# lab1代码文件剖析

标签（空格分隔）： os-ucore

---

[toc]

# 一、init

## （一）entry.S

这个汇编代码是一个典型的内核启动代码段，通常用于设置内核启动时的栈指针，并跳转到内核的初始化函数。它主要定义了内核的入口 kern_entry，设置栈指针，并跳转到初始化函数 kern_init，同时定义了内核栈的布局。
###  总结：
- 内核入口：代码从 `kern_entry` 开始执行，首先通过 `la sp`, `bootstacktop` 将栈指针设置为内核栈的顶端。
- 栈指针设置：通过将 `bootstacktop` 的地址加载到 `sp` 中，确保后续的内核代码可以使用内核栈。
- 跳转到初始化：通过 `tail kern_init`，直接跳转到内核初始化函数`kern_init`，内核从那里开始初始化系统。
- 内核栈的定义：通过` .space KSTACKSIZE` 分配了一块内存区域作为内核栈，栈的顶端是 `bootstacktop`，底端是 `bootstack`。
- 这段代码的主要作用是设置内核栈，并准备好内核的执行环境，接着跳转到内核初始化函数进行进一步的系统初始化。

以下是对每一部分的详细解释：

### 1. 节定义和汇编指令
```assembly
.section .text,"ax",%progbits
```
- `.section .text,"ax",%progbits`：这条指令告诉汇编器将接下来的代码放在 `.text` 段中，并设置它的权限为可执行（x）和可读（a）。`.text` 段是存放代码的区域，通常包含程序的指令部分。
- `%progbits`：这是一个标识符，告诉汇编器该段包含程序代码（或“有用的数据”），而不是调试信息或其他元数据。

### 2. 全局符号 kern_entry
```assembly
.globl kern_entry
kern_entry:
```
- `.globl kern_entry`：这是声明一个全局符号 kern_entry，表示这个符号可以在其他文件中引用。通常这是内核的入口点，即内核执行时首先跳转到的地方。
- `kern_entry`：定义了标签 kern_entry，表示这是内核的入口点，之后的指令会从这里开始执行。
### 3. 设置栈指针
```assembly
la sp, bootstacktop
```
- `la sp, bootstacktop`：这条指令的作用是将栈指针寄存器 `sp` 设置为 `bootstacktop` 的地址。
    - `la`：这是 "load address" 的缩写，用于将一个符号地址加载到寄存器中。在这个例子中，它将 `bootstacktop` 的地址加载到栈指针寄存器 sp 中。
    - `sp`：栈指针寄存器，表示当前栈的顶端。栈指针是用于函数调用时保存返回地址、局部变量和其他上下文信息的关键寄存器。
    - `bootstacktop`：这是栈的顶端地址（定义在后面）。这条指令表示在内核启动时，将栈指针设置为内核栈的顶端。
### 4. 跳转到内核初始化函数
```assembly
tail kern_init
```
- `tail kern_init`：这是一个汇编指令，tail 结合了调用和跳转，它会跳转到 `kern_init` 函数并替换当前的调用帧。这意味着不会返回到 `kern_entry`，而是直接进入 `kern_init` 并从那开始执行。这种跳转方式节省了栈空间，因为它不需要保存返回地址。
- `kern_init`：这是内核初始化函数，它负责初始化内核的各个子系统、设置中断、初始化设备等。
### 5. 数据段和内核栈定义
```assembly
.section .data
    # .align 2^12
    .align PGSHIFT
    .global bootstack
bootstack:
    .space KSTACKSIZE
    .global bootstacktop
bootstacktop:
```
#### 5.1 .section .data
`.section .data`：这一部分定义的是数据段，`.data` 段通常包含全局变量或静态变量。这些变量会在程序运行时被初始化。
#### 5.2 对齐栈指针
```assembly
# .align 2^12
.align PGSHIFT
````
-` .align PGSHIFT`：.align 指令用于对齐地址。`PGSHIFT `是页面大小的移位值，通常是 12 位，表示 4KB 的对齐（2^12 = 4096字节 = 4KB）。因此，这条指令确保接下来的数据结构 `bootstack` 是 4KB 对齐的。
- 这样做的原因是操作系统通常要求栈指针和其他内核数据结构以页面大小对齐，以优化内存访问和提高性能。
#### 5.3 栈定义 bootstack 和 bootstacktop
``` assembly
.global bootstack
bootstack:
    .space KSTACKSIZE
