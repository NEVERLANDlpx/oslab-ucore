
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # 1.设置三级页表的物理地址
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc
    
    # 2.配置 satp 寄存器来启动虚拟内存
    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    # 将组合后的值写入 satp 寄存器，启用三级页表映射。
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB,确保页表的更新生效。
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 3.设置栈指针并跳转到内核入口函数
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
    /*
        edata：指向数据段结束的位置，数据段包含所有已初始化的全局和静态变量。
        end：指向 BSS 段结束的位置。BSS 段存放的是所有未初始化的全局和静态变量，在程序启动时，这些变量会被初始化为 0。
    */
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	5b660613          	addi	a2,a2,1462 # ffffffffc02065f0 <end>
=======
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <buddy_system_free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	52e60613          	addi	a2,a2,1326 # ffffffffc0206568 <end>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
<<<<<<< HEAD
ffffffffc020004a:	537010ef          	jal	ra,ffffffffc0201d80 <memset>
=======
ffffffffc020004a:	48c010ef          	jal	ra,ffffffffc02014d6 <memset>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
<<<<<<< HEAD
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	d4650513          	addi	a0,a0,-698 # ffffffffc0201d98 <etext+0x6>
=======
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	49650513          	addi	a0,a0,1174 # ffffffffc02014e8 <etext>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();初始化 IDT（中断描述符表），该表用于管理各种中断请求和异常处理。
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>
<<<<<<< HEAD

    pmm_init();  // init physical memory management
ffffffffc0200066:	3ac010ef          	jal	ra,ffffffffc0201412 <pmm_init>
=======
    //初始化物理内存管理，设置物理内存分配、管理策略。
    pmm_init();  // init physical memory management
