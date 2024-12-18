#ifndef __KERN_MM_SWAP_H__
#define __KERN_MM_SWAP_H__

#include <defs.h>
#include <memlayout.h>
#include <pmm.h>
#include <vmm.h>
//该文件定义了页面置换机制的核心结构和接口
/* *
 * swap_entry_t
 * --------------------------------------------
 * |         offset        |   reserved   | 0 |
 * --------------------------------------------
 *           24 bits            7 bits    1 bit
 * */
//swap_entry_t 是一个 32 位的数据结构，表示页面置换条目。包含 24 位的偏移量、7 位保留位和1位标志位，用于表示是否有效。
#define MAX_SWAP_OFFSET_LIMIT                   (1 << 24)
//表示交换区最多可以存储 16,777,216 个页面。
extern size_t max_swap_offset;

/* *
 * swap_offset - takes a swap_entry (saved in pte), and returns
 * the corresponding offset in swap mem_map.
 * */
#define swap_offset(entry) ({                                       \
               size_t __offset = (entry >> 8);                        \
               if (!(__offset > 0 && __offset < max_swap_offset)) {    \
                    panic("invalid swap_entry_t = %08x.\n", entry);    \
               }                                                    \
               __offset;                                            \
          })

struct swap_manager
{
     const char *name;
     /* Global initialization for the swap manager */
      /* 页面置换算法的函数接口 */
     int (*init)            (void); // 全局初始化
     /* Initialize the priv data inside mm_struct */
     int (*init_mm)         (struct mm_struct *mm);// 初始化 mm_struct 的私有数据
     /* Called when tick interrupt occured */
     int (*tick_event)      (struct mm_struct *mm);
     /* Called when map a swappable page into the mm_struct */
     int (*map_swappable)   (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);  // 将页面标记为可交换
     /* When a page is marked as shared, this routine is called to
      * delete the addr entry from the swap manager */
     int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);  // 将页面标记为不可交换
     /* Try to swap out a page, return then victim */
     int (*swap_out_victim) (struct mm_struct *mm, struct Page **ptr_page, int in_tick); // 选择被淘汰的页面
     /* check the page relpacement algorithm */
     int (*check_swap)(void);     // 检查置换算法是否正确
};

extern volatile int swap_init_ok;  //标志页面置换机制是否已初始化,该变量可能随时被其他线程或硬件修改，因此需要每次从内存读取最新值
int swap_init(void);
int swap_init_mm(struct mm_struct *mm);
int swap_tick_event(struct mm_struct *mm);
int swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
int swap_set_unswappable(struct mm_struct *mm, uintptr_t addr);
int swap_out(struct mm_struct *mm, int n, int in_tick);
int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result);

//#define MEMBER_OFFSET(m,t) ((int)(&((t *)0)->m))
//#define FROM_MEMBER(m,t,a) ((t *)((char *)(a) - MEMBER_OFFSET(m,t)))

#endif
