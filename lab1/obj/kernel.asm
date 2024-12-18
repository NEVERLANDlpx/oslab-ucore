
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1101                	addi	sp,sp,-32
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	ec06                	sd	ra,24(sp)
    80200022:	e822                	sd	s0,16(sp)
    80200024:	e426                	sd	s1,8(sp)
    memset(edata, 0, end - edata);
    80200026:	22d000ef          	jal	ra,80200a52 <memset>

    cons_init();  // init the console
    8020002a:	18a000ef          	jal	ra,802001b4 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002e:	00001597          	auipc	a1,0x1
    80200032:	a3a58593          	addi	a1,a1,-1478 # 80200a68 <etext+0x4>
    80200036:	00001517          	auipc	a0,0x1
    8020003a:	a5250513          	addi	a0,a0,-1454 # 80200a88 <etext+0x24>
    8020003e:	070000ef          	jal	ra,802000ae <cprintf>

    print_kerninfo();
    80200042:	0a2000ef          	jal	ra,802000e4 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200046:	17e000ef          	jal	ra,802001c4 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    8020004a:	128000ef          	jal	ra,80200172 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004e:	170000ef          	jal	ra,802001be <intr_enable>

    //add begin :2213109
    asm("mret");
    asm("ebreak");
    80200052:	30002473          	csrr	s0,mstatus
    //add end
    80200056:	341024f3          	csrr	s1,mepc
    while (1)
    8020005a:	00001517          	auipc	a0,0x1
    8020005e:	a3650513          	addi	a0,a0,-1482 # 80200a90 <etext+0x2c>
    80200062:	85a2                	mv	a1,s0
    80200064:	04a000ef          	jal	ra,802000ae <cprintf>
        ;
    80200068:	85a6                	mv	a1,s1
    8020006a:	00001517          	auipc	a0,0x1
    8020006e:	a3650513          	addi	a0,a0,-1482 # 80200aa0 <etext+0x3c>
    80200072:	03c000ef          	jal	ra,802000ae <cprintf>
}
    80200076:	00b45593          	srli	a1,s0,0xb

    8020007a:	898d                	andi	a1,a1,3
    8020007c:	00001517          	auipc	a0,0x1
    80200080:	a3450513          	addi	a0,a0,-1484 # 80200ab0 <etext+0x4c>
    80200084:	02a000ef          	jal	ra,802000ae <cprintf>
void __attribute__((noinline))
grade_backtrace2(unsigned long long arg0, unsigned long long arg1, unsigned long long arg2, unsigned long long arg3) {
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline)) grade_backtrace1(int arg0, int arg1) {
    80200088:	30200073          	mret
    grade_backtrace2(arg0, (unsigned long long)&arg0, arg1, (unsigned long long)&arg1);
    8020008c:	9002                	ebreak
}
    8020008e:	10200073          	sret

void __attribute__((noinline)) grade_backtrace0(int arg0, int arg1, int arg2) {
    80200092:	a001                	j	80200092 <kern_init+0x88>

0000000080200094 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200094:	1141                	addi	sp,sp,-16
    80200096:	e022                	sd	s0,0(sp)
    80200098:	e406                	sd	ra,8(sp)
    8020009a:	842e                	mv	s0,a1
    cons_putc(c);
    8020009c:	11a000ef          	jal	ra,802001b6 <cons_putc>
    (*cnt)++;
    802000a0:	401c                	lw	a5,0(s0)
}
    802000a2:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    802000a4:	2785                	addiw	a5,a5,1
    802000a6:	c01c                	sw	a5,0(s0)
}
    802000a8:	6402                	ld	s0,0(sp)
    802000aa:	0141                	addi	sp,sp,16
    802000ac:	8082                	ret

00000000802000ae <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    802000ae:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    802000b0:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    802000b4:	8e2a                	mv	t3,a0
    802000b6:	f42e                	sd	a1,40(sp)
    802000b8:	f832                	sd	a2,48(sp)
    802000ba:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    802000bc:	00000517          	auipc	a0,0x0
    802000c0:	fd850513          	addi	a0,a0,-40 # 80200094 <cputch>
    802000c4:	004c                	addi	a1,sp,4
    802000c6:	869a                	mv	a3,t1
    802000c8:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    802000ca:	ec06                	sd	ra,24(sp)
    802000cc:	e0ba                	sd	a4,64(sp)
    802000ce:	e4be                	sd	a5,72(sp)
    802000d0:	e8c2                	sd	a6,80(sp)
    802000d2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    802000d4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    802000d6:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    802000d8:	58e000ef          	jal	ra,80200666 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    802000dc:	60e2                	ld	ra,24(sp)
    802000de:	4512                	lw	a0,4(sp)
    802000e0:	6125                	addi	sp,sp,96
    802000e2:	8082                	ret

00000000802000e4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000e4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	9da50513          	addi	a0,a0,-1574 # 80200ac0 <etext+0x5c>
void print_kerninfo(void) {
    802000ee:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000f0:	fbfff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000f4:	00000597          	auipc	a1,0x0
    802000f8:	f1658593          	addi	a1,a1,-234 # 8020000a <kern_init>
    802000fc:	00001517          	auipc	a0,0x1
    80200100:	9e450513          	addi	a0,a0,-1564 # 80200ae0 <etext+0x7c>
    80200104:	fabff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    80200108:	00001597          	auipc	a1,0x1
    8020010c:	95c58593          	addi	a1,a1,-1700 # 80200a64 <etext>
    80200110:	00001517          	auipc	a0,0x1
    80200114:	9f050513          	addi	a0,a0,-1552 # 80200b00 <etext+0x9c>
    80200118:	f97ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    8020011c:	00004597          	auipc	a1,0x4
    80200120:	ef458593          	addi	a1,a1,-268 # 80204010 <ticks>
    80200124:	00001517          	auipc	a0,0x1
    80200128:	9fc50513          	addi	a0,a0,-1540 # 80200b20 <etext+0xbc>
    8020012c:	f83ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    80200130:	00004597          	auipc	a1,0x4
    80200134:	ef858593          	addi	a1,a1,-264 # 80204028 <end>
    80200138:	00001517          	auipc	a0,0x1
    8020013c:	a0850513          	addi	a0,a0,-1528 # 80200b40 <etext+0xdc>
    80200140:	f6fff0ef          	jal	ra,802000ae <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200144:	00004597          	auipc	a1,0x4
    80200148:	2e358593          	addi	a1,a1,739 # 80204427 <end+0x3ff>
    8020014c:	00000797          	auipc	a5,0x0
    80200150:	ebe78793          	addi	a5,a5,-322 # 8020000a <kern_init>
    80200154:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200158:	43f7d593          	srai	a1,a5,0x3f
}
    8020015c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020015e:	3ff5f593          	andi	a1,a1,1023
    80200162:	95be                	add	a1,a1,a5
    80200164:	85a9                	srai	a1,a1,0xa
    80200166:	00001517          	auipc	a0,0x1
    8020016a:	9fa50513          	addi	a0,a0,-1542 # 80200b60 <etext+0xfc>
}
    8020016e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200170:	bf3d                	j	802000ae <cprintf>

