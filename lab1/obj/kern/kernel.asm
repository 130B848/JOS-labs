
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
f010004b:	68 c0 1c 10 f0       	push   $0xf0101cc0
f0100050:	e8 d8 09 00 00       	call   f0100a2d <cprintf>
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
f0100082:	68 dc 1c 10 f0       	push   $0xf0101cdc
f0100087:	e8 a1 09 00 00       	call   f0100a2d <cprintf>
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
f01000dd:	e8 02 17 00 00       	call   f01017e4 <memset>

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
f01000f4:	68 70 1d 10 f0       	push   $0xf0101d70
f01000f9:	e8 2f 09 00 00       	call   f0100a2d <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f01000fe:	83 c4 18             	add    $0x18,%esp
f0100101:	6a 16                	push   $0x16
f0100103:	68 90 1d 10 f0       	push   $0xf0101d90
f0100108:	e8 20 09 00 00       	call   f0100a2d <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f010010d:	83 c4 0c             	add    $0xc,%esp
f0100110:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f0100114:	50                   	push   %eax
f0100115:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0100119:	50                   	push   %eax
f010011a:	68 f7 1c 10 f0       	push   $0xf0101cf7
f010011f:	e8 09 09 00 00       	call   f0100a2d <cprintf>
	cprintf("%n", NULL);
f0100124:	83 c4 08             	add    $0x8,%esp
f0100127:	6a 00                	push   $0x0
f0100129:	68 10 1d 10 f0       	push   $0xf0101d10
f010012e:	e8 fa 08 00 00       	call   f0100a2d <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100133:	83 c4 0c             	add    $0xc,%esp
f0100136:	68 ff 00 00 00       	push   $0xff
f010013b:	6a 0d                	push   $0xd
f010013d:	8d 9d e6 fe ff ff    	lea    -0x11a(%ebp),%ebx
f0100143:	53                   	push   %ebx
f0100144:	e8 9b 16 00 00       	call   f01017e4 <memset>
	cprintf("%s%n", ntest, &chnum1);
f0100149:	83 c4 0c             	add    $0xc,%esp
f010014c:	56                   	push   %esi
f010014d:	53                   	push   %ebx
f010014e:	68 0e 1d 10 f0       	push   $0xf0101d0e
f0100153:	e8 d5 08 00 00       	call   f0100a2d <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f0100158:	83 c4 08             	add    $0x8,%esp
f010015b:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f010015f:	50                   	push   %eax
f0100160:	68 13 1d 10 f0       	push   $0xf0101d13
f0100165:	e8 c3 08 00 00       	call   f0100a2d <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f010016a:	83 c4 0c             	add    $0xc,%esp
f010016d:	68 00 fc ff ff       	push   $0xfffffc00
f0100172:	68 00 04 00 00       	push   $0x400
f0100177:	68 1f 1d 10 f0       	push   $0xf0101d1f
f010017c:	e8 ac 08 00 00       	call   f0100a2d <cprintf>


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
f0100195:	e8 fa 06 00 00       	call   f0100894 <monitor>
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
f01001c4:	68 3b 1d 10 f0       	push   $0xf0101d3b
f01001c9:	e8 5f 08 00 00       	call   f0100a2d <cprintf>
	vcprintf(fmt, ap);
f01001ce:	83 c4 08             	add    $0x8,%esp
f01001d1:	53                   	push   %ebx
f01001d2:	56                   	push   %esi
f01001d3:	e8 2f 08 00 00       	call   f0100a07 <vcprintf>
	cprintf("\n");
f01001d8:	c7 04 24 c9 1d 10 f0 	movl   $0xf0101dc9,(%esp)
f01001df:	e8 49 08 00 00       	call   f0100a2d <cprintf>
	va_end(ap);
f01001e4:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01001e7:	83 ec 0c             	sub    $0xc,%esp
f01001ea:	6a 00                	push   $0x0
f01001ec:	e8 a3 06 00 00       	call   f0100894 <monitor>
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
f0100206:	68 53 1d 10 f0       	push   $0xf0101d53
f010020b:	e8 1d 08 00 00       	call   f0100a2d <cprintf>
	vcprintf(fmt, ap);
f0100210:	83 c4 08             	add    $0x8,%esp
f0100213:	53                   	push   %ebx
f0100214:	ff 75 10             	pushl  0x10(%ebp)
f0100217:	e8 eb 07 00 00       	call   f0100a07 <vcprintf>
	cprintf("\n");
f010021c:	c7 04 24 c9 1d 10 f0 	movl   $0xf0101dc9,(%esp)
f0100223:	e8 05 08 00 00       	call   f0100a2d <cprintf>
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
f01002da:	0f b6 82 20 1f 10 f0 	movzbl -0xfefe0e0(%edx),%eax
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
f0100316:	0f b6 82 20 1f 10 f0 	movzbl -0xfefe0e0(%edx),%eax
f010031d:	0b 05 20 23 11 f0    	or     0xf0112320,%eax
f0100323:	0f b6 8a 20 1e 10 f0 	movzbl -0xfefe1e0(%edx),%ecx
f010032a:	31 c8                	xor    %ecx,%eax
f010032c:	a3 20 23 11 f0       	mov    %eax,0xf0112320

	c = charcode[shift & (CTL | SHIFT)][data];
f0100331:	89 c1                	mov    %eax,%ecx
f0100333:	83 e1 03             	and    $0x3,%ecx
f0100336:	8b 0c 8d 00 1e 10 f0 	mov    -0xfefe200(,%ecx,4),%ecx
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
f0100374:	68 bf 1d 10 f0       	push   $0xf0101dbf
f0100379:	e8 af 06 00 00       	call   f0100a2d <cprintf>
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
f0100532:	e8 fa 12 00 00       	call   f0101831 <memmove>
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
f0100705:	68 cb 1d 10 f0       	push   $0xf0101dcb
f010070a:	e8 1e 03 00 00       	call   f0100a2d <cprintf>
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
f010074b:	68 20 20 10 f0       	push   $0xf0102020
f0100750:	68 3e 20 10 f0       	push   $0xf010203e
f0100755:	68 43 20 10 f0       	push   $0xf0102043
f010075a:	e8 ce 02 00 00       	call   f0100a2d <cprintf>
f010075f:	83 c4 0c             	add    $0xc,%esp
f0100762:	68 e4 20 10 f0       	push   $0xf01020e4
f0100767:	68 4c 20 10 f0       	push   $0xf010204c
f010076c:	68 43 20 10 f0       	push   $0xf0102043
f0100771:	e8 b7 02 00 00       	call   f0100a2d <cprintf>
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
f0100783:	68 55 20 10 f0       	push   $0xf0102055
f0100788:	e8 a0 02 00 00       	call   f0100a2d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010078d:	83 c4 0c             	add    $0xc,%esp
f0100790:	68 0c 00 10 00       	push   $0x10000c
f0100795:	68 0c 00 10 f0       	push   $0xf010000c
f010079a:	68 0c 21 10 f0       	push   $0xf010210c
f010079f:	e8 89 02 00 00       	call   f0100a2d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a4:	83 c4 0c             	add    $0xc,%esp
f01007a7:	68 b1 1c 10 00       	push   $0x101cb1
f01007ac:	68 b1 1c 10 f0       	push   $0xf0101cb1
f01007b1:	68 30 21 10 f0       	push   $0xf0102130
f01007b6:	e8 72 02 00 00       	call   f0100a2d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007bb:	83 c4 0c             	add    $0xc,%esp
f01007be:	68 00 23 11 00       	push   $0x112300
f01007c3:	68 00 23 11 f0       	push   $0xf0112300
f01007c8:	68 54 21 10 f0       	push   $0xf0102154
f01007cd:	e8 5b 02 00 00       	call   f0100a2d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007d2:	83 c4 0c             	add    $0xc,%esp
f01007d5:	68 60 29 11 00       	push   $0x112960
f01007da:	68 60 29 11 f0       	push   $0xf0112960
f01007df:	68 78 21 10 f0       	push   $0xf0102178
f01007e4:	e8 44 02 00 00       	call   f0100a2d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007e9:	83 c4 08             	add    $0x8,%esp
f01007ec:	b8 5f 2d 11 f0       	mov    $0xf0112d5f,%eax
f01007f1:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007f6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007fc:	85 c0                	test   %eax,%eax
f01007fe:	0f 48 c2             	cmovs  %edx,%eax
f0100801:	c1 f8 0a             	sar    $0xa,%eax
f0100804:	50                   	push   %eax
f0100805:	68 9c 21 10 f0       	push   $0xf010219c
f010080a:	e8 1e 02 00 00       	call   f0100a2d <cprintf>
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
f010081c:	68 6e 20 10 f0       	push   $0xf010206e
f0100821:	e8 07 02 00 00       	call   f0100a2d <cprintf>
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
    char *pret_addr;

	// Your code here.
    // pret_addr = read_pretaddr();

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