.global bootstacktop
bootstacktop:
```
- `bootstack`：这是一个符号，用来表示内核栈的底部地址。它被声明为全局变量（.global），可以在其他文件中引用。

- `.space KSTACKSIZE`：这条指令为栈保留了一段大小为 KSTACKSIZE 的内存。KSTACKSIZE 通常定义为栈的大小，例如 8KB 或 16KB。这相当于为内核的启动过程分配了一块内存用于存放栈。
栈的具体用途是在程序执行时保存局部变量、返回地址以及函数调用的上下文。
- `bootstacktop`：这是栈的顶端地址，表示栈的起始位置。栈在使用时通常是从高地址向低地址增长的，因此 bootstacktop 是栈的最高地址（即栈的起始地址），而 bootstack 是栈的最低地址。
- `.global bootstacktop`：将 bootstacktop 声明为全局符号，意味着它可以被其他文件引用。

### 6.tail
`tail kern_init` 是 RISC-V 汇编中的一条指令，它结合了**跳转（jump）和调用（call）**的功能，用于将程序的执行流转移到 `kern_init` 函数。它的功能类似于调用函数，但有一个重要的区别：它不会保留当前调用帧的返回地址，因此在执行 `kern_init` 函数后，程序不会返回到 `kern_entry`。
`tail` 是 RISC-V 汇编中的一种伪指令，它实际上是**“尾调用优化（Tail Call Optimization, TCO）”**的一部分。

**尾调用优化（TCO）**是什么？
当一个函数的最后一步是调用另一个函数时，称为尾调用。尾调用优化是一种编译器和处理器的优化手段，能够避免为这次调用分配新的栈帧，而是直接复用当前栈帧。
这样做的好处是节省栈空间，避免在递归或函数调用过多时导致栈溢出。

当你使用 `tail kern_init` 时，它实际上是两步的操作：
1) 将当前函数的栈帧销毁或替换，不再保存返回地址。这意味着当前栈帧不再需要保存当前函数（`kern_entry`）的上下文。
2) 跳转到 `kern_init` 函数的地址并执行。它不会在 `kern_init` 执行完后返回到 `kern_entry`，因为它直接替换了调用帧，所以没有保存返回地址。

##### **在内核启动中的作用**
在这段代码中，`tail kern_init` 的作用是：

- 设置内核的栈指针：在此之前通过 `la sp`, `bootstacktop` 将栈指针设置为内核栈的顶端。
- 转移控制权到 `kern_init` 函数：通过 `tail kern_init`，程序的控制权被转移到 `kern_init`，内核初始化从 `kern_init` 开始，而不会返回到 `kern_entry`。

由于 `kern_init` 是内核启动后的主函数，负责初始化操作系统内核的各个模块，因此 `kern_entry` 仅仅是启动过程的一个跳转点，之后不会再需要返回它。

## （二）init.c

`kern_init` 是操作系统启动过程中至关重要的步骤，它完成了从内存清零、初始化控制台、设置中断处理，到打开中断等一系列工作。内核的启动过程确保操作系统能够正常处理中断、进行任务调度并与用户和硬件交互。

这段代码是一个典型的操作系统内核初始化代码，负责启动操作系统的各个子系统并配置中断等重要的机制。通过这段代码，操作系统准备了基本的运行环境，使内核能够开始调度任务并管理硬件资源。

### 1. 内存清零
`edata` 和 `end` 是链接脚本定义的符号，通常用于标识 `.bss `段的起始和结束位置。`.bss` 段包含所有未初始化的全局变量，操作系统启动时需要将这些变量初始化为 0。

`memset(edata, 0, end - edata)` 将 `.bss` 段的所有内存清零。内核需要明确地初始化内存状态，以确保所有未初始化的全局变量或静态变量在启动时都被置为 0。

### 2. 初始化控制台
`cons_init()` 用于初始化内核的控制台。控制台是操作系统与用户或开发者交互的接口。操作系统内核需要控制台来输出调试信息和错误消息，这也是调试操作系统的重要工具。

### 3. 内核加载消息
`cprintf` 是一个格式化输出函数，类似于标准 C 的 `printf`。这里的 `cprintf` 将内核启动消息输出到控制台，提示操作系统正在加载。

输出内核加载消息不仅是为了调试，也是为了在启动过程中提供信息，方便开发者检查内核是否正确加载。

### 4. 打印内核信息
`print_kerninfo() `负责打印内核的相关信息，比如内核的加载地址、内存布局等。这些信息对于开发和调试操作系统至关重要，能够帮助开发者理解内核如何管理内存和硬件资源。

### 5. 初始化中断描述符表
`idt_init()` 初始化中断描述符表（IDT）。**IDT** 是 CPU 用来响应中断和异常的核心机制，它定义了每个中断或异常对应的处理函数。

操作系统的中断机制需要管理硬件和外设发来的中断请求。内核初始化阶段通过配置 IDT，确保能够正确处理中断事件。

#### **中断描述符表（Interrupt Descriptor Table，IDT）**

    在操作系统中，中断描述符表（IDT）是一个重要的数据结构，用于处理硬件和软件的中断。IDT 在 x86 和 RISC-V 等架构中广泛使用，它的主要功能是将各种中断、异常以及系统调用指向相应的中断服务例程（ISR，Interrupt Service Routine），即中断处理函数。
        从操作系统的角度，IDT 的作用是确保处理器在接收到中断信号时能够根据中断的类型，快速找到对应的处理程序。IDT 本质上是一个数组，数组中的每一项指向一个具体的中断处理函数。

**IDT 的基本工作原理**
(1) 中断和异常：

     中断：外部设备（如键盘、硬盘、网络接口等）发送的信号，要求处理器暂停当前任务，去处理外设的请求。中断是异步发生的，处理器并不知道具体何时发生。
     
     异常：处理器在执行程序时遇到的错误或特殊事件，例如除零错误、缺页异常、非法指令等。异常是同步的，也就是说，它在处理特定指令时发生。
     
(2) 中断处理机制:

    当外部设备或处理器检测到中断或异常时，处理器会暂停当前正在执行的指令，跳转到相应的中断处理程序。

(3) 中断向量表:

        中断向量表（在 x86 中是 IVT，现代系统是IDT）存储了不同中断的处理程序地址，每个中断类型都有对应的编号，称为中断向量。IDT 负责将每个中断向量与相应的中断服务例程（ISR）关联起来。当中断或异常发生时，CPU 根据中断向量，从 IDT 中查找并调用相应的处理程序。

### 6. 初始化时钟中断
`clock_init()` 负责初始化时钟中断。时钟中断是操作系统调度的核心。通过时钟中断，操作系统能够周期性地中断当前任务，进行任务切换（上下文切换）和资源调度。

时钟中断使操作系统能够分时运行多个任务，保证系统的多任务调度功能正常运作。内核启动时必须初始化时钟中断，以确保系统具备定期中断的能力。

### 7. 启用中断
`intr_enable()` 启用全局中断。在操作系统启动过程中，内核往往在初始化各个子系统（如中断处理、设备驱动）后，才会打开中断。这样可以确保在关键的初始化过程中，不会被外部设备或其他事件打断。

操作系统依赖中断来处理外部事件和硬件请求，启用全局中断意味着操作系统已准备好响应来自硬件设备或外部源的中断信号。

### 8. 无限循环
`while (1)` 是一个死循环，表示内核在完成初始化后进入运行状态。操作系统内核不会退出或返回到某个上层程序，通常会进入一个主循环，等待处理外部事件或中断请求。

操作系统不会终止其主流程，内核将一直运行，处理调度、系统调用或其他核心任务。

### 9. 调试函数 grade_backtrace
虽然该函数在初始化过程中没有被调用（因为注释掉了），但它的目的是追踪内核中的函数调用路径。

grade_backtrace 系列函数用于追踪程序的调用栈，可以帮助开发者在内核调试时，查看调用链，了解某个函数是从哪里调用的。这对于调试复杂的内核逻辑非常有帮助。

# 二、trap

## (一) trap.h

这段代码是 `trap.h` 头文件的定义，它定义了用于处理中断和异常（trap）时的相关数据结构和函数接口。具体包括保存寄存器状态的结构体 `pushregs` 和 `trapframe`，以及几个函数声明，如 `trap()` 和 `idt_init()`，用于初始化和处理中断。


### 1.结构体 `pushregs`

`pushregs` 结构体保存了 RISC-V 中的所有通用寄存器。在处理中断或异常时，所有寄存器的值都会保存在 `pushregs` 结构体中，以便稍后恢复它们。

- `zero`：硬连线为 0 的寄存器，即 `x0`，在 RISC-V 架构中该寄存器的值总是 0。
- `ra`：返回地址寄存器（x1），保存函数调用的返回地址。
- `sp`：栈指针寄存器（x2），指向当前栈的顶部。
- `gp`：全局指针寄存器（x3），通常用于全局变量或静态数据。
- `tp`：线程指针寄存器（x4），指向当前线程的相关数据。
- `t0, t1, t2`：临时寄存器（x5, x6, x7），用于临时存储数据，函数调用间不保留值。
- `s0, s1`：保存寄存器（x8, x9），在函数调用之间需要保留，`s0` 还经常作为栈帧指针使用。
- `a0 - a7`：函数参数寄存器（x10 - x17），用于传递函数参数和返回值。
- `s2 - s11`：更多保存寄存器（x18 - x27），其值在函数调用之间需要保留。
- `t3 - t6`：更多的临时寄存器（x28 - x31），不需要保留其值。

### 2.结构体 `trapframe`

`trapframe` 是中断或异常发生时保存 CPU 完整状态的结构体。它不仅保存了所有通用寄存器（通过 `pushregs`），还保存了控制状态寄存器的值，这对于处理中断或异常非常关键。

- `gpr`：保存了所有的通用寄存器。
- `status`：保存 `sstatus` 寄存器的值，`sstatus` 记录了 CPU 的状态信息。
- `epc`：保存异常发生时的程序计数器 `sepc`，异常处理完成后，程序将从此地址继续执行。
- `badvaddr`：保存导致异常的虚拟地址（例如，访问无效内存时的地址）。
- `cause`：保存异常原因（scause），例如外部中断、非法指令等。

### 3.函数声明

#### 3.1 函数 `trap`

`trap` 是中断和异常处理的核心函数。当中断或异常发生时，系统会调用该函数，并将 `trapframe` 结构体作为参数传入。该函数根据异常的类型来执行不同的处理逻辑。

#### 3.2 函数 `idt_init`

`idt_init` 函数用于初始化中断描述符表（IDT），IDT 是用于将不同类型的中断或异常映射到各自的处理函数的表格。在系统启动时必须完成这一步初始化工作。

#### 3.3函数 `print_trapframe`

`print_trapframe` 函数用于打印 `trapframe` 结构体中的寄存器和状态信息。这通常用于调试，以便开发者能够检查在异常发生时 CPU 的状态。

#### 3.4 函数 `print_regs`

`print_regs` 用于打印 `pushregs` 结构体中的通用寄存器的值。它主要用于调试，帮助开发者了解寄存器的状态。

#### 3.5 函数 `trap_in_kernel`

`trap_in_kernel` 函数用于判断异常或中断是否发生在内核模式。如果返回 `true`，表示该异常发生在内核态，否则是在用户态。

### 4. 文件结尾定义

这是文件的结束标志，与文件开头的 `#ifndef` 相对应。它用于防止头文件被多次包含，确保该文件中的内容只被编译一次。

