
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
f010005c:	e8 ce 64 00 00       	call   f010652f <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 6c 10 f0       	push   $0xf0106c20
f010006d:	e8 00 3e 00 00       	call   f0103e72 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 d0 3d 00 00       	call   f0103e4c <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 16 70 10 f0 	movl   $0xf0107016,(%esp)
f0100083:	e8 ea 3d 00 00       	call   f0103e72 <cprintf>
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
f01000a9:	e8 81 64 00 00       	call   f010652f <cpunum>
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
f01000ea:	e8 ae 66 00 00       	call   f010679d <spin_lock>
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
f0100113:	68 44 6c 10 f0       	push   $0xf0106c44
f0100118:	6a 25                	push   $0x25
f010011a:	68 e8 6c 10 f0       	push   $0xf0106ce8
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
f0100160:	e8 0d 67 00 00       	call   f0106872 <spin_unlock>

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
f010017b:	e8 1d 66 00 00       	call   f010679d <spin_lock>
			test_ctr++;
		unlock_kernel();
	}

	lock_kernel();
	cprintf("spinlock_test() succeeded on CPU %d!\n", cpunum());
f0100180:	e8 aa 63 00 00       	call   f010652f <cpunum>
f0100185:	83 c4 08             	add    $0x8,%esp
f0100188:	50                   	push   %eax
f0100189:	68 78 6c 10 f0       	push   $0xf0106c78
f010018e:	e8 df 3c 00 00       	call   f0103e72 <cprintf>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0100193:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f010019a:	e8 d3 66 00 00       	call   f0106872 <spin_unlock>

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
f01001c4:	e8 eb 5c 00 00       	call   f0105eb4 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001c9:	e8 c3 05 00 00       	call   f0100791 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01001ce:	83 c4 08             	add    $0x8,%esp
f01001d1:	68 ac 1a 00 00       	push   $0x1aac
f01001d6:	68 f4 6c 10 f0       	push   $0xf0106cf4
f01001db:	e8 92 3c 00 00       	call   f0103e72 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001e0:	e8 5a 18 00 00       	call   f0101a3f <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001e5:	e8 63 34 00 00       	call   f010364d <env_init>
	trap_init();
f01001ea:	e8 9d 3d 00 00       	call   f0103f8c <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001ef:	e8 22 60 00 00       	call   f0106216 <mp_init>
	lapic_init();
