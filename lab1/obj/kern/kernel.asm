
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
f010004b:	68 80 1c 10 f0       	push   $0xf0101c80
f0100050:	e8 90 09 00 00       	call   f01009e5 <cprintf>
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
f0100076:	e8 ba 07 00 00       	call   f0100835 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 9c 1c 10 f0       	push   $0xf0101c9c
f0100087:	e8 59 09 00 00       	call   f01009e5 <cprintf>
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
f01000dd:	e8 ba 16 00 00       	call   f010179c <memset>

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
f01000f4:	68 30 1d 10 f0       	push   $0xf0101d30
f01000f9:	e8 e7 08 00 00       	call   f01009e5 <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f01000fe:	83 c4 18             	add    $0x18,%esp
f0100101:	6a 16                	push   $0x16
f0100103:	68 50 1d 10 f0       	push   $0xf0101d50
f0100108:	e8 d8 08 00 00       	call   f01009e5 <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f010010d:	83 c4 0c             	add    $0xc,%esp
f0100110:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f0100114:	50                   	push   %eax
f0100115:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0100119:	50                   	push   %eax
f010011a:	68 b7 1c 10 f0       	push   $0xf0101cb7
f010011f:	e8 c1 08 00 00       	call   f01009e5 <cprintf>
	cprintf("%n", NULL);
f0100124:	83 c4 08             	add    $0x8,%esp
f0100127:	6a 00                	push   $0x0
f0100129:	68 d0 1c 10 f0       	push   $0xf0101cd0
f010012e:	e8 b2 08 00 00       	call   f01009e5 <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100133:	83 c4 0c             	add    $0xc,%esp
f0100136:	68 ff 00 00 00       	push   $0xff
f010013b:	6a 0d                	push   $0xd
f010013d:	8d 9d e6 fe ff ff    	lea    -0x11a(%ebp),%ebx
f0100143:	53                   	push   %ebx
f0100144:	e8 53 16 00 00       	call   f010179c <memset>
	cprintf("%s%n", ntest, &chnum1);
f0100149:	83 c4 0c             	add    $0xc,%esp
f010014c:	56                   	push   %esi
f010014d:	53                   	push   %ebx
f010014e:	68 ce 1c 10 f0       	push   $0xf0101cce
f0100153:	e8 8d 08 00 00       	call   f01009e5 <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f0100158:	83 c4 08             	add    $0x8,%esp
f010015b:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f010015f:	50                   	push   %eax
f0100160:	68 d3 1c 10 f0       	push   $0xf0101cd3
f0100165:	e8 7b 08 00 00       	call   f01009e5 <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f010016a:	83 c4 0c             	add    $0xc,%esp
f010016d:	68 00 fc ff ff       	push   $0xfffffc00
f0100172:	68 00 04 00 00       	push   $0x400
f0100177:	68 df 1c 10 f0       	push   $0xf0101cdf
f010017c:	e8 64 08 00 00       	call   f01009e5 <cprintf>


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
f0100195:	e8 b2 06 00 00       	call   f010084c <monitor>
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
f01001c4:	68 fb 1c 10 f0       	push   $0xf0101cfb
f01001c9:	e8 17 08 00 00       	call   f01009e5 <cprintf>
	vcprintf(fmt, ap);
f01001ce:	83 c4 08             	add    $0x8,%esp
f01001d1:	53                   	push   %ebx
f01001d2:	56                   	push   %esi
f01001d3:	e8 e7 07 00 00       	call   f01009bf <vcprintf>
	cprintf("\n");
f01001d8:	c7 04 24 89 1d 10 f0 	movl   $0xf0101d89,(%esp)
f01001df:	e8 01 08 00 00       	call   f01009e5 <cprintf>
	va_end(ap);
f01001e4:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01001e7:	83 ec 0c             	sub    $0xc,%esp
f01001ea:	6a 00                	push   $0x0
f01001ec:	e8 5b 06 00 00       	call   f010084c <monitor>
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
f0100206:	68 13 1d 10 f0       	push   $0xf0101d13
f010020b:	e8 d5 07 00 00       	call   f01009e5 <cprintf>
	vcprintf(fmt, ap);
f0100210:	83 c4 08             	add    $0x8,%esp
f0100213:	53                   	push   %ebx
f0100214:	ff 75 10             	pushl  0x10(%ebp)
f0100217:	e8 a3 07 00 00       	call   f01009bf <vcprintf>
	cprintf("\n");
f010021c:	c7 04 24 89 1d 10 f0 	movl   $0xf0101d89,(%esp)
f0100223:	e8 bd 07 00 00       	call   f01009e5 <cprintf>
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
f01002da:	0f b6 82 e0 1e 10 f0 	movzbl -0xfefe120(%edx),%eax
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
f0100316:	0f b6 82 e0 1e 10 f0 	movzbl -0xfefe120(%edx),%eax
f010031d:	0b 05 20 23 11 f0    	or     0xf0112320,%eax
f0100323:	0f b6 8a e0 1d 10 f0 	movzbl -0xfefe220(%edx),%ecx
f010032a:	31 c8                	xor    %ecx,%eax
f010032c:	a3 20 23 11 f0       	mov    %eax,0xf0112320

	c = charcode[shift & (CTL | SHIFT)][data];
f0100331:	89 c1                	mov    %eax,%ecx
f0100333:	83 e1 03             	and    $0x3,%ecx
f0100336:	8b 0c 8d c0 1d 10 f0 	mov    -0xfefe240(,%ecx,4),%ecx
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
f0100374:	68 7f 1d 10 f0       	push   $0xf0101d7f
f0100379:	e8 67 06 00 00       	call   f01009e5 <cprintf>
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
f0100532:	e8 b2 12 00 00       	call   f01017e9 <memmove>
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
f0100705:	68 8b 1d 10 f0       	push   $0xf0101d8b
f010070a:	e8 d6 02 00 00       	call   f01009e5 <cprintf>
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

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100745:	55                   	push   %ebp
f0100746:	89 e5                	mov    %esp,%ebp
f0100748:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010074b:	68 e0 1f 10 f0       	push   $0xf0101fe0
f0100750:	68 fe 1f 10 f0       	push   $0xf0101ffe
f0100755:	68 03 20 10 f0       	push   $0xf0102003
f010075a:	e8 86 02 00 00       	call   f01009e5 <cprintf>
f010075f:	83 c4 0c             	add    $0xc,%esp
f0100762:	68 90 20 10 f0       	push   $0xf0102090
f0100767:	68 0c 20 10 f0       	push   $0xf010200c
f010076c:	68 03 20 10 f0       	push   $0xf0102003
f0100771:	e8 6f 02 00 00       	call   f01009e5 <cprintf>
	return 0;
}
f0100776:	b8 00 00 00 00       	mov    $0x0,%eax
f010077b:	c9                   	leave  
f010077c:	c3                   	ret    

f010077d <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010077d:	55                   	push   %ebp
f010077e:	89 e5                	mov    %esp,%ebp
f0100780:	83 ec 14             	sub    $0x14,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100783:	68 15 20 10 f0       	push   $0xf0102015
f0100788:	e8 58 02 00 00       	call   f01009e5 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010078d:	83 c4 0c             	add    $0xc,%esp
f0100790:	68 0c 00 10 00       	push   $0x10000c
f0100795:	68 0c 00 10 f0       	push   $0xf010000c
f010079a:	68 b8 20 10 f0       	push   $0xf01020b8
f010079f:	e8 41 02 00 00       	call   f01009e5 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a4:	83 c4 0c             	add    $0xc,%esp
f01007a7:	68 61 1c 10 00       	push   $0x101c61
f01007ac:	68 61 1c 10 f0       	push   $0xf0101c61
f01007b1:	68 dc 20 10 f0       	push   $0xf01020dc
f01007b6:	e8 2a 02 00 00       	call   f01009e5 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007bb:	83 c4 0c             	add    $0xc,%esp
f01007be:	68 00 23 11 00       	push   $0x112300
f01007c3:	68 00 23 11 f0       	push   $0xf0112300
f01007c8:	68 00 21 10 f0       	push   $0xf0102100
f01007cd:	e8 13 02 00 00       	call   f01009e5 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007d2:	83 c4 0c             	add    $0xc,%esp
f01007d5:	68 60 29 11 00       	push   $0x112960
f01007da:	68 60 29 11 f0       	push   $0xf0112960
f01007df:	68 24 21 10 f0       	push   $0xf0102124
f01007e4:	e8 fc 01 00 00       	call   f01009e5 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007e9:	83 c4 08             	add    $0x8,%esp
f01007ec:	b8 5f 2d 11 f0       	mov    $0xf0112d5f,%eax
f01007f1:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007f6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007fc:	85 c0                	test   %eax,%eax
f01007fe:	0f 48 c2             	cmovs  %edx,%eax
f0100801:	c1 f8 0a             	sar    $0xa,%eax
f0100804:	50                   	push   %eax
f0100805:	68 48 21 10 f0       	push   $0xf0102148
f010080a:	e8 d6 01 00 00       	call   f01009e5 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f010080f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100814:	c9                   	leave  
f0100815:	c3                   	ret    

f0100816 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f0100816:	55                   	push   %ebp
f0100817:	89 e5                	mov    %esp,%ebp
f0100819:	83 ec 14             	sub    $0x14,%esp
    cprintf("Overflow success\n");
f010081c:	68 2e 20 10 f0       	push   $0xf010202e
f0100821:	e8 bf 01 00 00       	call   f01009e5 <cprintf>
}
f0100826:	83 c4 10             	add    $0x10,%esp
f0100829:	c9                   	leave  
f010082a:	c3                   	ret    

f010082b <start_overflow>:

void
start_overflow(void)
{
f010082b:	55                   	push   %ebp
f010082c:	89 e5                	mov    %esp,%ebp

	// Your code here.
    


}
f010082e:	5d                   	pop    %ebp
f010082f:	c3                   	ret    

f0100830 <overflow_me>:

void
overflow_me(void)
{
f0100830:	55                   	push   %ebp
f0100831:	89 e5                	mov    %esp,%ebp
        start_overflow();
}
f0100833:	5d                   	pop    %ebp
f0100834:	c3                   	ret    

f0100835 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100835:	55                   	push   %ebp
f0100836:	89 e5                	mov    %esp,%ebp
f0100838:	83 ec 14             	sub    $0x14,%esp
	// Your code here.
    overflow_me();
    cprintf("Backtrace success\n");
f010083b:	68 40 20 10 f0       	push   $0xf0102040
f0100840:	e8 a0 01 00 00       	call   f01009e5 <cprintf>
	return 0;
}
f0100845:	b8 00 00 00 00       	mov    $0x0,%eax
f010084a:	c9                   	leave  
f010084b:	c3                   	ret    

f010084c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010084c:	55                   	push   %ebp
f010084d:	89 e5                	mov    %esp,%ebp
f010084f:	57                   	push   %edi
f0100850:	56                   	push   %esi
f0100851:	53                   	push   %ebx
f0100852:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100855:	68 74 21 10 f0       	push   $0xf0102174
f010085a:	e8 86 01 00 00       	call   f01009e5 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010085f:	c7 04 24 98 21 10 f0 	movl   $0xf0102198,(%esp)
f0100866:	e8 7a 01 00 00       	call   f01009e5 <cprintf>
f010086b:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010086e:	83 ec 0c             	sub    $0xc,%esp
f0100871:	68 53 20 10 f0       	push   $0xf0102053
f0100876:	e8 6d 0c 00 00       	call   f01014e8 <readline>
f010087b:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010087d:	83 c4 10             	add    $0x10,%esp
f0100880:	85 c0                	test   %eax,%eax
f0100882:	74 ea                	je     f010086e <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100884:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010088b:	be 00 00 00 00       	mov    $0x0,%esi
f0100890:	eb 0a                	jmp    f010089c <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100892:	c6 03 00             	movb   $0x0,(%ebx)
f0100895:	89 f7                	mov    %esi,%edi
f0100897:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010089a:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010089c:	0f b6 03             	movzbl (%ebx),%eax
f010089f:	84 c0                	test   %al,%al
f01008a1:	74 6a                	je     f010090d <monitor+0xc1>
f01008a3:	83 ec 08             	sub    $0x8,%esp
f01008a6:	0f be c0             	movsbl %al,%eax
f01008a9:	50                   	push   %eax
f01008aa:	68 57 20 10 f0       	push   $0xf0102057
f01008af:	e8 8a 0e 00 00       	call   f010173e <strchr>
f01008b4:	83 c4 10             	add    $0x10,%esp
f01008b7:	85 c0                	test   %eax,%eax
f01008b9:	75 d7                	jne    f0100892 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008bb:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008be:	74 4d                	je     f010090d <monitor+0xc1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008c0:	83 fe 0f             	cmp    $0xf,%esi
f01008c3:	75 14                	jne    f01008d9 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008c5:	83 ec 08             	sub    $0x8,%esp
f01008c8:	6a 10                	push   $0x10
f01008ca:	68 5c 20 10 f0       	push   $0xf010205c
f01008cf:	e8 11 01 00 00       	call   f01009e5 <cprintf>
f01008d4:	83 c4 10             	add    $0x10,%esp
f01008d7:	eb 95                	jmp    f010086e <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008d9:	8d 7e 01             	lea    0x1(%esi),%edi
f01008dc:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01008e0:	0f b6 03             	movzbl (%ebx),%eax
f01008e3:	84 c0                	test   %al,%al
f01008e5:	75 0c                	jne    f01008f3 <monitor+0xa7>
f01008e7:	eb b1                	jmp    f010089a <monitor+0x4e>
			buf++;
