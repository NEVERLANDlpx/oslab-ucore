#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc, 
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:
                                            
  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+ 
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  + 
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep 
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : get the process's pid

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))
/**
    proc_list：保存所有进程的链表。
    hash_list：基于进程PID的哈希表，用于加速按PID查找进程。
    idleproc、initproc、current：分别是空闲进程、初始化进程和当前运行的进程指针。
    nr_process：记录当前系统中的进程数量。
*/
// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL; //本实验中，指向一个内核线程。
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);
/** 
uCore OS 的 alloc_proc 函数就是通过分配 PCB 来创建内核线程。
首先，考虑最简单的内核线程，它通常只是内核中的一小段代码或者函数，没有自己的“专属”空间。
这是由于在 uCore OS 启动后，已经对整个内核内存空间进行了管理，通过设置页表建立了内核虚拟空间（即boot_cr3 指向的二级页表描述的空间）。
所以 uCore OS 内核中的所有线程都不需要再建立各自的页表，只需共享这个内核虚拟空间就可以访问整个物理内存了。
从这个角度看，内核线程被 uCore OS 内核这个大“内核进程”所管理。
*/
// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 2211820
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT; // 进程初始化状态为PROC_UNINIT
    proc->pid = -1;
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context)); // context全部置零
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
    proc->flags = 0;
    memset(proc->name, 0, PROC_NAME_LEN + 1); // 进程名全部置零

    }
    return proc;
}
/*set_proc_name 和 get_proc_name - 设置与获取进程名称 */
// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}
/**
 get_pid 函数的作用是为新创建的进程分配一个唯一的进程标识符（PID）。
 一起帮助找到整个链表中第一个可用的 PID 区间
 last_pid：表示下一个可能分配的 PID 值，候选的 PID。每次调用 get_pid 时递增，达到最大值后回绕到 1。
 next_safe：记录当前分配过程中最大的已分配 PID 的下一个安全值。如果 last_pid 超过了 next_safe，就表示需要检查所有 PID。
 */
// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);//静态断言，保证最大 PID 数量大于最大进程数。
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID; //表示下一个安全的 PID 值。它记录下一个可用的 PID 值。记录上次使用的 PID，初始时设为 MAX_PID。
    //每次调用 get_pid 时，last_pid 递增。如果 last_pid 超过了 MAX_PID，则从 1 开始循环，避免 PID 超过上限
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    /*
    如果 last_pid 大于或等于 next_safe，意味着 PID 在分配过程中可能会重复。
    进入 repeat 循环，遍历 proc_list 中的进程，检查每个进程的 PID：
    如果进程的 PID 等于当前的 last_pid，则说明该 PID 已经被占用，需要增加 last_pid 并重新检查。
    如果一个进程的 PID 大于 last_pid 且小于 next_safe，则更新 next_safe，保证我们下次分配的 PID 不会重复。    
    */
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) { //如果遍历到链表的头部，则停止遍历。
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) { //对于每一个进程节点，检查该进程的 PID 是否和 last_pid 相等。如果相等，说明 last_pid 被占用了。
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {  //如果 last_pid 被占用，就把 last_pid 增加 1（++last_pid），并且检查是否超出了最大 PID 的限制。如果超出了，就重置为 1。
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }  //前进程的 PID 大于 last_pid 且小于 next_safe，就更新 next_safe，确保下次分配的 PID 不会小于当前已分配的最大 PID
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;  // 这个函数最终返回一个唯一且未被占用的 PID。
}
/** 
proc_run - 将进程切换到 CPU 上运行
proc_run 函数的作用是将指定的进程（proc）调度到 CPU 上执行。它需要保存当前进程的上下文（CPU 状态），然后加载新进程的上下文，实现进程切换。
*/
// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {  //如果目标进程 proc 不是当前进程 current，需要执行进程切换。
        // LAB4:EXERCISE3 2212108
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
       bool intr_flag;
       struct proc_struct *prev=current,*next=proc;
       local_intr_save(intr_flag);//关中断
       {
        current=proc;//切换进程
        lcr3(next->cr3);//修改cr3寄存器
        switch_to(&(prev->context),&(next->context));//上下文切换
       }
       local_intr_restore(intr_flag);
    }
}

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
/** 新线程/进程的第一个内核入口点
 * forkret 是在新进程或线程启动时，作为内核中的第一个执行函数。
 * 当 fork 系统调用创建新进程后，调度器会切换到新进程并执行 forkret 函数。该函数的执行意味着进程的初始设置已经完成，进程将开始其后续的执行。
 * forkrets(current->tf)：调用 forkrets 函数，并传递当前进程的 tf（通常是指 trapframe，即进程的上下文，包括 CPU 寄存器的状态）。forkrets 负责完成进程初始化后的剩余工作。forkrets 通常会包括一些进程初始化的步骤，如恢复栈帧，设置返回地址等。
 * 在执行 switch_to 完成上下文切换后，forkret 会作为新进程的第一个内核入口点执行。
*/
static void
forkret(void) {
    forkrets(current->tf);
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}
/** find_proc
 * 根据进程的 PID，从进程哈希表中查找相应的进程结构体 proc_struct
 */
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
/**
 * kernel_thread 的工作主要包括为新线程创建执行上下文（特别是中断帧）并启动新的内核线程
 * fn：线程的入口函数地址。arg：传递给线程的参数。clone_flags：线程创建的标志，用于决定内存是否共享等行为。
 * 函数的工作是为新的内核线程设置执行上下文，并通过 do_fork 创建一个新的进程（即内核线程）
 */
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.gpr.s0 = (uintptr_t)fn;  // s0 保存线程入口函数地址
    tf.gpr.s1 = (uintptr_t)arg;  // s1 保存传递给函数 fn 的线程参数
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE; //读取当前特权状态寄存器。
    //SSTATUS_SPP：设置线程运行在内核模式下。SSTATUS_SPIE：启用中断的保存状态。~SSTATUS_SIE：禁用中断
    //SSTATUS 寄存器控制着当前线程的特权级别和中断状态。我们将 SSTATUS_SPP 设置为 1，使得内核线程在 supervisor（特权）模式下执行。
    //SSTATUS_SPIE 也设置为 1，表示中断是允许的。
    //SSTATUS_SIE 清零，表示禁用该线程的外部中断。
    tf.epc = (uintptr_t)kernel_thread_entry;  //设置程序计数器 (PC)：epc 指定线程的入口函数，这里是 kernel_thread_entry，它是内核线程的启动函数。
    //do_fork 是用于创建新进程或线程的函数，kernel_thread 函数通过它来启动一个新的内核线程。
    //clone_flags | CLONE_VM 表示新线程与当前线程共享虚拟内存空间，意味着这是一个内核线程而不是用户进程
    return do_fork(clone_flags | CLONE_VM, 0, &tf); //调用 do_fork 创建线程：
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
/** setup_kstack：为进程分配内核栈
 * proc：指向需要分配内核栈的进程结构体
 * 调用 alloc_pages 为进程分配 KSTACKPAGE 大小的内存作为内核栈。
 * 使用 page2kva 将分配的物理页地址转换为内核虚拟地址。
 * 成功后，将地址存储到 proc->kstack 中。
 * 如果分配失败，返回 -E_NO_MEM。
 */
static int
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
/**
 * put_kstack - 释放进程的内核栈
 * 使用 kva2page 将虚拟地址转换为物理页。
 * 调用 free_pages 释放分配的内核栈内存。
 */
static void
put_kstack(struct proc_struct *proc) {
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
/**
 *  copy_mm - 复制或共享内存管理结构
 * clone_flags：决定是否共享父进程的内存管理。proc：新创建的进程结构体。
 * 这里的实现是占位实现 (do nothing)。
    实际中，clone_flags & CLONE_VM 决定是否共享内存管理结构：
    如果设置了 CLONE_VM，父子进程共享内存管理。
    否则，子进程会复制父进程的内存管理结构。
    copy_mm 函数目前只是把 current->mm 设置为 NULL，这是由于目前在实验四中只能创建内核线程
 */
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL);
    /* do nothing in this project */
    return 0;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
/** copy_thread - 设置新线程的上下文和内核栈
 * proc：新线程的进程结构体。esp：用户栈指针（如果为 0，则使用默认值）。tf：父线程的 trapframe。
   线程设置 trapframe：
    将 trapframe 放置在内核栈的顶部：
    proc->kstack + KSTACKSIZE 是栈的顶端。
    - sizeof(struct trapframe) 为 trapframe 留出空间。
    复制父进程的 trapframe 到新进程的内核栈上。 
    a0 和 a1 是 RISC-V 架构中通用寄存器，它们用于传递参数，也就是说 a0 指向原进程，a1 指向目的进程。
    当子进程被创建时，它的 a0 寄存器会被设置为 0，表示该进程是刚刚通过 fork 创建出来的。
    这是为了区分父进程和子进程的返回值，因为父进程的 fork 调用会返回子进程的 PID，而子进程的 fork 调用会返回 0。

    在这里我们首先在上面分配的内核栈上分配出一片空间来保存 trapframe。然后，我们将 trapframe
   中的 a0 寄存器（返回值）设置为 0，说明这个进程是一个子进程。之后我们将上下文中的 ra 设置为了
   forkret 函数的入口，并且把 trapframe 放在上下文的栈顶。
 */
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe)); 
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    proc->tf->gpr.a0 = 0; //将通用寄存器 a0 设置为 0，表示子进程刚刚创建。
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;  //如果 esp 为 0，默认使用 trapframe 的地址作为栈指针。否则，使用提供的 esp。
    //ra 设置为 forkret，表示新线程的返回地址为 forkret 函数。sp 设置为 trapframe 的地址，作为栈指针。

    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
