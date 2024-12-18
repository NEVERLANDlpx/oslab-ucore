<<<<<<< HEAD
# lab0.5

## ·lab0相关知识

### 一、OpenSBI

#### 1.bootloader

##### 1）功能：负责boot(开机)和load(把OS加载到内存中)

##### 2）QEMU自带的bootloader:OpenSBI固件

在QEMU开始执行任何指令之前，先把两个文件加载到Qemu物理内存之中：

A.OpenSBI.bin(作为bootloader,被加载到物理内存中以物理地址0x80000000开头的区域上)

B.os.bin(内核镜像，被加载到以物理地址0x80200000开头的区域上)



#### 2.firmware(固件)

##### 1）是什么：是特定的计算机软件，为设备的特定硬件提供低级控制，也可以进一步加载其他软件

##### 2）riscv计算机系统中的固件：OpenSBI

##### 3）OpenSBI的特权级：M（11，Machine）



#### 3.复位地址

##### 1）是什么：CPU上电时，或者按下复位键时，PC被赋的初值

##### 2）灵活性：RISCV的设计允许芯片实现者自主选择复位地址，不同厂商会有差异

##### 3）QEMU-4.1.1：复位地址采用了0x1000,而非0x80000000（所以此处需要配置4.1.1版本）

##### 4）针对上述QEMU模拟的riscv处理器：复位向量地址初始化为0x1000->初始化PC为该复位地址->从此处开始执行复位代码

##### 5）复位代码：主要将将计算机系统的各个组件（包括处理器、内存、设备等）置于初始状态，并启动bootloader（此处复位代码指定加载bootloader的位置为0x80000000,bootloader将加载操作系统内核并启动操作系统执行）。



#### 4.代码的地址相关性（后续探索，先略过）

### 二、可执行文件elf,bin

#### 1.elf vs bin

##### 1)elf文件复杂：elf文件包含多个部分（sections）和段（segments），如代码段、数据段、符号表、重定位信息等。

##### 2)bin文件简单：bin 文件通常是原始二进制文件，不包含任何头信息或结构，只是数据的简单集合。（直接包含程序的机器代码）

##### 3)对比：在加载过程上，BIN 文件更为简单，因为它不包含复杂的头信息和结构，而是简单的二进制数据。相对而言，ELF 文件的加载需要额外的处理和解析。

##### 4）选择使用：如果需要复杂的功能，如动态链接、符号解析和调试信息，使用 ELF 文件。如果应用场景简单，比如嵌入式系统，且只需加载代码，使用 BIN 文件会更合适。



#### 2.OpenSBI的选择

##### 1）得到内存布局合适的elf文件

##### 2）把得到的elf文件转化成bin文件（通过objcopy实现）

##### 3）把得到的bin文件加载到QEMU中运行（由QEMU自带的OpenSBI完成）



#### 3.如何设置elf的内存布局

##### 1）段：程序按功能不同会分成不同段，比如.text(代码段，存放汇编代码)，.rodata(只读数据段，常是程序中的常量)，.data(被初始化的可读写数据，常保存程序中的全局变量)，.bss段（被初始化为00的可读写数据，只需记录段大小及所在位置，不用记录里面的数据）

##### 2）栈（stack）：用来存储程序运行过程中的局部变量，及负责函数调用的各种机制。从高地址向低地址增长。

##### 3）堆（heap)：用来支持程序运行过程中内存的动态分配。

##### 4）内存布局：段各自所放的位置



#### 4.链接脚本

##### 1）链接器作用：把输入文件（.o）链接成输出文件（.elf）

##### 2）链接脚本作用：描述怎样把输入文件的section映射到输出文件的section,同时规定这些section的内存布局

##### 3）默认链接脚本：适合链接一个能在现有操作系统下运行的应用程序，并不适合链接一个操作系统内核

##### 4）代码中使用的链接脚本：tools/kernel.ld

A.指定输出文件的指令集架构为riscv