f01008e9:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ec:	0f b6 03             	movzbl (%ebx),%eax
f01008ef:	84 c0                	test   %al,%al
f01008f1:	74 a7                	je     f010089a <monitor+0x4e>
f01008f3:	83 ec 08             	sub    $0x8,%esp
f01008f6:	0f be c0             	movsbl %al,%eax
f01008f9:	50                   	push   %eax
f01008fa:	68 57 20 10 f0       	push   $0xf0102057
f01008ff:	e8 3a 0e 00 00       	call   f010173e <strchr>
f0100904:	83 c4 10             	add    $0x10,%esp
f0100907:	85 c0                	test   %eax,%eax
f0100909:	74 de                	je     f01008e9 <monitor+0x9d>
f010090b:	eb 8d                	jmp    f010089a <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f010090d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100914:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100915:	85 f6                	test   %esi,%esi
f0100917:	0f 84 51 ff ff ff    	je     f010086e <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010091d:	83 ec 08             	sub    $0x8,%esp
f0100920:	68 fe 1f 10 f0       	push   $0xf0101ffe
f0100925:	ff 75 a8             	pushl  -0x58(%ebp)
f0100928:	e8 8d 0d 00 00       	call   f01016ba <strcmp>
f010092d:	83 c4 10             	add    $0x10,%esp
f0100930:	85 c0                	test   %eax,%eax
f0100932:	74 1e                	je     f0100952 <monitor+0x106>
f0100934:	83 ec 08             	sub    $0x8,%esp
f0100937:	68 0c 20 10 f0       	push   $0xf010200c
f010093c:	ff 75 a8             	pushl  -0x58(%ebp)
f010093f:	e8 76 0d 00 00       	call   f01016ba <strcmp>
f0100944:	83 c4 10             	add    $0x10,%esp
f0100947:	85 c0                	test   %eax,%eax
f0100949:	75 2f                	jne    f010097a <monitor+0x12e>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010094b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100950:	eb 05                	jmp    f0100957 <monitor+0x10b>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100952:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100957:	83 ec 04             	sub    $0x4,%esp
f010095a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010095d:	01 d0                	add    %edx,%eax
f010095f:	ff 75 08             	pushl  0x8(%ebp)
f0100962:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100965:	51                   	push   %ecx
f0100966:	56                   	push   %esi
f0100967:	ff 14 85 c8 21 10 f0 	call   *-0xfefde38(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010096e:	83 c4 10             	add    $0x10,%esp
f0100971:	85 c0                	test   %eax,%eax
f0100973:	78 1d                	js     f0100992 <monitor+0x146>
f0100975:	e9 f4 fe ff ff       	jmp    f010086e <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010097a:	83 ec 08             	sub    $0x8,%esp
f010097d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100980:	68 79 20 10 f0       	push   $0xf0102079
f0100985:	e8 5b 00 00 00       	call   f01009e5 <cprintf>
f010098a:	83 c4 10             	add    $0x10,%esp
f010098d:	e9 dc fe ff ff       	jmp    f010086e <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100992:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100995:	5b                   	pop    %ebx
f0100996:	5e                   	pop    %esi
f0100997:	5f                   	pop    %edi
f0100998:	5d                   	pop    %ebp
f0100999:	c3                   	ret    

f010099a <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f010099a:	55                   	push   %ebp
f010099b:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010099d:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01009a0:	5d                   	pop    %ebp
f01009a1:	c3                   	ret    

f01009a2 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009a2:	55                   	push   %ebp
f01009a3:	89 e5                	mov    %esp,%ebp
f01009a5:	53                   	push   %ebx
f01009a6:	83 ec 10             	sub    $0x10,%esp
f01009a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f01009ac:	ff 75 08             	pushl  0x8(%ebp)
f01009af:	e8 66 fd ff ff       	call   f010071a <cputchar>
    (*cnt)++;
f01009b4:	83 03 01             	addl   $0x1,(%ebx)
}
f01009b7:	83 c4 10             	add    $0x10,%esp
f01009ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01009bd:	c9                   	leave  
f01009be:	c3                   	ret    

f01009bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009bf:	55                   	push   %ebp
f01009c0:	89 e5                	mov    %esp,%ebp
f01009c2:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01009c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009cc:	ff 75 0c             	pushl  0xc(%ebp)
f01009cf:	ff 75 08             	pushl  0x8(%ebp)
f01009d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009d5:	50                   	push   %eax
f01009d6:	68 a2 09 10 f0       	push   $0xf01009a2
f01009db:	e8 d5 05 00 00       	call   f0100fb5 <vprintfmt>
	return cnt;
}
f01009e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009e3:	c9                   	leave  
f01009e4:	c3                   	ret    

f01009e5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009e5:	55                   	push   %ebp
f01009e6:	89 e5                	mov    %esp,%ebp
f01009e8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009eb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009ee:	50                   	push   %eax
f01009ef:	ff 75 08             	pushl  0x8(%ebp)
f01009f2:	e8 c8 ff ff ff       	call   f01009bf <vcprintf>
	va_end(ap);

	return cnt;
}
f01009f7:	c9                   	leave  
f01009f8:	c3                   	ret    

f01009f9 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009f9:	55                   	push   %ebp
f01009fa:	89 e5                	mov    %esp,%ebp
f01009fc:	57                   	push   %edi
f01009fd:	56                   	push   %esi
f01009fe:	53                   	push   %ebx
f01009ff:	83 ec 14             	sub    $0x14,%esp
f0100a02:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a08:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a0e:	8b 1a                	mov    (%edx),%ebx
f0100a10:	8b 01                	mov    (%ecx),%eax
f0100a12:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	while (l <= r) {
f0100a15:	39 c3                	cmp    %eax,%ebx
f0100a17:	0f 8f 9a 00 00 00    	jg     f0100ab7 <stab_binsearch+0xbe>
f0100a1d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a27:	01 d8                	add    %ebx,%eax
f0100a29:	89 c6                	mov    %eax,%esi
f0100a2b:	c1 ee 1f             	shr    $0x1f,%esi
f0100a2e:	01 c6                	add    %eax,%esi
f0100a30:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a32:	39 de                	cmp    %ebx,%esi
f0100a34:	0f 8c c4 00 00 00    	jl     f0100afe <stab_binsearch+0x105>
f0100a3a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a3d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a40:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100a43:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0100a47:	39 c7                	cmp    %eax,%edi
f0100a49:	0f 84 b4 00 00 00    	je     f0100b03 <stab_binsearch+0x10a>
f0100a4f:	89 f0                	mov    %esi,%eax
			m--;
f0100a51:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a54:	39 d8                	cmp    %ebx,%eax
f0100a56:	0f 8c a2 00 00 00    	jl     f0100afe <stab_binsearch+0x105>
f0100a5c:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0100a60:	83 ea 0c             	sub    $0xc,%edx
f0100a63:	39 f9                	cmp    %edi,%ecx
f0100a65:	75 ea                	jne    f0100a51 <stab_binsearch+0x58>
f0100a67:	e9 99 00 00 00       	jmp    f0100b05 <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100a6c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a6f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a71:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a74:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a7b:	eb 2b                	jmp    f0100aa8 <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a7d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a80:	76 14                	jbe    f0100a96 <stab_binsearch+0x9d>
			*region_right = m - 1;
f0100a82:	83 e8 01             	sub    $0x1,%eax
f0100a85:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a88:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a8b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a8d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a94:	eb 12                	jmp    f0100aa8 <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a96:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a99:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a9b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a9f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100aa1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100aa8:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0100aab:	0f 8d 73 ff ff ff    	jge    f0100a24 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100ab1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100ab5:	75 0f                	jne    f0100ac6 <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f0100ab7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aba:	8b 00                	mov    (%eax),%eax
f0100abc:	83 e8 01             	sub    $0x1,%eax
f0100abf:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100ac2:	89 07                	mov    %eax,(%edi)
f0100ac4:	eb 57                	jmp    f0100b1d <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ac6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ac9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100acb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ace:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ad0:	39 c8                	cmp    %ecx,%eax
f0100ad2:	7e 23                	jle    f0100af7 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0100ad4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ad7:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100ada:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0100add:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100ae1:	39 df                	cmp    %ebx,%edi
f0100ae3:	74 12                	je     f0100af7 <stab_binsearch+0xfe>
		     l--)
f0100ae5:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ae8:	39 c8                	cmp    %ecx,%eax
f0100aea:	7e 0b                	jle    f0100af7 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0100aec:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f0100af0:	83 ea 0c             	sub    $0xc,%edx
f0100af3:	39 df                	cmp    %ebx,%edi
f0100af5:	75 ee                	jne    f0100ae5 <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100af7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100afa:	89 07                	mov    %eax,(%edi)
	}
}
f0100afc:	eb 1f                	jmp    f0100b1d <stab_binsearch+0x124>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100afe:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100b01:	eb a5                	jmp    f0100aa8 <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100b03:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b05:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b08:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b0b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b0f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b12:	0f 82 54 ff ff ff    	jb     f0100a6c <stab_binsearch+0x73>
f0100b18:	e9 60 ff ff ff       	jmp    f0100a7d <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100b1d:	83 c4 14             	add    $0x14,%esp
f0100b20:	5b                   	pop    %ebx
f0100b21:	5e                   	pop    %esi
f0100b22:	5f                   	pop    %edi
f0100b23:	5d                   	pop    %ebp
f0100b24:	c3                   	ret    

f0100b25 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b25:	55                   	push   %ebp
f0100b26:	89 e5                	mov    %esp,%ebp
f0100b28:	57                   	push   %edi
f0100b29:	56                   	push   %esi
f0100b2a:	53                   	push   %ebx
f0100b2b:	83 ec 1c             	sub    $0x1c,%esp
f0100b2e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100b31:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b34:	c7 06 d8 21 10 f0    	movl   $0xf01021d8,(%esi)
	info->eip_line = 0;
f0100b3a:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100b41:	c7 46 08 d8 21 10 f0 	movl   $0xf01021d8,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100b48:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100b4f:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100b52:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b59:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100b5f:	76 11                	jbe    f0100b72 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b61:	b8 24 7a 10 f0       	mov    $0xf0107a24,%eax
f0100b66:	3d fd 5f 10 f0       	cmp    $0xf0105ffd,%eax
f0100b6b:	77 19                	ja     f0100b86 <debuginfo_eip+0x61>
f0100b6d:	e9 84 01 00 00       	jmp    f0100cf6 <debuginfo_eip+0x1d1>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b72:	83 ec 04             	sub    $0x4,%esp
f0100b75:	68 e2 21 10 f0       	push   $0xf01021e2
f0100b7a:	6a 7f                	push   $0x7f
f0100b7c:	68 ef 21 10 f0       	push   $0xf01021ef
f0100b81:	e8 19 f6 ff ff       	call   f010019f <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b86:	80 3d 23 7a 10 f0 00 	cmpb   $0x0,0xf0107a23
f0100b8d:	0f 85 6a 01 00 00    	jne    f0100cfd <debuginfo_eip+0x1d8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b93:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b9a:	b8 fc 5f 10 f0       	mov    $0xf0105ffc,%eax
f0100b9f:	2d 8c 24 10 f0       	sub    $0xf010248c,%eax
f0100ba4:	c1 f8 02             	sar    $0x2,%eax
f0100ba7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100bad:	83 e8 01             	sub    $0x1,%eax
f0100bb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bb3:	83 ec 08             	sub    $0x8,%esp
f0100bb6:	57                   	push   %edi
f0100bb7:	6a 64                	push   $0x64
f0100bb9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100bbc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100bbf:	b8 8c 24 10 f0       	mov    $0xf010248c,%eax
f0100bc4:	e8 30 fe ff ff       	call   f01009f9 <stab_binsearch>
	if (lfile == 0)
