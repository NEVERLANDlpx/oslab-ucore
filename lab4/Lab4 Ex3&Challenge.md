# Lab4 Ex3&Challenge

## 一、Ex3

问：在本实验的执行过程中，创建且运行了几个内核线程？

答：**两个**内核线程：0号线程`idleproc`和1号线程`initproc`。

## 二、Challenge

说明语句 local_intr_save(intr_flag);....local_intr_restore(intr_flag); 是如何实现开关中断的？

### ·介绍sstatus寄存器

```
sstatus寄存器（supervisor status registers）-禁止中断

二进制位SIE为0：S态运行程序时，禁用所有中断。（U态不行）

二进制位UIE为0：禁止用户态程序产生中断。
```



### 1.关中断

```
//1.对intr_flag调用__intr_save()
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
```

```
//2. __intr_save - 保存中断状态，并在启用中断的情况下禁用中断
static inline bool __intr_save(void) {
    // 检查 sstatus 寄存器中的 SIE（全局中断使能）位
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable(); // 如果 SIE 位被设置，调用 intr_disable() 禁用中断
        return 1; // 返回 1 表示中断之前是启用状态
    }
    return 0; // 返回 0 表示中断之前是禁用状态
}
```

```
/* 
 * 3.intr_disable - 禁用 IRQ（中断请求）中断 
 */
void intr_disable(void) { 
    clear_csr(sstatus, SSTATUS_SIE); // 清除 sstatus 寄存器中的 SIE 位，以禁用中断
}
```

### 2.开中断

```
//1.对x调用 __intr_restore
#define local_intr_restore(x) __intr_restore(x);
```

```
//2.如果之前是开中断状态，现在需要恢复开中断，调用intr_enable
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}
```

```
/* 3，intr_enable - 设置sstatus 寄存器中的 SIE 位，恢复中断 */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
```

