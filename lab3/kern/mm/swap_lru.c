#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

//lru区别lru算法：lru先替换的是”最早进入内存的页面“，该页面可能最近被访问过，也可能最近没有被访问
//而lru算法先替换的是”最近最少被访问的页面“，这个页面可能很早就进入了内存，也可能才进入一段时间
//前者维护的是，替换进内存的页面队列；后者则维护的是，访问页面的链表
//在实现过程中，参照了swap_lru.c

//思路：创建一个双向链表，维护页面访问顺序。最近被访问的页面被放置到链表的前面。每次替换时，选择链表最后端的节点替换

//疑难点：页面何时访问？页面访问相关的函数接口是哪一个？在其他几个check_swap操作中，以写页面为主。
//也许可以从多次写页面中，模拟访问页面的过程
//get_pte->create page

list_entry_t lru_pra_list_head;

static int
_lru_init_mm(struct mm_struct *mm)
{     
     list_init(&lru_pra_list_head);
     mm->sm_priv = &lru_pra_list_head;
     cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
     return 0;
}

static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation

    //(1)把最近抵达的页面放在链表的头部
    //抵达顺序：1->2->3
    //head<->entry3<->entry2<->entry1<->head
    //cprintf("lru_map_swappable is called!The page is %x\n",page->pra_vaddr );
    list_add(head, entry);
    return 0;
    
}


static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);
    list_entry_t* entry = list_prev(head);//选择链表尾部的节点，即最近没有访问的节点
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    //cprintf("lru_swap_out_victim is called!The page vaddr is  0x%x\n",(*ptr_page)->pra_vaddr);
    return 0;
}
//增加打印链表的函数
void print_list()
{
    list_entry_t *head = &lru_pra_list_head, *le = head;
    cprintf("===list is(vaddr):");
    while ((le = list_next(le)) != head)
    {
        struct Page* page = le2page(le, pra_page_link);
        cprintf(" %x(0x%x) ", *(unsigned char *)(page->pra_vaddr),page->pra_vaddr);
    }
    cprintf("===\n");
}

void recent_visit(uintptr_t addr)//把对应地址的page插到链表首部
{
    list_entry_t *head = &lru_pra_list_head, *le = head;
    while ((le = list_next(le)) != head)
    {
        struct Page* page = le2page(le, pra_page_link);
        if(page->pra_vaddr==addr)
        {
            list_entry_t *tmp=&page->pra_page_link;
            //inc_viscount(page);
            //cprintf("change list: 0x%x---",addr);
            list_del(le);//从原来位置删除
            //print_list();
            list_add(head,tmp);//放在首部
        }
    }
    print_list();

}

//需要修改与完善
static int
_lru_check_swap(void) {
    print_list();
    int t=4;
    cprintf("read page in 0x1000:%x\n",*(unsigned char *)0x1000);
    if(pgfault_num==t){recent_visit(0x1000);}
    //print_list();
    cprintf("read page in 0x2000:%x\n",*(unsigned char *)0x2000);
    if(pgfault_num==t){recent_visit(0x2000);}
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    if(pgfault_num==t){recent_visit(0x3000);}
    else{print_list();}
    // 在这个赋值之后，0x4000页面被换出去
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    t++;
    if(pgfault_num==t){recent_visit(0x5000);}
    else{print_list();}
    cprintf("read page in 0x2000:%x\n",*(unsigned char *)0x2000);
    if(pgfault_num==t){recent_visit(0x2000);}
    else{print_list();}
    //0x1000被替换出去
    cprintf("read page in 0x4000:%x\n",*(unsigned char *)0x4000);
    assert(pgfault_num==6);
    t++;
    print_list();
    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable()
{
    return 0;
}

static int
_lru_tick_event()
{ return 0; }


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};