f0100bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bcc:	83 c4 10             	add    $0x10,%esp
f0100bcf:	85 c0                	test   %eax,%eax
f0100bd1:	0f 84 2d 01 00 00    	je     f0100d04 <debuginfo_eip+0x1df>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100bd7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100bda:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bdd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100be0:	83 ec 08             	sub    $0x8,%esp
f0100be3:	57                   	push   %edi
f0100be4:	6a 24                	push   $0x24
f0100be6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100be9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bec:	b8 8c 24 10 f0       	mov    $0xf010248c,%eax
f0100bf1:	e8 03 fe ff ff       	call   f01009f9 <stab_binsearch>

	if (lfun <= rfun) {
f0100bf6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100bf9:	83 c4 10             	add    $0x10,%esp
f0100bfc:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100bff:	7f 31                	jg     f0100c32 <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c01:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c04:	c1 e0 02             	shl    $0x2,%eax
f0100c07:	8d 90 8c 24 10 f0    	lea    -0xfefdb74(%eax),%edx
f0100c0d:	8b 88 8c 24 10 f0    	mov    -0xfefdb74(%eax),%ecx
f0100c13:	b8 24 7a 10 f0       	mov    $0xf0107a24,%eax
f0100c18:	2d fd 5f 10 f0       	sub    $0xf0105ffd,%eax
f0100c1d:	39 c1                	cmp    %eax,%ecx
f0100c1f:	73 09                	jae    f0100c2a <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c21:	81 c1 fd 5f 10 f0    	add    $0xf0105ffd,%ecx
f0100c27:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c2a:	8b 42 08             	mov    0x8(%edx),%eax
f0100c2d:	89 46 10             	mov    %eax,0x10(%esi)
f0100c30:	eb 06                	jmp    f0100c38 <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c32:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100c35:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c38:	83 ec 08             	sub    $0x8,%esp
f0100c3b:	6a 3a                	push   $0x3a
f0100c3d:	ff 76 08             	pushl  0x8(%esi)
f0100c40:	e8 2f 0b 00 00       	call   f0101774 <strfind>
f0100c45:	2b 46 08             	sub    0x8(%esi),%eax
f0100c48:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c4e:	83 c4 10             	add    $0x10,%esp
f0100c51:	39 fb                	cmp    %edi,%ebx
f0100c53:	7c 5b                	jl     f0100cb0 <debuginfo_eip+0x18b>
	       && stabs[lline].n_type != N_SOL
f0100c55:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c58:	8d 0c 85 8c 24 10 f0 	lea    -0xfefdb74(,%eax,4),%ecx
f0100c5f:	0f b6 41 04          	movzbl 0x4(%ecx),%eax
f0100c63:	3c 84                	cmp    $0x84,%al
f0100c65:	74 29                	je     f0100c90 <debuginfo_eip+0x16b>
f0100c67:	89 ca                	mov    %ecx,%edx
f0100c69:	83 c1 08             	add    $0x8,%ecx
f0100c6c:	eb 15                	jmp    f0100c83 <debuginfo_eip+0x15e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100c6e:	83 eb 01             	sub    $0x1,%ebx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c71:	39 fb                	cmp    %edi,%ebx
f0100c73:	7c 3b                	jl     f0100cb0 <debuginfo_eip+0x18b>
	       && stabs[lline].n_type != N_SOL
f0100c75:	0f b6 42 f8          	movzbl -0x8(%edx),%eax
f0100c79:	83 ea 0c             	sub    $0xc,%edx
f0100c7c:	83 e9 0c             	sub    $0xc,%ecx
f0100c7f:	3c 84                	cmp    $0x84,%al
f0100c81:	74 0d                	je     f0100c90 <debuginfo_eip+0x16b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c83:	3c 64                	cmp    $0x64,%al
f0100c85:	75 e7                	jne    f0100c6e <debuginfo_eip+0x149>
f0100c87:	83 39 00             	cmpl   $0x0,(%ecx)
f0100c8a:	74 e2                	je     f0100c6e <debuginfo_eip+0x149>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c8c:	39 df                	cmp    %ebx,%edi
f0100c8e:	7f 20                	jg     f0100cb0 <debuginfo_eip+0x18b>
f0100c90:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c93:	8b 14 85 8c 24 10 f0 	mov    -0xfefdb74(,%eax,4),%edx
f0100c9a:	b8 24 7a 10 f0       	mov    $0xf0107a24,%eax
f0100c9f:	2d fd 5f 10 f0       	sub    $0xf0105ffd,%eax
f0100ca4:	39 c2                	cmp    %eax,%edx
f0100ca6:	73 08                	jae    f0100cb0 <debuginfo_eip+0x18b>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100ca8:	81 c2 fd 5f 10 f0    	add    $0xf0105ffd,%edx
f0100cae:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cb0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cb3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100cb6:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cbb:	39 ca                	cmp    %ecx,%edx
f0100cbd:	7d 5f                	jge    f0100d1e <debuginfo_eip+0x1f9>
		for (lline = lfun + 1;
f0100cbf:	8d 42 01             	lea    0x1(%edx),%eax
f0100cc2:	39 c1                	cmp    %eax,%ecx
f0100cc4:	7e 45                	jle    f0100d0b <debuginfo_eip+0x1e6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100cc6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100cc9:	c1 e2 02             	shl    $0x2,%edx
f0100ccc:	80 ba 90 24 10 f0 a0 	cmpb   $0xa0,-0xfefdb70(%edx)
f0100cd3:	75 3d                	jne    f0100d12 <debuginfo_eip+0x1ed>
f0100cd5:	81 c2 80 24 10 f0    	add    $0xf0102480,%edx
		     lline++)
			info->eip_fn_narg++;
f0100cdb:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100cdf:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100ce2:	39 c1                	cmp    %eax,%ecx
f0100ce4:	7e 33                	jle    f0100d19 <debuginfo_eip+0x1f4>
f0100ce6:	83 c2 0c             	add    $0xc,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ce9:	80 7a 10 a0          	cmpb   $0xa0,0x10(%edx)
f0100ced:	74 ec                	je     f0100cdb <debuginfo_eip+0x1b6>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100cef:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cf4:	eb 28                	jmp    f0100d1e <debuginfo_eip+0x1f9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100cf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cfb:	eb 21                	jmp    f0100d1e <debuginfo_eip+0x1f9>
f0100cfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d02:	eb 1a                	jmp    f0100d1e <debuginfo_eip+0x1f9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100d04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d09:	eb 13                	jmp    f0100d1e <debuginfo_eip+0x1f9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100d0b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d10:	eb 0c                	jmp    f0100d1e <debuginfo_eip+0x1f9>
f0100d12:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d17:	eb 05                	jmp    f0100d1e <debuginfo_eip+0x1f9>
f0100d19:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d21:	5b                   	pop    %ebx
f0100d22:	5e                   	pop    %esi
f0100d23:	5f                   	pop    %edi
f0100d24:	5d                   	pop    %ebp
f0100d25:	c3                   	ret    

f0100d26 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d26:	55                   	push   %ebp
f0100d27:	89 e5                	mov    %esp,%ebp
f0100d29:	57                   	push   %edi
f0100d2a:	56                   	push   %esi
f0100d2b:	53                   	push   %ebx
f0100d2c:	83 ec 1c             	sub    $0x1c,%esp
f0100d2f:	89 c7                	mov    %eax,%edi
f0100d31:	89 d6                	mov    %edx,%esi
f0100d33:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d36:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d39:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d3c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100d3f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
f0100d42:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0100d46:	0f 85 bf 00 00 00    	jne    f0100e0b <printnum+0xe5>
f0100d4c:	39 1d 5c 25 11 f0    	cmp    %ebx,0xf011255c
f0100d52:	0f 8d de 00 00 00    	jge    f0100e36 <printnum+0x110>
		judge_time_for_space = width;
f0100d58:	89 1d 5c 25 11 f0    	mov    %ebx,0xf011255c
f0100d5e:	e9 d3 00 00 00       	jmp    f0100e36 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0100d63:	83 eb 01             	sub    $0x1,%ebx
f0100d66:	85 db                	test   %ebx,%ebx
f0100d68:	7f 37                	jg     f0100da1 <printnum+0x7b>
f0100d6a:	e9 ea 00 00 00       	jmp    f0100e59 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
f0100d6f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100d72:	a3 58 25 11 f0       	mov    %eax,0xf0112558
				putch(padc, putdat);
		}
	}
	// 22       .
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d77:	83 ec 08             	sub    $0x8,%esp
f0100d7a:	56                   	push   %esi
f0100d7b:	83 ec 04             	sub    $0x4,%esp
f0100d7e:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d81:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d84:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d87:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d8a:	e8 81 0d 00 00       	call   f0101b10 <__umoddi3>
f0100d8f:	83 c4 14             	add    $0x14,%esp
f0100d92:	0f be 80 fd 21 10 f0 	movsbl -0xfefde03(%eax),%eax
f0100d99:	50                   	push   %eax
f0100d9a:	ff d7                	call   *%edi
f0100d9c:	83 c4 10             	add    $0x10,%esp
f0100d9f:	eb 16                	jmp    f0100db7 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
f0100da1:	83 ec 08             	sub    $0x8,%esp
f0100da4:	56                   	push   %esi
f0100da5:	ff 75 18             	pushl  0x18(%ebp)
f0100da8:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0100daa:	83 c4 10             	add    $0x10,%esp
f0100dad:	83 eb 01             	sub    $0x1,%ebx
f0100db0:	75 ef                	jne    f0100da1 <printnum+0x7b>
f0100db2:	e9 a2 00 00 00       	jmp    f0100e59 <printnum+0x133>
	}
	// 22       .
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
f0100db7:	3b 1d 5c 25 11 f0    	cmp    0xf011255c,%ebx
f0100dbd:	0f 85 76 01 00 00    	jne    f0100f39 <printnum+0x213>
		while(num_of_space-- > 0)
f0100dc3:	a1 58 25 11 f0       	mov    0xf0112558,%eax
f0100dc8:	8d 50 ff             	lea    -0x1(%eax),%edx
f0100dcb:	89 15 58 25 11 f0    	mov    %edx,0xf0112558
f0100dd1:	85 c0                	test   %eax,%eax
f0100dd3:	7e 1d                	jle    f0100df2 <printnum+0xcc>
			putch(' ', putdat);
f0100dd5:	83 ec 08             	sub    $0x8,%esp
f0100dd8:	56                   	push   %esi
f0100dd9:	6a 20                	push   $0x20
f0100ddb:	ff d7                	call   *%edi
	// 22       .
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
f0100ddd:	a1 58 25 11 f0       	mov    0xf0112558,%eax
f0100de2:	8d 50 ff             	lea    -0x1(%eax),%edx
f0100de5:	89 15 58 25 11 f0    	mov    %edx,0xf0112558
f0100deb:	83 c4 10             	add    $0x10,%esp
f0100dee:	85 c0                	test   %eax,%eax
f0100df0:	7f e3                	jg     f0100dd5 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
f0100df2:	c7 05 58 25 11 f0 00 	movl   $0x0,0xf0112558
f0100df9:	00 00 00 
		judge_time_for_space = 0;
f0100dfc:	c7 05 5c 25 11 f0 00 	movl   $0x0,0xf011255c
f0100e03:	00 00 00 
	}
}
f0100e06:	e9 2e 01 00 00       	jmp    f0100f39 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e0b:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e0e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e13:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e16:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100e19:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100e1f:	83 fa 00             	cmp    $0x0,%edx
f0100e22:	0f 87 ba 00 00 00    	ja     f0100ee2 <printnum+0x1bc>
f0100e28:	3b 45 10             	cmp    0x10(%ebp),%eax
f0100e2b:	0f 83 b1 00 00 00    	jae    f0100ee2 <printnum+0x1bc>
f0100e31:	e9 2d ff ff ff       	jmp    f0100d63 <printnum+0x3d>
f0100e36:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e39:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e41:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100e44:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100e4a:	83 fa 00             	cmp    $0x0,%edx
f0100e4d:	77 37                	ja     f0100e86 <printnum+0x160>
f0100e4f:	3b 45 10             	cmp    0x10(%ebp),%eax
f0100e52:	73 32                	jae    f0100e86 <printnum+0x160>
f0100e54:	e9 16 ff ff ff       	jmp    f0100d6f <printnum+0x49>
				putch(padc, putdat);
		}
	}
	// 22       .
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e59:	83 ec 08             	sub    $0x8,%esp
f0100e5c:	56                   	push   %esi
f0100e5d:	83 ec 04             	sub    $0x4,%esp
f0100e60:	ff 75 dc             	pushl  -0x24(%ebp)
f0100e63:	ff 75 d8             	pushl  -0x28(%ebp)
f0100e66:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e69:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e6c:	e8 9f 0c 00 00       	call   f0101b10 <__umoddi3>
f0100e71:	83 c4 14             	add    $0x14,%esp
f0100e74:	0f be 80 fd 21 10 f0 	movsbl -0xfefde03(%eax),%eax
f0100e7b:	50                   	push   %eax
f0100e7c:	ff d7                	call   *%edi
f0100e7e:	83 c4 10             	add    $0x10,%esp
f0100e81:	e9 b3 00 00 00       	jmp    f0100f39 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e86:	83 ec 0c             	sub    $0xc,%esp
f0100e89:	ff 75 18             	pushl  0x18(%ebp)
f0100e8c:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100e8f:	50                   	push   %eax
f0100e90:	ff 75 10             	pushl  0x10(%ebp)
f0100e93:	83 ec 08             	sub    $0x8,%esp
f0100e96:	ff 75 dc             	pushl  -0x24(%ebp)
f0100e99:	ff 75 d8             	pushl  -0x28(%ebp)
f0100e9c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e9f:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ea2:	e8 39 0b 00 00       	call   f01019e0 <__udivdi3>
f0100ea7:	83 c4 18             	add    $0x18,%esp
f0100eaa:	52                   	push   %edx
f0100eab:	50                   	push   %eax
f0100eac:	89 f2                	mov    %esi,%edx
f0100eae:	89 f8                	mov    %edi,%eax
f0100eb0:	e8 71 fe ff ff       	call   f0100d26 <printnum>
				putch(padc, putdat);
		}
	}
	// 22       .
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100eb5:	83 c4 18             	add    $0x18,%esp
f0100eb8:	56                   	push   %esi
f0100eb9:	83 ec 04             	sub    $0x4,%esp
f0100ebc:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ebf:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ec2:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ec5:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ec8:	e8 43 0c 00 00       	call   f0101b10 <__umoddi3>
f0100ecd:	83 c4 14             	add    $0x14,%esp
f0100ed0:	0f be 80 fd 21 10 f0 	movsbl -0xfefde03(%eax),%eax
f0100ed7:	50                   	push   %eax
f0100ed8:	ff d7                	call   *%edi
f0100eda:	83 c4 10             	add    $0x10,%esp
f0100edd:	e9 d5 fe ff ff       	jmp    f0100db7 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ee2:	83 ec 0c             	sub    $0xc,%esp
f0100ee5:	ff 75 18             	pushl  0x18(%ebp)
f0100ee8:	83 eb 01             	sub    $0x1,%ebx
f0100eeb:	53                   	push   %ebx
f0100eec:	ff 75 10             	pushl  0x10(%ebp)
f0100eef:	83 ec 08             	sub    $0x8,%esp
f0100ef2:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ef5:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ef8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100efb:	ff 75 e0             	pushl  -0x20(%ebp)
f0100efe:	e8 dd 0a 00 00       	call   f01019e0 <__udivdi3>
f0100f03:	83 c4 18             	add    $0x18,%esp
f0100f06:	52                   	push   %edx
f0100f07:	50                   	push   %eax
f0100f08:	89 f2                	mov    %esi,%edx
f0100f0a:	89 f8                	mov    %edi,%eax
f0100f0c:	e8 15 fe ff ff       	call   f0100d26 <printnum>
				putch(padc, putdat);
		}
	}
	// 22       .
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f11:	83 c4 18             	add    $0x18,%esp
f0100f14:	56                   	push   %esi
f0100f15:	83 ec 04             	sub    $0x4,%esp
f0100f18:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f1b:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f1e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f21:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f24:	e8 e7 0b 00 00       	call   f0101b10 <__umoddi3>
f0100f29:	83 c4 14             	add    $0x14,%esp
f0100f2c:	0f be 80 fd 21 10 f0 	movsbl -0xfefde03(%eax),%eax
f0100f33:	50                   	push   %eax
f0100f34:	ff d7                	call   *%edi
f0100f36:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
f0100f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f3c:	5b                   	pop    %ebx
f0100f3d:	5e                   	pop    %esi
f0100f3e:	5f                   	pop    %edi
f0100f3f:	5d                   	pop    %ebp
f0100f40:	c3                   	ret    

