#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}
/**
 uCore 在实验四中只实现了一个最简单的 FIFO 调度器，其核心就是 schedule 函数。
 1．设置当前内核线程 current->need_resched 为 0；
 2．在 proc_list 队列中查找下一个处于“就绪”态的线程或
进程 next；
 3．找到这样的进程后，就调用 proc_run 函数，保存当前进程 current 的执行现场（进程上下文），
恢复新进程的执行现场，完成进程切换。
至此，新的进程 next 就开始执行了。由于在 proc10 中只有两个内核线程，且 idleproc 要让出 CPU 给 initproc
执行，我们可以看到 schedule 函数通过查找 proc_list 进程队列，只能找到一个处于“就绪”态的 initproc 内核
线程。并通过 proc_run 和进一步的 switch_to 函数完成两个执行现场的切换，具体流程如下：
1. 将当前运行的进程设置为要切换过去的进程
2. 将页表换成新进程的页表
3. 使用 switch_to 切换到新进程
 */
void
schedule(void) {  //寻找下一个可运行的进程并切换到它
    bool intr_flag;
    list_entry_t *le, *last;//last 指向当前进程在链表中的位置,le 是一个遍历进程链表的指针。它从 last 开始，逐个节点遍历链表中的进程
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);//关中断
    {
        current->need_resched = 0;//当前进程不再需要调度
        last = (current == idleproc) ? &proc_list : &(current->list_link);//如果当前进程是idleproc，查找链表为proc_list(进程链表)
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {//找到一个可以运行的进程，跳出循环
                    break;
                }
            }
        } while (le != last);//终止条件：链表全部遍历一遍:遍历链表直到回到 last，即确保整个链表都被检查了一遍。
        if (next == NULL || next->state != PROC_RUNNABLE) {//如果没找到可以运行的进程，下一个进程还是idleproc
            next = idleproc;
        }
        next->runs ++;//运行计数增加
        if (next != current) {//如果找到的下一个进程和当前进程不同，运行它
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);//开中断
}