B.指定函数入口点为kern_entry

C.定义BASE_ADDRESS=0x80200000

D.一整条SECTIONS指令，用于指定输出文件中所有section

-.=BASE_ADDRESS :将当前地址（.）设置成BASE_ADDRESS。从这里开始，所有后续段都基于这个地址布局

-将特定特征的数据段匹配到相应段中



#### 5.入口点

##### 1）在链接脚本中指定的入口点是kern_entry(kern/init/entry.S)

##### 2）关键代码：

kern_entry:

​	la sp,bootstack#将“bootstack”的地址加载到栈指针寄存器“sp”中，即为内核的栈分配起始位置

​	tail kern_init#重用当前函数的栈帧，调用kern_init函数

##### 3）真正的入口点：kern_init(kern/init/init.c)

*调用不了C语言标准库（依赖借助操作系统加载好后的环境），所以库函数是自己写的

-输出"(THU.CST) os is loading ...\n"后，进入死循环

## 练习1：使用GDB验证启动流程

### 一、调试过程

#### 1.分别打开两个终端，进入lab0目录。一个终端执行make debug,一个终端执行make gdb。

##### 1）前者会构建相关目标并启动QEMU,以便进行调试，并使CPU在启动时暂停

##### 2）后者会直接启动GDB,以连接到QEMU的调试服务器，可在此处调试。

#### 2. x/10i $pc,显示即将执行的十条命令

##### 1）观察到程序从0x1000开始，到0x10101处有一个跳转指令jr t0

#### 3.设置两个断点，一个是break *0x8000000,一个是break kern_entry(发现在0x802000000处)

#### 4.逐步si,并在程序运行到0x10101 jr t0之前执行“info registers”，发现t0中存储的地址即为0x8000000，此步跳转到0x8000000。
=======
# lab0.5

## ·lab0相关知识

### 一、OpenSBI

#### 1.bootloader

##### 1）功能：负责boot(开机)和load(把OS加载到内存中)

##### 2）QEMU自带的bootloader:OpenSBI固件

在QEMU开始执行任何指令之前，先把两个文件加载到Qemu物理内存之中：

A.OpenSBI.bin(作为bootloader,被加载到物理内存中以物理地址0x80000000开头的区域上)

B.os.bin(内核镜像，被加载到以物理地址0x80200000开头的区域上)



#### 2.firmware(固件)

##### 1）是什么：是特定的计算机软件，为设备的特定硬件提供低级控制，也可以进一步加载其他软件

##### 2）riscv计算机系统中的固件：OpenSBI

##### 3）OpenSBI的特权级：M（11，Machine）



#### 3.复位地址

##### 1）是什么：CPU上电时，或者按下复位键时，PC被赋的初值

##### 2）灵活性：RISCV的设计允许芯片实现者自主选择复位地址，不同厂商会有差异

##### 3）QEMU-4.1.1：复位地址采用了0x1000,而非0x80000000（所以此处需要配置4.1.1版本）

##### 4）针对上述QEMU模拟的riscv处理器：复位向量地址初始化为0x1000->初始化PC为该复位地址->从此处开始执行复位代码

##### 5）复位代码：主要将将计算机系统的各个组件（包括处理器、内存、设备等）置于初始状态，并启动bootloader（此处复位代码指定加载bootloader的位置为0x80000000,bootloader将加载操作系统内核并启动操作系统执行）。



#### 4.代码的地址相关性（后续探索，先略过）

### 二、可执行文件elf,bin

#### 1.elf vs bin

##### 1)elf文件复杂：elf文件包含多个部分（sections）和段（segments），如代码段、数据段、符号表、重定位信息等。

##### 2)bin文件简单：bin 文件通常是原始二进制文件，不包含任何头信息或结构，只是数据的简单集合。（直接包含程序的机器代码）

