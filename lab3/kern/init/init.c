#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <console.h>
#include <kdebug.h>
#include <trap.h>
#include <clock.h>
#include <intr.h>
#include <pmm.h>
#include <vmm.h>
#include <ide.h>
#include <swap.h>
#include <kmonitor.h>

int kern_init(void) __attribute__((noreturn));  //内核的初始化函数，该函数永不返回
void grade_backtrace(void);


int
kern_init(void) {
    extern char edata[], end[];  //edata 和 end 分别是内核数据段的起始和结束地址
    memset(edata, 0, end - edata);  //memset 将内核的数据段清零，确保所有静态和全局变量初始化为 0

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);

    print_kerninfo();

    // grade_backtrace();

    pmm_init();                 // init physical memory management，完成物理内存的管理初始化

    idt_init();                 // init interrupt descriptor table

    vmm_init();                 // init virtual memory management，进行虚拟内存管理机制的初始化：主要是建立虚拟地址到物理地址的映射关系，为虚拟内存提供管理支持。

    ide_init();                 // init ide devices：其实这个函数啥也没做。对用于页面换入和换出的硬盘（通常称为 swap 硬盘）的初始化工作（ucore 准备好了对硬盘数据块的读写操作）

    swap_init();                // init swap:用于初始化页面置换算法
    
    
    clock_init();               // init clock interrupt
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (sint_t)&arg0, arg1, (sint_t)&arg1);
}

void __attribute__((noinline))
grade_backtrace0(int arg0, sint_t arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void
grade_backtrace(void) {
    grade_backtrace0(0, (sint_t)kern_init, 0xffff0000);
}

static void
lab1_print_cur_status(void) {   //状态轮询函数
    static int round = 0;
    round ++;
}