0000000080200172 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200172:	1141                	addi	sp,sp,-16
    80200174:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200176:	02000793          	li	a5,32
    8020017a:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020017e:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200182:	67e1                	lui	a5,0x18
    80200184:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200188:	953e                	add	a0,a0,a5
    8020018a:	079000ef          	jal	ra,80200a02 <sbi_set_timer>
}
    8020018e:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200190:	00004797          	auipc	a5,0x4
    80200194:	e807b023          	sd	zero,-384(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200198:	00001517          	auipc	a0,0x1
    8020019c:	9f850513          	addi	a0,a0,-1544 # 80200b90 <etext+0x12c>
}
    802001a0:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    802001a2:	b731                	j	802000ae <cprintf>

00000000802001a4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    802001a4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    802001a8:	67e1                	lui	a5,0x18
    802001aa:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    802001ae:	953e                	add	a0,a0,a5
    802001b0:	0530006f          	j	80200a02 <sbi_set_timer>

00000000802001b4 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    802001b4:	8082                	ret

00000000802001b6 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    802001b6:	0ff57513          	andi	a0,a0,255
    802001ba:	02f0006f          	j	802009e8 <sbi_console_putchar>

00000000802001be <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    802001be:	100167f3          	csrrsi	a5,sstatus,2
    802001c2:	8082                	ret

00000000802001c4 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    802001c4:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    802001c8:	00000797          	auipc	a5,0x0
    802001cc:	37c78793          	addi	a5,a5,892 # 80200544 <__alltraps>
    802001d0:	10579073          	csrw	stvec,a5
}
    802001d4:	8082                	ret

00000000802001d6 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001d6:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    802001d8:	1141                	addi	sp,sp,-16
    802001da:	e022                	sd	s0,0(sp)
    802001dc:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	9d250513          	addi	a0,a0,-1582 # 80200bb0 <etext+0x14c>
void print_regs(struct pushregs *gpr) {
    802001e6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001e8:	ec7ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ec:	640c                	ld	a1,8(s0)
    802001ee:	00001517          	auipc	a0,0x1
    802001f2:	9da50513          	addi	a0,a0,-1574 # 80200bc8 <etext+0x164>
    802001f6:	eb9ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001fa:	680c                	ld	a1,16(s0)
    802001fc:	00001517          	auipc	a0,0x1
    80200200:	9e450513          	addi	a0,a0,-1564 # 80200be0 <etext+0x17c>
    80200204:	eabff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    80200208:	6c0c                	ld	a1,24(s0)
    8020020a:	00001517          	auipc	a0,0x1
    8020020e:	9ee50513          	addi	a0,a0,-1554 # 80200bf8 <etext+0x194>
    80200212:	e9dff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    80200216:	700c                	ld	a1,32(s0)
    80200218:	00001517          	auipc	a0,0x1
    8020021c:	9f850513          	addi	a0,a0,-1544 # 80200c10 <etext+0x1ac>
    80200220:	e8fff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    80200224:	740c                	ld	a1,40(s0)
    80200226:	00001517          	auipc	a0,0x1
    8020022a:	a0250513          	addi	a0,a0,-1534 # 80200c28 <etext+0x1c4>
    8020022e:	e81ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    80200232:	780c                	ld	a1,48(s0)
    80200234:	00001517          	auipc	a0,0x1
    80200238:	a0c50513          	addi	a0,a0,-1524 # 80200c40 <etext+0x1dc>
    8020023c:	e73ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200240:	7c0c                	ld	a1,56(s0)
    80200242:	00001517          	auipc	a0,0x1
    80200246:	a1650513          	addi	a0,a0,-1514 # 80200c58 <etext+0x1f4>
    8020024a:	e65ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020024e:	602c                	ld	a1,64(s0)
    80200250:	00001517          	auipc	a0,0x1
    80200254:	a2050513          	addi	a0,a0,-1504 # 80200c70 <etext+0x20c>
    80200258:	e57ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020025c:	642c                	ld	a1,72(s0)
    8020025e:	00001517          	auipc	a0,0x1
    80200262:	a2a50513          	addi	a0,a0,-1494 # 80200c88 <etext+0x224>
    80200266:	e49ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020026a:	682c                	ld	a1,80(s0)
    8020026c:	00001517          	auipc	a0,0x1
    80200270:	a3450513          	addi	a0,a0,-1484 # 80200ca0 <etext+0x23c>
    80200274:	e3bff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200278:	6c2c                	ld	a1,88(s0)
    8020027a:	00001517          	auipc	a0,0x1
    8020027e:	a3e50513          	addi	a0,a0,-1474 # 80200cb8 <etext+0x254>
    80200282:	e2dff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200286:	702c                	ld	a1,96(s0)
    80200288:	00001517          	auipc	a0,0x1
    8020028c:	a4850513          	addi	a0,a0,-1464 # 80200cd0 <etext+0x26c>
    80200290:	e1fff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200294:	742c                	ld	a1,104(s0)
    80200296:	00001517          	auipc	a0,0x1
    8020029a:	a5250513          	addi	a0,a0,-1454 # 80200ce8 <etext+0x284>
    8020029e:	e11ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    802002a2:	782c                	ld	a1,112(s0)
    802002a4:	00001517          	auipc	a0,0x1
    802002a8:	a5c50513          	addi	a0,a0,-1444 # 80200d00 <etext+0x29c>
    802002ac:	e03ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    802002b0:	7c2c                	ld	a1,120(s0)
    802002b2:	00001517          	auipc	a0,0x1
    802002b6:	a6650513          	addi	a0,a0,-1434 # 80200d18 <etext+0x2b4>
    802002ba:	df5ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    802002be:	604c                	ld	a1,128(s0)
    802002c0:	00001517          	auipc	a0,0x1
    802002c4:	a7050513          	addi	a0,a0,-1424 # 80200d30 <etext+0x2cc>
    802002c8:	de7ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    802002cc:	644c                	ld	a1,136(s0)
    802002ce:	00001517          	auipc	a0,0x1
    802002d2:	a7a50513          	addi	a0,a0,-1414 # 80200d48 <etext+0x2e4>
    802002d6:	dd9ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002da:	684c                	ld	a1,144(s0)
    802002dc:	00001517          	auipc	a0,0x1
    802002e0:	a8450513          	addi	a0,a0,-1404 # 80200d60 <etext+0x2fc>
    802002e4:	dcbff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002e8:	6c4c                	ld	a1,152(s0)
    802002ea:	00001517          	auipc	a0,0x1
    802002ee:	a8e50513          	addi	a0,a0,-1394 # 80200d78 <etext+0x314>
    802002f2:	dbdff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002f6:	704c                	ld	a1,160(s0)
    802002f8:	00001517          	auipc	a0,0x1
    802002fc:	a9850513          	addi	a0,a0,-1384 # 80200d90 <etext+0x32c>
    80200300:	dafff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    80200304:	744c                	ld	a1,168(s0)
    80200306:	00001517          	auipc	a0,0x1
    8020030a:	aa250513          	addi	a0,a0,-1374 # 80200da8 <etext+0x344>
    8020030e:	da1ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    80200312:	784c                	ld	a1,176(s0)
    80200314:	00001517          	auipc	a0,0x1
    80200318:	aac50513          	addi	a0,a0,-1364 # 80200dc0 <etext+0x35c>
    8020031c:	d93ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    80200320:	7c4c                	ld	a1,184(s0)
    80200322:	00001517          	auipc	a0,0x1
    80200326:	ab650513          	addi	a0,a0,-1354 # 80200dd8 <etext+0x374>
    8020032a:	d85ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    8020032e:	606c                	ld	a1,192(s0)
    80200330:	00001517          	auipc	a0,0x1
    80200334:	ac050513          	addi	a0,a0,-1344 # 80200df0 <etext+0x38c>
    80200338:	d77ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    8020033c:	646c                	ld	a1,200(s0)
    8020033e:	00001517          	auipc	a0,0x1
    80200342:	aca50513          	addi	a0,a0,-1334 # 80200e08 <etext+0x3a4>
    80200346:	d69ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020034a:	686c                	ld	a1,208(s0)
    8020034c:	00001517          	auipc	a0,0x1
    80200350:	ad450513          	addi	a0,a0,-1324 # 80200e20 <etext+0x3bc>
    80200354:	d5bff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200358:	6c6c                	ld	a1,216(s0)
    8020035a:	00001517          	auipc	a0,0x1
    8020035e:	ade50513          	addi	a0,a0,-1314 # 80200e38 <etext+0x3d4>
    80200362:	d4dff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200366:	706c                	ld	a1,224(s0)
    80200368:	00001517          	auipc	a0,0x1
    8020036c:	ae850513          	addi	a0,a0,-1304 # 80200e50 <etext+0x3ec>
    80200370:	d3fff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200374:	746c                	ld	a1,232(s0)
    80200376:	00001517          	auipc	a0,0x1
    8020037a:	af250513          	addi	a0,a0,-1294 # 80200e68 <etext+0x404>
    8020037e:	d31ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200382:	786c                	ld	a1,240(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	afc50513          	addi	a0,a0,-1284 # 80200e80 <etext+0x41c>
    8020038c:	d23ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200390:	7c6c                	ld	a1,248(s0)
}
    80200392:	6402                	ld	s0,0(sp)
    80200394:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200396:	00001517          	auipc	a0,0x1
    8020039a:	b0250513          	addi	a0,a0,-1278 # 80200e98 <etext+0x434>
}
    8020039e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    802003a0:	b339                	j	802000ae <cprintf>

