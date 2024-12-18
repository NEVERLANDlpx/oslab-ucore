#include <swap.h>
#include <swapfs.h>
#include <mmu.h>
#include <fs.h>
#include <ide.h>
#include <pmm.h>
#include <assert.h>
//实现了一个简单的交换文件系统
void
swapfs_init(void) {
    static_assert((PGSIZE % SECTSIZE) == 0);
    //为了简化页面与扇区之间的映射关系，需要确保一个页面由若干完整扇区组成（PGSIZE 是 SECTSIZE 的倍数）
    if (!ide_device_valid(SWAP_DEV_NO)) {
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
}
/*
将指定页面从交换设备中读取到内存。
使用 swap_offset(entry) 获得交换条目的偏移量（以页为单位），乘以 PAGE_NSECT 得到扇区偏移量。
写入 page2kva(page) 指向的页面中
*/
int
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