f0100f41 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100f41:	55                   	push   %ebp
f0100f42:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100f44:	83 fa 01             	cmp    $0x1,%edx
f0100f47:	7e 0e                	jle    f0100f57 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100f49:	8b 10                	mov    (%eax),%edx
f0100f4b:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100f4e:	89 08                	mov    %ecx,(%eax)
f0100f50:	8b 02                	mov    (%edx),%eax
f0100f52:	8b 52 04             	mov    0x4(%edx),%edx
f0100f55:	eb 22                	jmp    f0100f79 <getuint+0x38>
	else if (lflag)
f0100f57:	85 d2                	test   %edx,%edx
f0100f59:	74 10                	je     f0100f6b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100f5b:	8b 10                	mov    (%eax),%edx
f0100f5d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f60:	89 08                	mov    %ecx,(%eax)
f0100f62:	8b 02                	mov    (%edx),%eax
f0100f64:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f69:	eb 0e                	jmp    f0100f79 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100f6b:	8b 10                	mov    (%eax),%edx
f0100f6d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100f70:	89 08                	mov    %ecx,(%eax)
f0100f72:	8b 02                	mov    (%edx),%eax
f0100f74:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100f79:	5d                   	pop    %ebp
f0100f7a:	c3                   	ret    

f0100f7b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f7b:	55                   	push   %ebp
f0100f7c:	89 e5                	mov    %esp,%ebp
f0100f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f81:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f85:	8b 10                	mov    (%eax),%edx
f0100f87:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f8a:	73 0a                	jae    f0100f96 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f8c:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f8f:	89 08                	mov    %ecx,(%eax)
f0100f91:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f94:	88 02                	mov    %al,(%edx)
}
f0100f96:	5d                   	pop    %ebp
f0100f97:	c3                   	ret    

f0100f98 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100f98:	55                   	push   %ebp
f0100f99:	89 e5                	mov    %esp,%ebp
f0100f9b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100f9e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100fa1:	50                   	push   %eax
f0100fa2:	ff 75 10             	pushl  0x10(%ebp)
f0100fa5:	ff 75 0c             	pushl  0xc(%ebp)
f0100fa8:	ff 75 08             	pushl  0x8(%ebp)
f0100fab:	e8 05 00 00 00       	call   f0100fb5 <vprintfmt>
	va_end(ap);
}
f0100fb0:	83 c4 10             	add    $0x10,%esp
f0100fb3:	c9                   	leave  
f0100fb4:	c3                   	ret    

f0100fb5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100fb5:	55                   	push   %ebp
f0100fb6:	89 e5                	mov    %esp,%ebp
f0100fb8:	57                   	push   %edi
f0100fb9:	56                   	push   %esi
f0100fba:	53                   	push   %ebx
f0100fbb:	83 ec 2c             	sub    $0x2c,%esp
f0100fbe:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100fc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fc4:	eb 03                	jmp    f0100fc9 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100fc6:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100fc9:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fcc:	8d 70 01             	lea    0x1(%eax),%esi
f0100fcf:	0f b6 00             	movzbl (%eax),%eax
f0100fd2:	83 f8 25             	cmp    $0x25,%eax
f0100fd5:	74 27                	je     f0100ffe <vprintfmt+0x49>
			if (ch == '\0')
f0100fd7:	85 c0                	test   %eax,%eax
f0100fd9:	75 0d                	jne    f0100fe8 <vprintfmt+0x33>
f0100fdb:	e9 98 04 00 00       	jmp    f0101478 <vprintfmt+0x4c3>
f0100fe0:	85 c0                	test   %eax,%eax
f0100fe2:	0f 84 90 04 00 00    	je     f0101478 <vprintfmt+0x4c3>
				return;
			putch(ch, putdat);
f0100fe8:	83 ec 08             	sub    $0x8,%esp
f0100feb:	53                   	push   %ebx
f0100fec:	50                   	push   %eax
f0100fed:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100fef:	83 c6 01             	add    $0x1,%esi
f0100ff2:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0100ff6:	83 c4 10             	add    $0x10,%esp
f0100ff9:	83 f8 25             	cmp    $0x25,%eax
f0100ffc:	75 e2                	jne    f0100fe0 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100ffe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101003:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f0101007:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010100e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101015:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010101c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0101023:	eb 08                	jmp    f010102d <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101025:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
f0101028:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010102d:	8d 46 01             	lea    0x1(%esi),%eax
f0101030:	89 45 10             	mov    %eax,0x10(%ebp)
f0101033:	0f b6 06             	movzbl (%esi),%eax
f0101036:	0f b6 d0             	movzbl %al,%edx
f0101039:	83 e8 23             	sub    $0x23,%eax
f010103c:	3c 55                	cmp    $0x55,%al
f010103e:	0f 87 f5 03 00 00    	ja     f0101439 <vprintfmt+0x484>
f0101044:	0f b6 c0             	movzbl %al,%eax
f0101047:	ff 24 85 08 23 10 f0 	jmp    *-0xfefdcf8(,%eax,4)
f010104e:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f0101051:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f0101055:	eb d6                	jmp    f010102d <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101057:	8d 42 d0             	lea    -0x30(%edx),%eax
f010105a:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f010105d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0101061:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101064:	83 fa 09             	cmp    $0x9,%edx
f0101067:	77 6b                	ja     f01010d4 <vprintfmt+0x11f>
f0101069:	8b 75 10             	mov    0x10(%ebp),%esi
f010106c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010106f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101072:	eb 09                	jmp    f010107d <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101074:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101077:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f010107b:	eb b0                	jmp    f010102d <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010107d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0101080:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101083:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0101087:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010108a:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010108d:	83 f9 09             	cmp    $0x9,%ecx
f0101090:	76 eb                	jbe    f010107d <vprintfmt+0xc8>
f0101092:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101095:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101098:	eb 3d                	jmp    f01010d7 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010109a:	8b 45 14             	mov    0x14(%ebp),%eax
f010109d:	8d 50 04             	lea    0x4(%eax),%edx
f01010a0:	89 55 14             	mov    %edx,0x14(%ebp)
f01010a3:	8b 00                	mov    (%eax),%eax
f01010a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010a8:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01010ab:	eb 2a                	jmp    f01010d7 <vprintfmt+0x122>
f01010ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010b0:	85 c0                	test   %eax,%eax
f01010b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01010b7:	0f 49 d0             	cmovns %eax,%edx
f01010ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010bd:	8b 75 10             	mov    0x10(%ebp),%esi
f01010c0:	e9 68 ff ff ff       	jmp    f010102d <vprintfmt+0x78>
f01010c5:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01010c8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01010cf:	e9 59 ff ff ff       	jmp    f010102d <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010d4:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01010d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01010db:	0f 89 4c ff ff ff    	jns    f010102d <vprintfmt+0x78>
				width = precision, precision = -1;
f01010e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01010e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01010ee:	e9 3a ff ff ff       	jmp    f010102d <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01010f3:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010f7:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01010fa:	e9 2e ff ff ff       	jmp    f010102d <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01010ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0101102:	8d 50 04             	lea    0x4(%eax),%edx
f0101105:	89 55 14             	mov    %edx,0x14(%ebp)
f0101108:	83 ec 08             	sub    $0x8,%esp
f010110b:	53                   	push   %ebx
f010110c:	ff 30                	pushl  (%eax)
f010110e:	ff d7                	call   *%edi
			break;
f0101110:	83 c4 10             	add    $0x10,%esp
f0101113:	e9 b1 fe ff ff       	jmp    f0100fc9 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101118:	8b 45 14             	mov    0x14(%ebp),%eax
f010111b:	8d 50 04             	lea    0x4(%eax),%edx
f010111e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101121:	8b 00                	mov    (%eax),%eax
f0101123:	99                   	cltd   
f0101124:	31 d0                	xor    %edx,%eax
f0101126:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101128:	83 f8 06             	cmp    $0x6,%eax
f010112b:	7f 0b                	jg     f0101138 <vprintfmt+0x183>
f010112d:	8b 14 85 60 24 10 f0 	mov    -0xfefdba0(,%eax,4),%edx
f0101134:	85 d2                	test   %edx,%edx
f0101136:	75 15                	jne    f010114d <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
f0101138:	50                   	push   %eax
f0101139:	68 15 22 10 f0       	push   $0xf0102215
f010113e:	53                   	push   %ebx
f010113f:	57                   	push   %edi
f0101140:	e8 53 fe ff ff       	call   f0100f98 <printfmt>
f0101145:	83 c4 10             	add    $0x10,%esp
f0101148:	e9 7c fe ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f010114d:	52                   	push   %edx
f010114e:	68 1e 22 10 f0       	push   $0xf010221e
f0101153:	53                   	push   %ebx
f0101154:	57                   	push   %edi
f0101155:	e8 3e fe ff ff       	call   f0100f98 <printfmt>
f010115a:	83 c4 10             	add    $0x10,%esp
f010115d:	e9 67 fe ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101162:	8b 45 14             	mov    0x14(%ebp),%eax
f0101165:	8d 50 04             	lea    0x4(%eax),%edx
f0101168:	89 55 14             	mov    %edx,0x14(%ebp)
f010116b:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f010116d:	85 c0                	test   %eax,%eax
f010116f:	b9 0e 22 10 f0       	mov    $0xf010220e,%ecx
f0101174:	0f 45 c8             	cmovne %eax,%ecx
f0101177:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010117a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010117e:	7e 06                	jle    f0101186 <vprintfmt+0x1d1>
f0101180:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0101184:	75 19                	jne    f010119f <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101186:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101189:	8d 70 01             	lea    0x1(%eax),%esi
f010118c:	0f b6 00             	movzbl (%eax),%eax
f010118f:	0f be d0             	movsbl %al,%edx
f0101192:	85 d2                	test   %edx,%edx
f0101194:	0f 85 9f 00 00 00    	jne    f0101239 <vprintfmt+0x284>
f010119a:	e9 8c 00 00 00       	jmp    f010122b <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010119f:	83 ec 08             	sub    $0x8,%esp
f01011a2:	ff 75 d0             	pushl  -0x30(%ebp)
f01011a5:	ff 75 cc             	pushl  -0x34(%ebp)
f01011a8:	e8 36 04 00 00       	call   f01015e3 <strnlen>
f01011ad:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f01011b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01011b3:	83 c4 10             	add    $0x10,%esp
f01011b6:	85 c9                	test   %ecx,%ecx
f01011b8:	0f 8e a1 02 00 00    	jle    f010145f <vprintfmt+0x4aa>
					putch(padc, putdat);
f01011be:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f01011c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01011c5:	89 cb                	mov    %ecx,%ebx
f01011c7:	83 ec 08             	sub    $0x8,%esp
f01011ca:	ff 75 0c             	pushl  0xc(%ebp)
f01011cd:	56                   	push   %esi
f01011ce:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01011d0:	83 c4 10             	add    $0x10,%esp
f01011d3:	83 eb 01             	sub    $0x1,%ebx
f01011d6:	75 ef                	jne    f01011c7 <vprintfmt+0x212>
f01011d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01011db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011de:	e9 7c 02 00 00       	jmp    f010145f <vprintfmt+0x4aa>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01011e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011e7:	74 1b                	je     f0101204 <vprintfmt+0x24f>
f01011e9:	0f be c0             	movsbl %al,%eax
f01011ec:	83 e8 20             	sub    $0x20,%eax
f01011ef:	83 f8 5e             	cmp    $0x5e,%eax
f01011f2:	76 10                	jbe    f0101204 <vprintfmt+0x24f>
					putch('?', putdat);