/*
    do_fork 是内核中负责创建新进程（或线程）的关键函数。它会分配资源、复制父进程的状态、并初始化新进程的上下文。
    clone_flags：进程克隆标志，决定新进程的行为，例如是否共享内存等。
    stack：父进程的用户栈指针。如果为 0，则表示要创建一个内核线程。
    tf：父进程的 trapframe，它会被复制到子进程的 proc->tf，即新进程的上下文信息。
*/
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) { //nr_process 表示当前已创建的进程数，MAX_PROCESS 是最大进程数。如果当前进程数已达到上限，直接返回错误。
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:2213109 刘沛鑫
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    if ((proc = alloc_proc()) == NULL) 
    {
        goto fork_out; //分配 proc_struct：alloc_proc() 用于分配一个新的 proc_struct，表示一个新进程。如果分配失败，跳转到 fork_out，返回错误。
    }
    proc->parent = current;  // 设置新进程的父进程为当前进程，即子进程会记录它的父进程。
    //    2. call setup_kstack to allocate a kernel stack for child process
    if (setup_kstack(proc) == -E_NO_MEM) //分配内核栈：setup_kstack 为子进程分配内核栈。如果分配失败，则跳转到 bad_fork_cleanup_proc 进行清理。
    {  
        goto bad_fork_cleanup_proc;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag
    if(copy_mm(clone_flags, proc) != 0) //复制或共享内存管理：copy_mm 函数根据 clone_flags 来决定是复制父进程的内存管理结构还是共享。若操作失败，跳转到 bad_fork_cleanup_kstack。
    {  
        goto bad_fork_cleanup_kstack;
    }
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc, stack, tf); //copy_thread 设置新进程的 trapframe 和上下文，确保子进程在启动时能正确地执行。
    //    5. insert proc_struct into hash_list && proc_list ：将进程插入哈希表和进程列表
    bool interrupt_flag;  // 判断是否禁用中断
    /*
    local_intr_save 和 local_intr_restore 正是用于控制中断状态的操作宏，它们确保了在关键代码区间内不会被中断打断，从而避免竞争条件。
    local_intr_save 的作用是保存当前的中断状态并禁用本地中断。
    在禁用中断时，当前CPU上的中断不会触发，这样可以保证接下来的操作不会被其他中断打断。
    它将当前中断状态保存在 interrupt_flag 变量中，以便后续恢复。
    */
    local_intr_save(interrupt_flag);  //使用 local_intr_save 和 local_intr_restore 保护这一过程，防止中断打断对共享资源的修改。
    {  
        proc->pid = get_pid();    // 为新进程分配 PID
        hash_proc(proc);  // 将进程添加到哈希表
        list_add(&proc_list, &proc->list_link); // 将进程添加到进程列表
        nr_process++;  // 更新进程数
    }
    local_intr_restore(interrupt_flag);   
    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc); //调用 wakeup_proc 将子进程的状态设置为可运行 (PROC_RUNNABLE)，意味着它准备好被调度。
    //    7. set ret vaule using child proc's pid
    ret = proc->pid;//返回子进程的 PID，作为 do_fork 的返回值。
    
/*
fork_out:这是 do_fork 函数的出口。如果进程创建成功，ret 会被设置为新进程的 pid；如果出错，则返回一个错误代码。
*/
fork_out:
    return ret;
/*
这个标签用于处理 setup_kstack 函数失败的情况。在 setup_kstack 函数中，分配了子进程的内核栈。如果栈分配失败（即返回 -E_NO_MEM），那么就需要回收之前已经分配的资源，避免内存泄漏。
put_kstack(proc) 调用 put_kstack 函数来释放已经为子进程分配的内核栈。put_kstack 的作用是通过 free_pages 函数来释放内核栈的内存。
*/
bad_fork_cleanup_kstack:
    put_kstack(proc);