f01001f4:	e8 51 63 00 00       	call   f010654a <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001f9:	e8 98 3b 00 00       	call   f0103d96 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01001fe:	c7 04 24 a0 23 12 f0 	movl   $0xf01223a0,(%esp)
f0100205:	e8 93 65 00 00       	call   f010679d <spin_lock>
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
f010021b:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0100220:	6a 7d                	push   $0x7d
f0100222:	68 e8 6c 10 f0       	push   $0xf0106ce8
f0100227:	e8 14 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010022c:	83 ec 04             	sub    $0x4,%esp
f010022f:	b8 6e 61 10 f0       	mov    $0xf010616e,%eax
f0100234:	2d f4 60 10 f0       	sub    $0xf01060f4,%eax
f0100239:	50                   	push   %eax
f010023a:	68 f4 60 10 f0       	push   $0xf01060f4
f010023f:	68 00 70 00 f0       	push   $0xf0007000
f0100244:	e8 b8 5c 00 00       	call   f0105f01 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100249:	6b 05 c4 23 24 f0 74 	imul   $0x74,0xf02423c4,%eax
f0100250:	05 20 20 24 f0       	add    $0xf0242020,%eax
f0100255:	83 c4 10             	add    $0x10,%esp
f0100258:	3d 20 20 24 f0       	cmp    $0xf0242020,%eax
f010025d:	76 62                	jbe    f01002c1 <i386_init+0x116>
f010025f:	bb 20 20 24 f0       	mov    $0xf0242020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100264:	e8 c6 62 00 00       	call   f010652f <cpunum>
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
f010029e:	e8 df 63 00 00       	call   f0106682 <lapic_startap>
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
f01002d5:	e8 61 35 00 00       	call   f010383b <env_create>
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
f01002e7:	68 e4 9b 00 00       	push   $0x9be4
f01002ec:	68 58 05 21 f0       	push   $0xf0210558
f01002f1:	e8 45 35 00 00       	call   f010383b <env_create>
	for (i = 0; i < 3; i++)
		ENV_CREATE(user_forktree, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002f6:	e8 e3 45 00 00       	call   f01048de <sched_yield>

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
f010030e:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0100313:	68 94 00 00 00       	push   $0x94
f0100318:	68 e8 6c 10 f0       	push   $0xf0106ce8
f010031d:	e8 1e fd ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100322:	05 00 00 00 10       	add    $0x10000000,%eax
f0100327:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010032a:	e8 00 62 00 00       	call   f010652f <cpunum>
f010032f:	83 ec 08             	sub    $0x8,%esp
f0100332:	50                   	push   %eax
f0100333:	68 0f 6d 10 f0       	push   $0xf0106d0f
f0100338:	e8 35 3b 00 00       	call   f0103e72 <cprintf>

	lapic_init();
f010033d:	e8 08 62 00 00       	call   f010654a <lapic_init>
	env_init_percpu();
f0100342:	e8 d6 32 00 00       	call   f010361d <env_init_percpu>
	trap_init_percpu();
f0100347:	e8 3a 3b 00 00       	call   f0103e86 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010034c:	e8 de 61 00 00       	call   f010652f <cpunum>
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
f010036f:	e8 29 64 00 00       	call   f010679d <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100374:	e8 65 45 00 00       	call   f01048de <sched_yield>

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
f0100389:	68 25 6d 10 f0       	push   $0xf0106d25
f010038e:	e8 df 3a 00 00       	call   f0103e72 <cprintf>
	vcprintf(fmt, ap);
f0100393:	83 c4 08             	add    $0x8,%esp
f0100396:	53                   	push   %ebx
f0100397:	ff 75 10             	pushl  0x10(%ebp)
f010039a:	e8 ad 3a 00 00       	call   f0103e4c <vcprintf>
	cprintf("\n");
f010039f:	c7 04 24 16 70 10 f0 	movl   $0xf0107016,(%esp)
f01003a6:	e8 c7 3a 00 00       	call   f0103e72 <cprintf>
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
f010045d:	0f b6 82 a0 6e 10 f0 	movzbl -0xfef9160(%edx),%eax
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
f0100499:	0f b6 82 a0 6e 10 f0 	movzbl -0xfef9160(%edx),%eax
f01004a0:	0b 05 20 10 24 f0    	or     0xf0241020,%eax
f01004a6:	0f b6 8a a0 6d 10 f0 	movzbl -0xfef9260(%edx),%ecx
f01004ad:	31 c8                	xor    %ecx,%eax
f01004af:	a3 20 10 24 f0       	mov    %eax,0xf0241020

	c = charcode[shift & (CTL | SHIFT)][data];
f01004b4:	89 c1                	mov    %eax,%ecx
f01004b6:	83 e1 03             	and    $0x3,%ecx
f01004b9:	8b 0c 8d 80 6d 10 f0 	mov    -0xfef9280(,%ecx,4),%ecx
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
f01004f7:	68 3f 6d 10 f0       	push   $0xf0106d3f
f01004fc:	e8 71 39 00 00       	call   f0103e72 <cprintf>
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
f01006b5:	e8 47 58 00 00       	call   f0105f01 <memmove>
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
f0100829:	e8 f0 34 00 00       	call   f0103d1e <irq_setmask_8259A>
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
f01008a5:	68 4b 6d 10 f0       	push   $0xf0106d4b
f01008aa:	e8 c3 35 00 00       	call   f0103e72 <cprintf>
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
f01008ea:	bb e4 72 10 f0       	mov    $0xf01072e4,%ebx
f01008ef:	be 38 73 10 f0       	mov    $0xf0107338,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008f4:	83 ec 04             	sub    $0x4,%esp
f01008f7:	ff 33                	pushl  (%ebx)
f01008f9:	ff 73 fc             	pushl  -0x4(%ebx)
f01008fc:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0100901:	e8 6c 35 00 00       	call   f0103e72 <cprintf>
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
f0100922:	68 a9 6f 10 f0       	push   $0xf0106fa9
f0100927:	e8 46 35 00 00       	call   f0103e72 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010092c:	83 c4 0c             	add    $0xc,%esp
f010092f:	68 0c 00 10 00       	push   $0x10000c
f0100934:	68 0c 00 10 f0       	push   $0xf010000c
f0100939:	68 18 71 10 f0       	push   $0xf0107118
f010093e:	e8 2f 35 00 00       	call   f0103e72 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100943:	83 c4 0c             	add    $0xc,%esp
f0100946:	68 01 6c 10 00       	push   $0x106c01
f010094b:	68 01 6c 10 f0       	push   $0xf0106c01
f0100950:	68 3c 71 10 f0       	push   $0xf010713c
f0100955:	e8 18 35 00 00       	call   f0103e72 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010095a:	83 c4 0c             	add    $0xc,%esp
f010095d:	68 a8 01 24 00       	push   $0x2401a8
f0100962:	68 a8 01 24 f0       	push   $0xf02401a8
f0100967:	68 60 71 10 f0       	push   $0xf0107160
f010096c:	e8 01 35 00 00       	call   f0103e72 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100971:	83 c4 0c             	add    $0xc,%esp
f0100974:	68 04 30 28 00       	push   $0x283004
f0100979:	68 04 30 28 f0       	push   $0xf0283004
f010097e:	68 84 71 10 f0       	push   $0xf0107184
f0100983:	e8 ea 34 00 00       	call   f0103e72 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100988:	83 c4 08             	add    $0x8,%esp
f010098b:	b8 03 34 28 f0       	mov    $0xf0283403,%eax
f0100990:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100995:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010099b:	85 c0                	test   %eax,%eax
f010099d:	0f 48 c2             	cmovs  %edx,%eax
f01009a0:	c1 f8 0a             	sar    $0xa,%eax
f01009a3:	50                   	push   %eax
f01009a4:	68 a8 71 10 f0       	push   $0xf01071a8
f01009a9:	e8 c4 34 00 00       	call   f0103e72 <cprintf>
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
f01009c4:	68 c2 6f 10 f0       	push   $0xf0106fc2
f01009c9:	e8 a4 34 00 00       	call   f0103e72 <cprintf>
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
f01009e5:	e8 22 56 00 00       	call   f010600c <strtol>
	cprintf("%d\n", result);
f01009ea:	83 c4 08             	add    $0x8,%esp
f01009ed:	ff 30                	pushl  (%eax)
f01009ef:	68 34 80 10 f0       	push   $0xf0108034
f01009f4:	e8 79 34 00 00       	call   f0103e72 <cprintf>
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
f0100a1d:	68 e9 6f 10 f0       	push   $0xf0106fe9
f0100a22:	e8 4b 34 00 00       	call   f0103e72 <cprintf>
	env_run(curenv);
f0100a27:	e8 03 5b 00 00       	call   f010652f <cpunum>
f0100a2c:	83 c4 04             	add    $0x4,%esp
f0100a2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0100a32:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0100a38:	e8 cc 31 00 00       	call   f0103c09 <env_run>

int
mon_debug_step(int argc, char **argv, struct Trapframe *tf)
{
	if (tf == NULL) {
		cprintf("Trapframe is NULL.\n");
f0100a3d:	83 ec 0c             	sub    $0xc,%esp
f0100a40:	68 d5 6f 10 f0       	push   $0xf0106fd5
f0100a45:	e8 28 34 00 00       	call   f0103e72 <cprintf>

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
f0100a65:	e8 c5 5a 00 00       	call   f010652f <cpunum>
f0100a6a:	83 ec 0c             	sub    $0xc,%esp
f0100a6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0100a70:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0100a76:	e8 8e 31 00 00       	call   f0103c09 <env_run>

int
mon_debug_continue(int argc, char **argv, struct Trapframe *tf)
{
	if (tf == NULL) {
		cprintf("Trapframe is NULL.\n");
f0100a7b:	83 ec 0c             	sub    $0xc,%esp
f0100a7e:	68 d5 6f 10 f0       	push   $0xf0106fd5
f0100a83:	e8 ea 33 00 00       	call   f0103e72 <cprintf>
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
f0100a9a:	68 f6 6f 10 f0       	push   $0xf0106ff6
f0100a9f:	e8 ce 33 00 00       	call   f0103e72 <cprintf>
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
f0100acb:	68 d4 71 10 f0       	push   $0xf01071d4
f0100ad0:	e8 9d 33 00 00       	call   f0103e72 <cprintf>
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f0100ad5:	83 c4 18             	add    $0x18,%esp
f0100ad8:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100adb:	56                   	push   %esi
f0100adc:	e8 31 46 00 00       	call   f0105112 <debuginfo_eip>
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
f0100b12:	e8 3d 52 00 00       	call   f0105d54 <strncpy>
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
f0100b2c:	68 08 70 10 f0       	push   $0xf0107008
f0100b31:	e8 3c 33 00 00       	call   f0103e72 <cprintf>
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
f0100b49:	68 18 70 10 f0       	push   $0xf0107018
f0100b4e:	e8 1f 33 00 00       	call   f0103e72 <cprintf>
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
f0100b72:	bf e0 72 10 f0       	mov    $0xf01072e0,%edi
f0100b77:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b7c:	eb 1d                	jmp    f0100b9b <mon_time+0x3b>
		cprintf("Usage: time [command]\n");
f0100b7e:	83 ec 0c             	sub    $0xc,%esp
f0100b81:	68 2b 70 10 f0       	push   $0xf010702b
f0100b86:	e8 e7 32 00 00       	call   f0103e72 <cprintf>
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
f0100ba3:	e8 2a 52 00 00       	call   f0105dd2 <strcmp>
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
f0100bba:	68 42 70 10 f0       	push   $0xf0107042
f0100bbf:	e8 ae 32 00 00       	call   f0103e72 <cprintf>
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
f0100be5:	ff 14 95 e8 72 10 f0 	call   *-0xfef8d18(,%edx,4)

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
f0100bfd:	68 57 70 10 f0       	push   $0xf0107057
f0100c02:	e8 6b 32 00 00       	call   f0103e72 <cprintf>

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
f0100c27:	68 0c 72 10 f0       	push   $0xf010720c
f0100c2c:	e8 41 32 00 00       	call   f0103e72 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c31:	c7 04 24 30 72 10 f0 	movl   $0xf0107230,(%esp)
f0100c38:	e8 35 32 00 00       	call   f0103e72 <cprintf>

	if (tf != NULL)
f0100c3d:	83 c4 10             	add    $0x10,%esp
f0100c40:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100c44:	74 0e                	je     f0100c54 <monitor+0x36>
		print_trapframe(tf);
f0100c46:	83 ec 0c             	sub    $0xc,%esp
f0100c49:	ff 75 08             	pushl  0x8(%ebp)
f0100c4c:	e8 30 37 00 00       	call   f0104381 <print_trapframe>
f0100c51:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100c54:	83 ec 0c             	sub    $0xc,%esp
f0100c57:	68 68 70 10 f0       	push   $0xf0107068
f0100c5c:	e8 7d 4f 00 00       	call   f0105bde <readline>
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
f0100c90:	68 6c 70 10 f0       	push   $0xf010706c
f0100c95:	e8 bc 51 00 00       	call   f0105e56 <strchr>
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
f0100cb0:	68 71 70 10 f0       	push   $0xf0107071
f0100cb5:	e8 b8 31 00 00       	call   f0103e72 <cprintf>
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
f0100ce0:	68 6c 70 10 f0       	push   $0xf010706c
f0100ce5:	e8 6c 51 00 00       	call   f0105e56 <strchr>
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
f0100d0e:	ff 34 85 e0 72 10 f0 	pushl  -0xfef8d20(,%eax,4)
f0100d15:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d18:	e8 b5 50 00 00       	call   f0105dd2 <strcmp>
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
f0100d32:	ff 14 85 e8 72 10 f0 	call   *-0xfef8d18(,%eax,4)
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
f0100d53:	68 8e 70 10 f0       	push   $0xf010708e
f0100d58:	e8 15 31 00 00       	call   f0103e72 <cprintf>
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
f0100e28:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0100e2d:	68 12 04 00 00       	push   $0x412
f0100e32:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0100ea2:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0100ea7:	6a 6f                	push   $0x6f
f0100ea9:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0100ec7:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0100ecc:	6a 6f                	push   $0x6f
f0100ece:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0100f0e:	68 34 73 10 f0       	push   $0xf0107334
f0100f13:	68 43 03 00 00       	push   $0x343
f0100f18:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0100fa1:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0100fa6:	6a 56                	push   $0x56
f0100fa8:	68 61 7a 10 f0       	push   $0xf0107a61
f0100fad:	e8 8e f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100fb2:	83 ec 04             	sub    $0x4,%esp
f0100fb5:	68 80 00 00 00       	push   $0x80
f0100fba:	68 97 00 00 00       	push   $0x97
f0100fbf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fc4:	50                   	push   %eax
f0100fc5:	e8 ea 4e 00 00       	call   f0105eb4 <memset>
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
f0101041:	68 6f 7a 10 f0       	push   $0xf0107a6f
f0101046:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010104b:	68 5e 03 00 00       	push   $0x35e
f0101050:	68 55 7a 10 f0       	push   $0xf0107a55
f0101055:	e8 e6 ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010105a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010105d:	72 19                	jb     f0101078 <check_page_free_list+0x188>
f010105f:	68 90 7a 10 f0       	push   $0xf0107a90
f0101064:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101069:	68 5f 03 00 00       	push   $0x35f
f010106e:	68 55 7a 10 f0       	push   $0xf0107a55
f0101073:	e8 c8 ef ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101078:	89 d0                	mov    %edx,%eax
f010107a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010107d:	a8 07                	test   $0x7,%al
f010107f:	74 19                	je     f010109a <check_page_free_list+0x1aa>
f0101081:	68 58 73 10 f0       	push   $0xf0107358
f0101086:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010108b:	68 60 03 00 00       	push   $0x360
f0101090:	68 55 7a 10 f0       	push   $0xf0107a55
f0101095:	e8 a6 ef ff ff       	call   f0100040 <_panic>
f010109a:	c1 f8 03             	sar    $0x3,%eax
f010109d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010a0:	85 c0                	test   %eax,%eax
f01010a2:	75 19                	jne    f01010bd <check_page_free_list+0x1cd>
f01010a4:	68 a4 7a 10 f0       	push   $0xf0107aa4
f01010a9:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01010ae:	68 63 03 00 00       	push   $0x363
f01010b3:	68 55 7a 10 f0       	push   $0xf0107a55
f01010b8:	e8 83 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010bd:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010c2:	75 19                	jne    f01010dd <check_page_free_list+0x1ed>
f01010c4:	68 b5 7a 10 f0       	push   $0xf0107ab5
f01010c9:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01010ce:	68 64 03 00 00       	push   $0x364
f01010d3:	68 55 7a 10 f0       	push   $0xf0107a55
f01010d8:	e8 63 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01010dd:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01010e2:	75 19                	jne    f01010fd <check_page_free_list+0x20d>
f01010e4:	68 8c 73 10 f0       	push   $0xf010738c
f01010e9:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01010ee:	68 65 03 00 00       	push   $0x365
f01010f3:	68 55 7a 10 f0       	push   $0xf0107a55
f01010f8:	e8 43 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01010fd:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101102:	75 19                	jne    f010111d <check_page_free_list+0x22d>
f0101104:	68 ce 7a 10 f0       	push   $0xf0107ace
f0101109:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010110e:	68 66 03 00 00       	push   $0x366
f0101113:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101133:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0101138:	6a 56                	push   $0x56
f010113a:	68 61 7a 10 f0       	push   $0xf0107a61
f010113f:	e8 fc ee ff ff       	call   f0100040 <_panic>
f0101144:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f010114a:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010114d:	0f 86 99 00 00 00    	jbe    f01011ec <check_page_free_list+0x2fc>
f0101153:	68 b0 73 10 f0       	push   $0xf01073b0
f0101158:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010115d:	68 67 03 00 00       	push   $0x367
f0101162:	68 55 7a 10 f0       	push   $0xf0107a55
f0101167:	e8 d4 ee ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010116c:	68 e8 7a 10 f0       	push   $0xf0107ae8
f0101171:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101176:	68 69 03 00 00       	push   $0x369
f010117b:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010119b:	68 05 7b 10 f0       	push   $0xf0107b05
f01011a0:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01011a5:	68 71 03 00 00       	push   $0x371
f01011aa:	68 55 7a 10 f0       	push   $0xf0107a55
f01011af:	e8 8c ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01011b4:	85 db                	test   %ebx,%ebx
f01011b6:	7f 40                	jg     f01011f8 <check_page_free_list+0x308>
f01011b8:	68 17 7b 10 f0       	push   $0xf0107b17
f01011bd:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01011c2:	68 72 03 00 00       	push   $0x372
f01011c7:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101253:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0101258:	68 47 01 00 00       	push   $0x147
f010125d:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101307:	68 a0 6c 10 f0       	push   $0xf0106ca0
f010130c:	6a 56                	push   $0x56
f010130e:	68 61 7a 10 f0       	push   $0xf0107a61
f0101313:	e8 28 ed ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0101318:	83 ec 04             	sub    $0x4,%esp
f010131b:	68 00 10 00 00       	push   $0x1000
f0101320:	6a 00                	push   $0x0
f0101322:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101327:	50                   	push   %eax
f0101328:	e8 87 4b 00 00       	call   f0105eb4 <memset>
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
f010143a:	68 a0 6c 10 f0       	push   $0xf0106ca0
f010143f:	6a 56                	push   $0x56
f0101441:	68 61 7a 10 f0       	push   $0xf0107a61
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
f010145b:	e8 54 4a 00 00       	call   f0105eb4 <memset>
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
f010155a:	68 f8 73 10 f0       	push   $0xf01073f8
f010155f:	e8 0e 29 00 00       	call   f0103e72 <cprintf>
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
f0101648:	68 a0 6c 10 f0       	push   $0xf0106ca0
f010164d:	6a 56                	push   $0x56
f010164f:	68 61 7a 10 f0       	push   $0xf0107a61
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
f0101674:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0101679:	6a 56                	push   $0x56
f010167b:	68 61 7a 10 f0       	push   $0xf0107a61
f0101680:	e8 bb e9 ff ff       	call   f0100040 <_panic>
f0101685:	83 ec 04             	sub    $0x4,%esp
f0101688:	57                   	push   %edi
f0101689:	52                   	push   %edx
f010168a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010168f:	50                   	push   %eax
f0101690:	e8 6c 48 00 00       	call   f0105f01 <memmove>
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
f010178c:	68 28 7b 10 f0       	push   $0xf0107b28
f0101791:	e8 dc 26 00 00       	call   f0103e72 <cprintf>
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
f01017c4:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01017c9:	68 5c 02 00 00       	push   $0x25c
f01017ce:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010182c:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0101831:	68 64 02 00 00       	push   $0x264
f0101836:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01018fe:	68 1c 74 10 f0       	push   $0xf010741c
f0101903:	6a 4f                	push   $0x4f
f0101905:	68 61 7a 10 f0       	push   $0xf0107a61
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
f0101931:	e8 f9 4b 00 00       	call   f010652f <cpunum>
f0101936:	6b c0 74             	imul   $0x74,%eax,%eax
f0101939:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0101940:	74 16                	je     f0101958 <tlb_invalidate+0x2d>
f0101942:	e8 e8 4b 00 00       	call   f010652f <cpunum>
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
f0101a4a:	e8 a1 22 00 00       	call   f0103cf0 <mc146818_read>
f0101a4f:	89 c3                	mov    %eax,%ebx
f0101a51:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101a58:	e8 93 22 00 00       	call   f0103cf0 <mc146818_read>
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
f0101a7f:	e8 6c 22 00 00       	call   f0103cf0 <mc146818_read>
f0101a84:	89 c3                	mov    %eax,%ebx
f0101a86:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101a8d:	e8 5e 22 00 00       	call   f0103cf0 <mc146818_read>
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
f0101ae8:	68 3c 74 10 f0       	push   $0xf010743c
f0101aed:	e8 80 23 00 00       	call   f0103e72 <cprintf>
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
f0101b0c:	e8 a3 43 00 00       	call   f0105eb4 <memset>
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
f0101b21:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0101b26:	68 96 00 00 00       	push   $0x96
f0101b2b:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101b80:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0101b85:	68 83 03 00 00       	push   $0x383
f0101b8a:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101bc5:	68 55 7b 10 f0       	push   $0xf0107b55
f0101bca:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101bcf:	68 8b 03 00 00       	push   $0x38b
f0101bd4:	68 55 7a 10 f0       	push   $0xf0107a55
f0101bd9:	e8 62 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bde:	83 ec 0c             	sub    $0xc,%esp
f0101be1:	6a 00                	push   $0x0
f0101be3:	e8 df f6 ff ff       	call   f01012c7 <page_alloc>
f0101be8:	89 c6                	mov    %eax,%esi
f0101bea:	83 c4 10             	add    $0x10,%esp
f0101bed:	85 c0                	test   %eax,%eax
f0101bef:	75 19                	jne    f0101c0a <mem_init+0x1cb>
f0101bf1:	68 6b 7b 10 f0       	push   $0xf0107b6b
f0101bf6:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101bfb:	68 8c 03 00 00       	push   $0x38c
f0101c00:	68 55 7a 10 f0       	push   $0xf0107a55
f0101c05:	e8 36 e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c0a:	83 ec 0c             	sub    $0xc,%esp
f0101c0d:	6a 00                	push   $0x0
f0101c0f:	e8 b3 f6 ff ff       	call   f01012c7 <page_alloc>
f0101c14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c17:	83 c4 10             	add    $0x10,%esp
f0101c1a:	85 c0                	test   %eax,%eax
f0101c1c:	75 19                	jne    f0101c37 <mem_init+0x1f8>
f0101c1e:	68 81 7b 10 f0       	push   $0xf0107b81
f0101c23:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101c28:	68 8d 03 00 00       	push   $0x38d
f0101c2d:	68 55 7a 10 f0       	push   $0xf0107a55
f0101c32:	e8 09 e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c37:	39 f7                	cmp    %esi,%edi
f0101c39:	75 19                	jne    f0101c54 <mem_init+0x215>
f0101c3b:	68 97 7b 10 f0       	push   $0xf0107b97
f0101c40:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101c45:	68 90 03 00 00       	push   $0x390
f0101c4a:	68 55 7a 10 f0       	push   $0xf0107a55
f0101c4f:	e8 ec e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c57:	39 c7                	cmp    %eax,%edi
f0101c59:	74 04                	je     f0101c5f <mem_init+0x220>
f0101c5b:	39 c6                	cmp    %eax,%esi
f0101c5d:	75 19                	jne    f0101c78 <mem_init+0x239>
f0101c5f:	68 78 74 10 f0       	push   $0xf0107478
f0101c64:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101c69:	68 91 03 00 00       	push   $0x391
f0101c6e:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101c95:	68 a9 7b 10 f0       	push   $0xf0107ba9
f0101c9a:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101c9f:	68 92 03 00 00       	push   $0x392
f0101ca4:	68 55 7a 10 f0       	push   $0xf0107a55
f0101ca9:	e8 92 e3 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101cae:	89 f0                	mov    %esi,%eax
f0101cb0:	29 c8                	sub    %ecx,%eax
f0101cb2:	c1 f8 03             	sar    $0x3,%eax
f0101cb5:	c1 e0 0c             	shl    $0xc,%eax
f0101cb8:	39 c2                	cmp    %eax,%edx
f0101cba:	77 19                	ja     f0101cd5 <mem_init+0x296>
f0101cbc:	68 c6 7b 10 f0       	push   $0xf0107bc6
f0101cc1:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101cc6:	68 93 03 00 00       	push   $0x393
f0101ccb:	68 55 7a 10 f0       	push   $0xf0107a55
f0101cd0:	e8 6b e3 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101cd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd8:	29 c8                	sub    %ecx,%eax
f0101cda:	c1 f8 03             	sar    $0x3,%eax
f0101cdd:	c1 e0 0c             	shl    $0xc,%eax
f0101ce0:	39 c2                	cmp    %eax,%edx
f0101ce2:	77 19                	ja     f0101cfd <mem_init+0x2be>
f0101ce4:	68 e3 7b 10 f0       	push   $0xf0107be3
f0101ce9:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101cee:	68 94 03 00 00       	push   $0x394
f0101cf3:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101d20:	68 00 7c 10 f0       	push   $0xf0107c00
f0101d25:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101d2a:	68 9b 03 00 00       	push   $0x39b
f0101d2f:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101d6a:	68 55 7b 10 f0       	push   $0xf0107b55
f0101d6f:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101d74:	68 a2 03 00 00       	push   $0x3a2
f0101d79:	68 55 7a 10 f0       	push   $0xf0107a55
f0101d7e:	e8 bd e2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d83:	83 ec 0c             	sub    $0xc,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	e8 3a f5 ff ff       	call   f01012c7 <page_alloc>
f0101d8d:	89 c7                	mov    %eax,%edi
f0101d8f:	83 c4 10             	add    $0x10,%esp
f0101d92:	85 c0                	test   %eax,%eax
f0101d94:	75 19                	jne    f0101daf <mem_init+0x370>
f0101d96:	68 6b 7b 10 f0       	push   $0xf0107b6b
f0101d9b:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101da0:	68 a3 03 00 00       	push   $0x3a3
f0101da5:	68 55 7a 10 f0       	push   $0xf0107a55
f0101daa:	e8 91 e2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101daf:	83 ec 0c             	sub    $0xc,%esp
f0101db2:	6a 00                	push   $0x0
f0101db4:	e8 0e f5 ff ff       	call   f01012c7 <page_alloc>
f0101db9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101dbc:	83 c4 10             	add    $0x10,%esp
f0101dbf:	85 c0                	test   %eax,%eax
f0101dc1:	75 19                	jne    f0101ddc <mem_init+0x39d>
f0101dc3:	68 81 7b 10 f0       	push   $0xf0107b81
f0101dc8:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101dcd:	68 a4 03 00 00       	push   $0x3a4
f0101dd2:	68 55 7a 10 f0       	push   $0xf0107a55
f0101dd7:	e8 64 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ddc:	39 fe                	cmp    %edi,%esi
f0101dde:	75 19                	jne    f0101df9 <mem_init+0x3ba>
f0101de0:	68 97 7b 10 f0       	push   $0xf0107b97
f0101de5:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101dea:	68 a6 03 00 00       	push   $0x3a6
f0101def:	68 55 7a 10 f0       	push   $0xf0107a55
f0101df4:	e8 47 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101df9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dfc:	39 c7                	cmp    %eax,%edi
f0101dfe:	74 04                	je     f0101e04 <mem_init+0x3c5>
f0101e00:	39 c6                	cmp    %eax,%esi
f0101e02:	75 19                	jne    f0101e1d <mem_init+0x3de>
f0101e04:	68 78 74 10 f0       	push   $0xf0107478
f0101e09:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101e0e:	68 a7 03 00 00       	push   $0x3a7
f0101e13:	68 55 7a 10 f0       	push   $0xf0107a55
f0101e18:	e8 23 e2 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101e1d:	83 ec 0c             	sub    $0xc,%esp
f0101e20:	6a 00                	push   $0x0
f0101e22:	e8 a0 f4 ff ff       	call   f01012c7 <page_alloc>
f0101e27:	83 c4 10             	add    $0x10,%esp
f0101e2a:	85 c0                	test   %eax,%eax
f0101e2c:	74 19                	je     f0101e47 <mem_init+0x408>
f0101e2e:	68 00 7c 10 f0       	push   $0xf0107c00
f0101e33:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101e38:	68 a8 03 00 00       	push   $0x3a8
f0101e3d:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101e63:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0101e68:	6a 56                	push   $0x56
f0101e6a:	68 61 7a 10 f0       	push   $0xf0107a61
f0101e6f:	e8 cc e1 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101e74:	83 ec 04             	sub    $0x4,%esp
f0101e77:	68 00 10 00 00       	push   $0x1000
f0101e7c:	6a 01                	push   $0x1
f0101e7e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e83:	50                   	push   %eax
f0101e84:	e8 2b 40 00 00       	call   f0105eb4 <memset>
	page_free(pp0);
f0101e89:	89 34 24             	mov    %esi,(%esp)
f0101e8c:	e8 a7 f6 ff ff       	call   f0101538 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101e91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101e98:	e8 2a f4 ff ff       	call   f01012c7 <page_alloc>
f0101e9d:	83 c4 10             	add    $0x10,%esp
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	75 19                	jne    f0101ebd <mem_init+0x47e>
f0101ea4:	68 0f 7c 10 f0       	push   $0xf0107c0f
f0101ea9:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101eae:	68 ad 03 00 00       	push   $0x3ad
f0101eb3:	68 55 7a 10 f0       	push   $0xf0107a55
f0101eb8:	e8 83 e1 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101ebd:	39 c6                	cmp    %eax,%esi
f0101ebf:	74 19                	je     f0101eda <mem_init+0x49b>
f0101ec1:	68 2d 7c 10 f0       	push   $0xf0107c2d
f0101ec6:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101ecb:	68 ae 03 00 00       	push   $0x3ae
f0101ed0:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101ef6:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0101efb:	6a 56                	push   $0x56
f0101efd:	68 61 7a 10 f0       	push   $0xf0107a61
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
f0101f21:	68 3d 7c 10 f0       	push   $0xf0107c3d
f0101f26:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101f2b:	68 b1 03 00 00       	push   $0x3b1
f0101f30:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0101f7e:	68 47 7c 10 f0       	push   $0xf0107c47
f0101f83:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101f88:	68 be 03 00 00       	push   $0x3be
f0101f8d:	68 55 7a 10 f0       	push   $0xf0107a55
f0101f92:	e8 a9 e0 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101f97:	83 ec 0c             	sub    $0xc,%esp
f0101f9a:	68 98 74 10 f0       	push   $0xf0107498
f0101f9f:	e8 ce 1e 00 00       	call   f0103e72 <cprintf>
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
f0101fb9:	68 55 7b 10 f0       	push   $0xf0107b55
f0101fbe:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101fc3:	68 26 04 00 00       	push   $0x426
f0101fc8:	68 55 7a 10 f0       	push   $0xf0107a55
f0101fcd:	e8 6e e0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101fd2:	83 ec 0c             	sub    $0xc,%esp
f0101fd5:	6a 00                	push   $0x0
f0101fd7:	e8 eb f2 ff ff       	call   f01012c7 <page_alloc>
f0101fdc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fdf:	83 c4 10             	add    $0x10,%esp
f0101fe2:	85 c0                	test   %eax,%eax
f0101fe4:	75 19                	jne    f0101fff <mem_init+0x5c0>
f0101fe6:	68 6b 7b 10 f0       	push   $0xf0107b6b
f0101feb:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0101ff0:	68 27 04 00 00       	push   $0x427
f0101ff5:	68 55 7a 10 f0       	push   $0xf0107a55
f0101ffa:	e8 41 e0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101fff:	83 ec 0c             	sub    $0xc,%esp
f0102002:	6a 00                	push   $0x0
f0102004:	e8 be f2 ff ff       	call   f01012c7 <page_alloc>
f0102009:	89 c6                	mov    %eax,%esi
f010200b:	83 c4 10             	add    $0x10,%esp
f010200e:	85 c0                	test   %eax,%eax
f0102010:	75 19                	jne    f010202b <mem_init+0x5ec>
f0102012:	68 81 7b 10 f0       	push   $0xf0107b81
f0102017:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010201c:	68 28 04 00 00       	push   $0x428
f0102021:	68 55 7a 10 f0       	push   $0xf0107a55
f0102026:	e8 15 e0 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010202b:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010202e:	75 19                	jne    f0102049 <mem_init+0x60a>
f0102030:	68 97 7b 10 f0       	push   $0xf0107b97
f0102035:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010203a:	68 2b 04 00 00       	push   $0x42b
f010203f:	68 55 7a 10 f0       	push   $0xf0107a55
f0102044:	e8 f7 df ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102049:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010204c:	74 04                	je     f0102052 <mem_init+0x613>
f010204e:	39 c3                	cmp    %eax,%ebx
f0102050:	75 19                	jne    f010206b <mem_init+0x62c>
f0102052:	68 78 74 10 f0       	push   $0xf0107478
f0102057:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010205c:	68 2c 04 00 00       	push   $0x42c
f0102061:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010208e:	68 00 7c 10 f0       	push   $0xf0107c00
f0102093:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102098:	68 33 04 00 00       	push   $0x433
f010209d:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01020c2:	68 b8 74 10 f0       	push   $0xf01074b8
f01020c7:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01020cc:	68 36 04 00 00       	push   $0x436
f01020d1:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01020f4:	68 f0 74 10 f0       	push   $0xf01074f0
f01020f9:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01020fe:	68 39 04 00 00       	push   $0x439
f0102103:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010212f:	68 20 75 10 f0       	push   $0xf0107520
f0102134:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102139:	68 3d 04 00 00       	push   $0x43d
f010213e:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010216e:	68 50 75 10 f0       	push   $0xf0107550
f0102173:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102178:	68 3e 04 00 00       	push   $0x43e
f010217d:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01021a3:	68 78 75 10 f0       	push   $0xf0107578
f01021a8:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01021ad:	68 3f 04 00 00       	push   $0x43f
f01021b2:	68 55 7a 10 f0       	push   $0xf0107a55
f01021b7:	e8 84 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01021bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bf:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021c4:	74 19                	je     f01021df <mem_init+0x7a0>
f01021c6:	68 52 7c 10 f0       	push   $0xf0107c52
f01021cb:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01021d0:	68 40 04 00 00       	push   $0x440
f01021d5:	68 55 7a 10 f0       	push   $0xf0107a55
f01021da:	e8 61 de ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01021df:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021e4:	74 19                	je     f01021ff <mem_init+0x7c0>
f01021e6:	68 63 7c 10 f0       	push   $0xf0107c63
f01021eb:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01021f0:	68 41 04 00 00       	push   $0x441
f01021f5:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102214:	68 a8 75 10 f0       	push   $0xf01075a8
f0102219:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010221e:	68 44 04 00 00       	push   $0x444
f0102223:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010224e:	68 e4 75 10 f0       	push   $0xf01075e4
f0102253:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102258:	68 45 04 00 00       	push   $0x445
f010225d:	68 55 7a 10 f0       	push   $0xf0107a55
f0102262:	e8 d9 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102267:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010226c:	74 19                	je     f0102287 <mem_init+0x848>
f010226e:	68 74 7c 10 f0       	push   $0xf0107c74
f0102273:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102278:	68 46 04 00 00       	push   $0x446
f010227d:	68 55 7a 10 f0       	push   $0xf0107a55
f0102282:	e8 b9 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102287:	83 ec 0c             	sub    $0xc,%esp
f010228a:	6a 00                	push   $0x0
f010228c:	e8 36 f0 ff ff       	call   f01012c7 <page_alloc>
f0102291:	83 c4 10             	add    $0x10,%esp
f0102294:	85 c0                	test   %eax,%eax
f0102296:	74 19                	je     f01022b1 <mem_init+0x872>
f0102298:	68 00 7c 10 f0       	push   $0xf0107c00
f010229d:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01022a2:	68 49 04 00 00       	push   $0x449
f01022a7:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01022cb:	68 a8 75 10 f0       	push   $0xf01075a8
f01022d0:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01022d5:	68 4c 04 00 00       	push   $0x44c
f01022da:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102305:	68 e4 75 10 f0       	push   $0xf01075e4
f010230a:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010230f:	68 4d 04 00 00       	push   $0x44d
f0102314:	68 55 7a 10 f0       	push   $0xf0107a55
f0102319:	e8 22 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010231e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102323:	74 19                	je     f010233e <mem_init+0x8ff>
f0102325:	68 74 7c 10 f0       	push   $0xf0107c74
f010232a:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010232f:	68 4e 04 00 00       	push   $0x44e
f0102334:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010234f:	68 00 7c 10 f0       	push   $0xf0107c00
f0102354:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102359:	68 52 04 00 00       	push   $0x452
f010235e:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102383:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0102388:	68 55 04 00 00       	push   $0x455
f010238d:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01023bc:	68 14 76 10 f0       	push   $0xf0107614
f01023c1:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01023c6:	68 56 04 00 00       	push   $0x456
f01023cb:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01023ef:	68 54 76 10 f0       	push   $0xf0107654
f01023f4:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01023f9:	68 59 04 00 00       	push   $0x459
f01023fe:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010242c:	68 e4 75 10 f0       	push   $0xf01075e4
f0102431:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102436:	68 5a 04 00 00       	push   $0x45a
f010243b:	68 55 7a 10 f0       	push   $0xf0107a55
f0102440:	e8 fb db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102445:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010244a:	74 19                	je     f0102465 <mem_init+0xa26>
f010244c:	68 74 7c 10 f0       	push   $0xf0107c74
f0102451:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102456:	68 5b 04 00 00       	push   $0x45b
f010245b:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010247d:	68 94 76 10 f0       	push   $0xf0107694
f0102482:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102487:	68 5c 04 00 00       	push   $0x45c
f010248c:	68 55 7a 10 f0       	push   $0xf0107a55
f0102491:	e8 aa db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102496:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
f010249b:	f6 00 04             	testb  $0x4,(%eax)
f010249e:	75 19                	jne    f01024b9 <mem_init+0xa7a>
f01024a0:	68 85 7c 10 f0       	push   $0xf0107c85
f01024a5:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01024aa:	68 5d 04 00 00       	push   $0x45d
f01024af:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01024ce:	68 c8 76 10 f0       	push   $0xf01076c8
f01024d3:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01024d8:	68 60 04 00 00       	push   $0x460
f01024dd:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102503:	68 00 77 10 f0       	push   $0xf0107700
f0102508:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010250d:	68 63 04 00 00       	push   $0x463
f0102512:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102539:	68 3c 77 10 f0       	push   $0xf010773c
f010253e:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102543:	68 64 04 00 00       	push   $0x464
f0102548:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010257c:	68 74 77 10 f0       	push   $0xf0107774
f0102581:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102586:	68 67 04 00 00       	push   $0x467
f010258b:	68 55 7a 10 f0       	push   $0xf0107a55
f0102590:	e8 ab da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102595:	ba 00 10 00 00       	mov    $0x1000,%edx
f010259a:	89 f8                	mov    %edi,%eax
f010259c:	e8 62 e8 ff ff       	call   f0100e03 <check_va2pa>
f01025a1:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01025a4:	74 19                	je     f01025bf <mem_init+0xb80>
f01025a6:	68 a0 77 10 f0       	push   $0xf01077a0
f01025ab:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01025b0:	68 68 04 00 00       	push   $0x468
f01025b5:	68 55 7a 10 f0       	push   $0xf0107a55
f01025ba:	e8 81 da ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01025bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025c2:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f01025c7:	74 19                	je     f01025e2 <mem_init+0xba3>
f01025c9:	68 9b 7c 10 f0       	push   $0xf0107c9b
f01025ce:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01025d3:	68 6a 04 00 00       	push   $0x46a
f01025d8:	68 55 7a 10 f0       	push   $0xf0107a55
f01025dd:	e8 5e da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025e2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025e7:	74 19                	je     f0102602 <mem_init+0xbc3>
f01025e9:	68 ac 7c 10 f0       	push   $0xf0107cac
f01025ee:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01025f3:	68 6b 04 00 00       	push   $0x46b
f01025f8:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102617:	68 d0 77 10 f0       	push   $0xf01077d0
f010261c:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102621:	68 6e 04 00 00       	push   $0x46e
f0102626:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010265a:	68 f4 77 10 f0       	push   $0xf01077f4
f010265f:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102664:	68 72 04 00 00       	push   $0x472
f0102669:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102692:	68 a0 77 10 f0       	push   $0xf01077a0
f0102697:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010269c:	68 73 04 00 00       	push   $0x473
f01026a1:	68 55 7a 10 f0       	push   $0xf0107a55
f01026a6:	e8 95 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01026ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026ae:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01026b3:	74 19                	je     f01026ce <mem_init+0xc8f>
f01026b5:	68 52 7c 10 f0       	push   $0xf0107c52
f01026ba:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01026bf:	68 74 04 00 00       	push   $0x474
f01026c4:	68 55 7a 10 f0       	push   $0xf0107a55
f01026c9:	e8 72 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026ce:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026d3:	74 19                	je     f01026ee <mem_init+0xcaf>
f01026d5:	68 ac 7c 10 f0       	push   $0xf0107cac
f01026da:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01026df:	68 75 04 00 00       	push   $0x475
f01026e4:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102716:	68 f4 77 10 f0       	push   $0xf01077f4
f010271b:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102720:	68 79 04 00 00       	push   $0x479
f0102725:	68 55 7a 10 f0       	push   $0xf0107a55
f010272a:	e8 11 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010272f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102734:	89 f8                	mov    %edi,%eax
f0102736:	e8 c8 e6 ff ff       	call   f0100e03 <check_va2pa>
f010273b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010273e:	74 19                	je     f0102759 <mem_init+0xd1a>
f0102740:	68 18 78 10 f0       	push   $0xf0107818
f0102745:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010274a:	68 7a 04 00 00       	push   $0x47a
f010274f:	68 55 7a 10 f0       	push   $0xf0107a55
f0102754:	e8 e7 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102759:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010275c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102761:	74 19                	je     f010277c <mem_init+0xd3d>
f0102763:	68 bd 7c 10 f0       	push   $0xf0107cbd
f0102768:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010276d:	68 7b 04 00 00       	push   $0x47b
f0102772:	68 55 7a 10 f0       	push   $0xf0107a55
f0102777:	e8 c4 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010277c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102781:	74 19                	je     f010279c <mem_init+0xd5d>
f0102783:	68 ac 7c 10 f0       	push   $0xf0107cac
f0102788:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010278d:	68 7c 04 00 00       	push   $0x47c
f0102792:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01027b2:	68 40 78 10 f0       	push   $0xf0107840
f01027b7:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01027bc:	68 7f 04 00 00       	push   $0x47f
f01027c1:	68 55 7a 10 f0       	push   $0xf0107a55
f01027c6:	e8 75 d8 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01027cb:	83 ec 0c             	sub    $0xc,%esp
f01027ce:	6a 00                	push   $0x0
f01027d0:	e8 f2 ea ff ff       	call   f01012c7 <page_alloc>
f01027d5:	83 c4 10             	add    $0x10,%esp
f01027d8:	85 c0                	test   %eax,%eax
f01027da:	74 19                	je     f01027f5 <mem_init+0xdb6>
f01027dc:	68 00 7c 10 f0       	push   $0xf0107c00
f01027e1:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01027e6:	68 82 04 00 00       	push   $0x482
f01027eb:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102815:	68 50 75 10 f0       	push   $0xf0107550
f010281a:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010281f:	68 85 04 00 00       	push   $0x485
f0102824:	68 55 7a 10 f0       	push   $0xf0107a55
f0102829:	e8 12 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010282e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102834:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102839:	74 19                	je     f0102854 <mem_init+0xe15>
f010283b:	68 63 7c 10 f0       	push   $0xf0107c63
f0102840:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102845:	68 87 04 00 00       	push   $0x487
f010284a:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01028a0:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01028a5:	68 8e 04 00 00       	push   $0x48e
f01028aa:	68 55 7a 10 f0       	push   $0xf0107a55
f01028af:	e8 8c d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028b4:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01028ba:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01028bd:	74 19                	je     f01028d8 <mem_init+0xe99>
f01028bf:	68 ce 7c 10 f0       	push   $0xf0107cce
f01028c4:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01028c9:	68 8f 04 00 00       	push   $0x48f
f01028ce:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01028fd:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0102902:	6a 56                	push   $0x56
f0102904:	68 61 7a 10 f0       	push   $0xf0107a61
f0102909:	e8 32 d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010290e:	83 ec 04             	sub    $0x4,%esp
f0102911:	68 00 10 00 00       	push   $0x1000
f0102916:	68 ff 00 00 00       	push   $0xff
f010291b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102920:	50                   	push   %eax
f0102921:	e8 8e 35 00 00       	call   f0105eb4 <memset>
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
f010295f:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0102964:	6a 56                	push   $0x56
f0102966:	68 61 7a 10 f0       	push   $0xf0107a61
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
f0102995:	68 e6 7c 10 f0       	push   $0xf0107ce6
f010299a:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010299f:	68 99 04 00 00       	push   $0x499
f01029a4:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01029ed:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01029f4:	e8 79 14 00 00       	call   f0103e72 <cprintf>
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
f0102a1c:	68 16 7d 10 f0       	push   $0xf0107d16
f0102a21:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102a26:	68 c6 04 00 00       	push   $0x4c6
f0102a2b:	68 55 7a 10 f0       	push   $0xf0107a55
f0102a30:	e8 0b d6 ff ff       	call   f0100040 <_panic>
	assert(pp0 != 0);
f0102a35:	85 c0                	test   %eax,%eax
f0102a37:	75 19                	jne    f0102a52 <mem_init+0x1013>
f0102a39:	68 1e 7d 10 f0       	push   $0xf0107d1e
f0102a3e:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102a43:	68 c7 04 00 00       	push   $0x4c7
f0102a48:	68 55 7a 10 f0       	push   $0xf0107a55
f0102a4d:	e8 ee d5 ff ff       	call   f0100040 <_panic>
	assert(pp != pp0);
f0102a52:	39 c3                	cmp    %eax,%ebx
f0102a54:	75 19                	jne    f0102a6f <mem_init+0x1030>
f0102a56:	68 27 7d 10 f0       	push   $0xf0107d27
f0102a5b:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102a60:	68 c8 04 00 00       	push   $0x4c8
f0102a65:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102a97:	68 31 7d 10 f0       	push   $0xf0107d31
f0102a9c:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102aa1:	68 ce 04 00 00       	push   $0x4ce
f0102aa6:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102ac2:	68 49 7d 10 f0       	push   $0xf0107d49
f0102ac7:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102acc:	68 d1 04 00 00       	push   $0x4d1
f0102ad1:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102afa:	68 62 7d 10 f0       	push   $0xf0107d62
f0102aff:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102b04:	68 d5 04 00 00       	push   $0x4d5
f0102b09:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102b25:	68 7a 7d 10 f0       	push   $0xf0107d7a
f0102b2a:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102b2f:	68 d8 04 00 00       	push   $0x4d8
f0102b34:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102b72:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0102b77:	6a 56                	push   $0x56
f0102b79:	68 61 7a 10 f0       	push   $0xf0107a61
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
f0102b9d:	68 93 7d 10 f0       	push   $0xf0107d93
f0102ba2:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102ba7:	68 e2 04 00 00       	push   $0x4e2
f0102bac:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102bcf:	68 a0 7d 10 f0       	push   $0xf0107da0
f0102bd4:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102bd9:	68 e6 04 00 00       	push   $0x4e6
f0102bde:	68 55 7a 10 f0       	push   $0xf0107a55
f0102be3:	e8 58 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_n_pages() succeeded!\n");
f0102be8:	83 ec 0c             	sub    $0xc,%esp
f0102beb:	68 ba 7d 10 f0       	push   $0xf0107dba
f0102bf0:	e8 7d 12 00 00       	call   f0103e72 <cprintf>
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
f0102c05:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0102c0a:	68 bd 00 00 00       	push   $0xbd
f0102c0f:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102c56:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0102c5b:	68 c6 00 00 00       	push   $0xc6
f0102c60:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102c99:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0102c9e:	68 d3 00 00 00       	push   $0xd3
f0102ca3:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102d2b:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0102d30:	68 1b 01 00 00       	push   $0x11b
f0102d35:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102dc8:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0102dcd:	68 d6 03 00 00       	push   $0x3d6
f0102dd2:	68 55 7a 10 f0       	push   $0xf0107a55
f0102dd7:	e8 64 d2 ff ff       	call   f0100040 <_panic>
f0102ddc:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102de3:	39 c2                	cmp    %eax,%edx
f0102de5:	74 19                	je     f0102e00 <mem_init+0x13c1>
f0102de7:	68 64 78 10 f0       	push   $0xf0107864
f0102dec:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102df1:	68 d6 03 00 00       	push   $0x3d6
f0102df6:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102e20:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0102e25:	68 db 03 00 00       	push   $0x3db
f0102e2a:	68 55 7a 10 f0       	push   $0xf0107a55
f0102e2f:	e8 0c d2 ff ff       	call   f0100040 <_panic>
f0102e34:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102e3b:	39 c2                	cmp    %eax,%edx
f0102e3d:	74 19                	je     f0102e58 <mem_init+0x1419>
f0102e3f:	68 98 78 10 f0       	push   $0xf0107898
f0102e44:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102e49:	68 db 03 00 00       	push   $0x3db
f0102e4e:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102e86:	68 cc 78 10 f0       	push   $0xf01078cc
f0102e8b:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102e90:	68 df 03 00 00       	push   $0x3df
f0102e95:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102ec2:	68 d6 7d 10 f0       	push   $0xf0107dd6
f0102ec7:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102ecc:	68 e3 03 00 00       	push   $0x3e3
f0102ed1:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102f20:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0102f25:	68 eb 03 00 00       	push   $0x3eb
f0102f2a:	68 55 7a 10 f0       	push   $0xf0107a55
f0102f2f:	e8 0c d1 ff ff       	call   f0100040 <_panic>
f0102f34:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f37:	8d 94 0b 00 30 24 f0 	lea    -0xfdbd000(%ebx,%ecx,1),%edx
f0102f3e:	39 c2                	cmp    %eax,%edx
f0102f40:	74 19                	je     f0102f5b <mem_init+0x151c>
f0102f42:	68 f4 78 10 f0       	push   $0xf01078f4
f0102f47:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102f4c:	68 eb 03 00 00       	push   $0x3eb
f0102f51:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102f82:	68 3c 79 10 f0       	push   $0xf010793c
f0102f87:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102f8c:	68 ed 03 00 00       	push   $0x3ed
f0102f91:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0102fdf:	68 f1 7d 10 f0       	push   $0xf0107df1
f0102fe4:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0102fe9:	68 f7 03 00 00       	push   $0x3f7
f0102fee:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0103007:	68 f1 7d 10 f0       	push   $0xf0107df1
f010300c:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0103011:	68 fb 03 00 00       	push   $0x3fb
f0103016:	68 55 7a 10 f0       	push   $0xf0107a55
f010301b:	e8 20 d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103020:	f6 c2 02             	test   $0x2,%dl
f0103023:	75 38                	jne    f010305d <mem_init+0x161e>
f0103025:	68 02 7e 10 f0       	push   $0xf0107e02
f010302a:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010302f:	68 fc 03 00 00       	push   $0x3fc
f0103034:	68 55 7a 10 f0       	push   $0xf0107a55
f0103039:	e8 02 d0 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f010303e:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0103042:	74 19                	je     f010305d <mem_init+0x161e>
f0103044:	68 13 7e 10 f0       	push   $0xf0107e13
f0103049:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010304e:	68 fe 03 00 00       	push   $0x3fe
f0103053:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010306e:	68 60 79 10 f0       	push   $0xf0107960
f0103073:	e8 fa 0d 00 00       	call   f0103e72 <cprintf>
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
f0103088:	68 c4 6c 10 f0       	push   $0xf0106cc4
f010308d:	68 ec 00 00 00       	push   $0xec
f0103092:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01030cf:	68 55 7b 10 f0       	push   $0xf0107b55
f01030d4:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01030d9:	68 f6 04 00 00       	push   $0x4f6
f01030de:	68 55 7a 10 f0       	push   $0xf0107a55
f01030e3:	e8 58 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01030e8:	83 ec 0c             	sub    $0xc,%esp
f01030eb:	6a 00                	push   $0x0
f01030ed:	e8 d5 e1 ff ff       	call   f01012c7 <page_alloc>
f01030f2:	89 c7                	mov    %eax,%edi
f01030f4:	83 c4 10             	add    $0x10,%esp
f01030f7:	85 c0                	test   %eax,%eax
f01030f9:	75 19                	jne    f0103114 <mem_init+0x16d5>
f01030fb:	68 6b 7b 10 f0       	push   $0xf0107b6b
f0103100:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0103105:	68 f7 04 00 00       	push   $0x4f7
f010310a:	68 55 7a 10 f0       	push   $0xf0107a55
f010310f:	e8 2c cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103114:	83 ec 0c             	sub    $0xc,%esp
f0103117:	6a 00                	push   $0x0
f0103119:	e8 a9 e1 ff ff       	call   f01012c7 <page_alloc>
f010311e:	89 c6                	mov    %eax,%esi
f0103120:	83 c4 10             	add    $0x10,%esp
f0103123:	85 c0                	test   %eax,%eax
f0103125:	75 19                	jne    f0103140 <mem_init+0x1701>
f0103127:	68 81 7b 10 f0       	push   $0xf0107b81
f010312c:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0103131:	68 f8 04 00 00       	push   $0x4f8
f0103136:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0103168:	68 a0 6c 10 f0       	push   $0xf0106ca0
f010316d:	6a 56                	push   $0x56
f010316f:	68 61 7a 10 f0       	push   $0xf0107a61
f0103174:	e8 c7 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103179:	83 ec 04             	sub    $0x4,%esp
f010317c:	68 00 10 00 00       	push   $0x1000
f0103181:	6a 01                	push   $0x1
f0103183:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103188:	50                   	push   %eax
f0103189:	e8 26 2d 00 00       	call   f0105eb4 <memset>
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
f01031ad:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01031b2:	6a 56                	push   $0x56
f01031b4:	68 61 7a 10 f0       	push   $0xf0107a61
f01031b9:	e8 82 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031be:	83 ec 04             	sub    $0x4,%esp
f01031c1:	68 00 10 00 00       	push   $0x1000
f01031c6:	6a 02                	push   $0x2
f01031c8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031cd:	50                   	push   %eax
f01031ce:	e8 e1 2c 00 00       	call   f0105eb4 <memset>
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
f01031f0:	68 52 7c 10 f0       	push   $0xf0107c52
f01031f5:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01031fa:	68 fd 04 00 00       	push   $0x4fd
f01031ff:	68 55 7a 10 f0       	push   $0xf0107a55
f0103204:	e8 37 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103209:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103210:	01 01 01 
f0103213:	74 19                	je     f010322e <mem_init+0x17ef>
f0103215:	68 80 79 10 f0       	push   $0xf0107980
f010321a:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010321f:	68 fe 04 00 00       	push   $0x4fe
f0103224:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0103250:	68 a4 79 10 f0       	push   $0xf01079a4
f0103255:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010325a:	68 00 05 00 00       	push   $0x500
f010325f:	68 55 7a 10 f0       	push   $0xf0107a55
f0103264:	e8 d7 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103269:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010326e:	74 19                	je     f0103289 <mem_init+0x184a>
f0103270:	68 74 7c 10 f0       	push   $0xf0107c74
f0103275:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010327a:	68 01 05 00 00       	push   $0x501
f010327f:	68 55 7a 10 f0       	push   $0xf0107a55
f0103284:	e8 b7 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103289:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010328e:	74 19                	je     f01032a9 <mem_init+0x186a>
f0103290:	68 bd 7c 10 f0       	push   $0xf0107cbd
f0103295:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010329a:	68 02 05 00 00       	push   $0x502
f010329f:	68 55 7a 10 f0       	push   $0xf0107a55
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
f01032cf:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01032d4:	6a 56                	push   $0x56
f01032d6:	68 61 7a 10 f0       	push   $0xf0107a61
f01032db:	e8 60 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01032e0:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01032e7:	03 03 03 
f01032ea:	74 19                	je     f0103305 <mem_init+0x18c6>
f01032ec:	68 c8 79 10 f0       	push   $0xf01079c8
f01032f1:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01032f6:	68 04 05 00 00       	push   $0x504
f01032fb:	68 55 7a 10 f0       	push   $0xf0107a55
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
f0103322:	68 ac 7c 10 f0       	push   $0xf0107cac
f0103327:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010332c:	68 06 05 00 00       	push   $0x506
f0103331:	68 55 7a 10 f0       	push   $0xf0107a55
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
f010335b:	68 50 75 10 f0       	push   $0xf0107550
f0103360:	68 7b 7a 10 f0       	push   $0xf0107a7b
f0103365:	68 09 05 00 00       	push   $0x509
f010336a:	68 55 7a 10 f0       	push   $0xf0107a55
f010336f:	e8 cc cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103374:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010337a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010337f:	74 19                	je     f010339a <mem_init+0x195b>
f0103381:	68 63 7c 10 f0       	push   $0xf0107c63
f0103386:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010338b:	68 0b 05 00 00       	push   $0x50b
f0103390:	68 55 7a 10 f0       	push   $0xf0107a55
f0103395:	e8 a6 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010339a:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01033a0:	83 ec 0c             	sub    $0xc,%esp
f01033a3:	53                   	push   %ebx
f01033a4:	e8 8f e1 ff ff       	call   f0101538 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01033a9:	c7 04 24 f4 79 10 f0 	movl   $0xf01079f4,(%esp)
f01033b0:	e8 bd 0a 00 00       	call   f0103e72 <cprintf>
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
f01034d5:	68 20 7a 10 f0       	push   $0xf0107a20
f01034da:	e8 93 09 00 00       	call   f0103e72 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01034df:	89 1c 24             	mov    %ebx,(%esp)
f01034e2:	e8 83 06 00 00       	call   f0103b6a <env_destroy>
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
f010352b:	68 24 7e 10 f0       	push   $0xf0107e24
f0103530:	68 33 01 00 00       	push   $0x133
f0103535:	68 e9 7e 10 f0       	push   $0xf0107ee9
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
f0103555:	68 58 7e 10 f0       	push   $0xf0107e58
f010355a:	68 36 01 00 00       	push   $0x136
f010355f:	68 e9 7e 10 f0       	push   $0xf0107ee9
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
f010358d:	e8 9d 2f 00 00       	call   f010652f <cpunum>
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
f01035d9:	e8 51 2f 00 00       	call   f010652f <cpunum>
f01035de:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e1:	3b 98 28 20 24 f0    	cmp    -0xfdbdfd8(%eax),%ebx
f01035e7:	74 26                	je     f010360f <envid2env+0x8e>
f01035e9:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01035ec:	e8 3e 2f 00 00       	call   f010652f <cpunum>
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
f01036b4:	0f 84 70 01 00 00    	je     f010382a <env_alloc+0x185>
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
f01036c9:	0f 84 62 01 00 00    	je     f0103831 <env_alloc+0x18c>
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
f01036eb:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01036f0:	6a 56                	push   $0x56
f01036f2:	68 61 7a 10 f0       	push   $0xf0107a61
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
f0103733:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0103738:	68 cb 00 00 00       	push   $0xcb
f010373d:	68 e9 7e 10 f0       	push   $0xf0107ee9
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
f01037a5:	e8 0a 27 00 00       	call   f0105eb4 <memset>
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

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01037c9:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01037d0:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01037d7:	8b 43 44             	mov    0x44(%ebx),%eax
f01037da:	a3 70 12 24 f0       	mov    %eax,0xf0241270
	*newenv_store = e;
f01037df:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e2:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037e4:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01037e7:	e8 43 2d 00 00       	call   f010652f <cpunum>
f01037ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ef:	83 c4 10             	add    $0x10,%esp
f01037f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01037f7:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f01037fe:	74 11                	je     f0103811 <env_alloc+0x16c>
f0103800:	e8 2a 2d 00 00       	call   f010652f <cpunum>
f0103805:	6b c0 74             	imul   $0x74,%eax,%eax
f0103808:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f010380e:	8b 50 48             	mov    0x48(%eax),%edx
f0103811:	83 ec 04             	sub    $0x4,%esp
f0103814:	53                   	push   %ebx
f0103815:	52                   	push   %edx
f0103816:	68 f4 7e 10 f0       	push   $0xf0107ef4
f010381b:	e8 52 06 00 00       	call   f0103e72 <cprintf>
	return 0;
f0103820:	83 c4 10             	add    $0x10,%esp
f0103823:	b8 00 00 00 00       	mov    $0x0,%eax
f0103828:	eb 0c                	jmp    f0103836 <env_alloc+0x191>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010382a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010382f:	eb 05                	jmp    f0103836 <env_alloc+0x191>
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103831:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103839:	c9                   	leave  
f010383a:	c3                   	ret    

f010383b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010383b:	55                   	push   %ebp
f010383c:	89 e5                	mov    %esp,%ebp
f010383e:	57                   	push   %edi
f010383f:	56                   	push   %esi
f0103840:	53                   	push   %ebx
f0103841:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *env;
	int err = env_alloc(&env, 0);
f0103844:	6a 00                	push   $0x0
f0103846:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103849:	50                   	push   %eax
f010384a:	e8 56 fe ff ff       	call   f01036a5 <env_alloc>
	if (err) {
f010384f:	83 c4 10             	add    $0x10,%esp
f0103852:	85 c0                	test   %eax,%eax
f0103854:	74 3c                	je     f0103892 <env_create+0x57>
		if (err == -E_NO_MEM) {
f0103856:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0103859:	75 17                	jne    f0103872 <env_create+0x37>
			panic("env_create failed. env_alloc E_NO_MEM.\n");
f010385b:	83 ec 04             	sub    $0x4,%esp
f010385e:	68 94 7e 10 f0       	push   $0xf0107e94
f0103863:	68 a1 01 00 00       	push   $0x1a1
f0103868:	68 e9 7e 10 f0       	push   $0xf0107ee9
f010386d:	e8 ce c7 ff ff       	call   f0100040 <_panic>
		} else if (err == -E_NO_FREE_ENV) {
f0103872:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0103875:	0f 85 0c 01 00 00    	jne    f0103987 <env_create+0x14c>
			panic("env_create failed. env_alloc E_NO_FREE_ENV.\n");
f010387b:	83 ec 04             	sub    $0x4,%esp
f010387e:	68 bc 7e 10 f0       	push   $0xf0107ebc
f0103883:	68 a3 01 00 00       	push   $0x1a3
f0103888:	68 e9 7e 10 f0       	push   $0xf0107ee9
f010388d:	e8 ae c7 ff ff       	call   f0100040 <_panic>
		}
	} else {
		load_icode(env, binary, size);
f0103892:	8b 7d e4             	mov    -0x1c(%ebp),%edi

	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *ELFHDR = (struct Elf *) binary;

	if (ELFHDR->e_magic != ELF_MAGIC) {
f0103895:	8b 45 08             	mov    0x8(%ebp),%eax
f0103898:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010389e:	74 17                	je     f01038b7 <env_create+0x7c>
		panic("Invalid ELF.\n");
f01038a0:	83 ec 04             	sub    $0x4,%esp
f01038a3:	68 09 7f 10 f0       	push   $0xf0107f09
f01038a8:	68 77 01 00 00       	push   $0x177
f01038ad:	68 e9 7e 10 f0       	push   $0xf0107ee9
f01038b2:	e8 89 c7 ff ff       	call   f0100040 <_panic>
	}

	lcr3(PADDR(e->env_pgdir));
f01038b7:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038bf:	77 15                	ja     f01038d6 <env_create+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038c1:	50                   	push   %eax
f01038c2:	68 c4 6c 10 f0       	push   $0xf0106cc4
f01038c7:	68 7a 01 00 00       	push   $0x17a
f01038cc:	68 e9 7e 10 f0       	push   $0xf0107ee9
f01038d1:	e8 6a c7 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01038d6:	05 00 00 00 10       	add    $0x10000000,%eax
f01038db:	0f 22 d8             	mov    %eax,%cr3
	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
f01038de:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e1:	89 c3                	mov    %eax,%ebx
f01038e3:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
f01038e6:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f01038ea:	c1 e6 05             	shl    $0x5,%esi
f01038ed:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++) {
f01038ef:	39 f3                	cmp    %esi,%ebx
f01038f1:	73 48                	jae    f010393b <env_create+0x100>
		if (ph->p_type == ELF_PROG_LOAD) {
f01038f3:	83 3b 01             	cmpl   $0x1,(%ebx)
f01038f6:	75 3c                	jne    f0103934 <env_create+0xf9>
			// cprintf("mem = %d  file = %d\n", ph->p_memsz, ph->p_filesz);
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01038f8:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01038fb:	8b 53 08             	mov    0x8(%ebx),%edx
f01038fe:	89 f8                	mov    %edi,%eax
f0103900:	e8 ea fb ff ff       	call   f01034ef <region_alloc>
			// lcr3(PADDR(e->env_pgdir));
			memmove((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
f0103905:	83 ec 04             	sub    $0x4,%esp
f0103908:	ff 73 10             	pushl  0x10(%ebx)
f010390b:	8b 45 08             	mov    0x8(%ebp),%eax
f010390e:	03 43 04             	add    0x4(%ebx),%eax
f0103911:	50                   	push   %eax
f0103912:	ff 73 08             	pushl  0x8(%ebx)
f0103915:	e8 e7 25 00 00       	call   f0105f01 <memmove>
			memset((void *)(ph->p_va + ph->p_filesz), 0, (ph->p_memsz - ph->p_filesz));
f010391a:	8b 43 10             	mov    0x10(%ebx),%eax
f010391d:	83 c4 0c             	add    $0xc,%esp
f0103920:	8b 53 14             	mov    0x14(%ebx),%edx
f0103923:	29 c2                	sub    %eax,%edx
f0103925:	52                   	push   %edx
f0103926:	6a 00                	push   $0x0
f0103928:	03 43 08             	add    0x8(%ebx),%eax
f010392b:	50                   	push   %eax
f010392c:	e8 83 25 00 00       	call   f0105eb4 <memset>
f0103931:	83 c4 10             	add    $0x10,%esp
	}

	lcr3(PADDR(e->env_pgdir));
	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++) {
f0103934:	83 c3 20             	add    $0x20,%ebx
f0103937:	39 de                	cmp    %ebx,%esi
f0103939:	77 b8                	ja     f01038f3 <env_create+0xb8>
			memmove((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
			memset((void *)(ph->p_va + ph->p_filesz), 0, (ph->p_memsz - ph->p_filesz));
			// lcr3(PADDR(kern_pgdir));
		}
	}
	lcr3(PADDR(kern_pgdir));
f010393b:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103940:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103945:	77 15                	ja     f010395c <env_create+0x121>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103947:	50                   	push   %eax
f0103948:	68 c4 6c 10 f0       	push   $0xf0106cc4
f010394d:	68 87 01 00 00       	push   $0x187
f0103952:	68 e9 7e 10 f0       	push   $0xf0107ee9
f0103957:	e8 e4 c6 ff ff       	call   f0100040 <_panic>
f010395c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103961:	0f 22 d8             	mov    %eax,%cr3

	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103964:	8b 45 08             	mov    0x8(%ebp),%eax
f0103967:	8b 40 18             	mov    0x18(%eax),%eax
f010396a:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010396d:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103972:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103977:	89 f8                	mov    %edi,%eax
f0103979:	e8 71 fb ff ff       	call   f01034ef <region_alloc>
		} else if (err == -E_NO_FREE_ENV) {
			panic("env_create failed. env_alloc E_NO_FREE_ENV.\n");
		}
	} else {
		load_icode(env, binary, size);
		env->env_type = type;
f010397e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103981:	8b 55 10             	mov    0x10(%ebp),%edx
f0103984:	89 50 50             	mov    %edx,0x50(%eax)
		// cprintf("env_create  env_id = %d env_type = %d\n", env->env_id, env->env_type);
	}
}
f0103987:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010398a:	5b                   	pop    %ebx
f010398b:	5e                   	pop    %esi
f010398c:	5f                   	pop    %edi
f010398d:	5d                   	pop    %ebp
f010398e:	c3                   	ret    

f010398f <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010398f:	55                   	push   %ebp
f0103990:	89 e5                	mov    %esp,%ebp
f0103992:	57                   	push   %edi
f0103993:	56                   	push   %esi
f0103994:	53                   	push   %ebx
f0103995:	83 ec 1c             	sub    $0x1c,%esp
f0103998:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010399b:	e8 8f 2b 00 00       	call   f010652f <cpunum>
f01039a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01039a3:	39 b8 28 20 24 f0    	cmp    %edi,-0xfdbdfd8(%eax)
f01039a9:	75 29                	jne    f01039d4 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01039ab:	a1 ac 1e 24 f0       	mov    0xf0241eac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039b0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039b5:	77 15                	ja     f01039cc <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039b7:	50                   	push   %eax
f01039b8:	68 c4 6c 10 f0       	push   $0xf0106cc4
f01039bd:	68 ba 01 00 00       	push   $0x1ba
f01039c2:	68 e9 7e 10 f0       	push   $0xf0107ee9
f01039c7:	e8 74 c6 ff ff       	call   f0100040 <_panic>
f01039cc:	05 00 00 00 10       	add    $0x10000000,%eax
f01039d1:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01039d4:	8b 5f 48             	mov    0x48(%edi),%ebx
f01039d7:	e8 53 2b 00 00       	call   f010652f <cpunum>
f01039dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01039df:	ba 00 00 00 00       	mov    $0x0,%edx
f01039e4:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f01039eb:	74 11                	je     f01039fe <env_free+0x6f>
f01039ed:	e8 3d 2b 00 00       	call   f010652f <cpunum>
f01039f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01039f5:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01039fb:	8b 50 48             	mov    0x48(%eax),%edx
f01039fe:	83 ec 04             	sub    $0x4,%esp
f0103a01:	53                   	push   %ebx
f0103a02:	52                   	push   %edx
f0103a03:	68 17 7f 10 f0       	push   $0xf0107f17
f0103a08:	e8 65 04 00 00       	call   f0103e72 <cprintf>
f0103a0d:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103a10:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103a17:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103a1a:	89 d0                	mov    %edx,%eax
f0103a1c:	c1 e0 02             	shl    $0x2,%eax
f0103a1f:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103a22:	8b 47 64             	mov    0x64(%edi),%eax
f0103a25:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103a28:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103a2e:	0f 84 a8 00 00 00    	je     f0103adc <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103a34:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a3a:	89 f0                	mov    %esi,%eax
f0103a3c:	c1 e8 0c             	shr    $0xc,%eax
f0103a3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a42:	39 05 a8 1e 24 f0    	cmp    %eax,0xf0241ea8
f0103a48:	77 15                	ja     f0103a5f <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a4a:	56                   	push   %esi
f0103a4b:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0103a50:	68 c9 01 00 00       	push   $0x1c9
f0103a55:	68 e9 7e 10 f0       	push   $0xf0107ee9
f0103a5a:	e8 e1 c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a62:	c1 e0 16             	shl    $0x16,%eax
f0103a65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a68:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103a6d:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103a74:	01 
f0103a75:	74 17                	je     f0103a8e <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a77:	83 ec 08             	sub    $0x8,%esp
f0103a7a:	89 d8                	mov    %ebx,%eax
f0103a7c:	c1 e0 0c             	shl    $0xc,%eax
f0103a7f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103a82:	50                   	push   %eax
f0103a83:	ff 77 64             	pushl  0x64(%edi)
f0103a86:	e8 d5 de ff ff       	call   f0101960 <page_remove>
f0103a8b:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a8e:	83 c3 01             	add    $0x1,%ebx
f0103a91:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103a97:	75 d4                	jne    f0103a6d <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103a99:	8b 47 64             	mov    0x64(%edi),%eax
f0103a9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a9f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103aa6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103aa9:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f0103aaf:	72 14                	jb     f0103ac5 <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103ab1:	83 ec 04             	sub    $0x4,%esp
f0103ab4:	68 1c 74 10 f0       	push   $0xf010741c
f0103ab9:	6a 4f                	push   $0x4f
f0103abb:	68 61 7a 10 f0       	push   $0xf0107a61
f0103ac0:	e8 7b c5 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103ac5:	83 ec 0c             	sub    $0xc,%esp
f0103ac8:	a1 b0 1e 24 f0       	mov    0xf0241eb0,%eax
f0103acd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ad0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103ad3:	50                   	push   %eax
f0103ad4:	e8 7a dc ff ff       	call   f0101753 <page_decref>
f0103ad9:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103adc:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103ae0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ae3:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103ae8:	0f 85 29 ff ff ff    	jne    f0103a17 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103aee:	8b 47 64             	mov    0x64(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103af1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103af6:	77 15                	ja     f0103b0d <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103af8:	50                   	push   %eax
f0103af9:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0103afe:	68 d7 01 00 00       	push   $0x1d7
f0103b03:	68 e9 7e 10 f0       	push   $0xf0107ee9
f0103b08:	e8 33 c5 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103b0d:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b14:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b19:	c1 e8 0c             	shr    $0xc,%eax
f0103b1c:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f0103b22:	72 14                	jb     f0103b38 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103b24:	83 ec 04             	sub    $0x4,%esp
f0103b27:	68 1c 74 10 f0       	push   $0xf010741c
f0103b2c:	6a 4f                	push   $0x4f
f0103b2e:	68 61 7a 10 f0       	push   $0xf0107a61
f0103b33:	e8 08 c5 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103b38:	83 ec 0c             	sub    $0xc,%esp
f0103b3b:	8b 15 b0 1e 24 f0    	mov    0xf0241eb0,%edx
f0103b41:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103b44:	50                   	push   %eax
f0103b45:	e8 09 dc ff ff       	call   f0101753 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103b4a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103b51:	a1 70 12 24 f0       	mov    0xf0241270,%eax
f0103b56:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103b59:	89 3d 70 12 24 f0    	mov    %edi,0xf0241270
}
f0103b5f:	83 c4 10             	add    $0x10,%esp
f0103b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b65:	5b                   	pop    %ebx
f0103b66:	5e                   	pop    %esi
f0103b67:	5f                   	pop    %edi
f0103b68:	5d                   	pop    %ebp
f0103b69:	c3                   	ret    

f0103b6a <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103b6a:	55                   	push   %ebp
f0103b6b:	89 e5                	mov    %esp,%ebp
f0103b6d:	53                   	push   %ebx
f0103b6e:	83 ec 04             	sub    $0x4,%esp
f0103b71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103b74:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103b78:	75 19                	jne    f0103b93 <env_destroy+0x29>
f0103b7a:	e8 b0 29 00 00       	call   f010652f <cpunum>
f0103b7f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b82:	3b 98 28 20 24 f0    	cmp    -0xfdbdfd8(%eax),%ebx
f0103b88:	74 09                	je     f0103b93 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103b8a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103b91:	eb 33                	jmp    f0103bc6 <env_destroy+0x5c>
	}

	env_free(e);
f0103b93:	83 ec 0c             	sub    $0xc,%esp
f0103b96:	53                   	push   %ebx
f0103b97:	e8 f3 fd ff ff       	call   f010398f <env_free>

	if (curenv == e) {
f0103b9c:	e8 8e 29 00 00       	call   f010652f <cpunum>
f0103ba1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ba4:	83 c4 10             	add    $0x10,%esp
f0103ba7:	3b 98 28 20 24 f0    	cmp    -0xfdbdfd8(%eax),%ebx
f0103bad:	75 17                	jne    f0103bc6 <env_destroy+0x5c>
		curenv = NULL;
f0103baf:	e8 7b 29 00 00       	call   f010652f <cpunum>
f0103bb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bb7:	c7 80 28 20 24 f0 00 	movl   $0x0,-0xfdbdfd8(%eax)
f0103bbe:	00 00 00 
		sched_yield();
f0103bc1:	e8 18 0d 00 00       	call   f01048de <sched_yield>
	}
}
f0103bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103bc9:	c9                   	leave  
f0103bca:	c3                   	ret    

f0103bcb <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103bcb:	55                   	push   %ebp
f0103bcc:	89 e5                	mov    %esp,%ebp
f0103bce:	53                   	push   %ebx
f0103bcf:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103bd2:	e8 58 29 00 00       	call   f010652f <cpunum>
f0103bd7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bda:	8b 98 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%ebx
f0103be0:	e8 4a 29 00 00       	call   f010652f <cpunum>
f0103be5:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103be8:	8b 65 08             	mov    0x8(%ebp),%esp
f0103beb:	61                   	popa   
f0103bec:	07                   	pop    %es
f0103bed:	1f                   	pop    %ds
f0103bee:	83 c4 08             	add    $0x8,%esp
f0103bf1:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103bf2:	83 ec 04             	sub    $0x4,%esp
f0103bf5:	68 2d 7f 10 f0       	push   $0xf0107f2d
f0103bfa:	68 0d 02 00 00       	push   $0x20d
f0103bff:	68 e9 7e 10 f0       	push   $0xf0107ee9
f0103c04:	e8 37 c4 ff ff       	call   f0100040 <_panic>

f0103c09 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c09:	55                   	push   %ebp
f0103c0a:	89 e5                	mov    %esp,%ebp
f0103c0c:	53                   	push   %ebx
f0103c0d:	83 ec 04             	sub    $0x4,%esp
f0103c10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("env_run e->env_id = %d, CPU %d\n", e->env_id, cpunum());
	if (curenv != e) {
f0103c13:	e8 17 29 00 00       	call   f010652f <cpunum>
f0103c18:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c1b:	39 98 28 20 24 f0    	cmp    %ebx,-0xfdbdfd8(%eax)
f0103c21:	0f 84 a4 00 00 00    	je     f0103ccb <env_run+0xc2>
		if (curenv && curenv->env_status == ENV_RUNNING) {
f0103c27:	e8 03 29 00 00       	call   f010652f <cpunum>
f0103c2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c2f:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0103c36:	74 29                	je     f0103c61 <env_run+0x58>
f0103c38:	e8 f2 28 00 00       	call   f010652f <cpunum>
f0103c3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c40:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103c46:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103c4a:	75 15                	jne    f0103c61 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103c4c:	e8 de 28 00 00       	call   f010652f <cpunum>
f0103c51:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c54:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103c5a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		curenv = e;
f0103c61:	e8 c9 28 00 00       	call   f010652f <cpunum>
f0103c66:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c69:	89 98 28 20 24 f0    	mov    %ebx,-0xfdbdfd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0103c6f:	e8 bb 28 00 00       	call   f010652f <cpunum>
f0103c74:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c77:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103c7d:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0103c84:	e8 a6 28 00 00       	call   f010652f <cpunum>
f0103c89:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c8c:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103c92:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0103c96:	e8 94 28 00 00       	call   f010652f <cpunum>
f0103c9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c9e:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103ca4:	8b 40 64             	mov    0x64(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ca7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cac:	77 15                	ja     f0103cc3 <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cae:	50                   	push   %eax
f0103caf:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0103cb4:	68 33 02 00 00       	push   $0x233
f0103cb9:	68 e9 7e 10 f0       	push   $0xf0107ee9
f0103cbe:	e8 7d c3 ff ff       	call   f0100040 <_panic>
f0103cc3:	05 00 00 00 10       	add    $0x10000000,%eax
f0103cc8:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ccb:	83 ec 0c             	sub    $0xc,%esp
f0103cce:	68 a0 23 12 f0       	push   $0xf01223a0
f0103cd3:	e8 9a 2b 00 00       	call   f0106872 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103cd8:	f3 90                	pause  
	}

	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f0103cda:	e8 50 28 00 00       	call   f010652f <cpunum>
f0103cdf:	83 c4 04             	add    $0x4,%esp
f0103ce2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce5:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0103ceb:	e8 db fe ff ff       	call   f0103bcb <env_pop_tf>

f0103cf0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103cf0:	55                   	push   %ebp
f0103cf1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103cf3:	ba 70 00 00 00       	mov    $0x70,%edx
f0103cf8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cfb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103cfc:	ba 71 00 00 00       	mov    $0x71,%edx
f0103d01:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d02:	0f b6 c0             	movzbl %al,%eax
}
f0103d05:	5d                   	pop    %ebp
f0103d06:	c3                   	ret    

f0103d07 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d07:	55                   	push   %ebp
f0103d08:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d0a:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d12:	ee                   	out    %al,(%dx)
f0103d13:	ba 71 00 00 00       	mov    $0x71,%edx
f0103d18:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d1b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103d1c:	5d                   	pop    %ebp
f0103d1d:	c3                   	ret    

f0103d1e <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103d1e:	55                   	push   %ebp
f0103d1f:	89 e5                	mov    %esp,%ebp
f0103d21:	56                   	push   %esi
f0103d22:	53                   	push   %ebx
f0103d23:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103d26:	66 a3 88 23 12 f0    	mov    %ax,0xf0122388
	if (!didinit)
f0103d2c:	83 3d 74 12 24 f0 00 	cmpl   $0x0,0xf0241274
f0103d33:	74 5a                	je     f0103d8f <irq_setmask_8259A+0x71>
f0103d35:	89 c6                	mov    %eax,%esi
f0103d37:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d3c:	ee                   	out    %al,(%dx)
f0103d3d:	66 c1 e8 08          	shr    $0x8,%ax
f0103d41:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103d46:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103d47:	83 ec 0c             	sub    $0xc,%esp
f0103d4a:	68 39 7f 10 f0       	push   $0xf0107f39
f0103d4f:	e8 1e 01 00 00       	call   f0103e72 <cprintf>
f0103d54:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103d57:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103d5c:	0f b7 f6             	movzwl %si,%esi
f0103d5f:	f7 d6                	not    %esi
f0103d61:	0f a3 de             	bt     %ebx,%esi
f0103d64:	73 11                	jae    f0103d77 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103d66:	83 ec 08             	sub    $0x8,%esp
f0103d69:	53                   	push   %ebx
f0103d6a:	68 27 84 10 f0       	push   $0xf0108427
f0103d6f:	e8 fe 00 00 00       	call   f0103e72 <cprintf>
f0103d74:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103d77:	83 c3 01             	add    $0x1,%ebx
f0103d7a:	83 fb 10             	cmp    $0x10,%ebx
f0103d7d:	75 e2                	jne    f0103d61 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103d7f:	83 ec 0c             	sub    $0xc,%esp
f0103d82:	68 16 70 10 f0       	push   $0xf0107016
f0103d87:	e8 e6 00 00 00       	call   f0103e72 <cprintf>
f0103d8c:	83 c4 10             	add    $0x10,%esp
}
f0103d8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103d92:	5b                   	pop    %ebx
f0103d93:	5e                   	pop    %esi
f0103d94:	5d                   	pop    %ebp
f0103d95:	c3                   	ret    

f0103d96 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103d96:	c7 05 74 12 24 f0 01 	movl   $0x1,0xf0241274
f0103d9d:	00 00 00 
f0103da0:	ba 21 00 00 00       	mov    $0x21,%edx
f0103da5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103daa:	ee                   	out    %al,(%dx)
f0103dab:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103db0:	ee                   	out    %al,(%dx)
f0103db1:	ba 20 00 00 00       	mov    $0x20,%edx
f0103db6:	b8 11 00 00 00       	mov    $0x11,%eax
f0103dbb:	ee                   	out    %al,(%dx)
f0103dbc:	ba 21 00 00 00       	mov    $0x21,%edx
f0103dc1:	b8 20 00 00 00       	mov    $0x20,%eax
f0103dc6:	ee                   	out    %al,(%dx)
f0103dc7:	b8 04 00 00 00       	mov    $0x4,%eax
f0103dcc:	ee                   	out    %al,(%dx)
f0103dcd:	b8 03 00 00 00       	mov    $0x3,%eax
f0103dd2:	ee                   	out    %al,(%dx)
f0103dd3:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103dd8:	b8 11 00 00 00       	mov    $0x11,%eax
f0103ddd:	ee                   	out    %al,(%dx)
f0103dde:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103de3:	b8 28 00 00 00       	mov    $0x28,%eax
f0103de8:	ee                   	out    %al,(%dx)
f0103de9:	b8 02 00 00 00       	mov    $0x2,%eax
f0103dee:	ee                   	out    %al,(%dx)
f0103def:	b8 01 00 00 00       	mov    $0x1,%eax
f0103df4:	ee                   	out    %al,(%dx)
f0103df5:	ba 20 00 00 00       	mov    $0x20,%edx
f0103dfa:	b8 68 00 00 00       	mov    $0x68,%eax
f0103dff:	ee                   	out    %al,(%dx)
f0103e00:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e05:	ee                   	out    %al,(%dx)
f0103e06:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103e0b:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e10:	ee                   	out    %al,(%dx)
f0103e11:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e16:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103e17:	0f b7 05 88 23 12 f0 	movzwl 0xf0122388,%eax
f0103e1e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103e22:	74 13                	je     f0103e37 <pic_init+0xa1>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103e24:	55                   	push   %ebp
f0103e25:	89 e5                	mov    %esp,%ebp
f0103e27:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103e2a:	0f b7 c0             	movzwl %ax,%eax
f0103e2d:	50                   	push   %eax
f0103e2e:	e8 eb fe ff ff       	call   f0103d1e <irq_setmask_8259A>
f0103e33:	83 c4 10             	add    $0x10,%esp
}
f0103e36:	c9                   	leave  
f0103e37:	f3 c3                	repz ret 

f0103e39 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103e39:	55                   	push   %ebp
f0103e3a:	89 e5                	mov    %esp,%ebp
f0103e3c:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103e3f:	ff 75 08             	pushl  0x8(%ebp)
f0103e42:	e8 73 ca ff ff       	call   f01008ba <cputchar>
	*cnt++;
}
f0103e47:	83 c4 10             	add    $0x10,%esp
f0103e4a:	c9                   	leave  
f0103e4b:	c3                   	ret    

f0103e4c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e4c:	55                   	push   %ebp
f0103e4d:	89 e5                	mov    %esp,%ebp
f0103e4f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103e52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103e59:	ff 75 0c             	pushl  0xc(%ebp)
f0103e5c:	ff 75 08             	pushl  0x8(%ebp)
f0103e5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e62:	50                   	push   %eax
f0103e63:	68 39 3e 10 f0       	push   $0xf0103e39
f0103e68:	e8 39 18 00 00       	call   f01056a6 <vprintfmt>
	return cnt;
}
f0103e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e70:	c9                   	leave  
f0103e71:	c3                   	ret    

