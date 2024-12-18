# Ex1:理解基于FIFO的页面替换算法

初始化相关函数、页面换出相关函数、页面换入相关函数

## 一、初始化相关的函数（2个）

### 1.swap_init()

调用swapfs_init, **指定页面替换算法**，初始化页面交换管理器(sm->init)（在fifo中为空函数）,调用check_swap()

```
     swapfs_init();
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     int r = sm->init();
     check_swap();
```

### 2.swapfs_init

指定最大页面交换偏移量，max_swap_offset（=7）

```
    static_assert((PGSIZE % SECTSIZE) == 0);//确保一个Page的大小是整数个磁盘扇区
    if (!ide_device_valid(SWAP_DEV_NO)) {panic("swap fs isn't available.\n"); }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
    //最大的偏移=56/8=7.也就是有7页page可交换
```

## 二、页面换出相关的函数（18个）

### 1.swap_out

将指定数量的页面（由参数 `n` 指定）**从内存中换出到交换空间**（swap space），同时使对应的**TLB条目失效**。

```
int swap_out(struct mm_struct *mm, int n, int in_tick) {
    int i; 
    for (i = 0; i != n; ++i) { 、
        uintptr_t v;  // 用于存储虚拟地址
        struct Page *page;  // 用于保存被换出的页面
        int r = sm->swap_out_victim(mm, &page, in_tick);  // 选择一个要换出的页面
        if (r != 0) {  // 如果选择页面失败
            cprintf("i %d, swap_out: call swap_out_victim failed\n", i);  
            break;  
        }          
        // assert(!PageReserved(page));  // 确保页面没有被保留

        v = page->pra_vaddr;  // 获取要换出页面的虚拟地址
        pte_t *ptep = get_pte(mm->pgdir, v, 0);  // 根据虚拟地址获取页表项指针
        assert((*ptep & PTE_V) != 0);  // 确保页面是有效的

        if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0) {  // 将页面写入交换文件失败
            cprintf("SWAP: failed to save\n"); 
            sm->map_swappable(mm, v, page, 0);  // 将页面标记为可交换
            continue;  // 继续下一轮循环
        } else {  // 如果保存成功
            cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);  
            *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;  // 更新页表项，将其指向交换文件中的条目
            free_page(page);  // 释放页面
        }

        tlb_invalidate(mm->pgdir, v);  // 使 TLB 中的条目失效
    }
    return i;  // 返回实际换出的页面数量
}
```

### 2.swap_out_victim

**选择要替换出的页面**。把pra_list_head队列头部的page,即最早抵达的页面取下，并且把该页面的地址赋给ptr_page.

head <->entry3<->entry2<-->entry1<-> head(1,2,3)

```
static int _fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
     assert(head != NULL);
     assert(in_tick==0);
    list_entry_t* entry = list_prev(head);//pra_list_head中，head的前向节点，即队列头部
    if (entry != head) {//队列中不是只有head一个节点
        list_del(entry);//先从链表中删除head的前向节点
        *ptr_page = le2page(entry, pra_page_link);//再把该前向节点对应的page地址赋给ptr_page
    } else {
        *ptr_page = NULL;
    }
}
```

### 3.get_pte

**根据虚拟地址la寻找**（有必要的时候分配）**一个页表项**,并返回这个pte（页表项）的内核虚拟地址。

在swap_out，swap_in中被使用。

```
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];//找到对应的大大页（Giga Page）
    if (!(*pdep1 & PTE_V)) {//如果下一级页表不存在，那就给它分配一页，创造新页表
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {//指定了不创建，或者没有分配到页面，才返回NULL
            return NULL;
        }
        set_page_ref(page, 1);//设置1的引用数
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);//现在在虚拟地址中，因此要转换成KADDR再memset
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);//这里的R，W，X全0
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];//再下一级页表，即大页
    if (!(*pdep0 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
 //       memset(pa, 0, PGSIZE);
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];//找到la对应的页表项地址（也可能是刚分配的）
}

```

### 4.swapfs_write,ide_write_secs

将要替换出的**页面写入交换文件**中。

在swap_out中被使用。

```
int swapfs_write(swap_entry_t entry, struct Page *page) {
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}//将page2kva(page)地址处，一页（PAGE_NSECT）大小的数据，写入SWAP_DEV_NO设备的swap_offset(entry) * PAGE_NSECT偏移处（即写入第swap_offset(entry)页）
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;//计算出写入数据的起始位置。`SECTSIZE` 是每个扇区的字节数。
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);//将src指向的数据复制到ide数组的指定位置,大小为nsecs * SECTSIZE。
    return 0;
}
```

```
//调用时示例如下：
if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0) {  ..... }
```

### 5.swap_offset

**计算交换条目**（待交换的页面）在交换空间（swap mem_map)中的**偏移量**

在swapfs_write中被使用。

```
/* *
 * swap_offset - takes a swap_entry (saved in pte), and returns
 * the corresponding offset in swap mem_map.
 * */
#define swap_offset(entry) ({                                       \
               size_t __offset = (entry >> 8);                        \//提取 `entry` 中低 8 位以外的部分
               if (!(__offset > 0 && __offset < max_swap_offset)) {    \//offset需要在[0,7]之间
                    panic("invalid swap_entry_t = %08x.\n", entry);    \
               }                                                    \
               __offset;                                            \
          })
```

### 6._fifo_map_swappable

将要替换的页面成功写入交换文件后，调用该函数，**把该页面链入可交换页面队列**的末尾。

在swap_out中被使用。

head <->entry3<->entry2<-->entry1<-> head(1,2,3)

