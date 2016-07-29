
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
	# until we set up our real page table in i386_vm_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 20 1e 10 f0       	push   $0xf0101e20
f0100050:	e8 ed 0a 00 00       	call   f0100b42 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 51 08 00 00       	call   f01008cc <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 3c 1e 10 f0       	push   $0xf0101e3c
f0100087:	e8 b6 0a 00 00       	call   f0100b42 <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	57                   	push   %edi
f0100098:	56                   	push   %esi
f0100099:	53                   	push   %ebx
f010009a:	81 ec 20 01 00 00    	sub    $0x120,%esp
	extern char edata[], end[];
   	// Lab1 only
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f01000a0:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f01000a4:	c6 45 e6 00          	movb   $0x0,-0x1a(%ebp)
f01000a8:	c7 85 e6 fe ff ff 00 	movl   $0x0,-0x11a(%ebp)
f01000af:	00 00 00 
f01000b2:	c7 45 e2 00 00 00 00 	movl   $0x0,-0x1e(%ebp)
f01000b9:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f01000bf:	b9 3f 00 00 00       	mov    $0x3f,%ecx
f01000c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01000c9:	f3 ab                	rep stos %eax,%es:(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000cb:	b8 60 29 11 f0       	mov    $0xf0112960,%eax
f01000d0:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000d5:	50                   	push   %eax
f01000d6:	6a 00                	push   $0x0
f01000d8:	68 00 23 11 f0       	push   $0xf0112300
f01000dd:	e8 6b 18 00 00       	call   f010194d <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000e2:	e8 27 05 00 00       	call   f010060e <cons_init>
	// unsigned int i = 0x00646c72;
	// cprintf("H%x Wo%s", 57616, &i);
	// char ch1, ch2;
	// cprintf("hello%n world%n\n", &ch1, &ch);

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01000e7:	8d 45 e6             	lea    -0x1a(%ebp),%eax
f01000ea:	50                   	push   %eax
f01000eb:	8d 75 e7             	lea    -0x19(%ebp),%esi
f01000ee:	56                   	push   %esi
f01000ef:	68 ac 1a 00 00       	push   $0x1aac
f01000f4:	68 d0 1e 10 f0       	push   $0xf0101ed0
f01000f9:	e8 44 0a 00 00       	call   f0100b42 <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f01000fe:	83 c4 18             	add    $0x18,%esp
f0100101:	6a 16                	push   $0x16
f0100103:	68 f0 1e 10 f0       	push   $0xf0101ef0
f0100108:	e8 35 0a 00 00       	call   f0100b42 <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f010010d:	83 c4 0c             	add    $0xc,%esp
f0100110:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f0100114:	50                   	push   %eax
f0100115:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0100119:	50                   	push   %eax
f010011a:	68 57 1e 10 f0       	push   $0xf0101e57
f010011f:	e8 1e 0a 00 00       	call   f0100b42 <cprintf>
	cprintf("%n", NULL);
f0100124:	83 c4 08             	add    $0x8,%esp
f0100127:	6a 00                	push   $0x0
f0100129:	68 70 1e 10 f0       	push   $0xf0101e70
f010012e:	e8 0f 0a 00 00       	call   f0100b42 <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100133:	83 c4 0c             	add    $0xc,%esp
f0100136:	68 ff 00 00 00       	push   $0xff
f010013b:	6a 0d                	push   $0xd
f010013d:	8d 9d e6 fe ff ff    	lea    -0x11a(%ebp),%ebx
f0100143:	53                   	push   %ebx
f0100144:	e8 04 18 00 00       	call   f010194d <memset>
	cprintf("%s%n", ntest, &chnum1);
f0100149:	83 c4 0c             	add    $0xc,%esp
f010014c:	56                   	push   %esi
f010014d:	53                   	push   %ebx
f010014e:	68 6e 1e 10 f0       	push   $0xf0101e6e
f0100153:	e8 ea 09 00 00       	call   f0100b42 <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f0100158:	83 c4 08             	add    $0x8,%esp
f010015b:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f010015f:	50                   	push   %eax
f0100160:	68 73 1e 10 f0       	push   $0xf0101e73
f0100165:	e8 d8 09 00 00       	call   f0100b42 <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f010016a:	83 c4 0c             	add    $0xc,%esp
f010016d:	68 00 fc ff ff       	push   $0xfffffc00
f0100172:	68 00 04 00 00       	push   $0x400
f0100177:	68 7f 1e 10 f0       	push   $0xf0101e7f
f010017c:	e8 c1 09 00 00       	call   f0100b42 <cprintf>


	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100181:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100188:	e8 b3 fe ff ff       	call   f0100040 <test_backtrace>
f010018d:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100190:	83 ec 0c             	sub    $0xc,%esp
f0100193:	6a 00                	push   $0x0
f0100195:	e8 22 08 00 00       	call   f01009bc <monitor>
f010019a:	83 c4 10             	add    $0x10,%esp
f010019d:	eb f1                	jmp    f0100190 <i386_init+0xfc>

f010019f <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010019f:	55                   	push   %ebp
f01001a0:	89 e5                	mov    %esp,%ebp
f01001a2:	56                   	push   %esi
f01001a3:	53                   	push   %ebx
f01001a4:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01001a7:	83 3d 00 23 11 f0 00 	cmpl   $0x0,0xf0112300
f01001ae:	75 37                	jne    f01001e7 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01001b0:	89 35 00 23 11 f0    	mov    %esi,0xf0112300

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01001b6:	fa                   	cli    
f01001b7:	fc                   	cld    

	va_start(ap, fmt);
f01001b8:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01001bb:	83 ec 04             	sub    $0x4,%esp
f01001be:	ff 75 0c             	pushl  0xc(%ebp)
f01001c1:	ff 75 08             	pushl  0x8(%ebp)
f01001c4:	68 9b 1e 10 f0       	push   $0xf0101e9b
f01001c9:	e8 74 09 00 00       	call   f0100b42 <cprintf>
	vcprintf(fmt, ap);
f01001ce:	83 c4 08             	add    $0x8,%esp
f01001d1:	53                   	push   %ebx
f01001d2:	56                   	push   %esi
f01001d3:	e8 44 09 00 00       	call   f0100b1c <vcprintf>
	cprintf("\n");
f01001d8:	c7 04 24 ff 21 10 f0 	movl   $0xf01021ff,(%esp)
f01001df:	e8 5e 09 00 00       	call   f0100b42 <cprintf>
	va_end(ap);
f01001e4:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01001e7:	83 ec 0c             	sub    $0xc,%esp
f01001ea:	6a 00                	push   $0x0
f01001ec:	e8 cb 07 00 00       	call   f01009bc <monitor>
f01001f1:	83 c4 10             	add    $0x10,%esp
f01001f4:	eb f1                	jmp    f01001e7 <_panic+0x48>

f01001f6 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01001f6:	55                   	push   %ebp
f01001f7:	89 e5                	mov    %esp,%ebp
f01001f9:	53                   	push   %ebx
f01001fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01001fd:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100200:	ff 75 0c             	pushl  0xc(%ebp)
f0100203:	ff 75 08             	pushl  0x8(%ebp)
f0100206:	68 b3 1e 10 f0       	push   $0xf0101eb3
f010020b:	e8 32 09 00 00       	call   f0100b42 <cprintf>
	vcprintf(fmt, ap);
f0100210:	83 c4 08             	add    $0x8,%esp
f0100213:	53                   	push   %ebx
f0100214:	ff 75 10             	pushl  0x10(%ebp)
f0100217:	e8 00 09 00 00       	call   f0100b1c <vcprintf>
	cprintf("\n");
f010021c:	c7 04 24 ff 21 10 f0 	movl   $0xf01021ff,(%esp)
f0100223:	e8 1a 09 00 00       	call   f0100b42 <cprintf>
	va_end(ap);
}
f0100228:	83 c4 10             	add    $0x10,%esp
f010022b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010022e:	c9                   	leave  
f010022f:	c3                   	ret    

f0100230 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100230:	55                   	push   %ebp
f0100231:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100233:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100238:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100239:	a8 01                	test   $0x1,%al
f010023b:	74 0b                	je     f0100248 <serial_proc_data+0x18>
f010023d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100242:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100243:	0f b6 c0             	movzbl %al,%eax
f0100246:	eb 05                	jmp    f010024d <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010024d:	5d                   	pop    %ebp
f010024e:	c3                   	ret    

f010024f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010024f:	55                   	push   %ebp
f0100250:	89 e5                	mov    %esp,%ebp
f0100252:	53                   	push   %ebx
f0100253:	83 ec 04             	sub    $0x4,%esp
f0100256:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100258:	eb 2b                	jmp    f0100285 <cons_intr+0x36>
		if (c == 0)
f010025a:	85 c0                	test   %eax,%eax
f010025c:	74 27                	je     f0100285 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010025e:	8b 0d 44 25 11 f0    	mov    0xf0112544,%ecx
f0100264:	8d 51 01             	lea    0x1(%ecx),%edx
f0100267:	89 15 44 25 11 f0    	mov    %edx,0xf0112544
f010026d:	88 81 40 23 11 f0    	mov    %al,-0xfeedcc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100273:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100279:	75 0a                	jne    f0100285 <cons_intr+0x36>
			cons.wpos = 0;
f010027b:	c7 05 44 25 11 f0 00 	movl   $0x0,0xf0112544
f0100282:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100285:	ff d3                	call   *%ebx
f0100287:	83 f8 ff             	cmp    $0xffffffff,%eax
f010028a:	75 ce                	jne    f010025a <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010028c:	83 c4 04             	add    $0x4,%esp
f010028f:	5b                   	pop    %ebx
f0100290:	5d                   	pop    %ebp
f0100291:	c3                   	ret    

f0100292 <kbd_proc_data>:
f0100292:	ba 64 00 00 00       	mov    $0x64,%edx
f0100297:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100298:	a8 01                	test   $0x1,%al
f010029a:	0f 84 f0 00 00 00    	je     f0100390 <kbd_proc_data+0xfe>
f01002a0:	ba 60 00 00 00       	mov    $0x60,%edx
f01002a5:	ec                   	in     (%dx),%al
f01002a6:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002a8:	3c e0                	cmp    $0xe0,%al
f01002aa:	75 0d                	jne    f01002b9 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002ac:	83 0d 20 23 11 f0 40 	orl    $0x40,0xf0112320
		return 0;
f01002b3:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002b8:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002b9:	55                   	push   %ebp
f01002ba:	89 e5                	mov    %esp,%ebp
f01002bc:	53                   	push   %ebx
f01002bd:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002c0:	84 c0                	test   %al,%al
f01002c2:	79 36                	jns    f01002fa <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002c4:	8b 0d 20 23 11 f0    	mov    0xf0112320,%ecx
f01002ca:	89 cb                	mov    %ecx,%ebx
f01002cc:	83 e3 40             	and    $0x40,%ebx
f01002cf:	83 e0 7f             	and    $0x7f,%eax
f01002d2:	85 db                	test   %ebx,%ebx
f01002d4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002d7:	0f b6 d2             	movzbl %dl,%edx
f01002da:	0f b6 82 80 20 10 f0 	movzbl -0xfefdf80(%edx),%eax
f01002e1:	83 c8 40             	or     $0x40,%eax
f01002e4:	0f b6 c0             	movzbl %al,%eax
f01002e7:	f7 d0                	not    %eax
f01002e9:	21 c8                	and    %ecx,%eax
f01002eb:	a3 20 23 11 f0       	mov    %eax,0xf0112320
		return 0;
f01002f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f5:	e9 9e 00 00 00       	jmp    f0100398 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01002fa:	8b 0d 20 23 11 f0    	mov    0xf0112320,%ecx
f0100300:	f6 c1 40             	test   $0x40,%cl
f0100303:	74 0e                	je     f0100313 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100305:	83 c8 80             	or     $0xffffff80,%eax
f0100308:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010030a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010030d:	89 0d 20 23 11 f0    	mov    %ecx,0xf0112320
	}

	shift |= shiftcode[data];
f0100313:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100316:	0f b6 82 80 20 10 f0 	movzbl -0xfefdf80(%edx),%eax
f010031d:	0b 05 20 23 11 f0    	or     0xf0112320,%eax
f0100323:	0f b6 8a 80 1f 10 f0 	movzbl -0xfefe080(%edx),%ecx
f010032a:	31 c8                	xor    %ecx,%eax
f010032c:	a3 20 23 11 f0       	mov    %eax,0xf0112320

	c = charcode[shift & (CTL | SHIFT)][data];
f0100331:	89 c1                	mov    %eax,%ecx
f0100333:	83 e1 03             	and    $0x3,%ecx
f0100336:	8b 0c 8d 60 1f 10 f0 	mov    -0xfefe0a0(,%ecx,4),%ecx
f010033d:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100341:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100344:	a8 08                	test   $0x8,%al
f0100346:	74 1b                	je     f0100363 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100348:	89 da                	mov    %ebx,%edx
f010034a:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010034d:	83 f9 19             	cmp    $0x19,%ecx
f0100350:	77 05                	ja     f0100357 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100352:	83 eb 20             	sub    $0x20,%ebx
f0100355:	eb 0c                	jmp    f0100363 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100357:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010035a:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010035d:	83 fa 19             	cmp    $0x19,%edx
f0100360:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100363:	f7 d0                	not    %eax
f0100365:	a8 06                	test   $0x6,%al
f0100367:	75 2d                	jne    f0100396 <kbd_proc_data+0x104>
f0100369:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010036f:	75 25                	jne    f0100396 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100371:	83 ec 0c             	sub    $0xc,%esp
f0100374:	68 1f 1f 10 f0       	push   $0xf0101f1f
f0100379:	e8 c4 07 00 00       	call   f0100b42 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100383:	b8 03 00 00 00       	mov    $0x3,%eax
f0100388:	ee                   	out    %al,(%dx)
f0100389:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010038c:	89 d8                	mov    %ebx,%eax
f010038e:	eb 08                	jmp    f0100398 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100395:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100396:	89 d8                	mov    %ebx,%eax
}
f0100398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010039b:	c9                   	leave  
f010039c:	c3                   	ret    

f010039d <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010039d:	55                   	push   %ebp
f010039e:	89 e5                	mov    %esp,%ebp
f01003a0:	57                   	push   %edi
f01003a1:	56                   	push   %esi
f01003a2:	53                   	push   %ebx
f01003a3:	83 ec 1c             	sub    $0x1c,%esp
f01003a6:	89 c7                	mov    %eax,%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003ad:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003ae:	a8 20                	test   $0x20,%al
f01003b0:	75 27                	jne    f01003d9 <cons_putc+0x3c>
f01003b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003bc:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003c1:	89 ca                	mov    %ecx,%edx
f01003c3:	ec                   	in     (%dx),%al
f01003c4:	ec                   	in     (%dx),%al
f01003c5:	ec                   	in     (%dx),%al
f01003c6:	ec                   	in     (%dx),%al
	     i++)
