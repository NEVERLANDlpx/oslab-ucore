#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <sync.h>
#include <vmm.h>
#include <riscv.h>

// virtual address of physical page array
struct Page *pages;
// amount of physical memory (in pages)
size_t npage = 0;
// The kernel image is mapped at VA=KERNBASE and PA=info.base
uint_t va_pa_offset;
// memory starts at 0x80000000 in RISC-V
const size_t nbase = DRAM_BASE / PGSIZE;

// virtual address of boot-time page directory
pde_t *boot_pgdir = NULL;
// physical address of boot-time page directory
uintptr_t boot_cr3;

// physical memory management
const struct pmm_manager *pmm_manager;


static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &default_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
/*
分配 n 页连续的物理内存。
如果内存不足且页大小为 1 页（n == 1），尝试通过 swap_out 将某些页换出，释放内存
local_intr_save 和 local_intr_restore：关闭并恢复中断，确保内存操作的原子性
*/
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    
    while (1) {
        local_intr_save(intr_flag);  // 保存当前中断状态，并关闭中断。
        { page = pmm_manager->alloc_pages(n); }  // 调用物理内存管理器分配 n 页连续内存。
        local_intr_restore(intr_flag);  // 恢复之前的中断状态。

        if (page != NULL || n > 1 || swap_init_ok == 0) break;  //只有当 page == NULL 且 n == 1 且页面置换模块已经初始化时，才会继续执行页面置换

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
    local_intr_restore(intr_flag);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
    local_intr_restore(intr_flag);
    return ret;
}

/* page_init - initialize the physical memory management */
static void page_init(void) {
    extern char kern_entry[];

    va_pa_offset = KERNBASE - 0x80200000;
    uint64_t mem_begin = KERNEL_BEGIN_PADDR;
    uint64_t mem_size = PHYSICAL_MEMORY_END - KERNEL_BEGIN_PADDR;
    uint64_t mem_end = PHYSICAL_MEMORY_END; //硬编码取代 sbi_query_memory()接口
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
            mem_end - 1);
    uint64_t maxpa = mem_end;

    if (maxpa > KERNTOP) {
        maxpa = KERNTOP;
    }

    extern char end[];

    npage = maxpa / PGSIZE;
    // BBL has put the initial page table at the first available page after the
    // kernel
    // so stay away from it by adding extra offset to end
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    if (freemem < mem_end) {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}
/*
enable_paging 函数用于在 RISC-V 架构上启用分页机制（Paging），通过设置控制寄存器（satp）完成地址空间的切换，使虚拟地址转换为物理地址的分页机制生效。
write_csr 是 RISC-V 指令集提供的操作 CSR（Control and Status Register，控制和状态寄存器）的一个函数/宏，用于写入指定的 CSR 寄存器。
这里将值写入 satp 寄存器（Supervisor Address Translation and Protection），它控制分页机制和地址空间。
satp 是 RISC-V 中用于分页的关键寄存器，控制地址空间转换。其格式如下：
┌─────────┬─────────────┬──────────────┬──────────────┐
│ Mode(4) │ ASID (16)   │ PPN (44/24) │ Reserved     │
└─────────┴─────────────┴──────────────┴──────────────┘
satp 的 Mode 设置为 Sv39。
页表的物理地址（PDT 基址）通过 boot_cr3 提供。
boot_cr3 是页表的物理地址，表示内核引导时的根页表（Page Directory Table，PDT）的物理基地址。
RISCV_PGSHIFT 是页大小的位移常量（通常为 12 位，对应 4 KB 页）。
boot_cr3 >> RISCV_PGSHIFT 提取页表的物理页号（PPN）。
写入 satp 后，CPU 从分页模式(所有程序访问的地址直接映射到物理内存，不涉及任何转换)切换到虚拟地址模式(CPU访问内存时，使用的是虚拟地址)。
*/
static void enable_paging(void) {
    write_csr(satp, (0x8000000000000000) | (boot_cr3 >> RISCV_PGSHIFT));
}

/**
 * @brief      setup and enable the paging mechanism
 *
 * @param      pgdir  The page dir,页目录的起始地址，用于表示整个分页结构的入口,在 Sv39 模式中，它指向最高层的页表（Giga 页表）
 * @param[in]  la     Linear address of this memory need to map
 * @param[in]  size   Memory size
 * @param[in]  pa     Physical address of this memory
 * @param[in]  perm   The permission of this memory,页表项的权限标志，例如读/写/用户访问权限（PTE_R, PTE_W, PTE_U 等）
 */
//将线性地址段（la 到 la + size）映射到物理地址段（pa 到 pa + size）
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size,
                             uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa)); //检查线性地址 la 和物理地址 pa 的页内偏移是否相同
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;  //根据 size 和地址偏移计算需要映射的页数
    la = ROUNDDOWN(la, PGSIZE);  //将线性地址 la 和物理地址 pa 对齐到页边界
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE) {  //线性地址和物理地址分别加上页大小，指向下一页
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pte_create(pa >> PGSHIFT, PTE_V | perm);
    }
}

// boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
// note: this function is used to get the memory for PDT(Page Directory
// Table)&PT(Page Table)
static void *boot_alloc_page(void) {
    struct Page *p = alloc_page();
    if (p == NULL) {
        panic("boot_alloc_page failed.\n");
    }
    return page2kva(p);
}

// pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup
// paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void pmm_init(void) {
    // We need to alloc/free the physical memory (granularity is 4KB or other
    // size).
    // So a framework of physical memory manager (struct pmm_manager)is defined
    // in pmm.h
    // First we should init a physical memory manager(pmm) based on the
    // framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();

    // use pmm->check to verify the correctness of the alloc/free function in a
    // pmm
    check_alloc_page();
    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    extern char boot_page_table_sv39[];
    boot_pgdir = (pte_t*)boot_page_table_sv39;
    boot_cr3 = PADDR(boot_pgdir);
    check_pgdir();
    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    // But shouldn't use this map until enable_paging() & gdt_init() finished.
    //boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, PADDR(KERNBASE),
     //                READ_WRITE_EXEC);将整个物理内存映射到虚拟地址 KERNBASE（3GB）开始的线性地址空间
    /*
    虚拟地址：KERNBASE ~ KERNBASE + KMEMSIZE
    对应物理地址：0 ~ KMEMSIZE
    */
    // temporary map:
    // virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M =
    // phy_addr 0~4M
    // boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];

    //    enable_paging();

    // now the basic virtual memory map(see memalyout.h) is established.
    // check the correctness of the basic virtual memory map.
    check_boot_pgdir();

}

// get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
/*
    函数功能：根据虚拟地址 la 和根页目录 pgdir，查找或创建相应的页表项（PTE）
    pgdir：页目录的起始地址
    la：需要查找的虚拟地址。
    create：布尔值，指示(指示如果页表项不存在，是否需要创建。)是否需要在页表中创建缺失的页表项（如果为 true，则创建；否则返回 NULL）。
    如果 create 为真且页表项不存在，则分配新的页表并建立映射
*/
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    /*
     *ess, please use KADDR()
     * please read pmm.h for useful macros
     *
     * If you need to visit a physical addr
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
     *   KADDR(pa) : takes a physical address and returns the corresponding
     * kernel virtual address.
     *   set_page_ref(page,1) : means the page be referenced by one time
     *   page2pa(page): get the physical address of memory which this (struct
     * Page *) page  manages
     *   struct Page * alloc_page() : allocation a page
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the
     * memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry
     * flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    /*
        PDX1(la) 计算出虚拟地址 la 对应的 Giga 页表项索引。
        pgdir[PDX1(la)] 提取出 Giga 页表项。
    */
    pde_t *pdep1 = &pgdir[PDX1(la)]; 
    if (!(*pdep1 & PTE_V)) { //如果不存在有效映射，则需要创建下一级页表。
        struct Page *page;  
        if (!create || (page = alloc_page()) == NULL) {  //如果 Giga 页表项无效，并且 create 为真，则分配一个物理页用于存储下一层页表
            return NULL;
        }
        set_page_ref(page, 1); // 设置物理页引用计数
        uintptr_t pa = page2pa(page); //将物理页面对象转换为物理地址
        memset(KADDR(pa), 0, PGSIZE);  // 将页清零
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V); //创建 Giga 页表项，设置物理页号（PPN）和权限位（如用户可访问 PTE_U、有效位 PTE_V）
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    /*
    PDE_ADDR(*pdep0):
    提取 Mega 页表项中的物理地址，指向最后一级页表。
    PTX(la):
    计算虚拟地址 la 在最后一级页表中的索引。
    通常定义为 PTX(la) = (la >> 12) & 0x1FF。
    KADDR:
    转换最后一级页表的物理地址为内核虚拟地址。
    */
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];  //返回最终 PTE(指向目标页表项的指针)
}

// get_page - get related Page struct for linear address la using PDT pgdir
/*
该函数实现了根据线性地址 la 和页表目录基地址 pgdir 获取与之关联的物理页面结构体 struct Page 的功能，同时支持可选地存储页表项地址
ptep_store:
一个指针的指针，用于存储页表项的地址（PTE 的指针）
*/
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
    /*
    调用 get_pte 函数，尝试从页表中找到对应线性地址 la 的页表项（PTE）。
    get_pte 的最后一个参数为 0，表示不创建新的页表项（仅查找）。
    */
    pte_t *ptep = get_pte(pgdir, la, 0); 
    if (ptep_store != NULL) {  //如果需要保存 PTE 地址，存储到 ptep_store
        *ptep_store = ptep; //如果 ptep_store 不为空，将 ptep 地址存储到 ptep_store 中
    }
    if (ptep != NULL && *ptep & PTE_V) {  //检查 ptep 是否有效（非空）。检查 PTE 是否标记为有效（PTE_V 位）
        return pte2page(*ptep);  //如果 PTE 有效，通过 pte2page 函数将页表项中的物理页号（PPN）转换为物理页面结构体
    }
    return NULL;
}

