
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
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 b0 ee 19 f0       	mov    $0xf019eeb0,%eax
f010004b:	2d 92 df 19 f0       	sub    $0xf019df92,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 92 df 19 f0       	push   $0xf019df92
f0100058:	e8 07 52 00 00       	call   f0105264 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 b2 04 00 00       	call   f0100514 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 40 57 10 f0       	push   $0xf0105740
f010006f:	e8 2b 39 00 00       	call   f010399f <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 94 16 00 00       	call   f010170d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 22 33 00 00       	call   f01033a0 <env_init>
	trap_init();
f010007e:	e8 8d 39 00 00       	call   f0103a10 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 0c             	add    $0xc,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 e8 89 00 00       	push   $0x89e8
f010008d:	68 92 f8 13 f0       	push   $0xf013f892
f0100092:	e8 d8 34 00 00       	call   f010356f <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100097:	83 c4 04             	add    $0x4,%esp
f010009a:	ff 35 f0 e1 19 f0    	pushl  0xf019e1f0
f01000a0:	e8 2a 38 00 00       	call   f01038cf <env_run>

f01000a5 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a5:	55                   	push   %ebp
f01000a6:	89 e5                	mov    %esp,%ebp
f01000a8:	56                   	push   %esi
f01000a9:	53                   	push   %ebx
f01000aa:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ad:	83 3d a0 ee 19 f0 00 	cmpl   $0x0,0xf019eea0
f01000b4:	75 37                	jne    f01000ed <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b6:	89 35 a0 ee 19 f0    	mov    %esi,0xf019eea0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000bc:	fa                   	cli    
f01000bd:	fc                   	cld    

	va_start(ap, fmt);
f01000be:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000c1:	83 ec 04             	sub    $0x4,%esp
f01000c4:	ff 75 0c             	pushl  0xc(%ebp)
f01000c7:	ff 75 08             	pushl  0x8(%ebp)
f01000ca:	68 5b 57 10 f0       	push   $0xf010575b
f01000cf:	e8 cb 38 00 00       	call   f010399f <cprintf>
	vcprintf(fmt, ap);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	53                   	push   %ebx
f01000d8:	56                   	push   %esi
f01000d9:	e8 9b 38 00 00       	call   f0103979 <vcprintf>
	cprintf("\n");
f01000de:	c7 04 24 5a 5a 10 f0 	movl   $0xf0105a5a,(%esp)
f01000e5:	e8 b5 38 00 00       	call   f010399f <cprintf>
	va_end(ap);
f01000ea:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000ed:	83 ec 0c             	sub    $0xc,%esp
f01000f0:	6a 00                	push   $0x0
f01000f2:	e8 7d 08 00 00       	call   f0100974 <monitor>
f01000f7:	83 c4 10             	add    $0x10,%esp
f01000fa:	eb f1                	jmp    f01000ed <_panic+0x48>

f01000fc <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000fc:	55                   	push   %ebp
f01000fd:	89 e5                	mov    %esp,%ebp
f01000ff:	53                   	push   %ebx
f0100100:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100103:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100106:	ff 75 0c             	pushl  0xc(%ebp)
f0100109:	ff 75 08             	pushl  0x8(%ebp)
f010010c:	68 73 57 10 f0       	push   $0xf0105773
f0100111:	e8 89 38 00 00       	call   f010399f <cprintf>
	vcprintf(fmt, ap);
f0100116:	83 c4 08             	add    $0x8,%esp
f0100119:	53                   	push   %ebx
f010011a:	ff 75 10             	pushl  0x10(%ebp)
f010011d:	e8 57 38 00 00       	call   f0103979 <vcprintf>
	cprintf("\n");
f0100122:	c7 04 24 5a 5a 10 f0 	movl   $0xf0105a5a,(%esp)
f0100129:	e8 71 38 00 00       	call   f010399f <cprintf>
	va_end(ap);
}
f010012e:	83 c4 10             	add    $0x10,%esp
f0100131:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100134:	c9                   	leave  
f0100135:	c3                   	ret    

f0100136 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100136:	55                   	push   %ebp
f0100137:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100139:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010013e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013f:	a8 01                	test   $0x1,%al
f0100141:	74 0b                	je     f010014e <serial_proc_data+0x18>
f0100143:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100148:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100149:	0f b6 c0             	movzbl %al,%eax
f010014c:	eb 05                	jmp    f0100153 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010014e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100153:	5d                   	pop    %ebp
f0100154:	c3                   	ret    

f0100155 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100155:	55                   	push   %ebp
f0100156:	89 e5                	mov    %esp,%ebp
f0100158:	53                   	push   %ebx
f0100159:	83 ec 04             	sub    $0x4,%esp
f010015c:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010015e:	eb 2b                	jmp    f010018b <cons_intr+0x36>
		if (c == 0)
f0100160:	85 c0                	test   %eax,%eax
f0100162:	74 27                	je     f010018b <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100164:	8b 0d c4 e1 19 f0    	mov    0xf019e1c4,%ecx
f010016a:	8d 51 01             	lea    0x1(%ecx),%edx
f010016d:	89 15 c4 e1 19 f0    	mov    %edx,0xf019e1c4
f0100173:	88 81 c0 df 19 f0    	mov    %al,-0xfe62040(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100179:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017f:	75 0a                	jne    f010018b <cons_intr+0x36>
			cons.wpos = 0;
f0100181:	c7 05 c4 e1 19 f0 00 	movl   $0x0,0xf019e1c4
f0100188:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010018b:	ff d3                	call   *%ebx
f010018d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100190:	75 ce                	jne    f0100160 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100192:	83 c4 04             	add    $0x4,%esp
f0100195:	5b                   	pop    %ebx
f0100196:	5d                   	pop    %ebp
f0100197:	c3                   	ret    

f0100198 <kbd_proc_data>:
f0100198:	ba 64 00 00 00       	mov    $0x64,%edx
f010019d:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010019e:	a8 01                	test   $0x1,%al
f01001a0:	0f 84 f0 00 00 00    	je     f0100296 <kbd_proc_data+0xfe>
f01001a6:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ab:	ec                   	in     (%dx),%al
f01001ac:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001ae:	3c e0                	cmp    $0xe0,%al
f01001b0:	75 0d                	jne    f01001bf <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001b2:	83 0d a0 df 19 f0 40 	orl    $0x40,0xf019dfa0
		return 0;
f01001b9:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001be:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001bf:	55                   	push   %ebp
f01001c0:	89 e5                	mov    %esp,%ebp
f01001c2:	53                   	push   %ebx
f01001c3:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c6:	84 c0                	test   %al,%al
f01001c8:	79 36                	jns    f0100200 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ca:	8b 0d a0 df 19 f0    	mov    0xf019dfa0,%ecx
f01001d0:	89 cb                	mov    %ecx,%ebx
f01001d2:	83 e3 40             	and    $0x40,%ebx
f01001d5:	83 e0 7f             	and    $0x7f,%eax
f01001d8:	85 db                	test   %ebx,%ebx
f01001da:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001dd:	0f b6 d2             	movzbl %dl,%edx
f01001e0:	0f b6 82 e0 58 10 f0 	movzbl -0xfefa720(%edx),%eax
f01001e7:	83 c8 40             	or     $0x40,%eax
f01001ea:	0f b6 c0             	movzbl %al,%eax
f01001ed:	f7 d0                	not    %eax
f01001ef:	21 c8                	and    %ecx,%eax
f01001f1:	a3 a0 df 19 f0       	mov    %eax,0xf019dfa0
		return 0;
f01001f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01001fb:	e9 9e 00 00 00       	jmp    f010029e <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100200:	8b 0d a0 df 19 f0    	mov    0xf019dfa0,%ecx
f0100206:	f6 c1 40             	test   $0x40,%cl
f0100209:	74 0e                	je     f0100219 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010020b:	83 c8 80             	or     $0xffffff80,%eax
f010020e:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100210:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100213:	89 0d a0 df 19 f0    	mov    %ecx,0xf019dfa0
	}

	shift |= shiftcode[data];
f0100219:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010021c:	0f b6 82 e0 58 10 f0 	movzbl -0xfefa720(%edx),%eax
f0100223:	0b 05 a0 df 19 f0    	or     0xf019dfa0,%eax
f0100229:	0f b6 8a e0 57 10 f0 	movzbl -0xfefa820(%edx),%ecx
f0100230:	31 c8                	xor    %ecx,%eax
f0100232:	a3 a0 df 19 f0       	mov    %eax,0xf019dfa0

	c = charcode[shift & (CTL | SHIFT)][data];
f0100237:	89 c1                	mov    %eax,%ecx
f0100239:	83 e1 03             	and    $0x3,%ecx
f010023c:	8b 0c 8d c0 57 10 f0 	mov    -0xfefa840(,%ecx,4),%ecx
f0100243:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100247:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010024a:	a8 08                	test   $0x8,%al
f010024c:	74 1b                	je     f0100269 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010024e:	89 da                	mov    %ebx,%edx
f0100250:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100253:	83 f9 19             	cmp    $0x19,%ecx
f0100256:	77 05                	ja     f010025d <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100258:	83 eb 20             	sub    $0x20,%ebx
f010025b:	eb 0c                	jmp    f0100269 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010025d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100260:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100263:	83 fa 19             	cmp    $0x19,%edx
f0100266:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100269:	f7 d0                	not    %eax
f010026b:	a8 06                	test   $0x6,%al
f010026d:	75 2d                	jne    f010029c <kbd_proc_data+0x104>
f010026f:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100275:	75 25                	jne    f010029c <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100277:	83 ec 0c             	sub    $0xc,%esp
f010027a:	68 8d 57 10 f0       	push   $0xf010578d
f010027f:	e8 1b 37 00 00       	call   f010399f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100284:	ba 92 00 00 00       	mov    $0x92,%edx
f0100289:	b8 03 00 00 00       	mov    $0x3,%eax
f010028e:	ee                   	out    %al,(%dx)
f010028f:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100292:	89 d8                	mov    %ebx,%eax
f0100294:	eb 08                	jmp    f010029e <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010029b:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010029c:	89 d8                	mov    %ebx,%eax
}
f010029e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002a1:	c9                   	leave  
f01002a2:	c3                   	ret    

f01002a3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002a3:	55                   	push   %ebp
f01002a4:	89 e5                	mov    %esp,%ebp
f01002a6:	57                   	push   %edi
f01002a7:	56                   	push   %esi
f01002a8:	53                   	push   %ebx
f01002a9:	83 ec 1c             	sub    $0x1c,%esp
f01002ac:	89 c7                	mov    %eax,%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ae:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002b3:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002b4:	a8 20                	test   $0x20,%al
f01002b6:	75 27                	jne    f01002df <cons_putc+0x3c>
f01002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002bd:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002c2:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002c7:	89 ca                	mov    %ecx,%edx
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	ec                   	in     (%dx),%al
f01002cc:	ec                   	in     (%dx),%al
	     i++)
f01002cd:	83 c3 01             	add    $0x1,%ebx
f01002d0:	89 f2                	mov    %esi,%edx
f01002d2:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d3:	a8 20                	test   $0x20,%al
f01002d5:	75 08                	jne    f01002df <cons_putc+0x3c>
f01002d7:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002dd:	7e e8                	jle    f01002c7 <cons_putc+0x24>
f01002df:	89 f8                	mov    %edi,%eax
f01002e1:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002e9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ea:	ba 79 03 00 00       	mov    $0x379,%edx
f01002ef:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002f0:	84 c0                	test   %al,%al
f01002f2:	78 27                	js     f010031b <cons_putc+0x78>
f01002f4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002f9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fe:	be 79 03 00 00       	mov    $0x379,%esi
f0100303:	89 ca                	mov    %ecx,%edx
f0100305:	ec                   	in     (%dx),%al
f0100306:	ec                   	in     (%dx),%al
f0100307:	ec                   	in     (%dx),%al
f0100308:	ec                   	in     (%dx),%al
f0100309:	83 c3 01             	add    $0x1,%ebx
f010030c:	89 f2                	mov    %esi,%edx
f010030e:	ec                   	in     (%dx),%al
f010030f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100315:	7f 04                	jg     f010031b <cons_putc+0x78>
f0100317:	84 c0                	test   %al,%al
f0100319:	79 e8                	jns    f0100303 <cons_putc+0x60>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100320:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100324:	ee                   	out    %al,(%dx)
f0100325:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010032a:	b8 0d 00 00 00       	mov    $0xd,%eax
f010032f:	ee                   	out    %al,(%dx)
f0100330:	b8 08 00 00 00       	mov    $0x8,%eax
f0100335:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100336:	89 fa                	mov    %edi,%edx
f0100338:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010033e:	89 f8                	mov    %edi,%eax
f0100340:	80 cc 07             	or     $0x7,%ah
f0100343:	85 d2                	test   %edx,%edx
f0100345:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100348:	89 f8                	mov    %edi,%eax
f010034a:	0f b6 c0             	movzbl %al,%eax
f010034d:	83 f8 09             	cmp    $0x9,%eax
f0100350:	74 74                	je     f01003c6 <cons_putc+0x123>
f0100352:	83 f8 09             	cmp    $0x9,%eax
f0100355:	7f 0a                	jg     f0100361 <cons_putc+0xbe>
f0100357:	83 f8 08             	cmp    $0x8,%eax
f010035a:	74 14                	je     f0100370 <cons_putc+0xcd>
f010035c:	e9 99 00 00 00       	jmp    f01003fa <cons_putc+0x157>
f0100361:	83 f8 0a             	cmp    $0xa,%eax
f0100364:	74 3a                	je     f01003a0 <cons_putc+0xfd>
f0100366:	83 f8 0d             	cmp    $0xd,%eax
f0100369:	74 3d                	je     f01003a8 <cons_putc+0x105>
f010036b:	e9 8a 00 00 00       	jmp    f01003fa <cons_putc+0x157>
	case '\b':
		if (crt_pos > 0) {
f0100370:	0f b7 05 c8 e1 19 f0 	movzwl 0xf019e1c8,%eax
f0100377:	66 85 c0             	test   %ax,%ax
f010037a:	0f 84 e6 00 00 00    	je     f0100466 <cons_putc+0x1c3>
			crt_pos--;
f0100380:	83 e8 01             	sub    $0x1,%eax
f0100383:	66 a3 c8 e1 19 f0    	mov    %ax,0xf019e1c8
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100389:	0f b7 c0             	movzwl %ax,%eax
f010038c:	66 81 e7 00 ff       	and    $0xff00,%di
f0100391:	83 cf 20             	or     $0x20,%edi
f0100394:	8b 15 cc e1 19 f0    	mov    0xf019e1cc,%edx
f010039a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010039e:	eb 78                	jmp    f0100418 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003a0:	66 83 05 c8 e1 19 f0 	addw   $0x50,0xf019e1c8
f01003a7:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003a8:	0f b7 05 c8 e1 19 f0 	movzwl 0xf019e1c8,%eax
f01003af:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003b5:	c1 e8 16             	shr    $0x16,%eax
f01003b8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003bb:	c1 e0 04             	shl    $0x4,%eax
f01003be:	66 a3 c8 e1 19 f0    	mov    %ax,0xf019e1c8
f01003c4:	eb 52                	jmp    f0100418 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f01003c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cb:	e8 d3 fe ff ff       	call   f01002a3 <cons_putc>
		cons_putc(' ');
f01003d0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d5:	e8 c9 fe ff ff       	call   f01002a3 <cons_putc>
		cons_putc(' ');
f01003da:	b8 20 00 00 00       	mov    $0x20,%eax
f01003df:	e8 bf fe ff ff       	call   f01002a3 <cons_putc>
		cons_putc(' ');
f01003e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e9:	e8 b5 fe ff ff       	call   f01002a3 <cons_putc>
		cons_putc(' ');
f01003ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f3:	e8 ab fe ff ff       	call   f01002a3 <cons_putc>
f01003f8:	eb 1e                	jmp    f0100418 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003fa:	0f b7 05 c8 e1 19 f0 	movzwl 0xf019e1c8,%eax
f0100401:	8d 50 01             	lea    0x1(%eax),%edx
f0100404:	66 89 15 c8 e1 19 f0 	mov    %dx,0xf019e1c8
f010040b:	0f b7 c0             	movzwl %ax,%eax
f010040e:	8b 15 cc e1 19 f0    	mov    0xf019e1cc,%edx
f0100414:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100418:	66 81 3d c8 e1 19 f0 	cmpw   $0x7cf,0xf019e1c8
f010041f:	cf 07 
f0100421:	76 43                	jbe    f0100466 <cons_putc+0x1c3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100423:	a1 cc e1 19 f0       	mov    0xf019e1cc,%eax
f0100428:	83 ec 04             	sub    $0x4,%esp
f010042b:	68 00 0f 00 00       	push   $0xf00
f0100430:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100436:	52                   	push   %edx
f0100437:	50                   	push   %eax
f0100438:	e8 74 4e 00 00       	call   f01052b1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010043d:	8b 15 cc e1 19 f0    	mov    0xf019e1cc,%edx
f0100443:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100449:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010044f:	83 c4 10             	add    $0x10,%esp
f0100452:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100457:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010045a:	39 c2                	cmp    %eax,%edx
f010045c:	75 f4                	jne    f0100452 <cons_putc+0x1af>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010045e:	66 83 2d c8 e1 19 f0 	subw   $0x50,0xf019e1c8
f0100465:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100466:	8b 0d d0 e1 19 f0    	mov    0xf019e1d0,%ecx
f010046c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100471:	89 ca                	mov    %ecx,%edx
f0100473:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100474:	0f b7 1d c8 e1 19 f0 	movzwl 0xf019e1c8,%ebx
f010047b:	8d 71 01             	lea    0x1(%ecx),%esi
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	66 c1 e8 08          	shr    $0x8,%ax
f0100484:	89 f2                	mov    %esi,%edx
f0100486:	ee                   	out    %al,(%dx)
f0100487:	b8 0f 00 00 00       	mov    $0xf,%eax
f010048c:	89 ca                	mov    %ecx,%edx
f010048e:	ee                   	out    %al,(%dx)
f010048f:	89 d8                	mov    %ebx,%eax
f0100491:	89 f2                	mov    %esi,%edx
f0100493:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100494:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100497:	5b                   	pop    %ebx
f0100498:	5e                   	pop    %esi
f0100499:	5f                   	pop    %edi
f010049a:	5d                   	pop    %ebp
f010049b:	c3                   	ret    

f010049c <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f010049c:	83 3d d4 e1 19 f0 00 	cmpl   $0x0,0xf019e1d4
f01004a3:	74 11                	je     f01004b6 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004a5:	55                   	push   %ebp
f01004a6:	89 e5                	mov    %esp,%ebp
f01004a8:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ab:	b8 36 01 10 f0       	mov    $0xf0100136,%eax
f01004b0:	e8 a0 fc ff ff       	call   f0100155 <cons_intr>
}
f01004b5:	c9                   	leave  
f01004b6:	f3 c3                	repz ret 

f01004b8 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004b8:	55                   	push   %ebp
f01004b9:	89 e5                	mov    %esp,%ebp
f01004bb:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004be:	b8 98 01 10 f0       	mov    $0xf0100198,%eax
f01004c3:	e8 8d fc ff ff       	call   f0100155 <cons_intr>
}
f01004c8:	c9                   	leave  
f01004c9:	c3                   	ret    

f01004ca <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ca:	55                   	push   %ebp
f01004cb:	89 e5                	mov    %esp,%ebp
f01004cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004d0:	e8 c7 ff ff ff       	call   f010049c <serial_intr>
	kbd_intr();
f01004d5:	e8 de ff ff ff       	call   f01004b8 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004da:	a1 c0 e1 19 f0       	mov    0xf019e1c0,%eax
f01004df:	3b 05 c4 e1 19 f0    	cmp    0xf019e1c4,%eax
f01004e5:	74 26                	je     f010050d <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004e7:	8d 50 01             	lea    0x1(%eax),%edx
f01004ea:	89 15 c0 e1 19 f0    	mov    %edx,0xf019e1c0
f01004f0:	0f b6 88 c0 df 19 f0 	movzbl -0xfe62040(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004f7:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004f9:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ff:	75 11                	jne    f0100512 <cons_getc+0x48>
			cons.rpos = 0;
f0100501:	c7 05 c0 e1 19 f0 00 	movl   $0x0,0xf019e1c0
f0100508:	00 00 00 
f010050b:	eb 05                	jmp    f0100512 <cons_getc+0x48>
		return c;
	}
	return 0;
f010050d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100512:	c9                   	leave  
f0100513:	c3                   	ret    

f0100514 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100514:	55                   	push   %ebp
f0100515:	89 e5                	mov    %esp,%ebp
f0100517:	57                   	push   %edi
f0100518:	56                   	push   %esi
f0100519:	53                   	push   %ebx
f010051a:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010051d:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100524:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010052b:	5a a5 
	if (*cp != 0xA55A) {
f010052d:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100534:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100538:	74 11                	je     f010054b <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010053a:	c7 05 d0 e1 19 f0 b4 	movl   $0x3b4,0xf019e1d0
f0100541:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100544:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100549:	eb 16                	jmp    f0100561 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010054b:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100552:	c7 05 d0 e1 19 f0 d4 	movl   $0x3d4,0xf019e1d0
f0100559:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010055c:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100561:	8b 3d d0 e1 19 f0    	mov    0xf019e1d0,%edi
f0100567:	b8 0e 00 00 00       	mov    $0xe,%eax
f010056c:	89 fa                	mov    %edi,%edx
f010056e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010056f:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100572:	89 da                	mov    %ebx,%edx
f0100574:	ec                   	in     (%dx),%al
f0100575:	0f b6 c8             	movzbl %al,%ecx
f0100578:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100580:	89 fa                	mov    %edi,%edx
f0100582:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100583:	89 da                	mov    %ebx,%edx
f0100585:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100586:	89 35 cc e1 19 f0    	mov    %esi,0xf019e1cc
	crt_pos = pos;
f010058c:	0f b6 c0             	movzbl %al,%eax
f010058f:	09 c8                	or     %ecx,%eax
f0100591:	66 a3 c8 e1 19 f0    	mov    %ax,0xf019e1c8
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100597:	be fa 03 00 00       	mov    $0x3fa,%esi
f010059c:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a1:	89 f2                	mov    %esi,%edx
f01005a3:	ee                   	out    %al,(%dx)
f01005a4:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005a9:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ae:	ee                   	out    %al,(%dx)
f01005af:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005b4:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005b9:	89 da                	mov    %ebx,%edx
f01005bb:	ee                   	out    %al,(%dx)
f01005bc:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c6:	ee                   	out    %al,(%dx)
f01005c7:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005cc:	b8 03 00 00 00       	mov    $0x3,%eax
f01005d1:	ee                   	out    %al,(%dx)
f01005d2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005dc:	ee                   	out    %al,(%dx)
f01005dd:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01005e7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005ed:	ec                   	in     (%dx),%al
f01005ee:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005f0:	3c ff                	cmp    $0xff,%al
f01005f2:	0f 95 c0             	setne  %al
f01005f5:	0f b6 c0             	movzbl %al,%eax
f01005f8:	a3 d4 e1 19 f0       	mov    %eax,0xf019e1d4
f01005fd:	89 f2                	mov    %esi,%edx
f01005ff:	ec                   	in     (%dx),%al
f0100600:	89 da                	mov    %ebx,%edx
f0100602:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100603:	80 f9 ff             	cmp    $0xff,%cl
f0100606:	75 10                	jne    f0100618 <cons_init+0x104>
		cprintf("Serial port does not exist!\n");
f0100608:	83 ec 0c             	sub    $0xc,%esp
f010060b:	68 99 57 10 f0       	push   $0xf0105799
f0100610:	e8 8a 33 00 00       	call   f010399f <cprintf>
f0100615:	83 c4 10             	add    $0x10,%esp
}
f0100618:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010061b:	5b                   	pop    %ebx
f010061c:	5e                   	pop    %esi
f010061d:	5f                   	pop    %edi
f010061e:	5d                   	pop    %ebp
f010061f:	c3                   	ret    

f0100620 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100626:	8b 45 08             	mov    0x8(%ebp),%eax
f0100629:	e8 75 fc ff ff       	call   f01002a3 <cons_putc>
}
f010062e:	c9                   	leave  
f010062f:	c3                   	ret    

f0100630 <getchar>:

int
getchar(void)
{
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100636:	e8 8f fe ff ff       	call   f01004ca <cons_getc>
f010063b:	85 c0                	test   %eax,%eax
f010063d:	74 f7                	je     f0100636 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010063f:	c9                   	leave  
f0100640:	c3                   	ret    

f0100641 <iscons>:

int
iscons(int fdnum)
{
f0100641:	55                   	push   %ebp
f0100642:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100644:	b8 01 00 00 00       	mov    $0x1,%eax
f0100649:	5d                   	pop    %ebp
f010064a:	c3                   	ret    

f010064b <mon_help>:
	return 0;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010064b:	55                   	push   %ebp
f010064c:	89 e5                	mov    %esp,%ebp
f010064e:	56                   	push   %esi
f010064f:	53                   	push   %ebx
f0100650:	bb 24 5d 10 f0       	mov    $0xf0105d24,%ebx
f0100655:	be 78 5d 10 f0       	mov    $0xf0105d78,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010065a:	83 ec 04             	sub    $0x4,%esp
f010065d:	ff 33                	pushl  (%ebx)
f010065f:	ff 73 fc             	pushl  -0x4(%ebx)
f0100662:	68 e0 59 10 f0       	push   $0xf01059e0
f0100667:	e8 33 33 00 00       	call   f010399f <cprintf>
f010066c:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f010066f:	83 c4 10             	add    $0x10,%esp
f0100672:	39 f3                	cmp    %esi,%ebx
f0100674:	75 e4                	jne    f010065a <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100676:	b8 00 00 00 00       	mov    $0x0,%eax
f010067b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010067e:	5b                   	pop    %ebx
f010067f:	5e                   	pop    %esi
f0100680:	5d                   	pop    %ebp
f0100681:	c3                   	ret    

f0100682 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100682:	55                   	push   %ebp
f0100683:	89 e5                	mov    %esp,%ebp
f0100685:	83 ec 14             	sub    $0x14,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100688:	68 e9 59 10 f0       	push   $0xf01059e9
f010068d:	e8 0d 33 00 00       	call   f010399f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100692:	83 c4 0c             	add    $0xc,%esp
f0100695:	68 0c 00 10 00       	push   $0x10000c
f010069a:	68 0c 00 10 f0       	push   $0xf010000c
f010069f:	68 5c 5b 10 f0       	push   $0xf0105b5c
f01006a4:	e8 f6 32 00 00       	call   f010399f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a9:	83 c4 0c             	add    $0xc,%esp
f01006ac:	68 31 57 10 00       	push   $0x105731
f01006b1:	68 31 57 10 f0       	push   $0xf0105731
f01006b6:	68 80 5b 10 f0       	push   $0xf0105b80
f01006bb:	e8 df 32 00 00       	call   f010399f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c0:	83 c4 0c             	add    $0xc,%esp
f01006c3:	68 92 df 19 00       	push   $0x19df92
f01006c8:	68 92 df 19 f0       	push   $0xf019df92
f01006cd:	68 a4 5b 10 f0       	push   $0xf0105ba4
f01006d2:	e8 c8 32 00 00       	call   f010399f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006d7:	83 c4 0c             	add    $0xc,%esp
f01006da:	68 b0 ee 19 00       	push   $0x19eeb0
f01006df:	68 b0 ee 19 f0       	push   $0xf019eeb0
f01006e4:	68 c8 5b 10 f0       	push   $0xf0105bc8
f01006e9:	e8 b1 32 00 00       	call   f010399f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ee:	83 c4 08             	add    $0x8,%esp
f01006f1:	b8 af f2 19 f0       	mov    $0xf019f2af,%eax
f01006f6:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006fb:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100701:	85 c0                	test   %eax,%eax
f0100703:	0f 48 c2             	cmovs  %edx,%eax
f0100706:	c1 f8 0a             	sar    $0xa,%eax
f0100709:	50                   	push   %eax
f010070a:	68 ec 5b 10 f0       	push   $0xf0105bec
f010070f:	e8 8b 32 00 00       	call   f010399f <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100714:	b8 00 00 00 00       	mov    $0x0,%eax
f0100719:	c9                   	leave  
f010071a:	c3                   	ret    

f010071b <mon_debug_display>:
unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/
int
mon_debug_display(int argc, char **argv, struct Trapframe *tf)
{
f010071b:	55                   	push   %ebp
f010071c:	89 e5                	mov    %esp,%ebp
f010071e:	83 ec 08             	sub    $0x8,%esp
	if (argc != 2) {
f0100721:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100725:	74 17                	je     f010073e <mon_debug_display+0x23>
		cprintf("Usage: x [address]");
f0100727:	83 ec 0c             	sub    $0xc,%esp
f010072a:	68 02 5a 10 f0       	push   $0xf0105a02
f010072f:	e8 6b 32 00 00       	call   f010399f <cprintf>
		return 1;
f0100734:	83 c4 10             	add    $0x10,%esp
f0100737:	b8 01 00 00 00       	mov    $0x1,%eax
f010073c:	eb 29                	jmp    f0100767 <mon_debug_display+0x4c>
	}

	int result = *(int *)(strtol(argv[1], NULL, 16));
f010073e:	83 ec 04             	sub    $0x4,%esp
f0100741:	6a 10                	push   $0x10
f0100743:	6a 00                	push   $0x0
f0100745:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100748:	ff 70 04             	pushl  0x4(%eax)
f010074b:	e8 6c 4c 00 00       	call   f01053bc <strtol>
	cprintf("%d\n", result);
f0100750:	83 c4 08             	add    $0x8,%esp
f0100753:	ff 30                	pushl  (%eax)
f0100755:	68 15 5a 10 f0       	push   $0xf0105a15
f010075a:	e8 40 32 00 00       	call   f010399f <cprintf>
	return 0;
f010075f:	83 c4 10             	add    $0x10,%esp
f0100762:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100767:	c9                   	leave  
f0100768:	c3                   	ret    

f0100769 <mon_debug_step>:

int
mon_debug_step(int argc, char **argv, struct Trapframe *tf)
{
f0100769:	55                   	push   %ebp
f010076a:	89 e5                	mov    %esp,%ebp
f010076c:	83 ec 08             	sub    $0x8,%esp
f010076f:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf == NULL) {
f0100772:	85 c0                	test   %eax,%eax
f0100774:	74 25                	je     f010079b <mon_debug_step+0x32>
		cprintf("Trapframe is NULL.\n");
		return 1;
	}

	tf->tf_eflags |= FL_TF;
f0100776:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
	cprintf("tf_eip=0x%x\n", tf->tf_eip);
f010077d:	83 ec 08             	sub    $0x8,%esp
f0100780:	ff 70 30             	pushl  0x30(%eax)
f0100783:	68 2d 5a 10 f0       	push   $0xf0105a2d
f0100788:	e8 12 32 00 00       	call   f010399f <cprintf>
	env_run(curenv);
f010078d:	83 c4 04             	add    $0x4,%esp
f0100790:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f0100796:	e8 34 31 00 00       	call   f01038cf <env_run>

int
mon_debug_step(int argc, char **argv, struct Trapframe *tf)
{
	if (tf == NULL) {
		cprintf("Trapframe is NULL.\n");
f010079b:	83 ec 0c             	sub    $0xc,%esp
f010079e:	68 19 5a 10 f0       	push   $0xf0105a19
f01007a3:	e8 f7 31 00 00       	call   f010399f <cprintf>

	tf->tf_eflags |= FL_TF;
	cprintf("tf_eip=0x%x\n", tf->tf_eip);
	env_run(curenv);
	return 0;
}
f01007a8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ad:	c9                   	leave  
f01007ae:	c3                   	ret    

f01007af <mon_debug_continue>:

int
mon_debug_continue(int argc, char **argv, struct Trapframe *tf)
{
f01007af:	55                   	push   %ebp
f01007b0:	89 e5                	mov    %esp,%ebp
f01007b2:	83 ec 08             	sub    $0x8,%esp
f01007b5:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf == NULL) {
f01007b8:	85 c0                	test   %eax,%eax
f01007ba:	74 15                	je     f01007d1 <mon_debug_continue+0x22>
		cprintf("Trapframe is NULL.\n");
		return 1;
	}

	tf->tf_eflags &= ~FL_TF;
f01007bc:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	env_run(curenv);
f01007c3:	83 ec 0c             	sub    $0xc,%esp
f01007c6:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f01007cc:	e8 fe 30 00 00       	call   f01038cf <env_run>

int
mon_debug_continue(int argc, char **argv, struct Trapframe *tf)
{
	if (tf == NULL) {
		cprintf("Trapframe is NULL.\n");
f01007d1:	83 ec 0c             	sub    $0xc,%esp
f01007d4:	68 19 5a 10 f0       	push   $0xf0105a19
f01007d9:	e8 c1 31 00 00       	call   f010399f <cprintf>
	}

	tf->tf_eflags &= ~FL_TF;
	env_run(curenv);
	return 0;
}
f01007de:	b8 01 00 00 00       	mov    $0x1,%eax
f01007e3:	c9                   	leave  
f01007e4:	c3                   	ret    

f01007e5 <mon_backtrace>:

#define EBP_OFFSET(ebp, offset) (*((uint32_t *)(ebp) + (offset)))

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007e5:	55                   	push   %ebp
f01007e6:	89 e5                	mov    %esp,%ebp
f01007e8:	57                   	push   %edi
f01007e9:	56                   	push   %esi
f01007ea:	53                   	push   %ebx
f01007eb:	83 ec 48             	sub    $0x48,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01007ee:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
f01007f0:	68 3a 5a 10 f0       	push   $0xf0105a3a
f01007f5:	e8 a5 31 00 00       	call   f010399f <cprintf>
	while(ebp != 0x0) {
f01007fa:	83 c4 10             	add    $0x10,%esp
f01007fd:	85 f6                	test   %esi,%esi
f01007ff:	0f 84 97 00 00 00    	je     f010089c <mon_backtrace+0xb7>
f0100805:	89 f3                	mov    %esi,%ebx
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f0100807:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010080a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
		eip = EBP_OFFSET(ebp, 1);
f010080d:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
f0100810:	ff 73 18             	pushl  0x18(%ebx)
f0100813:	ff 73 14             	pushl  0x14(%ebx)
f0100816:	ff 73 10             	pushl  0x10(%ebx)
f0100819:	ff 73 0c             	pushl  0xc(%ebx)
f010081c:	ff 73 08             	pushl  0x8(%ebx)
f010081f:	53                   	push   %ebx
f0100820:	56                   	push   %esi
f0100821:	68 18 5c 10 f0       	push   $0xf0105c18
f0100826:	e8 74 31 00 00       	call   f010399f <cprintf>
		eip, ebp, EBP_OFFSET(ebp, 2), EBP_OFFSET(ebp, 3), EBP_OFFSET(ebp, 4),
		EBP_OFFSET(ebp, 5), EBP_OFFSET(ebp, 6));
		// debug info
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) {
f010082b:	83 c4 18             	add    $0x18,%esp
f010082e:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100831:	56                   	push   %esi
f0100832:	e8 a4 3c 00 00       	call   f01044db <debuginfo_eip>
f0100837:	83 c4 10             	add    $0x10,%esp
f010083a:	85 c0                	test   %eax,%eax
f010083c:	75 54                	jne    f0100892 <mon_backtrace+0xad>
f010083e:	89 65 c0             	mov    %esp,-0x40(%ebp)
			char func_name[info.eip_fn_namelen + 1];
f0100841:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100844:	8d 41 10             	lea    0x10(%ecx),%eax
f0100847:	bf 10 00 00 00       	mov    $0x10,%edi
f010084c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100851:	f7 f7                	div    %edi
f0100853:	c1 e0 04             	shl    $0x4,%eax
f0100856:	29 c4                	sub    %eax,%esp
f0100858:	89 e0                	mov    %esp,%eax
f010085a:	89 e7                	mov    %esp,%edi
			func_name[info.eip_fn_namelen] = '\0';
f010085c:	c6 04 0c 00          	movb   $0x0,(%esp,%ecx,1)
			if (strncpy(func_name, info.eip_fn_name, info.eip_fn_namelen)) {
f0100860:	83 ec 04             	sub    $0x4,%esp
f0100863:	51                   	push   %ecx
f0100864:	ff 75 d8             	pushl  -0x28(%ebp)
f0100867:	50                   	push   %eax
f0100868:	e8 97 48 00 00       	call   f0105104 <strncpy>
f010086d:	83 c4 10             	add    $0x10,%esp
f0100870:	85 c0                	test   %eax,%eax
f0100872:	74 1b                	je     f010088f <mon_backtrace+0xaa>
				cprintf("\t%s:%d: %s+%x\n\n", info.eip_file, info.eip_line,
f0100874:	83 ec 0c             	sub    $0xc,%esp
f0100877:	2b 75 e0             	sub    -0x20(%ebp),%esi
f010087a:	56                   	push   %esi
f010087b:	57                   	push   %edi
f010087c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010087f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100882:	68 4c 5a 10 f0       	push   $0xf0105a4c
f0100887:	e8 13 31 00 00       	call   f010399f <cprintf>
f010088c:	83 c4 20             	add    $0x20,%esp
f010088f:	8b 65 c0             	mov    -0x40(%ebp),%esp
				func_name, eip - info.eip_fn_addr);
			}
		}
		// warning: the value of ebp to print is register value, not stack value
		ebp = EBP_OFFSET(ebp, 0);
f0100892:	8b 1b                	mov    (%ebx),%ebx
{
	// Your code here.
	uint32_t ebp = read_ebp(), eip;

	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
f0100894:	85 db                	test   %ebx,%ebx
f0100896:	0f 85 71 ff ff ff    	jne    f010080d <mon_backtrace+0x28>
		}
		// warning: the value of ebp to print is register value, not stack value
		ebp = EBP_OFFSET(ebp, 0);
	}

	cprintf("Backtrace success\n");
f010089c:	83 ec 0c             	sub    $0xc,%esp
f010089f:	68 5c 5a 10 f0       	push   $0xf0105a5c
f01008a4:	e8 f6 30 00 00       	call   f010399f <cprintf>
	return 0;
}
f01008a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008b1:	5b                   	pop    %ebx
f01008b2:	5e                   	pop    %esi
f01008b3:	5f                   	pop    %edi
f01008b4:	5d                   	pop    %ebp
f01008b5:	c3                   	ret    

f01008b6 <mon_time>:
	return (((uint64_t)high << 32) | low);
}

int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f01008b6:	55                   	push   %ebp
f01008b7:	89 e5                	mov    %esp,%ebp
f01008b9:	57                   	push   %edi
f01008ba:	56                   	push   %esi
f01008bb:	53                   	push   %ebx
f01008bc:	83 ec 1c             	sub    $0x1c,%esp
f01008bf:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f01008c2:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f01008c6:	74 0c                	je     f01008d4 <mon_time+0x1e>
f01008c8:	bf 20 5d 10 f0       	mov    $0xf0105d20,%edi
f01008cd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01008d2:	eb 1d                	jmp    f01008f1 <mon_time+0x3b>
		cprintf("Usage: time [command]\n");
f01008d4:	83 ec 0c             	sub    $0xc,%esp
f01008d7:	68 6f 5a 10 f0       	push   $0xf0105a6f
f01008dc:	e8 be 30 00 00       	call   f010399f <cprintf>
		return 0;
f01008e1:	83 c4 10             	add    $0x10,%esp
f01008e4:	eb 7a                	jmp    f0100960 <mon_time+0xaa>
	}

	int i;
	for (i = 0; i < NCOMMANDS && strcmp(argv[1], commands[i].name); i++)
f01008e6:	83 c3 01             	add    $0x1,%ebx
f01008e9:	83 c7 0c             	add    $0xc,%edi
f01008ec:	83 fb 07             	cmp    $0x7,%ebx
f01008ef:	74 19                	je     f010090a <mon_time+0x54>
f01008f1:	83 ec 08             	sub    $0x8,%esp
f01008f4:	ff 37                	pushl  (%edi)
f01008f6:	ff 76 04             	pushl  0x4(%esi)
f01008f9:	e8 84 48 00 00       	call   f0105182 <strcmp>
f01008fe:	83 c4 10             	add    $0x10,%esp
f0100901:	85 c0                	test   %eax,%eax
f0100903:	75 e1                	jne    f01008e6 <mon_time+0x30>
		;

	if (i == NCOMMANDS) {
f0100905:	83 fb 07             	cmp    $0x7,%ebx
f0100908:	75 15                	jne    f010091f <mon_time+0x69>
		cprintf("Unknown command: %s\n", argv[1]);
f010090a:	83 ec 08             	sub    $0x8,%esp
f010090d:	ff 76 04             	pushl  0x4(%esi)
f0100910:	68 86 5a 10 f0       	push   $0xf0105a86
f0100915:	e8 85 30 00 00       	call   f010399f <cprintf>
		return 0;
f010091a:	83 c4 10             	add    $0x10,%esp
f010091d:	eb 41                	jmp    f0100960 <mon_time+0xaa>

uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f010091f:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
f0100921:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100924:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		cprintf("Unknown command: %s\n", argv[1]);
		return 0;
	}

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
f0100927:	83 ec 04             	sub    $0x4,%esp
f010092a:	8d 14 5b             	lea    (%ebx,%ebx,2),%edx
f010092d:	ff 75 10             	pushl  0x10(%ebp)
f0100930:	8d 46 04             	lea    0x4(%esi),%eax
f0100933:	50                   	push   %eax
f0100934:	8b 45 08             	mov    0x8(%ebp),%eax
f0100937:	83 e8 01             	sub    $0x1,%eax
f010093a:	50                   	push   %eax
f010093b:	ff 14 95 28 5d 10 f0 	call   *-0xfefa2d8(,%edx,4)

uint64_t
rdtsc()
{
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f0100942:	0f 31                	rdtsc  

	uint64_t start = rdtsc();
	commands[i].func(argc - 1, argv + 1, tf);
	uint64_t end = rdtsc();

	cprintf("%s cycles: %llu\n", argv[1], end - start);
f0100944:	89 c1                	mov    %eax,%ecx
f0100946:	89 d3                	mov    %edx,%ebx
f0100948:	2b 4d e0             	sub    -0x20(%ebp),%ecx
f010094b:	1b 5d e4             	sbb    -0x1c(%ebp),%ebx
f010094e:	53                   	push   %ebx
f010094f:	51                   	push   %ecx
f0100950:	ff 76 04             	pushl  0x4(%esi)
f0100953:	68 9b 5a 10 f0       	push   $0xf0105a9b
f0100958:	e8 42 30 00 00       	call   f010399f <cprintf>

	return 0;
f010095d:	83 c4 20             	add    $0x20,%esp
}
f0100960:	b8 00 00 00 00       	mov    $0x0,%eax
f0100965:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100968:	5b                   	pop    %ebx
f0100969:	5e                   	pop    %esi
f010096a:	5f                   	pop    %edi
f010096b:	5d                   	pop    %ebp
f010096c:	c3                   	ret    

f010096d <rdtsc>:
	return 0;
}

uint64_t
rdtsc()
{
f010096d:	55                   	push   %ebp
f010096e:	89 e5                	mov    %esp,%ebp
	uint32_t low, high;
	__asm __volatile("rdtsc" : "=a"(low), "=d"(high));
f0100970:	0f 31                	rdtsc  
	return (((uint64_t)high << 32) | low);
}
f0100972:	5d                   	pop    %ebp
f0100973:	c3                   	ret    

f0100974 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100974:	55                   	push   %ebp
f0100975:	89 e5                	mov    %esp,%ebp
f0100977:	57                   	push   %edi
f0100978:	56                   	push   %esi
f0100979:	53                   	push   %ebx
f010097a:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010097d:	68 50 5c 10 f0       	push   $0xf0105c50
f0100982:	e8 18 30 00 00       	call   f010399f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100987:	c7 04 24 74 5c 10 f0 	movl   $0xf0105c74,(%esp)
f010098e:	e8 0c 30 00 00       	call   f010399f <cprintf>

	if (tf != NULL)
f0100993:	83 c4 10             	add    $0x10,%esp
f0100996:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010099a:	74 0e                	je     f01009aa <monitor+0x36>
		print_trapframe(tf);
f010099c:	83 ec 0c             	sub    $0xc,%esp
f010099f:	ff 75 08             	pushl  0x8(%ebp)
f01009a2:	e8 30 34 00 00       	call   f0103dd7 <print_trapframe>
f01009a7:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009aa:	83 ec 0c             	sub    $0xc,%esp
f01009ad:	68 ac 5a 10 f0       	push   $0xf0105aac
f01009b2:	e8 d7 45 00 00       	call   f0104f8e <readline>
f01009b7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009b9:	83 c4 10             	add    $0x10,%esp
f01009bc:	85 c0                	test   %eax,%eax
f01009be:	74 ea                	je     f01009aa <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009c0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009c7:	be 00 00 00 00       	mov    $0x0,%esi
f01009cc:	eb 0a                	jmp    f01009d8 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009ce:	c6 03 00             	movb   $0x0,(%ebx)
f01009d1:	89 f7                	mov    %esi,%edi
f01009d3:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009d6:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009d8:	0f b6 03             	movzbl (%ebx),%eax
f01009db:	84 c0                	test   %al,%al
f01009dd:	74 6a                	je     f0100a49 <monitor+0xd5>
f01009df:	83 ec 08             	sub    $0x8,%esp
f01009e2:	0f be c0             	movsbl %al,%eax
f01009e5:	50                   	push   %eax
f01009e6:	68 b0 5a 10 f0       	push   $0xf0105ab0
f01009eb:	e8 16 48 00 00       	call   f0105206 <strchr>
f01009f0:	83 c4 10             	add    $0x10,%esp
f01009f3:	85 c0                	test   %eax,%eax
f01009f5:	75 d7                	jne    f01009ce <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009f7:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009fa:	74 4d                	je     f0100a49 <monitor+0xd5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009fc:	83 fe 0f             	cmp    $0xf,%esi
f01009ff:	75 14                	jne    f0100a15 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a01:	83 ec 08             	sub    $0x8,%esp
f0100a04:	6a 10                	push   $0x10
f0100a06:	68 b5 5a 10 f0       	push   $0xf0105ab5
f0100a0b:	e8 8f 2f 00 00       	call   f010399f <cprintf>
f0100a10:	83 c4 10             	add    $0x10,%esp
f0100a13:	eb 95                	jmp    f01009aa <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a15:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a18:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a1c:	0f b6 03             	movzbl (%ebx),%eax
f0100a1f:	84 c0                	test   %al,%al
f0100a21:	75 0c                	jne    f0100a2f <monitor+0xbb>
f0100a23:	eb b1                	jmp    f01009d6 <monitor+0x62>
			buf++;
f0100a25:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a28:	0f b6 03             	movzbl (%ebx),%eax
f0100a2b:	84 c0                	test   %al,%al
f0100a2d:	74 a7                	je     f01009d6 <monitor+0x62>
f0100a2f:	83 ec 08             	sub    $0x8,%esp
f0100a32:	0f be c0             	movsbl %al,%eax
f0100a35:	50                   	push   %eax
f0100a36:	68 b0 5a 10 f0       	push   $0xf0105ab0
f0100a3b:	e8 c6 47 00 00       	call   f0105206 <strchr>
f0100a40:	83 c4 10             	add    $0x10,%esp
f0100a43:	85 c0                	test   %eax,%eax
f0100a45:	74 de                	je     f0100a25 <monitor+0xb1>
f0100a47:	eb 8d                	jmp    f01009d6 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a49:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a50:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a51:	85 f6                	test   %esi,%esi
f0100a53:	0f 84 51 ff ff ff    	je     f01009aa <monitor+0x36>
f0100a59:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a5e:	83 ec 08             	sub    $0x8,%esp
f0100a61:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a64:	ff 34 85 20 5d 10 f0 	pushl  -0xfefa2e0(,%eax,4)
f0100a6b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6e:	e8 0f 47 00 00       	call   f0105182 <strcmp>
f0100a73:	83 c4 10             	add    $0x10,%esp
f0100a76:	85 c0                	test   %eax,%eax
f0100a78:	75 21                	jne    f0100a9b <monitor+0x127>
			return commands[i].func(argc, argv, tf);
f0100a7a:	83 ec 04             	sub    $0x4,%esp
f0100a7d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a80:	ff 75 08             	pushl  0x8(%ebp)
f0100a83:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a86:	52                   	push   %edx
f0100a87:	56                   	push   %esi
f0100a88:	ff 14 85 28 5d 10 f0 	call   *-0xfefa2d8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a8f:	83 c4 10             	add    $0x10,%esp
f0100a92:	85 c0                	test   %eax,%eax
f0100a94:	78 25                	js     f0100abb <monitor+0x147>
f0100a96:	e9 0f ff ff ff       	jmp    f01009aa <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a9b:	83 c3 01             	add    $0x1,%ebx
f0100a9e:	83 fb 07             	cmp    $0x7,%ebx
f0100aa1:	75 bb                	jne    f0100a5e <monitor+0xea>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aa3:	83 ec 08             	sub    $0x8,%esp
f0100aa6:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aa9:	68 d2 5a 10 f0       	push   $0xf0105ad2
f0100aae:	e8 ec 2e 00 00       	call   f010399f <cprintf>
f0100ab3:	83 c4 10             	add    $0x10,%esp
f0100ab6:	e9 ef fe ff ff       	jmp    f01009aa <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100abe:	5b                   	pop    %ebx
f0100abf:	5e                   	pop    %esi
f0100ac0:	5f                   	pop    %edi
f0100ac1:	5d                   	pop    %ebp
f0100ac2:	c3                   	ret    

f0100ac3 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100ac3:	55                   	push   %ebp
f0100ac4:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100ac6:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100ac9:	5d                   	pop    %ebp
f0100aca:	c3                   	ret    

f0100acb <check_continuous>:
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100acb:	8d 4a ff             	lea    -0x1(%edx),%ecx
f0100ace:	85 c9                	test   %ecx,%ecx
f0100ad0:	7e 63                	jle    f0100b35 <check_continuous+0x6a>
	{
		if(tmp == NULL)
f0100ad2:	85 c0                	test   %eax,%eax
f0100ad4:	74 65                	je     f0100b3b <check_continuous+0x70>
	cprintf("check_page() succeeded!\n");
}

static int
check_continuous(struct Page *pp, int num_page)
{
f0100ad6:	55                   	push   %ebp
f0100ad7:	89 e5                	mov    %esp,%ebp
f0100ad9:	57                   	push   %edi
f0100ada:	56                   	push   %esi
f0100adb:	53                   	push   %ebx
	{
		if(tmp == NULL)
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100adc:	8b 08                	mov    (%eax),%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ade:	8b 35 ac ee 19 f0    	mov    0xf019eeac,%esi
f0100ae4:	89 cb                	mov    %ecx,%ebx
f0100ae6:	29 f3                	sub    %esi,%ebx
f0100ae8:	c1 fb 03             	sar    $0x3,%ebx
f0100aeb:	29 f0                	sub    %esi,%eax
f0100aed:	c1 f8 03             	sar    $0x3,%eax
f0100af0:	29 c3                	sub    %eax,%ebx
f0100af2:	c1 e3 0c             	shl    $0xc,%ebx
f0100af5:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
f0100afb:	75 44                	jne    f0100b41 <check_continuous+0x76>
f0100afd:	8d 7a ff             	lea    -0x1(%edx),%edi
f0100b00:	ba 00 00 00 00       	mov    $0x0,%edx
f0100b05:	eb 20                	jmp    f0100b27 <check_continuous+0x5c>
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
f0100b07:	85 c9                	test   %ecx,%ecx
f0100b09:	74 3d                	je     f0100b48 <check_continuous+0x7d>
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100b0b:	8b 19                	mov    (%ecx),%ebx
f0100b0d:	89 d8                	mov    %ebx,%eax
f0100b0f:	29 f0                	sub    %esi,%eax
f0100b11:	c1 f8 03             	sar    $0x3,%eax
f0100b14:	29 f1                	sub    %esi,%ecx
f0100b16:	c1 f9 03             	sar    $0x3,%ecx
f0100b19:	29 c8                	sub    %ecx,%eax
f0100b1b:	c1 e0 0c             	shl    $0xc,%eax
f0100b1e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0100b23:	75 2a                	jne    f0100b4f <check_continuous+0x84>
f0100b25:	89 d9                	mov    %ebx,%ecx
static int
check_continuous(struct Page *pp, int num_page)
{
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
f0100b27:	83 c2 01             	add    $0x1,%edx
f0100b2a:	39 fa                	cmp    %edi,%edx
f0100b2c:	75 d9                	jne    f0100b07 <check_continuous+0x3c>
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
		}
	}
	return 1;
f0100b2e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100b33:	eb 1f                	jmp    f0100b54 <check_continuous+0x89>
f0100b35:	b8 01 00 00 00       	mov    $0x1,%eax
f0100b3a:	c3                   	ret    
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
		{
			return 0;
f0100b3b:	b8 00 00 00 00       	mov    $0x0,%eax
		{
			return 0;
		}
	}
	return 1;
}
f0100b40:	c3                   	ret    
		{
			return 0;
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
f0100b41:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b46:	eb 0c                	jmp    f0100b54 <check_continuous+0x89>
	int i;
	for( tmp = pp, i = 0; i < num_page - 1; tmp = tmp->pp_link, i++ )
	{
		if(tmp == NULL)
		{
			return 0;
f0100b48:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b4d:	eb 05                	jmp    f0100b54 <check_continuous+0x89>
		}
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
		{
			return 0;
f0100b4f:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	return 1;
}
f0100b54:	5b                   	pop    %ebx
f0100b55:	5e                   	pop    %esi
f0100b56:	5f                   	pop    %edi
f0100b57:	5d                   	pop    %ebp
f0100b58:	c3                   	ret    

f0100b59 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b59:	89 d1                	mov    %edx,%ecx
f0100b5b:	c1 e9 16             	shr    $0x16,%ecx
f0100b5e:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b61:	a8 01                	test   $0x1,%al
f0100b63:	74 52                	je     f0100bb7 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b6a:	89 c1                	mov    %eax,%ecx
f0100b6c:	c1 e9 0c             	shr    $0xc,%ecx
f0100b6f:	3b 0d a4 ee 19 f0    	cmp    0xf019eea4,%ecx
f0100b75:	72 1b                	jb     f0100b92 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b77:	55                   	push   %ebp
f0100b78:	89 e5                	mov    %esp,%ebp
f0100b7a:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b7d:	50                   	push   %eax
f0100b7e:	68 74 5d 10 f0       	push   $0xf0105d74
f0100b83:	68 dc 03 00 00       	push   $0x3dc
f0100b88:	68 0d 65 10 f0       	push   $0xf010650d
f0100b8d:	e8 13 f5 ff ff       	call   f01000a5 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b92:	c1 ea 0c             	shr    $0xc,%edx
f0100b95:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b9b:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ba2:	89 c2                	mov    %eax,%edx
f0100ba4:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ba7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bac:	85 d2                	test   %edx,%edx
f0100bae:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bb3:	0f 44 c2             	cmove  %edx,%eax
f0100bb6:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bbc:	c3                   	ret    

f0100bbd <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100bbd:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100bbf:	83 3d d8 e1 19 f0 00 	cmpl   $0x0,0xf019e1d8
f0100bc6:	75 0f                	jne    f0100bd7 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100bc8:	b8 af fe 19 f0       	mov    $0xf019feaf,%eax
f0100bcd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bd2:	a3 d8 e1 19 f0       	mov    %eax,0xf019e1d8
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100bd7:	a1 d8 e1 19 f0       	mov    0xf019e1d8,%eax
	if (n > 0) {
f0100bdc:	85 d2                	test   %edx,%edx
f0100bde:	74 64                	je     f0100c44 <boot_alloc+0x87>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100be0:	55                   	push   %ebp
f0100be1:	89 e5                	mov    %esp,%ebp
f0100be3:	53                   	push   %ebx
f0100be4:	83 ec 04             	sub    $0x4,%esp
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
	if (n > 0) {
		nextfree += n;
f0100be7:	01 c2                	add    %eax,%edx
f0100be9:	89 15 d8 e1 19 f0    	mov    %edx,0xf019e1d8
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100bef:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100bf5:	77 12                	ja     f0100c09 <boot_alloc+0x4c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100bf7:	52                   	push   %edx
f0100bf8:	68 98 5d 10 f0       	push   $0xf0105d98
f0100bfd:	6a 6e                	push   $0x6e
f0100bff:	68 0d 65 10 f0       	push   $0xf010650d
f0100c04:	e8 9c f4 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100c09:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c0f:	89 cb                	mov    %ecx,%ebx
f0100c11:	c1 eb 0c             	shr    $0xc,%ebx
f0100c14:	39 1d a4 ee 19 f0    	cmp    %ebx,0xf019eea4
f0100c1a:	77 12                	ja     f0100c2e <boot_alloc+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c1c:	51                   	push   %ecx
f0100c1d:	68 74 5d 10 f0       	push   $0xf0105d74
f0100c22:	6a 6e                	push   $0x6e
f0100c24:	68 0d 65 10 f0       	push   $0xf010650d
f0100c29:	e8 77 f4 ff ff       	call   f01000a5 <_panic>
		nextfree = ROUNDUP(KADDR(PADDR(nextfree)), PGSIZE);
f0100c2e:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100c34:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c3a:	89 15 d8 e1 19 f0    	mov    %edx,0xf019e1d8
	}

	return result;
}
f0100c40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c43:	c9                   	leave  
f0100c44:	f3 c3                	repz ret 

f0100c46 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100c46:	55                   	push   %ebp
f0100c47:	89 e5                	mov    %esp,%ebp
f0100c49:	57                   	push   %edi
f0100c4a:	56                   	push   %esi
f0100c4b:	53                   	push   %ebx
f0100c4c:	83 ec 2c             	sub    $0x2c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c4f:	85 c0                	test   %eax,%eax
f0100c51:	0f 85 b1 02 00 00    	jne    f0100f08 <check_page_free_list+0x2c2>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c57:	8b 1d e4 e1 19 f0    	mov    0xf019e1e4,%ebx
f0100c5d:	85 db                	test   %ebx,%ebx
f0100c5f:	75 6c                	jne    f0100ccd <check_page_free_list+0x87>
		panic("'page_free_list' is a null pointer!");
f0100c61:	83 ec 04             	sub    $0x4,%esp
f0100c64:	68 bc 5d 10 f0       	push   $0xf0105dbc
f0100c69:	68 19 03 00 00       	push   $0x319
f0100c6e:	68 0d 65 10 f0       	push   $0xf010650d
f0100c73:	e8 2d f4 ff ff       	call   f01000a5 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100c78:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c7b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c7e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c81:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c84:	89 c2                	mov    %eax,%edx
f0100c86:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f0100c8c:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c92:	0f 95 c2             	setne  %dl
f0100c95:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c98:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c9c:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c9e:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca2:	8b 00                	mov    (%eax),%eax
f0100ca4:	85 c0                	test   %eax,%eax
f0100ca6:	75 dc                	jne    f0100c84 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ca8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cb7:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cb9:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100cbc:	89 1d e4 e1 19 f0    	mov    %ebx,0xf019e1e4
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100cc2:	85 db                	test   %ebx,%ebx
f0100cc4:	74 63                	je     f0100d29 <check_page_free_list+0xe3>
f0100cc6:	be 01 00 00 00       	mov    $0x1,%esi
f0100ccb:	eb 05                	jmp    f0100cd2 <check_page_free_list+0x8c>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ccd:	be 00 04 00 00       	mov    $0x400,%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cd2:	89 d8                	mov    %ebx,%eax
f0100cd4:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0100cda:	c1 f8 03             	sar    $0x3,%eax
f0100cdd:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ce0:	89 c2                	mov    %eax,%edx
f0100ce2:	c1 ea 16             	shr    $0x16,%edx
f0100ce5:	39 d6                	cmp    %edx,%esi
f0100ce7:	76 3a                	jbe    f0100d23 <check_page_free_list+0xdd>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ce9:	89 c2                	mov    %eax,%edx
f0100ceb:	c1 ea 0c             	shr    $0xc,%edx
f0100cee:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0100cf4:	72 12                	jb     f0100d08 <check_page_free_list+0xc2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cf6:	50                   	push   %eax
f0100cf7:	68 74 5d 10 f0       	push   $0xf0105d74
f0100cfc:	6a 56                	push   $0x56
f0100cfe:	68 19 65 10 f0       	push   $0xf0106519
f0100d03:	e8 9d f3 ff ff       	call   f01000a5 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d08:	83 ec 04             	sub    $0x4,%esp
f0100d0b:	68 80 00 00 00       	push   $0x80
f0100d10:	68 97 00 00 00       	push   $0x97
f0100d15:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d1a:	50                   	push   %eax
f0100d1b:	e8 44 45 00 00       	call   f0105264 <memset>
f0100d20:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100d23:	8b 1b                	mov    (%ebx),%ebx
f0100d25:	85 db                	test   %ebx,%ebx
f0100d27:	75 a9                	jne    f0100cd2 <check_page_free_list+0x8c>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0100d29:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d2e:	e8 8a fe ff ff       	call   f0100bbd <boot_alloc>
f0100d33:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d36:	8b 15 e4 e1 19 f0    	mov    0xf019e1e4,%edx
f0100d3c:	85 d2                	test   %edx,%edx
f0100d3e:	0f 84 8e 01 00 00    	je     f0100ed2 <check_page_free_list+0x28c>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d44:	8b 0d ac ee 19 f0    	mov    0xf019eeac,%ecx
f0100d4a:	39 ca                	cmp    %ecx,%edx
f0100d4c:	72 49                	jb     f0100d97 <check_page_free_list+0x151>
		assert(pp < pages + npages);
f0100d4e:	a1 a4 ee 19 f0       	mov    0xf019eea4,%eax
f0100d53:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100d56:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
f0100d59:	39 fa                	cmp    %edi,%edx
f0100d5b:	73 57                	jae    f0100db4 <check_page_free_list+0x16e>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d5d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100d60:	89 d0                	mov    %edx,%eax
f0100d62:	29 c8                	sub    %ecx,%eax
f0100d64:	a8 07                	test   $0x7,%al
f0100d66:	75 6e                	jne    f0100dd6 <check_page_free_list+0x190>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d68:	c1 f8 03             	sar    $0x3,%eax
f0100d6b:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d6e:	85 c0                	test   %eax,%eax
f0100d70:	0f 84 83 00 00 00    	je     f0100df9 <check_page_free_list+0x1b3>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d76:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d7b:	0f 84 98 00 00 00    	je     f0100e19 <check_page_free_list+0x1d3>
f0100d81:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d86:	be 00 00 00 00       	mov    $0x0,%esi
f0100d8b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100d8e:	e9 9f 00 00 00       	jmp    f0100e32 <check_page_free_list+0x1ec>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d93:	39 ca                	cmp    %ecx,%edx
f0100d95:	73 19                	jae    f0100db0 <check_page_free_list+0x16a>
f0100d97:	68 27 65 10 f0       	push   $0xf0106527
f0100d9c:	68 33 65 10 f0       	push   $0xf0106533
f0100da1:	68 34 03 00 00       	push   $0x334
f0100da6:	68 0d 65 10 f0       	push   $0xf010650d
f0100dab:	e8 f5 f2 ff ff       	call   f01000a5 <_panic>
		assert(pp < pages + npages);
f0100db0:	39 fa                	cmp    %edi,%edx
f0100db2:	72 19                	jb     f0100dcd <check_page_free_list+0x187>
f0100db4:	68 48 65 10 f0       	push   $0xf0106548
f0100db9:	68 33 65 10 f0       	push   $0xf0106533
f0100dbe:	68 35 03 00 00       	push   $0x335
f0100dc3:	68 0d 65 10 f0       	push   $0xf010650d
f0100dc8:	e8 d8 f2 ff ff       	call   f01000a5 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dcd:	89 d0                	mov    %edx,%eax
f0100dcf:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100dd2:	a8 07                	test   $0x7,%al
f0100dd4:	74 19                	je     f0100def <check_page_free_list+0x1a9>
f0100dd6:	68 e0 5d 10 f0       	push   $0xf0105de0
f0100ddb:	68 33 65 10 f0       	push   $0xf0106533
f0100de0:	68 36 03 00 00       	push   $0x336
f0100de5:	68 0d 65 10 f0       	push   $0xf010650d
f0100dea:	e8 b6 f2 ff ff       	call   f01000a5 <_panic>
f0100def:	c1 f8 03             	sar    $0x3,%eax
f0100df2:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100df5:	85 c0                	test   %eax,%eax
f0100df7:	75 19                	jne    f0100e12 <check_page_free_list+0x1cc>
f0100df9:	68 5c 65 10 f0       	push   $0xf010655c
f0100dfe:	68 33 65 10 f0       	push   $0xf0106533
f0100e03:	68 39 03 00 00       	push   $0x339
f0100e08:	68 0d 65 10 f0       	push   $0xf010650d
f0100e0d:	e8 93 f2 ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e12:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e17:	75 19                	jne    f0100e32 <check_page_free_list+0x1ec>
f0100e19:	68 6d 65 10 f0       	push   $0xf010656d
f0100e1e:	68 33 65 10 f0       	push   $0xf0106533
f0100e23:	68 3a 03 00 00       	push   $0x33a
f0100e28:	68 0d 65 10 f0       	push   $0xf010650d
f0100e2d:	e8 73 f2 ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e32:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e37:	75 19                	jne    f0100e52 <check_page_free_list+0x20c>
f0100e39:	68 14 5e 10 f0       	push   $0xf0105e14
f0100e3e:	68 33 65 10 f0       	push   $0xf0106533
f0100e43:	68 3b 03 00 00       	push   $0x33b
f0100e48:	68 0d 65 10 f0       	push   $0xf010650d
f0100e4d:	e8 53 f2 ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e52:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e57:	75 19                	jne    f0100e72 <check_page_free_list+0x22c>
f0100e59:	68 86 65 10 f0       	push   $0xf0106586
f0100e5e:	68 33 65 10 f0       	push   $0xf0106533
f0100e63:	68 3c 03 00 00       	push   $0x33c
f0100e68:	68 0d 65 10 f0       	push   $0xf010650d
f0100e6d:	e8 33 f2 ff ff       	call   f01000a5 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e72:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e77:	76 3f                	jbe    f0100eb8 <check_page_free_list+0x272>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e79:	89 c3                	mov    %eax,%ebx
f0100e7b:	c1 eb 0c             	shr    $0xc,%ebx
f0100e7e:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100e81:	77 12                	ja     f0100e95 <check_page_free_list+0x24f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e83:	50                   	push   %eax
f0100e84:	68 74 5d 10 f0       	push   $0xf0105d74
f0100e89:	6a 56                	push   $0x56
f0100e8b:	68 19 65 10 f0       	push   $0xf0106519
f0100e90:	e8 10 f2 ff ff       	call   f01000a5 <_panic>
f0100e95:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e9a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100e9d:	76 1e                	jbe    f0100ebd <check_page_free_list+0x277>
f0100e9f:	68 38 5e 10 f0       	push   $0xf0105e38
f0100ea4:	68 33 65 10 f0       	push   $0xf0106533
f0100ea9:	68 3d 03 00 00       	push   $0x33d
f0100eae:	68 0d 65 10 f0       	push   $0xf010650d
f0100eb3:	e8 ed f1 ff ff       	call   f01000a5 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100eb8:	83 c6 01             	add    $0x1,%esi
f0100ebb:	eb 04                	jmp    f0100ec1 <check_page_free_list+0x27b>
		else
			++nfree_extmem;
f0100ebd:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ec1:	8b 12                	mov    (%edx),%edx
f0100ec3:	85 d2                	test   %edx,%edx
f0100ec5:	0f 85 c8 fe ff ff    	jne    f0100d93 <check_page_free_list+0x14d>
f0100ecb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ece:	85 f6                	test   %esi,%esi
f0100ed0:	7f 19                	jg     f0100eeb <check_page_free_list+0x2a5>
f0100ed2:	68 a0 65 10 f0       	push   $0xf01065a0
f0100ed7:	68 33 65 10 f0       	push   $0xf0106533
f0100edc:	68 45 03 00 00       	push   $0x345
f0100ee1:	68 0d 65 10 f0       	push   $0xf010650d
f0100ee6:	e8 ba f1 ff ff       	call   f01000a5 <_panic>
	assert(nfree_extmem > 0);
f0100eeb:	85 db                	test   %ebx,%ebx
f0100eed:	7f 2b                	jg     f0100f1a <check_page_free_list+0x2d4>
f0100eef:	68 b2 65 10 f0       	push   $0xf01065b2
f0100ef4:	68 33 65 10 f0       	push   $0xf0106533
f0100ef9:	68 46 03 00 00       	push   $0x346
f0100efe:	68 0d 65 10 f0       	push   $0xf010650d
f0100f03:	e8 9d f1 ff ff       	call   f01000a5 <_panic>
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f08:	a1 e4 e1 19 f0       	mov    0xf019e1e4,%eax
f0100f0d:	85 c0                	test   %eax,%eax
f0100f0f:	0f 85 63 fd ff ff    	jne    f0100c78 <check_page_free_list+0x32>
f0100f15:	e9 47 fd ff ff       	jmp    f0100c61 <check_page_free_list+0x1b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f1d:	5b                   	pop    %ebx
f0100f1e:	5e                   	pop    %esi
f0100f1f:	5f                   	pop    %edi
f0100f20:	5d                   	pop    %ebp
f0100f21:	c3                   	ret    

f0100f22 <page_init>:
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
f0100f22:	c7 05 e4 e1 19 f0 00 	movl   $0x0,0xf019e1e4
f0100f29:	00 00 00 
	for (i = 0; i < npages; i++) {
f0100f2c:	83 3d a4 ee 19 f0 00 	cmpl   $0x0,0xf019eea4
f0100f33:	0f 85 8d 00 00 00    	jne    f0100fc6 <page_init+0xa4>
			continue;
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f0100f39:	c7 05 e0 e1 19 f0 00 	movl   $0x0,0xf019e1e0
f0100f40:	00 00 00 
f0100f43:	c3                   	ret    
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100f44:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100f4b:	a1 ac ee 19 f0       	mov    0xf019eeac,%eax
f0100f50:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
		if (i == 0 || (i >= PGNUM(IOPHYSMEM) && i < PGNUM(PADDR(boot_alloc(0))))) {
f0100f57:	85 db                	test   %ebx,%ebx
f0100f59:	74 54                	je     f0100faf <page_init+0x8d>
f0100f5b:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100f61:	76 32                	jbe    f0100f95 <page_init+0x73>
f0100f63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f68:	e8 50 fc ff ff       	call   f0100bbd <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f6d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f72:	77 15                	ja     f0100f89 <page_init+0x67>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f74:	50                   	push   %eax
f0100f75:	68 98 5d 10 f0       	push   $0xf0105d98
f0100f7a:	68 1c 01 00 00       	push   $0x11c
f0100f7f:	68 0d 65 10 f0       	push   $0xf010650d
f0100f84:	e8 1c f1 ff ff       	call   f01000a5 <_panic>
f0100f89:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f8e:	c1 e8 0c             	shr    $0xc,%eax
f0100f91:	39 d8                	cmp    %ebx,%eax
f0100f93:	77 1a                	ja     f0100faf <page_init+0x8d>
			continue;
		}
		pages[i].pp_link = page_free_list;
f0100f95:	8b 15 e4 e1 19 f0    	mov    0xf019e1e4,%edx
f0100f9b:	a1 ac ee 19 f0       	mov    0xf019eeac,%eax
f0100fa0:	89 14 30             	mov    %edx,(%eax,%esi,1)
		page_free_list = &pages[i];
f0100fa3:	03 35 ac ee 19 f0    	add    0xf019eeac,%esi
f0100fa9:	89 35 e4 e1 19 f0    	mov    %esi,0xf019e1e4
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
f0100faf:	83 c3 01             	add    $0x1,%ebx
f0100fb2:	39 1d a4 ee 19 f0    	cmp    %ebx,0xf019eea4
f0100fb8:	77 8a                	ja     f0100f44 <page_init+0x22>
			continue;
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
f0100fba:	c7 05 e0 e1 19 f0 00 	movl   $0x0,0xf019e1e0
f0100fc1:	00 00 00 
}
f0100fc4:	eb 17                	jmp    f0100fdd <page_init+0xbb>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100fc6:	55                   	push   %ebp
f0100fc7:	89 e5                	mov    %esp,%ebp
f0100fc9:	56                   	push   %esi
f0100fca:	53                   	push   %ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
	for (i = 0; i < npages; i++) {
		pages[i].pp_ref = 0;
f0100fcb:	a1 ac ee 19 f0       	mov    0xf019eeac,%eax
f0100fd0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
f0100fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100fdb:	eb d2                	jmp    f0100faf <page_init+0x8d>
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	chunk_list = NULL;
}
f0100fdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fe0:	5b                   	pop    %ebx
f0100fe1:	5e                   	pop    %esi
f0100fe2:	5d                   	pop    %ebp
f0100fe3:	c3                   	ret    

f0100fe4 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f0100fe4:	55                   	push   %ebp
f0100fe5:	89 e5                	mov    %esp,%ebp
f0100fe7:	53                   	push   %ebx
f0100fe8:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct Page *result = NULL;

	if (page_free_list) {
f0100feb:	8b 1d e4 e1 19 f0    	mov    0xf019e1e4,%ebx
f0100ff1:	85 db                	test   %ebx,%ebx
f0100ff3:	74 58                	je     f010104d <page_alloc+0x69>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100ff5:	8b 03                	mov    (%ebx),%eax
f0100ff7:	a3 e4 e1 19 f0       	mov    %eax,0xf019e1e4
		result->pp_link = NULL;
f0100ffc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

		if (alloc_flags & ALLOC_ZERO) {
f0101002:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101006:	74 45                	je     f010104d <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101008:	89 d8                	mov    %ebx,%eax
f010100a:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0101010:	c1 f8 03             	sar    $0x3,%eax
f0101013:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101016:	89 c2                	mov    %eax,%edx
f0101018:	c1 ea 0c             	shr    $0xc,%edx
f010101b:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0101021:	72 12                	jb     f0101035 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101023:	50                   	push   %eax
f0101024:	68 74 5d 10 f0       	push   $0xf0105d74
f0101029:	6a 56                	push   $0x56
f010102b:	68 19 65 10 f0       	push   $0xf0106519
f0101030:	e8 70 f0 ff ff       	call   f01000a5 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0101035:	83 ec 04             	sub    $0x4,%esp
f0101038:	68 00 10 00 00       	push   $0x1000
f010103d:	6a 00                	push   $0x0
f010103f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101044:	50                   	push   %eax
f0101045:	e8 1a 42 00 00       	call   f0105264 <memset>
f010104a:	83 c4 10             	add    $0x10,%esp
		}
	}

	return result;
}
f010104d:	89 d8                	mov    %ebx,%eax
f010104f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101052:	c9                   	leave  
f0101053:	c3                   	ret    

f0101054 <page_alloc_npages_helper>:

// Helper fucntion for page_alloc_npages()
struct Page *
page_alloc_npages_helper(int alloc_flags, int n, struct Page* list)
{
f0101054:	55                   	push   %ebp
f0101055:	89 e5                	mov    %esp,%ebp
f0101057:	57                   	push   %edi
f0101058:	56                   	push   %esi
f0101059:	53                   	push   %ebx
f010105a:	83 ec 1c             	sub    $0x1c,%esp
f010105d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Page* tmp = NULL;
	struct Page* result = NULL;
	struct Page* check = NULL;
	int cnt = n;

	if (list && n > 0) {
f0101060:	85 db                	test   %ebx,%ebx
f0101062:	0f 84 35 01 00 00    	je     f010119d <page_alloc_npages_helper+0x149>
f0101068:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010106c:	0f 8e 2b 01 00 00    	jle    f010119d <page_alloc_npages_helper+0x149>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101072:	a1 ac ee 19 f0       	mov    0xf019eeac,%eax
f0101077:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010107a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010107d:	89 d8                	mov    %ebx,%eax
f010107f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
			if (!check->pp_link) {
f0101086:	8b 08                	mov    (%eax),%ecx
f0101088:	85 c9                	test   %ecx,%ecx
f010108a:	75 11                	jne    f010109d <page_alloc_npages_helper+0x49>
f010108c:	8b 5d 10             	mov    0x10(%ebp),%ebx
				// Out of memory
				if (cnt > 1) {
f010108f:	83 fe 01             	cmp    $0x1,%esi
f0101092:	0f 8e 21 01 00 00    	jle    f01011b9 <page_alloc_npages_helper+0x165>
f0101098:	e9 07 01 00 00       	jmp    f01011a4 <page_alloc_npages_helper+0x150>
					return NULL;
				}
			} else if ((page2pa(check) - page2pa(check->pp_link)) != PGSIZE) {
f010109d:	89 c2                	mov    %eax,%edx
f010109f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01010a2:	29 fa                	sub    %edi,%edx
f01010a4:	c1 fa 03             	sar    $0x3,%edx
f01010a7:	89 cb                	mov    %ecx,%ebx
f01010a9:	29 fb                	sub    %edi,%ebx
f01010ab:	89 df                	mov    %ebx,%edi
f01010ad:	c1 ff 03             	sar    $0x3,%edi
f01010b0:	29 fa                	sub    %edi,%edx
f01010b2:	c1 e2 0c             	shl    $0xc,%edx
				tmp = check;	// Record junction
				result = check->pp_link;
				check = result;
				cnt = n;
f01010b5:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f01010bb:	0f 45 75 0c          	cmovne 0xc(%ebp),%esi
f01010bf:	89 cb                	mov    %ecx,%ebx
f01010c1:	0f 44 5d 10          	cmove  0x10(%ebp),%ebx
f01010c5:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01010c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010cb:	0f 45 d8             	cmovne %eax,%ebx
f01010ce:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01010d1:	0f 44 c8             	cmove  %eax,%ecx
	int cnt = n;

	if (list && n > 0) {
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
f01010d4:	8b 01                	mov    (%ecx),%eax
f01010d6:	83 ee 01             	sub    $0x1,%esi
f01010d9:	85 f6                	test   %esi,%esi
f01010db:	7e 04                	jle    f01010e1 <page_alloc_npages_helper+0x8d>
f01010dd:	85 c0                	test   %eax,%eax
f01010df:	75 a5                	jne    f0101086 <page_alloc_npages_helper+0x32>
f01010e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01010e4:	89 c1                	mov    %eax,%ecx
				check = result;
				cnt = n;
			}
		}

		if (!cnt) {
f01010e6:	85 f6                	test   %esi,%esi
f01010e8:	0f 85 bd 00 00 00    	jne    f01011ab <page_alloc_npages_helper+0x157>
			if (!tmp) {
f01010ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01010f1:	85 f6                	test   %esi,%esi
f01010f3:	74 04                	je     f01010f9 <page_alloc_npages_helper+0xa5>
				list = check->pp_link;
			} else {
				tmp->pp_link = check->pp_link;
f01010f5:	8b 01                	mov    (%ecx),%eax
f01010f7:	89 06                	mov    %eax,(%esi)
			}

			check->pp_link = NULL;
f01010f9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

			if (alloc_flags & ALLOC_ZERO) {
f01010ff:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101103:	74 27                	je     f010112c <page_alloc_npages_helper+0xd8>
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f0101105:	85 db                	test   %ebx,%ebx
f0101107:	0f 84 a5 00 00 00    	je     f01011b2 <page_alloc_npages_helper+0x15e>
f010110d:	89 d8                	mov    %ebx,%eax
f010110f:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0101115:	c1 f8 03             	sar    $0x3,%eax
f0101118:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010111b:	89 c2                	mov    %eax,%edx
f010111d:	c1 ea 0c             	shr    $0xc,%edx
f0101120:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0101126:	73 2e                	jae    f0101156 <page_alloc_npages_helper+0x102>
f0101128:	89 de                	mov    %ebx,%esi
f010112a:	eb 3c                	jmp    f0101168 <page_alloc_npages_helper+0x114>

			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
f010112c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101131:	85 db                	test   %ebx,%ebx
f0101133:	0f 84 88 00 00 00    	je     f01011c1 <page_alloc_npages_helper+0x16d>
f0101139:	eb 4b                	jmp    f0101186 <page_alloc_npages_helper+0x132>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010113b:	89 f0                	mov    %esi,%eax
f010113d:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0101143:	c1 f8 03             	sar    $0x3,%eax
f0101146:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101149:	89 c2                	mov    %eax,%edx
f010114b:	c1 ea 0c             	shr    $0xc,%edx
f010114e:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0101154:	72 12                	jb     f0101168 <page_alloc_npages_helper+0x114>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101156:	50                   	push   %eax
f0101157:	68 74 5d 10 f0       	push   $0xf0105d74
f010115c:	6a 56                	push   $0x56
f010115e:	68 19 65 10 f0       	push   $0xf0106519
f0101163:	e8 3d ef ff ff       	call   f01000a5 <_panic>

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
					memset(page2kva(tmp), 0, PGSIZE);
f0101168:	83 ec 04             	sub    $0x4,%esp
f010116b:	68 00 10 00 00       	push   $0x1000
f0101170:	6a 00                	push   $0x0
f0101172:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101177:	50                   	push   %eax
f0101178:	e8 e7 40 00 00       	call   f0105264 <memset>
			}

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f010117d:	8b 36                	mov    (%esi),%esi
f010117f:	83 c4 10             	add    $0x10,%esp
f0101182:	85 f6                	test   %esi,%esi
f0101184:	75 b5                	jne    f010113b <page_alloc_npages_helper+0xe7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101186:	ba 00 00 00 00       	mov    $0x0,%edx
f010118b:	eb 02                	jmp    f010118f <page_alloc_npages_helper+0x13b>
			tmp = result;
			while(tmp) {
				rear = tmp->pp_link;
				tmp->pp_link = head;
				head = tmp;
				tmp = rear;
f010118d:	89 c3                	mov    %eax,%ebx
			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
				rear = tmp->pp_link;
f010118f:	8b 03                	mov    (%ebx),%eax
				tmp->pp_link = head;
f0101191:	89 13                	mov    %edx,(%ebx)
f0101193:	89 da                	mov    %ebx,%edx

			// Reverse order
			struct Page* rear = NULL;
			struct Page* head = NULL;
			tmp = result;
			while(tmp) {
f0101195:	85 c0                	test   %eax,%eax
f0101197:	75 f4                	jne    f010118d <page_alloc_npages_helper+0x139>
f0101199:	89 d8                	mov    %ebx,%eax
f010119b:	eb 24                	jmp    f01011c1 <page_alloc_npages_helper+0x16d>
		} else {
			return NULL;
		}
	}

	return result;
f010119d:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a2:	eb 1d                	jmp    f01011c1 <page_alloc_npages_helper+0x16d>

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
			if (!check->pp_link) {
				// Out of memory
				if (cnt > 1) {
					return NULL;
f01011a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a9:	eb 16                	jmp    f01011c1 <page_alloc_npages_helper+0x16d>
				tmp = rear;
			}

			return head;
		} else {
			return NULL;
f01011ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01011b0:	eb 0f                	jmp    f01011c1 <page_alloc_npages_helper+0x16d>
			}

			check->pp_link = NULL;

			if (alloc_flags & ALLOC_ZERO) {
				for (tmp = result; tmp; tmp = tmp->pp_link) {
f01011b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01011b7:	eb 08                	jmp    f01011c1 <page_alloc_npages_helper+0x16d>
	int cnt = n;

	if (list && n > 0) {
		check = result = list;

		for (; cnt > 0 && check; check = check->pp_link, cnt--) {
f01011b9:	83 ee 01             	sub    $0x1,%esi
f01011bc:	e9 25 ff ff ff       	jmp    f01010e6 <page_alloc_npages_helper+0x92>
			return NULL;
		}
	}

	return result;
}
f01011c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011c4:	5b                   	pop    %ebx
f01011c5:	5e                   	pop    %esi
f01011c6:	5f                   	pop    %edi
f01011c7:	5d                   	pop    %ebp
f01011c8:	c3                   	ret    

f01011c9 <page_alloc_npages>:
// Try to reuse the pages cached in the chuck list
//
// Hint: use page2kva and memset
struct Page *
page_alloc_npages(int alloc_flags, int n)
{
f01011c9:	55                   	push   %ebp
f01011ca:	89 e5                	mov    %esp,%ebp
f01011cc:	56                   	push   %esi
f01011cd:	53                   	push   %ebx
f01011ce:	8b 75 08             	mov    0x8(%ebp),%esi
f01011d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function
	if (n == 1) {
f01011d4:	83 fb 01             	cmp    $0x1,%ebx
f01011d7:	75 0e                	jne    f01011e7 <page_alloc_npages+0x1e>
		return page_alloc(alloc_flags);
f01011d9:	83 ec 0c             	sub    $0xc,%esp
f01011dc:	56                   	push   %esi
f01011dd:	e8 02 fe ff ff       	call   f0100fe4 <page_alloc>
f01011e2:	83 c4 10             	add    $0x10,%esp
f01011e5:	eb 2a                	jmp    f0101211 <page_alloc_npages+0x48>
	}

	struct Page* result;
	if (!(result = page_alloc_npages_helper(alloc_flags, n, chunk_list))) {
f01011e7:	83 ec 04             	sub    $0x4,%esp
f01011ea:	ff 35 e0 e1 19 f0    	pushl  0xf019e1e0
f01011f0:	53                   	push   %ebx
f01011f1:	56                   	push   %esi
f01011f2:	e8 5d fe ff ff       	call   f0101054 <page_alloc_npages_helper>
f01011f7:	83 c4 10             	add    $0x10,%esp
f01011fa:	85 c0                	test   %eax,%eax
f01011fc:	75 13                	jne    f0101211 <page_alloc_npages+0x48>
		result = page_alloc_npages_helper(alloc_flags, n, page_free_list);
f01011fe:	83 ec 04             	sub    $0x4,%esp
f0101201:	ff 35 e4 e1 19 f0    	pushl  0xf019e1e4
f0101207:	53                   	push   %ebx
f0101208:	56                   	push   %esi
f0101209:	e8 46 fe ff ff       	call   f0101054 <page_alloc_npages_helper>
f010120e:	83 c4 10             	add    $0x10,%esp
	}

	return result;
}
f0101211:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101214:	5b                   	pop    %ebx
f0101215:	5e                   	pop    %esi
f0101216:	5d                   	pop    %ebp
f0101217:	c3                   	ret    

f0101218 <page_free_npages>:
//	2. Add the pages to the chunk list
//
//	Return 0 if everything ok
int
page_free_npages(struct Page *pp, int n)
{
f0101218:	55                   	push   %ebp
f0101219:	89 e5                	mov    %esp,%ebp
f010121b:	53                   	push   %ebx
f010121c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function
	if (!check_continuous(pp, n)) {
f010121f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101222:	89 d8                	mov    %ebx,%eax
f0101224:	e8 a2 f8 ff ff       	call   f0100acb <check_continuous>
f0101229:	85 c0                	test   %eax,%eax
f010122b:	74 20                	je     f010124d <page_free_npages+0x35>
		return -1;
	}

	if (chunk_list->pp_link == NULL) {
f010122d:	a1 e0 e1 19 f0       	mov    0xf019e1e0,%eax
f0101232:	8b 10                	mov    (%eax),%edx
f0101234:	85 d2                	test   %edx,%edx
f0101236:	75 0b                	jne    f0101243 <page_free_npages+0x2b>
		chunk_list->pp_link = pp;
f0101238:	89 18                	mov    %ebx,(%eax)
			;

		tmp->pp_link = pp;
	}

	return 0;
f010123a:	b8 00 00 00 00       	mov    $0x0,%eax
f010123f:	eb 11                	jmp    f0101252 <page_free_npages+0x3a>
	if (chunk_list->pp_link == NULL) {
		chunk_list->pp_link = pp;
	} else {
		struct Page* tmp = chunk_list->pp_link;

		for (; tmp->pp_link; tmp = tmp->pp_link)
f0101241:	89 c2                	mov    %eax,%edx
f0101243:	8b 02                	mov    (%edx),%eax
f0101245:	85 c0                	test   %eax,%eax
f0101247:	75 f8                	jne    f0101241 <page_free_npages+0x29>
			;

		tmp->pp_link = pp;
f0101249:	89 1a                	mov    %ebx,(%edx)
f010124b:	eb 05                	jmp    f0101252 <page_free_npages+0x3a>
int
page_free_npages(struct Page *pp, int n)
{
	// Fill this function
	if (!check_continuous(pp, n)) {
		return -1;
f010124d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

		tmp->pp_link = pp;
	}

	return 0;
}
f0101252:	5b                   	pop    %ebx
f0101253:	5d                   	pop    %ebp
f0101254:	c3                   	ret    

f0101255 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0101255:	55                   	push   %ebp
f0101256:	89 e5                	mov    %esp,%ebp
f0101258:	83 ec 08             	sub    $0x8,%esp
f010125b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if (!pp->pp_ref) {
f010125e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101263:	75 0f                	jne    f0101274 <page_free+0x1f>
		pp->pp_link = page_free_list;
f0101265:	8b 15 e4 e1 19 f0    	mov    0xf019e1e4,%edx
f010126b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f010126d:	a3 e4 e1 19 f0       	mov    %eax,0xf019e1e4
f0101272:	eb 10                	jmp    f0101284 <page_free+0x2f>
	} else {
		cprintf("Page free error! pp_ref is not 0!");
f0101274:	83 ec 0c             	sub    $0xc,%esp
f0101277:	68 80 5e 10 f0       	push   $0xf0105e80
f010127c:	e8 1e 27 00 00       	call   f010399f <cprintf>
f0101281:	83 c4 10             	add    $0x10,%esp
	}
}
f0101284:	c9                   	leave  
f0101285:	c3                   	ret    

f0101286 <page_realloc_npages>:
//
#define check_invalid(i) (i == 0 || (i >= IOPHYSMEM && i < PADDR(boot_alloc(0))))

struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f0101286:	55                   	push   %ebp
f0101287:	89 e5                	mov    %esp,%ebp
f0101289:	57                   	push   %edi
f010128a:	56                   	push   %esi
f010128b:	53                   	push   %ebx
f010128c:	83 ec 1c             	sub    $0x1c,%esp
f010128f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101292:	8b 4d 10             	mov    0x10(%ebp),%ecx
	// Fill this function
	if (!new_n) {
f0101295:	85 c9                	test   %ecx,%ecx
f0101297:	75 16                	jne    f01012af <page_realloc_npages+0x29>
		page_free_npages(pp, old_n);
f0101299:	ff 75 0c             	pushl  0xc(%ebp)
f010129c:	53                   	push   %ebx
f010129d:	e8 76 ff ff ff       	call   f0101218 <page_free_npages>
f01012a2:	83 c4 08             	add    $0x8,%esp
		pp = NULL;
f01012a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01012aa:	e9 b9 01 00 00       	jmp    f0101468 <page_realloc_npages+0x1e2>
	} else if (old_n > new_n) {
f01012af:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
f01012b2:	7d 28                	jge    f01012dc <page_realloc_npages+0x56>
		page_free_npages(pp + new_n, old_n - new_n);
f01012b4:	8d 34 cd 00 00 00 00 	lea    0x0(,%ecx,8),%esi
f01012bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012be:	29 c8                	sub    %ecx,%eax
f01012c0:	50                   	push   %eax
f01012c1:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f01012c4:	50                   	push   %eax
f01012c5:	e8 4e ff ff ff       	call   f0101218 <page_free_npages>
		(pp + new_n - 1)->pp_link = NULL;
f01012ca:	c7 44 33 f8 00 00 00 	movl   $0x0,-0x8(%ebx,%esi,1)
f01012d1:	00 
f01012d2:	83 c4 08             	add    $0x8,%esp
f01012d5:	89 d8                	mov    %ebx,%eax
f01012d7:	e9 8c 01 00 00       	jmp    f0101468 <page_realloc_npages+0x1e2>
	} else if (old_n < new_n) {
f01012dc:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
f01012df:	0f 8e 81 01 00 00    	jle    f0101466 <page_realloc_npages+0x1e0>
		int i = 0;

		for (i = old_n; i < new_n; i++) {
			if (!(pp + i < pages + npages	&& (pp + i)->pp_ref == 0)) {//|| check_invalid(PGNUM(pp + i))
f01012e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012e8:	c1 e0 03             	shl    $0x3,%eax
f01012eb:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
f01012ee:	8b 15 ac ee 19 f0    	mov    0xf019eeac,%edx
f01012f4:	8b 35 a4 ee 19 f0    	mov    0xf019eea4,%esi
f01012fa:	8d 34 f2             	lea    (%edx,%esi,8),%esi
f01012fd:	39 f7                	cmp    %esi,%edi
f01012ff:	73 2d                	jae    f010132e <page_realloc_npages+0xa8>
f0101301:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101306:	75 26                	jne    f010132e <page_realloc_npages+0xa8>
f0101308:	8d 44 03 08          	lea    0x8(%ebx,%eax,1),%eax
f010130c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010130f:	eb 0e                	jmp    f010131f <page_realloc_npages+0x99>
f0101311:	39 c6                	cmp    %eax,%esi
f0101313:	76 19                	jbe    f010132e <page_realloc_npages+0xa8>
f0101315:	83 c0 08             	add    $0x8,%eax
f0101318:	66 83 78 fc 00       	cmpw   $0x0,-0x4(%eax)
f010131d:	75 0f                	jne    f010132e <page_realloc_npages+0xa8>
		page_free_npages(pp + new_n, old_n - new_n);
		(pp + new_n - 1)->pp_link = NULL;
	} else if (old_n < new_n) {
		int i = 0;

		for (i = old_n; i < new_n; i++) {
f010131f:	83 c2 01             	add    $0x1,%edx
f0101322:	39 d1                	cmp    %edx,%ecx
f0101324:	7f eb                	jg     f0101311 <page_realloc_npages+0x8b>
			if (!(pp + i < pages + npages	&& (pp + i)->pp_ref == 0)) {//|| check_invalid(PGNUM(pp + i))
				break;
			}
		}

		if (i != new_n) {
f0101326:	39 d1                	cmp    %edx,%ecx
f0101328:	0f 84 9b 00 00 00    	je     f01013c9 <page_realloc_npages+0x143>
			struct Page* new_pp = page_alloc_npages(ALLOC_ZERO, new_n);
f010132e:	83 ec 08             	sub    $0x8,%esp
f0101331:	51                   	push   %ecx
f0101332:	6a 01                	push   $0x1
f0101334:	e8 90 fe ff ff       	call   f01011c9 <page_alloc_npages>
f0101339:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			memmove(page2kva(new_pp), page2kva(pp), old_n * PGSIZE);
f010133c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010133f:	c1 e7 0c             	shl    $0xc,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101342:	8b 35 ac ee 19 f0    	mov    0xf019eeac,%esi
f0101348:	89 d8                	mov    %ebx,%eax
f010134a:	29 f0                	sub    %esi,%eax
f010134c:	c1 f8 03             	sar    $0x3,%eax
f010134f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101352:	8b 0d a4 ee 19 f0    	mov    0xf019eea4,%ecx
f0101358:	89 c2                	mov    %eax,%edx
f010135a:	c1 ea 0c             	shr    $0xc,%edx
f010135d:	83 c4 10             	add    $0x10,%esp
f0101360:	39 ca                	cmp    %ecx,%edx
f0101362:	72 12                	jb     f0101376 <page_realloc_npages+0xf0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101364:	50                   	push   %eax
f0101365:	68 74 5d 10 f0       	push   $0xf0105d74
f010136a:	6a 56                	push   $0x56
f010136c:	68 19 65 10 f0       	push   $0xf0106519
f0101371:	e8 2f ed ff ff       	call   f01000a5 <_panic>
	return (void *)(pa + KERNBASE);
f0101376:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010137c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010137f:	29 f0                	sub    %esi,%eax
f0101381:	c1 f8 03             	sar    $0x3,%eax
f0101384:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101387:	89 c6                	mov    %eax,%esi
f0101389:	c1 ee 0c             	shr    $0xc,%esi
f010138c:	39 ce                	cmp    %ecx,%esi
f010138e:	72 12                	jb     f01013a2 <page_realloc_npages+0x11c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101390:	50                   	push   %eax
f0101391:	68 74 5d 10 f0       	push   $0xf0105d74
f0101396:	6a 56                	push   $0x56
f0101398:	68 19 65 10 f0       	push   $0xf0106519
f010139d:	e8 03 ed ff ff       	call   f01000a5 <_panic>
f01013a2:	83 ec 04             	sub    $0x4,%esp
f01013a5:	57                   	push   %edi
f01013a6:	52                   	push   %edx
f01013a7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013ac:	50                   	push   %eax
f01013ad:	e8 ff 3e 00 00       	call   f01052b1 <memmove>
			page_free_npages(pp, old_n);
f01013b2:	83 c4 08             	add    $0x8,%esp
f01013b5:	ff 75 0c             	pushl  0xc(%ebp)
f01013b8:	53                   	push   %ebx
f01013b9:	e8 5a fe ff ff       	call   f0101218 <page_free_npages>
			return new_pp;
f01013be:	83 c4 10             	add    $0x10,%esp
f01013c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013c4:	e9 9f 00 00 00       	jmp    f0101468 <page_realloc_npages+0x1e2>
		} else {
			struct Page* tmp = page_free_list;
f01013c9:	a1 e4 e1 19 f0       	mov    0xf019e1e4,%eax
			for (; tmp >= pp && tmp < pp + new_n; tmp = tmp->pp_link)
f01013ce:	39 c3                	cmp    %eax,%ebx
f01013d0:	77 11                	ja     f01013e3 <page_realloc_npages+0x15d>
f01013d2:	8d 0c d3             	lea    (%ebx,%edx,8),%ecx
f01013d5:	39 c8                	cmp    %ecx,%eax
f01013d7:	73 0a                	jae    f01013e3 <page_realloc_npages+0x15d>
f01013d9:	8b 00                	mov    (%eax),%eax
f01013db:	39 c3                	cmp    %eax,%ebx
f01013dd:	77 04                	ja     f01013e3 <page_realloc_npages+0x15d>
f01013df:	39 c8                	cmp    %ecx,%eax
f01013e1:	72 f6                	jb     f01013d9 <page_realloc_npages+0x153>
				;
			page_free_list = tmp;
f01013e3:	a3 e4 e1 19 f0       	mov    %eax,0xf019e1e4

			for (; tmp && tmp->pp_link; tmp = tmp->pp_link) {
f01013e8:	85 c0                	test   %eax,%eax
f01013ea:	74 21                	je     f010140d <page_realloc_npages+0x187>
f01013ec:	8b 08                	mov    (%eax),%ecx
f01013ee:	85 c9                	test   %ecx,%ecx
f01013f0:	74 1b                	je     f010140d <page_realloc_npages+0x187>
				if (tmp->pp_link >= pp && tmp->pp_link < pp + new_n) {
f01013f2:	8d 34 d3             	lea    (%ebx,%edx,8),%esi
f01013f5:	39 cb                	cmp    %ecx,%ebx
f01013f7:	77 08                	ja     f0101401 <page_realloc_npages+0x17b>
f01013f9:	39 ce                	cmp    %ecx,%esi
f01013fb:	76 04                	jbe    f0101401 <page_realloc_npages+0x17b>
					tmp->pp_link = tmp->pp_link->pp_link;
f01013fd:	8b 09                	mov    (%ecx),%ecx
f01013ff:	89 08                	mov    %ecx,(%eax)
			struct Page* tmp = page_free_list;
			for (; tmp >= pp && tmp < pp + new_n; tmp = tmp->pp_link)
				;
			page_free_list = tmp;

			for (; tmp && tmp->pp_link; tmp = tmp->pp_link) {
f0101401:	8b 00                	mov    (%eax),%eax
f0101403:	85 c0                	test   %eax,%eax
f0101405:	74 06                	je     f010140d <page_realloc_npages+0x187>
f0101407:	8b 08                	mov    (%eax),%ecx
f0101409:	85 c9                	test   %ecx,%ecx
f010140b:	75 e8                	jne    f01013f5 <page_realloc_npages+0x16f>
				if (tmp->pp_link >= pp && tmp->pp_link < pp + new_n) {
					tmp->pp_link = tmp->pp_link->pp_link;
				}
			}

			for(tmp = pp, i = 0; i < old_n - 1; tmp = tmp->pp_link, i++ )
f010140d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101410:	83 e8 01             	sub    $0x1,%eax
f0101413:	85 c0                	test   %eax,%eax
f0101415:	7e 18                	jle    f010142f <page_realloc_npages+0x1a9>
f0101417:	8b 45 0c             	mov    0xc(%ebp),%eax
f010141a:	8d 70 ff             	lea    -0x1(%eax),%esi
f010141d:	89 d8                	mov    %ebx,%eax
f010141f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101424:	8b 00                	mov    (%eax),%eax
f0101426:	83 c1 01             	add    $0x1,%ecx
f0101429:	39 f1                	cmp    %esi,%ecx
f010142b:	75 f7                	jne    f0101424 <page_realloc_npages+0x19e>
f010142d:	eb 02                	jmp    f0101431 <page_realloc_npages+0x1ab>
f010142f:	89 d8                	mov    %ebx,%eax
				;

			for (i = 0; i < new_n - old_n; i++) {
f0101431:	2b 55 0c             	sub    0xc(%ebp),%edx
f0101434:	85 d2                	test   %edx,%edx
f0101436:	7e 24                	jle    f010145c <page_realloc_npages+0x1d6>
f0101438:	89 f9                	mov    %edi,%ecx
f010143a:	89 d6                	mov    %edx,%esi
f010143c:	03 75 0c             	add    0xc(%ebp),%esi
f010143f:	8d 3c f3             	lea    (%ebx,%esi,8),%edi
				tmp->pp_link = pp + old_n + i;
f0101442:	89 ce                	mov    %ecx,%esi
f0101444:	89 08                	mov    %ecx,(%eax)
f0101446:	83 c1 08             	add    $0x8,%ecx
f0101449:	89 f0                	mov    %esi,%eax
			}

			for(tmp = pp, i = 0; i < old_n - 1; tmp = tmp->pp_link, i++ )
				;

			for (i = 0; i < new_n - old_n; i++) {
f010144b:	39 f9                	cmp    %edi,%ecx
f010144d:	75 f3                	jne    f0101442 <page_realloc_npages+0x1bc>
f010144f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101452:	8d 84 02 ff ff ff 1f 	lea    0x1fffffff(%edx,%eax,1),%eax
f0101459:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
				tmp->pp_link = pp + old_n + i;
				tmp = tmp->pp_link;
			}
			tmp->pp_link = NULL;
f010145c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

			return pp;
f0101462:	89 d8                	mov    %ebx,%eax
f0101464:	eb 02                	jmp    f0101468 <page_realloc_npages+0x1e2>
f0101466:	89 d8                	mov    %ebx,%eax
		}
	}

	return pp;
}
f0101468:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010146b:	5b                   	pop    %ebx
f010146c:	5e                   	pop    %esi
f010146d:	5f                   	pop    %edi
f010146e:	5d                   	pop    %ebp
f010146f:	c3                   	ret    

f0101470 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0101470:	55                   	push   %ebp
f0101471:	89 e5                	mov    %esp,%ebp
f0101473:	83 ec 08             	sub    $0x8,%esp
f0101476:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101479:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010147d:	83 e8 01             	sub    $0x1,%eax
f0101480:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101484:	66 85 c0             	test   %ax,%ax
f0101487:	75 0c                	jne    f0101495 <page_decref+0x25>
		page_free(pp);
f0101489:	83 ec 0c             	sub    $0xc,%esp
f010148c:	52                   	push   %edx
f010148d:	e8 c3 fd ff ff       	call   f0101255 <page_free>
f0101492:	83 c4 10             	add    $0x10,%esp
}
f0101495:	c9                   	leave  
f0101496:	c3                   	ret    

f0101497 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101497:	55                   	push   %ebp
f0101498:	89 e5                	mov    %esp,%ebp
f010149a:	56                   	push   %esi
f010149b:	53                   	push   %ebx
f010149c:	8b 45 08             	mov    0x8(%ebp),%eax
f010149f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	if (!pgdir) {
f01014a2:	85 c0                	test   %eax,%eax
f01014a4:	75 1a                	jne    f01014c0 <pgdir_walk+0x29>
		cprintf("pgdir no exists.\n");
f01014a6:	83 ec 0c             	sub    $0xc,%esp
f01014a9:	68 c3 65 10 f0       	push   $0xf01065c3
f01014ae:	e8 ec 24 00 00       	call   f010399f <cprintf>
		return NULL;
f01014b3:	83 c4 10             	add    $0x10,%esp
f01014b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01014bb:	e9 bb 00 00 00       	jmp    f010157b <pgdir_walk+0xe4>
	}

	pde_t *pde = pgdir + PDX(va);
f01014c0:	89 da                	mov    %ebx,%edx
f01014c2:	c1 ea 16             	shr    $0x16,%edx
f01014c5:	8d 34 90             	lea    (%eax,%edx,4),%esi
	pte_t *page_table;

	if (*pde & PTE_P) {
f01014c8:	8b 06                	mov    (%esi),%eax
f01014ca:	a8 01                	test   $0x1,%al
f01014cc:	74 39                	je     f0101507 <pgdir_walk+0x70>
		page_table = (pte_t *)KADDR(PTE_ADDR(*pde));
f01014ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014d3:	89 c2                	mov    %eax,%edx
f01014d5:	c1 ea 0c             	shr    $0xc,%edx
f01014d8:	39 15 a4 ee 19 f0    	cmp    %edx,0xf019eea4
f01014de:	77 15                	ja     f01014f5 <pgdir_walk+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014e0:	50                   	push   %eax
f01014e1:	68 74 5d 10 f0       	push   $0xf0105d74
f01014e6:	68 31 02 00 00       	push   $0x231
f01014eb:	68 0d 65 10 f0       	push   $0xf010650d
f01014f0:	e8 b0 eb ff ff       	call   f01000a5 <_panic>
		return page_table + PTX(va);
f01014f5:	c1 eb 0a             	shr    $0xa,%ebx
f01014f8:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01014fe:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101505:	eb 74                	jmp    f010157b <pgdir_walk+0xe4>
	}

	struct Page *page;
	if (create && (page = page_alloc(ALLOC_ZERO))) {
f0101507:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010150b:	74 62                	je     f010156f <pgdir_walk+0xd8>
f010150d:	83 ec 0c             	sub    $0xc,%esp
f0101510:	6a 01                	push   $0x1
f0101512:	e8 cd fa ff ff       	call   f0100fe4 <page_alloc>
f0101517:	83 c4 10             	add    $0x10,%esp
f010151a:	85 c0                	test   %eax,%eax
f010151c:	74 58                	je     f0101576 <pgdir_walk+0xdf>
		page->pp_ref++;
f010151e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101523:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0101529:	c1 f8 03             	sar    $0x3,%eax
f010152c:	c1 e0 0c             	shl    $0xc,%eax
		*pde = page2pa(page) | PTE_P | PTE_W | PTE_U;
f010152f:	89 c2                	mov    %eax,%edx
f0101531:	83 ca 07             	or     $0x7,%edx
f0101534:	89 16                	mov    %edx,(%esi)
f0101536:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010153b:	89 c2                	mov    %eax,%edx
f010153d:	c1 ea 0c             	shr    $0xc,%edx
f0101540:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0101546:	72 15                	jb     f010155d <pgdir_walk+0xc6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101548:	50                   	push   %eax
f0101549:	68 74 5d 10 f0       	push   $0xf0105d74
f010154e:	68 39 02 00 00       	push   $0x239
f0101553:	68 0d 65 10 f0       	push   $0xf010650d
f0101558:	e8 48 eb ff ff       	call   f01000a5 <_panic>
		page_table = (pte_t *)KADDR(PTE_ADDR(*pde));
		return page_table + PTX(va);
f010155d:	c1 eb 0a             	shr    $0xa,%ebx
f0101560:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101566:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f010156d:	eb 0c                	jmp    f010157b <pgdir_walk+0xe4>
	}

	return NULL;
f010156f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101574:	eb 05                	jmp    f010157b <pgdir_walk+0xe4>
f0101576:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010157b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010157e:	5b                   	pop    %ebx
f010157f:	5e                   	pop    %esi
f0101580:	5d                   	pop    %ebp
f0101581:	c3                   	ret    

f0101582 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101582:	55                   	push   %ebp
f0101583:	89 e5                	mov    %esp,%ebp
f0101585:	57                   	push   %edi
f0101586:	56                   	push   %esi
f0101587:	53                   	push   %ebx
f0101588:	83 ec 1c             	sub    $0x1c,%esp
	// Fill this function in
	size_t num = size / PGSIZE;
f010158b:	c1 e9 0c             	shr    $0xc,%ecx
f010158e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	size_t i;

	for (i = 0; i < num; i++) {
f0101591:	85 c9                	test   %ecx,%ecx
f0101593:	74 45                	je     f01015da <boot_map_region+0x58>
f0101595:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101598:	89 d3                	mov    %edx,%ebx
f010159a:	bf 00 00 00 00       	mov    $0x0,%edi
f010159f:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a2:	29 d0                	sub    %edx,%eax
f01015a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa | perm | PTE_P;
f01015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015aa:	83 c8 01             	or     $0x1,%eax
f01015ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01015b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015b3:	8d 34 18             	lea    (%eax,%ebx,1),%esi
	// Fill this function in
	size_t num = size / PGSIZE;
	size_t i;

	for (i = 0; i < num; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01015b6:	83 ec 04             	sub    $0x4,%esp
f01015b9:	6a 01                	push   $0x1
f01015bb:	53                   	push   %ebx
f01015bc:	ff 75 d8             	pushl  -0x28(%ebp)
f01015bf:	e8 d3 fe ff ff       	call   f0101497 <pgdir_walk>
		*pte = pa | perm | PTE_P;
f01015c4:	0b 75 dc             	or     -0x24(%ebp),%esi
f01015c7:	89 30                	mov    %esi,(%eax)
		va += PGSIZE;
f01015c9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// Fill this function in
	size_t num = size / PGSIZE;
	size_t i;

	for (i = 0; i < num; i++) {
f01015cf:	83 c7 01             	add    $0x1,%edi
f01015d2:	83 c4 10             	add    $0x10,%esp
f01015d5:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
f01015d8:	75 d6                	jne    f01015b0 <boot_map_region+0x2e>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f01015da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015dd:	5b                   	pop    %ebx
f01015de:	5e                   	pop    %esi
f01015df:	5f                   	pop    %edi
f01015e0:	5d                   	pop    %ebp
f01015e1:	c3                   	ret    

f01015e2 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01015e2:	55                   	push   %ebp
f01015e3:	89 e5                	mov    %esp,%ebp
f01015e5:	53                   	push   %ebx
f01015e6:	83 ec 08             	sub    $0x8,%esp
f01015e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01015ec:	6a 00                	push   $0x0
f01015ee:	ff 75 0c             	pushl  0xc(%ebp)
f01015f1:	ff 75 08             	pushl  0x8(%ebp)
f01015f4:	e8 9e fe ff ff       	call   f0101497 <pgdir_walk>
	if (pte && (*pte & PTE_P)) {
f01015f9:	83 c4 10             	add    $0x10,%esp
f01015fc:	85 c0                	test   %eax,%eax
f01015fe:	74 37                	je     f0101637 <page_lookup+0x55>
f0101600:	f6 00 01             	testb  $0x1,(%eax)
f0101603:	74 39                	je     f010163e <page_lookup+0x5c>
		if (pte_store) {
f0101605:	85 db                	test   %ebx,%ebx
f0101607:	74 02                	je     f010160b <page_lookup+0x29>
			*pte_store = pte;
f0101609:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010160b:	8b 00                	mov    (%eax),%eax
f010160d:	c1 e8 0c             	shr    $0xc,%eax
f0101610:	3b 05 a4 ee 19 f0    	cmp    0xf019eea4,%eax
f0101616:	72 14                	jb     f010162c <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101618:	83 ec 04             	sub    $0x4,%esp
f010161b:	68 a4 5e 10 f0       	push   $0xf0105ea4
f0101620:	6a 4f                	push   $0x4f
f0101622:	68 19 65 10 f0       	push   $0xf0106519
f0101627:	e8 79 ea ff ff       	call   f01000a5 <_panic>
	return &pages[PGNUM(pa)];
f010162c:	8b 15 ac ee 19 f0    	mov    0xf019eeac,%edx
f0101632:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		}
		return pa2page(PTE_ADDR(*pte));
f0101635:	eb 0c                	jmp    f0101643 <page_lookup+0x61>
	}

	return NULL;
f0101637:	b8 00 00 00 00       	mov    $0x0,%eax
f010163c:	eb 05                	jmp    f0101643 <page_lookup+0x61>
f010163e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101646:	c9                   	leave  
f0101647:	c3                   	ret    

f0101648 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101648:	55                   	push   %ebp
f0101649:	89 e5                	mov    %esp,%ebp
f010164b:	53                   	push   %ebx
f010164c:	83 ec 18             	sub    $0x18,%esp
f010164f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;
	struct Page *page = page_lookup(pgdir, va, &pte);
f0101652:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101655:	50                   	push   %eax
f0101656:	53                   	push   %ebx
f0101657:	ff 75 08             	pushl  0x8(%ebp)
f010165a:	e8 83 ff ff ff       	call   f01015e2 <page_lookup>
	if (page) {
f010165f:	83 c4 10             	add    $0x10,%esp
f0101662:	85 c0                	test   %eax,%eax
f0101664:	74 18                	je     f010167e <page_remove+0x36>
		*pte = 0;
f0101666:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101669:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010166f:	0f 01 3b             	invlpg (%ebx)
		tlb_invalidate(pgdir, va);
		page_decref(page);
f0101672:	83 ec 0c             	sub    $0xc,%esp
f0101675:	50                   	push   %eax
f0101676:	e8 f5 fd ff ff       	call   f0101470 <page_decref>
f010167b:	83 c4 10             	add    $0x10,%esp
	}
}
f010167e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101681:	c9                   	leave  
f0101682:	c3                   	ret    

f0101683 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f0101683:	55                   	push   %ebp
f0101684:	89 e5                	mov    %esp,%ebp
f0101686:	57                   	push   %edi
f0101687:	56                   	push   %esi
f0101688:	53                   	push   %ebx
f0101689:	83 ec 10             	sub    $0x10,%esp
f010168c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010168f:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101692:	6a 01                	push   $0x1
f0101694:	57                   	push   %edi
f0101695:	ff 75 08             	pushl  0x8(%ebp)
f0101698:	e8 fa fd ff ff       	call   f0101497 <pgdir_walk>

	if (pte && (*pte & PTE_P)) {
f010169d:	83 c4 10             	add    $0x10,%esp
f01016a0:	85 c0                	test   %eax,%eax
f01016a2:	74 5c                	je     f0101700 <page_insert+0x7d>
f01016a4:	89 c6                	mov    %eax,%esi
f01016a6:	8b 00                	mov    (%eax),%eax
f01016a8:	a8 01                	test   $0x1,%al
f01016aa:	74 30                	je     f01016dc <page_insert+0x59>
		if (page2pa(pp) == PTE_ADDR(*pte)) {
f01016ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01016b1:	89 da                	mov    %ebx,%edx
f01016b3:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f01016b9:	c1 fa 03             	sar    $0x3,%edx
f01016bc:	c1 e2 0c             	shl    $0xc,%edx
f01016bf:	39 d0                	cmp    %edx,%eax
f01016c1:	75 0a                	jne    f01016cd <page_insert+0x4a>
f01016c3:	0f 01 3f             	invlpg (%edi)
			tlb_invalidate(pgdir, va);
			pp->pp_ref--;
f01016c6:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f01016cb:	eb 0f                	jmp    f01016dc <page_insert+0x59>
		} else {
			page_remove(pgdir, va);
f01016cd:	83 ec 08             	sub    $0x8,%esp
f01016d0:	57                   	push   %edi
f01016d1:	ff 75 08             	pushl  0x8(%ebp)
f01016d4:	e8 6f ff ff ff       	call   f0101648 <page_remove>
f01016d9:	83 c4 10             	add    $0x10,%esp
		}
	} else if (!pte) {
		return -E_NO_MEM;
	}
	*pte = page2pa(pp) | perm | PTE_P;
f01016dc:	89 d8                	mov    %ebx,%eax
f01016de:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f01016e4:	c1 f8 03             	sar    $0x3,%eax
f01016e7:	c1 e0 0c             	shl    $0xc,%eax
f01016ea:	8b 55 14             	mov    0x14(%ebp),%edx
f01016ed:	83 ca 01             	or     $0x1,%edx
f01016f0:	09 d0                	or     %edx,%eax
f01016f2:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f01016f4:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	return 0;
f01016f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01016fe:	eb 05                	jmp    f0101705 <page_insert+0x82>
			pp->pp_ref--;
		} else {
			page_remove(pgdir, va);
		}
	} else if (!pte) {
		return -E_NO_MEM;
f0101700:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref++;

	return 0;
}
f0101705:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101708:	5b                   	pop    %ebx
f0101709:	5e                   	pop    %esi
f010170a:	5f                   	pop    %edi
f010170b:	5d                   	pop    %ebp
f010170c:	c3                   	ret    

f010170d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010170d:	55                   	push   %ebp
f010170e:	89 e5                	mov    %esp,%ebp
f0101710:	57                   	push   %edi
f0101711:	56                   	push   %esi
f0101712:	53                   	push   %ebx
f0101713:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101716:	6a 15                	push   $0x15
f0101718:	e8 1b 22 00 00       	call   f0103938 <mc146818_read>
f010171d:	89 c3                	mov    %eax,%ebx
f010171f:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101726:	e8 0d 22 00 00       	call   f0103938 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010172b:	c1 e0 08             	shl    $0x8,%eax
f010172e:	09 d8                	or     %ebx,%eax
f0101730:	c1 e0 0a             	shl    $0xa,%eax
f0101733:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101739:	85 c0                	test   %eax,%eax
f010173b:	0f 48 c2             	cmovs  %edx,%eax
f010173e:	c1 f8 0c             	sar    $0xc,%eax
f0101741:	a3 e8 e1 19 f0       	mov    %eax,0xf019e1e8
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101746:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010174d:	e8 e6 21 00 00       	call   f0103938 <mc146818_read>
f0101752:	89 c3                	mov    %eax,%ebx
f0101754:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010175b:	e8 d8 21 00 00       	call   f0103938 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101760:	c1 e0 08             	shl    $0x8,%eax
f0101763:	09 d8                	or     %ebx,%eax
f0101765:	c1 e0 0a             	shl    $0xa,%eax
f0101768:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010176e:	83 c4 10             	add    $0x10,%esp
f0101771:	85 c0                	test   %eax,%eax
f0101773:	0f 48 c2             	cmovs  %edx,%eax
f0101776:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101779:	85 c0                	test   %eax,%eax
f010177b:	74 0e                	je     f010178b <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010177d:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101783:	89 15 a4 ee 19 f0    	mov    %edx,0xf019eea4
f0101789:	eb 0c                	jmp    f0101797 <mem_init+0x8a>
	else
		npages = npages_basemem;
f010178b:	8b 15 e8 e1 19 f0    	mov    0xf019e1e8,%edx
f0101791:	89 15 a4 ee 19 f0    	mov    %edx,0xf019eea4

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101797:	c1 e0 0c             	shl    $0xc,%eax
f010179a:	c1 e8 0a             	shr    $0xa,%eax
f010179d:	50                   	push   %eax
f010179e:	a1 e8 e1 19 f0       	mov    0xf019e1e8,%eax
f01017a3:	c1 e0 0c             	shl    $0xc,%eax
f01017a6:	c1 e8 0a             	shr    $0xa,%eax
f01017a9:	50                   	push   %eax
f01017aa:	a1 a4 ee 19 f0       	mov    0xf019eea4,%eax
f01017af:	c1 e0 0c             	shl    $0xc,%eax
f01017b2:	c1 e8 0a             	shr    $0xa,%eax
f01017b5:	50                   	push   %eax
f01017b6:	68 c4 5e 10 f0       	push   $0xf0105ec4
f01017bb:	e8 df 21 00 00       	call   f010399f <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01017c0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01017c5:	e8 f3 f3 ff ff       	call   f0100bbd <boot_alloc>
f01017ca:	a3 a8 ee 19 f0       	mov    %eax,0xf019eea8
	memset(kern_pgdir, 0, PGSIZE);
f01017cf:	83 c4 0c             	add    $0xc,%esp
f01017d2:	68 00 10 00 00       	push   $0x1000
f01017d7:	6a 00                	push   $0x0
f01017d9:	50                   	push   %eax
f01017da:	e8 85 3a 00 00       	call   f0105264 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01017df:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01017e4:	83 c4 10             	add    $0x10,%esp
f01017e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01017ec:	77 15                	ja     f0101803 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01017ee:	50                   	push   %eax
f01017ef:	68 98 5d 10 f0       	push   $0xf0105d98
f01017f4:	68 95 00 00 00       	push   $0x95
f01017f9:	68 0d 65 10 f0       	push   $0xf010650d
f01017fe:	e8 a2 e8 ff ff       	call   f01000a5 <_panic>
f0101803:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101809:	83 ca 05             	or     $0x5,%edx
f010180c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = boot_alloc(npages * sizeof(struct Page));
f0101812:	a1 a4 ee 19 f0       	mov    0xf019eea4,%eax
f0101817:	c1 e0 03             	shl    $0x3,%eax
f010181a:	e8 9e f3 ff ff       	call   f0100bbd <boot_alloc>
f010181f:	a3 ac ee 19 f0       	mov    %eax,0xf019eeac


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = boot_alloc(NENV * sizeof(struct Env));
f0101824:	b8 00 90 01 00       	mov    $0x19000,%eax
f0101829:	e8 8f f3 ff ff       	call   f0100bbd <boot_alloc>
f010182e:	a3 f0 e1 19 f0       	mov    %eax,0xf019e1f0
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101833:	e8 ea f6 ff ff       	call   f0100f22 <page_init>

	check_page_free_list(1);
f0101838:	b8 01 00 00 00       	mov    $0x1,%eax
f010183d:	e8 04 f4 ff ff       	call   f0100c46 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0101842:	83 3d ac ee 19 f0 00 	cmpl   $0x0,0xf019eeac
f0101849:	75 17                	jne    f0101862 <mem_init+0x155>
		panic("'pages' is a null pointer!");
f010184b:	83 ec 04             	sub    $0x4,%esp
f010184e:	68 d5 65 10 f0       	push   $0xf01065d5
f0101853:	68 57 03 00 00       	push   $0x357
f0101858:	68 0d 65 10 f0       	push   $0xf010650d
f010185d:	e8 43 e8 ff ff       	call   f01000a5 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101862:	a1 e4 e1 19 f0       	mov    0xf019e1e4,%eax
f0101867:	85 c0                	test   %eax,%eax
f0101869:	74 10                	je     f010187b <mem_init+0x16e>
f010186b:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101870:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101873:	8b 00                	mov    (%eax),%eax
f0101875:	85 c0                	test   %eax,%eax
f0101877:	75 f7                	jne    f0101870 <mem_init+0x163>
f0101879:	eb 05                	jmp    f0101880 <mem_init+0x173>
f010187b:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101880:	83 ec 0c             	sub    $0xc,%esp
f0101883:	6a 00                	push   $0x0
f0101885:	e8 5a f7 ff ff       	call   f0100fe4 <page_alloc>
f010188a:	89 c7                	mov    %eax,%edi
f010188c:	83 c4 10             	add    $0x10,%esp
f010188f:	85 c0                	test   %eax,%eax
f0101891:	75 19                	jne    f01018ac <mem_init+0x19f>
f0101893:	68 f0 65 10 f0       	push   $0xf01065f0
f0101898:	68 33 65 10 f0       	push   $0xf0106533
f010189d:	68 5f 03 00 00       	push   $0x35f
f01018a2:	68 0d 65 10 f0       	push   $0xf010650d
f01018a7:	e8 f9 e7 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f01018ac:	83 ec 0c             	sub    $0xc,%esp
f01018af:	6a 00                	push   $0x0
f01018b1:	e8 2e f7 ff ff       	call   f0100fe4 <page_alloc>
f01018b6:	89 c6                	mov    %eax,%esi
f01018b8:	83 c4 10             	add    $0x10,%esp
f01018bb:	85 c0                	test   %eax,%eax
f01018bd:	75 19                	jne    f01018d8 <mem_init+0x1cb>
f01018bf:	68 06 66 10 f0       	push   $0xf0106606
f01018c4:	68 33 65 10 f0       	push   $0xf0106533
f01018c9:	68 60 03 00 00       	push   $0x360
f01018ce:	68 0d 65 10 f0       	push   $0xf010650d
f01018d3:	e8 cd e7 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f01018d8:	83 ec 0c             	sub    $0xc,%esp
f01018db:	6a 00                	push   $0x0
f01018dd:	e8 02 f7 ff ff       	call   f0100fe4 <page_alloc>
f01018e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018e5:	83 c4 10             	add    $0x10,%esp
f01018e8:	85 c0                	test   %eax,%eax
f01018ea:	75 19                	jne    f0101905 <mem_init+0x1f8>
f01018ec:	68 1c 66 10 f0       	push   $0xf010661c
f01018f1:	68 33 65 10 f0       	push   $0xf0106533
f01018f6:	68 61 03 00 00       	push   $0x361
f01018fb:	68 0d 65 10 f0       	push   $0xf010650d
f0101900:	e8 a0 e7 ff ff       	call   f01000a5 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101905:	39 f7                	cmp    %esi,%edi
f0101907:	75 19                	jne    f0101922 <mem_init+0x215>
f0101909:	68 32 66 10 f0       	push   $0xf0106632
f010190e:	68 33 65 10 f0       	push   $0xf0106533
f0101913:	68 64 03 00 00       	push   $0x364
f0101918:	68 0d 65 10 f0       	push   $0xf010650d
f010191d:	e8 83 e7 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101922:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101925:	39 c6                	cmp    %eax,%esi
f0101927:	74 04                	je     f010192d <mem_init+0x220>
f0101929:	39 c7                	cmp    %eax,%edi
f010192b:	75 19                	jne    f0101946 <mem_init+0x239>
f010192d:	68 00 5f 10 f0       	push   $0xf0105f00
f0101932:	68 33 65 10 f0       	push   $0xf0106533
f0101937:	68 65 03 00 00       	push   $0x365
f010193c:	68 0d 65 10 f0       	push   $0xf010650d
f0101941:	e8 5f e7 ff ff       	call   f01000a5 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101946:	8b 0d ac ee 19 f0    	mov    0xf019eeac,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010194c:	8b 15 a4 ee 19 f0    	mov    0xf019eea4,%edx
f0101952:	c1 e2 0c             	shl    $0xc,%edx
f0101955:	89 f8                	mov    %edi,%eax
f0101957:	29 c8                	sub    %ecx,%eax
f0101959:	c1 f8 03             	sar    $0x3,%eax
f010195c:	c1 e0 0c             	shl    $0xc,%eax
f010195f:	39 d0                	cmp    %edx,%eax
f0101961:	72 19                	jb     f010197c <mem_init+0x26f>
f0101963:	68 44 66 10 f0       	push   $0xf0106644
f0101968:	68 33 65 10 f0       	push   $0xf0106533
f010196d:	68 66 03 00 00       	push   $0x366
f0101972:	68 0d 65 10 f0       	push   $0xf010650d
f0101977:	e8 29 e7 ff ff       	call   f01000a5 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010197c:	89 f0                	mov    %esi,%eax
f010197e:	29 c8                	sub    %ecx,%eax
f0101980:	c1 f8 03             	sar    $0x3,%eax
f0101983:	c1 e0 0c             	shl    $0xc,%eax
f0101986:	39 c2                	cmp    %eax,%edx
f0101988:	77 19                	ja     f01019a3 <mem_init+0x296>
f010198a:	68 61 66 10 f0       	push   $0xf0106661
f010198f:	68 33 65 10 f0       	push   $0xf0106533
f0101994:	68 67 03 00 00       	push   $0x367
f0101999:	68 0d 65 10 f0       	push   $0xf010650d
f010199e:	e8 02 e7 ff ff       	call   f01000a5 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01019a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a6:	29 c8                	sub    %ecx,%eax
f01019a8:	c1 f8 03             	sar    $0x3,%eax
f01019ab:	c1 e0 0c             	shl    $0xc,%eax
f01019ae:	39 c2                	cmp    %eax,%edx
f01019b0:	77 19                	ja     f01019cb <mem_init+0x2be>
f01019b2:	68 7e 66 10 f0       	push   $0xf010667e
f01019b7:	68 33 65 10 f0       	push   $0xf0106533
f01019bc:	68 68 03 00 00       	push   $0x368
f01019c1:	68 0d 65 10 f0       	push   $0xf010650d
f01019c6:	e8 da e6 ff ff       	call   f01000a5 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019cb:	a1 e4 e1 19 f0       	mov    0xf019e1e4,%eax
f01019d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019d3:	c7 05 e4 e1 19 f0 00 	movl   $0x0,0xf019e1e4
f01019da:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019dd:	83 ec 0c             	sub    $0xc,%esp
f01019e0:	6a 00                	push   $0x0
f01019e2:	e8 fd f5 ff ff       	call   f0100fe4 <page_alloc>
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	74 19                	je     f0101a07 <mem_init+0x2fa>
f01019ee:	68 9b 66 10 f0       	push   $0xf010669b
f01019f3:	68 33 65 10 f0       	push   $0xf0106533
f01019f8:	68 6f 03 00 00       	push   $0x36f
f01019fd:	68 0d 65 10 f0       	push   $0xf010650d
f0101a02:	e8 9e e6 ff ff       	call   f01000a5 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101a07:	83 ec 0c             	sub    $0xc,%esp
f0101a0a:	57                   	push   %edi
f0101a0b:	e8 45 f8 ff ff       	call   f0101255 <page_free>
	page_free(pp1);
f0101a10:	89 34 24             	mov    %esi,(%esp)
f0101a13:	e8 3d f8 ff ff       	call   f0101255 <page_free>
	page_free(pp2);
f0101a18:	83 c4 04             	add    $0x4,%esp
f0101a1b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a1e:	e8 32 f8 ff ff       	call   f0101255 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a2a:	e8 b5 f5 ff ff       	call   f0100fe4 <page_alloc>
f0101a2f:	89 c6                	mov    %eax,%esi
f0101a31:	83 c4 10             	add    $0x10,%esp
f0101a34:	85 c0                	test   %eax,%eax
f0101a36:	75 19                	jne    f0101a51 <mem_init+0x344>
f0101a38:	68 f0 65 10 f0       	push   $0xf01065f0
f0101a3d:	68 33 65 10 f0       	push   $0xf0106533
f0101a42:	68 76 03 00 00       	push   $0x376
f0101a47:	68 0d 65 10 f0       	push   $0xf010650d
f0101a4c:	e8 54 e6 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a51:	83 ec 0c             	sub    $0xc,%esp
f0101a54:	6a 00                	push   $0x0
f0101a56:	e8 89 f5 ff ff       	call   f0100fe4 <page_alloc>
f0101a5b:	89 c7                	mov    %eax,%edi
f0101a5d:	83 c4 10             	add    $0x10,%esp
f0101a60:	85 c0                	test   %eax,%eax
f0101a62:	75 19                	jne    f0101a7d <mem_init+0x370>
f0101a64:	68 06 66 10 f0       	push   $0xf0106606
f0101a69:	68 33 65 10 f0       	push   $0xf0106533
f0101a6e:	68 77 03 00 00       	push   $0x377
f0101a73:	68 0d 65 10 f0       	push   $0xf010650d
f0101a78:	e8 28 e6 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a7d:	83 ec 0c             	sub    $0xc,%esp
f0101a80:	6a 00                	push   $0x0
f0101a82:	e8 5d f5 ff ff       	call   f0100fe4 <page_alloc>
f0101a87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a8a:	83 c4 10             	add    $0x10,%esp
f0101a8d:	85 c0                	test   %eax,%eax
f0101a8f:	75 19                	jne    f0101aaa <mem_init+0x39d>
f0101a91:	68 1c 66 10 f0       	push   $0xf010661c
f0101a96:	68 33 65 10 f0       	push   $0xf0106533
f0101a9b:	68 78 03 00 00       	push   $0x378
f0101aa0:	68 0d 65 10 f0       	push   $0xf010650d
f0101aa5:	e8 fb e5 ff ff       	call   f01000a5 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101aaa:	39 fe                	cmp    %edi,%esi
f0101aac:	75 19                	jne    f0101ac7 <mem_init+0x3ba>
f0101aae:	68 32 66 10 f0       	push   $0xf0106632
f0101ab3:	68 33 65 10 f0       	push   $0xf0106533
f0101ab8:	68 7a 03 00 00       	push   $0x37a
f0101abd:	68 0d 65 10 f0       	push   $0xf010650d
f0101ac2:	e8 de e5 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ac7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aca:	39 c7                	cmp    %eax,%edi
f0101acc:	74 04                	je     f0101ad2 <mem_init+0x3c5>
f0101ace:	39 c6                	cmp    %eax,%esi
f0101ad0:	75 19                	jne    f0101aeb <mem_init+0x3de>
f0101ad2:	68 00 5f 10 f0       	push   $0xf0105f00
f0101ad7:	68 33 65 10 f0       	push   $0xf0106533
f0101adc:	68 7b 03 00 00       	push   $0x37b
f0101ae1:	68 0d 65 10 f0       	push   $0xf010650d
f0101ae6:	e8 ba e5 ff ff       	call   f01000a5 <_panic>
	assert(!page_alloc(0));
f0101aeb:	83 ec 0c             	sub    $0xc,%esp
f0101aee:	6a 00                	push   $0x0
f0101af0:	e8 ef f4 ff ff       	call   f0100fe4 <page_alloc>
f0101af5:	83 c4 10             	add    $0x10,%esp
f0101af8:	85 c0                	test   %eax,%eax
f0101afa:	74 19                	je     f0101b15 <mem_init+0x408>
f0101afc:	68 9b 66 10 f0       	push   $0xf010669b
f0101b01:	68 33 65 10 f0       	push   $0xf0106533
f0101b06:	68 7c 03 00 00       	push   $0x37c
f0101b0b:	68 0d 65 10 f0       	push   $0xf010650d
f0101b10:	e8 90 e5 ff ff       	call   f01000a5 <_panic>
f0101b15:	89 f0                	mov    %esi,%eax
f0101b17:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0101b1d:	c1 f8 03             	sar    $0x3,%eax
f0101b20:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b23:	89 c2                	mov    %eax,%edx
f0101b25:	c1 ea 0c             	shr    $0xc,%edx
f0101b28:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0101b2e:	72 12                	jb     f0101b42 <mem_init+0x435>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b30:	50                   	push   %eax
f0101b31:	68 74 5d 10 f0       	push   $0xf0105d74
f0101b36:	6a 56                	push   $0x56
f0101b38:	68 19 65 10 f0       	push   $0xf0106519
f0101b3d:	e8 63 e5 ff ff       	call   f01000a5 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101b42:	83 ec 04             	sub    $0x4,%esp
f0101b45:	68 00 10 00 00       	push   $0x1000
f0101b4a:	6a 01                	push   $0x1
f0101b4c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b51:	50                   	push   %eax
f0101b52:	e8 0d 37 00 00       	call   f0105264 <memset>
	page_free(pp0);
f0101b57:	89 34 24             	mov    %esi,(%esp)
f0101b5a:	e8 f6 f6 ff ff       	call   f0101255 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b66:	e8 79 f4 ff ff       	call   f0100fe4 <page_alloc>
f0101b6b:	83 c4 10             	add    $0x10,%esp
f0101b6e:	85 c0                	test   %eax,%eax
f0101b70:	75 19                	jne    f0101b8b <mem_init+0x47e>
f0101b72:	68 aa 66 10 f0       	push   $0xf01066aa
f0101b77:	68 33 65 10 f0       	push   $0xf0106533
f0101b7c:	68 81 03 00 00       	push   $0x381
f0101b81:	68 0d 65 10 f0       	push   $0xf010650d
f0101b86:	e8 1a e5 ff ff       	call   f01000a5 <_panic>
	assert(pp && pp0 == pp);
f0101b8b:	39 c6                	cmp    %eax,%esi
f0101b8d:	74 19                	je     f0101ba8 <mem_init+0x49b>
f0101b8f:	68 c8 66 10 f0       	push   $0xf01066c8
f0101b94:	68 33 65 10 f0       	push   $0xf0106533
f0101b99:	68 82 03 00 00       	push   $0x382
f0101b9e:	68 0d 65 10 f0       	push   $0xf010650d
f0101ba3:	e8 fd e4 ff ff       	call   f01000a5 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ba8:	89 f2                	mov    %esi,%edx
f0101baa:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f0101bb0:	c1 fa 03             	sar    $0x3,%edx
f0101bb3:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bb6:	89 d0                	mov    %edx,%eax
f0101bb8:	c1 e8 0c             	shr    $0xc,%eax
f0101bbb:	3b 05 a4 ee 19 f0    	cmp    0xf019eea4,%eax
f0101bc1:	72 12                	jb     f0101bd5 <mem_init+0x4c8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bc3:	52                   	push   %edx
f0101bc4:	68 74 5d 10 f0       	push   $0xf0105d74
f0101bc9:	6a 56                	push   $0x56
f0101bcb:	68 19 65 10 f0       	push   $0xf0106519
f0101bd0:	e8 d0 e4 ff ff       	call   f01000a5 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101bd5:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101bdc:	75 11                	jne    f0101bef <mem_init+0x4e2>
f0101bde:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f0101be4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0101bea:	80 38 00             	cmpb   $0x0,(%eax)
f0101bed:	74 19                	je     f0101c08 <mem_init+0x4fb>
f0101bef:	68 d8 66 10 f0       	push   $0xf01066d8
f0101bf4:	68 33 65 10 f0       	push   $0xf0106533
f0101bf9:	68 85 03 00 00       	push   $0x385
f0101bfe:	68 0d 65 10 f0       	push   $0xf010650d
f0101c03:	e8 9d e4 ff ff       	call   f01000a5 <_panic>
f0101c08:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101c0b:	39 d0                	cmp    %edx,%eax
f0101c0d:	75 db                	jne    f0101bea <mem_init+0x4dd>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101c0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c12:	a3 e4 e1 19 f0       	mov    %eax,0xf019e1e4

	// free the pages we took
	page_free(pp0);
f0101c17:	83 ec 0c             	sub    $0xc,%esp
f0101c1a:	56                   	push   %esi
f0101c1b:	e8 35 f6 ff ff       	call   f0101255 <page_free>
	page_free(pp1);
f0101c20:	89 3c 24             	mov    %edi,(%esp)
f0101c23:	e8 2d f6 ff ff       	call   f0101255 <page_free>
	page_free(pp2);
f0101c28:	83 c4 04             	add    $0x4,%esp
f0101c2b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c2e:	e8 22 f6 ff ff       	call   f0101255 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c33:	a1 e4 e1 19 f0       	mov    0xf019e1e4,%eax
f0101c38:	83 c4 10             	add    $0x10,%esp
f0101c3b:	85 c0                	test   %eax,%eax
f0101c3d:	74 09                	je     f0101c48 <mem_init+0x53b>
		--nfree;
f0101c3f:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c42:	8b 00                	mov    (%eax),%eax
f0101c44:	85 c0                	test   %eax,%eax
f0101c46:	75 f7                	jne    f0101c3f <mem_init+0x532>
		--nfree;
	assert(nfree == 0);
f0101c48:	85 db                	test   %ebx,%ebx
f0101c4a:	74 19                	je     f0101c65 <mem_init+0x558>
f0101c4c:	68 e2 66 10 f0       	push   $0xf01066e2
f0101c51:	68 33 65 10 f0       	push   $0xf0106533
f0101c56:	68 92 03 00 00       	push   $0x392
f0101c5b:	68 0d 65 10 f0       	push   $0xf010650d
f0101c60:	e8 40 e4 ff ff       	call   f01000a5 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101c65:	83 ec 0c             	sub    $0xc,%esp
f0101c68:	68 20 5f 10 f0       	push   $0xf0105f20
f0101c6d:	e8 2d 1d 00 00       	call   f010399f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c79:	e8 66 f3 ff ff       	call   f0100fe4 <page_alloc>
f0101c7e:	89 c3                	mov    %eax,%ebx
f0101c80:	83 c4 10             	add    $0x10,%esp
f0101c83:	85 c0                	test   %eax,%eax
f0101c85:	75 19                	jne    f0101ca0 <mem_init+0x593>
f0101c87:	68 f0 65 10 f0       	push   $0xf01065f0
f0101c8c:	68 33 65 10 f0       	push   $0xf0106533
f0101c91:	68 f0 03 00 00       	push   $0x3f0
f0101c96:	68 0d 65 10 f0       	push   $0xf010650d
f0101c9b:	e8 05 e4 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ca0:	83 ec 0c             	sub    $0xc,%esp
f0101ca3:	6a 00                	push   $0x0
f0101ca5:	e8 3a f3 ff ff       	call   f0100fe4 <page_alloc>
f0101caa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cad:	83 c4 10             	add    $0x10,%esp
f0101cb0:	85 c0                	test   %eax,%eax
f0101cb2:	75 19                	jne    f0101ccd <mem_init+0x5c0>
f0101cb4:	68 06 66 10 f0       	push   $0xf0106606
f0101cb9:	68 33 65 10 f0       	push   $0xf0106533
f0101cbe:	68 f1 03 00 00       	push   $0x3f1
f0101cc3:	68 0d 65 10 f0       	push   $0xf010650d
f0101cc8:	e8 d8 e3 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ccd:	83 ec 0c             	sub    $0xc,%esp
f0101cd0:	6a 00                	push   $0x0
f0101cd2:	e8 0d f3 ff ff       	call   f0100fe4 <page_alloc>
f0101cd7:	89 c6                	mov    %eax,%esi
f0101cd9:	83 c4 10             	add    $0x10,%esp
f0101cdc:	85 c0                	test   %eax,%eax
f0101cde:	75 19                	jne    f0101cf9 <mem_init+0x5ec>
f0101ce0:	68 1c 66 10 f0       	push   $0xf010661c
f0101ce5:	68 33 65 10 f0       	push   $0xf0106533
f0101cea:	68 f2 03 00 00       	push   $0x3f2
f0101cef:	68 0d 65 10 f0       	push   $0xf010650d
f0101cf4:	e8 ac e3 ff ff       	call   f01000a5 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cf9:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0101cfc:	75 19                	jne    f0101d17 <mem_init+0x60a>
f0101cfe:	68 32 66 10 f0       	push   $0xf0106632
f0101d03:	68 33 65 10 f0       	push   $0xf0106533
f0101d08:	68 f5 03 00 00       	push   $0x3f5
f0101d0d:	68 0d 65 10 f0       	push   $0xf010650d
f0101d12:	e8 8e e3 ff ff       	call   f01000a5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d17:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101d1a:	74 04                	je     f0101d20 <mem_init+0x613>
f0101d1c:	39 c3                	cmp    %eax,%ebx
f0101d1e:	75 19                	jne    f0101d39 <mem_init+0x62c>
f0101d20:	68 00 5f 10 f0       	push   $0xf0105f00
f0101d25:	68 33 65 10 f0       	push   $0xf0106533
f0101d2a:	68 f6 03 00 00       	push   $0x3f6
f0101d2f:	68 0d 65 10 f0       	push   $0xf010650d
f0101d34:	e8 6c e3 ff ff       	call   f01000a5 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d39:	a1 e4 e1 19 f0       	mov    0xf019e1e4,%eax
f0101d3e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101d41:	c7 05 e4 e1 19 f0 00 	movl   $0x0,0xf019e1e4
f0101d48:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d4b:	83 ec 0c             	sub    $0xc,%esp
f0101d4e:	6a 00                	push   $0x0
f0101d50:	e8 8f f2 ff ff       	call   f0100fe4 <page_alloc>
f0101d55:	83 c4 10             	add    $0x10,%esp
f0101d58:	85 c0                	test   %eax,%eax
f0101d5a:	74 19                	je     f0101d75 <mem_init+0x668>
f0101d5c:	68 9b 66 10 f0       	push   $0xf010669b
f0101d61:	68 33 65 10 f0       	push   $0xf0106533
f0101d66:	68 fd 03 00 00       	push   $0x3fd
f0101d6b:	68 0d 65 10 f0       	push   $0xf010650d
f0101d70:	e8 30 e3 ff ff       	call   f01000a5 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d75:	83 ec 04             	sub    $0x4,%esp
f0101d78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d7b:	50                   	push   %eax
f0101d7c:	6a 00                	push   $0x0
f0101d7e:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0101d84:	e8 59 f8 ff ff       	call   f01015e2 <page_lookup>
f0101d89:	83 c4 10             	add    $0x10,%esp
f0101d8c:	85 c0                	test   %eax,%eax
f0101d8e:	74 19                	je     f0101da9 <mem_init+0x69c>
f0101d90:	68 40 5f 10 f0       	push   $0xf0105f40
f0101d95:	68 33 65 10 f0       	push   $0xf0106533
f0101d9a:	68 00 04 00 00       	push   $0x400
f0101d9f:	68 0d 65 10 f0       	push   $0xf010650d
f0101da4:	e8 fc e2 ff ff       	call   f01000a5 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101da9:	6a 02                	push   $0x2
f0101dab:	6a 00                	push   $0x0
f0101dad:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101db0:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0101db6:	e8 c8 f8 ff ff       	call   f0101683 <page_insert>
f0101dbb:	83 c4 10             	add    $0x10,%esp
f0101dbe:	85 c0                	test   %eax,%eax
f0101dc0:	78 19                	js     f0101ddb <mem_init+0x6ce>
f0101dc2:	68 78 5f 10 f0       	push   $0xf0105f78
f0101dc7:	68 33 65 10 f0       	push   $0xf0106533
f0101dcc:	68 03 04 00 00       	push   $0x403
f0101dd1:	68 0d 65 10 f0       	push   $0xf010650d
f0101dd6:	e8 ca e2 ff ff       	call   f01000a5 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ddb:	83 ec 0c             	sub    $0xc,%esp
f0101dde:	53                   	push   %ebx
f0101ddf:	e8 71 f4 ff ff       	call   f0101255 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101de4:	6a 02                	push   $0x2
f0101de6:	6a 00                	push   $0x0
f0101de8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101deb:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0101df1:	e8 8d f8 ff ff       	call   f0101683 <page_insert>
f0101df6:	83 c4 20             	add    $0x20,%esp
f0101df9:	85 c0                	test   %eax,%eax
f0101dfb:	74 19                	je     f0101e16 <mem_init+0x709>
f0101dfd:	68 a8 5f 10 f0       	push   $0xf0105fa8
f0101e02:	68 33 65 10 f0       	push   $0xf0106533
f0101e07:	68 07 04 00 00       	push   $0x407
f0101e0c:	68 0d 65 10 f0       	push   $0xf010650d
f0101e11:	e8 8f e2 ff ff       	call   f01000a5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e16:	8b 3d a8 ee 19 f0    	mov    0xf019eea8,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e1c:	a1 ac ee 19 f0       	mov    0xf019eeac,%eax
f0101e21:	89 c1                	mov    %eax,%ecx
f0101e23:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e26:	8b 17                	mov    (%edi),%edx
f0101e28:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e2e:	89 d8                	mov    %ebx,%eax
f0101e30:	29 c8                	sub    %ecx,%eax
f0101e32:	c1 f8 03             	sar    $0x3,%eax
f0101e35:	c1 e0 0c             	shl    $0xc,%eax
f0101e38:	39 c2                	cmp    %eax,%edx
f0101e3a:	74 19                	je     f0101e55 <mem_init+0x748>
f0101e3c:	68 d8 5f 10 f0       	push   $0xf0105fd8
f0101e41:	68 33 65 10 f0       	push   $0xf0106533
f0101e46:	68 08 04 00 00       	push   $0x408
f0101e4b:	68 0d 65 10 f0       	push   $0xf010650d
f0101e50:	e8 50 e2 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e55:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e5a:	89 f8                	mov    %edi,%eax
f0101e5c:	e8 f8 ec ff ff       	call   f0100b59 <check_va2pa>
f0101e61:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101e64:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101e67:	c1 fa 03             	sar    $0x3,%edx
f0101e6a:	c1 e2 0c             	shl    $0xc,%edx
f0101e6d:	39 d0                	cmp    %edx,%eax
f0101e6f:	74 19                	je     f0101e8a <mem_init+0x77d>
f0101e71:	68 00 60 10 f0       	push   $0xf0106000
f0101e76:	68 33 65 10 f0       	push   $0xf0106533
f0101e7b:	68 09 04 00 00       	push   $0x409
f0101e80:	68 0d 65 10 f0       	push   $0xf010650d
f0101e85:	e8 1b e2 ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 1);
f0101e8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e8d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e92:	74 19                	je     f0101ead <mem_init+0x7a0>
f0101e94:	68 ed 66 10 f0       	push   $0xf01066ed
f0101e99:	68 33 65 10 f0       	push   $0xf0106533
f0101e9e:	68 0a 04 00 00       	push   $0x40a
f0101ea3:	68 0d 65 10 f0       	push   $0xf010650d
f0101ea8:	e8 f8 e1 ff ff       	call   f01000a5 <_panic>
	assert(pp0->pp_ref == 1);
f0101ead:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101eb2:	74 19                	je     f0101ecd <mem_init+0x7c0>
f0101eb4:	68 fe 66 10 f0       	push   $0xf01066fe
f0101eb9:	68 33 65 10 f0       	push   $0xf0106533
f0101ebe:	68 0b 04 00 00       	push   $0x40b
f0101ec3:	68 0d 65 10 f0       	push   $0xf010650d
f0101ec8:	e8 d8 e1 ff ff       	call   f01000a5 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ecd:	6a 02                	push   $0x2
f0101ecf:	68 00 10 00 00       	push   $0x1000
f0101ed4:	56                   	push   %esi
f0101ed5:	57                   	push   %edi
f0101ed6:	e8 a8 f7 ff ff       	call   f0101683 <page_insert>
f0101edb:	83 c4 10             	add    $0x10,%esp
f0101ede:	85 c0                	test   %eax,%eax
f0101ee0:	74 19                	je     f0101efb <mem_init+0x7ee>
f0101ee2:	68 30 60 10 f0       	push   $0xf0106030
f0101ee7:	68 33 65 10 f0       	push   $0xf0106533
f0101eec:	68 0e 04 00 00       	push   $0x40e
f0101ef1:	68 0d 65 10 f0       	push   $0xf010650d
f0101ef6:	e8 aa e1 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101efb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f00:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0101f05:	e8 4f ec ff ff       	call   f0100b59 <check_va2pa>
f0101f0a:	89 f2                	mov    %esi,%edx
f0101f0c:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f0101f12:	c1 fa 03             	sar    $0x3,%edx
f0101f15:	c1 e2 0c             	shl    $0xc,%edx
f0101f18:	39 d0                	cmp    %edx,%eax
f0101f1a:	74 19                	je     f0101f35 <mem_init+0x828>
f0101f1c:	68 6c 60 10 f0       	push   $0xf010606c
f0101f21:	68 33 65 10 f0       	push   $0xf0106533
f0101f26:	68 0f 04 00 00       	push   $0x40f
f0101f2b:	68 0d 65 10 f0       	push   $0xf010650d
f0101f30:	e8 70 e1 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0101f35:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f3a:	74 19                	je     f0101f55 <mem_init+0x848>
f0101f3c:	68 0f 67 10 f0       	push   $0xf010670f
f0101f41:	68 33 65 10 f0       	push   $0xf0106533
f0101f46:	68 10 04 00 00       	push   $0x410
f0101f4b:	68 0d 65 10 f0       	push   $0xf010650d
f0101f50:	e8 50 e1 ff ff       	call   f01000a5 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f55:	83 ec 0c             	sub    $0xc,%esp
f0101f58:	6a 00                	push   $0x0
f0101f5a:	e8 85 f0 ff ff       	call   f0100fe4 <page_alloc>
f0101f5f:	83 c4 10             	add    $0x10,%esp
f0101f62:	85 c0                	test   %eax,%eax
f0101f64:	74 19                	je     f0101f7f <mem_init+0x872>
f0101f66:	68 9b 66 10 f0       	push   $0xf010669b
f0101f6b:	68 33 65 10 f0       	push   $0xf0106533
f0101f70:	68 13 04 00 00       	push   $0x413
f0101f75:	68 0d 65 10 f0       	push   $0xf010650d
f0101f7a:	e8 26 e1 ff ff       	call   f01000a5 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f7f:	6a 02                	push   $0x2
f0101f81:	68 00 10 00 00       	push   $0x1000
f0101f86:	56                   	push   %esi
f0101f87:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0101f8d:	e8 f1 f6 ff ff       	call   f0101683 <page_insert>
f0101f92:	83 c4 10             	add    $0x10,%esp
f0101f95:	85 c0                	test   %eax,%eax
f0101f97:	74 19                	je     f0101fb2 <mem_init+0x8a5>
f0101f99:	68 30 60 10 f0       	push   $0xf0106030
f0101f9e:	68 33 65 10 f0       	push   $0xf0106533
f0101fa3:	68 16 04 00 00       	push   $0x416
f0101fa8:	68 0d 65 10 f0       	push   $0xf010650d
f0101fad:	e8 f3 e0 ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fb2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fb7:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0101fbc:	e8 98 eb ff ff       	call   f0100b59 <check_va2pa>
f0101fc1:	89 f2                	mov    %esi,%edx
f0101fc3:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f0101fc9:	c1 fa 03             	sar    $0x3,%edx
f0101fcc:	c1 e2 0c             	shl    $0xc,%edx
f0101fcf:	39 d0                	cmp    %edx,%eax
f0101fd1:	74 19                	je     f0101fec <mem_init+0x8df>
f0101fd3:	68 6c 60 10 f0       	push   $0xf010606c
f0101fd8:	68 33 65 10 f0       	push   $0xf0106533
f0101fdd:	68 17 04 00 00       	push   $0x417
f0101fe2:	68 0d 65 10 f0       	push   $0xf010650d
f0101fe7:	e8 b9 e0 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0101fec:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ff1:	74 19                	je     f010200c <mem_init+0x8ff>
f0101ff3:	68 0f 67 10 f0       	push   $0xf010670f
f0101ff8:	68 33 65 10 f0       	push   $0xf0106533
f0101ffd:	68 18 04 00 00       	push   $0x418
f0102002:	68 0d 65 10 f0       	push   $0xf010650d
f0102007:	e8 99 e0 ff ff       	call   f01000a5 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010200c:	83 ec 0c             	sub    $0xc,%esp
f010200f:	6a 00                	push   $0x0
f0102011:	e8 ce ef ff ff       	call   f0100fe4 <page_alloc>
f0102016:	83 c4 10             	add    $0x10,%esp
f0102019:	85 c0                	test   %eax,%eax
f010201b:	74 19                	je     f0102036 <mem_init+0x929>
f010201d:	68 9b 66 10 f0       	push   $0xf010669b
f0102022:	68 33 65 10 f0       	push   $0xf0106533
f0102027:	68 1c 04 00 00       	push   $0x41c
f010202c:	68 0d 65 10 f0       	push   $0xf010650d
f0102031:	e8 6f e0 ff ff       	call   f01000a5 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102036:	8b 15 a8 ee 19 f0    	mov    0xf019eea8,%edx
f010203c:	8b 02                	mov    (%edx),%eax
f010203e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102043:	89 c1                	mov    %eax,%ecx
f0102045:	c1 e9 0c             	shr    $0xc,%ecx
f0102048:	3b 0d a4 ee 19 f0    	cmp    0xf019eea4,%ecx
f010204e:	72 15                	jb     f0102065 <mem_init+0x958>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102050:	50                   	push   %eax
f0102051:	68 74 5d 10 f0       	push   $0xf0105d74
f0102056:	68 1f 04 00 00       	push   $0x41f
f010205b:	68 0d 65 10 f0       	push   $0xf010650d
f0102060:	e8 40 e0 ff ff       	call   f01000a5 <_panic>
f0102065:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010206a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010206d:	83 ec 04             	sub    $0x4,%esp
f0102070:	6a 00                	push   $0x0
f0102072:	68 00 10 00 00       	push   $0x1000
f0102077:	52                   	push   %edx
f0102078:	e8 1a f4 ff ff       	call   f0101497 <pgdir_walk>
f010207d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102080:	8d 57 04             	lea    0x4(%edi),%edx
f0102083:	83 c4 10             	add    $0x10,%esp
f0102086:	39 d0                	cmp    %edx,%eax
f0102088:	74 19                	je     f01020a3 <mem_init+0x996>
f010208a:	68 9c 60 10 f0       	push   $0xf010609c
f010208f:	68 33 65 10 f0       	push   $0xf0106533
f0102094:	68 20 04 00 00       	push   $0x420
f0102099:	68 0d 65 10 f0       	push   $0xf010650d
f010209e:	e8 02 e0 ff ff       	call   f01000a5 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01020a3:	6a 06                	push   $0x6
f01020a5:	68 00 10 00 00       	push   $0x1000
f01020aa:	56                   	push   %esi
f01020ab:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f01020b1:	e8 cd f5 ff ff       	call   f0101683 <page_insert>
f01020b6:	83 c4 10             	add    $0x10,%esp
f01020b9:	85 c0                	test   %eax,%eax
f01020bb:	74 19                	je     f01020d6 <mem_init+0x9c9>
f01020bd:	68 dc 60 10 f0       	push   $0xf01060dc
f01020c2:	68 33 65 10 f0       	push   $0xf0106533
f01020c7:	68 23 04 00 00       	push   $0x423
f01020cc:	68 0d 65 10 f0       	push   $0xf010650d
f01020d1:	e8 cf df ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020d6:	8b 3d a8 ee 19 f0    	mov    0xf019eea8,%edi
f01020dc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020e1:	89 f8                	mov    %edi,%eax
f01020e3:	e8 71 ea ff ff       	call   f0100b59 <check_va2pa>
f01020e8:	89 f2                	mov    %esi,%edx
f01020ea:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f01020f0:	c1 fa 03             	sar    $0x3,%edx
f01020f3:	c1 e2 0c             	shl    $0xc,%edx
f01020f6:	39 d0                	cmp    %edx,%eax
f01020f8:	74 19                	je     f0102113 <mem_init+0xa06>
f01020fa:	68 6c 60 10 f0       	push   $0xf010606c
f01020ff:	68 33 65 10 f0       	push   $0xf0106533
f0102104:	68 24 04 00 00       	push   $0x424
f0102109:	68 0d 65 10 f0       	push   $0xf010650d
f010210e:	e8 92 df ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0102113:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102118:	74 19                	je     f0102133 <mem_init+0xa26>
f010211a:	68 0f 67 10 f0       	push   $0xf010670f
f010211f:	68 33 65 10 f0       	push   $0xf0106533
f0102124:	68 25 04 00 00       	push   $0x425
f0102129:	68 0d 65 10 f0       	push   $0xf010650d
f010212e:	e8 72 df ff ff       	call   f01000a5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102133:	83 ec 04             	sub    $0x4,%esp
f0102136:	6a 00                	push   $0x0
f0102138:	68 00 10 00 00       	push   $0x1000
f010213d:	57                   	push   %edi
f010213e:	e8 54 f3 ff ff       	call   f0101497 <pgdir_walk>
f0102143:	83 c4 10             	add    $0x10,%esp
f0102146:	f6 00 04             	testb  $0x4,(%eax)
f0102149:	75 19                	jne    f0102164 <mem_init+0xa57>
f010214b:	68 1c 61 10 f0       	push   $0xf010611c
f0102150:	68 33 65 10 f0       	push   $0xf0106533
f0102155:	68 26 04 00 00       	push   $0x426
f010215a:	68 0d 65 10 f0       	push   $0xf010650d
f010215f:	e8 41 df ff ff       	call   f01000a5 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102164:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0102169:	f6 00 04             	testb  $0x4,(%eax)
f010216c:	75 19                	jne    f0102187 <mem_init+0xa7a>
f010216e:	68 20 67 10 f0       	push   $0xf0106720
f0102173:	68 33 65 10 f0       	push   $0xf0106533
f0102178:	68 27 04 00 00       	push   $0x427
f010217d:	68 0d 65 10 f0       	push   $0xf010650d
f0102182:	e8 1e df ff ff       	call   f01000a5 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102187:	6a 02                	push   $0x2
f0102189:	68 00 00 40 00       	push   $0x400000
f010218e:	53                   	push   %ebx
f010218f:	50                   	push   %eax
f0102190:	e8 ee f4 ff ff       	call   f0101683 <page_insert>
f0102195:	83 c4 10             	add    $0x10,%esp
f0102198:	85 c0                	test   %eax,%eax
f010219a:	78 19                	js     f01021b5 <mem_init+0xaa8>
f010219c:	68 50 61 10 f0       	push   $0xf0106150
f01021a1:	68 33 65 10 f0       	push   $0xf0106533
f01021a6:	68 2a 04 00 00       	push   $0x42a
f01021ab:	68 0d 65 10 f0       	push   $0xf010650d
f01021b0:	e8 f0 de ff ff       	call   f01000a5 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021b5:	6a 02                	push   $0x2
f01021b7:	68 00 10 00 00       	push   $0x1000
f01021bc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01021bf:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f01021c5:	e8 b9 f4 ff ff       	call   f0101683 <page_insert>
f01021ca:	83 c4 10             	add    $0x10,%esp
f01021cd:	85 c0                	test   %eax,%eax
f01021cf:	74 19                	je     f01021ea <mem_init+0xadd>
f01021d1:	68 88 61 10 f0       	push   $0xf0106188
f01021d6:	68 33 65 10 f0       	push   $0xf0106533
f01021db:	68 2d 04 00 00       	push   $0x42d
f01021e0:	68 0d 65 10 f0       	push   $0xf010650d
f01021e5:	e8 bb de ff ff       	call   f01000a5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021ea:	83 ec 04             	sub    $0x4,%esp
f01021ed:	6a 00                	push   $0x0
f01021ef:	68 00 10 00 00       	push   $0x1000
f01021f4:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f01021fa:	e8 98 f2 ff ff       	call   f0101497 <pgdir_walk>
f01021ff:	83 c4 10             	add    $0x10,%esp
f0102202:	f6 00 04             	testb  $0x4,(%eax)
f0102205:	74 19                	je     f0102220 <mem_init+0xb13>
f0102207:	68 c4 61 10 f0       	push   $0xf01061c4
f010220c:	68 33 65 10 f0       	push   $0xf0106533
f0102211:	68 2e 04 00 00       	push   $0x42e
f0102216:	68 0d 65 10 f0       	push   $0xf010650d
f010221b:	e8 85 de ff ff       	call   f01000a5 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102220:	8b 3d a8 ee 19 f0    	mov    0xf019eea8,%edi
f0102226:	ba 00 00 00 00       	mov    $0x0,%edx
f010222b:	89 f8                	mov    %edi,%eax
f010222d:	e8 27 e9 ff ff       	call   f0100b59 <check_va2pa>
f0102232:	89 c1                	mov    %eax,%ecx
f0102234:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102237:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010223a:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0102240:	c1 f8 03             	sar    $0x3,%eax
f0102243:	c1 e0 0c             	shl    $0xc,%eax
f0102246:	39 c1                	cmp    %eax,%ecx
f0102248:	74 19                	je     f0102263 <mem_init+0xb56>
f010224a:	68 fc 61 10 f0       	push   $0xf01061fc
f010224f:	68 33 65 10 f0       	push   $0xf0106533
f0102254:	68 31 04 00 00       	push   $0x431
f0102259:	68 0d 65 10 f0       	push   $0xf010650d
f010225e:	e8 42 de ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102263:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102268:	89 f8                	mov    %edi,%eax
f010226a:	e8 ea e8 ff ff       	call   f0100b59 <check_va2pa>
f010226f:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102272:	74 19                	je     f010228d <mem_init+0xb80>
f0102274:	68 28 62 10 f0       	push   $0xf0106228
f0102279:	68 33 65 10 f0       	push   $0xf0106533
f010227e:	68 32 04 00 00       	push   $0x432
f0102283:	68 0d 65 10 f0       	push   $0xf010650d
f0102288:	e8 18 de ff ff       	call   f01000a5 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010228d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102290:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0102295:	74 19                	je     f01022b0 <mem_init+0xba3>
f0102297:	68 36 67 10 f0       	push   $0xf0106736
f010229c:	68 33 65 10 f0       	push   $0xf0106533
f01022a1:	68 34 04 00 00       	push   $0x434
f01022a6:	68 0d 65 10 f0       	push   $0xf010650d
f01022ab:	e8 f5 dd ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f01022b0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022b5:	74 19                	je     f01022d0 <mem_init+0xbc3>
f01022b7:	68 47 67 10 f0       	push   $0xf0106747
f01022bc:	68 33 65 10 f0       	push   $0xf0106533
f01022c1:	68 35 04 00 00       	push   $0x435
f01022c6:	68 0d 65 10 f0       	push   $0xf010650d
f01022cb:	e8 d5 dd ff ff       	call   f01000a5 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022d0:	83 ec 0c             	sub    $0xc,%esp
f01022d3:	6a 00                	push   $0x0
f01022d5:	e8 0a ed ff ff       	call   f0100fe4 <page_alloc>
f01022da:	83 c4 10             	add    $0x10,%esp
f01022dd:	85 c0                	test   %eax,%eax
f01022df:	74 04                	je     f01022e5 <mem_init+0xbd8>
f01022e1:	39 c6                	cmp    %eax,%esi
f01022e3:	74 19                	je     f01022fe <mem_init+0xbf1>
f01022e5:	68 58 62 10 f0       	push   $0xf0106258
f01022ea:	68 33 65 10 f0       	push   $0xf0106533
f01022ef:	68 38 04 00 00       	push   $0x438
f01022f4:	68 0d 65 10 f0       	push   $0xf010650d
f01022f9:	e8 a7 dd ff ff       	call   f01000a5 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01022fe:	83 ec 08             	sub    $0x8,%esp
f0102301:	6a 00                	push   $0x0
f0102303:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0102309:	e8 3a f3 ff ff       	call   f0101648 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010230e:	8b 3d a8 ee 19 f0    	mov    0xf019eea8,%edi
f0102314:	ba 00 00 00 00       	mov    $0x0,%edx
f0102319:	89 f8                	mov    %edi,%eax
f010231b:	e8 39 e8 ff ff       	call   f0100b59 <check_va2pa>
f0102320:	83 c4 10             	add    $0x10,%esp
f0102323:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102326:	74 19                	je     f0102341 <mem_init+0xc34>
f0102328:	68 7c 62 10 f0       	push   $0xf010627c
f010232d:	68 33 65 10 f0       	push   $0xf0106533
f0102332:	68 3c 04 00 00       	push   $0x43c
f0102337:	68 0d 65 10 f0       	push   $0xf010650d
f010233c:	e8 64 dd ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102341:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102346:	89 f8                	mov    %edi,%eax
f0102348:	e8 0c e8 ff ff       	call   f0100b59 <check_va2pa>
f010234d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102350:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f0102356:	c1 fa 03             	sar    $0x3,%edx
f0102359:	c1 e2 0c             	shl    $0xc,%edx
f010235c:	39 d0                	cmp    %edx,%eax
f010235e:	74 19                	je     f0102379 <mem_init+0xc6c>
f0102360:	68 28 62 10 f0       	push   $0xf0106228
f0102365:	68 33 65 10 f0       	push   $0xf0106533
f010236a:	68 3d 04 00 00       	push   $0x43d
f010236f:	68 0d 65 10 f0       	push   $0xf010650d
f0102374:	e8 2c dd ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 1);
f0102379:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010237c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102381:	74 19                	je     f010239c <mem_init+0xc8f>
f0102383:	68 ed 66 10 f0       	push   $0xf01066ed
f0102388:	68 33 65 10 f0       	push   $0xf0106533
f010238d:	68 3e 04 00 00       	push   $0x43e
f0102392:	68 0d 65 10 f0       	push   $0xf010650d
f0102397:	e8 09 dd ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f010239c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01023a1:	74 19                	je     f01023bc <mem_init+0xcaf>
f01023a3:	68 47 67 10 f0       	push   $0xf0106747
f01023a8:	68 33 65 10 f0       	push   $0xf0106533
f01023ad:	68 3f 04 00 00       	push   $0x43f
f01023b2:	68 0d 65 10 f0       	push   $0xf010650d
f01023b7:	e8 e9 dc ff ff       	call   f01000a5 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023bc:	83 ec 08             	sub    $0x8,%esp
f01023bf:	68 00 10 00 00       	push   $0x1000
f01023c4:	57                   	push   %edi
f01023c5:	e8 7e f2 ff ff       	call   f0101648 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023ca:	8b 3d a8 ee 19 f0    	mov    0xf019eea8,%edi
f01023d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01023d5:	89 f8                	mov    %edi,%eax
f01023d7:	e8 7d e7 ff ff       	call   f0100b59 <check_va2pa>
f01023dc:	83 c4 10             	add    $0x10,%esp
f01023df:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023e2:	74 19                	je     f01023fd <mem_init+0xcf0>
f01023e4:	68 7c 62 10 f0       	push   $0xf010627c
f01023e9:	68 33 65 10 f0       	push   $0xf0106533
f01023ee:	68 43 04 00 00       	push   $0x443
f01023f3:	68 0d 65 10 f0       	push   $0xf010650d
f01023f8:	e8 a8 dc ff ff       	call   f01000a5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01023fd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102402:	89 f8                	mov    %edi,%eax
f0102404:	e8 50 e7 ff ff       	call   f0100b59 <check_va2pa>
f0102409:	83 f8 ff             	cmp    $0xffffffff,%eax
f010240c:	74 19                	je     f0102427 <mem_init+0xd1a>
f010240e:	68 a0 62 10 f0       	push   $0xf01062a0
f0102413:	68 33 65 10 f0       	push   $0xf0106533
f0102418:	68 44 04 00 00       	push   $0x444
f010241d:	68 0d 65 10 f0       	push   $0xf010650d
f0102422:	e8 7e dc ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 0);
f0102427:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010242a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010242f:	74 19                	je     f010244a <mem_init+0xd3d>
f0102431:	68 58 67 10 f0       	push   $0xf0106758
f0102436:	68 33 65 10 f0       	push   $0xf0106533
f010243b:	68 45 04 00 00       	push   $0x445
f0102440:	68 0d 65 10 f0       	push   $0xf010650d
f0102445:	e8 5b dc ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 0);
f010244a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010244f:	74 19                	je     f010246a <mem_init+0xd5d>
f0102451:	68 47 67 10 f0       	push   $0xf0106747
f0102456:	68 33 65 10 f0       	push   $0xf0106533
f010245b:	68 46 04 00 00       	push   $0x446
f0102460:	68 0d 65 10 f0       	push   $0xf010650d
f0102465:	e8 3b dc ff ff       	call   f01000a5 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010246a:	83 ec 0c             	sub    $0xc,%esp
f010246d:	6a 00                	push   $0x0
f010246f:	e8 70 eb ff ff       	call   f0100fe4 <page_alloc>
f0102474:	83 c4 10             	add    $0x10,%esp
f0102477:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010247a:	75 04                	jne    f0102480 <mem_init+0xd73>
f010247c:	85 c0                	test   %eax,%eax
f010247e:	75 19                	jne    f0102499 <mem_init+0xd8c>
f0102480:	68 c8 62 10 f0       	push   $0xf01062c8
f0102485:	68 33 65 10 f0       	push   $0xf0106533
f010248a:	68 49 04 00 00       	push   $0x449
f010248f:	68 0d 65 10 f0       	push   $0xf010650d
f0102494:	e8 0c dc ff ff       	call   f01000a5 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102499:	83 ec 0c             	sub    $0xc,%esp
f010249c:	6a 00                	push   $0x0
f010249e:	e8 41 eb ff ff       	call   f0100fe4 <page_alloc>
f01024a3:	83 c4 10             	add    $0x10,%esp
f01024a6:	85 c0                	test   %eax,%eax
f01024a8:	74 19                	je     f01024c3 <mem_init+0xdb6>
f01024aa:	68 9b 66 10 f0       	push   $0xf010669b
f01024af:	68 33 65 10 f0       	push   $0xf0106533
f01024b4:	68 4c 04 00 00       	push   $0x44c
f01024b9:	68 0d 65 10 f0       	push   $0xf010650d
f01024be:	e8 e2 db ff ff       	call   f01000a5 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024c3:	8b 0d a8 ee 19 f0    	mov    0xf019eea8,%ecx
f01024c9:	8b 11                	mov    (%ecx),%edx
f01024cb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01024d1:	89 d8                	mov    %ebx,%eax
f01024d3:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f01024d9:	c1 f8 03             	sar    $0x3,%eax
f01024dc:	c1 e0 0c             	shl    $0xc,%eax
f01024df:	39 c2                	cmp    %eax,%edx
f01024e1:	74 19                	je     f01024fc <mem_init+0xdef>
f01024e3:	68 d8 5f 10 f0       	push   $0xf0105fd8
f01024e8:	68 33 65 10 f0       	push   $0xf0106533
f01024ed:	68 4f 04 00 00       	push   $0x44f
f01024f2:	68 0d 65 10 f0       	push   $0xf010650d
f01024f7:	e8 a9 db ff ff       	call   f01000a5 <_panic>
	kern_pgdir[0] = 0;
f01024fc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102502:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102507:	74 19                	je     f0102522 <mem_init+0xe15>
f0102509:	68 fe 66 10 f0       	push   $0xf01066fe
f010250e:	68 33 65 10 f0       	push   $0xf0106533
f0102513:	68 51 04 00 00       	push   $0x451
f0102518:	68 0d 65 10 f0       	push   $0xf010650d
f010251d:	e8 83 db ff ff       	call   f01000a5 <_panic>
	pp0->pp_ref = 0;
f0102522:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102528:	83 ec 0c             	sub    $0xc,%esp
f010252b:	53                   	push   %ebx
f010252c:	e8 24 ed ff ff       	call   f0101255 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102531:	83 c4 0c             	add    $0xc,%esp
f0102534:	6a 01                	push   $0x1
f0102536:	68 00 10 40 00       	push   $0x401000
f010253b:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0102541:	e8 51 ef ff ff       	call   f0101497 <pgdir_walk>
f0102546:	89 c7                	mov    %eax,%edi
f0102548:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010254b:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0102550:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102553:	8b 40 04             	mov    0x4(%eax),%eax
f0102556:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010255b:	8b 0d a4 ee 19 f0    	mov    0xf019eea4,%ecx
f0102561:	89 c2                	mov    %eax,%edx
f0102563:	c1 ea 0c             	shr    $0xc,%edx
f0102566:	83 c4 10             	add    $0x10,%esp
f0102569:	39 ca                	cmp    %ecx,%edx
f010256b:	72 15                	jb     f0102582 <mem_init+0xe75>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010256d:	50                   	push   %eax
f010256e:	68 74 5d 10 f0       	push   $0xf0105d74
f0102573:	68 58 04 00 00       	push   $0x458
f0102578:	68 0d 65 10 f0       	push   $0xf010650d
f010257d:	e8 23 db ff ff       	call   f01000a5 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102582:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102587:	39 c7                	cmp    %eax,%edi
f0102589:	74 19                	je     f01025a4 <mem_init+0xe97>
f010258b:	68 69 67 10 f0       	push   $0xf0106769
f0102590:	68 33 65 10 f0       	push   $0xf0106533
f0102595:	68 59 04 00 00       	push   $0x459
f010259a:	68 0d 65 10 f0       	push   $0xf010650d
f010259f:	e8 01 db ff ff       	call   f01000a5 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01025a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01025a7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01025ae:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01025b4:	89 d8                	mov    %ebx,%eax
f01025b6:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f01025bc:	c1 f8 03             	sar    $0x3,%eax
f01025bf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025c2:	89 c2                	mov    %eax,%edx
f01025c4:	c1 ea 0c             	shr    $0xc,%edx
f01025c7:	39 d1                	cmp    %edx,%ecx
f01025c9:	77 12                	ja     f01025dd <mem_init+0xed0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025cb:	50                   	push   %eax
f01025cc:	68 74 5d 10 f0       	push   $0xf0105d74
f01025d1:	6a 56                	push   $0x56
f01025d3:	68 19 65 10 f0       	push   $0xf0106519
f01025d8:	e8 c8 da ff ff       	call   f01000a5 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01025dd:	83 ec 04             	sub    $0x4,%esp
f01025e0:	68 00 10 00 00       	push   $0x1000
f01025e5:	68 ff 00 00 00       	push   $0xff
f01025ea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025ef:	50                   	push   %eax
f01025f0:	e8 6f 2c 00 00       	call   f0105264 <memset>
	page_free(pp0);
f01025f5:	89 1c 24             	mov    %ebx,(%esp)
f01025f8:	e8 58 ec ff ff       	call   f0101255 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01025fd:	83 c4 0c             	add    $0xc,%esp
f0102600:	6a 01                	push   $0x1
f0102602:	6a 00                	push   $0x0
f0102604:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f010260a:	e8 88 ee ff ff       	call   f0101497 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010260f:	89 da                	mov    %ebx,%edx
f0102611:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f0102617:	c1 fa 03             	sar    $0x3,%edx
f010261a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010261d:	89 d0                	mov    %edx,%eax
f010261f:	c1 e8 0c             	shr    $0xc,%eax
f0102622:	83 c4 10             	add    $0x10,%esp
f0102625:	3b 05 a4 ee 19 f0    	cmp    0xf019eea4,%eax
f010262b:	72 12                	jb     f010263f <mem_init+0xf32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010262d:	52                   	push   %edx
f010262e:	68 74 5d 10 f0       	push   $0xf0105d74
f0102633:	6a 56                	push   $0x56
f0102635:	68 19 65 10 f0       	push   $0xf0106519
f010263a:	e8 66 da ff ff       	call   f01000a5 <_panic>
	return (void *)(pa + KERNBASE);
f010263f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102645:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102648:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f010264f:	75 11                	jne    f0102662 <mem_init+0xf55>
f0102651:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0102657:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f010265d:	f6 00 01             	testb  $0x1,(%eax)
f0102660:	74 19                	je     f010267b <mem_init+0xf6e>
f0102662:	68 81 67 10 f0       	push   $0xf0106781
f0102667:	68 33 65 10 f0       	push   $0xf0106533
f010266c:	68 63 04 00 00       	push   $0x463
f0102671:	68 0d 65 10 f0       	push   $0xf010650d
f0102676:	e8 2a da ff ff       	call   f01000a5 <_panic>
f010267b:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010267e:	39 c2                	cmp    %eax,%edx
f0102680:	75 db                	jne    f010265d <mem_init+0xf50>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102682:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0102687:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010268d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f0102693:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102696:	a3 e4 e1 19 f0       	mov    %eax,0xf019e1e4

	// free the pages we took
	page_free(pp0);
f010269b:	83 ec 0c             	sub    $0xc,%esp
f010269e:	53                   	push   %ebx
f010269f:	e8 b1 eb ff ff       	call   f0101255 <page_free>
	page_free(pp1);
f01026a4:	83 c4 04             	add    $0x4,%esp
f01026a7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01026aa:	e8 a6 eb ff ff       	call   f0101255 <page_free>
	page_free(pp2);
f01026af:	89 34 24             	mov    %esi,(%esp)
f01026b2:	e8 9e eb ff ff       	call   f0101255 <page_free>

	cprintf("check_page() succeeded!\n");
f01026b7:	c7 04 24 98 67 10 f0 	movl   $0xf0106798,(%esp)
f01026be:	e8 dc 12 00 00       	call   f010399f <cprintf>
	char* addr;
	int i;
	pp = pp0 = 0;

	// Allocate two single pages
	pp =  page_alloc(0);
f01026c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026ca:	e8 15 e9 ff ff       	call   f0100fe4 <page_alloc>
f01026cf:	89 c3                	mov    %eax,%ebx
	pp0 = page_alloc(0);
f01026d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026d8:	e8 07 e9 ff ff       	call   f0100fe4 <page_alloc>
f01026dd:	89 c6                	mov    %eax,%esi
	assert(pp != 0);
f01026df:	83 c4 10             	add    $0x10,%esp
f01026e2:	85 db                	test   %ebx,%ebx
f01026e4:	75 19                	jne    f01026ff <mem_init+0xff2>
f01026e6:	68 b1 67 10 f0       	push   $0xf01067b1
f01026eb:	68 33 65 10 f0       	push   $0xf0106533
f01026f0:	68 90 04 00 00       	push   $0x490
f01026f5:	68 0d 65 10 f0       	push   $0xf010650d
f01026fa:	e8 a6 d9 ff ff       	call   f01000a5 <_panic>
	assert(pp0 != 0);
f01026ff:	85 c0                	test   %eax,%eax
f0102701:	75 19                	jne    f010271c <mem_init+0x100f>
f0102703:	68 b9 67 10 f0       	push   $0xf01067b9
f0102708:	68 33 65 10 f0       	push   $0xf0106533
f010270d:	68 91 04 00 00       	push   $0x491
f0102712:	68 0d 65 10 f0       	push   $0xf010650d
f0102717:	e8 89 d9 ff ff       	call   f01000a5 <_panic>
	assert(pp != pp0);
f010271c:	39 c3                	cmp    %eax,%ebx
f010271e:	75 19                	jne    f0102739 <mem_init+0x102c>
f0102720:	68 c2 67 10 f0       	push   $0xf01067c2
f0102725:	68 33 65 10 f0       	push   $0xf0106533
f010272a:	68 92 04 00 00       	push   $0x492
f010272f:	68 0d 65 10 f0       	push   $0xf010650d
f0102734:	e8 6c d9 ff ff       	call   f01000a5 <_panic>


	// Free pp and assign four continuous pages
	page_free(pp);
f0102739:	83 ec 0c             	sub    $0xc,%esp
f010273c:	53                   	push   %ebx
f010273d:	e8 13 eb ff ff       	call   f0101255 <page_free>
	pp = page_alloc_npages(0, 4);
f0102742:	83 c4 08             	add    $0x8,%esp
f0102745:	6a 04                	push   $0x4
f0102747:	6a 00                	push   $0x0
f0102749:	e8 7b ea ff ff       	call   f01011c9 <page_alloc_npages>
f010274e:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 4));
f0102750:	ba 04 00 00 00       	mov    $0x4,%edx
f0102755:	e8 71 e3 ff ff       	call   f0100acb <check_continuous>
f010275a:	83 c4 10             	add    $0x10,%esp
f010275d:	85 c0                	test   %eax,%eax
f010275f:	75 19                	jne    f010277a <mem_init+0x106d>
f0102761:	68 cc 67 10 f0       	push   $0xf01067cc
f0102766:	68 33 65 10 f0       	push   $0xf0106533
f010276b:	68 98 04 00 00       	push   $0x498
f0102770:	68 0d 65 10 f0       	push   $0xf010650d
f0102775:	e8 2b d9 ff ff       	call   f01000a5 <_panic>

	// Free four continuous pages
	assert(!page_free_npages(pp, 4));
f010277a:	83 ec 08             	sub    $0x8,%esp
f010277d:	6a 04                	push   $0x4
f010277f:	53                   	push   %ebx
f0102780:	e8 93 ea ff ff       	call   f0101218 <page_free_npages>
f0102785:	83 c4 10             	add    $0x10,%esp
f0102788:	85 c0                	test   %eax,%eax
f010278a:	74 19                	je     f01027a5 <mem_init+0x1098>
f010278c:	68 e4 67 10 f0       	push   $0xf01067e4
f0102791:	68 33 65 10 f0       	push   $0xf0106533
f0102796:	68 9b 04 00 00       	push   $0x49b
f010279b:	68 0d 65 10 f0       	push   $0xf010650d
f01027a0:	e8 00 d9 ff ff       	call   f01000a5 <_panic>

	// Free pp and assign eight continuous pages
	pp = page_alloc_npages(0, 8);
f01027a5:	83 ec 08             	sub    $0x8,%esp
f01027a8:	6a 08                	push   $0x8
f01027aa:	6a 00                	push   $0x0
f01027ac:	e8 18 ea ff ff       	call   f01011c9 <page_alloc_npages>
f01027b1:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 8));
f01027b3:	ba 08 00 00 00       	mov    $0x8,%edx
f01027b8:	e8 0e e3 ff ff       	call   f0100acb <check_continuous>
f01027bd:	83 c4 10             	add    $0x10,%esp
f01027c0:	85 c0                	test   %eax,%eax
f01027c2:	75 19                	jne    f01027dd <mem_init+0x10d0>
f01027c4:	68 fd 67 10 f0       	push   $0xf01067fd
f01027c9:	68 33 65 10 f0       	push   $0xf0106533
f01027ce:	68 9f 04 00 00       	push   $0x49f
f01027d3:	68 0d 65 10 f0       	push   $0xf010650d
f01027d8:	e8 c8 d8 ff ff       	call   f01000a5 <_panic>

	// Free four continuous pages
	assert(!page_free_npages(pp, 8));
f01027dd:	83 ec 08             	sub    $0x8,%esp
f01027e0:	6a 08                	push   $0x8
f01027e2:	53                   	push   %ebx
f01027e3:	e8 30 ea ff ff       	call   f0101218 <page_free_npages>
f01027e8:	83 c4 10             	add    $0x10,%esp
f01027eb:	85 c0                	test   %eax,%eax
f01027ed:	74 19                	je     f0102808 <mem_init+0x10fb>
f01027ef:	68 15 68 10 f0       	push   $0xf0106815
f01027f4:	68 33 65 10 f0       	push   $0xf0106533
f01027f9:	68 a2 04 00 00       	push   $0x4a2
f01027fe:	68 0d 65 10 f0       	push   $0xf010650d
f0102803:	e8 9d d8 ff ff       	call   f01000a5 <_panic>


	// Free pp0 and assign four continuous zero pages
	page_free(pp0);
f0102808:	83 ec 0c             	sub    $0xc,%esp
f010280b:	56                   	push   %esi
f010280c:	e8 44 ea ff ff       	call   f0101255 <page_free>
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
f0102811:	83 c4 08             	add    $0x8,%esp
f0102814:	6a 04                	push   $0x4
f0102816:	6a 01                	push   $0x1
f0102818:	e8 ac e9 ff ff       	call   f01011c9 <page_alloc_npages>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010281d:	89 c1                	mov    %eax,%ecx
f010281f:	2b 0d ac ee 19 f0    	sub    0xf019eeac,%ecx
f0102825:	c1 f9 03             	sar    $0x3,%ecx
f0102828:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010282b:	89 ca                	mov    %ecx,%edx
f010282d:	c1 ea 0c             	shr    $0xc,%edx
f0102830:	83 c4 10             	add    $0x10,%esp
f0102833:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0102839:	72 12                	jb     f010284d <mem_init+0x1140>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010283b:	51                   	push   %ecx
f010283c:	68 74 5d 10 f0       	push   $0xf0105d74
f0102841:	6a 56                	push   $0x56
f0102843:	68 19 65 10 f0       	push   $0xf0106519
f0102848:	e8 58 d8 ff ff       	call   f01000a5 <_panic>
	addr = (char*)page2kva(pp0);

	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f010284d:	80 b9 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%ecx)
f0102854:	75 11                	jne    f0102867 <mem_init+0x115a>
f0102856:	8d 91 01 00 00 f0    	lea    -0xfffffff(%ecx),%edx
f010285c:	81 e9 00 c0 ff 0f    	sub    $0xfffc000,%ecx
f0102862:	80 3a 00             	cmpb   $0x0,(%edx)
f0102865:	74 19                	je     f0102880 <mem_init+0x1173>
f0102867:	68 2e 68 10 f0       	push   $0xf010682e
f010286c:	68 33 65 10 f0       	push   $0xf0106533
f0102871:	68 ac 04 00 00       	push   $0x4ac
f0102876:	68 0d 65 10 f0       	push   $0xf010650d
f010287b:	e8 25 d8 ff ff       	call   f01000a5 <_panic>
f0102880:	83 c2 01             	add    $0x1,%edx
	page_free(pp0);
	pp0 = page_alloc_npages(ALLOC_ZERO, 4);
	addr = (char*)page2kva(pp0);

	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
f0102883:	39 ca                	cmp    %ecx,%edx
f0102885:	75 db                	jne    f0102862 <mem_init+0x1155>
		assert(addr[i] == 0);
	}

	// Free pages
	assert(!page_free_npages(pp0, 4));
f0102887:	83 ec 08             	sub    $0x8,%esp
f010288a:	6a 04                	push   $0x4
f010288c:	50                   	push   %eax
f010288d:	e8 86 e9 ff ff       	call   f0101218 <page_free_npages>
f0102892:	83 c4 10             	add    $0x10,%esp
f0102895:	85 c0                	test   %eax,%eax
f0102897:	74 19                	je     f01028b2 <mem_init+0x11a5>
f0102899:	68 3b 68 10 f0       	push   $0xf010683b
f010289e:	68 33 65 10 f0       	push   $0xf0106533
f01028a3:	68 b0 04 00 00       	push   $0x4b0
f01028a8:	68 0d 65 10 f0       	push   $0xf010650d
f01028ad:	e8 f3 d7 ff ff       	call   f01000a5 <_panic>
	cprintf("check_n_pages() succeeded!\n");
f01028b2:	83 ec 0c             	sub    $0xc,%esp
f01028b5:	68 55 68 10 f0       	push   $0xf0106855
f01028ba:	e8 e0 10 00 00       	call   f010399f <cprintf>
	char* addr;
	int i;
	pp = pp0 = 0;

	// Allocate two single pages
	pp =  page_alloc(0);
f01028bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028c6:	e8 19 e7 ff ff       	call   f0100fe4 <page_alloc>
f01028cb:	89 c6                	mov    %eax,%esi
	pp0 = page_alloc(0);
f01028cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028d4:	e8 0b e7 ff ff       	call   f0100fe4 <page_alloc>
f01028d9:	89 c3                	mov    %eax,%ebx
	assert(pp != 0);
f01028db:	83 c4 10             	add    $0x10,%esp
f01028de:	85 f6                	test   %esi,%esi
f01028e0:	75 19                	jne    f01028fb <mem_init+0x11ee>
f01028e2:	68 b1 67 10 f0       	push   $0xf01067b1
f01028e7:	68 33 65 10 f0       	push   $0xf0106533
f01028ec:	68 bf 04 00 00       	push   $0x4bf
f01028f1:	68 0d 65 10 f0       	push   $0xf010650d
f01028f6:	e8 aa d7 ff ff       	call   f01000a5 <_panic>
	assert(pp0 != 0);
f01028fb:	85 c0                	test   %eax,%eax
f01028fd:	75 19                	jne    f0102918 <mem_init+0x120b>
f01028ff:	68 b9 67 10 f0       	push   $0xf01067b9
f0102904:	68 33 65 10 f0       	push   $0xf0106533
f0102909:	68 c0 04 00 00       	push   $0x4c0
f010290e:	68 0d 65 10 f0       	push   $0xf010650d
f0102913:	e8 8d d7 ff ff       	call   f01000a5 <_panic>
	assert(pp != pp0);
f0102918:	39 c6                	cmp    %eax,%esi
f010291a:	75 19                	jne    f0102935 <mem_init+0x1228>
f010291c:	68 c2 67 10 f0       	push   $0xf01067c2
f0102921:	68 33 65 10 f0       	push   $0xf0106533
f0102926:	68 c1 04 00 00       	push   $0x4c1
f010292b:	68 0d 65 10 f0       	push   $0xf010650d
f0102930:	e8 70 d7 ff ff       	call   f01000a5 <_panic>

	// Free pp and pp0
	page_free(pp);
f0102935:	83 ec 0c             	sub    $0xc,%esp
f0102938:	56                   	push   %esi
f0102939:	e8 17 e9 ff ff       	call   f0101255 <page_free>
	page_free(pp0);
f010293e:	89 1c 24             	mov    %ebx,(%esp)
f0102941:	e8 0f e9 ff ff       	call   f0101255 <page_free>

	// Assign eight continuous pages
	pp = page_alloc_npages(0, 8);
f0102946:	83 c4 08             	add    $0x8,%esp
f0102949:	6a 08                	push   $0x8
f010294b:	6a 00                	push   $0x0
f010294d:	e8 77 e8 ff ff       	call   f01011c9 <page_alloc_npages>
f0102952:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp, 8));
f0102954:	ba 08 00 00 00       	mov    $0x8,%edx
f0102959:	e8 6d e1 ff ff       	call   f0100acb <check_continuous>
f010295e:	83 c4 10             	add    $0x10,%esp
f0102961:	85 c0                	test   %eax,%eax
f0102963:	75 19                	jne    f010297e <mem_init+0x1271>
f0102965:	68 fd 67 10 f0       	push   $0xf01067fd
f010296a:	68 33 65 10 f0       	push   $0xf0106533
f010296f:	68 c9 04 00 00       	push   $0x4c9
f0102974:	68 0d 65 10 f0       	push   $0xf010650d
f0102979:	e8 27 d7 ff ff       	call   f01000a5 <_panic>

	// Realloc to 4 pages
	pp0 = page_realloc_npages(pp, 8, 4);
f010297e:	83 ec 04             	sub    $0x4,%esp
f0102981:	6a 04                	push   $0x4
f0102983:	6a 08                	push   $0x8
f0102985:	53                   	push   %ebx
f0102986:	e8 fb e8 ff ff       	call   f0101286 <page_realloc_npages>
	assert(pp0 == pp);
f010298b:	83 c4 10             	add    $0x10,%esp
f010298e:	39 c3                	cmp    %eax,%ebx
f0102990:	74 19                	je     f01029ab <mem_init+0x129e>
f0102992:	68 ce 66 10 f0       	push   $0xf01066ce
f0102997:	68 33 65 10 f0       	push   $0xf0106533
f010299c:	68 cd 04 00 00       	push   $0x4cd
f01029a1:	68 0d 65 10 f0       	push   $0xf010650d
f01029a6:	e8 fa d6 ff ff       	call   f01000a5 <_panic>
	assert(check_continuous(pp, 4));
f01029ab:	ba 04 00 00 00       	mov    $0x4,%edx
f01029b0:	89 d8                	mov    %ebx,%eax
f01029b2:	e8 14 e1 ff ff       	call   f0100acb <check_continuous>
f01029b7:	85 c0                	test   %eax,%eax
f01029b9:	75 19                	jne    f01029d4 <mem_init+0x12c7>
f01029bb:	68 cc 67 10 f0       	push   $0xf01067cc
f01029c0:	68 33 65 10 f0       	push   $0xf0106533
f01029c5:	68 ce 04 00 00       	push   $0x4ce
f01029ca:	68 0d 65 10 f0       	push   $0xf010650d
f01029cf:	e8 d1 d6 ff ff       	call   f01000a5 <_panic>

	// Realloc to 6 pages
	pp0 = page_realloc_npages(pp, 4, 6);
f01029d4:	83 ec 04             	sub    $0x4,%esp
f01029d7:	6a 06                	push   $0x6
f01029d9:	6a 04                	push   $0x4
f01029db:	53                   	push   %ebx
f01029dc:	e8 a5 e8 ff ff       	call   f0101286 <page_realloc_npages>
	assert(pp0 == pp);
f01029e1:	83 c4 10             	add    $0x10,%esp
f01029e4:	39 c3                	cmp    %eax,%ebx
f01029e6:	74 19                	je     f0102a01 <mem_init+0x12f4>
f01029e8:	68 ce 66 10 f0       	push   $0xf01066ce
f01029ed:	68 33 65 10 f0       	push   $0xf0106533
f01029f2:	68 d2 04 00 00       	push   $0x4d2
f01029f7:	68 0d 65 10 f0       	push   $0xf010650d
f01029fc:	e8 a4 d6 ff ff       	call   f01000a5 <_panic>
	assert(check_continuous(pp, 6));
f0102a01:	ba 06 00 00 00       	mov    $0x6,%edx
f0102a06:	89 d8                	mov    %ebx,%eax
f0102a08:	e8 be e0 ff ff       	call   f0100acb <check_continuous>
f0102a0d:	85 c0                	test   %eax,%eax
f0102a0f:	75 19                	jne    f0102a2a <mem_init+0x131d>
f0102a11:	68 71 68 10 f0       	push   $0xf0106871
f0102a16:	68 33 65 10 f0       	push   $0xf0106533
f0102a1b:	68 d3 04 00 00       	push   $0x4d3
f0102a20:	68 0d 65 10 f0       	push   $0xf010650d
f0102a25:	e8 7b d6 ff ff       	call   f01000a5 <_panic>

	// Realloc to 12 pages
	pp0 = page_realloc_npages(pp, 6, 12);
f0102a2a:	83 ec 04             	sub    $0x4,%esp
f0102a2d:	6a 0c                	push   $0xc
f0102a2f:	6a 06                	push   $0x6
f0102a31:	53                   	push   %ebx
f0102a32:	e8 4f e8 ff ff       	call   f0101286 <page_realloc_npages>
f0102a37:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp0, 12));
f0102a39:	ba 0c 00 00 00       	mov    $0xc,%edx
f0102a3e:	e8 88 e0 ff ff       	call   f0100acb <check_continuous>
f0102a43:	83 c4 10             	add    $0x10,%esp
f0102a46:	85 c0                	test   %eax,%eax
f0102a48:	75 19                	jne    f0102a63 <mem_init+0x1356>
f0102a4a:	68 89 68 10 f0       	push   $0xf0106889
f0102a4f:	68 33 65 10 f0       	push   $0xf0106533
f0102a54:	68 d7 04 00 00       	push   $0x4d7
f0102a59:	68 0d 65 10 f0       	push   $0xf010650d
f0102a5e:	e8 42 d6 ff ff       	call   f01000a5 <_panic>

	// Free 12 continuous pages
	assert(!page_free_npages(pp0, 12));
f0102a63:	83 ec 08             	sub    $0x8,%esp
f0102a66:	6a 0c                	push   $0xc
f0102a68:	53                   	push   %ebx
f0102a69:	e8 aa e7 ff ff       	call   f0101218 <page_free_npages>
f0102a6e:	83 c4 10             	add    $0x10,%esp
f0102a71:	85 c0                	test   %eax,%eax
f0102a73:	74 19                	je     f0102a8e <mem_init+0x1381>
f0102a75:	68 a3 68 10 f0       	push   $0xf01068a3
f0102a7a:	68 33 65 10 f0       	push   $0xf0106533
f0102a7f:	68 da 04 00 00       	push   $0x4da
f0102a84:	68 0d 65 10 f0       	push   $0xf010650d
f0102a89:	e8 17 d6 ff ff       	call   f01000a5 <_panic>

	cprintf("check_realloc_npages() succeeded!\n");
f0102a8e:	83 ec 0c             	sub    $0xc,%esp
f0102a91:	68 ec 62 10 f0       	push   $0xf01062ec
f0102a96:	e8 04 0f 00 00       	call   f010399f <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof(struct Page), PGSIZE), PADDR(pages), PTE_U);
f0102a9b:	a1 ac ee 19 f0       	mov    0xf019eeac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102aa0:	83 c4 10             	add    $0x10,%esp
f0102aa3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102aa8:	77 15                	ja     f0102abf <mem_init+0x13b2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aaa:	50                   	push   %eax
f0102aab:	68 98 5d 10 f0       	push   $0xf0105d98
f0102ab0:	68 bd 00 00 00       	push   $0xbd
f0102ab5:	68 0d 65 10 f0       	push   $0xf010650d
f0102aba:	e8 e6 d5 ff ff       	call   f01000a5 <_panic>
f0102abf:	8b 15 a4 ee 19 f0    	mov    0xf019eea4,%edx
f0102ac5:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102acc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102ad2:	83 ec 08             	sub    $0x8,%esp
f0102ad5:	6a 04                	push   $0x4
f0102ad7:	05 00 00 00 10       	add    $0x10000000,%eax
f0102adc:	50                   	push   %eax
f0102add:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102ae2:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0102ae7:	e8 96 ea ff ff       	call   f0101582 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U);
f0102aec:	a1 f0 e1 19 f0       	mov    0xf019e1f0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102af1:	83 c4 10             	add    $0x10,%esp
f0102af4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102af9:	77 15                	ja     f0102b10 <mem_init+0x1403>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102afb:	50                   	push   %eax
f0102afc:	68 98 5d 10 f0       	push   $0xf0105d98
f0102b01:	68 c6 00 00 00       	push   $0xc6
f0102b06:	68 0d 65 10 f0       	push   $0xf010650d
f0102b0b:	e8 95 d5 ff ff       	call   f01000a5 <_panic>
f0102b10:	83 ec 08             	sub    $0x8,%esp
f0102b13:	6a 04                	push   $0x4
f0102b15:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b1a:	50                   	push   %eax
f0102b1b:	b9 00 90 01 00       	mov    $0x19000,%ecx
f0102b20:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102b25:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0102b2a:	e8 53 ea ff ff       	call   f0101582 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b2f:	83 c4 10             	add    $0x10,%esp
f0102b32:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f0102b37:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b3c:	77 15                	ja     f0102b53 <mem_init+0x1446>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b3e:	50                   	push   %eax
f0102b3f:	68 98 5d 10 f0       	push   $0xf0105d98
f0102b44:	68 d3 00 00 00       	push   $0xd3
f0102b49:	68 0d 65 10 f0       	push   $0xf010650d
f0102b4e:	e8 52 d5 ff ff       	call   f01000a5 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102b53:	c7 45 c8 00 30 11 00 	movl   $0x113000,-0x38(%ebp)
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102b5a:	83 ec 08             	sub    $0x8,%esp
f0102b5d:	6a 02                	push   $0x2
f0102b5f:	68 00 30 11 00       	push   $0x113000
f0102b64:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b69:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102b6e:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0102b73:	e8 0a ea ff ff       	call   f0101582 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, ~KERNBASE + 1, 0, PTE_W);
f0102b78:	83 c4 08             	add    $0x8,%esp
f0102b7b:	6a 02                	push   $0x2
f0102b7d:	6a 00                	push   $0x0
f0102b7f:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102b84:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102b89:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
f0102b8e:	e8 ef e9 ff ff       	call   f0101582 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102b93:	8b 1d a8 ee 19 f0    	mov    0xf019eea8,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0102b99:	a1 a4 ee 19 f0       	mov    0xf019eea4,%eax
f0102b9e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102ba1:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f0102ba8:	83 c4 10             	add    $0x10,%esp
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102bab:	8b 3d ac ee 19 f0    	mov    0xf019eeac,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bb1:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102bb4:	be 00 00 00 00       	mov    $0x0,%esi

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102bb9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102bbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102bc1:	75 10                	jne    f0102bd3 <mem_init+0x14c6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102bc3:	8b 3d f0 e1 19 f0    	mov    0xf019e1f0,%edi
f0102bc9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102bcc:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102bd1:	eb 5c                	jmp    f0102c2f <mem_init+0x1522>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102bd3:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102bd9:	89 d8                	mov    %ebx,%eax
f0102bdb:	e8 79 df ff ff       	call   f0100b59 <check_va2pa>
f0102be0:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102be7:	77 15                	ja     f0102bfe <mem_init+0x14f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102be9:	57                   	push   %edi
f0102bea:	68 98 5d 10 f0       	push   $0xf0105d98
f0102bef:	68 aa 03 00 00       	push   $0x3aa
f0102bf4:	68 0d 65 10 f0       	push   $0xf010650d
f0102bf9:	e8 a7 d4 ff ff       	call   f01000a5 <_panic>
f0102bfe:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f0102c05:	39 c2                	cmp    %eax,%edx
f0102c07:	74 19                	je     f0102c22 <mem_init+0x1515>
f0102c09:	68 10 63 10 f0       	push   $0xf0106310
f0102c0e:	68 33 65 10 f0       	push   $0xf0106533
f0102c13:	68 aa 03 00 00       	push   $0x3aa
f0102c18:	68 0d 65 10 f0       	push   $0xf010650d
f0102c1d:	e8 83 d4 ff ff       	call   f01000a5 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102c22:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c28:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102c2b:	77 a6                	ja     f0102bd3 <mem_init+0x14c6>
f0102c2d:	eb 94                	jmp    f0102bc3 <mem_init+0x14b6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102c2f:	89 f2                	mov    %esi,%edx
f0102c31:	89 d8                	mov    %ebx,%eax
f0102c33:	e8 21 df ff ff       	call   f0100b59 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c38:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102c3f:	77 15                	ja     f0102c56 <mem_init+0x1549>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c41:	57                   	push   %edi
f0102c42:	68 98 5d 10 f0       	push   $0xf0105d98
f0102c47:	68 af 03 00 00       	push   $0x3af
f0102c4c:	68 0d 65 10 f0       	push   $0xf010650d
f0102c51:	e8 4f d4 ff ff       	call   f01000a5 <_panic>
f0102c56:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f0102c5d:	39 c2                	cmp    %eax,%edx
f0102c5f:	74 19                	je     f0102c7a <mem_init+0x156d>
f0102c61:	68 44 63 10 f0       	push   $0xf0106344
f0102c66:	68 33 65 10 f0       	push   $0xf0106533
f0102c6b:	68 af 03 00 00       	push   $0x3af
f0102c70:	68 0d 65 10 f0       	push   $0xf010650d
f0102c75:	e8 2b d4 ff ff       	call   f01000a5 <_panic>
f0102c7a:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102c80:	81 fe 00 90 c1 ee    	cmp    $0xeec19000,%esi
f0102c86:	75 a7                	jne    f0102c2f <mem_init+0x1522>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c88:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102c8b:	c1 e7 0c             	shl    $0xc,%edi
f0102c8e:	85 ff                	test   %edi,%edi
f0102c90:	0f 84 94 04 00 00    	je     f010312a <mem_init+0x1a1d>
f0102c96:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c9b:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102ca1:	89 d8                	mov    %ebx,%eax
f0102ca3:	e8 b1 de ff ff       	call   f0100b59 <check_va2pa>
f0102ca8:	39 f0                	cmp    %esi,%eax
f0102caa:	74 19                	je     f0102cc5 <mem_init+0x15b8>
f0102cac:	68 78 63 10 f0       	push   $0xf0106378
f0102cb1:	68 33 65 10 f0       	push   $0xf0106533
f0102cb6:	68 b3 03 00 00       	push   $0x3b3
f0102cbb:	68 0d 65 10 f0       	push   $0xf010650d
f0102cc0:	e8 e0 d3 ff ff       	call   f01000a5 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102cc5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ccb:	39 f7                	cmp    %esi,%edi
f0102ccd:	77 cc                	ja     f0102c9b <mem_init+0x158e>
f0102ccf:	e9 56 04 00 00       	jmp    f010312a <mem_init+0x1a1d>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102cd4:	39 c3                	cmp    %eax,%ebx
f0102cd6:	74 19                	je     f0102cf1 <mem_init+0x15e4>
f0102cd8:	68 a0 63 10 f0       	push   $0xf01063a0
f0102cdd:	68 33 65 10 f0       	push   $0xf0106533
f0102ce2:	68 b7 03 00 00       	push   $0x3b7
f0102ce7:	68 0d 65 10 f0       	push   $0xf010650d
f0102cec:	e8 b4 d3 ff ff       	call   f01000a5 <_panic>
f0102cf1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102cf7:	39 df                	cmp    %ebx,%edi
f0102cf9:	0f 85 1b 04 00 00    	jne    f010311a <mem_init+0x1a0d>
f0102cff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102d02:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0102d07:	89 d8                	mov    %ebx,%eax
f0102d09:	e8 4b de ff ff       	call   f0100b59 <check_va2pa>
f0102d0e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102d11:	74 19                	je     f0102d2c <mem_init+0x161f>
f0102d13:	68 e8 63 10 f0       	push   $0xf01063e8
f0102d18:	68 33 65 10 f0       	push   $0xf0106533
f0102d1d:	68 b8 03 00 00       	push   $0x3b8
f0102d22:	68 0d 65 10 f0       	push   $0xf010650d
f0102d27:	e8 79 d3 ff ff       	call   f01000a5 <_panic>
f0102d2c:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102d31:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102d37:	83 fa 03             	cmp    $0x3,%edx
f0102d3a:	77 1f                	ja     f0102d5b <mem_init+0x164e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102d3c:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102d40:	75 7e                	jne    f0102dc0 <mem_init+0x16b3>
f0102d42:	68 be 68 10 f0       	push   $0xf01068be
f0102d47:	68 33 65 10 f0       	push   $0xf0106533
f0102d4c:	68 c1 03 00 00       	push   $0x3c1
f0102d51:	68 0d 65 10 f0       	push   $0xf010650d
f0102d56:	e8 4a d3 ff ff       	call   f01000a5 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102d5b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102d60:	76 3f                	jbe    f0102da1 <mem_init+0x1694>
				assert(pgdir[i] & PTE_P);
f0102d62:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102d65:	f6 c2 01             	test   $0x1,%dl
f0102d68:	75 19                	jne    f0102d83 <mem_init+0x1676>
f0102d6a:	68 be 68 10 f0       	push   $0xf01068be
f0102d6f:	68 33 65 10 f0       	push   $0xf0106533
f0102d74:	68 c5 03 00 00       	push   $0x3c5
f0102d79:	68 0d 65 10 f0       	push   $0xf010650d
f0102d7e:	e8 22 d3 ff ff       	call   f01000a5 <_panic>
				assert(pgdir[i] & PTE_W);
f0102d83:	f6 c2 02             	test   $0x2,%dl
f0102d86:	75 38                	jne    f0102dc0 <mem_init+0x16b3>
f0102d88:	68 cf 68 10 f0       	push   $0xf01068cf
f0102d8d:	68 33 65 10 f0       	push   $0xf0106533
f0102d92:	68 c6 03 00 00       	push   $0x3c6
f0102d97:	68 0d 65 10 f0       	push   $0xf010650d
f0102d9c:	e8 04 d3 ff ff       	call   f01000a5 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102da1:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102da5:	74 19                	je     f0102dc0 <mem_init+0x16b3>
f0102da7:	68 e0 68 10 f0       	push   $0xf01068e0
f0102dac:	68 33 65 10 f0       	push   $0xf0106533
f0102db1:	68 c8 03 00 00       	push   $0x3c8
f0102db6:	68 0d 65 10 f0       	push   $0xf010650d
f0102dbb:	e8 e5 d2 ff ff       	call   f01000a5 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102dc0:	83 c0 01             	add    $0x1,%eax
f0102dc3:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102dc8:	0f 85 63 ff ff ff    	jne    f0102d31 <mem_init+0x1624>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102dce:	83 ec 0c             	sub    $0xc,%esp
f0102dd1:	68 18 64 10 f0       	push   $0xf0106418
f0102dd6:	e8 c4 0b 00 00       	call   f010399f <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102ddb:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102de0:	83 c4 10             	add    $0x10,%esp
f0102de3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102de8:	77 15                	ja     f0102dff <mem_init+0x16f2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dea:	50                   	push   %eax
f0102deb:	68 98 5d 10 f0       	push   $0xf0105d98
f0102df0:	68 e9 00 00 00       	push   $0xe9
f0102df5:	68 0d 65 10 f0       	push   $0xf010650d
f0102dfa:	e8 a6 d2 ff ff       	call   f01000a5 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102dff:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e04:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102e07:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e0c:	e8 35 de ff ff       	call   f0100c46 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102e11:	0f 20 c0             	mov    %cr0,%eax
f0102e14:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102e17:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102e1c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e1f:	83 ec 0c             	sub    $0xc,%esp
f0102e22:	6a 00                	push   $0x0
f0102e24:	e8 bb e1 ff ff       	call   f0100fe4 <page_alloc>
f0102e29:	89 c3                	mov    %eax,%ebx
f0102e2b:	83 c4 10             	add    $0x10,%esp
f0102e2e:	85 c0                	test   %eax,%eax
f0102e30:	75 19                	jne    f0102e4b <mem_init+0x173e>
f0102e32:	68 f0 65 10 f0       	push   $0xf01065f0
f0102e37:	68 33 65 10 f0       	push   $0xf0106533
f0102e3c:	68 eb 04 00 00       	push   $0x4eb
f0102e41:	68 0d 65 10 f0       	push   $0xf010650d
f0102e46:	e8 5a d2 ff ff       	call   f01000a5 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e4b:	83 ec 0c             	sub    $0xc,%esp
f0102e4e:	6a 00                	push   $0x0
f0102e50:	e8 8f e1 ff ff       	call   f0100fe4 <page_alloc>
f0102e55:	89 c7                	mov    %eax,%edi
f0102e57:	83 c4 10             	add    $0x10,%esp
f0102e5a:	85 c0                	test   %eax,%eax
f0102e5c:	75 19                	jne    f0102e77 <mem_init+0x176a>
f0102e5e:	68 06 66 10 f0       	push   $0xf0106606
f0102e63:	68 33 65 10 f0       	push   $0xf0106533
f0102e68:	68 ec 04 00 00       	push   $0x4ec
f0102e6d:	68 0d 65 10 f0       	push   $0xf010650d
f0102e72:	e8 2e d2 ff ff       	call   f01000a5 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e77:	83 ec 0c             	sub    $0xc,%esp
f0102e7a:	6a 00                	push   $0x0
f0102e7c:	e8 63 e1 ff ff       	call   f0100fe4 <page_alloc>
f0102e81:	89 c6                	mov    %eax,%esi
f0102e83:	83 c4 10             	add    $0x10,%esp
f0102e86:	85 c0                	test   %eax,%eax
f0102e88:	75 19                	jne    f0102ea3 <mem_init+0x1796>
f0102e8a:	68 1c 66 10 f0       	push   $0xf010661c
f0102e8f:	68 33 65 10 f0       	push   $0xf0106533
f0102e94:	68 ed 04 00 00       	push   $0x4ed
f0102e99:	68 0d 65 10 f0       	push   $0xf010650d
f0102e9e:	e8 02 d2 ff ff       	call   f01000a5 <_panic>
	page_free(pp0);
f0102ea3:	83 ec 0c             	sub    $0xc,%esp
f0102ea6:	53                   	push   %ebx
f0102ea7:	e8 a9 e3 ff ff       	call   f0101255 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102eac:	89 f8                	mov    %edi,%eax
f0102eae:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0102eb4:	c1 f8 03             	sar    $0x3,%eax
f0102eb7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102eba:	89 c2                	mov    %eax,%edx
f0102ebc:	c1 ea 0c             	shr    $0xc,%edx
f0102ebf:	83 c4 10             	add    $0x10,%esp
f0102ec2:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0102ec8:	72 12                	jb     f0102edc <mem_init+0x17cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102eca:	50                   	push   %eax
f0102ecb:	68 74 5d 10 f0       	push   $0xf0105d74
f0102ed0:	6a 56                	push   $0x56
f0102ed2:	68 19 65 10 f0       	push   $0xf0106519
f0102ed7:	e8 c9 d1 ff ff       	call   f01000a5 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102edc:	83 ec 04             	sub    $0x4,%esp
f0102edf:	68 00 10 00 00       	push   $0x1000
f0102ee4:	6a 01                	push   $0x1
f0102ee6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102eeb:	50                   	push   %eax
f0102eec:	e8 73 23 00 00       	call   f0105264 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ef1:	89 f0                	mov    %esi,%eax
f0102ef3:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f0102ef9:	c1 f8 03             	sar    $0x3,%eax
f0102efc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102eff:	89 c2                	mov    %eax,%edx
f0102f01:	c1 ea 0c             	shr    $0xc,%edx
f0102f04:	83 c4 10             	add    $0x10,%esp
f0102f07:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f0102f0d:	72 12                	jb     f0102f21 <mem_init+0x1814>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f0f:	50                   	push   %eax
f0102f10:	68 74 5d 10 f0       	push   $0xf0105d74
f0102f15:	6a 56                	push   $0x56
f0102f17:	68 19 65 10 f0       	push   $0xf0106519
f0102f1c:	e8 84 d1 ff ff       	call   f01000a5 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f21:	83 ec 04             	sub    $0x4,%esp
f0102f24:	68 00 10 00 00       	push   $0x1000
f0102f29:	6a 02                	push   $0x2
f0102f2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f30:	50                   	push   %eax
f0102f31:	e8 2e 23 00 00       	call   f0105264 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102f36:	6a 02                	push   $0x2
f0102f38:	68 00 10 00 00       	push   $0x1000
f0102f3d:	57                   	push   %edi
f0102f3e:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0102f44:	e8 3a e7 ff ff       	call   f0101683 <page_insert>
	assert(pp1->pp_ref == 1);
f0102f49:	83 c4 20             	add    $0x20,%esp
f0102f4c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102f51:	74 19                	je     f0102f6c <mem_init+0x185f>
f0102f53:	68 ed 66 10 f0       	push   $0xf01066ed
f0102f58:	68 33 65 10 f0       	push   $0xf0106533
f0102f5d:	68 f2 04 00 00       	push   $0x4f2
f0102f62:	68 0d 65 10 f0       	push   $0xf010650d
f0102f67:	e8 39 d1 ff ff       	call   f01000a5 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f6c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102f73:	01 01 01 
f0102f76:	74 19                	je     f0102f91 <mem_init+0x1884>
f0102f78:	68 38 64 10 f0       	push   $0xf0106438
f0102f7d:	68 33 65 10 f0       	push   $0xf0106533
f0102f82:	68 f3 04 00 00       	push   $0x4f3
f0102f87:	68 0d 65 10 f0       	push   $0xf010650d
f0102f8c:	e8 14 d1 ff ff       	call   f01000a5 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102f91:	6a 02                	push   $0x2
f0102f93:	68 00 10 00 00       	push   $0x1000
f0102f98:	56                   	push   %esi
f0102f99:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0102f9f:	e8 df e6 ff ff       	call   f0101683 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102fa4:	83 c4 10             	add    $0x10,%esp
f0102fa7:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102fae:	02 02 02 
f0102fb1:	74 19                	je     f0102fcc <mem_init+0x18bf>
f0102fb3:	68 5c 64 10 f0       	push   $0xf010645c
f0102fb8:	68 33 65 10 f0       	push   $0xf0106533
f0102fbd:	68 f5 04 00 00       	push   $0x4f5
f0102fc2:	68 0d 65 10 f0       	push   $0xf010650d
f0102fc7:	e8 d9 d0 ff ff       	call   f01000a5 <_panic>
	assert(pp2->pp_ref == 1);
f0102fcc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102fd1:	74 19                	je     f0102fec <mem_init+0x18df>
f0102fd3:	68 0f 67 10 f0       	push   $0xf010670f
f0102fd8:	68 33 65 10 f0       	push   $0xf0106533
f0102fdd:	68 f6 04 00 00       	push   $0x4f6
f0102fe2:	68 0d 65 10 f0       	push   $0xf010650d
f0102fe7:	e8 b9 d0 ff ff       	call   f01000a5 <_panic>
	assert(pp1->pp_ref == 0);
f0102fec:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ff1:	74 19                	je     f010300c <mem_init+0x18ff>
f0102ff3:	68 58 67 10 f0       	push   $0xf0106758
f0102ff8:	68 33 65 10 f0       	push   $0xf0106533
f0102ffd:	68 f7 04 00 00       	push   $0x4f7
f0103002:	68 0d 65 10 f0       	push   $0xf010650d
f0103007:	e8 99 d0 ff ff       	call   f01000a5 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010300c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103013:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103016:	89 f0                	mov    %esi,%eax
f0103018:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f010301e:	c1 f8 03             	sar    $0x3,%eax
f0103021:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103024:	89 c2                	mov    %eax,%edx
f0103026:	c1 ea 0c             	shr    $0xc,%edx
f0103029:	3b 15 a4 ee 19 f0    	cmp    0xf019eea4,%edx
f010302f:	72 12                	jb     f0103043 <mem_init+0x1936>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103031:	50                   	push   %eax
f0103032:	68 74 5d 10 f0       	push   $0xf0105d74
f0103037:	6a 56                	push   $0x56
f0103039:	68 19 65 10 f0       	push   $0xf0106519
f010303e:	e8 62 d0 ff ff       	call   f01000a5 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103043:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010304a:	03 03 03 
f010304d:	74 19                	je     f0103068 <mem_init+0x195b>
f010304f:	68 80 64 10 f0       	push   $0xf0106480
f0103054:	68 33 65 10 f0       	push   $0xf0106533
f0103059:	68 f9 04 00 00       	push   $0x4f9
f010305e:	68 0d 65 10 f0       	push   $0xf010650d
f0103063:	e8 3d d0 ff ff       	call   f01000a5 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103068:	83 ec 08             	sub    $0x8,%esp
f010306b:	68 00 10 00 00       	push   $0x1000
f0103070:	ff 35 a8 ee 19 f0    	pushl  0xf019eea8
f0103076:	e8 cd e5 ff ff       	call   f0101648 <page_remove>
	assert(pp2->pp_ref == 0);
f010307b:	83 c4 10             	add    $0x10,%esp
f010307e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103083:	74 19                	je     f010309e <mem_init+0x1991>
f0103085:	68 47 67 10 f0       	push   $0xf0106747
f010308a:	68 33 65 10 f0       	push   $0xf0106533
f010308f:	68 fb 04 00 00       	push   $0x4fb
f0103094:	68 0d 65 10 f0       	push   $0xf010650d
f0103099:	e8 07 d0 ff ff       	call   f01000a5 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010309e:	8b 0d a8 ee 19 f0    	mov    0xf019eea8,%ecx
f01030a4:	8b 11                	mov    (%ecx),%edx
f01030a6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01030ac:	89 d8                	mov    %ebx,%eax
f01030ae:	2b 05 ac ee 19 f0    	sub    0xf019eeac,%eax
f01030b4:	c1 f8 03             	sar    $0x3,%eax
f01030b7:	c1 e0 0c             	shl    $0xc,%eax
f01030ba:	39 c2                	cmp    %eax,%edx
f01030bc:	74 19                	je     f01030d7 <mem_init+0x19ca>
f01030be:	68 d8 5f 10 f0       	push   $0xf0105fd8
f01030c3:	68 33 65 10 f0       	push   $0xf0106533
f01030c8:	68 fe 04 00 00       	push   $0x4fe
f01030cd:	68 0d 65 10 f0       	push   $0xf010650d
f01030d2:	e8 ce cf ff ff       	call   f01000a5 <_panic>
	kern_pgdir[0] = 0;
f01030d7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01030dd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01030e2:	74 19                	je     f01030fd <mem_init+0x19f0>
f01030e4:	68 fe 66 10 f0       	push   $0xf01066fe
f01030e9:	68 33 65 10 f0       	push   $0xf0106533
f01030ee:	68 00 05 00 00       	push   $0x500
f01030f3:	68 0d 65 10 f0       	push   $0xf010650d
f01030f8:	e8 a8 cf ff ff       	call   f01000a5 <_panic>
	pp0->pp_ref = 0;
f01030fd:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103103:	83 ec 0c             	sub    $0xc,%esp
f0103106:	53                   	push   %ebx
f0103107:	e8 49 e1 ff ff       	call   f0101255 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010310c:	c7 04 24 ac 64 10 f0 	movl   $0xf01064ac,(%esp)
f0103113:	e8 87 08 00 00       	call   f010399f <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103118:	eb 37                	jmp    f0103151 <mem_init+0x1a44>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010311a:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f010311d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103120:	e8 34 da ff ff       	call   f0100b59 <check_va2pa>
f0103125:	e9 aa fb ff ff       	jmp    f0102cd4 <mem_init+0x15c7>
f010312a:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010312f:	89 d8                	mov    %ebx,%eax
f0103131:	e8 23 da ff ff       	call   f0100b59 <check_va2pa>
f0103136:	bf 00 b0 11 00       	mov    $0x11b000,%edi
f010313b:	be 00 80 bf df       	mov    $0xdfbf8000,%esi
f0103140:	81 ee 00 30 11 f0    	sub    $0xf0113000,%esi
f0103146:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0103149:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f010314c:	e9 83 fb ff ff       	jmp    f0102cd4 <mem_init+0x15c7>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103151:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103154:	5b                   	pop    %ebx
f0103155:	5e                   	pop    %esi
f0103156:	5f                   	pop    %edi
f0103157:	5d                   	pop    %ebp
f0103158:	c3                   	ret    

f0103159 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0103159:	55                   	push   %ebp
f010315a:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010315c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010315f:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0103162:	5d                   	pop    %ebp
f0103163:	c3                   	ret    

f0103164 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103164:	55                   	push   %ebp
f0103165:	89 e5                	mov    %esp,%ebp
f0103167:	57                   	push   %edi
f0103168:	56                   	push   %esi
f0103169:	53                   	push   %ebx
f010316a:	83 ec 1c             	sub    $0x1c,%esp
f010316d:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f0103170:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103173:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103178:	89 c1                	mov    %eax,%ecx
f010317a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f010317d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103180:	03 45 10             	add    0x10(%ebp),%eax
f0103183:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103188:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010318d:	89 c2                	mov    %eax,%edx
f010318f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	size_t i;
	int auth = perm | PTE_P;
f0103192:	8b 75 14             	mov    0x14(%ebp),%esi
f0103195:	83 ce 01             	or     $0x1,%esi
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f0103198:	89 c8                	mov    %ecx,%eax
f010319a:	39 d0                	cmp    %edx,%eax
f010319c:	73 6f                	jae    f010320d <user_mem_check+0xa9>
		if (i >= ULIM) {
f010319e:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01031a3:	77 15                	ja     f01031ba <user_mem_check+0x56>
f01031a5:	89 c3                	mov    %eax,%ebx
f01031a7:	eb 21                	jmp    f01031ca <user_mem_check+0x66>
f01031a9:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01031af:	76 19                	jbe    f01031ca <user_mem_check+0x66>

	size_t i;
	int auth = perm | PTE_P;
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f01031b1:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f01031b4:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f01031b8:	eb 03                	jmp    f01031bd <user_mem_check+0x59>
		if (i >= ULIM) {
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
f01031ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031bd:	89 1d dc e1 19 f0    	mov    %ebx,0xf019e1dc
			return -E_FAULT;
f01031c3:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01031c8:	eb 48                	jmp    f0103212 <user_mem_check+0xae>
		}
		pte = pgdir_walk(env->env_pgdir, (void *)i, 0);
f01031ca:	83 ec 04             	sub    $0x4,%esp
f01031cd:	6a 00                	push   $0x0
f01031cf:	53                   	push   %ebx
f01031d0:	ff 77 60             	pushl  0x60(%edi)
f01031d3:	e8 bf e2 ff ff       	call   f0101497 <pgdir_walk>
		if (!(pte && (*pte & auth) == auth)) {
f01031d8:	83 c4 10             	add    $0x10,%esp
f01031db:	85 c0                	test   %eax,%eax
f01031dd:	74 08                	je     f01031e7 <user_mem_check+0x83>
f01031df:	89 f2                	mov    %esi,%edx
f01031e1:	23 10                	and    (%eax),%edx
f01031e3:	39 d6                	cmp    %edx,%esi
f01031e5:	74 14                	je     f01031fb <user_mem_check+0x97>
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
f01031e7:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
f01031ea:	0f 44 5d 0c          	cmove  0xc(%ebp),%ebx
f01031ee:	89 1d dc e1 19 f0    	mov    %ebx,0xf019e1dc
			return -E_FAULT;
f01031f4:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01031f9:	eb 17                	jmp    f0103212 <user_mem_check+0xae>

	size_t i;
	int auth = perm | PTE_P;
	pte_t *pte;

	for (i = start; i < end; i += PGSIZE) {
f01031fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103201:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103204:	77 a3                	ja     f01031a9 <user_mem_check+0x45>
			user_mem_check_addr = (i == start) ? (uintptr_t)va : i;
			return -E_FAULT;
		}
	}

	return 0;
f0103206:	b8 00 00 00 00       	mov    $0x0,%eax
f010320b:	eb 05                	jmp    f0103212 <user_mem_check+0xae>
f010320d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103212:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103215:	5b                   	pop    %ebx
f0103216:	5e                   	pop    %esi
f0103217:	5f                   	pop    %edi
f0103218:	5d                   	pop    %ebp
f0103219:	c3                   	ret    

f010321a <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010321a:	55                   	push   %ebp
f010321b:	89 e5                	mov    %esp,%ebp
f010321d:	53                   	push   %ebx
f010321e:	83 ec 04             	sub    $0x4,%esp
f0103221:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103224:	8b 45 14             	mov    0x14(%ebp),%eax
f0103227:	83 c8 04             	or     $0x4,%eax
f010322a:	50                   	push   %eax
f010322b:	ff 75 10             	pushl  0x10(%ebp)
f010322e:	ff 75 0c             	pushl  0xc(%ebp)
f0103231:	53                   	push   %ebx
f0103232:	e8 2d ff ff ff       	call   f0103164 <user_mem_check>
f0103237:	83 c4 10             	add    $0x10,%esp
f010323a:	85 c0                	test   %eax,%eax
f010323c:	79 21                	jns    f010325f <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f010323e:	83 ec 04             	sub    $0x4,%esp
f0103241:	ff 35 dc e1 19 f0    	pushl  0xf019e1dc
f0103247:	ff 73 48             	pushl  0x48(%ebx)
f010324a:	68 d8 64 10 f0       	push   $0xf01064d8
f010324f:	e8 4b 07 00 00       	call   f010399f <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103254:	89 1c 24             	mov    %ebx,(%esp)
f0103257:	e8 23 06 00 00       	call   f010387f <env_destroy>
f010325c:	83 c4 10             	add    $0x10,%esp
	}
}
f010325f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103262:	c9                   	leave  
f0103263:	c3                   	ret    

f0103264 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103264:	55                   	push   %ebp
f0103265:	89 e5                	mov    %esp,%ebp
f0103267:	57                   	push   %edi
f0103268:	56                   	push   %esi
f0103269:	53                   	push   %ebx
f010326a:	83 ec 1c             	sub    $0x1c,%esp
f010326d:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f010326f:	89 d0                	mov    %edx,%eax
f0103271:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103276:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f0103279:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103280:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f0103286:	39 f0                	cmp    %esi,%eax
f0103288:	73 5e                	jae    f01032e8 <region_alloc+0x84>
f010328a:	89 c3                	mov    %eax,%ebx
		if (!(tmp = page_alloc(0))) {
f010328c:	83 ec 0c             	sub    $0xc,%esp
f010328f:	6a 00                	push   $0x0
f0103291:	e8 4e dd ff ff       	call   f0100fe4 <page_alloc>
f0103296:	83 c4 10             	add    $0x10,%esp
f0103299:	85 c0                	test   %eax,%eax
f010329b:	75 17                	jne    f01032b4 <region_alloc+0x50>
			panic("Execute region_alloc(...) failed. Out of memory.\n");
f010329d:	83 ec 04             	sub    $0x4,%esp
f01032a0:	68 f0 68 10 f0       	push   $0xf01068f0
f01032a5:	68 27 01 00 00       	push   $0x127
f01032aa:	68 ee 69 10 f0       	push   $0xf01069ee
f01032af:	e8 f1 cd ff ff       	call   f01000a5 <_panic>
		} else {
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
f01032b4:	6a 06                	push   $0x6
f01032b6:	53                   	push   %ebx
f01032b7:	50                   	push   %eax
f01032b8:	ff 77 60             	pushl  0x60(%edi)
f01032bb:	e8 c3 e3 ff ff       	call   f0101683 <page_insert>
f01032c0:	83 c4 10             	add    $0x10,%esp
f01032c3:	85 c0                	test   %eax,%eax
f01032c5:	74 17                	je     f01032de <region_alloc+0x7a>
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
f01032c7:	83 ec 04             	sub    $0x4,%esp
f01032ca:	68 24 69 10 f0       	push   $0xf0106924
f01032cf:	68 2a 01 00 00       	push   $0x12a
f01032d4:	68 ee 69 10 f0       	push   $0xf01069ee
f01032d9:	e8 c7 cd ff ff       	call   f01000a5 <_panic>
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f01032de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032e4:	39 de                	cmp    %ebx,%esi
f01032e6:	77 a4                	ja     f010328c <region_alloc+0x28>
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
			}
		}
	}
	e->env_cur_brk = start;
f01032e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032eb:	89 47 5c             	mov    %eax,0x5c(%edi)
}
f01032ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032f1:	5b                   	pop    %ebx
f01032f2:	5e                   	pop    %esi
f01032f3:	5f                   	pop    %edi
f01032f4:	5d                   	pop    %ebp
f01032f5:	c3                   	ret    

f01032f6 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01032f6:	55                   	push   %ebp
f01032f7:	89 e5                	mov    %esp,%ebp
f01032f9:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01032fc:	85 d2                	test   %edx,%edx
f01032fe:	75 11                	jne    f0103311 <envid2env+0x1b>
		*env_store = curenv;
f0103300:	a1 ec e1 19 f0       	mov    0xf019e1ec,%eax
f0103305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103308:	89 01                	mov    %eax,(%ecx)
		return 0;
f010330a:	b8 00 00 00 00       	mov    $0x0,%eax
f010330f:	eb 5d                	jmp    f010336e <envid2env+0x78>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103311:	89 d0                	mov    %edx,%eax
f0103313:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103318:	6b c0 64             	imul   $0x64,%eax,%eax
f010331b:	03 05 f0 e1 19 f0    	add    0xf019e1f0,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103321:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0103325:	74 05                	je     f010332c <envid2env+0x36>
f0103327:	3b 50 48             	cmp    0x48(%eax),%edx
f010332a:	74 10                	je     f010333c <envid2env+0x46>
		*env_store = 0;
f010332c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010332f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103335:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010333a:	eb 32                	jmp    f010336e <envid2env+0x78>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010333c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103340:	74 22                	je     f0103364 <envid2env+0x6e>
f0103342:	8b 15 ec e1 19 f0    	mov    0xf019e1ec,%edx
f0103348:	39 d0                	cmp    %edx,%eax
f010334a:	74 18                	je     f0103364 <envid2env+0x6e>
f010334c:	8b 4a 48             	mov    0x48(%edx),%ecx
f010334f:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0103352:	74 10                	je     f0103364 <envid2env+0x6e>
		*env_store = 0;
f0103354:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103357:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010335d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103362:	eb 0a                	jmp    f010336e <envid2env+0x78>
	}

	*env_store = e;
f0103364:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103367:	89 01                	mov    %eax,(%ecx)
	return 0;
f0103369:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010336e:	5d                   	pop    %ebp
f010336f:	c3                   	ret    

f0103370 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103370:	55                   	push   %ebp
f0103371:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103373:	b8 00 d3 11 f0       	mov    $0xf011d300,%eax
f0103378:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010337b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103380:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103382:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103384:	b8 10 00 00 00       	mov    $0x10,%eax
f0103389:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010338b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010338d:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010338f:	ea 96 33 10 f0 08 00 	ljmp   $0x8,$0xf0103396
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103396:	b8 00 00 00 00       	mov    $0x0,%eax
f010339b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010339e:	5d                   	pop    %ebp
f010339f:	c3                   	ret    

f01033a0 <env_init>:
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (size_t i = 0; i < NENV - 1; i++) {
		envs[i].env_link = &envs[i + 1];
f01033a0:	8b 0d f0 e1 19 f0    	mov    0xf019e1f0,%ecx
f01033a6:	8d 41 64             	lea    0x64(%ecx),%eax
f01033a9:	8d 91 00 90 01 00    	lea    0x19000(%ecx),%edx
f01033af:	89 40 e0             	mov    %eax,-0x20(%eax)
		envs[i].env_id = 0;
f01033b2:	c7 40 e4 00 00 00 00 	movl   $0x0,-0x1c(%eax)
		envs[i].env_status = ENV_FREE;
f01033b9:	c7 40 f0 00 00 00 00 	movl   $0x0,-0x10(%eax)
f01033c0:	83 c0 64             	add    $0x64,%eax
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (size_t i = 0; i < NENV - 1; i++) {
f01033c3:	39 d0                	cmp    %edx,%eax
f01033c5:	75 e8                	jne    f01033af <env_init+0xf>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01033c7:	55                   	push   %ebp
f01033c8:	89 e5                	mov    %esp,%ebp
	for (size_t i = 0; i < NENV - 1; i++) {
		envs[i].env_link = &envs[i + 1];
		envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
	}
	envs[NENV - 1].env_link = NULL;
f01033ca:	c7 81 e0 8f 01 00 00 	movl   $0x0,0x18fe0(%ecx)
f01033d1:	00 00 00 
	envs[NENV - 1].env_id = 0;
f01033d4:	c7 81 e4 8f 01 00 00 	movl   $0x0,0x18fe4(%ecx)
f01033db:	00 00 00 
	envs[NENV - 1].env_status = ENV_FREE;
f01033de:	c7 81 f0 8f 01 00 00 	movl   $0x0,0x18ff0(%ecx)
f01033e5:	00 00 00 
	env_free_list = envs;
f01033e8:	89 0d f4 e1 19 f0    	mov    %ecx,0xf019e1f4

	// Per-CPU part of the initialization
	env_init_percpu();
f01033ee:	e8 7d ff ff ff       	call   f0103370 <env_init_percpu>
}
f01033f3:	5d                   	pop    %ebp
f01033f4:	c3                   	ret    

f01033f5 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01033f5:	55                   	push   %ebp
f01033f6:	89 e5                	mov    %esp,%ebp
f01033f8:	53                   	push   %ebx
f01033f9:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01033fc:	8b 1d f4 e1 19 f0    	mov    0xf019e1f4,%ebx
f0103402:	85 db                	test   %ebx,%ebx
f0103404:	0f 84 54 01 00 00    	je     f010355e <env_alloc+0x169>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010340a:	83 ec 0c             	sub    $0xc,%esp
f010340d:	6a 01                	push   $0x1
f010340f:	e8 d0 db ff ff       	call   f0100fe4 <page_alloc>
f0103414:	83 c4 10             	add    $0x10,%esp
f0103417:	85 c0                	test   %eax,%eax
f0103419:	0f 84 46 01 00 00    	je     f0103565 <env_alloc+0x170>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010341f:	89 c2                	mov    %eax,%edx
f0103421:	2b 15 ac ee 19 f0    	sub    0xf019eeac,%edx
f0103427:	c1 fa 03             	sar    $0x3,%edx
f010342a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010342d:	89 d1                	mov    %edx,%ecx
f010342f:	c1 e9 0c             	shr    $0xc,%ecx
f0103432:	3b 0d a4 ee 19 f0    	cmp    0xf019eea4,%ecx
f0103438:	72 12                	jb     f010344c <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010343a:	52                   	push   %edx
f010343b:	68 74 5d 10 f0       	push   $0xf0105d74
f0103440:	6a 56                	push   $0x56
f0103442:	68 19 65 10 f0       	push   $0xf0106519
f0103447:	e8 59 cc ff ff       	call   f01000a5 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pte_t *)page2kva(p);
f010344c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103452:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f0103455:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010345a:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	// memmove(e->env_pgdir + PDX(UTOP), kern_pgdir + PDX(UTOP), NPDENTRIES - PDX(UTOP));
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f010345f:	8b 15 a8 ee 19 f0    	mov    0xf019eea8,%edx
f0103465:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103468:	8b 53 60             	mov    0x60(%ebx),%edx
f010346b:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010346e:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
	e->env_pgdir = (pte_t *)page2kva(p);
	p->pp_ref++;
	// memmove(e->env_pgdir + PDX(UTOP), kern_pgdir + PDX(UTOP), NPDENTRIES - PDX(UTOP));
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103471:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103476:	75 e7                	jne    f010345f <env_alloc+0x6a>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103478:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010347b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103480:	77 15                	ja     f0103497 <env_alloc+0xa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103482:	50                   	push   %eax
f0103483:	68 98 5d 10 f0       	push   $0xf0105d98
f0103488:	68 c8 00 00 00       	push   $0xc8
f010348d:	68 ee 69 10 f0       	push   $0xf01069ee
f0103492:	e8 0e cc ff ff       	call   f01000a5 <_panic>
f0103497:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010349d:	83 ca 05             	or     $0x5,%edx
f01034a0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01034a6:	8b 43 48             	mov    0x48(%ebx),%eax
f01034a9:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01034ae:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01034b3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01034b8:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01034bb:	89 da                	mov    %ebx,%edx
f01034bd:	2b 15 f0 e1 19 f0    	sub    0xf019e1f0,%edx
f01034c3:	c1 fa 02             	sar    $0x2,%edx
f01034c6:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f01034cc:	09 d0                	or     %edx,%eax
f01034ce:	89 43 48             	mov    %eax,0x48(%ebx)
	// cprintf("env_alloc env_id = %d\n", e->env_id);

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01034d1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034d4:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01034d7:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01034de:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f01034e5:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	e->env_cur_brk = 0;
f01034ec:	c7 43 5c 00 00 00 00 	movl   $0x0,0x5c(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01034f3:	83 ec 04             	sub    $0x4,%esp
f01034f6:	6a 44                	push   $0x44
f01034f8:	6a 00                	push   $0x0
f01034fa:	53                   	push   %ebx
f01034fb:	e8 64 1d 00 00       	call   f0105264 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103500:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103506:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010350c:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103512:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103519:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010351f:	8b 43 44             	mov    0x44(%ebx),%eax
f0103522:	a3 f4 e1 19 f0       	mov    %eax,0xf019e1f4
	*newenv_store = e;
f0103527:	8b 45 08             	mov    0x8(%ebp),%eax
f010352a:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010352c:	8b 53 48             	mov    0x48(%ebx),%edx
f010352f:	a1 ec e1 19 f0       	mov    0xf019e1ec,%eax
f0103534:	83 c4 10             	add    $0x10,%esp
f0103537:	85 c0                	test   %eax,%eax
f0103539:	74 05                	je     f0103540 <env_alloc+0x14b>
f010353b:	8b 40 48             	mov    0x48(%eax),%eax
f010353e:	eb 05                	jmp    f0103545 <env_alloc+0x150>
f0103540:	b8 00 00 00 00       	mov    $0x0,%eax
f0103545:	83 ec 04             	sub    $0x4,%esp
f0103548:	52                   	push   %edx
f0103549:	50                   	push   %eax
f010354a:	68 f9 69 10 f0       	push   $0xf01069f9
f010354f:	e8 4b 04 00 00       	call   f010399f <cprintf>
	return 0;
f0103554:	83 c4 10             	add    $0x10,%esp
f0103557:	b8 00 00 00 00       	mov    $0x0,%eax
f010355c:	eb 0c                	jmp    f010356a <env_alloc+0x175>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010355e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103563:	eb 05                	jmp    f010356a <env_alloc+0x175>
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103565:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010356a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010356d:	c9                   	leave  
f010356e:	c3                   	ret    

f010356f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010356f:	55                   	push   %ebp
f0103570:	89 e5                	mov    %esp,%ebp
f0103572:	57                   	push   %edi
f0103573:	56                   	push   %esi
f0103574:	53                   	push   %ebx
f0103575:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *env;
	int err = env_alloc(&env, 0);
f0103578:	6a 00                	push   $0x0
f010357a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010357d:	50                   	push   %eax
f010357e:	e8 72 fe ff ff       	call   f01033f5 <env_alloc>
	if (err) {
f0103583:	83 c4 10             	add    $0x10,%esp
f0103586:	85 c0                	test   %eax,%eax
f0103588:	74 3c                	je     f01035c6 <env_create+0x57>
		if (err == -E_NO_MEM) {
f010358a:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010358d:	75 17                	jne    f01035a6 <env_create+0x37>
			panic("env_create failed. env_alloc E_NO_MEM.\n");
f010358f:	83 ec 04             	sub    $0x4,%esp
f0103592:	68 60 69 10 f0       	push   $0xf0106960
f0103597:	68 95 01 00 00       	push   $0x195
f010359c:	68 ee 69 10 f0       	push   $0xf01069ee
f01035a1:	e8 ff ca ff ff       	call   f01000a5 <_panic>
		} else if (err == -E_NO_FREE_ENV) {
f01035a6:	83 f8 fb             	cmp    $0xfffffffb,%eax
f01035a9:	0f 85 0c 01 00 00    	jne    f01036bb <env_create+0x14c>
			panic("env_create failed. env_alloc E_NO_FREE_ENV.\n");
f01035af:	83 ec 04             	sub    $0x4,%esp
f01035b2:	68 88 69 10 f0       	push   $0xf0106988
f01035b7:	68 97 01 00 00       	push   $0x197
f01035bc:	68 ee 69 10 f0       	push   $0xf01069ee
f01035c1:	e8 df ca ff ff       	call   f01000a5 <_panic>
		}
	} else {
		load_icode(env, binary, size);
f01035c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *ELFHDR = (struct Elf *) binary;

	if (ELFHDR->e_magic != ELF_MAGIC) {
f01035c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01035cc:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01035d2:	74 17                	je     f01035eb <env_create+0x7c>
		panic("Invalid ELF.\n");
f01035d4:	83 ec 04             	sub    $0x4,%esp
f01035d7:	68 0e 6a 10 f0       	push   $0xf0106a0e
f01035dc:	68 6b 01 00 00       	push   $0x16b
f01035e1:	68 ee 69 10 f0       	push   $0xf01069ee
f01035e6:	e8 ba ca ff ff       	call   f01000a5 <_panic>
	}

	lcr3(PADDR(e->env_pgdir));
f01035eb:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035f3:	77 15                	ja     f010360a <env_create+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035f5:	50                   	push   %eax
f01035f6:	68 98 5d 10 f0       	push   $0xf0105d98
f01035fb:	68 6e 01 00 00       	push   $0x16e
f0103600:	68 ee 69 10 f0       	push   $0xf01069ee
f0103605:	e8 9b ca ff ff       	call   f01000a5 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010360a:	05 00 00 00 10       	add    $0x10000000,%eax
f010360f:	0f 22 d8             	mov    %eax,%cr3
	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
f0103612:	8b 45 08             	mov    0x8(%ebp),%eax
f0103615:	89 c3                	mov    %eax,%ebx
f0103617:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
f010361a:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f010361e:	c1 e6 05             	shl    $0x5,%esi
f0103621:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++) {
f0103623:	39 f3                	cmp    %esi,%ebx
f0103625:	73 48                	jae    f010366f <env_create+0x100>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103627:	83 3b 01             	cmpl   $0x1,(%ebx)
f010362a:	75 3c                	jne    f0103668 <env_create+0xf9>
			// cprintf("mem = %d  file = %d\n", ph->p_memsz, ph->p_filesz);
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010362c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010362f:	8b 53 08             	mov    0x8(%ebx),%edx
f0103632:	89 f8                	mov    %edi,%eax
f0103634:	e8 2b fc ff ff       	call   f0103264 <region_alloc>
			// lcr3(PADDR(e->env_pgdir));
			memmove((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
f0103639:	83 ec 04             	sub    $0x4,%esp
f010363c:	ff 73 10             	pushl  0x10(%ebx)
f010363f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103642:	03 43 04             	add    0x4(%ebx),%eax
f0103645:	50                   	push   %eax
f0103646:	ff 73 08             	pushl  0x8(%ebx)
f0103649:	e8 63 1c 00 00       	call   f01052b1 <memmove>
			memset((void *)(ph->p_va + ph->p_filesz), 0, (ph->p_memsz - ph->p_filesz));
f010364e:	8b 43 10             	mov    0x10(%ebx),%eax
f0103651:	83 c4 0c             	add    $0xc,%esp
f0103654:	8b 53 14             	mov    0x14(%ebx),%edx
f0103657:	29 c2                	sub    %eax,%edx
f0103659:	52                   	push   %edx
f010365a:	6a 00                	push   $0x0
f010365c:	03 43 08             	add    0x8(%ebx),%eax
f010365f:	50                   	push   %eax
f0103660:	e8 ff 1b 00 00       	call   f0105264 <memset>
f0103665:	83 c4 10             	add    $0x10,%esp
	}

	lcr3(PADDR(e->env_pgdir));
	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++) {
f0103668:	83 c3 20             	add    $0x20,%ebx
f010366b:	39 de                	cmp    %ebx,%esi
f010366d:	77 b8                	ja     f0103627 <env_create+0xb8>
			memmove((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
			memset((void *)(ph->p_va + ph->p_filesz), 0, (ph->p_memsz - ph->p_filesz));
			// lcr3(PADDR(kern_pgdir));
		}
	}
	lcr3(PADDR(kern_pgdir));
f010366f:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103674:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103679:	77 15                	ja     f0103690 <env_create+0x121>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010367b:	50                   	push   %eax
f010367c:	68 98 5d 10 f0       	push   $0xf0105d98
f0103681:	68 7b 01 00 00       	push   $0x17b
f0103686:	68 ee 69 10 f0       	push   $0xf01069ee
f010368b:	e8 15 ca ff ff       	call   f01000a5 <_panic>
f0103690:	05 00 00 00 10       	add    $0x10000000,%eax
f0103695:	0f 22 d8             	mov    %eax,%cr3

	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103698:	8b 45 08             	mov    0x8(%ebp),%eax
f010369b:	8b 40 18             	mov    0x18(%eax),%eax
f010369e:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f01036a1:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01036a6:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01036ab:	89 f8                	mov    %edi,%eax
f01036ad:	e8 b2 fb ff ff       	call   f0103264 <region_alloc>
		} else if (err == -E_NO_FREE_ENV) {
			panic("env_create failed. env_alloc E_NO_FREE_ENV.\n");
		}
	} else {
		load_icode(env, binary, size);
		env->env_type = type;
f01036b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01036b5:	8b 55 10             	mov    0x10(%ebp),%edx
f01036b8:	89 50 50             	mov    %edx,0x50(%eax)
	}
}
f01036bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036be:	5b                   	pop    %ebx
f01036bf:	5e                   	pop    %esi
f01036c0:	5f                   	pop    %edi
f01036c1:	5d                   	pop    %ebp
f01036c2:	c3                   	ret    

f01036c3 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01036c3:	55                   	push   %ebp
f01036c4:	89 e5                	mov    %esp,%ebp
f01036c6:	57                   	push   %edi
f01036c7:	56                   	push   %esi
f01036c8:	53                   	push   %ebx
f01036c9:	83 ec 1c             	sub    $0x1c,%esp
f01036cc:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01036cf:	8b 15 ec e1 19 f0    	mov    0xf019e1ec,%edx
f01036d5:	39 fa                	cmp    %edi,%edx
f01036d7:	75 29                	jne    f0103702 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f01036d9:	a1 a8 ee 19 f0       	mov    0xf019eea8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036e3:	77 15                	ja     f01036fa <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036e5:	50                   	push   %eax
f01036e6:	68 98 5d 10 f0       	push   $0xf0105d98
f01036eb:	68 ad 01 00 00       	push   $0x1ad
f01036f0:	68 ee 69 10 f0       	push   $0xf01069ee
f01036f5:	e8 ab c9 ff ff       	call   f01000a5 <_panic>
f01036fa:	05 00 00 00 10       	add    $0x10000000,%eax
f01036ff:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103702:	8b 4f 48             	mov    0x48(%edi),%ecx
f0103705:	85 d2                	test   %edx,%edx
f0103707:	74 05                	je     f010370e <env_free+0x4b>
f0103709:	8b 42 48             	mov    0x48(%edx),%eax
f010370c:	eb 05                	jmp    f0103713 <env_free+0x50>
f010370e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103713:	83 ec 04             	sub    $0x4,%esp
f0103716:	51                   	push   %ecx
f0103717:	50                   	push   %eax
f0103718:	68 1c 6a 10 f0       	push   $0xf0106a1c
f010371d:	e8 7d 02 00 00       	call   f010399f <cprintf>
f0103722:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103725:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010372c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010372f:	89 d0                	mov    %edx,%eax
f0103731:	c1 e0 02             	shl    $0x2,%eax
f0103734:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103737:	8b 47 60             	mov    0x60(%edi),%eax
f010373a:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010373d:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103743:	0f 84 a8 00 00 00    	je     f01037f1 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103749:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010374f:	89 f0                	mov    %esi,%eax
f0103751:	c1 e8 0c             	shr    $0xc,%eax
f0103754:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103757:	39 05 a4 ee 19 f0    	cmp    %eax,0xf019eea4
f010375d:	77 15                	ja     f0103774 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010375f:	56                   	push   %esi
f0103760:	68 74 5d 10 f0       	push   $0xf0105d74
f0103765:	68 bc 01 00 00       	push   $0x1bc
f010376a:	68 ee 69 10 f0       	push   $0xf01069ee
f010376f:	e8 31 c9 ff ff       	call   f01000a5 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103774:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103777:	c1 e0 16             	shl    $0x16,%eax
f010377a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010377d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103782:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103789:	01 
f010378a:	74 17                	je     f01037a3 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010378c:	83 ec 08             	sub    $0x8,%esp
f010378f:	89 d8                	mov    %ebx,%eax
f0103791:	c1 e0 0c             	shl    $0xc,%eax
f0103794:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103797:	50                   	push   %eax
f0103798:	ff 77 60             	pushl  0x60(%edi)
f010379b:	e8 a8 de ff ff       	call   f0101648 <page_remove>
f01037a0:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01037a3:	83 c3 01             	add    $0x1,%ebx
f01037a6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01037ac:	75 d4                	jne    f0103782 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01037ae:	8b 47 60             	mov    0x60(%edi),%eax
f01037b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037b4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01037be:	3b 05 a4 ee 19 f0    	cmp    0xf019eea4,%eax
f01037c4:	72 14                	jb     f01037da <env_free+0x117>
		panic("pa2page called with invalid pa");
f01037c6:	83 ec 04             	sub    $0x4,%esp
f01037c9:	68 a4 5e 10 f0       	push   $0xf0105ea4
f01037ce:	6a 4f                	push   $0x4f
f01037d0:	68 19 65 10 f0       	push   $0xf0106519
f01037d5:	e8 cb c8 ff ff       	call   f01000a5 <_panic>
		page_decref(pa2page(pa));
f01037da:	83 ec 0c             	sub    $0xc,%esp
f01037dd:	a1 ac ee 19 f0       	mov    0xf019eeac,%eax
f01037e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01037e5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01037e8:	50                   	push   %eax
f01037e9:	e8 82 dc ff ff       	call   f0101470 <page_decref>
f01037ee:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01037f1:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01037f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037f8:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01037fd:	0f 85 29 ff ff ff    	jne    f010372c <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103803:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103806:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010380b:	77 15                	ja     f0103822 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010380d:	50                   	push   %eax
f010380e:	68 98 5d 10 f0       	push   $0xf0105d98
f0103813:	68 ca 01 00 00       	push   $0x1ca
f0103818:	68 ee 69 10 f0       	push   $0xf01069ee
f010381d:	e8 83 c8 ff ff       	call   f01000a5 <_panic>
	e->env_pgdir = 0;
f0103822:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103829:	05 00 00 00 10       	add    $0x10000000,%eax
f010382e:	c1 e8 0c             	shr    $0xc,%eax
f0103831:	3b 05 a4 ee 19 f0    	cmp    0xf019eea4,%eax
f0103837:	72 14                	jb     f010384d <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0103839:	83 ec 04             	sub    $0x4,%esp
f010383c:	68 a4 5e 10 f0       	push   $0xf0105ea4
f0103841:	6a 4f                	push   $0x4f
f0103843:	68 19 65 10 f0       	push   $0xf0106519
f0103848:	e8 58 c8 ff ff       	call   f01000a5 <_panic>
	page_decref(pa2page(pa));
f010384d:	83 ec 0c             	sub    $0xc,%esp
f0103850:	8b 15 ac ee 19 f0    	mov    0xf019eeac,%edx
f0103856:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103859:	50                   	push   %eax
f010385a:	e8 11 dc ff ff       	call   f0101470 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010385f:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103866:	a1 f4 e1 19 f0       	mov    0xf019e1f4,%eax
f010386b:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010386e:	89 3d f4 e1 19 f0    	mov    %edi,0xf019e1f4
}
f0103874:	83 c4 10             	add    $0x10,%esp
f0103877:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010387a:	5b                   	pop    %ebx
f010387b:	5e                   	pop    %esi
f010387c:	5f                   	pop    %edi
f010387d:	5d                   	pop    %ebp
f010387e:	c3                   	ret    

f010387f <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010387f:	55                   	push   %ebp
f0103880:	89 e5                	mov    %esp,%ebp
f0103882:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0103885:	ff 75 08             	pushl  0x8(%ebp)
f0103888:	e8 36 fe ff ff       	call   f01036c3 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010388d:	c7 04 24 b8 69 10 f0 	movl   $0xf01069b8,(%esp)
f0103894:	e8 06 01 00 00       	call   f010399f <cprintf>
f0103899:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f010389c:	83 ec 0c             	sub    $0xc,%esp
f010389f:	6a 00                	push   $0x0
f01038a1:	e8 ce d0 ff ff       	call   f0100974 <monitor>
f01038a6:	83 c4 10             	add    $0x10,%esp
f01038a9:	eb f1                	jmp    f010389c <env_destroy+0x1d>

f01038ab <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01038ab:	55                   	push   %ebp
f01038ac:	89 e5                	mov    %esp,%ebp
f01038ae:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f01038b1:	8b 65 08             	mov    0x8(%ebp),%esp
f01038b4:	61                   	popa   
f01038b5:	07                   	pop    %es
f01038b6:	1f                   	pop    %ds
f01038b7:	83 c4 08             	add    $0x8,%esp
f01038ba:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01038bb:	68 32 6a 10 f0       	push   $0xf0106a32
f01038c0:	68 f2 01 00 00       	push   $0x1f2
f01038c5:	68 ee 69 10 f0       	push   $0xf01069ee
f01038ca:	e8 d6 c7 ff ff       	call   f01000a5 <_panic>

f01038cf <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01038cf:	55                   	push   %ebp
f01038d0:	89 e5                	mov    %esp,%ebp
f01038d2:	83 ec 08             	sub    $0x8,%esp
f01038d5:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f01038d8:	8b 15 ec e1 19 f0    	mov    0xf019e1ec,%edx
f01038de:	39 c2                	cmp    %eax,%edx
f01038e0:	74 48                	je     f010392a <env_run+0x5b>
		if (curenv && curenv->env_status == ENV_RUNNING) {
f01038e2:	85 d2                	test   %edx,%edx
f01038e4:	74 0d                	je     f01038f3 <env_run+0x24>
f01038e6:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f01038ea:	75 07                	jne    f01038f3 <env_run+0x24>
			curenv->env_status = ENV_RUNNABLE;
f01038ec:	c7 42 54 01 00 00 00 	movl   $0x1,0x54(%edx)
		}
		curenv = e;
f01038f3:	a3 ec e1 19 f0       	mov    %eax,0xf019e1ec
		curenv->env_status = ENV_RUNNING;
f01038f8:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv->env_runs++;
f01038ff:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0103903:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103906:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010390b:	77 15                	ja     f0103922 <env_run+0x53>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010390d:	50                   	push   %eax
f010390e:	68 98 5d 10 f0       	push   $0xf0105d98
f0103913:	68 17 02 00 00       	push   $0x217
f0103918:	68 ee 69 10 f0       	push   $0xf01069ee
f010391d:	e8 83 c7 ff ff       	call   f01000a5 <_panic>
f0103922:	05 00 00 00 10       	add    $0x10000000,%eax
f0103927:	0f 22 d8             	mov    %eax,%cr3
	}

	env_pop_tf(&curenv->env_tf);
f010392a:	83 ec 0c             	sub    $0xc,%esp
f010392d:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f0103933:	e8 73 ff ff ff       	call   f01038ab <env_pop_tf>

f0103938 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103938:	55                   	push   %ebp
f0103939:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010393b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103940:	8b 45 08             	mov    0x8(%ebp),%eax
f0103943:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103944:	ba 71 00 00 00       	mov    $0x71,%edx
f0103949:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010394a:	0f b6 c0             	movzbl %al,%eax
}
f010394d:	5d                   	pop    %ebp
f010394e:	c3                   	ret    

f010394f <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010394f:	55                   	push   %ebp
f0103950:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103952:	ba 70 00 00 00       	mov    $0x70,%edx
f0103957:	8b 45 08             	mov    0x8(%ebp),%eax
f010395a:	ee                   	out    %al,(%dx)
f010395b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103960:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103963:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103964:	5d                   	pop    %ebp
f0103965:	c3                   	ret    

f0103966 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103966:	55                   	push   %ebp
f0103967:	89 e5                	mov    %esp,%ebp
f0103969:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010396c:	ff 75 08             	pushl  0x8(%ebp)
f010396f:	e8 ac cc ff ff       	call   f0100620 <cputchar>
	*cnt++;
}
f0103974:	83 c4 10             	add    $0x10,%esp
f0103977:	c9                   	leave  
f0103978:	c3                   	ret    

f0103979 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103979:	55                   	push   %ebp
f010397a:	89 e5                	mov    %esp,%ebp
f010397c:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010397f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103986:	ff 75 0c             	pushl  0xc(%ebp)
f0103989:	ff 75 08             	pushl  0x8(%ebp)
f010398c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010398f:	50                   	push   %eax
f0103990:	68 66 39 10 f0       	push   $0xf0103966
f0103995:	e8 bc 10 00 00       	call   f0104a56 <vprintfmt>
	return cnt;
}
f010399a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010399d:	c9                   	leave  
f010399e:	c3                   	ret    

f010399f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010399f:	55                   	push   %ebp
f01039a0:	89 e5                	mov    %esp,%ebp
f01039a2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01039a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01039a8:	50                   	push   %eax
f01039a9:	ff 75 08             	pushl  0x8(%ebp)
f01039ac:	e8 c8 ff ff ff       	call   f0103979 <vcprintf>
	va_end(ap);

	return cnt;
}
f01039b1:	c9                   	leave  
f01039b2:	c3                   	ret    

f01039b3 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01039b3:	55                   	push   %ebp
f01039b4:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01039b6:	b8 20 ea 19 f0       	mov    $0xf019ea20,%eax
f01039bb:	c7 05 24 ea 19 f0 00 	movl   $0xefc00000,0xf019ea24
f01039c2:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f01039c5:	66 c7 05 28 ea 19 f0 	movw   $0x10,0xf019ea28
f01039cc:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01039ce:	66 c7 05 48 d3 11 f0 	movw   $0x68,0xf011d348
f01039d5:	68 00 
f01039d7:	66 a3 4a d3 11 f0    	mov    %ax,0xf011d34a
f01039dd:	89 c2                	mov    %eax,%edx
f01039df:	c1 ea 10             	shr    $0x10,%edx
f01039e2:	88 15 4c d3 11 f0    	mov    %dl,0xf011d34c
f01039e8:	c6 05 4e d3 11 f0 40 	movb   $0x40,0xf011d34e
f01039ef:	c1 e8 18             	shr    $0x18,%eax
f01039f2:	a2 4f d3 11 f0       	mov    %al,0xf011d34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01039f7:	c6 05 4d d3 11 f0 89 	movb   $0x89,0xf011d34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01039fe:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a03:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103a06:	b8 50 d3 11 f0       	mov    $0xf011d350,%eax
f0103a0b:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103a0e:	5d                   	pop    %ebp
f0103a0f:	c3                   	ret    

f0103a10 <trap_init>:
}


void
trap_init(void)
{
f0103a10:	55                   	push   %ebp
f0103a11:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 1, GD_KT, _divide_error, 0);
f0103a13:	b8 d2 40 10 f0       	mov    $0xf01040d2,%eax
f0103a18:	66 a3 00 e2 19 f0    	mov    %ax,0xf019e200
f0103a1e:	66 c7 05 02 e2 19 f0 	movw   $0x8,0xf019e202
f0103a25:	08 00 
f0103a27:	c6 05 04 e2 19 f0 00 	movb   $0x0,0xf019e204
f0103a2e:	c6 05 05 e2 19 f0 8f 	movb   $0x8f,0xf019e205
f0103a35:	c1 e8 10             	shr    $0x10,%eax
f0103a38:	66 a3 06 e2 19 f0    	mov    %ax,0xf019e206
	SETGATE(idt[T_DEBUG], 1, GD_KT, _debug, 0);
f0103a3e:	b8 dc 40 10 f0       	mov    $0xf01040dc,%eax
f0103a43:	66 a3 08 e2 19 f0    	mov    %ax,0xf019e208
f0103a49:	66 c7 05 0a e2 19 f0 	movw   $0x8,0xf019e20a
f0103a50:	08 00 
f0103a52:	c6 05 0c e2 19 f0 00 	movb   $0x0,0xf019e20c
f0103a59:	c6 05 0d e2 19 f0 8f 	movb   $0x8f,0xf019e20d
f0103a60:	c1 e8 10             	shr    $0x10,%eax
f0103a63:	66 a3 0e e2 19 f0    	mov    %ax,0xf019e20e
	SETGATE(idt[T_NMI], 1, GD_KT, _non_maskable_interrupt, 0);
f0103a69:	b8 e6 40 10 f0       	mov    $0xf01040e6,%eax
f0103a6e:	66 a3 10 e2 19 f0    	mov    %ax,0xf019e210
f0103a74:	66 c7 05 12 e2 19 f0 	movw   $0x8,0xf019e212
f0103a7b:	08 00 
f0103a7d:	c6 05 14 e2 19 f0 00 	movb   $0x0,0xf019e214
f0103a84:	c6 05 15 e2 19 f0 8f 	movb   $0x8f,0xf019e215
f0103a8b:	c1 e8 10             	shr    $0x10,%eax
f0103a8e:	66 a3 16 e2 19 f0    	mov    %ax,0xf019e216
	SETGATE(idt[T_BRKPT], 1, GD_KT, _breakpoint, 3);
f0103a94:	b8 f0 40 10 f0       	mov    $0xf01040f0,%eax
f0103a99:	66 a3 18 e2 19 f0    	mov    %ax,0xf019e218
f0103a9f:	66 c7 05 1a e2 19 f0 	movw   $0x8,0xf019e21a
f0103aa6:	08 00 
f0103aa8:	c6 05 1c e2 19 f0 00 	movb   $0x0,0xf019e21c
f0103aaf:	c6 05 1d e2 19 f0 ef 	movb   $0xef,0xf019e21d
f0103ab6:	c1 e8 10             	shr    $0x10,%eax
f0103ab9:	66 a3 1e e2 19 f0    	mov    %ax,0xf019e21e
	SETGATE(idt[T_OFLOW], 1, GD_KT, _overflow, 0);
f0103abf:	b8 f6 40 10 f0       	mov    $0xf01040f6,%eax
f0103ac4:	66 a3 20 e2 19 f0    	mov    %ax,0xf019e220
f0103aca:	66 c7 05 22 e2 19 f0 	movw   $0x8,0xf019e222
f0103ad1:	08 00 
f0103ad3:	c6 05 24 e2 19 f0 00 	movb   $0x0,0xf019e224
f0103ada:	c6 05 25 e2 19 f0 8f 	movb   $0x8f,0xf019e225
f0103ae1:	c1 e8 10             	shr    $0x10,%eax
f0103ae4:	66 a3 26 e2 19 f0    	mov    %ax,0xf019e226
	SETGATE(idt[T_BOUND], 1, GD_KT, _bound_range_exceeded, 0);
f0103aea:	b8 fc 40 10 f0       	mov    $0xf01040fc,%eax
f0103aef:	66 a3 28 e2 19 f0    	mov    %ax,0xf019e228
f0103af5:	66 c7 05 2a e2 19 f0 	movw   $0x8,0xf019e22a
f0103afc:	08 00 
f0103afe:	c6 05 2c e2 19 f0 00 	movb   $0x0,0xf019e22c
f0103b05:	c6 05 2d e2 19 f0 8f 	movb   $0x8f,0xf019e22d
f0103b0c:	c1 e8 10             	shr    $0x10,%eax
f0103b0f:	66 a3 2e e2 19 f0    	mov    %ax,0xf019e22e
	SETGATE(idt[T_ILLOP], 1, GD_KT, _invalid_opcode, 0);
f0103b15:	b8 02 41 10 f0       	mov    $0xf0104102,%eax
f0103b1a:	66 a3 30 e2 19 f0    	mov    %ax,0xf019e230
f0103b20:	66 c7 05 32 e2 19 f0 	movw   $0x8,0xf019e232
f0103b27:	08 00 
f0103b29:	c6 05 34 e2 19 f0 00 	movb   $0x0,0xf019e234
f0103b30:	c6 05 35 e2 19 f0 8f 	movb   $0x8f,0xf019e235
f0103b37:	c1 e8 10             	shr    $0x10,%eax
f0103b3a:	66 a3 36 e2 19 f0    	mov    %ax,0xf019e236
	SETGATE(idt[T_DEVICE], 1, GD_KT, _device_not_available, 0);
f0103b40:	b8 08 41 10 f0       	mov    $0xf0104108,%eax
f0103b45:	66 a3 38 e2 19 f0    	mov    %ax,0xf019e238
f0103b4b:	66 c7 05 3a e2 19 f0 	movw   $0x8,0xf019e23a
f0103b52:	08 00 
f0103b54:	c6 05 3c e2 19 f0 00 	movb   $0x0,0xf019e23c
f0103b5b:	c6 05 3d e2 19 f0 8f 	movb   $0x8f,0xf019e23d
f0103b62:	c1 e8 10             	shr    $0x10,%eax
f0103b65:	66 a3 3e e2 19 f0    	mov    %ax,0xf019e23e
	SETGATE(idt[T_DBLFLT], 1, GD_KT, _double_fault, 0);
f0103b6b:	b8 0e 41 10 f0       	mov    $0xf010410e,%eax
f0103b70:	66 a3 40 e2 19 f0    	mov    %ax,0xf019e240
f0103b76:	66 c7 05 42 e2 19 f0 	movw   $0x8,0xf019e242
f0103b7d:	08 00 
f0103b7f:	c6 05 44 e2 19 f0 00 	movb   $0x0,0xf019e244
f0103b86:	c6 05 45 e2 19 f0 8f 	movb   $0x8f,0xf019e245
f0103b8d:	c1 e8 10             	shr    $0x10,%eax
f0103b90:	66 a3 46 e2 19 f0    	mov    %ax,0xf019e246

	SETGATE(idt[T_TSS], 1, GD_KT, _invalid_tss, 0);
f0103b96:	b8 12 41 10 f0       	mov    $0xf0104112,%eax
f0103b9b:	66 a3 50 e2 19 f0    	mov    %ax,0xf019e250
f0103ba1:	66 c7 05 52 e2 19 f0 	movw   $0x8,0xf019e252
f0103ba8:	08 00 
f0103baa:	c6 05 54 e2 19 f0 00 	movb   $0x0,0xf019e254
f0103bb1:	c6 05 55 e2 19 f0 8f 	movb   $0x8f,0xf019e255
f0103bb8:	c1 e8 10             	shr    $0x10,%eax
f0103bbb:	66 a3 56 e2 19 f0    	mov    %ax,0xf019e256
	SETGATE(idt[T_SEGNP], 1, GD_KT, _segment_not_present, 0);
f0103bc1:	b8 16 41 10 f0       	mov    $0xf0104116,%eax
f0103bc6:	66 a3 58 e2 19 f0    	mov    %ax,0xf019e258
f0103bcc:	66 c7 05 5a e2 19 f0 	movw   $0x8,0xf019e25a
f0103bd3:	08 00 
f0103bd5:	c6 05 5c e2 19 f0 00 	movb   $0x0,0xf019e25c
f0103bdc:	c6 05 5d e2 19 f0 8f 	movb   $0x8f,0xf019e25d
f0103be3:	c1 e8 10             	shr    $0x10,%eax
f0103be6:	66 a3 5e e2 19 f0    	mov    %ax,0xf019e25e
	SETGATE(idt[T_STACK], 1, GD_KT, _stack_fault, 0);
f0103bec:	b8 1a 41 10 f0       	mov    $0xf010411a,%eax
f0103bf1:	66 a3 60 e2 19 f0    	mov    %ax,0xf019e260
f0103bf7:	66 c7 05 62 e2 19 f0 	movw   $0x8,0xf019e262
f0103bfe:	08 00 
f0103c00:	c6 05 64 e2 19 f0 00 	movb   $0x0,0xf019e264
f0103c07:	c6 05 65 e2 19 f0 8f 	movb   $0x8f,0xf019e265
f0103c0e:	c1 e8 10             	shr    $0x10,%eax
f0103c11:	66 a3 66 e2 19 f0    	mov    %ax,0xf019e266
	SETGATE(idt[T_GPFLT], 1, GD_KT, _general_protection, 0);
f0103c17:	b8 1e 41 10 f0       	mov    $0xf010411e,%eax
f0103c1c:	66 a3 68 e2 19 f0    	mov    %ax,0xf019e268
f0103c22:	66 c7 05 6a e2 19 f0 	movw   $0x8,0xf019e26a
f0103c29:	08 00 
f0103c2b:	c6 05 6c e2 19 f0 00 	movb   $0x0,0xf019e26c
f0103c32:	c6 05 6d e2 19 f0 8f 	movb   $0x8f,0xf019e26d
f0103c39:	c1 e8 10             	shr    $0x10,%eax
f0103c3c:	66 a3 6e e2 19 f0    	mov    %ax,0xf019e26e
	SETGATE(idt[T_PGFLT], 1, GD_KT, _page_fault, 0);
f0103c42:	b8 22 41 10 f0       	mov    $0xf0104122,%eax
f0103c47:	66 a3 70 e2 19 f0    	mov    %ax,0xf019e270
f0103c4d:	66 c7 05 72 e2 19 f0 	movw   $0x8,0xf019e272
f0103c54:	08 00 
f0103c56:	c6 05 74 e2 19 f0 00 	movb   $0x0,0xf019e274
f0103c5d:	c6 05 75 e2 19 f0 8f 	movb   $0x8f,0xf019e275
f0103c64:	c1 e8 10             	shr    $0x10,%eax
f0103c67:	66 a3 76 e2 19 f0    	mov    %ax,0xf019e276

	SETGATE(idt[T_FPERR], 1, GD_KT, _x87_fpu_error, 0);
f0103c6d:	b8 26 41 10 f0       	mov    $0xf0104126,%eax
f0103c72:	66 a3 80 e2 19 f0    	mov    %ax,0xf019e280
f0103c78:	66 c7 05 82 e2 19 f0 	movw   $0x8,0xf019e282
f0103c7f:	08 00 
f0103c81:	c6 05 84 e2 19 f0 00 	movb   $0x0,0xf019e284
f0103c88:	c6 05 85 e2 19 f0 8f 	movb   $0x8f,0xf019e285
f0103c8f:	c1 e8 10             	shr    $0x10,%eax
f0103c92:	66 a3 86 e2 19 f0    	mov    %ax,0xf019e286
	SETGATE(idt[T_ALIGN], 1, GD_KT, _alignment_check, 0);
f0103c98:	b8 2c 41 10 f0       	mov    $0xf010412c,%eax
f0103c9d:	66 a3 88 e2 19 f0    	mov    %ax,0xf019e288
f0103ca3:	66 c7 05 8a e2 19 f0 	movw   $0x8,0xf019e28a
f0103caa:	08 00 
f0103cac:	c6 05 8c e2 19 f0 00 	movb   $0x0,0xf019e28c
f0103cb3:	c6 05 8d e2 19 f0 8f 	movb   $0x8f,0xf019e28d
f0103cba:	c1 e8 10             	shr    $0x10,%eax
f0103cbd:	66 a3 8e e2 19 f0    	mov    %ax,0xf019e28e
	SETGATE(idt[T_MCHK], 1, GD_KT, _machine_check, 0);
f0103cc3:	b8 30 41 10 f0       	mov    $0xf0104130,%eax
f0103cc8:	66 a3 90 e2 19 f0    	mov    %ax,0xf019e290
f0103cce:	66 c7 05 92 e2 19 f0 	movw   $0x8,0xf019e292
f0103cd5:	08 00 
f0103cd7:	c6 05 94 e2 19 f0 00 	movb   $0x0,0xf019e294
f0103cde:	c6 05 95 e2 19 f0 8f 	movb   $0x8f,0xf019e295
f0103ce5:	c1 e8 10             	shr    $0x10,%eax
f0103ce8:	66 a3 96 e2 19 f0    	mov    %ax,0xf019e296
	SETGATE(idt[T_SIMDERR], 1, GD_KT, _simd_fp_exception, 0);
f0103cee:	b8 36 41 10 f0       	mov    $0xf0104136,%eax
f0103cf3:	66 a3 98 e2 19 f0    	mov    %ax,0xf019e298
f0103cf9:	66 c7 05 9a e2 19 f0 	movw   $0x8,0xf019e29a
f0103d00:	08 00 
f0103d02:	c6 05 9c e2 19 f0 00 	movb   $0x0,0xf019e29c
f0103d09:	c6 05 9d e2 19 f0 8f 	movb   $0x8f,0xf019e29d
f0103d10:	c1 e8 10             	shr    $0x10,%eax
f0103d13:	66 a3 9e e2 19 f0    	mov    %ax,0xf019e29e

	extern void sysenter_handler();
	wrmsr(0x174, GD_KT, 0);
f0103d19:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d1e:	b8 08 00 00 00       	mov    $0x8,%eax
f0103d23:	b9 74 01 00 00       	mov    $0x174,%ecx
f0103d28:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP, 0);
f0103d2a:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f0103d2f:	b9 75 01 00 00       	mov    $0x175,%ecx
f0103d34:	0f 30                	wrmsr  
	wrmsr(0x176, sysenter_handler, 0);
f0103d36:	b8 3c 41 10 f0       	mov    $0xf010413c,%eax
f0103d3b:	b9 76 01 00 00       	mov    $0x176,%ecx
f0103d40:	0f 30                	wrmsr  

	// Per-CPU setup
	trap_init_percpu();
f0103d42:	e8 6c fc ff ff       	call   f01039b3 <trap_init_percpu>
}
f0103d47:	5d                   	pop    %ebp
f0103d48:	c3                   	ret    

f0103d49 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d49:	55                   	push   %ebp
f0103d4a:	89 e5                	mov    %esp,%ebp
f0103d4c:	53                   	push   %ebx
f0103d4d:	83 ec 0c             	sub    $0xc,%esp
f0103d50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d53:	ff 33                	pushl  (%ebx)
f0103d55:	68 3e 6a 10 f0       	push   $0xf0106a3e
f0103d5a:	e8 40 fc ff ff       	call   f010399f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d5f:	83 c4 08             	add    $0x8,%esp
f0103d62:	ff 73 04             	pushl  0x4(%ebx)
f0103d65:	68 4d 6a 10 f0       	push   $0xf0106a4d
f0103d6a:	e8 30 fc ff ff       	call   f010399f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d6f:	83 c4 08             	add    $0x8,%esp
f0103d72:	ff 73 08             	pushl  0x8(%ebx)
f0103d75:	68 5c 6a 10 f0       	push   $0xf0106a5c
f0103d7a:	e8 20 fc ff ff       	call   f010399f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d7f:	83 c4 08             	add    $0x8,%esp
f0103d82:	ff 73 0c             	pushl  0xc(%ebx)
f0103d85:	68 6b 6a 10 f0       	push   $0xf0106a6b
f0103d8a:	e8 10 fc ff ff       	call   f010399f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d8f:	83 c4 08             	add    $0x8,%esp
f0103d92:	ff 73 10             	pushl  0x10(%ebx)
f0103d95:	68 7a 6a 10 f0       	push   $0xf0106a7a
f0103d9a:	e8 00 fc ff ff       	call   f010399f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d9f:	83 c4 08             	add    $0x8,%esp
f0103da2:	ff 73 14             	pushl  0x14(%ebx)
f0103da5:	68 89 6a 10 f0       	push   $0xf0106a89
f0103daa:	e8 f0 fb ff ff       	call   f010399f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103daf:	83 c4 08             	add    $0x8,%esp
f0103db2:	ff 73 18             	pushl  0x18(%ebx)
f0103db5:	68 98 6a 10 f0       	push   $0xf0106a98
f0103dba:	e8 e0 fb ff ff       	call   f010399f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103dbf:	83 c4 08             	add    $0x8,%esp
f0103dc2:	ff 73 1c             	pushl  0x1c(%ebx)
f0103dc5:	68 a7 6a 10 f0       	push   $0xf0106aa7
f0103dca:	e8 d0 fb ff ff       	call   f010399f <cprintf>
}
f0103dcf:	83 c4 10             	add    $0x10,%esp
f0103dd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103dd5:	c9                   	leave  
f0103dd6:	c3                   	ret    

f0103dd7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103dd7:	55                   	push   %ebp
f0103dd8:	89 e5                	mov    %esp,%ebp
f0103dda:	56                   	push   %esi
f0103ddb:	53                   	push   %ebx
f0103ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103ddf:	83 ec 08             	sub    $0x8,%esp
f0103de2:	53                   	push   %ebx
f0103de3:	68 f6 6b 10 f0       	push   $0xf0106bf6
f0103de8:	e8 b2 fb ff ff       	call   f010399f <cprintf>
	print_regs(&tf->tf_regs);
f0103ded:	89 1c 24             	mov    %ebx,(%esp)
f0103df0:	e8 54 ff ff ff       	call   f0103d49 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103df5:	83 c4 08             	add    $0x8,%esp
f0103df8:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103dfc:	50                   	push   %eax
f0103dfd:	68 f8 6a 10 f0       	push   $0xf0106af8
f0103e02:	e8 98 fb ff ff       	call   f010399f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e07:	83 c4 08             	add    $0x8,%esp
f0103e0a:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e0e:	50                   	push   %eax
f0103e0f:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0103e14:	e8 86 fb ff ff       	call   f010399f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e19:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103e1c:	83 c4 10             	add    $0x10,%esp
f0103e1f:	83 f8 13             	cmp    $0x13,%eax
f0103e22:	77 09                	ja     f0103e2d <print_trapframe+0x56>
		return excnames[trapno];
f0103e24:	8b 14 85 c0 6d 10 f0 	mov    -0xfef9240(,%eax,4),%edx
f0103e2b:	eb 10                	jmp    f0103e3d <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0103e2d:	83 f8 30             	cmp    $0x30,%eax
f0103e30:	b9 c2 6a 10 f0       	mov    $0xf0106ac2,%ecx
f0103e35:	ba b6 6a 10 f0       	mov    $0xf0106ab6,%edx
f0103e3a:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e3d:	83 ec 04             	sub    $0x4,%esp
f0103e40:	52                   	push   %edx
f0103e41:	50                   	push   %eax
f0103e42:	68 1e 6b 10 f0       	push   $0xf0106b1e
f0103e47:	e8 53 fb ff ff       	call   f010399f <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e4c:	83 c4 10             	add    $0x10,%esp
f0103e4f:	3b 1d 00 ea 19 f0    	cmp    0xf019ea00,%ebx
f0103e55:	75 1a                	jne    f0103e71 <print_trapframe+0x9a>
f0103e57:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e5b:	75 14                	jne    f0103e71 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103e5d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e60:	83 ec 08             	sub    $0x8,%esp
f0103e63:	50                   	push   %eax
f0103e64:	68 30 6b 10 f0       	push   $0xf0106b30
f0103e69:	e8 31 fb ff ff       	call   f010399f <cprintf>
f0103e6e:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103e71:	83 ec 08             	sub    $0x8,%esp
f0103e74:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e77:	68 3f 6b 10 f0       	push   $0xf0106b3f
f0103e7c:	e8 1e fb ff ff       	call   f010399f <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e81:	83 c4 10             	add    $0x10,%esp
f0103e84:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e88:	75 49                	jne    f0103ed3 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e8a:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103e8d:	89 c2                	mov    %eax,%edx
f0103e8f:	83 e2 01             	and    $0x1,%edx
f0103e92:	ba dc 6a 10 f0       	mov    $0xf0106adc,%edx
f0103e97:	b9 d1 6a 10 f0       	mov    $0xf0106ad1,%ecx
f0103e9c:	0f 44 ca             	cmove  %edx,%ecx
f0103e9f:	89 c2                	mov    %eax,%edx
f0103ea1:	83 e2 02             	and    $0x2,%edx
f0103ea4:	ba ee 6a 10 f0       	mov    $0xf0106aee,%edx
f0103ea9:	be e8 6a 10 f0       	mov    $0xf0106ae8,%esi
f0103eae:	0f 45 d6             	cmovne %esi,%edx
f0103eb1:	83 e0 04             	and    $0x4,%eax
f0103eb4:	be 21 6c 10 f0       	mov    $0xf0106c21,%esi
f0103eb9:	b8 f3 6a 10 f0       	mov    $0xf0106af3,%eax
f0103ebe:	0f 44 c6             	cmove  %esi,%eax
f0103ec1:	51                   	push   %ecx
f0103ec2:	52                   	push   %edx
f0103ec3:	50                   	push   %eax
f0103ec4:	68 4d 6b 10 f0       	push   $0xf0106b4d
f0103ec9:	e8 d1 fa ff ff       	call   f010399f <cprintf>
f0103ece:	83 c4 10             	add    $0x10,%esp
f0103ed1:	eb 10                	jmp    f0103ee3 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103ed3:	83 ec 0c             	sub    $0xc,%esp
f0103ed6:	68 5a 5a 10 f0       	push   $0xf0105a5a
f0103edb:	e8 bf fa ff ff       	call   f010399f <cprintf>
f0103ee0:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103ee3:	83 ec 08             	sub    $0x8,%esp
f0103ee6:	ff 73 30             	pushl  0x30(%ebx)
f0103ee9:	68 5c 6b 10 f0       	push   $0xf0106b5c
f0103eee:	e8 ac fa ff ff       	call   f010399f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ef3:	83 c4 08             	add    $0x8,%esp
f0103ef6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103efa:	50                   	push   %eax
f0103efb:	68 6b 6b 10 f0       	push   $0xf0106b6b
f0103f00:	e8 9a fa ff ff       	call   f010399f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f05:	83 c4 08             	add    $0x8,%esp
f0103f08:	ff 73 38             	pushl  0x38(%ebx)
f0103f0b:	68 7e 6b 10 f0       	push   $0xf0106b7e
f0103f10:	e8 8a fa ff ff       	call   f010399f <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f15:	83 c4 10             	add    $0x10,%esp
f0103f18:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f1c:	74 25                	je     f0103f43 <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f1e:	83 ec 08             	sub    $0x8,%esp
f0103f21:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f24:	68 8d 6b 10 f0       	push   $0xf0106b8d
f0103f29:	e8 71 fa ff ff       	call   f010399f <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f2e:	83 c4 08             	add    $0x8,%esp
f0103f31:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f35:	50                   	push   %eax
f0103f36:	68 9c 6b 10 f0       	push   $0xf0106b9c
f0103f3b:	e8 5f fa ff ff       	call   f010399f <cprintf>
f0103f40:	83 c4 10             	add    $0x10,%esp
	}
}
f0103f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f46:	5b                   	pop    %ebx
f0103f47:	5e                   	pop    %esi
f0103f48:	5d                   	pop    %ebp
f0103f49:	c3                   	ret    

f0103f4a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103f4a:	55                   	push   %ebp
f0103f4b:	89 e5                	mov    %esp,%ebp
f0103f4d:	53                   	push   %ebx
f0103f4e:	83 ec 04             	sub    $0x4,%esp
f0103f51:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f54:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (!(tf->tf_cs & 0x03)) {
f0103f57:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f5b:	75 17                	jne    f0103f74 <page_fault_handler+0x2a>
		panic("Kernek mode page fault.\n");
f0103f5d:	83 ec 04             	sub    $0x4,%esp
f0103f60:	68 af 6b 10 f0       	push   $0xf0106baf
f0103f65:	68 0a 01 00 00       	push   $0x10a
f0103f6a:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0103f6f:	e8 31 c1 ff ff       	call   f01000a5 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103f74:	ff 73 30             	pushl  0x30(%ebx)
f0103f77:	50                   	push   %eax
f0103f78:	a1 ec e1 19 f0       	mov    0xf019e1ec,%eax
f0103f7d:	ff 70 48             	pushl  0x48(%eax)
f0103f80:	68 6c 6d 10 f0       	push   $0xf0106d6c
f0103f85:	e8 15 fa ff ff       	call   f010399f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103f8a:	89 1c 24             	mov    %ebx,(%esp)
f0103f8d:	e8 45 fe ff ff       	call   f0103dd7 <print_trapframe>
	env_destroy(curenv);
f0103f92:	83 c4 04             	add    $0x4,%esp
f0103f95:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f0103f9b:	e8 df f8 ff ff       	call   f010387f <env_destroy>
}
f0103fa0:	83 c4 10             	add    $0x10,%esp
f0103fa3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103fa6:	c9                   	leave  
f0103fa7:	c3                   	ret    

f0103fa8 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103fa8:	55                   	push   %ebp
f0103fa9:	89 e5                	mov    %esp,%ebp
f0103fab:	57                   	push   %edi
f0103fac:	56                   	push   %esi
f0103fad:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103fb0:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103fb1:	9c                   	pushf  
f0103fb2:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103fb3:	f6 c4 02             	test   $0x2,%ah
f0103fb6:	74 19                	je     f0103fd1 <trap+0x29>
f0103fb8:	68 d4 6b 10 f0       	push   $0xf0106bd4
f0103fbd:	68 33 65 10 f0       	push   $0xf0106533
f0103fc2:	68 e2 00 00 00       	push   $0xe2
f0103fc7:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0103fcc:	e8 d4 c0 ff ff       	call   f01000a5 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103fd1:	83 ec 08             	sub    $0x8,%esp
f0103fd4:	56                   	push   %esi
f0103fd5:	68 ed 6b 10 f0       	push   $0xf0106bed
f0103fda:	e8 c0 f9 ff ff       	call   f010399f <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103fdf:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103fe3:	83 e0 03             	and    $0x3,%eax
f0103fe6:	83 c4 10             	add    $0x10,%esp
f0103fe9:	66 83 f8 03          	cmp    $0x3,%ax
f0103fed:	75 31                	jne    f0104020 <trap+0x78>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103fef:	a1 ec e1 19 f0       	mov    0xf019e1ec,%eax
f0103ff4:	85 c0                	test   %eax,%eax
f0103ff6:	75 19                	jne    f0104011 <trap+0x69>
f0103ff8:	68 08 6c 10 f0       	push   $0xf0106c08
f0103ffd:	68 33 65 10 f0       	push   $0xf0106533
f0104002:	68 eb 00 00 00       	push   $0xeb
f0104007:	68 c8 6b 10 f0       	push   $0xf0106bc8
f010400c:	e8 94 c0 ff ff       	call   f01000a5 <_panic>
		curenv->env_tf = *tf;
f0104011:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104016:	89 c7                	mov    %eax,%edi
f0104018:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010401a:	8b 35 ec e1 19 f0    	mov    0xf019e1ec,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104020:	89 35 00 ea 19 f0    	mov    %esi,0xf019ea00
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
f0104026:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f010402a:	75 0c                	jne    f0104038 <trap+0x90>
		page_fault_handler(tf);
f010402c:	83 ec 0c             	sub    $0xc,%esp
f010402f:	56                   	push   %esi
f0104030:	e8 15 ff ff ff       	call   f0103f4a <page_fault_handler>
f0104035:	83 c4 10             	add    $0x10,%esp
	}
	switch (tf->tf_trapno) {
f0104038:	8b 46 28             	mov    0x28(%esi),%eax
f010403b:	83 f8 03             	cmp    $0x3,%eax
f010403e:	74 1a                	je     f010405a <trap+0xb2>
f0104040:	83 f8 0e             	cmp    $0xe,%eax
f0104043:	74 07                	je     f010404c <trap+0xa4>
f0104045:	83 f8 01             	cmp    $0x1,%eax
f0104048:	75 1c                	jne    f0104066 <trap+0xbe>
f010404a:	eb 0e                	jmp    f010405a <trap+0xb2>
		case T_PGFLT:
			page_fault_handler(tf);
f010404c:	83 ec 0c             	sub    $0xc,%esp
f010404f:	56                   	push   %esi
f0104050:	e8 f5 fe ff ff       	call   f0103f4a <page_fault_handler>
f0104055:	83 c4 10             	add    $0x10,%esp
f0104058:	eb 0c                	jmp    f0104066 <trap+0xbe>
			break;
		case T_DEBUG:
		case T_BRKPT:
			monitor(tf);
f010405a:	83 ec 0c             	sub    $0xc,%esp
f010405d:	56                   	push   %esi
f010405e:	e8 11 c9 ff ff       	call   f0100974 <monitor>
f0104063:	83 c4 10             	add    $0x10,%esp
		default:
			break;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104066:	83 ec 0c             	sub    $0xc,%esp
f0104069:	56                   	push   %esi
f010406a:	e8 68 fd ff ff       	call   f0103dd7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010406f:	83 c4 10             	add    $0x10,%esp
f0104072:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104077:	75 17                	jne    f0104090 <trap+0xe8>
		panic("unhandled trap in kernel");
f0104079:	83 ec 04             	sub    $0x4,%esp
f010407c:	68 0f 6c 10 f0       	push   $0xf0106c0f
f0104081:	68 d1 00 00 00       	push   $0xd1
f0104086:	68 c8 6b 10 f0       	push   $0xf0106bc8
f010408b:	e8 15 c0 ff ff       	call   f01000a5 <_panic>
	else {
		env_destroy(curenv);
f0104090:	83 ec 0c             	sub    $0xc,%esp
f0104093:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f0104099:	e8 e1 f7 ff ff       	call   f010387f <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010409e:	a1 ec e1 19 f0       	mov    0xf019e1ec,%eax
f01040a3:	83 c4 10             	add    $0x10,%esp
f01040a6:	85 c0                	test   %eax,%eax
f01040a8:	74 06                	je     f01040b0 <trap+0x108>
f01040aa:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01040ae:	74 19                	je     f01040c9 <trap+0x121>
f01040b0:	68 90 6d 10 f0       	push   $0xf0106d90
f01040b5:	68 33 65 10 f0       	push   $0xf0106533
f01040ba:	68 f9 00 00 00       	push   $0xf9
f01040bf:	68 c8 6b 10 f0       	push   $0xf0106bc8
f01040c4:	e8 dc bf ff ff       	call   f01000a5 <_panic>
	env_run(curenv);
f01040c9:	83 ec 0c             	sub    $0xc,%esp
f01040cc:	50                   	push   %eax
f01040cd:	e8 fd f7 ff ff       	call   f01038cf <env_run>

f01040d2 <_divide_error>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
  TRAPHANDLER_NOEC(_divide_error, T_DIVIDE);
f01040d2:	6a 00                	push   $0x0
f01040d4:	6a 00                	push   $0x0
f01040d6:	e9 95 00 00 00       	jmp    f0104170 <_alltraps>
f01040db:	90                   	nop

f01040dc <_debug>:
  TRAPHANDLER_NOEC(_debug, T_DEBUG);
f01040dc:	6a 00                	push   $0x0
f01040de:	6a 01                	push   $0x1
f01040e0:	e9 8b 00 00 00       	jmp    f0104170 <_alltraps>
f01040e5:	90                   	nop

f01040e6 <_non_maskable_interrupt>:
  TRAPHANDLER_NOEC(_non_maskable_interrupt, T_NMI);
f01040e6:	6a 00                	push   $0x0
f01040e8:	6a 02                	push   $0x2
f01040ea:	e9 81 00 00 00       	jmp    f0104170 <_alltraps>
f01040ef:	90                   	nop

f01040f0 <_breakpoint>:
  TRAPHANDLER_NOEC(_breakpoint, T_BRKPT);
f01040f0:	6a 00                	push   $0x0
f01040f2:	6a 03                	push   $0x3
f01040f4:	eb 7a                	jmp    f0104170 <_alltraps>

f01040f6 <_overflow>:
  TRAPHANDLER_NOEC(_overflow, T_OFLOW);
f01040f6:	6a 00                	push   $0x0
f01040f8:	6a 04                	push   $0x4
f01040fa:	eb 74                	jmp    f0104170 <_alltraps>

f01040fc <_bound_range_exceeded>:
  TRAPHANDLER_NOEC(_bound_range_exceeded, T_BOUND);
f01040fc:	6a 00                	push   $0x0
f01040fe:	6a 05                	push   $0x5
f0104100:	eb 6e                	jmp    f0104170 <_alltraps>

f0104102 <_invalid_opcode>:
  TRAPHANDLER_NOEC(_invalid_opcode, T_ILLOP);
f0104102:	6a 00                	push   $0x0
f0104104:	6a 06                	push   $0x6
f0104106:	eb 68                	jmp    f0104170 <_alltraps>

f0104108 <_device_not_available>:
  TRAPHANDLER_NOEC(_device_not_available, T_DEVICE);
f0104108:	6a 00                	push   $0x0
f010410a:	6a 07                	push   $0x7
f010410c:	eb 62                	jmp    f0104170 <_alltraps>

f010410e <_double_fault>:
  TRAPHANDLER(_double_fault, T_DBLFLT);
f010410e:	6a 08                	push   $0x8
f0104110:	eb 5e                	jmp    f0104170 <_alltraps>

f0104112 <_invalid_tss>:

  TRAPHANDLER(_invalid_tss, T_TSS);
f0104112:	6a 0a                	push   $0xa
f0104114:	eb 5a                	jmp    f0104170 <_alltraps>

f0104116 <_segment_not_present>:
  TRAPHANDLER(_segment_not_present, T_SEGNP);
f0104116:	6a 0b                	push   $0xb
f0104118:	eb 56                	jmp    f0104170 <_alltraps>

f010411a <_stack_fault>:
  TRAPHANDLER(_stack_fault, T_STACK);
f010411a:	6a 0c                	push   $0xc
f010411c:	eb 52                	jmp    f0104170 <_alltraps>

f010411e <_general_protection>:
  TRAPHANDLER(_general_protection, T_GPFLT);
f010411e:	6a 0d                	push   $0xd
f0104120:	eb 4e                	jmp    f0104170 <_alltraps>

f0104122 <_page_fault>:
  TRAPHANDLER(_page_fault, T_PGFLT);
f0104122:	6a 0e                	push   $0xe
f0104124:	eb 4a                	jmp    f0104170 <_alltraps>

f0104126 <_x87_fpu_error>:

  TRAPHANDLER_NOEC(_x87_fpu_error, T_FPERR);
f0104126:	6a 00                	push   $0x0
f0104128:	6a 10                	push   $0x10
f010412a:	eb 44                	jmp    f0104170 <_alltraps>

f010412c <_alignment_check>:
  TRAPHANDLER(_alignment_check, T_ALIGN);
f010412c:	6a 11                	push   $0x11
f010412e:	eb 40                	jmp    f0104170 <_alltraps>

f0104130 <_machine_check>:
  TRAPHANDLER_NOEC(_machine_check, T_MCHK);
f0104130:	6a 00                	push   $0x0
f0104132:	6a 12                	push   $0x12
f0104134:	eb 3a                	jmp    f0104170 <_alltraps>

f0104136 <_simd_fp_exception>:
  TRAPHANDLER_NOEC(_simd_fp_exception, T_SIMDERR );
f0104136:	6a 00                	push   $0x0
f0104138:	6a 13                	push   $0x13
f010413a:	eb 34                	jmp    f0104170 <_alltraps>

f010413c <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
   pushl $GD_UD
f010413c:	6a 20                	push   $0x20
   pushl %ebp
f010413e:	55                   	push   %ebp
   pushfl
f010413f:	9c                   	pushf  
   pushl $GD_UT
f0104140:	6a 18                	push   $0x18
   pushl %esi
f0104142:	56                   	push   %esi
   pushl $0
f0104143:	6a 00                	push   $0x0
 	 pushl $0
f0104145:	6a 00                	push   $0x0

   pushw $0    # uint16_t tf_padding2
f0104147:	66 6a 00             	pushw  $0x0
   pushw %ds
f010414a:	66 1e                	pushw  %ds
   pushw $0    # uint16_t tf_padding1
f010414c:	66 6a 00             	pushw  $0x0
   pushw %es
f010414f:	66 06                	pushw  %es
   pushal
f0104151:	60                   	pusha  

   movw $GD_KD, %ax
f0104152:	66 b8 10 00          	mov    $0x10,%ax
   movw %ax, %ds
f0104156:	8e d8                	mov    %eax,%ds
   movw %ax, %es
f0104158:	8e c0                	mov    %eax,%es
   pushl %esp
f010415a:	54                   	push   %esp

   call syscall_helper
f010415b:	e8 11 02 00 00       	call   f0104371 <syscall_helper>

   popl %esp
f0104160:	5c                   	pop    %esp
   popal
f0104161:	61                   	popa   
   popw %cx  # eliminate padding
f0104162:	66 59                	pop    %cx
   popw %es
f0104164:	66 07                	popw   %es
   popw %cx  # eliminate padding
f0104166:	66 59                	pop    %cx
   popw %ds
f0104168:	66 1f                	popw   %ds

   movl %ebp, %ecx
f010416a:	89 e9                	mov    %ebp,%ecx
   movl %esi, %edx
f010416c:	89 f2                	mov    %esi,%edx
   sysexit
f010416e:	0f 35                	sysexit 

f0104170 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
  pushw $0    # uint16_t tf_padding2
f0104170:	66 6a 00             	pushw  $0x0
	pushw %ds
f0104173:	66 1e                	pushw  %ds
	pushw $0    # uint16_t tf_padding1
f0104175:	66 6a 00             	pushw  $0x0
	pushw %es
f0104178:	66 06                	pushw  %es
	pushal
f010417a:	60                   	pusha  

  movl $GD_KD, %eax
f010417b:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104180:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104182:	8e c0                	mov    %eax,%es
	pushl %esp
f0104184:	54                   	push   %esp

	call trap
f0104185:	e8 1e fe ff ff       	call   f0103fa8 <trap>

f010418a <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010418a:	55                   	push   %ebp
f010418b:	89 e5                	mov    %esp,%ebp
f010418d:	57                   	push   %edi
f010418e:	56                   	push   %esi
f010418f:	53                   	push   %ebx
f0104190:	83 ec 2c             	sub    $0x2c,%esp
f0104193:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104196:	83 f8 05             	cmp    $0x5,%eax
f0104199:	0f 87 c5 01 00 00    	ja     f0104364 <syscall+0x1da>
f010419f:	ff 24 85 58 6e 10 f0 	jmp    *-0xfef91a8(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void*)s, len, 0);
f01041a6:	6a 00                	push   $0x0
f01041a8:	ff 75 10             	pushl  0x10(%ebp)
f01041ab:	ff 75 0c             	pushl  0xc(%ebp)
f01041ae:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f01041b4:	e8 61 f0 ff ff       	call   f010321a <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01041b9:	83 c4 0c             	add    $0xc,%esp
f01041bc:	ff 75 0c             	pushl  0xc(%ebp)
f01041bf:	ff 75 10             	pushl  0x10(%ebp)
f01041c2:	68 10 6e 10 f0       	push   $0xf0106e10
f01041c7:	e8 d3 f7 ff ff       	call   f010399f <cprintf>
f01041cc:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char *) a1, a2);
			return 0;
f01041cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01041d4:	e9 90 01 00 00       	jmp    f0104369 <syscall+0x1df>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01041d9:	e8 ec c2 ff ff       	call   f01004ca <cons_getc>
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char *) a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f01041de:	e9 86 01 00 00       	jmp    f0104369 <syscall+0x1df>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01041e3:	a1 ec e1 19 f0       	mov    0xf019e1ec,%eax
f01041e8:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((const char *) a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f01041eb:	e9 79 01 00 00       	jmp    f0104369 <syscall+0x1df>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01041f0:	83 ec 04             	sub    $0x4,%esp
f01041f3:	6a 01                	push   $0x1
f01041f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01041f8:	50                   	push   %eax
f01041f9:	ff 75 0c             	pushl  0xc(%ebp)
f01041fc:	e8 f5 f0 ff ff       	call   f01032f6 <envid2env>
f0104201:	83 c4 10             	add    $0x10,%esp
f0104204:	85 c0                	test   %eax,%eax
f0104206:	0f 88 5d 01 00 00    	js     f0104369 <syscall+0x1df>
		return r;
	if (e == curenv)
f010420c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010420f:	8b 15 ec e1 19 f0    	mov    0xf019e1ec,%edx
f0104215:	39 d0                	cmp    %edx,%eax
f0104217:	75 15                	jne    f010422e <syscall+0xa4>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104219:	83 ec 08             	sub    $0x8,%esp
f010421c:	ff 70 48             	pushl  0x48(%eax)
f010421f:	68 15 6e 10 f0       	push   $0xf0106e15
f0104224:	e8 76 f7 ff ff       	call   f010399f <cprintf>
f0104229:	83 c4 10             	add    $0x10,%esp
f010422c:	eb 16                	jmp    f0104244 <syscall+0xba>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010422e:	83 ec 04             	sub    $0x4,%esp
f0104231:	ff 70 48             	pushl  0x48(%eax)
f0104234:	ff 72 48             	pushl  0x48(%edx)
f0104237:	68 30 6e 10 f0       	push   $0xf0106e30
f010423c:	e8 5e f7 ff ff       	call   f010399f <cprintf>
f0104241:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104244:	83 ec 0c             	sub    $0xc,%esp
f0104247:	ff 75 e4             	pushl  -0x1c(%ebp)
f010424a:	e8 30 f6 ff ff       	call   f010387f <env_destroy>
f010424f:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104252:	b8 00 00 00 00       	mov    $0x0,%eax
f0104257:	e9 0d 01 00 00       	jmp    f0104369 <syscall+0x1df>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010425c:	81 7d 0c ff ff ff ef 	cmpl   $0xefffffff,0xc(%ebp)
f0104263:	77 14                	ja     f0104279 <syscall+0xef>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104265:	ff 75 0c             	pushl  0xc(%ebp)
f0104268:	68 98 5d 10 f0       	push   $0xf0105d98
f010426d:	6a 46                	push   $0x46
f010426f:	68 48 6e 10 f0       	push   $0xf0106e48
f0104274:	e8 2c be ff ff       	call   f01000a5 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104279:	8b 45 0c             	mov    0xc(%ebp),%eax
f010427c:	05 00 00 00 10       	add    $0x10000000,%eax
f0104281:	c1 e8 0c             	shr    $0xc,%eax
f0104284:	3b 05 a4 ee 19 f0    	cmp    0xf019eea4,%eax
f010428a:	72 14                	jb     f01042a0 <syscall+0x116>
		panic("pa2page called with invalid pa");
f010428c:	83 ec 04             	sub    $0x4,%esp
f010428f:	68 a4 5e 10 f0       	push   $0xf0105ea4
f0104294:	6a 4f                	push   $0x4f
f0104296:	68 19 65 10 f0       	push   $0xf0106519
f010429b:	e8 05 be ff ff       	call   f01000a5 <_panic>
	return &pages[PGNUM(pa)];
f01042a0:	8b 15 ac ee 19 f0    	mov    0xf019eeac,%edx
f01042a6:	8d 14 c2             	lea    (%edx,%eax,8),%edx
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p == NULL)
		return E_INVAL;
f01042a9:	b8 03 00 00 00       	mov    $0x3,%eax
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p == NULL)
f01042ae:	85 d2                	test   %edx,%edx
f01042b0:	0f 84 b3 00 00 00    	je     f0104369 <syscall+0x1df>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f01042b6:	6a 06                	push   $0x6
f01042b8:	ff 75 10             	pushl  0x10(%ebp)
f01042bb:	52                   	push   %edx
f01042bc:	a1 ec e1 19 f0       	mov    0xf019e1ec,%eax
f01042c1:	ff 70 60             	pushl  0x60(%eax)
f01042c4:	e8 ba d3 ff ff       	call   f0101683 <page_insert>
f01042c9:	83 c4 10             	add    $0x10,%esp
f01042cc:	e9 98 00 00 00       	jmp    f0104369 <syscall+0x1df>

static int
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_cur_brk + inc), inc);
f01042d1:	8b 3d ec e1 19 f0    	mov    0xf019e1ec,%edi
f01042d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042da:	03 47 5c             	add    0x5c(%edi),%eax
}

static void
region_alloc(struct Env *e, void *va, size_t len)
{
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
f01042dd:	89 c1                	mov    %eax,%ecx
f01042df:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01042e5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
f01042e8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01042eb:	8d b4 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%esi
f01042f2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f01042f8:	39 f1                	cmp    %esi,%ecx
f01042fa:	73 58                	jae    f0104354 <syscall+0x1ca>
f01042fc:	89 cb                	mov    %ecx,%ebx
		if (!(tmp = page_alloc(0))) {
f01042fe:	83 ec 0c             	sub    $0xc,%esp
f0104301:	6a 00                	push   $0x0
f0104303:	e8 dc cc ff ff       	call   f0100fe4 <page_alloc>
f0104308:	83 c4 10             	add    $0x10,%esp
f010430b:	85 c0                	test   %eax,%eax
f010430d:	75 14                	jne    f0104323 <syscall+0x199>
			panic("Execute region_alloc(...) failed. Out of memory.\n");
f010430f:	83 ec 04             	sub    $0x4,%esp
f0104312:	68 f0 68 10 f0       	push   $0xf01068f0
f0104317:	6a 57                	push   $0x57
f0104319:	68 48 6e 10 f0       	push   $0xf0106e48
f010431e:	e8 82 bd ff ff       	call   f01000a5 <_panic>
		} else {
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
f0104323:	6a 06                	push   $0x6
f0104325:	53                   	push   %ebx
f0104326:	50                   	push   %eax
f0104327:	ff 77 60             	pushl  0x60(%edi)
f010432a:	e8 54 d3 ff ff       	call   f0101683 <page_insert>
f010432f:	83 c4 10             	add    $0x10,%esp
f0104332:	85 c0                	test   %eax,%eax
f0104334:	74 14                	je     f010434a <syscall+0x1c0>
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
f0104336:	83 ec 04             	sub    $0x4,%esp
f0104339:	68 24 69 10 f0       	push   $0xf0106924
f010433e:	6a 5a                	push   $0x5a
f0104340:	68 48 6e 10 f0       	push   $0xf0106e48
f0104345:	e8 5b bd ff ff       	call   f01000a5 <_panic>
	size_t start = (size_t)ROUNDDOWN(va, PGSIZE);
	size_t end = (size_t)ROUNDUP(va + len, PGSIZE);
	size_t i;
	struct Page *tmp;

	for (i = start; i < end; i += PGSIZE) {
f010434a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104350:	39 de                	cmp    %ebx,%esi
f0104352:	77 aa                	ja     f01042fe <syscall+0x174>
			if (page_insert(e->env_pgdir, tmp, (void *)i, PTE_W | PTE_U)) {
				panic("page_insert in region_alloc failed. Cannot insert page.\n");
			}
		}
	}
	e->env_cur_brk = start;
f0104354:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104357:	89 47 5c             	mov    %eax,0x5c(%edi)
sys_sbrk(uint32_t inc)
{
	// LAB3: your code sbrk here...
	region_alloc(curenv, (void *)(curenv->env_cur_brk + inc), inc);
	// cprintf("sbrk %x inc %x\n", curenv->env_cur_brk, inc);
	return curenv->env_cur_brk;
f010435a:	a1 ec e1 19 f0       	mov    0xf019e1ec,%eax
f010435f:	8b 40 5c             	mov    0x5c(%eax),%eax
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_map_kernel_page:
			return sys_map_kernel_page((void *)a1, (void *)a2);
		case SYS_sbrk:
			return sys_sbrk(a1);
f0104362:	eb 05                	jmp    f0104369 <syscall+0x1df>
		default:
			return -E_INVAL;
f0104364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	// panic("syscall not implemented");
}
f0104369:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010436c:	5b                   	pop    %ebx
f010436d:	5e                   	pop    %esi
f010436e:	5f                   	pop    %edi
f010436f:	5d                   	pop    %ebp
f0104370:	c3                   	ret    

f0104371 <syscall_helper>:

void
syscall_helper(struct Trapframe *tf)
{
f0104371:	55                   	push   %ebp
f0104372:	89 e5                	mov    %esp,%ebp
f0104374:	57                   	push   %edi
f0104375:	56                   	push   %esi
f0104376:	53                   	push   %ebx
f0104377:	83 ec 14             	sub    $0x14,%esp
f010437a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	curenv->env_tf = *tf;
f010437d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104382:	8b 3d ec e1 19 f0    	mov    0xf019e1ec,%edi
f0104388:	89 de                	mov    %ebx,%esi
f010438a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, 0);
f010438c:	6a 00                	push   $0x0
f010438e:	ff 33                	pushl  (%ebx)
f0104390:	ff 73 10             	pushl  0x10(%ebx)
f0104393:	ff 73 18             	pushl  0x18(%ebx)
f0104396:	ff 73 14             	pushl  0x14(%ebx)
f0104399:	ff 73 1c             	pushl  0x1c(%ebx)
f010439c:	e8 e9 fd ff ff       	call   f010418a <syscall>
f01043a1:	89 43 1c             	mov    %eax,0x1c(%ebx)
}
f01043a4:	83 c4 20             	add    $0x20,%esp
f01043a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043aa:	5b                   	pop    %ebx
f01043ab:	5e                   	pop    %esi
f01043ac:	5f                   	pop    %edi
f01043ad:	5d                   	pop    %ebp
f01043ae:	c3                   	ret    

f01043af <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01043af:	55                   	push   %ebp
f01043b0:	89 e5                	mov    %esp,%ebp
f01043b2:	57                   	push   %edi
f01043b3:	56                   	push   %esi
f01043b4:	53                   	push   %ebx
f01043b5:	83 ec 14             	sub    $0x14,%esp
f01043b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01043bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01043be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01043c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01043c4:	8b 1a                	mov    (%edx),%ebx
f01043c6:	8b 01                	mov    (%ecx),%eax
f01043c8:	89 45 f0             	mov    %eax,-0x10(%ebp)

	while (l <= r) {
f01043cb:	39 c3                	cmp    %eax,%ebx
f01043cd:	0f 8f 9a 00 00 00    	jg     f010446d <stab_binsearch+0xbe>
f01043d3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f01043da:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01043dd:	01 d8                	add    %ebx,%eax
f01043df:	89 c6                	mov    %eax,%esi
f01043e1:	c1 ee 1f             	shr    $0x1f,%esi
f01043e4:	01 c6                	add    %eax,%esi
f01043e6:	d1 fe                	sar    %esi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01043e8:	39 de                	cmp    %ebx,%esi
f01043ea:	0f 8c c4 00 00 00    	jl     f01044b4 <stab_binsearch+0x105>
f01043f0:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01043f3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01043f6:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01043f9:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f01043fd:	39 c7                	cmp    %eax,%edi
f01043ff:	0f 84 b4 00 00 00    	je     f01044b9 <stab_binsearch+0x10a>
f0104405:	89 f0                	mov    %esi,%eax
			m--;
f0104407:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010440a:	39 d8                	cmp    %ebx,%eax
f010440c:	0f 8c a2 00 00 00    	jl     f01044b4 <stab_binsearch+0x105>
f0104412:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0104416:	83 ea 0c             	sub    $0xc,%edx
f0104419:	39 f9                	cmp    %edi,%ecx
f010441b:	75 ea                	jne    f0104407 <stab_binsearch+0x58>
f010441d:	e9 99 00 00 00       	jmp    f01044bb <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104422:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104425:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104427:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010442a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104431:	eb 2b                	jmp    f010445e <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104433:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104436:	76 14                	jbe    f010444c <stab_binsearch+0x9d>
			*region_right = m - 1;
f0104438:	83 e8 01             	sub    $0x1,%eax
f010443b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010443e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104441:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104443:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010444a:	eb 12                	jmp    f010445e <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010444c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010444f:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104451:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104455:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104457:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010445e:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f0104461:	0f 8d 73 ff ff ff    	jge    f01043da <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104467:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010446b:	75 0f                	jne    f010447c <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f010446d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104470:	8b 00                	mov    (%eax),%eax
f0104472:	83 e8 01             	sub    $0x1,%eax
f0104475:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104478:	89 07                	mov    %eax,(%edi)
f010447a:	eb 57                	jmp    f01044d3 <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010447c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010447f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104481:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104484:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104486:	39 c8                	cmp    %ecx,%eax
f0104488:	7e 23                	jle    f01044ad <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f010448a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010448d:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104490:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104493:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104497:	39 df                	cmp    %ebx,%edi
f0104499:	74 12                	je     f01044ad <stab_binsearch+0xfe>
		     l--)
f010449b:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010449e:	39 c8                	cmp    %ecx,%eax
f01044a0:	7e 0b                	jle    f01044ad <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f01044a2:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f01044a6:	83 ea 0c             	sub    $0xc,%edx
f01044a9:	39 df                	cmp    %ebx,%edi
f01044ab:	75 ee                	jne    f010449b <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f01044ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01044b0:	89 07                	mov    %eax,(%edi)
	}
}
f01044b2:	eb 1f                	jmp    f01044d3 <stab_binsearch+0x124>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01044b4:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01044b7:	eb a5                	jmp    f010445e <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01044b9:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01044bb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01044be:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01044c1:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01044c5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01044c8:	0f 82 54 ff ff ff    	jb     f0104422 <stab_binsearch+0x73>
f01044ce:	e9 60 ff ff ff       	jmp    f0104433 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01044d3:	83 c4 14             	add    $0x14,%esp
f01044d6:	5b                   	pop    %ebx
f01044d7:	5e                   	pop    %esi
f01044d8:	5f                   	pop    %edi
f01044d9:	5d                   	pop    %ebp
f01044da:	c3                   	ret    

f01044db <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01044db:	55                   	push   %ebp
f01044dc:	89 e5                	mov    %esp,%ebp
f01044de:	57                   	push   %edi
f01044df:	56                   	push   %esi
f01044e0:	53                   	push   %ebx
f01044e1:	83 ec 3c             	sub    $0x3c,%esp
f01044e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01044e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01044ea:	c7 03 70 6e 10 f0    	movl   $0xf0106e70,(%ebx)
	info->eip_line = 0;
f01044f0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01044f7:	c7 43 08 70 6e 10 f0 	movl   $0xf0106e70,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01044fe:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104505:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104508:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010450f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104515:	0f 87 8a 00 00 00    	ja     f01045a5 <debuginfo_eip+0xca>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U)) {
f010451b:	6a 04                	push   $0x4
f010451d:	6a 10                	push   $0x10
f010451f:	68 00 00 20 00       	push   $0x200000
f0104524:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f010452a:	e8 35 ec ff ff       	call   f0103164 <user_mem_check>
f010452f:	83 c4 10             	add    $0x10,%esp
f0104532:	85 c0                	test   %eax,%eax
f0104534:	0f 85 41 02 00 00    	jne    f010477b <debuginfo_eip+0x2a0>
			return -1;
		}

		stabs = usd->stabs;
f010453a:	a1 00 00 20 00       	mov    0x200000,%eax
f010453f:	89 c1                	mov    %eax,%ecx
f0104541:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104544:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010454a:	a1 08 00 20 00       	mov    0x200008,%eax
f010454f:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104552:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104558:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
f010455b:	6a 04                	push   $0x4
f010455d:	89 f8                	mov    %edi,%eax
f010455f:	29 c8                	sub    %ecx,%eax
f0104561:	c1 f8 02             	sar    $0x2,%eax
f0104564:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010456a:	50                   	push   %eax
f010456b:	51                   	push   %ecx
f010456c:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f0104572:	e8 ed eb ff ff       	call   f0103164 <user_mem_check>
f0104577:	83 c4 10             	add    $0x10,%esp
f010457a:	85 c0                	test   %eax,%eax
f010457c:	0f 85 00 02 00 00    	jne    f0104782 <debuginfo_eip+0x2a7>
			return -1;
		}

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
f0104582:	6a 04                	push   $0x4
f0104584:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104587:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010458a:	29 ca                	sub    %ecx,%edx
f010458c:	52                   	push   %edx
f010458d:	51                   	push   %ecx
f010458e:	ff 35 ec e1 19 f0    	pushl  0xf019e1ec
f0104594:	e8 cb eb ff ff       	call   f0103164 <user_mem_check>
f0104599:	83 c4 10             	add    $0x10,%esp
f010459c:	85 c0                	test   %eax,%eax
f010459e:	74 1f                	je     f01045bf <debuginfo_eip+0xe4>
f01045a0:	e9 e4 01 00 00       	jmp    f0104789 <debuginfo_eip+0x2ae>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01045a5:	c7 45 bc 5a 28 11 f0 	movl   $0xf011285a,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01045ac:	c7 45 b8 25 fc 10 f0 	movl   $0xf010fc25,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01045b3:	bf 24 fc 10 f0       	mov    $0xf010fc24,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01045b8:	c7 45 c0 04 71 10 f0 	movl   $0xf0107104,-0x40(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01045bf:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01045c2:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01045c5:	0f 83 c5 01 00 00    	jae    f0104790 <debuginfo_eip+0x2b5>
f01045cb:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01045cf:	0f 85 c2 01 00 00    	jne    f0104797 <debuginfo_eip+0x2bc>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01045d5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01045dc:	2b 7d c0             	sub    -0x40(%ebp),%edi
f01045df:	c1 ff 02             	sar    $0x2,%edi
f01045e2:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01045e8:	83 e8 01             	sub    $0x1,%eax
f01045eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01045ee:	83 ec 08             	sub    $0x8,%esp
f01045f1:	56                   	push   %esi
f01045f2:	6a 64                	push   $0x64
f01045f4:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01045f7:	89 d1                	mov    %edx,%ecx
f01045f9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01045fc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01045ff:	89 f8                	mov    %edi,%eax
f0104601:	e8 a9 fd ff ff       	call   f01043af <stab_binsearch>
	if (lfile == 0)
f0104606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104609:	83 c4 10             	add    $0x10,%esp
f010460c:	85 c0                	test   %eax,%eax
f010460e:	0f 84 8a 01 00 00    	je     f010479e <debuginfo_eip+0x2c3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104614:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104617:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010461a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010461d:	83 ec 08             	sub    $0x8,%esp
f0104620:	56                   	push   %esi
f0104621:	6a 24                	push   $0x24
f0104623:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104626:	89 d1                	mov    %edx,%ecx
f0104628:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010462b:	89 f8                	mov    %edi,%eax
f010462d:	e8 7d fd ff ff       	call   f01043af <stab_binsearch>

	if (lfun <= rfun) {
f0104632:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104635:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104638:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010463b:	83 c4 10             	add    $0x10,%esp
f010463e:	39 d0                	cmp    %edx,%eax
f0104640:	7f 2b                	jg     f010466d <debuginfo_eip+0x192>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104642:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104645:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104648:	8b 11                	mov    (%ecx),%edx
f010464a:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010464d:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0104650:	39 fa                	cmp    %edi,%edx
f0104652:	73 06                	jae    f010465a <debuginfo_eip+0x17f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104654:	03 55 b8             	add    -0x48(%ebp),%edx
f0104657:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010465a:	8b 51 08             	mov    0x8(%ecx),%edx
f010465d:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104660:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104662:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104665:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104668:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010466b:	eb 0f                	jmp    f010467c <debuginfo_eip+0x1a1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010466d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104673:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104676:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104679:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010467c:	83 ec 08             	sub    $0x8,%esp
f010467f:	6a 3a                	push   $0x3a
f0104681:	ff 73 08             	pushl  0x8(%ebx)
f0104684:	e8 b3 0b 00 00       	call   f010523c <strfind>
f0104689:	2b 43 08             	sub    0x8(%ebx),%eax
f010468c:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010468f:	83 c4 08             	add    $0x8,%esp
f0104692:	56                   	push   %esi
f0104693:	6a 44                	push   $0x44
f0104695:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104698:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010469b:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010469e:	89 f0                	mov    %esi,%eax
f01046a0:	e8 0a fd ff ff       	call   f01043af <stab_binsearch>
	if (lline <= rline) {
f01046a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01046a8:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01046ab:	83 c4 10             	add    $0x10,%esp
f01046ae:	39 d0                	cmp    %edx,%eax
f01046b0:	0f 8f ef 00 00 00    	jg     f01047a5 <debuginfo_eip+0x2ca>
		info->eip_line = rline;
f01046b6:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01046b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01046bc:	39 f8                	cmp    %edi,%eax
f01046be:	7c 69                	jl     f0104729 <debuginfo_eip+0x24e>
	       && stabs[lline].n_type != N_SOL
f01046c0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01046c3:	8d 34 96             	lea    (%esi,%edx,4),%esi
f01046c6:	0f b6 56 04          	movzbl 0x4(%esi),%edx
f01046ca:	80 fa 84             	cmp    $0x84,%dl
f01046cd:	74 41                	je     f0104710 <debuginfo_eip+0x235>
f01046cf:	89 f1                	mov    %esi,%ecx
f01046d1:	83 c6 08             	add    $0x8,%esi
f01046d4:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01046d8:	eb 1f                	jmp    f01046f9 <debuginfo_eip+0x21e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01046da:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01046dd:	39 f8                	cmp    %edi,%eax
f01046df:	7c 48                	jl     f0104729 <debuginfo_eip+0x24e>
	       && stabs[lline].n_type != N_SOL
f01046e1:	0f b6 51 f8          	movzbl -0x8(%ecx),%edx
f01046e5:	83 e9 0c             	sub    $0xc,%ecx
f01046e8:	83 ee 0c             	sub    $0xc,%esi
f01046eb:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01046ef:	80 fa 84             	cmp    $0x84,%dl
f01046f2:	75 05                	jne    f01046f9 <debuginfo_eip+0x21e>
f01046f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01046f7:	eb 17                	jmp    f0104710 <debuginfo_eip+0x235>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01046f9:	80 fa 64             	cmp    $0x64,%dl
f01046fc:	75 dc                	jne    f01046da <debuginfo_eip+0x1ff>
f01046fe:	83 3e 00             	cmpl   $0x0,(%esi)
f0104701:	74 d7                	je     f01046da <debuginfo_eip+0x1ff>
f0104703:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104707:	74 03                	je     f010470c <debuginfo_eip+0x231>
f0104709:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010470c:	39 c7                	cmp    %eax,%edi
f010470e:	7f 19                	jg     f0104729 <debuginfo_eip+0x24e>
f0104710:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104713:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104716:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104719:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010471c:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010471f:	29 f8                	sub    %edi,%eax
f0104721:	39 c2                	cmp    %eax,%edx
f0104723:	73 04                	jae    f0104729 <debuginfo_eip+0x24e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104725:	01 fa                	add    %edi,%edx
f0104727:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104729:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010472c:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010472f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104734:	39 f2                	cmp    %esi,%edx
f0104736:	0f 8d 83 00 00 00    	jge    f01047bf <debuginfo_eip+0x2e4>
		for (lline = lfun + 1;
f010473c:	8d 42 01             	lea    0x1(%edx),%eax
f010473f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104742:	39 c6                	cmp    %eax,%esi
f0104744:	7e 66                	jle    f01047ac <debuginfo_eip+0x2d1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104746:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104749:	c1 e1 02             	shl    $0x2,%ecx
f010474c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010474f:	80 7c 0f 04 a0       	cmpb   $0xa0,0x4(%edi,%ecx,1)
f0104754:	75 5d                	jne    f01047b3 <debuginfo_eip+0x2d8>
f0104756:	8d 42 02             	lea    0x2(%edx),%eax
f0104759:	8d 54 0f f4          	lea    -0xc(%edi,%ecx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f010475d:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104761:	39 c6                	cmp    %eax,%esi
f0104763:	74 55                	je     f01047ba <debuginfo_eip+0x2df>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104765:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f0104769:	83 c0 01             	add    $0x1,%eax
f010476c:	83 c2 0c             	add    $0xc,%edx
f010476f:	80 f9 a0             	cmp    $0xa0,%cl
f0104772:	74 e9                	je     f010475d <debuginfo_eip+0x282>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104774:	b8 00 00 00 00       	mov    $0x0,%eax
f0104779:	eb 44                	jmp    f01047bf <debuginfo_eip+0x2e4>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U)) {
			return -1;
f010477b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104780:	eb 3d                	jmp    f01047bf <debuginfo_eip+0x2e4>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
			return -1;
f0104782:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104787:	eb 36                	jmp    f01047bf <debuginfo_eip+0x2e4>
		}

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
			return -1;
f0104789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010478e:	eb 2f                	jmp    f01047bf <debuginfo_eip+0x2e4>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104790:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104795:	eb 28                	jmp    f01047bf <debuginfo_eip+0x2e4>
f0104797:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010479c:	eb 21                	jmp    f01047bf <debuginfo_eip+0x2e4>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010479e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047a3:	eb 1a                	jmp    f01047bf <debuginfo_eip+0x2e4>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = rline;
	} else {
		return -1;
f01047a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047aa:	eb 13                	jmp    f01047bf <debuginfo_eip+0x2e4>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01047ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01047b1:	eb 0c                	jmp    f01047bf <debuginfo_eip+0x2e4>
f01047b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01047b8:	eb 05                	jmp    f01047bf <debuginfo_eip+0x2e4>
f01047ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01047bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047c2:	5b                   	pop    %ebx
f01047c3:	5e                   	pop    %esi
f01047c4:	5f                   	pop    %edi
f01047c5:	5d                   	pop    %ebp
f01047c6:	c3                   	ret    

f01047c7 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01047c7:	55                   	push   %ebp
f01047c8:	89 e5                	mov    %esp,%ebp
f01047ca:	57                   	push   %edi
f01047cb:	56                   	push   %esi
f01047cc:	53                   	push   %ebx
f01047cd:	83 ec 1c             	sub    $0x1c,%esp
f01047d0:	89 c7                	mov    %eax,%edi
f01047d2:	89 d6                	mov    %edx,%esi
f01047d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01047d7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01047da:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01047dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01047e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
f01047e3:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f01047e7:	0f 85 bf 00 00 00    	jne    f01048ac <printnum+0xe5>
f01047ed:	39 1d 8c ea 19 f0    	cmp    %ebx,0xf019ea8c
f01047f3:	0f 8d de 00 00 00    	jge    f01048d7 <printnum+0x110>
		judge_time_for_space = width;
f01047f9:	89 1d 8c ea 19 f0    	mov    %ebx,0xf019ea8c
f01047ff:	e9 d3 00 00 00       	jmp    f01048d7 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f0104804:	83 eb 01             	sub    $0x1,%ebx
f0104807:	85 db                	test   %ebx,%ebx
f0104809:	7f 37                	jg     f0104842 <printnum+0x7b>
f010480b:	e9 ea 00 00 00       	jmp    f01048fa <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
f0104810:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104813:	a3 88 ea 19 f0       	mov    %eax,0xf019ea88
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104818:	83 ec 08             	sub    $0x8,%esp
f010481b:	56                   	push   %esi
f010481c:	83 ec 04             	sub    $0x4,%esp
f010481f:	ff 75 dc             	pushl  -0x24(%ebp)
f0104822:	ff 75 d8             	pushl  -0x28(%ebp)
f0104825:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104828:	ff 75 e0             	pushl  -0x20(%ebp)
f010482b:	e8 b0 0d 00 00       	call   f01055e0 <__umoddi3>
f0104830:	83 c4 14             	add    $0x14,%esp
f0104833:	0f be 80 7a 6e 10 f0 	movsbl -0xfef9186(%eax),%eax
f010483a:	50                   	push   %eax
f010483b:	ff d7                	call   *%edi
f010483d:	83 c4 10             	add    $0x10,%esp
f0104840:	eb 16                	jmp    f0104858 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
f0104842:	83 ec 08             	sub    $0x8,%esp
f0104845:	56                   	push   %esi
f0104846:	ff 75 18             	pushl  0x18(%ebp)
f0104849:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
f010484b:	83 c4 10             	add    $0x10,%esp
f010484e:	83 eb 01             	sub    $0x1,%ebx
f0104851:	75 ef                	jne    f0104842 <printnum+0x7b>
f0104853:	e9 a2 00 00 00       	jmp    f01048fa <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
f0104858:	3b 1d 8c ea 19 f0    	cmp    0xf019ea8c,%ebx
f010485e:	0f 85 76 01 00 00    	jne    f01049da <printnum+0x213>
		while(num_of_space-- > 0)
f0104864:	a1 88 ea 19 f0       	mov    0xf019ea88,%eax
f0104869:	8d 50 ff             	lea    -0x1(%eax),%edx
f010486c:	89 15 88 ea 19 f0    	mov    %edx,0xf019ea88
f0104872:	85 c0                	test   %eax,%eax
f0104874:	7e 1d                	jle    f0104893 <printnum+0xcc>
			putch(' ', putdat);
f0104876:	83 ec 08             	sub    $0x8,%esp
f0104879:	56                   	push   %esi
f010487a:	6a 20                	push   $0x20
f010487c:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
f010487e:	a1 88 ea 19 f0       	mov    0xf019ea88,%eax
f0104883:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104886:	89 15 88 ea 19 f0    	mov    %edx,0xf019ea88
f010488c:	83 c4 10             	add    $0x10,%esp
f010488f:	85 c0                	test   %eax,%eax
f0104891:	7f e3                	jg     f0104876 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
f0104893:	c7 05 88 ea 19 f0 00 	movl   $0x0,0xf019ea88
f010489a:	00 00 00 
		judge_time_for_space = 0;
f010489d:	c7 05 8c ea 19 f0 00 	movl   $0x0,0xf019ea8c
f01048a4:	00 00 00 
	}
}
f01048a7:	e9 2e 01 00 00       	jmp    f01049da <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01048ac:	8b 45 10             	mov    0x10(%ebp),%eax
f01048af:	ba 00 00 00 00       	mov    $0x0,%edx
f01048b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01048ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048c0:	83 fa 00             	cmp    $0x0,%edx
f01048c3:	0f 87 ba 00 00 00    	ja     f0104983 <printnum+0x1bc>
f01048c9:	3b 45 10             	cmp    0x10(%ebp),%eax
f01048cc:	0f 83 b1 00 00 00    	jae    f0104983 <printnum+0x1bc>
f01048d2:	e9 2d ff ff ff       	jmp    f0104804 <printnum+0x3d>
f01048d7:	8b 45 10             	mov    0x10(%ebp),%eax
f01048da:	ba 00 00 00 00       	mov    $0x0,%edx
f01048df:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01048e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048eb:	83 fa 00             	cmp    $0x0,%edx
f01048ee:	77 37                	ja     f0104927 <printnum+0x160>
f01048f0:	3b 45 10             	cmp    0x10(%ebp),%eax
f01048f3:	73 32                	jae    f0104927 <printnum+0x160>
f01048f5:	e9 16 ff ff ff       	jmp    f0104810 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01048fa:	83 ec 08             	sub    $0x8,%esp
f01048fd:	56                   	push   %esi
f01048fe:	83 ec 04             	sub    $0x4,%esp
f0104901:	ff 75 dc             	pushl  -0x24(%ebp)
f0104904:	ff 75 d8             	pushl  -0x28(%ebp)
f0104907:	ff 75 e4             	pushl  -0x1c(%ebp)
f010490a:	ff 75 e0             	pushl  -0x20(%ebp)
f010490d:	e8 ce 0c 00 00       	call   f01055e0 <__umoddi3>
f0104912:	83 c4 14             	add    $0x14,%esp
f0104915:	0f be 80 7a 6e 10 f0 	movsbl -0xfef9186(%eax),%eax
f010491c:	50                   	push   %eax
f010491d:	ff d7                	call   *%edi
f010491f:	83 c4 10             	add    $0x10,%esp
f0104922:	e9 b3 00 00 00       	jmp    f01049da <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104927:	83 ec 0c             	sub    $0xc,%esp
f010492a:	ff 75 18             	pushl  0x18(%ebp)
f010492d:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104930:	50                   	push   %eax
f0104931:	ff 75 10             	pushl  0x10(%ebp)
f0104934:	83 ec 08             	sub    $0x8,%esp
f0104937:	ff 75 dc             	pushl  -0x24(%ebp)
f010493a:	ff 75 d8             	pushl  -0x28(%ebp)
f010493d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104940:	ff 75 e0             	pushl  -0x20(%ebp)
f0104943:	e8 68 0b 00 00       	call   f01054b0 <__udivdi3>
f0104948:	83 c4 18             	add    $0x18,%esp
f010494b:	52                   	push   %edx
f010494c:	50                   	push   %eax
f010494d:	89 f2                	mov    %esi,%edx
f010494f:	89 f8                	mov    %edi,%eax
f0104951:	e8 71 fe ff ff       	call   f01047c7 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104956:	83 c4 18             	add    $0x18,%esp
f0104959:	56                   	push   %esi
f010495a:	83 ec 04             	sub    $0x4,%esp
f010495d:	ff 75 dc             	pushl  -0x24(%ebp)
f0104960:	ff 75 d8             	pushl  -0x28(%ebp)
f0104963:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104966:	ff 75 e0             	pushl  -0x20(%ebp)
f0104969:	e8 72 0c 00 00       	call   f01055e0 <__umoddi3>
f010496e:	83 c4 14             	add    $0x14,%esp
f0104971:	0f be 80 7a 6e 10 f0 	movsbl -0xfef9186(%eax),%eax
f0104978:	50                   	push   %eax
f0104979:	ff d7                	call   *%edi
f010497b:	83 c4 10             	add    $0x10,%esp
f010497e:	e9 d5 fe ff ff       	jmp    f0104858 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104983:	83 ec 0c             	sub    $0xc,%esp
f0104986:	ff 75 18             	pushl  0x18(%ebp)
f0104989:	83 eb 01             	sub    $0x1,%ebx
f010498c:	53                   	push   %ebx
f010498d:	ff 75 10             	pushl  0x10(%ebp)
f0104990:	83 ec 08             	sub    $0x8,%esp
f0104993:	ff 75 dc             	pushl  -0x24(%ebp)
f0104996:	ff 75 d8             	pushl  -0x28(%ebp)
f0104999:	ff 75 e4             	pushl  -0x1c(%ebp)
f010499c:	ff 75 e0             	pushl  -0x20(%ebp)
f010499f:	e8 0c 0b 00 00       	call   f01054b0 <__udivdi3>
f01049a4:	83 c4 18             	add    $0x18,%esp
f01049a7:	52                   	push   %edx
f01049a8:	50                   	push   %eax
f01049a9:	89 f2                	mov    %esi,%edx
f01049ab:	89 f8                	mov    %edi,%eax
f01049ad:	e8 15 fe ff ff       	call   f01047c7 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01049b2:	83 c4 18             	add    $0x18,%esp
f01049b5:	56                   	push   %esi
f01049b6:	83 ec 04             	sub    $0x4,%esp
f01049b9:	ff 75 dc             	pushl  -0x24(%ebp)
f01049bc:	ff 75 d8             	pushl  -0x28(%ebp)
f01049bf:	ff 75 e4             	pushl  -0x1c(%ebp)
f01049c2:	ff 75 e0             	pushl  -0x20(%ebp)
f01049c5:	e8 16 0c 00 00       	call   f01055e0 <__umoddi3>
f01049ca:	83 c4 14             	add    $0x14,%esp
f01049cd:	0f be 80 7a 6e 10 f0 	movsbl -0xfef9186(%eax),%eax
f01049d4:	50                   	push   %eax
f01049d5:	ff d7                	call   *%edi
f01049d7:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
f01049da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049dd:	5b                   	pop    %ebx
f01049de:	5e                   	pop    %esi
f01049df:	5f                   	pop    %edi
f01049e0:	5d                   	pop    %ebp
f01049e1:	c3                   	ret    

f01049e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01049e2:	55                   	push   %ebp
f01049e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01049e5:	83 fa 01             	cmp    $0x1,%edx
f01049e8:	7e 0e                	jle    f01049f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01049ea:	8b 10                	mov    (%eax),%edx
f01049ec:	8d 4a 08             	lea    0x8(%edx),%ecx
f01049ef:	89 08                	mov    %ecx,(%eax)
f01049f1:	8b 02                	mov    (%edx),%eax
f01049f3:	8b 52 04             	mov    0x4(%edx),%edx
f01049f6:	eb 22                	jmp    f0104a1a <getuint+0x38>
	else if (lflag)
f01049f8:	85 d2                	test   %edx,%edx
f01049fa:	74 10                	je     f0104a0c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01049fc:	8b 10                	mov    (%eax),%edx
f01049fe:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104a01:	89 08                	mov    %ecx,(%eax)
f0104a03:	8b 02                	mov    (%edx),%eax
f0104a05:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a0a:	eb 0e                	jmp    f0104a1a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104a0c:	8b 10                	mov    (%eax),%edx
f0104a0e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104a11:	89 08                	mov    %ecx,(%eax)
f0104a13:	8b 02                	mov    (%edx),%eax
f0104a15:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104a1a:	5d                   	pop    %ebp
f0104a1b:	c3                   	ret    

f0104a1c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104a1c:	55                   	push   %ebp
f0104a1d:	89 e5                	mov    %esp,%ebp
f0104a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104a22:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104a26:	8b 10                	mov    (%eax),%edx
f0104a28:	3b 50 04             	cmp    0x4(%eax),%edx
f0104a2b:	73 0a                	jae    f0104a37 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104a2d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104a30:	89 08                	mov    %ecx,(%eax)
f0104a32:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a35:	88 02                	mov    %al,(%edx)
}
f0104a37:	5d                   	pop    %ebp
f0104a38:	c3                   	ret    

f0104a39 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104a39:	55                   	push   %ebp
f0104a3a:	89 e5                	mov    %esp,%ebp
f0104a3c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104a3f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a42:	50                   	push   %eax
f0104a43:	ff 75 10             	pushl  0x10(%ebp)
f0104a46:	ff 75 0c             	pushl  0xc(%ebp)
f0104a49:	ff 75 08             	pushl  0x8(%ebp)
f0104a4c:	e8 05 00 00 00       	call   f0104a56 <vprintfmt>
	va_end(ap);
}
f0104a51:	83 c4 10             	add    $0x10,%esp
f0104a54:	c9                   	leave  
f0104a55:	c3                   	ret    

f0104a56 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104a56:	55                   	push   %ebp
f0104a57:	89 e5                	mov    %esp,%ebp
f0104a59:	57                   	push   %edi
f0104a5a:	56                   	push   %esi
f0104a5b:	53                   	push   %ebx
f0104a5c:	83 ec 2c             	sub    $0x2c,%esp
f0104a5f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a65:	eb 03                	jmp    f0104a6a <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104a67:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104a6a:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a6d:	8d 70 01             	lea    0x1(%eax),%esi
f0104a70:	0f b6 00             	movzbl (%eax),%eax
f0104a73:	83 f8 25             	cmp    $0x25,%eax
f0104a76:	74 27                	je     f0104a9f <vprintfmt+0x49>
			if (ch == '\0')
f0104a78:	85 c0                	test   %eax,%eax
f0104a7a:	75 0d                	jne    f0104a89 <vprintfmt+0x33>
f0104a7c:	e9 9d 04 00 00       	jmp    f0104f1e <vprintfmt+0x4c8>
f0104a81:	85 c0                	test   %eax,%eax
f0104a83:	0f 84 95 04 00 00    	je     f0104f1e <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
f0104a89:	83 ec 08             	sub    $0x8,%esp
f0104a8c:	53                   	push   %ebx
f0104a8d:	50                   	push   %eax
f0104a8e:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104a90:	83 c6 01             	add    $0x1,%esi
f0104a93:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0104a97:	83 c4 10             	add    $0x10,%esp
f0104a9a:	83 f8 25             	cmp    $0x25,%eax
f0104a9d:	75 e2                	jne    f0104a81 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104aa4:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f0104aa8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104aaf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104ab6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104abd:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0104ac4:	eb 08                	jmp    f0104ace <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ac6:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
f0104ac9:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ace:	8d 46 01             	lea    0x1(%esi),%eax
f0104ad1:	89 45 10             	mov    %eax,0x10(%ebp)
f0104ad4:	0f b6 06             	movzbl (%esi),%eax
f0104ad7:	0f b6 d0             	movzbl %al,%edx
f0104ada:	83 e8 23             	sub    $0x23,%eax
f0104add:	3c 55                	cmp    $0x55,%al
f0104adf:	0f 87 fa 03 00 00    	ja     f0104edf <vprintfmt+0x489>
f0104ae5:	0f b6 c0             	movzbl %al,%eax
f0104ae8:	ff 24 85 80 6f 10 f0 	jmp    *-0xfef9080(,%eax,4)
f0104aef:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
f0104af2:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f0104af6:	eb d6                	jmp    f0104ace <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104af8:	8d 42 d0             	lea    -0x30(%edx),%eax
f0104afb:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f0104afe:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0104b02:	8d 50 d0             	lea    -0x30(%eax),%edx
f0104b05:	83 fa 09             	cmp    $0x9,%edx
f0104b08:	77 6b                	ja     f0104b75 <vprintfmt+0x11f>
f0104b0a:	8b 75 10             	mov    0x10(%ebp),%esi
f0104b0d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104b10:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104b13:	eb 09                	jmp    f0104b1e <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b15:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104b18:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f0104b1c:	eb b0                	jmp    f0104ace <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104b1e:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0104b21:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104b24:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104b28:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104b2b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0104b2e:	83 f9 09             	cmp    $0x9,%ecx
f0104b31:	76 eb                	jbe    f0104b1e <vprintfmt+0xc8>
f0104b33:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104b36:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104b39:	eb 3d                	jmp    f0104b78 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104b3b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b3e:	8d 50 04             	lea    0x4(%eax),%edx
f0104b41:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b44:	8b 00                	mov    (%eax),%eax
f0104b46:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b49:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104b4c:	eb 2a                	jmp    f0104b78 <vprintfmt+0x122>
f0104b4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b51:	85 c0                	test   %eax,%eax
f0104b53:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b58:	0f 49 d0             	cmovns %eax,%edx
f0104b5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b5e:	8b 75 10             	mov    0x10(%ebp),%esi
f0104b61:	e9 68 ff ff ff       	jmp    f0104ace <vprintfmt+0x78>
f0104b66:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104b69:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104b70:	e9 59 ff ff ff       	jmp    f0104ace <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b75:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0104b78:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104b7c:	0f 89 4c ff ff ff    	jns    f0104ace <vprintfmt+0x78>
				width = precision, precision = -1;
f0104b82:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104b85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104b88:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104b8f:	e9 3a ff ff ff       	jmp    f0104ace <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104b94:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b98:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104b9b:	e9 2e ff ff ff       	jmp    f0104ace <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104ba0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ba3:	8d 50 04             	lea    0x4(%eax),%edx
f0104ba6:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ba9:	83 ec 08             	sub    $0x8,%esp
f0104bac:	53                   	push   %ebx
f0104bad:	ff 30                	pushl  (%eax)
f0104baf:	ff d7                	call   *%edi
			break;
f0104bb1:	83 c4 10             	add    $0x10,%esp
f0104bb4:	e9 b1 fe ff ff       	jmp    f0104a6a <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104bb9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bbc:	8d 50 04             	lea    0x4(%eax),%edx
f0104bbf:	89 55 14             	mov    %edx,0x14(%ebp)
f0104bc2:	8b 00                	mov    (%eax),%eax
f0104bc4:	99                   	cltd   
f0104bc5:	31 d0                	xor    %edx,%eax
f0104bc7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104bc9:	83 f8 06             	cmp    $0x6,%eax
f0104bcc:	7f 0b                	jg     f0104bd9 <vprintfmt+0x183>
f0104bce:	8b 14 85 d8 70 10 f0 	mov    -0xfef8f28(,%eax,4),%edx
f0104bd5:	85 d2                	test   %edx,%edx
f0104bd7:	75 15                	jne    f0104bee <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
f0104bd9:	50                   	push   %eax
f0104bda:	68 92 6e 10 f0       	push   $0xf0106e92
f0104bdf:	53                   	push   %ebx
f0104be0:	57                   	push   %edi
f0104be1:	e8 53 fe ff ff       	call   f0104a39 <printfmt>
f0104be6:	83 c4 10             	add    $0x10,%esp
f0104be9:	e9 7c fe ff ff       	jmp    f0104a6a <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f0104bee:	52                   	push   %edx
f0104bef:	68 45 65 10 f0       	push   $0xf0106545
f0104bf4:	53                   	push   %ebx
f0104bf5:	57                   	push   %edi
f0104bf6:	e8 3e fe ff ff       	call   f0104a39 <printfmt>
f0104bfb:	83 c4 10             	add    $0x10,%esp
f0104bfe:	e9 67 fe ff ff       	jmp    f0104a6a <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104c03:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c06:	8d 50 04             	lea    0x4(%eax),%edx
f0104c09:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c0c:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0104c0e:	85 c0                	test   %eax,%eax
f0104c10:	b9 8b 6e 10 f0       	mov    $0xf0106e8b,%ecx
f0104c15:	0f 45 c8             	cmovne %eax,%ecx
f0104c18:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0104c1b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c1f:	7e 06                	jle    f0104c27 <vprintfmt+0x1d1>
f0104c21:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0104c25:	75 19                	jne    f0104c40 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c27:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104c2a:	8d 70 01             	lea    0x1(%eax),%esi
f0104c2d:	0f b6 00             	movzbl (%eax),%eax
f0104c30:	0f be d0             	movsbl %al,%edx
f0104c33:	85 d2                	test   %edx,%edx
f0104c35:	0f 85 9f 00 00 00    	jne    f0104cda <vprintfmt+0x284>
f0104c3b:	e9 8c 00 00 00       	jmp    f0104ccc <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104c40:	83 ec 08             	sub    $0x8,%esp
f0104c43:	ff 75 d0             	pushl  -0x30(%ebp)
f0104c46:	ff 75 cc             	pushl  -0x34(%ebp)
f0104c49:	e8 3b 04 00 00       	call   f0105089 <strnlen>
f0104c4e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f0104c51:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104c54:	83 c4 10             	add    $0x10,%esp
f0104c57:	85 c9                	test   %ecx,%ecx
f0104c59:	0f 8e a6 02 00 00    	jle    f0104f05 <vprintfmt+0x4af>
					putch(padc, putdat);
f0104c5f:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0104c63:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c66:	89 cb                	mov    %ecx,%ebx
f0104c68:	83 ec 08             	sub    $0x8,%esp
f0104c6b:	ff 75 0c             	pushl  0xc(%ebp)
f0104c6e:	56                   	push   %esi
f0104c6f:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104c71:	83 c4 10             	add    $0x10,%esp
f0104c74:	83 eb 01             	sub    $0x1,%ebx
f0104c77:	75 ef                	jne    f0104c68 <vprintfmt+0x212>
f0104c79:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104c7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c7f:	e9 81 02 00 00       	jmp    f0104f05 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104c84:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c88:	74 1b                	je     f0104ca5 <vprintfmt+0x24f>
f0104c8a:	0f be c0             	movsbl %al,%eax
f0104c8d:	83 e8 20             	sub    $0x20,%eax
f0104c90:	83 f8 5e             	cmp    $0x5e,%eax
f0104c93:	76 10                	jbe    f0104ca5 <vprintfmt+0x24f>
					putch('?', putdat);
f0104c95:	83 ec 08             	sub    $0x8,%esp
f0104c98:	ff 75 0c             	pushl  0xc(%ebp)
f0104c9b:	6a 3f                	push   $0x3f
f0104c9d:	ff 55 08             	call   *0x8(%ebp)
f0104ca0:	83 c4 10             	add    $0x10,%esp
f0104ca3:	eb 0d                	jmp    f0104cb2 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
f0104ca5:	83 ec 08             	sub    $0x8,%esp
f0104ca8:	ff 75 0c             	pushl  0xc(%ebp)
f0104cab:	52                   	push   %edx
f0104cac:	ff 55 08             	call   *0x8(%ebp)
f0104caf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104cb2:	83 ef 01             	sub    $0x1,%edi
f0104cb5:	83 c6 01             	add    $0x1,%esi
f0104cb8:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0104cbc:	0f be d0             	movsbl %al,%edx
f0104cbf:	85 d2                	test   %edx,%edx
f0104cc1:	75 31                	jne    f0104cf4 <vprintfmt+0x29e>
f0104cc3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0104cc6:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104cc9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ccc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104ccf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104cd3:	7f 33                	jg     f0104d08 <vprintfmt+0x2b2>
f0104cd5:	e9 90 fd ff ff       	jmp    f0104a6a <vprintfmt+0x14>
f0104cda:	89 7d 08             	mov    %edi,0x8(%ebp)
f0104cdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ce0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104ce3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104ce6:	eb 0c                	jmp    f0104cf4 <vprintfmt+0x29e>
f0104ce8:	89 7d 08             	mov    %edi,0x8(%ebp)
f0104ceb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104cf1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104cf4:	85 db                	test   %ebx,%ebx
f0104cf6:	78 8c                	js     f0104c84 <vprintfmt+0x22e>
f0104cf8:	83 eb 01             	sub    $0x1,%ebx
f0104cfb:	79 87                	jns    f0104c84 <vprintfmt+0x22e>
f0104cfd:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0104d00:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104d03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d06:	eb c4                	jmp    f0104ccc <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104d08:	83 ec 08             	sub    $0x8,%esp
f0104d0b:	53                   	push   %ebx
f0104d0c:	6a 20                	push   $0x20
f0104d0e:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104d10:	83 c4 10             	add    $0x10,%esp
f0104d13:	83 ee 01             	sub    $0x1,%esi
f0104d16:	75 f0                	jne    f0104d08 <vprintfmt+0x2b2>
f0104d18:	e9 4d fd ff ff       	jmp    f0104a6a <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104d1d:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f0104d21:	7e 16                	jle    f0104d39 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
f0104d23:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d26:	8d 50 08             	lea    0x8(%eax),%edx
f0104d29:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d2c:	8b 50 04             	mov    0x4(%eax),%edx
f0104d2f:	8b 00                	mov    (%eax),%eax
f0104d31:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104d34:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104d37:	eb 34                	jmp    f0104d6d <vprintfmt+0x317>
	else if (lflag)
f0104d39:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104d3d:	74 18                	je     f0104d57 <vprintfmt+0x301>
		return va_arg(*ap, long);
f0104d3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d42:	8d 50 04             	lea    0x4(%eax),%edx
f0104d45:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d48:	8b 30                	mov    (%eax),%esi
f0104d4a:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0104d4d:	89 f0                	mov    %esi,%eax
f0104d4f:	c1 f8 1f             	sar    $0x1f,%eax
f0104d52:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104d55:	eb 16                	jmp    f0104d6d <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
f0104d57:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d5a:	8d 50 04             	lea    0x4(%eax),%edx
f0104d5d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d60:	8b 30                	mov    (%eax),%esi
f0104d62:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0104d65:	89 f0                	mov    %esi,%eax
f0104d67:	c1 f8 1f             	sar    $0x1f,%eax
f0104d6a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104d6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d70:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104d73:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d76:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0104d79:	85 d2                	test   %edx,%edx
f0104d7b:	79 28                	jns    f0104da5 <vprintfmt+0x34f>
				putch('-', putdat);
f0104d7d:	83 ec 08             	sub    $0x8,%esp
f0104d80:	53                   	push   %ebx
f0104d81:	6a 2d                	push   $0x2d
f0104d83:	ff d7                	call   *%edi
				num = -(long long) num;
f0104d85:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d88:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104d8b:	f7 d8                	neg    %eax
f0104d8d:	83 d2 00             	adc    $0x0,%edx
f0104d90:	f7 da                	neg    %edx
f0104d92:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d95:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104d98:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
f0104d9b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104da0:	e9 b2 00 00 00       	jmp    f0104e57 <vprintfmt+0x401>
f0104da5:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
f0104daa:	85 c9                	test   %ecx,%ecx
f0104dac:	0f 84 a5 00 00 00    	je     f0104e57 <vprintfmt+0x401>
				putch('+', putdat);
f0104db2:	83 ec 08             	sub    $0x8,%esp
f0104db5:	53                   	push   %ebx
f0104db6:	6a 2b                	push   $0x2b
f0104db8:	ff d7                	call   *%edi
f0104dba:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
f0104dbd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104dc2:	e9 90 00 00 00       	jmp    f0104e57 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
f0104dc7:	85 c9                	test   %ecx,%ecx
f0104dc9:	74 0b                	je     f0104dd6 <vprintfmt+0x380>
				putch('+', putdat);
f0104dcb:	83 ec 08             	sub    $0x8,%esp
f0104dce:	53                   	push   %ebx
f0104dcf:	6a 2b                	push   $0x2b
f0104dd1:	ff d7                	call   *%edi
f0104dd3:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
f0104dd6:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104dd9:	8d 45 14             	lea    0x14(%ebp),%eax
f0104ddc:	e8 01 fc ff ff       	call   f01049e2 <getuint>
f0104de1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104de4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0104de7:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104dec:	eb 69                	jmp    f0104e57 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
f0104dee:	83 ec 08             	sub    $0x8,%esp
f0104df1:	53                   	push   %ebx
f0104df2:	6a 30                	push   $0x30
f0104df4:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f0104df6:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104df9:	8d 45 14             	lea    0x14(%ebp),%eax
f0104dfc:	e8 e1 fb ff ff       	call   f01049e2 <getuint>
f0104e01:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e04:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f0104e07:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0104e0a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0104e0f:	eb 46                	jmp    f0104e57 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
f0104e11:	83 ec 08             	sub    $0x8,%esp
f0104e14:	53                   	push   %ebx
f0104e15:	6a 30                	push   $0x30
f0104e17:	ff d7                	call   *%edi
			putch('x', putdat);
f0104e19:	83 c4 08             	add    $0x8,%esp
f0104e1c:	53                   	push   %ebx
f0104e1d:	6a 78                	push   $0x78
f0104e1f:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104e21:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e24:	8d 50 04             	lea    0x4(%eax),%edx
f0104e27:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104e2a:	8b 00                	mov    (%eax),%eax
f0104e2c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e31:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e34:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104e37:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104e3a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104e3f:	eb 16                	jmp    f0104e57 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104e41:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104e44:	8d 45 14             	lea    0x14(%ebp),%eax
f0104e47:	e8 96 fb ff ff       	call   f01049e2 <getuint>
f0104e4c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e4f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0104e52:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104e57:	83 ec 0c             	sub    $0xc,%esp
f0104e5a:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0104e5e:	56                   	push   %esi
f0104e5f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e62:	50                   	push   %eax
f0104e63:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e66:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e69:	89 da                	mov    %ebx,%edx
f0104e6b:	89 f8                	mov    %edi,%eax
f0104e6d:	e8 55 f9 ff ff       	call   f01047c7 <printnum>
			break;
f0104e72:	83 c4 20             	add    $0x20,%esp
f0104e75:	e9 f0 fb ff ff       	jmp    f0104a6a <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
f0104e7a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e7d:	8d 50 04             	lea    0x4(%eax),%edx
f0104e80:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e83:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
f0104e85:	85 f6                	test   %esi,%esi
f0104e87:	75 1a                	jne    f0104ea3 <vprintfmt+0x44d>
						cprintf("%s", null_error);
f0104e89:	83 ec 08             	sub    $0x8,%esp
f0104e8c:	68 04 6f 10 f0       	push   $0xf0106f04
f0104e91:	68 45 65 10 f0       	push   $0xf0106545
f0104e96:	e8 04 eb ff ff       	call   f010399f <cprintf>
f0104e9b:	83 c4 10             	add    $0x10,%esp
f0104e9e:	e9 c7 fb ff ff       	jmp    f0104a6a <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
f0104ea3:	0f b6 03             	movzbl (%ebx),%eax
f0104ea6:	84 c0                	test   %al,%al
f0104ea8:	79 1f                	jns    f0104ec9 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
f0104eaa:	83 ec 08             	sub    $0x8,%esp
f0104ead:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0104eb2:	68 45 65 10 f0       	push   $0xf0106545
f0104eb7:	e8 e3 ea ff ff       	call   f010399f <cprintf>
						*tmp = *(char *)putdat;
f0104ebc:	0f b6 03             	movzbl (%ebx),%eax
f0104ebf:	88 06                	mov    %al,(%esi)
f0104ec1:	83 c4 10             	add    $0x10,%esp
f0104ec4:	e9 a1 fb ff ff       	jmp    f0104a6a <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
f0104ec9:	88 06                	mov    %al,(%esi)
f0104ecb:	e9 9a fb ff ff       	jmp    f0104a6a <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104ed0:	83 ec 08             	sub    $0x8,%esp
f0104ed3:	53                   	push   %ebx
f0104ed4:	52                   	push   %edx
f0104ed5:	ff d7                	call   *%edi
			break;
f0104ed7:	83 c4 10             	add    $0x10,%esp
f0104eda:	e9 8b fb ff ff       	jmp    f0104a6a <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104edf:	83 ec 08             	sub    $0x8,%esp
f0104ee2:	53                   	push   %ebx
f0104ee3:	6a 25                	push   $0x25
f0104ee5:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104ee7:	83 c4 10             	add    $0x10,%esp
f0104eea:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104eee:	0f 84 73 fb ff ff    	je     f0104a67 <vprintfmt+0x11>
f0104ef4:	83 ee 01             	sub    $0x1,%esi
f0104ef7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104efb:	75 f7                	jne    f0104ef4 <vprintfmt+0x49e>
f0104efd:	89 75 10             	mov    %esi,0x10(%ebp)
f0104f00:	e9 65 fb ff ff       	jmp    f0104a6a <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104f05:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104f08:	8d 70 01             	lea    0x1(%eax),%esi
f0104f0b:	0f b6 00             	movzbl (%eax),%eax
f0104f0e:	0f be d0             	movsbl %al,%edx
f0104f11:	85 d2                	test   %edx,%edx
f0104f13:	0f 85 cf fd ff ff    	jne    f0104ce8 <vprintfmt+0x292>
f0104f19:	e9 4c fb ff ff       	jmp    f0104a6a <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0104f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f21:	5b                   	pop    %ebx
f0104f22:	5e                   	pop    %esi
f0104f23:	5f                   	pop    %edi
f0104f24:	5d                   	pop    %ebp
f0104f25:	c3                   	ret    

f0104f26 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104f26:	55                   	push   %ebp
f0104f27:	89 e5                	mov    %esp,%ebp
f0104f29:	83 ec 18             	sub    $0x18,%esp
f0104f2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f2f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104f32:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104f35:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104f39:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104f3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104f43:	85 c0                	test   %eax,%eax
f0104f45:	74 26                	je     f0104f6d <vsnprintf+0x47>
f0104f47:	85 d2                	test   %edx,%edx
f0104f49:	7e 22                	jle    f0104f6d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104f4b:	ff 75 14             	pushl  0x14(%ebp)
f0104f4e:	ff 75 10             	pushl  0x10(%ebp)
f0104f51:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104f54:	50                   	push   %eax
f0104f55:	68 1c 4a 10 f0       	push   $0xf0104a1c
f0104f5a:	e8 f7 fa ff ff       	call   f0104a56 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f62:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f68:	83 c4 10             	add    $0x10,%esp
f0104f6b:	eb 05                	jmp    f0104f72 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104f6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104f72:	c9                   	leave  
f0104f73:	c3                   	ret    

f0104f74 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104f74:	55                   	push   %ebp
f0104f75:	89 e5                	mov    %esp,%ebp
f0104f77:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104f7a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104f7d:	50                   	push   %eax
f0104f7e:	ff 75 10             	pushl  0x10(%ebp)
f0104f81:	ff 75 0c             	pushl  0xc(%ebp)
f0104f84:	ff 75 08             	pushl  0x8(%ebp)
f0104f87:	e8 9a ff ff ff       	call   f0104f26 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104f8c:	c9                   	leave  
f0104f8d:	c3                   	ret    

f0104f8e <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104f8e:	55                   	push   %ebp
f0104f8f:	89 e5                	mov    %esp,%ebp
f0104f91:	57                   	push   %edi
f0104f92:	56                   	push   %esi
f0104f93:	53                   	push   %ebx
f0104f94:	83 ec 0c             	sub    $0xc,%esp
f0104f97:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104f9a:	85 c0                	test   %eax,%eax
f0104f9c:	74 11                	je     f0104faf <readline+0x21>
		cprintf("%s", prompt);
f0104f9e:	83 ec 08             	sub    $0x8,%esp
f0104fa1:	50                   	push   %eax
f0104fa2:	68 45 65 10 f0       	push   $0xf0106545
f0104fa7:	e8 f3 e9 ff ff       	call   f010399f <cprintf>
f0104fac:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104faf:	83 ec 0c             	sub    $0xc,%esp
f0104fb2:	6a 00                	push   $0x0
f0104fb4:	e8 88 b6 ff ff       	call   f0100641 <iscons>
f0104fb9:	89 c7                	mov    %eax,%edi
f0104fbb:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104fbe:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104fc3:	e8 68 b6 ff ff       	call   f0100630 <getchar>
f0104fc8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104fca:	85 c0                	test   %eax,%eax
f0104fcc:	79 18                	jns    f0104fe6 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104fce:	83 ec 08             	sub    $0x8,%esp
f0104fd1:	50                   	push   %eax
f0104fd2:	68 f4 70 10 f0       	push   $0xf01070f4
f0104fd7:	e8 c3 e9 ff ff       	call   f010399f <cprintf>
			return NULL;
f0104fdc:	83 c4 10             	add    $0x10,%esp
f0104fdf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fe4:	eb 79                	jmp    f010505f <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104fe6:	83 f8 08             	cmp    $0x8,%eax
f0104fe9:	0f 94 c2             	sete   %dl
f0104fec:	83 f8 7f             	cmp    $0x7f,%eax
f0104fef:	0f 94 c0             	sete   %al
f0104ff2:	08 c2                	or     %al,%dl
f0104ff4:	74 1a                	je     f0105010 <readline+0x82>
f0104ff6:	85 f6                	test   %esi,%esi
f0104ff8:	7e 16                	jle    f0105010 <readline+0x82>
			if (echoing)
f0104ffa:	85 ff                	test   %edi,%edi
f0104ffc:	74 0d                	je     f010500b <readline+0x7d>
				cputchar('\b');
f0104ffe:	83 ec 0c             	sub    $0xc,%esp
f0105001:	6a 08                	push   $0x8
f0105003:	e8 18 b6 ff ff       	call   f0100620 <cputchar>
f0105008:	83 c4 10             	add    $0x10,%esp
			i--;
f010500b:	83 ee 01             	sub    $0x1,%esi
f010500e:	eb b3                	jmp    f0104fc3 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105010:	83 fb 1f             	cmp    $0x1f,%ebx
f0105013:	7e 23                	jle    f0105038 <readline+0xaa>
f0105015:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010501b:	7f 1b                	jg     f0105038 <readline+0xaa>
			if (echoing)
f010501d:	85 ff                	test   %edi,%edi
f010501f:	74 0c                	je     f010502d <readline+0x9f>
				cputchar(c);
f0105021:	83 ec 0c             	sub    $0xc,%esp
f0105024:	53                   	push   %ebx
f0105025:	e8 f6 b5 ff ff       	call   f0100620 <cputchar>
f010502a:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010502d:	88 9e a0 ea 19 f0    	mov    %bl,-0xfe61560(%esi)
f0105033:	8d 76 01             	lea    0x1(%esi),%esi
f0105036:	eb 8b                	jmp    f0104fc3 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105038:	83 fb 0a             	cmp    $0xa,%ebx
f010503b:	74 05                	je     f0105042 <readline+0xb4>
f010503d:	83 fb 0d             	cmp    $0xd,%ebx
f0105040:	75 81                	jne    f0104fc3 <readline+0x35>
			if (echoing)
f0105042:	85 ff                	test   %edi,%edi
f0105044:	74 0d                	je     f0105053 <readline+0xc5>
				cputchar('\n');
f0105046:	83 ec 0c             	sub    $0xc,%esp
f0105049:	6a 0a                	push   $0xa
f010504b:	e8 d0 b5 ff ff       	call   f0100620 <cputchar>
f0105050:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105053:	c6 86 a0 ea 19 f0 00 	movb   $0x0,-0xfe61560(%esi)
			return buf;
f010505a:	b8 a0 ea 19 f0       	mov    $0xf019eaa0,%eax
		}
	}
}
f010505f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105062:	5b                   	pop    %ebx
f0105063:	5e                   	pop    %esi
f0105064:	5f                   	pop    %edi
f0105065:	5d                   	pop    %ebp
f0105066:	c3                   	ret    

f0105067 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105067:	55                   	push   %ebp
f0105068:	89 e5                	mov    %esp,%ebp
f010506a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010506d:	80 3a 00             	cmpb   $0x0,(%edx)
f0105070:	74 10                	je     f0105082 <strlen+0x1b>
f0105072:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105077:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010507a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010507e:	75 f7                	jne    f0105077 <strlen+0x10>
f0105080:	eb 05                	jmp    f0105087 <strlen+0x20>
f0105082:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105087:	5d                   	pop    %ebp
f0105088:	c3                   	ret    

f0105089 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105089:	55                   	push   %ebp
f010508a:	89 e5                	mov    %esp,%ebp
f010508c:	53                   	push   %ebx
f010508d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105093:	85 c9                	test   %ecx,%ecx
f0105095:	74 1c                	je     f01050b3 <strnlen+0x2a>
f0105097:	80 3b 00             	cmpb   $0x0,(%ebx)
f010509a:	74 1e                	je     f01050ba <strnlen+0x31>
f010509c:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01050a1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01050a3:	39 ca                	cmp    %ecx,%edx
f01050a5:	74 18                	je     f01050bf <strnlen+0x36>
f01050a7:	83 c2 01             	add    $0x1,%edx
f01050aa:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01050af:	75 f0                	jne    f01050a1 <strnlen+0x18>
f01050b1:	eb 0c                	jmp    f01050bf <strnlen+0x36>
f01050b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01050b8:	eb 05                	jmp    f01050bf <strnlen+0x36>
f01050ba:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01050bf:	5b                   	pop    %ebx
f01050c0:	5d                   	pop    %ebp
f01050c1:	c3                   	ret    

f01050c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01050c2:	55                   	push   %ebp
f01050c3:	89 e5                	mov    %esp,%ebp
f01050c5:	53                   	push   %ebx
f01050c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01050c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01050cc:	89 c2                	mov    %eax,%edx
f01050ce:	83 c2 01             	add    $0x1,%edx
f01050d1:	83 c1 01             	add    $0x1,%ecx
f01050d4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01050d8:	88 5a ff             	mov    %bl,-0x1(%edx)
f01050db:	84 db                	test   %bl,%bl
f01050dd:	75 ef                	jne    f01050ce <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01050df:	5b                   	pop    %ebx
f01050e0:	5d                   	pop    %ebp
f01050e1:	c3                   	ret    

f01050e2 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01050e2:	55                   	push   %ebp
f01050e3:	89 e5                	mov    %esp,%ebp
f01050e5:	53                   	push   %ebx
f01050e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01050e9:	53                   	push   %ebx
f01050ea:	e8 78 ff ff ff       	call   f0105067 <strlen>
f01050ef:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01050f2:	ff 75 0c             	pushl  0xc(%ebp)
f01050f5:	01 d8                	add    %ebx,%eax
f01050f7:	50                   	push   %eax
f01050f8:	e8 c5 ff ff ff       	call   f01050c2 <strcpy>
	return dst;
}
f01050fd:	89 d8                	mov    %ebx,%eax
f01050ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105102:	c9                   	leave  
f0105103:	c3                   	ret    

f0105104 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105104:	55                   	push   %ebp
f0105105:	89 e5                	mov    %esp,%ebp
f0105107:	56                   	push   %esi
f0105108:	53                   	push   %ebx
f0105109:	8b 75 08             	mov    0x8(%ebp),%esi
f010510c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010510f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105112:	85 db                	test   %ebx,%ebx
f0105114:	74 17                	je     f010512d <strncpy+0x29>
f0105116:	01 f3                	add    %esi,%ebx
f0105118:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f010511a:	83 c1 01             	add    $0x1,%ecx
f010511d:	0f b6 02             	movzbl (%edx),%eax
f0105120:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105123:	80 3a 01             	cmpb   $0x1,(%edx)
f0105126:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105129:	39 cb                	cmp    %ecx,%ebx
f010512b:	75 ed                	jne    f010511a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010512d:	89 f0                	mov    %esi,%eax
f010512f:	5b                   	pop    %ebx
f0105130:	5e                   	pop    %esi
f0105131:	5d                   	pop    %ebp
f0105132:	c3                   	ret    

f0105133 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105133:	55                   	push   %ebp
f0105134:	89 e5                	mov    %esp,%ebp
f0105136:	56                   	push   %esi
f0105137:	53                   	push   %ebx
f0105138:	8b 75 08             	mov    0x8(%ebp),%esi
f010513b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010513e:	8b 55 10             	mov    0x10(%ebp),%edx
f0105141:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105143:	85 d2                	test   %edx,%edx
f0105145:	74 35                	je     f010517c <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f0105147:	89 d0                	mov    %edx,%eax
f0105149:	83 e8 01             	sub    $0x1,%eax
f010514c:	74 25                	je     f0105173 <strlcpy+0x40>
f010514e:	0f b6 0b             	movzbl (%ebx),%ecx
f0105151:	84 c9                	test   %cl,%cl
f0105153:	74 22                	je     f0105177 <strlcpy+0x44>
f0105155:	8d 53 01             	lea    0x1(%ebx),%edx
f0105158:	01 c3                	add    %eax,%ebx
f010515a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f010515c:	83 c0 01             	add    $0x1,%eax
f010515f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105162:	39 da                	cmp    %ebx,%edx
f0105164:	74 13                	je     f0105179 <strlcpy+0x46>
f0105166:	83 c2 01             	add    $0x1,%edx
f0105169:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f010516d:	84 c9                	test   %cl,%cl
f010516f:	75 eb                	jne    f010515c <strlcpy+0x29>
f0105171:	eb 06                	jmp    f0105179 <strlcpy+0x46>
f0105173:	89 f0                	mov    %esi,%eax
f0105175:	eb 02                	jmp    f0105179 <strlcpy+0x46>
f0105177:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105179:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010517c:	29 f0                	sub    %esi,%eax
}
f010517e:	5b                   	pop    %ebx
f010517f:	5e                   	pop    %esi
f0105180:	5d                   	pop    %ebp
f0105181:	c3                   	ret    

f0105182 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105182:	55                   	push   %ebp
f0105183:	89 e5                	mov    %esp,%ebp
f0105185:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105188:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010518b:	0f b6 01             	movzbl (%ecx),%eax
f010518e:	84 c0                	test   %al,%al
f0105190:	74 15                	je     f01051a7 <strcmp+0x25>
f0105192:	3a 02                	cmp    (%edx),%al
f0105194:	75 11                	jne    f01051a7 <strcmp+0x25>
		p++, q++;
f0105196:	83 c1 01             	add    $0x1,%ecx
f0105199:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010519c:	0f b6 01             	movzbl (%ecx),%eax
f010519f:	84 c0                	test   %al,%al
f01051a1:	74 04                	je     f01051a7 <strcmp+0x25>
f01051a3:	3a 02                	cmp    (%edx),%al
f01051a5:	74 ef                	je     f0105196 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01051a7:	0f b6 c0             	movzbl %al,%eax
f01051aa:	0f b6 12             	movzbl (%edx),%edx
f01051ad:	29 d0                	sub    %edx,%eax
}
f01051af:	5d                   	pop    %ebp
f01051b0:	c3                   	ret    

f01051b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01051b1:	55                   	push   %ebp
f01051b2:	89 e5                	mov    %esp,%ebp
f01051b4:	56                   	push   %esi
f01051b5:	53                   	push   %ebx
f01051b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01051b9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01051bc:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f01051bf:	85 f6                	test   %esi,%esi
f01051c1:	74 29                	je     f01051ec <strncmp+0x3b>
f01051c3:	0f b6 03             	movzbl (%ebx),%eax
f01051c6:	84 c0                	test   %al,%al
f01051c8:	74 30                	je     f01051fa <strncmp+0x49>
f01051ca:	3a 02                	cmp    (%edx),%al
f01051cc:	75 2c                	jne    f01051fa <strncmp+0x49>
f01051ce:	8d 43 01             	lea    0x1(%ebx),%eax
f01051d1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f01051d3:	89 c3                	mov    %eax,%ebx
f01051d5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01051d8:	39 c6                	cmp    %eax,%esi
f01051da:	74 17                	je     f01051f3 <strncmp+0x42>
f01051dc:	0f b6 08             	movzbl (%eax),%ecx
f01051df:	84 c9                	test   %cl,%cl
f01051e1:	74 17                	je     f01051fa <strncmp+0x49>
f01051e3:	83 c0 01             	add    $0x1,%eax
f01051e6:	3a 0a                	cmp    (%edx),%cl
f01051e8:	74 e9                	je     f01051d3 <strncmp+0x22>
f01051ea:	eb 0e                	jmp    f01051fa <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01051ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01051f1:	eb 0f                	jmp    f0105202 <strncmp+0x51>
f01051f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01051f8:	eb 08                	jmp    f0105202 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01051fa:	0f b6 03             	movzbl (%ebx),%eax
f01051fd:	0f b6 12             	movzbl (%edx),%edx
f0105200:	29 d0                	sub    %edx,%eax
}
f0105202:	5b                   	pop    %ebx
f0105203:	5e                   	pop    %esi
f0105204:	5d                   	pop    %ebp
f0105205:	c3                   	ret    

f0105206 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105206:	55                   	push   %ebp
f0105207:	89 e5                	mov    %esp,%ebp
f0105209:	53                   	push   %ebx
f010520a:	8b 45 08             	mov    0x8(%ebp),%eax
f010520d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0105210:	0f b6 10             	movzbl (%eax),%edx
f0105213:	84 d2                	test   %dl,%dl
f0105215:	74 1d                	je     f0105234 <strchr+0x2e>
f0105217:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f0105219:	38 d3                	cmp    %dl,%bl
f010521b:	75 06                	jne    f0105223 <strchr+0x1d>
f010521d:	eb 1a                	jmp    f0105239 <strchr+0x33>
f010521f:	38 ca                	cmp    %cl,%dl
f0105221:	74 16                	je     f0105239 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105223:	83 c0 01             	add    $0x1,%eax
f0105226:	0f b6 10             	movzbl (%eax),%edx
f0105229:	84 d2                	test   %dl,%dl
f010522b:	75 f2                	jne    f010521f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f010522d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105232:	eb 05                	jmp    f0105239 <strchr+0x33>
f0105234:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105239:	5b                   	pop    %ebx
f010523a:	5d                   	pop    %ebp
f010523b:	c3                   	ret    

f010523c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010523c:	55                   	push   %ebp
f010523d:	89 e5                	mov    %esp,%ebp
f010523f:	53                   	push   %ebx
f0105240:	8b 45 08             	mov    0x8(%ebp),%eax
f0105243:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0105246:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f0105249:	38 d3                	cmp    %dl,%bl
f010524b:	74 14                	je     f0105261 <strfind+0x25>
f010524d:	89 d1                	mov    %edx,%ecx
f010524f:	84 db                	test   %bl,%bl
f0105251:	74 0e                	je     f0105261 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105253:	83 c0 01             	add    $0x1,%eax
f0105256:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105259:	38 ca                	cmp    %cl,%dl
f010525b:	74 04                	je     f0105261 <strfind+0x25>
f010525d:	84 d2                	test   %dl,%dl
f010525f:	75 f2                	jne    f0105253 <strfind+0x17>
			break;
	return (char *) s;
}
f0105261:	5b                   	pop    %ebx
f0105262:	5d                   	pop    %ebp
f0105263:	c3                   	ret    

f0105264 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105264:	55                   	push   %ebp
f0105265:	89 e5                	mov    %esp,%ebp
f0105267:	57                   	push   %edi
f0105268:	56                   	push   %esi
f0105269:	53                   	push   %ebx
f010526a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010526d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105270:	85 c9                	test   %ecx,%ecx
f0105272:	74 36                	je     f01052aa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105274:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010527a:	75 28                	jne    f01052a4 <memset+0x40>
f010527c:	f6 c1 03             	test   $0x3,%cl
f010527f:	75 23                	jne    f01052a4 <memset+0x40>
		c &= 0xFF;
f0105281:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105285:	89 d3                	mov    %edx,%ebx
f0105287:	c1 e3 08             	shl    $0x8,%ebx
f010528a:	89 d6                	mov    %edx,%esi
f010528c:	c1 e6 18             	shl    $0x18,%esi
f010528f:	89 d0                	mov    %edx,%eax
f0105291:	c1 e0 10             	shl    $0x10,%eax
f0105294:	09 f0                	or     %esi,%eax
f0105296:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105298:	89 d8                	mov    %ebx,%eax
f010529a:	09 d0                	or     %edx,%eax
f010529c:	c1 e9 02             	shr    $0x2,%ecx
f010529f:	fc                   	cld    
f01052a0:	f3 ab                	rep stos %eax,%es:(%edi)
f01052a2:	eb 06                	jmp    f01052aa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01052a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052a7:	fc                   	cld    
f01052a8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01052aa:	89 f8                	mov    %edi,%eax
f01052ac:	5b                   	pop    %ebx
f01052ad:	5e                   	pop    %esi
f01052ae:	5f                   	pop    %edi
f01052af:	5d                   	pop    %ebp
f01052b0:	c3                   	ret    

f01052b1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01052b1:	55                   	push   %ebp
f01052b2:	89 e5                	mov    %esp,%ebp
f01052b4:	57                   	push   %edi
f01052b5:	56                   	push   %esi
f01052b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01052bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01052bf:	39 c6                	cmp    %eax,%esi
f01052c1:	73 35                	jae    f01052f8 <memmove+0x47>
f01052c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01052c6:	39 d0                	cmp    %edx,%eax
f01052c8:	73 2e                	jae    f01052f8 <memmove+0x47>
		s += n;
		d += n;
f01052ca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01052cd:	89 d6                	mov    %edx,%esi
f01052cf:	09 fe                	or     %edi,%esi
f01052d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01052d7:	75 13                	jne    f01052ec <memmove+0x3b>
f01052d9:	f6 c1 03             	test   $0x3,%cl
f01052dc:	75 0e                	jne    f01052ec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01052de:	83 ef 04             	sub    $0x4,%edi
f01052e1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01052e4:	c1 e9 02             	shr    $0x2,%ecx
f01052e7:	fd                   	std    
f01052e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01052ea:	eb 09                	jmp    f01052f5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01052ec:	83 ef 01             	sub    $0x1,%edi
f01052ef:	8d 72 ff             	lea    -0x1(%edx),%esi
f01052f2:	fd                   	std    
f01052f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01052f5:	fc                   	cld    
f01052f6:	eb 1d                	jmp    f0105315 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01052f8:	89 f2                	mov    %esi,%edx
f01052fa:	09 c2                	or     %eax,%edx
f01052fc:	f6 c2 03             	test   $0x3,%dl
f01052ff:	75 0f                	jne    f0105310 <memmove+0x5f>
f0105301:	f6 c1 03             	test   $0x3,%cl
f0105304:	75 0a                	jne    f0105310 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105306:	c1 e9 02             	shr    $0x2,%ecx
f0105309:	89 c7                	mov    %eax,%edi
f010530b:	fc                   	cld    
f010530c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010530e:	eb 05                	jmp    f0105315 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105310:	89 c7                	mov    %eax,%edi
f0105312:	fc                   	cld    
f0105313:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105315:	5e                   	pop    %esi
f0105316:	5f                   	pop    %edi
f0105317:	5d                   	pop    %ebp
f0105318:	c3                   	ret    

f0105319 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0105319:	55                   	push   %ebp
f010531a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010531c:	ff 75 10             	pushl  0x10(%ebp)
f010531f:	ff 75 0c             	pushl  0xc(%ebp)
f0105322:	ff 75 08             	pushl  0x8(%ebp)
f0105325:	e8 87 ff ff ff       	call   f01052b1 <memmove>
}
f010532a:	c9                   	leave  
f010532b:	c3                   	ret    

f010532c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010532c:	55                   	push   %ebp
f010532d:	89 e5                	mov    %esp,%ebp
f010532f:	57                   	push   %edi
f0105330:	56                   	push   %esi
f0105331:	53                   	push   %ebx
f0105332:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105335:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105338:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010533b:	85 c0                	test   %eax,%eax
f010533d:	74 39                	je     f0105378 <memcmp+0x4c>
f010533f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f0105342:	0f b6 13             	movzbl (%ebx),%edx
f0105345:	0f b6 0e             	movzbl (%esi),%ecx
f0105348:	38 ca                	cmp    %cl,%dl
f010534a:	75 17                	jne    f0105363 <memcmp+0x37>
f010534c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105351:	eb 1a                	jmp    f010536d <memcmp+0x41>
f0105353:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f0105358:	83 c0 01             	add    $0x1,%eax
f010535b:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f010535f:	38 ca                	cmp    %cl,%dl
f0105361:	74 0a                	je     f010536d <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0105363:	0f b6 c2             	movzbl %dl,%eax
f0105366:	0f b6 c9             	movzbl %cl,%ecx
f0105369:	29 c8                	sub    %ecx,%eax
f010536b:	eb 10                	jmp    f010537d <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010536d:	39 f8                	cmp    %edi,%eax
f010536f:	75 e2                	jne    f0105353 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105371:	b8 00 00 00 00       	mov    $0x0,%eax
f0105376:	eb 05                	jmp    f010537d <memcmp+0x51>
f0105378:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010537d:	5b                   	pop    %ebx
f010537e:	5e                   	pop    %esi
f010537f:	5f                   	pop    %edi
f0105380:	5d                   	pop    %ebp
f0105381:	c3                   	ret    

f0105382 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105382:	55                   	push   %ebp
f0105383:	89 e5                	mov    %esp,%ebp
f0105385:	53                   	push   %ebx
f0105386:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f0105389:	89 d0                	mov    %edx,%eax
f010538b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f010538e:	39 c2                	cmp    %eax,%edx
f0105390:	73 1d                	jae    f01053af <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105392:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f0105396:	0f b6 0a             	movzbl (%edx),%ecx
f0105399:	39 d9                	cmp    %ebx,%ecx
f010539b:	75 09                	jne    f01053a6 <memfind+0x24>
f010539d:	eb 14                	jmp    f01053b3 <memfind+0x31>
f010539f:	0f b6 0a             	movzbl (%edx),%ecx
f01053a2:	39 d9                	cmp    %ebx,%ecx
f01053a4:	74 11                	je     f01053b7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01053a6:	83 c2 01             	add    $0x1,%edx
f01053a9:	39 d0                	cmp    %edx,%eax
f01053ab:	75 f2                	jne    f010539f <memfind+0x1d>
f01053ad:	eb 0a                	jmp    f01053b9 <memfind+0x37>
f01053af:	89 d0                	mov    %edx,%eax
f01053b1:	eb 06                	jmp    f01053b9 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f01053b3:	89 d0                	mov    %edx,%eax
f01053b5:	eb 02                	jmp    f01053b9 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01053b7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01053b9:	5b                   	pop    %ebx
f01053ba:	5d                   	pop    %ebp
f01053bb:	c3                   	ret    

f01053bc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01053bc:	55                   	push   %ebp
f01053bd:	89 e5                	mov    %esp,%ebp
f01053bf:	57                   	push   %edi
f01053c0:	56                   	push   %esi
f01053c1:	53                   	push   %ebx
f01053c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01053c8:	0f b6 01             	movzbl (%ecx),%eax
f01053cb:	3c 20                	cmp    $0x20,%al
f01053cd:	74 04                	je     f01053d3 <strtol+0x17>
f01053cf:	3c 09                	cmp    $0x9,%al
f01053d1:	75 0e                	jne    f01053e1 <strtol+0x25>
		s++;
f01053d3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01053d6:	0f b6 01             	movzbl (%ecx),%eax
f01053d9:	3c 20                	cmp    $0x20,%al
f01053db:	74 f6                	je     f01053d3 <strtol+0x17>
f01053dd:	3c 09                	cmp    $0x9,%al
f01053df:	74 f2                	je     f01053d3 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f01053e1:	3c 2b                	cmp    $0x2b,%al
f01053e3:	75 0a                	jne    f01053ef <strtol+0x33>
		s++;
f01053e5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01053e8:	bf 00 00 00 00       	mov    $0x0,%edi
f01053ed:	eb 11                	jmp    f0105400 <strtol+0x44>
f01053ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01053f4:	3c 2d                	cmp    $0x2d,%al
f01053f6:	75 08                	jne    f0105400 <strtol+0x44>
		s++, neg = 1;
f01053f8:	83 c1 01             	add    $0x1,%ecx
f01053fb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105400:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105406:	75 15                	jne    f010541d <strtol+0x61>
f0105408:	80 39 30             	cmpb   $0x30,(%ecx)
f010540b:	75 10                	jne    f010541d <strtol+0x61>
f010540d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105411:	75 7c                	jne    f010548f <strtol+0xd3>
		s += 2, base = 16;
f0105413:	83 c1 02             	add    $0x2,%ecx
f0105416:	bb 10 00 00 00       	mov    $0x10,%ebx
f010541b:	eb 16                	jmp    f0105433 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f010541d:	85 db                	test   %ebx,%ebx
f010541f:	75 12                	jne    f0105433 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105421:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105426:	80 39 30             	cmpb   $0x30,(%ecx)
f0105429:	75 08                	jne    f0105433 <strtol+0x77>
		s++, base = 8;
f010542b:	83 c1 01             	add    $0x1,%ecx
f010542e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105433:	b8 00 00 00 00       	mov    $0x0,%eax
f0105438:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010543b:	0f b6 11             	movzbl (%ecx),%edx
f010543e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105441:	89 f3                	mov    %esi,%ebx
f0105443:	80 fb 09             	cmp    $0x9,%bl
f0105446:	77 08                	ja     f0105450 <strtol+0x94>
			dig = *s - '0';
f0105448:	0f be d2             	movsbl %dl,%edx
f010544b:	83 ea 30             	sub    $0x30,%edx
f010544e:	eb 22                	jmp    f0105472 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f0105450:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105453:	89 f3                	mov    %esi,%ebx
f0105455:	80 fb 19             	cmp    $0x19,%bl
f0105458:	77 08                	ja     f0105462 <strtol+0xa6>
			dig = *s - 'a' + 10;
f010545a:	0f be d2             	movsbl %dl,%edx
f010545d:	83 ea 57             	sub    $0x57,%edx
f0105460:	eb 10                	jmp    f0105472 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f0105462:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105465:	89 f3                	mov    %esi,%ebx
f0105467:	80 fb 19             	cmp    $0x19,%bl
f010546a:	77 16                	ja     f0105482 <strtol+0xc6>
			dig = *s - 'A' + 10;
f010546c:	0f be d2             	movsbl %dl,%edx
f010546f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105472:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105475:	7d 0b                	jge    f0105482 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0105477:	83 c1 01             	add    $0x1,%ecx
f010547a:	0f af 45 10          	imul   0x10(%ebp),%eax
f010547e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105480:	eb b9                	jmp    f010543b <strtol+0x7f>

	if (endptr)
f0105482:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105486:	74 0d                	je     f0105495 <strtol+0xd9>
		*endptr = (char *) s;
f0105488:	8b 75 0c             	mov    0xc(%ebp),%esi
f010548b:	89 0e                	mov    %ecx,(%esi)
f010548d:	eb 06                	jmp    f0105495 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010548f:	85 db                	test   %ebx,%ebx
f0105491:	74 98                	je     f010542b <strtol+0x6f>
f0105493:	eb 9e                	jmp    f0105433 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105495:	89 c2                	mov    %eax,%edx
f0105497:	f7 da                	neg    %edx
f0105499:	85 ff                	test   %edi,%edi
f010549b:	0f 45 c2             	cmovne %edx,%eax
}
f010549e:	5b                   	pop    %ebx
f010549f:	5e                   	pop    %esi
f01054a0:	5f                   	pop    %edi
f01054a1:	5d                   	pop    %ebp
f01054a2:	c3                   	ret    
f01054a3:	66 90                	xchg   %ax,%ax
f01054a5:	66 90                	xchg   %ax,%ax
f01054a7:	66 90                	xchg   %ax,%ax
f01054a9:	66 90                	xchg   %ax,%ax
f01054ab:	66 90                	xchg   %ax,%ax
f01054ad:	66 90                	xchg   %ax,%ax
f01054af:	90                   	nop

f01054b0 <__udivdi3>:
f01054b0:	55                   	push   %ebp
f01054b1:	57                   	push   %edi
f01054b2:	56                   	push   %esi
f01054b3:	53                   	push   %ebx
f01054b4:	83 ec 1c             	sub    $0x1c,%esp
f01054b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01054bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01054bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01054c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01054c7:	85 f6                	test   %esi,%esi
f01054c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01054cd:	89 ca                	mov    %ecx,%edx
f01054cf:	89 f8                	mov    %edi,%eax
f01054d1:	75 3d                	jne    f0105510 <__udivdi3+0x60>
f01054d3:	39 cf                	cmp    %ecx,%edi
f01054d5:	0f 87 c5 00 00 00    	ja     f01055a0 <__udivdi3+0xf0>
f01054db:	85 ff                	test   %edi,%edi
f01054dd:	89 fd                	mov    %edi,%ebp
f01054df:	75 0b                	jne    f01054ec <__udivdi3+0x3c>
f01054e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01054e6:	31 d2                	xor    %edx,%edx
f01054e8:	f7 f7                	div    %edi
f01054ea:	89 c5                	mov    %eax,%ebp
f01054ec:	89 c8                	mov    %ecx,%eax
f01054ee:	31 d2                	xor    %edx,%edx
f01054f0:	f7 f5                	div    %ebp
f01054f2:	89 c1                	mov    %eax,%ecx
f01054f4:	89 d8                	mov    %ebx,%eax
f01054f6:	89 cf                	mov    %ecx,%edi
f01054f8:	f7 f5                	div    %ebp
f01054fa:	89 c3                	mov    %eax,%ebx
f01054fc:	89 d8                	mov    %ebx,%eax
f01054fe:	89 fa                	mov    %edi,%edx
f0105500:	83 c4 1c             	add    $0x1c,%esp
f0105503:	5b                   	pop    %ebx
f0105504:	5e                   	pop    %esi
f0105505:	5f                   	pop    %edi
f0105506:	5d                   	pop    %ebp
f0105507:	c3                   	ret    
f0105508:	90                   	nop
f0105509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105510:	39 ce                	cmp    %ecx,%esi
f0105512:	77 74                	ja     f0105588 <__udivdi3+0xd8>
f0105514:	0f bd fe             	bsr    %esi,%edi
f0105517:	83 f7 1f             	xor    $0x1f,%edi
f010551a:	0f 84 98 00 00 00    	je     f01055b8 <__udivdi3+0x108>
f0105520:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105525:	89 f9                	mov    %edi,%ecx
f0105527:	89 c5                	mov    %eax,%ebp
f0105529:	29 fb                	sub    %edi,%ebx
f010552b:	d3 e6                	shl    %cl,%esi
f010552d:	89 d9                	mov    %ebx,%ecx
f010552f:	d3 ed                	shr    %cl,%ebp
f0105531:	89 f9                	mov    %edi,%ecx
f0105533:	d3 e0                	shl    %cl,%eax
f0105535:	09 ee                	or     %ebp,%esi
f0105537:	89 d9                	mov    %ebx,%ecx
f0105539:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010553d:	89 d5                	mov    %edx,%ebp
f010553f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105543:	d3 ed                	shr    %cl,%ebp
f0105545:	89 f9                	mov    %edi,%ecx
f0105547:	d3 e2                	shl    %cl,%edx
f0105549:	89 d9                	mov    %ebx,%ecx
f010554b:	d3 e8                	shr    %cl,%eax
f010554d:	09 c2                	or     %eax,%edx
f010554f:	89 d0                	mov    %edx,%eax
f0105551:	89 ea                	mov    %ebp,%edx
f0105553:	f7 f6                	div    %esi
f0105555:	89 d5                	mov    %edx,%ebp
f0105557:	89 c3                	mov    %eax,%ebx
f0105559:	f7 64 24 0c          	mull   0xc(%esp)
f010555d:	39 d5                	cmp    %edx,%ebp
f010555f:	72 10                	jb     f0105571 <__udivdi3+0xc1>
f0105561:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105565:	89 f9                	mov    %edi,%ecx
f0105567:	d3 e6                	shl    %cl,%esi
f0105569:	39 c6                	cmp    %eax,%esi
f010556b:	73 07                	jae    f0105574 <__udivdi3+0xc4>
f010556d:	39 d5                	cmp    %edx,%ebp
f010556f:	75 03                	jne    f0105574 <__udivdi3+0xc4>
f0105571:	83 eb 01             	sub    $0x1,%ebx
f0105574:	31 ff                	xor    %edi,%edi
f0105576:	89 d8                	mov    %ebx,%eax
f0105578:	89 fa                	mov    %edi,%edx
f010557a:	83 c4 1c             	add    $0x1c,%esp
f010557d:	5b                   	pop    %ebx
f010557e:	5e                   	pop    %esi
f010557f:	5f                   	pop    %edi
f0105580:	5d                   	pop    %ebp
f0105581:	c3                   	ret    
f0105582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105588:	31 ff                	xor    %edi,%edi
f010558a:	31 db                	xor    %ebx,%ebx
f010558c:	89 d8                	mov    %ebx,%eax
f010558e:	89 fa                	mov    %edi,%edx
f0105590:	83 c4 1c             	add    $0x1c,%esp
f0105593:	5b                   	pop    %ebx
f0105594:	5e                   	pop    %esi
f0105595:	5f                   	pop    %edi
f0105596:	5d                   	pop    %ebp
f0105597:	c3                   	ret    
f0105598:	90                   	nop
f0105599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01055a0:	89 d8                	mov    %ebx,%eax
f01055a2:	f7 f7                	div    %edi
f01055a4:	31 ff                	xor    %edi,%edi
f01055a6:	89 c3                	mov    %eax,%ebx
f01055a8:	89 d8                	mov    %ebx,%eax
f01055aa:	89 fa                	mov    %edi,%edx
f01055ac:	83 c4 1c             	add    $0x1c,%esp
f01055af:	5b                   	pop    %ebx
f01055b0:	5e                   	pop    %esi
f01055b1:	5f                   	pop    %edi
f01055b2:	5d                   	pop    %ebp
f01055b3:	c3                   	ret    
f01055b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01055b8:	39 ce                	cmp    %ecx,%esi
f01055ba:	72 0c                	jb     f01055c8 <__udivdi3+0x118>
f01055bc:	31 db                	xor    %ebx,%ebx
f01055be:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01055c2:	0f 87 34 ff ff ff    	ja     f01054fc <__udivdi3+0x4c>
f01055c8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01055cd:	e9 2a ff ff ff       	jmp    f01054fc <__udivdi3+0x4c>
f01055d2:	66 90                	xchg   %ax,%ax
f01055d4:	66 90                	xchg   %ax,%ax
f01055d6:	66 90                	xchg   %ax,%ax
f01055d8:	66 90                	xchg   %ax,%ax
f01055da:	66 90                	xchg   %ax,%ax
f01055dc:	66 90                	xchg   %ax,%ax
f01055de:	66 90                	xchg   %ax,%ax

f01055e0 <__umoddi3>:
f01055e0:	55                   	push   %ebp
f01055e1:	57                   	push   %edi
f01055e2:	56                   	push   %esi
f01055e3:	53                   	push   %ebx
f01055e4:	83 ec 1c             	sub    $0x1c,%esp
f01055e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01055eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01055ef:	8b 74 24 34          	mov    0x34(%esp),%esi
f01055f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01055f7:	85 d2                	test   %edx,%edx
f01055f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01055fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105601:	89 f3                	mov    %esi,%ebx
f0105603:	89 3c 24             	mov    %edi,(%esp)
f0105606:	89 74 24 04          	mov    %esi,0x4(%esp)
f010560a:	75 1c                	jne    f0105628 <__umoddi3+0x48>
f010560c:	39 f7                	cmp    %esi,%edi
f010560e:	76 50                	jbe    f0105660 <__umoddi3+0x80>
f0105610:	89 c8                	mov    %ecx,%eax
f0105612:	89 f2                	mov    %esi,%edx
f0105614:	f7 f7                	div    %edi
f0105616:	89 d0                	mov    %edx,%eax
f0105618:	31 d2                	xor    %edx,%edx
f010561a:	83 c4 1c             	add    $0x1c,%esp
f010561d:	5b                   	pop    %ebx
f010561e:	5e                   	pop    %esi
f010561f:	5f                   	pop    %edi
f0105620:	5d                   	pop    %ebp
f0105621:	c3                   	ret    
f0105622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105628:	39 f2                	cmp    %esi,%edx
f010562a:	89 d0                	mov    %edx,%eax
f010562c:	77 52                	ja     f0105680 <__umoddi3+0xa0>
f010562e:	0f bd ea             	bsr    %edx,%ebp
f0105631:	83 f5 1f             	xor    $0x1f,%ebp
f0105634:	75 5a                	jne    f0105690 <__umoddi3+0xb0>
f0105636:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010563a:	0f 82 e0 00 00 00    	jb     f0105720 <__umoddi3+0x140>
f0105640:	39 0c 24             	cmp    %ecx,(%esp)
f0105643:	0f 86 d7 00 00 00    	jbe    f0105720 <__umoddi3+0x140>
f0105649:	8b 44 24 08          	mov    0x8(%esp),%eax
f010564d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105651:	83 c4 1c             	add    $0x1c,%esp
f0105654:	5b                   	pop    %ebx
f0105655:	5e                   	pop    %esi
f0105656:	5f                   	pop    %edi
f0105657:	5d                   	pop    %ebp
f0105658:	c3                   	ret    
f0105659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105660:	85 ff                	test   %edi,%edi
f0105662:	89 fd                	mov    %edi,%ebp
f0105664:	75 0b                	jne    f0105671 <__umoddi3+0x91>
f0105666:	b8 01 00 00 00       	mov    $0x1,%eax
f010566b:	31 d2                	xor    %edx,%edx
f010566d:	f7 f7                	div    %edi
f010566f:	89 c5                	mov    %eax,%ebp
f0105671:	89 f0                	mov    %esi,%eax
f0105673:	31 d2                	xor    %edx,%edx
f0105675:	f7 f5                	div    %ebp
f0105677:	89 c8                	mov    %ecx,%eax
f0105679:	f7 f5                	div    %ebp
f010567b:	89 d0                	mov    %edx,%eax
f010567d:	eb 99                	jmp    f0105618 <__umoddi3+0x38>
f010567f:	90                   	nop
f0105680:	89 c8                	mov    %ecx,%eax
f0105682:	89 f2                	mov    %esi,%edx
f0105684:	83 c4 1c             	add    $0x1c,%esp
f0105687:	5b                   	pop    %ebx
f0105688:	5e                   	pop    %esi
f0105689:	5f                   	pop    %edi
f010568a:	5d                   	pop    %ebp
f010568b:	c3                   	ret    
f010568c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105690:	8b 34 24             	mov    (%esp),%esi
f0105693:	bf 20 00 00 00       	mov    $0x20,%edi
f0105698:	89 e9                	mov    %ebp,%ecx
f010569a:	29 ef                	sub    %ebp,%edi
f010569c:	d3 e0                	shl    %cl,%eax
f010569e:	89 f9                	mov    %edi,%ecx
f01056a0:	89 f2                	mov    %esi,%edx
f01056a2:	d3 ea                	shr    %cl,%edx
f01056a4:	89 e9                	mov    %ebp,%ecx
f01056a6:	09 c2                	or     %eax,%edx
f01056a8:	89 d8                	mov    %ebx,%eax
f01056aa:	89 14 24             	mov    %edx,(%esp)
f01056ad:	89 f2                	mov    %esi,%edx
f01056af:	d3 e2                	shl    %cl,%edx
f01056b1:	89 f9                	mov    %edi,%ecx
f01056b3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01056b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01056bb:	d3 e8                	shr    %cl,%eax
f01056bd:	89 e9                	mov    %ebp,%ecx
f01056bf:	89 c6                	mov    %eax,%esi
f01056c1:	d3 e3                	shl    %cl,%ebx
f01056c3:	89 f9                	mov    %edi,%ecx
f01056c5:	89 d0                	mov    %edx,%eax
f01056c7:	d3 e8                	shr    %cl,%eax
f01056c9:	89 e9                	mov    %ebp,%ecx
f01056cb:	09 d8                	or     %ebx,%eax
f01056cd:	89 d3                	mov    %edx,%ebx
f01056cf:	89 f2                	mov    %esi,%edx
f01056d1:	f7 34 24             	divl   (%esp)
f01056d4:	89 d6                	mov    %edx,%esi
f01056d6:	d3 e3                	shl    %cl,%ebx
f01056d8:	f7 64 24 04          	mull   0x4(%esp)
f01056dc:	39 d6                	cmp    %edx,%esi
f01056de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01056e2:	89 d1                	mov    %edx,%ecx
f01056e4:	89 c3                	mov    %eax,%ebx
f01056e6:	72 08                	jb     f01056f0 <__umoddi3+0x110>
f01056e8:	75 11                	jne    f01056fb <__umoddi3+0x11b>
f01056ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01056ee:	73 0b                	jae    f01056fb <__umoddi3+0x11b>
f01056f0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01056f4:	1b 14 24             	sbb    (%esp),%edx
f01056f7:	89 d1                	mov    %edx,%ecx
f01056f9:	89 c3                	mov    %eax,%ebx
f01056fb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01056ff:	29 da                	sub    %ebx,%edx
f0105701:	19 ce                	sbb    %ecx,%esi
f0105703:	89 f9                	mov    %edi,%ecx
f0105705:	89 f0                	mov    %esi,%eax
f0105707:	d3 e0                	shl    %cl,%eax
f0105709:	89 e9                	mov    %ebp,%ecx
f010570b:	d3 ea                	shr    %cl,%edx
f010570d:	89 e9                	mov    %ebp,%ecx
f010570f:	d3 ee                	shr    %cl,%esi
f0105711:	09 d0                	or     %edx,%eax
f0105713:	89 f2                	mov    %esi,%edx
f0105715:	83 c4 1c             	add    $0x1c,%esp
f0105718:	5b                   	pop    %ebx
f0105719:	5e                   	pop    %esi
f010571a:	5f                   	pop    %edi
f010571b:	5d                   	pop    %ebp
f010571c:	c3                   	ret    
f010571d:	8d 76 00             	lea    0x0(%esi),%esi
f0105720:	29 f9                	sub    %edi,%ecx
f0105722:	19 d6                	sbb    %edx,%esi
f0105724:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010572c:	e9 18 ff ff ff       	jmp    f0105649 <__umoddi3+0x69>