f01003c7:	83 c3 01             	add    $0x1,%ebx
f01003ca:	89 f2                	mov    %esi,%edx
f01003cc:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003cd:	a8 20                	test   $0x20,%al
f01003cf:	75 08                	jne    f01003d9 <cons_putc+0x3c>
f01003d1:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003d7:	7e e8                	jle    f01003c1 <cons_putc+0x24>
f01003d9:	89 f8                	mov    %edi,%eax
f01003db:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003de:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003e3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e4:	ba 79 03 00 00       	mov    $0x379,%edx
f01003e9:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003ea:	84 c0                	test   %al,%al
f01003ec:	78 27                	js     f0100415 <cons_putc+0x78>
f01003ee:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f8:	be 79 03 00 00       	mov    $0x379,%esi
f01003fd:	89 ca                	mov    %ecx,%edx
f01003ff:	ec                   	in     (%dx),%al
f0100400:	ec                   	in     (%dx),%al
f0100401:	ec                   	in     (%dx),%al
f0100402:	ec                   	in     (%dx),%al
f0100403:	83 c3 01             	add    $0x1,%ebx
f0100406:	89 f2                	mov    %esi,%edx
f0100408:	ec                   	in     (%dx),%al
f0100409:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010040f:	7f 04                	jg     f0100415 <cons_putc+0x78>
f0100411:	84 c0                	test   %al,%al
f0100413:	79 e8                	jns    f01003fd <cons_putc+0x60>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100415:	ba 78 03 00 00       	mov    $0x378,%edx
f010041a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010041e:	ee                   	out    %al,(%dx)
f010041f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100424:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100429:	ee                   	out    %al,(%dx)
f010042a:	b8 08 00 00 00       	mov    $0x8,%eax
f010042f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100430:	89 fa                	mov    %edi,%edx
f0100432:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100438:	89 f8                	mov    %edi,%eax
f010043a:	80 cc 07             	or     $0x7,%ah
f010043d:	85 d2                	test   %edx,%edx
f010043f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100442:	89 f8                	mov    %edi,%eax
f0100444:	0f b6 c0             	movzbl %al,%eax
f0100447:	83 f8 09             	cmp    $0x9,%eax
f010044a:	74 74                	je     f01004c0 <cons_putc+0x123>
f010044c:	83 f8 09             	cmp    $0x9,%eax
f010044f:	7f 0a                	jg     f010045b <cons_putc+0xbe>
f0100451:	83 f8 08             	cmp    $0x8,%eax
f0100454:	74 14                	je     f010046a <cons_putc+0xcd>
f0100456:	e9 99 00 00 00       	jmp    f01004f4 <cons_putc+0x157>
f010045b:	83 f8 0a             	cmp    $0xa,%eax
f010045e:	74 3a                	je     f010049a <cons_putc+0xfd>
f0100460:	83 f8 0d             	cmp    $0xd,%eax
f0100463:	74 3d                	je     f01004a2 <cons_putc+0x105>
f0100465:	e9 8a 00 00 00       	jmp    f01004f4 <cons_putc+0x157>
	case '\b':
		if (crt_pos > 0) {
f010046a:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f0100471:	66 85 c0             	test   %ax,%ax
f0100474:	0f 84 e6 00 00 00    	je     f0100560 <cons_putc+0x1c3>
			crt_pos--;
f010047a:	83 e8 01             	sub    $0x1,%eax
f010047d:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100483:	0f b7 c0             	movzwl %ax,%eax
f0100486:	66 81 e7 00 ff       	and    $0xff00,%di
f010048b:	83 cf 20             	or     $0x20,%edi
f010048e:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f0100494:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100498:	eb 78                	jmp    f0100512 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010049a:	66 83 05 48 25 11 f0 	addw   $0x50,0xf0112548
f01004a1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004a2:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f01004a9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004af:	c1 e8 16             	shr    $0x16,%eax
f01004b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004b5:	c1 e0 04             	shl    $0x4,%eax
f01004b8:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
f01004be:	eb 52                	jmp    f0100512 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f01004c0:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c5:	e8 d3 fe ff ff       	call   f010039d <cons_putc>
		cons_putc(' ');
f01004ca:	b8 20 00 00 00       	mov    $0x20,%eax
f01004cf:	e8 c9 fe ff ff       	call   f010039d <cons_putc>
		cons_putc(' ');
f01004d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d9:	e8 bf fe ff ff       	call   f010039d <cons_putc>
		cons_putc(' ');
f01004de:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e3:	e8 b5 fe ff ff       	call   f010039d <cons_putc>
		cons_putc(' ');
f01004e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ed:	e8 ab fe ff ff       	call   f010039d <cons_putc>
f01004f2:	eb 1e                	jmp    f0100512 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004f4:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f01004fb:	8d 50 01             	lea    0x1(%eax),%edx
f01004fe:	66 89 15 48 25 11 f0 	mov    %dx,0xf0112548
f0100505:	0f b7 c0             	movzwl %ax,%eax
f0100508:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f010050e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100512:	66 81 3d 48 25 11 f0 	cmpw   $0x7cf,0xf0112548
f0100519:	cf 07 
f010051b:	76 43                	jbe    f0100560 <cons_putc+0x1c3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010051d:	a1 4c 25 11 f0       	mov    0xf011254c,%eax
f0100522:	83 ec 04             	sub    $0x4,%esp
f0100525:	68 00 0f 00 00       	push   $0xf00
f010052a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100530:	52                   	push   %edx
f0100531:	50                   	push   %eax
f0100532:	e8 63 14 00 00       	call   f010199a <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100537:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f010053d:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100543:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100549:	83 c4 10             	add    $0x10,%esp
f010054c:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100551:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100554:	39 c2                	cmp    %eax,%edx
f0100556:	75 f4                	jne    f010054c <cons_putc+0x1af>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100558:	66 83 2d 48 25 11 f0 	subw   $0x50,0xf0112548
f010055f:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100560:	8b 0d 50 25 11 f0    	mov    0xf0112550,%ecx
f0100566:	b8 0e 00 00 00       	mov    $0xe,%eax
f010056b:	89 ca                	mov    %ecx,%edx
f010056d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010056e:	0f b7 1d 48 25 11 f0 	movzwl 0xf0112548,%ebx
f0100575:	8d 71 01             	lea    0x1(%ecx),%esi
f0100578:	89 d8                	mov    %ebx,%eax
f010057a:	66 c1 e8 08          	shr    $0x8,%ax
f010057e:	89 f2                	mov    %esi,%edx
f0100580:	ee                   	out    %al,(%dx)
f0100581:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100586:	89 ca                	mov    %ecx,%edx
f0100588:	ee                   	out    %al,(%dx)
f0100589:	89 d8                	mov    %ebx,%eax
f010058b:	89 f2                	mov    %esi,%edx
f010058d:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010058e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100591:	5b                   	pop    %ebx
f0100592:	5e                   	pop    %esi
f0100593:	5f                   	pop    %edi
f0100594:	5d                   	pop    %ebp
f0100595:	c3                   	ret    

f0100596 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100596:	83 3d 54 25 11 f0 00 	cmpl   $0x0,0xf0112554
f010059d:	74 11                	je     f01005b0 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010059f:	55                   	push   %ebp
f01005a0:	89 e5                	mov    %esp,%ebp
f01005a2:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005a5:	b8 30 02 10 f0       	mov    $0xf0100230,%eax
f01005aa:	e8 a0 fc ff ff       	call   f010024f <cons_intr>
}
f01005af:	c9                   	leave  
f01005b0:	f3 c3                	repz ret 

f01005b2 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005b2:	55                   	push   %ebp
f01005b3:	89 e5                	mov    %esp,%ebp
f01005b5:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005b8:	b8 92 02 10 f0       	mov    $0xf0100292,%eax
f01005bd:	e8 8d fc ff ff       	call   f010024f <cons_intr>
}
f01005c2:	c9                   	leave  
f01005c3:	c3                   	ret    

f01005c4 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005c4:	55                   	push   %ebp
f01005c5:	89 e5                	mov    %esp,%ebp
f01005c7:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005ca:	e8 c7 ff ff ff       	call   f0100596 <serial_intr>
	kbd_intr();
f01005cf:	e8 de ff ff ff       	call   f01005b2 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005d4:	a1 40 25 11 f0       	mov    0xf0112540,%eax
f01005d9:	3b 05 44 25 11 f0    	cmp    0xf0112544,%eax
f01005df:	74 26                	je     f0100607 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005e1:	8d 50 01             	lea    0x1(%eax),%edx
f01005e4:	89 15 40 25 11 f0    	mov    %edx,0xf0112540
f01005ea:	0f b6 88 40 23 11 f0 	movzbl -0xfeedcc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01005f1:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01005f3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01005f9:	75 11                	jne    f010060c <cons_getc+0x48>
			cons.rpos = 0;
f01005fb:	c7 05 40 25 11 f0 00 	movl   $0x0,0xf0112540
f0100602:	00 00 00 
f0100605:	eb 05                	jmp    f010060c <cons_getc+0x48>
		return c;
	}
	return 0;
f0100607:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010060c:	c9                   	leave  
f010060d:	c3                   	ret    

f010060e <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010060e:	55                   	push   %ebp
f010060f:	89 e5                	mov    %esp,%ebp
f0100611:	57                   	push   %edi
f0100612:	56                   	push   %esi
f0100613:	53                   	push   %ebx
f0100614:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100617:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010061e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100625:	5a a5 
	if (*cp != 0xA55A) {
f0100627:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010062e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100632:	74 11                	je     f0100645 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100634:	c7 05 50 25 11 f0 b4 	movl   $0x3b4,0xf0112550
f010063b:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010063e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100643:	eb 16                	jmp    f010065b <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100645:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010064c:	c7 05 50 25 11 f0 d4 	movl   $0x3d4,0xf0112550
f0100653:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100656:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010065b:	8b 3d 50 25 11 f0    	mov    0xf0112550,%edi
f0100661:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100666:	89 fa                	mov    %edi,%edx
f0100668:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100669:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066c:	89 da                	mov    %ebx,%edx
f010066e:	ec                   	in     (%dx),%al
f010066f:	0f b6 c8             	movzbl %al,%ecx
f0100672:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100675:	b8 0f 00 00 00       	mov    $0xf,%eax
f010067a:	89 fa                	mov    %edi,%edx
f010067c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067d:	89 da                	mov    %ebx,%edx
f010067f:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100680:	89 35 4c 25 11 f0    	mov    %esi,0xf011254c
	crt_pos = pos;
f0100686:	0f b6 c0             	movzbl %al,%eax
f0100689:	09 c8                	or     %ecx,%eax
f010068b:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100696:	b8 00 00 00 00       	mov    $0x0,%eax
f010069b:	89 f2                	mov    %esi,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	ee                   	out    %al,(%dx)
f01006a9:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006ae:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b3:	89 da                	mov    %ebx,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c0:	ee                   	out    %al,(%dx)
f01006c1:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006c6:	b8 03 00 00 00       	mov    $0x3,%eax
f01006cb:	ee                   	out    %al,(%dx)
f01006cc:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d6:	ee                   	out    %al,(%dx)
f01006d7:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006dc:	b8 01 00 00 00       	mov    $0x1,%eax
f01006e1:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006e2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006e7:	ec                   	in     (%dx),%al
f01006e8:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006ea:	3c ff                	cmp    $0xff,%al
f01006ec:	0f 95 c0             	setne  %al
f01006ef:	0f b6 c0             	movzbl %al,%eax
f01006f2:	a3 54 25 11 f0       	mov    %eax,0xf0112554
f01006f7:	89 f2                	mov    %esi,%edx
f01006f9:	ec                   	in     (%dx),%al
f01006fa:	89 da                	mov    %ebx,%edx
f01006fc:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006fd:	80 f9 ff             	cmp    $0xff,%cl
f0100700:	75 10                	jne    f0100712 <cons_init+0x104>
		cprintf("Serial port does not exist!\n");
f0100702:	83 ec 0c             	sub    $0xc,%esp
f0100705:	68 2b 1f 10 f0       	push   $0xf0101f2b
f010070a:	e8 33 04 00 00       	call   f0100b42 <cprintf>
f010070f:	83 c4 10             	add    $0x10,%esp
}
f0100712:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100715:	5b                   	pop    %ebx
f0100716:	5e                   	pop    %esi
f0100717:	5f                   	pop    %edi
f0100718:	5d                   	pop    %ebp
f0100719:	c3                   	ret    

f010071a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010071a:	55                   	push   %ebp
f010071b:	89 e5                	mov    %esp,%ebp
f010071d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100720:	8b 45 08             	mov    0x8(%ebp),%eax
f0100723:	e8 75 fc ff ff       	call   f010039d <cons_putc>
}
f0100728:	c9                   	leave  
f0100729:	c3                   	ret    

f010072a <getchar>:

int
getchar(void)
{
f010072a:	55                   	push   %ebp
f010072b:	89 e5                	mov    %esp,%ebp
f010072d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100730:	e8 8f fe ff ff       	call   f01005c4 <cons_getc>
f0100735:	85 c0                	test   %eax,%eax
f0100737:	74 f7                	je     f0100730 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100739:	c9                   	leave  
f010073a:	c3                   	ret    

f010073b <iscons>:

int
iscons(int fdnum)
{
f010073b:	55                   	push   %ebp
f010073c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010073e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100743:	5d                   	pop    %ebp
f0100744:	c3                   	ret    

f0100745 <mon_help>:
	return 0;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100745:	55                   	push   %ebp
f0100746:	89 e5                	mov    %esp,%ebp
f0100748:	56                   	push   %esi
f0100749:	53                   	push   %ebx
f010074a:	bb 80 24 10 f0       	mov    $0xf0102480,%ebx
f010074f:	be b0 24 10 f0       	mov    $0xf01024b0,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100754:	83 ec 04             	sub    $0x4,%esp
f0100757:	ff 73 04             	pushl  0x4(%ebx)
f010075a:	ff 33                	pushl  (%ebx)
f010075c:	68 80 21 10 f0       	push   $0xf0102180
f0100761:	e8 dc 03 00 00       	call   f0100b42 <cprintf>
f0100766:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100769:	83 c4 10             	add    $0x10,%esp
f010076c:	39 f3                	cmp    %esi,%ebx
f010076e:	75 e4                	jne    f0100754 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100770:	b8 00 00 00 00       	mov    $0x0,%eax
f0100775:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100778:	5b                   	pop    %ebx
f0100779:	5e                   	pop    %esi
f010077a:	5d                   	pop    %ebp
f010077b:	c3                   	ret    

f010077c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010077c:	55                   	push   %ebp
f010077d:	89 e5                	mov    %esp,%ebp
f010077f:	83 ec 14             	sub    $0x14,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100782:	68 89 21 10 f0       	push   $0xf0102189
f0100787:	e8 b6 03 00 00       	call   f0100b42 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010078c:	83 c4 0c             	add    $0xc,%esp
f010078f:	68 0c 00 10 00       	push   $0x10000c
f0100794:	68 0c 00 10 f0       	push   $0xf010000c
f0100799:	68 a0 22 10 f0       	push   $0xf01022a0
f010079e:	e8 9f 03 00 00       	call   f0100b42 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a3:	83 c4 0c             	add    $0xc,%esp
f01007a6:	68 11 1e 10 00       	push   $0x101e11
f01007ab:	68 11 1e 10 f0       	push   $0xf0101e11
f01007b0:	68 c4 22 10 f0       	push   $0xf01022c4
f01007b5:	e8 88 03 00 00       	call   f0100b42 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007ba:	83 c4 0c             	add    $0xc,%esp
f01007bd:	68 00 23 11 00       	push   $0x112300
f01007c2:	68 00 23 11 f0       	push   $0xf0112300
f01007c7:	68 e8 22 10 f0       	push   $0xf01022e8
f01007cc:	e8 71 03 00 00       	call   f0100b42 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007d1:	83 c4 0c             	add    $0xc,%esp
f01007d4:	68 60 29 11 00       	push   $0x112960
f01007d9:	68 60 29 11 f0       	push   $0xf0112960
f01007de:	68 0c 23 10 f0       	push   $0xf010230c
f01007e3:	e8 5a 03 00 00       	call   f0100b42 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007e8:	83 c4 08             	add    $0x8,%esp
f01007eb:	b8 5f 2d 11 f0       	mov    $0xf0112d5f,%eax
f01007f0:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007f5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007fb:	85 c0                	test   %eax,%eax
f01007fd:	0f 48 c2             	cmovs  %edx,%eax
f0100800:	c1 f8 0a             	sar    $0xa,%eax
f0100803:	50                   	push   %eax
f0100804:	68 30 23 10 f0       	push   $0xf0102330
f0100809:	e8 34 03 00 00       	call   f0100b42 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f010080e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100813:	c9                   	leave  
f0100814:	c3                   	ret    

f0100815 <mon_time>:
	return (((uint64_t)high << 32) | low);
}

int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f0100815:	55                   	push   %ebp
f0100816:	89 e5                	mov    %esp,%ebp
f0100818:	57                   	push   %edi
f0100819:	56                   	push   %esi
f010081a:	53                   	push   %ebx
f010081b:	83 ec 1c             	sub    $0x1c,%esp
f010081e:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100821:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100825:	74 0c                	je     f0100833 <mon_time+0x1e>
f0100827:	bf 80 24 10 f0       	mov    $0xf0102480,%edi
f010082c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100831:	eb 1d                	jmp    f0100850 <mon_time+0x3b>
		cprintf("Usage: time [command]\n");
f0100833:	83 ec 0c             	sub    $0xc,%esp
f0100836:	68 a2 21 10 f0       	push   $0xf01021a2
f010083b:	e8 02 03 00 00       	call   f0100b42 <cprintf>
		return 0;
f0100840:	83 c4 10             	add    $0x10,%esp
f0100843:	eb 7a                	jmp    f01008bf <mon_time+0xaa>
	}

	int i;
	for (i = 0; i < NCOMMANDS && strcmp(argv[1], commands[i].name); i++)
f0100845:	83 c3 01             	add    $0x1,%ebx
f0100848:	83 c7 0c             	add    $0xc,%edi
f010084b:	83 fb 04             	cmp    $0x4,%ebx
f010084e:	74 19                	je     f0100869 <mon_time+0x54>
f0100850:	83 ec 08             	sub    $0x8,%esp
f0100853:	ff 37                	pushl  (%edi)
f0100855:	ff 76 04             	pushl  0x4(%esi)
f0100858:	e8 0e 10 00 00       	call   f010186b <strcmp>
f010085d:	83 c4 10             	add    $0x10,%esp
f0100860:	85 c0                	test   %eax,%eax
f0100862:	75 e1                	jne    f0100845 <mon_time+0x30>
		;

	if (i == NCOMMANDS) {
f0100864:	83 fb 04             	cmp    $0x4,%ebx
f0100867:	75 15                	jne    f010087e <mon_time+0x69>
		cprintf("Unknown command: %s\n", argv[1]);
f0100869:	83 ec 08             	sub    $0x8,%esp
f010086c:	ff 76 04             	pushl  0x4(%esi)
f010086f:	68 b9 21 10 f0       	push   $0xf01021b9
f0100874:	e8 c9 02 00 00       	call   f0100b42 <cprintf>
		return 0;
f0100879:	83 c4 10             	add    $0x10,%esp
f010087c:	eb 41                	jmp    f01008bf <mon_time+0xaa>
/***** Implementations of basic kernel monitor commands *****/
inline uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f010087e:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
f0100880:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100883:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		cprintf("Unknown command: %s\n", argv[1]);
		return 0;
	}

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
f0100886:	83 ec 04             	sub    $0x4,%esp
f0100889:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f010088c:	ff 75 10             	pushl  0x10(%ebp)
f010088f:	8d 46 04             	lea    0x4(%esi),%eax
f0100892:	50                   	push   %eax
f0100893:	8b 45 08             	mov    0x8(%ebp),%eax
f0100896:	83 e8 01             	sub    $0x1,%eax
f0100899:	50                   	push   %eax
f010089a:	ff 14 95 88 24 10 f0 	call   *-0xfefdb78(,%edx,4)
/***** Implementations of basic kernel monitor commands *****/
inline uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f01008a1:	0f 31                	rdtsc  

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
	uint64_t end = rdtsc();

	cprintf("%s cycles: %llu\n", argv[1], end - start);
f01008a3:	89 c1                	mov    %eax,%ecx
f01008a5:	89 d3                	mov    %edx,%ebx
f01008a7:	2b 4d e0             	sub    -0x20(%ebp),%ecx
f01008aa:	1b 5d e4             	sbb    -0x1c(%ebp),%ebx
f01008ad:	53                   	push   %ebx
f01008ae:	51                   	push   %ecx
f01008af:	ff 76 04             	pushl  0x4(%esi)
f01008b2:	68 ce 21 10 f0       	push   $0xf01021ce
f01008b7:	e8 86 02 00 00       	call   f0100b42 <cprintf>

	return 0;
