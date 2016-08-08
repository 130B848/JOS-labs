
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
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

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
f010004b:	68 40 1f 10 f0       	push   $0xf0101f40
f0100050:	e8 fe 0b 00 00       	call   f0100c53 <cprintf>
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
f0100076:	e8 6f 09 00 00       	call   f01009ea <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 5c 1f 10 f0       	push   $0xf0101f5c
f0100087:	e8 c7 0b 00 00       	call   f0100c53 <cprintf>
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
f01000cb:	b8 60 39 11 f0       	mov    $0xf0113960,%eax
f01000d0:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f01000d5:	50                   	push   %eax
f01000d6:	6a 00                	push   $0x0
f01000d8:	68 00 33 11 f0       	push   $0xf0113300
f01000dd:	e8 7e 19 00 00       	call   f0101a60 <memset>

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
f01000f4:	68 f0 1f 10 f0       	push   $0xf0101ff0
f01000f9:	e8 55 0b 00 00       	call   f0100c53 <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f01000fe:	83 c4 18             	add    $0x18,%esp
f0100101:	6a 16                	push   $0x16
f0100103:	68 10 20 10 f0       	push   $0xf0102010
f0100108:	e8 46 0b 00 00       	call   f0100c53 <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f010010d:	83 c4 0c             	add    $0xc,%esp
f0100110:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f0100114:	50                   	push   %eax
f0100115:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0100119:	50                   	push   %eax
f010011a:	68 77 1f 10 f0       	push   $0xf0101f77
f010011f:	e8 2f 0b 00 00       	call   f0100c53 <cprintf>
	cprintf("%n", NULL);
f0100124:	83 c4 08             	add    $0x8,%esp
f0100127:	6a 00                	push   $0x0
f0100129:	68 90 1f 10 f0       	push   $0xf0101f90
f010012e:	e8 20 0b 00 00       	call   f0100c53 <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100133:	83 c4 0c             	add    $0xc,%esp
f0100136:	68 ff 00 00 00       	push   $0xff
f010013b:	6a 0d                	push   $0xd
f010013d:	8d 9d e6 fe ff ff    	lea    -0x11a(%ebp),%ebx
f0100143:	53                   	push   %ebx
f0100144:	e8 17 19 00 00       	call   f0101a60 <memset>
	cprintf("%s%n", ntest, &chnum1);
f0100149:	83 c4 0c             	add    $0xc,%esp
f010014c:	56                   	push   %esi
f010014d:	53                   	push   %ebx
f010014e:	68 8e 1f 10 f0       	push   $0xf0101f8e
f0100153:	e8 fb 0a 00 00       	call   f0100c53 <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f0100158:	83 c4 08             	add    $0x8,%esp
f010015b:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f010015f:	50                   	push   %eax
f0100160:	68 93 1f 10 f0       	push   $0xf0101f93
f0100165:	e8 e9 0a 00 00       	call   f0100c53 <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f010016a:	83 c4 0c             	add    $0xc,%esp
f010016d:	68 00 fc ff ff       	push   $0xfffffc00
f0100172:	68 00 04 00 00       	push   $0x400
f0100177:	68 9f 1f 10 f0       	push   $0xf0101f9f
f010017c:	e8 d2 0a 00 00       	call   f0100c53 <cprintf>


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
f0100195:	e8 33 09 00 00       	call   f0100acd <monitor>
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
f01001a7:	83 3d 00 33 11 f0 00 	cmpl   $0x0,0xf0113300
f01001ae:	75 37                	jne    f01001e7 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01001b0:	89 35 00 33 11 f0    	mov    %esi,0xf0113300

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
f01001c4:	68 bb 1f 10 f0       	push   $0xf0101fbb
f01001c9:	e8 85 0a 00 00       	call   f0100c53 <cprintf>
	vcprintf(fmt, ap);
f01001ce:	83 c4 08             	add    $0x8,%esp
f01001d1:	53                   	push   %ebx
f01001d2:	56                   	push   %esi
f01001d3:	e8 55 0a 00 00       	call   f0100c2d <vcprintf>
	cprintf("\n");
f01001d8:	c7 04 24 50 23 10 f0 	movl   $0xf0102350,(%esp)
f01001df:	e8 6f 0a 00 00       	call   f0100c53 <cprintf>
	va_end(ap);
f01001e4:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01001e7:	83 ec 0c             	sub    $0xc,%esp
f01001ea:	6a 00                	push   $0x0
f01001ec:	e8 dc 08 00 00       	call   f0100acd <monitor>
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
f0100206:	68 d3 1f 10 f0       	push   $0xf0101fd3
f010020b:	e8 43 0a 00 00       	call   f0100c53 <cprintf>
	vcprintf(fmt, ap);
f0100210:	83 c4 08             	add    $0x8,%esp
f0100213:	53                   	push   %ebx
f0100214:	ff 75 10             	pushl  0x10(%ebp)
f0100217:	e8 11 0a 00 00       	call   f0100c2d <vcprintf>
	cprintf("\n");
f010021c:	c7 04 24 50 23 10 f0 	movl   $0xf0102350,(%esp)
f0100223:	e8 2b 0a 00 00       	call   f0100c53 <cprintf>
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
f010025e:	8b 0d 44 35 11 f0    	mov    0xf0113544,%ecx
f0100264:	8d 51 01             	lea    0x1(%ecx),%edx
f0100267:	89 15 44 35 11 f0    	mov    %edx,0xf0113544
f010026d:	88 81 40 33 11 f0    	mov    %al,-0xfeeccc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100273:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100279:	75 0a                	jne    f0100285 <cons_intr+0x36>
			cons.wpos = 0;
f010027b:	c7 05 44 35 11 f0 00 	movl   $0x0,0xf0113544
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
f01002ac:	83 0d 20 33 11 f0 40 	orl    $0x40,0xf0113320
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
f01002c4:	8b 0d 20 33 11 f0    	mov    0xf0113320,%ecx
f01002ca:	89 cb                	mov    %ecx,%ebx
f01002cc:	83 e3 40             	and    $0x40,%ebx
f01002cf:	83 e0 7f             	and    $0x7f,%eax
f01002d2:	85 db                	test   %ebx,%ebx
f01002d4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002d7:	0f b6 d2             	movzbl %dl,%edx
f01002da:	0f b6 82 a0 21 10 f0 	movzbl -0xfefde60(%edx),%eax
f01002e1:	83 c8 40             	or     $0x40,%eax
f01002e4:	0f b6 c0             	movzbl %al,%eax
f01002e7:	f7 d0                	not    %eax
f01002e9:	21 c8                	and    %ecx,%eax
f01002eb:	a3 20 33 11 f0       	mov    %eax,0xf0113320
		return 0;
f01002f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f5:	e9 9e 00 00 00       	jmp    f0100398 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01002fa:	8b 0d 20 33 11 f0    	mov    0xf0113320,%ecx
f0100300:	f6 c1 40             	test   $0x40,%cl
f0100303:	74 0e                	je     f0100313 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100305:	83 c8 80             	or     $0xffffff80,%eax
f0100308:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010030a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010030d:	89 0d 20 33 11 f0    	mov    %ecx,0xf0113320
	}

	shift |= shiftcode[data];
f0100313:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100316:	0f b6 82 a0 21 10 f0 	movzbl -0xfefde60(%edx),%eax
f010031d:	0b 05 20 33 11 f0    	or     0xf0113320,%eax
f0100323:	0f b6 8a a0 20 10 f0 	movzbl -0xfefdf60(%edx),%ecx
f010032a:	31 c8                	xor    %ecx,%eax
f010032c:	a3 20 33 11 f0       	mov    %eax,0xf0113320

	c = charcode[shift & (CTL | SHIFT)][data];
f0100331:	89 c1                	mov    %eax,%ecx
f0100333:	83 e1 03             	and    $0x3,%ecx
f0100336:	8b 0c 8d 80 20 10 f0 	mov    -0xfefdf80(,%ecx,4),%ecx
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
f0100374:	68 3f 20 10 f0       	push   $0xf010203f
f0100379:	e8 d5 08 00 00       	call   f0100c53 <cprintf>
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
f010046a:	0f b7 05 48 35 11 f0 	movzwl 0xf0113548,%eax
f0100471:	66 85 c0             	test   %ax,%ax
f0100474:	0f 84 e6 00 00 00    	je     f0100560 <cons_putc+0x1c3>
			crt_pos--;
f010047a:	83 e8 01             	sub    $0x1,%eax
f010047d:	66 a3 48 35 11 f0    	mov    %ax,0xf0113548
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100483:	0f b7 c0             	movzwl %ax,%eax
f0100486:	66 81 e7 00 ff       	and    $0xff00,%di
f010048b:	83 cf 20             	or     $0x20,%edi
f010048e:	8b 15 4c 35 11 f0    	mov    0xf011354c,%edx
f0100494:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100498:	eb 78                	jmp    f0100512 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010049a:	66 83 05 48 35 11 f0 	addw   $0x50,0xf0113548
f01004a1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004a2:	0f b7 05 48 35 11 f0 	movzwl 0xf0113548,%eax
f01004a9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004af:	c1 e8 16             	shr    $0x16,%eax
f01004b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004b5:	c1 e0 04             	shl    $0x4,%eax
f01004b8:	66 a3 48 35 11 f0    	mov    %ax,0xf0113548
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
f01004f4:	0f b7 05 48 35 11 f0 	movzwl 0xf0113548,%eax
f01004fb:	8d 50 01             	lea    0x1(%eax),%edx
f01004fe:	66 89 15 48 35 11 f0 	mov    %dx,0xf0113548
f0100505:	0f b7 c0             	movzwl %ax,%eax
f0100508:	8b 15 4c 35 11 f0    	mov    0xf011354c,%edx
f010050e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100512:	66 81 3d 48 35 11 f0 	cmpw   $0x7cf,0xf0113548
f0100519:	cf 07 
f010051b:	76 43                	jbe    f0100560 <cons_putc+0x1c3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010051d:	a1 4c 35 11 f0       	mov    0xf011354c,%eax
f0100522:	83 ec 04             	sub    $0x4,%esp
f0100525:	68 00 0f 00 00       	push   $0xf00
f010052a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100530:	52                   	push   %edx
f0100531:	50                   	push   %eax
f0100532:	e8 76 15 00 00       	call   f0101aad <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100537:	8b 15 4c 35 11 f0    	mov    0xf011354c,%edx
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
f0100558:	66 83 2d 48 35 11 f0 	subw   $0x50,0xf0113548
f010055f:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100560:	8b 0d 50 35 11 f0    	mov    0xf0113550,%ecx
f0100566:	b8 0e 00 00 00       	mov    $0xe,%eax
f010056b:	89 ca                	mov    %ecx,%edx
f010056d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010056e:	0f b7 1d 48 35 11 f0 	movzwl 0xf0113548,%ebx
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
f0100596:	83 3d 54 35 11 f0 00 	cmpl   $0x0,0xf0113554
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
f01005d4:	a1 40 35 11 f0       	mov    0xf0113540,%eax
f01005d9:	3b 05 44 35 11 f0    	cmp    0xf0113544,%eax
f01005df:	74 26                	je     f0100607 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005e1:	8d 50 01             	lea    0x1(%eax),%edx
f01005e4:	89 15 40 35 11 f0    	mov    %edx,0xf0113540
f01005ea:	0f b6 88 40 33 11 f0 	movzbl -0xfeeccc0(%eax),%ecx
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
f01005fb:	c7 05 40 35 11 f0 00 	movl   $0x0,0xf0113540
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
f0100634:	c7 05 50 35 11 f0 b4 	movl   $0x3b4,0xf0113550
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
f010064c:	c7 05 50 35 11 f0 d4 	movl   $0x3d4,0xf0113550
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
f010065b:	8b 3d 50 35 11 f0    	mov    0xf0113550,%edi
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
f0100680:	89 35 4c 35 11 f0    	mov    %esi,0xf011354c
	crt_pos = pos;
f0100686:	0f b6 c0             	movzbl %al,%eax
f0100689:	09 c8                	or     %ecx,%eax
f010068b:	66 a3 48 35 11 f0    	mov    %ax,0xf0113548
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
f01006f2:	a3 54 35 11 f0       	mov    %eax,0xf0113554
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
f0100705:	68 4b 20 10 f0       	push   $0xf010204b
f010070a:	e8 44 05 00 00       	call   f0100c53 <cprintf>
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
f010074a:	bb a0 25 10 f0       	mov    $0xf01025a0,%ebx
f010074f:	be d0 25 10 f0       	mov    $0xf01025d0,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100754:	83 ec 04             	sub    $0x4,%esp
f0100757:	ff 73 04             	pushl  0x4(%ebx)
f010075a:	ff 33                	pushl  (%ebx)
f010075c:	68 a0 22 10 f0       	push   $0xf01022a0
f0100761:	e8 ed 04 00 00       	call   f0100c53 <cprintf>
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
f0100782:	68 a9 22 10 f0       	push   $0xf01022a9
f0100787:	e8 c7 04 00 00       	call   f0100c53 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010078c:	83 c4 0c             	add    $0xc,%esp
f010078f:	68 0c 00 10 00       	push   $0x10000c
f0100794:	68 0c 00 10 f0       	push   $0xf010000c
f0100799:	68 cc 23 10 f0       	push   $0xf01023cc
f010079e:	e8 b0 04 00 00       	call   f0100c53 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a3:	83 c4 0c             	add    $0xc,%esp
f01007a6:	68 21 1f 10 00       	push   $0x101f21
f01007ab:	68 21 1f 10 f0       	push   $0xf0101f21
f01007b0:	68 f0 23 10 f0       	push   $0xf01023f0
f01007b5:	e8 99 04 00 00       	call   f0100c53 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007ba:	83 c4 0c             	add    $0xc,%esp
f01007bd:	68 00 33 11 00       	push   $0x113300
f01007c2:	68 00 33 11 f0       	push   $0xf0113300
f01007c7:	68 14 24 10 f0       	push   $0xf0102414
f01007cc:	e8 82 04 00 00       	call   f0100c53 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007d1:	83 c4 0c             	add    $0xc,%esp
f01007d4:	68 60 39 11 00       	push   $0x113960
f01007d9:	68 60 39 11 f0       	push   $0xf0113960
f01007de:	68 38 24 10 f0       	push   $0xf0102438
f01007e3:	e8 6b 04 00 00       	call   f0100c53 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007e8:	83 c4 08             	add    $0x8,%esp
f01007eb:	b8 5f 3d 11 f0       	mov    $0xf0113d5f,%eax
f01007f0:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007f5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007fb:	85 c0                	test   %eax,%eax
f01007fd:	0f 48 c2             	cmovs  %edx,%eax
f0100800:	c1 f8 0a             	sar    $0xa,%eax
f0100803:	50                   	push   %eax
f0100804:	68 5c 24 10 f0       	push   $0xf010245c
f0100809:	e8 45 04 00 00       	call   f0100c53 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f010080e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100813:	c9                   	leave  
f0100814:	c3                   	ret    

f0100815 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f0100815:	55                   	push   %ebp
f0100816:	89 e5                	mov    %esp,%ebp
f0100818:	83 ec 14             	sub    $0x14,%esp
    cprintf("Overflow success\n");
f010081b:	68 c2 22 10 f0       	push   $0xf01022c2
f0100820:	e8 2e 04 00 00       	call   f0100c53 <cprintf>
		// gcc's optimization differs
		cprintf("Backtrace success\n");
f0100825:	c7 04 24 d4 22 10 f0 	movl   $0xf01022d4,(%esp)
f010082c:	e8 22 04 00 00       	call   f0100c53 <cprintf>
}
f0100831:	83 c4 10             	add    $0x10,%esp
f0100834:	c9                   	leave  
f0100835:	c3                   	ret    

f0100836 <mon_time>:
	return (((uint64_t)high << 32) | low);
}

int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f0100836:	55                   	push   %ebp
f0100837:	89 e5                	mov    %esp,%ebp
f0100839:	57                   	push   %edi
f010083a:	56                   	push   %esi
f010083b:	53                   	push   %ebx
f010083c:	83 ec 1c             	sub    $0x1c,%esp
f010083f:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100842:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100846:	74 0c                	je     f0100854 <mon_time+0x1e>
f0100848:	bf a0 25 10 f0       	mov    $0xf01025a0,%edi
f010084d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100852:	eb 1d                	jmp    f0100871 <mon_time+0x3b>
		cprintf("Usage: time [command]\n");
f0100854:	83 ec 0c             	sub    $0xc,%esp
f0100857:	68 e7 22 10 f0       	push   $0xf01022e7
f010085c:	e8 f2 03 00 00       	call   f0100c53 <cprintf>
		return 0;