ffffffffc0200066:	531000ef          	jal	ra,ffffffffc0200d96 <pmm_init>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
<<<<<<< HEAD
ffffffffc02000a6:	005010ef          	jal	ra,ffffffffc02018aa <vprintfmt>
=======
ffffffffc02000a6:	75b000ef          	jal	ra,ffffffffc0201000 <vprintfmt>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
<<<<<<< HEAD
ffffffffc02000dc:	7ce010ef          	jal	ra,ffffffffc02018aa <vprintfmt>
=======
ffffffffc02000dc:	725000ef          	jal	ra,ffffffffc0201000 <vprintfmt>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
<<<<<<< HEAD
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	c7c50513          	addi	a0,a0,-900 # ffffffffc0201db8 <etext+0x26>
=======
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	3cc50513          	addi	a0,a0,972 # ffffffffc0201508 <etext+0x20>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
<<<<<<< HEAD
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	c8650513          	addi	a0,a0,-890 # ffffffffc0201dd8 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	c3458593          	addi	a1,a1,-972 # ffffffffc0201d92 <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	c9250513          	addi	a0,a0,-878 # ffffffffc0201df8 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	c9e50513          	addi	a0,a0,-866 # ffffffffc0201e18 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	46a58593          	addi	a1,a1,1130 # ffffffffc02065f0 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	caa50513          	addi	a0,a0,-854 # ffffffffc0201e38 <etext+0xa6>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00007597          	auipc	a1,0x7
ffffffffc020019e:	85558593          	addi	a1,a1,-1963 # ffffffffc02069ef <end+0x3ff>
=======
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	3d650513          	addi	a0,a0,982 # ffffffffc0201528 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	38a58593          	addi	a1,a1,906 # ffffffffc02014e8 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	3e250513          	addi	a0,a0,994 # ffffffffc0201548 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <buddy_system_free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0201568 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	3e258593          	addi	a1,a1,994 # ffffffffc0206568 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	3fa50513          	addi	a0,a0,1018 # ffffffffc0201588 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	7cd58593          	addi	a1,a1,1997 # ffffffffc0206967 <end+0x3ff>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
<<<<<<< HEAD
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	c9c50513          	addi	a0,a0,-868 # ffffffffc0201e58 <etext+0xc6>
=======
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	3ec50513          	addi	a0,a0,1004 # ffffffffc02015a8 <etext+0xc0>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
<<<<<<< HEAD
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	cbe60613          	addi	a2,a2,-834 # ffffffffc0201e88 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	cca50513          	addi	a0,a0,-822 # ffffffffc0201ea0 <etext+0x10e>
=======
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	40e60613          	addi	a2,a2,1038 # ffffffffc02015d8 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	41a50513          	addi	a0,a0,1050 # ffffffffc02015f0 <etext+0x108>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
<<<<<<< HEAD
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	cd260613          	addi	a2,a2,-814 # ffffffffc0201eb8 <etext+0x126>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	cea58593          	addi	a1,a1,-790 # ffffffffc0201ed8 <etext+0x146>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	cea50513          	addi	a0,a0,-790 # ffffffffc0201ee0 <etext+0x14e>
=======
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	42260613          	addi	a2,a2,1058 # ffffffffc0201608 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	43a58593          	addi	a1,a1,1082 # ffffffffc0201628 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	43a50513          	addi	a0,a0,1082 # ffffffffc0201630 <etext+0x148>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
<<<<<<< HEAD
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	cec60613          	addi	a2,a2,-788 # ffffffffc0201ef0 <etext+0x15e>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	d0c58593          	addi	a1,a1,-756 # ffffffffc0201f18 <etext+0x186>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	ccc50513          	addi	a0,a0,-820 # ffffffffc0201ee0 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	d0860613          	addi	a2,a2,-760 # ffffffffc0201f28 <etext+0x196>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	d2058593          	addi	a1,a1,-736 # ffffffffc0201f48 <etext+0x1b6>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	cb050513          	addi	a0,a0,-848 # ffffffffc0201ee0 <etext+0x14e>
=======
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	43c60613          	addi	a2,a2,1084 # ffffffffc0201640 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	45c58593          	addi	a1,a1,1116 # ffffffffc0201668 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	41c50513          	addi	a0,a0,1052 # ffffffffc0201630 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	45860613          	addi	a2,a2,1112 # ffffffffc0201678 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	47058593          	addi	a1,a1,1136 # ffffffffc0201698 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	40050513          	addi	a0,a0,1024 # ffffffffc0201630 <etext+0x148>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
<<<<<<< HEAD
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	cee50513          	addi	a0,a0,-786 # ffffffffc0201f58 <etext+0x1c6>
=======
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	43e50513          	addi	a0,a0,1086 # ffffffffc02016a8 <etext+0x1c0>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
<<<<<<< HEAD
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	cf450513          	addi	a0,a0,-780 # ffffffffc0201f80 <etext+0x1ee>
=======
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	44450513          	addi	a0,a0,1092 # ffffffffc02016d0 <etext+0x1e8>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
<<<<<<< HEAD
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	d4ec0c13          	addi	s8,s8,-690 # ffffffffc0201ff0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	cfe90913          	addi	s2,s2,-770 # ffffffffc0201fa8 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	cfe48493          	addi	s1,s1,-770 # ffffffffc0201fb0 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	cfcb0b13          	addi	s6,s6,-772 # ffffffffc0201fb8 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	c14a0a13          	addi	s4,s4,-1004 # ffffffffc0201ed8 <etext+0x146>
=======
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	49ec0c13          	addi	s8,s8,1182 # ffffffffc0201740 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	44e90913          	addi	s2,s2,1102 # ffffffffc02016f8 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	44e48493          	addi	s1,s1,1102 # ffffffffc0201700 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	44cb0b13          	addi	s6,s6,1100 # ffffffffc0201708 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	364a0a13          	addi	s4,s4,868 # ffffffffc0201628 <etext+0x140>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
<<<<<<< HEAD
ffffffffc02002d0:	15d010ef          	jal	ra,ffffffffc0201c2c <readline>
=======
ffffffffc02002d0:	0b2010ef          	jal	ra,ffffffffc0201382 <readline>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
<<<<<<< HEAD
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	d0ad0d13          	addi	s10,s10,-758 # ffffffffc0201ff0 <commands>
=======
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	45ad0d13          	addi	s10,s10,1114 # ffffffffc0201740 <commands>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
<<<<<<< HEAD
ffffffffc02002f4:	259010ef          	jal	ra,ffffffffc0201d4c <strcmp>
=======
ffffffffc02002f4:	1ae010ef          	jal	ra,ffffffffc02014a2 <strcmp>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
<<<<<<< HEAD
ffffffffc0200308:	245010ef          	jal	ra,ffffffffc0201d4c <strcmp>
=======
ffffffffc0200308:	19a010ef          	jal	ra,ffffffffc02014a2 <strcmp>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
<<<<<<< HEAD
ffffffffc0200346:	225010ef          	jal	ra,ffffffffc0201d6a <strchr>
=======
ffffffffc0200346:	17a010ef          	jal	ra,ffffffffc02014c0 <strchr>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
<<<<<<< HEAD
ffffffffc0200384:	1e7010ef          	jal	ra,ffffffffc0201d6a <strchr>
=======
ffffffffc0200384:	13c010ef          	jal	ra,ffffffffc02014c0 <strchr>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
<<<<<<< HEAD
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	c3a50513          	addi	a0,a0,-966 # ffffffffc0201fd8 <etext+0x246>
=======
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	38a50513          	addi	a0,a0,906 # ffffffffc0201728 <etext+0x240>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
<<<<<<< HEAD
ffffffffc02003b0:	1fc30313          	addi	t1,t1,508 # ffffffffc02065a8 <is_panic>
=======
ffffffffc02003b0:	16c30313          	addi	t1,t1,364 # ffffffffc0206518 <is_panic>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
<<<<<<< HEAD
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	c5e50513          	addi	a0,a0,-930 # ffffffffc0202038 <commands+0x48>
=======
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	3ae50513          	addi	a0,a0,942 # ffffffffc0201788 <commands+0x48>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
<<<<<<< HEAD
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	a9050513          	addi	a0,a0,-1392 # ffffffffc0201e80 <etext+0xee>
=======
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	1e050513          	addi	a0,a0,480 # ffffffffc02015d0 <etext+0xe8>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
<<<<<<< HEAD
ffffffffc0200420:	0db010ef          	jal	ra,ffffffffc0201cfa <sbi_set_timer>
=======
ffffffffc0200420:	030010ef          	jal	ra,ffffffffc0201450 <sbi_set_timer>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
<<<<<<< HEAD
ffffffffc020042a:	1807b523          	sd	zero,394(a5) # ffffffffc02065b0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	c2a50513          	addi	a0,a0,-982 # ffffffffc0202058 <commands+0x68>
=======
ffffffffc020042a:	0e07bd23          	sd	zero,250(a5) # ffffffffc0206520 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	37a50513          	addi	a0,a0,890 # ffffffffc02017a8 <commands+0x68>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
<<<<<<< HEAD
ffffffffc0200446:	0b50106f          	j	ffffffffc0201cfa <sbi_set_timer>
=======
ffffffffc0200446:	00a0106f          	j	ffffffffc0201450 <sbi_set_timer>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
<<<<<<< HEAD
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	0910106f          	j	ffffffffc0201ce0 <sbi_console_putchar>
=======
ffffffffc020044c:	0ff57513          	andi	a0,a0,255
ffffffffc0200450:	7e70006f          	j	ffffffffc0201436 <sbi_console_putchar>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
<<<<<<< HEAD
ffffffffc0200454:	0c10106f          	j	ffffffffc0201d14 <sbi_console_getchar>
=======
ffffffffc0200454:	0160106f          	j	ffffffffc020146a <sbi_console_getchar>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	36478793          	addi	a5,a5,868 # ffffffffc02007cc <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
<<<<<<< HEAD
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0202078 <commands+0x88>
=======
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	34a50513          	addi	a0,a0,842 # ffffffffc02017c8 <commands+0x88>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
<<<<<<< HEAD
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	c0250513          	addi	a0,a0,-1022 # ffffffffc0202090 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	c0c50513          	addi	a0,a0,-1012 # ffffffffc02020a8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	c1650513          	addi	a0,a0,-1002 # ffffffffc02020c0 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	c2050513          	addi	a0,a0,-992 # ffffffffc02020d8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	c2a50513          	addi	a0,a0,-982 # ffffffffc02020f0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	c3450513          	addi	a0,a0,-972 # ffffffffc0202108 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	c3e50513          	addi	a0,a0,-962 # ffffffffc0202120 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	c4850513          	addi	a0,a0,-952 # ffffffffc0202138 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	c5250513          	addi	a0,a0,-942 # ffffffffc0202150 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	c5c50513          	addi	a0,a0,-932 # ffffffffc0202168 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	c6650513          	addi	a0,a0,-922 # ffffffffc0202180 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	c7050513          	addi	a0,a0,-912 # ffffffffc0202198 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	c7a50513          	addi	a0,a0,-902 # ffffffffc02021b0 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	c8450513          	addi	a0,a0,-892 # ffffffffc02021c8 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	c8e50513          	addi	a0,a0,-882 # ffffffffc02021e0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	c9850513          	addi	a0,a0,-872 # ffffffffc02021f8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	ca250513          	addi	a0,a0,-862 # ffffffffc0202210 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	cac50513          	addi	a0,a0,-852 # ffffffffc0202228 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	cb650513          	addi	a0,a0,-842 # ffffffffc0202240 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	cc050513          	addi	a0,a0,-832 # ffffffffc0202258 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	cca50513          	addi	a0,a0,-822 # ffffffffc0202270 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	cd450513          	addi	a0,a0,-812 # ffffffffc0202288 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	cde50513          	addi	a0,a0,-802 # ffffffffc02022a0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	ce850513          	addi	a0,a0,-792 # ffffffffc02022b8 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	cf250513          	addi	a0,a0,-782 # ffffffffc02022d0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	cfc50513          	addi	a0,a0,-772 # ffffffffc02022e8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	d0650513          	addi	a0,a0,-762 # ffffffffc0202300 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	d1050513          	addi	a0,a0,-752 # ffffffffc0202318 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0202330 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	d2450513          	addi	a0,a0,-732 # ffffffffc0202348 <commands+0x358>
=======
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	35250513          	addi	a0,a0,850 # ffffffffc02017e0 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	35c50513          	addi	a0,a0,860 # ffffffffc02017f8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	36650513          	addi	a0,a0,870 # ffffffffc0201810 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	37050513          	addi	a0,a0,880 # ffffffffc0201828 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	37a50513          	addi	a0,a0,890 # ffffffffc0201840 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	38450513          	addi	a0,a0,900 # ffffffffc0201858 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	38e50513          	addi	a0,a0,910 # ffffffffc0201870 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	39850513          	addi	a0,a0,920 # ffffffffc0201888 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	3a250513          	addi	a0,a0,930 # ffffffffc02018a0 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	3ac50513          	addi	a0,a0,940 # ffffffffc02018b8 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	3b650513          	addi	a0,a0,950 # ffffffffc02018d0 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	3c050513          	addi	a0,a0,960 # ffffffffc02018e8 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	3ca50513          	addi	a0,a0,970 # ffffffffc0201900 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	3d450513          	addi	a0,a0,980 # ffffffffc0201918 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	3de50513          	addi	a0,a0,990 # ffffffffc0201930 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	3e850513          	addi	a0,a0,1000 # ffffffffc0201948 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	3f250513          	addi	a0,a0,1010 # ffffffffc0201960 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	3fc50513          	addi	a0,a0,1020 # ffffffffc0201978 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	40650513          	addi	a0,a0,1030 # ffffffffc0201990 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	41050513          	addi	a0,a0,1040 # ffffffffc02019a8 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	41a50513          	addi	a0,a0,1050 # ffffffffc02019c0 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	42450513          	addi	a0,a0,1060 # ffffffffc02019d8 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	42e50513          	addi	a0,a0,1070 # ffffffffc02019f0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	43850513          	addi	a0,a0,1080 # ffffffffc0201a08 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	44250513          	addi	a0,a0,1090 # ffffffffc0201a20 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	44c50513          	addi	a0,a0,1100 # ffffffffc0201a38 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	45650513          	addi	a0,a0,1110 # ffffffffc0201a50 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	46050513          	addi	a0,a0,1120 # ffffffffc0201a68 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	46a50513          	addi	a0,a0,1130 # ffffffffc0201a80 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	47450513          	addi	a0,a0,1140 # ffffffffc0201a98 <commands+0x358>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
<<<<<<< HEAD
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	d2a50513          	addi	a0,a0,-726 # ffffffffc0202360 <commands+0x370>
=======
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	47a50513          	addi	a0,a0,1146 # ffffffffc0201ab0 <commands+0x370>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
<<<<<<< HEAD
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	d2e50513          	addi	a0,a0,-722 # ffffffffc0202378 <commands+0x388>
=======
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	47e50513          	addi	a0,a0,1150 # ffffffffc0201ac8 <commands+0x388>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
<<<<<<< HEAD
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	d2e50513          	addi	a0,a0,-722 # ffffffffc0202390 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	d3650513          	addi	a0,a0,-714 # ffffffffc02023a8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	d3e50513          	addi	a0,a0,-706 # ffffffffc02023c0 <commands+0x3d0>
=======
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	47e50513          	addi	a0,a0,1150 # ffffffffc0201ae0 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	48650513          	addi	a0,a0,1158 # ffffffffc0201af8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	48e50513          	addi	a0,a0,1166 # ffffffffc0201b10 <commands+0x3d0>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
<<<<<<< HEAD
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	d4250513          	addi	a0,a0,-702 # ffffffffc02023d8 <commands+0x3e8>
=======
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	49250513          	addi	a0,a0,1170 # ffffffffc0201b28 <commands+0x3e8>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
<<<<<<< HEAD
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	e0870713          	addi	a4,a4,-504 # ffffffffc02024b8 <commands+0x4c8>
=======
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	55870713          	addi	a4,a4,1368 # ffffffffc0201c08 <commands+0x4c8>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
<<<<<<< HEAD
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	d8e50513          	addi	a0,a0,-626 # ffffffffc0202450 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	d6450513          	addi	a0,a0,-668 # ffffffffc0202430 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	d1a50513          	addi	a0,a0,-742 # ffffffffc02023f0 <commands+0x400>
=======
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	4de50513          	addi	a0,a0,1246 # ffffffffc0201ba0 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	4b450513          	addi	a0,a0,1204 # ffffffffc0201b80 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	46a50513          	addi	a0,a0,1130 # ffffffffc0201b40 <commands+0x400>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
<<<<<<< HEAD
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	d9050513          	addi	a0,a0,-624 # ffffffffc0202470 <commands+0x480>
=======
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	4e050513          	addi	a0,a0,1248 # ffffffffc0201bc0 <commands+0x480>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
<<<<<<< HEAD
ffffffffc02006f6:	ebe68693          	addi	a3,a3,-322 # ffffffffc02065b0 <ticks>
=======
ffffffffc02006f6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0206520 <ticks>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
<<<<<<< HEAD
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	d8850513          	addi	a0,a0,-632 # ffffffffc0202498 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	cf650513          	addi	a0,a0,-778 # ffffffffc0202410 <commands+0x420>
=======
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	4d850513          	addi	a0,a0,1240 # ffffffffc0201be8 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	44650513          	addi	a0,a0,1094 # ffffffffc0201b60 <commands+0x420>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
<<<<<<< HEAD
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	d5c50513          	addi	a0,a0,-676 # ffffffffc0202488 <commands+0x498>
=======
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201bd8 <commands+0x498>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020073c:	1141                	addi	sp,sp,-16
ffffffffc020073e:	e022                	sd	s0,0(sp)
ffffffffc0200740:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc0200742:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200744:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200746:	04e78663          	beq	a5,a4,ffffffffc0200792 <exception_handler+0x5a>
ffffffffc020074a:	02f76c63          	bltu	a4,a5,ffffffffc0200782 <exception_handler+0x4a>
ffffffffc020074e:	4709                	li	a4,2
ffffffffc0200750:	02e79563          	bne	a5,a4,ffffffffc020077a <exception_handler+0x42>
             /* LAB1 CHALLENGE3   2213109 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception Type: Illegal instruction\n");
<<<<<<< HEAD
ffffffffc0200754:	00002517          	auipc	a0,0x2
ffffffffc0200758:	d9450513          	addi	a0,a0,-620 # ffffffffc02024e8 <commands+0x4f8>
ffffffffc020075c:	957ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200760:	10843583          	ld	a1,264(s0)
ffffffffc0200764:	00002517          	auipc	a0,0x2
ffffffffc0200768:	dac50513          	addi	a0,a0,-596 # ffffffffc0202510 <commands+0x520>
=======
ffffffffc0200754:	00001517          	auipc	a0,0x1
ffffffffc0200758:	4e450513          	addi	a0,a0,1252 # ffffffffc0201c38 <commands+0x4f8>
ffffffffc020075c:	957ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200760:	10843583          	ld	a1,264(s0)
ffffffffc0200764:	00001517          	auipc	a0,0x1
ffffffffc0200768:	4fc50513          	addi	a0,a0,1276 # ffffffffc0201c60 <commands+0x520>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc020076c:	947ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc+=4;
ffffffffc0200770:	10843783          	ld	a5,264(s0)
ffffffffc0200774:	0791                	addi	a5,a5,4
ffffffffc0200776:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020077a:	60a2                	ld	ra,8(sp)
ffffffffc020077c:	6402                	ld	s0,0(sp)
ffffffffc020077e:	0141                	addi	sp,sp,16
ffffffffc0200780:	8082                	ret
    switch (tf->cause) {
ffffffffc0200782:	17f1                	addi	a5,a5,-4
ffffffffc0200784:	471d                	li	a4,7
ffffffffc0200786:	fef77ae3          	bgeu	a4,a5,ffffffffc020077a <exception_handler+0x42>
}
ffffffffc020078a:	6402                	ld	s0,0(sp)
ffffffffc020078c:	60a2                	ld	ra,8(sp)
ffffffffc020078e:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc0200790:	bd4d                	j	ffffffffc0200642 <print_trapframe>
            cprintf("Exception Type: breakpoint\n");
<<<<<<< HEAD
ffffffffc0200792:	00002517          	auipc	a0,0x2
ffffffffc0200796:	da650513          	addi	a0,a0,-602 # ffffffffc0202538 <commands+0x548>
ffffffffc020079a:	919ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc020079e:	10843583          	ld	a1,264(s0)
ffffffffc02007a2:	00002517          	auipc	a0,0x2
ffffffffc02007a6:	db650513          	addi	a0,a0,-586 # ffffffffc0202558 <commands+0x568>
=======
ffffffffc0200792:	00001517          	auipc	a0,0x1
ffffffffc0200796:	4f650513          	addi	a0,a0,1270 # ffffffffc0201c88 <commands+0x548>
ffffffffc020079a:	919ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc020079e:	10843583          	ld	a1,264(s0)
ffffffffc02007a2:	00001517          	auipc	a0,0x1
ffffffffc02007a6:	50650513          	addi	a0,a0,1286 # ffffffffc0201ca8 <commands+0x568>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
ffffffffc02007aa:	909ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc+=2;
ffffffffc02007ae:	10843783          	ld	a5,264(s0)
}
ffffffffc02007b2:	60a2                	ld	ra,8(sp)
            tf->epc+=2;
ffffffffc02007b4:	0789                	addi	a5,a5,2
ffffffffc02007b6:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007ba:	6402                	ld	s0,0(sp)
ffffffffc02007bc:	0141                	addi	sp,sp,16
ffffffffc02007be:	8082                	ret

ffffffffc02007c0 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	0007c363          	bltz	a5,ffffffffc02007ca <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02007c8:	bf85                	j	ffffffffc0200738 <exception_handler>
        interrupt_handler(tf);
ffffffffc02007ca:	bde1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc02007cc <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02007cc:	14011073          	csrw	sscratch,sp
ffffffffc02007d0:	712d                	addi	sp,sp,-288
ffffffffc02007d2:	e002                	sd	zero,0(sp)
ffffffffc02007d4:	e406                	sd	ra,8(sp)
ffffffffc02007d6:	ec0e                	sd	gp,24(sp)
ffffffffc02007d8:	f012                	sd	tp,32(sp)
ffffffffc02007da:	f416                	sd	t0,40(sp)
ffffffffc02007dc:	f81a                	sd	t1,48(sp)
ffffffffc02007de:	fc1e                	sd	t2,56(sp)
ffffffffc02007e0:	e0a2                	sd	s0,64(sp)
ffffffffc02007e2:	e4a6                	sd	s1,72(sp)
ffffffffc02007e4:	e8aa                	sd	a0,80(sp)
ffffffffc02007e6:	ecae                	sd	a1,88(sp)
ffffffffc02007e8:	f0b2                	sd	a2,96(sp)
ffffffffc02007ea:	f4b6                	sd	a3,104(sp)
ffffffffc02007ec:	f8ba                	sd	a4,112(sp)
ffffffffc02007ee:	fcbe                	sd	a5,120(sp)
ffffffffc02007f0:	e142                	sd	a6,128(sp)
ffffffffc02007f2:	e546                	sd	a7,136(sp)
ffffffffc02007f4:	e94a                	sd	s2,144(sp)
ffffffffc02007f6:	ed4e                	sd	s3,152(sp)
ffffffffc02007f8:	f152                	sd	s4,160(sp)
ffffffffc02007fa:	f556                	sd	s5,168(sp)
ffffffffc02007fc:	f95a                	sd	s6,176(sp)
ffffffffc02007fe:	fd5e                	sd	s7,184(sp)
ffffffffc0200800:	e1e2                	sd	s8,192(sp)
ffffffffc0200802:	e5e6                	sd	s9,200(sp)
ffffffffc0200804:	e9ea                	sd	s10,208(sp)
ffffffffc0200806:	edee                	sd	s11,216(sp)
ffffffffc0200808:	f1f2                	sd	t3,224(sp)
ffffffffc020080a:	f5f6                	sd	t4,232(sp)
ffffffffc020080c:	f9fa                	sd	t5,240(sp)
ffffffffc020080e:	fdfe                	sd	t6,248(sp)
ffffffffc0200810:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200814:	100024f3          	csrr	s1,sstatus
ffffffffc0200818:	14102973          	csrr	s2,sepc
ffffffffc020081c:	143029f3          	csrr	s3,stval
ffffffffc0200820:	14202a73          	csrr	s4,scause
ffffffffc0200824:	e822                	sd	s0,16(sp)
ffffffffc0200826:	e226                	sd	s1,256(sp)
ffffffffc0200828:	e64a                	sd	s2,264(sp)
ffffffffc020082a:	ea4e                	sd	s3,272(sp)
ffffffffc020082c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc020082e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200830:	f91ff0ef          	jal	ra,ffffffffc02007c0 <trap>

ffffffffc0200834 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200834:	6492                	ld	s1,256(sp)
ffffffffc0200836:	6932                	ld	s2,264(sp)
ffffffffc0200838:	10049073          	csrw	sstatus,s1
ffffffffc020083c:	14191073          	csrw	sepc,s2
ffffffffc0200840:	60a2                	ld	ra,8(sp)
ffffffffc0200842:	61e2                	ld	gp,24(sp)
ffffffffc0200844:	7202                	ld	tp,32(sp)
ffffffffc0200846:	72a2                	ld	t0,40(sp)
ffffffffc0200848:	7342                	ld	t1,48(sp)
ffffffffc020084a:	73e2                	ld	t2,56(sp)
ffffffffc020084c:	6406                	ld	s0,64(sp)
ffffffffc020084e:	64a6                	ld	s1,72(sp)
ffffffffc0200850:	6546                	ld	a0,80(sp)
ffffffffc0200852:	65e6                	ld	a1,88(sp)
ffffffffc0200854:	7606                	ld	a2,96(sp)
ffffffffc0200856:	76a6                	ld	a3,104(sp)
ffffffffc0200858:	7746                	ld	a4,112(sp)
ffffffffc020085a:	77e6                	ld	a5,120(sp)
ffffffffc020085c:	680a                	ld	a6,128(sp)
ffffffffc020085e:	68aa                	ld	a7,136(sp)
ffffffffc0200860:	694a                	ld	s2,144(sp)
ffffffffc0200862:	69ea                	ld	s3,152(sp)
ffffffffc0200864:	7a0a                	ld	s4,160(sp)
ffffffffc0200866:	7aaa                	ld	s5,168(sp)
ffffffffc0200868:	7b4a                	ld	s6,176(sp)
ffffffffc020086a:	7bea                	ld	s7,184(sp)
ffffffffc020086c:	6c0e                	ld	s8,192(sp)
ffffffffc020086e:	6cae                	ld	s9,200(sp)
ffffffffc0200870:	6d4e                	ld	s10,208(sp)
ffffffffc0200872:	6dee                	ld	s11,216(sp)
ffffffffc0200874:	7e0e                	ld	t3,224(sp)
ffffffffc0200876:	7eae                	ld	t4,232(sp)
ffffffffc0200878:	7f4e                	ld	t5,240(sp)
ffffffffc020087a:	7fee                	ld	t6,248(sp)
ffffffffc020087c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020087e:	10200073          	sret

<<<<<<< HEAD
ffffffffc0200882 <default_init>:
=======
ffffffffc0200882 <buddy_system_init>:
#define nr_free(i) buddy_system_free_area[(i)].nr_free

// 初始化 Buddy 系统，设置所有层级的空闲列表和空闲块数量
static void buddy_system_init(void) 
{   
    for(int level = 0; level < BuddyMaxLevel; level++) // 遍历所有的管理层级，从 0 到 BuddyMaxLevel-1
ffffffffc0200882:	00005797          	auipc	a5,0x5
ffffffffc0200886:	78e78793          	addi	a5,a5,1934 # ffffffffc0206010 <buddy_system_free_area>
ffffffffc020088a:	00006717          	auipc	a4,0x6
ffffffffc020088e:	88e70713          	addi	a4,a4,-1906 # ffffffffc0206118 <buf>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
<<<<<<< HEAD
ffffffffc0200882:	00005797          	auipc	a5,0x5
ffffffffc0200886:	78e78793          	addi	a5,a5,1934 # ffffffffc0206010 <free_area>
ffffffffc020088a:	e79c                	sd	a5,8(a5)
ffffffffc020088c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020088e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200892:	8082                	ret

ffffffffc0200894 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200894:	00005517          	auipc	a0,0x5
ffffffffc0200898:	78c56503          	lwu	a0,1932(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020089c:	8082                	ret

ffffffffc020089e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020089e:	715d                	addi	sp,sp,-80
ffffffffc02008a0:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008a2:	00005417          	auipc	s0,0x5
ffffffffc02008a6:	76e40413          	addi	s0,s0,1902 # ffffffffc0206010 <free_area>
ffffffffc02008aa:	641c                	ld	a5,8(s0)
ffffffffc02008ac:	e486                	sd	ra,72(sp)
ffffffffc02008ae:	fc26                	sd	s1,56(sp)
ffffffffc02008b0:	f84a                	sd	s2,48(sp)
ffffffffc02008b2:	f44e                	sd	s3,40(sp)
ffffffffc02008b4:	f052                	sd	s4,32(sp)
ffffffffc02008b6:	ec56                	sd	s5,24(sp)
ffffffffc02008b8:	e85a                	sd	s6,16(sp)
ffffffffc02008ba:	e45e                	sd	s7,8(sp)
ffffffffc02008bc:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008be:	2c878763          	beq	a5,s0,ffffffffc0200b8c <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc02008c2:	4481                	li	s1,0
ffffffffc02008c4:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02008c6:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02008ca:	8b09                	andi	a4,a4,2
ffffffffc02008cc:	2c070463          	beqz	a4,ffffffffc0200b94 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc02008d0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02008d4:	679c                	ld	a5,8(a5)
ffffffffc02008d6:	2905                	addiw	s2,s2,1
ffffffffc02008d8:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008da:	fe8796e3          	bne	a5,s0,ffffffffc02008c6 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02008de:	89a6                	mv	s3,s1
ffffffffc02008e0:	2f9000ef          	jal	ra,ffffffffc02013d8 <nr_free_pages>
ffffffffc02008e4:	71351863          	bne	a0,s3,ffffffffc0200ff4 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008e8:	4505                	li	a0,1
ffffffffc02008ea:	271000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc02008ee:	8a2a                	mv	s4,a0
ffffffffc02008f0:	44050263          	beqz	a0,ffffffffc0200d34 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02008f4:	4505                	li	a0,1
ffffffffc02008f6:	265000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc02008fa:	89aa                	mv	s3,a0
ffffffffc02008fc:	70050c63          	beqz	a0,ffffffffc0201014 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200900:	4505                	li	a0,1
ffffffffc0200902:	259000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200906:	8aaa                	mv	s5,a0
ffffffffc0200908:	4a050663          	beqz	a0,ffffffffc0200db4 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020090c:	2b3a0463          	beq	s4,s3,ffffffffc0200bb4 <default_check+0x316>
ffffffffc0200910:	2aaa0263          	beq	s4,a0,ffffffffc0200bb4 <default_check+0x316>
ffffffffc0200914:	2aa98063          	beq	s3,a0,ffffffffc0200bb4 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200918:	000a2783          	lw	a5,0(s4)
ffffffffc020091c:	2a079c63          	bnez	a5,ffffffffc0200bd4 <default_check+0x336>
ffffffffc0200920:	0009a783          	lw	a5,0(s3)
ffffffffc0200924:	2a079863          	bnez	a5,ffffffffc0200bd4 <default_check+0x336>
ffffffffc0200928:	411c                	lw	a5,0(a0)
ffffffffc020092a:	2a079563          	bnez	a5,ffffffffc0200bd4 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020092e:	00006797          	auipc	a5,0x6
ffffffffc0200932:	c927b783          	ld	a5,-878(a5) # ffffffffc02065c0 <pages>
ffffffffc0200936:	40fa0733          	sub	a4,s4,a5
ffffffffc020093a:	870d                	srai	a4,a4,0x3
ffffffffc020093c:	00002597          	auipc	a1,0x2
ffffffffc0200940:	4ac5b583          	ld	a1,1196(a1) # ffffffffc0202de8 <error_string+0x38>
ffffffffc0200944:	02b70733          	mul	a4,a4,a1
ffffffffc0200948:	00002617          	auipc	a2,0x2
ffffffffc020094c:	4a863603          	ld	a2,1192(a2) # ffffffffc0202df0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200950:	00006697          	auipc	a3,0x6
ffffffffc0200954:	c686b683          	ld	a3,-920(a3) # ffffffffc02065b8 <npage>
ffffffffc0200958:	06b2                	slli	a3,a3,0xc
ffffffffc020095a:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc020095c:	0732                	slli	a4,a4,0xc
ffffffffc020095e:	28d77b63          	bgeu	a4,a3,ffffffffc0200bf4 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200962:	40f98733          	sub	a4,s3,a5
ffffffffc0200966:	870d                	srai	a4,a4,0x3
ffffffffc0200968:	02b70733          	mul	a4,a4,a1
ffffffffc020096c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020096e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200970:	4cd77263          	bgeu	a4,a3,ffffffffc0200e34 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200974:	40f507b3          	sub	a5,a0,a5
ffffffffc0200978:	878d                	srai	a5,a5,0x3
ffffffffc020097a:	02b787b3          	mul	a5,a5,a1
ffffffffc020097e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200980:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200982:	30d7f963          	bgeu	a5,a3,ffffffffc0200c94 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200986:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200988:	00043c03          	ld	s8,0(s0)
ffffffffc020098c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200990:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200994:	e400                	sd	s0,8(s0)
ffffffffc0200996:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200998:	00005797          	auipc	a5,0x5
ffffffffc020099c:	6807a423          	sw	zero,1672(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02009a0:	1bb000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc02009a4:	2c051863          	bnez	a0,ffffffffc0200c74 <default_check+0x3d6>
    free_page(p0);
ffffffffc02009a8:	4585                	li	a1,1
ffffffffc02009aa:	8552                	mv	a0,s4
ffffffffc02009ac:	1ed000ef          	jal	ra,ffffffffc0201398 <free_pages>
    free_page(p1);
ffffffffc02009b0:	4585                	li	a1,1
ffffffffc02009b2:	854e                	mv	a0,s3
ffffffffc02009b4:	1e5000ef          	jal	ra,ffffffffc0201398 <free_pages>
    free_page(p2);
ffffffffc02009b8:	4585                	li	a1,1
ffffffffc02009ba:	8556                	mv	a0,s5
ffffffffc02009bc:	1dd000ef          	jal	ra,ffffffffc0201398 <free_pages>
    assert(nr_free == 3);
ffffffffc02009c0:	4818                	lw	a4,16(s0)
ffffffffc02009c2:	478d                	li	a5,3
ffffffffc02009c4:	28f71863          	bne	a4,a5,ffffffffc0200c54 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02009c8:	4505                	li	a0,1
ffffffffc02009ca:	191000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc02009ce:	89aa                	mv	s3,a0
ffffffffc02009d0:	26050263          	beqz	a0,ffffffffc0200c34 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009d4:	4505                	li	a0,1
ffffffffc02009d6:	185000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc02009da:	8aaa                	mv	s5,a0
ffffffffc02009dc:	3a050c63          	beqz	a0,ffffffffc0200d94 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009e0:	4505                	li	a0,1
ffffffffc02009e2:	179000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc02009e6:	8a2a                	mv	s4,a0
ffffffffc02009e8:	38050663          	beqz	a0,ffffffffc0200d74 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc02009ec:	4505                	li	a0,1
ffffffffc02009ee:	16d000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc02009f2:	36051163          	bnez	a0,ffffffffc0200d54 <default_check+0x4b6>
    free_page(p0);
ffffffffc02009f6:	4585                	li	a1,1
ffffffffc02009f8:	854e                	mv	a0,s3
ffffffffc02009fa:	19f000ef          	jal	ra,ffffffffc0201398 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02009fe:	641c                	ld	a5,8(s0)
ffffffffc0200a00:	20878a63          	beq	a5,s0,ffffffffc0200c14 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200a04:	4505                	li	a0,1
ffffffffc0200a06:	155000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200a0a:	30a99563          	bne	s3,a0,ffffffffc0200d14 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200a0e:	4505                	li	a0,1
ffffffffc0200a10:	14b000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200a14:	2e051063          	bnez	a0,ffffffffc0200cf4 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200a18:	481c                	lw	a5,16(s0)
ffffffffc0200a1a:	2a079d63          	bnez	a5,ffffffffc0200cd4 <default_check+0x436>
    free_page(p);
ffffffffc0200a1e:	854e                	mv	a0,s3
ffffffffc0200a20:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a22:	01843023          	sd	s8,0(s0)
ffffffffc0200a26:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200a2a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200a2e:	16b000ef          	jal	ra,ffffffffc0201398 <free_pages>
    free_page(p1);
ffffffffc0200a32:	4585                	li	a1,1
ffffffffc0200a34:	8556                	mv	a0,s5
ffffffffc0200a36:	163000ef          	jal	ra,ffffffffc0201398 <free_pages>
    free_page(p2);
ffffffffc0200a3a:	4585                	li	a1,1
ffffffffc0200a3c:	8552                	mv	a0,s4
ffffffffc0200a3e:	15b000ef          	jal	ra,ffffffffc0201398 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a42:	4515                	li	a0,5
ffffffffc0200a44:	117000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200a48:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a4a:	26050563          	beqz	a0,ffffffffc0200cb4 <default_check+0x416>
ffffffffc0200a4e:	651c                	ld	a5,8(a0)
ffffffffc0200a50:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a52:	8b85                	andi	a5,a5,1
ffffffffc0200a54:	54079063          	bnez	a5,ffffffffc0200f94 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a58:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a5a:	00043b03          	ld	s6,0(s0)
ffffffffc0200a5e:	00843a83          	ld	s5,8(s0)
ffffffffc0200a62:	e000                	sd	s0,0(s0)
ffffffffc0200a64:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200a66:	0f5000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200a6a:	50051563          	bnez	a0,ffffffffc0200f74 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200a6e:	05098a13          	addi	s4,s3,80
ffffffffc0200a72:	8552                	mv	a0,s4
ffffffffc0200a74:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200a76:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200a7a:	00005797          	auipc	a5,0x5
ffffffffc0200a7e:	5a07a323          	sw	zero,1446(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200a82:	117000ef          	jal	ra,ffffffffc0201398 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a86:	4511                	li	a0,4
ffffffffc0200a88:	0d3000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200a8c:	4c051463          	bnez	a0,ffffffffc0200f54 <default_check+0x6b6>
ffffffffc0200a90:	0589b783          	ld	a5,88(s3)
ffffffffc0200a94:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200a96:	8b85                	andi	a5,a5,1
ffffffffc0200a98:	48078e63          	beqz	a5,ffffffffc0200f34 <default_check+0x696>
ffffffffc0200a9c:	0609a703          	lw	a4,96(s3)
ffffffffc0200aa0:	478d                	li	a5,3
ffffffffc0200aa2:	48f71963          	bne	a4,a5,ffffffffc0200f34 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200aa6:	450d                	li	a0,3
ffffffffc0200aa8:	0b3000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200aac:	8c2a                	mv	s8,a0
ffffffffc0200aae:	46050363          	beqz	a0,ffffffffc0200f14 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200ab2:	4505                	li	a0,1
ffffffffc0200ab4:	0a7000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200ab8:	42051e63          	bnez	a0,ffffffffc0200ef4 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200abc:	418a1c63          	bne	s4,s8,ffffffffc0200ed4 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200ac0:	4585                	li	a1,1
ffffffffc0200ac2:	854e                	mv	a0,s3
ffffffffc0200ac4:	0d5000ef          	jal	ra,ffffffffc0201398 <free_pages>
    free_pages(p1, 3);
ffffffffc0200ac8:	458d                	li	a1,3
ffffffffc0200aca:	8552                	mv	a0,s4
ffffffffc0200acc:	0cd000ef          	jal	ra,ffffffffc0201398 <free_pages>
ffffffffc0200ad0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200ad4:	02898c13          	addi	s8,s3,40
ffffffffc0200ad8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200ada:	8b85                	andi	a5,a5,1
ffffffffc0200adc:	3c078c63          	beqz	a5,ffffffffc0200eb4 <default_check+0x616>
ffffffffc0200ae0:	0109a703          	lw	a4,16(s3)
ffffffffc0200ae4:	4785                	li	a5,1
ffffffffc0200ae6:	3cf71763          	bne	a4,a5,ffffffffc0200eb4 <default_check+0x616>
ffffffffc0200aea:	008a3783          	ld	a5,8(s4)
ffffffffc0200aee:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200af0:	8b85                	andi	a5,a5,1
ffffffffc0200af2:	3a078163          	beqz	a5,ffffffffc0200e94 <default_check+0x5f6>
ffffffffc0200af6:	010a2703          	lw	a4,16(s4)
ffffffffc0200afa:	478d                	li	a5,3
ffffffffc0200afc:	38f71c63          	bne	a4,a5,ffffffffc0200e94 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200b00:	4505                	li	a0,1
ffffffffc0200b02:	059000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200b06:	36a99763          	bne	s3,a0,ffffffffc0200e74 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200b0a:	4585                	li	a1,1
ffffffffc0200b0c:	08d000ef          	jal	ra,ffffffffc0201398 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200b10:	4509                	li	a0,2
ffffffffc0200b12:	049000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200b16:	32aa1f63          	bne	s4,a0,ffffffffc0200e54 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200b1a:	4589                	li	a1,2
ffffffffc0200b1c:	07d000ef          	jal	ra,ffffffffc0201398 <free_pages>
    free_page(p2);
ffffffffc0200b20:	4585                	li	a1,1
ffffffffc0200b22:	8562                	mv	a0,s8
ffffffffc0200b24:	075000ef          	jal	ra,ffffffffc0201398 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b28:	4515                	li	a0,5
ffffffffc0200b2a:	031000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200b2e:	89aa                	mv	s3,a0
ffffffffc0200b30:	48050263          	beqz	a0,ffffffffc0200fb4 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200b34:	4505                	li	a0,1
ffffffffc0200b36:	025000ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0200b3a:	2c051d63          	bnez	a0,ffffffffc0200e14 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200b3e:	481c                	lw	a5,16(s0)
ffffffffc0200b40:	2a079a63          	bnez	a5,ffffffffc0200df4 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b44:	4595                	li	a1,5
ffffffffc0200b46:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b48:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200b4c:	01643023          	sd	s6,0(s0)
ffffffffc0200b50:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200b54:	045000ef          	jal	ra,ffffffffc0201398 <free_pages>
    return listelm->next;
ffffffffc0200b58:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b5a:	00878963          	beq	a5,s0,ffffffffc0200b6c <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b5e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b62:	679c                	ld	a5,8(a5)
ffffffffc0200b64:	397d                	addiw	s2,s2,-1
ffffffffc0200b66:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b68:	fe879be3          	bne	a5,s0,ffffffffc0200b5e <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200b6c:	26091463          	bnez	s2,ffffffffc0200dd4 <default_check+0x536>
    assert(total == 0);
ffffffffc0200b70:	46049263          	bnez	s1,ffffffffc0200fd4 <default_check+0x736>
}
ffffffffc0200b74:	60a6                	ld	ra,72(sp)
ffffffffc0200b76:	6406                	ld	s0,64(sp)
ffffffffc0200b78:	74e2                	ld	s1,56(sp)
ffffffffc0200b7a:	7942                	ld	s2,48(sp)
ffffffffc0200b7c:	79a2                	ld	s3,40(sp)
ffffffffc0200b7e:	7a02                	ld	s4,32(sp)
ffffffffc0200b80:	6ae2                	ld	s5,24(sp)
ffffffffc0200b82:	6b42                	ld	s6,16(sp)
ffffffffc0200b84:	6ba2                	ld	s7,8(sp)
ffffffffc0200b86:	6c02                	ld	s8,0(sp)
ffffffffc0200b88:	6161                	addi	sp,sp,80
ffffffffc0200b8a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b8c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b8e:	4481                	li	s1,0
ffffffffc0200b90:	4901                	li	s2,0
ffffffffc0200b92:	b3b9                	j	ffffffffc02008e0 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200b94:	00002697          	auipc	a3,0x2
ffffffffc0200b98:	9e468693          	addi	a3,a3,-1564 # ffffffffc0202578 <commands+0x588>
ffffffffc0200b9c:	00002617          	auipc	a2,0x2
ffffffffc0200ba0:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0202588 <commands+0x598>
ffffffffc0200ba4:	0ef00593          	li	a1,239
ffffffffc0200ba8:	00002517          	auipc	a0,0x2
ffffffffc0200bac:	9f850513          	addi	a0,a0,-1544 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200bb0:	ffcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bb4:	00002697          	auipc	a3,0x2
ffffffffc0200bb8:	a8468693          	addi	a3,a3,-1404 # ffffffffc0202638 <commands+0x648>
ffffffffc0200bbc:	00002617          	auipc	a2,0x2
ffffffffc0200bc0:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0202588 <commands+0x598>
ffffffffc0200bc4:	0bc00593          	li	a1,188
ffffffffc0200bc8:	00002517          	auipc	a0,0x2
ffffffffc0200bcc:	9d850513          	addi	a0,a0,-1576 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200bd0:	fdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bd4:	00002697          	auipc	a3,0x2
ffffffffc0200bd8:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0202660 <commands+0x670>
ffffffffc0200bdc:	00002617          	auipc	a2,0x2
ffffffffc0200be0:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0202588 <commands+0x598>
ffffffffc0200be4:	0bd00593          	li	a1,189
ffffffffc0200be8:	00002517          	auipc	a0,0x2
ffffffffc0200bec:	9b850513          	addi	a0,a0,-1608 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200bf0:	fbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bf4:	00002697          	auipc	a3,0x2
ffffffffc0200bf8:	aac68693          	addi	a3,a3,-1364 # ffffffffc02026a0 <commands+0x6b0>
ffffffffc0200bfc:	00002617          	auipc	a2,0x2
ffffffffc0200c00:	98c60613          	addi	a2,a2,-1652 # ffffffffc0202588 <commands+0x598>
ffffffffc0200c04:	0bf00593          	li	a1,191
ffffffffc0200c08:	00002517          	auipc	a0,0x2
ffffffffc0200c0c:	99850513          	addi	a0,a0,-1640 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200c10:	f9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c14:	00002697          	auipc	a3,0x2
ffffffffc0200c18:	b1468693          	addi	a3,a3,-1260 # ffffffffc0202728 <commands+0x738>
ffffffffc0200c1c:	00002617          	auipc	a2,0x2
ffffffffc0200c20:	96c60613          	addi	a2,a2,-1684 # ffffffffc0202588 <commands+0x598>
ffffffffc0200c24:	0d800593          	li	a1,216
ffffffffc0200c28:	00002517          	auipc	a0,0x2
ffffffffc0200c2c:	97850513          	addi	a0,a0,-1672 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200c30:	f7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c34:	00002697          	auipc	a3,0x2
ffffffffc0200c38:	9a468693          	addi	a3,a3,-1628 # ffffffffc02025d8 <commands+0x5e8>
ffffffffc0200c3c:	00002617          	auipc	a2,0x2
ffffffffc0200c40:	94c60613          	addi	a2,a2,-1716 # ffffffffc0202588 <commands+0x598>
ffffffffc0200c44:	0d100593          	li	a1,209
ffffffffc0200c48:	00002517          	auipc	a0,0x2
ffffffffc0200c4c:	95850513          	addi	a0,a0,-1704 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200c50:	f5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200c54:	00002697          	auipc	a3,0x2
ffffffffc0200c58:	ac468693          	addi	a3,a3,-1340 # ffffffffc0202718 <commands+0x728>
ffffffffc0200c5c:	00002617          	auipc	a2,0x2
ffffffffc0200c60:	92c60613          	addi	a2,a2,-1748 # ffffffffc0202588 <commands+0x598>
ffffffffc0200c64:	0cf00593          	li	a1,207
ffffffffc0200c68:	00002517          	auipc	a0,0x2
ffffffffc0200c6c:	93850513          	addi	a0,a0,-1736 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200c70:	f3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c74:	00002697          	auipc	a3,0x2
ffffffffc0200c78:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0202700 <commands+0x710>
ffffffffc0200c7c:	00002617          	auipc	a2,0x2
ffffffffc0200c80:	90c60613          	addi	a2,a2,-1780 # ffffffffc0202588 <commands+0x598>
ffffffffc0200c84:	0ca00593          	li	a1,202
ffffffffc0200c88:	00002517          	auipc	a0,0x2
ffffffffc0200c8c:	91850513          	addi	a0,a0,-1768 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200c90:	f1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c94:	00002697          	auipc	a3,0x2
ffffffffc0200c98:	a4c68693          	addi	a3,a3,-1460 # ffffffffc02026e0 <commands+0x6f0>
ffffffffc0200c9c:	00002617          	auipc	a2,0x2
ffffffffc0200ca0:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0202588 <commands+0x598>
ffffffffc0200ca4:	0c100593          	li	a1,193
ffffffffc0200ca8:	00002517          	auipc	a0,0x2
ffffffffc0200cac:	8f850513          	addi	a0,a0,-1800 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200cb0:	efcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200cb4:	00002697          	auipc	a3,0x2
ffffffffc0200cb8:	abc68693          	addi	a3,a3,-1348 # ffffffffc0202770 <commands+0x780>
ffffffffc0200cbc:	00002617          	auipc	a2,0x2
ffffffffc0200cc0:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0202588 <commands+0x598>
ffffffffc0200cc4:	0f700593          	li	a1,247
ffffffffc0200cc8:	00002517          	auipc	a0,0x2
ffffffffc0200ccc:	8d850513          	addi	a0,a0,-1832 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200cd0:	edcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200cd4:	00002697          	auipc	a3,0x2
ffffffffc0200cd8:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0202760 <commands+0x770>
ffffffffc0200cdc:	00002617          	auipc	a2,0x2
ffffffffc0200ce0:	8ac60613          	addi	a2,a2,-1876 # ffffffffc0202588 <commands+0x598>
ffffffffc0200ce4:	0de00593          	li	a1,222
ffffffffc0200ce8:	00002517          	auipc	a0,0x2
ffffffffc0200cec:	8b850513          	addi	a0,a0,-1864 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200cf0:	ebcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cf4:	00002697          	auipc	a3,0x2
ffffffffc0200cf8:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0202700 <commands+0x710>
ffffffffc0200cfc:	00002617          	auipc	a2,0x2
ffffffffc0200d00:	88c60613          	addi	a2,a2,-1908 # ffffffffc0202588 <commands+0x598>
ffffffffc0200d04:	0dc00593          	li	a1,220
ffffffffc0200d08:	00002517          	auipc	a0,0x2
ffffffffc0200d0c:	89850513          	addi	a0,a0,-1896 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200d10:	e9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200d14:	00002697          	auipc	a3,0x2
ffffffffc0200d18:	a2c68693          	addi	a3,a3,-1492 # ffffffffc0202740 <commands+0x750>
ffffffffc0200d1c:	00002617          	auipc	a2,0x2
ffffffffc0200d20:	86c60613          	addi	a2,a2,-1940 # ffffffffc0202588 <commands+0x598>
ffffffffc0200d24:	0db00593          	li	a1,219
ffffffffc0200d28:	00002517          	auipc	a0,0x2
ffffffffc0200d2c:	87850513          	addi	a0,a0,-1928 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200d30:	e7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d34:	00002697          	auipc	a3,0x2
ffffffffc0200d38:	8a468693          	addi	a3,a3,-1884 # ffffffffc02025d8 <commands+0x5e8>
ffffffffc0200d3c:	00002617          	auipc	a2,0x2
ffffffffc0200d40:	84c60613          	addi	a2,a2,-1972 # ffffffffc0202588 <commands+0x598>
ffffffffc0200d44:	0b800593          	li	a1,184
ffffffffc0200d48:	00002517          	auipc	a0,0x2
ffffffffc0200d4c:	85850513          	addi	a0,a0,-1960 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200d50:	e5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d54:	00002697          	auipc	a3,0x2
ffffffffc0200d58:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0202700 <commands+0x710>
ffffffffc0200d5c:	00002617          	auipc	a2,0x2
ffffffffc0200d60:	82c60613          	addi	a2,a2,-2004 # ffffffffc0202588 <commands+0x598>
ffffffffc0200d64:	0d500593          	li	a1,213
ffffffffc0200d68:	00002517          	auipc	a0,0x2
ffffffffc0200d6c:	83850513          	addi	a0,a0,-1992 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200d70:	e3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d74:	00002697          	auipc	a3,0x2
ffffffffc0200d78:	8a468693          	addi	a3,a3,-1884 # ffffffffc0202618 <commands+0x628>
ffffffffc0200d7c:	00002617          	auipc	a2,0x2
ffffffffc0200d80:	80c60613          	addi	a2,a2,-2036 # ffffffffc0202588 <commands+0x598>
ffffffffc0200d84:	0d300593          	li	a1,211
ffffffffc0200d88:	00002517          	auipc	a0,0x2
ffffffffc0200d8c:	81850513          	addi	a0,a0,-2024 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200d90:	e1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d94:	00002697          	auipc	a3,0x2
ffffffffc0200d98:	86468693          	addi	a3,a3,-1948 # ffffffffc02025f8 <commands+0x608>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	7ec60613          	addi	a2,a2,2028 # ffffffffc0202588 <commands+0x598>
ffffffffc0200da4:	0d200593          	li	a1,210
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	7f850513          	addi	a0,a0,2040 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200db0:	dfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200db4:	00002697          	auipc	a3,0x2
ffffffffc0200db8:	86468693          	addi	a3,a3,-1948 # ffffffffc0202618 <commands+0x628>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	7cc60613          	addi	a2,a2,1996 # ffffffffc0202588 <commands+0x598>
ffffffffc0200dc4:	0ba00593          	li	a1,186
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	7d850513          	addi	a0,a0,2008 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200dd0:	ddcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200dd4:	00002697          	auipc	a3,0x2
ffffffffc0200dd8:	aec68693          	addi	a3,a3,-1300 # ffffffffc02028c0 <commands+0x8d0>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	7ac60613          	addi	a2,a2,1964 # ffffffffc0202588 <commands+0x598>
ffffffffc0200de4:	12400593          	li	a1,292
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	7b850513          	addi	a0,a0,1976 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200df0:	dbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200df4:	00002697          	auipc	a3,0x2
ffffffffc0200df8:	96c68693          	addi	a3,a3,-1684 # ffffffffc0202760 <commands+0x770>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	78c60613          	addi	a2,a2,1932 # ffffffffc0202588 <commands+0x598>
ffffffffc0200e04:	11900593          	li	a1,281
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	79850513          	addi	a0,a0,1944 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200e10:	d9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e14:	00002697          	auipc	a3,0x2
ffffffffc0200e18:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0202700 <commands+0x710>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	76c60613          	addi	a2,a2,1900 # ffffffffc0202588 <commands+0x598>
ffffffffc0200e24:	11700593          	li	a1,279
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	77850513          	addi	a0,a0,1912 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200e30:	d7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e34:	00002697          	auipc	a3,0x2
ffffffffc0200e38:	88c68693          	addi	a3,a3,-1908 # ffffffffc02026c0 <commands+0x6d0>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	74c60613          	addi	a2,a2,1868 # ffffffffc0202588 <commands+0x598>
ffffffffc0200e44:	0c000593          	li	a1,192
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	75850513          	addi	a0,a0,1880 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200e50:	d5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e54:	00002697          	auipc	a3,0x2
ffffffffc0200e58:	a2c68693          	addi	a3,a3,-1492 # ffffffffc0202880 <commands+0x890>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	72c60613          	addi	a2,a2,1836 # ffffffffc0202588 <commands+0x598>
ffffffffc0200e64:	11100593          	li	a1,273
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	73850513          	addi	a0,a0,1848 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200e70:	d3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e74:	00002697          	auipc	a3,0x2
ffffffffc0200e78:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0202860 <commands+0x870>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	70c60613          	addi	a2,a2,1804 # ffffffffc0202588 <commands+0x598>
ffffffffc0200e84:	10f00593          	li	a1,271
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	71850513          	addi	a0,a0,1816 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200e90:	d1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e94:	00002697          	auipc	a3,0x2
ffffffffc0200e98:	9a468693          	addi	a3,a3,-1628 # ffffffffc0202838 <commands+0x848>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	6ec60613          	addi	a2,a2,1772 # ffffffffc0202588 <commands+0x598>
ffffffffc0200ea4:	10d00593          	li	a1,269
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	6f850513          	addi	a0,a0,1784 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200eb0:	cfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200eb4:	00002697          	auipc	a3,0x2
ffffffffc0200eb8:	95c68693          	addi	a3,a3,-1700 # ffffffffc0202810 <commands+0x820>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	6cc60613          	addi	a2,a2,1740 # ffffffffc0202588 <commands+0x598>
ffffffffc0200ec4:	10c00593          	li	a1,268
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	6d850513          	addi	a0,a0,1752 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200ed0:	cdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 2 == p1);
ffffffffc0200ed4:	00002697          	auipc	a3,0x2
ffffffffc0200ed8:	92c68693          	addi	a3,a3,-1748 # ffffffffc0202800 <commands+0x810>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	6ac60613          	addi	a2,a2,1708 # ffffffffc0202588 <commands+0x598>
ffffffffc0200ee4:	10700593          	li	a1,263
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	6b850513          	addi	a0,a0,1720 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200ef0:	cbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ef4:	00002697          	auipc	a3,0x2
ffffffffc0200ef8:	80c68693          	addi	a3,a3,-2036 # ffffffffc0202700 <commands+0x710>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	68c60613          	addi	a2,a2,1676 # ffffffffc0202588 <commands+0x598>
ffffffffc0200f04:	10600593          	li	a1,262
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	69850513          	addi	a0,a0,1688 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200f10:	c9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200f14:	00002697          	auipc	a3,0x2
ffffffffc0200f18:	8cc68693          	addi	a3,a3,-1844 # ffffffffc02027e0 <commands+0x7f0>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	66c60613          	addi	a2,a2,1644 # ffffffffc0202588 <commands+0x598>
ffffffffc0200f24:	10500593          	li	a1,261
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	67850513          	addi	a0,a0,1656 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200f30:	c7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200f34:	00002697          	auipc	a3,0x2
ffffffffc0200f38:	87c68693          	addi	a3,a3,-1924 # ffffffffc02027b0 <commands+0x7c0>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	64c60613          	addi	a2,a2,1612 # ffffffffc0202588 <commands+0x598>
ffffffffc0200f44:	10400593          	li	a1,260
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	65850513          	addi	a0,a0,1624 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200f50:	c5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f54:	00002697          	auipc	a3,0x2
ffffffffc0200f58:	84468693          	addi	a3,a3,-1980 # ffffffffc0202798 <commands+0x7a8>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	62c60613          	addi	a2,a2,1580 # ffffffffc0202588 <commands+0x598>
ffffffffc0200f64:	10300593          	li	a1,259
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	63850513          	addi	a0,a0,1592 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200f70:	c3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	78c68693          	addi	a3,a3,1932 # ffffffffc0202700 <commands+0x710>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	60c60613          	addi	a2,a2,1548 # ffffffffc0202588 <commands+0x598>
ffffffffc0200f84:	0fd00593          	li	a1,253
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	61850513          	addi	a0,a0,1560 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200f90:	c1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	7ec68693          	addi	a3,a3,2028 # ffffffffc0202780 <commands+0x790>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	5ec60613          	addi	a2,a2,1516 # ffffffffc0202588 <commands+0x598>
ffffffffc0200fa4:	0f800593          	li	a1,248
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	5f850513          	addi	a0,a0,1528 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200fb0:	bfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200fb4:	00002697          	auipc	a3,0x2
ffffffffc0200fb8:	8ec68693          	addi	a3,a3,-1812 # ffffffffc02028a0 <commands+0x8b0>
ffffffffc0200fbc:	00001617          	auipc	a2,0x1
ffffffffc0200fc0:	5cc60613          	addi	a2,a2,1484 # ffffffffc0202588 <commands+0x598>
ffffffffc0200fc4:	11600593          	li	a1,278
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	5d850513          	addi	a0,a0,1496 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200fd0:	bdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200fd4:	00002697          	auipc	a3,0x2
ffffffffc0200fd8:	8fc68693          	addi	a3,a3,-1796 # ffffffffc02028d0 <commands+0x8e0>
ffffffffc0200fdc:	00001617          	auipc	a2,0x1
ffffffffc0200fe0:	5ac60613          	addi	a2,a2,1452 # ffffffffc0202588 <commands+0x598>
ffffffffc0200fe4:	12500593          	li	a1,293
ffffffffc0200fe8:	00001517          	auipc	a0,0x1
ffffffffc0200fec:	5b850513          	addi	a0,a0,1464 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0200ff0:	bbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ff4:	00001697          	auipc	a3,0x1
ffffffffc0200ff8:	5c468693          	addi	a3,a3,1476 # ffffffffc02025b8 <commands+0x5c8>
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	58c60613          	addi	a2,a2,1420 # ffffffffc0202588 <commands+0x598>
ffffffffc0201004:	0f200593          	li	a1,242
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	59850513          	addi	a0,a0,1432 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0201010:	b9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	5e468693          	addi	a3,a3,1508 # ffffffffc02025f8 <commands+0x608>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	56c60613          	addi	a2,a2,1388 # ffffffffc0202588 <commands+0x598>
ffffffffc0201024:	0b900593          	li	a1,185
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	57850513          	addi	a0,a0,1400 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0201030:	b7cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201034 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {  //default_free_pages 函数的主要作用是将之前分配的页面释放回自由页面链表中，并尝试将相邻的空闲页面合并成更大的内存块，以减少内存碎片
ffffffffc0201034:	1141                	addi	sp,sp,-16
ffffffffc0201036:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201038:	14058a63          	beqz	a1,ffffffffc020118c <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020103c:	00259693          	slli	a3,a1,0x2
ffffffffc0201040:	96ae                	add	a3,a3,a1
ffffffffc0201042:	068e                	slli	a3,a3,0x3
ffffffffc0201044:	96aa                	add	a3,a3,a0
ffffffffc0201046:	87aa                	mv	a5,a0
ffffffffc0201048:	02d50263          	beq	a0,a3,ffffffffc020106c <default_free_pages+0x38>
ffffffffc020104c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));  //确保这些页面没有被标记为保留或者正在使用的内存块
ffffffffc020104e:	8b05                	andi	a4,a4,1
ffffffffc0201050:	10071e63          	bnez	a4,ffffffffc020116c <default_free_pages+0x138>
ffffffffc0201054:	6798                	ld	a4,8(a5)
ffffffffc0201056:	8b09                	andi	a4,a4,2
ffffffffc0201058:	10071a63          	bnez	a4,ffffffffc020116c <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020105c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201060:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201064:	02878793          	addi	a5,a5,40
ffffffffc0201068:	fed792e3          	bne	a5,a3,ffffffffc020104c <default_free_pages+0x18>
    base->property = n;
ffffffffc020106c:	2581                	sext.w	a1,a1
ffffffffc020106e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201070:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201074:	4789                	li	a5,2
ffffffffc0201076:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020107a:	00005697          	auipc	a3,0x5
ffffffffc020107e:	f9668693          	addi	a3,a3,-106 # ffffffffc0206010 <free_area>
ffffffffc0201082:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201084:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201086:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020108a:	9db9                	addw	a1,a1,a4
ffffffffc020108c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020108e:	0ad78863          	beq	a5,a3,ffffffffc020113e <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201092:	fe878713          	addi	a4,a5,-24
ffffffffc0201096:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020109a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020109c:	00e56a63          	bltu	a0,a4,ffffffffc02010b0 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02010a0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010a2:	06d70263          	beq	a4,a3,ffffffffc0201106 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02010a6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010a8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010ac:	fee57ae3          	bgeu	a0,a4,ffffffffc02010a0 <default_free_pages+0x6c>
ffffffffc02010b0:	c199                	beqz	a1,ffffffffc02010b6 <default_free_pages+0x82>
ffffffffc02010b2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010b6:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02010b8:	e390                	sd	a2,0(a5)
ffffffffc02010ba:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010bc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010be:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02010c0:	02d70063          	beq	a4,a3,ffffffffc02010e0 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02010c4:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02010c8:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc02010cc:	02081613          	slli	a2,a6,0x20
ffffffffc02010d0:	9201                	srli	a2,a2,0x20
ffffffffc02010d2:	00261793          	slli	a5,a2,0x2
ffffffffc02010d6:	97b2                	add	a5,a5,a2
ffffffffc02010d8:	078e                	slli	a5,a5,0x3
ffffffffc02010da:	97ae                	add	a5,a5,a1
ffffffffc02010dc:	02f50f63          	beq	a0,a5,ffffffffc020111a <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02010e0:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc02010e2:	00d70f63          	beq	a4,a3,ffffffffc0201100 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02010e6:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02010e8:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02010ec:	02059613          	slli	a2,a1,0x20
ffffffffc02010f0:	9201                	srli	a2,a2,0x20
ffffffffc02010f2:	00261793          	slli	a5,a2,0x2
ffffffffc02010f6:	97b2                	add	a5,a5,a2
ffffffffc02010f8:	078e                	slli	a5,a5,0x3
ffffffffc02010fa:	97aa                	add	a5,a5,a0
ffffffffc02010fc:	04f68863          	beq	a3,a5,ffffffffc020114c <default_free_pages+0x118>
}
ffffffffc0201100:	60a2                	ld	ra,8(sp)
ffffffffc0201102:	0141                	addi	sp,sp,16
ffffffffc0201104:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201106:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201108:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020110a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020110c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020110e:	02d70563          	beq	a4,a3,ffffffffc0201138 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201112:	8832                	mv	a6,a2
ffffffffc0201114:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201116:	87ba                	mv	a5,a4
ffffffffc0201118:	bf41                	j	ffffffffc02010a8 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc020111a:	491c                	lw	a5,16(a0)
ffffffffc020111c:	0107883b          	addw	a6,a5,a6
ffffffffc0201120:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201124:	57f5                	li	a5,-3
ffffffffc0201126:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020112a:	6d10                	ld	a2,24(a0)
ffffffffc020112c:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc020112e:	852e                	mv	a0,a1
=======
ffffffffc0200892:	e79c                	sd	a5,8(a5)
ffffffffc0200894:	e39c                	sd	a5,0(a5)
    {
        list_init(&(buddy_system_free_area[level].free_list)); // 对每个层级的空闲链表进行初始化
        // 这个链表用于存储该层级中所有空闲的内存块
        nr_free(level)=0; //每个层级对应的 `nr_free` 记录该级别内存块的数量，在初始状态下，所有层级的空闲块数量为 0
ffffffffc0200896:	0007a823          	sw	zero,16(a5)
    for(int level = 0; level < BuddyMaxLevel; level++) // 遍历所有的管理层级，从 0 到 BuddyMaxLevel-1
ffffffffc020089a:	07e1                	addi	a5,a5,24
ffffffffc020089c:	fee79be3          	bne	a5,a4,ffffffffc0200892 <buddy_system_init+0x10>
    }
}
ffffffffc02008a0:	8082                	ret

ffffffffc02008a2 <split_page>:
        page += block_size; // 跳到下一个块的起始页
    }
}

// 分裂一个较大的块为两个较小的块
static void split_page(int level) {
ffffffffc02008a2:	7179                	addi	sp,sp,-48
ffffffffc02008a4:	e84a                	sd	s2,16(sp)
ffffffffc02008a6:	00151913          	slli	s2,a0,0x1
ffffffffc02008aa:	e052                	sd	s4,0(sp)
ffffffffc02008ac:	00a90a33          	add	s4,s2,a0
ffffffffc02008b0:	e44e                	sd	s3,8(sp)
ffffffffc02008b2:	0a0e                	slli	s4,s4,0x3
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc02008b4:	00005997          	auipc	s3,0x5
ffffffffc02008b8:	75c98993          	addi	s3,s3,1884 # ffffffffc0206010 <buddy_system_free_area>
ffffffffc02008bc:	014987b3          	add	a5,s3,s4
ffffffffc02008c0:	ec26                	sd	s1,24(sp)
ffffffffc02008c2:	6784                	ld	s1,8(a5)
ffffffffc02008c4:	f022                	sd	s0,32(sp)
ffffffffc02008c6:	f406                	sd	ra,40(sp)
ffffffffc02008c8:	842a                	mv	s0,a0
    // 如果当前层级没有空闲块，向更高层级分裂
    if (list_empty(&(free_list(level)))) 
ffffffffc02008ca:	06f48d63          	beq	s1,a5,ffffffffc0200944 <split_page+0xa2>
        split_page(level + 1);  // 递归调用 `split_page`，直到找到包含空闲块的级别
    }
    list_entry_t* entry = list_next(&(free_list(level)));  // 从链表获取第一个空闲块的链表项
    struct Page *page = le2page(entry, page_link);
    list_del(&(page->page_link));  // 从链表获取第一个空闲块的链表项
    nr_free(level)--; // 减少当前级别的空闲块数量
ffffffffc02008ce:	9922                	add	s2,s2,s0

    // 新分裂出的两个块，大小为当前块的一半
    int new_block_size = 1 << (level - 1); // 计算新的块大小为当前块大小的一半
ffffffffc02008d0:	4705                	li	a4,1
ffffffffc02008d2:	347d                	addiw	s0,s0,-1
    nr_free(level)--; // 减少当前级别的空闲块数量
ffffffffc02008d4:	090e                	slli	s2,s2,0x3
    int new_block_size = 1 << (level - 1); // 计算新的块大小为当前块大小的一半
ffffffffc02008d6:	0087153b          	sllw	a0,a4,s0
    __list_del(listelm->prev, listelm->next);
ffffffffc02008da:	608c                	ld	a1,0(s1)
ffffffffc02008dc:	6490                	ld	a2,8(s1)
    nr_free(level)--; // 减少当前级别的空闲块数量
ffffffffc02008de:	994e                	add	s2,s2,s3
ffffffffc02008e0:	01092683          	lw	a3,16(s2)
    struct Page *buddy_page = page + new_block_size;  // 计算新伙伴块的位置
ffffffffc02008e4:	00251793          	slli	a5,a0,0x2
ffffffffc02008e8:	97aa                	add	a5,a5,a0
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
<<<<<<< HEAD
ffffffffc0201130:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201132:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201134:	e390                	sd	a2,0(a5)
ffffffffc0201136:	b775                	j	ffffffffc02010e2 <default_free_pages+0xae>
ffffffffc0201138:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020113a:	873e                	mv	a4,a5
ffffffffc020113c:	b761                	j	ffffffffc02010c4 <default_free_pages+0x90>
}
ffffffffc020113e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201140:	e390                	sd	a2,0(a5)
ffffffffc0201142:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201144:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201146:	ed1c                	sd	a5,24(a0)
ffffffffc0201148:	0141                	addi	sp,sp,16
ffffffffc020114a:	8082                	ret
            base->property += p->property;
ffffffffc020114c:	ff872783          	lw	a5,-8(a4)
ffffffffc0201150:	ff070693          	addi	a3,a4,-16
ffffffffc0201154:	9dbd                	addw	a1,a1,a5
ffffffffc0201156:	c90c                	sw	a1,16(a0)
ffffffffc0201158:	57f5                	li	a5,-3
ffffffffc020115a:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020115e:	6314                	ld	a3,0(a4)
ffffffffc0201160:	671c                	ld	a5,8(a4)
}
ffffffffc0201162:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201164:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201166:	e394                	sd	a3,0(a5)
ffffffffc0201168:	0141                	addi	sp,sp,16
ffffffffc020116a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));  //确保这些页面没有被标记为保留或者正在使用的内存块
ffffffffc020116c:	00001697          	auipc	a3,0x1
ffffffffc0201170:	77c68693          	addi	a3,a3,1916 # ffffffffc02028e8 <commands+0x8f8>
ffffffffc0201174:	00001617          	auipc	a2,0x1
ffffffffc0201178:	41460613          	addi	a2,a2,1044 # ffffffffc0202588 <commands+0x598>
ffffffffc020117c:	08200593          	li	a1,130
ffffffffc0201180:	00001517          	auipc	a0,0x1
ffffffffc0201184:	42050513          	addi	a0,a0,1056 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0201188:	a24ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020118c:	00001697          	auipc	a3,0x1
ffffffffc0201190:	75468693          	addi	a3,a3,1876 # ffffffffc02028e0 <commands+0x8f0>
ffffffffc0201194:	00001617          	auipc	a2,0x1
ffffffffc0201198:	3f460613          	addi	a2,a2,1012 # ffffffffc0202588 <commands+0x598>
ffffffffc020119c:	07f00593          	li	a1,127
ffffffffc02011a0:	00001517          	auipc	a0,0x1
ffffffffc02011a4:	40050513          	addi	a0,a0,1024 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc02011a8:	a04ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011ac <default_alloc_pages>:
    assert(n > 0);
ffffffffc02011ac:	c959                	beqz	a0,ffffffffc0201242 <default_alloc_pages+0x96>
    if (n > nr_free) { //如果可用的页面数量小于请求的数量
ffffffffc02011ae:	00005597          	auipc	a1,0x5
ffffffffc02011b2:	e6258593          	addi	a1,a1,-414 # ffffffffc0206010 <free_area>
ffffffffc02011b6:	0105a803          	lw	a6,16(a1)
ffffffffc02011ba:	862a                	mv	a2,a0
ffffffffc02011bc:	02081793          	slli	a5,a6,0x20
ffffffffc02011c0:	9381                	srli	a5,a5,0x20
ffffffffc02011c2:	00a7ee63          	bltu	a5,a0,ffffffffc02011de <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02011c6:	87ae                	mv	a5,a1
ffffffffc02011c8:	a801                	j	ffffffffc02011d8 <default_alloc_pages+0x2c>
        if (p->property >= n) {  //检查当前页面块 p 的大小是否满足所需的页面数
ffffffffc02011ca:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011ce:	02071693          	slli	a3,a4,0x20
ffffffffc02011d2:	9281                	srli	a3,a3,0x20
ffffffffc02011d4:	00c6f763          	bgeu	a3,a2,ffffffffc02011e2 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02011d8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02011da:	feb798e3          	bne	a5,a1,ffffffffc02011ca <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02011de:	4501                	li	a0,0
}
ffffffffc02011e0:	8082                	ret
    return listelm->prev;
ffffffffc02011e2:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02011e6:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02011ea:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02011ee:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02011f2:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02011f6:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02011fa:	02d67b63          	bgeu	a2,a3,ffffffffc0201230 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02011fe:	00261693          	slli	a3,a2,0x2
ffffffffc0201202:	96b2                	add	a3,a3,a2
ffffffffc0201204:	068e                	slli	a3,a3,0x3
ffffffffc0201206:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201208:	41c7073b          	subw	a4,a4,t3
ffffffffc020120c:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020120e:	00868613          	addi	a2,a3,8
ffffffffc0201212:	4709                	li	a4,2
ffffffffc0201214:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201218:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));  //分配的页面块大于所需的页面数，找到未分配的部分，更新其 property 为剩余页面数，并将其重新加入空闲链表
ffffffffc020121c:	01868613          	addi	a2,a3,24
        nr_free -= n;
ffffffffc0201220:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201224:	e310                	sd	a2,0(a4)
ffffffffc0201226:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020122a:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc020122c:	0116bc23          	sd	a7,24(a3)
ffffffffc0201230:	41c8083b          	subw	a6,a6,t3
ffffffffc0201234:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201238:	5775                	li	a4,-3
ffffffffc020123a:	17c1                	addi	a5,a5,-16
ffffffffc020123c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201240:	8082                	ret
default_alloc_pages(size_t n) {  //实现的是内存页面的分配，它使用的是First Fit 分配算法。该函数会在空闲页面列表中找到第一个满足所需页面数量的块，进行分配，并更新页面属性
ffffffffc0201242:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201244:	00001697          	auipc	a3,0x1
ffffffffc0201248:	69c68693          	addi	a3,a3,1692 # ffffffffc02028e0 <commands+0x8f0>
ffffffffc020124c:	00001617          	auipc	a2,0x1
ffffffffc0201250:	33c60613          	addi	a2,a2,828 # ffffffffc0202588 <commands+0x598>
ffffffffc0201254:	06100593          	li	a1,97
ffffffffc0201258:	00001517          	auipc	a0,0x1
ffffffffc020125c:	34850513          	addi	a0,a0,840 # ffffffffc02025a0 <commands+0x5b0>
default_alloc_pages(size_t n) {  //实现的是内存页面的分配，它使用的是First Fit 分配算法。该函数会在空闲页面列表中找到第一个满足所需页面数量的块，进行分配，并更新页面属性
ffffffffc0201260:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201262:	94aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201266 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201266:	1141                	addi	sp,sp,-16
ffffffffc0201268:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020126a:	c9e1                	beqz	a1,ffffffffc020133a <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020126c:	00259693          	slli	a3,a1,0x2
ffffffffc0201270:	96ae                	add	a3,a3,a1
ffffffffc0201272:	068e                	slli	a3,a3,0x3
ffffffffc0201274:	96aa                	add	a3,a3,a0
ffffffffc0201276:	87aa                	mv	a5,a0
ffffffffc0201278:	00d50f63          	beq	a0,a3,ffffffffc0201296 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020127c:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020127e:	8b05                	andi	a4,a4,1
ffffffffc0201280:	cf49                	beqz	a4,ffffffffc020131a <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201282:	0007a823          	sw	zero,16(a5)
ffffffffc0201286:	0007b423          	sd	zero,8(a5)
ffffffffc020128a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020128e:	02878793          	addi	a5,a5,40
ffffffffc0201292:	fed795e3          	bne	a5,a3,ffffffffc020127c <default_init_memmap+0x16>
    base->property = n;  //将 base 页面块的 property 属性设置为 n，表示这块内存包含 n 个连续页面。
ffffffffc0201296:	2581                	sext.w	a1,a1
ffffffffc0201298:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020129a:	4789                	li	a5,2
ffffffffc020129c:	00850713          	addi	a4,a0,8
ffffffffc02012a0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02012a4:	00005697          	auipc	a3,0x5
ffffffffc02012a8:	d6c68693          	addi	a3,a3,-660 # ffffffffc0206010 <free_area>
ffffffffc02012ac:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012ae:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012b0:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02012b4:	9db9                	addw	a1,a1,a4
ffffffffc02012b6:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012b8:	04d78a63          	beq	a5,a3,ffffffffc020130c <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link); //通过链表节点 le 的地址，计算出包含它的 Page 结构体的地址
ffffffffc02012bc:	fe878713          	addi	a4,a5,-24
ffffffffc02012c0:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012c4:	4581                	li	a1,0
            if (base < page) { //base 是需要插入的页面指针，page 是当前节点指向的页面指针
ffffffffc02012c6:	00e56a63          	bltu	a0,a4,ffffffffc02012da <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02012ca:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) { //如果遍历到了链表末尾（即当前节点的下一个节点是 free_list），说明 base 的地址比所有链表中的页面地址都要大，这时就将 base 插入到链表的末尾。
ffffffffc02012cc:	02d70263          	beq	a4,a3,ffffffffc02012f0 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02012d0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link); //通过链表节点 le 的地址，计算出包含它的 Page 结构体的地址
ffffffffc02012d2:	fe878713          	addi	a4,a5,-24
            if (base < page) { //base 是需要插入的页面指针，page 是当前节点指向的页面指针
ffffffffc02012d6:	fee57ae3          	bgeu	a0,a4,ffffffffc02012ca <default_init_memmap+0x64>
ffffffffc02012da:	c199                	beqz	a1,ffffffffc02012e0 <default_init_memmap+0x7a>
ffffffffc02012dc:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02012e0:	6398                	ld	a4,0(a5)
}
ffffffffc02012e2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02012e4:	e390                	sd	a2,0(a5)
ffffffffc02012e6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02012e8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02012ea:	ed18                	sd	a4,24(a0)
ffffffffc02012ec:	0141                	addi	sp,sp,16
ffffffffc02012ee:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02012f0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02012f2:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02012f4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02012f6:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012f8:	00d70663          	beq	a4,a3,ffffffffc0201304 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02012fc:	8832                	mv	a6,a2
ffffffffc02012fe:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201300:	87ba                	mv	a5,a4
ffffffffc0201302:	bfc1                	j	ffffffffc02012d2 <default_init_memmap+0x6c>
}
ffffffffc0201304:	60a2                	ld	ra,8(sp)
ffffffffc0201306:	e290                	sd	a2,0(a3)
ffffffffc0201308:	0141                	addi	sp,sp,16
ffffffffc020130a:	8082                	ret
ffffffffc020130c:	60a2                	ld	ra,8(sp)
ffffffffc020130e:	e390                	sd	a2,0(a5)
ffffffffc0201310:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201312:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201314:	ed1c                	sd	a5,24(a0)
ffffffffc0201316:	0141                	addi	sp,sp,16
ffffffffc0201318:	8082                	ret
        assert(PageReserved(p));
ffffffffc020131a:	00001697          	auipc	a3,0x1
ffffffffc020131e:	5f668693          	addi	a3,a3,1526 # ffffffffc0202910 <commands+0x920>
ffffffffc0201322:	00001617          	auipc	a2,0x1
ffffffffc0201326:	26660613          	addi	a2,a2,614 # ffffffffc0202588 <commands+0x598>
ffffffffc020132a:	04800593          	li	a1,72
ffffffffc020132e:	00001517          	auipc	a0,0x1
ffffffffc0201332:	27250513          	addi	a0,a0,626 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0201336:	876ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020133a:	00001697          	auipc	a3,0x1
ffffffffc020133e:	5a668693          	addi	a3,a3,1446 # ffffffffc02028e0 <commands+0x8f0>
ffffffffc0201342:	00001617          	auipc	a2,0x1
ffffffffc0201346:	24660613          	addi	a2,a2,582 # ffffffffc0202588 <commands+0x598>
ffffffffc020134a:	04500593          	li	a1,69
ffffffffc020134e:	00001517          	auipc	a0,0x1
ffffffffc0201352:	25250513          	addi	a0,a0,594 # ffffffffc02025a0 <commands+0x5b0>
ffffffffc0201356:	856ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020135a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020135a:	100027f3          	csrr	a5,sstatus
ffffffffc020135e:	8b89                	andi	a5,a5,2
ffffffffc0201360:	e799                	bnez	a5,ffffffffc020136e <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201362:	00005797          	auipc	a5,0x5
ffffffffc0201366:	2667b783          	ld	a5,614(a5) # ffffffffc02065c8 <pmm_manager>
ffffffffc020136a:	6f9c                	ld	a5,24(a5)
ffffffffc020136c:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020136e:	1141                	addi	sp,sp,-16
ffffffffc0201370:	e406                	sd	ra,8(sp)
ffffffffc0201372:	e022                	sd	s0,0(sp)
ffffffffc0201374:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201376:	8e8ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020137a:	00005797          	auipc	a5,0x5
ffffffffc020137e:	24e7b783          	ld	a5,590(a5) # ffffffffc02065c8 <pmm_manager>
ffffffffc0201382:	6f9c                	ld	a5,24(a5)
ffffffffc0201384:	8522                	mv	a0,s0
ffffffffc0201386:	9782                	jalr	a5
ffffffffc0201388:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020138a:	8ceff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020138e:	60a2                	ld	ra,8(sp)
ffffffffc0201390:	8522                	mv	a0,s0
ffffffffc0201392:	6402                	ld	s0,0(sp)
ffffffffc0201394:	0141                	addi	sp,sp,16
ffffffffc0201396:	8082                	ret

ffffffffc0201398 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201398:	100027f3          	csrr	a5,sstatus
ffffffffc020139c:	8b89                	andi	a5,a5,2
ffffffffc020139e:	e799                	bnez	a5,ffffffffc02013ac <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02013a0:	00005797          	auipc	a5,0x5
ffffffffc02013a4:	2287b783          	ld	a5,552(a5) # ffffffffc02065c8 <pmm_manager>
ffffffffc02013a8:	739c                	ld	a5,32(a5)
ffffffffc02013aa:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02013ac:	1101                	addi	sp,sp,-32
ffffffffc02013ae:	ec06                	sd	ra,24(sp)
ffffffffc02013b0:	e822                	sd	s0,16(sp)
ffffffffc02013b2:	e426                	sd	s1,8(sp)
ffffffffc02013b4:	842a                	mv	s0,a0
ffffffffc02013b6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02013b8:	8a6ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02013bc:	00005797          	auipc	a5,0x5
ffffffffc02013c0:	20c7b783          	ld	a5,524(a5) # ffffffffc02065c8 <pmm_manager>
ffffffffc02013c4:	739c                	ld	a5,32(a5)
ffffffffc02013c6:	85a6                	mv	a1,s1
ffffffffc02013c8:	8522                	mv	a0,s0
ffffffffc02013ca:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02013cc:	6442                	ld	s0,16(sp)
ffffffffc02013ce:	60e2                	ld	ra,24(sp)
ffffffffc02013d0:	64a2                	ld	s1,8(sp)
ffffffffc02013d2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02013d4:	884ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02013d8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013d8:	100027f3          	csrr	a5,sstatus
ffffffffc02013dc:	8b89                	andi	a5,a5,2
ffffffffc02013de:	e799                	bnez	a5,ffffffffc02013ec <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02013e0:	00005797          	auipc	a5,0x5
ffffffffc02013e4:	1e87b783          	ld	a5,488(a5) # ffffffffc02065c8 <pmm_manager>
ffffffffc02013e8:	779c                	ld	a5,40(a5)
ffffffffc02013ea:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02013ec:	1141                	addi	sp,sp,-16
ffffffffc02013ee:	e406                	sd	ra,8(sp)
ffffffffc02013f0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02013f2:	86cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02013f6:	00005797          	auipc	a5,0x5
ffffffffc02013fa:	1d27b783          	ld	a5,466(a5) # ffffffffc02065c8 <pmm_manager>
ffffffffc02013fe:	779c                	ld	a5,40(a5)
ffffffffc0201400:	9782                	jalr	a5
ffffffffc0201402:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201404:	854ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201408:	60a2                	ld	ra,8(sp)
ffffffffc020140a:	8522                	mv	a0,s0
ffffffffc020140c:	6402                	ld	s0,0(sp)
ffffffffc020140e:	0141                	addi	sp,sp,16
ffffffffc0201410:	8082                	ret

ffffffffc0201412 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201412:	00001797          	auipc	a5,0x1
ffffffffc0201416:	52678793          	addi	a5,a5,1318 # ffffffffc0202938 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020141a:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020141c:	1101                	addi	sp,sp,-32
ffffffffc020141e:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201420:	00001517          	auipc	a0,0x1
ffffffffc0201424:	55050513          	addi	a0,a0,1360 # ffffffffc0202970 <default_pmm_manager+0x38>
    pmm_manager = &default_pmm_manager;
ffffffffc0201428:	00005497          	auipc	s1,0x5
ffffffffc020142c:	1a048493          	addi	s1,s1,416 # ffffffffc02065c8 <pmm_manager>
void pmm_init(void) {
ffffffffc0201430:	ec06                	sd	ra,24(sp)
ffffffffc0201432:	e822                	sd	s0,16(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201434:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201436:	c7dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc020143a:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020143c:	00005417          	auipc	s0,0x5
ffffffffc0201440:	1a440413          	addi	s0,s0,420 # ffffffffc02065e0 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201444:	679c                	ld	a5,8(a5)
ffffffffc0201446:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201448:	57f5                	li	a5,-3
ffffffffc020144a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020144c:	00001517          	auipc	a0,0x1
ffffffffc0201450:	53c50513          	addi	a0,a0,1340 # ffffffffc0202988 <default_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201454:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201456:	c5dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020145a:	46c5                	li	a3,17
ffffffffc020145c:	06ee                	slli	a3,a3,0x1b
ffffffffc020145e:	40100613          	li	a2,1025
ffffffffc0201462:	16fd                	addi	a3,a3,-1
ffffffffc0201464:	07e005b7          	lui	a1,0x7e00
ffffffffc0201468:	0656                	slli	a2,a2,0x15
ffffffffc020146a:	00001517          	auipc	a0,0x1
ffffffffc020146e:	53650513          	addi	a0,a0,1334 # ffffffffc02029a0 <default_pmm_manager+0x68>
ffffffffc0201472:	c41fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201476:	777d                	lui	a4,0xfffff
ffffffffc0201478:	00006797          	auipc	a5,0x6
ffffffffc020147c:	17778793          	addi	a5,a5,375 # ffffffffc02075ef <end+0xfff>
ffffffffc0201480:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201482:	00005517          	auipc	a0,0x5
ffffffffc0201486:	13650513          	addi	a0,a0,310 # ffffffffc02065b8 <npage>
ffffffffc020148a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020148e:	00005597          	auipc	a1,0x5
ffffffffc0201492:	13258593          	addi	a1,a1,306 # ffffffffc02065c0 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201496:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201498:	e19c                	sd	a5,0(a1)
ffffffffc020149a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020149c:	4701                	li	a4,0
ffffffffc020149e:	4885                	li	a7,1
ffffffffc02014a0:	fff80837          	lui	a6,0xfff80
ffffffffc02014a4:	a011                	j	ffffffffc02014a8 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02014a6:	619c                	ld	a5,0(a1)
ffffffffc02014a8:	97b6                	add	a5,a5,a3
ffffffffc02014aa:	07a1                	addi	a5,a5,8
ffffffffc02014ac:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02014b0:	611c                	ld	a5,0(a0)
ffffffffc02014b2:	0705                	addi	a4,a4,1
ffffffffc02014b4:	02868693          	addi	a3,a3,40
ffffffffc02014b8:	01078633          	add	a2,a5,a6
ffffffffc02014bc:	fec765e3          	bltu	a4,a2,ffffffffc02014a6 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014c0:	6190                	ld	a2,0(a1)
ffffffffc02014c2:	00279713          	slli	a4,a5,0x2
ffffffffc02014c6:	973e                	add	a4,a4,a5
ffffffffc02014c8:	fec006b7          	lui	a3,0xfec00
ffffffffc02014cc:	070e                	slli	a4,a4,0x3
ffffffffc02014ce:	96b2                	add	a3,a3,a2
ffffffffc02014d0:	96ba                	add	a3,a3,a4
ffffffffc02014d2:	c0200737          	lui	a4,0xc0200
ffffffffc02014d6:	0ae6e163          	bltu	a3,a4,ffffffffc0201578 <pmm_init+0x166>
ffffffffc02014da:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02014dc:	45c5                	li	a1,17
ffffffffc02014de:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014e0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02014e2:	04b6ea63          	bltu	a3,a1,ffffffffc0201536 <pmm_init+0x124>
=======
ffffffffc02008ea:	e590                	sd	a2,8(a1)
ffffffffc02008ec:	078e                	slli	a5,a5,0x3
    next->prev = prev;
ffffffffc02008ee:	e20c                	sd	a1,0(a2)
    nr_free(level)--; // 减少当前级别的空闲块数量
ffffffffc02008f0:	36fd                	addiw	a3,a3,-1
    struct Page *buddy_page = page + new_block_size;  // 计算新伙伴块的位置
ffffffffc02008f2:	17a1                	addi	a5,a5,-24
    nr_free(level)--; // 减少当前级别的空闲块数量
ffffffffc02008f4:	00d92823          	sw	a3,16(s2)
    struct Page *buddy_page = page + new_block_size;  // 计算新伙伴块的位置
ffffffffc02008f8:	97a6                	add	a5,a5,s1
    page->property = buddy_page->property = new_block_size; // 设置两个小块的大小属性
ffffffffc02008fa:	cb88                	sw	a0,16(a5)
ffffffffc02008fc:	fea4ac23          	sw	a0,-8(s1)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200900:	4709                	li	a4,2
ffffffffc0200902:	00878693          	addi	a3,a5,8
ffffffffc0200906:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020090a:	00141513          	slli	a0,s0,0x1
ffffffffc020090e:	942a                	add	s0,s0,a0
ffffffffc0200910:	040e                	slli	s0,s0,0x3
ffffffffc0200912:	944e                	add	s0,s0,s3
ffffffffc0200914:	6414                	ld	a3,8(s0)
    SetPageProperty(buddy_page);  // 标记伙伴块的空闲属性
      // 将两个小块添加到下一级别的空闲链表中
    list_add(&(free_list(level - 1)), &(page->page_link));
ffffffffc0200916:	1a21                	addi	s4,s4,-24
    prev->next = next->prev = elm;
ffffffffc0200918:	e404                	sd	s1,8(s0)
ffffffffc020091a:	99d2                	add	s3,s3,s4
    list_add(&(page->page_link), &(buddy_page->page_link));
    nr_free(level - 1) += 2;
ffffffffc020091c:	4818                	lw	a4,16(s0)
    elm->prev = prev;
ffffffffc020091e:	0134b023          	sd	s3,0(s1)
    list_add(&(page->page_link), &(buddy_page->page_link));
ffffffffc0200922:	01878613          	addi	a2,a5,24
    prev->next = next->prev = elm;
ffffffffc0200926:	e290                	sd	a2,0(a3)
ffffffffc0200928:	e490                	sd	a2,8(s1)
    elm->prev = prev;
ffffffffc020092a:	ef84                	sd	s1,24(a5)
    elm->next = next;
ffffffffc020092c:	f394                	sd	a3,32(a5)
    nr_free(level - 1) += 2;
ffffffffc020092e:	0027079b          	addiw	a5,a4,2
}
ffffffffc0200932:	70a2                	ld	ra,40(sp)
    nr_free(level - 1) += 2;
ffffffffc0200934:	c81c                	sw	a5,16(s0)
}
ffffffffc0200936:	7402                	ld	s0,32(sp)
ffffffffc0200938:	64e2                	ld	s1,24(sp)
ffffffffc020093a:	6942                	ld	s2,16(sp)
ffffffffc020093c:	69a2                	ld	s3,8(sp)
ffffffffc020093e:	6a02                	ld	s4,0(sp)
ffffffffc0200940:	6145                	addi	sp,sp,48
ffffffffc0200942:	8082                	ret
        split_page(level + 1);  // 递归调用 `split_page`，直到找到包含空闲块的级别
ffffffffc0200944:	2505                	addiw	a0,a0,1
ffffffffc0200946:	f5dff0ef          	jal	ra,ffffffffc02008a2 <split_page>
    return listelm->next;
ffffffffc020094a:	6484                	ld	s1,8(s1)
ffffffffc020094c:	b749                	j	ffffffffc02008ce <split_page+0x2c>

ffffffffc020094e <buddy_get_buddy>:
*/
extern size_t npage; //物理页的总数量。
extern const size_t nbase;  //在使用页面编号时，nbase 作为一个偏移量，使得可以将 Page 数组中的下标与实际物理页号进行对齐。
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }  //将 Page 转换为页号。
ffffffffc020094e:	00006797          	auipc	a5,0x6
ffffffffc0200952:	bea7b783          	ld	a5,-1046(a5) # ffffffffc0206538 <pages>
ffffffffc0200956:	40f507b3          	sub	a5,a0,a5
ffffffffc020095a:	00002717          	auipc	a4,0x2
ffffffffc020095e:	85673703          	ld	a4,-1962(a4) # ffffffffc02021b0 <error_string+0x38>
ffffffffc0200962:	878d                	srai	a5,a5,0x3
ffffffffc0200964:	02e787b3          	mul	a5,a5,a4
static struct Page* buddy_get_buddy(struct Page *page) {
    unsigned int level = page->property;  // 获取当前页块的级别 (大小级别)
    