##### 3)对比：在加载过程上，BIN 文件更为简单，因为它不包含复杂的头信息和结构，而是简单的二进制数据。相对而言，ELF 文件的加载需要额外的处理和解析。

##### 4）选择使用：如果需要复杂的功能，如动态链接、符号解析和调试信息，使用 ELF 文件。如果应用场景简单，比如嵌入式系统，且只需加载代码，使用 BIN 文件会更合适。



#### 2.OpenSBI的选择

##### 1）得到内存布局合适的elf文件

##### 2）把得到的elf文件转化成bin文件（通过objcopy实现）

##### 3）把得到的bin文件加载到QEMU中运行（由QEMU自带的OpenSBI完成）



#### 3.如何设置elf的内存布局

##### 1）段：程序按功能不同会分成不同段，比如.text(代码段，存放汇编代码)，.rodata(只读数据段，常是程序中的常量)，.data(被初始化的可读写数据，常保存程序中的全局变量)，.bss段（被初始化为00的可读写数据，只需记录段大小及所在位置，不用记录里面的数据）

##### 2）栈（stack）：用来存储程序运行过程中的局部变量，及负责函数调用的各种机制。从高地址向低地址增长。

##### 3）堆（heap)：用来支持程序运行过程中内存的动态分配。

##### 4）内存布局：段各自所放的位置



#### 4.链接脚本

##### 1）链接器作用：把输入文件（.o）链接成输出文件（.elf）

##### 2）链接脚本作用：描述怎样把输入文件的section映射到输出文件的section,同时规定这些section的内存布局

##### 3）默认链接脚本：适合链接一个能在现有操作系统下运行的应用程序，并不适合链接一个操作系统内核

##### 4）代码中使用的链接脚本：tools/kernel.ld

A.指定输出文件的指令集架构为riscv

B.指定函数入口点为kern_entry

C.定义BASE_ADDRESS=0x80200000

D.一整条SECTIONS指令，用于指定输出文件中所有section

-.=BASE_ADDRESS :将当前地址（.）设置成BASE_ADDRESS。从这里开始，所有后续段都基于这个地址布局

-将特定特征的数据段匹配到相应段中



#### 5.入口点

##### 1）在链接脚本中指定的入口点是kern_entry(kern/init/entry.S)

##### 2）关键代码：

kern_entry:

​	la sp,bootstack#将“bootstack”的地址加载到栈指针寄存器“sp”中，即为内核的栈分配起始位置

​	tail kern_init#重用当前函数的栈帧，调用kern_init函数

##### 3）真正的入口点：kern_init(kern/init/init.c)

*调用不了C语言标准库（依赖借助操作系统加载好后的环境），所以库函数是自己写的

-输出"(THU.CST) os is loading ...\n"后，进入死循环

## 练习1：使用GDB验证启动流程

### 一、调试过程

#### 1.分别打开两个终端，进入lab0目录。一个终端执行make debug,一个终端执行make gdb。

##### 1）前者会构建相关目标并启动QEMU,以便进行调试，并使CPU在启动时暂停

##### 2）后者会直接启动GDB,以连接到QEMU的调试服务器，可在此处调试。

#### 2. x/10i $pc,显示即将执行的十条命令

##### 1）观察到程序从0x1000开始，到0x10101处有一个跳转指令jr t0

#### 3.设置两个断点，一个是break *0x8000000,一个是break kern_entry(发现在0x802000000处)

#### 4.逐步si,并在程序运行到0x10101 jr t0之前执行“info registers”，发现t0中存储的地址即为0x8000000，此步跳转到0x8000000。
>>>>>>> a8d8b71dd4549dc1eac88d5bc341f2be1311a7fa

# lab1

## 扩展练习Challenge3：完善异常中断