f0100861:	83 c4 10             	add    $0x10,%esp
f0100864:	eb 7a                	jmp    f01008e0 <mon_time+0xaa>
	}

	int i;
	for (i = 0; i < NCOMMANDS && strcmp(argv[1], commands[i].name); i++)
f0100866:	83 c3 01             	add    $0x1,%ebx
f0100869:	83 c7 0c             	add    $0xc,%edi
f010086c:	83 fb 04             	cmp    $0x4,%ebx
f010086f:	74 19                	je     f010088a <mon_time+0x54>
f0100871:	83 ec 08             	sub    $0x8,%esp
f0100874:	ff 37                	pushl  (%edi)
f0100876:	ff 76 04             	pushl  0x4(%esi)
f0100879:	e8 00 11 00 00       	call   f010197e <strcmp>
f010087e:	83 c4 10             	add    $0x10,%esp
f0100881:	85 c0                	test   %eax,%eax
f0100883:	75 e1                	jne    f0100866 <mon_time+0x30>
		;

	if (i == NCOMMANDS) {
f0100885:	83 fb 04             	cmp    $0x4,%ebx
f0100888:	75 15                	jne    f010089f <mon_time+0x69>
		cprintf("Unknown command: %s\n", argv[1]);
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	ff 76 04             	pushl  0x4(%esi)
f0100890:	68 fe 22 10 f0       	push   $0xf01022fe
f0100895:	e8 b9 03 00 00       	call   f0100c53 <cprintf>
		return 0;
f010089a:	83 c4 10             	add    $0x10,%esp
f010089d:	eb 41                	jmp    f01008e0 <mon_time+0xaa>
/***** Implementations of basic kernel monitor commands *****/
uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f010089f:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
f01008a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01008a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		cprintf("Unknown command: %s\n", argv[1]);
		return 0;
	}

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
f01008a7:	83 ec 04             	sub    $0x4,%esp
f01008aa:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f01008ad:	ff 75 10             	pushl  0x10(%ebp)
f01008b0:	8d 46 04             	lea    0x4(%esi),%eax
f01008b3:	50                   	push   %eax
f01008b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01008b7:	83 e8 01             	sub    $0x1,%eax
f01008ba:	50                   	push   %eax
f01008bb:	ff 14 95 a8 25 10 f0 	call   *-0xfefda58(,%edx,4)
/***** Implementations of basic kernel monitor commands *****/
uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f01008c2:	0f 31                	rdtsc  

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
	uint64_t end = rdtsc();

	cprintf("%s cycles: %llu\n", argv[1], end - start);
f01008c4:	89 c1                	mov    %eax,%ecx
f01008c6:	89 d3                	mov    %edx,%ebx
f01008c8:	2b 4d e0             	sub    -0x20(%ebp),%ecx
f01008cb:	1b 5d e4             	sbb    -0x1c(%ebp),%ebx
f01008ce:	53                   	push   %ebx
f01008cf:	51                   	push   %ecx
f01008d0:	ff 76 04             	pushl  0x4(%esi)
f01008d3:	68 13 23 10 f0       	push   $0xf0102313
f01008d8:	e8 76 03 00 00       	call   f0100c53 <cprintf>

	return 0;
f01008dd:	83 c4 20             	add    $0x20,%esp
}
f01008e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008e8:	5b                   	pop    %ebx
f01008e9:	5e                   	pop    %esi
f01008ea:	5f                   	pop    %edi
f01008eb:	5d                   	pop    %ebp
f01008ec:	c3                   	ret    

f01008ed <rdtsc>:
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/
uint64_t
rdtsc()
{
f01008ed:	55                   	push   %ebp
f01008ee:	89 e5                	mov    %esp,%ebp
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f01008f0:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
}
f01008f2:	5d                   	pop    %ebp
f01008f3:	c3                   	ret    

f01008f4 <start_overflow>:

#define get_ret_byte(addr, off) ((addr >> (off * 8)) & 0xff)

void
start_overflow(void)
{
f01008f4:	55                   	push   %ebp
f01008f5:	89 e5                	mov    %esp,%ebp
f01008f7:	57                   	push   %edi
f01008f8:	56                   	push   %esi
f01008f9:	53                   	push   %ebx
f01008fa:	81 ec 20 01 00 00    	sub    $0x120,%esp
	// you augmented in the "Exercise 9" to do this job.

	// hint: You can use the read_pretaddr function to retrieve
	//       the pointer to the function call return address;

	char str[256] = {};
f0100900:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f0100906:	b9 40 00 00 00       	mov    $0x40,%ecx
f010090b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100910:	f3 ab                	rep stos %eax,%es:(%edi)
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr));
f0100912:	8d 5d 04             	lea    0x4(%ebp),%ebx
	int nstr = 0;
	char *pret_addr;

	// Your code here.
	pret_addr = (char *) read_pretaddr();
	memset(str, 0x11, 256);
f0100915:	68 00 01 00 00       	push   $0x100
f010091a:	6a 11                	push   $0x11
f010091c:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
f0100922:	56                   	push   %esi
f0100923:	e8 38 11 00 00       	call   f0101a60 <memset>
	uint32_t ret_addr = (uint32_t) do_overflow + 3;	// ignore push ebp, mov esp, ebp

	// *(uint32_t *)pret_addr = ret_addr;
	// cprintf("0x%x\n", pret_addr);

	str[get_ret_byte(ret_addr, 0)] = 0;
f0100928:	c7 85 e4 fe ff ff 18 	movl   $0xf0100818,-0x11c(%ebp)
f010092f:	08 10 f0 
f0100932:	0f b6 bd e4 fe ff ff 	movzbl -0x11c(%ebp),%edi
f0100939:	c6 84 3d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edi,1)
f0100940:	00 
	cprintf("%s%n\n", str, pret_addr);
f0100941:	83 c4 0c             	add    $0xc,%esp
f0100944:	53                   	push   %ebx
f0100945:	56                   	push   %esi
f0100946:	68 24 23 10 f0       	push   $0xf0102324
f010094b:	e8 03 03 00 00       	call   f0100c53 <cprintf>

	str[get_ret_byte(ret_addr, 0)] = 0x11;
f0100950:	c6 84 3d e8 fe ff ff 	movb   $0x11,-0x118(%ebp,%edi,1)
f0100957:	11 
	str[get_ret_byte(ret_addr, 1)] = 0;
f0100958:	b8 18 08 10 f0       	mov    $0xf0100818,%eax
f010095d:	0f b6 fc             	movzbl %ah,%edi
f0100960:	c6 84 3d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edi,1)
f0100967:	00 
	cprintf("%s%n\n", str, pret_addr + 1);
f0100968:	83 c4 0c             	add    $0xc,%esp
f010096b:	8d 43 01             	lea    0x1(%ebx),%eax
f010096e:	50                   	push   %eax
f010096f:	56                   	push   %esi
f0100970:	68 24 23 10 f0       	push   $0xf0102324
f0100975:	e8 d9 02 00 00       	call   f0100c53 <cprintf>

	str[get_ret_byte(ret_addr, 1)] = 0x11;
f010097a:	c6 84 3d e8 fe ff ff 	movb   $0x11,-0x118(%ebp,%edi,1)
f0100981:	11 
	str[get_ret_byte(ret_addr, 2)] = 0;
f0100982:	b8 18 08 10 f0       	mov    $0xf0100818,%eax
f0100987:	c1 e8 10             	shr    $0x10,%eax
f010098a:	0f b6 f8             	movzbl %al,%edi
f010098d:	c6 84 3d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edi,1)
f0100994:	00 
	cprintf("%s%n\n", str, pret_addr + 2);
f0100995:	83 c4 0c             	add    $0xc,%esp
f0100998:	8d 43 02             	lea    0x2(%ebx),%eax
f010099b:	50                   	push   %eax
f010099c:	56                   	push   %esi
f010099d:	68 24 23 10 f0       	push   $0xf0102324
f01009a2:	e8 ac 02 00 00       	call   f0100c53 <cprintf>

	str[get_ret_byte(ret_addr, 2)] = 0x11;
f01009a7:	c6 84 3d e8 fe ff ff 	movb   $0x11,-0x118(%ebp,%edi,1)
f01009ae:	11 
	str[get_ret_byte(ret_addr, 3)] = 0;
f01009af:	b8 18 08 10 f0       	mov    $0xf0100818,%eax
f01009b4:	c1 e8 18             	shr    $0x18,%eax
f01009b7:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f01009be:	00 
	cprintf("%s%n\n", str, pret_addr + 3);
f01009bf:	83 c4 0c             	add    $0xc,%esp
f01009c2:	8d 43 03             	lea    0x3(%ebx),%eax
f01009c5:	50                   	push   %eax
f01009c6:	56                   	push   %esi
f01009c7:	68 24 23 10 f0       	push   $0xf0102324
f01009cc:	e8 82 02 00 00       	call   f0100c53 <cprintf>
	cprintf("0x%x\n", pret_addr);
f01009d1:	83 c4 08             	add    $0x8,%esp
f01009d4:	53                   	push   %ebx
f01009d5:	68 2a 23 10 f0       	push   $0xf010232a
f01009da:	e8 74 02 00 00       	call   f0100c53 <cprintf>
}
f01009df:	83 c4 10             	add    $0x10,%esp
f01009e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009e5:	5b                   	pop    %ebx
f01009e6:	5e                   	pop    %esi
f01009e7:	5f                   	pop    %edi
f01009e8:	5d                   	pop    %ebp
f01009e9:	c3                   	ret    

f01009ea <mon_backtrace>:

#define EBP_OFFSET(ebp, offset) (*((uint32_t *)(ebp) + (offset)))

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01009ea:	55                   	push   %ebp
f01009eb:	89 e5                	mov    %esp,%ebp
f01009ed:	57                   	push   %edi
f01009ee:	56                   	push   %esi
f01009ef:	53                   	push   %ebx
f01009f0:	83 ec 48             	sub    $0x48,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01009f3:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
f01009f5:	68 30 23 10 f0       	push   $0xf0102330
f01009fa:	e8 54 02 00 00       	call   f0100c53 <cprintf>
	while(ebp != 0x0) {
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	85 f6                	test   %esi,%esi
f0100a04:	0f 84 97 00 00 00    	je     f0100aa1 <mon_backtrace+0xb7>
f0100a0a:	89 f3                	mov    %esi,%ebx
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f0100a0c:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100a0f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
		eip = EBP_OFFSET(ebp, 1);
f0100a12:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
f0100a15:	ff 73 18             	pushl  0x18(%ebx)
f0100a18:	ff 73 14             	pushl  0x14(%ebx)
f0100a1b:	ff 73 10             	pushl  0x10(%ebx)
f0100a1e:	ff 73 0c             	pushl  0xc(%ebx)
f0100a21:	ff 73 08             	pushl  0x8(%ebx)
f0100a24:	53                   	push   %ebx
f0100a25:	56                   	push   %esi
f0100a26:	68 88 24 10 f0       	push   $0xf0102488
f0100a2b:	e8 23 02 00 00       	call   f0100c53 <cprintf>
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f0100a30:	83 c4 18             	add    $0x18,%esp
f0100a33:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100a36:	56                   	push   %esi
f0100a37:	e8 57 03 00 00       	call   f0100d93 <debuginfo_eip>
f0100a3c:	83 c4 10             	add    $0x10,%esp
f0100a3f:	85 c0                	test   %eax,%eax
f0100a41:	75 54                	jne    f0100a97 <mon_backtrace+0xad>
f0100a43:	89 65 c0             	mov    %esp,-0x40(%ebp)
			char func_name[info.eip_fn_namelen + 1];
f0100a46:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100a49:	8d 41 10             	lea    0x10(%ecx),%eax
f0100a4c:	bf 10 00 00 00       	mov    $0x10,%edi
f0100a51:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a56:	f7 f7                	div    %edi
f0100a58:	c1 e0 04             	shl    $0x4,%eax
f0100a5b:	29 c4                	sub    %eax,%esp
f0100a5d:	89 e0                	mov    %esp,%eax
f0100a5f:	89 e7                	mov    %esp,%edi
			func_name[info.eip_fn_namelen] = '\0';
f0100a61:	c6 04 0c 00          	movb   $0x0,(%esp,%ecx,1)
			if (strncpy(func_name, info.eip_fn_name, info.eip_fn_namelen)) {
f0100a65:	83 ec 04             	sub    $0x4,%esp
f0100a68:	51                   	push   %ecx
f0100a69:	ff 75 d8             	pushl  -0x28(%ebp)
f0100a6c:	50                   	push   %eax
f0100a6d:	e8 8e 0e 00 00       	call   f0101900 <strncpy>
f0100a72:	83 c4 10             	add    $0x10,%esp
f0100a75:	85 c0                	test   %eax,%eax
f0100a77:	74 1b                	je     f0100a94 <mon_backtrace+0xaa>
				cprintf("\t%s:%d: %s+%x\n\n", info.eip_file, info.eip_line,
f0100a79:	83 ec 0c             	sub    $0xc,%esp
f0100a7c:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100a7f:	56                   	push   %esi
f0100a80:	57                   	push   %edi
f0100a81:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100a84:	ff 75 d0             	pushl  -0x30(%ebp)
f0100a87:	68 42 23 10 f0       	push   $0xf0102342
f0100a8c:	e8 c2 01 00 00       	call   f0100c53 <cprintf>
f0100a91:	83 c4 20             	add    $0x20,%esp
f0100a94:	8b 65 c0             	mov    -0x40(%ebp),%esp
				func_name, eip - info.eip_fn_addr);
			}
		}
		// warning: the value of ebp to print is register value, not stack value
		ebp = EBP_OFFSET(ebp, 0);
f0100a97:	8b 1b                	mov    (%ebx),%ebx
{
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
f0100a99:	85 db                	test   %ebx,%ebx
f0100a9b:	0f 85 71 ff ff ff    	jne    f0100a12 <mon_backtrace+0x28>
}

void
overflow_me(void)
{
	start_overflow();
f0100aa1:	e8 4e fe ff ff       	call   f01008f4 <start_overflow>
		// warning: the value of ebp to print is register value, not stack value
		ebp = EBP_OFFSET(ebp, 0);
	}

	overflow_me();
	cprintf("Backtrace success\n");
f0100aa6:	83 ec 0c             	sub    $0xc,%esp
f0100aa9:	68 d4 22 10 f0       	push   $0xf01022d4
f0100aae:	e8 a0 01 00 00       	call   f0100c53 <cprintf>
	return 0;
}
f0100ab3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ab8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100abb:	5b                   	pop    %ebx
f0100abc:	5e                   	pop    %esi
f0100abd:	5f                   	pop    %edi
f0100abe:	5d                   	pop    %ebp
f0100abf:	c3                   	ret    

f0100ac0 <overflow_me>:
	cprintf("0x%x\n", pret_addr);
}

void
overflow_me(void)
{
f0100ac0:	55                   	push   %ebp
f0100ac1:	89 e5                	mov    %esp,%ebp
f0100ac3:	83 ec 08             	sub    $0x8,%esp
	start_overflow();
f0100ac6:	e8 29 fe ff ff       	call   f01008f4 <start_overflow>
}
f0100acb:	c9                   	leave  
f0100acc:	c3                   	ret    