    // 计算伙伴块的物理页号
    // first_ppn是在ppm.c中新声明的全局变量，表示第一个可分配物理内存页在pages数组的下标.用代码中的异或计算便可得到伙伴块的头页在pages数组中的下标.
    unsigned int buddy_ppn = first_ppn + ((1 << level) ^ (page2ppn(page) - first_ppn));  
ffffffffc0200968:	4910                	lw	a2,16(a0)
ffffffffc020096a:	4705                	li	a4,1
ffffffffc020096c:	00006697          	auipc	a3,0x6
ffffffffc0200970:	bbc6a683          	lw	a3,-1092(a3) # ffffffffc0206528 <first_ppn>
ffffffffc0200974:	00c7173b          	sllw	a4,a4,a2
ffffffffc0200978:	00002617          	auipc	a2,0x2
ffffffffc020097c:	84063603          	ld	a2,-1984(a2) # ffffffffc02021b8 <nbase>
ffffffffc0200980:	97b2                	add	a5,a5,a2
ffffffffc0200982:	40d7863b          	subw	a2,a5,a3
ffffffffc0200986:	8f31                	xor	a4,a4,a2
ffffffffc0200988:	9f35                	addw	a4,a4,a3
    //将该偏移量与块大小 1 << level 进行 异或运算，可以找到伙伴块的偏移量
    // 判断伙伴块是在当前块的左侧还是右侧，并返回对应的伙伴页
    if (buddy_ppn > page2ppn(page)) {
ffffffffc020098a:	1702                	slli	a4,a4,0x20
ffffffffc020098c:	9301                	srli	a4,a4,0x20
ffffffffc020098e:	00e7fa63          	bgeu	a5,a4,ffffffffc02009a2 <buddy_get_buddy+0x54>
        return page + (buddy_ppn - page2ppn(page));  // 右侧的伙伴块
ffffffffc0200992:	40f707b3          	sub	a5,a4,a5
ffffffffc0200996:	00279713          	slli	a4,a5,0x2
ffffffffc020099a:	97ba                	add	a5,a5,a4
ffffffffc020099c:	078e                	slli	a5,a5,0x3
ffffffffc020099e:	953e                	add	a0,a0,a5
ffffffffc02009a0:	8082                	ret
    } else {
        return page - (page2ppn(page) - buddy_ppn);  // 左侧的伙伴块
ffffffffc02009a2:	8f99                	sub	a5,a5,a4
ffffffffc02009a4:	00279713          	slli	a4,a5,0x2
ffffffffc02009a8:	97ba                	add	a5,a5,a4
ffffffffc02009aa:	078e                	slli	a5,a5,0x3
ffffffffc02009ac:	8d1d                	sub	a0,a0,a5
    }
}
ffffffffc02009ae:	8082                	ret