00000000802003a2 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    802003a2:	1141                	addi	sp,sp,-16
    802003a4:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    802003a6:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    802003a8:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    802003aa:	00001517          	auipc	a0,0x1
    802003ae:	b0650513          	addi	a0,a0,-1274 # 80200eb0 <etext+0x44c>
void print_trapframe(struct trapframe *tf) {
    802003b2:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    802003b4:	cfbff0ef          	jal	ra,802000ae <cprintf>
    print_regs(&tf->gpr);
    802003b8:	8522                	mv	a0,s0
    802003ba:	e1dff0ef          	jal	ra,802001d6 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    802003be:	10043583          	ld	a1,256(s0)
    802003c2:	00001517          	auipc	a0,0x1
    802003c6:	b0650513          	addi	a0,a0,-1274 # 80200ec8 <etext+0x464>
    802003ca:	ce5ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    802003ce:	10843583          	ld	a1,264(s0)
    802003d2:	00001517          	auipc	a0,0x1
    802003d6:	b0e50513          	addi	a0,a0,-1266 # 80200ee0 <etext+0x47c>
    802003da:	cd5ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003de:	11043583          	ld	a1,272(s0)
    802003e2:	00001517          	auipc	a0,0x1
    802003e6:	b1650513          	addi	a0,a0,-1258 # 80200ef8 <etext+0x494>
    802003ea:	cc5ff0ef          	jal	ra,802000ae <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ee:	11843583          	ld	a1,280(s0)
}
    802003f2:	6402                	ld	s0,0(sp)
    802003f4:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003f6:	00001517          	auipc	a0,0x1
    802003fa:	b1a50513          	addi	a0,a0,-1254 # 80200f10 <etext+0x4ac>
}
    802003fe:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    80200400:	b17d                	j	802000ae <cprintf>