f0100acd <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100acd:	55                   	push   %ebp
f0100ace:	89 e5                	mov    %esp,%ebp
f0100ad0:	57                   	push   %edi
f0100ad1:	56                   	push   %esi
f0100ad2:	53                   	push   %ebx
f0100ad3:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ad6:	68 c0 24 10 f0       	push   $0xf01024c0
f0100adb:	e8 73 01 00 00       	call   f0100c53 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ae0:	c7 04 24 e4 24 10 f0 	movl   $0xf01024e4,(%esp)
f0100ae7:	e8 67 01 00 00       	call   f0100c53 <cprintf>
f0100aec:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100aef:	83 ec 0c             	sub    $0xc,%esp
f0100af2:	68 52 23 10 f0       	push   $0xf0102352
f0100af7:	e8 b0 0c 00 00       	call   f01017ac <readline>
f0100afc:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100afe:	83 c4 10             	add    $0x10,%esp
f0100b01:	85 c0                	test   %eax,%eax
f0100b03:	74 ea                	je     f0100aef <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b05:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100b0c:	be 00 00 00 00       	mov    $0x0,%esi
f0100b11:	eb 0a                	jmp    f0100b1d <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b13:	c6 03 00             	movb   $0x0,(%ebx)
f0100b16:	89 f7                	mov    %esi,%edi
f0100b18:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b1b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b1d:	0f b6 03             	movzbl (%ebx),%eax
f0100b20:	84 c0                	test   %al,%al
f0100b22:	74 6a                	je     f0100b8e <monitor+0xc1>
f0100b24:	83 ec 08             	sub    $0x8,%esp
f0100b27:	0f be c0             	movsbl %al,%eax
f0100b2a:	50                   	push   %eax
f0100b2b:	68 56 23 10 f0       	push   $0xf0102356
f0100b30:	e8 cd 0e 00 00       	call   f0101a02 <strchr>
f0100b35:	83 c4 10             	add    $0x10,%esp
f0100b38:	85 c0                	test   %eax,%eax
f0100b3a:	75 d7                	jne    f0100b13 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100b3c:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b3f:	74 4d                	je     f0100b8e <monitor+0xc1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b41:	83 fe 0f             	cmp    $0xf,%esi
f0100b44:	75 14                	jne    f0100b5a <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b46:	83 ec 08             	sub    $0x8,%esp
f0100b49:	6a 10                	push   $0x10
f0100b4b:	68 5b 23 10 f0       	push   $0xf010235b
f0100b50:	e8 fe 00 00 00       	call   f0100c53 <cprintf>
f0100b55:	83 c4 10             	add    $0x10,%esp
f0100b58:	eb 95                	jmp    f0100aef <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100b5a:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b5d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b61:	0f b6 03             	movzbl (%ebx),%eax
f0100b64:	84 c0                	test   %al,%al
f0100b66:	75 0c                	jne    f0100b74 <monitor+0xa7>
f0100b68:	eb b1                	jmp    f0100b1b <monitor+0x4e>
			buf++;
f0100b6a:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b6d:	0f b6 03             	movzbl (%ebx),%eax
f0100b70:	84 c0                	test   %al,%al
f0100b72:	74 a7                	je     f0100b1b <monitor+0x4e>
f0100b74:	83 ec 08             	sub    $0x8,%esp
f0100b77:	0f be c0             	movsbl %al,%eax
f0100b7a:	50                   	push   %eax
f0100b7b:	68 56 23 10 f0       	push   $0xf0102356
f0100b80:	e8 7d 0e 00 00       	call   f0101a02 <strchr>
f0100b85:	83 c4 10             	add    $0x10,%esp
f0100b88:	85 c0                	test   %eax,%eax
f0100b8a:	74 de                	je     f0100b6a <monitor+0x9d>
f0100b8c:	eb 8d                	jmp    f0100b1b <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100b8e:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100b95:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100b96:	85 f6                	test   %esi,%esi
f0100b98:	0f 84 51 ff ff ff    	je     f0100aef <monitor+0x22>
f0100b9e:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ba3:	83 ec 08             	sub    $0x8,%esp
f0100ba6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ba9:	ff 34 85 a0 25 10 f0 	pushl  -0xfefda60(,%eax,4)
f0100bb0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bb3:	e8 c6 0d 00 00       	call   f010197e <strcmp>
f0100bb8:	83 c4 10             	add    $0x10,%esp
f0100bbb:	85 c0                	test   %eax,%eax
f0100bbd:	75 21                	jne    f0100be0 <monitor+0x113>
			return commands[i].func(argc, argv, tf);
f0100bbf:	83 ec 04             	sub    $0x4,%esp
f0100bc2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bc5:	ff 75 08             	pushl  0x8(%ebp)
f0100bc8:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100bcb:	52                   	push   %edx
f0100bcc:	56                   	push   %esi
f0100bcd:	ff 14 85 a8 25 10 f0 	call   *-0xfefda58(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100bd4:	83 c4 10             	add    $0x10,%esp
f0100bd7:	85 c0                	test   %eax,%eax
f0100bd9:	78 25                	js     f0100c00 <monitor+0x133>
f0100bdb:	e9 0f ff ff ff       	jmp    f0100aef <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100be0:	83 c3 01             	add    $0x1,%ebx
f0100be3:	83 fb 04             	cmp    $0x4,%ebx
f0100be6:	75 bb                	jne    f0100ba3 <monitor+0xd6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100be8:	83 ec 08             	sub    $0x8,%esp
f0100beb:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bee:	68 78 23 10 f0       	push   $0xf0102378
f0100bf3:	e8 5b 00 00 00       	call   f0100c53 <cprintf>
f0100bf8:	83 c4 10             	add    $0x10,%esp
f0100bfb:	e9 ef fe ff ff       	jmp    f0100aef <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c03:	5b                   	pop    %ebx
f0100c04:	5e                   	pop    %esi
f0100c05:	5f                   	pop    %edi
f0100c06:	5d                   	pop    %ebp
f0100c07:	c3                   	ret    

f0100c08 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100c08:	55                   	push   %ebp
f0100c09:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100c0b:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100c0e:	5d                   	pop    %ebp
f0100c0f:	c3                   	ret    

f0100c10 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100c10:	55                   	push   %ebp
f0100c11:	89 e5                	mov    %esp,%ebp
f0100c13:	53                   	push   %ebx
f0100c14:	83 ec 10             	sub    $0x10,%esp
f0100c17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0100c1a:	ff 75 08             	pushl  0x8(%ebp)
f0100c1d:	e8 f8 fa ff ff       	call   f010071a <cputchar>
    (*cnt)++;
f0100c22:	83 03 01             	addl   $0x1,(%ebx)
}
f0100c25:	83 c4 10             	add    $0x10,%esp
f0100c28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c2b:	c9                   	leave  
f0100c2c:	c3                   	ret    

f0100c2d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100c2d:	55                   	push   %ebp
f0100c2e:	89 e5                	mov    %esp,%ebp
f0100c30:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100c33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100c3a:	ff 75 0c             	pushl  0xc(%ebp)
f0100c3d:	ff 75 08             	pushl  0x8(%ebp)
f0100c40:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100c43:	50                   	push   %eax
f0100c44:	68 10 0c 10 f0       	push   $0xf0100c10
f0100c49:	e8 26 06 00 00       	call   f0101274 <vprintfmt>
	return cnt;
}
f0100c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c51:	c9                   	leave  
f0100c52:	c3                   	ret    

f0100c53 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100c53:	55                   	push   %ebp
f0100c54:	89 e5                	mov    %esp,%ebp
f0100c56:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100c59:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100c5c:	50                   	push   %eax
f0100c5d:	ff 75 08             	pushl  0x8(%ebp)
f0100c60:	e8 c8 ff ff ff       	call   f0100c2d <vcprintf>
	va_end(ap);

	return cnt;
}
f0100c65:	c9                   	leave  
f0100c66:	c3                   	ret    

f0100c67 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100c67:	55                   	push   %ebp
f0100c68:	89 e5                	mov    %esp,%ebp
f0100c6a:	57                   	push   %edi
f0100c6b:	56                   	push   %esi
f0100c6c:	53                   	push   %ebx
f0100c6d:	83 ec 14             	sub    $0x14,%esp
f0100c70:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100c73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c76:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c79:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100c7c:	8b 1a                	mov    (%edx),%ebx
f0100c7e:	8b 01                	mov    (%ecx),%eax
f0100c80:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f0100c83:	39 c3                	cmp    %eax,%ebx
f0100c85:	0f 8f 9a 00 00 00    	jg     f0100d25 <stab_binsearch+0xbe>
f0100c8b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c95:	01 d8                	add    %ebx,%eax
f0100c97:	89 c6                	mov    %eax,%esi
f0100c99:	c1 ee 1f             	shr    $0x1f,%esi
f0100c9c:	01 c6                	add    %eax,%esi
f0100c9e:	d1 fe                	sar    %esi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ca0:	39 de                	cmp    %ebx,%esi
f0100ca2:	0f 8c c4 00 00 00    	jl     f0100d6c <stab_binsearch+0x105>
f0100ca8:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100cab:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100cae:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100cb1:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0100cb5:	39 c7                	cmp    %eax,%edi
f0100cb7:	0f 84 b4 00 00 00    	je     f0100d71 <stab_binsearch+0x10a>
f0100cbd:	89 f0                	mov    %esi,%eax
			m--;
f0100cbf:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100cc2:	39 d8                	cmp    %ebx,%eax
f0100cc4:	0f 8c a2 00 00 00    	jl     f0100d6c <stab_binsearch+0x105>
f0100cca:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0100cce:	83 ea 0c             	sub    $0xc,%edx
f0100cd1:	39 f9                	cmp    %edi,%ecx
f0100cd3:	75 ea                	jne    f0100cbf <stab_binsearch+0x58>
f0100cd5:	e9 99 00 00 00       	jmp    f0100d73 <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100cda:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100cdd:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100cdf:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ce2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100ce9:	eb 2b                	jmp    f0100d16 <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100ceb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100cee:	76 14                	jbe    f0100d04 <stab_binsearch+0x9d>
			*region_right = m - 1;
f0100cf0:	83 e8 01             	sub    $0x1,%eax
f0100cf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100cf6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100cf9:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100cfb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100d02:	eb 12                	jmp    f0100d16 <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100d04:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100d07:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100d09:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100d0d:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100d0f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100d16:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0100d19:	0f 8d 73 ff ff ff    	jge    f0100c92 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100d1f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100d23:	75 0f                	jne    f0100d34 <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f0100d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d28:	8b 00                	mov    (%eax),%eax
f0100d2a:	83 e8 01             	sub    $0x1,%eax
f0100d2d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100d30:	89 07                	mov    %eax,(%edi)
f0100d32:	eb 57                	jmp    f0100d8b <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d34:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d37:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100d39:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100d3c:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d3e:	39 c8                	cmp    %ecx,%eax
f0100d40:	7e 23                	jle    f0100d65 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0100d42:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d45:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100d48:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0100d4b:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100d4f:	39 df                	cmp    %ebx,%edi
f0100d51:	74 12                	je     f0100d65 <stab_binsearch+0xfe>
		     l--)
f0100d53:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100d56:	39 c8                	cmp    %ecx,%eax
f0100d58:	7e 0b                	jle    f0100d65 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0100d5a:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f0100d5e:	83 ea 0c             	sub    $0xc,%edx
f0100d61:	39 df                	cmp    %ebx,%edi
f0100d63:	75 ee                	jne    f0100d53 <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100d65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d68:	89 07                	mov    %eax,(%edi)
	}
}
f0100d6a:	eb 1f                	jmp    f0100d8b <stab_binsearch+0x124>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100d6c:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100d6f:	eb a5                	jmp    f0100d16 <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0100d71:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100d73:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d76:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100d79:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100d7d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100d80:	0f 82 54 ff ff ff    	jb     f0100cda <stab_binsearch+0x73>
f0100d86:	e9 60 ff ff ff       	jmp    f0100ceb <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100d8b:	83 c4 14             	add    $0x14,%esp
f0100d8e:	5b                   	pop    %ebx
f0100d8f:	5e                   	pop    %esi
f0100d90:	5f                   	pop    %edi
f0100d91:	5d                   	pop    %ebp
f0100d92:	c3                   	ret    

f0100d93 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100d93:	55                   	push   %ebp
f0100d94:	89 e5                	mov    %esp,%ebp
f0100d96:	57                   	push   %edi
f0100d97:	56                   	push   %esi
f0100d98:	53                   	push   %ebx
f0100d99:	83 ec 3c             	sub    $0x3c,%esp
f0100d9c:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100da2:	c7 03 d0 25 10 f0    	movl   $0xf01025d0,(%ebx)
	info->eip_line = 0;
f0100da8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100daf:	c7 43 08 d0 25 10 f0 	movl   $0xf01025d0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100db6:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100dbd:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100dc0:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100dc7:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100dcd:	76 11                	jbe    f0100de0 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100dcf:	b8 77 82 10 f0       	mov    $0xf0108277,%eax
f0100dd4:	3d cd 67 10 f0       	cmp    $0xf01067cd,%eax
f0100dd9:	77 19                	ja     f0100df4 <debuginfo_eip+0x61>
f0100ddb:	e9 ce 01 00 00       	jmp    f0100fae <debuginfo_eip+0x21b>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100de0:	83 ec 04             	sub    $0x4,%esp
f0100de3:	68 da 25 10 f0       	push   $0xf01025da
f0100de8:	6a 7f                	push   $0x7f
f0100dea:	68 e7 25 10 f0       	push   $0xf01025e7
f0100def:	e8 ab f3 ff ff       	call   f010019f <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100df4:	80 3d 76 82 10 f0 00 	cmpb   $0x0,0xf0108276
f0100dfb:	0f 85 b4 01 00 00    	jne    f0100fb5 <debuginfo_eip+0x222>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100e01:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100e08:	b8 cc 67 10 f0       	mov    $0xf01067cc,%eax
f0100e0d:	2d 84 28 10 f0       	sub    $0xf0102884,%eax
f0100e12:	c1 f8 02             	sar    $0x2,%eax
f0100e15:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100e1b:	83 e8 01             	sub    $0x1,%eax
f0100e1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100e21:	83 ec 08             	sub    $0x8,%esp
f0100e24:	56                   	push   %esi
f0100e25:	6a 64                	push   $0x64
f0100e27:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100e2a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100e2d:	b8 84 28 10 f0       	mov    $0xf0102884,%eax
f0100e32:	e8 30 fe ff ff       	call   f0100c67 <stab_binsearch>
	if (lfile == 0)
