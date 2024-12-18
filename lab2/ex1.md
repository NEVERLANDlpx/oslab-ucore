# Lab2-ex1及相关代码阅读

```
完成ex1并分析相关的.c,.h文件
```

# 一、ex1:first-fit

## 1.相关函数

### 1)default_init

```
default_init(void) { // 默认初始化函数
    list_init(&free_list); // 初始化空闲列表
    nr_free = 0; // 设置空闲块数量为 0
}
```



### 2)default_init_memmap

```
default_init_memmap(struct Page *base, size_t n);
//传入基页面地址，页面数量
```

**功能**：初始化一片空闲区域（page *base开始的n个页面，将其链入free_list).

**代码流程**：

```
->1）从base页面开始遍历n张page,设置每个page的flags和property为0，引用计数ref为0.
->2）设置base页面的property为n,为1；更新空闲页面数nr_free+=n
->3)若free_list为空，表明base开始是当前唯一的自由块，直接调用list_add把base->page_link加入free_list(即把base页面链入空闲链表)
->4)若free_list非空，则从free_list头部开始遍历，寻找合适的插入位置。确保page由小至大
```

首先初始化free_list中的每个page,具体包括：

A.设置p->flags的值为PG_property（PG_reserved标志设置在p->flags中）-

B.如果该page空闲，且不是空闲区域的first page,p->property应该被设置成0

C.如果该page空闲，且为空闲区域的first page,p->property应该被设置成block的总数

D.p->ref应该为0，因为现在p是空闲的，没有任何引用

E.使用p->page_link来吧page连接到free_list上（比如：list_add_before(&free_list,&(p->page_link))

最后，更新free mem block的总数：nr_free+=n

补充：

```
assert(n > 0);//如果结果为 `true`，程序继续执行；如果结果为 `false`，则触发断言失败。
```



### 3)default_alloc_pages

**可能的优化**：剩下的block不放回链表原来位置，而是按大小插入

功能：寻找free list中第一个block size>=n的free block；把该空闲块的大小作调整，返回分配的block的地址

```
default_alloc_pages(size_t n);
```

A.应该这么查找freelist:

```
 list_entry_t le = &free_list;
                        while((le=list_next(le)) != &free_list) {
                        ....
```

a.在while循环中，获取page，检查p->property是否>=n

```
 struct Page *p = le2page(le, page_link);
                        if(p->property >= n){ ...
```

b,如果找到这个p,则意味着我们找到了那个size>=n的free block,并且最开始的n个pages可以被分配了。这个page的一些标记位需要被设置：PG_reserverd=1,PG_property=0。将页面从free_list中取出。（而如果p->property>n,那么需要重新计算它的值，比如：le2page(le,page_link))->property = p->property - n;）

```
 if (page != NULL) {//找到的符合条件的free block(即page为头部的block)
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));//先把该page从free list中删除
        if (page->property > n) {//如果该block分走了n张page还有剩余
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));//把block的剩下部分放回原理位置
            //可能的优化：不放回原来位置，而是按大小插入
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
```

c.重新计算剩下free block的nr_free

d.返回p

B.如果我们找不到一个size>=n的block,返回NULL

### 4)default_free_pages

功能：把pages放回free list,也许可以把small free blocks融合成big free blocks

```
default_free_pages(struct Page *base, size_t n);
```

A.根据收回的blocks的基地址，查找free list,找到正确的地址（从低地址到高地址），并且插入pages(可能用到list_next,le2page,list_add_befire)

B,把pages的属性重置，比如p->ref,p->flags

C.尝试融合低地址或者高地址的blocks.需要注意正确改变一些pages的p->property

```
   //合并内存碎片的代码
   list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {//如果当前加入的base页面前还有页面
        p = le2page(le, page_link);
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
```



## 二、代码阅读

### 1.libs/list.h

1)实现双向链表节点list_entry_t类，每个节点有前屈和后向指针（prev,next）.

```
truct list_entry { // 定义链表节点结构
    struct list_entry *prev, *next; // 前驱和后继指针
};

typedef struct list_entry list_entry_t; // 定义链表节点类型为 list_entry_t

```

2)实现链表操作的内联函数，包括：

“内联函数设计为内部使用的函数，而不是作为公共 API 向外部暴露”

```
void list_init(list_entry_t *elm) ; // 初始化链表节点（前驱和后向指针都指向自己）
void list_add(list_entry_t *listelm, list_entry_t *elm) ; // 添加节点
void list_add_before(list_entry_t *listelm, list_entry_t *elm) ; // 在指定节点之前添加节点
void list_add_after(list_entry_t *listelm, list_entry_t *elm) ; // 在指定节点之后添加节点
void list_del(list_entry_t *listelm) ; // 删除指定节点
void list_del_init(list_entry_t *listelm) ; // 删除节点并重置
bool list_empty(list_entry_t *list) ; // 检查列表是否为空
list_entry_t *list_next(list_entry_t *listelm) ; // 获取下一个节点
list_entry_t *list_prev(list_entry_t *listelm) ; // 获取前一个节点

// 私有内联函数声明
void __list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) ; // 内部添加节点（在两个已知的连续节点prev,next间插入一个新节点）
void __list_del(list_entry_t *prev, list_entry_t *next) ; // 内部删除节点（前驱和后向指针彼此互指）

```

3)特点：内部函数在操作整个列表时，相较只操作单个节点更有用。因为当知晓了前向节点和后向节点时，能直接进行操作。

### 2.kern/mm/memlayout.h

1)free_area_t 结构

存储空闲页面的双向链表。构成是双向链表头节点+空页数量。

```
/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // number of free pages in this free list
} free_area_t;
```

2）page结构

```
struct Page {
    int ref;                        // 引用计数器（reference counter），用于跟踪对该物理页面的引用数量
    uint64_t flags;                 // 位标志（flags），用于描述该页面的状态。例如，标志可以表示页面是否被保留、是否是空闲的块的头等等
    unsigned int property;          // 表示空闲块的数量，通常用于内存管理中的首次适应算法（first fit memory allocation）
    list_entry_t page_link;         // 链表节点，允许该页面通过双向链表结构在空闲页面列表中链接。
};

/* 描述页面帧状态的标志 */
#define PG_reserved                 0       // 如果此位为 1：该页面被内核保留，不能在 alloc/free_pages 中使用；否则，此位为 0 
#define PG_property                 1       // 如果此位为 1：该页面是一个空闲内存块的头页面（包含一些连续地址的页面），可以在 alloc_pages 中使用；如果此位为 0：如果该页面是一个空闲内存块的头页面，则该页面和内存块已被分配。或者该页面不是头页面。
define le2page(le, member)                 \
    to_struct((le), struct Page, member) // 定义宏 le2page，将链表条目转换为页面
```