f01008bc:	83 c4 20             	add    $0x20,%esp
}
f01008bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008c7:	5b                   	pop    %ebx
f01008c8:	5e                   	pop    %esi
f01008c9:	5f                   	pop    %edi
f01008ca:	5d                   	pop    %ebp
f01008cb:	c3                   	ret    

f01008cc <mon_backtrace>:
}

#define EBP_OFFSET(ebp, offset) (*((uint32_t *)(ebp) + (offset)))
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008cc:	55                   	push   %ebp
f01008cd:	89 e5                	mov    %esp,%ebp
f01008cf:	57                   	push   %edi
f01008d0:	56                   	push   %esi
f01008d1:	53                   	push   %ebx
f01008d2:	83 ec 48             	sub    $0x48,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008d5:	89 ee                	mov    %ebp,%esi
	// Your code here.
		uint32_t ebp = read_ebp(), eip;

		cprintf("Stack backtrace:\n");
f01008d7:	68 df 21 10 f0       	push   $0xf01021df
f01008dc:	e8 61 02 00 00       	call   f0100b42 <cprintf>
		while(ebp != 0x0) {
f01008e1:	83 c4 10             	add    $0x10,%esp
f01008e4:	85 f6                	test   %esi,%esi
f01008e6:	0f 84 97 00 00 00    	je     f0100983 <mon_backtrace+0xb7>
f01008ec:	89 f3                	mov    %esi,%ebx
			cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
					eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
					EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
			// debug info
			struct Eipdebuginfo info;
			if (!debuginfo_eip(eip, &info)) {
f01008ee:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008f1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	// Your code here.
		uint32_t ebp = read_ebp(), eip;

		cprintf("Stack backtrace:\n");
		while(ebp != 0x0) {
			eip = EBP_OFFSET(ebp, 1);
f01008f4:	8b 73 04             	mov    0x4(%ebx),%esi
			cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
f01008f7:	ff 73 18             	pushl  0x18(%ebx)
f01008fa:	ff 73 14             	pushl  0x14(%ebx)
f01008fd:	ff 73 10             	pushl  0x10(%ebx)
f0100900:	ff 73 0c             	pushl  0xc(%ebx)
f0100903:	ff 73 08             	pushl  0x8(%ebx)
f0100906:	53                   	push   %ebx
f0100907:	56                   	push   %esi
f0100908:	68 5c 23 10 f0       	push   $0xf010235c
f010090d:	e8 30 02 00 00       	call   f0100b42 <cprintf>
					eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
					EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
			// debug info
			struct Eipdebuginfo info;
			if (!debuginfo_eip(eip, &info)) {
f0100912:	83 c4 18             	add    $0x18,%esp
f0100915:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100918:	56                   	push   %esi
f0100919:	e8 64 03 00 00       	call   f0100c82 <debuginfo_eip>
f010091e:	83 c4 10             	add    $0x10,%esp
f0100921:	85 c0                	test   %eax,%eax
f0100923:	75 54                	jne    f0100979 <mon_backtrace+0xad>
f0100925:	89 65 c0             	mov    %esp,-0x40(%ebp)
				char func_name[info.eip_fn_namelen + 1];
f0100928:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010092b:	8d 41 10             	lea    0x10(%ecx),%eax
f010092e:	bf 10 00 00 00       	mov    $0x10,%edi
f0100933:	ba 00 00 00 00       	mov    $0x0,%edx
f0100938:	f7 f7                	div    %edi
f010093a:	c1 e0 04             	shl    $0x4,%eax
f010093d:	29 c4                	sub    %eax,%esp
f010093f:	89 e0                	mov    %esp,%eax
f0100941:	89 e7                	mov    %esp,%edi
				func_name[info.eip_fn_namelen] = '\0';
f0100943:	c6 04 0c 00          	movb   $0x0,(%esp,%ecx,1)
				if (strncpy(func_name, info.eip_fn_name, info.eip_fn_namelen)) {
f0100947:	83 ec 04             	sub    $0x4,%esp
f010094a:	51                   	push   %ecx
f010094b:	ff 75 d8             	pushl  -0x28(%ebp)
f010094e:	50                   	push   %eax
f010094f:	e8 99 0e 00 00       	call   f01017ed <strncpy>
f0100954:	83 c4 10             	add    $0x10,%esp
f0100957:	85 c0                	test   %eax,%eax
f0100959:	74 1b                	je     f0100976 <mon_backtrace+0xaa>
					cprintf("\t%s:%d: %s+%x\n\n", info.eip_file, info.eip_line,
f010095b:	83 ec 0c             	sub    $0xc,%esp
f010095e:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100961:	56                   	push   %esi
f0100962:	57                   	push   %edi
f0100963:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100966:	ff 75 d0             	pushl  -0x30(%ebp)
f0100969:	68 f1 21 10 f0       	push   $0xf01021f1
f010096e:	e8 cf 01 00 00       	call   f0100b42 <cprintf>
f0100973:	83 c4 20             	add    $0x20,%esp
f0100976:	8b 65 c0             	mov    -0x40(%ebp),%esp
							func_name, eip - info.eip_fn_addr);
				}
			}
			// warning: the value of ebp to print is register value, not stack value
			ebp = EBP_OFFSET(ebp, 0);
f0100979:	8b 1b                	mov    (%ebx),%ebx
{
	// Your code here.
		uint32_t ebp = read_ebp(), eip;

		cprintf("Stack backtrace:\n");
		while(ebp != 0x0) {
f010097b:	85 db                	test   %ebx,%ebx
f010097d:	0f 85 71 ff ff ff    	jne    f01008f4 <mon_backtrace+0x28>
			// warning: the value of ebp to print is register value, not stack value
			ebp = EBP_OFFSET(ebp, 0);
		}

    overflow_me();
    cprintf("Backtrace success\n");
f0100983:	83 ec 0c             	sub    $0xc,%esp
f0100986:	68 01 22 10 f0       	push   $0xf0102201
f010098b:	e8 b2 01 00 00       	call   f0100b42 <cprintf>
	return 0;
}
f0100990:	b8 00 00 00 00       	mov    $0x0,%eax
f0100995:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100998:	5b                   	pop    %ebx
f0100999:	5e                   	pop    %esi
f010099a:	5f                   	pop    %edi
f010099b:	5d                   	pop    %ebp
f010099c:	c3                   	ret    

f010099d <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f010099d:	55                   	push   %ebp
f010099e:	89 e5                	mov    %esp,%ebp
f01009a0:	83 ec 14             	sub    $0x14,%esp
    cprintf("Overflow success\n");
f01009a3:	68 14 22 10 f0       	push   $0xf0102214
f01009a8:	e8 95 01 00 00       	call   f0100b42 <cprintf>
}
f01009ad:	83 c4 10             	add    $0x10,%esp
f01009b0:	c9                   	leave  
f01009b1:	c3                   	ret    

f01009b2 <start_overflow>:

void
start_overflow(void)
{
f01009b2:	55                   	push   %ebp
f01009b3:	89 e5                	mov    %esp,%ebp
		// str[ret_byte_2] = '\0';
		// cprintf("%s%n\n", str, pret_addr+2);
		// str[ret_byte_2] = 'h';
		// str[ret_byte_3] = '\0';
		// cprintf("%s%n\n", str, pret_addr+3);
}
f01009b5:	5d                   	pop    %ebp
f01009b6:	c3                   	ret    

f01009b7 <overflow_me>:

void
overflow_me(void)
{
f01009b7:	55                   	push   %ebp
f01009b8:	89 e5                	mov    %esp,%ebp
        start_overflow();
}
f01009ba:	5d                   	pop    %ebp
f01009bb:	c3                   	ret    

f01009bc <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009bc:	55                   	push   %ebp
f01009bd:	89 e5                	mov    %esp,%ebp
f01009bf:	57                   	push   %edi
f01009c0:	56                   	push   %esi
f01009c1:	53                   	push   %ebx
f01009c2:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009c5:	68 94 23 10 f0       	push   $0xf0102394
f01009ca:	e8 73 01 00 00       	call   f0100b42 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009cf:	c7 04 24 b8 23 10 f0 	movl   $0xf01023b8,(%esp)
f01009d6:	e8 67 01 00 00       	call   f0100b42 <cprintf>
f01009db:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009de:	83 ec 0c             	sub    $0xc,%esp
f01009e1:	68 26 22 10 f0       	push   $0xf0102226
f01009e6:	e8 ae 0c 00 00       	call   f0101699 <readline>
f01009eb:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009ed:	83 c4 10             	add    $0x10,%esp
f01009f0:	85 c0                	test   %eax,%eax
f01009f2:	74 ea                	je     f01009de <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009f4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009fb:	be 00 00 00 00       	mov    $0x0,%esi
f0100a00:	eb 0a                	jmp    f0100a0c <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a02:	c6 03 00             	movb   $0x0,(%ebx)
f0100a05:	89 f7                	mov    %esi,%edi
f0100a07:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a0a:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0c:	0f b6 03             	movzbl (%ebx),%eax
f0100a0f:	84 c0                	test   %al,%al
f0100a11:	74 6a                	je     f0100a7d <monitor+0xc1>
f0100a13:	83 ec 08             	sub    $0x8,%esp
f0100a16:	0f be c0             	movsbl %al,%eax
f0100a19:	50                   	push   %eax
f0100a1a:	68 2a 22 10 f0       	push   $0xf010222a
f0100a1f:	e8 cb 0e 00 00       	call   f01018ef <strchr>
f0100a24:	83 c4 10             	add    $0x10,%esp
f0100a27:	85 c0                	test   %eax,%eax
f0100a29:	75 d7                	jne    f0100a02 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100a2b:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a2e:	74 4d                	je     f0100a7d <monitor+0xc1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a30:	83 fe 0f             	cmp    $0xf,%esi
f0100a33:	75 14                	jne    f0100a49 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a35:	83 ec 08             	sub    $0x8,%esp
f0100a38:	6a 10                	push   $0x10
f0100a3a:	68 2f 22 10 f0       	push   $0xf010222f
f0100a3f:	e8 fe 00 00 00       	call   f0100b42 <cprintf>
f0100a44:	83 c4 10             	add    $0x10,%esp
f0100a47:	eb 95                	jmp    f01009de <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100a49:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a4c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a50:	0f b6 03             	movzbl (%ebx),%eax
f0100a53:	84 c0                	test   %al,%al
f0100a55:	75 0c                	jne    f0100a63 <monitor+0xa7>
f0100a57:	eb b1                	jmp    f0100a0a <monitor+0x4e>
			buf++;
f0100a59:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a5c:	0f b6 03             	movzbl (%ebx),%eax
f0100a5f:	84 c0                	test   %al,%al
f0100a61:	74 a7                	je     f0100a0a <monitor+0x4e>
f0100a63:	83 ec 08             	sub    $0x8,%esp
f0100a66:	0f be c0             	movsbl %al,%eax
f0100a69:	50                   	push   %eax
f0100a6a:	68 2a 22 10 f0       	push   $0xf010222a
f0100a6f:	e8 7b 0e 00 00       	call   f01018ef <strchr>
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	85 c0                	test   %eax,%eax
f0100a79:	74 de                	je     f0100a59 <monitor+0x9d>
f0100a7b:	eb 8d                	jmp    f0100a0a <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100a7d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a84:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a85:	85 f6                	test   %esi,%esi
f0100a87:	0f 84 51 ff ff ff    	je     f01009de <monitor+0x22>
f0100a8d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a92:	83 ec 08             	sub    $0x8,%esp
f0100a95:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a98:	ff 34 85 80 24 10 f0 	pushl  -0xfefdb80(,%eax,4)
f0100a9f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aa2:	e8 c4 0d 00 00       	call   f010186b <strcmp>
f0100aa7:	83 c4 10             	add    $0x10,%esp
f0100aaa:	85 c0                	test   %eax,%eax
f0100aac:	75 21                	jne    f0100acf <monitor+0x113>
			return commands[i].func(argc, argv, tf);
f0100aae:	83 ec 04             	sub    $0x4,%esp
f0100ab1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ab4:	ff 75 08             	pushl  0x8(%ebp)
f0100ab7:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aba:	52                   	push   %edx
f0100abb:	56                   	push   %esi
f0100abc:	ff 14 85 88 24 10 f0 	call   *-0xfefdb78(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ac3:	83 c4 10             	add    $0x10,%esp
f0100ac6:	85 c0                	test   %eax,%eax
f0100ac8:	78 25                	js     f0100aef <monitor+0x133>
f0100aca:	e9 0f ff ff ff       	jmp    f01009de <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100acf:	83 c3 01             	add    $0x1,%ebx
f0100ad2:	83 fb 04             	cmp    $0x4,%ebx
f0100ad5:	75 bb                	jne    f0100a92 <monitor+0xd6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ad7:	83 ec 08             	sub    $0x8,%esp
f0100ada:	ff 75 a8             	pushl  -0x58(%ebp)
f0100add:	68 4c 22 10 f0       	push   $0xf010224c
f0100ae2:	e8 5b 00 00 00       	call   f0100b42 <cprintf>
f0100ae7:	83 c4 10             	add    $0x10,%esp
f0100aea:	e9 ef fe ff ff       	jmp    f01009de <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100af2:	5b                   	pop    %ebx
f0100af3:	5e                   	pop    %esi
f0100af4:	5f                   	pop    %edi
f0100af5:	5d                   	pop    %ebp
f0100af6:	c3                   	ret    

f0100af7 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100af7:	55                   	push   %ebp
f0100af8:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100afa:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100afd:	5d                   	pop    %ebp
f0100afe:	c3                   	ret    

f0100aff <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100aff:	55                   	push   %ebp
f0100b00:	89 e5                	mov    %esp,%ebp
f0100b02:	53                   	push   %ebx
f0100b03:	83 ec 10             	sub    $0x10,%esp
f0100b06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0100b09:	ff 75 08             	pushl  0x8(%ebp)
f0100b0c:	e8 09 fc ff ff       	call   f010071a <cputchar>
    (*cnt)++;
f0100b11:	83 03 01             	addl   $0x1,(%ebx)
}
f0100b14:	83 c4 10             	add    $0x10,%esp
f0100b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b1a:	c9                   	leave  
f0100b1b:	c3                   	ret    

f0100b1c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b1c:	55                   	push   %ebp
f0100b1d:	89 e5                	mov    %esp,%ebp
f0100b1f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100b22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b29:	ff 75 0c             	pushl  0xc(%ebp)
f0100b2c:	ff 75 08             	pushl  0x8(%ebp)
f0100b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b32:	50                   	push   %eax
f0100b33:	68 ff 0a 10 f0       	push   $0xf0100aff
f0100b38:	e8 26 06 00 00       	call   f0101163 <vprintfmt>
	return cnt;
}
f0100b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b40:	c9                   	leave  
f0100b41:	c3                   	ret    

f0100b42 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b42:	55                   	push   %ebp
f0100b43:	89 e5                	mov    %esp,%ebp
f0100b45:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b48:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b4b:	50                   	push   %eax
f0100b4c:	ff 75 08             	pushl  0x8(%ebp)
f0100b4f:	e8 c8 ff ff ff       	call   f0100b1c <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b54:	c9                   	leave  
f0100b55:	c3                   	ret    

f0100b56 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b56:	55                   	push   %ebp
f0100b57:	89 e5                	mov    %esp,%ebp
f0100b59:	57                   	push   %edi
f0100b5a:	56                   	push   %esi
f0100b5b:	53                   	push   %ebx
f0100b5c:	83 ec 14             	sub    $0x14,%esp
f0100b5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b65:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b68:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b6b:	8b 1a                	mov    (%edx),%ebx
f0100b6d:	8b 01                	mov    (%ecx),%eax
f0100b6f:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f0100b72:	39 c3                	cmp    %eax,%ebx
f0100b74:	0f 8f 9a 00 00 00    	jg     f0100c14 <stab_binsearch+0xbe>
f0100b7a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b84:	01 d8                	add    %ebx,%eax
f0100b86:	89 c6                	mov    %eax,%esi
f0100b88:	c1 ee 1f             	shr    $0x1f,%esi
f0100b8b:	01 c6                	add    %eax,%esi
f0100b8d:	d1 fe                	sar    %esi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b8f:	39 de                	cmp    %ebx,%esi
f0100b91:	0f 8c c4 00 00 00    	jl     f0100c5b <stab_binsearch+0x105>
f0100b97:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100b9a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b9d:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100ba0:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0100ba4:	39 c7                	cmp    %eax,%edi
f0100ba6:	0f 84 b4 00 00 00    	je     f0100c60 <stab_binsearch+0x10a>
f0100bac:	89 f0                	mov    %esi,%eax
			m--;
f0100bae:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100bb1:	39 d8                	cmp    %ebx,%eax
f0100bb3:	0f 8c a2 00 00 00    	jl     f0100c5b <stab_binsearch+0x105>
f0100bb9:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0100bbd:	83 ea 0c             	sub    $0xc,%edx
f0100bc0:	39 f9                	cmp    %edi,%ecx
f0100bc2:	75 ea                	jne    f0100bae <stab_binsearch+0x58>
f0100bc4:	e9 99 00 00 00       	jmp    f0100c62 <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100bc9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bcc:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100bce:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100bd1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bd8:	eb 2b                	jmp    f0100c05 <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100bda:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bdd:	76 14                	jbe    f0100bf3 <stab_binsearch+0x9d>
			*region_right = m - 1;
f0100bdf:	83 e8 01             	sub    $0x1,%eax
f0100be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100be5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100be8:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100bea:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bf1:	eb 12                	jmp    f0100c05 <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bf3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bf6:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100bf8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bfc:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100bfe:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100c05:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0100c08:	0f 8d 73 ff ff ff    	jge    f0100b81 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100c0e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c12:	75 0f                	jne    f0100c23 <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f0100c14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c17:	8b 00                	mov    (%eax),%eax
f0100c19:	83 e8 01             	sub    $0x1,%eax
f0100c1c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c1f:	89 07                	mov    %eax,(%edi)
f0100c21:	eb 57                	jmp    f0100c7a <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c23:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c26:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c28:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c2b:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c2d:	39 c8                	cmp    %ecx,%eax
f0100c2f:	7e 23                	jle    f0100c54 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0100c31:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c34:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100c37:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0100c3a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100c3e:	39 df                	cmp    %ebx,%edi
f0100c40:	74 12                	je     f0100c54 <stab_binsearch+0xfe>
		     l--)