f0103e72 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103e72:	55                   	push   %ebp
f0103e73:	89 e5                	mov    %esp,%ebp
f0103e75:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103e78:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103e7b:	50                   	push   %eax
f0103e7c:	ff 75 08             	pushl  0x8(%ebp)
f0103e7f:	e8 c8 ff ff ff       	call   f0103e4c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103e84:	c9                   	leave  
f0103e85:	c3                   	ret    

f0103e86 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103e86:	55                   	push   %ebp
f0103e87:	89 e5                	mov    %esp,%ebp
f0103e89:	57                   	push   %edi
f0103e8a:	56                   	push   %esi
f0103e8b:	53                   	push   %ebx
f0103e8c:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int i = thiscpu->cpu_id;
f0103e8f:	e8 9b 26 00 00       	call   f010652f <cpunum>
f0103e94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e97:	0f b6 b0 20 20 24 f0 	movzbl -0xfdbdfe0(%eax),%esi
f0103e9e:	89 f0                	mov    %esi,%eax
f0103ea0:	0f b6 d8             	movzbl %al,%ebx

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103ea3:	e8 87 26 00 00       	call   f010652f <cpunum>
f0103ea8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eab:	89 d9                	mov    %ebx,%ecx
f0103ead:	c1 e1 10             	shl    $0x10,%ecx
f0103eb0:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0103eb5:	29 ca                	sub    %ecx,%edx
f0103eb7:	89 90 30 20 24 f0    	mov    %edx,-0xfdbdfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103ebd:	e8 6d 26 00 00       	call   f010652f <cpunum>
f0103ec2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ec5:	66 c7 80 34 20 24 f0 	movw   $0x10,-0xfdbdfcc(%eax)
f0103ecc:	10 00 

	extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
f0103ece:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ed3:	b8 08 00 00 00       	mov    $0x8,%eax
f0103ed8:	b9 74 01 00 00       	mov    $0x174,%ecx
f0103edd:	0f 30                	wrmsr  
  wrmsr(0x175, thiscpu->cpu_ts.ts_esp0, 0);
f0103edf:	e8 4b 26 00 00       	call   f010652f <cpunum>
f0103ee4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ee7:	8b 80 30 20 24 f0    	mov    -0xfdbdfd0(%eax),%eax
f0103eed:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ef2:	b9 75 01 00 00       	mov    $0x175,%ecx
f0103ef7:	0f 30                	wrmsr  
  wrmsr(0x176, sysenter_handler, 0);
f0103ef9:	b8 90 48 10 f0       	mov    $0xf0104890,%eax
f0103efe:	b9 76 01 00 00       	mov    $0x176,%ecx
f0103f03:	0f 30                	wrmsr  

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)(&thiscpu->cpu_ts),
f0103f05:	83 c3 05             	add    $0x5,%ebx
f0103f08:	e8 22 26 00 00       	call   f010652f <cpunum>
f0103f0d:	89 c7                	mov    %eax,%edi
f0103f0f:	e8 1b 26 00 00       	call   f010652f <cpunum>
f0103f14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f17:	e8 13 26 00 00       	call   f010652f <cpunum>
f0103f1c:	66 c7 04 dd 20 23 12 	movw   $0x68,-0xfeddce0(,%ebx,8)
f0103f23:	f0 68 00 
f0103f26:	6b ff 74             	imul   $0x74,%edi,%edi
f0103f29:	81 c7 2c 20 24 f0    	add    $0xf024202c,%edi
f0103f2f:	66 89 3c dd 22 23 12 	mov    %di,-0xfeddcde(,%ebx,8)
f0103f36:	f0 
f0103f37:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103f3b:	81 c2 2c 20 24 f0    	add    $0xf024202c,%edx
f0103f41:	c1 ea 10             	shr    $0x10,%edx
f0103f44:	88 14 dd 24 23 12 f0 	mov    %dl,-0xfeddcdc(,%ebx,8)
f0103f4b:	c6 04 dd 26 23 12 f0 	movb   $0x40,-0xfeddcda(,%ebx,8)
f0103f52:	40 
f0103f53:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f56:	05 2c 20 24 f0       	add    $0xf024202c,%eax
f0103f5b:	c1 e8 18             	shr    $0x18,%eax
f0103f5e:	88 04 dd 27 23 12 f0 	mov    %al,-0xfeddcd9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103f65:	c6 04 dd 25 23 12 f0 	movb   $0x89,-0xfeddcdb(,%ebx,8)
f0103f6c:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103f6d:	89 f0                	mov    %esi,%eax
f0103f6f:	0f b6 f0             	movzbl %al,%esi
f0103f72:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f0103f79:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103f7c:	b8 8c 23 12 f0       	mov    $0xf012238c,%eax
f0103f81:	0f 01 18             	lidtl  (%eax)

	ltr(GD_TSS0+(i << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f0103f84:	83 c4 1c             	add    $0x1c,%esp
f0103f87:	5b                   	pop    %ebx
f0103f88:	5e                   	pop    %esi
f0103f89:	5f                   	pop    %edi
f0103f8a:	5d                   	pop    %ebp
f0103f8b:	c3                   	ret    

f0103f8c <trap_init>:
}


void
trap_init(void)
{
f0103f8c:	55                   	push   %ebp
f0103f8d:	89 e5                	mov    %esp,%ebp
f0103f8f:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, _divide_error, 0);
f0103f92:	b8 26 48 10 f0       	mov    $0xf0104826,%eax
f0103f97:	66 a3 80 12 24 f0    	mov    %ax,0xf0241280
f0103f9d:	66 c7 05 82 12 24 f0 	movw   $0x8,0xf0241282
f0103fa4:	08 00 
f0103fa6:	c6 05 84 12 24 f0 00 	movb   $0x0,0xf0241284
f0103fad:	c6 05 85 12 24 f0 8e 	movb   $0x8e,0xf0241285
f0103fb4:	c1 e8 10             	shr    $0x10,%eax
f0103fb7:	66 a3 86 12 24 f0    	mov    %ax,0xf0241286
	SETGATE(idt[T_DEBUG], 0, GD_KT, _debug, 0);
f0103fbd:	b8 30 48 10 f0       	mov    $0xf0104830,%eax
f0103fc2:	66 a3 88 12 24 f0    	mov    %ax,0xf0241288
f0103fc8:	66 c7 05 8a 12 24 f0 	movw   $0x8,0xf024128a
f0103fcf:	08 00 
f0103fd1:	c6 05 8c 12 24 f0 00 	movb   $0x0,0xf024128c
f0103fd8:	c6 05 8d 12 24 f0 8e 	movb   $0x8e,0xf024128d
f0103fdf:	c1 e8 10             	shr    $0x10,%eax
f0103fe2:	66 a3 8e 12 24 f0    	mov    %ax,0xf024128e
	SETGATE(idt[T_NMI], 0, GD_KT, _non_maskable_interrupt, 0);
f0103fe8:	b8 3a 48 10 f0       	mov    $0xf010483a,%eax
f0103fed:	66 a3 90 12 24 f0    	mov    %ax,0xf0241290
f0103ff3:	66 c7 05 92 12 24 f0 	movw   $0x8,0xf0241292
f0103ffa:	08 00 
f0103ffc:	c6 05 94 12 24 f0 00 	movb   $0x0,0xf0241294
f0104003:	c6 05 95 12 24 f0 8e 	movb   $0x8e,0xf0241295
f010400a:	c1 e8 10             	shr    $0x10,%eax
f010400d:	66 a3 96 12 24 f0    	mov    %ax,0xf0241296
	SETGATE(idt[T_BRKPT], 0, GD_KT, _breakpoint, 3);
f0104013:	b8 44 48 10 f0       	mov    $0xf0104844,%eax
f0104018:	66 a3 98 12 24 f0    	mov    %ax,0xf0241298
f010401e:	66 c7 05 9a 12 24 f0 	movw   $0x8,0xf024129a
f0104025:	08 00 
f0104027:	c6 05 9c 12 24 f0 00 	movb   $0x0,0xf024129c
f010402e:	c6 05 9d 12 24 f0 ee 	movb   $0xee,0xf024129d
f0104035:	c1 e8 10             	shr    $0x10,%eax
f0104038:	66 a3 9e 12 24 f0    	mov    %ax,0xf024129e
	SETGATE(idt[T_OFLOW], 0, GD_KT, _overflow, 0);
f010403e:	b8 4a 48 10 f0       	mov    $0xf010484a,%eax
f0104043:	66 a3 a0 12 24 f0    	mov    %ax,0xf02412a0
f0104049:	66 c7 05 a2 12 24 f0 	movw   $0x8,0xf02412a2
f0104050:	08 00 
f0104052:	c6 05 a4 12 24 f0 00 	movb   $0x0,0xf02412a4
f0104059:	c6 05 a5 12 24 f0 8e 	movb   $0x8e,0xf02412a5
f0104060:	c1 e8 10             	shr    $0x10,%eax
f0104063:	66 a3 a6 12 24 f0    	mov    %ax,0xf02412a6
	SETGATE(idt[T_BOUND], 0, GD_KT, _bound_range_exceeded, 0);
f0104069:	b8 50 48 10 f0       	mov    $0xf0104850,%eax
f010406e:	66 a3 a8 12 24 f0    	mov    %ax,0xf02412a8
f0104074:	66 c7 05 aa 12 24 f0 	movw   $0x8,0xf02412aa
f010407b:	08 00 
f010407d:	c6 05 ac 12 24 f0 00 	movb   $0x0,0xf02412ac
f0104084:	c6 05 ad 12 24 f0 8e 	movb   $0x8e,0xf02412ad
f010408b:	c1 e8 10             	shr    $0x10,%eax
f010408e:	66 a3 ae 12 24 f0    	mov    %ax,0xf02412ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, _invalid_opcode, 0);
f0104094:	b8 56 48 10 f0       	mov    $0xf0104856,%eax
f0104099:	66 a3 b0 12 24 f0    	mov    %ax,0xf02412b0
f010409f:	66 c7 05 b2 12 24 f0 	movw   $0x8,0xf02412b2
f01040a6:	08 00 
f01040a8:	c6 05 b4 12 24 f0 00 	movb   $0x0,0xf02412b4
f01040af:	c6 05 b5 12 24 f0 8e 	movb   $0x8e,0xf02412b5
f01040b6:	c1 e8 10             	shr    $0x10,%eax
f01040b9:	66 a3 b6 12 24 f0    	mov    %ax,0xf02412b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, _device_not_available, 0);
f01040bf:	b8 5c 48 10 f0       	mov    $0xf010485c,%eax
f01040c4:	66 a3 b8 12 24 f0    	mov    %ax,0xf02412b8
f01040ca:	66 c7 05 ba 12 24 f0 	movw   $0x8,0xf02412ba
f01040d1:	08 00 
f01040d3:	c6 05 bc 12 24 f0 00 	movb   $0x0,0xf02412bc
f01040da:	c6 05 bd 12 24 f0 8e 	movb   $0x8e,0xf02412bd
f01040e1:	c1 e8 10             	shr    $0x10,%eax
f01040e4:	66 a3 be 12 24 f0    	mov    %ax,0xf02412be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, _double_fault, 0);
f01040ea:	b8 62 48 10 f0       	mov    $0xf0104862,%eax
f01040ef:	66 a3 c0 12 24 f0    	mov    %ax,0xf02412c0
f01040f5:	66 c7 05 c2 12 24 f0 	movw   $0x8,0xf02412c2
f01040fc:	08 00 
f01040fe:	c6 05 c4 12 24 f0 00 	movb   $0x0,0xf02412c4
f0104105:	c6 05 c5 12 24 f0 8e 	movb   $0x8e,0xf02412c5
f010410c:	c1 e8 10             	shr    $0x10,%eax
f010410f:	66 a3 c6 12 24 f0    	mov    %ax,0xf02412c6

	SETGATE(idt[T_TSS], 0, GD_KT, _invalid_tss, 0);
f0104115:	b8 66 48 10 f0       	mov    $0xf0104866,%eax
f010411a:	66 a3 d0 12 24 f0    	mov    %ax,0xf02412d0
f0104120:	66 c7 05 d2 12 24 f0 	movw   $0x8,0xf02412d2
f0104127:	08 00 
f0104129:	c6 05 d4 12 24 f0 00 	movb   $0x0,0xf02412d4
f0104130:	c6 05 d5 12 24 f0 8e 	movb   $0x8e,0xf02412d5
f0104137:	c1 e8 10             	shr    $0x10,%eax
f010413a:	66 a3 d6 12 24 f0    	mov    %ax,0xf02412d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, _segment_not_present, 0);
f0104140:	b8 6a 48 10 f0       	mov    $0xf010486a,%eax
f0104145:	66 a3 d8 12 24 f0    	mov    %ax,0xf02412d8
f010414b:	66 c7 05 da 12 24 f0 	movw   $0x8,0xf02412da
f0104152:	08 00 
f0104154:	c6 05 dc 12 24 f0 00 	movb   $0x0,0xf02412dc
f010415b:	c6 05 dd 12 24 f0 8e 	movb   $0x8e,0xf02412dd
f0104162:	c1 e8 10             	shr    $0x10,%eax
f0104165:	66 a3 de 12 24 f0    	mov    %ax,0xf02412de
	SETGATE(idt[T_STACK], 0, GD_KT, _stack_fault, 0);
f010416b:	b8 6e 48 10 f0       	mov    $0xf010486e,%eax
f0104170:	66 a3 e0 12 24 f0    	mov    %ax,0xf02412e0
f0104176:	66 c7 05 e2 12 24 f0 	movw   $0x8,0xf02412e2
f010417d:	08 00 
f010417f:	c6 05 e4 12 24 f0 00 	movb   $0x0,0xf02412e4
f0104186:	c6 05 e5 12 24 f0 8e 	movb   $0x8e,0xf02412e5
f010418d:	c1 e8 10             	shr    $0x10,%eax
f0104190:	66 a3 e6 12 24 f0    	mov    %ax,0xf02412e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, _general_protection, 0);
f0104196:	b8 72 48 10 f0       	mov    $0xf0104872,%eax
f010419b:	66 a3 e8 12 24 f0    	mov    %ax,0xf02412e8
f01041a1:	66 c7 05 ea 12 24 f0 	movw   $0x8,0xf02412ea
f01041a8:	08 00 
f01041aa:	c6 05 ec 12 24 f0 00 	movb   $0x0,0xf02412ec
f01041b1:	c6 05 ed 12 24 f0 8e 	movb   $0x8e,0xf02412ed
f01041b8:	c1 e8 10             	shr    $0x10,%eax
f01041bb:	66 a3 ee 12 24 f0    	mov    %ax,0xf02412ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, _page_fault, 0);
f01041c1:	b8 76 48 10 f0       	mov    $0xf0104876,%eax
f01041c6:	66 a3 f0 12 24 f0    	mov    %ax,0xf02412f0
f01041cc:	66 c7 05 f2 12 24 f0 	movw   $0x8,0xf02412f2
f01041d3:	08 00 
f01041d5:	c6 05 f4 12 24 f0 00 	movb   $0x0,0xf02412f4
f01041dc:	c6 05 f5 12 24 f0 8e 	movb   $0x8e,0xf02412f5
f01041e3:	c1 e8 10             	shr    $0x10,%eax
f01041e6:	66 a3 f6 12 24 f0    	mov    %ax,0xf02412f6

	SETGATE(idt[T_FPERR], 0, GD_KT, _x87_fpu_error, 0);
f01041ec:	b8 7a 48 10 f0       	mov    $0xf010487a,%eax
f01041f1:	66 a3 00 13 24 f0    	mov    %ax,0xf0241300
f01041f7:	66 c7 05 02 13 24 f0 	movw   $0x8,0xf0241302
f01041fe:	08 00 
f0104200:	c6 05 04 13 24 f0 00 	movb   $0x0,0xf0241304
f0104207:	c6 05 05 13 24 f0 8e 	movb   $0x8e,0xf0241305
f010420e:	c1 e8 10             	shr    $0x10,%eax
f0104211:	66 a3 06 13 24 f0    	mov    %ax,0xf0241306
	SETGATE(idt[T_ALIGN], 0, GD_KT, _alignment_check, 0);
f0104217:	b8 80 48 10 f0       	mov    $0xf0104880,%eax
f010421c:	66 a3 08 13 24 f0    	mov    %ax,0xf0241308
f0104222:	66 c7 05 0a 13 24 f0 	movw   $0x8,0xf024130a
f0104229:	08 00 
f010422b:	c6 05 0c 13 24 f0 00 	movb   $0x0,0xf024130c
f0104232:	c6 05 0d 13 24 f0 8e 	movb   $0x8e,0xf024130d
f0104239:	c1 e8 10             	shr    $0x10,%eax
f010423c:	66 a3 0e 13 24 f0    	mov    %ax,0xf024130e
	SETGATE(idt[T_MCHK], 0, GD_KT, _machine_check, 0);
f0104242:	b8 84 48 10 f0       	mov    $0xf0104884,%eax
f0104247:	66 a3 10 13 24 f0    	mov    %ax,0xf0241310
f010424d:	66 c7 05 12 13 24 f0 	movw   $0x8,0xf0241312
f0104254:	08 00 
f0104256:	c6 05 14 13 24 f0 00 	movb   $0x0,0xf0241314
f010425d:	c6 05 15 13 24 f0 8e 	movb   $0x8e,0xf0241315
f0104264:	c1 e8 10             	shr    $0x10,%eax
f0104267:	66 a3 16 13 24 f0    	mov    %ax,0xf0241316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, _simd_fp_exception, 0);
f010426d:	b8 8a 48 10 f0       	mov    $0xf010488a,%eax
f0104272:	66 a3 18 13 24 f0    	mov    %ax,0xf0241318
f0104278:	66 c7 05 1a 13 24 f0 	movw   $0x8,0xf024131a
f010427f:	08 00 
f0104281:	c6 05 1c 13 24 f0 00 	movb   $0x0,0xf024131c
f0104288:	c6 05 1d 13 24 f0 8e 	movb   $0x8e,0xf024131d
f010428f:	c1 e8 10             	shr    $0x10,%eax
f0104292:	66 a3 1e 13 24 f0    	mov    %ax,0xf024131e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall, 3);
f0104298:	b8 1f 4a 10 f0       	mov    $0xf0104a1f,%eax
f010429d:	66 a3 00 14 24 f0    	mov    %ax,0xf0241400
f01042a3:	66 c7 05 02 14 24 f0 	movw   $0x8,0xf0241402
f01042aa:	08 00 
f01042ac:	c6 05 04 14 24 f0 00 	movb   $0x0,0xf0241404
f01042b3:	c6 05 05 14 24 f0 ee 	movb   $0xee,0xf0241405
f01042ba:	c1 e8 10             	shr    $0x10,%eax
f01042bd:	66 a3 06 14 24 f0    	mov    %ax,0xf0241406

	extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
f01042c3:	ba 00 00 00 00       	mov    $0x0,%edx
f01042c8:	b8 08 00 00 00       	mov    $0x8,%eax
f01042cd:	b9 74 01 00 00       	mov    $0x174,%ecx
f01042d2:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP, 0);
f01042d4:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f01042d9:	b9 75 01 00 00       	mov    $0x175,%ecx
f01042de:	0f 30                	wrmsr  
	wrmsr(0x176, sysenter_handler, 0);
f01042e0:	b8 90 48 10 f0       	mov    $0xf0104890,%eax
f01042e5:	b9 76 01 00 00       	mov    $0x176,%ecx
f01042ea:	0f 30                	wrmsr  

	// Per-CPU setup
	trap_init_percpu();
f01042ec:	e8 95 fb ff ff       	call   f0103e86 <trap_init_percpu>
}
f01042f1:	c9                   	leave  
f01042f2:	c3                   	ret    

f01042f3 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01042f3:	55                   	push   %ebp
f01042f4:	89 e5                	mov    %esp,%ebp
f01042f6:	53                   	push   %ebx
f01042f7:	83 ec 0c             	sub    $0xc,%esp
f01042fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01042fd:	ff 33                	pushl  (%ebx)
f01042ff:	68 4d 7f 10 f0       	push   $0xf0107f4d
f0104304:	e8 69 fb ff ff       	call   f0103e72 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104309:	83 c4 08             	add    $0x8,%esp
f010430c:	ff 73 04             	pushl  0x4(%ebx)
f010430f:	68 5c 7f 10 f0       	push   $0xf0107f5c
f0104314:	e8 59 fb ff ff       	call   f0103e72 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104319:	83 c4 08             	add    $0x8,%esp
f010431c:	ff 73 08             	pushl  0x8(%ebx)
f010431f:	68 6b 7f 10 f0       	push   $0xf0107f6b
f0104324:	e8 49 fb ff ff       	call   f0103e72 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104329:	83 c4 08             	add    $0x8,%esp
f010432c:	ff 73 0c             	pushl  0xc(%ebx)
f010432f:	68 7a 7f 10 f0       	push   $0xf0107f7a
f0104334:	e8 39 fb ff ff       	call   f0103e72 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104339:	83 c4 08             	add    $0x8,%esp
f010433c:	ff 73 10             	pushl  0x10(%ebx)
f010433f:	68 89 7f 10 f0       	push   $0xf0107f89
f0104344:	e8 29 fb ff ff       	call   f0103e72 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104349:	83 c4 08             	add    $0x8,%esp
f010434c:	ff 73 14             	pushl  0x14(%ebx)
f010434f:	68 98 7f 10 f0       	push   $0xf0107f98
f0104354:	e8 19 fb ff ff       	call   f0103e72 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104359:	83 c4 08             	add    $0x8,%esp
f010435c:	ff 73 18             	pushl  0x18(%ebx)
f010435f:	68 a7 7f 10 f0       	push   $0xf0107fa7
f0104364:	e8 09 fb ff ff       	call   f0103e72 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104369:	83 c4 08             	add    $0x8,%esp
f010436c:	ff 73 1c             	pushl  0x1c(%ebx)
f010436f:	68 b6 7f 10 f0       	push   $0xf0107fb6
f0104374:	e8 f9 fa ff ff       	call   f0103e72 <cprintf>
}
f0104379:	83 c4 10             	add    $0x10,%esp
f010437c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010437f:	c9                   	leave  
f0104380:	c3                   	ret    

f0104381 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104381:	55                   	push   %ebp
f0104382:	89 e5                	mov    %esp,%ebp
f0104384:	56                   	push   %esi
f0104385:	53                   	push   %ebx
f0104386:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104389:	e8 a1 21 00 00       	call   f010652f <cpunum>
f010438e:	83 ec 04             	sub    $0x4,%esp
f0104391:	50                   	push   %eax
f0104392:	53                   	push   %ebx
f0104393:	68 1a 80 10 f0       	push   $0xf010801a
f0104398:	e8 d5 fa ff ff       	call   f0103e72 <cprintf>
	print_regs(&tf->tf_regs);
f010439d:	89 1c 24             	mov    %ebx,(%esp)
f01043a0:	e8 4e ff ff ff       	call   f01042f3 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01043a5:	83 c4 08             	add    $0x8,%esp
f01043a8:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01043ac:	50                   	push   %eax
f01043ad:	68 38 80 10 f0       	push   $0xf0108038
f01043b2:	e8 bb fa ff ff       	call   f0103e72 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01043b7:	83 c4 08             	add    $0x8,%esp
f01043ba:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01043be:	50                   	push   %eax
f01043bf:	68 4b 80 10 f0       	push   $0xf010804b
f01043c4:	e8 a9 fa ff ff       	call   f0103e72 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01043c9:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01043cc:	83 c4 10             	add    $0x10,%esp
f01043cf:	83 f8 13             	cmp    $0x13,%eax
f01043d2:	77 09                	ja     f01043dd <print_trapframe+0x5c>
		return excnames[trapno];
f01043d4:	8b 14 85 e0 82 10 f0 	mov    -0xfef7d20(,%eax,4),%edx
f01043db:	eb 1f                	jmp    f01043fc <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01043dd:	83 f8 30             	cmp    $0x30,%eax
f01043e0:	74 15                	je     f01043f7 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01043e2:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01043e5:	83 fa 10             	cmp    $0x10,%edx
f01043e8:	b9 e4 7f 10 f0       	mov    $0xf0107fe4,%ecx
f01043ed:	ba d1 7f 10 f0       	mov    $0xf0107fd1,%edx
f01043f2:	0f 43 d1             	cmovae %ecx,%edx
f01043f5:	eb 05                	jmp    f01043fc <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01043f7:	ba c5 7f 10 f0       	mov    $0xf0107fc5,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01043fc:	83 ec 04             	sub    $0x4,%esp
f01043ff:	52                   	push   %edx
f0104400:	50                   	push   %eax
f0104401:	68 5e 80 10 f0       	push   $0xf010805e
f0104406:	e8 67 fa ff ff       	call   f0103e72 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010440b:	83 c4 10             	add    $0x10,%esp
f010440e:	3b 1d 80 1a 24 f0    	cmp    0xf0241a80,%ebx
f0104414:	75 1a                	jne    f0104430 <print_trapframe+0xaf>
f0104416:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010441a:	75 14                	jne    f0104430 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010441c:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010441f:	83 ec 08             	sub    $0x8,%esp
f0104422:	50                   	push   %eax
f0104423:	68 70 80 10 f0       	push   $0xf0108070
f0104428:	e8 45 fa ff ff       	call   f0103e72 <cprintf>
f010442d:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0104430:	83 ec 08             	sub    $0x8,%esp
f0104433:	ff 73 2c             	pushl  0x2c(%ebx)
f0104436:	68 7f 80 10 f0       	push   $0xf010807f
f010443b:	e8 32 fa ff ff       	call   f0103e72 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104440:	83 c4 10             	add    $0x10,%esp
f0104443:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104447:	75 49                	jne    f0104492 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104449:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010444c:	89 c2                	mov    %eax,%edx
f010444e:	83 e2 01             	and    $0x1,%edx
f0104451:	ba fe 7f 10 f0       	mov    $0xf0107ffe,%edx
f0104456:	b9 f3 7f 10 f0       	mov    $0xf0107ff3,%ecx
f010445b:	0f 44 ca             	cmove  %edx,%ecx
f010445e:	89 c2                	mov    %eax,%edx
f0104460:	83 e2 02             	and    $0x2,%edx
f0104463:	ba 10 80 10 f0       	mov    $0xf0108010,%edx
f0104468:	be 0a 80 10 f0       	mov    $0xf010800a,%esi
f010446d:	0f 45 d6             	cmovne %esi,%edx
f0104470:	83 e0 04             	and    $0x4,%eax
f0104473:	be 63 81 10 f0       	mov    $0xf0108163,%esi
f0104478:	b8 15 80 10 f0       	mov    $0xf0108015,%eax
f010447d:	0f 44 c6             	cmove  %esi,%eax
f0104480:	51                   	push   %ecx
f0104481:	52                   	push   %edx
f0104482:	50                   	push   %eax
f0104483:	68 8d 80 10 f0       	push   $0xf010808d
f0104488:	e8 e5 f9 ff ff       	call   f0103e72 <cprintf>
f010448d:	83 c4 10             	add    $0x10,%esp
f0104490:	eb 10                	jmp    f01044a2 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104492:	83 ec 0c             	sub    $0xc,%esp
f0104495:	68 16 70 10 f0       	push   $0xf0107016
f010449a:	e8 d3 f9 ff ff       	call   f0103e72 <cprintf>
f010449f:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01044a2:	83 ec 08             	sub    $0x8,%esp
f01044a5:	ff 73 30             	pushl  0x30(%ebx)
f01044a8:	68 9c 80 10 f0       	push   $0xf010809c
f01044ad:	e8 c0 f9 ff ff       	call   f0103e72 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01044b2:	83 c4 08             	add    $0x8,%esp
f01044b5:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01044b9:	50                   	push   %eax
f01044ba:	68 ab 80 10 f0       	push   $0xf01080ab
f01044bf:	e8 ae f9 ff ff       	call   f0103e72 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01044c4:	83 c4 08             	add    $0x8,%esp
f01044c7:	ff 73 38             	pushl  0x38(%ebx)
f01044ca:	68 be 80 10 f0       	push   $0xf01080be
f01044cf:	e8 9e f9 ff ff       	call   f0103e72 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01044d4:	83 c4 10             	add    $0x10,%esp
f01044d7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01044db:	74 25                	je     f0104502 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01044dd:	83 ec 08             	sub    $0x8,%esp
f01044e0:	ff 73 3c             	pushl  0x3c(%ebx)
f01044e3:	68 cd 80 10 f0       	push   $0xf01080cd
f01044e8:	e8 85 f9 ff ff       	call   f0103e72 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01044ed:	83 c4 08             	add    $0x8,%esp
f01044f0:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01044f4:	50                   	push   %eax
f01044f5:	68 dc 80 10 f0       	push   $0xf01080dc
f01044fa:	e8 73 f9 ff ff       	call   f0103e72 <cprintf>
f01044ff:	83 c4 10             	add    $0x10,%esp
	}
}
f0104502:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104505:	5b                   	pop    %ebx
f0104506:	5e                   	pop    %esi
f0104507:	5d                   	pop    %ebp
f0104508:	c3                   	ret    

