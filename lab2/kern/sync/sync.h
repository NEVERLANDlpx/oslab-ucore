#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>
/*
    kern/sync/sync.h：
    为确保内存管理修改相关数据时不被中断打断，提供两个功能，一个是保存 sstatus 寄
    存器中的中断使能位 (SIE) 信息并屏蔽中断的功能，另一个是根据保存的中断使能位信息来使能中断的
    功能
*/

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
