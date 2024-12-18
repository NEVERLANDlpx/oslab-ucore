## 请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？

### 上下文（context）
进程上下文使用结构体struct context保存，其中包含了ra，sp，s0~s11共14个寄存器。在函数switch_to()中(switch.S文件)，将当前进程的上下文保存到该结构体中，并将新进程的上下文从该结构体中恢复到CPU寄存器。

### 中断帧（trapframe）
在kernel_thread()函数中，tf记录了当前新线程需要执行的main函数以及相关参数，以及status和epc寄存器，并最终调用了do_fork()。do_fork()函数调用了copy_thread()函数，将新线程的上下文中的ra寄存器设置为了forkrets()函数的地址，这样在switch_to()函数执行后，由于最后一条指令为ret，所以ra寄存器内的地址会被设置为下一个要执行的指令地址，控制权会转移到forkrets()函数。
 
 而在forkrets()函数中，tf被记录到栈顶，接着调用__trapret()函数，所有新内核线程的寄存器在__trapret()函数中借助tf恢复，包括epc寄存器。

 当 __trapret 中执行 sret 时，CPU 将根据之前恢复的状态（也就是 sepc）跳转到所需的地址，正好我们之前已经在kernel_thread()函数将epc设置为了kernel_thread_entry（）函数的地址，从而开始执行init_main()函数。

 简而言之，tf保证了新的内核线程可以利用设定好的执行程序和参数正常运行。