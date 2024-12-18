#include <riscv.h>

    .macro SAVE_ALL #SAVE_ALL 宏的作用是保存当前进程（或者线程）上下文中的所有寄存器值，以便在以后恢复
    .align 2

    csrw sscratch, sp

    addi sp, sp, -36 * REGBYTES
    # save gprs
    STORE  x1,1*REGBYTES(sp)
    STORE  x3,3*REGBYTES(sp)
    STORE  x4,4*REGBYTES(sp)
    STORE  x5,5*REGBYTES(sp)
    STORE  x6,6*REGBYTES(sp)
    STORE  x7,7*REGBYTES(sp)
    STORE  x8,8*REGBYTES(sp)
    STORE  x9,9*REGBYTES(sp)
    STORE  x10,10*REGBYTES(sp)
    STORE  x11,11*REGBYTES(sp)
    STORE  x12,12*REGBYTES(sp)
    STORE  x13,13*REGBYTES(sp)
    STORE  x14,14*REGBYTES(sp)
    STORE  x15,15*REGBYTES(sp)
    STORE  x16,16*REGBYTES(sp)
    STORE  x17,17*REGBYTES(sp)
    STORE  x18,18*REGBYTES(sp)
    STORE  x19,19*REGBYTES(sp)
    STORE  x20,20*REGBYTES(sp)
    STORE  x21,21*REGBYTES(sp)
    STORE  x22,22*REGBYTES(sp)
    STORE  x23,23*REGBYTES(sp)
    STORE  x24,24*REGBYTES(sp)
    STORE  x25,25*REGBYTES(sp)
    STORE  x26,26*REGBYTES(sp)
    STORE  x27,27*REGBYTES(sp)
    STORE  x28,28*REGBYTES(sp)
    STORE  x29,29*REGBYTES(sp)
    STORE  x30,30*REGBYTES(sp)
    STORE  x31,31*REGBYTES(sp)

    # get sr, epc, badvaddr, cause
    csrr s0, sscratch
    csrr s1, sstatus
    csrr s2, sepc
    csrr s3, 0x143
    csrr s4, scause

    STORE s0, 2*REGBYTES(sp)
    STORE s1, 32*REGBYTES(sp)
    STORE s2, 33*REGBYTES(sp)
    STORE s3, 34*REGBYTES(sp)
    STORE s4, 35*REGBYTES(sp)
    .endm

    .macro RESTORE_ALL #RESTORE_ALL 宏的作用是恢复保存的上下文，确保新进程或线程从保存的状态继续执行。

    LOAD s1, 32*REGBYTES(sp)
    LOAD s2, 33*REGBYTES(sp)

    csrw sstatus, s1
    csrw sepc, s2

    // restore x registers
    LOAD  x1,1*REGBYTES(sp)
    LOAD  x3,3*REGBYTES(sp)
    LOAD  x4,4*REGBYTES(sp)
    LOAD  x5,5*REGBYTES(sp)
    LOAD  x6,6*REGBYTES(sp)
    LOAD  x7,7*REGBYTES(sp)
    LOAD  x8,8*REGBYTES(sp)
    LOAD  x9,9*REGBYTES(sp)
    LOAD  x10,10*REGBYTES(sp)
    LOAD  x11,11*REGBYTES(sp)
    LOAD  x12,12*REGBYTES(sp)
    LOAD  x13,13*REGBYTES(sp)
    LOAD  x14,14*REGBYTES(sp)
    LOAD  x15,15*REGBYTES(sp)
    LOAD  x16,16*REGBYTES(sp)
    LOAD  x17,17*REGBYTES(sp)
    LOAD  x18,18*REGBYTES(sp)
    LOAD  x19,19*REGBYTES(sp)
    LOAD  x20,20*REGBYTES(sp)
    LOAD  x21,21*REGBYTES(sp)
    LOAD  x22,22*REGBYTES(sp)
    LOAD  x23,23*REGBYTES(sp)
    LOAD  x24,24*REGBYTES(sp)
    LOAD  x25,25*REGBYTES(sp)
    LOAD  x26,26*REGBYTES(sp)
    LOAD  x27,27*REGBYTES(sp)
    LOAD  x28,28*REGBYTES(sp)
    LOAD  x29,29*REGBYTES(sp)
    LOAD  x30,30*REGBYTES(sp)
    LOAD  x31,31*REGBYTES(sp)
    # restore sp last
    LOAD  x2,2*REGBYTES(sp)
    .endm

#__alltraps 和 __trapret这两个函数处理了异常发生时的堆栈保存和恢复过程。


    .globl __alltraps
__alltraps:
    SAVE_ALL

    move  a0, sp
    jal trap # 将当前堆栈指针传递给 trap 函数
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    # go back from supervisor call
    sret  # 从异常处理返回，恢复到中断前的状态
 
#a0 的作用：a0 作为参数传递寄存器，专门用来传递函数的参数。在内核线程的启动过程中，它用来传递新进程的参数。
#switch_to 中的 a0 和 a1：在 switch_to 函数中，a0 和 a1 分别指向当前进程和目标进程的上下文结构。上下文切换是通过保存当前进程的上下文、恢复目标进程的上下文来实现的，a0 和 a1 作为参数传递这些结构。
#s1 到 a0 的转换：在 kernel_thread_entry 中，将 s1（保存了函数参数）中的值传递到 a0，确保新进程能够使用正确的参数执行。
#一旦进程上下文切换完成，控制流会跳到 forkret 函数
#forkret 会确保堆栈指向正确的地址，即为新进程准备的中断帧（trapframe）。它会将堆栈指针设置为 a0，这个 a0 参数传递的值即为新进程的中断帧地址。
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
    j __trapret
