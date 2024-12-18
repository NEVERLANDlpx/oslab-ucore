#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

// 最大的 Buddy 系统管理层级
#define BuddyMaxLevel 11
free_area_t buddy_system_free_area[BuddyMaxLevel];
#define free_list(i) buddy_system_free_area[(i)].free_list
#define nr_free(i) buddy_system_free_area[(i)].nr_free

// 初始化 Buddy 系统，设置所有层级的空闲列表和空闲块数量
static void buddy_system_init(void) 
{   
    for(int level = 0; level < BuddyMaxLevel; level++) // 遍历所有的管理层级，从 0 到 BuddyMaxLevel-1
    {
        list_init(&(buddy_system_free_area[level].free_list)); // 对每个层级的空闲链表进行初始化
        // 这个链表用于存储该层级中所有空闲的内存块
        nr_free(level)=0; //每个层级对应的 `nr_free` 记录该级别内存块的数量，在初始状态下，所有层级的空闲块数量为 0
    }
}

// 初始化内存映射，将所有物理内存块加入空闲链表
static void buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n> 0);
    struct Page *page = base;

    // 初始化每页属性，重置所有页的标志位和引用计数
    for (; page != base + n; page++) 
    {
        assert(PageReserved(page)); //assert(PageReserved(page));   确保页处于保留状态，避免重复初始化
        page->flags = page->property = 0; // 清除页的标志位和属性
        set_page_ref(page, 0);  //// 将引用计数重置为0
    }

    // 将内存块按最大块大小分配到各个级别的空闲链表中
    size_t remaining_pages = n;
    int level = BuddyMaxLevel - 1;
    int block_size = 1 << level; // 当前块大小
    page = base;

    while (remaining_pages > 0) 
    {
        page->property = block_size; // 设置块大小
        SetPageProperty(page); // 标记为已设置属性的空闲块
        nr_free(level)++; // 更新对应级别的空闲块数量
        list_add_before(&(free_list(level)), &(page->page_link)); // 添加到空闲链表
        remaining_pages -= block_size;

        // 如果剩余内存不足以填满当前块，递减到下一个级别
        while (level > 0 && remaining_pages < block_size) 
        {
            block_size >>= 1; // 减半块大小
            level--; 
        }
        page += block_size; // 跳到下一个块的起始页
    }
}

// 分裂一个较大的块为两个较小的块
static void split_page(int level) {
    // 如果当前层级没有空闲块，向更高层级分裂
    if (list_empty(&(free_list(level)))) 
    {
        split_page(level + 1);  // 递归调用 `split_page`，直到找到包含空闲块的级别
    }
    list_entry_t* entry = list_next(&(free_list(level)));  // 从链表获取第一个空闲块的链表项
    struct Page *page = le2page(entry, page_link);
    list_del(&(page->page_link));  // 从链表获取第一个空闲块的链表项
    nr_free(level)--; // 减少当前级别的空闲块数量

    // 新分裂出的两个块，大小为当前块的一半
    int new_block_size = 1 << (level - 1); // 计算新的块大小为当前块大小的一半
    struct Page *buddy_page = page + new_block_size;  // 计算新伙伴块的位置
    page->property = buddy_page->property = new_block_size; // 设置两个小块的大小属性
    SetPageProperty(buddy_page);  // 标记伙伴块的空闲属性
      // 将两个小块添加到下一级别的空闲链表中
    list_add(&(free_list(level - 1)), &(page->page_link));
    list_add(&(page->page_link), &(buddy_page->page_link));
    nr_free(level - 1) += 2;
}

// 分配所需数量的页面块
static struct Page * buddy_system_alloc_pages(size_t num_pages) {
    assert(num_pages > 0);
    if (num_pages > (1 << (BuddyMaxLevel - 1))) 
    {
        return NULL;  //检查请求的页数是否超过最大块大小，如果超过则返回 NULL，无法分配
    }
    struct Page *allocated_page = NULL;  // 用于保存分配到的页面
    int level = BuddyMaxLevel - 1;  // 从最大级别开始查找

    // 找到最小的满足需求的块级别
    while (num_pages < (1 << level)) 
    {
        level--;
    }
    level++;
    // 检查从请求级别到最大级别是否存在空闲块
    int free_flag = 0;
    for (int i = level; i < BuddyMaxLevel; i++) free_flag += nr_free(i);
    if (free_flag == 0) return NULL;  // 无可用块，返回 NULL

    //如果当前级别没有空闲块，则递归调用分裂函数进行分裂
    if (list_empty(&(free_list(level)))) 
    {
        split_page(level + 1);
    }
    if (list_empty(&(free_list(level)))) return NULL;