在`trap.c`中完善异常处理代码：
```c
        case CAUSE_ILLEGAL_INSTRUCTION:
             // 非法指令异常处理
            cprintf("Exception Type: Illegal instruction\n");
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
            tf->epc+=4;
            break;
        case CAUSE_BREAKPOINT:
            //断点异常处理
            cprintf("Exception Type: breakpoint\n");
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
            tf->epc+=2;
            break;
```
在`init.c`中`intr_enable()`后添加:
```c
    asm("mret");
    asm("ebreak");
```
#### 1.关于mret指令,RISCV手册中有这么一段话：
  "虽然机器模式对于简单的嵌入式系统已经足够，但它仅适用于那些整个代码库都可信的情况，因为M模式可以自由地访问硬件平台。更常见的情况是，不能信任所有的应用程序代码，因为不能事先得知这一点，或者它太大，难以证明正确性。因此，RISC-V提供了保护系统免受不可信的代码危害的机制，并且为不受信任的进程提供隔离保护。 
   必须禁止不可信的代码执行特权指令（如 mret）和访问特权控制状态寄存器（如mstatus），因为这将允许程序控制系统。这样的限制很容易实现，只要加入一种额外的权限模式：用户模式（U 模式）。这种模式拒绝使用这些功能，并在尝试执行 M 模式指令或访问 CSR 的时候产生非法指令异常。其它时候，U 模式和 M 模式的表现十分相似。通过将 mstatus.MPP 设置为 U（如图 10.5 所示，编码为 0），然后执行 mret 指令，软件可以从 M 模式进入 U 模式。如果在 U 模式下发生异常，则把控制移交给 M 模式。"
 
#### 2.正确性证明：
查看RISCV手册，发现c.ebreak两个字节，扩展形式为ebreak四个字节，为了确定究竟几个字节，使用gdb调试：x/30i 0x80200000（从地址 0x80200000 开始，查看 30 条汇编指令）
```
   0x80200000 <kern_entry>:     auipc   sp,0x4
=> 0x80200004 <kern_entry+4>:   mv      sp,sp
   0x80200008 <kern_entry+8>:   j       0x8020000a <kern_init>
   0x8020000a <kern_init>:      auipc   a0,0x4
   0x8020000e <kern_init+4>:    addi    a0,a0,6
   0x80200012 <kern_init+8>:    auipc   a2,0x4
   0x80200016 <kern_init+12>:   addi    a2,a2,22
   0x8020001a <kern_init+16>:   addi    sp,sp,-16
   0x8020001c <kern_init+18>:   sub     a2,a2,a0
   0x8020001e <kern_init+20>:   li      a1,0
   0x80200020 <kern_init+22>:   sd      ra,8(sp)
   0x80200022 <kern_init+24>:   jal     ra,0x80200a16 <memset>
   0x80200026 <kern_init+28>:   jal     ra,0x80200176 <cons_init>
   0x8020002a <kern_init+32>:   auipc   a1,0x1
   0x8020002e <kern_init+36>:   addi    a1,a1,-1538
   0x80200032 <kern_init+40>:   auipc   a0,0x1
   0x80200036 <kern_init+44>:   addi    a0,a0,-1514
   0x8020003a <kern_init+48>:   jal     ra,0x80200070 <cprintf>
   0x8020003e <kern_init+52>:   jal     ra,0x802000a6 <print_kerninfo>
   0x80200042 <kern_init+56>:   jal     ra,0x80200186 <idt_init>
   0x80200046 <kern_init+60>:   jal     ra,0x80200134 <clock_init>
   0x8020004a <kern_init+64>:   jal     ra,0x80200180 <intr_enable>
   0x8020004e <kern_init+68>:   mret
   0x80200052 <kern_init+72>:   ebreak
   0x80200054 <kern_init+74>:   j       0x80200054 <kern_init+74>
   0x80200056 <cputch>: addi    sp,sp,-16
   0x80200058 <cputch+2>:       sd      s0,0(sp)
   0x8020005a <cputch+4>:       sd      ra,8(sp)
   0x8020005c <cputch+6>:       mv      s0,a1
   0x8020005e <cputch+8>:       jal     ra,0x80200178 <cons_putc>
```
发现ebreak指令是两个字节。

