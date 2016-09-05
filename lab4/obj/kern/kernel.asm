
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

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
f0100048:	83 3d a0 1e 24 f0 00 	cmpl   $0x0,0xf0241ea0
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 a0 1e 24 f0    	mov    %esi,0xf0241ea0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 82 68 00 00       	call   f01068e3 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 c0 6f 10 f0       	push   $0xf0106fc0
f010006d:	e8 1c 3e 00 00       	call   f0103e8e <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 ec 3d 00 00       	call   f0103e68 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 b6 73 10 f0 	movl   $0xf01073b6,(%esp)
f0100083:	e8 06 3e 00 00       	call   f0103e8e <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 89 0b 00 00       	call   f0100c1e <monitor>
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
f01000a9:	e8 35 68 00 00       	call   f01068e3 <cpunum>
f01000ae:	85 c0                	test   %eax,%eax
f01000b0:	75 10                	jne    f01000c2 <spinlock_test+0x28>
		while (interval++ < 10000) {
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
		}
	}

	for (i = 0; i < 100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f01000c7:	be ad 8b db 68       	mov    $0x68db8bad,%esi
f01000cc:	eb 14                	jmp    f01000e2 <spinlock_test+0x48>
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000) {
			asm volatile("pause");
f01000ce:	f3 90                	pause  
	int i;
	volatile int interval = 0;

	/* BSP give APs some time to reach this point */
	if (cpunum() == 0) {
		while (interval++ < 10000) {
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
f01000e5:	68 a0 23 12 f0       	push   $0xf01223a0
f01000ea:	e8 62 6a 00 00       	call   f0106b51 <spin_lock>
		}
	}

	for (i = 0; i < 100; i++) {
		lock_kernel();
		if (test_ctr % 10000 != 0)
f01000ef:	8b 0d 00 10 24 f0    	mov    0xf0241000,%ecx
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
f0100113:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0100118:	6a 25                	push   $0x25
f010011a:	68 88 70 10 f0       	push   $0xf0107088
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
f010013b:	a1 00 10 24 f0       	mov    0xf0241000,%eax
f0100140:	83 c0 01             	add    $0x1,%eax
f0100143:	a3 00 10 24 f0       	mov    %eax,0xf0241000
	for (i = 0; i < 100; i++) {
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
f010015b:	68 a0 23 12 f0       	push   $0xf01223a0
f0100160:	e8 c1 6a 00 00       	call   f0106c26 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0100165:	f3 90                	pause  
		while (interval++ < 10000) {
			asm volatile("pause");
		}
	}

	for (i = 0; i < 100; i++) {
f0100167:	83 c4 10             	add    $0x10,%esp
f010016a:	83 eb 01             	sub    $0x1,%ebx
f010016d:	0f 85 6f ff ff ff    	jne    f01000e2 <spinlock_test+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100173:	83 ec 0c             	sub    $0xc,%esp
f0100176:	68 a0 23 12 f0       	push   $0xf01223a0
f010017b:	e8 d1 69 00 00       	call   f0106b51 <spin_lock>
			test_ctr++;
		unlock_kernel();
	}

	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f0100180:	e8 5e 67 00 00       	call   f01068e3 <cpunum>
f0100185:	83 c4 08             	add    $0x8,%esp
f0100188:	50                   	push   %eax
f0100189:	68 18 70 10 f0       	push   $0xf0107018
f010018e:	e8 fb 3c 00 00       	call   f0103e8e <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0100193:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f010019a:	e8 87 6a 00 00       	call   f0106c26 <spin_unlock>

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
f01001b2:	b8 04 30 28 f0       	mov    $0xf0283004,%eax
f01001b7:	2d a8 01 24 f0       	sub    $0xf02401a8,%eax
f01001bc:	50                   	push   %eax
f01001bd:	6a 00                	push   $0x0
f01001bf:	68 a8 01 24 f0       	push   $0xf02401a8
f01001c4:	e8 a0 60 00 00       	call   f0106269 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001c9:	e8 c3 05 00 00       	call   f0100791 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01001ce:	83 c4 08             	add    $0x8,%esp
f01001d1:	68 ac 1a 00 00       	push   $0x1aac
f01001d6:	68 94 70 10 f0       	push   $0xf0107094
f01001db:	e8 ae 3c 00 00       	call   f0103e8e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001e0:	e8 5a 18 00 00       	call   f0101a3f <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001e5:	e8 63 34 00 00       	call   f010364d <env_init>
	trap_init();
f01001ea:	e8 b9 3d 00 00       	call   f0103fa8 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001ef:	e8 d6 63 00 00       	call   f01065ca <mp_init>
	lapic_init();
f01001f4:	e8 05 67 00 00       	call   f01068fe <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001f9:	e8 b4 3b 00 00       	call   f0103db2 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01001fe:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f0100205:	e8 47 69 00 00       	call   f0106b51 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010020a:	83 c4 10             	add    $0x10,%esp
f010020d:	83 3d a8 1e 24 f0 07 	cmpl   $0x7,0xf0241ea8
f0100214:	77 16                	ja     f010022c <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100216:	68 00 70 00 00       	push   $0x7000
f010021b:	68 40 70 10 f0       	push   $0xf0107040
f0100220:	6a 7b                	push   $0x7b
f0100222:	68 88 70 10 f0       	push   $0xf0107088
f0100227:	e8 14 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010022c:	83 ec 04             	sub    $0x4,%esp
f010022f:	b8 22 65 10 f0       	mov    $0xf0106522,%eax
f0100234:	2d a8 64 10 f0       	sub    $0xf01064a8,%eax
f0100239:	50                   	push   %eax
f010023a:	68 a8 64 10 f0       	push   $0xf01064a8
f010023f:	68 00 70 00 f0       	push   $0xf0007000
f0100244:	e8 6d 60 00 00       	call   f01062b6 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100249:	6b 05 c4 23 24 f0 74 	imul   $0x74,0xf02423c4,%eax
f0100250:	05 20 20 24 f0       	add    $0xf0242020,%eax
f0100255:	83 c4 10             	add    $0x10,%esp
f0100258:	3d 20 20 24 f0       	cmp    $0xf0242020,%eax
f010025d:	76 62                	jbe    f01002c1 <i386_init+0x116>
f010025f:	bb 20 20 24 f0       	mov    $0xf0242020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100264:	e8 7a 66 00 00       	call   f01068e3 <cpunum>
f0100269:	6b c0 74             	imul   $0x74,%eax,%eax
f010026c:	05 20 20 24 f0       	add    $0xf0242020,%eax
f0100271:	39 c3                	cmp    %eax,%ebx
f0100273:	74 39                	je     f01002ae <i386_init+0x103>
			continue;

		// Tell mpentry.S what stack to use
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100275:	89 d8                	mov    %ebx,%eax
f0100277:	2d 20 20 24 f0       	sub    $0xf0242020,%eax
f010027c:	c1 f8 02             	sar    $0x2,%eax
f010027f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100285:	c1 e0 0f             	shl    $0xf,%eax
f0100288:	05 00 b0 24 f0       	add    $0xf024b000,%eax
f010028d:	a3 a4 1e 24 f0       	mov    %eax,0xf0241ea4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100292:	83 ec 08             	sub    $0x8,%esp
f0100295:	68 00 70 00 00       	push   $0x7000
f010029a:	0f b6 03             	movzbl (%ebx),%eax
f010029d:	50                   	push   %eax
f010029e:	e8 93 67 00 00       	call   f0106a36 <lapic_startap>
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
f01002b1:	6b 05 c4 23 24 f0 74 	imul   $0x74,0xf02423c4,%eax
f01002b8:	05 20 20 24 f0       	add    $0xf0242020,%eax
f01002bd:	39 c3                	cmp    %eax,%ebx
f01002bf:	72 a3                	jb     f0100264 <i386_init+0xb9>
f01002c1:	bb 08 00 00 00       	mov    $0x8,%ebx
#endif
	// cprintf("spinlock_test() exited on CPU %d!\n", cpunum());
	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f01002c6:	83 ec 04             	sub    $0x4,%esp
f01002c9:	6a 01                	push   $0x1
f01002cb:	68 14 8b 00 00       	push   $0x8b14
f01002d0:	68 58 4b 1a f0       	push   $0xf01a4b58
f01002d5:	e8 68 35 00 00       	call   f0103842 <env_create>
		// lock_kernel();
#endif
	// cprintf("spinlock_test() exited on CPU %d!\n", cpunum());
	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01002da:	83 c4 10             	add    $0x10,%esp
f01002dd:	83 eb 01             	sub    $0x1,%ebx
f01002e0:	75 e4                	jne    f01002c6 <i386_init+0x11b>
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01002e2:	83 ec 04             	sub    $0x4,%esp
f01002e5:	6a 00                	push   $0x0
f01002e7:	68 44 9c 00 00       	push   $0x9c44
f01002ec:	68 b0 2c 22 f0       	push   $0xf0222cb0
f01002f1:	e8 4c 35 00 00       	call   f0103842 <env_create>
	// Touch all you want.
	ENV_CREATE(user_spin, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002f6:	e8 67 49 00 00       	call   f0104c62 <sched_yield>

f01002fb <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01002fb:	55                   	push   %ebp
f01002fc:	89 e5                	mov    %esp,%ebp
f01002fe:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir
	lcr3(PADDR(kern_pgdir));
f0100301:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100306:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010030b:	77 15                	ja     f0100322 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010030d:	50                   	push   %eax
f010030e:	68 64 70 10 f0       	push   $0xf0107064
f0100313:	68 92 00 00 00       	push   $0x92
f0100318:	68 88 70 10 f0       	push   $0xf0107088
f010031d:	e8 1e fd ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100322:	05 00 00 00 10       	add    $0x10000000,%eax
f0100327:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010032a:	e8 b4 65 00 00       	call   f01068e3 <cpunum>
f010032f:	83 ec 08             	sub    $0x8,%esp
f0100332:	50                   	push   %eax
f0100333:	68 af 70 10 f0       	push   $0xf01070af
f0100338:	e8 51 3b 00 00       	call   f0103e8e <cprintf>

	lapic_init();
f010033d:	e8 bc 65 00 00       	call   f01068fe <lapic_init>
	env_init_percpu();
f0100342:	e8 d6 32 00 00       	call   f010361d <env_init_percpu>
	trap_init_percpu();
f0100347:	e8 56 3b 00 00       	call   f0103ea2 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010034c:	e8 92 65 00 00       	call   f01068e3 <cpunum>
f0100351:	6b d0 74             	imul   $0x74,%eax,%edx
f0100354:	81 c2 20 20 24 f0    	add    $0xf0242020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010035a:	b8 01 00 00 00       	mov    $0x1,%eax
f010035f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)

#ifdef USE_TICKET_SPIN_LOCK
	spinlock_test();
f0100363:	e8 32 fd ff ff       	call   f010009a <spinlock_test>
f0100368:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f010036f:	e8 dd 67 00 00       	call   f0106b51 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100374:	e8 e9 48 00 00       	call   f0104c62 <sched_yield>

f0100379 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100379:	55                   	push   %ebp
f010037a:	89 e5                	mov    %esp,%ebp
f010037c:	53                   	push   %ebx
f010037d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100380:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100383:	ff 75 0c             	pushl  0xc(%ebp)
f0100386:	ff 75 08             	pushl  0x8(%ebp)
f0100389:	68 c5 70 10 f0       	push   $0xf01070c5
f010038e:	e8 fb 3a 00 00       	call   f0103e8e <cprintf>
	vcprintf(fmt, ap);
f0100393:	83 c4 08             	add    $0x8,%esp
f0100396:	53                   	push   %ebx
f0100397:	ff 75 10             	pushl  0x10(%ebp)
f010039a:	e8 c9 3a 00 00       	call   f0103e68 <vcprintf>
	cprintf("\n");
f010039f:	c7 04 24 b6 73 10 f0 	movl   $0xf01073b6,(%esp)
f01003a6:	e8 e3 3a 00 00       	call   f0103e8e <cprintf>
	va_end(ap);
}
f01003ab:	83 c4 10             	add    $0x10,%esp
f01003ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003b1:	c9                   	leave  
f01003b2:	c3                   	ret    

f01003b3 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01003b3:	55                   	push   %ebp
f01003b4:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003bb:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01003bc:	a8 01                	test   $0x1,%al
f01003be:	74 0b                	je     f01003cb <serial_proc_data+0x18>
f01003c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003c5:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01003c6:	0f b6 c0             	movzbl %al,%eax
f01003c9:	eb 05                	jmp    f01003d0 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01003cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01003d0:	5d                   	pop    %ebp
f01003d1:	c3                   	ret    

f01003d2 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01003d2:	55                   	push   %ebp
f01003d3:	89 e5                	mov    %esp,%ebp
f01003d5:	53                   	push   %ebx
f01003d6:	83 ec 04             	sub    $0x4,%esp
f01003d9:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01003db:	eb 2b                	jmp    f0100408 <cons_intr+0x36>
		if (c == 0)
f01003dd:	85 c0                	test   %eax,%eax
f01003df:	74 27                	je     f0100408 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01003e1:	8b 0d 44 12 24 f0    	mov    0xf0241244,%ecx
f01003e7:	8d 51 01             	lea    0x1(%ecx),%edx
f01003ea:	89 15 44 12 24 f0    	mov    %edx,0xf0241244
f01003f0:	88 81 40 10 24 f0    	mov    %al,-0xfdbefc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01003f6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003fc:	75 0a                	jne    f0100408 <cons_intr+0x36>
			cons.wpos = 0;
f01003fe:	c7 05 44 12 24 f0 00 	movl   $0x0,0xf0241244
f0100405:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100408:	ff d3                	call   *%ebx
f010040a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010040d:	75 ce                	jne    f01003dd <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010040f:	83 c4 04             	add    $0x4,%esp
f0100412:	5b                   	pop    %ebx
f0100413:	5d                   	pop    %ebp
f0100414:	c3                   	ret    

f0100415 <kbd_proc_data>:
f0100415:	ba 64 00 00 00       	mov    $0x64,%edx
f010041a:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010041b:	a8 01                	test   $0x1,%al
f010041d:	0f 84 f0 00 00 00    	je     f0100513 <kbd_proc_data+0xfe>
f0100423:	ba 60 00 00 00       	mov    $0x60,%edx
f0100428:	ec                   	in     (%dx),%al
f0100429:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010042b:	3c e0                	cmp    $0xe0,%al
f010042d:	75 0d                	jne    f010043c <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f010042f:	83 0d 20 10 24 f0 40 	orl    $0x40,0xf0241020
		return 0;
f0100436:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010043b:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010043c:	55                   	push   %ebp
f010043d:	89 e5                	mov    %esp,%ebp
f010043f:	53                   	push   %ebx
f0100440:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100443:	84 c0                	test   %al,%al
f0100445:	79 36                	jns    f010047d <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100447:	8b 0d 20 10 24 f0    	mov    0xf0241020,%ecx
f010044d:	89 cb                	mov    %ecx,%ebx
f010044f:	83 e3 40             	and    $0x40,%ebx
f0100452:	83 e0 7f             	and    $0x7f,%eax
f0100455:	85 db                	test   %ebx,%ebx
f0100457:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010045a:	0f b6 d2             	movzbl %dl,%edx
f010045d:	0f b6 82 40 72 10 f0 	movzbl -0xfef8dc0(%edx),%eax
f0100464:	83 c8 40             	or     $0x40,%eax
f0100467:	0f b6 c0             	movzbl %al,%eax
f010046a:	f7 d0                	not    %eax
f010046c:	21 c8                	and    %ecx,%eax
f010046e:	a3 20 10 24 f0       	mov    %eax,0xf0241020
		return 0;
f0100473:	b8 00 00 00 00       	mov    $0x0,%eax
f0100478:	e9 9e 00 00 00       	jmp    f010051b <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010047d:	8b 0d 20 10 24 f0    	mov    0xf0241020,%ecx
f0100483:	f6 c1 40             	test   $0x40,%cl
f0100486:	74 0e                	je     f0100496 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100488:	83 c8 80             	or     $0xffffff80,%eax
f010048b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010048d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100490:	89 0d 20 10 24 f0    	mov    %ecx,0xf0241020
	}

	shift |= shiftcode[data];
f0100496:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100499:	0f b6 82 40 72 10 f0 	movzbl -0xfef8dc0(%edx),%eax
f01004a0:	0b 05 20 10 24 f0    	or     0xf0241020,%eax
f01004a6:	0f b6 8a 40 71 10 f0 	movzbl -0xfef8ec0(%edx),%ecx
f01004ad:	31 c8                	xor    %ecx,%eax
f01004af:	a3 20 10 24 f0       	mov    %eax,0xf0241020

	c = charcode[shift & (CTL | SHIFT)][data];
f01004b4:	89 c1                	mov    %eax,%ecx
f01004b6:	83 e1 03             	and    $0x3,%ecx
f01004b9:	8b 0c 8d 20 71 10 f0 	mov    -0xfef8ee0(,%ecx,4),%ecx
f01004c0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01004c4:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01004c7:	a8 08                	test   $0x8,%al
f01004c9:	74 1b                	je     f01004e6 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01004cb:	89 da                	mov    %ebx,%edx
f01004cd:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01004d0:	83 f9 19             	cmp    $0x19,%ecx
f01004d3:	77 05                	ja     f01004da <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01004d5:	83 eb 20             	sub    $0x20,%ebx
f01004d8:	eb 0c                	jmp    f01004e6 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01004da:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01004dd:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01004e0:	83 fa 19             	cmp    $0x19,%edx
f01004e3:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004e6:	f7 d0                	not    %eax
f01004e8:	a8 06                	test   $0x6,%al
f01004ea:	75 2d                	jne    f0100519 <kbd_proc_data+0x104>
f01004ec:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004f2:	75 25                	jne    f0100519 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01004f4:	83 ec 0c             	sub    $0xc,%esp
f01004f7:	68 df 70 10 f0       	push   $0xf01070df
f01004fc:	e8 8d 39 00 00       	call   f0103e8e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100501:	ba 92 00 00 00       	mov    $0x92,%edx
f0100506:	b8 03 00 00 00       	mov    $0x3,%eax
f010050b:	ee                   	out    %al,(%dx)
f010050c:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010050f:	89 d8                	mov    %ebx,%eax
f0100511:	eb 08                	jmp    f010051b <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100513:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100518:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100519:	89 d8                	mov    %ebx,%eax
}
f010051b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010051e:	c9                   	leave  
f010051f:	c3                   	ret    

f0100520 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100520:	55                   	push   %ebp
f0100521:	89 e5                	mov    %esp,%ebp
f0100523:	57                   	push   %edi
f0100524:	56                   	push   %esi
f0100525:	53                   	push   %ebx
f0100526:	83 ec 1c             	sub    $0x1c,%esp
f0100529:	89 c7                	mov    %eax,%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010052b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100530:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100531:	a8 20                	test   $0x20,%al
f0100533:	75 27                	jne    f010055c <cons_putc+0x3c>
f0100535:	bb 00 00 00 00       	mov    $0x0,%ebx
f010053a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010053f:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100544:	89 ca                	mov    %ecx,%edx
f0100546:	ec                   	in     (%dx),%al
f0100547:	ec                   	in     (%dx),%al
f0100548:	ec                   	in     (%dx),%al
f0100549:	ec                   	in     (%dx),%al
	     i++)
f010054a:	83 c3 01             	add    $0x1,%ebx
f010054d:	89 f2                	mov    %esi,%edx
f010054f:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100550:	a8 20                	test   $0x20,%al
f0100552:	75 08                	jne    f010055c <cons_putc+0x3c>
f0100554:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010055a:	7e e8                	jle    f0100544 <cons_putc+0x24>
f010055c:	89 f8                	mov    %edi,%eax
f010055e:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100561:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100566:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100567:	ba 79 03 00 00       	mov    $0x379,%edx
f010056c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010056d:	84 c0                	test   %al,%al
f010056f:	78 27                	js     f0100598 <cons_putc+0x78>
f0100571:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100576:	b9 84 00 00 00       	mov    $0x84,%ecx
f010057b:	be 79 03 00 00       	mov    $0x379,%esi
f0100580:	89 ca                	mov    %ecx,%edx
f0100582:	ec                   	in     (%dx),%al
f0100583:	ec                   	in     (%dx),%al
f0100584:	ec                   	in     (%dx),%al
f0100585:	ec                   	in     (%dx),%al
f0100586:	83 c3 01             	add    $0x1,%ebx
f0100589:	89 f2                	mov    %esi,%edx
f010058b:	ec                   	in     (%dx),%al
f010058c:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100592:	7f 04                	jg     f0100598 <cons_putc+0x78>
f0100594:	84 c0                	test   %al,%al
f0100596:	79 e8                	jns    f0100580 <cons_putc+0x60>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100598:	ba 78 03 00 00       	mov    $0x378,%edx
f010059d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01005a1:	ee                   	out    %al,(%dx)
f01005a2:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01005a7:	b8 0d 00 00 00       	mov    $0xd,%eax
f01005ac:	ee                   	out    %al,(%dx)
f01005ad:	b8 08 00 00 00       	mov    $0x8,%eax
f01005b2:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01005b3:	89 fa                	mov    %edi,%edx
f01005b5:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01005bb:	89 f8                	mov    %edi,%eax
f01005bd:	80 cc 07             	or     $0x7,%ah
f01005c0:	85 d2                	test   %edx,%edx
f01005c2:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01005c5:	89 f8                	mov    %edi,%eax
f01005c7:	0f b6 c0             	movzbl %al,%eax
f01005ca:	83 f8 09             	cmp    $0x9,%eax
f01005cd:	74 74                	je     f0100643 <cons_putc+0x123>
f01005cf:	83 f8 09             	cmp    $0x9,%eax
f01005d2:	7f 0a                	jg     f01005de <cons_putc+0xbe>
f01005d4:	83 f8 08             	cmp    $0x8,%eax
f01005d7:	74 14                	je     f01005ed <cons_putc+0xcd>
f01005d9:	e9 99 00 00 00       	jmp    f0100677 <cons_putc+0x157>
f01005de:	83 f8 0a             	cmp    $0xa,%eax
f01005e1:	74 3a                	je     f010061d <cons_putc+0xfd>
f01005e3:	83 f8 0d             	cmp    $0xd,%eax
f01005e6:	74 3d                	je     f0100625 <cons_putc+0x105>
f01005e8:	e9 8a 00 00 00       	jmp    f0100677 <cons_putc+0x157>
	case '\b':
		if (crt_pos > 0) {
f01005ed:	0f b7 05 48 12 24 f0 	movzwl 0xf0241248,%eax
f01005f4:	66 85 c0             	test   %ax,%ax
f01005f7:	0f 84 e6 00 00 00    	je     f01006e3 <cons_putc+0x1c3>
			crt_pos--;
f01005fd:	83 e8 01             	sub    $0x1,%eax
f0100600:	66 a3 48 12 24 f0    	mov    %ax,0xf0241248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100606:	0f b7 c0             	movzwl %ax,%eax
f0100609:	66 81 e7 00 ff       	and    $0xff00,%di
f010060e:	83 cf 20             	or     $0x20,%edi
f0100611:	8b 15 4c 12 24 f0    	mov    0xf024124c,%edx
f0100617:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010061b:	eb 78                	jmp    f0100695 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010061d:	66 83 05 48 12 24 f0 	addw   $0x50,0xf0241248
f0100624:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100625:	0f b7 05 48 12 24 f0 	movzwl 0xf0241248,%eax
f010062c:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100632:	c1 e8 16             	shr    $0x16,%eax
f0100635:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100638:	c1 e0 04             	shl    $0x4,%eax
f010063b:	66 a3 48 12 24 f0    	mov    %ax,0xf0241248
f0100641:	eb 52                	jmp    f0100695 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f0100643:	b8 20 00 00 00       	mov    $0x20,%eax
f0100648:	e8 d3 fe ff ff       	call   f0100520 <cons_putc>
		cons_putc(' ');
f010064d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100652:	e8 c9 fe ff ff       	call   f0100520 <cons_putc>
		cons_putc(' ');
f0100657:	b8 20 00 00 00       	mov    $0x20,%eax
f010065c:	e8 bf fe ff ff       	call   f0100520 <cons_putc>
		cons_putc(' ');
f0100661:	b8 20 00 00 00       	mov    $0x20,%eax
f0100666:	e8 b5 fe ff ff       	call   f0100520 <cons_putc>
		cons_putc(' ');
f010066b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100670:	e8 ab fe ff ff       	call   f0100520 <cons_putc>
f0100675:	eb 1e                	jmp    f0100695 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100677:	0f b7 05 48 12 24 f0 	movzwl 0xf0241248,%eax
f010067e:	8d 50 01             	lea    0x1(%eax),%edx
f0100681:	66 89 15 48 12 24 f0 	mov    %dx,0xf0241248
f0100688:	0f b7 c0             	movzwl %ax,%eax
f010068b:	8b 15 4c 12 24 f0    	mov    0xf024124c,%edx
f0100691:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100695:	66 81 3d 48 12 24 f0 	cmpw   $0x7cf,0xf0241248
f010069c:	cf 07 
f010069e:	76 43                	jbe    f01006e3 <cons_putc+0x1c3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01006a0:	a1 4c 12 24 f0       	mov    0xf024124c,%eax
f01006a5:	83 ec 04             	sub    $0x4,%esp
f01006a8:	68 00 0f 00 00       	push   $0xf00
f01006ad:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01006b3:	52                   	push   %edx
f01006b4:	50                   	push   %eax
f01006b5:	e8 fc 5b 00 00       	call   f01062b6 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01006ba:	8b 15 4c 12 24 f0    	mov    0xf024124c,%edx
f01006c0:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01006c6:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01006cc:	83 c4 10             	add    $0x10,%esp
f01006cf:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01006d4:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006d7:	39 c2                	cmp    %eax,%edx
f01006d9:	75 f4                	jne    f01006cf <cons_putc+0x1af>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01006db:	66 83 2d 48 12 24 f0 	subw   $0x50,0xf0241248
f01006e2:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006e3:	8b 0d 50 12 24 f0    	mov    0xf0241250,%ecx
f01006e9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ee:	89 ca                	mov    %ecx,%edx
f01006f0:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006f1:	0f b7 1d 48 12 24 f0 	movzwl 0xf0241248,%ebx
f01006f8:	8d 71 01             	lea    0x1(%ecx),%esi
f01006fb:	89 d8                	mov    %ebx,%eax
f01006fd:	66 c1 e8 08          	shr    $0x8,%ax
f0100701:	89 f2                	mov    %esi,%edx
f0100703:	ee                   	out    %al,(%dx)
f0100704:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100709:	89 ca                	mov    %ecx,%edx
f010070b:	ee                   	out    %al,(%dx)
f010070c:	89 d8                	mov    %ebx,%eax
f010070e:	89 f2                	mov    %esi,%edx
f0100710:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100711:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100714:	5b                   	pop    %ebx
f0100715:	5e                   	pop    %esi
f0100716:	5f                   	pop    %edi
f0100717:	5d                   	pop    %ebp
f0100718:	c3                   	ret    

f0100719 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100719:	83 3d 54 12 24 f0 00 	cmpl   $0x0,0xf0241254
f0100720:	74 11                	je     f0100733 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100722:	55                   	push   %ebp
f0100723:	89 e5                	mov    %esp,%ebp
f0100725:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100728:	b8 b3 03 10 f0       	mov    $0xf01003b3,%eax
f010072d:	e8 a0 fc ff ff       	call   f01003d2 <cons_intr>
}
f0100732:	c9                   	leave  
f0100733:	f3 c3                	repz ret 

f0100735 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100735:	55                   	push   %ebp
f0100736:	89 e5                	mov    %esp,%ebp
f0100738:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010073b:	b8 15 04 10 f0       	mov    $0xf0100415,%eax
f0100740:	e8 8d fc ff ff       	call   f01003d2 <cons_intr>
}
f0100745:	c9                   	leave  
f0100746:	c3                   	ret    

f0100747 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100747:	55                   	push   %ebp
f0100748:	89 e5                	mov    %esp,%ebp
f010074a:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010074d:	e8 c7 ff ff ff       	call   f0100719 <serial_intr>
	kbd_intr();
f0100752:	e8 de ff ff ff       	call   f0100735 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100757:	a1 40 12 24 f0       	mov    0xf0241240,%eax
f010075c:	3b 05 44 12 24 f0    	cmp    0xf0241244,%eax
f0100762:	74 26                	je     f010078a <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100764:	8d 50 01             	lea    0x1(%eax),%edx
f0100767:	89 15 40 12 24 f0    	mov    %edx,0xf0241240
f010076d:	0f b6 88 40 10 24 f0 	movzbl -0xfdbefc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100774:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100776:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010077c:	75 11                	jne    f010078f <cons_getc+0x48>
			cons.rpos = 0;
f010077e:	c7 05 40 12 24 f0 00 	movl   $0x0,0xf0241240
f0100785:	00 00 00 
f0100788:	eb 05                	jmp    f010078f <cons_getc+0x48>
		return c;
	}
	return 0;
f010078a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010078f:	c9                   	leave  
f0100790:	c3                   	ret    

f0100791 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100791:	55                   	push   %ebp
f0100792:	89 e5                	mov    %esp,%ebp
f0100794:	57                   	push   %edi
f0100795:	56                   	push   %esi
f0100796:	53                   	push   %ebx
f0100797:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010079a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01007a1:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01007a8:	5a a5 
	if (*cp != 0xA55A) {
f01007aa:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01007b1:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01007b5:	74 11                	je     f01007c8 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01007b7:	c7 05 50 12 24 f0 b4 	movl   $0x3b4,0xf0241250
f01007be:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01007c1:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01007c6:	eb 16                	jmp    f01007de <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01007c8:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007cf:	c7 05 50 12 24 f0 d4 	movl   $0x3d4,0xf0241250
f01007d6:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01007d9:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01007de:	8b 3d 50 12 24 f0    	mov    0xf0241250,%edi
f01007e4:	b8 0e 00 00 00       	mov    $0xe,%eax
f01007e9:	89 fa                	mov    %edi,%edx
f01007eb:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01007ec:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007ef:	89 da                	mov    %ebx,%edx
f01007f1:	ec                   	in     (%dx),%al
f01007f2:	0f b6 c8             	movzbl %al,%ecx
f01007f5:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007f8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01007fd:	89 fa                	mov    %edi,%edx
f01007ff:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100800:	89 da                	mov    %ebx,%edx
f0100802:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100803:	89 35 4c 12 24 f0    	mov    %esi,0xf024124c
	crt_pos = pos;
f0100809:	0f b6 c0             	movzbl %al,%eax
f010080c:	09 c8                	or     %ecx,%eax
f010080e:	66 a3 48 12 24 f0    	mov    %ax,0xf0241248

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100814:	e8 1c ff ff ff       	call   f0100735 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100819:	83 ec 0c             	sub    $0xc,%esp
f010081c:	0f b7 05 88 23 12 f0 	movzwl 0xf0122388,%eax
f0100823:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100828:	50                   	push   %eax
f0100829:	e8 0c 35 00 00       	call   f0103d3a <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010082e:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100833:	b8 00 00 00 00       	mov    $0x0,%eax
f0100838:	89 f2                	mov    %esi,%edx
f010083a:	ee                   	out    %al,(%dx)
f010083b:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100840:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100845:	ee                   	out    %al,(%dx)
f0100846:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010084b:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100850:	89 da                	mov    %ebx,%edx
f0100852:	ee                   	out    %al,(%dx)
f0100853:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100858:	b8 00 00 00 00       	mov    $0x0,%eax
f010085d:	ee                   	out    %al,(%dx)
f010085e:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100863:	b8 03 00 00 00       	mov    $0x3,%eax
f0100868:	ee                   	out    %al,(%dx)
f0100869:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010086e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100873:	ee                   	out    %al,(%dx)
f0100874:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100879:	b8 01 00 00 00       	mov    $0x1,%eax
f010087e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010087f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100884:	ec                   	in     (%dx),%al
f0100885:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100887:	83 c4 10             	add    $0x10,%esp
f010088a:	3c ff                	cmp    $0xff,%al
f010088c:	0f 95 c0             	setne  %al
f010088f:	0f b6 c0             	movzbl %al,%eax
f0100892:	a3 54 12 24 f0       	mov    %eax,0xf0241254
f0100897:	89 f2                	mov    %esi,%edx
f0100899:	ec                   	in     (%dx),%al
f010089a:	89 da                	mov    %ebx,%edx
f010089c:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010089d:	80 f9 ff             	cmp    $0xff,%cl
f01008a0:	75 10                	jne    f01008b2 <cons_init+0x121>
		cprintf("Serial port does not exist!\n");
f01008a2:	83 ec 0c             	sub    $0xc,%esp
f01008a5:	68 eb 70 10 f0       	push   $0xf01070eb
f01008aa:	e8 df 35 00 00       	call   f0103e8e <cprintf>
f01008af:	83 c4 10             	add    $0x10,%esp
}
f01008b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008b5:	5b                   	pop    %ebx
f01008b6:	5e                   	pop    %esi
f01008b7:	5f                   	pop    %edi
f01008b8:	5d                   	pop    %ebp
f01008b9:	c3                   	ret    

f01008ba <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01008ba:	55                   	push   %ebp
f01008bb:	89 e5                	mov    %esp,%ebp
f01008bd:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01008c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01008c3:	e8 58 fc ff ff       	call   f0100520 <cons_putc>
}
f01008c8:	c9                   	leave  
f01008c9:	c3                   	ret    

f01008ca <getchar>:

int
getchar(void)
{
f01008ca:	55                   	push   %ebp
f01008cb:	89 e5                	mov    %esp,%ebp
f01008cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01008d0:	e8 72 fe ff ff       	call   f0100747 <cons_getc>
f01008d5:	85 c0                	test   %eax,%eax
f01008d7:	74 f7                	je     f01008d0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01008d9:	c9                   	leave  
f01008da:	c3                   	ret    

f01008db <iscons>:

int
iscons(int fdnum)
{
f01008db:	55                   	push   %ebp
f01008dc:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01008de:	b8 01 00 00 00       	mov    $0x1,%eax
f01008e3:	5d                   	pop    %ebp
f01008e4:	c3                   	ret    

f01008e5 <mon_help>:
	return 0;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008e5:	55                   	push   %ebp
f01008e6:	89 e5                	mov    %esp,%ebp
f01008e8:	56                   	push   %esi
f01008e9:	53                   	push   %ebx
f01008ea:	bb 84 76 10 f0       	mov    $0xf0107684,%ebx
f01008ef:	be d8 76 10 f0       	mov    $0xf01076d8,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008f4:	83 ec 04             	sub    $0x4,%esp
f01008f7:	ff 33                	pushl  (%ebx)
f01008f9:	ff 73 fc             	pushl  -0x4(%ebx)
f01008fc:	68 40 73 10 f0       	push   $0xf0107340
f0100901:	e8 88 35 00 00       	call   f0103e8e <cprintf>
f0100906:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100909:	83 c4 10             	add    $0x10,%esp
f010090c:	39 f3                	cmp    %esi,%ebx
f010090e:	75 e4                	jne    f01008f4 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100910:	b8 00 00 00 00       	mov    $0x0,%eax
f0100915:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100918:	5b                   	pop    %ebx
f0100919:	5e                   	pop    %esi
f010091a:	5d                   	pop    %ebp
f010091b:	c3                   	ret    

f010091c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010091c:	55                   	push   %ebp
f010091d:	89 e5                	mov    %esp,%ebp
f010091f:	83 ec 14             	sub    $0x14,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100922:	68 49 73 10 f0       	push   $0xf0107349
f0100927:	e8 62 35 00 00       	call   f0103e8e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010092c:	83 c4 0c             	add    $0xc,%esp
f010092f:	68 0c 00 10 00       	push   $0x10000c
f0100934:	68 0c 00 10 f0       	push   $0xf010000c
f0100939:	68 b8 74 10 f0       	push   $0xf01074b8
f010093e:	e8 4b 35 00 00       	call   f0103e8e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100943:	83 c4 0c             	add    $0xc,%esp
f0100946:	68 b1 6f 10 00       	push   $0x106fb1
f010094b:	68 b1 6f 10 f0       	push   $0xf0106fb1
f0100950:	68 dc 74 10 f0       	push   $0xf01074dc
f0100955:	e8 34 35 00 00       	call   f0103e8e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010095a:	83 c4 0c             	add    $0xc,%esp
f010095d:	68 a8 01 24 00       	push   $0x2401a8
f0100962:	68 a8 01 24 f0       	push   $0xf02401a8
f0100967:	68 00 75 10 f0       	push   $0xf0107500
f010096c:	e8 1d 35 00 00       	call   f0103e8e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100971:	83 c4 0c             	add    $0xc,%esp
f0100974:	68 04 30 28 00       	push   $0x283004
f0100979:	68 04 30 28 f0       	push   $0xf0283004
f010097e:	68 24 75 10 f0       	push   $0xf0107524
f0100983:	e8 06 35 00 00       	call   f0103e8e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100988:	83 c4 08             	add    $0x8,%esp
f010098b:	b8 03 34 28 f0       	mov    $0xf0283403,%eax
f0100990:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100995:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010099b:	85 c0                	test   %eax,%eax
f010099d:	0f 48 c2             	cmovs  %edx,%eax
f01009a0:	c1 f8 0a             	sar    $0xa,%eax
f01009a3:	50                   	push   %eax
f01009a4:	68 48 75 10 f0       	push   $0xf0107548
f01009a9:	e8 e0 34 00 00       	call   f0103e8e <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f01009ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b3:	c9                   	leave  
f01009b4:	c3                   	ret    

f01009b5 <mon_debug_display>:
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/
int
mon_debug_display(int argc, char **argv, struct Trapframe *tf)
{
f01009b5:	55                   	push   %ebp
f01009b6:	89 e5                	mov    %esp,%ebp
f01009b8:	83 ec 08             	sub    $0x8,%esp
	if (argc != 2) {
f01009bb:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01009bf:	74 17                	je     f01009d8 <mon_debug_display+0x23>
		cprintf("Usage: x [address]");
f01009c1:	83 ec 0c             	sub    $0xc,%esp
f01009c4:	68 62 73 10 f0       	push   $0xf0107362
f01009c9:	e8 c0 34 00 00       	call   f0103e8e <cprintf>
		return 1;
f01009ce:	83 c4 10             	add    $0x10,%esp
f01009d1:	b8 01 00 00 00       	mov    $0x1,%eax
f01009d6:	eb 29                	jmp    f0100a01 <mon_debug_display+0x4c>
	}

	int result = *(int *)(strtol(argv[1], NULL, 16));
f01009d8:	83 ec 04             	sub    $0x4,%esp
f01009db:	6a 10                	push   $0x10
f01009dd:	6a 00                	push   $0x0
f01009df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01009e2:	ff 70 04             	pushl  0x4(%eax)
f01009e5:	e8 d7 59 00 00       	call   f01063c1 <strtol>
	cprintf("%d\n", result);
f01009ea:	83 c4 08             	add    $0x8,%esp
f01009ed:	ff 30                	pushl  (%eax)
f01009ef:	68 d4 83 10 f0       	push   $0xf01083d4
f01009f4:	e8 95 34 00 00       	call   f0103e8e <cprintf>
	return 0;
f01009f9:	83 c4 10             	add    $0x10,%esp
f01009fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100a01:	c9                   	leave  
f0100a02:	c3                   	ret    

f0100a03 <mon_debug_step>:

int
mon_debug_step(int argc, char **argv, struct Trapframe *tf)
{
f0100a03:	55                   	push   %ebp
f0100a04:	89 e5                	mov    %esp,%ebp
f0100a06:	83 ec 08             	sub    $0x8,%esp
f0100a09:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf == NULL) {
f0100a0c:	85 c0                	test   %eax,%eax
f0100a0e:	74 2d                	je     f0100a3d <mon_debug_step+0x3a>
		cprintf("Trapframe is NULL.\n");
		return 1;
	}

	tf->tf_eflags |= FL_TF;
f0100a10:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
	cprintf("tf_eip=0x%x\n", tf->tf_eip);
f0100a17:	83 ec 08             	sub    $0x8,%esp
f0100a1a:	ff 70 30             	pushl  0x30(%eax)
f0100a1d:	68 89 73 10 f0       	push   $0xf0107389
f0100a22:	e8 67 34 00 00       	call   f0103e8e <cprintf>
	env_run(curenv);
f0100a27:	e8 b7 5e 00 00       	call   f01068e3 <cpunum>
f0100a2c:	83 c4 04             	add    $0x4,%esp
f0100a2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0100a32:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0100a38:	e8 d3 31 00 00       	call   f0103c10 <env_run>

int
mon_debug_step(int argc, char **argv, struct Trapframe *tf)
{
	if (tf == NULL) {
		cprintf("Trapframe is NULL.\n");
f0100a3d:	83 ec 0c             	sub    $0xc,%esp
f0100a40:	68 75 73 10 f0       	push   $0xf0107375
f0100a45:	e8 44 34 00 00       	call   f0103e8e <cprintf>

	tf->tf_eflags |= FL_TF;
	cprintf("tf_eip=0x%x\n", tf->tf_eip);
	env_run(curenv);
	return 0;
}
f0100a4a:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a4f:	c9                   	leave  
f0100a50:	c3                   	ret    

f0100a51 <mon_debug_continue>:

int
mon_debug_continue(int argc, char **argv, struct Trapframe *tf)
{
f0100a51:	55                   	push   %ebp
f0100a52:	89 e5                	mov    %esp,%ebp
f0100a54:	83 ec 08             	sub    $0x8,%esp
f0100a57:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf == NULL) {
f0100a5a:	85 c0                	test   %eax,%eax
f0100a5c:	74 1d                	je     f0100a7b <mon_debug_continue+0x2a>
		cprintf("Trapframe is NULL.\n");
		return 1;
	}

	tf->tf_eflags &= ~FL_TF;
f0100a5e:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	env_run(curenv);
f0100a65:	e8 79 5e 00 00       	call   f01068e3 <cpunum>
f0100a6a:	83 ec 0c             	sub    $0xc,%esp
f0100a6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0100a70:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0100a76:	e8 95 31 00 00       	call   f0103c10 <env_run>

int
mon_debug_continue(int argc, char **argv, struct Trapframe *tf)
{
	if (tf == NULL) {
		cprintf("Trapframe is NULL.\n");
f0100a7b:	83 ec 0c             	sub    $0xc,%esp
f0100a7e:	68 75 73 10 f0       	push   $0xf0107375
f0100a83:	e8 06 34 00 00       	call   f0103e8e <cprintf>
	}

	tf->tf_eflags &= ~FL_TF;
	env_run(curenv);
	return 0;
}
f0100a88:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a8d:	c9                   	leave  
f0100a8e:	c3                   	ret    

f0100a8f <mon_backtrace>:

#define EBP_OFFSET(ebp, offset) (*((uint32_t *)(ebp) + (offset)))

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a8f:	55                   	push   %ebp
f0100a90:	89 e5                	mov    %esp,%ebp
f0100a92:	57                   	push   %edi
f0100a93:	56                   	push   %esi
f0100a94:	53                   	push   %ebx
f0100a95:	83 ec 48             	sub    $0x48,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a98:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
f0100a9a:	68 96 73 10 f0       	push   $0xf0107396
f0100a9f:	e8 ea 33 00 00       	call   f0103e8e <cprintf>
	while(ebp != 0x0) {
f0100aa4:	83 c4 10             	add    $0x10,%esp
f0100aa7:	85 f6                	test   %esi,%esi
f0100aa9:	0f 84 97 00 00 00    	je     f0100b46 <mon_backtrace+0xb7>
f0100aaf:	89 f3                	mov    %esi,%ebx
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f0100ab1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100ab4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
		eip = EBP_OFFSET(ebp, 1);
f0100ab7:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
f0100aba:	ff 73 18             	pushl  0x18(%ebx)
f0100abd:	ff 73 14             	pushl  0x14(%ebx)
f0100ac0:	ff 73 10             	pushl  0x10(%ebx)
f0100ac3:	ff 73 0c             	pushl  0xc(%ebx)
f0100ac6:	ff 73 08             	pushl  0x8(%ebx)
f0100ac9:	53                   	push   %ebx
f0100aca:	56                   	push   %esi
f0100acb:	68 74 75 10 f0       	push   $0xf0107574
f0100ad0:	e8 b9 33 00 00       	call   f0103e8e <cprintf>
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f0100ad5:	83 c4 18             	add    $0x18,%esp
f0100ad8:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100adb:	56                   	push   %esi
f0100adc:	e8 e6 49 00 00       	call   f01054c7 <debuginfo_eip>
f0100ae1:	83 c4 10             	add    $0x10,%esp
f0100ae4:	85 c0                	test   %eax,%eax
f0100ae6:	75 54                	jne    f0100b3c <mon_backtrace+0xad>
f0100ae8:	89 65 c0             	mov    %esp,-0x40(%ebp)
			char func_name[info.eip_fn_namelen + 1];
f0100aeb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100aee:	8d 41 10             	lea    0x10(%ecx),%eax
f0100af1:	bf 10 00 00 00       	mov    $0x10,%edi
f0100af6:	ba 00 00 00 00       	mov    $0x0,%edx
f0100afb:	f7 f7                	div    %edi
f0100afd:	c1 e0 04             	shl    $0x4,%eax
f0100b00:	29 c4                	sub    %eax,%esp
f0100b02:	89 e0                	mov    %esp,%eax
f0100b04:	89 e7                	mov    %esp,%edi
			func_name[info.eip_fn_namelen] = '\0';
f0100b06:	c6 04 0c 00          	movb   $0x0,(%esp,%ecx,1)
			if (strncpy(func_name, info.eip_fn_name, info.eip_fn_namelen)) {
f0100b0a:	83 ec 04             	sub    $0x4,%esp
f0100b0d:	51                   	push   %ecx
f0100b0e:	ff 75 d8             	pushl  -0x28(%ebp)
f0100b11:	50                   	push   %eax
f0100b12:	e8 f2 55 00 00       	call   f0106109 <strncpy>
f0100b17:	83 c4 10             	add    $0x10,%esp
f0100b1a:	85 c0                	test   %eax,%eax
f0100b1c:	74 1b                	je     f0100b39 <mon_backtrace+0xaa>
				cprintf("\t%s:%d: %s+%x\n\n", info.eip_file, info.eip_line,
f0100b1e:	83 ec 0c             	sub    $0xc,%esp
f0100b21:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100b24:	56                   	push   %esi
f0100b25:	57                   	push   %edi
f0100b26:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100b29:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b2c:	68 a8 73 10 f0       	push   $0xf01073a8
f0100b31:	e8 58 33 00 00       	call   f0103e8e <cprintf>
f0100b36:	83 c4 20             	add    $0x20,%esp
f0100b39:	8b 65 c0             	mov    -0x40(%ebp),%esp
				func_name, eip - info.eip_fn_addr);
			}
		}
		// warning: the value of ebp to print is register value, not stack value
		ebp = EBP_OFFSET(ebp, 0);
f0100b3c:	8b 1b                	mov    (%ebx),%ebx
{
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
f0100b3e:	85 db                	test   %ebx,%ebx
f0100b40:	0f 85 71 ff ff ff    	jne    f0100ab7 <mon_backtrace+0x28>
		}
		// warning: the value of ebp to print is register value, not stack value
		ebp = EBP_OFFSET(ebp, 0);
	}

	cprintf("Backtrace success\n");
f0100b46:	83 ec 0c             	sub    $0xc,%esp
f0100b49:	68 b8 73 10 f0       	push   $0xf01073b8
f0100b4e:	e8 3b 33 00 00       	call   f0103e8e <cprintf>
	return 0;
}
f0100b53:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b5b:	5b                   	pop    %ebx
f0100b5c:	5e                   	pop    %esi
f0100b5d:	5f                   	pop    %edi
f0100b5e:	5d                   	pop    %ebp
f0100b5f:	c3                   	ret    

f0100b60 <mon_time>:
	return (((uint64_t)high << 32) | low);
}

int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f0100b60:	55                   	push   %ebp
f0100b61:	89 e5                	mov    %esp,%ebp
f0100b63:	57                   	push   %edi
f0100b64:	56                   	push   %esi
f0100b65:	53                   	push   %ebx
f0100b66:	83 ec 1c             	sub    $0x1c,%esp
f0100b69:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100b6c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100b70:	74 0c                	je     f0100b7e <mon_time+0x1e>
f0100b72:	bf 80 76 10 f0       	mov    $0xf0107680,%edi
f0100b77:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b7c:	eb 1d                	jmp    f0100b9b <mon_time+0x3b>
		cprintf("Usage: time [command]\n");
f0100b7e:	83 ec 0c             	sub    $0xc,%esp
f0100b81:	68 cb 73 10 f0       	push   $0xf01073cb
f0100b86:	e8 03 33 00 00       	call   f0103e8e <cprintf>
		return 0;
f0100b8b:	83 c4 10             	add    $0x10,%esp
f0100b8e:	eb 7a                	jmp    f0100c0a <mon_time+0xaa>
	}

	int i;
	for (i = 0; i < NCOMMANDS && strcmp(argv[1], commands[i].name); i++)
f0100b90:	83 c3 01             	add    $0x1,%ebx
f0100b93:	83 c7 0c             	add    $0xc,%edi
f0100b96:	83 fb 07             	cmp    $0x7,%ebx
f0100b99:	74 19                	je     f0100bb4 <mon_time+0x54>
f0100b9b:	83 ec 08             	sub    $0x8,%esp
f0100b9e:	ff 37                	pushl  (%edi)
f0100ba0:	ff 76 04             	pushl  0x4(%esi)
f0100ba3:	e8 df 55 00 00       	call   f0106187 <strcmp>
f0100ba8:	83 c4 10             	add    $0x10,%esp
f0100bab:	85 c0                	test   %eax,%eax
f0100bad:	75 e1                	jne    f0100b90 <mon_time+0x30>
		;

	if (i == NCOMMANDS) {
f0100baf:	83 fb 07             	cmp    $0x7,%ebx
f0100bb2:	75 15                	jne    f0100bc9 <mon_time+0x69>
		cprintf("Unknown command: %s\n", argv[1]);
f0100bb4:	83 ec 08             	sub    $0x8,%esp
f0100bb7:	ff 76 04             	pushl  0x4(%esi)
f0100bba:	68 e2 73 10 f0       	push   $0xf01073e2
f0100bbf:	e8 ca 32 00 00       	call   f0103e8e <cprintf>
		return 0;
f0100bc4:	83 c4 10             	add    $0x10,%esp
f0100bc7:	eb 41                	jmp    f0100c0a <mon_time+0xaa>

uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f0100bc9:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
f0100bcb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100bce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		cprintf("Unknown command: %s\n", argv[1]);
		return 0;
	}

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
f0100bd1:	83 ec 04             	sub    $0x4,%esp
f0100bd4:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f0100bd7:	ff 75 10             	pushl  0x10(%ebp)
f0100bda:	8d 46 04             	lea    0x4(%esi),%eax
f0100bdd:	50                   	push   %eax
f0100bde:	8b 45 08             	mov    0x8(%ebp),%eax
f0100be1:	83 e8 01             	sub    $0x1,%eax
f0100be4:	50                   	push   %eax
f0100be5:	ff 14 95 88 76 10 f0 	call   *-0xfef8978(,%edx,4)

uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f0100bec:	0f 31                	rdtsc  

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
	uint64_t end = rdtsc();

	cprintf("%s cycles: %llu\n", argv[1], end - start);
f0100bee:	89 c1                	mov    %eax,%ecx
f0100bf0:	89 d3                	mov    %edx,%ebx
f0100bf2:	2b 4d e0             	sub    -0x20(%ebp),%ecx
f0100bf5:	1b 5d e4             	sbb    -0x1c(%ebp),%ebx
f0100bf8:	53                   	push   %ebx
f0100bf9:	51                   	push   %ecx
f0100bfa:	ff 76 04             	pushl  0x4(%esi)
f0100bfd:	68 f7 73 10 f0       	push   $0xf01073f7
f0100c02:	e8 87 32 00 00       	call   f0103e8e <cprintf>

	return 0;
f0100c07:	83 c4 20             	add    $0x20,%esp
}
f0100c0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c12:	5b                   	pop    %ebx
f0100c13:	5e                   	pop    %esi
f0100c14:	5f                   	pop    %edi
f0100c15:	5d                   	pop    %ebp
f0100c16:	c3                   	ret    

f0100c17 <rdtsc>:
	return 0;
}

uint64_t
rdtsc()
{
f0100c17:	55                   	push   %ebp
f0100c18:	89 e5                	mov    %esp,%ebp
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f0100c1a:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
}
f0100c1c:	5d                   	pop    %ebp
f0100c1d:	c3                   	ret    

f0100c1e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100c1e:	55                   	push   %ebp
f0100c1f:	89 e5                	mov    %esp,%ebp
f0100c21:	57                   	push   %edi
f0100c22:	56                   	push   %esi
f0100c23:	53                   	push   %ebx
f0100c24:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100c27:	68 ac 75 10 f0       	push   $0xf01075ac
f0100c2c:	e8 5d 32 00 00       	call   f0103e8e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c31:	c7 04 24 d0 75 10 f0 	movl   $0xf01075d0,(%esp)
f0100c38:	e8 51 32 00 00       	call   f0103e8e <cprintf>

	if (tf != NULL)
f0100c3d:	83 c4 10             	add    $0x10,%esp
f0100c40:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100c44:	74 0e                	je     f0100c54 <monitor+0x36>
		print_trapframe(tf);
f0100c46:	83 ec 0c             	sub    $0xc,%esp
f0100c49:	ff 75 08             	pushl  0x8(%ebp)
f0100c4c:	e8 fc 39 00 00       	call   f010464d <print_trapframe>
f0100c51:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100c54:	83 ec 0c             	sub    $0xc,%esp
f0100c57:	68 08 74 10 f0       	push   $0xf0107408
f0100c5c:	e8 32 53 00 00       	call   f0105f93 <readline>
f0100c61:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100c63:	83 c4 10             	add    $0x10,%esp
f0100c66:	85 c0                	test   %eax,%eax
f0100c68:	74 ea                	je     f0100c54 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100c6a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100c71:	be 00 00 00 00       	mov    $0x0,%esi
f0100c76:	eb 0a                	jmp    f0100c82 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100c78:	c6 03 00             	movb   $0x0,(%ebx)
f0100c7b:	89 f7                	mov    %esi,%edi
f0100c7d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100c80:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100c82:	0f b6 03             	movzbl (%ebx),%eax
f0100c85:	84 c0                	test   %al,%al
f0100c87:	74 6a                	je     f0100cf3 <monitor+0xd5>
f0100c89:	83 ec 08             	sub    $0x8,%esp
f0100c8c:	0f be c0             	movsbl %al,%eax
f0100c8f:	50                   	push   %eax
f0100c90:	68 0c 74 10 f0       	push   $0xf010740c
f0100c95:	e8 71 55 00 00       	call   f010620b <strchr>
f0100c9a:	83 c4 10             	add    $0x10,%esp
f0100c9d:	85 c0                	test   %eax,%eax
f0100c9f:	75 d7                	jne    f0100c78 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100ca1:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ca4:	74 4d                	je     f0100cf3 <monitor+0xd5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100ca6:	83 fe 0f             	cmp    $0xf,%esi
f0100ca9:	75 14                	jne    f0100cbf <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100cab:	83 ec 08             	sub    $0x8,%esp
f0100cae:	6a 10                	push   $0x10
f0100cb0:	68 11 74 10 f0       	push   $0xf0107411
f0100cb5:	e8 d4 31 00 00       	call   f0103e8e <cprintf>
f0100cba:	83 c4 10             	add    $0x10,%esp
f0100cbd:	eb 95                	jmp    f0100c54 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100cbf:	8d 7e 01             	lea    0x1(%esi),%edi
f0100cc2:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100cc6:	0f b6 03             	movzbl (%ebx),%eax
f0100cc9:	84 c0                	test   %al,%al
f0100ccb:	75 0c                	jne    f0100cd9 <monitor+0xbb>
f0100ccd:	eb b1                	jmp    f0100c80 <monitor+0x62>
			buf++;
f0100ccf:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100cd2:	0f b6 03             	movzbl (%ebx),%eax
f0100cd5:	84 c0                	test   %al,%al
f0100cd7:	74 a7                	je     f0100c80 <monitor+0x62>
f0100cd9:	83 ec 08             	sub    $0x8,%esp
f0100cdc:	0f be c0             	movsbl %al,%eax
f0100cdf:	50                   	push   %eax
f0100ce0:	68 0c 74 10 f0       	push   $0xf010740c
f0100ce5:	e8 21 55 00 00       	call   f010620b <strchr>
f0100cea:	83 c4 10             	add    $0x10,%esp
f0100ced:	85 c0                	test   %eax,%eax
f0100cef:	74 de                	je     f0100ccf <monitor+0xb1>
f0100cf1:	eb 8d                	jmp    f0100c80 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100cf3:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100cfa:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100cfb:	85 f6                	test   %esi,%esi
f0100cfd:	0f 84 51 ff ff ff    	je     f0100c54 <monitor+0x36>
f0100d03:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d08:	83 ec 08             	sub    $0x8,%esp
f0100d0b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100d0e:	ff 34 85 80 76 10 f0 	pushl  -0xfef8980(,%eax,4)
f0100d15:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d18:	e8 6a 54 00 00       	call   f0106187 <strcmp>
f0100d1d:	83 c4 10             	add    $0x10,%esp
f0100d20:	85 c0                	test   %eax,%eax
f0100d22:	75 21                	jne    f0100d45 <monitor+0x127>
			return commands[i].func(argc, argv, tf);
f0100d24:	83 ec 04             	sub    $0x4,%esp
f0100d27:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100d2a:	ff 75 08             	pushl  0x8(%ebp)
f0100d2d:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100d30:	52                   	push   %edx
f0100d31:	56                   	push   %esi
f0100d32:	ff 14 85 88 76 10 f0 	call   *-0xfef8978(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100d39:	83 c4 10             	add    $0x10,%esp
f0100d3c:	85 c0                	test   %eax,%eax
f0100d3e:	78 25                	js     f0100d65 <monitor+0x147>
f0100d40:	e9 0f ff ff ff       	jmp    f0100c54 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100d45:	83 c3 01             	add    $0x1,%ebx
f0100d48:	83 fb 07             	cmp    $0x7,%ebx
f0100d4b:	75 bb                	jne    f0100d08 <monitor+0xea>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100d4d:	83 ec 08             	sub    $0x8,%esp
f0100d50:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d53:	68 2e 74 10 f0       	push   $0xf010742e
f0100d58:	e8 31 31 00 00       	call   f0103e8e <cprintf>
f0100d5d:	83 c4 10             	add    $0x10,%esp
f0100d60:	e9 ef fe ff ff       	jmp    f0100c54 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d68:	5b                   	pop    %ebx
f0100d69:	5e                   	pop    %esi
f0100d6a:	5f                   	pop    %edi
f0100d6b:	5d                   	pop    %ebp
f0100d6c:	c3                   	ret    

f0100d6d <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100d6d:	55                   	push   %ebp
f0100d6e:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100d70:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100d73:	5d                   	pop    %ebp
f0100d74:	c3                   	ret    

f0100d75 <check_continuous>:
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100d75:	8d 4a ff             	lea    -0x1(%edx),%ecx
f0100d78:	85 c9                	test   %ecx,%ecx
f0100d7a:	7e 63                	jle    f0100ddf <check_continuous+0x6a>
	{
		if(tmp == NULL)
f0100d7c:	85 c0                	test   %eax,%eax
f0100d7e:	74 65                	je     f0100de5 <check_continuous+0x70>
	cprintf("check_page() succeeded!\n");
}

static int
check_continuous(struct Page *pp, int num_page)
{
f0100d80:	55                   	push   %ebp
f0100d81:	89 e5                	mov    %esp,%ebp
f0100d83:	57                   	push   %edi
f0100d84:	56                   	push   %esi
f0100d85:	53                   	push   %ebx
	{
		if(tmp == NULL)
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100d86:	8b 08                	mov    (%eax),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d88:	8b 35 b0 1e 24 f0    	mov    0xf0241eb0,%esi
f0100d8e:	89 cb                	mov    %ecx,%ebx
f0100d90:	29 f3                	sub    %esi,%ebx
f0100d92:	c1 fb 03             	sar    $0x3,%ebx
f0100d95:	29 f0                	sub    %esi,%eax
f0100d97:	c1 f8 03             	sar    $0x3,%eax
f0100d9a:	29 c3                	sub    %eax,%ebx
f0100d9c:	c1 e3 0c             	shl    $0xc,%ebx
f0100d9f:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
f0100da5:	75 44                	jne    f0100deb <check_continuous+0x76>
f0100da7:	8d 7a ff             	lea    -0x1(%edx),%edi
f0100daa:	ba 00 00 00 00       	mov    $0x0,%edx
f0100daf:	eb 20                	jmp    f0100dd1 <check_continuous+0x5c>
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
f0100db1:	85 c9                	test   %ecx,%ecx
f0100db3:	74 3d                	je     f0100df2 <check_continuous+0x7d>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100db5:	8b 19                	mov    (%ecx),%ebx
f0100db7:	89 d8                	mov    %ebx,%eax
f0100db9:	29 f0                	sub    %esi,%eax
f0100dbb:	c1 f8 03             	sar    $0x3,%eax
f0100dbe:	29 f1                	sub    %esi,%ecx
f0100dc0:	c1 f9 03             	sar    $0x3,%ecx
f0100dc3:	29 c8                	sub    %ecx,%eax
f0100dc5:	c1 e0 0c             	shl    $0xc,%eax
f0100dc8:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0100dcd:	75 2a                	jne    f0100df9 <check_continuous+0x84>
f0100dcf:	89 d9                	mov    %ebx,%ecx
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100dd1:	83 c2 01             	add    $0x1,%edx
f0100dd4:	39 fa                	cmp    %edi,%edx
f0100dd6:	75 d9                	jne    f0100db1 <check_continuous+0x3c>
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
		}
	}
	return 1;
f0100dd8:	b8 01 00 00 00       	mov    $0x1,%eax
f0100ddd:	eb 1f                	jmp    f0100dfe <check_continuous+0x89>
f0100ddf:	b8 01 00 00 00       	mov    $0x1,%eax
f0100de4:	c3                   	ret    
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
		{
			return 0;
f0100de5:	b8 00 00 00 00       	mov    $0x0,%eax
		{
			return 0;
		}
	}
	return 1;
}
f0100dea:	c3                   	ret    
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
f0100deb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100df0:	eb 0c                	jmp    f0100dfe <check_continuous+0x89>
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
		{
			return 0;
f0100df2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100df7:	eb 05                	jmp    f0100dfe <check_continuous+0x89>
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
f0100df9:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	return 1;
}
f0100dfe:	5b                   	pop    %ebx
f0100dff:	5e                   	pop    %esi
f0100e00:	5f                   	pop    %edi
f0100e01:	5d                   	pop    %ebp
f0100e02:	c3                   	ret    

f0100e03 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100e03:	89 d1                	mov    %edx,%ecx
f0100e05:	c1 e9 16             	shr    $0x16,%ecx
f0100e08:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e0b:	a8 01                	test   $0x1,%al
f0100e0d:	74 52                	je     f0100e61 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e14:	89 c1                	mov    %eax,%ecx
f0100e16:	c1 e9 0c             	shr    $0xc,%ecx
f0100e19:	3b 0d a8 1e 24 f0    	cmp    0xf0241ea8,%ecx
f0100e1f:	72 1b                	jb     f0100e3c <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100e21:	55                   	push   %ebp
f0100e22:	89 e5                	mov    %esp,%ebp
f0100e24:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e27:	50                   	push   %eax
f0100e28:	68 40 70 10 f0       	push   $0xf0107040
f0100e2d:	68 12 04 00 00       	push   $0x412
f0100e32:	68 f5 7d 10 f0       	push   $0xf0107df5
f0100e37:	e8 04 f2 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100e3c:	c1 ea 0c             	shr    $0xc,%edx
f0100e3f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100e45:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e4c:	89 c2                	mov    %eax,%edx
f0100e4e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100e51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e56:	85 d2                	test   %edx,%edx
f0100e58:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e5d:	0f 44 c2             	cmove  %edx,%eax
f0100e60:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100e61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100e66:	c3                   	ret    

f0100e67 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e67:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e69:	83 3d 58 12 24 f0 00 	cmpl   $0x0,0xf0241258
f0100e70:	75 0f                	jne    f0100e81 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e72:	b8 03 40 28 f0       	mov    $0xf0284003,%eax
f0100e77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e7c:	a3 58 12 24 f0       	mov    %eax,0xf0241258
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100e81:	a1 58 12 24 f0       	mov    0xf0241258,%eax
	if (n > 0) {
f0100e86:	85 d2                	test   %edx,%edx
f0100e88:	74 64                	je     f0100eee <boot_alloc+0x87>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e8a:	55                   	push   %ebp
f0100e8b:	89 e5                	mov    %esp,%ebp
f0100e8d:	53                   	push   %ebx
f0100e8e:	83 ec 04             	sub    $0x4,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
	if (n > 0) {
		nextfree += n;
f0100e91:	01 c2                	add    %eax,%edx
f0100e93:	89 15 58 12 24 f0    	mov    %edx,0xf0241258
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e99:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e9f:	77 12                	ja     f0100eb3 <boot_alloc+0x4c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ea1:	52                   	push   %edx
f0100ea2:	68 64 70 10 f0       	push   $0xf0107064
f0100ea7:	6a 6f                	push   $0x6f
f0100ea9:	68 f5 7d 10 f0       	push   $0xf0107df5
f0100eae:	e8 8d f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100eb3:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eb9:	89 cb                	mov    %ecx,%ebx
f0100ebb:	c1 eb 0c             	shr    $0xc,%ebx
f0100ebe:	39 1d a8 1e 24 f0    	cmp    %ebx,0xf0241ea8
f0100ec4:	77 12                	ja     f0100ed8 <boot_alloc+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ec6:	51                   	push   %ecx
f0100ec7:	68 40 70 10 f0       	push   $0xf0107040
f0100ecc:	6a 6f                	push   $0x6f
f0100ece:	68 f5 7d 10 f0       	push   $0xf0107df5
f0100ed3:	e8 68 f1 ff ff       	call   f0100040 <_panic>
		nextfree = ROUNDUP(KADDR(PADDR(nextfree)), PGSIZE);
f0100ed8:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100ede:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ee4:	89 15 58 12 24 f0    	mov    %edx,0xf0241258
	}

	return result;
}
f0100eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100eed:	c9                   	leave  
f0100eee:	f3 c3                	repz ret 

f0100ef0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ef0:	55                   	push   %ebp
f0100ef1:	89 e5                	mov    %esp,%ebp
f0100ef3:	57                   	push   %edi
f0100ef4:	56                   	push   %esi
f0100ef5:	53                   	push   %ebx
f0100ef6:	83 ec 2c             	sub    $0x2c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ef9:	85 c0                	test   %eax,%eax
f0100efb:	0f 85 d0 02 00 00    	jne    f01011d1 <check_page_free_list+0x2e1>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f01:	8b 1d 64 12 24 f0    	mov    0xf0241264,%ebx
f0100f07:	85 db                	test   %ebx,%ebx
f0100f09:	75 6c                	jne    f0100f77 <check_page_free_list+0x87>
		panic("'page_free_list' is a null pointer!");
f0100f0b:	83 ec 04             	sub    $0x4,%esp
f0100f0e:	68 d4 76 10 f0       	push   $0xf01076d4
f0100f13:	68 43 03 00 00       	push   $0x343
f0100f18:	68 f5 7d 10 f0       	push   $0xf0107df5
f0100f1d:	e8 1e f1 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100f22:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f25:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f28:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f2e:	89 c2                	mov    %eax,%edx
f0100f30:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f0100f36:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f3c:	0f 95 c2             	setne  %dl
f0100f3f:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f42:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f46:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f48:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f4c:	8b 00                	mov    (%eax),%eax
f0100f4e:	85 c0                	test   %eax,%eax
f0100f50:	75 dc                	jne    f0100f2e <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100f52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f55:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f61:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f63:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100f66:	89 1d 64 12 24 f0    	mov    %ebx,0xf0241264
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100f6c:	85 db                	test   %ebx,%ebx
f0100f6e:	74 63                	je     f0100fd3 <check_page_free_list+0xe3>
f0100f70:	be 01 00 00 00       	mov    $0x1,%esi
f0100f75:	eb 05                	jmp    f0100f7c <check_page_free_list+0x8c>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f77:	be 00 04 00 00       	mov    $0x400,%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f7c:	89 d8                	mov    %ebx,%eax
f0100f7e:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f0100f84:	c1 f8 03             	sar    $0x3,%eax
f0100f87:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
f0100f8a:	89 c2                	mov    %eax,%edx
f0100f8c:	c1 ea 16             	shr    $0x16,%edx
f0100f8f:	39 d6                	cmp    %edx,%esi
f0100f91:	76 3a                	jbe    f0100fcd <check_page_free_list+0xdd>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f93:	89 c2                	mov    %eax,%edx
f0100f95:	c1 ea 0c             	shr    $0xc,%edx
f0100f98:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f0100f9e:	72 12                	jb     f0100fb2 <check_page_free_list+0xc2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa0:	50                   	push   %eax
f0100fa1:	68 40 70 10 f0       	push   $0xf0107040
f0100fa6:	6a 56                	push   $0x56
f0100fa8:	68 01 7e 10 f0       	push   $0xf0107e01
f0100fad:	e8 8e f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100fb2:	83 ec 04             	sub    $0x4,%esp
f0100fb5:	68 80 00 00 00       	push   $0x80
f0100fba:	68 97 00 00 00       	push   $0x97
f0100fbf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fc4:	50                   	push   %eax
f0100fc5:	e8 9f 52 00 00       	call   f0106269 <memset>
f0100fca:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100fcd:	8b 1b                	mov    (%ebx),%ebx
f0100fcf:	85 db                	test   %ebx,%ebx
f0100fd1:	75 a9                	jne    f0100f7c <check_page_free_list+0x8c>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0100fd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd8:	e8 8a fe ff ff       	call   f0100e67 <boot_alloc>
f0100fdd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fe0:	8b 15 64 12 24 f0    	mov    0xf0241264,%edx
f0100fe6:	85 d2                	test   %edx,%edx
f0100fe8:	0f 84 ad 01 00 00    	je     f010119b <check_page_free_list+0x2ab>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100fee:	8b 0d b0 1e 24 f0    	mov    0xf0241eb0,%ecx
f0100ff4:	39 ca                	cmp    %ecx,%edx
f0100ff6:	72 49                	jb     f0101041 <check_page_free_list+0x151>
		assert(pp < pages + npages);
f0100ff8:	a1 a8 1e 24 f0       	mov    0xf0241ea8,%eax
f0100ffd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101000:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101003:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101006:	39 c2                	cmp    %eax,%edx
f0101008:	73 55                	jae    f010105f <check_page_free_list+0x16f>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010100a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010100d:	89 d0                	mov    %edx,%eax
f010100f:	29 c8                	sub    %ecx,%eax
f0101011:	a8 07                	test   $0x7,%al
f0101013:	75 6c                	jne    f0101081 <check_page_free_list+0x191>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101015:	c1 f8 03             	sar    $0x3,%eax
f0101018:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010101b:	85 c0                	test   %eax,%eax
f010101d:	0f 84 81 00 00 00    	je     f01010a4 <check_page_free_list+0x1b4>
		assert(page2pa(pp) != IOPHYSMEM);
f0101023:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101028:	0f 84 96 00 00 00    	je     f01010c4 <check_page_free_list+0x1d4>
f010102e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101033:	be 00 00 00 00       	mov    $0x0,%esi
f0101038:	e9 a0 00 00 00       	jmp    f01010dd <check_page_free_list+0x1ed>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010103d:	39 ca                	cmp    %ecx,%edx
f010103f:	73 19                	jae    f010105a <check_page_free_list+0x16a>
f0101041:	68 0f 7e 10 f0       	push   $0xf0107e0f
f0101046:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010104b:	68 5e 03 00 00       	push   $0x35e
f0101050:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101055:	e8 e6 ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010105a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010105d:	72 19                	jb     f0101078 <check_page_free_list+0x188>
f010105f:	68 30 7e 10 f0       	push   $0xf0107e30
f0101064:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101069:	68 5f 03 00 00       	push   $0x35f
f010106e:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101073:	e8 c8 ef ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101078:	89 d0                	mov    %edx,%eax
f010107a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010107d:	a8 07                	test   $0x7,%al
f010107f:	74 19                	je     f010109a <check_page_free_list+0x1aa>
f0101081:	68 f8 76 10 f0       	push   $0xf01076f8
f0101086:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010108b:	68 60 03 00 00       	push   $0x360
f0101090:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101095:	e8 a6 ef ff ff       	call   f0100040 <_panic>
f010109a:	c1 f8 03             	sar    $0x3,%eax
f010109d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010a0:	85 c0                	test   %eax,%eax
f01010a2:	75 19                	jne    f01010bd <check_page_free_list+0x1cd>
f01010a4:	68 44 7e 10 f0       	push   $0xf0107e44
f01010a9:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01010ae:	68 63 03 00 00       	push   $0x363
f01010b3:	68 f5 7d 10 f0       	push   $0xf0107df5
f01010b8:	e8 83 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010bd:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010c2:	75 19                	jne    f01010dd <check_page_free_list+0x1ed>
f01010c4:	68 55 7e 10 f0       	push   $0xf0107e55
f01010c9:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01010ce:	68 64 03 00 00       	push   $0x364
f01010d3:	68 f5 7d 10 f0       	push   $0xf0107df5
f01010d8:	e8 63 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01010dd:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01010e2:	75 19                	jne    f01010fd <check_page_free_list+0x20d>
f01010e4:	68 2c 77 10 f0       	push   $0xf010772c
f01010e9:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01010ee:	68 65 03 00 00       	push   $0x365
f01010f3:	68 f5 7d 10 f0       	push   $0xf0107df5
f01010f8:	e8 43 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01010fd:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101102:	75 19                	jne    f010111d <check_page_free_list+0x22d>
f0101104:	68 6e 7e 10 f0       	push   $0xf0107e6e
f0101109:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010110e:	68 66 03 00 00       	push   $0x366
f0101113:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101118:	e8 23 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010111d:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101122:	0f 86 bb 00 00 00    	jbe    f01011e3 <check_page_free_list+0x2f3>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101128:	89 c7                	mov    %eax,%edi
f010112a:	c1 ef 0c             	shr    $0xc,%edi
f010112d:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0101130:	77 12                	ja     f0101144 <check_page_free_list+0x254>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101132:	50                   	push   %eax
f0101133:	68 40 70 10 f0       	push   $0xf0107040
f0101138:	6a 56                	push   $0x56
f010113a:	68 01 7e 10 f0       	push   $0xf0107e01
f010113f:	e8 fc ee ff ff       	call   f0100040 <_panic>
f0101144:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f010114a:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010114d:	0f 86 99 00 00 00    	jbe    f01011ec <check_page_free_list+0x2fc>
f0101153:	68 50 77 10 f0       	push   $0xf0107750
f0101158:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010115d:	68 67 03 00 00       	push   $0x367
f0101162:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101167:	e8 d4 ee ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010116c:	68 88 7e 10 f0       	push   $0xf0107e88
f0101171:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101176:	68 69 03 00 00       	push   $0x369
f010117b:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101180:	e8 bb ee ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101185:	83 c6 01             	add    $0x1,%esi
f0101188:	eb 03                	jmp    f010118d <check_page_free_list+0x29d>
		else
			++nfree_extmem;
f010118a:	83 c3 01             	add    $0x1,%ebx
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010118d:	8b 12                	mov    (%edx),%edx
f010118f:	85 d2                	test   %edx,%edx
f0101191:	0f 85 a6 fe ff ff    	jne    f010103d <check_page_free_list+0x14d>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101197:	85 f6                	test   %esi,%esi
f0101199:	7f 19                	jg     f01011b4 <check_page_free_list+0x2c4>
f010119b:	68 a5 7e 10 f0       	push   $0xf0107ea5
f01011a0:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01011a5:	68 71 03 00 00       	push   $0x371
f01011aa:	68 f5 7d 10 f0       	push   $0xf0107df5
f01011af:	e8 8c ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01011b4:	85 db                	test   %ebx,%ebx
f01011b6:	7f 40                	jg     f01011f8 <check_page_free_list+0x308>
f01011b8:	68 b7 7e 10 f0       	push   $0xf0107eb7
f01011bd:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01011c2:	68 72 03 00 00       	push   $0x372
f01011c7:	68 f5 7d 10 f0       	push   $0xf0107df5
f01011cc:	e8 6f ee ff ff       	call   f0100040 <_panic>
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01011d1:	a1 64 12 24 f0       	mov    0xf0241264,%eax
f01011d6:	85 c0                	test   %eax,%eax
f01011d8:	0f 85 44 fd ff ff    	jne    f0100f22 <check_page_free_list+0x32>
f01011de:	e9 28 fd ff ff       	jmp    f0100f0b <check_page_free_list+0x1b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011e3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011e8:	75 9b                	jne    f0101185 <check_page_free_list+0x295>
f01011ea:	eb 80                	jmp    f010116c <check_page_free_list+0x27c>
f01011ec:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011f1:	75 97                	jne    f010118a <check_page_free_list+0x29a>
f01011f3:	e9 74 ff ff ff       	jmp    f010116c <check_page_free_list+0x27c>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f01011f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011fb:	5b                   	pop    %ebx
f01011fc:	5e                   	pop    %esi
f01011fd:	5f                   	pop    %edi
f01011fe:	5d                   	pop    %ebp
f01011ff:	c3                   	ret    

f0101200 <page_init>:
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
f0101200:	c7 05 64 12 24 f0 00 	movl   $0x0,0xf0241264
f0101207:	00 00 00 
	for (i = 0; i < npages; i++) {
f010120a:	83 3d a8 1e 24 f0 00 	cmpl   $0x0,0xf0241ea8
f0101211:	0f 85 92 00 00 00    	jne    f01012a9 <page_init+0xa9>
			continue;
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f0101217:	c7 05 60 12 24 f0 00 	movl   $0x0,0xf0241260
f010121e:	00 00 00 
f0101221:	c3                   	ret    
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
		pages[i].pp_ref = 0;
f0101222:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0101229:	a1 b0 1e 24 f0       	mov    0xf0241eb0,%eax
f010122e:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
		if (i == 0 || (i >= PGNUM(IOPHYSMEM) && i < PGNUM(PADDR(boot_alloc(0)))) || i == PGNUM(MPENTRY_PADDR)) {
f0101235:	85 db                	test   %ebx,%ebx
f0101237:	74 59                	je     f0101292 <page_init+0x92>
f0101239:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f010123f:	76 32                	jbe    f0101273 <page_init+0x73>
f0101241:	b8 00 00 00 00       	mov    $0x0,%eax
f0101246:	e8 1c fc ff ff       	call   f0100e67 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010124b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101250:	77 15                	ja     f0101267 <page_init+0x67>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101252:	50                   	push   %eax
f0101253:	68 64 70 10 f0       	push   $0xf0107064
f0101258:	68 47 01 00 00       	push   $0x147
f010125d:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101262:	e8 d9 ed ff ff       	call   f0100040 <_panic>
f0101267:	05 00 00 00 10       	add    $0x10000000,%eax
f010126c:	c1 e8 0c             	shr    $0xc,%eax
f010126f:	39 d8                	cmp    %ebx,%eax
f0101271:	77 1f                	ja     f0101292 <page_init+0x92>
f0101273:	83 fb 07             	cmp    $0x7,%ebx
f0101276:	74 1a                	je     f0101292 <page_init+0x92>
			continue;
		}
		pages[i].pp_link = page_free_list;
f0101278:	8b 15 64 12 24 f0    	mov    0xf0241264,%edx
f010127e:	a1 b0 1e 24 f0       	mov    0xf0241eb0,%eax
f0101283:	89 14 30             	mov    %edx,(%eax,%esi,1)
		page_free_list = &pages[i];
f0101286:	03 35 b0 1e 24 f0    	add    0xf0241eb0,%esi
f010128c:	89 35 64 12 24 f0    	mov    %esi,0xf0241264
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
f0101292:	83 c3 01             	add    $0x1,%ebx
f0101295:	39 1d a8 1e 24 f0    	cmp    %ebx,0xf0241ea8
f010129b:	77 85                	ja     f0101222 <page_init+0x22>
			continue;
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f010129d:	c7 05 60 12 24 f0 00 	movl   $0x0,0xf0241260
f01012a4:	00 00 00 
}
f01012a7:	eb 17                	jmp    f01012c0 <page_init+0xc0>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012a9:	55                   	push   %ebp
f01012aa:	89 e5                	mov    %esp,%ebp
f01012ac:	56                   	push   %esi
f01012ad:	53                   	push   %ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
		pages[i].pp_ref = 0;
f01012ae:	a1 b0 1e 24 f0       	mov    0xf0241eb0,%eax
f01012b3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
f01012b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012be:	eb d2                	jmp    f0101292 <page_init+0x92>
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
}
f01012c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012c3:	5b                   	pop    %ebx
f01012c4:	5e                   	pop    %esi
f01012c5:	5d                   	pop    %ebp
f01012c6:	c3                   	ret    

f01012c7 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f01012c7:	55                   	push   %ebp
f01012c8:	89 e5                	mov    %esp,%ebp
f01012ca:	53                   	push   %ebx
f01012cb:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct Page *result = NULL;

	if (page_free_list) {
f01012ce:	8b 1d 64 12 24 f0    	mov    0xf0241264,%ebx
f01012d4:	85 db                	test   %ebx,%ebx
f01012d6:	74 58                	je     f0101330 <page_alloc+0x69>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f01012d8:	8b 03                	mov    (%ebx),%eax
f01012da:	a3 64 12 24 f0       	mov    %eax,0xf0241264
		result->pp_link = NULL;
f01012df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

		if (alloc_flags & ALLOC_ZERO) {
f01012e5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01012e9:	74 45                	je     f0101330 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01012eb:	89 d8                	mov    %ebx,%eax
f01012ed:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f01012f3:	c1 f8 03             	sar    $0x3,%eax
f01012f6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012f9:	89 c2                	mov    %eax,%edx
f01012fb:	c1 ea 0c             	shr    $0xc,%edx
f01012fe:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f0101304:	72 12                	jb     f0101318 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101306:	50                   	push   %eax
f0101307:	68 40 70 10 f0       	push   $0xf0107040
f010130c:	6a 56                	push   $0x56
f010130e:	68 01 7e 10 f0       	push   $0xf0107e01
f0101313:	e8 28 ed ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0101318:	83 ec 04             	sub    $0x4,%esp
f010131b:	68 00 10 00 00       	push   $0x1000
f0101320:	6a 00                	push   $0x0
f0101322:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101327:	50                   	push   %eax
f0101328:	e8 3c 4f 00 00       	call   f0106269 <memset>
f010132d:	83 c4 10             	add    $0x10,%esp
		}
	}

	return result;
}
f0101330:	89 d8                	mov    %ebx,%eax
f0101332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101335:	c9                   	leave  
f0101336:	c3                   	ret    

f0101337 <page_alloc_npages_helper>:

// Helper fucntion for page_alloc_npages()
struct Page *
page_alloc_npages_helper(int alloc_flags, int n, struct Page* list)
{
f0101337:	55                   	push   %ebp
f0101338:	89 e5                	mov    %esp,%ebp
f010133a:	57                   	push   %edi
f010133b:	56                   	push   %esi
f010133c:	53                   	push   %ebx
f010133d:	83 ec 1c             	sub    $0x1c,%esp
f0101340:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Page* tmp = NULL;
	struct Page* result = NULL;
	struct Page* check = NULL;
	int cnt = n;

	if (list && n > 0) {
f0101343:	85 db                	test   %ebx,%ebx
f0101345:	0f 84 35 01 00 00    	je     f0101480 <page_alloc_npages_helper+0x149>
f010134b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010134f:	0f 8e 2b 01 00 00    	jle    f0101480 <page_alloc_npages_helper+0x149>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101355:	a1 b0 1e 24 f0       	mov    0xf0241eb0,%eax
f010135a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010135d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101360:	89 d8                	mov    %ebx,%eax
f0101362:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
			if (!check->pp_link) {
f0101369:	8b 08                	mov    (%eax),%ecx
f010136b:	85 c9                	test   %ecx,%ecx
f010136d:	75 11                	jne    f0101380 <page_alloc_npages_helper+0x49>
f010136f:	8b 5d 10             	mov    0x10(%ebp),%ebx
				// Out of memory
				if (cnt > 1) {
f0101372:	83 fe 01             	cmp    $0x1,%esi
f0101375:	0f 8e 21 01 00 00    	jle    f010149c <page_alloc_npages_helper+0x165>
f010137b:	e9 07 01 00 00       	jmp    f0101487 <page_alloc_npages_helper+0x150>
					return NULL;
				}
			} else if ((page2pa(check) - page2pa(check->pp_link)) != PGSIZE) {
f0101380:	89 c2                	mov    %eax,%edx
f0101382:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101385:	29 fa                	sub    %edi,%edx
f0101387:	c1 fa 03             	sar    $0x3,%edx
f010138a:	89 cb                	mov    %ecx,%ebx
f010138c:	29 fb                	sub    %edi,%ebx
f010138e:	89 df                	mov    %ebx,%edi
f0101390:	c1 ff 03             	sar    $0x3,%edi
f0101393:	29 fa                	sub    %edi,%edx
f0101395:	c1 e2 0c             	shl    $0xc,%edx
				tmp = check;	// Record junction
				result = check->pp_link;
				check = result;
				cnt = n;
f0101398:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f010139e:	0f 45 75 0c          	cmovne 0xc(%ebp),%esi
f01013a2:	89 cb                	mov    %ecx,%ebx
f01013a4:	0f 44 5d 10          	cmove  0x10(%ebp),%ebx
f01013a8:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01013ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01013ae:	0f 45 d8             	cmovne %eax,%ebx
f01013b1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01013b4:	0f 44 c8             	cmove  %eax,%ecx
	int cnt = n;

	if (list && n > 0) {
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
f01013b7:	8b 01                	mov    (%ecx),%eax
f01013b9:	83 ee 01             	sub    $0x1,%esi
f01013bc:	85 f6                	test   %esi,%esi
f01013be:	7e 04                	jle    f01013c4 <page_alloc_npages_helper+0x8d>
f01013c0:	85 c0                	test   %eax,%eax
f01013c2:	75 a5                	jne    f0101369 <page_alloc_npages_helper+0x32>
f01013c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01013c7:	89 c1                	mov    %eax,%ecx
				check = result;
				cnt = n;
			}
		}

		if (!cnt) {
f01013c9:	85 f6                	test   %esi,%esi
f01013cb:	0f 85 bd 00 00 00    	jne    f010148e <page_alloc_npages_helper+0x157>
			if (!tmp) {
f01013d1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01013d4:	85 f6                	test   %esi,%esi
f01013d6:	74 04                	je     f01013dc <page_alloc_npages_helper+0xa5>
				list = check->pp_link;
			} else {
				tmp->pp_link = check->pp_link;
f01013d8:	8b 01                	mov    (%ecx),%eax
f01013da:	89 06                	mov    %eax,(%esi)
			}

			check->pp_link = NULL;
f01013dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

			if (alloc_flags & ALLOC_ZERO) {
f01013e2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013e6:	74 27                	je     f010140f <page_alloc_npages_helper+0xd8>
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f01013e8:	85 db                	test   %ebx,%ebx
f01013ea:	0f 84 a5 00 00 00    	je     f0101495 <page_alloc_npages_helper+0x15e>
f01013f0:	89 d8                	mov    %ebx,%eax
f01013f2:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f01013f8:	c1 f8 03             	sar    $0x3,%eax
f01013fb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013fe:	89 c2                	mov    %eax,%edx
f0101400:	c1 ea 0c             	shr    $0xc,%edx
f0101403:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f0101409:	73 2e                	jae    f0101439 <page_alloc_npages_helper+0x102>
f010140b:	89 de                	mov    %ebx,%esi
f010140d:	eb 3c                	jmp    f010144b <page_alloc_npages_helper+0x114>

			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
f010140f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101414:	85 db                	test   %ebx,%ebx
f0101416:	0f 84 88 00 00 00    	je     f01014a4 <page_alloc_npages_helper+0x16d>
f010141c:	eb 4b                	jmp    f0101469 <page_alloc_npages_helper+0x132>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010141e:	89 f0                	mov    %esi,%eax
f0101420:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f0101426:	c1 f8 03             	sar    $0x3,%eax
f0101429:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010142c:	89 c2                	mov    %eax,%edx
f010142e:	c1 ea 0c             	shr    $0xc,%edx
f0101431:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f0101437:	72 12                	jb     f010144b <page_alloc_npages_helper+0x114>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101439:	50                   	push   %eax
f010143a:	68 40 70 10 f0       	push   $0xf0107040
f010143f:	6a 56                	push   $0x56
f0101441:	68 01 7e 10 f0       	push   $0xf0107e01
f0101446:	e8 f5 eb ff ff       	call   f0100040 <_panic>

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
					memset(page2kva(tmp), 0, PGSIZE);
f010144b:	83 ec 04             	sub    $0x4,%esp
f010144e:	68 00 10 00 00       	push   $0x1000
f0101453:	6a 00                	push   $0x0
f0101455:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010145a:	50                   	push   %eax
f010145b:	e8 09 4e 00 00       	call   f0106269 <memset>
			}

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f0101460:	8b 36                	mov    (%esi),%esi
f0101462:	83 c4 10             	add    $0x10,%esp
f0101465:	85 f6                	test   %esi,%esi
f0101467:	75 b5                	jne    f010141e <page_alloc_npages_helper+0xe7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101469:	ba 00 00 00 00       	mov    $0x0,%edx
f010146e:	eb 02                	jmp    f0101472 <page_alloc_npages_helper+0x13b>
			tmp = result;
			while(tmp) {
				rear = tmp->pp_link;
				tmp->pp_link = head;
				head = tmp;
				tmp = rear;
f0101470:	89 c3                	mov    %eax,%ebx
			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
				rear = tmp->pp_link;
f0101472:	8b 03                	mov    (%ebx),%eax
				tmp->pp_link = head;
f0101474:	89 13                	mov    %edx,(%ebx)
f0101476:	89 da                	mov    %ebx,%edx

			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
f0101478:	85 c0                	test   %eax,%eax
f010147a:	75 f4                	jne    f0101470 <page_alloc_npages_helper+0x139>
f010147c:	89 d8                	mov    %ebx,%eax
f010147e:	eb 24                	jmp    f01014a4 <page_alloc_npages_helper+0x16d>
		} else {
			return NULL;
		}
	}

	return result;
f0101480:	b8 00 00 00 00       	mov    $0x0,%eax
f0101485:	eb 1d                	jmp    f01014a4 <page_alloc_npages_helper+0x16d>

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
			if (!check->pp_link) {
				// Out of memory
				if (cnt > 1) {
					return NULL;
f0101487:	b8 00 00 00 00       	mov    $0x0,%eax
f010148c:	eb 16                	jmp    f01014a4 <page_alloc_npages_helper+0x16d>
				tmp = rear;
			}

			return head;
		} else {
			return NULL;
f010148e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101493:	eb 0f                	jmp    f01014a4 <page_alloc_npages_helper+0x16d>
			}

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f0101495:	b8 00 00 00 00       	mov    $0x0,%eax
f010149a:	eb 08                	jmp    f01014a4 <page_alloc_npages_helper+0x16d>
	int cnt = n;

	if (list && n > 0) {
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
f010149c:	83 ee 01             	sub    $0x1,%esi
f010149f:	e9 25 ff ff ff       	jmp    f01013c9 <page_alloc_npages_helper+0x92>
			return NULL;
		}
	}

	return result;
}
f01014a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014a7:	5b                   	pop    %ebx
f01014a8:	5e                   	pop    %esi
f01014a9:	5f                   	pop    %edi
f01014aa:	5d                   	pop    %ebp
f01014ab:	c3                   	ret    

f01014ac <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f01014ac:	55                   	push   %ebp
f01014ad:	89 e5                	mov    %esp,%ebp
f01014af:	56                   	push   %esi
f01014b0:	53                   	push   %ebx
f01014b1:	8b 75 08             	mov    0x8(%ebp),%esi
f01014b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function
	if (n == 1) {
f01014b7:	83 fb 01             	cmp    $0x1,%ebx
f01014ba:	75 0e                	jne    f01014ca <page_alloc_npages+0x1e>
		return page_alloc(alloc_flags);
f01014bc:	83 ec 0c             	sub    $0xc,%esp
f01014bf:	56                   	push   %esi
f01014c0:	e8 02 fe ff ff       	call   f01012c7 <page_alloc>
f01014c5:	83 c4 10             	add    $0x10,%esp
f01014c8:	eb 2a                	jmp    f01014f4 <page_alloc_npages+0x48>
	}

	struct Page* result;
	if (!(result = page_alloc_npages_helper(alloc_flags, n, chunk_list))) {
f01014ca:	83 ec 04             	sub    $0x4,%esp
f01014cd:	ff 35 60 12 24 f0    	pushl  0xf0241260
f01014d3:	53                   	push   %ebx
f01014d4:	56                   	push   %esi
f01014d5:	e8 5d fe ff ff       	call   f0101337 <page_alloc_npages_helper>
f01014da:	83 c4 10             	add    $0x10,%esp
f01014dd:	85 c0                	test   %eax,%eax
f01014df:	75 13                	jne    f01014f4 <page_alloc_npages+0x48>
		result = page_alloc_npages_helper(alloc_flags, n, page_free_list);
f01014e1:	83 ec 04             	sub    $0x4,%esp
f01014e4:	ff 35 64 12 24 f0    	pushl  0xf0241264
f01014ea:	53                   	push   %ebx
f01014eb:	56                   	push   %esi
f01014ec:	e8 46 fe ff ff       	call   f0101337 <page_alloc_npages_helper>
f01014f1:	83 c4 10             	add    $0x10,%esp
	}

	return result;
}
f01014f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01014f7:	5b                   	pop    %ebx
f01014f8:	5e                   	pop    %esi
f01014f9:	5d                   	pop    %ebp
f01014fa:	c3                   	ret    

f01014fb <page_free_npages>:
//	2. Add the pages to the chunk list
//
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f01014fb:	55                   	push   %ebp
f01014fc:	89 e5                	mov    %esp,%ebp
f01014fe:	53                   	push   %ebx
f01014ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function
	if (!check_continuous(pp, n)) {
f0101502:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101505:	89 d8                	mov    %ebx,%eax
f0101507:	e8 69 f8 ff ff       	call   f0100d75 <check_continuous>
f010150c:	85 c0                	test   %eax,%eax
f010150e:	74 20                	je     f0101530 <page_free_npages+0x35>
		return -1;
	}

	if (chunk_list->pp_link == NULL) {
f0101510:	a1 60 12 24 f0       	mov    0xf0241260,%eax
f0101515:	8b 10                	mov    (%eax),%edx
f0101517:	85 d2                	test   %edx,%edx
f0101519:	75 0b                	jne    f0101526 <page_free_npages+0x2b>
		chunk_list->pp_link = pp;
f010151b:	89 18                	mov    %ebx,(%eax)
			;

		tmp->pp_link = pp;
	}

	return 0;
f010151d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101522:	eb 11                	jmp    f0101535 <page_free_npages+0x3a>
	if (chunk_list->pp_link == NULL) {
		chunk_list->pp_link = pp;
	} else {
		struct Page* tmp = chunk_list->pp_link;

		for (; tmp->pp_link; tmp = tmp->pp_link)
f0101524:	89 c2                	mov    %eax,%edx
f0101526:	8b 02                	mov    (%edx),%eax
f0101528:	85 c0                	test   %eax,%eax
f010152a:	75 f8                	jne    f0101524 <page_free_npages+0x29>
			;

		tmp->pp_link = pp;
f010152c:	89 1a                	mov    %ebx,(%edx)
f010152e:	eb 05                	jmp    f0101535 <page_free_npages+0x3a>
int
page_free_npages(struct Page *pp, int n)
{
	// Fill this function
	if (!check_continuous(pp, n)) {
		return -1;
f0101530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

		tmp->pp_link = pp;
	}

	return 0;
}
f0101535:	5b                   	pop    %ebx
f0101536:	5d                   	pop    %ebp
f0101537:	c3                   	ret    

f0101538 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0101538:	55                   	push   %ebp
f0101539:	89 e5                	mov    %esp,%ebp
f010153b:	83 ec 08             	sub    $0x8,%esp
f010153e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if (!pp->pp_ref) {
f0101541:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101546:	75 0f                	jne    f0101557 <page_free+0x1f>
		pp->pp_link = page_free_list;
f0101548:	8b 15 64 12 24 f0    	mov    0xf0241264,%edx
f010154e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0101550:	a3 64 12 24 f0       	mov    %eax,0xf0241264
f0101555:	eb 10                	jmp    f0101567 <page_free+0x2f>
	} else {
		cprintf("Page free error! pp_ref is not 0!");
f0101557:	83 ec 0c             	sub    $0xc,%esp
f010155a:	68 98 77 10 f0       	push   $0xf0107798
f010155f:	e8 2a 29 00 00       	call   f0103e8e <cprintf>
f0101564:	83 c4 10             	add    $0x10,%esp
	}
}
f0101567:	c9                   	leave  
f0101568:	c3                   	ret    

f0101569 <page_realloc_npages>:
//
#define check_invalid(i) (i == 0 || (i >= IOPHYSMEM && i < PADDR(boot_alloc(0))))

struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f0101569:	55                   	push   %ebp
f010156a:	89 e5                	mov    %esp,%ebp
f010156c:	57                   	push   %edi
f010156d:	56                   	push   %esi
f010156e:	53                   	push   %ebx
f010156f:	83 ec 1c             	sub    $0x1c,%esp
f0101572:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101575:	8b 4d 10             	mov    0x10(%ebp),%ecx
	// Fill this function
	if (!new_n) {
f0101578:	85 c9                	test   %ecx,%ecx
f010157a:	75 16                	jne    f0101592 <page_realloc_npages+0x29>
		page_free_npages(pp, old_n);
f010157c:	ff 75 0c             	pushl  0xc(%ebp)
f010157f:	53                   	push   %ebx
f0101580:	e8 76 ff ff ff       	call   f01014fb <page_free_npages>
f0101585:	83 c4 08             	add    $0x8,%esp
		pp = NULL;
f0101588:	b8 00 00 00 00       	mov    $0x0,%eax
f010158d:	e9 b9 01 00 00       	jmp    f010174b <page_realloc_npages+0x1e2>
	} else if (old_n > new_n) {
f0101592:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
f0101595:	7d 28                	jge    f01015bf <page_realloc_npages+0x56>
		page_free_npages(pp + new_n, old_n - new_n);
f0101597:	8d 34 cd 00 00 00 00 	lea    0x0(,%ecx,8),%esi
f010159e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015a1:	29 c8                	sub    %ecx,%eax
f01015a3:	50                   	push   %eax
f01015a4:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f01015a7:	50                   	push   %eax
f01015a8:	e8 4e ff ff ff       	call   f01014fb <page_free_npages>
		(pp + new_n - 1)->pp_link = NULL;
f01015ad:	c7 44 33 f8 00 00 00 	movl   $0x0,-0x8(%ebx,%esi,1)
f01015b4:	00 
f01015b5:	83 c4 08             	add    $0x8,%esp
f01015b8:	89 d8                	mov    %ebx,%eax
f01015ba:	e9 8c 01 00 00       	jmp    f010174b <page_realloc_npages+0x1e2>
	} else if (old_n < new_n) {
f01015bf:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
f01015c2:	0f 8e 81 01 00 00    	jle    f0101749 <page_realloc_npages+0x1e0>
		int i = 0;

		for (i = old_n; i < new_n; i++) {
			if (!(pp + i < pages + npages	&& (pp + i)->pp_ref == 0)) {//|| check_invalid(PGNUM(pp + i))
f01015c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015cb:	c1 e0 03             	shl    $0x3,%eax
f01015ce:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
f01015d1:	8b 15 b0 1e 24 f0    	mov    0xf0241eb0,%edx
f01015d7:	8b 35 a8 1e 24 f0    	mov    0xf0241ea8,%esi
f01015dd:	8d 34 f2             	lea    (%edx,%esi,8),%esi
f01015e0:	39 f7                	cmp    %esi,%edi
f01015e2:	73 2d                	jae    f0101611 <page_realloc_npages+0xa8>
f01015e4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01015e9:	75 26                	jne    f0101611 <page_realloc_npages+0xa8>
f01015eb:	8d 44 03 08          	lea    0x8(%ebx,%eax,1),%eax
f01015ef:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015f2:	eb 0e                	jmp    f0101602 <page_realloc_npages+0x99>
f01015f4:	39 c6                	cmp    %eax,%esi
f01015f6:	76 19                	jbe    f0101611 <page_realloc_npages+0xa8>
f01015f8:	83 c0 08             	add    $0x8,%eax
f01015fb:	66 83 78 fc 00       	cmpw   $0x0,-0x4(%eax)
f0101600:	75 0f                	jne    f0101611 <page_realloc_npages+0xa8>
		page_free_npages(pp + new_n, old_n - new_n);
		(pp + new_n - 1)->pp_link = NULL;
	} else if (old_n < new_n) {
		int i = 0;

		for (i = old_n; i < new_n; i++) {
f0101602:	83 c2 01             	add    $0x1,%edx
f0101605:	39 d1                	cmp    %edx,%ecx
f0101607:	7f eb                	jg     f01015f4 <page_realloc_npages+0x8b>
			if (!(pp + i < pages + npages	&& (pp + i)->pp_ref == 0)) {//|| check_invalid(PGNUM(pp + i))
				break;
			}
		}

		if (i != new_n) {
f0101609:	39 d1                	cmp    %edx,%ecx
f010160b:	0f 84 9b 00 00 00    	je     f01016ac <page_realloc_npages+0x143>
			struct Page* new_pp = page_alloc_npages(ALLOC_ZERO, new_n);
f0101611:	83 ec 08             	sub    $0x8,%esp
f0101614:	51                   	push   %ecx
f0101615:	6a 01                	push   $0x1
f0101617:	e8 90 fe ff ff       	call   f01014ac <page_alloc_npages>
f010161c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			memmove(page2kva(new_pp), page2kva(pp), old_n * PGSIZE);
f010161f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101622:	c1 e7 0c             	shl    $0xc,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101625:	8b 35 b0 1e 24 f0    	mov    0xf0241eb0,%esi
f010162b:	89 d8                	mov    %ebx,%eax
f010162d:	29 f0                	sub    %esi,%eax
f010162f:	c1 f8 03             	sar    $0x3,%eax
f0101632:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101635:	8b 0d a8 1e 24 f0    	mov    0xf0241ea8,%ecx
f010163b:	89 c2                	mov    %eax,%edx
f010163d:	c1 ea 0c             	shr    $0xc,%edx
f0101640:	83 c4 10             	add    $0x10,%esp
f0101643:	39 ca                	cmp    %ecx,%edx
f0101645:	72 12                	jb     f0101659 <page_realloc_npages+0xf0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101647:	50                   	push   %eax
f0101648:	68 40 70 10 f0       	push   $0xf0107040
f010164d:	6a 56                	push   $0x56
f010164f:	68 01 7e 10 f0       	push   $0xf0107e01
f0101654:	e8 e7 e9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101659:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010165f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101662:	29 f0                	sub    %esi,%eax
f0101664:	c1 f8 03             	sar    $0x3,%eax
f0101667:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010166a:	89 c6                	mov    %eax,%esi
f010166c:	c1 ee 0c             	shr    $0xc,%esi
f010166f:	39 ce                	cmp    %ecx,%esi
f0101671:	72 12                	jb     f0101685 <page_realloc_npages+0x11c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101673:	50                   	push   %eax
f0101674:	68 40 70 10 f0       	push   $0xf0107040
f0101679:	6a 56                	push   $0x56
f010167b:	68 01 7e 10 f0       	push   $0xf0107e01
f0101680:	e8 bb e9 ff ff       	call   f0100040 <_panic>
f0101685:	83 ec 04             	sub    $0x4,%esp
f0101688:	57                   	push   %edi
f0101689:	52                   	push   %edx
f010168a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010168f:	50                   	push   %eax
f0101690:	e8 21 4c 00 00       	call   f01062b6 <memmove>
			page_free_npages(pp, old_n);
f0101695:	83 c4 08             	add    $0x8,%esp
f0101698:	ff 75 0c             	pushl  0xc(%ebp)
f010169b:	53                   	push   %ebx
f010169c:	e8 5a fe ff ff       	call   f01014fb <page_free_npages>
			return new_pp;
f01016a1:	83 c4 10             	add    $0x10,%esp
f01016a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01016a7:	e9 9f 00 00 00       	jmp    f010174b <page_realloc_npages+0x1e2>
		} else {
			struct Page* tmp = page_free_list;
f01016ac:	a1 64 12 24 f0       	mov    0xf0241264,%eax
			for (; tmp >= pp && tmp < pp + new_n; tmp = tmp->pp_link)
f01016b1:	39 c3                	cmp    %eax,%ebx
f01016b3:	77 11                	ja     f01016c6 <page_realloc_npages+0x15d>
f01016b5:	8d 0c d3             	lea    (%ebx,%edx,8),%ecx
f01016b8:	39 c8                	cmp    %ecx,%eax
f01016ba:	73 0a                	jae    f01016c6 <page_realloc_npages+0x15d>
f01016bc:	8b 00                	mov    (%eax),%eax
f01016be:	39 c3                	cmp    %eax,%ebx
f01016c0:	77 04                	ja     f01016c6 <page_realloc_npages+0x15d>
f01016c2:	39 c8                	cmp    %ecx,%eax
f01016c4:	72 f6                	jb     f01016bc <page_realloc_npages+0x153>
				;
			page_free_list = tmp;
f01016c6:	a3 64 12 24 f0       	mov    %eax,0xf0241264

			for (; tmp && tmp->pp_link; tmp = tmp->pp_link) {
f01016cb:	85 c0                	test   %eax,%eax
f01016cd:	74 21                	je     f01016f0 <page_realloc_npages+0x187>
f01016cf:	8b 08                	mov    (%eax),%ecx
f01016d1:	85 c9                	test   %ecx,%ecx
f01016d3:	74 1b                	je     f01016f0 <page_realloc_npages+0x187>
				if (tmp->pp_link >= pp && tmp->pp_link < pp + new_n) {
f01016d5:	8d 34 d3             	lea    (%ebx,%edx,8),%esi
f01016d8:	39 cb                	cmp    %ecx,%ebx
f01016da:	77 08                	ja     f01016e4 <page_realloc_npages+0x17b>
f01016dc:	39 ce                	cmp    %ecx,%esi
f01016de:	76 04                	jbe    f01016e4 <page_realloc_npages+0x17b>
					tmp->pp_link = tmp->pp_link->pp_link;
f01016e0:	8b 09                	mov    (%ecx),%ecx
f01016e2:	89 08                	mov    %ecx,(%eax)
			struct Page* tmp = page_free_list;
			for (; tmp >= pp && tmp < pp + new_n; tmp = tmp->pp_link)
				;
			page_free_list = tmp;

			for (; tmp && tmp->pp_link; tmp = tmp->pp_link) {
f01016e4:	8b 00                	mov    (%eax),%eax
f01016e6:	85 c0                	test   %eax,%eax
f01016e8:	74 06                	je     f01016f0 <page_realloc_npages+0x187>
f01016ea:	8b 08                	mov    (%eax),%ecx
f01016ec:	85 c9                	test   %ecx,%ecx
f01016ee:	75 e8                	jne    f01016d8 <page_realloc_npages+0x16f>
				if (tmp->pp_link >= pp && tmp->pp_link < pp + new_n) {
					tmp->pp_link = tmp->pp_link->pp_link;
				}
			}

			for(tmp = pp, i = 0; i < old_n - 1; tmp = tmp->pp_link, i++ )
f01016f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016f3:	83 e8 01             	sub    $0x1,%eax
f01016f6:	85 c0                	test   %eax,%eax
f01016f8:	7e 18                	jle    f0101712 <page_realloc_npages+0x1a9>
f01016fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016fd:	8d 70 ff             	lea    -0x1(%eax),%esi
f0101700:	89 d8                	mov    %ebx,%eax
f0101702:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101707:	8b 00                	mov    (%eax),%eax
f0101709:	83 c1 01             	add    $0x1,%ecx
f010170c:	39 f1                	cmp    %esi,%ecx
f010170e:	75 f7                	jne    f0101707 <page_realloc_npages+0x19e>
f0101710:	eb 02                	jmp    f0101714 <page_realloc_npages+0x1ab>
f0101712:	89 d8                	mov    %ebx,%eax
				;

			for (i = 0; i < new_n - old_n; i++) {
f0101714:	2b 55 0c             	sub    0xc(%ebp),%edx
f0101717:	85 d2                	test   %edx,%edx
f0101719:	7e 24                	jle    f010173f <page_realloc_npages+0x1d6>
f010171b:	89 f9                	mov    %edi,%ecx
f010171d:	89 d6                	mov    %edx,%esi
f010171f:	03 75 0c             	add    0xc(%ebp),%esi
f0101722:	8d 3c f3             	lea    (%ebx,%esi,8),%edi
				tmp->pp_link = pp + old_n + i;
f0101725:	89 ce                	mov    %ecx,%esi
f0101727:	89 08                	mov    %ecx,(%eax)
f0101729:	83 c1 08             	add    $0x8,%ecx
f010172c:	89 f0                	mov    %esi,%eax
			}

			for(tmp = pp, i = 0; i < old_n - 1; tmp = tmp->pp_link, i++ )
				;

			for (i = 0; i < new_n - old_n; i++) {
f010172e:	39 f9                	cmp    %edi,%ecx
f0101730:	75 f3                	jne    f0101725 <page_realloc_npages+0x1bc>
f0101732:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101735:	8d 84 02 ff ff ff 1f 	lea    0x1fffffff(%edx,%eax,1),%eax
f010173c:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
				tmp->pp_link = pp + old_n + i;
				tmp = tmp->pp_link;
			}
			tmp->pp_link = NULL;
f010173f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

			return pp;
f0101745:	89 d8                	mov    %ebx,%eax
f0101747:	eb 02                	jmp    f010174b <page_realloc_npages+0x1e2>
f0101749:	89 d8                	mov    %ebx,%eax
		}
	}

	return pp;
}
f010174b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010174e:	5b                   	pop    %ebx
f010174f:	5e                   	pop    %esi
f0101750:	5f                   	pop    %edi
f0101751:	5d                   	pop    %ebp
f0101752:	c3                   	ret    

f0101753 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101753:	55                   	push   %ebp
f0101754:	89 e5                	mov    %esp,%ebp
f0101756:	83 ec 08             	sub    $0x8,%esp
f0101759:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010175c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101760:	83 e8 01             	sub    $0x1,%eax
f0101763:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101767:	66 85 c0             	test   %ax,%ax
f010176a:	75 0c                	jne    f0101778 <page_decref+0x25>
		page_free(pp);
f010176c:	83 ec 0c             	sub    $0xc,%esp
f010176f:	52                   	push   %edx
f0101770:	e8 c3 fd ff ff       	call   f0101538 <page_free>
f0101775:	83 c4 10             	add    $0x10,%esp
}
f0101778:	c9                   	leave  
f0101779:	c3                   	ret    

f010177a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010177a:	55                   	push   %ebp
f010177b:	89 e5                	mov    %esp,%ebp
f010177d:	56                   	push   %esi
f010177e:	53                   	push   %ebx
f010177f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	if (!pgdir) {
f0101785:	85 c0                	test   %eax,%eax
f0101787:	75 1a                	jne    f01017a3 <pgdir_walk+0x29>
		cprintf("pgdir no exists.\n");
f0101789:	83 ec 0c             	sub    $0xc,%esp
f010178c:	68 c8 7e 10 f0       	push   $0xf0107ec8
f0101791:	e8 f8 26 00 00       	call   f0103e8e <cprintf>
		return NULL;
f0101796:	83 c4 10             	add    $0x10,%esp
f0101799:	b8 00 00 00 00       	mov    $0x0,%eax
f010179e:	e9 bb 00 00 00       	jmp    f010185e <pgdir_walk+0xe4>
	}

	pde_t *pde = pgdir + PDX(va);
f01017a3:	89 da                	mov    %ebx,%edx
f01017a5:	c1 ea 16             	shr    $0x16,%edx
f01017a8:	8d 34 90             	lea    (%eax,%edx,4),%esi
	pte_t *page_table;

	if (*pde & PTE_P) {
f01017ab:	8b 06                	mov    (%esi),%eax
f01017ad:	a8 01                	test   $0x1,%al
f01017af:	74 39                	je     f01017ea <pgdir_walk+0x70>
		page_table = (pte_t *)KADDR(PTE_ADDR(*pde));
f01017b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017b6:	89 c2                	mov    %eax,%edx
f01017b8:	c1 ea 0c             	shr    $0xc,%edx
f01017bb:	39 15 a8 1e 24 f0    	cmp    %edx,0xf0241ea8
f01017c1:	77 15                	ja     f01017d8 <pgdir_walk+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017c3:	50                   	push   %eax
f01017c4:	68 40 70 10 f0       	push   $0xf0107040
f01017c9:	68 5c 02 00 00       	push   $0x25c
f01017ce:	68 f5 7d 10 f0       	push   $0xf0107df5
f01017d3:	e8 68 e8 ff ff       	call   f0100040 <_panic>
		return page_table + PTX(va);
f01017d8:	c1 eb 0a             	shr    $0xa,%ebx
f01017db:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01017e1:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01017e8:	eb 74                	jmp    f010185e <pgdir_walk+0xe4>
	}

	struct Page *page;
	if (create && (page = page_alloc(ALLOC_ZERO))) {
f01017ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01017ee:	74 62                	je     f0101852 <pgdir_walk+0xd8>
f01017f0:	83 ec 0c             	sub    $0xc,%esp
f01017f3:	6a 01                	push   $0x1
f01017f5:	e8 cd fa ff ff       	call   f01012c7 <page_alloc>
f01017fa:	83 c4 10             	add    $0x10,%esp
f01017fd:	85 c0                	test   %eax,%eax
f01017ff:	74 58                	je     f0101859 <pgdir_walk+0xdf>
		page->pp_ref++;
f0101801:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101806:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f010180c:	c1 f8 03             	sar    $0x3,%eax
f010180f:	c1 e0 0c             	shl    $0xc,%eax
		*pde = page2pa(page) | PTE_P | PTE_W | PTE_U;
f0101812:	89 c2                	mov    %eax,%edx
f0101814:	83 ca 07             	or     $0x7,%edx
f0101817:	89 16                	mov    %edx,(%esi)
f0101819:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010181e:	89 c2                	mov    %eax,%edx
f0101820:	c1 ea 0c             	shr    $0xc,%edx
f0101823:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f0101829:	72 15                	jb     f0101840 <pgdir_walk+0xc6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010182b:	50                   	push   %eax
f010182c:	68 40 70 10 f0       	push   $0xf0107040
f0101831:	68 64 02 00 00       	push   $0x264
f0101836:	68 f5 7d 10 f0       	push   $0xf0107df5
f010183b:	e8 00 e8 ff ff       	call   f0100040 <_panic>
		page_table = (pte_t *)KADDR(PTE_ADDR(*pde));
		return page_table + PTX(va);
f0101840:	c1 eb 0a             	shr    $0xa,%ebx
f0101843:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101849:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101850:	eb 0c                	jmp    f010185e <pgdir_walk+0xe4>
	}

	return NULL;
f0101852:	b8 00 00 00 00       	mov    $0x0,%eax
f0101857:	eb 05                	jmp    f010185e <pgdir_walk+0xe4>
f0101859:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010185e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101861:	5b                   	pop    %ebx
f0101862:	5e                   	pop    %esi
f0101863:	5d                   	pop    %ebp
f0101864:	c3                   	ret    

f0101865 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101865:	55                   	push   %ebp
f0101866:	89 e5                	mov    %esp,%ebp
f0101868:	57                   	push   %edi
f0101869:	56                   	push   %esi
f010186a:	53                   	push   %ebx
f010186b:	83 ec 1c             	sub    $0x1c,%esp
	// Fill this function in
	size_t num = size / PGSIZE;
f010186e:	c1 e9 0c             	shr    $0xc,%ecx
f0101871:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	size_t i;

	for (i = 0; i < num; i++) {
f0101874:	85 c9                	test   %ecx,%ecx
f0101876:	74 45                	je     f01018bd <boot_map_region+0x58>
f0101878:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010187b:	89 d3                	mov    %edx,%ebx
f010187d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101882:	8b 45 08             	mov    0x8(%ebp),%eax
f0101885:	29 d0                	sub    %edx,%eax
f0101887:	89 45 e0             	mov    %eax,-0x20(%ebp)
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa | perm | PTE_P;
f010188a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010188d:	83 c8 01             	or     $0x1,%eax
f0101890:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101893:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101896:	8d 34 18             	lea    (%eax,%ebx,1),%esi
	// Fill this function in
	size_t num = size / PGSIZE;
	size_t i;

	for (i = 0; i < num; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0101899:	83 ec 04             	sub    $0x4,%esp
f010189c:	6a 01                	push   $0x1
f010189e:	53                   	push   %ebx
f010189f:	ff 75 d8             	pushl  -0x28(%ebp)
f01018a2:	e8 d3 fe ff ff       	call   f010177a <pgdir_walk>
		*pte = pa | perm | PTE_P;
f01018a7:	0b 75 dc             	or     -0x24(%ebp),%esi
f01018aa:	89 30                	mov    %esi,(%eax)
		va += PGSIZE;
f01018ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// Fill this function in
	size_t num = size / PGSIZE;
	size_t i;

	for (i = 0; i < num; i++) {
f01018b2:	83 c7 01             	add    $0x1,%edi
f01018b5:	83 c4 10             	add    $0x10,%esp
f01018b8:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
f01018bb:	75 d6                	jne    f0101893 <boot_map_region+0x2e>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f01018bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01018c0:	5b                   	pop    %ebx
f01018c1:	5e                   	pop    %esi
f01018c2:	5f                   	pop    %edi
f01018c3:	5d                   	pop    %ebp
f01018c4:	c3                   	ret    

f01018c5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01018c5:	55                   	push   %ebp
f01018c6:	89 e5                	mov    %esp,%ebp
f01018c8:	53                   	push   %ebx
f01018c9:	83 ec 08             	sub    $0x8,%esp
f01018cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01018cf:	6a 00                	push   $0x0
f01018d1:	ff 75 0c             	pushl  0xc(%ebp)
f01018d4:	ff 75 08             	pushl  0x8(%ebp)
f01018d7:	e8 9e fe ff ff       	call   f010177a <pgdir_walk>
	if (pte && (*pte & PTE_P)) {
f01018dc:	83 c4 10             	add    $0x10,%esp
f01018df:	85 c0                	test   %eax,%eax
f01018e1:	74 37                	je     f010191a <page_lookup+0x55>
f01018e3:	f6 00 01             	testb  $0x1,(%eax)
f01018e6:	74 39                	je     f0101921 <page_lookup+0x5c>
		if (pte_store) {
f01018e8:	85 db                	test   %ebx,%ebx
f01018ea:	74 02                	je     f01018ee <page_lookup+0x29>
			*pte_store = pte;
f01018ec:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018ee:	8b 00                	mov    (%eax),%eax
f01018f0:	c1 e8 0c             	shr    $0xc,%eax
f01018f3:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f01018f9:	72 14                	jb     f010190f <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01018fb:	83 ec 04             	sub    $0x4,%esp
f01018fe:	68 bc 77 10 f0       	push   $0xf01077bc
f0101903:	6a 4f                	push   $0x4f
f0101905:	68 01 7e 10 f0       	push   $0xf0107e01
f010190a:	e8 31 e7 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010190f:	8b 15 b0 1e 24 f0    	mov    0xf0241eb0,%edx
f0101915:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		}
		return pa2page(PTE_ADDR(*pte));
f0101918:	eb 0c                	jmp    f0101926 <page_lookup+0x61>
	}

	return NULL;
f010191a:	b8 00 00 00 00       	mov    $0x0,%eax
f010191f:	eb 05                	jmp    f0101926 <page_lookup+0x61>
f0101921:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101926:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101929:	c9                   	leave  
f010192a:	c3                   	ret    

f010192b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010192b:	55                   	push   %ebp
f010192c:	89 e5                	mov    %esp,%ebp
f010192e:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101931:	e8 ad 4f 00 00       	call   f01068e3 <cpunum>
f0101936:	6b c0 74             	imul   $0x74,%eax,%eax
f0101939:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0101940:	74 16                	je     f0101958 <tlb_invalidate+0x2d>
f0101942:	e8 9c 4f 00 00       	call   f01068e3 <cpunum>
f0101947:	6b c0 74             	imul   $0x74,%eax,%eax
f010194a:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0101950:	8b 55 08             	mov    0x8(%ebp),%edx
f0101953:	39 50 64             	cmp    %edx,0x64(%eax)
f0101956:	75 06                	jne    f010195e <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101958:	8b 45 0c             	mov    0xc(%ebp),%eax
f010195b:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010195e:	c9                   	leave  
f010195f:	c3                   	ret    

f0101960 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101960:	55                   	push   %ebp
f0101961:	89 e5                	mov    %esp,%ebp
f0101963:	57                   	push   %edi
f0101964:	56                   	push   %esi
f0101965:	53                   	push   %ebx
f0101966:	83 ec 20             	sub    $0x20,%esp
f0101969:	8b 75 08             	mov    0x8(%ebp),%esi
f010196c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t *pte;
	struct Page *page = page_lookup(pgdir, va, &pte);
f010196f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101972:	50                   	push   %eax
f0101973:	57                   	push   %edi
f0101974:	56                   	push   %esi
f0101975:	e8 4b ff ff ff       	call   f01018c5 <page_lookup>
	if (page) {
f010197a:	83 c4 10             	add    $0x10,%esp
f010197d:	85 c0                	test   %eax,%eax
f010197f:	74 20                	je     f01019a1 <page_remove+0x41>
f0101981:	89 c3                	mov    %eax,%ebx
		*pte = 0;
f0101983:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101986:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f010198c:	83 ec 08             	sub    $0x8,%esp
f010198f:	57                   	push   %edi
f0101990:	56                   	push   %esi
f0101991:	e8 95 ff ff ff       	call   f010192b <tlb_invalidate>
		page_decref(page);
f0101996:	89 1c 24             	mov    %ebx,(%esp)
f0101999:	e8 b5 fd ff ff       	call   f0101753 <page_decref>
f010199e:	83 c4 10             	add    $0x10,%esp
	}
}
f01019a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01019a4:	5b                   	pop    %ebx
f01019a5:	5e                   	pop    %esi
f01019a6:	5f                   	pop    %edi
f01019a7:	5d                   	pop    %ebp
f01019a8:	c3                   	ret    

f01019a9 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01019a9:	55                   	push   %ebp
f01019aa:	89 e5                	mov    %esp,%ebp
f01019ac:	57                   	push   %edi
f01019ad:	56                   	push   %esi
f01019ae:	53                   	push   %ebx
f01019af:	83 ec 10             	sub    $0x10,%esp
f01019b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01019b5:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01019b8:	6a 01                	push   $0x1
f01019ba:	57                   	push   %edi
f01019bb:	ff 75 08             	pushl  0x8(%ebp)
f01019be:	e8 b7 fd ff ff       	call   f010177a <pgdir_walk>

	if (pte && (*pte & PTE_P)) {
f01019c3:	83 c4 10             	add    $0x10,%esp
f01019c6:	85 c0                	test   %eax,%eax
f01019c8:	74 68                	je     f0101a32 <page_insert+0x89>
f01019ca:	89 c6                	mov    %eax,%esi
f01019cc:	8b 00                	mov    (%eax),%eax
f01019ce:	a8 01                	test   $0x1,%al
f01019d0:	74 3c                	je     f0101a0e <page_insert+0x65>
		if (page2pa(pp) == PTE_ADDR(*pte)) {
f01019d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01019d7:	89 da                	mov    %ebx,%edx
f01019d9:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f01019df:	c1 fa 03             	sar    $0x3,%edx
f01019e2:	c1 e2 0c             	shl    $0xc,%edx
f01019e5:	39 d0                	cmp    %edx,%eax
f01019e7:	75 16                	jne    f01019ff <page_insert+0x56>
			tlb_invalidate(pgdir, va);
f01019e9:	83 ec 08             	sub    $0x8,%esp
f01019ec:	57                   	push   %edi
f01019ed:	ff 75 08             	pushl  0x8(%ebp)
f01019f0:	e8 36 ff ff ff       	call   f010192b <tlb_invalidate>
			pp->pp_ref--;
f01019f5:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01019fa:	83 c4 10             	add    $0x10,%esp
f01019fd:	eb 0f                	jmp    f0101a0e <page_insert+0x65>
		} else {
			page_remove(pgdir, va);
f01019ff:	83 ec 08             	sub    $0x8,%esp
f0101a02:	57                   	push   %edi
f0101a03:	ff 75 08             	pushl  0x8(%ebp)
f0101a06:	e8 55 ff ff ff       	call   f0101960 <page_remove>
f0101a0b:	83 c4 10             	add    $0x10,%esp
		}
	} else if (!pte) {
		return -E_NO_MEM;
	}
	*pte = page2pa(pp) | perm | PTE_P;
f0101a0e:	89 d8                	mov    %ebx,%eax
f0101a10:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f0101a16:	c1 f8 03             	sar    $0x3,%eax
f0101a19:	c1 e0 0c             	shl    $0xc,%eax
f0101a1c:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a1f:	83 ca 01             	or     $0x1,%edx
f0101a22:	09 d0                	or     %edx,%eax
f0101a24:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f0101a26:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f0101a2b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a30:	eb 05                	jmp    f0101a37 <page_insert+0x8e>
			pp->pp_ref--;
		} else {
			page_remove(pgdir, va);
		}
	} else if (!pte) {
		return -E_NO_MEM;
f0101a32:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref++;

	return 0;
}
f0101a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a3a:	5b                   	pop    %ebx
f0101a3b:	5e                   	pop    %esi
f0101a3c:	5f                   	pop    %edi
f0101a3d:	5d                   	pop    %ebp
f0101a3e:	c3                   	ret    

f0101a3f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101a3f:	55                   	push   %ebp
f0101a40:	89 e5                	mov    %esp,%ebp
f0101a42:	57                   	push   %edi
f0101a43:	56                   	push   %esi
f0101a44:	53                   	push   %ebx
f0101a45:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101a48:	6a 15                	push   $0x15
f0101a4a:	e8 bd 22 00 00       	call   f0103d0c <mc146818_read>
f0101a4f:	89 c3                	mov    %eax,%ebx
f0101a51:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101a58:	e8 af 22 00 00       	call   f0103d0c <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101a5d:	c1 e0 08             	shl    $0x8,%eax
f0101a60:	09 d8                	or     %ebx,%eax
f0101a62:	c1 e0 0a             	shl    $0xa,%eax
f0101a65:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101a6b:	85 c0                	test   %eax,%eax
f0101a6d:	0f 48 c2             	cmovs  %edx,%eax
f0101a70:	c1 f8 0c             	sar    $0xc,%eax
f0101a73:	a3 68 12 24 f0       	mov    %eax,0xf0241268
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101a78:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101a7f:	e8 88 22 00 00       	call   f0103d0c <mc146818_read>
f0101a84:	89 c3                	mov    %eax,%ebx
f0101a86:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101a8d:	e8 7a 22 00 00       	call   f0103d0c <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101a92:	c1 e0 08             	shl    $0x8,%eax
f0101a95:	09 d8                	or     %ebx,%eax
f0101a97:	c1 e0 0a             	shl    $0xa,%eax
f0101a9a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101aa0:	83 c4 10             	add    $0x10,%esp
f0101aa3:	85 c0                	test   %eax,%eax
f0101aa5:	0f 48 c2             	cmovs  %edx,%eax
f0101aa8:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101aab:	85 c0                	test   %eax,%eax
f0101aad:	74 0e                	je     f0101abd <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101aaf:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101ab5:	89 15 a8 1e 24 f0    	mov    %edx,0xf0241ea8
f0101abb:	eb 0c                	jmp    f0101ac9 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101abd:	8b 15 68 12 24 f0    	mov    0xf0241268,%edx
f0101ac3:	89 15 a8 1e 24 f0    	mov    %edx,0xf0241ea8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101ac9:	c1 e0 0c             	shl    $0xc,%eax
f0101acc:	c1 e8 0a             	shr    $0xa,%eax
f0101acf:	50                   	push   %eax
f0101ad0:	a1 68 12 24 f0       	mov    0xf0241268,%eax
f0101ad5:	c1 e0 0c             	shl    $0xc,%eax
f0101ad8:	c1 e8 0a             	shr    $0xa,%eax
f0101adb:	50                   	push   %eax
f0101adc:	a1 a8 1e 24 f0       	mov    0xf0241ea8,%eax
f0101ae1:	c1 e0 0c             	shl    $0xc,%eax
f0101ae4:	c1 e8 0a             	shr    $0xa,%eax
f0101ae7:	50                   	push   %eax
f0101ae8:	68 dc 77 10 f0       	push   $0xf01077dc
f0101aed:	e8 9c 23 00 00       	call   f0103e8e <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101af2:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101af7:	e8 6b f3 ff ff       	call   f0100e67 <boot_alloc>
f0101afc:	a3 ac 1e 24 f0       	mov    %eax,0xf0241eac
	memset(kern_pgdir, 0, PGSIZE);
f0101b01:	83 c4 0c             	add    $0xc,%esp
f0101b04:	68 00 10 00 00       	push   $0x1000
f0101b09:	6a 00                	push   $0x0
f0101b0b:	50                   	push   %eax
f0101b0c:	e8 58 47 00 00       	call   f0106269 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101b11:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101b16:	83 c4 10             	add    $0x10,%esp
f0101b19:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b1e:	77 15                	ja     f0101b35 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101b20:	50                   	push   %eax
f0101b21:	68 64 70 10 f0       	push   $0xf0107064
f0101b26:	68 96 00 00 00       	push   $0x96
f0101b2b:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101b30:	e8 0b e5 ff ff       	call   f0100040 <_panic>
f0101b35:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101b3b:	83 ca 05             	or     $0x5,%edx
f0101b3e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = boot_alloc(npages * sizeof(struct Page));
f0101b44:	a1 a8 1e 24 f0       	mov    0xf0241ea8,%eax
f0101b49:	c1 e0 03             	shl    $0x3,%eax
f0101b4c:	e8 16 f3 ff ff       	call   f0100e67 <boot_alloc>
f0101b51:	a3 b0 1e 24 f0       	mov    %eax,0xf0241eb0


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = boot_alloc(NENV * sizeof(struct Env));
f0101b56:	b8 00 00 02 00       	mov    $0x20000,%eax
f0101b5b:	e8 07 f3 ff ff       	call   f0100e67 <boot_alloc>
f0101b60:	a3 6c 12 24 f0       	mov    %eax,0xf024126c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101b65:	e8 96 f6 ff ff       	call   f0101200 <page_init>

	check_page_free_list(1);
f0101b6a:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b6f:	e8 7c f3 ff ff       	call   f0100ef0 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0101b74:	83 3d b0 1e 24 f0 00 	cmpl   $0x0,0xf0241eb0
f0101b7b:	75 17                	jne    f0101b94 <mem_init+0x155>
		panic("'pages' is a null pointer!");
f0101b7d:	83 ec 04             	sub    $0x4,%esp
f0101b80:	68 da 7e 10 f0       	push   $0xf0107eda
f0101b85:	68 83 03 00 00       	push   $0x383
f0101b8a:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101b8f:	e8 ac e4 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101b94:	a1 64 12 24 f0       	mov    0xf0241264,%eax
f0101b99:	85 c0                	test   %eax,%eax
f0101b9b:	74 10                	je     f0101bad <mem_init+0x16e>
f0101b9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101ba2:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101ba5:	8b 00                	mov    (%eax),%eax
f0101ba7:	85 c0                	test   %eax,%eax
f0101ba9:	75 f7                	jne    f0101ba2 <mem_init+0x163>
f0101bab:	eb 05                	jmp    f0101bb2 <mem_init+0x173>
f0101bad:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101bb2:	83 ec 0c             	sub    $0xc,%esp
f0101bb5:	6a 00                	push   $0x0
f0101bb7:	e8 0b f7 ff ff       	call   f01012c7 <page_alloc>
f0101bbc:	89 c7                	mov    %eax,%edi
f0101bbe:	83 c4 10             	add    $0x10,%esp
f0101bc1:	85 c0                	test   %eax,%eax
f0101bc3:	75 19                	jne    f0101bde <mem_init+0x19f>
f0101bc5:	68 f5 7e 10 f0       	push   $0xf0107ef5
f0101bca:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101bcf:	68 8b 03 00 00       	push   $0x38b
f0101bd4:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101bd9:	e8 62 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bde:	83 ec 0c             	sub    $0xc,%esp
f0101be1:	6a 00                	push   $0x0
f0101be3:	e8 df f6 ff ff       	call   f01012c7 <page_alloc>
f0101be8:	89 c6                	mov    %eax,%esi
f0101bea:	83 c4 10             	add    $0x10,%esp
f0101bed:	85 c0                	test   %eax,%eax
f0101bef:	75 19                	jne    f0101c0a <mem_init+0x1cb>
f0101bf1:	68 0b 7f 10 f0       	push   $0xf0107f0b
f0101bf6:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101bfb:	68 8c 03 00 00       	push   $0x38c
f0101c00:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101c05:	e8 36 e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c0a:	83 ec 0c             	sub    $0xc,%esp
f0101c0d:	6a 00                	push   $0x0
f0101c0f:	e8 b3 f6 ff ff       	call   f01012c7 <page_alloc>
f0101c14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c17:	83 c4 10             	add    $0x10,%esp
f0101c1a:	85 c0                	test   %eax,%eax
f0101c1c:	75 19                	jne    f0101c37 <mem_init+0x1f8>
f0101c1e:	68 21 7f 10 f0       	push   $0xf0107f21
f0101c23:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101c28:	68 8d 03 00 00       	push   $0x38d
f0101c2d:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101c32:	e8 09 e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c37:	39 f7                	cmp    %esi,%edi
f0101c39:	75 19                	jne    f0101c54 <mem_init+0x215>
f0101c3b:	68 37 7f 10 f0       	push   $0xf0107f37
f0101c40:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101c45:	68 90 03 00 00       	push   $0x390
f0101c4a:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101c4f:	e8 ec e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c57:	39 c7                	cmp    %eax,%edi
f0101c59:	74 04                	je     f0101c5f <mem_init+0x220>
f0101c5b:	39 c6                	cmp    %eax,%esi
f0101c5d:	75 19                	jne    f0101c78 <mem_init+0x239>
f0101c5f:	68 18 78 10 f0       	push   $0xf0107818
f0101c64:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101c69:	68 91 03 00 00       	push   $0x391
f0101c6e:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101c73:	e8 c8 e3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c78:	8b 0d b0 1e 24 f0    	mov    0xf0241eb0,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101c7e:	8b 15 a8 1e 24 f0    	mov    0xf0241ea8,%edx
f0101c84:	c1 e2 0c             	shl    $0xc,%edx
f0101c87:	89 f8                	mov    %edi,%eax
f0101c89:	29 c8                	sub    %ecx,%eax
f0101c8b:	c1 f8 03             	sar    $0x3,%eax
f0101c8e:	c1 e0 0c             	shl    $0xc,%eax
f0101c91:	39 d0                	cmp    %edx,%eax
f0101c93:	72 19                	jb     f0101cae <mem_init+0x26f>
f0101c95:	68 49 7f 10 f0       	push   $0xf0107f49
f0101c9a:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101c9f:	68 92 03 00 00       	push   $0x392
f0101ca4:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101ca9:	e8 92 e3 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101cae:	89 f0                	mov    %esi,%eax
f0101cb0:	29 c8                	sub    %ecx,%eax
f0101cb2:	c1 f8 03             	sar    $0x3,%eax
f0101cb5:	c1 e0 0c             	shl    $0xc,%eax
f0101cb8:	39 c2                	cmp    %eax,%edx
f0101cba:	77 19                	ja     f0101cd5 <mem_init+0x296>
f0101cbc:	68 66 7f 10 f0       	push   $0xf0107f66
f0101cc1:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101cc6:	68 93 03 00 00       	push   $0x393
f0101ccb:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101cd0:	e8 6b e3 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101cd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd8:	29 c8                	sub    %ecx,%eax
f0101cda:	c1 f8 03             	sar    $0x3,%eax
f0101cdd:	c1 e0 0c             	shl    $0xc,%eax
f0101ce0:	39 c2                	cmp    %eax,%edx
f0101ce2:	77 19                	ja     f0101cfd <mem_init+0x2be>
f0101ce4:	68 83 7f 10 f0       	push   $0xf0107f83
f0101ce9:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101cee:	68 94 03 00 00       	push   $0x394
f0101cf3:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101cf8:	e8 43 e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101cfd:	a1 64 12 24 f0       	mov    0xf0241264,%eax
f0101d02:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101d05:	c7 05 64 12 24 f0 00 	movl   $0x0,0xf0241264
f0101d0c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d0f:	83 ec 0c             	sub    $0xc,%esp
f0101d12:	6a 00                	push   $0x0
f0101d14:	e8 ae f5 ff ff       	call   f01012c7 <page_alloc>
f0101d19:	83 c4 10             	add    $0x10,%esp
f0101d1c:	85 c0                	test   %eax,%eax
f0101d1e:	74 19                	je     f0101d39 <mem_init+0x2fa>
f0101d20:	68 a0 7f 10 f0       	push   $0xf0107fa0
f0101d25:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101d2a:	68 9b 03 00 00       	push   $0x39b
f0101d2f:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101d34:	e8 07 e3 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101d39:	83 ec 0c             	sub    $0xc,%esp
f0101d3c:	57                   	push   %edi
f0101d3d:	e8 f6 f7 ff ff       	call   f0101538 <page_free>
	page_free(pp1);
f0101d42:	89 34 24             	mov    %esi,(%esp)
f0101d45:	e8 ee f7 ff ff       	call   f0101538 <page_free>
	page_free(pp2);
f0101d4a:	83 c4 04             	add    $0x4,%esp
f0101d4d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d50:	e8 e3 f7 ff ff       	call   f0101538 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d5c:	e8 66 f5 ff ff       	call   f01012c7 <page_alloc>
f0101d61:	89 c6                	mov    %eax,%esi
f0101d63:	83 c4 10             	add    $0x10,%esp
f0101d66:	85 c0                	test   %eax,%eax
f0101d68:	75 19                	jne    f0101d83 <mem_init+0x344>
f0101d6a:	68 f5 7e 10 f0       	push   $0xf0107ef5
f0101d6f:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101d74:	68 a2 03 00 00       	push   $0x3a2
f0101d79:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101d7e:	e8 bd e2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d83:	83 ec 0c             	sub    $0xc,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	e8 3a f5 ff ff       	call   f01012c7 <page_alloc>
f0101d8d:	89 c7                	mov    %eax,%edi
f0101d8f:	83 c4 10             	add    $0x10,%esp
f0101d92:	85 c0                	test   %eax,%eax
f0101d94:	75 19                	jne    f0101daf <mem_init+0x370>
f0101d96:	68 0b 7f 10 f0       	push   $0xf0107f0b
f0101d9b:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101da0:	68 a3 03 00 00       	push   $0x3a3
f0101da5:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101daa:	e8 91 e2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101daf:	83 ec 0c             	sub    $0xc,%esp
f0101db2:	6a 00                	push   $0x0
f0101db4:	e8 0e f5 ff ff       	call   f01012c7 <page_alloc>
f0101db9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101dbc:	83 c4 10             	add    $0x10,%esp
f0101dbf:	85 c0                	test   %eax,%eax
f0101dc1:	75 19                	jne    f0101ddc <mem_init+0x39d>
f0101dc3:	68 21 7f 10 f0       	push   $0xf0107f21
f0101dc8:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101dcd:	68 a4 03 00 00       	push   $0x3a4
f0101dd2:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101dd7:	e8 64 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ddc:	39 fe                	cmp    %edi,%esi
f0101dde:	75 19                	jne    f0101df9 <mem_init+0x3ba>
f0101de0:	68 37 7f 10 f0       	push   $0xf0107f37
f0101de5:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101dea:	68 a6 03 00 00       	push   $0x3a6
f0101def:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101df4:	e8 47 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101df9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dfc:	39 c7                	cmp    %eax,%edi
f0101dfe:	74 04                	je     f0101e04 <mem_init+0x3c5>
f0101e00:	39 c6                	cmp    %eax,%esi
f0101e02:	75 19                	jne    f0101e1d <mem_init+0x3de>
f0101e04:	68 18 78 10 f0       	push   $0xf0107818
f0101e09:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101e0e:	68 a7 03 00 00       	push   $0x3a7
f0101e13:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101e18:	e8 23 e2 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101e1d:	83 ec 0c             	sub    $0xc,%esp
f0101e20:	6a 00                	push   $0x0
f0101e22:	e8 a0 f4 ff ff       	call   f01012c7 <page_alloc>
f0101e27:	83 c4 10             	add    $0x10,%esp
f0101e2a:	85 c0                	test   %eax,%eax
f0101e2c:	74 19                	je     f0101e47 <mem_init+0x408>
f0101e2e:	68 a0 7f 10 f0       	push   $0xf0107fa0
f0101e33:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101e38:	68 a8 03 00 00       	push   $0x3a8
f0101e3d:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101e42:	e8 f9 e1 ff ff       	call   f0100040 <_panic>
f0101e47:	89 f0                	mov    %esi,%eax
f0101e49:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f0101e4f:	c1 f8 03             	sar    $0x3,%eax
f0101e52:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e55:	89 c2                	mov    %eax,%edx
f0101e57:	c1 ea 0c             	shr    $0xc,%edx
f0101e5a:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f0101e60:	72 12                	jb     f0101e74 <mem_init+0x435>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e62:	50                   	push   %eax
f0101e63:	68 40 70 10 f0       	push   $0xf0107040
f0101e68:	6a 56                	push   $0x56
f0101e6a:	68 01 7e 10 f0       	push   $0xf0107e01
f0101e6f:	e8 cc e1 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101e74:	83 ec 04             	sub    $0x4,%esp
f0101e77:	68 00 10 00 00       	push   $0x1000
f0101e7c:	6a 01                	push   $0x1
f0101e7e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e83:	50                   	push   %eax
f0101e84:	e8 e0 43 00 00       	call   f0106269 <memset>
	page_free(pp0);
f0101e89:	89 34 24             	mov    %esi,(%esp)
f0101e8c:	e8 a7 f6 ff ff       	call   f0101538 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101e91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101e98:	e8 2a f4 ff ff       	call   f01012c7 <page_alloc>
f0101e9d:	83 c4 10             	add    $0x10,%esp
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	75 19                	jne    f0101ebd <mem_init+0x47e>
f0101ea4:	68 af 7f 10 f0       	push   $0xf0107faf
f0101ea9:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101eae:	68 ad 03 00 00       	push   $0x3ad
f0101eb3:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101eb8:	e8 83 e1 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101ebd:	39 c6                	cmp    %eax,%esi
f0101ebf:	74 19                	je     f0101eda <mem_init+0x49b>
f0101ec1:	68 cd 7f 10 f0       	push   $0xf0107fcd
f0101ec6:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101ecb:	68 ae 03 00 00       	push   $0x3ae
f0101ed0:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101ed5:	e8 66 e1 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101eda:	89 f2                	mov    %esi,%edx
f0101edc:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f0101ee2:	c1 fa 03             	sar    $0x3,%edx
f0101ee5:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ee8:	89 d0                	mov    %edx,%eax
f0101eea:	c1 e8 0c             	shr    $0xc,%eax
f0101eed:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f0101ef3:	72 12                	jb     f0101f07 <mem_init+0x4c8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ef5:	52                   	push   %edx
f0101ef6:	68 40 70 10 f0       	push   $0xf0107040
f0101efb:	6a 56                	push   $0x56
f0101efd:	68 01 7e 10 f0       	push   $0xf0107e01
f0101f02:	e8 39 e1 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101f07:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101f0e:	75 11                	jne    f0101f21 <mem_init+0x4e2>
f0101f10:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f0101f16:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101f1c:	80 38 00             	cmpb   $0x0,(%eax)
f0101f1f:	74 19                	je     f0101f3a <mem_init+0x4fb>
f0101f21:	68 dd 7f 10 f0       	push   $0xf0107fdd
f0101f26:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101f2b:	68 b1 03 00 00       	push   $0x3b1
f0101f30:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101f35:	e8 06 e1 ff ff       	call   f0100040 <_panic>
f0101f3a:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101f3d:	39 d0                	cmp    %edx,%eax
f0101f3f:	75 db                	jne    f0101f1c <mem_init+0x4dd>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101f41:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f44:	a3 64 12 24 f0       	mov    %eax,0xf0241264

	// free the pages we took
	page_free(pp0);
f0101f49:	83 ec 0c             	sub    $0xc,%esp
f0101f4c:	56                   	push   %esi
f0101f4d:	e8 e6 f5 ff ff       	call   f0101538 <page_free>
	page_free(pp1);
f0101f52:	89 3c 24             	mov    %edi,(%esp)
f0101f55:	e8 de f5 ff ff       	call   f0101538 <page_free>
	page_free(pp2);
f0101f5a:	83 c4 04             	add    $0x4,%esp
f0101f5d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f60:	e8 d3 f5 ff ff       	call   f0101538 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f65:	a1 64 12 24 f0       	mov    0xf0241264,%eax
f0101f6a:	83 c4 10             	add    $0x10,%esp
f0101f6d:	85 c0                	test   %eax,%eax
f0101f6f:	74 09                	je     f0101f7a <mem_init+0x53b>
		--nfree;
f0101f71:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f74:	8b 00                	mov    (%eax),%eax
f0101f76:	85 c0                	test   %eax,%eax
f0101f78:	75 f7                	jne    f0101f71 <mem_init+0x532>
		--nfree;
	assert(nfree == 0);
f0101f7a:	85 db                	test   %ebx,%ebx
f0101f7c:	74 19                	je     f0101f97 <mem_init+0x558>
f0101f7e:	68 e7 7f 10 f0       	push   $0xf0107fe7
f0101f83:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101f88:	68 be 03 00 00       	push   $0x3be
f0101f8d:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101f92:	e8 a9 e0 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101f97:	83 ec 0c             	sub    $0xc,%esp
f0101f9a:	68 38 78 10 f0       	push   $0xf0107838
f0101f9f:	e8 ea 1e 00 00       	call   f0103e8e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101fa4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fab:	e8 17 f3 ff ff       	call   f01012c7 <page_alloc>
f0101fb0:	89 c3                	mov    %eax,%ebx
f0101fb2:	83 c4 10             	add    $0x10,%esp
f0101fb5:	85 c0                	test   %eax,%eax
f0101fb7:	75 19                	jne    f0101fd2 <mem_init+0x593>
f0101fb9:	68 f5 7e 10 f0       	push   $0xf0107ef5
f0101fbe:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101fc3:	68 26 04 00 00       	push   $0x426
f0101fc8:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101fcd:	e8 6e e0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101fd2:	83 ec 0c             	sub    $0xc,%esp
f0101fd5:	6a 00                	push   $0x0
f0101fd7:	e8 eb f2 ff ff       	call   f01012c7 <page_alloc>
f0101fdc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fdf:	83 c4 10             	add    $0x10,%esp
f0101fe2:	85 c0                	test   %eax,%eax
f0101fe4:	75 19                	jne    f0101fff <mem_init+0x5c0>
f0101fe6:	68 0b 7f 10 f0       	push   $0xf0107f0b
f0101feb:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0101ff0:	68 27 04 00 00       	push   $0x427
f0101ff5:	68 f5 7d 10 f0       	push   $0xf0107df5
f0101ffa:	e8 41 e0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101fff:	83 ec 0c             	sub    $0xc,%esp
f0102002:	6a 00                	push   $0x0
f0102004:	e8 be f2 ff ff       	call   f01012c7 <page_alloc>
f0102009:	89 c6                	mov    %eax,%esi
f010200b:	83 c4 10             	add    $0x10,%esp
f010200e:	85 c0                	test   %eax,%eax
f0102010:	75 19                	jne    f010202b <mem_init+0x5ec>
f0102012:	68 21 7f 10 f0       	push   $0xf0107f21
f0102017:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010201c:	68 28 04 00 00       	push   $0x428
f0102021:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102026:	e8 15 e0 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010202b:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010202e:	75 19                	jne    f0102049 <mem_init+0x60a>
f0102030:	68 37 7f 10 f0       	push   $0xf0107f37
f0102035:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010203a:	68 2b 04 00 00       	push   $0x42b
f010203f:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102044:	e8 f7 df ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102049:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010204c:	74 04                	je     f0102052 <mem_init+0x613>
f010204e:	39 c3                	cmp    %eax,%ebx
f0102050:	75 19                	jne    f010206b <mem_init+0x62c>
f0102052:	68 18 78 10 f0       	push   $0xf0107818
f0102057:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010205c:	68 2c 04 00 00       	push   $0x42c
f0102061:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102066:	e8 d5 df ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010206b:	a1 64 12 24 f0       	mov    0xf0241264,%eax
f0102070:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0102073:	c7 05 64 12 24 f0 00 	movl   $0x0,0xf0241264
f010207a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010207d:	83 ec 0c             	sub    $0xc,%esp
f0102080:	6a 00                	push   $0x0
f0102082:	e8 40 f2 ff ff       	call   f01012c7 <page_alloc>
f0102087:	83 c4 10             	add    $0x10,%esp
f010208a:	85 c0                	test   %eax,%eax
f010208c:	74 19                	je     f01020a7 <mem_init+0x668>
f010208e:	68 a0 7f 10 f0       	push   $0xf0107fa0
f0102093:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102098:	68 33 04 00 00       	push   $0x433
f010209d:	68 f5 7d 10 f0       	push   $0xf0107df5
f01020a2:	e8 99 df ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01020a7:	83 ec 04             	sub    $0x4,%esp
f01020aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01020ad:	50                   	push   %eax
f01020ae:	6a 00                	push   $0x0
f01020b0:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f01020b6:	e8 0a f8 ff ff       	call   f01018c5 <page_lookup>
f01020bb:	83 c4 10             	add    $0x10,%esp
f01020be:	85 c0                	test   %eax,%eax
f01020c0:	74 19                	je     f01020db <mem_init+0x69c>
f01020c2:	68 58 78 10 f0       	push   $0xf0107858
f01020c7:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01020cc:	68 36 04 00 00       	push   $0x436
f01020d1:	68 f5 7d 10 f0       	push   $0xf0107df5
f01020d6:	e8 65 df ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01020db:	6a 02                	push   $0x2
f01020dd:	6a 00                	push   $0x0
f01020df:	ff 75 d4             	pushl  -0x2c(%ebp)
f01020e2:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f01020e8:	e8 bc f8 ff ff       	call   f01019a9 <page_insert>
f01020ed:	83 c4 10             	add    $0x10,%esp
f01020f0:	85 c0                	test   %eax,%eax
f01020f2:	78 19                	js     f010210d <mem_init+0x6ce>
f01020f4:	68 90 78 10 f0       	push   $0xf0107890
f01020f9:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01020fe:	68 39 04 00 00       	push   $0x439
f0102103:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102108:	e8 33 df ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010210d:	83 ec 0c             	sub    $0xc,%esp
f0102110:	53                   	push   %ebx
f0102111:	e8 22 f4 ff ff       	call   f0101538 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102116:	6a 02                	push   $0x2
f0102118:	6a 00                	push   $0x0
f010211a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010211d:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f0102123:	e8 81 f8 ff ff       	call   f01019a9 <page_insert>
f0102128:	83 c4 20             	add    $0x20,%esp
f010212b:	85 c0                	test   %eax,%eax
f010212d:	74 19                	je     f0102148 <mem_init+0x709>
f010212f:	68 c0 78 10 f0       	push   $0xf01078c0
f0102134:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102139:	68 3d 04 00 00       	push   $0x43d
f010213e:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102143:	e8 f8 de ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102148:	8b 3d ac 1e 24 f0    	mov    0xf0241eac,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010214e:	a1 b0 1e 24 f0       	mov    0xf0241eb0,%eax
f0102153:	89 c1                	mov    %eax,%ecx
f0102155:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102158:	8b 17                	mov    (%edi),%edx
f010215a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102160:	89 d8                	mov    %ebx,%eax
f0102162:	29 c8                	sub    %ecx,%eax
f0102164:	c1 f8 03             	sar    $0x3,%eax
f0102167:	c1 e0 0c             	shl    $0xc,%eax
f010216a:	39 c2                	cmp    %eax,%edx
f010216c:	74 19                	je     f0102187 <mem_init+0x748>
f010216e:	68 f0 78 10 f0       	push   $0xf01078f0
f0102173:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102178:	68 3e 04 00 00       	push   $0x43e
f010217d:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102182:	e8 b9 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102187:	ba 00 00 00 00       	mov    $0x0,%edx
f010218c:	89 f8                	mov    %edi,%eax
f010218e:	e8 70 ec ff ff       	call   f0100e03 <check_va2pa>
f0102193:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102196:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0102199:	c1 fa 03             	sar    $0x3,%edx
f010219c:	c1 e2 0c             	shl    $0xc,%edx
f010219f:	39 d0                	cmp    %edx,%eax
f01021a1:	74 19                	je     f01021bc <mem_init+0x77d>
f01021a3:	68 18 79 10 f0       	push   $0xf0107918
f01021a8:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01021ad:	68 3f 04 00 00       	push   $0x43f
f01021b2:	68 f5 7d 10 f0       	push   $0xf0107df5
f01021b7:	e8 84 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01021bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bf:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021c4:	74 19                	je     f01021df <mem_init+0x7a0>
f01021c6:	68 f2 7f 10 f0       	push   $0xf0107ff2
f01021cb:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01021d0:	68 40 04 00 00       	push   $0x440
f01021d5:	68 f5 7d 10 f0       	push   $0xf0107df5
f01021da:	e8 61 de ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01021df:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021e4:	74 19                	je     f01021ff <mem_init+0x7c0>
f01021e6:	68 03 80 10 f0       	push   $0xf0108003
f01021eb:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01021f0:	68 41 04 00 00       	push   $0x441
f01021f5:	68 f5 7d 10 f0       	push   $0xf0107df5
f01021fa:	e8 41 de ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021ff:	6a 02                	push   $0x2
f0102201:	68 00 10 00 00       	push   $0x1000
f0102206:	56                   	push   %esi
f0102207:	57                   	push   %edi
f0102208:	e8 9c f7 ff ff       	call   f01019a9 <page_insert>
f010220d:	83 c4 10             	add    $0x10,%esp
f0102210:	85 c0                	test   %eax,%eax
f0102212:	74 19                	je     f010222d <mem_init+0x7ee>
f0102214:	68 48 79 10 f0       	push   $0xf0107948
f0102219:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010221e:	68 44 04 00 00       	push   $0x444
f0102223:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102228:	e8 13 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010222d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102232:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f0102237:	e8 c7 eb ff ff       	call   f0100e03 <check_va2pa>
f010223c:	89 f2                	mov    %esi,%edx
f010223e:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f0102244:	c1 fa 03             	sar    $0x3,%edx
f0102247:	c1 e2 0c             	shl    $0xc,%edx
f010224a:	39 d0                	cmp    %edx,%eax
f010224c:	74 19                	je     f0102267 <mem_init+0x828>
f010224e:	68 84 79 10 f0       	push   $0xf0107984
f0102253:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102258:	68 45 04 00 00       	push   $0x445
f010225d:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102262:	e8 d9 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102267:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010226c:	74 19                	je     f0102287 <mem_init+0x848>
f010226e:	68 14 80 10 f0       	push   $0xf0108014
f0102273:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102278:	68 46 04 00 00       	push   $0x446
f010227d:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102282:	e8 b9 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102287:	83 ec 0c             	sub    $0xc,%esp
f010228a:	6a 00                	push   $0x0
f010228c:	e8 36 f0 ff ff       	call   f01012c7 <page_alloc>
f0102291:	83 c4 10             	add    $0x10,%esp
f0102294:	85 c0                	test   %eax,%eax
f0102296:	74 19                	je     f01022b1 <mem_init+0x872>
f0102298:	68 a0 7f 10 f0       	push   $0xf0107fa0
f010229d:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01022a2:	68 49 04 00 00       	push   $0x449
f01022a7:	68 f5 7d 10 f0       	push   $0xf0107df5
f01022ac:	e8 8f dd ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022b1:	6a 02                	push   $0x2
f01022b3:	68 00 10 00 00       	push   $0x1000
f01022b8:	56                   	push   %esi
f01022b9:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f01022bf:	e8 e5 f6 ff ff       	call   f01019a9 <page_insert>
f01022c4:	83 c4 10             	add    $0x10,%esp
f01022c7:	85 c0                	test   %eax,%eax
f01022c9:	74 19                	je     f01022e4 <mem_init+0x8a5>
f01022cb:	68 48 79 10 f0       	push   $0xf0107948
f01022d0:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01022d5:	68 4c 04 00 00       	push   $0x44c
f01022da:	68 f5 7d 10 f0       	push   $0xf0107df5
f01022df:	e8 5c dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022e4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022e9:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f01022ee:	e8 10 eb ff ff       	call   f0100e03 <check_va2pa>
f01022f3:	89 f2                	mov    %esi,%edx
f01022f5:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f01022fb:	c1 fa 03             	sar    $0x3,%edx
f01022fe:	c1 e2 0c             	shl    $0xc,%edx
f0102301:	39 d0                	cmp    %edx,%eax
f0102303:	74 19                	je     f010231e <mem_init+0x8df>
f0102305:	68 84 79 10 f0       	push   $0xf0107984
f010230a:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010230f:	68 4d 04 00 00       	push   $0x44d
f0102314:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102319:	e8 22 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010231e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102323:	74 19                	je     f010233e <mem_init+0x8ff>
f0102325:	68 14 80 10 f0       	push   $0xf0108014
f010232a:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010232f:	68 4e 04 00 00       	push   $0x44e
f0102334:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102339:	e8 02 dd ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010233e:	83 ec 0c             	sub    $0xc,%esp
f0102341:	6a 00                	push   $0x0
f0102343:	e8 7f ef ff ff       	call   f01012c7 <page_alloc>
f0102348:	83 c4 10             	add    $0x10,%esp
f010234b:	85 c0                	test   %eax,%eax
f010234d:	74 19                	je     f0102368 <mem_init+0x929>
f010234f:	68 a0 7f 10 f0       	push   $0xf0107fa0
f0102354:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102359:	68 52 04 00 00       	push   $0x452
f010235e:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102363:	e8 d8 dc ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102368:	8b 15 ac 1e 24 f0    	mov    0xf0241eac,%edx
f010236e:	8b 02                	mov    (%edx),%eax
f0102370:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102375:	89 c1                	mov    %eax,%ecx
f0102377:	c1 e9 0c             	shr    $0xc,%ecx
f010237a:	3b 0d a8 1e 24 f0    	cmp    0xf0241ea8,%ecx
f0102380:	72 15                	jb     f0102397 <mem_init+0x958>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102382:	50                   	push   %eax
f0102383:	68 40 70 10 f0       	push   $0xf0107040
f0102388:	68 55 04 00 00       	push   $0x455
f010238d:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102392:	e8 a9 dc ff ff       	call   f0100040 <_panic>
f0102397:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010239c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010239f:	83 ec 04             	sub    $0x4,%esp
f01023a2:	6a 00                	push   $0x0
f01023a4:	68 00 10 00 00       	push   $0x1000
f01023a9:	52                   	push   %edx
f01023aa:	e8 cb f3 ff ff       	call   f010177a <pgdir_walk>
f01023af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01023b2:	8d 57 04             	lea    0x4(%edi),%edx
f01023b5:	83 c4 10             	add    $0x10,%esp
f01023b8:	39 d0                	cmp    %edx,%eax
f01023ba:	74 19                	je     f01023d5 <mem_init+0x996>
f01023bc:	68 b4 79 10 f0       	push   $0xf01079b4
f01023c1:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01023c6:	68 56 04 00 00       	push   $0x456
f01023cb:	68 f5 7d 10 f0       	push   $0xf0107df5
f01023d0:	e8 6b dc ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023d5:	6a 06                	push   $0x6
f01023d7:	68 00 10 00 00       	push   $0x1000
f01023dc:	56                   	push   %esi
f01023dd:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f01023e3:	e8 c1 f5 ff ff       	call   f01019a9 <page_insert>
f01023e8:	83 c4 10             	add    $0x10,%esp
f01023eb:	85 c0                	test   %eax,%eax
f01023ed:	74 19                	je     f0102408 <mem_init+0x9c9>
f01023ef:	68 f4 79 10 f0       	push   $0xf01079f4
f01023f4:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01023f9:	68 59 04 00 00       	push   $0x459
f01023fe:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102403:	e8 38 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102408:	8b 3d ac 1e 24 f0    	mov    0xf0241eac,%edi
f010240e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102413:	89 f8                	mov    %edi,%eax
f0102415:	e8 e9 e9 ff ff       	call   f0100e03 <check_va2pa>
f010241a:	89 f2                	mov    %esi,%edx
f010241c:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f0102422:	c1 fa 03             	sar    $0x3,%edx
f0102425:	c1 e2 0c             	shl    $0xc,%edx
f0102428:	39 d0                	cmp    %edx,%eax
f010242a:	74 19                	je     f0102445 <mem_init+0xa06>
f010242c:	68 84 79 10 f0       	push   $0xf0107984
f0102431:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102436:	68 5a 04 00 00       	push   $0x45a
f010243b:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102440:	e8 fb db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102445:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010244a:	74 19                	je     f0102465 <mem_init+0xa26>
f010244c:	68 14 80 10 f0       	push   $0xf0108014
f0102451:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102456:	68 5b 04 00 00       	push   $0x45b
f010245b:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102460:	e8 db db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102465:	83 ec 04             	sub    $0x4,%esp
f0102468:	6a 00                	push   $0x0
f010246a:	68 00 10 00 00       	push   $0x1000
f010246f:	57                   	push   %edi
f0102470:	e8 05 f3 ff ff       	call   f010177a <pgdir_walk>
f0102475:	83 c4 10             	add    $0x10,%esp
f0102478:	f6 00 04             	testb  $0x4,(%eax)
f010247b:	75 19                	jne    f0102496 <mem_init+0xa57>
f010247d:	68 34 7a 10 f0       	push   $0xf0107a34
f0102482:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102487:	68 5c 04 00 00       	push   $0x45c
f010248c:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102491:	e8 aa db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102496:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f010249b:	f6 00 04             	testb  $0x4,(%eax)
f010249e:	75 19                	jne    f01024b9 <mem_init+0xa7a>
f01024a0:	68 25 80 10 f0       	push   $0xf0108025
f01024a5:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01024aa:	68 5d 04 00 00       	push   $0x45d
f01024af:	68 f5 7d 10 f0       	push   $0xf0107df5
f01024b4:	e8 87 db ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024b9:	6a 02                	push   $0x2
f01024bb:	68 00 00 40 00       	push   $0x400000
f01024c0:	53                   	push   %ebx
f01024c1:	50                   	push   %eax
f01024c2:	e8 e2 f4 ff ff       	call   f01019a9 <page_insert>
f01024c7:	83 c4 10             	add    $0x10,%esp
f01024ca:	85 c0                	test   %eax,%eax
f01024cc:	78 19                	js     f01024e7 <mem_init+0xaa8>
f01024ce:	68 68 7a 10 f0       	push   $0xf0107a68
f01024d3:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01024d8:	68 60 04 00 00       	push   $0x460
f01024dd:	68 f5 7d 10 f0       	push   $0xf0107df5
f01024e2:	e8 59 db ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024e7:	6a 02                	push   $0x2
f01024e9:	68 00 10 00 00       	push   $0x1000
f01024ee:	ff 75 d4             	pushl  -0x2c(%ebp)
f01024f1:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f01024f7:	e8 ad f4 ff ff       	call   f01019a9 <page_insert>
f01024fc:	83 c4 10             	add    $0x10,%esp
f01024ff:	85 c0                	test   %eax,%eax
f0102501:	74 19                	je     f010251c <mem_init+0xadd>
f0102503:	68 a0 7a 10 f0       	push   $0xf0107aa0
f0102508:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010250d:	68 63 04 00 00       	push   $0x463
f0102512:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102517:	e8 24 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010251c:	83 ec 04             	sub    $0x4,%esp
f010251f:	6a 00                	push   $0x0
f0102521:	68 00 10 00 00       	push   $0x1000
f0102526:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f010252c:	e8 49 f2 ff ff       	call   f010177a <pgdir_walk>
f0102531:	83 c4 10             	add    $0x10,%esp
f0102534:	f6 00 04             	testb  $0x4,(%eax)
f0102537:	74 19                	je     f0102552 <mem_init+0xb13>
f0102539:	68 dc 7a 10 f0       	push   $0xf0107adc
f010253e:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102543:	68 64 04 00 00       	push   $0x464
f0102548:	68 f5 7d 10 f0       	push   $0xf0107df5
f010254d:	e8 ee da ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102552:	8b 3d ac 1e 24 f0    	mov    0xf0241eac,%edi
f0102558:	ba 00 00 00 00       	mov    $0x0,%edx
f010255d:	89 f8                	mov    %edi,%eax
f010255f:	e8 9f e8 ff ff       	call   f0100e03 <check_va2pa>
f0102564:	89 c1                	mov    %eax,%ecx
f0102566:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102569:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010256c:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f0102572:	c1 f8 03             	sar    $0x3,%eax
f0102575:	c1 e0 0c             	shl    $0xc,%eax
f0102578:	39 c1                	cmp    %eax,%ecx
f010257a:	74 19                	je     f0102595 <mem_init+0xb56>
f010257c:	68 14 7b 10 f0       	push   $0xf0107b14
f0102581:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102586:	68 67 04 00 00       	push   $0x467
f010258b:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102590:	e8 ab da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102595:	ba 00 10 00 00       	mov    $0x1000,%edx
f010259a:	89 f8                	mov    %edi,%eax
f010259c:	e8 62 e8 ff ff       	call   f0100e03 <check_va2pa>
f01025a1:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01025a4:	74 19                	je     f01025bf <mem_init+0xb80>
f01025a6:	68 40 7b 10 f0       	push   $0xf0107b40
f01025ab:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01025b0:	68 68 04 00 00       	push   $0x468
f01025b5:	68 f5 7d 10 f0       	push   $0xf0107df5
f01025ba:	e8 81 da ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01025bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025c2:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f01025c7:	74 19                	je     f01025e2 <mem_init+0xba3>
f01025c9:	68 3b 80 10 f0       	push   $0xf010803b
f01025ce:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01025d3:	68 6a 04 00 00       	push   $0x46a
f01025d8:	68 f5 7d 10 f0       	push   $0xf0107df5
f01025dd:	e8 5e da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025e2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025e7:	74 19                	je     f0102602 <mem_init+0xbc3>
f01025e9:	68 4c 80 10 f0       	push   $0xf010804c
f01025ee:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01025f3:	68 6b 04 00 00       	push   $0x46b
f01025f8:	68 f5 7d 10 f0       	push   $0xf0107df5
f01025fd:	e8 3e da ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102602:	83 ec 0c             	sub    $0xc,%esp
f0102605:	6a 00                	push   $0x0
f0102607:	e8 bb ec ff ff       	call   f01012c7 <page_alloc>
f010260c:	83 c4 10             	add    $0x10,%esp
f010260f:	85 c0                	test   %eax,%eax
f0102611:	74 04                	je     f0102617 <mem_init+0xbd8>
f0102613:	39 c6                	cmp    %eax,%esi
f0102615:	74 19                	je     f0102630 <mem_init+0xbf1>
f0102617:	68 70 7b 10 f0       	push   $0xf0107b70
f010261c:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102621:	68 6e 04 00 00       	push   $0x46e
f0102626:	68 f5 7d 10 f0       	push   $0xf0107df5
f010262b:	e8 10 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102630:	83 ec 08             	sub    $0x8,%esp
f0102633:	6a 00                	push   $0x0
f0102635:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f010263b:	e8 20 f3 ff ff       	call   f0101960 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102640:	8b 3d ac 1e 24 f0    	mov    0xf0241eac,%edi
f0102646:	ba 00 00 00 00       	mov    $0x0,%edx
f010264b:	89 f8                	mov    %edi,%eax
f010264d:	e8 b1 e7 ff ff       	call   f0100e03 <check_va2pa>
f0102652:	83 c4 10             	add    $0x10,%esp
f0102655:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102658:	74 19                	je     f0102673 <mem_init+0xc34>
f010265a:	68 94 7b 10 f0       	push   $0xf0107b94
f010265f:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102664:	68 72 04 00 00       	push   $0x472
f0102669:	68 f5 7d 10 f0       	push   $0xf0107df5
f010266e:	e8 cd d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102673:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102678:	89 f8                	mov    %edi,%eax
f010267a:	e8 84 e7 ff ff       	call   f0100e03 <check_va2pa>
f010267f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102682:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f0102688:	c1 fa 03             	sar    $0x3,%edx
f010268b:	c1 e2 0c             	shl    $0xc,%edx
f010268e:	39 d0                	cmp    %edx,%eax
f0102690:	74 19                	je     f01026ab <mem_init+0xc6c>
f0102692:	68 40 7b 10 f0       	push   $0xf0107b40
f0102697:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010269c:	68 73 04 00 00       	push   $0x473
f01026a1:	68 f5 7d 10 f0       	push   $0xf0107df5
f01026a6:	e8 95 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01026ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026ae:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01026b3:	74 19                	je     f01026ce <mem_init+0xc8f>
f01026b5:	68 f2 7f 10 f0       	push   $0xf0107ff2
f01026ba:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01026bf:	68 74 04 00 00       	push   $0x474
f01026c4:	68 f5 7d 10 f0       	push   $0xf0107df5
f01026c9:	e8 72 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026ce:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026d3:	74 19                	je     f01026ee <mem_init+0xcaf>
f01026d5:	68 4c 80 10 f0       	push   $0xf010804c
f01026da:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01026df:	68 75 04 00 00       	push   $0x475
f01026e4:	68 f5 7d 10 f0       	push   $0xf0107df5
f01026e9:	e8 52 d9 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026ee:	83 ec 08             	sub    $0x8,%esp
f01026f1:	68 00 10 00 00       	push   $0x1000
f01026f6:	57                   	push   %edi
f01026f7:	e8 64 f2 ff ff       	call   f0101960 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026fc:	8b 3d ac 1e 24 f0    	mov    0xf0241eac,%edi
f0102702:	ba 00 00 00 00       	mov    $0x0,%edx
f0102707:	89 f8                	mov    %edi,%eax
f0102709:	e8 f5 e6 ff ff       	call   f0100e03 <check_va2pa>
f010270e:	83 c4 10             	add    $0x10,%esp
f0102711:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102714:	74 19                	je     f010272f <mem_init+0xcf0>
f0102716:	68 94 7b 10 f0       	push   $0xf0107b94
f010271b:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102720:	68 79 04 00 00       	push   $0x479
f0102725:	68 f5 7d 10 f0       	push   $0xf0107df5
f010272a:	e8 11 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010272f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102734:	89 f8                	mov    %edi,%eax
f0102736:	e8 c8 e6 ff ff       	call   f0100e03 <check_va2pa>
f010273b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010273e:	74 19                	je     f0102759 <mem_init+0xd1a>
f0102740:	68 b8 7b 10 f0       	push   $0xf0107bb8
f0102745:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010274a:	68 7a 04 00 00       	push   $0x47a
f010274f:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102754:	e8 e7 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102759:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010275c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102761:	74 19                	je     f010277c <mem_init+0xd3d>
f0102763:	68 5d 80 10 f0       	push   $0xf010805d
f0102768:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010276d:	68 7b 04 00 00       	push   $0x47b
f0102772:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102777:	e8 c4 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010277c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102781:	74 19                	je     f010279c <mem_init+0xd5d>
f0102783:	68 4c 80 10 f0       	push   $0xf010804c
f0102788:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010278d:	68 7c 04 00 00       	push   $0x47c
f0102792:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102797:	e8 a4 d8 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010279c:	83 ec 0c             	sub    $0xc,%esp
f010279f:	6a 00                	push   $0x0
f01027a1:	e8 21 eb ff ff       	call   f01012c7 <page_alloc>
f01027a6:	83 c4 10             	add    $0x10,%esp
f01027a9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01027ac:	75 04                	jne    f01027b2 <mem_init+0xd73>
f01027ae:	85 c0                	test   %eax,%eax
f01027b0:	75 19                	jne    f01027cb <mem_init+0xd8c>
f01027b2:	68 e0 7b 10 f0       	push   $0xf0107be0
f01027b7:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01027bc:	68 7f 04 00 00       	push   $0x47f
f01027c1:	68 f5 7d 10 f0       	push   $0xf0107df5
f01027c6:	e8 75 d8 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01027cb:	83 ec 0c             	sub    $0xc,%esp
f01027ce:	6a 00                	push   $0x0
f01027d0:	e8 f2 ea ff ff       	call   f01012c7 <page_alloc>
f01027d5:	83 c4 10             	add    $0x10,%esp
f01027d8:	85 c0                	test   %eax,%eax
f01027da:	74 19                	je     f01027f5 <mem_init+0xdb6>
f01027dc:	68 a0 7f 10 f0       	push   $0xf0107fa0
f01027e1:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01027e6:	68 82 04 00 00       	push   $0x482
f01027eb:	68 f5 7d 10 f0       	push   $0xf0107df5
f01027f0:	e8 4b d8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027f5:	8b 0d ac 1e 24 f0    	mov    0xf0241eac,%ecx
f01027fb:	8b 11                	mov    (%ecx),%edx
f01027fd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102803:	89 d8                	mov    %ebx,%eax
f0102805:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f010280b:	c1 f8 03             	sar    $0x3,%eax
f010280e:	c1 e0 0c             	shl    $0xc,%eax
f0102811:	39 c2                	cmp    %eax,%edx
f0102813:	74 19                	je     f010282e <mem_init+0xdef>
f0102815:	68 f0 78 10 f0       	push   $0xf01078f0
f010281a:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010281f:	68 85 04 00 00       	push   $0x485
f0102824:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102829:	e8 12 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010282e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102834:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102839:	74 19                	je     f0102854 <mem_init+0xe15>
f010283b:	68 03 80 10 f0       	push   $0xf0108003
f0102840:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102845:	68 87 04 00 00       	push   $0x487
f010284a:	68 f5 7d 10 f0       	push   $0xf0107df5
f010284f:	e8 ec d7 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102854:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010285a:	83 ec 0c             	sub    $0xc,%esp
f010285d:	53                   	push   %ebx
f010285e:	e8 d5 ec ff ff       	call   f0101538 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102863:	83 c4 0c             	add    $0xc,%esp
f0102866:	6a 01                	push   $0x1
f0102868:	68 00 10 40 00       	push   $0x401000
f010286d:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f0102873:	e8 02 ef ff ff       	call   f010177a <pgdir_walk>
f0102878:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010287b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010287e:	8b 0d ac 1e 24 f0    	mov    0xf0241eac,%ecx
f0102884:	8b 51 04             	mov    0x4(%ecx),%edx
f0102887:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010288d:	8b 3d a8 1e 24 f0    	mov    0xf0241ea8,%edi
f0102893:	89 d0                	mov    %edx,%eax
f0102895:	c1 e8 0c             	shr    $0xc,%eax
f0102898:	83 c4 10             	add    $0x10,%esp
f010289b:	39 f8                	cmp    %edi,%eax
f010289d:	72 15                	jb     f01028b4 <mem_init+0xe75>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010289f:	52                   	push   %edx
f01028a0:	68 40 70 10 f0       	push   $0xf0107040
f01028a5:	68 8e 04 00 00       	push   $0x48e
f01028aa:	68 f5 7d 10 f0       	push   $0xf0107df5
f01028af:	e8 8c d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028b4:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01028ba:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01028bd:	74 19                	je     f01028d8 <mem_init+0xe99>
f01028bf:	68 6e 80 10 f0       	push   $0xf010806e
f01028c4:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01028c9:	68 8f 04 00 00       	push   $0x48f
f01028ce:	68 f5 7d 10 f0       	push   $0xf0107df5
f01028d3:	e8 68 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01028d8:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01028df:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01028e5:	89 d8                	mov    %ebx,%eax
f01028e7:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f01028ed:	c1 f8 03             	sar    $0x3,%eax
f01028f0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028f3:	89 c2                	mov    %eax,%edx
f01028f5:	c1 ea 0c             	shr    $0xc,%edx
f01028f8:	39 d7                	cmp    %edx,%edi
f01028fa:	77 12                	ja     f010290e <mem_init+0xecf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028fc:	50                   	push   %eax
f01028fd:	68 40 70 10 f0       	push   $0xf0107040
f0102902:	6a 56                	push   $0x56
f0102904:	68 01 7e 10 f0       	push   $0xf0107e01
f0102909:	e8 32 d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010290e:	83 ec 04             	sub    $0x4,%esp
f0102911:	68 00 10 00 00       	push   $0x1000
f0102916:	68 ff 00 00 00       	push   $0xff
f010291b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102920:	50                   	push   %eax
f0102921:	e8 43 39 00 00       	call   f0106269 <memset>
	page_free(pp0);
f0102926:	89 1c 24             	mov    %ebx,(%esp)
f0102929:	e8 0a ec ff ff       	call   f0101538 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010292e:	83 c4 0c             	add    $0xc,%esp
f0102931:	6a 01                	push   $0x1
f0102933:	6a 00                	push   $0x0
f0102935:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f010293b:	e8 3a ee ff ff       	call   f010177a <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102940:	89 da                	mov    %ebx,%edx
f0102942:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f0102948:	c1 fa 03             	sar    $0x3,%edx
f010294b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010294e:	89 d0                	mov    %edx,%eax
f0102950:	c1 e8 0c             	shr    $0xc,%eax
f0102953:	83 c4 10             	add    $0x10,%esp
f0102956:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f010295c:	72 12                	jb     f0102970 <mem_init+0xf31>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010295e:	52                   	push   %edx
f010295f:	68 40 70 10 f0       	push   $0xf0107040
f0102964:	6a 56                	push   $0x56
f0102966:	68 01 7e 10 f0       	push   $0xf0107e01
f010296b:	e8 d0 d6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102970:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102976:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102979:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102980:	75 13                	jne    f0102995 <mem_init+0xf56>
f0102982:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0102988:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f010298e:	8b 08                	mov    (%eax),%ecx
f0102990:	83 e1 01             	and    $0x1,%ecx
f0102993:	74 19                	je     f01029ae <mem_init+0xf6f>
f0102995:	68 86 80 10 f0       	push   $0xf0108086
f010299a:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010299f:	68 99 04 00 00       	push   $0x499
f01029a4:	68 f5 7d 10 f0       	push   $0xf0107df5
f01029a9:	e8 92 d6 ff ff       	call   f0100040 <_panic>
f01029ae:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01029b1:	39 c2                	cmp    %eax,%edx
f01029b3:	75 d9                	jne    f010298e <mem_init+0xf4f>
f01029b5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01029b8:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f01029bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01029c3:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f01029c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029cc:	a3 64 12 24 f0       	mov    %eax,0xf0241264

	// free the pages we took
	page_free(pp0);
f01029d1:	83 ec 0c             	sub    $0xc,%esp
f01029d4:	53                   	push   %ebx
f01029d5:	e8 5e eb ff ff       	call   f0101538 <page_free>
	page_free(pp1);
f01029da:	83 c4 04             	add    $0x4,%esp
f01029dd:	ff 75 d4             	pushl  -0x2c(%ebp)
f01029e0:	e8 53 eb ff ff       	call   f0101538 <page_free>
	page_free(pp2);
f01029e5:	89 34 24             	mov    %esi,(%esp)
f01029e8:	e8 4b eb ff ff       	call   f0101538 <page_free>

	cprintf("check_page() succeeded!\n");
f01029ed:	c7 04 24 9d 80 10 f0 	movl   $0xf010809d,(%esp)
f01029f4:	e8 95 14 00 00       	call   f0103e8e <cprintf>
	char* addr;
	int i;
	pp = pp0 = 0;

	// Allocate two single pages
	pp =  page_alloc(0);
f01029f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a00:	e8 c2 e8 ff ff       	call   f01012c7 <page_alloc>
f0102a05:	89 c3                	mov    %eax,%ebx
	pp0 = page_alloc(0);
f0102a07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a0e:	e8 b4 e8 ff ff       	call   f01012c7 <page_alloc>
f0102a13:	89 c6                	mov    %eax,%esi
	assert(pp != 0);
f0102a15:	83 c4 10             	add    $0x10,%esp
f0102a18:	85 db                	test   %ebx,%ebx
f0102a1a:	75 19                	jne    f0102a35 <mem_init+0xff6>
f0102a1c:	68 b6 80 10 f0       	push   $0xf01080b6
f0102a21:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102a26:	68 c6 04 00 00       	push   $0x4c6
f0102a2b:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102a30:	e8 0b d6 ff ff       	call   f0100040 <_panic>
	assert(pp0 != 0);
f0102a35:	85 c0                	test   %eax,%eax
f0102a37:	75 19                	jne    f0102a52 <mem_init+0x1013>
f0102a39:	68 be 80 10 f0       	push   $0xf01080be
f0102a3e:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102a43:	68 c7 04 00 00       	push   $0x4c7
f0102a48:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102a4d:	e8 ee d5 ff ff       	call   f0100040 <_panic>
	assert(pp != pp0);
f0102a52:	39 c3                	cmp    %eax,%ebx
f0102a54:	75 19                	jne    f0102a6f <mem_init+0x1030>
f0102a56:	68 c7 80 10 f0       	push   $0xf01080c7
f0102a5b:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102a60:	68 c8 04 00 00       	push   $0x4c8
f0102a65:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102a6a:	e8 d1 d5 ff ff       	call   f0100040 <_panic>


	// Free pp and assign four continuous pages
	page_free(pp);
f0102a6f:	83 ec 0c             	sub    $0xc,%esp
f0102a72:	53                   	push   %ebx
f0102a73:	e8 c0 ea ff ff       	call   f0101538 <page_free>
	pp = page_alloc_npages(0, 4);
f0102a78:	83 c4 08             	add    $0x8,%esp
f0102a7b:	6a 04                	push   $0x4
f0102a7d:	6a 00                	push   $0x0
f0102a7f:	e8 28 ea ff ff       	call   f01014ac <page_alloc_npages>
f0102a84:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 4));
f0102a86:	ba 04 00 00 00       	mov    $0x4,%edx
f0102a8b:	e8 e5 e2 ff ff       	call   f0100d75 <check_continuous>
f0102a90:	83 c4 10             	add    $0x10,%esp
f0102a93:	85 c0                	test   %eax,%eax
f0102a95:	75 19                	jne    f0102ab0 <mem_init+0x1071>
f0102a97:	68 d1 80 10 f0       	push   $0xf01080d1
f0102a9c:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102aa1:	68 ce 04 00 00       	push   $0x4ce
f0102aa6:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102aab:	e8 90 d5 ff ff       	call   f0100040 <_panic>

	// Free four continuous pages
	assert(!page_free_npages(pp, 4));
f0102ab0:	83 ec 08             	sub    $0x8,%esp
f0102ab3:	6a 04                	push   $0x4
f0102ab5:	53                   	push   %ebx
f0102ab6:	e8 40 ea ff ff       	call   f01014fb <page_free_npages>
f0102abb:	83 c4 10             	add    $0x10,%esp
f0102abe:	85 c0                	test   %eax,%eax
f0102ac0:	74 19                	je     f0102adb <mem_init+0x109c>
f0102ac2:	68 e9 80 10 f0       	push   $0xf01080e9
f0102ac7:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102acc:	68 d1 04 00 00       	push   $0x4d1
f0102ad1:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102ad6:	e8 65 d5 ff ff       	call   f0100040 <_panic>

	// Free pp and assign eight continuous pages
	pp = page_alloc_npages(0, 8);
f0102adb:	83 ec 08             	sub    $0x8,%esp
f0102ade:	6a 08                	push   $0x8
f0102ae0:	6a 00                	push   $0x0
f0102ae2:	e8 c5 e9 ff ff       	call   f01014ac <page_alloc_npages>
f0102ae7:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 8));
f0102ae9:	ba 08 00 00 00       	mov    $0x8,%edx
f0102aee:	e8 82 e2 ff ff       	call   f0100d75 <check_continuous>
f0102af3:	83 c4 10             	add    $0x10,%esp
f0102af6:	85 c0                	test   %eax,%eax
f0102af8:	75 19                	jne    f0102b13 <mem_init+0x10d4>
f0102afa:	68 02 81 10 f0       	push   $0xf0108102
f0102aff:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102b04:	68 d5 04 00 00       	push   $0x4d5
f0102b09:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102b0e:	e8 2d d5 ff ff       	call   f0100040 <_panic>

	// Free four continuous pages
	assert(!page_free_npages(pp, 8));
f0102b13:	83 ec 08             	sub    $0x8,%esp
f0102b16:	6a 08                	push   $0x8
f0102b18:	53                   	push   %ebx
f0102b19:	e8 dd e9 ff ff       	call   f01014fb <page_free_npages>
f0102b1e:	83 c4 10             	add    $0x10,%esp
f0102b21:	85 c0                	test   %eax,%eax
f0102b23:	74 19                	je     f0102b3e <mem_init+0x10ff>
f0102b25:	68 1a 81 10 f0       	push   $0xf010811a
f0102b2a:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102b2f:	68 d8 04 00 00       	push   $0x4d8
f0102b34:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102b39:	e8 02 d5 ff ff       	call   f0100040 <_panic>


	// Free pp0 and assign four continuous zero pages
	page_free(pp0);
f0102b3e:	83 ec 0c             	sub    $0xc,%esp
f0102b41:	56                   	push   %esi
f0102b42:	e8 f1 e9 ff ff       	call   f0101538 <page_free>
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
f0102b47:	83 c4 08             	add    $0x8,%esp
f0102b4a:	6a 04                	push   $0x4
f0102b4c:	6a 01                	push   $0x1
f0102b4e:	e8 59 e9 ff ff       	call   f01014ac <page_alloc_npages>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b53:	89 c1                	mov    %eax,%ecx
f0102b55:	2b 0d b0 1e 24 f0    	sub    0xf0241eb0,%ecx
f0102b5b:	c1 f9 03             	sar    $0x3,%ecx
f0102b5e:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b61:	89 ca                	mov    %ecx,%edx
f0102b63:	c1 ea 0c             	shr    $0xc,%edx
f0102b66:	83 c4 10             	add    $0x10,%esp
f0102b69:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f0102b6f:	72 12                	jb     f0102b83 <mem_init+0x1144>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b71:	51                   	push   %ecx
f0102b72:	68 40 70 10 f0       	push   $0xf0107040
f0102b77:	6a 56                	push   $0x56
f0102b79:	68 01 7e 10 f0       	push   $0xf0107e01
f0102b7e:	e8 bd d4 ff ff       	call   f0100040 <_panic>
	addr = (char*)page2kva(pp0);

	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0102b83:	80 b9 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%ecx)
f0102b8a:	75 11                	jne    f0102b9d <mem_init+0x115e>
f0102b8c:	8d 91 01 00 00 f0    	lea    -0xfffffff(%ecx),%edx
f0102b92:	81 e9 00 c0 ff 0f    	sub    $0xfffc000,%ecx
f0102b98:	80 3a 00             	cmpb   $0x0,(%edx)
f0102b9b:	74 19                	je     f0102bb6 <mem_init+0x1177>
f0102b9d:	68 33 81 10 f0       	push   $0xf0108133
f0102ba2:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102ba7:	68 e2 04 00 00       	push   $0x4e2
f0102bac:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102bb1:	e8 8a d4 ff ff       	call   f0100040 <_panic>
f0102bb6:	83 c2 01             	add    $0x1,%edx
	page_free(pp0);
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
	addr = (char*)page2kva(pp0);

	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
f0102bb9:	39 ca                	cmp    %ecx,%edx
f0102bbb:	75 db                	jne    f0102b98 <mem_init+0x1159>
		assert(addr[i] == 0);
	}

	// Free pages
	assert(!page_free_npages(pp0, 4));
f0102bbd:	83 ec 08             	sub    $0x8,%esp
f0102bc0:	6a 04                	push   $0x4
f0102bc2:	50                   	push   %eax
f0102bc3:	e8 33 e9 ff ff       	call   f01014fb <page_free_npages>
f0102bc8:	83 c4 10             	add    $0x10,%esp
f0102bcb:	85 c0                	test   %eax,%eax
f0102bcd:	74 19                	je     f0102be8 <mem_init+0x11a9>
f0102bcf:	68 40 81 10 f0       	push   $0xf0108140
f0102bd4:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102bd9:	68 e6 04 00 00       	push   $0x4e6
f0102bde:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102be3:	e8 58 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_n_pages() succeeded!\n");
f0102be8:	83 ec 0c             	sub    $0xc,%esp
f0102beb:	68 5a 81 10 f0       	push   $0xf010815a
f0102bf0:	e8 99 12 00 00       	call   f0103e8e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U);
f0102bf5:	a1 b0 1e 24 f0       	mov    0xf0241eb0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bfa:	83 c4 10             	add    $0x10,%esp
f0102bfd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c02:	77 15                	ja     f0102c19 <mem_init+0x11da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c04:	50                   	push   %eax
f0102c05:	68 64 70 10 f0       	push   $0xf0107064
f0102c0a:	68 bd 00 00 00       	push   $0xbd
f0102c0f:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102c14:	e8 27 d4 ff ff       	call   f0100040 <_panic>
f0102c19:	8b 15 a8 1e 24 f0    	mov    0xf0241ea8,%edx
f0102c1f:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102c26:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102c2c:	83 ec 08             	sub    $0x8,%esp
f0102c2f:	6a 04                	push   $0x4
f0102c31:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c36:	50                   	push   %eax
f0102c37:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c3c:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f0102c41:	e8 1f ec ff ff       	call   f0101865 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U);
f0102c46:	a1 6c 12 24 f0       	mov    0xf024126c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c4b:	83 c4 10             	add    $0x10,%esp
f0102c4e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c53:	77 15                	ja     f0102c6a <mem_init+0x122b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c55:	50                   	push   %eax
f0102c56:	68 64 70 10 f0       	push   $0xf0107064
f0102c5b:	68 c6 00 00 00       	push   $0xc6
f0102c60:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102c65:	e8 d6 d3 ff ff       	call   f0100040 <_panic>
f0102c6a:	83 ec 08             	sub    $0x8,%esp
f0102c6d:	6a 04                	push   $0x4
f0102c6f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c74:	50                   	push   %eax
f0102c75:	b9 00 00 02 00       	mov    $0x20000,%ecx
f0102c7a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c7f:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f0102c84:	e8 dc eb ff ff       	call   f0101865 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c89:	83 c4 10             	add    $0x10,%esp
f0102c8c:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102c91:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c96:	77 15                	ja     f0102cad <mem_init+0x126e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c98:	50                   	push   %eax
f0102c99:	68 64 70 10 f0       	push   $0xf0107064
f0102c9e:	68 d3 00 00 00       	push   $0xd3
f0102ca3:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102ca8:	e8 93 d3 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102cad:	83 ec 08             	sub    $0x8,%esp
f0102cb0:	6a 02                	push   $0x2
f0102cb2:	68 00 80 11 00       	push   $0x118000
f0102cb7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cbc:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102cc1:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f0102cc6:	e8 9a eb ff ff       	call   f0101865 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, ~KERNBASE + 1, 0, PTE_W);
f0102ccb:	83 c4 08             	add    $0x8,%esp
f0102cce:	6a 02                	push   $0x2
f0102cd0:	6a 00                	push   $0x0
f0102cd2:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102cd7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102cdc:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f0102ce1:	e8 7f eb ff ff       	call   f0101865 <boot_map_region>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f0102ce6:	83 c4 08             	add    $0x8,%esp
f0102ce9:	6a 02                	push   $0x2
f0102ceb:	68 00 00 00 fe       	push   $0xfe000000
f0102cf0:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f0102cf5:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f0102cfa:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f0102cff:	e8 61 eb ff ff       	call   f0101865 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d04:	83 c4 10             	add    $0x10,%esp
f0102d07:	b8 00 30 24 f0       	mov    $0xf0243000,%eax
f0102d0c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d11:	0f 87 a0 06 00 00    	ja     f01033b7 <mem_init+0x1978>
f0102d17:	eb 0c                	jmp    f0102d25 <mem_init+0x12e6>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	size_t i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir, KSTACKTOP_I(i), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102d19:	89 d8                	mov    %ebx,%eax
f0102d1b:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d21:	77 1c                	ja     f0102d3f <mem_init+0x1300>
f0102d23:	eb 05                	jmp    f0102d2a <mem_init+0x12eb>
f0102d25:	b8 00 30 24 f0       	mov    $0xf0243000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d2a:	50                   	push   %eax
f0102d2b:	68 64 70 10 f0       	push   $0xf0107064
f0102d30:	68 1b 01 00 00       	push   $0x11b
f0102d35:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102d3a:	e8 01 d3 ff ff       	call   f0100040 <_panic>
f0102d3f:	83 ec 08             	sub    $0x8,%esp
f0102d42:	6a 02                	push   $0x2
f0102d44:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102d4a:	50                   	push   %eax
f0102d4b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d50:	89 f2                	mov    %esi,%edx
f0102d52:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f0102d57:	e8 09 eb ff ff       	call   f0101865 <boot_map_region>
f0102d5c:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d62:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	size_t i;
	for (i = 0; i < NCPU; i++) {
f0102d68:	83 c4 10             	add    $0x10,%esp
f0102d6b:	b8 00 30 28 f0       	mov    $0xf0283000,%eax
f0102d70:	39 d8                	cmp    %ebx,%eax
f0102d72:	75 a5                	jne    f0102d19 <mem_init+0x12da>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d74:	8b 3d ac 1e 24 f0    	mov    0xf0241eac,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0102d7a:	a1 a8 1e 24 f0       	mov    0xf0241ea8,%eax
f0102d7f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102d82:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d89:	8b 35 b0 1e 24 f0    	mov    0xf0241eb0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d8f:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102d92:	bb 00 00 00 00       	mov    $0x0,%ebx

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102d9f:	75 10                	jne    f0102db1 <mem_init+0x1372>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102da1:	8b 35 6c 12 24 f0    	mov    0xf024126c,%esi
f0102da7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102daa:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102daf:	eb 5c                	jmp    f0102e0d <mem_init+0x13ce>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102db1:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102db7:	89 f8                	mov    %edi,%eax
f0102db9:	e8 45 e0 ff ff       	call   f0100e03 <check_va2pa>
f0102dbe:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102dc5:	77 15                	ja     f0102ddc <mem_init+0x139d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dc7:	56                   	push   %esi
f0102dc8:	68 64 70 10 f0       	push   $0xf0107064
f0102dcd:	68 d6 03 00 00       	push   $0x3d6
f0102dd2:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102dd7:	e8 64 d2 ff ff       	call   f0100040 <_panic>
f0102ddc:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102de3:	39 c2                	cmp    %eax,%edx
f0102de5:	74 19                	je     f0102e00 <mem_init+0x13c1>
f0102de7:	68 04 7c 10 f0       	push   $0xf0107c04
f0102dec:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102df1:	68 d6 03 00 00       	push   $0x3d6
f0102df6:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102dfb:	e8 40 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e00:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e06:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102e09:	77 a6                	ja     f0102db1 <mem_init+0x1372>
f0102e0b:	eb 94                	jmp    f0102da1 <mem_init+0x1362>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e0d:	89 da                	mov    %ebx,%edx
f0102e0f:	89 f8                	mov    %edi,%eax
f0102e11:	e8 ed df ff ff       	call   f0100e03 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e16:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102e1d:	77 15                	ja     f0102e34 <mem_init+0x13f5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e1f:	56                   	push   %esi
f0102e20:	68 64 70 10 f0       	push   $0xf0107064
f0102e25:	68 db 03 00 00       	push   $0x3db
f0102e2a:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102e2f:	e8 0c d2 ff ff       	call   f0100040 <_panic>
f0102e34:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102e3b:	39 c2                	cmp    %eax,%edx
f0102e3d:	74 19                	je     f0102e58 <mem_init+0x1419>
f0102e3f:	68 38 7c 10 f0       	push   $0xf0107c38
f0102e44:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102e49:	68 db 03 00 00       	push   $0x3db
f0102e4e:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102e53:	e8 e8 d1 ff ff       	call   f0100040 <_panic>
f0102e58:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e5e:	81 fb 00 00 c2 ee    	cmp    $0xeec20000,%ebx
f0102e64:	75 a7                	jne    f0102e0d <mem_init+0x13ce>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e66:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102e69:	c1 e6 0c             	shl    $0xc,%esi
f0102e6c:	85 f6                	test   %esi,%esi
f0102e6e:	74 40                	je     f0102eb0 <mem_init+0x1471>
f0102e70:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e75:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102e7b:	89 f8                	mov    %edi,%eax
f0102e7d:	e8 81 df ff ff       	call   f0100e03 <check_va2pa>
f0102e82:	39 d8                	cmp    %ebx,%eax
f0102e84:	74 19                	je     f0102e9f <mem_init+0x1460>
f0102e86:	68 6c 7c 10 f0       	push   $0xf0107c6c
f0102e8b:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102e90:	68 df 03 00 00       	push   $0x3df
f0102e95:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102e9a:	e8 a1 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e9f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ea5:	39 de                	cmp    %ebx,%esi
f0102ea7:	77 cc                	ja     f0102e75 <mem_init+0x1436>
f0102ea9:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
f0102eae:	eb 05                	jmp    f0102eb5 <mem_init+0x1476>
f0102eb0:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0102eb5:	89 da                	mov    %ebx,%edx
f0102eb7:	89 f8                	mov    %edi,%eax
f0102eb9:	e8 45 df ff ff       	call   f0100e03 <check_va2pa>
f0102ebe:	39 d8                	cmp    %ebx,%eax
f0102ec0:	74 19                	je     f0102edb <mem_init+0x149c>
f0102ec2:	68 76 81 10 f0       	push   $0xf0108176
f0102ec7:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102ecc:	68 e3 03 00 00       	push   $0x3e3
f0102ed1:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102ed6:	e8 65 d1 ff ff       	call   f0100040 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0102edb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ee1:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0102ee7:	75 cc                	jne    f0102eb5 <mem_init+0x1476>
f0102ee9:	be 00 30 24 f0       	mov    $0xf0243000,%esi
f0102eee:	c7 45 cc 00 80 bf ef 	movl   $0xefbf8000,-0x34(%ebp)
f0102ef5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102ef8:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102efe:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102f01:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102f03:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102f06:	05 00 80 40 20       	add    $0x20408000,%eax
f0102f0b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f0e:	89 da                	mov    %ebx,%edx
f0102f10:	89 f8                	mov    %edi,%eax
f0102f12:	e8 ec de ff ff       	call   f0100e03 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f17:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102f1d:	77 15                	ja     f0102f34 <mem_init+0x14f5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f1f:	56                   	push   %esi
f0102f20:	68 64 70 10 f0       	push   $0xf0107064
f0102f25:	68 eb 03 00 00       	push   $0x3eb
f0102f2a:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102f2f:	e8 0c d1 ff ff       	call   f0100040 <_panic>
f0102f34:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f37:	8d 94 0b 00 30 24 f0 	lea    -0xfdbd000(%ebx,%ecx,1),%edx
f0102f3e:	39 c2                	cmp    %eax,%edx
f0102f40:	74 19                	je     f0102f5b <mem_init+0x151c>
f0102f42:	68 94 7c 10 f0       	push   $0xf0107c94
f0102f47:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102f4c:	68 eb 03 00 00       	push   $0x3eb
f0102f51:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102f56:	e8 e5 d0 ff ff       	call   f0100040 <_panic>
f0102f5b:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f61:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102f64:	75 a8                	jne    f0102f0e <mem_init+0x14cf>
f0102f66:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102f69:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102f6f:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102f72:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f74:	89 da                	mov    %ebx,%edx
f0102f76:	89 f8                	mov    %edi,%eax
f0102f78:	e8 86 de ff ff       	call   f0100e03 <check_va2pa>
f0102f7d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f80:	74 19                	je     f0102f9b <mem_init+0x155c>
f0102f82:	68 dc 7c 10 f0       	push   $0xf0107cdc
f0102f87:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102f8c:	68 ed 03 00 00       	push   $0x3ed
f0102f91:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102f96:	e8 a5 d0 ff ff       	call   f0100040 <_panic>
f0102f9b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102fa1:	39 f3                	cmp    %esi,%ebx
f0102fa3:	75 cf                	jne    f0102f74 <mem_init+0x1535>
f0102fa5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102fa8:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102faf:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102fb6:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102fbc:	b8 00 30 28 f0       	mov    $0xf0283000,%eax
f0102fc1:	39 f0                	cmp    %esi,%eax
f0102fc3:	0f 85 2c ff ff ff    	jne    f0102ef5 <mem_init+0x14b6>
f0102fc9:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102fce:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102fd4:	83 fa 03             	cmp    $0x3,%edx
f0102fd7:	77 1f                	ja     f0102ff8 <mem_init+0x15b9>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102fd9:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102fdd:	75 7e                	jne    f010305d <mem_init+0x161e>
f0102fdf:	68 91 81 10 f0       	push   $0xf0108191
f0102fe4:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0102fe9:	68 f7 03 00 00       	push   $0x3f7
f0102fee:	68 f5 7d 10 f0       	push   $0xf0107df5
f0102ff3:	e8 48 d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102ff8:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ffd:	76 3f                	jbe    f010303e <mem_init+0x15ff>
				assert(pgdir[i] & PTE_P);
f0102fff:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103002:	f6 c2 01             	test   $0x1,%dl
f0103005:	75 19                	jne    f0103020 <mem_init+0x15e1>
f0103007:	68 91 81 10 f0       	push   $0xf0108191
f010300c:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0103011:	68 fb 03 00 00       	push   $0x3fb
f0103016:	68 f5 7d 10 f0       	push   $0xf0107df5
f010301b:	e8 20 d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103020:	f6 c2 02             	test   $0x2,%dl
f0103023:	75 38                	jne    f010305d <mem_init+0x161e>
f0103025:	68 a2 81 10 f0       	push   $0xf01081a2
f010302a:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010302f:	68 fc 03 00 00       	push   $0x3fc
f0103034:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103039:	e8 02 d0 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f010303e:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0103042:	74 19                	je     f010305d <mem_init+0x161e>
f0103044:	68 b3 81 10 f0       	push   $0xf01081b3
f0103049:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010304e:	68 fe 03 00 00       	push   $0x3fe
f0103053:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103058:	e8 e3 cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010305d:	83 c0 01             	add    $0x1,%eax
f0103060:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103065:	0f 85 63 ff ff ff    	jne    f0102fce <mem_init+0x158f>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010306b:	83 ec 0c             	sub    $0xc,%esp
f010306e:	68 00 7d 10 f0       	push   $0xf0107d00
f0103073:	e8 16 0e 00 00       	call   f0103e8e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103078:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010307d:	83 c4 10             	add    $0x10,%esp
f0103080:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103085:	77 15                	ja     f010309c <mem_init+0x165d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103087:	50                   	push   %eax
f0103088:	68 64 70 10 f0       	push   $0xf0107064
f010308d:	68 ec 00 00 00       	push   $0xec
f0103092:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103097:	e8 a4 cf ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010309c:	05 00 00 00 10       	add    $0x10000000,%eax
f01030a1:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01030a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01030a9:	e8 42 de ff ff       	call   f0100ef0 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01030ae:	0f 20 c0             	mov    %cr0,%eax
f01030b1:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01030b4:	0d 23 00 05 80       	or     $0x80050023,%eax
f01030b9:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030bc:	83 ec 0c             	sub    $0xc,%esp
f01030bf:	6a 00                	push   $0x0
f01030c1:	e8 01 e2 ff ff       	call   f01012c7 <page_alloc>
f01030c6:	89 c3                	mov    %eax,%ebx
f01030c8:	83 c4 10             	add    $0x10,%esp
f01030cb:	85 c0                	test   %eax,%eax
f01030cd:	75 19                	jne    f01030e8 <mem_init+0x16a9>
f01030cf:	68 f5 7e 10 f0       	push   $0xf0107ef5
f01030d4:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01030d9:	68 f6 04 00 00       	push   $0x4f6
f01030de:	68 f5 7d 10 f0       	push   $0xf0107df5
f01030e3:	e8 58 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01030e8:	83 ec 0c             	sub    $0xc,%esp
f01030eb:	6a 00                	push   $0x0
f01030ed:	e8 d5 e1 ff ff       	call   f01012c7 <page_alloc>
f01030f2:	89 c7                	mov    %eax,%edi
f01030f4:	83 c4 10             	add    $0x10,%esp
f01030f7:	85 c0                	test   %eax,%eax
f01030f9:	75 19                	jne    f0103114 <mem_init+0x16d5>
f01030fb:	68 0b 7f 10 f0       	push   $0xf0107f0b
f0103100:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0103105:	68 f7 04 00 00       	push   $0x4f7
f010310a:	68 f5 7d 10 f0       	push   $0xf0107df5
f010310f:	e8 2c cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103114:	83 ec 0c             	sub    $0xc,%esp
f0103117:	6a 00                	push   $0x0
f0103119:	e8 a9 e1 ff ff       	call   f01012c7 <page_alloc>
f010311e:	89 c6                	mov    %eax,%esi
f0103120:	83 c4 10             	add    $0x10,%esp
f0103123:	85 c0                	test   %eax,%eax
f0103125:	75 19                	jne    f0103140 <mem_init+0x1701>
f0103127:	68 21 7f 10 f0       	push   $0xf0107f21
f010312c:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0103131:	68 f8 04 00 00       	push   $0x4f8
f0103136:	68 f5 7d 10 f0       	push   $0xf0107df5
f010313b:	e8 00 cf ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103140:	83 ec 0c             	sub    $0xc,%esp
f0103143:	53                   	push   %ebx
f0103144:	e8 ef e3 ff ff       	call   f0101538 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103149:	89 f8                	mov    %edi,%eax
f010314b:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f0103151:	c1 f8 03             	sar    $0x3,%eax
f0103154:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103157:	89 c2                	mov    %eax,%edx
f0103159:	c1 ea 0c             	shr    $0xc,%edx
f010315c:	83 c4 10             	add    $0x10,%esp
f010315f:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f0103165:	72 12                	jb     f0103179 <mem_init+0x173a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103167:	50                   	push   %eax
f0103168:	68 40 70 10 f0       	push   $0xf0107040
f010316d:	6a 56                	push   $0x56
f010316f:	68 01 7e 10 f0       	push   $0xf0107e01
f0103174:	e8 c7 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103179:	83 ec 04             	sub    $0x4,%esp
f010317c:	68 00 10 00 00       	push   $0x1000
f0103181:	6a 01                	push   $0x1
f0103183:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103188:	50                   	push   %eax
f0103189:	e8 db 30 00 00       	call   f0106269 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010318e:	89 f0                	mov    %esi,%eax
f0103190:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f0103196:	c1 f8 03             	sar    $0x3,%eax
f0103199:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010319c:	89 c2                	mov    %eax,%edx
f010319e:	c1 ea 0c             	shr    $0xc,%edx
f01031a1:	83 c4 10             	add    $0x10,%esp
f01031a4:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f01031aa:	72 12                	jb     f01031be <mem_init+0x177f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031ac:	50                   	push   %eax
f01031ad:	68 40 70 10 f0       	push   $0xf0107040
f01031b2:	6a 56                	push   $0x56
f01031b4:	68 01 7e 10 f0       	push   $0xf0107e01
f01031b9:	e8 82 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031be:	83 ec 04             	sub    $0x4,%esp
f01031c1:	68 00 10 00 00       	push   $0x1000
f01031c6:	6a 02                	push   $0x2
f01031c8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031cd:	50                   	push   %eax
f01031ce:	e8 96 30 00 00       	call   f0106269 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031d3:	6a 02                	push   $0x2
f01031d5:	68 00 10 00 00       	push   $0x1000
f01031da:	57                   	push   %edi
f01031db:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f01031e1:	e8 c3 e7 ff ff       	call   f01019a9 <page_insert>
	assert(pp1->pp_ref == 1);
f01031e6:	83 c4 20             	add    $0x20,%esp
f01031e9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01031ee:	74 19                	je     f0103209 <mem_init+0x17ca>
f01031f0:	68 f2 7f 10 f0       	push   $0xf0107ff2
f01031f5:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01031fa:	68 fd 04 00 00       	push   $0x4fd
f01031ff:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103204:	e8 37 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103209:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103210:	01 01 01 
f0103213:	74 19                	je     f010322e <mem_init+0x17ef>
f0103215:	68 20 7d 10 f0       	push   $0xf0107d20
f010321a:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010321f:	68 fe 04 00 00       	push   $0x4fe
f0103224:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103229:	e8 12 ce ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010322e:	6a 02                	push   $0x2
f0103230:	68 00 10 00 00       	push   $0x1000
f0103235:	56                   	push   %esi
f0103236:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f010323c:	e8 68 e7 ff ff       	call   f01019a9 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103241:	83 c4 10             	add    $0x10,%esp
f0103244:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010324b:	02 02 02 
f010324e:	74 19                	je     f0103269 <mem_init+0x182a>
f0103250:	68 44 7d 10 f0       	push   $0xf0107d44
f0103255:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010325a:	68 00 05 00 00       	push   $0x500
f010325f:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103264:	e8 d7 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103269:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010326e:	74 19                	je     f0103289 <mem_init+0x184a>
f0103270:	68 14 80 10 f0       	push   $0xf0108014
f0103275:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010327a:	68 01 05 00 00       	push   $0x501
f010327f:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103284:	e8 b7 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103289:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010328e:	74 19                	je     f01032a9 <mem_init+0x186a>
f0103290:	68 5d 80 10 f0       	push   $0xf010805d
f0103295:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010329a:	68 02 05 00 00       	push   $0x502
f010329f:	68 f5 7d 10 f0       	push   $0xf0107df5
f01032a4:	e8 97 cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01032a9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01032b0:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01032b3:	89 f0                	mov    %esi,%eax
f01032b5:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f01032bb:	c1 f8 03             	sar    $0x3,%eax
f01032be:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032c1:	89 c2                	mov    %eax,%edx
f01032c3:	c1 ea 0c             	shr    $0xc,%edx
f01032c6:	3b 15 a8 1e 24 f0    	cmp    0xf0241ea8,%edx
f01032cc:	72 12                	jb     f01032e0 <mem_init+0x18a1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032ce:	50                   	push   %eax
f01032cf:	68 40 70 10 f0       	push   $0xf0107040
f01032d4:	6a 56                	push   $0x56
f01032d6:	68 01 7e 10 f0       	push   $0xf0107e01
f01032db:	e8 60 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01032e0:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01032e7:	03 03 03 
f01032ea:	74 19                	je     f0103305 <mem_init+0x18c6>
f01032ec:	68 68 7d 10 f0       	push   $0xf0107d68
f01032f1:	68 1b 7e 10 f0       	push   $0xf0107e1b
f01032f6:	68 04 05 00 00       	push   $0x504
f01032fb:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103300:	e8 3b cd ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103305:	83 ec 08             	sub    $0x8,%esp
f0103308:	68 00 10 00 00       	push   $0x1000
f010330d:	ff 35 ac 1e 24 f0    	pushl  0xf0241eac
f0103313:	e8 48 e6 ff ff       	call   f0101960 <page_remove>
	assert(pp2->pp_ref == 0);
f0103318:	83 c4 10             	add    $0x10,%esp
f010331b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103320:	74 19                	je     f010333b <mem_init+0x18fc>
f0103322:	68 4c 80 10 f0       	push   $0xf010804c
f0103327:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010332c:	68 06 05 00 00       	push   $0x506
f0103331:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103336:	e8 05 cd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010333b:	8b 0d ac 1e 24 f0    	mov    0xf0241eac,%ecx
f0103341:	8b 11                	mov    (%ecx),%edx
f0103343:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103349:	89 d8                	mov    %ebx,%eax
f010334b:	2b 05 b0 1e 24 f0    	sub    0xf0241eb0,%eax
f0103351:	c1 f8 03             	sar    $0x3,%eax
f0103354:	c1 e0 0c             	shl    $0xc,%eax
f0103357:	39 c2                	cmp    %eax,%edx
f0103359:	74 19                	je     f0103374 <mem_init+0x1935>
f010335b:	68 f0 78 10 f0       	push   $0xf01078f0
f0103360:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0103365:	68 09 05 00 00       	push   $0x509
f010336a:	68 f5 7d 10 f0       	push   $0xf0107df5
f010336f:	e8 cc cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103374:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010337a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010337f:	74 19                	je     f010339a <mem_init+0x195b>
f0103381:	68 03 80 10 f0       	push   $0xf0108003
f0103386:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010338b:	68 0b 05 00 00       	push   $0x50b
f0103390:	68 f5 7d 10 f0       	push   $0xf0107df5
f0103395:	e8 a6 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010339a:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01033a0:	83 ec 0c             	sub    $0xc,%esp
f01033a3:	53                   	push   %ebx
f01033a4:	e8 8f e1 ff ff       	call   f0101538 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01033a9:	c7 04 24 94 7d 10 f0 	movl   $0xf0107d94,(%esp)
f01033b0:	e8 d9 0a 00 00       	call   f0103e8e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01033b5:	eb 30                	jmp    f01033e7 <mem_init+0x19a8>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	size_t i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir, KSTACKTOP_I(i), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f01033b7:	83 ec 08             	sub    $0x8,%esp
f01033ba:	6a 02                	push   $0x2
f01033bc:	68 00 30 24 00       	push   $0x243000
f01033c1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01033c6:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01033cb:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f01033d0:	e8 90 e4 ff ff       	call   f0101865 <boot_map_region>
f01033d5:	bb 00 b0 24 f0       	mov    $0xf024b000,%ebx
f01033da:	83 c4 10             	add    $0x10,%esp
f01033dd:	be 00 80 be ef       	mov    $0xefbe8000,%esi
f01033e2:	e9 32 f9 ff ff       	jmp    f0102d19 <mem_init+0x12da>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01033e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ea:	5b                   	pop    %ebx
f01033eb:	5e                   	pop    %esi
f01033ec:	5f                   	pop    %edi
f01033ed:	5d                   	pop    %ebp
f01033ee:	c3                   	ret    

f01033ef <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01033ef:	55                   	push   %ebp
f01033f0:	89 e5                	mov    %esp,%ebp
f01033f2:	57                   	push   %edi
f01033f3:	56                   	push   %esi
f01033f4:	53                   	push   %ebx
f01033f5:	83 ec 1c             	sub    $0x1c,%esp
f01033f8:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f01033fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103403:	89 c1                	mov    %eax,%ecx
f0103405:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f0103408:	8b 45 0c             	mov    0xc(%ebp),%eax
f010340b:	03 45 10             	add    0x10(%ebp),%eax
f010340e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103413:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103418:	89 c2                	mov    %eax,%edx
f010341a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	size_t i;
	int auth = perm | PTE_P;
f010341d:	8b 75 14             	mov    0x14(%ebp),%esi
f0103420:	83 ce 01             	or     $0x1,%esi
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f0103423:	89 c8                	mov    %ecx,%eax
f0103425:	39 d0                	cmp    %edx,%eax
f0103427:	73 6f                	jae    f0103498 <user_mem_check+0xa9>
		if (i >= ULIM) {
f0103429:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010342e:	77 15                	ja     f0103445 <user_mem_check+0x56>
f0103430:	89 c3                	mov    %eax,%ebx
f0103432:	eb 21                	jmp    f0103455 <user_mem_check+0x66>
f0103434:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010343a:	76 19                	jbe    f0103455 <user_mem_check+0x66>

	size_t i;
	int auth = perm | PTE_P;
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f010343c:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f010343f:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f0103443:	eb 03                	jmp    f0103448 <user_mem_check+0x59>
		if (i >= ULIM) {
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
f0103445:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103448:	89 1d 5c 12 24 f0    	mov    %ebx,0xf024125c
			return -E_FAULT;
f010344e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103453:	eb 48                	jmp    f010349d <user_mem_check+0xae>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)i, 0);
f0103455:	83 ec 04             	sub    $0x4,%esp
f0103458:	6a 00                	push   $0x0
f010345a:	53                   	push   %ebx
f010345b:	ff 77 64             	pushl  0x64(%edi)
f010345e:	e8 17 e3 ff ff       	call   f010177a <pgdir_walk>
		if (!(pte && (*pte & auth) == auth)) {
f0103463:	83 c4 10             	add    $0x10,%esp
f0103466:	85 c0                	test   %eax,%eax
f0103468:	74 08                	je     f0103472 <user_mem_check+0x83>
f010346a:	89 f2                	mov    %esi,%edx
f010346c:	23 10                	and    (%eax),%edx
f010346e:	39 d6                	cmp    %edx,%esi
f0103470:	74 14                	je     f0103486 <user_mem_check+0x97>
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
f0103472:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f0103475:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f0103479:	89 1d 5c 12 24 f0    	mov    %ebx,0xf024125c
			return -E_FAULT;
f010347f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103484:	eb 17                	jmp    f010349d <user_mem_check+0xae>

	size_t i;
	int auth = perm | PTE_P;
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f0103486:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010348c:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f010348f:	77 a3                	ja     f0103434 <user_mem_check+0x45>
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
			return -E_FAULT;
		}
	}

	return 0;
f0103491:	b8 00 00 00 00       	mov    $0x0,%eax
f0103496:	eb 05                	jmp    f010349d <user_mem_check+0xae>
f0103498:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010349d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034a0:	5b                   	pop    %ebx
f01034a1:	5e                   	pop    %esi
f01034a2:	5f                   	pop    %edi
f01034a3:	5d                   	pop    %ebp
f01034a4:	c3                   	ret    

f01034a5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01034a5:	55                   	push   %ebp
f01034a6:	89 e5                	mov    %esp,%ebp
f01034a8:	53                   	push   %ebx
f01034a9:	83 ec 04             	sub    $0x4,%esp
f01034ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01034af:	8b 45 14             	mov    0x14(%ebp),%eax
f01034b2:	83 c8 04             	or     $0x4,%eax
f01034b5:	50                   	push   %eax
f01034b6:	ff 75 10             	pushl  0x10(%ebp)
f01034b9:	ff 75 0c             	pushl  0xc(%ebp)
f01034bc:	53                   	push   %ebx
f01034bd:	e8 2d ff ff ff       	call   f01033ef <user_mem_check>
f01034c2:	83 c4 10             	add    $0x10,%esp
f01034c5:	85 c0                	test   %eax,%eax
f01034c7:	79 21                	jns    f01034ea <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01034c9:	83 ec 04             	sub    $0x4,%esp
f01034cc:	ff 35 5c 12 24 f0    	pushl  0xf024125c
f01034d2:	ff 73 48             	pushl  0x48(%ebx)
f01034d5:	68 c0 7d 10 f0       	push   $0xf0107dc0
f01034da:	e8 af 09 00 00       	call   f0103e8e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01034df:	89 1c 24             	mov    %ebx,(%esp)
f01034e2:	e8 8a 06 00 00       	call   f0103b71 <env_destroy>
f01034e7:	83 c4 10             	add    $0x10,%esp
	}
}
f01034ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034ed:	c9                   	leave  
f01034ee:	c3                   	ret    

f01034ef <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01034ef:	55                   	push   %ebp
f01034f0:	89 e5                	mov    %esp,%ebp
f01034f2:	57                   	push   %edi
f01034f3:	56                   	push   %esi
f01034f4:	53                   	push   %ebx
f01034f5:	83 ec 1c             	sub    $0x1c,%esp
f01034f8:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f01034fa:	89 d0                	mov    %edx,%eax
f01034fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103501:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f0103504:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010350b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0103511:	39 f0                	cmp    %esi,%eax
f0103513:	73 5e                	jae    f0103573 <region_alloc+0x84>
f0103515:	89 c3                	mov    %eax,%ebx
		if (!(tmp = page_alloc(0))) {
f0103517:	83 ec 0c             	sub    $0xc,%esp
f010351a:	6a 00                	push   $0x0
f010351c:	e8 a6 dd ff ff       	call   f01012c7 <page_alloc>
f0103521:	83 c4 10             	add    $0x10,%esp
f0103524:	85 c0                	test   %eax,%eax
f0103526:	75 17                	jne    f010353f <region_alloc+0x50>
			panic("Execute region_alloc(...) failed. Out of memory.\n");
f0103528:	83 ec 04             	sub    $0x4,%esp
f010352b:	68 c4 81 10 f0       	push   $0xf01081c4
f0103530:	68 34 01 00 00       	push   $0x134
f0103535:	68 89 82 10 f0       	push   $0xf0108289
f010353a:	e8 01 cb ff ff       	call   f0100040 <_panic>
		} else {
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
f010353f:	6a 06                	push   $0x6
f0103541:	53                   	push   %ebx
f0103542:	50                   	push   %eax
f0103543:	ff 77 64             	pushl  0x64(%edi)
f0103546:	e8 5e e4 ff ff       	call   f01019a9 <page_insert>
f010354b:	83 c4 10             	add    $0x10,%esp
f010354e:	85 c0                	test   %eax,%eax
f0103550:	74 17                	je     f0103569 <region_alloc+0x7a>
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
f0103552:	83 ec 04             	sub    $0x4,%esp
f0103555:	68 f8 81 10 f0       	push   $0xf01081f8
f010355a:	68 37 01 00 00       	push   $0x137
f010355f:	68 89 82 10 f0       	push   $0xf0108289
f0103564:	e8 d7 ca ff ff       	call   f0100040 <_panic>
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0103569:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010356f:	39 de                	cmp    %ebx,%esi
f0103571:	77 a4                	ja     f0103517 <region_alloc+0x28>
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
			}
		}
	}
	e->env_cur_brk = start;
f0103573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103576:	89 47 60             	mov    %eax,0x60(%edi)
}
f0103579:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010357c:	5b                   	pop    %ebx
f010357d:	5e                   	pop    %esi
f010357e:	5f                   	pop    %edi
f010357f:	5d                   	pop    %ebp
f0103580:	c3                   	ret    

f0103581 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103581:	55                   	push   %ebp
f0103582:	89 e5                	mov    %esp,%ebp
f0103584:	56                   	push   %esi
f0103585:	53                   	push   %ebx
f0103586:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103589:	85 c0                	test   %eax,%eax
f010358b:	75 1a                	jne    f01035a7 <envid2env+0x26>
		*env_store = curenv;
f010358d:	e8 51 33 00 00       	call   f01068e3 <cpunum>
f0103592:	6b c0 74             	imul   $0x74,%eax,%eax
f0103595:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f010359b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010359e:	89 02                	mov    %eax,(%edx)
		return 0;
f01035a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01035a5:	eb 72                	jmp    f0103619 <envid2env+0x98>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01035a7:	89 c3                	mov    %eax,%ebx
f01035a9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01035af:	c1 e3 07             	shl    $0x7,%ebx
f01035b2:	03 1d 6c 12 24 f0    	add    0xf024126c,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01035b8:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01035bc:	74 05                	je     f01035c3 <envid2env+0x42>
f01035be:	3b 43 48             	cmp    0x48(%ebx),%eax
f01035c1:	74 10                	je     f01035d3 <envid2env+0x52>
		*env_store = 0;
f01035c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01035cc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035d1:	eb 46                	jmp    f0103619 <envid2env+0x98>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01035d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01035d7:	74 36                	je     f010360f <envid2env+0x8e>
f01035d9:	e8 05 33 00 00       	call   f01068e3 <cpunum>
f01035de:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e1:	3b 98 28 20 24 f0    	cmp    -0xfdbdfd8(%eax),%ebx
f01035e7:	74 26                	je     f010360f <envid2env+0x8e>
f01035e9:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01035ec:	e8 f2 32 00 00       	call   f01068e3 <cpunum>
f01035f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01035f4:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01035fa:	3b 70 48             	cmp    0x48(%eax),%esi
f01035fd:	74 10                	je     f010360f <envid2env+0x8e>
		*env_store = 0;
f01035ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103602:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103608:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010360d:	eb 0a                	jmp    f0103619 <envid2env+0x98>
	}

	*env_store = e;
f010360f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103612:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103614:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103619:	5b                   	pop    %ebx
f010361a:	5e                   	pop    %esi
f010361b:	5d                   	pop    %ebp
f010361c:	c3                   	ret    

f010361d <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010361d:	55                   	push   %ebp
f010361e:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103620:	b8 00 23 12 f0       	mov    $0xf0122300,%eax
f0103625:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103628:	b8 23 00 00 00       	mov    $0x23,%eax
f010362d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010362f:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103631:	b8 10 00 00 00       	mov    $0x10,%eax
f0103636:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103638:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010363a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010363c:	ea 43 36 10 f0 08 00 	ljmp   $0x8,$0xf0103643
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103643:	b8 00 00 00 00       	mov    $0x0,%eax
f0103648:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010364b:	5d                   	pop    %ebp
f010364c:	c3                   	ret    

f010364d <env_init>:
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (size_t i = 0; i < NENV - 1; i++) {
		envs[i].env_link = &envs[i + 1];
f010364d:	8b 0d 6c 12 24 f0    	mov    0xf024126c,%ecx
f0103653:	8d 81 80 00 00 00    	lea    0x80(%ecx),%eax
f0103659:	8d 91 00 00 02 00    	lea    0x20000(%ecx),%edx
f010365f:	89 40 c4             	mov    %eax,-0x3c(%eax)
		envs[i].env_id = 0;
f0103662:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
		envs[i].env_status = ENV_FREE;
f0103669:	c7 40 d4 00 00 00 00 	movl   $0x0,-0x2c(%eax)
f0103670:	83 e8 80             	sub    $0xffffff80,%eax
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (size_t i = 0; i < NENV - 1; i++) {
f0103673:	39 d0                	cmp    %edx,%eax
f0103675:	75 e8                	jne    f010365f <env_init+0x12>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103677:	55                   	push   %ebp
f0103678:	89 e5                	mov    %esp,%ebp
	for (size_t i = 0; i < NENV - 1; i++) {
		envs[i].env_link = &envs[i + 1];
		envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
	}
	envs[NENV - 1].env_link = NULL;
f010367a:	c7 81 c4 ff 01 00 00 	movl   $0x0,0x1ffc4(%ecx)
f0103681:	00 00 00 
	envs[NENV - 1].env_id = 0;
f0103684:	c7 81 c8 ff 01 00 00 	movl   $0x0,0x1ffc8(%ecx)
f010368b:	00 00 00 
	envs[NENV - 1].env_status = ENV_FREE;
f010368e:	c7 81 d4 ff 01 00 00 	movl   $0x0,0x1ffd4(%ecx)
f0103695:	00 00 00 
	env_free_list = envs;
f0103698:	89 0d 70 12 24 f0    	mov    %ecx,0xf0241270

	// Per-CPU part of the initialization
	env_init_percpu();
f010369e:	e8 7a ff ff ff       	call   f010361d <env_init_percpu>
}
f01036a3:	5d                   	pop    %ebp
f01036a4:	c3                   	ret    

f01036a5 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01036a5:	55                   	push   %ebp
f01036a6:	89 e5                	mov    %esp,%ebp
f01036a8:	53                   	push   %ebx
f01036a9:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01036ac:	8b 1d 70 12 24 f0    	mov    0xf0241270,%ebx
f01036b2:	85 db                	test   %ebx,%ebx
f01036b4:	0f 84 77 01 00 00    	je     f0103831 <env_alloc+0x18c>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01036ba:	83 ec 0c             	sub    $0xc,%esp
f01036bd:	6a 01                	push   $0x1
f01036bf:	e8 03 dc ff ff       	call   f01012c7 <page_alloc>
f01036c4:	83 c4 10             	add    $0x10,%esp
f01036c7:	85 c0                	test   %eax,%eax
f01036c9:	0f 84 69 01 00 00    	je     f0103838 <env_alloc+0x193>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01036cf:	89 c2                	mov    %eax,%edx
f01036d1:	2b 15 b0 1e 24 f0    	sub    0xf0241eb0,%edx
f01036d7:	c1 fa 03             	sar    $0x3,%edx
f01036da:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036dd:	89 d1                	mov    %edx,%ecx
f01036df:	c1 e9 0c             	shr    $0xc,%ecx
f01036e2:	3b 0d a8 1e 24 f0    	cmp    0xf0241ea8,%ecx
f01036e8:	72 12                	jb     f01036fc <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036ea:	52                   	push   %edx
f01036eb:	68 40 70 10 f0       	push   $0xf0107040
f01036f0:	6a 56                	push   $0x56
f01036f2:	68 01 7e 10 f0       	push   $0xf0107e01
f01036f7:	e8 44 c9 ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pte_t *)page2kva(p);
f01036fc:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103702:	89 53 64             	mov    %edx,0x64(%ebx)
	p->pp_ref++;
f0103705:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010370a:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	// memmove(e->env_pgdir + PDX(UTOP), kern_pgdir + PDX(UTOP), NPDENTRIES - PDX(UTOP));
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f010370f:	8b 15 ac 1e 24 f0    	mov    0xf0241eac,%edx
f0103715:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103718:	8b 53 64             	mov    0x64(%ebx),%edx
f010371b:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010371e:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
	e->env_pgdir = (pte_t *)page2kva(p);
	p->pp_ref++;
	// memmove(e->env_pgdir + PDX(UTOP), kern_pgdir + PDX(UTOP), NPDENTRIES - PDX(UTOP));
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103721:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103726:	75 e7                	jne    f010370f <env_alloc+0x6a>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103728:	8b 43 64             	mov    0x64(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010372b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103730:	77 15                	ja     f0103747 <env_alloc+0xa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103732:	50                   	push   %eax
f0103733:	68 64 70 10 f0       	push   $0xf0107064
f0103738:	68 cb 00 00 00       	push   $0xcb
f010373d:	68 89 82 10 f0       	push   $0xf0108289
f0103742:	e8 f9 c8 ff ff       	call   f0100040 <_panic>
f0103747:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010374d:	83 ca 05             	or     $0x5,%edx
f0103750:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103756:	8b 43 48             	mov    0x48(%ebx),%eax
f0103759:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010375e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103763:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103768:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010376b:	89 da                	mov    %ebx,%edx
f010376d:	2b 15 6c 12 24 f0    	sub    0xf024126c,%edx
f0103773:	c1 fa 07             	sar    $0x7,%edx
f0103776:	09 d0                	or     %edx,%eax
f0103778:	89 43 48             	mov    %eax,0x48(%ebx)
	// cprintf("env_alloc env_id = %d\n", e->env_id);

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010377b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010377e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103781:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103788:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010378f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	e->env_cur_brk = 0;
f0103796:	c7 43 60 00 00 00 00 	movl   $0x0,0x60(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010379d:	83 ec 04             	sub    $0x4,%esp
f01037a0:	6a 44                	push   $0x44
f01037a2:	6a 00                	push   $0x0
f01037a4:	53                   	push   %ebx
f01037a5:	e8 bf 2a 00 00       	call   f0106269 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01037aa:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01037b0:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01037b6:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01037bc:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01037c3:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= 	FL_IF;
f01037c9:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01037d0:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01037d7:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01037de:	8b 43 44             	mov    0x44(%ebx),%eax
f01037e1:	a3 70 12 24 f0       	mov    %eax,0xf0241270
	*newenv_store = e;
f01037e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e9:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037eb:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01037ee:	e8 f0 30 00 00       	call   f01068e3 <cpunum>
f01037f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01037f6:	83 c4 10             	add    $0x10,%esp
f01037f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01037fe:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0103805:	74 11                	je     f0103818 <env_alloc+0x173>
f0103807:	e8 d7 30 00 00       	call   f01068e3 <cpunum>
f010380c:	6b c0 74             	imul   $0x74,%eax,%eax
f010380f:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103815:	8b 50 48             	mov    0x48(%eax),%edx
f0103818:	83 ec 04             	sub    $0x4,%esp
f010381b:	53                   	push   %ebx
f010381c:	52                   	push   %edx
f010381d:	68 94 82 10 f0       	push   $0xf0108294
f0103822:	e8 67 06 00 00       	call   f0103e8e <cprintf>
	return 0;
f0103827:	83 c4 10             	add    $0x10,%esp
f010382a:	b8 00 00 00 00       	mov    $0x0,%eax
f010382f:	eb 0c                	jmp    f010383d <env_alloc+0x198>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103831:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103836:	eb 05                	jmp    f010383d <env_alloc+0x198>
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103838:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010383d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103840:	c9                   	leave  
f0103841:	c3                   	ret    

f0103842 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103842:	55                   	push   %ebp
f0103843:	89 e5                	mov    %esp,%ebp
f0103845:	57                   	push   %edi
f0103846:	56                   	push   %esi
f0103847:	53                   	push   %ebx
f0103848:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *env;
	int err = env_alloc(&env, 0);
f010384b:	6a 00                	push   $0x0
f010384d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103850:	50                   	push   %eax
f0103851:	e8 4f fe ff ff       	call   f01036a5 <env_alloc>
	if (err) {
f0103856:	83 c4 10             	add    $0x10,%esp
f0103859:	85 c0                	test   %eax,%eax
f010385b:	74 3c                	je     f0103899 <env_create+0x57>
		if (err == -E_NO_MEM) {
f010385d:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0103860:	75 17                	jne    f0103879 <env_create+0x37>
			panic("env_create failed. env_alloc E_NO_MEM.\n");
f0103862:	83 ec 04             	sub    $0x4,%esp
f0103865:	68 34 82 10 f0       	push   $0xf0108234
f010386a:	68 a2 01 00 00       	push   $0x1a2
f010386f:	68 89 82 10 f0       	push   $0xf0108289
f0103874:	e8 c7 c7 ff ff       	call   f0100040 <_panic>
		} else if (err == -E_NO_FREE_ENV) {
f0103879:	83 f8 fb             	cmp    $0xfffffffb,%eax
f010387c:	0f 85 0c 01 00 00    	jne    f010398e <env_create+0x14c>
			panic("env_create failed. env_alloc E_NO_FREE_ENV.\n");
f0103882:	83 ec 04             	sub    $0x4,%esp
f0103885:	68 5c 82 10 f0       	push   $0xf010825c
f010388a:	68 a4 01 00 00       	push   $0x1a4
f010388f:	68 89 82 10 f0       	push   $0xf0108289
f0103894:	e8 a7 c7 ff ff       	call   f0100040 <_panic>
		}
	} else {
		load_icode(env, binary, size);
f0103899:	8b 7d e4             	mov    -0x1c(%ebp),%edi

	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *ELFHDR = (struct Elf *) binary;

	if (ELFHDR->e_magic != ELF_MAGIC) {
f010389c:	8b 45 08             	mov    0x8(%ebp),%eax
f010389f:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01038a5:	74 17                	je     f01038be <env_create+0x7c>
		panic("Invalid ELF.\n");
f01038a7:	83 ec 04             	sub    $0x4,%esp
f01038aa:	68 a9 82 10 f0       	push   $0xf01082a9
f01038af:	68 78 01 00 00       	push   $0x178
f01038b4:	68 89 82 10 f0       	push   $0xf0108289
f01038b9:	e8 82 c7 ff ff       	call   f0100040 <_panic>
	}

	lcr3(PADDR(e->env_pgdir));
f01038be:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038c1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038c6:	77 15                	ja     f01038dd <env_create+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038c8:	50                   	push   %eax
f01038c9:	68 64 70 10 f0       	push   $0xf0107064
f01038ce:	68 7b 01 00 00       	push   $0x17b
f01038d3:	68 89 82 10 f0       	push   $0xf0108289
f01038d8:	e8 63 c7 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01038dd:	05 00 00 00 10       	add    $0x10000000,%eax
f01038e2:	0f 22 d8             	mov    %eax,%cr3
	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
f01038e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e8:	89 c3                	mov    %eax,%ebx
f01038ea:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
f01038ed:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f01038f1:	c1 e6 05             	shl    $0x5,%esi
f01038f4:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++) {
f01038f6:	39 f3                	cmp    %esi,%ebx
f01038f8:	73 48                	jae    f0103942 <env_create+0x100>
		if (ph->p_type == ELF_PROG_LOAD) {
f01038fa:	83 3b 01             	cmpl   $0x1,(%ebx)
f01038fd:	75 3c                	jne    f010393b <env_create+0xf9>
			// cprintf("mem = %d  file = %d\n", ph->p_memsz, ph->p_filesz);
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01038ff:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103902:	8b 53 08             	mov    0x8(%ebx),%edx
f0103905:	89 f8                	mov    %edi,%eax
f0103907:	e8 e3 fb ff ff       	call   f01034ef <region_alloc>
			// lcr3(PADDR(e->env_pgdir));
			memmove((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
f010390c:	83 ec 04             	sub    $0x4,%esp
f010390f:	ff 73 10             	pushl  0x10(%ebx)
f0103912:	8b 45 08             	mov    0x8(%ebp),%eax
f0103915:	03 43 04             	add    0x4(%ebx),%eax
f0103918:	50                   	push   %eax
f0103919:	ff 73 08             	pushl  0x8(%ebx)
f010391c:	e8 95 29 00 00       	call   f01062b6 <memmove>
			memset((void *)(ph->p_va + ph->p_filesz), 0, (ph->p_memsz - ph->p_filesz));
f0103921:	8b 43 10             	mov    0x10(%ebx),%eax
f0103924:	83 c4 0c             	add    $0xc,%esp
f0103927:	8b 53 14             	mov    0x14(%ebx),%edx
f010392a:	29 c2                	sub    %eax,%edx
f010392c:	52                   	push   %edx
f010392d:	6a 00                	push   $0x0
f010392f:	03 43 08             	add    0x8(%ebx),%eax
f0103932:	50                   	push   %eax
f0103933:	e8 31 29 00 00       	call   f0106269 <memset>
f0103938:	83 c4 10             	add    $0x10,%esp
	}

	lcr3(PADDR(e->env_pgdir));
	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++) {
f010393b:	83 c3 20             	add    $0x20,%ebx
f010393e:	39 de                	cmp    %ebx,%esi
f0103940:	77 b8                	ja     f01038fa <env_create+0xb8>
			memmove((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
			memset((void *)(ph->p_va + ph->p_filesz), 0, (ph->p_memsz - ph->p_filesz));
			// lcr3(PADDR(kern_pgdir));
		}
	}
	lcr3(PADDR(kern_pgdir));
f0103942:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103947:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010394c:	77 15                	ja     f0103963 <env_create+0x121>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010394e:	50                   	push   %eax
f010394f:	68 64 70 10 f0       	push   $0xf0107064
f0103954:	68 88 01 00 00       	push   $0x188
f0103959:	68 89 82 10 f0       	push   $0xf0108289
f010395e:	e8 dd c6 ff ff       	call   f0100040 <_panic>
f0103963:	05 00 00 00 10       	add    $0x10000000,%eax
f0103968:	0f 22 d8             	mov    %eax,%cr3

	e->env_tf.tf_eip = ELFHDR->e_entry;
f010396b:	8b 45 08             	mov    0x8(%ebp),%eax
f010396e:	8b 40 18             	mov    0x18(%eax),%eax
f0103971:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103974:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103979:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010397e:	89 f8                	mov    %edi,%eax
f0103980:	e8 6a fb ff ff       	call   f01034ef <region_alloc>
		} else if (err == -E_NO_FREE_ENV) {
			panic("env_create failed. env_alloc E_NO_FREE_ENV.\n");
		}
	} else {
		load_icode(env, binary, size);
		env->env_type = type;
f0103985:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103988:	8b 55 10             	mov    0x10(%ebp),%edx
f010398b:	89 50 50             	mov    %edx,0x50(%eax)
		// cprintf("env_create  env_id = %d env_type = %d\n", env->env_id, env->env_type);
	}
}
f010398e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103991:	5b                   	pop    %ebx
f0103992:	5e                   	pop    %esi
f0103993:	5f                   	pop    %edi
f0103994:	5d                   	pop    %ebp
f0103995:	c3                   	ret    

f0103996 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103996:	55                   	push   %ebp
f0103997:	89 e5                	mov    %esp,%ebp
f0103999:	57                   	push   %edi
f010399a:	56                   	push   %esi
f010399b:	53                   	push   %ebx
f010399c:	83 ec 1c             	sub    $0x1c,%esp
f010399f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01039a2:	e8 3c 2f 00 00       	call   f01068e3 <cpunum>
f01039a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01039aa:	39 b8 28 20 24 f0    	cmp    %edi,-0xfdbdfd8(%eax)
f01039b0:	75 29                	jne    f01039db <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01039b2:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039b7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039bc:	77 15                	ja     f01039d3 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039be:	50                   	push   %eax
f01039bf:	68 64 70 10 f0       	push   $0xf0107064
f01039c4:	68 bb 01 00 00       	push   $0x1bb
f01039c9:	68 89 82 10 f0       	push   $0xf0108289
f01039ce:	e8 6d c6 ff ff       	call   f0100040 <_panic>
f01039d3:	05 00 00 00 10       	add    $0x10000000,%eax
f01039d8:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01039db:	8b 5f 48             	mov    0x48(%edi),%ebx
f01039de:	e8 00 2f 00 00       	call   f01068e3 <cpunum>
f01039e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01039e6:	ba 00 00 00 00       	mov    $0x0,%edx
f01039eb:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f01039f2:	74 11                	je     f0103a05 <env_free+0x6f>
f01039f4:	e8 ea 2e 00 00       	call   f01068e3 <cpunum>
f01039f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01039fc:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103a02:	8b 50 48             	mov    0x48(%eax),%edx
f0103a05:	83 ec 04             	sub    $0x4,%esp
f0103a08:	53                   	push   %ebx
f0103a09:	52                   	push   %edx
f0103a0a:	68 b7 82 10 f0       	push   $0xf01082b7
f0103a0f:	e8 7a 04 00 00       	call   f0103e8e <cprintf>
f0103a14:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103a17:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103a1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103a21:	89 d0                	mov    %edx,%eax
f0103a23:	c1 e0 02             	shl    $0x2,%eax
f0103a26:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103a29:	8b 47 64             	mov    0x64(%edi),%eax
f0103a2c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103a2f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103a35:	0f 84 a8 00 00 00    	je     f0103ae3 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103a3b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a41:	89 f0                	mov    %esi,%eax
f0103a43:	c1 e8 0c             	shr    $0xc,%eax
f0103a46:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a49:	39 05 a8 1e 24 f0    	cmp    %eax,0xf0241ea8
f0103a4f:	77 15                	ja     f0103a66 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a51:	56                   	push   %esi
f0103a52:	68 40 70 10 f0       	push   $0xf0107040
f0103a57:	68 ca 01 00 00       	push   $0x1ca
f0103a5c:	68 89 82 10 f0       	push   $0xf0108289
f0103a61:	e8 da c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a66:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a69:	c1 e0 16             	shl    $0x16,%eax
f0103a6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a6f:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103a74:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103a7b:	01 
f0103a7c:	74 17                	je     f0103a95 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a7e:	83 ec 08             	sub    $0x8,%esp
f0103a81:	89 d8                	mov    %ebx,%eax
f0103a83:	c1 e0 0c             	shl    $0xc,%eax
f0103a86:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103a89:	50                   	push   %eax
f0103a8a:	ff 77 64             	pushl  0x64(%edi)
f0103a8d:	e8 ce de ff ff       	call   f0101960 <page_remove>
f0103a92:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a95:	83 c3 01             	add    $0x1,%ebx
f0103a98:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103a9e:	75 d4                	jne    f0103a74 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103aa0:	8b 47 64             	mov    0x64(%edi),%eax
f0103aa3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103aa6:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103aad:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ab0:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f0103ab6:	72 14                	jb     f0103acc <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103ab8:	83 ec 04             	sub    $0x4,%esp
f0103abb:	68 bc 77 10 f0       	push   $0xf01077bc
f0103ac0:	6a 4f                	push   $0x4f
f0103ac2:	68 01 7e 10 f0       	push   $0xf0107e01
f0103ac7:	e8 74 c5 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103acc:	83 ec 0c             	sub    $0xc,%esp
f0103acf:	a1 b0 1e 24 f0       	mov    0xf0241eb0,%eax
f0103ad4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ad7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103ada:	50                   	push   %eax
f0103adb:	e8 73 dc ff ff       	call   f0101753 <page_decref>
f0103ae0:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ae3:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103ae7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103aea:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103aef:	0f 85 29 ff ff ff    	jne    f0103a1e <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103af5:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103af8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103afd:	77 15                	ja     f0103b14 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103aff:	50                   	push   %eax
f0103b00:	68 64 70 10 f0       	push   $0xf0107064
f0103b05:	68 d8 01 00 00       	push   $0x1d8
f0103b0a:	68 89 82 10 f0       	push   $0xf0108289
f0103b0f:	e8 2c c5 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103b14:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b1b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b20:	c1 e8 0c             	shr    $0xc,%eax
f0103b23:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f0103b29:	72 14                	jb     f0103b3f <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103b2b:	83 ec 04             	sub    $0x4,%esp
f0103b2e:	68 bc 77 10 f0       	push   $0xf01077bc
f0103b33:	6a 4f                	push   $0x4f
f0103b35:	68 01 7e 10 f0       	push   $0xf0107e01
f0103b3a:	e8 01 c5 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103b3f:	83 ec 0c             	sub    $0xc,%esp
f0103b42:	8b 15 b0 1e 24 f0    	mov    0xf0241eb0,%edx
f0103b48:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103b4b:	50                   	push   %eax
f0103b4c:	e8 02 dc ff ff       	call   f0101753 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103b51:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103b58:	a1 70 12 24 f0       	mov    0xf0241270,%eax
f0103b5d:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103b60:	89 3d 70 12 24 f0    	mov    %edi,0xf0241270
}
f0103b66:	83 c4 10             	add    $0x10,%esp
f0103b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b6c:	5b                   	pop    %ebx
f0103b6d:	5e                   	pop    %esi
f0103b6e:	5f                   	pop    %edi
f0103b6f:	5d                   	pop    %ebp
f0103b70:	c3                   	ret    

f0103b71 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103b71:	55                   	push   %ebp
f0103b72:	89 e5                	mov    %esp,%ebp
f0103b74:	53                   	push   %ebx
f0103b75:	83 ec 04             	sub    $0x4,%esp
f0103b78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103b7b:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103b7f:	75 19                	jne    f0103b9a <env_destroy+0x29>
f0103b81:	e8 5d 2d 00 00       	call   f01068e3 <cpunum>
f0103b86:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b89:	3b 98 28 20 24 f0    	cmp    -0xfdbdfd8(%eax),%ebx
f0103b8f:	74 09                	je     f0103b9a <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103b91:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103b98:	eb 33                	jmp    f0103bcd <env_destroy+0x5c>
	}

	env_free(e);
f0103b9a:	83 ec 0c             	sub    $0xc,%esp
f0103b9d:	53                   	push   %ebx
f0103b9e:	e8 f3 fd ff ff       	call   f0103996 <env_free>

	if (curenv == e) {
f0103ba3:	e8 3b 2d 00 00       	call   f01068e3 <cpunum>
f0103ba8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bab:	83 c4 10             	add    $0x10,%esp
f0103bae:	3b 98 28 20 24 f0    	cmp    -0xfdbdfd8(%eax),%ebx
f0103bb4:	75 17                	jne    f0103bcd <env_destroy+0x5c>
		curenv = NULL;
f0103bb6:	e8 28 2d 00 00       	call   f01068e3 <cpunum>
f0103bbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bbe:	c7 80 28 20 24 f0 00 	movl   $0x0,-0xfdbdfd8(%eax)
f0103bc5:	00 00 00 
		sched_yield();
f0103bc8:	e8 95 10 00 00       	call   f0104c62 <sched_yield>
	}
}
f0103bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103bd0:	c9                   	leave  
f0103bd1:	c3                   	ret    

f0103bd2 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103bd2:	55                   	push   %ebp
f0103bd3:	89 e5                	mov    %esp,%ebp
f0103bd5:	53                   	push   %ebx
f0103bd6:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103bd9:	e8 05 2d 00 00       	call   f01068e3 <cpunum>
f0103bde:	6b c0 74             	imul   $0x74,%eax,%eax
f0103be1:	8b 98 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%ebx
f0103be7:	e8 f7 2c 00 00       	call   f01068e3 <cpunum>
f0103bec:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103bef:	8b 65 08             	mov    0x8(%ebp),%esp
f0103bf2:	61                   	popa   
f0103bf3:	07                   	pop    %es
f0103bf4:	1f                   	pop    %ds
f0103bf5:	83 c4 08             	add    $0x8,%esp
f0103bf8:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103bf9:	83 ec 04             	sub    $0x4,%esp
f0103bfc:	68 cd 82 10 f0       	push   $0xf01082cd
f0103c01:	68 0e 02 00 00       	push   $0x20e
f0103c06:	68 89 82 10 f0       	push   $0xf0108289
f0103c0b:	e8 30 c4 ff ff       	call   f0100040 <_panic>

f0103c10 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c10:	55                   	push   %ebp
f0103c11:	89 e5                	mov    %esp,%ebp
f0103c13:	53                   	push   %ebx
f0103c14:	83 ec 04             	sub    $0x4,%esp
f0103c17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("env_run e->env_id = %d, CPU %d\n", e->env_id, cpunum());
	if (curenv != e) {
f0103c1a:	e8 c4 2c 00 00       	call   f01068e3 <cpunum>
f0103c1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c22:	39 98 28 20 24 f0    	cmp    %ebx,-0xfdbdfd8(%eax)
f0103c28:	0f 84 a4 00 00 00    	je     f0103cd2 <env_run+0xc2>
		if (curenv && curenv->env_status == ENV_RUNNING) {
f0103c2e:	e8 b0 2c 00 00       	call   f01068e3 <cpunum>
f0103c33:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c36:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0103c3d:	74 29                	je     f0103c68 <env_run+0x58>
f0103c3f:	e8 9f 2c 00 00       	call   f01068e3 <cpunum>
f0103c44:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c47:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103c4d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103c51:	75 15                	jne    f0103c68 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103c53:	e8 8b 2c 00 00       	call   f01068e3 <cpunum>
f0103c58:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c5b:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103c61:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		curenv = e;
f0103c68:	e8 76 2c 00 00       	call   f01068e3 <cpunum>
f0103c6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c70:	89 98 28 20 24 f0    	mov    %ebx,-0xfdbdfd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0103c76:	e8 68 2c 00 00       	call   f01068e3 <cpunum>
f0103c7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c7e:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103c84:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0103c8b:	e8 53 2c 00 00       	call   f01068e3 <cpunum>
f0103c90:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c93:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103c99:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0103c9d:	e8 41 2c 00 00       	call   f01068e3 <cpunum>
f0103ca2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ca5:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103cab:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cb3:	77 15                	ja     f0103cca <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cb5:	50                   	push   %eax
f0103cb6:	68 64 70 10 f0       	push   $0xf0107064
f0103cbb:	68 34 02 00 00       	push   $0x234
f0103cc0:	68 89 82 10 f0       	push   $0xf0108289
f0103cc5:	e8 76 c3 ff ff       	call   f0100040 <_panic>
f0103cca:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ccf:	0f 22 d8             	mov    %eax,%cr3
	}

	curenv->env_tf.tf_eflags |= FL_IF;
f0103cd2:	e8 0c 2c 00 00       	call   f01068e3 <cpunum>
f0103cd7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cda:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103ce0:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ce7:	83 ec 0c             	sub    $0xc,%esp
f0103cea:	68 a0 23 12 f0       	push   $0xf01223a0
f0103cef:	e8 32 2f 00 00       	call   f0106c26 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103cf4:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f0103cf6:	e8 e8 2b 00 00       	call   f01068e3 <cpunum>
f0103cfb:	83 c4 04             	add    $0x4,%esp
f0103cfe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d01:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0103d07:	e8 c6 fe ff ff       	call   f0103bd2 <env_pop_tf>

f0103d0c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103d0c:	55                   	push   %ebp
f0103d0d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d0f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d14:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d17:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103d18:	ba 71 00 00 00       	mov    $0x71,%edx
f0103d1d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d1e:	0f b6 c0             	movzbl %al,%eax
}
f0103d21:	5d                   	pop    %ebp
f0103d22:	c3                   	ret    

f0103d23 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d23:	55                   	push   %ebp
f0103d24:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d26:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d2e:	ee                   	out    %al,(%dx)
f0103d2f:	ba 71 00 00 00       	mov    $0x71,%edx
f0103d34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d37:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103d38:	5d                   	pop    %ebp
f0103d39:	c3                   	ret    

f0103d3a <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103d3a:	55                   	push   %ebp
f0103d3b:	89 e5                	mov    %esp,%ebp
f0103d3d:	56                   	push   %esi
f0103d3e:	53                   	push   %ebx
f0103d3f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103d42:	66 a3 88 23 12 f0    	mov    %ax,0xf0122388
	if (!didinit)
f0103d48:	83 3d 74 12 24 f0 00 	cmpl   $0x0,0xf0241274
f0103d4f:	74 5a                	je     f0103dab <irq_setmask_8259A+0x71>
f0103d51:	89 c6                	mov    %eax,%esi
f0103d53:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d58:	ee                   	out    %al,(%dx)
f0103d59:	66 c1 e8 08          	shr    $0x8,%ax
f0103d5d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103d62:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103d63:	83 ec 0c             	sub    $0xc,%esp
f0103d66:	68 d9 82 10 f0       	push   $0xf01082d9
f0103d6b:	e8 1e 01 00 00       	call   f0103e8e <cprintf>
f0103d70:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103d73:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103d78:	0f b7 f6             	movzwl %si,%esi
f0103d7b:	f7 d6                	not    %esi
f0103d7d:	0f a3 de             	bt     %ebx,%esi
f0103d80:	73 11                	jae    f0103d93 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103d82:	83 ec 08             	sub    $0x8,%esp
f0103d85:	53                   	push   %ebx
f0103d86:	68 c7 87 10 f0       	push   $0xf01087c7
f0103d8b:	e8 fe 00 00 00       	call   f0103e8e <cprintf>
f0103d90:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103d93:	83 c3 01             	add    $0x1,%ebx
f0103d96:	83 fb 10             	cmp    $0x10,%ebx
f0103d99:	75 e2                	jne    f0103d7d <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103d9b:	83 ec 0c             	sub    $0xc,%esp
f0103d9e:	68 b6 73 10 f0       	push   $0xf01073b6
f0103da3:	e8 e6 00 00 00       	call   f0103e8e <cprintf>
f0103da8:	83 c4 10             	add    $0x10,%esp
}
f0103dab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103dae:	5b                   	pop    %ebx
f0103daf:	5e                   	pop    %esi
f0103db0:	5d                   	pop    %ebp
f0103db1:	c3                   	ret    

f0103db2 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103db2:	c7 05 74 12 24 f0 01 	movl   $0x1,0xf0241274
f0103db9:	00 00 00 
f0103dbc:	ba 21 00 00 00       	mov    $0x21,%edx
f0103dc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103dc6:	ee                   	out    %al,(%dx)
f0103dc7:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103dcc:	ee                   	out    %al,(%dx)
f0103dcd:	ba 20 00 00 00       	mov    $0x20,%edx
f0103dd2:	b8 11 00 00 00       	mov    $0x11,%eax
f0103dd7:	ee                   	out    %al,(%dx)
f0103dd8:	ba 21 00 00 00       	mov    $0x21,%edx
f0103ddd:	b8 20 00 00 00       	mov    $0x20,%eax
f0103de2:	ee                   	out    %al,(%dx)
f0103de3:	b8 04 00 00 00       	mov    $0x4,%eax
f0103de8:	ee                   	out    %al,(%dx)
f0103de9:	b8 03 00 00 00       	mov    $0x3,%eax
f0103dee:	ee                   	out    %al,(%dx)
f0103def:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103df4:	b8 11 00 00 00       	mov    $0x11,%eax
f0103df9:	ee                   	out    %al,(%dx)
f0103dfa:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103dff:	b8 28 00 00 00       	mov    $0x28,%eax
f0103e04:	ee                   	out    %al,(%dx)
f0103e05:	b8 02 00 00 00       	mov    $0x2,%eax
f0103e0a:	ee                   	out    %al,(%dx)
f0103e0b:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e10:	ee                   	out    %al,(%dx)
f0103e11:	ba 20 00 00 00       	mov    $0x20,%edx
f0103e16:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e1b:	ee                   	out    %al,(%dx)
f0103e1c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e21:	ee                   	out    %al,(%dx)
f0103e22:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103e27:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e2c:	ee                   	out    %al,(%dx)
f0103e2d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e32:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103e33:	0f b7 05 88 23 12 f0 	movzwl 0xf0122388,%eax
f0103e3a:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103e3e:	74 13                	je     f0103e53 <pic_init+0xa1>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103e40:	55                   	push   %ebp
f0103e41:	89 e5                	mov    %esp,%ebp
f0103e43:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103e46:	0f b7 c0             	movzwl %ax,%eax
f0103e49:	50                   	push   %eax
f0103e4a:	e8 eb fe ff ff       	call   f0103d3a <irq_setmask_8259A>
f0103e4f:	83 c4 10             	add    $0x10,%esp
}
f0103e52:	c9                   	leave  
f0103e53:	f3 c3                	repz ret 

f0103e55 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103e55:	55                   	push   %ebp
f0103e56:	89 e5                	mov    %esp,%ebp
f0103e58:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103e5b:	ff 75 08             	pushl  0x8(%ebp)
f0103e5e:	e8 57 ca ff ff       	call   f01008ba <cputchar>
	*cnt++;
}
f0103e63:	83 c4 10             	add    $0x10,%esp
f0103e66:	c9                   	leave  
f0103e67:	c3                   	ret    

f0103e68 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e68:	55                   	push   %ebp
f0103e69:	89 e5                	mov    %esp,%ebp
f0103e6b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103e6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103e75:	ff 75 0c             	pushl  0xc(%ebp)
f0103e78:	ff 75 08             	pushl  0x8(%ebp)
f0103e7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e7e:	50                   	push   %eax
f0103e7f:	68 55 3e 10 f0       	push   $0xf0103e55
f0103e84:	e8 d2 1b 00 00       	call   f0105a5b <vprintfmt>
	return cnt;
}
f0103e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e8c:	c9                   	leave  
f0103e8d:	c3                   	ret    

f0103e8e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103e8e:	55                   	push   %ebp
f0103e8f:	89 e5                	mov    %esp,%ebp
f0103e91:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103e94:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103e97:	50                   	push   %eax
f0103e98:	ff 75 08             	pushl  0x8(%ebp)
f0103e9b:	e8 c8 ff ff ff       	call   f0103e68 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ea0:	c9                   	leave  
f0103ea1:	c3                   	ret    

f0103ea2 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ea2:	55                   	push   %ebp
f0103ea3:	89 e5                	mov    %esp,%ebp
f0103ea5:	57                   	push   %edi
f0103ea6:	56                   	push   %esi
f0103ea7:	53                   	push   %ebx
f0103ea8:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int i = thiscpu->cpu_id;
f0103eab:	e8 33 2a 00 00       	call   f01068e3 <cpunum>
f0103eb0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eb3:	0f b6 b0 20 20 24 f0 	movzbl -0xfdbdfe0(%eax),%esi
f0103eba:	89 f0                	mov    %esi,%eax
f0103ebc:	0f b6 d8             	movzbl %al,%ebx

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103ebf:	e8 1f 2a 00 00       	call   f01068e3 <cpunum>
f0103ec4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ec7:	89 d9                	mov    %ebx,%ecx
f0103ec9:	c1 e1 10             	shl    $0x10,%ecx
f0103ecc:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0103ed1:	29 ca                	sub    %ecx,%edx
f0103ed3:	89 90 30 20 24 f0    	mov    %edx,-0xfdbdfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103ed9:	e8 05 2a 00 00       	call   f01068e3 <cpunum>
f0103ede:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ee1:	66 c7 80 34 20 24 f0 	movw   $0x10,-0xfdbdfcc(%eax)
f0103ee8:	10 00 

	extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
f0103eea:	ba 00 00 00 00       	mov    $0x0,%edx
f0103eef:	b8 08 00 00 00       	mov    $0x8,%eax
f0103ef4:	b9 74 01 00 00       	mov    $0x174,%ecx
f0103ef9:	0f 30                	wrmsr  
  wrmsr(0x175, thiscpu->cpu_ts.ts_esp0, 0);
f0103efb:	e8 e3 29 00 00       	call   f01068e3 <cpunum>
f0103f00:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f03:	8b 80 30 20 24 f0    	mov    -0xfdbdfd0(%eax),%eax
f0103f09:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f0e:	b9 75 01 00 00       	mov    $0x175,%ecx
f0103f13:	0f 30                	wrmsr  
  wrmsr(0x176, sysenter_handler, 0);
f0103f15:	b8 14 4c 10 f0       	mov    $0xf0104c14,%eax
f0103f1a:	b9 76 01 00 00       	mov    $0x176,%ecx
f0103f1f:	0f 30                	wrmsr  

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)(&thiscpu->cpu_ts),
f0103f21:	83 c3 05             	add    $0x5,%ebx
f0103f24:	e8 ba 29 00 00       	call   f01068e3 <cpunum>
f0103f29:	89 c7                	mov    %eax,%edi
f0103f2b:	e8 b3 29 00 00       	call   f01068e3 <cpunum>
f0103f30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f33:	e8 ab 29 00 00       	call   f01068e3 <cpunum>
f0103f38:	66 c7 04 dd 20 23 12 	movw   $0x68,-0xfeddce0(,%ebx,8)
f0103f3f:	f0 68 00 
f0103f42:	6b ff 74             	imul   $0x74,%edi,%edi
f0103f45:	81 c7 2c 20 24 f0    	add    $0xf024202c,%edi
f0103f4b:	66 89 3c dd 22 23 12 	mov    %di,-0xfeddcde(,%ebx,8)
f0103f52:	f0 
f0103f53:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103f57:	81 c2 2c 20 24 f0    	add    $0xf024202c,%edx
f0103f5d:	c1 ea 10             	shr    $0x10,%edx
f0103f60:	88 14 dd 24 23 12 f0 	mov    %dl,-0xfeddcdc(,%ebx,8)
f0103f67:	c6 04 dd 26 23 12 f0 	movb   $0x40,-0xfeddcda(,%ebx,8)
f0103f6e:	40 
f0103f6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f72:	05 2c 20 24 f0       	add    $0xf024202c,%eax
f0103f77:	c1 e8 18             	shr    $0x18,%eax
f0103f7a:	88 04 dd 27 23 12 f0 	mov    %al,-0xfeddcd9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103f81:	c6 04 dd 25 23 12 f0 	movb   $0x89,-0xfeddcdb(,%ebx,8)
f0103f88:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103f89:	89 f0                	mov    %esi,%eax
f0103f8b:	0f b6 f0             	movzbl %al,%esi
f0103f8e:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f0103f95:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103f98:	b8 8c 23 12 f0       	mov    $0xf012238c,%eax
f0103f9d:	0f 01 18             	lidtl  (%eax)

	ltr(GD_TSS0+(i << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f0103fa0:	83 c4 1c             	add    $0x1c,%esp
f0103fa3:	5b                   	pop    %ebx
f0103fa4:	5e                   	pop    %esi
f0103fa5:	5f                   	pop    %edi
f0103fa6:	5d                   	pop    %ebp
f0103fa7:	c3                   	ret    

f0103fa8 <trap_init>:
}


void
trap_init(void)
{
f0103fa8:	55                   	push   %ebp
f0103fa9:	89 e5                	mov    %esp,%ebp
f0103fab:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _divide_error, 0);
f0103fae:	b8 02 4b 10 f0       	mov    $0xf0104b02,%eax
f0103fb3:	66 a3 80 12 24 f0    	mov    %ax,0xf0241280
f0103fb9:	66 c7 05 82 12 24 f0 	movw   $0x8,0xf0241282
f0103fc0:	08 00 
f0103fc2:	c6 05 84 12 24 f0 00 	movb   $0x0,0xf0241284
f0103fc9:	c6 05 85 12 24 f0 8e 	movb   $0x8e,0xf0241285
f0103fd0:	c1 e8 10             	shr    $0x10,%eax
f0103fd3:	66 a3 86 12 24 f0    	mov    %ax,0xf0241286
	SETGATE(idt[T_DEBUG], 0, GD_KT, _debug, 0);
f0103fd9:	b8 0c 4b 10 f0       	mov    $0xf0104b0c,%eax
f0103fde:	66 a3 88 12 24 f0    	mov    %ax,0xf0241288
f0103fe4:	66 c7 05 8a 12 24 f0 	movw   $0x8,0xf024128a
f0103feb:	08 00 
f0103fed:	c6 05 8c 12 24 f0 00 	movb   $0x0,0xf024128c
f0103ff4:	c6 05 8d 12 24 f0 8e 	movb   $0x8e,0xf024128d
f0103ffb:	c1 e8 10             	shr    $0x10,%eax
f0103ffe:	66 a3 8e 12 24 f0    	mov    %ax,0xf024128e
	SETGATE(idt[T_NMI], 0, GD_KT, _non_maskable_interrupt, 0);
f0104004:	b8 16 4b 10 f0       	mov    $0xf0104b16,%eax
f0104009:	66 a3 90 12 24 f0    	mov    %ax,0xf0241290
f010400f:	66 c7 05 92 12 24 f0 	movw   $0x8,0xf0241292
f0104016:	08 00 
f0104018:	c6 05 94 12 24 f0 00 	movb   $0x0,0xf0241294
f010401f:	c6 05 95 12 24 f0 8e 	movb   $0x8e,0xf0241295
f0104026:	c1 e8 10             	shr    $0x10,%eax
f0104029:	66 a3 96 12 24 f0    	mov    %ax,0xf0241296
	SETGATE(idt[T_BRKPT], 0, GD_KT, _breakpoint, 3);
f010402f:	b8 20 4b 10 f0       	mov    $0xf0104b20,%eax
f0104034:	66 a3 98 12 24 f0    	mov    %ax,0xf0241298
f010403a:	66 c7 05 9a 12 24 f0 	movw   $0x8,0xf024129a
f0104041:	08 00 
f0104043:	c6 05 9c 12 24 f0 00 	movb   $0x0,0xf024129c
f010404a:	c6 05 9d 12 24 f0 ee 	movb   $0xee,0xf024129d
f0104051:	c1 e8 10             	shr    $0x10,%eax
f0104054:	66 a3 9e 12 24 f0    	mov    %ax,0xf024129e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _overflow, 0);
f010405a:	b8 2a 4b 10 f0       	mov    $0xf0104b2a,%eax
f010405f:	66 a3 a0 12 24 f0    	mov    %ax,0xf02412a0
f0104065:	66 c7 05 a2 12 24 f0 	movw   $0x8,0xf02412a2
f010406c:	08 00 
f010406e:	c6 05 a4 12 24 f0 00 	movb   $0x0,0xf02412a4
f0104075:	c6 05 a5 12 24 f0 8e 	movb   $0x8e,0xf02412a5
f010407c:	c1 e8 10             	shr    $0x10,%eax
f010407f:	66 a3 a6 12 24 f0    	mov    %ax,0xf02412a6
	SETGATE(idt[T_BOUND], 0, GD_KT, _bound_range_exceeded, 0);
f0104085:	b8 34 4b 10 f0       	mov    $0xf0104b34,%eax
f010408a:	66 a3 a8 12 24 f0    	mov    %ax,0xf02412a8
f0104090:	66 c7 05 aa 12 24 f0 	movw   $0x8,0xf02412aa
f0104097:	08 00 
f0104099:	c6 05 ac 12 24 f0 00 	movb   $0x0,0xf02412ac
f01040a0:	c6 05 ad 12 24 f0 8e 	movb   $0x8e,0xf02412ad
f01040a7:	c1 e8 10             	shr    $0x10,%eax
f01040aa:	66 a3 ae 12 24 f0    	mov    %ax,0xf02412ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, _invalid_opcode, 0);
f01040b0:	b8 3e 4b 10 f0       	mov    $0xf0104b3e,%eax
f01040b5:	66 a3 b0 12 24 f0    	mov    %ax,0xf02412b0
f01040bb:	66 c7 05 b2 12 24 f0 	movw   $0x8,0xf02412b2
f01040c2:	08 00 
f01040c4:	c6 05 b4 12 24 f0 00 	movb   $0x0,0xf02412b4
f01040cb:	c6 05 b5 12 24 f0 8e 	movb   $0x8e,0xf02412b5
f01040d2:	c1 e8 10             	shr    $0x10,%eax
f01040d5:	66 a3 b6 12 24 f0    	mov    %ax,0xf02412b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, _device_not_available, 0);
f01040db:	b8 48 4b 10 f0       	mov    $0xf0104b48,%eax
f01040e0:	66 a3 b8 12 24 f0    	mov    %ax,0xf02412b8
f01040e6:	66 c7 05 ba 12 24 f0 	movw   $0x8,0xf02412ba
f01040ed:	08 00 
f01040ef:	c6 05 bc 12 24 f0 00 	movb   $0x0,0xf02412bc
f01040f6:	c6 05 bd 12 24 f0 8e 	movb   $0x8e,0xf02412bd
f01040fd:	c1 e8 10             	shr    $0x10,%eax
f0104100:	66 a3 be 12 24 f0    	mov    %ax,0xf02412be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _double_fault, 0);
f0104106:	b8 52 4b 10 f0       	mov    $0xf0104b52,%eax
f010410b:	66 a3 c0 12 24 f0    	mov    %ax,0xf02412c0
f0104111:	66 c7 05 c2 12 24 f0 	movw   $0x8,0xf02412c2
f0104118:	08 00 
f010411a:	c6 05 c4 12 24 f0 00 	movb   $0x0,0xf02412c4
f0104121:	c6 05 c5 12 24 f0 8e 	movb   $0x8e,0xf02412c5
f0104128:	c1 e8 10             	shr    $0x10,%eax
f010412b:	66 a3 c6 12 24 f0    	mov    %ax,0xf02412c6

	SETGATE(idt[T_TSS], 0, GD_KT, _invalid_tss, 0);
f0104131:	b8 5a 4b 10 f0       	mov    $0xf0104b5a,%eax
f0104136:	66 a3 d0 12 24 f0    	mov    %ax,0xf02412d0
f010413c:	66 c7 05 d2 12 24 f0 	movw   $0x8,0xf02412d2
f0104143:	08 00 
f0104145:	c6 05 d4 12 24 f0 00 	movb   $0x0,0xf02412d4
f010414c:	c6 05 d5 12 24 f0 8e 	movb   $0x8e,0xf02412d5
f0104153:	c1 e8 10             	shr    $0x10,%eax
f0104156:	66 a3 d6 12 24 f0    	mov    %ax,0xf02412d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _segment_not_present, 0);
f010415c:	b8 62 4b 10 f0       	mov    $0xf0104b62,%eax
f0104161:	66 a3 d8 12 24 f0    	mov    %ax,0xf02412d8
f0104167:	66 c7 05 da 12 24 f0 	movw   $0x8,0xf02412da
f010416e:	08 00 
f0104170:	c6 05 dc 12 24 f0 00 	movb   $0x0,0xf02412dc
f0104177:	c6 05 dd 12 24 f0 8e 	movb   $0x8e,0xf02412dd
f010417e:	c1 e8 10             	shr    $0x10,%eax
f0104181:	66 a3 de 12 24 f0    	mov    %ax,0xf02412de
	SETGATE(idt[T_STACK], 0, GD_KT, _stack_fault, 0);
f0104187:	b8 6a 4b 10 f0       	mov    $0xf0104b6a,%eax
f010418c:	66 a3 e0 12 24 f0    	mov    %ax,0xf02412e0
f0104192:	66 c7 05 e2 12 24 f0 	movw   $0x8,0xf02412e2
f0104199:	08 00 
f010419b:	c6 05 e4 12 24 f0 00 	movb   $0x0,0xf02412e4
f01041a2:	c6 05 e5 12 24 f0 8e 	movb   $0x8e,0xf02412e5
f01041a9:	c1 e8 10             	shr    $0x10,%eax
f01041ac:	66 a3 e6 12 24 f0    	mov    %ax,0xf02412e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _general_protection, 0);
f01041b2:	b8 72 4b 10 f0       	mov    $0xf0104b72,%eax
f01041b7:	66 a3 e8 12 24 f0    	mov    %ax,0xf02412e8
f01041bd:	66 c7 05 ea 12 24 f0 	movw   $0x8,0xf02412ea
f01041c4:	08 00 
f01041c6:	c6 05 ec 12 24 f0 00 	movb   $0x0,0xf02412ec
f01041cd:	c6 05 ed 12 24 f0 8e 	movb   $0x8e,0xf02412ed
f01041d4:	c1 e8 10             	shr    $0x10,%eax
f01041d7:	66 a3 ee 12 24 f0    	mov    %ax,0xf02412ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, _page_fault, 0);
f01041dd:	b8 7a 4b 10 f0       	mov    $0xf0104b7a,%eax
f01041e2:	66 a3 f0 12 24 f0    	mov    %ax,0xf02412f0
f01041e8:	66 c7 05 f2 12 24 f0 	movw   $0x8,0xf02412f2
f01041ef:	08 00 
f01041f1:	c6 05 f4 12 24 f0 00 	movb   $0x0,0xf02412f4
f01041f8:	c6 05 f5 12 24 f0 8e 	movb   $0x8e,0xf02412f5
f01041ff:	c1 e8 10             	shr    $0x10,%eax
f0104202:	66 a3 f6 12 24 f0    	mov    %ax,0xf02412f6

	SETGATE(idt[T_FPERR], 0, GD_KT, _x87_fpu_error, 0);
f0104208:	b8 82 4b 10 f0       	mov    $0xf0104b82,%eax
f010420d:	66 a3 00 13 24 f0    	mov    %ax,0xf0241300
f0104213:	66 c7 05 02 13 24 f0 	movw   $0x8,0xf0241302
f010421a:	08 00 
f010421c:	c6 05 04 13 24 f0 00 	movb   $0x0,0xf0241304
f0104223:	c6 05 05 13 24 f0 8e 	movb   $0x8e,0xf0241305
f010422a:	c1 e8 10             	shr    $0x10,%eax
f010422d:	66 a3 06 13 24 f0    	mov    %ax,0xf0241306
	SETGATE(idt[T_ALIGN], 0, GD_KT, _alignment_check, 0);
f0104233:	b8 8c 4b 10 f0       	mov    $0xf0104b8c,%eax
f0104238:	66 a3 08 13 24 f0    	mov    %ax,0xf0241308
f010423e:	66 c7 05 0a 13 24 f0 	movw   $0x8,0xf024130a
f0104245:	08 00 
f0104247:	c6 05 0c 13 24 f0 00 	movb   $0x0,0xf024130c
f010424e:	c6 05 0d 13 24 f0 8e 	movb   $0x8e,0xf024130d
f0104255:	c1 e8 10             	shr    $0x10,%eax
f0104258:	66 a3 0e 13 24 f0    	mov    %ax,0xf024130e
	SETGATE(idt[T_MCHK], 0, GD_KT, _machine_check, 0);
f010425e:	b8 94 4b 10 f0       	mov    $0xf0104b94,%eax
f0104263:	66 a3 10 13 24 f0    	mov    %ax,0xf0241310
f0104269:	66 c7 05 12 13 24 f0 	movw   $0x8,0xf0241312
f0104270:	08 00 
f0104272:	c6 05 14 13 24 f0 00 	movb   $0x0,0xf0241314
f0104279:	c6 05 15 13 24 f0 8e 	movb   $0x8e,0xf0241315
f0104280:	c1 e8 10             	shr    $0x10,%eax
f0104283:	66 a3 16 13 24 f0    	mov    %ax,0xf0241316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _simd_fp_exception, 0);
f0104289:	b8 9e 4b 10 f0       	mov    $0xf0104b9e,%eax
f010428e:	66 a3 18 13 24 f0    	mov    %ax,0xf0241318
f0104294:	66 c7 05 1a 13 24 f0 	movw   $0x8,0xf024131a
f010429b:	08 00 
f010429d:	c6 05 1c 13 24 f0 00 	movb   $0x0,0xf024131c
f01042a4:	c6 05 1d 13 24 f0 8e 	movb   $0x8e,0xf024131d
f01042ab:	c1 e8 10             	shr    $0x10,%eax
f01042ae:	66 a3 1e 13 24 f0    	mov    %ax,0xf024131e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall, 3);
f01042b4:	b8 a3 4d 10 f0       	mov    $0xf0104da3,%eax
f01042b9:	66 a3 00 14 24 f0    	mov    %ax,0xf0241400
f01042bf:	66 c7 05 02 14 24 f0 	movw   $0x8,0xf0241402
f01042c6:	08 00 
f01042c8:	c6 05 04 14 24 f0 00 	movb   $0x0,0xf0241404
f01042cf:	c6 05 05 14 24 f0 ee 	movb   $0xee,0xf0241405
f01042d6:	c1 e8 10             	shr    $0x10,%eax
f01042d9:	66 a3 06 14 24 f0    	mov    %ax,0xf0241406

	SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, _irq0, 0);
f01042df:	b8 a8 4b 10 f0       	mov    $0xf0104ba8,%eax
f01042e4:	66 a3 80 13 24 f0    	mov    %ax,0xf0241380
f01042ea:	66 c7 05 82 13 24 f0 	movw   $0x8,0xf0241382
f01042f1:	08 00 
f01042f3:	c6 05 84 13 24 f0 00 	movb   $0x0,0xf0241384
f01042fa:	c6 05 85 13 24 f0 8e 	movb   $0x8e,0xf0241385
f0104301:	c1 e8 10             	shr    $0x10,%eax
f0104304:	66 a3 86 13 24 f0    	mov    %ax,0xf0241386
	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, _irq1, 0);
f010430a:	b8 b2 4b 10 f0       	mov    $0xf0104bb2,%eax
f010430f:	66 a3 88 13 24 f0    	mov    %ax,0xf0241388
f0104315:	66 c7 05 8a 13 24 f0 	movw   $0x8,0xf024138a
f010431c:	08 00 
f010431e:	c6 05 8c 13 24 f0 00 	movb   $0x0,0xf024138c
f0104325:	c6 05 8d 13 24 f0 8e 	movb   $0x8e,0xf024138d
f010432c:	c1 e8 10             	shr    $0x10,%eax
f010432f:	66 a3 8e 13 24 f0    	mov    %ax,0xf024138e
	SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, _irq2, 0);
f0104335:	b8 bc 4b 10 f0       	mov    $0xf0104bbc,%eax
f010433a:	66 a3 90 13 24 f0    	mov    %ax,0xf0241390
f0104340:	66 c7 05 92 13 24 f0 	movw   $0x8,0xf0241392
f0104347:	08 00 
f0104349:	c6 05 94 13 24 f0 00 	movb   $0x0,0xf0241394
f0104350:	c6 05 95 13 24 f0 8e 	movb   $0x8e,0xf0241395
f0104357:	c1 e8 10             	shr    $0x10,%eax
f010435a:	66 a3 96 13 24 f0    	mov    %ax,0xf0241396
	SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, _irq3, 0);
f0104360:	b8 c6 4b 10 f0       	mov    $0xf0104bc6,%eax
f0104365:	66 a3 98 13 24 f0    	mov    %ax,0xf0241398
f010436b:	66 c7 05 9a 13 24 f0 	movw   $0x8,0xf024139a
f0104372:	08 00 
f0104374:	c6 05 9c 13 24 f0 00 	movb   $0x0,0xf024139c
f010437b:	c6 05 9d 13 24 f0 8e 	movb   $0x8e,0xf024139d
f0104382:	c1 e8 10             	shr    $0x10,%eax
f0104385:	66 a3 9e 13 24 f0    	mov    %ax,0xf024139e
	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, _irq4, 0);
f010438b:	b8 cc 4b 10 f0       	mov    $0xf0104bcc,%eax
f0104390:	66 a3 a0 13 24 f0    	mov    %ax,0xf02413a0
f0104396:	66 c7 05 a2 13 24 f0 	movw   $0x8,0xf02413a2
f010439d:	08 00 
f010439f:	c6 05 a4 13 24 f0 00 	movb   $0x0,0xf02413a4
f01043a6:	c6 05 a5 13 24 f0 8e 	movb   $0x8e,0xf02413a5
f01043ad:	c1 e8 10             	shr    $0x10,%eax
f01043b0:	66 a3 a6 13 24 f0    	mov    %ax,0xf02413a6
	SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, _irq5, 0);
f01043b6:	b8 d2 4b 10 f0       	mov    $0xf0104bd2,%eax
f01043bb:	66 a3 a8 13 24 f0    	mov    %ax,0xf02413a8
f01043c1:	66 c7 05 aa 13 24 f0 	movw   $0x8,0xf02413aa
f01043c8:	08 00 
f01043ca:	c6 05 ac 13 24 f0 00 	movb   $0x0,0xf02413ac
f01043d1:	c6 05 ad 13 24 f0 8e 	movb   $0x8e,0xf02413ad
f01043d8:	c1 e8 10             	shr    $0x10,%eax
f01043db:	66 a3 ae 13 24 f0    	mov    %ax,0xf02413ae
	SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, _irq6, 0);
f01043e1:	b8 d8 4b 10 f0       	mov    $0xf0104bd8,%eax
f01043e6:	66 a3 b0 13 24 f0    	mov    %ax,0xf02413b0
f01043ec:	66 c7 05 b2 13 24 f0 	movw   $0x8,0xf02413b2
f01043f3:	08 00 
f01043f5:	c6 05 b4 13 24 f0 00 	movb   $0x0,0xf02413b4
f01043fc:	c6 05 b5 13 24 f0 8e 	movb   $0x8e,0xf02413b5
f0104403:	c1 e8 10             	shr    $0x10,%eax
f0104406:	66 a3 b6 13 24 f0    	mov    %ax,0xf02413b6
	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, _irq7, 0);
f010440c:	b8 de 4b 10 f0       	mov    $0xf0104bde,%eax
f0104411:	66 a3 b8 13 24 f0    	mov    %ax,0xf02413b8
f0104417:	66 c7 05 ba 13 24 f0 	movw   $0x8,0xf02413ba
f010441e:	08 00 
f0104420:	c6 05 bc 13 24 f0 00 	movb   $0x0,0xf02413bc
f0104427:	c6 05 bd 13 24 f0 8e 	movb   $0x8e,0xf02413bd
f010442e:	c1 e8 10             	shr    $0x10,%eax
f0104431:	66 a3 be 13 24 f0    	mov    %ax,0xf02413be
	SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, _irq8, 0);
f0104437:	b8 e4 4b 10 f0       	mov    $0xf0104be4,%eax
f010443c:	66 a3 c0 13 24 f0    	mov    %ax,0xf02413c0
f0104442:	66 c7 05 c2 13 24 f0 	movw   $0x8,0xf02413c2
f0104449:	08 00 
f010444b:	c6 05 c4 13 24 f0 00 	movb   $0x0,0xf02413c4
f0104452:	c6 05 c5 13 24 f0 8e 	movb   $0x8e,0xf02413c5
f0104459:	c1 e8 10             	shr    $0x10,%eax
f010445c:	66 a3 c6 13 24 f0    	mov    %ax,0xf02413c6
	SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, _irq9, 0);
f0104462:	b8 ea 4b 10 f0       	mov    $0xf0104bea,%eax
f0104467:	66 a3 c8 13 24 f0    	mov    %ax,0xf02413c8
f010446d:	66 c7 05 ca 13 24 f0 	movw   $0x8,0xf02413ca
f0104474:	08 00 
f0104476:	c6 05 cc 13 24 f0 00 	movb   $0x0,0xf02413cc
f010447d:	c6 05 cd 13 24 f0 8e 	movb   $0x8e,0xf02413cd
f0104484:	c1 e8 10             	shr    $0x10,%eax
f0104487:	66 a3 ce 13 24 f0    	mov    %ax,0xf02413ce
	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, _irq10, 0);
f010448d:	b8 f0 4b 10 f0       	mov    $0xf0104bf0,%eax
f0104492:	66 a3 d0 13 24 f0    	mov    %ax,0xf02413d0
f0104498:	66 c7 05 d2 13 24 f0 	movw   $0x8,0xf02413d2
f010449f:	08 00 
f01044a1:	c6 05 d4 13 24 f0 00 	movb   $0x0,0xf02413d4
f01044a8:	c6 05 d5 13 24 f0 8e 	movb   $0x8e,0xf02413d5
f01044af:	c1 e8 10             	shr    $0x10,%eax
f01044b2:	66 a3 d6 13 24 f0    	mov    %ax,0xf02413d6
	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, _irq11, 0);
f01044b8:	b8 f6 4b 10 f0       	mov    $0xf0104bf6,%eax
f01044bd:	66 a3 d8 13 24 f0    	mov    %ax,0xf02413d8
f01044c3:	66 c7 05 da 13 24 f0 	movw   $0x8,0xf02413da
f01044ca:	08 00 
f01044cc:	c6 05 dc 13 24 f0 00 	movb   $0x0,0xf02413dc
f01044d3:	c6 05 dd 13 24 f0 8e 	movb   $0x8e,0xf02413dd
f01044da:	c1 e8 10             	shr    $0x10,%eax
f01044dd:	66 a3 de 13 24 f0    	mov    %ax,0xf02413de
	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, _irq12, 0);
f01044e3:	b8 fc 4b 10 f0       	mov    $0xf0104bfc,%eax
f01044e8:	66 a3 e0 13 24 f0    	mov    %ax,0xf02413e0
f01044ee:	66 c7 05 e2 13 24 f0 	movw   $0x8,0xf02413e2
f01044f5:	08 00 
f01044f7:	c6 05 e4 13 24 f0 00 	movb   $0x0,0xf02413e4
f01044fe:	c6 05 e5 13 24 f0 8e 	movb   $0x8e,0xf02413e5
f0104505:	c1 e8 10             	shr    $0x10,%eax
f0104508:	66 a3 e6 13 24 f0    	mov    %ax,0xf02413e6
	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, _irq13, 0);
f010450e:	b8 02 4c 10 f0       	mov    $0xf0104c02,%eax
f0104513:	66 a3 e8 13 24 f0    	mov    %ax,0xf02413e8
f0104519:	66 c7 05 ea 13 24 f0 	movw   $0x8,0xf02413ea
f0104520:	08 00 
f0104522:	c6 05 ec 13 24 f0 00 	movb   $0x0,0xf02413ec
f0104529:	c6 05 ed 13 24 f0 8e 	movb   $0x8e,0xf02413ed
f0104530:	c1 e8 10             	shr    $0x10,%eax
f0104533:	66 a3 ee 13 24 f0    	mov    %ax,0xf02413ee
	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, _irq14, 0);
f0104539:	b8 08 4c 10 f0       	mov    $0xf0104c08,%eax
f010453e:	66 a3 f0 13 24 f0    	mov    %ax,0xf02413f0
f0104544:	66 c7 05 f2 13 24 f0 	movw   $0x8,0xf02413f2
f010454b:	08 00 
f010454d:	c6 05 f4 13 24 f0 00 	movb   $0x0,0xf02413f4
f0104554:	c6 05 f5 13 24 f0 8e 	movb   $0x8e,0xf02413f5
f010455b:	c1 e8 10             	shr    $0x10,%eax
f010455e:	66 a3 f6 13 24 f0    	mov    %ax,0xf02413f6
	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, _irq15, 0);
f0104564:	b8 0e 4c 10 f0       	mov    $0xf0104c0e,%eax
f0104569:	66 a3 f8 13 24 f0    	mov    %ax,0xf02413f8
f010456f:	66 c7 05 fa 13 24 f0 	movw   $0x8,0xf02413fa
f0104576:	08 00 
f0104578:	c6 05 fc 13 24 f0 00 	movb   $0x0,0xf02413fc
f010457f:	c6 05 fd 13 24 f0 8e 	movb   $0x8e,0xf02413fd
f0104586:	c1 e8 10             	shr    $0x10,%eax
f0104589:	66 a3 fe 13 24 f0    	mov    %ax,0xf02413fe

	extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
f010458f:	ba 00 00 00 00       	mov    $0x0,%edx
f0104594:	b8 08 00 00 00       	mov    $0x8,%eax
f0104599:	b9 74 01 00 00       	mov    $0x174,%ecx
f010459e:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP, 0);
f01045a0:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f01045a5:	b9 75 01 00 00       	mov    $0x175,%ecx
f01045aa:	0f 30                	wrmsr  
	wrmsr(0x176, sysenter_handler, 0);
f01045ac:	b8 14 4c 10 f0       	mov    $0xf0104c14,%eax
f01045b1:	b9 76 01 00 00       	mov    $0x176,%ecx
f01045b6:	0f 30                	wrmsr  

	// Per-CPU setup
	trap_init_percpu();
f01045b8:	e8 e5 f8 ff ff       	call   f0103ea2 <trap_init_percpu>
}
f01045bd:	c9                   	leave  
f01045be:	c3                   	ret    

f01045bf <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01045bf:	55                   	push   %ebp
f01045c0:	89 e5                	mov    %esp,%ebp
f01045c2:	53                   	push   %ebx
f01045c3:	83 ec 0c             	sub    $0xc,%esp
f01045c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01045c9:	ff 33                	pushl  (%ebx)
f01045cb:	68 ed 82 10 f0       	push   $0xf01082ed
f01045d0:	e8 b9 f8 ff ff       	call   f0103e8e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01045d5:	83 c4 08             	add    $0x8,%esp
f01045d8:	ff 73 04             	pushl  0x4(%ebx)
f01045db:	68 fc 82 10 f0       	push   $0xf01082fc
f01045e0:	e8 a9 f8 ff ff       	call   f0103e8e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01045e5:	83 c4 08             	add    $0x8,%esp
f01045e8:	ff 73 08             	pushl  0x8(%ebx)
f01045eb:	68 0b 83 10 f0       	push   $0xf010830b
f01045f0:	e8 99 f8 ff ff       	call   f0103e8e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01045f5:	83 c4 08             	add    $0x8,%esp
f01045f8:	ff 73 0c             	pushl  0xc(%ebx)
f01045fb:	68 1a 83 10 f0       	push   $0xf010831a
f0104600:	e8 89 f8 ff ff       	call   f0103e8e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104605:	83 c4 08             	add    $0x8,%esp
f0104608:	ff 73 10             	pushl  0x10(%ebx)
f010460b:	68 29 83 10 f0       	push   $0xf0108329
f0104610:	e8 79 f8 ff ff       	call   f0103e8e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104615:	83 c4 08             	add    $0x8,%esp
f0104618:	ff 73 14             	pushl  0x14(%ebx)
f010461b:	68 38 83 10 f0       	push   $0xf0108338
f0104620:	e8 69 f8 ff ff       	call   f0103e8e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104625:	83 c4 08             	add    $0x8,%esp
f0104628:	ff 73 18             	pushl  0x18(%ebx)
f010462b:	68 47 83 10 f0       	push   $0xf0108347
f0104630:	e8 59 f8 ff ff       	call   f0103e8e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104635:	83 c4 08             	add    $0x8,%esp
f0104638:	ff 73 1c             	pushl  0x1c(%ebx)
f010463b:	68 56 83 10 f0       	push   $0xf0108356
f0104640:	e8 49 f8 ff ff       	call   f0103e8e <cprintf>
}
f0104645:	83 c4 10             	add    $0x10,%esp
f0104648:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010464b:	c9                   	leave  
f010464c:	c3                   	ret    

f010464d <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010464d:	55                   	push   %ebp
f010464e:	89 e5                	mov    %esp,%ebp
f0104650:	56                   	push   %esi
f0104651:	53                   	push   %ebx
f0104652:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104655:	e8 89 22 00 00       	call   f01068e3 <cpunum>
f010465a:	83 ec 04             	sub    $0x4,%esp
f010465d:	50                   	push   %eax
f010465e:	53                   	push   %ebx
f010465f:	68 ba 83 10 f0       	push   $0xf01083ba
f0104664:	e8 25 f8 ff ff       	call   f0103e8e <cprintf>
	print_regs(&tf->tf_regs);
f0104669:	89 1c 24             	mov    %ebx,(%esp)
f010466c:	e8 4e ff ff ff       	call   f01045bf <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104671:	83 c4 08             	add    $0x8,%esp
f0104674:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104678:	50                   	push   %eax
f0104679:	68 d8 83 10 f0       	push   $0xf01083d8
f010467e:	e8 0b f8 ff ff       	call   f0103e8e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104683:	83 c4 08             	add    $0x8,%esp
f0104686:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010468a:	50                   	push   %eax
f010468b:	68 eb 83 10 f0       	push   $0xf01083eb
f0104690:	e8 f9 f7 ff ff       	call   f0103e8e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104695:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104698:	83 c4 10             	add    $0x10,%esp
f010469b:	83 f8 13             	cmp    $0x13,%eax
f010469e:	77 09                	ja     f01046a9 <print_trapframe+0x5c>
		return excnames[trapno];
f01046a0:	8b 14 85 80 86 10 f0 	mov    -0xfef7980(,%eax,4),%edx
f01046a7:	eb 1f                	jmp    f01046c8 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01046a9:	83 f8 30             	cmp    $0x30,%eax
f01046ac:	74 15                	je     f01046c3 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01046ae:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01046b1:	83 fa 10             	cmp    $0x10,%edx
f01046b4:	b9 84 83 10 f0       	mov    $0xf0108384,%ecx
f01046b9:	ba 71 83 10 f0       	mov    $0xf0108371,%edx
f01046be:	0f 43 d1             	cmovae %ecx,%edx
f01046c1:	eb 05                	jmp    f01046c8 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01046c3:	ba 65 83 10 f0       	mov    $0xf0108365,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01046c8:	83 ec 04             	sub    $0x4,%esp
f01046cb:	52                   	push   %edx
f01046cc:	50                   	push   %eax
f01046cd:	68 fe 83 10 f0       	push   $0xf01083fe
f01046d2:	e8 b7 f7 ff ff       	call   f0103e8e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01046d7:	83 c4 10             	add    $0x10,%esp
f01046da:	3b 1d 80 1a 24 f0    	cmp    0xf0241a80,%ebx
f01046e0:	75 1a                	jne    f01046fc <print_trapframe+0xaf>
f01046e2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01046e6:	75 14                	jne    f01046fc <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01046e8:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01046eb:	83 ec 08             	sub    $0x8,%esp
f01046ee:	50                   	push   %eax
f01046ef:	68 10 84 10 f0       	push   $0xf0108410
f01046f4:	e8 95 f7 ff ff       	call   f0103e8e <cprintf>
f01046f9:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01046fc:	83 ec 08             	sub    $0x8,%esp
f01046ff:	ff 73 2c             	pushl  0x2c(%ebx)
f0104702:	68 1f 84 10 f0       	push   $0xf010841f
f0104707:	e8 82 f7 ff ff       	call   f0103e8e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010470c:	83 c4 10             	add    $0x10,%esp
f010470f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104713:	75 49                	jne    f010475e <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104715:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104718:	89 c2                	mov    %eax,%edx
f010471a:	83 e2 01             	and    $0x1,%edx
f010471d:	ba 9e 83 10 f0       	mov    $0xf010839e,%edx
f0104722:	b9 93 83 10 f0       	mov    $0xf0108393,%ecx
f0104727:	0f 44 ca             	cmove  %edx,%ecx
f010472a:	89 c2                	mov    %eax,%edx
f010472c:	83 e2 02             	and    $0x2,%edx
f010472f:	ba b0 83 10 f0       	mov    $0xf01083b0,%edx
f0104734:	be aa 83 10 f0       	mov    $0xf01083aa,%esi
f0104739:	0f 45 d6             	cmovne %esi,%edx
f010473c:	83 e0 04             	and    $0x4,%eax
f010473f:	be 03 85 10 f0       	mov    $0xf0108503,%esi
f0104744:	b8 b5 83 10 f0       	mov    $0xf01083b5,%eax
f0104749:	0f 44 c6             	cmove  %esi,%eax
f010474c:	51                   	push   %ecx
f010474d:	52                   	push   %edx
f010474e:	50                   	push   %eax
f010474f:	68 2d 84 10 f0       	push   $0xf010842d
f0104754:	e8 35 f7 ff ff       	call   f0103e8e <cprintf>
f0104759:	83 c4 10             	add    $0x10,%esp
f010475c:	eb 10                	jmp    f010476e <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010475e:	83 ec 0c             	sub    $0xc,%esp
f0104761:	68 b6 73 10 f0       	push   $0xf01073b6
f0104766:	e8 23 f7 ff ff       	call   f0103e8e <cprintf>
f010476b:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010476e:	83 ec 08             	sub    $0x8,%esp
f0104771:	ff 73 30             	pushl  0x30(%ebx)
f0104774:	68 3c 84 10 f0       	push   $0xf010843c
f0104779:	e8 10 f7 ff ff       	call   f0103e8e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010477e:	83 c4 08             	add    $0x8,%esp
f0104781:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104785:	50                   	push   %eax
f0104786:	68 4b 84 10 f0       	push   $0xf010844b
f010478b:	e8 fe f6 ff ff       	call   f0103e8e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104790:	83 c4 08             	add    $0x8,%esp
f0104793:	ff 73 38             	pushl  0x38(%ebx)
f0104796:	68 5e 84 10 f0       	push   $0xf010845e
f010479b:	e8 ee f6 ff ff       	call   f0103e8e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01047a0:	83 c4 10             	add    $0x10,%esp
f01047a3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01047a7:	74 25                	je     f01047ce <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01047a9:	83 ec 08             	sub    $0x8,%esp
f01047ac:	ff 73 3c             	pushl  0x3c(%ebx)
f01047af:	68 6d 84 10 f0       	push   $0xf010846d
f01047b4:	e8 d5 f6 ff ff       	call   f0103e8e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01047b9:	83 c4 08             	add    $0x8,%esp
f01047bc:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01047c0:	50                   	push   %eax
f01047c1:	68 7c 84 10 f0       	push   $0xf010847c
f01047c6:	e8 c3 f6 ff ff       	call   f0103e8e <cprintf>
f01047cb:	83 c4 10             	add    $0x10,%esp
	}
}
f01047ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01047d1:	5b                   	pop    %ebx
f01047d2:	5e                   	pop    %esi
f01047d3:	5d                   	pop    %ebp
f01047d4:	c3                   	ret    

f01047d5 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01047d5:	55                   	push   %ebp
f01047d6:	89 e5                	mov    %esp,%ebp
f01047d8:	57                   	push   %edi
f01047d9:	56                   	push   %esi
f01047da:	53                   	push   %ebx
f01047db:	83 ec 0c             	sub    $0xc,%esp
f01047de:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01047e1:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (!(tf->tf_cs & 0x3)) {
f01047e4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01047e8:	75 17                	jne    f0104801 <page_fault_handler+0x2c>
		panic("Kernel mode page fault.\n");
f01047ea:	83 ec 04             	sub    $0x4,%esp
f01047ed:	68 8f 84 10 f0       	push   $0xf010848f
f01047f2:	68 75 01 00 00       	push   $0x175
f01047f7:	68 a8 84 10 f0       	push   $0xf01084a8
f01047fc:	e8 3f b8 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// cprintf("curenv->env_pgfault_upcall: %x\n", curenv->env_pgfault_upcall);
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall) {
f0104801:	e8 dd 20 00 00       	call   f01068e3 <cpunum>
f0104806:	6b c0 74             	imul   $0x74,%eax,%eax
f0104809:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f010480f:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f0104813:	0f 84 d4 00 00 00    	je     f01048ed <page_fault_handler+0x118>
		if (curenv->env_tf.tf_esp >= UXSTACKTOP - PGSIZE &&
f0104819:	e8 c5 20 00 00       	call   f01068e3 <cpunum>
f010481e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104821:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
			curenv->env_tf.tf_esp < UXSTACKTOP) {
			utf = (struct UTrapframe *)
						(curenv->env_tf.tf_esp - sizeof(struct UTrapframe) - 4);
		} else {
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0104827:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi

	// LAB 4: Your code here.
	// cprintf("curenv->env_pgfault_upcall: %x\n", curenv->env_pgfault_upcall);
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall) {
		if (curenv->env_tf.tf_esp >= UXSTACKTOP - PGSIZE &&
f010482c:	81 78 3c ff ef bf ee 	cmpl   $0xeebfefff,0x3c(%eax)
f0104833:	76 2d                	jbe    f0104862 <page_fault_handler+0x8d>
			curenv->env_tf.tf_esp < UXSTACKTOP) {
f0104835:	e8 a9 20 00 00       	call   f01068e3 <cpunum>
f010483a:	6b c0 74             	imul   $0x74,%eax,%eax
f010483d:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax

	// LAB 4: Your code here.
	// cprintf("curenv->env_pgfault_upcall: %x\n", curenv->env_pgfault_upcall);
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall) {
		if (curenv->env_tf.tf_esp >= UXSTACKTOP - PGSIZE &&
f0104843:	81 78 3c ff ff bf ee 	cmpl   $0xeebfffff,0x3c(%eax)
f010484a:	77 16                	ja     f0104862 <page_fault_handler+0x8d>
			curenv->env_tf.tf_esp < UXSTACKTOP) {
			utf = (struct UTrapframe *)
						(curenv->env_tf.tf_esp - sizeof(struct UTrapframe) - 4);
f010484c:	e8 92 20 00 00       	call   f01068e3 <cpunum>
f0104851:	6b c0 74             	imul   $0x74,%eax,%eax
f0104854:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
	// cprintf("curenv->env_pgfault_upcall: %x\n", curenv->env_pgfault_upcall);
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall) {
		if (curenv->env_tf.tf_esp >= UXSTACKTOP - PGSIZE &&
			curenv->env_tf.tf_esp < UXSTACKTOP) {
			utf = (struct UTrapframe *)
f010485a:	8b 40 3c             	mov    0x3c(%eax),%eax
f010485d:	83 e8 38             	sub    $0x38,%eax
f0104860:	89 c7                	mov    %eax,%edi
						(curenv->env_tf.tf_esp - sizeof(struct UTrapframe) - 4);
		} else {
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W);
f0104862:	e8 7c 20 00 00       	call   f01068e3 <cpunum>
f0104867:	6a 02                	push   $0x2
f0104869:	6a 34                	push   $0x34
f010486b:	57                   	push   %edi
f010486c:	6b c0 74             	imul   $0x74,%eax,%eax
f010486f:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104875:	e8 2b ec ff ff       	call   f01034a5 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f010487a:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f010487c:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010487f:	89 fa                	mov    %edi,%edx
f0104881:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0104884:	8d 7f 08             	lea    0x8(%edi),%edi
f0104887:	b9 08 00 00 00       	mov    $0x8,%ecx
f010488c:	89 de                	mov    %ebx,%esi
f010488e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0104890:	8b 43 30             	mov    0x30(%ebx),%eax
f0104893:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104896:	8b 43 38             	mov    0x38(%ebx),%eax
f0104899:	89 d7                	mov    %edx,%edi
f010489b:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f010489e:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01048a1:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f01048a4:	e8 3a 20 00 00       	call   f01068e3 <cpunum>
f01048a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ac:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01048b2:	89 78 3c             	mov    %edi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f01048b5:	e8 29 20 00 00       	call   f01068e3 <cpunum>
f01048ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01048bd:	8b 98 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%ebx
f01048c3:	e8 1b 20 00 00       	call   f01068e3 <cpunum>
f01048c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01048cb:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01048d1:	8b 40 68             	mov    0x68(%eax),%eax
f01048d4:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f01048d7:	e8 07 20 00 00       	call   f01068e3 <cpunum>
f01048dc:	83 c4 04             	add    $0x4,%esp
f01048df:	6b c0 74             	imul   $0x74,%eax,%eax
f01048e2:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f01048e8:	e8 23 f3 ff ff       	call   f0103c10 <env_run>
	} else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01048ed:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f01048f0:	e8 ee 1f 00 00       	call   f01068e3 <cpunum>
		curenv->env_tf.tf_esp = (uint32_t)utf;
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
		env_run(curenv);
	} else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01048f5:	57                   	push   %edi
f01048f6:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f01048f7:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv->env_tf.tf_esp = (uint32_t)utf;
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
		env_run(curenv);
	} else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01048fa:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104900:	ff 70 48             	pushl  0x48(%eax)
f0104903:	68 50 86 10 f0       	push   $0xf0108650
f0104908:	e8 81 f5 ff ff       	call   f0103e8e <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f010490d:	89 1c 24             	mov    %ebx,(%esp)
f0104910:	e8 38 fd ff ff       	call   f010464d <print_trapframe>
		env_destroy(curenv);
f0104915:	e8 c9 1f 00 00       	call   f01068e3 <cpunum>
f010491a:	83 c4 04             	add    $0x4,%esp
f010491d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104920:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104926:	e8 46 f2 ff ff       	call   f0103b71 <env_destroy>
	}
}
f010492b:	83 c4 10             	add    $0x10,%esp
f010492e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104931:	5b                   	pop    %ebx
f0104932:	5e                   	pop    %esi
f0104933:	5f                   	pop    %edi
f0104934:	5d                   	pop    %ebp
f0104935:	c3                   	ret    

f0104936 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104936:	55                   	push   %ebp
f0104937:	89 e5                	mov    %esp,%ebp
f0104939:	57                   	push   %edi
f010493a:	56                   	push   %esi
f010493b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010493e:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010493f:	83 3d a0 1e 24 f0 00 	cmpl   $0x0,0xf0241ea0
f0104946:	74 01                	je     f0104949 <trap+0x13>
		asm volatile("hlt");
f0104948:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104949:	9c                   	pushf  
f010494a:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010494b:	f6 c4 02             	test   $0x2,%ah
f010494e:	74 19                	je     f0104969 <trap+0x33>
f0104950:	68 b4 84 10 f0       	push   $0xf01084b4
f0104955:	68 1b 7e 10 f0       	push   $0xf0107e1b
f010495a:	68 3f 01 00 00       	push   $0x13f
f010495f:	68 a8 84 10 f0       	push   $0xf01084a8
f0104964:	e8 d7 b6 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104969:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010496d:	83 e0 03             	and    $0x3,%eax
f0104970:	66 83 f8 03          	cmp    $0x3,%ax
f0104974:	0f 85 a0 00 00 00    	jne    f0104a1a <trap+0xe4>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f010497a:	e8 64 1f 00 00       	call   f01068e3 <cpunum>
f010497f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104982:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0104989:	75 19                	jne    f01049a4 <trap+0x6e>
f010498b:	68 cd 84 10 f0       	push   $0xf01084cd
f0104990:	68 1b 7e 10 f0       	push   $0xf0107e1b
f0104995:	68 46 01 00 00       	push   $0x146
f010499a:	68 a8 84 10 f0       	push   $0xf01084a8
f010499f:	e8 9c b6 ff ff       	call   f0100040 <_panic>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01049a4:	83 ec 0c             	sub    $0xc,%esp
f01049a7:	68 a0 23 12 f0       	push   $0xf01223a0
f01049ac:	e8 a0 21 00 00       	call   f0106b51 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01049b1:	e8 2d 1f 00 00       	call   f01068e3 <cpunum>
f01049b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b9:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01049bf:	83 c4 10             	add    $0x10,%esp
f01049c2:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01049c6:	75 2d                	jne    f01049f5 <trap+0xbf>
			env_free(curenv);
f01049c8:	e8 16 1f 00 00       	call   f01068e3 <cpunum>
f01049cd:	83 ec 0c             	sub    $0xc,%esp
f01049d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d3:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f01049d9:	e8 b8 ef ff ff       	call   f0103996 <env_free>
			curenv = NULL;
f01049de:	e8 00 1f 00 00       	call   f01068e3 <cpunum>
f01049e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e6:	c7 80 28 20 24 f0 00 	movl   $0x0,-0xfdbdfd8(%eax)
f01049ed:	00 00 00 
			sched_yield();
f01049f0:	e8 6d 02 00 00       	call   f0104c62 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01049f5:	e8 e9 1e 00 00       	call   f01068e3 <cpunum>
f01049fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01049fd:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104a03:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a08:	89 c7                	mov    %eax,%edi
f0104a0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104a0c:	e8 d2 1e 00 00       	call   f01068e3 <cpunum>
f0104a11:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a14:	8b b0 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104a1a:	89 35 80 1a 24 f0    	mov    %esi,0xf0241a80
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
f0104a20:	8b 46 28             	mov    0x28(%esi),%eax
f0104a23:	83 f8 03             	cmp    $0x3,%eax
f0104a26:	74 1a                	je     f0104a42 <trap+0x10c>
f0104a28:	83 f8 0e             	cmp    $0xe,%eax
f0104a2b:	74 07                	je     f0104a34 <trap+0xfe>
f0104a2d:	83 f8 01             	cmp    $0x1,%eax
f0104a30:	75 1c                	jne    f0104a4e <trap+0x118>
f0104a32:	eb 0e                	jmp    f0104a42 <trap+0x10c>
		// case T_SYSCALL:
		// 	syscall_helper(tf);
		// 	break;
		case T_PGFLT:
			page_fault_handler(tf);
f0104a34:	83 ec 0c             	sub    $0xc,%esp
f0104a37:	56                   	push   %esi
f0104a38:	e8 98 fd ff ff       	call   f01047d5 <page_fault_handler>
f0104a3d:	83 c4 10             	add    $0x10,%esp
f0104a40:	eb 0c                	jmp    f0104a4e <trap+0x118>
			break;
		case T_DEBUG:
		case T_BRKPT:
			monitor(tf);
f0104a42:	83 ec 0c             	sub    $0xc,%esp
f0104a45:	56                   	push   %esi
f0104a46:	e8 d3 c1 ff ff       	call   f0100c1e <monitor>
f0104a4b:	83 c4 10             	add    $0x10,%esp
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104a4e:	8b 46 28             	mov    0x28(%esi),%eax
f0104a51:	83 f8 27             	cmp    $0x27,%eax
f0104a54:	75 1a                	jne    f0104a70 <trap+0x13a>
		cprintf("Spurious interrupt on irq 7\n");
f0104a56:	83 ec 0c             	sub    $0xc,%esp
f0104a59:	68 d4 84 10 f0       	push   $0xf01084d4
f0104a5e:	e8 2b f4 ff ff       	call   f0103e8e <cprintf>
		print_trapframe(tf);
f0104a63:	89 34 24             	mov    %esi,(%esp)
f0104a66:	e8 e2 fb ff ff       	call   f010464d <print_trapframe>
f0104a6b:	83 c4 10             	add    $0x10,%esp
f0104a6e:	eb 52                	jmp    f0104ac2 <trap+0x18c>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104a70:	83 f8 20             	cmp    $0x20,%eax
f0104a73:	75 0a                	jne    f0104a7f <trap+0x149>
		lapic_eoi();
f0104a75:	e8 9e 1f 00 00       	call   f0106a18 <lapic_eoi>
		sched_yield();
f0104a7a:	e8 e3 01 00 00       	call   f0104c62 <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104a7f:	83 ec 0c             	sub    $0xc,%esp
f0104a82:	56                   	push   %esi
f0104a83:	e8 c5 fb ff ff       	call   f010464d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104a88:	83 c4 10             	add    $0x10,%esp
f0104a8b:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104a90:	75 17                	jne    f0104aa9 <trap+0x173>
		panic("unhandled trap in kernel");
f0104a92:	83 ec 04             	sub    $0x4,%esp
f0104a95:	68 f1 84 10 f0       	push   $0xf01084f1
f0104a9a:	68 29 01 00 00       	push   $0x129
f0104a9f:	68 a8 84 10 f0       	push   $0xf01084a8
f0104aa4:	e8 97 b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104aa9:	e8 35 1e 00 00       	call   f01068e3 <cpunum>
f0104aae:	83 ec 0c             	sub    $0xc,%esp
f0104ab1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab4:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104aba:	e8 b2 f0 ff ff       	call   f0103b71 <env_destroy>
f0104abf:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104ac2:	e8 1c 1e 00 00       	call   f01068e3 <cpunum>
f0104ac7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aca:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0104ad1:	74 2a                	je     f0104afd <trap+0x1c7>
f0104ad3:	e8 0b 1e 00 00       	call   f01068e3 <cpunum>
f0104ad8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104adb:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104ae1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104ae5:	75 16                	jne    f0104afd <trap+0x1c7>
		env_run(curenv);
f0104ae7:	e8 f7 1d 00 00       	call   f01068e3 <cpunum>
f0104aec:	83 ec 0c             	sub    $0xc,%esp
f0104aef:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af2:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104af8:	e8 13 f1 ff ff       	call   f0103c10 <env_run>
	else
		sched_yield();
f0104afd:	e8 60 01 00 00       	call   f0104c62 <sched_yield>

f0104b02 <_divide_error>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
  TRAPHANDLER_NOEC(_divide_error, T_DIVIDE);
f0104b02:	6a 00                	push   $0x0
f0104b04:	6a 00                	push   $0x0
f0104b06:	e9 3d 01 00 00       	jmp    f0104c48 <_alltraps>
f0104b0b:	90                   	nop

f0104b0c <_debug>:
  TRAPHANDLER_NOEC(_debug, T_DEBUG);
f0104b0c:	6a 00                	push   $0x0
f0104b0e:	6a 01                	push   $0x1
f0104b10:	e9 33 01 00 00       	jmp    f0104c48 <_alltraps>
f0104b15:	90                   	nop

f0104b16 <_non_maskable_interrupt>:
  TRAPHANDLER_NOEC(_non_maskable_interrupt, T_NMI);
f0104b16:	6a 00                	push   $0x0
f0104b18:	6a 02                	push   $0x2
f0104b1a:	e9 29 01 00 00       	jmp    f0104c48 <_alltraps>
f0104b1f:	90                   	nop

f0104b20 <_breakpoint>:
  TRAPHANDLER_NOEC(_breakpoint, T_BRKPT);
f0104b20:	6a 00                	push   $0x0
f0104b22:	6a 03                	push   $0x3
f0104b24:	e9 1f 01 00 00       	jmp    f0104c48 <_alltraps>
f0104b29:	90                   	nop

f0104b2a <_overflow>:
  TRAPHANDLER_NOEC(_overflow, T_OFLOW);
f0104b2a:	6a 00                	push   $0x0
f0104b2c:	6a 04                	push   $0x4
f0104b2e:	e9 15 01 00 00       	jmp    f0104c48 <_alltraps>
f0104b33:	90                   	nop

f0104b34 <_bound_range_exceeded>:
  TRAPHANDLER_NOEC(_bound_range_exceeded, T_BOUND);
f0104b34:	6a 00                	push   $0x0
f0104b36:	6a 05                	push   $0x5
f0104b38:	e9 0b 01 00 00       	jmp    f0104c48 <_alltraps>
f0104b3d:	90                   	nop

f0104b3e <_invalid_opcode>:
  TRAPHANDLER_NOEC(_invalid_opcode, T_ILLOP);
f0104b3e:	6a 00                	push   $0x0
f0104b40:	6a 06                	push   $0x6
f0104b42:	e9 01 01 00 00       	jmp    f0104c48 <_alltraps>
f0104b47:	90                   	nop

f0104b48 <_device_not_available>:
  TRAPHANDLER_NOEC(_device_not_available, T_DEVICE);
f0104b48:	6a 00                	push   $0x0
f0104b4a:	6a 07                	push   $0x7
f0104b4c:	e9 f7 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b51:	90                   	nop

f0104b52 <_double_fault>:
  TRAPHANDLER(_double_fault, T_DBLFLT);
f0104b52:	6a 08                	push   $0x8
f0104b54:	e9 ef 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b59:	90                   	nop

f0104b5a <_invalid_tss>:

  TRAPHANDLER(_invalid_tss, T_TSS);
f0104b5a:	6a 0a                	push   $0xa
f0104b5c:	e9 e7 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b61:	90                   	nop

f0104b62 <_segment_not_present>:
  TRAPHANDLER(_segment_not_present, T_SEGNP);
f0104b62:	6a 0b                	push   $0xb
f0104b64:	e9 df 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b69:	90                   	nop

f0104b6a <_stack_fault>:
  TRAPHANDLER(_stack_fault, T_STACK);
f0104b6a:	6a 0c                	push   $0xc
f0104b6c:	e9 d7 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b71:	90                   	nop

f0104b72 <_general_protection>:
  TRAPHANDLER(_general_protection, T_GPFLT);
f0104b72:	6a 0d                	push   $0xd
f0104b74:	e9 cf 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b79:	90                   	nop

f0104b7a <_page_fault>:
  TRAPHANDLER(_page_fault, T_PGFLT);
f0104b7a:	6a 0e                	push   $0xe
f0104b7c:	e9 c7 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b81:	90                   	nop

f0104b82 <_x87_fpu_error>:

  TRAPHANDLER_NOEC(_x87_fpu_error, T_FPERR);
f0104b82:	6a 00                	push   $0x0
f0104b84:	6a 10                	push   $0x10
f0104b86:	e9 bd 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b8b:	90                   	nop

f0104b8c <_alignment_check>:
  TRAPHANDLER(_alignment_check, T_ALIGN);
f0104b8c:	6a 11                	push   $0x11
f0104b8e:	e9 b5 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b93:	90                   	nop

f0104b94 <_machine_check>:
  TRAPHANDLER_NOEC(_machine_check, T_MCHK);
f0104b94:	6a 00                	push   $0x0
f0104b96:	6a 12                	push   $0x12
f0104b98:	e9 ab 00 00 00       	jmp    f0104c48 <_alltraps>
f0104b9d:	90                   	nop

f0104b9e <_simd_fp_exception>:
  TRAPHANDLER_NOEC(_simd_fp_exception, T_SIMDERR );
f0104b9e:	6a 00                	push   $0x0
f0104ba0:	6a 13                	push   $0x13
f0104ba2:	e9 a1 00 00 00       	jmp    f0104c48 <_alltraps>
f0104ba7:	90                   	nop

f0104ba8 <_irq0>:

  TRAPHANDLER_NOEC(_irq0, IRQ_OFFSET + 0);
f0104ba8:	6a 00                	push   $0x0
f0104baa:	6a 20                	push   $0x20
f0104bac:	e9 97 00 00 00       	jmp    f0104c48 <_alltraps>
f0104bb1:	90                   	nop

f0104bb2 <_irq1>:
  TRAPHANDLER_NOEC(_irq1, IRQ_OFFSET + 1);
f0104bb2:	6a 00                	push   $0x0
f0104bb4:	6a 21                	push   $0x21
f0104bb6:	e9 8d 00 00 00       	jmp    f0104c48 <_alltraps>
f0104bbb:	90                   	nop

f0104bbc <_irq2>:
  TRAPHANDLER_NOEC(_irq2, IRQ_OFFSET + 2);
f0104bbc:	6a 00                	push   $0x0
f0104bbe:	6a 22                	push   $0x22
f0104bc0:	e9 83 00 00 00       	jmp    f0104c48 <_alltraps>
f0104bc5:	90                   	nop

f0104bc6 <_irq3>:
  TRAPHANDLER_NOEC(_irq3, IRQ_OFFSET + 3);
f0104bc6:	6a 00                	push   $0x0
f0104bc8:	6a 23                	push   $0x23
f0104bca:	eb 7c                	jmp    f0104c48 <_alltraps>

f0104bcc <_irq4>:
  TRAPHANDLER_NOEC(_irq4, IRQ_OFFSET + 4);
f0104bcc:	6a 00                	push   $0x0
f0104bce:	6a 24                	push   $0x24
f0104bd0:	eb 76                	jmp    f0104c48 <_alltraps>

f0104bd2 <_irq5>:
  TRAPHANDLER_NOEC(_irq5, IRQ_OFFSET + 5);
f0104bd2:	6a 00                	push   $0x0
f0104bd4:	6a 25                	push   $0x25
f0104bd6:	eb 70                	jmp    f0104c48 <_alltraps>

f0104bd8 <_irq6>:
  TRAPHANDLER_NOEC(_irq6, IRQ_OFFSET + 6);
f0104bd8:	6a 00                	push   $0x0
f0104bda:	6a 26                	push   $0x26
f0104bdc:	eb 6a                	jmp    f0104c48 <_alltraps>

f0104bde <_irq7>:
  TRAPHANDLER_NOEC(_irq7, IRQ_OFFSET + 7);
f0104bde:	6a 00                	push   $0x0
f0104be0:	6a 27                	push   $0x27
f0104be2:	eb 64                	jmp    f0104c48 <_alltraps>

f0104be4 <_irq8>:
  TRAPHANDLER_NOEC(_irq8, IRQ_OFFSET + 8);
f0104be4:	6a 00                	push   $0x0
f0104be6:	6a 28                	push   $0x28
f0104be8:	eb 5e                	jmp    f0104c48 <_alltraps>

f0104bea <_irq9>:
  TRAPHANDLER_NOEC(_irq9, IRQ_OFFSET + 9);
f0104bea:	6a 00                	push   $0x0
f0104bec:	6a 29                	push   $0x29
f0104bee:	eb 58                	jmp    f0104c48 <_alltraps>

f0104bf0 <_irq10>:
  TRAPHANDLER_NOEC(_irq10, IRQ_OFFSET + 10);
f0104bf0:	6a 00                	push   $0x0
f0104bf2:	6a 2a                	push   $0x2a
f0104bf4:	eb 52                	jmp    f0104c48 <_alltraps>

f0104bf6 <_irq11>:
  TRAPHANDLER_NOEC(_irq11, IRQ_OFFSET + 11);
f0104bf6:	6a 00                	push   $0x0
f0104bf8:	6a 2b                	push   $0x2b
f0104bfa:	eb 4c                	jmp    f0104c48 <_alltraps>

f0104bfc <_irq12>:
  TRAPHANDLER_NOEC(_irq12, IRQ_OFFSET + 12);
f0104bfc:	6a 00                	push   $0x0
f0104bfe:	6a 2c                	push   $0x2c
f0104c00:	eb 46                	jmp    f0104c48 <_alltraps>

f0104c02 <_irq13>:
  TRAPHANDLER_NOEC(_irq13, IRQ_OFFSET + 13);
f0104c02:	6a 00                	push   $0x0
f0104c04:	6a 2d                	push   $0x2d
f0104c06:	eb 40                	jmp    f0104c48 <_alltraps>

f0104c08 <_irq14>:
  TRAPHANDLER_NOEC(_irq14, IRQ_OFFSET + 14);
f0104c08:	6a 00                	push   $0x0
f0104c0a:	6a 2e                	push   $0x2e
f0104c0c:	eb 3a                	jmp    f0104c48 <_alltraps>

f0104c0e <_irq15>:
  TRAPHANDLER_NOEC(_irq15, IRQ_OFFSET + 15);
f0104c0e:	6a 00                	push   $0x0
f0104c10:	6a 2f                	push   $0x2f
f0104c12:	eb 34                	jmp    f0104c48 <_alltraps>

f0104c14 <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
   pushl $GD_UD | 3
f0104c14:	6a 23                	push   $0x23
   pushl %ebp
f0104c16:	55                   	push   %ebp
   pushfl
f0104c17:	9c                   	pushf  
   pushl $GD_UT | 3
f0104c18:	6a 1b                	push   $0x1b
   pushl %esi
f0104c1a:	56                   	push   %esi
   pushl $0
f0104c1b:	6a 00                	push   $0x0
 	 pushl $0
f0104c1d:	6a 00                	push   $0x0

   pushw $0    # uint16_t tf_padding2
f0104c1f:	66 6a 00             	pushw  $0x0
   pushw %ds
f0104c22:	66 1e                	pushw  %ds
   pushw $0    # uint16_t tf_padding1
f0104c24:	66 6a 00             	pushw  $0x0
   pushw %es
f0104c27:	66 06                	pushw  %es
   pushal
f0104c29:	60                   	pusha  

   movw $GD_KD, %ax
f0104c2a:	66 b8 10 00          	mov    $0x10,%ax
   movw %ax, %ds
f0104c2e:	8e d8                	mov    %eax,%ds
   movw %ax, %es
f0104c30:	8e c0                	mov    %eax,%es
   pushl %esp
f0104c32:	54                   	push   %esp

   call syscall_helper
f0104c33:	e8 ce 06 00 00       	call   f0105306 <syscall_helper>

   popl %esp
f0104c38:	5c                   	pop    %esp
   popal
f0104c39:	61                   	popa   
   popw %cx  # eliminate padding
f0104c3a:	66 59                	pop    %cx
   popw %es
f0104c3c:	66 07                	popw   %es
   popw %cx  # eliminate padding
f0104c3e:	66 59                	pop    %cx
   popw %ds
f0104c40:	66 1f                	popw   %ds

   movl %ebp, %ecx
f0104c42:	89 e9                	mov    %ebp,%ecx
   movl %esi, %edx
f0104c44:	89 f2                	mov    %esi,%edx
   sysexit
f0104c46:	0f 35                	sysexit 

f0104c48 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
  pushw $0    # uint16_t tf_padding2
f0104c48:	66 6a 00             	pushw  $0x0
	pushw %ds
f0104c4b:	66 1e                	pushw  %ds
	pushw $0    # uint16_t tf_padding1
f0104c4d:	66 6a 00             	pushw  $0x0
	pushw %es
f0104c50:	66 06                	pushw  %es
	pushal
f0104c52:	60                   	pusha  

  movl $GD_KD, %eax
f0104c53:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104c58:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104c5a:	8e c0                	mov    %eax,%es
	pushl %esp
f0104c5c:	54                   	push   %esp

	call trap
f0104c5d:	e8 d4 fc ff ff       	call   f0104936 <trap>

f0104c62 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104c62:	55                   	push   %ebp
f0104c63:	89 e5                	mov    %esp,%ebp
f0104c65:	56                   	push   %esi
f0104c66:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
	// cprintf("CPU %d\n", cpunum());
	if (curenv) {
f0104c67:	e8 77 1c 00 00       	call   f01068e3 <cpunum>
f0104c6c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c6f:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0104c76:	0f 84 80 00 00 00    	je     f0104cfc <sched_yield+0x9a>
		int cur_env_id = ENVX(curenv->env_id);
f0104c7c:	e8 62 1c 00 00       	call   f01068e3 <cpunum>
f0104c81:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c84:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104c8a:	8b 50 48             	mov    0x48(%eax),%edx
f0104c8d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
		for (i = (cur_env_id + 1) % NENV; i != cur_env_id; i = (i + 1) % NENV) {
f0104c93:	8d 42 01             	lea    0x1(%edx),%eax
f0104c96:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104c9b:	89 c6                	mov    %eax,%esi
f0104c9d:	39 c2                	cmp    %eax,%edx
f0104c9f:	0f 84 e1 00 00 00    	je     f0104d86 <sched_yield+0x124>
			if (envs[i].env_status == ENV_RUNNABLE &&
f0104ca5:	8b 0d 6c 12 24 f0    	mov    0xf024126c,%ecx
f0104cab:	89 f3                	mov    %esi,%ebx
f0104cad:	c1 e3 07             	shl    $0x7,%ebx
f0104cb0:	01 cb                	add    %ecx,%ebx
f0104cb2:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104cb6:	75 0f                	jne    f0104cc7 <sched_yield+0x65>
f0104cb8:	83 7b 50 01          	cmpl   $0x1,0x50(%ebx)
f0104cbc:	74 09                	je     f0104cc7 <sched_yield+0x65>
					envs[i].env_type != ENV_TYPE_IDLE) {
			  // cprintf("sched_yield CPU %d, i = %d\n", cpunum(), i);
				env_run(&envs[i]);
f0104cbe:	83 ec 0c             	sub    $0xc,%esp
f0104cc1:	53                   	push   %ebx
f0104cc2:	e8 49 ef ff ff       	call   f0103c10 <env_run>

	// LAB 4: Your code here.
	// cprintf("CPU %d\n", cpunum());
	if (curenv) {
		int cur_env_id = ENVX(curenv->env_id);
		for (i = (cur_env_id + 1) % NENV; i != cur_env_id; i = (i + 1) % NENV) {
f0104cc7:	8d 46 01             	lea    0x1(%esi),%eax
f0104cca:	89 c3                	mov    %eax,%ebx
f0104ccc:	c1 fb 1f             	sar    $0x1f,%ebx
f0104ccf:	c1 eb 16             	shr    $0x16,%ebx
f0104cd2:	01 d8                	add    %ebx,%eax
f0104cd4:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104cd9:	29 d8                	sub    %ebx,%eax
f0104cdb:	89 c6                	mov    %eax,%esi
f0104cdd:	39 c2                	cmp    %eax,%edx
f0104cdf:	75 ca                	jne    f0104cab <sched_yield+0x49>
f0104ce1:	e9 a0 00 00 00       	jmp    f0104d86 <sched_yield+0x124>
				break;
			}
		}
		if (i == cur_env_id && curenv->env_status == ENV_RUNNING) {
			// cprintf("sched_yield CPU %d, i = %d\n", cpunum(), i);
			env_run(curenv);
f0104ce6:	e8 f8 1b 00 00       	call   f01068e3 <cpunum>
f0104ceb:	83 ec 0c             	sub    $0xc,%esp
f0104cee:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cf1:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104cf7:	e8 14 ef ff ff       	call   f0103c10 <env_run>

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0104cfc:	8b 1d 6c 12 24 f0    	mov    0xf024126c,%ebx
f0104d02:	8d 43 50             	lea    0x50(%ebx),%eax
	}

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104d05:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0104d0a:	83 38 01             	cmpl   $0x1,(%eax)
f0104d0d:	74 0b                	je     f0104d1a <sched_yield+0xb8>
f0104d0f:	8b 70 04             	mov    0x4(%eax),%esi
f0104d12:	8d 4e fe             	lea    -0x2(%esi),%ecx
f0104d15:	83 f9 01             	cmp    $0x1,%ecx
f0104d18:	76 10                	jbe    f0104d2a <sched_yield+0xc8>
	}

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104d1a:	83 c2 01             	add    $0x1,%edx
f0104d1d:	83 e8 80             	sub    $0xffffff80,%eax
f0104d20:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104d26:	75 e2                	jne    f0104d0a <sched_yield+0xa8>
f0104d28:	eb 08                	jmp    f0104d32 <sched_yield+0xd0>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104d2a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104d30:	75 1f                	jne    f0104d51 <sched_yield+0xef>
		cprintf("No more runnable environments!\n");
f0104d32:	83 ec 0c             	sub    $0xc,%esp
f0104d35:	68 d0 86 10 f0       	push   $0xf01086d0
f0104d3a:	e8 4f f1 ff ff       	call   f0103e8e <cprintf>
f0104d3f:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104d42:	83 ec 0c             	sub    $0xc,%esp
f0104d45:	6a 00                	push   $0x0
f0104d47:	e8 d2 be ff ff       	call   f0100c1e <monitor>
f0104d4c:	83 c4 10             	add    $0x10,%esp
f0104d4f:	eb f1                	jmp    f0104d42 <sched_yield+0xe0>
	}
	// cprintf("sched_yield CPU %d, i = %d\n", cpunum(), i);

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0104d51:	e8 8d 1b 00 00       	call   f01068e3 <cpunum>
f0104d56:	c1 e0 07             	shl    $0x7,%eax
f0104d59:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f0104d5b:	8b 43 54             	mov    0x54(%ebx),%eax
f0104d5e:	83 e8 02             	sub    $0x2,%eax
f0104d61:	83 f8 01             	cmp    $0x1,%eax
f0104d64:	76 17                	jbe    f0104d7d <sched_yield+0x11b>
		panic("CPU %d: No idle environment!", cpunum());
f0104d66:	e8 78 1b 00 00       	call   f01068e3 <cpunum>
f0104d6b:	50                   	push   %eax
f0104d6c:	68 f0 86 10 f0       	push   $0xf01086f0
f0104d71:	6a 44                	push   $0x44
f0104d73:	68 0d 87 10 f0       	push   $0xf010870d
f0104d78:	e8 c3 b2 ff ff       	call   f0100040 <_panic>
	env_run(idle);
f0104d7d:	83 ec 0c             	sub    $0xc,%esp
f0104d80:	53                   	push   %ebx
f0104d81:	e8 8a ee ff ff       	call   f0103c10 <env_run>
			  // cprintf("sched_yield CPU %d, i = %d\n", cpunum(), i);
				env_run(&envs[i]);
				break;
			}
		}
		if (i == cur_env_id && curenv->env_status == ENV_RUNNING) {
f0104d86:	e8 58 1b 00 00       	call   f01068e3 <cpunum>
f0104d8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d8e:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104d94:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104d98:	0f 85 5e ff ff ff    	jne    f0104cfc <sched_yield+0x9a>
f0104d9e:	e9 43 ff ff ff       	jmp    f0104ce6 <sched_yield+0x84>

f0104da3 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104da3:	55                   	push   %ebp
f0104da4:	89 e5                	mov    %esp,%ebp
f0104da6:	57                   	push   %edi
f0104da7:	56                   	push   %esi
f0104da8:	53                   	push   %ebx
f0104da9:	83 ec 2c             	sub    $0x2c,%esp
f0104dac:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int t;
	switch (syscallno) {
f0104daf:	83 f8 0e             	cmp    $0xe,%eax
f0104db2:	0f 87 3f 05 00 00    	ja     f01052f7 <syscall+0x554>
f0104db8:	ff 24 85 64 87 10 f0 	jmp    *-0xfef789c(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, 0);
f0104dbf:	e8 1f 1b 00 00       	call   f01068e3 <cpunum>
f0104dc4:	6a 00                	push   $0x0
f0104dc6:	ff 75 10             	pushl  0x10(%ebp)
f0104dc9:	ff 75 0c             	pushl  0xc(%ebp)
f0104dcc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dcf:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104dd5:	e8 cb e6 ff ff       	call   f01034a5 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104dda:	83 c4 0c             	add    $0xc,%esp
f0104ddd:	ff 75 0c             	pushl  0xc(%ebp)
f0104de0:	ff 75 10             	pushl  0x10(%ebp)
f0104de3:	68 1a 87 10 f0       	push   $0xf010871a
f0104de8:	e8 a1 f0 ff ff       	call   f0103e8e <cprintf>
f0104ded:	83 c4 10             	add    $0x10,%esp
	int t;
	switch (syscallno) {
		case SYS_cputs:
			// cprintf("SYS_cputs\n");
			sys_cputs((const char *) a1, a2);
			return 0;
f0104df0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104df5:	e9 02 05 00 00       	jmp    f01052fc <syscall+0x559>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104dfa:	e8 48 b9 ff ff       	call   f0100747 <cons_getc>
f0104dff:	89 c3                	mov    %eax,%ebx
			// cprintf("SYS_cputs\n");
			sys_cputs((const char *) a1, a2);
			return 0;
		case SYS_cgetc:
			// cprintf("SYS_cgetc\n");
			return sys_cgetc();
f0104e01:	e9 f6 04 00 00       	jmp    f01052fc <syscall+0x559>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104e06:	e8 d8 1a 00 00       	call   f01068e3 <cpunum>
f0104e0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e0e:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104e14:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cgetc:
			// cprintf("SYS_cgetc\n");
			return sys_cgetc();
		case SYS_getenvid:
			// cprintf("SYS_getenvid\n");
			return sys_getenvid();
f0104e17:	e9 e0 04 00 00       	jmp    f01052fc <syscall+0x559>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e1c:	83 ec 04             	sub    $0x4,%esp
f0104e1f:	6a 01                	push   $0x1
f0104e21:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e24:	50                   	push   %eax
f0104e25:	ff 75 0c             	pushl  0xc(%ebp)
f0104e28:	e8 54 e7 ff ff       	call   f0103581 <envid2env>
f0104e2d:	83 c4 10             	add    $0x10,%esp
		return r;
f0104e30:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e32:	85 c0                	test   %eax,%eax
f0104e34:	0f 88 c2 04 00 00    	js     f01052fc <syscall+0x559>
		return r;
	if (e == curenv)
f0104e3a:	e8 a4 1a 00 00       	call   f01068e3 <cpunum>
f0104e3f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e42:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e45:	39 90 28 20 24 f0    	cmp    %edx,-0xfdbdfd8(%eax)
f0104e4b:	75 23                	jne    f0104e70 <syscall+0xcd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104e4d:	e8 91 1a 00 00       	call   f01068e3 <cpunum>
f0104e52:	83 ec 08             	sub    $0x8,%esp
f0104e55:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e58:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104e5e:	ff 70 48             	pushl  0x48(%eax)
f0104e61:	68 1f 87 10 f0       	push   $0xf010871f
f0104e66:	e8 23 f0 ff ff       	call   f0103e8e <cprintf>
f0104e6b:	83 c4 10             	add    $0x10,%esp
f0104e6e:	eb 25                	jmp    f0104e95 <syscall+0xf2>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104e70:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104e73:	e8 6b 1a 00 00       	call   f01068e3 <cpunum>
f0104e78:	83 ec 04             	sub    $0x4,%esp
f0104e7b:	53                   	push   %ebx
f0104e7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e7f:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104e85:	ff 70 48             	pushl  0x48(%eax)
f0104e88:	68 3a 87 10 f0       	push   $0xf010873a
f0104e8d:	e8 fc ef ff ff       	call   f0103e8e <cprintf>
f0104e92:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104e95:	83 ec 0c             	sub    $0xc,%esp
f0104e98:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e9b:	e8 d1 ec ff ff       	call   f0103b71 <env_destroy>
f0104ea0:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ea8:	e9 4f 04 00 00       	jmp    f01052fc <syscall+0x559>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104ead:	81 7d 0c ff ff ff ef 	cmpl   $0xefffffff,0xc(%ebp)
f0104eb4:	77 14                	ja     f0104eca <syscall+0x127>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104eb6:	ff 75 0c             	pushl  0xc(%ebp)
f0104eb9:	68 64 70 10 f0       	push   $0xf0107064
f0104ebe:	6a 48                	push   $0x48
f0104ec0:	68 52 87 10 f0       	push   $0xf0108752
f0104ec5:	e8 76 b1 ff ff       	call   f0100040 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104eca:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ecd:	05 00 00 00 10       	add    $0x10000000,%eax
f0104ed2:	c1 e8 0c             	shr    $0xc,%eax
f0104ed5:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f0104edb:	72 14                	jb     f0104ef1 <syscall+0x14e>
		panic("pa2page called with invalid pa");
f0104edd:	83 ec 04             	sub    $0x4,%esp
f0104ee0:	68 bc 77 10 f0       	push   $0xf01077bc
f0104ee5:	6a 4f                	push   $0x4f
f0104ee7:	68 01 7e 10 f0       	push   $0xf0107e01
f0104eec:	e8 4f b1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104ef1:	8b 15 b0 1e 24 f0    	mov    0xf0241eb0,%edx
f0104ef7:	8d 34 c2             	lea    (%edx,%eax,8),%esi
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p == NULL)
		return E_INVAL;
f0104efa:	bb 03 00 00 00       	mov    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p == NULL)
f0104eff:	85 f6                	test   %esi,%esi
f0104f01:	0f 84 f5 03 00 00    	je     f01052fc <syscall+0x559>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0104f07:	e8 d7 19 00 00       	call   f01068e3 <cpunum>
f0104f0c:	6a 06                	push   $0x6
f0104f0e:	ff 75 10             	pushl  0x10(%ebp)
f0104f11:	56                   	push   %esi
f0104f12:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f15:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104f1b:	ff 70 64             	pushl  0x64(%eax)
f0104f1e:	e8 86 ca ff ff       	call   f01019a9 <page_insert>
f0104f23:	83 c4 10             	add    $0x10,%esp
	return r;
f0104f26:	89 c3                	mov    %eax,%ebx
f0104f28:	e9 cf 03 00 00       	jmp    f01052fc <syscall+0x559>

static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_cur_brk + inc), inc);
f0104f2d:	e8 b1 19 00 00       	call   f01068e3 <cpunum>
f0104f32:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f35:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104f3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f3e:	03 58 60             	add    0x60(%eax),%ebx
f0104f41:	e8 9d 19 00 00       	call   f01068e3 <cpunum>
f0104f46:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f49:	8b b8 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%edi
}

static void
region_alloc(struct Env *e, void *va, size_t len)
{
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f0104f4f:	89 d8                	mov    %ebx,%eax
f0104f51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104f56:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f0104f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104f5c:	8d b4 0b ff 0f 00 00 	lea    0xfff(%ebx,%ecx,1),%esi
f0104f63:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0104f69:	39 f0                	cmp    %esi,%eax
f0104f6b:	73 5e                	jae    f0104fcb <syscall+0x228>
f0104f6d:	89 c3                	mov    %eax,%ebx
		if (!(tmp = page_alloc(0))) {
f0104f6f:	83 ec 0c             	sub    $0xc,%esp
f0104f72:	6a 00                	push   $0x0
f0104f74:	e8 4e c3 ff ff       	call   f01012c7 <page_alloc>
f0104f79:	83 c4 10             	add    $0x10,%esp
f0104f7c:	85 c0                	test   %eax,%eax
f0104f7e:	75 17                	jne    f0104f97 <syscall+0x1f4>
			panic("Execute region_alloc(...) failed. Out of memory.\n");
f0104f80:	83 ec 04             	sub    $0x4,%esp
f0104f83:	68 c4 81 10 f0       	push   $0xf01081c4
f0104f88:	68 71 01 00 00       	push   $0x171
f0104f8d:	68 52 87 10 f0       	push   $0xf0108752
f0104f92:	e8 a9 b0 ff ff       	call   f0100040 <_panic>
		} else {
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
f0104f97:	6a 06                	push   $0x6
f0104f99:	53                   	push   %ebx
f0104f9a:	50                   	push   %eax
f0104f9b:	ff 77 64             	pushl  0x64(%edi)
f0104f9e:	e8 06 ca ff ff       	call   f01019a9 <page_insert>
f0104fa3:	83 c4 10             	add    $0x10,%esp
f0104fa6:	85 c0                	test   %eax,%eax
f0104fa8:	74 17                	je     f0104fc1 <syscall+0x21e>
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
f0104faa:	83 ec 04             	sub    $0x4,%esp
f0104fad:	68 f8 81 10 f0       	push   $0xf01081f8
f0104fb2:	68 74 01 00 00       	push   $0x174
f0104fb7:	68 52 87 10 f0       	push   $0xf0108752
f0104fbc:	e8 7f b0 ff ff       	call   f0100040 <_panic>
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0104fc1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104fc7:	39 de                	cmp    %ebx,%esi
f0104fc9:	77 a4                	ja     f0104f6f <syscall+0x1cc>
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
			}
		}
	}
	e->env_cur_brk = start;
f0104fcb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104fce:	89 47 60             	mov    %eax,0x60(%edi)
static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_cur_brk + inc), inc);
	return curenv->env_cur_brk;
f0104fd1:	e8 0d 19 00 00       	call   f01068e3 <cpunum>
f0104fd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fd9:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104fdf:	8b 58 60             	mov    0x60(%eax),%ebx
		case SYS_map_kernel_page:
			// cprintf("SYS_map_kernel_page\n");
			return sys_map_kernel_page((void *)a1, (void *)a2);
		case SYS_sbrk:
			// cprintf("SYS_sbrk\n");
			return sys_sbrk(a1);
f0104fe2:	e9 15 03 00 00       	jmp    f01052fc <syscall+0x559>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104fe7:	e8 76 fc ff ff       	call   f0104c62 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *env;
	int err = env_alloc(&env, curenv->env_id);
f0104fec:	e8 f2 18 00 00       	call   f01068e3 <cpunum>
f0104ff1:	83 ec 08             	sub    $0x8,%esp
f0104ff4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ff7:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104ffd:	ff 70 48             	pushl  0x48(%eax)
f0105000:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105003:	50                   	push   %eax
f0105004:	e8 9c e6 ff ff       	call   f01036a5 <env_alloc>
	if (err) {
f0105009:	83 c4 10             	add    $0x10,%esp
		return err;
f010500c:	89 c3                	mov    %eax,%ebx
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *env;
	int err = env_alloc(&env, curenv->env_id);
	if (err) {
f010500e:	85 c0                	test   %eax,%eax
f0105010:	0f 85 e6 02 00 00    	jne    f01052fc <syscall+0x559>
		return err;
	} else {
		env->env_status = ENV_NOT_RUNNABLE;
f0105016:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105019:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
		env->env_tf = curenv->env_tf;
f0105020:	e8 be 18 00 00       	call   f01068e3 <cpunum>
f0105025:	6b c0 74             	imul   $0x74,%eax,%eax
f0105028:	8b b0 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%esi
f010502e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105033:	89 df                	mov    %ebx,%edi
f0105035:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		env->env_tf.tf_regs.reg_eax = 0;
f0105037:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010503a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
		return env->env_id;
f0105041:	8b 58 48             	mov    0x48(%eax),%ebx
f0105044:	e9 b3 02 00 00       	jmp    f01052fc <syscall+0x559>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *env;
	if (envid2env(envid, &env, 1)) {
f0105049:	83 ec 04             	sub    $0x4,%esp
f010504c:	6a 01                	push   $0x1
f010504e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105051:	50                   	push   %eax
f0105052:	ff 75 0c             	pushl  0xc(%ebp)
f0105055:	e8 27 e5 ff ff       	call   f0103581 <envid2env>
f010505a:	89 c3                	mov    %eax,%ebx
f010505c:	83 c4 10             	add    $0x10,%esp
f010505f:	85 c0                	test   %eax,%eax
f0105061:	75 1b                	jne    f010507e <syscall+0x2db>
		return -E_BAD_ENV;
	} else if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f0105063:	8b 45 10             	mov    0x10(%ebp),%eax
f0105066:	83 e8 02             	sub    $0x2,%eax
f0105069:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010506e:	75 18                	jne    f0105088 <syscall+0x2e5>
		return -E_INVAL;
	} else {
		env->env_status = status;
f0105070:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105073:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105076:	89 48 54             	mov    %ecx,0x54(%eax)
f0105079:	e9 7e 02 00 00       	jmp    f01052fc <syscall+0x559>
	// envid's status.

	// LAB 4: Your code here.
	struct Env *env;
	if (envid2env(envid, &env, 1)) {
		return -E_BAD_ENV;
f010507e:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0105083:	e9 74 02 00 00       	jmp    f01052fc <syscall+0x559>
	} else if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
		return -E_INVAL;
f0105088:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_exofork:
			// cprintf("SYS_exofork\n");
			return sys_exofork();
		case SYS_env_set_status:
			// cprintf("SYS_env_set_status\n");
			return sys_env_set_status((envid_t)a1, (int)a2);
f010508d:	e9 6a 02 00 00       	jmp    f01052fc <syscall+0x559>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if (va >= (void *)UTOP || (perm & 0x5) != 0x5 ||
f0105092:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105099:	77 7d                	ja     f0105118 <syscall+0x375>
f010509b:	8b 45 14             	mov    0x14(%ebp),%eax
f010509e:	83 e0 05             	and    $0x5,%eax
f01050a1:	83 f8 05             	cmp    $0x5,%eax
f01050a4:	75 7c                	jne    f0105122 <syscall+0x37f>
f01050a6:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01050ad:	75 7d                	jne    f010512c <syscall+0x389>
			PGOFF(va) || (perm & (~PTE_SYSCALL)))
f01050af:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01050b2:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f01050b8:	75 7c                	jne    f0105136 <syscall+0x393>
		return -E_INVAL;

	struct Env *env;
	int r = envid2env(envid, &env, 1);
f01050ba:	83 ec 04             	sub    $0x4,%esp
f01050bd:	6a 01                	push   $0x1
f01050bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050c2:	50                   	push   %eax
f01050c3:	ff 75 0c             	pushl  0xc(%ebp)
f01050c6:	e8 b6 e4 ff ff       	call   f0103581 <envid2env>
	if (r < 0) {
f01050cb:	83 c4 10             	add    $0x10,%esp
f01050ce:	85 c0                	test   %eax,%eax
f01050d0:	78 6e                	js     f0105140 <syscall+0x39d>
		return -E_BAD_ENV;
	}

	struct Page *new_page = page_alloc(ALLOC_ZERO);
f01050d2:	83 ec 0c             	sub    $0xc,%esp
f01050d5:	6a 01                	push   $0x1
f01050d7:	e8 eb c1 ff ff       	call   f01012c7 <page_alloc>
f01050dc:	89 c6                	mov    %eax,%esi
	if (!new_page) {
f01050de:	83 c4 10             	add    $0x10,%esp
f01050e1:	85 c0                	test   %eax,%eax
f01050e3:	74 65                	je     f010514a <syscall+0x3a7>
		return -E_NO_MEM;
	}

	r = page_insert(env->env_pgdir, new_page, va, perm);
f01050e5:	ff 75 14             	pushl  0x14(%ebp)
f01050e8:	ff 75 10             	pushl  0x10(%ebp)
f01050eb:	50                   	push   %eax
f01050ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050ef:	ff 70 64             	pushl  0x64(%eax)
f01050f2:	e8 b2 c8 ff ff       	call   f01019a9 <page_insert>
	if (r) {
f01050f7:	83 c4 10             	add    $0x10,%esp
f01050fa:	85 c0                	test   %eax,%eax
f01050fc:	0f 84 fa 01 00 00    	je     f01052fc <syscall+0x559>
		page_free(new_page);
f0105102:	83 ec 0c             	sub    $0xc,%esp
f0105105:	56                   	push   %esi
f0105106:	e8 2d c4 ff ff       	call   f0101538 <page_free>
f010510b:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f010510e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0105113:	e9 e4 01 00 00       	jmp    f01052fc <syscall+0x559>
	//   allocated!

	// LAB 4: Your code here.
	if (va >= (void *)UTOP || (perm & 0x5) != 0x5 ||
			PGOFF(va) || (perm & (~PTE_SYSCALL)))
		return -E_INVAL;
f0105118:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010511d:	e9 da 01 00 00       	jmp    f01052fc <syscall+0x559>
f0105122:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105127:	e9 d0 01 00 00       	jmp    f01052fc <syscall+0x559>
f010512c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105131:	e9 c6 01 00 00       	jmp    f01052fc <syscall+0x559>
f0105136:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010513b:	e9 bc 01 00 00       	jmp    f01052fc <syscall+0x559>

	struct Env *env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) {
		return -E_BAD_ENV;
f0105140:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0105145:	e9 b2 01 00 00       	jmp    f01052fc <syscall+0x559>
	}

	struct Page *new_page = page_alloc(ALLOC_ZERO);
	if (!new_page) {
		return -E_NO_MEM;
f010514a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		case SYS_env_set_status:
			// cprintf("SYS_env_set_status\n");
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
			// cprintf("SYS_page_alloc\n");
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f010514f:	e9 a8 01 00 00       	jmp    f01052fc <syscall+0x559>
		case SYS_page_map:
			// cprintf("SYS_page_map\n");
			return sys_page_map((envid_t)*((uint32_t *)a1),
f0105154:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105157:	8b 58 10             	mov    0x10(%eax),%ebx
													(void *)*((uint32_t *)a1 + 1),
													(envid_t)*((uint32_t *)a1 + 2),
													(void *)*((uint32_t *)a1 + 3),
f010515a:	8b 70 0c             	mov    0xc(%eax),%esi
			// cprintf("SYS_page_alloc\n");
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_page_map:
			// cprintf("SYS_page_map\n");
			return sys_page_map((envid_t)*((uint32_t *)a1),
													(void *)*((uint32_t *)a1 + 1),
f010515d:	8b 78 04             	mov    0x4(%eax),%edi
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || (perm & 0x5) != 0x5 ||
f0105160:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105166:	0f 87 b8 00 00 00    	ja     f0105224 <syscall+0x481>
f010516c:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0105172:	0f 87 ac 00 00 00    	ja     f0105224 <syscall+0x481>
f0105178:	89 d8                	mov    %ebx,%eax
f010517a:	83 e0 05             	and    $0x5,%eax
f010517d:	83 f8 05             	cmp    $0x5,%eax
f0105180:	0f 85 a8 00 00 00    	jne    f010522e <syscall+0x48b>
			PGOFF(srcva) || PGOFF(dstva) || (perm & (~PTE_SYSCALL)))
f0105186:	89 f0                	mov    %esi,%eax
f0105188:	09 f8                	or     %edi,%eax
f010518a:	a9 ff 0f 00 00       	test   $0xfff,%eax
f010518f:	0f 85 a3 00 00 00    	jne    f0105238 <syscall+0x495>
f0105195:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
f010519b:	0f 85 a1 00 00 00    	jne    f0105242 <syscall+0x49f>
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_page_map:
			// cprintf("SYS_page_map\n");
			return sys_page_map((envid_t)*((uint32_t *)a1),
													(void *)*((uint32_t *)a1 + 1),
													(envid_t)*((uint32_t *)a1 + 2),
f01051a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051a4:	8b 40 08             	mov    0x8(%eax),%eax
f01051a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || (perm & 0x5) != 0x5 ||
			PGOFF(srcva) || PGOFF(dstva) || (perm & (~PTE_SYSCALL)))
		return -E_INVAL;

	struct Env *src_env, *dst_env;
	envid2env(srcenvid, &src_env, 1);
f01051aa:	83 ec 04             	sub    $0x4,%esp
f01051ad:	6a 01                	push   $0x1
f01051af:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051b2:	50                   	push   %eax
f01051b3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01051b6:	ff 32                	pushl  (%edx)
f01051b8:	e8 c4 e3 ff ff       	call   f0103581 <envid2env>
	envid2env(dstenvid, &dst_env, 1);
f01051bd:	83 c4 0c             	add    $0xc,%esp
f01051c0:	6a 01                	push   $0x1
f01051c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01051c5:	50                   	push   %eax
f01051c6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01051c9:	e8 b3 e3 ff ff       	call   f0103581 <envid2env>
	if (!src_env || !dst_env) {
f01051ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01051d1:	83 c4 10             	add    $0x10,%esp
f01051d4:	85 c0                	test   %eax,%eax
f01051d6:	74 74                	je     f010524c <syscall+0x4a9>
f01051d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01051dc:	74 78                	je     f0105256 <syscall+0x4b3>
		return -E_BAD_ENV;
	}

	pte_t *pte;
	struct Page *page = page_lookup(src_env->env_pgdir, srcva, &pte);
f01051de:	83 ec 04             	sub    $0x4,%esp
f01051e1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01051e4:	52                   	push   %edx
f01051e5:	57                   	push   %edi
f01051e6:	ff 70 64             	pushl  0x64(%eax)
f01051e9:	e8 d7 c6 ff ff       	call   f01018c5 <page_lookup>
	if (!page || (!(*pte & PTE_W) && (perm & PTE_W))) {
f01051ee:	83 c4 10             	add    $0x10,%esp
f01051f1:	85 c0                	test   %eax,%eax
f01051f3:	74 6b                	je     f0105260 <syscall+0x4bd>
f01051f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051f8:	f6 02 02             	testb  $0x2,(%edx)
f01051fb:	75 05                	jne    f0105202 <syscall+0x45f>
f01051fd:	f6 c3 02             	test   $0x2,%bl
f0105200:	75 68                	jne    f010526a <syscall+0x4c7>
		return -E_INVAL;
	}

	if (page_insert(dst_env->env_pgdir, page, dstva, perm)) {
f0105202:	53                   	push   %ebx
f0105203:	56                   	push   %esi
f0105204:	50                   	push   %eax
f0105205:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105208:	ff 70 64             	pushl  0x64(%eax)
f010520b:	e8 99 c7 ff ff       	call   f01019a9 <page_insert>
f0105210:	89 c3                	mov    %eax,%ebx
f0105212:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0105215:	85 c0                	test   %eax,%eax
f0105217:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010521c:	0f 45 d8             	cmovne %eax,%ebx
f010521f:	e9 d8 00 00 00       	jmp    f01052fc <syscall+0x559>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || (perm & 0x5) != 0x5 ||
			PGOFF(srcva) || PGOFF(dstva) || (perm & (~PTE_SYSCALL)))
		return -E_INVAL;
f0105224:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105229:	e9 ce 00 00 00       	jmp    f01052fc <syscall+0x559>
f010522e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105233:	e9 c4 00 00 00       	jmp    f01052fc <syscall+0x559>
f0105238:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010523d:	e9 ba 00 00 00       	jmp    f01052fc <syscall+0x559>
f0105242:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105247:	e9 b0 00 00 00       	jmp    f01052fc <syscall+0x559>

	struct Env *src_env, *dst_env;
	envid2env(srcenvid, &src_env, 1);
	envid2env(dstenvid, &dst_env, 1);
	if (!src_env || !dst_env) {
		return -E_BAD_ENV;
f010524c:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0105251:	e9 a6 00 00 00       	jmp    f01052fc <syscall+0x559>
f0105256:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010525b:	e9 9c 00 00 00       	jmp    f01052fc <syscall+0x559>
	}

	pte_t *pte;
	struct Page *page = page_lookup(src_env->env_pgdir, srcva, &pte);
	if (!page || (!(*pte & PTE_W) && (perm & PTE_W))) {
		return -E_INVAL;
f0105260:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105265:	e9 92 00 00 00       	jmp    f01052fc <syscall+0x559>
f010526a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010526f:	e9 88 00 00 00       	jmp    f01052fc <syscall+0x559>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va >= (void *)UTOP || PGOFF(va))
f0105274:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010527b:	77 39                	ja     f01052b6 <syscall+0x513>
f010527d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105284:	75 37                	jne    f01052bd <syscall+0x51a>
		return -E_INVAL;

	struct Env *env;
	if (envid2env(envid, &env, 1)) {
f0105286:	83 ec 04             	sub    $0x4,%esp
f0105289:	6a 01                	push   $0x1
f010528b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010528e:	50                   	push   %eax
f010528f:	ff 75 0c             	pushl  0xc(%ebp)
f0105292:	e8 ea e2 ff ff       	call   f0103581 <envid2env>
f0105297:	89 c3                	mov    %eax,%ebx
f0105299:	83 c4 10             	add    $0x10,%esp
f010529c:	85 c0                	test   %eax,%eax
f010529e:	75 24                	jne    f01052c4 <syscall+0x521>
		return -E_BAD_ENV;
	}

	page_remove(env->env_pgdir, va);
f01052a0:	83 ec 08             	sub    $0x8,%esp
f01052a3:	ff 75 10             	pushl  0x10(%ebp)
f01052a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052a9:	ff 70 64             	pushl  0x64(%eax)
f01052ac:	e8 af c6 ff ff       	call   f0101960 <page_remove>
f01052b1:	83 c4 10             	add    $0x10,%esp
f01052b4:	eb 46                	jmp    f01052fc <syscall+0x559>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va >= (void *)UTOP || PGOFF(va))
		return -E_INVAL;
f01052b6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01052bb:	eb 3f                	jmp    f01052fc <syscall+0x559>
f01052bd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01052c2:	eb 38                	jmp    f01052fc <syscall+0x559>

	struct Env *env;
	if (envid2env(envid, &env, 1)) {
		return -E_BAD_ENV;
f01052c4:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
													(envid_t)*((uint32_t *)a1 + 2),
													(void *)*((uint32_t *)a1 + 3),
													(int)*((uint32_t*)a1 + 4));
		case SYS_page_unmap:
			// cprintf("SYS_page_unmap\n");
			return sys_page_unmap((envid_t)a1, (void *)a2);
f01052c9:	eb 31                	jmp    f01052fc <syscall+0x559>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *env;
	if (envid2env(envid, &env, 1)) {
f01052cb:	83 ec 04             	sub    $0x4,%esp
f01052ce:	6a 01                	push   $0x1
f01052d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01052d3:	50                   	push   %eax
f01052d4:	ff 75 0c             	pushl  0xc(%ebp)
f01052d7:	e8 a5 e2 ff ff       	call   f0103581 <envid2env>
f01052dc:	89 c3                	mov    %eax,%ebx
f01052de:	83 c4 10             	add    $0x10,%esp
f01052e1:	85 c0                	test   %eax,%eax
f01052e3:	75 0b                	jne    f01052f0 <syscall+0x54d>
		return -E_BAD_ENV;
	}

	env->env_pgfault_upcall = func;
f01052e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01052eb:	89 48 68             	mov    %ecx,0x68(%eax)
f01052ee:	eb 0c                	jmp    f01052fc <syscall+0x559>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *env;
	if (envid2env(envid, &env, 1)) {
		return -E_BAD_ENV;
f01052f0:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		case SYS_page_unmap:
			// cprintf("SYS_page_unmap\n");
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			// cprintf("SYS_env_set_pgfault_upcall\n");
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f01052f5:	eb 05                	jmp    f01052fc <syscall+0x559>
		default:
			return -E_INVAL;
f01052f7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	}
	// panic("syscall not implemented");
}
f01052fc:	89 d8                	mov    %ebx,%eax
f01052fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105301:	5b                   	pop    %ebx
f0105302:	5e                   	pop    %esi
f0105303:	5f                   	pop    %edi
f0105304:	5d                   	pop    %ebp
f0105305:	c3                   	ret    

f0105306 <syscall_helper>:

void
syscall_helper(struct Trapframe *tf)
{
f0105306:	55                   	push   %ebp
f0105307:	89 e5                	mov    %esp,%ebp
f0105309:	57                   	push   %edi
f010530a:	56                   	push   %esi
f010530b:	53                   	push   %ebx
f010530c:	83 ec 18             	sub    $0x18,%esp
f010530f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105312:	68 a0 23 12 f0       	push   $0xf01223a0
f0105317:	e8 35 18 00 00       	call   f0106b51 <spin_lock>
	lock_kernel();
	curenv->env_tf = *tf;
f010531c:	e8 c2 15 00 00       	call   f01068e3 <cpunum>
f0105321:	6b c0 74             	imul   $0x74,%eax,%eax
f0105324:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f010532a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010532f:	89 c7                	mov    %eax,%edi
f0105331:	89 de                	mov    %ebx,%esi
f0105333:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	curenv->env_tf.tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f0105335:	e8 a9 15 00 00       	call   f01068e3 <cpunum>
f010533a:	6b c0 74             	imul   $0x74,%eax,%eax
f010533d:	8b b0 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%esi
f0105343:	83 c4 08             	add    $0x8,%esp
f0105346:	6a 00                	push   $0x0
f0105348:	ff 33                	pushl  (%ebx)
f010534a:	ff 73 10             	pushl  0x10(%ebx)
f010534d:	ff 73 18             	pushl  0x18(%ebx)
f0105350:	ff 73 14             	pushl  0x14(%ebx)
f0105353:	ff 73 1c             	pushl  0x1c(%ebx)
f0105356:	e8 48 fa ff ff       	call   f0104da3 <syscall>
f010535b:	89 46 1c             	mov    %eax,0x1c(%esi)
				tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
	curenv->env_tf.tf_eflags |= FL_IF;
f010535e:	83 c4 20             	add    $0x20,%esp
f0105361:	e8 7d 15 00 00       	call   f01068e3 <cpunum>
f0105366:	6b c0 74             	imul   $0x74,%eax,%eax
f0105369:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f010536f:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105376:	83 ec 0c             	sub    $0xc,%esp
f0105379:	68 a0 23 12 f0       	push   $0xf01223a0
f010537e:	e8 a3 18 00 00       	call   f0106c26 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105383:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f0105385:	e8 59 15 00 00       	call   f01068e3 <cpunum>
f010538a:	83 c4 04             	add    $0x4,%esp
f010538d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105390:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0105396:	e8 37 e8 ff ff       	call   f0103bd2 <env_pop_tf>

f010539b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010539b:	55                   	push   %ebp
f010539c:	89 e5                	mov    %esp,%ebp
f010539e:	57                   	push   %edi
f010539f:	56                   	push   %esi
f01053a0:	53                   	push   %ebx
f01053a1:	83 ec 14             	sub    $0x14,%esp
f01053a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01053a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01053aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01053ad:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01053b0:	8b 1a                	mov    (%edx),%ebx
f01053b2:	8b 01                	mov    (%ecx),%eax
f01053b4:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f01053b7:	39 c3                	cmp    %eax,%ebx
f01053b9:	0f 8f 9a 00 00 00    	jg     f0105459 <stab_binsearch+0xbe>
f01053bf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01053c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01053c9:	01 d8                	add    %ebx,%eax
f01053cb:	89 c6                	mov    %eax,%esi
f01053cd:	c1 ee 1f             	shr    $0x1f,%esi
f01053d0:	01 c6                	add    %eax,%esi
f01053d2:	d1 fe                	sar    %esi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053d4:	39 de                	cmp    %ebx,%esi
f01053d6:	0f 8c c4 00 00 00    	jl     f01054a0 <stab_binsearch+0x105>
f01053dc:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01053df:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01053e2:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01053e5:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f01053e9:	39 c7                	cmp    %eax,%edi
f01053eb:	0f 84 b4 00 00 00    	je     f01054a5 <stab_binsearch+0x10a>
f01053f1:	89 f0                	mov    %esi,%eax
			m--;
f01053f3:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053f6:	39 d8                	cmp    %ebx,%eax
f01053f8:	0f 8c a2 00 00 00    	jl     f01054a0 <stab_binsearch+0x105>
f01053fe:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0105402:	83 ea 0c             	sub    $0xc,%edx
f0105405:	39 f9                	cmp    %edi,%ecx
f0105407:	75 ea                	jne    f01053f3 <stab_binsearch+0x58>
f0105409:	e9 99 00 00 00       	jmp    f01054a7 <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010540e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105411:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105413:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105416:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010541d:	eb 2b                	jmp    f010544a <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010541f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105422:	76 14                	jbe    f0105438 <stab_binsearch+0x9d>
			*region_right = m - 1;
f0105424:	83 e8 01             	sub    $0x1,%eax
f0105427:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010542a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010542d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010542f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105436:	eb 12                	jmp    f010544a <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105438:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010543b:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010543d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105441:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105443:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010544a:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f010544d:	0f 8d 73 ff ff ff    	jge    f01053c6 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105453:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105457:	75 0f                	jne    f0105468 <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f0105459:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010545c:	8b 00                	mov    (%eax),%eax
f010545e:	83 e8 01             	sub    $0x1,%eax
f0105461:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105464:	89 07                	mov    %eax,(%edi)
f0105466:	eb 57                	jmp    f01054bf <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105468:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010546b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010546d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105470:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105472:	39 c8                	cmp    %ecx,%eax
f0105474:	7e 23                	jle    f0105499 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0105476:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105479:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010547c:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010547f:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0105483:	39 df                	cmp    %ebx,%edi
f0105485:	74 12                	je     f0105499 <stab_binsearch+0xfe>
		     l--)
f0105487:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010548a:	39 c8                	cmp    %ecx,%eax
f010548c:	7e 0b                	jle    f0105499 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f010548e:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f0105492:	83 ea 0c             	sub    $0xc,%edx
f0105495:	39 df                	cmp    %ebx,%edi
f0105497:	75 ee                	jne    f0105487 <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010549c:	89 07                	mov    %eax,(%edi)
	}
}
f010549e:	eb 1f                	jmp    f01054bf <stab_binsearch+0x124>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01054a0:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01054a3:	eb a5                	jmp    f010544a <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01054a5:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01054a7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054aa:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01054ad:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01054b1:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01054b4:	0f 82 54 ff ff ff    	jb     f010540e <stab_binsearch+0x73>
f01054ba:	e9 60 ff ff ff       	jmp    f010541f <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01054bf:	83 c4 14             	add    $0x14,%esp
f01054c2:	5b                   	pop    %ebx
f01054c3:	5e                   	pop    %esi
f01054c4:	5f                   	pop    %edi
f01054c5:	5d                   	pop    %ebp
f01054c6:	c3                   	ret    

f01054c7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01054c7:	55                   	push   %ebp
f01054c8:	89 e5                	mov    %esp,%ebp
f01054ca:	57                   	push   %edi
f01054cb:	56                   	push   %esi
f01054cc:	53                   	push   %ebx
f01054cd:	83 ec 3c             	sub    $0x3c,%esp
f01054d0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01054d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01054d6:	c7 03 a0 87 10 f0    	movl   $0xf01087a0,(%ebx)
	info->eip_line = 0;
f01054dc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01054e3:	c7 43 08 a0 87 10 f0 	movl   $0xf01087a0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01054ea:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01054f1:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01054f4:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01054fb:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0105501:	0f 87 a3 00 00 00    	ja     f01055aa <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U)) {
f0105507:	e8 d7 13 00 00       	call   f01068e3 <cpunum>
f010550c:	6a 04                	push   $0x4
f010550e:	6a 10                	push   $0x10
f0105510:	68 00 00 20 00       	push   $0x200000
f0105515:	6b c0 74             	imul   $0x74,%eax,%eax
f0105518:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f010551e:	e8 cc de ff ff       	call   f01033ef <user_mem_check>
f0105523:	83 c4 10             	add    $0x10,%esp
f0105526:	85 c0                	test   %eax,%eax
f0105528:	0f 85 52 02 00 00    	jne    f0105780 <debuginfo_eip+0x2b9>
			return -1;
		}

		stabs = usd->stabs;
f010552e:	a1 00 00 20 00       	mov    0x200000,%eax
f0105533:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0105536:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010553c:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105542:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0105545:	a1 0c 00 20 00       	mov    0x20000c,%eax
f010554a:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
f010554d:	e8 91 13 00 00       	call   f01068e3 <cpunum>
f0105552:	6a 04                	push   $0x4
f0105554:	89 f2                	mov    %esi,%edx
f0105556:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105559:	29 ca                	sub    %ecx,%edx
f010555b:	c1 fa 02             	sar    $0x2,%edx
f010555e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0105564:	52                   	push   %edx
f0105565:	51                   	push   %ecx
f0105566:	6b c0 74             	imul   $0x74,%eax,%eax
f0105569:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f010556f:	e8 7b de ff ff       	call   f01033ef <user_mem_check>
f0105574:	83 c4 10             	add    $0x10,%esp
f0105577:	85 c0                	test   %eax,%eax
f0105579:	0f 85 08 02 00 00    	jne    f0105787 <debuginfo_eip+0x2c0>
			return -1;
		}

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
f010557f:	e8 5f 13 00 00       	call   f01068e3 <cpunum>
f0105584:	6a 04                	push   $0x4
f0105586:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105589:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010558c:	29 ca                	sub    %ecx,%edx
f010558e:	52                   	push   %edx
f010558f:	51                   	push   %ecx
f0105590:	6b c0 74             	imul   $0x74,%eax,%eax
f0105593:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0105599:	e8 51 de ff ff       	call   f01033ef <user_mem_check>
f010559e:	83 c4 10             	add    $0x10,%esp
f01055a1:	85 c0                	test   %eax,%eax
f01055a3:	74 1f                	je     f01055c4 <debuginfo_eip+0xfd>
f01055a5:	e9 e4 01 00 00       	jmp    f010578e <debuginfo_eip+0x2c7>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01055aa:	c7 45 bc c0 75 11 f0 	movl   $0xf01175c0,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01055b1:	c7 45 b8 49 3e 11 f0 	movl   $0xf0113e49,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01055b8:	be 48 3e 11 f0       	mov    $0xf0113e48,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01055bd:	c7 45 c0 f4 8c 10 f0 	movl   $0xf0108cf4,-0x40(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01055c4:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01055c7:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01055ca:	0f 83 c5 01 00 00    	jae    f0105795 <debuginfo_eip+0x2ce>
f01055d0:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01055d4:	0f 85 c2 01 00 00    	jne    f010579c <debuginfo_eip+0x2d5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01055da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01055e1:	2b 75 c0             	sub    -0x40(%ebp),%esi
f01055e4:	c1 fe 02             	sar    $0x2,%esi
f01055e7:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01055ed:	83 e8 01             	sub    $0x1,%eax
f01055f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01055f3:	83 ec 08             	sub    $0x8,%esp
f01055f6:	57                   	push   %edi
f01055f7:	6a 64                	push   $0x64
f01055f9:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01055fc:	89 d1                	mov    %edx,%ecx
f01055fe:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105601:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0105604:	89 f0                	mov    %esi,%eax
f0105606:	e8 90 fd ff ff       	call   f010539b <stab_binsearch>
	if (lfile == 0)
f010560b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010560e:	83 c4 10             	add    $0x10,%esp
f0105611:	85 c0                	test   %eax,%eax
f0105613:	0f 84 8a 01 00 00    	je     f01057a3 <debuginfo_eip+0x2dc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105619:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010561c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010561f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105622:	83 ec 08             	sub    $0x8,%esp
f0105625:	57                   	push   %edi
f0105626:	6a 24                	push   $0x24
f0105628:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010562b:	89 d1                	mov    %edx,%ecx
f010562d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105630:	89 f0                	mov    %esi,%eax
f0105632:	e8 64 fd ff ff       	call   f010539b <stab_binsearch>

	if (lfun <= rfun) {
f0105637:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010563a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010563d:	83 c4 10             	add    $0x10,%esp
f0105640:	39 d0                	cmp    %edx,%eax
f0105642:	7f 2e                	jg     f0105672 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105644:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105647:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f010564a:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f010564d:	8b 36                	mov    (%esi),%esi
f010564f:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105652:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0105655:	39 ce                	cmp    %ecx,%esi
f0105657:	73 06                	jae    f010565f <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105659:	03 75 b8             	add    -0x48(%ebp),%esi
f010565c:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010565f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105662:	8b 4e 08             	mov    0x8(%esi),%ecx
f0105665:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105668:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f010566a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010566d:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105670:	eb 0f                	jmp    f0105681 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105672:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0105675:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105678:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010567b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010567e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105681:	83 ec 08             	sub    $0x8,%esp
f0105684:	6a 3a                	push   $0x3a
f0105686:	ff 73 08             	pushl  0x8(%ebx)
f0105689:	e8 b3 0b 00 00       	call   f0106241 <strfind>
f010568e:	2b 43 08             	sub    0x8(%ebx),%eax
f0105691:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105694:	83 c4 08             	add    $0x8,%esp
f0105697:	57                   	push   %edi
f0105698:	6a 44                	push   $0x44
f010569a:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010569d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01056a0:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01056a3:	89 f0                	mov    %esi,%eax
f01056a5:	e8 f1 fc ff ff       	call   f010539b <stab_binsearch>
	if (lline <= rline) {
f01056aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056ad:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01056b0:	83 c4 10             	add    $0x10,%esp
f01056b3:	39 d0                	cmp    %edx,%eax
f01056b5:	0f 8f ef 00 00 00    	jg     f01057aa <debuginfo_eip+0x2e3>
		info->eip_line = rline;
f01056bb:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056c1:	39 f8                	cmp    %edi,%eax
f01056c3:	7c 69                	jl     f010572e <debuginfo_eip+0x267>
	       && stabs[lline].n_type != N_SOL
f01056c5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01056c8:	8d 34 96             	lea    (%esi,%edx,4),%esi
f01056cb:	0f b6 56 04          	movzbl 0x4(%esi),%edx
f01056cf:	80 fa 84             	cmp    $0x84,%dl
f01056d2:	74 41                	je     f0105715 <debuginfo_eip+0x24e>
f01056d4:	89 f1                	mov    %esi,%ecx
f01056d6:	83 c6 08             	add    $0x8,%esi
f01056d9:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01056dd:	eb 1f                	jmp    f01056fe <debuginfo_eip+0x237>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01056df:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01056e2:	39 f8                	cmp    %edi,%eax
f01056e4:	7c 48                	jl     f010572e <debuginfo_eip+0x267>
	       && stabs[lline].n_type != N_SOL
f01056e6:	0f b6 51 f8          	movzbl -0x8(%ecx),%edx
f01056ea:	83 e9 0c             	sub    $0xc,%ecx
f01056ed:	83 ee 0c             	sub    $0xc,%esi
f01056f0:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01056f4:	80 fa 84             	cmp    $0x84,%dl
f01056f7:	75 05                	jne    f01056fe <debuginfo_eip+0x237>
f01056f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01056fc:	eb 17                	jmp    f0105715 <debuginfo_eip+0x24e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01056fe:	80 fa 64             	cmp    $0x64,%dl
f0105701:	75 dc                	jne    f01056df <debuginfo_eip+0x218>
f0105703:	83 3e 00             	cmpl   $0x0,(%esi)
f0105706:	74 d7                	je     f01056df <debuginfo_eip+0x218>
f0105708:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010570c:	74 03                	je     f0105711 <debuginfo_eip+0x24a>
f010570e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105711:	39 c7                	cmp    %eax,%edi
f0105713:	7f 19                	jg     f010572e <debuginfo_eip+0x267>
f0105715:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105718:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010571b:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010571e:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105721:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0105724:	29 f8                	sub    %edi,%eax
f0105726:	39 c2                	cmp    %eax,%edx
f0105728:	73 04                	jae    f010572e <debuginfo_eip+0x267>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010572a:	01 fa                	add    %edi,%edx
f010572c:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010572e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105731:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105734:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105739:	39 f2                	cmp    %esi,%edx
f010573b:	0f 8d 83 00 00 00    	jge    f01057c4 <debuginfo_eip+0x2fd>
		for (lline = lfun + 1;
f0105741:	8d 42 01             	lea    0x1(%edx),%eax
f0105744:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105747:	39 c6                	cmp    %eax,%esi
f0105749:	7e 66                	jle    f01057b1 <debuginfo_eip+0x2ea>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010574b:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010574e:	c1 e1 02             	shl    $0x2,%ecx
f0105751:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105754:	80 7c 0f 04 a0       	cmpb   $0xa0,0x4(%edi,%ecx,1)
f0105759:	75 5d                	jne    f01057b8 <debuginfo_eip+0x2f1>
f010575b:	8d 42 02             	lea    0x2(%edx),%eax
f010575e:	8d 54 0f f4          	lea    -0xc(%edi,%ecx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f0105762:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105766:	39 c6                	cmp    %eax,%esi
f0105768:	74 55                	je     f01057bf <debuginfo_eip+0x2f8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010576a:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f010576e:	83 c0 01             	add    $0x1,%eax
f0105771:	83 c2 0c             	add    $0xc,%edx
f0105774:	80 f9 a0             	cmp    $0xa0,%cl
f0105777:	74 e9                	je     f0105762 <debuginfo_eip+0x29b>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105779:	b8 00 00 00 00       	mov    $0x0,%eax
f010577e:	eb 44                	jmp    f01057c4 <debuginfo_eip+0x2fd>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U)) {
			return -1;
f0105780:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105785:	eb 3d                	jmp    f01057c4 <debuginfo_eip+0x2fd>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
			return -1;
f0105787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010578c:	eb 36                	jmp    f01057c4 <debuginfo_eip+0x2fd>
		}

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
			return -1;
f010578e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105793:	eb 2f                	jmp    f01057c4 <debuginfo_eip+0x2fd>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105795:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010579a:	eb 28                	jmp    f01057c4 <debuginfo_eip+0x2fd>
f010579c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057a1:	eb 21                	jmp    f01057c4 <debuginfo_eip+0x2fd>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01057a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057a8:	eb 1a                	jmp    f01057c4 <debuginfo_eip+0x2fd>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = rline;
	} else {
		return -1;
f01057aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01057af:	eb 13                	jmp    f01057c4 <debuginfo_eip+0x2fd>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01057b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01057b6:	eb 0c                	jmp    f01057c4 <debuginfo_eip+0x2fd>
f01057b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01057bd:	eb 05                	jmp    f01057c4 <debuginfo_eip+0x2fd>
f01057bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057c7:	5b                   	pop    %ebx
f01057c8:	5e                   	pop    %esi
f01057c9:	5f                   	pop    %edi
f01057ca:	5d                   	pop    %ebp
f01057cb:	c3                   	ret    

f01057cc <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01057cc:	55                   	push   %ebp
f01057cd:	89 e5                	mov    %esp,%ebp
f01057cf:	57                   	push   %edi
f01057d0:	56                   	push   %esi
f01057d1:	53                   	push   %ebx
f01057d2:	83 ec 1c             	sub    $0x1c,%esp
f01057d5:	89 c7                	mov    %eax,%edi
f01057d7:	89 d6                	mov    %edx,%esi
f01057d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01057dc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057df:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01057e2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01057e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
f01057e8:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f01057ec:	0f 85 bf 00 00 00    	jne    f01058b1 <printnum+0xe5>
f01057f2:	39 1d 88 1a 24 f0    	cmp    %ebx,0xf0241a88
f01057f8:	0f 8d de 00 00 00    	jge    f01058dc <printnum+0x110>
		judge_time_for_space = width;
f01057fe:	89 1d 88 1a 24 f0    	mov    %ebx,0xf0241a88
f0105804:	e9 d3 00 00 00       	jmp    f01058dc <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0105809:	83 eb 01             	sub    $0x1,%ebx
f010580c:	85 db                	test   %ebx,%ebx
f010580e:	7f 37                	jg     f0105847 <printnum+0x7b>
f0105810:	e9 ea 00 00 00       	jmp    f01058ff <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
f0105815:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105818:	a3 84 1a 24 f0       	mov    %eax,0xf0241a84
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010581d:	83 ec 08             	sub    $0x8,%esp
f0105820:	56                   	push   %esi
f0105821:	83 ec 04             	sub    $0x4,%esp
f0105824:	ff 75 dc             	pushl  -0x24(%ebp)
f0105827:	ff 75 d8             	pushl  -0x28(%ebp)
f010582a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010582d:	ff 75 e0             	pushl  -0x20(%ebp)
f0105830:	e8 2b 16 00 00       	call   f0106e60 <__umoddi3>
f0105835:	83 c4 14             	add    $0x14,%esp
f0105838:	0f be 80 aa 87 10 f0 	movsbl -0xfef7856(%eax),%eax
f010583f:	50                   	push   %eax
f0105840:	ff d7                	call   *%edi
f0105842:	83 c4 10             	add    $0x10,%esp
f0105845:	eb 16                	jmp    f010585d <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
f0105847:	83 ec 08             	sub    $0x8,%esp
f010584a:	56                   	push   %esi
f010584b:	ff 75 18             	pushl  0x18(%ebp)
f010584e:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0105850:	83 c4 10             	add    $0x10,%esp
f0105853:	83 eb 01             	sub    $0x1,%ebx
f0105856:	75 ef                	jne    f0105847 <printnum+0x7b>
f0105858:	e9 a2 00 00 00       	jmp    f01058ff <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
f010585d:	3b 1d 88 1a 24 f0    	cmp    0xf0241a88,%ebx
f0105863:	0f 85 76 01 00 00    	jne    f01059df <printnum+0x213>
		while(num_of_space-- > 0)
f0105869:	a1 84 1a 24 f0       	mov    0xf0241a84,%eax
f010586e:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105871:	89 15 84 1a 24 f0    	mov    %edx,0xf0241a84
f0105877:	85 c0                	test   %eax,%eax
f0105879:	7e 1d                	jle    f0105898 <printnum+0xcc>
			putch(' ', putdat);
f010587b:	83 ec 08             	sub    $0x8,%esp
f010587e:	56                   	push   %esi
f010587f:	6a 20                	push   $0x20
f0105881:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
f0105883:	a1 84 1a 24 f0       	mov    0xf0241a84,%eax
f0105888:	8d 50 ff             	lea    -0x1(%eax),%edx
f010588b:	89 15 84 1a 24 f0    	mov    %edx,0xf0241a84
f0105891:	83 c4 10             	add    $0x10,%esp
f0105894:	85 c0                	test   %eax,%eax
f0105896:	7f e3                	jg     f010587b <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
f0105898:	c7 05 84 1a 24 f0 00 	movl   $0x0,0xf0241a84
f010589f:	00 00 00 
		judge_time_for_space = 0;
f01058a2:	c7 05 88 1a 24 f0 00 	movl   $0x0,0xf0241a88
f01058a9:	00 00 00 
	}
}
f01058ac:	e9 2e 01 00 00       	jmp    f01059df <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01058b1:	8b 45 10             	mov    0x10(%ebp),%eax
f01058b4:	ba 00 00 00 00       	mov    $0x0,%edx
f01058b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01058bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01058bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01058c5:	83 fa 00             	cmp    $0x0,%edx
f01058c8:	0f 87 ba 00 00 00    	ja     f0105988 <printnum+0x1bc>
f01058ce:	3b 45 10             	cmp    0x10(%ebp),%eax
f01058d1:	0f 83 b1 00 00 00    	jae    f0105988 <printnum+0x1bc>
f01058d7:	e9 2d ff ff ff       	jmp    f0105809 <printnum+0x3d>
f01058dc:	8b 45 10             	mov    0x10(%ebp),%eax
f01058df:	ba 00 00 00 00       	mov    $0x0,%edx
f01058e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01058e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01058ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01058f0:	83 fa 00             	cmp    $0x0,%edx
f01058f3:	77 37                	ja     f010592c <printnum+0x160>
f01058f5:	3b 45 10             	cmp    0x10(%ebp),%eax
f01058f8:	73 32                	jae    f010592c <printnum+0x160>
f01058fa:	e9 16 ff ff ff       	jmp    f0105815 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01058ff:	83 ec 08             	sub    $0x8,%esp
f0105902:	56                   	push   %esi
f0105903:	83 ec 04             	sub    $0x4,%esp
f0105906:	ff 75 dc             	pushl  -0x24(%ebp)
f0105909:	ff 75 d8             	pushl  -0x28(%ebp)
f010590c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010590f:	ff 75 e0             	pushl  -0x20(%ebp)
f0105912:	e8 49 15 00 00       	call   f0106e60 <__umoddi3>
f0105917:	83 c4 14             	add    $0x14,%esp
f010591a:	0f be 80 aa 87 10 f0 	movsbl -0xfef7856(%eax),%eax
f0105921:	50                   	push   %eax
f0105922:	ff d7                	call   *%edi
f0105924:	83 c4 10             	add    $0x10,%esp
f0105927:	e9 b3 00 00 00       	jmp    f01059df <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010592c:	83 ec 0c             	sub    $0xc,%esp
f010592f:	ff 75 18             	pushl  0x18(%ebp)
f0105932:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105935:	50                   	push   %eax
f0105936:	ff 75 10             	pushl  0x10(%ebp)
f0105939:	83 ec 08             	sub    $0x8,%esp
f010593c:	ff 75 dc             	pushl  -0x24(%ebp)
f010593f:	ff 75 d8             	pushl  -0x28(%ebp)
f0105942:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105945:	ff 75 e0             	pushl  -0x20(%ebp)
f0105948:	e8 e3 13 00 00       	call   f0106d30 <__udivdi3>
f010594d:	83 c4 18             	add    $0x18,%esp
f0105950:	52                   	push   %edx
f0105951:	50                   	push   %eax
f0105952:	89 f2                	mov    %esi,%edx
f0105954:	89 f8                	mov    %edi,%eax
f0105956:	e8 71 fe ff ff       	call   f01057cc <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010595b:	83 c4 18             	add    $0x18,%esp
f010595e:	56                   	push   %esi
f010595f:	83 ec 04             	sub    $0x4,%esp
f0105962:	ff 75 dc             	pushl  -0x24(%ebp)
f0105965:	ff 75 d8             	pushl  -0x28(%ebp)
f0105968:	ff 75 e4             	pushl  -0x1c(%ebp)
f010596b:	ff 75 e0             	pushl  -0x20(%ebp)
f010596e:	e8 ed 14 00 00       	call   f0106e60 <__umoddi3>
f0105973:	83 c4 14             	add    $0x14,%esp
f0105976:	0f be 80 aa 87 10 f0 	movsbl -0xfef7856(%eax),%eax
f010597d:	50                   	push   %eax
f010597e:	ff d7                	call   *%edi
f0105980:	83 c4 10             	add    $0x10,%esp
f0105983:	e9 d5 fe ff ff       	jmp    f010585d <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105988:	83 ec 0c             	sub    $0xc,%esp
f010598b:	ff 75 18             	pushl  0x18(%ebp)
f010598e:	83 eb 01             	sub    $0x1,%ebx
f0105991:	53                   	push   %ebx
f0105992:	ff 75 10             	pushl  0x10(%ebp)
f0105995:	83 ec 08             	sub    $0x8,%esp
f0105998:	ff 75 dc             	pushl  -0x24(%ebp)
f010599b:	ff 75 d8             	pushl  -0x28(%ebp)
f010599e:	ff 75 e4             	pushl  -0x1c(%ebp)
f01059a1:	ff 75 e0             	pushl  -0x20(%ebp)
f01059a4:	e8 87 13 00 00       	call   f0106d30 <__udivdi3>
f01059a9:	83 c4 18             	add    $0x18,%esp
f01059ac:	52                   	push   %edx
f01059ad:	50                   	push   %eax
f01059ae:	89 f2                	mov    %esi,%edx
f01059b0:	89 f8                	mov    %edi,%eax
f01059b2:	e8 15 fe ff ff       	call   f01057cc <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01059b7:	83 c4 18             	add    $0x18,%esp
f01059ba:	56                   	push   %esi
f01059bb:	83 ec 04             	sub    $0x4,%esp
f01059be:	ff 75 dc             	pushl  -0x24(%ebp)
f01059c1:	ff 75 d8             	pushl  -0x28(%ebp)
f01059c4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01059c7:	ff 75 e0             	pushl  -0x20(%ebp)
f01059ca:	e8 91 14 00 00       	call   f0106e60 <__umoddi3>
f01059cf:	83 c4 14             	add    $0x14,%esp
f01059d2:	0f be 80 aa 87 10 f0 	movsbl -0xfef7856(%eax),%eax
f01059d9:	50                   	push   %eax
f01059da:	ff d7                	call   *%edi
f01059dc:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
f01059df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059e2:	5b                   	pop    %ebx
f01059e3:	5e                   	pop    %esi
f01059e4:	5f                   	pop    %edi
f01059e5:	5d                   	pop    %ebp
f01059e6:	c3                   	ret    

f01059e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01059e7:	55                   	push   %ebp
f01059e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01059ea:	83 fa 01             	cmp    $0x1,%edx
f01059ed:	7e 0e                	jle    f01059fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01059ef:	8b 10                	mov    (%eax),%edx
f01059f1:	8d 4a 08             	lea    0x8(%edx),%ecx
f01059f4:	89 08                	mov    %ecx,(%eax)
f01059f6:	8b 02                	mov    (%edx),%eax
f01059f8:	8b 52 04             	mov    0x4(%edx),%edx
f01059fb:	eb 22                	jmp    f0105a1f <getuint+0x38>
	else if (lflag)
f01059fd:	85 d2                	test   %edx,%edx
f01059ff:	74 10                	je     f0105a11 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105a01:	8b 10                	mov    (%eax),%edx
f0105a03:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105a06:	89 08                	mov    %ecx,(%eax)
f0105a08:	8b 02                	mov    (%edx),%eax
f0105a0a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a0f:	eb 0e                	jmp    f0105a1f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105a11:	8b 10                	mov    (%eax),%edx
f0105a13:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105a16:	89 08                	mov    %ecx,(%eax)
f0105a18:	8b 02                	mov    (%edx),%eax
f0105a1a:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105a1f:	5d                   	pop    %ebp
f0105a20:	c3                   	ret    

f0105a21 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105a21:	55                   	push   %ebp
f0105a22:	89 e5                	mov    %esp,%ebp
f0105a24:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105a27:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105a2b:	8b 10                	mov    (%eax),%edx
f0105a2d:	3b 50 04             	cmp    0x4(%eax),%edx
f0105a30:	73 0a                	jae    f0105a3c <sprintputch+0x1b>
		*b->buf++ = ch;
f0105a32:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105a35:	89 08                	mov    %ecx,(%eax)
f0105a37:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a3a:	88 02                	mov    %al,(%edx)
}
f0105a3c:	5d                   	pop    %ebp
f0105a3d:	c3                   	ret    

f0105a3e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105a3e:	55                   	push   %ebp
f0105a3f:	89 e5                	mov    %esp,%ebp
f0105a41:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105a44:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105a47:	50                   	push   %eax
f0105a48:	ff 75 10             	pushl  0x10(%ebp)
f0105a4b:	ff 75 0c             	pushl  0xc(%ebp)
f0105a4e:	ff 75 08             	pushl  0x8(%ebp)
f0105a51:	e8 05 00 00 00       	call   f0105a5b <vprintfmt>
	va_end(ap);
}
f0105a56:	83 c4 10             	add    $0x10,%esp
f0105a59:	c9                   	leave  
f0105a5a:	c3                   	ret    

f0105a5b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105a5b:	55                   	push   %ebp
f0105a5c:	89 e5                	mov    %esp,%ebp
f0105a5e:	57                   	push   %edi
f0105a5f:	56                   	push   %esi
f0105a60:	53                   	push   %ebx
f0105a61:	83 ec 2c             	sub    $0x2c,%esp
f0105a64:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105a67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a6a:	eb 03                	jmp    f0105a6f <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a6c:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105a6f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a72:	8d 70 01             	lea    0x1(%eax),%esi
f0105a75:	0f b6 00             	movzbl (%eax),%eax
f0105a78:	83 f8 25             	cmp    $0x25,%eax
f0105a7b:	74 27                	je     f0105aa4 <vprintfmt+0x49>
			if (ch == '\0')
f0105a7d:	85 c0                	test   %eax,%eax
f0105a7f:	75 0d                	jne    f0105a8e <vprintfmt+0x33>
f0105a81:	e9 9d 04 00 00       	jmp    f0105f23 <vprintfmt+0x4c8>
f0105a86:	85 c0                	test   %eax,%eax
f0105a88:	0f 84 95 04 00 00    	je     f0105f23 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
f0105a8e:	83 ec 08             	sub    $0x8,%esp
f0105a91:	53                   	push   %ebx
f0105a92:	50                   	push   %eax
f0105a93:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105a95:	83 c6 01             	add    $0x1,%esi
f0105a98:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0105a9c:	83 c4 10             	add    $0x10,%esp
f0105a9f:	83 f8 25             	cmp    $0x25,%eax
f0105aa2:	75 e2                	jne    f0105a86 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105aa4:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105aa9:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f0105aad:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105ab4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105abb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105ac2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0105ac9:	eb 08                	jmp    f0105ad3 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105acb:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
f0105ace:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ad3:	8d 46 01             	lea    0x1(%esi),%eax
f0105ad6:	89 45 10             	mov    %eax,0x10(%ebp)
f0105ad9:	0f b6 06             	movzbl (%esi),%eax
f0105adc:	0f b6 d0             	movzbl %al,%edx
f0105adf:	83 e8 23             	sub    $0x23,%eax
f0105ae2:	3c 55                	cmp    $0x55,%al
f0105ae4:	0f 87 fa 03 00 00    	ja     f0105ee4 <vprintfmt+0x489>
f0105aea:	0f b6 c0             	movzbl %al,%eax
f0105aed:	ff 24 85 e0 88 10 f0 	jmp    *-0xfef7720(,%eax,4)
f0105af4:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f0105af7:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f0105afb:	eb d6                	jmp    f0105ad3 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105afd:	8d 42 d0             	lea    -0x30(%edx),%eax
f0105b00:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f0105b03:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105b07:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105b0a:	83 fa 09             	cmp    $0x9,%edx
f0105b0d:	77 6b                	ja     f0105b7a <vprintfmt+0x11f>
f0105b0f:	8b 75 10             	mov    0x10(%ebp),%esi
f0105b12:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105b15:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105b18:	eb 09                	jmp    f0105b23 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b1a:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105b1d:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f0105b21:	eb b0                	jmp    f0105ad3 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105b23:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105b26:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105b29:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105b2d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105b30:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105b33:	83 f9 09             	cmp    $0x9,%ecx
f0105b36:	76 eb                	jbe    f0105b23 <vprintfmt+0xc8>
f0105b38:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105b3b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105b3e:	eb 3d                	jmp    f0105b7d <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105b40:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b43:	8d 50 04             	lea    0x4(%eax),%edx
f0105b46:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b49:	8b 00                	mov    (%eax),%eax
f0105b4b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b4e:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105b51:	eb 2a                	jmp    f0105b7d <vprintfmt+0x122>
f0105b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b56:	85 c0                	test   %eax,%eax
f0105b58:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b5d:	0f 49 d0             	cmovns %eax,%edx
f0105b60:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b63:	8b 75 10             	mov    0x10(%ebp),%esi
f0105b66:	e9 68 ff ff ff       	jmp    f0105ad3 <vprintfmt+0x78>
f0105b6b:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105b6e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105b75:	e9 59 ff ff ff       	jmp    f0105ad3 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b7a:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0105b7d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105b81:	0f 89 4c ff ff ff    	jns    f0105ad3 <vprintfmt+0x78>
				width = precision, precision = -1;
f0105b87:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105b8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b8d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105b94:	e9 3a ff ff ff       	jmp    f0105ad3 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105b99:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b9d:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105ba0:	e9 2e ff ff ff       	jmp    f0105ad3 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105ba5:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ba8:	8d 50 04             	lea    0x4(%eax),%edx
f0105bab:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bae:	83 ec 08             	sub    $0x8,%esp
f0105bb1:	53                   	push   %ebx
f0105bb2:	ff 30                	pushl  (%eax)
f0105bb4:	ff d7                	call   *%edi
			break;
f0105bb6:	83 c4 10             	add    $0x10,%esp
f0105bb9:	e9 b1 fe ff ff       	jmp    f0105a6f <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105bbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bc1:	8d 50 04             	lea    0x4(%eax),%edx
f0105bc4:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bc7:	8b 00                	mov    (%eax),%eax
f0105bc9:	99                   	cltd   
f0105bca:	31 d0                	xor    %edx,%eax
f0105bcc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105bce:	83 f8 08             	cmp    $0x8,%eax
f0105bd1:	7f 0b                	jg     f0105bde <vprintfmt+0x183>
f0105bd3:	8b 14 85 40 8a 10 f0 	mov    -0xfef75c0(,%eax,4),%edx
f0105bda:	85 d2                	test   %edx,%edx
f0105bdc:	75 15                	jne    f0105bf3 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
f0105bde:	50                   	push   %eax
f0105bdf:	68 c2 87 10 f0       	push   $0xf01087c2
f0105be4:	53                   	push   %ebx
f0105be5:	57                   	push   %edi
f0105be6:	e8 53 fe ff ff       	call   f0105a3e <printfmt>
f0105beb:	83 c4 10             	add    $0x10,%esp
f0105bee:	e9 7c fe ff ff       	jmp    f0105a6f <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f0105bf3:	52                   	push   %edx
f0105bf4:	68 2d 7e 10 f0       	push   $0xf0107e2d
f0105bf9:	53                   	push   %ebx
f0105bfa:	57                   	push   %edi
f0105bfb:	e8 3e fe ff ff       	call   f0105a3e <printfmt>
f0105c00:	83 c4 10             	add    $0x10,%esp
f0105c03:	e9 67 fe ff ff       	jmp    f0105a6f <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105c08:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c0b:	8d 50 04             	lea    0x4(%eax),%edx
f0105c0e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c11:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0105c13:	85 c0                	test   %eax,%eax
f0105c15:	b9 bb 87 10 f0       	mov    $0xf01087bb,%ecx
f0105c1a:	0f 45 c8             	cmovne %eax,%ecx
f0105c1d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0105c20:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105c24:	7e 06                	jle    f0105c2c <vprintfmt+0x1d1>
f0105c26:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0105c2a:	75 19                	jne    f0105c45 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105c2c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105c2f:	8d 70 01             	lea    0x1(%eax),%esi
f0105c32:	0f b6 00             	movzbl (%eax),%eax
f0105c35:	0f be d0             	movsbl %al,%edx
f0105c38:	85 d2                	test   %edx,%edx
f0105c3a:	0f 85 9f 00 00 00    	jne    f0105cdf <vprintfmt+0x284>
f0105c40:	e9 8c 00 00 00       	jmp    f0105cd1 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c45:	83 ec 08             	sub    $0x8,%esp
f0105c48:	ff 75 d0             	pushl  -0x30(%ebp)
f0105c4b:	ff 75 cc             	pushl  -0x34(%ebp)
f0105c4e:	e8 3b 04 00 00       	call   f010608e <strnlen>
f0105c53:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f0105c56:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105c59:	83 c4 10             	add    $0x10,%esp
f0105c5c:	85 c9                	test   %ecx,%ecx
f0105c5e:	0f 8e a6 02 00 00    	jle    f0105f0a <vprintfmt+0x4af>
					putch(padc, putdat);
f0105c64:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105c68:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105c6b:	89 cb                	mov    %ecx,%ebx
f0105c6d:	83 ec 08             	sub    $0x8,%esp
f0105c70:	ff 75 0c             	pushl  0xc(%ebp)
f0105c73:	56                   	push   %esi
f0105c74:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c76:	83 c4 10             	add    $0x10,%esp
f0105c79:	83 eb 01             	sub    $0x1,%ebx
f0105c7c:	75 ef                	jne    f0105c6d <vprintfmt+0x212>
f0105c7e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105c84:	e9 81 02 00 00       	jmp    f0105f0a <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105c89:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105c8d:	74 1b                	je     f0105caa <vprintfmt+0x24f>
f0105c8f:	0f be c0             	movsbl %al,%eax
f0105c92:	83 e8 20             	sub    $0x20,%eax
f0105c95:	83 f8 5e             	cmp    $0x5e,%eax
f0105c98:	76 10                	jbe    f0105caa <vprintfmt+0x24f>
					putch('?', putdat);
f0105c9a:	83 ec 08             	sub    $0x8,%esp
f0105c9d:	ff 75 0c             	pushl  0xc(%ebp)
f0105ca0:	6a 3f                	push   $0x3f
f0105ca2:	ff 55 08             	call   *0x8(%ebp)
f0105ca5:	83 c4 10             	add    $0x10,%esp
f0105ca8:	eb 0d                	jmp    f0105cb7 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
f0105caa:	83 ec 08             	sub    $0x8,%esp
f0105cad:	ff 75 0c             	pushl  0xc(%ebp)
f0105cb0:	52                   	push   %edx
f0105cb1:	ff 55 08             	call   *0x8(%ebp)
f0105cb4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105cb7:	83 ef 01             	sub    $0x1,%edi
f0105cba:	83 c6 01             	add    $0x1,%esi
f0105cbd:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0105cc1:	0f be d0             	movsbl %al,%edx
f0105cc4:	85 d2                	test   %edx,%edx
f0105cc6:	75 31                	jne    f0105cf9 <vprintfmt+0x29e>
f0105cc8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105ccb:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105cce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105cd1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105cd4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105cd8:	7f 33                	jg     f0105d0d <vprintfmt+0x2b2>
f0105cda:	e9 90 fd ff ff       	jmp    f0105a6f <vprintfmt+0x14>
f0105cdf:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105ce2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105ce5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105ce8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105ceb:	eb 0c                	jmp    f0105cf9 <vprintfmt+0x29e>
f0105ced:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105cf0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105cf3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105cf6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105cf9:	85 db                	test   %ebx,%ebx
f0105cfb:	78 8c                	js     f0105c89 <vprintfmt+0x22e>
f0105cfd:	83 eb 01             	sub    $0x1,%ebx
f0105d00:	79 87                	jns    f0105c89 <vprintfmt+0x22e>
f0105d02:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105d05:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d0b:	eb c4                	jmp    f0105cd1 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105d0d:	83 ec 08             	sub    $0x8,%esp
f0105d10:	53                   	push   %ebx
f0105d11:	6a 20                	push   $0x20
f0105d13:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105d15:	83 c4 10             	add    $0x10,%esp
f0105d18:	83 ee 01             	sub    $0x1,%esi
f0105d1b:	75 f0                	jne    f0105d0d <vprintfmt+0x2b2>
f0105d1d:	e9 4d fd ff ff       	jmp    f0105a6f <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105d22:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f0105d26:	7e 16                	jle    f0105d3e <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
f0105d28:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d2b:	8d 50 08             	lea    0x8(%eax),%edx
f0105d2e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d31:	8b 50 04             	mov    0x4(%eax),%edx
f0105d34:	8b 00                	mov    (%eax),%eax
f0105d36:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105d39:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105d3c:	eb 34                	jmp    f0105d72 <vprintfmt+0x317>
	else if (lflag)
f0105d3e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105d42:	74 18                	je     f0105d5c <vprintfmt+0x301>
		return va_arg(*ap, long);
f0105d44:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d47:	8d 50 04             	lea    0x4(%eax),%edx
f0105d4a:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d4d:	8b 30                	mov    (%eax),%esi
f0105d4f:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105d52:	89 f0                	mov    %esi,%eax
f0105d54:	c1 f8 1f             	sar    $0x1f,%eax
f0105d57:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105d5a:	eb 16                	jmp    f0105d72 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
f0105d5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d5f:	8d 50 04             	lea    0x4(%eax),%edx
f0105d62:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d65:	8b 30                	mov    (%eax),%esi
f0105d67:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105d6a:	89 f0                	mov    %esi,%eax
f0105d6c:	c1 f8 1f             	sar    $0x1f,%eax
f0105d6f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105d72:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105d75:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105d78:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105d7b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0105d7e:	85 d2                	test   %edx,%edx
f0105d80:	79 28                	jns    f0105daa <vprintfmt+0x34f>
				putch('-', putdat);
f0105d82:	83 ec 08             	sub    $0x8,%esp
f0105d85:	53                   	push   %ebx
f0105d86:	6a 2d                	push   $0x2d
f0105d88:	ff d7                	call   *%edi
				num = -(long long) num;
f0105d8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105d8d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105d90:	f7 d8                	neg    %eax
f0105d92:	83 d2 00             	adc    $0x0,%edx
f0105d95:	f7 da                	neg    %edx
f0105d97:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105d9a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105d9d:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
f0105da0:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105da5:	e9 b2 00 00 00       	jmp    f0105e5c <vprintfmt+0x401>
f0105daa:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
f0105daf:	85 c9                	test   %ecx,%ecx
f0105db1:	0f 84 a5 00 00 00    	je     f0105e5c <vprintfmt+0x401>
				putch('+', putdat);
f0105db7:	83 ec 08             	sub    $0x8,%esp
f0105dba:	53                   	push   %ebx
f0105dbb:	6a 2b                	push   $0x2b
f0105dbd:	ff d7                	call   *%edi
f0105dbf:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
f0105dc2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105dc7:	e9 90 00 00 00       	jmp    f0105e5c <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
f0105dcc:	85 c9                	test   %ecx,%ecx
f0105dce:	74 0b                	je     f0105ddb <vprintfmt+0x380>
				putch('+', putdat);
f0105dd0:	83 ec 08             	sub    $0x8,%esp
f0105dd3:	53                   	push   %ebx
f0105dd4:	6a 2b                	push   $0x2b
f0105dd6:	ff d7                	call   *%edi
f0105dd8:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
f0105ddb:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105dde:	8d 45 14             	lea    0x14(%ebp),%eax
f0105de1:	e8 01 fc ff ff       	call   f01059e7 <getuint>
f0105de6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105de9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0105dec:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105df1:	eb 69                	jmp    f0105e5c <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
f0105df3:	83 ec 08             	sub    $0x8,%esp
f0105df6:	53                   	push   %ebx
f0105df7:	6a 30                	push   $0x30
f0105df9:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f0105dfb:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105dfe:	8d 45 14             	lea    0x14(%ebp),%eax
f0105e01:	e8 e1 fb ff ff       	call   f01059e7 <getuint>
f0105e06:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105e09:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f0105e0c:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0105e0f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105e14:	eb 46                	jmp    f0105e5c <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105e16:	83 ec 08             	sub    $0x8,%esp
f0105e19:	53                   	push   %ebx
f0105e1a:	6a 30                	push   $0x30
f0105e1c:	ff d7                	call   *%edi
			putch('x', putdat);
f0105e1e:	83 c4 08             	add    $0x8,%esp
f0105e21:	53                   	push   %ebx
f0105e22:	6a 78                	push   $0x78
f0105e24:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105e26:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e29:	8d 50 04             	lea    0x4(%eax),%edx
f0105e2c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105e2f:	8b 00                	mov    (%eax),%eax
f0105e31:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e36:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105e39:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105e3c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105e3f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105e44:	eb 16                	jmp    f0105e5c <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105e46:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105e49:	8d 45 14             	lea    0x14(%ebp),%eax
f0105e4c:	e8 96 fb ff ff       	call   f01059e7 <getuint>
f0105e51:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105e54:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0105e57:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105e5c:	83 ec 0c             	sub    $0xc,%esp
f0105e5f:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105e63:	56                   	push   %esi
f0105e64:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105e67:	50                   	push   %eax
f0105e68:	ff 75 dc             	pushl  -0x24(%ebp)
f0105e6b:	ff 75 d8             	pushl  -0x28(%ebp)
f0105e6e:	89 da                	mov    %ebx,%edx
f0105e70:	89 f8                	mov    %edi,%eax
f0105e72:	e8 55 f9 ff ff       	call   f01057cc <printnum>
			break;
f0105e77:	83 c4 20             	add    $0x20,%esp
f0105e7a:	e9 f0 fb ff ff       	jmp    f0105a6f <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
f0105e7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e82:	8d 50 04             	lea    0x4(%eax),%edx
f0105e85:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e88:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
f0105e8a:	85 f6                	test   %esi,%esi
f0105e8c:	75 1a                	jne    f0105ea8 <vprintfmt+0x44d>
						cprintf("%s", null_error);
f0105e8e:	83 ec 08             	sub    $0x8,%esp
f0105e91:	68 60 88 10 f0       	push   $0xf0108860
f0105e96:	68 2d 7e 10 f0       	push   $0xf0107e2d
f0105e9b:	e8 ee df ff ff       	call   f0103e8e <cprintf>
f0105ea0:	83 c4 10             	add    $0x10,%esp
f0105ea3:	e9 c7 fb ff ff       	jmp    f0105a6f <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
f0105ea8:	0f b6 03             	movzbl (%ebx),%eax
f0105eab:	84 c0                	test   %al,%al
f0105ead:	79 1f                	jns    f0105ece <vprintfmt+0x473>
						cprintf("%s", overflow_error);
f0105eaf:	83 ec 08             	sub    $0x8,%esp
f0105eb2:	68 98 88 10 f0       	push   $0xf0108898
f0105eb7:	68 2d 7e 10 f0       	push   $0xf0107e2d
f0105ebc:	e8 cd df ff ff       	call   f0103e8e <cprintf>
						*tmp = *(char *)putdat;
f0105ec1:	0f b6 03             	movzbl (%ebx),%eax
f0105ec4:	88 06                	mov    %al,(%esi)
f0105ec6:	83 c4 10             	add    $0x10,%esp
f0105ec9:	e9 a1 fb ff ff       	jmp    f0105a6f <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
f0105ece:	88 06                	mov    %al,(%esi)
f0105ed0:	e9 9a fb ff ff       	jmp    f0105a6f <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105ed5:	83 ec 08             	sub    $0x8,%esp
f0105ed8:	53                   	push   %ebx
f0105ed9:	52                   	push   %edx
f0105eda:	ff d7                	call   *%edi
			break;
f0105edc:	83 c4 10             	add    $0x10,%esp
f0105edf:	e9 8b fb ff ff       	jmp    f0105a6f <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105ee4:	83 ec 08             	sub    $0x8,%esp
f0105ee7:	53                   	push   %ebx
f0105ee8:	6a 25                	push   $0x25
f0105eea:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105eec:	83 c4 10             	add    $0x10,%esp
f0105eef:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105ef3:	0f 84 73 fb ff ff    	je     f0105a6c <vprintfmt+0x11>
f0105ef9:	83 ee 01             	sub    $0x1,%esi
f0105efc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105f00:	75 f7                	jne    f0105ef9 <vprintfmt+0x49e>
f0105f02:	89 75 10             	mov    %esi,0x10(%ebp)
f0105f05:	e9 65 fb ff ff       	jmp    f0105a6f <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105f0a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105f0d:	8d 70 01             	lea    0x1(%eax),%esi
f0105f10:	0f b6 00             	movzbl (%eax),%eax
f0105f13:	0f be d0             	movsbl %al,%edx
f0105f16:	85 d2                	test   %edx,%edx
f0105f18:	0f 85 cf fd ff ff    	jne    f0105ced <vprintfmt+0x292>
f0105f1e:	e9 4c fb ff ff       	jmp    f0105a6f <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0105f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f26:	5b                   	pop    %ebx
f0105f27:	5e                   	pop    %esi
f0105f28:	5f                   	pop    %edi
f0105f29:	5d                   	pop    %ebp
f0105f2a:	c3                   	ret    

f0105f2b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105f2b:	55                   	push   %ebp
f0105f2c:	89 e5                	mov    %esp,%ebp
f0105f2e:	83 ec 18             	sub    $0x18,%esp
f0105f31:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f34:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105f37:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105f3a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105f3e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105f41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105f48:	85 c0                	test   %eax,%eax
f0105f4a:	74 26                	je     f0105f72 <vsnprintf+0x47>
f0105f4c:	85 d2                	test   %edx,%edx
f0105f4e:	7e 22                	jle    f0105f72 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105f50:	ff 75 14             	pushl  0x14(%ebp)
f0105f53:	ff 75 10             	pushl  0x10(%ebp)
f0105f56:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105f59:	50                   	push   %eax
f0105f5a:	68 21 5a 10 f0       	push   $0xf0105a21
f0105f5f:	e8 f7 fa ff ff       	call   f0105a5b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105f67:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105f6d:	83 c4 10             	add    $0x10,%esp
f0105f70:	eb 05                	jmp    f0105f77 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105f72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105f77:	c9                   	leave  
f0105f78:	c3                   	ret    

f0105f79 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105f79:	55                   	push   %ebp
f0105f7a:	89 e5                	mov    %esp,%ebp
f0105f7c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105f7f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105f82:	50                   	push   %eax
f0105f83:	ff 75 10             	pushl  0x10(%ebp)
f0105f86:	ff 75 0c             	pushl  0xc(%ebp)
f0105f89:	ff 75 08             	pushl  0x8(%ebp)
f0105f8c:	e8 9a ff ff ff       	call   f0105f2b <vsnprintf>
	va_end(ap);

	return rc;
}
f0105f91:	c9                   	leave  
f0105f92:	c3                   	ret    

f0105f93 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105f93:	55                   	push   %ebp
f0105f94:	89 e5                	mov    %esp,%ebp
f0105f96:	57                   	push   %edi
f0105f97:	56                   	push   %esi
f0105f98:	53                   	push   %ebx
f0105f99:	83 ec 0c             	sub    $0xc,%esp
f0105f9c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105f9f:	85 c0                	test   %eax,%eax
f0105fa1:	74 11                	je     f0105fb4 <readline+0x21>
		cprintf("%s", prompt);
f0105fa3:	83 ec 08             	sub    $0x8,%esp
f0105fa6:	50                   	push   %eax
f0105fa7:	68 2d 7e 10 f0       	push   $0xf0107e2d
f0105fac:	e8 dd de ff ff       	call   f0103e8e <cprintf>
f0105fb1:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105fb4:	83 ec 0c             	sub    $0xc,%esp
f0105fb7:	6a 00                	push   $0x0
f0105fb9:	e8 1d a9 ff ff       	call   f01008db <iscons>
f0105fbe:	89 c7                	mov    %eax,%edi
f0105fc0:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105fc3:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105fc8:	e8 fd a8 ff ff       	call   f01008ca <getchar>
f0105fcd:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105fcf:	85 c0                	test   %eax,%eax
f0105fd1:	79 18                	jns    f0105feb <readline+0x58>
			cprintf("read error: %e\n", c);
f0105fd3:	83 ec 08             	sub    $0x8,%esp
f0105fd6:	50                   	push   %eax
f0105fd7:	68 64 8a 10 f0       	push   $0xf0108a64
f0105fdc:	e8 ad de ff ff       	call   f0103e8e <cprintf>
			return NULL;
f0105fe1:	83 c4 10             	add    $0x10,%esp
f0105fe4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fe9:	eb 79                	jmp    f0106064 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105feb:	83 f8 08             	cmp    $0x8,%eax
f0105fee:	0f 94 c2             	sete   %dl
f0105ff1:	83 f8 7f             	cmp    $0x7f,%eax
f0105ff4:	0f 94 c0             	sete   %al
f0105ff7:	08 c2                	or     %al,%dl
f0105ff9:	74 1a                	je     f0106015 <readline+0x82>
f0105ffb:	85 f6                	test   %esi,%esi
f0105ffd:	7e 16                	jle    f0106015 <readline+0x82>
			if (echoing)
f0105fff:	85 ff                	test   %edi,%edi
f0106001:	74 0d                	je     f0106010 <readline+0x7d>
				cputchar('\b');
f0106003:	83 ec 0c             	sub    $0xc,%esp
f0106006:	6a 08                	push   $0x8
f0106008:	e8 ad a8 ff ff       	call   f01008ba <cputchar>
f010600d:	83 c4 10             	add    $0x10,%esp
			i--;
f0106010:	83 ee 01             	sub    $0x1,%esi
f0106013:	eb b3                	jmp    f0105fc8 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0106015:	83 fb 1f             	cmp    $0x1f,%ebx
f0106018:	7e 23                	jle    f010603d <readline+0xaa>
f010601a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106020:	7f 1b                	jg     f010603d <readline+0xaa>
			if (echoing)
f0106022:	85 ff                	test   %edi,%edi
f0106024:	74 0c                	je     f0106032 <readline+0x9f>
				cputchar(c);
f0106026:	83 ec 0c             	sub    $0xc,%esp
f0106029:	53                   	push   %ebx
f010602a:	e8 8b a8 ff ff       	call   f01008ba <cputchar>
f010602f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0106032:	88 9e a0 1a 24 f0    	mov    %bl,-0xfdbe560(%esi)
f0106038:	8d 76 01             	lea    0x1(%esi),%esi
f010603b:	eb 8b                	jmp    f0105fc8 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010603d:	83 fb 0a             	cmp    $0xa,%ebx
f0106040:	74 05                	je     f0106047 <readline+0xb4>
f0106042:	83 fb 0d             	cmp    $0xd,%ebx
f0106045:	75 81                	jne    f0105fc8 <readline+0x35>
			if (echoing)
f0106047:	85 ff                	test   %edi,%edi
f0106049:	74 0d                	je     f0106058 <readline+0xc5>
				cputchar('\n');
f010604b:	83 ec 0c             	sub    $0xc,%esp
f010604e:	6a 0a                	push   $0xa
f0106050:	e8 65 a8 ff ff       	call   f01008ba <cputchar>
f0106055:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0106058:	c6 86 a0 1a 24 f0 00 	movb   $0x0,-0xfdbe560(%esi)
			return buf;
f010605f:	b8 a0 1a 24 f0       	mov    $0xf0241aa0,%eax
		}
	}
}
f0106064:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106067:	5b                   	pop    %ebx
f0106068:	5e                   	pop    %esi
f0106069:	5f                   	pop    %edi
f010606a:	5d                   	pop    %ebp
f010606b:	c3                   	ret    

f010606c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010606c:	55                   	push   %ebp
f010606d:	89 e5                	mov    %esp,%ebp
f010606f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106072:	80 3a 00             	cmpb   $0x0,(%edx)
f0106075:	74 10                	je     f0106087 <strlen+0x1b>
f0106077:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f010607c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010607f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0106083:	75 f7                	jne    f010607c <strlen+0x10>
f0106085:	eb 05                	jmp    f010608c <strlen+0x20>
f0106087:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010608c:	5d                   	pop    %ebp
f010608d:	c3                   	ret    

f010608e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010608e:	55                   	push   %ebp
f010608f:	89 e5                	mov    %esp,%ebp
f0106091:	53                   	push   %ebx
f0106092:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106095:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106098:	85 c9                	test   %ecx,%ecx
f010609a:	74 1c                	je     f01060b8 <strnlen+0x2a>
f010609c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010609f:	74 1e                	je     f01060bf <strnlen+0x31>
f01060a1:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01060a6:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01060a8:	39 ca                	cmp    %ecx,%edx
f01060aa:	74 18                	je     f01060c4 <strnlen+0x36>
f01060ac:	83 c2 01             	add    $0x1,%edx
f01060af:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01060b4:	75 f0                	jne    f01060a6 <strnlen+0x18>
f01060b6:	eb 0c                	jmp    f01060c4 <strnlen+0x36>
f01060b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01060bd:	eb 05                	jmp    f01060c4 <strnlen+0x36>
f01060bf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01060c4:	5b                   	pop    %ebx
f01060c5:	5d                   	pop    %ebp
f01060c6:	c3                   	ret    

f01060c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01060c7:	55                   	push   %ebp
f01060c8:	89 e5                	mov    %esp,%ebp
f01060ca:	53                   	push   %ebx
f01060cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01060ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01060d1:	89 c2                	mov    %eax,%edx
f01060d3:	83 c2 01             	add    $0x1,%edx
f01060d6:	83 c1 01             	add    $0x1,%ecx
f01060d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01060dd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01060e0:	84 db                	test   %bl,%bl
f01060e2:	75 ef                	jne    f01060d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01060e4:	5b                   	pop    %ebx
f01060e5:	5d                   	pop    %ebp
f01060e6:	c3                   	ret    

f01060e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01060e7:	55                   	push   %ebp
f01060e8:	89 e5                	mov    %esp,%ebp
f01060ea:	53                   	push   %ebx
f01060eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01060ee:	53                   	push   %ebx
f01060ef:	e8 78 ff ff ff       	call   f010606c <strlen>
f01060f4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01060f7:	ff 75 0c             	pushl  0xc(%ebp)
f01060fa:	01 d8                	add    %ebx,%eax
f01060fc:	50                   	push   %eax
f01060fd:	e8 c5 ff ff ff       	call   f01060c7 <strcpy>
	return dst;
}
f0106102:	89 d8                	mov    %ebx,%eax
f0106104:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106107:	c9                   	leave  
f0106108:	c3                   	ret    

f0106109 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106109:	55                   	push   %ebp
f010610a:	89 e5                	mov    %esp,%ebp
f010610c:	56                   	push   %esi
f010610d:	53                   	push   %ebx
f010610e:	8b 75 08             	mov    0x8(%ebp),%esi
f0106111:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106114:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106117:	85 db                	test   %ebx,%ebx
f0106119:	74 17                	je     f0106132 <strncpy+0x29>
f010611b:	01 f3                	add    %esi,%ebx
f010611d:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f010611f:	83 c1 01             	add    $0x1,%ecx
f0106122:	0f b6 02             	movzbl (%edx),%eax
f0106125:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106128:	80 3a 01             	cmpb   $0x1,(%edx)
f010612b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010612e:	39 cb                	cmp    %ecx,%ebx
f0106130:	75 ed                	jne    f010611f <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106132:	89 f0                	mov    %esi,%eax
f0106134:	5b                   	pop    %ebx
f0106135:	5e                   	pop    %esi
f0106136:	5d                   	pop    %ebp
f0106137:	c3                   	ret    

f0106138 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106138:	55                   	push   %ebp
f0106139:	89 e5                	mov    %esp,%ebp
f010613b:	56                   	push   %esi
f010613c:	53                   	push   %ebx
f010613d:	8b 75 08             	mov    0x8(%ebp),%esi
f0106140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106143:	8b 55 10             	mov    0x10(%ebp),%edx
f0106146:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106148:	85 d2                	test   %edx,%edx
f010614a:	74 35                	je     f0106181 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f010614c:	89 d0                	mov    %edx,%eax
f010614e:	83 e8 01             	sub    $0x1,%eax
f0106151:	74 25                	je     f0106178 <strlcpy+0x40>
f0106153:	0f b6 0b             	movzbl (%ebx),%ecx
f0106156:	84 c9                	test   %cl,%cl
f0106158:	74 22                	je     f010617c <strlcpy+0x44>
f010615a:	8d 53 01             	lea    0x1(%ebx),%edx
f010615d:	01 c3                	add    %eax,%ebx
f010615f:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f0106161:	83 c0 01             	add    $0x1,%eax
f0106164:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106167:	39 da                	cmp    %ebx,%edx
f0106169:	74 13                	je     f010617e <strlcpy+0x46>
f010616b:	83 c2 01             	add    $0x1,%edx
f010616e:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f0106172:	84 c9                	test   %cl,%cl
f0106174:	75 eb                	jne    f0106161 <strlcpy+0x29>
f0106176:	eb 06                	jmp    f010617e <strlcpy+0x46>
f0106178:	89 f0                	mov    %esi,%eax
f010617a:	eb 02                	jmp    f010617e <strlcpy+0x46>
f010617c:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010617e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0106181:	29 f0                	sub    %esi,%eax
}
f0106183:	5b                   	pop    %ebx
f0106184:	5e                   	pop    %esi
f0106185:	5d                   	pop    %ebp
f0106186:	c3                   	ret    

f0106187 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0106187:	55                   	push   %ebp
f0106188:	89 e5                	mov    %esp,%ebp
f010618a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010618d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0106190:	0f b6 01             	movzbl (%ecx),%eax
f0106193:	84 c0                	test   %al,%al
f0106195:	74 15                	je     f01061ac <strcmp+0x25>
f0106197:	3a 02                	cmp    (%edx),%al
f0106199:	75 11                	jne    f01061ac <strcmp+0x25>
		p++, q++;
f010619b:	83 c1 01             	add    $0x1,%ecx
f010619e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01061a1:	0f b6 01             	movzbl (%ecx),%eax
f01061a4:	84 c0                	test   %al,%al
f01061a6:	74 04                	je     f01061ac <strcmp+0x25>
f01061a8:	3a 02                	cmp    (%edx),%al
f01061aa:	74 ef                	je     f010619b <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01061ac:	0f b6 c0             	movzbl %al,%eax
f01061af:	0f b6 12             	movzbl (%edx),%edx
f01061b2:	29 d0                	sub    %edx,%eax
}
f01061b4:	5d                   	pop    %ebp
f01061b5:	c3                   	ret    

f01061b6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01061b6:	55                   	push   %ebp
f01061b7:	89 e5                	mov    %esp,%ebp
f01061b9:	56                   	push   %esi
f01061ba:	53                   	push   %ebx
f01061bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01061be:	8b 55 0c             	mov    0xc(%ebp),%edx
f01061c1:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f01061c4:	85 f6                	test   %esi,%esi
f01061c6:	74 29                	je     f01061f1 <strncmp+0x3b>
f01061c8:	0f b6 03             	movzbl (%ebx),%eax
f01061cb:	84 c0                	test   %al,%al
f01061cd:	74 30                	je     f01061ff <strncmp+0x49>
f01061cf:	3a 02                	cmp    (%edx),%al
f01061d1:	75 2c                	jne    f01061ff <strncmp+0x49>
f01061d3:	8d 43 01             	lea    0x1(%ebx),%eax
f01061d6:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f01061d8:	89 c3                	mov    %eax,%ebx
f01061da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01061dd:	39 c6                	cmp    %eax,%esi
f01061df:	74 17                	je     f01061f8 <strncmp+0x42>
f01061e1:	0f b6 08             	movzbl (%eax),%ecx
f01061e4:	84 c9                	test   %cl,%cl
f01061e6:	74 17                	je     f01061ff <strncmp+0x49>
f01061e8:	83 c0 01             	add    $0x1,%eax
f01061eb:	3a 0a                	cmp    (%edx),%cl
f01061ed:	74 e9                	je     f01061d8 <strncmp+0x22>
f01061ef:	eb 0e                	jmp    f01061ff <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01061f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01061f6:	eb 0f                	jmp    f0106207 <strncmp+0x51>
f01061f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01061fd:	eb 08                	jmp    f0106207 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01061ff:	0f b6 03             	movzbl (%ebx),%eax
f0106202:	0f b6 12             	movzbl (%edx),%edx
f0106205:	29 d0                	sub    %edx,%eax
}
f0106207:	5b                   	pop    %ebx
f0106208:	5e                   	pop    %esi
f0106209:	5d                   	pop    %ebp
f010620a:	c3                   	ret    

f010620b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010620b:	55                   	push   %ebp
f010620c:	89 e5                	mov    %esp,%ebp
f010620e:	53                   	push   %ebx
f010620f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0106215:	0f b6 10             	movzbl (%eax),%edx
f0106218:	84 d2                	test   %dl,%dl
f010621a:	74 1d                	je     f0106239 <strchr+0x2e>
f010621c:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f010621e:	38 d3                	cmp    %dl,%bl
f0106220:	75 06                	jne    f0106228 <strchr+0x1d>
f0106222:	eb 1a                	jmp    f010623e <strchr+0x33>
f0106224:	38 ca                	cmp    %cl,%dl
f0106226:	74 16                	je     f010623e <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106228:	83 c0 01             	add    $0x1,%eax
f010622b:	0f b6 10             	movzbl (%eax),%edx
f010622e:	84 d2                	test   %dl,%dl
f0106230:	75 f2                	jne    f0106224 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f0106232:	b8 00 00 00 00       	mov    $0x0,%eax
f0106237:	eb 05                	jmp    f010623e <strchr+0x33>
f0106239:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010623e:	5b                   	pop    %ebx
f010623f:	5d                   	pop    %ebp
f0106240:	c3                   	ret    

f0106241 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0106241:	55                   	push   %ebp
f0106242:	89 e5                	mov    %esp,%ebp
f0106244:	53                   	push   %ebx
f0106245:	8b 45 08             	mov    0x8(%ebp),%eax
f0106248:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f010624b:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f010624e:	38 d3                	cmp    %dl,%bl
f0106250:	74 14                	je     f0106266 <strfind+0x25>
f0106252:	89 d1                	mov    %edx,%ecx
f0106254:	84 db                	test   %bl,%bl
f0106256:	74 0e                	je     f0106266 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106258:	83 c0 01             	add    $0x1,%eax
f010625b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010625e:	38 ca                	cmp    %cl,%dl
f0106260:	74 04                	je     f0106266 <strfind+0x25>
f0106262:	84 d2                	test   %dl,%dl
f0106264:	75 f2                	jne    f0106258 <strfind+0x17>
			break;
	return (char *) s;
}
f0106266:	5b                   	pop    %ebx
f0106267:	5d                   	pop    %ebp
f0106268:	c3                   	ret    

f0106269 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106269:	55                   	push   %ebp
f010626a:	89 e5                	mov    %esp,%ebp
f010626c:	57                   	push   %edi
f010626d:	56                   	push   %esi
f010626e:	53                   	push   %ebx
f010626f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106272:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106275:	85 c9                	test   %ecx,%ecx
f0106277:	74 36                	je     f01062af <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106279:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010627f:	75 28                	jne    f01062a9 <memset+0x40>
f0106281:	f6 c1 03             	test   $0x3,%cl
f0106284:	75 23                	jne    f01062a9 <memset+0x40>
		c &= 0xFF;
f0106286:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010628a:	89 d3                	mov    %edx,%ebx
f010628c:	c1 e3 08             	shl    $0x8,%ebx
f010628f:	89 d6                	mov    %edx,%esi
f0106291:	c1 e6 18             	shl    $0x18,%esi
f0106294:	89 d0                	mov    %edx,%eax
f0106296:	c1 e0 10             	shl    $0x10,%eax
f0106299:	09 f0                	or     %esi,%eax
f010629b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010629d:	89 d8                	mov    %ebx,%eax
f010629f:	09 d0                	or     %edx,%eax
f01062a1:	c1 e9 02             	shr    $0x2,%ecx
f01062a4:	fc                   	cld    
f01062a5:	f3 ab                	rep stos %eax,%es:(%edi)
f01062a7:	eb 06                	jmp    f01062af <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01062a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01062ac:	fc                   	cld    
f01062ad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01062af:	89 f8                	mov    %edi,%eax
f01062b1:	5b                   	pop    %ebx
f01062b2:	5e                   	pop    %esi
f01062b3:	5f                   	pop    %edi
f01062b4:	5d                   	pop    %ebp
f01062b5:	c3                   	ret    

f01062b6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01062b6:	55                   	push   %ebp
f01062b7:	89 e5                	mov    %esp,%ebp
f01062b9:	57                   	push   %edi
f01062ba:	56                   	push   %esi
f01062bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01062be:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01062c4:	39 c6                	cmp    %eax,%esi
f01062c6:	73 35                	jae    f01062fd <memmove+0x47>
f01062c8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01062cb:	39 d0                	cmp    %edx,%eax
f01062cd:	73 2e                	jae    f01062fd <memmove+0x47>
		s += n;
		d += n;
f01062cf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01062d2:	89 d6                	mov    %edx,%esi
f01062d4:	09 fe                	or     %edi,%esi
f01062d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01062dc:	75 13                	jne    f01062f1 <memmove+0x3b>
f01062de:	f6 c1 03             	test   $0x3,%cl
f01062e1:	75 0e                	jne    f01062f1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01062e3:	83 ef 04             	sub    $0x4,%edi
f01062e6:	8d 72 fc             	lea    -0x4(%edx),%esi
f01062e9:	c1 e9 02             	shr    $0x2,%ecx
f01062ec:	fd                   	std    
f01062ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01062ef:	eb 09                	jmp    f01062fa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01062f1:	83 ef 01             	sub    $0x1,%edi
f01062f4:	8d 72 ff             	lea    -0x1(%edx),%esi
f01062f7:	fd                   	std    
f01062f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01062fa:	fc                   	cld    
f01062fb:	eb 1d                	jmp    f010631a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01062fd:	89 f2                	mov    %esi,%edx
f01062ff:	09 c2                	or     %eax,%edx
f0106301:	f6 c2 03             	test   $0x3,%dl
f0106304:	75 0f                	jne    f0106315 <memmove+0x5f>
f0106306:	f6 c1 03             	test   $0x3,%cl
f0106309:	75 0a                	jne    f0106315 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010630b:	c1 e9 02             	shr    $0x2,%ecx
f010630e:	89 c7                	mov    %eax,%edi
f0106310:	fc                   	cld    
f0106311:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106313:	eb 05                	jmp    f010631a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106315:	89 c7                	mov    %eax,%edi
f0106317:	fc                   	cld    
f0106318:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010631a:	5e                   	pop    %esi
f010631b:	5f                   	pop    %edi
f010631c:	5d                   	pop    %ebp
f010631d:	c3                   	ret    

f010631e <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f010631e:	55                   	push   %ebp
f010631f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0106321:	ff 75 10             	pushl  0x10(%ebp)
f0106324:	ff 75 0c             	pushl  0xc(%ebp)
f0106327:	ff 75 08             	pushl  0x8(%ebp)
f010632a:	e8 87 ff ff ff       	call   f01062b6 <memmove>
}
f010632f:	c9                   	leave  
f0106330:	c3                   	ret    

f0106331 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106331:	55                   	push   %ebp
f0106332:	89 e5                	mov    %esp,%ebp
f0106334:	57                   	push   %edi
f0106335:	56                   	push   %esi
f0106336:	53                   	push   %ebx
f0106337:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010633a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010633d:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106340:	85 c0                	test   %eax,%eax
f0106342:	74 39                	je     f010637d <memcmp+0x4c>
f0106344:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f0106347:	0f b6 13             	movzbl (%ebx),%edx
f010634a:	0f b6 0e             	movzbl (%esi),%ecx
f010634d:	38 ca                	cmp    %cl,%dl
f010634f:	75 17                	jne    f0106368 <memcmp+0x37>
f0106351:	b8 00 00 00 00       	mov    $0x0,%eax
f0106356:	eb 1a                	jmp    f0106372 <memcmp+0x41>
f0106358:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f010635d:	83 c0 01             	add    $0x1,%eax
f0106360:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f0106364:	38 ca                	cmp    %cl,%dl
f0106366:	74 0a                	je     f0106372 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0106368:	0f b6 c2             	movzbl %dl,%eax
f010636b:	0f b6 c9             	movzbl %cl,%ecx
f010636e:	29 c8                	sub    %ecx,%eax
f0106370:	eb 10                	jmp    f0106382 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106372:	39 f8                	cmp    %edi,%eax
f0106374:	75 e2                	jne    f0106358 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106376:	b8 00 00 00 00       	mov    $0x0,%eax
f010637b:	eb 05                	jmp    f0106382 <memcmp+0x51>
f010637d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106382:	5b                   	pop    %ebx
f0106383:	5e                   	pop    %esi
f0106384:	5f                   	pop    %edi
f0106385:	5d                   	pop    %ebp
f0106386:	c3                   	ret    

f0106387 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106387:	55                   	push   %ebp
f0106388:	89 e5                	mov    %esp,%ebp
f010638a:	53                   	push   %ebx
f010638b:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f010638e:	89 d0                	mov    %edx,%eax
f0106390:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f0106393:	39 c2                	cmp    %eax,%edx
f0106395:	73 1d                	jae    f01063b4 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106397:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f010639b:	0f b6 0a             	movzbl (%edx),%ecx
f010639e:	39 d9                	cmp    %ebx,%ecx
f01063a0:	75 09                	jne    f01063ab <memfind+0x24>
f01063a2:	eb 14                	jmp    f01063b8 <memfind+0x31>
f01063a4:	0f b6 0a             	movzbl (%edx),%ecx
f01063a7:	39 d9                	cmp    %ebx,%ecx
f01063a9:	74 11                	je     f01063bc <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01063ab:	83 c2 01             	add    $0x1,%edx
f01063ae:	39 d0                	cmp    %edx,%eax
f01063b0:	75 f2                	jne    f01063a4 <memfind+0x1d>
f01063b2:	eb 0a                	jmp    f01063be <memfind+0x37>
f01063b4:	89 d0                	mov    %edx,%eax
f01063b6:	eb 06                	jmp    f01063be <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f01063b8:	89 d0                	mov    %edx,%eax
f01063ba:	eb 02                	jmp    f01063be <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01063bc:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01063be:	5b                   	pop    %ebx
f01063bf:	5d                   	pop    %ebp
f01063c0:	c3                   	ret    

f01063c1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01063c1:	55                   	push   %ebp
f01063c2:	89 e5                	mov    %esp,%ebp
f01063c4:	57                   	push   %edi
f01063c5:	56                   	push   %esi
f01063c6:	53                   	push   %ebx
f01063c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01063ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01063cd:	0f b6 01             	movzbl (%ecx),%eax
f01063d0:	3c 20                	cmp    $0x20,%al
f01063d2:	74 04                	je     f01063d8 <strtol+0x17>
f01063d4:	3c 09                	cmp    $0x9,%al
f01063d6:	75 0e                	jne    f01063e6 <strtol+0x25>
		s++;
f01063d8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01063db:	0f b6 01             	movzbl (%ecx),%eax
f01063de:	3c 20                	cmp    $0x20,%al
f01063e0:	74 f6                	je     f01063d8 <strtol+0x17>
f01063e2:	3c 09                	cmp    $0x9,%al
f01063e4:	74 f2                	je     f01063d8 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f01063e6:	3c 2b                	cmp    $0x2b,%al
f01063e8:	75 0a                	jne    f01063f4 <strtol+0x33>
		s++;
f01063ea:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01063ed:	bf 00 00 00 00       	mov    $0x0,%edi
f01063f2:	eb 11                	jmp    f0106405 <strtol+0x44>
f01063f4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01063f9:	3c 2d                	cmp    $0x2d,%al
f01063fb:	75 08                	jne    f0106405 <strtol+0x44>
		s++, neg = 1;
f01063fd:	83 c1 01             	add    $0x1,%ecx
f0106400:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106405:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010640b:	75 15                	jne    f0106422 <strtol+0x61>
f010640d:	80 39 30             	cmpb   $0x30,(%ecx)
f0106410:	75 10                	jne    f0106422 <strtol+0x61>
f0106412:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106416:	75 7c                	jne    f0106494 <strtol+0xd3>
		s += 2, base = 16;
f0106418:	83 c1 02             	add    $0x2,%ecx
f010641b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106420:	eb 16                	jmp    f0106438 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0106422:	85 db                	test   %ebx,%ebx
f0106424:	75 12                	jne    f0106438 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106426:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010642b:	80 39 30             	cmpb   $0x30,(%ecx)
f010642e:	75 08                	jne    f0106438 <strtol+0x77>
		s++, base = 8;
f0106430:	83 c1 01             	add    $0x1,%ecx
f0106433:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0106438:	b8 00 00 00 00       	mov    $0x0,%eax
f010643d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106440:	0f b6 11             	movzbl (%ecx),%edx
f0106443:	8d 72 d0             	lea    -0x30(%edx),%esi
f0106446:	89 f3                	mov    %esi,%ebx
f0106448:	80 fb 09             	cmp    $0x9,%bl
f010644b:	77 08                	ja     f0106455 <strtol+0x94>
			dig = *s - '0';
f010644d:	0f be d2             	movsbl %dl,%edx
f0106450:	83 ea 30             	sub    $0x30,%edx
f0106453:	eb 22                	jmp    f0106477 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f0106455:	8d 72 9f             	lea    -0x61(%edx),%esi
f0106458:	89 f3                	mov    %esi,%ebx
f010645a:	80 fb 19             	cmp    $0x19,%bl
f010645d:	77 08                	ja     f0106467 <strtol+0xa6>
			dig = *s - 'a' + 10;
f010645f:	0f be d2             	movsbl %dl,%edx
f0106462:	83 ea 57             	sub    $0x57,%edx
f0106465:	eb 10                	jmp    f0106477 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f0106467:	8d 72 bf             	lea    -0x41(%edx),%esi
f010646a:	89 f3                	mov    %esi,%ebx
f010646c:	80 fb 19             	cmp    $0x19,%bl
f010646f:	77 16                	ja     f0106487 <strtol+0xc6>
			dig = *s - 'A' + 10;
f0106471:	0f be d2             	movsbl %dl,%edx
f0106474:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0106477:	3b 55 10             	cmp    0x10(%ebp),%edx
f010647a:	7d 0b                	jge    f0106487 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f010647c:	83 c1 01             	add    $0x1,%ecx
f010647f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0106483:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0106485:	eb b9                	jmp    f0106440 <strtol+0x7f>

	if (endptr)
f0106487:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010648b:	74 0d                	je     f010649a <strtol+0xd9>
		*endptr = (char *) s;
f010648d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106490:	89 0e                	mov    %ecx,(%esi)
f0106492:	eb 06                	jmp    f010649a <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106494:	85 db                	test   %ebx,%ebx
f0106496:	74 98                	je     f0106430 <strtol+0x6f>
f0106498:	eb 9e                	jmp    f0106438 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010649a:	89 c2                	mov    %eax,%edx
f010649c:	f7 da                	neg    %edx
f010649e:	85 ff                	test   %edi,%edi
f01064a0:	0f 45 c2             	cmovne %edx,%eax
}
f01064a3:	5b                   	pop    %ebx
f01064a4:	5e                   	pop    %esi
f01064a5:	5f                   	pop    %edi
f01064a6:	5d                   	pop    %ebp
f01064a7:	c3                   	ret    

f01064a8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01064a8:	fa                   	cli    

	xorw    %ax, %ax
f01064a9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01064ab:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01064ad:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01064af:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01064b1:	0f 01 16             	lgdtl  (%esi)
f01064b4:	74 70                	je     f0106526 <mpsearch1+0x3>
	movl    %cr0, %eax
f01064b6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01064b9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01064bd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01064c0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01064c6:	08 00                	or     %al,(%eax)

f01064c8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01064c8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01064cc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01064ce:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01064d0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01064d2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01064d6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01064d8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01064da:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01064df:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01064e2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01064e5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01064ea:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f01064ed:	8b 25 a4 1e 24 f0    	mov    0xf0241ea4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01064f3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01064f8:	b8 fb 02 10 f0       	mov    $0xf01002fb,%eax
	call    *%eax
f01064fd:	ff d0                	call   *%eax

f01064ff <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01064ff:	eb fe                	jmp    f01064ff <spin>
f0106501:	8d 76 00             	lea    0x0(%esi),%esi

f0106504 <gdt>:
	...
f010650c:	ff                   	(bad)  
f010650d:	ff 00                	incl   (%eax)
f010650f:	00 00                	add    %al,(%eax)
f0106511:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106518:	00                   	.byte 0x0
f0106519:	92                   	xchg   %eax,%edx
f010651a:	cf                   	iret   
	...

f010651c <gdtdesc>:
f010651c:	17                   	pop    %ss
f010651d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106522 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106522:	90                   	nop

f0106523 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106523:	55                   	push   %ebp
f0106524:	89 e5                	mov    %esp,%ebp
f0106526:	57                   	push   %edi
f0106527:	56                   	push   %esi
f0106528:	53                   	push   %ebx
f0106529:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010652c:	8b 0d a8 1e 24 f0    	mov    0xf0241ea8,%ecx
f0106532:	89 c3                	mov    %eax,%ebx
f0106534:	c1 eb 0c             	shr    $0xc,%ebx
f0106537:	39 cb                	cmp    %ecx,%ebx
f0106539:	72 12                	jb     f010654d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010653b:	50                   	push   %eax
f010653c:	68 40 70 10 f0       	push   $0xf0107040
f0106541:	6a 57                	push   $0x57
f0106543:	68 01 8c 10 f0       	push   $0xf0108c01
f0106548:	e8 f3 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010654d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106553:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106555:	89 c2                	mov    %eax,%edx
f0106557:	c1 ea 0c             	shr    $0xc,%edx
f010655a:	39 ca                	cmp    %ecx,%edx
f010655c:	72 12                	jb     f0106570 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010655e:	50                   	push   %eax
f010655f:	68 40 70 10 f0       	push   $0xf0107040
f0106564:	6a 57                	push   $0x57
f0106566:	68 01 8c 10 f0       	push   $0xf0108c01
f010656b:	e8 d0 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106570:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0106576:	39 de                	cmp    %ebx,%esi
f0106578:	76 3f                	jbe    f01065b9 <mpsearch1+0x96>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010657a:	83 ec 04             	sub    $0x4,%esp
f010657d:	6a 04                	push   $0x4
f010657f:	68 11 8c 10 f0       	push   $0xf0108c11
f0106584:	53                   	push   %ebx
f0106585:	e8 a7 fd ff ff       	call   f0106331 <memcmp>
f010658a:	83 c4 10             	add    $0x10,%esp
f010658d:	85 c0                	test   %eax,%eax
f010658f:	75 1a                	jne    f01065ab <mpsearch1+0x88>
f0106591:	89 d8                	mov    %ebx,%eax
f0106593:	8d 7b 10             	lea    0x10(%ebx),%edi
f0106596:	ba 00 00 00 00       	mov    $0x0,%edx
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f010659b:	0f b6 08             	movzbl (%eax),%ecx
f010659e:	01 ca                	add    %ecx,%edx
f01065a0:	83 c0 01             	add    $0x1,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01065a3:	39 c7                	cmp    %eax,%edi
f01065a5:	75 f4                	jne    f010659b <mpsearch1+0x78>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01065a7:	84 d2                	test   %dl,%dl
f01065a9:	74 15                	je     f01065c0 <mpsearch1+0x9d>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01065ab:	83 c3 10             	add    $0x10,%ebx
f01065ae:	39 f3                	cmp    %esi,%ebx
f01065b0:	72 c8                	jb     f010657a <mpsearch1+0x57>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01065b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01065b7:	eb 09                	jmp    f01065c2 <mpsearch1+0x9f>
f01065b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01065be:	eb 02                	jmp    f01065c2 <mpsearch1+0x9f>
f01065c0:	89 d8                	mov    %ebx,%eax
}
f01065c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01065c5:	5b                   	pop    %ebx
f01065c6:	5e                   	pop    %esi
f01065c7:	5f                   	pop    %edi
f01065c8:	5d                   	pop    %ebp
f01065c9:	c3                   	ret    

f01065ca <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01065ca:	55                   	push   %ebp
f01065cb:	89 e5                	mov    %esp,%ebp
f01065cd:	57                   	push   %edi
f01065ce:	56                   	push   %esi
f01065cf:	53                   	push   %ebx
f01065d0:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01065d3:	c7 05 c0 23 24 f0 20 	movl   $0xf0242020,0xf02423c0
f01065da:	20 24 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01065dd:	83 3d a8 1e 24 f0 00 	cmpl   $0x0,0xf0241ea8
f01065e4:	75 16                	jne    f01065fc <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065e6:	68 00 04 00 00       	push   $0x400
f01065eb:	68 40 70 10 f0       	push   $0xf0107040
f01065f0:	6a 6f                	push   $0x6f
f01065f2:	68 01 8c 10 f0       	push   $0xf0108c01
f01065f7:	e8 44 9a ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01065fc:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106603:	85 c0                	test   %eax,%eax
f0106605:	74 16                	je     f010661d <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0106607:	c1 e0 04             	shl    $0x4,%eax
f010660a:	ba 00 04 00 00       	mov    $0x400,%edx
f010660f:	e8 0f ff ff ff       	call   f0106523 <mpsearch1>
f0106614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106617:	85 c0                	test   %eax,%eax
f0106619:	75 3c                	jne    f0106657 <mp_init+0x8d>
f010661b:	eb 20                	jmp    f010663d <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010661d:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106624:	c1 e0 0a             	shl    $0xa,%eax
f0106627:	2d 00 04 00 00       	sub    $0x400,%eax
f010662c:	ba 00 04 00 00       	mov    $0x400,%edx
f0106631:	e8 ed fe ff ff       	call   f0106523 <mpsearch1>
f0106636:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106639:	85 c0                	test   %eax,%eax
f010663b:	75 1a                	jne    f0106657 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010663d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106642:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106647:	e8 d7 fe ff ff       	call   f0106523 <mpsearch1>
f010664c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010664f:	85 c0                	test   %eax,%eax
f0106651:	0f 84 6c 02 00 00    	je     f01068c3 <mp_init+0x2f9>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010665a:	8b 70 04             	mov    0x4(%eax),%esi
f010665d:	85 f6                	test   %esi,%esi
f010665f:	74 06                	je     f0106667 <mp_init+0x9d>
f0106661:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106665:	74 15                	je     f010667c <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0106667:	83 ec 0c             	sub    $0xc,%esp
f010666a:	68 74 8a 10 f0       	push   $0xf0108a74
f010666f:	e8 1a d8 ff ff       	call   f0103e8e <cprintf>
f0106674:	83 c4 10             	add    $0x10,%esp
f0106677:	e9 47 02 00 00       	jmp    f01068c3 <mp_init+0x2f9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010667c:	89 f0                	mov    %esi,%eax
f010667e:	c1 e8 0c             	shr    $0xc,%eax
f0106681:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f0106687:	72 15                	jb     f010669e <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106689:	56                   	push   %esi
f010668a:	68 40 70 10 f0       	push   $0xf0107040
f010668f:	68 90 00 00 00       	push   $0x90
f0106694:	68 01 8c 10 f0       	push   $0xf0108c01
f0106699:	e8 a2 99 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010669e:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01066a4:	83 ec 04             	sub    $0x4,%esp
f01066a7:	6a 04                	push   $0x4
f01066a9:	68 16 8c 10 f0       	push   $0xf0108c16
f01066ae:	53                   	push   %ebx
f01066af:	e8 7d fc ff ff       	call   f0106331 <memcmp>
f01066b4:	83 c4 10             	add    $0x10,%esp
f01066b7:	85 c0                	test   %eax,%eax
f01066b9:	74 15                	je     f01066d0 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01066bb:	83 ec 0c             	sub    $0xc,%esp
f01066be:	68 a4 8a 10 f0       	push   $0xf0108aa4
f01066c3:	e8 c6 d7 ff ff       	call   f0103e8e <cprintf>
f01066c8:	83 c4 10             	add    $0x10,%esp
f01066cb:	e9 f3 01 00 00       	jmp    f01068c3 <mp_init+0x2f9>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01066d0:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01066d4:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01066d8:	0f b7 f8             	movzwl %ax,%edi
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01066db:	85 ff                	test   %edi,%edi
f01066dd:	7e 34                	jle    f0106713 <mp_init+0x149>
f01066df:	ba 00 00 00 00       	mov    $0x0,%edx
f01066e4:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01066e9:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01066f0:	f0 
f01066f1:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01066f3:	83 c0 01             	add    $0x1,%eax
f01066f6:	39 c7                	cmp    %eax,%edi
f01066f8:	75 ef                	jne    f01066e9 <mp_init+0x11f>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01066fa:	84 d2                	test   %dl,%dl
f01066fc:	74 15                	je     f0106713 <mp_init+0x149>
		cprintf("SMP: Bad MP configuration checksum\n");
f01066fe:	83 ec 0c             	sub    $0xc,%esp
f0106701:	68 d8 8a 10 f0       	push   $0xf0108ad8
f0106706:	e8 83 d7 ff ff       	call   f0103e8e <cprintf>
f010670b:	83 c4 10             	add    $0x10,%esp
f010670e:	e9 b0 01 00 00       	jmp    f01068c3 <mp_init+0x2f9>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106713:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106717:	3c 01                	cmp    $0x1,%al
f0106719:	74 1d                	je     f0106738 <mp_init+0x16e>
f010671b:	3c 04                	cmp    $0x4,%al
f010671d:	74 19                	je     f0106738 <mp_init+0x16e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010671f:	83 ec 08             	sub    $0x8,%esp
f0106722:	0f b6 c0             	movzbl %al,%eax
f0106725:	50                   	push   %eax
f0106726:	68 fc 8a 10 f0       	push   $0xf0108afc
f010672b:	e8 5e d7 ff ff       	call   f0103e8e <cprintf>
f0106730:	83 c4 10             	add    $0x10,%esp
f0106733:	e9 8b 01 00 00       	jmp    f01068c3 <mp_init+0x2f9>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106738:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f010673c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106740:	85 ff                	test   %edi,%edi
f0106742:	7e 1f                	jle    f0106763 <mp_init+0x199>
f0106744:	ba 00 00 00 00       	mov    $0x0,%edx
f0106749:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010674e:	01 ce                	add    %ecx,%esi
f0106750:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0106757:	f0 
f0106758:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010675a:	83 c0 01             	add    $0x1,%eax
f010675d:	39 c7                	cmp    %eax,%edi
f010675f:	75 ef                	jne    f0106750 <mp_init+0x186>
f0106761:	eb 05                	jmp    f0106768 <mp_init+0x19e>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106763:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106768:	38 53 2a             	cmp    %dl,0x2a(%ebx)
f010676b:	74 15                	je     f0106782 <mp_init+0x1b8>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010676d:	83 ec 0c             	sub    $0xc,%esp
f0106770:	68 1c 8b 10 f0       	push   $0xf0108b1c
f0106775:	e8 14 d7 ff ff       	call   f0103e8e <cprintf>
f010677a:	83 c4 10             	add    $0x10,%esp
f010677d:	e9 41 01 00 00       	jmp    f01068c3 <mp_init+0x2f9>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106782:	85 db                	test   %ebx,%ebx
f0106784:	0f 84 39 01 00 00    	je     f01068c3 <mp_init+0x2f9>
		return;
	ismp = 1;
f010678a:	c7 05 00 20 24 f0 01 	movl   $0x1,0xf0242000
f0106791:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0106794:	8b 43 24             	mov    0x24(%ebx),%eax
f0106797:	a3 00 30 28 f0       	mov    %eax,0xf0283000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010679c:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f010679f:	66 83 7b 22 00       	cmpw   $0x0,0x22(%ebx)
f01067a4:	0f 84 96 00 00 00    	je     f0106840 <mp_init+0x276>
f01067aa:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f01067af:	0f b6 07             	movzbl (%edi),%eax
f01067b2:	84 c0                	test   %al,%al
f01067b4:	74 06                	je     f01067bc <mp_init+0x1f2>
f01067b6:	3c 04                	cmp    $0x4,%al
f01067b8:	77 55                	ja     f010680f <mp_init+0x245>
f01067ba:	eb 4e                	jmp    f010680a <mp_init+0x240>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01067bc:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01067c0:	74 11                	je     f01067d3 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f01067c2:	6b 05 c4 23 24 f0 74 	imul   $0x74,0xf02423c4,%eax
f01067c9:	05 20 20 24 f0       	add    $0xf0242020,%eax
f01067ce:	a3 c0 23 24 f0       	mov    %eax,0xf02423c0
			if (ncpu < NCPU) {
f01067d3:	a1 c4 23 24 f0       	mov    0xf02423c4,%eax
f01067d8:	83 f8 07             	cmp    $0x7,%eax
f01067db:	7f 13                	jg     f01067f0 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f01067dd:	6b d0 74             	imul   $0x74,%eax,%edx
f01067e0:	88 82 20 20 24 f0    	mov    %al,-0xfdbdfe0(%edx)
				ncpu++;
f01067e6:	83 c0 01             	add    $0x1,%eax
f01067e9:	a3 c4 23 24 f0       	mov    %eax,0xf02423c4
f01067ee:	eb 15                	jmp    f0106805 <mp_init+0x23b>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01067f0:	83 ec 08             	sub    $0x8,%esp
f01067f3:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01067f7:	50                   	push   %eax
f01067f8:	68 4c 8b 10 f0       	push   $0xf0108b4c
f01067fd:	e8 8c d6 ff ff       	call   f0103e8e <cprintf>
f0106802:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106805:	83 c7 14             	add    $0x14,%edi
			continue;
f0106808:	eb 27                	jmp    f0106831 <mp_init+0x267>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010680a:	83 c7 08             	add    $0x8,%edi
			continue;
f010680d:	eb 22                	jmp    f0106831 <mp_init+0x267>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010680f:	83 ec 08             	sub    $0x8,%esp
f0106812:	0f b6 c0             	movzbl %al,%eax
f0106815:	50                   	push   %eax
f0106816:	68 74 8b 10 f0       	push   $0xf0108b74
f010681b:	e8 6e d6 ff ff       	call   f0103e8e <cprintf>
			ismp = 0;
f0106820:	c7 05 00 20 24 f0 00 	movl   $0x0,0xf0242000
f0106827:	00 00 00 
			i = conf->entry;
f010682a:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f010682e:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106831:	83 c6 01             	add    $0x1,%esi
f0106834:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106838:	39 f0                	cmp    %esi,%eax
f010683a:	0f 87 6f ff ff ff    	ja     f01067af <mp_init+0x1e5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106840:	a1 c0 23 24 f0       	mov    0xf02423c0,%eax
f0106845:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010684c:	83 3d 00 20 24 f0 00 	cmpl   $0x0,0xf0242000
f0106853:	75 26                	jne    f010687b <mp_init+0x2b1>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106855:	c7 05 c4 23 24 f0 01 	movl   $0x1,0xf02423c4
f010685c:	00 00 00 
		lapic = NULL;
f010685f:	c7 05 00 30 28 f0 00 	movl   $0x0,0xf0283000
f0106866:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106869:	83 ec 0c             	sub    $0xc,%esp
f010686c:	68 94 8b 10 f0       	push   $0xf0108b94
f0106871:	e8 18 d6 ff ff       	call   f0103e8e <cprintf>
		return;
f0106876:	83 c4 10             	add    $0x10,%esp
f0106879:	eb 48                	jmp    f01068c3 <mp_init+0x2f9>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010687b:	83 ec 04             	sub    $0x4,%esp
f010687e:	ff 35 c4 23 24 f0    	pushl  0xf02423c4
f0106884:	0f b6 00             	movzbl (%eax),%eax
f0106887:	50                   	push   %eax
f0106888:	68 1b 8c 10 f0       	push   $0xf0108c1b
f010688d:	e8 fc d5 ff ff       	call   f0103e8e <cprintf>

	if (mp->imcrp) {
f0106892:	83 c4 10             	add    $0x10,%esp
f0106895:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106898:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010689c:	74 25                	je     f01068c3 <mp_init+0x2f9>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010689e:	83 ec 0c             	sub    $0xc,%esp
f01068a1:	68 c0 8b 10 f0       	push   $0xf0108bc0
f01068a6:	e8 e3 d5 ff ff       	call   f0103e8e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01068ab:	ba 22 00 00 00       	mov    $0x22,%edx
f01068b0:	b8 70 00 00 00       	mov    $0x70,%eax
f01068b5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01068b6:	ba 23 00 00 00       	mov    $0x23,%edx
f01068bb:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01068bc:	83 c8 01             	or     $0x1,%eax
f01068bf:	ee                   	out    %al,(%dx)
f01068c0:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01068c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01068c6:	5b                   	pop    %ebx
f01068c7:	5e                   	pop    %esi
f01068c8:	5f                   	pop    %edi
f01068c9:	5d                   	pop    %ebp
f01068ca:	c3                   	ret    

f01068cb <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f01068cb:	55                   	push   %ebp
f01068cc:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01068ce:	8b 0d 00 30 28 f0    	mov    0xf0283000,%ecx
f01068d4:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01068d7:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01068d9:	a1 00 30 28 f0       	mov    0xf0283000,%eax
f01068de:	8b 40 20             	mov    0x20(%eax),%eax
}
f01068e1:	5d                   	pop    %ebp
f01068e2:	c3                   	ret    

f01068e3 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01068e3:	55                   	push   %ebp
f01068e4:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01068e6:	a1 00 30 28 f0       	mov    0xf0283000,%eax
f01068eb:	85 c0                	test   %eax,%eax
f01068ed:	74 08                	je     f01068f7 <cpunum+0x14>
		return lapic[ID] >> 24;
f01068ef:	8b 40 20             	mov    0x20(%eax),%eax
f01068f2:	c1 e8 18             	shr    $0x18,%eax
f01068f5:	eb 05                	jmp    f01068fc <cpunum+0x19>
	return 0;
f01068f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01068fc:	5d                   	pop    %ebp
f01068fd:	c3                   	ret    

f01068fe <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapic) 
f01068fe:	83 3d 00 30 28 f0 00 	cmpl   $0x0,0xf0283000
f0106905:	0f 84 0b 01 00 00    	je     f0106a16 <lapic_init+0x118>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010690b:	55                   	push   %ebp
f010690c:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010690e:	ba 27 01 00 00       	mov    $0x127,%edx
f0106913:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106918:	e8 ae ff ff ff       	call   f01068cb <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010691d:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106922:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106927:	e8 9f ff ff ff       	call   f01068cb <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010692c:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106931:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106936:	e8 90 ff ff ff       	call   f01068cb <lapicw>
	lapicw(TICR, 10000000); 
f010693b:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106940:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106945:	e8 81 ff ff ff       	call   f01068cb <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010694a:	e8 94 ff ff ff       	call   f01068e3 <cpunum>
f010694f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106952:	05 20 20 24 f0       	add    $0xf0242020,%eax
f0106957:	39 05 c0 23 24 f0    	cmp    %eax,0xf02423c0
f010695d:	74 0f                	je     f010696e <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f010695f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106964:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106969:	e8 5d ff ff ff       	call   f01068cb <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010696e:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106973:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106978:	e8 4e ff ff ff       	call   f01068cb <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010697d:	a1 00 30 28 f0       	mov    0xf0283000,%eax
f0106982:	8b 40 30             	mov    0x30(%eax),%eax
f0106985:	c1 e8 10             	shr    $0x10,%eax
f0106988:	3c 03                	cmp    $0x3,%al
f010698a:	76 0f                	jbe    f010699b <lapic_init+0x9d>
		lapicw(PCINT, MASKED);
f010698c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106991:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106996:	e8 30 ff ff ff       	call   f01068cb <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010699b:	ba 33 00 00 00       	mov    $0x33,%edx
f01069a0:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01069a5:	e8 21 ff ff ff       	call   f01068cb <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01069aa:	ba 00 00 00 00       	mov    $0x0,%edx
f01069af:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01069b4:	e8 12 ff ff ff       	call   f01068cb <lapicw>
	lapicw(ESR, 0);
f01069b9:	ba 00 00 00 00       	mov    $0x0,%edx
f01069be:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01069c3:	e8 03 ff ff ff       	call   f01068cb <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01069c8:	ba 00 00 00 00       	mov    $0x0,%edx
f01069cd:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01069d2:	e8 f4 fe ff ff       	call   f01068cb <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01069d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01069dc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01069e1:	e8 e5 fe ff ff       	call   f01068cb <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01069e6:	ba 00 85 08 00       	mov    $0x88500,%edx
f01069eb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069f0:	e8 d6 fe ff ff       	call   f01068cb <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01069f5:	8b 15 00 30 28 f0    	mov    0xf0283000,%edx
f01069fb:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106a01:	f6 c4 10             	test   $0x10,%ah
f0106a04:	75 f5                	jne    f01069fb <lapic_init+0xfd>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106a06:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a0b:	b8 20 00 00 00       	mov    $0x20,%eax
f0106a10:	e8 b6 fe ff ff       	call   f01068cb <lapicw>
}
f0106a15:	5d                   	pop    %ebp
f0106a16:	f3 c3                	repz ret 

f0106a18 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106a18:	83 3d 00 30 28 f0 00 	cmpl   $0x0,0xf0283000
f0106a1f:	74 13                	je     f0106a34 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106a21:	55                   	push   %ebp
f0106a22:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106a24:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a29:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106a2e:	e8 98 fe ff ff       	call   f01068cb <lapicw>
}
f0106a33:	5d                   	pop    %ebp
f0106a34:	f3 c3                	repz ret 

f0106a36 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106a36:	55                   	push   %ebp
f0106a37:	89 e5                	mov    %esp,%ebp
f0106a39:	56                   	push   %esi
f0106a3a:	53                   	push   %ebx
f0106a3b:	8b 75 08             	mov    0x8(%ebp),%esi
f0106a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106a41:	ba 70 00 00 00       	mov    $0x70,%edx
f0106a46:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106a4b:	ee                   	out    %al,(%dx)
f0106a4c:	ba 71 00 00 00       	mov    $0x71,%edx
f0106a51:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106a56:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106a57:	83 3d a8 1e 24 f0 00 	cmpl   $0x0,0xf0241ea8
f0106a5e:	75 19                	jne    f0106a79 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106a60:	68 67 04 00 00       	push   $0x467
f0106a65:	68 40 70 10 f0       	push   $0xf0107040
f0106a6a:	68 93 00 00 00       	push   $0x93
f0106a6f:	68 38 8c 10 f0       	push   $0xf0108c38
f0106a74:	e8 c7 95 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106a79:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106a80:	00 00 
	wrv[1] = addr >> 4;
f0106a82:	89 d8                	mov    %ebx,%eax
f0106a84:	c1 e8 04             	shr    $0x4,%eax
f0106a87:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106a8d:	c1 e6 18             	shl    $0x18,%esi
f0106a90:	89 f2                	mov    %esi,%edx
f0106a92:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106a97:	e8 2f fe ff ff       	call   f01068cb <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106a9c:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106aa1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106aa6:	e8 20 fe ff ff       	call   f01068cb <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106aab:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106ab0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ab5:	e8 11 fe ff ff       	call   f01068cb <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106aba:	c1 eb 0c             	shr    $0xc,%ebx
f0106abd:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106ac0:	89 f2                	mov    %esi,%edx
f0106ac2:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106ac7:	e8 ff fd ff ff       	call   f01068cb <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106acc:	89 da                	mov    %ebx,%edx
f0106ace:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ad3:	e8 f3 fd ff ff       	call   f01068cb <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106ad8:	89 f2                	mov    %esi,%edx
f0106ada:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106adf:	e8 e7 fd ff ff       	call   f01068cb <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ae4:	89 da                	mov    %ebx,%edx
f0106ae6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106aeb:	e8 db fd ff ff       	call   f01068cb <lapicw>
		microdelay(200);
	}
}
f0106af0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106af3:	5b                   	pop    %ebx
f0106af4:	5e                   	pop    %esi
f0106af5:	5d                   	pop    %ebp
f0106af6:	c3                   	ret    

f0106af7 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106af7:	55                   	push   %ebp
f0106af8:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106afa:	8b 55 08             	mov    0x8(%ebp),%edx
f0106afd:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106b03:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106b08:	e8 be fd ff ff       	call   f01068cb <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106b0d:	8b 15 00 30 28 f0    	mov    0xf0283000,%edx
f0106b13:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106b19:	f6 c4 10             	test   $0x10,%ah
f0106b1c:	75 f5                	jne    f0106b13 <lapic_ipi+0x1c>
		;
}
f0106b1e:	5d                   	pop    %ebp
f0106b1f:	c3                   	ret    

f0106b20 <atomic_return_and_add>:
// This is the atomic instruction that
// reading the old value as well as doing the add operation.
// If your gcc cannot support this function, report to TA.
#ifdef USE_TICKET_SPIN_LOCK
unsigned atomic_return_and_add(volatile unsigned *addr, unsigned value)
{
f0106b20:	55                   	push   %ebp
f0106b21:	89 e5                	mov    %esp,%ebp
f0106b23:	8b 55 08             	mov    0x8(%ebp),%edx
	return __sync_fetch_and_add(addr, value);
f0106b26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b29:	f0 0f c1 02          	lock xadd %eax,(%edx)
}
f0106b2d:	5d                   	pop    %ebp
f0106b2e:	c3                   	ret    

f0106b2f <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106b2f:	55                   	push   %ebp
f0106b30:	89 e5                	mov    %esp,%ebp
f0106b32:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
#else
	//LAB 4: Your code here
	lk->own = 0;
f0106b35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lk->next = 0;
f0106b3b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106b42:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b45:	89 50 08             	mov    %edx,0x8(%eax)
	lk->cpu = 0;
f0106b48:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#endif
}
f0106b4f:	5d                   	pop    %ebp
f0106b50:	c3                   	ret    

f0106b51 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106b51:	55                   	push   %ebp
f0106b52:	89 e5                	mov    %esp,%ebp
f0106b54:	56                   	push   %esi
f0106b55:	53                   	push   %ebx
f0106b56:	8b 5d 08             	mov    0x8(%ebp),%ebx
{
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
#else
	//LAB 4: Your code here
	return lock->own != lock->next && lock->cpu == thiscpu;
f0106b59:	8b 13                	mov    (%ebx),%edx
f0106b5b:	8b 43 04             	mov    0x4(%ebx),%eax
f0106b5e:	39 c2                	cmp    %eax,%edx
f0106b60:	74 32                	je     f0106b94 <spin_lock+0x43>
f0106b62:	8b 73 0c             	mov    0xc(%ebx),%esi
f0106b65:	e8 79 fd ff ff       	call   f01068e3 <cpunum>
f0106b6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0106b6d:	05 20 20 24 f0       	add    $0xf0242020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106b72:	39 c6                	cmp    %eax,%esi
f0106b74:	75 1e                	jne    f0106b94 <spin_lock+0x43>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106b76:	8b 5b 08             	mov    0x8(%ebx),%ebx
f0106b79:	e8 65 fd ff ff       	call   f01068e3 <cpunum>
f0106b7e:	83 ec 0c             	sub    $0xc,%esp
f0106b81:	53                   	push   %ebx
f0106b82:	50                   	push   %eax
f0106b83:	68 48 8c 10 f0       	push   $0xf0108c48
f0106b88:	6a 5b                	push   $0x5b
f0106b8a:	68 ac 8c 10 f0       	push   $0xf0108cac
f0106b8f:	e8 ac 94 ff ff       	call   f0100040 <_panic>
	// reordered before it.
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
#else
	//LAB 4: Your code here
	unsigned ticket = atomic_return_and_add(&(lk->next), 1);
f0106b94:	83 ec 08             	sub    $0x8,%esp
f0106b97:	6a 01                	push   $0x1
f0106b99:	8d 43 04             	lea    0x4(%ebx),%eax
f0106b9c:	50                   	push   %eax
f0106b9d:	e8 7e ff ff ff       	call   f0106b20 <atomic_return_and_add>
	while (ticket != lk->own)
f0106ba2:	8b 13                	mov    (%ebx),%edx
f0106ba4:	83 c4 10             	add    $0x10,%esp
f0106ba7:	39 d0                	cmp    %edx,%eax
f0106ba9:	74 08                	je     f0106bb3 <spin_lock+0x62>
		asm volatile ("pause");
f0106bab:	f3 90                	pause  
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
#else
	//LAB 4: Your code here
	unsigned ticket = atomic_return_and_add(&(lk->next), 1);
	while (ticket != lk->own)
f0106bad:	8b 13                	mov    (%ebx),%edx
f0106baf:	39 d0                	cmp    %edx,%eax
f0106bb1:	75 f8                	jne    f0106bab <spin_lock+0x5a>

#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106bb3:	e8 2b fd ff ff       	call   f01068e3 <cpunum>
f0106bb8:	6b c0 74             	imul   $0x74,%eax,%eax
f0106bbb:	05 20 20 24 f0       	add    $0xf0242020,%eax
f0106bc0:	89 43 0c             	mov    %eax,0xc(%ebx)
	get_caller_pcs(lk->pcs);
f0106bc3:	8d 4b 10             	lea    0x10(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106bc6:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0106bc8:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f0106bce:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0106bd4:	76 3a                	jbe    f0106c10 <spin_lock+0xbf>
f0106bd6:	eb 31                	jmp    f0106c09 <spin_lock+0xb8>
f0106bd8:	8d 9a 00 00 80 10    	lea    0x10800000(%edx),%ebx
f0106bde:	81 fb ff ff 7f 0e    	cmp    $0xe7fffff,%ebx
f0106be4:	77 12                	ja     f0106bf8 <spin_lock+0xa7>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106be6:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106be9:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106bec:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106bee:	83 c0 01             	add    $0x1,%eax
f0106bf1:	83 f8 0a             	cmp    $0xa,%eax
f0106bf4:	75 e2                	jne    f0106bd8 <spin_lock+0x87>
f0106bf6:	eb 27                	jmp    f0106c1f <spin_lock+0xce>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106bf8:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106bff:	83 c0 01             	add    $0x1,%eax
f0106c02:	83 f8 09             	cmp    $0x9,%eax
f0106c05:	7e f1                	jle    f0106bf8 <spin_lock+0xa7>
f0106c07:	eb 16                	jmp    f0106c1f <spin_lock+0xce>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106c09:	b8 00 00 00 00       	mov    $0x0,%eax
f0106c0e:	eb e8                	jmp    f0106bf8 <spin_lock+0xa7>
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106c10:	8b 50 04             	mov    0x4(%eax),%edx
f0106c13:	89 53 10             	mov    %edx,0x10(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106c16:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106c18:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c1d:	eb b9                	jmp    f0106bd8 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106c1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106c22:	5b                   	pop    %ebx
f0106c23:	5e                   	pop    %esi
f0106c24:	5d                   	pop    %ebp
f0106c25:	c3                   	ret    

f0106c26 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106c26:	55                   	push   %ebp
f0106c27:	89 e5                	mov    %esp,%ebp
f0106c29:	57                   	push   %edi
f0106c2a:	56                   	push   %esi
f0106c2b:	53                   	push   %ebx
f0106c2c:	83 ec 4c             	sub    $0x4c,%esp
f0106c2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
{
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
#else
	//LAB 4: Your code here
	return lock->own != lock->next && lock->cpu == thiscpu;
f0106c32:	8b 13                	mov    (%ebx),%edx
f0106c34:	8b 43 04             	mov    0x4(%ebx),%eax
f0106c37:	39 c2                	cmp    %eax,%edx
f0106c39:	74 18                	je     f0106c53 <spin_unlock+0x2d>
f0106c3b:	8b 73 0c             	mov    0xc(%ebx),%esi
f0106c3e:	e8 a0 fc ff ff       	call   f01068e3 <cpunum>
f0106c43:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c46:	05 20 20 24 f0       	add    $0xf0242020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106c4b:	39 c6                	cmp    %eax,%esi
f0106c4d:	0f 84 ae 00 00 00    	je     f0106d01 <spin_unlock+0xdb>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106c53:	83 ec 04             	sub    $0x4,%esp
f0106c56:	6a 28                	push   $0x28
f0106c58:	8d 43 10             	lea    0x10(%ebx),%eax
f0106c5b:	50                   	push   %eax
f0106c5c:	8d 45 c0             	lea    -0x40(%ebp),%eax
f0106c5f:	50                   	push   %eax
f0106c60:	e8 51 f6 ff ff       	call   f01062b6 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106c65:	8b 43 0c             	mov    0xc(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
f0106c68:	0f b6 30             	movzbl (%eax),%esi
f0106c6b:	8b 5b 08             	mov    0x8(%ebx),%ebx
f0106c6e:	e8 70 fc ff ff       	call   f01068e3 <cpunum>
f0106c73:	56                   	push   %esi
f0106c74:	53                   	push   %ebx
f0106c75:	50                   	push   %eax
f0106c76:	68 74 8c 10 f0       	push   $0xf0108c74
f0106c7b:	e8 0e d2 ff ff       	call   f0103e8e <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106c80:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0106c83:	83 c4 20             	add    $0x20,%esp
f0106c86:	85 c0                	test   %eax,%eax
f0106c88:	74 60                	je     f0106cea <spin_unlock+0xc4>
f0106c8a:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106c8d:	8d 7d e4             	lea    -0x1c(%ebp),%edi
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106c90:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106c93:	83 ec 08             	sub    $0x8,%esp
f0106c96:	56                   	push   %esi
f0106c97:	50                   	push   %eax
f0106c98:	e8 2a e8 ff ff       	call   f01054c7 <debuginfo_eip>
f0106c9d:	83 c4 10             	add    $0x10,%esp
f0106ca0:	85 c0                	test   %eax,%eax
f0106ca2:	78 27                	js     f0106ccb <spin_unlock+0xa5>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106ca4:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106ca6:	83 ec 04             	sub    $0x4,%esp
f0106ca9:	89 c2                	mov    %eax,%edx
f0106cab:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106cae:	52                   	push   %edx
f0106caf:	ff 75 b0             	pushl  -0x50(%ebp)
f0106cb2:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106cb5:	ff 75 ac             	pushl  -0x54(%ebp)
f0106cb8:	ff 75 a8             	pushl  -0x58(%ebp)
f0106cbb:	50                   	push   %eax
f0106cbc:	68 bc 8c 10 f0       	push   $0xf0108cbc
f0106cc1:	e8 c8 d1 ff ff       	call   f0103e8e <cprintf>
f0106cc6:	83 c4 20             	add    $0x20,%esp
f0106cc9:	eb 12                	jmp    f0106cdd <spin_unlock+0xb7>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106ccb:	83 ec 08             	sub    $0x8,%esp
f0106cce:	ff 33                	pushl  (%ebx)
f0106cd0:	68 d3 8c 10 f0       	push   $0xf0108cd3
f0106cd5:	e8 b4 d1 ff ff       	call   f0103e8e <cprintf>
f0106cda:	83 c4 10             	add    $0x10,%esp
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106cdd:	39 fb                	cmp    %edi,%ebx
f0106cdf:	74 09                	je     f0106cea <spin_unlock+0xc4>
f0106ce1:	83 c3 04             	add    $0x4,%ebx
f0106ce4:	8b 03                	mov    (%ebx),%eax
f0106ce6:	85 c0                	test   %eax,%eax
f0106ce8:	75 a9                	jne    f0106c93 <spin_unlock+0x6d>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106cea:	83 ec 04             	sub    $0x4,%esp
f0106ced:	68 db 8c 10 f0       	push   $0xf0108cdb
f0106cf2:	68 89 00 00 00       	push   $0x89
f0106cf7:	68 ac 8c 10 f0       	push   $0xf0108cac
f0106cfc:	e8 3f 93 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106d01:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
	lk->cpu = 0;
f0106d08:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
#else
	//LAB 4: Your code here
	atomic_return_and_add(&(lk->own), 1);
f0106d0f:	83 ec 08             	sub    $0x8,%esp
f0106d12:	6a 01                	push   $0x1
f0106d14:	53                   	push   %ebx
f0106d15:	e8 06 fe ff ff       	call   f0106b20 <atomic_return_and_add>
#endif
}
f0106d1a:	83 c4 10             	add    $0x10,%esp
f0106d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106d20:	5b                   	pop    %ebx
f0106d21:	5e                   	pop    %esi
f0106d22:	5f                   	pop    %edi
f0106d23:	5d                   	pop    %ebp
f0106d24:	c3                   	ret    
f0106d25:	66 90                	xchg   %ax,%ax
f0106d27:	66 90                	xchg   %ax,%ax
f0106d29:	66 90                	xchg   %ax,%ax
f0106d2b:	66 90                	xchg   %ax,%ax
f0106d2d:	66 90                	xchg   %ax,%ax
f0106d2f:	90                   	nop

f0106d30 <__udivdi3>:
f0106d30:	55                   	push   %ebp
f0106d31:	57                   	push   %edi
f0106d32:	56                   	push   %esi
f0106d33:	53                   	push   %ebx
f0106d34:	83 ec 1c             	sub    $0x1c,%esp
f0106d37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0106d3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0106d3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106d47:	85 f6                	test   %esi,%esi
f0106d49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106d4d:	89 ca                	mov    %ecx,%edx
f0106d4f:	89 f8                	mov    %edi,%eax
f0106d51:	75 3d                	jne    f0106d90 <__udivdi3+0x60>
f0106d53:	39 cf                	cmp    %ecx,%edi
f0106d55:	0f 87 c5 00 00 00    	ja     f0106e20 <__udivdi3+0xf0>
f0106d5b:	85 ff                	test   %edi,%edi
f0106d5d:	89 fd                	mov    %edi,%ebp
f0106d5f:	75 0b                	jne    f0106d6c <__udivdi3+0x3c>
f0106d61:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d66:	31 d2                	xor    %edx,%edx
f0106d68:	f7 f7                	div    %edi
f0106d6a:	89 c5                	mov    %eax,%ebp
f0106d6c:	89 c8                	mov    %ecx,%eax
f0106d6e:	31 d2                	xor    %edx,%edx
f0106d70:	f7 f5                	div    %ebp
f0106d72:	89 c1                	mov    %eax,%ecx
f0106d74:	89 d8                	mov    %ebx,%eax
f0106d76:	89 cf                	mov    %ecx,%edi
f0106d78:	f7 f5                	div    %ebp
f0106d7a:	89 c3                	mov    %eax,%ebx
f0106d7c:	89 d8                	mov    %ebx,%eax
f0106d7e:	89 fa                	mov    %edi,%edx
f0106d80:	83 c4 1c             	add    $0x1c,%esp
f0106d83:	5b                   	pop    %ebx
f0106d84:	5e                   	pop    %esi
f0106d85:	5f                   	pop    %edi
f0106d86:	5d                   	pop    %ebp
f0106d87:	c3                   	ret    
f0106d88:	90                   	nop
f0106d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106d90:	39 ce                	cmp    %ecx,%esi
f0106d92:	77 74                	ja     f0106e08 <__udivdi3+0xd8>
f0106d94:	0f bd fe             	bsr    %esi,%edi
f0106d97:	83 f7 1f             	xor    $0x1f,%edi
f0106d9a:	0f 84 98 00 00 00    	je     f0106e38 <__udivdi3+0x108>
f0106da0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106da5:	89 f9                	mov    %edi,%ecx
f0106da7:	89 c5                	mov    %eax,%ebp
f0106da9:	29 fb                	sub    %edi,%ebx
f0106dab:	d3 e6                	shl    %cl,%esi
f0106dad:	89 d9                	mov    %ebx,%ecx
f0106daf:	d3 ed                	shr    %cl,%ebp
f0106db1:	89 f9                	mov    %edi,%ecx
f0106db3:	d3 e0                	shl    %cl,%eax
f0106db5:	09 ee                	or     %ebp,%esi
f0106db7:	89 d9                	mov    %ebx,%ecx
f0106db9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106dbd:	89 d5                	mov    %edx,%ebp
f0106dbf:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106dc3:	d3 ed                	shr    %cl,%ebp
f0106dc5:	89 f9                	mov    %edi,%ecx
f0106dc7:	d3 e2                	shl    %cl,%edx
f0106dc9:	89 d9                	mov    %ebx,%ecx
f0106dcb:	d3 e8                	shr    %cl,%eax
f0106dcd:	09 c2                	or     %eax,%edx
f0106dcf:	89 d0                	mov    %edx,%eax
f0106dd1:	89 ea                	mov    %ebp,%edx
f0106dd3:	f7 f6                	div    %esi
f0106dd5:	89 d5                	mov    %edx,%ebp
f0106dd7:	89 c3                	mov    %eax,%ebx
f0106dd9:	f7 64 24 0c          	mull   0xc(%esp)
f0106ddd:	39 d5                	cmp    %edx,%ebp
f0106ddf:	72 10                	jb     f0106df1 <__udivdi3+0xc1>
f0106de1:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106de5:	89 f9                	mov    %edi,%ecx
f0106de7:	d3 e6                	shl    %cl,%esi
f0106de9:	39 c6                	cmp    %eax,%esi
f0106deb:	73 07                	jae    f0106df4 <__udivdi3+0xc4>
f0106ded:	39 d5                	cmp    %edx,%ebp
f0106def:	75 03                	jne    f0106df4 <__udivdi3+0xc4>
f0106df1:	83 eb 01             	sub    $0x1,%ebx
f0106df4:	31 ff                	xor    %edi,%edi
f0106df6:	89 d8                	mov    %ebx,%eax
f0106df8:	89 fa                	mov    %edi,%edx
f0106dfa:	83 c4 1c             	add    $0x1c,%esp
f0106dfd:	5b                   	pop    %ebx
f0106dfe:	5e                   	pop    %esi
f0106dff:	5f                   	pop    %edi
f0106e00:	5d                   	pop    %ebp
f0106e01:	c3                   	ret    
f0106e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106e08:	31 ff                	xor    %edi,%edi
f0106e0a:	31 db                	xor    %ebx,%ebx
f0106e0c:	89 d8                	mov    %ebx,%eax
f0106e0e:	89 fa                	mov    %edi,%edx
f0106e10:	83 c4 1c             	add    $0x1c,%esp
f0106e13:	5b                   	pop    %ebx
f0106e14:	5e                   	pop    %esi
f0106e15:	5f                   	pop    %edi
f0106e16:	5d                   	pop    %ebp
f0106e17:	c3                   	ret    
f0106e18:	90                   	nop
f0106e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106e20:	89 d8                	mov    %ebx,%eax
f0106e22:	f7 f7                	div    %edi
f0106e24:	31 ff                	xor    %edi,%edi
f0106e26:	89 c3                	mov    %eax,%ebx
f0106e28:	89 d8                	mov    %ebx,%eax
f0106e2a:	89 fa                	mov    %edi,%edx
f0106e2c:	83 c4 1c             	add    $0x1c,%esp
f0106e2f:	5b                   	pop    %ebx
f0106e30:	5e                   	pop    %esi
f0106e31:	5f                   	pop    %edi
f0106e32:	5d                   	pop    %ebp
f0106e33:	c3                   	ret    
f0106e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106e38:	39 ce                	cmp    %ecx,%esi
f0106e3a:	72 0c                	jb     f0106e48 <__udivdi3+0x118>
f0106e3c:	31 db                	xor    %ebx,%ebx
f0106e3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106e42:	0f 87 34 ff ff ff    	ja     f0106d7c <__udivdi3+0x4c>
f0106e48:	bb 01 00 00 00       	mov    $0x1,%ebx
f0106e4d:	e9 2a ff ff ff       	jmp    f0106d7c <__udivdi3+0x4c>
f0106e52:	66 90                	xchg   %ax,%ax
f0106e54:	66 90                	xchg   %ax,%ax
f0106e56:	66 90                	xchg   %ax,%ax
f0106e58:	66 90                	xchg   %ax,%ax
f0106e5a:	66 90                	xchg   %ax,%ax
f0106e5c:	66 90                	xchg   %ax,%ax
f0106e5e:	66 90                	xchg   %ax,%ax

f0106e60 <__umoddi3>:
f0106e60:	55                   	push   %ebp
f0106e61:	57                   	push   %edi
f0106e62:	56                   	push   %esi
f0106e63:	53                   	push   %ebx
f0106e64:	83 ec 1c             	sub    $0x1c,%esp
f0106e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106e6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106e77:	85 d2                	test   %edx,%edx
f0106e79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106e81:	89 f3                	mov    %esi,%ebx
f0106e83:	89 3c 24             	mov    %edi,(%esp)
f0106e86:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106e8a:	75 1c                	jne    f0106ea8 <__umoddi3+0x48>
f0106e8c:	39 f7                	cmp    %esi,%edi
f0106e8e:	76 50                	jbe    f0106ee0 <__umoddi3+0x80>
f0106e90:	89 c8                	mov    %ecx,%eax
f0106e92:	89 f2                	mov    %esi,%edx
f0106e94:	f7 f7                	div    %edi
f0106e96:	89 d0                	mov    %edx,%eax
f0106e98:	31 d2                	xor    %edx,%edx
f0106e9a:	83 c4 1c             	add    $0x1c,%esp
f0106e9d:	5b                   	pop    %ebx
f0106e9e:	5e                   	pop    %esi
f0106e9f:	5f                   	pop    %edi
f0106ea0:	5d                   	pop    %ebp
f0106ea1:	c3                   	ret    
f0106ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106ea8:	39 f2                	cmp    %esi,%edx
f0106eaa:	89 d0                	mov    %edx,%eax
f0106eac:	77 52                	ja     f0106f00 <__umoddi3+0xa0>
f0106eae:	0f bd ea             	bsr    %edx,%ebp
f0106eb1:	83 f5 1f             	xor    $0x1f,%ebp
f0106eb4:	75 5a                	jne    f0106f10 <__umoddi3+0xb0>
f0106eb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0106eba:	0f 82 e0 00 00 00    	jb     f0106fa0 <__umoddi3+0x140>
f0106ec0:	39 0c 24             	cmp    %ecx,(%esp)
f0106ec3:	0f 86 d7 00 00 00    	jbe    f0106fa0 <__umoddi3+0x140>
f0106ec9:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106ecd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106ed1:	83 c4 1c             	add    $0x1c,%esp
f0106ed4:	5b                   	pop    %ebx
f0106ed5:	5e                   	pop    %esi
f0106ed6:	5f                   	pop    %edi
f0106ed7:	5d                   	pop    %ebp
f0106ed8:	c3                   	ret    
f0106ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106ee0:	85 ff                	test   %edi,%edi
f0106ee2:	89 fd                	mov    %edi,%ebp
f0106ee4:	75 0b                	jne    f0106ef1 <__umoddi3+0x91>
f0106ee6:	b8 01 00 00 00       	mov    $0x1,%eax
f0106eeb:	31 d2                	xor    %edx,%edx
f0106eed:	f7 f7                	div    %edi
f0106eef:	89 c5                	mov    %eax,%ebp
f0106ef1:	89 f0                	mov    %esi,%eax
f0106ef3:	31 d2                	xor    %edx,%edx
f0106ef5:	f7 f5                	div    %ebp
f0106ef7:	89 c8                	mov    %ecx,%eax
f0106ef9:	f7 f5                	div    %ebp
f0106efb:	89 d0                	mov    %edx,%eax
f0106efd:	eb 99                	jmp    f0106e98 <__umoddi3+0x38>
f0106eff:	90                   	nop
f0106f00:	89 c8                	mov    %ecx,%eax
f0106f02:	89 f2                	mov    %esi,%edx
f0106f04:	83 c4 1c             	add    $0x1c,%esp
f0106f07:	5b                   	pop    %ebx
f0106f08:	5e                   	pop    %esi
f0106f09:	5f                   	pop    %edi
f0106f0a:	5d                   	pop    %ebp
f0106f0b:	c3                   	ret    
f0106f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106f10:	8b 34 24             	mov    (%esp),%esi
f0106f13:	bf 20 00 00 00       	mov    $0x20,%edi
f0106f18:	89 e9                	mov    %ebp,%ecx
f0106f1a:	29 ef                	sub    %ebp,%edi
f0106f1c:	d3 e0                	shl    %cl,%eax
f0106f1e:	89 f9                	mov    %edi,%ecx
f0106f20:	89 f2                	mov    %esi,%edx
f0106f22:	d3 ea                	shr    %cl,%edx
f0106f24:	89 e9                	mov    %ebp,%ecx
f0106f26:	09 c2                	or     %eax,%edx
f0106f28:	89 d8                	mov    %ebx,%eax
f0106f2a:	89 14 24             	mov    %edx,(%esp)
f0106f2d:	89 f2                	mov    %esi,%edx
f0106f2f:	d3 e2                	shl    %cl,%edx
f0106f31:	89 f9                	mov    %edi,%ecx
f0106f33:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106f37:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106f3b:	d3 e8                	shr    %cl,%eax
f0106f3d:	89 e9                	mov    %ebp,%ecx
f0106f3f:	89 c6                	mov    %eax,%esi
f0106f41:	d3 e3                	shl    %cl,%ebx
f0106f43:	89 f9                	mov    %edi,%ecx
f0106f45:	89 d0                	mov    %edx,%eax
f0106f47:	d3 e8                	shr    %cl,%eax
f0106f49:	89 e9                	mov    %ebp,%ecx
f0106f4b:	09 d8                	or     %ebx,%eax
f0106f4d:	89 d3                	mov    %edx,%ebx
f0106f4f:	89 f2                	mov    %esi,%edx
f0106f51:	f7 34 24             	divl   (%esp)
f0106f54:	89 d6                	mov    %edx,%esi
f0106f56:	d3 e3                	shl    %cl,%ebx
f0106f58:	f7 64 24 04          	mull   0x4(%esp)
f0106f5c:	39 d6                	cmp    %edx,%esi
f0106f5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106f62:	89 d1                	mov    %edx,%ecx
f0106f64:	89 c3                	mov    %eax,%ebx
f0106f66:	72 08                	jb     f0106f70 <__umoddi3+0x110>
f0106f68:	75 11                	jne    f0106f7b <__umoddi3+0x11b>
f0106f6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106f6e:	73 0b                	jae    f0106f7b <__umoddi3+0x11b>
f0106f70:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106f74:	1b 14 24             	sbb    (%esp),%edx
f0106f77:	89 d1                	mov    %edx,%ecx
f0106f79:	89 c3                	mov    %eax,%ebx
f0106f7b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106f7f:	29 da                	sub    %ebx,%edx
f0106f81:	19 ce                	sbb    %ecx,%esi
f0106f83:	89 f9                	mov    %edi,%ecx
f0106f85:	89 f0                	mov    %esi,%eax
f0106f87:	d3 e0                	shl    %cl,%eax
f0106f89:	89 e9                	mov    %ebp,%ecx
f0106f8b:	d3 ea                	shr    %cl,%edx
f0106f8d:	89 e9                	mov    %ebp,%ecx
f0106f8f:	d3 ee                	shr    %cl,%esi
f0106f91:	09 d0                	or     %edx,%eax
f0106f93:	89 f2                	mov    %esi,%edx
f0106f95:	83 c4 1c             	add    $0x1c,%esp
f0106f98:	5b                   	pop    %ebx
f0106f99:	5e                   	pop    %esi
f0106f9a:	5f                   	pop    %edi
f0106f9b:	5d                   	pop    %ebp
f0106f9c:	c3                   	ret    
f0106f9d:	8d 76 00             	lea    0x0(%esi),%esi
f0106fa0:	29 f9                	sub    %edi,%ecx
f0106fa2:	19 d6                	sbb    %edx,%esi
f0106fa4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106fa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106fac:	e9 18 ff ff ff       	jmp    f0106ec9 <__umoddi3+0x69>