f0100c42:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c45:	39 c8                	cmp    %ecx,%eax
f0100c47:	7e 0b                	jle    f0100c54 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0100c49:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f0100c4d:	83 ea 0c             	sub    $0xc,%edx
f0100c50:	39 df                	cmp    %ebx,%edi
f0100c52:	75 ee                	jne    f0100c42 <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100c54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c57:	89 07                	mov    %eax,(%edi)
	}
}
f0100c59:	eb 1f                	jmp    f0100c7a <stab_binsearch+0x124>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100c5b:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100c5e:	eb a5                	jmp    f0100c05 <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100c60:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100c62:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c65:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c68:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100c6c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c6f:	0f 82 54 ff ff ff    	jb     f0100bc9 <stab_binsearch+0x73>
f0100c75:	e9 60 ff ff ff       	jmp    f0100bda <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c7a:	83 c4 14             	add    $0x14,%esp
f0100c7d:	5b                   	pop    %ebx
f0100c7e:	5e                   	pop    %esi
f0100c7f:	5f                   	pop    %edi
f0100c80:	5d                   	pop    %ebp
f0100c81:	c3                   	ret    

f0100c82 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c82:	55                   	push   %ebp
f0100c83:	89 e5                	mov    %esp,%ebp
f0100c85:	57                   	push   %edi
f0100c86:	56                   	push   %esi
f0100c87:	53                   	push   %ebx
f0100c88:	83 ec 3c             	sub    $0x3c,%esp
f0100c8b:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c91:	c7 03 b0 24 10 f0    	movl   $0xf01024b0,(%ebx)
	info->eip_line = 0;
f0100c97:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100c9e:	c7 43 08 b0 24 10 f0 	movl   $0xf01024b0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100ca5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100cac:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100caf:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100cb6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100cbc:	76 11                	jbe    f0100ccf <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100cbe:	b8 fe 7f 10 f0       	mov    $0xf0107ffe,%eax
f0100cc3:	3d 81 65 10 f0       	cmp    $0xf0106581,%eax
f0100cc8:	77 19                	ja     f0100ce3 <debuginfo_eip+0x61>
f0100cca:	e9 ce 01 00 00       	jmp    f0100e9d <debuginfo_eip+0x21b>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ccf:	83 ec 04             	sub    $0x4,%esp
f0100cd2:	68 ba 24 10 f0       	push   $0xf01024ba
f0100cd7:	6a 7f                	push   $0x7f
f0100cd9:	68 c7 24 10 f0       	push   $0xf01024c7
f0100cde:	e8 bc f4 ff ff       	call   f010019f <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ce3:	80 3d fd 7f 10 f0 00 	cmpb   $0x0,0xf0107ffd
f0100cea:	0f 85 b4 01 00 00    	jne    f0100ea4 <debuginfo_eip+0x222>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100cf0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100cf7:	b8 80 65 10 f0       	mov    $0xf0106580,%eax
f0100cfc:	2d 64 27 10 f0       	sub    $0xf0102764,%eax
f0100d01:	c1 f8 02             	sar    $0x2,%eax
f0100d04:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100d0a:	83 e8 01             	sub    $0x1,%eax
f0100d0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d10:	83 ec 08             	sub    $0x8,%esp
f0100d13:	56                   	push   %esi
f0100d14:	6a 64                	push   $0x64
f0100d16:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d19:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d1c:	b8 64 27 10 f0       	mov    $0xf0102764,%eax
f0100d21:	e8 30 fe ff ff       	call   f0100b56 <stab_binsearch>
	if (lfile == 0)
f0100d26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d29:	83 c4 10             	add    $0x10,%esp
f0100d2c:	85 c0                	test   %eax,%eax
f0100d2e:	0f 84 77 01 00 00    	je     f0100eab <debuginfo_eip+0x229>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d34:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d37:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d3a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d3d:	83 ec 08             	sub    $0x8,%esp
f0100d40:	56                   	push   %esi
f0100d41:	6a 24                	push   $0x24
f0100d43:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d46:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d49:	b8 64 27 10 f0       	mov    $0xf0102764,%eax
f0100d4e:	e8 03 fe ff ff       	call   f0100b56 <stab_binsearch>

	if (lfun <= rfun) {
f0100d53:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d56:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100d59:	83 c4 10             	add    $0x10,%esp
f0100d5c:	39 d0                	cmp    %edx,%eax
f0100d5e:	7f 40                	jg     f0100da0 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d60:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100d63:	c1 e1 02             	shl    $0x2,%ecx
f0100d66:	8d b9 64 27 10 f0    	lea    -0xfefd89c(%ecx),%edi
f0100d6c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100d6f:	8b b9 64 27 10 f0    	mov    -0xfefd89c(%ecx),%edi
f0100d75:	b9 fe 7f 10 f0       	mov    $0xf0107ffe,%ecx
f0100d7a:	81 e9 81 65 10 f0    	sub    $0xf0106581,%ecx
f0100d80:	39 cf                	cmp    %ecx,%edi
f0100d82:	73 09                	jae    f0100d8d <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d84:	81 c7 81 65 10 f0    	add    $0xf0106581,%edi
f0100d8a:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d8d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100d90:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100d93:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100d96:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d9b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100d9e:	eb 0f                	jmp    f0100daf <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100da0:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100da3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100da6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100da9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dac:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100daf:	83 ec 08             	sub    $0x8,%esp
f0100db2:	6a 3a                	push   $0x3a
f0100db4:	ff 73 08             	pushl  0x8(%ebx)
f0100db7:	e8 69 0b 00 00       	call   f0101925 <strfind>
f0100dbc:	2b 43 08             	sub    0x8(%ebx),%eax
f0100dbf:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100dc2:	83 c4 08             	add    $0x8,%esp
f0100dc5:	56                   	push   %esi
f0100dc6:	6a 44                	push   $0x44
f0100dc8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100dcb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100dce:	b8 64 27 10 f0       	mov    $0xf0102764,%eax
f0100dd3:	e8 7e fd ff ff       	call   f0100b56 <stab_binsearch>
	if (lline <= rline) {
f0100dd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ddb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100dde:	83 c4 10             	add    $0x10,%esp
f0100de1:	39 d0                	cmp    %edx,%eax
f0100de3:	0f 8f c9 00 00 00    	jg     f0100eb2 <debuginfo_eip+0x230>
		info->eip_line = rline;
f0100de9:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100dec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100def:	39 f8                	cmp    %edi,%eax
f0100df1:	7c 5e                	jl     f0100e51 <debuginfo_eip+0x1cf>
	       && stabs[lline].n_type != N_SOL
f0100df3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100df6:	8d 34 95 64 27 10 f0 	lea    -0xfefd89c(,%edx,4),%esi
f0100dfd:	0f b6 56 04          	movzbl 0x4(%esi),%edx
f0100e01:	80 fa 84             	cmp    $0x84,%dl
f0100e04:	74 2b                	je     f0100e31 <debuginfo_eip+0x1af>
f0100e06:	89 f1                	mov    %esi,%ecx
f0100e08:	83 c6 08             	add    $0x8,%esi
f0100e0b:	eb 16                	jmp    f0100e23 <debuginfo_eip+0x1a1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100e0d:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e10:	39 f8                	cmp    %edi,%eax
f0100e12:	7c 3d                	jl     f0100e51 <debuginfo_eip+0x1cf>
	       && stabs[lline].n_type != N_SOL
f0100e14:	0f b6 51 f8          	movzbl -0x8(%ecx),%edx
f0100e18:	83 e9 0c             	sub    $0xc,%ecx
f0100e1b:	83 ee 0c             	sub    $0xc,%esi
f0100e1e:	80 fa 84             	cmp    $0x84,%dl
f0100e21:	74 0e                	je     f0100e31 <debuginfo_eip+0x1af>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e23:	80 fa 64             	cmp    $0x64,%dl
f0100e26:	75 e5                	jne    f0100e0d <debuginfo_eip+0x18b>
f0100e28:	83 3e 00             	cmpl   $0x0,(%esi)
f0100e2b:	74 e0                	je     f0100e0d <debuginfo_eip+0x18b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e2d:	39 c7                	cmp    %eax,%edi
f0100e2f:	7f 20                	jg     f0100e51 <debuginfo_eip+0x1cf>
f0100e31:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100e34:	8b 14 85 64 27 10 f0 	mov    -0xfefd89c(,%eax,4),%edx
f0100e3b:	b8 fe 7f 10 f0       	mov    $0xf0107ffe,%eax
f0100e40:	2d 81 65 10 f0       	sub    $0xf0106581,%eax
f0100e45:	39 c2                	cmp    %eax,%edx
f0100e47:	73 08                	jae    f0100e51 <debuginfo_eip+0x1cf>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e49:	81 c2 81 65 10 f0    	add    $0xf0106581,%edx
f0100e4f:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e51:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100e54:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e57:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e5c:	39 f1                	cmp    %esi,%ecx
f0100e5e:	7d 6c                	jge    f0100ecc <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
f0100e60:	8d 41 01             	lea    0x1(%ecx),%eax
f0100e63:	39 c6                	cmp    %eax,%esi
f0100e65:	7e 52                	jle    f0100eb9 <debuginfo_eip+0x237>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e67:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e6a:	c1 e2 02             	shl    $0x2,%edx
f0100e6d:	80 ba 68 27 10 f0 a0 	cmpb   $0xa0,-0xfefd898(%edx)
f0100e74:	75 4a                	jne    f0100ec0 <debuginfo_eip+0x23e>
f0100e76:	8d 41 02             	lea    0x2(%ecx),%eax
f0100e79:	81 c2 58 27 10 f0    	add    $0xf0102758,%edx
		     lline++)
			info->eip_fn_narg++;
f0100e7f:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100e83:	39 c6                	cmp    %eax,%esi
f0100e85:	74 40                	je     f0100ec7 <debuginfo_eip+0x245>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e87:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f0100e8b:	83 c0 01             	add    $0x1,%eax
f0100e8e:	83 c2 0c             	add    $0xc,%edx
f0100e91:	80 f9 a0             	cmp    $0xa0,%cl
f0100e94:	74 e9                	je     f0100e7f <debuginfo_eip+0x1fd>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e96:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e9b:	eb 2f                	jmp    f0100ecc <debuginfo_eip+0x24a>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100e9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ea2:	eb 28                	jmp    f0100ecc <debuginfo_eip+0x24a>
f0100ea4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ea9:	eb 21                	jmp    f0100ecc <debuginfo_eip+0x24a>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100eab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100eb0:	eb 1a                	jmp    f0100ecc <debuginfo_eip+0x24a>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = rline;
	} else {
		return -1;
f0100eb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100eb7:	eb 13                	jmp    f0100ecc <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100eb9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ebe:	eb 0c                	jmp    f0100ecc <debuginfo_eip+0x24a>
f0100ec0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ec5:	eb 05                	jmp    f0100ecc <debuginfo_eip+0x24a>
f0100ec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ecc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ecf:	5b                   	pop    %ebx
f0100ed0:	5e                   	pop    %esi
f0100ed1:	5f                   	pop    %edi
f0100ed2:	5d                   	pop    %ebp
f0100ed3:	c3                   	ret    

f0100ed4 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ed4:	55                   	push   %ebp
f0100ed5:	89 e5                	mov    %esp,%ebp
f0100ed7:	57                   	push   %edi
f0100ed8:	56                   	push   %esi
f0100ed9:	53                   	push   %ebx
f0100eda:	83 ec 1c             	sub    $0x1c,%esp
f0100edd:	89 c7                	mov    %eax,%edi
f0100edf:	89 d6                	mov    %edx,%esi
f0100ee1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ee4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ee7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100eea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100eed:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
f0100ef0:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0100ef4:	0f 85 bf 00 00 00    	jne    f0100fb9 <printnum+0xe5>
f0100efa:	39 1d 5c 25 11 f0    	cmp    %ebx,0xf011255c
f0100f00:	0f 8d de 00 00 00    	jge    f0100fe4 <printnum+0x110>
		judge_time_for_space = width;
f0100f06:	89 1d 5c 25 11 f0    	mov    %ebx,0xf011255c
f0100f0c:	e9 d3 00 00 00       	jmp    f0100fe4 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0100f11:	83 eb 01             	sub    $0x1,%ebx
f0100f14:	85 db                	test   %ebx,%ebx
f0100f16:	7f 37                	jg     f0100f4f <printnum+0x7b>
f0100f18:	e9 ea 00 00 00       	jmp    f0101007 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
f0100f1d:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100f20:	a3 58 25 11 f0       	mov    %eax,0xf0112558
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f25:	83 ec 08             	sub    $0x8,%esp
f0100f28:	56                   	push   %esi
f0100f29:	83 ec 04             	sub    $0x4,%esp
f0100f2c:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f2f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f32:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f35:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f38:	e8 83 0d 00 00       	call   f0101cc0 <__umoddi3>
f0100f3d:	83 c4 14             	add    $0x14,%esp
f0100f40:	0f be 80 d5 24 10 f0 	movsbl -0xfefdb2b(%eax),%eax
f0100f47:	50                   	push   %eax
f0100f48:	ff d7                	call   *%edi
f0100f4a:	83 c4 10             	add    $0x10,%esp
f0100f4d:	eb 16                	jmp    f0100f65 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
f0100f4f:	83 ec 08             	sub    $0x8,%esp
f0100f52:	56                   	push   %esi
f0100f53:	ff 75 18             	pushl  0x18(%ebp)
f0100f56:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0100f58:	83 c4 10             	add    $0x10,%esp
f0100f5b:	83 eb 01             	sub    $0x1,%ebx
f0100f5e:	75 ef                	jne    f0100f4f <printnum+0x7b>
f0100f60:	e9 a2 00 00 00       	jmp    f0101007 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
f0100f65:	3b 1d 5c 25 11 f0    	cmp    0xf011255c,%ebx
f0100f6b:	0f 85 76 01 00 00    	jne    f01010e7 <printnum+0x213>
		while(num_of_space-- > 0)
f0100f71:	a1 58 25 11 f0       	mov    0xf0112558,%eax
f0100f76:	8d 50 ff             	lea    -0x1(%eax),%edx
f0100f79:	89 15 58 25 11 f0    	mov    %edx,0xf0112558
f0100f7f:	85 c0                	test   %eax,%eax
f0100f81:	7e 1d                	jle    f0100fa0 <printnum+0xcc>
			putch(' ', putdat);
f0100f83:	83 ec 08             	sub    $0x8,%esp
f0100f86:	56                   	push   %esi
f0100f87:	6a 20                	push   $0x20
f0100f89:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
f0100f8b:	a1 58 25 11 f0       	mov    0xf0112558,%eax
f0100f90:	8d 50 ff             	lea    -0x1(%eax),%edx
f0100f93:	89 15 58 25 11 f0    	mov    %edx,0xf0112558
f0100f99:	83 c4 10             	add    $0x10,%esp
f0100f9c:	85 c0                	test   %eax,%eax
f0100f9e:	7f e3                	jg     f0100f83 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
f0100fa0:	c7 05 58 25 11 f0 00 	movl   $0x0,0xf0112558
f0100fa7:	00 00 00 
		judge_time_for_space = 0;
f0100faa:	c7 05 5c 25 11 f0 00 	movl   $0x0,0xf011255c
f0100fb1:	00 00 00 
	}
}
f0100fb4:	e9 2e 01 00 00       	jmp    f01010e7 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100fb9:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fbc:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fc1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fc4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100fcd:	83 fa 00             	cmp    $0x0,%edx
f0100fd0:	0f 87 ba 00 00 00    	ja     f0101090 <printnum+0x1bc>
f0100fd6:	3b 45 10             	cmp    0x10(%ebp),%eax
f0100fd9:	0f 83 b1 00 00 00    	jae    f0101090 <printnum+0x1bc>
f0100fdf:	e9 2d ff ff ff       	jmp    f0100f11 <printnum+0x3d>
f0100fe4:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fe7:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fec:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fef:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ff5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ff8:	83 fa 00             	cmp    $0x0,%edx
f0100ffb:	77 37                	ja     f0101034 <printnum+0x160>
f0100ffd:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101000:	73 32                	jae    f0101034 <printnum+0x160>
f0101002:	e9 16 ff ff ff       	jmp    f0100f1d <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101007:	83 ec 08             	sub    $0x8,%esp
f010100a:	56                   	push   %esi
f010100b:	83 ec 04             	sub    $0x4,%esp
f010100e:	ff 75 dc             	pushl  -0x24(%ebp)
f0101011:	ff 75 d8             	pushl  -0x28(%ebp)
f0101014:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101017:	ff 75 e0             	pushl  -0x20(%ebp)
f010101a:	e8 a1 0c 00 00       	call   f0101cc0 <__umoddi3>
f010101f:	83 c4 14             	add    $0x14,%esp
f0101022:	0f be 80 d5 24 10 f0 	movsbl -0xfefdb2b(%eax),%eax
f0101029:	50                   	push   %eax
f010102a:	ff d7                	call   *%edi
f010102c:	83 c4 10             	add    $0x10,%esp
f010102f:	e9 b3 00 00 00       	jmp    f01010e7 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101034:	83 ec 0c             	sub    $0xc,%esp
f0101037:	ff 75 18             	pushl  0x18(%ebp)
f010103a:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010103d:	50                   	push   %eax
f010103e:	ff 75 10             	pushl  0x10(%ebp)
f0101041:	83 ec 08             	sub    $0x8,%esp
f0101044:	ff 75 dc             	pushl  -0x24(%ebp)
f0101047:	ff 75 d8             	pushl  -0x28(%ebp)
f010104a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010104d:	ff 75 e0             	pushl  -0x20(%ebp)
f0101050:	e8 3b 0b 00 00       	call   f0101b90 <__udivdi3>
f0101055:	83 c4 18             	add    $0x18,%esp
f0101058:	52                   	push   %edx
f0101059:	50                   	push   %eax
f010105a:	89 f2                	mov    %esi,%edx
f010105c:	89 f8                	mov    %edi,%eax
f010105e:	e8 71 fe ff ff       	call   f0100ed4 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101063:	83 c4 18             	add    $0x18,%esp
f0101066:	56                   	push   %esi
f0101067:	83 ec 04             	sub    $0x4,%esp
f010106a:	ff 75 dc             	pushl  -0x24(%ebp)
f010106d:	ff 75 d8             	pushl  -0x28(%ebp)
f0101070:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101073:	ff 75 e0             	pushl  -0x20(%ebp)
f0101076:	e8 45 0c 00 00       	call   f0101cc0 <__umoddi3>
f010107b:	83 c4 14             	add    $0x14,%esp
f010107e:	0f be 80 d5 24 10 f0 	movsbl -0xfefdb2b(%eax),%eax
f0101085:	50                   	push   %eax
f0101086:	ff d7                	call   *%edi
f0101088:	83 c4 10             	add    $0x10,%esp
f010108b:	e9 d5 fe ff ff       	jmp    f0100f65 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101090:	83 ec 0c             	sub    $0xc,%esp
f0101093:	ff 75 18             	pushl  0x18(%ebp)
f0101096:	83 eb 01             	sub    $0x1,%ebx
f0101099:	53                   	push   %ebx
f010109a:	ff 75 10             	pushl  0x10(%ebp)
f010109d:	83 ec 08             	sub    $0x8,%esp
f01010a0:	ff 75 dc             	pushl  -0x24(%ebp)
f01010a3:	ff 75 d8             	pushl  -0x28(%ebp)
f01010a6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01010a9:	ff 75 e0             	pushl  -0x20(%ebp)
f01010ac:	e8 df 0a 00 00       	call   f0101b90 <__udivdi3>
f01010b1:	83 c4 18             	add    $0x18,%esp
f01010b4:	52                   	push   %edx
f01010b5:	50                   	push   %eax
f01010b6:	89 f2                	mov    %esi,%edx
f01010b8:	89 f8                	mov    %edi,%eax
f01010ba:	e8 15 fe ff ff       	call   f0100ed4 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01010bf:	83 c4 18             	add    $0x18,%esp
f01010c2:	56                   	push   %esi
f01010c3:	83 ec 04             	sub    $0x4,%esp
f01010c6:	ff 75 dc             	pushl  -0x24(%ebp)
f01010c9:	ff 75 d8             	pushl  -0x28(%ebp)
f01010cc:	ff 75 e4             	pushl  -0x1c(%ebp)
f01010cf:	ff 75 e0             	pushl  -0x20(%ebp)
f01010d2:	e8 e9 0b 00 00       	call   f0101cc0 <__umoddi3>
f01010d7:	83 c4 14             	add    $0x14,%esp
f01010da:	0f be 80 d5 24 10 f0 	movsbl -0xfefdb2b(%eax),%eax
f01010e1:	50                   	push   %eax
f01010e2:	ff d7                	call   *%edi
f01010e4:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
f01010e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010ea:	5b                   	pop    %ebx
f01010eb:	5e                   	pop    %esi
f01010ec:	5f                   	pop    %edi
f01010ed:	5d                   	pop    %ebp
f01010ee:	c3                   	ret    