f0104509 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104509:	55                   	push   %ebp
f010450a:	89 e5                	mov    %esp,%ebp
f010450c:	57                   	push   %edi
f010450d:	56                   	push   %esi
f010450e:	53                   	push   %ebx
f010450f:	83 ec 0c             	sub    $0xc,%esp
f0104512:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104515:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (!(tf->tf_cs & 0x3)) {
f0104518:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010451c:	75 17                	jne    f0104535 <page_fault_handler+0x2c>
		panic("Kernel mode page fault.\n");
f010451e:	83 ec 04             	sub    $0x4,%esp
f0104521:	68 ef 80 10 f0       	push   $0xf01080ef
f0104526:	68 4e 01 00 00       	push   $0x14e
f010452b:	68 08 81 10 f0       	push   $0xf0108108
f0104530:	e8 0b bb ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// cprintf("curenv->env_pgfault_upcall: %x\n", curenv->env_pgfault_upcall);
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall) {
f0104535:	e8 f5 1f 00 00       	call   f010652f <cpunum>
f010453a:	6b c0 74             	imul   $0x74,%eax,%eax
f010453d:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104543:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f0104547:	0f 84 d4 00 00 00    	je     f0104621 <page_fault_handler+0x118>
		if (curenv->env_tf.tf_esp >= UXSTACKTOP - PGSIZE &&
f010454d:	e8 dd 1f 00 00       	call   f010652f <cpunum>
f0104552:	6b c0 74             	imul   $0x74,%eax,%eax
f0104555:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
			curenv->env_tf.tf_esp < UXSTACKTOP) {
			utf = (struct UTrapframe *)
						(curenv->env_tf.tf_esp - sizeof(struct UTrapframe) - 4);
		} else {
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f010455b:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi

	// LAB 4: Your code here.
	// cprintf("curenv->env_pgfault_upcall: %x\n", curenv->env_pgfault_upcall);
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall) {
		if (curenv->env_tf.tf_esp >= UXSTACKTOP - PGSIZE &&
f0104560:	81 78 3c ff ef bf ee 	cmpl   $0xeebfefff,0x3c(%eax)
f0104567:	76 2d                	jbe    f0104596 <page_fault_handler+0x8d>
			curenv->env_tf.tf_esp < UXSTACKTOP) {
f0104569:	e8 c1 1f 00 00       	call   f010652f <cpunum>
f010456e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104571:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax

	// LAB 4: Your code here.
	// cprintf("curenv->env_pgfault_upcall: %x\n", curenv->env_pgfault_upcall);
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall) {
		if (curenv->env_tf.tf_esp >= UXSTACKTOP - PGSIZE &&
f0104577:	81 78 3c ff ff bf ee 	cmpl   $0xeebfffff,0x3c(%eax)
f010457e:	77 16                	ja     f0104596 <page_fault_handler+0x8d>
			curenv->env_tf.tf_esp < UXSTACKTOP) {
			utf = (struct UTrapframe *)
						(curenv->env_tf.tf_esp - sizeof(struct UTrapframe) - 4);
f0104580:	e8 aa 1f 00 00       	call   f010652f <cpunum>
f0104585:	6b c0 74             	imul   $0x74,%eax,%eax
f0104588:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
	// cprintf("curenv->env_pgfault_upcall: %x\n", curenv->env_pgfault_upcall);
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall) {
		if (curenv->env_tf.tf_esp >= UXSTACKTOP - PGSIZE &&
			curenv->env_tf.tf_esp < UXSTACKTOP) {
			utf = (struct UTrapframe *)
f010458e:	8b 40 3c             	mov    0x3c(%eax),%eax
f0104591:	83 e8 38             	sub    $0x38,%eax
f0104594:	89 c7                	mov    %eax,%edi
						(curenv->env_tf.tf_esp - sizeof(struct UTrapframe) - 4);
		} else {
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W);
f0104596:	e8 94 1f 00 00       	call   f010652f <cpunum>
f010459b:	6a 02                	push   $0x2
f010459d:	6a 34                	push   $0x34
f010459f:	57                   	push   %edi
f01045a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a3:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f01045a9:	e8 f7 ee ff ff       	call   f01034a5 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f01045ae:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f01045b0:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01045b3:	89 fa                	mov    %edi,%edx
f01045b5:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f01045b8:	8d 7f 08             	lea    0x8(%edi),%edi
f01045bb:	b9 08 00 00 00       	mov    $0x8,%ecx
f01045c0:	89 de                	mov    %ebx,%esi
f01045c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01045c4:	8b 43 30             	mov    0x30(%ebx),%eax
f01045c7:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01045ca:	8b 43 38             	mov    0x38(%ebx),%eax
f01045cd:	89 d7                	mov    %edx,%edi
f01045cf:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01045d2:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01045d5:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_esp = (uint32_t)utf;
f01045d8:	e8 52 1f 00 00       	call   f010652f <cpunum>
f01045dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e0:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01045e6:	89 78 3c             	mov    %edi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f01045e9:	e8 41 1f 00 00       	call   f010652f <cpunum>
f01045ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f1:	8b 98 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%ebx
f01045f7:	e8 33 1f 00 00       	call   f010652f <cpunum>
f01045fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ff:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104605:	8b 40 68             	mov    0x68(%eax),%eax
f0104608:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f010460b:	e8 1f 1f 00 00       	call   f010652f <cpunum>
f0104610:	83 c4 04             	add    $0x4,%esp
f0104613:	6b c0 74             	imul   $0x74,%eax,%eax
f0104616:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f010461c:	e8 e8 f5 ff ff       	call   f0103c09 <env_run>
	} else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104621:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104624:	e8 06 1f 00 00       	call   f010652f <cpunum>
		curenv->env_tf.tf_esp = (uint32_t)utf;
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
		env_run(curenv);
	} else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104629:	57                   	push   %edi
f010462a:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f010462b:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv->env_tf.tf_esp = (uint32_t)utf;
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
		env_run(curenv);
	} else {
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010462e:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104634:	ff 70 48             	pushl  0x48(%eax)
f0104637:	68 b0 82 10 f0       	push   $0xf01082b0
f010463c:	e8 31 f8 ff ff       	call   f0103e72 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0104641:	89 1c 24             	mov    %ebx,(%esp)
f0104644:	e8 38 fd ff ff       	call   f0104381 <print_trapframe>
		env_destroy(curenv);
f0104649:	e8 e1 1e 00 00       	call   f010652f <cpunum>
f010464e:	83 c4 04             	add    $0x4,%esp
f0104651:	6b c0 74             	imul   $0x74,%eax,%eax
f0104654:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f010465a:	e8 0b f5 ff ff       	call   f0103b6a <env_destroy>
	}
}
f010465f:	83 c4 10             	add    $0x10,%esp
f0104662:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104665:	5b                   	pop    %ebx
f0104666:	5e                   	pop    %esi
f0104667:	5f                   	pop    %edi
f0104668:	5d                   	pop    %ebp
f0104669:	c3                   	ret    

f010466a <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010466a:	55                   	push   %ebp
f010466b:	89 e5                	mov    %esp,%ebp
f010466d:	57                   	push   %edi
f010466e:	56                   	push   %esi
f010466f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104672:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104673:	83 3d a0 1e 24 f0 00 	cmpl   $0x0,0xf0241ea0
f010467a:	74 01                	je     f010467d <trap+0x13>
		asm volatile("hlt");
f010467c:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010467d:	9c                   	pushf  
f010467e:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010467f:	f6 c4 02             	test   $0x2,%ah
f0104682:	74 19                	je     f010469d <trap+0x33>
f0104684:	68 14 81 10 f0       	push   $0xf0108114
f0104689:	68 7b 7a 10 f0       	push   $0xf0107a7b
f010468e:	68 18 01 00 00       	push   $0x118
f0104693:	68 08 81 10 f0       	push   $0xf0108108
f0104698:	e8 a3 b9 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010469d:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01046a1:	83 e0 03             	and    $0x3,%eax
f01046a4:	66 83 f8 03          	cmp    $0x3,%ax
f01046a8:	0f 85 a0 00 00 00    	jne    f010474e <trap+0xe4>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f01046ae:	e8 7c 1e 00 00       	call   f010652f <cpunum>
f01046b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b6:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f01046bd:	75 19                	jne    f01046d8 <trap+0x6e>
f01046bf:	68 2d 81 10 f0       	push   $0xf010812d
f01046c4:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01046c9:	68 1f 01 00 00       	push   $0x11f
f01046ce:	68 08 81 10 f0       	push   $0xf0108108
f01046d3:	e8 68 b9 ff ff       	call   f0100040 <_panic>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01046d8:	83 ec 0c             	sub    $0xc,%esp
f01046db:	68 a0 23 12 f0       	push   $0xf01223a0
f01046e0:	e8 b8 20 00 00       	call   f010679d <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01046e5:	e8 45 1e 00 00       	call   f010652f <cpunum>
f01046ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ed:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01046f3:	83 c4 10             	add    $0x10,%esp
f01046f6:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01046fa:	75 2d                	jne    f0104729 <trap+0xbf>
			env_free(curenv);
f01046fc:	e8 2e 1e 00 00       	call   f010652f <cpunum>
f0104701:	83 ec 0c             	sub    $0xc,%esp
f0104704:	6b c0 74             	imul   $0x74,%eax,%eax
f0104707:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f010470d:	e8 7d f2 ff ff       	call   f010398f <env_free>
			curenv = NULL;
f0104712:	e8 18 1e 00 00       	call   f010652f <cpunum>
f0104717:	6b c0 74             	imul   $0x74,%eax,%eax
f010471a:	c7 80 28 20 24 f0 00 	movl   $0x0,-0xfdbdfd8(%eax)
f0104721:	00 00 00 
			sched_yield();
f0104724:	e8 b5 01 00 00       	call   f01048de <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104729:	e8 01 1e 00 00       	call   f010652f <cpunum>
f010472e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104731:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104737:	b9 11 00 00 00       	mov    $0x11,%ecx
f010473c:	89 c7                	mov    %eax,%edi
f010473e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104740:	e8 ea 1d 00 00       	call   f010652f <cpunum>
f0104745:	6b c0 74             	imul   $0x74,%eax,%eax
f0104748:	8b b0 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010474e:	89 35 80 1a 24 f0    	mov    %esi,0xf0241a80
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
f0104754:	8b 46 28             	mov    0x28(%esi),%eax
f0104757:	83 f8 03             	cmp    $0x3,%eax
f010475a:	74 1a                	je     f0104776 <trap+0x10c>
f010475c:	83 f8 0e             	cmp    $0xe,%eax
f010475f:	74 07                	je     f0104768 <trap+0xfe>
f0104761:	83 f8 01             	cmp    $0x1,%eax
f0104764:	75 1c                	jne    f0104782 <trap+0x118>
f0104766:	eb 0e                	jmp    f0104776 <trap+0x10c>
		// case T_SYSCALL:
		// 	syscall_helper(tf);
		// 	break;
		case T_PGFLT:
			page_fault_handler(tf);
f0104768:	83 ec 0c             	sub    $0xc,%esp
f010476b:	56                   	push   %esi
f010476c:	e8 98 fd ff ff       	call   f0104509 <page_fault_handler>
f0104771:	83 c4 10             	add    $0x10,%esp
f0104774:	eb 0c                	jmp    f0104782 <trap+0x118>
			break;
		case T_DEBUG:
		case T_BRKPT:
			monitor(tf);
f0104776:	83 ec 0c             	sub    $0xc,%esp
f0104779:	56                   	push   %esi
f010477a:	e8 9f c4 ff ff       	call   f0100c1e <monitor>
f010477f:	83 c4 10             	add    $0x10,%esp
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104782:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f0104786:	75 1a                	jne    f01047a2 <trap+0x138>
		cprintf("Spurious interrupt on irq 7\n");
f0104788:	83 ec 0c             	sub    $0xc,%esp
f010478b:	68 34 81 10 f0       	push   $0xf0108134
f0104790:	e8 dd f6 ff ff       	call   f0103e72 <cprintf>
		print_trapframe(tf);
f0104795:	89 34 24             	mov    %esi,(%esp)
f0104798:	e8 e4 fb ff ff       	call   f0104381 <print_trapframe>
f010479d:	83 c4 10             	add    $0x10,%esp
f01047a0:	eb 43                	jmp    f01047e5 <trap+0x17b>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01047a2:	83 ec 0c             	sub    $0xc,%esp
f01047a5:	56                   	push   %esi
f01047a6:	e8 d6 fb ff ff       	call   f0104381 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01047ab:	83 c4 10             	add    $0x10,%esp
f01047ae:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01047b3:	75 17                	jne    f01047cc <trap+0x162>
		panic("unhandled trap in kernel");
f01047b5:	83 ec 04             	sub    $0x4,%esp
f01047b8:	68 51 81 10 f0       	push   $0xf0108151
f01047bd:	68 02 01 00 00       	push   $0x102
f01047c2:	68 08 81 10 f0       	push   $0xf0108108
f01047c7:	e8 74 b8 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01047cc:	e8 5e 1d 00 00       	call   f010652f <cpunum>
f01047d1:	83 ec 0c             	sub    $0xc,%esp
f01047d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d7:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f01047dd:	e8 88 f3 ff ff       	call   f0103b6a <env_destroy>
f01047e2:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01047e5:	e8 45 1d 00 00       	call   f010652f <cpunum>
f01047ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ed:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f01047f4:	74 2a                	je     f0104820 <trap+0x1b6>
f01047f6:	e8 34 1d 00 00       	call   f010652f <cpunum>
f01047fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01047fe:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104804:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104808:	75 16                	jne    f0104820 <trap+0x1b6>
		env_run(curenv);
f010480a:	e8 20 1d 00 00       	call   f010652f <cpunum>
f010480f:	83 ec 0c             	sub    $0xc,%esp
f0104812:	6b c0 74             	imul   $0x74,%eax,%eax
f0104815:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f010481b:	e8 e9 f3 ff ff       	call   f0103c09 <env_run>
	else
		sched_yield();
f0104820:	e8 b9 00 00 00       	call   f01048de <sched_yield>
f0104825:	90                   	nop

f0104826 <_divide_error>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
  TRAPHANDLER_NOEC(_divide_error, T_DIVIDE);
f0104826:	6a 00                	push   $0x0
f0104828:	6a 00                	push   $0x0
f010482a:	e9 95 00 00 00       	jmp    f01048c4 <_alltraps>
f010482f:	90                   	nop

f0104830 <_debug>:
  TRAPHANDLER_NOEC(_debug, T_DEBUG);
f0104830:	6a 00                	push   $0x0
f0104832:	6a 01                	push   $0x1
f0104834:	e9 8b 00 00 00       	jmp    f01048c4 <_alltraps>
f0104839:	90                   	nop

f010483a <_non_maskable_interrupt>:
  TRAPHANDLER_NOEC(_non_maskable_interrupt, T_NMI);
f010483a:	6a 00                	push   $0x0
f010483c:	6a 02                	push   $0x2
f010483e:	e9 81 00 00 00       	jmp    f01048c4 <_alltraps>
f0104843:	90                   	nop

f0104844 <_breakpoint>:
  TRAPHANDLER_NOEC(_breakpoint, T_BRKPT);
f0104844:	6a 00                	push   $0x0
f0104846:	6a 03                	push   $0x3
f0104848:	eb 7a                	jmp    f01048c4 <_alltraps>

f010484a <_overflow>:
  TRAPHANDLER_NOEC(_overflow, T_OFLOW);
f010484a:	6a 00                	push   $0x0
f010484c:	6a 04                	push   $0x4
f010484e:	eb 74                	jmp    f01048c4 <_alltraps>

f0104850 <_bound_range_exceeded>:
  TRAPHANDLER_NOEC(_bound_range_exceeded, T_BOUND);
f0104850:	6a 00                	push   $0x0
f0104852:	6a 05                	push   $0x5
f0104854:	eb 6e                	jmp    f01048c4 <_alltraps>

f0104856 <_invalid_opcode>:
  TRAPHANDLER_NOEC(_invalid_opcode, T_ILLOP);
f0104856:	6a 00                	push   $0x0
f0104858:	6a 06                	push   $0x6
f010485a:	eb 68                	jmp    f01048c4 <_alltraps>

f010485c <_device_not_available>:
  TRAPHANDLER_NOEC(_device_not_available, T_DEVICE);
f010485c:	6a 00                	push   $0x0
f010485e:	6a 07                	push   $0x7
f0104860:	eb 62                	jmp    f01048c4 <_alltraps>

f0104862 <_double_fault>:
  TRAPHANDLER(_double_fault, T_DBLFLT);
f0104862:	6a 08                	push   $0x8
f0104864:	eb 5e                	jmp    f01048c4 <_alltraps>

f0104866 <_invalid_tss>:

  TRAPHANDLER(_invalid_tss, T_TSS);
f0104866:	6a 0a                	push   $0xa
f0104868:	eb 5a                	jmp    f01048c4 <_alltraps>

f010486a <_segment_not_present>:
  TRAPHANDLER(_segment_not_present, T_SEGNP);
f010486a:	6a 0b                	push   $0xb
f010486c:	eb 56                	jmp    f01048c4 <_alltraps>

f010486e <_stack_fault>:
  TRAPHANDLER(_stack_fault, T_STACK);
f010486e:	6a 0c                	push   $0xc
f0104870:	eb 52                	jmp    f01048c4 <_alltraps>

f0104872 <_general_protection>:
  TRAPHANDLER(_general_protection, T_GPFLT);
f0104872:	6a 0d                	push   $0xd
f0104874:	eb 4e                	jmp    f01048c4 <_alltraps>

f0104876 <_page_fault>:
  TRAPHANDLER(_page_fault, T_PGFLT);
f0104876:	6a 0e                	push   $0xe
f0104878:	eb 4a                	jmp    f01048c4 <_alltraps>

f010487a <_x87_fpu_error>:

  TRAPHANDLER_NOEC(_x87_fpu_error, T_FPERR);
f010487a:	6a 00                	push   $0x0
f010487c:	6a 10                	push   $0x10
f010487e:	eb 44                	jmp    f01048c4 <_alltraps>

f0104880 <_alignment_check>:
  TRAPHANDLER(_alignment_check, T_ALIGN);
f0104880:	6a 11                	push   $0x11
f0104882:	eb 40                	jmp    f01048c4 <_alltraps>

f0104884 <_machine_check>:
  TRAPHANDLER_NOEC(_machine_check, T_MCHK);
f0104884:	6a 00                	push   $0x0
f0104886:	6a 12                	push   $0x12
f0104888:	eb 3a                	jmp    f01048c4 <_alltraps>

f010488a <_simd_fp_exception>:
  TRAPHANDLER_NOEC(_simd_fp_exception, T_SIMDERR );
f010488a:	6a 00                	push   $0x0
f010488c:	6a 13                	push   $0x13
f010488e:	eb 34                	jmp    f01048c4 <_alltraps>

f0104890 <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
   pushl $GD_UD | 3
f0104890:	6a 23                	push   $0x23
   pushl %ebp
f0104892:	55                   	push   %ebp
   pushfl
f0104893:	9c                   	pushf  
   pushl $GD_UT | 3
f0104894:	6a 1b                	push   $0x1b
   pushl %esi
f0104896:	56                   	push   %esi
   pushl $0
f0104897:	6a 00                	push   $0x0
 	 pushl $0
f0104899:	6a 00                	push   $0x0

   pushw $0    # uint16_t tf_padding2
f010489b:	66 6a 00             	pushw  $0x0
   pushw %ds
f010489e:	66 1e                	pushw  %ds
   pushw $0    # uint16_t tf_padding1
f01048a0:	66 6a 00             	pushw  $0x0
   pushw %es
f01048a3:	66 06                	pushw  %es
   pushal
f01048a5:	60                   	pusha  

   movw $GD_KD, %ax
f01048a6:	66 b8 10 00          	mov    $0x10,%ax
   movw %ax, %ds
f01048aa:	8e d8                	mov    %eax,%ds
   movw %ax, %es
f01048ac:	8e c0                	mov    %eax,%es
   pushl %esp
f01048ae:	54                   	push   %esp

   call syscall_helper
f01048af:	e8 ce 06 00 00       	call   f0104f82 <syscall_helper>

   popl %esp
f01048b4:	5c                   	pop    %esp
   popal
f01048b5:	61                   	popa   
   popw %cx  # eliminate padding
f01048b6:	66 59                	pop    %cx
   popw %es
f01048b8:	66 07                	popw   %es
   popw %cx  # eliminate padding
f01048ba:	66 59                	pop    %cx
   popw %ds
f01048bc:	66 1f                	popw   %ds

   movl %ebp, %ecx
f01048be:	89 e9                	mov    %ebp,%ecx
   movl %esi, %edx
f01048c0:	89 f2                	mov    %esi,%edx
   sysexit
f01048c2:	0f 35                	sysexit 

f01048c4 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
  pushw $0    # uint16_t tf_padding2
f01048c4:	66 6a 00             	pushw  $0x0
	pushw %ds
f01048c7:	66 1e                	pushw  %ds
	pushw $0    # uint16_t tf_padding1
f01048c9:	66 6a 00             	pushw  $0x0
	pushw %es
f01048cc:	66 06                	pushw  %es
	pushal
f01048ce:	60                   	pusha  

  movl $GD_KD, %eax
f01048cf:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f01048d4:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01048d6:	8e c0                	mov    %eax,%es
	pushl %esp
f01048d8:	54                   	push   %esp

	call trap
f01048d9:	e8 8c fd ff ff       	call   f010466a <trap>

f01048de <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01048de:	55                   	push   %ebp
f01048df:	89 e5                	mov    %esp,%ebp
f01048e1:	56                   	push   %esi
f01048e2:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
	// cprintf("CPU %d\n", cpunum());
	if (curenv) {
f01048e3:	e8 47 1c 00 00       	call   f010652f <cpunum>
f01048e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01048eb:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f01048f2:	0f 84 80 00 00 00    	je     f0104978 <sched_yield+0x9a>
		int cur_env_id = ENVX(curenv->env_id);
f01048f8:	e8 32 1c 00 00       	call   f010652f <cpunum>
f01048fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104900:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104906:	8b 50 48             	mov    0x48(%eax),%edx
f0104909:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
		for (i = (cur_env_id + 1) % NENV; i != cur_env_id; i = (i + 1) % NENV) {
f010490f:	8d 42 01             	lea    0x1(%edx),%eax
f0104912:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104917:	89 c6                	mov    %eax,%esi
f0104919:	39 c2                	cmp    %eax,%edx
f010491b:	0f 84 e1 00 00 00    	je     f0104a02 <sched_yield+0x124>
			if (envs[i].env_status == ENV_RUNNABLE &&
f0104921:	8b 0d 6c 12 24 f0    	mov    0xf024126c,%ecx
f0104927:	89 f3                	mov    %esi,%ebx
f0104929:	c1 e3 07             	shl    $0x7,%ebx
f010492c:	01 cb                	add    %ecx,%ebx
f010492e:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104932:	75 0f                	jne    f0104943 <sched_yield+0x65>
f0104934:	83 7b 50 01          	cmpl   $0x1,0x50(%ebx)
f0104938:	74 09                	je     f0104943 <sched_yield+0x65>
					envs[i].env_type != ENV_TYPE_IDLE) {
			  // cprintf("sched_yield CPU %d, i = %d\n", cpunum(), i);
				env_run(&envs[i]);
f010493a:	83 ec 0c             	sub    $0xc,%esp
f010493d:	53                   	push   %ebx
f010493e:	e8 c6 f2 ff ff       	call   f0103c09 <env_run>

	// LAB 4: Your code here.
	// cprintf("CPU %d\n", cpunum());
	if (curenv) {
		int cur_env_id = ENVX(curenv->env_id);
		for (i = (cur_env_id + 1) % NENV; i != cur_env_id; i = (i + 1) % NENV) {
f0104943:	8d 46 01             	lea    0x1(%esi),%eax
f0104946:	89 c3                	mov    %eax,%ebx
f0104948:	c1 fb 1f             	sar    $0x1f,%ebx
f010494b:	c1 eb 16             	shr    $0x16,%ebx
f010494e:	01 d8                	add    %ebx,%eax
f0104950:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104955:	29 d8                	sub    %ebx,%eax
f0104957:	89 c6                	mov    %eax,%esi
f0104959:	39 c2                	cmp    %eax,%edx
f010495b:	75 ca                	jne    f0104927 <sched_yield+0x49>
f010495d:	e9 a0 00 00 00       	jmp    f0104a02 <sched_yield+0x124>
				break;
			}
		}
		if (i == cur_env_id && curenv->env_status == ENV_RUNNING) {
			// cprintf("sched_yield CPU %d, i = %d\n", cpunum(), i);
			env_run(curenv);
f0104962:	e8 c8 1b 00 00       	call   f010652f <cpunum>
f0104967:	83 ec 0c             	sub    $0xc,%esp
f010496a:	6b c0 74             	imul   $0x74,%eax,%eax
f010496d:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104973:	e8 91 f2 ff ff       	call   f0103c09 <env_run>

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0104978:	8b 1d 6c 12 24 f0    	mov    0xf024126c,%ebx
f010497e:	8d 43 50             	lea    0x50(%ebx),%eax
	}

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104981:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f0104986:	83 38 01             	cmpl   $0x1,(%eax)
f0104989:	74 0b                	je     f0104996 <sched_yield+0xb8>
f010498b:	8b 70 04             	mov    0x4(%eax),%esi
f010498e:	8d 4e fe             	lea    -0x2(%esi),%ecx
f0104991:	83 f9 01             	cmp    $0x1,%ecx
f0104994:	76 10                	jbe    f01049a6 <sched_yield+0xc8>
	}

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104996:	83 c2 01             	add    $0x1,%edx
f0104999:	83 e8 80             	sub    $0xffffff80,%eax
f010499c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01049a2:	75 e2                	jne    f0104986 <sched_yield+0xa8>
f01049a4:	eb 08                	jmp    f01049ae <sched_yield+0xd0>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f01049a6:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01049ac:	75 1f                	jne    f01049cd <sched_yield+0xef>
		cprintf("No more runnable environments!\n");
f01049ae:	83 ec 0c             	sub    $0xc,%esp
f01049b1:	68 30 83 10 f0       	push   $0xf0108330
f01049b6:	e8 b7 f4 ff ff       	call   f0103e72 <cprintf>
f01049bb:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01049be:	83 ec 0c             	sub    $0xc,%esp
f01049c1:	6a 00                	push   $0x0
f01049c3:	e8 56 c2 ff ff       	call   f0100c1e <monitor>
f01049c8:	83 c4 10             	add    $0x10,%esp
f01049cb:	eb f1                	jmp    f01049be <sched_yield+0xe0>
	}
	// cprintf("sched_yield CPU %d, i = %d\n", cpunum(), i);

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f01049cd:	e8 5d 1b 00 00       	call   f010652f <cpunum>
f01049d2:	c1 e0 07             	shl    $0x7,%eax
f01049d5:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f01049d7:	8b 43 54             	mov    0x54(%ebx),%eax
f01049da:	83 e8 02             	sub    $0x2,%eax
f01049dd:	83 f8 01             	cmp    $0x1,%eax
f01049e0:	76 17                	jbe    f01049f9 <sched_yield+0x11b>
		panic("CPU %d: No idle environment!", cpunum());
f01049e2:	e8 48 1b 00 00       	call   f010652f <cpunum>
f01049e7:	50                   	push   %eax
f01049e8:	68 50 83 10 f0       	push   $0xf0108350
f01049ed:	6a 44                	push   $0x44
f01049ef:	68 6d 83 10 f0       	push   $0xf010836d
f01049f4:	e8 47 b6 ff ff       	call   f0100040 <_panic>
	env_run(idle);
f01049f9:	83 ec 0c             	sub    $0xc,%esp
f01049fc:	53                   	push   %ebx
f01049fd:	e8 07 f2 ff ff       	call   f0103c09 <env_run>
			  // cprintf("sched_yield CPU %d, i = %d\n", cpunum(), i);
				env_run(&envs[i]);
				break;
			}
		}
		if (i == cur_env_id && curenv->env_status == ENV_RUNNING) {
f0104a02:	e8 28 1b 00 00       	call   f010652f <cpunum>
f0104a07:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0a:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104a10:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a14:	0f 85 5e ff ff ff    	jne    f0104978 <sched_yield+0x9a>
f0104a1a:	e9 43 ff ff ff       	jmp    f0104962 <sched_yield+0x84>

f0104a1f <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104a1f:	55                   	push   %ebp
f0104a20:	89 e5                	mov    %esp,%ebp
f0104a22:	57                   	push   %edi
f0104a23:	56                   	push   %esi
f0104a24:	53                   	push   %ebx
f0104a25:	83 ec 2c             	sub    $0x2c,%esp
f0104a28:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int t;
	switch (syscallno) {
f0104a2b:	83 f8 0e             	cmp    $0xe,%eax
f0104a2e:	0f 87 3f 05 00 00    	ja     f0104f73 <syscall+0x554>
f0104a34:	ff 24 85 c4 83 10 f0 	jmp    *-0xfef7c3c(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, 0);
f0104a3b:	e8 ef 1a 00 00       	call   f010652f <cpunum>
f0104a40:	6a 00                	push   $0x0
f0104a42:	ff 75 10             	pushl  0x10(%ebp)
f0104a45:	ff 75 0c             	pushl  0xc(%ebp)
f0104a48:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a4b:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104a51:	e8 4f ea ff ff       	call   f01034a5 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104a56:	83 c4 0c             	add    $0xc,%esp
f0104a59:	ff 75 0c             	pushl  0xc(%ebp)
f0104a5c:	ff 75 10             	pushl  0x10(%ebp)
f0104a5f:	68 7a 83 10 f0       	push   $0xf010837a
f0104a64:	e8 09 f4 ff ff       	call   f0103e72 <cprintf>
f0104a69:	83 c4 10             	add    $0x10,%esp
	int t;
	switch (syscallno) {
		case SYS_cputs:
			// cprintf("SYS_cputs\n");
			sys_cputs((const char *) a1, a2);
			return 0;
f0104a6c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a71:	e9 02 05 00 00       	jmp    f0104f78 <syscall+0x559>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104a76:	e8 cc bc ff ff       	call   f0100747 <cons_getc>
f0104a7b:	89 c3                	mov    %eax,%ebx
			// cprintf("SYS_cputs\n");
			sys_cputs((const char *) a1, a2);
			return 0;
		case SYS_cgetc:
			// cprintf("SYS_cgetc\n");
			return sys_cgetc();
f0104a7d:	e9 f6 04 00 00       	jmp    f0104f78 <syscall+0x559>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104a82:	e8 a8 1a 00 00       	call   f010652f <cpunum>
f0104a87:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a8a:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104a90:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cgetc:
			// cprintf("SYS_cgetc\n");
			return sys_cgetc();
		case SYS_getenvid:
			// cprintf("SYS_getenvid\n");
			return sys_getenvid();
f0104a93:	e9 e0 04 00 00       	jmp    f0104f78 <syscall+0x559>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104a98:	83 ec 04             	sub    $0x4,%esp
f0104a9b:	6a 01                	push   $0x1
f0104a9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104aa0:	50                   	push   %eax
f0104aa1:	ff 75 0c             	pushl  0xc(%ebp)
f0104aa4:	e8 d8 ea ff ff       	call   f0103581 <envid2env>
f0104aa9:	83 c4 10             	add    $0x10,%esp
		return r;
f0104aac:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104aae:	85 c0                	test   %eax,%eax
f0104ab0:	0f 88 c2 04 00 00    	js     f0104f78 <syscall+0x559>
		return r;
	if (e == curenv)
f0104ab6:	e8 74 1a 00 00       	call   f010652f <cpunum>
f0104abb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104abe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac1:	39 90 28 20 24 f0    	cmp    %edx,-0xfdbdfd8(%eax)
f0104ac7:	75 23                	jne    f0104aec <syscall+0xcd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104ac9:	e8 61 1a 00 00       	call   f010652f <cpunum>
f0104ace:	83 ec 08             	sub    $0x8,%esp
f0104ad1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad4:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104ada:	ff 70 48             	pushl  0x48(%eax)
f0104add:	68 7f 83 10 f0       	push   $0xf010837f
f0104ae2:	e8 8b f3 ff ff       	call   f0103e72 <cprintf>
f0104ae7:	83 c4 10             	add    $0x10,%esp
f0104aea:	eb 25                	jmp    f0104b11 <syscall+0xf2>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104aec:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104aef:	e8 3b 1a 00 00       	call   f010652f <cpunum>
f0104af4:	83 ec 04             	sub    $0x4,%esp
f0104af7:	53                   	push   %ebx
f0104af8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104afb:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104b01:	ff 70 48             	pushl  0x48(%eax)
f0104b04:	68 9a 83 10 f0       	push   $0xf010839a
f0104b09:	e8 64 f3 ff ff       	call   f0103e72 <cprintf>
f0104b0e:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b11:	83 ec 0c             	sub    $0xc,%esp
f0104b14:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b17:	e8 4e f0 ff ff       	call   f0103b6a <env_destroy>
f0104b1c:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104b1f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b24:	e9 4f 04 00 00       	jmp    f0104f78 <syscall+0x559>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104b29:	81 7d 0c ff ff ff ef 	cmpl   $0xefffffff,0xc(%ebp)
f0104b30:	77 14                	ja     f0104b46 <syscall+0x127>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104b32:	ff 75 0c             	pushl  0xc(%ebp)
f0104b35:	68 c4 6c 10 f0       	push   $0xf0106cc4
f0104b3a:	6a 48                	push   $0x48
f0104b3c:	68 b2 83 10 f0       	push   $0xf01083b2
f0104b41:	e8 fa b4 ff ff       	call   f0100040 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104b46:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b49:	05 00 00 00 10       	add    $0x10000000,%eax
f0104b4e:	c1 e8 0c             	shr    $0xc,%eax
f0104b51:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f0104b57:	72 14                	jb     f0104b6d <syscall+0x14e>
		panic("pa2page called with invalid pa");
f0104b59:	83 ec 04             	sub    $0x4,%esp
f0104b5c:	68 1c 74 10 f0       	push   $0xf010741c
f0104b61:	6a 4f                	push   $0x4f
f0104b63:	68 61 7a 10 f0       	push   $0xf0107a61
f0104b68:	e8 d3 b4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104b6d:	8b 15 b0 1e 24 f0    	mov    0xf0241eb0,%edx
f0104b73:	8d 34 c2             	lea    (%edx,%eax,8),%esi
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p == NULL)
		return E_INVAL;
f0104b76:	bb 03 00 00 00       	mov    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p == NULL)
f0104b7b:	85 f6                	test   %esi,%esi
f0104b7d:	0f 84 f5 03 00 00    	je     f0104f78 <syscall+0x559>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0104b83:	e8 a7 19 00 00       	call   f010652f <cpunum>
f0104b88:	6a 06                	push   $0x6
f0104b8a:	ff 75 10             	pushl  0x10(%ebp)
f0104b8d:	56                   	push   %esi
f0104b8e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b91:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104b97:	ff 70 64             	pushl  0x64(%eax)
f0104b9a:	e8 0a ce ff ff       	call   f01019a9 <page_insert>
f0104b9f:	83 c4 10             	add    $0x10,%esp
	return r;
f0104ba2:	89 c3                	mov    %eax,%ebx
f0104ba4:	e9 cf 03 00 00       	jmp    f0104f78 <syscall+0x559>

static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_cur_brk + inc), inc);
f0104ba9:	e8 81 19 00 00       	call   f010652f <cpunum>
f0104bae:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb1:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104bb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bba:	03 58 60             	add    0x60(%eax),%ebx
f0104bbd:	e8 6d 19 00 00       	call   f010652f <cpunum>
f0104bc2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bc5:	8b b8 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%edi
}

