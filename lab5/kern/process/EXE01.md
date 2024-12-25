## load_icode的第6步
建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。

```c
//(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    tf->gpr.sp = USTACKTOP;  // 设置f->gpr.sp为用户栈的顶部地址
    tf->epc = elf->e_entry;  // 设置tf->epc为用户程序的入口地址
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE);  // 根据需要设置 tf->status 的值，清除 SSTATUS_SPP 和 SSTATUS_SPIE 位

    ret = 0;
```
将`sp`设置为栈顶，`epc`设置为文件的入口地址，`sstatus`的`SPP`位清零，代表异常来自用户态，之后需要返回用户态；`SPIE`位清零，表示不启用中断。


## 用户进程 `userproc` 的创建过程


### **1. 内核线程 `initproc` 的创建**

在 `proc_init` 中，首先创建了内核线程 `initproc`，调用如下：

```c
kernel_thread(init_main, NULL, 0);
```

- **`init_main`**：是 `initproc` 的入口函数。

---

### **2. 内核线程 `initproc` 调用 `user_main`**

在 `init_main` 中，调用了 `user_main` 函数：

```c
kernel_thread(user_main, NULL, 0);
```

- **`user_main`**：负责启动用户进程。

---

### **3. `user_main` 调用 `KERNEL_EXECVE2`**

在 `user_main` 中，调用了 `KERNEL_EXECVE2` 宏来执行用户程序：

```c
KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
```

- **`TEST`**：用户程序的名称（如 `hello`）。
- **`TESTSTART`**：用户程序的二进制起始地址。
- **`TESTSIZE`**：用户程序的二进制大小。

`KERNEL_EXECVE2` 调用了 `kernel_execve` 函数，该函数通过 `SYS_exec` 系统调用创建用户进程。

---

### **4. `kernel_execve` 调用 `SYS_exec`**

`kernel_execve` 函数的作用是将用户程序的二进制数据加载到当前进程的虚拟内存空间中，并执行该程序。其调用流程如下：

1. **触发系统调用**：
   - 通过 `ebreak` 指令触发断点异常，进入内核态。
   - 系统调用号 `SYS_exec` 被传递到寄存器 `a7`。

2. **异常处理**：
   - 异常处理程序 `exception_handler` 捕获断点异常。
   - 检查 `a7` 是否为 `SYS_exec`，如果是，则调用 `syscall()` 处理系统调用。

3. **系统调用处理**：
   - `syscall()` 根据系统调用号调用 `sys_exec`。
   - `sys_exec` 调用 `do_execve` 完成用户进程的创建。

---

## **5. `do_execve` 函数的工作流程**

`do_execve` 是用户进程创建的核心函数，其主要工作流程如下：

### **5.1 清空用户态内存空间**

- 如果当前进程的 `mm`（内存管理结构）不为 `NULL`，则：
  - 设置页表为内核空间页表。
  - 如果 `mm` 的引用计数减 1 后为 0，则释放用户空间内存和页表。
  - 将当前进程的 `mm` 指针设为 `NULL`。
- 由于 `initproc` 是内核线程，`mm` 为 `NULL`，因此不会执行上述操作。

### **5.2 加载用户程序**

- 调用 `load_icode` 函数，完成以下任务：
  - 读取 ELF 格式的用户程序文件。
  - 申请内存空间，建立用户态虚拟内存空间。
  - 加载用户程序的执行码到内存中。
  - 初始化用户进程的堆栈。
  - 修改当前进程的 `trapframe`，使得中断返回时能够切换到用户态并跳转到用户程序的入口。

---

### **6. 进程创建与调度**

### **6.1 `do_fork` 创建子进程**

- `kernel_thread` 函数内部调用了 `do_fork`，创建子进程。
- `do_fork` 调用 `wake_proc`，将新创建的进程设置为就绪状态（`RUNNABLE`）。

### **6.2 `initproc` 等待子进程**

- `initproc` 调用 `do_wait`，等待子进程进入就绪状态。
- 当子进程就绪后，调用 `schedule` 函数进行调度。

### **6.3 `schedule` 调度新进程**

- `schedule` 函数调用 `proc_run`，运行新的进程。
- `proc_run` 完成以下操作：
  - 将 `satp` 寄存器设置为用户态进程的页表基址（`lcr3(to->cr3)`）。
  - 调用 `switch_to` 函数进行上下文切换，保存当前寄存器状态，恢复待执行进程的寄存器状态。
  - 使用 `ret` 指令跳转到 `ra` 寄存器指向的地址（即 `forkret` 函数）。

### **6.4 `forkret` 返回用户态**

- `forkret` 函数调用 `forkrets`（位于 `trapentry.S`）。
- `forkrets` 跳转到 `__trapret`，保存所有寄存器。
- 由于在 `load_icode` 中已将 `SSTATUS_SPP` 设置为 0，因此不会跳转。
- 保存内核态栈指针，恢复 `sstatus` 和 `sepc` 以及通用寄存器。
- 执行 `sret` 指令，切换到用户态。

### **6.5 跳转到用户程序入口**

- `sret` 指令跳转到 `sepc` 指向的地址，即 ELF 文件的入口地址。
- 开始执行用户态程序。

