
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	2ce50513          	addi	a0,a0,718 # ffffffffc02a7300 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	82260613          	addi	a2,a2,-2014 # ffffffffc02b285c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	3af050ef          	jal	ra,ffffffffc0205bf8 <memset>
    cons_init();                // init the console
ffffffffc020004e:	52a000ef          	jal	ra,ffffffffc0200578 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	bd658593          	addi	a1,a1,-1066 # ffffffffc0205c28 <etext+0x6>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0205c48 <etext+0x26>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1a2000ef          	jal	ra,ffffffffc0200208 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	4ee020ef          	jal	ra,ffffffffc0202558 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5ba000ef          	jal	ra,ffffffffc0200628 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5b8000ef          	jal	ra,ffffffffc020062a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	0da040ef          	jal	ra,ffffffffc0204150 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	35c050ef          	jal	ra,ffffffffc02053d6 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	56c000ef          	jal	ra,ffffffffc02005ea <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	14c030ef          	jal	ra,ffffffffc02031ce <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4a0000ef          	jal	ra,ffffffffc0200526 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	592000ef          	jal	ra,ffffffffc020061c <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	4e4050ef          	jal	ra,ffffffffc0205572 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	ba850513          	addi	a0,a0,-1112 # ffffffffc0205c50 <etext+0x2e>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	000a7b97          	auipc	s7,0xa7
ffffffffc02000c2:	242b8b93          	addi	s7,s7,578 # ffffffffc02a7300 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	12e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	11e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	10c000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	000a7517          	auipc	a0,0xa7
ffffffffc020011e:	1e650513          	addi	a0,a0,486 # ffffffffc02a7300 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	42c000ef          	jal	ra,ffffffffc020057a <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	686050ef          	jal	ra,ffffffffc02057fa <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	650050ef          	jal	ra,ffffffffc02057fa <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a6d1                	j	ffffffffc020057a <cons_putc>

ffffffffc02001b8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b8:	1101                	addi	sp,sp,-32
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	ec06                	sd	ra,24(sp)
ffffffffc02001be:	e426                	sd	s1,8(sp)
ffffffffc02001c0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001c2:	00054503          	lbu	a0,0(a0)
ffffffffc02001c6:	c51d                	beqz	a0,ffffffffc02001f4 <cputs+0x3c>
ffffffffc02001c8:	0405                	addi	s0,s0,1
ffffffffc02001ca:	4485                	li	s1,1
ffffffffc02001cc:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001ce:	3ac000ef          	jal	ra,ffffffffc020057a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d2:	00044503          	lbu	a0,0(s0)
ffffffffc02001d6:	008487bb          	addw	a5,s1,s0
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	f96d                	bnez	a0,ffffffffc02001ce <cputs+0x16>
    (*cnt) ++;
ffffffffc02001de:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001e2:	4529                	li	a0,10
ffffffffc02001e4:	396000ef          	jal	ra,ffffffffc020057a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	64a2                	ld	s1,8(sp)
ffffffffc02001f0:	6105                	addi	sp,sp,32
ffffffffc02001f2:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001f4:	4405                	li	s0,1
ffffffffc02001f6:	b7f5                	j	ffffffffc02001e2 <cputs+0x2a>

ffffffffc02001f8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001f8:	1141                	addi	sp,sp,-16
ffffffffc02001fa:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001fc:	3b2000ef          	jal	ra,ffffffffc02005ae <cons_getc>
ffffffffc0200200:	dd75                	beqz	a0,ffffffffc02001fc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200202:	60a2                	ld	ra,8(sp)
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020020a:	00006517          	auipc	a0,0x6
ffffffffc020020e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0205c58 <etext+0x36>
void print_kerninfo(void) {
ffffffffc0200212:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200214:	f6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200218:	00000597          	auipc	a1,0x0
ffffffffc020021c:	e1a58593          	addi	a1,a1,-486 # ffffffffc0200032 <kern_init>
ffffffffc0200220:	00006517          	auipc	a0,0x6
ffffffffc0200224:	a5850513          	addi	a0,a0,-1448 # ffffffffc0205c78 <etext+0x56>
ffffffffc0200228:	f59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020022c:	00006597          	auipc	a1,0x6
ffffffffc0200230:	9f658593          	addi	a1,a1,-1546 # ffffffffc0205c22 <etext>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	a6450513          	addi	a0,a0,-1436 # ffffffffc0205c98 <etext+0x76>
ffffffffc020023c:	f45ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200240:	000a7597          	auipc	a1,0xa7
ffffffffc0200244:	0c058593          	addi	a1,a1,192 # ffffffffc02a7300 <buf>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	a7050513          	addi	a0,a0,-1424 # ffffffffc0205cb8 <etext+0x96>
ffffffffc0200250:	f31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200254:	000b2597          	auipc	a1,0xb2
ffffffffc0200258:	60858593          	addi	a1,a1,1544 # ffffffffc02b285c <end>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0205cd8 <etext+0xb6>
ffffffffc0200264:	f1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200268:	000b3597          	auipc	a1,0xb3
ffffffffc020026c:	9f358593          	addi	a1,a1,-1549 # ffffffffc02b2c5b <end+0x3ff>
ffffffffc0200270:	00000797          	auipc	a5,0x0
ffffffffc0200274:	dc278793          	addi	a5,a5,-574 # ffffffffc0200032 <kern_init>
ffffffffc0200278:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020027c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200282:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200286:	95be                	add	a1,a1,a5
ffffffffc0200288:	85a9                	srai	a1,a1,0xa
ffffffffc020028a:	00006517          	auipc	a0,0x6
ffffffffc020028e:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0205cf8 <etext+0xd6>
}
ffffffffc0200292:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	b5f5                	j	ffffffffc0200180 <cprintf>

ffffffffc0200296 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200296:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200298:	00006617          	auipc	a2,0x6
ffffffffc020029c:	a9060613          	addi	a2,a2,-1392 # ffffffffc0205d28 <etext+0x106>
ffffffffc02002a0:	04d00593          	li	a1,77
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0205d40 <etext+0x11e>
void print_stackframe(void) {
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ae:	1cc000ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02002b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002b4:	00006617          	auipc	a2,0x6
ffffffffc02002b8:	aa460613          	addi	a2,a2,-1372 # ffffffffc0205d58 <etext+0x136>
ffffffffc02002bc:	00006597          	auipc	a1,0x6
ffffffffc02002c0:	abc58593          	addi	a1,a1,-1348 # ffffffffc0205d78 <etext+0x156>
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	abc50513          	addi	a0,a0,-1348 # ffffffffc0205d80 <etext+0x15e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ce:	eb3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002d2:	00006617          	auipc	a2,0x6
ffffffffc02002d6:	abe60613          	addi	a2,a2,-1346 # ffffffffc0205d90 <etext+0x16e>
ffffffffc02002da:	00006597          	auipc	a1,0x6
ffffffffc02002de:	ade58593          	addi	a1,a1,-1314 # ffffffffc0205db8 <etext+0x196>
ffffffffc02002e2:	00006517          	auipc	a0,0x6
ffffffffc02002e6:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0205d80 <etext+0x15e>
ffffffffc02002ea:	e97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ee:	00006617          	auipc	a2,0x6
ffffffffc02002f2:	ada60613          	addi	a2,a2,-1318 # ffffffffc0205dc8 <etext+0x1a6>
ffffffffc02002f6:	00006597          	auipc	a1,0x6
ffffffffc02002fa:	af258593          	addi	a1,a1,-1294 # ffffffffc0205de8 <etext+0x1c6>
ffffffffc02002fe:	00006517          	auipc	a0,0x6
ffffffffc0200302:	a8250513          	addi	a0,a0,-1406 # ffffffffc0205d80 <etext+0x15e>
ffffffffc0200306:	e7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc020030a:	60a2                	ld	ra,8(sp)
ffffffffc020030c:	4501                	li	a0,0
ffffffffc020030e:	0141                	addi	sp,sp,16
ffffffffc0200310:	8082                	ret

ffffffffc0200312 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200312:	1141                	addi	sp,sp,-16
ffffffffc0200314:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200316:	ef3ff0ef          	jal	ra,ffffffffc0200208 <print_kerninfo>
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200326:	f71ff0ef          	jal	ra,ffffffffc0200296 <print_stackframe>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200332:	7115                	addi	sp,sp,-224
ffffffffc0200334:	ed5e                	sd	s7,152(sp)
ffffffffc0200336:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200338:	00006517          	auipc	a0,0x6
ffffffffc020033c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0205df8 <etext+0x1d6>
kmonitor(struct trapframe *tf) {
ffffffffc0200340:	ed86                	sd	ra,216(sp)
ffffffffc0200342:	e9a2                	sd	s0,208(sp)
ffffffffc0200344:	e5a6                	sd	s1,200(sp)
ffffffffc0200346:	e1ca                	sd	s2,192(sp)
ffffffffc0200348:	fd4e                	sd	s3,184(sp)
ffffffffc020034a:	f952                	sd	s4,176(sp)
ffffffffc020034c:	f556                	sd	s5,168(sp)
ffffffffc020034e:	f15a                	sd	s6,160(sp)
ffffffffc0200350:	e962                	sd	s8,144(sp)
ffffffffc0200352:	e566                	sd	s9,136(sp)
ffffffffc0200354:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200356:	e2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020035a:	00006517          	auipc	a0,0x6
ffffffffc020035e:	ac650513          	addi	a0,a0,-1338 # ffffffffc0205e20 <etext+0x1fe>
ffffffffc0200362:	e1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200366:	000b8563          	beqz	s7,ffffffffc0200370 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020036a:	855e                	mv	a0,s7
ffffffffc020036c:	4a4000ef          	jal	ra,ffffffffc0200810 <print_trapframe>
ffffffffc0200370:	00006c17          	auipc	s8,0x6
ffffffffc0200374:	b20c0c13          	addi	s8,s8,-1248 # ffffffffc0205e90 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	00006917          	auipc	s2,0x6
ffffffffc020037c:	ad090913          	addi	s2,s2,-1328 # ffffffffc0205e48 <etext+0x226>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200380:	00006497          	auipc	s1,0x6
ffffffffc0200384:	ad048493          	addi	s1,s1,-1328 # ffffffffc0205e50 <etext+0x22e>
        if (argc == MAXARGS - 1) {
ffffffffc0200388:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038a:	00006b17          	auipc	s6,0x6
ffffffffc020038e:	aceb0b13          	addi	s6,s6,-1330 # ffffffffc0205e58 <etext+0x236>
        argv[argc ++] = buf;
ffffffffc0200392:	00006a17          	auipc	s4,0x6
ffffffffc0200396:	9e6a0a13          	addi	s4,s4,-1562 # ffffffffc0205d78 <etext+0x156>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020039c:	854a                	mv	a0,s2
ffffffffc020039e:	cf5ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc02003a2:	842a                	mv	s0,a0
ffffffffc02003a4:	dd65                	beqz	a0,ffffffffc020039c <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003aa:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ac:	e1bd                	bnez	a1,ffffffffc0200412 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003ae:	fe0c87e3          	beqz	s9,ffffffffc020039c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b2:	6582                	ld	a1,0(sp)
ffffffffc02003b4:	00006d17          	auipc	s10,0x6
ffffffffc02003b8:	adcd0d13          	addi	s10,s10,-1316 # ffffffffc0205e90 <commands>
        argv[argc ++] = buf;
ffffffffc02003bc:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003be:	4401                	li	s0,0
ffffffffc02003c0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c2:	003050ef          	jal	ra,ffffffffc0205bc4 <strcmp>
ffffffffc02003c6:	c919                	beqz	a0,ffffffffc02003dc <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c8:	2405                	addiw	s0,s0,1
ffffffffc02003ca:	0b540063          	beq	s0,s5,ffffffffc020046a <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ce:	000d3503          	ld	a0,0(s10)
ffffffffc02003d2:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d6:	7ee050ef          	jal	ra,ffffffffc0205bc4 <strcmp>
ffffffffc02003da:	f57d                	bnez	a0,ffffffffc02003c8 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003dc:	00141793          	slli	a5,s0,0x1
ffffffffc02003e0:	97a2                	add	a5,a5,s0
ffffffffc02003e2:	078e                	slli	a5,a5,0x3
ffffffffc02003e4:	97e2                	add	a5,a5,s8
ffffffffc02003e6:	6b9c                	ld	a5,16(a5)
ffffffffc02003e8:	865e                	mv	a2,s7
ffffffffc02003ea:	002c                	addi	a1,sp,8
ffffffffc02003ec:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003f0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f2:	fa0555e3          	bgez	a0,ffffffffc020039c <kmonitor+0x6a>
}
ffffffffc02003f6:	60ee                	ld	ra,216(sp)
ffffffffc02003f8:	644e                	ld	s0,208(sp)
ffffffffc02003fa:	64ae                	ld	s1,200(sp)
ffffffffc02003fc:	690e                	ld	s2,192(sp)
ffffffffc02003fe:	79ea                	ld	s3,184(sp)
ffffffffc0200400:	7a4a                	ld	s4,176(sp)
ffffffffc0200402:	7aaa                	ld	s5,168(sp)
ffffffffc0200404:	7b0a                	ld	s6,160(sp)
ffffffffc0200406:	6bea                	ld	s7,152(sp)
ffffffffc0200408:	6c4a                	ld	s8,144(sp)
ffffffffc020040a:	6caa                	ld	s9,136(sp)
ffffffffc020040c:	6d0a                	ld	s10,128(sp)
ffffffffc020040e:	612d                	addi	sp,sp,224
ffffffffc0200410:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200412:	8526                	mv	a0,s1
ffffffffc0200414:	7ce050ef          	jal	ra,ffffffffc0205be2 <strchr>
ffffffffc0200418:	c901                	beqz	a0,ffffffffc0200428 <kmonitor+0xf6>
ffffffffc020041a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020041e:	00040023          	sb	zero,0(s0)
ffffffffc0200422:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	d5c9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200426:	b7f5                	j	ffffffffc0200412 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200428:	00044783          	lbu	a5,0(s0)
ffffffffc020042c:	d3c9                	beqz	a5,ffffffffc02003ae <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020042e:	033c8963          	beq	s9,s3,ffffffffc0200460 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200432:	003c9793          	slli	a5,s9,0x3
ffffffffc0200436:	0118                	addi	a4,sp,128
ffffffffc0200438:	97ba                	add	a5,a5,a4
ffffffffc020043a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020043e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200442:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200444:	e591                	bnez	a1,ffffffffc0200450 <kmonitor+0x11e>
ffffffffc0200446:	b7b5                	j	ffffffffc02003b2 <kmonitor+0x80>
ffffffffc0200448:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020044c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	d1a5                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	790050ef          	jal	ra,ffffffffc0205be2 <strchr>
ffffffffc0200456:	d96d                	beqz	a0,ffffffffc0200448 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	00044583          	lbu	a1,0(s0)
ffffffffc020045c:	d9a9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc020045e:	bf55                	j	ffffffffc0200412 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200460:	45c1                	li	a1,16
ffffffffc0200462:	855a                	mv	a0,s6
ffffffffc0200464:	d1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200468:	b7e9                	j	ffffffffc0200432 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020046a:	6582                	ld	a1,0(sp)
ffffffffc020046c:	00006517          	auipc	a0,0x6
ffffffffc0200470:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0205e78 <etext+0x256>
ffffffffc0200474:	d0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200478:	b715                	j	ffffffffc020039c <kmonitor+0x6a>

ffffffffc020047a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020047a:	000b2317          	auipc	t1,0xb2
ffffffffc020047e:	34e30313          	addi	t1,t1,846 # ffffffffc02b27c8 <is_panic>
ffffffffc0200482:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200486:	715d                	addi	sp,sp,-80
ffffffffc0200488:	ec06                	sd	ra,24(sp)
ffffffffc020048a:	e822                	sd	s0,16(sp)
ffffffffc020048c:	f436                	sd	a3,40(sp)
ffffffffc020048e:	f83a                	sd	a4,48(sp)
ffffffffc0200490:	fc3e                	sd	a5,56(sp)
ffffffffc0200492:	e0c2                	sd	a6,64(sp)
ffffffffc0200494:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200496:	020e1a63          	bnez	t3,ffffffffc02004ca <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020049a:	4785                	li	a5,1
ffffffffc020049c:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004a0:	8432                	mv	s0,a2
ffffffffc02004a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a4:	862e                	mv	a2,a1
ffffffffc02004a6:	85aa                	mv	a1,a0
ffffffffc02004a8:	00006517          	auipc	a0,0x6
ffffffffc02004ac:	a3050513          	addi	a0,a0,-1488 # ffffffffc0205ed8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004b0:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b2:	ccfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b6:	65a2                	ld	a1,8(sp)
ffffffffc02004b8:	8522                	mv	a0,s0
ffffffffc02004ba:	ca7ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004be:	00007517          	auipc	a0,0x7
ffffffffc02004c2:	9d250513          	addi	a0,a0,-1582 # ffffffffc0206e90 <default_pmm_manager+0x518>
ffffffffc02004c6:	cbbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	4581                	li	a1,0
ffffffffc02004ce:	4601                	li	a2,0
ffffffffc02004d0:	48a1                	li	a7,8
ffffffffc02004d2:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d6:	14c000ef          	jal	ra,ffffffffc0200622 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	e57ff0ef          	jal	ra,ffffffffc0200332 <kmonitor>
    while (1) {
ffffffffc02004e0:	bfed                	j	ffffffffc02004da <__panic+0x60>

ffffffffc02004e2 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e2:	715d                	addi	sp,sp,-80
ffffffffc02004e4:	832e                	mv	t1,a1
ffffffffc02004e6:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ea:	8432                	mv	s0,a2
ffffffffc02004ec:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ee:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004f0:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f2:	00006517          	auipc	a0,0x6
ffffffffc02004f6:	a0650513          	addi	a0,a0,-1530 # ffffffffc0205ef8 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fa:	ec06                	sd	ra,24(sp)
ffffffffc02004fc:	f436                	sd	a3,40(sp)
ffffffffc02004fe:	f83a                	sd	a4,48(sp)
ffffffffc0200500:	e0c2                	sd	a6,64(sp)
ffffffffc0200502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200504:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	c7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020050a:	65a2                	ld	a1,8(sp)
ffffffffc020050c:	8522                	mv	a0,s0
ffffffffc020050e:	c53ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc0200512:	00007517          	auipc	a0,0x7
ffffffffc0200516:	97e50513          	addi	a0,a0,-1666 # ffffffffc0206e90 <default_pmm_manager+0x518>
ffffffffc020051a:	c67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc020051e:	60e2                	ld	ra,24(sp)
ffffffffc0200520:	6442                	ld	s0,16(sp)
ffffffffc0200522:	6161                	addi	sp,sp,80
ffffffffc0200524:	8082                	ret

ffffffffc0200526 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200526:	67e1                	lui	a5,0x18
ffffffffc0200528:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd578>
ffffffffc020052c:	000b2717          	auipc	a4,0xb2
ffffffffc0200530:	2af73623          	sd	a5,684(a4) # ffffffffc02b27d8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200534:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200538:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020053a:	953e                	add	a0,a0,a5
ffffffffc020053c:	4601                	li	a2,0
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200544:	02000793          	li	a5,32
ffffffffc0200548:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020054c:	00006517          	auipc	a0,0x6
ffffffffc0200550:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0205f18 <commands+0x88>
    ticks = 0;
ffffffffc0200554:	000b2797          	auipc	a5,0xb2
ffffffffc0200558:	2607be23          	sd	zero,636(a5) # ffffffffc02b27d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020055c:	b115                	j	ffffffffc0200180 <cprintf>

ffffffffc020055e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020055e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200562:	000b2797          	auipc	a5,0xb2
ffffffffc0200566:	2767b783          	ld	a5,630(a5) # ffffffffc02b27d8 <timebase>
ffffffffc020056a:	953e                	add	a0,a0,a5
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
ffffffffc0200576:	8082                	ret

ffffffffc0200578 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200578:	8082                	ret

ffffffffc020057a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020057a:	100027f3          	csrr	a5,sstatus
ffffffffc020057e:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200580:	0ff57513          	andi	a0,a0,255
ffffffffc0200584:	e799                	bnez	a5,ffffffffc0200592 <cons_putc+0x18>
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4885                	li	a7,1
ffffffffc020058c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200590:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200592:	1101                	addi	sp,sp,-32
ffffffffc0200594:	ec06                	sd	ra,24(sp)
ffffffffc0200596:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200598:	08a000ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc020059c:	6522                	ld	a0,8(sp)
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4885                	li	a7,1
ffffffffc02005a4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a8:	60e2                	ld	ra,24(sp)
ffffffffc02005aa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005ac:	a885                	j	ffffffffc020061c <intr_enable>

ffffffffc02005ae <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ae:	100027f3          	csrr	a5,sstatus
ffffffffc02005b2:	8b89                	andi	a5,a5,2
ffffffffc02005b4:	eb89                	bnez	a5,ffffffffc02005c6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005c4:	8082                	ret
int cons_getc(void) {
ffffffffc02005c6:	1101                	addi	sp,sp,-32
ffffffffc02005c8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005ca:	058000ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc02005ce:	4501                	li	a0,0
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4889                	li	a7,2
ffffffffc02005d6:	00000073          	ecall
ffffffffc02005da:	2501                	sext.w	a0,a0
ffffffffc02005dc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005de:	03e000ef          	jal	ra,ffffffffc020061c <intr_enable>
}
ffffffffc02005e2:	60e2                	ld	ra,24(sp)
ffffffffc02005e4:	6522                	ld	a0,8(sp)
ffffffffc02005e6:	6105                	addi	sp,sp,32
ffffffffc02005e8:	8082                	ret

ffffffffc02005ea <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005ec:	00253513          	sltiu	a0,a0,2
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005f2:	03800513          	li	a0,56
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <ide_write_secs>:
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02005f8:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005fc:	000a7517          	auipc	a0,0xa7
ffffffffc0200600:	10450513          	addi	a0,a0,260 # ffffffffc02a7700 <ide>
                   size_t nsecs) {
ffffffffc0200604:	1141                	addi	sp,sp,-16
ffffffffc0200606:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200608:	953e                	add	a0,a0,a5
ffffffffc020060a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020060e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200610:	5fa050ef          	jal	ra,ffffffffc0205c0a <memcpy>
    return 0;
}
ffffffffc0200614:	60a2                	ld	ra,8(sp)
ffffffffc0200616:	4501                	li	a0,0
ffffffffc0200618:	0141                	addi	sp,sp,16
ffffffffc020061a:	8082                	ret

ffffffffc020061c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020061c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200620:	8082                	ret

ffffffffc0200622 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200622:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200626:	8082                	ret

ffffffffc0200628 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200628:	8082                	ret

ffffffffc020062a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020062a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020062e:	00000797          	auipc	a5,0x0
ffffffffc0200632:	65a78793          	addi	a5,a5,1626 # ffffffffc0200c88 <__alltraps>
ffffffffc0200636:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020063a:	000407b7          	lui	a5,0x40
ffffffffc020063e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200642:	8082                	ret

ffffffffc0200644 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200644:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200646:	1141                	addi	sp,sp,-16
ffffffffc0200648:	e022                	sd	s0,0(sp)
ffffffffc020064a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020064c:	00006517          	auipc	a0,0x6
ffffffffc0200650:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0205f38 <commands+0xa8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200654:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200656:	b2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020065a:	640c                	ld	a1,8(s0)
ffffffffc020065c:	00006517          	auipc	a0,0x6
ffffffffc0200660:	8f450513          	addi	a0,a0,-1804 # ffffffffc0205f50 <commands+0xc0>
ffffffffc0200664:	b1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200668:	680c                	ld	a1,16(s0)
ffffffffc020066a:	00006517          	auipc	a0,0x6
ffffffffc020066e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0205f68 <commands+0xd8>
ffffffffc0200672:	b0fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200676:	6c0c                	ld	a1,24(s0)
ffffffffc0200678:	00006517          	auipc	a0,0x6
ffffffffc020067c:	90850513          	addi	a0,a0,-1784 # ffffffffc0205f80 <commands+0xf0>
ffffffffc0200680:	b01ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200684:	700c                	ld	a1,32(s0)
ffffffffc0200686:	00006517          	auipc	a0,0x6
ffffffffc020068a:	91250513          	addi	a0,a0,-1774 # ffffffffc0205f98 <commands+0x108>
ffffffffc020068e:	af3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200692:	740c                	ld	a1,40(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	91c50513          	addi	a0,a0,-1764 # ffffffffc0205fb0 <commands+0x120>
ffffffffc020069c:	ae5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006a0:	780c                	ld	a1,48(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	92650513          	addi	a0,a0,-1754 # ffffffffc0205fc8 <commands+0x138>
ffffffffc02006aa:	ad7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ae:	7c0c                	ld	a1,56(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	93050513          	addi	a0,a0,-1744 # ffffffffc0205fe0 <commands+0x150>
ffffffffc02006b8:	ac9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006bc:	602c                	ld	a1,64(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	93a50513          	addi	a0,a0,-1734 # ffffffffc0205ff8 <commands+0x168>
ffffffffc02006c6:	abbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ca:	642c                	ld	a1,72(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	94450513          	addi	a0,a0,-1724 # ffffffffc0206010 <commands+0x180>
ffffffffc02006d4:	aadff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006d8:	682c                	ld	a1,80(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	94e50513          	addi	a0,a0,-1714 # ffffffffc0206028 <commands+0x198>
ffffffffc02006e2:	a9fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006e6:	6c2c                	ld	a1,88(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	95850513          	addi	a0,a0,-1704 # ffffffffc0206040 <commands+0x1b0>
ffffffffc02006f0:	a91ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f4:	702c                	ld	a1,96(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	96250513          	addi	a0,a0,-1694 # ffffffffc0206058 <commands+0x1c8>
ffffffffc02006fe:	a83ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200702:	742c                	ld	a1,104(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	96c50513          	addi	a0,a0,-1684 # ffffffffc0206070 <commands+0x1e0>
ffffffffc020070c:	a75ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200710:	782c                	ld	a1,112(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	97650513          	addi	a0,a0,-1674 # ffffffffc0206088 <commands+0x1f8>
ffffffffc020071a:	a67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020071e:	7c2c                	ld	a1,120(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	98050513          	addi	a0,a0,-1664 # ffffffffc02060a0 <commands+0x210>
ffffffffc0200728:	a59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020072c:	604c                	ld	a1,128(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	98a50513          	addi	a0,a0,-1654 # ffffffffc02060b8 <commands+0x228>
ffffffffc0200736:	a4bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020073a:	644c                	ld	a1,136(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	99450513          	addi	a0,a0,-1644 # ffffffffc02060d0 <commands+0x240>
ffffffffc0200744:	a3dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200748:	684c                	ld	a1,144(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	99e50513          	addi	a0,a0,-1634 # ffffffffc02060e8 <commands+0x258>
ffffffffc0200752:	a2fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200756:	6c4c                	ld	a1,152(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	9a850513          	addi	a0,a0,-1624 # ffffffffc0206100 <commands+0x270>
ffffffffc0200760:	a21ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200764:	704c                	ld	a1,160(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	9b250513          	addi	a0,a0,-1614 # ffffffffc0206118 <commands+0x288>
ffffffffc020076e:	a13ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200772:	744c                	ld	a1,168(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0206130 <commands+0x2a0>
ffffffffc020077c:	a05ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200780:	784c                	ld	a1,176(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	9c650513          	addi	a0,a0,-1594 # ffffffffc0206148 <commands+0x2b8>
ffffffffc020078a:	9f7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020078e:	7c4c                	ld	a1,184(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	9d050513          	addi	a0,a0,-1584 # ffffffffc0206160 <commands+0x2d0>
ffffffffc0200798:	9e9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc020079c:	606c                	ld	a1,192(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	9da50513          	addi	a0,a0,-1574 # ffffffffc0206178 <commands+0x2e8>
ffffffffc02007a6:	9dbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007aa:	646c                	ld	a1,200(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	9e450513          	addi	a0,a0,-1564 # ffffffffc0206190 <commands+0x300>
ffffffffc02007b4:	9cdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007b8:	686c                	ld	a1,208(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	9ee50513          	addi	a0,a0,-1554 # ffffffffc02061a8 <commands+0x318>
ffffffffc02007c2:	9bfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007c6:	6c6c                	ld	a1,216(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	9f850513          	addi	a0,a0,-1544 # ffffffffc02061c0 <commands+0x330>
ffffffffc02007d0:	9b1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d4:	706c                	ld	a1,224(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	a0250513          	addi	a0,a0,-1534 # ffffffffc02061d8 <commands+0x348>
ffffffffc02007de:	9a3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007e2:	746c                	ld	a1,232(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02061f0 <commands+0x360>
ffffffffc02007ec:	995ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007f0:	786c                	ld	a1,240(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	a1650513          	addi	a0,a0,-1514 # ffffffffc0206208 <commands+0x378>
ffffffffc02007fa:	987ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007fe:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200800:	6402                	ld	s0,0(sp)
ffffffffc0200802:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200804:	00006517          	auipc	a0,0x6
ffffffffc0200808:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206220 <commands+0x390>
}
ffffffffc020080c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	ba8d                	j	ffffffffc0200180 <cprintf>

ffffffffc0200810 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200810:	1141                	addi	sp,sp,-16
ffffffffc0200812:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200814:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200816:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200818:	00006517          	auipc	a0,0x6
ffffffffc020081c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0206238 <commands+0x3a8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200820:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200822:	95fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200826:	8522                	mv	a0,s0
ffffffffc0200828:	e1dff0ef          	jal	ra,ffffffffc0200644 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020082c:	10043583          	ld	a1,256(s0)
ffffffffc0200830:	00006517          	auipc	a0,0x6
ffffffffc0200834:	a2050513          	addi	a0,a0,-1504 # ffffffffc0206250 <commands+0x3c0>
ffffffffc0200838:	949ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020083c:	10843583          	ld	a1,264(s0)
ffffffffc0200840:	00006517          	auipc	a0,0x6
ffffffffc0200844:	a2850513          	addi	a0,a0,-1496 # ffffffffc0206268 <commands+0x3d8>
ffffffffc0200848:	939ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020084c:	11043583          	ld	a1,272(s0)
ffffffffc0200850:	00006517          	auipc	a0,0x6
ffffffffc0200854:	a3050513          	addi	a0,a0,-1488 # ffffffffc0206280 <commands+0x3f0>
ffffffffc0200858:	929ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020085c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200860:	6402                	ld	s0,0(sp)
ffffffffc0200862:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200864:	00006517          	auipc	a0,0x6
ffffffffc0200868:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0206290 <commands+0x400>
}
ffffffffc020086c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086e:	913ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200872 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200872:	1101                	addi	sp,sp,-32
ffffffffc0200874:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200876:	000b2497          	auipc	s1,0xb2
ffffffffc020087a:	fba48493          	addi	s1,s1,-70 # ffffffffc02b2830 <check_mm_struct>
ffffffffc020087e:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc0200880:	e822                	sd	s0,16(sp)
ffffffffc0200882:	ec06                	sd	ra,24(sp)
ffffffffc0200884:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200886:	cbad                	beqz	a5,ffffffffc02008f8 <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200888:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020088c:	11053583          	ld	a1,272(a0)
ffffffffc0200890:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200894:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200898:	c7b1                	beqz	a5,ffffffffc02008e4 <pgfault_handler+0x72>
ffffffffc020089a:	11843703          	ld	a4,280(s0)
ffffffffc020089e:	47bd                	li	a5,15
ffffffffc02008a0:	05700693          	li	a3,87
ffffffffc02008a4:	00f70463          	beq	a4,a5,ffffffffc02008ac <pgfault_handler+0x3a>
ffffffffc02008a8:	05200693          	li	a3,82
ffffffffc02008ac:	00006517          	auipc	a0,0x6
ffffffffc02008b0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02062a8 <commands+0x418>
ffffffffc02008b4:	8cdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008b8:	6088                	ld	a0,0(s1)
ffffffffc02008ba:	cd1d                	beqz	a0,ffffffffc02008f8 <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008bc:	000b2717          	auipc	a4,0xb2
ffffffffc02008c0:	f8473703          	ld	a4,-124(a4) # ffffffffc02b2840 <current>
ffffffffc02008c4:	000b2797          	auipc	a5,0xb2
ffffffffc02008c8:	f847b783          	ld	a5,-124(a5) # ffffffffc02b2848 <idleproc>
ffffffffc02008cc:	04f71663          	bne	a4,a5,ffffffffc0200918 <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008d0:	11043603          	ld	a2,272(s0)
ffffffffc02008d4:	11843583          	ld	a1,280(s0)
}
ffffffffc02008d8:	6442                	ld	s0,16(sp)
ffffffffc02008da:	60e2                	ld	ra,24(sp)
ffffffffc02008dc:	64a2                	ld	s1,8(sp)
ffffffffc02008de:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008e0:	5b10306f          	j	ffffffffc0204690 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008e4:	11843703          	ld	a4,280(s0)
ffffffffc02008e8:	47bd                	li	a5,15
ffffffffc02008ea:	05500613          	li	a2,85
ffffffffc02008ee:	05700693          	li	a3,87
ffffffffc02008f2:	faf71be3          	bne	a4,a5,ffffffffc02008a8 <pgfault_handler+0x36>
ffffffffc02008f6:	bf5d                	j	ffffffffc02008ac <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc02008f8:	000b2797          	auipc	a5,0xb2
ffffffffc02008fc:	f487b783          	ld	a5,-184(a5) # ffffffffc02b2840 <current>
ffffffffc0200900:	cf85                	beqz	a5,ffffffffc0200938 <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200902:	11043603          	ld	a2,272(s0)
ffffffffc0200906:	11843583          	ld	a1,280(s0)
}
ffffffffc020090a:	6442                	ld	s0,16(sp)
ffffffffc020090c:	60e2                	ld	ra,24(sp)
ffffffffc020090e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200910:	7788                	ld	a0,40(a5)
}
ffffffffc0200912:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200914:	57d0306f          	j	ffffffffc0204690 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200918:	00006697          	auipc	a3,0x6
ffffffffc020091c:	9b068693          	addi	a3,a3,-1616 # ffffffffc02062c8 <commands+0x438>
ffffffffc0200920:	00006617          	auipc	a2,0x6
ffffffffc0200924:	9c060613          	addi	a2,a2,-1600 # ffffffffc02062e0 <commands+0x450>
ffffffffc0200928:	06b00593          	li	a1,107
ffffffffc020092c:	00006517          	auipc	a0,0x6
ffffffffc0200930:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02062f8 <commands+0x468>
ffffffffc0200934:	b47ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200938:	8522                	mv	a0,s0
ffffffffc020093a:	ed7ff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020093e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200942:	11043583          	ld	a1,272(s0)
ffffffffc0200946:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020094a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020094e:	e399                	bnez	a5,ffffffffc0200954 <pgfault_handler+0xe2>
ffffffffc0200950:	05500613          	li	a2,85
ffffffffc0200954:	11843703          	ld	a4,280(s0)
ffffffffc0200958:	47bd                	li	a5,15
ffffffffc020095a:	02f70663          	beq	a4,a5,ffffffffc0200986 <pgfault_handler+0x114>
ffffffffc020095e:	05200693          	li	a3,82
ffffffffc0200962:	00006517          	auipc	a0,0x6
ffffffffc0200966:	94650513          	addi	a0,a0,-1722 # ffffffffc02062a8 <commands+0x418>
ffffffffc020096a:	817ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc020096e:	00006617          	auipc	a2,0x6
ffffffffc0200972:	9a260613          	addi	a2,a2,-1630 # ffffffffc0206310 <commands+0x480>
ffffffffc0200976:	07200593          	li	a1,114
ffffffffc020097a:	00006517          	auipc	a0,0x6
ffffffffc020097e:	97e50513          	addi	a0,a0,-1666 # ffffffffc02062f8 <commands+0x468>
ffffffffc0200982:	af9ff0ef          	jal	ra,ffffffffc020047a <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200986:	05700693          	li	a3,87
ffffffffc020098a:	bfe1                	j	ffffffffc0200962 <pgfault_handler+0xf0>

ffffffffc020098c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020098c:	11853783          	ld	a5,280(a0)
ffffffffc0200990:	472d                	li	a4,11
ffffffffc0200992:	0786                	slli	a5,a5,0x1
ffffffffc0200994:	8385                	srli	a5,a5,0x1
ffffffffc0200996:	08f76363          	bltu	a4,a5,ffffffffc0200a1c <interrupt_handler+0x90>
ffffffffc020099a:	00006717          	auipc	a4,0x6
ffffffffc020099e:	a2e70713          	addi	a4,a4,-1490 # ffffffffc02063c8 <commands+0x538>
ffffffffc02009a2:	078a                	slli	a5,a5,0x2
ffffffffc02009a4:	97ba                	add	a5,a5,a4
ffffffffc02009a6:	439c                	lw	a5,0(a5)
ffffffffc02009a8:	97ba                	add	a5,a5,a4
ffffffffc02009aa:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ac:	00006517          	auipc	a0,0x6
ffffffffc02009b0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0206388 <commands+0x4f8>
ffffffffc02009b4:	fccff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009b8:	00006517          	auipc	a0,0x6
ffffffffc02009bc:	9b050513          	addi	a0,a0,-1616 # ffffffffc0206368 <commands+0x4d8>
ffffffffc02009c0:	fc0ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009c4:	00006517          	auipc	a0,0x6
ffffffffc02009c8:	96450513          	addi	a0,a0,-1692 # ffffffffc0206328 <commands+0x498>
ffffffffc02009cc:	fb4ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009d0:	00006517          	auipc	a0,0x6
ffffffffc02009d4:	97850513          	addi	a0,a0,-1672 # ffffffffc0206348 <commands+0x4b8>
ffffffffc02009d8:	fa8ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009dc:	1141                	addi	sp,sp,-16
ffffffffc02009de:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009e0:	b7fff0ef          	jal	ra,ffffffffc020055e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009e4:	000b2697          	auipc	a3,0xb2
ffffffffc02009e8:	dec68693          	addi	a3,a3,-532 # ffffffffc02b27d0 <ticks>
ffffffffc02009ec:	629c                	ld	a5,0(a3)
ffffffffc02009ee:	06400713          	li	a4,100
ffffffffc02009f2:	0785                	addi	a5,a5,1
ffffffffc02009f4:	02e7f733          	remu	a4,a5,a4
ffffffffc02009f8:	e29c                	sd	a5,0(a3)
ffffffffc02009fa:	eb01                	bnez	a4,ffffffffc0200a0a <interrupt_handler+0x7e>
ffffffffc02009fc:	000b2797          	auipc	a5,0xb2
ffffffffc0200a00:	e447b783          	ld	a5,-444(a5) # ffffffffc02b2840 <current>
ffffffffc0200a04:	c399                	beqz	a5,ffffffffc0200a0a <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a06:	4705                	li	a4,1
ffffffffc0200a08:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a0a:	60a2                	ld	ra,8(sp)
ffffffffc0200a0c:	0141                	addi	sp,sp,16
ffffffffc0200a0e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a10:	00006517          	auipc	a0,0x6
ffffffffc0200a14:	99850513          	addi	a0,a0,-1640 # ffffffffc02063a8 <commands+0x518>
ffffffffc0200a18:	f68ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200a1c:	bbd5                	j	ffffffffc0200810 <print_trapframe>

ffffffffc0200a1e <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a1e:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a22:	1101                	addi	sp,sp,-32
ffffffffc0200a24:	e822                	sd	s0,16(sp)
ffffffffc0200a26:	ec06                	sd	ra,24(sp)
ffffffffc0200a28:	e426                	sd	s1,8(sp)
ffffffffc0200a2a:	473d                	li	a4,15
ffffffffc0200a2c:	842a                	mv	s0,a0
ffffffffc0200a2e:	18f76563          	bltu	a4,a5,ffffffffc0200bb8 <exception_handler+0x19a>
ffffffffc0200a32:	00006717          	auipc	a4,0x6
ffffffffc0200a36:	b5e70713          	addi	a4,a4,-1186 # ffffffffc0206590 <commands+0x700>
ffffffffc0200a3a:	078a                	slli	a5,a5,0x2
ffffffffc0200a3c:	97ba                	add	a5,a5,a4
ffffffffc0200a3e:	439c                	lw	a5,0(a5)
ffffffffc0200a40:	97ba                	add	a5,a5,a4
ffffffffc0200a42:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a44:	00006517          	auipc	a0,0x6
ffffffffc0200a48:	aa450513          	addi	a0,a0,-1372 # ffffffffc02064e8 <commands+0x658>
ffffffffc0200a4c:	f34ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a50:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a54:	60e2                	ld	ra,24(sp)
ffffffffc0200a56:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a58:	0791                	addi	a5,a5,4
ffffffffc0200a5a:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a5e:	6442                	ld	s0,16(sp)
ffffffffc0200a60:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a62:	4970406f          	j	ffffffffc02056f8 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a66:	00006517          	auipc	a0,0x6
ffffffffc0200a6a:	aa250513          	addi	a0,a0,-1374 # ffffffffc0206508 <commands+0x678>
}
ffffffffc0200a6e:	6442                	ld	s0,16(sp)
ffffffffc0200a70:	60e2                	ld	ra,24(sp)
ffffffffc0200a72:	64a2                	ld	s1,8(sp)
ffffffffc0200a74:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a76:	f0aff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a7a:	00006517          	auipc	a0,0x6
ffffffffc0200a7e:	aae50513          	addi	a0,a0,-1362 # ffffffffc0206528 <commands+0x698>
ffffffffc0200a82:	b7f5                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a84:	00006517          	auipc	a0,0x6
ffffffffc0200a88:	ac450513          	addi	a0,a0,-1340 # ffffffffc0206548 <commands+0x6b8>
ffffffffc0200a8c:	b7cd                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a8e:	00006517          	auipc	a0,0x6
ffffffffc0200a92:	ad250513          	addi	a0,a0,-1326 # ffffffffc0206560 <commands+0x6d0>
ffffffffc0200a96:	eeaff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a9a:	8522                	mv	a0,s0
ffffffffc0200a9c:	dd7ff0ef          	jal	ra,ffffffffc0200872 <pgfault_handler>
ffffffffc0200aa0:	84aa                	mv	s1,a0
ffffffffc0200aa2:	12051d63          	bnez	a0,ffffffffc0200bdc <exception_handler+0x1be>
}
ffffffffc0200aa6:	60e2                	ld	ra,24(sp)
ffffffffc0200aa8:	6442                	ld	s0,16(sp)
ffffffffc0200aaa:	64a2                	ld	s1,8(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
ffffffffc0200aae:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ab0:	00006517          	auipc	a0,0x6
ffffffffc0200ab4:	ac850513          	addi	a0,a0,-1336 # ffffffffc0206578 <commands+0x6e8>
ffffffffc0200ab8:	ec8ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abc:	8522                	mv	a0,s0
ffffffffc0200abe:	db5ff0ef          	jal	ra,ffffffffc0200872 <pgfault_handler>
ffffffffc0200ac2:	84aa                	mv	s1,a0
ffffffffc0200ac4:	d16d                	beqz	a0,ffffffffc0200aa6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ac6:	8522                	mv	a0,s0
ffffffffc0200ac8:	d49ff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200acc:	86a6                	mv	a3,s1
ffffffffc0200ace:	00006617          	auipc	a2,0x6
ffffffffc0200ad2:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0206498 <commands+0x608>
ffffffffc0200ad6:	0f800593          	li	a1,248
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	81e50513          	addi	a0,a0,-2018 # ffffffffc02062f8 <commands+0x468>
ffffffffc0200ae2:	999ff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200ae6:	00006517          	auipc	a0,0x6
ffffffffc0200aea:	91250513          	addi	a0,a0,-1774 # ffffffffc02063f8 <commands+0x568>
ffffffffc0200aee:	b741                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200af0:	00006517          	auipc	a0,0x6
ffffffffc0200af4:	92850513          	addi	a0,a0,-1752 # ffffffffc0206418 <commands+0x588>
ffffffffc0200af8:	bf9d                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200afa:	00006517          	auipc	a0,0x6
ffffffffc0200afe:	93e50513          	addi	a0,a0,-1730 # ffffffffc0206438 <commands+0x5a8>
ffffffffc0200b02:	b7b5                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b04:	00006517          	auipc	a0,0x6
ffffffffc0200b08:	94c50513          	addi	a0,a0,-1716 # ffffffffc0206450 <commands+0x5c0>
ffffffffc0200b0c:	e74ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b10:	6458                	ld	a4,136(s0)
ffffffffc0200b12:	47a9                	li	a5,10
ffffffffc0200b14:	f8f719e3          	bne	a4,a5,ffffffffc0200aa6 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b18:	10843783          	ld	a5,264(s0)
ffffffffc0200b1c:	0791                	addi	a5,a5,4
ffffffffc0200b1e:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b22:	3d7040ef          	jal	ra,ffffffffc02056f8 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b26:	000b2797          	auipc	a5,0xb2
ffffffffc0200b2a:	d1a7b783          	ld	a5,-742(a5) # ffffffffc02b2840 <current>
ffffffffc0200b2e:	6b9c                	ld	a5,16(a5)
ffffffffc0200b30:	8522                	mv	a0,s0
}
ffffffffc0200b32:	6442                	ld	s0,16(sp)
ffffffffc0200b34:	60e2                	ld	ra,24(sp)
ffffffffc0200b36:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b38:	6589                	lui	a1,0x2
ffffffffc0200b3a:	95be                	add	a1,a1,a5
}
ffffffffc0200b3c:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b3e:	ac21                	j	ffffffffc0200d56 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b40:	00006517          	auipc	a0,0x6
ffffffffc0200b44:	92050513          	addi	a0,a0,-1760 # ffffffffc0206460 <commands+0x5d0>
ffffffffc0200b48:	b71d                	j	ffffffffc0200a6e <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b4a:	00006517          	auipc	a0,0x6
ffffffffc0200b4e:	93650513          	addi	a0,a0,-1738 # ffffffffc0206480 <commands+0x5f0>
ffffffffc0200b52:	e2eff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b56:	8522                	mv	a0,s0
ffffffffc0200b58:	d1bff0ef          	jal	ra,ffffffffc0200872 <pgfault_handler>
ffffffffc0200b5c:	84aa                	mv	s1,a0
ffffffffc0200b5e:	d521                	beqz	a0,ffffffffc0200aa6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b60:	8522                	mv	a0,s0
ffffffffc0200b62:	cafff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b66:	86a6                	mv	a3,s1
ffffffffc0200b68:	00006617          	auipc	a2,0x6
ffffffffc0200b6c:	93060613          	addi	a2,a2,-1744 # ffffffffc0206498 <commands+0x608>
ffffffffc0200b70:	0cd00593          	li	a1,205
ffffffffc0200b74:	00005517          	auipc	a0,0x5
ffffffffc0200b78:	78450513          	addi	a0,a0,1924 # ffffffffc02062f8 <commands+0x468>
ffffffffc0200b7c:	8ffff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b80:	00006517          	auipc	a0,0x6
ffffffffc0200b84:	95050513          	addi	a0,a0,-1712 # ffffffffc02064d0 <commands+0x640>
ffffffffc0200b88:	df8ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b8c:	8522                	mv	a0,s0
ffffffffc0200b8e:	ce5ff0ef          	jal	ra,ffffffffc0200872 <pgfault_handler>
ffffffffc0200b92:	84aa                	mv	s1,a0
ffffffffc0200b94:	f00509e3          	beqz	a0,ffffffffc0200aa6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b98:	8522                	mv	a0,s0
ffffffffc0200b9a:	c77ff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b9e:	86a6                	mv	a3,s1
ffffffffc0200ba0:	00006617          	auipc	a2,0x6
ffffffffc0200ba4:	8f860613          	addi	a2,a2,-1800 # ffffffffc0206498 <commands+0x608>
ffffffffc0200ba8:	0d700593          	li	a1,215
ffffffffc0200bac:	00005517          	auipc	a0,0x5
ffffffffc0200bb0:	74c50513          	addi	a0,a0,1868 # ffffffffc02062f8 <commands+0x468>
ffffffffc0200bb4:	8c7ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200bb8:	8522                	mv	a0,s0
}
ffffffffc0200bba:	6442                	ld	s0,16(sp)
ffffffffc0200bbc:	60e2                	ld	ra,24(sp)
ffffffffc0200bbe:	64a2                	ld	s1,8(sp)
ffffffffc0200bc0:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bc2:	b1b9                	j	ffffffffc0200810 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bc4:	00006617          	auipc	a2,0x6
ffffffffc0200bc8:	8f460613          	addi	a2,a2,-1804 # ffffffffc02064b8 <commands+0x628>
ffffffffc0200bcc:	0d100593          	li	a1,209
ffffffffc0200bd0:	00005517          	auipc	a0,0x5
ffffffffc0200bd4:	72850513          	addi	a0,a0,1832 # ffffffffc02062f8 <commands+0x468>
ffffffffc0200bd8:	8a3ff0ef          	jal	ra,ffffffffc020047a <__panic>
                print_trapframe(tf);
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	c33ff0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be2:	86a6                	mv	a3,s1
ffffffffc0200be4:	00006617          	auipc	a2,0x6
ffffffffc0200be8:	8b460613          	addi	a2,a2,-1868 # ffffffffc0206498 <commands+0x608>
ffffffffc0200bec:	0f100593          	li	a1,241
ffffffffc0200bf0:	00005517          	auipc	a0,0x5
ffffffffc0200bf4:	70850513          	addi	a0,a0,1800 # ffffffffc02062f8 <commands+0x468>
ffffffffc0200bf8:	883ff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0200bfc <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200bfc:	1101                	addi	sp,sp,-32
ffffffffc0200bfe:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c00:	000b2417          	auipc	s0,0xb2
ffffffffc0200c04:	c4040413          	addi	s0,s0,-960 # ffffffffc02b2840 <current>
ffffffffc0200c08:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c0a:	ec06                	sd	ra,24(sp)
ffffffffc0200c0c:	e426                	sd	s1,8(sp)
ffffffffc0200c0e:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c10:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c14:	cf1d                	beqz	a4,ffffffffc0200c52 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c16:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c1a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c1e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c20:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c24:	0206c463          	bltz	a3,ffffffffc0200c4c <trap+0x50>
        exception_handler(tf);
ffffffffc0200c28:	df7ff0ef          	jal	ra,ffffffffc0200a1e <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c2c:	601c                	ld	a5,0(s0)
ffffffffc0200c2e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c32:	e499                	bnez	s1,ffffffffc0200c40 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c34:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c38:	8b05                	andi	a4,a4,1
ffffffffc0200c3a:	e329                	bnez	a4,ffffffffc0200c7c <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c3c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c3e:	eb85                	bnez	a5,ffffffffc0200c6e <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c40:	60e2                	ld	ra,24(sp)
ffffffffc0200c42:	6442                	ld	s0,16(sp)
ffffffffc0200c44:	64a2                	ld	s1,8(sp)
ffffffffc0200c46:	6902                	ld	s2,0(sp)
ffffffffc0200c48:	6105                	addi	sp,sp,32
ffffffffc0200c4a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c4c:	d41ff0ef          	jal	ra,ffffffffc020098c <interrupt_handler>
ffffffffc0200c50:	bff1                	j	ffffffffc0200c2c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c52:	0006c863          	bltz	a3,ffffffffc0200c62 <trap+0x66>
}
ffffffffc0200c56:	6442                	ld	s0,16(sp)
ffffffffc0200c58:	60e2                	ld	ra,24(sp)
ffffffffc0200c5a:	64a2                	ld	s1,8(sp)
ffffffffc0200c5c:	6902                	ld	s2,0(sp)
ffffffffc0200c5e:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c60:	bb7d                	j	ffffffffc0200a1e <exception_handler>
}
ffffffffc0200c62:	6442                	ld	s0,16(sp)
ffffffffc0200c64:	60e2                	ld	ra,24(sp)
ffffffffc0200c66:	64a2                	ld	s1,8(sp)
ffffffffc0200c68:	6902                	ld	s2,0(sp)
ffffffffc0200c6a:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c6c:	b305                	j	ffffffffc020098c <interrupt_handler>
}
ffffffffc0200c6e:	6442                	ld	s0,16(sp)
ffffffffc0200c70:	60e2                	ld	ra,24(sp)
ffffffffc0200c72:	64a2                	ld	s1,8(sp)
ffffffffc0200c74:	6902                	ld	s2,0(sp)
ffffffffc0200c76:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c78:	1950406f          	j	ffffffffc020560c <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c7c:	555d                	li	a0,-9
ffffffffc0200c7e:	55b030ef          	jal	ra,ffffffffc02049d8 <do_exit>
            if (current->need_resched) {
ffffffffc0200c82:	601c                	ld	a5,0(s0)
ffffffffc0200c84:	bf65                	j	ffffffffc0200c3c <trap+0x40>
	...

ffffffffc0200c88 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200c88:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200c8c:	00011463          	bnez	sp,ffffffffc0200c94 <__alltraps+0xc>
ffffffffc0200c90:	14002173          	csrr	sp,sscratch
ffffffffc0200c94:	712d                	addi	sp,sp,-288
ffffffffc0200c96:	e002                	sd	zero,0(sp)
ffffffffc0200c98:	e406                	sd	ra,8(sp)
ffffffffc0200c9a:	ec0e                	sd	gp,24(sp)
ffffffffc0200c9c:	f012                	sd	tp,32(sp)
ffffffffc0200c9e:	f416                	sd	t0,40(sp)
ffffffffc0200ca0:	f81a                	sd	t1,48(sp)
ffffffffc0200ca2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ca4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ca6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ca8:	e8aa                	sd	a0,80(sp)
ffffffffc0200caa:	ecae                	sd	a1,88(sp)
ffffffffc0200cac:	f0b2                	sd	a2,96(sp)
ffffffffc0200cae:	f4b6                	sd	a3,104(sp)
ffffffffc0200cb0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cb2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cb4:	e142                	sd	a6,128(sp)
ffffffffc0200cb6:	e546                	sd	a7,136(sp)
ffffffffc0200cb8:	e94a                	sd	s2,144(sp)
ffffffffc0200cba:	ed4e                	sd	s3,152(sp)
ffffffffc0200cbc:	f152                	sd	s4,160(sp)
ffffffffc0200cbe:	f556                	sd	s5,168(sp)
ffffffffc0200cc0:	f95a                	sd	s6,176(sp)
ffffffffc0200cc2:	fd5e                	sd	s7,184(sp)
ffffffffc0200cc4:	e1e2                	sd	s8,192(sp)
ffffffffc0200cc6:	e5e6                	sd	s9,200(sp)
ffffffffc0200cc8:	e9ea                	sd	s10,208(sp)
ffffffffc0200cca:	edee                	sd	s11,216(sp)
ffffffffc0200ccc:	f1f2                	sd	t3,224(sp)
ffffffffc0200cce:	f5f6                	sd	t4,232(sp)
ffffffffc0200cd0:	f9fa                	sd	t5,240(sp)
ffffffffc0200cd2:	fdfe                	sd	t6,248(sp)
ffffffffc0200cd4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cd8:	100024f3          	csrr	s1,sstatus
ffffffffc0200cdc:	14102973          	csrr	s2,sepc
ffffffffc0200ce0:	143029f3          	csrr	s3,stval
ffffffffc0200ce4:	14202a73          	csrr	s4,scause
ffffffffc0200ce8:	e822                	sd	s0,16(sp)
ffffffffc0200cea:	e226                	sd	s1,256(sp)
ffffffffc0200cec:	e64a                	sd	s2,264(sp)
ffffffffc0200cee:	ea4e                	sd	s3,272(sp)
ffffffffc0200cf0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cf2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cf4:	f09ff0ef          	jal	ra,ffffffffc0200bfc <trap>

ffffffffc0200cf8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200cf8:	6492                	ld	s1,256(sp)
ffffffffc0200cfa:	6932                	ld	s2,264(sp)
ffffffffc0200cfc:	1004f413          	andi	s0,s1,256
ffffffffc0200d00:	e401                	bnez	s0,ffffffffc0200d08 <__trapret+0x10>
ffffffffc0200d02:	1200                	addi	s0,sp,288
ffffffffc0200d04:	14041073          	csrw	sscratch,s0
ffffffffc0200d08:	10049073          	csrw	sstatus,s1
ffffffffc0200d0c:	14191073          	csrw	sepc,s2
ffffffffc0200d10:	60a2                	ld	ra,8(sp)
ffffffffc0200d12:	61e2                	ld	gp,24(sp)
ffffffffc0200d14:	7202                	ld	tp,32(sp)
ffffffffc0200d16:	72a2                	ld	t0,40(sp)
ffffffffc0200d18:	7342                	ld	t1,48(sp)
ffffffffc0200d1a:	73e2                	ld	t2,56(sp)
ffffffffc0200d1c:	6406                	ld	s0,64(sp)
ffffffffc0200d1e:	64a6                	ld	s1,72(sp)
ffffffffc0200d20:	6546                	ld	a0,80(sp)
ffffffffc0200d22:	65e6                	ld	a1,88(sp)
ffffffffc0200d24:	7606                	ld	a2,96(sp)
ffffffffc0200d26:	76a6                	ld	a3,104(sp)
ffffffffc0200d28:	7746                	ld	a4,112(sp)
ffffffffc0200d2a:	77e6                	ld	a5,120(sp)
ffffffffc0200d2c:	680a                	ld	a6,128(sp)
ffffffffc0200d2e:	68aa                	ld	a7,136(sp)
ffffffffc0200d30:	694a                	ld	s2,144(sp)
ffffffffc0200d32:	69ea                	ld	s3,152(sp)
ffffffffc0200d34:	7a0a                	ld	s4,160(sp)
ffffffffc0200d36:	7aaa                	ld	s5,168(sp)
ffffffffc0200d38:	7b4a                	ld	s6,176(sp)
ffffffffc0200d3a:	7bea                	ld	s7,184(sp)
ffffffffc0200d3c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d3e:	6cae                	ld	s9,200(sp)
ffffffffc0200d40:	6d4e                	ld	s10,208(sp)
ffffffffc0200d42:	6dee                	ld	s11,216(sp)
ffffffffc0200d44:	7e0e                	ld	t3,224(sp)
ffffffffc0200d46:	7eae                	ld	t4,232(sp)
ffffffffc0200d48:	7f4e                	ld	t5,240(sp)
ffffffffc0200d4a:	7fee                	ld	t6,248(sp)
ffffffffc0200d4c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d4e:	10200073          	sret

ffffffffc0200d52 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d52:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d54:	b755                	j	ffffffffc0200cf8 <__trapret>

ffffffffc0200d56 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d56:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d5a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d5e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d62:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d66:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d6a:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d6e:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d72:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d76:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d7a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d7c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d7e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d80:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d82:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d84:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d86:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200d88:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200d8a:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200d8c:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200d8e:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200d90:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200d92:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200d94:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200d96:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200d98:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200d9a:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200d9c:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200d9e:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200da0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200da2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200da4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200da6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200da8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200daa:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dac:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dae:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200db0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200db2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200db4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200db6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200db8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dba:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dbc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dbe:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200dc0:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dc2:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200dc4:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dc6:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dc8:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dca:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200dcc:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dce:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dd0:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dd2:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200dd4:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dd6:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dd8:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dda:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200ddc:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dde:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200de0:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200de2:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200de4:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200de6:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200de8:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200dea:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200dec:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200dee:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200df0:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200df2:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200df4:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200df6:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200df8:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200dfa:	812e                	mv	sp,a1
ffffffffc0200dfc:	bdf5                	j	ffffffffc0200cf8 <__trapret>

ffffffffc0200dfe <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200dfe:	000ae797          	auipc	a5,0xae
ffffffffc0200e02:	90278793          	addi	a5,a5,-1790 # ffffffffc02ae700 <free_area>
ffffffffc0200e06:	e79c                	sd	a5,8(a5)
ffffffffc0200e08:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e0a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e0e:	8082                	ret

ffffffffc0200e10 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e10:	000ae517          	auipc	a0,0xae
ffffffffc0200e14:	90056503          	lwu	a0,-1792(a0) # ffffffffc02ae710 <free_area+0x10>
ffffffffc0200e18:	8082                	ret

ffffffffc0200e1a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e1a:	715d                	addi	sp,sp,-80
ffffffffc0200e1c:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e1e:	000ae417          	auipc	s0,0xae
ffffffffc0200e22:	8e240413          	addi	s0,s0,-1822 # ffffffffc02ae700 <free_area>
ffffffffc0200e26:	641c                	ld	a5,8(s0)
ffffffffc0200e28:	e486                	sd	ra,72(sp)
ffffffffc0200e2a:	fc26                	sd	s1,56(sp)
ffffffffc0200e2c:	f84a                	sd	s2,48(sp)
ffffffffc0200e2e:	f44e                	sd	s3,40(sp)
ffffffffc0200e30:	f052                	sd	s4,32(sp)
ffffffffc0200e32:	ec56                	sd	s5,24(sp)
ffffffffc0200e34:	e85a                	sd	s6,16(sp)
ffffffffc0200e36:	e45e                	sd	s7,8(sp)
ffffffffc0200e38:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e3a:	2a878d63          	beq	a5,s0,ffffffffc02010f4 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200e3e:	4481                	li	s1,0
ffffffffc0200e40:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e42:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e46:	8b09                	andi	a4,a4,2
ffffffffc0200e48:	2a070a63          	beqz	a4,ffffffffc02010fc <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200e4c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e50:	679c                	ld	a5,8(a5)
ffffffffc0200e52:	2905                	addiw	s2,s2,1
ffffffffc0200e54:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e56:	fe8796e3          	bne	a5,s0,ffffffffc0200e42 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e5a:	89a6                	mv	s3,s1
ffffffffc0200e5c:	733000ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
ffffffffc0200e60:	6f351e63          	bne	a0,s3,ffffffffc020155c <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e64:	4505                	li	a0,1
ffffffffc0200e66:	657000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200e6a:	8aaa                	mv	s5,a0
ffffffffc0200e6c:	42050863          	beqz	a0,ffffffffc020129c <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e70:	4505                	li	a0,1
ffffffffc0200e72:	64b000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200e76:	89aa                	mv	s3,a0
ffffffffc0200e78:	70050263          	beqz	a0,ffffffffc020157c <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e7c:	4505                	li	a0,1
ffffffffc0200e7e:	63f000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200e82:	8a2a                	mv	s4,a0
ffffffffc0200e84:	48050c63          	beqz	a0,ffffffffc020131c <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e88:	293a8a63          	beq	s5,s3,ffffffffc020111c <default_check+0x302>
ffffffffc0200e8c:	28aa8863          	beq	s5,a0,ffffffffc020111c <default_check+0x302>
ffffffffc0200e90:	28a98663          	beq	s3,a0,ffffffffc020111c <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e94:	000aa783          	lw	a5,0(s5)
ffffffffc0200e98:	2a079263          	bnez	a5,ffffffffc020113c <default_check+0x322>
ffffffffc0200e9c:	0009a783          	lw	a5,0(s3)
ffffffffc0200ea0:	28079e63          	bnez	a5,ffffffffc020113c <default_check+0x322>
ffffffffc0200ea4:	411c                	lw	a5,0(a0)
ffffffffc0200ea6:	28079b63          	bnez	a5,ffffffffc020113c <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200eaa:	000b2797          	auipc	a5,0xb2
ffffffffc0200eae:	9567b783          	ld	a5,-1706(a5) # ffffffffc02b2800 <pages>
ffffffffc0200eb2:	40fa8733          	sub	a4,s5,a5
ffffffffc0200eb6:	00007617          	auipc	a2,0x7
ffffffffc0200eba:	35a63603          	ld	a2,858(a2) # ffffffffc0208210 <nbase>
ffffffffc0200ebe:	8719                	srai	a4,a4,0x6
ffffffffc0200ec0:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ec2:	000b2697          	auipc	a3,0xb2
ffffffffc0200ec6:	9366b683          	ld	a3,-1738(a3) # ffffffffc02b27f8 <npage>
ffffffffc0200eca:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ecc:	0732                	slli	a4,a4,0xc
ffffffffc0200ece:	28d77763          	bgeu	a4,a3,ffffffffc020115c <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200ed2:	40f98733          	sub	a4,s3,a5
ffffffffc0200ed6:	8719                	srai	a4,a4,0x6
ffffffffc0200ed8:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eda:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200edc:	4cd77063          	bgeu	a4,a3,ffffffffc020139c <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200ee0:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ee4:	8799                	srai	a5,a5,0x6
ffffffffc0200ee6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ee8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200eea:	30d7f963          	bgeu	a5,a3,ffffffffc02011fc <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200eee:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ef0:	00043c03          	ld	s8,0(s0)
ffffffffc0200ef4:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200ef8:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200efc:	e400                	sd	s0,8(s0)
ffffffffc0200efe:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200f00:	000ae797          	auipc	a5,0xae
ffffffffc0200f04:	8007a823          	sw	zero,-2032(a5) # ffffffffc02ae710 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f08:	5b5000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f0c:	2c051863          	bnez	a0,ffffffffc02011dc <default_check+0x3c2>
    free_page(p0);
ffffffffc0200f10:	4585                	li	a1,1
ffffffffc0200f12:	8556                	mv	a0,s5
ffffffffc0200f14:	63b000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p1);
ffffffffc0200f18:	4585                	li	a1,1
ffffffffc0200f1a:	854e                	mv	a0,s3
ffffffffc0200f1c:	633000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p2);
ffffffffc0200f20:	4585                	li	a1,1
ffffffffc0200f22:	8552                	mv	a0,s4
ffffffffc0200f24:	62b000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    assert(nr_free == 3);
ffffffffc0200f28:	4818                	lw	a4,16(s0)
ffffffffc0200f2a:	478d                	li	a5,3
ffffffffc0200f2c:	28f71863          	bne	a4,a5,ffffffffc02011bc <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f30:	4505                	li	a0,1
ffffffffc0200f32:	58b000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f36:	89aa                	mv	s3,a0
ffffffffc0200f38:	26050263          	beqz	a0,ffffffffc020119c <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f3c:	4505                	li	a0,1
ffffffffc0200f3e:	57f000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f42:	8aaa                	mv	s5,a0
ffffffffc0200f44:	3a050c63          	beqz	a0,ffffffffc02012fc <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f48:	4505                	li	a0,1
ffffffffc0200f4a:	573000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f4e:	8a2a                	mv	s4,a0
ffffffffc0200f50:	38050663          	beqz	a0,ffffffffc02012dc <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200f54:	4505                	li	a0,1
ffffffffc0200f56:	567000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f5a:	36051163          	bnez	a0,ffffffffc02012bc <default_check+0x4a2>
    free_page(p0);
ffffffffc0200f5e:	4585                	li	a1,1
ffffffffc0200f60:	854e                	mv	a0,s3
ffffffffc0200f62:	5ed000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f66:	641c                	ld	a5,8(s0)
ffffffffc0200f68:	20878a63          	beq	a5,s0,ffffffffc020117c <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200f6c:	4505                	li	a0,1
ffffffffc0200f6e:	54f000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f72:	30a99563          	bne	s3,a0,ffffffffc020127c <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200f76:	4505                	li	a0,1
ffffffffc0200f78:	545000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200f7c:	2e051063          	bnez	a0,ffffffffc020125c <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200f80:	481c                	lw	a5,16(s0)
ffffffffc0200f82:	2a079d63          	bnez	a5,ffffffffc020123c <default_check+0x422>
    free_page(p);
ffffffffc0200f86:	854e                	mv	a0,s3
ffffffffc0200f88:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f8a:	01843023          	sd	s8,0(s0)
ffffffffc0200f8e:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f92:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f96:	5b9000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p1);
ffffffffc0200f9a:	4585                	li	a1,1
ffffffffc0200f9c:	8556                	mv	a0,s5
ffffffffc0200f9e:	5b1000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p2);
ffffffffc0200fa2:	4585                	li	a1,1
ffffffffc0200fa4:	8552                	mv	a0,s4
ffffffffc0200fa6:	5a9000ef          	jal	ra,ffffffffc0201d4e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200faa:	4515                	li	a0,5
ffffffffc0200fac:	511000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200fb0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fb2:	26050563          	beqz	a0,ffffffffc020121c <default_check+0x402>
ffffffffc0200fb6:	651c                	ld	a5,8(a0)
ffffffffc0200fb8:	8385                	srli	a5,a5,0x1
ffffffffc0200fba:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0200fbc:	54079063          	bnez	a5,ffffffffc02014fc <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fc0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fc2:	00043b03          	ld	s6,0(s0)
ffffffffc0200fc6:	00843a83          	ld	s5,8(s0)
ffffffffc0200fca:	e000                	sd	s0,0(s0)
ffffffffc0200fcc:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200fce:	4ef000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200fd2:	50051563          	bnez	a0,ffffffffc02014dc <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200fd6:	08098a13          	addi	s4,s3,128
ffffffffc0200fda:	8552                	mv	a0,s4
ffffffffc0200fdc:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200fde:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200fe2:	000ad797          	auipc	a5,0xad
ffffffffc0200fe6:	7207a723          	sw	zero,1838(a5) # ffffffffc02ae710 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200fea:	565000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fee:	4511                	li	a0,4
ffffffffc0200ff0:	4cd000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0200ff4:	4c051463          	bnez	a0,ffffffffc02014bc <default_check+0x6a2>
ffffffffc0200ff8:	0889b783          	ld	a5,136(s3)
ffffffffc0200ffc:	8385                	srli	a5,a5,0x1
ffffffffc0200ffe:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201000:	48078e63          	beqz	a5,ffffffffc020149c <default_check+0x682>
ffffffffc0201004:	0909a703          	lw	a4,144(s3)
ffffffffc0201008:	478d                	li	a5,3
ffffffffc020100a:	48f71963          	bne	a4,a5,ffffffffc020149c <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020100e:	450d                	li	a0,3
ffffffffc0201010:	4ad000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201014:	8c2a                	mv	s8,a0
ffffffffc0201016:	46050363          	beqz	a0,ffffffffc020147c <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020101a:	4505                	li	a0,1
ffffffffc020101c:	4a1000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201020:	42051e63          	bnez	a0,ffffffffc020145c <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201024:	418a1c63          	bne	s4,s8,ffffffffc020143c <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201028:	4585                	li	a1,1
ffffffffc020102a:	854e                	mv	a0,s3
ffffffffc020102c:	523000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_pages(p1, 3);
ffffffffc0201030:	458d                	li	a1,3
ffffffffc0201032:	8552                	mv	a0,s4
ffffffffc0201034:	51b000ef          	jal	ra,ffffffffc0201d4e <free_pages>
ffffffffc0201038:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020103c:	04098c13          	addi	s8,s3,64
ffffffffc0201040:	8385                	srli	a5,a5,0x1
ffffffffc0201042:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201044:	3c078c63          	beqz	a5,ffffffffc020141c <default_check+0x602>
ffffffffc0201048:	0109a703          	lw	a4,16(s3)
ffffffffc020104c:	4785                	li	a5,1
ffffffffc020104e:	3cf71763          	bne	a4,a5,ffffffffc020141c <default_check+0x602>
ffffffffc0201052:	008a3783          	ld	a5,8(s4)
ffffffffc0201056:	8385                	srli	a5,a5,0x1
ffffffffc0201058:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020105a:	3a078163          	beqz	a5,ffffffffc02013fc <default_check+0x5e2>
ffffffffc020105e:	010a2703          	lw	a4,16(s4)
ffffffffc0201062:	478d                	li	a5,3
ffffffffc0201064:	38f71c63          	bne	a4,a5,ffffffffc02013fc <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201068:	4505                	li	a0,1
ffffffffc020106a:	453000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc020106e:	36a99763          	bne	s3,a0,ffffffffc02013dc <default_check+0x5c2>
    free_page(p0);
ffffffffc0201072:	4585                	li	a1,1
ffffffffc0201074:	4db000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201078:	4509                	li	a0,2
ffffffffc020107a:	443000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc020107e:	32aa1f63          	bne	s4,a0,ffffffffc02013bc <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0201082:	4589                	li	a1,2
ffffffffc0201084:	4cb000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    free_page(p2);
ffffffffc0201088:	4585                	li	a1,1
ffffffffc020108a:	8562                	mv	a0,s8
ffffffffc020108c:	4c3000ef          	jal	ra,ffffffffc0201d4e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201090:	4515                	li	a0,5
ffffffffc0201092:	42b000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201096:	89aa                	mv	s3,a0
ffffffffc0201098:	48050263          	beqz	a0,ffffffffc020151c <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc020109c:	4505                	li	a0,1
ffffffffc020109e:	41f000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc02010a2:	2c051d63          	bnez	a0,ffffffffc020137c <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02010a6:	481c                	lw	a5,16(s0)
ffffffffc02010a8:	2a079a63          	bnez	a5,ffffffffc020135c <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02010ac:	4595                	li	a1,5
ffffffffc02010ae:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02010b0:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02010b4:	01643023          	sd	s6,0(s0)
ffffffffc02010b8:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02010bc:	493000ef          	jal	ra,ffffffffc0201d4e <free_pages>
    return listelm->next;
ffffffffc02010c0:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010c2:	00878963          	beq	a5,s0,ffffffffc02010d4 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010c6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ca:	679c                	ld	a5,8(a5)
ffffffffc02010cc:	397d                	addiw	s2,s2,-1
ffffffffc02010ce:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010d0:	fe879be3          	bne	a5,s0,ffffffffc02010c6 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02010d4:	26091463          	bnez	s2,ffffffffc020133c <default_check+0x522>
    assert(total == 0);
ffffffffc02010d8:	46049263          	bnez	s1,ffffffffc020153c <default_check+0x722>
}
ffffffffc02010dc:	60a6                	ld	ra,72(sp)
ffffffffc02010de:	6406                	ld	s0,64(sp)
ffffffffc02010e0:	74e2                	ld	s1,56(sp)
ffffffffc02010e2:	7942                	ld	s2,48(sp)
ffffffffc02010e4:	79a2                	ld	s3,40(sp)
ffffffffc02010e6:	7a02                	ld	s4,32(sp)
ffffffffc02010e8:	6ae2                	ld	s5,24(sp)
ffffffffc02010ea:	6b42                	ld	s6,16(sp)
ffffffffc02010ec:	6ba2                	ld	s7,8(sp)
ffffffffc02010ee:	6c02                	ld	s8,0(sp)
ffffffffc02010f0:	6161                	addi	sp,sp,80
ffffffffc02010f2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010f4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02010f6:	4481                	li	s1,0
ffffffffc02010f8:	4901                	li	s2,0
ffffffffc02010fa:	b38d                	j	ffffffffc0200e5c <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02010fc:	00005697          	auipc	a3,0x5
ffffffffc0201100:	4d468693          	addi	a3,a3,1236 # ffffffffc02065d0 <commands+0x740>
ffffffffc0201104:	00005617          	auipc	a2,0x5
ffffffffc0201108:	1dc60613          	addi	a2,a2,476 # ffffffffc02062e0 <commands+0x450>
ffffffffc020110c:	0f000593          	li	a1,240
ffffffffc0201110:	00005517          	auipc	a0,0x5
ffffffffc0201114:	4d050513          	addi	a0,a0,1232 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201118:	b62ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020111c:	00005697          	auipc	a3,0x5
ffffffffc0201120:	55c68693          	addi	a3,a3,1372 # ffffffffc0206678 <commands+0x7e8>
ffffffffc0201124:	00005617          	auipc	a2,0x5
ffffffffc0201128:	1bc60613          	addi	a2,a2,444 # ffffffffc02062e0 <commands+0x450>
ffffffffc020112c:	0bd00593          	li	a1,189
ffffffffc0201130:	00005517          	auipc	a0,0x5
ffffffffc0201134:	4b050513          	addi	a0,a0,1200 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201138:	b42ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020113c:	00005697          	auipc	a3,0x5
ffffffffc0201140:	56468693          	addi	a3,a3,1380 # ffffffffc02066a0 <commands+0x810>
ffffffffc0201144:	00005617          	auipc	a2,0x5
ffffffffc0201148:	19c60613          	addi	a2,a2,412 # ffffffffc02062e0 <commands+0x450>
ffffffffc020114c:	0be00593          	li	a1,190
ffffffffc0201150:	00005517          	auipc	a0,0x5
ffffffffc0201154:	49050513          	addi	a0,a0,1168 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201158:	b22ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020115c:	00005697          	auipc	a3,0x5
ffffffffc0201160:	58468693          	addi	a3,a3,1412 # ffffffffc02066e0 <commands+0x850>
ffffffffc0201164:	00005617          	auipc	a2,0x5
ffffffffc0201168:	17c60613          	addi	a2,a2,380 # ffffffffc02062e0 <commands+0x450>
ffffffffc020116c:	0c000593          	li	a1,192
ffffffffc0201170:	00005517          	auipc	a0,0x5
ffffffffc0201174:	47050513          	addi	a0,a0,1136 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201178:	b02ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!list_empty(&free_list));
ffffffffc020117c:	00005697          	auipc	a3,0x5
ffffffffc0201180:	5ec68693          	addi	a3,a3,1516 # ffffffffc0206768 <commands+0x8d8>
ffffffffc0201184:	00005617          	auipc	a2,0x5
ffffffffc0201188:	15c60613          	addi	a2,a2,348 # ffffffffc02062e0 <commands+0x450>
ffffffffc020118c:	0d900593          	li	a1,217
ffffffffc0201190:	00005517          	auipc	a0,0x5
ffffffffc0201194:	45050513          	addi	a0,a0,1104 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201198:	ae2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020119c:	00005697          	auipc	a3,0x5
ffffffffc02011a0:	47c68693          	addi	a3,a3,1148 # ffffffffc0206618 <commands+0x788>
ffffffffc02011a4:	00005617          	auipc	a2,0x5
ffffffffc02011a8:	13c60613          	addi	a2,a2,316 # ffffffffc02062e0 <commands+0x450>
ffffffffc02011ac:	0d200593          	li	a1,210
ffffffffc02011b0:	00005517          	auipc	a0,0x5
ffffffffc02011b4:	43050513          	addi	a0,a0,1072 # ffffffffc02065e0 <commands+0x750>
ffffffffc02011b8:	ac2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 3);
ffffffffc02011bc:	00005697          	auipc	a3,0x5
ffffffffc02011c0:	59c68693          	addi	a3,a3,1436 # ffffffffc0206758 <commands+0x8c8>
ffffffffc02011c4:	00005617          	auipc	a2,0x5
ffffffffc02011c8:	11c60613          	addi	a2,a2,284 # ffffffffc02062e0 <commands+0x450>
ffffffffc02011cc:	0d000593          	li	a1,208
ffffffffc02011d0:	00005517          	auipc	a0,0x5
ffffffffc02011d4:	41050513          	addi	a0,a0,1040 # ffffffffc02065e0 <commands+0x750>
ffffffffc02011d8:	aa2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011dc:	00005697          	auipc	a3,0x5
ffffffffc02011e0:	56468693          	addi	a3,a3,1380 # ffffffffc0206740 <commands+0x8b0>
ffffffffc02011e4:	00005617          	auipc	a2,0x5
ffffffffc02011e8:	0fc60613          	addi	a2,a2,252 # ffffffffc02062e0 <commands+0x450>
ffffffffc02011ec:	0cb00593          	li	a1,203
ffffffffc02011f0:	00005517          	auipc	a0,0x5
ffffffffc02011f4:	3f050513          	addi	a0,a0,1008 # ffffffffc02065e0 <commands+0x750>
ffffffffc02011f8:	a82ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011fc:	00005697          	auipc	a3,0x5
ffffffffc0201200:	52468693          	addi	a3,a3,1316 # ffffffffc0206720 <commands+0x890>
ffffffffc0201204:	00005617          	auipc	a2,0x5
ffffffffc0201208:	0dc60613          	addi	a2,a2,220 # ffffffffc02062e0 <commands+0x450>
ffffffffc020120c:	0c200593          	li	a1,194
ffffffffc0201210:	00005517          	auipc	a0,0x5
ffffffffc0201214:	3d050513          	addi	a0,a0,976 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201218:	a62ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != NULL);
ffffffffc020121c:	00005697          	auipc	a3,0x5
ffffffffc0201220:	59468693          	addi	a3,a3,1428 # ffffffffc02067b0 <commands+0x920>
ffffffffc0201224:	00005617          	auipc	a2,0x5
ffffffffc0201228:	0bc60613          	addi	a2,a2,188 # ffffffffc02062e0 <commands+0x450>
ffffffffc020122c:	0f800593          	li	a1,248
ffffffffc0201230:	00005517          	auipc	a0,0x5
ffffffffc0201234:	3b050513          	addi	a0,a0,944 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201238:	a42ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc020123c:	00005697          	auipc	a3,0x5
ffffffffc0201240:	56468693          	addi	a3,a3,1380 # ffffffffc02067a0 <commands+0x910>
ffffffffc0201244:	00005617          	auipc	a2,0x5
ffffffffc0201248:	09c60613          	addi	a2,a2,156 # ffffffffc02062e0 <commands+0x450>
ffffffffc020124c:	0df00593          	li	a1,223
ffffffffc0201250:	00005517          	auipc	a0,0x5
ffffffffc0201254:	39050513          	addi	a0,a0,912 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201258:	a22ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020125c:	00005697          	auipc	a3,0x5
ffffffffc0201260:	4e468693          	addi	a3,a3,1252 # ffffffffc0206740 <commands+0x8b0>
ffffffffc0201264:	00005617          	auipc	a2,0x5
ffffffffc0201268:	07c60613          	addi	a2,a2,124 # ffffffffc02062e0 <commands+0x450>
ffffffffc020126c:	0dd00593          	li	a1,221
ffffffffc0201270:	00005517          	auipc	a0,0x5
ffffffffc0201274:	37050513          	addi	a0,a0,880 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201278:	a02ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020127c:	00005697          	auipc	a3,0x5
ffffffffc0201280:	50468693          	addi	a3,a3,1284 # ffffffffc0206780 <commands+0x8f0>
ffffffffc0201284:	00005617          	auipc	a2,0x5
ffffffffc0201288:	05c60613          	addi	a2,a2,92 # ffffffffc02062e0 <commands+0x450>
ffffffffc020128c:	0dc00593          	li	a1,220
ffffffffc0201290:	00005517          	auipc	a0,0x5
ffffffffc0201294:	35050513          	addi	a0,a0,848 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201298:	9e2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020129c:	00005697          	auipc	a3,0x5
ffffffffc02012a0:	37c68693          	addi	a3,a3,892 # ffffffffc0206618 <commands+0x788>
ffffffffc02012a4:	00005617          	auipc	a2,0x5
ffffffffc02012a8:	03c60613          	addi	a2,a2,60 # ffffffffc02062e0 <commands+0x450>
ffffffffc02012ac:	0b900593          	li	a1,185
ffffffffc02012b0:	00005517          	auipc	a0,0x5
ffffffffc02012b4:	33050513          	addi	a0,a0,816 # ffffffffc02065e0 <commands+0x750>
ffffffffc02012b8:	9c2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012bc:	00005697          	auipc	a3,0x5
ffffffffc02012c0:	48468693          	addi	a3,a3,1156 # ffffffffc0206740 <commands+0x8b0>
ffffffffc02012c4:	00005617          	auipc	a2,0x5
ffffffffc02012c8:	01c60613          	addi	a2,a2,28 # ffffffffc02062e0 <commands+0x450>
ffffffffc02012cc:	0d600593          	li	a1,214
ffffffffc02012d0:	00005517          	auipc	a0,0x5
ffffffffc02012d4:	31050513          	addi	a0,a0,784 # ffffffffc02065e0 <commands+0x750>
ffffffffc02012d8:	9a2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012dc:	00005697          	auipc	a3,0x5
ffffffffc02012e0:	37c68693          	addi	a3,a3,892 # ffffffffc0206658 <commands+0x7c8>
ffffffffc02012e4:	00005617          	auipc	a2,0x5
ffffffffc02012e8:	ffc60613          	addi	a2,a2,-4 # ffffffffc02062e0 <commands+0x450>
ffffffffc02012ec:	0d400593          	li	a1,212
ffffffffc02012f0:	00005517          	auipc	a0,0x5
ffffffffc02012f4:	2f050513          	addi	a0,a0,752 # ffffffffc02065e0 <commands+0x750>
ffffffffc02012f8:	982ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012fc:	00005697          	auipc	a3,0x5
ffffffffc0201300:	33c68693          	addi	a3,a3,828 # ffffffffc0206638 <commands+0x7a8>
ffffffffc0201304:	00005617          	auipc	a2,0x5
ffffffffc0201308:	fdc60613          	addi	a2,a2,-36 # ffffffffc02062e0 <commands+0x450>
ffffffffc020130c:	0d300593          	li	a1,211
ffffffffc0201310:	00005517          	auipc	a0,0x5
ffffffffc0201314:	2d050513          	addi	a0,a0,720 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201318:	962ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020131c:	00005697          	auipc	a3,0x5
ffffffffc0201320:	33c68693          	addi	a3,a3,828 # ffffffffc0206658 <commands+0x7c8>
ffffffffc0201324:	00005617          	auipc	a2,0x5
ffffffffc0201328:	fbc60613          	addi	a2,a2,-68 # ffffffffc02062e0 <commands+0x450>
ffffffffc020132c:	0bb00593          	li	a1,187
ffffffffc0201330:	00005517          	auipc	a0,0x5
ffffffffc0201334:	2b050513          	addi	a0,a0,688 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201338:	942ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(count == 0);
ffffffffc020133c:	00005697          	auipc	a3,0x5
ffffffffc0201340:	5c468693          	addi	a3,a3,1476 # ffffffffc0206900 <commands+0xa70>
ffffffffc0201344:	00005617          	auipc	a2,0x5
ffffffffc0201348:	f9c60613          	addi	a2,a2,-100 # ffffffffc02062e0 <commands+0x450>
ffffffffc020134c:	12500593          	li	a1,293
ffffffffc0201350:	00005517          	auipc	a0,0x5
ffffffffc0201354:	29050513          	addi	a0,a0,656 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201358:	922ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc020135c:	00005697          	auipc	a3,0x5
ffffffffc0201360:	44468693          	addi	a3,a3,1092 # ffffffffc02067a0 <commands+0x910>
ffffffffc0201364:	00005617          	auipc	a2,0x5
ffffffffc0201368:	f7c60613          	addi	a2,a2,-132 # ffffffffc02062e0 <commands+0x450>
ffffffffc020136c:	11a00593          	li	a1,282
ffffffffc0201370:	00005517          	auipc	a0,0x5
ffffffffc0201374:	27050513          	addi	a0,a0,624 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201378:	902ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020137c:	00005697          	auipc	a3,0x5
ffffffffc0201380:	3c468693          	addi	a3,a3,964 # ffffffffc0206740 <commands+0x8b0>
ffffffffc0201384:	00005617          	auipc	a2,0x5
ffffffffc0201388:	f5c60613          	addi	a2,a2,-164 # ffffffffc02062e0 <commands+0x450>
ffffffffc020138c:	11800593          	li	a1,280
ffffffffc0201390:	00005517          	auipc	a0,0x5
ffffffffc0201394:	25050513          	addi	a0,a0,592 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201398:	8e2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020139c:	00005697          	auipc	a3,0x5
ffffffffc02013a0:	36468693          	addi	a3,a3,868 # ffffffffc0206700 <commands+0x870>
ffffffffc02013a4:	00005617          	auipc	a2,0x5
ffffffffc02013a8:	f3c60613          	addi	a2,a2,-196 # ffffffffc02062e0 <commands+0x450>
ffffffffc02013ac:	0c100593          	li	a1,193
ffffffffc02013b0:	00005517          	auipc	a0,0x5
ffffffffc02013b4:	23050513          	addi	a0,a0,560 # ffffffffc02065e0 <commands+0x750>
ffffffffc02013b8:	8c2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013bc:	00005697          	auipc	a3,0x5
ffffffffc02013c0:	50468693          	addi	a3,a3,1284 # ffffffffc02068c0 <commands+0xa30>
ffffffffc02013c4:	00005617          	auipc	a2,0x5
ffffffffc02013c8:	f1c60613          	addi	a2,a2,-228 # ffffffffc02062e0 <commands+0x450>
ffffffffc02013cc:	11200593          	li	a1,274
ffffffffc02013d0:	00005517          	auipc	a0,0x5
ffffffffc02013d4:	21050513          	addi	a0,a0,528 # ffffffffc02065e0 <commands+0x750>
ffffffffc02013d8:	8a2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02013dc:	00005697          	auipc	a3,0x5
ffffffffc02013e0:	4c468693          	addi	a3,a3,1220 # ffffffffc02068a0 <commands+0xa10>
ffffffffc02013e4:	00005617          	auipc	a2,0x5
ffffffffc02013e8:	efc60613          	addi	a2,a2,-260 # ffffffffc02062e0 <commands+0x450>
ffffffffc02013ec:	11000593          	li	a1,272
ffffffffc02013f0:	00005517          	auipc	a0,0x5
ffffffffc02013f4:	1f050513          	addi	a0,a0,496 # ffffffffc02065e0 <commands+0x750>
ffffffffc02013f8:	882ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02013fc:	00005697          	auipc	a3,0x5
ffffffffc0201400:	47c68693          	addi	a3,a3,1148 # ffffffffc0206878 <commands+0x9e8>
ffffffffc0201404:	00005617          	auipc	a2,0x5
ffffffffc0201408:	edc60613          	addi	a2,a2,-292 # ffffffffc02062e0 <commands+0x450>
ffffffffc020140c:	10e00593          	li	a1,270
ffffffffc0201410:	00005517          	auipc	a0,0x5
ffffffffc0201414:	1d050513          	addi	a0,a0,464 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201418:	862ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020141c:	00005697          	auipc	a3,0x5
ffffffffc0201420:	43468693          	addi	a3,a3,1076 # ffffffffc0206850 <commands+0x9c0>
ffffffffc0201424:	00005617          	auipc	a2,0x5
ffffffffc0201428:	ebc60613          	addi	a2,a2,-324 # ffffffffc02062e0 <commands+0x450>
ffffffffc020142c:	10d00593          	li	a1,269
ffffffffc0201430:	00005517          	auipc	a0,0x5
ffffffffc0201434:	1b050513          	addi	a0,a0,432 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201438:	842ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 + 2 == p1);
ffffffffc020143c:	00005697          	auipc	a3,0x5
ffffffffc0201440:	40468693          	addi	a3,a3,1028 # ffffffffc0206840 <commands+0x9b0>
ffffffffc0201444:	00005617          	auipc	a2,0x5
ffffffffc0201448:	e9c60613          	addi	a2,a2,-356 # ffffffffc02062e0 <commands+0x450>
ffffffffc020144c:	10800593          	li	a1,264
ffffffffc0201450:	00005517          	auipc	a0,0x5
ffffffffc0201454:	19050513          	addi	a0,a0,400 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201458:	822ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020145c:	00005697          	auipc	a3,0x5
ffffffffc0201460:	2e468693          	addi	a3,a3,740 # ffffffffc0206740 <commands+0x8b0>
ffffffffc0201464:	00005617          	auipc	a2,0x5
ffffffffc0201468:	e7c60613          	addi	a2,a2,-388 # ffffffffc02062e0 <commands+0x450>
ffffffffc020146c:	10700593          	li	a1,263
ffffffffc0201470:	00005517          	auipc	a0,0x5
ffffffffc0201474:	17050513          	addi	a0,a0,368 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201478:	802ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020147c:	00005697          	auipc	a3,0x5
ffffffffc0201480:	3a468693          	addi	a3,a3,932 # ffffffffc0206820 <commands+0x990>
ffffffffc0201484:	00005617          	auipc	a2,0x5
ffffffffc0201488:	e5c60613          	addi	a2,a2,-420 # ffffffffc02062e0 <commands+0x450>
ffffffffc020148c:	10600593          	li	a1,262
ffffffffc0201490:	00005517          	auipc	a0,0x5
ffffffffc0201494:	15050513          	addi	a0,a0,336 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201498:	fe3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020149c:	00005697          	auipc	a3,0x5
ffffffffc02014a0:	35468693          	addi	a3,a3,852 # ffffffffc02067f0 <commands+0x960>
ffffffffc02014a4:	00005617          	auipc	a2,0x5
ffffffffc02014a8:	e3c60613          	addi	a2,a2,-452 # ffffffffc02062e0 <commands+0x450>
ffffffffc02014ac:	10500593          	li	a1,261
ffffffffc02014b0:	00005517          	auipc	a0,0x5
ffffffffc02014b4:	13050513          	addi	a0,a0,304 # ffffffffc02065e0 <commands+0x750>
ffffffffc02014b8:	fc3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014bc:	00005697          	auipc	a3,0x5
ffffffffc02014c0:	31c68693          	addi	a3,a3,796 # ffffffffc02067d8 <commands+0x948>
ffffffffc02014c4:	00005617          	auipc	a2,0x5
ffffffffc02014c8:	e1c60613          	addi	a2,a2,-484 # ffffffffc02062e0 <commands+0x450>
ffffffffc02014cc:	10400593          	li	a1,260
ffffffffc02014d0:	00005517          	auipc	a0,0x5
ffffffffc02014d4:	11050513          	addi	a0,a0,272 # ffffffffc02065e0 <commands+0x750>
ffffffffc02014d8:	fa3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014dc:	00005697          	auipc	a3,0x5
ffffffffc02014e0:	26468693          	addi	a3,a3,612 # ffffffffc0206740 <commands+0x8b0>
ffffffffc02014e4:	00005617          	auipc	a2,0x5
ffffffffc02014e8:	dfc60613          	addi	a2,a2,-516 # ffffffffc02062e0 <commands+0x450>
ffffffffc02014ec:	0fe00593          	li	a1,254
ffffffffc02014f0:	00005517          	auipc	a0,0x5
ffffffffc02014f4:	0f050513          	addi	a0,a0,240 # ffffffffc02065e0 <commands+0x750>
ffffffffc02014f8:	f83fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!PageProperty(p0));
ffffffffc02014fc:	00005697          	auipc	a3,0x5
ffffffffc0201500:	2c468693          	addi	a3,a3,708 # ffffffffc02067c0 <commands+0x930>
ffffffffc0201504:	00005617          	auipc	a2,0x5
ffffffffc0201508:	ddc60613          	addi	a2,a2,-548 # ffffffffc02062e0 <commands+0x450>
ffffffffc020150c:	0f900593          	li	a1,249
ffffffffc0201510:	00005517          	auipc	a0,0x5
ffffffffc0201514:	0d050513          	addi	a0,a0,208 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201518:	f63fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020151c:	00005697          	auipc	a3,0x5
ffffffffc0201520:	3c468693          	addi	a3,a3,964 # ffffffffc02068e0 <commands+0xa50>
ffffffffc0201524:	00005617          	auipc	a2,0x5
ffffffffc0201528:	dbc60613          	addi	a2,a2,-580 # ffffffffc02062e0 <commands+0x450>
ffffffffc020152c:	11700593          	li	a1,279
ffffffffc0201530:	00005517          	auipc	a0,0x5
ffffffffc0201534:	0b050513          	addi	a0,a0,176 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201538:	f43fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == 0);
ffffffffc020153c:	00005697          	auipc	a3,0x5
ffffffffc0201540:	3d468693          	addi	a3,a3,980 # ffffffffc0206910 <commands+0xa80>
ffffffffc0201544:	00005617          	auipc	a2,0x5
ffffffffc0201548:	d9c60613          	addi	a2,a2,-612 # ffffffffc02062e0 <commands+0x450>
ffffffffc020154c:	12600593          	li	a1,294
ffffffffc0201550:	00005517          	auipc	a0,0x5
ffffffffc0201554:	09050513          	addi	a0,a0,144 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201558:	f23fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == nr_free_pages());
ffffffffc020155c:	00005697          	auipc	a3,0x5
ffffffffc0201560:	09c68693          	addi	a3,a3,156 # ffffffffc02065f8 <commands+0x768>
ffffffffc0201564:	00005617          	auipc	a2,0x5
ffffffffc0201568:	d7c60613          	addi	a2,a2,-644 # ffffffffc02062e0 <commands+0x450>
ffffffffc020156c:	0f300593          	li	a1,243
ffffffffc0201570:	00005517          	auipc	a0,0x5
ffffffffc0201574:	07050513          	addi	a0,a0,112 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201578:	f03fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020157c:	00005697          	auipc	a3,0x5
ffffffffc0201580:	0bc68693          	addi	a3,a3,188 # ffffffffc0206638 <commands+0x7a8>
ffffffffc0201584:	00005617          	auipc	a2,0x5
ffffffffc0201588:	d5c60613          	addi	a2,a2,-676 # ffffffffc02062e0 <commands+0x450>
ffffffffc020158c:	0ba00593          	li	a1,186
ffffffffc0201590:	00005517          	auipc	a0,0x5
ffffffffc0201594:	05050513          	addi	a0,a0,80 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201598:	ee3fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020159c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020159c:	1141                	addi	sp,sp,-16
ffffffffc020159e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015a0:	14058463          	beqz	a1,ffffffffc02016e8 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02015a4:	00659693          	slli	a3,a1,0x6
ffffffffc02015a8:	96aa                	add	a3,a3,a0
ffffffffc02015aa:	87aa                	mv	a5,a0
ffffffffc02015ac:	02d50263          	beq	a0,a3,ffffffffc02015d0 <default_free_pages+0x34>
ffffffffc02015b0:	6798                	ld	a4,8(a5)
ffffffffc02015b2:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015b4:	10071a63          	bnez	a4,ffffffffc02016c8 <default_free_pages+0x12c>
ffffffffc02015b8:	6798                	ld	a4,8(a5)
ffffffffc02015ba:	8b09                	andi	a4,a4,2
ffffffffc02015bc:	10071663          	bnez	a4,ffffffffc02016c8 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02015c0:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02015c4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015c8:	04078793          	addi	a5,a5,64
ffffffffc02015cc:	fed792e3          	bne	a5,a3,ffffffffc02015b0 <default_free_pages+0x14>
    base->property = n;
ffffffffc02015d0:	2581                	sext.w	a1,a1
ffffffffc02015d2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015d4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015d8:	4789                	li	a5,2
ffffffffc02015da:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02015de:	000ad697          	auipc	a3,0xad
ffffffffc02015e2:	12268693          	addi	a3,a3,290 # ffffffffc02ae700 <free_area>
ffffffffc02015e6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015e8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02015ea:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02015ee:	9db9                	addw	a1,a1,a4
ffffffffc02015f0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015f2:	0ad78463          	beq	a5,a3,ffffffffc020169a <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02015f6:	fe878713          	addi	a4,a5,-24
ffffffffc02015fa:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015fe:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201600:	00e56a63          	bltu	a0,a4,ffffffffc0201614 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201604:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201606:	04d70c63          	beq	a4,a3,ffffffffc020165e <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020160a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020160c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201610:	fee57ae3          	bgeu	a0,a4,ffffffffc0201604 <default_free_pages+0x68>
ffffffffc0201614:	c199                	beqz	a1,ffffffffc020161a <default_free_pages+0x7e>
ffffffffc0201616:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020161a:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020161c:	e390                	sd	a2,0(a5)
ffffffffc020161e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201620:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201622:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201624:	00d70d63          	beq	a4,a3,ffffffffc020163e <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201628:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020162c:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201630:	02059813          	slli	a6,a1,0x20
ffffffffc0201634:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201638:	97b2                	add	a5,a5,a2
ffffffffc020163a:	02f50c63          	beq	a0,a5,ffffffffc0201672 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020163e:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201640:	00d78c63          	beq	a5,a3,ffffffffc0201658 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201644:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201646:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020164a:	02061593          	slli	a1,a2,0x20
ffffffffc020164e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201652:	972a                	add	a4,a4,a0
ffffffffc0201654:	04e68a63          	beq	a3,a4,ffffffffc02016a8 <default_free_pages+0x10c>
}
ffffffffc0201658:	60a2                	ld	ra,8(sp)
ffffffffc020165a:	0141                	addi	sp,sp,16
ffffffffc020165c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020165e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201660:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201662:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201664:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201666:	02d70763          	beq	a4,a3,ffffffffc0201694 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020166a:	8832                	mv	a6,a2
ffffffffc020166c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020166e:	87ba                	mv	a5,a4
ffffffffc0201670:	bf71                	j	ffffffffc020160c <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201672:	491c                	lw	a5,16(a0)
ffffffffc0201674:	9dbd                	addw	a1,a1,a5
ffffffffc0201676:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020167a:	57f5                	li	a5,-3
ffffffffc020167c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201680:	01853803          	ld	a6,24(a0)
ffffffffc0201684:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201686:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201688:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc020168c:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020168e:	0105b023          	sd	a6,0(a1)
ffffffffc0201692:	b77d                	j	ffffffffc0201640 <default_free_pages+0xa4>
ffffffffc0201694:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201696:	873e                	mv	a4,a5
ffffffffc0201698:	bf41                	j	ffffffffc0201628 <default_free_pages+0x8c>
}
ffffffffc020169a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020169c:	e390                	sd	a2,0(a5)
ffffffffc020169e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016a0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016a2:	ed1c                	sd	a5,24(a0)
ffffffffc02016a4:	0141                	addi	sp,sp,16
ffffffffc02016a6:	8082                	ret
            base->property += p->property;
ffffffffc02016a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016ac:	ff078693          	addi	a3,a5,-16
ffffffffc02016b0:	9e39                	addw	a2,a2,a4
ffffffffc02016b2:	c910                	sw	a2,16(a0)
ffffffffc02016b4:	5775                	li	a4,-3
ffffffffc02016b6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016ba:	6398                	ld	a4,0(a5)
ffffffffc02016bc:	679c                	ld	a5,8(a5)
}
ffffffffc02016be:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016c0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02016c2:	e398                	sd	a4,0(a5)
ffffffffc02016c4:	0141                	addi	sp,sp,16
ffffffffc02016c6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016c8:	00005697          	auipc	a3,0x5
ffffffffc02016cc:	26068693          	addi	a3,a3,608 # ffffffffc0206928 <commands+0xa98>
ffffffffc02016d0:	00005617          	auipc	a2,0x5
ffffffffc02016d4:	c1060613          	addi	a2,a2,-1008 # ffffffffc02062e0 <commands+0x450>
ffffffffc02016d8:	08300593          	li	a1,131
ffffffffc02016dc:	00005517          	auipc	a0,0x5
ffffffffc02016e0:	f0450513          	addi	a0,a0,-252 # ffffffffc02065e0 <commands+0x750>
ffffffffc02016e4:	d97fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc02016e8:	00005697          	auipc	a3,0x5
ffffffffc02016ec:	23868693          	addi	a3,a3,568 # ffffffffc0206920 <commands+0xa90>
ffffffffc02016f0:	00005617          	auipc	a2,0x5
ffffffffc02016f4:	bf060613          	addi	a2,a2,-1040 # ffffffffc02062e0 <commands+0x450>
ffffffffc02016f8:	08000593          	li	a1,128
ffffffffc02016fc:	00005517          	auipc	a0,0x5
ffffffffc0201700:	ee450513          	addi	a0,a0,-284 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201704:	d77fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201708 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201708:	c941                	beqz	a0,ffffffffc0201798 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020170a:	000ad597          	auipc	a1,0xad
ffffffffc020170e:	ff658593          	addi	a1,a1,-10 # ffffffffc02ae700 <free_area>
ffffffffc0201712:	0105a803          	lw	a6,16(a1)
ffffffffc0201716:	872a                	mv	a4,a0
ffffffffc0201718:	02081793          	slli	a5,a6,0x20
ffffffffc020171c:	9381                	srli	a5,a5,0x20
ffffffffc020171e:	00a7ee63          	bltu	a5,a0,ffffffffc020173a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201722:	87ae                	mv	a5,a1
ffffffffc0201724:	a801                	j	ffffffffc0201734 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201726:	ff87a683          	lw	a3,-8(a5)
ffffffffc020172a:	02069613          	slli	a2,a3,0x20
ffffffffc020172e:	9201                	srli	a2,a2,0x20
ffffffffc0201730:	00e67763          	bgeu	a2,a4,ffffffffc020173e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201734:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201736:	feb798e3          	bne	a5,a1,ffffffffc0201726 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020173a:	4501                	li	a0,0
}
ffffffffc020173c:	8082                	ret
    return listelm->prev;
ffffffffc020173e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201742:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201746:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020174a:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc020174e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201752:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201756:	02c77863          	bgeu	a4,a2,ffffffffc0201786 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020175a:	071a                	slli	a4,a4,0x6
ffffffffc020175c:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020175e:	41c686bb          	subw	a3,a3,t3
ffffffffc0201762:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201764:	00870613          	addi	a2,a4,8
ffffffffc0201768:	4689                	li	a3,2
ffffffffc020176a:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020176e:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201772:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201776:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020177a:	e290                	sd	a2,0(a3)
ffffffffc020177c:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201780:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201782:	01173c23          	sd	a7,24(a4)
ffffffffc0201786:	41c8083b          	subw	a6,a6,t3
ffffffffc020178a:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020178e:	5775                	li	a4,-3
ffffffffc0201790:	17c1                	addi	a5,a5,-16
ffffffffc0201792:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201796:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201798:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020179a:	00005697          	auipc	a3,0x5
ffffffffc020179e:	18668693          	addi	a3,a3,390 # ffffffffc0206920 <commands+0xa90>
ffffffffc02017a2:	00005617          	auipc	a2,0x5
ffffffffc02017a6:	b3e60613          	addi	a2,a2,-1218 # ffffffffc02062e0 <commands+0x450>
ffffffffc02017aa:	06200593          	li	a1,98
ffffffffc02017ae:	00005517          	auipc	a0,0x5
ffffffffc02017b2:	e3250513          	addi	a0,a0,-462 # ffffffffc02065e0 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc02017b6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017b8:	cc3fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02017bc <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017bc:	1141                	addi	sp,sp,-16
ffffffffc02017be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017c0:	c5f1                	beqz	a1,ffffffffc020188c <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02017c2:	00659693          	slli	a3,a1,0x6
ffffffffc02017c6:	96aa                	add	a3,a3,a0
ffffffffc02017c8:	87aa                	mv	a5,a0
ffffffffc02017ca:	00d50f63          	beq	a0,a3,ffffffffc02017e8 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017ce:	6798                	ld	a4,8(a5)
ffffffffc02017d0:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02017d2:	cf49                	beqz	a4,ffffffffc020186c <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017d4:	0007a823          	sw	zero,16(a5)
ffffffffc02017d8:	0007b423          	sd	zero,8(a5)
ffffffffc02017dc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02017e0:	04078793          	addi	a5,a5,64
ffffffffc02017e4:	fed795e3          	bne	a5,a3,ffffffffc02017ce <default_init_memmap+0x12>
    base->property = n;
ffffffffc02017e8:	2581                	sext.w	a1,a1
ffffffffc02017ea:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017ec:	4789                	li	a5,2
ffffffffc02017ee:	00850713          	addi	a4,a0,8
ffffffffc02017f2:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02017f6:	000ad697          	auipc	a3,0xad
ffffffffc02017fa:	f0a68693          	addi	a3,a3,-246 # ffffffffc02ae700 <free_area>
ffffffffc02017fe:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201800:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201802:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201806:	9db9                	addw	a1,a1,a4
ffffffffc0201808:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020180a:	04d78a63          	beq	a5,a3,ffffffffc020185e <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc020180e:	fe878713          	addi	a4,a5,-24
ffffffffc0201812:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201816:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201818:	00e56a63          	bltu	a0,a4,ffffffffc020182c <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020181c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020181e:	02d70263          	beq	a4,a3,ffffffffc0201842 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0201822:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201824:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201828:	fee57ae3          	bgeu	a0,a4,ffffffffc020181c <default_init_memmap+0x60>
ffffffffc020182c:	c199                	beqz	a1,ffffffffc0201832 <default_init_memmap+0x76>
ffffffffc020182e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201832:	6398                	ld	a4,0(a5)
}
ffffffffc0201834:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201836:	e390                	sd	a2,0(a5)
ffffffffc0201838:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020183a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020183c:	ed18                	sd	a4,24(a0)
ffffffffc020183e:	0141                	addi	sp,sp,16
ffffffffc0201840:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201842:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201844:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201846:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201848:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020184a:	00d70663          	beq	a4,a3,ffffffffc0201856 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020184e:	8832                	mv	a6,a2
ffffffffc0201850:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201852:	87ba                	mv	a5,a4
ffffffffc0201854:	bfc1                	j	ffffffffc0201824 <default_init_memmap+0x68>
}
ffffffffc0201856:	60a2                	ld	ra,8(sp)
ffffffffc0201858:	e290                	sd	a2,0(a3)
ffffffffc020185a:	0141                	addi	sp,sp,16
ffffffffc020185c:	8082                	ret
ffffffffc020185e:	60a2                	ld	ra,8(sp)
ffffffffc0201860:	e390                	sd	a2,0(a5)
ffffffffc0201862:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201864:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201866:	ed1c                	sd	a5,24(a0)
ffffffffc0201868:	0141                	addi	sp,sp,16
ffffffffc020186a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020186c:	00005697          	auipc	a3,0x5
ffffffffc0201870:	0e468693          	addi	a3,a3,228 # ffffffffc0206950 <commands+0xac0>
ffffffffc0201874:	00005617          	auipc	a2,0x5
ffffffffc0201878:	a6c60613          	addi	a2,a2,-1428 # ffffffffc02062e0 <commands+0x450>
ffffffffc020187c:	04900593          	li	a1,73
ffffffffc0201880:	00005517          	auipc	a0,0x5
ffffffffc0201884:	d6050513          	addi	a0,a0,-672 # ffffffffc02065e0 <commands+0x750>
ffffffffc0201888:	bf3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc020188c:	00005697          	auipc	a3,0x5
ffffffffc0201890:	09468693          	addi	a3,a3,148 # ffffffffc0206920 <commands+0xa90>
ffffffffc0201894:	00005617          	auipc	a2,0x5
ffffffffc0201898:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02062e0 <commands+0x450>
ffffffffc020189c:	04600593          	li	a1,70
ffffffffc02018a0:	00005517          	auipc	a0,0x5
ffffffffc02018a4:	d4050513          	addi	a0,a0,-704 # ffffffffc02065e0 <commands+0x750>
ffffffffc02018a8:	bd3fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02018ac <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02018ac:	c94d                	beqz	a0,ffffffffc020195e <slob_free+0xb2>
{
ffffffffc02018ae:	1141                	addi	sp,sp,-16
ffffffffc02018b0:	e022                	sd	s0,0(sp)
ffffffffc02018b2:	e406                	sd	ra,8(sp)
ffffffffc02018b4:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02018b6:	e9c1                	bnez	a1,ffffffffc0201946 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018b8:	100027f3          	csrr	a5,sstatus
ffffffffc02018bc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018be:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018c0:	ebd9                	bnez	a5,ffffffffc0201956 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018c2:	000a6617          	auipc	a2,0xa6
ffffffffc02018c6:	a3660613          	addi	a2,a2,-1482 # ffffffffc02a72f8 <slobfree>
ffffffffc02018ca:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018cc:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018ce:	679c                	ld	a5,8(a5)
ffffffffc02018d0:	02877a63          	bgeu	a4,s0,ffffffffc0201904 <slob_free+0x58>
ffffffffc02018d4:	00f46463          	bltu	s0,a5,ffffffffc02018dc <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018d8:	fef76ae3          	bltu	a4,a5,ffffffffc02018cc <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc02018dc:	400c                	lw	a1,0(s0)
ffffffffc02018de:	00459693          	slli	a3,a1,0x4
ffffffffc02018e2:	96a2                	add	a3,a3,s0
ffffffffc02018e4:	02d78a63          	beq	a5,a3,ffffffffc0201918 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02018e8:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02018ea:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02018ec:	00469793          	slli	a5,a3,0x4
ffffffffc02018f0:	97ba                	add	a5,a5,a4
ffffffffc02018f2:	02f40e63          	beq	s0,a5,ffffffffc020192e <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02018f6:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02018f8:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02018fa:	e129                	bnez	a0,ffffffffc020193c <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02018fc:	60a2                	ld	ra,8(sp)
ffffffffc02018fe:	6402                	ld	s0,0(sp)
ffffffffc0201900:	0141                	addi	sp,sp,16
ffffffffc0201902:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201904:	fcf764e3          	bltu	a4,a5,ffffffffc02018cc <slob_free+0x20>
ffffffffc0201908:	fcf472e3          	bgeu	s0,a5,ffffffffc02018cc <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc020190c:	400c                	lw	a1,0(s0)
ffffffffc020190e:	00459693          	slli	a3,a1,0x4
ffffffffc0201912:	96a2                	add	a3,a3,s0
ffffffffc0201914:	fcd79ae3          	bne	a5,a3,ffffffffc02018e8 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201918:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020191a:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020191c:	9db5                	addw	a1,a1,a3
ffffffffc020191e:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201920:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201922:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201924:	00469793          	slli	a5,a3,0x4
ffffffffc0201928:	97ba                	add	a5,a5,a4
ffffffffc020192a:	fcf416e3          	bne	s0,a5,ffffffffc02018f6 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020192e:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201930:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201932:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201934:	9ebd                	addw	a3,a3,a5
ffffffffc0201936:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201938:	e70c                	sd	a1,8(a4)
ffffffffc020193a:	d169                	beqz	a0,ffffffffc02018fc <slob_free+0x50>
}
ffffffffc020193c:	6402                	ld	s0,0(sp)
ffffffffc020193e:	60a2                	ld	ra,8(sp)
ffffffffc0201940:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201942:	cdbfe06f          	j	ffffffffc020061c <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201946:	25bd                	addiw	a1,a1,15
ffffffffc0201948:	8191                	srli	a1,a1,0x4
ffffffffc020194a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020194c:	100027f3          	csrr	a5,sstatus
ffffffffc0201950:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201952:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201954:	d7bd                	beqz	a5,ffffffffc02018c2 <slob_free+0x16>
        intr_disable();
ffffffffc0201956:	ccdfe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc020195a:	4505                	li	a0,1
ffffffffc020195c:	b79d                	j	ffffffffc02018c2 <slob_free+0x16>
ffffffffc020195e:	8082                	ret

ffffffffc0201960 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201960:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201962:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201964:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201968:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020196a:	352000ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
  if(!page)
ffffffffc020196e:	c91d                	beqz	a0,ffffffffc02019a4 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201970:	000b1697          	auipc	a3,0xb1
ffffffffc0201974:	e906b683          	ld	a3,-368(a3) # ffffffffc02b2800 <pages>
ffffffffc0201978:	8d15                	sub	a0,a0,a3
ffffffffc020197a:	8519                	srai	a0,a0,0x6
ffffffffc020197c:	00007697          	auipc	a3,0x7
ffffffffc0201980:	8946b683          	ld	a3,-1900(a3) # ffffffffc0208210 <nbase>
ffffffffc0201984:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201986:	00c51793          	slli	a5,a0,0xc
ffffffffc020198a:	83b1                	srli	a5,a5,0xc
ffffffffc020198c:	000b1717          	auipc	a4,0xb1
ffffffffc0201990:	e6c73703          	ld	a4,-404(a4) # ffffffffc02b27f8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201994:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201996:	00e7fa63          	bgeu	a5,a4,ffffffffc02019aa <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020199a:	000b1697          	auipc	a3,0xb1
ffffffffc020199e:	e766b683          	ld	a3,-394(a3) # ffffffffc02b2810 <va_pa_offset>
ffffffffc02019a2:	9536                	add	a0,a0,a3
}
ffffffffc02019a4:	60a2                	ld	ra,8(sp)
ffffffffc02019a6:	0141                	addi	sp,sp,16
ffffffffc02019a8:	8082                	ret
ffffffffc02019aa:	86aa                	mv	a3,a0
ffffffffc02019ac:	00005617          	auipc	a2,0x5
ffffffffc02019b0:	00460613          	addi	a2,a2,4 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc02019b4:	06900593          	li	a1,105
ffffffffc02019b8:	00005517          	auipc	a0,0x5
ffffffffc02019bc:	02050513          	addi	a0,a0,32 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc02019c0:	abbfe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02019c4 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019c4:	1101                	addi	sp,sp,-32
ffffffffc02019c6:	ec06                	sd	ra,24(sp)
ffffffffc02019c8:	e822                	sd	s0,16(sp)
ffffffffc02019ca:	e426                	sd	s1,8(sp)
ffffffffc02019cc:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019ce:	01050713          	addi	a4,a0,16
ffffffffc02019d2:	6785                	lui	a5,0x1
ffffffffc02019d4:	0cf77363          	bgeu	a4,a5,ffffffffc0201a9a <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019d8:	00f50493          	addi	s1,a0,15
ffffffffc02019dc:	8091                	srli	s1,s1,0x4
ffffffffc02019de:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019e0:	10002673          	csrr	a2,sstatus
ffffffffc02019e4:	8a09                	andi	a2,a2,2
ffffffffc02019e6:	e25d                	bnez	a2,ffffffffc0201a8c <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02019e8:	000a6917          	auipc	s2,0xa6
ffffffffc02019ec:	91090913          	addi	s2,s2,-1776 # ffffffffc02a72f8 <slobfree>
ffffffffc02019f0:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02019f4:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019f6:	4398                	lw	a4,0(a5)
ffffffffc02019f8:	08975e63          	bge	a4,s1,ffffffffc0201a94 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02019fc:	00f68b63          	beq	a3,a5,ffffffffc0201a12 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a00:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a02:	4018                	lw	a4,0(s0)
ffffffffc0201a04:	02975a63          	bge	a4,s1,ffffffffc0201a38 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201a08:	00093683          	ld	a3,0(s2)
ffffffffc0201a0c:	87a2                	mv	a5,s0
ffffffffc0201a0e:	fef699e3          	bne	a3,a5,ffffffffc0201a00 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201a12:	ee31                	bnez	a2,ffffffffc0201a6e <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a14:	4501                	li	a0,0
ffffffffc0201a16:	f4bff0ef          	jal	ra,ffffffffc0201960 <__slob_get_free_pages.constprop.0>
ffffffffc0201a1a:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a1c:	cd05                	beqz	a0,ffffffffc0201a54 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a1e:	6585                	lui	a1,0x1
ffffffffc0201a20:	e8dff0ef          	jal	ra,ffffffffc02018ac <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a24:	10002673          	csrr	a2,sstatus
ffffffffc0201a28:	8a09                	andi	a2,a2,2
ffffffffc0201a2a:	ee05                	bnez	a2,ffffffffc0201a62 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a2c:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a30:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a32:	4018                	lw	a4,0(s0)
ffffffffc0201a34:	fc974ae3          	blt	a4,s1,ffffffffc0201a08 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a38:	04e48763          	beq	s1,a4,ffffffffc0201a86 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a3c:	00449693          	slli	a3,s1,0x4
ffffffffc0201a40:	96a2                	add	a3,a3,s0
ffffffffc0201a42:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a44:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a46:	9f05                	subw	a4,a4,s1
ffffffffc0201a48:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a4a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a4c:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a4e:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a52:	e20d                	bnez	a2,ffffffffc0201a74 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a54:	60e2                	ld	ra,24(sp)
ffffffffc0201a56:	8522                	mv	a0,s0
ffffffffc0201a58:	6442                	ld	s0,16(sp)
ffffffffc0201a5a:	64a2                	ld	s1,8(sp)
ffffffffc0201a5c:	6902                	ld	s2,0(sp)
ffffffffc0201a5e:	6105                	addi	sp,sp,32
ffffffffc0201a60:	8082                	ret
        intr_disable();
ffffffffc0201a62:	bc1fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
			cur = slobfree;
ffffffffc0201a66:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a6a:	4605                	li	a2,1
ffffffffc0201a6c:	b7d1                	j	ffffffffc0201a30 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a6e:	baffe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0201a72:	b74d                	j	ffffffffc0201a14 <slob_alloc.constprop.0+0x50>
ffffffffc0201a74:	ba9fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
}
ffffffffc0201a78:	60e2                	ld	ra,24(sp)
ffffffffc0201a7a:	8522                	mv	a0,s0
ffffffffc0201a7c:	6442                	ld	s0,16(sp)
ffffffffc0201a7e:	64a2                	ld	s1,8(sp)
ffffffffc0201a80:	6902                	ld	s2,0(sp)
ffffffffc0201a82:	6105                	addi	sp,sp,32
ffffffffc0201a84:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201a86:	6418                	ld	a4,8(s0)
ffffffffc0201a88:	e798                	sd	a4,8(a5)
ffffffffc0201a8a:	b7d1                	j	ffffffffc0201a4e <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201a8c:	b97fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc0201a90:	4605                	li	a2,1
ffffffffc0201a92:	bf99                	j	ffffffffc02019e8 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a94:	843e                	mv	s0,a5
ffffffffc0201a96:	87b6                	mv	a5,a3
ffffffffc0201a98:	b745                	j	ffffffffc0201a38 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201a9a:	00005697          	auipc	a3,0x5
ffffffffc0201a9e:	f4e68693          	addi	a3,a3,-178 # ffffffffc02069e8 <default_pmm_manager+0x70>
ffffffffc0201aa2:	00005617          	auipc	a2,0x5
ffffffffc0201aa6:	83e60613          	addi	a2,a2,-1986 # ffffffffc02062e0 <commands+0x450>
ffffffffc0201aaa:	06400593          	li	a1,100
ffffffffc0201aae:	00005517          	auipc	a0,0x5
ffffffffc0201ab2:	f5a50513          	addi	a0,a0,-166 # ffffffffc0206a08 <default_pmm_manager+0x90>
ffffffffc0201ab6:	9c5fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201aba <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201aba:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201abc:	00005517          	auipc	a0,0x5
ffffffffc0201ac0:	f6450513          	addi	a0,a0,-156 # ffffffffc0206a20 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201ac4:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201ac6:	ebafe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201aca:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201acc:	00005517          	auipc	a0,0x5
ffffffffc0201ad0:	f6c50513          	addi	a0,a0,-148 # ffffffffc0206a38 <default_pmm_manager+0xc0>
}
ffffffffc0201ad4:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ad6:	eaafe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201ada <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201ada:	4501                	li	a0,0
ffffffffc0201adc:	8082                	ret

ffffffffc0201ade <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201ade:	1101                	addi	sp,sp,-32
ffffffffc0201ae0:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ae2:	6905                	lui	s2,0x1
{
ffffffffc0201ae4:	e822                	sd	s0,16(sp)
ffffffffc0201ae6:	ec06                	sd	ra,24(sp)
ffffffffc0201ae8:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201aea:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc1>
{
ffffffffc0201aee:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201af0:	04a7f963          	bgeu	a5,a0,ffffffffc0201b42 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201af4:	4561                	li	a0,24
ffffffffc0201af6:	ecfff0ef          	jal	ra,ffffffffc02019c4 <slob_alloc.constprop.0>
ffffffffc0201afa:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201afc:	c929                	beqz	a0,ffffffffc0201b4e <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201afe:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b02:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b04:	00f95763          	bge	s2,a5,ffffffffc0201b12 <kmalloc+0x34>
ffffffffc0201b08:	6705                	lui	a4,0x1
ffffffffc0201b0a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b0c:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b0e:	fef74ee3          	blt	a4,a5,ffffffffc0201b0a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b12:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b14:	e4dff0ef          	jal	ra,ffffffffc0201960 <__slob_get_free_pages.constprop.0>
ffffffffc0201b18:	e488                	sd	a0,8(s1)
ffffffffc0201b1a:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201b1c:	c525                	beqz	a0,ffffffffc0201b84 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b1e:	100027f3          	csrr	a5,sstatus
ffffffffc0201b22:	8b89                	andi	a5,a5,2
ffffffffc0201b24:	ef8d                	bnez	a5,ffffffffc0201b5e <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b26:	000b1797          	auipc	a5,0xb1
ffffffffc0201b2a:	cba78793          	addi	a5,a5,-838 # ffffffffc02b27e0 <bigblocks>
ffffffffc0201b2e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b30:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b32:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201b34:	60e2                	ld	ra,24(sp)
ffffffffc0201b36:	8522                	mv	a0,s0
ffffffffc0201b38:	6442                	ld	s0,16(sp)
ffffffffc0201b3a:	64a2                	ld	s1,8(sp)
ffffffffc0201b3c:	6902                	ld	s2,0(sp)
ffffffffc0201b3e:	6105                	addi	sp,sp,32
ffffffffc0201b40:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b42:	0541                	addi	a0,a0,16
ffffffffc0201b44:	e81ff0ef          	jal	ra,ffffffffc02019c4 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b48:	01050413          	addi	s0,a0,16
ffffffffc0201b4c:	f565                	bnez	a0,ffffffffc0201b34 <kmalloc+0x56>
ffffffffc0201b4e:	4401                	li	s0,0
}
ffffffffc0201b50:	60e2                	ld	ra,24(sp)
ffffffffc0201b52:	8522                	mv	a0,s0
ffffffffc0201b54:	6442                	ld	s0,16(sp)
ffffffffc0201b56:	64a2                	ld	s1,8(sp)
ffffffffc0201b58:	6902                	ld	s2,0(sp)
ffffffffc0201b5a:	6105                	addi	sp,sp,32
ffffffffc0201b5c:	8082                	ret
        intr_disable();
ffffffffc0201b5e:	ac5fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b62:	000b1797          	auipc	a5,0xb1
ffffffffc0201b66:	c7e78793          	addi	a5,a5,-898 # ffffffffc02b27e0 <bigblocks>
ffffffffc0201b6a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b6c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b6e:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b70:	aadfe0ef          	jal	ra,ffffffffc020061c <intr_enable>
		return bb->pages;
ffffffffc0201b74:	6480                	ld	s0,8(s1)
}
ffffffffc0201b76:	60e2                	ld	ra,24(sp)
ffffffffc0201b78:	64a2                	ld	s1,8(sp)
ffffffffc0201b7a:	8522                	mv	a0,s0
ffffffffc0201b7c:	6442                	ld	s0,16(sp)
ffffffffc0201b7e:	6902                	ld	s2,0(sp)
ffffffffc0201b80:	6105                	addi	sp,sp,32
ffffffffc0201b82:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b84:	45e1                	li	a1,24
ffffffffc0201b86:	8526                	mv	a0,s1
ffffffffc0201b88:	d25ff0ef          	jal	ra,ffffffffc02018ac <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201b8c:	b765                	j	ffffffffc0201b34 <kmalloc+0x56>

ffffffffc0201b8e <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201b8e:	c169                	beqz	a0,ffffffffc0201c50 <kfree+0xc2>
{
ffffffffc0201b90:	1101                	addi	sp,sp,-32
ffffffffc0201b92:	e822                	sd	s0,16(sp)
ffffffffc0201b94:	ec06                	sd	ra,24(sp)
ffffffffc0201b96:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201b98:	03451793          	slli	a5,a0,0x34
ffffffffc0201b9c:	842a                	mv	s0,a0
ffffffffc0201b9e:	e3d9                	bnez	a5,ffffffffc0201c24 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ba0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ba4:	8b89                	andi	a5,a5,2
ffffffffc0201ba6:	e7d9                	bnez	a5,ffffffffc0201c34 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ba8:	000b1797          	auipc	a5,0xb1
ffffffffc0201bac:	c387b783          	ld	a5,-968(a5) # ffffffffc02b27e0 <bigblocks>
    return 0;
ffffffffc0201bb0:	4601                	li	a2,0
ffffffffc0201bb2:	cbad                	beqz	a5,ffffffffc0201c24 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201bb4:	000b1697          	auipc	a3,0xb1
ffffffffc0201bb8:	c2c68693          	addi	a3,a3,-980 # ffffffffc02b27e0 <bigblocks>
ffffffffc0201bbc:	a021                	j	ffffffffc0201bc4 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201bbe:	01048693          	addi	a3,s1,16
ffffffffc0201bc2:	c3a5                	beqz	a5,ffffffffc0201c22 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201bc4:	6798                	ld	a4,8(a5)
ffffffffc0201bc6:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201bc8:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201bca:	fe871ae3          	bne	a4,s0,ffffffffc0201bbe <kfree+0x30>
				*last = bb->next;
ffffffffc0201bce:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201bd0:	ee2d                	bnez	a2,ffffffffc0201c4a <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201bd2:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201bd6:	4098                	lw	a4,0(s1)
ffffffffc0201bd8:	08f46963          	bltu	s0,a5,ffffffffc0201c6a <kfree+0xdc>
ffffffffc0201bdc:	000b1697          	auipc	a3,0xb1
ffffffffc0201be0:	c346b683          	ld	a3,-972(a3) # ffffffffc02b2810 <va_pa_offset>
ffffffffc0201be4:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201be6:	8031                	srli	s0,s0,0xc
ffffffffc0201be8:	000b1797          	auipc	a5,0xb1
ffffffffc0201bec:	c107b783          	ld	a5,-1008(a5) # ffffffffc02b27f8 <npage>
ffffffffc0201bf0:	06f47163          	bgeu	s0,a5,ffffffffc0201c52 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bf4:	00006517          	auipc	a0,0x6
ffffffffc0201bf8:	61c53503          	ld	a0,1564(a0) # ffffffffc0208210 <nbase>
ffffffffc0201bfc:	8c09                	sub	s0,s0,a0
ffffffffc0201bfe:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201c00:	000b1517          	auipc	a0,0xb1
ffffffffc0201c04:	c0053503          	ld	a0,-1024(a0) # ffffffffc02b2800 <pages>
ffffffffc0201c08:	4585                	li	a1,1
ffffffffc0201c0a:	9522                	add	a0,a0,s0
ffffffffc0201c0c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c10:	13e000ef          	jal	ra,ffffffffc0201d4e <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c14:	6442                	ld	s0,16(sp)
ffffffffc0201c16:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c18:	8526                	mv	a0,s1
}
ffffffffc0201c1a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c1c:	45e1                	li	a1,24
}
ffffffffc0201c1e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c20:	b171                	j	ffffffffc02018ac <slob_free>
ffffffffc0201c22:	e20d                	bnez	a2,ffffffffc0201c44 <kfree+0xb6>
ffffffffc0201c24:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c28:	6442                	ld	s0,16(sp)
ffffffffc0201c2a:	60e2                	ld	ra,24(sp)
ffffffffc0201c2c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c2e:	4581                	li	a1,0
}
ffffffffc0201c30:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c32:	b9ad                	j	ffffffffc02018ac <slob_free>
        intr_disable();
ffffffffc0201c34:	9effe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c38:	000b1797          	auipc	a5,0xb1
ffffffffc0201c3c:	ba87b783          	ld	a5,-1112(a5) # ffffffffc02b27e0 <bigblocks>
        return 1;
ffffffffc0201c40:	4605                	li	a2,1
ffffffffc0201c42:	fbad                	bnez	a5,ffffffffc0201bb4 <kfree+0x26>
        intr_enable();
ffffffffc0201c44:	9d9fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0201c48:	bff1                	j	ffffffffc0201c24 <kfree+0x96>
ffffffffc0201c4a:	9d3fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0201c4e:	b751                	j	ffffffffc0201bd2 <kfree+0x44>
ffffffffc0201c50:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c52:	00005617          	auipc	a2,0x5
ffffffffc0201c56:	e2e60613          	addi	a2,a2,-466 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc0201c5a:	06200593          	li	a1,98
ffffffffc0201c5e:	00005517          	auipc	a0,0x5
ffffffffc0201c62:	d7a50513          	addi	a0,a0,-646 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0201c66:	815fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c6a:	86a2                	mv	a3,s0
ffffffffc0201c6c:	00005617          	auipc	a2,0x5
ffffffffc0201c70:	dec60613          	addi	a2,a2,-532 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0201c74:	06e00593          	li	a1,110
ffffffffc0201c78:	00005517          	auipc	a0,0x5
ffffffffc0201c7c:	d6050513          	addi	a0,a0,-672 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0201c80:	ffafe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201c84 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201c84:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201c86:	00005617          	auipc	a2,0x5
ffffffffc0201c8a:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc0201c8e:	06200593          	li	a1,98
ffffffffc0201c92:	00005517          	auipc	a0,0x5
ffffffffc0201c96:	d4650513          	addi	a0,a0,-698 # ffffffffc02069d8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201c9a:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201c9c:	fdefe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ca0 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201ca0:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201ca2:	00005617          	auipc	a2,0x5
ffffffffc0201ca6:	dfe60613          	addi	a2,a2,-514 # ffffffffc0206aa0 <default_pmm_manager+0x128>
ffffffffc0201caa:	07400593          	li	a1,116
ffffffffc0201cae:	00005517          	auipc	a0,0x5
ffffffffc0201cb2:	d2a50513          	addi	a0,a0,-726 # ffffffffc02069d8 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201cb6:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201cb8:	fc2fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201cbc <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201cbc:	7139                	addi	sp,sp,-64
ffffffffc0201cbe:	f426                	sd	s1,40(sp)
ffffffffc0201cc0:	f04a                	sd	s2,32(sp)
ffffffffc0201cc2:	ec4e                	sd	s3,24(sp)
ffffffffc0201cc4:	e852                	sd	s4,16(sp)
ffffffffc0201cc6:	e456                	sd	s5,8(sp)
ffffffffc0201cc8:	e05a                	sd	s6,0(sp)
ffffffffc0201cca:	fc06                	sd	ra,56(sp)
ffffffffc0201ccc:	f822                	sd	s0,48(sp)
ffffffffc0201cce:	84aa                	mv	s1,a0
ffffffffc0201cd0:	000b1917          	auipc	s2,0xb1
ffffffffc0201cd4:	b3890913          	addi	s2,s2,-1224 # ffffffffc02b2808 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cd8:	4a05                	li	s4,1
ffffffffc0201cda:	000b1a97          	auipc	s5,0xb1
ffffffffc0201cde:	b4ea8a93          	addi	s5,s5,-1202 # ffffffffc02b2828 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ce2:	0005099b          	sext.w	s3,a0
ffffffffc0201ce6:	000b1b17          	auipc	s6,0xb1
ffffffffc0201cea:	b4ab0b13          	addi	s6,s6,-1206 # ffffffffc02b2830 <check_mm_struct>
ffffffffc0201cee:	a01d                	j	ffffffffc0201d14 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201cf0:	00093783          	ld	a5,0(s2)
ffffffffc0201cf4:	6f9c                	ld	a5,24(a5)
ffffffffc0201cf6:	9782                	jalr	a5
ffffffffc0201cf8:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cfa:	4601                	li	a2,0
ffffffffc0201cfc:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cfe:	ec0d                	bnez	s0,ffffffffc0201d38 <alloc_pages+0x7c>
ffffffffc0201d00:	029a6c63          	bltu	s4,s1,ffffffffc0201d38 <alloc_pages+0x7c>
ffffffffc0201d04:	000aa783          	lw	a5,0(s5)
ffffffffc0201d08:	2781                	sext.w	a5,a5
ffffffffc0201d0a:	c79d                	beqz	a5,ffffffffc0201d38 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d0c:	000b3503          	ld	a0,0(s6)
ffffffffc0201d10:	41d010ef          	jal	ra,ffffffffc020392c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d14:	100027f3          	csrr	a5,sstatus
ffffffffc0201d18:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d1a:	8526                	mv	a0,s1
ffffffffc0201d1c:	dbf1                	beqz	a5,ffffffffc0201cf0 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201d1e:	905fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0201d22:	00093783          	ld	a5,0(s2)
ffffffffc0201d26:	8526                	mv	a0,s1
ffffffffc0201d28:	6f9c                	ld	a5,24(a5)
ffffffffc0201d2a:	9782                	jalr	a5
ffffffffc0201d2c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d2e:	8effe0ef          	jal	ra,ffffffffc020061c <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d32:	4601                	li	a2,0
ffffffffc0201d34:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d36:	d469                	beqz	s0,ffffffffc0201d00 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d38:	70e2                	ld	ra,56(sp)
ffffffffc0201d3a:	8522                	mv	a0,s0
ffffffffc0201d3c:	7442                	ld	s0,48(sp)
ffffffffc0201d3e:	74a2                	ld	s1,40(sp)
ffffffffc0201d40:	7902                	ld	s2,32(sp)
ffffffffc0201d42:	69e2                	ld	s3,24(sp)
ffffffffc0201d44:	6a42                	ld	s4,16(sp)
ffffffffc0201d46:	6aa2                	ld	s5,8(sp)
ffffffffc0201d48:	6b02                	ld	s6,0(sp)
ffffffffc0201d4a:	6121                	addi	sp,sp,64
ffffffffc0201d4c:	8082                	ret

ffffffffc0201d4e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d4e:	100027f3          	csrr	a5,sstatus
ffffffffc0201d52:	8b89                	andi	a5,a5,2
ffffffffc0201d54:	e799                	bnez	a5,ffffffffc0201d62 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d56:	000b1797          	auipc	a5,0xb1
ffffffffc0201d5a:	ab27b783          	ld	a5,-1358(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc0201d5e:	739c                	ld	a5,32(a5)
ffffffffc0201d60:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201d62:	1101                	addi	sp,sp,-32
ffffffffc0201d64:	ec06                	sd	ra,24(sp)
ffffffffc0201d66:	e822                	sd	s0,16(sp)
ffffffffc0201d68:	e426                	sd	s1,8(sp)
ffffffffc0201d6a:	842a                	mv	s0,a0
ffffffffc0201d6c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d6e:	8b5fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d72:	000b1797          	auipc	a5,0xb1
ffffffffc0201d76:	a967b783          	ld	a5,-1386(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc0201d7a:	739c                	ld	a5,32(a5)
ffffffffc0201d7c:	85a6                	mv	a1,s1
ffffffffc0201d7e:	8522                	mv	a0,s0
ffffffffc0201d80:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201d82:	6442                	ld	s0,16(sp)
ffffffffc0201d84:	60e2                	ld	ra,24(sp)
ffffffffc0201d86:	64a2                	ld	s1,8(sp)
ffffffffc0201d88:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201d8a:	893fe06f          	j	ffffffffc020061c <intr_enable>

ffffffffc0201d8e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d8e:	100027f3          	csrr	a5,sstatus
ffffffffc0201d92:	8b89                	andi	a5,a5,2
ffffffffc0201d94:	e799                	bnez	a5,ffffffffc0201da2 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d96:	000b1797          	auipc	a5,0xb1
ffffffffc0201d9a:	a727b783          	ld	a5,-1422(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc0201d9e:	779c                	ld	a5,40(a5)
ffffffffc0201da0:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201da2:	1141                	addi	sp,sp,-16
ffffffffc0201da4:	e406                	sd	ra,8(sp)
ffffffffc0201da6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201da8:	87bfe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dac:	000b1797          	auipc	a5,0xb1
ffffffffc0201db0:	a5c7b783          	ld	a5,-1444(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc0201db4:	779c                	ld	a5,40(a5)
ffffffffc0201db6:	9782                	jalr	a5
ffffffffc0201db8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201dba:	863fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201dbe:	60a2                	ld	ra,8(sp)
ffffffffc0201dc0:	8522                	mv	a0,s0
ffffffffc0201dc2:	6402                	ld	s0,0(sp)
ffffffffc0201dc4:	0141                	addi	sp,sp,16
ffffffffc0201dc6:	8082                	ret

ffffffffc0201dc8 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dc8:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201dcc:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dd0:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dd2:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dd4:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dd6:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dda:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201ddc:	f04a                	sd	s2,32(sp)
ffffffffc0201dde:	ec4e                	sd	s3,24(sp)
ffffffffc0201de0:	e852                	sd	s4,16(sp)
ffffffffc0201de2:	fc06                	sd	ra,56(sp)
ffffffffc0201de4:	f822                	sd	s0,48(sp)
ffffffffc0201de6:	e456                	sd	s5,8(sp)
ffffffffc0201de8:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dea:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dee:	892e                	mv	s2,a1
ffffffffc0201df0:	89b2                	mv	s3,a2
ffffffffc0201df2:	000b1a17          	auipc	s4,0xb1
ffffffffc0201df6:	a06a0a13          	addi	s4,s4,-1530 # ffffffffc02b27f8 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dfa:	e7b5                	bnez	a5,ffffffffc0201e66 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201dfc:	12060b63          	beqz	a2,ffffffffc0201f32 <get_pte+0x16a>
ffffffffc0201e00:	4505                	li	a0,1
ffffffffc0201e02:	ebbff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201e06:	842a                	mv	s0,a0
ffffffffc0201e08:	12050563          	beqz	a0,ffffffffc0201f32 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201e0c:	000b1b17          	auipc	s6,0xb1
ffffffffc0201e10:	9f4b0b13          	addi	s6,s6,-1548 # ffffffffc02b2800 <pages>
ffffffffc0201e14:	000b3503          	ld	a0,0(s6)
ffffffffc0201e18:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e1c:	000b1a17          	auipc	s4,0xb1
ffffffffc0201e20:	9dca0a13          	addi	s4,s4,-1572 # ffffffffc02b27f8 <npage>
ffffffffc0201e24:	40a40533          	sub	a0,s0,a0
ffffffffc0201e28:	8519                	srai	a0,a0,0x6
ffffffffc0201e2a:	9556                	add	a0,a0,s5
ffffffffc0201e2c:	000a3703          	ld	a4,0(s4)
ffffffffc0201e30:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e34:	4685                	li	a3,1
ffffffffc0201e36:	c014                	sw	a3,0(s0)
ffffffffc0201e38:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e3a:	0532                	slli	a0,a0,0xc
ffffffffc0201e3c:	14e7f263          	bgeu	a5,a4,ffffffffc0201f80 <get_pte+0x1b8>
ffffffffc0201e40:	000b1797          	auipc	a5,0xb1
ffffffffc0201e44:	9d07b783          	ld	a5,-1584(a5) # ffffffffc02b2810 <va_pa_offset>
ffffffffc0201e48:	6605                	lui	a2,0x1
ffffffffc0201e4a:	4581                	li	a1,0
ffffffffc0201e4c:	953e                	add	a0,a0,a5
ffffffffc0201e4e:	5ab030ef          	jal	ra,ffffffffc0205bf8 <memset>
    return page - pages + nbase;
ffffffffc0201e52:	000b3683          	ld	a3,0(s6)
ffffffffc0201e56:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e5a:	8699                	srai	a3,a3,0x6
ffffffffc0201e5c:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e5e:	06aa                	slli	a3,a3,0xa
ffffffffc0201e60:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e64:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e66:	77fd                	lui	a5,0xfffff
ffffffffc0201e68:	068a                	slli	a3,a3,0x2
ffffffffc0201e6a:	000a3703          	ld	a4,0(s4)
ffffffffc0201e6e:	8efd                	and	a3,a3,a5
ffffffffc0201e70:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e74:	0ce7f163          	bgeu	a5,a4,ffffffffc0201f36 <get_pte+0x16e>
ffffffffc0201e78:	000b1a97          	auipc	s5,0xb1
ffffffffc0201e7c:	998a8a93          	addi	s5,s5,-1640 # ffffffffc02b2810 <va_pa_offset>
ffffffffc0201e80:	000ab403          	ld	s0,0(s5)
ffffffffc0201e84:	01595793          	srli	a5,s2,0x15
ffffffffc0201e88:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e8c:	96a2                	add	a3,a3,s0
ffffffffc0201e8e:	00379413          	slli	s0,a5,0x3
ffffffffc0201e92:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201e94:	6014                	ld	a3,0(s0)
ffffffffc0201e96:	0016f793          	andi	a5,a3,1
ffffffffc0201e9a:	e3ad                	bnez	a5,ffffffffc0201efc <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e9c:	08098b63          	beqz	s3,ffffffffc0201f32 <get_pte+0x16a>
ffffffffc0201ea0:	4505                	li	a0,1
ffffffffc0201ea2:	e1bff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0201ea6:	84aa                	mv	s1,a0
ffffffffc0201ea8:	c549                	beqz	a0,ffffffffc0201f32 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201eaa:	000b1b17          	auipc	s6,0xb1
ffffffffc0201eae:	956b0b13          	addi	s6,s6,-1706 # ffffffffc02b2800 <pages>
ffffffffc0201eb2:	000b3503          	ld	a0,0(s6)
ffffffffc0201eb6:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201eba:	000a3703          	ld	a4,0(s4)
ffffffffc0201ebe:	40a48533          	sub	a0,s1,a0
ffffffffc0201ec2:	8519                	srai	a0,a0,0x6
ffffffffc0201ec4:	954e                	add	a0,a0,s3
ffffffffc0201ec6:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201eca:	4685                	li	a3,1
ffffffffc0201ecc:	c094                	sw	a3,0(s1)
ffffffffc0201ece:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ed0:	0532                	slli	a0,a0,0xc
ffffffffc0201ed2:	08e7fa63          	bgeu	a5,a4,ffffffffc0201f66 <get_pte+0x19e>
ffffffffc0201ed6:	000ab783          	ld	a5,0(s5)
ffffffffc0201eda:	6605                	lui	a2,0x1
ffffffffc0201edc:	4581                	li	a1,0
ffffffffc0201ede:	953e                	add	a0,a0,a5
ffffffffc0201ee0:	519030ef          	jal	ra,ffffffffc0205bf8 <memset>
    return page - pages + nbase;
ffffffffc0201ee4:	000b3683          	ld	a3,0(s6)
ffffffffc0201ee8:	40d486b3          	sub	a3,s1,a3
ffffffffc0201eec:	8699                	srai	a3,a3,0x6
ffffffffc0201eee:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ef0:	06aa                	slli	a3,a3,0xa
ffffffffc0201ef2:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ef6:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201ef8:	000a3703          	ld	a4,0(s4)
ffffffffc0201efc:	068a                	slli	a3,a3,0x2
ffffffffc0201efe:	757d                	lui	a0,0xfffff
ffffffffc0201f00:	8ee9                	and	a3,a3,a0
ffffffffc0201f02:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f06:	04e7f463          	bgeu	a5,a4,ffffffffc0201f4e <get_pte+0x186>
ffffffffc0201f0a:	000ab503          	ld	a0,0(s5)
ffffffffc0201f0e:	00c95913          	srli	s2,s2,0xc
ffffffffc0201f12:	1ff97913          	andi	s2,s2,511
ffffffffc0201f16:	96aa                	add	a3,a3,a0
ffffffffc0201f18:	00391513          	slli	a0,s2,0x3
ffffffffc0201f1c:	9536                	add	a0,a0,a3
}
ffffffffc0201f1e:	70e2                	ld	ra,56(sp)
ffffffffc0201f20:	7442                	ld	s0,48(sp)
ffffffffc0201f22:	74a2                	ld	s1,40(sp)
ffffffffc0201f24:	7902                	ld	s2,32(sp)
ffffffffc0201f26:	69e2                	ld	s3,24(sp)
ffffffffc0201f28:	6a42                	ld	s4,16(sp)
ffffffffc0201f2a:	6aa2                	ld	s5,8(sp)
ffffffffc0201f2c:	6b02                	ld	s6,0(sp)
ffffffffc0201f2e:	6121                	addi	sp,sp,64
ffffffffc0201f30:	8082                	ret
            return NULL;
ffffffffc0201f32:	4501                	li	a0,0
ffffffffc0201f34:	b7ed                	j	ffffffffc0201f1e <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f36:	00005617          	auipc	a2,0x5
ffffffffc0201f3a:	a7a60613          	addi	a2,a2,-1414 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0201f3e:	0e300593          	li	a1,227
ffffffffc0201f42:	00005517          	auipc	a0,0x5
ffffffffc0201f46:	b8650513          	addi	a0,a0,-1146 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0201f4a:	d30fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f4e:	00005617          	auipc	a2,0x5
ffffffffc0201f52:	a6260613          	addi	a2,a2,-1438 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0201f56:	0ee00593          	li	a1,238
ffffffffc0201f5a:	00005517          	auipc	a0,0x5
ffffffffc0201f5e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0201f62:	d18fe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f66:	86aa                	mv	a3,a0
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	a4860613          	addi	a2,a2,-1464 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0201f70:	0eb00593          	li	a1,235
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	b5450513          	addi	a0,a0,-1196 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0201f7c:	cfefe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f80:	86aa                	mv	a3,a0
ffffffffc0201f82:	00005617          	auipc	a2,0x5
ffffffffc0201f86:	a2e60613          	addi	a2,a2,-1490 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0201f8a:	0df00593          	li	a1,223
ffffffffc0201f8e:	00005517          	auipc	a0,0x5
ffffffffc0201f92:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0201f96:	ce4fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201f9a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201f9a:	1141                	addi	sp,sp,-16
ffffffffc0201f9c:	e022                	sd	s0,0(sp)
ffffffffc0201f9e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fa0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fa2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fa4:	e25ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201fa8:	c011                	beqz	s0,ffffffffc0201fac <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201faa:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fac:	c511                	beqz	a0,ffffffffc0201fb8 <get_page+0x1e>
ffffffffc0201fae:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201fb0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fb2:	0017f713          	andi	a4,a5,1
ffffffffc0201fb6:	e709                	bnez	a4,ffffffffc0201fc0 <get_page+0x26>
}
ffffffffc0201fb8:	60a2                	ld	ra,8(sp)
ffffffffc0201fba:	6402                	ld	s0,0(sp)
ffffffffc0201fbc:	0141                	addi	sp,sp,16
ffffffffc0201fbe:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fc0:	078a                	slli	a5,a5,0x2
ffffffffc0201fc2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fc4:	000b1717          	auipc	a4,0xb1
ffffffffc0201fc8:	83473703          	ld	a4,-1996(a4) # ffffffffc02b27f8 <npage>
ffffffffc0201fcc:	00e7ff63          	bgeu	a5,a4,ffffffffc0201fea <get_page+0x50>
ffffffffc0201fd0:	60a2                	ld	ra,8(sp)
ffffffffc0201fd2:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201fd4:	fff80537          	lui	a0,0xfff80
ffffffffc0201fd8:	97aa                	add	a5,a5,a0
ffffffffc0201fda:	079a                	slli	a5,a5,0x6
ffffffffc0201fdc:	000b1517          	auipc	a0,0xb1
ffffffffc0201fe0:	82453503          	ld	a0,-2012(a0) # ffffffffc02b2800 <pages>
ffffffffc0201fe4:	953e                	add	a0,a0,a5
ffffffffc0201fe6:	0141                	addi	sp,sp,16
ffffffffc0201fe8:	8082                	ret
ffffffffc0201fea:	c9bff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>

ffffffffc0201fee <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201fee:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201ff0:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201ff4:	f486                	sd	ra,104(sp)
ffffffffc0201ff6:	f0a2                	sd	s0,96(sp)
ffffffffc0201ff8:	eca6                	sd	s1,88(sp)
ffffffffc0201ffa:	e8ca                	sd	s2,80(sp)
ffffffffc0201ffc:	e4ce                	sd	s3,72(sp)
ffffffffc0201ffe:	e0d2                	sd	s4,64(sp)
ffffffffc0202000:	fc56                	sd	s5,56(sp)
ffffffffc0202002:	f85a                	sd	s6,48(sp)
ffffffffc0202004:	f45e                	sd	s7,40(sp)
ffffffffc0202006:	f062                	sd	s8,32(sp)
ffffffffc0202008:	ec66                	sd	s9,24(sp)
ffffffffc020200a:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020200c:	17d2                	slli	a5,a5,0x34
ffffffffc020200e:	e3ed                	bnez	a5,ffffffffc02020f0 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202010:	002007b7          	lui	a5,0x200
ffffffffc0202014:	842e                	mv	s0,a1
ffffffffc0202016:	0ef5ed63          	bltu	a1,a5,ffffffffc0202110 <unmap_range+0x122>
ffffffffc020201a:	8932                	mv	s2,a2
ffffffffc020201c:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202110 <unmap_range+0x122>
ffffffffc0202020:	4785                	li	a5,1
ffffffffc0202022:	07fe                	slli	a5,a5,0x1f
ffffffffc0202024:	0ec7e663          	bltu	a5,a2,ffffffffc0202110 <unmap_range+0x122>
ffffffffc0202028:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc020202a:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020202c:	000b0c97          	auipc	s9,0xb0
ffffffffc0202030:	7ccc8c93          	addi	s9,s9,1996 # ffffffffc02b27f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202034:	000b0c17          	auipc	s8,0xb0
ffffffffc0202038:	7ccc0c13          	addi	s8,s8,1996 # ffffffffc02b2800 <pages>
ffffffffc020203c:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202040:	000b0d17          	auipc	s10,0xb0
ffffffffc0202044:	7c8d0d13          	addi	s10,s10,1992 # ffffffffc02b2808 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202048:	00200b37          	lui	s6,0x200
ffffffffc020204c:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202050:	4601                	li	a2,0
ffffffffc0202052:	85a2                	mv	a1,s0
ffffffffc0202054:	854e                	mv	a0,s3
ffffffffc0202056:	d73ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc020205a:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc020205c:	cd29                	beqz	a0,ffffffffc02020b6 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc020205e:	611c                	ld	a5,0(a0)
ffffffffc0202060:	e395                	bnez	a5,ffffffffc0202084 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202062:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202064:	ff2466e3          	bltu	s0,s2,ffffffffc0202050 <unmap_range+0x62>
}
ffffffffc0202068:	70a6                	ld	ra,104(sp)
ffffffffc020206a:	7406                	ld	s0,96(sp)
ffffffffc020206c:	64e6                	ld	s1,88(sp)
ffffffffc020206e:	6946                	ld	s2,80(sp)
ffffffffc0202070:	69a6                	ld	s3,72(sp)
ffffffffc0202072:	6a06                	ld	s4,64(sp)
ffffffffc0202074:	7ae2                	ld	s5,56(sp)
ffffffffc0202076:	7b42                	ld	s6,48(sp)
ffffffffc0202078:	7ba2                	ld	s7,40(sp)
ffffffffc020207a:	7c02                	ld	s8,32(sp)
ffffffffc020207c:	6ce2                	ld	s9,24(sp)
ffffffffc020207e:	6d42                	ld	s10,16(sp)
ffffffffc0202080:	6165                	addi	sp,sp,112
ffffffffc0202082:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202084:	0017f713          	andi	a4,a5,1
ffffffffc0202088:	df69                	beqz	a4,ffffffffc0202062 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc020208a:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020208e:	078a                	slli	a5,a5,0x2
ffffffffc0202090:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202092:	08e7ff63          	bgeu	a5,a4,ffffffffc0202130 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202096:	000c3503          	ld	a0,0(s8)
ffffffffc020209a:	97de                	add	a5,a5,s7
ffffffffc020209c:	079a                	slli	a5,a5,0x6
ffffffffc020209e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02020a0:	411c                	lw	a5,0(a0)
ffffffffc02020a2:	fff7871b          	addiw	a4,a5,-1
ffffffffc02020a6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02020a8:	cf11                	beqz	a4,ffffffffc02020c4 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02020aa:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020ae:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02020b2:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02020b4:	bf45                	j	ffffffffc0202064 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02020b6:	945a                	add	s0,s0,s6
ffffffffc02020b8:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02020bc:	d455                	beqz	s0,ffffffffc0202068 <unmap_range+0x7a>
ffffffffc02020be:	f92469e3          	bltu	s0,s2,ffffffffc0202050 <unmap_range+0x62>
ffffffffc02020c2:	b75d                	j	ffffffffc0202068 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020c4:	100027f3          	csrr	a5,sstatus
ffffffffc02020c8:	8b89                	andi	a5,a5,2
ffffffffc02020ca:	e799                	bnez	a5,ffffffffc02020d8 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02020cc:	000d3783          	ld	a5,0(s10)
ffffffffc02020d0:	4585                	li	a1,1
ffffffffc02020d2:	739c                	ld	a5,32(a5)
ffffffffc02020d4:	9782                	jalr	a5
    if (flag) {
ffffffffc02020d6:	bfd1                	j	ffffffffc02020aa <unmap_range+0xbc>
ffffffffc02020d8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020da:	d48fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc02020de:	000d3783          	ld	a5,0(s10)
ffffffffc02020e2:	6522                	ld	a0,8(sp)
ffffffffc02020e4:	4585                	li	a1,1
ffffffffc02020e6:	739c                	ld	a5,32(a5)
ffffffffc02020e8:	9782                	jalr	a5
        intr_enable();
ffffffffc02020ea:	d32fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc02020ee:	bf75                	j	ffffffffc02020aa <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020f0:	00005697          	auipc	a3,0x5
ffffffffc02020f4:	9e868693          	addi	a3,a3,-1560 # ffffffffc0206ad8 <default_pmm_manager+0x160>
ffffffffc02020f8:	00004617          	auipc	a2,0x4
ffffffffc02020fc:	1e860613          	addi	a2,a2,488 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202100:	10f00593          	li	a1,271
ffffffffc0202104:	00005517          	auipc	a0,0x5
ffffffffc0202108:	9c450513          	addi	a0,a0,-1596 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020210c:	b6efe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202110:	00005697          	auipc	a3,0x5
ffffffffc0202114:	9f868693          	addi	a3,a3,-1544 # ffffffffc0206b08 <default_pmm_manager+0x190>
ffffffffc0202118:	00004617          	auipc	a2,0x4
ffffffffc020211c:	1c860613          	addi	a2,a2,456 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202120:	11000593          	li	a1,272
ffffffffc0202124:	00005517          	auipc	a0,0x5
ffffffffc0202128:	9a450513          	addi	a0,a0,-1628 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020212c:	b4efe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202130:	b55ff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>

ffffffffc0202134 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202134:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202136:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020213a:	fc86                	sd	ra,120(sp)
ffffffffc020213c:	f8a2                	sd	s0,112(sp)
ffffffffc020213e:	f4a6                	sd	s1,104(sp)
ffffffffc0202140:	f0ca                	sd	s2,96(sp)
ffffffffc0202142:	ecce                	sd	s3,88(sp)
ffffffffc0202144:	e8d2                	sd	s4,80(sp)
ffffffffc0202146:	e4d6                	sd	s5,72(sp)
ffffffffc0202148:	e0da                	sd	s6,64(sp)
ffffffffc020214a:	fc5e                	sd	s7,56(sp)
ffffffffc020214c:	f862                	sd	s8,48(sp)
ffffffffc020214e:	f466                	sd	s9,40(sp)
ffffffffc0202150:	f06a                	sd	s10,32(sp)
ffffffffc0202152:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202154:	17d2                	slli	a5,a5,0x34
ffffffffc0202156:	20079a63          	bnez	a5,ffffffffc020236a <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc020215a:	002007b7          	lui	a5,0x200
ffffffffc020215e:	24f5e463          	bltu	a1,a5,ffffffffc02023a6 <exit_range+0x272>
ffffffffc0202162:	8ab2                	mv	s5,a2
ffffffffc0202164:	24c5f163          	bgeu	a1,a2,ffffffffc02023a6 <exit_range+0x272>
ffffffffc0202168:	4785                	li	a5,1
ffffffffc020216a:	07fe                	slli	a5,a5,0x1f
ffffffffc020216c:	22c7ed63          	bltu	a5,a2,ffffffffc02023a6 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202170:	c00009b7          	lui	s3,0xc0000
ffffffffc0202174:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202178:	ffe00937          	lui	s2,0xffe00
ffffffffc020217c:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0202180:	5cfd                	li	s9,-1
ffffffffc0202182:	8c2a                	mv	s8,a0
ffffffffc0202184:	0125f933          	and	s2,a1,s2
ffffffffc0202188:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc020218a:	000b0d17          	auipc	s10,0xb0
ffffffffc020218e:	66ed0d13          	addi	s10,s10,1646 # ffffffffc02b27f8 <npage>
    return KADDR(page2pa(page));
ffffffffc0202192:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202196:	000b0717          	auipc	a4,0xb0
ffffffffc020219a:	66a70713          	addi	a4,a4,1642 # ffffffffc02b2800 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020219e:	000b0d97          	auipc	s11,0xb0
ffffffffc02021a2:	66ad8d93          	addi	s11,s11,1642 # ffffffffc02b2808 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02021a6:	c0000437          	lui	s0,0xc0000
ffffffffc02021aa:	944e                	add	s0,s0,s3
ffffffffc02021ac:	8079                	srli	s0,s0,0x1e
ffffffffc02021ae:	1ff47413          	andi	s0,s0,511
ffffffffc02021b2:	040e                	slli	s0,s0,0x3
ffffffffc02021b4:	9462                	add	s0,s0,s8
ffffffffc02021b6:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
        if (pde1&PTE_V){
ffffffffc02021ba:	001a7793          	andi	a5,s4,1
ffffffffc02021be:	eb99                	bnez	a5,ffffffffc02021d4 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02021c0:	12098463          	beqz	s3,ffffffffc02022e8 <exit_range+0x1b4>
ffffffffc02021c4:	400007b7          	lui	a5,0x40000
ffffffffc02021c8:	97ce                	add	a5,a5,s3
ffffffffc02021ca:	894e                	mv	s2,s3
ffffffffc02021cc:	1159fe63          	bgeu	s3,s5,ffffffffc02022e8 <exit_range+0x1b4>
ffffffffc02021d0:	89be                	mv	s3,a5
ffffffffc02021d2:	bfd1                	j	ffffffffc02021a6 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02021d4:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021d8:	0a0a                	slli	s4,s4,0x2
ffffffffc02021da:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021de:	1cfa7263          	bgeu	s4,a5,ffffffffc02023a2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02021e2:	fff80637          	lui	a2,0xfff80
ffffffffc02021e6:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02021e8:	000806b7          	lui	a3,0x80
ffffffffc02021ec:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02021ee:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02021f2:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02021f4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02021f6:	18f5fa63          	bgeu	a1,a5,ffffffffc020238a <exit_range+0x256>
ffffffffc02021fa:	000b0817          	auipc	a6,0xb0
ffffffffc02021fe:	61680813          	addi	a6,a6,1558 # ffffffffc02b2810 <va_pa_offset>
ffffffffc0202202:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202206:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202208:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc020220c:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc020220e:	00080337          	lui	t1,0x80
ffffffffc0202212:	6885                	lui	a7,0x1
ffffffffc0202214:	a819                	j	ffffffffc020222a <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202216:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202218:	002007b7          	lui	a5,0x200
ffffffffc020221c:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020221e:	08090c63          	beqz	s2,ffffffffc02022b6 <exit_range+0x182>
ffffffffc0202222:	09397a63          	bgeu	s2,s3,ffffffffc02022b6 <exit_range+0x182>
ffffffffc0202226:	0f597063          	bgeu	s2,s5,ffffffffc0202306 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020222a:	01595493          	srli	s1,s2,0x15
ffffffffc020222e:	1ff4f493          	andi	s1,s1,511
ffffffffc0202232:	048e                	slli	s1,s1,0x3
ffffffffc0202234:	94da                	add	s1,s1,s6
ffffffffc0202236:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc0202238:	0017f693          	andi	a3,a5,1
ffffffffc020223c:	dee9                	beqz	a3,ffffffffc0202216 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc020223e:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202242:	078a                	slli	a5,a5,0x2
ffffffffc0202244:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202246:	14b7fe63          	bgeu	a5,a1,ffffffffc02023a2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020224a:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc020224c:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202250:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202254:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202258:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020225a:	12bef863          	bgeu	t4,a1,ffffffffc020238a <exit_range+0x256>
ffffffffc020225e:	00083783          	ld	a5,0(a6)
ffffffffc0202262:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202264:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0202268:	629c                	ld	a5,0(a3)
ffffffffc020226a:	8b85                	andi	a5,a5,1
ffffffffc020226c:	f7d5                	bnez	a5,ffffffffc0202218 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020226e:	06a1                	addi	a3,a3,8
ffffffffc0202270:	fed59ce3          	bne	a1,a3,ffffffffc0202268 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202274:	631c                	ld	a5,0(a4)
ffffffffc0202276:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202278:	100027f3          	csrr	a5,sstatus
ffffffffc020227c:	8b89                	andi	a5,a5,2
ffffffffc020227e:	e7d9                	bnez	a5,ffffffffc020230c <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0202280:	000db783          	ld	a5,0(s11)
ffffffffc0202284:	4585                	li	a1,1
ffffffffc0202286:	e032                	sd	a2,0(sp)
ffffffffc0202288:	739c                	ld	a5,32(a5)
ffffffffc020228a:	9782                	jalr	a5
    if (flag) {
ffffffffc020228c:	6602                	ld	a2,0(sp)
ffffffffc020228e:	000b0817          	auipc	a6,0xb0
ffffffffc0202292:	58280813          	addi	a6,a6,1410 # ffffffffc02b2810 <va_pa_offset>
ffffffffc0202296:	fff80e37          	lui	t3,0xfff80
ffffffffc020229a:	00080337          	lui	t1,0x80
ffffffffc020229e:	6885                	lui	a7,0x1
ffffffffc02022a0:	000b0717          	auipc	a4,0xb0
ffffffffc02022a4:	56070713          	addi	a4,a4,1376 # ffffffffc02b2800 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02022a8:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02022ac:	002007b7          	lui	a5,0x200
ffffffffc02022b0:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02022b2:	f60918e3          	bnez	s2,ffffffffc0202222 <exit_range+0xee>
            if (free_pd0) {
ffffffffc02022b6:	f00b85e3          	beqz	s7,ffffffffc02021c0 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc02022ba:	000d3783          	ld	a5,0(s10)
ffffffffc02022be:	0efa7263          	bgeu	s4,a5,ffffffffc02023a2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022c2:	6308                	ld	a0,0(a4)
ffffffffc02022c4:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022c6:	100027f3          	csrr	a5,sstatus
ffffffffc02022ca:	8b89                	andi	a5,a5,2
ffffffffc02022cc:	efad                	bnez	a5,ffffffffc0202346 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02022ce:	000db783          	ld	a5,0(s11)
ffffffffc02022d2:	4585                	li	a1,1
ffffffffc02022d4:	739c                	ld	a5,32(a5)
ffffffffc02022d6:	9782                	jalr	a5
ffffffffc02022d8:	000b0717          	auipc	a4,0xb0
ffffffffc02022dc:	52870713          	addi	a4,a4,1320 # ffffffffc02b2800 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02022e0:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02022e4:	ee0990e3          	bnez	s3,ffffffffc02021c4 <exit_range+0x90>
}
ffffffffc02022e8:	70e6                	ld	ra,120(sp)
ffffffffc02022ea:	7446                	ld	s0,112(sp)
ffffffffc02022ec:	74a6                	ld	s1,104(sp)
ffffffffc02022ee:	7906                	ld	s2,96(sp)
ffffffffc02022f0:	69e6                	ld	s3,88(sp)
ffffffffc02022f2:	6a46                	ld	s4,80(sp)
ffffffffc02022f4:	6aa6                	ld	s5,72(sp)
ffffffffc02022f6:	6b06                	ld	s6,64(sp)
ffffffffc02022f8:	7be2                	ld	s7,56(sp)
ffffffffc02022fa:	7c42                	ld	s8,48(sp)
ffffffffc02022fc:	7ca2                	ld	s9,40(sp)
ffffffffc02022fe:	7d02                	ld	s10,32(sp)
ffffffffc0202300:	6de2                	ld	s11,24(sp)
ffffffffc0202302:	6109                	addi	sp,sp,128
ffffffffc0202304:	8082                	ret
            if (free_pd0) {
ffffffffc0202306:	ea0b8fe3          	beqz	s7,ffffffffc02021c4 <exit_range+0x90>
ffffffffc020230a:	bf45                	j	ffffffffc02022ba <exit_range+0x186>
ffffffffc020230c:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc020230e:	e42a                	sd	a0,8(sp)
ffffffffc0202310:	b12fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202314:	000db783          	ld	a5,0(s11)
ffffffffc0202318:	6522                	ld	a0,8(sp)
ffffffffc020231a:	4585                	li	a1,1
ffffffffc020231c:	739c                	ld	a5,32(a5)
ffffffffc020231e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202320:	afcfe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202324:	6602                	ld	a2,0(sp)
ffffffffc0202326:	000b0717          	auipc	a4,0xb0
ffffffffc020232a:	4da70713          	addi	a4,a4,1242 # ffffffffc02b2800 <pages>
ffffffffc020232e:	6885                	lui	a7,0x1
ffffffffc0202330:	00080337          	lui	t1,0x80
ffffffffc0202334:	fff80e37          	lui	t3,0xfff80
ffffffffc0202338:	000b0817          	auipc	a6,0xb0
ffffffffc020233c:	4d880813          	addi	a6,a6,1240 # ffffffffc02b2810 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202340:	0004b023          	sd	zero,0(s1)
ffffffffc0202344:	b7a5                	j	ffffffffc02022ac <exit_range+0x178>
ffffffffc0202346:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202348:	adafe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020234c:	000db783          	ld	a5,0(s11)
ffffffffc0202350:	6502                	ld	a0,0(sp)
ffffffffc0202352:	4585                	li	a1,1
ffffffffc0202354:	739c                	ld	a5,32(a5)
ffffffffc0202356:	9782                	jalr	a5
        intr_enable();
ffffffffc0202358:	ac4fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc020235c:	000b0717          	auipc	a4,0xb0
ffffffffc0202360:	4a470713          	addi	a4,a4,1188 # ffffffffc02b2800 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202364:	00043023          	sd	zero,0(s0)
ffffffffc0202368:	bfb5                	j	ffffffffc02022e4 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020236a:	00004697          	auipc	a3,0x4
ffffffffc020236e:	76e68693          	addi	a3,a3,1902 # ffffffffc0206ad8 <default_pmm_manager+0x160>
ffffffffc0202372:	00004617          	auipc	a2,0x4
ffffffffc0202376:	f6e60613          	addi	a2,a2,-146 # ffffffffc02062e0 <commands+0x450>
ffffffffc020237a:	12000593          	li	a1,288
ffffffffc020237e:	00004517          	auipc	a0,0x4
ffffffffc0202382:	74a50513          	addi	a0,a0,1866 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202386:	8f4fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc020238a:	00004617          	auipc	a2,0x4
ffffffffc020238e:	62660613          	addi	a2,a2,1574 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0202392:	06900593          	li	a1,105
ffffffffc0202396:	00004517          	auipc	a0,0x4
ffffffffc020239a:	64250513          	addi	a0,a0,1602 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc020239e:	8dcfe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02023a2:	8e3ff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02023a6:	00004697          	auipc	a3,0x4
ffffffffc02023aa:	76268693          	addi	a3,a3,1890 # ffffffffc0206b08 <default_pmm_manager+0x190>
ffffffffc02023ae:	00004617          	auipc	a2,0x4
ffffffffc02023b2:	f3260613          	addi	a2,a2,-206 # ffffffffc02062e0 <commands+0x450>
ffffffffc02023b6:	12100593          	li	a1,289
ffffffffc02023ba:	00004517          	auipc	a0,0x4
ffffffffc02023be:	70e50513          	addi	a0,a0,1806 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02023c2:	8b8fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02023c6 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023c6:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023c8:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023ca:	ec26                	sd	s1,24(sp)
ffffffffc02023cc:	f406                	sd	ra,40(sp)
ffffffffc02023ce:	f022                	sd	s0,32(sp)
ffffffffc02023d0:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023d2:	9f7ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
    if (ptep != NULL) {
ffffffffc02023d6:	c511                	beqz	a0,ffffffffc02023e2 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02023d8:	611c                	ld	a5,0(a0)
ffffffffc02023da:	842a                	mv	s0,a0
ffffffffc02023dc:	0017f713          	andi	a4,a5,1
ffffffffc02023e0:	e711                	bnez	a4,ffffffffc02023ec <page_remove+0x26>
}
ffffffffc02023e2:	70a2                	ld	ra,40(sp)
ffffffffc02023e4:	7402                	ld	s0,32(sp)
ffffffffc02023e6:	64e2                	ld	s1,24(sp)
ffffffffc02023e8:	6145                	addi	sp,sp,48
ffffffffc02023ea:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02023ec:	078a                	slli	a5,a5,0x2
ffffffffc02023ee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023f0:	000b0717          	auipc	a4,0xb0
ffffffffc02023f4:	40873703          	ld	a4,1032(a4) # ffffffffc02b27f8 <npage>
ffffffffc02023f8:	06e7f363          	bgeu	a5,a4,ffffffffc020245e <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02023fc:	fff80537          	lui	a0,0xfff80
ffffffffc0202400:	97aa                	add	a5,a5,a0
ffffffffc0202402:	079a                	slli	a5,a5,0x6
ffffffffc0202404:	000b0517          	auipc	a0,0xb0
ffffffffc0202408:	3fc53503          	ld	a0,1020(a0) # ffffffffc02b2800 <pages>
ffffffffc020240c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020240e:	411c                	lw	a5,0(a0)
ffffffffc0202410:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202414:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202416:	cb11                	beqz	a4,ffffffffc020242a <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202418:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020241c:	12048073          	sfence.vma	s1
}
ffffffffc0202420:	70a2                	ld	ra,40(sp)
ffffffffc0202422:	7402                	ld	s0,32(sp)
ffffffffc0202424:	64e2                	ld	s1,24(sp)
ffffffffc0202426:	6145                	addi	sp,sp,48
ffffffffc0202428:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020242a:	100027f3          	csrr	a5,sstatus
ffffffffc020242e:	8b89                	andi	a5,a5,2
ffffffffc0202430:	eb89                	bnez	a5,ffffffffc0202442 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202432:	000b0797          	auipc	a5,0xb0
ffffffffc0202436:	3d67b783          	ld	a5,982(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc020243a:	739c                	ld	a5,32(a5)
ffffffffc020243c:	4585                	li	a1,1
ffffffffc020243e:	9782                	jalr	a5
    if (flag) {
ffffffffc0202440:	bfe1                	j	ffffffffc0202418 <page_remove+0x52>
        intr_disable();
ffffffffc0202442:	e42a                	sd	a0,8(sp)
ffffffffc0202444:	9defe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202448:	000b0797          	auipc	a5,0xb0
ffffffffc020244c:	3c07b783          	ld	a5,960(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc0202450:	739c                	ld	a5,32(a5)
ffffffffc0202452:	6522                	ld	a0,8(sp)
ffffffffc0202454:	4585                	li	a1,1
ffffffffc0202456:	9782                	jalr	a5
        intr_enable();
ffffffffc0202458:	9c4fe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc020245c:	bf75                	j	ffffffffc0202418 <page_remove+0x52>
ffffffffc020245e:	827ff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>

ffffffffc0202462 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202462:	7139                	addi	sp,sp,-64
ffffffffc0202464:	e852                	sd	s4,16(sp)
ffffffffc0202466:	8a32                	mv	s4,a2
ffffffffc0202468:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020246a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020246c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020246e:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202470:	f426                	sd	s1,40(sp)
ffffffffc0202472:	fc06                	sd	ra,56(sp)
ffffffffc0202474:	f04a                	sd	s2,32(sp)
ffffffffc0202476:	ec4e                	sd	s3,24(sp)
ffffffffc0202478:	e456                	sd	s5,8(sp)
ffffffffc020247a:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020247c:	94dff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
    if (ptep == NULL) {
ffffffffc0202480:	c961                	beqz	a0,ffffffffc0202550 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202482:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202484:	611c                	ld	a5,0(a0)
ffffffffc0202486:	89aa                	mv	s3,a0
ffffffffc0202488:	0016871b          	addiw	a4,a3,1
ffffffffc020248c:	c018                	sw	a4,0(s0)
ffffffffc020248e:	0017f713          	andi	a4,a5,1
ffffffffc0202492:	ef05                	bnez	a4,ffffffffc02024ca <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202494:	000b0717          	auipc	a4,0xb0
ffffffffc0202498:	36c73703          	ld	a4,876(a4) # ffffffffc02b2800 <pages>
ffffffffc020249c:	8c19                	sub	s0,s0,a4
ffffffffc020249e:	000807b7          	lui	a5,0x80
ffffffffc02024a2:	8419                	srai	s0,s0,0x6
ffffffffc02024a4:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02024a6:	042a                	slli	s0,s0,0xa
ffffffffc02024a8:	8cc1                	or	s1,s1,s0
ffffffffc02024aa:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02024ae:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024b2:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02024b6:	4501                	li	a0,0
}
ffffffffc02024b8:	70e2                	ld	ra,56(sp)
ffffffffc02024ba:	7442                	ld	s0,48(sp)
ffffffffc02024bc:	74a2                	ld	s1,40(sp)
ffffffffc02024be:	7902                	ld	s2,32(sp)
ffffffffc02024c0:	69e2                	ld	s3,24(sp)
ffffffffc02024c2:	6a42                	ld	s4,16(sp)
ffffffffc02024c4:	6aa2                	ld	s5,8(sp)
ffffffffc02024c6:	6121                	addi	sp,sp,64
ffffffffc02024c8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024ca:	078a                	slli	a5,a5,0x2
ffffffffc02024cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024ce:	000b0717          	auipc	a4,0xb0
ffffffffc02024d2:	32a73703          	ld	a4,810(a4) # ffffffffc02b27f8 <npage>
ffffffffc02024d6:	06e7ff63          	bgeu	a5,a4,ffffffffc0202554 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02024da:	000b0a97          	auipc	s5,0xb0
ffffffffc02024de:	326a8a93          	addi	s5,s5,806 # ffffffffc02b2800 <pages>
ffffffffc02024e2:	000ab703          	ld	a4,0(s5)
ffffffffc02024e6:	fff80937          	lui	s2,0xfff80
ffffffffc02024ea:	993e                	add	s2,s2,a5
ffffffffc02024ec:	091a                	slli	s2,s2,0x6
ffffffffc02024ee:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc02024f0:	01240c63          	beq	s0,s2,ffffffffc0202508 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02024f4:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd7a4>
ffffffffc02024f8:	fff7869b          	addiw	a3,a5,-1
ffffffffc02024fc:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202500:	c691                	beqz	a3,ffffffffc020250c <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202502:	120a0073          	sfence.vma	s4
}
ffffffffc0202506:	bf59                	j	ffffffffc020249c <page_insert+0x3a>
ffffffffc0202508:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020250a:	bf49                	j	ffffffffc020249c <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020250c:	100027f3          	csrr	a5,sstatus
ffffffffc0202510:	8b89                	andi	a5,a5,2
ffffffffc0202512:	ef91                	bnez	a5,ffffffffc020252e <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202514:	000b0797          	auipc	a5,0xb0
ffffffffc0202518:	2f47b783          	ld	a5,756(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc020251c:	739c                	ld	a5,32(a5)
ffffffffc020251e:	4585                	li	a1,1
ffffffffc0202520:	854a                	mv	a0,s2
ffffffffc0202522:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202524:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202528:	120a0073          	sfence.vma	s4
ffffffffc020252c:	bf85                	j	ffffffffc020249c <page_insert+0x3a>
        intr_disable();
ffffffffc020252e:	8f4fe0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202532:	000b0797          	auipc	a5,0xb0
ffffffffc0202536:	2d67b783          	ld	a5,726(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc020253a:	739c                	ld	a5,32(a5)
ffffffffc020253c:	4585                	li	a1,1
ffffffffc020253e:	854a                	mv	a0,s2
ffffffffc0202540:	9782                	jalr	a5
        intr_enable();
ffffffffc0202542:	8dafe0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202546:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020254a:	120a0073          	sfence.vma	s4
ffffffffc020254e:	b7b9                	j	ffffffffc020249c <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202550:	5571                	li	a0,-4
ffffffffc0202552:	b79d                	j	ffffffffc02024b8 <page_insert+0x56>
ffffffffc0202554:	f30ff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>

ffffffffc0202558 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202558:	00004797          	auipc	a5,0x4
ffffffffc020255c:	42078793          	addi	a5,a5,1056 # ffffffffc0206978 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202560:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202562:	711d                	addi	sp,sp,-96
ffffffffc0202564:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202566:	00004517          	auipc	a0,0x4
ffffffffc020256a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0206b20 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc020256e:	000b0b97          	auipc	s7,0xb0
ffffffffc0202572:	29ab8b93          	addi	s7,s7,666 # ffffffffc02b2808 <pmm_manager>
void pmm_init(void) {
ffffffffc0202576:	ec86                	sd	ra,88(sp)
ffffffffc0202578:	e4a6                	sd	s1,72(sp)
ffffffffc020257a:	fc4e                	sd	s3,56(sp)
ffffffffc020257c:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020257e:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202582:	e8a2                	sd	s0,80(sp)
ffffffffc0202584:	e0ca                	sd	s2,64(sp)
ffffffffc0202586:	f852                	sd	s4,48(sp)
ffffffffc0202588:	f456                	sd	s5,40(sp)
ffffffffc020258a:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020258c:	bf5fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc0202590:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202594:	000b0997          	auipc	s3,0xb0
ffffffffc0202598:	27c98993          	addi	s3,s3,636 # ffffffffc02b2810 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc020259c:	000b0497          	auipc	s1,0xb0
ffffffffc02025a0:	25c48493          	addi	s1,s1,604 # ffffffffc02b27f8 <npage>
    pmm_manager->init();
ffffffffc02025a4:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025a6:	000b0b17          	auipc	s6,0xb0
ffffffffc02025aa:	25ab0b13          	addi	s6,s6,602 # ffffffffc02b2800 <pages>
    pmm_manager->init();
ffffffffc02025ae:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025b0:	57f5                	li	a5,-3
ffffffffc02025b2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02025b4:	00004517          	auipc	a0,0x4
ffffffffc02025b8:	58450513          	addi	a0,a0,1412 # ffffffffc0206b38 <default_pmm_manager+0x1c0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025bc:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02025c0:	bc1fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02025c4:	46c5                	li	a3,17
ffffffffc02025c6:	06ee                	slli	a3,a3,0x1b
ffffffffc02025c8:	40100613          	li	a2,1025
ffffffffc02025cc:	07e005b7          	lui	a1,0x7e00
ffffffffc02025d0:	16fd                	addi	a3,a3,-1
ffffffffc02025d2:	0656                	slli	a2,a2,0x15
ffffffffc02025d4:	00004517          	auipc	a0,0x4
ffffffffc02025d8:	57c50513          	addi	a0,a0,1404 # ffffffffc0206b50 <default_pmm_manager+0x1d8>
ffffffffc02025dc:	ba5fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025e0:	777d                	lui	a4,0xfffff
ffffffffc02025e2:	000b1797          	auipc	a5,0xb1
ffffffffc02025e6:	27978793          	addi	a5,a5,633 # ffffffffc02b385b <end+0xfff>
ffffffffc02025ea:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02025ec:	00088737          	lui	a4,0x88
ffffffffc02025f0:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025f2:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02025f6:	4701                	li	a4,0
ffffffffc02025f8:	4585                	li	a1,1
ffffffffc02025fa:	fff80837          	lui	a6,0xfff80
ffffffffc02025fe:	a019                	j	ffffffffc0202604 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0202600:	000b3783          	ld	a5,0(s6)
ffffffffc0202604:	00671693          	slli	a3,a4,0x6
ffffffffc0202608:	97b6                	add	a5,a5,a3
ffffffffc020260a:	07a1                	addi	a5,a5,8
ffffffffc020260c:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202610:	6090                	ld	a2,0(s1)
ffffffffc0202612:	0705                	addi	a4,a4,1
ffffffffc0202614:	010607b3          	add	a5,a2,a6
ffffffffc0202618:	fef764e3          	bltu	a4,a5,ffffffffc0202600 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020261c:	000b3503          	ld	a0,0(s6)
ffffffffc0202620:	079a                	slli	a5,a5,0x6
ffffffffc0202622:	c0200737          	lui	a4,0xc0200
ffffffffc0202626:	00f506b3          	add	a3,a0,a5
ffffffffc020262a:	60e6e563          	bltu	a3,a4,ffffffffc0202c34 <pmm_init+0x6dc>
ffffffffc020262e:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202632:	4745                	li	a4,17
ffffffffc0202634:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202636:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202638:	4ae6e563          	bltu	a3,a4,ffffffffc0202ae2 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020263c:	00004517          	auipc	a0,0x4
ffffffffc0202640:	53c50513          	addi	a0,a0,1340 # ffffffffc0206b78 <default_pmm_manager+0x200>
ffffffffc0202644:	b3dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202648:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020264c:	000b0917          	auipc	s2,0xb0
ffffffffc0202650:	1a490913          	addi	s2,s2,420 # ffffffffc02b27f0 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202654:	7b9c                	ld	a5,48(a5)
ffffffffc0202656:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202658:	00004517          	auipc	a0,0x4
ffffffffc020265c:	53850513          	addi	a0,a0,1336 # ffffffffc0206b90 <default_pmm_manager+0x218>
ffffffffc0202660:	b21fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202664:	00009697          	auipc	a3,0x9
ffffffffc0202668:	99c68693          	addi	a3,a3,-1636 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020266c:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202670:	c02007b7          	lui	a5,0xc0200
ffffffffc0202674:	5cf6ec63          	bltu	a3,a5,ffffffffc0202c4c <pmm_init+0x6f4>
ffffffffc0202678:	0009b783          	ld	a5,0(s3)
ffffffffc020267c:	8e9d                	sub	a3,a3,a5
ffffffffc020267e:	000b0797          	auipc	a5,0xb0
ffffffffc0202682:	16d7b523          	sd	a3,362(a5) # ffffffffc02b27e8 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202686:	100027f3          	csrr	a5,sstatus
ffffffffc020268a:	8b89                	andi	a5,a5,2
ffffffffc020268c:	48079263          	bnez	a5,ffffffffc0202b10 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202690:	000bb783          	ld	a5,0(s7)
ffffffffc0202694:	779c                	ld	a5,40(a5)
ffffffffc0202696:	9782                	jalr	a5
ffffffffc0202698:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020269a:	6098                	ld	a4,0(s1)
ffffffffc020269c:	c80007b7          	lui	a5,0xc8000
ffffffffc02026a0:	83b1                	srli	a5,a5,0xc
ffffffffc02026a2:	5ee7e163          	bltu	a5,a4,ffffffffc0202c84 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026a6:	00093503          	ld	a0,0(s2)
ffffffffc02026aa:	5a050d63          	beqz	a0,ffffffffc0202c64 <pmm_init+0x70c>
ffffffffc02026ae:	03451793          	slli	a5,a0,0x34
ffffffffc02026b2:	5a079963          	bnez	a5,ffffffffc0202c64 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02026b6:	4601                	li	a2,0
ffffffffc02026b8:	4581                	li	a1,0
ffffffffc02026ba:	8e1ff0ef          	jal	ra,ffffffffc0201f9a <get_page>
ffffffffc02026be:	62051563          	bnez	a0,ffffffffc0202ce8 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02026c2:	4505                	li	a0,1
ffffffffc02026c4:	df8ff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc02026c8:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02026ca:	00093503          	ld	a0,0(s2)
ffffffffc02026ce:	4681                	li	a3,0
ffffffffc02026d0:	4601                	li	a2,0
ffffffffc02026d2:	85d2                	mv	a1,s4
ffffffffc02026d4:	d8fff0ef          	jal	ra,ffffffffc0202462 <page_insert>
ffffffffc02026d8:	5e051863          	bnez	a0,ffffffffc0202cc8 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02026dc:	00093503          	ld	a0,0(s2)
ffffffffc02026e0:	4601                	li	a2,0
ffffffffc02026e2:	4581                	li	a1,0
ffffffffc02026e4:	ee4ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc02026e8:	5c050063          	beqz	a0,ffffffffc0202ca8 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc02026ec:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02026ee:	0017f713          	andi	a4,a5,1
ffffffffc02026f2:	5a070963          	beqz	a4,ffffffffc0202ca4 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02026f6:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02026f8:	078a                	slli	a5,a5,0x2
ffffffffc02026fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026fc:	52e7fa63          	bgeu	a5,a4,ffffffffc0202c30 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202700:	000b3683          	ld	a3,0(s6)
ffffffffc0202704:	fff80637          	lui	a2,0xfff80
ffffffffc0202708:	97b2                	add	a5,a5,a2
ffffffffc020270a:	079a                	slli	a5,a5,0x6
ffffffffc020270c:	97b6                	add	a5,a5,a3
ffffffffc020270e:	10fa16e3          	bne	s4,a5,ffffffffc020301a <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0202712:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0202716:	4785                	li	a5,1
ffffffffc0202718:	12f69de3          	bne	a3,a5,ffffffffc0203052 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020271c:	00093503          	ld	a0,0(s2)
ffffffffc0202720:	77fd                	lui	a5,0xfffff
ffffffffc0202722:	6114                	ld	a3,0(a0)
ffffffffc0202724:	068a                	slli	a3,a3,0x2
ffffffffc0202726:	8efd                	and	a3,a3,a5
ffffffffc0202728:	00c6d613          	srli	a2,a3,0xc
ffffffffc020272c:	10e677e3          	bgeu	a2,a4,ffffffffc020303a <pmm_init+0xae2>
ffffffffc0202730:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202734:	96e2                	add	a3,a3,s8
ffffffffc0202736:	0006ba83          	ld	s5,0(a3)
ffffffffc020273a:	0a8a                	slli	s5,s5,0x2
ffffffffc020273c:	00fafab3          	and	s5,s5,a5
ffffffffc0202740:	00cad793          	srli	a5,s5,0xc
ffffffffc0202744:	62e7f263          	bgeu	a5,a4,ffffffffc0202d68 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202748:	4601                	li	a2,0
ffffffffc020274a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020274c:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020274e:	e7aff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202752:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202754:	5f551a63          	bne	a0,s5,ffffffffc0202d48 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0202758:	4505                	li	a0,1
ffffffffc020275a:	d62ff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc020275e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202760:	00093503          	ld	a0,0(s2)
ffffffffc0202764:	46d1                	li	a3,20
ffffffffc0202766:	6605                	lui	a2,0x1
ffffffffc0202768:	85d6                	mv	a1,s5
ffffffffc020276a:	cf9ff0ef          	jal	ra,ffffffffc0202462 <page_insert>
ffffffffc020276e:	58051d63          	bnez	a0,ffffffffc0202d08 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202772:	00093503          	ld	a0,0(s2)
ffffffffc0202776:	4601                	li	a2,0
ffffffffc0202778:	6585                	lui	a1,0x1
ffffffffc020277a:	e4eff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc020277e:	0e050ae3          	beqz	a0,ffffffffc0203072 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0202782:	611c                	ld	a5,0(a0)
ffffffffc0202784:	0107f713          	andi	a4,a5,16
ffffffffc0202788:	6e070d63          	beqz	a4,ffffffffc0202e82 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc020278c:	8b91                	andi	a5,a5,4
ffffffffc020278e:	6a078a63          	beqz	a5,ffffffffc0202e42 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202792:	00093503          	ld	a0,0(s2)
ffffffffc0202796:	611c                	ld	a5,0(a0)
ffffffffc0202798:	8bc1                	andi	a5,a5,16
ffffffffc020279a:	68078463          	beqz	a5,ffffffffc0202e22 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc020279e:	000aa703          	lw	a4,0(s5)
ffffffffc02027a2:	4785                	li	a5,1
ffffffffc02027a4:	58f71263          	bne	a4,a5,ffffffffc0202d28 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027a8:	4681                	li	a3,0
ffffffffc02027aa:	6605                	lui	a2,0x1
ffffffffc02027ac:	85d2                	mv	a1,s4
ffffffffc02027ae:	cb5ff0ef          	jal	ra,ffffffffc0202462 <page_insert>
ffffffffc02027b2:	62051863          	bnez	a0,ffffffffc0202de2 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02027b6:	000a2703          	lw	a4,0(s4)
ffffffffc02027ba:	4789                	li	a5,2
ffffffffc02027bc:	60f71363          	bne	a4,a5,ffffffffc0202dc2 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02027c0:	000aa783          	lw	a5,0(s5)
ffffffffc02027c4:	5c079f63          	bnez	a5,ffffffffc0202da2 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027c8:	00093503          	ld	a0,0(s2)
ffffffffc02027cc:	4601                	li	a2,0
ffffffffc02027ce:	6585                	lui	a1,0x1
ffffffffc02027d0:	df8ff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc02027d4:	5a050763          	beqz	a0,ffffffffc0202d82 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02027d8:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027da:	00177793          	andi	a5,a4,1
ffffffffc02027de:	4c078363          	beqz	a5,ffffffffc0202ca4 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02027e2:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027e4:	00271793          	slli	a5,a4,0x2
ffffffffc02027e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027ea:	44d7f363          	bgeu	a5,a3,ffffffffc0202c30 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02027ee:	000b3683          	ld	a3,0(s6)
ffffffffc02027f2:	fff80637          	lui	a2,0xfff80
ffffffffc02027f6:	97b2                	add	a5,a5,a2
ffffffffc02027f8:	079a                	slli	a5,a5,0x6
ffffffffc02027fa:	97b6                	add	a5,a5,a3
ffffffffc02027fc:	6efa1363          	bne	s4,a5,ffffffffc0202ee2 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202800:	8b41                	andi	a4,a4,16
ffffffffc0202802:	6c071063          	bnez	a4,ffffffffc0202ec2 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202806:	00093503          	ld	a0,0(s2)
ffffffffc020280a:	4581                	li	a1,0
ffffffffc020280c:	bbbff0ef          	jal	ra,ffffffffc02023c6 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202810:	000a2703          	lw	a4,0(s4)
ffffffffc0202814:	4785                	li	a5,1
ffffffffc0202816:	68f71663          	bne	a4,a5,ffffffffc0202ea2 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc020281a:	000aa783          	lw	a5,0(s5)
ffffffffc020281e:	74079e63          	bnez	a5,ffffffffc0202f7a <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202822:	00093503          	ld	a0,0(s2)
ffffffffc0202826:	6585                	lui	a1,0x1
ffffffffc0202828:	b9fff0ef          	jal	ra,ffffffffc02023c6 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020282c:	000a2783          	lw	a5,0(s4)
ffffffffc0202830:	72079563          	bnez	a5,ffffffffc0202f5a <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0202834:	000aa783          	lw	a5,0(s5)
ffffffffc0202838:	70079163          	bnez	a5,ffffffffc0202f3a <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020283c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202840:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202842:	000a3683          	ld	a3,0(s4)
ffffffffc0202846:	068a                	slli	a3,a3,0x2
ffffffffc0202848:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020284a:	3ee6f363          	bgeu	a3,a4,ffffffffc0202c30 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020284e:	fff807b7          	lui	a5,0xfff80
ffffffffc0202852:	000b3503          	ld	a0,0(s6)
ffffffffc0202856:	96be                	add	a3,a3,a5
ffffffffc0202858:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc020285a:	00d507b3          	add	a5,a0,a3
ffffffffc020285e:	4390                	lw	a2,0(a5)
ffffffffc0202860:	4785                	li	a5,1
ffffffffc0202862:	6af61c63          	bne	a2,a5,ffffffffc0202f1a <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0202866:	8699                	srai	a3,a3,0x6
ffffffffc0202868:	000805b7          	lui	a1,0x80
ffffffffc020286c:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020286e:	00c69613          	slli	a2,a3,0xc
ffffffffc0202872:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202874:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202876:	68e67663          	bgeu	a2,a4,ffffffffc0202f02 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020287a:	0009b603          	ld	a2,0(s3)
ffffffffc020287e:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0202880:	629c                	ld	a5,0(a3)
ffffffffc0202882:	078a                	slli	a5,a5,0x2
ffffffffc0202884:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202886:	3ae7f563          	bgeu	a5,a4,ffffffffc0202c30 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020288a:	8f8d                	sub	a5,a5,a1
ffffffffc020288c:	079a                	slli	a5,a5,0x6
ffffffffc020288e:	953e                	add	a0,a0,a5
ffffffffc0202890:	100027f3          	csrr	a5,sstatus
ffffffffc0202894:	8b89                	andi	a5,a5,2
ffffffffc0202896:	2c079763          	bnez	a5,ffffffffc0202b64 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc020289a:	000bb783          	ld	a5,0(s7)
ffffffffc020289e:	4585                	li	a1,1
ffffffffc02028a0:	739c                	ld	a5,32(a5)
ffffffffc02028a2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02028a4:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02028a8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028aa:	078a                	slli	a5,a5,0x2
ffffffffc02028ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028ae:	38e7f163          	bgeu	a5,a4,ffffffffc0202c30 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028b2:	000b3503          	ld	a0,0(s6)
ffffffffc02028b6:	fff80737          	lui	a4,0xfff80
ffffffffc02028ba:	97ba                	add	a5,a5,a4
ffffffffc02028bc:	079a                	slli	a5,a5,0x6
ffffffffc02028be:	953e                	add	a0,a0,a5
ffffffffc02028c0:	100027f3          	csrr	a5,sstatus
ffffffffc02028c4:	8b89                	andi	a5,a5,2
ffffffffc02028c6:	28079363          	bnez	a5,ffffffffc0202b4c <pmm_init+0x5f4>
ffffffffc02028ca:	000bb783          	ld	a5,0(s7)
ffffffffc02028ce:	4585                	li	a1,1
ffffffffc02028d0:	739c                	ld	a5,32(a5)
ffffffffc02028d2:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02028d4:	00093783          	ld	a5,0(s2)
ffffffffc02028d8:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd7a4>
  asm volatile("sfence.vma");
ffffffffc02028dc:	12000073          	sfence.vma
ffffffffc02028e0:	100027f3          	csrr	a5,sstatus
ffffffffc02028e4:	8b89                	andi	a5,a5,2
ffffffffc02028e6:	24079963          	bnez	a5,ffffffffc0202b38 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02028ea:	000bb783          	ld	a5,0(s7)
ffffffffc02028ee:	779c                	ld	a5,40(a5)
ffffffffc02028f0:	9782                	jalr	a5
ffffffffc02028f2:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02028f4:	71441363          	bne	s0,s4,ffffffffc0202ffa <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02028f8:	00004517          	auipc	a0,0x4
ffffffffc02028fc:	58050513          	addi	a0,a0,1408 # ffffffffc0206e78 <default_pmm_manager+0x500>
ffffffffc0202900:	881fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202904:	100027f3          	csrr	a5,sstatus
ffffffffc0202908:	8b89                	andi	a5,a5,2
ffffffffc020290a:	20079d63          	bnez	a5,ffffffffc0202b24 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc020290e:	000bb783          	ld	a5,0(s7)
ffffffffc0202912:	779c                	ld	a5,40(a5)
ffffffffc0202914:	9782                	jalr	a5
ffffffffc0202916:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202918:	6098                	ld	a4,0(s1)
ffffffffc020291a:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020291e:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202920:	00c71793          	slli	a5,a4,0xc
ffffffffc0202924:	6a05                	lui	s4,0x1
ffffffffc0202926:	02f47c63          	bgeu	s0,a5,ffffffffc020295e <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020292a:	00c45793          	srli	a5,s0,0xc
ffffffffc020292e:	00093503          	ld	a0,0(s2)
ffffffffc0202932:	2ee7f263          	bgeu	a5,a4,ffffffffc0202c16 <pmm_init+0x6be>
ffffffffc0202936:	0009b583          	ld	a1,0(s3)
ffffffffc020293a:	4601                	li	a2,0
ffffffffc020293c:	95a2                	add	a1,a1,s0
ffffffffc020293e:	c8aff0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc0202942:	2a050a63          	beqz	a0,ffffffffc0202bf6 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202946:	611c                	ld	a5,0(a0)
ffffffffc0202948:	078a                	slli	a5,a5,0x2
ffffffffc020294a:	0157f7b3          	and	a5,a5,s5
ffffffffc020294e:	28879463          	bne	a5,s0,ffffffffc0202bd6 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202952:	6098                	ld	a4,0(s1)
ffffffffc0202954:	9452                	add	s0,s0,s4
ffffffffc0202956:	00c71793          	slli	a5,a4,0xc
ffffffffc020295a:	fcf468e3          	bltu	s0,a5,ffffffffc020292a <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020295e:	00093783          	ld	a5,0(s2)
ffffffffc0202962:	639c                	ld	a5,0(a5)
ffffffffc0202964:	66079b63          	bnez	a5,ffffffffc0202fda <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0202968:	4505                	li	a0,1
ffffffffc020296a:	b52ff0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc020296e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202970:	00093503          	ld	a0,0(s2)
ffffffffc0202974:	4699                	li	a3,6
ffffffffc0202976:	10000613          	li	a2,256
ffffffffc020297a:	85d6                	mv	a1,s5
ffffffffc020297c:	ae7ff0ef          	jal	ra,ffffffffc0202462 <page_insert>
ffffffffc0202980:	62051d63          	bnez	a0,ffffffffc0202fba <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0202984:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c7a4>
ffffffffc0202988:	4785                	li	a5,1
ffffffffc020298a:	60f71863          	bne	a4,a5,ffffffffc0202f9a <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020298e:	00093503          	ld	a0,0(s2)
ffffffffc0202992:	6405                	lui	s0,0x1
ffffffffc0202994:	4699                	li	a3,6
ffffffffc0202996:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab0>
ffffffffc020299a:	85d6                	mv	a1,s5
ffffffffc020299c:	ac7ff0ef          	jal	ra,ffffffffc0202462 <page_insert>
ffffffffc02029a0:	46051163          	bnez	a0,ffffffffc0202e02 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02029a4:	000aa703          	lw	a4,0(s5)
ffffffffc02029a8:	4789                	li	a5,2
ffffffffc02029aa:	72f71463          	bne	a4,a5,ffffffffc02030d2 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02029ae:	00004597          	auipc	a1,0x4
ffffffffc02029b2:	60258593          	addi	a1,a1,1538 # ffffffffc0206fb0 <default_pmm_manager+0x638>
ffffffffc02029b6:	10000513          	li	a0,256
ffffffffc02029ba:	1f8030ef          	jal	ra,ffffffffc0205bb2 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02029be:	10040593          	addi	a1,s0,256
ffffffffc02029c2:	10000513          	li	a0,256
ffffffffc02029c6:	1fe030ef          	jal	ra,ffffffffc0205bc4 <strcmp>
ffffffffc02029ca:	6e051463          	bnez	a0,ffffffffc02030b2 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02029ce:	000b3683          	ld	a3,0(s6)
ffffffffc02029d2:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02029d6:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02029d8:	40da86b3          	sub	a3,s5,a3
ffffffffc02029dc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02029de:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02029e0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02029e2:	8031                	srli	s0,s0,0xc
ffffffffc02029e4:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02029e8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029ea:	50f77c63          	bgeu	a4,a5,ffffffffc0202f02 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02029ee:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02029f2:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02029f6:	96be                	add	a3,a3,a5
ffffffffc02029f8:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02029fc:	180030ef          	jal	ra,ffffffffc0205b7c <strlen>
ffffffffc0202a00:	68051963          	bnez	a0,ffffffffc0203092 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a04:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a08:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a0a:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0202a0e:	068a                	slli	a3,a3,0x2
ffffffffc0202a10:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a12:	20f6ff63          	bgeu	a3,a5,ffffffffc0202c30 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0202a16:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a18:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a1a:	4ef47463          	bgeu	s0,a5,ffffffffc0202f02 <pmm_init+0x9aa>
ffffffffc0202a1e:	0009b403          	ld	s0,0(s3)
ffffffffc0202a22:	9436                	add	s0,s0,a3
ffffffffc0202a24:	100027f3          	csrr	a5,sstatus
ffffffffc0202a28:	8b89                	andi	a5,a5,2
ffffffffc0202a2a:	18079b63          	bnez	a5,ffffffffc0202bc0 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0202a2e:	000bb783          	ld	a5,0(s7)
ffffffffc0202a32:	4585                	li	a1,1
ffffffffc0202a34:	8556                	mv	a0,s5
ffffffffc0202a36:	739c                	ld	a5,32(a5)
ffffffffc0202a38:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a3a:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a3c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a3e:	078a                	slli	a5,a5,0x2
ffffffffc0202a40:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a42:	1ee7f763          	bgeu	a5,a4,ffffffffc0202c30 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a46:	000b3503          	ld	a0,0(s6)
ffffffffc0202a4a:	fff80737          	lui	a4,0xfff80
ffffffffc0202a4e:	97ba                	add	a5,a5,a4
ffffffffc0202a50:	079a                	slli	a5,a5,0x6
ffffffffc0202a52:	953e                	add	a0,a0,a5
ffffffffc0202a54:	100027f3          	csrr	a5,sstatus
ffffffffc0202a58:	8b89                	andi	a5,a5,2
ffffffffc0202a5a:	14079763          	bnez	a5,ffffffffc0202ba8 <pmm_init+0x650>
ffffffffc0202a5e:	000bb783          	ld	a5,0(s7)
ffffffffc0202a62:	4585                	li	a1,1
ffffffffc0202a64:	739c                	ld	a5,32(a5)
ffffffffc0202a66:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a68:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a6c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a6e:	078a                	slli	a5,a5,0x2
ffffffffc0202a70:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a72:	1ae7ff63          	bgeu	a5,a4,ffffffffc0202c30 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a76:	000b3503          	ld	a0,0(s6)
ffffffffc0202a7a:	fff80737          	lui	a4,0xfff80
ffffffffc0202a7e:	97ba                	add	a5,a5,a4
ffffffffc0202a80:	079a                	slli	a5,a5,0x6
ffffffffc0202a82:	953e                	add	a0,a0,a5
ffffffffc0202a84:	100027f3          	csrr	a5,sstatus
ffffffffc0202a88:	8b89                	andi	a5,a5,2
ffffffffc0202a8a:	10079363          	bnez	a5,ffffffffc0202b90 <pmm_init+0x638>
ffffffffc0202a8e:	000bb783          	ld	a5,0(s7)
ffffffffc0202a92:	4585                	li	a1,1
ffffffffc0202a94:	739c                	ld	a5,32(a5)
ffffffffc0202a96:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202a98:	00093783          	ld	a5,0(s2)
ffffffffc0202a9c:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202aa0:	12000073          	sfence.vma
ffffffffc0202aa4:	100027f3          	csrr	a5,sstatus
ffffffffc0202aa8:	8b89                	andi	a5,a5,2
ffffffffc0202aaa:	0c079963          	bnez	a5,ffffffffc0202b7c <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202aae:	000bb783          	ld	a5,0(s7)
ffffffffc0202ab2:	779c                	ld	a5,40(a5)
ffffffffc0202ab4:	9782                	jalr	a5
ffffffffc0202ab6:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202ab8:	3a8c1563          	bne	s8,s0,ffffffffc0202e62 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202abc:	00004517          	auipc	a0,0x4
ffffffffc0202ac0:	56c50513          	addi	a0,a0,1388 # ffffffffc0207028 <default_pmm_manager+0x6b0>
ffffffffc0202ac4:	ebcfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202ac8:	6446                	ld	s0,80(sp)
ffffffffc0202aca:	60e6                	ld	ra,88(sp)
ffffffffc0202acc:	64a6                	ld	s1,72(sp)
ffffffffc0202ace:	6906                	ld	s2,64(sp)
ffffffffc0202ad0:	79e2                	ld	s3,56(sp)
ffffffffc0202ad2:	7a42                	ld	s4,48(sp)
ffffffffc0202ad4:	7aa2                	ld	s5,40(sp)
ffffffffc0202ad6:	7b02                	ld	s6,32(sp)
ffffffffc0202ad8:	6be2                	ld	s7,24(sp)
ffffffffc0202ada:	6c42                	ld	s8,16(sp)
ffffffffc0202adc:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202ade:	fddfe06f          	j	ffffffffc0201aba <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202ae2:	6785                	lui	a5,0x1
ffffffffc0202ae4:	17fd                	addi	a5,a5,-1
ffffffffc0202ae6:	96be                	add	a3,a3,a5
ffffffffc0202ae8:	77fd                	lui	a5,0xfffff
ffffffffc0202aea:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202aec:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202af0:	14c6f063          	bgeu	a3,a2,ffffffffc0202c30 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202af4:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202af8:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202afa:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202afe:	6a10                	ld	a2,16(a2)
ffffffffc0202b00:	069a                	slli	a3,a3,0x6
ffffffffc0202b02:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202b06:	9536                	add	a0,a0,a3
ffffffffc0202b08:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202b0a:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202b0e:	b63d                	j	ffffffffc020263c <pmm_init+0xe4>
        intr_disable();
ffffffffc0202b10:	b13fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b14:	000bb783          	ld	a5,0(s7)
ffffffffc0202b18:	779c                	ld	a5,40(a5)
ffffffffc0202b1a:	9782                	jalr	a5
ffffffffc0202b1c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b1e:	afffd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202b22:	bea5                	j	ffffffffc020269a <pmm_init+0x142>
        intr_disable();
ffffffffc0202b24:	afffd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202b28:	000bb783          	ld	a5,0(s7)
ffffffffc0202b2c:	779c                	ld	a5,40(a5)
ffffffffc0202b2e:	9782                	jalr	a5
ffffffffc0202b30:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202b32:	aebfd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202b36:	b3cd                	j	ffffffffc0202918 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202b38:	aebfd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202b3c:	000bb783          	ld	a5,0(s7)
ffffffffc0202b40:	779c                	ld	a5,40(a5)
ffffffffc0202b42:	9782                	jalr	a5
ffffffffc0202b44:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202b46:	ad7fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202b4a:	b36d                	j	ffffffffc02028f4 <pmm_init+0x39c>
ffffffffc0202b4c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b4e:	ad5fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b52:	000bb783          	ld	a5,0(s7)
ffffffffc0202b56:	6522                	ld	a0,8(sp)
ffffffffc0202b58:	4585                	li	a1,1
ffffffffc0202b5a:	739c                	ld	a5,32(a5)
ffffffffc0202b5c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b5e:	abffd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202b62:	bb8d                	j	ffffffffc02028d4 <pmm_init+0x37c>
ffffffffc0202b64:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b66:	abdfd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202b6a:	000bb783          	ld	a5,0(s7)
ffffffffc0202b6e:	6522                	ld	a0,8(sp)
ffffffffc0202b70:	4585                	li	a1,1
ffffffffc0202b72:	739c                	ld	a5,32(a5)
ffffffffc0202b74:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b76:	aa7fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202b7a:	b32d                	j	ffffffffc02028a4 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202b7c:	aa7fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b80:	000bb783          	ld	a5,0(s7)
ffffffffc0202b84:	779c                	ld	a5,40(a5)
ffffffffc0202b86:	9782                	jalr	a5
ffffffffc0202b88:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b8a:	a93fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202b8e:	b72d                	j	ffffffffc0202ab8 <pmm_init+0x560>
ffffffffc0202b90:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b92:	a91fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b96:	000bb783          	ld	a5,0(s7)
ffffffffc0202b9a:	6522                	ld	a0,8(sp)
ffffffffc0202b9c:	4585                	li	a1,1
ffffffffc0202b9e:	739c                	ld	a5,32(a5)
ffffffffc0202ba0:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ba2:	a7bfd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202ba6:	bdcd                	j	ffffffffc0202a98 <pmm_init+0x540>
ffffffffc0202ba8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202baa:	a79fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202bae:	000bb783          	ld	a5,0(s7)
ffffffffc0202bb2:	6522                	ld	a0,8(sp)
ffffffffc0202bb4:	4585                	li	a1,1
ffffffffc0202bb6:	739c                	ld	a5,32(a5)
ffffffffc0202bb8:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bba:	a63fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202bbe:	b56d                	j	ffffffffc0202a68 <pmm_init+0x510>
        intr_disable();
ffffffffc0202bc0:	a63fd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
ffffffffc0202bc4:	000bb783          	ld	a5,0(s7)
ffffffffc0202bc8:	4585                	li	a1,1
ffffffffc0202bca:	8556                	mv	a0,s5
ffffffffc0202bcc:	739c                	ld	a5,32(a5)
ffffffffc0202bce:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bd0:	a4dfd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0202bd4:	b59d                	j	ffffffffc0202a3a <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bd6:	00004697          	auipc	a3,0x4
ffffffffc0202bda:	30268693          	addi	a3,a3,770 # ffffffffc0206ed8 <default_pmm_manager+0x560>
ffffffffc0202bde:	00003617          	auipc	a2,0x3
ffffffffc0202be2:	70260613          	addi	a2,a2,1794 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202be6:	22800593          	li	a1,552
ffffffffc0202bea:	00004517          	auipc	a0,0x4
ffffffffc0202bee:	ede50513          	addi	a0,a0,-290 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202bf2:	889fd0ef          	jal	ra,ffffffffc020047a <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202bf6:	00004697          	auipc	a3,0x4
ffffffffc0202bfa:	2a268693          	addi	a3,a3,674 # ffffffffc0206e98 <default_pmm_manager+0x520>
ffffffffc0202bfe:	00003617          	auipc	a2,0x3
ffffffffc0202c02:	6e260613          	addi	a2,a2,1762 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202c06:	22700593          	li	a1,551
ffffffffc0202c0a:	00004517          	auipc	a0,0x4
ffffffffc0202c0e:	ebe50513          	addi	a0,a0,-322 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202c12:	869fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c16:	86a2                	mv	a3,s0
ffffffffc0202c18:	00004617          	auipc	a2,0x4
ffffffffc0202c1c:	d9860613          	addi	a2,a2,-616 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0202c20:	22700593          	li	a1,551
ffffffffc0202c24:	00004517          	auipc	a0,0x4
ffffffffc0202c28:	ea450513          	addi	a0,a0,-348 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202c2c:	84ffd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c30:	854ff0ef          	jal	ra,ffffffffc0201c84 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c34:	00004617          	auipc	a2,0x4
ffffffffc0202c38:	e2460613          	addi	a2,a2,-476 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0202c3c:	07f00593          	li	a1,127
ffffffffc0202c40:	00004517          	auipc	a0,0x4
ffffffffc0202c44:	e8850513          	addi	a0,a0,-376 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202c48:	833fd0ef          	jal	ra,ffffffffc020047a <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202c4c:	00004617          	auipc	a2,0x4
ffffffffc0202c50:	e0c60613          	addi	a2,a2,-500 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0202c54:	0c100593          	li	a1,193
ffffffffc0202c58:	00004517          	auipc	a0,0x4
ffffffffc0202c5c:	e7050513          	addi	a0,a0,-400 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202c60:	81bfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c64:	00004697          	auipc	a3,0x4
ffffffffc0202c68:	f6c68693          	addi	a3,a3,-148 # ffffffffc0206bd0 <default_pmm_manager+0x258>
ffffffffc0202c6c:	00003617          	auipc	a2,0x3
ffffffffc0202c70:	67460613          	addi	a2,a2,1652 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202c74:	1eb00593          	li	a1,491
ffffffffc0202c78:	00004517          	auipc	a0,0x4
ffffffffc0202c7c:	e5050513          	addi	a0,a0,-432 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202c80:	ffafd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202c84:	00004697          	auipc	a3,0x4
ffffffffc0202c88:	f2c68693          	addi	a3,a3,-212 # ffffffffc0206bb0 <default_pmm_manager+0x238>
ffffffffc0202c8c:	00003617          	auipc	a2,0x3
ffffffffc0202c90:	65460613          	addi	a2,a2,1620 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202c94:	1ea00593          	li	a1,490
ffffffffc0202c98:	00004517          	auipc	a0,0x4
ffffffffc0202c9c:	e3050513          	addi	a0,a0,-464 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202ca0:	fdafd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202ca4:	ffdfe0ef          	jal	ra,ffffffffc0201ca0 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202ca8:	00004697          	auipc	a3,0x4
ffffffffc0202cac:	fb868693          	addi	a3,a3,-72 # ffffffffc0206c60 <default_pmm_manager+0x2e8>
ffffffffc0202cb0:	00003617          	auipc	a2,0x3
ffffffffc0202cb4:	63060613          	addi	a2,a2,1584 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202cb8:	1f300593          	li	a1,499
ffffffffc0202cbc:	00004517          	auipc	a0,0x4
ffffffffc0202cc0:	e0c50513          	addi	a0,a0,-500 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202cc4:	fb6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202cc8:	00004697          	auipc	a3,0x4
ffffffffc0202ccc:	f6868693          	addi	a3,a3,-152 # ffffffffc0206c30 <default_pmm_manager+0x2b8>
ffffffffc0202cd0:	00003617          	auipc	a2,0x3
ffffffffc0202cd4:	61060613          	addi	a2,a2,1552 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202cd8:	1f000593          	li	a1,496
ffffffffc0202cdc:	00004517          	auipc	a0,0x4
ffffffffc0202ce0:	dec50513          	addi	a0,a0,-532 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202ce4:	f96fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202ce8:	00004697          	auipc	a3,0x4
ffffffffc0202cec:	f2068693          	addi	a3,a3,-224 # ffffffffc0206c08 <default_pmm_manager+0x290>
ffffffffc0202cf0:	00003617          	auipc	a2,0x3
ffffffffc0202cf4:	5f060613          	addi	a2,a2,1520 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202cf8:	1ec00593          	li	a1,492
ffffffffc0202cfc:	00004517          	auipc	a0,0x4
ffffffffc0202d00:	dcc50513          	addi	a0,a0,-564 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202d04:	f76fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d08:	00004697          	auipc	a3,0x4
ffffffffc0202d0c:	fe068693          	addi	a3,a3,-32 # ffffffffc0206ce8 <default_pmm_manager+0x370>
ffffffffc0202d10:	00003617          	auipc	a2,0x3
ffffffffc0202d14:	5d060613          	addi	a2,a2,1488 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202d18:	1fc00593          	li	a1,508
ffffffffc0202d1c:	00004517          	auipc	a0,0x4
ffffffffc0202d20:	dac50513          	addi	a0,a0,-596 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202d24:	f56fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202d28:	00004697          	auipc	a3,0x4
ffffffffc0202d2c:	06068693          	addi	a3,a3,96 # ffffffffc0206d88 <default_pmm_manager+0x410>
ffffffffc0202d30:	00003617          	auipc	a2,0x3
ffffffffc0202d34:	5b060613          	addi	a2,a2,1456 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202d38:	20100593          	li	a1,513
ffffffffc0202d3c:	00004517          	auipc	a0,0x4
ffffffffc0202d40:	d8c50513          	addi	a0,a0,-628 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202d44:	f36fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d48:	00004697          	auipc	a3,0x4
ffffffffc0202d4c:	f7868693          	addi	a3,a3,-136 # ffffffffc0206cc0 <default_pmm_manager+0x348>
ffffffffc0202d50:	00003617          	auipc	a2,0x3
ffffffffc0202d54:	59060613          	addi	a2,a2,1424 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202d58:	1f900593          	li	a1,505
ffffffffc0202d5c:	00004517          	auipc	a0,0x4
ffffffffc0202d60:	d6c50513          	addi	a0,a0,-660 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202d64:	f16fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d68:	86d6                	mv	a3,s5
ffffffffc0202d6a:	00004617          	auipc	a2,0x4
ffffffffc0202d6e:	c4660613          	addi	a2,a2,-954 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0202d72:	1f800593          	li	a1,504
ffffffffc0202d76:	00004517          	auipc	a0,0x4
ffffffffc0202d7a:	d5250513          	addi	a0,a0,-686 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202d7e:	efcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d82:	00004697          	auipc	a3,0x4
ffffffffc0202d86:	f9e68693          	addi	a3,a3,-98 # ffffffffc0206d20 <default_pmm_manager+0x3a8>
ffffffffc0202d8a:	00003617          	auipc	a2,0x3
ffffffffc0202d8e:	55660613          	addi	a2,a2,1366 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202d92:	20600593          	li	a1,518
ffffffffc0202d96:	00004517          	auipc	a0,0x4
ffffffffc0202d9a:	d3250513          	addi	a0,a0,-718 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202d9e:	edcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202da2:	00004697          	auipc	a3,0x4
ffffffffc0202da6:	04668693          	addi	a3,a3,70 # ffffffffc0206de8 <default_pmm_manager+0x470>
ffffffffc0202daa:	00003617          	auipc	a2,0x3
ffffffffc0202dae:	53660613          	addi	a2,a2,1334 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202db2:	20500593          	li	a1,517
ffffffffc0202db6:	00004517          	auipc	a0,0x4
ffffffffc0202dba:	d1250513          	addi	a0,a0,-750 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202dbe:	ebcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202dc2:	00004697          	auipc	a3,0x4
ffffffffc0202dc6:	00e68693          	addi	a3,a3,14 # ffffffffc0206dd0 <default_pmm_manager+0x458>
ffffffffc0202dca:	00003617          	auipc	a2,0x3
ffffffffc0202dce:	51660613          	addi	a2,a2,1302 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202dd2:	20400593          	li	a1,516
ffffffffc0202dd6:	00004517          	auipc	a0,0x4
ffffffffc0202dda:	cf250513          	addi	a0,a0,-782 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202dde:	e9cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202de2:	00004697          	auipc	a3,0x4
ffffffffc0202de6:	fbe68693          	addi	a3,a3,-66 # ffffffffc0206da0 <default_pmm_manager+0x428>
ffffffffc0202dea:	00003617          	auipc	a2,0x3
ffffffffc0202dee:	4f660613          	addi	a2,a2,1270 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202df2:	20300593          	li	a1,515
ffffffffc0202df6:	00004517          	auipc	a0,0x4
ffffffffc0202dfa:	cd250513          	addi	a0,a0,-814 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202dfe:	e7cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e02:	00004697          	auipc	a3,0x4
ffffffffc0202e06:	15668693          	addi	a3,a3,342 # ffffffffc0206f58 <default_pmm_manager+0x5e0>
ffffffffc0202e0a:	00003617          	auipc	a2,0x3
ffffffffc0202e0e:	4d660613          	addi	a2,a2,1238 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202e12:	23200593          	li	a1,562
ffffffffc0202e16:	00004517          	auipc	a0,0x4
ffffffffc0202e1a:	cb250513          	addi	a0,a0,-846 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202e1e:	e5cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202e22:	00004697          	auipc	a3,0x4
ffffffffc0202e26:	f4e68693          	addi	a3,a3,-178 # ffffffffc0206d70 <default_pmm_manager+0x3f8>
ffffffffc0202e2a:	00003617          	auipc	a2,0x3
ffffffffc0202e2e:	4b660613          	addi	a2,a2,1206 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202e32:	20000593          	li	a1,512
ffffffffc0202e36:	00004517          	auipc	a0,0x4
ffffffffc0202e3a:	c9250513          	addi	a0,a0,-878 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202e3e:	e3cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e42:	00004697          	auipc	a3,0x4
ffffffffc0202e46:	f1e68693          	addi	a3,a3,-226 # ffffffffc0206d60 <default_pmm_manager+0x3e8>
ffffffffc0202e4a:	00003617          	auipc	a2,0x3
ffffffffc0202e4e:	49660613          	addi	a2,a2,1174 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202e52:	1ff00593          	li	a1,511
ffffffffc0202e56:	00004517          	auipc	a0,0x4
ffffffffc0202e5a:	c7250513          	addi	a0,a0,-910 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202e5e:	e1cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202e62:	00004697          	auipc	a3,0x4
ffffffffc0202e66:	ff668693          	addi	a3,a3,-10 # ffffffffc0206e58 <default_pmm_manager+0x4e0>
ffffffffc0202e6a:	00003617          	auipc	a2,0x3
ffffffffc0202e6e:	47660613          	addi	a2,a2,1142 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202e72:	24300593          	li	a1,579
ffffffffc0202e76:	00004517          	auipc	a0,0x4
ffffffffc0202e7a:	c5250513          	addi	a0,a0,-942 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202e7e:	dfcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202e82:	00004697          	auipc	a3,0x4
ffffffffc0202e86:	ece68693          	addi	a3,a3,-306 # ffffffffc0206d50 <default_pmm_manager+0x3d8>
ffffffffc0202e8a:	00003617          	auipc	a2,0x3
ffffffffc0202e8e:	45660613          	addi	a2,a2,1110 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202e92:	1fe00593          	li	a1,510
ffffffffc0202e96:	00004517          	auipc	a0,0x4
ffffffffc0202e9a:	c3250513          	addi	a0,a0,-974 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202e9e:	ddcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ea2:	00004697          	auipc	a3,0x4
ffffffffc0202ea6:	e0668693          	addi	a3,a3,-506 # ffffffffc0206ca8 <default_pmm_manager+0x330>
ffffffffc0202eaa:	00003617          	auipc	a2,0x3
ffffffffc0202eae:	43660613          	addi	a2,a2,1078 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202eb2:	20b00593          	li	a1,523
ffffffffc0202eb6:	00004517          	auipc	a0,0x4
ffffffffc0202eba:	c1250513          	addi	a0,a0,-1006 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202ebe:	dbcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ec2:	00004697          	auipc	a3,0x4
ffffffffc0202ec6:	f3e68693          	addi	a3,a3,-194 # ffffffffc0206e00 <default_pmm_manager+0x488>
ffffffffc0202eca:	00003617          	auipc	a2,0x3
ffffffffc0202ece:	41660613          	addi	a2,a2,1046 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202ed2:	20800593          	li	a1,520
ffffffffc0202ed6:	00004517          	auipc	a0,0x4
ffffffffc0202eda:	bf250513          	addi	a0,a0,-1038 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202ede:	d9cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202ee2:	00004697          	auipc	a3,0x4
ffffffffc0202ee6:	dae68693          	addi	a3,a3,-594 # ffffffffc0206c90 <default_pmm_manager+0x318>
ffffffffc0202eea:	00003617          	auipc	a2,0x3
ffffffffc0202eee:	3f660613          	addi	a2,a2,1014 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202ef2:	20700593          	li	a1,519
ffffffffc0202ef6:	00004517          	auipc	a0,0x4
ffffffffc0202efa:	bd250513          	addi	a0,a0,-1070 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202efe:	d7cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f02:	00004617          	auipc	a2,0x4
ffffffffc0202f06:	aae60613          	addi	a2,a2,-1362 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0202f0a:	06900593          	li	a1,105
ffffffffc0202f0e:	00004517          	auipc	a0,0x4
ffffffffc0202f12:	aca50513          	addi	a0,a0,-1334 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0202f16:	d64fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202f1a:	00004697          	auipc	a3,0x4
ffffffffc0202f1e:	f1668693          	addi	a3,a3,-234 # ffffffffc0206e30 <default_pmm_manager+0x4b8>
ffffffffc0202f22:	00003617          	auipc	a2,0x3
ffffffffc0202f26:	3be60613          	addi	a2,a2,958 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202f2a:	21200593          	li	a1,530
ffffffffc0202f2e:	00004517          	auipc	a0,0x4
ffffffffc0202f32:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202f36:	d44fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f3a:	00004697          	auipc	a3,0x4
ffffffffc0202f3e:	eae68693          	addi	a3,a3,-338 # ffffffffc0206de8 <default_pmm_manager+0x470>
ffffffffc0202f42:	00003617          	auipc	a2,0x3
ffffffffc0202f46:	39e60613          	addi	a2,a2,926 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202f4a:	21000593          	li	a1,528
ffffffffc0202f4e:	00004517          	auipc	a0,0x4
ffffffffc0202f52:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202f56:	d24fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f5a:	00004697          	auipc	a3,0x4
ffffffffc0202f5e:	ebe68693          	addi	a3,a3,-322 # ffffffffc0206e18 <default_pmm_manager+0x4a0>
ffffffffc0202f62:	00003617          	auipc	a2,0x3
ffffffffc0202f66:	37e60613          	addi	a2,a2,894 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202f6a:	20f00593          	li	a1,527
ffffffffc0202f6e:	00004517          	auipc	a0,0x4
ffffffffc0202f72:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202f76:	d04fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f7a:	00004697          	auipc	a3,0x4
ffffffffc0202f7e:	e6e68693          	addi	a3,a3,-402 # ffffffffc0206de8 <default_pmm_manager+0x470>
ffffffffc0202f82:	00003617          	auipc	a2,0x3
ffffffffc0202f86:	35e60613          	addi	a2,a2,862 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202f8a:	20c00593          	li	a1,524
ffffffffc0202f8e:	00004517          	auipc	a0,0x4
ffffffffc0202f92:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202f96:	ce4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202f9a:	00004697          	auipc	a3,0x4
ffffffffc0202f9e:	fa668693          	addi	a3,a3,-90 # ffffffffc0206f40 <default_pmm_manager+0x5c8>
ffffffffc0202fa2:	00003617          	auipc	a2,0x3
ffffffffc0202fa6:	33e60613          	addi	a2,a2,830 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202faa:	23100593          	li	a1,561
ffffffffc0202fae:	00004517          	auipc	a0,0x4
ffffffffc0202fb2:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202fb6:	cc4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202fba:	00004697          	auipc	a3,0x4
ffffffffc0202fbe:	f4e68693          	addi	a3,a3,-178 # ffffffffc0206f08 <default_pmm_manager+0x590>
ffffffffc0202fc2:	00003617          	auipc	a2,0x3
ffffffffc0202fc6:	31e60613          	addi	a2,a2,798 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202fca:	23000593          	li	a1,560
ffffffffc0202fce:	00004517          	auipc	a0,0x4
ffffffffc0202fd2:	afa50513          	addi	a0,a0,-1286 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202fd6:	ca4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202fda:	00004697          	auipc	a3,0x4
ffffffffc0202fde:	f1668693          	addi	a3,a3,-234 # ffffffffc0206ef0 <default_pmm_manager+0x578>
ffffffffc0202fe2:	00003617          	auipc	a2,0x3
ffffffffc0202fe6:	2fe60613          	addi	a2,a2,766 # ffffffffc02062e0 <commands+0x450>
ffffffffc0202fea:	22c00593          	li	a1,556
ffffffffc0202fee:	00004517          	auipc	a0,0x4
ffffffffc0202ff2:	ada50513          	addi	a0,a0,-1318 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0202ff6:	c84fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202ffa:	00004697          	auipc	a3,0x4
ffffffffc0202ffe:	e5e68693          	addi	a3,a3,-418 # ffffffffc0206e58 <default_pmm_manager+0x4e0>
ffffffffc0203002:	00003617          	auipc	a2,0x3
ffffffffc0203006:	2de60613          	addi	a2,a2,734 # ffffffffc02062e0 <commands+0x450>
ffffffffc020300a:	21a00593          	li	a1,538
ffffffffc020300e:	00004517          	auipc	a0,0x4
ffffffffc0203012:	aba50513          	addi	a0,a0,-1350 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203016:	c64fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020301a:	00004697          	auipc	a3,0x4
ffffffffc020301e:	c7668693          	addi	a3,a3,-906 # ffffffffc0206c90 <default_pmm_manager+0x318>
ffffffffc0203022:	00003617          	auipc	a2,0x3
ffffffffc0203026:	2be60613          	addi	a2,a2,702 # ffffffffc02062e0 <commands+0x450>
ffffffffc020302a:	1f400593          	li	a1,500
ffffffffc020302e:	00004517          	auipc	a0,0x4
ffffffffc0203032:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc0203036:	c44fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020303a:	00004617          	auipc	a2,0x4
ffffffffc020303e:	97660613          	addi	a2,a2,-1674 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0203042:	1f700593          	li	a1,503
ffffffffc0203046:	00004517          	auipc	a0,0x4
ffffffffc020304a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020304e:	c2cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203052:	00004697          	auipc	a3,0x4
ffffffffc0203056:	c5668693          	addi	a3,a3,-938 # ffffffffc0206ca8 <default_pmm_manager+0x330>
ffffffffc020305a:	00003617          	auipc	a2,0x3
ffffffffc020305e:	28660613          	addi	a2,a2,646 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203062:	1f500593          	li	a1,501
ffffffffc0203066:	00004517          	auipc	a0,0x4
ffffffffc020306a:	a6250513          	addi	a0,a0,-1438 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020306e:	c0cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203072:	00004697          	auipc	a3,0x4
ffffffffc0203076:	cae68693          	addi	a3,a3,-850 # ffffffffc0206d20 <default_pmm_manager+0x3a8>
ffffffffc020307a:	00003617          	auipc	a2,0x3
ffffffffc020307e:	26660613          	addi	a2,a2,614 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203082:	1fd00593          	li	a1,509
ffffffffc0203086:	00004517          	auipc	a0,0x4
ffffffffc020308a:	a4250513          	addi	a0,a0,-1470 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc020308e:	becfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203092:	00004697          	auipc	a3,0x4
ffffffffc0203096:	f6e68693          	addi	a3,a3,-146 # ffffffffc0207000 <default_pmm_manager+0x688>
ffffffffc020309a:	00003617          	auipc	a2,0x3
ffffffffc020309e:	24660613          	addi	a2,a2,582 # ffffffffc02062e0 <commands+0x450>
ffffffffc02030a2:	23a00593          	li	a1,570
ffffffffc02030a6:	00004517          	auipc	a0,0x4
ffffffffc02030aa:	a2250513          	addi	a0,a0,-1502 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02030ae:	bccfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02030b2:	00004697          	auipc	a3,0x4
ffffffffc02030b6:	f1668693          	addi	a3,a3,-234 # ffffffffc0206fc8 <default_pmm_manager+0x650>
ffffffffc02030ba:	00003617          	auipc	a2,0x3
ffffffffc02030be:	22660613          	addi	a2,a2,550 # ffffffffc02062e0 <commands+0x450>
ffffffffc02030c2:	23700593          	li	a1,567
ffffffffc02030c6:	00004517          	auipc	a0,0x4
ffffffffc02030ca:	a0250513          	addi	a0,a0,-1534 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02030ce:	bacfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 2);
ffffffffc02030d2:	00004697          	auipc	a3,0x4
ffffffffc02030d6:	ec668693          	addi	a3,a3,-314 # ffffffffc0206f98 <default_pmm_manager+0x620>
ffffffffc02030da:	00003617          	auipc	a2,0x3
ffffffffc02030de:	20660613          	addi	a2,a2,518 # ffffffffc02062e0 <commands+0x450>
ffffffffc02030e2:	23300593          	li	a1,563
ffffffffc02030e6:	00004517          	auipc	a0,0x4
ffffffffc02030ea:	9e250513          	addi	a0,a0,-1566 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02030ee:	b8cfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02030f2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02030f2:	12058073          	sfence.vma	a1
}
ffffffffc02030f6:	8082                	ret

ffffffffc02030f8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02030f8:	7179                	addi	sp,sp,-48
ffffffffc02030fa:	e84a                	sd	s2,16(sp)
ffffffffc02030fc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02030fe:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203100:	f022                	sd	s0,32(sp)
ffffffffc0203102:	ec26                	sd	s1,24(sp)
ffffffffc0203104:	e44e                	sd	s3,8(sp)
ffffffffc0203106:	f406                	sd	ra,40(sp)
ffffffffc0203108:	84ae                	mv	s1,a1
ffffffffc020310a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020310c:	bb1fe0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0203110:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203112:	cd05                	beqz	a0,ffffffffc020314a <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203114:	85aa                	mv	a1,a0
ffffffffc0203116:	86ce                	mv	a3,s3
ffffffffc0203118:	8626                	mv	a2,s1
ffffffffc020311a:	854a                	mv	a0,s2
ffffffffc020311c:	b46ff0ef          	jal	ra,ffffffffc0202462 <page_insert>
ffffffffc0203120:	ed0d                	bnez	a0,ffffffffc020315a <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0203122:	000af797          	auipc	a5,0xaf
ffffffffc0203126:	7067a783          	lw	a5,1798(a5) # ffffffffc02b2828 <swap_init_ok>
ffffffffc020312a:	c385                	beqz	a5,ffffffffc020314a <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc020312c:	000af517          	auipc	a0,0xaf
ffffffffc0203130:	70453503          	ld	a0,1796(a0) # ffffffffc02b2830 <check_mm_struct>
ffffffffc0203134:	c919                	beqz	a0,ffffffffc020314a <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203136:	4681                	li	a3,0
ffffffffc0203138:	8622                	mv	a2,s0
ffffffffc020313a:	85a6                	mv	a1,s1
ffffffffc020313c:	7e4000ef          	jal	ra,ffffffffc0203920 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203140:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203142:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203144:	4785                	li	a5,1
ffffffffc0203146:	04f71663          	bne	a4,a5,ffffffffc0203192 <pgdir_alloc_page+0x9a>
}
ffffffffc020314a:	70a2                	ld	ra,40(sp)
ffffffffc020314c:	8522                	mv	a0,s0
ffffffffc020314e:	7402                	ld	s0,32(sp)
ffffffffc0203150:	64e2                	ld	s1,24(sp)
ffffffffc0203152:	6942                	ld	s2,16(sp)
ffffffffc0203154:	69a2                	ld	s3,8(sp)
ffffffffc0203156:	6145                	addi	sp,sp,48
ffffffffc0203158:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020315a:	100027f3          	csrr	a5,sstatus
ffffffffc020315e:	8b89                	andi	a5,a5,2
ffffffffc0203160:	eb99                	bnez	a5,ffffffffc0203176 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0203162:	000af797          	auipc	a5,0xaf
ffffffffc0203166:	6a67b783          	ld	a5,1702(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc020316a:	739c                	ld	a5,32(a5)
ffffffffc020316c:	8522                	mv	a0,s0
ffffffffc020316e:	4585                	li	a1,1
ffffffffc0203170:	9782                	jalr	a5
            return NULL;
ffffffffc0203172:	4401                	li	s0,0
ffffffffc0203174:	bfd9                	j	ffffffffc020314a <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0203176:	cacfd0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020317a:	000af797          	auipc	a5,0xaf
ffffffffc020317e:	68e7b783          	ld	a5,1678(a5) # ffffffffc02b2808 <pmm_manager>
ffffffffc0203182:	739c                	ld	a5,32(a5)
ffffffffc0203184:	8522                	mv	a0,s0
ffffffffc0203186:	4585                	li	a1,1
ffffffffc0203188:	9782                	jalr	a5
            return NULL;
ffffffffc020318a:	4401                	li	s0,0
        intr_enable();
ffffffffc020318c:	c90fd0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0203190:	bf6d                	j	ffffffffc020314a <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0203192:	00004697          	auipc	a3,0x4
ffffffffc0203196:	eb668693          	addi	a3,a3,-330 # ffffffffc0207048 <default_pmm_manager+0x6d0>
ffffffffc020319a:	00003617          	auipc	a2,0x3
ffffffffc020319e:	14660613          	addi	a2,a2,326 # ffffffffc02062e0 <commands+0x450>
ffffffffc02031a2:	1cb00593          	li	a1,459
ffffffffc02031a6:	00004517          	auipc	a0,0x4
ffffffffc02031aa:	92250513          	addi	a0,a0,-1758 # ffffffffc0206ac8 <default_pmm_manager+0x150>
ffffffffc02031ae:	accfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02031b2 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02031b2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02031b4:	00004617          	auipc	a2,0x4
ffffffffc02031b8:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc02031bc:	06200593          	li	a1,98
ffffffffc02031c0:	00004517          	auipc	a0,0x4
ffffffffc02031c4:	81850513          	addi	a0,a0,-2024 # ffffffffc02069d8 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc02031c8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02031ca:	ab0fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02031ce <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02031ce:	7135                	addi	sp,sp,-160
ffffffffc02031d0:	ed06                	sd	ra,152(sp)
ffffffffc02031d2:	e922                	sd	s0,144(sp)
ffffffffc02031d4:	e526                	sd	s1,136(sp)
ffffffffc02031d6:	e14a                	sd	s2,128(sp)
ffffffffc02031d8:	fcce                	sd	s3,120(sp)
ffffffffc02031da:	f8d2                	sd	s4,112(sp)
ffffffffc02031dc:	f4d6                	sd	s5,104(sp)
ffffffffc02031de:	f0da                	sd	s6,96(sp)
ffffffffc02031e0:	ecde                	sd	s7,88(sp)
ffffffffc02031e2:	e8e2                	sd	s8,80(sp)
ffffffffc02031e4:	e4e6                	sd	s9,72(sp)
ffffffffc02031e6:	e0ea                	sd	s10,64(sp)
ffffffffc02031e8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02031ea:	5f6010ef          	jal	ra,ffffffffc02047e0 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02031ee:	000af697          	auipc	a3,0xaf
ffffffffc02031f2:	62a6b683          	ld	a3,1578(a3) # ffffffffc02b2818 <max_swap_offset>
ffffffffc02031f6:	010007b7          	lui	a5,0x1000
ffffffffc02031fa:	ff968713          	addi	a4,a3,-7
ffffffffc02031fe:	17e1                	addi	a5,a5,-8
ffffffffc0203200:	42e7e663          	bltu	a5,a4,ffffffffc020362c <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203204:	000a4797          	auipc	a5,0xa4
ffffffffc0203208:	0b478793          	addi	a5,a5,180 # ffffffffc02a72b8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020320c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020320e:	000afb97          	auipc	s7,0xaf
ffffffffc0203212:	612b8b93          	addi	s7,s7,1554 # ffffffffc02b2820 <sm>
ffffffffc0203216:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc020321a:	9702                	jalr	a4
ffffffffc020321c:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020321e:	c10d                	beqz	a0,ffffffffc0203240 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0203220:	60ea                	ld	ra,152(sp)
ffffffffc0203222:	644a                	ld	s0,144(sp)
ffffffffc0203224:	64aa                	ld	s1,136(sp)
ffffffffc0203226:	79e6                	ld	s3,120(sp)
ffffffffc0203228:	7a46                	ld	s4,112(sp)
ffffffffc020322a:	7aa6                	ld	s5,104(sp)
ffffffffc020322c:	7b06                	ld	s6,96(sp)
ffffffffc020322e:	6be6                	ld	s7,88(sp)
ffffffffc0203230:	6c46                	ld	s8,80(sp)
ffffffffc0203232:	6ca6                	ld	s9,72(sp)
ffffffffc0203234:	6d06                	ld	s10,64(sp)
ffffffffc0203236:	7de2                	ld	s11,56(sp)
ffffffffc0203238:	854a                	mv	a0,s2
ffffffffc020323a:	690a                	ld	s2,128(sp)
ffffffffc020323c:	610d                	addi	sp,sp,160
ffffffffc020323e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203240:	000bb783          	ld	a5,0(s7)
ffffffffc0203244:	00004517          	auipc	a0,0x4
ffffffffc0203248:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207090 <default_pmm_manager+0x718>
    return listelm->next;
ffffffffc020324c:	000ab417          	auipc	s0,0xab
ffffffffc0203250:	4b440413          	addi	s0,s0,1204 # ffffffffc02ae700 <free_area>
ffffffffc0203254:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203256:	4785                	li	a5,1
ffffffffc0203258:	000af717          	auipc	a4,0xaf
ffffffffc020325c:	5cf72823          	sw	a5,1488(a4) # ffffffffc02b2828 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203260:	f21fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203264:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0203266:	4d01                	li	s10,0
ffffffffc0203268:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020326a:	34878163          	beq	a5,s0,ffffffffc02035ac <swap_init+0x3de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020326e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203272:	8b09                	andi	a4,a4,2
ffffffffc0203274:	32070e63          	beqz	a4,ffffffffc02035b0 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203278:	ff87a703          	lw	a4,-8(a5)
ffffffffc020327c:	679c                	ld	a5,8(a5)
ffffffffc020327e:	2d85                	addiw	s11,s11,1
ffffffffc0203280:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203284:	fe8795e3          	bne	a5,s0,ffffffffc020326e <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0203288:	84ea                	mv	s1,s10
ffffffffc020328a:	b05fe0ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
ffffffffc020328e:	42951763          	bne	a0,s1,ffffffffc02036bc <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203292:	866a                	mv	a2,s10
ffffffffc0203294:	85ee                	mv	a1,s11
ffffffffc0203296:	00004517          	auipc	a0,0x4
ffffffffc020329a:	e1250513          	addi	a0,a0,-494 # ffffffffc02070a8 <default_pmm_manager+0x730>
ffffffffc020329e:	ee3fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02032a2:	3b1000ef          	jal	ra,ffffffffc0203e52 <mm_create>
ffffffffc02032a6:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02032a8:	46050a63          	beqz	a0,ffffffffc020371c <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02032ac:	000af797          	auipc	a5,0xaf
ffffffffc02032b0:	58478793          	addi	a5,a5,1412 # ffffffffc02b2830 <check_mm_struct>
ffffffffc02032b4:	6398                	ld	a4,0(a5)
ffffffffc02032b6:	3e071363          	bnez	a4,ffffffffc020369c <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02032ba:	000af717          	auipc	a4,0xaf
ffffffffc02032be:	53670713          	addi	a4,a4,1334 # ffffffffc02b27f0 <boot_pgdir>
ffffffffc02032c2:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02032c6:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02032c8:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02032cc:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02032d0:	42079663          	bnez	a5,ffffffffc02036fc <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02032d4:	6599                	lui	a1,0x6
ffffffffc02032d6:	460d                	li	a2,3
ffffffffc02032d8:	6505                	lui	a0,0x1
ffffffffc02032da:	3c1000ef          	jal	ra,ffffffffc0203e9a <vma_create>
ffffffffc02032de:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02032e0:	52050a63          	beqz	a0,ffffffffc0203814 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02032e4:	8556                	mv	a0,s5
ffffffffc02032e6:	423000ef          	jal	ra,ffffffffc0203f08 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02032ea:	00004517          	auipc	a0,0x4
ffffffffc02032ee:	e2e50513          	addi	a0,a0,-466 # ffffffffc0207118 <default_pmm_manager+0x7a0>
ffffffffc02032f2:	e8ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02032f6:	018ab503          	ld	a0,24(s5)
ffffffffc02032fa:	4605                	li	a2,1
ffffffffc02032fc:	6585                	lui	a1,0x1
ffffffffc02032fe:	acbfe0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203302:	4c050963          	beqz	a0,ffffffffc02037d4 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203306:	00004517          	auipc	a0,0x4
ffffffffc020330a:	e6250513          	addi	a0,a0,-414 # ffffffffc0207168 <default_pmm_manager+0x7f0>
ffffffffc020330e:	000ab497          	auipc	s1,0xab
ffffffffc0203312:	42a48493          	addi	s1,s1,1066 # ffffffffc02ae738 <check_rp>
ffffffffc0203316:	e6bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020331a:	000ab997          	auipc	s3,0xab
ffffffffc020331e:	43e98993          	addi	s3,s3,1086 # ffffffffc02ae758 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203322:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0203324:	4505                	li	a0,1
ffffffffc0203326:	997fe0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc020332a:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc020332e:	2c050f63          	beqz	a0,ffffffffc020360c <swap_init+0x43e>
ffffffffc0203332:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203334:	8b89                	andi	a5,a5,2
ffffffffc0203336:	34079363          	bnez	a5,ffffffffc020367c <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020333a:	0a21                	addi	s4,s4,8
ffffffffc020333c:	ff3a14e3          	bne	s4,s3,ffffffffc0203324 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203340:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203342:	000aba17          	auipc	s4,0xab
ffffffffc0203346:	3f6a0a13          	addi	s4,s4,1014 # ffffffffc02ae738 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020334a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020334c:	ec3e                	sd	a5,24(sp)
ffffffffc020334e:	641c                	ld	a5,8(s0)
ffffffffc0203350:	e400                	sd	s0,8(s0)
ffffffffc0203352:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203354:	481c                	lw	a5,16(s0)
ffffffffc0203356:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0203358:	000ab797          	auipc	a5,0xab
ffffffffc020335c:	3a07ac23          	sw	zero,952(a5) # ffffffffc02ae710 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203360:	000a3503          	ld	a0,0(s4)
ffffffffc0203364:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203366:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0203368:	9e7fe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020336c:	ff3a1ae3          	bne	s4,s3,ffffffffc0203360 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203370:	01042a03          	lw	s4,16(s0)
ffffffffc0203374:	4791                	li	a5,4
ffffffffc0203376:	42fa1f63          	bne	s4,a5,ffffffffc02037b4 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020337a:	00004517          	auipc	a0,0x4
ffffffffc020337e:	e7650513          	addi	a0,a0,-394 # ffffffffc02071f0 <default_pmm_manager+0x878>
ffffffffc0203382:	dfffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203386:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203388:	000af797          	auipc	a5,0xaf
ffffffffc020338c:	4a07a823          	sw	zero,1200(a5) # ffffffffc02b2838 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203390:	4629                	li	a2,10
ffffffffc0203392:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
     assert(pgfault_num==1);
ffffffffc0203396:	000af697          	auipc	a3,0xaf
ffffffffc020339a:	4a26a683          	lw	a3,1186(a3) # ffffffffc02b2838 <pgfault_num>
ffffffffc020339e:	4585                	li	a1,1
ffffffffc02033a0:	000af797          	auipc	a5,0xaf
ffffffffc02033a4:	49878793          	addi	a5,a5,1176 # ffffffffc02b2838 <pgfault_num>
ffffffffc02033a8:	54b69663          	bne	a3,a1,ffffffffc02038f4 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02033ac:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc02033b0:	4398                	lw	a4,0(a5)
ffffffffc02033b2:	2701                	sext.w	a4,a4
ffffffffc02033b4:	3ed71063          	bne	a4,a3,ffffffffc0203794 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02033b8:	6689                	lui	a3,0x2
ffffffffc02033ba:	462d                	li	a2,11
ffffffffc02033bc:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
     assert(pgfault_num==2);
ffffffffc02033c0:	4398                	lw	a4,0(a5)
ffffffffc02033c2:	4589                	li	a1,2
ffffffffc02033c4:	2701                	sext.w	a4,a4
ffffffffc02033c6:	4ab71763          	bne	a4,a1,ffffffffc0203874 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02033ca:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02033ce:	4394                	lw	a3,0(a5)
ffffffffc02033d0:	2681                	sext.w	a3,a3
ffffffffc02033d2:	4ce69163          	bne	a3,a4,ffffffffc0203894 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02033d6:	668d                	lui	a3,0x3
ffffffffc02033d8:	4631                	li	a2,12
ffffffffc02033da:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
     assert(pgfault_num==3);
ffffffffc02033de:	4398                	lw	a4,0(a5)
ffffffffc02033e0:	458d                	li	a1,3
ffffffffc02033e2:	2701                	sext.w	a4,a4
ffffffffc02033e4:	4cb71863          	bne	a4,a1,ffffffffc02038b4 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02033e8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02033ec:	4394                	lw	a3,0(a5)
ffffffffc02033ee:	2681                	sext.w	a3,a3
ffffffffc02033f0:	4ee69263          	bne	a3,a4,ffffffffc02038d4 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02033f4:	6691                	lui	a3,0x4
ffffffffc02033f6:	4635                	li	a2,13
ffffffffc02033f8:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
     assert(pgfault_num==4);
ffffffffc02033fc:	4398                	lw	a4,0(a5)
ffffffffc02033fe:	2701                	sext.w	a4,a4
ffffffffc0203400:	43471a63          	bne	a4,s4,ffffffffc0203834 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203404:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203408:	439c                	lw	a5,0(a5)
ffffffffc020340a:	2781                	sext.w	a5,a5
ffffffffc020340c:	44e79463          	bne	a5,a4,ffffffffc0203854 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203410:	481c                	lw	a5,16(s0)
ffffffffc0203412:	2c079563          	bnez	a5,ffffffffc02036dc <swap_init+0x50e>
ffffffffc0203416:	000ab797          	auipc	a5,0xab
ffffffffc020341a:	34278793          	addi	a5,a5,834 # ffffffffc02ae758 <swap_in_seq_no>
ffffffffc020341e:	000ab717          	auipc	a4,0xab
ffffffffc0203422:	36270713          	addi	a4,a4,866 # ffffffffc02ae780 <swap_out_seq_no>
ffffffffc0203426:	000ab617          	auipc	a2,0xab
ffffffffc020342a:	35a60613          	addi	a2,a2,858 # ffffffffc02ae780 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020342e:	56fd                	li	a3,-1
ffffffffc0203430:	c394                	sw	a3,0(a5)
ffffffffc0203432:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203434:	0791                	addi	a5,a5,4
ffffffffc0203436:	0711                	addi	a4,a4,4
ffffffffc0203438:	fec79ce3          	bne	a5,a2,ffffffffc0203430 <swap_init+0x262>
ffffffffc020343c:	000ab717          	auipc	a4,0xab
ffffffffc0203440:	2dc70713          	addi	a4,a4,732 # ffffffffc02ae718 <check_ptep>
ffffffffc0203444:	000ab697          	auipc	a3,0xab
ffffffffc0203448:	2f468693          	addi	a3,a3,756 # ffffffffc02ae738 <check_rp>
ffffffffc020344c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc020344e:	000afc17          	auipc	s8,0xaf
ffffffffc0203452:	3aac0c13          	addi	s8,s8,938 # ffffffffc02b27f8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203456:	000afc97          	auipc	s9,0xaf
ffffffffc020345a:	3aac8c93          	addi	s9,s9,938 # ffffffffc02b2800 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020345e:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203462:	4601                	li	a2,0
ffffffffc0203464:	855a                	mv	a0,s6
ffffffffc0203466:	e836                	sd	a3,16(sp)
ffffffffc0203468:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc020346a:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020346c:	95dfe0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc0203470:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203472:	65a2                	ld	a1,8(sp)
ffffffffc0203474:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203476:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203478:	1c050663          	beqz	a0,ffffffffc0203644 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020347c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020347e:	0017f613          	andi	a2,a5,1
ffffffffc0203482:	1e060163          	beqz	a2,ffffffffc0203664 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203486:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020348a:	078a                	slli	a5,a5,0x2
ffffffffc020348c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020348e:	14c7f363          	bgeu	a5,a2,ffffffffc02035d4 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0203492:	00005617          	auipc	a2,0x5
ffffffffc0203496:	d7e60613          	addi	a2,a2,-642 # ffffffffc0208210 <nbase>
ffffffffc020349a:	00063a03          	ld	s4,0(a2)
ffffffffc020349e:	000cb603          	ld	a2,0(s9)
ffffffffc02034a2:	6288                	ld	a0,0(a3)
ffffffffc02034a4:	414787b3          	sub	a5,a5,s4
ffffffffc02034a8:	079a                	slli	a5,a5,0x6
ffffffffc02034aa:	97b2                	add	a5,a5,a2
ffffffffc02034ac:	14f51063          	bne	a0,a5,ffffffffc02035ec <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034b0:	6785                	lui	a5,0x1
ffffffffc02034b2:	95be                	add	a1,a1,a5
ffffffffc02034b4:	6795                	lui	a5,0x5
ffffffffc02034b6:	0721                	addi	a4,a4,8
ffffffffc02034b8:	06a1                	addi	a3,a3,8
ffffffffc02034ba:	faf592e3          	bne	a1,a5,ffffffffc020345e <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02034be:	00004517          	auipc	a0,0x4
ffffffffc02034c2:	dda50513          	addi	a0,a0,-550 # ffffffffc0207298 <default_pmm_manager+0x920>
ffffffffc02034c6:	cbbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc02034ca:	000bb783          	ld	a5,0(s7)
ffffffffc02034ce:	7f9c                	ld	a5,56(a5)
ffffffffc02034d0:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02034d2:	32051163          	bnez	a0,ffffffffc02037f4 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc02034d6:	77a2                	ld	a5,40(sp)
ffffffffc02034d8:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc02034da:	67e2                	ld	a5,24(sp)
ffffffffc02034dc:	e01c                	sd	a5,0(s0)
ffffffffc02034de:	7782                	ld	a5,32(sp)
ffffffffc02034e0:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02034e2:	6088                	ld	a0,0(s1)
ffffffffc02034e4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034e6:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc02034e8:	867fe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034ec:	ff349be3          	bne	s1,s3,ffffffffc02034e2 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02034f0:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc02034f4:	8556                	mv	a0,s5
ffffffffc02034f6:	2e3000ef          	jal	ra,ffffffffc0203fd8 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02034fa:	000af797          	auipc	a5,0xaf
ffffffffc02034fe:	2f678793          	addi	a5,a5,758 # ffffffffc02b27f0 <boot_pgdir>
ffffffffc0203502:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203504:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203508:	000af697          	auipc	a3,0xaf
ffffffffc020350c:	3206b423          	sd	zero,808(a3) # ffffffffc02b2830 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203510:	639c                	ld	a5,0(a5)
ffffffffc0203512:	078a                	slli	a5,a5,0x2
ffffffffc0203514:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203516:	0ae7fd63          	bgeu	a5,a4,ffffffffc02035d0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc020351a:	414786b3          	sub	a3,a5,s4
ffffffffc020351e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203520:	8699                	srai	a3,a3,0x6
ffffffffc0203522:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203524:	00c69793          	slli	a5,a3,0xc
ffffffffc0203528:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc020352a:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc020352e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203530:	22e7f663          	bgeu	a5,a4,ffffffffc020375c <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203534:	000af797          	auipc	a5,0xaf
ffffffffc0203538:	2dc7b783          	ld	a5,732(a5) # ffffffffc02b2810 <va_pa_offset>
ffffffffc020353c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020353e:	629c                	ld	a5,0(a3)
ffffffffc0203540:	078a                	slli	a5,a5,0x2
ffffffffc0203542:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203544:	08e7f663          	bgeu	a5,a4,ffffffffc02035d0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203548:	414787b3          	sub	a5,a5,s4
ffffffffc020354c:	079a                	slli	a5,a5,0x6
ffffffffc020354e:	953e                	add	a0,a0,a5
ffffffffc0203550:	4585                	li	a1,1
ffffffffc0203552:	ffcfe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203556:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020355a:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc020355e:	078a                	slli	a5,a5,0x2
ffffffffc0203560:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203562:	06e7f763          	bgeu	a5,a4,ffffffffc02035d0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203566:	000cb503          	ld	a0,0(s9)
ffffffffc020356a:	414787b3          	sub	a5,a5,s4
ffffffffc020356e:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203570:	4585                	li	a1,1
ffffffffc0203572:	953e                	add	a0,a0,a5
ffffffffc0203574:	fdafe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
     pgdir[0] = 0;
ffffffffc0203578:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020357c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203580:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203582:	00878a63          	beq	a5,s0,ffffffffc0203596 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203586:	ff87a703          	lw	a4,-8(a5)
ffffffffc020358a:	679c                	ld	a5,8(a5)
ffffffffc020358c:	3dfd                	addiw	s11,s11,-1
ffffffffc020358e:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203592:	fe879ae3          	bne	a5,s0,ffffffffc0203586 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203596:	1c0d9f63          	bnez	s11,ffffffffc0203774 <swap_init+0x5a6>
     assert(total==0);
ffffffffc020359a:	1a0d1163          	bnez	s10,ffffffffc020373c <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc020359e:	00004517          	auipc	a0,0x4
ffffffffc02035a2:	d4a50513          	addi	a0,a0,-694 # ffffffffc02072e8 <default_pmm_manager+0x970>
ffffffffc02035a6:	bdbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc02035aa:	b99d                	j	ffffffffc0203220 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02035ac:	4481                	li	s1,0
ffffffffc02035ae:	b9f1                	j	ffffffffc020328a <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc02035b0:	00003697          	auipc	a3,0x3
ffffffffc02035b4:	02068693          	addi	a3,a3,32 # ffffffffc02065d0 <commands+0x740>
ffffffffc02035b8:	00003617          	auipc	a2,0x3
ffffffffc02035bc:	d2860613          	addi	a2,a2,-728 # ffffffffc02062e0 <commands+0x450>
ffffffffc02035c0:	0bc00593          	li	a1,188
ffffffffc02035c4:	00004517          	auipc	a0,0x4
ffffffffc02035c8:	abc50513          	addi	a0,a0,-1348 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02035cc:	eaffc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02035d0:	be3ff0ef          	jal	ra,ffffffffc02031b2 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc02035d4:	00003617          	auipc	a2,0x3
ffffffffc02035d8:	4ac60613          	addi	a2,a2,1196 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc02035dc:	06200593          	li	a1,98
ffffffffc02035e0:	00003517          	auipc	a0,0x3
ffffffffc02035e4:	3f850513          	addi	a0,a0,1016 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc02035e8:	e93fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02035ec:	00004697          	auipc	a3,0x4
ffffffffc02035f0:	c8468693          	addi	a3,a3,-892 # ffffffffc0207270 <default_pmm_manager+0x8f8>
ffffffffc02035f4:	00003617          	auipc	a2,0x3
ffffffffc02035f8:	cec60613          	addi	a2,a2,-788 # ffffffffc02062e0 <commands+0x450>
ffffffffc02035fc:	0fc00593          	li	a1,252
ffffffffc0203600:	00004517          	auipc	a0,0x4
ffffffffc0203604:	a8050513          	addi	a0,a0,-1408 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203608:	e73fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020360c:	00004697          	auipc	a3,0x4
ffffffffc0203610:	b8468693          	addi	a3,a3,-1148 # ffffffffc0207190 <default_pmm_manager+0x818>
ffffffffc0203614:	00003617          	auipc	a2,0x3
ffffffffc0203618:	ccc60613          	addi	a2,a2,-820 # ffffffffc02062e0 <commands+0x450>
ffffffffc020361c:	0dc00593          	li	a1,220
ffffffffc0203620:	00004517          	auipc	a0,0x4
ffffffffc0203624:	a6050513          	addi	a0,a0,-1440 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203628:	e53fc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020362c:	00004617          	auipc	a2,0x4
ffffffffc0203630:	a3460613          	addi	a2,a2,-1484 # ffffffffc0207060 <default_pmm_manager+0x6e8>
ffffffffc0203634:	02800593          	li	a1,40
ffffffffc0203638:	00004517          	auipc	a0,0x4
ffffffffc020363c:	a4850513          	addi	a0,a0,-1464 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203640:	e3bfc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203644:	00004697          	auipc	a3,0x4
ffffffffc0203648:	c1468693          	addi	a3,a3,-1004 # ffffffffc0207258 <default_pmm_manager+0x8e0>
ffffffffc020364c:	00003617          	auipc	a2,0x3
ffffffffc0203650:	c9460613          	addi	a2,a2,-876 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203654:	0fb00593          	li	a1,251
ffffffffc0203658:	00004517          	auipc	a0,0x4
ffffffffc020365c:	a2850513          	addi	a0,a0,-1496 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203660:	e1bfc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203664:	00003617          	auipc	a2,0x3
ffffffffc0203668:	43c60613          	addi	a2,a2,1084 # ffffffffc0206aa0 <default_pmm_manager+0x128>
ffffffffc020366c:	07400593          	li	a1,116
ffffffffc0203670:	00003517          	auipc	a0,0x3
ffffffffc0203674:	36850513          	addi	a0,a0,872 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0203678:	e03fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020367c:	00004697          	auipc	a3,0x4
ffffffffc0203680:	b2c68693          	addi	a3,a3,-1236 # ffffffffc02071a8 <default_pmm_manager+0x830>
ffffffffc0203684:	00003617          	auipc	a2,0x3
ffffffffc0203688:	c5c60613          	addi	a2,a2,-932 # ffffffffc02062e0 <commands+0x450>
ffffffffc020368c:	0dd00593          	li	a1,221
ffffffffc0203690:	00004517          	auipc	a0,0x4
ffffffffc0203694:	9f050513          	addi	a0,a0,-1552 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203698:	de3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020369c:	00004697          	auipc	a3,0x4
ffffffffc02036a0:	a4468693          	addi	a3,a3,-1468 # ffffffffc02070e0 <default_pmm_manager+0x768>
ffffffffc02036a4:	00003617          	auipc	a2,0x3
ffffffffc02036a8:	c3c60613          	addi	a2,a2,-964 # ffffffffc02062e0 <commands+0x450>
ffffffffc02036ac:	0c700593          	li	a1,199
ffffffffc02036b0:	00004517          	auipc	a0,0x4
ffffffffc02036b4:	9d050513          	addi	a0,a0,-1584 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02036b8:	dc3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total == nr_free_pages());
ffffffffc02036bc:	00003697          	auipc	a3,0x3
ffffffffc02036c0:	f3c68693          	addi	a3,a3,-196 # ffffffffc02065f8 <commands+0x768>
ffffffffc02036c4:	00003617          	auipc	a2,0x3
ffffffffc02036c8:	c1c60613          	addi	a2,a2,-996 # ffffffffc02062e0 <commands+0x450>
ffffffffc02036cc:	0bf00593          	li	a1,191
ffffffffc02036d0:	00004517          	auipc	a0,0x4
ffffffffc02036d4:	9b050513          	addi	a0,a0,-1616 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02036d8:	da3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert( nr_free == 0);         
ffffffffc02036dc:	00003697          	auipc	a3,0x3
ffffffffc02036e0:	0c468693          	addi	a3,a3,196 # ffffffffc02067a0 <commands+0x910>
ffffffffc02036e4:	00003617          	auipc	a2,0x3
ffffffffc02036e8:	bfc60613          	addi	a2,a2,-1028 # ffffffffc02062e0 <commands+0x450>
ffffffffc02036ec:	0f300593          	li	a1,243
ffffffffc02036f0:	00004517          	auipc	a0,0x4
ffffffffc02036f4:	99050513          	addi	a0,a0,-1648 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02036f8:	d83fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgdir[0] == 0);
ffffffffc02036fc:	00004697          	auipc	a3,0x4
ffffffffc0203700:	9fc68693          	addi	a3,a3,-1540 # ffffffffc02070f8 <default_pmm_manager+0x780>
ffffffffc0203704:	00003617          	auipc	a2,0x3
ffffffffc0203708:	bdc60613          	addi	a2,a2,-1060 # ffffffffc02062e0 <commands+0x450>
ffffffffc020370c:	0cc00593          	li	a1,204
ffffffffc0203710:	00004517          	auipc	a0,0x4
ffffffffc0203714:	97050513          	addi	a0,a0,-1680 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203718:	d63fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(mm != NULL);
ffffffffc020371c:	00004697          	auipc	a3,0x4
ffffffffc0203720:	9b468693          	addi	a3,a3,-1612 # ffffffffc02070d0 <default_pmm_manager+0x758>
ffffffffc0203724:	00003617          	auipc	a2,0x3
ffffffffc0203728:	bbc60613          	addi	a2,a2,-1092 # ffffffffc02062e0 <commands+0x450>
ffffffffc020372c:	0c400593          	li	a1,196
ffffffffc0203730:	00004517          	auipc	a0,0x4
ffffffffc0203734:	95050513          	addi	a0,a0,-1712 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203738:	d43fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total==0);
ffffffffc020373c:	00004697          	auipc	a3,0x4
ffffffffc0203740:	b9c68693          	addi	a3,a3,-1124 # ffffffffc02072d8 <default_pmm_manager+0x960>
ffffffffc0203744:	00003617          	auipc	a2,0x3
ffffffffc0203748:	b9c60613          	addi	a2,a2,-1124 # ffffffffc02062e0 <commands+0x450>
ffffffffc020374c:	11e00593          	li	a1,286
ffffffffc0203750:	00004517          	auipc	a0,0x4
ffffffffc0203754:	93050513          	addi	a0,a0,-1744 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203758:	d23fc0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc020375c:	00003617          	auipc	a2,0x3
ffffffffc0203760:	25460613          	addi	a2,a2,596 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0203764:	06900593          	li	a1,105
ffffffffc0203768:	00003517          	auipc	a0,0x3
ffffffffc020376c:	27050513          	addi	a0,a0,624 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0203770:	d0bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(count==0);
ffffffffc0203774:	00004697          	auipc	a3,0x4
ffffffffc0203778:	b5468693          	addi	a3,a3,-1196 # ffffffffc02072c8 <default_pmm_manager+0x950>
ffffffffc020377c:	00003617          	auipc	a2,0x3
ffffffffc0203780:	b6460613          	addi	a2,a2,-1180 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203784:	11d00593          	li	a1,285
ffffffffc0203788:	00004517          	auipc	a0,0x4
ffffffffc020378c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203790:	cebfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203794:	00004697          	auipc	a3,0x4
ffffffffc0203798:	a8468693          	addi	a3,a3,-1404 # ffffffffc0207218 <default_pmm_manager+0x8a0>
ffffffffc020379c:	00003617          	auipc	a2,0x3
ffffffffc02037a0:	b4460613          	addi	a2,a2,-1212 # ffffffffc02062e0 <commands+0x450>
ffffffffc02037a4:	09500593          	li	a1,149
ffffffffc02037a8:	00004517          	auipc	a0,0x4
ffffffffc02037ac:	8d850513          	addi	a0,a0,-1832 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02037b0:	ccbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02037b4:	00004697          	auipc	a3,0x4
ffffffffc02037b8:	a1468693          	addi	a3,a3,-1516 # ffffffffc02071c8 <default_pmm_manager+0x850>
ffffffffc02037bc:	00003617          	auipc	a2,0x3
ffffffffc02037c0:	b2460613          	addi	a2,a2,-1244 # ffffffffc02062e0 <commands+0x450>
ffffffffc02037c4:	0ea00593          	li	a1,234
ffffffffc02037c8:	00004517          	auipc	a0,0x4
ffffffffc02037cc:	8b850513          	addi	a0,a0,-1864 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02037d0:	cabfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02037d4:	00004697          	auipc	a3,0x4
ffffffffc02037d8:	97c68693          	addi	a3,a3,-1668 # ffffffffc0207150 <default_pmm_manager+0x7d8>
ffffffffc02037dc:	00003617          	auipc	a2,0x3
ffffffffc02037e0:	b0460613          	addi	a2,a2,-1276 # ffffffffc02062e0 <commands+0x450>
ffffffffc02037e4:	0d700593          	li	a1,215
ffffffffc02037e8:	00004517          	auipc	a0,0x4
ffffffffc02037ec:	89850513          	addi	a0,a0,-1896 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02037f0:	c8bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(ret==0);
ffffffffc02037f4:	00004697          	auipc	a3,0x4
ffffffffc02037f8:	acc68693          	addi	a3,a3,-1332 # ffffffffc02072c0 <default_pmm_manager+0x948>
ffffffffc02037fc:	00003617          	auipc	a2,0x3
ffffffffc0203800:	ae460613          	addi	a2,a2,-1308 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203804:	10200593          	li	a1,258
ffffffffc0203808:	00004517          	auipc	a0,0x4
ffffffffc020380c:	87850513          	addi	a0,a0,-1928 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203810:	c6bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(vma != NULL);
ffffffffc0203814:	00004697          	auipc	a3,0x4
ffffffffc0203818:	8f468693          	addi	a3,a3,-1804 # ffffffffc0207108 <default_pmm_manager+0x790>
ffffffffc020381c:	00003617          	auipc	a2,0x3
ffffffffc0203820:	ac460613          	addi	a2,a2,-1340 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203824:	0cf00593          	li	a1,207
ffffffffc0203828:	00004517          	auipc	a0,0x4
ffffffffc020382c:	85850513          	addi	a0,a0,-1960 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203830:	c4bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203834:	00004697          	auipc	a3,0x4
ffffffffc0203838:	a1468693          	addi	a3,a3,-1516 # ffffffffc0207248 <default_pmm_manager+0x8d0>
ffffffffc020383c:	00003617          	auipc	a2,0x3
ffffffffc0203840:	aa460613          	addi	a2,a2,-1372 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203844:	09f00593          	li	a1,159
ffffffffc0203848:	00004517          	auipc	a0,0x4
ffffffffc020384c:	83850513          	addi	a0,a0,-1992 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203850:	c2bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203854:	00004697          	auipc	a3,0x4
ffffffffc0203858:	9f468693          	addi	a3,a3,-1548 # ffffffffc0207248 <default_pmm_manager+0x8d0>
ffffffffc020385c:	00003617          	auipc	a2,0x3
ffffffffc0203860:	a8460613          	addi	a2,a2,-1404 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203864:	0a100593          	li	a1,161
ffffffffc0203868:	00004517          	auipc	a0,0x4
ffffffffc020386c:	81850513          	addi	a0,a0,-2024 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203870:	c0bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203874:	00004697          	auipc	a3,0x4
ffffffffc0203878:	9b468693          	addi	a3,a3,-1612 # ffffffffc0207228 <default_pmm_manager+0x8b0>
ffffffffc020387c:	00003617          	auipc	a2,0x3
ffffffffc0203880:	a6460613          	addi	a2,a2,-1436 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203884:	09700593          	li	a1,151
ffffffffc0203888:	00003517          	auipc	a0,0x3
ffffffffc020388c:	7f850513          	addi	a0,a0,2040 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203890:	bebfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203894:	00004697          	auipc	a3,0x4
ffffffffc0203898:	99468693          	addi	a3,a3,-1644 # ffffffffc0207228 <default_pmm_manager+0x8b0>
ffffffffc020389c:	00003617          	auipc	a2,0x3
ffffffffc02038a0:	a4460613          	addi	a2,a2,-1468 # ffffffffc02062e0 <commands+0x450>
ffffffffc02038a4:	09900593          	li	a1,153
ffffffffc02038a8:	00003517          	auipc	a0,0x3
ffffffffc02038ac:	7d850513          	addi	a0,a0,2008 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02038b0:	bcbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc02038b4:	00004697          	auipc	a3,0x4
ffffffffc02038b8:	98468693          	addi	a3,a3,-1660 # ffffffffc0207238 <default_pmm_manager+0x8c0>
ffffffffc02038bc:	00003617          	auipc	a2,0x3
ffffffffc02038c0:	a2460613          	addi	a2,a2,-1500 # ffffffffc02062e0 <commands+0x450>
ffffffffc02038c4:	09b00593          	li	a1,155
ffffffffc02038c8:	00003517          	auipc	a0,0x3
ffffffffc02038cc:	7b850513          	addi	a0,a0,1976 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02038d0:	babfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc02038d4:	00004697          	auipc	a3,0x4
ffffffffc02038d8:	96468693          	addi	a3,a3,-1692 # ffffffffc0207238 <default_pmm_manager+0x8c0>
ffffffffc02038dc:	00003617          	auipc	a2,0x3
ffffffffc02038e0:	a0460613          	addi	a2,a2,-1532 # ffffffffc02062e0 <commands+0x450>
ffffffffc02038e4:	09d00593          	li	a1,157
ffffffffc02038e8:	00003517          	auipc	a0,0x3
ffffffffc02038ec:	79850513          	addi	a0,a0,1944 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc02038f0:	b8bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc02038f4:	00004697          	auipc	a3,0x4
ffffffffc02038f8:	92468693          	addi	a3,a3,-1756 # ffffffffc0207218 <default_pmm_manager+0x8a0>
ffffffffc02038fc:	00003617          	auipc	a2,0x3
ffffffffc0203900:	9e460613          	addi	a2,a2,-1564 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203904:	09300593          	li	a1,147
ffffffffc0203908:	00003517          	auipc	a0,0x3
ffffffffc020390c:	77850513          	addi	a0,a0,1912 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203910:	b6bfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203914 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203914:	000af797          	auipc	a5,0xaf
ffffffffc0203918:	f0c7b783          	ld	a5,-244(a5) # ffffffffc02b2820 <sm>
ffffffffc020391c:	6b9c                	ld	a5,16(a5)
ffffffffc020391e:	8782                	jr	a5

ffffffffc0203920 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203920:	000af797          	auipc	a5,0xaf
ffffffffc0203924:	f007b783          	ld	a5,-256(a5) # ffffffffc02b2820 <sm>
ffffffffc0203928:	739c                	ld	a5,32(a5)
ffffffffc020392a:	8782                	jr	a5

ffffffffc020392c <swap_out>:
{
ffffffffc020392c:	711d                	addi	sp,sp,-96
ffffffffc020392e:	ec86                	sd	ra,88(sp)
ffffffffc0203930:	e8a2                	sd	s0,80(sp)
ffffffffc0203932:	e4a6                	sd	s1,72(sp)
ffffffffc0203934:	e0ca                	sd	s2,64(sp)
ffffffffc0203936:	fc4e                	sd	s3,56(sp)
ffffffffc0203938:	f852                	sd	s4,48(sp)
ffffffffc020393a:	f456                	sd	s5,40(sp)
ffffffffc020393c:	f05a                	sd	s6,32(sp)
ffffffffc020393e:	ec5e                	sd	s7,24(sp)
ffffffffc0203940:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203942:	cde9                	beqz	a1,ffffffffc0203a1c <swap_out+0xf0>
ffffffffc0203944:	8a2e                	mv	s4,a1
ffffffffc0203946:	892a                	mv	s2,a0
ffffffffc0203948:	8ab2                	mv	s5,a2
ffffffffc020394a:	4401                	li	s0,0
ffffffffc020394c:	000af997          	auipc	s3,0xaf
ffffffffc0203950:	ed498993          	addi	s3,s3,-300 # ffffffffc02b2820 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203954:	00004b17          	auipc	s6,0x4
ffffffffc0203958:	a14b0b13          	addi	s6,s6,-1516 # ffffffffc0207368 <default_pmm_manager+0x9f0>
                    cprintf("SWAP: failed to save\n");
ffffffffc020395c:	00004b97          	auipc	s7,0x4
ffffffffc0203960:	9f4b8b93          	addi	s7,s7,-1548 # ffffffffc0207350 <default_pmm_manager+0x9d8>
ffffffffc0203964:	a825                	j	ffffffffc020399c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203966:	67a2                	ld	a5,8(sp)
ffffffffc0203968:	8626                	mv	a2,s1
ffffffffc020396a:	85a2                	mv	a1,s0
ffffffffc020396c:	7f94                	ld	a3,56(a5)
ffffffffc020396e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203970:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203972:	82b1                	srli	a3,a3,0xc
ffffffffc0203974:	0685                	addi	a3,a3,1
ffffffffc0203976:	80bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020397a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020397c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020397e:	7d1c                	ld	a5,56(a0)
ffffffffc0203980:	83b1                	srli	a5,a5,0xc
ffffffffc0203982:	0785                	addi	a5,a5,1
ffffffffc0203984:	07a2                	slli	a5,a5,0x8
ffffffffc0203986:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020398a:	bc4fe0ef          	jal	ra,ffffffffc0201d4e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020398e:	01893503          	ld	a0,24(s2)
ffffffffc0203992:	85a6                	mv	a1,s1
ffffffffc0203994:	f5eff0ef          	jal	ra,ffffffffc02030f2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203998:	048a0d63          	beq	s4,s0,ffffffffc02039f2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020399c:	0009b783          	ld	a5,0(s3)
ffffffffc02039a0:	8656                	mv	a2,s5
ffffffffc02039a2:	002c                	addi	a1,sp,8
ffffffffc02039a4:	7b9c                	ld	a5,48(a5)
ffffffffc02039a6:	854a                	mv	a0,s2
ffffffffc02039a8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc02039aa:	e12d                	bnez	a0,ffffffffc0203a0c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc02039ac:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02039ae:	01893503          	ld	a0,24(s2)
ffffffffc02039b2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02039b4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02039b6:	85a6                	mv	a1,s1
ffffffffc02039b8:	c10fe0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02039bc:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02039be:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02039c0:	8b85                	andi	a5,a5,1
ffffffffc02039c2:	cfb9                	beqz	a5,ffffffffc0203a20 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02039c4:	65a2                	ld	a1,8(sp)
ffffffffc02039c6:	7d9c                	ld	a5,56(a1)
ffffffffc02039c8:	83b1                	srli	a5,a5,0xc
ffffffffc02039ca:	0785                	addi	a5,a5,1
ffffffffc02039cc:	00879513          	slli	a0,a5,0x8
ffffffffc02039d0:	649000ef          	jal	ra,ffffffffc0204818 <swapfs_write>
ffffffffc02039d4:	d949                	beqz	a0,ffffffffc0203966 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02039d6:	855e                	mv	a0,s7
ffffffffc02039d8:	fa8fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02039dc:	0009b783          	ld	a5,0(s3)
ffffffffc02039e0:	6622                	ld	a2,8(sp)
ffffffffc02039e2:	4681                	li	a3,0
ffffffffc02039e4:	739c                	ld	a5,32(a5)
ffffffffc02039e6:	85a6                	mv	a1,s1
ffffffffc02039e8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02039ea:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02039ec:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02039ee:	fa8a17e3          	bne	s4,s0,ffffffffc020399c <swap_out+0x70>
}
ffffffffc02039f2:	60e6                	ld	ra,88(sp)
ffffffffc02039f4:	8522                	mv	a0,s0
ffffffffc02039f6:	6446                	ld	s0,80(sp)
ffffffffc02039f8:	64a6                	ld	s1,72(sp)
ffffffffc02039fa:	6906                	ld	s2,64(sp)
ffffffffc02039fc:	79e2                	ld	s3,56(sp)
ffffffffc02039fe:	7a42                	ld	s4,48(sp)
ffffffffc0203a00:	7aa2                	ld	s5,40(sp)
ffffffffc0203a02:	7b02                	ld	s6,32(sp)
ffffffffc0203a04:	6be2                	ld	s7,24(sp)
ffffffffc0203a06:	6c42                	ld	s8,16(sp)
ffffffffc0203a08:	6125                	addi	sp,sp,96
ffffffffc0203a0a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203a0c:	85a2                	mv	a1,s0
ffffffffc0203a0e:	00004517          	auipc	a0,0x4
ffffffffc0203a12:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0207308 <default_pmm_manager+0x990>
ffffffffc0203a16:	f6afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203a1a:	bfe1                	j	ffffffffc02039f2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203a1c:	4401                	li	s0,0
ffffffffc0203a1e:	bfd1                	j	ffffffffc02039f2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203a20:	00004697          	auipc	a3,0x4
ffffffffc0203a24:	91868693          	addi	a3,a3,-1768 # ffffffffc0207338 <default_pmm_manager+0x9c0>
ffffffffc0203a28:	00003617          	auipc	a2,0x3
ffffffffc0203a2c:	8b860613          	addi	a2,a2,-1864 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203a30:	06800593          	li	a1,104
ffffffffc0203a34:	00003517          	auipc	a0,0x3
ffffffffc0203a38:	64c50513          	addi	a0,a0,1612 # ffffffffc0207080 <default_pmm_manager+0x708>
ffffffffc0203a3c:	a3ffc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203a40 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203a40:	000ab797          	auipc	a5,0xab
ffffffffc0203a44:	d6878793          	addi	a5,a5,-664 # ffffffffc02ae7a8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203a48:	f51c                	sd	a5,40(a0)
ffffffffc0203a4a:	e79c                	sd	a5,8(a5)
ffffffffc0203a4c:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203a4e:	4501                	li	a0,0
ffffffffc0203a50:	8082                	ret

ffffffffc0203a52 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203a52:	4501                	li	a0,0
ffffffffc0203a54:	8082                	ret

ffffffffc0203a56 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203a56:	4501                	li	a0,0
ffffffffc0203a58:	8082                	ret

ffffffffc0203a5a <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203a5a:	4501                	li	a0,0
ffffffffc0203a5c:	8082                	ret

ffffffffc0203a5e <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203a5e:	711d                	addi	sp,sp,-96
ffffffffc0203a60:	fc4e                	sd	s3,56(sp)
ffffffffc0203a62:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203a64:	00004517          	auipc	a0,0x4
ffffffffc0203a68:	94450513          	addi	a0,a0,-1724 # ffffffffc02073a8 <default_pmm_manager+0xa30>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203a6c:	698d                	lui	s3,0x3
ffffffffc0203a6e:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203a70:	e0ca                	sd	s2,64(sp)
ffffffffc0203a72:	ec86                	sd	ra,88(sp)
ffffffffc0203a74:	e8a2                	sd	s0,80(sp)
ffffffffc0203a76:	e4a6                	sd	s1,72(sp)
ffffffffc0203a78:	f456                	sd	s5,40(sp)
ffffffffc0203a7a:	f05a                	sd	s6,32(sp)
ffffffffc0203a7c:	ec5e                	sd	s7,24(sp)
ffffffffc0203a7e:	e862                	sd	s8,16(sp)
ffffffffc0203a80:	e466                	sd	s9,8(sp)
ffffffffc0203a82:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203a84:	efcfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203a88:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
    assert(pgfault_num==4);
ffffffffc0203a8c:	000af917          	auipc	s2,0xaf
ffffffffc0203a90:	dac92903          	lw	s2,-596(s2) # ffffffffc02b2838 <pgfault_num>
ffffffffc0203a94:	4791                	li	a5,4
ffffffffc0203a96:	14f91e63          	bne	s2,a5,ffffffffc0203bf2 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203a9a:	00004517          	auipc	a0,0x4
ffffffffc0203a9e:	94e50513          	addi	a0,a0,-1714 # ffffffffc02073e8 <default_pmm_manager+0xa70>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203aa2:	6a85                	lui	s5,0x1
ffffffffc0203aa4:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203aa6:	edafc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203aaa:	000af417          	auipc	s0,0xaf
ffffffffc0203aae:	d8e40413          	addi	s0,s0,-626 # ffffffffc02b2838 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203ab2:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    assert(pgfault_num==4);
ffffffffc0203ab6:	4004                	lw	s1,0(s0)
ffffffffc0203ab8:	2481                	sext.w	s1,s1
ffffffffc0203aba:	2b249c63          	bne	s1,s2,ffffffffc0203d72 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203abe:	00004517          	auipc	a0,0x4
ffffffffc0203ac2:	95250513          	addi	a0,a0,-1710 # ffffffffc0207410 <default_pmm_manager+0xa98>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ac6:	6b91                	lui	s7,0x4
ffffffffc0203ac8:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203aca:	eb6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ace:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
    assert(pgfault_num==4);
ffffffffc0203ad2:	00042903          	lw	s2,0(s0)
ffffffffc0203ad6:	2901                	sext.w	s2,s2
ffffffffc0203ad8:	26991d63          	bne	s2,s1,ffffffffc0203d52 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203adc:	00004517          	auipc	a0,0x4
ffffffffc0203ae0:	95c50513          	addi	a0,a0,-1700 # ffffffffc0207438 <default_pmm_manager+0xac0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203ae4:	6c89                	lui	s9,0x2
ffffffffc0203ae6:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ae8:	e98fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203aec:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
    assert(pgfault_num==4);
ffffffffc0203af0:	401c                	lw	a5,0(s0)
ffffffffc0203af2:	2781                	sext.w	a5,a5
ffffffffc0203af4:	23279f63          	bne	a5,s2,ffffffffc0203d32 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203af8:	00004517          	auipc	a0,0x4
ffffffffc0203afc:	96850513          	addi	a0,a0,-1688 # ffffffffc0207460 <default_pmm_manager+0xae8>
ffffffffc0203b00:	e80fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203b04:	6795                	lui	a5,0x5
ffffffffc0203b06:	4739                	li	a4,14
ffffffffc0203b08:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==5);
ffffffffc0203b0c:	4004                	lw	s1,0(s0)
ffffffffc0203b0e:	4795                	li	a5,5
ffffffffc0203b10:	2481                	sext.w	s1,s1
ffffffffc0203b12:	20f49063          	bne	s1,a5,ffffffffc0203d12 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203b16:	00004517          	auipc	a0,0x4
ffffffffc0203b1a:	92250513          	addi	a0,a0,-1758 # ffffffffc0207438 <default_pmm_manager+0xac0>
ffffffffc0203b1e:	e62fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203b22:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203b26:	401c                	lw	a5,0(s0)
ffffffffc0203b28:	2781                	sext.w	a5,a5
ffffffffc0203b2a:	1c979463          	bne	a5,s1,ffffffffc0203cf2 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203b2e:	00004517          	auipc	a0,0x4
ffffffffc0203b32:	8ba50513          	addi	a0,a0,-1862 # ffffffffc02073e8 <default_pmm_manager+0xa70>
ffffffffc0203b36:	e4afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203b3a:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203b3e:	401c                	lw	a5,0(s0)
ffffffffc0203b40:	4719                	li	a4,6
ffffffffc0203b42:	2781                	sext.w	a5,a5
ffffffffc0203b44:	18e79763          	bne	a5,a4,ffffffffc0203cd2 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203b48:	00004517          	auipc	a0,0x4
ffffffffc0203b4c:	8f050513          	addi	a0,a0,-1808 # ffffffffc0207438 <default_pmm_manager+0xac0>
ffffffffc0203b50:	e30fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203b54:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203b58:	401c                	lw	a5,0(s0)
ffffffffc0203b5a:	471d                	li	a4,7
ffffffffc0203b5c:	2781                	sext.w	a5,a5
ffffffffc0203b5e:	14e79a63          	bne	a5,a4,ffffffffc0203cb2 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203b62:	00004517          	auipc	a0,0x4
ffffffffc0203b66:	84650513          	addi	a0,a0,-1978 # ffffffffc02073a8 <default_pmm_manager+0xa30>
ffffffffc0203b6a:	e16fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203b6e:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203b72:	401c                	lw	a5,0(s0)
ffffffffc0203b74:	4721                	li	a4,8
ffffffffc0203b76:	2781                	sext.w	a5,a5
ffffffffc0203b78:	10e79d63          	bne	a5,a4,ffffffffc0203c92 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203b7c:	00004517          	auipc	a0,0x4
ffffffffc0203b80:	89450513          	addi	a0,a0,-1900 # ffffffffc0207410 <default_pmm_manager+0xa98>
ffffffffc0203b84:	dfcfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203b88:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203b8c:	401c                	lw	a5,0(s0)
ffffffffc0203b8e:	4725                	li	a4,9
ffffffffc0203b90:	2781                	sext.w	a5,a5
ffffffffc0203b92:	0ee79063          	bne	a5,a4,ffffffffc0203c72 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203b96:	00004517          	auipc	a0,0x4
ffffffffc0203b9a:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0207460 <default_pmm_manager+0xae8>
ffffffffc0203b9e:	de2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203ba2:	6795                	lui	a5,0x5
ffffffffc0203ba4:	4739                	li	a4,14
ffffffffc0203ba6:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==10);
ffffffffc0203baa:	4004                	lw	s1,0(s0)
ffffffffc0203bac:	47a9                	li	a5,10
ffffffffc0203bae:	2481                	sext.w	s1,s1
ffffffffc0203bb0:	0af49163          	bne	s1,a5,ffffffffc0203c52 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203bb4:	00004517          	auipc	a0,0x4
ffffffffc0203bb8:	83450513          	addi	a0,a0,-1996 # ffffffffc02073e8 <default_pmm_manager+0xa70>
ffffffffc0203bbc:	dc4fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203bc0:	6785                	lui	a5,0x1
ffffffffc0203bc2:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0203bc6:	06979663          	bne	a5,s1,ffffffffc0203c32 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203bca:	401c                	lw	a5,0(s0)
ffffffffc0203bcc:	472d                	li	a4,11
ffffffffc0203bce:	2781                	sext.w	a5,a5
ffffffffc0203bd0:	04e79163          	bne	a5,a4,ffffffffc0203c12 <_fifo_check_swap+0x1b4>
}
ffffffffc0203bd4:	60e6                	ld	ra,88(sp)
ffffffffc0203bd6:	6446                	ld	s0,80(sp)
ffffffffc0203bd8:	64a6                	ld	s1,72(sp)
ffffffffc0203bda:	6906                	ld	s2,64(sp)
ffffffffc0203bdc:	79e2                	ld	s3,56(sp)
ffffffffc0203bde:	7a42                	ld	s4,48(sp)
ffffffffc0203be0:	7aa2                	ld	s5,40(sp)
ffffffffc0203be2:	7b02                	ld	s6,32(sp)
ffffffffc0203be4:	6be2                	ld	s7,24(sp)
ffffffffc0203be6:	6c42                	ld	s8,16(sp)
ffffffffc0203be8:	6ca2                	ld	s9,8(sp)
ffffffffc0203bea:	6d02                	ld	s10,0(sp)
ffffffffc0203bec:	4501                	li	a0,0
ffffffffc0203bee:	6125                	addi	sp,sp,96
ffffffffc0203bf0:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203bf2:	00003697          	auipc	a3,0x3
ffffffffc0203bf6:	65668693          	addi	a3,a3,1622 # ffffffffc0207248 <default_pmm_manager+0x8d0>
ffffffffc0203bfa:	00002617          	auipc	a2,0x2
ffffffffc0203bfe:	6e660613          	addi	a2,a2,1766 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203c02:	05100593          	li	a1,81
ffffffffc0203c06:	00003517          	auipc	a0,0x3
ffffffffc0203c0a:	7ca50513          	addi	a0,a0,1994 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203c0e:	86dfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==11);
ffffffffc0203c12:	00004697          	auipc	a3,0x4
ffffffffc0203c16:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0207510 <default_pmm_manager+0xb98>
ffffffffc0203c1a:	00002617          	auipc	a2,0x2
ffffffffc0203c1e:	6c660613          	addi	a2,a2,1734 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203c22:	07300593          	li	a1,115
ffffffffc0203c26:	00003517          	auipc	a0,0x3
ffffffffc0203c2a:	7aa50513          	addi	a0,a0,1962 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203c2e:	84dfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203c32:	00004697          	auipc	a3,0x4
ffffffffc0203c36:	8b668693          	addi	a3,a3,-1866 # ffffffffc02074e8 <default_pmm_manager+0xb70>
ffffffffc0203c3a:	00002617          	auipc	a2,0x2
ffffffffc0203c3e:	6a660613          	addi	a2,a2,1702 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203c42:	07100593          	li	a1,113
ffffffffc0203c46:	00003517          	auipc	a0,0x3
ffffffffc0203c4a:	78a50513          	addi	a0,a0,1930 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203c4e:	82dfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==10);
ffffffffc0203c52:	00004697          	auipc	a3,0x4
ffffffffc0203c56:	88668693          	addi	a3,a3,-1914 # ffffffffc02074d8 <default_pmm_manager+0xb60>
ffffffffc0203c5a:	00002617          	auipc	a2,0x2
ffffffffc0203c5e:	68660613          	addi	a2,a2,1670 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203c62:	06f00593          	li	a1,111
ffffffffc0203c66:	00003517          	auipc	a0,0x3
ffffffffc0203c6a:	76a50513          	addi	a0,a0,1898 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203c6e:	80dfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==9);
ffffffffc0203c72:	00004697          	auipc	a3,0x4
ffffffffc0203c76:	85668693          	addi	a3,a3,-1962 # ffffffffc02074c8 <default_pmm_manager+0xb50>
ffffffffc0203c7a:	00002617          	auipc	a2,0x2
ffffffffc0203c7e:	66660613          	addi	a2,a2,1638 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203c82:	06c00593          	li	a1,108
ffffffffc0203c86:	00003517          	auipc	a0,0x3
ffffffffc0203c8a:	74a50513          	addi	a0,a0,1866 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203c8e:	fecfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==8);
ffffffffc0203c92:	00004697          	auipc	a3,0x4
ffffffffc0203c96:	82668693          	addi	a3,a3,-2010 # ffffffffc02074b8 <default_pmm_manager+0xb40>
ffffffffc0203c9a:	00002617          	auipc	a2,0x2
ffffffffc0203c9e:	64660613          	addi	a2,a2,1606 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203ca2:	06900593          	li	a1,105
ffffffffc0203ca6:	00003517          	auipc	a0,0x3
ffffffffc0203caa:	72a50513          	addi	a0,a0,1834 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203cae:	fccfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==7);
ffffffffc0203cb2:	00003697          	auipc	a3,0x3
ffffffffc0203cb6:	7f668693          	addi	a3,a3,2038 # ffffffffc02074a8 <default_pmm_manager+0xb30>
ffffffffc0203cba:	00002617          	auipc	a2,0x2
ffffffffc0203cbe:	62660613          	addi	a2,a2,1574 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203cc2:	06600593          	li	a1,102
ffffffffc0203cc6:	00003517          	auipc	a0,0x3
ffffffffc0203cca:	70a50513          	addi	a0,a0,1802 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203cce:	facfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==6);
ffffffffc0203cd2:	00003697          	auipc	a3,0x3
ffffffffc0203cd6:	7c668693          	addi	a3,a3,1990 # ffffffffc0207498 <default_pmm_manager+0xb20>
ffffffffc0203cda:	00002617          	auipc	a2,0x2
ffffffffc0203cde:	60660613          	addi	a2,a2,1542 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203ce2:	06300593          	li	a1,99
ffffffffc0203ce6:	00003517          	auipc	a0,0x3
ffffffffc0203cea:	6ea50513          	addi	a0,a0,1770 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203cee:	f8cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0203cf2:	00003697          	auipc	a3,0x3
ffffffffc0203cf6:	79668693          	addi	a3,a3,1942 # ffffffffc0207488 <default_pmm_manager+0xb10>
ffffffffc0203cfa:	00002617          	auipc	a2,0x2
ffffffffc0203cfe:	5e660613          	addi	a2,a2,1510 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203d02:	06000593          	li	a1,96
ffffffffc0203d06:	00003517          	auipc	a0,0x3
ffffffffc0203d0a:	6ca50513          	addi	a0,a0,1738 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203d0e:	f6cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0203d12:	00003697          	auipc	a3,0x3
ffffffffc0203d16:	77668693          	addi	a3,a3,1910 # ffffffffc0207488 <default_pmm_manager+0xb10>
ffffffffc0203d1a:	00002617          	auipc	a2,0x2
ffffffffc0203d1e:	5c660613          	addi	a2,a2,1478 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203d22:	05d00593          	li	a1,93
ffffffffc0203d26:	00003517          	auipc	a0,0x3
ffffffffc0203d2a:	6aa50513          	addi	a0,a0,1706 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203d2e:	f4cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203d32:	00003697          	auipc	a3,0x3
ffffffffc0203d36:	51668693          	addi	a3,a3,1302 # ffffffffc0207248 <default_pmm_manager+0x8d0>
ffffffffc0203d3a:	00002617          	auipc	a2,0x2
ffffffffc0203d3e:	5a660613          	addi	a2,a2,1446 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203d42:	05a00593          	li	a1,90
ffffffffc0203d46:	00003517          	auipc	a0,0x3
ffffffffc0203d4a:	68a50513          	addi	a0,a0,1674 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203d4e:	f2cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203d52:	00003697          	auipc	a3,0x3
ffffffffc0203d56:	4f668693          	addi	a3,a3,1270 # ffffffffc0207248 <default_pmm_manager+0x8d0>
ffffffffc0203d5a:	00002617          	auipc	a2,0x2
ffffffffc0203d5e:	58660613          	addi	a2,a2,1414 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203d62:	05700593          	li	a1,87
ffffffffc0203d66:	00003517          	auipc	a0,0x3
ffffffffc0203d6a:	66a50513          	addi	a0,a0,1642 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203d6e:	f0cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203d72:	00003697          	auipc	a3,0x3
ffffffffc0203d76:	4d668693          	addi	a3,a3,1238 # ffffffffc0207248 <default_pmm_manager+0x8d0>
ffffffffc0203d7a:	00002617          	auipc	a2,0x2
ffffffffc0203d7e:	56660613          	addi	a2,a2,1382 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203d82:	05400593          	li	a1,84
ffffffffc0203d86:	00003517          	auipc	a0,0x3
ffffffffc0203d8a:	64a50513          	addi	a0,a0,1610 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203d8e:	eecfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203d92 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203d92:	751c                	ld	a5,40(a0)
{
ffffffffc0203d94:	1141                	addi	sp,sp,-16
ffffffffc0203d96:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203d98:	cf91                	beqz	a5,ffffffffc0203db4 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203d9a:	ee0d                	bnez	a2,ffffffffc0203dd4 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203d9c:	679c                	ld	a5,8(a5)
}
ffffffffc0203d9e:	60a2                	ld	ra,8(sp)
ffffffffc0203da0:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203da2:	6394                	ld	a3,0(a5)
ffffffffc0203da4:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203da6:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203daa:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203dac:	e314                	sd	a3,0(a4)
ffffffffc0203dae:	e19c                	sd	a5,0(a1)
}
ffffffffc0203db0:	0141                	addi	sp,sp,16
ffffffffc0203db2:	8082                	ret
         assert(head != NULL);
ffffffffc0203db4:	00003697          	auipc	a3,0x3
ffffffffc0203db8:	76c68693          	addi	a3,a3,1900 # ffffffffc0207520 <default_pmm_manager+0xba8>
ffffffffc0203dbc:	00002617          	auipc	a2,0x2
ffffffffc0203dc0:	52460613          	addi	a2,a2,1316 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203dc4:	04100593          	li	a1,65
ffffffffc0203dc8:	00003517          	auipc	a0,0x3
ffffffffc0203dcc:	60850513          	addi	a0,a0,1544 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203dd0:	eaafc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(in_tick==0);
ffffffffc0203dd4:	00003697          	auipc	a3,0x3
ffffffffc0203dd8:	75c68693          	addi	a3,a3,1884 # ffffffffc0207530 <default_pmm_manager+0xbb8>
ffffffffc0203ddc:	00002617          	auipc	a2,0x2
ffffffffc0203de0:	50460613          	addi	a2,a2,1284 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203de4:	04200593          	li	a1,66
ffffffffc0203de8:	00003517          	auipc	a0,0x3
ffffffffc0203dec:	5e850513          	addi	a0,a0,1512 # ffffffffc02073d0 <default_pmm_manager+0xa58>
ffffffffc0203df0:	e8afc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203df4 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203df4:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203df6:	cb91                	beqz	a5,ffffffffc0203e0a <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203df8:	6394                	ld	a3,0(a5)
ffffffffc0203dfa:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0203dfe:	e398                	sd	a4,0(a5)
ffffffffc0203e00:	e698                	sd	a4,8(a3)
}
ffffffffc0203e02:	4501                	li	a0,0
    elm->next = next;
ffffffffc0203e04:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203e06:	f614                	sd	a3,40(a2)
ffffffffc0203e08:	8082                	ret
{
ffffffffc0203e0a:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203e0c:	00003697          	auipc	a3,0x3
ffffffffc0203e10:	73468693          	addi	a3,a3,1844 # ffffffffc0207540 <default_pmm_manager+0xbc8>
ffffffffc0203e14:	00002617          	auipc	a2,0x2
ffffffffc0203e18:	4cc60613          	addi	a2,a2,1228 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203e1c:	03200593          	li	a1,50
ffffffffc0203e20:	00003517          	auipc	a0,0x3
ffffffffc0203e24:	5b050513          	addi	a0,a0,1456 # ffffffffc02073d0 <default_pmm_manager+0xa58>
{
ffffffffc0203e28:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203e2a:	e50fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203e2e <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203e2e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203e30:	00003697          	auipc	a3,0x3
ffffffffc0203e34:	74868693          	addi	a3,a3,1864 # ffffffffc0207578 <default_pmm_manager+0xc00>
ffffffffc0203e38:	00002617          	auipc	a2,0x2
ffffffffc0203e3c:	4a860613          	addi	a2,a2,1192 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203e40:	06d00593          	li	a1,109
ffffffffc0203e44:	00003517          	auipc	a0,0x3
ffffffffc0203e48:	75450513          	addi	a0,a0,1876 # ffffffffc0207598 <default_pmm_manager+0xc20>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203e4c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203e4e:	e2cfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203e52 <mm_create>:
mm_create(void) {
ffffffffc0203e52:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203e54:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0203e58:	e022                	sd	s0,0(sp)
ffffffffc0203e5a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203e5c:	c83fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc0203e60:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203e62:	c505                	beqz	a0,ffffffffc0203e8a <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc0203e64:	e408                	sd	a0,8(s0)
ffffffffc0203e66:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203e68:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203e6c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203e70:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203e74:	000af797          	auipc	a5,0xaf
ffffffffc0203e78:	9b47a783          	lw	a5,-1612(a5) # ffffffffc02b2828 <swap_init_ok>
ffffffffc0203e7c:	ef81                	bnez	a5,ffffffffc0203e94 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0203e7e:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0203e82:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0203e86:	02043c23          	sd	zero,56(s0)
}
ffffffffc0203e8a:	60a2                	ld	ra,8(sp)
ffffffffc0203e8c:	8522                	mv	a0,s0
ffffffffc0203e8e:	6402                	ld	s0,0(sp)
ffffffffc0203e90:	0141                	addi	sp,sp,16
ffffffffc0203e92:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203e94:	a81ff0ef          	jal	ra,ffffffffc0203914 <swap_init_mm>
ffffffffc0203e98:	b7ed                	j	ffffffffc0203e82 <mm_create+0x30>

ffffffffc0203e9a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203e9a:	1101                	addi	sp,sp,-32
ffffffffc0203e9c:	e04a                	sd	s2,0(sp)
ffffffffc0203e9e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ea0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203ea4:	e822                	sd	s0,16(sp)
ffffffffc0203ea6:	e426                	sd	s1,8(sp)
ffffffffc0203ea8:	ec06                	sd	ra,24(sp)
ffffffffc0203eaa:	84ae                	mv	s1,a1
ffffffffc0203eac:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203eae:	c31fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
    if (vma != NULL) {
ffffffffc0203eb2:	c509                	beqz	a0,ffffffffc0203ebc <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203eb4:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203eb8:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203eba:	cd00                	sw	s0,24(a0)
}
ffffffffc0203ebc:	60e2                	ld	ra,24(sp)
ffffffffc0203ebe:	6442                	ld	s0,16(sp)
ffffffffc0203ec0:	64a2                	ld	s1,8(sp)
ffffffffc0203ec2:	6902                	ld	s2,0(sp)
ffffffffc0203ec4:	6105                	addi	sp,sp,32
ffffffffc0203ec6:	8082                	ret

ffffffffc0203ec8 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0203ec8:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0203eca:	c505                	beqz	a0,ffffffffc0203ef2 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203ecc:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203ece:	c501                	beqz	a0,ffffffffc0203ed6 <find_vma+0xe>
ffffffffc0203ed0:	651c                	ld	a5,8(a0)
ffffffffc0203ed2:	02f5f263          	bgeu	a1,a5,ffffffffc0203ef6 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203ed6:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0203ed8:	00f68d63          	beq	a3,a5,ffffffffc0203ef2 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203edc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203ee0:	00e5e663          	bltu	a1,a4,ffffffffc0203eec <find_vma+0x24>
ffffffffc0203ee4:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203ee8:	00e5ec63          	bltu	a1,a4,ffffffffc0203f00 <find_vma+0x38>
ffffffffc0203eec:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203eee:	fef697e3          	bne	a3,a5,ffffffffc0203edc <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203ef2:	4501                	li	a0,0
}
ffffffffc0203ef4:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203ef6:	691c                	ld	a5,16(a0)
ffffffffc0203ef8:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203ed6 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203efc:	ea88                	sd	a0,16(a3)
ffffffffc0203efe:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203f00:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203f04:	ea88                	sd	a0,16(a3)
ffffffffc0203f06:	8082                	ret

ffffffffc0203f08 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203f08:	6590                	ld	a2,8(a1)
ffffffffc0203f0a:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8ba0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203f0e:	1141                	addi	sp,sp,-16
ffffffffc0203f10:	e406                	sd	ra,8(sp)
ffffffffc0203f12:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203f14:	01066763          	bltu	a2,a6,ffffffffc0203f22 <insert_vma_struct+0x1a>
ffffffffc0203f18:	a085                	j	ffffffffc0203f78 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203f1a:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203f1e:	04e66863          	bltu	a2,a4,ffffffffc0203f6e <insert_vma_struct+0x66>
ffffffffc0203f22:	86be                	mv	a3,a5
ffffffffc0203f24:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203f26:	fef51ae3          	bne	a0,a5,ffffffffc0203f1a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203f2a:	02a68463          	beq	a3,a0,ffffffffc0203f52 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203f2e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203f32:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203f36:	08e8f163          	bgeu	a7,a4,ffffffffc0203fb8 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203f3a:	04e66f63          	bltu	a2,a4,ffffffffc0203f98 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0203f3e:	00f50a63          	beq	a0,a5,ffffffffc0203f52 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203f42:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203f46:	05076963          	bltu	a4,a6,ffffffffc0203f98 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203f4a:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203f4e:	02c77363          	bgeu	a4,a2,ffffffffc0203f74 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203f52:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203f54:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203f56:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203f5a:	e390                	sd	a2,0(a5)
ffffffffc0203f5c:	e690                	sd	a2,8(a3)
}
ffffffffc0203f5e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203f60:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203f62:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0203f64:	0017079b          	addiw	a5,a4,1
ffffffffc0203f68:	d11c                	sw	a5,32(a0)
}
ffffffffc0203f6a:	0141                	addi	sp,sp,16
ffffffffc0203f6c:	8082                	ret
    if (le_prev != list) {
ffffffffc0203f6e:	fca690e3          	bne	a3,a0,ffffffffc0203f2e <insert_vma_struct+0x26>
ffffffffc0203f72:	bfd1                	j	ffffffffc0203f46 <insert_vma_struct+0x3e>
ffffffffc0203f74:	ebbff0ef          	jal	ra,ffffffffc0203e2e <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203f78:	00003697          	auipc	a3,0x3
ffffffffc0203f7c:	63068693          	addi	a3,a3,1584 # ffffffffc02075a8 <default_pmm_manager+0xc30>
ffffffffc0203f80:	00002617          	auipc	a2,0x2
ffffffffc0203f84:	36060613          	addi	a2,a2,864 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203f88:	07400593          	li	a1,116
ffffffffc0203f8c:	00003517          	auipc	a0,0x3
ffffffffc0203f90:	60c50513          	addi	a0,a0,1548 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc0203f94:	ce6fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203f98:	00003697          	auipc	a3,0x3
ffffffffc0203f9c:	65068693          	addi	a3,a3,1616 # ffffffffc02075e8 <default_pmm_manager+0xc70>
ffffffffc0203fa0:	00002617          	auipc	a2,0x2
ffffffffc0203fa4:	34060613          	addi	a2,a2,832 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203fa8:	06c00593          	li	a1,108
ffffffffc0203fac:	00003517          	auipc	a0,0x3
ffffffffc0203fb0:	5ec50513          	addi	a0,a0,1516 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc0203fb4:	cc6fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203fb8:	00003697          	auipc	a3,0x3
ffffffffc0203fbc:	61068693          	addi	a3,a3,1552 # ffffffffc02075c8 <default_pmm_manager+0xc50>
ffffffffc0203fc0:	00002617          	auipc	a2,0x2
ffffffffc0203fc4:	32060613          	addi	a2,a2,800 # ffffffffc02062e0 <commands+0x450>
ffffffffc0203fc8:	06b00593          	li	a1,107
ffffffffc0203fcc:	00003517          	auipc	a0,0x3
ffffffffc0203fd0:	5cc50513          	addi	a0,a0,1484 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc0203fd4:	ca6fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203fd8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0203fd8:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0203fda:	1141                	addi	sp,sp,-16
ffffffffc0203fdc:	e406                	sd	ra,8(sp)
ffffffffc0203fde:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203fe0:	e78d                	bnez	a5,ffffffffc020400a <mm_destroy+0x32>
ffffffffc0203fe2:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203fe4:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203fe6:	00a40c63          	beq	s0,a0,ffffffffc0203ffe <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203fea:	6118                	ld	a4,0(a0)
ffffffffc0203fec:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203fee:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203ff0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203ff2:	e398                	sd	a4,0(a5)
ffffffffc0203ff4:	b9bfd0ef          	jal	ra,ffffffffc0201b8e <kfree>
    return listelm->next;
ffffffffc0203ff8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203ffa:	fea418e3          	bne	s0,a0,ffffffffc0203fea <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0203ffe:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204000:	6402                	ld	s0,0(sp)
ffffffffc0204002:	60a2                	ld	ra,8(sp)
ffffffffc0204004:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0204006:	b89fd06f          	j	ffffffffc0201b8e <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020400a:	00003697          	auipc	a3,0x3
ffffffffc020400e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0207608 <default_pmm_manager+0xc90>
ffffffffc0204012:	00002617          	auipc	a2,0x2
ffffffffc0204016:	2ce60613          	addi	a2,a2,718 # ffffffffc02062e0 <commands+0x450>
ffffffffc020401a:	09400593          	li	a1,148
ffffffffc020401e:	00003517          	auipc	a0,0x3
ffffffffc0204022:	57a50513          	addi	a0,a0,1402 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc0204026:	c54fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020402a <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc020402a:	7139                	addi	sp,sp,-64
ffffffffc020402c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020402e:	6405                	lui	s0,0x1
ffffffffc0204030:	147d                	addi	s0,s0,-1
ffffffffc0204032:	77fd                	lui	a5,0xfffff
ffffffffc0204034:	9622                	add	a2,a2,s0
ffffffffc0204036:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0204038:	f426                	sd	s1,40(sp)
ffffffffc020403a:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020403c:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0204040:	f04a                	sd	s2,32(sp)
ffffffffc0204042:	ec4e                	sd	s3,24(sp)
ffffffffc0204044:	e852                	sd	s4,16(sp)
ffffffffc0204046:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0204048:	002005b7          	lui	a1,0x200
ffffffffc020404c:	00f67433          	and	s0,a2,a5
ffffffffc0204050:	06b4e363          	bltu	s1,a1,ffffffffc02040b6 <mm_map+0x8c>
ffffffffc0204054:	0684f163          	bgeu	s1,s0,ffffffffc02040b6 <mm_map+0x8c>
ffffffffc0204058:	4785                	li	a5,1
ffffffffc020405a:	07fe                	slli	a5,a5,0x1f
ffffffffc020405c:	0487ed63          	bltu	a5,s0,ffffffffc02040b6 <mm_map+0x8c>
ffffffffc0204060:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0204062:	cd21                	beqz	a0,ffffffffc02040ba <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0204064:	85a6                	mv	a1,s1
ffffffffc0204066:	8ab6                	mv	s5,a3
ffffffffc0204068:	8a3a                	mv	s4,a4
ffffffffc020406a:	e5fff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
ffffffffc020406e:	c501                	beqz	a0,ffffffffc0204076 <mm_map+0x4c>
ffffffffc0204070:	651c                	ld	a5,8(a0)
ffffffffc0204072:	0487e263          	bltu	a5,s0,ffffffffc02040b6 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204076:	03000513          	li	a0,48
ffffffffc020407a:	a65fd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc020407e:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204080:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204082:	02090163          	beqz	s2,ffffffffc02040a4 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0204086:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0204088:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020408c:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204090:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204094:	85ca                	mv	a1,s2
ffffffffc0204096:	e73ff0ef          	jal	ra,ffffffffc0203f08 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020409a:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020409c:	000a0463          	beqz	s4,ffffffffc02040a4 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc02040a0:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02040a4:	70e2                	ld	ra,56(sp)
ffffffffc02040a6:	7442                	ld	s0,48(sp)
ffffffffc02040a8:	74a2                	ld	s1,40(sp)
ffffffffc02040aa:	7902                	ld	s2,32(sp)
ffffffffc02040ac:	69e2                	ld	s3,24(sp)
ffffffffc02040ae:	6a42                	ld	s4,16(sp)
ffffffffc02040b0:	6aa2                	ld	s5,8(sp)
ffffffffc02040b2:	6121                	addi	sp,sp,64
ffffffffc02040b4:	8082                	ret
        return -E_INVAL;
ffffffffc02040b6:	5575                	li	a0,-3
ffffffffc02040b8:	b7f5                	j	ffffffffc02040a4 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc02040ba:	00003697          	auipc	a3,0x3
ffffffffc02040be:	01668693          	addi	a3,a3,22 # ffffffffc02070d0 <default_pmm_manager+0x758>
ffffffffc02040c2:	00002617          	auipc	a2,0x2
ffffffffc02040c6:	21e60613          	addi	a2,a2,542 # ffffffffc02062e0 <commands+0x450>
ffffffffc02040ca:	0a700593          	li	a1,167
ffffffffc02040ce:	00003517          	auipc	a0,0x3
ffffffffc02040d2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02040d6:	ba4fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02040da <exit_mmap>:
    }
    return 0;
}

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02040da:	1101                	addi	sp,sp,-32
ffffffffc02040dc:	ec06                	sd	ra,24(sp)
ffffffffc02040de:	e822                	sd	s0,16(sp)
ffffffffc02040e0:	e426                	sd	s1,8(sp)
ffffffffc02040e2:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02040e4:	c531                	beqz	a0,ffffffffc0204130 <exit_mmap+0x56>
ffffffffc02040e6:	591c                	lw	a5,48(a0)
ffffffffc02040e8:	84aa                	mv	s1,a0
ffffffffc02040ea:	e3b9                	bnez	a5,ffffffffc0204130 <exit_mmap+0x56>
ffffffffc02040ec:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02040ee:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02040f2:	02850663          	beq	a0,s0,ffffffffc020411e <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02040f6:	ff043603          	ld	a2,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc02040fa:	fe843583          	ld	a1,-24(s0)
ffffffffc02040fe:	854a                	mv	a0,s2
ffffffffc0204100:	eeffd0ef          	jal	ra,ffffffffc0201fee <unmap_range>
ffffffffc0204104:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204106:	fe8498e3          	bne	s1,s0,ffffffffc02040f6 <exit_mmap+0x1c>
ffffffffc020410a:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020410c:	00848c63          	beq	s1,s0,ffffffffc0204124 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204110:	ff043603          	ld	a2,-16(s0)
ffffffffc0204114:	fe843583          	ld	a1,-24(s0)
ffffffffc0204118:	854a                	mv	a0,s2
ffffffffc020411a:	81afe0ef          	jal	ra,ffffffffc0202134 <exit_range>
ffffffffc020411e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204120:	fe8498e3          	bne	s1,s0,ffffffffc0204110 <exit_mmap+0x36>
    }
}
ffffffffc0204124:	60e2                	ld	ra,24(sp)
ffffffffc0204126:	6442                	ld	s0,16(sp)
ffffffffc0204128:	64a2                	ld	s1,8(sp)
ffffffffc020412a:	6902                	ld	s2,0(sp)
ffffffffc020412c:	6105                	addi	sp,sp,32
ffffffffc020412e:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204130:	00003697          	auipc	a3,0x3
ffffffffc0204134:	4f068693          	addi	a3,a3,1264 # ffffffffc0207620 <default_pmm_manager+0xca8>
ffffffffc0204138:	00002617          	auipc	a2,0x2
ffffffffc020413c:	1a860613          	addi	a2,a2,424 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204140:	0d600593          	li	a1,214
ffffffffc0204144:	00003517          	auipc	a0,0x3
ffffffffc0204148:	45450513          	addi	a0,a0,1108 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020414c:	b2efc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204150 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204150:	7139                	addi	sp,sp,-64
ffffffffc0204152:	f822                	sd	s0,48(sp)
ffffffffc0204154:	f426                	sd	s1,40(sp)
ffffffffc0204156:	fc06                	sd	ra,56(sp)
ffffffffc0204158:	f04a                	sd	s2,32(sp)
ffffffffc020415a:	ec4e                	sd	s3,24(sp)
ffffffffc020415c:	e852                	sd	s4,16(sp)
ffffffffc020415e:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204160:	cf3ff0ef          	jal	ra,ffffffffc0203e52 <mm_create>
    assert(mm != NULL);
ffffffffc0204164:	84aa                	mv	s1,a0
ffffffffc0204166:	03200413          	li	s0,50
ffffffffc020416a:	e919                	bnez	a0,ffffffffc0204180 <vmm_init+0x30>
ffffffffc020416c:	a991                	j	ffffffffc02045c0 <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc020416e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204170:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204172:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0204176:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204178:	8526                	mv	a0,s1
ffffffffc020417a:	d8fff0ef          	jal	ra,ffffffffc0203f08 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020417e:	c80d                	beqz	s0,ffffffffc02041b0 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204180:	03000513          	li	a0,48
ffffffffc0204184:	95bfd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc0204188:	85aa                	mv	a1,a0
ffffffffc020418a:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020418e:	f165                	bnez	a0,ffffffffc020416e <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204190:	00003697          	auipc	a3,0x3
ffffffffc0204194:	f7868693          	addi	a3,a3,-136 # ffffffffc0207108 <default_pmm_manager+0x790>
ffffffffc0204198:	00002617          	auipc	a2,0x2
ffffffffc020419c:	14860613          	addi	a2,a2,328 # ffffffffc02062e0 <commands+0x450>
ffffffffc02041a0:	11300593          	li	a1,275
ffffffffc02041a4:	00003517          	auipc	a0,0x3
ffffffffc02041a8:	3f450513          	addi	a0,a0,1012 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02041ac:	acefc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02041b0:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02041b4:	1f900913          	li	s2,505
ffffffffc02041b8:	a819                	j	ffffffffc02041ce <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02041ba:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02041bc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02041be:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02041c2:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02041c4:	8526                	mv	a0,s1
ffffffffc02041c6:	d43ff0ef          	jal	ra,ffffffffc0203f08 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02041ca:	03240a63          	beq	s0,s2,ffffffffc02041fe <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02041ce:	03000513          	li	a0,48
ffffffffc02041d2:	90dfd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc02041d6:	85aa                	mv	a1,a0
ffffffffc02041d8:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02041dc:	fd79                	bnez	a0,ffffffffc02041ba <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02041de:	00003697          	auipc	a3,0x3
ffffffffc02041e2:	f2a68693          	addi	a3,a3,-214 # ffffffffc0207108 <default_pmm_manager+0x790>
ffffffffc02041e6:	00002617          	auipc	a2,0x2
ffffffffc02041ea:	0fa60613          	addi	a2,a2,250 # ffffffffc02062e0 <commands+0x450>
ffffffffc02041ee:	11900593          	li	a1,281
ffffffffc02041f2:	00003517          	auipc	a0,0x3
ffffffffc02041f6:	3a650513          	addi	a0,a0,934 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02041fa:	a80fc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02041fe:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0204200:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0204202:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204206:	2cf48d63          	beq	s1,a5,ffffffffc02044e0 <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020420a:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c78c>
ffffffffc020420e:	ffe70613          	addi	a2,a4,-2
ffffffffc0204212:	24d61763          	bne	a2,a3,ffffffffc0204460 <vmm_init+0x310>
ffffffffc0204216:	ff07b683          	ld	a3,-16(a5)
ffffffffc020421a:	24e69363          	bne	a3,a4,ffffffffc0204460 <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc020421e:	0715                	addi	a4,a4,5
ffffffffc0204220:	679c                	ld	a5,8(a5)
ffffffffc0204222:	feb712e3          	bne	a4,a1,ffffffffc0204206 <vmm_init+0xb6>
ffffffffc0204226:	4a1d                	li	s4,7
ffffffffc0204228:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020422a:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020422e:	85a2                	mv	a1,s0
ffffffffc0204230:	8526                	mv	a0,s1
ffffffffc0204232:	c97ff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
ffffffffc0204236:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0204238:	30050463          	beqz	a0,ffffffffc0204540 <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020423c:	00140593          	addi	a1,s0,1
ffffffffc0204240:	8526                	mv	a0,s1
ffffffffc0204242:	c87ff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
ffffffffc0204246:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204248:	2c050c63          	beqz	a0,ffffffffc0204520 <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020424c:	85d2                	mv	a1,s4
ffffffffc020424e:	8526                	mv	a0,s1
ffffffffc0204250:	c79ff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204254:	2a051663          	bnez	a0,ffffffffc0204500 <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0204258:	00340593          	addi	a1,s0,3
ffffffffc020425c:	8526                	mv	a0,s1
ffffffffc020425e:	c6bff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204262:	30051f63          	bnez	a0,ffffffffc0204580 <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204266:	00440593          	addi	a1,s0,4
ffffffffc020426a:	8526                	mv	a0,s1
ffffffffc020426c:	c5dff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204270:	2e051863          	bnez	a0,ffffffffc0204560 <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204274:	00893783          	ld	a5,8(s2)
ffffffffc0204278:	20879463          	bne	a5,s0,ffffffffc0204480 <vmm_init+0x330>
ffffffffc020427c:	01093783          	ld	a5,16(s2)
ffffffffc0204280:	20fa1063          	bne	s4,a5,ffffffffc0204480 <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204284:	0089b783          	ld	a5,8(s3)
ffffffffc0204288:	20879c63          	bne	a5,s0,ffffffffc02044a0 <vmm_init+0x350>
ffffffffc020428c:	0109b783          	ld	a5,16(s3)
ffffffffc0204290:	20fa1863          	bne	s4,a5,ffffffffc02044a0 <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204294:	0415                	addi	s0,s0,5
ffffffffc0204296:	0a15                	addi	s4,s4,5
ffffffffc0204298:	f9541be3          	bne	s0,s5,ffffffffc020422e <vmm_init+0xde>
ffffffffc020429c:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020429e:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02042a0:	85a2                	mv	a1,s0
ffffffffc02042a2:	8526                	mv	a0,s1
ffffffffc02042a4:	c25ff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
ffffffffc02042a8:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02042ac:	c90d                	beqz	a0,ffffffffc02042de <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02042ae:	6914                	ld	a3,16(a0)
ffffffffc02042b0:	6510                	ld	a2,8(a0)
ffffffffc02042b2:	00003517          	auipc	a0,0x3
ffffffffc02042b6:	48e50513          	addi	a0,a0,1166 # ffffffffc0207740 <default_pmm_manager+0xdc8>
ffffffffc02042ba:	ec7fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02042be:	00003697          	auipc	a3,0x3
ffffffffc02042c2:	4aa68693          	addi	a3,a3,1194 # ffffffffc0207768 <default_pmm_manager+0xdf0>
ffffffffc02042c6:	00002617          	auipc	a2,0x2
ffffffffc02042ca:	01a60613          	addi	a2,a2,26 # ffffffffc02062e0 <commands+0x450>
ffffffffc02042ce:	13b00593          	li	a1,315
ffffffffc02042d2:	00003517          	auipc	a0,0x3
ffffffffc02042d6:	2c650513          	addi	a0,a0,710 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02042da:	9a0fc0ef          	jal	ra,ffffffffc020047a <__panic>
    for (i =4; i>=0; i--) {
ffffffffc02042de:	147d                	addi	s0,s0,-1
ffffffffc02042e0:	fd2410e3          	bne	s0,s2,ffffffffc02042a0 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02042e4:	8526                	mv	a0,s1
ffffffffc02042e6:	cf3ff0ef          	jal	ra,ffffffffc0203fd8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02042ea:	00003517          	auipc	a0,0x3
ffffffffc02042ee:	49650513          	addi	a0,a0,1174 # ffffffffc0207780 <default_pmm_manager+0xe08>
ffffffffc02042f2:	e8ffb0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02042f6:	a99fd0ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
ffffffffc02042fa:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc02042fc:	b57ff0ef          	jal	ra,ffffffffc0203e52 <mm_create>
ffffffffc0204300:	000ae797          	auipc	a5,0xae
ffffffffc0204304:	52a7b823          	sd	a0,1328(a5) # ffffffffc02b2830 <check_mm_struct>
ffffffffc0204308:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc020430a:	28050b63          	beqz	a0,ffffffffc02045a0 <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020430e:	000ae497          	auipc	s1,0xae
ffffffffc0204312:	4e24b483          	ld	s1,1250(s1) # ffffffffc02b27f0 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0204316:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204318:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020431a:	2e079f63          	bnez	a5,ffffffffc0204618 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020431e:	03000513          	li	a0,48
ffffffffc0204322:	fbcfd0ef          	jal	ra,ffffffffc0201ade <kmalloc>
ffffffffc0204326:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0204328:	18050c63          	beqz	a0,ffffffffc02044c0 <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc020432c:	002007b7          	lui	a5,0x200
ffffffffc0204330:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0204334:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204336:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204338:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc020433c:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020433e:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0204342:	bc7ff0ef          	jal	ra,ffffffffc0203f08 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204346:	10000593          	li	a1,256
ffffffffc020434a:	8522                	mv	a0,s0
ffffffffc020434c:	b7dff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
ffffffffc0204350:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0204354:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204358:	2ea99063          	bne	s3,a0,ffffffffc0204638 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc020435c:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed8>
    for (i = 0; i < 100; i ++) {
ffffffffc0204360:	0785                	addi	a5,a5,1
ffffffffc0204362:	fee79de3          	bne	a5,a4,ffffffffc020435c <vmm_init+0x20c>
        sum += i;
ffffffffc0204366:	6705                	lui	a4,0x1
ffffffffc0204368:	10000793          	li	a5,256
ffffffffc020436c:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x885a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204370:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0204374:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0204378:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc020437a:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020437c:	fec79ce3          	bne	a5,a2,ffffffffc0204374 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc0204380:	2e071863          	bnez	a4,ffffffffc0204670 <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204384:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0204386:	000aea97          	auipc	s5,0xae
ffffffffc020438a:	472a8a93          	addi	s5,s5,1138 # ffffffffc02b27f8 <npage>
ffffffffc020438e:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204392:	078a                	slli	a5,a5,0x2
ffffffffc0204394:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204396:	2cc7f163          	bgeu	a5,a2,ffffffffc0204658 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020439a:	00004a17          	auipc	s4,0x4
ffffffffc020439e:	e76a3a03          	ld	s4,-394(s4) # ffffffffc0208210 <nbase>
ffffffffc02043a2:	414787b3          	sub	a5,a5,s4
ffffffffc02043a6:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc02043a8:	8799                	srai	a5,a5,0x6
ffffffffc02043aa:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc02043ac:	00c79713          	slli	a4,a5,0xc
ffffffffc02043b0:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02043b2:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02043b6:	24c77563          	bgeu	a4,a2,ffffffffc0204600 <vmm_init+0x4b0>
ffffffffc02043ba:	000ae997          	auipc	s3,0xae
ffffffffc02043be:	4569b983          	ld	s3,1110(s3) # ffffffffc02b2810 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02043c2:	4581                	li	a1,0
ffffffffc02043c4:	8526                	mv	a0,s1
ffffffffc02043c6:	99b6                	add	s3,s3,a3
ffffffffc02043c8:	ffffd0ef          	jal	ra,ffffffffc02023c6 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02043cc:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02043d0:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02043d4:	078a                	slli	a5,a5,0x2
ffffffffc02043d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02043d8:	28e7f063          	bgeu	a5,a4,ffffffffc0204658 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02043dc:	000ae997          	auipc	s3,0xae
ffffffffc02043e0:	42498993          	addi	s3,s3,1060 # ffffffffc02b2800 <pages>
ffffffffc02043e4:	0009b503          	ld	a0,0(s3)
ffffffffc02043e8:	414787b3          	sub	a5,a5,s4
ffffffffc02043ec:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02043ee:	953e                	add	a0,a0,a5
ffffffffc02043f0:	4585                	li	a1,1
ffffffffc02043f2:	95dfd0ef          	jal	ra,ffffffffc0201d4e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02043f6:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02043f8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02043fc:	078a                	slli	a5,a5,0x2
ffffffffc02043fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204400:	24e7fc63          	bgeu	a5,a4,ffffffffc0204658 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204404:	0009b503          	ld	a0,0(s3)
ffffffffc0204408:	414787b3          	sub	a5,a5,s4
ffffffffc020440c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020440e:	4585                	li	a1,1
ffffffffc0204410:	953e                	add	a0,a0,a5
ffffffffc0204412:	93dfd0ef          	jal	ra,ffffffffc0201d4e <free_pages>
    pgdir[0] = 0;
ffffffffc0204416:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc020441a:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020441e:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0204420:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0204424:	bb5ff0ef          	jal	ra,ffffffffc0203fd8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204428:	000ae797          	auipc	a5,0xae
ffffffffc020442c:	4007b423          	sd	zero,1032(a5) # ffffffffc02b2830 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204430:	95ffd0ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
ffffffffc0204434:	1aa91663          	bne	s2,a0,ffffffffc02045e0 <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204438:	00003517          	auipc	a0,0x3
ffffffffc020443c:	3d850513          	addi	a0,a0,984 # ffffffffc0207810 <default_pmm_manager+0xe98>
ffffffffc0204440:	d41fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0204444:	7442                	ld	s0,48(sp)
ffffffffc0204446:	70e2                	ld	ra,56(sp)
ffffffffc0204448:	74a2                	ld	s1,40(sp)
ffffffffc020444a:	7902                	ld	s2,32(sp)
ffffffffc020444c:	69e2                	ld	s3,24(sp)
ffffffffc020444e:	6a42                	ld	s4,16(sp)
ffffffffc0204450:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204452:	00003517          	auipc	a0,0x3
ffffffffc0204456:	3de50513          	addi	a0,a0,990 # ffffffffc0207830 <default_pmm_manager+0xeb8>
}
ffffffffc020445a:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020445c:	d25fb06f          	j	ffffffffc0200180 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204460:	00003697          	auipc	a3,0x3
ffffffffc0204464:	1f868693          	addi	a3,a3,504 # ffffffffc0207658 <default_pmm_manager+0xce0>
ffffffffc0204468:	00002617          	auipc	a2,0x2
ffffffffc020446c:	e7860613          	addi	a2,a2,-392 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204470:	12200593          	li	a1,290
ffffffffc0204474:	00003517          	auipc	a0,0x3
ffffffffc0204478:	12450513          	addi	a0,a0,292 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020447c:	ffffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204480:	00003697          	auipc	a3,0x3
ffffffffc0204484:	26068693          	addi	a3,a3,608 # ffffffffc02076e0 <default_pmm_manager+0xd68>
ffffffffc0204488:	00002617          	auipc	a2,0x2
ffffffffc020448c:	e5860613          	addi	a2,a2,-424 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204490:	13200593          	li	a1,306
ffffffffc0204494:	00003517          	auipc	a0,0x3
ffffffffc0204498:	10450513          	addi	a0,a0,260 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020449c:	fdffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02044a0:	00003697          	auipc	a3,0x3
ffffffffc02044a4:	27068693          	addi	a3,a3,624 # ffffffffc0207710 <default_pmm_manager+0xd98>
ffffffffc02044a8:	00002617          	auipc	a2,0x2
ffffffffc02044ac:	e3860613          	addi	a2,a2,-456 # ffffffffc02062e0 <commands+0x450>
ffffffffc02044b0:	13300593          	li	a1,307
ffffffffc02044b4:	00003517          	auipc	a0,0x3
ffffffffc02044b8:	0e450513          	addi	a0,a0,228 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02044bc:	fbffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(vma != NULL);
ffffffffc02044c0:	00003697          	auipc	a3,0x3
ffffffffc02044c4:	c4868693          	addi	a3,a3,-952 # ffffffffc0207108 <default_pmm_manager+0x790>
ffffffffc02044c8:	00002617          	auipc	a2,0x2
ffffffffc02044cc:	e1860613          	addi	a2,a2,-488 # ffffffffc02062e0 <commands+0x450>
ffffffffc02044d0:	15200593          	li	a1,338
ffffffffc02044d4:	00003517          	auipc	a0,0x3
ffffffffc02044d8:	0c450513          	addi	a0,a0,196 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02044dc:	f9ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02044e0:	00003697          	auipc	a3,0x3
ffffffffc02044e4:	16068693          	addi	a3,a3,352 # ffffffffc0207640 <default_pmm_manager+0xcc8>
ffffffffc02044e8:	00002617          	auipc	a2,0x2
ffffffffc02044ec:	df860613          	addi	a2,a2,-520 # ffffffffc02062e0 <commands+0x450>
ffffffffc02044f0:	12000593          	li	a1,288
ffffffffc02044f4:	00003517          	auipc	a0,0x3
ffffffffc02044f8:	0a450513          	addi	a0,a0,164 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02044fc:	f7ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma3 == NULL);
ffffffffc0204500:	00003697          	auipc	a3,0x3
ffffffffc0204504:	1b068693          	addi	a3,a3,432 # ffffffffc02076b0 <default_pmm_manager+0xd38>
ffffffffc0204508:	00002617          	auipc	a2,0x2
ffffffffc020450c:	dd860613          	addi	a2,a2,-552 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204510:	12c00593          	li	a1,300
ffffffffc0204514:	00003517          	auipc	a0,0x3
ffffffffc0204518:	08450513          	addi	a0,a0,132 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020451c:	f5ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2 != NULL);
ffffffffc0204520:	00003697          	auipc	a3,0x3
ffffffffc0204524:	18068693          	addi	a3,a3,384 # ffffffffc02076a0 <default_pmm_manager+0xd28>
ffffffffc0204528:	00002617          	auipc	a2,0x2
ffffffffc020452c:	db860613          	addi	a2,a2,-584 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204530:	12a00593          	li	a1,298
ffffffffc0204534:	00003517          	auipc	a0,0x3
ffffffffc0204538:	06450513          	addi	a0,a0,100 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020453c:	f3ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1 != NULL);
ffffffffc0204540:	00003697          	auipc	a3,0x3
ffffffffc0204544:	15068693          	addi	a3,a3,336 # ffffffffc0207690 <default_pmm_manager+0xd18>
ffffffffc0204548:	00002617          	auipc	a2,0x2
ffffffffc020454c:	d9860613          	addi	a2,a2,-616 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204550:	12800593          	li	a1,296
ffffffffc0204554:	00003517          	auipc	a0,0x3
ffffffffc0204558:	04450513          	addi	a0,a0,68 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020455c:	f1ffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma5 == NULL);
ffffffffc0204560:	00003697          	auipc	a3,0x3
ffffffffc0204564:	17068693          	addi	a3,a3,368 # ffffffffc02076d0 <default_pmm_manager+0xd58>
ffffffffc0204568:	00002617          	auipc	a2,0x2
ffffffffc020456c:	d7860613          	addi	a2,a2,-648 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204570:	13000593          	li	a1,304
ffffffffc0204574:	00003517          	auipc	a0,0x3
ffffffffc0204578:	02450513          	addi	a0,a0,36 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020457c:	efffb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma4 == NULL);
ffffffffc0204580:	00003697          	auipc	a3,0x3
ffffffffc0204584:	14068693          	addi	a3,a3,320 # ffffffffc02076c0 <default_pmm_manager+0xd48>
ffffffffc0204588:	00002617          	auipc	a2,0x2
ffffffffc020458c:	d5860613          	addi	a2,a2,-680 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204590:	12e00593          	li	a1,302
ffffffffc0204594:	00003517          	auipc	a0,0x3
ffffffffc0204598:	00450513          	addi	a0,a0,4 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020459c:	edffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02045a0:	00003697          	auipc	a3,0x3
ffffffffc02045a4:	20068693          	addi	a3,a3,512 # ffffffffc02077a0 <default_pmm_manager+0xe28>
ffffffffc02045a8:	00002617          	auipc	a2,0x2
ffffffffc02045ac:	d3860613          	addi	a2,a2,-712 # ffffffffc02062e0 <commands+0x450>
ffffffffc02045b0:	14b00593          	li	a1,331
ffffffffc02045b4:	00003517          	auipc	a0,0x3
ffffffffc02045b8:	fe450513          	addi	a0,a0,-28 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02045bc:	ebffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(mm != NULL);
ffffffffc02045c0:	00003697          	auipc	a3,0x3
ffffffffc02045c4:	b1068693          	addi	a3,a3,-1264 # ffffffffc02070d0 <default_pmm_manager+0x758>
ffffffffc02045c8:	00002617          	auipc	a2,0x2
ffffffffc02045cc:	d1860613          	addi	a2,a2,-744 # ffffffffc02062e0 <commands+0x450>
ffffffffc02045d0:	10c00593          	li	a1,268
ffffffffc02045d4:	00003517          	auipc	a0,0x3
ffffffffc02045d8:	fc450513          	addi	a0,a0,-60 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02045dc:	e9ffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02045e0:	00003697          	auipc	a3,0x3
ffffffffc02045e4:	20868693          	addi	a3,a3,520 # ffffffffc02077e8 <default_pmm_manager+0xe70>
ffffffffc02045e8:	00002617          	auipc	a2,0x2
ffffffffc02045ec:	cf860613          	addi	a2,a2,-776 # ffffffffc02062e0 <commands+0x450>
ffffffffc02045f0:	17000593          	li	a1,368
ffffffffc02045f4:	00003517          	auipc	a0,0x3
ffffffffc02045f8:	fa450513          	addi	a0,a0,-92 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc02045fc:	e7ffb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204600:	00002617          	auipc	a2,0x2
ffffffffc0204604:	3b060613          	addi	a2,a2,944 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0204608:	06900593          	li	a1,105
ffffffffc020460c:	00002517          	auipc	a0,0x2
ffffffffc0204610:	3cc50513          	addi	a0,a0,972 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204614:	e67fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204618:	00003697          	auipc	a3,0x3
ffffffffc020461c:	ae068693          	addi	a3,a3,-1312 # ffffffffc02070f8 <default_pmm_manager+0x780>
ffffffffc0204620:	00002617          	auipc	a2,0x2
ffffffffc0204624:	cc060613          	addi	a2,a2,-832 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204628:	14f00593          	li	a1,335
ffffffffc020462c:	00003517          	auipc	a0,0x3
ffffffffc0204630:	f6c50513          	addi	a0,a0,-148 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc0204634:	e47fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204638:	00003697          	auipc	a3,0x3
ffffffffc020463c:	18068693          	addi	a3,a3,384 # ffffffffc02077b8 <default_pmm_manager+0xe40>
ffffffffc0204640:	00002617          	auipc	a2,0x2
ffffffffc0204644:	ca060613          	addi	a2,a2,-864 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204648:	15700593          	li	a1,343
ffffffffc020464c:	00003517          	auipc	a0,0x3
ffffffffc0204650:	f4c50513          	addi	a0,a0,-180 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc0204654:	e27fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204658:	00002617          	auipc	a2,0x2
ffffffffc020465c:	42860613          	addi	a2,a2,1064 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc0204660:	06200593          	li	a1,98
ffffffffc0204664:	00002517          	auipc	a0,0x2
ffffffffc0204668:	37450513          	addi	a0,a0,884 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc020466c:	e0ffb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(sum == 0);
ffffffffc0204670:	00003697          	auipc	a3,0x3
ffffffffc0204674:	16868693          	addi	a3,a3,360 # ffffffffc02077d8 <default_pmm_manager+0xe60>
ffffffffc0204678:	00002617          	auipc	a2,0x2
ffffffffc020467c:	c6860613          	addi	a2,a2,-920 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204680:	16300593          	li	a1,355
ffffffffc0204684:	00003517          	auipc	a0,0x3
ffffffffc0204688:	f1450513          	addi	a0,a0,-236 # ffffffffc0207598 <default_pmm_manager+0xc20>
ffffffffc020468c:	deffb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204690 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204690:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204692:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204694:	e822                	sd	s0,16(sp)
ffffffffc0204696:	e426                	sd	s1,8(sp)
ffffffffc0204698:	ec06                	sd	ra,24(sp)
ffffffffc020469a:	e04a                	sd	s2,0(sp)
ffffffffc020469c:	8432                	mv	s0,a2
ffffffffc020469e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02046a0:	829ff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>

    pgfault_num++;
ffffffffc02046a4:	000ae797          	auipc	a5,0xae
ffffffffc02046a8:	1947a783          	lw	a5,404(a5) # ffffffffc02b2838 <pgfault_num>
ffffffffc02046ac:	2785                	addiw	a5,a5,1
ffffffffc02046ae:	000ae717          	auipc	a4,0xae
ffffffffc02046b2:	18f72523          	sw	a5,394(a4) # ffffffffc02b2838 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02046b6:	c931                	beqz	a0,ffffffffc020470a <do_pgfault+0x7a>
ffffffffc02046b8:	651c                	ld	a5,8(a0)
ffffffffc02046ba:	04f46863          	bltu	s0,a5,ffffffffc020470a <do_pgfault+0x7a>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02046be:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02046c0:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02046c2:	8b89                	andi	a5,a5,2
ffffffffc02046c4:	e39d                	bnez	a5,ffffffffc02046ea <do_pgfault+0x5a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02046c6:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02046c8:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02046ca:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02046cc:	4605                	li	a2,1
ffffffffc02046ce:	85a2                	mv	a1,s0
ffffffffc02046d0:	ef8fd0ef          	jal	ra,ffffffffc0201dc8 <get_pte>
ffffffffc02046d4:	cd21                	beqz	a0,ffffffffc020472c <do_pgfault+0x9c>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02046d6:	610c                	ld	a1,0(a0)
ffffffffc02046d8:	c999                	beqz	a1,ffffffffc02046ee <do_pgfault+0x5e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02046da:	000ae797          	auipc	a5,0xae
ffffffffc02046de:	14e7a783          	lw	a5,334(a5) # ffffffffc02b2828 <swap_init_ok>
ffffffffc02046e2:	cf8d                	beqz	a5,ffffffffc020471c <do_pgfault+0x8c>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc02046e4:	02003c23          	sd	zero,56(zero) # 38 <_binary_obj___user_faultread_out_size-0x9b78>
ffffffffc02046e8:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc02046ea:	495d                	li	s2,23
ffffffffc02046ec:	bfe9                	j	ffffffffc02046c6 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02046ee:	6c88                	ld	a0,24(s1)
ffffffffc02046f0:	864a                	mv	a2,s2
ffffffffc02046f2:	85a2                	mv	a1,s0
ffffffffc02046f4:	a05fe0ef          	jal	ra,ffffffffc02030f8 <pgdir_alloc_page>
ffffffffc02046f8:	87aa                	mv	a5,a0
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc02046fa:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02046fc:	c3a1                	beqz	a5,ffffffffc020473c <do_pgfault+0xac>
failed:
    return ret;
}
ffffffffc02046fe:	60e2                	ld	ra,24(sp)
ffffffffc0204700:	6442                	ld	s0,16(sp)
ffffffffc0204702:	64a2                	ld	s1,8(sp)
ffffffffc0204704:	6902                	ld	s2,0(sp)
ffffffffc0204706:	6105                	addi	sp,sp,32
ffffffffc0204708:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020470a:	85a2                	mv	a1,s0
ffffffffc020470c:	00003517          	auipc	a0,0x3
ffffffffc0204710:	13c50513          	addi	a0,a0,316 # ffffffffc0207848 <default_pmm_manager+0xed0>
ffffffffc0204714:	a6dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204718:	5575                	li	a0,-3
        goto failed;
ffffffffc020471a:	b7d5                	j	ffffffffc02046fe <do_pgfault+0x6e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020471c:	00003517          	auipc	a0,0x3
ffffffffc0204720:	1a450513          	addi	a0,a0,420 # ffffffffc02078c0 <default_pmm_manager+0xf48>
ffffffffc0204724:	a5dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204728:	5571                	li	a0,-4
            goto failed;
ffffffffc020472a:	bfd1                	j	ffffffffc02046fe <do_pgfault+0x6e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020472c:	00003517          	auipc	a0,0x3
ffffffffc0204730:	14c50513          	addi	a0,a0,332 # ffffffffc0207878 <default_pmm_manager+0xf00>
ffffffffc0204734:	a4dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204738:	5571                	li	a0,-4
        goto failed;
ffffffffc020473a:	b7d1                	j	ffffffffc02046fe <do_pgfault+0x6e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020473c:	00003517          	auipc	a0,0x3
ffffffffc0204740:	15c50513          	addi	a0,a0,348 # ffffffffc0207898 <default_pmm_manager+0xf20>
ffffffffc0204744:	a3dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204748:	5571                	li	a0,-4
            goto failed;
ffffffffc020474a:	bf55                	j	ffffffffc02046fe <do_pgfault+0x6e>

ffffffffc020474c <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc020474c:	7179                	addi	sp,sp,-48
ffffffffc020474e:	f022                	sd	s0,32(sp)
ffffffffc0204750:	f406                	sd	ra,40(sp)
ffffffffc0204752:	ec26                	sd	s1,24(sp)
ffffffffc0204754:	e84a                	sd	s2,16(sp)
ffffffffc0204756:	e44e                	sd	s3,8(sp)
ffffffffc0204758:	e052                	sd	s4,0(sp)
ffffffffc020475a:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc020475c:	c135                	beqz	a0,ffffffffc02047c0 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc020475e:	002007b7          	lui	a5,0x200
ffffffffc0204762:	04f5e663          	bltu	a1,a5,ffffffffc02047ae <user_mem_check+0x62>
ffffffffc0204766:	00c584b3          	add	s1,a1,a2
ffffffffc020476a:	0495f263          	bgeu	a1,s1,ffffffffc02047ae <user_mem_check+0x62>
ffffffffc020476e:	4785                	li	a5,1
ffffffffc0204770:	07fe                	slli	a5,a5,0x1f
ffffffffc0204772:	0297ee63          	bltu	a5,s1,ffffffffc02047ae <user_mem_check+0x62>
ffffffffc0204776:	892a                	mv	s2,a0
ffffffffc0204778:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020477a:	6a05                	lui	s4,0x1
ffffffffc020477c:	a821                	j	ffffffffc0204794 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020477e:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204782:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204784:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204786:	c685                	beqz	a3,ffffffffc02047ae <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204788:	c399                	beqz	a5,ffffffffc020478e <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020478a:	02e46263          	bltu	s0,a4,ffffffffc02047ae <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc020478e:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204790:	04947663          	bgeu	s0,s1,ffffffffc02047dc <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204794:	85a2                	mv	a1,s0
ffffffffc0204796:	854a                	mv	a0,s2
ffffffffc0204798:	f30ff0ef          	jal	ra,ffffffffc0203ec8 <find_vma>
ffffffffc020479c:	c909                	beqz	a0,ffffffffc02047ae <user_mem_check+0x62>
ffffffffc020479e:	6518                	ld	a4,8(a0)
ffffffffc02047a0:	00e46763          	bltu	s0,a4,ffffffffc02047ae <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02047a4:	4d1c                	lw	a5,24(a0)
ffffffffc02047a6:	fc099ce3          	bnez	s3,ffffffffc020477e <user_mem_check+0x32>
ffffffffc02047aa:	8b85                	andi	a5,a5,1
ffffffffc02047ac:	f3ed                	bnez	a5,ffffffffc020478e <user_mem_check+0x42>
            return 0;
ffffffffc02047ae:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02047b0:	70a2                	ld	ra,40(sp)
ffffffffc02047b2:	7402                	ld	s0,32(sp)
ffffffffc02047b4:	64e2                	ld	s1,24(sp)
ffffffffc02047b6:	6942                	ld	s2,16(sp)
ffffffffc02047b8:	69a2                	ld	s3,8(sp)
ffffffffc02047ba:	6a02                	ld	s4,0(sp)
ffffffffc02047bc:	6145                	addi	sp,sp,48
ffffffffc02047be:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02047c0:	c02007b7          	lui	a5,0xc0200
ffffffffc02047c4:	4501                	li	a0,0
ffffffffc02047c6:	fef5e5e3          	bltu	a1,a5,ffffffffc02047b0 <user_mem_check+0x64>
ffffffffc02047ca:	962e                	add	a2,a2,a1
ffffffffc02047cc:	fec5f2e3          	bgeu	a1,a2,ffffffffc02047b0 <user_mem_check+0x64>
ffffffffc02047d0:	c8000537          	lui	a0,0xc8000
ffffffffc02047d4:	0505                	addi	a0,a0,1
ffffffffc02047d6:	00a63533          	sltu	a0,a2,a0
ffffffffc02047da:	bfd9                	j	ffffffffc02047b0 <user_mem_check+0x64>
        return 1;
ffffffffc02047dc:	4505                	li	a0,1
ffffffffc02047de:	bfc9                	j	ffffffffc02047b0 <user_mem_check+0x64>

ffffffffc02047e0 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02047e0:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02047e2:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02047e4:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02047e6:	e07fb0ef          	jal	ra,ffffffffc02005ec <ide_device_valid>
ffffffffc02047ea:	cd01                	beqz	a0,ffffffffc0204802 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02047ec:	4505                	li	a0,1
ffffffffc02047ee:	e05fb0ef          	jal	ra,ffffffffc02005f2 <ide_device_size>
}
ffffffffc02047f2:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02047f4:	810d                	srli	a0,a0,0x3
ffffffffc02047f6:	000ae797          	auipc	a5,0xae
ffffffffc02047fa:	02a7b123          	sd	a0,34(a5) # ffffffffc02b2818 <max_swap_offset>
}
ffffffffc02047fe:	0141                	addi	sp,sp,16
ffffffffc0204800:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204802:	00003617          	auipc	a2,0x3
ffffffffc0204806:	0e660613          	addi	a2,a2,230 # ffffffffc02078e8 <default_pmm_manager+0xf70>
ffffffffc020480a:	45b5                	li	a1,13
ffffffffc020480c:	00003517          	auipc	a0,0x3
ffffffffc0204810:	0fc50513          	addi	a0,a0,252 # ffffffffc0207908 <default_pmm_manager+0xf90>
ffffffffc0204814:	c67fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204818 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204818:	1141                	addi	sp,sp,-16
ffffffffc020481a:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020481c:	00855793          	srli	a5,a0,0x8
ffffffffc0204820:	cbb1                	beqz	a5,ffffffffc0204874 <swapfs_write+0x5c>
ffffffffc0204822:	000ae717          	auipc	a4,0xae
ffffffffc0204826:	ff673703          	ld	a4,-10(a4) # ffffffffc02b2818 <max_swap_offset>
ffffffffc020482a:	04e7f563          	bgeu	a5,a4,ffffffffc0204874 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc020482e:	000ae617          	auipc	a2,0xae
ffffffffc0204832:	fd263603          	ld	a2,-46(a2) # ffffffffc02b2800 <pages>
ffffffffc0204836:	8d91                	sub	a1,a1,a2
ffffffffc0204838:	4065d613          	srai	a2,a1,0x6
ffffffffc020483c:	00004717          	auipc	a4,0x4
ffffffffc0204840:	9d473703          	ld	a4,-1580(a4) # ffffffffc0208210 <nbase>
ffffffffc0204844:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204846:	00c61713          	slli	a4,a2,0xc
ffffffffc020484a:	8331                	srli	a4,a4,0xc
ffffffffc020484c:	000ae697          	auipc	a3,0xae
ffffffffc0204850:	fac6b683          	ld	a3,-84(a3) # ffffffffc02b27f8 <npage>
ffffffffc0204854:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204858:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020485a:	02d77963          	bgeu	a4,a3,ffffffffc020488c <swapfs_write+0x74>
}
ffffffffc020485e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204860:	000ae797          	auipc	a5,0xae
ffffffffc0204864:	fb07b783          	ld	a5,-80(a5) # ffffffffc02b2810 <va_pa_offset>
ffffffffc0204868:	46a1                	li	a3,8
ffffffffc020486a:	963e                	add	a2,a2,a5
ffffffffc020486c:	4505                	li	a0,1
}
ffffffffc020486e:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204870:	d89fb06f          	j	ffffffffc02005f8 <ide_write_secs>
ffffffffc0204874:	86aa                	mv	a3,a0
ffffffffc0204876:	00003617          	auipc	a2,0x3
ffffffffc020487a:	0aa60613          	addi	a2,a2,170 # ffffffffc0207920 <default_pmm_manager+0xfa8>
ffffffffc020487e:	45e5                	li	a1,25
ffffffffc0204880:	00003517          	auipc	a0,0x3
ffffffffc0204884:	08850513          	addi	a0,a0,136 # ffffffffc0207908 <default_pmm_manager+0xf90>
ffffffffc0204888:	bf3fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc020488c:	86b2                	mv	a3,a2
ffffffffc020488e:	06900593          	li	a1,105
ffffffffc0204892:	00002617          	auipc	a2,0x2
ffffffffc0204896:	11e60613          	addi	a2,a2,286 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc020489a:	00002517          	auipc	a0,0x2
ffffffffc020489e:	13e50513          	addi	a0,a0,318 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc02048a2:	bd9fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02048a6 <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc02048a6:	000ae797          	auipc	a5,0xae
ffffffffc02048aa:	f9a7b783          	ld	a5,-102(a5) # ffffffffc02b2840 <current>
ffffffffc02048ae:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc02048b0:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc02048b2:	00003617          	auipc	a2,0x3
ffffffffc02048b6:	08e60613          	addi	a2,a2,142 # ffffffffc0207940 <default_pmm_manager+0xfc8>
ffffffffc02048ba:	00003517          	auipc	a0,0x3
ffffffffc02048be:	08e50513          	addi	a0,a0,142 # ffffffffc0207948 <default_pmm_manager+0xfd0>
user_main(void *arg) {
ffffffffc02048c2:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc02048c4:	8bdfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02048c8:	3fe07797          	auipc	a5,0x3fe07
ffffffffc02048cc:	86078793          	addi	a5,a5,-1952 # b128 <_binary_obj___user_exit_out_size>
ffffffffc02048d0:	e43e                	sd	a5,8(sp)
ffffffffc02048d2:	00003517          	auipc	a0,0x3
ffffffffc02048d6:	06e50513          	addi	a0,a0,110 # ffffffffc0207940 <default_pmm_manager+0xfc8>
ffffffffc02048da:	00027797          	auipc	a5,0x27
ffffffffc02048de:	c3e78793          	addi	a5,a5,-962 # ffffffffc022b518 <_binary_obj___user_exit_out_start>
ffffffffc02048e2:	f03e                	sd	a5,32(sp)
ffffffffc02048e4:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc02048e6:	e802                	sd	zero,16(sp)
ffffffffc02048e8:	294010ef          	jal	ra,ffffffffc0205b7c <strlen>
ffffffffc02048ec:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc02048ee:	4511                	li	a0,4
ffffffffc02048f0:	55a2                	lw	a1,40(sp)
ffffffffc02048f2:	4662                	lw	a2,24(sp)
ffffffffc02048f4:	5682                	lw	a3,32(sp)
ffffffffc02048f6:	4722                	lw	a4,8(sp)
ffffffffc02048f8:	48a9                	li	a7,10
ffffffffc02048fa:	9002                	ebreak
ffffffffc02048fc:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc02048fe:	65c2                	ld	a1,16(sp)
ffffffffc0204900:	00003517          	auipc	a0,0x3
ffffffffc0204904:	07050513          	addi	a0,a0,112 # ffffffffc0207970 <default_pmm_manager+0xff8>
ffffffffc0204908:	879fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc020490c:	00003617          	auipc	a2,0x3
ffffffffc0204910:	07460613          	addi	a2,a2,116 # ffffffffc0207980 <default_pmm_manager+0x1008>
ffffffffc0204914:	31b00593          	li	a1,795
ffffffffc0204918:	00003517          	auipc	a0,0x3
ffffffffc020491c:	08850513          	addi	a0,a0,136 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204920:	b5bfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204924 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204924:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204926:	1141                	addi	sp,sp,-16
ffffffffc0204928:	e406                	sd	ra,8(sp)
ffffffffc020492a:	c02007b7          	lui	a5,0xc0200
ffffffffc020492e:	02f6ee63          	bltu	a3,a5,ffffffffc020496a <put_pgdir+0x46>
ffffffffc0204932:	000ae517          	auipc	a0,0xae
ffffffffc0204936:	ede53503          	ld	a0,-290(a0) # ffffffffc02b2810 <va_pa_offset>
ffffffffc020493a:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc020493c:	82b1                	srli	a3,a3,0xc
ffffffffc020493e:	000ae797          	auipc	a5,0xae
ffffffffc0204942:	eba7b783          	ld	a5,-326(a5) # ffffffffc02b27f8 <npage>
ffffffffc0204946:	02f6fe63          	bgeu	a3,a5,ffffffffc0204982 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020494a:	00004517          	auipc	a0,0x4
ffffffffc020494e:	8c653503          	ld	a0,-1850(a0) # ffffffffc0208210 <nbase>
}
ffffffffc0204952:	60a2                	ld	ra,8(sp)
ffffffffc0204954:	8e89                	sub	a3,a3,a0
ffffffffc0204956:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204958:	000ae517          	auipc	a0,0xae
ffffffffc020495c:	ea853503          	ld	a0,-344(a0) # ffffffffc02b2800 <pages>
ffffffffc0204960:	4585                	li	a1,1
ffffffffc0204962:	9536                	add	a0,a0,a3
}
ffffffffc0204964:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204966:	be8fd06f          	j	ffffffffc0201d4e <free_pages>
    return pa2page(PADDR(kva));
ffffffffc020496a:	00002617          	auipc	a2,0x2
ffffffffc020496e:	0ee60613          	addi	a2,a2,238 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0204972:	06e00593          	li	a1,110
ffffffffc0204976:	00002517          	auipc	a0,0x2
ffffffffc020497a:	06250513          	addi	a0,a0,98 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc020497e:	afdfb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204982:	00002617          	auipc	a2,0x2
ffffffffc0204986:	0fe60613          	addi	a2,a2,254 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc020498a:	06200593          	li	a1,98
ffffffffc020498e:	00002517          	auipc	a0,0x2
ffffffffc0204992:	04a50513          	addi	a0,a0,74 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204996:	ae5fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020499a <proc_run>:
}
ffffffffc020499a:	8082                	ret

ffffffffc020499c <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020499c:	7169                	addi	sp,sp,-304
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020499e:	12000613          	li	a2,288
ffffffffc02049a2:	4581                	li	a1,0
ffffffffc02049a4:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02049a6:	f606                	sd	ra,296(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02049a8:	250010ef          	jal	ra,ffffffffc0205bf8 <memset>
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02049ac:	100027f3          	csrr	a5,sstatus
}
ffffffffc02049b0:	70b2                	ld	ra,296(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02049b2:	000ae517          	auipc	a0,0xae
ffffffffc02049b6:	ea652503          	lw	a0,-346(a0) # ffffffffc02b2858 <nr_process>
ffffffffc02049ba:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc02049bc:	00f52533          	slt	a0,a0,a5
}
ffffffffc02049c0:	156d                	addi	a0,a0,-5
ffffffffc02049c2:	6155                	addi	sp,sp,304
ffffffffc02049c4:	8082                	ret

ffffffffc02049c6 <do_fork>:
    if (nr_process >= MAX_PROCESS) {
ffffffffc02049c6:	000ae517          	auipc	a0,0xae
ffffffffc02049ca:	e9252503          	lw	a0,-366(a0) # ffffffffc02b2858 <nr_process>
ffffffffc02049ce:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc02049d0:	00f52533          	slt	a0,a0,a5
}
ffffffffc02049d4:	156d                	addi	a0,a0,-5
ffffffffc02049d6:	8082                	ret

ffffffffc02049d8 <do_exit>:
do_exit(int error_code) {
ffffffffc02049d8:	7179                	addi	sp,sp,-48
ffffffffc02049da:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc02049dc:	000ae417          	auipc	s0,0xae
ffffffffc02049e0:	e6440413          	addi	s0,s0,-412 # ffffffffc02b2840 <current>
ffffffffc02049e4:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc02049e6:	f406                	sd	ra,40(sp)
ffffffffc02049e8:	ec26                	sd	s1,24(sp)
ffffffffc02049ea:	e84a                	sd	s2,16(sp)
ffffffffc02049ec:	e44e                	sd	s3,8(sp)
ffffffffc02049ee:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02049f0:	000ae717          	auipc	a4,0xae
ffffffffc02049f4:	e5873703          	ld	a4,-424(a4) # ffffffffc02b2848 <idleproc>
ffffffffc02049f8:	0ce78c63          	beq	a5,a4,ffffffffc0204ad0 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc02049fc:	000ae497          	auipc	s1,0xae
ffffffffc0204a00:	e5448493          	addi	s1,s1,-428 # ffffffffc02b2850 <initproc>
ffffffffc0204a04:	6098                	ld	a4,0(s1)
ffffffffc0204a06:	0ee78b63          	beq	a5,a4,ffffffffc0204afc <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0204a0a:	0287b983          	ld	s3,40(a5) # 1028 <_binary_obj___user_faultread_out_size-0x8b88>
ffffffffc0204a0e:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc0204a10:	02098663          	beqz	s3,ffffffffc0204a3c <do_exit+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204a14:	000ae797          	auipc	a5,0xae
ffffffffc0204a18:	dd47b783          	ld	a5,-556(a5) # ffffffffc02b27e8 <boot_cr3>
ffffffffc0204a1c:	577d                	li	a4,-1
ffffffffc0204a1e:	177e                	slli	a4,a4,0x3f
ffffffffc0204a20:	83b1                	srli	a5,a5,0xc
ffffffffc0204a22:	8fd9                	or	a5,a5,a4
ffffffffc0204a24:	18079073          	csrw	satp,a5
    return mm->mm_count;
}

static inline int
mm_count_dec(struct mm_struct *mm) {
    mm->mm_count -= 1;
ffffffffc0204a28:	0309a783          	lw	a5,48(s3)
ffffffffc0204a2c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204a30:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0204a34:	cb55                	beqz	a4,ffffffffc0204ae8 <do_exit+0x110>
        current->mm = NULL;
ffffffffc0204a36:	601c                	ld	a5,0(s0)
ffffffffc0204a38:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204a3c:	601c                	ld	a5,0(s0)
ffffffffc0204a3e:	470d                	li	a4,3
ffffffffc0204a40:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204a42:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a46:	100027f3          	csrr	a5,sstatus
ffffffffc0204a4a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204a4c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a4e:	e3f9                	bnez	a5,ffffffffc0204b14 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0204a50:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0204a52:	800007b7          	lui	a5,0x80000
ffffffffc0204a56:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204a58:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0204a5a:	0ec52703          	lw	a4,236(a0)
ffffffffc0204a5e:	0af70f63          	beq	a4,a5,ffffffffc0204b1c <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc0204a62:	6018                	ld	a4,0(s0)
ffffffffc0204a64:	7b7c                	ld	a5,240(a4)
ffffffffc0204a66:	c3a1                	beqz	a5,ffffffffc0204aa6 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0204a68:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204a6c:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0204a6e:	0985                	addi	s3,s3,1
ffffffffc0204a70:	a021                	j	ffffffffc0204a78 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc0204a72:	6018                	ld	a4,0(s0)
ffffffffc0204a74:	7b7c                	ld	a5,240(a4)
ffffffffc0204a76:	cb85                	beqz	a5,ffffffffc0204aa6 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0204a78:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0204a7c:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204a7e:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0204a80:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204a82:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0204a86:	10e7b023          	sd	a4,256(a5)
ffffffffc0204a8a:	c311                	beqz	a4,ffffffffc0204a8e <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0204a8c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204a8e:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204a90:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204a92:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204a94:	fd271fe3          	bne	a4,s2,ffffffffc0204a72 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0204a98:	0ec52783          	lw	a5,236(a0)
ffffffffc0204a9c:	fd379be3          	bne	a5,s3,ffffffffc0204a72 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0204aa0:	2ed000ef          	jal	ra,ffffffffc020558c <wakeup_proc>
ffffffffc0204aa4:	b7f9                	j	ffffffffc0204a72 <do_exit+0x9a>
    if (flag) {
ffffffffc0204aa6:	020a1263          	bnez	s4,ffffffffc0204aca <do_exit+0xf2>
    schedule();
ffffffffc0204aaa:	363000ef          	jal	ra,ffffffffc020560c <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204aae:	601c                	ld	a5,0(s0)
ffffffffc0204ab0:	00003617          	auipc	a2,0x3
ffffffffc0204ab4:	f2860613          	addi	a2,a2,-216 # ffffffffc02079d8 <default_pmm_manager+0x1060>
ffffffffc0204ab8:	1d400593          	li	a1,468
ffffffffc0204abc:	43d4                	lw	a3,4(a5)
ffffffffc0204abe:	00003517          	auipc	a0,0x3
ffffffffc0204ac2:	ee250513          	addi	a0,a0,-286 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204ac6:	9b5fb0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_enable();
ffffffffc0204aca:	b53fb0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0204ace:	bff1                	j	ffffffffc0204aaa <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0204ad0:	00003617          	auipc	a2,0x3
ffffffffc0204ad4:	ee860613          	addi	a2,a2,-280 # ffffffffc02079b8 <default_pmm_manager+0x1040>
ffffffffc0204ad8:	1a800593          	li	a1,424
ffffffffc0204adc:	00003517          	auipc	a0,0x3
ffffffffc0204ae0:	ec450513          	addi	a0,a0,-316 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204ae4:	997fb0ef          	jal	ra,ffffffffc020047a <__panic>
            exit_mmap(mm);
ffffffffc0204ae8:	854e                	mv	a0,s3
ffffffffc0204aea:	df0ff0ef          	jal	ra,ffffffffc02040da <exit_mmap>
            put_pgdir(mm);
ffffffffc0204aee:	854e                	mv	a0,s3
ffffffffc0204af0:	e35ff0ef          	jal	ra,ffffffffc0204924 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204af4:	854e                	mv	a0,s3
ffffffffc0204af6:	ce2ff0ef          	jal	ra,ffffffffc0203fd8 <mm_destroy>
ffffffffc0204afa:	bf35                	j	ffffffffc0204a36 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0204afc:	00003617          	auipc	a2,0x3
ffffffffc0204b00:	ecc60613          	addi	a2,a2,-308 # ffffffffc02079c8 <default_pmm_manager+0x1050>
ffffffffc0204b04:	1ab00593          	li	a1,427
ffffffffc0204b08:	00003517          	auipc	a0,0x3
ffffffffc0204b0c:	e9850513          	addi	a0,a0,-360 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204b10:	96bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_disable();
ffffffffc0204b14:	b0ffb0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc0204b18:	4a05                	li	s4,1
ffffffffc0204b1a:	bf1d                	j	ffffffffc0204a50 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc0204b1c:	271000ef          	jal	ra,ffffffffc020558c <wakeup_proc>
ffffffffc0204b20:	b789                	j	ffffffffc0204a62 <do_exit+0x8a>

ffffffffc0204b22 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0204b22:	715d                	addi	sp,sp,-80
ffffffffc0204b24:	f84a                	sd	s2,48(sp)
ffffffffc0204b26:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc0204b28:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204b2c:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0204b2e:	fc26                	sd	s1,56(sp)
ffffffffc0204b30:	f052                	sd	s4,32(sp)
ffffffffc0204b32:	ec56                	sd	s5,24(sp)
ffffffffc0204b34:	e85a                	sd	s6,16(sp)
ffffffffc0204b36:	e45e                	sd	s7,8(sp)
ffffffffc0204b38:	e486                	sd	ra,72(sp)
ffffffffc0204b3a:	e0a2                	sd	s0,64(sp)
ffffffffc0204b3c:	84aa                	mv	s1,a0
ffffffffc0204b3e:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204b40:	000aeb97          	auipc	s7,0xae
ffffffffc0204b44:	d00b8b93          	addi	s7,s7,-768 # ffffffffc02b2840 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204b48:	00050b1b          	sext.w	s6,a0
ffffffffc0204b4c:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0204b50:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204b52:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0204b54:	ccbd                	beqz	s1,ffffffffc0204bd2 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204b56:	0359e863          	bltu	s3,s5,ffffffffc0204b86 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204b5a:	45a9                	li	a1,10
ffffffffc0204b5c:	855a                	mv	a0,s6
ffffffffc0204b5e:	41b000ef          	jal	ra,ffffffffc0205778 <hash32>
ffffffffc0204b62:	02051793          	slli	a5,a0,0x20
ffffffffc0204b66:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204b6a:	000aa797          	auipc	a5,0xaa
ffffffffc0204b6e:	c4e78793          	addi	a5,a5,-946 # ffffffffc02ae7b8 <hash_list>
ffffffffc0204b72:	953e                	add	a0,a0,a5
ffffffffc0204b74:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc0204b76:	a029                	j	ffffffffc0204b80 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc0204b78:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204b7c:	02978163          	beq	a5,s1,ffffffffc0204b9e <do_wait.part.0+0x7c>
ffffffffc0204b80:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0204b82:	fe851be3          	bne	a0,s0,ffffffffc0204b78 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0204b86:	5579                	li	a0,-2
}
ffffffffc0204b88:	60a6                	ld	ra,72(sp)
ffffffffc0204b8a:	6406                	ld	s0,64(sp)
ffffffffc0204b8c:	74e2                	ld	s1,56(sp)
ffffffffc0204b8e:	7942                	ld	s2,48(sp)
ffffffffc0204b90:	79a2                	ld	s3,40(sp)
ffffffffc0204b92:	7a02                	ld	s4,32(sp)
ffffffffc0204b94:	6ae2                	ld	s5,24(sp)
ffffffffc0204b96:	6b42                	ld	s6,16(sp)
ffffffffc0204b98:	6ba2                	ld	s7,8(sp)
ffffffffc0204b9a:	6161                	addi	sp,sp,80
ffffffffc0204b9c:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0204b9e:	000bb683          	ld	a3,0(s7)
ffffffffc0204ba2:	f4843783          	ld	a5,-184(s0)
ffffffffc0204ba6:	fed790e3          	bne	a5,a3,ffffffffc0204b86 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204baa:	f2842703          	lw	a4,-216(s0)
ffffffffc0204bae:	478d                	li	a5,3
ffffffffc0204bb0:	0ef70b63          	beq	a4,a5,ffffffffc0204ca6 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0204bb4:	4785                	li	a5,1
ffffffffc0204bb6:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0204bb8:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0204bbc:	251000ef          	jal	ra,ffffffffc020560c <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0204bc0:	000bb783          	ld	a5,0(s7)
ffffffffc0204bc4:	0b07a783          	lw	a5,176(a5)
ffffffffc0204bc8:	8b85                	andi	a5,a5,1
ffffffffc0204bca:	d7c9                	beqz	a5,ffffffffc0204b54 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0204bcc:	555d                	li	a0,-9
ffffffffc0204bce:	e0bff0ef          	jal	ra,ffffffffc02049d8 <do_exit>
        proc = current->cptr;
ffffffffc0204bd2:	000bb683          	ld	a3,0(s7)
ffffffffc0204bd6:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0204bd8:	d45d                	beqz	s0,ffffffffc0204b86 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204bda:	470d                	li	a4,3
ffffffffc0204bdc:	a021                	j	ffffffffc0204be4 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0204bde:	10043403          	ld	s0,256(s0)
ffffffffc0204be2:	d869                	beqz	s0,ffffffffc0204bb4 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204be4:	401c                	lw	a5,0(s0)
ffffffffc0204be6:	fee79ce3          	bne	a5,a4,ffffffffc0204bde <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0204bea:	000ae797          	auipc	a5,0xae
ffffffffc0204bee:	c5e7b783          	ld	a5,-930(a5) # ffffffffc02b2848 <idleproc>
ffffffffc0204bf2:	0c878963          	beq	a5,s0,ffffffffc0204cc4 <do_wait.part.0+0x1a2>
ffffffffc0204bf6:	000ae797          	auipc	a5,0xae
ffffffffc0204bfa:	c5a7b783          	ld	a5,-934(a5) # ffffffffc02b2850 <initproc>
ffffffffc0204bfe:	0cf40363          	beq	s0,a5,ffffffffc0204cc4 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0204c02:	000a0663          	beqz	s4,ffffffffc0204c0e <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0204c06:	0e842783          	lw	a5,232(s0)
ffffffffc0204c0a:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204c0e:	100027f3          	csrr	a5,sstatus
ffffffffc0204c12:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204c14:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204c16:	e7c1                	bnez	a5,ffffffffc0204c9e <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204c18:	6c70                	ld	a2,216(s0)
ffffffffc0204c1a:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0204c1c:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204c20:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204c22:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204c24:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204c26:	6470                	ld	a2,200(s0)
ffffffffc0204c28:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204c2a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204c2c:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0204c2e:	c319                	beqz	a4,ffffffffc0204c34 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204c30:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0204c32:	7c7c                	ld	a5,248(s0)
ffffffffc0204c34:	c3b5                	beqz	a5,ffffffffc0204c98 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0204c36:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0204c3a:	000ae717          	auipc	a4,0xae
ffffffffc0204c3e:	c1e70713          	addi	a4,a4,-994 # ffffffffc02b2858 <nr_process>
ffffffffc0204c42:	431c                	lw	a5,0(a4)
ffffffffc0204c44:	37fd                	addiw	a5,a5,-1
ffffffffc0204c46:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc0204c48:	e5a9                	bnez	a1,ffffffffc0204c92 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204c4a:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204c4c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c50:	04f6ee63          	bltu	a3,a5,ffffffffc0204cac <do_wait.part.0+0x18a>
ffffffffc0204c54:	000ae797          	auipc	a5,0xae
ffffffffc0204c58:	bbc7b783          	ld	a5,-1092(a5) # ffffffffc02b2810 <va_pa_offset>
ffffffffc0204c5c:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0204c5e:	82b1                	srli	a3,a3,0xc
ffffffffc0204c60:	000ae797          	auipc	a5,0xae
ffffffffc0204c64:	b987b783          	ld	a5,-1128(a5) # ffffffffc02b27f8 <npage>
ffffffffc0204c68:	06f6fa63          	bgeu	a3,a5,ffffffffc0204cdc <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204c6c:	00003517          	auipc	a0,0x3
ffffffffc0204c70:	5a453503          	ld	a0,1444(a0) # ffffffffc0208210 <nbase>
ffffffffc0204c74:	8e89                	sub	a3,a3,a0
ffffffffc0204c76:	069a                	slli	a3,a3,0x6
ffffffffc0204c78:	000ae517          	auipc	a0,0xae
ffffffffc0204c7c:	b8853503          	ld	a0,-1144(a0) # ffffffffc02b2800 <pages>
ffffffffc0204c80:	9536                	add	a0,a0,a3
ffffffffc0204c82:	4589                	li	a1,2
ffffffffc0204c84:	8cafd0ef          	jal	ra,ffffffffc0201d4e <free_pages>
    kfree(proc);
ffffffffc0204c88:	8522                	mv	a0,s0
ffffffffc0204c8a:	f05fc0ef          	jal	ra,ffffffffc0201b8e <kfree>
    return 0;
ffffffffc0204c8e:	4501                	li	a0,0
ffffffffc0204c90:	bde5                	j	ffffffffc0204b88 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204c92:	98bfb0ef          	jal	ra,ffffffffc020061c <intr_enable>
ffffffffc0204c96:	bf55                	j	ffffffffc0204c4a <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc0204c98:	701c                	ld	a5,32(s0)
ffffffffc0204c9a:	fbf8                	sd	a4,240(a5)
ffffffffc0204c9c:	bf79                	j	ffffffffc0204c3a <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204c9e:	985fb0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc0204ca2:	4585                	li	a1,1
ffffffffc0204ca4:	bf95                	j	ffffffffc0204c18 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204ca6:	f2840413          	addi	s0,s0,-216
ffffffffc0204caa:	b781                	j	ffffffffc0204bea <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0204cac:	00002617          	auipc	a2,0x2
ffffffffc0204cb0:	dac60613          	addi	a2,a2,-596 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc0204cb4:	06e00593          	li	a1,110
ffffffffc0204cb8:	00002517          	auipc	a0,0x2
ffffffffc0204cbc:	d2050513          	addi	a0,a0,-736 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204cc0:	fbafb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0204cc4:	00003617          	auipc	a2,0x3
ffffffffc0204cc8:	d3460613          	addi	a2,a2,-716 # ffffffffc02079f8 <default_pmm_manager+0x1080>
ffffffffc0204ccc:	2c900593          	li	a1,713
ffffffffc0204cd0:	00003517          	auipc	a0,0x3
ffffffffc0204cd4:	cd050513          	addi	a0,a0,-816 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204cd8:	fa2fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204cdc:	00002617          	auipc	a2,0x2
ffffffffc0204ce0:	da460613          	addi	a2,a2,-604 # ffffffffc0206a80 <default_pmm_manager+0x108>
ffffffffc0204ce4:	06200593          	li	a1,98
ffffffffc0204ce8:	00002517          	auipc	a0,0x2
ffffffffc0204cec:	cf050513          	addi	a0,a0,-784 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0204cf0:	f8afb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204cf4 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0204cf4:	1141                	addi	sp,sp,-16
ffffffffc0204cf6:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204cf8:	896fd0ef          	jal	ra,ffffffffc0201d8e <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204cfc:	ddffc0ef          	jal	ra,ffffffffc0201ada <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204d00:	4601                	li	a2,0
ffffffffc0204d02:	4581                	li	a1,0
ffffffffc0204d04:	00000517          	auipc	a0,0x0
ffffffffc0204d08:	ba250513          	addi	a0,a0,-1118 # ffffffffc02048a6 <user_main>
ffffffffc0204d0c:	c91ff0ef          	jal	ra,ffffffffc020499c <kernel_thread>
    if (pid <= 0) {
ffffffffc0204d10:	00a04563          	bgtz	a0,ffffffffc0204d1a <init_main+0x26>
ffffffffc0204d14:	a071                	j	ffffffffc0204da0 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0204d16:	0f7000ef          	jal	ra,ffffffffc020560c <schedule>
    if (code_store != NULL) {
ffffffffc0204d1a:	4581                	li	a1,0
ffffffffc0204d1c:	4501                	li	a0,0
ffffffffc0204d1e:	e05ff0ef          	jal	ra,ffffffffc0204b22 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc0204d22:	d975                	beqz	a0,ffffffffc0204d16 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204d24:	00003517          	auipc	a0,0x3
ffffffffc0204d28:	d1450513          	addi	a0,a0,-748 # ffffffffc0207a38 <default_pmm_manager+0x10c0>
ffffffffc0204d2c:	c54fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204d30:	000ae797          	auipc	a5,0xae
ffffffffc0204d34:	b207b783          	ld	a5,-1248(a5) # ffffffffc02b2850 <initproc>
ffffffffc0204d38:	7bf8                	ld	a4,240(a5)
ffffffffc0204d3a:	e339                	bnez	a4,ffffffffc0204d80 <init_main+0x8c>
ffffffffc0204d3c:	7ff8                	ld	a4,248(a5)
ffffffffc0204d3e:	e329                	bnez	a4,ffffffffc0204d80 <init_main+0x8c>
ffffffffc0204d40:	1007b703          	ld	a4,256(a5)
ffffffffc0204d44:	ef15                	bnez	a4,ffffffffc0204d80 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204d46:	000ae697          	auipc	a3,0xae
ffffffffc0204d4a:	b126a683          	lw	a3,-1262(a3) # ffffffffc02b2858 <nr_process>
ffffffffc0204d4e:	4709                	li	a4,2
ffffffffc0204d50:	0ae69463          	bne	a3,a4,ffffffffc0204df8 <init_main+0x104>
    return listelm->next;
ffffffffc0204d54:	000ae697          	auipc	a3,0xae
ffffffffc0204d58:	a6468693          	addi	a3,a3,-1436 # ffffffffc02b27b8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204d5c:	6698                	ld	a4,8(a3)
ffffffffc0204d5e:	0c878793          	addi	a5,a5,200
ffffffffc0204d62:	06f71b63          	bne	a4,a5,ffffffffc0204dd8 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204d66:	629c                	ld	a5,0(a3)
ffffffffc0204d68:	04f71863          	bne	a4,a5,ffffffffc0204db8 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204d6c:	00003517          	auipc	a0,0x3
ffffffffc0204d70:	db450513          	addi	a0,a0,-588 # ffffffffc0207b20 <default_pmm_manager+0x11a8>
ffffffffc0204d74:	c0cfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0204d78:	60a2                	ld	ra,8(sp)
ffffffffc0204d7a:	4501                	li	a0,0
ffffffffc0204d7c:	0141                	addi	sp,sp,16
ffffffffc0204d7e:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204d80:	00003697          	auipc	a3,0x3
ffffffffc0204d84:	ce068693          	addi	a3,a3,-800 # ffffffffc0207a60 <default_pmm_manager+0x10e8>
ffffffffc0204d88:	00001617          	auipc	a2,0x1
ffffffffc0204d8c:	55860613          	addi	a2,a2,1368 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204d90:	32e00593          	li	a1,814
ffffffffc0204d94:	00003517          	auipc	a0,0x3
ffffffffc0204d98:	c0c50513          	addi	a0,a0,-1012 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204d9c:	edefb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("create user_main failed.\n");
ffffffffc0204da0:	00003617          	auipc	a2,0x3
ffffffffc0204da4:	c7860613          	addi	a2,a2,-904 # ffffffffc0207a18 <default_pmm_manager+0x10a0>
ffffffffc0204da8:	32600593          	li	a1,806
ffffffffc0204dac:	00003517          	auipc	a0,0x3
ffffffffc0204db0:	bf450513          	addi	a0,a0,-1036 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204db4:	ec6fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204db8:	00003697          	auipc	a3,0x3
ffffffffc0204dbc:	d3868693          	addi	a3,a3,-712 # ffffffffc0207af0 <default_pmm_manager+0x1178>
ffffffffc0204dc0:	00001617          	auipc	a2,0x1
ffffffffc0204dc4:	52060613          	addi	a2,a2,1312 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204dc8:	33100593          	li	a1,817
ffffffffc0204dcc:	00003517          	auipc	a0,0x3
ffffffffc0204dd0:	bd450513          	addi	a0,a0,-1068 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204dd4:	ea6fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204dd8:	00003697          	auipc	a3,0x3
ffffffffc0204ddc:	ce868693          	addi	a3,a3,-792 # ffffffffc0207ac0 <default_pmm_manager+0x1148>
ffffffffc0204de0:	00001617          	auipc	a2,0x1
ffffffffc0204de4:	50060613          	addi	a2,a2,1280 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204de8:	33000593          	li	a1,816
ffffffffc0204dec:	00003517          	auipc	a0,0x3
ffffffffc0204df0:	bb450513          	addi	a0,a0,-1100 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204df4:	e86fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_process == 2);
ffffffffc0204df8:	00003697          	auipc	a3,0x3
ffffffffc0204dfc:	cb868693          	addi	a3,a3,-840 # ffffffffc0207ab0 <default_pmm_manager+0x1138>
ffffffffc0204e00:	00001617          	auipc	a2,0x1
ffffffffc0204e04:	4e060613          	addi	a2,a2,1248 # ffffffffc02062e0 <commands+0x450>
ffffffffc0204e08:	32f00593          	li	a1,815
ffffffffc0204e0c:	00003517          	auipc	a0,0x3
ffffffffc0204e10:	b9450513          	addi	a0,a0,-1132 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0204e14:	e66fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204e18 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204e18:	7171                	addi	sp,sp,-176
ffffffffc0204e1a:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204e1c:	000aed97          	auipc	s11,0xae
ffffffffc0204e20:	a24d8d93          	addi	s11,s11,-1500 # ffffffffc02b2840 <current>
ffffffffc0204e24:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204e28:	e54e                	sd	s3,136(sp)
ffffffffc0204e2a:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204e2c:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204e30:	e94a                	sd	s2,144(sp)
ffffffffc0204e32:	87b2                	mv	a5,a2
ffffffffc0204e34:	892a                	mv	s2,a0
ffffffffc0204e36:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0204e38:	862e                	mv	a2,a1
ffffffffc0204e3a:	4681                	li	a3,0
ffffffffc0204e3c:	85aa                	mv	a1,a0
ffffffffc0204e3e:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204e40:	f506                	sd	ra,168(sp)
ffffffffc0204e42:	f122                	sd	s0,160(sp)
ffffffffc0204e44:	e152                	sd	s4,128(sp)
ffffffffc0204e46:	fcd6                	sd	s5,120(sp)
ffffffffc0204e48:	f8da                	sd	s6,112(sp)
ffffffffc0204e4a:	f4de                	sd	s7,104(sp)
ffffffffc0204e4c:	f0e2                	sd	s8,96(sp)
ffffffffc0204e4e:	ece6                	sd	s9,88(sp)
ffffffffc0204e50:	e8ea                	sd	s10,80(sp)
ffffffffc0204e52:	f03e                	sd	a5,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0204e54:	8f9ff0ef          	jal	ra,ffffffffc020474c <user_mem_check>
ffffffffc0204e58:	3e050a63          	beqz	a0,ffffffffc020524c <do_execve+0x434>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204e5c:	4641                	li	a2,16
ffffffffc0204e5e:	4581                	li	a1,0
ffffffffc0204e60:	1808                	addi	a0,sp,48
ffffffffc0204e62:	597000ef          	jal	ra,ffffffffc0205bf8 <memset>
    memcpy(local_name, name, len);
ffffffffc0204e66:	47bd                	li	a5,15
ffffffffc0204e68:	8626                	mv	a2,s1
ffffffffc0204e6a:	1c97e263          	bltu	a5,s1,ffffffffc020502e <do_execve+0x216>
ffffffffc0204e6e:	85ca                	mv	a1,s2
ffffffffc0204e70:	1808                	addi	a0,sp,48
ffffffffc0204e72:	599000ef          	jal	ra,ffffffffc0205c0a <memcpy>
    if (mm != NULL) {
ffffffffc0204e76:	1c098363          	beqz	s3,ffffffffc020503c <do_execve+0x224>
        cputs("mm != NULL");
ffffffffc0204e7a:	00002517          	auipc	a0,0x2
ffffffffc0204e7e:	25650513          	addi	a0,a0,598 # ffffffffc02070d0 <default_pmm_manager+0x758>
ffffffffc0204e82:	b36fb0ef          	jal	ra,ffffffffc02001b8 <cputs>
ffffffffc0204e86:	000ae797          	auipc	a5,0xae
ffffffffc0204e8a:	9627b783          	ld	a5,-1694(a5) # ffffffffc02b27e8 <boot_cr3>
ffffffffc0204e8e:	577d                	li	a4,-1
ffffffffc0204e90:	177e                	slli	a4,a4,0x3f
ffffffffc0204e92:	83b1                	srli	a5,a5,0xc
ffffffffc0204e94:	8fd9                	or	a5,a5,a4
ffffffffc0204e96:	18079073          	csrw	satp,a5
ffffffffc0204e9a:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b80>
ffffffffc0204e9e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204ea2:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0204ea6:	2a070463          	beqz	a4,ffffffffc020514e <do_execve+0x336>
        current->mm = NULL;
ffffffffc0204eaa:	000db783          	ld	a5,0(s11)
ffffffffc0204eae:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0204eb2:	fa1fe0ef          	jal	ra,ffffffffc0203e52 <mm_create>
ffffffffc0204eb6:	84aa                	mv	s1,a0
ffffffffc0204eb8:	1a050d63          	beqz	a0,ffffffffc0205072 <do_execve+0x25a>
    if ((page = alloc_page()) == NULL) {
ffffffffc0204ebc:	4505                	li	a0,1
ffffffffc0204ebe:	dfffc0ef          	jal	ra,ffffffffc0201cbc <alloc_pages>
ffffffffc0204ec2:	38050963          	beqz	a0,ffffffffc0205254 <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0204ec6:	000aec17          	auipc	s8,0xae
ffffffffc0204eca:	93ac0c13          	addi	s8,s8,-1734 # ffffffffc02b2800 <pages>
ffffffffc0204ece:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204ed2:	000aec97          	auipc	s9,0xae
ffffffffc0204ed6:	926c8c93          	addi	s9,s9,-1754 # ffffffffc02b27f8 <npage>
    return page - pages + nbase;
ffffffffc0204eda:	00003717          	auipc	a4,0x3
ffffffffc0204ede:	33673703          	ld	a4,822(a4) # ffffffffc0208210 <nbase>
ffffffffc0204ee2:	40d506b3          	sub	a3,a0,a3
ffffffffc0204ee6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204ee8:	5afd                	li	s5,-1
ffffffffc0204eea:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0204eee:	96ba                	add	a3,a3,a4
ffffffffc0204ef0:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204ef2:	00cad713          	srli	a4,s5,0xc
ffffffffc0204ef6:	ec3a                	sd	a4,24(sp)
ffffffffc0204ef8:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204efa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204efc:	36f77063          	bgeu	a4,a5,ffffffffc020525c <do_execve+0x444>
ffffffffc0204f00:	000aeb17          	auipc	s6,0xae
ffffffffc0204f04:	910b0b13          	addi	s6,s6,-1776 # ffffffffc02b2810 <va_pa_offset>
ffffffffc0204f08:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204f0c:	6605                	lui	a2,0x1
ffffffffc0204f0e:	000ae597          	auipc	a1,0xae
ffffffffc0204f12:	8e25b583          	ld	a1,-1822(a1) # ffffffffc02b27f0 <boot_pgdir>
ffffffffc0204f16:	9936                	add	s2,s2,a3
ffffffffc0204f18:	854a                	mv	a0,s2
ffffffffc0204f1a:	4f1000ef          	jal	ra,ffffffffc0205c0a <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0204f1e:	7782                	ld	a5,32(sp)
ffffffffc0204f20:	4398                	lw	a4,0(a5)
ffffffffc0204f22:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204f26:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0204f2a:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9457>
ffffffffc0204f2e:	12f71863          	bne	a4,a5,ffffffffc020505e <do_execve+0x246>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204f32:	7682                	ld	a3,32(sp)
ffffffffc0204f34:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204f38:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204f3c:	00371793          	slli	a5,a4,0x3
ffffffffc0204f40:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204f42:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204f44:	078e                	slli	a5,a5,0x3
ffffffffc0204f46:	97ce                	add	a5,a5,s3
ffffffffc0204f48:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0204f4a:	00f9fc63          	bgeu	s3,a5,ffffffffc0204f62 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0204f4e:	0009a783          	lw	a5,0(s3)
ffffffffc0204f52:	4705                	li	a4,1
ffffffffc0204f54:	12e78163          	beq	a5,a4,ffffffffc0205076 <do_execve+0x25e>
    for (; ph < ph_end; ph ++) {
ffffffffc0204f58:	77a2                	ld	a5,40(sp)
ffffffffc0204f5a:	03898993          	addi	s3,s3,56
ffffffffc0204f5e:	fef9e8e3          	bltu	s3,a5,ffffffffc0204f4e <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0204f62:	4701                	li	a4,0
ffffffffc0204f64:	46ad                	li	a3,11
ffffffffc0204f66:	00100637          	lui	a2,0x100
ffffffffc0204f6a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204f6e:	8526                	mv	a0,s1
ffffffffc0204f70:	8baff0ef          	jal	ra,ffffffffc020402a <mm_map>
ffffffffc0204f74:	892a                	mv	s2,a0
ffffffffc0204f76:	1c051263          	bnez	a0,ffffffffc020513a <do_execve+0x322>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0204f7a:	6c88                	ld	a0,24(s1)
ffffffffc0204f7c:	467d                	li	a2,31
ffffffffc0204f7e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204f82:	976fe0ef          	jal	ra,ffffffffc02030f8 <pgdir_alloc_page>
ffffffffc0204f86:	36050363          	beqz	a0,ffffffffc02052ec <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0204f8a:	6c88                	ld	a0,24(s1)
ffffffffc0204f8c:	467d                	li	a2,31
ffffffffc0204f8e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204f92:	966fe0ef          	jal	ra,ffffffffc02030f8 <pgdir_alloc_page>
ffffffffc0204f96:	32050b63          	beqz	a0,ffffffffc02052cc <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0204f9a:	6c88                	ld	a0,24(s1)
ffffffffc0204f9c:	467d                	li	a2,31
ffffffffc0204f9e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204fa2:	956fe0ef          	jal	ra,ffffffffc02030f8 <pgdir_alloc_page>
ffffffffc0204fa6:	30050363          	beqz	a0,ffffffffc02052ac <do_execve+0x494>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0204faa:	6c88                	ld	a0,24(s1)
ffffffffc0204fac:	467d                	li	a2,31
ffffffffc0204fae:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204fb2:	946fe0ef          	jal	ra,ffffffffc02030f8 <pgdir_alloc_page>
ffffffffc0204fb6:	2c050b63          	beqz	a0,ffffffffc020528c <do_execve+0x474>
    mm->mm_count += 1;
ffffffffc0204fba:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204fbc:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0204fc0:	6c94                	ld	a3,24(s1)
ffffffffc0204fc2:	2785                	addiw	a5,a5,1
ffffffffc0204fc4:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204fc6:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0204fc8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204fcc:	2af6e463          	bltu	a3,a5,ffffffffc0205274 <do_execve+0x45c>
ffffffffc0204fd0:	000b3783          	ld	a5,0(s6)
ffffffffc0204fd4:	577d                	li	a4,-1
ffffffffc0204fd6:	177e                	slli	a4,a4,0x3f
ffffffffc0204fd8:	8e9d                	sub	a3,a3,a5
ffffffffc0204fda:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204fde:	f654                	sd	a3,168(a2)
ffffffffc0204fe0:	8fd9                	or	a5,a5,a4
ffffffffc0204fe2:	18079073          	csrw	satp,a5
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204fe6:	7248                	ld	a0,160(a2)
ffffffffc0204fe8:	4581                	li	a1,0
ffffffffc0204fea:	12000613          	li	a2,288
ffffffffc0204fee:	40b000ef          	jal	ra,ffffffffc0205bf8 <memset>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ff2:	000db403          	ld	s0,0(s11)
ffffffffc0204ff6:	4641                	li	a2,16
ffffffffc0204ff8:	4581                	li	a1,0
ffffffffc0204ffa:	0b440413          	addi	s0,s0,180
ffffffffc0204ffe:	8522                	mv	a0,s0
ffffffffc0205000:	3f9000ef          	jal	ra,ffffffffc0205bf8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205004:	463d                	li	a2,15
ffffffffc0205006:	180c                	addi	a1,sp,48
ffffffffc0205008:	8522                	mv	a0,s0
ffffffffc020500a:	401000ef          	jal	ra,ffffffffc0205c0a <memcpy>
}
ffffffffc020500e:	70aa                	ld	ra,168(sp)
ffffffffc0205010:	740a                	ld	s0,160(sp)
ffffffffc0205012:	64ea                	ld	s1,152(sp)
ffffffffc0205014:	69aa                	ld	s3,136(sp)
ffffffffc0205016:	6a0a                	ld	s4,128(sp)
ffffffffc0205018:	7ae6                	ld	s5,120(sp)
ffffffffc020501a:	7b46                	ld	s6,112(sp)
ffffffffc020501c:	7ba6                	ld	s7,104(sp)
ffffffffc020501e:	7c06                	ld	s8,96(sp)
ffffffffc0205020:	6ce6                	ld	s9,88(sp)
ffffffffc0205022:	6d46                	ld	s10,80(sp)
ffffffffc0205024:	6da6                	ld	s11,72(sp)
ffffffffc0205026:	854a                	mv	a0,s2
ffffffffc0205028:	694a                	ld	s2,144(sp)
ffffffffc020502a:	614d                	addi	sp,sp,176
ffffffffc020502c:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc020502e:	463d                	li	a2,15
ffffffffc0205030:	85ca                	mv	a1,s2
ffffffffc0205032:	1808                	addi	a0,sp,48
ffffffffc0205034:	3d7000ef          	jal	ra,ffffffffc0205c0a <memcpy>
    if (mm != NULL) {
ffffffffc0205038:	e40991e3          	bnez	s3,ffffffffc0204e7a <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc020503c:	000db783          	ld	a5,0(s11)
ffffffffc0205040:	779c                	ld	a5,40(a5)
ffffffffc0205042:	e60788e3          	beqz	a5,ffffffffc0204eb2 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205046:	00003617          	auipc	a2,0x3
ffffffffc020504a:	afa60613          	addi	a2,a2,-1286 # ffffffffc0207b40 <default_pmm_manager+0x11c8>
ffffffffc020504e:	1de00593          	li	a1,478
ffffffffc0205052:	00003517          	auipc	a0,0x3
ffffffffc0205056:	94e50513          	addi	a0,a0,-1714 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc020505a:	c20fb0ef          	jal	ra,ffffffffc020047a <__panic>
    put_pgdir(mm);
ffffffffc020505e:	8526                	mv	a0,s1
ffffffffc0205060:	8c5ff0ef          	jal	ra,ffffffffc0204924 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205064:	8526                	mv	a0,s1
ffffffffc0205066:	f73fe0ef          	jal	ra,ffffffffc0203fd8 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc020506a:	5961                	li	s2,-8
    do_exit(ret);
ffffffffc020506c:	854a                	mv	a0,s2
ffffffffc020506e:	96bff0ef          	jal	ra,ffffffffc02049d8 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205072:	5971                	li	s2,-4
ffffffffc0205074:	bfe5                	j	ffffffffc020506c <do_execve+0x254>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205076:	0289b603          	ld	a2,40(s3)
ffffffffc020507a:	0209b783          	ld	a5,32(s3)
ffffffffc020507e:	1cf66d63          	bltu	a2,a5,ffffffffc0205258 <do_execve+0x440>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205082:	0049a783          	lw	a5,4(s3)
ffffffffc0205086:	0017f693          	andi	a3,a5,1
ffffffffc020508a:	c291                	beqz	a3,ffffffffc020508e <do_execve+0x276>
ffffffffc020508c:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020508e:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205092:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205094:	e779                	bnez	a4,ffffffffc0205162 <do_execve+0x34a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205096:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205098:	c781                	beqz	a5,ffffffffc02050a0 <do_execve+0x288>
ffffffffc020509a:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc020509e:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02050a0:	0026f793          	andi	a5,a3,2
ffffffffc02050a4:	e3f1                	bnez	a5,ffffffffc0205168 <do_execve+0x350>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc02050a6:	0046f793          	andi	a5,a3,4
ffffffffc02050aa:	c399                	beqz	a5,ffffffffc02050b0 <do_execve+0x298>
ffffffffc02050ac:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc02050b0:	0109b583          	ld	a1,16(s3)
ffffffffc02050b4:	4701                	li	a4,0
ffffffffc02050b6:	8526                	mv	a0,s1
ffffffffc02050b8:	f73fe0ef          	jal	ra,ffffffffc020402a <mm_map>
ffffffffc02050bc:	892a                	mv	s2,a0
ffffffffc02050be:	ed35                	bnez	a0,ffffffffc020513a <do_execve+0x322>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02050c0:	0109ba83          	ld	s5,16(s3)
ffffffffc02050c4:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc02050c6:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02050ca:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02050ce:	00fafbb3          	and	s7,s5,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc02050d2:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc02050d4:	9a56                	add	s4,s4,s5
        unsigned char *from = binary + ph->p_offset;
ffffffffc02050d6:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc02050d8:	054ae963          	bltu	s5,s4,ffffffffc020512a <do_execve+0x312>
ffffffffc02050dc:	aa95                	j	ffffffffc0205250 <do_execve+0x438>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02050de:	6785                	lui	a5,0x1
ffffffffc02050e0:	417a8533          	sub	a0,s5,s7
ffffffffc02050e4:	9bbe                	add	s7,s7,a5
ffffffffc02050e6:	415b8633          	sub	a2,s7,s5
            if (end < la) {
ffffffffc02050ea:	017a7463          	bgeu	s4,s7,ffffffffc02050f2 <do_execve+0x2da>
                size -= la - end;
ffffffffc02050ee:	415a0633          	sub	a2,s4,s5
    return page - pages + nbase;
ffffffffc02050f2:	000c3683          	ld	a3,0(s8)
ffffffffc02050f6:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc02050f8:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc02050fc:	40d406b3          	sub	a3,s0,a3
ffffffffc0205100:	8699                	srai	a3,a3,0x6
ffffffffc0205102:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205104:	67e2                	ld	a5,24(sp)
ffffffffc0205106:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020510a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020510c:	14b87863          	bgeu	a6,a1,ffffffffc020525c <do_execve+0x444>
ffffffffc0205110:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205114:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205116:	9ab2                	add	s5,s5,a2
ffffffffc0205118:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc020511a:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc020511c:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc020511e:	2ed000ef          	jal	ra,ffffffffc0205c0a <memcpy>
            start += size, from += size;
ffffffffc0205122:	6622                	ld	a2,8(sp)
ffffffffc0205124:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205126:	054af363          	bgeu	s5,s4,ffffffffc020516c <do_execve+0x354>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc020512a:	6c88                	ld	a0,24(s1)
ffffffffc020512c:	866a                	mv	a2,s10
ffffffffc020512e:	85de                	mv	a1,s7
ffffffffc0205130:	fc9fd0ef          	jal	ra,ffffffffc02030f8 <pgdir_alloc_page>
ffffffffc0205134:	842a                	mv	s0,a0
ffffffffc0205136:	f545                	bnez	a0,ffffffffc02050de <do_execve+0x2c6>
        ret = -E_NO_MEM;
ffffffffc0205138:	5971                	li	s2,-4
    exit_mmap(mm);
ffffffffc020513a:	8526                	mv	a0,s1
ffffffffc020513c:	f9ffe0ef          	jal	ra,ffffffffc02040da <exit_mmap>
    put_pgdir(mm);
ffffffffc0205140:	8526                	mv	a0,s1
ffffffffc0205142:	fe2ff0ef          	jal	ra,ffffffffc0204924 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205146:	8526                	mv	a0,s1
ffffffffc0205148:	e91fe0ef          	jal	ra,ffffffffc0203fd8 <mm_destroy>
    return ret;
ffffffffc020514c:	b705                	j	ffffffffc020506c <do_execve+0x254>
            exit_mmap(mm);
ffffffffc020514e:	854e                	mv	a0,s3
ffffffffc0205150:	f8bfe0ef          	jal	ra,ffffffffc02040da <exit_mmap>
            put_pgdir(mm);
ffffffffc0205154:	854e                	mv	a0,s3
ffffffffc0205156:	fceff0ef          	jal	ra,ffffffffc0204924 <put_pgdir>
            mm_destroy(mm);
ffffffffc020515a:	854e                	mv	a0,s3
ffffffffc020515c:	e7dfe0ef          	jal	ra,ffffffffc0203fd8 <mm_destroy>
ffffffffc0205160:	b3a9                	j	ffffffffc0204eaa <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205162:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205166:	fb95                	bnez	a5,ffffffffc020509a <do_execve+0x282>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205168:	4d5d                	li	s10,23
ffffffffc020516a:	bf35                	j	ffffffffc02050a6 <do_execve+0x28e>
        end = ph->p_va + ph->p_memsz;
ffffffffc020516c:	0109b903          	ld	s2,16(s3)
ffffffffc0205170:	0289b683          	ld	a3,40(s3)
ffffffffc0205174:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205176:	077afd63          	bgeu	s5,s7,ffffffffc02051f0 <do_execve+0x3d8>
            if (start == end) {
ffffffffc020517a:	dd590fe3          	beq	s2,s5,ffffffffc0204f58 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc020517e:	6785                	lui	a5,0x1
ffffffffc0205180:	00fa8533          	add	a0,s5,a5
ffffffffc0205184:	41750533          	sub	a0,a0,s7
                size -= la - end;
ffffffffc0205188:	41590a33          	sub	s4,s2,s5
            if (end < la) {
ffffffffc020518c:	0b797d63          	bgeu	s2,s7,ffffffffc0205246 <do_execve+0x42e>
    return page - pages + nbase;
ffffffffc0205190:	000c3683          	ld	a3,0(s8)
ffffffffc0205194:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205196:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc020519a:	40d406b3          	sub	a3,s0,a3
ffffffffc020519e:	8699                	srai	a3,a3,0x6
ffffffffc02051a0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02051a2:	67e2                	ld	a5,24(sp)
ffffffffc02051a4:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02051a8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02051aa:	0ac5f963          	bgeu	a1,a2,ffffffffc020525c <do_execve+0x444>
ffffffffc02051ae:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc02051b2:	8652                	mv	a2,s4
ffffffffc02051b4:	4581                	li	a1,0
ffffffffc02051b6:	96c2                	add	a3,a3,a6
ffffffffc02051b8:	9536                	add	a0,a0,a3
ffffffffc02051ba:	23f000ef          	jal	ra,ffffffffc0205bf8 <memset>
            start += size;
ffffffffc02051be:	015a0733          	add	a4,s4,s5
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc02051c2:	03797463          	bgeu	s2,s7,ffffffffc02051ea <do_execve+0x3d2>
ffffffffc02051c6:	d8e909e3          	beq	s2,a4,ffffffffc0204f58 <do_execve+0x140>
ffffffffc02051ca:	00003697          	auipc	a3,0x3
ffffffffc02051ce:	99e68693          	addi	a3,a3,-1634 # ffffffffc0207b68 <default_pmm_manager+0x11f0>
ffffffffc02051d2:	00001617          	auipc	a2,0x1
ffffffffc02051d6:	10e60613          	addi	a2,a2,270 # ffffffffc02062e0 <commands+0x450>
ffffffffc02051da:	23300593          	li	a1,563
ffffffffc02051de:	00002517          	auipc	a0,0x2
ffffffffc02051e2:	7c250513          	addi	a0,a0,1986 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc02051e6:	a94fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02051ea:	ff7710e3          	bne	a4,s7,ffffffffc02051ca <do_execve+0x3b2>
ffffffffc02051ee:	8ade                	mv	s5,s7
        while (start < end) {
ffffffffc02051f0:	d72af4e3          	bgeu	s5,s2,ffffffffc0204f58 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02051f4:	6c88                	ld	a0,24(s1)
ffffffffc02051f6:	866a                	mv	a2,s10
ffffffffc02051f8:	85de                	mv	a1,s7
ffffffffc02051fa:	efffd0ef          	jal	ra,ffffffffc02030f8 <pgdir_alloc_page>
ffffffffc02051fe:	842a                	mv	s0,a0
ffffffffc0205200:	dd05                	beqz	a0,ffffffffc0205138 <do_execve+0x320>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205202:	6785                	lui	a5,0x1
ffffffffc0205204:	417a8533          	sub	a0,s5,s7
ffffffffc0205208:	9bbe                	add	s7,s7,a5
ffffffffc020520a:	415b8633          	sub	a2,s7,s5
            if (end < la) {
ffffffffc020520e:	01797463          	bgeu	s2,s7,ffffffffc0205216 <do_execve+0x3fe>
                size -= la - end;
ffffffffc0205212:	41590633          	sub	a2,s2,s5
    return page - pages + nbase;
ffffffffc0205216:	000c3683          	ld	a3,0(s8)
ffffffffc020521a:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc020521c:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205220:	40d406b3          	sub	a3,s0,a3
ffffffffc0205224:	8699                	srai	a3,a3,0x6
ffffffffc0205226:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205228:	67e2                	ld	a5,24(sp)
ffffffffc020522a:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020522e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205230:	02b87663          	bgeu	a6,a1,ffffffffc020525c <do_execve+0x444>
ffffffffc0205234:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205238:	4581                	li	a1,0
            start += size;
ffffffffc020523a:	9ab2                	add	s5,s5,a2
ffffffffc020523c:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc020523e:	9536                	add	a0,a0,a3
ffffffffc0205240:	1b9000ef          	jal	ra,ffffffffc0205bf8 <memset>
ffffffffc0205244:	b775                	j	ffffffffc02051f0 <do_execve+0x3d8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205246:	415b8a33          	sub	s4,s7,s5
ffffffffc020524a:	b799                	j	ffffffffc0205190 <do_execve+0x378>
        return -E_INVAL;
ffffffffc020524c:	5975                	li	s2,-3
ffffffffc020524e:	b3c1                	j	ffffffffc020500e <do_execve+0x1f6>
        while (start < end) {
ffffffffc0205250:	8956                	mv	s2,s5
ffffffffc0205252:	bf39                	j	ffffffffc0205170 <do_execve+0x358>
    int ret = -E_NO_MEM;
ffffffffc0205254:	5971                	li	s2,-4
ffffffffc0205256:	bdc5                	j	ffffffffc0205146 <do_execve+0x32e>
            ret = -E_INVAL_ELF;
ffffffffc0205258:	5961                	li	s2,-8
ffffffffc020525a:	b5c5                	j	ffffffffc020513a <do_execve+0x322>
ffffffffc020525c:	00001617          	auipc	a2,0x1
ffffffffc0205260:	75460613          	addi	a2,a2,1876 # ffffffffc02069b0 <default_pmm_manager+0x38>
ffffffffc0205264:	06900593          	li	a1,105
ffffffffc0205268:	00001517          	auipc	a0,0x1
ffffffffc020526c:	77050513          	addi	a0,a0,1904 # ffffffffc02069d8 <default_pmm_manager+0x60>
ffffffffc0205270:	a0afb0ef          	jal	ra,ffffffffc020047a <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205274:	00001617          	auipc	a2,0x1
ffffffffc0205278:	7e460613          	addi	a2,a2,2020 # ffffffffc0206a58 <default_pmm_manager+0xe0>
ffffffffc020527c:	24e00593          	li	a1,590
ffffffffc0205280:	00002517          	auipc	a0,0x2
ffffffffc0205284:	72050513          	addi	a0,a0,1824 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0205288:	9f2fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020528c:	00003697          	auipc	a3,0x3
ffffffffc0205290:	9f468693          	addi	a3,a3,-1548 # ffffffffc0207c80 <default_pmm_manager+0x1308>
ffffffffc0205294:	00001617          	auipc	a2,0x1
ffffffffc0205298:	04c60613          	addi	a2,a2,76 # ffffffffc02062e0 <commands+0x450>
ffffffffc020529c:	24900593          	li	a1,585
ffffffffc02052a0:	00002517          	auipc	a0,0x2
ffffffffc02052a4:	70050513          	addi	a0,a0,1792 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc02052a8:	9d2fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02052ac:	00003697          	auipc	a3,0x3
ffffffffc02052b0:	98c68693          	addi	a3,a3,-1652 # ffffffffc0207c38 <default_pmm_manager+0x12c0>
ffffffffc02052b4:	00001617          	auipc	a2,0x1
ffffffffc02052b8:	02c60613          	addi	a2,a2,44 # ffffffffc02062e0 <commands+0x450>
ffffffffc02052bc:	24800593          	li	a1,584
ffffffffc02052c0:	00002517          	auipc	a0,0x2
ffffffffc02052c4:	6e050513          	addi	a0,a0,1760 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc02052c8:	9b2fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02052cc:	00003697          	auipc	a3,0x3
ffffffffc02052d0:	92468693          	addi	a3,a3,-1756 # ffffffffc0207bf0 <default_pmm_manager+0x1278>
ffffffffc02052d4:	00001617          	auipc	a2,0x1
ffffffffc02052d8:	00c60613          	addi	a2,a2,12 # ffffffffc02062e0 <commands+0x450>
ffffffffc02052dc:	24700593          	li	a1,583
ffffffffc02052e0:	00002517          	auipc	a0,0x2
ffffffffc02052e4:	6c050513          	addi	a0,a0,1728 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc02052e8:	992fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02052ec:	00003697          	auipc	a3,0x3
ffffffffc02052f0:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0207ba8 <default_pmm_manager+0x1230>
ffffffffc02052f4:	00001617          	auipc	a2,0x1
ffffffffc02052f8:	fec60613          	addi	a2,a2,-20 # ffffffffc02062e0 <commands+0x450>
ffffffffc02052fc:	24600593          	li	a1,582
ffffffffc0205300:	00002517          	auipc	a0,0x2
ffffffffc0205304:	6a050513          	addi	a0,a0,1696 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0205308:	972fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020530c <do_yield>:
    current->need_resched = 1;
ffffffffc020530c:	000ad797          	auipc	a5,0xad
ffffffffc0205310:	5347b783          	ld	a5,1332(a5) # ffffffffc02b2840 <current>
ffffffffc0205314:	4705                	li	a4,1
ffffffffc0205316:	ef98                	sd	a4,24(a5)
}
ffffffffc0205318:	4501                	li	a0,0
ffffffffc020531a:	8082                	ret

ffffffffc020531c <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc020531c:	1101                	addi	sp,sp,-32
ffffffffc020531e:	e822                	sd	s0,16(sp)
ffffffffc0205320:	e426                	sd	s1,8(sp)
ffffffffc0205322:	ec06                	sd	ra,24(sp)
ffffffffc0205324:	842e                	mv	s0,a1
ffffffffc0205326:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205328:	c999                	beqz	a1,ffffffffc020533e <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc020532a:	000ad797          	auipc	a5,0xad
ffffffffc020532e:	5167b783          	ld	a5,1302(a5) # ffffffffc02b2840 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205332:	7788                	ld	a0,40(a5)
ffffffffc0205334:	4685                	li	a3,1
ffffffffc0205336:	4611                	li	a2,4
ffffffffc0205338:	c14ff0ef          	jal	ra,ffffffffc020474c <user_mem_check>
ffffffffc020533c:	c909                	beqz	a0,ffffffffc020534e <do_wait+0x32>
ffffffffc020533e:	85a2                	mv	a1,s0
}
ffffffffc0205340:	6442                	ld	s0,16(sp)
ffffffffc0205342:	60e2                	ld	ra,24(sp)
ffffffffc0205344:	8526                	mv	a0,s1
ffffffffc0205346:	64a2                	ld	s1,8(sp)
ffffffffc0205348:	6105                	addi	sp,sp,32
ffffffffc020534a:	fd8ff06f          	j	ffffffffc0204b22 <do_wait.part.0>
ffffffffc020534e:	60e2                	ld	ra,24(sp)
ffffffffc0205350:	6442                	ld	s0,16(sp)
ffffffffc0205352:	64a2                	ld	s1,8(sp)
ffffffffc0205354:	5575                	li	a0,-3
ffffffffc0205356:	6105                	addi	sp,sp,32
ffffffffc0205358:	8082                	ret

ffffffffc020535a <do_kill>:
do_kill(int pid) {
ffffffffc020535a:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc020535c:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc020535e:	e406                	sd	ra,8(sp)
ffffffffc0205360:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205362:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205366:	17f9                	addi	a5,a5,-2
ffffffffc0205368:	02e7e963          	bltu	a5,a4,ffffffffc020539a <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020536c:	842a                	mv	s0,a0
ffffffffc020536e:	45a9                	li	a1,10
ffffffffc0205370:	2501                	sext.w	a0,a0
ffffffffc0205372:	406000ef          	jal	ra,ffffffffc0205778 <hash32>
ffffffffc0205376:	02051793          	slli	a5,a0,0x20
ffffffffc020537a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020537e:	000a9797          	auipc	a5,0xa9
ffffffffc0205382:	43a78793          	addi	a5,a5,1082 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205386:	953e                	add	a0,a0,a5
ffffffffc0205388:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc020538a:	a029                	j	ffffffffc0205394 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc020538c:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205390:	00870b63          	beq	a4,s0,ffffffffc02053a6 <do_kill+0x4c>
ffffffffc0205394:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205396:	fef51be3          	bne	a0,a5,ffffffffc020538c <do_kill+0x32>
    return -E_INVAL;
ffffffffc020539a:	5475                	li	s0,-3
}
ffffffffc020539c:	60a2                	ld	ra,8(sp)
ffffffffc020539e:	8522                	mv	a0,s0
ffffffffc02053a0:	6402                	ld	s0,0(sp)
ffffffffc02053a2:	0141                	addi	sp,sp,16
ffffffffc02053a4:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc02053a6:	fd87a703          	lw	a4,-40(a5)
ffffffffc02053aa:	00177693          	andi	a3,a4,1
ffffffffc02053ae:	e295                	bnez	a3,ffffffffc02053d2 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc02053b0:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc02053b2:	00176713          	ori	a4,a4,1
ffffffffc02053b6:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc02053ba:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc02053bc:	fe06d0e3          	bgez	a3,ffffffffc020539c <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc02053c0:	f2878513          	addi	a0,a5,-216
ffffffffc02053c4:	1c8000ef          	jal	ra,ffffffffc020558c <wakeup_proc>
}
ffffffffc02053c8:	60a2                	ld	ra,8(sp)
ffffffffc02053ca:	8522                	mv	a0,s0
ffffffffc02053cc:	6402                	ld	s0,0(sp)
ffffffffc02053ce:	0141                	addi	sp,sp,16
ffffffffc02053d0:	8082                	ret
        return -E_KILLED;
ffffffffc02053d2:	545d                	li	s0,-9
ffffffffc02053d4:	b7e1                	j	ffffffffc020539c <do_kill+0x42>

ffffffffc02053d6 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc02053d6:	1101                	addi	sp,sp,-32
ffffffffc02053d8:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02053da:	000ad797          	auipc	a5,0xad
ffffffffc02053de:	3de78793          	addi	a5,a5,990 # ffffffffc02b27b8 <proc_list>
ffffffffc02053e2:	ec06                	sd	ra,24(sp)
ffffffffc02053e4:	e822                	sd	s0,16(sp)
ffffffffc02053e6:	e04a                	sd	s2,0(sp)
ffffffffc02053e8:	000a9497          	auipc	s1,0xa9
ffffffffc02053ec:	3d048493          	addi	s1,s1,976 # ffffffffc02ae7b8 <hash_list>
ffffffffc02053f0:	e79c                	sd	a5,8(a5)
ffffffffc02053f2:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02053f4:	000ad717          	auipc	a4,0xad
ffffffffc02053f8:	3c470713          	addi	a4,a4,964 # ffffffffc02b27b8 <proc_list>
ffffffffc02053fc:	87a6                	mv	a5,s1
ffffffffc02053fe:	e79c                	sd	a5,8(a5)
ffffffffc0205400:	e39c                	sd	a5,0(a5)
ffffffffc0205402:	07c1                	addi	a5,a5,16
ffffffffc0205404:	fef71de3          	bne	a4,a5,ffffffffc02053fe <proc_init+0x28>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0205408:	10800513          	li	a0,264
ffffffffc020540c:	ed2fc0ef          	jal	ra,ffffffffc0201ade <kmalloc>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205410:	000ad917          	auipc	s2,0xad
ffffffffc0205414:	43890913          	addi	s2,s2,1080 # ffffffffc02b2848 <idleproc>
ffffffffc0205418:	00a93023          	sd	a0,0(s2)
ffffffffc020541c:	0e050f63          	beqz	a0,ffffffffc020551a <proc_init+0x144>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205420:	4789                	li	a5,2
ffffffffc0205422:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205424:	00004797          	auipc	a5,0x4
ffffffffc0205428:	bdc78793          	addi	a5,a5,-1060 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020542c:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205430:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205432:	4785                	li	a5,1
ffffffffc0205434:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205436:	4641                	li	a2,16
ffffffffc0205438:	4581                	li	a1,0
ffffffffc020543a:	8522                	mv	a0,s0
ffffffffc020543c:	7bc000ef          	jal	ra,ffffffffc0205bf8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205440:	463d                	li	a2,15
ffffffffc0205442:	00003597          	auipc	a1,0x3
ffffffffc0205446:	89e58593          	addi	a1,a1,-1890 # ffffffffc0207ce0 <default_pmm_manager+0x1368>
ffffffffc020544a:	8522                	mv	a0,s0
ffffffffc020544c:	7be000ef          	jal	ra,ffffffffc0205c0a <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205450:	000ad717          	auipc	a4,0xad
ffffffffc0205454:	40870713          	addi	a4,a4,1032 # ffffffffc02b2858 <nr_process>
ffffffffc0205458:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020545a:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020545e:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205460:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205462:	4581                	li	a1,0
ffffffffc0205464:	00000517          	auipc	a0,0x0
ffffffffc0205468:	89050513          	addi	a0,a0,-1904 # ffffffffc0204cf4 <init_main>
    nr_process ++;
ffffffffc020546c:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc020546e:	000ad797          	auipc	a5,0xad
ffffffffc0205472:	3cd7b923          	sd	a3,978(a5) # ffffffffc02b2840 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205476:	d26ff0ef          	jal	ra,ffffffffc020499c <kernel_thread>
ffffffffc020547a:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc020547c:	08a05363          	blez	a0,ffffffffc0205502 <proc_init+0x12c>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205480:	6789                	lui	a5,0x2
ffffffffc0205482:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205486:	17f9                	addi	a5,a5,-2
ffffffffc0205488:	2501                	sext.w	a0,a0
ffffffffc020548a:	02e7e363          	bltu	a5,a4,ffffffffc02054b0 <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020548e:	45a9                	li	a1,10
ffffffffc0205490:	2e8000ef          	jal	ra,ffffffffc0205778 <hash32>
ffffffffc0205494:	02051793          	slli	a5,a0,0x20
ffffffffc0205498:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020549c:	96a6                	add	a3,a3,s1
ffffffffc020549e:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02054a0:	a029                	j	ffffffffc02054aa <proc_init+0xd4>
            if (proc->pid == pid) {
ffffffffc02054a2:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc02054a6:	04870b63          	beq	a4,s0,ffffffffc02054fc <proc_init+0x126>
    return listelm->next;
ffffffffc02054aa:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02054ac:	fef69be3          	bne	a3,a5,ffffffffc02054a2 <proc_init+0xcc>
    return NULL;
ffffffffc02054b0:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02054b2:	0b478493          	addi	s1,a5,180
ffffffffc02054b6:	4641                	li	a2,16
ffffffffc02054b8:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02054ba:	000ad417          	auipc	s0,0xad
ffffffffc02054be:	39640413          	addi	s0,s0,918 # ffffffffc02b2850 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02054c2:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02054c4:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02054c6:	732000ef          	jal	ra,ffffffffc0205bf8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02054ca:	463d                	li	a2,15
ffffffffc02054cc:	00003597          	auipc	a1,0x3
ffffffffc02054d0:	83c58593          	addi	a1,a1,-1988 # ffffffffc0207d08 <default_pmm_manager+0x1390>
ffffffffc02054d4:	8526                	mv	a0,s1
ffffffffc02054d6:	734000ef          	jal	ra,ffffffffc0205c0a <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02054da:	00093783          	ld	a5,0(s2)
ffffffffc02054de:	cbb5                	beqz	a5,ffffffffc0205552 <proc_init+0x17c>
ffffffffc02054e0:	43dc                	lw	a5,4(a5)
ffffffffc02054e2:	eba5                	bnez	a5,ffffffffc0205552 <proc_init+0x17c>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02054e4:	601c                	ld	a5,0(s0)
ffffffffc02054e6:	c7b1                	beqz	a5,ffffffffc0205532 <proc_init+0x15c>
ffffffffc02054e8:	43d8                	lw	a4,4(a5)
ffffffffc02054ea:	4785                	li	a5,1
ffffffffc02054ec:	04f71363          	bne	a4,a5,ffffffffc0205532 <proc_init+0x15c>
}
ffffffffc02054f0:	60e2                	ld	ra,24(sp)
ffffffffc02054f2:	6442                	ld	s0,16(sp)
ffffffffc02054f4:	64a2                	ld	s1,8(sp)
ffffffffc02054f6:	6902                	ld	s2,0(sp)
ffffffffc02054f8:	6105                	addi	sp,sp,32
ffffffffc02054fa:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02054fc:	f2878793          	addi	a5,a5,-216
ffffffffc0205500:	bf4d                	j	ffffffffc02054b2 <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc0205502:	00002617          	auipc	a2,0x2
ffffffffc0205506:	7e660613          	addi	a2,a2,2022 # ffffffffc0207ce8 <default_pmm_manager+0x1370>
ffffffffc020550a:	35100593          	li	a1,849
ffffffffc020550e:	00002517          	auipc	a0,0x2
ffffffffc0205512:	49250513          	addi	a0,a0,1170 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc0205516:	f65fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc020551a:	00002617          	auipc	a2,0x2
ffffffffc020551e:	7ae60613          	addi	a2,a2,1966 # ffffffffc0207cc8 <default_pmm_manager+0x1350>
ffffffffc0205522:	34300593          	li	a1,835
ffffffffc0205526:	00002517          	auipc	a0,0x2
ffffffffc020552a:	47a50513          	addi	a0,a0,1146 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc020552e:	f4dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205532:	00003697          	auipc	a3,0x3
ffffffffc0205536:	80668693          	addi	a3,a3,-2042 # ffffffffc0207d38 <default_pmm_manager+0x13c0>
ffffffffc020553a:	00001617          	auipc	a2,0x1
ffffffffc020553e:	da660613          	addi	a2,a2,-602 # ffffffffc02062e0 <commands+0x450>
ffffffffc0205542:	35800593          	li	a1,856
ffffffffc0205546:	00002517          	auipc	a0,0x2
ffffffffc020554a:	45a50513          	addi	a0,a0,1114 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc020554e:	f2dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205552:	00002697          	auipc	a3,0x2
ffffffffc0205556:	7be68693          	addi	a3,a3,1982 # ffffffffc0207d10 <default_pmm_manager+0x1398>
ffffffffc020555a:	00001617          	auipc	a2,0x1
ffffffffc020555e:	d8660613          	addi	a2,a2,-634 # ffffffffc02062e0 <commands+0x450>
ffffffffc0205562:	35700593          	li	a1,855
ffffffffc0205566:	00002517          	auipc	a0,0x2
ffffffffc020556a:	43a50513          	addi	a0,a0,1082 # ffffffffc02079a0 <default_pmm_manager+0x1028>
ffffffffc020556e:	f0dfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205572 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205572:	1141                	addi	sp,sp,-16
ffffffffc0205574:	e022                	sd	s0,0(sp)
ffffffffc0205576:	e406                	sd	ra,8(sp)
ffffffffc0205578:	000ad417          	auipc	s0,0xad
ffffffffc020557c:	2c840413          	addi	s0,s0,712 # ffffffffc02b2840 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205580:	6018                	ld	a4,0(s0)
ffffffffc0205582:	6f1c                	ld	a5,24(a4)
ffffffffc0205584:	dffd                	beqz	a5,ffffffffc0205582 <cpu_idle+0x10>
            schedule();
ffffffffc0205586:	086000ef          	jal	ra,ffffffffc020560c <schedule>
ffffffffc020558a:	bfdd                	j	ffffffffc0205580 <cpu_idle+0xe>

ffffffffc020558c <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020558c:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc020558e:	1101                	addi	sp,sp,-32
ffffffffc0205590:	ec06                	sd	ra,24(sp)
ffffffffc0205592:	e822                	sd	s0,16(sp)
ffffffffc0205594:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205596:	478d                	li	a5,3
ffffffffc0205598:	04f70b63          	beq	a4,a5,ffffffffc02055ee <wakeup_proc+0x62>
ffffffffc020559c:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020559e:	100027f3          	csrr	a5,sstatus
ffffffffc02055a2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055a4:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055a6:	ef9d                	bnez	a5,ffffffffc02055e4 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02055a8:	4789                	li	a5,2
ffffffffc02055aa:	02f70163          	beq	a4,a5,ffffffffc02055cc <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc02055ae:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc02055b0:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc02055b4:	e491                	bnez	s1,ffffffffc02055c0 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02055b6:	60e2                	ld	ra,24(sp)
ffffffffc02055b8:	6442                	ld	s0,16(sp)
ffffffffc02055ba:	64a2                	ld	s1,8(sp)
ffffffffc02055bc:	6105                	addi	sp,sp,32
ffffffffc02055be:	8082                	ret
ffffffffc02055c0:	6442                	ld	s0,16(sp)
ffffffffc02055c2:	60e2                	ld	ra,24(sp)
ffffffffc02055c4:	64a2                	ld	s1,8(sp)
ffffffffc02055c6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02055c8:	854fb06f          	j	ffffffffc020061c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc02055cc:	00002617          	auipc	a2,0x2
ffffffffc02055d0:	7cc60613          	addi	a2,a2,1996 # ffffffffc0207d98 <default_pmm_manager+0x1420>
ffffffffc02055d4:	45c9                	li	a1,18
ffffffffc02055d6:	00002517          	auipc	a0,0x2
ffffffffc02055da:	7aa50513          	addi	a0,a0,1962 # ffffffffc0207d80 <default_pmm_manager+0x1408>
ffffffffc02055de:	f05fa0ef          	jal	ra,ffffffffc02004e2 <__warn>
ffffffffc02055e2:	bfc9                	j	ffffffffc02055b4 <wakeup_proc+0x28>
        intr_disable();
ffffffffc02055e4:	83efb0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02055e8:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02055ea:	4485                	li	s1,1
ffffffffc02055ec:	bf75                	j	ffffffffc02055a8 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02055ee:	00002697          	auipc	a3,0x2
ffffffffc02055f2:	77268693          	addi	a3,a3,1906 # ffffffffc0207d60 <default_pmm_manager+0x13e8>
ffffffffc02055f6:	00001617          	auipc	a2,0x1
ffffffffc02055fa:	cea60613          	addi	a2,a2,-790 # ffffffffc02062e0 <commands+0x450>
ffffffffc02055fe:	45a5                	li	a1,9
ffffffffc0205600:	00002517          	auipc	a0,0x2
ffffffffc0205604:	78050513          	addi	a0,a0,1920 # ffffffffc0207d80 <default_pmm_manager+0x1408>
ffffffffc0205608:	e73fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020560c <schedule>:

void
schedule(void) {
ffffffffc020560c:	1141                	addi	sp,sp,-16
ffffffffc020560e:	e406                	sd	ra,8(sp)
ffffffffc0205610:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205612:	100027f3          	csrr	a5,sstatus
ffffffffc0205616:	8b89                	andi	a5,a5,2
ffffffffc0205618:	4401                	li	s0,0
ffffffffc020561a:	efbd                	bnez	a5,ffffffffc0205698 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020561c:	000ad897          	auipc	a7,0xad
ffffffffc0205620:	2248b883          	ld	a7,548(a7) # ffffffffc02b2840 <current>
ffffffffc0205624:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205628:	000ad517          	auipc	a0,0xad
ffffffffc020562c:	22053503          	ld	a0,544(a0) # ffffffffc02b2848 <idleproc>
ffffffffc0205630:	04a88e63          	beq	a7,a0,ffffffffc020568c <schedule+0x80>
ffffffffc0205634:	0c888693          	addi	a3,a7,200
ffffffffc0205638:	000ad617          	auipc	a2,0xad
ffffffffc020563c:	18060613          	addi	a2,a2,384 # ffffffffc02b27b8 <proc_list>
        le = last;
ffffffffc0205640:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205642:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205644:	4809                	li	a6,2
ffffffffc0205646:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205648:	00c78863          	beq	a5,a2,ffffffffc0205658 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020564c:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205650:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205654:	03070163          	beq	a4,a6,ffffffffc0205676 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205658:	fef697e3          	bne	a3,a5,ffffffffc0205646 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020565c:	ed89                	bnez	a1,ffffffffc0205676 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020565e:	451c                	lw	a5,8(a0)
ffffffffc0205660:	2785                	addiw	a5,a5,1
ffffffffc0205662:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205664:	00a88463          	beq	a7,a0,ffffffffc020566c <schedule+0x60>
            proc_run(next);
ffffffffc0205668:	b32ff0ef          	jal	ra,ffffffffc020499a <proc_run>
    if (flag) {
ffffffffc020566c:	e819                	bnez	s0,ffffffffc0205682 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020566e:	60a2                	ld	ra,8(sp)
ffffffffc0205670:	6402                	ld	s0,0(sp)
ffffffffc0205672:	0141                	addi	sp,sp,16
ffffffffc0205674:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205676:	4198                	lw	a4,0(a1)
ffffffffc0205678:	4789                	li	a5,2
ffffffffc020567a:	fef712e3          	bne	a4,a5,ffffffffc020565e <schedule+0x52>
ffffffffc020567e:	852e                	mv	a0,a1
ffffffffc0205680:	bff9                	j	ffffffffc020565e <schedule+0x52>
}
ffffffffc0205682:	6402                	ld	s0,0(sp)
ffffffffc0205684:	60a2                	ld	ra,8(sp)
ffffffffc0205686:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205688:	f95fa06f          	j	ffffffffc020061c <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020568c:	000ad617          	auipc	a2,0xad
ffffffffc0205690:	12c60613          	addi	a2,a2,300 # ffffffffc02b27b8 <proc_list>
ffffffffc0205694:	86b2                	mv	a3,a2
ffffffffc0205696:	b76d                	j	ffffffffc0205640 <schedule+0x34>
        intr_disable();
ffffffffc0205698:	f8bfa0ef          	jal	ra,ffffffffc0200622 <intr_disable>
        return 1;
ffffffffc020569c:	4405                	li	s0,1
ffffffffc020569e:	bfbd                	j	ffffffffc020561c <schedule+0x10>

ffffffffc02056a0 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02056a0:	000ad797          	auipc	a5,0xad
ffffffffc02056a4:	1a07b783          	ld	a5,416(a5) # ffffffffc02b2840 <current>
}
ffffffffc02056a8:	43c8                	lw	a0,4(a5)
ffffffffc02056aa:	8082                	ret

ffffffffc02056ac <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02056ac:	4501                	li	a0,0
ffffffffc02056ae:	8082                	ret

ffffffffc02056b0 <sys_putc>:
    cputchar(c);
ffffffffc02056b0:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02056b2:	1141                	addi	sp,sp,-16
ffffffffc02056b4:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02056b6:	b01fa0ef          	jal	ra,ffffffffc02001b6 <cputchar>
}
ffffffffc02056ba:	60a2                	ld	ra,8(sp)
ffffffffc02056bc:	4501                	li	a0,0
ffffffffc02056be:	0141                	addi	sp,sp,16
ffffffffc02056c0:	8082                	ret

ffffffffc02056c2 <sys_kill>:
    return do_kill(pid);
ffffffffc02056c2:	4108                	lw	a0,0(a0)
ffffffffc02056c4:	c97ff06f          	j	ffffffffc020535a <do_kill>

ffffffffc02056c8 <sys_yield>:
    return do_yield();
ffffffffc02056c8:	c45ff06f          	j	ffffffffc020530c <do_yield>

ffffffffc02056cc <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02056cc:	6d14                	ld	a3,24(a0)
ffffffffc02056ce:	6910                	ld	a2,16(a0)
ffffffffc02056d0:	650c                	ld	a1,8(a0)
ffffffffc02056d2:	6108                	ld	a0,0(a0)
ffffffffc02056d4:	f44ff06f          	j	ffffffffc0204e18 <do_execve>

ffffffffc02056d8 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02056d8:	650c                	ld	a1,8(a0)
ffffffffc02056da:	4108                	lw	a0,0(a0)
ffffffffc02056dc:	c41ff06f          	j	ffffffffc020531c <do_wait>

ffffffffc02056e0 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02056e0:	000ad797          	auipc	a5,0xad
ffffffffc02056e4:	1607b783          	ld	a5,352(a5) # ffffffffc02b2840 <current>
ffffffffc02056e8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02056ea:	4501                	li	a0,0
ffffffffc02056ec:	6a0c                	ld	a1,16(a2)
ffffffffc02056ee:	ad8ff06f          	j	ffffffffc02049c6 <do_fork>

ffffffffc02056f2 <sys_exit>:
    return do_exit(error_code);
ffffffffc02056f2:	4108                	lw	a0,0(a0)
ffffffffc02056f4:	ae4ff06f          	j	ffffffffc02049d8 <do_exit>

ffffffffc02056f8 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02056f8:	715d                	addi	sp,sp,-80
ffffffffc02056fa:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02056fc:	000ad497          	auipc	s1,0xad
ffffffffc0205700:	14448493          	addi	s1,s1,324 # ffffffffc02b2840 <current>
ffffffffc0205704:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205706:	e0a2                	sd	s0,64(sp)
ffffffffc0205708:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc020570a:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc020570c:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020570e:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205710:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205714:	0327ee63          	bltu	a5,s2,ffffffffc0205750 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205718:	00391713          	slli	a4,s2,0x3
ffffffffc020571c:	00002797          	auipc	a5,0x2
ffffffffc0205720:	6e478793          	addi	a5,a5,1764 # ffffffffc0207e00 <syscalls>
ffffffffc0205724:	97ba                	add	a5,a5,a4
ffffffffc0205726:	639c                	ld	a5,0(a5)
ffffffffc0205728:	c785                	beqz	a5,ffffffffc0205750 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc020572a:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020572c:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020572e:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205730:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205732:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205734:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205736:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205738:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020573a:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020573c:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020573e:	0028                	addi	a0,sp,8
ffffffffc0205740:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205742:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205744:	e828                	sd	a0,80(s0)
}
ffffffffc0205746:	6406                	ld	s0,64(sp)
ffffffffc0205748:	74e2                	ld	s1,56(sp)
ffffffffc020574a:	7942                	ld	s2,48(sp)
ffffffffc020574c:	6161                	addi	sp,sp,80
ffffffffc020574e:	8082                	ret
    print_trapframe(tf);
ffffffffc0205750:	8522                	mv	a0,s0
ffffffffc0205752:	8befb0ef          	jal	ra,ffffffffc0200810 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205756:	609c                	ld	a5,0(s1)
ffffffffc0205758:	86ca                	mv	a3,s2
ffffffffc020575a:	00002617          	auipc	a2,0x2
ffffffffc020575e:	65e60613          	addi	a2,a2,1630 # ffffffffc0207db8 <default_pmm_manager+0x1440>
ffffffffc0205762:	43d8                	lw	a4,4(a5)
ffffffffc0205764:	06200593          	li	a1,98
ffffffffc0205768:	0b478793          	addi	a5,a5,180
ffffffffc020576c:	00002517          	auipc	a0,0x2
ffffffffc0205770:	67c50513          	addi	a0,a0,1660 # ffffffffc0207de8 <default_pmm_manager+0x1470>
ffffffffc0205774:	d07fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205778 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205778:	9e3707b7          	lui	a5,0x9e370
ffffffffc020577c:	2785                	addiw	a5,a5,1
ffffffffc020577e:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205782:	02000793          	li	a5,32
ffffffffc0205786:	9f8d                	subw	a5,a5,a1
}
ffffffffc0205788:	00f5553b          	srlw	a0,a0,a5
ffffffffc020578c:	8082                	ret

ffffffffc020578e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020578e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205792:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205794:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205798:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020579a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020579e:	f022                	sd	s0,32(sp)
ffffffffc02057a0:	ec26                	sd	s1,24(sp)
ffffffffc02057a2:	e84a                	sd	s2,16(sp)
ffffffffc02057a4:	f406                	sd	ra,40(sp)
ffffffffc02057a6:	e44e                	sd	s3,8(sp)
ffffffffc02057a8:	84aa                	mv	s1,a0
ffffffffc02057aa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02057ac:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02057b0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02057b2:	03067e63          	bgeu	a2,a6,ffffffffc02057ee <printnum+0x60>
ffffffffc02057b6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02057b8:	00805763          	blez	s0,ffffffffc02057c6 <printnum+0x38>
ffffffffc02057bc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02057be:	85ca                	mv	a1,s2
ffffffffc02057c0:	854e                	mv	a0,s3
ffffffffc02057c2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02057c4:	fc65                	bnez	s0,ffffffffc02057bc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057c6:	1a02                	slli	s4,s4,0x20
ffffffffc02057c8:	00002797          	auipc	a5,0x2
ffffffffc02057cc:	73878793          	addi	a5,a5,1848 # ffffffffc0207f00 <syscalls+0x100>
ffffffffc02057d0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02057d4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02057d6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057d8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02057dc:	70a2                	ld	ra,40(sp)
ffffffffc02057de:	69a2                	ld	s3,8(sp)
ffffffffc02057e0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057e2:	85ca                	mv	a1,s2
ffffffffc02057e4:	87a6                	mv	a5,s1
}
ffffffffc02057e6:	6942                	ld	s2,16(sp)
ffffffffc02057e8:	64e2                	ld	s1,24(sp)
ffffffffc02057ea:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057ec:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02057ee:	03065633          	divu	a2,a2,a6
ffffffffc02057f2:	8722                	mv	a4,s0
ffffffffc02057f4:	f9bff0ef          	jal	ra,ffffffffc020578e <printnum>
ffffffffc02057f8:	b7f9                	j	ffffffffc02057c6 <printnum+0x38>

ffffffffc02057fa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02057fa:	7119                	addi	sp,sp,-128
ffffffffc02057fc:	f4a6                	sd	s1,104(sp)
ffffffffc02057fe:	f0ca                	sd	s2,96(sp)
ffffffffc0205800:	ecce                	sd	s3,88(sp)
ffffffffc0205802:	e8d2                	sd	s4,80(sp)
ffffffffc0205804:	e4d6                	sd	s5,72(sp)
ffffffffc0205806:	e0da                	sd	s6,64(sp)
ffffffffc0205808:	fc5e                	sd	s7,56(sp)
ffffffffc020580a:	f06a                	sd	s10,32(sp)
ffffffffc020580c:	fc86                	sd	ra,120(sp)
ffffffffc020580e:	f8a2                	sd	s0,112(sp)
ffffffffc0205810:	f862                	sd	s8,48(sp)
ffffffffc0205812:	f466                	sd	s9,40(sp)
ffffffffc0205814:	ec6e                	sd	s11,24(sp)
ffffffffc0205816:	892a                	mv	s2,a0
ffffffffc0205818:	84ae                	mv	s1,a1
ffffffffc020581a:	8d32                	mv	s10,a2
ffffffffc020581c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020581e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205822:	5b7d                	li	s6,-1
ffffffffc0205824:	00002a97          	auipc	s5,0x2
ffffffffc0205828:	708a8a93          	addi	s5,s5,1800 # ffffffffc0207f2c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020582c:	00003b97          	auipc	s7,0x3
ffffffffc0205830:	91cb8b93          	addi	s7,s7,-1764 # ffffffffc0208148 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205834:	000d4503          	lbu	a0,0(s10)
ffffffffc0205838:	001d0413          	addi	s0,s10,1
ffffffffc020583c:	01350a63          	beq	a0,s3,ffffffffc0205850 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0205840:	c121                	beqz	a0,ffffffffc0205880 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0205842:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205844:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205846:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205848:	fff44503          	lbu	a0,-1(s0)
ffffffffc020584c:	ff351ae3          	bne	a0,s3,ffffffffc0205840 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205850:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205854:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0205858:	4c81                	li	s9,0
ffffffffc020585a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020585c:	5c7d                	li	s8,-1
ffffffffc020585e:	5dfd                	li	s11,-1
ffffffffc0205860:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0205864:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205866:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020586a:	0ff5f593          	andi	a1,a1,255
ffffffffc020586e:	00140d13          	addi	s10,s0,1
ffffffffc0205872:	04b56263          	bltu	a0,a1,ffffffffc02058b6 <vprintfmt+0xbc>
ffffffffc0205876:	058a                	slli	a1,a1,0x2
ffffffffc0205878:	95d6                	add	a1,a1,s5
ffffffffc020587a:	4194                	lw	a3,0(a1)
ffffffffc020587c:	96d6                	add	a3,a3,s5
ffffffffc020587e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205880:	70e6                	ld	ra,120(sp)
ffffffffc0205882:	7446                	ld	s0,112(sp)
ffffffffc0205884:	74a6                	ld	s1,104(sp)
ffffffffc0205886:	7906                	ld	s2,96(sp)
ffffffffc0205888:	69e6                	ld	s3,88(sp)
ffffffffc020588a:	6a46                	ld	s4,80(sp)
ffffffffc020588c:	6aa6                	ld	s5,72(sp)
ffffffffc020588e:	6b06                	ld	s6,64(sp)
ffffffffc0205890:	7be2                	ld	s7,56(sp)
ffffffffc0205892:	7c42                	ld	s8,48(sp)
ffffffffc0205894:	7ca2                	ld	s9,40(sp)
ffffffffc0205896:	7d02                	ld	s10,32(sp)
ffffffffc0205898:	6de2                	ld	s11,24(sp)
ffffffffc020589a:	6109                	addi	sp,sp,128
ffffffffc020589c:	8082                	ret
            padc = '0';
ffffffffc020589e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02058a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058a4:	846a                	mv	s0,s10
ffffffffc02058a6:	00140d13          	addi	s10,s0,1
ffffffffc02058aa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02058ae:	0ff5f593          	andi	a1,a1,255
ffffffffc02058b2:	fcb572e3          	bgeu	a0,a1,ffffffffc0205876 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02058b6:	85a6                	mv	a1,s1
ffffffffc02058b8:	02500513          	li	a0,37
ffffffffc02058bc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02058be:	fff44783          	lbu	a5,-1(s0)
ffffffffc02058c2:	8d22                	mv	s10,s0
ffffffffc02058c4:	f73788e3          	beq	a5,s3,ffffffffc0205834 <vprintfmt+0x3a>
ffffffffc02058c8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02058cc:	1d7d                	addi	s10,s10,-1
ffffffffc02058ce:	ff379de3          	bne	a5,s3,ffffffffc02058c8 <vprintfmt+0xce>
ffffffffc02058d2:	b78d                	j	ffffffffc0205834 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02058d4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02058d8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058dc:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02058de:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02058e2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02058e6:	02d86463          	bltu	a6,a3,ffffffffc020590e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02058ea:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02058ee:	002c169b          	slliw	a3,s8,0x2
ffffffffc02058f2:	0186873b          	addw	a4,a3,s8
ffffffffc02058f6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02058fa:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02058fc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205900:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0205902:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205906:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020590a:	fed870e3          	bgeu	a6,a3,ffffffffc02058ea <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020590e:	f40ddce3          	bgez	s11,ffffffffc0205866 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0205912:	8de2                	mv	s11,s8
ffffffffc0205914:	5c7d                	li	s8,-1
ffffffffc0205916:	bf81                	j	ffffffffc0205866 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205918:	fffdc693          	not	a3,s11
ffffffffc020591c:	96fd                	srai	a3,a3,0x3f
ffffffffc020591e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205922:	00144603          	lbu	a2,1(s0)
ffffffffc0205926:	2d81                	sext.w	s11,s11
ffffffffc0205928:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020592a:	bf35                	j	ffffffffc0205866 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020592c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205930:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205934:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205936:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0205938:	bfd9                	j	ffffffffc020590e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020593a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020593c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205940:	01174463          	blt	a4,a7,ffffffffc0205948 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0205944:	1a088e63          	beqz	a7,ffffffffc0205b00 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0205948:	000a3603          	ld	a2,0(s4)
ffffffffc020594c:	46c1                	li	a3,16
ffffffffc020594e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205950:	2781                	sext.w	a5,a5
ffffffffc0205952:	876e                	mv	a4,s11
ffffffffc0205954:	85a6                	mv	a1,s1
ffffffffc0205956:	854a                	mv	a0,s2
ffffffffc0205958:	e37ff0ef          	jal	ra,ffffffffc020578e <printnum>
            break;
ffffffffc020595c:	bde1                	j	ffffffffc0205834 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020595e:	000a2503          	lw	a0,0(s4)
ffffffffc0205962:	85a6                	mv	a1,s1
ffffffffc0205964:	0a21                	addi	s4,s4,8
ffffffffc0205966:	9902                	jalr	s2
            break;
ffffffffc0205968:	b5f1                	j	ffffffffc0205834 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020596a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020596c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205970:	01174463          	blt	a4,a7,ffffffffc0205978 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0205974:	18088163          	beqz	a7,ffffffffc0205af6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0205978:	000a3603          	ld	a2,0(s4)
ffffffffc020597c:	46a9                	li	a3,10
ffffffffc020597e:	8a2e                	mv	s4,a1
ffffffffc0205980:	bfc1                	j	ffffffffc0205950 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205982:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0205986:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205988:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020598a:	bdf1                	j	ffffffffc0205866 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020598c:	85a6                	mv	a1,s1
ffffffffc020598e:	02500513          	li	a0,37
ffffffffc0205992:	9902                	jalr	s2
            break;
ffffffffc0205994:	b545                	j	ffffffffc0205834 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205996:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020599a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020599c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020599e:	b5e1                	j	ffffffffc0205866 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02059a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02059a2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02059a6:	01174463          	blt	a4,a7,ffffffffc02059ae <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02059aa:	14088163          	beqz	a7,ffffffffc0205aec <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02059ae:	000a3603          	ld	a2,0(s4)
ffffffffc02059b2:	46a1                	li	a3,8
ffffffffc02059b4:	8a2e                	mv	s4,a1
ffffffffc02059b6:	bf69                	j	ffffffffc0205950 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02059b8:	03000513          	li	a0,48
ffffffffc02059bc:	85a6                	mv	a1,s1
ffffffffc02059be:	e03e                	sd	a5,0(sp)
ffffffffc02059c0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02059c2:	85a6                	mv	a1,s1
ffffffffc02059c4:	07800513          	li	a0,120
ffffffffc02059c8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02059ca:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02059cc:	6782                	ld	a5,0(sp)
ffffffffc02059ce:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02059d0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02059d4:	bfb5                	j	ffffffffc0205950 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02059d6:	000a3403          	ld	s0,0(s4)
ffffffffc02059da:	008a0713          	addi	a4,s4,8
ffffffffc02059de:	e03a                	sd	a4,0(sp)
ffffffffc02059e0:	14040263          	beqz	s0,ffffffffc0205b24 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02059e4:	0fb05763          	blez	s11,ffffffffc0205ad2 <vprintfmt+0x2d8>
ffffffffc02059e8:	02d00693          	li	a3,45
ffffffffc02059ec:	0cd79163          	bne	a5,a3,ffffffffc0205aae <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02059f0:	00044783          	lbu	a5,0(s0)
ffffffffc02059f4:	0007851b          	sext.w	a0,a5
ffffffffc02059f8:	cf85                	beqz	a5,ffffffffc0205a30 <vprintfmt+0x236>
ffffffffc02059fa:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02059fe:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205a02:	000c4563          	bltz	s8,ffffffffc0205a0c <vprintfmt+0x212>
ffffffffc0205a06:	3c7d                	addiw	s8,s8,-1
ffffffffc0205a08:	036c0263          	beq	s8,s6,ffffffffc0205a2c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0205a0c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205a0e:	0e0c8e63          	beqz	s9,ffffffffc0205b0a <vprintfmt+0x310>
ffffffffc0205a12:	3781                	addiw	a5,a5,-32
ffffffffc0205a14:	0ef47b63          	bgeu	s0,a5,ffffffffc0205b0a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205a18:	03f00513          	li	a0,63
ffffffffc0205a1c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205a1e:	000a4783          	lbu	a5,0(s4)
ffffffffc0205a22:	3dfd                	addiw	s11,s11,-1
ffffffffc0205a24:	0a05                	addi	s4,s4,1
ffffffffc0205a26:	0007851b          	sext.w	a0,a5
ffffffffc0205a2a:	ffe1                	bnez	a5,ffffffffc0205a02 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0205a2c:	01b05963          	blez	s11,ffffffffc0205a3e <vprintfmt+0x244>
ffffffffc0205a30:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205a32:	85a6                	mv	a1,s1
ffffffffc0205a34:	02000513          	li	a0,32
ffffffffc0205a38:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0205a3a:	fe0d9be3          	bnez	s11,ffffffffc0205a30 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205a3e:	6a02                	ld	s4,0(sp)
ffffffffc0205a40:	bbd5                	j	ffffffffc0205834 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205a42:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205a44:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0205a48:	01174463          	blt	a4,a7,ffffffffc0205a50 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0205a4c:	08088d63          	beqz	a7,ffffffffc0205ae6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0205a50:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205a54:	0a044d63          	bltz	s0,ffffffffc0205b0e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0205a58:	8622                	mv	a2,s0
ffffffffc0205a5a:	8a66                	mv	s4,s9
ffffffffc0205a5c:	46a9                	li	a3,10
ffffffffc0205a5e:	bdcd                	j	ffffffffc0205950 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0205a60:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205a64:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0205a66:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0205a68:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0205a6c:	8fb5                	xor	a5,a5,a3
ffffffffc0205a6e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205a72:	02d74163          	blt	a4,a3,ffffffffc0205a94 <vprintfmt+0x29a>
ffffffffc0205a76:	00369793          	slli	a5,a3,0x3
ffffffffc0205a7a:	97de                	add	a5,a5,s7
ffffffffc0205a7c:	639c                	ld	a5,0(a5)
ffffffffc0205a7e:	cb99                	beqz	a5,ffffffffc0205a94 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0205a80:	86be                	mv	a3,a5
ffffffffc0205a82:	00000617          	auipc	a2,0x0
ffffffffc0205a86:	1ce60613          	addi	a2,a2,462 # ffffffffc0205c50 <etext+0x2e>
ffffffffc0205a8a:	85a6                	mv	a1,s1
ffffffffc0205a8c:	854a                	mv	a0,s2
ffffffffc0205a8e:	0ce000ef          	jal	ra,ffffffffc0205b5c <printfmt>
ffffffffc0205a92:	b34d                	j	ffffffffc0205834 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205a94:	00002617          	auipc	a2,0x2
ffffffffc0205a98:	48c60613          	addi	a2,a2,1164 # ffffffffc0207f20 <syscalls+0x120>
ffffffffc0205a9c:	85a6                	mv	a1,s1
ffffffffc0205a9e:	854a                	mv	a0,s2
ffffffffc0205aa0:	0bc000ef          	jal	ra,ffffffffc0205b5c <printfmt>
ffffffffc0205aa4:	bb41                	j	ffffffffc0205834 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0205aa6:	00002417          	auipc	s0,0x2
ffffffffc0205aaa:	47240413          	addi	s0,s0,1138 # ffffffffc0207f18 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205aae:	85e2                	mv	a1,s8
ffffffffc0205ab0:	8522                	mv	a0,s0
ffffffffc0205ab2:	e43e                	sd	a5,8(sp)
ffffffffc0205ab4:	0e2000ef          	jal	ra,ffffffffc0205b96 <strnlen>
ffffffffc0205ab8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205abc:	01b05b63          	blez	s11,ffffffffc0205ad2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205ac0:	67a2                	ld	a5,8(sp)
ffffffffc0205ac2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205ac6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205ac8:	85a6                	mv	a1,s1
ffffffffc0205aca:	8552                	mv	a0,s4
ffffffffc0205acc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205ace:	fe0d9ce3          	bnez	s11,ffffffffc0205ac6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205ad2:	00044783          	lbu	a5,0(s0)
ffffffffc0205ad6:	00140a13          	addi	s4,s0,1
ffffffffc0205ada:	0007851b          	sext.w	a0,a5
ffffffffc0205ade:	d3a5                	beqz	a5,ffffffffc0205a3e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205ae0:	05e00413          	li	s0,94
ffffffffc0205ae4:	bf39                	j	ffffffffc0205a02 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0205ae6:	000a2403          	lw	s0,0(s4)
ffffffffc0205aea:	b7ad                	j	ffffffffc0205a54 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0205aec:	000a6603          	lwu	a2,0(s4)
ffffffffc0205af0:	46a1                	li	a3,8
ffffffffc0205af2:	8a2e                	mv	s4,a1
ffffffffc0205af4:	bdb1                	j	ffffffffc0205950 <vprintfmt+0x156>
ffffffffc0205af6:	000a6603          	lwu	a2,0(s4)
ffffffffc0205afa:	46a9                	li	a3,10
ffffffffc0205afc:	8a2e                	mv	s4,a1
ffffffffc0205afe:	bd89                	j	ffffffffc0205950 <vprintfmt+0x156>
ffffffffc0205b00:	000a6603          	lwu	a2,0(s4)
ffffffffc0205b04:	46c1                	li	a3,16
ffffffffc0205b06:	8a2e                	mv	s4,a1
ffffffffc0205b08:	b5a1                	j	ffffffffc0205950 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0205b0a:	9902                	jalr	s2
ffffffffc0205b0c:	bf09                	j	ffffffffc0205a1e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0205b0e:	85a6                	mv	a1,s1
ffffffffc0205b10:	02d00513          	li	a0,45
ffffffffc0205b14:	e03e                	sd	a5,0(sp)
ffffffffc0205b16:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205b18:	6782                	ld	a5,0(sp)
ffffffffc0205b1a:	8a66                	mv	s4,s9
ffffffffc0205b1c:	40800633          	neg	a2,s0
ffffffffc0205b20:	46a9                	li	a3,10
ffffffffc0205b22:	b53d                	j	ffffffffc0205950 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205b24:	03b05163          	blez	s11,ffffffffc0205b46 <vprintfmt+0x34c>
ffffffffc0205b28:	02d00693          	li	a3,45
ffffffffc0205b2c:	f6d79de3          	bne	a5,a3,ffffffffc0205aa6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0205b30:	00002417          	auipc	s0,0x2
ffffffffc0205b34:	3e840413          	addi	s0,s0,1000 # ffffffffc0207f18 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205b38:	02800793          	li	a5,40
ffffffffc0205b3c:	02800513          	li	a0,40
ffffffffc0205b40:	00140a13          	addi	s4,s0,1
ffffffffc0205b44:	bd6d                	j	ffffffffc02059fe <vprintfmt+0x204>
ffffffffc0205b46:	00002a17          	auipc	s4,0x2
ffffffffc0205b4a:	3d3a0a13          	addi	s4,s4,979 # ffffffffc0207f19 <syscalls+0x119>
ffffffffc0205b4e:	02800513          	li	a0,40
ffffffffc0205b52:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205b56:	05e00413          	li	s0,94
ffffffffc0205b5a:	b565                	j	ffffffffc0205a02 <vprintfmt+0x208>

ffffffffc0205b5c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b5c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205b5e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b62:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205b64:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b66:	ec06                	sd	ra,24(sp)
ffffffffc0205b68:	f83a                	sd	a4,48(sp)
ffffffffc0205b6a:	fc3e                	sd	a5,56(sp)
ffffffffc0205b6c:	e0c2                	sd	a6,64(sp)
ffffffffc0205b6e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205b70:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205b72:	c89ff0ef          	jal	ra,ffffffffc02057fa <vprintfmt>
}
ffffffffc0205b76:	60e2                	ld	ra,24(sp)
ffffffffc0205b78:	6161                	addi	sp,sp,80
ffffffffc0205b7a:	8082                	ret

ffffffffc0205b7c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205b7c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205b80:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205b82:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205b84:	cb81                	beqz	a5,ffffffffc0205b94 <strlen+0x18>
        cnt ++;
ffffffffc0205b86:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205b88:	00a707b3          	add	a5,a4,a0
ffffffffc0205b8c:	0007c783          	lbu	a5,0(a5)
ffffffffc0205b90:	fbfd                	bnez	a5,ffffffffc0205b86 <strlen+0xa>
ffffffffc0205b92:	8082                	ret
    }
    return cnt;
}
ffffffffc0205b94:	8082                	ret

ffffffffc0205b96 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205b96:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205b98:	e589                	bnez	a1,ffffffffc0205ba2 <strnlen+0xc>
ffffffffc0205b9a:	a811                	j	ffffffffc0205bae <strnlen+0x18>
        cnt ++;
ffffffffc0205b9c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205b9e:	00f58863          	beq	a1,a5,ffffffffc0205bae <strnlen+0x18>
ffffffffc0205ba2:	00f50733          	add	a4,a0,a5
ffffffffc0205ba6:	00074703          	lbu	a4,0(a4)
ffffffffc0205baa:	fb6d                	bnez	a4,ffffffffc0205b9c <strnlen+0x6>
ffffffffc0205bac:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205bae:	852e                	mv	a0,a1
ffffffffc0205bb0:	8082                	ret

ffffffffc0205bb2 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205bb2:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205bb4:	0005c703          	lbu	a4,0(a1)
ffffffffc0205bb8:	0785                	addi	a5,a5,1
ffffffffc0205bba:	0585                	addi	a1,a1,1
ffffffffc0205bbc:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205bc0:	fb75                	bnez	a4,ffffffffc0205bb4 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205bc2:	8082                	ret

ffffffffc0205bc4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205bc4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205bc8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205bcc:	cb89                	beqz	a5,ffffffffc0205bde <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205bce:	0505                	addi	a0,a0,1
ffffffffc0205bd0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205bd2:	fee789e3          	beq	a5,a4,ffffffffc0205bc4 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205bd6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205bda:	9d19                	subw	a0,a0,a4
ffffffffc0205bdc:	8082                	ret
ffffffffc0205bde:	4501                	li	a0,0
ffffffffc0205be0:	bfed                	j	ffffffffc0205bda <strcmp+0x16>

ffffffffc0205be2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205be2:	00054783          	lbu	a5,0(a0)
ffffffffc0205be6:	c799                	beqz	a5,ffffffffc0205bf4 <strchr+0x12>
        if (*s == c) {
ffffffffc0205be8:	00f58763          	beq	a1,a5,ffffffffc0205bf6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0205bec:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0205bf0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205bf2:	fbfd                	bnez	a5,ffffffffc0205be8 <strchr+0x6>
    }
    return NULL;
ffffffffc0205bf4:	4501                	li	a0,0
}
ffffffffc0205bf6:	8082                	ret

ffffffffc0205bf8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205bf8:	ca01                	beqz	a2,ffffffffc0205c08 <memset+0x10>
ffffffffc0205bfa:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205bfc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205bfe:	0785                	addi	a5,a5,1
ffffffffc0205c00:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205c04:	fec79de3          	bne	a5,a2,ffffffffc0205bfe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205c08:	8082                	ret

ffffffffc0205c0a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205c0a:	ca19                	beqz	a2,ffffffffc0205c20 <memcpy+0x16>
ffffffffc0205c0c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205c0e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205c10:	0005c703          	lbu	a4,0(a1)
ffffffffc0205c14:	0585                	addi	a1,a1,1
ffffffffc0205c16:	0785                	addi	a5,a5,1
ffffffffc0205c18:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205c1c:	fec59ae3          	bne	a1,a2,ffffffffc0205c10 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205c20:	8082                	ret