f01010ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01010ef:	55                   	push   %ebp
f01010f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01010f2:	83 fa 01             	cmp    $0x1,%edx
f01010f5:	7e 0e                	jle    f0101105 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01010f7:	8b 10                	mov    (%eax),%edx
f01010f9:	8d 4a 08             	lea    0x8(%edx),%ecx
f01010fc:	89 08                	mov    %ecx,(%eax)
f01010fe:	8b 02                	mov    (%edx),%eax
f0101100:	8b 52 04             	mov    0x4(%edx),%edx
f0101103:	eb 22                	jmp    f0101127 <getuint+0x38>
	else if (lflag)
f0101105:	85 d2                	test   %edx,%edx
f0101107:	74 10                	je     f0101119 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101109:	8b 10                	mov    (%eax),%edx
f010110b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010110e:	89 08                	mov    %ecx,(%eax)
f0101110:	8b 02                	mov    (%edx),%eax
f0101112:	ba 00 00 00 00       	mov    $0x0,%edx
f0101117:	eb 0e                	jmp    f0101127 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101119:	8b 10                	mov    (%eax),%edx
f010111b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010111e:	89 08                	mov    %ecx,(%eax)
f0101120:	8b 02                	mov    (%edx),%eax
f0101122:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101127:	5d                   	pop    %ebp
f0101128:	c3                   	ret    

f0101129 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101129:	55                   	push   %ebp
f010112a:	89 e5                	mov    %esp,%ebp
f010112c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010112f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101133:	8b 10                	mov    (%eax),%edx
f0101135:	3b 50 04             	cmp    0x4(%eax),%edx
f0101138:	73 0a                	jae    f0101144 <sprintputch+0x1b>
		*b->buf++ = ch;
f010113a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010113d:	89 08                	mov    %ecx,(%eax)
f010113f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101142:	88 02                	mov    %al,(%edx)
}
f0101144:	5d                   	pop    %ebp
f0101145:	c3                   	ret    

f0101146 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101146:	55                   	push   %ebp
f0101147:	89 e5                	mov    %esp,%ebp
f0101149:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010114c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010114f:	50                   	push   %eax
f0101150:	ff 75 10             	pushl  0x10(%ebp)
f0101153:	ff 75 0c             	pushl  0xc(%ebp)
f0101156:	ff 75 08             	pushl  0x8(%ebp)
f0101159:	e8 05 00 00 00       	call   f0101163 <vprintfmt>
	va_end(ap);
}
f010115e:	83 c4 10             	add    $0x10,%esp
f0101161:	c9                   	leave  
f0101162:	c3                   	ret    

f0101163 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101163:	55                   	push   %ebp
f0101164:	89 e5                	mov    %esp,%ebp
f0101166:	57                   	push   %edi
f0101167:	56                   	push   %esi
f0101168:	53                   	push   %ebx
f0101169:	83 ec 2c             	sub    $0x2c,%esp
f010116c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010116f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101172:	eb 03                	jmp    f0101177 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101174:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101177:	8b 45 10             	mov    0x10(%ebp),%eax
f010117a:	8d 70 01             	lea    0x1(%eax),%esi
f010117d:	0f b6 00             	movzbl (%eax),%eax
f0101180:	83 f8 25             	cmp    $0x25,%eax
f0101183:	74 27                	je     f01011ac <vprintfmt+0x49>
			if (ch == '\0')
f0101185:	85 c0                	test   %eax,%eax
f0101187:	75 0d                	jne    f0101196 <vprintfmt+0x33>
f0101189:	e9 9b 04 00 00       	jmp    f0101629 <vprintfmt+0x4c6>
f010118e:	85 c0                	test   %eax,%eax
f0101190:	0f 84 93 04 00 00    	je     f0101629 <vprintfmt+0x4c6>
				return;
			putch(ch, putdat);
f0101196:	83 ec 08             	sub    $0x8,%esp
f0101199:	53                   	push   %ebx
f010119a:	50                   	push   %eax
f010119b:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010119d:	83 c6 01             	add    $0x1,%esi
f01011a0:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f01011a4:	83 c4 10             	add    $0x10,%esp
f01011a7:	83 f8 25             	cmp    $0x25,%eax
f01011aa:	75 e2                	jne    f010118e <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01011ac:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011b1:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f01011b5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01011bc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01011c3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01011ca:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f01011d1:	eb 08                	jmp    f01011db <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011d3:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
f01011d6:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011db:	8d 46 01             	lea    0x1(%esi),%eax
f01011de:	89 45 10             	mov    %eax,0x10(%ebp)
f01011e1:	0f b6 06             	movzbl (%esi),%eax
f01011e4:	0f b6 d0             	movzbl %al,%edx
f01011e7:	83 e8 23             	sub    $0x23,%eax
f01011ea:	3c 55                	cmp    $0x55,%al
f01011ec:	0f 87 f8 03 00 00    	ja     f01015ea <vprintfmt+0x487>
f01011f2:	0f b6 c0             	movzbl %al,%eax
f01011f5:	ff 24 85 e0 25 10 f0 	jmp    *-0xfefda20(,%eax,4)
f01011fc:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f01011ff:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f0101203:	eb d6                	jmp    f01011db <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101205:	8d 42 d0             	lea    -0x30(%edx),%eax
f0101208:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f010120b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f010120f:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101212:	83 fa 09             	cmp    $0x9,%edx
f0101215:	77 6b                	ja     f0101282 <vprintfmt+0x11f>
f0101217:	8b 75 10             	mov    0x10(%ebp),%esi
f010121a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010121d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101220:	eb 09                	jmp    f010122b <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101222:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101225:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f0101229:	eb b0                	jmp    f01011db <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010122b:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f010122e:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101231:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0101235:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0101238:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010123b:	83 f9 09             	cmp    $0x9,%ecx
f010123e:	76 eb                	jbe    f010122b <vprintfmt+0xc8>
f0101240:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101243:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101246:	eb 3d                	jmp    f0101285 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101248:	8b 45 14             	mov    0x14(%ebp),%eax
f010124b:	8d 50 04             	lea    0x4(%eax),%edx
f010124e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101251:	8b 00                	mov    (%eax),%eax
f0101253:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101256:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101259:	eb 2a                	jmp    f0101285 <vprintfmt+0x122>
f010125b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010125e:	85 c0                	test   %eax,%eax
f0101260:	ba 00 00 00 00       	mov    $0x0,%edx
f0101265:	0f 49 d0             	cmovns %eax,%edx
f0101268:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010126b:	8b 75 10             	mov    0x10(%ebp),%esi
f010126e:	e9 68 ff ff ff       	jmp    f01011db <vprintfmt+0x78>
f0101273:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101276:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010127d:	e9 59 ff ff ff       	jmp    f01011db <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101282:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0101285:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101289:	0f 89 4c ff ff ff    	jns    f01011db <vprintfmt+0x78>
				width = precision, precision = -1;
f010128f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101292:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101295:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010129c:	e9 3a ff ff ff       	jmp    f01011db <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01012a1:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012a5:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01012a8:	e9 2e ff ff ff       	jmp    f01011db <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01012ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b0:	8d 50 04             	lea    0x4(%eax),%edx
f01012b3:	89 55 14             	mov    %edx,0x14(%ebp)
f01012b6:	83 ec 08             	sub    $0x8,%esp
f01012b9:	53                   	push   %ebx
f01012ba:	ff 30                	pushl  (%eax)
f01012bc:	ff d7                	call   *%edi
			break;
f01012be:	83 c4 10             	add    $0x10,%esp
f01012c1:	e9 b1 fe ff ff       	jmp    f0101177 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01012c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c9:	8d 50 04             	lea    0x4(%eax),%edx
f01012cc:	89 55 14             	mov    %edx,0x14(%ebp)
f01012cf:	8b 00                	mov    (%eax),%eax
f01012d1:	99                   	cltd   
f01012d2:	31 d0                	xor    %edx,%eax
f01012d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01012d6:	83 f8 06             	cmp    $0x6,%eax
f01012d9:	7f 0b                	jg     f01012e6 <vprintfmt+0x183>
f01012db:	8b 14 85 38 27 10 f0 	mov    -0xfefd8c8(,%eax,4),%edx
f01012e2:	85 d2                	test   %edx,%edx
f01012e4:	75 15                	jne    f01012fb <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
f01012e6:	50                   	push   %eax
f01012e7:	68 ed 24 10 f0       	push   $0xf01024ed
f01012ec:	53                   	push   %ebx
f01012ed:	57                   	push   %edi
f01012ee:	e8 53 fe ff ff       	call   f0101146 <printfmt>
f01012f3:	83 c4 10             	add    $0x10,%esp
f01012f6:	e9 7c fe ff ff       	jmp    f0101177 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f01012fb:	52                   	push   %edx
f01012fc:	68 f6 24 10 f0       	push   $0xf01024f6
f0101301:	53                   	push   %ebx
f0101302:	57                   	push   %edi
f0101303:	e8 3e fe ff ff       	call   f0101146 <printfmt>
f0101308:	83 c4 10             	add    $0x10,%esp
f010130b:	e9 67 fe ff ff       	jmp    f0101177 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101310:	8b 45 14             	mov    0x14(%ebp),%eax
f0101313:	8d 50 04             	lea    0x4(%eax),%edx
f0101316:	89 55 14             	mov    %edx,0x14(%ebp)
f0101319:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f010131b:	85 c0                	test   %eax,%eax
f010131d:	b9 e6 24 10 f0       	mov    $0xf01024e6,%ecx
f0101322:	0f 45 c8             	cmovne %eax,%ecx
f0101325:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0101328:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010132c:	7e 06                	jle    f0101334 <vprintfmt+0x1d1>
f010132e:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0101332:	75 19                	jne    f010134d <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101334:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101337:	8d 70 01             	lea    0x1(%eax),%esi
f010133a:	0f b6 00             	movzbl (%eax),%eax
f010133d:	0f be d0             	movsbl %al,%edx
f0101340:	85 d2                	test   %edx,%edx
f0101342:	0f 85 9f 00 00 00    	jne    f01013e7 <vprintfmt+0x284>
f0101348:	e9 8c 00 00 00       	jmp    f01013d9 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010134d:	83 ec 08             	sub    $0x8,%esp
f0101350:	ff 75 d0             	pushl  -0x30(%ebp)
f0101353:	ff 75 cc             	pushl  -0x34(%ebp)
f0101356:	e8 39 04 00 00       	call   f0101794 <strnlen>
f010135b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f010135e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101361:	83 c4 10             	add    $0x10,%esp
f0101364:	85 c9                	test   %ecx,%ecx
f0101366:	0f 8e a4 02 00 00    	jle    f0101610 <vprintfmt+0x4ad>
					putch(padc, putdat);
f010136c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0101370:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101373:	89 cb                	mov    %ecx,%ebx
f0101375:	83 ec 08             	sub    $0x8,%esp
f0101378:	ff 75 0c             	pushl  0xc(%ebp)
f010137b:	56                   	push   %esi
f010137c:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010137e:	83 c4 10             	add    $0x10,%esp
f0101381:	83 eb 01             	sub    $0x1,%ebx
f0101384:	75 ef                	jne    f0101375 <vprintfmt+0x212>
f0101386:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101389:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010138c:	e9 7f 02 00 00       	jmp    f0101610 <vprintfmt+0x4ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101391:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101395:	74 1b                	je     f01013b2 <vprintfmt+0x24f>
f0101397:	0f be c0             	movsbl %al,%eax
f010139a:	83 e8 20             	sub    $0x20,%eax
f010139d:	83 f8 5e             	cmp    $0x5e,%eax
f01013a0:	76 10                	jbe    f01013b2 <vprintfmt+0x24f>
					putch('?', putdat);
f01013a2:	83 ec 08             	sub    $0x8,%esp
f01013a5:	ff 75 0c             	pushl  0xc(%ebp)
f01013a8:	6a 3f                	push   $0x3f
f01013aa:	ff 55 08             	call   *0x8(%ebp)
f01013ad:	83 c4 10             	add    $0x10,%esp
f01013b0:	eb 0d                	jmp    f01013bf <vprintfmt+0x25c>
				else
					putch(ch, putdat);
f01013b2:	83 ec 08             	sub    $0x8,%esp
f01013b5:	ff 75 0c             	pushl  0xc(%ebp)
f01013b8:	52                   	push   %edx
f01013b9:	ff 55 08             	call   *0x8(%ebp)
f01013bc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01013bf:	83 ef 01             	sub    $0x1,%edi
f01013c2:	83 c6 01             	add    $0x1,%esi
f01013c5:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f01013c9:	0f be d0             	movsbl %al,%edx
f01013cc:	85 d2                	test   %edx,%edx
f01013ce:	75 31                	jne    f0101401 <vprintfmt+0x29e>
f01013d0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01013d3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01013d9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01013dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01013e0:	7f 33                	jg     f0101415 <vprintfmt+0x2b2>
f01013e2:	e9 90 fd ff ff       	jmp    f0101177 <vprintfmt+0x14>
f01013e7:	89 7d 08             	mov    %edi,0x8(%ebp)
f01013ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01013ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01013f0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01013f3:	eb 0c                	jmp    f0101401 <vprintfmt+0x29e>
f01013f5:	89 7d 08             	mov    %edi,0x8(%ebp)
f01013f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01013fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01013fe:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101401:	85 db                	test   %ebx,%ebx
f0101403:	78 8c                	js     f0101391 <vprintfmt+0x22e>
f0101405:	83 eb 01             	sub    $0x1,%ebx
f0101408:	79 87                	jns    f0101391 <vprintfmt+0x22e>
f010140a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010140d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101413:	eb c4                	jmp    f01013d9 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101415:	83 ec 08             	sub    $0x8,%esp
f0101418:	53                   	push   %ebx
f0101419:	6a 20                	push   $0x20
f010141b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010141d:	83 c4 10             	add    $0x10,%esp
f0101420:	83 ee 01             	sub    $0x1,%esi
f0101423:	75 f0                	jne    f0101415 <vprintfmt+0x2b2>
f0101425:	e9 4d fd ff ff       	jmp    f0101177 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010142a:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f010142e:	7e 16                	jle    f0101446 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
f0101430:	8b 45 14             	mov    0x14(%ebp),%eax
f0101433:	8d 50 08             	lea    0x8(%eax),%edx
f0101436:	89 55 14             	mov    %edx,0x14(%ebp)
f0101439:	8b 50 04             	mov    0x4(%eax),%edx
f010143c:	8b 00                	mov    (%eax),%eax
f010143e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101441:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101444:	eb 34                	jmp    f010147a <vprintfmt+0x317>
	else if (lflag)