f01011f4:	83 ec 08             	sub    $0x8,%esp
f01011f7:	ff 75 0c             	pushl  0xc(%ebp)
f01011fa:	6a 3f                	push   $0x3f
f01011fc:	ff 55 08             	call   *0x8(%ebp)
f01011ff:	83 c4 10             	add    $0x10,%esp
f0101202:	eb 0d                	jmp    f0101211 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
f0101204:	83 ec 08             	sub    $0x8,%esp
f0101207:	ff 75 0c             	pushl  0xc(%ebp)
f010120a:	52                   	push   %edx
f010120b:	ff 55 08             	call   *0x8(%ebp)
f010120e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101211:	83 ef 01             	sub    $0x1,%edi
f0101214:	83 c6 01             	add    $0x1,%esi
f0101217:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f010121b:	0f be d0             	movsbl %al,%edx
f010121e:	85 d2                	test   %edx,%edx
f0101220:	75 31                	jne    f0101253 <vprintfmt+0x29e>
f0101222:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0101225:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101228:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010122b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010122e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101232:	7f 33                	jg     f0101267 <vprintfmt+0x2b2>
f0101234:	e9 90 fd ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
f0101239:	89 7d 08             	mov    %edi,0x8(%ebp)
f010123c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010123f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101242:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101245:	eb 0c                	jmp    f0101253 <vprintfmt+0x29e>
f0101247:	89 7d 08             	mov    %edi,0x8(%ebp)
f010124a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010124d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101250:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101253:	85 db                	test   %ebx,%ebx
f0101255:	78 8c                	js     f01011e3 <vprintfmt+0x22e>
f0101257:	83 eb 01             	sub    $0x1,%ebx
f010125a:	79 87                	jns    f01011e3 <vprintfmt+0x22e>
f010125c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010125f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101262:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101265:	eb c4                	jmp    f010122b <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101267:	83 ec 08             	sub    $0x8,%esp
f010126a:	53                   	push   %ebx
f010126b:	6a 20                	push   $0x20
f010126d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010126f:	83 c4 10             	add    $0x10,%esp
f0101272:	83 ee 01             	sub    $0x1,%esi
f0101275:	75 f0                	jne    f0101267 <vprintfmt+0x2b2>
f0101277:	e9 4d fd ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010127c:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f0101280:	7e 16                	jle    f0101298 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
f0101282:	8b 45 14             	mov    0x14(%ebp),%eax
f0101285:	8d 50 08             	lea    0x8(%eax),%edx
f0101288:	89 55 14             	mov    %edx,0x14(%ebp)
f010128b:	8b 50 04             	mov    0x4(%eax),%edx
f010128e:	8b 00                	mov    (%eax),%eax
f0101290:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101293:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101296:	eb 34                	jmp    f01012cc <vprintfmt+0x317>
	else if (lflag)
f0101298:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f010129c:	74 18                	je     f01012b6 <vprintfmt+0x301>
		return va_arg(*ap, long);
f010129e:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a1:	8d 50 04             	lea    0x4(%eax),%edx
f01012a4:	89 55 14             	mov    %edx,0x14(%ebp)
f01012a7:	8b 30                	mov    (%eax),%esi
f01012a9:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01012ac:	89 f0                	mov    %esi,%eax
f01012ae:	c1 f8 1f             	sar    $0x1f,%eax
f01012b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012b4:	eb 16                	jmp    f01012cc <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
f01012b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b9:	8d 50 04             	lea    0x4(%eax),%edx
f01012bc:	89 55 14             	mov    %edx,0x14(%ebp)
f01012bf:	8b 30                	mov    (%eax),%esi
f01012c1:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01012c4:	89 f0                	mov    %esi,%eax
f01012c6:	c1 f8 1f             	sar    $0x1f,%eax
f01012c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01012cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01012cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01012d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f01012d8:	85 d2                	test   %edx,%edx
f01012da:	79 28                	jns    f0101304 <vprintfmt+0x34f>
				putch('-', putdat);
f01012dc:	83 ec 08             	sub    $0x8,%esp
f01012df:	53                   	push   %ebx
f01012e0:	6a 2d                	push   $0x2d
f01012e2:	ff d7                	call   *%edi
				num = -(long long) num;
f01012e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01012e7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01012ea:	f7 d8                	neg    %eax
f01012ec:	83 d2 00             	adc    $0x0,%edx
f01012ef:	f7 da                	neg    %edx
f01012f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012f7:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
f01012fa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012ff:	e9 b2 00 00 00       	jmp    f01013b6 <vprintfmt+0x401>
f0101304:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
f0101309:	85 c9                	test   %ecx,%ecx
f010130b:	0f 84 a5 00 00 00    	je     f01013b6 <vprintfmt+0x401>
				putch('+', putdat);
f0101311:	83 ec 08             	sub    $0x8,%esp
f0101314:	53                   	push   %ebx
f0101315:	6a 2b                	push   $0x2b
f0101317:	ff d7                	call   *%edi
f0101319:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
f010131c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101321:	e9 90 00 00 00       	jmp    f01013b6 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
f0101326:	85 c9                	test   %ecx,%ecx
f0101328:	74 0b                	je     f0101335 <vprintfmt+0x380>
				putch('+', putdat);
f010132a:	83 ec 08             	sub    $0x8,%esp
f010132d:	53                   	push   %ebx
f010132e:	6a 2b                	push   $0x2b
f0101330:	ff d7                	call   *%edi
f0101332:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
f0101335:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101338:	8d 45 14             	lea    0x14(%ebp),%eax
f010133b:	e8 01 fc ff ff       	call   f0100f41 <getuint>
f0101340:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101343:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0101346:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010134b:	eb 69                	jmp    f01013b6 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
f010134d:	83 ec 08             	sub    $0x8,%esp
f0101350:	53                   	push   %ebx
f0101351:	6a 30                	push   $0x30
f0101353:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f0101355:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101358:	8d 45 14             	lea    0x14(%ebp),%eax
f010135b:	e8 e1 fb ff ff       	call   f0100f41 <getuint>
f0101360:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101363:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f0101366:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0101369:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f010136e:	eb 46                	jmp    f01013b6 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
f0101370:	83 ec 08             	sub    $0x8,%esp
f0101373:	53                   	push   %ebx
f0101374:	6a 30                	push   $0x30
f0101376:	ff d7                	call   *%edi
			putch('x', putdat);
f0101378:	83 c4 08             	add    $0x8,%esp
f010137b:	53                   	push   %ebx
f010137c:	6a 78                	push   $0x78
f010137e:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101380:	8b 45 14             	mov    0x14(%ebp),%eax
f0101383:	8d 50 04             	lea    0x4(%eax),%edx
f0101386:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101389:	8b 00                	mov    (%eax),%eax
f010138b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101390:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101393:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101396:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101399:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010139e:	eb 16                	jmp    f01013b6 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01013a0:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01013a3:	8d 45 14             	lea    0x14(%ebp),%eax
f01013a6:	e8 96 fb ff ff       	call   f0100f41 <getuint>
f01013ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f01013b1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01013b6:	83 ec 0c             	sub    $0xc,%esp
f01013b9:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f01013bd:	56                   	push   %esi
f01013be:	ff 75 e4             	pushl  -0x1c(%ebp)
f01013c1:	50                   	push   %eax
f01013c2:	ff 75 dc             	pushl  -0x24(%ebp)
f01013c5:	ff 75 d8             	pushl  -0x28(%ebp)
f01013c8:	89 da                	mov    %ebx,%edx
f01013ca:	89 f8                	mov    %edi,%eax
f01013cc:	e8 55 f9 ff ff       	call   f0100d26 <printnum>
			break;
f01013d1:	83 c4 20             	add    $0x20,%esp
f01013d4:	e9 f0 fb ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
						// cprintf("n: %d\n", *(char *)putdat);
						char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
f01013d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01013dc:	8d 50 04             	lea    0x4(%eax),%edx
f01013df:	89 55 14             	mov    %edx,0x14(%ebp)
f01013e2:	8b 00                	mov    (%eax),%eax
						if (!tmp) {
f01013e4:	85 c0                	test   %eax,%eax
f01013e6:	75 1a                	jne    f0101402 <vprintfmt+0x44d>
							cprintf("%s", null_error);
f01013e8:	83 ec 08             	sub    $0x8,%esp
f01013eb:	68 8c 22 10 f0       	push   $0xf010228c
f01013f0:	68 1e 22 10 f0       	push   $0xf010221e
f01013f5:	e8 eb f5 ff ff       	call   f01009e5 <cprintf>
f01013fa:	83 c4 10             	add    $0x10,%esp
f01013fd:	e9 c7 fb ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
						} else if ((*(char *)putdat) & 0x80) {
f0101402:	0f b6 13             	movzbl (%ebx),%edx
f0101405:	84 d2                	test   %dl,%dl
f0101407:	79 1a                	jns    f0101423 <vprintfmt+0x46e>
							cprintf("%s", overflow_error);
f0101409:	83 ec 08             	sub    $0x8,%esp
f010140c:	68 c4 22 10 f0       	push   $0xf01022c4
f0101411:	68 1e 22 10 f0       	push   $0xf010221e
f0101416:	e8 ca f5 ff ff       	call   f01009e5 <cprintf>
f010141b:	83 c4 10             	add    $0x10,%esp
f010141e:	e9 a6 fb ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
						} else {
							*tmp = *(char *)putdat;
f0101423:	88 10                	mov    %dl,(%eax)
f0101425:	e9 9f fb ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010142a:	83 ec 08             	sub    $0x8,%esp
f010142d:	53                   	push   %ebx
f010142e:	52                   	push   %edx
f010142f:	ff d7                	call   *%edi
			break;
f0101431:	83 c4 10             	add    $0x10,%esp
f0101434:	e9 90 fb ff ff       	jmp    f0100fc9 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101439:	83 ec 08             	sub    $0x8,%esp
f010143c:	53                   	push   %ebx
f010143d:	6a 25                	push   $0x25
f010143f:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101441:	83 c4 10             	add    $0x10,%esp
f0101444:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101448:	0f 84 78 fb ff ff    	je     f0100fc6 <vprintfmt+0x11>
f010144e:	83 ee 01             	sub    $0x1,%esi
f0101451:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101455:	75 f7                	jne    f010144e <vprintfmt+0x499>
f0101457:	89 75 10             	mov    %esi,0x10(%ebp)
f010145a:	e9 6a fb ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010145f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101462:	8d 70 01             	lea    0x1(%eax),%esi
f0101465:	0f b6 00             	movzbl (%eax),%eax
f0101468:	0f be d0             	movsbl %al,%edx
f010146b:	85 d2                	test   %edx,%edx
f010146d:	0f 85 d4 fd ff ff    	jne    f0101247 <vprintfmt+0x292>
f0101473:	e9 51 fb ff ff       	jmp    f0100fc9 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0101478:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010147b:	5b                   	pop    %ebx
f010147c:	5e                   	pop    %esi
f010147d:	5f                   	pop    %edi
f010147e:	5d                   	pop    %ebp
f010147f:	c3                   	ret    

f0101480 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101480:	55                   	push   %ebp
f0101481:	89 e5                	mov    %esp,%ebp
f0101483:	83 ec 18             	sub    $0x18,%esp
f0101486:	8b 45 08             	mov    0x8(%ebp),%eax
f0101489:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010148c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010148f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101493:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101496:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010149d:	85 c0                	test   %eax,%eax
f010149f:	74 26                	je     f01014c7 <vsnprintf+0x47>
f01014a1:	85 d2                	test   %edx,%edx
f01014a3:	7e 22                	jle    f01014c7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014a5:	ff 75 14             	pushl  0x14(%ebp)
f01014a8:	ff 75 10             	pushl  0x10(%ebp)
f01014ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014ae:	50                   	push   %eax
f01014af:	68 7b 0f 10 f0       	push   $0xf0100f7b
f01014b4:	e8 fc fa ff ff       	call   f0100fb5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01014bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014c2:	83 c4 10             	add    $0x10,%esp
f01014c5:	eb 05                	jmp    f01014cc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01014c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01014cc:	c9                   	leave  
f01014cd:	c3                   	ret    

f01014ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014ce:	55                   	push   %ebp
f01014cf:	89 e5                	mov    %esp,%ebp
f01014d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014d7:	50                   	push   %eax
f01014d8:	ff 75 10             	pushl  0x10(%ebp)
f01014db:	ff 75 0c             	pushl  0xc(%ebp)
f01014de:	ff 75 08             	pushl  0x8(%ebp)
f01014e1:	e8 9a ff ff ff       	call   f0101480 <vsnprintf>
	va_end(ap);

	return rc;
}
f01014e6:	c9                   	leave  
f01014e7:	c3                   	ret    

f01014e8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014e8:	55                   	push   %ebp
f01014e9:	89 e5                	mov    %esp,%ebp
f01014eb:	57                   	push   %edi
f01014ec:	56                   	push   %esi
f01014ed:	53                   	push   %ebx
f01014ee:	83 ec 0c             	sub    $0xc,%esp
f01014f1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014f4:	85 c0                	test   %eax,%eax
f01014f6:	74 11                	je     f0101509 <readline+0x21>
		cprintf("%s", prompt);
f01014f8:	83 ec 08             	sub    $0x8,%esp
f01014fb:	50                   	push   %eax
f01014fc:	68 1e 22 10 f0       	push   $0xf010221e
f0101501:	e8 df f4 ff ff       	call   f01009e5 <cprintf>
f0101506:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101509:	83 ec 0c             	sub    $0xc,%esp
f010150c:	6a 00                	push   $0x0
f010150e:	e8 28 f2 ff ff       	call   f010073b <iscons>
f0101513:	89 c7                	mov    %eax,%edi
f0101515:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101518:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010151d:	e8 08 f2 ff ff       	call   f010072a <getchar>
f0101522:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101524:	85 c0                	test   %eax,%eax
f0101526:	79 18                	jns    f0101540 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101528:	83 ec 08             	sub    $0x8,%esp
f010152b:	50                   	push   %eax
f010152c:	68 7c 24 10 f0       	push   $0xf010247c
f0101531:	e8 af f4 ff ff       	call   f01009e5 <cprintf>
			return NULL;
f0101536:	83 c4 10             	add    $0x10,%esp
f0101539:	b8 00 00 00 00       	mov    $0x0,%eax
f010153e:	eb 79                	jmp    f01015b9 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101540:	83 f8 08             	cmp    $0x8,%eax
f0101543:	0f 94 c2             	sete   %dl
f0101546:	83 f8 7f             	cmp    $0x7f,%eax
f0101549:	0f 94 c0             	sete   %al
f010154c:	08 c2                	or     %al,%dl
f010154e:	74 1a                	je     f010156a <readline+0x82>
f0101550:	85 f6                	test   %esi,%esi
f0101552:	7e 16                	jle    f010156a <readline+0x82>
			if (echoing)
