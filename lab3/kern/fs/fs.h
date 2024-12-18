#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <mmu.h>

#define SECTSIZE            512   //定义了磁盘扇区大小，即 512 字节。所有的数据读写都以扇区为基本单位，每次操作的数据大小必须是 512 字节的倍数
#define PAGE_NSECT          (PGSIZE / SECTSIZE)  
//PAGE_NSECT：定义每页所需的扇区数量。PGSIZE：系统定义的页大小（通常为 4096 字节）。将页大小除以扇区大小，得到一页占用的扇区数。（每页需要 8 个扇区来存储）

#define SWAP_DEV_NO         1   //定义了交换设备的编号

#endif /* !__KERN_FS_FS_H__ */

/*
fs.h 文件定义了“文件系统”模块的一些基本常量和宏
这里的“文件系统”并不是传统意义上的文件系统，因为实验中并没有涉及具体的文件操作。
这个模块只是充当“硬盘”和内核之间的接口，用于在内存和模拟的“硬盘”之间传输数据。
*/