#define EBP_OFFSET(ebp, offset) (*((uint32_t *)(ebp) + (offset)))
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100835:	55                   	push   %ebp
f0100836:	89 e5                	mov    %esp,%ebp
f0100838:	56                   	push   %esi
f0100839:	53                   	push   %ebx

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010083a:	89 ee                	mov    %ebp,%esi
f010083c:	89 f3                	mov    %esi,%ebx
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010083e:	8b 45 04             	mov    0x4(%ebp),%eax
{
	// Your code here.
		uint32_t ebp = read_ebp();
		uint32_t eip = read_eip();

		cprintf("Stack backtrace:\n");
f0100841:	83 ec 0c             	sub    $0xc,%esp
f0100844:	68 80 20 10 f0       	push   $0xf0102080
f0100849:	e8 df 01 00 00       	call   f0100a2d <cprintf>
		while(ebp != 0x0) {
f010084e:	83 c4 10             	add    $0x10,%esp
f0100851:	85 f6                	test   %esi,%esi
f0100853:	74 26                	je     f010087b <mon_backtrace+0x46>
			eip = EBP_OFFSET(ebp, 1);
			cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
f0100855:	ff 73 18             	pushl  0x18(%ebx)
f0100858:	ff 73 14             	pushl  0x14(%ebx)
f010085b:	ff 73 10             	pushl  0x10(%ebx)
f010085e:	ff 73 0c             	pushl  0xc(%ebx)
f0100861:	ff 73 08             	pushl  0x8(%ebx)
f0100864:	53                   	push   %ebx
f0100865:	ff 73 04             	pushl  0x4(%ebx)
f0100868:	68 c8 21 10 f0       	push   $0xf01021c8
f010086d:	e8 bb 01 00 00       	call   f0100a2d <cprintf>
					eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
					EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
			// warning: the value of ebp to print is register value, not stack value
			ebp = EBP_OFFSET(ebp, 0);
f0100872:	8b 1b                	mov    (%ebx),%ebx
	// Your code here.
		uint32_t ebp = read_ebp();
		uint32_t eip = read_eip();

		cprintf("Stack backtrace:\n");
		while(ebp != 0x0) {
f0100874:	83 c4 20             	add    $0x20,%esp
f0100877:	85 db                	test   %ebx,%ebx
f0100879:	75 da                	jne    f0100855 <mon_backtrace+0x20>
			// warning: the value of ebp to print is register value, not stack value
			ebp = EBP_OFFSET(ebp, 0);
		}

    overflow_me();
    cprintf("Backtrace success\n");
f010087b:	83 ec 0c             	sub    $0xc,%esp
f010087e:	68 92 20 10 f0       	push   $0xf0102092
f0100883:	e8 a5 01 00 00       	call   f0100a2d <cprintf>
	return 0;
}
f0100888:	b8 00 00 00 00       	mov    $0x0,%eax
f010088d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100890:	5b                   	pop    %ebx
f0100891:	5e                   	pop    %esi
f0100892:	5d                   	pop    %ebp
f0100893:	c3                   	ret    

f0100894 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100894:	55                   	push   %ebp
f0100895:	89 e5                	mov    %esp,%ebp
f0100897:	57                   	push   %edi
f0100898:	56                   	push   %esi
f0100899:	53                   	push   %ebx
f010089a:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010089d:	68 00 22 10 f0       	push   $0xf0102200
f01008a2:	e8 86 01 00 00       	call   f0100a2d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008a7:	c7 04 24 24 22 10 f0 	movl   $0xf0102224,(%esp)
f01008ae:	e8 7a 01 00 00       	call   f0100a2d <cprintf>
f01008b3:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01008b6:	83 ec 0c             	sub    $0xc,%esp
f01008b9:	68 a5 20 10 f0       	push   $0xf01020a5
f01008be:	e8 6d 0c 00 00       	call   f0101530 <readline>
f01008c3:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008c5:	83 c4 10             	add    $0x10,%esp
f01008c8:	85 c0                	test   %eax,%eax
f01008ca:	74 ea                	je     f01008b6 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008cc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008d3:	be 00 00 00 00       	mov    $0x0,%esi
f01008d8:	eb 0a                	jmp    f01008e4 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008da:	c6 03 00             	movb   $0x0,(%ebx)
f01008dd:	89 f7                	mov    %esi,%edi
f01008df:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01008e2:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008e4:	0f b6 03             	movzbl (%ebx),%eax
f01008e7:	84 c0                	test   %al,%al
f01008e9:	74 6a                	je     f0100955 <monitor+0xc1>
f01008eb:	83 ec 08             	sub    $0x8,%esp
f01008ee:	0f be c0             	movsbl %al,%eax
f01008f1:	50                   	push   %eax
f01008f2:	68 a9 20 10 f0       	push   $0xf01020a9
f01008f7:	e8 8a 0e 00 00       	call   f0101786 <strchr>
f01008fc:	83 c4 10             	add    $0x10,%esp
f01008ff:	85 c0                	test   %eax,%eax
f0100901:	75 d7                	jne    f01008da <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100903:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100906:	74 4d                	je     f0100955 <monitor+0xc1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100908:	83 fe 0f             	cmp    $0xf,%esi
f010090b:	75 14                	jne    f0100921 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010090d:	83 ec 08             	sub    $0x8,%esp
f0100910:	6a 10                	push   $0x10
f0100912:	68 ae 20 10 f0       	push   $0xf01020ae
f0100917:	e8 11 01 00 00       	call   f0100a2d <cprintf>
f010091c:	83 c4 10             	add    $0x10,%esp
f010091f:	eb 95                	jmp    f01008b6 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100921:	8d 7e 01             	lea    0x1(%esi),%edi
f0100924:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100928:	0f b6 03             	movzbl (%ebx),%eax
f010092b:	84 c0                	test   %al,%al
f010092d:	75 0c                	jne    f010093b <monitor+0xa7>
f010092f:	eb b1                	jmp    f01008e2 <monitor+0x4e>
			buf++;
f0100931:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100934:	0f b6 03             	movzbl (%ebx),%eax
f0100937:	84 c0                	test   %al,%al
f0100939:	74 a7                	je     f01008e2 <monitor+0x4e>
f010093b:	83 ec 08             	sub    $0x8,%esp
f010093e:	0f be c0             	movsbl %al,%eax
f0100941:	50                   	push   %eax
f0100942:	68 a9 20 10 f0       	push   $0xf01020a9
f0100947:	e8 3a 0e 00 00       	call   f0101786 <strchr>
f010094c:	83 c4 10             	add    $0x10,%esp
f010094f:	85 c0                	test   %eax,%eax
f0100951:	74 de                	je     f0100931 <monitor+0x9d>
f0100953:	eb 8d                	jmp    f01008e2 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100955:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010095c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010095d:	85 f6                	test   %esi,%esi
f010095f:	0f 84 51 ff ff ff    	je     f01008b6 <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100965:	83 ec 08             	sub    $0x8,%esp
f0100968:	68 3e 20 10 f0       	push   $0xf010203e
f010096d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100970:	e8 8d 0d 00 00       	call   f0101702 <strcmp>
f0100975:	83 c4 10             	add    $0x10,%esp
f0100978:	85 c0                	test   %eax,%eax
f010097a:	74 1e                	je     f010099a <monitor+0x106>
f010097c:	83 ec 08             	sub    $0x8,%esp
f010097f:	68 4c 20 10 f0       	push   $0xf010204c
f0100984:	ff 75 a8             	pushl  -0x58(%ebp)
f0100987:	e8 76 0d 00 00       	call   f0101702 <strcmp>
f010098c:	83 c4 10             	add    $0x10,%esp
f010098f:	85 c0                	test   %eax,%eax
f0100991:	75 2f                	jne    f01009c2 <monitor+0x12e>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100993:	b8 01 00 00 00       	mov    $0x1,%eax
f0100998:	eb 05                	jmp    f010099f <monitor+0x10b>
		if (strcmp(argv[0], commands[i].name) == 0)
f010099a:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f010099f:	83 ec 04             	sub    $0x4,%esp
f01009a2:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009a5:	01 d0                	add    %edx,%eax
f01009a7:	ff 75 08             	pushl  0x8(%ebp)
f01009aa:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01009ad:	51                   	push   %ecx
f01009ae:	56                   	push   %esi
f01009af:	ff 14 85 54 22 10 f0 	call   *-0xfefddac(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009b6:	83 c4 10             	add    $0x10,%esp
f01009b9:	85 c0                	test   %eax,%eax
f01009bb:	78 1d                	js     f01009da <monitor+0x146>
f01009bd:	e9 f4 fe ff ff       	jmp    f01008b6 <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009c2:	83 ec 08             	sub    $0x8,%esp
f01009c5:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c8:	68 cb 20 10 f0       	push   $0xf01020cb
f01009cd:	e8 5b 00 00 00       	call   f0100a2d <cprintf>
f01009d2:	83 c4 10             	add    $0x10,%esp
f01009d5:	e9 dc fe ff ff       	jmp    f01008b6 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009dd:	5b                   	pop    %ebx
f01009de:	5e                   	pop    %esi
f01009df:	5f                   	pop    %edi
f01009e0:	5d                   	pop    %ebp
f01009e1:	c3                   	ret    

f01009e2 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01009e2:	55                   	push   %ebp
f01009e3:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01009e5:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01009e8:	5d                   	pop    %ebp
f01009e9:	c3                   	ret    

f01009ea <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009ea:	55                   	push   %ebp
f01009eb:	89 e5                	mov    %esp,%ebp
f01009ed:	53                   	push   %ebx
f01009ee:	83 ec 10             	sub    $0x10,%esp
f01009f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f01009f4:	ff 75 08             	pushl  0x8(%ebp)
f01009f7:	e8 1e fd ff ff       	call   f010071a <cputchar>
    (*cnt)++;
f01009fc:	83 03 01             	addl   $0x1,(%ebx)
}
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a05:	c9                   	leave  
f0100a06:	c3                   	ret    

f0100a07 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a07:	55                   	push   %ebp
f0100a08:	89 e5                	mov    %esp,%ebp
f0100a0a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100a0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a14:	ff 75 0c             	pushl  0xc(%ebp)
f0100a17:	ff 75 08             	pushl  0x8(%ebp)
f0100a1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a1d:	50                   	push   %eax
f0100a1e:	68 ea 09 10 f0       	push   $0xf01009ea
f0100a23:	e8 d5 05 00 00       	call   f0100ffd <vprintfmt>
	return cnt;
}
f0100a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a2b:	c9                   	leave  
f0100a2c:	c3                   	ret    

f0100a2d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a2d:	55                   	push   %ebp
f0100a2e:	89 e5                	mov    %esp,%ebp
f0100a30:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a33:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a36:	50                   	push   %eax
f0100a37:	ff 75 08             	pushl  0x8(%ebp)
f0100a3a:	e8 c8 ff ff ff       	call   f0100a07 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a3f:	c9                   	leave  
f0100a40:	c3                   	ret    

f0100a41 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a41:	55                   	push   %ebp
f0100a42:	89 e5                	mov    %esp,%ebp
f0100a44:	57                   	push   %edi
f0100a45:	56                   	push   %esi
f0100a46:	53                   	push   %ebx
f0100a47:	83 ec 14             	sub    $0x14,%esp
f0100a4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a4d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a50:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a53:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a56:	8b 1a                	mov    (%edx),%ebx
f0100a58:	8b 01                	mov    (%ecx),%eax
f0100a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	while (l <= r) {
f0100a5d:	39 c3                	cmp    %eax,%ebx
f0100a5f:	0f 8f 9a 00 00 00    	jg     f0100aff <stab_binsearch+0xbe>
f0100a65:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a6f:	01 d8                	add    %ebx,%eax
f0100a71:	89 c6                	mov    %eax,%esi
f0100a73:	c1 ee 1f             	shr    $0x1f,%esi
f0100a76:	01 c6                	add    %eax,%esi
f0100a78:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a7a:	39 de                	cmp    %ebx,%esi
f0100a7c:	0f 8c c4 00 00 00    	jl     f0100b46 <stab_binsearch+0x105>
f0100a82:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a85:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a88:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100a8b:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0100a8f:	39 c7                	cmp    %eax,%edi
f0100a91:	0f 84 b4 00 00 00    	je     f0100b4b <stab_binsearch+0x10a>
f0100a97:	89 f0                	mov    %esi,%eax
			m--;
f0100a99:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a9c:	39 d8                	cmp    %ebx,%eax
f0100a9e:	0f 8c a2 00 00 00    	jl     f0100b46 <stab_binsearch+0x105>
f0100aa4:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0100aa8:	83 ea 0c             	sub    $0xc,%edx
f0100aab:	39 f9                	cmp    %edi,%ecx
f0100aad:	75 ea                	jne    f0100a99 <stab_binsearch+0x58>
f0100aaf:	e9 99 00 00 00       	jmp    f0100b4d <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100ab4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ab7:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100ab9:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100abc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100ac3:	eb 2b                	jmp    f0100af0 <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100ac5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100ac8:	76 14                	jbe    f0100ade <stab_binsearch+0x9d>
			*region_right = m - 1;
f0100aca:	83 e8 01             	sub    $0x1,%eax
f0100acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ad0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100ad3:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ad5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100adc:	eb 12                	jmp    f0100af0 <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100ade:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ae1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100ae3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100ae7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ae9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100af0:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0100af3:	0f 8d 73 ff ff ff    	jge    f0100a6c <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100af9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100afd:	75 0f                	jne    f0100b0e <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f0100aff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b02:	8b 00                	mov    (%eax),%eax
f0100b04:	83 e8 01             	sub    $0x1,%eax
f0100b07:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b0a:	89 07                	mov    %eax,(%edi)
f0100b0c:	eb 57                	jmp    f0100b65 <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b11:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b13:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b16:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b18:	39 c8                	cmp    %ecx,%eax
f0100b1a:	7e 23                	jle    f0100b3f <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0100b1c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b1f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100b22:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0100b25:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100b29:	39 df                	cmp    %ebx,%edi
f0100b2b:	74 12                	je     f0100b3f <stab_binsearch+0xfe>
		     l--)
f0100b2d:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b30:	39 c8                	cmp    %ecx,%eax
f0100b32:	7e 0b                	jle    f0100b3f <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0100b34:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f0100b38:	83 ea 0c             	sub    $0xc,%edx
f0100b3b:	39 df                	cmp    %ebx,%edi
f0100b3d:	75 ee                	jne    f0100b2d <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b42:	89 07                	mov    %eax,(%edi)
	}
}
f0100b44:	eb 1f                	jmp    f0100b65 <stab_binsearch+0x124>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100b46:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100b49:	eb a5                	jmp    f0100af0 <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100b4b:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b4d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b50:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b53:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b57:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b5a:	0f 82 54 ff ff ff    	jb     f0100ab4 <stab_binsearch+0x73>
f0100b60:	e9 60 ff ff ff       	jmp    f0100ac5 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100b65:	83 c4 14             	add    $0x14,%esp
f0100b68:	5b                   	pop    %ebx
f0100b69:	5e                   	pop    %esi
f0100b6a:	5f                   	pop    %edi
f0100b6b:	5d                   	pop    %ebp
f0100b6c:	c3                   	ret    

f0100b6d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b6d:	55                   	push   %ebp
f0100b6e:	89 e5                	mov    %esp,%ebp
f0100b70:	57                   	push   %edi
f0100b71:	56                   	push   %esi
f0100b72:	53                   	push   %ebx
f0100b73:	83 ec 1c             	sub    $0x1c,%esp
f0100b76:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100b79:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b7c:	c7 06 64 22 10 f0    	movl   $0xf0102264,(%esi)
	info->eip_line = 0;
f0100b82:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100b89:	c7 46 08 64 22 10 f0 	movl   $0xf0102264,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100b90:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100b97:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100b9a:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ba1:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100ba7:	76 11                	jbe    f0100bba <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ba9:	b8 4b 7b 10 f0       	mov    $0xf0107b4b,%eax
f0100bae:	3d 19 61 10 f0       	cmp    $0xf0106119,%eax
f0100bb3:	77 19                	ja     f0100bce <debuginfo_eip+0x61>
f0100bb5:	e9 84 01 00 00       	jmp    f0100d3e <debuginfo_eip+0x1d1>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100bba:	83 ec 04             	sub    $0x4,%esp
f0100bbd:	68 6e 22 10 f0       	push   $0xf010226e
f0100bc2:	6a 7f                	push   $0x7f
f0100bc4:	68 7b 22 10 f0       	push   $0xf010227b
f0100bc9:	e8 d1 f5 ff ff       	call   f010019f <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100bce:	80 3d 4a 7b 10 f0 00 	cmpb   $0x0,0xf0107b4a
f0100bd5:	0f 85 6a 01 00 00    	jne    f0100d45 <debuginfo_eip+0x1d8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bdb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100be2:	b8 18 61 10 f0       	mov    $0xf0106118,%eax
f0100be7:	2d 18 25 10 f0       	sub    $0xf0102518,%eax
f0100bec:	c1 f8 02             	sar    $0x2,%eax
f0100bef:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100bf5:	83 e8 01             	sub    $0x1,%eax
f0100bf8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bfb:	83 ec 08             	sub    $0x8,%esp
f0100bfe:	57                   	push   %edi
f0100bff:	6a 64                	push   $0x64
f0100c01:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c04:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c07:	b8 18 25 10 f0       	mov    $0xf0102518,%eax
f0100c0c:	e8 30 fe ff ff       	call   f0100a41 <stab_binsearch>
	if (lfile == 0)
