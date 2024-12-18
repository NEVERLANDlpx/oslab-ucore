#include <defs.h>
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <slub_pmm.h>
#include <stdio.h>

#define MIN_ORDER 4
#define MAX_ORDER 11
#define MAX_ALLOC_SIZE (1 << MAX_ORDER) // 最大分配大小 2048

// slab中存放的对象，也就是小内存块
typedef struct Object {
    size_t order;
    list_entry_t object_link;
} Object_t;

// slab中空闲的内存块，slab有多个，每个slab中存放不同大小的内存块
typedef struct Slab {
    free_area_t free_objects;  // 空闲的内存块链表及数量
    size_t order;              // slab中存放的内存块的大小为2^order
    size_t num_objects;        // slab中对象的数量
    struct Page *pages;        // 关联的页面
} Slab_t;

#define Slab_size(i) (1 << (i))
#define Object_num(i) (1 << (12-i))
#define le2object(le, member) to_struct((le), Object_t, member)

Slab_t slab_list[MAX_ORDER - MIN_ORDER + 1]; // slab的数组，数组下标为order，存放不同大小的slab

static void slab_init(Slab_t *slab, size_t order) {
    slab->order = order;
    slab->num_objects = Object_num(order);
    list_init(&slab->free_objects.free_list); // 初始化空闲链表
    slab->free_objects.nr_free = 0; // 初始化空闲块数量
    slab->pages = NULL; // 初始化页面为 NULL
}

static void slub_init(void) {
    for (size_t i = MIN_ORDER; i <= MAX_ORDER; i++) {
        slab_init(&slab_list[i - MIN_ORDER], i);
    }
}

static void slub_init_memmap() {
    // 在这里初始化与 slab 关联的页面结构
    for (size_t i = 0; i < (MAX_ORDER - MIN_ORDER + 1); ++i) {
        struct Page* page = alloc_pages(4); // 分配4个页面
        if (!page) {
            cprintf("Failed to allocate page for slab %zu\n", i);
            continue; // 处理分配失败的情况
        }
        
        Slab_t *slab = &slab_list[i];
        slab->pages = page; // 将当前页面关联到 slab
        slab->free_objects.nr_free = slab->num_objects; // 初始化空闲块数量

        cprintf("Allocated page %p for slab %d\n", page, i);

        // 将这个页面的内存块添加到 slab 的 free_objects 中
        for (size_t j = 0; j < slab->num_objects; j++) {
            Object_t *obj = (Object_t *)((char*)page + j * Slab_size(slab->order)); // 使用 Slab_size 计算对象地址
            list_add(&slab->free_objects.free_list, &obj->object_link); // 添加到空闲对象链表
        }
        
    }
}

static void *slub_alloc(size_t size) {
    if (size > MAX_ALLOC_SIZE) {
        // 请求内存大于 2048，分配新的页面
        struct Page *new_page = alloc_pages((size + PGSIZE - 1) / PGSIZE); // 分配页面
        return new_page ? (void *)new_page : NULL; // 返回页面指针
    }

    // 请求内存小于或等于 2048，查找合适的 slab
    for (size_t i = 0; i < MAX_ORDER - MIN_ORDER + 1; i++) {
        Slab_t *slab = &slab_list[i];
        if (size <= Slab_size(slab->order) && slab->free_objects.nr_free > 0) {
            // 找到合适的 slab，分配对象
            list_entry_t *freelist_entry = slab->free_objects.free_list.next;
            Object_t *obj = le2object(freelist_entry, object_link);
            list_del(freelist_entry); // 从空闲链表中删除
            slab->free_objects.nr_free--; // 更新空闲数量
            return (void *)obj; // 返回对象指针
        }
    }

    // 如果没有合适的 slab，分配新的页面
    return slub_alloc(size);
}

static void slub_free(void *ptr) {
    if (!ptr) return; // 防止空指针

    Object_t *obj = (Object_t *)ptr;
    size_t order = obj->order; // 获取对象的 order
    Slab_t *slab = &slab_list[order - MIN_ORDER];

    list_add(&obj->object_link, &slab->free_objects.free_list); // 将对象添加回空闲链表
    slab->free_objects.nr_free++; // 更新空闲数量

    // 合并相邻的空闲对象
    list_entry_t *le = slab->free_objects.free_list.prev; // 获取空闲列表的前一个元素
    if (le != &slab->free_objects.free_list) { // 如果不是空链表
        Object_t *prev_obj = le2object(le, object_link); // 获取前一个对象
        if ((uintptr_t)prev_obj + Slab_size(order) == (uintptr_t)obj) { // 判断是否相邻
            // 合并相邻的块
            list_del(le); // 从空闲链表中删除前一个对象
            slab->free_objects.nr_free--; // 减少空闲数量
            obj = prev_obj; // 更新当前对象为合并后的对象
            obj->order = order; // 更新 order
        }
    }

    // 重新检查下一个对象是否可以合并
    le = list_next(&obj->object_link); // 获取下一个元素
    if (le != &slab->free_objects.free_list) { // 如果不是空链表
        Object_t *next_obj = le2object(le, object_link); // 获取下一个对象
        if ((uintptr_t)obj + Slab_size(order) == (uintptr_t)next_obj) { // 判断是否相邻
            // 合并相邻的块
            list_del(le); // 从空闲链表中删除下一个对象
            slab->free_objects.nr_free--; // 减少空闲数量
            obj->order = order; // 更新 order
        }
    }
}


static void slub_free_pages(struct Page *base, size_t n) {
    free_pages(base, n); // 释放 n 页面
}

void slub_check(void) {
    slub_init();
    slub_init_memmap();

    void *ptr1 = slub_alloc(1024);
    void *ptr2 = slub_alloc(2048);
    void *ptr3 = slub_alloc(4096);

    assert(ptr1 != NULL);
    assert(ptr2 != NULL);
    assert(ptr3 != NULL);

    // 检查每个 slab 的状态
    for (size_t i = 0; i < MAX_ORDER - MIN_ORDER + 1; i++) {
        Slab_t *slab = &slab_list[i];
        cprintf("Slab order %d: num_objects %d, free %d\n",
               slab->order, slab->num_objects, slab->free_objects.nr_free);
    }

    // 释放分配的内存
    slub_free(ptr1);
    //slub_free(ptr2);
    //slub_free(ptr3);

    assert(slab_list[MIN_ORDER].free_objects.nr_free == slab_list[MIN_ORDER].num_objects);
}