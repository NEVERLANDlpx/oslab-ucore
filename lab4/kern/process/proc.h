#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>


// process's state in his life cycle
/**
state：进程所处的状态。uCore 中进程状态有四种：分别是 PROC_UNINIT、PROC_SLEEPING、PROC_RUNNABLE、PROC_ZOMBIE。
PROC_ZOMBIE：进程已经结束，但其父进程还没有回收它的资源（例如等待其退出状态）。
PROC_UNINIT：进程尚未初始化，处于无效状态。
PROC_SLEEPING：进程正在等待某个事件或资源（例如等待 I/O 操作完成）。
PROC_RUNNABLE：进程已经准备好运行，等待调度。此时，进程处于就绪状态，CPU 一旦空闲就可以调度该进程来执行。
 */
enum proc_state {
    PROC_UNINIT = 0,  // uninitialized
    PROC_SLEEPING,    // sleeping
    PROC_RUNNABLE,    // runnable(maybe running)
    PROC_ZOMBIE,      // almost dead, and wait parent proc to reclaim his resource
};
/**
    进程上下文保存了与进程执行相关的所有寄存器的值
    编译器会自动帮助我们生成保存和恢复调用者保存寄存器的代码，在实际的进程切换过程中我们只需要保存被调用者保存寄存器。
    uCore 操作系统在管理进程时，使用了进程控制块（proc_struct）来保存每个进程的状态信息。操作系统需要维护一个关于所有进程的全局数据结构，用于进程的调度、切换以及资源管理。以下是几个关键的数据结构：
    current：指向当前正在运行的进程控制块（PCB）。这是一个指针，通常是只读的，只有在进程切换时，才会被修改。current 是系统调度和中断管理的核心。
    initproc：指向系统启动时的内核线程（或第一个用户进程）。在 uCore 中，initproc 用来指向系统初始化时创建的内核线程。在以后，initproc 可能指向第一个用户态进程。
    hash_list[HASH_LIST_SIZE]：用于存储所有进程控制块的哈希表。进程控制块通过 hash_link 链接到该哈希表中，哈希表的大小由 HASH_LIST_SIZE 决定。哈希表的主要作用是通过进程的 PID（进程标识符）快速查找进程控制块。
    proc_list：一个双向链表，保存所有进程控制块。进程控制块通过 list_link 链接到这个链表中。该链表的主要作用是维护所有进程的顺序列表，并且能够方便地进行进程的遍历和调度。
 */
struct context {
    uintptr_t ra;
    uintptr_t sp;
    uintptr_t s0;
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};

#define PROC_NAME_LEN               15
#define MAX_PROCESS                 4096
#define MAX_PID                     (MAX_PROCESS * 2)

extern list_entry_t proc_list;
/** proc_struct：进程控制块（PCB）
    state：描述进程的当前状态。PROC_UNINIT表示未初始化状态，PROC_SLEEPING表示进程处于休眠状态，PROC_RUNNABLE表示进程可被调度运行，PROC_ZOMBIE表示进程已终止，等待被回收。
    pid：进程的唯一标识符。在操作系统中，每个进程都有一个独立的PID，用于在系统中区分不同的进程。
    runs：记录进程被调度执行的次数。这个字段可以用于进程的调度策略优化，例如优先调度运行次数少的进程。
    kstack：指向进程的内核栈。在操作系统中，每个进程都有自己的内核栈，进程在内核模式下的函数调用、数据存储等都在这个栈上进行。
    need_resched：指示当前进程是否需要被重新调度。若设置为 1，表示当前进程需要重新调度，否则表示进程可以继续运行。
    parent：指向该进程的父进程的指针。每个进程通常都有一个父进程，父进程可以通过进程控制块对子进程进行管理。
    mm：指向该进程的内存管理结构体（mm_struct）。它包含了进程的虚拟内存信息，包括内存映射、页面表等。每个进程都有自己的内存空间和页表，以保证进程间的内存隔离。
    context：保存了进程切换所需的寄存器状态。每次进程切换时，操作系统会保存当前进程的上下文，然后恢复新进程的上下文。context结构体包含了保存和恢复进程状态的必要信息（如sp、ra寄存器等）。
    tf：进程的中断帧，用于保存进程的中断状态。在系统调用或中断发生时，进程的执行状态会保存在中断帧中。当进程从内核返回用户态时，需要使用该中断帧来恢复进程的状态。
    cr3：这是一个特殊的寄存器，在 x86 架构中，cr3保存的是当前进程的页表基地址。它指向进程的页表目录，是虚拟地址到物理地址转换的关键。
    flags：存储进程的一些标志位，控制进程的行为或状态。例如，可能有一些标志位用于指示进程是否正在进行系统调用，是否是内核线程等。
    name：存储进程的名称，便于调试和管理。
    list_link：该字段用于将进程插入到系统的进程双向链表中。链表保存了所有进程的控制块，调度器通过遍历链表来选择下一个执行的进程。
    hash_link：用于将进程插入到哈希表中。哈希表通过进程ID（pid）来加速查找进程。
 */
//里面保存了进程的父进程的指针。在内核中，只有内核创建的 idle 进程没有父进程，其他进程都有父进程。进程的父子关系组成了一棵进程树，这种父子关系有利于维护父进程对于子进程的一些特殊操作。

struct proc_struct {
    enum proc_state state;                      // Process state：
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    uintptr_t kstack;                           // Process kernel stack
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?进程通过设置 need_resched 来主动让出 CPU
    struct proc_struct *parent;                 // the parent process
    struct mm_struct *mm;                       // Process's memory management field
    struct context context;                     // Switch here to run process
    struct trapframe *tf;                       // Trap frame for current interrupt
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
};

#define le2proc(le, member)         \
    to_struct((le), struct proc_struct, member)

extern struct proc_struct *idleproc, *initproc, *current;

void proc_init(void);
void proc_run(struct proc_struct *proc);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
void cpu_idle(void) __attribute__((noreturn));

struct proc_struct *find_proc(int pid);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_exit(int error_code);

#endif /* !__KERN_PROCESS_PROC_H__ */