    list_entry_t *entry = list_next(&(free_list(level)));  // 分配块，从当前级别的空闲链表中取出第一个块
    allocated_page = le2page(entry, page_link);
    list_del(&(allocated_page->page_link));  // 从链表中移除已分配块
    ClearPageProperty(allocated_page);  // 清除该块的空闲属性，表示已分配

    return allocated_page;
}

// 将空闲块加入链表中，确保链表按地址顺序排列
static void add_page(int level, struct Page* block_page) 
{
    if (list_empty(&(free_list(level)))) // 检查当前级别的空闲列表是否为空
    {  // 如果是空的，则直接将当前块添加到该空闲链表中
        list_add(&(free_list(level)), &(block_page->page_link));
    } 
    else 
    {
        list_entry_t* entry = &(free_list(level));
        // 遍历当前级别的空闲列表，找到适当的位置插入新的块
        // 以保持链表中块按地址的顺序排列
        while ((entry = list_next(entry)) != &(free_list(level))) 
        {
            struct Page* curr_page = le2page(entry, page_link);
            if (block_page < curr_page)  // 如果当前块的地址小于遍历到的块的地址，找到插入位置
            {
                list_add_before(entry, &(block_page->page_link));  // 在当前 entry 前插入新的块
                break;
            } 
            else if (list_next(entry) == &(free_list(level))) //如果遍历到最后一个块且尚未找到位置，插入到链表末尾
            {
                list_add(entry, &(block_page->page_link));
            }
        }
    }
}

// 获取伙伴块
// 根据当前页块的物理页号和块大小级别，计算并返回对应的伙伴块。
// 伙伴块是与当前块大小相同、相邻的块，并且两者可以合并为一个更大的块。
static struct Page* buddy_get_buddy(struct Page *page) {
    unsigned int level = page->property;  // 获取当前页块的级别 (大小级别)
    
    // 计算伙伴块的物理页号
    // first_ppn是在ppm.c中新声明的全局变量，表示第一个可分配物理内存页在pages数组的下标.用代码中的异或计算便可得到伙伴块的头页在pages数组中的下标.
    unsigned int buddy_ppn = first_ppn + ((1 << level) ^ (page2ppn(page) - first_ppn));  
    //将该偏移量与块大小 1 << level 进行 异或运算，可以找到伙伴块的偏移量
    // 判断伙伴块是在当前块的左侧还是右侧，并返回对应的伙伴页
    if (buddy_ppn > page2ppn(page)) {
        return page + (buddy_ppn - page2ppn(page));  // 右侧的伙伴块
    } else {
        return page - (page2ppn(page) - buddy_ppn);  // 左侧的伙伴块
    }
}

/*

buddy_free_pages的思路如下:

step 1: 将阶为i, 大小为 2^i的当前块插入伙伴数组的第i条链表。获取当前块的伙伴块

step 2:检查当前阶为i, 大小为2^i块的伙伴块是否空闲.若不空闲则条至step 6

step 3: 从第i条链表中将当前块与伙伴块删除

step 4: 判断当前块的伙伴块是否为左块(伙伴块头页地址小于当前块), 若为左块则将当前块的指针指向伙伴块

step 5:将当前块的property加一，i = i +1，跳至step 1

step 6：释放完成返回。
*/
static void buddy_system_free_pages(struct Page *base, size_t num_pages) {
    assert(num_pages > 0);  // 检查释放的块大小大于0
    assert((num_pages & (num_pages - 1)) == 0);  // 确保块大小是2的幂 (伙伴系统要求)

    assert(num_pages < (1 << (BuddyMaxLevel - 1)));  // 确保释放块小于系统能管理的最大块

    struct Page *page = base;
    
    // 清除每个页的保留标志和引用计数
    for (; page != base + num_pages; page++) {
        assert(!PageReserved(page) && !PageProperty(page));  // 页不能有保留或其他属性
        page->flags = 0;  // 清除页的标志
        set_page_ref(page, 0);  // 设置引用计数为0
    }
    
    base->property = num_pages;  // 设置当前块的大小
    SetPageProperty(base);  // 标记当前页块为空闲块

    // 计算当前块所属的级别（基于块大小）
    int level = 0;
    while (num_pages > 1) {
        num_pages /= 2;
        level++;
    }
    
    // 将当前块插入到对应级别的空闲链表中
    add_page(level, base);

    // 检查并尝试合并伙伴块
    struct Page *buddy = buddy_get_buddy(base);  // 获取当前块的伙伴块
    while (!PageProperty(buddy) && level < BuddyMaxLevel) {  // 伙伴块空闲且未达到最大块级别时
        // 如果当前块是右侧块，那么交换伙伴块和当前块
        if (base > buddy) {
            base->property = -1;  // 将右侧块标记为无效
            ClearPageProperty(base);  // 清除当前块的空闲属性
            struct Page* temp = base;
            base = buddy;
            buddy = temp;
        }
        // 将两个块从对应的空闲链表中移除
        list_del(&(base->page_link));
        list_del(&(buddy->page_link));

        // 合并后的块级别加1
        base->property += 1;
        // 将合并后的大块加入到更高级别的空闲链表中
        list_add(&(free_list(base->property)), &(base->page_link));

        // 获取合并后的新伙伴块，并继续合并
        buddy = buddy_get_buddy(base);
        level++;
    }

    // 清除最后合并后的块的属性，表示该块空闲
    ClearPageProperty(base);
}