### 总结

- `pushregs` 结构体：保存了所有的通用寄存器，在中断或异常发生时用来保存 CPU 的状态。
- `trapframe` 结构体：保存 CPU 状态的完整信息，包括通用寄存器和控制状态寄存器。
- 主要函数：
  - `trap`：核心的中断和异常处理函数。
  - `idt_init`：初始化中断向量表（IDT）。
  - `print_trapframe` 和 `print_regs`：用于打印调试信息，帮助开发者了解异常发生时的寄存器状态。
  - `trap_in_kernel`：判断中断或异常是否发生在内核模式。

## (二) trap.c

`trap.c` 文件是操作系统中处理中断和异常（trap）的核心代码部分。它定义了中断和异常的处理函数，并根据 trap 类型进行分发，处理不同的中断和异常情况。

### 1. 头文件引入

- 头文件包括了系统中所需的各种定义和函数，例如 `clock.h`, `console.h`, `trap.h` 等。它们提供了系统中不同模块的支持，例如时钟中断、控制台输出、以及处理 trap 的定义。

### 2. 宏定义和全局变量

- **`#define TICK_NUM 100`**: 该宏定义每 100 次时钟中断触发时输出 "ticks"。
- **`volatile size_t num=0;`**: 定义了一个全局变量 `num`，用于记录时钟中断次数。当达到 10 次 `100 ticks` 时，系统将调用 `sbi_shutdown()` 关机。