f0100c11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c14:	83 c4 10             	add    $0x10,%esp
f0100c17:	85 c0                	test   %eax,%eax
f0100c19:	0f 84 2d 01 00 00    	je     f0100d4c <debuginfo_eip+0x1df>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c1f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c22:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c25:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c28:	83 ec 08             	sub    $0x8,%esp
f0100c2b:	57                   	push   %edi
f0100c2c:	6a 24                	push   $0x24
f0100c2e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c31:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c34:	b8 18 25 10 f0       	mov    $0xf0102518,%eax
f0100c39:	e8 03 fe ff ff       	call   f0100a41 <stab_binsearch>

	if (lfun <= rfun) {
f0100c3e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100c41:	83 c4 10             	add    $0x10,%esp
f0100c44:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100c47:	7f 31                	jg     f0100c7a <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c49:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c4c:	c1 e0 02             	shl    $0x2,%eax
f0100c4f:	8d 90 18 25 10 f0    	lea    -0xfefdae8(%eax),%edx
f0100c55:	8b 88 18 25 10 f0    	mov    -0xfefdae8(%eax),%ecx
f0100c5b:	b8 4b 7b 10 f0       	mov    $0xf0107b4b,%eax
f0100c60:	2d 19 61 10 f0       	sub    $0xf0106119,%eax
f0100c65:	39 c1                	cmp    %eax,%ecx
f0100c67:	73 09                	jae    f0100c72 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c69:	81 c1 19 61 10 f0    	add    $0xf0106119,%ecx
f0100c6f:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c72:	8b 42 08             	mov    0x8(%edx),%eax
f0100c75:	89 46 10             	mov    %eax,0x10(%esi)
f0100c78:	eb 06                	jmp    f0100c80 <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c7a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100c7d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c80:	83 ec 08             	sub    $0x8,%esp
f0100c83:	6a 3a                	push   $0x3a
f0100c85:	ff 76 08             	pushl  0x8(%esi)
f0100c88:	e8 2f 0b 00 00       	call   f01017bc <strfind>
f0100c8d:	2b 46 08             	sub    0x8(%esi),%eax
f0100c90:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c96:	83 c4 10             	add    $0x10,%esp
f0100c99:	39 fb                	cmp    %edi,%ebx
f0100c9b:	7c 5b                	jl     f0100cf8 <debuginfo_eip+0x18b>
	       && stabs[lline].n_type != N_SOL
f0100c9d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ca0:	8d 0c 85 18 25 10 f0 	lea    -0xfefdae8(,%eax,4),%ecx
f0100ca7:	0f b6 41 04          	movzbl 0x4(%ecx),%eax
f0100cab:	3c 84                	cmp    $0x84,%al
f0100cad:	74 29                	je     f0100cd8 <debuginfo_eip+0x16b>
f0100caf:	89 ca                	mov    %ecx,%edx
f0100cb1:	83 c1 08             	add    $0x8,%ecx
f0100cb4:	eb 15                	jmp    f0100ccb <debuginfo_eip+0x15e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100cb6:	83 eb 01             	sub    $0x1,%ebx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100cb9:	39 fb                	cmp    %edi,%ebx
f0100cbb:	7c 3b                	jl     f0100cf8 <debuginfo_eip+0x18b>
	       && stabs[lline].n_type != N_SOL
f0100cbd:	0f b6 42 f8          	movzbl -0x8(%edx),%eax
f0100cc1:	83 ea 0c             	sub    $0xc,%edx
f0100cc4:	83 e9 0c             	sub    $0xc,%ecx
f0100cc7:	3c 84                	cmp    $0x84,%al
f0100cc9:	74 0d                	je     f0100cd8 <debuginfo_eip+0x16b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100ccb:	3c 64                	cmp    $0x64,%al
f0100ccd:	75 e7                	jne    f0100cb6 <debuginfo_eip+0x149>
f0100ccf:	83 39 00             	cmpl   $0x0,(%ecx)
f0100cd2:	74 e2                	je     f0100cb6 <debuginfo_eip+0x149>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100cd4:	39 df                	cmp    %ebx,%edi
f0100cd6:	7f 20                	jg     f0100cf8 <debuginfo_eip+0x18b>
f0100cd8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100cdb:	8b 14 85 18 25 10 f0 	mov    -0xfefdae8(,%eax,4),%edx
f0100ce2:	b8 4b 7b 10 f0       	mov    $0xf0107b4b,%eax
f0100ce7:	2d 19 61 10 f0       	sub    $0xf0106119,%eax
f0100cec:	39 c2                	cmp    %eax,%edx
f0100cee:	73 08                	jae    f0100cf8 <debuginfo_eip+0x18b>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100cf0:	81 c2 19 61 10 f0    	add    $0xf0106119,%edx
f0100cf6:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cf8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cfb:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100cfe:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d03:	39 ca                	cmp    %ecx,%edx
f0100d05:	7d 5f                	jge    f0100d66 <debuginfo_eip+0x1f9>
		for (lline = lfun + 1;
f0100d07:	8d 42 01             	lea    0x1(%edx),%eax
f0100d0a:	39 c1                	cmp    %eax,%ecx
f0100d0c:	7e 45                	jle    f0100d53 <debuginfo_eip+0x1e6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d0e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d11:	c1 e2 02             	shl    $0x2,%edx
f0100d14:	80 ba 1c 25 10 f0 a0 	cmpb   $0xa0,-0xfefdae4(%edx)
f0100d1b:	75 3d                	jne    f0100d5a <debuginfo_eip+0x1ed>
f0100d1d:	81 c2 0c 25 10 f0    	add    $0xf010250c,%edx
		     lline++)
			info->eip_fn_narg++;
f0100d23:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100d27:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d2a:	39 c1                	cmp    %eax,%ecx
f0100d2c:	7e 33                	jle    f0100d61 <debuginfo_eip+0x1f4>
f0100d2e:	83 c2 0c             	add    $0xc,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d31:	80 7a 10 a0          	cmpb   $0xa0,0x10(%edx)
f0100d35:	74 ec                	je     f0100d23 <debuginfo_eip+0x1b6>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100d37:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d3c:	eb 28                	jmp    f0100d66 <debuginfo_eip+0x1f9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100d3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d43:	eb 21                	jmp    f0100d66 <debuginfo_eip+0x1f9>
f0100d45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d4a:	eb 1a                	jmp    f0100d66 <debuginfo_eip+0x1f9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d51:	eb 13                	jmp    f0100d66 <debuginfo_eip+0x1f9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0100d53:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d58:	eb 0c                	jmp    f0100d66 <debuginfo_eip+0x1f9>
f0100d5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d5f:	eb 05                	jmp    f0100d66 <debuginfo_eip+0x1f9>
f0100d61:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d69:	5b                   	pop    %ebx
f0100d6a:	5e                   	pop    %esi
f0100d6b:	5f                   	pop    %edi
f0100d6c:	5d                   	pop    %ebp
f0100d6d:	c3                   	ret    

f0100d6e <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d6e:	55                   	push   %ebp
f0100d6f:	89 e5                	mov    %esp,%ebp
f0100d71:	57                   	push   %edi
f0100d72:	56                   	push   %esi
f0100d73:	53                   	push   %ebx
f0100d74:	83 ec 1c             	sub    $0x1c,%esp
f0100d77:	89 c7                	mov    %eax,%edi
f0100d79:	89 d6                	mov    %edx,%esi
f0100d7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d7e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d81:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d84:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100d87:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
f0100d8a:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0100d8e:	0f 85 bf 00 00 00    	jne    f0100e53 <printnum+0xe5>
f0100d94:	39 1d 5c 25 11 f0    	cmp    %ebx,0xf011255c
f0100d9a:	0f 8d de 00 00 00    	jge    f0100e7e <printnum+0x110>
		judge_time_for_space = width;
f0100da0:	89 1d 5c 25 11 f0    	mov    %ebx,0xf011255c
f0100da6:	e9 d3 00 00 00       	jmp    f0100e7e <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0100dab:	83 eb 01             	sub    $0x1,%ebx
f0100dae:	85 db                	test   %ebx,%ebx
f0100db0:	7f 37                	jg     f0100de9 <printnum+0x7b>
f0100db2:	e9 ea 00 00 00       	jmp    f0100ea1 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
f0100db7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100dba:	a3 58 25 11 f0       	mov    %eax,0xf0112558
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100dbf:	83 ec 08             	sub    $0x8,%esp
f0100dc2:	56                   	push   %esi
f0100dc3:	83 ec 04             	sub    $0x4,%esp
f0100dc6:	ff 75 dc             	pushl  -0x24(%ebp)
f0100dc9:	ff 75 d8             	pushl  -0x28(%ebp)
f0100dcc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100dcf:	ff 75 e0             	pushl  -0x20(%ebp)
f0100dd2:	e8 89 0d 00 00       	call   f0101b60 <__umoddi3>
f0100dd7:	83 c4 14             	add    $0x14,%esp
f0100dda:	0f be 80 89 22 10 f0 	movsbl -0xfefdd77(%eax),%eax
f0100de1:	50                   	push   %eax
f0100de2:	ff d7                	call   *%edi
f0100de4:	83 c4 10             	add    $0x10,%esp
f0100de7:	eb 16                	jmp    f0100dff <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
f0100de9:	83 ec 08             	sub    $0x8,%esp
f0100dec:	56                   	push   %esi
f0100ded:	ff 75 18             	pushl  0x18(%ebp)
f0100df0:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0100df2:	83 c4 10             	add    $0x10,%esp
f0100df5:	83 eb 01             	sub    $0x1,%ebx
f0100df8:	75 ef                	jne    f0100de9 <printnum+0x7b>
f0100dfa:	e9 a2 00 00 00       	jmp    f0100ea1 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
f0100dff:	3b 1d 5c 25 11 f0    	cmp    0xf011255c,%ebx
f0100e05:	0f 85 76 01 00 00    	jne    f0100f81 <printnum+0x213>
		while(num_of_space-- > 0)
f0100e0b:	a1 58 25 11 f0       	mov    0xf0112558,%eax
f0100e10:	8d 50 ff             	lea    -0x1(%eax),%edx
f0100e13:	89 15 58 25 11 f0    	mov    %edx,0xf0112558
f0100e19:	85 c0                	test   %eax,%eax
f0100e1b:	7e 1d                	jle    f0100e3a <printnum+0xcc>
			putch(' ', putdat);
f0100e1d:	83 ec 08             	sub    $0x8,%esp
f0100e20:	56                   	push   %esi
f0100e21:	6a 20                	push   $0x20
f0100e23:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
f0100e25:	a1 58 25 11 f0       	mov    0xf0112558,%eax
f0100e2a:	8d 50 ff             	lea    -0x1(%eax),%edx
f0100e2d:	89 15 58 25 11 f0    	mov    %edx,0xf0112558
f0100e33:	83 c4 10             	add    $0x10,%esp
f0100e36:	85 c0                	test   %eax,%eax
f0100e38:	7f e3                	jg     f0100e1d <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
f0100e3a:	c7 05 58 25 11 f0 00 	movl   $0x0,0xf0112558
f0100e41:	00 00 00 
		judge_time_for_space = 0;
f0100e44:	c7 05 5c 25 11 f0 00 	movl   $0x0,0xf011255c
f0100e4b:	00 00 00 
	}
}
f0100e4e:	e9 2e 01 00 00       	jmp    f0100f81 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e53:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e56:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e5e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100e61:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100e67:	83 fa 00             	cmp    $0x0,%edx
f0100e6a:	0f 87 ba 00 00 00    	ja     f0100f2a <printnum+0x1bc>
f0100e70:	3b 45 10             	cmp    0x10(%ebp),%eax
f0100e73:	0f 83 b1 00 00 00    	jae    f0100f2a <printnum+0x1bc>
f0100e79:	e9 2d ff ff ff       	jmp    f0100dab <printnum+0x3d>
f0100e7e:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e81:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e86:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e89:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100e8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100e92:	83 fa 00             	cmp    $0x0,%edx
f0100e95:	77 37                	ja     f0100ece <printnum+0x160>
f0100e97:	3b 45 10             	cmp    0x10(%ebp),%eax
f0100e9a:	73 32                	jae    f0100ece <printnum+0x160>
f0100e9c:	e9 16 ff ff ff       	jmp    f0100db7 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ea1:	83 ec 08             	sub    $0x8,%esp
f0100ea4:	56                   	push   %esi
f0100ea5:	83 ec 04             	sub    $0x4,%esp
f0100ea8:	ff 75 dc             	pushl  -0x24(%ebp)
f0100eab:	ff 75 d8             	pushl  -0x28(%ebp)
f0100eae:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100eb1:	ff 75 e0             	pushl  -0x20(%ebp)
f0100eb4:	e8 a7 0c 00 00       	call   f0101b60 <__umoddi3>
f0100eb9:	83 c4 14             	add    $0x14,%esp
f0100ebc:	0f be 80 89 22 10 f0 	movsbl -0xfefdd77(%eax),%eax
f0100ec3:	50                   	push   %eax
f0100ec4:	ff d7                	call   *%edi
f0100ec6:	83 c4 10             	add    $0x10,%esp
f0100ec9:	e9 b3 00 00 00       	jmp    f0100f81 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ece:	83 ec 0c             	sub    $0xc,%esp
f0100ed1:	ff 75 18             	pushl  0x18(%ebp)
f0100ed4:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100ed7:	50                   	push   %eax
f0100ed8:	ff 75 10             	pushl  0x10(%ebp)
f0100edb:	83 ec 08             	sub    $0x8,%esp
f0100ede:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ee1:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ee4:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ee7:	ff 75 e0             	pushl  -0x20(%ebp)
f0100eea:	e8 41 0b 00 00       	call   f0101a30 <__udivdi3>
f0100eef:	83 c4 18             	add    $0x18,%esp
f0100ef2:	52                   	push   %edx
f0100ef3:	50                   	push   %eax
f0100ef4:	89 f2                	mov    %esi,%edx
f0100ef6:	89 f8                	mov    %edi,%eax
f0100ef8:	e8 71 fe ff ff       	call   f0100d6e <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100efd:	83 c4 18             	add    $0x18,%esp
f0100f00:	56                   	push   %esi
f0100f01:	83 ec 04             	sub    $0x4,%esp
f0100f04:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f07:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f0a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f0d:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f10:	e8 4b 0c 00 00       	call   f0101b60 <__umoddi3>
f0100f15:	83 c4 14             	add    $0x14,%esp
f0100f18:	0f be 80 89 22 10 f0 	movsbl -0xfefdd77(%eax),%eax
f0100f1f:	50                   	push   %eax
f0100f20:	ff d7                	call   *%edi
f0100f22:	83 c4 10             	add    $0x10,%esp
f0100f25:	e9 d5 fe ff ff       	jmp    f0100dff <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f2a:	83 ec 0c             	sub    $0xc,%esp
f0100f2d:	ff 75 18             	pushl  0x18(%ebp)
f0100f30:	83 eb 01             	sub    $0x1,%ebx
f0100f33:	53                   	push   %ebx
f0100f34:	ff 75 10             	pushl  0x10(%ebp)
f0100f37:	83 ec 08             	sub    $0x8,%esp
f0100f3a:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f3d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f40:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f43:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f46:	e8 e5 0a 00 00       	call   f0101a30 <__udivdi3>
f0100f4b:	83 c4 18             	add    $0x18,%esp
f0100f4e:	52                   	push   %edx
f0100f4f:	50                   	push   %eax
f0100f50:	89 f2                	mov    %esi,%edx
f0100f52:	89 f8                	mov    %edi,%eax
f0100f54:	e8 15 fe ff ff       	call   f0100d6e <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f59:	83 c4 18             	add    $0x18,%esp
f0100f5c:	56                   	push   %esi
f0100f5d:	83 ec 04             	sub    $0x4,%esp
f0100f60:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f63:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f66:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f69:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f6c:	e8 ef 0b 00 00       	call   f0101b60 <__umoddi3>
f0100f71:	83 c4 14             	add    $0x14,%esp
f0100f74:	0f be 80 89 22 10 f0 	movsbl -0xfefdd77(%eax),%eax
f0100f7b:	50                   	push   %eax
f0100f7c:	ff d7                	call   *%edi
f0100f7e:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
f0100f81:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f84:	5b                   	pop    %ebx
f0100f85:	5e                   	pop    %esi
f0100f86:	5f                   	pop    %edi
f0100f87:	5d                   	pop    %ebp
f0100f88:	c3                   	ret    