f0100e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e3a:	83 c4 10             	add    $0x10,%esp
f0100e3d:	85 c0                	test   %eax,%eax
f0100e3f:	0f 84 77 01 00 00    	je     f0100fbc <debuginfo_eip+0x229>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100e45:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100e48:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100e4e:	83 ec 08             	sub    $0x8,%esp
f0100e51:	56                   	push   %esi
f0100e52:	6a 24                	push   $0x24
f0100e54:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100e57:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e5a:	b8 84 28 10 f0       	mov    $0xf0102884,%eax
f0100e5f:	e8 03 fe ff ff       	call   f0100c67 <stab_binsearch>

	if (lfun <= rfun) {
f0100e64:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e67:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100e6a:	83 c4 10             	add    $0x10,%esp
f0100e6d:	39 d0                	cmp    %edx,%eax
f0100e6f:	7f 40                	jg     f0100eb1 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100e71:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100e74:	c1 e1 02             	shl    $0x2,%ecx
f0100e77:	8d b9 84 28 10 f0    	lea    -0xfefd77c(%ecx),%edi
f0100e7d:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100e80:	8b b9 84 28 10 f0    	mov    -0xfefd77c(%ecx),%edi
f0100e86:	b9 77 82 10 f0       	mov    $0xf0108277,%ecx
f0100e8b:	81 e9 cd 67 10 f0    	sub    $0xf01067cd,%ecx
f0100e91:	39 cf                	cmp    %ecx,%edi
f0100e93:	73 09                	jae    f0100e9e <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100e95:	81 c7 cd 67 10 f0    	add    $0xf01067cd,%edi
f0100e9b:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100e9e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ea1:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100ea4:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100ea7:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100ea9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100eac:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100eaf:	eb 0f                	jmp    f0100ec0 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100eb1:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100eb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100eb7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100eba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ebd:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ec0:	83 ec 08             	sub    $0x8,%esp
f0100ec3:	6a 3a                	push   $0x3a
f0100ec5:	ff 73 08             	pushl  0x8(%ebx)
f0100ec8:	e8 6b 0b 00 00       	call   f0101a38 <strfind>
f0100ecd:	2b 43 08             	sub    0x8(%ebx),%eax
f0100ed0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100ed3:	83 c4 08             	add    $0x8,%esp
f0100ed6:	56                   	push   %esi
f0100ed7:	6a 44                	push   $0x44
f0100ed9:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100edc:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100edf:	b8 84 28 10 f0       	mov    $0xf0102884,%eax
f0100ee4:	e8 7e fd ff ff       	call   f0100c67 <stab_binsearch>
	if (lline <= rline) {
f0100ee9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100eec:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100eef:	83 c4 10             	add    $0x10,%esp
f0100ef2:	39 d0                	cmp    %edx,%eax
f0100ef4:	0f 8f c9 00 00 00    	jg     f0100fc3 <debuginfo_eip+0x230>
		info->eip_line = rline;
f0100efa:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100efd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f00:	39 f8                	cmp    %edi,%eax
f0100f02:	7c 5e                	jl     f0100f62 <debuginfo_eip+0x1cf>
	       && stabs[lline].n_type != N_SOL
f0100f04:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100f07:	8d 34 95 84 28 10 f0 	lea    -0xfefd77c(,%edx,4),%esi
f0100f0e:	0f b6 56 04          	movzbl 0x4(%esi),%edx
f0100f12:	80 fa 84             	cmp    $0x84,%dl
f0100f15:	74 2b                	je     f0100f42 <debuginfo_eip+0x1af>
f0100f17:	89 f1                	mov    %esi,%ecx
f0100f19:	83 c6 08             	add    $0x8,%esi
f0100f1c:	eb 16                	jmp    f0100f34 <debuginfo_eip+0x1a1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100f1e:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100f21:	39 f8                	cmp    %edi,%eax
f0100f23:	7c 3d                	jl     f0100f62 <debuginfo_eip+0x1cf>
	       && stabs[lline].n_type != N_SOL
f0100f25:	0f b6 51 f8          	movzbl -0x8(%ecx),%edx
f0100f29:	83 e9 0c             	sub    $0xc,%ecx
f0100f2c:	83 ee 0c             	sub    $0xc,%esi
f0100f2f:	80 fa 84             	cmp    $0x84,%dl
f0100f32:	74 0e                	je     f0100f42 <debuginfo_eip+0x1af>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100f34:	80 fa 64             	cmp    $0x64,%dl
f0100f37:	75 e5                	jne    f0100f1e <debuginfo_eip+0x18b>
f0100f39:	83 3e 00             	cmpl   $0x0,(%esi)
f0100f3c:	74 e0                	je     f0100f1e <debuginfo_eip+0x18b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100f3e:	39 c7                	cmp    %eax,%edi
f0100f40:	7f 20                	jg     f0100f62 <debuginfo_eip+0x1cf>
f0100f42:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100f45:	8b 14 85 84 28 10 f0 	mov    -0xfefd77c(,%eax,4),%edx
f0100f4c:	b8 77 82 10 f0       	mov    $0xf0108277,%eax
f0100f51:	2d cd 67 10 f0       	sub    $0xf01067cd,%eax
f0100f56:	39 c2                	cmp    %eax,%edx
f0100f58:	73 08                	jae    f0100f62 <debuginfo_eip+0x1cf>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100f5a:	81 c2 cd 67 10 f0    	add    $0xf01067cd,%edx
f0100f60:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100f62:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100f65:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100f68:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100f6d:	39 f1                	cmp    %esi,%ecx
f0100f6f:	7d 6c                	jge    f0100fdd <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
f0100f71:	8d 41 01             	lea    0x1(%ecx),%eax
f0100f74:	39 c6                	cmp    %eax,%esi
f0100f76:	7e 52                	jle    f0100fca <debuginfo_eip+0x237>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100f78:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100f7b:	c1 e2 02             	shl    $0x2,%edx
f0100f7e:	80 ba 88 28 10 f0 a0 	cmpb   $0xa0,-0xfefd778(%edx)
f0100f85:	75 4a                	jne    f0100fd1 <debuginfo_eip+0x23e>
f0100f87:	8d 41 02             	lea    0x2(%ecx),%eax
f0100f8a:	81 c2 78 28 10 f0    	add    $0xf0102878,%edx
		     lline++)
			info->eip_fn_narg++;
f0100f90:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100f94:	39 c6                	cmp    %eax,%esi
f0100f96:	74 40                	je     f0100fd8 <debuginfo_eip+0x245>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100f98:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f0100f9c:	83 c0 01             	add    $0x1,%eax
f0100f9f:	83 c2 0c             	add    $0xc,%edx
f0100fa2:	80 f9 a0             	cmp    $0xa0,%cl
f0100fa5:	74 e9                	je     f0100f90 <debuginfo_eip+0x1fd>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100fa7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fac:	eb 2f                	jmp    f0100fdd <debuginfo_eip+0x24a>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100fae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fb3:	eb 28                	jmp    f0100fdd <debuginfo_eip+0x24a>
f0100fb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fba:	eb 21                	jmp    f0100fdd <debuginfo_eip+0x24a>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100fbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fc1:	eb 1a                	jmp    f0100fdd <debuginfo_eip+0x24a>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = rline;
	} else {
		return -1;
f0100fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fc8:	eb 13                	jmp    f0100fdd <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100fca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fcf:	eb 0c                	jmp    f0100fdd <debuginfo_eip+0x24a>
f0100fd1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd6:	eb 05                	jmp    f0100fdd <debuginfo_eip+0x24a>
f0100fd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fe0:	5b                   	pop    %ebx
f0100fe1:	5e                   	pop    %esi
f0100fe2:	5f                   	pop    %edi
f0100fe3:	5d                   	pop    %ebp
f0100fe4:	c3                   	ret    

f0100fe5 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100fe5:	55                   	push   %ebp
f0100fe6:	89 e5                	mov    %esp,%ebp
f0100fe8:	57                   	push   %edi
f0100fe9:	56                   	push   %esi
f0100fea:	53                   	push   %ebx
f0100feb:	83 ec 1c             	sub    $0x1c,%esp
f0100fee:	89 c7                	mov    %eax,%edi
f0100ff0:	89 d6                	mov    %edx,%esi
f0100ff2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ff5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ff8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ffb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100ffe:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
f0101001:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0101005:	0f 85 bf 00 00 00    	jne    f01010ca <printnum+0xe5>
f010100b:	39 1d 5c 35 11 f0    	cmp    %ebx,0xf011355c
f0101011:	0f 8d de 00 00 00    	jge    f01010f5 <printnum+0x110>
		judge_time_for_space = width;
f0101017:	89 1d 5c 35 11 f0    	mov    %ebx,0xf011355c
f010101d:	e9 d3 00 00 00       	jmp    f01010f5 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0101022:	83 eb 01             	sub    $0x1,%ebx
f0101025:	85 db                	test   %ebx,%ebx
f0101027:	7f 37                	jg     f0101060 <printnum+0x7b>
f0101029:	e9 ea 00 00 00       	jmp    f0101118 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
f010102e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101031:	a3 58 35 11 f0       	mov    %eax,0xf0113558
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101036:	83 ec 08             	sub    $0x8,%esp
f0101039:	56                   	push   %esi
f010103a:	83 ec 04             	sub    $0x4,%esp
f010103d:	ff 75 dc             	pushl  -0x24(%ebp)
f0101040:	ff 75 d8             	pushl  -0x28(%ebp)
f0101043:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101046:	ff 75 e0             	pushl  -0x20(%ebp)
f0101049:	e8 82 0d 00 00       	call   f0101dd0 <__umoddi3>
f010104e:	83 c4 14             	add    $0x14,%esp
f0101051:	0f be 80 f5 25 10 f0 	movsbl -0xfefda0b(%eax),%eax
f0101058:	50                   	push   %eax
f0101059:	ff d7                	call   *%edi
f010105b:	83 c4 10             	add    $0x10,%esp
f010105e:	eb 16                	jmp    f0101076 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
f0101060:	83 ec 08             	sub    $0x8,%esp
f0101063:	56                   	push   %esi
f0101064:	ff 75 18             	pushl  0x18(%ebp)
f0101067:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0101069:	83 c4 10             	add    $0x10,%esp
f010106c:	83 eb 01             	sub    $0x1,%ebx
f010106f:	75 ef                	jne    f0101060 <printnum+0x7b>
f0101071:	e9 a2 00 00 00       	jmp    f0101118 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
f0101076:	3b 1d 5c 35 11 f0    	cmp    0xf011355c,%ebx
f010107c:	0f 85 76 01 00 00    	jne    f01011f8 <printnum+0x213>
		while(num_of_space-- > 0)
f0101082:	a1 58 35 11 f0       	mov    0xf0113558,%eax
f0101087:	8d 50 ff             	lea    -0x1(%eax),%edx
f010108a:	89 15 58 35 11 f0    	mov    %edx,0xf0113558
f0101090:	85 c0                	test   %eax,%eax
f0101092:	7e 1d                	jle    f01010b1 <printnum+0xcc>
			putch(' ', putdat);
f0101094:	83 ec 08             	sub    $0x8,%esp
f0101097:	56                   	push   %esi
f0101098:	6a 20                	push   $0x20
f010109a:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
f010109c:	a1 58 35 11 f0       	mov    0xf0113558,%eax
f01010a1:	8d 50 ff             	lea    -0x1(%eax),%edx
f01010a4:	89 15 58 35 11 f0    	mov    %edx,0xf0113558
f01010aa:	83 c4 10             	add    $0x10,%esp
f01010ad:	85 c0                	test   %eax,%eax
f01010af:	7f e3                	jg     f0101094 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
f01010b1:	c7 05 58 35 11 f0 00 	movl   $0x0,0xf0113558
f01010b8:	00 00 00 
		judge_time_for_space = 0;
f01010bb:	c7 05 5c 35 11 f0 00 	movl   $0x0,0xf011355c
f01010c2:	00 00 00 
	}
}
f01010c5:	e9 2e 01 00 00       	jmp    f01011f8 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01010ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01010cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01010d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01010de:	83 fa 00             	cmp    $0x0,%edx
f01010e1:	0f 87 ba 00 00 00    	ja     f01011a1 <printnum+0x1bc>
f01010e7:	3b 45 10             	cmp    0x10(%ebp),%eax
f01010ea:	0f 83 b1 00 00 00    	jae    f01011a1 <printnum+0x1bc>
f01010f0:	e9 2d ff ff ff       	jmp    f0101022 <printnum+0x3d>
f01010f5:	8b 45 10             	mov    0x10(%ebp),%eax
f01010f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01010fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101100:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101103:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101106:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101109:	83 fa 00             	cmp    $0x0,%edx
f010110c:	77 37                	ja     f0101145 <printnum+0x160>
f010110e:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101111:	73 32                	jae    f0101145 <printnum+0x160>
f0101113:	e9 16 ff ff ff       	jmp    f010102e <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101118:	83 ec 08             	sub    $0x8,%esp
f010111b:	56                   	push   %esi
f010111c:	83 ec 04             	sub    $0x4,%esp
f010111f:	ff 75 dc             	pushl  -0x24(%ebp)
f0101122:	ff 75 d8             	pushl  -0x28(%ebp)
f0101125:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101128:	ff 75 e0             	pushl  -0x20(%ebp)
f010112b:	e8 a0 0c 00 00       	call   f0101dd0 <__umoddi3>
f0101130:	83 c4 14             	add    $0x14,%esp
f0101133:	0f be 80 f5 25 10 f0 	movsbl -0xfefda0b(%eax),%eax
f010113a:	50                   	push   %eax
f010113b:	ff d7                	call   *%edi
f010113d:	83 c4 10             	add    $0x10,%esp
f0101140:	e9 b3 00 00 00       	jmp    f01011f8 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101145:	83 ec 0c             	sub    $0xc,%esp
f0101148:	ff 75 18             	pushl  0x18(%ebp)
f010114b:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010114e:	50                   	push   %eax
f010114f:	ff 75 10             	pushl  0x10(%ebp)
f0101152:	83 ec 08             	sub    $0x8,%esp
f0101155:	ff 75 dc             	pushl  -0x24(%ebp)
f0101158:	ff 75 d8             	pushl  -0x28(%ebp)
f010115b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010115e:	ff 75 e0             	pushl  -0x20(%ebp)
f0101161:	e8 3a 0b 00 00       	call   f0101ca0 <__udivdi3>
f0101166:	83 c4 18             	add    $0x18,%esp
f0101169:	52                   	push   %edx
f010116a:	50                   	push   %eax
f010116b:	89 f2                	mov    %esi,%edx
f010116d:	89 f8                	mov    %edi,%eax
f010116f:	e8 71 fe ff ff       	call   f0100fe5 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101174:	83 c4 18             	add    $0x18,%esp
f0101177:	56                   	push   %esi
f0101178:	83 ec 04             	sub    $0x4,%esp
f010117b:	ff 75 dc             	pushl  -0x24(%ebp)
f010117e:	ff 75 d8             	pushl  -0x28(%ebp)
f0101181:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101184:	ff 75 e0             	pushl  -0x20(%ebp)
f0101187:	e8 44 0c 00 00       	call   f0101dd0 <__umoddi3>
f010118c:	83 c4 14             	add    $0x14,%esp
f010118f:	0f be 80 f5 25 10 f0 	movsbl -0xfefda0b(%eax),%eax
f0101196:	50                   	push   %eax
f0101197:	ff d7                	call   *%edi
f0101199:	83 c4 10             	add    $0x10,%esp
f010119c:	e9 d5 fe ff ff       	jmp    f0101076 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01011a1:	83 ec 0c             	sub    $0xc,%esp
f01011a4:	ff 75 18             	pushl  0x18(%ebp)
f01011a7:	83 eb 01             	sub    $0x1,%ebx
f01011aa:	53                   	push   %ebx
f01011ab:	ff 75 10             	pushl  0x10(%ebp)
f01011ae:	83 ec 08             	sub    $0x8,%esp
f01011b1:	ff 75 dc             	pushl  -0x24(%ebp)
f01011b4:	ff 75 d8             	pushl  -0x28(%ebp)
f01011b7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01011ba:	ff 75 e0             	pushl  -0x20(%ebp)
f01011bd:	e8 de 0a 00 00       	call   f0101ca0 <__udivdi3>
f01011c2:	83 c4 18             	add    $0x18,%esp
f01011c5:	52                   	push   %edx
f01011c6:	50                   	push   %eax
f01011c7:	89 f2                	mov    %esi,%edx
f01011c9:	89 f8                	mov    %edi,%eax
f01011cb:	e8 15 fe ff ff       	call   f0100fe5 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01011d0:	83 c4 18             	add    $0x18,%esp
f01011d3:	56                   	push   %esi
f01011d4:	83 ec 04             	sub    $0x4,%esp
f01011d7:	ff 75 dc             	pushl  -0x24(%ebp)
f01011da:	ff 75 d8             	pushl  -0x28(%ebp)
f01011dd:	ff 75 e4             	pushl  -0x1c(%ebp)
f01011e0:	ff 75 e0             	pushl  -0x20(%ebp)
f01011e3:	e8 e8 0b 00 00       	call   f0101dd0 <__umoddi3>
f01011e8:	83 c4 14             	add    $0x14,%esp
f01011eb:	0f be 80 f5 25 10 f0 	movsbl -0xfefda0b(%eax),%eax
f01011f2:	50                   	push   %eax
f01011f3:	ff d7                	call   *%edi
f01011f5:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
f01011f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011fb:	5b                   	pop    %ebx
f01011fc:	5e                   	pop    %esi
f01011fd:	5f                   	pop    %edi
f01011fe:	5d                   	pop    %ebp
f01011ff:	c3                   	ret    

f0101200 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0101200:	55                   	push   %ebp
f0101201:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101203:	83 fa 01             	cmp    $0x1,%edx
f0101206:	7e 0e                	jle    f0101216 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101208:	8b 10                	mov    (%eax),%edx
f010120a:	8d 4a 08             	lea    0x8(%edx),%ecx
f010120d:	89 08                	mov    %ecx,(%eax)
f010120f:	8b 02                	mov    (%edx),%eax
f0101211:	8b 52 04             	mov    0x4(%edx),%edx
f0101214:	eb 22                	jmp    f0101238 <getuint+0x38>
	else if (lflag)
f0101216:	85 d2                	test   %edx,%edx
f0101218:	74 10                	je     f010122a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010121a:	8b 10                	mov    (%eax),%edx
f010121c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010121f:	89 08                	mov    %ecx,(%eax)
f0101221:	8b 02                	mov    (%edx),%eax
f0101223:	ba 00 00 00 00       	mov    $0x0,%edx
f0101228:	eb 0e                	jmp    f0101238 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010122a:	8b 10                	mov    (%eax),%edx
f010122c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010122f:	89 08                	mov    %ecx,(%eax)
f0101231:	8b 02                	mov    (%edx),%eax
f0101233:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101238:	5d                   	pop    %ebp
f0101239:	c3                   	ret    

f010123a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010123a:	55                   	push   %ebp
f010123b:	89 e5                	mov    %esp,%ebp
f010123d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101240:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101244:	8b 10                	mov    (%eax),%edx
f0101246:	3b 50 04             	cmp    0x4(%eax),%edx
f0101249:	73 0a                	jae    f0101255 <sprintputch+0x1b>
		*b->buf++ = ch;
f010124b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010124e:	89 08                	mov    %ecx,(%eax)
f0101250:	8b 45 08             	mov    0x8(%ebp),%eax
f0101253:	88 02                	mov    %al,(%edx)
}
f0101255:	5d                   	pop    %ebp
f0101256:	c3                   	ret    

