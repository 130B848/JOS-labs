
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6d 01 00 00       	call   f01001ab <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d a0 8e 23 f0 00 	cmpl   $0x0,0xf0238ea0
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 a0 8e 23 f0    	mov    %esi,0xf0238ea0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 06 60 00 00       	call   f0106067 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 40 67 10 f0       	push   $0xf0106740
f010006d:	e8 22 3e 00 00       	call   f0103e94 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 f2 3d 00 00       	call   f0103e6e <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 36 6b 10 f0 	movl   $0xf0106b36,(%esp)
f0100083:	e8 0c 3e 00 00       	call   f0103e94 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 ac 0b 00 00       	call   f0100c41 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <spinlock_test>:
static void boot_aps(void);

static volatile int test_ctr = 0;

void spinlock_test()
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	56                   	push   %esi
f010009e:	53                   	push   %ebx
f010009f:	83 ec 10             	sub    $0x10,%esp
	int i;
	volatile int interval = 0;
f01000a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
f01000a9:	e8 b9 5f 00 00       	call   f0106067 <cpunum>
f01000ae:	85 c0                	test   %eax,%eax
f01000b0:	75 10                	jne    f01000c2 <spinlock_test+0x28>
		while (interval++ < 10000)
f01000b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01000b5:	8d 50 01             	lea    0x1(%eax),%edx
f01000b8:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01000bb:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01000c0:	7e 0c                	jle    f01000ce <spinlock_test+0x34>
static void boot_aps(void);

static volatile int test_ctr = 0;

void spinlock_test()
{
f01000c2:	bb 64 00 00 00       	mov    $0x64,%ebx
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f01000c7:	be ad 8b db 68       	mov    $0x68db8bad,%esi
f01000cc:	eb 14                	jmp    f01000e2 <spinlock_test+0x48>
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
f01000ce:	f3 90                	pause  
	int i;
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000)
f01000d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01000d3:	8d 50 01             	lea    0x1(%eax),%edx
f01000d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01000d9:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f01000de:	7e ee                	jle    f01000ce <spinlock_test+0x34>
f01000e0:	eb e0                	jmp    f01000c2 <spinlock_test+0x28>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e2:	83 ec 0c             	sub    $0xc,%esp
f01000e5:	68 a0 13 12 f0       	push   $0xf01213a0
f01000ea:	e8 e6 61 00 00       	call   f01062d5 <spin_lock>
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f01000ef:	8b 0d 00 80 23 f0    	mov    0xf0238000,%ecx
f01000f5:	89 c8                	mov    %ecx,%eax
f01000f7:	f7 ee                	imul   %esi
f01000f9:	c1 fa 0c             	sar    $0xc,%edx
f01000fc:	89 c8                	mov    %ecx,%eax
f01000fe:	c1 f8 1f             	sar    $0x1f,%eax
f0100101:	29 c2                	sub    %eax,%edx
f0100103:	69 d2 10 27 00 00    	imul   $0x2710,%edx,%edx
f0100109:	83 c4 10             	add    $0x10,%esp
f010010c:	39 d1                	cmp    %edx,%ecx
f010010e:	74 14                	je     f0100124 <spinlock_test+0x8a>
			panic("ticket spinlock test fail: I saw a middle value\n");
f0100110:	83 ec 04             	sub    $0x4,%esp
f0100113:	68 64 67 10 f0       	push   $0xf0106764
f0100118:	6a 24                	push   $0x24
f010011a:	68 08 68 10 f0       	push   $0xf0106808
f010011f:	e8 1c ff ff ff       	call   f0100040 <_panic>
		interval = 0;
f0100124:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		while (interval++ < 10000)
f010012b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010012e:	8d 50 01             	lea    0x1(%eax),%edx
f0100131:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100134:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f0100139:	7f 1d                	jg     f0100158 <spinlock_test+0xbe>
			test_ctr++;
f010013b:	a1 00 80 23 f0       	mov    0xf0238000,%eax
f0100140:	83 c0 01             	add    $0x1,%eax
f0100143:	a3 00 80 23 f0       	mov    %eax,0xf0238000
	for (i=0; i<100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
			panic("ticket spinlock test fail: I saw a middle value\n");
		interval = 0;
		while (interval++ < 10000)
f0100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010014b:	8d 50 01             	lea    0x1(%eax),%edx
f010014e:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0100151:	3d 0f 27 00 00       	cmp    $0x270f,%eax
f0100156:	7e e3                	jle    f010013b <spinlock_test+0xa1>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0100158:	83 ec 0c             	sub    $0xc,%esp
f010015b:	68 a0 13 12 f0       	push   $0xf01213a0
f0100160:	e8 3b 62 00 00       	call   f01063a0 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0100165:	f3 90                	pause  
	if (cpunum() == 0) {
		while (interval++ < 10000)
			asm volatile("pause");
	}

	for (i=0; i<100; i++) {
f0100167:	83 c4 10             	add    $0x10,%esp
f010016a:	83 eb 01             	sub    $0x1,%ebx
f010016d:	0f 85 6f ff ff ff    	jne    f01000e2 <spinlock_test+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100173:	83 ec 0c             	sub    $0xc,%esp
f0100176:	68 a0 13 12 f0       	push   $0xf01213a0
f010017b:	e8 55 61 00 00       	call   f01062d5 <spin_lock>
		while (interval++ < 10000)
			test_ctr++;
		unlock_kernel();
	}
	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f0100180:	e8 e2 5e 00 00       	call   f0106067 <cpunum>
f0100185:	83 c4 08             	add    $0x8,%esp
f0100188:	50                   	push   %eax
f0100189:	68 98 67 10 f0       	push   $0xf0106798
f010018e:	e8 01 3d 00 00       	call   f0103e94 <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0100193:	c7 04 24 a0 13 12 f0 	movl   $0xf01213a0,(%esp)
f010019a:	e8 01 62 00 00       	call   f01063a0 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010019f:	f3 90                	pause  
	unlock_kernel();
}
f01001a1:	83 c4 10             	add    $0x10,%esp
f01001a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001a7:	5b                   	pop    %ebx
f01001a8:	5e                   	pop    %esi
f01001a9:	5d                   	pop    %ebp
f01001aa:	c3                   	ret    

f01001ab <i386_init>:

void
i386_init(void)
{
f01001ab:	55                   	push   %ebp
f01001ac:	89 e5                	mov    %esp,%ebp
f01001ae:	53                   	push   %ebx
f01001af:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01001b2:	b8 04 a0 27 f0       	mov    $0xf027a004,%eax
f01001b7:	2d f0 7d 23 f0       	sub    $0xf0237df0,%eax
f01001bc:	50                   	push   %eax
f01001bd:	6a 00                	push   $0x0
f01001bf:	68 f0 7d 23 f0       	push   $0xf0237df0
f01001c4:	e8 23 58 00 00       	call   f01059ec <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001c9:	e8 e6 05 00 00       	call   f01007b4 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01001ce:	83 c4 08             	add    $0x8,%esp
f01001d1:	68 ac 1a 00 00       	push   $0x1aac
f01001d6:	68 14 68 10 f0       	push   $0xf0106814
f01001db:	e8 b4 3c 00 00       	call   f0103e94 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001e0:	e8 7d 18 00 00       	call   f0101a62 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001e5:	e8 85 34 00 00       	call   f010366f <env_init>
	trap_init();
f01001ea:	e8 bf 3d 00 00       	call   f0103fae <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001ef:	e8 5a 5b 00 00       	call   f0105d4e <mp_init>
	lapic_init();
f01001f4:	e8 89 5e 00 00       	call   f0106082 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001f9:	e8 ba 3b 00 00       	call   f0103db8 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01001fe:	c7 04 24 a0 13 12 f0 	movl   $0xf01213a0,(%esp)
f0100205:	e8 cb 60 00 00       	call   f01062d5 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010020a:	83 c4 10             	add    $0x10,%esp
f010020d:	83 3d a8 8e 23 f0 07 	cmpl   $0x7,0xf0238ea8
f0100214:	77 16                	ja     f010022c <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100216:	68 00 70 00 00       	push   $0x7000
f010021b:	68 c0 67 10 f0       	push   $0xf01067c0
f0100220:	6a 79                	push   $0x79
f0100222:	68 08 68 10 f0       	push   $0xf0106808
f0100227:	e8 14 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010022c:	83 ec 04             	sub    $0x4,%esp
f010022f:	b8 a6 5c 10 f0       	mov    $0xf0105ca6,%eax
f0100234:	2d 2c 5c 10 f0       	sub    $0xf0105c2c,%eax
f0100239:	50                   	push   %eax
f010023a:	68 2c 5c 10 f0       	push   $0xf0105c2c
f010023f:	68 00 70 00 f0       	push   $0xf0007000
f0100244:	e8 f0 57 00 00       	call   f0105a39 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100249:	6b 05 c4 93 23 f0 74 	imul   $0x74,0xf02393c4,%eax
f0100250:	05 20 90 23 f0       	add    $0xf0239020,%eax
f0100255:	83 c4 10             	add    $0x10,%esp
f0100258:	3d 20 90 23 f0       	cmp    $0xf0239020,%eax
f010025d:	76 62                	jbe    f01002c1 <i386_init+0x116>
f010025f:	bb 20 90 23 f0       	mov    $0xf0239020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100264:	e8 fe 5d 00 00       	call   f0106067 <cpunum>
f0100269:	6b c0 74             	imul   $0x74,%eax,%eax
f010026c:	05 20 90 23 f0       	add    $0xf0239020,%eax
f0100271:	39 c3                	cmp    %eax,%ebx
f0100273:	74 39                	je     f01002ae <i386_init+0x103>
			continue;

		// Tell mpentry.S what stack to use
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100275:	89 d8                	mov    %ebx,%eax
f0100277:	2d 20 90 23 f0       	sub    $0xf0239020,%eax
f010027c:	c1 f8 02             	sar    $0x2,%eax
f010027f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100285:	c1 e0 0f             	shl    $0xf,%eax
f0100288:	05 00 20 24 f0       	add    $0xf0242000,%eax
f010028d:	a3 a4 8e 23 f0       	mov    %eax,0xf0238ea4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100292:	83 ec 08             	sub    $0x8,%esp
f0100295:	68 00 70 00 00       	push   $0x7000
f010029a:	0f b6 03             	movzbl (%ebx),%eax
f010029d:	50                   	push   %eax
f010029e:	e8 17 5f 00 00       	call   f01061ba <lapic_startap>
f01002a3:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01002a6:	8b 43 04             	mov    0x4(%ebx),%eax
f01002a9:	83 f8 01             	cmp    $0x1,%eax
f01002ac:	75 f8                	jne    f01002a6 <i386_init+0xfb>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01002ae:	83 c3 74             	add    $0x74,%ebx
f01002b1:	6b 05 c4 93 23 f0 74 	imul   $0x74,0xf02393c4,%eax
f01002b8:	05 20 90 23 f0       	add    $0xf0239020,%eax
f01002bd:	39 c3                	cmp    %eax,%ebx
f01002bf:	72 a3                	jb     f0100264 <i386_init+0xb9>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01002c1:	83 ec 0c             	sub    $0xc,%esp
f01002c4:	68 a0 13 12 f0       	push   $0xf01213a0
f01002c9:	e8 d2 60 00 00       	call   f01063a0 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01002ce:	f3 90                	pause  
	// Starting non-boot CPUs
	boot_aps();

#ifdef USE_TICKET_SPIN_LOCK
	unlock_kernel();
	spinlock_test();
f01002d0:	e8 c5 fd ff ff       	call   f010009a <spinlock_test>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01002d5:	c7 04 24 a0 13 12 f0 	movl   $0xf01213a0,(%esp)
f01002dc:	e8 f4 5f 00 00       	call   f01062d5 <spin_lock>
f01002e1:	83 c4 10             	add    $0x10,%esp
f01002e4:	bb 08 00 00 00       	mov    $0x8,%ebx
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f01002e9:	83 ec 04             	sub    $0x4,%esp
f01002ec:	6a 01                	push   $0x1
f01002ee:	68 14 8b 00 00       	push   $0x8b14
f01002f3:	68 58 3b 1a f0       	push   $0xf01a3b58
f01002f8:	e8 60 35 00 00       	call   f010385d <env_create>
	lock_kernel();
#endif

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01002fd:	83 c4 10             	add    $0x10,%esp
f0100300:	83 eb 01             	sub    $0x1,%ebx
f0100303:	75 e4                	jne    f01002e9 <i386_init+0x13e>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f0100305:	83 ec 04             	sub    $0x4,%esp
f0100308:	6a 00                	push   $0x0
f010030a:	68 cc 8b 00 00       	push   $0x8bcc
f010030f:	68 24 f2 22 f0       	push   $0xf022f224
f0100314:	e8 44 35 00 00       	call   f010385d <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100319:	e8 dc 44 00 00       	call   f01047fa <sched_yield>

f010031e <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010031e:	55                   	push   %ebp
f010031f:	89 e5                	mov    %esp,%ebp
f0100321:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir
	lcr3(PADDR(kern_pgdir));
f0100324:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100329:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010032e:	77 15                	ja     f0100345 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100330:	50                   	push   %eax
f0100331:	68 e4 67 10 f0       	push   $0xf01067e4
f0100336:	68 90 00 00 00       	push   $0x90
f010033b:	68 08 68 10 f0       	push   $0xf0106808
f0100340:	e8 fb fc ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100345:	05 00 00 00 10       	add    $0x10000000,%eax
f010034a:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010034d:	e8 15 5d 00 00       	call   f0106067 <cpunum>
f0100352:	83 ec 08             	sub    $0x8,%esp
f0100355:	50                   	push   %eax
f0100356:	68 2f 68 10 f0       	push   $0xf010682f
f010035b:	e8 34 3b 00 00       	call   f0103e94 <cprintf>

	lapic_init();
f0100360:	e8 1d 5d 00 00       	call   f0106082 <lapic_init>
	env_init_percpu();
f0100365:	e8 d5 32 00 00       	call   f010363f <env_init_percpu>
	trap_init_percpu();
f010036a:	e8 39 3b 00 00       	call   f0103ea8 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010036f:	e8 f3 5c 00 00       	call   f0106067 <cpunum>
f0100374:	6b d0 74             	imul   $0x74,%eax,%edx
f0100377:	81 c2 20 90 23 f0    	add    $0xf0239020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010037d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100382:	f0 87 42 04          	lock xchg %eax,0x4(%edx)

#ifdef USE_TICKET_SPIN_LOCK
	spinlock_test();
f0100386:	e8 0f fd ff ff       	call   f010009a <spinlock_test>
f010038b:	c7 04 24 a0 13 12 f0 	movl   $0xf01213a0,(%esp)
f0100392:	e8 3e 5f 00 00       	call   f01062d5 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100397:	e8 5e 44 00 00       	call   f01047fa <sched_yield>

f010039c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010039c:	55                   	push   %ebp
f010039d:	89 e5                	mov    %esp,%ebp
f010039f:	53                   	push   %ebx
f01003a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01003a3:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01003a6:	ff 75 0c             	pushl  0xc(%ebp)
f01003a9:	ff 75 08             	pushl  0x8(%ebp)
f01003ac:	68 45 68 10 f0       	push   $0xf0106845
f01003b1:	e8 de 3a 00 00       	call   f0103e94 <cprintf>
	vcprintf(fmt, ap);
f01003b6:	83 c4 08             	add    $0x8,%esp
f01003b9:	53                   	push   %ebx
f01003ba:	ff 75 10             	pushl  0x10(%ebp)
f01003bd:	e8 ac 3a 00 00       	call   f0103e6e <vcprintf>
	cprintf("\n");
f01003c2:	c7 04 24 36 6b 10 f0 	movl   $0xf0106b36,(%esp)
f01003c9:	e8 c6 3a 00 00       	call   f0103e94 <cprintf>
	va_end(ap);
}
f01003ce:	83 c4 10             	add    $0x10,%esp
f01003d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003d4:	c9                   	leave  
f01003d5:	c3                   	ret    

f01003d6 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01003d6:	55                   	push   %ebp
f01003d7:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d9:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003de:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01003df:	a8 01                	test   $0x1,%al
f01003e1:	74 0b                	je     f01003ee <serial_proc_data+0x18>
f01003e3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003e8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01003e9:	0f b6 c0             	movzbl %al,%eax
f01003ec:	eb 05                	jmp    f01003f3 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01003ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01003f3:	5d                   	pop    %ebp
f01003f4:	c3                   	ret    

f01003f5 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01003f5:	55                   	push   %ebp
f01003f6:	89 e5                	mov    %esp,%ebp
f01003f8:	53                   	push   %ebx
f01003f9:	83 ec 04             	sub    $0x4,%esp
f01003fc:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01003fe:	eb 2b                	jmp    f010042b <cons_intr+0x36>
		if (c == 0)
f0100400:	85 c0                	test   %eax,%eax
f0100402:	74 27                	je     f010042b <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100404:	8b 0d 44 82 23 f0    	mov    0xf0238244,%ecx
f010040a:	8d 51 01             	lea    0x1(%ecx),%edx
f010040d:	89 15 44 82 23 f0    	mov    %edx,0xf0238244
f0100413:	88 81 40 80 23 f0    	mov    %al,-0xfdc7fc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100419:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010041f:	75 0a                	jne    f010042b <cons_intr+0x36>
			cons.wpos = 0;
f0100421:	c7 05 44 82 23 f0 00 	movl   $0x0,0xf0238244
f0100428:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010042b:	ff d3                	call   *%ebx
f010042d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100430:	75 ce                	jne    f0100400 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100432:	83 c4 04             	add    $0x4,%esp
f0100435:	5b                   	pop    %ebx
f0100436:	5d                   	pop    %ebp
f0100437:	c3                   	ret    

f0100438 <kbd_proc_data>:
f0100438:	ba 64 00 00 00       	mov    $0x64,%edx
f010043d:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010043e:	a8 01                	test   $0x1,%al
f0100440:	0f 84 f0 00 00 00    	je     f0100536 <kbd_proc_data+0xfe>
f0100446:	ba 60 00 00 00       	mov    $0x60,%edx
f010044b:	ec                   	in     (%dx),%al
f010044c:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010044e:	3c e0                	cmp    $0xe0,%al
f0100450:	75 0d                	jne    f010045f <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f0100452:	83 0d 20 80 23 f0 40 	orl    $0x40,0xf0238020
		return 0;
f0100459:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010045e:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010045f:	55                   	push   %ebp
f0100460:	89 e5                	mov    %esp,%ebp
f0100462:	53                   	push   %ebx
f0100463:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100466:	84 c0                	test   %al,%al
f0100468:	79 36                	jns    f01004a0 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010046a:	8b 0d 20 80 23 f0    	mov    0xf0238020,%ecx
f0100470:	89 cb                	mov    %ecx,%ebx
f0100472:	83 e3 40             	and    $0x40,%ebx
f0100475:	83 e0 7f             	and    $0x7f,%eax
f0100478:	85 db                	test   %ebx,%ebx
f010047a:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010047d:	0f b6 d2             	movzbl %dl,%edx
f0100480:	0f b6 82 c0 69 10 f0 	movzbl -0xfef9640(%edx),%eax
f0100487:	83 c8 40             	or     $0x40,%eax
f010048a:	0f b6 c0             	movzbl %al,%eax
f010048d:	f7 d0                	not    %eax
f010048f:	21 c8                	and    %ecx,%eax
f0100491:	a3 20 80 23 f0       	mov    %eax,0xf0238020
		return 0;
f0100496:	b8 00 00 00 00       	mov    $0x0,%eax
f010049b:	e9 9e 00 00 00       	jmp    f010053e <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01004a0:	8b 0d 20 80 23 f0    	mov    0xf0238020,%ecx
f01004a6:	f6 c1 40             	test   $0x40,%cl
f01004a9:	74 0e                	je     f01004b9 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01004ab:	83 c8 80             	or     $0xffffff80,%eax
f01004ae:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01004b0:	83 e1 bf             	and    $0xffffffbf,%ecx
f01004b3:	89 0d 20 80 23 f0    	mov    %ecx,0xf0238020
	}

	shift |= shiftcode[data];
f01004b9:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01004bc:	0f b6 82 c0 69 10 f0 	movzbl -0xfef9640(%edx),%eax
f01004c3:	0b 05 20 80 23 f0    	or     0xf0238020,%eax
f01004c9:	0f b6 8a c0 68 10 f0 	movzbl -0xfef9740(%edx),%ecx
f01004d0:	31 c8                	xor    %ecx,%eax
f01004d2:	a3 20 80 23 f0       	mov    %eax,0xf0238020

	c = charcode[shift & (CTL | SHIFT)][data];
f01004d7:	89 c1                	mov    %eax,%ecx
f01004d9:	83 e1 03             	and    $0x3,%ecx
f01004dc:	8b 0c 8d a0 68 10 f0 	mov    -0xfef9760(,%ecx,4),%ecx
f01004e3:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01004e7:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01004ea:	a8 08                	test   $0x8,%al
f01004ec:	74 1b                	je     f0100509 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01004ee:	89 da                	mov    %ebx,%edx
f01004f0:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01004f3:	83 f9 19             	cmp    $0x19,%ecx
f01004f6:	77 05                	ja     f01004fd <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01004f8:	83 eb 20             	sub    $0x20,%ebx
f01004fb:	eb 0c                	jmp    f0100509 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01004fd:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100500:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100503:	83 fa 19             	cmp    $0x19,%edx
f0100506:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100509:	f7 d0                	not    %eax
f010050b:	a8 06                	test   $0x6,%al
f010050d:	75 2d                	jne    f010053c <kbd_proc_data+0x104>
f010050f:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100515:	75 25                	jne    f010053c <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100517:	83 ec 0c             	sub    $0xc,%esp
f010051a:	68 5f 68 10 f0       	push   $0xf010685f
f010051f:	e8 70 39 00 00       	call   f0103e94 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100524:	ba 92 00 00 00       	mov    $0x92,%edx
f0100529:	b8 03 00 00 00       	mov    $0x3,%eax
f010052e:	ee                   	out    %al,(%dx)
f010052f:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100532:	89 d8                	mov    %ebx,%eax
f0100534:	eb 08                	jmp    f010053e <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100536:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010053b:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010053c:	89 d8                	mov    %ebx,%eax
}
f010053e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100541:	c9                   	leave  
f0100542:	c3                   	ret    

f0100543 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100543:	55                   	push   %ebp
f0100544:	89 e5                	mov    %esp,%ebp
f0100546:	57                   	push   %edi
f0100547:	56                   	push   %esi
f0100548:	53                   	push   %ebx
f0100549:	83 ec 1c             	sub    $0x1c,%esp
f010054c:	89 c7                	mov    %eax,%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010054e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100553:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100554:	a8 20                	test   $0x20,%al
f0100556:	75 27                	jne    f010057f <cons_putc+0x3c>
f0100558:	bb 00 00 00 00       	mov    $0x0,%ebx
f010055d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100562:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100567:	89 ca                	mov    %ecx,%edx
f0100569:	ec                   	in     (%dx),%al
f010056a:	ec                   	in     (%dx),%al
f010056b:	ec                   	in     (%dx),%al
f010056c:	ec                   	in     (%dx),%al
	     i++)
f010056d:	83 c3 01             	add    $0x1,%ebx
f0100570:	89 f2                	mov    %esi,%edx
f0100572:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100573:	a8 20                	test   $0x20,%al
f0100575:	75 08                	jne    f010057f <cons_putc+0x3c>
f0100577:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010057d:	7e e8                	jle    f0100567 <cons_putc+0x24>
f010057f:	89 f8                	mov    %edi,%eax
f0100581:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100584:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100589:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058a:	ba 79 03 00 00       	mov    $0x379,%edx
f010058f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100590:	84 c0                	test   %al,%al
f0100592:	78 27                	js     f01005bb <cons_putc+0x78>
f0100594:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100599:	b9 84 00 00 00       	mov    $0x84,%ecx
f010059e:	be 79 03 00 00       	mov    $0x379,%esi
f01005a3:	89 ca                	mov    %ecx,%edx
f01005a5:	ec                   	in     (%dx),%al
f01005a6:	ec                   	in     (%dx),%al
f01005a7:	ec                   	in     (%dx),%al
f01005a8:	ec                   	in     (%dx),%al
f01005a9:	83 c3 01             	add    $0x1,%ebx
f01005ac:	89 f2                	mov    %esi,%edx
f01005ae:	ec                   	in     (%dx),%al
f01005af:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01005b5:	7f 04                	jg     f01005bb <cons_putc+0x78>
f01005b7:	84 c0                	test   %al,%al
f01005b9:	79 e8                	jns    f01005a3 <cons_putc+0x60>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005bb:	ba 78 03 00 00       	mov    $0x378,%edx
f01005c0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01005c4:	ee                   	out    %al,(%dx)
f01005c5:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01005ca:	b8 0d 00 00 00       	mov    $0xd,%eax
f01005cf:	ee                   	out    %al,(%dx)
f01005d0:	b8 08 00 00 00       	mov    $0x8,%eax
f01005d5:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01005d6:	89 fa                	mov    %edi,%edx
f01005d8:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01005de:	89 f8                	mov    %edi,%eax
f01005e0:	80 cc 07             	or     $0x7,%ah
f01005e3:	85 d2                	test   %edx,%edx
f01005e5:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01005e8:	89 f8                	mov    %edi,%eax
f01005ea:	0f b6 c0             	movzbl %al,%eax
f01005ed:	83 f8 09             	cmp    $0x9,%eax
f01005f0:	74 74                	je     f0100666 <cons_putc+0x123>
f01005f2:	83 f8 09             	cmp    $0x9,%eax
f01005f5:	7f 0a                	jg     f0100601 <cons_putc+0xbe>
f01005f7:	83 f8 08             	cmp    $0x8,%eax
f01005fa:	74 14                	je     f0100610 <cons_putc+0xcd>
f01005fc:	e9 99 00 00 00       	jmp    f010069a <cons_putc+0x157>
f0100601:	83 f8 0a             	cmp    $0xa,%eax
f0100604:	74 3a                	je     f0100640 <cons_putc+0xfd>
f0100606:	83 f8 0d             	cmp    $0xd,%eax
f0100609:	74 3d                	je     f0100648 <cons_putc+0x105>
f010060b:	e9 8a 00 00 00       	jmp    f010069a <cons_putc+0x157>
	case '\b':
		if (crt_pos > 0) {
f0100610:	0f b7 05 48 82 23 f0 	movzwl 0xf0238248,%eax
f0100617:	66 85 c0             	test   %ax,%ax
f010061a:	0f 84 e6 00 00 00    	je     f0100706 <cons_putc+0x1c3>
			crt_pos--;
f0100620:	83 e8 01             	sub    $0x1,%eax
f0100623:	66 a3 48 82 23 f0    	mov    %ax,0xf0238248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100629:	0f b7 c0             	movzwl %ax,%eax
f010062c:	66 81 e7 00 ff       	and    $0xff00,%di
f0100631:	83 cf 20             	or     $0x20,%edi
f0100634:	8b 15 4c 82 23 f0    	mov    0xf023824c,%edx
f010063a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010063e:	eb 78                	jmp    f01006b8 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100640:	66 83 05 48 82 23 f0 	addw   $0x50,0xf0238248
f0100647:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100648:	0f b7 05 48 82 23 f0 	movzwl 0xf0238248,%eax
f010064f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100655:	c1 e8 16             	shr    $0x16,%eax
f0100658:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010065b:	c1 e0 04             	shl    $0x4,%eax
f010065e:	66 a3 48 82 23 f0    	mov    %ax,0xf0238248
f0100664:	eb 52                	jmp    f01006b8 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f0100666:	b8 20 00 00 00       	mov    $0x20,%eax
f010066b:	e8 d3 fe ff ff       	call   f0100543 <cons_putc>
		cons_putc(' ');
f0100670:	b8 20 00 00 00       	mov    $0x20,%eax
f0100675:	e8 c9 fe ff ff       	call   f0100543 <cons_putc>
		cons_putc(' ');
f010067a:	b8 20 00 00 00       	mov    $0x20,%eax
f010067f:	e8 bf fe ff ff       	call   f0100543 <cons_putc>
		cons_putc(' ');
f0100684:	b8 20 00 00 00       	mov    $0x20,%eax
f0100689:	e8 b5 fe ff ff       	call   f0100543 <cons_putc>
		cons_putc(' ');
f010068e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100693:	e8 ab fe ff ff       	call   f0100543 <cons_putc>
f0100698:	eb 1e                	jmp    f01006b8 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010069a:	0f b7 05 48 82 23 f0 	movzwl 0xf0238248,%eax
f01006a1:	8d 50 01             	lea    0x1(%eax),%edx
f01006a4:	66 89 15 48 82 23 f0 	mov    %dx,0xf0238248
f01006ab:	0f b7 c0             	movzwl %ax,%eax
f01006ae:	8b 15 4c 82 23 f0    	mov    0xf023824c,%edx
f01006b4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01006b8:	66 81 3d 48 82 23 f0 	cmpw   $0x7cf,0xf0238248
f01006bf:	cf 07 
f01006c1:	76 43                	jbe    f0100706 <cons_putc+0x1c3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01006c3:	a1 4c 82 23 f0       	mov    0xf023824c,%eax
f01006c8:	83 ec 04             	sub    $0x4,%esp
f01006cb:	68 00 0f 00 00       	push   $0xf00
f01006d0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01006d6:	52                   	push   %edx
f01006d7:	50                   	push   %eax
f01006d8:	e8 5c 53 00 00       	call   f0105a39 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01006dd:	8b 15 4c 82 23 f0    	mov    0xf023824c,%edx
f01006e3:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01006e9:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01006ef:	83 c4 10             	add    $0x10,%esp
f01006f2:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01006f7:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006fa:	39 c2                	cmp    %eax,%edx
f01006fc:	75 f4                	jne    f01006f2 <cons_putc+0x1af>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01006fe:	66 83 2d 48 82 23 f0 	subw   $0x50,0xf0238248
f0100705:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100706:	8b 0d 50 82 23 f0    	mov    0xf0238250,%ecx
f010070c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100711:	89 ca                	mov    %ecx,%edx
f0100713:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100714:	0f b7 1d 48 82 23 f0 	movzwl 0xf0238248,%ebx
f010071b:	8d 71 01             	lea    0x1(%ecx),%esi
f010071e:	89 d8                	mov    %ebx,%eax
f0100720:	66 c1 e8 08          	shr    $0x8,%ax
f0100724:	89 f2                	mov    %esi,%edx
f0100726:	ee                   	out    %al,(%dx)
f0100727:	b8 0f 00 00 00       	mov    $0xf,%eax
f010072c:	89 ca                	mov    %ecx,%edx
f010072e:	ee                   	out    %al,(%dx)
f010072f:	89 d8                	mov    %ebx,%eax
f0100731:	89 f2                	mov    %esi,%edx
f0100733:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100734:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100737:	5b                   	pop    %ebx
f0100738:	5e                   	pop    %esi
f0100739:	5f                   	pop    %edi
f010073a:	5d                   	pop    %ebp
f010073b:	c3                   	ret    

f010073c <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f010073c:	83 3d 54 82 23 f0 00 	cmpl   $0x0,0xf0238254
f0100743:	74 11                	je     f0100756 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100745:	55                   	push   %ebp
f0100746:	89 e5                	mov    %esp,%ebp
f0100748:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010074b:	b8 d6 03 10 f0       	mov    $0xf01003d6,%eax
f0100750:	e8 a0 fc ff ff       	call   f01003f5 <cons_intr>
}
f0100755:	c9                   	leave  
f0100756:	f3 c3                	repz ret 

f0100758 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100758:	55                   	push   %ebp
f0100759:	89 e5                	mov    %esp,%ebp
f010075b:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010075e:	b8 38 04 10 f0       	mov    $0xf0100438,%eax
f0100763:	e8 8d fc ff ff       	call   f01003f5 <cons_intr>
}
f0100768:	c9                   	leave  
f0100769:	c3                   	ret    

f010076a <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010076a:	55                   	push   %ebp
f010076b:	89 e5                	mov    %esp,%ebp
f010076d:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100770:	e8 c7 ff ff ff       	call   f010073c <serial_intr>
	kbd_intr();
f0100775:	e8 de ff ff ff       	call   f0100758 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010077a:	a1 40 82 23 f0       	mov    0xf0238240,%eax
f010077f:	3b 05 44 82 23 f0    	cmp    0xf0238244,%eax
f0100785:	74 26                	je     f01007ad <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100787:	8d 50 01             	lea    0x1(%eax),%edx
f010078a:	89 15 40 82 23 f0    	mov    %edx,0xf0238240
f0100790:	0f b6 88 40 80 23 f0 	movzbl -0xfdc7fc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100797:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100799:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010079f:	75 11                	jne    f01007b2 <cons_getc+0x48>
			cons.rpos = 0;
f01007a1:	c7 05 40 82 23 f0 00 	movl   $0x0,0xf0238240
f01007a8:	00 00 00 
f01007ab:	eb 05                	jmp    f01007b2 <cons_getc+0x48>
		return c;
	}
	return 0;
f01007ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01007b2:	c9                   	leave  
f01007b3:	c3                   	ret    

f01007b4 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01007b4:	55                   	push   %ebp
f01007b5:	89 e5                	mov    %esp,%ebp
f01007b7:	57                   	push   %edi
f01007b8:	56                   	push   %esi
f01007b9:	53                   	push   %ebx
f01007ba:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01007bd:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01007c4:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01007cb:	5a a5 
	if (*cp != 0xA55A) {
f01007cd:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01007d4:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01007d8:	74 11                	je     f01007eb <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01007da:	c7 05 50 82 23 f0 b4 	movl   $0x3b4,0xf0238250
f01007e1:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01007e4:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01007e9:	eb 16                	jmp    f0100801 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01007eb:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007f2:	c7 05 50 82 23 f0 d4 	movl   $0x3d4,0xf0238250
f01007f9:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01007fc:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100801:	8b 3d 50 82 23 f0    	mov    0xf0238250,%edi
f0100807:	b8 0e 00 00 00       	mov    $0xe,%eax
f010080c:	89 fa                	mov    %edi,%edx
f010080e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010080f:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100812:	89 da                	mov    %ebx,%edx
f0100814:	ec                   	in     (%dx),%al
f0100815:	0f b6 c8             	movzbl %al,%ecx
f0100818:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010081b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100820:	89 fa                	mov    %edi,%edx
f0100822:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100823:	89 da                	mov    %ebx,%edx
f0100825:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100826:	89 35 4c 82 23 f0    	mov    %esi,0xf023824c
	crt_pos = pos;
f010082c:	0f b6 c0             	movzbl %al,%eax
f010082f:	09 c8                	or     %ecx,%eax
f0100831:	66 a3 48 82 23 f0    	mov    %ax,0xf0238248

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100837:	e8 1c ff ff ff       	call   f0100758 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f010083c:	83 ec 0c             	sub    $0xc,%esp
f010083f:	0f b7 05 88 13 12 f0 	movzwl 0xf0121388,%eax
f0100846:	25 fd ff 00 00       	and    $0xfffd,%eax
f010084b:	50                   	push   %eax
f010084c:	e8 ef 34 00 00       	call   f0103d40 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100851:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100856:	b8 00 00 00 00       	mov    $0x0,%eax
f010085b:	89 f2                	mov    %esi,%edx
f010085d:	ee                   	out    %al,(%dx)
f010085e:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100863:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100868:	ee                   	out    %al,(%dx)
f0100869:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010086e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100873:	89 da                	mov    %ebx,%edx
f0100875:	ee                   	out    %al,(%dx)
f0100876:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010087b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100880:	ee                   	out    %al,(%dx)
f0100881:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100886:	b8 03 00 00 00       	mov    $0x3,%eax
f010088b:	ee                   	out    %al,(%dx)
f010088c:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100891:	b8 00 00 00 00       	mov    $0x0,%eax
f0100896:	ee                   	out    %al,(%dx)
f0100897:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010089c:	b8 01 00 00 00       	mov    $0x1,%eax
f01008a1:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008a2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01008a7:	ec                   	in     (%dx),%al
f01008a8:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01008aa:	83 c4 10             	add    $0x10,%esp
f01008ad:	3c ff                	cmp    $0xff,%al
f01008af:	0f 95 c0             	setne  %al
f01008b2:	0f b6 c0             	movzbl %al,%eax
f01008b5:	a3 54 82 23 f0       	mov    %eax,0xf0238254
f01008ba:	89 f2                	mov    %esi,%edx
f01008bc:	ec                   	in     (%dx),%al
f01008bd:	89 da                	mov    %ebx,%edx
f01008bf:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01008c0:	80 f9 ff             	cmp    $0xff,%cl
f01008c3:	75 10                	jne    f01008d5 <cons_init+0x121>
		cprintf("Serial port does not exist!\n");
f01008c5:	83 ec 0c             	sub    $0xc,%esp
f01008c8:	68 6b 68 10 f0       	push   $0xf010686b
f01008cd:	e8 c2 35 00 00       	call   f0103e94 <cprintf>
f01008d2:	83 c4 10             	add    $0x10,%esp
}
f01008d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d8:	5b                   	pop    %ebx
f01008d9:	5e                   	pop    %esi
f01008da:	5f                   	pop    %edi
f01008db:	5d                   	pop    %ebp
f01008dc:	c3                   	ret    

f01008dd <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01008dd:	55                   	push   %ebp
f01008de:	89 e5                	mov    %esp,%ebp
f01008e0:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01008e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01008e6:	e8 58 fc ff ff       	call   f0100543 <cons_putc>
}
f01008eb:	c9                   	leave  
f01008ec:	c3                   	ret    

f01008ed <getchar>:

int
getchar(void)
{
f01008ed:	55                   	push   %ebp
f01008ee:	89 e5                	mov    %esp,%ebp
f01008f0:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01008f3:	e8 72 fe ff ff       	call   f010076a <cons_getc>
f01008f8:	85 c0                	test   %eax,%eax
f01008fa:	74 f7                	je     f01008f3 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01008fc:	c9                   	leave  
f01008fd:	c3                   	ret    

f01008fe <iscons>:

int
iscons(int fdnum)
{
f01008fe:	55                   	push   %ebp
f01008ff:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100901:	b8 01 00 00 00       	mov    $0x1,%eax
f0100906:	5d                   	pop    %ebp
f0100907:	c3                   	ret    

f0100908 <mon_help>:
	return 0;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100908:	55                   	push   %ebp
f0100909:	89 e5                	mov    %esp,%ebp
f010090b:	56                   	push   %esi
f010090c:	53                   	push   %ebx
f010090d:	bb 04 6e 10 f0       	mov    $0xf0106e04,%ebx
f0100912:	be 58 6e 10 f0       	mov    $0xf0106e58,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100917:	83 ec 04             	sub    $0x4,%esp
f010091a:	ff 33                	pushl  (%ebx)
f010091c:	ff 73 fc             	pushl  -0x4(%ebx)
f010091f:	68 c0 6a 10 f0       	push   $0xf0106ac0
f0100924:	e8 6b 35 00 00       	call   f0103e94 <cprintf>
f0100929:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f010092c:	83 c4 10             	add    $0x10,%esp
f010092f:	39 f3                	cmp    %esi,%ebx
f0100931:	75 e4                	jne    f0100917 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100933:	b8 00 00 00 00       	mov    $0x0,%eax
f0100938:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010093b:	5b                   	pop    %ebx
f010093c:	5e                   	pop    %esi
f010093d:	5d                   	pop    %ebp
f010093e:	c3                   	ret    

f010093f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010093f:	55                   	push   %ebp
f0100940:	89 e5                	mov    %esp,%ebp
f0100942:	83 ec 14             	sub    $0x14,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100945:	68 c9 6a 10 f0       	push   $0xf0106ac9
f010094a:	e8 45 35 00 00       	call   f0103e94 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010094f:	83 c4 0c             	add    $0xc,%esp
f0100952:	68 0c 00 10 00       	push   $0x10000c
f0100957:	68 0c 00 10 f0       	push   $0xf010000c
f010095c:	68 38 6c 10 f0       	push   $0xf0106c38
f0100961:	e8 2e 35 00 00       	call   f0103e94 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100966:	83 c4 0c             	add    $0xc,%esp
f0100969:	68 21 67 10 00       	push   $0x106721
f010096e:	68 21 67 10 f0       	push   $0xf0106721
f0100973:	68 5c 6c 10 f0       	push   $0xf0106c5c
f0100978:	e8 17 35 00 00       	call   f0103e94 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010097d:	83 c4 0c             	add    $0xc,%esp
f0100980:	68 f0 7d 23 00       	push   $0x237df0
f0100985:	68 f0 7d 23 f0       	push   $0xf0237df0
f010098a:	68 80 6c 10 f0       	push   $0xf0106c80
f010098f:	e8 00 35 00 00       	call   f0103e94 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100994:	83 c4 0c             	add    $0xc,%esp
f0100997:	68 04 a0 27 00       	push   $0x27a004
f010099c:	68 04 a0 27 f0       	push   $0xf027a004
f01009a1:	68 a4 6c 10 f0       	push   $0xf0106ca4
f01009a6:	e8 e9 34 00 00       	call   f0103e94 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01009ab:	83 c4 08             	add    $0x8,%esp
f01009ae:	b8 03 a4 27 f0       	mov    $0xf027a403,%eax
f01009b3:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01009b8:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01009be:	85 c0                	test   %eax,%eax
f01009c0:	0f 48 c2             	cmovs  %edx,%eax
f01009c3:	c1 f8 0a             	sar    $0xa,%eax
f01009c6:	50                   	push   %eax
f01009c7:	68 c8 6c 10 f0       	push   $0xf0106cc8
f01009cc:	e8 c3 34 00 00       	call   f0103e94 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f01009d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01009d6:	c9                   	leave  
f01009d7:	c3                   	ret    

f01009d8 <mon_debug_display>:
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/
int
mon_debug_display(int argc, char **argv, struct Trapframe *tf)
{
f01009d8:	55                   	push   %ebp
f01009d9:	89 e5                	mov    %esp,%ebp
f01009db:	83 ec 08             	sub    $0x8,%esp
	if (argc != 2) {
f01009de:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01009e2:	74 17                	je     f01009fb <mon_debug_display+0x23>
		cprintf("Usage: x [address]");
f01009e4:	83 ec 0c             	sub    $0xc,%esp
f01009e7:	68 e2 6a 10 f0       	push   $0xf0106ae2
f01009ec:	e8 a3 34 00 00       	call   f0103e94 <cprintf>
		return 1;
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01009f9:	eb 29                	jmp    f0100a24 <mon_debug_display+0x4c>
	}

	int result = *(int *)(strtol(argv[1], NULL, 16));
f01009fb:	83 ec 04             	sub    $0x4,%esp
f01009fe:	6a 10                	push   $0x10
f0100a00:	6a 00                	push   $0x0
f0100a02:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a05:	ff 70 04             	pushl  0x4(%eax)
f0100a08:	e8 37 51 00 00       	call   f0105b44 <strtol>
	cprintf("%d\n", result);
f0100a0d:	83 c4 08             	add    $0x8,%esp
f0100a10:	ff 30                	pushl  (%eax)
f0100a12:	68 54 7b 10 f0       	push   $0xf0107b54
f0100a17:	e8 78 34 00 00       	call   f0103e94 <cprintf>
	return 0;
f0100a1c:	83 c4 10             	add    $0x10,%esp
f0100a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100a24:	c9                   	leave  
f0100a25:	c3                   	ret    

f0100a26 <mon_debug_step>:

int
mon_debug_step(int argc, char **argv, struct Trapframe *tf)
{
f0100a26:	55                   	push   %ebp
f0100a27:	89 e5                	mov    %esp,%ebp
f0100a29:	83 ec 08             	sub    $0x8,%esp
f0100a2c:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf == NULL) {
f0100a2f:	85 c0                	test   %eax,%eax
f0100a31:	74 2d                	je     f0100a60 <mon_debug_step+0x3a>
		cprintf("Trapframe is NULL.\n");
		return 1;
	}

	tf->tf_eflags |= FL_TF;
f0100a33:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
	cprintf("tf_eip=0x%x\n", tf->tf_eip);
f0100a3a:	83 ec 08             	sub    $0x8,%esp
f0100a3d:	ff 70 30             	pushl  0x30(%eax)
f0100a40:	68 09 6b 10 f0       	push   $0xf0106b09
f0100a45:	e8 4a 34 00 00       	call   f0103e94 <cprintf>
	env_run(curenv);
f0100a4a:	e8 18 56 00 00       	call   f0106067 <cpunum>
f0100a4f:	83 c4 04             	add    $0x4,%esp
f0100a52:	6b c0 74             	imul   $0x74,%eax,%eax
f0100a55:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0100a5b:	e8 cb 31 00 00       	call   f0103c2b <env_run>

int
mon_debug_step(int argc, char **argv, struct Trapframe *tf)
{
	if (tf == NULL) {
		cprintf("Trapframe is NULL.\n");
f0100a60:	83 ec 0c             	sub    $0xc,%esp
f0100a63:	68 f5 6a 10 f0       	push   $0xf0106af5
f0100a68:	e8 27 34 00 00       	call   f0103e94 <cprintf>

	tf->tf_eflags |= FL_TF;
	cprintf("tf_eip=0x%x\n", tf->tf_eip);
	env_run(curenv);
	return 0;
}
f0100a6d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a72:	c9                   	leave  
f0100a73:	c3                   	ret    

f0100a74 <mon_debug_continue>:

int
mon_debug_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100a74:	55                   	push   %ebp
f0100a75:	89 e5                	mov    %esp,%ebp
f0100a77:	83 ec 08             	sub    $0x8,%esp
f0100a7a:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf == NULL) {
f0100a7d:	85 c0                	test   %eax,%eax
f0100a7f:	74 1d                	je     f0100a9e <mon_debug_continue+0x2a>
		cprintf("Trapframe is NULL.\n");
		return 1;
	}

	tf->tf_eflags &= ~FL_TF;
f0100a81:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	env_run(curenv);
f0100a88:	e8 da 55 00 00       	call   f0106067 <cpunum>
f0100a8d:	83 ec 0c             	sub    $0xc,%esp
f0100a90:	6b c0 74             	imul   $0x74,%eax,%eax
f0100a93:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0100a99:	e8 8d 31 00 00       	call   f0103c2b <env_run>

int
mon_debug_continue(int argc, char **argv, struct Trapframe *tf)
{
	if (tf == NULL) {
		cprintf("Trapframe is NULL.\n");
f0100a9e:	83 ec 0c             	sub    $0xc,%esp
f0100aa1:	68 f5 6a 10 f0       	push   $0xf0106af5
f0100aa6:	e8 e9 33 00 00       	call   f0103e94 <cprintf>
	}

	tf->tf_eflags &= ~FL_TF;
	env_run(curenv);
	return 0;
}
f0100aab:	b8 01 00 00 00       	mov    $0x1,%eax
f0100ab0:	c9                   	leave  
f0100ab1:	c3                   	ret    

f0100ab2 <mon_backtrace>:

#define EBP_OFFSET(ebp, offset) (*((uint32_t *)(ebp) + (offset)))

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100ab2:	55                   	push   %ebp
f0100ab3:	89 e5                	mov    %esp,%ebp
f0100ab5:	57                   	push   %edi
f0100ab6:	56                   	push   %esi
f0100ab7:	53                   	push   %ebx
f0100ab8:	83 ec 48             	sub    $0x48,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100abb:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
f0100abd:	68 16 6b 10 f0       	push   $0xf0106b16
f0100ac2:	e8 cd 33 00 00       	call   f0103e94 <cprintf>
	while(ebp != 0x0) {
f0100ac7:	83 c4 10             	add    $0x10,%esp
f0100aca:	85 f6                	test   %esi,%esi
f0100acc:	0f 84 97 00 00 00    	je     f0100b69 <mon_backtrace+0xb7>
f0100ad2:	89 f3                	mov    %esi,%ebx
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f0100ad4:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100ad7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
		eip = EBP_OFFSET(ebp, 1);
f0100ada:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
f0100add:	ff 73 18             	pushl  0x18(%ebx)
f0100ae0:	ff 73 14             	pushl  0x14(%ebx)
f0100ae3:	ff 73 10             	pushl  0x10(%ebx)
f0100ae6:	ff 73 0c             	pushl  0xc(%ebx)
f0100ae9:	ff 73 08             	pushl  0x8(%ebx)
f0100aec:	53                   	push   %ebx
f0100aed:	56                   	push   %esi
f0100aee:	68 f4 6c 10 f0       	push   $0xf0106cf4
f0100af3:	e8 9c 33 00 00       	call   f0103e94 <cprintf>
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f0100af8:	83 c4 18             	add    $0x18,%esp
f0100afb:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100afe:	56                   	push   %esi
f0100aff:	e8 46 41 00 00       	call   f0104c4a <debuginfo_eip>
f0100b04:	83 c4 10             	add    $0x10,%esp
f0100b07:	85 c0                	test   %eax,%eax
f0100b09:	75 54                	jne    f0100b5f <mon_backtrace+0xad>
f0100b0b:	89 65 c0             	mov    %esp,-0x40(%ebp)
			char func_name[info.eip_fn_namelen + 1];
f0100b0e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100b11:	8d 41 10             	lea    0x10(%ecx),%eax
f0100b14:	bf 10 00 00 00       	mov    $0x10,%edi
f0100b19:	ba 00 00 00 00       	mov    $0x0,%edx
f0100b1e:	f7 f7                	div    %edi
f0100b20:	c1 e0 04             	shl    $0x4,%eax
f0100b23:	29 c4                	sub    %eax,%esp
f0100b25:	89 e0                	mov    %esp,%eax
f0100b27:	89 e7                	mov    %esp,%edi
			func_name[info.eip_fn_namelen] = '\0';
f0100b29:	c6 04 0c 00          	movb   $0x0,(%esp,%ecx,1)
			if (strncpy(func_name, info.eip_fn_name, info.eip_fn_namelen)) {
f0100b2d:	83 ec 04             	sub    $0x4,%esp
f0100b30:	51                   	push   %ecx
f0100b31:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b34:	50                   	push   %eax
f0100b35:	e8 52 4d 00 00       	call   f010588c <strncpy>
f0100b3a:	83 c4 10             	add    $0x10,%esp
f0100b3d:	85 c0                	test   %eax,%eax
f0100b3f:	74 1b                	je     f0100b5c <mon_backtrace+0xaa>
				cprintf("\t%s:%d: %s+%x\n\n", info.eip_file, info.eip_line,
f0100b41:	83 ec 0c             	sub    $0xc,%esp
f0100b44:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100b47:	56                   	push   %esi
f0100b48:	57                   	push   %edi
f0100b49:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b4c:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b4f:	68 28 6b 10 f0       	push   $0xf0106b28
f0100b54:	e8 3b 33 00 00       	call   f0103e94 <cprintf>
f0100b59:	83 c4 20             	add    $0x20,%esp
f0100b5c:	8b 65 c0             	mov    -0x40(%ebp),%esp
				func_name, eip - info.eip_fn_addr);
			}
		}
		// warning: the value of ebp to print is register value, not stack value
		ebp = EBP_OFFSET(ebp, 0);
f0100b5f:	8b 1b                	mov    (%ebx),%ebx
{
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
f0100b61:	85 db                	test   %ebx,%ebx
f0100b63:	0f 85 71 ff ff ff    	jne    f0100ada <mon_backtrace+0x28>
		}
		// warning: the value of ebp to print is register value, not stack value
		ebp = EBP_OFFSET(ebp, 0);
	}

	cprintf("Backtrace success\n");
f0100b69:	83 ec 0c             	sub    $0xc,%esp
f0100b6c:	68 38 6b 10 f0       	push   $0xf0106b38
f0100b71:	e8 1e 33 00 00       	call   f0103e94 <cprintf>
	return 0;
}
f0100b76:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b7e:	5b                   	pop    %ebx
f0100b7f:	5e                   	pop    %esi
f0100b80:	5f                   	pop    %edi
f0100b81:	5d                   	pop    %ebp
f0100b82:	c3                   	ret    

f0100b83 <mon_time>:
	return (((uint64_t)high << 32) | low);
}

int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f0100b83:	55                   	push   %ebp
f0100b84:	89 e5                	mov    %esp,%ebp
f0100b86:	57                   	push   %edi
f0100b87:	56                   	push   %esi
f0100b88:	53                   	push   %ebx
f0100b89:	83 ec 1c             	sub    $0x1c,%esp
f0100b8c:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100b8f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100b93:	74 0c                	je     f0100ba1 <mon_time+0x1e>
f0100b95:	bf 00 6e 10 f0       	mov    $0xf0106e00,%edi
f0100b9a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b9f:	eb 1d                	jmp    f0100bbe <mon_time+0x3b>
		cprintf("Usage: time [command]\n");
f0100ba1:	83 ec 0c             	sub    $0xc,%esp
f0100ba4:	68 4b 6b 10 f0       	push   $0xf0106b4b
f0100ba9:	e8 e6 32 00 00       	call   f0103e94 <cprintf>
		return 0;
f0100bae:	83 c4 10             	add    $0x10,%esp
f0100bb1:	eb 7a                	jmp    f0100c2d <mon_time+0xaa>
	}

	int i;
	for (i = 0; i < NCOMMANDS && strcmp(argv[1], commands[i].name); i++)
f0100bb3:	83 c3 01             	add    $0x1,%ebx
f0100bb6:	83 c7 0c             	add    $0xc,%edi
f0100bb9:	83 fb 07             	cmp    $0x7,%ebx
f0100bbc:	74 19                	je     f0100bd7 <mon_time+0x54>
f0100bbe:	83 ec 08             	sub    $0x8,%esp
f0100bc1:	ff 37                	pushl  (%edi)
f0100bc3:	ff 76 04             	pushl  0x4(%esi)
f0100bc6:	e8 3f 4d 00 00       	call   f010590a <strcmp>
f0100bcb:	83 c4 10             	add    $0x10,%esp
f0100bce:	85 c0                	test   %eax,%eax
f0100bd0:	75 e1                	jne    f0100bb3 <mon_time+0x30>
		;

	if (i == NCOMMANDS) {
f0100bd2:	83 fb 07             	cmp    $0x7,%ebx
f0100bd5:	75 15                	jne    f0100bec <mon_time+0x69>
		cprintf("Unknown command: %s\n", argv[1]);
f0100bd7:	83 ec 08             	sub    $0x8,%esp
f0100bda:	ff 76 04             	pushl  0x4(%esi)
f0100bdd:	68 62 6b 10 f0       	push   $0xf0106b62
f0100be2:	e8 ad 32 00 00       	call   f0103e94 <cprintf>
		return 0;
f0100be7:	83 c4 10             	add    $0x10,%esp
f0100bea:	eb 41                	jmp    f0100c2d <mon_time+0xaa>

uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f0100bec:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
f0100bee:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100bf1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		cprintf("Unknown command: %s\n", argv[1]);
		return 0;
	}

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
f0100bf4:	83 ec 04             	sub    $0x4,%esp
f0100bf7:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f0100bfa:	ff 75 10             	pushl  0x10(%ebp)
f0100bfd:	8d 46 04             	lea    0x4(%esi),%eax
f0100c00:	50                   	push   %eax
f0100c01:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c04:	83 e8 01             	sub    $0x1,%eax
f0100c07:	50                   	push   %eax
f0100c08:	ff 14 95 08 6e 10 f0 	call   *-0xfef91f8(,%edx,4)

uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f0100c0f:	0f 31                	rdtsc  

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
	uint64_t end = rdtsc();

	cprintf("%s cycles: %llu\n", argv[1], end - start);
f0100c11:	89 c1                	mov    %eax,%ecx
f0100c13:	89 d3                	mov    %edx,%ebx
f0100c15:	2b 4d e0             	sub    -0x20(%ebp),%ecx
f0100c18:	1b 5d e4             	sbb    -0x1c(%ebp),%ebx
f0100c1b:	53                   	push   %ebx
f0100c1c:	51                   	push   %ecx
f0100c1d:	ff 76 04             	pushl  0x4(%esi)
f0100c20:	68 77 6b 10 f0       	push   $0xf0106b77
f0100c25:	e8 6a 32 00 00       	call   f0103e94 <cprintf>

	return 0;
f0100c2a:	83 c4 20             	add    $0x20,%esp
}
f0100c2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c32:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c35:	5b                   	pop    %ebx
f0100c36:	5e                   	pop    %esi
f0100c37:	5f                   	pop    %edi
f0100c38:	5d                   	pop    %ebp
f0100c39:	c3                   	ret    

f0100c3a <rdtsc>:
	return 0;
}

uint64_t
rdtsc()
{
f0100c3a:	55                   	push   %ebp
f0100c3b:	89 e5                	mov    %esp,%ebp
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f0100c3d:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
}
f0100c3f:	5d                   	pop    %ebp
f0100c40:	c3                   	ret    

f0100c41 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100c41:	55                   	push   %ebp
f0100c42:	89 e5                	mov    %esp,%ebp
f0100c44:	57                   	push   %edi
f0100c45:	56                   	push   %esi
f0100c46:	53                   	push   %ebx
f0100c47:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100c4a:	68 2c 6d 10 f0       	push   $0xf0106d2c
f0100c4f:	e8 40 32 00 00       	call   f0103e94 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c54:	c7 04 24 50 6d 10 f0 	movl   $0xf0106d50,(%esp)
f0100c5b:	e8 34 32 00 00       	call   f0103e94 <cprintf>

	if (tf != NULL)
f0100c60:	83 c4 10             	add    $0x10,%esp
f0100c63:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100c67:	74 0e                	je     f0100c77 <monitor+0x36>
		print_trapframe(tf);
f0100c69:	83 ec 0c             	sub    $0xc,%esp
f0100c6c:	ff 75 08             	pushl  0x8(%ebp)
f0100c6f:	e8 04 37 00 00       	call   f0104378 <print_trapframe>
f0100c74:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100c77:	83 ec 0c             	sub    $0xc,%esp
f0100c7a:	68 88 6b 10 f0       	push   $0xf0106b88
f0100c7f:	e8 92 4a 00 00       	call   f0105716 <readline>
f0100c84:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100c86:	83 c4 10             	add    $0x10,%esp
f0100c89:	85 c0                	test   %eax,%eax
f0100c8b:	74 ea                	je     f0100c77 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100c8d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100c94:	be 00 00 00 00       	mov    $0x0,%esi
f0100c99:	eb 0a                	jmp    f0100ca5 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100c9b:	c6 03 00             	movb   $0x0,(%ebx)
f0100c9e:	89 f7                	mov    %esi,%edi
f0100ca0:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100ca3:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100ca5:	0f b6 03             	movzbl (%ebx),%eax
f0100ca8:	84 c0                	test   %al,%al
f0100caa:	74 6a                	je     f0100d16 <monitor+0xd5>
f0100cac:	83 ec 08             	sub    $0x8,%esp
f0100caf:	0f be c0             	movsbl %al,%eax
f0100cb2:	50                   	push   %eax
f0100cb3:	68 8c 6b 10 f0       	push   $0xf0106b8c
f0100cb8:	e8 d1 4c 00 00       	call   f010598e <strchr>
f0100cbd:	83 c4 10             	add    $0x10,%esp
f0100cc0:	85 c0                	test   %eax,%eax
f0100cc2:	75 d7                	jne    f0100c9b <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100cc4:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100cc7:	74 4d                	je     f0100d16 <monitor+0xd5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100cc9:	83 fe 0f             	cmp    $0xf,%esi
f0100ccc:	75 14                	jne    f0100ce2 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100cce:	83 ec 08             	sub    $0x8,%esp
f0100cd1:	6a 10                	push   $0x10
f0100cd3:	68 91 6b 10 f0       	push   $0xf0106b91
f0100cd8:	e8 b7 31 00 00       	call   f0103e94 <cprintf>
f0100cdd:	83 c4 10             	add    $0x10,%esp
f0100ce0:	eb 95                	jmp    f0100c77 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100ce2:	8d 7e 01             	lea    0x1(%esi),%edi
f0100ce5:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ce9:	0f b6 03             	movzbl (%ebx),%eax
f0100cec:	84 c0                	test   %al,%al
f0100cee:	75 0c                	jne    f0100cfc <monitor+0xbb>
f0100cf0:	eb b1                	jmp    f0100ca3 <monitor+0x62>
			buf++;
f0100cf2:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100cf5:	0f b6 03             	movzbl (%ebx),%eax
f0100cf8:	84 c0                	test   %al,%al
f0100cfa:	74 a7                	je     f0100ca3 <monitor+0x62>
f0100cfc:	83 ec 08             	sub    $0x8,%esp
f0100cff:	0f be c0             	movsbl %al,%eax
f0100d02:	50                   	push   %eax
f0100d03:	68 8c 6b 10 f0       	push   $0xf0106b8c
f0100d08:	e8 81 4c 00 00       	call   f010598e <strchr>
f0100d0d:	83 c4 10             	add    $0x10,%esp
f0100d10:	85 c0                	test   %eax,%eax
f0100d12:	74 de                	je     f0100cf2 <monitor+0xb1>
f0100d14:	eb 8d                	jmp    f0100ca3 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100d16:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100d1d:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100d1e:	85 f6                	test   %esi,%esi
f0100d20:	0f 84 51 ff ff ff    	je     f0100c77 <monitor+0x36>
f0100d26:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d2b:	83 ec 08             	sub    $0x8,%esp
f0100d2e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100d31:	ff 34 85 00 6e 10 f0 	pushl  -0xfef9200(,%eax,4)
f0100d38:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d3b:	e8 ca 4b 00 00       	call   f010590a <strcmp>
f0100d40:	83 c4 10             	add    $0x10,%esp
f0100d43:	85 c0                	test   %eax,%eax
f0100d45:	75 21                	jne    f0100d68 <monitor+0x127>
			return commands[i].func(argc, argv, tf);
f0100d47:	83 ec 04             	sub    $0x4,%esp
f0100d4a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100d4d:	ff 75 08             	pushl  0x8(%ebp)
f0100d50:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100d53:	52                   	push   %edx
f0100d54:	56                   	push   %esi
f0100d55:	ff 14 85 08 6e 10 f0 	call   *-0xfef91f8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100d5c:	83 c4 10             	add    $0x10,%esp
f0100d5f:	85 c0                	test   %eax,%eax
f0100d61:	78 25                	js     f0100d88 <monitor+0x147>
f0100d63:	e9 0f ff ff ff       	jmp    f0100c77 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100d68:	83 c3 01             	add    $0x1,%ebx
f0100d6b:	83 fb 07             	cmp    $0x7,%ebx
f0100d6e:	75 bb                	jne    f0100d2b <monitor+0xea>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100d70:	83 ec 08             	sub    $0x8,%esp
f0100d73:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d76:	68 ae 6b 10 f0       	push   $0xf0106bae
f0100d7b:	e8 14 31 00 00       	call   f0103e94 <cprintf>
f0100d80:	83 c4 10             	add    $0x10,%esp
f0100d83:	e9 ef fe ff ff       	jmp    f0100c77 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d8b:	5b                   	pop    %ebx
f0100d8c:	5e                   	pop    %esi
f0100d8d:	5f                   	pop    %edi
f0100d8e:	5d                   	pop    %ebp
f0100d8f:	c3                   	ret    

f0100d90 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100d90:	55                   	push   %ebp
f0100d91:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100d93:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100d96:	5d                   	pop    %ebp
f0100d97:	c3                   	ret    

f0100d98 <check_continuous>:
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100d98:	8d 4a ff             	lea    -0x1(%edx),%ecx
f0100d9b:	85 c9                	test   %ecx,%ecx
f0100d9d:	7e 63                	jle    f0100e02 <check_continuous+0x6a>
	{
		if(tmp == NULL)
f0100d9f:	85 c0                	test   %eax,%eax
f0100da1:	74 65                	je     f0100e08 <check_continuous+0x70>
	cprintf("check_page() succeeded!\n");
}

static int
check_continuous(struct Page *pp, int num_page)
{
f0100da3:	55                   	push   %ebp
f0100da4:	89 e5                	mov    %esp,%ebp
f0100da6:	57                   	push   %edi
f0100da7:	56                   	push   %esi
f0100da8:	53                   	push   %ebx
	{
		if(tmp == NULL)
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100da9:	8b 08                	mov    (%eax),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dab:	8b 35 b0 8e 23 f0    	mov    0xf0238eb0,%esi
f0100db1:	89 cb                	mov    %ecx,%ebx
f0100db3:	29 f3                	sub    %esi,%ebx
f0100db5:	c1 fb 03             	sar    $0x3,%ebx
f0100db8:	29 f0                	sub    %esi,%eax
f0100dba:	c1 f8 03             	sar    $0x3,%eax
f0100dbd:	29 c3                	sub    %eax,%ebx
f0100dbf:	c1 e3 0c             	shl    $0xc,%ebx
f0100dc2:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
f0100dc8:	75 44                	jne    f0100e0e <check_continuous+0x76>
f0100dca:	8d 7a ff             	lea    -0x1(%edx),%edi
f0100dcd:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dd2:	eb 20                	jmp    f0100df4 <check_continuous+0x5c>
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
f0100dd4:	85 c9                	test   %ecx,%ecx
f0100dd6:	74 3d                	je     f0100e15 <check_continuous+0x7d>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100dd8:	8b 19                	mov    (%ecx),%ebx
f0100dda:	89 d8                	mov    %ebx,%eax
f0100ddc:	29 f0                	sub    %esi,%eax
f0100dde:	c1 f8 03             	sar    $0x3,%eax
f0100de1:	29 f1                	sub    %esi,%ecx
f0100de3:	c1 f9 03             	sar    $0x3,%ecx
f0100de6:	29 c8                	sub    %ecx,%eax
f0100de8:	c1 e0 0c             	shl    $0xc,%eax
f0100deb:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0100df0:	75 2a                	jne    f0100e1c <check_continuous+0x84>
f0100df2:	89 d9                	mov    %ebx,%ecx
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100df4:	83 c2 01             	add    $0x1,%edx
f0100df7:	39 fa                	cmp    %edi,%edx
f0100df9:	75 d9                	jne    f0100dd4 <check_continuous+0x3c>
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
		}
	}
	return 1;
f0100dfb:	b8 01 00 00 00       	mov    $0x1,%eax
f0100e00:	eb 1f                	jmp    f0100e21 <check_continuous+0x89>
f0100e02:	b8 01 00 00 00       	mov    $0x1,%eax
f0100e07:	c3                   	ret    
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
		{
			return 0;
f0100e08:	b8 00 00 00 00       	mov    $0x0,%eax
		{
			return 0;
		}
	}
	return 1;
}
f0100e0d:	c3                   	ret    
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
f0100e0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e13:	eb 0c                	jmp    f0100e21 <check_continuous+0x89>
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
		{
			return 0;
f0100e15:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e1a:	eb 05                	jmp    f0100e21 <check_continuous+0x89>
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
f0100e1c:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	return 1;
}
f0100e21:	5b                   	pop    %ebx
f0100e22:	5e                   	pop    %esi
f0100e23:	5f                   	pop    %edi
f0100e24:	5d                   	pop    %ebp
f0100e25:	c3                   	ret    

f0100e26 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100e26:	89 d1                	mov    %edx,%ecx
f0100e28:	c1 e9 16             	shr    $0x16,%ecx
f0100e2b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e2e:	a8 01                	test   $0x1,%al
f0100e30:	74 52                	je     f0100e84 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e37:	89 c1                	mov    %eax,%ecx
f0100e39:	c1 e9 0c             	shr    $0xc,%ecx
f0100e3c:	3b 0d a8 8e 23 f0    	cmp    0xf0238ea8,%ecx
f0100e42:	72 1b                	jb     f0100e5f <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100e44:	55                   	push   %ebp
f0100e45:	89 e5                	mov    %esp,%ebp
f0100e47:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e4a:	50                   	push   %eax
f0100e4b:	68 c0 67 10 f0       	push   $0xf01067c0
f0100e50:	68 12 04 00 00       	push   $0x412
f0100e55:	68 75 75 10 f0       	push   $0xf0107575
f0100e5a:	e8 e1 f1 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100e5f:	c1 ea 0c             	shr    $0xc,%edx
f0100e62:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100e68:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e6f:	89 c2                	mov    %eax,%edx
f0100e71:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100e74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e79:	85 d2                	test   %edx,%edx
f0100e7b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e80:	0f 44 c2             	cmove  %edx,%eax
f0100e83:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100e84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100e89:	c3                   	ret    

f0100e8a <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e8a:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e8c:	83 3d 58 82 23 f0 00 	cmpl   $0x0,0xf0238258
f0100e93:	75 0f                	jne    f0100ea4 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e95:	b8 03 b0 27 f0       	mov    $0xf027b003,%eax
f0100e9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e9f:	a3 58 82 23 f0       	mov    %eax,0xf0238258
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100ea4:	a1 58 82 23 f0       	mov    0xf0238258,%eax
	if (n > 0) {
f0100ea9:	85 d2                	test   %edx,%edx
f0100eab:	74 64                	je     f0100f11 <boot_alloc+0x87>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ead:	55                   	push   %ebp
f0100eae:	89 e5                	mov    %esp,%ebp
f0100eb0:	53                   	push   %ebx
f0100eb1:	83 ec 04             	sub    $0x4,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
	if (n > 0) {
		nextfree += n;
f0100eb4:	01 c2                	add    %eax,%edx
f0100eb6:	89 15 58 82 23 f0    	mov    %edx,0xf0238258
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ebc:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100ec2:	77 12                	ja     f0100ed6 <boot_alloc+0x4c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ec4:	52                   	push   %edx
f0100ec5:	68 e4 67 10 f0       	push   $0xf01067e4
f0100eca:	6a 6f                	push   $0x6f
f0100ecc:	68 75 75 10 f0       	push   $0xf0107575
f0100ed1:	e8 6a f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ed6:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100edc:	89 cb                	mov    %ecx,%ebx
f0100ede:	c1 eb 0c             	shr    $0xc,%ebx
f0100ee1:	39 1d a8 8e 23 f0    	cmp    %ebx,0xf0238ea8
f0100ee7:	77 12                	ja     f0100efb <boot_alloc+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee9:	51                   	push   %ecx
f0100eea:	68 c0 67 10 f0       	push   $0xf01067c0
f0100eef:	6a 6f                	push   $0x6f
f0100ef1:	68 75 75 10 f0       	push   $0xf0107575
f0100ef6:	e8 45 f1 ff ff       	call   f0100040 <_panic>
		nextfree = ROUNDUP(KADDR(PADDR(nextfree)), PGSIZE);
f0100efb:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100f01:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f07:	89 15 58 82 23 f0    	mov    %edx,0xf0238258
	}

	return result;
}
f0100f0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f10:	c9                   	leave  
f0100f11:	f3 c3                	repz ret 

f0100f13 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f13:	55                   	push   %ebp
f0100f14:	89 e5                	mov    %esp,%ebp
f0100f16:	57                   	push   %edi
f0100f17:	56                   	push   %esi
f0100f18:	53                   	push   %ebx
f0100f19:	83 ec 2c             	sub    $0x2c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f1c:	85 c0                	test   %eax,%eax
f0100f1e:	0f 85 d0 02 00 00    	jne    f01011f4 <check_page_free_list+0x2e1>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f24:	8b 1d 64 82 23 f0    	mov    0xf0238264,%ebx
f0100f2a:	85 db                	test   %ebx,%ebx
f0100f2c:	75 6c                	jne    f0100f9a <check_page_free_list+0x87>
		panic("'page_free_list' is a null pointer!");
f0100f2e:	83 ec 04             	sub    $0x4,%esp
f0100f31:	68 54 6e 10 f0       	push   $0xf0106e54
f0100f36:	68 43 03 00 00       	push   $0x343
f0100f3b:	68 75 75 10 f0       	push   $0xf0107575
f0100f40:	e8 fb f0 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100f45:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f48:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f4b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f4e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f51:	89 c2                	mov    %eax,%edx
f0100f53:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f0100f59:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f5f:	0f 95 c2             	setne  %dl
f0100f62:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f65:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f69:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f6b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f6f:	8b 00                	mov    (%eax),%eax
f0100f71:	85 c0                	test   %eax,%eax
f0100f73:	75 dc                	jne    f0100f51 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100f75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f81:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f84:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f86:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100f89:	89 1d 64 82 23 f0    	mov    %ebx,0xf0238264
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100f8f:	85 db                	test   %ebx,%ebx
f0100f91:	74 63                	je     f0100ff6 <check_page_free_list+0xe3>
f0100f93:	be 01 00 00 00       	mov    $0x1,%esi
f0100f98:	eb 05                	jmp    f0100f9f <check_page_free_list+0x8c>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f9a:	be 00 04 00 00       	mov    $0x400,%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f9f:	89 d8                	mov    %ebx,%eax
f0100fa1:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0100fa7:	c1 f8 03             	sar    $0x3,%eax
f0100faa:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
f0100fad:	89 c2                	mov    %eax,%edx
f0100faf:	c1 ea 16             	shr    $0x16,%edx
f0100fb2:	39 d6                	cmp    %edx,%esi
f0100fb4:	76 3a                	jbe    f0100ff0 <check_page_free_list+0xdd>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fb6:	89 c2                	mov    %eax,%edx
f0100fb8:	c1 ea 0c             	shr    $0xc,%edx
f0100fbb:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f0100fc1:	72 12                	jb     f0100fd5 <check_page_free_list+0xc2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fc3:	50                   	push   %eax
f0100fc4:	68 c0 67 10 f0       	push   $0xf01067c0
f0100fc9:	6a 56                	push   $0x56
f0100fcb:	68 81 75 10 f0       	push   $0xf0107581
f0100fd0:	e8 6b f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100fd5:	83 ec 04             	sub    $0x4,%esp
f0100fd8:	68 80 00 00 00       	push   $0x80
f0100fdd:	68 97 00 00 00       	push   $0x97
f0100fe2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fe7:	50                   	push   %eax
f0100fe8:	e8 ff 49 00 00       	call   f01059ec <memset>
f0100fed:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100ff0:	8b 1b                	mov    (%ebx),%ebx
f0100ff2:	85 db                	test   %ebx,%ebx
f0100ff4:	75 a9                	jne    f0100f9f <check_page_free_list+0x8c>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0100ff6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ffb:	e8 8a fe ff ff       	call   f0100e8a <boot_alloc>
f0101000:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101003:	8b 15 64 82 23 f0    	mov    0xf0238264,%edx
f0101009:	85 d2                	test   %edx,%edx
f010100b:	0f 84 ad 01 00 00    	je     f01011be <check_page_free_list+0x2ab>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101011:	8b 0d b0 8e 23 f0    	mov    0xf0238eb0,%ecx
f0101017:	39 ca                	cmp    %ecx,%edx
f0101019:	72 49                	jb     f0101064 <check_page_free_list+0x151>
		assert(pp < pages + npages);
f010101b:	a1 a8 8e 23 f0       	mov    0xf0238ea8,%eax
f0101020:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101023:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101026:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101029:	39 c2                	cmp    %eax,%edx
f010102b:	73 55                	jae    f0101082 <check_page_free_list+0x16f>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010102d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101030:	89 d0                	mov    %edx,%eax
f0101032:	29 c8                	sub    %ecx,%eax
f0101034:	a8 07                	test   $0x7,%al
f0101036:	75 6c                	jne    f01010a4 <check_page_free_list+0x191>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101038:	c1 f8 03             	sar    $0x3,%eax
f010103b:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010103e:	85 c0                	test   %eax,%eax
f0101040:	0f 84 81 00 00 00    	je     f01010c7 <check_page_free_list+0x1b4>
		assert(page2pa(pp) != IOPHYSMEM);
f0101046:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010104b:	0f 84 96 00 00 00    	je     f01010e7 <check_page_free_list+0x1d4>
f0101051:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101056:	be 00 00 00 00       	mov    $0x0,%esi
f010105b:	e9 a0 00 00 00       	jmp    f0101100 <check_page_free_list+0x1ed>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101060:	39 ca                	cmp    %ecx,%edx
f0101062:	73 19                	jae    f010107d <check_page_free_list+0x16a>
f0101064:	68 8f 75 10 f0       	push   $0xf010758f
f0101069:	68 9b 75 10 f0       	push   $0xf010759b
f010106e:	68 5e 03 00 00       	push   $0x35e
f0101073:	68 75 75 10 f0       	push   $0xf0107575
f0101078:	e8 c3 ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010107d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101080:	72 19                	jb     f010109b <check_page_free_list+0x188>
f0101082:	68 b0 75 10 f0       	push   $0xf01075b0
f0101087:	68 9b 75 10 f0       	push   $0xf010759b
f010108c:	68 5f 03 00 00       	push   $0x35f
f0101091:	68 75 75 10 f0       	push   $0xf0107575
f0101096:	e8 a5 ef ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010109b:	89 d0                	mov    %edx,%eax
f010109d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01010a0:	a8 07                	test   $0x7,%al
f01010a2:	74 19                	je     f01010bd <check_page_free_list+0x1aa>
f01010a4:	68 78 6e 10 f0       	push   $0xf0106e78
f01010a9:	68 9b 75 10 f0       	push   $0xf010759b
f01010ae:	68 60 03 00 00       	push   $0x360
f01010b3:	68 75 75 10 f0       	push   $0xf0107575
f01010b8:	e8 83 ef ff ff       	call   f0100040 <_panic>
f01010bd:	c1 f8 03             	sar    $0x3,%eax
f01010c0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010c3:	85 c0                	test   %eax,%eax
f01010c5:	75 19                	jne    f01010e0 <check_page_free_list+0x1cd>
f01010c7:	68 c4 75 10 f0       	push   $0xf01075c4
f01010cc:	68 9b 75 10 f0       	push   $0xf010759b
f01010d1:	68 63 03 00 00       	push   $0x363
f01010d6:	68 75 75 10 f0       	push   $0xf0107575
f01010db:	e8 60 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010e0:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010e5:	75 19                	jne    f0101100 <check_page_free_list+0x1ed>
f01010e7:	68 d5 75 10 f0       	push   $0xf01075d5
f01010ec:	68 9b 75 10 f0       	push   $0xf010759b
f01010f1:	68 64 03 00 00       	push   $0x364
f01010f6:	68 75 75 10 f0       	push   $0xf0107575
f01010fb:	e8 40 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101100:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101105:	75 19                	jne    f0101120 <check_page_free_list+0x20d>
f0101107:	68 ac 6e 10 f0       	push   $0xf0106eac
f010110c:	68 9b 75 10 f0       	push   $0xf010759b
f0101111:	68 65 03 00 00       	push   $0x365
f0101116:	68 75 75 10 f0       	push   $0xf0107575
f010111b:	e8 20 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101120:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101125:	75 19                	jne    f0101140 <check_page_free_list+0x22d>
f0101127:	68 ee 75 10 f0       	push   $0xf01075ee
f010112c:	68 9b 75 10 f0       	push   $0xf010759b
f0101131:	68 66 03 00 00       	push   $0x366
f0101136:	68 75 75 10 f0       	push   $0xf0107575
f010113b:	e8 00 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101140:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101145:	0f 86 bb 00 00 00    	jbe    f0101206 <check_page_free_list+0x2f3>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010114b:	89 c7                	mov    %eax,%edi
f010114d:	c1 ef 0c             	shr    $0xc,%edi
f0101150:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0101153:	77 12                	ja     f0101167 <check_page_free_list+0x254>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101155:	50                   	push   %eax
f0101156:	68 c0 67 10 f0       	push   $0xf01067c0
f010115b:	6a 56                	push   $0x56
f010115d:	68 81 75 10 f0       	push   $0xf0107581
f0101162:	e8 d9 ee ff ff       	call   f0100040 <_panic>
f0101167:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f010116d:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101170:	0f 86 99 00 00 00    	jbe    f010120f <check_page_free_list+0x2fc>
f0101176:	68 d0 6e 10 f0       	push   $0xf0106ed0
f010117b:	68 9b 75 10 f0       	push   $0xf010759b
f0101180:	68 67 03 00 00       	push   $0x367
f0101185:	68 75 75 10 f0       	push   $0xf0107575
f010118a:	e8 b1 ee ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010118f:	68 08 76 10 f0       	push   $0xf0107608
f0101194:	68 9b 75 10 f0       	push   $0xf010759b
f0101199:	68 69 03 00 00       	push   $0x369
f010119e:	68 75 75 10 f0       	push   $0xf0107575
f01011a3:	e8 98 ee ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01011a8:	83 c6 01             	add    $0x1,%esi
f01011ab:	eb 03                	jmp    f01011b0 <check_page_free_list+0x29d>
		else
			++nfree_extmem;
f01011ad:	83 c3 01             	add    $0x1,%ebx
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011b0:	8b 12                	mov    (%edx),%edx
f01011b2:	85 d2                	test   %edx,%edx
f01011b4:	0f 85 a6 fe ff ff    	jne    f0101060 <check_page_free_list+0x14d>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01011ba:	85 f6                	test   %esi,%esi
f01011bc:	7f 19                	jg     f01011d7 <check_page_free_list+0x2c4>
f01011be:	68 25 76 10 f0       	push   $0xf0107625
f01011c3:	68 9b 75 10 f0       	push   $0xf010759b
f01011c8:	68 71 03 00 00       	push   $0x371
f01011cd:	68 75 75 10 f0       	push   $0xf0107575
f01011d2:	e8 69 ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01011d7:	85 db                	test   %ebx,%ebx
f01011d9:	7f 40                	jg     f010121b <check_page_free_list+0x308>
f01011db:	68 37 76 10 f0       	push   $0xf0107637
f01011e0:	68 9b 75 10 f0       	push   $0xf010759b
f01011e5:	68 72 03 00 00       	push   $0x372
f01011ea:	68 75 75 10 f0       	push   $0xf0107575
f01011ef:	e8 4c ee ff ff       	call   f0100040 <_panic>
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01011f4:	a1 64 82 23 f0       	mov    0xf0238264,%eax
f01011f9:	85 c0                	test   %eax,%eax
f01011fb:	0f 85 44 fd ff ff    	jne    f0100f45 <check_page_free_list+0x32>
f0101201:	e9 28 fd ff ff       	jmp    f0100f2e <check_page_free_list+0x1b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101206:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010120b:	75 9b                	jne    f01011a8 <check_page_free_list+0x295>
f010120d:	eb 80                	jmp    f010118f <check_page_free_list+0x27c>
f010120f:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101214:	75 97                	jne    f01011ad <check_page_free_list+0x29a>
f0101216:	e9 74 ff ff ff       	jmp    f010118f <check_page_free_list+0x27c>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f010121b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010121e:	5b                   	pop    %ebx
f010121f:	5e                   	pop    %esi
f0101220:	5f                   	pop    %edi
f0101221:	5d                   	pop    %ebp
f0101222:	c3                   	ret    

f0101223 <page_init>:
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
f0101223:	c7 05 64 82 23 f0 00 	movl   $0x0,0xf0238264
f010122a:	00 00 00 
	for (i = 0; i < npages; i++) {
f010122d:	83 3d a8 8e 23 f0 00 	cmpl   $0x0,0xf0238ea8
f0101234:	0f 85 92 00 00 00    	jne    f01012cc <page_init+0xa9>
			continue;
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f010123a:	c7 05 60 82 23 f0 00 	movl   $0x0,0xf0238260
f0101241:	00 00 00 
f0101244:	c3                   	ret    
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
		pages[i].pp_ref = 0;
f0101245:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f010124c:	a1 b0 8e 23 f0       	mov    0xf0238eb0,%eax
f0101251:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
		if (i == 0 || (i >= PGNUM(IOPHYSMEM) && i < PGNUM(PADDR(boot_alloc(0)))) || i == PGNUM(MPENTRY_PADDR)) {
f0101258:	85 db                	test   %ebx,%ebx
f010125a:	74 59                	je     f01012b5 <page_init+0x92>
f010125c:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0101262:	76 32                	jbe    f0101296 <page_init+0x73>
f0101264:	b8 00 00 00 00       	mov    $0x0,%eax
f0101269:	e8 1c fc ff ff       	call   f0100e8a <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010126e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101273:	77 15                	ja     f010128a <page_init+0x67>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101275:	50                   	push   %eax
f0101276:	68 e4 67 10 f0       	push   $0xf01067e4
f010127b:	68 47 01 00 00       	push   $0x147
f0101280:	68 75 75 10 f0       	push   $0xf0107575
f0101285:	e8 b6 ed ff ff       	call   f0100040 <_panic>
f010128a:	05 00 00 00 10       	add    $0x10000000,%eax
f010128f:	c1 e8 0c             	shr    $0xc,%eax
f0101292:	39 d8                	cmp    %ebx,%eax
f0101294:	77 1f                	ja     f01012b5 <page_init+0x92>
f0101296:	83 fb 07             	cmp    $0x7,%ebx
f0101299:	74 1a                	je     f01012b5 <page_init+0x92>
			continue;
		}
		pages[i].pp_link = page_free_list;
f010129b:	8b 15 64 82 23 f0    	mov    0xf0238264,%edx
f01012a1:	a1 b0 8e 23 f0       	mov    0xf0238eb0,%eax
f01012a6:	89 14 30             	mov    %edx,(%eax,%esi,1)
		page_free_list = &pages[i];
f01012a9:	03 35 b0 8e 23 f0    	add    0xf0238eb0,%esi
f01012af:	89 35 64 82 23 f0    	mov    %esi,0xf0238264
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
f01012b5:	83 c3 01             	add    $0x1,%ebx
f01012b8:	39 1d a8 8e 23 f0    	cmp    %ebx,0xf0238ea8
f01012be:	77 85                	ja     f0101245 <page_init+0x22>
			continue;
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f01012c0:	c7 05 60 82 23 f0 00 	movl   $0x0,0xf0238260
f01012c7:	00 00 00 
}
f01012ca:	eb 17                	jmp    f01012e3 <page_init+0xc0>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012cc:	55                   	push   %ebp
f01012cd:	89 e5                	mov    %esp,%ebp
f01012cf:	56                   	push   %esi
f01012d0:	53                   	push   %ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
		pages[i].pp_ref = 0;
f01012d1:	a1 b0 8e 23 f0       	mov    0xf0238eb0,%eax
f01012d6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
f01012dc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012e1:	eb d2                	jmp    f01012b5 <page_init+0x92>
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
}
f01012e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012e6:	5b                   	pop    %ebx
f01012e7:	5e                   	pop    %esi
f01012e8:	5d                   	pop    %ebp
f01012e9:	c3                   	ret    

f01012ea <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f01012ea:	55                   	push   %ebp
f01012eb:	89 e5                	mov    %esp,%ebp
f01012ed:	53                   	push   %ebx
f01012ee:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct Page *result = NULL;

	if (page_free_list) {
f01012f1:	8b 1d 64 82 23 f0    	mov    0xf0238264,%ebx
f01012f7:	85 db                	test   %ebx,%ebx
f01012f9:	74 58                	je     f0101353 <page_alloc+0x69>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f01012fb:	8b 03                	mov    (%ebx),%eax
f01012fd:	a3 64 82 23 f0       	mov    %eax,0xf0238264
		result->pp_link = NULL;
f0101302:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

		if (alloc_flags & ALLOC_ZERO) {
f0101308:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010130c:	74 45                	je     f0101353 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010130e:	89 d8                	mov    %ebx,%eax
f0101310:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0101316:	c1 f8 03             	sar    $0x3,%eax
f0101319:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010131c:	89 c2                	mov    %eax,%edx
f010131e:	c1 ea 0c             	shr    $0xc,%edx
f0101321:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f0101327:	72 12                	jb     f010133b <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101329:	50                   	push   %eax
f010132a:	68 c0 67 10 f0       	push   $0xf01067c0
f010132f:	6a 56                	push   $0x56
f0101331:	68 81 75 10 f0       	push   $0xf0107581
f0101336:	e8 05 ed ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f010133b:	83 ec 04             	sub    $0x4,%esp
f010133e:	68 00 10 00 00       	push   $0x1000
f0101343:	6a 00                	push   $0x0
f0101345:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010134a:	50                   	push   %eax
f010134b:	e8 9c 46 00 00       	call   f01059ec <memset>
f0101350:	83 c4 10             	add    $0x10,%esp
		}
	}

	return result;
}
f0101353:	89 d8                	mov    %ebx,%eax
f0101355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101358:	c9                   	leave  
f0101359:	c3                   	ret    

f010135a <page_alloc_npages_helper>:

// Helper fucntion for page_alloc_npages()
struct Page *
page_alloc_npages_helper(int alloc_flags, int n, struct Page* list)
{
f010135a:	55                   	push   %ebp
f010135b:	89 e5                	mov    %esp,%ebp
f010135d:	57                   	push   %edi
f010135e:	56                   	push   %esi
f010135f:	53                   	push   %ebx
f0101360:	83 ec 1c             	sub    $0x1c,%esp
f0101363:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Page* tmp = NULL;
	struct Page* result = NULL;
	struct Page* check = NULL;
	int cnt = n;

	if (list && n > 0) {
f0101366:	85 db                	test   %ebx,%ebx
f0101368:	0f 84 35 01 00 00    	je     f01014a3 <page_alloc_npages_helper+0x149>
f010136e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101372:	0f 8e 2b 01 00 00    	jle    f01014a3 <page_alloc_npages_helper+0x149>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101378:	a1 b0 8e 23 f0       	mov    0xf0238eb0,%eax
f010137d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101380:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101383:	89 d8                	mov    %ebx,%eax
f0101385:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
			if (!check->pp_link) {
f010138c:	8b 08                	mov    (%eax),%ecx
f010138e:	85 c9                	test   %ecx,%ecx
f0101390:	75 11                	jne    f01013a3 <page_alloc_npages_helper+0x49>
f0101392:	8b 5d 10             	mov    0x10(%ebp),%ebx
				// Out of memory
				if (cnt > 1) {
f0101395:	83 fe 01             	cmp    $0x1,%esi
f0101398:	0f 8e 21 01 00 00    	jle    f01014bf <page_alloc_npages_helper+0x165>
f010139e:	e9 07 01 00 00       	jmp    f01014aa <page_alloc_npages_helper+0x150>
					return NULL;
				}
			} else if ((page2pa(check) - page2pa(check->pp_link)) != PGSIZE) {
f01013a3:	89 c2                	mov    %eax,%edx
f01013a5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01013a8:	29 fa                	sub    %edi,%edx
f01013aa:	c1 fa 03             	sar    $0x3,%edx
f01013ad:	89 cb                	mov    %ecx,%ebx
f01013af:	29 fb                	sub    %edi,%ebx
f01013b1:	89 df                	mov    %ebx,%edi
f01013b3:	c1 ff 03             	sar    $0x3,%edi
f01013b6:	29 fa                	sub    %edi,%edx
f01013b8:	c1 e2 0c             	shl    $0xc,%edx
				tmp = check;	// Record junction
				result = check->pp_link;
				check = result;
				cnt = n;
f01013bb:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f01013c1:	0f 45 75 0c          	cmovne 0xc(%ebp),%esi
f01013c5:	89 cb                	mov    %ecx,%ebx
f01013c7:	0f 44 5d 10          	cmove  0x10(%ebp),%ebx
f01013cb:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01013ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01013d1:	0f 45 d8             	cmovne %eax,%ebx
f01013d4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01013d7:	0f 44 c8             	cmove  %eax,%ecx
	int cnt = n;

	if (list && n > 0) {
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
f01013da:	8b 01                	mov    (%ecx),%eax
f01013dc:	83 ee 01             	sub    $0x1,%esi
f01013df:	85 f6                	test   %esi,%esi
f01013e1:	7e 04                	jle    f01013e7 <page_alloc_npages_helper+0x8d>
f01013e3:	85 c0                	test   %eax,%eax
f01013e5:	75 a5                	jne    f010138c <page_alloc_npages_helper+0x32>
f01013e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01013ea:	89 c1                	mov    %eax,%ecx
				check = result;
				cnt = n;
			}
		}

		if (!cnt) {
f01013ec:	85 f6                	test   %esi,%esi
f01013ee:	0f 85 bd 00 00 00    	jne    f01014b1 <page_alloc_npages_helper+0x157>
			if (!tmp) {
f01013f4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01013f7:	85 f6                	test   %esi,%esi
f01013f9:	74 04                	je     f01013ff <page_alloc_npages_helper+0xa5>
				list = check->pp_link;
			} else {
				tmp->pp_link = check->pp_link;
f01013fb:	8b 01                	mov    (%ecx),%eax
f01013fd:	89 06                	mov    %eax,(%esi)
			}

			check->pp_link = NULL;
f01013ff:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

			if (alloc_flags & ALLOC_ZERO) {
f0101405:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101409:	74 27                	je     f0101432 <page_alloc_npages_helper+0xd8>
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f010140b:	85 db                	test   %ebx,%ebx
f010140d:	0f 84 a5 00 00 00    	je     f01014b8 <page_alloc_npages_helper+0x15e>
f0101413:	89 d8                	mov    %ebx,%eax
f0101415:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f010141b:	c1 f8 03             	sar    $0x3,%eax
f010141e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101421:	89 c2                	mov    %eax,%edx
f0101423:	c1 ea 0c             	shr    $0xc,%edx
f0101426:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f010142c:	73 2e                	jae    f010145c <page_alloc_npages_helper+0x102>
f010142e:	89 de                	mov    %ebx,%esi
f0101430:	eb 3c                	jmp    f010146e <page_alloc_npages_helper+0x114>

			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
f0101432:	b8 00 00 00 00       	mov    $0x0,%eax
f0101437:	85 db                	test   %ebx,%ebx
f0101439:	0f 84 88 00 00 00    	je     f01014c7 <page_alloc_npages_helper+0x16d>
f010143f:	eb 4b                	jmp    f010148c <page_alloc_npages_helper+0x132>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101441:	89 f0                	mov    %esi,%eax
f0101443:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0101449:	c1 f8 03             	sar    $0x3,%eax
f010144c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010144f:	89 c2                	mov    %eax,%edx
f0101451:	c1 ea 0c             	shr    $0xc,%edx
f0101454:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f010145a:	72 12                	jb     f010146e <page_alloc_npages_helper+0x114>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010145c:	50                   	push   %eax
f010145d:	68 c0 67 10 f0       	push   $0xf01067c0
f0101462:	6a 56                	push   $0x56
f0101464:	68 81 75 10 f0       	push   $0xf0107581
f0101469:	e8 d2 eb ff ff       	call   f0100040 <_panic>

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
					memset(page2kva(tmp), 0, PGSIZE);
f010146e:	83 ec 04             	sub    $0x4,%esp
f0101471:	68 00 10 00 00       	push   $0x1000
f0101476:	6a 00                	push   $0x0
f0101478:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010147d:	50                   	push   %eax
f010147e:	e8 69 45 00 00       	call   f01059ec <memset>
			}

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f0101483:	8b 36                	mov    (%esi),%esi
f0101485:	83 c4 10             	add    $0x10,%esp
f0101488:	85 f6                	test   %esi,%esi
f010148a:	75 b5                	jne    f0101441 <page_alloc_npages_helper+0xe7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010148c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101491:	eb 02                	jmp    f0101495 <page_alloc_npages_helper+0x13b>
			tmp = result;
			while(tmp) {
				rear = tmp->pp_link;
				tmp->pp_link = head;
				head = tmp;
				tmp = rear;
f0101493:	89 c3                	mov    %eax,%ebx
			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
				rear = tmp->pp_link;
f0101495:	8b 03                	mov    (%ebx),%eax
				tmp->pp_link = head;
f0101497:	89 13                	mov    %edx,(%ebx)
f0101499:	89 da                	mov    %ebx,%edx

			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
f010149b:	85 c0                	test   %eax,%eax
f010149d:	75 f4                	jne    f0101493 <page_alloc_npages_helper+0x139>
f010149f:	89 d8                	mov    %ebx,%eax
f01014a1:	eb 24                	jmp    f01014c7 <page_alloc_npages_helper+0x16d>
		} else {
			return NULL;
		}
	}

	return result;
f01014a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01014a8:	eb 1d                	jmp    f01014c7 <page_alloc_npages_helper+0x16d>

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
			if (!check->pp_link) {
				// Out of memory
				if (cnt > 1) {
					return NULL;
f01014aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01014af:	eb 16                	jmp    f01014c7 <page_alloc_npages_helper+0x16d>
				tmp = rear;
			}

			return head;
		} else {
			return NULL;
f01014b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01014b6:	eb 0f                	jmp    f01014c7 <page_alloc_npages_helper+0x16d>
			}

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f01014b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01014bd:	eb 08                	jmp    f01014c7 <page_alloc_npages_helper+0x16d>
	int cnt = n;

	if (list && n > 0) {
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
f01014bf:	83 ee 01             	sub    $0x1,%esi
f01014c2:	e9 25 ff ff ff       	jmp    f01013ec <page_alloc_npages_helper+0x92>
			return NULL;
		}
	}

	return result;
}
f01014c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014ca:	5b                   	pop    %ebx
f01014cb:	5e                   	pop    %esi
f01014cc:	5f                   	pop    %edi
f01014cd:	5d                   	pop    %ebp
f01014ce:	c3                   	ret    

f01014cf <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f01014cf:	55                   	push   %ebp
f01014d0:	89 e5                	mov    %esp,%ebp
f01014d2:	56                   	push   %esi
f01014d3:	53                   	push   %ebx
f01014d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01014d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function
	if (n == 1) {
f01014da:	83 fb 01             	cmp    $0x1,%ebx
f01014dd:	75 0e                	jne    f01014ed <page_alloc_npages+0x1e>
		return page_alloc(alloc_flags);
f01014df:	83 ec 0c             	sub    $0xc,%esp
f01014e2:	56                   	push   %esi
f01014e3:	e8 02 fe ff ff       	call   f01012ea <page_alloc>
f01014e8:	83 c4 10             	add    $0x10,%esp
f01014eb:	eb 2a                	jmp    f0101517 <page_alloc_npages+0x48>
	}

	struct Page* result;
	if (!(result = page_alloc_npages_helper(alloc_flags, n, chunk_list))) {
f01014ed:	83 ec 04             	sub    $0x4,%esp
f01014f0:	ff 35 60 82 23 f0    	pushl  0xf0238260
f01014f6:	53                   	push   %ebx
f01014f7:	56                   	push   %esi
f01014f8:	e8 5d fe ff ff       	call   f010135a <page_alloc_npages_helper>
f01014fd:	83 c4 10             	add    $0x10,%esp
f0101500:	85 c0                	test   %eax,%eax
f0101502:	75 13                	jne    f0101517 <page_alloc_npages+0x48>
		result = page_alloc_npages_helper(alloc_flags, n, page_free_list);
f0101504:	83 ec 04             	sub    $0x4,%esp
f0101507:	ff 35 64 82 23 f0    	pushl  0xf0238264
f010150d:	53                   	push   %ebx
f010150e:	56                   	push   %esi
f010150f:	e8 46 fe ff ff       	call   f010135a <page_alloc_npages_helper>
f0101514:	83 c4 10             	add    $0x10,%esp
	}

	return result;
}
f0101517:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010151a:	5b                   	pop    %ebx
f010151b:	5e                   	pop    %esi
f010151c:	5d                   	pop    %ebp
f010151d:	c3                   	ret    

f010151e <page_free_npages>:
//	2. Add the pages to the chunk list
//
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f010151e:	55                   	push   %ebp
f010151f:	89 e5                	mov    %esp,%ebp
f0101521:	53                   	push   %ebx
f0101522:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function
	if (!check_continuous(pp, n)) {
f0101525:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101528:	89 d8                	mov    %ebx,%eax
f010152a:	e8 69 f8 ff ff       	call   f0100d98 <check_continuous>
f010152f:	85 c0                	test   %eax,%eax
f0101531:	74 20                	je     f0101553 <page_free_npages+0x35>
		return -1;
	}

	if (chunk_list->pp_link == NULL) {
f0101533:	a1 60 82 23 f0       	mov    0xf0238260,%eax
f0101538:	8b 10                	mov    (%eax),%edx
f010153a:	85 d2                	test   %edx,%edx
f010153c:	75 0b                	jne    f0101549 <page_free_npages+0x2b>
		chunk_list->pp_link = pp;
f010153e:	89 18                	mov    %ebx,(%eax)
			;

		tmp->pp_link = pp;
	}

	return 0;
f0101540:	b8 00 00 00 00       	mov    $0x0,%eax
f0101545:	eb 11                	jmp    f0101558 <page_free_npages+0x3a>
	if (chunk_list->pp_link == NULL) {
		chunk_list->pp_link = pp;
	} else {
		struct Page* tmp = chunk_list->pp_link;

		for (; tmp->pp_link; tmp = tmp->pp_link)
f0101547:	89 c2                	mov    %eax,%edx
f0101549:	8b 02                	mov    (%edx),%eax
f010154b:	85 c0                	test   %eax,%eax
f010154d:	75 f8                	jne    f0101547 <page_free_npages+0x29>
			;

		tmp->pp_link = pp;
f010154f:	89 1a                	mov    %ebx,(%edx)
f0101551:	eb 05                	jmp    f0101558 <page_free_npages+0x3a>
int
page_free_npages(struct Page *pp, int n)
{
	// Fill this function
	if (!check_continuous(pp, n)) {
		return -1;
f0101553:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

		tmp->pp_link = pp;
	}

	return 0;
}
f0101558:	5b                   	pop    %ebx
f0101559:	5d                   	pop    %ebp
f010155a:	c3                   	ret    

f010155b <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f010155b:	55                   	push   %ebp
f010155c:	89 e5                	mov    %esp,%ebp
f010155e:	83 ec 08             	sub    $0x8,%esp
f0101561:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if (!pp->pp_ref) {
f0101564:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101569:	75 0f                	jne    f010157a <page_free+0x1f>
		pp->pp_link = page_free_list;
f010156b:	8b 15 64 82 23 f0    	mov    0xf0238264,%edx
f0101571:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0101573:	a3 64 82 23 f0       	mov    %eax,0xf0238264
f0101578:	eb 10                	jmp    f010158a <page_free+0x2f>
	} else {
		cprintf("Page free error! pp_ref is not 0!");
f010157a:	83 ec 0c             	sub    $0xc,%esp
f010157d:	68 18 6f 10 f0       	push   $0xf0106f18
f0101582:	e8 0d 29 00 00       	call   f0103e94 <cprintf>
f0101587:	83 c4 10             	add    $0x10,%esp
	}
}
f010158a:	c9                   	leave  
f010158b:	c3                   	ret    

f010158c <page_realloc_npages>:
//
#define check_invalid(i) (i == 0 || (i >= IOPHYSMEM && i < PADDR(boot_alloc(0))))

struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f010158c:	55                   	push   %ebp
f010158d:	89 e5                	mov    %esp,%ebp
f010158f:	57                   	push   %edi
f0101590:	56                   	push   %esi
f0101591:	53                   	push   %ebx
f0101592:	83 ec 1c             	sub    $0x1c,%esp
f0101595:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101598:	8b 4d 10             	mov    0x10(%ebp),%ecx
	// Fill this function
	if (!new_n) {
f010159b:	85 c9                	test   %ecx,%ecx
f010159d:	75 16                	jne    f01015b5 <page_realloc_npages+0x29>
		page_free_npages(pp, old_n);
f010159f:	ff 75 0c             	pushl  0xc(%ebp)
f01015a2:	53                   	push   %ebx
f01015a3:	e8 76 ff ff ff       	call   f010151e <page_free_npages>
f01015a8:	83 c4 08             	add    $0x8,%esp
		pp = NULL;
f01015ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01015b0:	e9 b9 01 00 00       	jmp    f010176e <page_realloc_npages+0x1e2>
	} else if (old_n > new_n) {
f01015b5:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
f01015b8:	7d 28                	jge    f01015e2 <page_realloc_npages+0x56>
		page_free_npages(pp + new_n, old_n - new_n);
f01015ba:	8d 34 cd 00 00 00 00 	lea    0x0(,%ecx,8),%esi
f01015c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015c4:	29 c8                	sub    %ecx,%eax
f01015c6:	50                   	push   %eax
f01015c7:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f01015ca:	50                   	push   %eax
f01015cb:	e8 4e ff ff ff       	call   f010151e <page_free_npages>
		(pp + new_n - 1)->pp_link = NULL;
f01015d0:	c7 44 33 f8 00 00 00 	movl   $0x0,-0x8(%ebx,%esi,1)
f01015d7:	00 
f01015d8:	83 c4 08             	add    $0x8,%esp
f01015db:	89 d8                	mov    %ebx,%eax
f01015dd:	e9 8c 01 00 00       	jmp    f010176e <page_realloc_npages+0x1e2>
	} else if (old_n < new_n) {
f01015e2:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
f01015e5:	0f 8e 81 01 00 00    	jle    f010176c <page_realloc_npages+0x1e0>
		int i = 0;

		for (i = old_n; i < new_n; i++) {
			if (!(pp + i < pages + npages	&& (pp + i)->pp_ref == 0)) {//|| check_invalid(PGNUM(pp + i))
f01015eb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ee:	c1 e0 03             	shl    $0x3,%eax
f01015f1:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
f01015f4:	8b 15 b0 8e 23 f0    	mov    0xf0238eb0,%edx
f01015fa:	8b 35 a8 8e 23 f0    	mov    0xf0238ea8,%esi
f0101600:	8d 34 f2             	lea    (%edx,%esi,8),%esi
f0101603:	39 f7                	cmp    %esi,%edi
f0101605:	73 2d                	jae    f0101634 <page_realloc_npages+0xa8>
f0101607:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010160c:	75 26                	jne    f0101634 <page_realloc_npages+0xa8>
f010160e:	8d 44 03 08          	lea    0x8(%ebx,%eax,1),%eax
f0101612:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101615:	eb 0e                	jmp    f0101625 <page_realloc_npages+0x99>
f0101617:	39 c6                	cmp    %eax,%esi
f0101619:	76 19                	jbe    f0101634 <page_realloc_npages+0xa8>
f010161b:	83 c0 08             	add    $0x8,%eax
f010161e:	66 83 78 fc 00       	cmpw   $0x0,-0x4(%eax)
f0101623:	75 0f                	jne    f0101634 <page_realloc_npages+0xa8>
		page_free_npages(pp + new_n, old_n - new_n);
		(pp + new_n - 1)->pp_link = NULL;
	} else if (old_n < new_n) {
		int i = 0;

		for (i = old_n; i < new_n; i++) {
f0101625:	83 c2 01             	add    $0x1,%edx
f0101628:	39 d1                	cmp    %edx,%ecx
f010162a:	7f eb                	jg     f0101617 <page_realloc_npages+0x8b>
			if (!(pp + i < pages + npages	&& (pp + i)->pp_ref == 0)) {//|| check_invalid(PGNUM(pp + i))
				break;
			}
		}

		if (i != new_n) {
f010162c:	39 d1                	cmp    %edx,%ecx
f010162e:	0f 84 9b 00 00 00    	je     f01016cf <page_realloc_npages+0x143>
			struct Page* new_pp = page_alloc_npages(ALLOC_ZERO, new_n);
f0101634:	83 ec 08             	sub    $0x8,%esp
f0101637:	51                   	push   %ecx
f0101638:	6a 01                	push   $0x1
f010163a:	e8 90 fe ff ff       	call   f01014cf <page_alloc_npages>
f010163f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			memmove(page2kva(new_pp), page2kva(pp), old_n * PGSIZE);
f0101642:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101645:	c1 e7 0c             	shl    $0xc,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101648:	8b 35 b0 8e 23 f0    	mov    0xf0238eb0,%esi
f010164e:	89 d8                	mov    %ebx,%eax
f0101650:	29 f0                	sub    %esi,%eax
f0101652:	c1 f8 03             	sar    $0x3,%eax
f0101655:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101658:	8b 0d a8 8e 23 f0    	mov    0xf0238ea8,%ecx
f010165e:	89 c2                	mov    %eax,%edx
f0101660:	c1 ea 0c             	shr    $0xc,%edx
f0101663:	83 c4 10             	add    $0x10,%esp
f0101666:	39 ca                	cmp    %ecx,%edx
f0101668:	72 12                	jb     f010167c <page_realloc_npages+0xf0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010166a:	50                   	push   %eax
f010166b:	68 c0 67 10 f0       	push   $0xf01067c0
f0101670:	6a 56                	push   $0x56
f0101672:	68 81 75 10 f0       	push   $0xf0107581
f0101677:	e8 c4 e9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010167c:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101682:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101685:	29 f0                	sub    %esi,%eax
f0101687:	c1 f8 03             	sar    $0x3,%eax
f010168a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010168d:	89 c6                	mov    %eax,%esi
f010168f:	c1 ee 0c             	shr    $0xc,%esi
f0101692:	39 ce                	cmp    %ecx,%esi
f0101694:	72 12                	jb     f01016a8 <page_realloc_npages+0x11c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101696:	50                   	push   %eax
f0101697:	68 c0 67 10 f0       	push   $0xf01067c0
f010169c:	6a 56                	push   $0x56
f010169e:	68 81 75 10 f0       	push   $0xf0107581
f01016a3:	e8 98 e9 ff ff       	call   f0100040 <_panic>
f01016a8:	83 ec 04             	sub    $0x4,%esp
f01016ab:	57                   	push   %edi
f01016ac:	52                   	push   %edx
f01016ad:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016b2:	50                   	push   %eax
f01016b3:	e8 81 43 00 00       	call   f0105a39 <memmove>
			page_free_npages(pp, old_n);
f01016b8:	83 c4 08             	add    $0x8,%esp
f01016bb:	ff 75 0c             	pushl  0xc(%ebp)
f01016be:	53                   	push   %ebx
f01016bf:	e8 5a fe ff ff       	call   f010151e <page_free_npages>
			return new_pp;
f01016c4:	83 c4 10             	add    $0x10,%esp
f01016c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01016ca:	e9 9f 00 00 00       	jmp    f010176e <page_realloc_npages+0x1e2>
		} else {
			struct Page* tmp = page_free_list;
f01016cf:	a1 64 82 23 f0       	mov    0xf0238264,%eax
			for (; tmp >= pp && tmp < pp + new_n; tmp = tmp->pp_link)
f01016d4:	39 c3                	cmp    %eax,%ebx
f01016d6:	77 11                	ja     f01016e9 <page_realloc_npages+0x15d>
f01016d8:	8d 0c d3             	lea    (%ebx,%edx,8),%ecx
f01016db:	39 c8                	cmp    %ecx,%eax
f01016dd:	73 0a                	jae    f01016e9 <page_realloc_npages+0x15d>
f01016df:	8b 00                	mov    (%eax),%eax
f01016e1:	39 c3                	cmp    %eax,%ebx
f01016e3:	77 04                	ja     f01016e9 <page_realloc_npages+0x15d>
f01016e5:	39 c8                	cmp    %ecx,%eax
f01016e7:	72 f6                	jb     f01016df <page_realloc_npages+0x153>
				;
			page_free_list = tmp;
f01016e9:	a3 64 82 23 f0       	mov    %eax,0xf0238264

			for (; tmp && tmp->pp_link; tmp = tmp->pp_link) {
f01016ee:	85 c0                	test   %eax,%eax
f01016f0:	74 21                	je     f0101713 <page_realloc_npages+0x187>
f01016f2:	8b 08                	mov    (%eax),%ecx
f01016f4:	85 c9                	test   %ecx,%ecx
f01016f6:	74 1b                	je     f0101713 <page_realloc_npages+0x187>
				if (tmp->pp_link >= pp && tmp->pp_link < pp + new_n) {
f01016f8:	8d 34 d3             	lea    (%ebx,%edx,8),%esi
f01016fb:	39 cb                	cmp    %ecx,%ebx
f01016fd:	77 08                	ja     f0101707 <page_realloc_npages+0x17b>
f01016ff:	39 ce                	cmp    %ecx,%esi
f0101701:	76 04                	jbe    f0101707 <page_realloc_npages+0x17b>
					tmp->pp_link = tmp->pp_link->pp_link;
f0101703:	8b 09                	mov    (%ecx),%ecx
f0101705:	89 08                	mov    %ecx,(%eax)
			struct Page* tmp = page_free_list;
			for (; tmp >= pp && tmp < pp + new_n; tmp = tmp->pp_link)
				;
			page_free_list = tmp;

			for (; tmp && tmp->pp_link; tmp = tmp->pp_link) {
f0101707:	8b 00                	mov    (%eax),%eax
f0101709:	85 c0                	test   %eax,%eax
f010170b:	74 06                	je     f0101713 <page_realloc_npages+0x187>
f010170d:	8b 08                	mov    (%eax),%ecx
f010170f:	85 c9                	test   %ecx,%ecx
f0101711:	75 e8                	jne    f01016fb <page_realloc_npages+0x16f>
				if (tmp->pp_link >= pp && tmp->pp_link < pp + new_n) {
					tmp->pp_link = tmp->pp_link->pp_link;
				}
			}

			for(tmp = pp, i = 0; i < old_n - 1; tmp = tmp->pp_link, i++ )
f0101713:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101716:	83 e8 01             	sub    $0x1,%eax
f0101719:	85 c0                	test   %eax,%eax
f010171b:	7e 18                	jle    f0101735 <page_realloc_npages+0x1a9>
f010171d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101720:	8d 70 ff             	lea    -0x1(%eax),%esi
f0101723:	89 d8                	mov    %ebx,%eax
f0101725:	b9 00 00 00 00       	mov    $0x0,%ecx
f010172a:	8b 00                	mov    (%eax),%eax
f010172c:	83 c1 01             	add    $0x1,%ecx
f010172f:	39 f1                	cmp    %esi,%ecx
f0101731:	75 f7                	jne    f010172a <page_realloc_npages+0x19e>
f0101733:	eb 02                	jmp    f0101737 <page_realloc_npages+0x1ab>
f0101735:	89 d8                	mov    %ebx,%eax
				;

			for (i = 0; i < new_n - old_n; i++) {
f0101737:	2b 55 0c             	sub    0xc(%ebp),%edx
f010173a:	85 d2                	test   %edx,%edx
f010173c:	7e 24                	jle    f0101762 <page_realloc_npages+0x1d6>
f010173e:	89 f9                	mov    %edi,%ecx
f0101740:	89 d6                	mov    %edx,%esi
f0101742:	03 75 0c             	add    0xc(%ebp),%esi
f0101745:	8d 3c f3             	lea    (%ebx,%esi,8),%edi
				tmp->pp_link = pp + old_n + i;
f0101748:	89 ce                	mov    %ecx,%esi
f010174a:	89 08                	mov    %ecx,(%eax)
f010174c:	83 c1 08             	add    $0x8,%ecx
f010174f:	89 f0                	mov    %esi,%eax
			}

			for(tmp = pp, i = 0; i < old_n - 1; tmp = tmp->pp_link, i++ )
				;

			for (i = 0; i < new_n - old_n; i++) {
f0101751:	39 f9                	cmp    %edi,%ecx
f0101753:	75 f3                	jne    f0101748 <page_realloc_npages+0x1bc>
f0101755:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101758:	8d 84 02 ff ff ff 1f 	lea    0x1fffffff(%edx,%eax,1),%eax
f010175f:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
				tmp->pp_link = pp + old_n + i;
				tmp = tmp->pp_link;
			}
			tmp->pp_link = NULL;
f0101762:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

			return pp;
f0101768:	89 d8                	mov    %ebx,%eax
f010176a:	eb 02                	jmp    f010176e <page_realloc_npages+0x1e2>
f010176c:	89 d8                	mov    %ebx,%eax
		}
	}

	return pp;
}
f010176e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101771:	5b                   	pop    %ebx
f0101772:	5e                   	pop    %esi
f0101773:	5f                   	pop    %edi
f0101774:	5d                   	pop    %ebp
f0101775:	c3                   	ret    

f0101776 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101776:	55                   	push   %ebp
f0101777:	89 e5                	mov    %esp,%ebp
f0101779:	83 ec 08             	sub    $0x8,%esp
f010177c:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010177f:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101783:	83 e8 01             	sub    $0x1,%eax
f0101786:	66 89 42 04          	mov    %ax,0x4(%edx)
f010178a:	66 85 c0             	test   %ax,%ax
f010178d:	75 0c                	jne    f010179b <page_decref+0x25>
		page_free(pp);
f010178f:	83 ec 0c             	sub    $0xc,%esp
f0101792:	52                   	push   %edx
f0101793:	e8 c3 fd ff ff       	call   f010155b <page_free>
f0101798:	83 c4 10             	add    $0x10,%esp
}
f010179b:	c9                   	leave  
f010179c:	c3                   	ret    

f010179d <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010179d:	55                   	push   %ebp
f010179e:	89 e5                	mov    %esp,%ebp
f01017a0:	56                   	push   %esi
f01017a1:	53                   	push   %ebx
f01017a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01017a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	if (!pgdir) {
f01017a8:	85 c0                	test   %eax,%eax
f01017aa:	75 1a                	jne    f01017c6 <pgdir_walk+0x29>
		cprintf("pgdir no exists.\n");
f01017ac:	83 ec 0c             	sub    $0xc,%esp
f01017af:	68 48 76 10 f0       	push   $0xf0107648
f01017b4:	e8 db 26 00 00       	call   f0103e94 <cprintf>
		return NULL;
f01017b9:	83 c4 10             	add    $0x10,%esp
f01017bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01017c1:	e9 bb 00 00 00       	jmp    f0101881 <pgdir_walk+0xe4>
	}

	pde_t *pde = pgdir + PDX(va);
f01017c6:	89 da                	mov    %ebx,%edx
f01017c8:	c1 ea 16             	shr    $0x16,%edx
f01017cb:	8d 34 90             	lea    (%eax,%edx,4),%esi
	pte_t *page_table;

	if (*pde & PTE_P) {
f01017ce:	8b 06                	mov    (%esi),%eax
f01017d0:	a8 01                	test   $0x1,%al
f01017d2:	74 39                	je     f010180d <pgdir_walk+0x70>
		page_table = (pte_t *)KADDR(PTE_ADDR(*pde));
f01017d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017d9:	89 c2                	mov    %eax,%edx
f01017db:	c1 ea 0c             	shr    $0xc,%edx
f01017de:	39 15 a8 8e 23 f0    	cmp    %edx,0xf0238ea8
f01017e4:	77 15                	ja     f01017fb <pgdir_walk+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017e6:	50                   	push   %eax
f01017e7:	68 c0 67 10 f0       	push   $0xf01067c0
f01017ec:	68 5c 02 00 00       	push   $0x25c
f01017f1:	68 75 75 10 f0       	push   $0xf0107575
f01017f6:	e8 45 e8 ff ff       	call   f0100040 <_panic>
		return page_table + PTX(va);
f01017fb:	c1 eb 0a             	shr    $0xa,%ebx
f01017fe:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101804:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f010180b:	eb 74                	jmp    f0101881 <pgdir_walk+0xe4>
	}

	struct Page *page;
	if (create && (page = page_alloc(ALLOC_ZERO))) {
f010180d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101811:	74 62                	je     f0101875 <pgdir_walk+0xd8>
f0101813:	83 ec 0c             	sub    $0xc,%esp
f0101816:	6a 01                	push   $0x1
f0101818:	e8 cd fa ff ff       	call   f01012ea <page_alloc>
f010181d:	83 c4 10             	add    $0x10,%esp
f0101820:	85 c0                	test   %eax,%eax
f0101822:	74 58                	je     f010187c <pgdir_walk+0xdf>
		page->pp_ref++;
f0101824:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101829:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f010182f:	c1 f8 03             	sar    $0x3,%eax
f0101832:	c1 e0 0c             	shl    $0xc,%eax
		*pde = page2pa(page) | PTE_P | PTE_W | PTE_U;
f0101835:	89 c2                	mov    %eax,%edx
f0101837:	83 ca 07             	or     $0x7,%edx
f010183a:	89 16                	mov    %edx,(%esi)
f010183c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101841:	89 c2                	mov    %eax,%edx
f0101843:	c1 ea 0c             	shr    $0xc,%edx
f0101846:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f010184c:	72 15                	jb     f0101863 <pgdir_walk+0xc6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010184e:	50                   	push   %eax
f010184f:	68 c0 67 10 f0       	push   $0xf01067c0
f0101854:	68 64 02 00 00       	push   $0x264
f0101859:	68 75 75 10 f0       	push   $0xf0107575
f010185e:	e8 dd e7 ff ff       	call   f0100040 <_panic>
		page_table = (pte_t *)KADDR(PTE_ADDR(*pde));
		return page_table + PTX(va);
f0101863:	c1 eb 0a             	shr    $0xa,%ebx
f0101866:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010186c:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101873:	eb 0c                	jmp    f0101881 <pgdir_walk+0xe4>
	}

	return NULL;
f0101875:	b8 00 00 00 00       	mov    $0x0,%eax
f010187a:	eb 05                	jmp    f0101881 <pgdir_walk+0xe4>
f010187c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101881:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101884:	5b                   	pop    %ebx
f0101885:	5e                   	pop    %esi
f0101886:	5d                   	pop    %ebp
f0101887:	c3                   	ret    

f0101888 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101888:	55                   	push   %ebp
f0101889:	89 e5                	mov    %esp,%ebp
f010188b:	57                   	push   %edi
f010188c:	56                   	push   %esi
f010188d:	53                   	push   %ebx
f010188e:	83 ec 1c             	sub    $0x1c,%esp
	// Fill this function in
	size_t num = size / PGSIZE;
f0101891:	c1 e9 0c             	shr    $0xc,%ecx
f0101894:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	size_t i;

	for (i = 0; i < num; i++) {
f0101897:	85 c9                	test   %ecx,%ecx
f0101899:	74 45                	je     f01018e0 <boot_map_region+0x58>
f010189b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010189e:	89 d3                	mov    %edx,%ebx
f01018a0:	bf 00 00 00 00       	mov    $0x0,%edi
f01018a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01018a8:	29 d0                	sub    %edx,%eax
f01018aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa | perm | PTE_P;
f01018ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018b0:	83 c8 01             	or     $0x1,%eax
f01018b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01018b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01018b9:	8d 34 18             	lea    (%eax,%ebx,1),%esi
	// Fill this function in
	size_t num = size / PGSIZE;
	size_t i;

	for (i = 0; i < num; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01018bc:	83 ec 04             	sub    $0x4,%esp
f01018bf:	6a 01                	push   $0x1
f01018c1:	53                   	push   %ebx
f01018c2:	ff 75 d8             	pushl  -0x28(%ebp)
f01018c5:	e8 d3 fe ff ff       	call   f010179d <pgdir_walk>
		*pte = pa | perm | PTE_P;
f01018ca:	0b 75 dc             	or     -0x24(%ebp),%esi
f01018cd:	89 30                	mov    %esi,(%eax)
		va += PGSIZE;
f01018cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// Fill this function in
	size_t num = size / PGSIZE;
	size_t i;

	for (i = 0; i < num; i++) {
f01018d5:	83 c7 01             	add    $0x1,%edi
f01018d8:	83 c4 10             	add    $0x10,%esp
f01018db:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
f01018de:	75 d6                	jne    f01018b6 <boot_map_region+0x2e>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f01018e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01018e3:	5b                   	pop    %ebx
f01018e4:	5e                   	pop    %esi
f01018e5:	5f                   	pop    %edi
f01018e6:	5d                   	pop    %ebp
f01018e7:	c3                   	ret    

f01018e8 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01018e8:	55                   	push   %ebp
f01018e9:	89 e5                	mov    %esp,%ebp
f01018eb:	53                   	push   %ebx
f01018ec:	83 ec 08             	sub    $0x8,%esp
f01018ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01018f2:	6a 00                	push   $0x0
f01018f4:	ff 75 0c             	pushl  0xc(%ebp)
f01018f7:	ff 75 08             	pushl  0x8(%ebp)
f01018fa:	e8 9e fe ff ff       	call   f010179d <pgdir_walk>
	if (pte && (*pte & PTE_P)) {
f01018ff:	83 c4 10             	add    $0x10,%esp
f0101902:	85 c0                	test   %eax,%eax
f0101904:	74 37                	je     f010193d <page_lookup+0x55>
f0101906:	f6 00 01             	testb  $0x1,(%eax)
f0101909:	74 39                	je     f0101944 <page_lookup+0x5c>
		if (pte_store) {
f010190b:	85 db                	test   %ebx,%ebx
f010190d:	74 02                	je     f0101911 <page_lookup+0x29>
			*pte_store = pte;
f010190f:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101911:	8b 00                	mov    (%eax),%eax
f0101913:	c1 e8 0c             	shr    $0xc,%eax
f0101916:	3b 05 a8 8e 23 f0    	cmp    0xf0238ea8,%eax
f010191c:	72 14                	jb     f0101932 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010191e:	83 ec 04             	sub    $0x4,%esp
f0101921:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0101926:	6a 4f                	push   $0x4f
f0101928:	68 81 75 10 f0       	push   $0xf0107581
f010192d:	e8 0e e7 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101932:	8b 15 b0 8e 23 f0    	mov    0xf0238eb0,%edx
f0101938:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		}
		return pa2page(PTE_ADDR(*pte));
f010193b:	eb 0c                	jmp    f0101949 <page_lookup+0x61>
	}

	return NULL;
f010193d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101942:	eb 05                	jmp    f0101949 <page_lookup+0x61>
f0101944:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101949:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010194c:	c9                   	leave  
f010194d:	c3                   	ret    

f010194e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010194e:	55                   	push   %ebp
f010194f:	89 e5                	mov    %esp,%ebp
f0101951:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101954:	e8 0e 47 00 00       	call   f0106067 <cpunum>
f0101959:	6b c0 74             	imul   $0x74,%eax,%eax
f010195c:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f0101963:	74 16                	je     f010197b <tlb_invalidate+0x2d>
f0101965:	e8 fd 46 00 00       	call   f0106067 <cpunum>
f010196a:	6b c0 74             	imul   $0x74,%eax,%eax
f010196d:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0101973:	8b 55 08             	mov    0x8(%ebp),%edx
f0101976:	39 50 64             	cmp    %edx,0x64(%eax)
f0101979:	75 06                	jne    f0101981 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010197b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010197e:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101981:	c9                   	leave  
f0101982:	c3                   	ret    

f0101983 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101983:	55                   	push   %ebp
f0101984:	89 e5                	mov    %esp,%ebp
f0101986:	57                   	push   %edi
f0101987:	56                   	push   %esi
f0101988:	53                   	push   %ebx
f0101989:	83 ec 20             	sub    $0x20,%esp
f010198c:	8b 75 08             	mov    0x8(%ebp),%esi
f010198f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t *pte;
	struct Page *page = page_lookup(pgdir, va, &pte);
f0101992:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101995:	50                   	push   %eax
f0101996:	57                   	push   %edi
f0101997:	56                   	push   %esi
f0101998:	e8 4b ff ff ff       	call   f01018e8 <page_lookup>
	if (page) {
f010199d:	83 c4 10             	add    $0x10,%esp
f01019a0:	85 c0                	test   %eax,%eax
f01019a2:	74 20                	je     f01019c4 <page_remove+0x41>
f01019a4:	89 c3                	mov    %eax,%ebx
		*pte = 0;
f01019a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01019a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f01019af:	83 ec 08             	sub    $0x8,%esp
f01019b2:	57                   	push   %edi
f01019b3:	56                   	push   %esi
f01019b4:	e8 95 ff ff ff       	call   f010194e <tlb_invalidate>
		page_decref(page);
f01019b9:	89 1c 24             	mov    %ebx,(%esp)
f01019bc:	e8 b5 fd ff ff       	call   f0101776 <page_decref>
f01019c1:	83 c4 10             	add    $0x10,%esp
	}
}
f01019c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01019c7:	5b                   	pop    %ebx
f01019c8:	5e                   	pop    %esi
f01019c9:	5f                   	pop    %edi
f01019ca:	5d                   	pop    %ebp
f01019cb:	c3                   	ret    

f01019cc <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01019cc:	55                   	push   %ebp
f01019cd:	89 e5                	mov    %esp,%ebp
f01019cf:	57                   	push   %edi
f01019d0:	56                   	push   %esi
f01019d1:	53                   	push   %ebx
f01019d2:	83 ec 10             	sub    $0x10,%esp
f01019d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01019d8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01019db:	6a 01                	push   $0x1
f01019dd:	57                   	push   %edi
f01019de:	ff 75 08             	pushl  0x8(%ebp)
f01019e1:	e8 b7 fd ff ff       	call   f010179d <pgdir_walk>

	if (pte && (*pte & PTE_P)) {
f01019e6:	83 c4 10             	add    $0x10,%esp
f01019e9:	85 c0                	test   %eax,%eax
f01019eb:	74 68                	je     f0101a55 <page_insert+0x89>
f01019ed:	89 c6                	mov    %eax,%esi
f01019ef:	8b 00                	mov    (%eax),%eax
f01019f1:	a8 01                	test   $0x1,%al
f01019f3:	74 3c                	je     f0101a31 <page_insert+0x65>
		if (page2pa(pp) == PTE_ADDR(*pte)) {
f01019f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01019fa:	89 da                	mov    %ebx,%edx
f01019fc:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f0101a02:	c1 fa 03             	sar    $0x3,%edx
f0101a05:	c1 e2 0c             	shl    $0xc,%edx
f0101a08:	39 d0                	cmp    %edx,%eax
f0101a0a:	75 16                	jne    f0101a22 <page_insert+0x56>
			tlb_invalidate(pgdir, va);
f0101a0c:	83 ec 08             	sub    $0x8,%esp
f0101a0f:	57                   	push   %edi
f0101a10:	ff 75 08             	pushl  0x8(%ebp)
f0101a13:	e8 36 ff ff ff       	call   f010194e <tlb_invalidate>
			pp->pp_ref--;
f0101a18:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101a1d:	83 c4 10             	add    $0x10,%esp
f0101a20:	eb 0f                	jmp    f0101a31 <page_insert+0x65>
		} else {
			page_remove(pgdir, va);
f0101a22:	83 ec 08             	sub    $0x8,%esp
f0101a25:	57                   	push   %edi
f0101a26:	ff 75 08             	pushl  0x8(%ebp)
f0101a29:	e8 55 ff ff ff       	call   f0101983 <page_remove>
f0101a2e:	83 c4 10             	add    $0x10,%esp
		}
	} else if (!pte) {
		return -E_NO_MEM;
	}
	*pte = page2pa(pp) | perm | PTE_P;
f0101a31:	89 d8                	mov    %ebx,%eax
f0101a33:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0101a39:	c1 f8 03             	sar    $0x3,%eax
f0101a3c:	c1 e0 0c             	shl    $0xc,%eax
f0101a3f:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a42:	83 ca 01             	or     $0x1,%edx
f0101a45:	09 d0                	or     %edx,%eax
f0101a47:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f0101a49:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101a4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a53:	eb 05                	jmp    f0101a5a <page_insert+0x8e>
			pp->pp_ref--;
		} else {
			page_remove(pgdir, va);
		}
	} else if (!pte) {
		return -E_NO_MEM;
f0101a55:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref++;

	return 0;
}
f0101a5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a5d:	5b                   	pop    %ebx
f0101a5e:	5e                   	pop    %esi
f0101a5f:	5f                   	pop    %edi
f0101a60:	5d                   	pop    %ebp
f0101a61:	c3                   	ret    

f0101a62 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101a62:	55                   	push   %ebp
f0101a63:	89 e5                	mov    %esp,%ebp
f0101a65:	57                   	push   %edi
f0101a66:	56                   	push   %esi
f0101a67:	53                   	push   %ebx
f0101a68:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101a6b:	6a 15                	push   $0x15
f0101a6d:	e8 a0 22 00 00       	call   f0103d12 <mc146818_read>
f0101a72:	89 c3                	mov    %eax,%ebx
f0101a74:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101a7b:	e8 92 22 00 00       	call   f0103d12 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101a80:	c1 e0 08             	shl    $0x8,%eax
f0101a83:	09 d8                	or     %ebx,%eax
f0101a85:	c1 e0 0a             	shl    $0xa,%eax
f0101a88:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101a8e:	85 c0                	test   %eax,%eax
f0101a90:	0f 48 c2             	cmovs  %edx,%eax
f0101a93:	c1 f8 0c             	sar    $0xc,%eax
f0101a96:	a3 68 82 23 f0       	mov    %eax,0xf0238268
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101a9b:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101aa2:	e8 6b 22 00 00       	call   f0103d12 <mc146818_read>
f0101aa7:	89 c3                	mov    %eax,%ebx
f0101aa9:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101ab0:	e8 5d 22 00 00       	call   f0103d12 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101ab5:	c1 e0 08             	shl    $0x8,%eax
f0101ab8:	09 d8                	or     %ebx,%eax
f0101aba:	c1 e0 0a             	shl    $0xa,%eax
f0101abd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101ac3:	83 c4 10             	add    $0x10,%esp
f0101ac6:	85 c0                	test   %eax,%eax
f0101ac8:	0f 48 c2             	cmovs  %edx,%eax
f0101acb:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101ace:	85 c0                	test   %eax,%eax
f0101ad0:	74 0e                	je     f0101ae0 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101ad2:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101ad8:	89 15 a8 8e 23 f0    	mov    %edx,0xf0238ea8
f0101ade:	eb 0c                	jmp    f0101aec <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101ae0:	8b 15 68 82 23 f0    	mov    0xf0238268,%edx
f0101ae6:	89 15 a8 8e 23 f0    	mov    %edx,0xf0238ea8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101aec:	c1 e0 0c             	shl    $0xc,%eax
f0101aef:	c1 e8 0a             	shr    $0xa,%eax
f0101af2:	50                   	push   %eax
f0101af3:	a1 68 82 23 f0       	mov    0xf0238268,%eax
f0101af8:	c1 e0 0c             	shl    $0xc,%eax
f0101afb:	c1 e8 0a             	shr    $0xa,%eax
f0101afe:	50                   	push   %eax
f0101aff:	a1 a8 8e 23 f0       	mov    0xf0238ea8,%eax
f0101b04:	c1 e0 0c             	shl    $0xc,%eax
f0101b07:	c1 e8 0a             	shr    $0xa,%eax
f0101b0a:	50                   	push   %eax
f0101b0b:	68 5c 6f 10 f0       	push   $0xf0106f5c
f0101b10:	e8 7f 23 00 00       	call   f0103e94 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101b15:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101b1a:	e8 6b f3 ff ff       	call   f0100e8a <boot_alloc>
f0101b1f:	a3 ac 8e 23 f0       	mov    %eax,0xf0238eac
	memset(kern_pgdir, 0, PGSIZE);
f0101b24:	83 c4 0c             	add    $0xc,%esp
f0101b27:	68 00 10 00 00       	push   $0x1000
f0101b2c:	6a 00                	push   $0x0
f0101b2e:	50                   	push   %eax
f0101b2f:	e8 b8 3e 00 00       	call   f01059ec <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101b34:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101b39:	83 c4 10             	add    $0x10,%esp
f0101b3c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b41:	77 15                	ja     f0101b58 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101b43:	50                   	push   %eax
f0101b44:	68 e4 67 10 f0       	push   $0xf01067e4
f0101b49:	68 96 00 00 00       	push   $0x96
f0101b4e:	68 75 75 10 f0       	push   $0xf0107575
f0101b53:	e8 e8 e4 ff ff       	call   f0100040 <_panic>
f0101b58:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101b5e:	83 ca 05             	or     $0x5,%edx
f0101b61:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = boot_alloc(npages * sizeof(struct Page));
f0101b67:	a1 a8 8e 23 f0       	mov    0xf0238ea8,%eax
f0101b6c:	c1 e0 03             	shl    $0x3,%eax
f0101b6f:	e8 16 f3 ff ff       	call   f0100e8a <boot_alloc>
f0101b74:	a3 b0 8e 23 f0       	mov    %eax,0xf0238eb0


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = boot_alloc(NENV * sizeof(struct Env));
f0101b79:	b8 00 00 02 00       	mov    $0x20000,%eax
f0101b7e:	e8 07 f3 ff ff       	call   f0100e8a <boot_alloc>
f0101b83:	a3 6c 82 23 f0       	mov    %eax,0xf023826c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101b88:	e8 96 f6 ff ff       	call   f0101223 <page_init>

	check_page_free_list(1);
f0101b8d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b92:	e8 7c f3 ff ff       	call   f0100f13 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0101b97:	83 3d b0 8e 23 f0 00 	cmpl   $0x0,0xf0238eb0
f0101b9e:	75 17                	jne    f0101bb7 <mem_init+0x155>
		panic("'pages' is a null pointer!");
f0101ba0:	83 ec 04             	sub    $0x4,%esp
f0101ba3:	68 5a 76 10 f0       	push   $0xf010765a
f0101ba8:	68 83 03 00 00       	push   $0x383
f0101bad:	68 75 75 10 f0       	push   $0xf0107575
f0101bb2:	e8 89 e4 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101bb7:	a1 64 82 23 f0       	mov    0xf0238264,%eax
f0101bbc:	85 c0                	test   %eax,%eax
f0101bbe:	74 10                	je     f0101bd0 <mem_init+0x16e>
f0101bc0:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101bc5:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101bc8:	8b 00                	mov    (%eax),%eax
f0101bca:	85 c0                	test   %eax,%eax
f0101bcc:	75 f7                	jne    f0101bc5 <mem_init+0x163>
f0101bce:	eb 05                	jmp    f0101bd5 <mem_init+0x173>
f0101bd0:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101bd5:	83 ec 0c             	sub    $0xc,%esp
f0101bd8:	6a 00                	push   $0x0
f0101bda:	e8 0b f7 ff ff       	call   f01012ea <page_alloc>
f0101bdf:	89 c7                	mov    %eax,%edi
f0101be1:	83 c4 10             	add    $0x10,%esp
f0101be4:	85 c0                	test   %eax,%eax
f0101be6:	75 19                	jne    f0101c01 <mem_init+0x19f>
f0101be8:	68 75 76 10 f0       	push   $0xf0107675
f0101bed:	68 9b 75 10 f0       	push   $0xf010759b
f0101bf2:	68 8b 03 00 00       	push   $0x38b
f0101bf7:	68 75 75 10 f0       	push   $0xf0107575
f0101bfc:	e8 3f e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c01:	83 ec 0c             	sub    $0xc,%esp
f0101c04:	6a 00                	push   $0x0
f0101c06:	e8 df f6 ff ff       	call   f01012ea <page_alloc>
f0101c0b:	89 c6                	mov    %eax,%esi
f0101c0d:	83 c4 10             	add    $0x10,%esp
f0101c10:	85 c0                	test   %eax,%eax
f0101c12:	75 19                	jne    f0101c2d <mem_init+0x1cb>
f0101c14:	68 8b 76 10 f0       	push   $0xf010768b
f0101c19:	68 9b 75 10 f0       	push   $0xf010759b
f0101c1e:	68 8c 03 00 00       	push   $0x38c
f0101c23:	68 75 75 10 f0       	push   $0xf0107575
f0101c28:	e8 13 e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c2d:	83 ec 0c             	sub    $0xc,%esp
f0101c30:	6a 00                	push   $0x0
f0101c32:	e8 b3 f6 ff ff       	call   f01012ea <page_alloc>
f0101c37:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c3a:	83 c4 10             	add    $0x10,%esp
f0101c3d:	85 c0                	test   %eax,%eax
f0101c3f:	75 19                	jne    f0101c5a <mem_init+0x1f8>
f0101c41:	68 a1 76 10 f0       	push   $0xf01076a1
f0101c46:	68 9b 75 10 f0       	push   $0xf010759b
f0101c4b:	68 8d 03 00 00       	push   $0x38d
f0101c50:	68 75 75 10 f0       	push   $0xf0107575
f0101c55:	e8 e6 e3 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c5a:	39 f7                	cmp    %esi,%edi
f0101c5c:	75 19                	jne    f0101c77 <mem_init+0x215>
f0101c5e:	68 b7 76 10 f0       	push   $0xf01076b7
f0101c63:	68 9b 75 10 f0       	push   $0xf010759b
f0101c68:	68 90 03 00 00       	push   $0x390
f0101c6d:	68 75 75 10 f0       	push   $0xf0107575
f0101c72:	e8 c9 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c77:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c7a:	39 c7                	cmp    %eax,%edi
f0101c7c:	74 04                	je     f0101c82 <mem_init+0x220>
f0101c7e:	39 c6                	cmp    %eax,%esi
f0101c80:	75 19                	jne    f0101c9b <mem_init+0x239>
f0101c82:	68 98 6f 10 f0       	push   $0xf0106f98
f0101c87:	68 9b 75 10 f0       	push   $0xf010759b
f0101c8c:	68 91 03 00 00       	push   $0x391
f0101c91:	68 75 75 10 f0       	push   $0xf0107575
f0101c96:	e8 a5 e3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c9b:	8b 0d b0 8e 23 f0    	mov    0xf0238eb0,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101ca1:	8b 15 a8 8e 23 f0    	mov    0xf0238ea8,%edx
f0101ca7:	c1 e2 0c             	shl    $0xc,%edx
f0101caa:	89 f8                	mov    %edi,%eax
f0101cac:	29 c8                	sub    %ecx,%eax
f0101cae:	c1 f8 03             	sar    $0x3,%eax
f0101cb1:	c1 e0 0c             	shl    $0xc,%eax
f0101cb4:	39 d0                	cmp    %edx,%eax
f0101cb6:	72 19                	jb     f0101cd1 <mem_init+0x26f>
f0101cb8:	68 c9 76 10 f0       	push   $0xf01076c9
f0101cbd:	68 9b 75 10 f0       	push   $0xf010759b
f0101cc2:	68 92 03 00 00       	push   $0x392
f0101cc7:	68 75 75 10 f0       	push   $0xf0107575
f0101ccc:	e8 6f e3 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101cd1:	89 f0                	mov    %esi,%eax
f0101cd3:	29 c8                	sub    %ecx,%eax
f0101cd5:	c1 f8 03             	sar    $0x3,%eax
f0101cd8:	c1 e0 0c             	shl    $0xc,%eax
f0101cdb:	39 c2                	cmp    %eax,%edx
f0101cdd:	77 19                	ja     f0101cf8 <mem_init+0x296>
f0101cdf:	68 e6 76 10 f0       	push   $0xf01076e6
f0101ce4:	68 9b 75 10 f0       	push   $0xf010759b
f0101ce9:	68 93 03 00 00       	push   $0x393
f0101cee:	68 75 75 10 f0       	push   $0xf0107575
f0101cf3:	e8 48 e3 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101cf8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cfb:	29 c8                	sub    %ecx,%eax
f0101cfd:	c1 f8 03             	sar    $0x3,%eax
f0101d00:	c1 e0 0c             	shl    $0xc,%eax
f0101d03:	39 c2                	cmp    %eax,%edx
f0101d05:	77 19                	ja     f0101d20 <mem_init+0x2be>
f0101d07:	68 03 77 10 f0       	push   $0xf0107703
f0101d0c:	68 9b 75 10 f0       	push   $0xf010759b
f0101d11:	68 94 03 00 00       	push   $0x394
f0101d16:	68 75 75 10 f0       	push   $0xf0107575
f0101d1b:	e8 20 e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d20:	a1 64 82 23 f0       	mov    0xf0238264,%eax
f0101d25:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101d28:	c7 05 64 82 23 f0 00 	movl   $0x0,0xf0238264
f0101d2f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d32:	83 ec 0c             	sub    $0xc,%esp
f0101d35:	6a 00                	push   $0x0
f0101d37:	e8 ae f5 ff ff       	call   f01012ea <page_alloc>
f0101d3c:	83 c4 10             	add    $0x10,%esp
f0101d3f:	85 c0                	test   %eax,%eax
f0101d41:	74 19                	je     f0101d5c <mem_init+0x2fa>
f0101d43:	68 20 77 10 f0       	push   $0xf0107720
f0101d48:	68 9b 75 10 f0       	push   $0xf010759b
f0101d4d:	68 9b 03 00 00       	push   $0x39b
f0101d52:	68 75 75 10 f0       	push   $0xf0107575
f0101d57:	e8 e4 e2 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101d5c:	83 ec 0c             	sub    $0xc,%esp
f0101d5f:	57                   	push   %edi
f0101d60:	e8 f6 f7 ff ff       	call   f010155b <page_free>
	page_free(pp1);
f0101d65:	89 34 24             	mov    %esi,(%esp)
f0101d68:	e8 ee f7 ff ff       	call   f010155b <page_free>
	page_free(pp2);
f0101d6d:	83 c4 04             	add    $0x4,%esp
f0101d70:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d73:	e8 e3 f7 ff ff       	call   f010155b <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d7f:	e8 66 f5 ff ff       	call   f01012ea <page_alloc>
f0101d84:	89 c6                	mov    %eax,%esi
f0101d86:	83 c4 10             	add    $0x10,%esp
f0101d89:	85 c0                	test   %eax,%eax
f0101d8b:	75 19                	jne    f0101da6 <mem_init+0x344>
f0101d8d:	68 75 76 10 f0       	push   $0xf0107675
f0101d92:	68 9b 75 10 f0       	push   $0xf010759b
f0101d97:	68 a2 03 00 00       	push   $0x3a2
f0101d9c:	68 75 75 10 f0       	push   $0xf0107575
f0101da1:	e8 9a e2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101da6:	83 ec 0c             	sub    $0xc,%esp
f0101da9:	6a 00                	push   $0x0
f0101dab:	e8 3a f5 ff ff       	call   f01012ea <page_alloc>
f0101db0:	89 c7                	mov    %eax,%edi
f0101db2:	83 c4 10             	add    $0x10,%esp
f0101db5:	85 c0                	test   %eax,%eax
f0101db7:	75 19                	jne    f0101dd2 <mem_init+0x370>
f0101db9:	68 8b 76 10 f0       	push   $0xf010768b
f0101dbe:	68 9b 75 10 f0       	push   $0xf010759b
f0101dc3:	68 a3 03 00 00       	push   $0x3a3
f0101dc8:	68 75 75 10 f0       	push   $0xf0107575
f0101dcd:	e8 6e e2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101dd2:	83 ec 0c             	sub    $0xc,%esp
f0101dd5:	6a 00                	push   $0x0
f0101dd7:	e8 0e f5 ff ff       	call   f01012ea <page_alloc>
f0101ddc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ddf:	83 c4 10             	add    $0x10,%esp
f0101de2:	85 c0                	test   %eax,%eax
f0101de4:	75 19                	jne    f0101dff <mem_init+0x39d>
f0101de6:	68 a1 76 10 f0       	push   $0xf01076a1
f0101deb:	68 9b 75 10 f0       	push   $0xf010759b
f0101df0:	68 a4 03 00 00       	push   $0x3a4
f0101df5:	68 75 75 10 f0       	push   $0xf0107575
f0101dfa:	e8 41 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101dff:	39 fe                	cmp    %edi,%esi
f0101e01:	75 19                	jne    f0101e1c <mem_init+0x3ba>
f0101e03:	68 b7 76 10 f0       	push   $0xf01076b7
f0101e08:	68 9b 75 10 f0       	push   $0xf010759b
f0101e0d:	68 a6 03 00 00       	push   $0x3a6
f0101e12:	68 75 75 10 f0       	push   $0xf0107575
f0101e17:	e8 24 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e1f:	39 c7                	cmp    %eax,%edi
f0101e21:	74 04                	je     f0101e27 <mem_init+0x3c5>
f0101e23:	39 c6                	cmp    %eax,%esi
f0101e25:	75 19                	jne    f0101e40 <mem_init+0x3de>
f0101e27:	68 98 6f 10 f0       	push   $0xf0106f98
f0101e2c:	68 9b 75 10 f0       	push   $0xf010759b
f0101e31:	68 a7 03 00 00       	push   $0x3a7
f0101e36:	68 75 75 10 f0       	push   $0xf0107575
f0101e3b:	e8 00 e2 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101e40:	83 ec 0c             	sub    $0xc,%esp
f0101e43:	6a 00                	push   $0x0
f0101e45:	e8 a0 f4 ff ff       	call   f01012ea <page_alloc>
f0101e4a:	83 c4 10             	add    $0x10,%esp
f0101e4d:	85 c0                	test   %eax,%eax
f0101e4f:	74 19                	je     f0101e6a <mem_init+0x408>
f0101e51:	68 20 77 10 f0       	push   $0xf0107720
f0101e56:	68 9b 75 10 f0       	push   $0xf010759b
f0101e5b:	68 a8 03 00 00       	push   $0x3a8
f0101e60:	68 75 75 10 f0       	push   $0xf0107575
f0101e65:	e8 d6 e1 ff ff       	call   f0100040 <_panic>
f0101e6a:	89 f0                	mov    %esi,%eax
f0101e6c:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0101e72:	c1 f8 03             	sar    $0x3,%eax
f0101e75:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e78:	89 c2                	mov    %eax,%edx
f0101e7a:	c1 ea 0c             	shr    $0xc,%edx
f0101e7d:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f0101e83:	72 12                	jb     f0101e97 <mem_init+0x435>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e85:	50                   	push   %eax
f0101e86:	68 c0 67 10 f0       	push   $0xf01067c0
f0101e8b:	6a 56                	push   $0x56
f0101e8d:	68 81 75 10 f0       	push   $0xf0107581
f0101e92:	e8 a9 e1 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101e97:	83 ec 04             	sub    $0x4,%esp
f0101e9a:	68 00 10 00 00       	push   $0x1000
f0101e9f:	6a 01                	push   $0x1
f0101ea1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ea6:	50                   	push   %eax
f0101ea7:	e8 40 3b 00 00       	call   f01059ec <memset>
	page_free(pp0);
f0101eac:	89 34 24             	mov    %esi,(%esp)
f0101eaf:	e8 a7 f6 ff ff       	call   f010155b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101eb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101ebb:	e8 2a f4 ff ff       	call   f01012ea <page_alloc>
f0101ec0:	83 c4 10             	add    $0x10,%esp
f0101ec3:	85 c0                	test   %eax,%eax
f0101ec5:	75 19                	jne    f0101ee0 <mem_init+0x47e>
f0101ec7:	68 2f 77 10 f0       	push   $0xf010772f
f0101ecc:	68 9b 75 10 f0       	push   $0xf010759b
f0101ed1:	68 ad 03 00 00       	push   $0x3ad
f0101ed6:	68 75 75 10 f0       	push   $0xf0107575
f0101edb:	e8 60 e1 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101ee0:	39 c6                	cmp    %eax,%esi
f0101ee2:	74 19                	je     f0101efd <mem_init+0x49b>
f0101ee4:	68 4d 77 10 f0       	push   $0xf010774d
f0101ee9:	68 9b 75 10 f0       	push   $0xf010759b
f0101eee:	68 ae 03 00 00       	push   $0x3ae
f0101ef3:	68 75 75 10 f0       	push   $0xf0107575
f0101ef8:	e8 43 e1 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101efd:	89 f2                	mov    %esi,%edx
f0101eff:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f0101f05:	c1 fa 03             	sar    $0x3,%edx
f0101f08:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f0b:	89 d0                	mov    %edx,%eax
f0101f0d:	c1 e8 0c             	shr    $0xc,%eax
f0101f10:	3b 05 a8 8e 23 f0    	cmp    0xf0238ea8,%eax
f0101f16:	72 12                	jb     f0101f2a <mem_init+0x4c8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f18:	52                   	push   %edx
f0101f19:	68 c0 67 10 f0       	push   $0xf01067c0
f0101f1e:	6a 56                	push   $0x56
f0101f20:	68 81 75 10 f0       	push   $0xf0107581
f0101f25:	e8 16 e1 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101f2a:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101f31:	75 11                	jne    f0101f44 <mem_init+0x4e2>
f0101f33:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f0101f39:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101f3f:	80 38 00             	cmpb   $0x0,(%eax)
f0101f42:	74 19                	je     f0101f5d <mem_init+0x4fb>
f0101f44:	68 5d 77 10 f0       	push   $0xf010775d
f0101f49:	68 9b 75 10 f0       	push   $0xf010759b
f0101f4e:	68 b1 03 00 00       	push   $0x3b1
f0101f53:	68 75 75 10 f0       	push   $0xf0107575
f0101f58:	e8 e3 e0 ff ff       	call   f0100040 <_panic>
f0101f5d:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101f60:	39 d0                	cmp    %edx,%eax
f0101f62:	75 db                	jne    f0101f3f <mem_init+0x4dd>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101f64:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f67:	a3 64 82 23 f0       	mov    %eax,0xf0238264

	// free the pages we took
	page_free(pp0);
f0101f6c:	83 ec 0c             	sub    $0xc,%esp
f0101f6f:	56                   	push   %esi
f0101f70:	e8 e6 f5 ff ff       	call   f010155b <page_free>
	page_free(pp1);
f0101f75:	89 3c 24             	mov    %edi,(%esp)
f0101f78:	e8 de f5 ff ff       	call   f010155b <page_free>
	page_free(pp2);
f0101f7d:	83 c4 04             	add    $0x4,%esp
f0101f80:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f83:	e8 d3 f5 ff ff       	call   f010155b <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f88:	a1 64 82 23 f0       	mov    0xf0238264,%eax
f0101f8d:	83 c4 10             	add    $0x10,%esp
f0101f90:	85 c0                	test   %eax,%eax
f0101f92:	74 09                	je     f0101f9d <mem_init+0x53b>
		--nfree;
f0101f94:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f97:	8b 00                	mov    (%eax),%eax
f0101f99:	85 c0                	test   %eax,%eax
f0101f9b:	75 f7                	jne    f0101f94 <mem_init+0x532>
		--nfree;
	assert(nfree == 0);
f0101f9d:	85 db                	test   %ebx,%ebx
f0101f9f:	74 19                	je     f0101fba <mem_init+0x558>
f0101fa1:	68 67 77 10 f0       	push   $0xf0107767
f0101fa6:	68 9b 75 10 f0       	push   $0xf010759b
f0101fab:	68 be 03 00 00       	push   $0x3be
f0101fb0:	68 75 75 10 f0       	push   $0xf0107575
f0101fb5:	e8 86 e0 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101fba:	83 ec 0c             	sub    $0xc,%esp
f0101fbd:	68 b8 6f 10 f0       	push   $0xf0106fb8
f0101fc2:	e8 cd 1e 00 00       	call   f0103e94 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101fc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fce:	e8 17 f3 ff ff       	call   f01012ea <page_alloc>
f0101fd3:	89 c3                	mov    %eax,%ebx
f0101fd5:	83 c4 10             	add    $0x10,%esp
f0101fd8:	85 c0                	test   %eax,%eax
f0101fda:	75 19                	jne    f0101ff5 <mem_init+0x593>
f0101fdc:	68 75 76 10 f0       	push   $0xf0107675
f0101fe1:	68 9b 75 10 f0       	push   $0xf010759b
f0101fe6:	68 26 04 00 00       	push   $0x426
f0101feb:	68 75 75 10 f0       	push   $0xf0107575
f0101ff0:	e8 4b e0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ff5:	83 ec 0c             	sub    $0xc,%esp
f0101ff8:	6a 00                	push   $0x0
f0101ffa:	e8 eb f2 ff ff       	call   f01012ea <page_alloc>
f0101fff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102002:	83 c4 10             	add    $0x10,%esp
f0102005:	85 c0                	test   %eax,%eax
f0102007:	75 19                	jne    f0102022 <mem_init+0x5c0>
f0102009:	68 8b 76 10 f0       	push   $0xf010768b
f010200e:	68 9b 75 10 f0       	push   $0xf010759b
f0102013:	68 27 04 00 00       	push   $0x427
f0102018:	68 75 75 10 f0       	push   $0xf0107575
f010201d:	e8 1e e0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102022:	83 ec 0c             	sub    $0xc,%esp
f0102025:	6a 00                	push   $0x0
f0102027:	e8 be f2 ff ff       	call   f01012ea <page_alloc>
f010202c:	89 c6                	mov    %eax,%esi
f010202e:	83 c4 10             	add    $0x10,%esp
f0102031:	85 c0                	test   %eax,%eax
f0102033:	75 19                	jne    f010204e <mem_init+0x5ec>
f0102035:	68 a1 76 10 f0       	push   $0xf01076a1
f010203a:	68 9b 75 10 f0       	push   $0xf010759b
f010203f:	68 28 04 00 00       	push   $0x428
f0102044:	68 75 75 10 f0       	push   $0xf0107575
f0102049:	e8 f2 df ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010204e:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102051:	75 19                	jne    f010206c <mem_init+0x60a>
f0102053:	68 b7 76 10 f0       	push   $0xf01076b7
f0102058:	68 9b 75 10 f0       	push   $0xf010759b
f010205d:	68 2b 04 00 00       	push   $0x42b
f0102062:	68 75 75 10 f0       	push   $0xf0107575
f0102067:	e8 d4 df ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010206c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010206f:	74 04                	je     f0102075 <mem_init+0x613>
f0102071:	39 c3                	cmp    %eax,%ebx
f0102073:	75 19                	jne    f010208e <mem_init+0x62c>
f0102075:	68 98 6f 10 f0       	push   $0xf0106f98
f010207a:	68 9b 75 10 f0       	push   $0xf010759b
f010207f:	68 2c 04 00 00       	push   $0x42c
f0102084:	68 75 75 10 f0       	push   $0xf0107575
f0102089:	e8 b2 df ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010208e:	a1 64 82 23 f0       	mov    0xf0238264,%eax
f0102093:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0102096:	c7 05 64 82 23 f0 00 	movl   $0x0,0xf0238264
f010209d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01020a0:	83 ec 0c             	sub    $0xc,%esp
f01020a3:	6a 00                	push   $0x0
f01020a5:	e8 40 f2 ff ff       	call   f01012ea <page_alloc>
f01020aa:	83 c4 10             	add    $0x10,%esp
f01020ad:	85 c0                	test   %eax,%eax
f01020af:	74 19                	je     f01020ca <mem_init+0x668>
f01020b1:	68 20 77 10 f0       	push   $0xf0107720
f01020b6:	68 9b 75 10 f0       	push   $0xf010759b
f01020bb:	68 33 04 00 00       	push   $0x433
f01020c0:	68 75 75 10 f0       	push   $0xf0107575
f01020c5:	e8 76 df ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01020ca:	83 ec 04             	sub    $0x4,%esp
f01020cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01020d0:	50                   	push   %eax
f01020d1:	6a 00                	push   $0x0
f01020d3:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f01020d9:	e8 0a f8 ff ff       	call   f01018e8 <page_lookup>
f01020de:	83 c4 10             	add    $0x10,%esp
f01020e1:	85 c0                	test   %eax,%eax
f01020e3:	74 19                	je     f01020fe <mem_init+0x69c>
f01020e5:	68 d8 6f 10 f0       	push   $0xf0106fd8
f01020ea:	68 9b 75 10 f0       	push   $0xf010759b
f01020ef:	68 36 04 00 00       	push   $0x436
f01020f4:	68 75 75 10 f0       	push   $0xf0107575
f01020f9:	e8 42 df ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01020fe:	6a 02                	push   $0x2
f0102100:	6a 00                	push   $0x0
f0102102:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102105:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f010210b:	e8 bc f8 ff ff       	call   f01019cc <page_insert>
f0102110:	83 c4 10             	add    $0x10,%esp
f0102113:	85 c0                	test   %eax,%eax
f0102115:	78 19                	js     f0102130 <mem_init+0x6ce>
f0102117:	68 10 70 10 f0       	push   $0xf0107010
f010211c:	68 9b 75 10 f0       	push   $0xf010759b
f0102121:	68 39 04 00 00       	push   $0x439
f0102126:	68 75 75 10 f0       	push   $0xf0107575
f010212b:	e8 10 df ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102130:	83 ec 0c             	sub    $0xc,%esp
f0102133:	53                   	push   %ebx
f0102134:	e8 22 f4 ff ff       	call   f010155b <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102139:	6a 02                	push   $0x2
f010213b:	6a 00                	push   $0x0
f010213d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102140:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f0102146:	e8 81 f8 ff ff       	call   f01019cc <page_insert>
f010214b:	83 c4 20             	add    $0x20,%esp
f010214e:	85 c0                	test   %eax,%eax
f0102150:	74 19                	je     f010216b <mem_init+0x709>
f0102152:	68 40 70 10 f0       	push   $0xf0107040
f0102157:	68 9b 75 10 f0       	push   $0xf010759b
f010215c:	68 3d 04 00 00       	push   $0x43d
f0102161:	68 75 75 10 f0       	push   $0xf0107575
f0102166:	e8 d5 de ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010216b:	8b 3d ac 8e 23 f0    	mov    0xf0238eac,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102171:	a1 b0 8e 23 f0       	mov    0xf0238eb0,%eax
f0102176:	89 c1                	mov    %eax,%ecx
f0102178:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010217b:	8b 17                	mov    (%edi),%edx
f010217d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102183:	89 d8                	mov    %ebx,%eax
f0102185:	29 c8                	sub    %ecx,%eax
f0102187:	c1 f8 03             	sar    $0x3,%eax
f010218a:	c1 e0 0c             	shl    $0xc,%eax
f010218d:	39 c2                	cmp    %eax,%edx
f010218f:	74 19                	je     f01021aa <mem_init+0x748>
f0102191:	68 70 70 10 f0       	push   $0xf0107070
f0102196:	68 9b 75 10 f0       	push   $0xf010759b
f010219b:	68 3e 04 00 00       	push   $0x43e
f01021a0:	68 75 75 10 f0       	push   $0xf0107575
f01021a5:	e8 96 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01021aa:	ba 00 00 00 00       	mov    $0x0,%edx
f01021af:	89 f8                	mov    %edi,%eax
f01021b1:	e8 70 ec ff ff       	call   f0100e26 <check_va2pa>
f01021b6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01021b9:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01021bc:	c1 fa 03             	sar    $0x3,%edx
f01021bf:	c1 e2 0c             	shl    $0xc,%edx
f01021c2:	39 d0                	cmp    %edx,%eax
f01021c4:	74 19                	je     f01021df <mem_init+0x77d>
f01021c6:	68 98 70 10 f0       	push   $0xf0107098
f01021cb:	68 9b 75 10 f0       	push   $0xf010759b
f01021d0:	68 3f 04 00 00       	push   $0x43f
f01021d5:	68 75 75 10 f0       	push   $0xf0107575
f01021da:	e8 61 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01021df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021e2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021e7:	74 19                	je     f0102202 <mem_init+0x7a0>
f01021e9:	68 72 77 10 f0       	push   $0xf0107772
f01021ee:	68 9b 75 10 f0       	push   $0xf010759b
f01021f3:	68 40 04 00 00       	push   $0x440
f01021f8:	68 75 75 10 f0       	push   $0xf0107575
f01021fd:	e8 3e de ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102202:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102207:	74 19                	je     f0102222 <mem_init+0x7c0>
f0102209:	68 83 77 10 f0       	push   $0xf0107783
f010220e:	68 9b 75 10 f0       	push   $0xf010759b
f0102213:	68 41 04 00 00       	push   $0x441
f0102218:	68 75 75 10 f0       	push   $0xf0107575
f010221d:	e8 1e de ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102222:	6a 02                	push   $0x2
f0102224:	68 00 10 00 00       	push   $0x1000
f0102229:	56                   	push   %esi
f010222a:	57                   	push   %edi
f010222b:	e8 9c f7 ff ff       	call   f01019cc <page_insert>
f0102230:	83 c4 10             	add    $0x10,%esp
f0102233:	85 c0                	test   %eax,%eax
f0102235:	74 19                	je     f0102250 <mem_init+0x7ee>
f0102237:	68 c8 70 10 f0       	push   $0xf01070c8
f010223c:	68 9b 75 10 f0       	push   $0xf010759b
f0102241:	68 44 04 00 00       	push   $0x444
f0102246:	68 75 75 10 f0       	push   $0xf0107575
f010224b:	e8 f0 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102250:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102255:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f010225a:	e8 c7 eb ff ff       	call   f0100e26 <check_va2pa>
f010225f:	89 f2                	mov    %esi,%edx
f0102261:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f0102267:	c1 fa 03             	sar    $0x3,%edx
f010226a:	c1 e2 0c             	shl    $0xc,%edx
f010226d:	39 d0                	cmp    %edx,%eax
f010226f:	74 19                	je     f010228a <mem_init+0x828>
f0102271:	68 04 71 10 f0       	push   $0xf0107104
f0102276:	68 9b 75 10 f0       	push   $0xf010759b
f010227b:	68 45 04 00 00       	push   $0x445
f0102280:	68 75 75 10 f0       	push   $0xf0107575
f0102285:	e8 b6 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010228a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010228f:	74 19                	je     f01022aa <mem_init+0x848>
f0102291:	68 94 77 10 f0       	push   $0xf0107794
f0102296:	68 9b 75 10 f0       	push   $0xf010759b
f010229b:	68 46 04 00 00       	push   $0x446
f01022a0:	68 75 75 10 f0       	push   $0xf0107575
f01022a5:	e8 96 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022aa:	83 ec 0c             	sub    $0xc,%esp
f01022ad:	6a 00                	push   $0x0
f01022af:	e8 36 f0 ff ff       	call   f01012ea <page_alloc>
f01022b4:	83 c4 10             	add    $0x10,%esp
f01022b7:	85 c0                	test   %eax,%eax
f01022b9:	74 19                	je     f01022d4 <mem_init+0x872>
f01022bb:	68 20 77 10 f0       	push   $0xf0107720
f01022c0:	68 9b 75 10 f0       	push   $0xf010759b
f01022c5:	68 49 04 00 00       	push   $0x449
f01022ca:	68 75 75 10 f0       	push   $0xf0107575
f01022cf:	e8 6c dd ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022d4:	6a 02                	push   $0x2
f01022d6:	68 00 10 00 00       	push   $0x1000
f01022db:	56                   	push   %esi
f01022dc:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f01022e2:	e8 e5 f6 ff ff       	call   f01019cc <page_insert>
f01022e7:	83 c4 10             	add    $0x10,%esp
f01022ea:	85 c0                	test   %eax,%eax
f01022ec:	74 19                	je     f0102307 <mem_init+0x8a5>
f01022ee:	68 c8 70 10 f0       	push   $0xf01070c8
f01022f3:	68 9b 75 10 f0       	push   $0xf010759b
f01022f8:	68 4c 04 00 00       	push   $0x44c
f01022fd:	68 75 75 10 f0       	push   $0xf0107575
f0102302:	e8 39 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102307:	ba 00 10 00 00       	mov    $0x1000,%edx
f010230c:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f0102311:	e8 10 eb ff ff       	call   f0100e26 <check_va2pa>
f0102316:	89 f2                	mov    %esi,%edx
f0102318:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f010231e:	c1 fa 03             	sar    $0x3,%edx
f0102321:	c1 e2 0c             	shl    $0xc,%edx
f0102324:	39 d0                	cmp    %edx,%eax
f0102326:	74 19                	je     f0102341 <mem_init+0x8df>
f0102328:	68 04 71 10 f0       	push   $0xf0107104
f010232d:	68 9b 75 10 f0       	push   $0xf010759b
f0102332:	68 4d 04 00 00       	push   $0x44d
f0102337:	68 75 75 10 f0       	push   $0xf0107575
f010233c:	e8 ff dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102341:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102346:	74 19                	je     f0102361 <mem_init+0x8ff>
f0102348:	68 94 77 10 f0       	push   $0xf0107794
f010234d:	68 9b 75 10 f0       	push   $0xf010759b
f0102352:	68 4e 04 00 00       	push   $0x44e
f0102357:	68 75 75 10 f0       	push   $0xf0107575
f010235c:	e8 df dc ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102361:	83 ec 0c             	sub    $0xc,%esp
f0102364:	6a 00                	push   $0x0
f0102366:	e8 7f ef ff ff       	call   f01012ea <page_alloc>
f010236b:	83 c4 10             	add    $0x10,%esp
f010236e:	85 c0                	test   %eax,%eax
f0102370:	74 19                	je     f010238b <mem_init+0x929>
f0102372:	68 20 77 10 f0       	push   $0xf0107720
f0102377:	68 9b 75 10 f0       	push   $0xf010759b
f010237c:	68 52 04 00 00       	push   $0x452
f0102381:	68 75 75 10 f0       	push   $0xf0107575
f0102386:	e8 b5 dc ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010238b:	8b 15 ac 8e 23 f0    	mov    0xf0238eac,%edx
f0102391:	8b 02                	mov    (%edx),%eax
f0102393:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102398:	89 c1                	mov    %eax,%ecx
f010239a:	c1 e9 0c             	shr    $0xc,%ecx
f010239d:	3b 0d a8 8e 23 f0    	cmp    0xf0238ea8,%ecx
f01023a3:	72 15                	jb     f01023ba <mem_init+0x958>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023a5:	50                   	push   %eax
f01023a6:	68 c0 67 10 f0       	push   $0xf01067c0
f01023ab:	68 55 04 00 00       	push   $0x455
f01023b0:	68 75 75 10 f0       	push   $0xf0107575
f01023b5:	e8 86 dc ff ff       	call   f0100040 <_panic>
f01023ba:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023c2:	83 ec 04             	sub    $0x4,%esp
f01023c5:	6a 00                	push   $0x0
f01023c7:	68 00 10 00 00       	push   $0x1000
f01023cc:	52                   	push   %edx
f01023cd:	e8 cb f3 ff ff       	call   f010179d <pgdir_walk>
f01023d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01023d5:	8d 57 04             	lea    0x4(%edi),%edx
f01023d8:	83 c4 10             	add    $0x10,%esp
f01023db:	39 d0                	cmp    %edx,%eax
f01023dd:	74 19                	je     f01023f8 <mem_init+0x996>
f01023df:	68 34 71 10 f0       	push   $0xf0107134
f01023e4:	68 9b 75 10 f0       	push   $0xf010759b
f01023e9:	68 56 04 00 00       	push   $0x456
f01023ee:	68 75 75 10 f0       	push   $0xf0107575
f01023f3:	e8 48 dc ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023f8:	6a 06                	push   $0x6
f01023fa:	68 00 10 00 00       	push   $0x1000
f01023ff:	56                   	push   %esi
f0102400:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f0102406:	e8 c1 f5 ff ff       	call   f01019cc <page_insert>
f010240b:	83 c4 10             	add    $0x10,%esp
f010240e:	85 c0                	test   %eax,%eax
f0102410:	74 19                	je     f010242b <mem_init+0x9c9>
f0102412:	68 74 71 10 f0       	push   $0xf0107174
f0102417:	68 9b 75 10 f0       	push   $0xf010759b
f010241c:	68 59 04 00 00       	push   $0x459
f0102421:	68 75 75 10 f0       	push   $0xf0107575
f0102426:	e8 15 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010242b:	8b 3d ac 8e 23 f0    	mov    0xf0238eac,%edi
f0102431:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102436:	89 f8                	mov    %edi,%eax
f0102438:	e8 e9 e9 ff ff       	call   f0100e26 <check_va2pa>
f010243d:	89 f2                	mov    %esi,%edx
f010243f:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f0102445:	c1 fa 03             	sar    $0x3,%edx
f0102448:	c1 e2 0c             	shl    $0xc,%edx
f010244b:	39 d0                	cmp    %edx,%eax
f010244d:	74 19                	je     f0102468 <mem_init+0xa06>
f010244f:	68 04 71 10 f0       	push   $0xf0107104
f0102454:	68 9b 75 10 f0       	push   $0xf010759b
f0102459:	68 5a 04 00 00       	push   $0x45a
f010245e:	68 75 75 10 f0       	push   $0xf0107575
f0102463:	e8 d8 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102468:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010246d:	74 19                	je     f0102488 <mem_init+0xa26>
f010246f:	68 94 77 10 f0       	push   $0xf0107794
f0102474:	68 9b 75 10 f0       	push   $0xf010759b
f0102479:	68 5b 04 00 00       	push   $0x45b
f010247e:	68 75 75 10 f0       	push   $0xf0107575
f0102483:	e8 b8 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102488:	83 ec 04             	sub    $0x4,%esp
f010248b:	6a 00                	push   $0x0
f010248d:	68 00 10 00 00       	push   $0x1000
f0102492:	57                   	push   %edi
f0102493:	e8 05 f3 ff ff       	call   f010179d <pgdir_walk>
f0102498:	83 c4 10             	add    $0x10,%esp
f010249b:	f6 00 04             	testb  $0x4,(%eax)
f010249e:	75 19                	jne    f01024b9 <mem_init+0xa57>
f01024a0:	68 b4 71 10 f0       	push   $0xf01071b4
f01024a5:	68 9b 75 10 f0       	push   $0xf010759b
f01024aa:	68 5c 04 00 00       	push   $0x45c
f01024af:	68 75 75 10 f0       	push   $0xf0107575
f01024b4:	e8 87 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024b9:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f01024be:	f6 00 04             	testb  $0x4,(%eax)
f01024c1:	75 19                	jne    f01024dc <mem_init+0xa7a>
f01024c3:	68 a5 77 10 f0       	push   $0xf01077a5
f01024c8:	68 9b 75 10 f0       	push   $0xf010759b
f01024cd:	68 5d 04 00 00       	push   $0x45d
f01024d2:	68 75 75 10 f0       	push   $0xf0107575
f01024d7:	e8 64 db ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024dc:	6a 02                	push   $0x2
f01024de:	68 00 00 40 00       	push   $0x400000
f01024e3:	53                   	push   %ebx
f01024e4:	50                   	push   %eax
f01024e5:	e8 e2 f4 ff ff       	call   f01019cc <page_insert>
f01024ea:	83 c4 10             	add    $0x10,%esp
f01024ed:	85 c0                	test   %eax,%eax
f01024ef:	78 19                	js     f010250a <mem_init+0xaa8>
f01024f1:	68 e8 71 10 f0       	push   $0xf01071e8
f01024f6:	68 9b 75 10 f0       	push   $0xf010759b
f01024fb:	68 60 04 00 00       	push   $0x460
f0102500:	68 75 75 10 f0       	push   $0xf0107575
f0102505:	e8 36 db ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010250a:	6a 02                	push   $0x2
f010250c:	68 00 10 00 00       	push   $0x1000
f0102511:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102514:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f010251a:	e8 ad f4 ff ff       	call   f01019cc <page_insert>
f010251f:	83 c4 10             	add    $0x10,%esp
f0102522:	85 c0                	test   %eax,%eax
f0102524:	74 19                	je     f010253f <mem_init+0xadd>
f0102526:	68 20 72 10 f0       	push   $0xf0107220
f010252b:	68 9b 75 10 f0       	push   $0xf010759b
f0102530:	68 63 04 00 00       	push   $0x463
f0102535:	68 75 75 10 f0       	push   $0xf0107575
f010253a:	e8 01 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010253f:	83 ec 04             	sub    $0x4,%esp
f0102542:	6a 00                	push   $0x0
f0102544:	68 00 10 00 00       	push   $0x1000
f0102549:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f010254f:	e8 49 f2 ff ff       	call   f010179d <pgdir_walk>
f0102554:	83 c4 10             	add    $0x10,%esp
f0102557:	f6 00 04             	testb  $0x4,(%eax)
f010255a:	74 19                	je     f0102575 <mem_init+0xb13>
f010255c:	68 5c 72 10 f0       	push   $0xf010725c
f0102561:	68 9b 75 10 f0       	push   $0xf010759b
f0102566:	68 64 04 00 00       	push   $0x464
f010256b:	68 75 75 10 f0       	push   $0xf0107575
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102575:	8b 3d ac 8e 23 f0    	mov    0xf0238eac,%edi
f010257b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102580:	89 f8                	mov    %edi,%eax
f0102582:	e8 9f e8 ff ff       	call   f0100e26 <check_va2pa>
f0102587:	89 c1                	mov    %eax,%ecx
f0102589:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010258c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010258f:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0102595:	c1 f8 03             	sar    $0x3,%eax
f0102598:	c1 e0 0c             	shl    $0xc,%eax
f010259b:	39 c1                	cmp    %eax,%ecx
f010259d:	74 19                	je     f01025b8 <mem_init+0xb56>
f010259f:	68 94 72 10 f0       	push   $0xf0107294
f01025a4:	68 9b 75 10 f0       	push   $0xf010759b
f01025a9:	68 67 04 00 00       	push   $0x467
f01025ae:	68 75 75 10 f0       	push   $0xf0107575
f01025b3:	e8 88 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025b8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025bd:	89 f8                	mov    %edi,%eax
f01025bf:	e8 62 e8 ff ff       	call   f0100e26 <check_va2pa>
f01025c4:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01025c7:	74 19                	je     f01025e2 <mem_init+0xb80>
f01025c9:	68 c0 72 10 f0       	push   $0xf01072c0
f01025ce:	68 9b 75 10 f0       	push   $0xf010759b
f01025d3:	68 68 04 00 00       	push   $0x468
f01025d8:	68 75 75 10 f0       	push   $0xf0107575
f01025dd:	e8 5e da ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01025e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025e5:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f01025ea:	74 19                	je     f0102605 <mem_init+0xba3>
f01025ec:	68 bb 77 10 f0       	push   $0xf01077bb
f01025f1:	68 9b 75 10 f0       	push   $0xf010759b
f01025f6:	68 6a 04 00 00       	push   $0x46a
f01025fb:	68 75 75 10 f0       	push   $0xf0107575
f0102600:	e8 3b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102605:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010260a:	74 19                	je     f0102625 <mem_init+0xbc3>
f010260c:	68 cc 77 10 f0       	push   $0xf01077cc
f0102611:	68 9b 75 10 f0       	push   $0xf010759b
f0102616:	68 6b 04 00 00       	push   $0x46b
f010261b:	68 75 75 10 f0       	push   $0xf0107575
f0102620:	e8 1b da ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102625:	83 ec 0c             	sub    $0xc,%esp
f0102628:	6a 00                	push   $0x0
f010262a:	e8 bb ec ff ff       	call   f01012ea <page_alloc>
f010262f:	83 c4 10             	add    $0x10,%esp
f0102632:	85 c0                	test   %eax,%eax
f0102634:	74 04                	je     f010263a <mem_init+0xbd8>
f0102636:	39 c6                	cmp    %eax,%esi
f0102638:	74 19                	je     f0102653 <mem_init+0xbf1>
f010263a:	68 f0 72 10 f0       	push   $0xf01072f0
f010263f:	68 9b 75 10 f0       	push   $0xf010759b
f0102644:	68 6e 04 00 00       	push   $0x46e
f0102649:	68 75 75 10 f0       	push   $0xf0107575
f010264e:	e8 ed d9 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102653:	83 ec 08             	sub    $0x8,%esp
f0102656:	6a 00                	push   $0x0
f0102658:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f010265e:	e8 20 f3 ff ff       	call   f0101983 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102663:	8b 3d ac 8e 23 f0    	mov    0xf0238eac,%edi
f0102669:	ba 00 00 00 00       	mov    $0x0,%edx
f010266e:	89 f8                	mov    %edi,%eax
f0102670:	e8 b1 e7 ff ff       	call   f0100e26 <check_va2pa>
f0102675:	83 c4 10             	add    $0x10,%esp
f0102678:	83 f8 ff             	cmp    $0xffffffff,%eax
f010267b:	74 19                	je     f0102696 <mem_init+0xc34>
f010267d:	68 14 73 10 f0       	push   $0xf0107314
f0102682:	68 9b 75 10 f0       	push   $0xf010759b
f0102687:	68 72 04 00 00       	push   $0x472
f010268c:	68 75 75 10 f0       	push   $0xf0107575
f0102691:	e8 aa d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102696:	ba 00 10 00 00       	mov    $0x1000,%edx
f010269b:	89 f8                	mov    %edi,%eax
f010269d:	e8 84 e7 ff ff       	call   f0100e26 <check_va2pa>
f01026a2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01026a5:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f01026ab:	c1 fa 03             	sar    $0x3,%edx
f01026ae:	c1 e2 0c             	shl    $0xc,%edx
f01026b1:	39 d0                	cmp    %edx,%eax
f01026b3:	74 19                	je     f01026ce <mem_init+0xc6c>
f01026b5:	68 c0 72 10 f0       	push   $0xf01072c0
f01026ba:	68 9b 75 10 f0       	push   $0xf010759b
f01026bf:	68 73 04 00 00       	push   $0x473
f01026c4:	68 75 75 10 f0       	push   $0xf0107575
f01026c9:	e8 72 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01026ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026d1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01026d6:	74 19                	je     f01026f1 <mem_init+0xc8f>
f01026d8:	68 72 77 10 f0       	push   $0xf0107772
f01026dd:	68 9b 75 10 f0       	push   $0xf010759b
f01026e2:	68 74 04 00 00       	push   $0x474
f01026e7:	68 75 75 10 f0       	push   $0xf0107575
f01026ec:	e8 4f d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026f1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026f6:	74 19                	je     f0102711 <mem_init+0xcaf>
f01026f8:	68 cc 77 10 f0       	push   $0xf01077cc
f01026fd:	68 9b 75 10 f0       	push   $0xf010759b
f0102702:	68 75 04 00 00       	push   $0x475
f0102707:	68 75 75 10 f0       	push   $0xf0107575
f010270c:	e8 2f d9 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102711:	83 ec 08             	sub    $0x8,%esp
f0102714:	68 00 10 00 00       	push   $0x1000
f0102719:	57                   	push   %edi
f010271a:	e8 64 f2 ff ff       	call   f0101983 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010271f:	8b 3d ac 8e 23 f0    	mov    0xf0238eac,%edi
f0102725:	ba 00 00 00 00       	mov    $0x0,%edx
f010272a:	89 f8                	mov    %edi,%eax
f010272c:	e8 f5 e6 ff ff       	call   f0100e26 <check_va2pa>
f0102731:	83 c4 10             	add    $0x10,%esp
f0102734:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102737:	74 19                	je     f0102752 <mem_init+0xcf0>
f0102739:	68 14 73 10 f0       	push   $0xf0107314
f010273e:	68 9b 75 10 f0       	push   $0xf010759b
f0102743:	68 79 04 00 00       	push   $0x479
f0102748:	68 75 75 10 f0       	push   $0xf0107575
f010274d:	e8 ee d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102752:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102757:	89 f8                	mov    %edi,%eax
f0102759:	e8 c8 e6 ff ff       	call   f0100e26 <check_va2pa>
f010275e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102761:	74 19                	je     f010277c <mem_init+0xd1a>
f0102763:	68 38 73 10 f0       	push   $0xf0107338
f0102768:	68 9b 75 10 f0       	push   $0xf010759b
f010276d:	68 7a 04 00 00       	push   $0x47a
f0102772:	68 75 75 10 f0       	push   $0xf0107575
f0102777:	e8 c4 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010277c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010277f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102784:	74 19                	je     f010279f <mem_init+0xd3d>
f0102786:	68 dd 77 10 f0       	push   $0xf01077dd
f010278b:	68 9b 75 10 f0       	push   $0xf010759b
f0102790:	68 7b 04 00 00       	push   $0x47b
f0102795:	68 75 75 10 f0       	push   $0xf0107575
f010279a:	e8 a1 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010279f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01027a4:	74 19                	je     f01027bf <mem_init+0xd5d>
f01027a6:	68 cc 77 10 f0       	push   $0xf01077cc
f01027ab:	68 9b 75 10 f0       	push   $0xf010759b
f01027b0:	68 7c 04 00 00       	push   $0x47c
f01027b5:	68 75 75 10 f0       	push   $0xf0107575
f01027ba:	e8 81 d8 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01027bf:	83 ec 0c             	sub    $0xc,%esp
f01027c2:	6a 00                	push   $0x0
f01027c4:	e8 21 eb ff ff       	call   f01012ea <page_alloc>
f01027c9:	83 c4 10             	add    $0x10,%esp
f01027cc:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01027cf:	75 04                	jne    f01027d5 <mem_init+0xd73>
f01027d1:	85 c0                	test   %eax,%eax
f01027d3:	75 19                	jne    f01027ee <mem_init+0xd8c>
f01027d5:	68 60 73 10 f0       	push   $0xf0107360
f01027da:	68 9b 75 10 f0       	push   $0xf010759b
f01027df:	68 7f 04 00 00       	push   $0x47f
f01027e4:	68 75 75 10 f0       	push   $0xf0107575
f01027e9:	e8 52 d8 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01027ee:	83 ec 0c             	sub    $0xc,%esp
f01027f1:	6a 00                	push   $0x0
f01027f3:	e8 f2 ea ff ff       	call   f01012ea <page_alloc>
f01027f8:	83 c4 10             	add    $0x10,%esp
f01027fb:	85 c0                	test   %eax,%eax
f01027fd:	74 19                	je     f0102818 <mem_init+0xdb6>
f01027ff:	68 20 77 10 f0       	push   $0xf0107720
f0102804:	68 9b 75 10 f0       	push   $0xf010759b
f0102809:	68 82 04 00 00       	push   $0x482
f010280e:	68 75 75 10 f0       	push   $0xf0107575
f0102813:	e8 28 d8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102818:	8b 0d ac 8e 23 f0    	mov    0xf0238eac,%ecx
f010281e:	8b 11                	mov    (%ecx),%edx
f0102820:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102826:	89 d8                	mov    %ebx,%eax
f0102828:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f010282e:	c1 f8 03             	sar    $0x3,%eax
f0102831:	c1 e0 0c             	shl    $0xc,%eax
f0102834:	39 c2                	cmp    %eax,%edx
f0102836:	74 19                	je     f0102851 <mem_init+0xdef>
f0102838:	68 70 70 10 f0       	push   $0xf0107070
f010283d:	68 9b 75 10 f0       	push   $0xf010759b
f0102842:	68 85 04 00 00       	push   $0x485
f0102847:	68 75 75 10 f0       	push   $0xf0107575
f010284c:	e8 ef d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102851:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102857:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010285c:	74 19                	je     f0102877 <mem_init+0xe15>
f010285e:	68 83 77 10 f0       	push   $0xf0107783
f0102863:	68 9b 75 10 f0       	push   $0xf010759b
f0102868:	68 87 04 00 00       	push   $0x487
f010286d:	68 75 75 10 f0       	push   $0xf0107575
f0102872:	e8 c9 d7 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102877:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010287d:	83 ec 0c             	sub    $0xc,%esp
f0102880:	53                   	push   %ebx
f0102881:	e8 d5 ec ff ff       	call   f010155b <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102886:	83 c4 0c             	add    $0xc,%esp
f0102889:	6a 01                	push   $0x1
f010288b:	68 00 10 40 00       	push   $0x401000
f0102890:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f0102896:	e8 02 ef ff ff       	call   f010179d <pgdir_walk>
f010289b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010289e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01028a1:	8b 0d ac 8e 23 f0    	mov    0xf0238eac,%ecx
f01028a7:	8b 51 04             	mov    0x4(%ecx),%edx
f01028aa:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028b0:	8b 3d a8 8e 23 f0    	mov    0xf0238ea8,%edi
f01028b6:	89 d0                	mov    %edx,%eax
f01028b8:	c1 e8 0c             	shr    $0xc,%eax
f01028bb:	83 c4 10             	add    $0x10,%esp
f01028be:	39 f8                	cmp    %edi,%eax
f01028c0:	72 15                	jb     f01028d7 <mem_init+0xe75>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028c2:	52                   	push   %edx
f01028c3:	68 c0 67 10 f0       	push   $0xf01067c0
f01028c8:	68 8e 04 00 00       	push   $0x48e
f01028cd:	68 75 75 10 f0       	push   $0xf0107575
f01028d2:	e8 69 d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028d7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01028dd:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01028e0:	74 19                	je     f01028fb <mem_init+0xe99>
f01028e2:	68 ee 77 10 f0       	push   $0xf01077ee
f01028e7:	68 9b 75 10 f0       	push   $0xf010759b
f01028ec:	68 8f 04 00 00       	push   $0x48f
f01028f1:	68 75 75 10 f0       	push   $0xf0107575
f01028f6:	e8 45 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01028fb:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102902:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102908:	89 d8                	mov    %ebx,%eax
f010290a:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0102910:	c1 f8 03             	sar    $0x3,%eax
f0102913:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102916:	89 c2                	mov    %eax,%edx
f0102918:	c1 ea 0c             	shr    $0xc,%edx
f010291b:	39 d7                	cmp    %edx,%edi
f010291d:	77 12                	ja     f0102931 <mem_init+0xecf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010291f:	50                   	push   %eax
f0102920:	68 c0 67 10 f0       	push   $0xf01067c0
f0102925:	6a 56                	push   $0x56
f0102927:	68 81 75 10 f0       	push   $0xf0107581
f010292c:	e8 0f d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102931:	83 ec 04             	sub    $0x4,%esp
f0102934:	68 00 10 00 00       	push   $0x1000
f0102939:	68 ff 00 00 00       	push   $0xff
f010293e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102943:	50                   	push   %eax
f0102944:	e8 a3 30 00 00       	call   f01059ec <memset>
	page_free(pp0);
f0102949:	89 1c 24             	mov    %ebx,(%esp)
f010294c:	e8 0a ec ff ff       	call   f010155b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102951:	83 c4 0c             	add    $0xc,%esp
f0102954:	6a 01                	push   $0x1
f0102956:	6a 00                	push   $0x0
f0102958:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f010295e:	e8 3a ee ff ff       	call   f010179d <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102963:	89 da                	mov    %ebx,%edx
f0102965:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f010296b:	c1 fa 03             	sar    $0x3,%edx
f010296e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102971:	89 d0                	mov    %edx,%eax
f0102973:	c1 e8 0c             	shr    $0xc,%eax
f0102976:	83 c4 10             	add    $0x10,%esp
f0102979:	3b 05 a8 8e 23 f0    	cmp    0xf0238ea8,%eax
f010297f:	72 12                	jb     f0102993 <mem_init+0xf31>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102981:	52                   	push   %edx
f0102982:	68 c0 67 10 f0       	push   $0xf01067c0
f0102987:	6a 56                	push   $0x56
f0102989:	68 81 75 10 f0       	push   $0xf0107581
f010298e:	e8 ad d6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102993:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102999:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010299c:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01029a3:	75 13                	jne    f01029b8 <mem_init+0xf56>
f01029a5:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f01029ab:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f01029b1:	8b 08                	mov    (%eax),%ecx
f01029b3:	83 e1 01             	and    $0x1,%ecx
f01029b6:	74 19                	je     f01029d1 <mem_init+0xf6f>
f01029b8:	68 06 78 10 f0       	push   $0xf0107806
f01029bd:	68 9b 75 10 f0       	push   $0xf010759b
f01029c2:	68 99 04 00 00       	push   $0x499
f01029c7:	68 75 75 10 f0       	push   $0xf0107575
f01029cc:	e8 6f d6 ff ff       	call   f0100040 <_panic>
f01029d1:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01029d4:	39 c2                	cmp    %eax,%edx
f01029d6:	75 d9                	jne    f01029b1 <mem_init+0xf4f>
f01029d8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01029db:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f01029e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01029e6:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f01029ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029ef:	a3 64 82 23 f0       	mov    %eax,0xf0238264

	// free the pages we took
	page_free(pp0);
f01029f4:	83 ec 0c             	sub    $0xc,%esp
f01029f7:	53                   	push   %ebx
f01029f8:	e8 5e eb ff ff       	call   f010155b <page_free>
	page_free(pp1);
f01029fd:	83 c4 04             	add    $0x4,%esp
f0102a00:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102a03:	e8 53 eb ff ff       	call   f010155b <page_free>
	page_free(pp2);
f0102a08:	89 34 24             	mov    %esi,(%esp)
f0102a0b:	e8 4b eb ff ff       	call   f010155b <page_free>

	cprintf("check_page() succeeded!\n");
f0102a10:	c7 04 24 1d 78 10 f0 	movl   $0xf010781d,(%esp)
f0102a17:	e8 78 14 00 00       	call   f0103e94 <cprintf>
	char* addr;
	int i;
	pp = pp0 = 0;

	// Allocate two single pages
	pp =  page_alloc(0);
f0102a1c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a23:	e8 c2 e8 ff ff       	call   f01012ea <page_alloc>
f0102a28:	89 c3                	mov    %eax,%ebx
	pp0 = page_alloc(0);
f0102a2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a31:	e8 b4 e8 ff ff       	call   f01012ea <page_alloc>
f0102a36:	89 c6                	mov    %eax,%esi
	assert(pp != 0);
f0102a38:	83 c4 10             	add    $0x10,%esp
f0102a3b:	85 db                	test   %ebx,%ebx
f0102a3d:	75 19                	jne    f0102a58 <mem_init+0xff6>
f0102a3f:	68 36 78 10 f0       	push   $0xf0107836
f0102a44:	68 9b 75 10 f0       	push   $0xf010759b
f0102a49:	68 c6 04 00 00       	push   $0x4c6
f0102a4e:	68 75 75 10 f0       	push   $0xf0107575
f0102a53:	e8 e8 d5 ff ff       	call   f0100040 <_panic>
	assert(pp0 != 0);
f0102a58:	85 c0                	test   %eax,%eax
f0102a5a:	75 19                	jne    f0102a75 <mem_init+0x1013>
f0102a5c:	68 3e 78 10 f0       	push   $0xf010783e
f0102a61:	68 9b 75 10 f0       	push   $0xf010759b
f0102a66:	68 c7 04 00 00       	push   $0x4c7
f0102a6b:	68 75 75 10 f0       	push   $0xf0107575
f0102a70:	e8 cb d5 ff ff       	call   f0100040 <_panic>
	assert(pp != pp0);
f0102a75:	39 c3                	cmp    %eax,%ebx
f0102a77:	75 19                	jne    f0102a92 <mem_init+0x1030>
f0102a79:	68 47 78 10 f0       	push   $0xf0107847
f0102a7e:	68 9b 75 10 f0       	push   $0xf010759b
f0102a83:	68 c8 04 00 00       	push   $0x4c8
f0102a88:	68 75 75 10 f0       	push   $0xf0107575
f0102a8d:	e8 ae d5 ff ff       	call   f0100040 <_panic>


	// Free pp and assign four continuous pages
	page_free(pp);
f0102a92:	83 ec 0c             	sub    $0xc,%esp
f0102a95:	53                   	push   %ebx
f0102a96:	e8 c0 ea ff ff       	call   f010155b <page_free>
	pp = page_alloc_npages(0, 4);
f0102a9b:	83 c4 08             	add    $0x8,%esp
f0102a9e:	6a 04                	push   $0x4
f0102aa0:	6a 00                	push   $0x0
f0102aa2:	e8 28 ea ff ff       	call   f01014cf <page_alloc_npages>
f0102aa7:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 4));
f0102aa9:	ba 04 00 00 00       	mov    $0x4,%edx
f0102aae:	e8 e5 e2 ff ff       	call   f0100d98 <check_continuous>
f0102ab3:	83 c4 10             	add    $0x10,%esp
f0102ab6:	85 c0                	test   %eax,%eax
f0102ab8:	75 19                	jne    f0102ad3 <mem_init+0x1071>
f0102aba:	68 51 78 10 f0       	push   $0xf0107851
f0102abf:	68 9b 75 10 f0       	push   $0xf010759b
f0102ac4:	68 ce 04 00 00       	push   $0x4ce
f0102ac9:	68 75 75 10 f0       	push   $0xf0107575
f0102ace:	e8 6d d5 ff ff       	call   f0100040 <_panic>

	// Free four continuous pages
	assert(!page_free_npages(pp, 4));
f0102ad3:	83 ec 08             	sub    $0x8,%esp
f0102ad6:	6a 04                	push   $0x4
f0102ad8:	53                   	push   %ebx
f0102ad9:	e8 40 ea ff ff       	call   f010151e <page_free_npages>
f0102ade:	83 c4 10             	add    $0x10,%esp
f0102ae1:	85 c0                	test   %eax,%eax
f0102ae3:	74 19                	je     f0102afe <mem_init+0x109c>
f0102ae5:	68 69 78 10 f0       	push   $0xf0107869
f0102aea:	68 9b 75 10 f0       	push   $0xf010759b
f0102aef:	68 d1 04 00 00       	push   $0x4d1
f0102af4:	68 75 75 10 f0       	push   $0xf0107575
f0102af9:	e8 42 d5 ff ff       	call   f0100040 <_panic>

	// Free pp and assign eight continuous pages
	pp = page_alloc_npages(0, 8);
f0102afe:	83 ec 08             	sub    $0x8,%esp
f0102b01:	6a 08                	push   $0x8
f0102b03:	6a 00                	push   $0x0
f0102b05:	e8 c5 e9 ff ff       	call   f01014cf <page_alloc_npages>
f0102b0a:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 8));
f0102b0c:	ba 08 00 00 00       	mov    $0x8,%edx
f0102b11:	e8 82 e2 ff ff       	call   f0100d98 <check_continuous>
f0102b16:	83 c4 10             	add    $0x10,%esp
f0102b19:	85 c0                	test   %eax,%eax
f0102b1b:	75 19                	jne    f0102b36 <mem_init+0x10d4>
f0102b1d:	68 82 78 10 f0       	push   $0xf0107882
f0102b22:	68 9b 75 10 f0       	push   $0xf010759b
f0102b27:	68 d5 04 00 00       	push   $0x4d5
f0102b2c:	68 75 75 10 f0       	push   $0xf0107575
f0102b31:	e8 0a d5 ff ff       	call   f0100040 <_panic>

	// Free four continuous pages
	assert(!page_free_npages(pp, 8));
f0102b36:	83 ec 08             	sub    $0x8,%esp
f0102b39:	6a 08                	push   $0x8
f0102b3b:	53                   	push   %ebx
f0102b3c:	e8 dd e9 ff ff       	call   f010151e <page_free_npages>
f0102b41:	83 c4 10             	add    $0x10,%esp
f0102b44:	85 c0                	test   %eax,%eax
f0102b46:	74 19                	je     f0102b61 <mem_init+0x10ff>
f0102b48:	68 9a 78 10 f0       	push   $0xf010789a
f0102b4d:	68 9b 75 10 f0       	push   $0xf010759b
f0102b52:	68 d8 04 00 00       	push   $0x4d8
f0102b57:	68 75 75 10 f0       	push   $0xf0107575
f0102b5c:	e8 df d4 ff ff       	call   f0100040 <_panic>


	// Free pp0 and assign four continuous zero pages
	page_free(pp0);
f0102b61:	83 ec 0c             	sub    $0xc,%esp
f0102b64:	56                   	push   %esi
f0102b65:	e8 f1 e9 ff ff       	call   f010155b <page_free>
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
f0102b6a:	83 c4 08             	add    $0x8,%esp
f0102b6d:	6a 04                	push   $0x4
f0102b6f:	6a 01                	push   $0x1
f0102b71:	e8 59 e9 ff ff       	call   f01014cf <page_alloc_npages>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b76:	89 c1                	mov    %eax,%ecx
f0102b78:	2b 0d b0 8e 23 f0    	sub    0xf0238eb0,%ecx
f0102b7e:	c1 f9 03             	sar    $0x3,%ecx
f0102b81:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b84:	89 ca                	mov    %ecx,%edx
f0102b86:	c1 ea 0c             	shr    $0xc,%edx
f0102b89:	83 c4 10             	add    $0x10,%esp
f0102b8c:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f0102b92:	72 12                	jb     f0102ba6 <mem_init+0x1144>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b94:	51                   	push   %ecx
f0102b95:	68 c0 67 10 f0       	push   $0xf01067c0
f0102b9a:	6a 56                	push   $0x56
f0102b9c:	68 81 75 10 f0       	push   $0xf0107581
f0102ba1:	e8 9a d4 ff ff       	call   f0100040 <_panic>
	addr = (char*)page2kva(pp0);

	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0102ba6:	80 b9 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%ecx)
f0102bad:	75 11                	jne    f0102bc0 <mem_init+0x115e>
f0102baf:	8d 91 01 00 00 f0    	lea    -0xfffffff(%ecx),%edx
f0102bb5:	81 e9 00 c0 ff 0f    	sub    $0xfffc000,%ecx
f0102bbb:	80 3a 00             	cmpb   $0x0,(%edx)
f0102bbe:	74 19                	je     f0102bd9 <mem_init+0x1177>
f0102bc0:	68 b3 78 10 f0       	push   $0xf01078b3
f0102bc5:	68 9b 75 10 f0       	push   $0xf010759b
f0102bca:	68 e2 04 00 00       	push   $0x4e2
f0102bcf:	68 75 75 10 f0       	push   $0xf0107575
f0102bd4:	e8 67 d4 ff ff       	call   f0100040 <_panic>
f0102bd9:	83 c2 01             	add    $0x1,%edx
	page_free(pp0);
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
	addr = (char*)page2kva(pp0);

	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
f0102bdc:	39 d1                	cmp    %edx,%ecx
f0102bde:	75 db                	jne    f0102bbb <mem_init+0x1159>
		assert(addr[i] == 0);
	}

	// Free pages
	assert(!page_free_npages(pp0, 4));
f0102be0:	83 ec 08             	sub    $0x8,%esp
f0102be3:	6a 04                	push   $0x4
f0102be5:	50                   	push   %eax
f0102be6:	e8 33 e9 ff ff       	call   f010151e <page_free_npages>
f0102beb:	83 c4 10             	add    $0x10,%esp
f0102bee:	85 c0                	test   %eax,%eax
f0102bf0:	74 19                	je     f0102c0b <mem_init+0x11a9>
f0102bf2:	68 c0 78 10 f0       	push   $0xf01078c0
f0102bf7:	68 9b 75 10 f0       	push   $0xf010759b
f0102bfc:	68 e6 04 00 00       	push   $0x4e6
f0102c01:	68 75 75 10 f0       	push   $0xf0107575
f0102c06:	e8 35 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_n_pages() succeeded!\n");
f0102c0b:	83 ec 0c             	sub    $0xc,%esp
f0102c0e:	68 da 78 10 f0       	push   $0xf01078da
f0102c13:	e8 7c 12 00 00       	call   f0103e94 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U);
f0102c18:	a1 b0 8e 23 f0       	mov    0xf0238eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c1d:	83 c4 10             	add    $0x10,%esp
f0102c20:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c25:	77 15                	ja     f0102c3c <mem_init+0x11da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c27:	50                   	push   %eax
f0102c28:	68 e4 67 10 f0       	push   $0xf01067e4
f0102c2d:	68 bd 00 00 00       	push   $0xbd
f0102c32:	68 75 75 10 f0       	push   $0xf0107575
f0102c37:	e8 04 d4 ff ff       	call   f0100040 <_panic>
f0102c3c:	8b 15 a8 8e 23 f0    	mov    0xf0238ea8,%edx
f0102c42:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102c49:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102c4f:	83 ec 08             	sub    $0x8,%esp
f0102c52:	6a 04                	push   $0x4
f0102c54:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c59:	50                   	push   %eax
f0102c5a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c5f:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f0102c64:	e8 1f ec ff ff       	call   f0101888 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U);
f0102c69:	a1 6c 82 23 f0       	mov    0xf023826c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c6e:	83 c4 10             	add    $0x10,%esp
f0102c71:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c76:	77 15                	ja     f0102c8d <mem_init+0x122b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c78:	50                   	push   %eax
f0102c79:	68 e4 67 10 f0       	push   $0xf01067e4
f0102c7e:	68 c6 00 00 00       	push   $0xc6
f0102c83:	68 75 75 10 f0       	push   $0xf0107575
f0102c88:	e8 b3 d3 ff ff       	call   f0100040 <_panic>
f0102c8d:	83 ec 08             	sub    $0x8,%esp
f0102c90:	6a 04                	push   $0x4
f0102c92:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c97:	50                   	push   %eax
f0102c98:	b9 00 00 02 00       	mov    $0x20000,%ecx
f0102c9d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102ca2:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f0102ca7:	e8 dc eb ff ff       	call   f0101888 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cac:	83 c4 10             	add    $0x10,%esp
f0102caf:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102cb4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cb9:	77 15                	ja     f0102cd0 <mem_init+0x126e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cbb:	50                   	push   %eax
f0102cbc:	68 e4 67 10 f0       	push   $0xf01067e4
f0102cc1:	68 d3 00 00 00       	push   $0xd3
f0102cc6:	68 75 75 10 f0       	push   $0xf0107575
f0102ccb:	e8 70 d3 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102cd0:	83 ec 08             	sub    $0x8,%esp
f0102cd3:	6a 02                	push   $0x2
f0102cd5:	68 00 70 11 00       	push   $0x117000
f0102cda:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cdf:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102ce4:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f0102ce9:	e8 9a eb ff ff       	call   f0101888 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, ~KERNBASE + 1, 0, PTE_W);
f0102cee:	83 c4 08             	add    $0x8,%esp
f0102cf1:	6a 02                	push   $0x2
f0102cf3:	6a 00                	push   $0x0
f0102cf5:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102cfa:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102cff:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f0102d04:	e8 7f eb ff ff       	call   f0101888 <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0102d09:	83 c4 08             	add    $0x8,%esp
f0102d0c:	6a 02                	push   $0x2
f0102d0e:	68 00 00 00 fe       	push   $0xfe000000
f0102d13:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0102d18:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0102d1d:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f0102d22:	e8 61 eb ff ff       	call   f0101888 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d27:	83 c4 10             	add    $0x10,%esp
f0102d2a:	b8 00 a0 23 f0       	mov    $0xf023a000,%eax
f0102d2f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d34:	0f 87 9f 06 00 00    	ja     f01033d9 <mem_init+0x1977>
f0102d3a:	eb 0c                	jmp    f0102d48 <mem_init+0x12e6>
	//
	// LAB 4: Your code here:
	uint32_t i;
	uint32_t per_stack_top = KSTACKTOP - KSTKSIZE;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir, per_stack_top, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_P | PTE_W);
f0102d3c:	89 d8                	mov    %ebx,%eax
f0102d3e:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d44:	77 1c                	ja     f0102d62 <mem_init+0x1300>
f0102d46:	eb 05                	jmp    f0102d4d <mem_init+0x12eb>
f0102d48:	b8 00 a0 23 f0       	mov    $0xf023a000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d4d:	50                   	push   %eax
f0102d4e:	68 e4 67 10 f0       	push   $0xf01067e4
f0102d53:	68 1a 01 00 00       	push   $0x11a
f0102d58:	68 75 75 10 f0       	push   $0xf0107575
f0102d5d:	e8 de d2 ff ff       	call   f0100040 <_panic>
f0102d62:	83 ec 08             	sub    $0x8,%esp
f0102d65:	6a 03                	push   $0x3
f0102d67:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102d6d:	50                   	push   %eax
f0102d6e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d73:	89 f2                	mov    %esi,%edx
f0102d75:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f0102d7a:	e8 09 eb ff ff       	call   f0101888 <boot_map_region>
		per_stack_top -= (KSTKSIZE + KSTKGAP);
f0102d7f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102d85:	81 c3 00 80 00 00    	add    $0x8000,%ebx
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uint32_t i;
	uint32_t per_stack_top = KSTACKTOP - KSTKSIZE;
	for (i = 0; i < NCPU; i++) {
f0102d8b:	83 c4 10             	add    $0x10,%esp
f0102d8e:	81 fe 00 80 b7 ef    	cmp    $0xefb78000,%esi
f0102d94:	75 a6                	jne    f0102d3c <mem_init+0x12da>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d96:	8b 3d ac 8e 23 f0    	mov    0xf0238eac,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0102d9c:	a1 a8 8e 23 f0       	mov    0xf0238ea8,%eax
f0102da1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102da4:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dab:	8b 35 b0 8e 23 f0    	mov    0xf0238eb0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102db1:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102db4:	bb 00 00 00 00       	mov    $0x0,%ebx

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102db9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102dbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102dc1:	75 10                	jne    f0102dd3 <mem_init+0x1371>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102dc3:	8b 35 6c 82 23 f0    	mov    0xf023826c,%esi
f0102dc9:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102dcc:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102dd1:	eb 5c                	jmp    f0102e2f <mem_init+0x13cd>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dd3:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102dd9:	89 f8                	mov    %edi,%eax
f0102ddb:	e8 46 e0 ff ff       	call   f0100e26 <check_va2pa>
f0102de0:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102de7:	77 15                	ja     f0102dfe <mem_init+0x139c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102de9:	56                   	push   %esi
f0102dea:	68 e4 67 10 f0       	push   $0xf01067e4
f0102def:	68 d6 03 00 00       	push   $0x3d6
f0102df4:	68 75 75 10 f0       	push   $0xf0107575
f0102df9:	e8 42 d2 ff ff       	call   f0100040 <_panic>
f0102dfe:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102e05:	39 c2                	cmp    %eax,%edx
f0102e07:	74 19                	je     f0102e22 <mem_init+0x13c0>
f0102e09:	68 84 73 10 f0       	push   $0xf0107384
f0102e0e:	68 9b 75 10 f0       	push   $0xf010759b
f0102e13:	68 d6 03 00 00       	push   $0x3d6
f0102e18:	68 75 75 10 f0       	push   $0xf0107575
f0102e1d:	e8 1e d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e28:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102e2b:	77 a6                	ja     f0102dd3 <mem_init+0x1371>
f0102e2d:	eb 94                	jmp    f0102dc3 <mem_init+0x1361>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e2f:	89 da                	mov    %ebx,%edx
f0102e31:	89 f8                	mov    %edi,%eax
f0102e33:	e8 ee df ff ff       	call   f0100e26 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e38:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102e3f:	77 15                	ja     f0102e56 <mem_init+0x13f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e41:	56                   	push   %esi
f0102e42:	68 e4 67 10 f0       	push   $0xf01067e4
f0102e47:	68 db 03 00 00       	push   $0x3db
f0102e4c:	68 75 75 10 f0       	push   $0xf0107575
f0102e51:	e8 ea d1 ff ff       	call   f0100040 <_panic>
f0102e56:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102e5d:	39 c2                	cmp    %eax,%edx
f0102e5f:	74 19                	je     f0102e7a <mem_init+0x1418>
f0102e61:	68 b8 73 10 f0       	push   $0xf01073b8
f0102e66:	68 9b 75 10 f0       	push   $0xf010759b
f0102e6b:	68 db 03 00 00       	push   $0x3db
f0102e70:	68 75 75 10 f0       	push   $0xf0107575
f0102e75:	e8 c6 d1 ff ff       	call   f0100040 <_panic>
f0102e7a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e80:	81 fb 00 00 c2 ee    	cmp    $0xeec20000,%ebx
f0102e86:	75 a7                	jne    f0102e2f <mem_init+0x13cd>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e88:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102e8b:	c1 e6 0c             	shl    $0xc,%esi
f0102e8e:	85 f6                	test   %esi,%esi
f0102e90:	74 40                	je     f0102ed2 <mem_init+0x1470>
f0102e92:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e97:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102e9d:	89 f8                	mov    %edi,%eax
f0102e9f:	e8 82 df ff ff       	call   f0100e26 <check_va2pa>
f0102ea4:	39 d8                	cmp    %ebx,%eax
f0102ea6:	74 19                	je     f0102ec1 <mem_init+0x145f>
f0102ea8:	68 ec 73 10 f0       	push   $0xf01073ec
f0102ead:	68 9b 75 10 f0       	push   $0xf010759b
f0102eb2:	68 df 03 00 00       	push   $0x3df
f0102eb7:	68 75 75 10 f0       	push   $0xf0107575
f0102ebc:	e8 7f d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ec1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ec7:	39 de                	cmp    %ebx,%esi
f0102ec9:	77 cc                	ja     f0102e97 <mem_init+0x1435>
f0102ecb:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
f0102ed0:	eb 05                	jmp    f0102ed7 <mem_init+0x1475>
f0102ed2:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0102ed7:	89 da                	mov    %ebx,%edx
f0102ed9:	89 f8                	mov    %edi,%eax
f0102edb:	e8 46 df ff ff       	call   f0100e26 <check_va2pa>
f0102ee0:	39 d8                	cmp    %ebx,%eax
f0102ee2:	74 19                	je     f0102efd <mem_init+0x149b>
f0102ee4:	68 f6 78 10 f0       	push   $0xf01078f6
f0102ee9:	68 9b 75 10 f0       	push   $0xf010759b
f0102eee:	68 e3 03 00 00       	push   $0x3e3
f0102ef3:	68 75 75 10 f0       	push   $0xf0107575
f0102ef8:	e8 43 d1 ff ff       	call   f0100040 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0102efd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f03:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0102f09:	75 cc                	jne    f0102ed7 <mem_init+0x1475>
f0102f0b:	be 00 a0 23 f0       	mov    $0xf023a000,%esi
f0102f10:	c7 45 cc 00 80 bf ef 	movl   $0xefbf8000,-0x34(%ebp)
f0102f17:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102f1a:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102f20:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102f23:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f25:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102f28:	05 00 80 40 20       	add    $0x20408000,%eax
f0102f2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f30:	89 da                	mov    %ebx,%edx
f0102f32:	89 f8                	mov    %edi,%eax
f0102f34:	e8 ed de ff ff       	call   f0100e26 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f39:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102f3f:	77 15                	ja     f0102f56 <mem_init+0x14f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f41:	56                   	push   %esi
f0102f42:	68 e4 67 10 f0       	push   $0xf01067e4
f0102f47:	68 eb 03 00 00       	push   $0x3eb
f0102f4c:	68 75 75 10 f0       	push   $0xf0107575
f0102f51:	e8 ea d0 ff ff       	call   f0100040 <_panic>
f0102f56:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f59:	8d 94 0b 00 a0 23 f0 	lea    -0xfdc6000(%ebx,%ecx,1),%edx
f0102f60:	39 c2                	cmp    %eax,%edx
f0102f62:	74 19                	je     f0102f7d <mem_init+0x151b>
f0102f64:	68 14 74 10 f0       	push   $0xf0107414
f0102f69:	68 9b 75 10 f0       	push   $0xf010759b
f0102f6e:	68 eb 03 00 00       	push   $0x3eb
f0102f73:	68 75 75 10 f0       	push   $0xf0107575
f0102f78:	e8 c3 d0 ff ff       	call   f0100040 <_panic>
f0102f7d:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f83:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102f86:	75 a8                	jne    f0102f30 <mem_init+0x14ce>
f0102f88:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102f8b:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102f91:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102f94:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f96:	89 da                	mov    %ebx,%edx
f0102f98:	89 f8                	mov    %edi,%eax
f0102f9a:	e8 87 de ff ff       	call   f0100e26 <check_va2pa>
f0102f9f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102fa2:	74 19                	je     f0102fbd <mem_init+0x155b>
f0102fa4:	68 5c 74 10 f0       	push   $0xf010745c
f0102fa9:	68 9b 75 10 f0       	push   $0xf010759b
f0102fae:	68 ed 03 00 00       	push   $0x3ed
f0102fb3:	68 75 75 10 f0       	push   $0xf0107575
f0102fb8:	e8 83 d0 ff ff       	call   f0100040 <_panic>
f0102fbd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102fc3:	39 f3                	cmp    %esi,%ebx
f0102fc5:	75 cf                	jne    f0102f96 <mem_init+0x1534>
f0102fc7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102fca:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102fd1:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102fd8:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102fde:	b8 00 a0 27 f0       	mov    $0xf027a000,%eax
f0102fe3:	39 f0                	cmp    %esi,%eax
f0102fe5:	0f 85 2c ff ff ff    	jne    f0102f17 <mem_init+0x14b5>
f0102feb:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102ff0:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102ff6:	83 fa 03             	cmp    $0x3,%edx
f0102ff9:	77 1f                	ja     f010301a <mem_init+0x15b8>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102ffb:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102fff:	75 7e                	jne    f010307f <mem_init+0x161d>
f0103001:	68 11 79 10 f0       	push   $0xf0107911
f0103006:	68 9b 75 10 f0       	push   $0xf010759b
f010300b:	68 f7 03 00 00       	push   $0x3f7
f0103010:	68 75 75 10 f0       	push   $0xf0107575
f0103015:	e8 26 d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010301a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010301f:	76 3f                	jbe    f0103060 <mem_init+0x15fe>
				assert(pgdir[i] & PTE_P);
f0103021:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103024:	f6 c2 01             	test   $0x1,%dl
f0103027:	75 19                	jne    f0103042 <mem_init+0x15e0>
f0103029:	68 11 79 10 f0       	push   $0xf0107911
f010302e:	68 9b 75 10 f0       	push   $0xf010759b
f0103033:	68 fb 03 00 00       	push   $0x3fb
f0103038:	68 75 75 10 f0       	push   $0xf0107575
f010303d:	e8 fe cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103042:	f6 c2 02             	test   $0x2,%dl
f0103045:	75 38                	jne    f010307f <mem_init+0x161d>
f0103047:	68 22 79 10 f0       	push   $0xf0107922
f010304c:	68 9b 75 10 f0       	push   $0xf010759b
f0103051:	68 fc 03 00 00       	push   $0x3fc
f0103056:	68 75 75 10 f0       	push   $0xf0107575
f010305b:	e8 e0 cf ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103060:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0103064:	74 19                	je     f010307f <mem_init+0x161d>
f0103066:	68 33 79 10 f0       	push   $0xf0107933
f010306b:	68 9b 75 10 f0       	push   $0xf010759b
f0103070:	68 fe 03 00 00       	push   $0x3fe
f0103075:	68 75 75 10 f0       	push   $0xf0107575
f010307a:	e8 c1 cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010307f:	83 c0 01             	add    $0x1,%eax
f0103082:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103087:	0f 85 63 ff ff ff    	jne    f0102ff0 <mem_init+0x158e>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010308d:	83 ec 0c             	sub    $0xc,%esp
f0103090:	68 80 74 10 f0       	push   $0xf0107480
f0103095:	e8 fa 0d 00 00       	call   f0103e94 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010309a:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010309f:	83 c4 10             	add    $0x10,%esp
f01030a2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030a7:	77 15                	ja     f01030be <mem_init+0x165c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030a9:	50                   	push   %eax
f01030aa:	68 e4 67 10 f0       	push   $0xf01067e4
f01030af:	68 ec 00 00 00       	push   $0xec
f01030b4:	68 75 75 10 f0       	push   $0xf0107575
f01030b9:	e8 82 cf ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01030be:	05 00 00 00 10       	add    $0x10000000,%eax
f01030c3:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01030c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01030cb:	e8 43 de ff ff       	call   f0100f13 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01030d0:	0f 20 c0             	mov    %cr0,%eax
f01030d3:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01030d6:	0d 23 00 05 80       	or     $0x80050023,%eax
f01030db:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030de:	83 ec 0c             	sub    $0xc,%esp
f01030e1:	6a 00                	push   $0x0
f01030e3:	e8 02 e2 ff ff       	call   f01012ea <page_alloc>
f01030e8:	89 c3                	mov    %eax,%ebx
f01030ea:	83 c4 10             	add    $0x10,%esp
f01030ed:	85 c0                	test   %eax,%eax
f01030ef:	75 19                	jne    f010310a <mem_init+0x16a8>
f01030f1:	68 75 76 10 f0       	push   $0xf0107675
f01030f6:	68 9b 75 10 f0       	push   $0xf010759b
f01030fb:	68 f6 04 00 00       	push   $0x4f6
f0103100:	68 75 75 10 f0       	push   $0xf0107575
f0103105:	e8 36 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010310a:	83 ec 0c             	sub    $0xc,%esp
f010310d:	6a 00                	push   $0x0
f010310f:	e8 d6 e1 ff ff       	call   f01012ea <page_alloc>
f0103114:	89 c7                	mov    %eax,%edi
f0103116:	83 c4 10             	add    $0x10,%esp
f0103119:	85 c0                	test   %eax,%eax
f010311b:	75 19                	jne    f0103136 <mem_init+0x16d4>
f010311d:	68 8b 76 10 f0       	push   $0xf010768b
f0103122:	68 9b 75 10 f0       	push   $0xf010759b
f0103127:	68 f7 04 00 00       	push   $0x4f7
f010312c:	68 75 75 10 f0       	push   $0xf0107575
f0103131:	e8 0a cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103136:	83 ec 0c             	sub    $0xc,%esp
f0103139:	6a 00                	push   $0x0
f010313b:	e8 aa e1 ff ff       	call   f01012ea <page_alloc>
f0103140:	89 c6                	mov    %eax,%esi
f0103142:	83 c4 10             	add    $0x10,%esp
f0103145:	85 c0                	test   %eax,%eax
f0103147:	75 19                	jne    f0103162 <mem_init+0x1700>
f0103149:	68 a1 76 10 f0       	push   $0xf01076a1
f010314e:	68 9b 75 10 f0       	push   $0xf010759b
f0103153:	68 f8 04 00 00       	push   $0x4f8
f0103158:	68 75 75 10 f0       	push   $0xf0107575
f010315d:	e8 de ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103162:	83 ec 0c             	sub    $0xc,%esp
f0103165:	53                   	push   %ebx
f0103166:	e8 f0 e3 ff ff       	call   f010155b <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010316b:	89 f8                	mov    %edi,%eax
f010316d:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0103173:	c1 f8 03             	sar    $0x3,%eax
f0103176:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103179:	89 c2                	mov    %eax,%edx
f010317b:	c1 ea 0c             	shr    $0xc,%edx
f010317e:	83 c4 10             	add    $0x10,%esp
f0103181:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f0103187:	72 12                	jb     f010319b <mem_init+0x1739>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103189:	50                   	push   %eax
f010318a:	68 c0 67 10 f0       	push   $0xf01067c0
f010318f:	6a 56                	push   $0x56
f0103191:	68 81 75 10 f0       	push   $0xf0107581
f0103196:	e8 a5 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010319b:	83 ec 04             	sub    $0x4,%esp
f010319e:	68 00 10 00 00       	push   $0x1000
f01031a3:	6a 01                	push   $0x1
f01031a5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031aa:	50                   	push   %eax
f01031ab:	e8 3c 28 00 00       	call   f01059ec <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01031b0:	89 f0                	mov    %esi,%eax
f01031b2:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f01031b8:	c1 f8 03             	sar    $0x3,%eax
f01031bb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031be:	89 c2                	mov    %eax,%edx
f01031c0:	c1 ea 0c             	shr    $0xc,%edx
f01031c3:	83 c4 10             	add    $0x10,%esp
f01031c6:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f01031cc:	72 12                	jb     f01031e0 <mem_init+0x177e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031ce:	50                   	push   %eax
f01031cf:	68 c0 67 10 f0       	push   $0xf01067c0
f01031d4:	6a 56                	push   $0x56
f01031d6:	68 81 75 10 f0       	push   $0xf0107581
f01031db:	e8 60 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031e0:	83 ec 04             	sub    $0x4,%esp
f01031e3:	68 00 10 00 00       	push   $0x1000
f01031e8:	6a 02                	push   $0x2
f01031ea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031ef:	50                   	push   %eax
f01031f0:	e8 f7 27 00 00       	call   f01059ec <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031f5:	6a 02                	push   $0x2
f01031f7:	68 00 10 00 00       	push   $0x1000
f01031fc:	57                   	push   %edi
f01031fd:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f0103203:	e8 c4 e7 ff ff       	call   f01019cc <page_insert>
	assert(pp1->pp_ref == 1);
f0103208:	83 c4 20             	add    $0x20,%esp
f010320b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103210:	74 19                	je     f010322b <mem_init+0x17c9>
f0103212:	68 72 77 10 f0       	push   $0xf0107772
f0103217:	68 9b 75 10 f0       	push   $0xf010759b
f010321c:	68 fd 04 00 00       	push   $0x4fd
f0103221:	68 75 75 10 f0       	push   $0xf0107575
f0103226:	e8 15 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010322b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103232:	01 01 01 
f0103235:	74 19                	je     f0103250 <mem_init+0x17ee>
f0103237:	68 a0 74 10 f0       	push   $0xf01074a0
f010323c:	68 9b 75 10 f0       	push   $0xf010759b
f0103241:	68 fe 04 00 00       	push   $0x4fe
f0103246:	68 75 75 10 f0       	push   $0xf0107575
f010324b:	e8 f0 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103250:	6a 02                	push   $0x2
f0103252:	68 00 10 00 00       	push   $0x1000
f0103257:	56                   	push   %esi
f0103258:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f010325e:	e8 69 e7 ff ff       	call   f01019cc <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103263:	83 c4 10             	add    $0x10,%esp
f0103266:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010326d:	02 02 02 
f0103270:	74 19                	je     f010328b <mem_init+0x1829>
f0103272:	68 c4 74 10 f0       	push   $0xf01074c4
f0103277:	68 9b 75 10 f0       	push   $0xf010759b
f010327c:	68 00 05 00 00       	push   $0x500
f0103281:	68 75 75 10 f0       	push   $0xf0107575
f0103286:	e8 b5 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010328b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103290:	74 19                	je     f01032ab <mem_init+0x1849>
f0103292:	68 94 77 10 f0       	push   $0xf0107794
f0103297:	68 9b 75 10 f0       	push   $0xf010759b
f010329c:	68 01 05 00 00       	push   $0x501
f01032a1:	68 75 75 10 f0       	push   $0xf0107575
f01032a6:	e8 95 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01032ab:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01032b0:	74 19                	je     f01032cb <mem_init+0x1869>
f01032b2:	68 dd 77 10 f0       	push   $0xf01077dd
f01032b7:	68 9b 75 10 f0       	push   $0xf010759b
f01032bc:	68 02 05 00 00       	push   $0x502
f01032c1:	68 75 75 10 f0       	push   $0xf0107575
f01032c6:	e8 75 cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01032cb:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01032d2:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01032d5:	89 f0                	mov    %esi,%eax
f01032d7:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f01032dd:	c1 f8 03             	sar    $0x3,%eax
f01032e0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032e3:	89 c2                	mov    %eax,%edx
f01032e5:	c1 ea 0c             	shr    $0xc,%edx
f01032e8:	3b 15 a8 8e 23 f0    	cmp    0xf0238ea8,%edx
f01032ee:	72 12                	jb     f0103302 <mem_init+0x18a0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032f0:	50                   	push   %eax
f01032f1:	68 c0 67 10 f0       	push   $0xf01067c0
f01032f6:	6a 56                	push   $0x56
f01032f8:	68 81 75 10 f0       	push   $0xf0107581
f01032fd:	e8 3e cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103302:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103309:	03 03 03 
f010330c:	74 19                	je     f0103327 <mem_init+0x18c5>
f010330e:	68 e8 74 10 f0       	push   $0xf01074e8
f0103313:	68 9b 75 10 f0       	push   $0xf010759b
f0103318:	68 04 05 00 00       	push   $0x504
f010331d:	68 75 75 10 f0       	push   $0xf0107575
f0103322:	e8 19 cd ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103327:	83 ec 08             	sub    $0x8,%esp
f010332a:	68 00 10 00 00       	push   $0x1000
f010332f:	ff 35 ac 8e 23 f0    	pushl  0xf0238eac
f0103335:	e8 49 e6 ff ff       	call   f0101983 <page_remove>
	assert(pp2->pp_ref == 0);
f010333a:	83 c4 10             	add    $0x10,%esp
f010333d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103342:	74 19                	je     f010335d <mem_init+0x18fb>
f0103344:	68 cc 77 10 f0       	push   $0xf01077cc
f0103349:	68 9b 75 10 f0       	push   $0xf010759b
f010334e:	68 06 05 00 00       	push   $0x506
f0103353:	68 75 75 10 f0       	push   $0xf0107575
f0103358:	e8 e3 cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010335d:	8b 0d ac 8e 23 f0    	mov    0xf0238eac,%ecx
f0103363:	8b 11                	mov    (%ecx),%edx
f0103365:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010336b:	89 d8                	mov    %ebx,%eax
f010336d:	2b 05 b0 8e 23 f0    	sub    0xf0238eb0,%eax
f0103373:	c1 f8 03             	sar    $0x3,%eax
f0103376:	c1 e0 0c             	shl    $0xc,%eax
f0103379:	39 c2                	cmp    %eax,%edx
f010337b:	74 19                	je     f0103396 <mem_init+0x1934>
f010337d:	68 70 70 10 f0       	push   $0xf0107070
f0103382:	68 9b 75 10 f0       	push   $0xf010759b
f0103387:	68 09 05 00 00       	push   $0x509
f010338c:	68 75 75 10 f0       	push   $0xf0107575
f0103391:	e8 aa cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103396:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010339c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01033a1:	74 19                	je     f01033bc <mem_init+0x195a>
f01033a3:	68 83 77 10 f0       	push   $0xf0107783
f01033a8:	68 9b 75 10 f0       	push   $0xf010759b
f01033ad:	68 0b 05 00 00       	push   $0x50b
f01033b2:	68 75 75 10 f0       	push   $0xf0107575
f01033b7:	e8 84 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01033bc:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01033c2:	83 ec 0c             	sub    $0xc,%esp
f01033c5:	53                   	push   %ebx
f01033c6:	e8 90 e1 ff ff       	call   f010155b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01033cb:	c7 04 24 14 75 10 f0 	movl   $0xf0107514,(%esp)
f01033d2:	e8 bd 0a 00 00       	call   f0103e94 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01033d7:	eb 30                	jmp    f0103409 <mem_init+0x19a7>
	//
	// LAB 4: Your code here:
	uint32_t i;
	uint32_t per_stack_top = KSTACKTOP - KSTKSIZE;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir, per_stack_top, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_P | PTE_W);
f01033d9:	83 ec 08             	sub    $0x8,%esp
f01033dc:	6a 03                	push   $0x3
f01033de:	68 00 a0 23 00       	push   $0x23a000
f01033e3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01033e8:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01033ed:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
f01033f2:	e8 91 e4 ff ff       	call   f0101888 <boot_map_region>
f01033f7:	bb 00 20 24 f0       	mov    $0xf0242000,%ebx
f01033fc:	83 c4 10             	add    $0x10,%esp
		per_stack_top -= (KSTKSIZE + KSTKGAP);
f01033ff:	be 00 80 be ef       	mov    $0xefbe8000,%esi
f0103404:	e9 33 f9 ff ff       	jmp    f0102d3c <mem_init+0x12da>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103409:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010340c:	5b                   	pop    %ebx
f010340d:	5e                   	pop    %esi
f010340e:	5f                   	pop    %edi
f010340f:	5d                   	pop    %ebp
f0103410:	c3                   	ret    

f0103411 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103411:	55                   	push   %ebp
f0103412:	89 e5                	mov    %esp,%ebp
f0103414:	57                   	push   %edi
f0103415:	56                   	push   %esi
f0103416:	53                   	push   %ebx
f0103417:	83 ec 1c             	sub    $0x1c,%esp
f010341a:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f010341d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103420:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103425:	89 c1                	mov    %eax,%ecx
f0103427:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f010342a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010342d:	03 45 10             	add    0x10(%ebp),%eax
f0103430:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103435:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010343a:	89 c2                	mov    %eax,%edx
f010343c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	size_t i;
	int auth = perm | PTE_P;
f010343f:	8b 75 14             	mov    0x14(%ebp),%esi
f0103442:	83 ce 01             	or     $0x1,%esi
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f0103445:	89 c8                	mov    %ecx,%eax
f0103447:	39 d0                	cmp    %edx,%eax
f0103449:	73 6f                	jae    f01034ba <user_mem_check+0xa9>
		if (i >= ULIM) {
f010344b:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103450:	77 15                	ja     f0103467 <user_mem_check+0x56>
f0103452:	89 c3                	mov    %eax,%ebx
f0103454:	eb 21                	jmp    f0103477 <user_mem_check+0x66>
f0103456:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010345c:	76 19                	jbe    f0103477 <user_mem_check+0x66>

	size_t i;
	int auth = perm | PTE_P;
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f010345e:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f0103461:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f0103465:	eb 03                	jmp    f010346a <user_mem_check+0x59>
		if (i >= ULIM) {
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
f0103467:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010346a:	89 1d 5c 82 23 f0    	mov    %ebx,0xf023825c
			return -E_FAULT;
f0103470:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103475:	eb 48                	jmp    f01034bf <user_mem_check+0xae>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)i, 0);
f0103477:	83 ec 04             	sub    $0x4,%esp
f010347a:	6a 00                	push   $0x0
f010347c:	53                   	push   %ebx
f010347d:	ff 77 64             	pushl  0x64(%edi)
f0103480:	e8 18 e3 ff ff       	call   f010179d <pgdir_walk>
		if (!(pte && (*pte & auth) == auth)) {
f0103485:	83 c4 10             	add    $0x10,%esp
f0103488:	85 c0                	test   %eax,%eax
f010348a:	74 08                	je     f0103494 <user_mem_check+0x83>
f010348c:	89 f2                	mov    %esi,%edx
f010348e:	23 10                	and    (%eax),%edx
f0103490:	39 d6                	cmp    %edx,%esi
f0103492:	74 14                	je     f01034a8 <user_mem_check+0x97>
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
f0103494:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f0103497:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f010349b:	89 1d 5c 82 23 f0    	mov    %ebx,0xf023825c
			return -E_FAULT;
f01034a1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034a6:	eb 17                	jmp    f01034bf <user_mem_check+0xae>

	size_t i;
	int auth = perm | PTE_P;
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f01034a8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034ae:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01034b1:	77 a3                	ja     f0103456 <user_mem_check+0x45>
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
			return -E_FAULT;
		}
	}

	return 0;
f01034b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01034b8:	eb 05                	jmp    f01034bf <user_mem_check+0xae>
f01034ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034c2:	5b                   	pop    %ebx
f01034c3:	5e                   	pop    %esi
f01034c4:	5f                   	pop    %edi
f01034c5:	5d                   	pop    %ebp
f01034c6:	c3                   	ret    

f01034c7 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01034c7:	55                   	push   %ebp
f01034c8:	89 e5                	mov    %esp,%ebp
f01034ca:	53                   	push   %ebx
f01034cb:	83 ec 04             	sub    $0x4,%esp
f01034ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01034d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01034d4:	83 c8 04             	or     $0x4,%eax
f01034d7:	50                   	push   %eax
f01034d8:	ff 75 10             	pushl  0x10(%ebp)
f01034db:	ff 75 0c             	pushl  0xc(%ebp)
f01034de:	53                   	push   %ebx
f01034df:	e8 2d ff ff ff       	call   f0103411 <user_mem_check>
f01034e4:	83 c4 10             	add    $0x10,%esp
f01034e7:	85 c0                	test   %eax,%eax
f01034e9:	79 21                	jns    f010350c <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01034eb:	83 ec 04             	sub    $0x4,%esp
f01034ee:	ff 35 5c 82 23 f0    	pushl  0xf023825c
f01034f4:	ff 73 48             	pushl  0x48(%ebx)
f01034f7:	68 40 75 10 f0       	push   $0xf0107540
f01034fc:	e8 93 09 00 00       	call   f0103e94 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103501:	89 1c 24             	mov    %ebx,(%esp)
f0103504:	e8 83 06 00 00       	call   f0103b8c <env_destroy>
f0103509:	83 c4 10             	add    $0x10,%esp
	}
}
f010350c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010350f:	c9                   	leave  
f0103510:	c3                   	ret    

f0103511 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103511:	55                   	push   %ebp
f0103512:	89 e5                	mov    %esp,%ebp
f0103514:	57                   	push   %edi
f0103515:	56                   	push   %esi
f0103516:	53                   	push   %ebx
f0103517:	83 ec 1c             	sub    $0x1c,%esp
f010351a:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f010351c:	89 d0                	mov    %edx,%eax
f010351e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103523:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f0103526:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010352d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0103533:	39 f0                	cmp    %esi,%eax
f0103535:	73 5e                	jae    f0103595 <region_alloc+0x84>
f0103537:	89 c3                	mov    %eax,%ebx
		if (!(tmp = page_alloc(0))) {
f0103539:	83 ec 0c             	sub    $0xc,%esp
f010353c:	6a 00                	push   $0x0
f010353e:	e8 a7 dd ff ff       	call   f01012ea <page_alloc>
f0103543:	83 c4 10             	add    $0x10,%esp
f0103546:	85 c0                	test   %eax,%eax
f0103548:	75 17                	jne    f0103561 <region_alloc+0x50>
			panic("Execute region_alloc(...) failed. Out of memory.\n");
f010354a:	83 ec 04             	sub    $0x4,%esp
f010354d:	68 44 79 10 f0       	push   $0xf0107944
f0103552:	68 33 01 00 00       	push   $0x133
f0103557:	68 09 7a 10 f0       	push   $0xf0107a09
f010355c:	e8 df ca ff ff       	call   f0100040 <_panic>
		} else {
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
f0103561:	6a 06                	push   $0x6
f0103563:	53                   	push   %ebx
f0103564:	50                   	push   %eax
f0103565:	ff 77 64             	pushl  0x64(%edi)
f0103568:	e8 5f e4 ff ff       	call   f01019cc <page_insert>
f010356d:	83 c4 10             	add    $0x10,%esp
f0103570:	85 c0                	test   %eax,%eax
f0103572:	74 17                	je     f010358b <region_alloc+0x7a>
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
f0103574:	83 ec 04             	sub    $0x4,%esp
f0103577:	68 78 79 10 f0       	push   $0xf0107978
f010357c:	68 36 01 00 00       	push   $0x136
f0103581:	68 09 7a 10 f0       	push   $0xf0107a09
f0103586:	e8 b5 ca ff ff       	call   f0100040 <_panic>
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f010358b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103591:	39 de                	cmp    %ebx,%esi
f0103593:	77 a4                	ja     f0103539 <region_alloc+0x28>
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
			}
		}
	}
	e->env_cur_brk = start;
f0103595:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103598:	89 47 60             	mov    %eax,0x60(%edi)
}
f010359b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010359e:	5b                   	pop    %ebx
f010359f:	5e                   	pop    %esi
f01035a0:	5f                   	pop    %edi
f01035a1:	5d                   	pop    %ebp
f01035a2:	c3                   	ret    

f01035a3 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01035a3:	55                   	push   %ebp
f01035a4:	89 e5                	mov    %esp,%ebp
f01035a6:	56                   	push   %esi
f01035a7:	53                   	push   %ebx
f01035a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01035ab:	85 c0                	test   %eax,%eax
f01035ad:	75 1a                	jne    f01035c9 <envid2env+0x26>
		*env_store = curenv;
f01035af:	e8 b3 2a 00 00       	call   f0106067 <cpunum>
f01035b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b7:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01035bd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01035c0:	89 02                	mov    %eax,(%edx)
		return 0;
f01035c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01035c7:	eb 72                	jmp    f010363b <envid2env+0x98>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01035c9:	89 c3                	mov    %eax,%ebx
f01035cb:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01035d1:	c1 e3 07             	shl    $0x7,%ebx
f01035d4:	03 1d 6c 82 23 f0    	add    0xf023826c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01035da:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01035de:	74 05                	je     f01035e5 <envid2env+0x42>
f01035e0:	3b 43 48             	cmp    0x48(%ebx),%eax
f01035e3:	74 10                	je     f01035f5 <envid2env+0x52>
		*env_store = 0;
f01035e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01035ee:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035f3:	eb 46                	jmp    f010363b <envid2env+0x98>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01035f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01035f9:	74 36                	je     f0103631 <envid2env+0x8e>
f01035fb:	e8 67 2a 00 00       	call   f0106067 <cpunum>
f0103600:	6b c0 74             	imul   $0x74,%eax,%eax
f0103603:	3b 98 28 90 23 f0    	cmp    -0xfdc6fd8(%eax),%ebx
f0103609:	74 26                	je     f0103631 <envid2env+0x8e>
f010360b:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010360e:	e8 54 2a 00 00       	call   f0106067 <cpunum>
f0103613:	6b c0 74             	imul   $0x74,%eax,%eax
f0103616:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010361c:	3b 70 48             	cmp    0x48(%eax),%esi
f010361f:	74 10                	je     f0103631 <envid2env+0x8e>
		*env_store = 0;
f0103621:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103624:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010362a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010362f:	eb 0a                	jmp    f010363b <envid2env+0x98>
	}

	*env_store = e;
f0103631:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103634:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103636:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010363b:	5b                   	pop    %ebx
f010363c:	5e                   	pop    %esi
f010363d:	5d                   	pop    %ebp
f010363e:	c3                   	ret    

f010363f <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010363f:	55                   	push   %ebp
f0103640:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103642:	b8 00 13 12 f0       	mov    $0xf0121300,%eax
f0103647:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010364a:	b8 23 00 00 00       	mov    $0x23,%eax
f010364f:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103651:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103653:	b8 10 00 00 00       	mov    $0x10,%eax
f0103658:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010365a:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010365c:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010365e:	ea 65 36 10 f0 08 00 	ljmp   $0x8,$0xf0103665
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103665:	b8 00 00 00 00       	mov    $0x0,%eax
f010366a:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010366d:	5d                   	pop    %ebp
f010366e:	c3                   	ret    

f010366f <env_init>:
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (size_t i = 0; i < NENV - 1; i++) {
		envs[i].env_link = &envs[i + 1];
f010366f:	8b 0d 6c 82 23 f0    	mov    0xf023826c,%ecx
f0103675:	8d 81 80 00 00 00    	lea    0x80(%ecx),%eax
f010367b:	8d 91 00 00 02 00    	lea    0x20000(%ecx),%edx
f0103681:	89 40 c4             	mov    %eax,-0x3c(%eax)
		envs[i].env_id = 0;
f0103684:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
		envs[i].env_status = ENV_FREE;
f010368b:	c7 40 d4 00 00 00 00 	movl   $0x0,-0x2c(%eax)
f0103692:	83 e8 80             	sub    $0xffffff80,%eax
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (size_t i = 0; i < NENV - 1; i++) {
f0103695:	39 d0                	cmp    %edx,%eax
f0103697:	75 e8                	jne    f0103681 <env_init+0x12>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103699:	55                   	push   %ebp
f010369a:	89 e5                	mov    %esp,%ebp
	for (size_t i = 0; i < NENV - 1; i++) {
		envs[i].env_link = &envs[i + 1];
		envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
	}
	envs[NENV - 1].env_link = NULL;
f010369c:	c7 81 c4 ff 01 00 00 	movl   $0x0,0x1ffc4(%ecx)
f01036a3:	00 00 00 
	envs[NENV - 1].env_id = 0;
f01036a6:	c7 81 c8 ff 01 00 00 	movl   $0x0,0x1ffc8(%ecx)
f01036ad:	00 00 00 
	envs[NENV - 1].env_status = ENV_FREE;
f01036b0:	c7 81 d4 ff 01 00 00 	movl   $0x0,0x1ffd4(%ecx)
f01036b7:	00 00 00 
	env_free_list = envs;
f01036ba:	89 0d 70 82 23 f0    	mov    %ecx,0xf0238270

	// Per-CPU part of the initialization
	env_init_percpu();
f01036c0:	e8 7a ff ff ff       	call   f010363f <env_init_percpu>
}
f01036c5:	5d                   	pop    %ebp
f01036c6:	c3                   	ret    

f01036c7 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01036c7:	55                   	push   %ebp
f01036c8:	89 e5                	mov    %esp,%ebp
f01036ca:	53                   	push   %ebx
f01036cb:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01036ce:	8b 1d 70 82 23 f0    	mov    0xf0238270,%ebx
f01036d4:	85 db                	test   %ebx,%ebx
f01036d6:	0f 84 70 01 00 00    	je     f010384c <env_alloc+0x185>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01036dc:	83 ec 0c             	sub    $0xc,%esp
f01036df:	6a 01                	push   $0x1
f01036e1:	e8 04 dc ff ff       	call   f01012ea <page_alloc>
f01036e6:	83 c4 10             	add    $0x10,%esp
f01036e9:	85 c0                	test   %eax,%eax
f01036eb:	0f 84 62 01 00 00    	je     f0103853 <env_alloc+0x18c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01036f1:	89 c2                	mov    %eax,%edx
f01036f3:	2b 15 b0 8e 23 f0    	sub    0xf0238eb0,%edx
f01036f9:	c1 fa 03             	sar    $0x3,%edx
f01036fc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036ff:	89 d1                	mov    %edx,%ecx
f0103701:	c1 e9 0c             	shr    $0xc,%ecx
f0103704:	3b 0d a8 8e 23 f0    	cmp    0xf0238ea8,%ecx
f010370a:	72 12                	jb     f010371e <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010370c:	52                   	push   %edx
f010370d:	68 c0 67 10 f0       	push   $0xf01067c0
f0103712:	6a 56                	push   $0x56
f0103714:	68 81 75 10 f0       	push   $0xf0107581
f0103719:	e8 22 c9 ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pte_t *)page2kva(p);
f010371e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103724:	89 53 64             	mov    %edx,0x64(%ebx)
	p->pp_ref++;
f0103727:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010372c:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	// memmove(e->env_pgdir + PDX(UTOP), kern_pgdir + PDX(UTOP), NPDENTRIES - PDX(UTOP));
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f0103731:	8b 15 ac 8e 23 f0    	mov    0xf0238eac,%edx
f0103737:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010373a:	8b 53 64             	mov    0x64(%ebx),%edx
f010373d:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103740:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
	e->env_pgdir = (pte_t *)page2kva(p);
	p->pp_ref++;
	// memmove(e->env_pgdir + PDX(UTOP), kern_pgdir + PDX(UTOP), NPDENTRIES - PDX(UTOP));
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103743:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103748:	75 e7                	jne    f0103731 <env_alloc+0x6a>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010374a:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010374d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103752:	77 15                	ja     f0103769 <env_alloc+0xa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103754:	50                   	push   %eax
f0103755:	68 e4 67 10 f0       	push   $0xf01067e4
f010375a:	68 cb 00 00 00       	push   $0xcb
f010375f:	68 09 7a 10 f0       	push   $0xf0107a09
f0103764:	e8 d7 c8 ff ff       	call   f0100040 <_panic>
f0103769:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010376f:	83 ca 05             	or     $0x5,%edx
f0103772:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103778:	8b 43 48             	mov    0x48(%ebx),%eax
f010377b:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103780:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103785:	ba 00 10 00 00       	mov    $0x1000,%edx
f010378a:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010378d:	89 da                	mov    %ebx,%edx
f010378f:	2b 15 6c 82 23 f0    	sub    0xf023826c,%edx
f0103795:	c1 fa 07             	sar    $0x7,%edx
f0103798:	09 d0                	or     %edx,%eax
f010379a:	89 43 48             	mov    %eax,0x48(%ebx)
	// cprintf("env_alloc env_id = %d\n", e->env_id);

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010379d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037a0:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01037a3:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01037aa:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01037b1:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	e->env_cur_brk = 0;
f01037b8:	c7 43 60 00 00 00 00 	movl   $0x0,0x60(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01037bf:	83 ec 04             	sub    $0x4,%esp
f01037c2:	6a 44                	push   $0x44
f01037c4:	6a 00                	push   $0x0
f01037c6:	53                   	push   %ebx
f01037c7:	e8 20 22 00 00       	call   f01059ec <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01037cc:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01037d2:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01037d8:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01037de:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01037e5:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01037eb:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01037f2:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01037f9:	8b 43 44             	mov    0x44(%ebx),%eax
f01037fc:	a3 70 82 23 f0       	mov    %eax,0xf0238270
	*newenv_store = e;
f0103801:	8b 45 08             	mov    0x8(%ebp),%eax
f0103804:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103806:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103809:	e8 59 28 00 00       	call   f0106067 <cpunum>
f010380e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103811:	83 c4 10             	add    $0x10,%esp
f0103814:	ba 00 00 00 00       	mov    $0x0,%edx
f0103819:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f0103820:	74 11                	je     f0103833 <env_alloc+0x16c>
f0103822:	e8 40 28 00 00       	call   f0106067 <cpunum>
f0103827:	6b c0 74             	imul   $0x74,%eax,%eax
f010382a:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103830:	8b 50 48             	mov    0x48(%eax),%edx
f0103833:	83 ec 04             	sub    $0x4,%esp
f0103836:	53                   	push   %ebx
f0103837:	52                   	push   %edx
f0103838:	68 14 7a 10 f0       	push   $0xf0107a14
f010383d:	e8 52 06 00 00       	call   f0103e94 <cprintf>
	return 0;
f0103842:	83 c4 10             	add    $0x10,%esp
f0103845:	b8 00 00 00 00       	mov    $0x0,%eax
f010384a:	eb 0c                	jmp    f0103858 <env_alloc+0x191>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010384c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103851:	eb 05                	jmp    f0103858 <env_alloc+0x191>
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103853:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010385b:	c9                   	leave  
f010385c:	c3                   	ret    

f010385d <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010385d:	55                   	push   %ebp
f010385e:	89 e5                	mov    %esp,%ebp
f0103860:	57                   	push   %edi
f0103861:	56                   	push   %esi
f0103862:	53                   	push   %ebx
f0103863:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *env;
	int err = env_alloc(&env, 0);
f0103866:	6a 00                	push   $0x0
f0103868:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010386b:	50                   	push   %eax
f010386c:	e8 56 fe ff ff       	call   f01036c7 <env_alloc>
	if (err) {
f0103871:	83 c4 10             	add    $0x10,%esp
f0103874:	85 c0                	test   %eax,%eax
f0103876:	74 3c                	je     f01038b4 <env_create+0x57>
		if (err == -E_NO_MEM) {
f0103878:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010387b:	75 17                	jne    f0103894 <env_create+0x37>
			panic("env_create failed. env_alloc E_NO_MEM.\n");
f010387d:	83 ec 04             	sub    $0x4,%esp
f0103880:	68 b4 79 10 f0       	push   $0xf01079b4
f0103885:	68 a1 01 00 00       	push   $0x1a1
f010388a:	68 09 7a 10 f0       	push   $0xf0107a09
f010388f:	e8 ac c7 ff ff       	call   f0100040 <_panic>
		} else if (err == -E_NO_FREE_ENV) {
f0103894:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0103897:	0f 85 0c 01 00 00    	jne    f01039a9 <env_create+0x14c>
			panic("env_create failed. env_alloc E_NO_FREE_ENV.\n");
f010389d:	83 ec 04             	sub    $0x4,%esp
f01038a0:	68 dc 79 10 f0       	push   $0xf01079dc
f01038a5:	68 a3 01 00 00       	push   $0x1a3
f01038aa:	68 09 7a 10 f0       	push   $0xf0107a09
f01038af:	e8 8c c7 ff ff       	call   f0100040 <_panic>
		}
	} else {
		load_icode(env, binary, size);
f01038b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *ELFHDR = (struct Elf *) binary;

	if (ELFHDR->e_magic != ELF_MAGIC) {
f01038b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01038ba:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01038c0:	74 17                	je     f01038d9 <env_create+0x7c>
		panic("Invalid ELF.\n");
f01038c2:	83 ec 04             	sub    $0x4,%esp
f01038c5:	68 29 7a 10 f0       	push   $0xf0107a29
f01038ca:	68 77 01 00 00       	push   $0x177
f01038cf:	68 09 7a 10 f0       	push   $0xf0107a09
f01038d4:	e8 67 c7 ff ff       	call   f0100040 <_panic>
	}

	lcr3(PADDR(e->env_pgdir));
f01038d9:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038e1:	77 15                	ja     f01038f8 <env_create+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038e3:	50                   	push   %eax
f01038e4:	68 e4 67 10 f0       	push   $0xf01067e4
f01038e9:	68 7a 01 00 00       	push   $0x17a
f01038ee:	68 09 7a 10 f0       	push   $0xf0107a09
f01038f3:	e8 48 c7 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01038f8:	05 00 00 00 10       	add    $0x10000000,%eax
f01038fd:	0f 22 d8             	mov    %eax,%cr3
	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
f0103900:	8b 45 08             	mov    0x8(%ebp),%eax
f0103903:	89 c3                	mov    %eax,%ebx
f0103905:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103908:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f010390c:	c1 e6 05             	shl    $0x5,%esi
f010390f:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++) {
f0103911:	39 f3                	cmp    %esi,%ebx
f0103913:	73 48                	jae    f010395d <env_create+0x100>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103915:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103918:	75 3c                	jne    f0103956 <env_create+0xf9>
			// cprintf("mem = %d  file = %d\n", ph->p_memsz, ph->p_filesz);
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010391a:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010391d:	8b 53 08             	mov    0x8(%ebx),%edx
f0103920:	89 f8                	mov    %edi,%eax
f0103922:	e8 ea fb ff ff       	call   f0103511 <region_alloc>
			// lcr3(PADDR(e->env_pgdir));
			memmove((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
f0103927:	83 ec 04             	sub    $0x4,%esp
f010392a:	ff 73 10             	pushl  0x10(%ebx)
f010392d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103930:	03 43 04             	add    0x4(%ebx),%eax
f0103933:	50                   	push   %eax
f0103934:	ff 73 08             	pushl  0x8(%ebx)
f0103937:	e8 fd 20 00 00       	call   f0105a39 <memmove>
			memset((void *)(ph->p_va + ph->p_filesz), 0, (ph->p_memsz - ph->p_filesz));
f010393c:	8b 43 10             	mov    0x10(%ebx),%eax
f010393f:	83 c4 0c             	add    $0xc,%esp
f0103942:	8b 53 14             	mov    0x14(%ebx),%edx
f0103945:	29 c2                	sub    %eax,%edx
f0103947:	52                   	push   %edx
f0103948:	6a 00                	push   $0x0
f010394a:	03 43 08             	add    0x8(%ebx),%eax
f010394d:	50                   	push   %eax
f010394e:	e8 99 20 00 00       	call   f01059ec <memset>
f0103953:	83 c4 10             	add    $0x10,%esp
	}

	lcr3(PADDR(e->env_pgdir));
	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++) {
f0103956:	83 c3 20             	add    $0x20,%ebx
f0103959:	39 de                	cmp    %ebx,%esi
f010395b:	77 b8                	ja     f0103915 <env_create+0xb8>
			memmove((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
			memset((void *)(ph->p_va + ph->p_filesz), 0, (ph->p_memsz - ph->p_filesz));
			// lcr3(PADDR(kern_pgdir));
		}
	}
	lcr3(PADDR(kern_pgdir));
f010395d:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103962:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103967:	77 15                	ja     f010397e <env_create+0x121>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103969:	50                   	push   %eax
f010396a:	68 e4 67 10 f0       	push   $0xf01067e4
f010396f:	68 87 01 00 00       	push   $0x187
f0103974:	68 09 7a 10 f0       	push   $0xf0107a09
f0103979:	e8 c2 c6 ff ff       	call   f0100040 <_panic>
f010397e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103983:	0f 22 d8             	mov    %eax,%cr3

	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103986:	8b 45 08             	mov    0x8(%ebp),%eax
f0103989:	8b 40 18             	mov    0x18(%eax),%eax
f010398c:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010398f:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103994:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103999:	89 f8                	mov    %edi,%eax
f010399b:	e8 71 fb ff ff       	call   f0103511 <region_alloc>
		} else if (err == -E_NO_FREE_ENV) {
			panic("env_create failed. env_alloc E_NO_FREE_ENV.\n");
		}
	} else {
		load_icode(env, binary, size);
		env->env_type = type;
f01039a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039a3:	8b 55 10             	mov    0x10(%ebp),%edx
f01039a6:	89 50 50             	mov    %edx,0x50(%eax)
	}
}
f01039a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01039ac:	5b                   	pop    %ebx
f01039ad:	5e                   	pop    %esi
f01039ae:	5f                   	pop    %edi
f01039af:	5d                   	pop    %ebp
f01039b0:	c3                   	ret    

f01039b1 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01039b1:	55                   	push   %ebp
f01039b2:	89 e5                	mov    %esp,%ebp
f01039b4:	57                   	push   %edi
f01039b5:	56                   	push   %esi
f01039b6:	53                   	push   %ebx
f01039b7:	83 ec 1c             	sub    $0x1c,%esp
f01039ba:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01039bd:	e8 a5 26 00 00       	call   f0106067 <cpunum>
f01039c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01039c5:	39 b8 28 90 23 f0    	cmp    %edi,-0xfdc6fd8(%eax)
f01039cb:	75 29                	jne    f01039f6 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01039cd:	a1 ac 8e 23 f0       	mov    0xf0238eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039d7:	77 15                	ja     f01039ee <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039d9:	50                   	push   %eax
f01039da:	68 e4 67 10 f0       	push   $0xf01067e4
f01039df:	68 b9 01 00 00       	push   $0x1b9
f01039e4:	68 09 7a 10 f0       	push   $0xf0107a09
f01039e9:	e8 52 c6 ff ff       	call   f0100040 <_panic>
f01039ee:	05 00 00 00 10       	add    $0x10000000,%eax
f01039f3:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01039f6:	8b 5f 48             	mov    0x48(%edi),%ebx
f01039f9:	e8 69 26 00 00       	call   f0106067 <cpunum>
f01039fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a01:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a06:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f0103a0d:	74 11                	je     f0103a20 <env_free+0x6f>
f0103a0f:	e8 53 26 00 00       	call   f0106067 <cpunum>
f0103a14:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a17:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103a1d:	8b 50 48             	mov    0x48(%eax),%edx
f0103a20:	83 ec 04             	sub    $0x4,%esp
f0103a23:	53                   	push   %ebx
f0103a24:	52                   	push   %edx
f0103a25:	68 37 7a 10 f0       	push   $0xf0107a37
f0103a2a:	e8 65 04 00 00       	call   f0103e94 <cprintf>
f0103a2f:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103a32:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103a39:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103a3c:	89 d0                	mov    %edx,%eax
f0103a3e:	c1 e0 02             	shl    $0x2,%eax
f0103a41:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103a44:	8b 47 64             	mov    0x64(%edi),%eax
f0103a47:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103a4a:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103a50:	0f 84 a8 00 00 00    	je     f0103afe <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103a56:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a5c:	89 f0                	mov    %esi,%eax
f0103a5e:	c1 e8 0c             	shr    $0xc,%eax
f0103a61:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a64:	39 05 a8 8e 23 f0    	cmp    %eax,0xf0238ea8
f0103a6a:	77 15                	ja     f0103a81 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a6c:	56                   	push   %esi
f0103a6d:	68 c0 67 10 f0       	push   $0xf01067c0
f0103a72:	68 c8 01 00 00       	push   $0x1c8
f0103a77:	68 09 7a 10 f0       	push   $0xf0107a09
f0103a7c:	e8 bf c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a81:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a84:	c1 e0 16             	shl    $0x16,%eax
f0103a87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a8a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103a8f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103a96:	01 
f0103a97:	74 17                	je     f0103ab0 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a99:	83 ec 08             	sub    $0x8,%esp
f0103a9c:	89 d8                	mov    %ebx,%eax
f0103a9e:	c1 e0 0c             	shl    $0xc,%eax
f0103aa1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103aa4:	50                   	push   %eax
f0103aa5:	ff 77 64             	pushl  0x64(%edi)
f0103aa8:	e8 d6 de ff ff       	call   f0101983 <page_remove>
f0103aad:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ab0:	83 c3 01             	add    $0x1,%ebx
f0103ab3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103ab9:	75 d4                	jne    f0103a8f <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103abb:	8b 47 64             	mov    0x64(%edi),%eax
f0103abe:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ac1:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ac8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103acb:	3b 05 a8 8e 23 f0    	cmp    0xf0238ea8,%eax
f0103ad1:	72 14                	jb     f0103ae7 <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103ad3:	83 ec 04             	sub    $0x4,%esp
f0103ad6:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0103adb:	6a 4f                	push   $0x4f
f0103add:	68 81 75 10 f0       	push   $0xf0107581
f0103ae2:	e8 59 c5 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103ae7:	83 ec 0c             	sub    $0xc,%esp
f0103aea:	a1 b0 8e 23 f0       	mov    0xf0238eb0,%eax
f0103aef:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103af2:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103af5:	50                   	push   %eax
f0103af6:	e8 7b dc ff ff       	call   f0101776 <page_decref>
f0103afb:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103afe:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103b02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b05:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103b0a:	0f 85 29 ff ff ff    	jne    f0103a39 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103b10:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b13:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b18:	77 15                	ja     f0103b2f <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b1a:	50                   	push   %eax
f0103b1b:	68 e4 67 10 f0       	push   $0xf01067e4
f0103b20:	68 d6 01 00 00       	push   $0x1d6
f0103b25:	68 09 7a 10 f0       	push   $0xf0107a09
f0103b2a:	e8 11 c5 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103b2f:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b36:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b3b:	c1 e8 0c             	shr    $0xc,%eax
f0103b3e:	3b 05 a8 8e 23 f0    	cmp    0xf0238ea8,%eax
f0103b44:	72 14                	jb     f0103b5a <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103b46:	83 ec 04             	sub    $0x4,%esp
f0103b49:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0103b4e:	6a 4f                	push   $0x4f
f0103b50:	68 81 75 10 f0       	push   $0xf0107581
f0103b55:	e8 e6 c4 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103b5a:	83 ec 0c             	sub    $0xc,%esp
f0103b5d:	8b 15 b0 8e 23 f0    	mov    0xf0238eb0,%edx
f0103b63:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103b66:	50                   	push   %eax
f0103b67:	e8 0a dc ff ff       	call   f0101776 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103b6c:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103b73:	a1 70 82 23 f0       	mov    0xf0238270,%eax
f0103b78:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103b7b:	89 3d 70 82 23 f0    	mov    %edi,0xf0238270
}
f0103b81:	83 c4 10             	add    $0x10,%esp
f0103b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b87:	5b                   	pop    %ebx
f0103b88:	5e                   	pop    %esi
f0103b89:	5f                   	pop    %edi
f0103b8a:	5d                   	pop    %ebp
f0103b8b:	c3                   	ret    

f0103b8c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103b8c:	55                   	push   %ebp
f0103b8d:	89 e5                	mov    %esp,%ebp
f0103b8f:	53                   	push   %ebx
f0103b90:	83 ec 04             	sub    $0x4,%esp
f0103b93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103b96:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103b9a:	75 19                	jne    f0103bb5 <env_destroy+0x29>
f0103b9c:	e8 c6 24 00 00       	call   f0106067 <cpunum>
f0103ba1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ba4:	3b 98 28 90 23 f0    	cmp    -0xfdc6fd8(%eax),%ebx
f0103baa:	74 09                	je     f0103bb5 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103bac:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103bb3:	eb 33                	jmp    f0103be8 <env_destroy+0x5c>
	}

	env_free(e);
f0103bb5:	83 ec 0c             	sub    $0xc,%esp
f0103bb8:	53                   	push   %ebx
f0103bb9:	e8 f3 fd ff ff       	call   f01039b1 <env_free>

	if (curenv == e) {
f0103bbe:	e8 a4 24 00 00       	call   f0106067 <cpunum>
f0103bc3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bc6:	83 c4 10             	add    $0x10,%esp
f0103bc9:	3b 98 28 90 23 f0    	cmp    -0xfdc6fd8(%eax),%ebx
f0103bcf:	75 17                	jne    f0103be8 <env_destroy+0x5c>
		curenv = NULL;
f0103bd1:	e8 91 24 00 00       	call   f0106067 <cpunum>
f0103bd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bd9:	c7 80 28 90 23 f0 00 	movl   $0x0,-0xfdc6fd8(%eax)
f0103be0:	00 00 00 
		sched_yield();
f0103be3:	e8 12 0c 00 00       	call   f01047fa <sched_yield>
	}
}
f0103be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103beb:	c9                   	leave  
f0103bec:	c3                   	ret    

f0103bed <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103bed:	55                   	push   %ebp
f0103bee:	89 e5                	mov    %esp,%ebp
f0103bf0:	53                   	push   %ebx
f0103bf1:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103bf4:	e8 6e 24 00 00       	call   f0106067 <cpunum>
f0103bf9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bfc:	8b 98 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%ebx
f0103c02:	e8 60 24 00 00       	call   f0106067 <cpunum>
f0103c07:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103c0a:	8b 65 08             	mov    0x8(%ebp),%esp
f0103c0d:	61                   	popa   
f0103c0e:	07                   	pop    %es
f0103c0f:	1f                   	pop    %ds
f0103c10:	83 c4 08             	add    $0x8,%esp
f0103c13:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103c14:	83 ec 04             	sub    $0x4,%esp
f0103c17:	68 4d 7a 10 f0       	push   $0xf0107a4d
f0103c1c:	68 0c 02 00 00       	push   $0x20c
f0103c21:	68 09 7a 10 f0       	push   $0xf0107a09
f0103c26:	e8 15 c4 ff ff       	call   f0100040 <_panic>

f0103c2b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c2b:	55                   	push   %ebp
f0103c2c:	89 e5                	mov    %esp,%ebp
f0103c2e:	53                   	push   %ebx
f0103c2f:	83 ec 04             	sub    $0x4,%esp
f0103c32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f0103c35:	e8 2d 24 00 00       	call   f0106067 <cpunum>
f0103c3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c3d:	39 98 28 90 23 f0    	cmp    %ebx,-0xfdc6fd8(%eax)
f0103c43:	0f 84 a4 00 00 00    	je     f0103ced <env_run+0xc2>
		if (curenv && curenv->env_status == ENV_RUNNING) {
f0103c49:	e8 19 24 00 00       	call   f0106067 <cpunum>
f0103c4e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c51:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f0103c58:	74 29                	je     f0103c83 <env_run+0x58>
f0103c5a:	e8 08 24 00 00       	call   f0106067 <cpunum>
f0103c5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c62:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103c68:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103c6c:	75 15                	jne    f0103c83 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103c6e:	e8 f4 23 00 00       	call   f0106067 <cpunum>
f0103c73:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c76:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103c7c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		curenv = e;
f0103c83:	e8 df 23 00 00       	call   f0106067 <cpunum>
f0103c88:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c8b:	89 98 28 90 23 f0    	mov    %ebx,-0xfdc6fd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0103c91:	e8 d1 23 00 00       	call   f0106067 <cpunum>
f0103c96:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c99:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103c9f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0103ca6:	e8 bc 23 00 00       	call   f0106067 <cpunum>
f0103cab:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cae:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103cb4:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0103cb8:	e8 aa 23 00 00       	call   f0106067 <cpunum>
f0103cbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cc0:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103cc6:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cc9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cce:	77 15                	ja     f0103ce5 <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cd0:	50                   	push   %eax
f0103cd1:	68 e4 67 10 f0       	push   $0xf01067e4
f0103cd6:	68 31 02 00 00       	push   $0x231
f0103cdb:	68 09 7a 10 f0       	push   $0xf0107a09
f0103ce0:	e8 5b c3 ff ff       	call   f0100040 <_panic>
f0103ce5:	05 00 00 00 10       	add    $0x10000000,%eax
f0103cea:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ced:	83 ec 0c             	sub    $0xc,%esp
f0103cf0:	68 a0 13 12 f0       	push   $0xf01213a0
f0103cf5:	e8 a6 26 00 00       	call   f01063a0 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103cfa:	f3 90                	pause  
	}

	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f0103cfc:	e8 66 23 00 00       	call   f0106067 <cpunum>
f0103d01:	83 c4 04             	add    $0x4,%esp
f0103d04:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d07:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0103d0d:	e8 db fe ff ff       	call   f0103bed <env_pop_tf>

f0103d12 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103d12:	55                   	push   %ebp
f0103d13:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d15:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d1a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d1d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103d1e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103d23:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d24:	0f b6 c0             	movzbl %al,%eax
}
f0103d27:	5d                   	pop    %ebp
f0103d28:	c3                   	ret    

f0103d29 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d29:	55                   	push   %ebp
f0103d2a:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d2c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d31:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d34:	ee                   	out    %al,(%dx)
f0103d35:	ba 71 00 00 00       	mov    $0x71,%edx
f0103d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d3d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103d3e:	5d                   	pop    %ebp
f0103d3f:	c3                   	ret    

f0103d40 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103d40:	55                   	push   %ebp
f0103d41:	89 e5                	mov    %esp,%ebp
f0103d43:	56                   	push   %esi
f0103d44:	53                   	push   %ebx
f0103d45:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103d48:	66 a3 88 13 12 f0    	mov    %ax,0xf0121388
	if (!didinit)
f0103d4e:	83 3d 74 82 23 f0 00 	cmpl   $0x0,0xf0238274
f0103d55:	74 5a                	je     f0103db1 <irq_setmask_8259A+0x71>
f0103d57:	89 c6                	mov    %eax,%esi
f0103d59:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d5e:	ee                   	out    %al,(%dx)
f0103d5f:	66 c1 e8 08          	shr    $0x8,%ax
f0103d63:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103d68:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103d69:	83 ec 0c             	sub    $0xc,%esp
f0103d6c:	68 59 7a 10 f0       	push   $0xf0107a59
f0103d71:	e8 1e 01 00 00       	call   f0103e94 <cprintf>
f0103d76:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103d79:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103d7e:	0f b7 f6             	movzwl %si,%esi
f0103d81:	f7 d6                	not    %esi
f0103d83:	0f a3 de             	bt     %ebx,%esi
f0103d86:	73 11                	jae    f0103d99 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103d88:	83 ec 08             	sub    $0x8,%esp
f0103d8b:	53                   	push   %ebx
f0103d8c:	68 47 7f 10 f0       	push   $0xf0107f47
f0103d91:	e8 fe 00 00 00       	call   f0103e94 <cprintf>
f0103d96:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103d99:	83 c3 01             	add    $0x1,%ebx
f0103d9c:	83 fb 10             	cmp    $0x10,%ebx
f0103d9f:	75 e2                	jne    f0103d83 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103da1:	83 ec 0c             	sub    $0xc,%esp
f0103da4:	68 36 6b 10 f0       	push   $0xf0106b36
f0103da9:	e8 e6 00 00 00       	call   f0103e94 <cprintf>
f0103dae:	83 c4 10             	add    $0x10,%esp
}
f0103db1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103db4:	5b                   	pop    %ebx
f0103db5:	5e                   	pop    %esi
f0103db6:	5d                   	pop    %ebp
f0103db7:	c3                   	ret    

f0103db8 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103db8:	c7 05 74 82 23 f0 01 	movl   $0x1,0xf0238274
f0103dbf:	00 00 00 
f0103dc2:	ba 21 00 00 00       	mov    $0x21,%edx
f0103dc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103dcc:	ee                   	out    %al,(%dx)
f0103dcd:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103dd2:	ee                   	out    %al,(%dx)
f0103dd3:	ba 20 00 00 00       	mov    $0x20,%edx
f0103dd8:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ddd:	ee                   	out    %al,(%dx)
f0103dde:	ba 21 00 00 00       	mov    $0x21,%edx
f0103de3:	b8 20 00 00 00       	mov    $0x20,%eax
f0103de8:	ee                   	out    %al,(%dx)
f0103de9:	b8 04 00 00 00       	mov    $0x4,%eax
f0103dee:	ee                   	out    %al,(%dx)
f0103def:	b8 03 00 00 00       	mov    $0x3,%eax
f0103df4:	ee                   	out    %al,(%dx)
f0103df5:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103dfa:	b8 11 00 00 00       	mov    $0x11,%eax
f0103dff:	ee                   	out    %al,(%dx)
f0103e00:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103e05:	b8 28 00 00 00       	mov    $0x28,%eax
f0103e0a:	ee                   	out    %al,(%dx)
f0103e0b:	b8 02 00 00 00       	mov    $0x2,%eax
f0103e10:	ee                   	out    %al,(%dx)
f0103e11:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e16:	ee                   	out    %al,(%dx)
f0103e17:	ba 20 00 00 00       	mov    $0x20,%edx
f0103e1c:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e21:	ee                   	out    %al,(%dx)
f0103e22:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e27:	ee                   	out    %al,(%dx)
f0103e28:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103e2d:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e32:	ee                   	out    %al,(%dx)
f0103e33:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e38:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103e39:	0f b7 05 88 13 12 f0 	movzwl 0xf0121388,%eax
f0103e40:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103e44:	74 13                	je     f0103e59 <pic_init+0xa1>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103e46:	55                   	push   %ebp
f0103e47:	89 e5                	mov    %esp,%ebp
f0103e49:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103e4c:	0f b7 c0             	movzwl %ax,%eax
f0103e4f:	50                   	push   %eax
f0103e50:	e8 eb fe ff ff       	call   f0103d40 <irq_setmask_8259A>
f0103e55:	83 c4 10             	add    $0x10,%esp
}
f0103e58:	c9                   	leave  
f0103e59:	f3 c3                	repz ret 

f0103e5b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103e5b:	55                   	push   %ebp
f0103e5c:	89 e5                	mov    %esp,%ebp
f0103e5e:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103e61:	ff 75 08             	pushl  0x8(%ebp)
f0103e64:	e8 74 ca ff ff       	call   f01008dd <cputchar>
	*cnt++;
}
f0103e69:	83 c4 10             	add    $0x10,%esp
f0103e6c:	c9                   	leave  
f0103e6d:	c3                   	ret    

f0103e6e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e6e:	55                   	push   %ebp
f0103e6f:	89 e5                	mov    %esp,%ebp
f0103e71:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103e74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103e7b:	ff 75 0c             	pushl  0xc(%ebp)
f0103e7e:	ff 75 08             	pushl  0x8(%ebp)
f0103e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e84:	50                   	push   %eax
f0103e85:	68 5b 3e 10 f0       	push   $0xf0103e5b
f0103e8a:	e8 4f 13 00 00       	call   f01051de <vprintfmt>
	return cnt;
}
f0103e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e92:	c9                   	leave  
f0103e93:	c3                   	ret    

f0103e94 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103e94:	55                   	push   %ebp
f0103e95:	89 e5                	mov    %esp,%ebp
f0103e97:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103e9a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103e9d:	50                   	push   %eax
f0103e9e:	ff 75 08             	pushl  0x8(%ebp)
f0103ea1:	e8 c8 ff ff ff       	call   f0103e6e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ea6:	c9                   	leave  
f0103ea7:	c3                   	ret    

f0103ea8 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ea8:	55                   	push   %ebp
f0103ea9:	89 e5                	mov    %esp,%ebp
f0103eab:	57                   	push   %edi
f0103eac:	56                   	push   %esi
f0103ead:	53                   	push   %ebx
f0103eae:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int i = thiscpu->cpu_id;
f0103eb1:	e8 b1 21 00 00       	call   f0106067 <cpunum>
f0103eb6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eb9:	0f b6 b0 20 90 23 f0 	movzbl -0xfdc6fe0(%eax),%esi
f0103ec0:	89 f0                	mov    %esi,%eax
f0103ec2:	0f b6 d8             	movzbl %al,%ebx

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103ec5:	e8 9d 21 00 00       	call   f0106067 <cpunum>
f0103eca:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ecd:	89 d9                	mov    %ebx,%ecx
f0103ecf:	c1 e1 10             	shl    $0x10,%ecx
f0103ed2:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0103ed7:	29 ca                	sub    %ecx,%edx
f0103ed9:	89 90 30 90 23 f0    	mov    %edx,-0xfdc6fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103edf:	e8 83 21 00 00       	call   f0106067 <cpunum>
f0103ee4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ee7:	66 c7 80 34 90 23 f0 	movw   $0x10,-0xfdc6fcc(%eax)
f0103eee:	10 00 

	extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
f0103ef0:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ef5:	b8 08 00 00 00       	mov    $0x8,%eax
f0103efa:	b9 74 01 00 00       	mov    $0x174,%ecx
f0103eff:	0f 30                	wrmsr  
  wrmsr(0x175, thiscpu->cpu_ts.ts_esp0, 0);
f0103f01:	e8 61 21 00 00       	call   f0106067 <cpunum>
f0103f06:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f09:	8b 80 30 90 23 f0    	mov    -0xfdc6fd0(%eax),%eax
f0103f0f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f14:	b9 75 01 00 00       	mov    $0x175,%ecx
f0103f19:	0f 30                	wrmsr  
  wrmsr(0x176, sysenter_handler, 0);
f0103f1b:	b8 ac 47 10 f0       	mov    $0xf01047ac,%eax
f0103f20:	b9 76 01 00 00       	mov    $0x176,%ecx
f0103f25:	0f 30                	wrmsr  

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)(&thiscpu->cpu_ts),
f0103f27:	83 c3 05             	add    $0x5,%ebx
f0103f2a:	e8 38 21 00 00       	call   f0106067 <cpunum>
f0103f2f:	89 c7                	mov    %eax,%edi
f0103f31:	e8 31 21 00 00       	call   f0106067 <cpunum>
f0103f36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f39:	e8 29 21 00 00       	call   f0106067 <cpunum>
f0103f3e:	66 c7 04 dd 20 13 12 	movw   $0x68,-0xfedece0(,%ebx,8)
f0103f45:	f0 68 00 
f0103f48:	6b ff 74             	imul   $0x74,%edi,%edi
f0103f4b:	81 c7 2c 90 23 f0    	add    $0xf023902c,%edi
f0103f51:	66 89 3c dd 22 13 12 	mov    %di,-0xfedecde(,%ebx,8)
f0103f58:	f0 
f0103f59:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103f5d:	81 c2 2c 90 23 f0    	add    $0xf023902c,%edx
f0103f63:	c1 ea 10             	shr    $0x10,%edx
f0103f66:	88 14 dd 24 13 12 f0 	mov    %dl,-0xfedecdc(,%ebx,8)
f0103f6d:	c6 04 dd 26 13 12 f0 	movb   $0x40,-0xfedecda(,%ebx,8)
f0103f74:	40 
f0103f75:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f78:	05 2c 90 23 f0       	add    $0xf023902c,%eax
f0103f7d:	c1 e8 18             	shr    $0x18,%eax
f0103f80:	88 04 dd 27 13 12 f0 	mov    %al,-0xfedecd9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103f87:	c6 04 dd 25 13 12 f0 	movb   $0x89,-0xfedecdb(,%ebx,8)
f0103f8e:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103f8f:	89 f0                	mov    %esi,%eax
f0103f91:	0f b6 f0             	movzbl %al,%esi
f0103f94:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f0103f9b:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103f9e:	b8 8c 13 12 f0       	mov    $0xf012138c,%eax
f0103fa3:	0f 01 18             	lidtl  (%eax)

	ltr(GD_TSS0+(i << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f0103fa6:	83 c4 1c             	add    $0x1c,%esp
f0103fa9:	5b                   	pop    %ebx
f0103faa:	5e                   	pop    %esi
f0103fab:	5f                   	pop    %edi
f0103fac:	5d                   	pop    %ebp
f0103fad:	c3                   	ret    

f0103fae <trap_init>:
}


void
trap_init(void)
{
f0103fae:	55                   	push   %ebp
f0103faf:	89 e5                	mov    %esp,%ebp
f0103fb1:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 1, GD_KT, _divide_error, 0);
f0103fb4:	b8 42 47 10 f0       	mov    $0xf0104742,%eax
f0103fb9:	66 a3 80 82 23 f0    	mov    %ax,0xf0238280
f0103fbf:	66 c7 05 82 82 23 f0 	movw   $0x8,0xf0238282
f0103fc6:	08 00 
f0103fc8:	c6 05 84 82 23 f0 00 	movb   $0x0,0xf0238284
f0103fcf:	c6 05 85 82 23 f0 8f 	movb   $0x8f,0xf0238285
f0103fd6:	c1 e8 10             	shr    $0x10,%eax
f0103fd9:	66 a3 86 82 23 f0    	mov    %ax,0xf0238286
	SETGATE(idt[T_DEBUG], 1, GD_KT, _debug, 0);
f0103fdf:	b8 4c 47 10 f0       	mov    $0xf010474c,%eax
f0103fe4:	66 a3 88 82 23 f0    	mov    %ax,0xf0238288
f0103fea:	66 c7 05 8a 82 23 f0 	movw   $0x8,0xf023828a
f0103ff1:	08 00 
f0103ff3:	c6 05 8c 82 23 f0 00 	movb   $0x0,0xf023828c
f0103ffa:	c6 05 8d 82 23 f0 8f 	movb   $0x8f,0xf023828d
f0104001:	c1 e8 10             	shr    $0x10,%eax
f0104004:	66 a3 8e 82 23 f0    	mov    %ax,0xf023828e
	SETGATE(idt[T_NMI], 1, GD_KT, _non_maskable_interrupt, 0);
f010400a:	b8 56 47 10 f0       	mov    $0xf0104756,%eax
f010400f:	66 a3 90 82 23 f0    	mov    %ax,0xf0238290
f0104015:	66 c7 05 92 82 23 f0 	movw   $0x8,0xf0238292
f010401c:	08 00 
f010401e:	c6 05 94 82 23 f0 00 	movb   $0x0,0xf0238294
f0104025:	c6 05 95 82 23 f0 8f 	movb   $0x8f,0xf0238295
f010402c:	c1 e8 10             	shr    $0x10,%eax
f010402f:	66 a3 96 82 23 f0    	mov    %ax,0xf0238296
	SETGATE(idt[T_BRKPT], 1, GD_KT, _breakpoint, 3);
f0104035:	b8 60 47 10 f0       	mov    $0xf0104760,%eax
f010403a:	66 a3 98 82 23 f0    	mov    %ax,0xf0238298
f0104040:	66 c7 05 9a 82 23 f0 	movw   $0x8,0xf023829a
f0104047:	08 00 
f0104049:	c6 05 9c 82 23 f0 00 	movb   $0x0,0xf023829c
f0104050:	c6 05 9d 82 23 f0 ef 	movb   $0xef,0xf023829d
f0104057:	c1 e8 10             	shr    $0x10,%eax
f010405a:	66 a3 9e 82 23 f0    	mov    %ax,0xf023829e
	SETGATE(idt[T_OFLOW], 1, GD_KT, _overflow, 0);
f0104060:	b8 66 47 10 f0       	mov    $0xf0104766,%eax
f0104065:	66 a3 a0 82 23 f0    	mov    %ax,0xf02382a0
f010406b:	66 c7 05 a2 82 23 f0 	movw   $0x8,0xf02382a2
f0104072:	08 00 
f0104074:	c6 05 a4 82 23 f0 00 	movb   $0x0,0xf02382a4
f010407b:	c6 05 a5 82 23 f0 8f 	movb   $0x8f,0xf02382a5
f0104082:	c1 e8 10             	shr    $0x10,%eax
f0104085:	66 a3 a6 82 23 f0    	mov    %ax,0xf02382a6
	SETGATE(idt[T_BOUND], 1, GD_KT, _bound_range_exceeded, 0);
f010408b:	b8 6c 47 10 f0       	mov    $0xf010476c,%eax
f0104090:	66 a3 a8 82 23 f0    	mov    %ax,0xf02382a8
f0104096:	66 c7 05 aa 82 23 f0 	movw   $0x8,0xf02382aa
f010409d:	08 00 
f010409f:	c6 05 ac 82 23 f0 00 	movb   $0x0,0xf02382ac
f01040a6:	c6 05 ad 82 23 f0 8f 	movb   $0x8f,0xf02382ad
f01040ad:	c1 e8 10             	shr    $0x10,%eax
f01040b0:	66 a3 ae 82 23 f0    	mov    %ax,0xf02382ae
	SETGATE(idt[T_ILLOP], 1, GD_KT, _invalid_opcode, 0);
f01040b6:	b8 72 47 10 f0       	mov    $0xf0104772,%eax
f01040bb:	66 a3 b0 82 23 f0    	mov    %ax,0xf02382b0
f01040c1:	66 c7 05 b2 82 23 f0 	movw   $0x8,0xf02382b2
f01040c8:	08 00 
f01040ca:	c6 05 b4 82 23 f0 00 	movb   $0x0,0xf02382b4
f01040d1:	c6 05 b5 82 23 f0 8f 	movb   $0x8f,0xf02382b5
f01040d8:	c1 e8 10             	shr    $0x10,%eax
f01040db:	66 a3 b6 82 23 f0    	mov    %ax,0xf02382b6
	SETGATE(idt[T_DEVICE], 1, GD_KT, _device_not_available, 0);
f01040e1:	b8 78 47 10 f0       	mov    $0xf0104778,%eax
f01040e6:	66 a3 b8 82 23 f0    	mov    %ax,0xf02382b8
f01040ec:	66 c7 05 ba 82 23 f0 	movw   $0x8,0xf02382ba
f01040f3:	08 00 
f01040f5:	c6 05 bc 82 23 f0 00 	movb   $0x0,0xf02382bc
f01040fc:	c6 05 bd 82 23 f0 8f 	movb   $0x8f,0xf02382bd
f0104103:	c1 e8 10             	shr    $0x10,%eax
f0104106:	66 a3 be 82 23 f0    	mov    %ax,0xf02382be
	SETGATE(idt[T_DBLFLT], 1, GD_KT, _double_fault, 0);
f010410c:	b8 7e 47 10 f0       	mov    $0xf010477e,%eax
f0104111:	66 a3 c0 82 23 f0    	mov    %ax,0xf02382c0
f0104117:	66 c7 05 c2 82 23 f0 	movw   $0x8,0xf02382c2
f010411e:	08 00 
f0104120:	c6 05 c4 82 23 f0 00 	movb   $0x0,0xf02382c4
f0104127:	c6 05 c5 82 23 f0 8f 	movb   $0x8f,0xf02382c5
f010412e:	c1 e8 10             	shr    $0x10,%eax
f0104131:	66 a3 c6 82 23 f0    	mov    %ax,0xf02382c6

	SETGATE(idt[T_TSS], 1, GD_KT, _invalid_tss, 0);
f0104137:	b8 82 47 10 f0       	mov    $0xf0104782,%eax
f010413c:	66 a3 d0 82 23 f0    	mov    %ax,0xf02382d0
f0104142:	66 c7 05 d2 82 23 f0 	movw   $0x8,0xf02382d2
f0104149:	08 00 
f010414b:	c6 05 d4 82 23 f0 00 	movb   $0x0,0xf02382d4
f0104152:	c6 05 d5 82 23 f0 8f 	movb   $0x8f,0xf02382d5
f0104159:	c1 e8 10             	shr    $0x10,%eax
f010415c:	66 a3 d6 82 23 f0    	mov    %ax,0xf02382d6
	SETGATE(idt[T_SEGNP], 1, GD_KT, _segment_not_present, 0);
f0104162:	b8 86 47 10 f0       	mov    $0xf0104786,%eax
f0104167:	66 a3 d8 82 23 f0    	mov    %ax,0xf02382d8
f010416d:	66 c7 05 da 82 23 f0 	movw   $0x8,0xf02382da
f0104174:	08 00 
f0104176:	c6 05 dc 82 23 f0 00 	movb   $0x0,0xf02382dc
f010417d:	c6 05 dd 82 23 f0 8f 	movb   $0x8f,0xf02382dd
f0104184:	c1 e8 10             	shr    $0x10,%eax
f0104187:	66 a3 de 82 23 f0    	mov    %ax,0xf02382de
	SETGATE(idt[T_STACK], 1, GD_KT, _stack_fault, 0);
f010418d:	b8 8a 47 10 f0       	mov    $0xf010478a,%eax
f0104192:	66 a3 e0 82 23 f0    	mov    %ax,0xf02382e0
f0104198:	66 c7 05 e2 82 23 f0 	movw   $0x8,0xf02382e2
f010419f:	08 00 
f01041a1:	c6 05 e4 82 23 f0 00 	movb   $0x0,0xf02382e4
f01041a8:	c6 05 e5 82 23 f0 8f 	movb   $0x8f,0xf02382e5
f01041af:	c1 e8 10             	shr    $0x10,%eax
f01041b2:	66 a3 e6 82 23 f0    	mov    %ax,0xf02382e6
	SETGATE(idt[T_GPFLT], 1, GD_KT, _general_protection, 0);
f01041b8:	b8 8e 47 10 f0       	mov    $0xf010478e,%eax
f01041bd:	66 a3 e8 82 23 f0    	mov    %ax,0xf02382e8
f01041c3:	66 c7 05 ea 82 23 f0 	movw   $0x8,0xf02382ea
f01041ca:	08 00 
f01041cc:	c6 05 ec 82 23 f0 00 	movb   $0x0,0xf02382ec
f01041d3:	c6 05 ed 82 23 f0 8f 	movb   $0x8f,0xf02382ed
f01041da:	c1 e8 10             	shr    $0x10,%eax
f01041dd:	66 a3 ee 82 23 f0    	mov    %ax,0xf02382ee
	SETGATE(idt[T_PGFLT], 1, GD_KT, _page_fault, 0);
f01041e3:	b8 92 47 10 f0       	mov    $0xf0104792,%eax
f01041e8:	66 a3 f0 82 23 f0    	mov    %ax,0xf02382f0
f01041ee:	66 c7 05 f2 82 23 f0 	movw   $0x8,0xf02382f2
f01041f5:	08 00 
f01041f7:	c6 05 f4 82 23 f0 00 	movb   $0x0,0xf02382f4
f01041fe:	c6 05 f5 82 23 f0 8f 	movb   $0x8f,0xf02382f5
f0104205:	c1 e8 10             	shr    $0x10,%eax
f0104208:	66 a3 f6 82 23 f0    	mov    %ax,0xf02382f6

	SETGATE(idt[T_FPERR], 1, GD_KT, _x87_fpu_error, 0);
f010420e:	b8 96 47 10 f0       	mov    $0xf0104796,%eax
f0104213:	66 a3 00 83 23 f0    	mov    %ax,0xf0238300
f0104219:	66 c7 05 02 83 23 f0 	movw   $0x8,0xf0238302
f0104220:	08 00 
f0104222:	c6 05 04 83 23 f0 00 	movb   $0x0,0xf0238304
f0104229:	c6 05 05 83 23 f0 8f 	movb   $0x8f,0xf0238305
f0104230:	c1 e8 10             	shr    $0x10,%eax
f0104233:	66 a3 06 83 23 f0    	mov    %ax,0xf0238306
	SETGATE(idt[T_ALIGN], 1, GD_KT, _alignment_check, 0);
f0104239:	b8 9c 47 10 f0       	mov    $0xf010479c,%eax
f010423e:	66 a3 08 83 23 f0    	mov    %ax,0xf0238308
f0104244:	66 c7 05 0a 83 23 f0 	movw   $0x8,0xf023830a
f010424b:	08 00 
f010424d:	c6 05 0c 83 23 f0 00 	movb   $0x0,0xf023830c
f0104254:	c6 05 0d 83 23 f0 8f 	movb   $0x8f,0xf023830d
f010425b:	c1 e8 10             	shr    $0x10,%eax
f010425e:	66 a3 0e 83 23 f0    	mov    %ax,0xf023830e
	SETGATE(idt[T_MCHK], 1, GD_KT, _machine_check, 0);
f0104264:	b8 a0 47 10 f0       	mov    $0xf01047a0,%eax
f0104269:	66 a3 10 83 23 f0    	mov    %ax,0xf0238310
f010426f:	66 c7 05 12 83 23 f0 	movw   $0x8,0xf0238312
f0104276:	08 00 
f0104278:	c6 05 14 83 23 f0 00 	movb   $0x0,0xf0238314
f010427f:	c6 05 15 83 23 f0 8f 	movb   $0x8f,0xf0238315
f0104286:	c1 e8 10             	shr    $0x10,%eax
f0104289:	66 a3 16 83 23 f0    	mov    %ax,0xf0238316
	SETGATE(idt[T_SIMDERR], 1, GD_KT, _simd_fp_exception, 0);
f010428f:	b8 a6 47 10 f0       	mov    $0xf01047a6,%eax
f0104294:	66 a3 18 83 23 f0    	mov    %ax,0xf0238318
f010429a:	66 c7 05 1a 83 23 f0 	movw   $0x8,0xf023831a
f01042a1:	08 00 
f01042a3:	c6 05 1c 83 23 f0 00 	movb   $0x0,0xf023831c
f01042aa:	c6 05 1d 83 23 f0 8f 	movb   $0x8f,0xf023831d
f01042b1:	c1 e8 10             	shr    $0x10,%eax
f01042b4:	66 a3 1e 83 23 f0    	mov    %ax,0xf023831e

	extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
f01042ba:	ba 00 00 00 00       	mov    $0x0,%edx
f01042bf:	b8 08 00 00 00       	mov    $0x8,%eax
f01042c4:	b9 74 01 00 00       	mov    $0x174,%ecx
f01042c9:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP, 0);
f01042cb:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f01042d0:	b9 75 01 00 00       	mov    $0x175,%ecx
f01042d5:	0f 30                	wrmsr  
	wrmsr(0x176, sysenter_handler, 0);
f01042d7:	b8 ac 47 10 f0       	mov    $0xf01047ac,%eax
f01042dc:	b9 76 01 00 00       	mov    $0x176,%ecx
f01042e1:	0f 30                	wrmsr  

	// Per-CPU setup
	trap_init_percpu();
f01042e3:	e8 c0 fb ff ff       	call   f0103ea8 <trap_init_percpu>
}
f01042e8:	c9                   	leave  
f01042e9:	c3                   	ret    

f01042ea <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01042ea:	55                   	push   %ebp
f01042eb:	89 e5                	mov    %esp,%ebp
f01042ed:	53                   	push   %ebx
f01042ee:	83 ec 0c             	sub    $0xc,%esp
f01042f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01042f4:	ff 33                	pushl  (%ebx)
f01042f6:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01042fb:	e8 94 fb ff ff       	call   f0103e94 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104300:	83 c4 08             	add    $0x8,%esp
f0104303:	ff 73 04             	pushl  0x4(%ebx)
f0104306:	68 7c 7a 10 f0       	push   $0xf0107a7c
f010430b:	e8 84 fb ff ff       	call   f0103e94 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104310:	83 c4 08             	add    $0x8,%esp
f0104313:	ff 73 08             	pushl  0x8(%ebx)
f0104316:	68 8b 7a 10 f0       	push   $0xf0107a8b
f010431b:	e8 74 fb ff ff       	call   f0103e94 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104320:	83 c4 08             	add    $0x8,%esp
f0104323:	ff 73 0c             	pushl  0xc(%ebx)
f0104326:	68 9a 7a 10 f0       	push   $0xf0107a9a
f010432b:	e8 64 fb ff ff       	call   f0103e94 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104330:	83 c4 08             	add    $0x8,%esp
f0104333:	ff 73 10             	pushl  0x10(%ebx)
f0104336:	68 a9 7a 10 f0       	push   $0xf0107aa9
f010433b:	e8 54 fb ff ff       	call   f0103e94 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104340:	83 c4 08             	add    $0x8,%esp
f0104343:	ff 73 14             	pushl  0x14(%ebx)
f0104346:	68 b8 7a 10 f0       	push   $0xf0107ab8
f010434b:	e8 44 fb ff ff       	call   f0103e94 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104350:	83 c4 08             	add    $0x8,%esp
f0104353:	ff 73 18             	pushl  0x18(%ebx)
f0104356:	68 c7 7a 10 f0       	push   $0xf0107ac7
f010435b:	e8 34 fb ff ff       	call   f0103e94 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104360:	83 c4 08             	add    $0x8,%esp
f0104363:	ff 73 1c             	pushl  0x1c(%ebx)
f0104366:	68 d6 7a 10 f0       	push   $0xf0107ad6
f010436b:	e8 24 fb ff ff       	call   f0103e94 <cprintf>
}
f0104370:	83 c4 10             	add    $0x10,%esp
f0104373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104376:	c9                   	leave  
f0104377:	c3                   	ret    

f0104378 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104378:	55                   	push   %ebp
f0104379:	89 e5                	mov    %esp,%ebp
f010437b:	56                   	push   %esi
f010437c:	53                   	push   %ebx
f010437d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104380:	e8 e2 1c 00 00       	call   f0106067 <cpunum>
f0104385:	83 ec 04             	sub    $0x4,%esp
f0104388:	50                   	push   %eax
f0104389:	53                   	push   %ebx
f010438a:	68 3a 7b 10 f0       	push   $0xf0107b3a
f010438f:	e8 00 fb ff ff       	call   f0103e94 <cprintf>
	print_regs(&tf->tf_regs);
f0104394:	89 1c 24             	mov    %ebx,(%esp)
f0104397:	e8 4e ff ff ff       	call   f01042ea <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010439c:	83 c4 08             	add    $0x8,%esp
f010439f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01043a3:	50                   	push   %eax
f01043a4:	68 58 7b 10 f0       	push   $0xf0107b58
f01043a9:	e8 e6 fa ff ff       	call   f0103e94 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01043ae:	83 c4 08             	add    $0x8,%esp
f01043b1:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01043b5:	50                   	push   %eax
f01043b6:	68 6b 7b 10 f0       	push   $0xf0107b6b
f01043bb:	e8 d4 fa ff ff       	call   f0103e94 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01043c0:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01043c3:	83 c4 10             	add    $0x10,%esp
f01043c6:	83 f8 13             	cmp    $0x13,%eax
f01043c9:	77 09                	ja     f01043d4 <print_trapframe+0x5c>
		return excnames[trapno];
f01043cb:	8b 14 85 00 7e 10 f0 	mov    -0xfef8200(,%eax,4),%edx
f01043d2:	eb 1f                	jmp    f01043f3 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01043d4:	83 f8 30             	cmp    $0x30,%eax
f01043d7:	74 15                	je     f01043ee <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01043d9:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01043dc:	83 fa 10             	cmp    $0x10,%edx
f01043df:	b9 04 7b 10 f0       	mov    $0xf0107b04,%ecx
f01043e4:	ba f1 7a 10 f0       	mov    $0xf0107af1,%edx
f01043e9:	0f 43 d1             	cmovae %ecx,%edx
f01043ec:	eb 05                	jmp    f01043f3 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01043ee:	ba e5 7a 10 f0       	mov    $0xf0107ae5,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01043f3:	83 ec 04             	sub    $0x4,%esp
f01043f6:	52                   	push   %edx
f01043f7:	50                   	push   %eax
f01043f8:	68 7e 7b 10 f0       	push   $0xf0107b7e
f01043fd:	e8 92 fa ff ff       	call   f0103e94 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104402:	83 c4 10             	add    $0x10,%esp
f0104405:	3b 1d 80 8a 23 f0    	cmp    0xf0238a80,%ebx
f010440b:	75 1a                	jne    f0104427 <print_trapframe+0xaf>
f010440d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104411:	75 14                	jne    f0104427 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104413:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104416:	83 ec 08             	sub    $0x8,%esp
f0104419:	50                   	push   %eax
f010441a:	68 90 7b 10 f0       	push   $0xf0107b90
f010441f:	e8 70 fa ff ff       	call   f0103e94 <cprintf>
f0104424:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104427:	83 ec 08             	sub    $0x8,%esp
f010442a:	ff 73 2c             	pushl  0x2c(%ebx)
f010442d:	68 9f 7b 10 f0       	push   $0xf0107b9f
f0104432:	e8 5d fa ff ff       	call   f0103e94 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104437:	83 c4 10             	add    $0x10,%esp
f010443a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010443e:	75 49                	jne    f0104489 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104440:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104443:	89 c2                	mov    %eax,%edx
f0104445:	83 e2 01             	and    $0x1,%edx
f0104448:	ba 1e 7b 10 f0       	mov    $0xf0107b1e,%edx
f010444d:	b9 13 7b 10 f0       	mov    $0xf0107b13,%ecx
f0104452:	0f 44 ca             	cmove  %edx,%ecx
f0104455:	89 c2                	mov    %eax,%edx
f0104457:	83 e2 02             	and    $0x2,%edx
f010445a:	ba 30 7b 10 f0       	mov    $0xf0107b30,%edx
f010445f:	be 2a 7b 10 f0       	mov    $0xf0107b2a,%esi
f0104464:	0f 45 d6             	cmovne %esi,%edx
f0104467:	83 e0 04             	and    $0x4,%eax
f010446a:	be 83 7c 10 f0       	mov    $0xf0107c83,%esi
f010446f:	b8 35 7b 10 f0       	mov    $0xf0107b35,%eax
f0104474:	0f 44 c6             	cmove  %esi,%eax
f0104477:	51                   	push   %ecx
f0104478:	52                   	push   %edx
f0104479:	50                   	push   %eax
f010447a:	68 ad 7b 10 f0       	push   $0xf0107bad
f010447f:	e8 10 fa ff ff       	call   f0103e94 <cprintf>
f0104484:	83 c4 10             	add    $0x10,%esp
f0104487:	eb 10                	jmp    f0104499 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104489:	83 ec 0c             	sub    $0xc,%esp
f010448c:	68 36 6b 10 f0       	push   $0xf0106b36
f0104491:	e8 fe f9 ff ff       	call   f0103e94 <cprintf>
f0104496:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104499:	83 ec 08             	sub    $0x8,%esp
f010449c:	ff 73 30             	pushl  0x30(%ebx)
f010449f:	68 bc 7b 10 f0       	push   $0xf0107bbc
f01044a4:	e8 eb f9 ff ff       	call   f0103e94 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01044a9:	83 c4 08             	add    $0x8,%esp
f01044ac:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01044b0:	50                   	push   %eax
f01044b1:	68 cb 7b 10 f0       	push   $0xf0107bcb
f01044b6:	e8 d9 f9 ff ff       	call   f0103e94 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01044bb:	83 c4 08             	add    $0x8,%esp
f01044be:	ff 73 38             	pushl  0x38(%ebx)
f01044c1:	68 de 7b 10 f0       	push   $0xf0107bde
f01044c6:	e8 c9 f9 ff ff       	call   f0103e94 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01044cb:	83 c4 10             	add    $0x10,%esp
f01044ce:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01044d2:	74 25                	je     f01044f9 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01044d4:	83 ec 08             	sub    $0x8,%esp
f01044d7:	ff 73 3c             	pushl  0x3c(%ebx)
f01044da:	68 ed 7b 10 f0       	push   $0xf0107bed
f01044df:	e8 b0 f9 ff ff       	call   f0103e94 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01044e4:	83 c4 08             	add    $0x8,%esp
f01044e7:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01044eb:	50                   	push   %eax
f01044ec:	68 fc 7b 10 f0       	push   $0xf0107bfc
f01044f1:	e8 9e f9 ff ff       	call   f0103e94 <cprintf>
f01044f6:	83 c4 10             	add    $0x10,%esp
	}
}
f01044f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01044fc:	5b                   	pop    %ebx
f01044fd:	5e                   	pop    %esi
f01044fe:	5d                   	pop    %ebp
f01044ff:	c3                   	ret    

f0104500 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104500:	55                   	push   %ebp
f0104501:	89 e5                	mov    %esp,%ebp
f0104503:	57                   	push   %edi
f0104504:	56                   	push   %esi
f0104505:	53                   	push   %ebx
f0104506:	83 ec 0c             	sub    $0xc,%esp
f0104509:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010450c:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (!(tf->tf_cs & 0x03)) {
f010450f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104513:	75 17                	jne    f010452c <page_fault_handler+0x2c>
		panic("Kernek mode page fault.\n");
f0104515:	83 ec 04             	sub    $0x4,%esp
f0104518:	68 0f 7c 10 f0       	push   $0xf0107c0f
f010451d:	68 4d 01 00 00       	push   $0x14d
f0104522:	68 28 7c 10 f0       	push   $0xf0107c28
f0104527:	e8 14 bb ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010452c:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010452f:	e8 33 1b 00 00       	call   f0106067 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104534:	57                   	push   %edi
f0104535:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104536:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104539:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010453f:	ff 70 48             	pushl  0x48(%eax)
f0104542:	68 d0 7d 10 f0       	push   $0xf0107dd0
f0104547:	e8 48 f9 ff ff       	call   f0103e94 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010454c:	89 1c 24             	mov    %ebx,(%esp)
f010454f:	e8 24 fe ff ff       	call   f0104378 <print_trapframe>
	env_destroy(curenv);
f0104554:	e8 0e 1b 00 00       	call   f0106067 <cpunum>
f0104559:	83 c4 04             	add    $0x4,%esp
f010455c:	6b c0 74             	imul   $0x74,%eax,%eax
f010455f:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104565:	e8 22 f6 ff ff       	call   f0103b8c <env_destroy>
}
f010456a:	83 c4 10             	add    $0x10,%esp
f010456d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104570:	5b                   	pop    %ebx
f0104571:	5e                   	pop    %esi
f0104572:	5f                   	pop    %edi
f0104573:	5d                   	pop    %ebp
f0104574:	c3                   	ret    

f0104575 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104575:	55                   	push   %ebp
f0104576:	89 e5                	mov    %esp,%ebp
f0104578:	57                   	push   %edi
f0104579:	56                   	push   %esi
f010457a:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010457d:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010457e:	83 3d a0 8e 23 f0 00 	cmpl   $0x0,0xf0238ea0
f0104585:	74 01                	je     f0104588 <trap+0x13>
		asm volatile("hlt");
f0104587:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104588:	9c                   	pushf  
f0104589:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010458a:	f6 c4 02             	test   $0x2,%ah
f010458d:	74 19                	je     f01045a8 <trap+0x33>
f010458f:	68 34 7c 10 f0       	push   $0xf0107c34
f0104594:	68 9b 75 10 f0       	push   $0xf010759b
f0104599:	68 17 01 00 00       	push   $0x117
f010459e:	68 28 7c 10 f0       	push   $0xf0107c28
f01045a3:	e8 98 ba ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01045a8:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01045ac:	83 e0 03             	and    $0x3,%eax
f01045af:	66 83 f8 03          	cmp    $0x3,%ax
f01045b3:	0f 85 a0 00 00 00    	jne    f0104659 <trap+0xe4>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01045b9:	83 ec 0c             	sub    $0xc,%esp
f01045bc:	68 a0 13 12 f0       	push   $0xf01213a0
f01045c1:	e8 0f 1d 00 00       	call   f01062d5 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f01045c6:	e8 9c 1a 00 00       	call   f0106067 <cpunum>
f01045cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ce:	83 c4 10             	add    $0x10,%esp
f01045d1:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f01045d8:	75 19                	jne    f01045f3 <trap+0x7e>
f01045da:	68 4d 7c 10 f0       	push   $0xf0107c4d
f01045df:	68 9b 75 10 f0       	push   $0xf010759b
f01045e4:	68 1f 01 00 00       	push   $0x11f
f01045e9:	68 28 7c 10 f0       	push   $0xf0107c28
f01045ee:	e8 4d ba ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01045f3:	e8 6f 1a 00 00       	call   f0106067 <cpunum>
f01045f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01045fb:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104601:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104605:	75 2d                	jne    f0104634 <trap+0xbf>
			env_free(curenv);
f0104607:	e8 5b 1a 00 00       	call   f0106067 <cpunum>
f010460c:	83 ec 0c             	sub    $0xc,%esp
f010460f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104612:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104618:	e8 94 f3 ff ff       	call   f01039b1 <env_free>
			curenv = NULL;
f010461d:	e8 45 1a 00 00       	call   f0106067 <cpunum>
f0104622:	6b c0 74             	imul   $0x74,%eax,%eax
f0104625:	c7 80 28 90 23 f0 00 	movl   $0x0,-0xfdc6fd8(%eax)
f010462c:	00 00 00 
			sched_yield();
f010462f:	e8 c6 01 00 00       	call   f01047fa <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104634:	e8 2e 1a 00 00       	call   f0106067 <cpunum>
f0104639:	6b c0 74             	imul   $0x74,%eax,%eax
f010463c:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104642:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104647:	89 c7                	mov    %eax,%edi
f0104649:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010464b:	e8 17 1a 00 00       	call   f0106067 <cpunum>
f0104650:	6b c0 74             	imul   $0x74,%eax,%eax
f0104653:	8b b0 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104659:	89 35 80 8a 23 f0    	mov    %esi,0xf0238a80
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
f010465f:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104663:	75 0c                	jne    f0104671 <trap+0xfc>
		page_fault_handler(tf);
f0104665:	83 ec 0c             	sub    $0xc,%esp
f0104668:	56                   	push   %esi
f0104669:	e8 92 fe ff ff       	call   f0104500 <page_fault_handler>
f010466e:	83 c4 10             	add    $0x10,%esp
	}
	switch (tf->tf_trapno) {
f0104671:	8b 46 28             	mov    0x28(%esi),%eax
f0104674:	83 f8 03             	cmp    $0x3,%eax
f0104677:	74 1a                	je     f0104693 <trap+0x11e>
f0104679:	83 f8 0e             	cmp    $0xe,%eax
f010467c:	74 07                	je     f0104685 <trap+0x110>
f010467e:	83 f8 01             	cmp    $0x1,%eax
f0104681:	75 1c                	jne    f010469f <trap+0x12a>
f0104683:	eb 0e                	jmp    f0104693 <trap+0x11e>
		case T_PGFLT:
			page_fault_handler(tf);
f0104685:	83 ec 0c             	sub    $0xc,%esp
f0104688:	56                   	push   %esi
f0104689:	e8 72 fe ff ff       	call   f0104500 <page_fault_handler>
f010468e:	83 c4 10             	add    $0x10,%esp
f0104691:	eb 0c                	jmp    f010469f <trap+0x12a>
			break;
		case T_DEBUG:
		case T_BRKPT:
			monitor(tf);
f0104693:	83 ec 0c             	sub    $0xc,%esp
f0104696:	56                   	push   %esi
f0104697:	e8 a5 c5 ff ff       	call   f0100c41 <monitor>
f010469c:	83 c4 10             	add    $0x10,%esp
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010469f:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f01046a3:	75 1a                	jne    f01046bf <trap+0x14a>
		cprintf("Spurious interrupt on irq 7\n");
f01046a5:	83 ec 0c             	sub    $0xc,%esp
f01046a8:	68 54 7c 10 f0       	push   $0xf0107c54
f01046ad:	e8 e2 f7 ff ff       	call   f0103e94 <cprintf>
		print_trapframe(tf);
f01046b2:	89 34 24             	mov    %esi,(%esp)
f01046b5:	e8 be fc ff ff       	call   f0104378 <print_trapframe>
f01046ba:	83 c4 10             	add    $0x10,%esp
f01046bd:	eb 43                	jmp    f0104702 <trap+0x18d>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01046bf:	83 ec 0c             	sub    $0xc,%esp
f01046c2:	56                   	push   %esi
f01046c3:	e8 b0 fc ff ff       	call   f0104378 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01046c8:	83 c4 10             	add    $0x10,%esp
f01046cb:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01046d0:	75 17                	jne    f01046e9 <trap+0x174>
		panic("unhandled trap in kernel");
f01046d2:	83 ec 04             	sub    $0x4,%esp
f01046d5:	68 71 7c 10 f0       	push   $0xf0107c71
f01046da:	68 01 01 00 00       	push   $0x101
f01046df:	68 28 7c 10 f0       	push   $0xf0107c28
f01046e4:	e8 57 b9 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01046e9:	e8 79 19 00 00       	call   f0106067 <cpunum>
f01046ee:	83 ec 0c             	sub    $0xc,%esp
f01046f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f4:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f01046fa:	e8 8d f4 ff ff       	call   f0103b8c <env_destroy>
f01046ff:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104702:	e8 60 19 00 00       	call   f0106067 <cpunum>
f0104707:	6b c0 74             	imul   $0x74,%eax,%eax
f010470a:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f0104711:	74 2a                	je     f010473d <trap+0x1c8>
f0104713:	e8 4f 19 00 00       	call   f0106067 <cpunum>
f0104718:	6b c0 74             	imul   $0x74,%eax,%eax
f010471b:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104721:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104725:	75 16                	jne    f010473d <trap+0x1c8>
		env_run(curenv);
f0104727:	e8 3b 19 00 00       	call   f0106067 <cpunum>
f010472c:	83 ec 0c             	sub    $0xc,%esp
f010472f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104732:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104738:	e8 ee f4 ff ff       	call   f0103c2b <env_run>
	else
		sched_yield();
f010473d:	e8 b8 00 00 00       	call   f01047fa <sched_yield>

f0104742 <_divide_error>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
  TRAPHANDLER_NOEC(_divide_error, T_DIVIDE);
f0104742:	6a 00                	push   $0x0
f0104744:	6a 00                	push   $0x0
f0104746:	e9 95 00 00 00       	jmp    f01047e0 <_alltraps>
f010474b:	90                   	nop

f010474c <_debug>:
  TRAPHANDLER_NOEC(_debug, T_DEBUG);
f010474c:	6a 00                	push   $0x0
f010474e:	6a 01                	push   $0x1
f0104750:	e9 8b 00 00 00       	jmp    f01047e0 <_alltraps>
f0104755:	90                   	nop

f0104756 <_non_maskable_interrupt>:
  TRAPHANDLER_NOEC(_non_maskable_interrupt, T_NMI);
f0104756:	6a 00                	push   $0x0
f0104758:	6a 02                	push   $0x2
f010475a:	e9 81 00 00 00       	jmp    f01047e0 <_alltraps>
f010475f:	90                   	nop

f0104760 <_breakpoint>:
  TRAPHANDLER_NOEC(_breakpoint, T_BRKPT);
f0104760:	6a 00                	push   $0x0
f0104762:	6a 03                	push   $0x3
f0104764:	eb 7a                	jmp    f01047e0 <_alltraps>

f0104766 <_overflow>:
  TRAPHANDLER_NOEC(_overflow, T_OFLOW);
f0104766:	6a 00                	push   $0x0
f0104768:	6a 04                	push   $0x4
f010476a:	eb 74                	jmp    f01047e0 <_alltraps>

f010476c <_bound_range_exceeded>:
  TRAPHANDLER_NOEC(_bound_range_exceeded, T_BOUND);
f010476c:	6a 00                	push   $0x0
f010476e:	6a 05                	push   $0x5
f0104770:	eb 6e                	jmp    f01047e0 <_alltraps>

f0104772 <_invalid_opcode>:
  TRAPHANDLER_NOEC(_invalid_opcode, T_ILLOP);
f0104772:	6a 00                	push   $0x0
f0104774:	6a 06                	push   $0x6
f0104776:	eb 68                	jmp    f01047e0 <_alltraps>

f0104778 <_device_not_available>:
  TRAPHANDLER_NOEC(_device_not_available, T_DEVICE);
f0104778:	6a 00                	push   $0x0
f010477a:	6a 07                	push   $0x7
f010477c:	eb 62                	jmp    f01047e0 <_alltraps>

f010477e <_double_fault>:
  TRAPHANDLER(_double_fault, T_DBLFLT);
f010477e:	6a 08                	push   $0x8
f0104780:	eb 5e                	jmp    f01047e0 <_alltraps>

f0104782 <_invalid_tss>:

  TRAPHANDLER(_invalid_tss, T_TSS);
f0104782:	6a 0a                	push   $0xa
f0104784:	eb 5a                	jmp    f01047e0 <_alltraps>

f0104786 <_segment_not_present>:
  TRAPHANDLER(_segment_not_present, T_SEGNP);
f0104786:	6a 0b                	push   $0xb
f0104788:	eb 56                	jmp    f01047e0 <_alltraps>

f010478a <_stack_fault>:
  TRAPHANDLER(_stack_fault, T_STACK);
f010478a:	6a 0c                	push   $0xc
f010478c:	eb 52                	jmp    f01047e0 <_alltraps>

f010478e <_general_protection>:
  TRAPHANDLER(_general_protection, T_GPFLT);
f010478e:	6a 0d                	push   $0xd
f0104790:	eb 4e                	jmp    f01047e0 <_alltraps>

f0104792 <_page_fault>:
  TRAPHANDLER(_page_fault, T_PGFLT);
f0104792:	6a 0e                	push   $0xe
f0104794:	eb 4a                	jmp    f01047e0 <_alltraps>

f0104796 <_x87_fpu_error>:

  TRAPHANDLER_NOEC(_x87_fpu_error, T_FPERR);
f0104796:	6a 00                	push   $0x0
f0104798:	6a 10                	push   $0x10
f010479a:	eb 44                	jmp    f01047e0 <_alltraps>

f010479c <_alignment_check>:
  TRAPHANDLER(_alignment_check, T_ALIGN);
f010479c:	6a 11                	push   $0x11
f010479e:	eb 40                	jmp    f01047e0 <_alltraps>

f01047a0 <_machine_check>:
  TRAPHANDLER_NOEC(_machine_check, T_MCHK);
f01047a0:	6a 00                	push   $0x0
f01047a2:	6a 12                	push   $0x12
f01047a4:	eb 3a                	jmp    f01047e0 <_alltraps>

f01047a6 <_simd_fp_exception>:
  TRAPHANDLER_NOEC(_simd_fp_exception, T_SIMDERR );
f01047a6:	6a 00                	push   $0x0
f01047a8:	6a 13                	push   $0x13
f01047aa:	eb 34                	jmp    f01047e0 <_alltraps>

f01047ac <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
   pushl $GD_UD
f01047ac:	6a 20                	push   $0x20
   pushl %ebp
f01047ae:	55                   	push   %ebp
   pushfl
f01047af:	9c                   	pushf  
   pushl $GD_UT
f01047b0:	6a 18                	push   $0x18
   pushl %esi
f01047b2:	56                   	push   %esi
   pushl $0
f01047b3:	6a 00                	push   $0x0
 	 pushl $0
f01047b5:	6a 00                	push   $0x0

   pushw $0    # uint16_t tf_padding2
f01047b7:	66 6a 00             	pushw  $0x0
   pushw %ds
f01047ba:	66 1e                	pushw  %ds
   pushw $0    # uint16_t tf_padding1
f01047bc:	66 6a 00             	pushw  $0x0
   pushw %es
f01047bf:	66 06                	pushw  %es
   pushal
f01047c1:	60                   	pusha  

   movw $GD_KD, %ax
f01047c2:	66 b8 10 00          	mov    $0x10,%ax
   movw %ax, %ds
f01047c6:	8e d8                	mov    %eax,%ds
   movw %ax, %es
f01047c8:	8e c0                	mov    %eax,%es
   pushl %esp
f01047ca:	54                   	push   %esp

   call syscall_helper
f01047cb:	e8 03 03 00 00       	call   f0104ad3 <syscall_helper>

   popl %esp
f01047d0:	5c                   	pop    %esp
   popal
f01047d1:	61                   	popa   
   popw %cx  # eliminate padding
f01047d2:	66 59                	pop    %cx
   popw %es
f01047d4:	66 07                	popw   %es
   popw %cx  # eliminate padding
f01047d6:	66 59                	pop    %cx
   popw %ds
f01047d8:	66 1f                	popw   %ds

   movl %ebp, %ecx
f01047da:	89 e9                	mov    %ebp,%ecx
   movl %esi, %edx
f01047dc:	89 f2                	mov    %esi,%edx
   sysexit
f01047de:	0f 35                	sysexit 

f01047e0 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
  pushw $0    # uint16_t tf_padding2
f01047e0:	66 6a 00             	pushw  $0x0
	pushw %ds
f01047e3:	66 1e                	pushw  %ds
	pushw $0    # uint16_t tf_padding1
f01047e5:	66 6a 00             	pushw  $0x0
	pushw %es
f01047e8:	66 06                	pushw  %es
	pushal
f01047ea:	60                   	pusha  

  movl $GD_KD, %eax
f01047eb:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f01047f0:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01047f2:	8e c0                	mov    %eax,%es
	pushl %esp
f01047f4:	54                   	push   %esp

	call trap
f01047f5:	e8 7b fd ff ff       	call   f0104575 <trap>

f01047fa <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01047fa:	55                   	push   %ebp
f01047fb:	89 e5                	mov    %esp,%ebp
f01047fd:	53                   	push   %ebx
f01047fe:	83 ec 04             	sub    $0x4,%esp

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0104801:	8b 1d 6c 82 23 f0    	mov    0xf023826c,%ebx
f0104807:	8d 43 50             	lea    0x50(%ebx),%eax
	// LAB 4: Your code here.

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010480a:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f010480f:	83 38 01             	cmpl   $0x1,(%eax)
f0104812:	74 0b                	je     f010481f <sched_yield+0x25>
f0104814:	8b 48 04             	mov    0x4(%eax),%ecx
f0104817:	83 e9 02             	sub    $0x2,%ecx
f010481a:	83 f9 01             	cmp    $0x1,%ecx
f010481d:	76 10                	jbe    f010482f <sched_yield+0x35>
	// LAB 4: Your code here.

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010481f:	83 c2 01             	add    $0x1,%edx
f0104822:	83 e8 80             	sub    $0xffffff80,%eax
f0104825:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010482b:	75 e2                	jne    f010480f <sched_yield+0x15>
f010482d:	eb 08                	jmp    f0104837 <sched_yield+0x3d>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f010482f:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104835:	75 1f                	jne    f0104856 <sched_yield+0x5c>
		cprintf("No more runnable environments!\n");
f0104837:	83 ec 0c             	sub    $0xc,%esp
f010483a:	68 50 7e 10 f0       	push   $0xf0107e50
f010483f:	e8 50 f6 ff ff       	call   f0103e94 <cprintf>
f0104844:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104847:	83 ec 0c             	sub    $0xc,%esp
f010484a:	6a 00                	push   $0x0
f010484c:	e8 f0 c3 ff ff       	call   f0100c41 <monitor>
f0104851:	83 c4 10             	add    $0x10,%esp
f0104854:	eb f1                	jmp    f0104847 <sched_yield+0x4d>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0104856:	e8 0c 18 00 00       	call   f0106067 <cpunum>
f010485b:	c1 e0 07             	shl    $0x7,%eax
f010485e:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0104860:	8b 43 54             	mov    0x54(%ebx),%eax
f0104863:	83 e8 02             	sub    $0x2,%eax
f0104866:	83 f8 01             	cmp    $0x1,%eax
f0104869:	76 17                	jbe    f0104882 <sched_yield+0x88>
		panic("CPU %d: No idle environment!", cpunum());
f010486b:	e8 f7 17 00 00       	call   f0106067 <cpunum>
f0104870:	50                   	push   %eax
f0104871:	68 70 7e 10 f0       	push   $0xf0107e70
f0104876:	6a 33                	push   $0x33
f0104878:	68 8d 7e 10 f0       	push   $0xf0107e8d
f010487d:	e8 be b7 ff ff       	call   f0100040 <_panic>
	env_run(idle);
f0104882:	83 ec 0c             	sub    $0xc,%esp
f0104885:	53                   	push   %ebx
f0104886:	e8 a0 f3 ff ff       	call   f0103c2b <env_run>

f010488b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010488b:	55                   	push   %ebp
f010488c:	89 e5                	mov    %esp,%ebp
f010488e:	57                   	push   %edi
f010488f:	56                   	push   %esi
f0104890:	53                   	push   %ebx
f0104891:	83 ec 2c             	sub    $0x2c,%esp
f0104894:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104897:	83 f8 0e             	cmp    $0xe,%eax
f010489a:	0f 87 26 02 00 00    	ja     f0104ac6 <syscall+0x23b>
f01048a0:	ff 24 85 e4 7e 10 f0 	jmp    *-0xfef811c(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void*)s, len, 0);
f01048a7:	e8 bb 17 00 00       	call   f0106067 <cpunum>
f01048ac:	6a 00                	push   $0x0
f01048ae:	ff 75 10             	pushl  0x10(%ebp)
f01048b1:	ff 75 0c             	pushl  0xc(%ebp)
f01048b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b7:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f01048bd:	e8 05 ec ff ff       	call   f01034c7 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01048c2:	83 c4 0c             	add    $0xc,%esp
f01048c5:	ff 75 0c             	pushl  0xc(%ebp)
f01048c8:	ff 75 10             	pushl  0x10(%ebp)
f01048cb:	68 9a 7e 10 f0       	push   $0xf0107e9a
f01048d0:	e8 bf f5 ff ff       	call   f0103e94 <cprintf>
f01048d5:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char *) a1, a2);
			return 0;
f01048d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01048dd:	e9 e9 01 00 00       	jmp    f0104acb <syscall+0x240>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01048e2:	e8 83 be ff ff       	call   f010076a <cons_getc>
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char *) a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f01048e7:	e9 df 01 00 00       	jmp    f0104acb <syscall+0x240>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01048ec:	e8 76 17 00 00       	call   f0106067 <cpunum>
f01048f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01048f4:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01048fa:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((const char *) a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f01048fd:	e9 c9 01 00 00       	jmp    f0104acb <syscall+0x240>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104902:	83 ec 04             	sub    $0x4,%esp
f0104905:	6a 01                	push   $0x1
f0104907:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010490a:	50                   	push   %eax
f010490b:	ff 75 0c             	pushl  0xc(%ebp)
f010490e:	e8 90 ec ff ff       	call   f01035a3 <envid2env>
f0104913:	83 c4 10             	add    $0x10,%esp
f0104916:	85 c0                	test   %eax,%eax
f0104918:	0f 88 ad 01 00 00    	js     f0104acb <syscall+0x240>
		return r;
	if (e == curenv)
f010491e:	e8 44 17 00 00       	call   f0106067 <cpunum>
f0104923:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104926:	6b c0 74             	imul   $0x74,%eax,%eax
f0104929:	39 90 28 90 23 f0    	cmp    %edx,-0xfdc6fd8(%eax)
f010492f:	75 23                	jne    f0104954 <syscall+0xc9>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104931:	e8 31 17 00 00       	call   f0106067 <cpunum>
f0104936:	83 ec 08             	sub    $0x8,%esp
f0104939:	6b c0 74             	imul   $0x74,%eax,%eax
f010493c:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104942:	ff 70 48             	pushl  0x48(%eax)
f0104945:	68 9f 7e 10 f0       	push   $0xf0107e9f
f010494a:	e8 45 f5 ff ff       	call   f0103e94 <cprintf>
f010494f:	83 c4 10             	add    $0x10,%esp
f0104952:	eb 25                	jmp    f0104979 <syscall+0xee>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104954:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104957:	e8 0b 17 00 00       	call   f0106067 <cpunum>
f010495c:	83 ec 04             	sub    $0x4,%esp
f010495f:	53                   	push   %ebx
f0104960:	6b c0 74             	imul   $0x74,%eax,%eax
f0104963:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104969:	ff 70 48             	pushl  0x48(%eax)
f010496c:	68 ba 7e 10 f0       	push   $0xf0107eba
f0104971:	e8 1e f5 ff ff       	call   f0103e94 <cprintf>
f0104976:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104979:	83 ec 0c             	sub    $0xc,%esp
f010497c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010497f:	e8 08 f2 ff ff       	call   f0103b8c <env_destroy>
f0104984:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104987:	b8 00 00 00 00       	mov    $0x0,%eax
f010498c:	e9 3a 01 00 00       	jmp    f0104acb <syscall+0x240>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104991:	81 7d 0c ff ff ff ef 	cmpl   $0xefffffff,0xc(%ebp)
f0104998:	77 14                	ja     f01049ae <syscall+0x123>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010499a:	ff 75 0c             	pushl  0xc(%ebp)
f010499d:	68 e4 67 10 f0       	push   $0xf01067e4
f01049a2:	6a 47                	push   $0x47
f01049a4:	68 d2 7e 10 f0       	push   $0xf0107ed2
f01049a9:	e8 92 b6 ff ff       	call   f0100040 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01049ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049b1:	05 00 00 00 10       	add    $0x10000000,%eax
f01049b6:	c1 e8 0c             	shr    $0xc,%eax
f01049b9:	3b 05 a8 8e 23 f0    	cmp    0xf0238ea8,%eax
f01049bf:	72 14                	jb     f01049d5 <syscall+0x14a>
		panic("pa2page called with invalid pa");
f01049c1:	83 ec 04             	sub    $0x4,%esp
f01049c4:	68 3c 6f 10 f0       	push   $0xf0106f3c
f01049c9:	6a 4f                	push   $0x4f
f01049cb:	68 81 75 10 f0       	push   $0xf0107581
f01049d0:	e8 6b b6 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01049d5:	8b 15 b0 8e 23 f0    	mov    0xf0238eb0,%edx
f01049db:	8d 1c c2             	lea    (%edx,%eax,8),%ebx
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p == NULL)
		return E_INVAL;
f01049de:	b8 03 00 00 00       	mov    $0x3,%eax
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p == NULL)
f01049e3:	85 db                	test   %ebx,%ebx
f01049e5:	0f 84 e0 00 00 00    	je     f0104acb <syscall+0x240>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f01049eb:	e8 77 16 00 00       	call   f0106067 <cpunum>
f01049f0:	6a 06                	push   $0x6
f01049f2:	ff 75 10             	pushl  0x10(%ebp)
f01049f5:	53                   	push   %ebx
f01049f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f9:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01049ff:	ff 70 64             	pushl  0x64(%eax)
f0104a02:	e8 c5 cf ff ff       	call   f01019cc <page_insert>
f0104a07:	83 c4 10             	add    $0x10,%esp
f0104a0a:	e9 bc 00 00 00       	jmp    f0104acb <syscall+0x240>

static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_cur_brk + inc), inc);
f0104a0f:	e8 53 16 00 00       	call   f0106067 <cpunum>
f0104a14:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a17:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a20:	03 58 60             	add    0x60(%eax),%ebx
f0104a23:	e8 3f 16 00 00       	call   f0106067 <cpunum>
f0104a28:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a2b:	8b b8 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%edi
}

static void
region_alloc(struct Env *e, void *va, size_t len)
{
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f0104a31:	89 d8                	mov    %ebx,%eax
f0104a33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104a38:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f0104a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a3e:	8d b4 0b ff 0f 00 00 	lea    0xfff(%ebx,%ecx,1),%esi
f0104a45:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0104a4b:	39 f0                	cmp    %esi,%eax
f0104a4d:	73 5e                	jae    f0104aad <syscall+0x222>
f0104a4f:	89 c3                	mov    %eax,%ebx
		if (!(tmp = page_alloc(0))) {
f0104a51:	83 ec 0c             	sub    $0xc,%esp
f0104a54:	6a 00                	push   $0x0
f0104a56:	e8 8f c8 ff ff       	call   f01012ea <page_alloc>
f0104a5b:	83 c4 10             	add    $0x10,%esp
f0104a5e:	85 c0                	test   %eax,%eax
f0104a60:	75 17                	jne    f0104a79 <syscall+0x1ee>
			panic("Execute region_alloc(...) failed. Out of memory.\n");
f0104a62:	83 ec 04             	sub    $0x4,%esp
f0104a65:	68 44 79 10 f0       	push   $0xf0107944
f0104a6a:	68 20 01 00 00       	push   $0x120
f0104a6f:	68 d2 7e 10 f0       	push   $0xf0107ed2
f0104a74:	e8 c7 b5 ff ff       	call   f0100040 <_panic>
		} else {
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
f0104a79:	6a 06                	push   $0x6
f0104a7b:	53                   	push   %ebx
f0104a7c:	50                   	push   %eax
f0104a7d:	ff 77 64             	pushl  0x64(%edi)
f0104a80:	e8 47 cf ff ff       	call   f01019cc <page_insert>
f0104a85:	83 c4 10             	add    $0x10,%esp
f0104a88:	85 c0                	test   %eax,%eax
f0104a8a:	74 17                	je     f0104aa3 <syscall+0x218>
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
f0104a8c:	83 ec 04             	sub    $0x4,%esp
f0104a8f:	68 78 79 10 f0       	push   $0xf0107978
f0104a94:	68 23 01 00 00       	push   $0x123
f0104a99:	68 d2 7e 10 f0       	push   $0xf0107ed2
f0104a9e:	e8 9d b5 ff ff       	call   f0100040 <_panic>
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0104aa3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104aa9:	39 de                	cmp    %ebx,%esi
f0104aab:	77 a4                	ja     f0104a51 <syscall+0x1c6>
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
			}
		}
	}
	e->env_cur_brk = start;
f0104aad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104ab0:	89 47 60             	mov    %eax,0x60(%edi)
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_cur_brk + inc), inc);
	// cprintf("sbrk %x inc %x\n", curenv->env_cur_brk, inc);
	return curenv->env_cur_brk;
f0104ab3:	e8 af 15 00 00       	call   f0106067 <cpunum>
f0104ab8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104abb:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104ac1:	8b 40 60             	mov    0x60(%eax),%eax
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_map_kernel_page:
			return sys_map_kernel_page((void *)a1, (void *)a2);
		case SYS_sbrk:
			return sys_sbrk(a1);
f0104ac4:	eb 05                	jmp    f0104acb <syscall+0x240>
		default:
			return -E_INVAL;
f0104ac6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	// panic("syscall not implemented");
}
f0104acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ace:	5b                   	pop    %ebx
f0104acf:	5e                   	pop    %esi
f0104ad0:	5f                   	pop    %edi
f0104ad1:	5d                   	pop    %ebp
f0104ad2:	c3                   	ret    

f0104ad3 <syscall_helper>:

void
syscall_helper(struct Trapframe *tf)
{
f0104ad3:	55                   	push   %ebp
f0104ad4:	89 e5                	mov    %esp,%ebp
f0104ad6:	57                   	push   %edi
f0104ad7:	56                   	push   %esi
f0104ad8:	53                   	push   %ebx
f0104ad9:	83 ec 0c             	sub    $0xc,%esp
f0104adc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	curenv->env_tf = *tf;
f0104adf:	e8 83 15 00 00       	call   f0106067 <cpunum>
f0104ae4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae7:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104aed:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104af2:	89 c7                	mov    %eax,%edi
f0104af4:	89 de                	mov    %ebx,%esi
f0104af6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
f0104af8:	83 ec 08             	sub    $0x8,%esp
f0104afb:	6a 00                	push   $0x0
f0104afd:	ff 33                	pushl  (%ebx)
f0104aff:	ff 73 10             	pushl  0x10(%ebx)
f0104b02:	ff 73 18             	pushl  0x18(%ebx)
f0104b05:	ff 73 14             	pushl  0x14(%ebx)
f0104b08:	ff 73 1c             	pushl  0x1c(%ebx)
f0104b0b:	e8 7b fd ff ff       	call   f010488b <syscall>
f0104b10:	89 43 1c             	mov    %eax,0x1c(%ebx)
}
f0104b13:	83 c4 20             	add    $0x20,%esp
f0104b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b19:	5b                   	pop    %ebx
f0104b1a:	5e                   	pop    %esi
f0104b1b:	5f                   	pop    %edi
f0104b1c:	5d                   	pop    %ebp
f0104b1d:	c3                   	ret    

f0104b1e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104b1e:	55                   	push   %ebp
f0104b1f:	89 e5                	mov    %esp,%ebp
f0104b21:	57                   	push   %edi
f0104b22:	56                   	push   %esi
f0104b23:	53                   	push   %ebx
f0104b24:	83 ec 14             	sub    $0x14,%esp
f0104b27:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b2a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104b2d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104b30:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104b33:	8b 1a                	mov    (%edx),%ebx
f0104b35:	8b 01                	mov    (%ecx),%eax
f0104b37:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f0104b3a:	39 c3                	cmp    %eax,%ebx
f0104b3c:	0f 8f 9a 00 00 00    	jg     f0104bdc <stab_binsearch+0xbe>
f0104b42:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0104b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b4c:	01 d8                	add    %ebx,%eax
f0104b4e:	89 c6                	mov    %eax,%esi
f0104b50:	c1 ee 1f             	shr    $0x1f,%esi
f0104b53:	01 c6                	add    %eax,%esi
f0104b55:	d1 fe                	sar    %esi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104b57:	39 de                	cmp    %ebx,%esi
f0104b59:	0f 8c c4 00 00 00    	jl     f0104c23 <stab_binsearch+0x105>
f0104b5f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104b62:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b65:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104b68:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0104b6c:	39 c7                	cmp    %eax,%edi
f0104b6e:	0f 84 b4 00 00 00    	je     f0104c28 <stab_binsearch+0x10a>
f0104b74:	89 f0                	mov    %esi,%eax
			m--;
f0104b76:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104b79:	39 d8                	cmp    %ebx,%eax
f0104b7b:	0f 8c a2 00 00 00    	jl     f0104c23 <stab_binsearch+0x105>
f0104b81:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0104b85:	83 ea 0c             	sub    $0xc,%edx
f0104b88:	39 f9                	cmp    %edi,%ecx
f0104b8a:	75 ea                	jne    f0104b76 <stab_binsearch+0x58>
f0104b8c:	e9 99 00 00 00       	jmp    f0104c2a <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104b91:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104b94:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104b96:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b99:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ba0:	eb 2b                	jmp    f0104bcd <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104ba2:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104ba5:	76 14                	jbe    f0104bbb <stab_binsearch+0x9d>
			*region_right = m - 1;
f0104ba7:	83 e8 01             	sub    $0x1,%eax
f0104baa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104bad:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104bb0:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104bb2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104bb9:	eb 12                	jmp    f0104bcd <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104bbb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104bbe:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104bc0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104bc4:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104bc6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104bcd:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0104bd0:	0f 8d 73 ff ff ff    	jge    f0104b49 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104bd6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104bda:	75 0f                	jne    f0104beb <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f0104bdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bdf:	8b 00                	mov    (%eax),%eax
f0104be1:	83 e8 01             	sub    $0x1,%eax
f0104be4:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104be7:	89 07                	mov    %eax,(%edi)
f0104be9:	eb 57                	jmp    f0104c42 <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104beb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bee:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104bf0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104bf3:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104bf5:	39 c8                	cmp    %ecx,%eax
f0104bf7:	7e 23                	jle    f0104c1c <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0104bf9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104bfc:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104bff:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104c02:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104c06:	39 df                	cmp    %ebx,%edi
f0104c08:	74 12                	je     f0104c1c <stab_binsearch+0xfe>
		     l--)
f0104c0a:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c0d:	39 c8                	cmp    %ecx,%eax
f0104c0f:	7e 0b                	jle    f0104c1c <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0104c11:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f0104c15:	83 ea 0c             	sub    $0xc,%edx
f0104c18:	39 df                	cmp    %ebx,%edi
f0104c1a:	75 ee                	jne    f0104c0a <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104c1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c1f:	89 07                	mov    %eax,(%edi)
	}
}
f0104c21:	eb 1f                	jmp    f0104c42 <stab_binsearch+0x124>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c23:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104c26:	eb a5                	jmp    f0104bcd <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104c28:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c2a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c2d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c30:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c34:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104c37:	0f 82 54 ff ff ff    	jb     f0104b91 <stab_binsearch+0x73>
f0104c3d:	e9 60 ff ff ff       	jmp    f0104ba2 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104c42:	83 c4 14             	add    $0x14,%esp
f0104c45:	5b                   	pop    %ebx
f0104c46:	5e                   	pop    %esi
f0104c47:	5f                   	pop    %edi
f0104c48:	5d                   	pop    %ebp
f0104c49:	c3                   	ret    

f0104c4a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104c4a:	55                   	push   %ebp
f0104c4b:	89 e5                	mov    %esp,%ebp
f0104c4d:	57                   	push   %edi
f0104c4e:	56                   	push   %esi
f0104c4f:	53                   	push   %ebx
f0104c50:	83 ec 3c             	sub    $0x3c,%esp
f0104c53:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104c59:	c7 03 20 7f 10 f0    	movl   $0xf0107f20,(%ebx)
	info->eip_line = 0;
f0104c5f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104c66:	c7 43 08 20 7f 10 f0 	movl   $0xf0107f20,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104c6d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104c74:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104c77:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104c7e:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104c84:	0f 87 a3 00 00 00    	ja     f0104d2d <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U)) {
f0104c8a:	e8 d8 13 00 00       	call   f0106067 <cpunum>
f0104c8f:	6a 04                	push   $0x4
f0104c91:	6a 10                	push   $0x10
f0104c93:	68 00 00 20 00       	push   $0x200000
f0104c98:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c9b:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104ca1:	e8 6b e7 ff ff       	call   f0103411 <user_mem_check>
f0104ca6:	83 c4 10             	add    $0x10,%esp
f0104ca9:	85 c0                	test   %eax,%eax
f0104cab:	0f 85 52 02 00 00    	jne    f0104f03 <debuginfo_eip+0x2b9>
			return -1;
		}

		stabs = usd->stabs;
f0104cb1:	a1 00 00 20 00       	mov    0x200000,%eax
f0104cb6:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104cb9:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104cbf:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104cc5:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104cc8:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104ccd:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
f0104cd0:	e8 92 13 00 00       	call   f0106067 <cpunum>
f0104cd5:	6a 04                	push   $0x4
f0104cd7:	89 f2                	mov    %esi,%edx
f0104cd9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104cdc:	29 ca                	sub    %ecx,%edx
f0104cde:	c1 fa 02             	sar    $0x2,%edx
f0104ce1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104ce7:	52                   	push   %edx
f0104ce8:	51                   	push   %ecx
f0104ce9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cec:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104cf2:	e8 1a e7 ff ff       	call   f0103411 <user_mem_check>
f0104cf7:	83 c4 10             	add    $0x10,%esp
f0104cfa:	85 c0                	test   %eax,%eax
f0104cfc:	0f 85 08 02 00 00    	jne    f0104f0a <debuginfo_eip+0x2c0>
			return -1;
		}

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
f0104d02:	e8 60 13 00 00       	call   f0106067 <cpunum>
f0104d07:	6a 04                	push   $0x4
f0104d09:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104d0c:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104d0f:	29 ca                	sub    %ecx,%edx
f0104d11:	52                   	push   %edx
f0104d12:	51                   	push   %ecx
f0104d13:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d16:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104d1c:	e8 f0 e6 ff ff       	call   f0103411 <user_mem_check>
f0104d21:	83 c4 10             	add    $0x10,%esp
f0104d24:	85 c0                	test   %eax,%eax
f0104d26:	74 1f                	je     f0104d47 <debuginfo_eip+0xfd>
f0104d28:	e9 e4 01 00 00       	jmp    f0104f11 <debuginfo_eip+0x2c7>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d2d:	c7 45 bc b3 65 11 f0 	movl   $0xf01165b3,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104d34:	c7 45 b8 91 2e 11 f0 	movl   $0xf0112e91,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104d3b:	be 90 2e 11 f0       	mov    $0xf0112e90,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104d40:	c7 45 c0 74 84 10 f0 	movl   $0xf0108474,-0x40(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d47:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104d4a:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104d4d:	0f 83 c5 01 00 00    	jae    f0104f18 <debuginfo_eip+0x2ce>
f0104d53:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104d57:	0f 85 c2 01 00 00    	jne    f0104f1f <debuginfo_eip+0x2d5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104d5d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d64:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104d67:	c1 fe 02             	sar    $0x2,%esi
f0104d6a:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104d70:	83 e8 01             	sub    $0x1,%eax
f0104d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104d76:	83 ec 08             	sub    $0x8,%esp
f0104d79:	57                   	push   %edi
f0104d7a:	6a 64                	push   $0x64
f0104d7c:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104d7f:	89 d1                	mov    %edx,%ecx
f0104d81:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d84:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104d87:	89 f0                	mov    %esi,%eax
f0104d89:	e8 90 fd ff ff       	call   f0104b1e <stab_binsearch>
	if (lfile == 0)
f0104d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d91:	83 c4 10             	add    $0x10,%esp
f0104d94:	85 c0                	test   %eax,%eax
f0104d96:	0f 84 8a 01 00 00    	je     f0104f26 <debuginfo_eip+0x2dc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104d9c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104d9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104da2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104da5:	83 ec 08             	sub    $0x8,%esp
f0104da8:	57                   	push   %edi
f0104da9:	6a 24                	push   $0x24
f0104dab:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104dae:	89 d1                	mov    %edx,%ecx
f0104db0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104db3:	89 f0                	mov    %esi,%eax
f0104db5:	e8 64 fd ff ff       	call   f0104b1e <stab_binsearch>

	if (lfun <= rfun) {
f0104dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104dbd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104dc0:	83 c4 10             	add    $0x10,%esp
f0104dc3:	39 d0                	cmp    %edx,%eax
f0104dc5:	7f 2e                	jg     f0104df5 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104dc7:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104dca:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104dcd:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104dd0:	8b 36                	mov    (%esi),%esi
f0104dd2:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104dd5:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104dd8:	39 ce                	cmp    %ecx,%esi
f0104dda:	73 06                	jae    f0104de2 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104ddc:	03 75 b8             	add    -0x48(%ebp),%esi
f0104ddf:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104de2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104de5:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104de8:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104deb:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ded:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104df0:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104df3:	eb 0f                	jmp    f0104e04 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104df5:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dfb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e01:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e04:	83 ec 08             	sub    $0x8,%esp
f0104e07:	6a 3a                	push   $0x3a
f0104e09:	ff 73 08             	pushl  0x8(%ebx)
f0104e0c:	e8 b3 0b 00 00       	call   f01059c4 <strfind>
f0104e11:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e14:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e17:	83 c4 08             	add    $0x8,%esp
f0104e1a:	57                   	push   %edi
f0104e1b:	6a 44                	push   $0x44
f0104e1d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e20:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e23:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104e26:	89 f0                	mov    %esi,%eax
f0104e28:	e8 f1 fc ff ff       	call   f0104b1e <stab_binsearch>
	if (lline <= rline) {
f0104e2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e30:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104e33:	83 c4 10             	add    $0x10,%esp
f0104e36:	39 d0                	cmp    %edx,%eax
f0104e38:	0f 8f ef 00 00 00    	jg     f0104f2d <debuginfo_eip+0x2e3>
		info->eip_line = rline;
f0104e3e:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e44:	39 f8                	cmp    %edi,%eax
f0104e46:	7c 69                	jl     f0104eb1 <debuginfo_eip+0x267>
	       && stabs[lline].n_type != N_SOL
f0104e48:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e4b:	8d 34 96             	lea    (%esi,%edx,4),%esi
f0104e4e:	0f b6 56 04          	movzbl 0x4(%esi),%edx
f0104e52:	80 fa 84             	cmp    $0x84,%dl
f0104e55:	74 41                	je     f0104e98 <debuginfo_eip+0x24e>
f0104e57:	89 f1                	mov    %esi,%ecx
f0104e59:	83 c6 08             	add    $0x8,%esi
f0104e5c:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104e60:	eb 1f                	jmp    f0104e81 <debuginfo_eip+0x237>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104e62:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e65:	39 f8                	cmp    %edi,%eax
f0104e67:	7c 48                	jl     f0104eb1 <debuginfo_eip+0x267>
	       && stabs[lline].n_type != N_SOL
f0104e69:	0f b6 51 f8          	movzbl -0x8(%ecx),%edx
f0104e6d:	83 e9 0c             	sub    $0xc,%ecx
f0104e70:	83 ee 0c             	sub    $0xc,%esi
f0104e73:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104e77:	80 fa 84             	cmp    $0x84,%dl
f0104e7a:	75 05                	jne    f0104e81 <debuginfo_eip+0x237>
f0104e7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104e7f:	eb 17                	jmp    f0104e98 <debuginfo_eip+0x24e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104e81:	80 fa 64             	cmp    $0x64,%dl
f0104e84:	75 dc                	jne    f0104e62 <debuginfo_eip+0x218>
f0104e86:	83 3e 00             	cmpl   $0x0,(%esi)
f0104e89:	74 d7                	je     f0104e62 <debuginfo_eip+0x218>
f0104e8b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104e8f:	74 03                	je     f0104e94 <debuginfo_eip+0x24a>
f0104e91:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104e94:	39 c7                	cmp    %eax,%edi
f0104e96:	7f 19                	jg     f0104eb1 <debuginfo_eip+0x267>
f0104e98:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104e9b:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104e9e:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104ea1:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104ea4:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104ea7:	29 f8                	sub    %edi,%eax
f0104ea9:	39 c2                	cmp    %eax,%edx
f0104eab:	73 04                	jae    f0104eb1 <debuginfo_eip+0x267>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104ead:	01 fa                	add    %edi,%edx
f0104eaf:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104eb1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104eb4:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104eb7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ebc:	39 f2                	cmp    %esi,%edx
f0104ebe:	0f 8d 83 00 00 00    	jge    f0104f47 <debuginfo_eip+0x2fd>
		for (lline = lfun + 1;
f0104ec4:	8d 42 01             	lea    0x1(%edx),%eax
f0104ec7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104eca:	39 c6                	cmp    %eax,%esi
f0104ecc:	7e 66                	jle    f0104f34 <debuginfo_eip+0x2ea>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104ece:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104ed1:	c1 e1 02             	shl    $0x2,%ecx
f0104ed4:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104ed7:	80 7c 0f 04 a0       	cmpb   $0xa0,0x4(%edi,%ecx,1)
f0104edc:	75 5d                	jne    f0104f3b <debuginfo_eip+0x2f1>
f0104ede:	8d 42 02             	lea    0x2(%edx),%eax
f0104ee1:	8d 54 0f f4          	lea    -0xc(%edi,%ecx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f0104ee5:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104ee9:	39 c6                	cmp    %eax,%esi
f0104eeb:	74 55                	je     f0104f42 <debuginfo_eip+0x2f8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104eed:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f0104ef1:	83 c0 01             	add    $0x1,%eax
f0104ef4:	83 c2 0c             	add    $0xc,%edx
f0104ef7:	80 f9 a0             	cmp    $0xa0,%cl
f0104efa:	74 e9                	je     f0104ee5 <debuginfo_eip+0x29b>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104efc:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f01:	eb 44                	jmp    f0104f47 <debuginfo_eip+0x2fd>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U)) {
			return -1;
f0104f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f08:	eb 3d                	jmp    f0104f47 <debuginfo_eip+0x2fd>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
			return -1;
f0104f0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f0f:	eb 36                	jmp    f0104f47 <debuginfo_eip+0x2fd>
		}

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
			return -1;
f0104f11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f16:	eb 2f                	jmp    f0104f47 <debuginfo_eip+0x2fd>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f1d:	eb 28                	jmp    f0104f47 <debuginfo_eip+0x2fd>
f0104f1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f24:	eb 21                	jmp    f0104f47 <debuginfo_eip+0x2fd>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f2b:	eb 1a                	jmp    f0104f47 <debuginfo_eip+0x2fd>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = rline;
	} else {
		return -1;
f0104f2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f32:	eb 13                	jmp    f0104f47 <debuginfo_eip+0x2fd>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f34:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f39:	eb 0c                	jmp    f0104f47 <debuginfo_eip+0x2fd>
f0104f3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f40:	eb 05                	jmp    f0104f47 <debuginfo_eip+0x2fd>
f0104f42:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f4a:	5b                   	pop    %ebx
f0104f4b:	5e                   	pop    %esi
f0104f4c:	5f                   	pop    %edi
f0104f4d:	5d                   	pop    %ebp
f0104f4e:	c3                   	ret    

f0104f4f <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f4f:	55                   	push   %ebp
f0104f50:	89 e5                	mov    %esp,%ebp
f0104f52:	57                   	push   %edi
f0104f53:	56                   	push   %esi
f0104f54:	53                   	push   %ebx
f0104f55:	83 ec 1c             	sub    $0x1c,%esp
f0104f58:	89 c7                	mov    %eax,%edi
f0104f5a:	89 d6                	mov    %edx,%esi
f0104f5c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f5f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f62:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f65:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104f68:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
f0104f6b:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0104f6f:	0f 85 bf 00 00 00    	jne    f0105034 <printnum+0xe5>
f0104f75:	39 1d 88 8a 23 f0    	cmp    %ebx,0xf0238a88
f0104f7b:	0f 8d de 00 00 00    	jge    f010505f <printnum+0x110>
		judge_time_for_space = width;
f0104f81:	89 1d 88 8a 23 f0    	mov    %ebx,0xf0238a88
f0104f87:	e9 d3 00 00 00       	jmp    f010505f <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0104f8c:	83 eb 01             	sub    $0x1,%ebx
f0104f8f:	85 db                	test   %ebx,%ebx
f0104f91:	7f 37                	jg     f0104fca <printnum+0x7b>
f0104f93:	e9 ea 00 00 00       	jmp    f0105082 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
f0104f98:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104f9b:	a3 84 8a 23 f0       	mov    %eax,0xf0238a84
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fa0:	83 ec 08             	sub    $0x8,%esp
f0104fa3:	56                   	push   %esi
f0104fa4:	83 ec 04             	sub    $0x4,%esp
f0104fa7:	ff 75 dc             	pushl  -0x24(%ebp)
f0104faa:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fad:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fb0:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fb3:	e8 18 16 00 00       	call   f01065d0 <__umoddi3>
f0104fb8:	83 c4 14             	add    $0x14,%esp
f0104fbb:	0f be 80 2a 7f 10 f0 	movsbl -0xfef80d6(%eax),%eax
f0104fc2:	50                   	push   %eax
f0104fc3:	ff d7                	call   *%edi
f0104fc5:	83 c4 10             	add    $0x10,%esp
f0104fc8:	eb 16                	jmp    f0104fe0 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
f0104fca:	83 ec 08             	sub    $0x8,%esp
f0104fcd:	56                   	push   %esi
f0104fce:	ff 75 18             	pushl  0x18(%ebp)
f0104fd1:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0104fd3:	83 c4 10             	add    $0x10,%esp
f0104fd6:	83 eb 01             	sub    $0x1,%ebx
f0104fd9:	75 ef                	jne    f0104fca <printnum+0x7b>
f0104fdb:	e9 a2 00 00 00       	jmp    f0105082 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
f0104fe0:	3b 1d 88 8a 23 f0    	cmp    0xf0238a88,%ebx
f0104fe6:	0f 85 76 01 00 00    	jne    f0105162 <printnum+0x213>
		while(num_of_space-- > 0)
f0104fec:	a1 84 8a 23 f0       	mov    0xf0238a84,%eax
f0104ff1:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104ff4:	89 15 84 8a 23 f0    	mov    %edx,0xf0238a84
f0104ffa:	85 c0                	test   %eax,%eax
f0104ffc:	7e 1d                	jle    f010501b <printnum+0xcc>
			putch(' ', putdat);
f0104ffe:	83 ec 08             	sub    $0x8,%esp
f0105001:	56                   	push   %esi
f0105002:	6a 20                	push   $0x20
f0105004:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
f0105006:	a1 84 8a 23 f0       	mov    0xf0238a84,%eax
f010500b:	8d 50 ff             	lea    -0x1(%eax),%edx
f010500e:	89 15 84 8a 23 f0    	mov    %edx,0xf0238a84
f0105014:	83 c4 10             	add    $0x10,%esp
f0105017:	85 c0                	test   %eax,%eax
f0105019:	7f e3                	jg     f0104ffe <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
f010501b:	c7 05 84 8a 23 f0 00 	movl   $0x0,0xf0238a84
f0105022:	00 00 00 
		judge_time_for_space = 0;
f0105025:	c7 05 88 8a 23 f0 00 	movl   $0x0,0xf0238a88
f010502c:	00 00 00 
	}
}
f010502f:	e9 2e 01 00 00       	jmp    f0105162 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105034:	8b 45 10             	mov    0x10(%ebp),%eax
f0105037:	ba 00 00 00 00       	mov    $0x0,%edx
f010503c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010503f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105042:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105045:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105048:	83 fa 00             	cmp    $0x0,%edx
f010504b:	0f 87 ba 00 00 00    	ja     f010510b <printnum+0x1bc>
f0105051:	3b 45 10             	cmp    0x10(%ebp),%eax
f0105054:	0f 83 b1 00 00 00    	jae    f010510b <printnum+0x1bc>
f010505a:	e9 2d ff ff ff       	jmp    f0104f8c <printnum+0x3d>
f010505f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105062:	ba 00 00 00 00       	mov    $0x0,%edx
f0105067:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010506a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010506d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105070:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105073:	83 fa 00             	cmp    $0x0,%edx
f0105076:	77 37                	ja     f01050af <printnum+0x160>
f0105078:	3b 45 10             	cmp    0x10(%ebp),%eax
f010507b:	73 32                	jae    f01050af <printnum+0x160>
f010507d:	e9 16 ff ff ff       	jmp    f0104f98 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105082:	83 ec 08             	sub    $0x8,%esp
f0105085:	56                   	push   %esi
f0105086:	83 ec 04             	sub    $0x4,%esp
f0105089:	ff 75 dc             	pushl  -0x24(%ebp)
f010508c:	ff 75 d8             	pushl  -0x28(%ebp)
f010508f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105092:	ff 75 e0             	pushl  -0x20(%ebp)
f0105095:	e8 36 15 00 00       	call   f01065d0 <__umoddi3>
f010509a:	83 c4 14             	add    $0x14,%esp
f010509d:	0f be 80 2a 7f 10 f0 	movsbl -0xfef80d6(%eax),%eax
f01050a4:	50                   	push   %eax
f01050a5:	ff d7                	call   *%edi
f01050a7:	83 c4 10             	add    $0x10,%esp
f01050aa:	e9 b3 00 00 00       	jmp    f0105162 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01050af:	83 ec 0c             	sub    $0xc,%esp
f01050b2:	ff 75 18             	pushl  0x18(%ebp)
f01050b5:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01050b8:	50                   	push   %eax
f01050b9:	ff 75 10             	pushl  0x10(%ebp)
f01050bc:	83 ec 08             	sub    $0x8,%esp
f01050bf:	ff 75 dc             	pushl  -0x24(%ebp)
f01050c2:	ff 75 d8             	pushl  -0x28(%ebp)
f01050c5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050c8:	ff 75 e0             	pushl  -0x20(%ebp)
f01050cb:	e8 d0 13 00 00       	call   f01064a0 <__udivdi3>
f01050d0:	83 c4 18             	add    $0x18,%esp
f01050d3:	52                   	push   %edx
f01050d4:	50                   	push   %eax
f01050d5:	89 f2                	mov    %esi,%edx
f01050d7:	89 f8                	mov    %edi,%eax
f01050d9:	e8 71 fe ff ff       	call   f0104f4f <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01050de:	83 c4 18             	add    $0x18,%esp
f01050e1:	56                   	push   %esi
f01050e2:	83 ec 04             	sub    $0x4,%esp
f01050e5:	ff 75 dc             	pushl  -0x24(%ebp)
f01050e8:	ff 75 d8             	pushl  -0x28(%ebp)
f01050eb:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050ee:	ff 75 e0             	pushl  -0x20(%ebp)
f01050f1:	e8 da 14 00 00       	call   f01065d0 <__umoddi3>
f01050f6:	83 c4 14             	add    $0x14,%esp
f01050f9:	0f be 80 2a 7f 10 f0 	movsbl -0xfef80d6(%eax),%eax
f0105100:	50                   	push   %eax
f0105101:	ff d7                	call   *%edi
f0105103:	83 c4 10             	add    $0x10,%esp
f0105106:	e9 d5 fe ff ff       	jmp    f0104fe0 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010510b:	83 ec 0c             	sub    $0xc,%esp
f010510e:	ff 75 18             	pushl  0x18(%ebp)
f0105111:	83 eb 01             	sub    $0x1,%ebx
f0105114:	53                   	push   %ebx
f0105115:	ff 75 10             	pushl  0x10(%ebp)
f0105118:	83 ec 08             	sub    $0x8,%esp
f010511b:	ff 75 dc             	pushl  -0x24(%ebp)
f010511e:	ff 75 d8             	pushl  -0x28(%ebp)
f0105121:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105124:	ff 75 e0             	pushl  -0x20(%ebp)
f0105127:	e8 74 13 00 00       	call   f01064a0 <__udivdi3>
f010512c:	83 c4 18             	add    $0x18,%esp
f010512f:	52                   	push   %edx
f0105130:	50                   	push   %eax
f0105131:	89 f2                	mov    %esi,%edx
f0105133:	89 f8                	mov    %edi,%eax
f0105135:	e8 15 fe ff ff       	call   f0104f4f <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010513a:	83 c4 18             	add    $0x18,%esp
f010513d:	56                   	push   %esi
f010513e:	83 ec 04             	sub    $0x4,%esp
f0105141:	ff 75 dc             	pushl  -0x24(%ebp)
f0105144:	ff 75 d8             	pushl  -0x28(%ebp)
f0105147:	ff 75 e4             	pushl  -0x1c(%ebp)
f010514a:	ff 75 e0             	pushl  -0x20(%ebp)
f010514d:	e8 7e 14 00 00       	call   f01065d0 <__umoddi3>
f0105152:	83 c4 14             	add    $0x14,%esp
f0105155:	0f be 80 2a 7f 10 f0 	movsbl -0xfef80d6(%eax),%eax
f010515c:	50                   	push   %eax
f010515d:	ff d7                	call   *%edi
f010515f:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
f0105162:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105165:	5b                   	pop    %ebx
f0105166:	5e                   	pop    %esi
f0105167:	5f                   	pop    %edi
f0105168:	5d                   	pop    %ebp
f0105169:	c3                   	ret    

f010516a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010516a:	55                   	push   %ebp
f010516b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010516d:	83 fa 01             	cmp    $0x1,%edx
f0105170:	7e 0e                	jle    f0105180 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105172:	8b 10                	mov    (%eax),%edx
f0105174:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105177:	89 08                	mov    %ecx,(%eax)
f0105179:	8b 02                	mov    (%edx),%eax
f010517b:	8b 52 04             	mov    0x4(%edx),%edx
f010517e:	eb 22                	jmp    f01051a2 <getuint+0x38>
	else if (lflag)
f0105180:	85 d2                	test   %edx,%edx
f0105182:	74 10                	je     f0105194 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105184:	8b 10                	mov    (%eax),%edx
f0105186:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105189:	89 08                	mov    %ecx,(%eax)
f010518b:	8b 02                	mov    (%edx),%eax
f010518d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105192:	eb 0e                	jmp    f01051a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105194:	8b 10                	mov    (%eax),%edx
f0105196:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105199:	89 08                	mov    %ecx,(%eax)
f010519b:	8b 02                	mov    (%edx),%eax
f010519d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01051a2:	5d                   	pop    %ebp
f01051a3:	c3                   	ret    

f01051a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01051a4:	55                   	push   %ebp
f01051a5:	89 e5                	mov    %esp,%ebp
f01051a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01051aa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01051ae:	8b 10                	mov    (%eax),%edx
f01051b0:	3b 50 04             	cmp    0x4(%eax),%edx
f01051b3:	73 0a                	jae    f01051bf <sprintputch+0x1b>
		*b->buf++ = ch;
f01051b5:	8d 4a 01             	lea    0x1(%edx),%ecx
f01051b8:	89 08                	mov    %ecx,(%eax)
f01051ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01051bd:	88 02                	mov    %al,(%edx)
}
f01051bf:	5d                   	pop    %ebp
f01051c0:	c3                   	ret    

f01051c1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01051c1:	55                   	push   %ebp
f01051c2:	89 e5                	mov    %esp,%ebp
f01051c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01051c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01051ca:	50                   	push   %eax
f01051cb:	ff 75 10             	pushl  0x10(%ebp)
f01051ce:	ff 75 0c             	pushl  0xc(%ebp)
f01051d1:	ff 75 08             	pushl  0x8(%ebp)
f01051d4:	e8 05 00 00 00       	call   f01051de <vprintfmt>
	va_end(ap);
}
f01051d9:	83 c4 10             	add    $0x10,%esp
f01051dc:	c9                   	leave  
f01051dd:	c3                   	ret    

f01051de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01051de:	55                   	push   %ebp
f01051df:	89 e5                	mov    %esp,%ebp
f01051e1:	57                   	push   %edi
f01051e2:	56                   	push   %esi
f01051e3:	53                   	push   %ebx
f01051e4:	83 ec 2c             	sub    $0x2c,%esp
f01051e7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01051ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051ed:	eb 03                	jmp    f01051f2 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f01051ef:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01051f2:	8b 45 10             	mov    0x10(%ebp),%eax
f01051f5:	8d 70 01             	lea    0x1(%eax),%esi
f01051f8:	0f b6 00             	movzbl (%eax),%eax
f01051fb:	83 f8 25             	cmp    $0x25,%eax
f01051fe:	74 27                	je     f0105227 <vprintfmt+0x49>
			if (ch == '\0')
f0105200:	85 c0                	test   %eax,%eax
f0105202:	75 0d                	jne    f0105211 <vprintfmt+0x33>
f0105204:	e9 9d 04 00 00       	jmp    f01056a6 <vprintfmt+0x4c8>
f0105209:	85 c0                	test   %eax,%eax
f010520b:	0f 84 95 04 00 00    	je     f01056a6 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
f0105211:	83 ec 08             	sub    $0x8,%esp
f0105214:	53                   	push   %ebx
f0105215:	50                   	push   %eax
f0105216:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105218:	83 c6 01             	add    $0x1,%esi
f010521b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f010521f:	83 c4 10             	add    $0x10,%esp
f0105222:	83 f8 25             	cmp    $0x25,%eax
f0105225:	75 e2                	jne    f0105209 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105227:	b9 00 00 00 00       	mov    $0x0,%ecx
f010522c:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f0105230:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105237:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010523e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105245:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f010524c:	eb 08                	jmp    f0105256 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010524e:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
f0105251:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105256:	8d 46 01             	lea    0x1(%esi),%eax
f0105259:	89 45 10             	mov    %eax,0x10(%ebp)
f010525c:	0f b6 06             	movzbl (%esi),%eax
f010525f:	0f b6 d0             	movzbl %al,%edx
f0105262:	83 e8 23             	sub    $0x23,%eax
f0105265:	3c 55                	cmp    $0x55,%al
f0105267:	0f 87 fa 03 00 00    	ja     f0105667 <vprintfmt+0x489>
f010526d:	0f b6 c0             	movzbl %al,%eax
f0105270:	ff 24 85 60 80 10 f0 	jmp    *-0xfef7fa0(,%eax,4)
f0105277:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f010527a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f010527e:	eb d6                	jmp    f0105256 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105280:	8d 42 d0             	lea    -0x30(%edx),%eax
f0105283:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f0105286:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f010528a:	8d 50 d0             	lea    -0x30(%eax),%edx
f010528d:	83 fa 09             	cmp    $0x9,%edx
f0105290:	77 6b                	ja     f01052fd <vprintfmt+0x11f>
f0105292:	8b 75 10             	mov    0x10(%ebp),%esi
f0105295:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105298:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010529b:	eb 09                	jmp    f01052a6 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010529d:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01052a0:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f01052a4:	eb b0                	jmp    f0105256 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01052a6:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f01052a9:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01052ac:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01052b0:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01052b3:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01052b6:	83 f9 09             	cmp    $0x9,%ecx
f01052b9:	76 eb                	jbe    f01052a6 <vprintfmt+0xc8>
f01052bb:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01052be:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01052c1:	eb 3d                	jmp    f0105300 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01052c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c6:	8d 50 04             	lea    0x4(%eax),%edx
f01052c9:	89 55 14             	mov    %edx,0x14(%ebp)
f01052cc:	8b 00                	mov    (%eax),%eax
f01052ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052d1:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01052d4:	eb 2a                	jmp    f0105300 <vprintfmt+0x122>
f01052d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052d9:	85 c0                	test   %eax,%eax
f01052db:	ba 00 00 00 00       	mov    $0x0,%edx
f01052e0:	0f 49 d0             	cmovns %eax,%edx
f01052e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052e6:	8b 75 10             	mov    0x10(%ebp),%esi
f01052e9:	e9 68 ff ff ff       	jmp    f0105256 <vprintfmt+0x78>
f01052ee:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01052f1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01052f8:	e9 59 ff ff ff       	jmp    f0105256 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052fd:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0105300:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105304:	0f 89 4c ff ff ff    	jns    f0105256 <vprintfmt+0x78>
				width = precision, precision = -1;
f010530a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010530d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105310:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105317:	e9 3a ff ff ff       	jmp    f0105256 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010531c:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105320:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105323:	e9 2e ff ff ff       	jmp    f0105256 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105328:	8b 45 14             	mov    0x14(%ebp),%eax
f010532b:	8d 50 04             	lea    0x4(%eax),%edx
f010532e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105331:	83 ec 08             	sub    $0x8,%esp
f0105334:	53                   	push   %ebx
f0105335:	ff 30                	pushl  (%eax)
f0105337:	ff d7                	call   *%edi
			break;
f0105339:	83 c4 10             	add    $0x10,%esp
f010533c:	e9 b1 fe ff ff       	jmp    f01051f2 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105341:	8b 45 14             	mov    0x14(%ebp),%eax
f0105344:	8d 50 04             	lea    0x4(%eax),%edx
f0105347:	89 55 14             	mov    %edx,0x14(%ebp)
f010534a:	8b 00                	mov    (%eax),%eax
f010534c:	99                   	cltd   
f010534d:	31 d0                	xor    %edx,%eax
f010534f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105351:	83 f8 08             	cmp    $0x8,%eax
f0105354:	7f 0b                	jg     f0105361 <vprintfmt+0x183>
f0105356:	8b 14 85 c0 81 10 f0 	mov    -0xfef7e40(,%eax,4),%edx
f010535d:	85 d2                	test   %edx,%edx
f010535f:	75 15                	jne    f0105376 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
f0105361:	50                   	push   %eax
f0105362:	68 42 7f 10 f0       	push   $0xf0107f42
f0105367:	53                   	push   %ebx
f0105368:	57                   	push   %edi
f0105369:	e8 53 fe ff ff       	call   f01051c1 <printfmt>
f010536e:	83 c4 10             	add    $0x10,%esp
f0105371:	e9 7c fe ff ff       	jmp    f01051f2 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f0105376:	52                   	push   %edx
f0105377:	68 ad 75 10 f0       	push   $0xf01075ad
f010537c:	53                   	push   %ebx
f010537d:	57                   	push   %edi
f010537e:	e8 3e fe ff ff       	call   f01051c1 <printfmt>
f0105383:	83 c4 10             	add    $0x10,%esp
f0105386:	e9 67 fe ff ff       	jmp    f01051f2 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010538b:	8b 45 14             	mov    0x14(%ebp),%eax
f010538e:	8d 50 04             	lea    0x4(%eax),%edx
f0105391:	89 55 14             	mov    %edx,0x14(%ebp)
f0105394:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0105396:	85 c0                	test   %eax,%eax
f0105398:	b9 3b 7f 10 f0       	mov    $0xf0107f3b,%ecx
f010539d:	0f 45 c8             	cmovne %eax,%ecx
f01053a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f01053a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01053a7:	7e 06                	jle    f01053af <vprintfmt+0x1d1>
f01053a9:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f01053ad:	75 19                	jne    f01053c8 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01053af:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01053b2:	8d 70 01             	lea    0x1(%eax),%esi
f01053b5:	0f b6 00             	movzbl (%eax),%eax
f01053b8:	0f be d0             	movsbl %al,%edx
f01053bb:	85 d2                	test   %edx,%edx
f01053bd:	0f 85 9f 00 00 00    	jne    f0105462 <vprintfmt+0x284>
f01053c3:	e9 8c 00 00 00       	jmp    f0105454 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01053c8:	83 ec 08             	sub    $0x8,%esp
f01053cb:	ff 75 d0             	pushl  -0x30(%ebp)
f01053ce:	ff 75 cc             	pushl  -0x34(%ebp)
f01053d1:	e8 3b 04 00 00       	call   f0105811 <strnlen>
f01053d6:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f01053d9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053dc:	83 c4 10             	add    $0x10,%esp
f01053df:	85 c9                	test   %ecx,%ecx
f01053e1:	0f 8e a6 02 00 00    	jle    f010568d <vprintfmt+0x4af>
					putch(padc, putdat);
f01053e7:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f01053eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01053ee:	89 cb                	mov    %ecx,%ebx
f01053f0:	83 ec 08             	sub    $0x8,%esp
f01053f3:	ff 75 0c             	pushl  0xc(%ebp)
f01053f6:	56                   	push   %esi
f01053f7:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01053f9:	83 c4 10             	add    $0x10,%esp
f01053fc:	83 eb 01             	sub    $0x1,%ebx
f01053ff:	75 ef                	jne    f01053f0 <vprintfmt+0x212>
f0105401:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105404:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105407:	e9 81 02 00 00       	jmp    f010568d <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010540c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105410:	74 1b                	je     f010542d <vprintfmt+0x24f>
f0105412:	0f be c0             	movsbl %al,%eax
f0105415:	83 e8 20             	sub    $0x20,%eax
f0105418:	83 f8 5e             	cmp    $0x5e,%eax
f010541b:	76 10                	jbe    f010542d <vprintfmt+0x24f>
					putch('?', putdat);
f010541d:	83 ec 08             	sub    $0x8,%esp
f0105420:	ff 75 0c             	pushl  0xc(%ebp)
f0105423:	6a 3f                	push   $0x3f
f0105425:	ff 55 08             	call   *0x8(%ebp)
f0105428:	83 c4 10             	add    $0x10,%esp
f010542b:	eb 0d                	jmp    f010543a <vprintfmt+0x25c>
				else
					putch(ch, putdat);
f010542d:	83 ec 08             	sub    $0x8,%esp
f0105430:	ff 75 0c             	pushl  0xc(%ebp)
f0105433:	52                   	push   %edx
f0105434:	ff 55 08             	call   *0x8(%ebp)
f0105437:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010543a:	83 ef 01             	sub    $0x1,%edi
f010543d:	83 c6 01             	add    $0x1,%esi
f0105440:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0105444:	0f be d0             	movsbl %al,%edx
f0105447:	85 d2                	test   %edx,%edx
f0105449:	75 31                	jne    f010547c <vprintfmt+0x29e>
f010544b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010544e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105454:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105457:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010545b:	7f 33                	jg     f0105490 <vprintfmt+0x2b2>
f010545d:	e9 90 fd ff ff       	jmp    f01051f2 <vprintfmt+0x14>
f0105462:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105468:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010546b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010546e:	eb 0c                	jmp    f010547c <vprintfmt+0x29e>
f0105470:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105476:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105479:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010547c:	85 db                	test   %ebx,%ebx
f010547e:	78 8c                	js     f010540c <vprintfmt+0x22e>
f0105480:	83 eb 01             	sub    $0x1,%ebx
f0105483:	79 87                	jns    f010540c <vprintfmt+0x22e>
f0105485:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105488:	8b 7d 08             	mov    0x8(%ebp),%edi
f010548b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010548e:	eb c4                	jmp    f0105454 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105490:	83 ec 08             	sub    $0x8,%esp
f0105493:	53                   	push   %ebx
f0105494:	6a 20                	push   $0x20
f0105496:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105498:	83 c4 10             	add    $0x10,%esp
f010549b:	83 ee 01             	sub    $0x1,%esi
f010549e:	75 f0                	jne    f0105490 <vprintfmt+0x2b2>
f01054a0:	e9 4d fd ff ff       	jmp    f01051f2 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01054a5:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f01054a9:	7e 16                	jle    f01054c1 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
f01054ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01054ae:	8d 50 08             	lea    0x8(%eax),%edx
f01054b1:	89 55 14             	mov    %edx,0x14(%ebp)
f01054b4:	8b 50 04             	mov    0x4(%eax),%edx
f01054b7:	8b 00                	mov    (%eax),%eax
f01054b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01054bc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01054bf:	eb 34                	jmp    f01054f5 <vprintfmt+0x317>
	else if (lflag)
f01054c1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01054c5:	74 18                	je     f01054df <vprintfmt+0x301>
		return va_arg(*ap, long);
f01054c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01054ca:	8d 50 04             	lea    0x4(%eax),%edx
f01054cd:	89 55 14             	mov    %edx,0x14(%ebp)
f01054d0:	8b 30                	mov    (%eax),%esi
f01054d2:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01054d5:	89 f0                	mov    %esi,%eax
f01054d7:	c1 f8 1f             	sar    $0x1f,%eax
f01054da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01054dd:	eb 16                	jmp    f01054f5 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
f01054df:	8b 45 14             	mov    0x14(%ebp),%eax
f01054e2:	8d 50 04             	lea    0x4(%eax),%edx
f01054e5:	89 55 14             	mov    %edx,0x14(%ebp)
f01054e8:	8b 30                	mov    (%eax),%esi
f01054ea:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01054ed:	89 f0                	mov    %esi,%eax
f01054ef:	c1 f8 1f             	sar    $0x1f,%eax
f01054f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01054f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01054f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01054fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0105501:	85 d2                	test   %edx,%edx
f0105503:	79 28                	jns    f010552d <vprintfmt+0x34f>
				putch('-', putdat);
f0105505:	83 ec 08             	sub    $0x8,%esp
f0105508:	53                   	push   %ebx
f0105509:	6a 2d                	push   $0x2d
f010550b:	ff d7                	call   *%edi
				num = -(long long) num;
f010550d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105510:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105513:	f7 d8                	neg    %eax
f0105515:	83 d2 00             	adc    $0x0,%edx
f0105518:	f7 da                	neg    %edx
f010551a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010551d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105520:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
f0105523:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105528:	e9 b2 00 00 00       	jmp    f01055df <vprintfmt+0x401>
f010552d:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
f0105532:	85 c9                	test   %ecx,%ecx
f0105534:	0f 84 a5 00 00 00    	je     f01055df <vprintfmt+0x401>
				putch('+', putdat);
f010553a:	83 ec 08             	sub    $0x8,%esp
f010553d:	53                   	push   %ebx
f010553e:	6a 2b                	push   $0x2b
f0105540:	ff d7                	call   *%edi
f0105542:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
f0105545:	b8 0a 00 00 00       	mov    $0xa,%eax
f010554a:	e9 90 00 00 00       	jmp    f01055df <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
f010554f:	85 c9                	test   %ecx,%ecx
f0105551:	74 0b                	je     f010555e <vprintfmt+0x380>
				putch('+', putdat);
f0105553:	83 ec 08             	sub    $0x8,%esp
f0105556:	53                   	push   %ebx
f0105557:	6a 2b                	push   $0x2b
f0105559:	ff d7                	call   *%edi
f010555b:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
f010555e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105561:	8d 45 14             	lea    0x14(%ebp),%eax
f0105564:	e8 01 fc ff ff       	call   f010516a <getuint>
f0105569:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010556c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f010556f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105574:	eb 69                	jmp    f01055df <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
f0105576:	83 ec 08             	sub    $0x8,%esp
f0105579:	53                   	push   %ebx
f010557a:	6a 30                	push   $0x30
f010557c:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f010557e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105581:	8d 45 14             	lea    0x14(%ebp),%eax
f0105584:	e8 e1 fb ff ff       	call   f010516a <getuint>
f0105589:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010558c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f010558f:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0105592:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105597:	eb 46                	jmp    f01055df <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105599:	83 ec 08             	sub    $0x8,%esp
f010559c:	53                   	push   %ebx
f010559d:	6a 30                	push   $0x30
f010559f:	ff d7                	call   *%edi
			putch('x', putdat);
f01055a1:	83 c4 08             	add    $0x8,%esp
f01055a4:	53                   	push   %ebx
f01055a5:	6a 78                	push   $0x78
f01055a7:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01055a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01055ac:	8d 50 04             	lea    0x4(%eax),%edx
f01055af:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01055b2:	8b 00                	mov    (%eax),%eax
f01055b4:	ba 00 00 00 00       	mov    $0x0,%edx
f01055b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01055bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01055bf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01055c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01055c7:	eb 16                	jmp    f01055df <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01055c9:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01055cc:	8d 45 14             	lea    0x14(%ebp),%eax
f01055cf:	e8 96 fb ff ff       	call   f010516a <getuint>
f01055d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01055d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f01055da:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01055df:	83 ec 0c             	sub    $0xc,%esp
f01055e2:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f01055e6:	56                   	push   %esi
f01055e7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01055ea:	50                   	push   %eax
f01055eb:	ff 75 dc             	pushl  -0x24(%ebp)
f01055ee:	ff 75 d8             	pushl  -0x28(%ebp)
f01055f1:	89 da                	mov    %ebx,%edx
f01055f3:	89 f8                	mov    %edi,%eax
f01055f5:	e8 55 f9 ff ff       	call   f0104f4f <printnum>
			break;
f01055fa:	83 c4 20             	add    $0x20,%esp
f01055fd:	e9 f0 fb ff ff       	jmp    f01051f2 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
f0105602:	8b 45 14             	mov    0x14(%ebp),%eax
f0105605:	8d 50 04             	lea    0x4(%eax),%edx
f0105608:	89 55 14             	mov    %edx,0x14(%ebp)
f010560b:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
f010560d:	85 f6                	test   %esi,%esi
f010560f:	75 1a                	jne    f010562b <vprintfmt+0x44d>
						cprintf("%s", null_error);
f0105611:	83 ec 08             	sub    $0x8,%esp
f0105614:	68 e0 7f 10 f0       	push   $0xf0107fe0
f0105619:	68 ad 75 10 f0       	push   $0xf01075ad
f010561e:	e8 71 e8 ff ff       	call   f0103e94 <cprintf>
f0105623:	83 c4 10             	add    $0x10,%esp
f0105626:	e9 c7 fb ff ff       	jmp    f01051f2 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
f010562b:	0f b6 03             	movzbl (%ebx),%eax
f010562e:	84 c0                	test   %al,%al
f0105630:	79 1f                	jns    f0105651 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
f0105632:	83 ec 08             	sub    $0x8,%esp
f0105635:	68 18 80 10 f0       	push   $0xf0108018
f010563a:	68 ad 75 10 f0       	push   $0xf01075ad
f010563f:	e8 50 e8 ff ff       	call   f0103e94 <cprintf>
						*tmp = *(char *)putdat;
f0105644:	0f b6 03             	movzbl (%ebx),%eax
f0105647:	88 06                	mov    %al,(%esi)
f0105649:	83 c4 10             	add    $0x10,%esp
f010564c:	e9 a1 fb ff ff       	jmp    f01051f2 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
f0105651:	88 06                	mov    %al,(%esi)
f0105653:	e9 9a fb ff ff       	jmp    f01051f2 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105658:	83 ec 08             	sub    $0x8,%esp
f010565b:	53                   	push   %ebx
f010565c:	52                   	push   %edx
f010565d:	ff d7                	call   *%edi
			break;
f010565f:	83 c4 10             	add    $0x10,%esp
f0105662:	e9 8b fb ff ff       	jmp    f01051f2 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105667:	83 ec 08             	sub    $0x8,%esp
f010566a:	53                   	push   %ebx
f010566b:	6a 25                	push   $0x25
f010566d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010566f:	83 c4 10             	add    $0x10,%esp
f0105672:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105676:	0f 84 73 fb ff ff    	je     f01051ef <vprintfmt+0x11>
f010567c:	83 ee 01             	sub    $0x1,%esi
f010567f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105683:	75 f7                	jne    f010567c <vprintfmt+0x49e>
f0105685:	89 75 10             	mov    %esi,0x10(%ebp)
f0105688:	e9 65 fb ff ff       	jmp    f01051f2 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010568d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105690:	8d 70 01             	lea    0x1(%eax),%esi
f0105693:	0f b6 00             	movzbl (%eax),%eax
f0105696:	0f be d0             	movsbl %al,%edx
f0105699:	85 d2                	test   %edx,%edx
f010569b:	0f 85 cf fd ff ff    	jne    f0105470 <vprintfmt+0x292>
f01056a1:	e9 4c fb ff ff       	jmp    f01051f2 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01056a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01056a9:	5b                   	pop    %ebx
f01056aa:	5e                   	pop    %esi
f01056ab:	5f                   	pop    %edi
f01056ac:	5d                   	pop    %ebp
f01056ad:	c3                   	ret    

f01056ae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01056ae:	55                   	push   %ebp
f01056af:	89 e5                	mov    %esp,%ebp
f01056b1:	83 ec 18             	sub    $0x18,%esp
f01056b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01056b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01056ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01056bd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01056c1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01056c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01056cb:	85 c0                	test   %eax,%eax
f01056cd:	74 26                	je     f01056f5 <vsnprintf+0x47>
f01056cf:	85 d2                	test   %edx,%edx
f01056d1:	7e 22                	jle    f01056f5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01056d3:	ff 75 14             	pushl  0x14(%ebp)
f01056d6:	ff 75 10             	pushl  0x10(%ebp)
f01056d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01056dc:	50                   	push   %eax
f01056dd:	68 a4 51 10 f0       	push   $0xf01051a4
f01056e2:	e8 f7 fa ff ff       	call   f01051de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01056e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01056ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01056ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01056f0:	83 c4 10             	add    $0x10,%esp
f01056f3:	eb 05                	jmp    f01056fa <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01056f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01056fa:	c9                   	leave  
f01056fb:	c3                   	ret    

f01056fc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01056fc:	55                   	push   %ebp
f01056fd:	89 e5                	mov    %esp,%ebp
f01056ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105702:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105705:	50                   	push   %eax
f0105706:	ff 75 10             	pushl  0x10(%ebp)
f0105709:	ff 75 0c             	pushl  0xc(%ebp)
f010570c:	ff 75 08             	pushl  0x8(%ebp)
f010570f:	e8 9a ff ff ff       	call   f01056ae <vsnprintf>
	va_end(ap);

	return rc;
}
f0105714:	c9                   	leave  
f0105715:	c3                   	ret    

f0105716 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105716:	55                   	push   %ebp
f0105717:	89 e5                	mov    %esp,%ebp
f0105719:	57                   	push   %edi
f010571a:	56                   	push   %esi
f010571b:	53                   	push   %ebx
f010571c:	83 ec 0c             	sub    $0xc,%esp
f010571f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105722:	85 c0                	test   %eax,%eax
f0105724:	74 11                	je     f0105737 <readline+0x21>
		cprintf("%s", prompt);
f0105726:	83 ec 08             	sub    $0x8,%esp
f0105729:	50                   	push   %eax
f010572a:	68 ad 75 10 f0       	push   $0xf01075ad
f010572f:	e8 60 e7 ff ff       	call   f0103e94 <cprintf>
f0105734:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105737:	83 ec 0c             	sub    $0xc,%esp
f010573a:	6a 00                	push   $0x0
f010573c:	e8 bd b1 ff ff       	call   f01008fe <iscons>
f0105741:	89 c7                	mov    %eax,%edi
f0105743:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105746:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010574b:	e8 9d b1 ff ff       	call   f01008ed <getchar>
f0105750:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105752:	85 c0                	test   %eax,%eax
f0105754:	79 18                	jns    f010576e <readline+0x58>
			cprintf("read error: %e\n", c);
f0105756:	83 ec 08             	sub    $0x8,%esp
f0105759:	50                   	push   %eax
f010575a:	68 e4 81 10 f0       	push   $0xf01081e4
f010575f:	e8 30 e7 ff ff       	call   f0103e94 <cprintf>
			return NULL;
f0105764:	83 c4 10             	add    $0x10,%esp
f0105767:	b8 00 00 00 00       	mov    $0x0,%eax
f010576c:	eb 79                	jmp    f01057e7 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010576e:	83 f8 08             	cmp    $0x8,%eax
f0105771:	0f 94 c2             	sete   %dl
f0105774:	83 f8 7f             	cmp    $0x7f,%eax
f0105777:	0f 94 c0             	sete   %al
f010577a:	08 c2                	or     %al,%dl
f010577c:	74 1a                	je     f0105798 <readline+0x82>
f010577e:	85 f6                	test   %esi,%esi
f0105780:	7e 16                	jle    f0105798 <readline+0x82>
			if (echoing)
f0105782:	85 ff                	test   %edi,%edi
f0105784:	74 0d                	je     f0105793 <readline+0x7d>
				cputchar('\b');
f0105786:	83 ec 0c             	sub    $0xc,%esp
f0105789:	6a 08                	push   $0x8
f010578b:	e8 4d b1 ff ff       	call   f01008dd <cputchar>
f0105790:	83 c4 10             	add    $0x10,%esp
			i--;
f0105793:	83 ee 01             	sub    $0x1,%esi
f0105796:	eb b3                	jmp    f010574b <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105798:	83 fb 1f             	cmp    $0x1f,%ebx
f010579b:	7e 23                	jle    f01057c0 <readline+0xaa>
f010579d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01057a3:	7f 1b                	jg     f01057c0 <readline+0xaa>
			if (echoing)
f01057a5:	85 ff                	test   %edi,%edi
f01057a7:	74 0c                	je     f01057b5 <readline+0x9f>
				cputchar(c);
f01057a9:	83 ec 0c             	sub    $0xc,%esp
f01057ac:	53                   	push   %ebx
f01057ad:	e8 2b b1 ff ff       	call   f01008dd <cputchar>
f01057b2:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01057b5:	88 9e a0 8a 23 f0    	mov    %bl,-0xfdc7560(%esi)
f01057bb:	8d 76 01             	lea    0x1(%esi),%esi
f01057be:	eb 8b                	jmp    f010574b <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01057c0:	83 fb 0a             	cmp    $0xa,%ebx
f01057c3:	74 05                	je     f01057ca <readline+0xb4>
f01057c5:	83 fb 0d             	cmp    $0xd,%ebx
f01057c8:	75 81                	jne    f010574b <readline+0x35>
			if (echoing)
f01057ca:	85 ff                	test   %edi,%edi
f01057cc:	74 0d                	je     f01057db <readline+0xc5>
				cputchar('\n');
f01057ce:	83 ec 0c             	sub    $0xc,%esp
f01057d1:	6a 0a                	push   $0xa
f01057d3:	e8 05 b1 ff ff       	call   f01008dd <cputchar>
f01057d8:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01057db:	c6 86 a0 8a 23 f0 00 	movb   $0x0,-0xfdc7560(%esi)
			return buf;
f01057e2:	b8 a0 8a 23 f0       	mov    $0xf0238aa0,%eax
		}
	}
}
f01057e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057ea:	5b                   	pop    %ebx
f01057eb:	5e                   	pop    %esi
f01057ec:	5f                   	pop    %edi
f01057ed:	5d                   	pop    %ebp
f01057ee:	c3                   	ret    

f01057ef <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01057ef:	55                   	push   %ebp
f01057f0:	89 e5                	mov    %esp,%ebp
f01057f2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01057f5:	80 3a 00             	cmpb   $0x0,(%edx)
f01057f8:	74 10                	je     f010580a <strlen+0x1b>
f01057fa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01057ff:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105802:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105806:	75 f7                	jne    f01057ff <strlen+0x10>
f0105808:	eb 05                	jmp    f010580f <strlen+0x20>
f010580a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010580f:	5d                   	pop    %ebp
f0105810:	c3                   	ret    

f0105811 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105811:	55                   	push   %ebp
f0105812:	89 e5                	mov    %esp,%ebp
f0105814:	53                   	push   %ebx
f0105815:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010581b:	85 c9                	test   %ecx,%ecx
f010581d:	74 1c                	je     f010583b <strnlen+0x2a>
f010581f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0105822:	74 1e                	je     f0105842 <strnlen+0x31>
f0105824:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0105829:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010582b:	39 ca                	cmp    %ecx,%edx
f010582d:	74 18                	je     f0105847 <strnlen+0x36>
f010582f:	83 c2 01             	add    $0x1,%edx
f0105832:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0105837:	75 f0                	jne    f0105829 <strnlen+0x18>
f0105839:	eb 0c                	jmp    f0105847 <strnlen+0x36>
f010583b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105840:	eb 05                	jmp    f0105847 <strnlen+0x36>
f0105842:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105847:	5b                   	pop    %ebx
f0105848:	5d                   	pop    %ebp
f0105849:	c3                   	ret    

f010584a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010584a:	55                   	push   %ebp
f010584b:	89 e5                	mov    %esp,%ebp
f010584d:	53                   	push   %ebx
f010584e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105854:	89 c2                	mov    %eax,%edx
f0105856:	83 c2 01             	add    $0x1,%edx
f0105859:	83 c1 01             	add    $0x1,%ecx
f010585c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105860:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105863:	84 db                	test   %bl,%bl
f0105865:	75 ef                	jne    f0105856 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105867:	5b                   	pop    %ebx
f0105868:	5d                   	pop    %ebp
f0105869:	c3                   	ret    

f010586a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010586a:	55                   	push   %ebp
f010586b:	89 e5                	mov    %esp,%ebp
f010586d:	53                   	push   %ebx
f010586e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105871:	53                   	push   %ebx
f0105872:	e8 78 ff ff ff       	call   f01057ef <strlen>
f0105877:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010587a:	ff 75 0c             	pushl  0xc(%ebp)
f010587d:	01 d8                	add    %ebx,%eax
f010587f:	50                   	push   %eax
f0105880:	e8 c5 ff ff ff       	call   f010584a <strcpy>
	return dst;
}
f0105885:	89 d8                	mov    %ebx,%eax
f0105887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010588a:	c9                   	leave  
f010588b:	c3                   	ret    

f010588c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010588c:	55                   	push   %ebp
f010588d:	89 e5                	mov    %esp,%ebp
f010588f:	56                   	push   %esi
f0105890:	53                   	push   %ebx
f0105891:	8b 75 08             	mov    0x8(%ebp),%esi
f0105894:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105897:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010589a:	85 db                	test   %ebx,%ebx
f010589c:	74 17                	je     f01058b5 <strncpy+0x29>
f010589e:	01 f3                	add    %esi,%ebx
f01058a0:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f01058a2:	83 c1 01             	add    $0x1,%ecx
f01058a5:	0f b6 02             	movzbl (%edx),%eax
f01058a8:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01058ab:	80 3a 01             	cmpb   $0x1,(%edx)
f01058ae:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01058b1:	39 cb                	cmp    %ecx,%ebx
f01058b3:	75 ed                	jne    f01058a2 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01058b5:	89 f0                	mov    %esi,%eax
f01058b7:	5b                   	pop    %ebx
f01058b8:	5e                   	pop    %esi
f01058b9:	5d                   	pop    %ebp
f01058ba:	c3                   	ret    

f01058bb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01058bb:	55                   	push   %ebp
f01058bc:	89 e5                	mov    %esp,%ebp
f01058be:	56                   	push   %esi
f01058bf:	53                   	push   %ebx
f01058c0:	8b 75 08             	mov    0x8(%ebp),%esi
f01058c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058c6:	8b 55 10             	mov    0x10(%ebp),%edx
f01058c9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01058cb:	85 d2                	test   %edx,%edx
f01058cd:	74 35                	je     f0105904 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f01058cf:	89 d0                	mov    %edx,%eax
f01058d1:	83 e8 01             	sub    $0x1,%eax
f01058d4:	74 25                	je     f01058fb <strlcpy+0x40>
f01058d6:	0f b6 0b             	movzbl (%ebx),%ecx
f01058d9:	84 c9                	test   %cl,%cl
f01058db:	74 22                	je     f01058ff <strlcpy+0x44>
f01058dd:	8d 53 01             	lea    0x1(%ebx),%edx
f01058e0:	01 c3                	add    %eax,%ebx
f01058e2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f01058e4:	83 c0 01             	add    $0x1,%eax
f01058e7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01058ea:	39 da                	cmp    %ebx,%edx
f01058ec:	74 13                	je     f0105901 <strlcpy+0x46>
f01058ee:	83 c2 01             	add    $0x1,%edx
f01058f1:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f01058f5:	84 c9                	test   %cl,%cl
f01058f7:	75 eb                	jne    f01058e4 <strlcpy+0x29>
f01058f9:	eb 06                	jmp    f0105901 <strlcpy+0x46>
f01058fb:	89 f0                	mov    %esi,%eax
f01058fd:	eb 02                	jmp    f0105901 <strlcpy+0x46>
f01058ff:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105901:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105904:	29 f0                	sub    %esi,%eax
}
f0105906:	5b                   	pop    %ebx
f0105907:	5e                   	pop    %esi
f0105908:	5d                   	pop    %ebp
f0105909:	c3                   	ret    

f010590a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010590a:	55                   	push   %ebp
f010590b:	89 e5                	mov    %esp,%ebp
f010590d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105910:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105913:	0f b6 01             	movzbl (%ecx),%eax
f0105916:	84 c0                	test   %al,%al
f0105918:	74 15                	je     f010592f <strcmp+0x25>
f010591a:	3a 02                	cmp    (%edx),%al
f010591c:	75 11                	jne    f010592f <strcmp+0x25>
		p++, q++;
f010591e:	83 c1 01             	add    $0x1,%ecx
f0105921:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105924:	0f b6 01             	movzbl (%ecx),%eax
f0105927:	84 c0                	test   %al,%al
f0105929:	74 04                	je     f010592f <strcmp+0x25>
f010592b:	3a 02                	cmp    (%edx),%al
f010592d:	74 ef                	je     f010591e <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010592f:	0f b6 c0             	movzbl %al,%eax
f0105932:	0f b6 12             	movzbl (%edx),%edx
f0105935:	29 d0                	sub    %edx,%eax
}
f0105937:	5d                   	pop    %ebp
f0105938:	c3                   	ret    

f0105939 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105939:	55                   	push   %ebp
f010593a:	89 e5                	mov    %esp,%ebp
f010593c:	56                   	push   %esi
f010593d:	53                   	push   %ebx
f010593e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105941:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105944:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f0105947:	85 f6                	test   %esi,%esi
f0105949:	74 29                	je     f0105974 <strncmp+0x3b>
f010594b:	0f b6 03             	movzbl (%ebx),%eax
f010594e:	84 c0                	test   %al,%al
f0105950:	74 30                	je     f0105982 <strncmp+0x49>
f0105952:	3a 02                	cmp    (%edx),%al
f0105954:	75 2c                	jne    f0105982 <strncmp+0x49>
f0105956:	8d 43 01             	lea    0x1(%ebx),%eax
f0105959:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f010595b:	89 c3                	mov    %eax,%ebx
f010595d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105960:	39 c6                	cmp    %eax,%esi
f0105962:	74 17                	je     f010597b <strncmp+0x42>
f0105964:	0f b6 08             	movzbl (%eax),%ecx
f0105967:	84 c9                	test   %cl,%cl
f0105969:	74 17                	je     f0105982 <strncmp+0x49>
f010596b:	83 c0 01             	add    $0x1,%eax
f010596e:	3a 0a                	cmp    (%edx),%cl
f0105970:	74 e9                	je     f010595b <strncmp+0x22>
f0105972:	eb 0e                	jmp    f0105982 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105974:	b8 00 00 00 00       	mov    $0x0,%eax
f0105979:	eb 0f                	jmp    f010598a <strncmp+0x51>
f010597b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105980:	eb 08                	jmp    f010598a <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105982:	0f b6 03             	movzbl (%ebx),%eax
f0105985:	0f b6 12             	movzbl (%edx),%edx
f0105988:	29 d0                	sub    %edx,%eax
}
f010598a:	5b                   	pop    %ebx
f010598b:	5e                   	pop    %esi
f010598c:	5d                   	pop    %ebp
f010598d:	c3                   	ret    

f010598e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010598e:	55                   	push   %ebp
f010598f:	89 e5                	mov    %esp,%ebp
f0105991:	53                   	push   %ebx
f0105992:	8b 45 08             	mov    0x8(%ebp),%eax
f0105995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0105998:	0f b6 10             	movzbl (%eax),%edx
f010599b:	84 d2                	test   %dl,%dl
f010599d:	74 1d                	je     f01059bc <strchr+0x2e>
f010599f:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f01059a1:	38 d3                	cmp    %dl,%bl
f01059a3:	75 06                	jne    f01059ab <strchr+0x1d>
f01059a5:	eb 1a                	jmp    f01059c1 <strchr+0x33>
f01059a7:	38 ca                	cmp    %cl,%dl
f01059a9:	74 16                	je     f01059c1 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01059ab:	83 c0 01             	add    $0x1,%eax
f01059ae:	0f b6 10             	movzbl (%eax),%edx
f01059b1:	84 d2                	test   %dl,%dl
f01059b3:	75 f2                	jne    f01059a7 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f01059b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01059ba:	eb 05                	jmp    f01059c1 <strchr+0x33>
f01059bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01059c1:	5b                   	pop    %ebx
f01059c2:	5d                   	pop    %ebp
f01059c3:	c3                   	ret    

f01059c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01059c4:	55                   	push   %ebp
f01059c5:	89 e5                	mov    %esp,%ebp
f01059c7:	53                   	push   %ebx
f01059c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01059cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f01059ce:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f01059d1:	38 d3                	cmp    %dl,%bl
f01059d3:	74 14                	je     f01059e9 <strfind+0x25>
f01059d5:	89 d1                	mov    %edx,%ecx
f01059d7:	84 db                	test   %bl,%bl
f01059d9:	74 0e                	je     f01059e9 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01059db:	83 c0 01             	add    $0x1,%eax
f01059de:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01059e1:	38 ca                	cmp    %cl,%dl
f01059e3:	74 04                	je     f01059e9 <strfind+0x25>
f01059e5:	84 d2                	test   %dl,%dl
f01059e7:	75 f2                	jne    f01059db <strfind+0x17>
			break;
	return (char *) s;
}
f01059e9:	5b                   	pop    %ebx
f01059ea:	5d                   	pop    %ebp
f01059eb:	c3                   	ret    

f01059ec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01059ec:	55                   	push   %ebp
f01059ed:	89 e5                	mov    %esp,%ebp
f01059ef:	57                   	push   %edi
f01059f0:	56                   	push   %esi
f01059f1:	53                   	push   %ebx
f01059f2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01059f8:	85 c9                	test   %ecx,%ecx
f01059fa:	74 36                	je     f0105a32 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01059fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105a02:	75 28                	jne    f0105a2c <memset+0x40>
f0105a04:	f6 c1 03             	test   $0x3,%cl
f0105a07:	75 23                	jne    f0105a2c <memset+0x40>
		c &= 0xFF;
f0105a09:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105a0d:	89 d3                	mov    %edx,%ebx
f0105a0f:	c1 e3 08             	shl    $0x8,%ebx
f0105a12:	89 d6                	mov    %edx,%esi
f0105a14:	c1 e6 18             	shl    $0x18,%esi
f0105a17:	89 d0                	mov    %edx,%eax
f0105a19:	c1 e0 10             	shl    $0x10,%eax
f0105a1c:	09 f0                	or     %esi,%eax
f0105a1e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105a20:	89 d8                	mov    %ebx,%eax
f0105a22:	09 d0                	or     %edx,%eax
f0105a24:	c1 e9 02             	shr    $0x2,%ecx
f0105a27:	fc                   	cld    
f0105a28:	f3 ab                	rep stos %eax,%es:(%edi)
f0105a2a:	eb 06                	jmp    f0105a32 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a2f:	fc                   	cld    
f0105a30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105a32:	89 f8                	mov    %edi,%eax
f0105a34:	5b                   	pop    %ebx
f0105a35:	5e                   	pop    %esi
f0105a36:	5f                   	pop    %edi
f0105a37:	5d                   	pop    %ebp
f0105a38:	c3                   	ret    

f0105a39 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105a39:	55                   	push   %ebp
f0105a3a:	89 e5                	mov    %esp,%ebp
f0105a3c:	57                   	push   %edi
f0105a3d:	56                   	push   %esi
f0105a3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a41:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105a47:	39 c6                	cmp    %eax,%esi
f0105a49:	73 35                	jae    f0105a80 <memmove+0x47>
f0105a4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105a4e:	39 d0                	cmp    %edx,%eax
f0105a50:	73 2e                	jae    f0105a80 <memmove+0x47>
		s += n;
		d += n;
f0105a52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105a55:	89 d6                	mov    %edx,%esi
f0105a57:	09 fe                	or     %edi,%esi
f0105a59:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105a5f:	75 13                	jne    f0105a74 <memmove+0x3b>
f0105a61:	f6 c1 03             	test   $0x3,%cl
f0105a64:	75 0e                	jne    f0105a74 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105a66:	83 ef 04             	sub    $0x4,%edi
f0105a69:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105a6c:	c1 e9 02             	shr    $0x2,%ecx
f0105a6f:	fd                   	std    
f0105a70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105a72:	eb 09                	jmp    f0105a7d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105a74:	83 ef 01             	sub    $0x1,%edi
f0105a77:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105a7a:	fd                   	std    
f0105a7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105a7d:	fc                   	cld    
f0105a7e:	eb 1d                	jmp    f0105a9d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105a80:	89 f2                	mov    %esi,%edx
f0105a82:	09 c2                	or     %eax,%edx
f0105a84:	f6 c2 03             	test   $0x3,%dl
f0105a87:	75 0f                	jne    f0105a98 <memmove+0x5f>
f0105a89:	f6 c1 03             	test   $0x3,%cl
f0105a8c:	75 0a                	jne    f0105a98 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105a8e:	c1 e9 02             	shr    $0x2,%ecx
f0105a91:	89 c7                	mov    %eax,%edi
f0105a93:	fc                   	cld    
f0105a94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105a96:	eb 05                	jmp    f0105a9d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105a98:	89 c7                	mov    %eax,%edi
f0105a9a:	fc                   	cld    
f0105a9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105a9d:	5e                   	pop    %esi
f0105a9e:	5f                   	pop    %edi
f0105a9f:	5d                   	pop    %ebp
f0105aa0:	c3                   	ret    

f0105aa1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0105aa1:	55                   	push   %ebp
f0105aa2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105aa4:	ff 75 10             	pushl  0x10(%ebp)
f0105aa7:	ff 75 0c             	pushl  0xc(%ebp)
f0105aaa:	ff 75 08             	pushl  0x8(%ebp)
f0105aad:	e8 87 ff ff ff       	call   f0105a39 <memmove>
}
f0105ab2:	c9                   	leave  
f0105ab3:	c3                   	ret    

f0105ab4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105ab4:	55                   	push   %ebp
f0105ab5:	89 e5                	mov    %esp,%ebp
f0105ab7:	57                   	push   %edi
f0105ab8:	56                   	push   %esi
f0105ab9:	53                   	push   %ebx
f0105aba:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105abd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ac0:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ac3:	85 c0                	test   %eax,%eax
f0105ac5:	74 39                	je     f0105b00 <memcmp+0x4c>
f0105ac7:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f0105aca:	0f b6 13             	movzbl (%ebx),%edx
f0105acd:	0f b6 0e             	movzbl (%esi),%ecx
f0105ad0:	38 ca                	cmp    %cl,%dl
f0105ad2:	75 17                	jne    f0105aeb <memcmp+0x37>
f0105ad4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ad9:	eb 1a                	jmp    f0105af5 <memcmp+0x41>
f0105adb:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f0105ae0:	83 c0 01             	add    $0x1,%eax
f0105ae3:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f0105ae7:	38 ca                	cmp    %cl,%dl
f0105ae9:	74 0a                	je     f0105af5 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0105aeb:	0f b6 c2             	movzbl %dl,%eax
f0105aee:	0f b6 c9             	movzbl %cl,%ecx
f0105af1:	29 c8                	sub    %ecx,%eax
f0105af3:	eb 10                	jmp    f0105b05 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105af5:	39 f8                	cmp    %edi,%eax
f0105af7:	75 e2                	jne    f0105adb <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105af9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105afe:	eb 05                	jmp    f0105b05 <memcmp+0x51>
f0105b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b05:	5b                   	pop    %ebx
f0105b06:	5e                   	pop    %esi
f0105b07:	5f                   	pop    %edi
f0105b08:	5d                   	pop    %ebp
f0105b09:	c3                   	ret    

f0105b0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105b0a:	55                   	push   %ebp
f0105b0b:	89 e5                	mov    %esp,%ebp
f0105b0d:	53                   	push   %ebx
f0105b0e:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f0105b11:	89 d0                	mov    %edx,%eax
f0105b13:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f0105b16:	39 c2                	cmp    %eax,%edx
f0105b18:	73 1d                	jae    f0105b37 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105b1a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f0105b1e:	0f b6 0a             	movzbl (%edx),%ecx
f0105b21:	39 d9                	cmp    %ebx,%ecx
f0105b23:	75 09                	jne    f0105b2e <memfind+0x24>
f0105b25:	eb 14                	jmp    f0105b3b <memfind+0x31>
f0105b27:	0f b6 0a             	movzbl (%edx),%ecx
f0105b2a:	39 d9                	cmp    %ebx,%ecx
f0105b2c:	74 11                	je     f0105b3f <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105b2e:	83 c2 01             	add    $0x1,%edx
f0105b31:	39 d0                	cmp    %edx,%eax
f0105b33:	75 f2                	jne    f0105b27 <memfind+0x1d>
f0105b35:	eb 0a                	jmp    f0105b41 <memfind+0x37>
f0105b37:	89 d0                	mov    %edx,%eax
f0105b39:	eb 06                	jmp    f0105b41 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105b3b:	89 d0                	mov    %edx,%eax
f0105b3d:	eb 02                	jmp    f0105b41 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105b3f:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105b41:	5b                   	pop    %ebx
f0105b42:	5d                   	pop    %ebp
f0105b43:	c3                   	ret    

f0105b44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105b44:	55                   	push   %ebp
f0105b45:	89 e5                	mov    %esp,%ebp
f0105b47:	57                   	push   %edi
f0105b48:	56                   	push   %esi
f0105b49:	53                   	push   %ebx
f0105b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105b50:	0f b6 01             	movzbl (%ecx),%eax
f0105b53:	3c 20                	cmp    $0x20,%al
f0105b55:	74 04                	je     f0105b5b <strtol+0x17>
f0105b57:	3c 09                	cmp    $0x9,%al
f0105b59:	75 0e                	jne    f0105b69 <strtol+0x25>
		s++;
f0105b5b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105b5e:	0f b6 01             	movzbl (%ecx),%eax
f0105b61:	3c 20                	cmp    $0x20,%al
f0105b63:	74 f6                	je     f0105b5b <strtol+0x17>
f0105b65:	3c 09                	cmp    $0x9,%al
f0105b67:	74 f2                	je     f0105b5b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105b69:	3c 2b                	cmp    $0x2b,%al
f0105b6b:	75 0a                	jne    f0105b77 <strtol+0x33>
		s++;
f0105b6d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105b70:	bf 00 00 00 00       	mov    $0x0,%edi
f0105b75:	eb 11                	jmp    f0105b88 <strtol+0x44>
f0105b77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105b7c:	3c 2d                	cmp    $0x2d,%al
f0105b7e:	75 08                	jne    f0105b88 <strtol+0x44>
		s++, neg = 1;
f0105b80:	83 c1 01             	add    $0x1,%ecx
f0105b83:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105b88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105b8e:	75 15                	jne    f0105ba5 <strtol+0x61>
f0105b90:	80 39 30             	cmpb   $0x30,(%ecx)
f0105b93:	75 10                	jne    f0105ba5 <strtol+0x61>
f0105b95:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105b99:	75 7c                	jne    f0105c17 <strtol+0xd3>
		s += 2, base = 16;
f0105b9b:	83 c1 02             	add    $0x2,%ecx
f0105b9e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105ba3:	eb 16                	jmp    f0105bbb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0105ba5:	85 db                	test   %ebx,%ebx
f0105ba7:	75 12                	jne    f0105bbb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105ba9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105bae:	80 39 30             	cmpb   $0x30,(%ecx)
f0105bb1:	75 08                	jne    f0105bbb <strtol+0x77>
		s++, base = 8;
f0105bb3:	83 c1 01             	add    $0x1,%ecx
f0105bb6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105bbb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bc0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105bc3:	0f b6 11             	movzbl (%ecx),%edx
f0105bc6:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105bc9:	89 f3                	mov    %esi,%ebx
f0105bcb:	80 fb 09             	cmp    $0x9,%bl
f0105bce:	77 08                	ja     f0105bd8 <strtol+0x94>
			dig = *s - '0';
f0105bd0:	0f be d2             	movsbl %dl,%edx
f0105bd3:	83 ea 30             	sub    $0x30,%edx
f0105bd6:	eb 22                	jmp    f0105bfa <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f0105bd8:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105bdb:	89 f3                	mov    %esi,%ebx
f0105bdd:	80 fb 19             	cmp    $0x19,%bl
f0105be0:	77 08                	ja     f0105bea <strtol+0xa6>
			dig = *s - 'a' + 10;
f0105be2:	0f be d2             	movsbl %dl,%edx
f0105be5:	83 ea 57             	sub    $0x57,%edx
f0105be8:	eb 10                	jmp    f0105bfa <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f0105bea:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105bed:	89 f3                	mov    %esi,%ebx
f0105bef:	80 fb 19             	cmp    $0x19,%bl
f0105bf2:	77 16                	ja     f0105c0a <strtol+0xc6>
			dig = *s - 'A' + 10;
f0105bf4:	0f be d2             	movsbl %dl,%edx
f0105bf7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105bfa:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105bfd:	7d 0b                	jge    f0105c0a <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0105bff:	83 c1 01             	add    $0x1,%ecx
f0105c02:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105c06:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105c08:	eb b9                	jmp    f0105bc3 <strtol+0x7f>

	if (endptr)
f0105c0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105c0e:	74 0d                	je     f0105c1d <strtol+0xd9>
		*endptr = (char *) s;
f0105c10:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105c13:	89 0e                	mov    %ecx,(%esi)
f0105c15:	eb 06                	jmp    f0105c1d <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105c17:	85 db                	test   %ebx,%ebx
f0105c19:	74 98                	je     f0105bb3 <strtol+0x6f>
f0105c1b:	eb 9e                	jmp    f0105bbb <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105c1d:	89 c2                	mov    %eax,%edx
f0105c1f:	f7 da                	neg    %edx
f0105c21:	85 ff                	test   %edi,%edi
f0105c23:	0f 45 c2             	cmovne %edx,%eax
}
f0105c26:	5b                   	pop    %ebx
f0105c27:	5e                   	pop    %esi
f0105c28:	5f                   	pop    %edi
f0105c29:	5d                   	pop    %ebp
f0105c2a:	c3                   	ret    
f0105c2b:	90                   	nop

f0105c2c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105c2c:	fa                   	cli    

	xorw    %ax, %ax
f0105c2d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105c2f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105c31:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105c33:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105c35:	0f 01 16             	lgdtl  (%esi)
f0105c38:	74 70                	je     f0105caa <mpsearch1+0x3>
	movl    %cr0, %eax
f0105c3a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105c3d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105c41:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105c44:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105c4a:	08 00                	or     %al,(%eax)

f0105c4c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105c4c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105c50:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105c52:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105c54:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105c56:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105c5a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105c5c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105c5e:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105c63:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105c66:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105c69:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105c6e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0105c71:	8b 25 a4 8e 23 f0    	mov    0xf0238ea4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105c77:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105c7c:	b8 1e 03 10 f0       	mov    $0xf010031e,%eax
	call    *%eax
f0105c81:	ff d0                	call   *%eax

f0105c83 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105c83:	eb fe                	jmp    f0105c83 <spin>
f0105c85:	8d 76 00             	lea    0x0(%esi),%esi

f0105c88 <gdt>:
	...
f0105c90:	ff                   	(bad)  
f0105c91:	ff 00                	incl   (%eax)
f0105c93:	00 00                	add    %al,(%eax)
f0105c95:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105c9c:	00                   	.byte 0x0
f0105c9d:	92                   	xchg   %eax,%edx
f0105c9e:	cf                   	iret   
	...

f0105ca0 <gdtdesc>:
f0105ca0:	17                   	pop    %ss
f0105ca1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105ca6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105ca6:	90                   	nop

f0105ca7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105ca7:	55                   	push   %ebp
f0105ca8:	89 e5                	mov    %esp,%ebp
f0105caa:	57                   	push   %edi
f0105cab:	56                   	push   %esi
f0105cac:	53                   	push   %ebx
f0105cad:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105cb0:	8b 0d a8 8e 23 f0    	mov    0xf0238ea8,%ecx
f0105cb6:	89 c3                	mov    %eax,%ebx
f0105cb8:	c1 eb 0c             	shr    $0xc,%ebx
f0105cbb:	39 cb                	cmp    %ecx,%ebx
f0105cbd:	72 12                	jb     f0105cd1 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105cbf:	50                   	push   %eax
f0105cc0:	68 c0 67 10 f0       	push   $0xf01067c0
f0105cc5:	6a 57                	push   $0x57
f0105cc7:	68 81 83 10 f0       	push   $0xf0108381
f0105ccc:	e8 6f a3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105cd1:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105cd7:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105cd9:	89 c2                	mov    %eax,%edx
f0105cdb:	c1 ea 0c             	shr    $0xc,%edx
f0105cde:	39 ca                	cmp    %ecx,%edx
f0105ce0:	72 12                	jb     f0105cf4 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ce2:	50                   	push   %eax
f0105ce3:	68 c0 67 10 f0       	push   $0xf01067c0
f0105ce8:	6a 57                	push   $0x57
f0105cea:	68 81 83 10 f0       	push   $0xf0108381
f0105cef:	e8 4c a3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105cf4:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105cfa:	39 de                	cmp    %ebx,%esi
f0105cfc:	76 3f                	jbe    f0105d3d <mpsearch1+0x96>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105cfe:	83 ec 04             	sub    $0x4,%esp
f0105d01:	6a 04                	push   $0x4
f0105d03:	68 91 83 10 f0       	push   $0xf0108391
f0105d08:	53                   	push   %ebx
f0105d09:	e8 a6 fd ff ff       	call   f0105ab4 <memcmp>
f0105d0e:	83 c4 10             	add    $0x10,%esp
f0105d11:	85 c0                	test   %eax,%eax
f0105d13:	75 1a                	jne    f0105d2f <mpsearch1+0x88>
f0105d15:	89 d8                	mov    %ebx,%eax
f0105d17:	8d 7b 10             	lea    0x10(%ebx),%edi
f0105d1a:	ba 00 00 00 00       	mov    $0x0,%edx
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105d1f:	0f b6 08             	movzbl (%eax),%ecx
f0105d22:	01 ca                	add    %ecx,%edx
f0105d24:	83 c0 01             	add    $0x1,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105d27:	39 c7                	cmp    %eax,%edi
f0105d29:	75 f4                	jne    f0105d1f <mpsearch1+0x78>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105d2b:	84 d2                	test   %dl,%dl
f0105d2d:	74 15                	je     f0105d44 <mpsearch1+0x9d>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105d2f:	83 c3 10             	add    $0x10,%ebx
f0105d32:	39 f3                	cmp    %esi,%ebx
f0105d34:	72 c8                	jb     f0105cfe <mpsearch1+0x57>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105d36:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d3b:	eb 09                	jmp    f0105d46 <mpsearch1+0x9f>
f0105d3d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d42:	eb 02                	jmp    f0105d46 <mpsearch1+0x9f>
f0105d44:	89 d8                	mov    %ebx,%eax
}
f0105d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d49:	5b                   	pop    %ebx
f0105d4a:	5e                   	pop    %esi
f0105d4b:	5f                   	pop    %edi
f0105d4c:	5d                   	pop    %ebp
f0105d4d:	c3                   	ret    

f0105d4e <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105d4e:	55                   	push   %ebp
f0105d4f:	89 e5                	mov    %esp,%ebp
f0105d51:	57                   	push   %edi
f0105d52:	56                   	push   %esi
f0105d53:	53                   	push   %ebx
f0105d54:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105d57:	c7 05 c0 93 23 f0 20 	movl   $0xf0239020,0xf02393c0
f0105d5e:	90 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d61:	83 3d a8 8e 23 f0 00 	cmpl   $0x0,0xf0238ea8
f0105d68:	75 16                	jne    f0105d80 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d6a:	68 00 04 00 00       	push   $0x400
f0105d6f:	68 c0 67 10 f0       	push   $0xf01067c0
f0105d74:	6a 6f                	push   $0x6f
f0105d76:	68 81 83 10 f0       	push   $0xf0108381
f0105d7b:	e8 c0 a2 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105d80:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105d87:	85 c0                	test   %eax,%eax
f0105d89:	74 16                	je     f0105da1 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105d8b:	c1 e0 04             	shl    $0x4,%eax
f0105d8e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105d93:	e8 0f ff ff ff       	call   f0105ca7 <mpsearch1>
f0105d98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d9b:	85 c0                	test   %eax,%eax
f0105d9d:	75 3c                	jne    f0105ddb <mp_init+0x8d>
f0105d9f:	eb 20                	jmp    f0105dc1 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105da1:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105da8:	c1 e0 0a             	shl    $0xa,%eax
f0105dab:	2d 00 04 00 00       	sub    $0x400,%eax
f0105db0:	ba 00 04 00 00       	mov    $0x400,%edx
f0105db5:	e8 ed fe ff ff       	call   f0105ca7 <mpsearch1>
f0105dba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105dbd:	85 c0                	test   %eax,%eax
f0105dbf:	75 1a                	jne    f0105ddb <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105dc1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105dc6:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105dcb:	e8 d7 fe ff ff       	call   f0105ca7 <mpsearch1>
f0105dd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105dd3:	85 c0                	test   %eax,%eax
f0105dd5:	0f 84 6c 02 00 00    	je     f0106047 <mp_init+0x2f9>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105dde:	8b 70 04             	mov    0x4(%eax),%esi
f0105de1:	85 f6                	test   %esi,%esi
f0105de3:	74 06                	je     f0105deb <mp_init+0x9d>
f0105de5:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105de9:	74 15                	je     f0105e00 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105deb:	83 ec 0c             	sub    $0xc,%esp
f0105dee:	68 f4 81 10 f0       	push   $0xf01081f4
f0105df3:	e8 9c e0 ff ff       	call   f0103e94 <cprintf>
f0105df8:	83 c4 10             	add    $0x10,%esp
f0105dfb:	e9 47 02 00 00       	jmp    f0106047 <mp_init+0x2f9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e00:	89 f0                	mov    %esi,%eax
f0105e02:	c1 e8 0c             	shr    $0xc,%eax
f0105e05:	3b 05 a8 8e 23 f0    	cmp    0xf0238ea8,%eax
f0105e0b:	72 15                	jb     f0105e22 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e0d:	56                   	push   %esi
f0105e0e:	68 c0 67 10 f0       	push   $0xf01067c0
f0105e13:	68 90 00 00 00       	push   $0x90
f0105e18:	68 81 83 10 f0       	push   $0xf0108381
f0105e1d:	e8 1e a2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105e22:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105e28:	83 ec 04             	sub    $0x4,%esp
f0105e2b:	6a 04                	push   $0x4
f0105e2d:	68 96 83 10 f0       	push   $0xf0108396
f0105e32:	53                   	push   %ebx
f0105e33:	e8 7c fc ff ff       	call   f0105ab4 <memcmp>
f0105e38:	83 c4 10             	add    $0x10,%esp
f0105e3b:	85 c0                	test   %eax,%eax
f0105e3d:	74 15                	je     f0105e54 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105e3f:	83 ec 0c             	sub    $0xc,%esp
f0105e42:	68 24 82 10 f0       	push   $0xf0108224
f0105e47:	e8 48 e0 ff ff       	call   f0103e94 <cprintf>
f0105e4c:	83 c4 10             	add    $0x10,%esp
f0105e4f:	e9 f3 01 00 00       	jmp    f0106047 <mp_init+0x2f9>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105e54:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105e58:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105e5c:	0f b7 f8             	movzwl %ax,%edi
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105e5f:	85 ff                	test   %edi,%edi
f0105e61:	7e 34                	jle    f0105e97 <mp_init+0x149>
f0105e63:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e68:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105e6d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105e74:	f0 
f0105e75:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105e77:	83 c0 01             	add    $0x1,%eax
f0105e7a:	39 c7                	cmp    %eax,%edi
f0105e7c:	75 ef                	jne    f0105e6d <mp_init+0x11f>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105e7e:	84 d2                	test   %dl,%dl
f0105e80:	74 15                	je     f0105e97 <mp_init+0x149>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105e82:	83 ec 0c             	sub    $0xc,%esp
f0105e85:	68 58 82 10 f0       	push   $0xf0108258
f0105e8a:	e8 05 e0 ff ff       	call   f0103e94 <cprintf>
f0105e8f:	83 c4 10             	add    $0x10,%esp
f0105e92:	e9 b0 01 00 00       	jmp    f0106047 <mp_init+0x2f9>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105e97:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105e9b:	3c 01                	cmp    $0x1,%al
f0105e9d:	74 1d                	je     f0105ebc <mp_init+0x16e>
f0105e9f:	3c 04                	cmp    $0x4,%al
f0105ea1:	74 19                	je     f0105ebc <mp_init+0x16e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105ea3:	83 ec 08             	sub    $0x8,%esp
f0105ea6:	0f b6 c0             	movzbl %al,%eax
f0105ea9:	50                   	push   %eax
f0105eaa:	68 7c 82 10 f0       	push   $0xf010827c
f0105eaf:	e8 e0 df ff ff       	call   f0103e94 <cprintf>
f0105eb4:	83 c4 10             	add    $0x10,%esp
f0105eb7:	e9 8b 01 00 00       	jmp    f0106047 <mp_init+0x2f9>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105ebc:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105ec0:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ec4:	85 ff                	test   %edi,%edi
f0105ec6:	7e 1f                	jle    f0105ee7 <mp_init+0x199>
f0105ec8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ecd:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105ed2:	01 ce                	add    %ecx,%esi
f0105ed4:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105edb:	f0 
f0105edc:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ede:	83 c0 01             	add    $0x1,%eax
f0105ee1:	39 c7                	cmp    %eax,%edi
f0105ee3:	75 ef                	jne    f0105ed4 <mp_init+0x186>
f0105ee5:	eb 05                	jmp    f0105eec <mp_init+0x19e>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105ee7:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105eec:	38 53 2a             	cmp    %dl,0x2a(%ebx)
f0105eef:	74 15                	je     f0105f06 <mp_init+0x1b8>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105ef1:	83 ec 0c             	sub    $0xc,%esp
f0105ef4:	68 9c 82 10 f0       	push   $0xf010829c
f0105ef9:	e8 96 df ff ff       	call   f0103e94 <cprintf>
f0105efe:	83 c4 10             	add    $0x10,%esp
f0105f01:	e9 41 01 00 00       	jmp    f0106047 <mp_init+0x2f9>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105f06:	85 db                	test   %ebx,%ebx
f0105f08:	0f 84 39 01 00 00    	je     f0106047 <mp_init+0x2f9>
		return;
	ismp = 1;
f0105f0e:	c7 05 00 90 23 f0 01 	movl   $0x1,0xf0239000
f0105f15:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0105f18:	8b 43 24             	mov    0x24(%ebx),%eax
f0105f1b:	a3 00 a0 27 f0       	mov    %eax,0xf027a000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105f20:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105f23:	66 83 7b 22 00       	cmpw   $0x0,0x22(%ebx)
f0105f28:	0f 84 96 00 00 00    	je     f0105fc4 <mp_init+0x276>
f0105f2e:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0105f33:	0f b6 07             	movzbl (%edi),%eax
f0105f36:	84 c0                	test   %al,%al
f0105f38:	74 06                	je     f0105f40 <mp_init+0x1f2>
f0105f3a:	3c 04                	cmp    $0x4,%al
f0105f3c:	77 55                	ja     f0105f93 <mp_init+0x245>
f0105f3e:	eb 4e                	jmp    f0105f8e <mp_init+0x240>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105f40:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105f44:	74 11                	je     f0105f57 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0105f46:	6b 05 c4 93 23 f0 74 	imul   $0x74,0xf02393c4,%eax
f0105f4d:	05 20 90 23 f0       	add    $0xf0239020,%eax
f0105f52:	a3 c0 93 23 f0       	mov    %eax,0xf02393c0
			if (ncpu < NCPU) {
f0105f57:	a1 c4 93 23 f0       	mov    0xf02393c4,%eax
f0105f5c:	83 f8 07             	cmp    $0x7,%eax
f0105f5f:	7f 13                	jg     f0105f74 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f0105f61:	6b d0 74             	imul   $0x74,%eax,%edx
f0105f64:	88 82 20 90 23 f0    	mov    %al,-0xfdc6fe0(%edx)
				ncpu++;
f0105f6a:	83 c0 01             	add    $0x1,%eax
f0105f6d:	a3 c4 93 23 f0       	mov    %eax,0xf02393c4
f0105f72:	eb 15                	jmp    f0105f89 <mp_init+0x23b>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105f74:	83 ec 08             	sub    $0x8,%esp
f0105f77:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105f7b:	50                   	push   %eax
f0105f7c:	68 cc 82 10 f0       	push   $0xf01082cc
f0105f81:	e8 0e df ff ff       	call   f0103e94 <cprintf>
f0105f86:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105f89:	83 c7 14             	add    $0x14,%edi
			continue;
f0105f8c:	eb 27                	jmp    f0105fb5 <mp_init+0x267>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105f8e:	83 c7 08             	add    $0x8,%edi
			continue;
f0105f91:	eb 22                	jmp    f0105fb5 <mp_init+0x267>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105f93:	83 ec 08             	sub    $0x8,%esp
f0105f96:	0f b6 c0             	movzbl %al,%eax
f0105f99:	50                   	push   %eax
f0105f9a:	68 f4 82 10 f0       	push   $0xf01082f4
f0105f9f:	e8 f0 de ff ff       	call   f0103e94 <cprintf>
			ismp = 0;
f0105fa4:	c7 05 00 90 23 f0 00 	movl   $0x0,0xf0239000
f0105fab:	00 00 00 
			i = conf->entry;
f0105fae:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105fb2:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105fb5:	83 c6 01             	add    $0x1,%esi
f0105fb8:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105fbc:	39 f0                	cmp    %esi,%eax
f0105fbe:	0f 87 6f ff ff ff    	ja     f0105f33 <mp_init+0x1e5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105fc4:	a1 c0 93 23 f0       	mov    0xf02393c0,%eax
f0105fc9:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105fd0:	83 3d 00 90 23 f0 00 	cmpl   $0x0,0xf0239000
f0105fd7:	75 26                	jne    f0105fff <mp_init+0x2b1>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105fd9:	c7 05 c4 93 23 f0 01 	movl   $0x1,0xf02393c4
f0105fe0:	00 00 00 
		lapic = NULL;
f0105fe3:	c7 05 00 a0 27 f0 00 	movl   $0x0,0xf027a000
f0105fea:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105fed:	83 ec 0c             	sub    $0xc,%esp
f0105ff0:	68 14 83 10 f0       	push   $0xf0108314
f0105ff5:	e8 9a de ff ff       	call   f0103e94 <cprintf>
		return;
f0105ffa:	83 c4 10             	add    $0x10,%esp
f0105ffd:	eb 48                	jmp    f0106047 <mp_init+0x2f9>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105fff:	83 ec 04             	sub    $0x4,%esp
f0106002:	ff 35 c4 93 23 f0    	pushl  0xf02393c4
f0106008:	0f b6 00             	movzbl (%eax),%eax
f010600b:	50                   	push   %eax
f010600c:	68 9b 83 10 f0       	push   $0xf010839b
f0106011:	e8 7e de ff ff       	call   f0103e94 <cprintf>

	if (mp->imcrp) {
f0106016:	83 c4 10             	add    $0x10,%esp
f0106019:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010601c:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106020:	74 25                	je     f0106047 <mp_init+0x2f9>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106022:	83 ec 0c             	sub    $0xc,%esp
f0106025:	68 40 83 10 f0       	push   $0xf0108340
f010602a:	e8 65 de ff ff       	call   f0103e94 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010602f:	ba 22 00 00 00       	mov    $0x22,%edx
f0106034:	b8 70 00 00 00       	mov    $0x70,%eax
f0106039:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010603a:	ba 23 00 00 00       	mov    $0x23,%edx
f010603f:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106040:	83 c8 01             	or     $0x1,%eax
f0106043:	ee                   	out    %al,(%dx)
f0106044:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106047:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010604a:	5b                   	pop    %ebx
f010604b:	5e                   	pop    %esi
f010604c:	5f                   	pop    %edi
f010604d:	5d                   	pop    %ebp
f010604e:	c3                   	ret    

f010604f <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f010604f:	55                   	push   %ebp
f0106050:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106052:	8b 0d 00 a0 27 f0    	mov    0xf027a000,%ecx
f0106058:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010605b:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010605d:	a1 00 a0 27 f0       	mov    0xf027a000,%eax
f0106062:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106065:	5d                   	pop    %ebp
f0106066:	c3                   	ret    

f0106067 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106067:	55                   	push   %ebp
f0106068:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010606a:	a1 00 a0 27 f0       	mov    0xf027a000,%eax
f010606f:	85 c0                	test   %eax,%eax
f0106071:	74 08                	je     f010607b <cpunum+0x14>
		return lapic[ID] >> 24;
f0106073:	8b 40 20             	mov    0x20(%eax),%eax
f0106076:	c1 e8 18             	shr    $0x18,%eax
f0106079:	eb 05                	jmp    f0106080 <cpunum+0x19>
	return 0;
f010607b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106080:	5d                   	pop    %ebp
f0106081:	c3                   	ret    

f0106082 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapic) 
f0106082:	83 3d 00 a0 27 f0 00 	cmpl   $0x0,0xf027a000
f0106089:	0f 84 0b 01 00 00    	je     f010619a <lapic_init+0x118>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010608f:	55                   	push   %ebp
f0106090:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106092:	ba 27 01 00 00       	mov    $0x127,%edx
f0106097:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010609c:	e8 ae ff ff ff       	call   f010604f <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01060a1:	ba 0b 00 00 00       	mov    $0xb,%edx
f01060a6:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01060ab:	e8 9f ff ff ff       	call   f010604f <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01060b0:	ba 20 00 02 00       	mov    $0x20020,%edx
f01060b5:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01060ba:	e8 90 ff ff ff       	call   f010604f <lapicw>
	lapicw(TICR, 10000000); 
f01060bf:	ba 80 96 98 00       	mov    $0x989680,%edx
f01060c4:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01060c9:	e8 81 ff ff ff       	call   f010604f <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01060ce:	e8 94 ff ff ff       	call   f0106067 <cpunum>
f01060d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01060d6:	05 20 90 23 f0       	add    $0xf0239020,%eax
f01060db:	39 05 c0 93 23 f0    	cmp    %eax,0xf02393c0
f01060e1:	74 0f                	je     f01060f2 <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f01060e3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01060e8:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01060ed:	e8 5d ff ff ff       	call   f010604f <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01060f2:	ba 00 00 01 00       	mov    $0x10000,%edx
f01060f7:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01060fc:	e8 4e ff ff ff       	call   f010604f <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106101:	a1 00 a0 27 f0       	mov    0xf027a000,%eax
f0106106:	8b 40 30             	mov    0x30(%eax),%eax
f0106109:	c1 e8 10             	shr    $0x10,%eax
f010610c:	3c 03                	cmp    $0x3,%al
f010610e:	76 0f                	jbe    f010611f <lapic_init+0x9d>
		lapicw(PCINT, MASKED);
f0106110:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106115:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010611a:	e8 30 ff ff ff       	call   f010604f <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010611f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106124:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106129:	e8 21 ff ff ff       	call   f010604f <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010612e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106133:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106138:	e8 12 ff ff ff       	call   f010604f <lapicw>
	lapicw(ESR, 0);
f010613d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106142:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106147:	e8 03 ff ff ff       	call   f010604f <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010614c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106151:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106156:	e8 f4 fe ff ff       	call   f010604f <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010615b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106160:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106165:	e8 e5 fe ff ff       	call   f010604f <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010616a:	ba 00 85 08 00       	mov    $0x88500,%edx
f010616f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106174:	e8 d6 fe ff ff       	call   f010604f <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106179:	8b 15 00 a0 27 f0    	mov    0xf027a000,%edx
f010617f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106185:	f6 c4 10             	test   $0x10,%ah
f0106188:	75 f5                	jne    f010617f <lapic_init+0xfd>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010618a:	ba 00 00 00 00       	mov    $0x0,%edx
f010618f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106194:	e8 b6 fe ff ff       	call   f010604f <lapicw>
}
f0106199:	5d                   	pop    %ebp
f010619a:	f3 c3                	repz ret 

f010619c <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010619c:	83 3d 00 a0 27 f0 00 	cmpl   $0x0,0xf027a000
f01061a3:	74 13                	je     f01061b8 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01061a5:	55                   	push   %ebp
f01061a6:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01061a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01061ad:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01061b2:	e8 98 fe ff ff       	call   f010604f <lapicw>
}
f01061b7:	5d                   	pop    %ebp
f01061b8:	f3 c3                	repz ret 

f01061ba <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01061ba:	55                   	push   %ebp
f01061bb:	89 e5                	mov    %esp,%ebp
f01061bd:	56                   	push   %esi
f01061be:	53                   	push   %ebx
f01061bf:	8b 75 08             	mov    0x8(%ebp),%esi
f01061c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01061c5:	ba 70 00 00 00       	mov    $0x70,%edx
f01061ca:	b8 0f 00 00 00       	mov    $0xf,%eax
f01061cf:	ee                   	out    %al,(%dx)
f01061d0:	ba 71 00 00 00       	mov    $0x71,%edx
f01061d5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01061da:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061db:	83 3d a8 8e 23 f0 00 	cmpl   $0x0,0xf0238ea8
f01061e2:	75 19                	jne    f01061fd <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061e4:	68 67 04 00 00       	push   $0x467
f01061e9:	68 c0 67 10 f0       	push   $0xf01067c0
f01061ee:	68 93 00 00 00       	push   $0x93
f01061f3:	68 b8 83 10 f0       	push   $0xf01083b8
f01061f8:	e8 43 9e ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01061fd:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106204:	00 00 
	wrv[1] = addr >> 4;
f0106206:	89 d8                	mov    %ebx,%eax
f0106208:	c1 e8 04             	shr    $0x4,%eax
f010620b:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106211:	c1 e6 18             	shl    $0x18,%esi
f0106214:	89 f2                	mov    %esi,%edx
f0106216:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010621b:	e8 2f fe ff ff       	call   f010604f <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106220:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106225:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010622a:	e8 20 fe ff ff       	call   f010604f <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010622f:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106234:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106239:	e8 11 fe ff ff       	call   f010604f <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010623e:	c1 eb 0c             	shr    $0xc,%ebx
f0106241:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106244:	89 f2                	mov    %esi,%edx
f0106246:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010624b:	e8 ff fd ff ff       	call   f010604f <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106250:	89 da                	mov    %ebx,%edx
f0106252:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106257:	e8 f3 fd ff ff       	call   f010604f <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010625c:	89 f2                	mov    %esi,%edx
f010625e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106263:	e8 e7 fd ff ff       	call   f010604f <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106268:	89 da                	mov    %ebx,%edx
f010626a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010626f:	e8 db fd ff ff       	call   f010604f <lapicw>
		microdelay(200);
	}
}
f0106274:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106277:	5b                   	pop    %ebx
f0106278:	5e                   	pop    %esi
f0106279:	5d                   	pop    %ebp
f010627a:	c3                   	ret    

f010627b <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010627b:	55                   	push   %ebp
f010627c:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010627e:	8b 55 08             	mov    0x8(%ebp),%edx
f0106281:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106287:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010628c:	e8 be fd ff ff       	call   f010604f <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106291:	8b 15 00 a0 27 f0    	mov    0xf027a000,%edx
f0106297:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010629d:	f6 c4 10             	test   $0x10,%ah
f01062a0:	75 f5                	jne    f0106297 <lapic_ipi+0x1c>
		;
}
f01062a2:	5d                   	pop    %ebp
f01062a3:	c3                   	ret    

f01062a4 <atomic_return_and_add>:
// This is the atomic instruction that
// reading the old value as well as doing the add operation.
// If your gcc cannot support this function, report to TA.
#ifdef USE_TICKET_SPIN_LOCK
unsigned atomic_return_and_add(unsigned *addr, unsigned value)
{
f01062a4:	55                   	push   %ebp
f01062a5:	89 e5                	mov    %esp,%ebp
f01062a7:	8b 55 08             	mov    0x8(%ebp),%edx
	return __sync_fetch_and_add(addr, value);
f01062aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01062ad:	f0 0f c1 02          	lock xadd %eax,(%edx)
}
f01062b1:	5d                   	pop    %ebp
f01062b2:	c3                   	ret    

f01062b3 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01062b3:	55                   	push   %ebp
f01062b4:	89 e5                	mov    %esp,%ebp
f01062b6:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
#else
	//LAB 4: Your code here
	lk->own = 0;
f01062b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lk->next = 0;
f01062bf:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01062c6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01062c9:	89 50 08             	mov    %edx,0x8(%eax)
	lk->cpu = 0;
f01062cc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#endif
}
f01062d3:	5d                   	pop    %ebp
f01062d4:	c3                   	ret    

f01062d5 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01062d5:	55                   	push   %ebp
f01062d6:	89 e5                	mov    %esp,%ebp
f01062d8:	56                   	push   %esi
f01062d9:	53                   	push   %ebx
f01062da:	8b 5d 08             	mov    0x8(%ebp),%ebx
{
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
#else
	//LAB 4: Your code here
	return lock->own != lock->next && lock->cpu == thiscpu;
f01062dd:	8b 43 04             	mov    0x4(%ebx),%eax
f01062e0:	39 03                	cmp    %eax,(%ebx)
f01062e2:	74 32                	je     f0106316 <spin_lock+0x41>
f01062e4:	8b 73 0c             	mov    0xc(%ebx),%esi
f01062e7:	e8 7b fd ff ff       	call   f0106067 <cpunum>
f01062ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01062ef:	05 20 90 23 f0       	add    $0xf0239020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01062f4:	39 c6                	cmp    %eax,%esi
f01062f6:	75 1e                	jne    f0106316 <spin_lock+0x41>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01062f8:	8b 5b 08             	mov    0x8(%ebx),%ebx
f01062fb:	e8 67 fd ff ff       	call   f0106067 <cpunum>
f0106300:	83 ec 0c             	sub    $0xc,%esp
f0106303:	53                   	push   %ebx
f0106304:	50                   	push   %eax
f0106305:	68 c8 83 10 f0       	push   $0xf01083c8
f010630a:	6a 5b                	push   $0x5b
f010630c:	68 2c 84 10 f0       	push   $0xf010842c
f0106311:	e8 2a 9d ff ff       	call   f0100040 <_panic>
	// reordered before it.
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
#else
	//LAB 4: Your code here
	unsigned ticket = atomic_return_and_add(&(lk->next), 1);
f0106316:	83 ec 08             	sub    $0x8,%esp
f0106319:	6a 01                	push   $0x1
f010631b:	8d 43 04             	lea    0x4(%ebx),%eax
f010631e:	50                   	push   %eax
f010631f:	e8 80 ff ff ff       	call   f01062a4 <atomic_return_and_add>
	while (ticket != lk->own)
f0106324:	8b 13                	mov    (%ebx),%edx
f0106326:	83 c4 10             	add    $0x10,%esp
f0106329:	39 d0                	cmp    %edx,%eax
f010632b:	75 fc                	jne    f0106329 <spin_lock+0x54>
		
#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010632d:	e8 35 fd ff ff       	call   f0106067 <cpunum>
f0106332:	6b c0 74             	imul   $0x74,%eax,%eax
f0106335:	05 20 90 23 f0       	add    $0xf0239020,%eax
f010633a:	89 43 0c             	mov    %eax,0xc(%ebx)
	get_caller_pcs(lk->pcs);
f010633d:	8d 4b 10             	lea    0x10(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106340:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0106342:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f0106348:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f010634e:	76 3a                	jbe    f010638a <spin_lock+0xb5>
f0106350:	eb 31                	jmp    f0106383 <spin_lock+0xae>
f0106352:	8d 9a 00 00 80 10    	lea    0x10800000(%edx),%ebx
f0106358:	81 fb ff ff 7f 0e    	cmp    $0xe7fffff,%ebx
f010635e:	77 12                	ja     f0106372 <spin_lock+0x9d>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106360:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106363:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106366:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106368:	83 c0 01             	add    $0x1,%eax
f010636b:	83 f8 0a             	cmp    $0xa,%eax
f010636e:	75 e2                	jne    f0106352 <spin_lock+0x7d>
f0106370:	eb 27                	jmp    f0106399 <spin_lock+0xc4>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106372:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106379:	83 c0 01             	add    $0x1,%eax
f010637c:	83 f8 09             	cmp    $0x9,%eax
f010637f:	7e f1                	jle    f0106372 <spin_lock+0x9d>
f0106381:	eb 16                	jmp    f0106399 <spin_lock+0xc4>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106383:	b8 00 00 00 00       	mov    $0x0,%eax
f0106388:	eb e8                	jmp    f0106372 <spin_lock+0x9d>
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f010638a:	8b 50 04             	mov    0x4(%eax),%edx
f010638d:	89 53 10             	mov    %edx,0x10(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106390:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106392:	b8 01 00 00 00       	mov    $0x1,%eax
f0106397:	eb b9                	jmp    f0106352 <spin_lock+0x7d>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106399:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010639c:	5b                   	pop    %ebx
f010639d:	5e                   	pop    %esi
f010639e:	5d                   	pop    %ebp
f010639f:	c3                   	ret    

f01063a0 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01063a0:	55                   	push   %ebp
f01063a1:	89 e5                	mov    %esp,%ebp
f01063a3:	57                   	push   %edi
f01063a4:	56                   	push   %esi
f01063a5:	53                   	push   %ebx
f01063a6:	83 ec 4c             	sub    $0x4c,%esp
f01063a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
{
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
#else
	//LAB 4: Your code here
	return lock->own != lock->next && lock->cpu == thiscpu;
f01063ac:	8b 43 04             	mov    0x4(%ebx),%eax
f01063af:	39 03                	cmp    %eax,(%ebx)
f01063b1:	74 18                	je     f01063cb <spin_unlock+0x2b>
f01063b3:	8b 73 0c             	mov    0xc(%ebx),%esi
f01063b6:	e8 ac fc ff ff       	call   f0106067 <cpunum>
f01063bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01063be:	05 20 90 23 f0       	add    $0xf0239020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01063c3:	39 c6                	cmp    %eax,%esi
f01063c5:	0f 84 ae 00 00 00    	je     f0106479 <spin_unlock+0xd9>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01063cb:	83 ec 04             	sub    $0x4,%esp
f01063ce:	6a 28                	push   $0x28
f01063d0:	8d 43 10             	lea    0x10(%ebx),%eax
f01063d3:	50                   	push   %eax
f01063d4:	8d 45 c0             	lea    -0x40(%ebp),%eax
f01063d7:	50                   	push   %eax
f01063d8:	e8 5c f6 ff ff       	call   f0105a39 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
f01063dd:	8b 43 0c             	mov    0xc(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
f01063e0:	0f b6 30             	movzbl (%eax),%esi
f01063e3:	8b 5b 08             	mov    0x8(%ebx),%ebx
f01063e6:	e8 7c fc ff ff       	call   f0106067 <cpunum>
f01063eb:	56                   	push   %esi
f01063ec:	53                   	push   %ebx
f01063ed:	50                   	push   %eax
f01063ee:	68 f4 83 10 f0       	push   $0xf01083f4
f01063f3:	e8 9c da ff ff       	call   f0103e94 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01063f8:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01063fb:	83 c4 20             	add    $0x20,%esp
f01063fe:	85 c0                	test   %eax,%eax
f0106400:	74 60                	je     f0106462 <spin_unlock+0xc2>
f0106402:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106405:	8d 7d e4             	lea    -0x1c(%ebp),%edi
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106408:	8d 75 a8             	lea    -0x58(%ebp),%esi
f010640b:	83 ec 08             	sub    $0x8,%esp
f010640e:	56                   	push   %esi
f010640f:	50                   	push   %eax
f0106410:	e8 35 e8 ff ff       	call   f0104c4a <debuginfo_eip>
f0106415:	83 c4 10             	add    $0x10,%esp
f0106418:	85 c0                	test   %eax,%eax
f010641a:	78 27                	js     f0106443 <spin_unlock+0xa3>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010641c:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010641e:	83 ec 04             	sub    $0x4,%esp
f0106421:	89 c2                	mov    %eax,%edx
f0106423:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106426:	52                   	push   %edx
f0106427:	ff 75 b0             	pushl  -0x50(%ebp)
f010642a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010642d:	ff 75 ac             	pushl  -0x54(%ebp)
f0106430:	ff 75 a8             	pushl  -0x58(%ebp)
f0106433:	50                   	push   %eax
f0106434:	68 3c 84 10 f0       	push   $0xf010843c
f0106439:	e8 56 da ff ff       	call   f0103e94 <cprintf>
f010643e:	83 c4 20             	add    $0x20,%esp
f0106441:	eb 12                	jmp    f0106455 <spin_unlock+0xb5>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106443:	83 ec 08             	sub    $0x8,%esp
f0106446:	ff 33                	pushl  (%ebx)
f0106448:	68 53 84 10 f0       	push   $0xf0108453
f010644d:	e8 42 da ff ff       	call   f0103e94 <cprintf>
f0106452:	83 c4 10             	add    $0x10,%esp
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106455:	39 fb                	cmp    %edi,%ebx
f0106457:	74 09                	je     f0106462 <spin_unlock+0xc2>
f0106459:	83 c3 04             	add    $0x4,%ebx
f010645c:	8b 03                	mov    (%ebx),%eax
f010645e:	85 c0                	test   %eax,%eax
f0106460:	75 a9                	jne    f010640b <spin_unlock+0x6b>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106462:	83 ec 04             	sub    $0x4,%esp
f0106465:	68 5b 84 10 f0       	push   $0xf010845b
f010646a:	68 89 00 00 00       	push   $0x89
f010646f:	68 2c 84 10 f0       	push   $0xf010842c
f0106474:	e8 c7 9b ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106479:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
	lk->cpu = 0;
f0106480:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
#else
	//LAB 4: Your code here
	atomic_return_and_add(&(lk->own), 1);
f0106487:	83 ec 08             	sub    $0x8,%esp
f010648a:	6a 01                	push   $0x1
f010648c:	53                   	push   %ebx
f010648d:	e8 12 fe ff ff       	call   f01062a4 <atomic_return_and_add>
#endif
}
f0106492:	83 c4 10             	add    $0x10,%esp
f0106495:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106498:	5b                   	pop    %ebx
f0106499:	5e                   	pop    %esi
f010649a:	5f                   	pop    %edi
f010649b:	5d                   	pop    %ebp
f010649c:	c3                   	ret    
f010649d:	66 90                	xchg   %ax,%ax
f010649f:	90                   	nop

f01064a0 <__udivdi3>:
f01064a0:	55                   	push   %ebp
f01064a1:	57                   	push   %edi
f01064a2:	56                   	push   %esi
f01064a3:	53                   	push   %ebx
f01064a4:	83 ec 1c             	sub    $0x1c,%esp
f01064a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01064ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01064af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01064b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01064b7:	85 f6                	test   %esi,%esi
f01064b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01064bd:	89 ca                	mov    %ecx,%edx
f01064bf:	89 f8                	mov    %edi,%eax
f01064c1:	75 3d                	jne    f0106500 <__udivdi3+0x60>
f01064c3:	39 cf                	cmp    %ecx,%edi
f01064c5:	0f 87 c5 00 00 00    	ja     f0106590 <__udivdi3+0xf0>
f01064cb:	85 ff                	test   %edi,%edi
f01064cd:	89 fd                	mov    %edi,%ebp
f01064cf:	75 0b                	jne    f01064dc <__udivdi3+0x3c>
f01064d1:	b8 01 00 00 00       	mov    $0x1,%eax
f01064d6:	31 d2                	xor    %edx,%edx
f01064d8:	f7 f7                	div    %edi
f01064da:	89 c5                	mov    %eax,%ebp
f01064dc:	89 c8                	mov    %ecx,%eax
f01064de:	31 d2                	xor    %edx,%edx
f01064e0:	f7 f5                	div    %ebp
f01064e2:	89 c1                	mov    %eax,%ecx
f01064e4:	89 d8                	mov    %ebx,%eax
f01064e6:	89 cf                	mov    %ecx,%edi
f01064e8:	f7 f5                	div    %ebp
f01064ea:	89 c3                	mov    %eax,%ebx
f01064ec:	89 d8                	mov    %ebx,%eax
f01064ee:	89 fa                	mov    %edi,%edx
f01064f0:	83 c4 1c             	add    $0x1c,%esp
f01064f3:	5b                   	pop    %ebx
f01064f4:	5e                   	pop    %esi
f01064f5:	5f                   	pop    %edi
f01064f6:	5d                   	pop    %ebp
f01064f7:	c3                   	ret    
f01064f8:	90                   	nop
f01064f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106500:	39 ce                	cmp    %ecx,%esi
f0106502:	77 74                	ja     f0106578 <__udivdi3+0xd8>
f0106504:	0f bd fe             	bsr    %esi,%edi
f0106507:	83 f7 1f             	xor    $0x1f,%edi
f010650a:	0f 84 98 00 00 00    	je     f01065a8 <__udivdi3+0x108>
f0106510:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106515:	89 f9                	mov    %edi,%ecx
f0106517:	89 c5                	mov    %eax,%ebp
f0106519:	29 fb                	sub    %edi,%ebx
f010651b:	d3 e6                	shl    %cl,%esi
f010651d:	89 d9                	mov    %ebx,%ecx
f010651f:	d3 ed                	shr    %cl,%ebp
f0106521:	89 f9                	mov    %edi,%ecx
f0106523:	d3 e0                	shl    %cl,%eax
f0106525:	09 ee                	or     %ebp,%esi
f0106527:	89 d9                	mov    %ebx,%ecx
f0106529:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010652d:	89 d5                	mov    %edx,%ebp
f010652f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106533:	d3 ed                	shr    %cl,%ebp
f0106535:	89 f9                	mov    %edi,%ecx
f0106537:	d3 e2                	shl    %cl,%edx
f0106539:	89 d9                	mov    %ebx,%ecx
f010653b:	d3 e8                	shr    %cl,%eax
f010653d:	09 c2                	or     %eax,%edx
f010653f:	89 d0                	mov    %edx,%eax
f0106541:	89 ea                	mov    %ebp,%edx
f0106543:	f7 f6                	div    %esi
f0106545:	89 d5                	mov    %edx,%ebp
f0106547:	89 c3                	mov    %eax,%ebx
f0106549:	f7 64 24 0c          	mull   0xc(%esp)
f010654d:	39 d5                	cmp    %edx,%ebp
f010654f:	72 10                	jb     f0106561 <__udivdi3+0xc1>
f0106551:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106555:	89 f9                	mov    %edi,%ecx
f0106557:	d3 e6                	shl    %cl,%esi
f0106559:	39 c6                	cmp    %eax,%esi
f010655b:	73 07                	jae    f0106564 <__udivdi3+0xc4>
f010655d:	39 d5                	cmp    %edx,%ebp
f010655f:	75 03                	jne    f0106564 <__udivdi3+0xc4>
f0106561:	83 eb 01             	sub    $0x1,%ebx
f0106564:	31 ff                	xor    %edi,%edi
f0106566:	89 d8                	mov    %ebx,%eax
f0106568:	89 fa                	mov    %edi,%edx
f010656a:	83 c4 1c             	add    $0x1c,%esp
f010656d:	5b                   	pop    %ebx
f010656e:	5e                   	pop    %esi
f010656f:	5f                   	pop    %edi
f0106570:	5d                   	pop    %ebp
f0106571:	c3                   	ret    
f0106572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106578:	31 ff                	xor    %edi,%edi
f010657a:	31 db                	xor    %ebx,%ebx
f010657c:	89 d8                	mov    %ebx,%eax
f010657e:	89 fa                	mov    %edi,%edx
f0106580:	83 c4 1c             	add    $0x1c,%esp
f0106583:	5b                   	pop    %ebx
f0106584:	5e                   	pop    %esi
f0106585:	5f                   	pop    %edi
f0106586:	5d                   	pop    %ebp
f0106587:	c3                   	ret    
f0106588:	90                   	nop
f0106589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106590:	89 d8                	mov    %ebx,%eax
f0106592:	f7 f7                	div    %edi
f0106594:	31 ff                	xor    %edi,%edi
f0106596:	89 c3                	mov    %eax,%ebx
f0106598:	89 d8                	mov    %ebx,%eax
f010659a:	89 fa                	mov    %edi,%edx
f010659c:	83 c4 1c             	add    $0x1c,%esp
f010659f:	5b                   	pop    %ebx
f01065a0:	5e                   	pop    %esi
f01065a1:	5f                   	pop    %edi
f01065a2:	5d                   	pop    %ebp
f01065a3:	c3                   	ret    
f01065a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01065a8:	39 ce                	cmp    %ecx,%esi
f01065aa:	72 0c                	jb     f01065b8 <__udivdi3+0x118>
f01065ac:	31 db                	xor    %ebx,%ebx
f01065ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01065b2:	0f 87 34 ff ff ff    	ja     f01064ec <__udivdi3+0x4c>
f01065b8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01065bd:	e9 2a ff ff ff       	jmp    f01064ec <__udivdi3+0x4c>
f01065c2:	66 90                	xchg   %ax,%ax
f01065c4:	66 90                	xchg   %ax,%ax
f01065c6:	66 90                	xchg   %ax,%ax
f01065c8:	66 90                	xchg   %ax,%ax
f01065ca:	66 90                	xchg   %ax,%ax
f01065cc:	66 90                	xchg   %ax,%ax
f01065ce:	66 90                	xchg   %ax,%ax

f01065d0 <__umoddi3>:
f01065d0:	55                   	push   %ebp
f01065d1:	57                   	push   %edi
f01065d2:	56                   	push   %esi
f01065d3:	53                   	push   %ebx
f01065d4:	83 ec 1c             	sub    $0x1c,%esp
f01065d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01065db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01065df:	8b 74 24 34          	mov    0x34(%esp),%esi
f01065e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01065e7:	85 d2                	test   %edx,%edx
f01065e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01065ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01065f1:	89 f3                	mov    %esi,%ebx
f01065f3:	89 3c 24             	mov    %edi,(%esp)
f01065f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065fa:	75 1c                	jne    f0106618 <__umoddi3+0x48>
f01065fc:	39 f7                	cmp    %esi,%edi
f01065fe:	76 50                	jbe    f0106650 <__umoddi3+0x80>
f0106600:	89 c8                	mov    %ecx,%eax
f0106602:	89 f2                	mov    %esi,%edx
f0106604:	f7 f7                	div    %edi
f0106606:	89 d0                	mov    %edx,%eax
f0106608:	31 d2                	xor    %edx,%edx
f010660a:	83 c4 1c             	add    $0x1c,%esp
f010660d:	5b                   	pop    %ebx
f010660e:	5e                   	pop    %esi
f010660f:	5f                   	pop    %edi
f0106610:	5d                   	pop    %ebp
f0106611:	c3                   	ret    
f0106612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106618:	39 f2                	cmp    %esi,%edx
f010661a:	89 d0                	mov    %edx,%eax
f010661c:	77 52                	ja     f0106670 <__umoddi3+0xa0>
f010661e:	0f bd ea             	bsr    %edx,%ebp
f0106621:	83 f5 1f             	xor    $0x1f,%ebp
f0106624:	75 5a                	jne    f0106680 <__umoddi3+0xb0>
f0106626:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010662a:	0f 82 e0 00 00 00    	jb     f0106710 <__umoddi3+0x140>
f0106630:	39 0c 24             	cmp    %ecx,(%esp)
f0106633:	0f 86 d7 00 00 00    	jbe    f0106710 <__umoddi3+0x140>
f0106639:	8b 44 24 08          	mov    0x8(%esp),%eax
f010663d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106641:	83 c4 1c             	add    $0x1c,%esp
f0106644:	5b                   	pop    %ebx
f0106645:	5e                   	pop    %esi
f0106646:	5f                   	pop    %edi
f0106647:	5d                   	pop    %ebp
f0106648:	c3                   	ret    
f0106649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106650:	85 ff                	test   %edi,%edi
f0106652:	89 fd                	mov    %edi,%ebp
f0106654:	75 0b                	jne    f0106661 <__umoddi3+0x91>
f0106656:	b8 01 00 00 00       	mov    $0x1,%eax
f010665b:	31 d2                	xor    %edx,%edx
f010665d:	f7 f7                	div    %edi
f010665f:	89 c5                	mov    %eax,%ebp
f0106661:	89 f0                	mov    %esi,%eax
f0106663:	31 d2                	xor    %edx,%edx
f0106665:	f7 f5                	div    %ebp
f0106667:	89 c8                	mov    %ecx,%eax
f0106669:	f7 f5                	div    %ebp
f010666b:	89 d0                	mov    %edx,%eax
f010666d:	eb 99                	jmp    f0106608 <__umoddi3+0x38>
f010666f:	90                   	nop
f0106670:	89 c8                	mov    %ecx,%eax
f0106672:	89 f2                	mov    %esi,%edx
f0106674:	83 c4 1c             	add    $0x1c,%esp
f0106677:	5b                   	pop    %ebx
f0106678:	5e                   	pop    %esi
f0106679:	5f                   	pop    %edi
f010667a:	5d                   	pop    %ebp
f010667b:	c3                   	ret    
f010667c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106680:	8b 34 24             	mov    (%esp),%esi
f0106683:	bf 20 00 00 00       	mov    $0x20,%edi
f0106688:	89 e9                	mov    %ebp,%ecx
f010668a:	29 ef                	sub    %ebp,%edi
f010668c:	d3 e0                	shl    %cl,%eax
f010668e:	89 f9                	mov    %edi,%ecx
f0106690:	89 f2                	mov    %esi,%edx
f0106692:	d3 ea                	shr    %cl,%edx
f0106694:	89 e9                	mov    %ebp,%ecx
f0106696:	09 c2                	or     %eax,%edx
f0106698:	89 d8                	mov    %ebx,%eax
f010669a:	89 14 24             	mov    %edx,(%esp)
f010669d:	89 f2                	mov    %esi,%edx
f010669f:	d3 e2                	shl    %cl,%edx
f01066a1:	89 f9                	mov    %edi,%ecx
f01066a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01066a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01066ab:	d3 e8                	shr    %cl,%eax
f01066ad:	89 e9                	mov    %ebp,%ecx
f01066af:	89 c6                	mov    %eax,%esi
f01066b1:	d3 e3                	shl    %cl,%ebx
f01066b3:	89 f9                	mov    %edi,%ecx
f01066b5:	89 d0                	mov    %edx,%eax
f01066b7:	d3 e8                	shr    %cl,%eax
f01066b9:	89 e9                	mov    %ebp,%ecx
f01066bb:	09 d8                	or     %ebx,%eax
f01066bd:	89 d3                	mov    %edx,%ebx
f01066bf:	89 f2                	mov    %esi,%edx
f01066c1:	f7 34 24             	divl   (%esp)
f01066c4:	89 d6                	mov    %edx,%esi
f01066c6:	d3 e3                	shl    %cl,%ebx
f01066c8:	f7 64 24 04          	mull   0x4(%esp)
f01066cc:	39 d6                	cmp    %edx,%esi
f01066ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01066d2:	89 d1                	mov    %edx,%ecx
f01066d4:	89 c3                	mov    %eax,%ebx
f01066d6:	72 08                	jb     f01066e0 <__umoddi3+0x110>
f01066d8:	75 11                	jne    f01066eb <__umoddi3+0x11b>
f01066da:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01066de:	73 0b                	jae    f01066eb <__umoddi3+0x11b>
f01066e0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01066e4:	1b 14 24             	sbb    (%esp),%edx
f01066e7:	89 d1                	mov    %edx,%ecx
f01066e9:	89 c3                	mov    %eax,%ebx
f01066eb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01066ef:	29 da                	sub    %ebx,%edx
f01066f1:	19 ce                	sbb    %ecx,%esi
f01066f3:	89 f9                	mov    %edi,%ecx
f01066f5:	89 f0                	mov    %esi,%eax
f01066f7:	d3 e0                	shl    %cl,%eax
f01066f9:	89 e9                	mov    %ebp,%ecx
f01066fb:	d3 ea                	shr    %cl,%edx
f01066fd:	89 e9                	mov    %ebp,%ecx
f01066ff:	d3 ee                	shr    %cl,%esi
f0106701:	09 d0                	or     %edx,%eax
f0106703:	89 f2                	mov    %esi,%edx
f0106705:	83 c4 1c             	add    $0x1c,%esp
f0106708:	5b                   	pop    %ebx
f0106709:	5e                   	pop    %esi
f010670a:	5f                   	pop    %edi
f010670b:	5d                   	pop    %ebp
f010670c:	c3                   	ret    
f010670d:	8d 76 00             	lea    0x0(%esi),%esi
f0106710:	29 f9                	sub    %edi,%ecx
f0106712:	19 d6                	sbb    %edx,%esi
f0106714:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106718:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010671c:	e9 18 ff ff ff       	jmp    f0106639 <__umoddi3+0x69>
