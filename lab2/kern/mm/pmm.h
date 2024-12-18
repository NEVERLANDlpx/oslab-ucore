#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

#include <assert.h>
#include <atomic.h>
#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <riscv.h>

//add begin
extern unsigned int first_ppn;
//add end

// pmm_manager is a physical memory management class. A special pmm manager -
// XXX_pmm_manager
// only needs to implement the methods in pmm_manager class, then
// XXX_pmm_manager can be used
// by ucore to manage the total physical memory space.
struct pmm_manager {
    const char *name;  // XXX_pmm_manager's name
    void (*init)(
        void);  // initialize internal description&management data structure
                // (free block list, number of free block) of XXX_pmm_manager
    void (*init_memmap)(
        struct Page *base,
        size_t n);  // setup description&management data structcure according to
                    // the initial free physical memory space
    struct Page *(*alloc_pages)(
        size_t n);  // allocate >=n pages, depend on the allocation algorithm
    void (*free_pages)(struct Page *base, size_t n);  // free >=n pages with
                                                      // "base" addr of Page
                                                      // descriptor
                                                      // structures(memlayout.h)
    size_t (*nr_free_pages)(void);  // return the number of free pages
    void (*check)(void);            // check the correctness of XXX_pmm_manager
};

extern const struct pmm_manager *pmm_manager; //指向当前使用的物理内存管理器。

void pmm_init(void);

struct Page *alloc_pages(size_t n);
void free_pages(struct Page *base, size_t n);
size_t nr_free_pages(void); // number of free pages

#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)


/* *
 * PADDR - takes a kernel virtual address (an address that points above
 * KERNBASE),
 * where the machine's maximum 256MB of physical memory is mapped and returns
 * the
 * corresponding physical address.  It panics if you pass it a non-kernel
 * virtual address.
 * */
/*
    va_pa_offset 是虚拟地址到物理地址的转换偏移量。
    它的作用是简化虚拟地址和物理地址之间的转换，使得内核可以方便地通过加减偏移量来得到相应的物理地址或虚拟地址。
    PADDR 宏将内核虚拟地址（kva）转换为物理地址，通过减去 va_pa_offset 来实现虚拟地址到物理地址的映射。
    这种方式使得系统在需要访问内核空间的物理内存时可以快速转换，优化了内存访问效率。
*/
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
/*
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })
*/
extern struct Page *pages;  //pages 是一个数组，表示系统中所有的物理页
/*
Page 结构体包含 ref 字段，用于表示页面的引用计数。相关的辅助函数包括：
    page_ref：返回页面引用计数。
    set_page_ref：设置页面的引用计数。
    page_ref_inc 和 page_ref_dec：增加或减少页面的引用计数。
*/
extern size_t npage; //物理页的总数量。
extern const size_t nbase;  //在使用页面编号时，nbase 作为一个偏移量，使得可以将 Page 数组中的下标与实际物理页号进行对齐。
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }  //将 Page 转换为页号。

static inline uintptr_t page2pa(struct Page *page) {  //将 Page 转换为物理地址。
    return page2ppn(page) << PGSHIFT;
}



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }

static inline int page_ref_inc(struct Page *page) {
    page->ref += 1;
    return page->ref;
}

static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
}
static inline void flush_tlb() { asm volatile("sfence.vm"); }  //用于刷新 TLB（Translation Lookaside Buffer），以确保在更新页表之后立即生效。
//内核堆栈
//bootstack 和 bootstacktop：定义在 entry.S 中的内核堆栈的开始和结束地址，用于系统启动时的内存初始化。
extern char bootstack[], bootstacktop[]; // defined in entry.S

#endif /* !__KERN_MM_PMM_H__ */