f0101257 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101257:	55                   	push   %ebp
f0101258:	89 e5                	mov    %esp,%ebp
f010125a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010125d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101260:	50                   	push   %eax
f0101261:	ff 75 10             	pushl  0x10(%ebp)
f0101264:	ff 75 0c             	pushl  0xc(%ebp)
f0101267:	ff 75 08             	pushl  0x8(%ebp)
f010126a:	e8 05 00 00 00       	call   f0101274 <vprintfmt>
	va_end(ap);
}
f010126f:	83 c4 10             	add    $0x10,%esp
f0101272:	c9                   	leave  
f0101273:	c3                   	ret    

f0101274 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101274:	55                   	push   %ebp
f0101275:	89 e5                	mov    %esp,%ebp
f0101277:	57                   	push   %edi
f0101278:	56                   	push   %esi
f0101279:	53                   	push   %ebx
f010127a:	83 ec 2c             	sub    $0x2c,%esp
f010127d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101280:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101283:	eb 03                	jmp    f0101288 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101285:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101288:	8b 45 10             	mov    0x10(%ebp),%eax
f010128b:	8d 70 01             	lea    0x1(%eax),%esi
f010128e:	0f b6 00             	movzbl (%eax),%eax
f0101291:	83 f8 25             	cmp    $0x25,%eax
f0101294:	74 27                	je     f01012bd <vprintfmt+0x49>
			if (ch == '\0')
f0101296:	85 c0                	test   %eax,%eax
f0101298:	75 0d                	jne    f01012a7 <vprintfmt+0x33>
f010129a:	e9 9d 04 00 00       	jmp    f010173c <vprintfmt+0x4c8>
f010129f:	85 c0                	test   %eax,%eax
f01012a1:	0f 84 95 04 00 00    	je     f010173c <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
f01012a7:	83 ec 08             	sub    $0x8,%esp
f01012aa:	53                   	push   %ebx
f01012ab:	50                   	push   %eax
f01012ac:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01012ae:	83 c6 01             	add    $0x1,%esi
f01012b1:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f01012b5:	83 c4 10             	add    $0x10,%esp
f01012b8:	83 f8 25             	cmp    $0x25,%eax
f01012bb:	75 e2                	jne    f010129f <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01012bd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012c2:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f01012c6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01012cd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01012d4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01012db:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f01012e2:	eb 08                	jmp    f01012ec <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012e4:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
f01012e7:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012ec:	8d 46 01             	lea    0x1(%esi),%eax
f01012ef:	89 45 10             	mov    %eax,0x10(%ebp)
f01012f2:	0f b6 06             	movzbl (%esi),%eax
f01012f5:	0f b6 d0             	movzbl %al,%edx
f01012f8:	83 e8 23             	sub    $0x23,%eax
f01012fb:	3c 55                	cmp    $0x55,%al
f01012fd:	0f 87 fa 03 00 00    	ja     f01016fd <vprintfmt+0x489>
f0101303:	0f b6 c0             	movzbl %al,%eax
f0101306:	ff 24 85 00 27 10 f0 	jmp    *-0xfefd900(,%eax,4)
f010130d:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f0101310:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f0101314:	eb d6                	jmp    f01012ec <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101316:	8d 42 d0             	lea    -0x30(%edx),%eax
f0101319:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f010131c:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0101320:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101323:	83 fa 09             	cmp    $0x9,%edx
f0101326:	77 6b                	ja     f0101393 <vprintfmt+0x11f>
f0101328:	8b 75 10             	mov    0x10(%ebp),%esi
f010132b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010132e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101331:	eb 09                	jmp    f010133c <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101333:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101336:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f010133a:	eb b0                	jmp    f01012ec <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010133c:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f010133f:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101342:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0101346:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0101349:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010134c:	83 f9 09             	cmp    $0x9,%ecx
f010134f:	76 eb                	jbe    f010133c <vprintfmt+0xc8>
f0101351:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101354:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101357:	eb 3d                	jmp    f0101396 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101359:	8b 45 14             	mov    0x14(%ebp),%eax
f010135c:	8d 50 04             	lea    0x4(%eax),%edx
f010135f:	89 55 14             	mov    %edx,0x14(%ebp)
f0101362:	8b 00                	mov    (%eax),%eax
f0101364:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101367:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010136a:	eb 2a                	jmp    f0101396 <vprintfmt+0x122>
f010136c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010136f:	85 c0                	test   %eax,%eax
f0101371:	ba 00 00 00 00       	mov    $0x0,%edx
f0101376:	0f 49 d0             	cmovns %eax,%edx
f0101379:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010137c:	8b 75 10             	mov    0x10(%ebp),%esi
f010137f:	e9 68 ff ff ff       	jmp    f01012ec <vprintfmt+0x78>
f0101384:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101387:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010138e:	e9 59 ff ff ff       	jmp    f01012ec <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101393:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0101396:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010139a:	0f 89 4c ff ff ff    	jns    f01012ec <vprintfmt+0x78>
				width = precision, precision = -1;
f01013a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01013a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01013ad:	e9 3a ff ff ff       	jmp    f01012ec <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01013b2:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013b6:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01013b9:	e9 2e ff ff ff       	jmp    f01012ec <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01013be:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c1:	8d 50 04             	lea    0x4(%eax),%edx
f01013c4:	89 55 14             	mov    %edx,0x14(%ebp)
f01013c7:	83 ec 08             	sub    $0x8,%esp
f01013ca:	53                   	push   %ebx
f01013cb:	ff 30                	pushl  (%eax)
f01013cd:	ff d7                	call   *%edi
			break;
f01013cf:	83 c4 10             	add    $0x10,%esp
f01013d2:	e9 b1 fe ff ff       	jmp    f0101288 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01013d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01013da:	8d 50 04             	lea    0x4(%eax),%edx
f01013dd:	89 55 14             	mov    %edx,0x14(%ebp)
f01013e0:	8b 00                	mov    (%eax),%eax
f01013e2:	99                   	cltd   
f01013e3:	31 d0                	xor    %edx,%eax
f01013e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01013e7:	83 f8 06             	cmp    $0x6,%eax
f01013ea:	7f 0b                	jg     f01013f7 <vprintfmt+0x183>
f01013ec:	8b 14 85 58 28 10 f0 	mov    -0xfefd7a8(,%eax,4),%edx
f01013f3:	85 d2                	test   %edx,%edx
f01013f5:	75 15                	jne    f010140c <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
f01013f7:	50                   	push   %eax
f01013f8:	68 0d 26 10 f0       	push   $0xf010260d
f01013fd:	53                   	push   %ebx
f01013fe:	57                   	push   %edi
f01013ff:	e8 53 fe ff ff       	call   f0101257 <printfmt>
f0101404:	83 c4 10             	add    $0x10,%esp
f0101407:	e9 7c fe ff ff       	jmp    f0101288 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f010140c:	52                   	push   %edx
f010140d:	68 16 26 10 f0       	push   $0xf0102616
f0101412:	53                   	push   %ebx
f0101413:	57                   	push   %edi
f0101414:	e8 3e fe ff ff       	call   f0101257 <printfmt>
f0101419:	83 c4 10             	add    $0x10,%esp
f010141c:	e9 67 fe ff ff       	jmp    f0101288 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101421:	8b 45 14             	mov    0x14(%ebp),%eax
f0101424:	8d 50 04             	lea    0x4(%eax),%edx
f0101427:	89 55 14             	mov    %edx,0x14(%ebp)
f010142a:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f010142c:	85 c0                	test   %eax,%eax
f010142e:	b9 06 26 10 f0       	mov    $0xf0102606,%ecx
f0101433:	0f 45 c8             	cmovne %eax,%ecx
f0101436:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0101439:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010143d:	7e 06                	jle    f0101445 <vprintfmt+0x1d1>
f010143f:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0101443:	75 19                	jne    f010145e <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101445:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101448:	8d 70 01             	lea    0x1(%eax),%esi
f010144b:	0f b6 00             	movzbl (%eax),%eax
f010144e:	0f be d0             	movsbl %al,%edx
f0101451:	85 d2                	test   %edx,%edx
f0101453:	0f 85 9f 00 00 00    	jne    f01014f8 <vprintfmt+0x284>
f0101459:	e9 8c 00 00 00       	jmp    f01014ea <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010145e:	83 ec 08             	sub    $0x8,%esp
f0101461:	ff 75 d0             	pushl  -0x30(%ebp)
f0101464:	ff 75 cc             	pushl  -0x34(%ebp)
f0101467:	e8 3b 04 00 00       	call   f01018a7 <strnlen>
f010146c:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f010146f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101472:	83 c4 10             	add    $0x10,%esp
f0101475:	85 c9                	test   %ecx,%ecx
f0101477:	0f 8e a6 02 00 00    	jle    f0101723 <vprintfmt+0x4af>
					putch(padc, putdat);
f010147d:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0101481:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101484:	89 cb                	mov    %ecx,%ebx
f0101486:	83 ec 08             	sub    $0x8,%esp
f0101489:	ff 75 0c             	pushl  0xc(%ebp)
f010148c:	56                   	push   %esi
f010148d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010148f:	83 c4 10             	add    $0x10,%esp
f0101492:	83 eb 01             	sub    $0x1,%ebx
f0101495:	75 ef                	jne    f0101486 <vprintfmt+0x212>
f0101497:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010149a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010149d:	e9 81 02 00 00       	jmp    f0101723 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01014a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01014a6:	74 1b                	je     f01014c3 <vprintfmt+0x24f>
f01014a8:	0f be c0             	movsbl %al,%eax
f01014ab:	83 e8 20             	sub    $0x20,%eax
f01014ae:	83 f8 5e             	cmp    $0x5e,%eax
f01014b1:	76 10                	jbe    f01014c3 <vprintfmt+0x24f>
					putch('?', putdat);
f01014b3:	83 ec 08             	sub    $0x8,%esp
f01014b6:	ff 75 0c             	pushl  0xc(%ebp)
f01014b9:	6a 3f                	push   $0x3f
f01014bb:	ff 55 08             	call   *0x8(%ebp)
f01014be:	83 c4 10             	add    $0x10,%esp
f01014c1:	eb 0d                	jmp    f01014d0 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
f01014c3:	83 ec 08             	sub    $0x8,%esp
f01014c6:	ff 75 0c             	pushl  0xc(%ebp)
f01014c9:	52                   	push   %edx
f01014ca:	ff 55 08             	call   *0x8(%ebp)
f01014cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01014d0:	83 ef 01             	sub    $0x1,%edi
f01014d3:	83 c6 01             	add    $0x1,%esi
f01014d6:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f01014da:	0f be d0             	movsbl %al,%edx
f01014dd:	85 d2                	test   %edx,%edx
f01014df:	75 31                	jne    f0101512 <vprintfmt+0x29e>
f01014e1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01014e4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01014ea:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01014ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014f1:	7f 33                	jg     f0101526 <vprintfmt+0x2b2>
f01014f3:	e9 90 fd ff ff       	jmp    f0101288 <vprintfmt+0x14>
f01014f8:	89 7d 08             	mov    %edi,0x8(%ebp)
f01014fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01014fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101501:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101504:	eb 0c                	jmp    f0101512 <vprintfmt+0x29e>
f0101506:	89 7d 08             	mov    %edi,0x8(%ebp)
f0101509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010150c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010150f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101512:	85 db                	test   %ebx,%ebx
f0101514:	78 8c                	js     f01014a2 <vprintfmt+0x22e>
f0101516:	83 eb 01             	sub    $0x1,%ebx
f0101519:	79 87                	jns    f01014a2 <vprintfmt+0x22e>
f010151b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010151e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101524:	eb c4                	jmp    f01014ea <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101526:	83 ec 08             	sub    $0x8,%esp
f0101529:	53                   	push   %ebx
f010152a:	6a 20                	push   $0x20
f010152c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010152e:	83 c4 10             	add    $0x10,%esp
f0101531:	83 ee 01             	sub    $0x1,%esi
f0101534:	75 f0                	jne    f0101526 <vprintfmt+0x2b2>
f0101536:	e9 4d fd ff ff       	jmp    f0101288 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010153b:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f010153f:	7e 16                	jle    f0101557 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
f0101541:	8b 45 14             	mov    0x14(%ebp),%eax
f0101544:	8d 50 08             	lea    0x8(%eax),%edx
f0101547:	89 55 14             	mov    %edx,0x14(%ebp)
f010154a:	8b 50 04             	mov    0x4(%eax),%edx
f010154d:	8b 00                	mov    (%eax),%eax
f010154f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101552:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101555:	eb 34                	jmp    f010158b <vprintfmt+0x317>
	else if (lflag)
f0101557:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f010155b:	74 18                	je     f0101575 <vprintfmt+0x301>
		return va_arg(*ap, long);
f010155d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101560:	8d 50 04             	lea    0x4(%eax),%edx
f0101563:	89 55 14             	mov    %edx,0x14(%ebp)
f0101566:	8b 30                	mov    (%eax),%esi
f0101568:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010156b:	89 f0                	mov    %esi,%eax
f010156d:	c1 f8 1f             	sar    $0x1f,%eax
f0101570:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101573:	eb 16                	jmp    f010158b <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
f0101575:	8b 45 14             	mov    0x14(%ebp),%eax
f0101578:	8d 50 04             	lea    0x4(%eax),%edx
f010157b:	89 55 14             	mov    %edx,0x14(%ebp)
f010157e:	8b 30                	mov    (%eax),%esi
f0101580:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101583:	89 f0                	mov    %esi,%eax
f0101585:	c1 f8 1f             	sar    $0x1f,%eax
f0101588:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010158b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010158e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101591:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101594:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0101597:	85 d2                	test   %edx,%edx
f0101599:	79 28                	jns    f01015c3 <vprintfmt+0x34f>
				putch('-', putdat);
f010159b:	83 ec 08             	sub    $0x8,%esp
f010159e:	53                   	push   %ebx
f010159f:	6a 2d                	push   $0x2d
f01015a1:	ff d7                	call   *%edi
				num = -(long long) num;
f01015a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01015a9:	f7 d8                	neg    %eax
f01015ab:	83 d2 00             	adc    $0x0,%edx
f01015ae:	f7 da                	neg    %edx
f01015b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01015b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01015b6:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
f01015b9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01015be:	e9 b2 00 00 00       	jmp    f0101675 <vprintfmt+0x401>
f01015c3:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
f01015c8:	85 c9                	test   %ecx,%ecx
f01015ca:	0f 84 a5 00 00 00    	je     f0101675 <vprintfmt+0x401>
				putch('+', putdat);
f01015d0:	83 ec 08             	sub    $0x8,%esp
f01015d3:	53                   	push   %ebx
f01015d4:	6a 2b                	push   $0x2b
f01015d6:	ff d7                	call   *%edi
f01015d8:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
f01015db:	b8 0a 00 00 00       	mov    $0xa,%eax
f01015e0:	e9 90 00 00 00       	jmp    f0101675 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
f01015e5:	85 c9                	test   %ecx,%ecx
f01015e7:	74 0b                	je     f01015f4 <vprintfmt+0x380>
				putch('+', putdat);
f01015e9:	83 ec 08             	sub    $0x8,%esp
f01015ec:	53                   	push   %ebx
f01015ed:	6a 2b                	push   $0x2b
f01015ef:	ff d7                	call   *%edi
f01015f1:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
f01015f4:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01015f7:	8d 45 14             	lea    0x14(%ebp),%eax
f01015fa:	e8 01 fc ff ff       	call   f0101200 <getuint>
f01015ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101602:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0101605:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010160a:	eb 69                	jmp    f0101675 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
f010160c:	83 ec 08             	sub    $0x8,%esp
f010160f:	53                   	push   %ebx
f0101610:	6a 30                	push   $0x30
f0101612:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f0101614:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101617:	8d 45 14             	lea    0x14(%ebp),%eax
f010161a:	e8 e1 fb ff ff       	call   f0101200 <getuint>
f010161f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101622:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f0101625:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0101628:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f010162d:	eb 46                	jmp    f0101675 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
f010162f:	83 ec 08             	sub    $0x8,%esp
f0101632:	53                   	push   %ebx
f0101633:	6a 30                	push   $0x30
f0101635:	ff d7                	call   *%edi
			putch('x', putdat);