static void
region_alloc(struct Env *e, void *va, size_t len)
{
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f0104bcb:	89 d8                	mov    %ebx,%eax
f0104bcd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104bd2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f0104bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104bd8:	8d b4 0b ff 0f 00 00 	lea    0xfff(%ebx,%ecx,1),%esi
f0104bdf:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0104be5:	39 f0                	cmp    %esi,%eax
f0104be7:	73 5e                	jae    f0104c47 <syscall+0x228>
f0104be9:	89 c3                	mov    %eax,%ebx
		if (!(tmp = page_alloc(0))) {
f0104beb:	83 ec 0c             	sub    $0xc,%esp
f0104bee:	6a 00                	push   $0x0
f0104bf0:	e8 d2 c6 ff ff       	call   f01012c7 <page_alloc>
f0104bf5:	83 c4 10             	add    $0x10,%esp
f0104bf8:	85 c0                	test   %eax,%eax
f0104bfa:	75 17                	jne    f0104c13 <syscall+0x1f4>
			panic("Execute region_alloc(...) failed. Out of memory.\n");
f0104bfc:	83 ec 04             	sub    $0x4,%esp
f0104bff:	68 24 7e 10 f0       	push   $0xf0107e24
f0104c04:	68 71 01 00 00       	push   $0x171
f0104c09:	68 b2 83 10 f0       	push   $0xf01083b2
f0104c0e:	e8 2d b4 ff ff       	call   f0100040 <_panic>
		} else {
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
f0104c13:	6a 06                	push   $0x6
f0104c15:	53                   	push   %ebx
f0104c16:	50                   	push   %eax
f0104c17:	ff 77 64             	pushl  0x64(%edi)
f0104c1a:	e8 8a cd ff ff       	call   f01019a9 <page_insert>
f0104c1f:	83 c4 10             	add    $0x10,%esp
f0104c22:	85 c0                	test   %eax,%eax
f0104c24:	74 17                	je     f0104c3d <syscall+0x21e>
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
f0104c26:	83 ec 04             	sub    $0x4,%esp
f0104c29:	68 58 7e 10 f0       	push   $0xf0107e58
f0104c2e:	68 74 01 00 00       	push   $0x174
f0104c33:	68 b2 83 10 f0       	push   $0xf01083b2
f0104c38:	e8 03 b4 ff ff       	call   f0100040 <_panic>
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0104c3d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104c43:	39 de                	cmp    %ebx,%esi
f0104c45:	77 a4                	ja     f0104beb <syscall+0x1cc>
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
			}
		}
	}
	e->env_cur_brk = start;
f0104c47:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104c4a:	89 47 60             	mov    %eax,0x60(%edi)
static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_cur_brk + inc), inc);
	return curenv->env_cur_brk;
f0104c4d:	e8 dd 18 00 00       	call   f010652f <cpunum>
f0104c52:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c55:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104c5b:	8b 58 60             	mov    0x60(%eax),%ebx
		case SYS_map_kernel_page:
			// cprintf("SYS_map_kernel_page\n");
			return sys_map_kernel_page((void *)a1, (void *)a2);
		case SYS_sbrk:
			// cprintf("SYS_sbrk\n");
			return sys_sbrk(a1);
f0104c5e:	e9 15 03 00 00       	jmp    f0104f78 <syscall+0x559>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104c63:	e8 76 fc ff ff       	call   f01048de <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *env;
	int err = env_alloc(&env, curenv->env_id);
f0104c68:	e8 c2 18 00 00       	call   f010652f <cpunum>
f0104c6d:	83 ec 08             	sub    $0x8,%esp
f0104c70:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c73:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104c79:	ff 70 48             	pushl  0x48(%eax)
f0104c7c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c7f:	50                   	push   %eax
f0104c80:	e8 20 ea ff ff       	call   f01036a5 <env_alloc>
	if (err) {
f0104c85:	83 c4 10             	add    $0x10,%esp
		return err;
f0104c88:	89 c3                	mov    %eax,%ebx
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *env;
	int err = env_alloc(&env, curenv->env_id);
	if (err) {
f0104c8a:	85 c0                	test   %eax,%eax
f0104c8c:	0f 85 e6 02 00 00    	jne    f0104f78 <syscall+0x559>
		return err;
	} else {
		env->env_status = ENV_NOT_RUNNABLE;
f0104c92:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c95:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
		env->env_tf = curenv->env_tf;
f0104c9c:	e8 8e 18 00 00       	call   f010652f <cpunum>
f0104ca1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca4:	8b b0 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%esi
f0104caa:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104caf:	89 df                	mov    %ebx,%edi
f0104cb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		env->env_tf.tf_regs.reg_eax = 0;
f0104cb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cb6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
		return env->env_id;
f0104cbd:	8b 58 48             	mov    0x48(%eax),%ebx
f0104cc0:	e9 b3 02 00 00       	jmp    f0104f78 <syscall+0x559>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *env;
	if (envid2env(envid, &env, 1)) {
f0104cc5:	83 ec 04             	sub    $0x4,%esp
f0104cc8:	6a 01                	push   $0x1
f0104cca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ccd:	50                   	push   %eax
f0104cce:	ff 75 0c             	pushl  0xc(%ebp)
f0104cd1:	e8 ab e8 ff ff       	call   f0103581 <envid2env>
f0104cd6:	89 c3                	mov    %eax,%ebx
f0104cd8:	83 c4 10             	add    $0x10,%esp
f0104cdb:	85 c0                	test   %eax,%eax
f0104cdd:	75 1b                	jne    f0104cfa <syscall+0x2db>
		return -E_BAD_ENV;
	} else if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f0104cdf:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ce2:	83 e8 02             	sub    $0x2,%eax
f0104ce5:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104cea:	75 18                	jne    f0104d04 <syscall+0x2e5>
		return -E_INVAL;
	} else {
		env->env_status = status;
f0104cec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104cf2:	89 48 54             	mov    %ecx,0x54(%eax)
f0104cf5:	e9 7e 02 00 00       	jmp    f0104f78 <syscall+0x559>
	// envid's status.

	// LAB 4: Your code here.
	struct Env *env;
	if (envid2env(envid, &env, 1)) {
		return -E_BAD_ENV;
f0104cfa:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104cff:	e9 74 02 00 00       	jmp    f0104f78 <syscall+0x559>
	} else if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
		return -E_INVAL;
f0104d04:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_exofork:
			// cprintf("SYS_exofork\n");
			return sys_exofork();
		case SYS_env_set_status:
			// cprintf("SYS_env_set_status\n");
			return sys_env_set_status((envid_t)a1, (int)a2);
f0104d09:	e9 6a 02 00 00       	jmp    f0104f78 <syscall+0x559>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if (va >= (void *)UTOP || (perm & 0x5) != 0x5 ||
f0104d0e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d15:	77 7d                	ja     f0104d94 <syscall+0x375>
f0104d17:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d1a:	83 e0 05             	and    $0x5,%eax
f0104d1d:	83 f8 05             	cmp    $0x5,%eax
f0104d20:	75 7c                	jne    f0104d9e <syscall+0x37f>
f0104d22:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d29:	75 7d                	jne    f0104da8 <syscall+0x389>
			PGOFF(va) || (perm & (~PTE_SYSCALL)))
f0104d2b:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104d2e:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104d34:	75 7c                	jne    f0104db2 <syscall+0x393>
		return -E_INVAL;

	struct Env *env;
	int r = envid2env(envid, &env, 1);
f0104d36:	83 ec 04             	sub    $0x4,%esp
f0104d39:	6a 01                	push   $0x1
f0104d3b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d3e:	50                   	push   %eax
f0104d3f:	ff 75 0c             	pushl  0xc(%ebp)
f0104d42:	e8 3a e8 ff ff       	call   f0103581 <envid2env>
	if (r < 0) {
f0104d47:	83 c4 10             	add    $0x10,%esp
f0104d4a:	85 c0                	test   %eax,%eax
f0104d4c:	78 6e                	js     f0104dbc <syscall+0x39d>
		return -E_BAD_ENV;
	}

	struct Page *new_page = page_alloc(ALLOC_ZERO);
f0104d4e:	83 ec 0c             	sub    $0xc,%esp
f0104d51:	6a 01                	push   $0x1
f0104d53:	e8 6f c5 ff ff       	call   f01012c7 <page_alloc>
f0104d58:	89 c6                	mov    %eax,%esi
	if (!new_page) {
f0104d5a:	83 c4 10             	add    $0x10,%esp
f0104d5d:	85 c0                	test   %eax,%eax
f0104d5f:	74 65                	je     f0104dc6 <syscall+0x3a7>
		return -E_NO_MEM;
	}

	r = page_insert(env->env_pgdir, new_page, va, perm);
f0104d61:	ff 75 14             	pushl  0x14(%ebp)
f0104d64:	ff 75 10             	pushl  0x10(%ebp)
f0104d67:	50                   	push   %eax
f0104d68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d6b:	ff 70 64             	pushl  0x64(%eax)
f0104d6e:	e8 36 cc ff ff       	call   f01019a9 <page_insert>
	if (r) {
f0104d73:	83 c4 10             	add    $0x10,%esp
f0104d76:	85 c0                	test   %eax,%eax
f0104d78:	0f 84 fa 01 00 00    	je     f0104f78 <syscall+0x559>
		page_free(new_page);
f0104d7e:	83 ec 0c             	sub    $0xc,%esp
f0104d81:	56                   	push   %esi
f0104d82:	e8 b1 c7 ff ff       	call   f0101538 <page_free>
f0104d87:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104d8a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104d8f:	e9 e4 01 00 00       	jmp    f0104f78 <syscall+0x559>
	//   allocated!

	// LAB 4: Your code here.
	if (va >= (void *)UTOP || (perm & 0x5) != 0x5 ||
			PGOFF(va) || (perm & (~PTE_SYSCALL)))
		return -E_INVAL;
f0104d94:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d99:	e9 da 01 00 00       	jmp    f0104f78 <syscall+0x559>
f0104d9e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104da3:	e9 d0 01 00 00       	jmp    f0104f78 <syscall+0x559>
f0104da8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dad:	e9 c6 01 00 00       	jmp    f0104f78 <syscall+0x559>
f0104db2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104db7:	e9 bc 01 00 00       	jmp    f0104f78 <syscall+0x559>

	struct Env *env;
	int r = envid2env(envid, &env, 1);
	if (r < 0) {
		return -E_BAD_ENV;
f0104dbc:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104dc1:	e9 b2 01 00 00       	jmp    f0104f78 <syscall+0x559>
	}

	struct Page *new_page = page_alloc(ALLOC_ZERO);
	if (!new_page) {
		return -E_NO_MEM;
f0104dc6:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		case SYS_env_set_status:
			// cprintf("SYS_env_set_status\n");
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
			// cprintf("SYS_page_alloc\n");
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104dcb:	e9 a8 01 00 00       	jmp    f0104f78 <syscall+0x559>
		case SYS_page_map:
			// cprintf("SYS_page_map\n");
			return sys_page_map((envid_t)*((uint32_t *)a1),
f0104dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dd3:	8b 58 10             	mov    0x10(%eax),%ebx
													(void *)*((uint32_t *)a1 + 1),
													(envid_t)*((uint32_t *)a1 + 2),
													(void *)*((uint32_t *)a1 + 3),
f0104dd6:	8b 70 0c             	mov    0xc(%eax),%esi
			// cprintf("SYS_page_alloc\n");
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_page_map:
			// cprintf("SYS_page_map\n");
			return sys_page_map((envid_t)*((uint32_t *)a1),
													(void *)*((uint32_t *)a1 + 1),
f0104dd9:	8b 78 04             	mov    0x4(%eax),%edi
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || (perm & 0x5) != 0x5 ||
f0104ddc:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104de2:	0f 87 b8 00 00 00    	ja     f0104ea0 <syscall+0x481>
f0104de8:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104dee:	0f 87 ac 00 00 00    	ja     f0104ea0 <syscall+0x481>
f0104df4:	89 d8                	mov    %ebx,%eax
f0104df6:	83 e0 05             	and    $0x5,%eax
f0104df9:	83 f8 05             	cmp    $0x5,%eax
f0104dfc:	0f 85 a8 00 00 00    	jne    f0104eaa <syscall+0x48b>
			PGOFF(srcva) || PGOFF(dstva) || (perm & (~PTE_SYSCALL)))
f0104e02:	89 f0                	mov    %esi,%eax
f0104e04:	09 f8                	or     %edi,%eax
f0104e06:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104e0b:	0f 85 a3 00 00 00    	jne    f0104eb4 <syscall+0x495>
f0104e11:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
f0104e17:	0f 85 a1 00 00 00    	jne    f0104ebe <syscall+0x49f>
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_page_map:
			// cprintf("SYS_page_map\n");
			return sys_page_map((envid_t)*((uint32_t *)a1),
													(void *)*((uint32_t *)a1 + 1),
													(envid_t)*((uint32_t *)a1 + 2),
f0104e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e20:	8b 40 08             	mov    0x8(%eax),%eax
f0104e23:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || (perm & 0x5) != 0x5 ||
			PGOFF(srcva) || PGOFF(dstva) || (perm & (~PTE_SYSCALL)))
		return -E_INVAL;

	struct Env *src_env, *dst_env;
	envid2env(srcenvid, &src_env, 1);
f0104e26:	83 ec 04             	sub    $0x4,%esp
f0104e29:	6a 01                	push   $0x1
f0104e2b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e2e:	50                   	push   %eax
f0104e2f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e32:	ff 32                	pushl  (%edx)
f0104e34:	e8 48 e7 ff ff       	call   f0103581 <envid2env>
	envid2env(dstenvid, &dst_env, 1);
f0104e39:	83 c4 0c             	add    $0xc,%esp
f0104e3c:	6a 01                	push   $0x1
f0104e3e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e41:	50                   	push   %eax
f0104e42:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104e45:	e8 37 e7 ff ff       	call   f0103581 <envid2env>
	if (!src_env || !dst_env) {
f0104e4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e4d:	83 c4 10             	add    $0x10,%esp
f0104e50:	85 c0                	test   %eax,%eax
f0104e52:	74 74                	je     f0104ec8 <syscall+0x4a9>
f0104e54:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104e58:	74 78                	je     f0104ed2 <syscall+0x4b3>
		return -E_BAD_ENV;
	}

	pte_t *pte;
	struct Page *page = page_lookup(src_env->env_pgdir, srcva, &pte);
f0104e5a:	83 ec 04             	sub    $0x4,%esp
f0104e5d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e60:	52                   	push   %edx
f0104e61:	57                   	push   %edi
f0104e62:	ff 70 64             	pushl  0x64(%eax)
f0104e65:	e8 5b ca ff ff       	call   f01018c5 <page_lookup>
	if (!page || (!(*pte & PTE_W) && (perm & PTE_W))) {
f0104e6a:	83 c4 10             	add    $0x10,%esp
f0104e6d:	85 c0                	test   %eax,%eax
f0104e6f:	74 6b                	je     f0104edc <syscall+0x4bd>
f0104e71:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e74:	f6 02 02             	testb  $0x2,(%edx)
f0104e77:	75 05                	jne    f0104e7e <syscall+0x45f>
f0104e79:	f6 c3 02             	test   $0x2,%bl
f0104e7c:	75 68                	jne    f0104ee6 <syscall+0x4c7>
		return -E_INVAL;
	}

	if (page_insert(dst_env->env_pgdir, page, dstva, perm)) {
f0104e7e:	53                   	push   %ebx
f0104e7f:	56                   	push   %esi
f0104e80:	50                   	push   %eax
f0104e81:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e84:	ff 70 64             	pushl  0x64(%eax)
f0104e87:	e8 1d cb ff ff       	call   f01019a9 <page_insert>
f0104e8c:	89 c3                	mov    %eax,%ebx
f0104e8e:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104e91:	85 c0                	test   %eax,%eax
f0104e93:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104e98:	0f 45 d8             	cmovne %eax,%ebx
f0104e9b:	e9 d8 00 00 00       	jmp    f0104f78 <syscall+0x559>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || (perm & 0x5) != 0x5 ||
			PGOFF(srcva) || PGOFF(dstva) || (perm & (~PTE_SYSCALL)))
		return -E_INVAL;
f0104ea0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ea5:	e9 ce 00 00 00       	jmp    f0104f78 <syscall+0x559>
f0104eaa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104eaf:	e9 c4 00 00 00       	jmp    f0104f78 <syscall+0x559>
f0104eb4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104eb9:	e9 ba 00 00 00       	jmp    f0104f78 <syscall+0x559>
f0104ebe:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ec3:	e9 b0 00 00 00       	jmp    f0104f78 <syscall+0x559>

	struct Env *src_env, *dst_env;
	envid2env(srcenvid, &src_env, 1);
	envid2env(dstenvid, &dst_env, 1);
	if (!src_env || !dst_env) {
		return -E_BAD_ENV;
f0104ec8:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104ecd:	e9 a6 00 00 00       	jmp    f0104f78 <syscall+0x559>
f0104ed2:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104ed7:	e9 9c 00 00 00       	jmp    f0104f78 <syscall+0x559>
	}

	pte_t *pte;
	struct Page *page = page_lookup(src_env->env_pgdir, srcva, &pte);
	if (!page || (!(*pte & PTE_W) && (perm & PTE_W))) {
		return -E_INVAL;
f0104edc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ee1:	e9 92 00 00 00       	jmp    f0104f78 <syscall+0x559>
f0104ee6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104eeb:	e9 88 00 00 00       	jmp    f0104f78 <syscall+0x559>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va >= (void *)UTOP || PGOFF(va))
f0104ef0:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104ef7:	77 39                	ja     f0104f32 <syscall+0x513>
f0104ef9:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f00:	75 37                	jne    f0104f39 <syscall+0x51a>
		return -E_INVAL;

	struct Env *env;
	if (envid2env(envid, &env, 1)) {
f0104f02:	83 ec 04             	sub    $0x4,%esp
f0104f05:	6a 01                	push   $0x1
f0104f07:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f0a:	50                   	push   %eax
f0104f0b:	ff 75 0c             	pushl  0xc(%ebp)
f0104f0e:	e8 6e e6 ff ff       	call   f0103581 <envid2env>
f0104f13:	89 c3                	mov    %eax,%ebx
f0104f15:	83 c4 10             	add    $0x10,%esp
f0104f18:	85 c0                	test   %eax,%eax
f0104f1a:	75 24                	jne    f0104f40 <syscall+0x521>
		return -E_BAD_ENV;
	}

	page_remove(env->env_pgdir, va);
f0104f1c:	83 ec 08             	sub    $0x8,%esp
f0104f1f:	ff 75 10             	pushl  0x10(%ebp)
f0104f22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f25:	ff 70 64             	pushl  0x64(%eax)
f0104f28:	e8 33 ca ff ff       	call   f0101960 <page_remove>
f0104f2d:	83 c4 10             	add    $0x10,%esp
f0104f30:	eb 46                	jmp    f0104f78 <syscall+0x559>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va >= (void *)UTOP || PGOFF(va))
		return -E_INVAL;
f0104f32:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f37:	eb 3f                	jmp    f0104f78 <syscall+0x559>
f0104f39:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f3e:	eb 38                	jmp    f0104f78 <syscall+0x559>

	struct Env *env;
	if (envid2env(envid, &env, 1)) {
		return -E_BAD_ENV;
f0104f40:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
													(envid_t)*((uint32_t *)a1 + 2),
													(void *)*((uint32_t *)a1 + 3),
													(int)*((uint32_t*)a1 + 4));
		case SYS_page_unmap:
			// cprintf("SYS_page_unmap\n");
			return sys_page_unmap((envid_t)a1, (void *)a2);
f0104f45:	eb 31                	jmp    f0104f78 <syscall+0x559>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *env;
	if (envid2env(envid, &env, 1)) {
f0104f47:	83 ec 04             	sub    $0x4,%esp
f0104f4a:	6a 01                	push   $0x1
f0104f4c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f4f:	50                   	push   %eax
f0104f50:	ff 75 0c             	pushl  0xc(%ebp)
f0104f53:	e8 29 e6 ff ff       	call   f0103581 <envid2env>
f0104f58:	89 c3                	mov    %eax,%ebx
f0104f5a:	83 c4 10             	add    $0x10,%esp
f0104f5d:	85 c0                	test   %eax,%eax
f0104f5f:	75 0b                	jne    f0104f6c <syscall+0x54d>
		return -E_BAD_ENV;
	}

	env->env_pgfault_upcall = func;
f0104f61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f64:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f67:	89 48 68             	mov    %ecx,0x68(%eax)
f0104f6a:	eb 0c                	jmp    f0104f78 <syscall+0x559>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *env;
	if (envid2env(envid, &env, 1)) {
		return -E_BAD_ENV;
f0104f6c:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		case SYS_page_unmap:
			// cprintf("SYS_page_unmap\n");
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			// cprintf("SYS_env_set_pgfault_upcall\n");
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104f71:	eb 05                	jmp    f0104f78 <syscall+0x559>
		default:
			return -E_INVAL;
f0104f73:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	}
	// panic("syscall not implemented");
}
f0104f78:	89 d8                	mov    %ebx,%eax
f0104f7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f7d:	5b                   	pop    %ebx
f0104f7e:	5e                   	pop    %esi
f0104f7f:	5f                   	pop    %edi
f0104f80:	5d                   	pop    %ebp
f0104f81:	c3                   	ret    

f0104f82 <syscall_helper>:

void
syscall_helper(struct Trapframe *tf)
{
f0104f82:	55                   	push   %ebp
f0104f83:	89 e5                	mov    %esp,%ebp
f0104f85:	57                   	push   %edi
f0104f86:	56                   	push   %esi
f0104f87:	53                   	push   %ebx
f0104f88:	83 ec 18             	sub    $0x18,%esp
f0104f8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104f8e:	68 a0 23 12 f0       	push   $0xf01223a0
f0104f93:	e8 05 18 00 00       	call   f010679d <spin_lock>
	lock_kernel();
	curenv->env_tf = *tf;
f0104f98:	e8 92 15 00 00       	call   f010652f <cpunum>
f0104f9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa0:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104fa6:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104fab:	89 c7                	mov    %eax,%edi
f0104fad:	89 de                	mov    %ebx,%esi
f0104faf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f0104fb1:	83 c4 08             	add    $0x8,%esp
f0104fb4:	6a 00                	push   $0x0
f0104fb6:	ff 33                	pushl  (%ebx)
f0104fb8:	ff 73 10             	pushl  0x10(%ebx)
f0104fbb:	ff 73 18             	pushl  0x18(%ebx)
f0104fbe:	ff 73 14             	pushl  0x14(%ebx)
f0104fc1:	ff 73 1c             	pushl  0x1c(%ebx)
f0104fc4:	e8 56 fa ff ff       	call   f0104a1f <syscall>
f0104fc9:	89 43 1c             	mov    %eax,0x1c(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104fcc:	83 c4 14             	add    $0x14,%esp
f0104fcf:	68 a0 23 12 f0       	push   $0xf01223a0
f0104fd4:	e8 99 18 00 00       	call   f0106872 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104fd9:	f3 90                	pause  
				tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
	unlock_kernel();
}
f0104fdb:	83 c4 10             	add    $0x10,%esp
f0104fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fe1:	5b                   	pop    %ebx
f0104fe2:	5e                   	pop    %esi
f0104fe3:	5f                   	pop    %edi
f0104fe4:	5d                   	pop    %ebp
f0104fe5:	c3                   	ret    

f0104fe6 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104fe6:	55                   	push   %ebp
f0104fe7:	89 e5                	mov    %esp,%ebp
f0104fe9:	57                   	push   %edi
f0104fea:	56                   	push   %esi
f0104feb:	53                   	push   %ebx
f0104fec:	83 ec 14             	sub    $0x14,%esp
f0104fef:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ff2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ff5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ff8:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ffb:	8b 1a                	mov    (%edx),%ebx
f0104ffd:	8b 01                	mov    (%ecx),%eax
f0104fff:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f0105002:	39 c3                	cmp    %eax,%ebx
f0105004:	0f 8f 9a 00 00 00    	jg     f01050a4 <stab_binsearch+0xbe>
f010500a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0105011:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105014:	01 d8                	add    %ebx,%eax
f0105016:	89 c6                	mov    %eax,%esi
f0105018:	c1 ee 1f             	shr    $0x1f,%esi
f010501b:	01 c6                	add    %eax,%esi
f010501d:	d1 fe                	sar    %esi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010501f:	39 de                	cmp    %ebx,%esi
f0105021:	0f 8c c4 00 00 00    	jl     f01050eb <stab_binsearch+0x105>
f0105027:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010502a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010502d:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0105030:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0105034:	39 c7                	cmp    %eax,%edi
f0105036:	0f 84 b4 00 00 00    	je     f01050f0 <stab_binsearch+0x10a>
f010503c:	89 f0                	mov    %esi,%eax
			m--;
f010503e:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105041:	39 d8                	cmp    %ebx,%eax
f0105043:	0f 8c a2 00 00 00    	jl     f01050eb <stab_binsearch+0x105>
f0105049:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f010504d:	83 ea 0c             	sub    $0xc,%edx
f0105050:	39 f9                	cmp    %edi,%ecx
f0105052:	75 ea                	jne    f010503e <stab_binsearch+0x58>
f0105054:	e9 99 00 00 00       	jmp    f01050f2 <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105059:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010505c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010505e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105061:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105068:	eb 2b                	jmp    f0105095 <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010506a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010506d:	76 14                	jbe    f0105083 <stab_binsearch+0x9d>
			*region_right = m - 1;
f010506f:	83 e8 01             	sub    $0x1,%eax
f0105072:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105075:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105078:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010507a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105081:	eb 12                	jmp    f0105095 <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105083:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105086:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0105088:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010508c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010508e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105095:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0105098:	0f 8d 73 ff ff ff    	jge    f0105011 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010509e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01050a2:	75 0f                	jne    f01050b3 <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f01050a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050a7:	8b 00                	mov    (%eax),%eax
f01050a9:	83 e8 01             	sub    $0x1,%eax
f01050ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01050af:	89 07                	mov    %eax,(%edi)
f01050b1:	eb 57                	jmp    f010510a <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01050b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050b6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01050b8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01050bb:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01050bd:	39 c8                	cmp    %ecx,%eax
f01050bf:	7e 23                	jle    f01050e4 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f01050c1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01050c4:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01050c7:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01050ca:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01050ce:	39 df                	cmp    %ebx,%edi
f01050d0:	74 12                	je     f01050e4 <stab_binsearch+0xfe>
		     l--)
f01050d2:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01050d5:	39 c8                	cmp    %ecx,%eax
f01050d7:	7e 0b                	jle    f01050e4 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f01050d9:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f01050dd:	83 ea 0c             	sub    $0xc,%edx
f01050e0:	39 df                	cmp    %ebx,%edi
f01050e2:	75 ee                	jne    f01050d2 <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f01050e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050e7:	89 07                	mov    %eax,(%edi)
	}
}
f01050e9:	eb 1f                	jmp    f010510a <stab_binsearch+0x124>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01050eb:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01050ee:	eb a5                	jmp    f0105095 <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01050f0:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01050f2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01050f5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01050f8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01050fc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01050ff:	0f 82 54 ff ff ff    	jb     f0105059 <stab_binsearch+0x73>
f0105105:	e9 60 ff ff ff       	jmp    f010506a <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010510a:	83 c4 14             	add    $0x14,%esp
f010510d:	5b                   	pop    %ebx
f010510e:	5e                   	pop    %esi
f010510f:	5f                   	pop    %edi
f0105110:	5d                   	pop    %ebp
f0105111:	c3                   	ret    

f0105112 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105112:	55                   	push   %ebp
f0105113:	89 e5                	mov    %esp,%ebp
f0105115:	57                   	push   %edi
f0105116:	56                   	push   %esi
f0105117:	53                   	push   %ebx
f0105118:	83 ec 3c             	sub    $0x3c,%esp
f010511b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010511e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105121:	c7 03 00 84 10 f0    	movl   $0xf0108400,(%ebx)
	info->eip_line = 0;
f0105127:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010512e:	c7 43 08 00 84 10 f0 	movl   $0xf0108400,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105135:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010513c:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010513f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105146:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010514c:	0f 87 a3 00 00 00    	ja     f01051f5 <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U)) {
f0105152:	e8 d8 13 00 00       	call   f010652f <cpunum>
f0105157:	6a 04                	push   $0x4
f0105159:	6a 10                	push   $0x10
f010515b:	68 00 00 20 00       	push   $0x200000
f0105160:	6b c0 74             	imul   $0x74,%eax,%eax
f0105163:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0105169:	e8 81 e2 ff ff       	call   f01033ef <user_mem_check>
f010516e:	83 c4 10             	add    $0x10,%esp
f0105171:	85 c0                	test   %eax,%eax
f0105173:	0f 85 52 02 00 00    	jne    f01053cb <debuginfo_eip+0x2b9>
			return -1;
		}

		stabs = usd->stabs;