f0100f89 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100f89:	55                   	push   %ebp
f0100f8a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100f8c:	83 fa 01             	cmp    $0x1,%edx
f0100f8f:	7e 0e                	jle    f0100f9f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100f91:	8b 10                	mov    (%eax),%edx
f0100f93:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100f96:	89 08                	mov    %ecx,(%eax)
f0100f98:	8b 02                	mov    (%edx),%eax
f0100f9a:	8b 52 04             	mov    0x4(%edx),%edx
f0100f9d:	eb 22                	jmp    f0100fc1 <getuint+0x38>
	else if (lflag)
f0100f9f:	85 d2                	test   %edx,%edx
f0100fa1:	74 10                	je     f0100fb3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100fa3:	8b 10                	mov    (%eax),%edx
f0100fa5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100fa8:	89 08                	mov    %ecx,(%eax)
f0100faa:	8b 02                	mov    (%edx),%eax
f0100fac:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fb1:	eb 0e                	jmp    f0100fc1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100fb3:	8b 10                	mov    (%eax),%edx
f0100fb5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100fb8:	89 08                	mov    %ecx,(%eax)
f0100fba:	8b 02                	mov    (%edx),%eax
f0100fbc:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100fc1:	5d                   	pop    %ebp
f0100fc2:	c3                   	ret    

f0100fc3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100fc3:	55                   	push   %ebp
f0100fc4:	89 e5                	mov    %esp,%ebp
f0100fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100fc9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100fcd:	8b 10                	mov    (%eax),%edx
f0100fcf:	3b 50 04             	cmp    0x4(%eax),%edx
f0100fd2:	73 0a                	jae    f0100fde <sprintputch+0x1b>
		*b->buf++ = ch;
f0100fd4:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100fd7:	89 08                	mov    %ecx,(%eax)
f0100fd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fdc:	88 02                	mov    %al,(%edx)
}
f0100fde:	5d                   	pop    %ebp
f0100fdf:	c3                   	ret    

f0100fe0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100fe0:	55                   	push   %ebp
f0100fe1:	89 e5                	mov    %esp,%ebp
f0100fe3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100fe6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100fe9:	50                   	push   %eax
f0100fea:	ff 75 10             	pushl  0x10(%ebp)
f0100fed:	ff 75 0c             	pushl  0xc(%ebp)
f0100ff0:	ff 75 08             	pushl  0x8(%ebp)
f0100ff3:	e8 05 00 00 00       	call   f0100ffd <vprintfmt>
	va_end(ap);
}
f0100ff8:	83 c4 10             	add    $0x10,%esp
f0100ffb:	c9                   	leave  
f0100ffc:	c3                   	ret    

f0100ffd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100ffd:	55                   	push   %ebp
f0100ffe:	89 e5                	mov    %esp,%ebp
f0101000:	57                   	push   %edi
f0101001:	56                   	push   %esi
f0101002:	53                   	push   %ebx
f0101003:	83 ec 2c             	sub    $0x2c,%esp
f0101006:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101009:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010100c:	eb 03                	jmp    f0101011 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f010100e:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101011:	8b 45 10             	mov    0x10(%ebp),%eax
f0101014:	8d 70 01             	lea    0x1(%eax),%esi
f0101017:	0f b6 00             	movzbl (%eax),%eax
f010101a:	83 f8 25             	cmp    $0x25,%eax
f010101d:	74 27                	je     f0101046 <vprintfmt+0x49>
			if (ch == '\0')
f010101f:	85 c0                	test   %eax,%eax
f0101021:	75 0d                	jne    f0101030 <vprintfmt+0x33>
f0101023:	e9 98 04 00 00       	jmp    f01014c0 <vprintfmt+0x4c3>
f0101028:	85 c0                	test   %eax,%eax
f010102a:	0f 84 90 04 00 00    	je     f01014c0 <vprintfmt+0x4c3>
				return;
			putch(ch, putdat);
f0101030:	83 ec 08             	sub    $0x8,%esp
f0101033:	53                   	push   %ebx
f0101034:	50                   	push   %eax
f0101035:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101037:	83 c6 01             	add    $0x1,%esi
f010103a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f010103e:	83 c4 10             	add    $0x10,%esp
f0101041:	83 f8 25             	cmp    $0x25,%eax
f0101044:	75 e2                	jne    f0101028 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101046:	b9 00 00 00 00       	mov    $0x0,%ecx
f010104b:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f010104f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101056:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010105d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0101064:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f010106b:	eb 08                	jmp    f0101075 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010106d:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
f0101070:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101075:	8d 46 01             	lea    0x1(%esi),%eax
f0101078:	89 45 10             	mov    %eax,0x10(%ebp)
f010107b:	0f b6 06             	movzbl (%esi),%eax
f010107e:	0f b6 d0             	movzbl %al,%edx
f0101081:	83 e8 23             	sub    $0x23,%eax
f0101084:	3c 55                	cmp    $0x55,%al
f0101086:	0f 87 f5 03 00 00    	ja     f0101481 <vprintfmt+0x484>
f010108c:	0f b6 c0             	movzbl %al,%eax
f010108f:	ff 24 85 94 23 10 f0 	jmp    *-0xfefdc6c(,%eax,4)
f0101096:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f0101099:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f010109d:	eb d6                	jmp    f0101075 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010109f:	8d 42 d0             	lea    -0x30(%edx),%eax
f01010a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f01010a5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f01010a9:	8d 50 d0             	lea    -0x30(%eax),%edx
f01010ac:	83 fa 09             	cmp    $0x9,%edx
f01010af:	77 6b                	ja     f010111c <vprintfmt+0x11f>
f01010b1:	8b 75 10             	mov    0x10(%ebp),%esi
f01010b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01010b7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01010ba:	eb 09                	jmp    f01010c5 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010bc:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01010bf:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f01010c3:	eb b0                	jmp    f0101075 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01010c5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f01010c8:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01010cb:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f01010cf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01010d2:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01010d5:	83 f9 09             	cmp    $0x9,%ecx
f01010d8:	76 eb                	jbe    f01010c5 <vprintfmt+0xc8>
f01010da:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01010dd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01010e0:	eb 3d                	jmp    f010111f <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01010e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e5:	8d 50 04             	lea    0x4(%eax),%edx
f01010e8:	89 55 14             	mov    %edx,0x14(%ebp)
f01010eb:	8b 00                	mov    (%eax),%eax
f01010ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010f0:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01010f3:	eb 2a                	jmp    f010111f <vprintfmt+0x122>
f01010f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010f8:	85 c0                	test   %eax,%eax
f01010fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01010ff:	0f 49 d0             	cmovns %eax,%edx
f0101102:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101105:	8b 75 10             	mov    0x10(%ebp),%esi
f0101108:	e9 68 ff ff ff       	jmp    f0101075 <vprintfmt+0x78>
f010110d:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101110:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101117:	e9 59 ff ff ff       	jmp    f0101075 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010111c:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010111f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101123:	0f 89 4c ff ff ff    	jns    f0101075 <vprintfmt+0x78>
				width = precision, precision = -1;
f0101129:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010112c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010112f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101136:	e9 3a ff ff ff       	jmp    f0101075 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010113b:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010113f:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101142:	e9 2e ff ff ff       	jmp    f0101075 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101147:	8b 45 14             	mov    0x14(%ebp),%eax
f010114a:	8d 50 04             	lea    0x4(%eax),%edx
f010114d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101150:	83 ec 08             	sub    $0x8,%esp
f0101153:	53                   	push   %ebx
f0101154:	ff 30                	pushl  (%eax)
f0101156:	ff d7                	call   *%edi
			break;
f0101158:	83 c4 10             	add    $0x10,%esp
f010115b:	e9 b1 fe ff ff       	jmp    f0101011 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101160:	8b 45 14             	mov    0x14(%ebp),%eax
f0101163:	8d 50 04             	lea    0x4(%eax),%edx
f0101166:	89 55 14             	mov    %edx,0x14(%ebp)
f0101169:	8b 00                	mov    (%eax),%eax
f010116b:	99                   	cltd   
f010116c:	31 d0                	xor    %edx,%eax
f010116e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101170:	83 f8 06             	cmp    $0x6,%eax
f0101173:	7f 0b                	jg     f0101180 <vprintfmt+0x183>
f0101175:	8b 14 85 ec 24 10 f0 	mov    -0xfefdb14(,%eax,4),%edx
f010117c:	85 d2                	test   %edx,%edx
f010117e:	75 15                	jne    f0101195 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
f0101180:	50                   	push   %eax
f0101181:	68 a1 22 10 f0       	push   $0xf01022a1
f0101186:	53                   	push   %ebx
f0101187:	57                   	push   %edi
f0101188:	e8 53 fe ff ff       	call   f0100fe0 <printfmt>
f010118d:	83 c4 10             	add    $0x10,%esp
f0101190:	e9 7c fe ff ff       	jmp    f0101011 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f0101195:	52                   	push   %edx
f0101196:	68 aa 22 10 f0       	push   $0xf01022aa
f010119b:	53                   	push   %ebx
f010119c:	57                   	push   %edi
f010119d:	e8 3e fe ff ff       	call   f0100fe0 <printfmt>
f01011a2:	83 c4 10             	add    $0x10,%esp
f01011a5:	e9 67 fe ff ff       	jmp    f0101011 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01011aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ad:	8d 50 04             	lea    0x4(%eax),%edx
f01011b0:	89 55 14             	mov    %edx,0x14(%ebp)
f01011b3:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f01011b5:	85 c0                	test   %eax,%eax
f01011b7:	b9 9a 22 10 f0       	mov    $0xf010229a,%ecx
f01011bc:	0f 45 c8             	cmovne %eax,%ecx
f01011bf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f01011c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01011c6:	7e 06                	jle    f01011ce <vprintfmt+0x1d1>
f01011c8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f01011cc:	75 19                	jne    f01011e7 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01011d1:	8d 70 01             	lea    0x1(%eax),%esi
f01011d4:	0f b6 00             	movzbl (%eax),%eax
f01011d7:	0f be d0             	movsbl %al,%edx
f01011da:	85 d2                	test   %edx,%edx
f01011dc:	0f 85 9f 00 00 00    	jne    f0101281 <vprintfmt+0x284>
f01011e2:	e9 8c 00 00 00       	jmp    f0101273 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01011e7:	83 ec 08             	sub    $0x8,%esp
f01011ea:	ff 75 d0             	pushl  -0x30(%ebp)
f01011ed:	ff 75 cc             	pushl  -0x34(%ebp)
f01011f0:	e8 36 04 00 00       	call   f010162b <strnlen>
f01011f5:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f01011f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01011fb:	83 c4 10             	add    $0x10,%esp
f01011fe:	85 c9                	test   %ecx,%ecx
f0101200:	0f 8e a1 02 00 00    	jle    f01014a7 <vprintfmt+0x4aa>
					putch(padc, putdat);
f0101206:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f010120a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010120d:	89 cb                	mov    %ecx,%ebx
f010120f:	83 ec 08             	sub    $0x8,%esp
f0101212:	ff 75 0c             	pushl  0xc(%ebp)
f0101215:	56                   	push   %esi
f0101216:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101218:	83 c4 10             	add    $0x10,%esp
f010121b:	83 eb 01             	sub    $0x1,%ebx
f010121e:	75 ef                	jne    f010120f <vprintfmt+0x212>
f0101220:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101226:	e9 7c 02 00 00       	jmp    f01014a7 <vprintfmt+0x4aa>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010122b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010122f:	74 1b                	je     f010124c <vprintfmt+0x24f>
f0101231:	0f be c0             	movsbl %al,%eax
f0101234:	83 e8 20             	sub    $0x20,%eax
f0101237:	83 f8 5e             	cmp    $0x5e,%eax
f010123a:	76 10                	jbe    f010124c <vprintfmt+0x24f>
					putch('?', putdat);