f0101637:	83 c4 08             	add    $0x8,%esp
f010163a:	53                   	push   %ebx
f010163b:	6a 78                	push   $0x78
f010163d:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010163f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101642:	8d 50 04             	lea    0x4(%eax),%edx
f0101645:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101648:	8b 00                	mov    (%eax),%eax
f010164a:	ba 00 00 00 00       	mov    $0x0,%edx
f010164f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101652:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101655:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101658:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010165d:	eb 16                	jmp    f0101675 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010165f:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101662:	8d 45 14             	lea    0x14(%ebp),%eax
f0101665:	e8 96 fb ff ff       	call   f0101200 <getuint>
f010166a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010166d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0101670:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101675:	83 ec 0c             	sub    $0xc,%esp
f0101678:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f010167c:	56                   	push   %esi
f010167d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101680:	50                   	push   %eax
f0101681:	ff 75 dc             	pushl  -0x24(%ebp)
f0101684:	ff 75 d8             	pushl  -0x28(%ebp)
f0101687:	89 da                	mov    %ebx,%edx
f0101689:	89 f8                	mov    %edi,%eax
f010168b:	e8 55 f9 ff ff       	call   f0100fe5 <printnum>
			break;
f0101690:	83 c4 20             	add    $0x20,%esp
f0101693:	e9 f0 fb ff ff       	jmp    f0101288 <vprintfmt+0x14>
            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
						// cprintf("n: %d\n", *(char *)putdat);
						char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
f0101698:	8b 45 14             	mov    0x14(%ebp),%eax
f010169b:	8d 50 04             	lea    0x4(%eax),%edx
f010169e:	89 55 14             	mov    %edx,0x14(%ebp)
f01016a1:	8b 30                	mov    (%eax),%esi
						if (!tmp) {
f01016a3:	85 f6                	test   %esi,%esi
f01016a5:	75 1a                	jne    f01016c1 <vprintfmt+0x44d>
							cprintf("%s", null_error);
f01016a7:	83 ec 08             	sub    $0x8,%esp
f01016aa:	68 84 26 10 f0       	push   $0xf0102684
f01016af:	68 16 26 10 f0       	push   $0xf0102616
f01016b4:	e8 9a f5 ff ff       	call   f0100c53 <cprintf>
f01016b9:	83 c4 10             	add    $0x10,%esp
f01016bc:	e9 c7 fb ff ff       	jmp    f0101288 <vprintfmt+0x14>
						} else if ((*(char *)putdat) & 0x80) {
f01016c1:	0f b6 03             	movzbl (%ebx),%eax
f01016c4:	84 c0                	test   %al,%al
f01016c6:	79 1f                	jns    f01016e7 <vprintfmt+0x473>
							cprintf("%s", overflow_error);
f01016c8:	83 ec 08             	sub    $0x8,%esp
f01016cb:	68 bc 26 10 f0       	push   $0xf01026bc
f01016d0:	68 16 26 10 f0       	push   $0xf0102616
f01016d5:	e8 79 f5 ff ff       	call   f0100c53 <cprintf>
							*tmp = *(char *)putdat;
f01016da:	0f b6 03             	movzbl (%ebx),%eax
f01016dd:	88 06                	mov    %al,(%esi)
f01016df:	83 c4 10             	add    $0x10,%esp
f01016e2:	e9 a1 fb ff ff       	jmp    f0101288 <vprintfmt+0x14>
						} else {
							*tmp = *(char *)putdat;
f01016e7:	88 06                	mov    %al,(%esi)
f01016e9:	e9 9a fb ff ff       	jmp    f0101288 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01016ee:	83 ec 08             	sub    $0x8,%esp
f01016f1:	53                   	push   %ebx
f01016f2:	52                   	push   %edx
f01016f3:	ff d7                	call   *%edi
			break;
f01016f5:	83 c4 10             	add    $0x10,%esp
f01016f8:	e9 8b fb ff ff       	jmp    f0101288 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01016fd:	83 ec 08             	sub    $0x8,%esp
f0101700:	53                   	push   %ebx
f0101701:	6a 25                	push   $0x25
f0101703:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101705:	83 c4 10             	add    $0x10,%esp
f0101708:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010170c:	0f 84 73 fb ff ff    	je     f0101285 <vprintfmt+0x11>
f0101712:	83 ee 01             	sub    $0x1,%esi
f0101715:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101719:	75 f7                	jne    f0101712 <vprintfmt+0x49e>
f010171b:	89 75 10             	mov    %esi,0x10(%ebp)
f010171e:	e9 65 fb ff ff       	jmp    f0101288 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101723:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101726:	8d 70 01             	lea    0x1(%eax),%esi
f0101729:	0f b6 00             	movzbl (%eax),%eax
f010172c:	0f be d0             	movsbl %al,%edx
f010172f:	85 d2                	test   %edx,%edx
f0101731:	0f 85 cf fd ff ff    	jne    f0101506 <vprintfmt+0x292>
f0101737:	e9 4c fb ff ff       	jmp    f0101288 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f010173c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010173f:	5b                   	pop    %ebx
f0101740:	5e                   	pop    %esi
f0101741:	5f                   	pop    %edi
f0101742:	5d                   	pop    %ebp
f0101743:	c3                   	ret    

f0101744 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101744:	55                   	push   %ebp
f0101745:	89 e5                	mov    %esp,%ebp
f0101747:	83 ec 18             	sub    $0x18,%esp
f010174a:	8b 45 08             	mov    0x8(%ebp),%eax
f010174d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101750:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101753:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101757:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010175a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101761:	85 c0                	test   %eax,%eax
f0101763:	74 26                	je     f010178b <vsnprintf+0x47>
f0101765:	85 d2                	test   %edx,%edx
f0101767:	7e 22                	jle    f010178b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101769:	ff 75 14             	pushl  0x14(%ebp)
f010176c:	ff 75 10             	pushl  0x10(%ebp)
f010176f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101772:	50                   	push   %eax
f0101773:	68 3a 12 10 f0       	push   $0xf010123a
f0101778:	e8 f7 fa ff ff       	call   f0101274 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010177d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101780:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101783:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101786:	83 c4 10             	add    $0x10,%esp
f0101789:	eb 05                	jmp    f0101790 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010178b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101790:	c9                   	leave  
f0101791:	c3                   	ret    

f0101792 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101792:	55                   	push   %ebp
f0101793:	89 e5                	mov    %esp,%ebp
f0101795:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101798:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010179b:	50                   	push   %eax
f010179c:	ff 75 10             	pushl  0x10(%ebp)
f010179f:	ff 75 0c             	pushl  0xc(%ebp)
f01017a2:	ff 75 08             	pushl  0x8(%ebp)
f01017a5:	e8 9a ff ff ff       	call   f0101744 <vsnprintf>
	va_end(ap);

	return rc;
}
f01017aa:	c9                   	leave  
f01017ab:	c3                   	ret    

f01017ac <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01017ac:	55                   	push   %ebp
f01017ad:	89 e5                	mov    %esp,%ebp
f01017af:	57                   	push   %edi
f01017b0:	56                   	push   %esi
f01017b1:	53                   	push   %ebx
f01017b2:	83 ec 0c             	sub    $0xc,%esp
f01017b5:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01017b8:	85 c0                	test   %eax,%eax
f01017ba:	74 11                	je     f01017cd <readline+0x21>
		cprintf("%s", prompt);
f01017bc:	83 ec 08             	sub    $0x8,%esp
f01017bf:	50                   	push   %eax
f01017c0:	68 16 26 10 f0       	push   $0xf0102616
f01017c5:	e8 89 f4 ff ff       	call   f0100c53 <cprintf>
f01017ca:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01017cd:	83 ec 0c             	sub    $0xc,%esp
f01017d0:	6a 00                	push   $0x0
f01017d2:	e8 64 ef ff ff       	call   f010073b <iscons>
f01017d7:	89 c7                	mov    %eax,%edi
f01017d9:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01017dc:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01017e1:	e8 44 ef ff ff       	call   f010072a <getchar>
f01017e6:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01017e8:	85 c0                	test   %eax,%eax
f01017ea:	79 18                	jns    f0101804 <readline+0x58>
			cprintf("read error: %e\n", c);
f01017ec:	83 ec 08             	sub    $0x8,%esp
f01017ef:	50                   	push   %eax
f01017f0:	68 74 28 10 f0       	push   $0xf0102874
f01017f5:	e8 59 f4 ff ff       	call   f0100c53 <cprintf>
			return NULL;
f01017fa:	83 c4 10             	add    $0x10,%esp
f01017fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0101802:	eb 79                	jmp    f010187d <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101804:	83 f8 08             	cmp    $0x8,%eax
f0101807:	0f 94 c2             	sete   %dl
f010180a:	83 f8 7f             	cmp    $0x7f,%eax
f010180d:	0f 94 c0             	sete   %al
f0101810:	08 c2                	or     %al,%dl
f0101812:	74 1a                	je     f010182e <readline+0x82>
f0101814:	85 f6                	test   %esi,%esi
f0101816:	7e 16                	jle    f010182e <readline+0x82>
			if (echoing)
f0101818:	85 ff                	test   %edi,%edi
f010181a:	74 0d                	je     f0101829 <readline+0x7d>
				cputchar('\b');
f010181c:	83 ec 0c             	sub    $0xc,%esp
f010181f:	6a 08                	push   $0x8
f0101821:	e8 f4 ee ff ff       	call   f010071a <cputchar>
f0101826:	83 c4 10             	add    $0x10,%esp
			i--;
f0101829:	83 ee 01             	sub    $0x1,%esi
f010182c:	eb b3                	jmp    f01017e1 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010182e:	83 fb 1f             	cmp    $0x1f,%ebx
f0101831:	7e 23                	jle    f0101856 <readline+0xaa>
f0101833:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101839:	7f 1b                	jg     f0101856 <readline+0xaa>
			if (echoing)
f010183b:	85 ff                	test   %edi,%edi
f010183d:	74 0c                	je     f010184b <readline+0x9f>
				cputchar(c);
f010183f:	83 ec 0c             	sub    $0xc,%esp
f0101842:	53                   	push   %ebx
f0101843:	e8 d2 ee ff ff       	call   f010071a <cputchar>
f0101848:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010184b:	88 9e 60 35 11 f0    	mov    %bl,-0xfeecaa0(%esi)
f0101851:	8d 76 01             	lea    0x1(%esi),%esi
f0101854:	eb 8b                	jmp    f01017e1 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101856:	83 fb 0a             	cmp    $0xa,%ebx
f0101859:	74 05                	je     f0101860 <readline+0xb4>
f010185b:	83 fb 0d             	cmp    $0xd,%ebx
f010185e:	75 81                	jne    f01017e1 <readline+0x35>
			if (echoing)
f0101860:	85 ff                	test   %edi,%edi
f0101862:	74 0d                	je     f0101871 <readline+0xc5>
				cputchar('\n');
f0101864:	83 ec 0c             	sub    $0xc,%esp
f0101867:	6a 0a                	push   $0xa
f0101869:	e8 ac ee ff ff       	call   f010071a <cputchar>
f010186e:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0101871:	c6 86 60 35 11 f0 00 	movb   $0x0,-0xfeecaa0(%esi)
			return buf;
f0101878:	b8 60 35 11 f0       	mov    $0xf0113560,%eax
		}
	}
}
f010187d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101880:	5b                   	pop    %ebx
f0101881:	5e                   	pop    %esi
f0101882:	5f                   	pop    %edi
f0101883:	5d                   	pop    %ebp
f0101884:	c3                   	ret    

f0101885 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101885:	55                   	push   %ebp
f0101886:	89 e5                	mov    %esp,%ebp
f0101888:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010188b:	80 3a 00             	cmpb   $0x0,(%edx)
f010188e:	74 10                	je     f01018a0 <strlen+0x1b>
f0101890:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101895:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101898:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010189c:	75 f7                	jne    f0101895 <strlen+0x10>
f010189e:	eb 05                	jmp    f01018a5 <strlen+0x20>
f01018a0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01018a5:	5d                   	pop    %ebp
f01018a6:	c3                   	ret    

f01018a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01018a7:	55                   	push   %ebp
f01018a8:	89 e5                	mov    %esp,%ebp
f01018aa:	53                   	push   %ebx
f01018ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01018ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01018b1:	85 c9                	test   %ecx,%ecx
f01018b3:	74 1c                	je     f01018d1 <strnlen+0x2a>
f01018b5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01018b8:	74 1e                	je     f01018d8 <strnlen+0x31>
f01018ba:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01018bf:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01018c1:	39 ca                	cmp    %ecx,%edx
f01018c3:	74 18                	je     f01018dd <strnlen+0x36>
f01018c5:	83 c2 01             	add    $0x1,%edx
f01018c8:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01018cd:	75 f0                	jne    f01018bf <strnlen+0x18>
f01018cf:	eb 0c                	jmp    f01018dd <strnlen+0x36>
f01018d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01018d6:	eb 05                	jmp    f01018dd <strnlen+0x36>
f01018d8:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01018dd:	5b                   	pop    %ebx
f01018de:	5d                   	pop    %ebp
f01018df:	c3                   	ret    

f01018e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01018e0:	55                   	push   %ebp
f01018e1:	89 e5                	mov    %esp,%ebp
f01018e3:	53                   	push   %ebx
f01018e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01018e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01018ea:	89 c2                	mov    %eax,%edx
f01018ec:	83 c2 01             	add    $0x1,%edx
f01018ef:	83 c1 01             	add    $0x1,%ecx
f01018f2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01018f6:	88 5a ff             	mov    %bl,-0x1(%edx)
f01018f9:	84 db                	test   %bl,%bl
f01018fb:	75 ef                	jne    f01018ec <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01018fd:	5b                   	pop    %ebx
f01018fe:	5d                   	pop    %ebp
f01018ff:	c3                   	ret    

f0101900 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101900:	55                   	push   %ebp
f0101901:	89 e5                	mov    %esp,%ebp
f0101903:	56                   	push   %esi
f0101904:	53                   	push   %ebx
f0101905:	8b 75 08             	mov    0x8(%ebp),%esi
f0101908:	8b 55 0c             	mov    0xc(%ebp),%edx
f010190b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010190e:	85 db                	test   %ebx,%ebx
f0101910:	74 17                	je     f0101929 <strncpy+0x29>
f0101912:	01 f3                	add    %esi,%ebx
f0101914:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f0101916:	83 c1 01             	add    $0x1,%ecx
f0101919:	0f b6 02             	movzbl (%edx),%eax
f010191c:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010191f:	80 3a 01             	cmpb   $0x1,(%edx)
f0101922:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101925:	39 cb                	cmp    %ecx,%ebx
f0101927:	75 ed                	jne    f0101916 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101929:	89 f0                	mov    %esi,%eax
f010192b:	5b                   	pop    %ebx
f010192c:	5e                   	pop    %esi
f010192d:	5d                   	pop    %ebp
f010192e:	c3                   	ret    

f010192f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010192f:	55                   	push   %ebp
f0101930:	89 e5                	mov    %esp,%ebp
f0101932:	56                   	push   %esi
f0101933:	53                   	push   %ebx
f0101934:	8b 75 08             	mov    0x8(%ebp),%esi
f0101937:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010193a:	8b 55 10             	mov    0x10(%ebp),%edx
f010193d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010193f:	85 d2                	test   %edx,%edx
f0101941:	74 35                	je     f0101978 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f0101943:	89 d0                	mov    %edx,%eax
f0101945:	83 e8 01             	sub    $0x1,%eax
f0101948:	74 25                	je     f010196f <strlcpy+0x40>
f010194a:	0f b6 0b             	movzbl (%ebx),%ecx
f010194d:	84 c9                	test   %cl,%cl
f010194f:	74 22                	je     f0101973 <strlcpy+0x44>
f0101951:	8d 53 01             	lea    0x1(%ebx),%edx
f0101954:	01 c3                	add    %eax,%ebx
f0101956:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f0101958:	83 c0 01             	add    $0x1,%eax
f010195b:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010195e:	39 da                	cmp    %ebx,%edx
f0101960:	74 13                	je     f0101975 <strlcpy+0x46>
f0101962:	83 c2 01             	add    $0x1,%edx
f0101965:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f0101969:	84 c9                	test   %cl,%cl
f010196b:	75 eb                	jne    f0101958 <strlcpy+0x29>
f010196d:	eb 06                	jmp    f0101975 <strlcpy+0x46>
f010196f:	89 f0                	mov    %esi,%eax
f0101971:	eb 02                	jmp    f0101975 <strlcpy+0x46>
f0101973:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101975:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101978:	29 f0                	sub    %esi,%eax
}
f010197a:	5b                   	pop    %ebx
f010197b:	5e                   	pop    %esi
f010197c:	5d                   	pop    %ebp
f010197d:	c3                   	ret    

f010197e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010197e:	55                   	push   %ebp
f010197f:	89 e5                	mov    %esp,%ebp
f0101981:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101984:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101987:	0f b6 01             	movzbl (%ecx),%eax
f010198a:	84 c0                	test   %al,%al
f010198c:	74 15                	je     f01019a3 <strcmp+0x25>
f010198e:	3a 02                	cmp    (%edx),%al
f0101990:	75 11                	jne    f01019a3 <strcmp+0x25>
		p++, q++;