ffffffffc02009b0 <buddy_system_nr_free_pages>:


// 返回空闲页面总数
static size_t buddy_system_nr_free_pages(void) {
    size_t total_pages = 0;
    for(int level = 0; level < BuddyMaxLevel; level++) 
ffffffffc02009b0:	00005697          	auipc	a3,0x5
ffffffffc02009b4:	67068693          	addi	a3,a3,1648 # ffffffffc0206020 <buddy_system_free_area+0x10>
ffffffffc02009b8:	4701                	li	a4,0
    size_t total_pages = 0;
ffffffffc02009ba:	4501                	li	a0,0
    for(int level = 0; level < BuddyMaxLevel; level++) 
ffffffffc02009bc:	462d                	li	a2,11
    {
        total_pages += nr_free(level) << level;
ffffffffc02009be:	429c                	lw	a5,0(a3)
    for(int level = 0; level < BuddyMaxLevel; level++) 
ffffffffc02009c0:	06e1                	addi	a3,a3,24
        total_pages += nr_free(level) << level;
ffffffffc02009c2:	00e797bb          	sllw	a5,a5,a4
ffffffffc02009c6:	1782                	slli	a5,a5,0x20
ffffffffc02009c8:	9381                	srli	a5,a5,0x20
    for(int level = 0; level < BuddyMaxLevel; level++) 
ffffffffc02009ca:	2705                	addiw	a4,a4,1
        total_pages += nr_free(level) << level;
ffffffffc02009cc:	953e                	add	a0,a0,a5
    for(int level = 0; level < BuddyMaxLevel; level++) 
ffffffffc02009ce:	fec718e3          	bne	a4,a2,ffffffffc02009be <buddy_system_nr_free_pages+0xe>
    }
    return total_pages;
}
ffffffffc02009d2:	8082                	ret

ffffffffc02009d4 <buddy_system_check>:

static void
buddy_system_check(void) {
}
ffffffffc02009d4:	8082                	ret