f0101554:	85 ff                	test   %edi,%edi
f0101556:	74 0d                	je     f0101565 <readline+0x7d>
				cputchar('\b');
f0101558:	83 ec 0c             	sub    $0xc,%esp
f010155b:	6a 08                	push   $0x8
f010155d:	e8 b8 f1 ff ff       	call   f010071a <cputchar>
f0101562:	83 c4 10             	add    $0x10,%esp
			i--;
f0101565:	83 ee 01             	sub    $0x1,%esi
f0101568:	eb b3                	jmp    f010151d <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010156a:	83 fb 1f             	cmp    $0x1f,%ebx
f010156d:	7e 23                	jle    f0101592 <readline+0xaa>
f010156f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101575:	7f 1b                	jg     f0101592 <readline+0xaa>
			if (echoing)
f0101577:	85 ff                	test   %edi,%edi
f0101579:	74 0c                	je     f0101587 <readline+0x9f>
				cputchar(c);
f010157b:	83 ec 0c             	sub    $0xc,%esp
f010157e:	53                   	push   %ebx
f010157f:	e8 96 f1 ff ff       	call   f010071a <cputchar>
f0101584:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101587:	88 9e 60 25 11 f0    	mov    %bl,-0xfeedaa0(%esi)
f010158d:	8d 76 01             	lea    0x1(%esi),%esi
f0101590:	eb 8b                	jmp    f010151d <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101592:	83 fb 0a             	cmp    $0xa,%ebx
f0101595:	74 05                	je     f010159c <readline+0xb4>
f0101597:	83 fb 0d             	cmp    $0xd,%ebx
f010159a:	75 81                	jne    f010151d <readline+0x35>
			if (echoing)
f010159c:	85 ff                	test   %edi,%edi
f010159e:	74 0d                	je     f01015ad <readline+0xc5>
				cputchar('\n');
f01015a0:	83 ec 0c             	sub    $0xc,%esp
f01015a3:	6a 0a                	push   $0xa
f01015a5:	e8 70 f1 ff ff       	call   f010071a <cputchar>
f01015aa:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01015ad:	c6 86 60 25 11 f0 00 	movb   $0x0,-0xfeedaa0(%esi)
			return buf;
f01015b4:	b8 60 25 11 f0       	mov    $0xf0112560,%eax
		}
	}
}
f01015b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015bc:	5b                   	pop    %ebx
f01015bd:	5e                   	pop    %esi
f01015be:	5f                   	pop    %edi
f01015bf:	5d                   	pop    %ebp
f01015c0:	c3                   	ret    

f01015c1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015c1:	55                   	push   %ebp
f01015c2:	89 e5                	mov    %esp,%ebp
f01015c4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015c7:	80 3a 00             	cmpb   $0x0,(%edx)
f01015ca:	74 10                	je     f01015dc <strlen+0x1b>
f01015cc:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01015d1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01015d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015d8:	75 f7                	jne    f01015d1 <strlen+0x10>
f01015da:	eb 05                	jmp    f01015e1 <strlen+0x20>
f01015dc:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01015e1:	5d                   	pop    %ebp
f01015e2:	c3                   	ret    

f01015e3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015e3:	55                   	push   %ebp
f01015e4:	89 e5                	mov    %esp,%ebp
f01015e6:	53                   	push   %ebx
f01015e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01015ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015ed:	85 c9                	test   %ecx,%ecx
f01015ef:	74 1c                	je     f010160d <strnlen+0x2a>
f01015f1:	80 3b 00             	cmpb   $0x0,(%ebx)
f01015f4:	74 1e                	je     f0101614 <strnlen+0x31>
f01015f6:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01015fb:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015fd:	39 ca                	cmp    %ecx,%edx
f01015ff:	74 18                	je     f0101619 <strnlen+0x36>
f0101601:	83 c2 01             	add    $0x1,%edx
f0101604:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0101609:	75 f0                	jne    f01015fb <strnlen+0x18>
f010160b:	eb 0c                	jmp    f0101619 <strnlen+0x36>
f010160d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101612:	eb 05                	jmp    f0101619 <strnlen+0x36>
f0101614:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101619:	5b                   	pop    %ebx
f010161a:	5d                   	pop    %ebp
f010161b:	c3                   	ret    

f010161c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010161c:	55                   	push   %ebp
f010161d:	89 e5                	mov    %esp,%ebp
f010161f:	53                   	push   %ebx
f0101620:	8b 45 08             	mov    0x8(%ebp),%eax
f0101623:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101626:	89 c2                	mov    %eax,%edx
f0101628:	83 c2 01             	add    $0x1,%edx
f010162b:	83 c1 01             	add    $0x1,%ecx
f010162e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101632:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101635:	84 db                	test   %bl,%bl
f0101637:	75 ef                	jne    f0101628 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101639:	5b                   	pop    %ebx
f010163a:	5d                   	pop    %ebp
f010163b:	c3                   	ret    

f010163c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010163c:	55                   	push   %ebp
f010163d:	89 e5                	mov    %esp,%ebp
f010163f:	56                   	push   %esi
f0101640:	53                   	push   %ebx
f0101641:	8b 75 08             	mov    0x8(%ebp),%esi
f0101644:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101647:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010164a:	85 db                	test   %ebx,%ebx
f010164c:	74 17                	je     f0101665 <strncpy+0x29>
f010164e:	01 f3                	add    %esi,%ebx
f0101650:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f0101652:	83 c1 01             	add    $0x1,%ecx
f0101655:	0f b6 02             	movzbl (%edx),%eax
f0101658:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010165b:	80 3a 01             	cmpb   $0x1,(%edx)
f010165e:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101661:	39 cb                	cmp    %ecx,%ebx
f0101663:	75 ed                	jne    f0101652 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101665:	89 f0                	mov    %esi,%eax
f0101667:	5b                   	pop    %ebx
f0101668:	5e                   	pop    %esi
f0101669:	5d                   	pop    %ebp
f010166a:	c3                   	ret    

f010166b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010166b:	55                   	push   %ebp
f010166c:	89 e5                	mov    %esp,%ebp
f010166e:	56                   	push   %esi
f010166f:	53                   	push   %ebx
f0101670:	8b 75 08             	mov    0x8(%ebp),%esi
f0101673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101676:	8b 55 10             	mov    0x10(%ebp),%edx
f0101679:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010167b:	85 d2                	test   %edx,%edx
f010167d:	74 35                	je     f01016b4 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f010167f:	89 d0                	mov    %edx,%eax
f0101681:	83 e8 01             	sub    $0x1,%eax
f0101684:	74 25                	je     f01016ab <strlcpy+0x40>
f0101686:	0f b6 0b             	movzbl (%ebx),%ecx
f0101689:	84 c9                	test   %cl,%cl
f010168b:	74 22                	je     f01016af <strlcpy+0x44>
f010168d:	8d 53 01             	lea    0x1(%ebx),%edx
f0101690:	01 c3                	add    %eax,%ebx
f0101692:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f0101694:	83 c0 01             	add    $0x1,%eax
f0101697:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010169a:	39 da                	cmp    %ebx,%edx
f010169c:	74 13                	je     f01016b1 <strlcpy+0x46>
f010169e:	83 c2 01             	add    $0x1,%edx
f01016a1:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f01016a5:	84 c9                	test   %cl,%cl
f01016a7:	75 eb                	jne    f0101694 <strlcpy+0x29>
f01016a9:	eb 06                	jmp    f01016b1 <strlcpy+0x46>
f01016ab:	89 f0                	mov    %esi,%eax
f01016ad:	eb 02                	jmp    f01016b1 <strlcpy+0x46>
f01016af:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01016b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016b4:	29 f0                	sub    %esi,%eax
}
f01016b6:	5b                   	pop    %ebx
f01016b7:	5e                   	pop    %esi
f01016b8:	5d                   	pop    %ebp
f01016b9:	c3                   	ret    

f01016ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016ba:	55                   	push   %ebp
f01016bb:	89 e5                	mov    %esp,%ebp
f01016bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016c3:	0f b6 01             	movzbl (%ecx),%eax
f01016c6:	84 c0                	test   %al,%al
f01016c8:	74 15                	je     f01016df <strcmp+0x25>
f01016ca:	3a 02                	cmp    (%edx),%al
f01016cc:	75 11                	jne    f01016df <strcmp+0x25>
		p++, q++;
f01016ce:	83 c1 01             	add    $0x1,%ecx
f01016d1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01016d4:	0f b6 01             	movzbl (%ecx),%eax
f01016d7:	84 c0                	test   %al,%al
f01016d9:	74 04                	je     f01016df <strcmp+0x25>
f01016db:	3a 02                	cmp    (%edx),%al
f01016dd:	74 ef                	je     f01016ce <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016df:	0f b6 c0             	movzbl %al,%eax
f01016e2:	0f b6 12             	movzbl (%edx),%edx
f01016e5:	29 d0                	sub    %edx,%eax
}
f01016e7:	5d                   	pop    %ebp
f01016e8:	c3                   	ret    

f01016e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016e9:	55                   	push   %ebp
f01016ea:	89 e5                	mov    %esp,%ebp
f01016ec:	56                   	push   %esi
f01016ed:	53                   	push   %ebx
f01016ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01016f1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016f4:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f01016f7:	85 f6                	test   %esi,%esi
f01016f9:	74 29                	je     f0101724 <strncmp+0x3b>
f01016fb:	0f b6 03             	movzbl (%ebx),%eax
f01016fe:	84 c0                	test   %al,%al
f0101700:	74 30                	je     f0101732 <strncmp+0x49>
f0101702:	3a 02                	cmp    (%edx),%al
f0101704:	75 2c                	jne    f0101732 <strncmp+0x49>
f0101706:	8d 43 01             	lea    0x1(%ebx),%eax
f0101709:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f010170b:	89 c3                	mov    %eax,%ebx
f010170d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101710:	39 c6                	cmp    %eax,%esi
f0101712:	74 17                	je     f010172b <strncmp+0x42>
f0101714:	0f b6 08             	movzbl (%eax),%ecx
f0101717:	84 c9                	test   %cl,%cl
f0101719:	74 17                	je     f0101732 <strncmp+0x49>
f010171b:	83 c0 01             	add    $0x1,%eax
f010171e:	3a 0a                	cmp    (%edx),%cl
f0101720:	74 e9                	je     f010170b <strncmp+0x22>
f0101722:	eb 0e                	jmp    f0101732 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101724:	b8 00 00 00 00       	mov    $0x0,%eax
f0101729:	eb 0f                	jmp    f010173a <strncmp+0x51>
f010172b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101730:	eb 08                	jmp    f010173a <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101732:	0f b6 03             	movzbl (%ebx),%eax
f0101735:	0f b6 12             	movzbl (%edx),%edx
f0101738:	29 d0                	sub    %edx,%eax
}
f010173a:	5b                   	pop    %ebx
f010173b:	5e                   	pop    %esi
f010173c:	5d                   	pop    %ebp
f010173d:	c3                   	ret    

f010173e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010173e:	55                   	push   %ebp
f010173f:	89 e5                	mov    %esp,%ebp
f0101741:	53                   	push   %ebx
f0101742:	8b 45 08             	mov    0x8(%ebp),%eax
f0101745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0101748:	0f b6 10             	movzbl (%eax),%edx
f010174b:	84 d2                	test   %dl,%dl
f010174d:	74 1d                	je     f010176c <strchr+0x2e>
f010174f:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f0101751:	38 d3                	cmp    %dl,%bl
f0101753:	75 06                	jne    f010175b <strchr+0x1d>
f0101755:	eb 1a                	jmp    f0101771 <strchr+0x33>
f0101757:	38 ca                	cmp    %cl,%dl
f0101759:	74 16                	je     f0101771 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010175b:	83 c0 01             	add    $0x1,%eax
f010175e:	0f b6 10             	movzbl (%eax),%edx
f0101761:	84 d2                	test   %dl,%dl
f0101763:	75 f2                	jne    f0101757 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f0101765:	b8 00 00 00 00       	mov    $0x0,%eax
f010176a:	eb 05                	jmp    f0101771 <strchr+0x33>
f010176c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101771:	5b                   	pop    %ebx
f0101772:	5d                   	pop    %ebp
f0101773:	c3                   	ret    

f0101774 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101774:	55                   	push   %ebp
f0101775:	89 e5                	mov    %esp,%ebp
f0101777:	53                   	push   %ebx
f0101778:	8b 45 08             	mov    0x8(%ebp),%eax
f010177b:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f010177e:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f0101781:	38 d3                	cmp    %dl,%bl
f0101783:	74 14                	je     f0101799 <strfind+0x25>
f0101785:	89 d1                	mov    %edx,%ecx
f0101787:	84 db                	test   %bl,%bl
f0101789:	74 0e                	je     f0101799 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010178b:	83 c0 01             	add    $0x1,%eax
f010178e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101791:	38 ca                	cmp    %cl,%dl
f0101793:	74 04                	je     f0101799 <strfind+0x25>
f0101795:	84 d2                	test   %dl,%dl
f0101797:	75 f2                	jne    f010178b <strfind+0x17>
			break;
	return (char *) s;
}
f0101799:	5b                   	pop    %ebx
f010179a:	5d                   	pop    %ebp
f010179b:	c3                   	ret    

f010179c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010179c:	55                   	push   %ebp
f010179d:	89 e5                	mov    %esp,%ebp
f010179f:	57                   	push   %edi
f01017a0:	56                   	push   %esi
f01017a1:	53                   	push   %ebx
f01017a2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01017a8:	85 c9                	test   %ecx,%ecx
f01017aa:	74 36                	je     f01017e2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01017ac:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01017b2:	75 28                	jne    f01017dc <memset+0x40>
f01017b4:	f6 c1 03             	test   $0x3,%cl
f01017b7:	75 23                	jne    f01017dc <memset+0x40>
		c &= 0xFF;