f0101992:	83 c1 01             	add    $0x1,%ecx
f0101995:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101998:	0f b6 01             	movzbl (%ecx),%eax
f010199b:	84 c0                	test   %al,%al
f010199d:	74 04                	je     f01019a3 <strcmp+0x25>
f010199f:	3a 02                	cmp    (%edx),%al
f01019a1:	74 ef                	je     f0101992 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01019a3:	0f b6 c0             	movzbl %al,%eax
f01019a6:	0f b6 12             	movzbl (%edx),%edx
f01019a9:	29 d0                	sub    %edx,%eax
}
f01019ab:	5d                   	pop    %ebp
f01019ac:	c3                   	ret    

f01019ad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01019ad:	55                   	push   %ebp
f01019ae:	89 e5                	mov    %esp,%ebp
f01019b0:	56                   	push   %esi
f01019b1:	53                   	push   %ebx
f01019b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01019b5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01019b8:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f01019bb:	85 f6                	test   %esi,%esi
f01019bd:	74 29                	je     f01019e8 <strncmp+0x3b>
f01019bf:	0f b6 03             	movzbl (%ebx),%eax
f01019c2:	84 c0                	test   %al,%al
f01019c4:	74 30                	je     f01019f6 <strncmp+0x49>
f01019c6:	3a 02                	cmp    (%edx),%al
f01019c8:	75 2c                	jne    f01019f6 <strncmp+0x49>
f01019ca:	8d 43 01             	lea    0x1(%ebx),%eax
f01019cd:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f01019cf:	89 c3                	mov    %eax,%ebx
f01019d1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01019d4:	39 c6                	cmp    %eax,%esi
f01019d6:	74 17                	je     f01019ef <strncmp+0x42>
f01019d8:	0f b6 08             	movzbl (%eax),%ecx
f01019db:	84 c9                	test   %cl,%cl
f01019dd:	74 17                	je     f01019f6 <strncmp+0x49>
f01019df:	83 c0 01             	add    $0x1,%eax
f01019e2:	3a 0a                	cmp    (%edx),%cl
f01019e4:	74 e9                	je     f01019cf <strncmp+0x22>
f01019e6:	eb 0e                	jmp    f01019f6 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01019e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01019ed:	eb 0f                	jmp    f01019fe <strncmp+0x51>
f01019ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01019f4:	eb 08                	jmp    f01019fe <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01019f6:	0f b6 03             	movzbl (%ebx),%eax
f01019f9:	0f b6 12             	movzbl (%edx),%edx
f01019fc:	29 d0                	sub    %edx,%eax
}
f01019fe:	5b                   	pop    %ebx
f01019ff:	5e                   	pop    %esi
f0101a00:	5d                   	pop    %ebp
f0101a01:	c3                   	ret    

f0101a02 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101a02:	55                   	push   %ebp
f0101a03:	89 e5                	mov    %esp,%ebp
f0101a05:	53                   	push   %ebx
f0101a06:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0101a0c:	0f b6 10             	movzbl (%eax),%edx
f0101a0f:	84 d2                	test   %dl,%dl
f0101a11:	74 1d                	je     f0101a30 <strchr+0x2e>
f0101a13:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f0101a15:	38 d3                	cmp    %dl,%bl
f0101a17:	75 06                	jne    f0101a1f <strchr+0x1d>
f0101a19:	eb 1a                	jmp    f0101a35 <strchr+0x33>
f0101a1b:	38 ca                	cmp    %cl,%dl
f0101a1d:	74 16                	je     f0101a35 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101a1f:	83 c0 01             	add    $0x1,%eax
f0101a22:	0f b6 10             	movzbl (%eax),%edx
f0101a25:	84 d2                	test   %dl,%dl
f0101a27:	75 f2                	jne    f0101a1b <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f0101a29:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a2e:	eb 05                	jmp    f0101a35 <strchr+0x33>
f0101a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a35:	5b                   	pop    %ebx
f0101a36:	5d                   	pop    %ebp
f0101a37:	c3                   	ret    

f0101a38 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101a38:	55                   	push   %ebp
f0101a39:	89 e5                	mov    %esp,%ebp
f0101a3b:	53                   	push   %ebx
f0101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0101a42:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f0101a45:	38 d3                	cmp    %dl,%bl
f0101a47:	74 14                	je     f0101a5d <strfind+0x25>
f0101a49:	89 d1                	mov    %edx,%ecx
f0101a4b:	84 db                	test   %bl,%bl
f0101a4d:	74 0e                	je     f0101a5d <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101a4f:	83 c0 01             	add    $0x1,%eax
f0101a52:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101a55:	38 ca                	cmp    %cl,%dl
f0101a57:	74 04                	je     f0101a5d <strfind+0x25>
f0101a59:	84 d2                	test   %dl,%dl
f0101a5b:	75 f2                	jne    f0101a4f <strfind+0x17>
			break;
	return (char *) s;
}
f0101a5d:	5b                   	pop    %ebx
f0101a5e:	5d                   	pop    %ebp
f0101a5f:	c3                   	ret    

f0101a60 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101a60:	55                   	push   %ebp
f0101a61:	89 e5                	mov    %esp,%ebp
f0101a63:	57                   	push   %edi
f0101a64:	56                   	push   %esi
f0101a65:	53                   	push   %ebx
f0101a66:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101a69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101a6c:	85 c9                	test   %ecx,%ecx
f0101a6e:	74 36                	je     f0101aa6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101a70:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101a76:	75 28                	jne    f0101aa0 <memset+0x40>
f0101a78:	f6 c1 03             	test   $0x3,%cl
f0101a7b:	75 23                	jne    f0101aa0 <memset+0x40>
		c &= 0xFF;
f0101a7d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101a81:	89 d3                	mov    %edx,%ebx
f0101a83:	c1 e3 08             	shl    $0x8,%ebx
f0101a86:	89 d6                	mov    %edx,%esi
f0101a88:	c1 e6 18             	shl    $0x18,%esi
f0101a8b:	89 d0                	mov    %edx,%eax
f0101a8d:	c1 e0 10             	shl    $0x10,%eax
f0101a90:	09 f0                	or     %esi,%eax
f0101a92:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101a94:	89 d8                	mov    %ebx,%eax
f0101a96:	09 d0                	or     %edx,%eax
f0101a98:	c1 e9 02             	shr    $0x2,%ecx
f0101a9b:	fc                   	cld    
f0101a9c:	f3 ab                	rep stos %eax,%es:(%edi)
f0101a9e:	eb 06                	jmp    f0101aa6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101aa3:	fc                   	cld    
f0101aa4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101aa6:	89 f8                	mov    %edi,%eax
f0101aa8:	5b                   	pop    %ebx
f0101aa9:	5e                   	pop    %esi
f0101aaa:	5f                   	pop    %edi
f0101aab:	5d                   	pop    %ebp
f0101aac:	c3                   	ret    

f0101aad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101aad:	55                   	push   %ebp
f0101aae:	89 e5                	mov    %esp,%ebp
f0101ab0:	57                   	push   %edi
f0101ab1:	56                   	push   %esi
f0101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101ab8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101abb:	39 c6                	cmp    %eax,%esi
f0101abd:	73 35                	jae    f0101af4 <memmove+0x47>
f0101abf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101ac2:	39 d0                	cmp    %edx,%eax
f0101ac4:	73 2e                	jae    f0101af4 <memmove+0x47>
		s += n;
		d += n;
f0101ac6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101ac9:	89 d6                	mov    %edx,%esi
f0101acb:	09 fe                	or     %edi,%esi
f0101acd:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101ad3:	75 13                	jne    f0101ae8 <memmove+0x3b>
f0101ad5:	f6 c1 03             	test   $0x3,%cl
f0101ad8:	75 0e                	jne    f0101ae8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101ada:	83 ef 04             	sub    $0x4,%edi
f0101add:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101ae0:	c1 e9 02             	shr    $0x2,%ecx
f0101ae3:	fd                   	std    
f0101ae4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101ae6:	eb 09                	jmp    f0101af1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101ae8:	83 ef 01             	sub    $0x1,%edi
f0101aeb:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101aee:	fd                   	std    
f0101aef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101af1:	fc                   	cld    
f0101af2:	eb 1d                	jmp    f0101b11 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101af4:	89 f2                	mov    %esi,%edx
f0101af6:	09 c2                	or     %eax,%edx
f0101af8:	f6 c2 03             	test   $0x3,%dl
f0101afb:	75 0f                	jne    f0101b0c <memmove+0x5f>
f0101afd:	f6 c1 03             	test   $0x3,%cl
f0101b00:	75 0a                	jne    f0101b0c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101b02:	c1 e9 02             	shr    $0x2,%ecx
f0101b05:	89 c7                	mov    %eax,%edi
f0101b07:	fc                   	cld    
f0101b08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101b0a:	eb 05                	jmp    f0101b11 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101b0c:	89 c7                	mov    %eax,%edi
f0101b0e:	fc                   	cld    
f0101b0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101b11:	5e                   	pop    %esi
f0101b12:	5f                   	pop    %edi
f0101b13:	5d                   	pop    %ebp
f0101b14:	c3                   	ret    

f0101b15 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101b15:	55                   	push   %ebp
f0101b16:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101b18:	ff 75 10             	pushl  0x10(%ebp)
f0101b1b:	ff 75 0c             	pushl  0xc(%ebp)
f0101b1e:	ff 75 08             	pushl  0x8(%ebp)
f0101b21:	e8 87 ff ff ff       	call   f0101aad <memmove>
}
f0101b26:	c9                   	leave  
f0101b27:	c3                   	ret    

f0101b28 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101b28:	55                   	push   %ebp
f0101b29:	89 e5                	mov    %esp,%ebp
f0101b2b:	57                   	push   %edi
f0101b2c:	56                   	push   %esi
f0101b2d:	53                   	push   %ebx
f0101b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101b31:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b34:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b37:	85 c0                	test   %eax,%eax
f0101b39:	74 39                	je     f0101b74 <memcmp+0x4c>
f0101b3b:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f0101b3e:	0f b6 13             	movzbl (%ebx),%edx
f0101b41:	0f b6 0e             	movzbl (%esi),%ecx
f0101b44:	38 ca                	cmp    %cl,%dl
f0101b46:	75 17                	jne    f0101b5f <memcmp+0x37>
f0101b48:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b4d:	eb 1a                	jmp    f0101b69 <memcmp+0x41>
f0101b4f:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f0101b54:	83 c0 01             	add    $0x1,%eax
f0101b57:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f0101b5b:	38 ca                	cmp    %cl,%dl
f0101b5d:	74 0a                	je     f0101b69 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0101b5f:	0f b6 c2             	movzbl %dl,%eax
f0101b62:	0f b6 c9             	movzbl %cl,%ecx
f0101b65:	29 c8                	sub    %ecx,%eax
f0101b67:	eb 10                	jmp    f0101b79 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b69:	39 f8                	cmp    %edi,%eax
f0101b6b:	75 e2                	jne    f0101b4f <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101b6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b72:	eb 05                	jmp    f0101b79 <memcmp+0x51>
f0101b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b79:	5b                   	pop    %ebx
f0101b7a:	5e                   	pop    %esi
f0101b7b:	5f                   	pop    %edi
f0101b7c:	5d                   	pop    %ebp
f0101b7d:	c3                   	ret    

f0101b7e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101b7e:	55                   	push   %ebp
f0101b7f:	89 e5                	mov    %esp,%ebp
f0101b81:	53                   	push   %ebx
f0101b82:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f0101b85:	89 d0                	mov    %edx,%eax
f0101b87:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f0101b8a:	39 c2                	cmp    %eax,%edx
f0101b8c:	73 1d                	jae    f0101bab <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101b8e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f0101b92:	0f b6 0a             	movzbl (%edx),%ecx
f0101b95:	39 d9                	cmp    %ebx,%ecx
f0101b97:	75 09                	jne    f0101ba2 <memfind+0x24>
f0101b99:	eb 14                	jmp    f0101baf <memfind+0x31>
f0101b9b:	0f b6 0a             	movzbl (%edx),%ecx
f0101b9e:	39 d9                	cmp    %ebx,%ecx
f0101ba0:	74 11                	je     f0101bb3 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101ba2:	83 c2 01             	add    $0x1,%edx
f0101ba5:	39 d0                	cmp    %edx,%eax
f0101ba7:	75 f2                	jne    f0101b9b <memfind+0x1d>
f0101ba9:	eb 0a                	jmp    f0101bb5 <memfind+0x37>
f0101bab:	89 d0                	mov    %edx,%eax
f0101bad:	eb 06                	jmp    f0101bb5 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101baf:	89 d0                	mov    %edx,%eax
f0101bb1:	eb 02                	jmp    f0101bb5 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101bb3:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101bb5:	5b                   	pop    %ebx
f0101bb6:	5d                   	pop    %ebp
f0101bb7:	c3                   	ret    

f0101bb8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101bb8:	55                   	push   %ebp
f0101bb9:	89 e5                	mov    %esp,%ebp
f0101bbb:	57                   	push   %edi
f0101bbc:	56                   	push   %esi
f0101bbd:	53                   	push   %ebx
f0101bbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101bc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101bc4:	0f b6 01             	movzbl (%ecx),%eax
f0101bc7:	3c 20                	cmp    $0x20,%al
f0101bc9:	74 04                	je     f0101bcf <strtol+0x17>
f0101bcb:	3c 09                	cmp    $0x9,%al
f0101bcd:	75 0e                	jne    f0101bdd <strtol+0x25>
		s++;
f0101bcf:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101bd2:	0f b6 01             	movzbl (%ecx),%eax
f0101bd5:	3c 20                	cmp    $0x20,%al
f0101bd7:	74 f6                	je     f0101bcf <strtol+0x17>
f0101bd9:	3c 09                	cmp    $0x9,%al
f0101bdb:	74 f2                	je     f0101bcf <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101bdd:	3c 2b                	cmp    $0x2b,%al
f0101bdf:	75 0a                	jne    f0101beb <strtol+0x33>
		s++;
f0101be1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101be4:	bf 00 00 00 00       	mov    $0x0,%edi
f0101be9:	eb 11                	jmp    f0101bfc <strtol+0x44>
f0101beb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101bf0:	3c 2d                	cmp    $0x2d,%al
f0101bf2:	75 08                	jne    f0101bfc <strtol+0x44>
		s++, neg = 1;
f0101bf4:	83 c1 01             	add    $0x1,%ecx
f0101bf7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101bfc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101c02:	75 15                	jne    f0101c19 <strtol+0x61>
f0101c04:	80 39 30             	cmpb   $0x30,(%ecx)
f0101c07:	75 10                	jne    f0101c19 <strtol+0x61>
f0101c09:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101c0d:	75 7c                	jne    f0101c8b <strtol+0xd3>
		s += 2, base = 16;
f0101c0f:	83 c1 02             	add    $0x2,%ecx
f0101c12:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101c17:	eb 16                	jmp    f0101c2f <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0101c19:	85 db                	test   %ebx,%ebx
f0101c1b:	75 12                	jne    f0101c2f <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101c1d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101c22:	80 39 30             	cmpb   $0x30,(%ecx)
f0101c25:	75 08                	jne    f0101c2f <strtol+0x77>
		s++, base = 8;
f0101c27:	83 c1 01             	add    $0x1,%ecx
f0101c2a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101c2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c34:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101c37:	0f b6 11             	movzbl (%ecx),%edx
f0101c3a:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101c3d:	89 f3                	mov    %esi,%ebx
f0101c3f:	80 fb 09             	cmp    $0x9,%bl
f0101c42:	77 08                	ja     f0101c4c <strtol+0x94>
			dig = *s - '0';
f0101c44:	0f be d2             	movsbl %dl,%edx
f0101c47:	83 ea 30             	sub    $0x30,%edx
f0101c4a:	eb 22                	jmp    f0101c6e <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f0101c4c:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101c4f:	89 f3                	mov    %esi,%ebx
f0101c51:	80 fb 19             	cmp    $0x19,%bl
f0101c54:	77 08                	ja     f0101c5e <strtol+0xa6>
			dig = *s - 'a' + 10;
f0101c56:	0f be d2             	movsbl %dl,%edx
f0101c59:	83 ea 57             	sub    $0x57,%edx
f0101c5c:	eb 10                	jmp    f0101c6e <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f0101c5e:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101c61:	89 f3                	mov    %esi,%ebx
f0101c63:	80 fb 19             	cmp    $0x19,%bl
f0101c66:	77 16                	ja     f0101c7e <strtol+0xc6>
			dig = *s - 'A' + 10;