### 3. 函数 `print_ticks`

该函数会在系统时钟中断 100 次后输出一个 `"100 ticks"`，并根据是否启用了调试模式输出额外信息。如果开启了 `DEBUG_GRADE`，会输出测试结束信息并终止系统。

- **`cprintf`**：控制台输出函数，用于打印调试信息。
- **`panic`**：输出错误信息并停止系统运行。

### 4. 函数 `idt_init`

- **`idt_init`** 是中断向量表（IDT）的初始化函数。它做了两件事：
  1. 将 `sscratch` 设置为 0，以指示异常向量当前处于内核模式。
  2. 设置 `stvec` 寄存器，将其指向 `__alltraps` 函数地址，`__alltraps` 是异常或中断发生时跳转的入口。

### 5. 函数 `trap_in_kernel`

- **`trap_in_kernel`** 用于判断异常或中断是否发生在内核模式下。它通过检查 `trapframe` 中的 `status` 寄存器中的 `SSTATUS_SPP` 位来确定，如果不为 0，则表示中断发生在内核模式。

### 6. 函数 `print_trapframe`

- **`print_trapframe`** 会打印出 `trapframe` 的所有寄存器值和状态，用于调试目的。它通过 `print_regs` 函数打印通用寄存器的内容，然后打印 `status`, `epc`, `badvaddr`, `cause` 等控制寄存器的值。