f01017b9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01017bd:	89 d3                	mov    %edx,%ebx
f01017bf:	c1 e3 08             	shl    $0x8,%ebx
f01017c2:	89 d6                	mov    %edx,%esi
f01017c4:	c1 e6 18             	shl    $0x18,%esi
f01017c7:	89 d0                	mov    %edx,%eax
f01017c9:	c1 e0 10             	shl    $0x10,%eax
f01017cc:	09 f0                	or     %esi,%eax
f01017ce:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01017d0:	89 d8                	mov    %ebx,%eax
f01017d2:	09 d0                	or     %edx,%eax
f01017d4:	c1 e9 02             	shr    $0x2,%ecx
f01017d7:	fc                   	cld    
f01017d8:	f3 ab                	rep stos %eax,%es:(%edi)
f01017da:	eb 06                	jmp    f01017e2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01017dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017df:	fc                   	cld    
f01017e0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01017e2:	89 f8                	mov    %edi,%eax
f01017e4:	5b                   	pop    %ebx
f01017e5:	5e                   	pop    %esi
f01017e6:	5f                   	pop    %edi
f01017e7:	5d                   	pop    %ebp
f01017e8:	c3                   	ret    

f01017e9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01017e9:	55                   	push   %ebp
f01017ea:	89 e5                	mov    %esp,%ebp
f01017ec:	57                   	push   %edi
f01017ed:	56                   	push   %esi
f01017ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01017f1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01017f7:	39 c6                	cmp    %eax,%esi
f01017f9:	73 35                	jae    f0101830 <memmove+0x47>
f01017fb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017fe:	39 d0                	cmp    %edx,%eax
f0101800:	73 2e                	jae    f0101830 <memmove+0x47>
		s += n;
		d += n;
f0101802:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101805:	89 d6                	mov    %edx,%esi
f0101807:	09 fe                	or     %edi,%esi
f0101809:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010180f:	75 13                	jne    f0101824 <memmove+0x3b>
f0101811:	f6 c1 03             	test   $0x3,%cl
f0101814:	75 0e                	jne    f0101824 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101816:	83 ef 04             	sub    $0x4,%edi
f0101819:	8d 72 fc             	lea    -0x4(%edx),%esi
f010181c:	c1 e9 02             	shr    $0x2,%ecx
f010181f:	fd                   	std    
f0101820:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101822:	eb 09                	jmp    f010182d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101824:	83 ef 01             	sub    $0x1,%edi
f0101827:	8d 72 ff             	lea    -0x1(%edx),%esi
f010182a:	fd                   	std    
f010182b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010182d:	fc                   	cld    
f010182e:	eb 1d                	jmp    f010184d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101830:	89 f2                	mov    %esi,%edx
f0101832:	09 c2                	or     %eax,%edx
f0101834:	f6 c2 03             	test   $0x3,%dl
f0101837:	75 0f                	jne    f0101848 <memmove+0x5f>
f0101839:	f6 c1 03             	test   $0x3,%cl
f010183c:	75 0a                	jne    f0101848 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010183e:	c1 e9 02             	shr    $0x2,%ecx
f0101841:	89 c7                	mov    %eax,%edi
f0101843:	fc                   	cld    
f0101844:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101846:	eb 05                	jmp    f010184d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101848:	89 c7                	mov    %eax,%edi
f010184a:	fc                   	cld    
f010184b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010184d:	5e                   	pop    %esi
f010184e:	5f                   	pop    %edi
f010184f:	5d                   	pop    %ebp
f0101850:	c3                   	ret    

f0101851 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101851:	55                   	push   %ebp
f0101852:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101854:	ff 75 10             	pushl  0x10(%ebp)
f0101857:	ff 75 0c             	pushl  0xc(%ebp)
f010185a:	ff 75 08             	pushl  0x8(%ebp)
f010185d:	e8 87 ff ff ff       	call   f01017e9 <memmove>
}
f0101862:	c9                   	leave  
f0101863:	c3                   	ret    

f0101864 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101864:	55                   	push   %ebp
f0101865:	89 e5                	mov    %esp,%ebp
f0101867:	57                   	push   %edi
f0101868:	56                   	push   %esi
f0101869:	53                   	push   %ebx
f010186a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010186d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101870:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101873:	85 c0                	test   %eax,%eax
f0101875:	74 39                	je     f01018b0 <memcmp+0x4c>
f0101877:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f010187a:	0f b6 13             	movzbl (%ebx),%edx
f010187d:	0f b6 0e             	movzbl (%esi),%ecx
f0101880:	38 ca                	cmp    %cl,%dl
f0101882:	75 17                	jne    f010189b <memcmp+0x37>
f0101884:	b8 00 00 00 00       	mov    $0x0,%eax
f0101889:	eb 1a                	jmp    f01018a5 <memcmp+0x41>
f010188b:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f0101890:	83 c0 01             	add    $0x1,%eax
f0101893:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f0101897:	38 ca                	cmp    %cl,%dl
f0101899:	74 0a                	je     f01018a5 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f010189b:	0f b6 c2             	movzbl %dl,%eax
f010189e:	0f b6 c9             	movzbl %cl,%ecx
f01018a1:	29 c8                	sub    %ecx,%eax
f01018a3:	eb 10                	jmp    f01018b5 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018a5:	39 f8                	cmp    %edi,%eax
f01018a7:	75 e2                	jne    f010188b <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01018a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01018ae:	eb 05                	jmp    f01018b5 <memcmp+0x51>
f01018b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018b5:	5b                   	pop    %ebx
f01018b6:	5e                   	pop    %esi
f01018b7:	5f                   	pop    %edi
f01018b8:	5d                   	pop    %ebp
f01018b9:	c3                   	ret    

f01018ba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01018ba:	55                   	push   %ebp
f01018bb:	89 e5                	mov    %esp,%ebp
f01018bd:	53                   	push   %ebx
f01018be:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f01018c1:	89 d0                	mov    %edx,%eax
f01018c3:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f01018c6:	39 c2                	cmp    %eax,%edx
f01018c8:	73 1d                	jae    f01018e7 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f01018ca:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f01018ce:	0f b6 0a             	movzbl (%edx),%ecx
f01018d1:	39 d9                	cmp    %ebx,%ecx
f01018d3:	75 09                	jne    f01018de <memfind+0x24>
f01018d5:	eb 14                	jmp    f01018eb <memfind+0x31>
f01018d7:	0f b6 0a             	movzbl (%edx),%ecx
f01018da:	39 d9                	cmp    %ebx,%ecx
f01018dc:	74 11                	je     f01018ef <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01018de:	83 c2 01             	add    $0x1,%edx
f01018e1:	39 d0                	cmp    %edx,%eax
f01018e3:	75 f2                	jne    f01018d7 <memfind+0x1d>
f01018e5:	eb 0a                	jmp    f01018f1 <memfind+0x37>
f01018e7:	89 d0                	mov    %edx,%eax
f01018e9:	eb 06                	jmp    f01018f1 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f01018eb:	89 d0                	mov    %edx,%eax
f01018ed:	eb 02                	jmp    f01018f1 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01018ef:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01018f1:	5b                   	pop    %ebx
f01018f2:	5d                   	pop    %ebp
f01018f3:	c3                   	ret    

f01018f4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01018f4:	55                   	push   %ebp
f01018f5:	89 e5                	mov    %esp,%ebp
f01018f7:	57                   	push   %edi
f01018f8:	56                   	push   %esi
f01018f9:	53                   	push   %ebx
f01018fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01018fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101900:	0f b6 01             	movzbl (%ecx),%eax
f0101903:	3c 20                	cmp    $0x20,%al
f0101905:	74 04                	je     f010190b <strtol+0x17>
f0101907:	3c 09                	cmp    $0x9,%al
f0101909:	75 0e                	jne    f0101919 <strtol+0x25>
		s++;
f010190b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010190e:	0f b6 01             	movzbl (%ecx),%eax
f0101911:	3c 20                	cmp    $0x20,%al
f0101913:	74 f6                	je     f010190b <strtol+0x17>
f0101915:	3c 09                	cmp    $0x9,%al
f0101917:	74 f2                	je     f010190b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101919:	3c 2b                	cmp    $0x2b,%al
f010191b:	75 0a                	jne    f0101927 <strtol+0x33>
		s++;
f010191d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101920:	bf 00 00 00 00       	mov    $0x0,%edi
f0101925:	eb 11                	jmp    f0101938 <strtol+0x44>
f0101927:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010192c:	3c 2d                	cmp    $0x2d,%al
f010192e:	75 08                	jne    f0101938 <strtol+0x44>
		s++, neg = 1;
f0101930:	83 c1 01             	add    $0x1,%ecx
f0101933:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101938:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010193e:	75 15                	jne    f0101955 <strtol+0x61>
f0101940:	80 39 30             	cmpb   $0x30,(%ecx)
f0101943:	75 10                	jne    f0101955 <strtol+0x61>
f0101945:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101949:	75 7c                	jne    f01019c7 <strtol+0xd3>
		s += 2, base = 16;
f010194b:	83 c1 02             	add    $0x2,%ecx
f010194e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101953:	eb 16                	jmp    f010196b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0101955:	85 db                	test   %ebx,%ebx
f0101957:	75 12                	jne    f010196b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101959:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010195e:	80 39 30             	cmpb   $0x30,(%ecx)
f0101961:	75 08                	jne    f010196b <strtol+0x77>
		s++, base = 8;
f0101963:	83 c1 01             	add    $0x1,%ecx
f0101966:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010196b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101970:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101973:	0f b6 11             	movzbl (%ecx),%edx
f0101976:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101979:	89 f3                	mov    %esi,%ebx
f010197b:	80 fb 09             	cmp    $0x9,%bl
f010197e:	77 08                	ja     f0101988 <strtol+0x94>
			dig = *s - '0';
f0101980:	0f be d2             	movsbl %dl,%edx
f0101983:	83 ea 30             	sub    $0x30,%edx
f0101986:	eb 22                	jmp    f01019aa <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f0101988:	8d 72 9f             	lea    -0x61(%edx),%esi
f010198b:	89 f3                	mov    %esi,%ebx
f010198d:	80 fb 19             	cmp    $0x19,%bl
f0101990:	77 08                	ja     f010199a <strtol+0xa6>
			dig = *s - 'a' + 10;
f0101992:	0f be d2             	movsbl %dl,%edx
f0101995:	83 ea 57             	sub    $0x57,%edx
f0101998:	eb 10                	jmp    f01019aa <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f010199a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010199d:	89 f3                	mov    %esi,%ebx
f010199f:	80 fb 19             	cmp    $0x19,%bl
f01019a2:	77 16                	ja     f01019ba <strtol+0xc6>
			dig = *s - 'A' + 10;
f01019a4:	0f be d2             	movsbl %dl,%edx
f01019a7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01019aa:	3b 55 10             	cmp    0x10(%ebp),%edx
f01019ad:	7d 0b                	jge    f01019ba <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f01019af:	83 c1 01             	add    $0x1,%ecx
f01019b2:	0f af 45 10          	imul   0x10(%ebp),%eax
f01019b6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01019b8:	eb b9                	jmp    f0101973 <strtol+0x7f>

	if (endptr)
f01019ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01019be:	74 0d                	je     f01019cd <strtol+0xd9>
		*endptr = (char *) s;
f01019c0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019c3:	89 0e                	mov    %ecx,(%esi)
f01019c5:	eb 06                	jmp    f01019cd <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01019c7:	85 db                	test   %ebx,%ebx
f01019c9:	74 98                	je     f0101963 <strtol+0x6f>
f01019cb:	eb 9e                	jmp    f010196b <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01019cd:	89 c2                	mov    %eax,%edx
f01019cf:	f7 da                	neg    %edx
f01019d1:	85 ff                	test   %edi,%edi
f01019d3:	0f 45 c2             	cmovne %edx,%eax
}
f01019d6:	5b                   	pop    %ebx
f01019d7:	5e                   	pop    %esi
f01019d8:	5f                   	pop    %edi
f01019d9:	5d                   	pop    %ebp
f01019da:	c3                   	ret    
f01019db:	66 90                	xchg   %ax,%ax
f01019dd:	66 90                	xchg   %ax,%ax
f01019df:	90                   	nop