/*
当 alloc_proc 函数分配 proc 结构体失败时，或者在 setup_kstack、copy_mm、copy_thread 等函数执行失败时，都会跳转到这个标签。
kfree(proc) 用来释放为 proc 分配的内存。proc 是通过 alloc_proc 分配的进程控制块（PCB），如果子进程的创建失败，就需要释放这个 proc 结构体所占的内存
*/
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;  //在资源清理完成后，执行 goto fork_out，跳转到函数的结束部分，最终返回错误码。
    /*通过 goto 跳到 fork_out 标签，保证 do_fork 函数最终能够返回一个正确的结果：
    无论是成功创建了子进程并返回其 pid，还是在创建过程中发生了错误，最终都会跳到 fork_out 并返回相应的错误码或子进程 pid
    */
}

// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
/**
第 0 个内核线程主要工作是完成内核中各个子系统的初始化，然后就通过执行 cpu_idle 函数开始过退休生活
了。所以 uCore 接下来还需创建其他进程来完成各种工作，但 idleproc 内核子线程自己不想做，于是就通过
调用 kernel_thread 函数创建了一个内核线程 init_main。在实验四中，这个子内核线程的工作就是输出一些字
符串，然后就返回了（参看 init_main 函数）。但在后续的实验中，init_main 的工作就是创建特定的其他内核
线程或用户进程（实验五涉及）。
 */
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
/** 
进程模块的初始化主要分为两步，首先创建第 0 个内核进程，idle。
这个函数完成了 idleproc 内核线程和 initproc 内核线程的创建或复制工作
idleproc 内核线程的工作就是不停地查询，看是否有其他内核线程可以执行了，如果有，马上让调度器选择那个内核线程执行： cpu_idle 
所以 idleproc 内核线程是在 ucore 操作系统没有其他内核线程可执行的情况下才会被调用。
接着就是调用 kernel_thread 函数来创建
initproc 内核线程。initproc 内核线程的工作就是显示“Hello World”，表明自己存在且能正常工作了。
*/
void
proc_init(void) {
    int i;
    //1.初始化
    list_init(&proc_list);//初始化进程链表 
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i);//对哈希链表中的每一项进行初始化
    }

    if ((idleproc = alloc_proc()) == NULL) {//分配一个进程结构体来作为idleproc
        panic("cannot alloc idleproc.\n");
    }

    // 2.check the proc structure 检查进程结构体的初始化
    int *context_mem = (int*) kmalloc(sizeof(struct context));//分配内存来存储context
    memset(context_mem, 0, sizeof(struct context));//清零context_mem
    //比较idleproc的上下文和清零后的上下文，检查是否已初始化
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);//分配内存以存储进程名称
    memset(proc_name_mem, 0, PROC_NAME_LEN);
     //比较idleproc的名称和清零后的上下文，检查是否已初始化
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
    //检查idleproc的多个属性
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
    ){
        cprintf("alloc_proc() correct!\n");//一切检查通过会打印这个日志

    }
    //3.设置idleporc的进程属性
    idleproc->pid = 0;//进程ID为0
    idleproc->state = PROC_RUNNABLE;//进程状态可运行
    idleproc->kstack = (uintptr_t)bootstack;//内核栈
    idleproc->need_resched = 1;//需要调度
    set_proc_name(idleproc, "idle");//进程名称为"idle"
    nr_process ++;//进程总数+1

    current = idleproc;//设置当前进程为idleproc
    //4.创建第二个内核线程“init_main”,返回值赋给pid
    int pid = kernel_thread(init_main, "Hello world!!", 0);
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);//根据进程id找到initproc
    set_proc_name(initproc, "init");//设置进程名称为"init"
    //验证两个进程存在且PID是否正确
    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
/**
 如果发现当前进程（也就是 idleproc）的 need_resched 置为 1
（在初始化 idleproc 的进程控制块时就置为 1 了），则调用 schedule 函数，完成进程调度和进程切换。
进程调度的过程其实比较简单，就是在进程控制块链表中查找到一个“合适”的内核线程，
所谓“合适”就是指内核线程处于“PROC_RUNNABLE”状态：进程的状态是 PROC_RUNNABLE 时，它表示该进程已经完成了初始化，并且已经做好了执行的准备。

idle 进程是一个特殊的进程，它没有父进程。
idle 进程是操作系统启动时的第一个内核线程，用于保证系统的最小资源使用。当没有其他进程可以运行时，CPU 会空闲运行 idle 进程。

proc_init 函数在初始化 idleproc 中，就把 idleproc->need_resched 置为 1 了，所以会马上调用 schedule函数找其他处于“就绪”态的进程执行。
 */
void
cpu_idle(void) {
    while (1) {
        if (current->need_resched) {
            schedule();
        }
    }
}