// page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
// note: PT is changed, so the TLB need to be invalidate
/*
该函数负责删除页表项 (PTE)，并释放与其关联的物理页面（如果不再被引用）。
在修改页表后，同时需要更新 TLB（Translation Lookaside Buffer）以确保内存映射的正确性。
*/
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    /*
     *
     * Please check if ptep is valid, and tlb must be manually updated if
     * mapping is updated
     *
     * Maybe you want help comment, BELOW comments can help you finish the code
     *
     * Some Useful MACROs and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   struct Page *page pte2page(*ptep): get the according page from the
     * value of a ptep
     *   free_page : free a page
     *   page_ref_dec(page) : decrease page->ref. NOTICE: ff page->ref == 0 ,
     * then this page should be free.
     *   tlb_invalidate(pde_t *pgdir, uintptr_t la) : Invalidate a TLB entry,
     * but only if the page tables being
     *                        edited are the ones currently in use by the
     * processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry
     * flags bit : Present
     */
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
        struct Page *page =
            pte2page(*ptep);  //(2) find corresponding page to pte
        page_ref_dec(page);   //(3) decrease page reference
        if (page_ref(page) ==
            0) {  //(4) and free this page when page reference reachs 0
            free_page(page);
        }
        *ptep = 0;                  //(5) clear second page table entry,将页表项清零，表示该线性地址已不再映射任何物理页面
        tlb_invalidate(pgdir, la);  //(6) flush tlb,TLB 是 CPU 的一个高速缓存，用于存储线性地址到物理地址的映射
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
/*
page_remove 作为对页面移除操作的简化接口，负责调用 get_pte 和 page_remove_pte
page_remove:
    是更高层的接口。
    负责从页表目录 pgdir 和线性地址 la 中定位具体的页表项。
    调用 page_remove_pte 来执行实际的页面释放操作。
page_remove_pte:
    是低层操作，直接对指定的页表项 ptep 进行处理。
    不涉及页表的解析或查找，假定调用者已提供正确的页表项。
*/
void page_remove(pde_t *pgdir, uintptr_t la) {
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep != NULL) {
        page_remove_pte(pgdir, la, ptep);
    }
}

// page_insert - build the map of phy addr of an Page with the linear addr la
// paramemters:
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);  //调用 get_pte 获取虚拟地址 la 对应的页表项指针。如果不存在，则创建相应的页表
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);  //增加 page 的引用计数，表示该物理页被一个新的虚拟地址引用。
    if (*ptep & PTE_V) {  //检查页表项是否有效（PTE_V 表示有效位）
        struct Page *p = pte2page(*ptep);
        if (p == page) {  //如果当前页表项指向相同的物理页 page，无需重新映射，减少 page 的引用计数
            page_ref_dec(page);
        } else {  //如果当前页表项指向不同的物理页：
            page_remove_pte(pgdir, la, ptep); //调用 page_remove_pte 清除旧的映射关系，释放旧的物理页。
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);  //使用 pte_create 构造新的页表,PTE_V | perm：设置页表项有效位和权限位。
    tlb_invalidate(pgdir, la);
    return 0;
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
    struct Page *page = alloc_page();
    if (page != NULL) {
        if (page_insert(pgdir, page, la, perm) != 0) {
            free_page(page);
            return NULL;
        }
        if (swap_init_ok) {
            swap_map_swappable(check_mm_struct, la, page, 0);
            page->pra_vaddr = la;
            assert(page_ref(page) == 1);
            // cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x,
            // pra_link_next %x in pgdir_alloc_page\n", (page-pages),
            // page->pra_vaddr,page->pra_page_link.prev,
            // page->pra_page_link.next);
        }
    }

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}

static void check_pgdir(void) {
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert(page_ref(p1) == 1);

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);

    p2 = alloc_page();
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(*ptep & PTE_U);
    assert(*ptep & PTE_W);
    assert(boot_pgdir[0] & PTE_U);
    assert(page_ref(p2) == 1);

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
    assert(page_ref(p1) == 2);
    assert(page_ref(p2) == 0);
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);

    page_remove(boot_pgdir, 0x0);
    assert(page_ref(p1) == 1);
    assert(page_ref(p2) == 0);

    page_remove(boot_pgdir, PGSIZE);
    assert(page_ref(p1) == 0);
    assert(page_ref(p2) == 0);

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;

    assert(nr_free_store==nr_free_pages());

    cprintf("check_pgdir() succeeded!\n");
}

static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }


    assert(boot_pgdir[0] == 0);

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 2);

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);

    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;

    assert(nr_free_store==nr_free_pages());

    cprintf("check_boot_pgdir() succeeded!\n");
}
/*
根据输入的字节数 n，计算需要的页数。
分配对应的物理页框，并将其映射为内核虚拟地址返回。
*/
void *kmalloc(size_t n) {  
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
    base = alloc_pages(num_pages);
    assert(base != NULL);
    ptr = page2kva(base);
    return ptr;
}
/*
内核虚拟地址转物理页框：
使用 kva2page 将虚拟地址 ptr 转换为对应的物理页框结构 base。
释放内存：
调用 free_pages，将 base 开始的 num_pages 个连续页框标记为可用。
*/
void kfree(void *ptr, size_t n) {
    assert(n > 0 && n < 1024 * 0124);
    assert(ptr != NULL);
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
