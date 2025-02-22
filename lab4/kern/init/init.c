#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <console.h>
#include <kdebug.h>
#include <picirq.h>
#include <trap.h>
#include <clock.h>
#include <intr.h>
#include <pmm.h>
#include <vmm.h>
#include <ide.h>
#include <swap.h>
#include <proc.h>
#include <kmonitor.h>

int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    cons_init();                // init the console

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);

    print_kerninfo();

    // grade_backtrace();

    pmm_init();                 // init physical memory management

    pic_init();                 // init interrupt controller
    idt_init();                 // init interrupt descriptor table

    vmm_init();                 // init virtual memory management
    proc_init();                // init process table：这个函数完成了 idleproc 内核线程和 initproc 内核线程的创建或复制工作，
    //在 uCore 执行完 proc_init 函数后，就创建好了两个内核线程：idleproc 和 initproc
    ide_init();                 // init ide devices
    swap_init();                // init swap

    clock_init();               // init clock interrupt
    intr_enable();              // enable irq interrupt
    //等到执行到 init 函数的最后一个函数 cpu_idle 之前，uCore 的所有初始化工作就结束了，
    //idleproc 将通过执行 cpu_idle 函数让出 CPU，给其它内核线程执行
    cpu_idle();                 // run idle process
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
}

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void
grade_backtrace(void) {
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
}

static void
lab1_print_cur_status(void) {
    static int round = 0;
    round ++;
}