f0105179:	a1 00 00 20 00       	mov    0x200000,%eax
f010517e:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0105181:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0105187:	8b 15 08 00 20 00    	mov    0x200008,%edx
f010518d:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0105190:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105195:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
f0105198:	e8 92 13 00 00       	call   f010652f <cpunum>
f010519d:	6a 04                	push   $0x4
f010519f:	89 f2                	mov    %esi,%edx
f01051a1:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01051a4:	29 ca                	sub    %ecx,%edx
f01051a6:	c1 fa 02             	sar    $0x2,%edx
f01051a9:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01051af:	52                   	push   %edx
f01051b0:	51                   	push   %ecx
f01051b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01051b4:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f01051ba:	e8 30 e2 ff ff       	call   f01033ef <user_mem_check>
f01051bf:	83 c4 10             	add    $0x10,%esp
f01051c2:	85 c0                	test   %eax,%eax
f01051c4:	0f 85 08 02 00 00    	jne    f01053d2 <debuginfo_eip+0x2c0>
			return -1;
		}

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
f01051ca:	e8 60 13 00 00       	call   f010652f <cpunum>
f01051cf:	6a 04                	push   $0x4
f01051d1:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01051d4:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01051d7:	29 ca                	sub    %ecx,%edx
f01051d9:	52                   	push   %edx
f01051da:	51                   	push   %ecx
f01051db:	6b c0 74             	imul   $0x74,%eax,%eax
f01051de:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f01051e4:	e8 06 e2 ff ff       	call   f01033ef <user_mem_check>
f01051e9:	83 c4 10             	add    $0x10,%esp
f01051ec:	85 c0                	test   %eax,%eax
f01051ee:	74 1f                	je     f010520f <debuginfo_eip+0xfd>
f01051f0:	e9 e4 01 00 00       	jmp    f01053d9 <debuginfo_eip+0x2c7>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01051f5:	c7 45 bc 4c 70 11 f0 	movl   $0xf011704c,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01051fc:	c7 45 b8 d5 38 11 f0 	movl   $0xf01138d5,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105203:	be d4 38 11 f0       	mov    $0xf01138d4,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105208:	c7 45 c0 54 89 10 f0 	movl   $0xf0108954,-0x40(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010520f:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105212:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0105215:	0f 83 c5 01 00 00    	jae    f01053e0 <debuginfo_eip+0x2ce>
f010521b:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010521f:	0f 85 c2 01 00 00    	jne    f01053e7 <debuginfo_eip+0x2d5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105225:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010522c:	2b 75 c0             	sub    -0x40(%ebp),%esi
f010522f:	c1 fe 02             	sar    $0x2,%esi
f0105232:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0105238:	83 e8 01             	sub    $0x1,%eax
f010523b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010523e:	83 ec 08             	sub    $0x8,%esp
f0105241:	57                   	push   %edi
f0105242:	6a 64                	push   $0x64
f0105244:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105247:	89 d1                	mov    %edx,%ecx
f0105249:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010524c:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010524f:	89 f0                	mov    %esi,%eax
f0105251:	e8 90 fd ff ff       	call   f0104fe6 <stab_binsearch>
	if (lfile == 0)
f0105256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105259:	83 c4 10             	add    $0x10,%esp
f010525c:	85 c0                	test   %eax,%eax
f010525e:	0f 84 8a 01 00 00    	je     f01053ee <debuginfo_eip+0x2dc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105264:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105267:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010526a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010526d:	83 ec 08             	sub    $0x8,%esp
f0105270:	57                   	push   %edi
f0105271:	6a 24                	push   $0x24
f0105273:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0105276:	89 d1                	mov    %edx,%ecx
f0105278:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010527b:	89 f0                	mov    %esi,%eax
f010527d:	e8 64 fd ff ff       	call   f0104fe6 <stab_binsearch>

	if (lfun <= rfun) {
f0105282:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105285:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105288:	83 c4 10             	add    $0x10,%esp
f010528b:	39 d0                	cmp    %edx,%eax
f010528d:	7f 2e                	jg     f01052bd <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010528f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105292:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0105295:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105298:	8b 36                	mov    (%esi),%esi
f010529a:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010529d:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f01052a0:	39 ce                	cmp    %ecx,%esi
f01052a2:	73 06                	jae    f01052aa <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01052a4:	03 75 b8             	add    -0x48(%ebp),%esi
f01052a7:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01052aa:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01052ad:	8b 4e 08             	mov    0x8(%esi),%ecx
f01052b0:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01052b3:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01052b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01052b8:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01052bb:	eb 0f                	jmp    f01052cc <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01052bd:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01052c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01052c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01052cc:	83 ec 08             	sub    $0x8,%esp
f01052cf:	6a 3a                	push   $0x3a
f01052d1:	ff 73 08             	pushl  0x8(%ebx)
f01052d4:	e8 b3 0b 00 00       	call   f0105e8c <strfind>
f01052d9:	2b 43 08             	sub    0x8(%ebx),%eax
f01052dc:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01052df:	83 c4 08             	add    $0x8,%esp
f01052e2:	57                   	push   %edi
f01052e3:	6a 44                	push   $0x44
f01052e5:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01052e8:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01052eb:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01052ee:	89 f0                	mov    %esi,%eax
f01052f0:	e8 f1 fc ff ff       	call   f0104fe6 <stab_binsearch>
	if (lline <= rline) {
f01052f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01052f8:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01052fb:	83 c4 10             	add    $0x10,%esp
f01052fe:	39 d0                	cmp    %edx,%eax
f0105300:	0f 8f ef 00 00 00    	jg     f01053f5 <debuginfo_eip+0x2e3>
		info->eip_line = rline;
f0105306:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010530c:	39 f8                	cmp    %edi,%eax
f010530e:	7c 69                	jl     f0105379 <debuginfo_eip+0x267>
	       && stabs[lline].n_type != N_SOL
f0105310:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105313:	8d 34 96             	lea    (%esi,%edx,4),%esi
f0105316:	0f b6 56 04          	movzbl 0x4(%esi),%edx
f010531a:	80 fa 84             	cmp    $0x84,%dl
f010531d:	74 41                	je     f0105360 <debuginfo_eip+0x24e>
f010531f:	89 f1                	mov    %esi,%ecx
f0105321:	83 c6 08             	add    $0x8,%esi
f0105324:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105328:	eb 1f                	jmp    f0105349 <debuginfo_eip+0x237>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010532a:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010532d:	39 f8                	cmp    %edi,%eax
f010532f:	7c 48                	jl     f0105379 <debuginfo_eip+0x267>
	       && stabs[lline].n_type != N_SOL
f0105331:	0f b6 51 f8          	movzbl -0x8(%ecx),%edx
f0105335:	83 e9 0c             	sub    $0xc,%ecx
f0105338:	83 ee 0c             	sub    $0xc,%esi
f010533b:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f010533f:	80 fa 84             	cmp    $0x84,%dl
f0105342:	75 05                	jne    f0105349 <debuginfo_eip+0x237>
f0105344:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105347:	eb 17                	jmp    f0105360 <debuginfo_eip+0x24e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105349:	80 fa 64             	cmp    $0x64,%dl
f010534c:	75 dc                	jne    f010532a <debuginfo_eip+0x218>
f010534e:	83 3e 00             	cmpl   $0x0,(%esi)
f0105351:	74 d7                	je     f010532a <debuginfo_eip+0x218>
f0105353:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105357:	74 03                	je     f010535c <debuginfo_eip+0x24a>
f0105359:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010535c:	39 c7                	cmp    %eax,%edi
f010535e:	7f 19                	jg     f0105379 <debuginfo_eip+0x267>
f0105360:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105363:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105366:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105369:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010536c:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010536f:	29 f8                	sub    %edi,%eax
f0105371:	39 c2                	cmp    %eax,%edx
f0105373:	73 04                	jae    f0105379 <debuginfo_eip+0x267>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105375:	01 fa                	add    %edi,%edx
f0105377:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105379:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010537c:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010537f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105384:	39 f2                	cmp    %esi,%edx
f0105386:	0f 8d 83 00 00 00    	jge    f010540f <debuginfo_eip+0x2fd>
		for (lline = lfun + 1;
f010538c:	8d 42 01             	lea    0x1(%edx),%eax
f010538f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105392:	39 c6                	cmp    %eax,%esi
f0105394:	7e 66                	jle    f01053fc <debuginfo_eip+0x2ea>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105396:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105399:	c1 e1 02             	shl    $0x2,%ecx
f010539c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010539f:	80 7c 0f 04 a0       	cmpb   $0xa0,0x4(%edi,%ecx,1)
f01053a4:	75 5d                	jne    f0105403 <debuginfo_eip+0x2f1>
f01053a6:	8d 42 02             	lea    0x2(%edx),%eax
f01053a9:	8d 54 0f f4          	lea    -0xc(%edi,%ecx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f01053ad:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01053b1:	39 c6                	cmp    %eax,%esi
f01053b3:	74 55                	je     f010540a <debuginfo_eip+0x2f8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01053b5:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f01053b9:	83 c0 01             	add    $0x1,%eax
f01053bc:	83 c2 0c             	add    $0xc,%edx
f01053bf:	80 f9 a0             	cmp    $0xa0,%cl
f01053c2:	74 e9                	je     f01053ad <debuginfo_eip+0x29b>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01053c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01053c9:	eb 44                	jmp    f010540f <debuginfo_eip+0x2fd>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U)) {
			return -1;
f01053cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01053d0:	eb 3d                	jmp    f010540f <debuginfo_eip+0x2fd>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
			return -1;
f01053d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01053d7:	eb 36                	jmp    f010540f <debuginfo_eip+0x2fd>
		}

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
			return -1;
f01053d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01053de:	eb 2f                	jmp    f010540f <debuginfo_eip+0x2fd>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01053e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01053e5:	eb 28                	jmp    f010540f <debuginfo_eip+0x2fd>
f01053e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01053ec:	eb 21                	jmp    f010540f <debuginfo_eip+0x2fd>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01053ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01053f3:	eb 1a                	jmp    f010540f <debuginfo_eip+0x2fd>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = rline;
	} else {
		return -1;
f01053f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01053fa:	eb 13                	jmp    f010540f <debuginfo_eip+0x2fd>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01053fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105401:	eb 0c                	jmp    f010540f <debuginfo_eip+0x2fd>
f0105403:	b8 00 00 00 00       	mov    $0x0,%eax
f0105408:	eb 05                	jmp    f010540f <debuginfo_eip+0x2fd>
f010540a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010540f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105412:	5b                   	pop    %ebx
f0105413:	5e                   	pop    %esi
f0105414:	5f                   	pop    %edi
f0105415:	5d                   	pop    %ebp
f0105416:	c3                   	ret    

f0105417 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105417:	55                   	push   %ebp
f0105418:	89 e5                	mov    %esp,%ebp
f010541a:	57                   	push   %edi
f010541b:	56                   	push   %esi
f010541c:	53                   	push   %ebx
f010541d:	83 ec 1c             	sub    $0x1c,%esp
f0105420:	89 c7                	mov    %eax,%edi
f0105422:	89 d6                	mov    %edx,%esi
f0105424:	8b 45 08             	mov    0x8(%ebp),%eax
f0105427:	8b 55 0c             	mov    0xc(%ebp),%edx
f010542a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010542d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105430:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
f0105433:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0105437:	0f 85 bf 00 00 00    	jne    f01054fc <printnum+0xe5>
f010543d:	39 1d 88 1a 24 f0    	cmp    %ebx,0xf0241a88
f0105443:	0f 8d de 00 00 00    	jge    f0105527 <printnum+0x110>
		judge_time_for_space = width;
f0105449:	89 1d 88 1a 24 f0    	mov    %ebx,0xf0241a88
f010544f:	e9 d3 00 00 00       	jmp    f0105527 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0105454:	83 eb 01             	sub    $0x1,%ebx
f0105457:	85 db                	test   %ebx,%ebx
f0105459:	7f 37                	jg     f0105492 <printnum+0x7b>
f010545b:	e9 ea 00 00 00       	jmp    f010554a <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
f0105460:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105463:	a3 84 1a 24 f0       	mov    %eax,0xf0241a84
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105468:	83 ec 08             	sub    $0x8,%esp
f010546b:	56                   	push   %esi
f010546c:	83 ec 04             	sub    $0x4,%esp
f010546f:	ff 75 dc             	pushl  -0x24(%ebp)
f0105472:	ff 75 d8             	pushl  -0x28(%ebp)
f0105475:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105478:	ff 75 e0             	pushl  -0x20(%ebp)
f010547b:	e8 30 16 00 00       	call   f0106ab0 <__umoddi3>
f0105480:	83 c4 14             	add    $0x14,%esp
f0105483:	0f be 80 0a 84 10 f0 	movsbl -0xfef7bf6(%eax),%eax
f010548a:	50                   	push   %eax
f010548b:	ff d7                	call   *%edi
f010548d:	83 c4 10             	add    $0x10,%esp
f0105490:	eb 16                	jmp    f01054a8 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
f0105492:	83 ec 08             	sub    $0x8,%esp
f0105495:	56                   	push   %esi
f0105496:	ff 75 18             	pushl  0x18(%ebp)
f0105499:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f010549b:	83 c4 10             	add    $0x10,%esp
f010549e:	83 eb 01             	sub    $0x1,%ebx
f01054a1:	75 ef                	jne    f0105492 <printnum+0x7b>
f01054a3:	e9 a2 00 00 00       	jmp    f010554a <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
f01054a8:	3b 1d 88 1a 24 f0    	cmp    0xf0241a88,%ebx
f01054ae:	0f 85 76 01 00 00    	jne    f010562a <printnum+0x213>
		while(num_of_space-- > 0)
f01054b4:	a1 84 1a 24 f0       	mov    0xf0241a84,%eax
f01054b9:	8d 50 ff             	lea    -0x1(%eax),%edx
f01054bc:	89 15 84 1a 24 f0    	mov    %edx,0xf0241a84
f01054c2:	85 c0                	test   %eax,%eax
f01054c4:	7e 1d                	jle    f01054e3 <printnum+0xcc>
			putch(' ', putdat);
f01054c6:	83 ec 08             	sub    $0x8,%esp
f01054c9:	56                   	push   %esi
f01054ca:	6a 20                	push   $0x20
f01054cc:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
f01054ce:	a1 84 1a 24 f0       	mov    0xf0241a84,%eax
f01054d3:	8d 50 ff             	lea    -0x1(%eax),%edx
f01054d6:	89 15 84 1a 24 f0    	mov    %edx,0xf0241a84
f01054dc:	83 c4 10             	add    $0x10,%esp
f01054df:	85 c0                	test   %eax,%eax
f01054e1:	7f e3                	jg     f01054c6 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
f01054e3:	c7 05 84 1a 24 f0 00 	movl   $0x0,0xf0241a84
f01054ea:	00 00 00 
		judge_time_for_space = 0;
f01054ed:	c7 05 88 1a 24 f0 00 	movl   $0x0,0xf0241a88
f01054f4:	00 00 00 
	}
}
f01054f7:	e9 2e 01 00 00       	jmp    f010562a <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01054fc:	8b 45 10             	mov    0x10(%ebp),%eax
f01054ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105504:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105507:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010550a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010550d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105510:	83 fa 00             	cmp    $0x0,%edx
f0105513:	0f 87 ba 00 00 00    	ja     f01055d3 <printnum+0x1bc>
f0105519:	3b 45 10             	cmp    0x10(%ebp),%eax
f010551c:	0f 83 b1 00 00 00    	jae    f01055d3 <printnum+0x1bc>
f0105522:	e9 2d ff ff ff       	jmp    f0105454 <printnum+0x3d>
f0105527:	8b 45 10             	mov    0x10(%ebp),%eax
f010552a:	ba 00 00 00 00       	mov    $0x0,%edx
f010552f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105532:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105535:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105538:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010553b:	83 fa 00             	cmp    $0x0,%edx
f010553e:	77 37                	ja     f0105577 <printnum+0x160>
f0105540:	3b 45 10             	cmp    0x10(%ebp),%eax
f0105543:	73 32                	jae    f0105577 <printnum+0x160>
f0105545:	e9 16 ff ff ff       	jmp    f0105460 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010554a:	83 ec 08             	sub    $0x8,%esp
f010554d:	56                   	push   %esi
f010554e:	83 ec 04             	sub    $0x4,%esp
f0105551:	ff 75 dc             	pushl  -0x24(%ebp)
f0105554:	ff 75 d8             	pushl  -0x28(%ebp)
f0105557:	ff 75 e4             	pushl  -0x1c(%ebp)
f010555a:	ff 75 e0             	pushl  -0x20(%ebp)
f010555d:	e8 4e 15 00 00       	call   f0106ab0 <__umoddi3>
f0105562:	83 c4 14             	add    $0x14,%esp
f0105565:	0f be 80 0a 84 10 f0 	movsbl -0xfef7bf6(%eax),%eax
f010556c:	50                   	push   %eax
f010556d:	ff d7                	call   *%edi
f010556f:	83 c4 10             	add    $0x10,%esp
f0105572:	e9 b3 00 00 00       	jmp    f010562a <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105577:	83 ec 0c             	sub    $0xc,%esp
f010557a:	ff 75 18             	pushl  0x18(%ebp)
f010557d:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105580:	50                   	push   %eax
f0105581:	ff 75 10             	pushl  0x10(%ebp)
f0105584:	83 ec 08             	sub    $0x8,%esp
f0105587:	ff 75 dc             	pushl  -0x24(%ebp)
f010558a:	ff 75 d8             	pushl  -0x28(%ebp)
f010558d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105590:	ff 75 e0             	pushl  -0x20(%ebp)
f0105593:	e8 e8 13 00 00       	call   f0106980 <__udivdi3>
f0105598:	83 c4 18             	add    $0x18,%esp
f010559b:	52                   	push   %edx
f010559c:	50                   	push   %eax
f010559d:	89 f2                	mov    %esi,%edx
f010559f:	89 f8                	mov    %edi,%eax
f01055a1:	e8 71 fe ff ff       	call   f0105417 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01055a6:	83 c4 18             	add    $0x18,%esp
f01055a9:	56                   	push   %esi
f01055aa:	83 ec 04             	sub    $0x4,%esp
f01055ad:	ff 75 dc             	pushl  -0x24(%ebp)
f01055b0:	ff 75 d8             	pushl  -0x28(%ebp)
f01055b3:	ff 75 e4             	pushl  -0x1c(%ebp)
f01055b6:	ff 75 e0             	pushl  -0x20(%ebp)
f01055b9:	e8 f2 14 00 00       	call   f0106ab0 <__umoddi3>
f01055be:	83 c4 14             	add    $0x14,%esp
f01055c1:	0f be 80 0a 84 10 f0 	movsbl -0xfef7bf6(%eax),%eax
f01055c8:	50                   	push   %eax
f01055c9:	ff d7                	call   *%edi
f01055cb:	83 c4 10             	add    $0x10,%esp
f01055ce:	e9 d5 fe ff ff       	jmp    f01054a8 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01055d3:	83 ec 0c             	sub    $0xc,%esp
f01055d6:	ff 75 18             	pushl  0x18(%ebp)
f01055d9:	83 eb 01             	sub    $0x1,%ebx
f01055dc:	53                   	push   %ebx
f01055dd:	ff 75 10             	pushl  0x10(%ebp)
f01055e0:	83 ec 08             	sub    $0x8,%esp
f01055e3:	ff 75 dc             	pushl  -0x24(%ebp)
f01055e6:	ff 75 d8             	pushl  -0x28(%ebp)
f01055e9:	ff 75 e4             	pushl  -0x1c(%ebp)
f01055ec:	ff 75 e0             	pushl  -0x20(%ebp)
f01055ef:	e8 8c 13 00 00       	call   f0106980 <__udivdi3>
f01055f4:	83 c4 18             	add    $0x18,%esp
f01055f7:	52                   	push   %edx
f01055f8:	50                   	push   %eax
f01055f9:	89 f2                	mov    %esi,%edx
f01055fb:	89 f8                	mov    %edi,%eax
f01055fd:	e8 15 fe ff ff       	call   f0105417 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105602:	83 c4 18             	add    $0x18,%esp
f0105605:	56                   	push   %esi
f0105606:	83 ec 04             	sub    $0x4,%esp
f0105609:	ff 75 dc             	pushl  -0x24(%ebp)
f010560c:	ff 75 d8             	pushl  -0x28(%ebp)
f010560f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105612:	ff 75 e0             	pushl  -0x20(%ebp)
f0105615:	e8 96 14 00 00       	call   f0106ab0 <__umoddi3>
f010561a:	83 c4 14             	add    $0x14,%esp
f010561d:	0f be 80 0a 84 10 f0 	movsbl -0xfef7bf6(%eax),%eax
f0105624:	50                   	push   %eax
f0105625:	ff d7                	call   *%edi
f0105627:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
f010562a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010562d:	5b                   	pop    %ebx
f010562e:	5e                   	pop    %esi
f010562f:	5f                   	pop    %edi
f0105630:	5d                   	pop    %ebp
f0105631:	c3                   	ret    

f0105632 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105632:	55                   	push   %ebp
f0105633:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105635:	83 fa 01             	cmp    $0x1,%edx
f0105638:	7e 0e                	jle    f0105648 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010563a:	8b 10                	mov    (%eax),%edx
f010563c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010563f:	89 08                	mov    %ecx,(%eax)
f0105641:	8b 02                	mov    (%edx),%eax
f0105643:	8b 52 04             	mov    0x4(%edx),%edx
f0105646:	eb 22                	jmp    f010566a <getuint+0x38>
	else if (lflag)
f0105648:	85 d2                	test   %edx,%edx
f010564a:	74 10                	je     f010565c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010564c:	8b 10                	mov    (%eax),%edx
f010564e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105651:	89 08                	mov    %ecx,(%eax)
f0105653:	8b 02                	mov    (%edx),%eax
f0105655:	ba 00 00 00 00       	mov    $0x0,%edx
f010565a:	eb 0e                	jmp    f010566a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010565c:	8b 10                	mov    (%eax),%edx
f010565e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105661:	89 08                	mov    %ecx,(%eax)
f0105663:	8b 02                	mov    (%edx),%eax
f0105665:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010566a:	5d                   	pop    %ebp
f010566b:	c3                   	ret    

f010566c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010566c:	55                   	push   %ebp
f010566d:	89 e5                	mov    %esp,%ebp
f010566f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105672:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105676:	8b 10                	mov    (%eax),%edx
f0105678:	3b 50 04             	cmp    0x4(%eax),%edx
f010567b:	73 0a                	jae    f0105687 <sprintputch+0x1b>
		*b->buf++ = ch;
f010567d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105680:	89 08                	mov    %ecx,(%eax)
f0105682:	8b 45 08             	mov    0x8(%ebp),%eax
f0105685:	88 02                	mov    %al,(%edx)
}
f0105687:	5d                   	pop    %ebp
f0105688:	c3                   	ret    

f0105689 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105689:	55                   	push   %ebp
f010568a:	89 e5                	mov    %esp,%ebp
f010568c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010568f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105692:	50                   	push   %eax
f0105693:	ff 75 10             	pushl  0x10(%ebp)
f0105696:	ff 75 0c             	pushl  0xc(%ebp)
f0105699:	ff 75 08             	pushl  0x8(%ebp)
f010569c:	e8 05 00 00 00       	call   f01056a6 <vprintfmt>
	va_end(ap);
}
f01056a1:	83 c4 10             	add    $0x10,%esp
f01056a4:	c9                   	leave  
f01056a5:	c3                   	ret    

f01056a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01056a6:	55                   	push   %ebp
f01056a7:	89 e5                	mov    %esp,%ebp
f01056a9:	57                   	push   %edi
f01056aa:	56                   	push   %esi
f01056ab:	53                   	push   %ebx
f01056ac:	83 ec 2c             	sub    $0x2c,%esp
f01056af:	8b 7d 08             	mov    0x8(%ebp),%edi
f01056b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056b5:	eb 03                	jmp    f01056ba <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f01056b7:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01056ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01056bd:	8d 70 01             	lea    0x1(%eax),%esi
f01056c0:	0f b6 00             	movzbl (%eax),%eax
f01056c3:	83 f8 25             	cmp    $0x25,%eax
f01056c6:	74 27                	je     f01056ef <vprintfmt+0x49>
			if (ch == '\0')
f01056c8:	85 c0                	test   %eax,%eax
f01056ca:	75 0d                	jne    f01056d9 <vprintfmt+0x33>
f01056cc:	e9 9d 04 00 00       	jmp    f0105b6e <vprintfmt+0x4c8>
f01056d1:	85 c0                	test   %eax,%eax
f01056d3:	0f 84 95 04 00 00    	je     f0105b6e <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
f01056d9:	83 ec 08             	sub    $0x8,%esp
f01056dc:	53                   	push   %ebx
f01056dd:	50                   	push   %eax
f01056de:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01056e0:	83 c6 01             	add    $0x1,%esi
f01056e3:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f01056e7:	83 c4 10             	add    $0x10,%esp
f01056ea:	83 f8 25             	cmp    $0x25,%eax
f01056ed:	75 e2                	jne    f01056d1 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01056ef:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056f4:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f01056f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01056ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105706:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010570d:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0105714:	eb 08                	jmp    f010571e <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105716:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
f0105719:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010571e:	8d 46 01             	lea    0x1(%esi),%eax
f0105721:	89 45 10             	mov    %eax,0x10(%ebp)
f0105724:	0f b6 06             	movzbl (%esi),%eax
f0105727:	0f b6 d0             	movzbl %al,%edx
f010572a:	83 e8 23             	sub    $0x23,%eax
f010572d:	3c 55                	cmp    $0x55,%al
f010572f:	0f 87 fa 03 00 00    	ja     f0105b2f <vprintfmt+0x489>
f0105735:	0f b6 c0             	movzbl %al,%eax
f0105738:	ff 24 85 40 85 10 f0 	jmp    *-0xfef7ac0(,%eax,4)
f010573f:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f0105742:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f0105746:	eb d6                	jmp    f010571e <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105748:	8d 42 d0             	lea    -0x30(%edx),%eax
f010574b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f010574e:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105752:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105755:	83 fa 09             	cmp    $0x9,%edx
f0105758:	77 6b                	ja     f01057c5 <vprintfmt+0x11f>
f010575a:	8b 75 10             	mov    0x10(%ebp),%esi
f010575d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105760:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105763:	eb 09                	jmp    f010576e <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105765:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105768:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f010576c:	eb b0                	jmp    f010571e <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010576e:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105771:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105774:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0105778:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010577b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010577e:	83 f9 09             	cmp    $0x9,%ecx
f0105781:	76 eb                	jbe    f010576e <vprintfmt+0xc8>
f0105783:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105786:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105789:	eb 3d                	jmp    f01057c8 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010578b:	8b 45 14             	mov    0x14(%ebp),%eax
f010578e:	8d 50 04             	lea    0x4(%eax),%edx
f0105791:	89 55 14             	mov    %edx,0x14(%ebp)
f0105794:	8b 00                	mov    (%eax),%eax
f0105796:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105799:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010579c:	eb 2a                	jmp    f01057c8 <vprintfmt+0x122>
f010579e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057a1:	85 c0                	test   %eax,%eax
f01057a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01057a8:	0f 49 d0             	cmovns %eax,%edx
f01057ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057ae:	8b 75 10             	mov    0x10(%ebp),%esi
f01057b1:	e9 68 ff ff ff       	jmp    f010571e <vprintfmt+0x78>
f01057b6:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01057b9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01057c0:	e9 59 ff ff ff       	jmp    f010571e <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057c5:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01057c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01057cc:	0f 89 4c ff ff ff    	jns    f010571e <vprintfmt+0x78>
				width = precision, precision = -1;
f01057d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01057d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01057d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01057df:	e9 3a ff ff ff       	jmp    f010571e <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01057e4:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057e8:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01057eb:	e9 2e ff ff ff       	jmp    f010571e <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01057f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01057f3:	8d 50 04             	lea    0x4(%eax),%edx
f01057f6:	89 55 14             	mov    %edx,0x14(%ebp)
f01057f9:	83 ec 08             	sub    $0x8,%esp
f01057fc:	53                   	push   %ebx
f01057fd:	ff 30                	pushl  (%eax)
f01057ff:	ff d7                	call   *%edi
			break;
f0105801:	83 c4 10             	add    $0x10,%esp
f0105804:	e9 b1 fe ff ff       	jmp    f01056ba <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105809:	8b 45 14             	mov    0x14(%ebp),%eax
f010580c:	8d 50 04             	lea    0x4(%eax),%edx
f010580f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105812:	8b 00                	mov    (%eax),%eax
f0105814:	99                   	cltd   
f0105815:	31 d0                	xor    %edx,%eax
f0105817:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105819:	83 f8 08             	cmp    $0x8,%eax
f010581c:	7f 0b                	jg     f0105829 <vprintfmt+0x183>
f010581e:	8b 14 85 a0 86 10 f0 	mov    -0xfef7960(,%eax,4),%edx
f0105825:	85 d2                	test   %edx,%edx
f0105827:	75 15                	jne    f010583e <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
f0105829:	50                   	push   %eax
f010582a:	68 22 84 10 f0       	push   $0xf0108422
f010582f:	53                   	push   %ebx
f0105830:	57                   	push   %edi
f0105831:	e8 53 fe ff ff       	call   f0105689 <printfmt>
f0105836:	83 c4 10             	add    $0x10,%esp
f0105839:	e9 7c fe ff ff       	jmp    f01056ba <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f010583e:	52                   	push   %edx
f010583f:	68 8d 7a 10 f0       	push   $0xf0107a8d
f0105844:	53                   	push   %ebx
f0105845:	57                   	push   %edi
f0105846:	e8 3e fe ff ff       	call   f0105689 <printfmt>
f010584b:	83 c4 10             	add    $0x10,%esp
f010584e:	e9 67 fe ff ff       	jmp    f01056ba <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105853:	8b 45 14             	mov    0x14(%ebp),%eax
f0105856:	8d 50 04             	lea    0x4(%eax),%edx
f0105859:	89 55 14             	mov    %edx,0x14(%ebp)
f010585c:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f010585e:	85 c0                	test   %eax,%eax
f0105860:	b9 1b 84 10 f0       	mov    $0xf010841b,%ecx
f0105865:	0f 45 c8             	cmovne %eax,%ecx
f0105868:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010586b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010586f:	7e 06                	jle    f0105877 <vprintfmt+0x1d1>
f0105871:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0105875:	75 19                	jne    f0105890 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105877:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010587a:	8d 70 01             	lea    0x1(%eax),%esi
f010587d:	0f b6 00             	movzbl (%eax),%eax
f0105880:	0f be d0             	movsbl %al,%edx
f0105883:	85 d2                	test   %edx,%edx
f0105885:	0f 85 9f 00 00 00    	jne    f010592a <vprintfmt+0x284>
f010588b:	e9 8c 00 00 00       	jmp    f010591c <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105890:	83 ec 08             	sub    $0x8,%esp
f0105893:	ff 75 d0             	pushl  -0x30(%ebp)
f0105896:	ff 75 cc             	pushl  -0x34(%ebp)
f0105899:	e8 3b 04 00 00       	call   f0105cd9 <strnlen>
f010589e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f01058a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01058a4:	83 c4 10             	add    $0x10,%esp
f01058a7:	85 c9                	test   %ecx,%ecx
f01058a9:	0f 8e a6 02 00 00    	jle    f0105b55 <vprintfmt+0x4af>
					putch(padc, putdat);
f01058af:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f01058b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01058b6:	89 cb                	mov    %ecx,%ebx
f01058b8:	83 ec 08             	sub    $0x8,%esp
f01058bb:	ff 75 0c             	pushl  0xc(%ebp)
f01058be:	56                   	push   %esi
f01058bf:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01058c1:	83 c4 10             	add    $0x10,%esp
f01058c4:	83 eb 01             	sub    $0x1,%ebx
f01058c7:	75 ef                	jne    f01058b8 <vprintfmt+0x212>
f01058c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01058cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058cf:	e9 81 02 00 00       	jmp    f0105b55 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01058d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01058d8:	74 1b                	je     f01058f5 <vprintfmt+0x24f>
f01058da:	0f be c0             	movsbl %al,%eax
f01058dd:	83 e8 20             	sub    $0x20,%eax
f01058e0:	83 f8 5e             	cmp    $0x5e,%eax
f01058e3:	76 10                	jbe    f01058f5 <vprintfmt+0x24f>
					putch('?', putdat);
f01058e5:	83 ec 08             	sub    $0x8,%esp
f01058e8:	ff 75 0c             	pushl  0xc(%ebp)
f01058eb:	6a 3f                	push   $0x3f
f01058ed:	ff 55 08             	call   *0x8(%ebp)
f01058f0:	83 c4 10             	add    $0x10,%esp
f01058f3:	eb 0d                	jmp    f0105902 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
f01058f5:	83 ec 08             	sub    $0x8,%esp
f01058f8:	ff 75 0c             	pushl  0xc(%ebp)
f01058fb:	52                   	push   %edx
f01058fc:	ff 55 08             	call   *0x8(%ebp)
f01058ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105902:	83 ef 01             	sub    $0x1,%edi
f0105905:	83 c6 01             	add    $0x1,%esi
f0105908:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f010590c:	0f be d0             	movsbl %al,%edx
f010590f:	85 d2                	test   %edx,%edx
f0105911:	75 31                	jne    f0105944 <vprintfmt+0x29e>
f0105913:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105916:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105919:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010591c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010591f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105923:	7f 33                	jg     f0105958 <vprintfmt+0x2b2>
f0105925:	e9 90 fd ff ff       	jmp    f01056ba <vprintfmt+0x14>
f010592a:	89 7d 08             	mov    %edi,0x8(%ebp)
f010592d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105930:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105933:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105936:	eb 0c                	jmp    f0105944 <vprintfmt+0x29e>
f0105938:	89 7d 08             	mov    %edi,0x8(%ebp)
f010593b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010593e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105941:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105944:	85 db                	test   %ebx,%ebx
f0105946:	78 8c                	js     f01058d4 <vprintfmt+0x22e>
f0105948:	83 eb 01             	sub    $0x1,%ebx
f010594b:	79 87                	jns    f01058d4 <vprintfmt+0x22e>
f010594d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105950:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105953:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105956:	eb c4                	jmp    f010591c <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105958:	83 ec 08             	sub    $0x8,%esp
f010595b:	53                   	push   %ebx
f010595c:	6a 20                	push   $0x20
f010595e:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105960:	83 c4 10             	add    $0x10,%esp
f0105963:	83 ee 01             	sub    $0x1,%esi
f0105966:	75 f0                	jne    f0105958 <vprintfmt+0x2b2>
f0105968:	e9 4d fd ff ff       	jmp    f01056ba <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010596d:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f0105971:	7e 16                	jle    f0105989 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
f0105973:	8b 45 14             	mov    0x14(%ebp),%eax
f0105976:	8d 50 08             	lea    0x8(%eax),%edx
f0105979:	89 55 14             	mov    %edx,0x14(%ebp)
f010597c:	8b 50 04             	mov    0x4(%eax),%edx
f010597f:	8b 00                	mov    (%eax),%eax
f0105981:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105984:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105987:	eb 34                	jmp    f01059bd <vprintfmt+0x317>
	else if (lflag)
f0105989:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f010598d:	74 18                	je     f01059a7 <vprintfmt+0x301>
		return va_arg(*ap, long);
f010598f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105992:	8d 50 04             	lea    0x4(%eax),%edx
f0105995:	89 55 14             	mov    %edx,0x14(%ebp)
f0105998:	8b 30                	mov    (%eax),%esi
f010599a:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010599d:	89 f0                	mov    %esi,%eax
f010599f:	c1 f8 1f             	sar    $0x1f,%eax
f01059a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01059a5:	eb 16                	jmp    f01059bd <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
f01059a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01059aa:	8d 50 04             	lea    0x4(%eax),%edx
f01059ad:	89 55 14             	mov    %edx,0x14(%ebp)
f01059b0:	8b 30                	mov    (%eax),%esi
f01059b2:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01059b5:	89 f0                	mov    %esi,%eax
f01059b7:	c1 f8 1f             	sar    $0x1f,%eax
f01059ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01059bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01059c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01059c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01059c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f01059c9:	85 d2                	test   %edx,%edx
f01059cb:	79 28                	jns    f01059f5 <vprintfmt+0x34f>
				putch('-', putdat);
f01059cd:	83 ec 08             	sub    $0x8,%esp
f01059d0:	53                   	push   %ebx
f01059d1:	6a 2d                	push   $0x2d
f01059d3:	ff d7                	call   *%edi
				num = -(long long) num;
f01059d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01059d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01059db:	f7 d8                	neg    %eax
f01059dd:	83 d2 00             	adc    $0x0,%edx
f01059e0:	f7 da                	neg    %edx
f01059e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01059e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01059e8:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
f01059eb:	b8 0a 00 00 00       	mov    $0xa,%eax
f01059f0:	e9 b2 00 00 00       	jmp    f0105aa7 <vprintfmt+0x401>
f01059f5:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
f01059fa:	85 c9                	test   %ecx,%ecx
f01059fc:	0f 84 a5 00 00 00    	je     f0105aa7 <vprintfmt+0x401>
				putch('+', putdat);
f0105a02:	83 ec 08             	sub    $0x8,%esp
f0105a05:	53                   	push   %ebx
f0105a06:	6a 2b                	push   $0x2b
f0105a08:	ff d7                	call   *%edi
f0105a0a:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
f0105a0d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a12:	e9 90 00 00 00       	jmp    f0105aa7 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
f0105a17:	85 c9                	test   %ecx,%ecx
f0105a19:	74 0b                	je     f0105a26 <vprintfmt+0x380>
				putch('+', putdat);
f0105a1b:	83 ec 08             	sub    $0x8,%esp
f0105a1e:	53                   	push   %ebx
f0105a1f:	6a 2b                	push   $0x2b
f0105a21:	ff d7                	call   *%edi
f0105a23:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
f0105a26:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105a29:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a2c:	e8 01 fc ff ff       	call   f0105632 <getuint>
f0105a31:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105a34:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0105a37:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105a3c:	eb 69                	jmp    f0105aa7 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
f0105a3e:	83 ec 08             	sub    $0x8,%esp
f0105a41:	53                   	push   %ebx
f0105a42:	6a 30                	push   $0x30
f0105a44:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f0105a46:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105a49:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a4c:	e8 e1 fb ff ff       	call   f0105632 <getuint>
f0105a51:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105a54:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f0105a57:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0105a5a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105a5f:	eb 46                	jmp    f0105aa7 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105a61:	83 ec 08             	sub    $0x8,%esp
f0105a64:	53                   	push   %ebx
f0105a65:	6a 30                	push   $0x30
f0105a67:	ff d7                	call   *%edi
			putch('x', putdat);
f0105a69:	83 c4 08             	add    $0x8,%esp
f0105a6c:	53                   	push   %ebx
f0105a6d:	6a 78                	push   $0x78
f0105a6f:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105a71:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a74:	8d 50 04             	lea    0x4(%eax),%edx
f0105a77:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105a7a:	8b 00                	mov    (%eax),%eax
f0105a7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a81:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105a84:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105a87:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105a8a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105a8f:	eb 16                	jmp    f0105aa7 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105a91:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105a94:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a97:	e8 96 fb ff ff       	call   f0105632 <getuint>
f0105a9c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105a9f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0105aa2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105aa7:	83 ec 0c             	sub    $0xc,%esp
f0105aaa:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0105aae:	56                   	push   %esi
f0105aaf:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105ab2:	50                   	push   %eax
f0105ab3:	ff 75 dc             	pushl  -0x24(%ebp)
f0105ab6:	ff 75 d8             	pushl  -0x28(%ebp)
f0105ab9:	89 da                	mov    %ebx,%edx
f0105abb:	89 f8                	mov    %edi,%eax
f0105abd:	e8 55 f9 ff ff       	call   f0105417 <printnum>
			break;
f0105ac2:	83 c4 20             	add    $0x20,%esp
f0105ac5:	e9 f0 fb ff ff       	jmp    f01056ba <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
f0105aca:	8b 45 14             	mov    0x14(%ebp),%eax
f0105acd:	8d 50 04             	lea    0x4(%eax),%edx
f0105ad0:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ad3:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
f0105ad5:	85 f6                	test   %esi,%esi
f0105ad7:	75 1a                	jne    f0105af3 <vprintfmt+0x44d>
						cprintf("%s", null_error);
f0105ad9:	83 ec 08             	sub    $0x8,%esp
f0105adc:	68 c0 84 10 f0       	push   $0xf01084c0
f0105ae1:	68 8d 7a 10 f0       	push   $0xf0107a8d
f0105ae6:	e8 87 e3 ff ff       	call   f0103e72 <cprintf>
f0105aeb:	83 c4 10             	add    $0x10,%esp
f0105aee:	e9 c7 fb ff ff       	jmp    f01056ba <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
f0105af3:	0f b6 03             	movzbl (%ebx),%eax
f0105af6:	84 c0                	test   %al,%al
f0105af8:	79 1f                	jns    f0105b19 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
f0105afa:	83 ec 08             	sub    $0x8,%esp
f0105afd:	68 f8 84 10 f0       	push   $0xf01084f8
f0105b02:	68 8d 7a 10 f0       	push   $0xf0107a8d
f0105b07:	e8 66 e3 ff ff       	call   f0103e72 <cprintf>
						*tmp = *(char *)putdat;
f0105b0c:	0f b6 03             	movzbl (%ebx),%eax
f0105b0f:	88 06                	mov    %al,(%esi)
f0105b11:	83 c4 10             	add    $0x10,%esp
f0105b14:	e9 a1 fb ff ff       	jmp    f01056ba <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
f0105b19:	88 06                	mov    %al,(%esi)
f0105b1b:	e9 9a fb ff ff       	jmp    f01056ba <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105b20:	83 ec 08             	sub    $0x8,%esp
f0105b23:	53                   	push   %ebx
f0105b24:	52                   	push   %edx
f0105b25:	ff d7                	call   *%edi
			break;
f0105b27:	83 c4 10             	add    $0x10,%esp
f0105b2a:	e9 8b fb ff ff       	jmp    f01056ba <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105b2f:	83 ec 08             	sub    $0x8,%esp
f0105b32:	53                   	push   %ebx
f0105b33:	6a 25                	push   $0x25
f0105b35:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105b37:	83 c4 10             	add    $0x10,%esp
f0105b3a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105b3e:	0f 84 73 fb ff ff    	je     f01056b7 <vprintfmt+0x11>
f0105b44:	83 ee 01             	sub    $0x1,%esi
f0105b47:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105b4b:	75 f7                	jne    f0105b44 <vprintfmt+0x49e>
f0105b4d:	89 75 10             	mov    %esi,0x10(%ebp)
f0105b50:	e9 65 fb ff ff       	jmp    f01056ba <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105b55:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105b58:	8d 70 01             	lea    0x1(%eax),%esi
f0105b5b:	0f b6 00             	movzbl (%eax),%eax
f0105b5e:	0f be d0             	movsbl %al,%edx
f0105b61:	85 d2                	test   %edx,%edx
f0105b63:	0f 85 cf fd ff ff    	jne    f0105938 <vprintfmt+0x292>
f0105b69:	e9 4c fb ff ff       	jmp    f01056ba <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0105b6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b71:	5b                   	pop    %ebx
f0105b72:	5e                   	pop    %esi
f0105b73:	5f                   	pop    %edi
f0105b74:	5d                   	pop    %ebp
f0105b75:	c3                   	ret    

f0105b76 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105b76:	55                   	push   %ebp
f0105b77:	89 e5                	mov    %esp,%ebp
f0105b79:	83 ec 18             	sub    $0x18,%esp
f0105b7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b85:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b89:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105b93:	85 c0                	test   %eax,%eax
f0105b95:	74 26                	je     f0105bbd <vsnprintf+0x47>
f0105b97:	85 d2                	test   %edx,%edx
f0105b99:	7e 22                	jle    f0105bbd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105b9b:	ff 75 14             	pushl  0x14(%ebp)
f0105b9e:	ff 75 10             	pushl  0x10(%ebp)
f0105ba1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105ba4:	50                   	push   %eax
f0105ba5:	68 6c 56 10 f0       	push   $0xf010566c
f0105baa:	e8 f7 fa ff ff       	call   f01056a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105baf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105bb2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105bb8:	83 c4 10             	add    $0x10,%esp
f0105bbb:	eb 05                	jmp    f0105bc2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105bbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105bc2:	c9                   	leave  
f0105bc3:	c3                   	ret    

f0105bc4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105bc4:	55                   	push   %ebp
f0105bc5:	89 e5                	mov    %esp,%ebp
f0105bc7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105bca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105bcd:	50                   	push   %eax
f0105bce:	ff 75 10             	pushl  0x10(%ebp)
f0105bd1:	ff 75 0c             	pushl  0xc(%ebp)
f0105bd4:	ff 75 08             	pushl  0x8(%ebp)
f0105bd7:	e8 9a ff ff ff       	call   f0105b76 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105bdc:	c9                   	leave  
f0105bdd:	c3                   	ret    

f0105bde <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105bde:	55                   	push   %ebp
f0105bdf:	89 e5                	mov    %esp,%ebp
f0105be1:	57                   	push   %edi
f0105be2:	56                   	push   %esi
f0105be3:	53                   	push   %ebx
f0105be4:	83 ec 0c             	sub    $0xc,%esp
f0105be7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105bea:	85 c0                	test   %eax,%eax
f0105bec:	74 11                	je     f0105bff <readline+0x21>
		cprintf("%s", prompt);
f0105bee:	83 ec 08             	sub    $0x8,%esp
f0105bf1:	50                   	push   %eax
f0105bf2:	68 8d 7a 10 f0       	push   $0xf0107a8d
f0105bf7:	e8 76 e2 ff ff       	call   f0103e72 <cprintf>
f0105bfc:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105bff:	83 ec 0c             	sub    $0xc,%esp
f0105c02:	6a 00                	push   $0x0
f0105c04:	e8 d2 ac ff ff       	call   f01008db <iscons>
f0105c09:	89 c7                	mov    %eax,%edi
f0105c0b:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105c0e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105c13:	e8 b2 ac ff ff       	call   f01008ca <getchar>
f0105c18:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105c1a:	85 c0                	test   %eax,%eax
f0105c1c:	79 18                	jns    f0105c36 <readline+0x58>
			cprintf("read error: %e\n", c);
f0105c1e:	83 ec 08             	sub    $0x8,%esp
f0105c21:	50                   	push   %eax
f0105c22:	68 c4 86 10 f0       	push   $0xf01086c4
f0105c27:	e8 46 e2 ff ff       	call   f0103e72 <cprintf>
			return NULL;
f0105c2c:	83 c4 10             	add    $0x10,%esp
f0105c2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c34:	eb 79                	jmp    f0105caf <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105c36:	83 f8 08             	cmp    $0x8,%eax
f0105c39:	0f 94 c2             	sete   %dl
f0105c3c:	83 f8 7f             	cmp    $0x7f,%eax
f0105c3f:	0f 94 c0             	sete   %al
f0105c42:	08 c2                	or     %al,%dl
f0105c44:	74 1a                	je     f0105c60 <readline+0x82>
f0105c46:	85 f6                	test   %esi,%esi
f0105c48:	7e 16                	jle    f0105c60 <readline+0x82>
			if (echoing)
f0105c4a:	85 ff                	test   %edi,%edi
f0105c4c:	74 0d                	je     f0105c5b <readline+0x7d>
				cputchar('\b');
f0105c4e:	83 ec 0c             	sub    $0xc,%esp
f0105c51:	6a 08                	push   $0x8
f0105c53:	e8 62 ac ff ff       	call   f01008ba <cputchar>
f0105c58:	83 c4 10             	add    $0x10,%esp
			i--;
f0105c5b:	83 ee 01             	sub    $0x1,%esi
f0105c5e:	eb b3                	jmp    f0105c13 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c60:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c63:	7e 23                	jle    f0105c88 <readline+0xaa>
f0105c65:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c6b:	7f 1b                	jg     f0105c88 <readline+0xaa>
			if (echoing)
f0105c6d:	85 ff                	test   %edi,%edi
f0105c6f:	74 0c                	je     f0105c7d <readline+0x9f>
				cputchar(c);
f0105c71:	83 ec 0c             	sub    $0xc,%esp
f0105c74:	53                   	push   %ebx
f0105c75:	e8 40 ac ff ff       	call   f01008ba <cputchar>
f0105c7a:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105c7d:	88 9e a0 1a 24 f0    	mov    %bl,-0xfdbe560(%esi)
f0105c83:	8d 76 01             	lea    0x1(%esi),%esi
f0105c86:	eb 8b                	jmp    f0105c13 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105c88:	83 fb 0a             	cmp    $0xa,%ebx
f0105c8b:	74 05                	je     f0105c92 <readline+0xb4>
f0105c8d:	83 fb 0d             	cmp    $0xd,%ebx
f0105c90:	75 81                	jne    f0105c13 <readline+0x35>
			if (echoing)