### 7. 函数 `print_regs`

- **`print_regs`** 用于逐个打印 `pushregs` 结构体中保存的所有通用寄存器的值，用于调试。通用寄存器包括从 `x0` 到 `x31`，即 `zero` 到 `t6`。

### 8. 函数 `interrupt_handler`

- **`interrupt_handler`** 是处理中断的核心函数，根据 `trapframe` 中的 `cause` 寄存器来区分不同的中断类型，并做出相应处理。例如：
  - **`IRQ_S_TIMER`**：当发生 Supervisor Timer 中断时，调用 `clock_set_next_event` 设置下次时钟中断，增加时钟 `ticks` 计数器，达到 100 时输出 "100 ticks"，并在累积 10 次后调用 `sbi_shutdown` 关机。
  - 其他类型的中断（如用户、机器、外部中断等）根据需要进行打印或忽略。

### 9. 函数 `exception_handler`

- **`exception_handler`** 是处理异常的核心函数。它根据 `trapframe` 中的 `cause` 寄存器来处理不同的异常类型。例如：
  - **`CAUSE_ILLEGAL_INSTRUCTION`**：处理非法指令异常。输出异常类型、异常地址，并更新 `epc`，使其跳过异常指令。
  - **`CAUSE_BREAKPOINT`**：处理断点异常，通常用于调试，类似地输出异常类型和地址，并更新 `epc`。

### 10. 函数 `trap_dispatch`

- **`trap_dispatch`** 是一个中断和异常的分发函数。它根据 `trapframe` 中 `cause` 的值来区分中断和异常：
  - 如果 `cause` 为负值，则表示中断，调用 `interrupt_handler`。
  - 如果 `cause` 为正值，则表示异常，调用 `exception_handler`。

### 11. 函数 `trap`

- **`trap`** 是系统处理中断和异常的总入口。当发生中断或异常时，系统首先会进入 `__alltraps`，并最终调用 `trap` 函数。`trap` 函数调用 `trap_dispatch` 来分发和处理具体的中断或异常。处理完后，系统会返回到异常发生前的状态。