// 返回空闲页面总数
static size_t buddy_system_nr_free_pages(void) {
    size_t total_pages = 0;
    for(int level = 0; level < BuddyMaxLevel; level++) 
    {
        total_pages += nr_free(level) << level;
    }
    return total_pages;
}

static void
buddy_system_check(void) {
}

static void
basic_check(void) {
    int count = 0, total = 0;
    // 遍历所有阶层，计算空闲块总数
    for (int i = 0; i < BuddyMaxLevel; i++) 
    {
        list_entry_t *le = &free_list(i);
        while ((le = list_next(le)) != &free_list(i)) 
        {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p)); // 确认空闲块的 PageProperty 标志
            count++;
            total += (1 << i); // 每阶的块大小为 2^i
        }
    }
    assert(total == buddy_system_nr_free_pages()); // 验证空闲页面总数

    // 基础分配与释放测试
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = buddy_system_alloc_pages(1)) != NULL); // 分配一个 4KB 页面
    assert((p1 = buddy_system_alloc_pages(1)) != NULL); // 再分配一个 4KB 页面
    assert((p2 = buddy_system_alloc_pages(1)) != NULL); // 再分配一个 4KB 页面
    assert(p0 != p1 && p0 != p2 && p1 != p2); // 确保分配的页面是不同的
    buddy_system_free_pages(p0, 1); // 释放 p0
    buddy_system_free_pages(p1, 1); // 释放 p1
    buddy_system_free_pages(p2, 1); // 释放 p2
    assert(buddy_system_nr_free_pages() == total); // 验证释放后空闲页面总数

    // 测试块分裂：分配一个较大的块，并验证是否能正确分裂
    struct Page *big_block = buddy_system_alloc_pages(8); // 分配 32KB 块
    assert(big_block != NULL);
    buddy_system_free_pages(big_block, 8); // 释放大块并检查是否可以正确合并
    assert(buddy_system_nr_free_pages() == total); // 验证合并后空闲页面数

    // 测试分裂与合并的行为
    struct Page *small_block1 = buddy_system_alloc_pages(1); // 分配 4KB
    struct Page *small_block2 = buddy_system_alloc_pages(1); // 再分配 4KB
    struct Page *small_block3 = buddy_system_alloc_pages(2); // 再分配 8KB
    assert(small_block1 != NULL && small_block2 != NULL && small_block3 != NULL);
    
    // 验证释放小块时是否可以合并回较大的块
    buddy_system_free_pages(small_block3, 2); // 释放 8KB 块
    buddy_system_free_pages(small_block2, 1); // 释放 4KB 块
    buddy_system_free_pages(small_block1, 1); // 释放 4KB 块
    assert(buddy_system_nr_free_pages() == total); // 验证空闲页面总数

    // 测试分裂行为：分配大块并分裂为小块
    struct Page *huge_block = buddy_system_alloc_pages(16); // 分配 64KB 块
    assert(huge_block != NULL);
    buddy_system_free_pages(huge_block, 16);  // 释放大块，验证是否能分裂为较小的块并返回空闲列表
    assert(buddy_system_nr_free_pages() == total); // 验证释放后空闲页面总数

    // 最终检查，遍历空闲列表并验证每个块的属性
    for (int i = 0; i < BuddyMaxLevel; i++) 
    {
        list_entry_t *le = &free_list(i);
        while ((le = list_next(le)) != &free_list(i)) 
        {
            struct Page *p = le2page(le, page_link);
            count--;
            total -= (1 << i); // 减少该阶层的页数
        }
    }

    // 验证所有空闲块最终一致性
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};