f0101446:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f010144a:	74 18                	je     f0101464 <vprintfmt+0x301>
		return va_arg(*ap, long);
f010144c:	8b 45 14             	mov    0x14(%ebp),%eax
f010144f:	8d 50 04             	lea    0x4(%eax),%edx
f0101452:	89 55 14             	mov    %edx,0x14(%ebp)
f0101455:	8b 30                	mov    (%eax),%esi
f0101457:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010145a:	89 f0                	mov    %esi,%eax
f010145c:	c1 f8 1f             	sar    $0x1f,%eax
f010145f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101462:	eb 16                	jmp    f010147a <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
f0101464:	8b 45 14             	mov    0x14(%ebp),%eax
f0101467:	8d 50 04             	lea    0x4(%eax),%edx
f010146a:	89 55 14             	mov    %edx,0x14(%ebp)
f010146d:	8b 30                	mov    (%eax),%esi
f010146f:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101472:	89 f0                	mov    %esi,%eax
f0101474:	c1 f8 1f             	sar    $0x1f,%eax
f0101477:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010147a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010147d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101480:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101483:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0101486:	85 d2                	test   %edx,%edx
f0101488:	79 28                	jns    f01014b2 <vprintfmt+0x34f>
				putch('-', putdat);
f010148a:	83 ec 08             	sub    $0x8,%esp
f010148d:	53                   	push   %ebx
f010148e:	6a 2d                	push   $0x2d
f0101490:	ff d7                	call   *%edi
				num = -(long long) num;
f0101492:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101495:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101498:	f7 d8                	neg    %eax
f010149a:	83 d2 00             	adc    $0x0,%edx
f010149d:	f7 da                	neg    %edx
f010149f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01014a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01014a5:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
f01014a8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01014ad:	e9 b2 00 00 00       	jmp    f0101564 <vprintfmt+0x401>
f01014b2:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
f01014b7:	85 c9                	test   %ecx,%ecx
f01014b9:	0f 84 a5 00 00 00    	je     f0101564 <vprintfmt+0x401>
				putch('+', putdat);
f01014bf:	83 ec 08             	sub    $0x8,%esp
f01014c2:	53                   	push   %ebx
f01014c3:	6a 2b                	push   $0x2b
f01014c5:	ff d7                	call   *%edi
f01014c7:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
f01014ca:	b8 0a 00 00 00       	mov    $0xa,%eax
f01014cf:	e9 90 00 00 00       	jmp    f0101564 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
f01014d4:	85 c9                	test   %ecx,%ecx
f01014d6:	74 0b                	je     f01014e3 <vprintfmt+0x380>
				putch('+', putdat);
f01014d8:	83 ec 08             	sub    $0x8,%esp
f01014db:	53                   	push   %ebx
f01014dc:	6a 2b                	push   $0x2b
f01014de:	ff d7                	call   *%edi
f01014e0:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
f01014e3:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01014e6:	8d 45 14             	lea    0x14(%ebp),%eax
f01014e9:	e8 01 fc ff ff       	call   f01010ef <getuint>
f01014ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01014f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f01014f4:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01014f9:	eb 69                	jmp    f0101564 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
f01014fb:	83 ec 08             	sub    $0x8,%esp
f01014fe:	53                   	push   %ebx
f01014ff:	6a 30                	push   $0x30
f0101501:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f0101503:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101506:	8d 45 14             	lea    0x14(%ebp),%eax
f0101509:	e8 e1 fb ff ff       	call   f01010ef <getuint>
f010150e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101511:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f0101514:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0101517:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f010151c:	eb 46                	jmp    f0101564 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
f010151e:	83 ec 08             	sub    $0x8,%esp
f0101521:	53                   	push   %ebx
f0101522:	6a 30                	push   $0x30
f0101524:	ff d7                	call   *%edi
			putch('x', putdat);
f0101526:	83 c4 08             	add    $0x8,%esp
f0101529:	53                   	push   %ebx
f010152a:	6a 78                	push   $0x78
f010152c:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010152e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101531:	8d 50 04             	lea    0x4(%eax),%edx
f0101534:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101537:	8b 00                	mov    (%eax),%eax
f0101539:	ba 00 00 00 00       	mov    $0x0,%edx
f010153e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101541:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101544:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101547:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010154c:	eb 16                	jmp    f0101564 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010154e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101551:	8d 45 14             	lea    0x14(%ebp),%eax
f0101554:	e8 96 fb ff ff       	call   f01010ef <getuint>
f0101559:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010155c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f010155f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101564:	83 ec 0c             	sub    $0xc,%esp
f0101567:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f010156b:	56                   	push   %esi
f010156c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010156f:	50                   	push   %eax
f0101570:	ff 75 dc             	pushl  -0x24(%ebp)
f0101573:	ff 75 d8             	pushl  -0x28(%ebp)
f0101576:	89 da                	mov    %ebx,%edx
f0101578:	89 f8                	mov    %edi,%eax
f010157a:	e8 55 f9 ff ff       	call   f0100ed4 <printnum>
			break;
f010157f:	83 c4 20             	add    $0x20,%esp
f0101582:	e9 f0 fb ff ff       	jmp    f0101177 <vprintfmt+0x14>
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
						// cprintf("n: %d\n", *(char *)putdat);
						char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
f0101587:	8b 45 14             	mov    0x14(%ebp),%eax
f010158a:	8d 50 04             	lea    0x4(%eax),%edx
f010158d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101590:	8b 30                	mov    (%eax),%esi
						if (!tmp) {
f0101592:	85 f6                	test   %esi,%esi
f0101594:	75 1a                	jne    f01015b0 <vprintfmt+0x44d>
							cprintf("%s", null_error);
f0101596:	83 ec 08             	sub    $0x8,%esp
f0101599:	68 64 25 10 f0       	push   $0xf0102564
f010159e:	68 f6 24 10 f0       	push   $0xf01024f6
f01015a3:	e8 9a f5 ff ff       	call   f0100b42 <cprintf>
f01015a8:	83 c4 10             	add    $0x10,%esp
f01015ab:	e9 c7 fb ff ff       	jmp    f0101177 <vprintfmt+0x14>
						} else if ((*(char *)putdat) & 0x80) {
f01015b0:	0f b6 03             	movzbl (%ebx),%eax
f01015b3:	84 c0                	test   %al,%al
f01015b5:	79 1d                	jns    f01015d4 <vprintfmt+0x471>
							cprintf("%s", overflow_error);
f01015b7:	83 ec 08             	sub    $0x8,%esp
f01015ba:	68 9c 25 10 f0       	push   $0xf010259c
f01015bf:	68 f6 24 10 f0       	push   $0xf01024f6
f01015c4:	e8 79 f5 ff ff       	call   f0100b42 <cprintf>
							*tmp = 0xff;	// due to the grade.sh, this should return -1
f01015c9:	c6 06 ff             	movb   $0xff,(%esi)
f01015cc:	83 c4 10             	add    $0x10,%esp
f01015cf:	e9 a3 fb ff ff       	jmp    f0101177 <vprintfmt+0x14>
						} else {
							*tmp = *(char *)putdat;
f01015d4:	88 06                	mov    %al,(%esi)
f01015d6:	e9 9c fb ff ff       	jmp    f0101177 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01015db:	83 ec 08             	sub    $0x8,%esp
f01015de:	53                   	push   %ebx
f01015df:	52                   	push   %edx
f01015e0:	ff d7                	call   *%edi
			break;
f01015e2:	83 c4 10             	add    $0x10,%esp
f01015e5:	e9 8d fb ff ff       	jmp    f0101177 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01015ea:	83 ec 08             	sub    $0x8,%esp
f01015ed:	53                   	push   %ebx
f01015ee:	6a 25                	push   $0x25
f01015f0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01015f2:	83 c4 10             	add    $0x10,%esp
f01015f5:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01015f9:	0f 84 75 fb ff ff    	je     f0101174 <vprintfmt+0x11>
f01015ff:	83 ee 01             	sub    $0x1,%esi
f0101602:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101606:	75 f7                	jne    f01015ff <vprintfmt+0x49c>
f0101608:	89 75 10             	mov    %esi,0x10(%ebp)
f010160b:	e9 67 fb ff ff       	jmp    f0101177 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101610:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101613:	8d 70 01             	lea    0x1(%eax),%esi
f0101616:	0f b6 00             	movzbl (%eax),%eax
f0101619:	0f be d0             	movsbl %al,%edx
f010161c:	85 d2                	test   %edx,%edx
f010161e:	0f 85 d1 fd ff ff    	jne    f01013f5 <vprintfmt+0x292>
f0101624:	e9 4e fb ff ff       	jmp    f0101177 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0101629:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010162c:	5b                   	pop    %ebx
f010162d:	5e                   	pop    %esi
f010162e:	5f                   	pop    %edi
f010162f:	5d                   	pop    %ebp
f0101630:	c3                   	ret    

f0101631 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101631:	55                   	push   %ebp
f0101632:	89 e5                	mov    %esp,%ebp
f0101634:	83 ec 18             	sub    $0x18,%esp
f0101637:	8b 45 08             	mov    0x8(%ebp),%eax
f010163a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010163d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101640:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101644:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101647:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010164e:	85 c0                	test   %eax,%eax
f0101650:	74 26                	je     f0101678 <vsnprintf+0x47>
f0101652:	85 d2                	test   %edx,%edx
f0101654:	7e 22                	jle    f0101678 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101656:	ff 75 14             	pushl  0x14(%ebp)
f0101659:	ff 75 10             	pushl  0x10(%ebp)
f010165c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010165f:	50                   	push   %eax
f0101660:	68 29 11 10 f0       	push   $0xf0101129
f0101665:	e8 f9 fa ff ff       	call   f0101163 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010166a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010166d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101670:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101673:	83 c4 10             	add    $0x10,%esp
f0101676:	eb 05                	jmp    f010167d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101678:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010167d:	c9                   	leave  
f010167e:	c3                   	ret    

f010167f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010167f:	55                   	push   %ebp
f0101680:	89 e5                	mov    %esp,%ebp
f0101682:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101685:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101688:	50                   	push   %eax
f0101689:	ff 75 10             	pushl  0x10(%ebp)
f010168c:	ff 75 0c             	pushl  0xc(%ebp)
f010168f:	ff 75 08             	pushl  0x8(%ebp)
f0101692:	e8 9a ff ff ff       	call   f0101631 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101697:	c9                   	leave  
f0101698:	c3                   	ret    

f0101699 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101699:	55                   	push   %ebp
f010169a:	89 e5                	mov    %esp,%ebp
f010169c:	57                   	push   %edi
f010169d:	56                   	push   %esi
f010169e:	53                   	push   %ebx
f010169f:	83 ec 0c             	sub    $0xc,%esp
f01016a2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01016a5:	85 c0                	test   %eax,%eax
f01016a7:	74 11                	je     f01016ba <readline+0x21>
		cprintf("%s", prompt);
f01016a9:	83 ec 08             	sub    $0x8,%esp
f01016ac:	50                   	push   %eax
f01016ad:	68 f6 24 10 f0       	push   $0xf01024f6
f01016b2:	e8 8b f4 ff ff       	call   f0100b42 <cprintf>
f01016b7:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01016ba:	83 ec 0c             	sub    $0xc,%esp
f01016bd:	6a 00                	push   $0x0
f01016bf:	e8 77 f0 ff ff       	call   f010073b <iscons>
f01016c4:	89 c7                	mov    %eax,%edi
f01016c6:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01016c9:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01016ce:	e8 57 f0 ff ff       	call   f010072a <getchar>
f01016d3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01016d5:	85 c0                	test   %eax,%eax
f01016d7:	79 18                	jns    f01016f1 <readline+0x58>
			cprintf("read error: %e\n", c);
f01016d9:	83 ec 08             	sub    $0x8,%esp
f01016dc:	50                   	push   %eax
f01016dd:	68 54 27 10 f0       	push   $0xf0102754
f01016e2:	e8 5b f4 ff ff       	call   f0100b42 <cprintf>
			return NULL;
f01016e7:	83 c4 10             	add    $0x10,%esp
f01016ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01016ef:	eb 79                	jmp    f010176a <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01016f1:	83 f8 08             	cmp    $0x8,%eax
f01016f4:	0f 94 c2             	sete   %dl
f01016f7:	83 f8 7f             	cmp    $0x7f,%eax
f01016fa:	0f 94 c0             	sete   %al
f01016fd:	08 c2                	or     %al,%dl
f01016ff:	74 1a                	je     f010171b <readline+0x82>
f0101701:	85 f6                	test   %esi,%esi
f0101703:	7e 16                	jle    f010171b <readline+0x82>
			if (echoing)
f0101705:	85 ff                	test   %edi,%edi
f0101707:	74 0d                	je     f0101716 <readline+0x7d>
				cputchar('\b');
f0101709:	83 ec 0c             	sub    $0xc,%esp
f010170c:	6a 08                	push   $0x8
f010170e:	e8 07 f0 ff ff       	call   f010071a <cputchar>
f0101713:	83 c4 10             	add    $0x10,%esp
			i--;
f0101716:	83 ee 01             	sub    $0x1,%esi
f0101719:	eb b3                	jmp    f01016ce <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010171b:	83 fb 1f             	cmp    $0x1f,%ebx
f010171e:	7e 23                	jle    f0101743 <readline+0xaa>
f0101720:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101726:	7f 1b                	jg     f0101743 <readline+0xaa>
			if (echoing)
f0101728:	85 ff                	test   %edi,%edi
f010172a:	74 0c                	je     f0101738 <readline+0x9f>
				cputchar(c);
f010172c:	83 ec 0c             	sub    $0xc,%esp
f010172f:	53                   	push   %ebx
f0101730:	e8 e5 ef ff ff       	call   f010071a <cputchar>
f0101735:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101738:	88 9e 60 25 11 f0    	mov    %bl,-0xfeedaa0(%esi)
f010173e:	8d 76 01             	lea    0x1(%esi),%esi
f0101741:	eb 8b                	jmp    f01016ce <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101743:	83 fb 0a             	cmp    $0xa,%ebx
f0101746:	74 05                	je     f010174d <readline+0xb4>
f0101748:	83 fb 0d             	cmp    $0xd,%ebx
f010174b:	75 81                	jne    f01016ce <readline+0x35>
			if (echoing)
f010174d:	85 ff                	test   %edi,%edi
f010174f:	74 0d                	je     f010175e <readline+0xc5>
				cputchar('\n');
f0101751:	83 ec 0c             	sub    $0xc,%esp
f0101754:	6a 0a                	push   $0xa
f0101756:	e8 bf ef ff ff       	call   f010071a <cputchar>
f010175b:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010175e:	c6 86 60 25 11 f0 00 	movb   $0x0,-0xfeedaa0(%esi)
			return buf;
f0101765:	b8 60 25 11 f0       	mov    $0xf0112560,%eax
		}
	}
}
f010176a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010176d:	5b                   	pop    %ebx
f010176e:	5e                   	pop    %esi
f010176f:	5f                   	pop    %edi
f0101770:	5d                   	pop    %ebp
f0101771:	c3                   	ret    

f0101772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101772:	55                   	push   %ebp
f0101773:	89 e5                	mov    %esp,%ebp
f0101775:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101778:	80 3a 00             	cmpb   $0x0,(%edx)
f010177b:	74 10                	je     f010178d <strlen+0x1b>
f010177d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101782:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101785:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101789:	75 f7                	jne    f0101782 <strlen+0x10>
f010178b:	eb 05                	jmp    f0101792 <strlen+0x20>
f010178d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101792:	5d                   	pop    %ebp
f0101793:	c3                   	ret    

f0101794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101794:	55                   	push   %ebp
f0101795:	89 e5                	mov    %esp,%ebp
f0101797:	53                   	push   %ebx
f0101798:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010179b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010179e:	85 c9                	test   %ecx,%ecx
f01017a0:	74 1c                	je     f01017be <strnlen+0x2a>
f01017a2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01017a5:	74 1e                	je     f01017c5 <strnlen+0x31>
f01017a7:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01017ac:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01017ae:	39 ca                	cmp    %ecx,%edx
f01017b0:	74 18                	je     f01017ca <strnlen+0x36>
f01017b2:	83 c2 01             	add    $0x1,%edx
f01017b5:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01017ba:	75 f0                	jne    f01017ac <strnlen+0x18>
f01017bc:	eb 0c                	jmp    f01017ca <strnlen+0x36>
f01017be:	b8 00 00 00 00       	mov    $0x0,%eax
f01017c3:	eb 05                	jmp    f01017ca <strnlen+0x36>
f01017c5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01017ca:	5b                   	pop    %ebx
f01017cb:	5d                   	pop    %ebp
f01017cc:	c3                   	ret    

f01017cd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01017cd:	55                   	push   %ebp
f01017ce:	89 e5                	mov    %esp,%ebp
f01017d0:	53                   	push   %ebx
f01017d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01017d7:	89 c2                	mov    %eax,%edx
f01017d9:	83 c2 01             	add    $0x1,%edx
f01017dc:	83 c1 01             	add    $0x1,%ecx
f01017df:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01017e3:	88 5a ff             	mov    %bl,-0x1(%edx)
f01017e6:	84 db                	test   %bl,%bl
f01017e8:	75 ef                	jne    f01017d9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01017ea:	5b                   	pop    %ebx
f01017eb:	5d                   	pop    %ebp
f01017ec:	c3                   	ret    