f01019e0 <__udivdi3>:
f01019e0:	55                   	push   %ebp
f01019e1:	57                   	push   %edi
f01019e2:	56                   	push   %esi
f01019e3:	53                   	push   %ebx
f01019e4:	83 ec 1c             	sub    $0x1c,%esp
f01019e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01019eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01019ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01019f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01019f7:	85 f6                	test   %esi,%esi
f01019f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01019fd:	89 ca                	mov    %ecx,%edx
f01019ff:	89 f8                	mov    %edi,%eax
f0101a01:	75 3d                	jne    f0101a40 <__udivdi3+0x60>
f0101a03:	39 cf                	cmp    %ecx,%edi
f0101a05:	0f 87 c5 00 00 00    	ja     f0101ad0 <__udivdi3+0xf0>
f0101a0b:	85 ff                	test   %edi,%edi
f0101a0d:	89 fd                	mov    %edi,%ebp
f0101a0f:	75 0b                	jne    f0101a1c <__udivdi3+0x3c>
f0101a11:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a16:	31 d2                	xor    %edx,%edx
f0101a18:	f7 f7                	div    %edi
f0101a1a:	89 c5                	mov    %eax,%ebp
f0101a1c:	89 c8                	mov    %ecx,%eax
f0101a1e:	31 d2                	xor    %edx,%edx
f0101a20:	f7 f5                	div    %ebp
f0101a22:	89 c1                	mov    %eax,%ecx
f0101a24:	89 d8                	mov    %ebx,%eax
f0101a26:	89 cf                	mov    %ecx,%edi
f0101a28:	f7 f5                	div    %ebp
f0101a2a:	89 c3                	mov    %eax,%ebx
f0101a2c:	89 d8                	mov    %ebx,%eax
f0101a2e:	89 fa                	mov    %edi,%edx
f0101a30:	83 c4 1c             	add    $0x1c,%esp
f0101a33:	5b                   	pop    %ebx
f0101a34:	5e                   	pop    %esi
f0101a35:	5f                   	pop    %edi
f0101a36:	5d                   	pop    %ebp
f0101a37:	c3                   	ret    
f0101a38:	90                   	nop
f0101a39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a40:	39 ce                	cmp    %ecx,%esi
f0101a42:	77 74                	ja     f0101ab8 <__udivdi3+0xd8>
f0101a44:	0f bd fe             	bsr    %esi,%edi
f0101a47:	83 f7 1f             	xor    $0x1f,%edi
f0101a4a:	0f 84 98 00 00 00    	je     f0101ae8 <__udivdi3+0x108>
f0101a50:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101a55:	89 f9                	mov    %edi,%ecx
f0101a57:	89 c5                	mov    %eax,%ebp
f0101a59:	29 fb                	sub    %edi,%ebx
f0101a5b:	d3 e6                	shl    %cl,%esi
f0101a5d:	89 d9                	mov    %ebx,%ecx
f0101a5f:	d3 ed                	shr    %cl,%ebp
f0101a61:	89 f9                	mov    %edi,%ecx
f0101a63:	d3 e0                	shl    %cl,%eax
f0101a65:	09 ee                	or     %ebp,%esi
f0101a67:	89 d9                	mov    %ebx,%ecx
f0101a69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a6d:	89 d5                	mov    %edx,%ebp
f0101a6f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101a73:	d3 ed                	shr    %cl,%ebp
f0101a75:	89 f9                	mov    %edi,%ecx
f0101a77:	d3 e2                	shl    %cl,%edx
f0101a79:	89 d9                	mov    %ebx,%ecx
f0101a7b:	d3 e8                	shr    %cl,%eax
f0101a7d:	09 c2                	or     %eax,%edx
f0101a7f:	89 d0                	mov    %edx,%eax
f0101a81:	89 ea                	mov    %ebp,%edx
f0101a83:	f7 f6                	div    %esi
f0101a85:	89 d5                	mov    %edx,%ebp
f0101a87:	89 c3                	mov    %eax,%ebx
f0101a89:	f7 64 24 0c          	mull   0xc(%esp)
f0101a8d:	39 d5                	cmp    %edx,%ebp
f0101a8f:	72 10                	jb     f0101aa1 <__udivdi3+0xc1>
f0101a91:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101a95:	89 f9                	mov    %edi,%ecx
f0101a97:	d3 e6                	shl    %cl,%esi
f0101a99:	39 c6                	cmp    %eax,%esi
f0101a9b:	73 07                	jae    f0101aa4 <__udivdi3+0xc4>
f0101a9d:	39 d5                	cmp    %edx,%ebp
f0101a9f:	75 03                	jne    f0101aa4 <__udivdi3+0xc4>
f0101aa1:	83 eb 01             	sub    $0x1,%ebx
f0101aa4:	31 ff                	xor    %edi,%edi
f0101aa6:	89 d8                	mov    %ebx,%eax
f0101aa8:	89 fa                	mov    %edi,%edx
f0101aaa:	83 c4 1c             	add    $0x1c,%esp
f0101aad:	5b                   	pop    %ebx
f0101aae:	5e                   	pop    %esi
f0101aaf:	5f                   	pop    %edi
f0101ab0:	5d                   	pop    %ebp
f0101ab1:	c3                   	ret    
f0101ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ab8:	31 ff                	xor    %edi,%edi
f0101aba:	31 db                	xor    %ebx,%ebx
f0101abc:	89 d8                	mov    %ebx,%eax
f0101abe:	89 fa                	mov    %edi,%edx
f0101ac0:	83 c4 1c             	add    $0x1c,%esp
f0101ac3:	5b                   	pop    %ebx
f0101ac4:	5e                   	pop    %esi
f0101ac5:	5f                   	pop    %edi
f0101ac6:	5d                   	pop    %ebp
f0101ac7:	c3                   	ret    
f0101ac8:	90                   	nop
f0101ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ad0:	89 d8                	mov    %ebx,%eax
f0101ad2:	f7 f7                	div    %edi
f0101ad4:	31 ff                	xor    %edi,%edi
f0101ad6:	89 c3                	mov    %eax,%ebx
f0101ad8:	89 d8                	mov    %ebx,%eax
f0101ada:	89 fa                	mov    %edi,%edx
f0101adc:	83 c4 1c             	add    $0x1c,%esp
f0101adf:	5b                   	pop    %ebx
f0101ae0:	5e                   	pop    %esi
f0101ae1:	5f                   	pop    %edi
f0101ae2:	5d                   	pop    %ebp
f0101ae3:	c3                   	ret    
f0101ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ae8:	39 ce                	cmp    %ecx,%esi
f0101aea:	72 0c                	jb     f0101af8 <__udivdi3+0x118>
f0101aec:	31 db                	xor    %ebx,%ebx
f0101aee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101af2:	0f 87 34 ff ff ff    	ja     f0101a2c <__udivdi3+0x4c>
f0101af8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0101afd:	e9 2a ff ff ff       	jmp    f0101a2c <__udivdi3+0x4c>
f0101b02:	66 90                	xchg   %ax,%ax
f0101b04:	66 90                	xchg   %ax,%ax
f0101b06:	66 90                	xchg   %ax,%ax
f0101b08:	66 90                	xchg   %ax,%ax
f0101b0a:	66 90                	xchg   %ax,%ax
f0101b0c:	66 90                	xchg   %ax,%ax
f0101b0e:	66 90                	xchg   %ax,%ax

f0101b10 <__umoddi3>:
f0101b10:	55                   	push   %ebp
f0101b11:	57                   	push   %edi
f0101b12:	56                   	push   %esi
f0101b13:	53                   	push   %ebx
f0101b14:	83 ec 1c             	sub    $0x1c,%esp
f0101b17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101b1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0101b1f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101b23:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b27:	85 d2                	test   %edx,%edx
f0101b29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101b2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b31:	89 f3                	mov    %esi,%ebx
f0101b33:	89 3c 24             	mov    %edi,(%esp)
f0101b36:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b3a:	75 1c                	jne    f0101b58 <__umoddi3+0x48>
f0101b3c:	39 f7                	cmp    %esi,%edi
f0101b3e:	76 50                	jbe    f0101b90 <__umoddi3+0x80>
f0101b40:	89 c8                	mov    %ecx,%eax
f0101b42:	89 f2                	mov    %esi,%edx
f0101b44:	f7 f7                	div    %edi
f0101b46:	89 d0                	mov    %edx,%eax
f0101b48:	31 d2                	xor    %edx,%edx
f0101b4a:	83 c4 1c             	add    $0x1c,%esp
f0101b4d:	5b                   	pop    %ebx
f0101b4e:	5e                   	pop    %esi
f0101b4f:	5f                   	pop    %edi
f0101b50:	5d                   	pop    %ebp
f0101b51:	c3                   	ret    
f0101b52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b58:	39 f2                	cmp    %esi,%edx
f0101b5a:	89 d0                	mov    %edx,%eax
f0101b5c:	77 52                	ja     f0101bb0 <__umoddi3+0xa0>
f0101b5e:	0f bd ea             	bsr    %edx,%ebp
f0101b61:	83 f5 1f             	xor    $0x1f,%ebp
f0101b64:	75 5a                	jne    f0101bc0 <__umoddi3+0xb0>
f0101b66:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0101b6a:	0f 82 e0 00 00 00    	jb     f0101c50 <__umoddi3+0x140>
f0101b70:	39 0c 24             	cmp    %ecx,(%esp)
f0101b73:	0f 86 d7 00 00 00    	jbe    f0101c50 <__umoddi3+0x140>
f0101b79:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101b7d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101b81:	83 c4 1c             	add    $0x1c,%esp
f0101b84:	5b                   	pop    %ebx
f0101b85:	5e                   	pop    %esi
f0101b86:	5f                   	pop    %edi
f0101b87:	5d                   	pop    %ebp
f0101b88:	c3                   	ret    
f0101b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b90:	85 ff                	test   %edi,%edi
f0101b92:	89 fd                	mov    %edi,%ebp
f0101b94:	75 0b                	jne    f0101ba1 <__umoddi3+0x91>
f0101b96:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b9b:	31 d2                	xor    %edx,%edx
f0101b9d:	f7 f7                	div    %edi
f0101b9f:	89 c5                	mov    %eax,%ebp
f0101ba1:	89 f0                	mov    %esi,%eax
f0101ba3:	31 d2                	xor    %edx,%edx
f0101ba5:	f7 f5                	div    %ebp
f0101ba7:	89 c8                	mov    %ecx,%eax
f0101ba9:	f7 f5                	div    %ebp
f0101bab:	89 d0                	mov    %edx,%eax
f0101bad:	eb 99                	jmp    f0101b48 <__umoddi3+0x38>
f0101baf:	90                   	nop
f0101bb0:	89 c8                	mov    %ecx,%eax
f0101bb2:	89 f2                	mov    %esi,%edx
f0101bb4:	83 c4 1c             	add    $0x1c,%esp
f0101bb7:	5b                   	pop    %ebx
f0101bb8:	5e                   	pop    %esi
f0101bb9:	5f                   	pop    %edi
f0101bba:	5d                   	pop    %ebp
f0101bbb:	c3                   	ret    
f0101bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bc0:	8b 34 24             	mov    (%esp),%esi
f0101bc3:	bf 20 00 00 00       	mov    $0x20,%edi
f0101bc8:	89 e9                	mov    %ebp,%ecx
f0101bca:	29 ef                	sub    %ebp,%edi
f0101bcc:	d3 e0                	shl    %cl,%eax
f0101bce:	89 f9                	mov    %edi,%ecx
f0101bd0:	89 f2                	mov    %esi,%edx
f0101bd2:	d3 ea                	shr    %cl,%edx
f0101bd4:	89 e9                	mov    %ebp,%ecx
f0101bd6:	09 c2                	or     %eax,%edx
f0101bd8:	89 d8                	mov    %ebx,%eax
f0101bda:	89 14 24             	mov    %edx,(%esp)
f0101bdd:	89 f2                	mov    %esi,%edx
f0101bdf:	d3 e2                	shl    %cl,%edx
f0101be1:	89 f9                	mov    %edi,%ecx
f0101be3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101be7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101beb:	d3 e8                	shr    %cl,%eax
f0101bed:	89 e9                	mov    %ebp,%ecx
f0101bef:	89 c6                	mov    %eax,%esi
f0101bf1:	d3 e3                	shl    %cl,%ebx
f0101bf3:	89 f9                	mov    %edi,%ecx
f0101bf5:	89 d0                	mov    %edx,%eax
f0101bf7:	d3 e8                	shr    %cl,%eax
f0101bf9:	89 e9                	mov    %ebp,%ecx
f0101bfb:	09 d8                	or     %ebx,%eax
f0101bfd:	89 d3                	mov    %edx,%ebx
f0101bff:	89 f2                	mov    %esi,%edx
f0101c01:	f7 34 24             	divl   (%esp)
f0101c04:	89 d6                	mov    %edx,%esi
f0101c06:	d3 e3                	shl    %cl,%ebx
f0101c08:	f7 64 24 04          	mull   0x4(%esp)
f0101c0c:	39 d6                	cmp    %edx,%esi
f0101c0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101c12:	89 d1                	mov    %edx,%ecx
f0101c14:	89 c3                	mov    %eax,%ebx
f0101c16:	72 08                	jb     f0101c20 <__umoddi3+0x110>
f0101c18:	75 11                	jne    f0101c2b <__umoddi3+0x11b>
f0101c1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101c1e:	73 0b                	jae    f0101c2b <__umoddi3+0x11b>
f0101c20:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101c24:	1b 14 24             	sbb    (%esp),%edx
f0101c27:	89 d1                	mov    %edx,%ecx
f0101c29:	89 c3                	mov    %eax,%ebx
f0101c2b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101c2f:	29 da                	sub    %ebx,%edx
f0101c31:	19 ce                	sbb    %ecx,%esi
f0101c33:	89 f9                	mov    %edi,%ecx
f0101c35:	89 f0                	mov    %esi,%eax
f0101c37:	d3 e0                	shl    %cl,%eax
f0101c39:	89 e9                	mov    %ebp,%ecx
f0101c3b:	d3 ea                	shr    %cl,%edx
f0101c3d:	89 e9                	mov    %ebp,%ecx
f0101c3f:	d3 ee                	shr    %cl,%esi
f0101c41:	09 d0                	or     %edx,%eax
f0101c43:	89 f2                	mov    %esi,%edx
f0101c45:	83 c4 1c             	add    $0x1c,%esp
f0101c48:	5b                   	pop    %ebx
f0101c49:	5e                   	pop    %esi
f0101c4a:	5f                   	pop    %edi
f0101c4b:	5d                   	pop    %ebp
f0101c4c:	c3                   	ret    
f0101c4d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c50:	29 f9                	sub    %edi,%ecx
f0101c52:	19 d6                	sbb    %edx,%esi
f0101c54:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101c5c:	e9 18 ff ff ff       	jmp    f0101b79 <__umoddi3+0x69>