- 在 `trap` 返回后，系统的状态会由 `trapentry.S` 中的汇编代码进行恢复，最后通过 `sret` 指令从中断返回。

### 总结

`trap.c` 文件实现了系统中对中断和异常的处理逻辑，分为中断处理和异常处理。中断处理包括时钟中断、软件中断等，而异常处理包括非法指令、断点等异常。通过 `trapframe` 保存的上下文，系统可以在处理完中断或异常后恢复执行。

主要函数：

- `idt_init`：初始化中断向量表。
- `trap`：处理中断或异常的核心函数。
- `interrupt_handler` 和 `exception_handler`：分别处理中断和异常。
- `trap_dispatch`：分发中断或异常到相应的处理函数。
- `print_trapframe` 和 `print_regs`：打印调试信息，帮助调试中断和异常发生时的 CPU 状态。

## (三) trapentry.S

这段代码实现了在 RISC-V 架构下的中断与异常处理机制，主要包括保存和恢复寄存器的宏定义 `SAVE_ALL` 和 `RESTORE_ALL`，以及中断入口 `__alltraps` 和返回点 `__trapret` 的汇编代码。

这段代码实现了在 RISC-V 架构下的中断与异常处理机制，主要包括保存和恢复寄存器的宏定义 `SAVE_ALL` 和 `RESTORE_ALL`，以及中断入口 `__alltraps` 和返回点 `__trapret` 的汇编代码。以下是详细的讲解，包括各指令和寄存器的作用。

### 1. 基本背景：中断和异常处理

操作系统内核会频繁遇到各种中断和异常。当系统发生中断或异常时，CPU 会暂停当前执行的任务，转而去处理这些事件。处理完之后，CPU 需要恢复到中断发生前的状态，继续执行原来的任务。为了做到这一点，系统需要在进入中断时保存所有寄存器的状态，处理完中断后再恢复它们，这正是这段代码的目的。

---

### 2. 寄存器的基本作用

在 RISC-V 架构中，寄存器是 CPU 用来存储数据的地方，有几种重要的寄存器：

- **通用寄存器（x0 - x31）**：用于存储计算结果、函数参数、返回地址等。
- **控制状态寄存器（CSR）**：用于存储与 CPU 状态相关的特殊寄存器，例如：
  - **`sstatus`**：存储中断状态和特权级别。
  - **`sepc`**：存储异常发生时的指令地址（即哪个指令导致了异常）。
  - **`scause`**：保存导致中断或异常的原因。

---

### 3. 汇编指令简述

- **`csrr`** 和 **`csrw`**：这两条指令是用来读写 CSR 寄存器的。
  - **`csrr`**：从一个 CSR 寄存器中读取数据，存储到一个普通寄存器中。
  - **`csrw`**：将一个普通寄存器的值写入到一个 CSR 寄存器中。

- **`STORE`** 和 **`LOAD`**：这两条指令是用来在栈上保存和恢复寄存器数据的。
  - **`STORE`**：将寄存器的值存到内存中（这里存到栈里）。
  - **`LOAD`**：从栈中取出保存的值，放回寄存器。

- **`addi`**：这是一个加法指令，用来对寄存器中的值加上一个常数。

---

### 4. `SAVE_ALL` 宏详细解读

`SAVE_ALL` 是用来在中断发生时，保存当前的 CPU 状态，包括所有通用寄存器和控制状态寄存器。

```assembly
csrw sscratch, sp
```