f0101c68:	0f be d2             	movsbl %dl,%edx
f0101c6b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101c6e:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101c71:	7d 0b                	jge    f0101c7e <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0101c73:	83 c1 01             	add    $0x1,%ecx
f0101c76:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101c7a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101c7c:	eb b9                	jmp    f0101c37 <strtol+0x7f>

	if (endptr)
f0101c7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101c82:	74 0d                	je     f0101c91 <strtol+0xd9>
		*endptr = (char *) s;
f0101c84:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101c87:	89 0e                	mov    %ecx,(%esi)
f0101c89:	eb 06                	jmp    f0101c91 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101c8b:	85 db                	test   %ebx,%ebx
f0101c8d:	74 98                	je     f0101c27 <strtol+0x6f>
f0101c8f:	eb 9e                	jmp    f0101c2f <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101c91:	89 c2                	mov    %eax,%edx
f0101c93:	f7 da                	neg    %edx
f0101c95:	85 ff                	test   %edi,%edi
f0101c97:	0f 45 c2             	cmovne %edx,%eax
}
f0101c9a:	5b                   	pop    %ebx
f0101c9b:	5e                   	pop    %esi
f0101c9c:	5f                   	pop    %edi
f0101c9d:	5d                   	pop    %ebp
f0101c9e:	c3                   	ret    
f0101c9f:	90                   	nop

f0101ca0 <__udivdi3>:
f0101ca0:	55                   	push   %ebp
f0101ca1:	57                   	push   %edi
f0101ca2:	56                   	push   %esi
f0101ca3:	53                   	push   %ebx
f0101ca4:	83 ec 1c             	sub    $0x1c,%esp
f0101ca7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0101cab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0101caf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101cb7:	85 f6                	test   %esi,%esi
f0101cb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101cbd:	89 ca                	mov    %ecx,%edx
f0101cbf:	89 f8                	mov    %edi,%eax
f0101cc1:	75 3d                	jne    f0101d00 <__udivdi3+0x60>
f0101cc3:	39 cf                	cmp    %ecx,%edi
f0101cc5:	0f 87 c5 00 00 00    	ja     f0101d90 <__udivdi3+0xf0>
f0101ccb:	85 ff                	test   %edi,%edi
f0101ccd:	89 fd                	mov    %edi,%ebp
f0101ccf:	75 0b                	jne    f0101cdc <__udivdi3+0x3c>
f0101cd1:	b8 01 00 00 00       	mov    $0x1,%eax
f0101cd6:	31 d2                	xor    %edx,%edx
f0101cd8:	f7 f7                	div    %edi
f0101cda:	89 c5                	mov    %eax,%ebp
f0101cdc:	89 c8                	mov    %ecx,%eax
f0101cde:	31 d2                	xor    %edx,%edx
f0101ce0:	f7 f5                	div    %ebp
f0101ce2:	89 c1                	mov    %eax,%ecx
f0101ce4:	89 d8                	mov    %ebx,%eax
f0101ce6:	89 cf                	mov    %ecx,%edi
f0101ce8:	f7 f5                	div    %ebp
f0101cea:	89 c3                	mov    %eax,%ebx
f0101cec:	89 d8                	mov    %ebx,%eax
f0101cee:	89 fa                	mov    %edi,%edx
f0101cf0:	83 c4 1c             	add    $0x1c,%esp
f0101cf3:	5b                   	pop    %ebx
f0101cf4:	5e                   	pop    %esi
f0101cf5:	5f                   	pop    %edi
f0101cf6:	5d                   	pop    %ebp
f0101cf7:	c3                   	ret    
f0101cf8:	90                   	nop
f0101cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d00:	39 ce                	cmp    %ecx,%esi
f0101d02:	77 74                	ja     f0101d78 <__udivdi3+0xd8>
f0101d04:	0f bd fe             	bsr    %esi,%edi
f0101d07:	83 f7 1f             	xor    $0x1f,%edi
f0101d0a:	0f 84 98 00 00 00    	je     f0101da8 <__udivdi3+0x108>
f0101d10:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101d15:	89 f9                	mov    %edi,%ecx
f0101d17:	89 c5                	mov    %eax,%ebp
f0101d19:	29 fb                	sub    %edi,%ebx
f0101d1b:	d3 e6                	shl    %cl,%esi
f0101d1d:	89 d9                	mov    %ebx,%ecx
f0101d1f:	d3 ed                	shr    %cl,%ebp
f0101d21:	89 f9                	mov    %edi,%ecx
f0101d23:	d3 e0                	shl    %cl,%eax
f0101d25:	09 ee                	or     %ebp,%esi
f0101d27:	89 d9                	mov    %ebx,%ecx
f0101d29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d2d:	89 d5                	mov    %edx,%ebp
f0101d2f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101d33:	d3 ed                	shr    %cl,%ebp
f0101d35:	89 f9                	mov    %edi,%ecx
f0101d37:	d3 e2                	shl    %cl,%edx
f0101d39:	89 d9                	mov    %ebx,%ecx
f0101d3b:	d3 e8                	shr    %cl,%eax
f0101d3d:	09 c2                	or     %eax,%edx
f0101d3f:	89 d0                	mov    %edx,%eax
f0101d41:	89 ea                	mov    %ebp,%edx
f0101d43:	f7 f6                	div    %esi
f0101d45:	89 d5                	mov    %edx,%ebp
f0101d47:	89 c3                	mov    %eax,%ebx
f0101d49:	f7 64 24 0c          	mull   0xc(%esp)
f0101d4d:	39 d5                	cmp    %edx,%ebp
f0101d4f:	72 10                	jb     f0101d61 <__udivdi3+0xc1>
f0101d51:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101d55:	89 f9                	mov    %edi,%ecx
f0101d57:	d3 e6                	shl    %cl,%esi
f0101d59:	39 c6                	cmp    %eax,%esi
f0101d5b:	73 07                	jae    f0101d64 <__udivdi3+0xc4>
f0101d5d:	39 d5                	cmp    %edx,%ebp
f0101d5f:	75 03                	jne    f0101d64 <__udivdi3+0xc4>
f0101d61:	83 eb 01             	sub    $0x1,%ebx
f0101d64:	31 ff                	xor    %edi,%edi
f0101d66:	89 d8                	mov    %ebx,%eax
f0101d68:	89 fa                	mov    %edi,%edx
f0101d6a:	83 c4 1c             	add    $0x1c,%esp
f0101d6d:	5b                   	pop    %ebx
f0101d6e:	5e                   	pop    %esi
f0101d6f:	5f                   	pop    %edi
f0101d70:	5d                   	pop    %ebp
f0101d71:	c3                   	ret    
f0101d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101d78:	31 ff                	xor    %edi,%edi
f0101d7a:	31 db                	xor    %ebx,%ebx
f0101d7c:	89 d8                	mov    %ebx,%eax
f0101d7e:	89 fa                	mov    %edi,%edx
f0101d80:	83 c4 1c             	add    $0x1c,%esp
f0101d83:	5b                   	pop    %ebx
f0101d84:	5e                   	pop    %esi
f0101d85:	5f                   	pop    %edi
f0101d86:	5d                   	pop    %ebp
f0101d87:	c3                   	ret    
f0101d88:	90                   	nop
f0101d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d90:	89 d8                	mov    %ebx,%eax
f0101d92:	f7 f7                	div    %edi
f0101d94:	31 ff                	xor    %edi,%edi
f0101d96:	89 c3                	mov    %eax,%ebx
f0101d98:	89 d8                	mov    %ebx,%eax
f0101d9a:	89 fa                	mov    %edi,%edx
f0101d9c:	83 c4 1c             	add    $0x1c,%esp
f0101d9f:	5b                   	pop    %ebx
f0101da0:	5e                   	pop    %esi
f0101da1:	5f                   	pop    %edi
f0101da2:	5d                   	pop    %ebp
f0101da3:	c3                   	ret    
f0101da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101da8:	39 ce                	cmp    %ecx,%esi
f0101daa:	72 0c                	jb     f0101db8 <__udivdi3+0x118>
f0101dac:	31 db                	xor    %ebx,%ebx
f0101dae:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101db2:	0f 87 34 ff ff ff    	ja     f0101cec <__udivdi3+0x4c>
f0101db8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0101dbd:	e9 2a ff ff ff       	jmp    f0101cec <__udivdi3+0x4c>
f0101dc2:	66 90                	xchg   %ax,%ax
f0101dc4:	66 90                	xchg   %ax,%ax
f0101dc6:	66 90                	xchg   %ax,%ax
f0101dc8:	66 90                	xchg   %ax,%ax
f0101dca:	66 90                	xchg   %ax,%ax
f0101dcc:	66 90                	xchg   %ax,%ax
f0101dce:	66 90                	xchg   %ax,%ax

f0101dd0 <__umoddi3>:
f0101dd0:	55                   	push   %ebp
f0101dd1:	57                   	push   %edi
f0101dd2:	56                   	push   %esi
f0101dd3:	53                   	push   %ebx
f0101dd4:	83 ec 1c             	sub    $0x1c,%esp
f0101dd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101ddb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0101ddf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101de7:	85 d2                	test   %edx,%edx
f0101de9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101df1:	89 f3                	mov    %esi,%ebx
f0101df3:	89 3c 24             	mov    %edi,(%esp)
f0101df6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101dfa:	75 1c                	jne    f0101e18 <__umoddi3+0x48>
f0101dfc:	39 f7                	cmp    %esi,%edi
f0101dfe:	76 50                	jbe    f0101e50 <__umoddi3+0x80>
f0101e00:	89 c8                	mov    %ecx,%eax
f0101e02:	89 f2                	mov    %esi,%edx
f0101e04:	f7 f7                	div    %edi
f0101e06:	89 d0                	mov    %edx,%eax
f0101e08:	31 d2                	xor    %edx,%edx
f0101e0a:	83 c4 1c             	add    $0x1c,%esp
f0101e0d:	5b                   	pop    %ebx
f0101e0e:	5e                   	pop    %esi
f0101e0f:	5f                   	pop    %edi
f0101e10:	5d                   	pop    %ebp
f0101e11:	c3                   	ret    
f0101e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101e18:	39 f2                	cmp    %esi,%edx
f0101e1a:	89 d0                	mov    %edx,%eax
f0101e1c:	77 52                	ja     f0101e70 <__umoddi3+0xa0>
f0101e1e:	0f bd ea             	bsr    %edx,%ebp
f0101e21:	83 f5 1f             	xor    $0x1f,%ebp
f0101e24:	75 5a                	jne    f0101e80 <__umoddi3+0xb0>
f0101e26:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0101e2a:	0f 82 e0 00 00 00    	jb     f0101f10 <__umoddi3+0x140>
f0101e30:	39 0c 24             	cmp    %ecx,(%esp)
f0101e33:	0f 86 d7 00 00 00    	jbe    f0101f10 <__umoddi3+0x140>
f0101e39:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101e3d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101e41:	83 c4 1c             	add    $0x1c,%esp
f0101e44:	5b                   	pop    %ebx
f0101e45:	5e                   	pop    %esi
f0101e46:	5f                   	pop    %edi
f0101e47:	5d                   	pop    %ebp
f0101e48:	c3                   	ret    
f0101e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101e50:	85 ff                	test   %edi,%edi
f0101e52:	89 fd                	mov    %edi,%ebp
f0101e54:	75 0b                	jne    f0101e61 <__umoddi3+0x91>
f0101e56:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e5b:	31 d2                	xor    %edx,%edx
f0101e5d:	f7 f7                	div    %edi
f0101e5f:	89 c5                	mov    %eax,%ebp
f0101e61:	89 f0                	mov    %esi,%eax
f0101e63:	31 d2                	xor    %edx,%edx
f0101e65:	f7 f5                	div    %ebp
f0101e67:	89 c8                	mov    %ecx,%eax
f0101e69:	f7 f5                	div    %ebp
f0101e6b:	89 d0                	mov    %edx,%eax
f0101e6d:	eb 99                	jmp    f0101e08 <__umoddi3+0x38>
f0101e6f:	90                   	nop
f0101e70:	89 c8                	mov    %ecx,%eax
f0101e72:	89 f2                	mov    %esi,%edx
f0101e74:	83 c4 1c             	add    $0x1c,%esp
f0101e77:	5b                   	pop    %ebx
f0101e78:	5e                   	pop    %esi
f0101e79:	5f                   	pop    %edi
f0101e7a:	5d                   	pop    %ebp
f0101e7b:	c3                   	ret    
f0101e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101e80:	8b 34 24             	mov    (%esp),%esi
f0101e83:	bf 20 00 00 00       	mov    $0x20,%edi
f0101e88:	89 e9                	mov    %ebp,%ecx
f0101e8a:	29 ef                	sub    %ebp,%edi
f0101e8c:	d3 e0                	shl    %cl,%eax
f0101e8e:	89 f9                	mov    %edi,%ecx
f0101e90:	89 f2                	mov    %esi,%edx
f0101e92:	d3 ea                	shr    %cl,%edx
f0101e94:	89 e9                	mov    %ebp,%ecx
f0101e96:	09 c2                	or     %eax,%edx
f0101e98:	89 d8                	mov    %ebx,%eax
f0101e9a:	89 14 24             	mov    %edx,(%esp)
f0101e9d:	89 f2                	mov    %esi,%edx
f0101e9f:	d3 e2                	shl    %cl,%edx
f0101ea1:	89 f9                	mov    %edi,%ecx
f0101ea3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101ea7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101eab:	d3 e8                	shr    %cl,%eax
f0101ead:	89 e9                	mov    %ebp,%ecx
f0101eaf:	89 c6                	mov    %eax,%esi
f0101eb1:	d3 e3                	shl    %cl,%ebx
f0101eb3:	89 f9                	mov    %edi,%ecx
f0101eb5:	89 d0                	mov    %edx,%eax
f0101eb7:	d3 e8                	shr    %cl,%eax
f0101eb9:	89 e9                	mov    %ebp,%ecx
f0101ebb:	09 d8                	or     %ebx,%eax
f0101ebd:	89 d3                	mov    %edx,%ebx
f0101ebf:	89 f2                	mov    %esi,%edx
f0101ec1:	f7 34 24             	divl   (%esp)
f0101ec4:	89 d6                	mov    %edx,%esi
f0101ec6:	d3 e3                	shl    %cl,%ebx
f0101ec8:	f7 64 24 04          	mull   0x4(%esp)
f0101ecc:	39 d6                	cmp    %edx,%esi
f0101ece:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101ed2:	89 d1                	mov    %edx,%ecx
f0101ed4:	89 c3                	mov    %eax,%ebx
f0101ed6:	72 08                	jb     f0101ee0 <__umoddi3+0x110>
f0101ed8:	75 11                	jne    f0101eeb <__umoddi3+0x11b>
f0101eda:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101ede:	73 0b                	jae    f0101eeb <__umoddi3+0x11b>
f0101ee0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101ee4:	1b 14 24             	sbb    (%esp),%edx
f0101ee7:	89 d1                	mov    %edx,%ecx
f0101ee9:	89 c3                	mov    %eax,%ebx
f0101eeb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101eef:	29 da                	sub    %ebx,%edx
f0101ef1:	19 ce                	sbb    %ecx,%esi
f0101ef3:	89 f9                	mov    %edi,%ecx
f0101ef5:	89 f0                	mov    %esi,%eax
f0101ef7:	d3 e0                	shl    %cl,%eax
f0101ef9:	89 e9                	mov    %ebp,%ecx
f0101efb:	d3 ea                	shr    %cl,%edx
f0101efd:	89 e9                	mov    %ebp,%ecx
f0101eff:	d3 ee                	shr    %cl,%esi
f0101f01:	09 d0                	or     %edx,%eax
f0101f03:	89 f2                	mov    %esi,%edx
f0101f05:	83 c4 1c             	add    $0x1c,%esp
f0101f08:	5b                   	pop    %ebx
f0101f09:	5e                   	pop    %esi
f0101f0a:	5f                   	pop    %edi
f0101f0b:	5d                   	pop    %ebp
f0101f0c:	c3                   	ret    
f0101f0d:	8d 76 00             	lea    0x0(%esi),%esi
f0101f10:	29 f9                	sub    %edi,%ecx
f0101f12:	19 d6                	sbb    %edx,%esi
f0101f14:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101f1c:	e9 18 ff ff ff       	jmp    f0101e39 <__umoddi3+0x69>