f01017ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01017ed:	55                   	push   %ebp
f01017ee:	89 e5                	mov    %esp,%ebp
f01017f0:	56                   	push   %esi
f01017f1:	53                   	push   %ebx
f01017f2:	8b 75 08             	mov    0x8(%ebp),%esi
f01017f5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01017fb:	85 db                	test   %ebx,%ebx
f01017fd:	74 17                	je     f0101816 <strncpy+0x29>
f01017ff:	01 f3                	add    %esi,%ebx
f0101801:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f0101803:	83 c1 01             	add    $0x1,%ecx
f0101806:	0f b6 02             	movzbl (%edx),%eax
f0101809:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010180c:	80 3a 01             	cmpb   $0x1,(%edx)
f010180f:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101812:	39 cb                	cmp    %ecx,%ebx
f0101814:	75 ed                	jne    f0101803 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101816:	89 f0                	mov    %esi,%eax
f0101818:	5b                   	pop    %ebx
f0101819:	5e                   	pop    %esi
f010181a:	5d                   	pop    %ebp
f010181b:	c3                   	ret    

f010181c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010181c:	55                   	push   %ebp
f010181d:	89 e5                	mov    %esp,%ebp
f010181f:	56                   	push   %esi
f0101820:	53                   	push   %ebx
f0101821:	8b 75 08             	mov    0x8(%ebp),%esi
f0101824:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101827:	8b 55 10             	mov    0x10(%ebp),%edx
f010182a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010182c:	85 d2                	test   %edx,%edx
f010182e:	74 35                	je     f0101865 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f0101830:	89 d0                	mov    %edx,%eax
f0101832:	83 e8 01             	sub    $0x1,%eax
f0101835:	74 25                	je     f010185c <strlcpy+0x40>
f0101837:	0f b6 0b             	movzbl (%ebx),%ecx
f010183a:	84 c9                	test   %cl,%cl
f010183c:	74 22                	je     f0101860 <strlcpy+0x44>
f010183e:	8d 53 01             	lea    0x1(%ebx),%edx
f0101841:	01 c3                	add    %eax,%ebx
f0101843:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f0101845:	83 c0 01             	add    $0x1,%eax
f0101848:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010184b:	39 da                	cmp    %ebx,%edx
f010184d:	74 13                	je     f0101862 <strlcpy+0x46>
f010184f:	83 c2 01             	add    $0x1,%edx
f0101852:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f0101856:	84 c9                	test   %cl,%cl
f0101858:	75 eb                	jne    f0101845 <strlcpy+0x29>
f010185a:	eb 06                	jmp    f0101862 <strlcpy+0x46>
f010185c:	89 f0                	mov    %esi,%eax
f010185e:	eb 02                	jmp    f0101862 <strlcpy+0x46>
f0101860:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101862:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101865:	29 f0                	sub    %esi,%eax
}
f0101867:	5b                   	pop    %ebx
f0101868:	5e                   	pop    %esi
f0101869:	5d                   	pop    %ebp
f010186a:	c3                   	ret    

f010186b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010186b:	55                   	push   %ebp
f010186c:	89 e5                	mov    %esp,%ebp
f010186e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101871:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101874:	0f b6 01             	movzbl (%ecx),%eax
f0101877:	84 c0                	test   %al,%al
f0101879:	74 15                	je     f0101890 <strcmp+0x25>
f010187b:	3a 02                	cmp    (%edx),%al
f010187d:	75 11                	jne    f0101890 <strcmp+0x25>
		p++, q++;
f010187f:	83 c1 01             	add    $0x1,%ecx
f0101882:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101885:	0f b6 01             	movzbl (%ecx),%eax
f0101888:	84 c0                	test   %al,%al
f010188a:	74 04                	je     f0101890 <strcmp+0x25>
f010188c:	3a 02                	cmp    (%edx),%al
f010188e:	74 ef                	je     f010187f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101890:	0f b6 c0             	movzbl %al,%eax
f0101893:	0f b6 12             	movzbl (%edx),%edx
f0101896:	29 d0                	sub    %edx,%eax
}
f0101898:	5d                   	pop    %ebp
f0101899:	c3                   	ret    

f010189a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010189a:	55                   	push   %ebp
f010189b:	89 e5                	mov    %esp,%ebp
f010189d:	56                   	push   %esi
f010189e:	53                   	push   %ebx
f010189f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01018a2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018a5:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f01018a8:	85 f6                	test   %esi,%esi
f01018aa:	74 29                	je     f01018d5 <strncmp+0x3b>
f01018ac:	0f b6 03             	movzbl (%ebx),%eax
f01018af:	84 c0                	test   %al,%al
f01018b1:	74 30                	je     f01018e3 <strncmp+0x49>
f01018b3:	3a 02                	cmp    (%edx),%al
f01018b5:	75 2c                	jne    f01018e3 <strncmp+0x49>
f01018b7:	8d 43 01             	lea    0x1(%ebx),%eax
f01018ba:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f01018bc:	89 c3                	mov    %eax,%ebx
f01018be:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01018c1:	39 c6                	cmp    %eax,%esi
f01018c3:	74 17                	je     f01018dc <strncmp+0x42>
f01018c5:	0f b6 08             	movzbl (%eax),%ecx
f01018c8:	84 c9                	test   %cl,%cl
f01018ca:	74 17                	je     f01018e3 <strncmp+0x49>
f01018cc:	83 c0 01             	add    $0x1,%eax
f01018cf:	3a 0a                	cmp    (%edx),%cl
f01018d1:	74 e9                	je     f01018bc <strncmp+0x22>
f01018d3:	eb 0e                	jmp    f01018e3 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01018d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01018da:	eb 0f                	jmp    f01018eb <strncmp+0x51>
f01018dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01018e1:	eb 08                	jmp    f01018eb <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01018e3:	0f b6 03             	movzbl (%ebx),%eax
f01018e6:	0f b6 12             	movzbl (%edx),%edx
f01018e9:	29 d0                	sub    %edx,%eax
}
f01018eb:	5b                   	pop    %ebx
f01018ec:	5e                   	pop    %esi
f01018ed:	5d                   	pop    %ebp
f01018ee:	c3                   	ret    

f01018ef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01018ef:	55                   	push   %ebp
f01018f0:	89 e5                	mov    %esp,%ebp
f01018f2:	53                   	push   %ebx
f01018f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01018f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f01018f9:	0f b6 10             	movzbl (%eax),%edx
f01018fc:	84 d2                	test   %dl,%dl
f01018fe:	74 1d                	je     f010191d <strchr+0x2e>
f0101900:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f0101902:	38 d3                	cmp    %dl,%bl
f0101904:	75 06                	jne    f010190c <strchr+0x1d>
f0101906:	eb 1a                	jmp    f0101922 <strchr+0x33>
f0101908:	38 ca                	cmp    %cl,%dl
f010190a:	74 16                	je     f0101922 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010190c:	83 c0 01             	add    $0x1,%eax
f010190f:	0f b6 10             	movzbl (%eax),%edx
f0101912:	84 d2                	test   %dl,%dl
f0101914:	75 f2                	jne    f0101908 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f0101916:	b8 00 00 00 00       	mov    $0x0,%eax
f010191b:	eb 05                	jmp    f0101922 <strchr+0x33>
f010191d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101922:	5b                   	pop    %ebx
f0101923:	5d                   	pop    %ebp
f0101924:	c3                   	ret    

f0101925 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101925:	55                   	push   %ebp
f0101926:	89 e5                	mov    %esp,%ebp
f0101928:	53                   	push   %ebx
f0101929:	8b 45 08             	mov    0x8(%ebp),%eax
f010192c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f010192f:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f0101932:	38 d3                	cmp    %dl,%bl
f0101934:	74 14                	je     f010194a <strfind+0x25>
f0101936:	89 d1                	mov    %edx,%ecx
f0101938:	84 db                	test   %bl,%bl
f010193a:	74 0e                	je     f010194a <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010193c:	83 c0 01             	add    $0x1,%eax
f010193f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101942:	38 ca                	cmp    %cl,%dl
f0101944:	74 04                	je     f010194a <strfind+0x25>
f0101946:	84 d2                	test   %dl,%dl
f0101948:	75 f2                	jne    f010193c <strfind+0x17>
			break;
	return (char *) s;
}
f010194a:	5b                   	pop    %ebx
f010194b:	5d                   	pop    %ebp
f010194c:	c3                   	ret    

f010194d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010194d:	55                   	push   %ebp
f010194e:	89 e5                	mov    %esp,%ebp
f0101950:	57                   	push   %edi
f0101951:	56                   	push   %esi
f0101952:	53                   	push   %ebx
f0101953:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101959:	85 c9                	test   %ecx,%ecx
f010195b:	74 36                	je     f0101993 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010195d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101963:	75 28                	jne    f010198d <memset+0x40>
f0101965:	f6 c1 03             	test   $0x3,%cl
f0101968:	75 23                	jne    f010198d <memset+0x40>
		c &= 0xFF;
f010196a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010196e:	89 d3                	mov    %edx,%ebx
f0101970:	c1 e3 08             	shl    $0x8,%ebx
f0101973:	89 d6                	mov    %edx,%esi
f0101975:	c1 e6 18             	shl    $0x18,%esi
f0101978:	89 d0                	mov    %edx,%eax
f010197a:	c1 e0 10             	shl    $0x10,%eax
f010197d:	09 f0                	or     %esi,%eax
f010197f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101981:	89 d8                	mov    %ebx,%eax
f0101983:	09 d0                	or     %edx,%eax
f0101985:	c1 e9 02             	shr    $0x2,%ecx
f0101988:	fc                   	cld    
f0101989:	f3 ab                	rep stos %eax,%es:(%edi)
f010198b:	eb 06                	jmp    f0101993 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010198d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101990:	fc                   	cld    
f0101991:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101993:	89 f8                	mov    %edi,%eax
f0101995:	5b                   	pop    %ebx
f0101996:	5e                   	pop    %esi
f0101997:	5f                   	pop    %edi
f0101998:	5d                   	pop    %ebp
f0101999:	c3                   	ret    

f010199a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010199a:	55                   	push   %ebp
f010199b:	89 e5                	mov    %esp,%ebp
f010199d:	57                   	push   %edi
f010199e:	56                   	push   %esi
f010199f:	8b 45 08             	mov    0x8(%ebp),%eax
f01019a2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01019a8:	39 c6                	cmp    %eax,%esi
f01019aa:	73 35                	jae    f01019e1 <memmove+0x47>
f01019ac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01019af:	39 d0                	cmp    %edx,%eax
f01019b1:	73 2e                	jae    f01019e1 <memmove+0x47>
		s += n;
		d += n;
f01019b3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01019b6:	89 d6                	mov    %edx,%esi
f01019b8:	09 fe                	or     %edi,%esi
f01019ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01019c0:	75 13                	jne    f01019d5 <memmove+0x3b>
f01019c2:	f6 c1 03             	test   $0x3,%cl
f01019c5:	75 0e                	jne    f01019d5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01019c7:	83 ef 04             	sub    $0x4,%edi
f01019ca:	8d 72 fc             	lea    -0x4(%edx),%esi
f01019cd:	c1 e9 02             	shr    $0x2,%ecx
f01019d0:	fd                   	std    
f01019d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01019d3:	eb 09                	jmp    f01019de <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01019d5:	83 ef 01             	sub    $0x1,%edi
f01019d8:	8d 72 ff             	lea    -0x1(%edx),%esi
f01019db:	fd                   	std    
f01019dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01019de:	fc                   	cld    
f01019df:	eb 1d                	jmp    f01019fe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01019e1:	89 f2                	mov    %esi,%edx
f01019e3:	09 c2                	or     %eax,%edx
f01019e5:	f6 c2 03             	test   $0x3,%dl
f01019e8:	75 0f                	jne    f01019f9 <memmove+0x5f>
f01019ea:	f6 c1 03             	test   $0x3,%cl
f01019ed:	75 0a                	jne    f01019f9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01019ef:	c1 e9 02             	shr    $0x2,%ecx
f01019f2:	89 c7                	mov    %eax,%edi
f01019f4:	fc                   	cld    
f01019f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01019f7:	eb 05                	jmp    f01019fe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01019f9:	89 c7                	mov    %eax,%edi
f01019fb:	fc                   	cld    
f01019fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01019fe:	5e                   	pop    %esi
f01019ff:	5f                   	pop    %edi
f0101a00:	5d                   	pop    %ebp
f0101a01:	c3                   	ret    

f0101a02 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101a02:	55                   	push   %ebp
f0101a03:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101a05:	ff 75 10             	pushl  0x10(%ebp)
f0101a08:	ff 75 0c             	pushl  0xc(%ebp)
f0101a0b:	ff 75 08             	pushl  0x8(%ebp)
f0101a0e:	e8 87 ff ff ff       	call   f010199a <memmove>
}
f0101a13:	c9                   	leave  
f0101a14:	c3                   	ret    

f0101a15 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101a15:	55                   	push   %ebp
f0101a16:	89 e5                	mov    %esp,%ebp
f0101a18:	57                   	push   %edi
f0101a19:	56                   	push   %esi
f0101a1a:	53                   	push   %ebx
f0101a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101a1e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a21:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101a24:	85 c0                	test   %eax,%eax
f0101a26:	74 39                	je     f0101a61 <memcmp+0x4c>
f0101a28:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f0101a2b:	0f b6 13             	movzbl (%ebx),%edx
f0101a2e:	0f b6 0e             	movzbl (%esi),%ecx
f0101a31:	38 ca                	cmp    %cl,%dl
f0101a33:	75 17                	jne    f0101a4c <memcmp+0x37>
f0101a35:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a3a:	eb 1a                	jmp    f0101a56 <memcmp+0x41>
f0101a3c:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f0101a41:	83 c0 01             	add    $0x1,%eax
f0101a44:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f0101a48:	38 ca                	cmp    %cl,%dl
f0101a4a:	74 0a                	je     f0101a56 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0101a4c:	0f b6 c2             	movzbl %dl,%eax
f0101a4f:	0f b6 c9             	movzbl %cl,%ecx
f0101a52:	29 c8                	sub    %ecx,%eax
f0101a54:	eb 10                	jmp    f0101a66 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101a56:	39 f8                	cmp    %edi,%eax
f0101a58:	75 e2                	jne    f0101a3c <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101a5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a5f:	eb 05                	jmp    f0101a66 <memcmp+0x51>
f0101a61:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a66:	5b                   	pop    %ebx
f0101a67:	5e                   	pop    %esi
f0101a68:	5f                   	pop    %edi
f0101a69:	5d                   	pop    %ebp
f0101a6a:	c3                   	ret    

f0101a6b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101a6b:	55                   	push   %ebp
f0101a6c:	89 e5                	mov    %esp,%ebp
f0101a6e:	53                   	push   %ebx
f0101a6f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f0101a72:	89 d0                	mov    %edx,%eax
f0101a74:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f0101a77:	39 c2                	cmp    %eax,%edx
f0101a79:	73 1d                	jae    f0101a98 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101a7b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f0101a7f:	0f b6 0a             	movzbl (%edx),%ecx
f0101a82:	39 d9                	cmp    %ebx,%ecx
f0101a84:	75 09                	jne    f0101a8f <memfind+0x24>
f0101a86:	eb 14                	jmp    f0101a9c <memfind+0x31>
f0101a88:	0f b6 0a             	movzbl (%edx),%ecx
f0101a8b:	39 d9                	cmp    %ebx,%ecx
f0101a8d:	74 11                	je     f0101aa0 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101a8f:	83 c2 01             	add    $0x1,%edx
f0101a92:	39 d0                	cmp    %edx,%eax
f0101a94:	75 f2                	jne    f0101a88 <memfind+0x1d>
f0101a96:	eb 0a                	jmp    f0101aa2 <memfind+0x37>
f0101a98:	89 d0                	mov    %edx,%eax
f0101a9a:	eb 06                	jmp    f0101aa2 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101a9c:	89 d0                	mov    %edx,%eax
f0101a9e:	eb 02                	jmp    f0101aa2 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101aa0:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101aa2:	5b                   	pop    %ebx
f0101aa3:	5d                   	pop    %ebp
f0101aa4:	c3                   	ret    

f0101aa5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101aa5:	55                   	push   %ebp
f0101aa6:	89 e5                	mov    %esp,%ebp
f0101aa8:	57                   	push   %edi
f0101aa9:	56                   	push   %esi
f0101aaa:	53                   	push   %ebx
f0101aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101ab1:	0f b6 01             	movzbl (%ecx),%eax
f0101ab4:	3c 20                	cmp    $0x20,%al
f0101ab6:	74 04                	je     f0101abc <strtol+0x17>
f0101ab8:	3c 09                	cmp    $0x9,%al
f0101aba:	75 0e                	jne    f0101aca <strtol+0x25>
		s++;
f0101abc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101abf:	0f b6 01             	movzbl (%ecx),%eax
f0101ac2:	3c 20                	cmp    $0x20,%al
f0101ac4:	74 f6                	je     f0101abc <strtol+0x17>
f0101ac6:	3c 09                	cmp    $0x9,%al
f0101ac8:	74 f2                	je     f0101abc <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101aca:	3c 2b                	cmp    $0x2b,%al
f0101acc:	75 0a                	jne    f0101ad8 <strtol+0x33>
		s++;
f0101ace:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101ad1:	bf 00 00 00 00       	mov    $0x0,%edi
f0101ad6:	eb 11                	jmp    f0101ae9 <strtol+0x44>
f0101ad8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101add:	3c 2d                	cmp    $0x2d,%al
f0101adf:	75 08                	jne    f0101ae9 <strtol+0x44>
		s++, neg = 1;
f0101ae1:	83 c1 01             	add    $0x1,%ecx
f0101ae4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101ae9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101aef:	75 15                	jne    f0101b06 <strtol+0x61>
f0101af1:	80 39 30             	cmpb   $0x30,(%ecx)
f0101af4:	75 10                	jne    f0101b06 <strtol+0x61>
f0101af6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101afa:	75 7c                	jne    f0101b78 <strtol+0xd3>
		s += 2, base = 16;