f010123c:	83 ec 08             	sub    $0x8,%esp
f010123f:	ff 75 0c             	pushl  0xc(%ebp)
f0101242:	6a 3f                	push   $0x3f
f0101244:	ff 55 08             	call   *0x8(%ebp)
f0101247:	83 c4 10             	add    $0x10,%esp
f010124a:	eb 0d                	jmp    f0101259 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
f010124c:	83 ec 08             	sub    $0x8,%esp
f010124f:	ff 75 0c             	pushl  0xc(%ebp)
f0101252:	52                   	push   %edx
f0101253:	ff 55 08             	call   *0x8(%ebp)
f0101256:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101259:	83 ef 01             	sub    $0x1,%edi
f010125c:	83 c6 01             	add    $0x1,%esi
f010125f:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0101263:	0f be d0             	movsbl %al,%edx
f0101266:	85 d2                	test   %edx,%edx
f0101268:	75 31                	jne    f010129b <vprintfmt+0x29e>
f010126a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010126d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101273:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101276:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010127a:	7f 33                	jg     f01012af <vprintfmt+0x2b2>
f010127c:	e9 90 fd ff ff       	jmp    f0101011 <vprintfmt+0x14>
f0101281:	89 7d 08             	mov    %edi,0x8(%ebp)
f0101284:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101287:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010128a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010128d:	eb 0c                	jmp    f010129b <vprintfmt+0x29e>
f010128f:	89 7d 08             	mov    %edi,0x8(%ebp)
f0101292:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101295:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101298:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010129b:	85 db                	test   %ebx,%ebx
f010129d:	78 8c                	js     f010122b <vprintfmt+0x22e>
f010129f:	83 eb 01             	sub    $0x1,%ebx
f01012a2:	79 87                	jns    f010122b <vprintfmt+0x22e>
f01012a4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01012a7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012ad:	eb c4                	jmp    f0101273 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01012af:	83 ec 08             	sub    $0x8,%esp
f01012b2:	53                   	push   %ebx
f01012b3:	6a 20                	push   $0x20
f01012b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01012b7:	83 c4 10             	add    $0x10,%esp
f01012ba:	83 ee 01             	sub    $0x1,%esi
f01012bd:	75 f0                	jne    f01012af <vprintfmt+0x2b2>
f01012bf:	e9 4d fd ff ff       	jmp    f0101011 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01012c4:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f01012c8:	7e 16                	jle    f01012e0 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
f01012ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01012cd:	8d 50 08             	lea    0x8(%eax),%edx
f01012d0:	89 55 14             	mov    %edx,0x14(%ebp)
f01012d3:	8b 50 04             	mov    0x4(%eax),%edx
f01012d6:	8b 00                	mov    (%eax),%eax
f01012d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01012db:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01012de:	eb 34                	jmp    f0101314 <vprintfmt+0x317>
	else if (lflag)
f01012e0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01012e4:	74 18                	je     f01012fe <vprintfmt+0x301>
		return va_arg(*ap, long);
f01012e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e9:	8d 50 04             	lea    0x4(%eax),%edx
f01012ec:	89 55 14             	mov    %edx,0x14(%ebp)
f01012ef:	8b 30                	mov    (%eax),%esi
f01012f1:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01012f4:	89 f0                	mov    %esi,%eax
f01012f6:	c1 f8 1f             	sar    $0x1f,%eax
f01012f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012fc:	eb 16                	jmp    f0101314 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
f01012fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101301:	8d 50 04             	lea    0x4(%eax),%edx
f0101304:	89 55 14             	mov    %edx,0x14(%ebp)
f0101307:	8b 30                	mov    (%eax),%esi
f0101309:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010130c:	89 f0                	mov    %esi,%eax
f010130e:	c1 f8 1f             	sar    $0x1f,%eax
f0101311:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101314:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101317:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010131a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010131d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0101320:	85 d2                	test   %edx,%edx
f0101322:	79 28                	jns    f010134c <vprintfmt+0x34f>
				putch('-', putdat);
f0101324:	83 ec 08             	sub    $0x8,%esp
f0101327:	53                   	push   %ebx
f0101328:	6a 2d                	push   $0x2d
f010132a:	ff d7                	call   *%edi
				num = -(long long) num;
f010132c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010132f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101332:	f7 d8                	neg    %eax
f0101334:	83 d2 00             	adc    $0x0,%edx
f0101337:	f7 da                	neg    %edx
f0101339:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010133c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010133f:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
f0101342:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101347:	e9 b2 00 00 00       	jmp    f01013fe <vprintfmt+0x401>
f010134c:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
f0101351:	85 c9                	test   %ecx,%ecx
f0101353:	0f 84 a5 00 00 00    	je     f01013fe <vprintfmt+0x401>
				putch('+', putdat);
f0101359:	83 ec 08             	sub    $0x8,%esp
f010135c:	53                   	push   %ebx
f010135d:	6a 2b                	push   $0x2b
f010135f:	ff d7                	call   *%edi
f0101361:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
f0101364:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101369:	e9 90 00 00 00       	jmp    f01013fe <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
f010136e:	85 c9                	test   %ecx,%ecx
f0101370:	74 0b                	je     f010137d <vprintfmt+0x380>
				putch('+', putdat);
f0101372:	83 ec 08             	sub    $0x8,%esp
f0101375:	53                   	push   %ebx
f0101376:	6a 2b                	push   $0x2b
f0101378:	ff d7                	call   *%edi
f010137a:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
f010137d:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101380:	8d 45 14             	lea    0x14(%ebp),%eax
f0101383:	e8 01 fc ff ff       	call   f0100f89 <getuint>
f0101388:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010138b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f010138e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0101393:	eb 69                	jmp    f01013fe <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
f0101395:	83 ec 08             	sub    $0x8,%esp
f0101398:	53                   	push   %ebx
f0101399:	6a 30                	push   $0x30
f010139b:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f010139d:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01013a0:	8d 45 14             	lea    0x14(%ebp),%eax
f01013a3:	e8 e1 fb ff ff       	call   f0100f89 <getuint>
f01013a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f01013ae:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f01013b1:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01013b6:	eb 46                	jmp    f01013fe <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
f01013b8:	83 ec 08             	sub    $0x8,%esp
f01013bb:	53                   	push   %ebx
f01013bc:	6a 30                	push   $0x30
f01013be:	ff d7                	call   *%edi
			putch('x', putdat);
f01013c0:	83 c4 08             	add    $0x8,%esp
f01013c3:	53                   	push   %ebx
f01013c4:	6a 78                	push   $0x78
f01013c6:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01013c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01013cb:	8d 50 04             	lea    0x4(%eax),%edx
f01013ce:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01013d1:	8b 00                	mov    (%eax),%eax
f01013d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01013d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013db:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01013de:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01013e1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01013e6:	eb 16                	jmp    f01013fe <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01013e8:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01013eb:	8d 45 14             	lea    0x14(%ebp),%eax
f01013ee:	e8 96 fb ff ff       	call   f0100f89 <getuint>
f01013f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f01013f9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01013fe:	83 ec 0c             	sub    $0xc,%esp
f0101401:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0101405:	56                   	push   %esi
f0101406:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101409:	50                   	push   %eax
f010140a:	ff 75 dc             	pushl  -0x24(%ebp)
f010140d:	ff 75 d8             	pushl  -0x28(%ebp)
f0101410:	89 da                	mov    %ebx,%edx
f0101412:	89 f8                	mov    %edi,%eax
f0101414:	e8 55 f9 ff ff       	call   f0100d6e <printnum>
			break;
f0101419:	83 c4 20             	add    $0x20,%esp
f010141c:	e9 f0 fb ff ff       	jmp    f0101011 <vprintfmt+0x14>
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
						// cprintf("n: %d\n", *(char *)putdat);
						char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
f0101421:	8b 45 14             	mov    0x14(%ebp),%eax
f0101424:	8d 50 04             	lea    0x4(%eax),%edx
f0101427:	89 55 14             	mov    %edx,0x14(%ebp)
f010142a:	8b 00                	mov    (%eax),%eax
						if (!tmp) {
f010142c:	85 c0                	test   %eax,%eax
f010142e:	75 1a                	jne    f010144a <vprintfmt+0x44d>
							cprintf("%s", null_error);
f0101430:	83 ec 08             	sub    $0x8,%esp
f0101433:	68 18 23 10 f0       	push   $0xf0102318
f0101438:	68 aa 22 10 f0       	push   $0xf01022aa
f010143d:	e8 eb f5 ff ff       	call   f0100a2d <cprintf>
f0101442:	83 c4 10             	add    $0x10,%esp
f0101445:	e9 c7 fb ff ff       	jmp    f0101011 <vprintfmt+0x14>
						} else if ((*(char *)putdat) & 0x80) {
f010144a:	0f b6 13             	movzbl (%ebx),%edx
f010144d:	84 d2                	test   %dl,%dl
f010144f:	79 1a                	jns    f010146b <vprintfmt+0x46e>
							cprintf("%s", overflow_error);
f0101451:	83 ec 08             	sub    $0x8,%esp
f0101454:	68 50 23 10 f0       	push   $0xf0102350
f0101459:	68 aa 22 10 f0       	push   $0xf01022aa
f010145e:	e8 ca f5 ff ff       	call   f0100a2d <cprintf>
f0101463:	83 c4 10             	add    $0x10,%esp
f0101466:	e9 a6 fb ff ff       	jmp    f0101011 <vprintfmt+0x14>
						} else {
							*tmp = *(char *)putdat;
f010146b:	88 10                	mov    %dl,(%eax)
f010146d:	e9 9f fb ff ff       	jmp    f0101011 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101472:	83 ec 08             	sub    $0x8,%esp
f0101475:	53                   	push   %ebx
f0101476:	52                   	push   %edx
f0101477:	ff d7                	call   *%edi
			break;
f0101479:	83 c4 10             	add    $0x10,%esp
f010147c:	e9 90 fb ff ff       	jmp    f0101011 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101481:	83 ec 08             	sub    $0x8,%esp
f0101484:	53                   	push   %ebx
f0101485:	6a 25                	push   $0x25
f0101487:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101489:	83 c4 10             	add    $0x10,%esp
f010148c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101490:	0f 84 78 fb ff ff    	je     f010100e <vprintfmt+0x11>
f0101496:	83 ee 01             	sub    $0x1,%esi
f0101499:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010149d:	75 f7                	jne    f0101496 <vprintfmt+0x499>
f010149f:	89 75 10             	mov    %esi,0x10(%ebp)
f01014a2:	e9 6a fb ff ff       	jmp    f0101011 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01014a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01014aa:	8d 70 01             	lea    0x1(%eax),%esi
f01014ad:	0f b6 00             	movzbl (%eax),%eax
f01014b0:	0f be d0             	movsbl %al,%edx
f01014b3:	85 d2                	test   %edx,%edx
f01014b5:	0f 85 d4 fd ff ff    	jne    f010128f <vprintfmt+0x292>
f01014bb:	e9 51 fb ff ff       	jmp    f0101011 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01014c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014c3:	5b                   	pop    %ebx
f01014c4:	5e                   	pop    %esi
f01014c5:	5f                   	pop    %edi
f01014c6:	5d                   	pop    %ebp
f01014c7:	c3                   	ret    

f01014c8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01014c8:	55                   	push   %ebp
f01014c9:	89 e5                	mov    %esp,%ebp
f01014cb:	83 ec 18             	sub    $0x18,%esp
f01014ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01014d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014d7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01014db:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01014de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014e5:	85 c0                	test   %eax,%eax
f01014e7:	74 26                	je     f010150f <vsnprintf+0x47>
f01014e9:	85 d2                	test   %edx,%edx
f01014eb:	7e 22                	jle    f010150f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014ed:	ff 75 14             	pushl  0x14(%ebp)
f01014f0:	ff 75 10             	pushl  0x10(%ebp)
f01014f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014f6:	50                   	push   %eax
f01014f7:	68 c3 0f 10 f0       	push   $0xf0100fc3
f01014fc:	e8 fc fa ff ff       	call   f0100ffd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101501:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101504:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101507:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010150a:	83 c4 10             	add    $0x10,%esp
f010150d:	eb 05                	jmp    f0101514 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010150f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101514:	c9                   	leave  
f0101515:	c3                   	ret    

f0101516 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101516:	55                   	push   %ebp
f0101517:	89 e5                	mov    %esp,%ebp
f0101519:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010151c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010151f:	50                   	push   %eax
f0101520:	ff 75 10             	pushl  0x10(%ebp)
f0101523:	ff 75 0c             	pushl  0xc(%ebp)
f0101526:	ff 75 08             	pushl  0x8(%ebp)
f0101529:	e8 9a ff ff ff       	call   f01014c8 <vsnprintf>
	va_end(ap);

	return rc;
}
f010152e:	c9                   	leave  
f010152f:	c3                   	ret    

f0101530 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101530:	55                   	push   %ebp
f0101531:	89 e5                	mov    %esp,%ebp
f0101533:	57                   	push   %edi
f0101534:	56                   	push   %esi
f0101535:	53                   	push   %ebx
f0101536:	83 ec 0c             	sub    $0xc,%esp
f0101539:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010153c:	85 c0                	test   %eax,%eax
f010153e:	74 11                	je     f0101551 <readline+0x21>
		cprintf("%s", prompt);
f0101540:	83 ec 08             	sub    $0x8,%esp
f0101543:	50                   	push   %eax
f0101544:	68 aa 22 10 f0       	push   $0xf01022aa
f0101549:	e8 df f4 ff ff       	call   f0100a2d <cprintf>
f010154e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101551:	83 ec 0c             	sub    $0xc,%esp
f0101554:	6a 00                	push   $0x0
f0101556:	e8 e0 f1 ff ff       	call   f010073b <iscons>
f010155b:	89 c7                	mov    %eax,%edi
f010155d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101560:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101565:	e8 c0 f1 ff ff       	call   f010072a <getchar>
f010156a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010156c:	85 c0                	test   %eax,%eax
f010156e:	79 18                	jns    f0101588 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101570:	83 ec 08             	sub    $0x8,%esp
f0101573:	50                   	push   %eax
f0101574:	68 08 25 10 f0       	push   $0xf0102508
f0101579:	e8 af f4 ff ff       	call   f0100a2d <cprintf>
			return NULL;
f010157e:	83 c4 10             	add    $0x10,%esp
f0101581:	b8 00 00 00 00       	mov    $0x0,%eax
f0101586:	eb 79                	jmp    f0101601 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101588:	83 f8 08             	cmp    $0x8,%eax
f010158b:	0f 94 c2             	sete   %dl
f010158e:	83 f8 7f             	cmp    $0x7f,%eax
f0101591:	0f 94 c0             	sete   %al
f0101594:	08 c2                	or     %al,%dl
f0101596:	74 1a                	je     f01015b2 <readline+0x82>
f0101598:	85 f6                	test   %esi,%esi
f010159a:	7e 16                	jle    f01015b2 <readline+0x82>
			if (echoing)