ffffffffc02009d6 <buddy_system_free_pages>:
static void buddy_system_free_pages(struct Page *base, size_t num_pages) {
ffffffffc02009d6:	715d                	addi	sp,sp,-80
ffffffffc02009d8:	e486                	sd	ra,72(sp)
ffffffffc02009da:	e0a2                	sd	s0,64(sp)
ffffffffc02009dc:	fc26                	sd	s1,56(sp)
ffffffffc02009de:	f84a                	sd	s2,48(sp)
ffffffffc02009e0:	f44e                	sd	s3,40(sp)
ffffffffc02009e2:	f052                	sd	s4,32(sp)
ffffffffc02009e4:	ec56                	sd	s5,24(sp)
ffffffffc02009e6:	e85a                	sd	s6,16(sp)
ffffffffc02009e8:	e45e                	sd	s7,8(sp)
    assert(num_pages > 0);  // 检查释放的块大小大于0
ffffffffc02009ea:	1c058863          	beqz	a1,ffffffffc0200bba <buddy_system_free_pages+0x1e4>
    assert((num_pages & (num_pages - 1)) == 0);  // 确保块大小是2的幂 (伙伴系统要求)
ffffffffc02009ee:	fff58793          	addi	a5,a1,-1
ffffffffc02009f2:	8fed                	and	a5,a5,a1
ffffffffc02009f4:	1a079363          	bnez	a5,ffffffffc0200b9a <buddy_system_free_pages+0x1c4>
    assert(num_pages < (1 << (BuddyMaxLevel - 1)));  // 确保释放块小于系统能管理的最大块
ffffffffc02009f8:	3ff00793          	li	a5,1023
ffffffffc02009fc:	1cb7ef63          	bltu	a5,a1,ffffffffc0200bda <buddy_system_free_pages+0x204>
    for (; page != base + num_pages; page++) {
ffffffffc0200a00:	00259693          	slli	a3,a1,0x2
ffffffffc0200a04:	96ae                	add	a3,a3,a1
ffffffffc0200a06:	068e                	slli	a3,a3,0x3
ffffffffc0200a08:	8b2a                	mv	s6,a0
ffffffffc0200a0a:	96aa                	add	a3,a3,a0
ffffffffc0200a0c:	87aa                	mv	a5,a0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a0e:	6780                	ld	s0,8(a5)
ffffffffc0200a10:	8805                	andi	s0,s0,1
        assert(!PageReserved(page) && !PageProperty(page));  // 页不能有保留或其他属性
ffffffffc0200a12:	16041463          	bnez	s0,ffffffffc0200b7a <buddy_system_free_pages+0x1a4>
ffffffffc0200a16:	6798                	ld	a4,8(a5)
ffffffffc0200a18:	8b09                	andi	a4,a4,2
ffffffffc0200a1a:	16071063          	bnez	a4,ffffffffc0200b7a <buddy_system_free_pages+0x1a4>
        page->flags = 0;  // 清除页的标志
ffffffffc0200a1e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a22:	0007a023          	sw	zero,0(a5)
    for (; page != base + num_pages; page++) {
ffffffffc0200a26:	02878793          	addi	a5,a5,40
ffffffffc0200a2a:	fed792e3          	bne	a5,a3,ffffffffc0200a0e <buddy_system_free_pages+0x38>
    base->property = num_pages;  // 设置当前块的大小
ffffffffc0200a2e:	00bb2823          	sw	a1,16(s6)
    SetPageProperty(base);  // 标记当前页块为空闲块
ffffffffc0200a32:	008b0493          	addi	s1,s6,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a36:	4789                	li	a5,2
ffffffffc0200a38:	40f4b02f          	amoor.d	zero,a5,(s1)
    while (num_pages > 1) {
ffffffffc0200a3c:	4785                	li	a5,1
ffffffffc0200a3e:	12f58763          	beq	a1,a5,ffffffffc0200b6c <buddy_system_free_pages+0x196>
        num_pages /= 2;
ffffffffc0200a42:	8185                	srli	a1,a1,0x1
        level++;
ffffffffc0200a44:	2405                	addiw	s0,s0,1
    while (num_pages > 1) {
ffffffffc0200a46:	fef59ee3          	bne	a1,a5,ffffffffc0200a42 <buddy_system_free_pages+0x6c>
    if (list_empty(&(free_list(level)))) // 检查当前级别的空闲列表是否为空
ffffffffc0200a4a:	00141793          	slli	a5,s0,0x1
ffffffffc0200a4e:	008786b3          	add	a3,a5,s0
ffffffffc0200a52:	00005917          	auipc	s2,0x5
ffffffffc0200a56:	5be90913          	addi	s2,s2,1470 # ffffffffc0206010 <buddy_system_free_area>
ffffffffc0200a5a:	068e                	slli	a3,a3,0x3
ffffffffc0200a5c:	96ca                	add	a3,a3,s2
    return list->next == list;
ffffffffc0200a5e:	00878733          	add	a4,a5,s0
ffffffffc0200a62:	070e                	slli	a4,a4,0x3
ffffffffc0200a64:	974a                	add	a4,a4,s2
ffffffffc0200a66:	671c                	ld	a5,8(a4)
        list_add(&(free_list(level)), &(block_page->page_link));
ffffffffc0200a68:	018b0b93          	addi	s7,s6,24
    if (list_empty(&(free_list(level)))) // 检查当前级别的空闲列表是否为空
ffffffffc0200a6c:	0ed78763          	beq	a5,a3,ffffffffc0200b5a <buddy_system_free_pages+0x184>
            struct Page* curr_page = le2page(entry, page_link);
ffffffffc0200a70:	fe878713          	addi	a4,a5,-24
            if (block_page < curr_page)  // 如果当前块的地址小于遍历到的块的地址，找到插入位置
ffffffffc0200a74:	00eb6a63          	bltu	s6,a4,ffffffffc0200a88 <buddy_system_free_pages+0xb2>
    return listelm->next;
ffffffffc0200a78:	6798                	ld	a4,8(a5)
            else if (list_next(entry) == &(free_list(level))) //如果遍历到最后一个块且尚未找到位置，插入到链表末尾
ffffffffc0200a7a:	0cd70363          	beq	a4,a3,ffffffffc0200b40 <buddy_system_free_pages+0x16a>
    while (num_pages > 1) {
ffffffffc0200a7e:	87ba                	mv	a5,a4
            struct Page* curr_page = le2page(entry, page_link);
ffffffffc0200a80:	fe878713          	addi	a4,a5,-24
            if (block_page < curr_page)  // 如果当前块的地址小于遍历到的块的地址，找到插入位置
ffffffffc0200a84:	feeb7ae3          	bgeu	s6,a4,ffffffffc0200a78 <buddy_system_free_pages+0xa2>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200a88:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200a8a:	0177b023          	sd	s7,0(a5)
ffffffffc0200a8e:	01773423          	sd	s7,8(a4)
    elm->next = next;
ffffffffc0200a92:	02fb3023          	sd	a5,32(s6)
    elm->prev = prev;
ffffffffc0200a96:	00eb3c23          	sd	a4,24(s6)
    struct Page *buddy = buddy_get_buddy(base);  // 获取当前块的伙伴块
ffffffffc0200a9a:	855a                	mv	a0,s6
ffffffffc0200a9c:	eb3ff0ef          	jal	ra,ffffffffc020094e <buddy_get_buddy>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200aa0:	6518                	ld	a4,8(a0)
ffffffffc0200aa2:	87aa                	mv	a5,a0
ffffffffc0200aa4:	8305                	srli	a4,a4,0x1
    while (!PageProperty(buddy) && level < BuddyMaxLevel) {  // 伙伴块空闲且未达到最大块级别时
ffffffffc0200aa6:	8b05                	andi	a4,a4,1
ffffffffc0200aa8:	ef35                	bnez	a4,ffffffffc0200b24 <buddy_system_free_pages+0x14e>
ffffffffc0200aaa:	4729                	li	a4,10
ffffffffc0200aac:	06874c63          	blt	a4,s0,ffffffffc0200b24 <buddy_system_free_pages+0x14e>
            base->property = -1;  // 将右侧块标记为无效
ffffffffc0200ab0:	5afd                	li	s5,-1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ab2:	5a75                	li	s4,-3
    while (!PageProperty(buddy) && level < BuddyMaxLevel) {  // 伙伴块空闲且未达到最大块级别时
ffffffffc0200ab4:	49ad                	li	s3,11
        if (base > buddy) {
ffffffffc0200ab6:	0167fd63          	bgeu	a5,s6,ffffffffc0200ad0 <buddy_system_free_pages+0xfa>
            base->property = -1;  // 将右侧块标记为无效
ffffffffc0200aba:	015b2823          	sw	s5,16(s6)
ffffffffc0200abe:	6144b02f          	amoand.d	zero,s4,(s1)
    ClearPageProperty(base);
ffffffffc0200ac2:	875a                	mv	a4,s6
ffffffffc0200ac4:	00878493          	addi	s1,a5,8
ffffffffc0200ac8:	8b3e                	mv	s6,a5
ffffffffc0200aca:	01878b93          	addi	s7,a5,24
ffffffffc0200ace:	87ba                	mv	a5,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ad0:	018b3603          	ld	a2,24(s6)
ffffffffc0200ad4:	020b3683          	ld	a3,32(s6)
        base->property += 1;
ffffffffc0200ad8:	010b2703          	lw	a4,16(s6)
        buddy = buddy_get_buddy(base);
ffffffffc0200adc:	855a                	mv	a0,s6
    prev->next = next;
ffffffffc0200ade:	e614                	sd	a3,8(a2)
        base->property += 1;
ffffffffc0200ae0:	2705                	addiw	a4,a4,1
    next->prev = prev;
ffffffffc0200ae2:	e290                	sd	a2,0(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ae4:	02071593          	slli	a1,a4,0x20
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ae8:	6f90                	ld	a2,24(a5)
ffffffffc0200aea:	7394                	ld	a3,32(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200aec:	9181                	srli	a1,a1,0x20
ffffffffc0200aee:	00159793          	slli	a5,a1,0x1
ffffffffc0200af2:	97ae                	add	a5,a5,a1
    prev->next = next;
ffffffffc0200af4:	e614                	sd	a3,8(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200af6:	078e                	slli	a5,a5,0x3
    next->prev = prev;
ffffffffc0200af8:	e290                	sd	a2,0(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200afa:	97ca                	add	a5,a5,s2
ffffffffc0200afc:	6794                	ld	a3,8(a5)
ffffffffc0200afe:	00eb2823          	sw	a4,16(s6)
        level++;
ffffffffc0200b02:	2405                	addiw	s0,s0,1
    prev->next = next->prev = elm;
ffffffffc0200b04:	0176b023          	sd	s7,0(a3)
ffffffffc0200b08:	0177b423          	sd	s7,8(a5)
    elm->prev = prev;
ffffffffc0200b0c:	00fb3c23          	sd	a5,24(s6)
    elm->next = next;
ffffffffc0200b10:	02db3023          	sd	a3,32(s6)
        buddy = buddy_get_buddy(base);
ffffffffc0200b14:	e3bff0ef          	jal	ra,ffffffffc020094e <buddy_get_buddy>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b18:	6518                	ld	a4,8(a0)
ffffffffc0200b1a:	87aa                	mv	a5,a0
    while (!PageProperty(buddy) && level < BuddyMaxLevel) {  // 伙伴块空闲且未达到最大块级别时
ffffffffc0200b1c:	8b09                	andi	a4,a4,2
ffffffffc0200b1e:	e319                	bnez	a4,ffffffffc0200b24 <buddy_system_free_pages+0x14e>
ffffffffc0200b20:	f9341be3          	bne	s0,s3,ffffffffc0200ab6 <buddy_system_free_pages+0xe0>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b24:	57f5                	li	a5,-3
ffffffffc0200b26:	60f4b02f          	amoand.d	zero,a5,(s1)
}
ffffffffc0200b2a:	60a6                	ld	ra,72(sp)
ffffffffc0200b2c:	6406                	ld	s0,64(sp)
ffffffffc0200b2e:	74e2                	ld	s1,56(sp)
ffffffffc0200b30:	7942                	ld	s2,48(sp)
ffffffffc0200b32:	79a2                	ld	s3,40(sp)
ffffffffc0200b34:	7a02                	ld	s4,32(sp)
ffffffffc0200b36:	6ae2                	ld	s5,24(sp)
ffffffffc0200b38:	6b42                	ld	s6,16(sp)
ffffffffc0200b3a:	6ba2                	ld	s7,8(sp)
ffffffffc0200b3c:	6161                	addi	sp,sp,80
ffffffffc0200b3e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200b40:	0176b023          	sd	s7,0(a3)
ffffffffc0200b44:	0177b423          	sd	s7,8(a5)
    elm->next = next;
ffffffffc0200b48:	02db3023          	sd	a3,32(s6)
    return listelm->next;
ffffffffc0200b4c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200b4e:	00fb3c23          	sd	a5,24(s6)
        while ((entry = list_next(entry)) != &(free_list(level))) 
ffffffffc0200b52:	f4d704e3          	beq	a4,a3,ffffffffc0200a9a <buddy_system_free_pages+0xc4>
    while (num_pages > 1) {
ffffffffc0200b56:	87ba                	mv	a5,a4
ffffffffc0200b58:	b725                	j	ffffffffc0200a80 <buddy_system_free_pages+0xaa>
    prev->next = next->prev = elm;
ffffffffc0200b5a:	0176b023          	sd	s7,0(a3)
ffffffffc0200b5e:	01773423          	sd	s7,8(a4)
    elm->next = next;
ffffffffc0200b62:	02db3023          	sd	a3,32(s6)
    elm->prev = prev;
ffffffffc0200b66:	00db3c23          	sd	a3,24(s6)
}
ffffffffc0200b6a:	bf05                	j	ffffffffc0200a9a <buddy_system_free_pages+0xc4>
ffffffffc0200b6c:	00005917          	auipc	s2,0x5
ffffffffc0200b70:	4a490913          	addi	s2,s2,1188 # ffffffffc0206010 <buddy_system_free_area>
ffffffffc0200b74:	86ca                	mv	a3,s2
ffffffffc0200b76:	4781                	li	a5,0
ffffffffc0200b78:	b5dd                	j	ffffffffc0200a5e <buddy_system_free_pages+0x88>
        assert(!PageReserved(page) && !PageProperty(page));  // 页不能有保留或其他属性
ffffffffc0200b7a:	00001697          	auipc	a3,0x1
ffffffffc0200b7e:	1e668693          	addi	a3,a3,486 # ffffffffc0201d60 <commands+0x620>
ffffffffc0200b82:	00001617          	auipc	a2,0x1
ffffffffc0200b86:	15660613          	addi	a2,a2,342 # ffffffffc0201cd8 <commands+0x598>
ffffffffc0200b8a:	0c000593          	li	a1,192
ffffffffc0200b8e:	00001517          	auipc	a0,0x1
ffffffffc0200b92:	16250513          	addi	a0,a0,354 # ffffffffc0201cf0 <commands+0x5b0>
ffffffffc0200b96:	817ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((num_pages & (num_pages - 1)) == 0);  // 确保块大小是2的幂 (伙伴系统要求)
ffffffffc0200b9a:	00001697          	auipc	a3,0x1
ffffffffc0200b9e:	17668693          	addi	a3,a3,374 # ffffffffc0201d10 <commands+0x5d0>
ffffffffc0200ba2:	00001617          	auipc	a2,0x1
ffffffffc0200ba6:	13660613          	addi	a2,a2,310 # ffffffffc0201cd8 <commands+0x598>
ffffffffc0200baa:	0b800593          	li	a1,184
ffffffffc0200bae:	00001517          	auipc	a0,0x1
ffffffffc0200bb2:	14250513          	addi	a0,a0,322 # ffffffffc0201cf0 <commands+0x5b0>
ffffffffc0200bb6:	ff6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(num_pages > 0);  // 检查释放的块大小大于0
ffffffffc0200bba:	00001697          	auipc	a3,0x1
ffffffffc0200bbe:	10e68693          	addi	a3,a3,270 # ffffffffc0201cc8 <commands+0x588>
ffffffffc0200bc2:	00001617          	auipc	a2,0x1
ffffffffc0200bc6:	11660613          	addi	a2,a2,278 # ffffffffc0201cd8 <commands+0x598>
ffffffffc0200bca:	0b700593          	li	a1,183
ffffffffc0200bce:	00001517          	auipc	a0,0x1
ffffffffc0200bd2:	12250513          	addi	a0,a0,290 # ffffffffc0201cf0 <commands+0x5b0>
ffffffffc0200bd6:	fd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(num_pages < (1 << (BuddyMaxLevel - 1)));  // 确保释放块小于系统能管理的最大块
ffffffffc0200bda:	00001697          	auipc	a3,0x1
ffffffffc0200bde:	15e68693          	addi	a3,a3,350 # ffffffffc0201d38 <commands+0x5f8>
ffffffffc0200be2:	00001617          	auipc	a2,0x1
ffffffffc0200be6:	0f660613          	addi	a2,a2,246 # ffffffffc0201cd8 <commands+0x598>
ffffffffc0200bea:	0ba00593          	li	a1,186
ffffffffc0200bee:	00001517          	auipc	a0,0x1
ffffffffc0200bf2:	10250513          	addi	a0,a0,258 # ffffffffc0201cf0 <commands+0x5b0>
ffffffffc0200bf6:	fb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bfa <buddy_system_alloc_pages>:
static struct Page * buddy_system_alloc_pages(size_t num_pages) {
ffffffffc0200bfa:	1101                	addi	sp,sp,-32
ffffffffc0200bfc:	ec06                	sd	ra,24(sp)
ffffffffc0200bfe:	e822                	sd	s0,16(sp)
ffffffffc0200c00:	e426                	sd	s1,8(sp)
    assert(num_pages > 0);
ffffffffc0200c02:	c14d                	beqz	a0,ffffffffc0200ca4 <buddy_system_alloc_pages+0xaa>
    while (num_pages < (1 << level)) 
ffffffffc0200c04:	3ff00793          	li	a5,1023
ffffffffc0200c08:	08a7e863          	bltu	a5,a0,ffffffffc0200c98 <buddy_system_alloc_pages+0x9e>
    int level = BuddyMaxLevel - 1;  // 从最大级别开始查找
ffffffffc0200c0c:	47a9                	li	a5,10
    while (num_pages < (1 << level)) 
ffffffffc0200c0e:	4605                	li	a2,1
        level--;
ffffffffc0200c10:	873e                	mv	a4,a5
ffffffffc0200c12:	37fd                	addiw	a5,a5,-1
    while (num_pages < (1 << level)) 
ffffffffc0200c14:	00f616bb          	sllw	a3,a2,a5
ffffffffc0200c18:	fed56ce3          	bltu	a0,a3,ffffffffc0200c10 <buddy_system_alloc_pages+0x16>
ffffffffc0200c1c:	45a9                	li	a1,10
ffffffffc0200c1e:	9d99                	subw	a1,a1,a4
ffffffffc0200c20:	1582                	slli	a1,a1,0x20
ffffffffc0200c22:	9181                	srli	a1,a1,0x20
ffffffffc0200c24:	00e587b3          	add	a5,a1,a4
ffffffffc0200c28:	00171513          	slli	a0,a4,0x1
ffffffffc0200c2c:	00179593          	slli	a1,a5,0x1
ffffffffc0200c30:	00e50433          	add	s0,a0,a4
ffffffffc0200c34:	95be                	add	a1,a1,a5
ffffffffc0200c36:	00005817          	auipc	a6,0x5
ffffffffc0200c3a:	3da80813          	addi	a6,a6,986 # ffffffffc0206010 <buddy_system_free_area>
ffffffffc0200c3e:	040e                	slli	s0,s0,0x3
ffffffffc0200c40:	00005697          	auipc	a3,0x5
ffffffffc0200c44:	3e868693          	addi	a3,a3,1000 # ffffffffc0206028 <buddy_system_free_area+0x18>
ffffffffc0200c48:	9442                	add	s0,s0,a6
ffffffffc0200c4a:	058e                	slli	a1,a1,0x3
ffffffffc0200c4c:	95b6                	add	a1,a1,a3
ffffffffc0200c4e:	87a2                	mv	a5,s0
ffffffffc0200c50:	4681                	li	a3,0
    for (int i = level; i < BuddyMaxLevel; i++) free_flag += nr_free(i);
ffffffffc0200c52:	4b90                	lw	a2,16(a5)
ffffffffc0200c54:	07e1                	addi	a5,a5,24
ffffffffc0200c56:	9eb1                	addw	a3,a3,a2
ffffffffc0200c58:	feb79de3          	bne	a5,a1,ffffffffc0200c52 <buddy_system_alloc_pages+0x58>
    if (free_flag == 0) return NULL;  // 无可用块，返回 NULL
ffffffffc0200c5c:	ce95                	beqz	a3,ffffffffc0200c98 <buddy_system_alloc_pages+0x9e>
    return list->next == list;
ffffffffc0200c5e:	953a                	add	a0,a0,a4
ffffffffc0200c60:	050e                	slli	a0,a0,0x3
ffffffffc0200c62:	00a804b3          	add	s1,a6,a0
ffffffffc0200c66:	649c                	ld	a5,8(s1)
    if (list_empty(&(free_list(level)))) 
ffffffffc0200c68:	02f40163          	beq	s0,a5,ffffffffc0200c8a <buddy_system_alloc_pages+0x90>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c6c:	6798                	ld	a4,8(a5)
ffffffffc0200c6e:	6394                	ld	a3,0(a5)
    allocated_page = le2page(entry, page_link);
ffffffffc0200c70:	fe878513          	addi	a0,a5,-24
ffffffffc0200c74:	17c1                	addi	a5,a5,-16
    prev->next = next;
ffffffffc0200c76:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200c78:	e314                	sd	a3,0(a4)
ffffffffc0200c7a:	5775                	li	a4,-3
ffffffffc0200c7c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0200c80:	60e2                	ld	ra,24(sp)
ffffffffc0200c82:	6442                	ld	s0,16(sp)
ffffffffc0200c84:	64a2                	ld	s1,8(sp)
ffffffffc0200c86:	6105                	addi	sp,sp,32
ffffffffc0200c88:	8082                	ret
        split_page(level + 1);
ffffffffc0200c8a:	0017051b          	addiw	a0,a4,1
ffffffffc0200c8e:	c15ff0ef          	jal	ra,ffffffffc02008a2 <split_page>
    return list->next == list;
ffffffffc0200c92:	649c                	ld	a5,8(s1)
    if (list_empty(&(free_list(level)))) return NULL;
ffffffffc0200c94:	fcf41ce3          	bne	s0,a5,ffffffffc0200c6c <buddy_system_alloc_pages+0x72>
}
ffffffffc0200c98:	60e2                	ld	ra,24(sp)
ffffffffc0200c9a:	6442                	ld	s0,16(sp)
ffffffffc0200c9c:	64a2                	ld	s1,8(sp)
        return NULL;  //检查请求的页数是否超过最大块大小，如果超过则返回 NULL，无法分配
ffffffffc0200c9e:	4501                	li	a0,0
}
ffffffffc0200ca0:	6105                	addi	sp,sp,32
ffffffffc0200ca2:	8082                	ret
    assert(num_pages > 0);
ffffffffc0200ca4:	00001697          	auipc	a3,0x1
ffffffffc0200ca8:	02468693          	addi	a3,a3,36 # ffffffffc0201cc8 <commands+0x588>
ffffffffc0200cac:	00001617          	auipc	a2,0x1
ffffffffc0200cb0:	02c60613          	addi	a2,a2,44 # ffffffffc0201cd8 <commands+0x598>
ffffffffc0200cb4:	05600593          	li	a1,86
ffffffffc0200cb8:	00001517          	auipc	a0,0x1
ffffffffc0200cbc:	03850513          	addi	a0,a0,56 # ffffffffc0201cf0 <commands+0x5b0>
ffffffffc0200cc0:	eecff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200cc4 <buddy_system_init_memmap>:
static void buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200cc4:	1141                	addi	sp,sp,-16
ffffffffc0200cc6:	e406                	sd	ra,8(sp)
    assert(n> 0);
ffffffffc0200cc8:	c9c5                	beqz	a1,ffffffffc0200d78 <buddy_system_init_memmap+0xb4>
    for (; page != base + n; page++) 
ffffffffc0200cca:	00259693          	slli	a3,a1,0x2
ffffffffc0200cce:	96ae                	add	a3,a3,a1
ffffffffc0200cd0:	068e                	slli	a3,a3,0x3
ffffffffc0200cd2:	96aa                	add	a3,a3,a0
ffffffffc0200cd4:	87aa                	mv	a5,a0
ffffffffc0200cd6:	00d50f63          	beq	a0,a3,ffffffffc0200cf4 <buddy_system_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200cda:	6798                	ld	a4,8(a5)
        assert(PageReserved(page)); //assert(PageReserved(page));   确保页处于保留状态，避免重复初始化
ffffffffc0200cdc:	8b05                	andi	a4,a4,1
ffffffffc0200cde:	cf2d                	beqz	a4,ffffffffc0200d58 <buddy_system_init_memmap+0x94>
        page->flags = page->property = 0; // 清除页的标志位和属性
ffffffffc0200ce0:	0007a823          	sw	zero,16(a5)
ffffffffc0200ce4:	0007b423          	sd	zero,8(a5)
ffffffffc0200ce8:	0007a023          	sw	zero,0(a5)
    for (; page != base + n; page++) 
ffffffffc0200cec:	02878793          	addi	a5,a5,40
ffffffffc0200cf0:	fed795e3          	bne	a5,a3,ffffffffc0200cda <buddy_system_init_memmap+0x16>
    int level = BuddyMaxLevel - 1;
ffffffffc0200cf4:	4729                	li	a4,10
    int block_size = 1 << level; // 当前块大小
ffffffffc0200cf6:	40000793          	li	a5,1024
ffffffffc0200cfa:	00005e17          	auipc	t3,0x5
ffffffffc0200cfe:	316e0e13          	addi	t3,t3,790 # ffffffffc0206010 <buddy_system_free_area>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d02:	4309                	li	t1,2
        page->property = block_size; // 设置块大小
ffffffffc0200d04:	c91c                	sw	a5,16(a0)
ffffffffc0200d06:	00850693          	addi	a3,a0,8
ffffffffc0200d0a:	4066b02f          	amoor.d	zero,t1,(a3)
        nr_free(level)++; // 更新对应级别的空闲块数量
ffffffffc0200d0e:	00171693          	slli	a3,a4,0x1
ffffffffc0200d12:	96ba                	add	a3,a3,a4
ffffffffc0200d14:	068e                	slli	a3,a3,0x3
ffffffffc0200d16:	96f2                	add	a3,a3,t3
ffffffffc0200d18:	0106a803          	lw	a6,16(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d1c:	0006b883          	ld	a7,0(a3)
        list_add_before(&(free_list(level)), &(page->page_link)); // 添加到空闲链表
ffffffffc0200d20:	01850613          	addi	a2,a0,24
        nr_free(level)++; // 更新对应级别的空闲块数量
ffffffffc0200d24:	2805                	addiw	a6,a6,1
ffffffffc0200d26:	0106a823          	sw	a6,16(a3)
    prev->next = next->prev = elm;
ffffffffc0200d2a:	e290                	sd	a2,0(a3)
ffffffffc0200d2c:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0200d30:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200d32:	01153c23          	sd	a7,24(a0)
        remaining_pages -= block_size;
ffffffffc0200d36:	8d9d                	sub	a1,a1,a5
        while (level > 0 && remaining_pages < block_size) 
ffffffffc0200d38:	00e05763          	blez	a4,ffffffffc0200d46 <buddy_system_init_memmap+0x82>
ffffffffc0200d3c:	00f5f563          	bgeu	a1,a5,ffffffffc0200d46 <buddy_system_init_memmap+0x82>
            level--; 
ffffffffc0200d40:	377d                	addiw	a4,a4,-1
            block_size >>= 1; // 减半块大小
ffffffffc0200d42:	8785                	srai	a5,a5,0x1
        while (level > 0 && remaining_pages < block_size) 
ffffffffc0200d44:	ff65                	bnez	a4,ffffffffc0200d3c <buddy_system_init_memmap+0x78>
        page += block_size; // 跳到下一个块的起始页
ffffffffc0200d46:	00279693          	slli	a3,a5,0x2
ffffffffc0200d4a:	96be                	add	a3,a3,a5
ffffffffc0200d4c:	068e                	slli	a3,a3,0x3
ffffffffc0200d4e:	9536                	add	a0,a0,a3
    while (remaining_pages > 0) 
ffffffffc0200d50:	f9d5                	bnez	a1,ffffffffc0200d04 <buddy_system_init_memmap+0x40>
}
ffffffffc0200d52:	60a2                	ld	ra,8(sp)
ffffffffc0200d54:	0141                	addi	sp,sp,16
ffffffffc0200d56:	8082                	ret
        assert(PageReserved(page)); //assert(PageReserved(page));   确保页处于保留状态，避免重复初始化
ffffffffc0200d58:	00001697          	auipc	a3,0x1
ffffffffc0200d5c:	04068693          	addi	a3,a3,64 # ffffffffc0201d98 <commands+0x658>
ffffffffc0200d60:	00001617          	auipc	a2,0x1
ffffffffc0200d64:	f7860613          	addi	a2,a2,-136 # ffffffffc0201cd8 <commands+0x598>
ffffffffc0200d68:	02000593          	li	a1,32
ffffffffc0200d6c:	00001517          	auipc	a0,0x1
ffffffffc0200d70:	f8450513          	addi	a0,a0,-124 # ffffffffc0201cf0 <commands+0x5b0>
ffffffffc0200d74:	e38ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n> 0);
ffffffffc0200d78:	00001697          	auipc	a3,0x1
ffffffffc0200d7c:	01868693          	addi	a3,a3,24 # ffffffffc0201d90 <commands+0x650>
ffffffffc0200d80:	00001617          	auipc	a2,0x1
ffffffffc0200d84:	f5860613          	addi	a2,a2,-168 # ffffffffc0201cd8 <commands+0x598>
ffffffffc0200d88:	45e9                	li	a1,26
ffffffffc0200d8a:	00001517          	auipc	a0,0x1
ffffffffc0200d8e:	f6650513          	addi	a0,a0,-154 # ffffffffc0201cf0 <commands+0x5b0>
ffffffffc0200d92:	e1aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d96 <pmm_init>:
static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    //pmm_manager = &best_fit_pmm_manager;
    pmm_manager = & buddy_system_pmm_manager;
ffffffffc0200d96:	00001797          	auipc	a5,0x1
ffffffffc0200d9a:	03a78793          	addi	a5,a5,58 # ffffffffc0201dd0 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d9e:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200da0:	7179                	addi	sp,sp,-48
ffffffffc0200da2:	e44e                	sd	s3,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200da4:	00001517          	auipc	a0,0x1
ffffffffc0200da8:	06450513          	addi	a0,a0,100 # ffffffffc0201e08 <buddy_system_pmm_manager+0x38>
    pmm_manager = & buddy_system_pmm_manager;
ffffffffc0200dac:	00005997          	auipc	s3,0x5
ffffffffc0200db0:	79498993          	addi	s3,s3,1940 # ffffffffc0206540 <pmm_manager>
void pmm_init(void) {
ffffffffc0200db4:	f406                	sd	ra,40(sp)
ffffffffc0200db6:	f022                	sd	s0,32(sp)
ffffffffc0200db8:	ec26                	sd	s1,24(sp)
ffffffffc0200dba:	e84a                	sd	s2,16(sp)
    pmm_manager = & buddy_system_pmm_manager;
ffffffffc0200dbc:	00f9b023          	sd	a5,0(s3)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dc0:	af2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200dc4:	0009b783          	ld	a5,0(s3)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200dc8:	00005917          	auipc	s2,0x5
ffffffffc0200dcc:	79090913          	addi	s2,s2,1936 # ffffffffc0206558 <va_pa_offset>
    npage = maxpa / PGSIZE;  
ffffffffc0200dd0:	00005497          	auipc	s1,0x5
ffffffffc0200dd4:	76048493          	addi	s1,s1,1888 # ffffffffc0206530 <npage>
    pmm_manager->init();
ffffffffc0200dd8:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200dda:	00005417          	auipc	s0,0x5
ffffffffc0200dde:	75e40413          	addi	s0,s0,1886 # ffffffffc0206538 <pages>
    pmm_manager->init();
ffffffffc0200de2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200de4:	57f5                	li	a5,-3
ffffffffc0200de6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	03850513          	addi	a0,a0,56 # ffffffffc0201e20 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200df0:	00f93023          	sd	a5,0(s2)
    cprintf("physcial memory map:\n");
ffffffffc0200df4:	abeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200df8:	46c5                	li	a3,17
ffffffffc0200dfa:	06ee                	slli	a3,a3,0x1b
ffffffffc0200dfc:	40100613          	li	a2,1025
ffffffffc0200e00:	16fd                	addi	a3,a3,-1
ffffffffc0200e02:	0656                	slli	a2,a2,0x15
ffffffffc0200e04:	07e005b7          	lui	a1,0x7e00
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	03050513          	addi	a0,a0,48 # ffffffffc0201e38 <buddy_system_pmm_manager+0x68>
ffffffffc0200e10:	aa2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    npage = maxpa / PGSIZE;  
ffffffffc0200e14:	77fd                	lui	a5,0xfffff
ffffffffc0200e16:	00006697          	auipc	a3,0x6
ffffffffc0200e1a:	75168693          	addi	a3,a3,1873 # ffffffffc0207567 <end+0xfff>
ffffffffc0200e1e:	8efd                	and	a3,a3,a5
ffffffffc0200e20:	000887b7          	lui	a5,0x88
ffffffffc0200e24:	e09c                	sd	a5,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e26:	e014                	sd	a3,0(s0)
    first_ppn = PADDR(pages) / PGSIZE;  // 设置 first_ppn 为第一个可分配物理页的页号
ffffffffc0200e28:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e2c:	12f6eb63          	bltu	a3,a5,ffffffffc0200f62 <pmm_init+0x1cc>
ffffffffc0200e30:	00093783          	ld	a5,0(s2)
    cprintf("First allocatable physical page number (first_ppn): %d\n", first_ppn);
ffffffffc0200e34:	00001517          	auipc	a0,0x1
ffffffffc0200e38:	06c50513          	addi	a0,a0,108 # ffffffffc0201ea0 <buddy_system_pmm_manager+0xd0>
    first_ppn = PADDR(pages) / PGSIZE;  // 设置 first_ppn 为第一个可分配物理页的页号
ffffffffc0200e3c:	8e9d                	sub	a3,a3,a5
ffffffffc0200e3e:	82b1                	srli	a3,a3,0xc
    cprintf("First allocatable physical page number (first_ppn): %d\n", first_ppn);
ffffffffc0200e40:	0006859b          	sext.w	a1,a3
    first_ppn = PADDR(pages) / PGSIZE;  // 设置 first_ppn 为第一个可分配物理页的页号
ffffffffc0200e44:	00005797          	auipc	a5,0x5
ffffffffc0200e48:	6ed7a223          	sw	a3,1764(a5) # ffffffffc0206528 <first_ppn>
    cprintf("First allocatable physical page number (first_ppn): %d\n", first_ppn);
ffffffffc0200e4c:	a66ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e50:	609c                	ld	a5,0(s1)
ffffffffc0200e52:	00080737          	lui	a4,0x80
ffffffffc0200e56:	0ce78b63          	beq	a5,a4,ffffffffc0200f2c <pmm_init+0x196>
ffffffffc0200e5a:	4681                	li	a3,0
ffffffffc0200e5c:	4701                	li	a4,0
ffffffffc0200e5e:	4505                	li	a0,1
ffffffffc0200e60:	fff805b7          	lui	a1,0xfff80
        SetPageReserved(pages + i);
ffffffffc0200e64:	601c                	ld	a5,0(s0)
ffffffffc0200e66:	97b6                	add	a5,a5,a3
ffffffffc0200e68:	07a1                	addi	a5,a5,8
ffffffffc0200e6a:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e6e:	609c                	ld	a5,0(s1)
ffffffffc0200e70:	0705                	addi	a4,a4,1
ffffffffc0200e72:	02868693          	addi	a3,a3,40
ffffffffc0200e76:	00b78633          	add	a2,a5,a1
ffffffffc0200e7a:	fec765e3          	bltu	a4,a2,ffffffffc0200e64 <pmm_init+0xce>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase)); //nbase：表示内存中第一个可分配物理页的基准页号
ffffffffc0200e7e:	00279693          	slli	a3,a5,0x2
ffffffffc0200e82:	96be                	add	a3,a3,a5
ffffffffc0200e84:	00369713          	slli	a4,a3,0x3
ffffffffc0200e88:	6010                	ld	a2,0(s0)
ffffffffc0200e8a:	fec006b7          	lui	a3,0xfec00
ffffffffc0200e8e:	c02005b7          	lui	a1,0xc0200
ffffffffc0200e92:	96b2                	add	a3,a3,a2
ffffffffc0200e94:	96ba                	add	a3,a3,a4
ffffffffc0200e96:	0ab6ea63          	bltu	a3,a1,ffffffffc0200f4a <pmm_init+0x1b4>
ffffffffc0200e9a:	00093703          	ld	a4,0(s2)
    if (freemem < mem_end) {
ffffffffc0200e9e:	45c5                	li	a1,17
ffffffffc0200ea0:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase)); //nbase：表示内存中第一个可分配物理页的基准页号
ffffffffc0200ea2:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200ea4:	04b6ec63          	bltu	a3,a1,ffffffffc0200efc <pmm_init+0x166>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
<<<<<<< HEAD
ffffffffc02014e6:	609c                	ld	a5,0(s1)
ffffffffc02014e8:	7b9c                	ld	a5,48(a5)
ffffffffc02014ea:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02014ec:	00001517          	auipc	a0,0x1
ffffffffc02014f0:	54c50513          	addi	a0,a0,1356 # ffffffffc0202a38 <default_pmm_manager+0x100>
ffffffffc02014f4:	bbffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    slub_check();
ffffffffc02014f8:	100000ef          	jal	ra,ffffffffc02015f8 <slub_check>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02014fc:	00004597          	auipc	a1,0x4
ffffffffc0201500:	b0458593          	addi	a1,a1,-1276 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201504:	00005797          	auipc	a5,0x5
ffffffffc0201508:	0cb7ba23          	sd	a1,212(a5) # ffffffffc02065d8 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020150c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201510:	08f5e063          	bltu	a1,a5,ffffffffc0201590 <pmm_init+0x17e>
ffffffffc0201514:	6010                	ld	a2,0(s0)
}
ffffffffc0201516:	6442                	ld	s0,16(sp)
ffffffffc0201518:	60e2                	ld	ra,24(sp)
ffffffffc020151a:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc020151c:	40c58633          	sub	a2,a1,a2
ffffffffc0201520:	00005797          	auipc	a5,0x5
ffffffffc0201524:	0ac7b823          	sd	a2,176(a5) # ffffffffc02065d0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201528:	00001517          	auipc	a0,0x1
ffffffffc020152c:	53050513          	addi	a0,a0,1328 # ffffffffc0202a58 <default_pmm_manager+0x120>
}
ffffffffc0201530:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201532:	b81fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201536:	6705                	lui	a4,0x1
ffffffffc0201538:	177d                	addi	a4,a4,-1
ffffffffc020153a:	96ba                	add	a3,a3,a4
ffffffffc020153c:	777d                	lui	a4,0xfffff
ffffffffc020153e:	8ef9                	and	a3,a3,a4
=======
ffffffffc0200ea8:	0009b783          	ld	a5,0(s3)
ffffffffc0200eac:	7b9c                	ld	a5,48(a5)
ffffffffc0200eae:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200eb0:	00001517          	auipc	a0,0x1
ffffffffc0200eb4:	05850513          	addi	a0,a0,88 # ffffffffc0201f08 <buddy_system_pmm_manager+0x138>
ffffffffc0200eb8:	9faff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200ebc:	00004597          	auipc	a1,0x4
ffffffffc0200ec0:	14458593          	addi	a1,a1,324 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200ec4:	00005797          	auipc	a5,0x5
ffffffffc0200ec8:	68b7b623          	sd	a1,1676(a5) # ffffffffc0206550 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ecc:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ed0:	0af5e563          	bltu	a1,a5,ffffffffc0200f7a <pmm_init+0x1e4>
ffffffffc0200ed4:	00093603          	ld	a2,0(s2)
}
ffffffffc0200ed8:	7402                	ld	s0,32(sp)
ffffffffc0200eda:	70a2                	ld	ra,40(sp)
ffffffffc0200edc:	64e2                	ld	s1,24(sp)
ffffffffc0200ede:	6942                	ld	s2,16(sp)
ffffffffc0200ee0:	69a2                	ld	s3,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ee2:	40c58633          	sub	a2,a1,a2
ffffffffc0200ee6:	00005797          	auipc	a5,0x5
ffffffffc0200eea:	66c7b123          	sd	a2,1634(a5) # ffffffffc0206548 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200eee:	00001517          	auipc	a0,0x1
ffffffffc0200ef2:	03a50513          	addi	a0,a0,58 # ffffffffc0201f28 <buddy_system_pmm_manager+0x158>
}
ffffffffc0200ef6:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ef8:	9baff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200efc:	6705                	lui	a4,0x1
ffffffffc0200efe:	177d                	addi	a4,a4,-1
ffffffffc0200f00:	96ba                	add	a3,a3,a4
ffffffffc0200f02:	777d                	lui	a4,0xfffff
ffffffffc0200f04:	8ef9                	and	a3,a3,a4
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
<<<<<<< HEAD
ffffffffc0201540:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201544:	00f57e63          	bgeu	a0,a5,ffffffffc0201560 <pmm_init+0x14e>
    pmm_manager->init_memmap(base, n);
ffffffffc0201548:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020154a:	982a                	add	a6,a6,a0
ffffffffc020154c:	00281513          	slli	a0,a6,0x2
ffffffffc0201550:	9542                	add	a0,a0,a6
ffffffffc0201552:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201554:	8d95                	sub	a1,a1,a3
ffffffffc0201556:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201558:	81b1                	srli	a1,a1,0xc
ffffffffc020155a:	9532                	add	a0,a0,a2
ffffffffc020155c:	9782                	jalr	a5
}
ffffffffc020155e:	b761                	j	ffffffffc02014e6 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201560:	00001617          	auipc	a2,0x1
ffffffffc0201564:	4a860613          	addi	a2,a2,1192 # ffffffffc0202a08 <default_pmm_manager+0xd0>
ffffffffc0201568:	06b00593          	li	a1,107
ffffffffc020156c:	00001517          	auipc	a0,0x1
ffffffffc0201570:	4bc50513          	addi	a0,a0,1212 # ffffffffc0202a28 <default_pmm_manager+0xf0>
ffffffffc0201574:	e39fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201578:	00001617          	auipc	a2,0x1
ffffffffc020157c:	45860613          	addi	a2,a2,1112 # ffffffffc02029d0 <default_pmm_manager+0x98>
ffffffffc0201580:	07000593          	li	a1,112
ffffffffc0201584:	00001517          	auipc	a0,0x1
ffffffffc0201588:	47450513          	addi	a0,a0,1140 # ffffffffc02029f8 <default_pmm_manager+0xc0>
ffffffffc020158c:	e21fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201590:	86ae                	mv	a3,a1
ffffffffc0201592:	00001617          	auipc	a2,0x1
ffffffffc0201596:	43e60613          	addi	a2,a2,1086 # ffffffffc02029d0 <default_pmm_manager+0x98>
ffffffffc020159a:	08d00593          	li	a1,141
ffffffffc020159e:	00001517          	auipc	a0,0x1
ffffffffc02015a2:	45a50513          	addi	a0,a0,1114 # ffffffffc02029f8 <default_pmm_manager+0xc0>
ffffffffc02015a6:	e07fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02015aa <slub_alloc>:
    }

    // 请求内存小于或等于 2048，查找合适的 slab
    for (size_t i = 0; i < MAX_ORDER - MIN_ORDER + 1; i++) {
        Slab_t *slab = &slab_list[i];
        if (size <= Slab_size(slab->order) && slab->free_objects.nr_free > 0) {
ffffffffc02015aa:	4605                	li	a2,1
    for (size_t i = 0; i < MAX_ORDER - MIN_ORDER + 1; i++) {
ffffffffc02015ac:	45a1                	li	a1,8
ffffffffc02015ae:	00005717          	auipc	a4,0x5
ffffffffc02015b2:	a7a70713          	addi	a4,a4,-1414 # ffffffffc0206028 <slab_list>
ffffffffc02015b6:	4681                	li	a3,0
ffffffffc02015b8:	a031                	j	ffffffffc02015c4 <slub_alloc+0x1a>
ffffffffc02015ba:	0685                	addi	a3,a3,1
ffffffffc02015bc:	03070713          	addi	a4,a4,48
ffffffffc02015c0:	feb687e3          	beq	a3,a1,ffffffffc02015ae <slub_alloc+0x4>
        if (size <= Slab_size(slab->order) && slab->free_objects.nr_free > 0) {
ffffffffc02015c4:	6f1c                	ld	a5,24(a4)
ffffffffc02015c6:	00f617bb          	sllw	a5,a2,a5
ffffffffc02015ca:	fea7e8e3          	bltu	a5,a0,ffffffffc02015ba <slub_alloc+0x10>
ffffffffc02015ce:	4b1c                	lw	a5,16(a4)
ffffffffc02015d0:	d7ed                	beqz	a5,ffffffffc02015ba <slub_alloc+0x10>
            // 找到合适的 slab，分配对象
            list_entry_t *freelist_entry = slab->free_objects.free_list.next;
ffffffffc02015d2:	00169793          	slli	a5,a3,0x1
ffffffffc02015d6:	96be                	add	a3,a3,a5
ffffffffc02015d8:	0692                	slli	a3,a3,0x4
ffffffffc02015da:	00005797          	auipc	a5,0x5
ffffffffc02015de:	a4e78793          	addi	a5,a5,-1458 # ffffffffc0206028 <slab_list>
ffffffffc02015e2:	97b6                	add	a5,a5,a3
ffffffffc02015e4:	6788                	ld	a0,8(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015e6:	6518                	ld	a4,8(a0)
ffffffffc02015e8:	6114                	ld	a3,0(a0)
            Object_t *obj = le2object(freelist_entry, object_link);
ffffffffc02015ea:	1561                	addi	a0,a0,-8
    prev->next = next;
ffffffffc02015ec:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02015ee:	e314                	sd	a3,0(a4)
            list_del(freelist_entry); // 从空闲链表中删除
            slab->free_objects.nr_free--; // 更新空闲数量
ffffffffc02015f0:	4b98                	lw	a4,16(a5)
ffffffffc02015f2:	377d                	addiw	a4,a4,-1
ffffffffc02015f4:	cb98                	sw	a4,16(a5)
        }
    }

    // 如果没有合适的 slab，分配新的页面
    return slub_alloc(size);
}
ffffffffc02015f6:	8082                	ret

ffffffffc02015f8 <slub_check>:

static void slub_free_pages(struct Page *base, size_t n) {
    free_pages(base, n); // 释放 n 页面
}

void slub_check(void) {
ffffffffc02015f8:	715d                	addi	sp,sp,-80
ffffffffc02015fa:	e85a                	sd	s6,16(sp)
ffffffffc02015fc:	00005b17          	auipc	s6,0x5
ffffffffc0201600:	a2cb0b13          	addi	s6,s6,-1492 # ffffffffc0206028 <slab_list>
ffffffffc0201604:	f44e                	sd	s3,40(sp)
ffffffffc0201606:	e486                	sd	ra,72(sp)
ffffffffc0201608:	e0a2                	sd	s0,64(sp)
ffffffffc020160a:	fc26                	sd	s1,56(sp)
ffffffffc020160c:	f84a                	sd	s2,48(sp)
ffffffffc020160e:	f052                	sd	s4,32(sp)
ffffffffc0201610:	ec56                	sd	s5,24(sp)
ffffffffc0201612:	e45e                	sd	s7,8(sp)
ffffffffc0201614:	e062                	sd	s8,0(sp)
ffffffffc0201616:	89da                	mv	s3,s6
ffffffffc0201618:	87da                	mv	a5,s6
    for (size_t i = MIN_ORDER; i <= MAX_ORDER; i++) {
ffffffffc020161a:	4711                	li	a4,4
    slab->num_objects = Object_num(order);
ffffffffc020161c:	4531                	li	a0,12
ffffffffc020161e:	4585                	li	a1,1
    for (size_t i = MIN_ORDER; i <= MAX_ORDER; i++) {
ffffffffc0201620:	4631                	li	a2,12
    slab->num_objects = Object_num(order);
ffffffffc0201622:	40e506bb          	subw	a3,a0,a4
ffffffffc0201626:	00d596bb          	sllw	a3,a1,a3
    slab->order = order;
ffffffffc020162a:	ef98                	sd	a4,24(a5)
    slab->num_objects = Object_num(order);
ffffffffc020162c:	f394                	sd	a3,32(a5)
    elm->prev = elm->next = elm;
ffffffffc020162e:	e79c                	sd	a5,8(a5)
ffffffffc0201630:	e39c                	sd	a5,0(a5)
    slab->free_objects.nr_free = 0; // 初始化空闲块数量
ffffffffc0201632:	0007a823          	sw	zero,16(a5)
    slab->pages = NULL; // 初始化页面为 NULL
ffffffffc0201636:	0207b423          	sd	zero,40(a5)
    for (size_t i = MIN_ORDER; i <= MAX_ORDER; i++) {
ffffffffc020163a:	0705                	addi	a4,a4,1
ffffffffc020163c:	03078793          	addi	a5,a5,48
ffffffffc0201640:	fec711e3          	bne	a4,a2,ffffffffc0201622 <slub_check+0x2a>
ffffffffc0201644:	00005417          	auipc	s0,0x5
ffffffffc0201648:	9e440413          	addi	s0,s0,-1564 # ffffffffc0206028 <slab_list>
    for (size_t i = 0; i < (MAX_ORDER - MIN_ORDER + 1); ++i) {
ffffffffc020164c:	4c01                	li	s8,0
        cprintf("Allocated page %p for slab %d\n", page, i);
ffffffffc020164e:	00001917          	auipc	s2,0x1
ffffffffc0201652:	47290913          	addi	s2,s2,1138 # ffffffffc0202ac0 <default_pmm_manager+0x188>
            Object_t *obj = (Object_t *)((char*)page + j * Slab_size(slab->order)); // 使用 Slab_size 计算对象地址
ffffffffc0201656:	4b85                	li	s7,1
            cprintf("Failed to allocate page for slab %zu\n", i);
ffffffffc0201658:	00001a17          	auipc	s4,0x1
ffffffffc020165c:	440a0a13          	addi	s4,s4,1088 # ffffffffc0202a98 <default_pmm_manager+0x160>
    for (size_t i = 0; i < (MAX_ORDER - MIN_ORDER + 1); ++i) {
ffffffffc0201660:	44a1                	li	s1,8
        struct Page* page = alloc_pages(4); // 分配4个页面
ffffffffc0201662:	4511                	li	a0,4
ffffffffc0201664:	cf7ff0ef          	jal	ra,ffffffffc020135a <alloc_pages>
ffffffffc0201668:	8aaa                	mv	s5,a0
        if (!page) {
ffffffffc020166a:	10050863          	beqz	a0,ffffffffc020177a <slub_check+0x182>
        slab->free_objects.nr_free = slab->num_objects; // 初始化空闲块数量
ffffffffc020166e:	701c                	ld	a5,32(s0)
        cprintf("Allocated page %p for slab %d\n", page, i);
ffffffffc0201670:	85aa                	mv	a1,a0
ffffffffc0201672:	8662                	mv	a2,s8
        slab->free_objects.nr_free = slab->num_objects; // 初始化空闲块数量
ffffffffc0201674:	c81c                	sw	a5,16(s0)
        cprintf("Allocated page %p for slab %d\n", page, i);
ffffffffc0201676:	854a                	mv	a0,s2
        slab->pages = page; // 将当前页面关联到 slab
ffffffffc0201678:	03543423          	sd	s5,40(s0)
        cprintf("Allocated page %p for slab %d\n", page, i);
ffffffffc020167c:	a37fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        for (size_t j = 0; j < slab->num_objects; j++) {
ffffffffc0201680:	701c                	ld	a5,32(s0)
ffffffffc0201682:	4701                	li	a4,0
ffffffffc0201684:	c785                	beqz	a5,ffffffffc02016ac <slub_check+0xb4>
            Object_t *obj = (Object_t *)((char*)page + j * Slab_size(slab->order)); // 使用 Slab_size 计算对象地址
ffffffffc0201686:	6c1c                	ld	a5,24(s0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201688:	6414                	ld	a3,8(s0)
ffffffffc020168a:	00fb97bb          	sllw	a5,s7,a5
ffffffffc020168e:	02e787b3          	mul	a5,a5,a4
        for (size_t j = 0; j < slab->num_objects; j++) {
ffffffffc0201692:	0705                	addi	a4,a4,1
            Object_t *obj = (Object_t *)((char*)page + j * Slab_size(slab->order)); // 使用 Slab_size 计算对象地址
ffffffffc0201694:	97d6                	add	a5,a5,s5
            list_add(&slab->free_objects.free_list, &obj->object_link); // 添加到空闲对象链表
ffffffffc0201696:	00878813          	addi	a6,a5,8
    prev->next = next->prev = elm;
ffffffffc020169a:	0106b023          	sd	a6,0(a3) # fffffffffec00000 <end+0x3e9f9a10>
ffffffffc020169e:	01043423          	sd	a6,8(s0)
    elm->next = next;
ffffffffc02016a2:	eb94                	sd	a3,16(a5)
    elm->prev = prev;
ffffffffc02016a4:	e780                	sd	s0,8(a5)
        for (size_t j = 0; j < slab->num_objects; j++) {
ffffffffc02016a6:	701c                	ld	a5,32(s0)
ffffffffc02016a8:	fcf76fe3          	bltu	a4,a5,ffffffffc0201686 <slub_check+0x8e>
    for (size_t i = 0; i < (MAX_ORDER - MIN_ORDER + 1); ++i) {
ffffffffc02016ac:	0c05                	addi	s8,s8,1
ffffffffc02016ae:	03040413          	addi	s0,s0,48
ffffffffc02016b2:	fa9c18e3          	bne	s8,s1,ffffffffc0201662 <slub_check+0x6a>
    slub_init();
    slub_init_memmap();

    void *ptr1 = slub_alloc(1024);
ffffffffc02016b6:	40000513          	li	a0,1024
ffffffffc02016ba:	ef1ff0ef          	jal	ra,ffffffffc02015aa <slub_alloc>
ffffffffc02016be:	842a                	mv	s0,a0
    void *ptr2 = slub_alloc(2048);
ffffffffc02016c0:	6505                	lui	a0,0x1
ffffffffc02016c2:	80050513          	addi	a0,a0,-2048 # 800 <kern_entry-0xffffffffc01ff800>
ffffffffc02016c6:	ee5ff0ef          	jal	ra,ffffffffc02015aa <slub_alloc>
ffffffffc02016ca:	84aa                	mv	s1,a0
        struct Page *new_page = alloc_pages((size + PGSIZE - 1) / PGSIZE); // 分配页面
ffffffffc02016cc:	4505                	li	a0,1
ffffffffc02016ce:	c8dff0ef          	jal	ra,ffffffffc020135a <alloc_pages>
    void *ptr3 = slub_alloc(4096);

    assert(ptr1 != NULL);
ffffffffc02016d2:	12040663          	beqz	s0,ffffffffc02017fe <slub_check+0x206>
    assert(ptr2 != NULL);
ffffffffc02016d6:	10048463          	beqz	s1,ffffffffc02017de <slub_check+0x1e6>
    assert(ptr3 != NULL);
ffffffffc02016da:	00005917          	auipc	s2,0x5
ffffffffc02016de:	ace90913          	addi	s2,s2,-1330 # ffffffffc02061a8 <buf>

    // 检查每个 slab 的状态
    for (size_t i = 0; i < MAX_ORDER - MIN_ORDER + 1; i++) {
        Slab_t *slab = &slab_list[i];
        cprintf("Slab order %d: num_objects %d, free %d\n",
ffffffffc02016e2:	00001497          	auipc	s1,0x1
ffffffffc02016e6:	44648493          	addi	s1,s1,1094 # ffffffffc0202b28 <default_pmm_manager+0x1f0>
    assert(ptr3 != NULL);
ffffffffc02016ea:	12050a63          	beqz	a0,ffffffffc020181e <slub_check+0x226>
        cprintf("Slab order %d: num_objects %d, free %d\n",
ffffffffc02016ee:	010b2683          	lw	a3,16(s6)
ffffffffc02016f2:	020b3603          	ld	a2,32(s6)
ffffffffc02016f6:	018b3583          	ld	a1,24(s6)
ffffffffc02016fa:	8526                	mv	a0,s1
    for (size_t i = 0; i < MAX_ORDER - MIN_ORDER + 1; i++) {
ffffffffc02016fc:	030b0b13          	addi	s6,s6,48
        cprintf("Slab order %d: num_objects %d, free %d\n",
ffffffffc0201700:	9b3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (size_t i = 0; i < MAX_ORDER - MIN_ORDER + 1; i++) {
ffffffffc0201704:	ff6915e3          	bne	s2,s6,ffffffffc02016ee <slub_check+0xf6>
    size_t order = obj->order; // 获取对象的 order
ffffffffc0201708:	6010                	ld	a2,0(s0)
    __list_add(elm, listelm, listelm->next);
ffffffffc020170a:	01043803          	ld	a6,16(s0)
    list_add(&obj->object_link, &slab->free_objects.free_list); // 将对象添加回空闲链表
ffffffffc020170e:	00840713          	addi	a4,s0,8
    Slab_t *slab = &slab_list[order - MIN_ORDER];
ffffffffc0201712:	ffc60513          	addi	a0,a2,-4
    list_add(&obj->object_link, &slab->free_objects.free_list); // 将对象添加回空闲链表
ffffffffc0201716:	00151593          	slli	a1,a0,0x1
ffffffffc020171a:	00a587b3          	add	a5,a1,a0
ffffffffc020171e:	0792                	slli	a5,a5,0x4
ffffffffc0201720:	97ce                	add	a5,a5,s3
    prev->next = next->prev = elm;
ffffffffc0201722:	00f83023          	sd	a5,0(a6) # fffffffffff80000 <end+0x3fd79a10>
ffffffffc0201726:	e81c                	sd	a5,16(s0)
    slab->free_objects.nr_free++; // 更新空闲数量
ffffffffc0201728:	4b94                	lw	a3,16(a5)
    elm->next = next;
ffffffffc020172a:	0107b423          	sd	a6,8(a5)
    elm->prev = prev;
ffffffffc020172e:	e398                	sd	a4,0(a5)
ffffffffc0201730:	2685                	addiw	a3,a3,1
ffffffffc0201732:	cb94                	sw	a3,16(a5)
    if (le != &slab->free_objects.free_list) { // 如果不是空链表
ffffffffc0201734:	04f70d63          	beq	a4,a5,ffffffffc020178e <slub_check+0x196>
        if ((uintptr_t)prev_obj + Slab_size(order) == (uintptr_t)obj) { // 判断是否相邻
ffffffffc0201738:	4685                	li	a3,1
ffffffffc020173a:	00c696bb          	sllw	a3,a3,a2
    __list_del(listelm->prev, listelm->next);
ffffffffc020173e:	6818                	ld	a4,16(s0)
ffffffffc0201740:	c6b5                	beqz	a3,ffffffffc02017ac <slub_check+0x1b4>
    if (le != &slab->free_objects.free_list) { // 如果不是空链表
ffffffffc0201742:	00e78a63          	beq	a5,a4,ffffffffc0201756 <slub_check+0x15e>
        if ((uintptr_t)obj + Slab_size(order) == (uintptr_t)next_obj) { // 判断是否相邻
ffffffffc0201746:	4785                	li	a5,1
ffffffffc0201748:	00c797bb          	sllw	a5,a5,a2
ffffffffc020174c:	97a2                	add	a5,a5,s0
        Object_t *next_obj = le2object(le, object_link); // 获取下一个对象
ffffffffc020174e:	ff870693          	addi	a3,a4,-8
        if ((uintptr_t)obj + Slab_size(order) == (uintptr_t)next_obj) { // 判断是否相邻
ffffffffc0201752:	04d78063          	beq	a5,a3,ffffffffc0201792 <slub_check+0x19a>
    // 释放分配的内存
    slub_free(ptr1);
    //slub_free(ptr2);
    //slub_free(ptr3);

    assert(slab_list[MIN_ORDER].free_objects.nr_free == slab_list[MIN_ORDER].num_objects);
ffffffffc0201756:	0d09e703          	lwu	a4,208(s3)
ffffffffc020175a:	0e09b783          	ld	a5,224(s3)
ffffffffc020175e:	06f71063          	bne	a4,a5,ffffffffc02017be <slub_check+0x1c6>
ffffffffc0201762:	60a6                	ld	ra,72(sp)
ffffffffc0201764:	6406                	ld	s0,64(sp)
ffffffffc0201766:	74e2                	ld	s1,56(sp)
ffffffffc0201768:	7942                	ld	s2,48(sp)
ffffffffc020176a:	79a2                	ld	s3,40(sp)
ffffffffc020176c:	7a02                	ld	s4,32(sp)
ffffffffc020176e:	6ae2                	ld	s5,24(sp)
ffffffffc0201770:	6b42                	ld	s6,16(sp)
ffffffffc0201772:	6ba2                	ld	s7,8(sp)
ffffffffc0201774:	6c02                	ld	s8,0(sp)
ffffffffc0201776:	6161                	addi	sp,sp,80
ffffffffc0201778:	8082                	ret
            cprintf("Failed to allocate page for slab %zu\n", i);
ffffffffc020177a:	85e2                	mv	a1,s8
ffffffffc020177c:	8552                	mv	a0,s4
    for (size_t i = 0; i < (MAX_ORDER - MIN_ORDER + 1); ++i) {
ffffffffc020177e:	0c05                	addi	s8,s8,1
            cprintf("Failed to allocate page for slab %zu\n", i);
ffffffffc0201780:	933fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (size_t i = 0; i < (MAX_ORDER - MIN_ORDER + 1); ++i) {
ffffffffc0201784:	03040413          	addi	s0,s0,48
ffffffffc0201788:	ec9c1de3          	bne	s8,s1,ffffffffc0201662 <slub_check+0x6a>
ffffffffc020178c:	b72d                	j	ffffffffc02016b6 <slub_check+0xbe>
    return listelm->next;
ffffffffc020178e:	6818                	ld	a4,16(s0)
ffffffffc0201790:	bf4d                	j	ffffffffc0201742 <slub_check+0x14a>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201792:	6314                	ld	a3,0(a4)
ffffffffc0201794:	6718                	ld	a4,8(a4)
            slab->free_objects.nr_free--; // 减少空闲数量
ffffffffc0201796:	00a587b3          	add	a5,a1,a0
ffffffffc020179a:	0792                	slli	a5,a5,0x4
    prev->next = next;
ffffffffc020179c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020179e:	e314                	sd	a3,0(a4)
ffffffffc02017a0:	97ce                	add	a5,a5,s3
ffffffffc02017a2:	4b98                	lw	a4,16(a5)
ffffffffc02017a4:	377d                	addiw	a4,a4,-1
ffffffffc02017a6:	cb98                	sw	a4,16(a5)
            obj->order = order; // 更新 order
ffffffffc02017a8:	e010                	sd	a2,0(s0)
ffffffffc02017aa:	b775                	j	ffffffffc0201756 <slub_check+0x15e>
    __list_del(listelm->prev, listelm->next);
ffffffffc02017ac:	6414                	ld	a3,8(s0)
    prev->next = next;
ffffffffc02017ae:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02017b0:	e314                	sd	a3,0(a4)
            slab->free_objects.nr_free--; // 减少空闲数量
ffffffffc02017b2:	4b98                	lw	a4,16(a5)
ffffffffc02017b4:	377d                	addiw	a4,a4,-1
ffffffffc02017b6:	cb98                	sw	a4,16(a5)
    return listelm->next;
ffffffffc02017b8:	6818                	ld	a4,16(s0)
            obj->order = order; // 更新 order
ffffffffc02017ba:	e010                	sd	a2,0(s0)
ffffffffc02017bc:	b759                	j	ffffffffc0201742 <slub_check+0x14a>
    assert(slab_list[MIN_ORDER].free_objects.nr_free == slab_list[MIN_ORDER].num_objects);
ffffffffc02017be:	00001697          	auipc	a3,0x1
ffffffffc02017c2:	39268693          	addi	a3,a3,914 # ffffffffc0202b50 <default_pmm_manager+0x218>
ffffffffc02017c6:	00001617          	auipc	a2,0x1
ffffffffc02017ca:	dc260613          	addi	a2,a2,-574 # ffffffffc0202588 <commands+0x598>
ffffffffc02017ce:	09f00593          	li	a1,159
ffffffffc02017d2:	00001517          	auipc	a0,0x1
ffffffffc02017d6:	31e50513          	addi	a0,a0,798 # ffffffffc0202af0 <default_pmm_manager+0x1b8>
ffffffffc02017da:	bd3fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ptr2 != NULL);
ffffffffc02017de:	00001697          	auipc	a3,0x1
ffffffffc02017e2:	32a68693          	addi	a3,a3,810 # ffffffffc0202b08 <default_pmm_manager+0x1d0>
ffffffffc02017e6:	00001617          	auipc	a2,0x1
ffffffffc02017ea:	da260613          	addi	a2,a2,-606 # ffffffffc0202588 <commands+0x598>
ffffffffc02017ee:	09000593          	li	a1,144
ffffffffc02017f2:	00001517          	auipc	a0,0x1
ffffffffc02017f6:	2fe50513          	addi	a0,a0,766 # ffffffffc0202af0 <default_pmm_manager+0x1b8>
ffffffffc02017fa:	bb3fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ptr1 != NULL);
ffffffffc02017fe:	00001697          	auipc	a3,0x1
ffffffffc0201802:	2e268693          	addi	a3,a3,738 # ffffffffc0202ae0 <default_pmm_manager+0x1a8>
ffffffffc0201806:	00001617          	auipc	a2,0x1
ffffffffc020180a:	d8260613          	addi	a2,a2,-638 # ffffffffc0202588 <commands+0x598>
ffffffffc020180e:	08f00593          	li	a1,143
ffffffffc0201812:	00001517          	auipc	a0,0x1
ffffffffc0201816:	2de50513          	addi	a0,a0,734 # ffffffffc0202af0 <default_pmm_manager+0x1b8>
ffffffffc020181a:	b93fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ptr3 != NULL);
ffffffffc020181e:	00001697          	auipc	a3,0x1
ffffffffc0201822:	2fa68693          	addi	a3,a3,762 # ffffffffc0202b18 <default_pmm_manager+0x1e0>
ffffffffc0201826:	00001617          	auipc	a2,0x1
ffffffffc020182a:	d6260613          	addi	a2,a2,-670 # ffffffffc0202588 <commands+0x598>
ffffffffc020182e:	09100593          	li	a1,145
ffffffffc0201832:	00001517          	auipc	a0,0x1
ffffffffc0201836:	2be50513          	addi	a0,a0,702 # ffffffffc0202af0 <default_pmm_manager+0x1b8>
ffffffffc020183a:	b73fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020183e <printnum>:
=======
ffffffffc0200f06:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200f0a:	02f57463          	bgeu	a0,a5,ffffffffc0200f32 <pmm_init+0x19c>
    pmm_manager->init_memmap(base, n);
ffffffffc0200f0e:	0009b703          	ld	a4,0(s3)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200f12:	fff807b7          	lui	a5,0xfff80
ffffffffc0200f16:	97aa                	add	a5,a5,a0
ffffffffc0200f18:	00279513          	slli	a0,a5,0x2
ffffffffc0200f1c:	953e                	add	a0,a0,a5
ffffffffc0200f1e:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200f20:	8d95                	sub	a1,a1,a3
ffffffffc0200f22:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200f24:	81b1                	srli	a1,a1,0xc
ffffffffc0200f26:	9532                	add	a0,a0,a2
ffffffffc0200f28:	9782                	jalr	a5
}
ffffffffc0200f2a:	bfbd                	j	ffffffffc0200ea8 <pmm_init+0x112>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f2c:	01400737          	lui	a4,0x1400
ffffffffc0200f30:	bfa1                	j	ffffffffc0200e88 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc0200f32:	00001617          	auipc	a2,0x1
ffffffffc0200f36:	fa660613          	addi	a2,a2,-90 # ffffffffc0201ed8 <buddy_system_pmm_manager+0x108>
ffffffffc0200f3a:	07b00593          	li	a1,123
ffffffffc0200f3e:	00001517          	auipc	a0,0x1
ffffffffc0200f42:	fba50513          	addi	a0,a0,-70 # ffffffffc0201ef8 <buddy_system_pmm_manager+0x128>
ffffffffc0200f46:	c66ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase)); //nbase：表示内存中第一个可分配物理页的基准页号
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	f1e60613          	addi	a2,a2,-226 # ffffffffc0201e68 <buddy_system_pmm_manager+0x98>
ffffffffc0200f52:	08b00593          	li	a1,139
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	f3a50513          	addi	a0,a0,-198 # ffffffffc0201e90 <buddy_system_pmm_manager+0xc0>
ffffffffc0200f5e:	c4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    first_ppn = PADDR(pages) / PGSIZE;  // 设置 first_ppn 为第一个可分配物理页的页号
ffffffffc0200f62:	00001617          	auipc	a2,0x1
ffffffffc0200f66:	f0660613          	addi	a2,a2,-250 # ffffffffc0201e68 <buddy_system_pmm_manager+0x98>
ffffffffc0200f6a:	08200593          	li	a1,130
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	f2250513          	addi	a0,a0,-222 # ffffffffc0201e90 <buddy_system_pmm_manager+0xc0>
ffffffffc0200f76:	c36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f7a:	86ae                	mv	a3,a1
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	eec60613          	addi	a2,a2,-276 # ffffffffc0201e68 <buddy_system_pmm_manager+0x98>
ffffffffc0200f84:	0a600593          	li	a1,166
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	f0850513          	addi	a0,a0,-248 # ffffffffc0201e90 <buddy_system_pmm_manager+0xc0>
ffffffffc0200f90:	c1cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f94 <printnum>:
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
<<<<<<< HEAD
ffffffffc020183e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201842:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201844:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201848:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020184a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020184e:	f022                	sd	s0,32(sp)
ffffffffc0201850:	ec26                	sd	s1,24(sp)
ffffffffc0201852:	e84a                	sd	s2,16(sp)
ffffffffc0201854:	f406                	sd	ra,40(sp)
ffffffffc0201856:	e44e                	sd	s3,8(sp)
ffffffffc0201858:	84aa                	mv	s1,a0
ffffffffc020185a:	892e                	mv	s2,a1
=======
ffffffffc0200f94:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f98:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200f9a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f9e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200fa0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200fa4:	f022                	sd	s0,32(sp)
ffffffffc0200fa6:	ec26                	sd	s1,24(sp)
ffffffffc0200fa8:	e84a                	sd	s2,16(sp)
ffffffffc0200faa:	f406                	sd	ra,40(sp)
ffffffffc0200fac:	e44e                	sd	s3,8(sp)
ffffffffc0200fae:	84aa                	mv	s1,a0
ffffffffc0200fb0:	892e                	mv	s2,a1
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
<<<<<<< HEAD
ffffffffc020185c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201860:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201862:	03067e63          	bgeu	a2,a6,ffffffffc020189e <printnum+0x60>
ffffffffc0201866:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201868:	00805763          	blez	s0,ffffffffc0201876 <printnum+0x38>
ffffffffc020186c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020186e:	85ca                	mv	a1,s2
ffffffffc0201870:	854e                	mv	a0,s3
ffffffffc0201872:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201874:	fc65                	bnez	s0,ffffffffc020186c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201876:	1a02                	slli	s4,s4,0x20
ffffffffc0201878:	00001797          	auipc	a5,0x1
ffffffffc020187c:	32878793          	addi	a5,a5,808 # ffffffffc0202ba0 <default_pmm_manager+0x268>
ffffffffc0201880:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201884:	9a3e                	add	s4,s4,a5
}
ffffffffc0201886:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201888:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020188c:	70a2                	ld	ra,40(sp)
ffffffffc020188e:	69a2                	ld	s3,8(sp)
ffffffffc0201890:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201892:	85ca                	mv	a1,s2
ffffffffc0201894:	87a6                	mv	a5,s1
}
ffffffffc0201896:	6942                	ld	s2,16(sp)
ffffffffc0201898:	64e2                	ld	s1,24(sp)
ffffffffc020189a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020189c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020189e:	03065633          	divu	a2,a2,a6
ffffffffc02018a2:	8722                	mv	a4,s0
ffffffffc02018a4:	f9bff0ef          	jal	ra,ffffffffc020183e <printnum>
ffffffffc02018a8:	b7f9                	j	ffffffffc0201876 <printnum+0x38>

ffffffffc02018aa <vprintfmt>:
=======
ffffffffc0200fb2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200fb6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200fb8:	03067e63          	bgeu	a2,a6,ffffffffc0200ff4 <printnum+0x60>
ffffffffc0200fbc:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200fbe:	00805763          	blez	s0,ffffffffc0200fcc <printnum+0x38>
ffffffffc0200fc2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200fc4:	85ca                	mv	a1,s2
ffffffffc0200fc6:	854e                	mv	a0,s3
ffffffffc0200fc8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200fca:	fc65                	bnez	s0,ffffffffc0200fc2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fcc:	1a02                	slli	s4,s4,0x20
ffffffffc0200fce:	00001797          	auipc	a5,0x1
ffffffffc0200fd2:	f9a78793          	addi	a5,a5,-102 # ffffffffc0201f68 <buddy_system_pmm_manager+0x198>
ffffffffc0200fd6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200fda:	9a3e                	add	s4,s4,a5
}
ffffffffc0200fdc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fde:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200fe2:	70a2                	ld	ra,40(sp)
ffffffffc0200fe4:	69a2                	ld	s3,8(sp)
ffffffffc0200fe6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200fe8:	85ca                	mv	a1,s2
ffffffffc0200fea:	87a6                	mv	a5,s1
}
ffffffffc0200fec:	6942                	ld	s2,16(sp)
ffffffffc0200fee:	64e2                	ld	s1,24(sp)
ffffffffc0200ff0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200ff2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200ff4:	03065633          	divu	a2,a2,a6
ffffffffc0200ff8:	8722                	mv	a4,s0
ffffffffc0200ffa:	f9bff0ef          	jal	ra,ffffffffc0200f94 <printnum>
ffffffffc0200ffe:	b7f9                	j	ffffffffc0200fcc <printnum+0x38>

ffffffffc0201000 <vprintfmt>:
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
<<<<<<< HEAD
ffffffffc02018aa:	7119                	addi	sp,sp,-128
ffffffffc02018ac:	f4a6                	sd	s1,104(sp)
ffffffffc02018ae:	f0ca                	sd	s2,96(sp)
ffffffffc02018b0:	ecce                	sd	s3,88(sp)
ffffffffc02018b2:	e8d2                	sd	s4,80(sp)
ffffffffc02018b4:	e4d6                	sd	s5,72(sp)
ffffffffc02018b6:	e0da                	sd	s6,64(sp)
ffffffffc02018b8:	fc5e                	sd	s7,56(sp)
ffffffffc02018ba:	f06a                	sd	s10,32(sp)
ffffffffc02018bc:	fc86                	sd	ra,120(sp)
ffffffffc02018be:	f8a2                	sd	s0,112(sp)
ffffffffc02018c0:	f862                	sd	s8,48(sp)
ffffffffc02018c2:	f466                	sd	s9,40(sp)
ffffffffc02018c4:	ec6e                	sd	s11,24(sp)
ffffffffc02018c6:	892a                	mv	s2,a0
ffffffffc02018c8:	84ae                	mv	s1,a1
ffffffffc02018ca:	8d32                	mv	s10,a2
ffffffffc02018cc:	8a36                	mv	s4,a3
=======
ffffffffc0201000:	7119                	addi	sp,sp,-128
ffffffffc0201002:	f4a6                	sd	s1,104(sp)
ffffffffc0201004:	f0ca                	sd	s2,96(sp)
ffffffffc0201006:	ecce                	sd	s3,88(sp)
ffffffffc0201008:	e8d2                	sd	s4,80(sp)
ffffffffc020100a:	e4d6                	sd	s5,72(sp)
ffffffffc020100c:	e0da                	sd	s6,64(sp)
ffffffffc020100e:	fc5e                	sd	s7,56(sp)
ffffffffc0201010:	f06a                	sd	s10,32(sp)
ffffffffc0201012:	fc86                	sd	ra,120(sp)
ffffffffc0201014:	f8a2                	sd	s0,112(sp)
ffffffffc0201016:	f862                	sd	s8,48(sp)
ffffffffc0201018:	f466                	sd	s9,40(sp)
ffffffffc020101a:	ec6e                	sd	s11,24(sp)
ffffffffc020101c:	892a                	mv	s2,a0
ffffffffc020101e:	84ae                	mv	s1,a1
ffffffffc0201020:	8d32                	mv	s10,a2
ffffffffc0201022:	8a36                	mv	s4,a3
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
<<<<<<< HEAD
ffffffffc02018ce:	02500993          	li	s3,37
=======
ffffffffc0201024:	02500993          	li	s3,37
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
<<<<<<< HEAD
ffffffffc02018d2:	5b7d                	li	s6,-1
ffffffffc02018d4:	00001a97          	auipc	s5,0x1
ffffffffc02018d8:	300a8a93          	addi	s5,s5,768 # ffffffffc0202bd4 <default_pmm_manager+0x29c>
=======
ffffffffc0201028:	5b7d                	li	s6,-1
ffffffffc020102a:	00001a97          	auipc	s5,0x1
ffffffffc020102e:	f72a8a93          	addi	s5,s5,-142 # ffffffffc0201f9c <buddy_system_pmm_manager+0x1cc>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
<<<<<<< HEAD
ffffffffc02018dc:	00001b97          	auipc	s7,0x1
ffffffffc02018e0:	4d4b8b93          	addi	s7,s7,1236 # ffffffffc0202db0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018e4:	000d4503          	lbu	a0,0(s10)
ffffffffc02018e8:	001d0413          	addi	s0,s10,1
ffffffffc02018ec:	01350a63          	beq	a0,s3,ffffffffc0201900 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02018f0:	c121                	beqz	a0,ffffffffc0201930 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02018f2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018f4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02018f6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018f8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02018fc:	ff351ae3          	bne	a0,s3,ffffffffc02018f0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201900:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201904:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201908:	4c81                	li	s9,0
ffffffffc020190a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020190c:	5c7d                	li	s8,-1
ffffffffc020190e:	5dfd                	li	s11,-1
ffffffffc0201910:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201914:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201916:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020191a:	0ff5f593          	zext.b	a1,a1
ffffffffc020191e:	00140d13          	addi	s10,s0,1
ffffffffc0201922:	04b56263          	bltu	a0,a1,ffffffffc0201966 <vprintfmt+0xbc>
ffffffffc0201926:	058a                	slli	a1,a1,0x2
ffffffffc0201928:	95d6                	add	a1,a1,s5
ffffffffc020192a:	4194                	lw	a3,0(a1)
ffffffffc020192c:	96d6                	add	a3,a3,s5
ffffffffc020192e:	8682                	jr	a3
=======
ffffffffc0201032:	00001b97          	auipc	s7,0x1
ffffffffc0201036:	146b8b93          	addi	s7,s7,326 # ffffffffc0202178 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020103a:	000d4503          	lbu	a0,0(s10)
ffffffffc020103e:	001d0413          	addi	s0,s10,1
ffffffffc0201042:	01350a63          	beq	a0,s3,ffffffffc0201056 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201046:	c121                	beqz	a0,ffffffffc0201086 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201048:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020104a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020104c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020104e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201052:	ff351ae3          	bne	a0,s3,ffffffffc0201046 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201056:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020105a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020105e:	4c81                	li	s9,0
ffffffffc0201060:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201062:	5c7d                	li	s8,-1
ffffffffc0201064:	5dfd                	li	s11,-1
ffffffffc0201066:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020106a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020106c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201070:	0ff5f593          	andi	a1,a1,255
ffffffffc0201074:	00140d13          	addi	s10,s0,1
ffffffffc0201078:	04b56263          	bltu	a0,a1,ffffffffc02010bc <vprintfmt+0xbc>
ffffffffc020107c:	058a                	slli	a1,a1,0x2
ffffffffc020107e:	95d6                	add	a1,a1,s5
ffffffffc0201080:	4194                	lw	a3,0(a1)
ffffffffc0201082:	96d6                	add	a3,a3,s5
ffffffffc0201084:	8682                	jr	a3
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
<<<<<<< HEAD
ffffffffc0201930:	70e6                	ld	ra,120(sp)
ffffffffc0201932:	7446                	ld	s0,112(sp)
ffffffffc0201934:	74a6                	ld	s1,104(sp)
ffffffffc0201936:	7906                	ld	s2,96(sp)
ffffffffc0201938:	69e6                	ld	s3,88(sp)
ffffffffc020193a:	6a46                	ld	s4,80(sp)
ffffffffc020193c:	6aa6                	ld	s5,72(sp)
ffffffffc020193e:	6b06                	ld	s6,64(sp)
ffffffffc0201940:	7be2                	ld	s7,56(sp)
ffffffffc0201942:	7c42                	ld	s8,48(sp)
ffffffffc0201944:	7ca2                	ld	s9,40(sp)
ffffffffc0201946:	7d02                	ld	s10,32(sp)
ffffffffc0201948:	6de2                	ld	s11,24(sp)
ffffffffc020194a:	6109                	addi	sp,sp,128
ffffffffc020194c:	8082                	ret
            padc = '0';
ffffffffc020194e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201950:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201954:	846a                	mv	s0,s10
ffffffffc0201956:	00140d13          	addi	s10,s0,1
ffffffffc020195a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020195e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201962:	fcb572e3          	bgeu	a0,a1,ffffffffc0201926 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201966:	85a6                	mv	a1,s1
ffffffffc0201968:	02500513          	li	a0,37
ffffffffc020196c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020196e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201972:	8d22                	mv	s10,s0
ffffffffc0201974:	f73788e3          	beq	a5,s3,ffffffffc02018e4 <vprintfmt+0x3a>
ffffffffc0201978:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020197c:	1d7d                	addi	s10,s10,-1
ffffffffc020197e:	ff379de3          	bne	a5,s3,ffffffffc0201978 <vprintfmt+0xce>
ffffffffc0201982:	b78d                	j	ffffffffc02018e4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201984:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201988:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020198c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020198e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201992:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201996:	02d86463          	bltu	a6,a3,ffffffffc02019be <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020199a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020199e:	002c169b          	slliw	a3,s8,0x2
ffffffffc02019a2:	0186873b          	addw	a4,a3,s8
ffffffffc02019a6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02019aa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02019ac:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02019b0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02019b2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02019b6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02019ba:	fed870e3          	bgeu	a6,a3,ffffffffc020199a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02019be:	f40ddce3          	bgez	s11,ffffffffc0201916 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02019c2:	8de2                	mv	s11,s8
ffffffffc02019c4:	5c7d                	li	s8,-1
ffffffffc02019c6:	bf81                	j	ffffffffc0201916 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02019c8:	fffdc693          	not	a3,s11
ffffffffc02019cc:	96fd                	srai	a3,a3,0x3f
ffffffffc02019ce:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019d2:	00144603          	lbu	a2,1(s0)
ffffffffc02019d6:	2d81                	sext.w	s11,s11
ffffffffc02019d8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02019da:	bf35                	j	ffffffffc0201916 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02019dc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019e0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02019e4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019e6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02019e8:	bfd9                	j	ffffffffc02019be <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02019ea:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02019ec:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02019f0:	01174463          	blt	a4,a7,ffffffffc02019f8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02019f4:	1a088e63          	beqz	a7,ffffffffc0201bb0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02019f8:	000a3603          	ld	a2,0(s4)
ffffffffc02019fc:	46c1                	li	a3,16
ffffffffc02019fe:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201a00:	2781                	sext.w	a5,a5
ffffffffc0201a02:	876e                	mv	a4,s11
ffffffffc0201a04:	85a6                	mv	a1,s1
ffffffffc0201a06:	854a                	mv	a0,s2
ffffffffc0201a08:	e37ff0ef          	jal	ra,ffffffffc020183e <printnum>
            break;
ffffffffc0201a0c:	bde1                	j	ffffffffc02018e4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201a0e:	000a2503          	lw	a0,0(s4)
ffffffffc0201a12:	85a6                	mv	a1,s1
ffffffffc0201a14:	0a21                	addi	s4,s4,8
ffffffffc0201a16:	9902                	jalr	s2
            break;
ffffffffc0201a18:	b5f1                	j	ffffffffc02018e4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201a1a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201a1c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201a20:	01174463          	blt	a4,a7,ffffffffc0201a28 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201a24:	18088163          	beqz	a7,ffffffffc0201ba6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201a28:	000a3603          	ld	a2,0(s4)
ffffffffc0201a2c:	46a9                	li	a3,10
ffffffffc0201a2e:	8a2e                	mv	s4,a1
ffffffffc0201a30:	bfc1                	j	ffffffffc0201a00 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a32:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201a36:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a38:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201a3a:	bdf1                	j	ffffffffc0201916 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201a3c:	85a6                	mv	a1,s1
ffffffffc0201a3e:	02500513          	li	a0,37
ffffffffc0201a42:	9902                	jalr	s2
            break;
ffffffffc0201a44:	b545                	j	ffffffffc02018e4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a46:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201a4a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a4c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201a4e:	b5e1                	j	ffffffffc0201916 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201a50:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201a52:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201a56:	01174463          	blt	a4,a7,ffffffffc0201a5e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201a5a:	14088163          	beqz	a7,ffffffffc0201b9c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201a5e:	000a3603          	ld	a2,0(s4)
ffffffffc0201a62:	46a1                	li	a3,8
ffffffffc0201a64:	8a2e                	mv	s4,a1
ffffffffc0201a66:	bf69                	j	ffffffffc0201a00 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201a68:	03000513          	li	a0,48
ffffffffc0201a6c:	85a6                	mv	a1,s1
ffffffffc0201a6e:	e03e                	sd	a5,0(sp)
ffffffffc0201a70:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201a72:	85a6                	mv	a1,s1
ffffffffc0201a74:	07800513          	li	a0,120
ffffffffc0201a78:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201a7a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201a7c:	6782                	ld	a5,0(sp)
ffffffffc0201a7e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201a80:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201a84:	bfb5                	j	ffffffffc0201a00 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201a86:	000a3403          	ld	s0,0(s4)
ffffffffc0201a8a:	008a0713          	addi	a4,s4,8
ffffffffc0201a8e:	e03a                	sd	a4,0(sp)
ffffffffc0201a90:	14040263          	beqz	s0,ffffffffc0201bd4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201a94:	0fb05763          	blez	s11,ffffffffc0201b82 <vprintfmt+0x2d8>
ffffffffc0201a98:	02d00693          	li	a3,45
ffffffffc0201a9c:	0cd79163          	bne	a5,a3,ffffffffc0201b5e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201aa0:	00044783          	lbu	a5,0(s0)
ffffffffc0201aa4:	0007851b          	sext.w	a0,a5
ffffffffc0201aa8:	cf85                	beqz	a5,ffffffffc0201ae0 <vprintfmt+0x236>
ffffffffc0201aaa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201aae:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ab2:	000c4563          	bltz	s8,ffffffffc0201abc <vprintfmt+0x212>
ffffffffc0201ab6:	3c7d                	addiw	s8,s8,-1
ffffffffc0201ab8:	036c0263          	beq	s8,s6,ffffffffc0201adc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201abc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201abe:	0e0c8e63          	beqz	s9,ffffffffc0201bba <vprintfmt+0x310>
ffffffffc0201ac2:	3781                	addiw	a5,a5,-32
ffffffffc0201ac4:	0ef47b63          	bgeu	s0,a5,ffffffffc0201bba <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201ac8:	03f00513          	li	a0,63
ffffffffc0201acc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ace:	000a4783          	lbu	a5,0(s4)
ffffffffc0201ad2:	3dfd                	addiw	s11,s11,-1
ffffffffc0201ad4:	0a05                	addi	s4,s4,1
ffffffffc0201ad6:	0007851b          	sext.w	a0,a5
ffffffffc0201ada:	ffe1                	bnez	a5,ffffffffc0201ab2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201adc:	01b05963          	blez	s11,ffffffffc0201aee <vprintfmt+0x244>
ffffffffc0201ae0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201ae2:	85a6                	mv	a1,s1
ffffffffc0201ae4:	02000513          	li	a0,32
ffffffffc0201ae8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201aea:	fe0d9be3          	bnez	s11,ffffffffc0201ae0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201aee:	6a02                	ld	s4,0(sp)
ffffffffc0201af0:	bbd5                	j	ffffffffc02018e4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201af2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201af4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201af8:	01174463          	blt	a4,a7,ffffffffc0201b00 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201afc:	08088d63          	beqz	a7,ffffffffc0201b96 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201b00:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201b04:	0a044d63          	bltz	s0,ffffffffc0201bbe <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201b08:	8622                	mv	a2,s0
ffffffffc0201b0a:	8a66                	mv	s4,s9
ffffffffc0201b0c:	46a9                	li	a3,10
ffffffffc0201b0e:	bdcd                	j	ffffffffc0201a00 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201b10:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201b14:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201b16:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201b18:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201b1c:	8fb5                	xor	a5,a5,a3
ffffffffc0201b1e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201b22:	02d74163          	blt	a4,a3,ffffffffc0201b44 <vprintfmt+0x29a>
ffffffffc0201b26:	00369793          	slli	a5,a3,0x3
ffffffffc0201b2a:	97de                	add	a5,a5,s7
ffffffffc0201b2c:	639c                	ld	a5,0(a5)
ffffffffc0201b2e:	cb99                	beqz	a5,ffffffffc0201b44 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201b30:	86be                	mv	a3,a5
ffffffffc0201b32:	00001617          	auipc	a2,0x1
ffffffffc0201b36:	09e60613          	addi	a2,a2,158 # ffffffffc0202bd0 <default_pmm_manager+0x298>
ffffffffc0201b3a:	85a6                	mv	a1,s1
ffffffffc0201b3c:	854a                	mv	a0,s2
ffffffffc0201b3e:	0ce000ef          	jal	ra,ffffffffc0201c0c <printfmt>
ffffffffc0201b42:	b34d                	j	ffffffffc02018e4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201b44:	00001617          	auipc	a2,0x1
ffffffffc0201b48:	07c60613          	addi	a2,a2,124 # ffffffffc0202bc0 <default_pmm_manager+0x288>
ffffffffc0201b4c:	85a6                	mv	a1,s1
ffffffffc0201b4e:	854a                	mv	a0,s2
ffffffffc0201b50:	0bc000ef          	jal	ra,ffffffffc0201c0c <printfmt>
ffffffffc0201b54:	bb41                	j	ffffffffc02018e4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201b56:	00001417          	auipc	s0,0x1
ffffffffc0201b5a:	06240413          	addi	s0,s0,98 # ffffffffc0202bb8 <default_pmm_manager+0x280>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b5e:	85e2                	mv	a1,s8
ffffffffc0201b60:	8522                	mv	a0,s0
ffffffffc0201b62:	e43e                	sd	a5,8(sp)
ffffffffc0201b64:	1cc000ef          	jal	ra,ffffffffc0201d30 <strnlen>
ffffffffc0201b68:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201b6c:	01b05b63          	blez	s11,ffffffffc0201b82 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201b70:	67a2                	ld	a5,8(sp)
ffffffffc0201b72:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b76:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201b78:	85a6                	mv	a1,s1
ffffffffc0201b7a:	8552                	mv	a0,s4
ffffffffc0201b7c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b7e:	fe0d9ce3          	bnez	s11,ffffffffc0201b76 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b82:	00044783          	lbu	a5,0(s0)
ffffffffc0201b86:	00140a13          	addi	s4,s0,1
ffffffffc0201b8a:	0007851b          	sext.w	a0,a5
ffffffffc0201b8e:	d3a5                	beqz	a5,ffffffffc0201aee <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b90:	05e00413          	li	s0,94
ffffffffc0201b94:	bf39                	j	ffffffffc0201ab2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201b96:	000a2403          	lw	s0,0(s4)
ffffffffc0201b9a:	b7ad                	j	ffffffffc0201b04 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201b9c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201ba0:	46a1                	li	a3,8
ffffffffc0201ba2:	8a2e                	mv	s4,a1
ffffffffc0201ba4:	bdb1                	j	ffffffffc0201a00 <vprintfmt+0x156>
ffffffffc0201ba6:	000a6603          	lwu	a2,0(s4)
ffffffffc0201baa:	46a9                	li	a3,10
ffffffffc0201bac:	8a2e                	mv	s4,a1
ffffffffc0201bae:	bd89                	j	ffffffffc0201a00 <vprintfmt+0x156>
ffffffffc0201bb0:	000a6603          	lwu	a2,0(s4)
ffffffffc0201bb4:	46c1                	li	a3,16
ffffffffc0201bb6:	8a2e                	mv	s4,a1
ffffffffc0201bb8:	b5a1                	j	ffffffffc0201a00 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201bba:	9902                	jalr	s2
ffffffffc0201bbc:	bf09                	j	ffffffffc0201ace <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201bbe:	85a6                	mv	a1,s1
ffffffffc0201bc0:	02d00513          	li	a0,45
ffffffffc0201bc4:	e03e                	sd	a5,0(sp)
ffffffffc0201bc6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201bc8:	6782                	ld	a5,0(sp)
ffffffffc0201bca:	8a66                	mv	s4,s9
ffffffffc0201bcc:	40800633          	neg	a2,s0
ffffffffc0201bd0:	46a9                	li	a3,10
ffffffffc0201bd2:	b53d                	j	ffffffffc0201a00 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201bd4:	03b05163          	blez	s11,ffffffffc0201bf6 <vprintfmt+0x34c>
ffffffffc0201bd8:	02d00693          	li	a3,45
ffffffffc0201bdc:	f6d79de3          	bne	a5,a3,ffffffffc0201b56 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201be0:	00001417          	auipc	s0,0x1
ffffffffc0201be4:	fd840413          	addi	s0,s0,-40 # ffffffffc0202bb8 <default_pmm_manager+0x280>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201be8:	02800793          	li	a5,40
ffffffffc0201bec:	02800513          	li	a0,40
ffffffffc0201bf0:	00140a13          	addi	s4,s0,1
ffffffffc0201bf4:	bd6d                	j	ffffffffc0201aae <vprintfmt+0x204>
ffffffffc0201bf6:	00001a17          	auipc	s4,0x1
ffffffffc0201bfa:	fc3a0a13          	addi	s4,s4,-61 # ffffffffc0202bb9 <default_pmm_manager+0x281>
ffffffffc0201bfe:	02800513          	li	a0,40
ffffffffc0201c02:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c06:	05e00413          	li	s0,94
ffffffffc0201c0a:	b565                	j	ffffffffc0201ab2 <vprintfmt+0x208>

ffffffffc0201c0c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c0c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201c0e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c12:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201c14:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c16:	ec06                	sd	ra,24(sp)
ffffffffc0201c18:	f83a                	sd	a4,48(sp)
ffffffffc0201c1a:	fc3e                	sd	a5,56(sp)
ffffffffc0201c1c:	e0c2                	sd	a6,64(sp)
ffffffffc0201c1e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201c20:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201c22:	c89ff0ef          	jal	ra,ffffffffc02018aa <vprintfmt>
}
ffffffffc0201c26:	60e2                	ld	ra,24(sp)
ffffffffc0201c28:	6161                	addi	sp,sp,80
ffffffffc0201c2a:	8082                	ret

ffffffffc0201c2c <readline>:
=======
ffffffffc0201086:	70e6                	ld	ra,120(sp)
ffffffffc0201088:	7446                	ld	s0,112(sp)
ffffffffc020108a:	74a6                	ld	s1,104(sp)
ffffffffc020108c:	7906                	ld	s2,96(sp)
ffffffffc020108e:	69e6                	ld	s3,88(sp)
ffffffffc0201090:	6a46                	ld	s4,80(sp)
ffffffffc0201092:	6aa6                	ld	s5,72(sp)
ffffffffc0201094:	6b06                	ld	s6,64(sp)
ffffffffc0201096:	7be2                	ld	s7,56(sp)
ffffffffc0201098:	7c42                	ld	s8,48(sp)
ffffffffc020109a:	7ca2                	ld	s9,40(sp)
ffffffffc020109c:	7d02                	ld	s10,32(sp)
ffffffffc020109e:	6de2                	ld	s11,24(sp)
ffffffffc02010a0:	6109                	addi	sp,sp,128
ffffffffc02010a2:	8082                	ret
            padc = '0';
ffffffffc02010a4:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02010a6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010aa:	846a                	mv	s0,s10
ffffffffc02010ac:	00140d13          	addi	s10,s0,1
ffffffffc02010b0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02010b4:	0ff5f593          	andi	a1,a1,255
ffffffffc02010b8:	fcb572e3          	bgeu	a0,a1,ffffffffc020107c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02010bc:	85a6                	mv	a1,s1
ffffffffc02010be:	02500513          	li	a0,37
ffffffffc02010c2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02010c4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02010c8:	8d22                	mv	s10,s0
ffffffffc02010ca:	f73788e3          	beq	a5,s3,ffffffffc020103a <vprintfmt+0x3a>
ffffffffc02010ce:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02010d2:	1d7d                	addi	s10,s10,-1
ffffffffc02010d4:	ff379de3          	bne	a5,s3,ffffffffc02010ce <vprintfmt+0xce>
ffffffffc02010d8:	b78d                	j	ffffffffc020103a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02010da:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02010de:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010e2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02010e4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02010e8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02010ec:	02d86463          	bltu	a6,a3,ffffffffc0201114 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02010f0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02010f4:	002c169b          	slliw	a3,s8,0x2
ffffffffc02010f8:	0186873b          	addw	a4,a3,s8
ffffffffc02010fc:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201100:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201102:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201106:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201108:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020110c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201110:	fed870e3          	bgeu	a6,a3,ffffffffc02010f0 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201114:	f40ddce3          	bgez	s11,ffffffffc020106c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201118:	8de2                	mv	s11,s8
ffffffffc020111a:	5c7d                	li	s8,-1
ffffffffc020111c:	bf81                	j	ffffffffc020106c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020111e:	fffdc693          	not	a3,s11
ffffffffc0201122:	96fd                	srai	a3,a3,0x3f
ffffffffc0201124:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201128:	00144603          	lbu	a2,1(s0)
ffffffffc020112c:	2d81                	sext.w	s11,s11
ffffffffc020112e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201130:	bf35                	j	ffffffffc020106c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201132:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201136:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020113a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020113c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020113e:	bfd9                	j	ffffffffc0201114 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201140:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201142:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201146:	01174463          	blt	a4,a7,ffffffffc020114e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020114a:	1a088e63          	beqz	a7,ffffffffc0201306 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020114e:	000a3603          	ld	a2,0(s4)
ffffffffc0201152:	46c1                	li	a3,16
ffffffffc0201154:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201156:	2781                	sext.w	a5,a5
ffffffffc0201158:	876e                	mv	a4,s11
ffffffffc020115a:	85a6                	mv	a1,s1
ffffffffc020115c:	854a                	mv	a0,s2
ffffffffc020115e:	e37ff0ef          	jal	ra,ffffffffc0200f94 <printnum>
            break;
ffffffffc0201162:	bde1                	j	ffffffffc020103a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201164:	000a2503          	lw	a0,0(s4)
ffffffffc0201168:	85a6                	mv	a1,s1
ffffffffc020116a:	0a21                	addi	s4,s4,8
ffffffffc020116c:	9902                	jalr	s2
            break;
ffffffffc020116e:	b5f1                	j	ffffffffc020103a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201170:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201172:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201176:	01174463          	blt	a4,a7,ffffffffc020117e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020117a:	18088163          	beqz	a7,ffffffffc02012fc <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020117e:	000a3603          	ld	a2,0(s4)
ffffffffc0201182:	46a9                	li	a3,10
ffffffffc0201184:	8a2e                	mv	s4,a1
ffffffffc0201186:	bfc1                	j	ffffffffc0201156 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201188:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020118c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020118e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201190:	bdf1                	j	ffffffffc020106c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201192:	85a6                	mv	a1,s1
ffffffffc0201194:	02500513          	li	a0,37
ffffffffc0201198:	9902                	jalr	s2
            break;
ffffffffc020119a:	b545                	j	ffffffffc020103a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020119c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02011a0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011a2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011a4:	b5e1                	j	ffffffffc020106c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02011a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011ac:	01174463          	blt	a4,a7,ffffffffc02011b4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02011b0:	14088163          	beqz	a7,ffffffffc02012f2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02011b4:	000a3603          	ld	a2,0(s4)
ffffffffc02011b8:	46a1                	li	a3,8
ffffffffc02011ba:	8a2e                	mv	s4,a1
ffffffffc02011bc:	bf69                	j	ffffffffc0201156 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02011be:	03000513          	li	a0,48
ffffffffc02011c2:	85a6                	mv	a1,s1
ffffffffc02011c4:	e03e                	sd	a5,0(sp)
ffffffffc02011c6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02011c8:	85a6                	mv	a1,s1
ffffffffc02011ca:	07800513          	li	a0,120
ffffffffc02011ce:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011d0:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02011d2:	6782                	ld	a5,0(sp)
ffffffffc02011d4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02011d6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02011da:	bfb5                	j	ffffffffc0201156 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02011dc:	000a3403          	ld	s0,0(s4)
ffffffffc02011e0:	008a0713          	addi	a4,s4,8
ffffffffc02011e4:	e03a                	sd	a4,0(sp)
ffffffffc02011e6:	14040263          	beqz	s0,ffffffffc020132a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02011ea:	0fb05763          	blez	s11,ffffffffc02012d8 <vprintfmt+0x2d8>
ffffffffc02011ee:	02d00693          	li	a3,45
ffffffffc02011f2:	0cd79163          	bne	a5,a3,ffffffffc02012b4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011f6:	00044783          	lbu	a5,0(s0)
ffffffffc02011fa:	0007851b          	sext.w	a0,a5
ffffffffc02011fe:	cf85                	beqz	a5,ffffffffc0201236 <vprintfmt+0x236>
ffffffffc0201200:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201204:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201208:	000c4563          	bltz	s8,ffffffffc0201212 <vprintfmt+0x212>
ffffffffc020120c:	3c7d                	addiw	s8,s8,-1
ffffffffc020120e:	036c0263          	beq	s8,s6,ffffffffc0201232 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201212:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201214:	0e0c8e63          	beqz	s9,ffffffffc0201310 <vprintfmt+0x310>
ffffffffc0201218:	3781                	addiw	a5,a5,-32
ffffffffc020121a:	0ef47b63          	bgeu	s0,a5,ffffffffc0201310 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020121e:	03f00513          	li	a0,63
ffffffffc0201222:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201224:	000a4783          	lbu	a5,0(s4)
ffffffffc0201228:	3dfd                	addiw	s11,s11,-1
ffffffffc020122a:	0a05                	addi	s4,s4,1
ffffffffc020122c:	0007851b          	sext.w	a0,a5
ffffffffc0201230:	ffe1                	bnez	a5,ffffffffc0201208 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201232:	01b05963          	blez	s11,ffffffffc0201244 <vprintfmt+0x244>
ffffffffc0201236:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201238:	85a6                	mv	a1,s1
ffffffffc020123a:	02000513          	li	a0,32
ffffffffc020123e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201240:	fe0d9be3          	bnez	s11,ffffffffc0201236 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201244:	6a02                	ld	s4,0(sp)
ffffffffc0201246:	bbd5                	j	ffffffffc020103a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201248:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020124a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020124e:	01174463          	blt	a4,a7,ffffffffc0201256 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201252:	08088d63          	beqz	a7,ffffffffc02012ec <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201256:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020125a:	0a044d63          	bltz	s0,ffffffffc0201314 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020125e:	8622                	mv	a2,s0
ffffffffc0201260:	8a66                	mv	s4,s9
ffffffffc0201262:	46a9                	li	a3,10
ffffffffc0201264:	bdcd                	j	ffffffffc0201156 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201266:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020126a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020126c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020126e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201272:	8fb5                	xor	a5,a5,a3
ffffffffc0201274:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201278:	02d74163          	blt	a4,a3,ffffffffc020129a <vprintfmt+0x29a>
ffffffffc020127c:	00369793          	slli	a5,a3,0x3
ffffffffc0201280:	97de                	add	a5,a5,s7
ffffffffc0201282:	639c                	ld	a5,0(a5)
ffffffffc0201284:	cb99                	beqz	a5,ffffffffc020129a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201286:	86be                	mv	a3,a5
ffffffffc0201288:	00001617          	auipc	a2,0x1
ffffffffc020128c:	d1060613          	addi	a2,a2,-752 # ffffffffc0201f98 <buddy_system_pmm_manager+0x1c8>
ffffffffc0201290:	85a6                	mv	a1,s1
ffffffffc0201292:	854a                	mv	a0,s2
ffffffffc0201294:	0ce000ef          	jal	ra,ffffffffc0201362 <printfmt>
ffffffffc0201298:	b34d                	j	ffffffffc020103a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020129a:	00001617          	auipc	a2,0x1
ffffffffc020129e:	cee60613          	addi	a2,a2,-786 # ffffffffc0201f88 <buddy_system_pmm_manager+0x1b8>
ffffffffc02012a2:	85a6                	mv	a1,s1
ffffffffc02012a4:	854a                	mv	a0,s2
ffffffffc02012a6:	0bc000ef          	jal	ra,ffffffffc0201362 <printfmt>
ffffffffc02012aa:	bb41                	j	ffffffffc020103a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02012ac:	00001417          	auipc	s0,0x1
ffffffffc02012b0:	cd440413          	addi	s0,s0,-812 # ffffffffc0201f80 <buddy_system_pmm_manager+0x1b0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012b4:	85e2                	mv	a1,s8
ffffffffc02012b6:	8522                	mv	a0,s0
ffffffffc02012b8:	e43e                	sd	a5,8(sp)
ffffffffc02012ba:	1cc000ef          	jal	ra,ffffffffc0201486 <strnlen>
ffffffffc02012be:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02012c2:	01b05b63          	blez	s11,ffffffffc02012d8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02012c6:	67a2                	ld	a5,8(sp)
ffffffffc02012c8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012cc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02012ce:	85a6                	mv	a1,s1
ffffffffc02012d0:	8552                	mv	a0,s4
ffffffffc02012d2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02012d4:	fe0d9ce3          	bnez	s11,ffffffffc02012cc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012d8:	00044783          	lbu	a5,0(s0)
ffffffffc02012dc:	00140a13          	addi	s4,s0,1
ffffffffc02012e0:	0007851b          	sext.w	a0,a5
ffffffffc02012e4:	d3a5                	beqz	a5,ffffffffc0201244 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012e6:	05e00413          	li	s0,94
ffffffffc02012ea:	bf39                	j	ffffffffc0201208 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02012ec:	000a2403          	lw	s0,0(s4)
ffffffffc02012f0:	b7ad                	j	ffffffffc020125a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02012f2:	000a6603          	lwu	a2,0(s4)
ffffffffc02012f6:	46a1                	li	a3,8
ffffffffc02012f8:	8a2e                	mv	s4,a1
ffffffffc02012fa:	bdb1                	j	ffffffffc0201156 <vprintfmt+0x156>
ffffffffc02012fc:	000a6603          	lwu	a2,0(s4)
ffffffffc0201300:	46a9                	li	a3,10
ffffffffc0201302:	8a2e                	mv	s4,a1
ffffffffc0201304:	bd89                	j	ffffffffc0201156 <vprintfmt+0x156>
ffffffffc0201306:	000a6603          	lwu	a2,0(s4)
ffffffffc020130a:	46c1                	li	a3,16
ffffffffc020130c:	8a2e                	mv	s4,a1
ffffffffc020130e:	b5a1                	j	ffffffffc0201156 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201310:	9902                	jalr	s2
ffffffffc0201312:	bf09                	j	ffffffffc0201224 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201314:	85a6                	mv	a1,s1
ffffffffc0201316:	02d00513          	li	a0,45
ffffffffc020131a:	e03e                	sd	a5,0(sp)
ffffffffc020131c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020131e:	6782                	ld	a5,0(sp)
ffffffffc0201320:	8a66                	mv	s4,s9
ffffffffc0201322:	40800633          	neg	a2,s0
ffffffffc0201326:	46a9                	li	a3,10
ffffffffc0201328:	b53d                	j	ffffffffc0201156 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020132a:	03b05163          	blez	s11,ffffffffc020134c <vprintfmt+0x34c>
ffffffffc020132e:	02d00693          	li	a3,45
ffffffffc0201332:	f6d79de3          	bne	a5,a3,ffffffffc02012ac <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201336:	00001417          	auipc	s0,0x1
ffffffffc020133a:	c4a40413          	addi	s0,s0,-950 # ffffffffc0201f80 <buddy_system_pmm_manager+0x1b0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020133e:	02800793          	li	a5,40
ffffffffc0201342:	02800513          	li	a0,40
ffffffffc0201346:	00140a13          	addi	s4,s0,1
ffffffffc020134a:	bd6d                	j	ffffffffc0201204 <vprintfmt+0x204>
ffffffffc020134c:	00001a17          	auipc	s4,0x1
ffffffffc0201350:	c35a0a13          	addi	s4,s4,-971 # ffffffffc0201f81 <buddy_system_pmm_manager+0x1b1>
ffffffffc0201354:	02800513          	li	a0,40
ffffffffc0201358:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020135c:	05e00413          	li	s0,94
ffffffffc0201360:	b565                	j	ffffffffc0201208 <vprintfmt+0x208>

ffffffffc0201362 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201362:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201364:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201368:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020136a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020136c:	ec06                	sd	ra,24(sp)
ffffffffc020136e:	f83a                	sd	a4,48(sp)
ffffffffc0201370:	fc3e                	sd	a5,56(sp)
ffffffffc0201372:	e0c2                	sd	a6,64(sp)
ffffffffc0201374:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201376:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201378:	c89ff0ef          	jal	ra,ffffffffc0201000 <vprintfmt>
}
ffffffffc020137c:	60e2                	ld	ra,24(sp)
ffffffffc020137e:	6161                	addi	sp,sp,80
ffffffffc0201380:	8082                	ret

ffffffffc0201382 <readline>:
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
<<<<<<< HEAD
ffffffffc0201c2c:	715d                	addi	sp,sp,-80
ffffffffc0201c2e:	e486                	sd	ra,72(sp)
ffffffffc0201c30:	e0a6                	sd	s1,64(sp)
ffffffffc0201c32:	fc4a                	sd	s2,56(sp)
ffffffffc0201c34:	f84e                	sd	s3,48(sp)
ffffffffc0201c36:	f452                	sd	s4,40(sp)
ffffffffc0201c38:	f056                	sd	s5,32(sp)
ffffffffc0201c3a:	ec5a                	sd	s6,24(sp)
ffffffffc0201c3c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201c3e:	c901                	beqz	a0,ffffffffc0201c4e <readline+0x22>
ffffffffc0201c40:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201c42:	00001517          	auipc	a0,0x1
ffffffffc0201c46:	f8e50513          	addi	a0,a0,-114 # ffffffffc0202bd0 <default_pmm_manager+0x298>
ffffffffc0201c4a:	c68fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201c4e:	4481                	li	s1,0
=======
ffffffffc0201382:	715d                	addi	sp,sp,-80
ffffffffc0201384:	e486                	sd	ra,72(sp)
ffffffffc0201386:	e0a6                	sd	s1,64(sp)
ffffffffc0201388:	fc4a                	sd	s2,56(sp)
ffffffffc020138a:	f84e                	sd	s3,48(sp)
ffffffffc020138c:	f452                	sd	s4,40(sp)
ffffffffc020138e:	f056                	sd	s5,32(sp)
ffffffffc0201390:	ec5a                	sd	s6,24(sp)
ffffffffc0201392:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201394:	c901                	beqz	a0,ffffffffc02013a4 <readline+0x22>
ffffffffc0201396:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201398:	00001517          	auipc	a0,0x1
ffffffffc020139c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0201f98 <buddy_system_pmm_manager+0x1c8>
ffffffffc02013a0:	d13fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc02013a4:	4481                	li	s1,0
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
<<<<<<< HEAD
ffffffffc0201c50:	497d                	li	s2,31
=======
ffffffffc02013a6:	497d                	li	s2,31
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
<<<<<<< HEAD
ffffffffc0201c52:	49a1                	li	s3,8
=======
ffffffffc02013a8:	49a1                	li	s3,8
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
<<<<<<< HEAD
ffffffffc0201c54:	4aa9                	li	s5,10
ffffffffc0201c56:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201c58:	00004b97          	auipc	s7,0x4
ffffffffc0201c5c:	550b8b93          	addi	s7,s7,1360 # ffffffffc02061a8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c60:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201c64:	cc6fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201c68:	00054a63          	bltz	a0,ffffffffc0201c7c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c6c:	00a95a63          	bge	s2,a0,ffffffffc0201c80 <readline+0x54>
ffffffffc0201c70:	029a5263          	bge	s4,s1,ffffffffc0201c94 <readline+0x68>
        c = getchar();
ffffffffc0201c74:	cb6fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201c78:	fe055ae3          	bgez	a0,ffffffffc0201c6c <readline+0x40>
            return NULL;
ffffffffc0201c7c:	4501                	li	a0,0
ffffffffc0201c7e:	a091                	j	ffffffffc0201cc2 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201c80:	03351463          	bne	a0,s3,ffffffffc0201ca8 <readline+0x7c>
ffffffffc0201c84:	e8a9                	bnez	s1,ffffffffc0201cd6 <readline+0xaa>
        c = getchar();
ffffffffc0201c86:	ca4fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201c8a:	fe0549e3          	bltz	a0,ffffffffc0201c7c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c8e:	fea959e3          	bge	s2,a0,ffffffffc0201c80 <readline+0x54>
ffffffffc0201c92:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201c94:	e42a                	sd	a0,8(sp)
ffffffffc0201c96:	c52fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201c9a:	6522                	ld	a0,8(sp)
ffffffffc0201c9c:	009b87b3          	add	a5,s7,s1
ffffffffc0201ca0:	2485                	addiw	s1,s1,1
ffffffffc0201ca2:	00a78023          	sb	a0,0(a5)
ffffffffc0201ca6:	bf7d                	j	ffffffffc0201c64 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201ca8:	01550463          	beq	a0,s5,ffffffffc0201cb0 <readline+0x84>
ffffffffc0201cac:	fb651ce3          	bne	a0,s6,ffffffffc0201c64 <readline+0x38>
            cputchar(c);
ffffffffc0201cb0:	c38fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201cb4:	00004517          	auipc	a0,0x4
ffffffffc0201cb8:	4f450513          	addi	a0,a0,1268 # ffffffffc02061a8 <buf>
ffffffffc0201cbc:	94aa                	add	s1,s1,a0
ffffffffc0201cbe:	00048023          	sb	zero,0(s1)
=======
ffffffffc02013aa:	4aa9                	li	s5,10
ffffffffc02013ac:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02013ae:	00005b97          	auipc	s7,0x5
ffffffffc02013b2:	d6ab8b93          	addi	s7,s7,-662 # ffffffffc0206118 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013b6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02013ba:	d71fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013be:	00054a63          	bltz	a0,ffffffffc02013d2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013c2:	00a95a63          	bge	s2,a0,ffffffffc02013d6 <readline+0x54>
ffffffffc02013c6:	029a5263          	bge	s4,s1,ffffffffc02013ea <readline+0x68>
        c = getchar();
ffffffffc02013ca:	d61fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013ce:	fe055ae3          	bgez	a0,ffffffffc02013c2 <readline+0x40>
            return NULL;
ffffffffc02013d2:	4501                	li	a0,0
ffffffffc02013d4:	a091                	j	ffffffffc0201418 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02013d6:	03351463          	bne	a0,s3,ffffffffc02013fe <readline+0x7c>
ffffffffc02013da:	e8a9                	bnez	s1,ffffffffc020142c <readline+0xaa>
        c = getchar();
ffffffffc02013dc:	d4ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02013e0:	fe0549e3          	bltz	a0,ffffffffc02013d2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02013e4:	fea959e3          	bge	s2,a0,ffffffffc02013d6 <readline+0x54>
ffffffffc02013e8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02013ea:	e42a                	sd	a0,8(sp)
ffffffffc02013ec:	cfdfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02013f0:	6522                	ld	a0,8(sp)
ffffffffc02013f2:	009b87b3          	add	a5,s7,s1
ffffffffc02013f6:	2485                	addiw	s1,s1,1
ffffffffc02013f8:	00a78023          	sb	a0,0(a5)
ffffffffc02013fc:	bf7d                	j	ffffffffc02013ba <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02013fe:	01550463          	beq	a0,s5,ffffffffc0201406 <readline+0x84>
ffffffffc0201402:	fb651ce3          	bne	a0,s6,ffffffffc02013ba <readline+0x38>
            cputchar(c);
ffffffffc0201406:	ce3fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020140a:	00005517          	auipc	a0,0x5
ffffffffc020140e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0206118 <buf>
ffffffffc0201412:	94aa                	add	s1,s1,a0
ffffffffc0201414:	00048023          	sb	zero,0(s1)
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
            return buf;
        }
    }
}
<<<<<<< HEAD
ffffffffc0201cc2:	60a6                	ld	ra,72(sp)
ffffffffc0201cc4:	6486                	ld	s1,64(sp)
ffffffffc0201cc6:	7962                	ld	s2,56(sp)
ffffffffc0201cc8:	79c2                	ld	s3,48(sp)
ffffffffc0201cca:	7a22                	ld	s4,40(sp)
ffffffffc0201ccc:	7a82                	ld	s5,32(sp)
ffffffffc0201cce:	6b62                	ld	s6,24(sp)
ffffffffc0201cd0:	6bc2                	ld	s7,16(sp)
ffffffffc0201cd2:	6161                	addi	sp,sp,80
ffffffffc0201cd4:	8082                	ret
            cputchar(c);
ffffffffc0201cd6:	4521                	li	a0,8
ffffffffc0201cd8:	c10fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201cdc:	34fd                	addiw	s1,s1,-1
ffffffffc0201cde:	b759                	j	ffffffffc0201c64 <readline+0x38>

ffffffffc0201ce0 <sbi_console_putchar>:
=======
ffffffffc0201418:	60a6                	ld	ra,72(sp)
ffffffffc020141a:	6486                	ld	s1,64(sp)
ffffffffc020141c:	7962                	ld	s2,56(sp)
ffffffffc020141e:	79c2                	ld	s3,48(sp)
ffffffffc0201420:	7a22                	ld	s4,40(sp)
ffffffffc0201422:	7a82                	ld	s5,32(sp)
ffffffffc0201424:	6b62                	ld	s6,24(sp)
ffffffffc0201426:	6bc2                	ld	s7,16(sp)
ffffffffc0201428:	6161                	addi	sp,sp,80
ffffffffc020142a:	8082                	ret
            cputchar(c);
ffffffffc020142c:	4521                	li	a0,8
ffffffffc020142e:	cbbfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201432:	34fd                	addiw	s1,s1,-1
ffffffffc0201434:	b759                	j	ffffffffc02013ba <readline+0x38>

ffffffffc0201436 <sbi_console_putchar>:
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
<<<<<<< HEAD
ffffffffc0201ce0:	4781                	li	a5,0
ffffffffc0201ce2:	00004717          	auipc	a4,0x4
ffffffffc0201ce6:	32673703          	ld	a4,806(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201cea:	88ba                	mv	a7,a4
ffffffffc0201cec:	852a                	mv	a0,a0
ffffffffc0201cee:	85be                	mv	a1,a5
ffffffffc0201cf0:	863e                	mv	a2,a5
ffffffffc0201cf2:	00000073          	ecall
ffffffffc0201cf6:	87aa                	mv	a5,a0
=======
ffffffffc0201436:	4781                	li	a5,0
ffffffffc0201438:	00005717          	auipc	a4,0x5
ffffffffc020143c:	bd073703          	ld	a4,-1072(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201440:	88ba                	mv	a7,a4
ffffffffc0201442:	852a                	mv	a0,a0
ffffffffc0201444:	85be                	mv	a1,a5
ffffffffc0201446:	863e                	mv	a2,a5
ffffffffc0201448:	00000073          	ecall
ffffffffc020144c:	87aa                	mv	a5,a0
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
<<<<<<< HEAD
ffffffffc0201cf8:	8082                	ret

ffffffffc0201cfa <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201cfa:	4781                	li	a5,0
ffffffffc0201cfc:	00005717          	auipc	a4,0x5
ffffffffc0201d00:	8ec73703          	ld	a4,-1812(a4) # ffffffffc02065e8 <SBI_SET_TIMER>
ffffffffc0201d04:	88ba                	mv	a7,a4
ffffffffc0201d06:	852a                	mv	a0,a0
ffffffffc0201d08:	85be                	mv	a1,a5
ffffffffc0201d0a:	863e                	mv	a2,a5
ffffffffc0201d0c:	00000073          	ecall
ffffffffc0201d10:	87aa                	mv	a5,a0
=======
ffffffffc020144e:	8082                	ret

ffffffffc0201450 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201450:	4781                	li	a5,0
ffffffffc0201452:	00005717          	auipc	a4,0x5
ffffffffc0201456:	10e73703          	ld	a4,270(a4) # ffffffffc0206560 <SBI_SET_TIMER>
ffffffffc020145a:	88ba                	mv	a7,a4
ffffffffc020145c:	852a                	mv	a0,a0
ffffffffc020145e:	85be                	mv	a1,a5
ffffffffc0201460:	863e                	mv	a2,a5
ffffffffc0201462:	00000073          	ecall
ffffffffc0201466:	87aa                	mv	a5,a0
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
<<<<<<< HEAD
ffffffffc0201d12:	8082                	ret

ffffffffc0201d14 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201d14:	4501                	li	a0,0
ffffffffc0201d16:	00004797          	auipc	a5,0x4
ffffffffc0201d1a:	2ea7b783          	ld	a5,746(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201d1e:	88be                	mv	a7,a5
ffffffffc0201d20:	852a                	mv	a0,a0
ffffffffc0201d22:	85aa                	mv	a1,a0
ffffffffc0201d24:	862a                	mv	a2,a0
ffffffffc0201d26:	00000073          	ecall
ffffffffc0201d2a:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201d2c:	2501                	sext.w	a0,a0
ffffffffc0201d2e:	8082                	ret

ffffffffc0201d30 <strnlen>:
=======
ffffffffc0201468:	8082                	ret

ffffffffc020146a <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020146a:	4501                	li	a0,0
ffffffffc020146c:	00005797          	auipc	a5,0x5
ffffffffc0201470:	b947b783          	ld	a5,-1132(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201474:	88be                	mv	a7,a5
ffffffffc0201476:	852a                	mv	a0,a0
ffffffffc0201478:	85aa                	mv	a1,a0
ffffffffc020147a:	862a                	mv	a2,a0
ffffffffc020147c:	00000073          	ecall
ffffffffc0201480:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201482:	2501                	sext.w	a0,a0
ffffffffc0201484:	8082                	ret

ffffffffc0201486 <strnlen>:
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
<<<<<<< HEAD
ffffffffc0201d30:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d32:	e589                	bnez	a1,ffffffffc0201d3c <strnlen+0xc>
ffffffffc0201d34:	a811                	j	ffffffffc0201d48 <strnlen+0x18>
        cnt ++;
ffffffffc0201d36:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d38:	00f58863          	beq	a1,a5,ffffffffc0201d48 <strnlen+0x18>
ffffffffc0201d3c:	00f50733          	add	a4,a0,a5
ffffffffc0201d40:	00074703          	lbu	a4,0(a4)
ffffffffc0201d44:	fb6d                	bnez	a4,ffffffffc0201d36 <strnlen+0x6>
ffffffffc0201d46:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201d48:	852e                	mv	a0,a1
ffffffffc0201d4a:	8082                	ret

ffffffffc0201d4c <strcmp>:
=======
ffffffffc0201486:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201488:	e589                	bnez	a1,ffffffffc0201492 <strnlen+0xc>
ffffffffc020148a:	a811                	j	ffffffffc020149e <strnlen+0x18>
        cnt ++;
ffffffffc020148c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020148e:	00f58863          	beq	a1,a5,ffffffffc020149e <strnlen+0x18>
ffffffffc0201492:	00f50733          	add	a4,a0,a5
ffffffffc0201496:	00074703          	lbu	a4,0(a4)
ffffffffc020149a:	fb6d                	bnez	a4,ffffffffc020148c <strnlen+0x6>
ffffffffc020149c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020149e:	852e                	mv	a0,a1
ffffffffc02014a0:	8082                	ret

ffffffffc02014a2 <strcmp>:
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
<<<<<<< HEAD
ffffffffc0201d4c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201d50:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d54:	cb89                	beqz	a5,ffffffffc0201d66 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201d56:	0505                	addi	a0,a0,1
ffffffffc0201d58:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d5a:	fee789e3          	beq	a5,a4,ffffffffc0201d4c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201d5e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201d62:	9d19                	subw	a0,a0,a4
ffffffffc0201d64:	8082                	ret
ffffffffc0201d66:	4501                	li	a0,0
ffffffffc0201d68:	bfed                	j	ffffffffc0201d62 <strcmp+0x16>

ffffffffc0201d6a <strchr>:
=======
ffffffffc02014a2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02014a6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02014aa:	cb89                	beqz	a5,ffffffffc02014bc <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02014ac:	0505                	addi	a0,a0,1
ffffffffc02014ae:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02014b0:	fee789e3          	beq	a5,a4,ffffffffc02014a2 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02014b4:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02014b8:	9d19                	subw	a0,a0,a4
ffffffffc02014ba:	8082                	ret
ffffffffc02014bc:	4501                	li	a0,0
ffffffffc02014be:	bfed                	j	ffffffffc02014b8 <strcmp+0x16>

ffffffffc02014c0 <strchr>:
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
<<<<<<< HEAD
ffffffffc0201d6a:	00054783          	lbu	a5,0(a0)
ffffffffc0201d6e:	c799                	beqz	a5,ffffffffc0201d7c <strchr+0x12>
        if (*s == c) {
ffffffffc0201d70:	00f58763          	beq	a1,a5,ffffffffc0201d7e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201d74:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201d78:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201d7a:	fbfd                	bnez	a5,ffffffffc0201d70 <strchr+0x6>
    }
    return NULL;
ffffffffc0201d7c:	4501                	li	a0,0
}
ffffffffc0201d7e:	8082                	ret

ffffffffc0201d80 <memset>:
=======
ffffffffc02014c0:	00054783          	lbu	a5,0(a0)
ffffffffc02014c4:	c799                	beqz	a5,ffffffffc02014d2 <strchr+0x12>
        if (*s == c) {
ffffffffc02014c6:	00f58763          	beq	a1,a5,ffffffffc02014d4 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02014ca:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02014ce:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02014d0:	fbfd                	bnez	a5,ffffffffc02014c6 <strchr+0x6>
    }
    return NULL;
ffffffffc02014d2:	4501                	li	a0,0
}
ffffffffc02014d4:	8082                	ret

ffffffffc02014d6 <memset>:
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
<<<<<<< HEAD
ffffffffc0201d80:	ca01                	beqz	a2,ffffffffc0201d90 <memset+0x10>
ffffffffc0201d82:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201d84:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201d86:	0785                	addi	a5,a5,1
ffffffffc0201d88:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201d8c:	fec79de3          	bne	a5,a2,ffffffffc0201d86 <memset+0x6>
=======
ffffffffc02014d6:	ca01                	beqz	a2,ffffffffc02014e6 <memset+0x10>
ffffffffc02014d8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02014da:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02014dc:	0785                	addi	a5,a5,1
ffffffffc02014de:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02014e2:	fec79de3          	bne	a5,a2,ffffffffc02014dc <memset+0x6>
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
<<<<<<< HEAD
ffffffffc0201d90:	8082                	ret
=======
ffffffffc02014e6:	8082                	ret
>>>>>>> b35cae514a66c32ebd187274134dc2406b66d2fb