#### 3.使用内联汇编的原因
- 1. 访问底层硬件和特权指令
在操作系统开发中，某些特定操作只能通过汇编指令来实现，C语言本身没有内建支持这些特权操作。
    * mret 是 RISC-V 的 特权指令，用于从 M 模式 返回到 S 或 U 模式。它是 RISC-V 中特有的一条底层汇编指令，C 语言无法直接调用这种指令，因此需要使用内联汇编。
    * ebreak 是 RISC-V 的 断点指令，用于在调试时触发断点中断，也是一条低级的汇编指令。类似地，这种指令在 C 语言中没有等效表达，需要通过内联汇编来实现。
- 2. 触发异常
在`init.c`中使用了 mret 和 ebreak 来 故意触发异常以测试异常处理机制。
    * mret 触发非法指令异常：如果在非 M 模式下执行 mret，它会被识别为 非法指令 并触发异常处理。
    * ebreak 触发断点异常：ebreak 是一种调试指令，通常用来手动插入断点，触发断点异常。
C 语言没有直接调用这些底层指令的能力，而操作系统的异常处理机制通常需要通过这种低级指令来测试和验证。通过 asm，可以在 C代码中直接调用这些汇编指令并触发异常，从而验证异常处理代码是否正常工作。

#### 4.一些探索
虽然异常处理的代码已经完善，但对于为什么mret会是非法指令让我感到疑惑。于是加入以下代码：
```
    uintptr_t mstatus_value, mepc_value;
    asm volatile ("csrr %0, mstatus" : "=r" (mstatus_value));
    asm volatile ("csrr %0, mepc" : "=r" (mepc_value));
    cprintf("mstatus: 0x%lx\n", mstatus_value);
    cprintf("mepc: 0x%lx\n", mepc_value);
    uintptr_t mpp = (mstatus_value >> 11) & 0x3;  // 提取 MPP 的值
    cprintf("MPP: 0x%lx\n", mpp);   // 打印 MPP 的值
    /*             
    如果输出的 MPP 值为 0x0，则表示当前处于 U模式。
    如果输出的 MPP 值为 0x1，则表示处于 S模式。
    如果输出的 MPP 值为 0x3，则表示处于 M模式。
    */ 
```
结果是：
```
++ setup timer interrupts
sbi_emulate_csr_read: hartid0: invalid csr_num=0x300
Exception Type: Illegal instruction
Illegal instruction caught at 0x80200052
sbi_emulate_csr_read: hartid0: invalid csr_num=0x341
Exception Type: Illegal instruction
Illegal instruction caught at 0x80200056
mstatus: 0x8001bd90
mepc: 0x8001be00
MPP: 0x3
sbi_emulate_csr_read: hartid0: invalid csr_num=0x302
Exception Type: Illegal instruction
Illegal instruction caught at 0x80200088
Exception Type: breakpoint
ebreak caught at 0x8020008c
sbi_emulate_csr_read: hartid0: invalid csr_num=0x102
Exception Type: Illegal instruction
Illegal instruction caught at 0x8020008e
```
从输出结果来看，mstatus 中的 MPP 值为 0x3，这表示当前处于 M 模式（Machine Mode）。但是执行 mret 后仍然触发了 非法指令异常。日志中多次出现 sbi_emulate_csr_read 错误，表明 OpenSBI 或 QEMU 仿真器在读取 CSR（如 mstatus、medeleg 等）时遇到了问题。这可能限制了 mret 指令的正常执行，因为它依赖于 CSR 来进行模式切换和状态恢复。
解决方法：更新 OpenSBI 版本，或者尝试更高版本的 QEMU，可以避免这种 CSR 访问限制。
但是为了保证版本和实验指导书一致（实际上OpenSBI v1.0甚至会导致lab1无法正常输出os is loading），所以暂不解决，按下不表。