f010159c:	85 ff                	test   %edi,%edi
f010159e:	74 0d                	je     f01015ad <readline+0x7d>
				cputchar('\b');
f01015a0:	83 ec 0c             	sub    $0xc,%esp
f01015a3:	6a 08                	push   $0x8
f01015a5:	e8 70 f1 ff ff       	call   f010071a <cputchar>
f01015aa:	83 c4 10             	add    $0x10,%esp
			i--;
f01015ad:	83 ee 01             	sub    $0x1,%esi
f01015b0:	eb b3                	jmp    f0101565 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01015b2:	83 fb 1f             	cmp    $0x1f,%ebx
f01015b5:	7e 23                	jle    f01015da <readline+0xaa>
f01015b7:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01015bd:	7f 1b                	jg     f01015da <readline+0xaa>
			if (echoing)
f01015bf:	85 ff                	test   %edi,%edi
f01015c1:	74 0c                	je     f01015cf <readline+0x9f>
				cputchar(c);
f01015c3:	83 ec 0c             	sub    $0xc,%esp
f01015c6:	53                   	push   %ebx
f01015c7:	e8 4e f1 ff ff       	call   f010071a <cputchar>
f01015cc:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01015cf:	88 9e 60 25 11 f0    	mov    %bl,-0xfeedaa0(%esi)
f01015d5:	8d 76 01             	lea    0x1(%esi),%esi
f01015d8:	eb 8b                	jmp    f0101565 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01015da:	83 fb 0a             	cmp    $0xa,%ebx
f01015dd:	74 05                	je     f01015e4 <readline+0xb4>
f01015df:	83 fb 0d             	cmp    $0xd,%ebx
f01015e2:	75 81                	jne    f0101565 <readline+0x35>
			if (echoing)
f01015e4:	85 ff                	test   %edi,%edi
f01015e6:	74 0d                	je     f01015f5 <readline+0xc5>
				cputchar('\n');
f01015e8:	83 ec 0c             	sub    $0xc,%esp
f01015eb:	6a 0a                	push   $0xa
f01015ed:	e8 28 f1 ff ff       	call   f010071a <cputchar>
f01015f2:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01015f5:	c6 86 60 25 11 f0 00 	movb   $0x0,-0xfeedaa0(%esi)
			return buf;
f01015fc:	b8 60 25 11 f0       	mov    $0xf0112560,%eax
		}
	}
}
f0101601:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101604:	5b                   	pop    %ebx
f0101605:	5e                   	pop    %esi
f0101606:	5f                   	pop    %edi
f0101607:	5d                   	pop    %ebp
f0101608:	c3                   	ret    

f0101609 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101609:	55                   	push   %ebp
f010160a:	89 e5                	mov    %esp,%ebp
f010160c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010160f:	80 3a 00             	cmpb   $0x0,(%edx)
f0101612:	74 10                	je     f0101624 <strlen+0x1b>
f0101614:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101619:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010161c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101620:	75 f7                	jne    f0101619 <strlen+0x10>
f0101622:	eb 05                	jmp    f0101629 <strlen+0x20>
f0101624:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101629:	5d                   	pop    %ebp
f010162a:	c3                   	ret    

f010162b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010162b:	55                   	push   %ebp
f010162c:	89 e5                	mov    %esp,%ebp
f010162e:	53                   	push   %ebx
f010162f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101632:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101635:	85 c9                	test   %ecx,%ecx
f0101637:	74 1c                	je     f0101655 <strnlen+0x2a>
f0101639:	80 3b 00             	cmpb   $0x0,(%ebx)
f010163c:	74 1e                	je     f010165c <strnlen+0x31>
f010163e:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0101643:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101645:	39 ca                	cmp    %ecx,%edx
f0101647:	74 18                	je     f0101661 <strnlen+0x36>
f0101649:	83 c2 01             	add    $0x1,%edx
f010164c:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0101651:	75 f0                	jne    f0101643 <strnlen+0x18>
f0101653:	eb 0c                	jmp    f0101661 <strnlen+0x36>
f0101655:	b8 00 00 00 00       	mov    $0x0,%eax
f010165a:	eb 05                	jmp    f0101661 <strnlen+0x36>
f010165c:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101661:	5b                   	pop    %ebx
f0101662:	5d                   	pop    %ebp
f0101663:	c3                   	ret    

f0101664 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101664:	55                   	push   %ebp
f0101665:	89 e5                	mov    %esp,%ebp
f0101667:	53                   	push   %ebx
f0101668:	8b 45 08             	mov    0x8(%ebp),%eax
f010166b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010166e:	89 c2                	mov    %eax,%edx
f0101670:	83 c2 01             	add    $0x1,%edx
f0101673:	83 c1 01             	add    $0x1,%ecx
f0101676:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010167a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010167d:	84 db                	test   %bl,%bl
f010167f:	75 ef                	jne    f0101670 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101681:	5b                   	pop    %ebx
f0101682:	5d                   	pop    %ebp
f0101683:	c3                   	ret    

f0101684 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101684:	55                   	push   %ebp
f0101685:	89 e5                	mov    %esp,%ebp
f0101687:	56                   	push   %esi
f0101688:	53                   	push   %ebx
f0101689:	8b 75 08             	mov    0x8(%ebp),%esi
f010168c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010168f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101692:	85 db                	test   %ebx,%ebx
f0101694:	74 17                	je     f01016ad <strncpy+0x29>
f0101696:	01 f3                	add    %esi,%ebx
f0101698:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f010169a:	83 c1 01             	add    $0x1,%ecx
f010169d:	0f b6 02             	movzbl (%edx),%eax
f01016a0:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01016a3:	80 3a 01             	cmpb   $0x1,(%edx)
f01016a6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01016a9:	39 cb                	cmp    %ecx,%ebx
f01016ab:	75 ed                	jne    f010169a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01016ad:	89 f0                	mov    %esi,%eax
f01016af:	5b                   	pop    %ebx
f01016b0:	5e                   	pop    %esi
f01016b1:	5d                   	pop    %ebp
f01016b2:	c3                   	ret    

f01016b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01016b3:	55                   	push   %ebp
f01016b4:	89 e5                	mov    %esp,%ebp
f01016b6:	56                   	push   %esi
f01016b7:	53                   	push   %ebx
f01016b8:	8b 75 08             	mov    0x8(%ebp),%esi
f01016bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016be:	8b 55 10             	mov    0x10(%ebp),%edx
f01016c1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01016c3:	85 d2                	test   %edx,%edx
f01016c5:	74 35                	je     f01016fc <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f01016c7:	89 d0                	mov    %edx,%eax
f01016c9:	83 e8 01             	sub    $0x1,%eax
f01016cc:	74 25                	je     f01016f3 <strlcpy+0x40>
f01016ce:	0f b6 0b             	movzbl (%ebx),%ecx
f01016d1:	84 c9                	test   %cl,%cl
f01016d3:	74 22                	je     f01016f7 <strlcpy+0x44>
f01016d5:	8d 53 01             	lea    0x1(%ebx),%edx
f01016d8:	01 c3                	add    %eax,%ebx
f01016da:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f01016dc:	83 c0 01             	add    $0x1,%eax
f01016df:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01016e2:	39 da                	cmp    %ebx,%edx
f01016e4:	74 13                	je     f01016f9 <strlcpy+0x46>
f01016e6:	83 c2 01             	add    $0x1,%edx
f01016e9:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f01016ed:	84 c9                	test   %cl,%cl
f01016ef:	75 eb                	jne    f01016dc <strlcpy+0x29>
f01016f1:	eb 06                	jmp    f01016f9 <strlcpy+0x46>
f01016f3:	89 f0                	mov    %esi,%eax
f01016f5:	eb 02                	jmp    f01016f9 <strlcpy+0x46>
f01016f7:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01016f9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016fc:	29 f0                	sub    %esi,%eax
}
f01016fe:	5b                   	pop    %ebx
f01016ff:	5e                   	pop    %esi
f0101700:	5d                   	pop    %ebp
f0101701:	c3                   	ret    

f0101702 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101702:	55                   	push   %ebp
f0101703:	89 e5                	mov    %esp,%ebp
f0101705:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101708:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010170b:	0f b6 01             	movzbl (%ecx),%eax
f010170e:	84 c0                	test   %al,%al
f0101710:	74 15                	je     f0101727 <strcmp+0x25>
f0101712:	3a 02                	cmp    (%edx),%al
f0101714:	75 11                	jne    f0101727 <strcmp+0x25>
		p++, q++;
f0101716:	83 c1 01             	add    $0x1,%ecx
f0101719:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010171c:	0f b6 01             	movzbl (%ecx),%eax
f010171f:	84 c0                	test   %al,%al
f0101721:	74 04                	je     f0101727 <strcmp+0x25>
f0101723:	3a 02                	cmp    (%edx),%al
f0101725:	74 ef                	je     f0101716 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101727:	0f b6 c0             	movzbl %al,%eax
f010172a:	0f b6 12             	movzbl (%edx),%edx
f010172d:	29 d0                	sub    %edx,%eax
}
f010172f:	5d                   	pop    %ebp
f0101730:	c3                   	ret    

f0101731 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101731:	55                   	push   %ebp
f0101732:	89 e5                	mov    %esp,%ebp
f0101734:	56                   	push   %esi
f0101735:	53                   	push   %ebx
f0101736:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101739:	8b 55 0c             	mov    0xc(%ebp),%edx
f010173c:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f010173f:	85 f6                	test   %esi,%esi
f0101741:	74 29                	je     f010176c <strncmp+0x3b>
f0101743:	0f b6 03             	movzbl (%ebx),%eax
f0101746:	84 c0                	test   %al,%al
f0101748:	74 30                	je     f010177a <strncmp+0x49>
f010174a:	3a 02                	cmp    (%edx),%al
f010174c:	75 2c                	jne    f010177a <strncmp+0x49>
f010174e:	8d 43 01             	lea    0x1(%ebx),%eax
f0101751:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f0101753:	89 c3                	mov    %eax,%ebx
f0101755:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101758:	39 c6                	cmp    %eax,%esi
f010175a:	74 17                	je     f0101773 <strncmp+0x42>
f010175c:	0f b6 08             	movzbl (%eax),%ecx
f010175f:	84 c9                	test   %cl,%cl
f0101761:	74 17                	je     f010177a <strncmp+0x49>
f0101763:	83 c0 01             	add    $0x1,%eax
f0101766:	3a 0a                	cmp    (%edx),%cl
f0101768:	74 e9                	je     f0101753 <strncmp+0x22>
f010176a:	eb 0e                	jmp    f010177a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010176c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101771:	eb 0f                	jmp    f0101782 <strncmp+0x51>
f0101773:	b8 00 00 00 00       	mov    $0x0,%eax
f0101778:	eb 08                	jmp    f0101782 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010177a:	0f b6 03             	movzbl (%ebx),%eax
f010177d:	0f b6 12             	movzbl (%edx),%edx
f0101780:	29 d0                	sub    %edx,%eax
}
f0101782:	5b                   	pop    %ebx
f0101783:	5e                   	pop    %esi
f0101784:	5d                   	pop    %ebp
f0101785:	c3                   	ret    

f0101786 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101786:	55                   	push   %ebp
f0101787:	89 e5                	mov    %esp,%ebp
f0101789:	53                   	push   %ebx
f010178a:	8b 45 08             	mov    0x8(%ebp),%eax
f010178d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0101790:	0f b6 10             	movzbl (%eax),%edx
f0101793:	84 d2                	test   %dl,%dl
f0101795:	74 1d                	je     f01017b4 <strchr+0x2e>
f0101797:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f0101799:	38 d3                	cmp    %dl,%bl
f010179b:	75 06                	jne    f01017a3 <strchr+0x1d>
f010179d:	eb 1a                	jmp    f01017b9 <strchr+0x33>
f010179f:	38 ca                	cmp    %cl,%dl
f01017a1:	74 16                	je     f01017b9 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01017a3:	83 c0 01             	add    $0x1,%eax
f01017a6:	0f b6 10             	movzbl (%eax),%edx
f01017a9:	84 d2                	test   %dl,%dl
f01017ab:	75 f2                	jne    f010179f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f01017ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01017b2:	eb 05                	jmp    f01017b9 <strchr+0x33>
f01017b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017b9:	5b                   	pop    %ebx
f01017ba:	5d                   	pop    %ebp
f01017bb:	c3                   	ret    

f01017bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01017bc:	55                   	push   %ebp
f01017bd:	89 e5                	mov    %esp,%ebp
f01017bf:	53                   	push   %ebx
f01017c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01017c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f01017c6:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f01017c9:	38 d3                	cmp    %dl,%bl
f01017cb:	74 14                	je     f01017e1 <strfind+0x25>
f01017cd:	89 d1                	mov    %edx,%ecx
f01017cf:	84 db                	test   %bl,%bl
f01017d1:	74 0e                	je     f01017e1 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01017d3:	83 c0 01             	add    $0x1,%eax
f01017d6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01017d9:	38 ca                	cmp    %cl,%dl
f01017db:	74 04                	je     f01017e1 <strfind+0x25>
f01017dd:	84 d2                	test   %dl,%dl
f01017df:	75 f2                	jne    f01017d3 <strfind+0x17>
			break;
	return (char *) s;
}
f01017e1:	5b                   	pop    %ebx
f01017e2:	5d                   	pop    %ebp
f01017e3:	c3                   	ret    

f01017e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01017e4:	55                   	push   %ebp
f01017e5:	89 e5                	mov    %esp,%ebp
f01017e7:	57                   	push   %edi
f01017e8:	56                   	push   %esi
f01017e9:	53                   	push   %ebx
f01017ea:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01017f0:	85 c9                	test   %ecx,%ecx
f01017f2:	74 36                	je     f010182a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01017f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01017fa:	75 28                	jne    f0101824 <memset+0x40>
f01017fc:	f6 c1 03             	test   $0x3,%cl
f01017ff:	75 23                	jne    f0101824 <memset+0x40>
		c &= 0xFF;