- `csrw sscratch, sp`：把当前栈指针 `sp`（指向当前任务的栈顶）保存到 `sscratch` 寄存器。这样做是为了在处理异常时保存栈的状态。
```assembly
addi sp, sp, -36 * REGBYTES
```
- `addi sp, sp, -36 * REGBYTES`：这里把栈指针向下移动了 36 个寄存器大小的空间（REGBYTES 通常是 8 字节）。这是为了给所有需要保存的寄存器腾出足够的空间。
```assembly
STORE x0, 0*REGBYTES(sp)
STORE x1, 1*REGBYTES(sp)
STORE x3, 3*REGBYTES(sp)
...
STORE x31, 31*REGBYTES(sp)
```
- 这一系列 `STORE` 指令把所有通用寄存器（`x0` 到 `x31`）的值保存到栈中。栈是内存中的一块区域，专门用于保存函数调用时的上下文（包括寄存器、局部变量等）。通过这些指令，我们在中断时保存了所有寄存器的值，以便稍后可以恢复。
```assembly
csrrw s0, sscratch, x0
```
- `csrrw`：这是一个从 `sscratch` 读取值的指令，并把它保存在 `s0` 寄存器中。之后，我们将 `sscratch` 清零，防止在递归异常时混淆上下文信息。
```assembly
csrr s1, sstatus
csrr s2, sepc
csrr s3, sbadaddr
csrr s4, scause
```
- 这里，分别将 `sstatus`（中断状态寄存器）、`sepc`（异常程序计数器）、`sbadaddr`（发生错误的内存地址）和 `scause`（异常原因）保存到 `s1`、`s2`、`s3`、`s4` 寄存器中。通过保存这些寄存器，系统可以记住中断发生时的状态。

### 5. RESTORE_ALL 宏详细解读

`RESTORE_ALL `，将之前保存的寄存器状态恢复，以确保程序可以从中断之前的状态继续运行。
```assembly
LOAD s1, 32*REGBYTES(sp)
LOAD s2, 33*REGBYTES(sp)
```

- `LOAD`：从栈中恢复之前保存的`sstatus` 和 `sepc` 的值。

```assembly
csrw sstatus, s1
csrw sepc, s2
```
- 这里将恢复的 `sstatus` 和 `sepc` 写回到相应的控制状态寄存器，恢复之前的中断状态和程序计数器。
```assembly
LOAD x1, 1*REGBYTES(sp)
LOAD x3, 3*REGBYTES(sp)
LOAD x4, 4*REGBYTES(sp)
...
LOAD x31, 31*REGBYTES(sp)
```

 - 这一系列 `LOAD` 指令将所有通用寄存器从栈中恢复。

```assembly
LOAD x2, 2*REGBYTES(sp)
```
- 最后一步是恢复栈指针 sp，确保栈能够正常工作。
### 6. 中断处理入口 __alltraps
```assembly
__alltraps:
    SAVE_ALL
    move  a0, sp
    jal trap
```
- `SAVE_ALL`：在进入中断时，首先调用 `SAVE_ALL` 宏保存所有寄存器的状态。
- `move a0, sp`：将当前栈指针` sp` 传递给 `a0 `寄存器，这是为了将当前任务的栈传递给` trap` 函数进行处理。
- `jal trap`：跳转到 trap 函数，这个函数是操作系统用来处理中断或异常的 C 语言函数。通过这条指令，我们从汇编代码跳到 C 语言的世界，继续处理中断。
### 7. 中断处理返回 __trapret
```assembly
__trapret:
    RESTORE_ALL
    sret
```
- `RESTORE_ALL`：恢复所有寄存器的状态。
- `sret`：这是一个特权指令，表示从中断返回。`sret` 会将处理器的状态恢复到中断或异常发生时的状态，并从之前保存的程序计数器 `sepc` 恢复执行。
### 8. 总结
整个流程是操作系统处理中断的关键步骤：

进入中断时，首先保存当前程序的所有寄存器状态（通用寄存器和控制状态寄存器）。
然后将控制权转移给 C 语言的 **trap** 函数，让操作系统根据中断类型进行处理。
**处理中断**后，通过 RESTORE_ALL 恢复之前保存的寄存器状态，确保程序可以从中断前的状态继续执行。
通过 **sret** 指令返回到中断前的执行状态。

## 三、Makefile


`Makefile` 是构建系统的一个核心配置文件，它通过定义一系列规则和指令来告诉编译器如何构建项目。这段 `Makefile` 的主要作用是配置和构建 RISC-V 内核以及相关的可执行文件。

### 1. 项目和变量定义

- `PROJ := lab1`：定义项目名称为 `lab1`，该名称可以用于其他地方。
- `GCCPREFIX := riscv64-unknown-elf-`：定义交叉编译器的前缀，表示使用 RISC-V 工具链来进行编译。
- `QEMU` 和 `SPIKE`：定义了用于模拟 RISC-V 环境的模拟器，默认为 `qemu-system-riscv64` 和 `spike`。
  