f0105c92:	85 ff                	test   %edi,%edi
f0105c94:	74 0d                	je     f0105ca3 <readline+0xc5>
				cputchar('\n');
f0105c96:	83 ec 0c             	sub    $0xc,%esp
f0105c99:	6a 0a                	push   $0xa
f0105c9b:	e8 1a ac ff ff       	call   f01008ba <cputchar>
f0105ca0:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105ca3:	c6 86 a0 1a 24 f0 00 	movb   $0x0,-0xfdbe560(%esi)
			return buf;
f0105caa:	b8 a0 1a 24 f0       	mov    $0xf0241aa0,%eax
		}
	}
}
f0105caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cb2:	5b                   	pop    %ebx
f0105cb3:	5e                   	pop    %esi
f0105cb4:	5f                   	pop    %edi
f0105cb5:	5d                   	pop    %ebp
f0105cb6:	c3                   	ret    

f0105cb7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105cb7:	55                   	push   %ebp
f0105cb8:	89 e5                	mov    %esp,%ebp
f0105cba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105cbd:	80 3a 00             	cmpb   $0x0,(%edx)
f0105cc0:	74 10                	je     f0105cd2 <strlen+0x1b>
f0105cc2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105cc7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105cca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105cce:	75 f7                	jne    f0105cc7 <strlen+0x10>
f0105cd0:	eb 05                	jmp    f0105cd7 <strlen+0x20>
f0105cd2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105cd7:	5d                   	pop    %ebp
f0105cd8:	c3                   	ret    

f0105cd9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105cd9:	55                   	push   %ebp
f0105cda:	89 e5                	mov    %esp,%ebp
f0105cdc:	53                   	push   %ebx
f0105cdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ce3:	85 c9                	test   %ecx,%ecx
f0105ce5:	74 1c                	je     f0105d03 <strnlen+0x2a>
f0105ce7:	80 3b 00             	cmpb   $0x0,(%ebx)
f0105cea:	74 1e                	je     f0105d0a <strnlen+0x31>
f0105cec:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0105cf1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105cf3:	39 ca                	cmp    %ecx,%edx
f0105cf5:	74 18                	je     f0105d0f <strnlen+0x36>
f0105cf7:	83 c2 01             	add    $0x1,%edx
f0105cfa:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0105cff:	75 f0                	jne    f0105cf1 <strnlen+0x18>
f0105d01:	eb 0c                	jmp    f0105d0f <strnlen+0x36>
f0105d03:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d08:	eb 05                	jmp    f0105d0f <strnlen+0x36>
f0105d0a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105d0f:	5b                   	pop    %ebx
f0105d10:	5d                   	pop    %ebp
f0105d11:	c3                   	ret    

f0105d12 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105d12:	55                   	push   %ebp
f0105d13:	89 e5                	mov    %esp,%ebp
f0105d15:	53                   	push   %ebx
f0105d16:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105d1c:	89 c2                	mov    %eax,%edx
f0105d1e:	83 c2 01             	add    $0x1,%edx
f0105d21:	83 c1 01             	add    $0x1,%ecx
f0105d24:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105d28:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105d2b:	84 db                	test   %bl,%bl
f0105d2d:	75 ef                	jne    f0105d1e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105d2f:	5b                   	pop    %ebx
f0105d30:	5d                   	pop    %ebp
f0105d31:	c3                   	ret    

f0105d32 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105d32:	55                   	push   %ebp
f0105d33:	89 e5                	mov    %esp,%ebp
f0105d35:	53                   	push   %ebx
f0105d36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105d39:	53                   	push   %ebx
f0105d3a:	e8 78 ff ff ff       	call   f0105cb7 <strlen>
f0105d3f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105d42:	ff 75 0c             	pushl  0xc(%ebp)
f0105d45:	01 d8                	add    %ebx,%eax
f0105d47:	50                   	push   %eax
f0105d48:	e8 c5 ff ff ff       	call   f0105d12 <strcpy>
	return dst;
}
f0105d4d:	89 d8                	mov    %ebx,%eax
f0105d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105d52:	c9                   	leave  
f0105d53:	c3                   	ret    

f0105d54 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105d54:	55                   	push   %ebp
f0105d55:	89 e5                	mov    %esp,%ebp
f0105d57:	56                   	push   %esi
f0105d58:	53                   	push   %ebx
f0105d59:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d5c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d62:	85 db                	test   %ebx,%ebx
f0105d64:	74 17                	je     f0105d7d <strncpy+0x29>
f0105d66:	01 f3                	add    %esi,%ebx
f0105d68:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f0105d6a:	83 c1 01             	add    $0x1,%ecx
f0105d6d:	0f b6 02             	movzbl (%edx),%eax
f0105d70:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105d73:	80 3a 01             	cmpb   $0x1,(%edx)
f0105d76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d79:	39 cb                	cmp    %ecx,%ebx
f0105d7b:	75 ed                	jne    f0105d6a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105d7d:	89 f0                	mov    %esi,%eax
f0105d7f:	5b                   	pop    %ebx
f0105d80:	5e                   	pop    %esi
f0105d81:	5d                   	pop    %ebp
f0105d82:	c3                   	ret    

f0105d83 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d83:	55                   	push   %ebp
f0105d84:	89 e5                	mov    %esp,%ebp
f0105d86:	56                   	push   %esi
f0105d87:	53                   	push   %ebx
f0105d88:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d8e:	8b 55 10             	mov    0x10(%ebp),%edx
f0105d91:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d93:	85 d2                	test   %edx,%edx
f0105d95:	74 35                	je     f0105dcc <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f0105d97:	89 d0                	mov    %edx,%eax
f0105d99:	83 e8 01             	sub    $0x1,%eax
f0105d9c:	74 25                	je     f0105dc3 <strlcpy+0x40>
f0105d9e:	0f b6 0b             	movzbl (%ebx),%ecx
f0105da1:	84 c9                	test   %cl,%cl
f0105da3:	74 22                	je     f0105dc7 <strlcpy+0x44>
f0105da5:	8d 53 01             	lea    0x1(%ebx),%edx
f0105da8:	01 c3                	add    %eax,%ebx
f0105daa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f0105dac:	83 c0 01             	add    $0x1,%eax
f0105daf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105db2:	39 da                	cmp    %ebx,%edx
f0105db4:	74 13                	je     f0105dc9 <strlcpy+0x46>
f0105db6:	83 c2 01             	add    $0x1,%edx
f0105db9:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f0105dbd:	84 c9                	test   %cl,%cl
f0105dbf:	75 eb                	jne    f0105dac <strlcpy+0x29>
f0105dc1:	eb 06                	jmp    f0105dc9 <strlcpy+0x46>
f0105dc3:	89 f0                	mov    %esi,%eax
f0105dc5:	eb 02                	jmp    f0105dc9 <strlcpy+0x46>
f0105dc7:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105dc9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105dcc:	29 f0                	sub    %esi,%eax
}
f0105dce:	5b                   	pop    %ebx
f0105dcf:	5e                   	pop    %esi
f0105dd0:	5d                   	pop    %ebp
f0105dd1:	c3                   	ret    

f0105dd2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105dd2:	55                   	push   %ebp
f0105dd3:	89 e5                	mov    %esp,%ebp
f0105dd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105dd8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105ddb:	0f b6 01             	movzbl (%ecx),%eax
f0105dde:	84 c0                	test   %al,%al
f0105de0:	74 15                	je     f0105df7 <strcmp+0x25>
f0105de2:	3a 02                	cmp    (%edx),%al
f0105de4:	75 11                	jne    f0105df7 <strcmp+0x25>
		p++, q++;
f0105de6:	83 c1 01             	add    $0x1,%ecx
f0105de9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105dec:	0f b6 01             	movzbl (%ecx),%eax
f0105def:	84 c0                	test   %al,%al
f0105df1:	74 04                	je     f0105df7 <strcmp+0x25>
f0105df3:	3a 02                	cmp    (%edx),%al
f0105df5:	74 ef                	je     f0105de6 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105df7:	0f b6 c0             	movzbl %al,%eax
f0105dfa:	0f b6 12             	movzbl (%edx),%edx
f0105dfd:	29 d0                	sub    %edx,%eax
}
f0105dff:	5d                   	pop    %ebp
f0105e00:	c3                   	ret    

f0105e01 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105e01:	55                   	push   %ebp
f0105e02:	89 e5                	mov    %esp,%ebp
f0105e04:	56                   	push   %esi
f0105e05:	53                   	push   %ebx
f0105e06:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105e09:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e0c:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f0105e0f:	85 f6                	test   %esi,%esi
f0105e11:	74 29                	je     f0105e3c <strncmp+0x3b>
f0105e13:	0f b6 03             	movzbl (%ebx),%eax
f0105e16:	84 c0                	test   %al,%al
f0105e18:	74 30                	je     f0105e4a <strncmp+0x49>
f0105e1a:	3a 02                	cmp    (%edx),%al
f0105e1c:	75 2c                	jne    f0105e4a <strncmp+0x49>
f0105e1e:	8d 43 01             	lea    0x1(%ebx),%eax
f0105e21:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f0105e23:	89 c3                	mov    %eax,%ebx
f0105e25:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105e28:	39 c6                	cmp    %eax,%esi
f0105e2a:	74 17                	je     f0105e43 <strncmp+0x42>
f0105e2c:	0f b6 08             	movzbl (%eax),%ecx
f0105e2f:	84 c9                	test   %cl,%cl
f0105e31:	74 17                	je     f0105e4a <strncmp+0x49>
f0105e33:	83 c0 01             	add    $0x1,%eax
f0105e36:	3a 0a                	cmp    (%edx),%cl
f0105e38:	74 e9                	je     f0105e23 <strncmp+0x22>
f0105e3a:	eb 0e                	jmp    f0105e4a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105e3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e41:	eb 0f                	jmp    f0105e52 <strncmp+0x51>
f0105e43:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e48:	eb 08                	jmp    f0105e52 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105e4a:	0f b6 03             	movzbl (%ebx),%eax
f0105e4d:	0f b6 12             	movzbl (%edx),%edx
f0105e50:	29 d0                	sub    %edx,%eax
}
f0105e52:	5b                   	pop    %ebx
f0105e53:	5e                   	pop    %esi
f0105e54:	5d                   	pop    %ebp
f0105e55:	c3                   	ret    

f0105e56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105e56:	55                   	push   %ebp
f0105e57:	89 e5                	mov    %esp,%ebp
f0105e59:	53                   	push   %ebx
f0105e5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0105e60:	0f b6 10             	movzbl (%eax),%edx
f0105e63:	84 d2                	test   %dl,%dl
f0105e65:	74 1d                	je     f0105e84 <strchr+0x2e>
f0105e67:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f0105e69:	38 d3                	cmp    %dl,%bl
f0105e6b:	75 06                	jne    f0105e73 <strchr+0x1d>
f0105e6d:	eb 1a                	jmp    f0105e89 <strchr+0x33>
f0105e6f:	38 ca                	cmp    %cl,%dl
f0105e71:	74 16                	je     f0105e89 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105e73:	83 c0 01             	add    $0x1,%eax
f0105e76:	0f b6 10             	movzbl (%eax),%edx
f0105e79:	84 d2                	test   %dl,%dl
f0105e7b:	75 f2                	jne    f0105e6f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f0105e7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e82:	eb 05                	jmp    f0105e89 <strchr+0x33>
f0105e84:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e89:	5b                   	pop    %ebx
f0105e8a:	5d                   	pop    %ebp
f0105e8b:	c3                   	ret    

f0105e8c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105e8c:	55                   	push   %ebp
f0105e8d:	89 e5                	mov    %esp,%ebp
f0105e8f:	53                   	push   %ebx
f0105e90:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e93:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0105e96:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f0105e99:	38 d3                	cmp    %dl,%bl
f0105e9b:	74 14                	je     f0105eb1 <strfind+0x25>
f0105e9d:	89 d1                	mov    %edx,%ecx
f0105e9f:	84 db                	test   %bl,%bl
f0105ea1:	74 0e                	je     f0105eb1 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105ea3:	83 c0 01             	add    $0x1,%eax
f0105ea6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105ea9:	38 ca                	cmp    %cl,%dl
f0105eab:	74 04                	je     f0105eb1 <strfind+0x25>
f0105ead:	84 d2                	test   %dl,%dl
f0105eaf:	75 f2                	jne    f0105ea3 <strfind+0x17>
			break;
	return (char *) s;
}
f0105eb1:	5b                   	pop    %ebx
f0105eb2:	5d                   	pop    %ebp
f0105eb3:	c3                   	ret    

f0105eb4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105eb4:	55                   	push   %ebp
f0105eb5:	89 e5                	mov    %esp,%ebp
f0105eb7:	57                   	push   %edi
f0105eb8:	56                   	push   %esi
f0105eb9:	53                   	push   %ebx
f0105eba:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ebd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105ec0:	85 c9                	test   %ecx,%ecx
f0105ec2:	74 36                	je     f0105efa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105ec4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105eca:	75 28                	jne    f0105ef4 <memset+0x40>
f0105ecc:	f6 c1 03             	test   $0x3,%cl
f0105ecf:	75 23                	jne    f0105ef4 <memset+0x40>
		c &= 0xFF;
f0105ed1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105ed5:	89 d3                	mov    %edx,%ebx
f0105ed7:	c1 e3 08             	shl    $0x8,%ebx
f0105eda:	89 d6                	mov    %edx,%esi
f0105edc:	c1 e6 18             	shl    $0x18,%esi
f0105edf:	89 d0                	mov    %edx,%eax
f0105ee1:	c1 e0 10             	shl    $0x10,%eax
f0105ee4:	09 f0                	or     %esi,%eax
f0105ee6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105ee8:	89 d8                	mov    %ebx,%eax
f0105eea:	09 d0                	or     %edx,%eax
f0105eec:	c1 e9 02             	shr    $0x2,%ecx
f0105eef:	fc                   	cld    
f0105ef0:	f3 ab                	rep stos %eax,%es:(%edi)
f0105ef2:	eb 06                	jmp    f0105efa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ef7:	fc                   	cld    
f0105ef8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105efa:	89 f8                	mov    %edi,%eax
f0105efc:	5b                   	pop    %ebx
f0105efd:	5e                   	pop    %esi
f0105efe:	5f                   	pop    %edi
f0105eff:	5d                   	pop    %ebp
f0105f00:	c3                   	ret    

f0105f01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105f01:	55                   	push   %ebp
f0105f02:	89 e5                	mov    %esp,%ebp
f0105f04:	57                   	push   %edi
f0105f05:	56                   	push   %esi
f0105f06:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f09:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105f0f:	39 c6                	cmp    %eax,%esi
f0105f11:	73 35                	jae    f0105f48 <memmove+0x47>
f0105f13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105f16:	39 d0                	cmp    %edx,%eax
f0105f18:	73 2e                	jae    f0105f48 <memmove+0x47>
		s += n;
		d += n;
f0105f1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f1d:	89 d6                	mov    %edx,%esi
f0105f1f:	09 fe                	or     %edi,%esi
f0105f21:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105f27:	75 13                	jne    f0105f3c <memmove+0x3b>
f0105f29:	f6 c1 03             	test   $0x3,%cl
f0105f2c:	75 0e                	jne    f0105f3c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105f2e:	83 ef 04             	sub    $0x4,%edi
f0105f31:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105f34:	c1 e9 02             	shr    $0x2,%ecx
f0105f37:	fd                   	std    
f0105f38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105f3a:	eb 09                	jmp    f0105f45 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105f3c:	83 ef 01             	sub    $0x1,%edi
f0105f3f:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105f42:	fd                   	std    
f0105f43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105f45:	fc                   	cld    
f0105f46:	eb 1d                	jmp    f0105f65 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105f48:	89 f2                	mov    %esi,%edx
f0105f4a:	09 c2                	or     %eax,%edx
f0105f4c:	f6 c2 03             	test   $0x3,%dl
f0105f4f:	75 0f                	jne    f0105f60 <memmove+0x5f>
f0105f51:	f6 c1 03             	test   $0x3,%cl
f0105f54:	75 0a                	jne    f0105f60 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105f56:	c1 e9 02             	shr    $0x2,%ecx
f0105f59:	89 c7                	mov    %eax,%edi
f0105f5b:	fc                   	cld    
f0105f5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105f5e:	eb 05                	jmp    f0105f65 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105f60:	89 c7                	mov    %eax,%edi
f0105f62:	fc                   	cld    
f0105f63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105f65:	5e                   	pop    %esi
f0105f66:	5f                   	pop    %edi
f0105f67:	5d                   	pop    %ebp
f0105f68:	c3                   	ret    

f0105f69 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0105f69:	55                   	push   %ebp
f0105f6a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105f6c:	ff 75 10             	pushl  0x10(%ebp)
f0105f6f:	ff 75 0c             	pushl  0xc(%ebp)
f0105f72:	ff 75 08             	pushl  0x8(%ebp)
f0105f75:	e8 87 ff ff ff       	call   f0105f01 <memmove>
}
f0105f7a:	c9                   	leave  
f0105f7b:	c3                   	ret    

f0105f7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105f7c:	55                   	push   %ebp
f0105f7d:	89 e5                	mov    %esp,%ebp
f0105f7f:	57                   	push   %edi
f0105f80:	56                   	push   %esi
f0105f81:	53                   	push   %ebx
f0105f82:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105f85:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f88:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105f8b:	85 c0                	test   %eax,%eax
f0105f8d:	74 39                	je     f0105fc8 <memcmp+0x4c>
f0105f8f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f0105f92:	0f b6 13             	movzbl (%ebx),%edx
f0105f95:	0f b6 0e             	movzbl (%esi),%ecx
f0105f98:	38 ca                	cmp    %cl,%dl
f0105f9a:	75 17                	jne    f0105fb3 <memcmp+0x37>
f0105f9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fa1:	eb 1a                	jmp    f0105fbd <memcmp+0x41>
f0105fa3:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f0105fa8:	83 c0 01             	add    $0x1,%eax
f0105fab:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f0105faf:	38 ca                	cmp    %cl,%dl
f0105fb1:	74 0a                	je     f0105fbd <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0105fb3:	0f b6 c2             	movzbl %dl,%eax
f0105fb6:	0f b6 c9             	movzbl %cl,%ecx
f0105fb9:	29 c8                	sub    %ecx,%eax
f0105fbb:	eb 10                	jmp    f0105fcd <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105fbd:	39 f8                	cmp    %edi,%eax
f0105fbf:	75 e2                	jne    f0105fa3 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105fc1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fc6:	eb 05                	jmp    f0105fcd <memcmp+0x51>
f0105fc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105fcd:	5b                   	pop    %ebx
f0105fce:	5e                   	pop    %esi
f0105fcf:	5f                   	pop    %edi
f0105fd0:	5d                   	pop    %ebp
f0105fd1:	c3                   	ret    

f0105fd2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105fd2:	55                   	push   %ebp
f0105fd3:	89 e5                	mov    %esp,%ebp
f0105fd5:	53                   	push   %ebx
f0105fd6:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f0105fd9:	89 d0                	mov    %edx,%eax
f0105fdb:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f0105fde:	39 c2                	cmp    %eax,%edx
f0105fe0:	73 1d                	jae    f0105fff <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105fe2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f0105fe6:	0f b6 0a             	movzbl (%edx),%ecx
f0105fe9:	39 d9                	cmp    %ebx,%ecx
f0105feb:	75 09                	jne    f0105ff6 <memfind+0x24>
f0105fed:	eb 14                	jmp    f0106003 <memfind+0x31>
f0105fef:	0f b6 0a             	movzbl (%edx),%ecx
f0105ff2:	39 d9                	cmp    %ebx,%ecx
f0105ff4:	74 11                	je     f0106007 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105ff6:	83 c2 01             	add    $0x1,%edx
f0105ff9:	39 d0                	cmp    %edx,%eax
f0105ffb:	75 f2                	jne    f0105fef <memfind+0x1d>
f0105ffd:	eb 0a                	jmp    f0106009 <memfind+0x37>
f0105fff:	89 d0                	mov    %edx,%eax
f0106001:	eb 06                	jmp    f0106009 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106003:	89 d0                	mov    %edx,%eax
f0106005:	eb 02                	jmp    f0106009 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106007:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106009:	5b                   	pop    %ebx
f010600a:	5d                   	pop    %ebp
f010600b:	c3                   	ret    

f010600c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010600c:	55                   	push   %ebp
f010600d:	89 e5                	mov    %esp,%ebp
f010600f:	57                   	push   %edi
f0106010:	56                   	push   %esi
f0106011:	53                   	push   %ebx
f0106012:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106015:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106018:	0f b6 01             	movzbl (%ecx),%eax
f010601b:	3c 20                	cmp    $0x20,%al
f010601d:	74 04                	je     f0106023 <strtol+0x17>
f010601f:	3c 09                	cmp    $0x9,%al
f0106021:	75 0e                	jne    f0106031 <strtol+0x25>
		s++;
f0106023:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106026:	0f b6 01             	movzbl (%ecx),%eax
f0106029:	3c 20                	cmp    $0x20,%al
f010602b:	74 f6                	je     f0106023 <strtol+0x17>
f010602d:	3c 09                	cmp    $0x9,%al
f010602f:	74 f2                	je     f0106023 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106031:	3c 2b                	cmp    $0x2b,%al
f0106033:	75 0a                	jne    f010603f <strtol+0x33>
		s++;
f0106035:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106038:	bf 00 00 00 00       	mov    $0x0,%edi
f010603d:	eb 11                	jmp    f0106050 <strtol+0x44>
f010603f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106044:	3c 2d                	cmp    $0x2d,%al
f0106046:	75 08                	jne    f0106050 <strtol+0x44>
		s++, neg = 1;
f0106048:	83 c1 01             	add    $0x1,%ecx
f010604b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106050:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0106056:	75 15                	jne    f010606d <strtol+0x61>
f0106058:	80 39 30             	cmpb   $0x30,(%ecx)
f010605b:	75 10                	jne    f010606d <strtol+0x61>
f010605d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0106061:	75 7c                	jne    f01060df <strtol+0xd3>
		s += 2, base = 16;
f0106063:	83 c1 02             	add    $0x2,%ecx
f0106066:	bb 10 00 00 00       	mov    $0x10,%ebx
f010606b:	eb 16                	jmp    f0106083 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f010606d:	85 db                	test   %ebx,%ebx
f010606f:	75 12                	jne    f0106083 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106071:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106076:	80 39 30             	cmpb   $0x30,(%ecx)
f0106079:	75 08                	jne    f0106083 <strtol+0x77>
		s++, base = 8;
f010607b:	83 c1 01             	add    $0x1,%ecx
f010607e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0106083:	b8 00 00 00 00       	mov    $0x0,%eax
f0106088:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010608b:	0f b6 11             	movzbl (%ecx),%edx
f010608e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0106091:	89 f3                	mov    %esi,%ebx
f0106093:	80 fb 09             	cmp    $0x9,%bl
f0106096:	77 08                	ja     f01060a0 <strtol+0x94>
			dig = *s - '0';
f0106098:	0f be d2             	movsbl %dl,%edx
f010609b:	83 ea 30             	sub    $0x30,%edx
f010609e:	eb 22                	jmp    f01060c2 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f01060a0:	8d 72 9f             	lea    -0x61(%edx),%esi
f01060a3:	89 f3                	mov    %esi,%ebx
f01060a5:	80 fb 19             	cmp    $0x19,%bl
f01060a8:	77 08                	ja     f01060b2 <strtol+0xa6>
			dig = *s - 'a' + 10;
f01060aa:	0f be d2             	movsbl %dl,%edx
f01060ad:	83 ea 57             	sub    $0x57,%edx
f01060b0:	eb 10                	jmp    f01060c2 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f01060b2:	8d 72 bf             	lea    -0x41(%edx),%esi
f01060b5:	89 f3                	mov    %esi,%ebx
f01060b7:	80 fb 19             	cmp    $0x19,%bl
f01060ba:	77 16                	ja     f01060d2 <strtol+0xc6>
			dig = *s - 'A' + 10;
f01060bc:	0f be d2             	movsbl %dl,%edx
f01060bf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01060c2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01060c5:	7d 0b                	jge    f01060d2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f01060c7:	83 c1 01             	add    $0x1,%ecx
f01060ca:	0f af 45 10          	imul   0x10(%ebp),%eax
f01060ce:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01060d0:	eb b9                	jmp    f010608b <strtol+0x7f>

	if (endptr)
f01060d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01060d6:	74 0d                	je     f01060e5 <strtol+0xd9>
		*endptr = (char *) s;
f01060d8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01060db:	89 0e                	mov    %ecx,(%esi)
f01060dd:	eb 06                	jmp    f01060e5 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01060df:	85 db                	test   %ebx,%ebx
f01060e1:	74 98                	je     f010607b <strtol+0x6f>
f01060e3:	eb 9e                	jmp    f0106083 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01060e5:	89 c2                	mov    %eax,%edx
f01060e7:	f7 da                	neg    %edx
f01060e9:	85 ff                	test   %edi,%edi
f01060eb:	0f 45 c2             	cmovne %edx,%eax
}
f01060ee:	5b                   	pop    %ebx
f01060ef:	5e                   	pop    %esi
f01060f0:	5f                   	pop    %edi
f01060f1:	5d                   	pop    %ebp
f01060f2:	c3                   	ret    
f01060f3:	90                   	nop

f01060f4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01060f4:	fa                   	cli    

	xorw    %ax, %ax
f01060f5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01060f7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01060f9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01060fb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01060fd:	0f 01 16             	lgdtl  (%esi)
f0106100:	74 70                	je     f0106172 <mpsearch1+0x3>
	movl    %cr0, %eax
f0106102:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106105:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106109:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010610c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106112:	08 00                	or     %al,(%eax)

f0106114 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106114:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106118:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010611a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010611c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010611e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106122:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106124:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106126:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f010612b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010612e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106131:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106136:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0106139:	8b 25 a4 1e 24 f0    	mov    0xf0241ea4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010613f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106144:	b8 fb 02 10 f0       	mov    $0xf01002fb,%eax
	call    *%eax
f0106149:	ff d0                	call   *%eax

f010614b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010614b:	eb fe                	jmp    f010614b <spin>
f010614d:	8d 76 00             	lea    0x0(%esi),%esi

f0106150 <gdt>:
	...
f0106158:	ff                   	(bad)  
f0106159:	ff 00                	incl   (%eax)
f010615b:	00 00                	add    %al,(%eax)
f010615d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106164:	00                   	.byte 0x0
f0106165:	92                   	xchg   %eax,%edx
f0106166:	cf                   	iret   
	...

f0106168 <gdtdesc>:
f0106168:	17                   	pop    %ss
f0106169:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010616e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010616e:	90                   	nop

f010616f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010616f:	55                   	push   %ebp
f0106170:	89 e5                	mov    %esp,%ebp
f0106172:	57                   	push   %edi
f0106173:	56                   	push   %esi
f0106174:	53                   	push   %ebx
f0106175:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106178:	8b 0d a8 1e 24 f0    	mov    0xf0241ea8,%ecx
f010617e:	89 c3                	mov    %eax,%ebx
f0106180:	c1 eb 0c             	shr    $0xc,%ebx
f0106183:	39 cb                	cmp    %ecx,%ebx
f0106185:	72 12                	jb     f0106199 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106187:	50                   	push   %eax
f0106188:	68 a0 6c 10 f0       	push   $0xf0106ca0
f010618d:	6a 57                	push   $0x57
f010618f:	68 61 88 10 f0       	push   $0xf0108861
f0106194:	e8 a7 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106199:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010619f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061a1:	89 c2                	mov    %eax,%edx
f01061a3:	c1 ea 0c             	shr    $0xc,%edx
f01061a6:	39 ca                	cmp    %ecx,%edx
f01061a8:	72 12                	jb     f01061bc <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061aa:	50                   	push   %eax
f01061ab:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01061b0:	6a 57                	push   $0x57
f01061b2:	68 61 88 10 f0       	push   $0xf0108861
f01061b7:	e8 84 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01061bc:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01061c2:	39 de                	cmp    %ebx,%esi
f01061c4:	76 3f                	jbe    f0106205 <mpsearch1+0x96>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01061c6:	83 ec 04             	sub    $0x4,%esp
f01061c9:	6a 04                	push   $0x4
f01061cb:	68 71 88 10 f0       	push   $0xf0108871
f01061d0:	53                   	push   %ebx
f01061d1:	e8 a6 fd ff ff       	call   f0105f7c <memcmp>
f01061d6:	83 c4 10             	add    $0x10,%esp
f01061d9:	85 c0                	test   %eax,%eax
f01061db:	75 1a                	jne    f01061f7 <mpsearch1+0x88>
f01061dd:	89 d8                	mov    %ebx,%eax
f01061df:	8d 7b 10             	lea    0x10(%ebx),%edi
f01061e2:	ba 00 00 00 00       	mov    $0x0,%edx
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01061e7:	0f b6 08             	movzbl (%eax),%ecx
f01061ea:	01 ca                	add    %ecx,%edx
f01061ec:	83 c0 01             	add    $0x1,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01061ef:	39 c7                	cmp    %eax,%edi
f01061f1:	75 f4                	jne    f01061e7 <mpsearch1+0x78>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01061f3:	84 d2                	test   %dl,%dl
f01061f5:	74 15                	je     f010620c <mpsearch1+0x9d>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01061f7:	83 c3 10             	add    $0x10,%ebx
f01061fa:	39 f3                	cmp    %esi,%ebx
f01061fc:	72 c8                	jb     f01061c6 <mpsearch1+0x57>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01061fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0106203:	eb 09                	jmp    f010620e <mpsearch1+0x9f>
f0106205:	b8 00 00 00 00       	mov    $0x0,%eax
f010620a:	eb 02                	jmp    f010620e <mpsearch1+0x9f>
f010620c:	89 d8                	mov    %ebx,%eax
}
f010620e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106211:	5b                   	pop    %ebx
f0106212:	5e                   	pop    %esi
f0106213:	5f                   	pop    %edi
f0106214:	5d                   	pop    %ebp
f0106215:	c3                   	ret    

f0106216 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106216:	55                   	push   %ebp
f0106217:	89 e5                	mov    %esp,%ebp
f0106219:	57                   	push   %edi
f010621a:	56                   	push   %esi
f010621b:	53                   	push   %ebx
f010621c:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010621f:	c7 05 c0 23 24 f0 20 	movl   $0xf0242020,0xf02423c0
f0106226:	20 24 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106229:	83 3d a8 1e 24 f0 00 	cmpl   $0x0,0xf0241ea8
f0106230:	75 16                	jne    f0106248 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106232:	68 00 04 00 00       	push   $0x400
f0106237:	68 a0 6c 10 f0       	push   $0xf0106ca0
f010623c:	6a 6f                	push   $0x6f
f010623e:	68 61 88 10 f0       	push   $0xf0108861
f0106243:	e8 f8 9d ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106248:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010624f:	85 c0                	test   %eax,%eax
f0106251:	74 16                	je     f0106269 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0106253:	c1 e0 04             	shl    $0x4,%eax
f0106256:	ba 00 04 00 00       	mov    $0x400,%edx
f010625b:	e8 0f ff ff ff       	call   f010616f <mpsearch1>
f0106260:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106263:	85 c0                	test   %eax,%eax
f0106265:	75 3c                	jne    f01062a3 <mp_init+0x8d>
f0106267:	eb 20                	jmp    f0106289 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106269:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106270:	c1 e0 0a             	shl    $0xa,%eax
f0106273:	2d 00 04 00 00       	sub    $0x400,%eax
f0106278:	ba 00 04 00 00       	mov    $0x400,%edx
f010627d:	e8 ed fe ff ff       	call   f010616f <mpsearch1>
f0106282:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106285:	85 c0                	test   %eax,%eax
f0106287:	75 1a                	jne    f01062a3 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106289:	ba 00 00 01 00       	mov    $0x10000,%edx
f010628e:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106293:	e8 d7 fe ff ff       	call   f010616f <mpsearch1>
f0106298:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010629b:	85 c0                	test   %eax,%eax
f010629d:	0f 84 6c 02 00 00    	je     f010650f <mp_init+0x2f9>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01062a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01062a6:	8b 70 04             	mov    0x4(%eax),%esi
f01062a9:	85 f6                	test   %esi,%esi
f01062ab:	74 06                	je     f01062b3 <mp_init+0x9d>
f01062ad:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01062b1:	74 15                	je     f01062c8 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01062b3:	83 ec 0c             	sub    $0xc,%esp
f01062b6:	68 d4 86 10 f0       	push   $0xf01086d4
f01062bb:	e8 b2 db ff ff       	call   f0103e72 <cprintf>
f01062c0:	83 c4 10             	add    $0x10,%esp
f01062c3:	e9 47 02 00 00       	jmp    f010650f <mp_init+0x2f9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062c8:	89 f0                	mov    %esi,%eax
f01062ca:	c1 e8 0c             	shr    $0xc,%eax
f01062cd:	3b 05 a8 1e 24 f0    	cmp    0xf0241ea8,%eax
f01062d3:	72 15                	jb     f01062ea <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062d5:	56                   	push   %esi
f01062d6:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01062db:	68 90 00 00 00       	push   $0x90
f01062e0:	68 61 88 10 f0       	push   $0xf0108861
f01062e5:	e8 56 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01062ea:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01062f0:	83 ec 04             	sub    $0x4,%esp
f01062f3:	6a 04                	push   $0x4
f01062f5:	68 76 88 10 f0       	push   $0xf0108876
f01062fa:	53                   	push   %ebx
f01062fb:	e8 7c fc ff ff       	call   f0105f7c <memcmp>
f0106300:	83 c4 10             	add    $0x10,%esp
f0106303:	85 c0                	test   %eax,%eax
f0106305:	74 15                	je     f010631c <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106307:	83 ec 0c             	sub    $0xc,%esp
f010630a:	68 04 87 10 f0       	push   $0xf0108704
f010630f:	e8 5e db ff ff       	call   f0103e72 <cprintf>
f0106314:	83 c4 10             	add    $0x10,%esp
f0106317:	e9 f3 01 00 00       	jmp    f010650f <mp_init+0x2f9>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010631c:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0106320:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0106324:	0f b7 f8             	movzwl %ax,%edi
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106327:	85 ff                	test   %edi,%edi
f0106329:	7e 34                	jle    f010635f <mp_init+0x149>
f010632b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106330:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0106335:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f010633c:	f0 
f010633d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010633f:	83 c0 01             	add    $0x1,%eax
f0106342:	39 c7                	cmp    %eax,%edi
f0106344:	75 ef                	jne    f0106335 <mp_init+0x11f>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106346:	84 d2                	test   %dl,%dl
f0106348:	74 15                	je     f010635f <mp_init+0x149>
		cprintf("SMP: Bad MP configuration checksum\n");
f010634a:	83 ec 0c             	sub    $0xc,%esp
f010634d:	68 38 87 10 f0       	push   $0xf0108738
f0106352:	e8 1b db ff ff       	call   f0103e72 <cprintf>
f0106357:	83 c4 10             	add    $0x10,%esp
f010635a:	e9 b0 01 00 00       	jmp    f010650f <mp_init+0x2f9>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010635f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106363:	3c 01                	cmp    $0x1,%al
f0106365:	74 1d                	je     f0106384 <mp_init+0x16e>
f0106367:	3c 04                	cmp    $0x4,%al
f0106369:	74 19                	je     f0106384 <mp_init+0x16e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010636b:	83 ec 08             	sub    $0x8,%esp
f010636e:	0f b6 c0             	movzbl %al,%eax
f0106371:	50                   	push   %eax
f0106372:	68 5c 87 10 f0       	push   $0xf010875c
f0106377:	e8 f6 da ff ff       	call   f0103e72 <cprintf>
f010637c:	83 c4 10             	add    $0x10,%esp
f010637f:	e9 8b 01 00 00       	jmp    f010650f <mp_init+0x2f9>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106384:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0106388:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010638c:	85 ff                	test   %edi,%edi
f010638e:	7e 1f                	jle    f01063af <mp_init+0x199>
f0106390:	ba 00 00 00 00       	mov    $0x0,%edx
f0106395:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010639a:	01 ce                	add    %ecx,%esi
f010639c:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01063a3:	f0 
f01063a4:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01063a6:	83 c0 01             	add    $0x1,%eax
f01063a9:	39 c7                	cmp    %eax,%edi
f01063ab:	75 ef                	jne    f010639c <mp_init+0x186>
f01063ad:	eb 05                	jmp    f01063b4 <mp_init+0x19e>
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01063af:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f01063b4:	38 53 2a             	cmp    %dl,0x2a(%ebx)
f01063b7:	74 15                	je     f01063ce <mp_init+0x1b8>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01063b9:	83 ec 0c             	sub    $0xc,%esp
f01063bc:	68 7c 87 10 f0       	push   $0xf010877c
f01063c1:	e8 ac da ff ff       	call   f0103e72 <cprintf>
f01063c6:	83 c4 10             	add    $0x10,%esp
f01063c9:	e9 41 01 00 00       	jmp    f010650f <mp_init+0x2f9>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01063ce:	85 db                	test   %ebx,%ebx
f01063d0:	0f 84 39 01 00 00    	je     f010650f <mp_init+0x2f9>
		return;
	ismp = 1;