f0101afc:	83 c1 02             	add    $0x2,%ecx
f0101aff:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101b04:	eb 16                	jmp    f0101b1c <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0101b06:	85 db                	test   %ebx,%ebx
f0101b08:	75 12                	jne    f0101b1c <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101b0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101b0f:	80 39 30             	cmpb   $0x30,(%ecx)
f0101b12:	75 08                	jne    f0101b1c <strtol+0x77>
		s++, base = 8;
f0101b14:	83 c1 01             	add    $0x1,%ecx
f0101b17:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101b1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b21:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101b24:	0f b6 11             	movzbl (%ecx),%edx
f0101b27:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101b2a:	89 f3                	mov    %esi,%ebx
f0101b2c:	80 fb 09             	cmp    $0x9,%bl
f0101b2f:	77 08                	ja     f0101b39 <strtol+0x94>
			dig = *s - '0';
f0101b31:	0f be d2             	movsbl %dl,%edx
f0101b34:	83 ea 30             	sub    $0x30,%edx
f0101b37:	eb 22                	jmp    f0101b5b <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f0101b39:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101b3c:	89 f3                	mov    %esi,%ebx
f0101b3e:	80 fb 19             	cmp    $0x19,%bl
f0101b41:	77 08                	ja     f0101b4b <strtol+0xa6>
			dig = *s - 'a' + 10;
f0101b43:	0f be d2             	movsbl %dl,%edx
f0101b46:	83 ea 57             	sub    $0x57,%edx
f0101b49:	eb 10                	jmp    f0101b5b <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f0101b4b:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101b4e:	89 f3                	mov    %esi,%ebx
f0101b50:	80 fb 19             	cmp    $0x19,%bl
f0101b53:	77 16                	ja     f0101b6b <strtol+0xc6>
			dig = *s - 'A' + 10;
f0101b55:	0f be d2             	movsbl %dl,%edx
f0101b58:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101b5b:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101b5e:	7d 0b                	jge    f0101b6b <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0101b60:	83 c1 01             	add    $0x1,%ecx
f0101b63:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101b67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101b69:	eb b9                	jmp    f0101b24 <strtol+0x7f>

	if (endptr)
f0101b6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101b6f:	74 0d                	je     f0101b7e <strtol+0xd9>
		*endptr = (char *) s;
f0101b71:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b74:	89 0e                	mov    %ecx,(%esi)
f0101b76:	eb 06                	jmp    f0101b7e <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101b78:	85 db                	test   %ebx,%ebx
f0101b7a:	74 98                	je     f0101b14 <strtol+0x6f>
f0101b7c:	eb 9e                	jmp    f0101b1c <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101b7e:	89 c2                	mov    %eax,%edx
f0101b80:	f7 da                	neg    %edx
f0101b82:	85 ff                	test   %edi,%edi
f0101b84:	0f 45 c2             	cmovne %edx,%eax
}
f0101b87:	5b                   	pop    %ebx
f0101b88:	5e                   	pop    %esi
f0101b89:	5f                   	pop    %edi
f0101b8a:	5d                   	pop    %ebp
f0101b8b:	c3                   	ret    
f0101b8c:	66 90                	xchg   %ax,%ax
f0101b8e:	66 90                	xchg   %ax,%ax

f0101b90 <__udivdi3>:
f0101b90:	55                   	push   %ebp
f0101b91:	57                   	push   %edi
f0101b92:	56                   	push   %esi
f0101b93:	53                   	push   %ebx
f0101b94:	83 ec 1c             	sub    $0x1c,%esp
f0101b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0101b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0101b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101ba7:	85 f6                	test   %esi,%esi
f0101ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101bad:	89 ca                	mov    %ecx,%edx
f0101baf:	89 f8                	mov    %edi,%eax
f0101bb1:	75 3d                	jne    f0101bf0 <__udivdi3+0x60>
f0101bb3:	39 cf                	cmp    %ecx,%edi
f0101bb5:	0f 87 c5 00 00 00    	ja     f0101c80 <__udivdi3+0xf0>
f0101bbb:	85 ff                	test   %edi,%edi
f0101bbd:	89 fd                	mov    %edi,%ebp
f0101bbf:	75 0b                	jne    f0101bcc <__udivdi3+0x3c>
f0101bc1:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bc6:	31 d2                	xor    %edx,%edx
f0101bc8:	f7 f7                	div    %edi
f0101bca:	89 c5                	mov    %eax,%ebp
f0101bcc:	89 c8                	mov    %ecx,%eax
f0101bce:	31 d2                	xor    %edx,%edx
f0101bd0:	f7 f5                	div    %ebp
f0101bd2:	89 c1                	mov    %eax,%ecx
f0101bd4:	89 d8                	mov    %ebx,%eax
f0101bd6:	89 cf                	mov    %ecx,%edi
f0101bd8:	f7 f5                	div    %ebp
f0101bda:	89 c3                	mov    %eax,%ebx
f0101bdc:	89 d8                	mov    %ebx,%eax
f0101bde:	89 fa                	mov    %edi,%edx
f0101be0:	83 c4 1c             	add    $0x1c,%esp
f0101be3:	5b                   	pop    %ebx
f0101be4:	5e                   	pop    %esi
f0101be5:	5f                   	pop    %edi
f0101be6:	5d                   	pop    %ebp
f0101be7:	c3                   	ret    
f0101be8:	90                   	nop
f0101be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101bf0:	39 ce                	cmp    %ecx,%esi
f0101bf2:	77 74                	ja     f0101c68 <__udivdi3+0xd8>
f0101bf4:	0f bd fe             	bsr    %esi,%edi
f0101bf7:	83 f7 1f             	xor    $0x1f,%edi
f0101bfa:	0f 84 98 00 00 00    	je     f0101c98 <__udivdi3+0x108>
f0101c00:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101c05:	89 f9                	mov    %edi,%ecx
f0101c07:	89 c5                	mov    %eax,%ebp
f0101c09:	29 fb                	sub    %edi,%ebx
f0101c0b:	d3 e6                	shl    %cl,%esi
f0101c0d:	89 d9                	mov    %ebx,%ecx
f0101c0f:	d3 ed                	shr    %cl,%ebp
f0101c11:	89 f9                	mov    %edi,%ecx
f0101c13:	d3 e0                	shl    %cl,%eax
f0101c15:	09 ee                	or     %ebp,%esi
f0101c17:	89 d9                	mov    %ebx,%ecx
f0101c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c1d:	89 d5                	mov    %edx,%ebp
f0101c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101c23:	d3 ed                	shr    %cl,%ebp
f0101c25:	89 f9                	mov    %edi,%ecx
f0101c27:	d3 e2                	shl    %cl,%edx
f0101c29:	89 d9                	mov    %ebx,%ecx
f0101c2b:	d3 e8                	shr    %cl,%eax
f0101c2d:	09 c2                	or     %eax,%edx
f0101c2f:	89 d0                	mov    %edx,%eax
f0101c31:	89 ea                	mov    %ebp,%edx
f0101c33:	f7 f6                	div    %esi
f0101c35:	89 d5                	mov    %edx,%ebp
f0101c37:	89 c3                	mov    %eax,%ebx
f0101c39:	f7 64 24 0c          	mull   0xc(%esp)
f0101c3d:	39 d5                	cmp    %edx,%ebp
f0101c3f:	72 10                	jb     f0101c51 <__udivdi3+0xc1>
f0101c41:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101c45:	89 f9                	mov    %edi,%ecx
f0101c47:	d3 e6                	shl    %cl,%esi
f0101c49:	39 c6                	cmp    %eax,%esi
f0101c4b:	73 07                	jae    f0101c54 <__udivdi3+0xc4>
f0101c4d:	39 d5                	cmp    %edx,%ebp
f0101c4f:	75 03                	jne    f0101c54 <__udivdi3+0xc4>
f0101c51:	83 eb 01             	sub    $0x1,%ebx
f0101c54:	31 ff                	xor    %edi,%edi
f0101c56:	89 d8                	mov    %ebx,%eax
f0101c58:	89 fa                	mov    %edi,%edx
f0101c5a:	83 c4 1c             	add    $0x1c,%esp
f0101c5d:	5b                   	pop    %ebx
f0101c5e:	5e                   	pop    %esi
f0101c5f:	5f                   	pop    %edi
f0101c60:	5d                   	pop    %ebp
f0101c61:	c3                   	ret    
f0101c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101c68:	31 ff                	xor    %edi,%edi
f0101c6a:	31 db                	xor    %ebx,%ebx
f0101c6c:	89 d8                	mov    %ebx,%eax
f0101c6e:	89 fa                	mov    %edi,%edx
f0101c70:	83 c4 1c             	add    $0x1c,%esp
f0101c73:	5b                   	pop    %ebx
f0101c74:	5e                   	pop    %esi
f0101c75:	5f                   	pop    %edi
f0101c76:	5d                   	pop    %ebp
f0101c77:	c3                   	ret    
f0101c78:	90                   	nop
f0101c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c80:	89 d8                	mov    %ebx,%eax
f0101c82:	f7 f7                	div    %edi
f0101c84:	31 ff                	xor    %edi,%edi
f0101c86:	89 c3                	mov    %eax,%ebx
f0101c88:	89 d8                	mov    %ebx,%eax
f0101c8a:	89 fa                	mov    %edi,%edx
f0101c8c:	83 c4 1c             	add    $0x1c,%esp
f0101c8f:	5b                   	pop    %ebx
f0101c90:	5e                   	pop    %esi
f0101c91:	5f                   	pop    %edi
f0101c92:	5d                   	pop    %ebp
f0101c93:	c3                   	ret    
f0101c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c98:	39 ce                	cmp    %ecx,%esi
f0101c9a:	72 0c                	jb     f0101ca8 <__udivdi3+0x118>
f0101c9c:	31 db                	xor    %ebx,%ebx
f0101c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101ca2:	0f 87 34 ff ff ff    	ja     f0101bdc <__udivdi3+0x4c>
f0101ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0101cad:	e9 2a ff ff ff       	jmp    f0101bdc <__udivdi3+0x4c>
f0101cb2:	66 90                	xchg   %ax,%ax
f0101cb4:	66 90                	xchg   %ax,%ax
f0101cb6:	66 90                	xchg   %ax,%ax
f0101cb8:	66 90                	xchg   %ax,%ax
f0101cba:	66 90                	xchg   %ax,%ax
f0101cbc:	66 90                	xchg   %ax,%ax
f0101cbe:	66 90                	xchg   %ax,%ax

f0101cc0 <__umoddi3>:
f0101cc0:	55                   	push   %ebp
f0101cc1:	57                   	push   %edi
f0101cc2:	56                   	push   %esi
f0101cc3:	53                   	push   %ebx
f0101cc4:	83 ec 1c             	sub    $0x1c,%esp
f0101cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0101ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101cd7:	85 d2                	test   %edx,%edx
f0101cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ce1:	89 f3                	mov    %esi,%ebx
f0101ce3:	89 3c 24             	mov    %edi,(%esp)
f0101ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101cea:	75 1c                	jne    f0101d08 <__umoddi3+0x48>
f0101cec:	39 f7                	cmp    %esi,%edi
f0101cee:	76 50                	jbe    f0101d40 <__umoddi3+0x80>
f0101cf0:	89 c8                	mov    %ecx,%eax
f0101cf2:	89 f2                	mov    %esi,%edx
f0101cf4:	f7 f7                	div    %edi
f0101cf6:	89 d0                	mov    %edx,%eax
f0101cf8:	31 d2                	xor    %edx,%edx
f0101cfa:	83 c4 1c             	add    $0x1c,%esp
f0101cfd:	5b                   	pop    %ebx
f0101cfe:	5e                   	pop    %esi
f0101cff:	5f                   	pop    %edi
f0101d00:	5d                   	pop    %ebp
f0101d01:	c3                   	ret    
f0101d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101d08:	39 f2                	cmp    %esi,%edx
f0101d0a:	89 d0                	mov    %edx,%eax
f0101d0c:	77 52                	ja     f0101d60 <__umoddi3+0xa0>
f0101d0e:	0f bd ea             	bsr    %edx,%ebp
f0101d11:	83 f5 1f             	xor    $0x1f,%ebp
f0101d14:	75 5a                	jne    f0101d70 <__umoddi3+0xb0>
f0101d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0101d1a:	0f 82 e0 00 00 00    	jb     f0101e00 <__umoddi3+0x140>
f0101d20:	39 0c 24             	cmp    %ecx,(%esp)
f0101d23:	0f 86 d7 00 00 00    	jbe    f0101e00 <__umoddi3+0x140>
f0101d29:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101d31:	83 c4 1c             	add    $0x1c,%esp
f0101d34:	5b                   	pop    %ebx
f0101d35:	5e                   	pop    %esi
f0101d36:	5f                   	pop    %edi
f0101d37:	5d                   	pop    %ebp
f0101d38:	c3                   	ret    
f0101d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d40:	85 ff                	test   %edi,%edi
f0101d42:	89 fd                	mov    %edi,%ebp
f0101d44:	75 0b                	jne    f0101d51 <__umoddi3+0x91>
f0101d46:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d4b:	31 d2                	xor    %edx,%edx
f0101d4d:	f7 f7                	div    %edi
f0101d4f:	89 c5                	mov    %eax,%ebp
f0101d51:	89 f0                	mov    %esi,%eax
f0101d53:	31 d2                	xor    %edx,%edx
f0101d55:	f7 f5                	div    %ebp
f0101d57:	89 c8                	mov    %ecx,%eax
f0101d59:	f7 f5                	div    %ebp
f0101d5b:	89 d0                	mov    %edx,%eax
f0101d5d:	eb 99                	jmp    f0101cf8 <__umoddi3+0x38>
f0101d5f:	90                   	nop
f0101d60:	89 c8                	mov    %ecx,%eax
f0101d62:	89 f2                	mov    %esi,%edx
f0101d64:	83 c4 1c             	add    $0x1c,%esp
f0101d67:	5b                   	pop    %ebx
f0101d68:	5e                   	pop    %esi
f0101d69:	5f                   	pop    %edi
f0101d6a:	5d                   	pop    %ebp
f0101d6b:	c3                   	ret    
f0101d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d70:	8b 34 24             	mov    (%esp),%esi
f0101d73:	bf 20 00 00 00       	mov    $0x20,%edi
f0101d78:	89 e9                	mov    %ebp,%ecx
f0101d7a:	29 ef                	sub    %ebp,%edi
f0101d7c:	d3 e0                	shl    %cl,%eax
f0101d7e:	89 f9                	mov    %edi,%ecx
f0101d80:	89 f2                	mov    %esi,%edx
f0101d82:	d3 ea                	shr    %cl,%edx
f0101d84:	89 e9                	mov    %ebp,%ecx
f0101d86:	09 c2                	or     %eax,%edx
f0101d88:	89 d8                	mov    %ebx,%eax
f0101d8a:	89 14 24             	mov    %edx,(%esp)
f0101d8d:	89 f2                	mov    %esi,%edx
f0101d8f:	d3 e2                	shl    %cl,%edx
f0101d91:	89 f9                	mov    %edi,%ecx
f0101d93:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101d9b:	d3 e8                	shr    %cl,%eax
f0101d9d:	89 e9                	mov    %ebp,%ecx
f0101d9f:	89 c6                	mov    %eax,%esi
f0101da1:	d3 e3                	shl    %cl,%ebx
f0101da3:	89 f9                	mov    %edi,%ecx
f0101da5:	89 d0                	mov    %edx,%eax
f0101da7:	d3 e8                	shr    %cl,%eax
f0101da9:	89 e9                	mov    %ebp,%ecx
f0101dab:	09 d8                	or     %ebx,%eax
f0101dad:	89 d3                	mov    %edx,%ebx
f0101daf:	89 f2                	mov    %esi,%edx
f0101db1:	f7 34 24             	divl   (%esp)
f0101db4:	89 d6                	mov    %edx,%esi
f0101db6:	d3 e3                	shl    %cl,%ebx
f0101db8:	f7 64 24 04          	mull   0x4(%esp)
f0101dbc:	39 d6                	cmp    %edx,%esi
f0101dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101dc2:	89 d1                	mov    %edx,%ecx
f0101dc4:	89 c3                	mov    %eax,%ebx
f0101dc6:	72 08                	jb     f0101dd0 <__umoddi3+0x110>
f0101dc8:	75 11                	jne    f0101ddb <__umoddi3+0x11b>
f0101dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101dce:	73 0b                	jae    f0101ddb <__umoddi3+0x11b>
f0101dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101dd4:	1b 14 24             	sbb    (%esp),%edx
f0101dd7:	89 d1                	mov    %edx,%ecx
f0101dd9:	89 c3                	mov    %eax,%ebx
f0101ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101ddf:	29 da                	sub    %ebx,%edx
f0101de1:	19 ce                	sbb    %ecx,%esi
f0101de3:	89 f9                	mov    %edi,%ecx
f0101de5:	89 f0                	mov    %esi,%eax
f0101de7:	d3 e0                	shl    %cl,%eax
f0101de9:	89 e9                	mov    %ebp,%ecx
f0101deb:	d3 ea                	shr    %cl,%edx
f0101ded:	89 e9                	mov    %ebp,%ecx
f0101def:	d3 ee                	shr    %cl,%esi
f0101df1:	09 d0                	or     %edx,%eax
f0101df3:	89 f2                	mov    %esi,%edx
f0101df5:	83 c4 1c             	add    $0x1c,%esp
f0101df8:	5b                   	pop    %ebx
f0101df9:	5e                   	pop    %esi
f0101dfa:	5f                   	pop    %edi
f0101dfb:	5d                   	pop    %ebp
f0101dfc:	c3                   	ret    
f0101dfd:	8d 76 00             	lea    0x0(%esi),%esi
f0101e00:	29 f9                	sub    %edi,%ecx
f0101e02:	19 d6                	sbb    %edx,%esi
f0101e04:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101e0c:	e9 18 ff ff ff       	jmp    f0101d29 <__umoddi3+0x69>