```makefile
GCCPREFIX := riscv64-unknown-elf-
QEMU := qemu-system-riscv64
SPIKE := spike
```
### 2. 编译器和链接器设置
- `HOSTCC`：设置宿主编译器为 gcc，并使用 -Wall 和 -O2 进行警告和优化。
- `GDB`：指定用于调试的 GDB 命令（riscv64-unknown-elf-gdb）。
- `CC`：设置交叉编译器为 riscv64-unknown-elf-gcc，并定义了一系列的编译标志（CFLAGS），例如 -mcmodel=medany 和 -g。
```makefile
CC := $(GCCPREFIX)gcc
CFLAGS := -mcmodel=medany -std=gnu99 -Wno-unused -Werror
CFLAGS += -fno-builtin -Wall -O2 -nostdinc $(DEFS)
CFLAGS += -fno-stack-protector -ffunction-sections -fdata-sections
CFLAGS += -g
```

- `LD` 和 `LDFLAGS`：指定链接器和链接时的选项，使用 RISC-V ELF 格式并禁用标准库。

```makefile
LD := $(GCCPREFIX)ld
LDFLAGS := -m elf64lriscv
LDFLAGS += -nostdlib --gc-sections
```
### 3. 编译和链接过程
- `OBJCOPY` 和 `OBJDUMP`：用于将目标文件转换为其他格式或生成可视化的汇编代码。
- `COPY`, `MKDIR`, `MV`, `RM`, `AWK` 等：定义了一些常用的命令，用于文件操作和处理。
```makefile
OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump
COPY := cp
MKDIR := mkdir -p
MV := mv
RM := rm -f
```
### 4. 编译目标和规则
- `KINCLUDE` 和 `KSRCDIR`：定义内核相关的头文件和源文件路径。通过这些变量，Makefile 可以动态生成编译和链接的规则。
- `KOBJS`：定义了需要编译的内核对象文件。
- `kernel`：这是最终生成的内核目标文件，使用 `LD` 和 `LDFLAGS` 链接生成。
```makefile
KOBJS = $(call read_packet,kernel libs)

kernel = $(call totarget,kernel)
```
`UCOREIMG`：定义了 `ucore.img`，这是最终生成的 RISC-V 可执行文件，它通过将内核目标文件 `kernel` 转换为二进制文件生成。
```makefile
UCOREIMG := $(call totarget,ucore.img)
```
### 5. QEMU 和调试目标
- `qemu`：该目标用于通过 QEMU 模拟器来运行 RISC-V 内核。
- `debug`：该目标会启动 QEMU 并进入调试模式，监听本地的 1234 端口，等待 gdb 连接。
```makefile
qemu: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU) \
		-machine virt \
		-nographic \
		-bios default \
		-device loader,file=$(UCOREIMG),addr=0x80200000

debug: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
	$(V)$(QEMU) \
		-machine virt \
		-nographic \
		-bios default \
		-device loader,file=$(UCOREIMG),addr=0x80200000\
		-s -S
```
### 6. 清理和其他辅助目标
- `clean` 和 `dist-clean`：这些目标用于清理生成的文件，例如目标文件、符号文件和标签文件。
- `grade`：该目标用于执行项目的测试脚本。
- `tags`：该目标用于生成代码导航所需的标签文件。
```makefile
.PHONY: clean dist-clean handin packall tags
clean:
	$(V)$(RM) $(GRADE_GDB_IN) $(GRADE_QEMU_OUT) cscope* tags
	-$(RM) -r $(OBJDIR) $(BINDIR)

dist-clean: clean
	-$(RM) $(HANDIN)

handin: packall
	@echo Please visit http://learn.tsinghua.edu.cn and upload $(HANDIN). Thanks!
```

### 总结
这个 Makefile 通过一系列的定义和规则，自动化了 RISC-V 内核的编译、链接、打包和运行。通过指定交叉编译器和模拟器，它为在 RISC-V 平台上开发操作系统提供了完整的工具链支持。同时，它也包含了调试功能，可以通过 gdb 和 qemu 结合进行调试。