f01063d6:	c7 05 00 20 24 f0 01 	movl   $0x1,0xf0242000
f01063dd:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f01063e0:	8b 43 24             	mov    0x24(%ebx),%eax
f01063e3:	a3 00 30 28 f0       	mov    %eax,0xf0283000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01063e8:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01063eb:	66 83 7b 22 00       	cmpw   $0x0,0x22(%ebx)
f01063f0:	0f 84 96 00 00 00    	je     f010648c <mp_init+0x276>
f01063f6:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f01063fb:	0f b6 07             	movzbl (%edi),%eax
f01063fe:	84 c0                	test   %al,%al
f0106400:	74 06                	je     f0106408 <mp_init+0x1f2>
f0106402:	3c 04                	cmp    $0x4,%al
f0106404:	77 55                	ja     f010645b <mp_init+0x245>
f0106406:	eb 4e                	jmp    f0106456 <mp_init+0x240>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106408:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010640c:	74 11                	je     f010641f <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f010640e:	6b 05 c4 23 24 f0 74 	imul   $0x74,0xf02423c4,%eax
f0106415:	05 20 20 24 f0       	add    $0xf0242020,%eax
f010641a:	a3 c0 23 24 f0       	mov    %eax,0xf02423c0
			if (ncpu < NCPU) {
f010641f:	a1 c4 23 24 f0       	mov    0xf02423c4,%eax
f0106424:	83 f8 07             	cmp    $0x7,%eax
f0106427:	7f 13                	jg     f010643c <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f0106429:	6b d0 74             	imul   $0x74,%eax,%edx
f010642c:	88 82 20 20 24 f0    	mov    %al,-0xfdbdfe0(%edx)
				ncpu++;
f0106432:	83 c0 01             	add    $0x1,%eax
f0106435:	a3 c4 23 24 f0       	mov    %eax,0xf02423c4
f010643a:	eb 15                	jmp    f0106451 <mp_init+0x23b>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010643c:	83 ec 08             	sub    $0x8,%esp
f010643f:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106443:	50                   	push   %eax
f0106444:	68 ac 87 10 f0       	push   $0xf01087ac
f0106449:	e8 24 da ff ff       	call   f0103e72 <cprintf>
f010644e:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106451:	83 c7 14             	add    $0x14,%edi
			continue;
f0106454:	eb 27                	jmp    f010647d <mp_init+0x267>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106456:	83 c7 08             	add    $0x8,%edi
			continue;
f0106459:	eb 22                	jmp    f010647d <mp_init+0x267>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010645b:	83 ec 08             	sub    $0x8,%esp
f010645e:	0f b6 c0             	movzbl %al,%eax
f0106461:	50                   	push   %eax
f0106462:	68 d4 87 10 f0       	push   $0xf01087d4
f0106467:	e8 06 da ff ff       	call   f0103e72 <cprintf>
			ismp = 0;
f010646c:	c7 05 00 20 24 f0 00 	movl   $0x0,0xf0242000
f0106473:	00 00 00 
			i = conf->entry;
f0106476:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f010647a:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010647d:	83 c6 01             	add    $0x1,%esi
f0106480:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106484:	39 f0                	cmp    %esi,%eax
f0106486:	0f 87 6f ff ff ff    	ja     f01063fb <mp_init+0x1e5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010648c:	a1 c0 23 24 f0       	mov    0xf02423c0,%eax
f0106491:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106498:	83 3d 00 20 24 f0 00 	cmpl   $0x0,0xf0242000
f010649f:	75 26                	jne    f01064c7 <mp_init+0x2b1>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01064a1:	c7 05 c4 23 24 f0 01 	movl   $0x1,0xf02423c4
f01064a8:	00 00 00 
		lapic = NULL;
f01064ab:	c7 05 00 30 28 f0 00 	movl   $0x0,0xf0283000
f01064b2:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01064b5:	83 ec 0c             	sub    $0xc,%esp
f01064b8:	68 f4 87 10 f0       	push   $0xf01087f4
f01064bd:	e8 b0 d9 ff ff       	call   f0103e72 <cprintf>
		return;
f01064c2:	83 c4 10             	add    $0x10,%esp
f01064c5:	eb 48                	jmp    f010650f <mp_init+0x2f9>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01064c7:	83 ec 04             	sub    $0x4,%esp
f01064ca:	ff 35 c4 23 24 f0    	pushl  0xf02423c4
f01064d0:	0f b6 00             	movzbl (%eax),%eax
f01064d3:	50                   	push   %eax
f01064d4:	68 7b 88 10 f0       	push   $0xf010887b
f01064d9:	e8 94 d9 ff ff       	call   f0103e72 <cprintf>

	if (mp->imcrp) {
f01064de:	83 c4 10             	add    $0x10,%esp
f01064e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064e4:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01064e8:	74 25                	je     f010650f <mp_init+0x2f9>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01064ea:	83 ec 0c             	sub    $0xc,%esp
f01064ed:	68 20 88 10 f0       	push   $0xf0108820
f01064f2:	e8 7b d9 ff ff       	call   f0103e72 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01064f7:	ba 22 00 00 00       	mov    $0x22,%edx
f01064fc:	b8 70 00 00 00       	mov    $0x70,%eax
f0106501:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106502:	ba 23 00 00 00       	mov    $0x23,%edx
f0106507:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106508:	83 c8 01             	or     $0x1,%eax
f010650b:	ee                   	out    %al,(%dx)
f010650c:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010650f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106512:	5b                   	pop    %ebx
f0106513:	5e                   	pop    %esi
f0106514:	5f                   	pop    %edi
f0106515:	5d                   	pop    %ebp
f0106516:	c3                   	ret    

f0106517 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f0106517:	55                   	push   %ebp
f0106518:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010651a:	8b 0d 00 30 28 f0    	mov    0xf0283000,%ecx
f0106520:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106523:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106525:	a1 00 30 28 f0       	mov    0xf0283000,%eax
f010652a:	8b 40 20             	mov    0x20(%eax),%eax
}
f010652d:	5d                   	pop    %ebp
f010652e:	c3                   	ret    

f010652f <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010652f:	55                   	push   %ebp
f0106530:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106532:	a1 00 30 28 f0       	mov    0xf0283000,%eax
f0106537:	85 c0                	test   %eax,%eax
f0106539:	74 08                	je     f0106543 <cpunum+0x14>
		return lapic[ID] >> 24;
f010653b:	8b 40 20             	mov    0x20(%eax),%eax
f010653e:	c1 e8 18             	shr    $0x18,%eax
f0106541:	eb 05                	jmp    f0106548 <cpunum+0x19>
	return 0;
f0106543:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106548:	5d                   	pop    %ebp
f0106549:	c3                   	ret    

f010654a <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapic) 
f010654a:	83 3d 00 30 28 f0 00 	cmpl   $0x0,0xf0283000
f0106551:	0f 84 0b 01 00 00    	je     f0106662 <lapic_init+0x118>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106557:	55                   	push   %ebp
f0106558:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010655a:	ba 27 01 00 00       	mov    $0x127,%edx
f010655f:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106564:	e8 ae ff ff ff       	call   f0106517 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106569:	ba 0b 00 00 00       	mov    $0xb,%edx
f010656e:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106573:	e8 9f ff ff ff       	call   f0106517 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106578:	ba 20 00 02 00       	mov    $0x20020,%edx
f010657d:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106582:	e8 90 ff ff ff       	call   f0106517 <lapicw>
	lapicw(TICR, 10000000); 
f0106587:	ba 80 96 98 00       	mov    $0x989680,%edx
f010658c:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106591:	e8 81 ff ff ff       	call   f0106517 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106596:	e8 94 ff ff ff       	call   f010652f <cpunum>
f010659b:	6b c0 74             	imul   $0x74,%eax,%eax
f010659e:	05 20 20 24 f0       	add    $0xf0242020,%eax
f01065a3:	39 05 c0 23 24 f0    	cmp    %eax,0xf02423c0
f01065a9:	74 0f                	je     f01065ba <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f01065ab:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065b0:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01065b5:	e8 5d ff ff ff       	call   f0106517 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01065ba:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065bf:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01065c4:	e8 4e ff ff ff       	call   f0106517 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01065c9:	a1 00 30 28 f0       	mov    0xf0283000,%eax
f01065ce:	8b 40 30             	mov    0x30(%eax),%eax
f01065d1:	c1 e8 10             	shr    $0x10,%eax
f01065d4:	3c 03                	cmp    $0x3,%al
f01065d6:	76 0f                	jbe    f01065e7 <lapic_init+0x9d>
		lapicw(PCINT, MASKED);
f01065d8:	ba 00 00 01 00       	mov    $0x10000,%edx
f01065dd:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01065e2:	e8 30 ff ff ff       	call   f0106517 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01065e7:	ba 33 00 00 00       	mov    $0x33,%edx
f01065ec:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01065f1:	e8 21 ff ff ff       	call   f0106517 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01065f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01065fb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106600:	e8 12 ff ff ff       	call   f0106517 <lapicw>
	lapicw(ESR, 0);
f0106605:	ba 00 00 00 00       	mov    $0x0,%edx
f010660a:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010660f:	e8 03 ff ff ff       	call   f0106517 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106614:	ba 00 00 00 00       	mov    $0x0,%edx
f0106619:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010661e:	e8 f4 fe ff ff       	call   f0106517 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106623:	ba 00 00 00 00       	mov    $0x0,%edx
f0106628:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010662d:	e8 e5 fe ff ff       	call   f0106517 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106632:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106637:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010663c:	e8 d6 fe ff ff       	call   f0106517 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106641:	8b 15 00 30 28 f0    	mov    0xf0283000,%edx
f0106647:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010664d:	f6 c4 10             	test   $0x10,%ah
f0106650:	75 f5                	jne    f0106647 <lapic_init+0xfd>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106652:	ba 00 00 00 00       	mov    $0x0,%edx
f0106657:	b8 20 00 00 00       	mov    $0x20,%eax
f010665c:	e8 b6 fe ff ff       	call   f0106517 <lapicw>
}
f0106661:	5d                   	pop    %ebp
f0106662:	f3 c3                	repz ret 

f0106664 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106664:	83 3d 00 30 28 f0 00 	cmpl   $0x0,0xf0283000
f010666b:	74 13                	je     f0106680 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010666d:	55                   	push   %ebp
f010666e:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106670:	ba 00 00 00 00       	mov    $0x0,%edx
f0106675:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010667a:	e8 98 fe ff ff       	call   f0106517 <lapicw>
}
f010667f:	5d                   	pop    %ebp
f0106680:	f3 c3                	repz ret 

f0106682 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106682:	55                   	push   %ebp
f0106683:	89 e5                	mov    %esp,%ebp
f0106685:	56                   	push   %esi
f0106686:	53                   	push   %ebx
f0106687:	8b 75 08             	mov    0x8(%ebp),%esi
f010668a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010668d:	ba 70 00 00 00       	mov    $0x70,%edx
f0106692:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106697:	ee                   	out    %al,(%dx)
f0106698:	ba 71 00 00 00       	mov    $0x71,%edx
f010669d:	b8 0a 00 00 00       	mov    $0xa,%eax
f01066a2:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01066a3:	83 3d a8 1e 24 f0 00 	cmpl   $0x0,0xf0241ea8
f01066aa:	75 19                	jne    f01066c5 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01066ac:	68 67 04 00 00       	push   $0x467
f01066b1:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01066b6:	68 93 00 00 00       	push   $0x93
f01066bb:	68 98 88 10 f0       	push   $0xf0108898
f01066c0:	e8 7b 99 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01066c5:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01066cc:	00 00 
	wrv[1] = addr >> 4;
f01066ce:	89 d8                	mov    %ebx,%eax
f01066d0:	c1 e8 04             	shr    $0x4,%eax
f01066d3:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01066d9:	c1 e6 18             	shl    $0x18,%esi
f01066dc:	89 f2                	mov    %esi,%edx
f01066de:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01066e3:	e8 2f fe ff ff       	call   f0106517 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01066e8:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01066ed:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066f2:	e8 20 fe ff ff       	call   f0106517 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01066f7:	ba 00 85 00 00       	mov    $0x8500,%edx
f01066fc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106701:	e8 11 fe ff ff       	call   f0106517 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106706:	c1 eb 0c             	shr    $0xc,%ebx
f0106709:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010670c:	89 f2                	mov    %esi,%edx
f010670e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106713:	e8 ff fd ff ff       	call   f0106517 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106718:	89 da                	mov    %ebx,%edx
f010671a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010671f:	e8 f3 fd ff ff       	call   f0106517 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106724:	89 f2                	mov    %esi,%edx
f0106726:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010672b:	e8 e7 fd ff ff       	call   f0106517 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106730:	89 da                	mov    %ebx,%edx
f0106732:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106737:	e8 db fd ff ff       	call   f0106517 <lapicw>
		microdelay(200);
	}
}
f010673c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010673f:	5b                   	pop    %ebx
f0106740:	5e                   	pop    %esi
f0106741:	5d                   	pop    %ebp
f0106742:	c3                   	ret    

f0106743 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106743:	55                   	push   %ebp
f0106744:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106746:	8b 55 08             	mov    0x8(%ebp),%edx
f0106749:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010674f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106754:	e8 be fd ff ff       	call   f0106517 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106759:	8b 15 00 30 28 f0    	mov    0xf0283000,%edx
f010675f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106765:	f6 c4 10             	test   $0x10,%ah
f0106768:	75 f5                	jne    f010675f <lapic_ipi+0x1c>
		;
}
f010676a:	5d                   	pop    %ebp
f010676b:	c3                   	ret    

f010676c <atomic_return_and_add>:
// This is the atomic instruction that
// reading the old value as well as doing the add operation.
// If your gcc cannot support this function, report to TA.
#ifdef USE_TICKET_SPIN_LOCK
unsigned atomic_return_and_add(volatile unsigned *addr, unsigned value)
{
f010676c:	55                   	push   %ebp
f010676d:	89 e5                	mov    %esp,%ebp
f010676f:	8b 55 08             	mov    0x8(%ebp),%edx
	return __sync_fetch_and_add(addr, value);
f0106772:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106775:	f0 0f c1 02          	lock xadd %eax,(%edx)
}
f0106779:	5d                   	pop    %ebp
f010677a:	c3                   	ret    

f010677b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010677b:	55                   	push   %ebp
f010677c:	89 e5                	mov    %esp,%ebp
f010677e:	8b 45 08             	mov    0x8(%ebp),%eax
#ifndef USE_TICKET_SPIN_LOCK
	lk->locked = 0;
#else
	//LAB 4: Your code here
	lk->own = 0;
f0106781:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lk->next = 0;
f0106787:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

#endif

#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010678e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106791:	89 50 08             	mov    %edx,0x8(%eax)
	lk->cpu = 0;
f0106794:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#endif
}
f010679b:	5d                   	pop    %ebp
f010679c:	c3                   	ret    

f010679d <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010679d:	55                   	push   %ebp
f010679e:	89 e5                	mov    %esp,%ebp
f01067a0:	56                   	push   %esi
f01067a1:	53                   	push   %ebx
f01067a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
{
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
#else
	//LAB 4: Your code here
	return lock->own != lock->next && lock->cpu == thiscpu;
f01067a5:	8b 13                	mov    (%ebx),%edx
f01067a7:	8b 43 04             	mov    0x4(%ebx),%eax
f01067aa:	39 c2                	cmp    %eax,%edx
f01067ac:	74 32                	je     f01067e0 <spin_lock+0x43>
f01067ae:	8b 73 0c             	mov    0xc(%ebx),%esi
f01067b1:	e8 79 fd ff ff       	call   f010652f <cpunum>
f01067b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01067b9:	05 20 20 24 f0       	add    $0xf0242020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01067be:	39 c6                	cmp    %eax,%esi
f01067c0:	75 1e                	jne    f01067e0 <spin_lock+0x43>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01067c2:	8b 5b 08             	mov    0x8(%ebx),%ebx
f01067c5:	e8 65 fd ff ff       	call   f010652f <cpunum>
f01067ca:	83 ec 0c             	sub    $0xc,%esp
f01067cd:	53                   	push   %ebx
f01067ce:	50                   	push   %eax
f01067cf:	68 a8 88 10 f0       	push   $0xf01088a8
f01067d4:	6a 5b                	push   $0x5b
f01067d6:	68 0c 89 10 f0       	push   $0xf010890c
f01067db:	e8 60 98 ff ff       	call   f0100040 <_panic>
	// reordered before it.
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
#else
	//LAB 4: Your code here
	unsigned ticket = atomic_return_and_add(&(lk->next), 1);
f01067e0:	83 ec 08             	sub    $0x8,%esp
f01067e3:	6a 01                	push   $0x1
f01067e5:	8d 43 04             	lea    0x4(%ebx),%eax
f01067e8:	50                   	push   %eax
f01067e9:	e8 7e ff ff ff       	call   f010676c <atomic_return_and_add>
	while (ticket != lk->own)
f01067ee:	8b 13                	mov    (%ebx),%edx
f01067f0:	83 c4 10             	add    $0x10,%esp
f01067f3:	39 d0                	cmp    %edx,%eax
f01067f5:	74 08                	je     f01067ff <spin_lock+0x62>
		asm volatile ("pause");
f01067f7:	f3 90                	pause  
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
#else
	//LAB 4: Your code here
	unsigned ticket = atomic_return_and_add(&(lk->next), 1);
	while (ticket != lk->own)
f01067f9:	8b 13                	mov    (%ebx),%edx
f01067fb:	39 d0                	cmp    %edx,%eax
f01067fd:	75 f8                	jne    f01067f7 <spin_lock+0x5a>

#endif

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01067ff:	e8 2b fd ff ff       	call   f010652f <cpunum>
f0106804:	6b c0 74             	imul   $0x74,%eax,%eax
f0106807:	05 20 20 24 f0       	add    $0xf0242020,%eax
f010680c:	89 43 0c             	mov    %eax,0xc(%ebx)
	get_caller_pcs(lk->pcs);
f010680f:	8d 4b 10             	lea    0x10(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106812:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0106814:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f010681a:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0106820:	76 3a                	jbe    f010685c <spin_lock+0xbf>
f0106822:	eb 31                	jmp    f0106855 <spin_lock+0xb8>
f0106824:	8d 9a 00 00 80 10    	lea    0x10800000(%edx),%ebx
f010682a:	81 fb ff ff 7f 0e    	cmp    $0xe7fffff,%ebx
f0106830:	77 12                	ja     f0106844 <spin_lock+0xa7>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106832:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106835:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106838:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010683a:	83 c0 01             	add    $0x1,%eax
f010683d:	83 f8 0a             	cmp    $0xa,%eax
f0106840:	75 e2                	jne    f0106824 <spin_lock+0x87>
f0106842:	eb 27                	jmp    f010686b <spin_lock+0xce>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106844:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010684b:	83 c0 01             	add    $0x1,%eax
f010684e:	83 f8 09             	cmp    $0x9,%eax
f0106851:	7e f1                	jle    f0106844 <spin_lock+0xa7>
f0106853:	eb 16                	jmp    f010686b <spin_lock+0xce>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106855:	b8 00 00 00 00       	mov    $0x0,%eax
f010685a:	eb e8                	jmp    f0106844 <spin_lock+0xa7>
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f010685c:	8b 50 04             	mov    0x4(%eax),%edx
f010685f:	89 53 10             	mov    %edx,0x10(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106862:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106864:	b8 01 00 00 00       	mov    $0x1,%eax
f0106869:	eb b9                	jmp    f0106824 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010686b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010686e:	5b                   	pop    %ebx
f010686f:	5e                   	pop    %esi
f0106870:	5d                   	pop    %ebp
f0106871:	c3                   	ret    

f0106872 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106872:	55                   	push   %ebp
f0106873:	89 e5                	mov    %esp,%ebp
f0106875:	57                   	push   %edi
f0106876:	56                   	push   %esi
f0106877:	53                   	push   %ebx
f0106878:	83 ec 4c             	sub    $0x4c,%esp
f010687b:	8b 5d 08             	mov    0x8(%ebp),%ebx
{
#ifndef USE_TICKET_SPIN_LOCK
	return lock->locked && lock->cpu == thiscpu;
#else
	//LAB 4: Your code here
	return lock->own != lock->next && lock->cpu == thiscpu;
f010687e:	8b 13                	mov    (%ebx),%edx
f0106880:	8b 43 04             	mov    0x4(%ebx),%eax
f0106883:	39 c2                	cmp    %eax,%edx
f0106885:	74 18                	je     f010689f <spin_unlock+0x2d>
f0106887:	8b 73 0c             	mov    0xc(%ebx),%esi
f010688a:	e8 a0 fc ff ff       	call   f010652f <cpunum>
f010688f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106892:	05 20 20 24 f0       	add    $0xf0242020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106897:	39 c6                	cmp    %eax,%esi
f0106899:	0f 84 ae 00 00 00    	je     f010694d <spin_unlock+0xdb>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010689f:	83 ec 04             	sub    $0x4,%esp
f01068a2:	6a 28                	push   $0x28
f01068a4:	8d 43 10             	lea    0x10(%ebx),%eax
f01068a7:	50                   	push   %eax
f01068a8:	8d 45 c0             	lea    -0x40(%ebp),%eax
f01068ab:	50                   	push   %eax
f01068ac:	e8 50 f6 ff ff       	call   f0105f01 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
f01068b1:	8b 43 0c             	mov    0xc(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
f01068b4:	0f b6 30             	movzbl (%eax),%esi
f01068b7:	8b 5b 08             	mov    0x8(%ebx),%ebx
f01068ba:	e8 70 fc ff ff       	call   f010652f <cpunum>
f01068bf:	56                   	push   %esi
f01068c0:	53                   	push   %ebx
f01068c1:	50                   	push   %eax
f01068c2:	68 d4 88 10 f0       	push   $0xf01088d4
f01068c7:	e8 a6 d5 ff ff       	call   f0103e72 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01068cc:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01068cf:	83 c4 20             	add    $0x20,%esp
f01068d2:	85 c0                	test   %eax,%eax
f01068d4:	74 60                	je     f0106936 <spin_unlock+0xc4>
f01068d6:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01068d9:	8d 7d e4             	lea    -0x1c(%ebp),%edi
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01068dc:	8d 75 a8             	lea    -0x58(%ebp),%esi
f01068df:	83 ec 08             	sub    $0x8,%esp
f01068e2:	56                   	push   %esi
f01068e3:	50                   	push   %eax
f01068e4:	e8 29 e8 ff ff       	call   f0105112 <debuginfo_eip>
f01068e9:	83 c4 10             	add    $0x10,%esp
f01068ec:	85 c0                	test   %eax,%eax
f01068ee:	78 27                	js     f0106917 <spin_unlock+0xa5>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01068f0:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01068f2:	83 ec 04             	sub    $0x4,%esp
f01068f5:	89 c2                	mov    %eax,%edx
f01068f7:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01068fa:	52                   	push   %edx
f01068fb:	ff 75 b0             	pushl  -0x50(%ebp)
f01068fe:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106901:	ff 75 ac             	pushl  -0x54(%ebp)
f0106904:	ff 75 a8             	pushl  -0x58(%ebp)
f0106907:	50                   	push   %eax
f0106908:	68 1c 89 10 f0       	push   $0xf010891c
f010690d:	e8 60 d5 ff ff       	call   f0103e72 <cprintf>
f0106912:	83 c4 20             	add    $0x20,%esp
f0106915:	eb 12                	jmp    f0106929 <spin_unlock+0xb7>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106917:	83 ec 08             	sub    $0x8,%esp
f010691a:	ff 33                	pushl  (%ebx)
f010691c:	68 33 89 10 f0       	push   $0xf0108933
f0106921:	e8 4c d5 ff ff       	call   f0103e72 <cprintf>
f0106926:	83 c4 10             	add    $0x10,%esp
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:",
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106929:	39 fb                	cmp    %edi,%ebx
f010692b:	74 09                	je     f0106936 <spin_unlock+0xc4>
f010692d:	83 c3 04             	add    $0x4,%ebx
f0106930:	8b 03                	mov    (%ebx),%eax
f0106932:	85 c0                	test   %eax,%eax
f0106934:	75 a9                	jne    f01068df <spin_unlock+0x6d>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106936:	83 ec 04             	sub    $0x4,%esp
f0106939:	68 3b 89 10 f0       	push   $0xf010893b
f010693e:	68 89 00 00 00       	push   $0x89
f0106943:	68 0c 89 10 f0       	push   $0xf010890c
f0106948:	e8 f3 96 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010694d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
	lk->cpu = 0;
f0106954:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
#else
	//LAB 4: Your code here
	atomic_return_and_add(&(lk->own), 1);
f010695b:	83 ec 08             	sub    $0x8,%esp
f010695e:	6a 01                	push   $0x1
f0106960:	53                   	push   %ebx
f0106961:	e8 06 fe ff ff       	call   f010676c <atomic_return_and_add>
#endif
}
f0106966:	83 c4 10             	add    $0x10,%esp
f0106969:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010696c:	5b                   	pop    %ebx
f010696d:	5e                   	pop    %esi
f010696e:	5f                   	pop    %edi
f010696f:	5d                   	pop    %ebp
f0106970:	c3                   	ret    
f0106971:	66 90                	xchg   %ax,%ax
f0106973:	66 90                	xchg   %ax,%ax
f0106975:	66 90                	xchg   %ax,%ax
f0106977:	66 90                	xchg   %ax,%ax
f0106979:	66 90                	xchg   %ax,%ax
f010697b:	66 90                	xchg   %ax,%ax
f010697d:	66 90                	xchg   %ax,%ax
f010697f:	90                   	nop

f0106980 <__udivdi3>:
f0106980:	55                   	push   %ebp
f0106981:	57                   	push   %edi
f0106982:	56                   	push   %esi
f0106983:	53                   	push   %ebx
f0106984:	83 ec 1c             	sub    $0x1c,%esp
f0106987:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010698b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010698f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106993:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106997:	85 f6                	test   %esi,%esi
f0106999:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010699d:	89 ca                	mov    %ecx,%edx
f010699f:	89 f8                	mov    %edi,%eax
f01069a1:	75 3d                	jne    f01069e0 <__udivdi3+0x60>
f01069a3:	39 cf                	cmp    %ecx,%edi
f01069a5:	0f 87 c5 00 00 00    	ja     f0106a70 <__udivdi3+0xf0>
f01069ab:	85 ff                	test   %edi,%edi
f01069ad:	89 fd                	mov    %edi,%ebp
f01069af:	75 0b                	jne    f01069bc <__udivdi3+0x3c>
f01069b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01069b6:	31 d2                	xor    %edx,%edx
f01069b8:	f7 f7                	div    %edi
f01069ba:	89 c5                	mov    %eax,%ebp
f01069bc:	89 c8                	mov    %ecx,%eax
f01069be:	31 d2                	xor    %edx,%edx
f01069c0:	f7 f5                	div    %ebp
f01069c2:	89 c1                	mov    %eax,%ecx
f01069c4:	89 d8                	mov    %ebx,%eax
f01069c6:	89 cf                	mov    %ecx,%edi
f01069c8:	f7 f5                	div    %ebp
f01069ca:	89 c3                	mov    %eax,%ebx
f01069cc:	89 d8                	mov    %ebx,%eax
f01069ce:	89 fa                	mov    %edi,%edx
f01069d0:	83 c4 1c             	add    $0x1c,%esp
f01069d3:	5b                   	pop    %ebx
f01069d4:	5e                   	pop    %esi
f01069d5:	5f                   	pop    %edi
f01069d6:	5d                   	pop    %ebp
f01069d7:	c3                   	ret    
f01069d8:	90                   	nop
f01069d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01069e0:	39 ce                	cmp    %ecx,%esi
f01069e2:	77 74                	ja     f0106a58 <__udivdi3+0xd8>
f01069e4:	0f bd fe             	bsr    %esi,%edi
f01069e7:	83 f7 1f             	xor    $0x1f,%edi
f01069ea:	0f 84 98 00 00 00    	je     f0106a88 <__udivdi3+0x108>
f01069f0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01069f5:	89 f9                	mov    %edi,%ecx
f01069f7:	89 c5                	mov    %eax,%ebp
f01069f9:	29 fb                	sub    %edi,%ebx
f01069fb:	d3 e6                	shl    %cl,%esi
f01069fd:	89 d9                	mov    %ebx,%ecx
f01069ff:	d3 ed                	shr    %cl,%ebp
f0106a01:	89 f9                	mov    %edi,%ecx
f0106a03:	d3 e0                	shl    %cl,%eax
f0106a05:	09 ee                	or     %ebp,%esi
f0106a07:	89 d9                	mov    %ebx,%ecx
f0106a09:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a0d:	89 d5                	mov    %edx,%ebp
f0106a0f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106a13:	d3 ed                	shr    %cl,%ebp
f0106a15:	89 f9                	mov    %edi,%ecx
f0106a17:	d3 e2                	shl    %cl,%edx
f0106a19:	89 d9                	mov    %ebx,%ecx
f0106a1b:	d3 e8                	shr    %cl,%eax
f0106a1d:	09 c2                	or     %eax,%edx
f0106a1f:	89 d0                	mov    %edx,%eax
f0106a21:	89 ea                	mov    %ebp,%edx
f0106a23:	f7 f6                	div    %esi
f0106a25:	89 d5                	mov    %edx,%ebp
f0106a27:	89 c3                	mov    %eax,%ebx
f0106a29:	f7 64 24 0c          	mull   0xc(%esp)
f0106a2d:	39 d5                	cmp    %edx,%ebp
f0106a2f:	72 10                	jb     f0106a41 <__udivdi3+0xc1>
f0106a31:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106a35:	89 f9                	mov    %edi,%ecx
f0106a37:	d3 e6                	shl    %cl,%esi
f0106a39:	39 c6                	cmp    %eax,%esi
f0106a3b:	73 07                	jae    f0106a44 <__udivdi3+0xc4>
f0106a3d:	39 d5                	cmp    %edx,%ebp
f0106a3f:	75 03                	jne    f0106a44 <__udivdi3+0xc4>
f0106a41:	83 eb 01             	sub    $0x1,%ebx
f0106a44:	31 ff                	xor    %edi,%edi
f0106a46:	89 d8                	mov    %ebx,%eax
f0106a48:	89 fa                	mov    %edi,%edx
f0106a4a:	83 c4 1c             	add    $0x1c,%esp
f0106a4d:	5b                   	pop    %ebx
f0106a4e:	5e                   	pop    %esi
f0106a4f:	5f                   	pop    %edi
f0106a50:	5d                   	pop    %ebp
f0106a51:	c3                   	ret    
f0106a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a58:	31 ff                	xor    %edi,%edi
f0106a5a:	31 db                	xor    %ebx,%ebx
f0106a5c:	89 d8                	mov    %ebx,%eax
f0106a5e:	89 fa                	mov    %edi,%edx
f0106a60:	83 c4 1c             	add    $0x1c,%esp
f0106a63:	5b                   	pop    %ebx
f0106a64:	5e                   	pop    %esi
f0106a65:	5f                   	pop    %edi
f0106a66:	5d                   	pop    %ebp
f0106a67:	c3                   	ret    
f0106a68:	90                   	nop
f0106a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106a70:	89 d8                	mov    %ebx,%eax
f0106a72:	f7 f7                	div    %edi
f0106a74:	31 ff                	xor    %edi,%edi
f0106a76:	89 c3                	mov    %eax,%ebx
f0106a78:	89 d8                	mov    %ebx,%eax
f0106a7a:	89 fa                	mov    %edi,%edx
f0106a7c:	83 c4 1c             	add    $0x1c,%esp
f0106a7f:	5b                   	pop    %ebx
f0106a80:	5e                   	pop    %esi
f0106a81:	5f                   	pop    %edi
f0106a82:	5d                   	pop    %ebp
f0106a83:	c3                   	ret    
f0106a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106a88:	39 ce                	cmp    %ecx,%esi
f0106a8a:	72 0c                	jb     f0106a98 <__udivdi3+0x118>
f0106a8c:	31 db                	xor    %ebx,%ebx
f0106a8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106a92:	0f 87 34 ff ff ff    	ja     f01069cc <__udivdi3+0x4c>
f0106a98:	bb 01 00 00 00       	mov    $0x1,%ebx
f0106a9d:	e9 2a ff ff ff       	jmp    f01069cc <__udivdi3+0x4c>
f0106aa2:	66 90                	xchg   %ax,%ax
f0106aa4:	66 90                	xchg   %ax,%ax
f0106aa6:	66 90                	xchg   %ax,%ax
f0106aa8:	66 90                	xchg   %ax,%ax
f0106aaa:	66 90                	xchg   %ax,%ax
f0106aac:	66 90                	xchg   %ax,%ax
f0106aae:	66 90                	xchg   %ax,%ax

f0106ab0 <__umoddi3>:
f0106ab0:	55                   	push   %ebp
f0106ab1:	57                   	push   %edi
f0106ab2:	56                   	push   %esi
f0106ab3:	53                   	push   %ebx
f0106ab4:	83 ec 1c             	sub    $0x1c,%esp
f0106ab7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0106abb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0106abf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106ac3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106ac7:	85 d2                	test   %edx,%edx
f0106ac9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106acd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106ad1:	89 f3                	mov    %esi,%ebx
f0106ad3:	89 3c 24             	mov    %edi,(%esp)
f0106ad6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106ada:	75 1c                	jne    f0106af8 <__umoddi3+0x48>
f0106adc:	39 f7                	cmp    %esi,%edi
f0106ade:	76 50                	jbe    f0106b30 <__umoddi3+0x80>
f0106ae0:	89 c8                	mov    %ecx,%eax
f0106ae2:	89 f2                	mov    %esi,%edx
f0106ae4:	f7 f7                	div    %edi
f0106ae6:	89 d0                	mov    %edx,%eax
f0106ae8:	31 d2                	xor    %edx,%edx
f0106aea:	83 c4 1c             	add    $0x1c,%esp
f0106aed:	5b                   	pop    %ebx
f0106aee:	5e                   	pop    %esi
f0106aef:	5f                   	pop    %edi
f0106af0:	5d                   	pop    %ebp
f0106af1:	c3                   	ret    
f0106af2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106af8:	39 f2                	cmp    %esi,%edx
f0106afa:	89 d0                	mov    %edx,%eax
f0106afc:	77 52                	ja     f0106b50 <__umoddi3+0xa0>
f0106afe:	0f bd ea             	bsr    %edx,%ebp
f0106b01:	83 f5 1f             	xor    $0x1f,%ebp
f0106b04:	75 5a                	jne    f0106b60 <__umoddi3+0xb0>
f0106b06:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0106b0a:	0f 82 e0 00 00 00    	jb     f0106bf0 <__umoddi3+0x140>
f0106b10:	39 0c 24             	cmp    %ecx,(%esp)
f0106b13:	0f 86 d7 00 00 00    	jbe    f0106bf0 <__umoddi3+0x140>
f0106b19:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106b1d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106b21:	83 c4 1c             	add    $0x1c,%esp
f0106b24:	5b                   	pop    %ebx
f0106b25:	5e                   	pop    %esi
f0106b26:	5f                   	pop    %edi
f0106b27:	5d                   	pop    %ebp
f0106b28:	c3                   	ret    
f0106b29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106b30:	85 ff                	test   %edi,%edi
f0106b32:	89 fd                	mov    %edi,%ebp
f0106b34:	75 0b                	jne    f0106b41 <__umoddi3+0x91>
f0106b36:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b3b:	31 d2                	xor    %edx,%edx
f0106b3d:	f7 f7                	div    %edi
f0106b3f:	89 c5                	mov    %eax,%ebp
f0106b41:	89 f0                	mov    %esi,%eax
f0106b43:	31 d2                	xor    %edx,%edx
f0106b45:	f7 f5                	div    %ebp
f0106b47:	89 c8                	mov    %ecx,%eax
f0106b49:	f7 f5                	div    %ebp
f0106b4b:	89 d0                	mov    %edx,%eax
f0106b4d:	eb 99                	jmp    f0106ae8 <__umoddi3+0x38>
f0106b4f:	90                   	nop
f0106b50:	89 c8                	mov    %ecx,%eax
f0106b52:	89 f2                	mov    %esi,%edx
f0106b54:	83 c4 1c             	add    $0x1c,%esp
f0106b57:	5b                   	pop    %ebx
f0106b58:	5e                   	pop    %esi
f0106b59:	5f                   	pop    %edi
f0106b5a:	5d                   	pop    %ebp
f0106b5b:	c3                   	ret    
f0106b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b60:	8b 34 24             	mov    (%esp),%esi
f0106b63:	bf 20 00 00 00       	mov    $0x20,%edi
f0106b68:	89 e9                	mov    %ebp,%ecx
f0106b6a:	29 ef                	sub    %ebp,%edi
f0106b6c:	d3 e0                	shl    %cl,%eax
f0106b6e:	89 f9                	mov    %edi,%ecx
f0106b70:	89 f2                	mov    %esi,%edx
f0106b72:	d3 ea                	shr    %cl,%edx
f0106b74:	89 e9                	mov    %ebp,%ecx
f0106b76:	09 c2                	or     %eax,%edx
f0106b78:	89 d8                	mov    %ebx,%eax
f0106b7a:	89 14 24             	mov    %edx,(%esp)
f0106b7d:	89 f2                	mov    %esi,%edx
f0106b7f:	d3 e2                	shl    %cl,%edx
f0106b81:	89 f9                	mov    %edi,%ecx
f0106b83:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b87:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106b8b:	d3 e8                	shr    %cl,%eax
f0106b8d:	89 e9                	mov    %ebp,%ecx
f0106b8f:	89 c6                	mov    %eax,%esi
f0106b91:	d3 e3                	shl    %cl,%ebx
f0106b93:	89 f9                	mov    %edi,%ecx
f0106b95:	89 d0                	mov    %edx,%eax
f0106b97:	d3 e8                	shr    %cl,%eax
f0106b99:	89 e9                	mov    %ebp,%ecx
f0106b9b:	09 d8                	or     %ebx,%eax
f0106b9d:	89 d3                	mov    %edx,%ebx
f0106b9f:	89 f2                	mov    %esi,%edx
f0106ba1:	f7 34 24             	divl   (%esp)
f0106ba4:	89 d6                	mov    %edx,%esi
f0106ba6:	d3 e3                	shl    %cl,%ebx
f0106ba8:	f7 64 24 04          	mull   0x4(%esp)
f0106bac:	39 d6                	cmp    %edx,%esi
f0106bae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106bb2:	89 d1                	mov    %edx,%ecx
f0106bb4:	89 c3                	mov    %eax,%ebx
f0106bb6:	72 08                	jb     f0106bc0 <__umoddi3+0x110>
f0106bb8:	75 11                	jne    f0106bcb <__umoddi3+0x11b>
f0106bba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106bbe:	73 0b                	jae    f0106bcb <__umoddi3+0x11b>
f0106bc0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106bc4:	1b 14 24             	sbb    (%esp),%edx
f0106bc7:	89 d1                	mov    %edx,%ecx
f0106bc9:	89 c3                	mov    %eax,%ebx
f0106bcb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0106bcf:	29 da                	sub    %ebx,%edx
f0106bd1:	19 ce                	sbb    %ecx,%esi
f0106bd3:	89 f9                	mov    %edi,%ecx
f0106bd5:	89 f0                	mov    %esi,%eax
f0106bd7:	d3 e0                	shl    %cl,%eax
f0106bd9:	89 e9                	mov    %ebp,%ecx
f0106bdb:	d3 ea                	shr    %cl,%edx
f0106bdd:	89 e9                	mov    %ebp,%ecx
f0106bdf:	d3 ee                	shr    %cl,%esi
f0106be1:	09 d0                	or     %edx,%eax
f0106be3:	89 f2                	mov    %esi,%edx
f0106be5:	83 c4 1c             	add    $0x1c,%esp
f0106be8:	5b                   	pop    %ebx
f0106be9:	5e                   	pop    %esi
f0106bea:	5f                   	pop    %edi
f0106beb:	5d                   	pop    %ebp
f0106bec:	c3                   	ret    
f0106bed:	8d 76 00             	lea    0x0(%esi),%esi
f0106bf0:	29 f9                	sub    %edi,%ecx
f0106bf2:	19 d6                	sbb    %edx,%esi
f0106bf4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106bf8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106bfc:	e9 18 ff ff ff       	jmp    f0106b19 <__umoddi3+0x69>
