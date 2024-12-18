#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>
//该文件模拟了一个简单的“硬盘”接口，实现读写操作，但实际操作是通过内存中的数据复制来模拟磁盘的数据存取
void ide_init(void) {}

#define MAX_IDE 2  //定义系统中最多可以有2个 IDE 设备。在本实验中实际上只有一个
#define MAX_DISK_NSECS 56  //定义硬盘的扇区数，每个扇区大小为 SECTSIZE（512字节）
static char ide[MAX_DISK_NSECS * SECTSIZE];  //这是一个内存数组，用于模拟硬盘的数据存储。数组大小为 MAX_DISK_NSECS * SECTSIZE 字节（相当于56个扇区的大小）

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }  //设备编号 ideno 是否在有效范围内

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }  //指定设备的扇区数

/*
    模拟的硬盘读操作函数，用于从模拟的磁盘中读取数据
    ideno：设备编号。由于这里只模拟一个设备，所以此参数未实际使用。
    secno：起始扇区号，从该扇区开始读取数据。
    dst：目标地址，用于存储读取到的数据。
    nsecs：要读取的扇区数。
    iobase 计算起始位置的字节偏移量
    memcpy 将数据从 ide 数组的 iobase 位置复制到 dst 指向的内存区域
*/
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}  


int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;
}