f0101801:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101805:	89 d3                	mov    %edx,%ebx
f0101807:	c1 e3 08             	shl    $0x8,%ebx
f010180a:	89 d6                	mov    %edx,%esi
f010180c:	c1 e6 18             	shl    $0x18,%esi
f010180f:	89 d0                	mov    %edx,%eax
f0101811:	c1 e0 10             	shl    $0x10,%eax
f0101814:	09 f0                	or     %esi,%eax
f0101816:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101818:	89 d8                	mov    %ebx,%eax
f010181a:	09 d0                	or     %edx,%eax
f010181c:	c1 e9 02             	shr    $0x2,%ecx
f010181f:	fc                   	cld    
f0101820:	f3 ab                	rep stos %eax,%es:(%edi)
f0101822:	eb 06                	jmp    f010182a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101824:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101827:	fc                   	cld    
f0101828:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010182a:	89 f8                	mov    %edi,%eax
f010182c:	5b                   	pop    %ebx
f010182d:	5e                   	pop    %esi
f010182e:	5f                   	pop    %edi
f010182f:	5d                   	pop    %ebp
f0101830:	c3                   	ret    

f0101831 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101831:	55                   	push   %ebp
f0101832:	89 e5                	mov    %esp,%ebp
f0101834:	57                   	push   %edi
f0101835:	56                   	push   %esi
f0101836:	8b 45 08             	mov    0x8(%ebp),%eax
f0101839:	8b 75 0c             	mov    0xc(%ebp),%esi
f010183c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010183f:	39 c6                	cmp    %eax,%esi
f0101841:	73 35                	jae    f0101878 <memmove+0x47>
f0101843:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101846:	39 d0                	cmp    %edx,%eax
f0101848:	73 2e                	jae    f0101878 <memmove+0x47>
		s += n;
		d += n;
f010184a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010184d:	89 d6                	mov    %edx,%esi
f010184f:	09 fe                	or     %edi,%esi
f0101851:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101857:	75 13                	jne    f010186c <memmove+0x3b>
f0101859:	f6 c1 03             	test   $0x3,%cl
f010185c:	75 0e                	jne    f010186c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010185e:	83 ef 04             	sub    $0x4,%edi
f0101861:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101864:	c1 e9 02             	shr    $0x2,%ecx
f0101867:	fd                   	std    
f0101868:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010186a:	eb 09                	jmp    f0101875 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010186c:	83 ef 01             	sub    $0x1,%edi
f010186f:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101872:	fd                   	std    
f0101873:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101875:	fc                   	cld    
f0101876:	eb 1d                	jmp    f0101895 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101878:	89 f2                	mov    %esi,%edx
f010187a:	09 c2                	or     %eax,%edx
f010187c:	f6 c2 03             	test   $0x3,%dl
f010187f:	75 0f                	jne    f0101890 <memmove+0x5f>
f0101881:	f6 c1 03             	test   $0x3,%cl
f0101884:	75 0a                	jne    f0101890 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101886:	c1 e9 02             	shr    $0x2,%ecx
f0101889:	89 c7                	mov    %eax,%edi
f010188b:	fc                   	cld    
f010188c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010188e:	eb 05                	jmp    f0101895 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101890:	89 c7                	mov    %eax,%edi
f0101892:	fc                   	cld    
f0101893:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101895:	5e                   	pop    %esi
f0101896:	5f                   	pop    %edi
f0101897:	5d                   	pop    %ebp
f0101898:	c3                   	ret    

f0101899 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101899:	55                   	push   %ebp
f010189a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010189c:	ff 75 10             	pushl  0x10(%ebp)
f010189f:	ff 75 0c             	pushl  0xc(%ebp)
f01018a2:	ff 75 08             	pushl  0x8(%ebp)
f01018a5:	e8 87 ff ff ff       	call   f0101831 <memmove>
}
f01018aa:	c9                   	leave  
f01018ab:	c3                   	ret    

f01018ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01018ac:	55                   	push   %ebp
f01018ad:	89 e5                	mov    %esp,%ebp
f01018af:	57                   	push   %edi
f01018b0:	56                   	push   %esi
f01018b1:	53                   	push   %ebx
f01018b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01018b5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01018b8:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018bb:	85 c0                	test   %eax,%eax
f01018bd:	74 39                	je     f01018f8 <memcmp+0x4c>
f01018bf:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f01018c2:	0f b6 13             	movzbl (%ebx),%edx
f01018c5:	0f b6 0e             	movzbl (%esi),%ecx
f01018c8:	38 ca                	cmp    %cl,%dl
f01018ca:	75 17                	jne    f01018e3 <memcmp+0x37>
f01018cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01018d1:	eb 1a                	jmp    f01018ed <memcmp+0x41>
f01018d3:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f01018d8:	83 c0 01             	add    $0x1,%eax
f01018db:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f01018df:	38 ca                	cmp    %cl,%dl
f01018e1:	74 0a                	je     f01018ed <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f01018e3:	0f b6 c2             	movzbl %dl,%eax
f01018e6:	0f b6 c9             	movzbl %cl,%ecx
f01018e9:	29 c8                	sub    %ecx,%eax
f01018eb:	eb 10                	jmp    f01018fd <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018ed:	39 f8                	cmp    %edi,%eax
f01018ef:	75 e2                	jne    f01018d3 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01018f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01018f6:	eb 05                	jmp    f01018fd <memcmp+0x51>
f01018f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018fd:	5b                   	pop    %ebx
f01018fe:	5e                   	pop    %esi
f01018ff:	5f                   	pop    %edi
f0101900:	5d                   	pop    %ebp
f0101901:	c3                   	ret    

f0101902 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101902:	55                   	push   %ebp
f0101903:	89 e5                	mov    %esp,%ebp
f0101905:	53                   	push   %ebx
f0101906:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f0101909:	89 d0                	mov    %edx,%eax
f010190b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f010190e:	39 c2                	cmp    %eax,%edx
f0101910:	73 1d                	jae    f010192f <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101912:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f0101916:	0f b6 0a             	movzbl (%edx),%ecx
f0101919:	39 d9                	cmp    %ebx,%ecx
f010191b:	75 09                	jne    f0101926 <memfind+0x24>
f010191d:	eb 14                	jmp    f0101933 <memfind+0x31>
f010191f:	0f b6 0a             	movzbl (%edx),%ecx
f0101922:	39 d9                	cmp    %ebx,%ecx
f0101924:	74 11                	je     f0101937 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101926:	83 c2 01             	add    $0x1,%edx
f0101929:	39 d0                	cmp    %edx,%eax
f010192b:	75 f2                	jne    f010191f <memfind+0x1d>
f010192d:	eb 0a                	jmp    f0101939 <memfind+0x37>
f010192f:	89 d0                	mov    %edx,%eax
f0101931:	eb 06                	jmp    f0101939 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101933:	89 d0                	mov    %edx,%eax
f0101935:	eb 02                	jmp    f0101939 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101937:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101939:	5b                   	pop    %ebx
f010193a:	5d                   	pop    %ebp
f010193b:	c3                   	ret    

f010193c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010193c:	55                   	push   %ebp
f010193d:	89 e5                	mov    %esp,%ebp
f010193f:	57                   	push   %edi
f0101940:	56                   	push   %esi
f0101941:	53                   	push   %ebx
f0101942:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101945:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101948:	0f b6 01             	movzbl (%ecx),%eax
f010194b:	3c 20                	cmp    $0x20,%al
f010194d:	74 04                	je     f0101953 <strtol+0x17>
f010194f:	3c 09                	cmp    $0x9,%al
f0101951:	75 0e                	jne    f0101961 <strtol+0x25>
		s++;
f0101953:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101956:	0f b6 01             	movzbl (%ecx),%eax
f0101959:	3c 20                	cmp    $0x20,%al
f010195b:	74 f6                	je     f0101953 <strtol+0x17>
f010195d:	3c 09                	cmp    $0x9,%al
f010195f:	74 f2                	je     f0101953 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101961:	3c 2b                	cmp    $0x2b,%al
f0101963:	75 0a                	jne    f010196f <strtol+0x33>
		s++;
f0101965:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101968:	bf 00 00 00 00       	mov    $0x0,%edi
f010196d:	eb 11                	jmp    f0101980 <strtol+0x44>
f010196f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101974:	3c 2d                	cmp    $0x2d,%al
f0101976:	75 08                	jne    f0101980 <strtol+0x44>
		s++, neg = 1;
f0101978:	83 c1 01             	add    $0x1,%ecx
f010197b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101980:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101986:	75 15                	jne    f010199d <strtol+0x61>
f0101988:	80 39 30             	cmpb   $0x30,(%ecx)
f010198b:	75 10                	jne    f010199d <strtol+0x61>
f010198d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101991:	75 7c                	jne    f0101a0f <strtol+0xd3>
		s += 2, base = 16;
f0101993:	83 c1 02             	add    $0x2,%ecx
f0101996:	bb 10 00 00 00       	mov    $0x10,%ebx
f010199b:	eb 16                	jmp    f01019b3 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f010199d:	85 db                	test   %ebx,%ebx
f010199f:	75 12                	jne    f01019b3 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01019a1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01019a6:	80 39 30             	cmpb   $0x30,(%ecx)
f01019a9:	75 08                	jne    f01019b3 <strtol+0x77>
		s++, base = 8;
f01019ab:	83 c1 01             	add    $0x1,%ecx
f01019ae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01019b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01019b8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01019bb:	0f b6 11             	movzbl (%ecx),%edx
f01019be:	8d 72 d0             	lea    -0x30(%edx),%esi
f01019c1:	89 f3                	mov    %esi,%ebx
f01019c3:	80 fb 09             	cmp    $0x9,%bl
f01019c6:	77 08                	ja     f01019d0 <strtol+0x94>
			dig = *s - '0';
f01019c8:	0f be d2             	movsbl %dl,%edx
f01019cb:	83 ea 30             	sub    $0x30,%edx
f01019ce:	eb 22                	jmp    f01019f2 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f01019d0:	8d 72 9f             	lea    -0x61(%edx),%esi
f01019d3:	89 f3                	mov    %esi,%ebx
f01019d5:	80 fb 19             	cmp    $0x19,%bl
f01019d8:	77 08                	ja     f01019e2 <strtol+0xa6>
			dig = *s - 'a' + 10;
f01019da:	0f be d2             	movsbl %dl,%edx
f01019dd:	83 ea 57             	sub    $0x57,%edx
f01019e0:	eb 10                	jmp    f01019f2 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f01019e2:	8d 72 bf             	lea    -0x41(%edx),%esi
f01019e5:	89 f3                	mov    %esi,%ebx
f01019e7:	80 fb 19             	cmp    $0x19,%bl
f01019ea:	77 16                	ja     f0101a02 <strtol+0xc6>
			dig = *s - 'A' + 10;
f01019ec:	0f be d2             	movsbl %dl,%edx
f01019ef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01019f2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01019f5:	7d 0b                	jge    f0101a02 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f01019f7:	83 c1 01             	add    $0x1,%ecx
f01019fa:	0f af 45 10          	imul   0x10(%ebp),%eax
f01019fe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101a00:	eb b9                	jmp    f01019bb <strtol+0x7f>

	if (endptr)
f0101a02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101a06:	74 0d                	je     f0101a15 <strtol+0xd9>
		*endptr = (char *) s;
f0101a08:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a0b:	89 0e                	mov    %ecx,(%esi)
f0101a0d:	eb 06                	jmp    f0101a15 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101a0f:	85 db                	test   %ebx,%ebx
f0101a11:	74 98                	je     f01019ab <strtol+0x6f>
f0101a13:	eb 9e                	jmp    f01019b3 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101a15:	89 c2                	mov    %eax,%edx
f0101a17:	f7 da                	neg    %edx
f0101a19:	85 ff                	test   %edi,%edi
f0101a1b:	0f 45 c2             	cmovne %edx,%eax
}
f0101a1e:	5b                   	pop    %ebx
f0101a1f:	5e                   	pop    %esi
f0101a20:	5f                   	pop    %edi
f0101a21:	5d                   	pop    %ebp
f0101a22:	c3                   	ret    
f0101a23:	66 90                	xchg   %ax,%ax
f0101a25:	66 90                	xchg   %ax,%ax
f0101a27:	66 90                	xchg   %ax,%ax
f0101a29:	66 90                	xchg   %ax,%ax
f0101a2b:	66 90                	xchg   %ax,%ax
f0101a2d:	66 90                	xchg   %ax,%ax
f0101a2f:	90                   	nop