0000000080200402 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    80200402:	11853783          	ld	a5,280(a0)
    80200406:	472d                	li	a4,11
    80200408:	0786                	slli	a5,a5,0x1
    8020040a:	8385                	srli	a5,a5,0x1
    8020040c:	06f76763          	bltu	a4,a5,8020047a <interrupt_handler+0x78>
    80200410:	00001717          	auipc	a4,0x1
    80200414:	bc870713          	addi	a4,a4,-1080 # 80200fd8 <etext+0x574>
    80200418:	078a                	slli	a5,a5,0x2
    8020041a:	97ba                	add	a5,a5,a4
    8020041c:	439c                	lw	a5,0(a5)
    8020041e:	97ba                	add	a5,a5,a4
    80200420:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    80200422:	00001517          	auipc	a0,0x1
    80200426:	b6650513          	addi	a0,a0,-1178 # 80200f88 <etext+0x524>
    8020042a:	b151                	j	802000ae <cprintf>
            cprintf("Hypervisor software interrupt\n");
    8020042c:	00001517          	auipc	a0,0x1
    80200430:	b3c50513          	addi	a0,a0,-1220 # 80200f68 <etext+0x504>
    80200434:	b9ad                	j	802000ae <cprintf>
            cprintf("User software interrupt\n");
    80200436:	00001517          	auipc	a0,0x1
    8020043a:	af250513          	addi	a0,a0,-1294 # 80200f28 <etext+0x4c4>
    8020043e:	b985                	j	802000ae <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200440:	00001517          	auipc	a0,0x1
    80200444:	b0850513          	addi	a0,a0,-1272 # 80200f48 <etext+0x4e4>
    80200448:	b19d                	j	802000ae <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020044a:	1141                	addi	sp,sp,-16
    8020044c:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
    8020044e:	d57ff0ef          	jal	ra,802001a4 <clock_set_next_event>
            ticks++;
    80200452:	00004797          	auipc	a5,0x4
    80200456:	bbe78793          	addi	a5,a5,-1090 # 80204010 <ticks>
    8020045a:	6398                	ld	a4,0(a5)
            if(ticks==TICK_NUM){
    8020045c:	06400693          	li	a3,100
            ticks++;
    80200460:	0705                	addi	a4,a4,1
    80200462:	e398                	sd	a4,0(a5)
            if(ticks==TICK_NUM){
    80200464:	639c                	ld	a5,0(a5)
    80200466:	00d78b63          	beq	a5,a3,8020047c <interrupt_handler+0x7a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020046a:	60a2                	ld	ra,8(sp)
    8020046c:	0141                	addi	sp,sp,16
    8020046e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200470:	00001517          	auipc	a0,0x1
    80200474:	b4850513          	addi	a0,a0,-1208 # 80200fb8 <etext+0x554>
    80200478:	b91d                	j	802000ae <cprintf>
            print_trapframe(tf);
    8020047a:	b725                	j	802003a2 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020047c:	06400593          	li	a1,100
    80200480:	00001517          	auipc	a0,0x1
    80200484:	b2850513          	addi	a0,a0,-1240 # 80200fa8 <etext+0x544>
    80200488:	c27ff0ef          	jal	ra,802000ae <cprintf>
                ticks=0;
    8020048c:	00004797          	auipc	a5,0x4
    80200490:	b807b223          	sd	zero,-1148(a5) # 80204010 <ticks>
                num++;
    80200494:	00004797          	auipc	a5,0x4
    80200498:	b8478793          	addi	a5,a5,-1148 # 80204018 <num>
    8020049c:	6398                	ld	a4,0(a5)
                if(num==10)
    8020049e:	46a9                	li	a3,10
                num++;
    802004a0:	0705                	addi	a4,a4,1
    802004a2:	e398                	sd	a4,0(a5)
                if(num==10)
    802004a4:	639c                	ld	a5,0(a5)
    802004a6:	fcd792e3          	bne	a5,a3,8020046a <interrupt_handler+0x68>
}
    802004aa:	60a2                	ld	ra,8(sp)
    802004ac:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    802004ae:	a3bd                	j	80200a1c <sbi_shutdown>

00000000802004b0 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    802004b0:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    802004b4:	1141                	addi	sp,sp,-16
    802004b6:	e022                	sd	s0,0(sp)
    802004b8:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    802004ba:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    802004bc:	842a                	mv	s0,a0
    switch (tf->cause) {
    802004be:	04e78663          	beq	a5,a4,8020050a <exception_handler+0x5a>
    802004c2:	02f76c63          	bltu	a4,a5,802004fa <exception_handler+0x4a>
    802004c6:	4709                	li	a4,2
    802004c8:	02e79563          	bne	a5,a4,802004f2 <exception_handler+0x42>
             /* LAB1 CHALLENGE3   2213109 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception Type: Illegal instruction\n");
    802004cc:	00001517          	auipc	a0,0x1
    802004d0:	b3c50513          	addi	a0,a0,-1220 # 80201008 <etext+0x5a4>
    802004d4:	bdbff0ef          	jal	ra,802000ae <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    802004d8:	10843583          	ld	a1,264(s0)
    802004dc:	00001517          	auipc	a0,0x1
    802004e0:	b5450513          	addi	a0,a0,-1196 # 80201030 <etext+0x5cc>
    802004e4:	bcbff0ef          	jal	ra,802000ae <cprintf>
            tf->epc+=4;
    802004e8:	10843783          	ld	a5,264(s0)
    802004ec:	0791                	addi	a5,a5,4
    802004ee:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004f2:	60a2                	ld	ra,8(sp)
    802004f4:	6402                	ld	s0,0(sp)
    802004f6:	0141                	addi	sp,sp,16
    802004f8:	8082                	ret
    switch (tf->cause) {
    802004fa:	17f1                	addi	a5,a5,-4
    802004fc:	471d                	li	a4,7
    802004fe:	fef77ae3          	bgeu	a4,a5,802004f2 <exception_handler+0x42>
}
    80200502:	6402                	ld	s0,0(sp)
    80200504:	60a2                	ld	ra,8(sp)
    80200506:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    80200508:	bd69                	j	802003a2 <print_trapframe>
            cprintf("Exception Type: breakpoint\n");
    8020050a:	00001517          	auipc	a0,0x1
    8020050e:	b4e50513          	addi	a0,a0,-1202 # 80201058 <etext+0x5f4>
    80200512:	b9dff0ef          	jal	ra,802000ae <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    80200516:	10843583          	ld	a1,264(s0)
    8020051a:	00001517          	auipc	a0,0x1
    8020051e:	b5e50513          	addi	a0,a0,-1186 # 80201078 <etext+0x614>
    80200522:	b8dff0ef          	jal	ra,802000ae <cprintf>
            tf->epc+=2;
    80200526:	10843783          	ld	a5,264(s0)
}
    8020052a:	60a2                	ld	ra,8(sp)
            tf->epc+=2;
    8020052c:	0789                	addi	a5,a5,2
    8020052e:	10f43423          	sd	a5,264(s0)
}
    80200532:	6402                	ld	s0,0(sp)
    80200534:	0141                	addi	sp,sp,16
    80200536:	8082                	ret

0000000080200538 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200538:	11853783          	ld	a5,280(a0)
    8020053c:	0007c363          	bltz	a5,80200542 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200540:	bf85                	j	802004b0 <exception_handler>
        interrupt_handler(tf);
    80200542:	b5c1                	j	80200402 <interrupt_handler>

0000000080200544 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200544:	14011073          	csrw	sscratch,sp
    80200548:	712d                	addi	sp,sp,-288
    8020054a:	e002                	sd	zero,0(sp)
    8020054c:	e406                	sd	ra,8(sp)
    8020054e:	ec0e                	sd	gp,24(sp)
    80200550:	f012                	sd	tp,32(sp)
    80200552:	f416                	sd	t0,40(sp)
    80200554:	f81a                	sd	t1,48(sp)
    80200556:	fc1e                	sd	t2,56(sp)
    80200558:	e0a2                	sd	s0,64(sp)
    8020055a:	e4a6                	sd	s1,72(sp)
    8020055c:	e8aa                	sd	a0,80(sp)
    8020055e:	ecae                	sd	a1,88(sp)
    80200560:	f0b2                	sd	a2,96(sp)
    80200562:	f4b6                	sd	a3,104(sp)
    80200564:	f8ba                	sd	a4,112(sp)
    80200566:	fcbe                	sd	a5,120(sp)
    80200568:	e142                	sd	a6,128(sp)
    8020056a:	e546                	sd	a7,136(sp)
    8020056c:	e94a                	sd	s2,144(sp)
    8020056e:	ed4e                	sd	s3,152(sp)
    80200570:	f152                	sd	s4,160(sp)
    80200572:	f556                	sd	s5,168(sp)
    80200574:	f95a                	sd	s6,176(sp)
    80200576:	fd5e                	sd	s7,184(sp)
    80200578:	e1e2                	sd	s8,192(sp)
    8020057a:	e5e6                	sd	s9,200(sp)
    8020057c:	e9ea                	sd	s10,208(sp)
    8020057e:	edee                	sd	s11,216(sp)
    80200580:	f1f2                	sd	t3,224(sp)
    80200582:	f5f6                	sd	t4,232(sp)
    80200584:	f9fa                	sd	t5,240(sp)
    80200586:	fdfe                	sd	t6,248(sp)
    80200588:	14001473          	csrrw	s0,sscratch,zero
    8020058c:	100024f3          	csrr	s1,sstatus
    80200590:	14102973          	csrr	s2,sepc
    80200594:	143029f3          	csrr	s3,stval
    80200598:	14202a73          	csrr	s4,scause
    8020059c:	e822                	sd	s0,16(sp)
    8020059e:	e226                	sd	s1,256(sp)
    802005a0:	e64a                	sd	s2,264(sp)
    802005a2:	ea4e                	sd	s3,272(sp)
    802005a4:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802005a6:	850a                	mv	a0,sp
    jal trap
    802005a8:	f91ff0ef          	jal	ra,80200538 <trap>

00000000802005ac <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005ac:	6492                	ld	s1,256(sp)
    802005ae:	6932                	ld	s2,264(sp)
    802005b0:	10049073          	csrw	sstatus,s1
    802005b4:	14191073          	csrw	sepc,s2
    802005b8:	60a2                	ld	ra,8(sp)
    802005ba:	61e2                	ld	gp,24(sp)
    802005bc:	7202                	ld	tp,32(sp)
    802005be:	72a2                	ld	t0,40(sp)
    802005c0:	7342                	ld	t1,48(sp)
    802005c2:	73e2                	ld	t2,56(sp)
    802005c4:	6406                	ld	s0,64(sp)
    802005c6:	64a6                	ld	s1,72(sp)
    802005c8:	6546                	ld	a0,80(sp)
    802005ca:	65e6                	ld	a1,88(sp)
    802005cc:	7606                	ld	a2,96(sp)
    802005ce:	76a6                	ld	a3,104(sp)
    802005d0:	7746                	ld	a4,112(sp)
    802005d2:	77e6                	ld	a5,120(sp)
    802005d4:	680a                	ld	a6,128(sp)
    802005d6:	68aa                	ld	a7,136(sp)
    802005d8:	694a                	ld	s2,144(sp)
    802005da:	69ea                	ld	s3,152(sp)
    802005dc:	7a0a                	ld	s4,160(sp)
    802005de:	7aaa                	ld	s5,168(sp)
    802005e0:	7b4a                	ld	s6,176(sp)
    802005e2:	7bea                	ld	s7,184(sp)
    802005e4:	6c0e                	ld	s8,192(sp)
    802005e6:	6cae                	ld	s9,200(sp)
    802005e8:	6d4e                	ld	s10,208(sp)
    802005ea:	6dee                	ld	s11,216(sp)
    802005ec:	7e0e                	ld	t3,224(sp)
    802005ee:	7eae                	ld	t4,232(sp)
    802005f0:	7f4e                	ld	t5,240(sp)
    802005f2:	7fee                	ld	t6,248(sp)
    802005f4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005f6:	10200073          	sret

00000000802005fa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005fa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005fe:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200600:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200604:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200606:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020060a:	f022                	sd	s0,32(sp)
    8020060c:	ec26                	sd	s1,24(sp)
    8020060e:	e84a                	sd	s2,16(sp)
    80200610:	f406                	sd	ra,40(sp)
    80200612:	e44e                	sd	s3,8(sp)
    80200614:	84aa                	mv	s1,a0
    80200616:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200618:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020061c:	2a01                	sext.w	s4,s4
    if (num >= base) {
    8020061e:	03067e63          	bgeu	a2,a6,8020065a <printnum+0x60>
    80200622:	89be                	mv	s3,a5
        while (-- width > 0)
    80200624:	00805763          	blez	s0,80200632 <printnum+0x38>
    80200628:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020062a:	85ca                	mv	a1,s2
    8020062c:	854e                	mv	a0,s3
    8020062e:	9482                	jalr	s1
        while (-- width > 0)
    80200630:	fc65                	bnez	s0,80200628 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200632:	1a02                	slli	s4,s4,0x20
    80200634:	00001797          	auipc	a5,0x1
    80200638:	a6478793          	addi	a5,a5,-1436 # 80201098 <etext+0x634>
    8020063c:	020a5a13          	srli	s4,s4,0x20
    80200640:	9a3e                	add	s4,s4,a5
}
    80200642:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200644:	000a4503          	lbu	a0,0(s4)
}
    80200648:	70a2                	ld	ra,40(sp)
    8020064a:	69a2                	ld	s3,8(sp)
    8020064c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020064e:	85ca                	mv	a1,s2
    80200650:	87a6                	mv	a5,s1
}
    80200652:	6942                	ld	s2,16(sp)
    80200654:	64e2                	ld	s1,24(sp)
    80200656:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200658:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    8020065a:	03065633          	divu	a2,a2,a6
    8020065e:	8722                	mv	a4,s0
    80200660:	f9bff0ef          	jal	ra,802005fa <printnum>
    80200664:	b7f9                	j	80200632 <printnum+0x38>

0000000080200666 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200666:	7119                	addi	sp,sp,-128
    80200668:	f4a6                	sd	s1,104(sp)
    8020066a:	f0ca                	sd	s2,96(sp)
    8020066c:	ecce                	sd	s3,88(sp)
    8020066e:	e8d2                	sd	s4,80(sp)
    80200670:	e4d6                	sd	s5,72(sp)
    80200672:	e0da                	sd	s6,64(sp)
    80200674:	fc5e                	sd	s7,56(sp)
    80200676:	f06a                	sd	s10,32(sp)
    80200678:	fc86                	sd	ra,120(sp)
    8020067a:	f8a2                	sd	s0,112(sp)
    8020067c:	f862                	sd	s8,48(sp)
    8020067e:	f466                	sd	s9,40(sp)
    80200680:	ec6e                	sd	s11,24(sp)
    80200682:	892a                	mv	s2,a0
    80200684:	84ae                	mv	s1,a1
    80200686:	8d32                	mv	s10,a2
    80200688:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020068a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020068e:	5b7d                	li	s6,-1
    80200690:	00001a97          	auipc	s5,0x1
    80200694:	a3ca8a93          	addi	s5,s5,-1476 # 802010cc <etext+0x668>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200698:	00001b97          	auipc	s7,0x1
    8020069c:	c10b8b93          	addi	s7,s7,-1008 # 802012a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a0:	000d4503          	lbu	a0,0(s10)
    802006a4:	001d0413          	addi	s0,s10,1
    802006a8:	01350a63          	beq	a0,s3,802006bc <vprintfmt+0x56>
            if (ch == '\0') {
    802006ac:	c121                	beqz	a0,802006ec <vprintfmt+0x86>
            putch(ch, putdat);
    802006ae:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006b2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b4:	fff44503          	lbu	a0,-1(s0)
    802006b8:	ff351ae3          	bne	a0,s3,802006ac <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    802006bc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006c0:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006c4:	4c81                	li	s9,0
    802006c6:	4881                	li	a7,0
        width = precision = -1;
    802006c8:	5c7d                	li	s8,-1
    802006ca:	5dfd                	li	s11,-1
    802006cc:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    802006d0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006d2:	fdd6059b          	addiw	a1,a2,-35
    802006d6:	0ff5f593          	andi	a1,a1,255
    802006da:	00140d13          	addi	s10,s0,1
    802006de:	04b56263          	bltu	a0,a1,80200722 <vprintfmt+0xbc>
    802006e2:	058a                	slli	a1,a1,0x2
    802006e4:	95d6                	add	a1,a1,s5
    802006e6:	4194                	lw	a3,0(a1)
    802006e8:	96d6                	add	a3,a3,s5
    802006ea:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006ec:	70e6                	ld	ra,120(sp)
    802006ee:	7446                	ld	s0,112(sp)
    802006f0:	74a6                	ld	s1,104(sp)
    802006f2:	7906                	ld	s2,96(sp)
    802006f4:	69e6                	ld	s3,88(sp)
    802006f6:	6a46                	ld	s4,80(sp)
    802006f8:	6aa6                	ld	s5,72(sp)
    802006fa:	6b06                	ld	s6,64(sp)
    802006fc:	7be2                	ld	s7,56(sp)
    802006fe:	7c42                	ld	s8,48(sp)
    80200700:	7ca2                	ld	s9,40(sp)
    80200702:	7d02                	ld	s10,32(sp)
    80200704:	6de2                	ld	s11,24(sp)
    80200706:	6109                	addi	sp,sp,128
    80200708:	8082                	ret
            padc = '0';
    8020070a:	87b2                	mv	a5,a2
            goto reswitch;
    8020070c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200710:	846a                	mv	s0,s10
    80200712:	00140d13          	addi	s10,s0,1
    80200716:	fdd6059b          	addiw	a1,a2,-35
    8020071a:	0ff5f593          	andi	a1,a1,255
    8020071e:	fcb572e3          	bgeu	a0,a1,802006e2 <vprintfmt+0x7c>
            putch('%', putdat);
    80200722:	85a6                	mv	a1,s1
    80200724:	02500513          	li	a0,37
    80200728:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    8020072a:	fff44783          	lbu	a5,-1(s0)
    8020072e:	8d22                	mv	s10,s0
    80200730:	f73788e3          	beq	a5,s3,802006a0 <vprintfmt+0x3a>
    80200734:	ffed4783          	lbu	a5,-2(s10)
    80200738:	1d7d                	addi	s10,s10,-1
    8020073a:	ff379de3          	bne	a5,s3,80200734 <vprintfmt+0xce>
    8020073e:	b78d                	j	802006a0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    80200740:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    80200744:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200748:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    8020074a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    8020074e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200752:	02d86463          	bltu	a6,a3,8020077a <vprintfmt+0x114>
                ch = *fmt;
    80200756:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    8020075a:	002c169b          	slliw	a3,s8,0x2
    8020075e:	0186873b          	addw	a4,a3,s8
    80200762:	0017171b          	slliw	a4,a4,0x1
    80200766:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200768:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    8020076c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020076e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200772:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200776:	fed870e3          	bgeu	a6,a3,80200756 <vprintfmt+0xf0>
            if (width < 0)
    8020077a:	f40ddce3          	bgez	s11,802006d2 <vprintfmt+0x6c>
                width = precision, precision = -1;
    8020077e:	8de2                	mv	s11,s8
    80200780:	5c7d                	li	s8,-1
    80200782:	bf81                	j	802006d2 <vprintfmt+0x6c>
            if (width < 0)
    80200784:	fffdc693          	not	a3,s11
    80200788:	96fd                	srai	a3,a3,0x3f
    8020078a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    8020078e:	00144603          	lbu	a2,1(s0)
    80200792:	2d81                	sext.w	s11,s11
    80200794:	846a                	mv	s0,s10
            goto reswitch;
    80200796:	bf35                	j	802006d2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200798:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    8020079c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802007a0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    802007a2:	846a                	mv	s0,s10
            goto process_precision;
    802007a4:	bfd9                	j	8020077a <vprintfmt+0x114>
    if (lflag >= 2) {
    802007a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007ac:	01174463          	blt	a4,a7,802007b4 <vprintfmt+0x14e>
    else if (lflag) {
    802007b0:	1a088e63          	beqz	a7,8020096c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    802007b4:	000a3603          	ld	a2,0(s4)
    802007b8:	46c1                	li	a3,16
    802007ba:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    802007bc:	2781                	sext.w	a5,a5
    802007be:	876e                	mv	a4,s11
    802007c0:	85a6                	mv	a1,s1
    802007c2:	854a                	mv	a0,s2
    802007c4:	e37ff0ef          	jal	ra,802005fa <printnum>
            break;
    802007c8:	bde1                	j	802006a0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    802007ca:	000a2503          	lw	a0,0(s4)
    802007ce:	85a6                	mv	a1,s1
    802007d0:	0a21                	addi	s4,s4,8
    802007d2:	9902                	jalr	s2
            break;
    802007d4:	b5f1                	j	802006a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007d6:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007d8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007dc:	01174463          	blt	a4,a7,802007e4 <vprintfmt+0x17e>
    else if (lflag) {
    802007e0:	18088163          	beqz	a7,80200962 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    802007e4:	000a3603          	ld	a2,0(s4)
    802007e8:	46a9                	li	a3,10
    802007ea:	8a2e                	mv	s4,a1
    802007ec:	bfc1                	j	802007bc <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    802007ee:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802007f2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007f4:	846a                	mv	s0,s10
            goto reswitch;
    802007f6:	bdf1                	j	802006d2 <vprintfmt+0x6c>
            putch(ch, putdat);
    802007f8:	85a6                	mv	a1,s1
    802007fa:	02500513          	li	a0,37
    802007fe:	9902                	jalr	s2
            break;
    80200800:	b545                	j	802006a0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    80200802:	00144603          	lbu	a2,1(s0)
            lflag ++;
    80200806:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200808:	846a                	mv	s0,s10
            goto reswitch;
    8020080a:	b5e1                	j	802006d2 <vprintfmt+0x6c>
    if (lflag >= 2) {
    8020080c:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020080e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200812:	01174463          	blt	a4,a7,8020081a <vprintfmt+0x1b4>
    else if (lflag) {
    80200816:	14088163          	beqz	a7,80200958 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    8020081a:	000a3603          	ld	a2,0(s4)
    8020081e:	46a1                	li	a3,8
    80200820:	8a2e                	mv	s4,a1
    80200822:	bf69                	j	802007bc <vprintfmt+0x156>
            putch('0', putdat);
    80200824:	03000513          	li	a0,48
    80200828:	85a6                	mv	a1,s1
    8020082a:	e03e                	sd	a5,0(sp)
    8020082c:	9902                	jalr	s2
            putch('x', putdat);
    8020082e:	85a6                	mv	a1,s1
    80200830:	07800513          	li	a0,120
    80200834:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200836:	0a21                	addi	s4,s4,8
            goto number;
    80200838:	6782                	ld	a5,0(sp)
    8020083a:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    8020083c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    80200840:	bfb5                	j	802007bc <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200842:	000a3403          	ld	s0,0(s4)
    80200846:	008a0713          	addi	a4,s4,8
    8020084a:	e03a                	sd	a4,0(sp)
    8020084c:	14040263          	beqz	s0,80200990 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    80200850:	0fb05763          	blez	s11,8020093e <vprintfmt+0x2d8>
    80200854:	02d00693          	li	a3,45
    80200858:	0cd79163          	bne	a5,a3,8020091a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020085c:	00044783          	lbu	a5,0(s0)
    80200860:	0007851b          	sext.w	a0,a5
    80200864:	cf85                	beqz	a5,8020089c <vprintfmt+0x236>
    80200866:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020086a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020086e:	000c4563          	bltz	s8,80200878 <vprintfmt+0x212>
    80200872:	3c7d                	addiw	s8,s8,-1
    80200874:	036c0263          	beq	s8,s6,80200898 <vprintfmt+0x232>
                    putch('?', putdat);
    80200878:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020087a:	0e0c8e63          	beqz	s9,80200976 <vprintfmt+0x310>
    8020087e:	3781                	addiw	a5,a5,-32
    80200880:	0ef47b63          	bgeu	s0,a5,80200976 <vprintfmt+0x310>
                    putch('?', putdat);
    80200884:	03f00513          	li	a0,63
    80200888:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020088a:	000a4783          	lbu	a5,0(s4)
    8020088e:	3dfd                	addiw	s11,s11,-1
    80200890:	0a05                	addi	s4,s4,1
    80200892:	0007851b          	sext.w	a0,a5
    80200896:	ffe1                	bnez	a5,8020086e <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200898:	01b05963          	blez	s11,802008aa <vprintfmt+0x244>
    8020089c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020089e:	85a6                	mv	a1,s1
    802008a0:	02000513          	li	a0,32
    802008a4:	9902                	jalr	s2
            for (; width > 0; width --) {
    802008a6:	fe0d9be3          	bnez	s11,8020089c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    802008aa:	6a02                	ld	s4,0(sp)
    802008ac:	bbd5                	j	802006a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802008ae:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802008b0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    802008b4:	01174463          	blt	a4,a7,802008bc <vprintfmt+0x256>
    else if (lflag) {
    802008b8:	08088d63          	beqz	a7,80200952 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    802008bc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    802008c0:	0a044d63          	bltz	s0,8020097a <vprintfmt+0x314>
            num = getint(&ap, lflag);
    802008c4:	8622                	mv	a2,s0
    802008c6:	8a66                	mv	s4,s9
    802008c8:	46a9                	li	a3,10
    802008ca:	bdcd                	j	802007bc <vprintfmt+0x156>
            err = va_arg(ap, int);
    802008cc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008d0:	4719                	li	a4,6
            err = va_arg(ap, int);
    802008d2:	0a21                	addi	s4,s4,8
            if (err < 0) {
    802008d4:	41f7d69b          	sraiw	a3,a5,0x1f
    802008d8:	8fb5                	xor	a5,a5,a3
    802008da:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008de:	02d74163          	blt	a4,a3,80200900 <vprintfmt+0x29a>
    802008e2:	00369793          	slli	a5,a3,0x3
    802008e6:	97de                	add	a5,a5,s7
    802008e8:	639c                	ld	a5,0(a5)
    802008ea:	cb99                	beqz	a5,80200900 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    802008ec:	86be                	mv	a3,a5
    802008ee:	00000617          	auipc	a2,0x0
    802008f2:	7da60613          	addi	a2,a2,2010 # 802010c8 <etext+0x664>
    802008f6:	85a6                	mv	a1,s1
    802008f8:	854a                	mv	a0,s2
    802008fa:	0ce000ef          	jal	ra,802009c8 <printfmt>
    802008fe:	b34d                	j	802006a0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200900:	00000617          	auipc	a2,0x0
    80200904:	7b860613          	addi	a2,a2,1976 # 802010b8 <etext+0x654>
    80200908:	85a6                	mv	a1,s1
    8020090a:	854a                	mv	a0,s2
    8020090c:	0bc000ef          	jal	ra,802009c8 <printfmt>
    80200910:	bb41                	j	802006a0 <vprintfmt+0x3a>
                p = "(null)";
    80200912:	00000417          	auipc	s0,0x0
    80200916:	79e40413          	addi	s0,s0,1950 # 802010b0 <etext+0x64c>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020091a:	85e2                	mv	a1,s8
    8020091c:	8522                	mv	a0,s0
    8020091e:	e43e                	sd	a5,8(sp)
    80200920:	116000ef          	jal	ra,80200a36 <strnlen>
    80200924:	40ad8dbb          	subw	s11,s11,a0
    80200928:	01b05b63          	blez	s11,8020093e <vprintfmt+0x2d8>
                    putch(padc, putdat);
    8020092c:	67a2                	ld	a5,8(sp)
    8020092e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200932:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200934:	85a6                	mv	a1,s1
    80200936:	8552                	mv	a0,s4
    80200938:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020093a:	fe0d9ce3          	bnez	s11,80200932 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020093e:	00044783          	lbu	a5,0(s0)
    80200942:	00140a13          	addi	s4,s0,1
    80200946:	0007851b          	sext.w	a0,a5
    8020094a:	d3a5                	beqz	a5,802008aa <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    8020094c:	05e00413          	li	s0,94
    80200950:	bf39                	j	8020086e <vprintfmt+0x208>
        return va_arg(*ap, int);
    80200952:	000a2403          	lw	s0,0(s4)
    80200956:	b7ad                	j	802008c0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200958:	000a6603          	lwu	a2,0(s4)
    8020095c:	46a1                	li	a3,8
    8020095e:	8a2e                	mv	s4,a1
    80200960:	bdb1                	j	802007bc <vprintfmt+0x156>
    80200962:	000a6603          	lwu	a2,0(s4)
    80200966:	46a9                	li	a3,10
    80200968:	8a2e                	mv	s4,a1
    8020096a:	bd89                	j	802007bc <vprintfmt+0x156>
    8020096c:	000a6603          	lwu	a2,0(s4)
    80200970:	46c1                	li	a3,16
    80200972:	8a2e                	mv	s4,a1
    80200974:	b5a1                	j	802007bc <vprintfmt+0x156>
                    putch(ch, putdat);
    80200976:	9902                	jalr	s2
    80200978:	bf09                	j	8020088a <vprintfmt+0x224>
                putch('-', putdat);
    8020097a:	85a6                	mv	a1,s1
    8020097c:	02d00513          	li	a0,45
    80200980:	e03e                	sd	a5,0(sp)
    80200982:	9902                	jalr	s2
                num = -(long long)num;
    80200984:	6782                	ld	a5,0(sp)
    80200986:	8a66                	mv	s4,s9
    80200988:	40800633          	neg	a2,s0
    8020098c:	46a9                	li	a3,10
    8020098e:	b53d                	j	802007bc <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200990:	03b05163          	blez	s11,802009b2 <vprintfmt+0x34c>
    80200994:	02d00693          	li	a3,45
    80200998:	f6d79de3          	bne	a5,a3,80200912 <vprintfmt+0x2ac>
                p = "(null)";
    8020099c:	00000417          	auipc	s0,0x0
    802009a0:	71440413          	addi	s0,s0,1812 # 802010b0 <etext+0x64c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009a4:	02800793          	li	a5,40
    802009a8:	02800513          	li	a0,40
    802009ac:	00140a13          	addi	s4,s0,1
    802009b0:	bd6d                	j	8020086a <vprintfmt+0x204>
    802009b2:	00000a17          	auipc	s4,0x0
    802009b6:	6ffa0a13          	addi	s4,s4,1791 # 802010b1 <etext+0x64d>
    802009ba:	02800513          	li	a0,40
    802009be:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    802009c2:	05e00413          	li	s0,94
    802009c6:	b565                	j	8020086e <vprintfmt+0x208>

00000000802009c8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009c8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009ca:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009ce:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009d0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009d2:	ec06                	sd	ra,24(sp)
    802009d4:	f83a                	sd	a4,48(sp)
    802009d6:	fc3e                	sd	a5,56(sp)
    802009d8:	e0c2                	sd	a6,64(sp)
    802009da:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009dc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009de:	c89ff0ef          	jal	ra,80200666 <vprintfmt>
}
    802009e2:	60e2                	ld	ra,24(sp)
    802009e4:	6161                	addi	sp,sp,80
    802009e6:	8082                	ret

00000000802009e8 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    802009e8:	4781                	li	a5,0
    802009ea:	00003717          	auipc	a4,0x3
    802009ee:	61673703          	ld	a4,1558(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009f2:	88ba                	mv	a7,a4
    802009f4:	852a                	mv	a0,a0
    802009f6:	85be                	mv	a1,a5
    802009f8:	863e                	mv	a2,a5
    802009fa:	00000073          	ecall
    802009fe:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200a00:	8082                	ret

0000000080200a02 <sbi_set_timer>:
    __asm__ volatile (
    80200a02:	4781                	li	a5,0
    80200a04:	00003717          	auipc	a4,0x3
    80200a08:	61c73703          	ld	a4,1564(a4) # 80204020 <SBI_SET_TIMER>
    80200a0c:	88ba                	mv	a7,a4
    80200a0e:	852a                	mv	a0,a0
    80200a10:	85be                	mv	a1,a5
    80200a12:	863e                	mv	a2,a5
    80200a14:	00000073          	ecall
    80200a18:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    80200a1a:	8082                	ret

0000000080200a1c <sbi_shutdown>:
    __asm__ volatile (
    80200a1c:	4781                	li	a5,0
    80200a1e:	00003717          	auipc	a4,0x3
    80200a22:	5ea73703          	ld	a4,1514(a4) # 80204008 <SBI_SHUTDOWN>
    80200a26:	88ba                	mv	a7,a4
    80200a28:	853e                	mv	a0,a5
    80200a2a:	85be                	mv	a1,a5
    80200a2c:	863e                	mv	a2,a5
    80200a2e:	00000073          	ecall
    80200a32:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a34:	8082                	ret

0000000080200a36 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200a36:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200a38:	e589                	bnez	a1,80200a42 <strnlen+0xc>
    80200a3a:	a811                	j	80200a4e <strnlen+0x18>
        cnt ++;
    80200a3c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a3e:	00f58863          	beq	a1,a5,80200a4e <strnlen+0x18>
    80200a42:	00f50733          	add	a4,a0,a5
    80200a46:	00074703          	lbu	a4,0(a4)
    80200a4a:	fb6d                	bnez	a4,80200a3c <strnlen+0x6>
    80200a4c:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200a4e:	852e                	mv	a0,a1
    80200a50:	8082                	ret

0000000080200a52 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a52:	ca01                	beqz	a2,80200a62 <memset+0x10>
    80200a54:	962a                	add	a2,a2,a0
    char *p = s;
    80200a56:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a58:	0785                	addi	a5,a5,1
    80200a5a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a5e:	fec79de3          	bne	a5,a2,80200a58 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a62:	8082                	ret
