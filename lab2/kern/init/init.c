#include <clock.h>
#include <console.h>
#include <defs.h>
#include <intr.h>
#include <kdebug.h>
#include <kmonitor.h>
#include <pmm.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>

/*
    kern_init 是内核初始化函数，并使用了 __attribute__((noreturn))，表示该函数不会返回控制权到调用者。
    因此，它作为操作系统启动的起点，一旦开始执行，系统的控制权将一直维持在该函数中。
*/
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);


int kern_init(void) {
    /*
        edata：指向数据段结束的位置，数据段包含所有已初始化的全局和静态变量。
        end：指向 BSS 段结束的位置。BSS 段存放的是所有未初始化的全局和静态变量，在程序启动时，这些变量会被初始化为 0。
    */
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    cons_init();  // init the console
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);

    print_kerninfo();

    // grade_backtrace();初始化 IDT（中断描述符表），该表用于管理各种中断请求和异常处理。
    idt_init();  // init interrupt descriptor table
    //初始化物理内存管理，设置物理内存分配、管理策略。
    pmm_init();  // init physical memory management

    idt_init();  // init interrupt descriptor table

    clock_init();   // init clock interrupt
    intr_enable();  // enable irq interrupt



    /* do nothing */
    while (1)
        ;
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline)) grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (uintptr_t)&arg0, arg1, (uintptr_t)&arg1);
}

void __attribute__((noinline)) grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void grade_backtrace(void) { grade_backtrace0(0, (uintptr_t)kern_init, 0xffff0000); }

static void lab1_print_cur_status(void) {
    static int round = 0;
    round++;
}