f0101a30 <__udivdi3>:
f0101a30:	55                   	push   %ebp
f0101a31:	57                   	push   %edi
f0101a32:	56                   	push   %esi
f0101a33:	53                   	push   %ebx
f0101a34:	83 ec 1c             	sub    $0x1c,%esp
f0101a37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0101a3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0101a3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101a43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a47:	85 f6                	test   %esi,%esi
f0101a49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101a4d:	89 ca                	mov    %ecx,%edx
f0101a4f:	89 f8                	mov    %edi,%eax
f0101a51:	75 3d                	jne    f0101a90 <__udivdi3+0x60>
f0101a53:	39 cf                	cmp    %ecx,%edi
f0101a55:	0f 87 c5 00 00 00    	ja     f0101b20 <__udivdi3+0xf0>
f0101a5b:	85 ff                	test   %edi,%edi
f0101a5d:	89 fd                	mov    %edi,%ebp
f0101a5f:	75 0b                	jne    f0101a6c <__udivdi3+0x3c>
f0101a61:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a66:	31 d2                	xor    %edx,%edx
f0101a68:	f7 f7                	div    %edi
f0101a6a:	89 c5                	mov    %eax,%ebp
f0101a6c:	89 c8                	mov    %ecx,%eax
f0101a6e:	31 d2                	xor    %edx,%edx
f0101a70:	f7 f5                	div    %ebp
f0101a72:	89 c1                	mov    %eax,%ecx
f0101a74:	89 d8                	mov    %ebx,%eax
f0101a76:	89 cf                	mov    %ecx,%edi
f0101a78:	f7 f5                	div    %ebp
f0101a7a:	89 c3                	mov    %eax,%ebx
f0101a7c:	89 d8                	mov    %ebx,%eax
f0101a7e:	89 fa                	mov    %edi,%edx
f0101a80:	83 c4 1c             	add    $0x1c,%esp
f0101a83:	5b                   	pop    %ebx
f0101a84:	5e                   	pop    %esi
f0101a85:	5f                   	pop    %edi
f0101a86:	5d                   	pop    %ebp
f0101a87:	c3                   	ret    
f0101a88:	90                   	nop
f0101a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a90:	39 ce                	cmp    %ecx,%esi
f0101a92:	77 74                	ja     f0101b08 <__udivdi3+0xd8>
f0101a94:	0f bd fe             	bsr    %esi,%edi
f0101a97:	83 f7 1f             	xor    $0x1f,%edi
f0101a9a:	0f 84 98 00 00 00    	je     f0101b38 <__udivdi3+0x108>
f0101aa0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101aa5:	89 f9                	mov    %edi,%ecx
f0101aa7:	89 c5                	mov    %eax,%ebp
f0101aa9:	29 fb                	sub    %edi,%ebx
f0101aab:	d3 e6                	shl    %cl,%esi
f0101aad:	89 d9                	mov    %ebx,%ecx
f0101aaf:	d3 ed                	shr    %cl,%ebp
f0101ab1:	89 f9                	mov    %edi,%ecx
f0101ab3:	d3 e0                	shl    %cl,%eax
f0101ab5:	09 ee                	or     %ebp,%esi
f0101ab7:	89 d9                	mov    %ebx,%ecx
f0101ab9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101abd:	89 d5                	mov    %edx,%ebp
f0101abf:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101ac3:	d3 ed                	shr    %cl,%ebp
f0101ac5:	89 f9                	mov    %edi,%ecx
f0101ac7:	d3 e2                	shl    %cl,%edx
f0101ac9:	89 d9                	mov    %ebx,%ecx
f0101acb:	d3 e8                	shr    %cl,%eax
f0101acd:	09 c2                	or     %eax,%edx
f0101acf:	89 d0                	mov    %edx,%eax
f0101ad1:	89 ea                	mov    %ebp,%edx
f0101ad3:	f7 f6                	div    %esi
f0101ad5:	89 d5                	mov    %edx,%ebp
f0101ad7:	89 c3                	mov    %eax,%ebx
f0101ad9:	f7 64 24 0c          	mull   0xc(%esp)
f0101add:	39 d5                	cmp    %edx,%ebp
f0101adf:	72 10                	jb     f0101af1 <__udivdi3+0xc1>
f0101ae1:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101ae5:	89 f9                	mov    %edi,%ecx
f0101ae7:	d3 e6                	shl    %cl,%esi
f0101ae9:	39 c6                	cmp    %eax,%esi
f0101aeb:	73 07                	jae    f0101af4 <__udivdi3+0xc4>
f0101aed:	39 d5                	cmp    %edx,%ebp
f0101aef:	75 03                	jne    f0101af4 <__udivdi3+0xc4>
f0101af1:	83 eb 01             	sub    $0x1,%ebx
f0101af4:	31 ff                	xor    %edi,%edi
f0101af6:	89 d8                	mov    %ebx,%eax
f0101af8:	89 fa                	mov    %edi,%edx
f0101afa:	83 c4 1c             	add    $0x1c,%esp
f0101afd:	5b                   	pop    %ebx
f0101afe:	5e                   	pop    %esi
f0101aff:	5f                   	pop    %edi
f0101b00:	5d                   	pop    %ebp
f0101b01:	c3                   	ret    
f0101b02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b08:	31 ff                	xor    %edi,%edi
f0101b0a:	31 db                	xor    %ebx,%ebx
f0101b0c:	89 d8                	mov    %ebx,%eax
f0101b0e:	89 fa                	mov    %edi,%edx
f0101b10:	83 c4 1c             	add    $0x1c,%esp
f0101b13:	5b                   	pop    %ebx
f0101b14:	5e                   	pop    %esi
f0101b15:	5f                   	pop    %edi
f0101b16:	5d                   	pop    %ebp
f0101b17:	c3                   	ret    
f0101b18:	90                   	nop
f0101b19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b20:	89 d8                	mov    %ebx,%eax
f0101b22:	f7 f7                	div    %edi
f0101b24:	31 ff                	xor    %edi,%edi
f0101b26:	89 c3                	mov    %eax,%ebx
f0101b28:	89 d8                	mov    %ebx,%eax
f0101b2a:	89 fa                	mov    %edi,%edx
f0101b2c:	83 c4 1c             	add    $0x1c,%esp
f0101b2f:	5b                   	pop    %ebx
f0101b30:	5e                   	pop    %esi
f0101b31:	5f                   	pop    %edi
f0101b32:	5d                   	pop    %ebp
f0101b33:	c3                   	ret    
f0101b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b38:	39 ce                	cmp    %ecx,%esi
f0101b3a:	72 0c                	jb     f0101b48 <__udivdi3+0x118>
f0101b3c:	31 db                	xor    %ebx,%ebx
f0101b3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101b42:	0f 87 34 ff ff ff    	ja     f0101a7c <__udivdi3+0x4c>
f0101b48:	bb 01 00 00 00       	mov    $0x1,%ebx
f0101b4d:	e9 2a ff ff ff       	jmp    f0101a7c <__udivdi3+0x4c>
f0101b52:	66 90                	xchg   %ax,%ax
f0101b54:	66 90                	xchg   %ax,%ax
f0101b56:	66 90                	xchg   %ax,%ax
f0101b58:	66 90                	xchg   %ax,%ax
f0101b5a:	66 90                	xchg   %ax,%ax
f0101b5c:	66 90                	xchg   %ax,%ax
f0101b5e:	66 90                	xchg   %ax,%ax

f0101b60 <__umoddi3>:
f0101b60:	55                   	push   %ebp
f0101b61:	57                   	push   %edi
f0101b62:	56                   	push   %esi
f0101b63:	53                   	push   %ebx
f0101b64:	83 ec 1c             	sub    $0x1c,%esp
f0101b67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101b6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0101b6f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b77:	85 d2                	test   %edx,%edx
f0101b79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101b7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b81:	89 f3                	mov    %esi,%ebx
f0101b83:	89 3c 24             	mov    %edi,(%esp)
f0101b86:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b8a:	75 1c                	jne    f0101ba8 <__umoddi3+0x48>
f0101b8c:	39 f7                	cmp    %esi,%edi
f0101b8e:	76 50                	jbe    f0101be0 <__umoddi3+0x80>
f0101b90:	89 c8                	mov    %ecx,%eax
f0101b92:	89 f2                	mov    %esi,%edx
f0101b94:	f7 f7                	div    %edi
f0101b96:	89 d0                	mov    %edx,%eax
f0101b98:	31 d2                	xor    %edx,%edx
f0101b9a:	83 c4 1c             	add    $0x1c,%esp
f0101b9d:	5b                   	pop    %ebx
f0101b9e:	5e                   	pop    %esi
f0101b9f:	5f                   	pop    %edi
f0101ba0:	5d                   	pop    %ebp
f0101ba1:	c3                   	ret    
f0101ba2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ba8:	39 f2                	cmp    %esi,%edx
f0101baa:	89 d0                	mov    %edx,%eax
f0101bac:	77 52                	ja     f0101c00 <__umoddi3+0xa0>
f0101bae:	0f bd ea             	bsr    %edx,%ebp
f0101bb1:	83 f5 1f             	xor    $0x1f,%ebp
f0101bb4:	75 5a                	jne    f0101c10 <__umoddi3+0xb0>
f0101bb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0101bba:	0f 82 e0 00 00 00    	jb     f0101ca0 <__umoddi3+0x140>
f0101bc0:	39 0c 24             	cmp    %ecx,(%esp)
f0101bc3:	0f 86 d7 00 00 00    	jbe    f0101ca0 <__umoddi3+0x140>
f0101bc9:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101bcd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101bd1:	83 c4 1c             	add    $0x1c,%esp
f0101bd4:	5b                   	pop    %ebx
f0101bd5:	5e                   	pop    %esi
f0101bd6:	5f                   	pop    %edi
f0101bd7:	5d                   	pop    %ebp
f0101bd8:	c3                   	ret    
f0101bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101be0:	85 ff                	test   %edi,%edi
f0101be2:	89 fd                	mov    %edi,%ebp
f0101be4:	75 0b                	jne    f0101bf1 <__umoddi3+0x91>
f0101be6:	b8 01 00 00 00       	mov    $0x1,%eax
f0101beb:	31 d2                	xor    %edx,%edx
f0101bed:	f7 f7                	div    %edi
f0101bef:	89 c5                	mov    %eax,%ebp
f0101bf1:	89 f0                	mov    %esi,%eax
f0101bf3:	31 d2                	xor    %edx,%edx
f0101bf5:	f7 f5                	div    %ebp
f0101bf7:	89 c8                	mov    %ecx,%eax
f0101bf9:	f7 f5                	div    %ebp
f0101bfb:	89 d0                	mov    %edx,%eax
f0101bfd:	eb 99                	jmp    f0101b98 <__umoddi3+0x38>
f0101bff:	90                   	nop
f0101c00:	89 c8                	mov    %ecx,%eax
f0101c02:	89 f2                	mov    %esi,%edx
f0101c04:	83 c4 1c             	add    $0x1c,%esp
f0101c07:	5b                   	pop    %ebx
f0101c08:	5e                   	pop    %esi
f0101c09:	5f                   	pop    %edi
f0101c0a:	5d                   	pop    %ebp
f0101c0b:	c3                   	ret    
f0101c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c10:	8b 34 24             	mov    (%esp),%esi
f0101c13:	bf 20 00 00 00       	mov    $0x20,%edi
f0101c18:	89 e9                	mov    %ebp,%ecx
f0101c1a:	29 ef                	sub    %ebp,%edi
f0101c1c:	d3 e0                	shl    %cl,%eax
f0101c1e:	89 f9                	mov    %edi,%ecx
f0101c20:	89 f2                	mov    %esi,%edx
f0101c22:	d3 ea                	shr    %cl,%edx
f0101c24:	89 e9                	mov    %ebp,%ecx
f0101c26:	09 c2                	or     %eax,%edx
f0101c28:	89 d8                	mov    %ebx,%eax
f0101c2a:	89 14 24             	mov    %edx,(%esp)
f0101c2d:	89 f2                	mov    %esi,%edx
f0101c2f:	d3 e2                	shl    %cl,%edx
f0101c31:	89 f9                	mov    %edi,%ecx
f0101c33:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101c37:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101c3b:	d3 e8                	shr    %cl,%eax
f0101c3d:	89 e9                	mov    %ebp,%ecx
f0101c3f:	89 c6                	mov    %eax,%esi
f0101c41:	d3 e3                	shl    %cl,%ebx
f0101c43:	89 f9                	mov    %edi,%ecx
f0101c45:	89 d0                	mov    %edx,%eax
f0101c47:	d3 e8                	shr    %cl,%eax
f0101c49:	89 e9                	mov    %ebp,%ecx
f0101c4b:	09 d8                	or     %ebx,%eax
f0101c4d:	89 d3                	mov    %edx,%ebx
f0101c4f:	89 f2                	mov    %esi,%edx
f0101c51:	f7 34 24             	divl   (%esp)
f0101c54:	89 d6                	mov    %edx,%esi
f0101c56:	d3 e3                	shl    %cl,%ebx
f0101c58:	f7 64 24 04          	mull   0x4(%esp)
f0101c5c:	39 d6                	cmp    %edx,%esi
f0101c5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101c62:	89 d1                	mov    %edx,%ecx
f0101c64:	89 c3                	mov    %eax,%ebx
f0101c66:	72 08                	jb     f0101c70 <__umoddi3+0x110>
f0101c68:	75 11                	jne    f0101c7b <__umoddi3+0x11b>
f0101c6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101c6e:	73 0b                	jae    f0101c7b <__umoddi3+0x11b>
f0101c70:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101c74:	1b 14 24             	sbb    (%esp),%edx
f0101c77:	89 d1                	mov    %edx,%ecx
f0101c79:	89 c3                	mov    %eax,%ebx
f0101c7b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101c7f:	29 da                	sub    %ebx,%edx
f0101c81:	19 ce                	sbb    %ecx,%esi
f0101c83:	89 f9                	mov    %edi,%ecx
f0101c85:	89 f0                	mov    %esi,%eax
f0101c87:	d3 e0                	shl    %cl,%eax
f0101c89:	89 e9                	mov    %ebp,%ecx
f0101c8b:	d3 ea                	shr    %cl,%edx
f0101c8d:	89 e9                	mov    %ebp,%ecx
f0101c8f:	d3 ee                	shr    %cl,%esi
f0101c91:	09 d0                	or     %edx,%eax
f0101c93:	89 f2                	mov    %esi,%edx
f0101c95:	83 c4 1c             	add    $0x1c,%esp
f0101c98:	5b                   	pop    %ebx
f0101c99:	5e                   	pop    %esi
f0101c9a:	5f                   	pop    %edi
f0101c9b:	5d                   	pop    %ebp
f0101c9c:	c3                   	ret    
f0101c9d:	8d 76 00             	lea    0x0(%esi),%esi
f0101ca0:	29 f9                	sub    %edi,%ecx
f0101ca2:	19 d6                	sbb    %edx,%esi
f0101ca4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ca8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101cac:	e9 18 ff ff ff       	jmp    f0101bc9 <__umoddi3+0x69>