```
static int _fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{//把最新抵达的页面，链在pra_list_head的末尾
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);

    assert(entry != NULL && head != NULL);
    //record the page access situlation

    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);//把entry链在head后面，即把pra_page_link链在head之后
    return 0;
}
```

### 7.list_add,list_add_after,list_add_after

把一个**节点链入双向链表**的一个节点之后。fifo算法中，标记一个页面可替换时，把它链入可替换队列pra_list_head的head之后。

在_fifo_map_swappable中使用。

```
static inline void//把elm链在listelm之后
list_add(list_entry_t *listelm, list_entry_t *elm) {
    list_add_after(listelm, elm);
}

static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
}
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
    elm->next = next;
    elm->prev = prev;
}
```

### 8.list_del,__list_del

**把一个节点从双向链表中删除**。f,ifo算法中，选择要替换出的页面后，需要把该页面从可替换队列pra_list_head中删除。

在swap_out_victim中使用。

```
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
}
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
    next->prev = prev;
}
```

### 9.list_prev

获取一个节点的前向节点。fifo算法中，选择替换的页面是最先抵达的页面，即head节点的前向节点。

在swap_out_victim中使用。

```
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
}
```

### 10.le2_page,to_struct,offsetof

**通过结构体成员的地址，获取结构体的地址（指针）**。在fifo算法中，维护了一个list_entry_t类型的双向链表，链表上每个节点对应一个页面。在获取要替换的页面时，取pra_list_head的队列首部节点，把该list_entry_t类型的节点（page的pra_page_link成员）转变成page类型。

在swap_out_victim中使用。

```
//memlayout.h中
//通过list_entry的le指针，获得page结构体的指针
//struct Page *p = le2page(le, page_link);
#define le2page(le, member)                 \
    to_struct((le), struct Page, member) // 定义宏 le2page，将链表条目转换为页面

//根据给定的成员指针，获取到它所属于的整个结构体的指针
#define to_struct(ptr, type, member)                               \
    ((type *)((char *)(ptr) - offsetof(type, member)))

//返回成员member在结构体type中的字节偏移量
#define offsetof(type, member)                                      \
    ((size_t)(&((type *)0)->member))
//(type*)0:创建一个指向type类型的指针，指向地址0.空指针，不会引用真实的内存地址
//&(type*)0->member：得到的地址值，实际上是成员"member"在结构体中的偏移量
```

```
*ptr_page = le2page(entry, pra_page_link);
```

### 11.free_page

**释放一个指定的页面page。**

在swap_out中使用。

```
#define free_page(page) free_pages(page, 1)
```

```
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
//free_pages 释放连续n页的内存
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);//在释放过程中关中断
    { pmm_manager->free_pages(base, n); }//取决于采用哪个pmm_manager，默认是best_fit算法
    local_intr_restore(intr_flag);
}
```

```
//把pages放回free list,也许可以把small free blocks融合成big free blocks
static void best_fit_free_pages(struct Page *base, size_t n) {
   //略
}

```

### 12.tlb_invalidate

**刷新TLB条目**（直接全部刷新了）。在fifo算法中，替换出一个页面之后，需要刷新TLB条目。

在swap_out中使用。

```
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
```

```
static inline void flush_tlb() { asm volatile("sfence.vma"); } 
```



## 三、页面换入的函数

对于在页面换出中也用到的函数，此处不再赘述。

### 1.swap_in

**从交换空间加载页面到内存**，并获取加载后的页面

```
int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
     struct Page *result = alloc_page();//分配一个页面
     assert(result!=NULL);

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);//获取该地址对应的页表项
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));

     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)//从交换空间中读取该页表项
     {
        assert(r!=0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
     *ptr_result=result;//获取读到的页面
     return 0;
}
```

### 2.alloc_page

**分配一个页面。**

在swap_in中使用。

```
#define alloc_page() alloc_pages(1)
```

```
// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
//分配连续n页页面
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;

    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }//取决于具体的pmm_manager，默认使用best_fit
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
```

```
//寻找free list中最接近n的free block；把该空闲块的大小作调整，返回分配的block的地址
static void best_fit_free_pages(struct Page *base, size_t n) {//略}
```

### 3.swapfs_read、ide_read_secs

将页表项pte对应地址处的**页面，从交换空间读取到内存中**

在swap_in中使用。

```
int swapfs_read(swap_entry_t entry, struct Page *page) {//从交换空间中读取页面到内存中
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);//从ide[iobase]拷贝 nsecs扇区大小的数据到地址dst
    return 0;
}
```

```
 if ((r = swapfs_read((*ptep), result)) != 0){...}
```

### 4.set_page_ref

如果大页中的页表项不存在/页表中的页表项不存在，创建一个新的页表项，并把页面引用计数设成1.
在get_pte中使用。

```
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
```

    set_page_ref(page, 1)；

### 5.page2pa, page2ppn

page2ppn函数计算给定页的页帧号（PPN）。

`page2pa` 函数根据页帧号计算对应的物理内存地址（PA）.

在get_pte中使用。

```
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}
```

```
uintptr_t pa = page2pa(page);
```

### 6.memset

在指定页面虚拟地址处填充PGSIZE个0.

在get_pte中使用。

```
  memset(KADDR(pa), 0, PGSIZE);
```

### 7.KADDR

根据页面的物理地址，返回页面的虚拟地址。

在get_pte中使用。

```
/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })
```

### 8.pte_create

通过对应的页表号、页的类型（写？读？执行），**创建一个页表项**。

在get_pte中使用。

```
// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
}
```

```
*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
```
