
obj/user/evilhello2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 16 01 00 00       	call   800147 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <evil>:
#include <inc/x86.h>


// Call this function with ring0 privilege
void evil()
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800036:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003d:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800042:	b8 49 00 00 00       	mov    $0x49,%eax
  800047:	ee                   	out    %al,(%dx)
  800048:	b8 4e 00 00 00       	mov    $0x4e,%eax
  80004d:	ee                   	out    %al,(%dx)
  80004e:	b8 20 00 00 00       	mov    $0x20,%eax
  800053:	ee                   	out    %al,(%dx)
  800054:	b8 52 00 00 00       	mov    $0x52,%eax
  800059:	ee                   	out    %al,(%dx)
  80005a:	b8 49 00 00 00       	mov    $0x49,%eax
  80005f:	ee                   	out    %al,(%dx)
  800060:	b8 4e 00 00 00       	mov    $0x4e,%eax
  800065:	ee                   	out    %al,(%dx)
  800066:	b8 47 00 00 00       	mov    $0x47,%eax
  80006b:	ee                   	out    %al,(%dx)
  80006c:	b8 30 00 00 00       	mov    $0x30,%eax
  800071:	ee                   	out    %al,(%dx)
  800072:	b8 21 00 00 00       	mov    $0x21,%eax
  800077:	ee                   	out    %al,(%dx)
  800078:	ee                   	out    %al,(%dx)
  800079:	ee                   	out    %al,(%dx)
  80007a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80007f:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <warpper>:
struct Segdesc backup;
struct Segdesc *gdt;
struct Segdesc *entry;

void warpper()
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
	evil();
  800085:	e8 a9 ff ff ff       	call   800033 <evil>
	*entry = backup;
  80008a:	a1 64 30 80 00       	mov    0x803064,%eax
  80008f:	8b 15 68 30 80 00    	mov    0x803068,%edx
  800095:	8b 0d 40 20 80 00    	mov    0x802040,%ecx
  80009b:	89 01                	mov    %eax,(%ecx)
  80009d:	89 51 04             	mov    %edx,0x4(%ecx)
	__asm __volatile("popl %ebp\r\n"	\
  8000a0:	5d                   	pop    %ebp
  8000a1:	cb                   	lret   
								"lret\r\n");
}
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <ring0_call>:

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 20             	sub    $0x20,%esp
}

static void
sgdt(struct Pseudodesc* gdtd)
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
  8000aa:	0f 01 45 f2          	sgdtl  -0xe(%ebp)

    // Lab3 : Your Code Here
		struct Pseudodesc gdtd;
		sgdt(&gdtd);

		int err = sys_map_kernel_page((void *)gdtd.pd_base, (void *)vaddr);
  8000ae:	68 60 20 80 00       	push   $0x802060
  8000b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8000b6:	e8 70 0e 00 00       	call   800f2b <sys_map_kernel_page>
		if (err) {
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	85 c0                	test   %eax,%eax
  8000c0:	74 10                	je     8000d2 <ring0_call+0x2e>
			cprintf("sys_map_kernel_page failed\n");
  8000c2:	83 ec 0c             	sub    $0xc,%esp
  8000c5:	68 00 15 80 00       	push   $0x801500
  8000ca:	e8 63 01 00 00       	call   800232 <cprintf>
  8000cf:	83 c4 10             	add    $0x10,%esp

		uint32_t base = (uint32_t)vaddr & ~0xFFF;
		uint32_t offset = PGOFF(gdtd.pd_base);
		uint32_t index = GD_UD >> 0x3;

		gdt = (struct Segdesc *)(base + offset);
  8000d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000d5:	25 ff 0f 00 00       	and    $0xfff,%eax
  8000da:	b9 60 20 80 00       	mov    $0x802060,%ecx
  8000df:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  8000e5:	01 c1                	add    %eax,%ecx
  8000e7:	89 0d 60 30 80 00    	mov    %ecx,0x803060
		entry = gdt + index;
  8000ed:	8d 41 20             	lea    0x20(%ecx),%eax
  8000f0:	a3 40 20 80 00       	mov    %eax,0x802040
		backup = *entry;
  8000f5:	8b 41 20             	mov    0x20(%ecx),%eax
  8000f8:	8b 51 24             	mov    0x24(%ecx),%edx
  8000fb:	a3 64 30 80 00       	mov    %eax,0x803064
  800100:	89 15 68 30 80 00    	mov    %edx,0x803068

		SETCALLGATE(*((struct Gatedesc *)entry), GD_KT, warpper, 3);
  800106:	b8 82 00 80 00       	mov    $0x800082,%eax
  80010b:	66 89 41 20          	mov    %ax,0x20(%ecx)
  80010f:	66 c7 41 22 08 00    	movw   $0x8,0x22(%ecx)
  800115:	c6 41 24 00          	movb   $0x0,0x24(%ecx)
  800119:	c6 41 25 ec          	movb   $0xec,0x25(%ecx)
  80011d:	c1 e8 10             	shr    $0x10,%eax
  800120:	66 89 41 26          	mov    %ax,0x26(%ecx)
		__asm __volatile("lcall $0x20, $0");
  800124:	9a 00 00 00 00 20 00 	lcall  $0x20,$0x0
}
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <umain>:

void
umain(int argc, char **argv)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 14             	sub    $0x14,%esp
        // call the evil function in ring0
	ring0_call(&evil);
  800133:	68 33 00 80 00       	push   $0x800033
  800138:	e8 67 ff ff ff       	call   8000a4 <ring0_call>

	// call the evil function in ring3
	evil();
  80013d:	e8 f1 fe ff ff       	call   800033 <evil>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80014f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800152:	e8 a3 0d 00 00       	call   800efa <sys_getenvid>
  800157:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015c:	c1 e0 07             	shl    $0x7,%eax
  80015f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800164:	a3 6c 30 80 00       	mov    %eax,0x80306c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800169:	85 db                	test   %ebx,%ebx
  80016b:	7e 07                	jle    800174 <libmain+0x2d>
		binaryname = argv[0];
  80016d:	8b 06                	mov    (%esi),%eax
  80016f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800174:	83 ec 08             	sub    $0x8,%esp
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
  800179:	e8 af ff ff ff       	call   80012d <umain>

	// exit gracefully
	exit();
  80017e:	e8 0a 00 00 00       	call   80018d <exit>
}
  800183:	83 c4 10             	add    $0x10,%esp
  800186:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800193:	6a 00                	push   $0x0
  800195:	e8 10 0d 00 00       	call   800eaa <sys_env_destroy>
}
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 04             	sub    $0x4,%esp
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a9:	8b 13                	mov    (%ebx),%edx
  8001ab:	8d 42 01             	lea    0x1(%edx),%eax
  8001ae:	89 03                	mov    %eax,(%ebx)
  8001b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bc:	75 1a                	jne    8001d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	68 ff 00 00 00       	push   $0xff
  8001c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c9:	50                   	push   %eax
  8001ca:	e8 7a 0c 00 00       	call   800e49 <sys_cputs>
		b->idx = 0;
  8001cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	ff 75 0c             	pushl  0xc(%ebp)
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	68 9f 01 80 00       	push   $0x80019f
  800210:	e8 c0 02 00 00       	call   8004d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	e8 1f 0c 00 00       	call   800e49 <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 9d ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80025f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800262:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800266:	0f 85 bf 00 00 00    	jne    80032b <printnum+0xe5>
  80026c:	39 1d 24 20 80 00    	cmp    %ebx,0x802024
  800272:	0f 8d de 00 00 00    	jge    800356 <printnum+0x110>
		judge_time_for_space = width;
  800278:	89 1d 24 20 80 00    	mov    %ebx,0x802024
  80027e:	e9 d3 00 00 00       	jmp    800356 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800283:	83 eb 01             	sub    $0x1,%ebx
  800286:	85 db                	test   %ebx,%ebx
  800288:	7f 37                	jg     8002c1 <printnum+0x7b>
  80028a:	e9 ea 00 00 00       	jmp    800379 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80028f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800292:	a3 20 20 80 00       	mov    %eax,0x802020
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800297:	83 ec 08             	sub    $0x8,%esp
  80029a:	56                   	push   %esi
  80029b:	83 ec 04             	sub    $0x4,%esp
  80029e:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002aa:	e8 e1 10 00 00       	call   801390 <__umoddi3>
  8002af:	83 c4 14             	add    $0x14,%esp
  8002b2:	0f be 80 26 15 80 00 	movsbl 0x801526(%eax),%eax
  8002b9:	50                   	push   %eax
  8002ba:	ff d7                	call   *%edi
  8002bc:	83 c4 10             	add    $0x10,%esp
  8002bf:	eb 16                	jmp    8002d7 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	56                   	push   %esi
  8002c5:	ff 75 18             	pushl  0x18(%ebp)
  8002c8:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	83 eb 01             	sub    $0x1,%ebx
  8002d0:	75 ef                	jne    8002c1 <printnum+0x7b>
  8002d2:	e9 a2 00 00 00       	jmp    800379 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8002d7:	3b 1d 24 20 80 00    	cmp    0x802024,%ebx
  8002dd:	0f 85 76 01 00 00    	jne    800459 <printnum+0x213>
		while(num_of_space-- > 0)
  8002e3:	a1 20 20 80 00       	mov    0x802020,%eax
  8002e8:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002eb:	89 15 20 20 80 00    	mov    %edx,0x802020
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7e 1d                	jle    800312 <printnum+0xcc>
			putch(' ', putdat);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	56                   	push   %esi
  8002f9:	6a 20                	push   $0x20
  8002fb:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8002fd:	a1 20 20 80 00       	mov    0x802020,%eax
  800302:	8d 50 ff             	lea    -0x1(%eax),%edx
  800305:	89 15 20 20 80 00    	mov    %edx,0x802020
  80030b:	83 c4 10             	add    $0x10,%esp
  80030e:	85 c0                	test   %eax,%eax
  800310:	7f e3                	jg     8002f5 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800312:	c7 05 20 20 80 00 00 	movl   $0x0,0x802020
  800319:	00 00 00 
		judge_time_for_space = 0;
  80031c:	c7 05 24 20 80 00 00 	movl   $0x0,0x802024
  800323:	00 00 00 
	}
}
  800326:	e9 2e 01 00 00       	jmp    800459 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80032b:	8b 45 10             	mov    0x10(%ebp),%eax
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800336:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800339:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80033f:	83 fa 00             	cmp    $0x0,%edx
  800342:	0f 87 ba 00 00 00    	ja     800402 <printnum+0x1bc>
  800348:	3b 45 10             	cmp    0x10(%ebp),%eax
  80034b:	0f 83 b1 00 00 00    	jae    800402 <printnum+0x1bc>
  800351:	e9 2d ff ff ff       	jmp    800283 <printnum+0x3d>
  800356:	8b 45 10             	mov    0x10(%ebp),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800361:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800364:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800367:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80036a:	83 fa 00             	cmp    $0x0,%edx
  80036d:	77 37                	ja     8003a6 <printnum+0x160>
  80036f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800372:	73 32                	jae    8003a6 <printnum+0x160>
  800374:	e9 16 ff ff ff       	jmp    80028f <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	56                   	push   %esi
  80037d:	83 ec 04             	sub    $0x4,%esp
  800380:	ff 75 dc             	pushl  -0x24(%ebp)
  800383:	ff 75 d8             	pushl  -0x28(%ebp)
  800386:	ff 75 e4             	pushl  -0x1c(%ebp)
  800389:	ff 75 e0             	pushl  -0x20(%ebp)
  80038c:	e8 ff 0f 00 00       	call   801390 <__umoddi3>
  800391:	83 c4 14             	add    $0x14,%esp
  800394:	0f be 80 26 15 80 00 	movsbl 0x801526(%eax),%eax
  80039b:	50                   	push   %eax
  80039c:	ff d7                	call   *%edi
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	e9 b3 00 00 00       	jmp    800459 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003a6:	83 ec 0c             	sub    $0xc,%esp
  8003a9:	ff 75 18             	pushl  0x18(%ebp)
  8003ac:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	83 ec 08             	sub    $0x8,%esp
  8003b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c2:	e8 99 0e 00 00       	call   801260 <__udivdi3>
  8003c7:	83 c4 18             	add    $0x18,%esp
  8003ca:	52                   	push   %edx
  8003cb:	50                   	push   %eax
  8003cc:	89 f2                	mov    %esi,%edx
  8003ce:	89 f8                	mov    %edi,%eax
  8003d0:	e8 71 fe ff ff       	call   800246 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d5:	83 c4 18             	add    $0x18,%esp
  8003d8:	56                   	push   %esi
  8003d9:	83 ec 04             	sub    $0x4,%esp
  8003dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8003df:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e8:	e8 a3 0f 00 00       	call   801390 <__umoddi3>
  8003ed:	83 c4 14             	add    $0x14,%esp
  8003f0:	0f be 80 26 15 80 00 	movsbl 0x801526(%eax),%eax
  8003f7:	50                   	push   %eax
  8003f8:	ff d7                	call   *%edi
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	e9 d5 fe ff ff       	jmp    8002d7 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800402:	83 ec 0c             	sub    $0xc,%esp
  800405:	ff 75 18             	pushl  0x18(%ebp)
  800408:	83 eb 01             	sub    $0x1,%ebx
  80040b:	53                   	push   %ebx
  80040c:	ff 75 10             	pushl  0x10(%ebp)
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	ff 75 dc             	pushl  -0x24(%ebp)
  800415:	ff 75 d8             	pushl  -0x28(%ebp)
  800418:	ff 75 e4             	pushl  -0x1c(%ebp)
  80041b:	ff 75 e0             	pushl  -0x20(%ebp)
  80041e:	e8 3d 0e 00 00       	call   801260 <__udivdi3>
  800423:	83 c4 18             	add    $0x18,%esp
  800426:	52                   	push   %edx
  800427:	50                   	push   %eax
  800428:	89 f2                	mov    %esi,%edx
  80042a:	89 f8                	mov    %edi,%eax
  80042c:	e8 15 fe ff ff       	call   800246 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800431:	83 c4 18             	add    $0x18,%esp
  800434:	56                   	push   %esi
  800435:	83 ec 04             	sub    $0x4,%esp
  800438:	ff 75 dc             	pushl  -0x24(%ebp)
  80043b:	ff 75 d8             	pushl  -0x28(%ebp)
  80043e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800441:	ff 75 e0             	pushl  -0x20(%ebp)
  800444:	e8 47 0f 00 00       	call   801390 <__umoddi3>
  800449:	83 c4 14             	add    $0x14,%esp
  80044c:	0f be 80 26 15 80 00 	movsbl 0x801526(%eax),%eax
  800453:	50                   	push   %eax
  800454:	ff d7                	call   *%edi
  800456:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800459:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80045c:	5b                   	pop    %ebx
  80045d:	5e                   	pop    %esi
  80045e:	5f                   	pop    %edi
  80045f:	5d                   	pop    %ebp
  800460:	c3                   	ret    

00800461 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800464:	83 fa 01             	cmp    $0x1,%edx
  800467:	7e 0e                	jle    800477 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800469:	8b 10                	mov    (%eax),%edx
  80046b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80046e:	89 08                	mov    %ecx,(%eax)
  800470:	8b 02                	mov    (%edx),%eax
  800472:	8b 52 04             	mov    0x4(%edx),%edx
  800475:	eb 22                	jmp    800499 <getuint+0x38>
	else if (lflag)
  800477:	85 d2                	test   %edx,%edx
  800479:	74 10                	je     80048b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80047b:	8b 10                	mov    (%eax),%edx
  80047d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800480:	89 08                	mov    %ecx,(%eax)
  800482:	8b 02                	mov    (%edx),%eax
  800484:	ba 00 00 00 00       	mov    $0x0,%edx
  800489:	eb 0e                	jmp    800499 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80048b:	8b 10                	mov    (%eax),%edx
  80048d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800490:	89 08                	mov    %ecx,(%eax)
  800492:	8b 02                	mov    (%edx),%eax
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800499:	5d                   	pop    %ebp
  80049a:	c3                   	ret    

0080049b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004aa:	73 0a                	jae    8004b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b4:	88 02                	mov    %al,(%edx)
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c1:	50                   	push   %eax
  8004c2:	ff 75 10             	pushl  0x10(%ebp)
  8004c5:	ff 75 0c             	pushl  0xc(%ebp)
  8004c8:	ff 75 08             	pushl  0x8(%ebp)
  8004cb:	e8 05 00 00 00       	call   8004d5 <vprintfmt>
	va_end(ap);
}
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	c9                   	leave  
  8004d4:	c3                   	ret    

008004d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	57                   	push   %edi
  8004d9:	56                   	push   %esi
  8004da:	53                   	push   %ebx
  8004db:	83 ec 2c             	sub    $0x2c,%esp
  8004de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e4:	eb 03                	jmp    8004e9 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004e6:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ec:	8d 70 01             	lea    0x1(%eax),%esi
  8004ef:	0f b6 00             	movzbl (%eax),%eax
  8004f2:	83 f8 25             	cmp    $0x25,%eax
  8004f5:	74 27                	je     80051e <vprintfmt+0x49>
			if (ch == '\0')
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	75 0d                	jne    800508 <vprintfmt+0x33>
  8004fb:	e9 9d 04 00 00       	jmp    80099d <vprintfmt+0x4c8>
  800500:	85 c0                	test   %eax,%eax
  800502:	0f 84 95 04 00 00    	je     80099d <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	50                   	push   %eax
  80050d:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050f:	83 c6 01             	add    $0x1,%esi
  800512:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	83 f8 25             	cmp    $0x25,%eax
  80051c:	75 e2                	jne    800500 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80051e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800523:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800527:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80052e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800535:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80053c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800543:	eb 08                	jmp    80054d <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800548:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8d 46 01             	lea    0x1(%esi),%eax
  800550:	89 45 10             	mov    %eax,0x10(%ebp)
  800553:	0f b6 06             	movzbl (%esi),%eax
  800556:	0f b6 d0             	movzbl %al,%edx
  800559:	83 e8 23             	sub    $0x23,%eax
  80055c:	3c 55                	cmp    $0x55,%al
  80055e:	0f 87 fa 03 00 00    	ja     80095e <vprintfmt+0x489>
  800564:	0f b6 c0             	movzbl %al,%eax
  800567:	ff 24 85 60 16 80 00 	jmp    *0x801660(,%eax,4)
  80056e:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800571:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800575:	eb d6                	jmp    80054d <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800577:	8d 42 d0             	lea    -0x30(%edx),%eax
  80057a:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80057d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800581:	8d 50 d0             	lea    -0x30(%eax),%edx
  800584:	83 fa 09             	cmp    $0x9,%edx
  800587:	77 6b                	ja     8005f4 <vprintfmt+0x11f>
  800589:	8b 75 10             	mov    0x10(%ebp),%esi
  80058c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800592:	eb 09                	jmp    80059d <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800597:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80059b:	eb b0                	jmp    80054d <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80059d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005a0:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005a3:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005a7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005aa:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005ad:	83 f9 09             	cmp    $0x9,%ecx
  8005b0:	76 eb                	jbe    80059d <vprintfmt+0xc8>
  8005b2:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005b5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005b8:	eb 3d                	jmp    8005f7 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005cb:	eb 2a                	jmp    8005f7 <vprintfmt+0x122>
  8005cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d7:	0f 49 d0             	cmovns %eax,%edx
  8005da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 75 10             	mov    0x10(%ebp),%esi
  8005e0:	e9 68 ff ff ff       	jmp    80054d <vprintfmt+0x78>
  8005e5:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ef:	e9 59 ff ff ff       	jmp    80054d <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fb:	0f 89 4c ff ff ff    	jns    80054d <vprintfmt+0x78>
				width = precision, precision = -1;
  800601:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800607:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80060e:	e9 3a ff ff ff       	jmp    80054d <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800613:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061a:	e9 2e ff ff ff       	jmp    80054d <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	ff 30                	pushl  (%eax)
  80062e:	ff d7                	call   *%edi
			break;
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	e9 b1 fe ff ff       	jmp    8004e9 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 00                	mov    (%eax),%eax
  800643:	99                   	cltd   
  800644:	31 d0                	xor    %edx,%eax
  800646:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800648:	83 f8 08             	cmp    $0x8,%eax
  80064b:	7f 0b                	jg     800658 <vprintfmt+0x183>
  80064d:	8b 14 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%edx
  800654:	85 d2                	test   %edx,%edx
  800656:	75 15                	jne    80066d <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800658:	50                   	push   %eax
  800659:	68 3e 15 80 00       	push   $0x80153e
  80065e:	53                   	push   %ebx
  80065f:	57                   	push   %edi
  800660:	e8 53 fe ff ff       	call   8004b8 <printfmt>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	e9 7c fe ff ff       	jmp    8004e9 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80066d:	52                   	push   %edx
  80066e:	68 47 15 80 00       	push   $0x801547
  800673:	53                   	push   %ebx
  800674:	57                   	push   %edi
  800675:	e8 3e fe ff ff       	call   8004b8 <printfmt>
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	e9 67 fe ff ff       	jmp    8004e9 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80068d:	85 c0                	test   %eax,%eax
  80068f:	b9 37 15 80 00       	mov    $0x801537,%ecx
  800694:	0f 45 c8             	cmovne %eax,%ecx
  800697:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80069a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069e:	7e 06                	jle    8006a6 <vprintfmt+0x1d1>
  8006a0:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006a4:	75 19                	jne    8006bf <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a9:	8d 70 01             	lea    0x1(%eax),%esi
  8006ac:	0f b6 00             	movzbl (%eax),%eax
  8006af:	0f be d0             	movsbl %al,%edx
  8006b2:	85 d2                	test   %edx,%edx
  8006b4:	0f 85 9f 00 00 00    	jne    800759 <vprintfmt+0x284>
  8006ba:	e9 8c 00 00 00       	jmp    80074b <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c5:	ff 75 cc             	pushl  -0x34(%ebp)
  8006c8:	e8 62 03 00 00       	call   800a2f <strnlen>
  8006cd:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	85 c9                	test   %ecx,%ecx
  8006d8:	0f 8e a6 02 00 00    	jle    800984 <vprintfmt+0x4af>
					putch(padc, putdat);
  8006de:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e5:	89 cb                	mov    %ecx,%ebx
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	56                   	push   %esi
  8006ee:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	83 eb 01             	sub    $0x1,%ebx
  8006f6:	75 ef                	jne    8006e7 <vprintfmt+0x212>
  8006f8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fe:	e9 81 02 00 00       	jmp    800984 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800703:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800707:	74 1b                	je     800724 <vprintfmt+0x24f>
  800709:	0f be c0             	movsbl %al,%eax
  80070c:	83 e8 20             	sub    $0x20,%eax
  80070f:	83 f8 5e             	cmp    $0x5e,%eax
  800712:	76 10                	jbe    800724 <vprintfmt+0x24f>
					putch('?', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	ff 75 0c             	pushl  0xc(%ebp)
  80071a:	6a 3f                	push   $0x3f
  80071c:	ff 55 08             	call   *0x8(%ebp)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	eb 0d                	jmp    800731 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	52                   	push   %edx
  80072b:	ff 55 08             	call   *0x8(%ebp)
  80072e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800731:	83 ef 01             	sub    $0x1,%edi
  800734:	83 c6 01             	add    $0x1,%esi
  800737:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80073b:	0f be d0             	movsbl %al,%edx
  80073e:	85 d2                	test   %edx,%edx
  800740:	75 31                	jne    800773 <vprintfmt+0x29e>
  800742:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800745:	8b 7d 08             	mov    0x8(%ebp),%edi
  800748:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800752:	7f 33                	jg     800787 <vprintfmt+0x2b2>
  800754:	e9 90 fd ff ff       	jmp    8004e9 <vprintfmt+0x14>
  800759:	89 7d 08             	mov    %edi,0x8(%ebp)
  80075c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800765:	eb 0c                	jmp    800773 <vprintfmt+0x29e>
  800767:	89 7d 08             	mov    %edi,0x8(%ebp)
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800773:	85 db                	test   %ebx,%ebx
  800775:	78 8c                	js     800703 <vprintfmt+0x22e>
  800777:	83 eb 01             	sub    $0x1,%ebx
  80077a:	79 87                	jns    800703 <vprintfmt+0x22e>
  80077c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80077f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800785:	eb c4                	jmp    80074b <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	6a 20                	push   $0x20
  80078d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078f:	83 c4 10             	add    $0x10,%esp
  800792:	83 ee 01             	sub    $0x1,%esi
  800795:	75 f0                	jne    800787 <vprintfmt+0x2b2>
  800797:	e9 4d fd ff ff       	jmp    8004e9 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079c:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8007a0:	7e 16                	jle    8007b8 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8d 50 08             	lea    0x8(%eax),%edx
  8007a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ab:	8b 50 04             	mov    0x4(%eax),%edx
  8007ae:	8b 00                	mov    (%eax),%eax
  8007b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007b3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007b6:	eb 34                	jmp    8007ec <vprintfmt+0x317>
	else if (lflag)
  8007b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007bc:	74 18                	je     8007d6 <vprintfmt+0x301>
		return va_arg(*ap, long);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8d 50 04             	lea    0x4(%eax),%edx
  8007c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c7:	8b 30                	mov    (%eax),%esi
  8007c9:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007cc:	89 f0                	mov    %esi,%eax
  8007ce:	c1 f8 1f             	sar    $0x1f,%eax
  8007d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007d4:	eb 16                	jmp    8007ec <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8d 50 04             	lea    0x4(%eax),%edx
  8007dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007df:	8b 30                	mov    (%eax),%esi
  8007e1:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007e4:	89 f0                	mov    %esi,%eax
  8007e6:	c1 f8 1f             	sar    $0x1f,%eax
  8007e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	79 28                	jns    800824 <vprintfmt+0x34f>
				putch('-', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	53                   	push   %ebx
  800800:	6a 2d                	push   $0x2d
  800802:	ff d7                	call   *%edi
				num = -(long long) num;
  800804:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800807:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80080a:	f7 d8                	neg    %eax
  80080c:	83 d2 00             	adc    $0x0,%edx
  80080f:	f7 da                	neg    %edx
  800811:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800814:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800817:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  80081a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081f:	e9 b2 00 00 00       	jmp    8008d6 <vprintfmt+0x401>
  800824:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800829:	85 c9                	test   %ecx,%ecx
  80082b:	0f 84 a5 00 00 00    	je     8008d6 <vprintfmt+0x401>
				putch('+', putdat);
  800831:	83 ec 08             	sub    $0x8,%esp
  800834:	53                   	push   %ebx
  800835:	6a 2b                	push   $0x2b
  800837:	ff d7                	call   *%edi
  800839:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 90 00 00 00       	jmp    8008d6 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800846:	85 c9                	test   %ecx,%ecx
  800848:	74 0b                	je     800855 <vprintfmt+0x380>
				putch('+', putdat);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	53                   	push   %ebx
  80084e:	6a 2b                	push   $0x2b
  800850:	ff d7                	call   *%edi
  800852:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800855:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800858:	8d 45 14             	lea    0x14(%ebp),%eax
  80085b:	e8 01 fc ff ff       	call   800461 <getuint>
  800860:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800863:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800866:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80086b:	eb 69                	jmp    8008d6 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	53                   	push   %ebx
  800871:	6a 30                	push   $0x30
  800873:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800875:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800878:	8d 45 14             	lea    0x14(%ebp),%eax
  80087b:	e8 e1 fb ff ff       	call   800461 <getuint>
  800880:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800883:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800886:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800889:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80088e:	eb 46                	jmp    8008d6 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	53                   	push   %ebx
  800894:	6a 30                	push   $0x30
  800896:	ff d7                	call   *%edi
			putch('x', putdat);
  800898:	83 c4 08             	add    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	6a 78                	push   $0x78
  80089e:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a3:	8d 50 04             	lea    0x4(%eax),%edx
  8008a6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008a9:	8b 00                	mov    (%eax),%eax
  8008ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008be:	eb 16                	jmp    8008d6 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c6:	e8 96 fb ff ff       	call   800461 <getuint>
  8008cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008d1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d6:	83 ec 0c             	sub    $0xc,%esp
  8008d9:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008dd:	56                   	push   %esi
  8008de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008e1:	50                   	push   %eax
  8008e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8008e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8008e8:	89 da                	mov    %ebx,%edx
  8008ea:	89 f8                	mov    %edi,%eax
  8008ec:	e8 55 f9 ff ff       	call   800246 <printnum>
			break;
  8008f1:	83 c4 20             	add    $0x20,%esp
  8008f4:	e9 f0 fb ff ff       	jmp    8004e9 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8d 50 04             	lea    0x4(%eax),%edx
  8008ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800902:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800904:	85 f6                	test   %esi,%esi
  800906:	75 1a                	jne    800922 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	68 e0 15 80 00       	push   $0x8015e0
  800910:	68 47 15 80 00       	push   $0x801547
  800915:	e8 18 f9 ff ff       	call   800232 <cprintf>
  80091a:	83 c4 10             	add    $0x10,%esp
  80091d:	e9 c7 fb ff ff       	jmp    8004e9 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800922:	0f b6 03             	movzbl (%ebx),%eax
  800925:	84 c0                	test   %al,%al
  800927:	79 1f                	jns    800948 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800929:	83 ec 08             	sub    $0x8,%esp
  80092c:	68 18 16 80 00       	push   $0x801618
  800931:	68 47 15 80 00       	push   $0x801547
  800936:	e8 f7 f8 ff ff       	call   800232 <cprintf>
						*tmp = *(char *)putdat;
  80093b:	0f b6 03             	movzbl (%ebx),%eax
  80093e:	88 06                	mov    %al,(%esi)
  800940:	83 c4 10             	add    $0x10,%esp
  800943:	e9 a1 fb ff ff       	jmp    8004e9 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800948:	88 06                	mov    %al,(%esi)
  80094a:	e9 9a fb ff ff       	jmp    8004e9 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094f:	83 ec 08             	sub    $0x8,%esp
  800952:	53                   	push   %ebx
  800953:	52                   	push   %edx
  800954:	ff d7                	call   *%edi
			break;
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	e9 8b fb ff ff       	jmp    8004e9 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095e:	83 ec 08             	sub    $0x8,%esp
  800961:	53                   	push   %ebx
  800962:	6a 25                	push   $0x25
  800964:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800966:	83 c4 10             	add    $0x10,%esp
  800969:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80096d:	0f 84 73 fb ff ff    	je     8004e6 <vprintfmt+0x11>
  800973:	83 ee 01             	sub    $0x1,%esi
  800976:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80097a:	75 f7                	jne    800973 <vprintfmt+0x49e>
  80097c:	89 75 10             	mov    %esi,0x10(%ebp)
  80097f:	e9 65 fb ff ff       	jmp    8004e9 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800984:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800987:	8d 70 01             	lea    0x1(%eax),%esi
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f be d0             	movsbl %al,%edx
  800990:	85 d2                	test   %edx,%edx
  800992:	0f 85 cf fd ff ff    	jne    800767 <vprintfmt+0x292>
  800998:	e9 4c fb ff ff       	jmp    8004e9 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80099d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	83 ec 18             	sub    $0x18,%esp
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009b4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009b8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009c2:	85 c0                	test   %eax,%eax
  8009c4:	74 26                	je     8009ec <vsnprintf+0x47>
  8009c6:	85 d2                	test   %edx,%edx
  8009c8:	7e 22                	jle    8009ec <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ca:	ff 75 14             	pushl  0x14(%ebp)
  8009cd:	ff 75 10             	pushl  0x10(%ebp)
  8009d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d3:	50                   	push   %eax
  8009d4:	68 9b 04 80 00       	push   $0x80049b
  8009d9:	e8 f7 fa ff ff       	call   8004d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009de:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	eb 05                	jmp    8009f1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009f9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009fc:	50                   	push   %eax
  8009fd:	ff 75 10             	pushl  0x10(%ebp)
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	ff 75 08             	pushl  0x8(%ebp)
  800a06:	e8 9a ff ff ff       	call   8009a5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a13:	80 3a 00             	cmpb   $0x0,(%edx)
  800a16:	74 10                	je     800a28 <strlen+0x1b>
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a24:	75 f7                	jne    800a1d <strlen+0x10>
  800a26:	eb 05                	jmp    800a2d <strlen+0x20>
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a39:	85 c9                	test   %ecx,%ecx
  800a3b:	74 1c                	je     800a59 <strnlen+0x2a>
  800a3d:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a40:	74 1e                	je     800a60 <strnlen+0x31>
  800a42:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a47:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a49:	39 ca                	cmp    %ecx,%edx
  800a4b:	74 18                	je     800a65 <strnlen+0x36>
  800a4d:	83 c2 01             	add    $0x1,%edx
  800a50:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a55:	75 f0                	jne    800a47 <strnlen+0x18>
  800a57:	eb 0c                	jmp    800a65 <strnlen+0x36>
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5e:	eb 05                	jmp    800a65 <strnlen+0x36>
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a65:	5b                   	pop    %ebx
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	83 c2 01             	add    $0x1,%edx
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a7e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a81:	84 db                	test   %bl,%bl
  800a83:	75 ef                	jne    800a74 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a85:	5b                   	pop    %ebx
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	53                   	push   %ebx
  800a8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8f:	53                   	push   %ebx
  800a90:	e8 78 ff ff ff       	call   800a0d <strlen>
  800a95:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a98:	ff 75 0c             	pushl  0xc(%ebp)
  800a9b:	01 d8                	add    %ebx,%eax
  800a9d:	50                   	push   %eax
  800a9e:	e8 c5 ff ff ff       	call   800a68 <strcpy>
	return dst;
}
  800aa3:	89 d8                	mov    %ebx,%eax
  800aa5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    

00800aaa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	74 17                	je     800ad3 <strncpy+0x29>
  800abc:	01 f3                	add    %esi,%ebx
  800abe:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	0f b6 02             	movzbl (%edx),%eax
  800ac6:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac9:	80 3a 01             	cmpb   $0x1,(%edx)
  800acc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acf:	39 cb                	cmp    %ecx,%ebx
  800ad1:	75 ed                	jne    800ac0 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad3:	89 f0                	mov    %esi,%eax
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae4:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae9:	85 d2                	test   %edx,%edx
  800aeb:	74 35                	je     800b22 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800aed:	89 d0                	mov    %edx,%eax
  800aef:	83 e8 01             	sub    $0x1,%eax
  800af2:	74 25                	je     800b19 <strlcpy+0x40>
  800af4:	0f b6 0b             	movzbl (%ebx),%ecx
  800af7:	84 c9                	test   %cl,%cl
  800af9:	74 22                	je     800b1d <strlcpy+0x44>
  800afb:	8d 53 01             	lea    0x1(%ebx),%edx
  800afe:	01 c3                	add    %eax,%ebx
  800b00:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b08:	39 da                	cmp    %ebx,%edx
  800b0a:	74 13                	je     800b1f <strlcpy+0x46>
  800b0c:	83 c2 01             	add    $0x1,%edx
  800b0f:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800b13:	84 c9                	test   %cl,%cl
  800b15:	75 eb                	jne    800b02 <strlcpy+0x29>
  800b17:	eb 06                	jmp    800b1f <strlcpy+0x46>
  800b19:	89 f0                	mov    %esi,%eax
  800b1b:	eb 02                	jmp    800b1f <strlcpy+0x46>
  800b1d:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b1f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b22:	29 f0                	sub    %esi,%eax
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b31:	0f b6 01             	movzbl (%ecx),%eax
  800b34:	84 c0                	test   %al,%al
  800b36:	74 15                	je     800b4d <strcmp+0x25>
  800b38:	3a 02                	cmp    (%edx),%al
  800b3a:	75 11                	jne    800b4d <strcmp+0x25>
		p++, q++;
  800b3c:	83 c1 01             	add    $0x1,%ecx
  800b3f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b42:	0f b6 01             	movzbl (%ecx),%eax
  800b45:	84 c0                	test   %al,%al
  800b47:	74 04                	je     800b4d <strcmp+0x25>
  800b49:	3a 02                	cmp    (%edx),%al
  800b4b:	74 ef                	je     800b3c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4d:	0f b6 c0             	movzbl %al,%eax
  800b50:	0f b6 12             	movzbl (%edx),%edx
  800b53:	29 d0                	sub    %edx,%eax
}
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b62:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b65:	85 f6                	test   %esi,%esi
  800b67:	74 29                	je     800b92 <strncmp+0x3b>
  800b69:	0f b6 03             	movzbl (%ebx),%eax
  800b6c:	84 c0                	test   %al,%al
  800b6e:	74 30                	je     800ba0 <strncmp+0x49>
  800b70:	3a 02                	cmp    (%edx),%al
  800b72:	75 2c                	jne    800ba0 <strncmp+0x49>
  800b74:	8d 43 01             	lea    0x1(%ebx),%eax
  800b77:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b79:	89 c3                	mov    %eax,%ebx
  800b7b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b7e:	39 c6                	cmp    %eax,%esi
  800b80:	74 17                	je     800b99 <strncmp+0x42>
  800b82:	0f b6 08             	movzbl (%eax),%ecx
  800b85:	84 c9                	test   %cl,%cl
  800b87:	74 17                	je     800ba0 <strncmp+0x49>
  800b89:	83 c0 01             	add    $0x1,%eax
  800b8c:	3a 0a                	cmp    (%edx),%cl
  800b8e:	74 e9                	je     800b79 <strncmp+0x22>
  800b90:	eb 0e                	jmp    800ba0 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	eb 0f                	jmp    800ba8 <strncmp+0x51>
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9e:	eb 08                	jmp    800ba8 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba0:	0f b6 03             	movzbl (%ebx),%eax
  800ba3:	0f b6 12             	movzbl (%edx),%edx
  800ba6:	29 d0                	sub    %edx,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	53                   	push   %ebx
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800bb6:	0f b6 10             	movzbl (%eax),%edx
  800bb9:	84 d2                	test   %dl,%dl
  800bbb:	74 1d                	je     800bda <strchr+0x2e>
  800bbd:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800bbf:	38 d3                	cmp    %dl,%bl
  800bc1:	75 06                	jne    800bc9 <strchr+0x1d>
  800bc3:	eb 1a                	jmp    800bdf <strchr+0x33>
  800bc5:	38 ca                	cmp    %cl,%dl
  800bc7:	74 16                	je     800bdf <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bc9:	83 c0 01             	add    $0x1,%eax
  800bcc:	0f b6 10             	movzbl (%eax),%edx
  800bcf:	84 d2                	test   %dl,%dl
  800bd1:	75 f2                	jne    800bc5 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd8:	eb 05                	jmp    800bdf <strchr+0x33>
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	53                   	push   %ebx
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
  800be9:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bec:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bef:	38 d3                	cmp    %dl,%bl
  800bf1:	74 14                	je     800c07 <strfind+0x25>
  800bf3:	89 d1                	mov    %edx,%ecx
  800bf5:	84 db                	test   %bl,%bl
  800bf7:	74 0e                	je     800c07 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bf9:	83 c0 01             	add    $0x1,%eax
  800bfc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bff:	38 ca                	cmp    %cl,%dl
  800c01:	74 04                	je     800c07 <strfind+0x25>
  800c03:	84 d2                	test   %dl,%dl
  800c05:	75 f2                	jne    800bf9 <strfind+0x17>
			break;
	return (char *) s;
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c16:	85 c9                	test   %ecx,%ecx
  800c18:	74 36                	je     800c50 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c1a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c20:	75 28                	jne    800c4a <memset+0x40>
  800c22:	f6 c1 03             	test   $0x3,%cl
  800c25:	75 23                	jne    800c4a <memset+0x40>
		c &= 0xFF;
  800c27:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c2b:	89 d3                	mov    %edx,%ebx
  800c2d:	c1 e3 08             	shl    $0x8,%ebx
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	c1 e6 18             	shl    $0x18,%esi
  800c35:	89 d0                	mov    %edx,%eax
  800c37:	c1 e0 10             	shl    $0x10,%eax
  800c3a:	09 f0                	or     %esi,%eax
  800c3c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c3e:	89 d8                	mov    %ebx,%eax
  800c40:	09 d0                	or     %edx,%eax
  800c42:	c1 e9 02             	shr    $0x2,%ecx
  800c45:	fc                   	cld    
  800c46:	f3 ab                	rep stos %eax,%es:(%edi)
  800c48:	eb 06                	jmp    800c50 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4d:	fc                   	cld    
  800c4e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c50:	89 f8                	mov    %edi,%eax
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c65:	39 c6                	cmp    %eax,%esi
  800c67:	73 35                	jae    800c9e <memmove+0x47>
  800c69:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c6c:	39 d0                	cmp    %edx,%eax
  800c6e:	73 2e                	jae    800c9e <memmove+0x47>
		s += n;
		d += n;
  800c70:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c73:	89 d6                	mov    %edx,%esi
  800c75:	09 fe                	or     %edi,%esi
  800c77:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c7d:	75 13                	jne    800c92 <memmove+0x3b>
  800c7f:	f6 c1 03             	test   $0x3,%cl
  800c82:	75 0e                	jne    800c92 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c84:	83 ef 04             	sub    $0x4,%edi
  800c87:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c8a:	c1 e9 02             	shr    $0x2,%ecx
  800c8d:	fd                   	std    
  800c8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c90:	eb 09                	jmp    800c9b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c92:	83 ef 01             	sub    $0x1,%edi
  800c95:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c98:	fd                   	std    
  800c99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c9b:	fc                   	cld    
  800c9c:	eb 1d                	jmp    800cbb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c9e:	89 f2                	mov    %esi,%edx
  800ca0:	09 c2                	or     %eax,%edx
  800ca2:	f6 c2 03             	test   $0x3,%dl
  800ca5:	75 0f                	jne    800cb6 <memmove+0x5f>
  800ca7:	f6 c1 03             	test   $0x3,%cl
  800caa:	75 0a                	jne    800cb6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cac:	c1 e9 02             	shr    $0x2,%ecx
  800caf:	89 c7                	mov    %eax,%edi
  800cb1:	fc                   	cld    
  800cb2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cb4:	eb 05                	jmp    800cbb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	fc                   	cld    
  800cb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cc2:	ff 75 10             	pushl  0x10(%ebp)
  800cc5:	ff 75 0c             	pushl  0xc(%ebp)
  800cc8:	ff 75 08             	pushl  0x8(%ebp)
  800ccb:	e8 87 ff ff ff       	call   800c57 <memmove>
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    

00800cd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cde:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	74 39                	je     800d1e <memcmp+0x4c>
  800ce5:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ce8:	0f b6 13             	movzbl (%ebx),%edx
  800ceb:	0f b6 0e             	movzbl (%esi),%ecx
  800cee:	38 ca                	cmp    %cl,%dl
  800cf0:	75 17                	jne    800d09 <memcmp+0x37>
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf7:	eb 1a                	jmp    800d13 <memcmp+0x41>
  800cf9:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800cfe:	83 c0 01             	add    $0x1,%eax
  800d01:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800d05:	38 ca                	cmp    %cl,%dl
  800d07:	74 0a                	je     800d13 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d09:	0f b6 c2             	movzbl %dl,%eax
  800d0c:	0f b6 c9             	movzbl %cl,%ecx
  800d0f:	29 c8                	sub    %ecx,%eax
  800d11:	eb 10                	jmp    800d23 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d13:	39 f8                	cmp    %edi,%eax
  800d15:	75 e2                	jne    800cf9 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d17:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1c:	eb 05                	jmp    800d23 <memcmp+0x51>
  800d1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	53                   	push   %ebx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d2f:	89 d0                	mov    %edx,%eax
  800d31:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d34:	39 c2                	cmp    %eax,%edx
  800d36:	73 1d                	jae    800d55 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d38:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d3c:	0f b6 0a             	movzbl (%edx),%ecx
  800d3f:	39 d9                	cmp    %ebx,%ecx
  800d41:	75 09                	jne    800d4c <memfind+0x24>
  800d43:	eb 14                	jmp    800d59 <memfind+0x31>
  800d45:	0f b6 0a             	movzbl (%edx),%ecx
  800d48:	39 d9                	cmp    %ebx,%ecx
  800d4a:	74 11                	je     800d5d <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d4c:	83 c2 01             	add    $0x1,%edx
  800d4f:	39 d0                	cmp    %edx,%eax
  800d51:	75 f2                	jne    800d45 <memfind+0x1d>
  800d53:	eb 0a                	jmp    800d5f <memfind+0x37>
  800d55:	89 d0                	mov    %edx,%eax
  800d57:	eb 06                	jmp    800d5f <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	eb 02                	jmp    800d5f <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5d:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6e:	0f b6 01             	movzbl (%ecx),%eax
  800d71:	3c 20                	cmp    $0x20,%al
  800d73:	74 04                	je     800d79 <strtol+0x17>
  800d75:	3c 09                	cmp    $0x9,%al
  800d77:	75 0e                	jne    800d87 <strtol+0x25>
		s++;
  800d79:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7c:	0f b6 01             	movzbl (%ecx),%eax
  800d7f:	3c 20                	cmp    $0x20,%al
  800d81:	74 f6                	je     800d79 <strtol+0x17>
  800d83:	3c 09                	cmp    $0x9,%al
  800d85:	74 f2                	je     800d79 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d87:	3c 2b                	cmp    $0x2b,%al
  800d89:	75 0a                	jne    800d95 <strtol+0x33>
		s++;
  800d8b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d93:	eb 11                	jmp    800da6 <strtol+0x44>
  800d95:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d9a:	3c 2d                	cmp    $0x2d,%al
  800d9c:	75 08                	jne    800da6 <strtol+0x44>
		s++, neg = 1;
  800d9e:	83 c1 01             	add    $0x1,%ecx
  800da1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dac:	75 15                	jne    800dc3 <strtol+0x61>
  800dae:	80 39 30             	cmpb   $0x30,(%ecx)
  800db1:	75 10                	jne    800dc3 <strtol+0x61>
  800db3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800db7:	75 7c                	jne    800e35 <strtol+0xd3>
		s += 2, base = 16;
  800db9:	83 c1 02             	add    $0x2,%ecx
  800dbc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dc1:	eb 16                	jmp    800dd9 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800dc3:	85 db                	test   %ebx,%ebx
  800dc5:	75 12                	jne    800dd9 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dc7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dcc:	80 39 30             	cmpb   $0x30,(%ecx)
  800dcf:	75 08                	jne    800dd9 <strtol+0x77>
		s++, base = 8;
  800dd1:	83 c1 01             	add    $0x1,%ecx
  800dd4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dde:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de1:	0f b6 11             	movzbl (%ecx),%edx
  800de4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800de7:	89 f3                	mov    %esi,%ebx
  800de9:	80 fb 09             	cmp    $0x9,%bl
  800dec:	77 08                	ja     800df6 <strtol+0x94>
			dig = *s - '0';
  800dee:	0f be d2             	movsbl %dl,%edx
  800df1:	83 ea 30             	sub    $0x30,%edx
  800df4:	eb 22                	jmp    800e18 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800df6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800df9:	89 f3                	mov    %esi,%ebx
  800dfb:	80 fb 19             	cmp    $0x19,%bl
  800dfe:	77 08                	ja     800e08 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800e00:	0f be d2             	movsbl %dl,%edx
  800e03:	83 ea 57             	sub    $0x57,%edx
  800e06:	eb 10                	jmp    800e18 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800e08:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e0b:	89 f3                	mov    %esi,%ebx
  800e0d:	80 fb 19             	cmp    $0x19,%bl
  800e10:	77 16                	ja     800e28 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800e12:	0f be d2             	movsbl %dl,%edx
  800e15:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e18:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e1b:	7d 0b                	jge    800e28 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e1d:	83 c1 01             	add    $0x1,%ecx
  800e20:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e24:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e26:	eb b9                	jmp    800de1 <strtol+0x7f>

	if (endptr)
  800e28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e2c:	74 0d                	je     800e3b <strtol+0xd9>
		*endptr = (char *) s;
  800e2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e31:	89 0e                	mov    %ecx,(%esi)
  800e33:	eb 06                	jmp    800e3b <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e35:	85 db                	test   %ebx,%ebx
  800e37:	74 98                	je     800dd1 <strtol+0x6f>
  800e39:	eb 9e                	jmp    800dd9 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e3b:	89 c2                	mov    %eax,%edx
  800e3d:	f7 da                	neg    %edx
  800e3f:	85 ff                	test   %edi,%edi
  800e41:	0f 45 c2             	cmovne %edx,%eax
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 c3                	mov    %eax,%ebx
  800e5b:	89 c7                	mov    %eax,%edi
  800e5d:	51                   	push   %ecx
  800e5e:	52                   	push   %edx
  800e5f:	53                   	push   %ebx
  800e60:	56                   	push   %esi
  800e61:	57                   	push   %edi
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	8d 35 6d 0e 80 00    	lea    0x800e6d,%esi
  800e6b:	0f 34                	sysenter 

00800e6d <label_21>:
  800e6d:	89 ec                	mov    %ebp,%esp
  800e6f:	5d                   	pop    %ebp
  800e70:	5f                   	pop    %edi
  800e71:	5e                   	pop    %esi
  800e72:	5b                   	pop    %ebx
  800e73:	5a                   	pop    %edx
  800e74:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e75:	5b                   	pop    %ebx
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e83:	b8 01 00 00 00       	mov    $0x1,%eax
  800e88:	89 ca                	mov    %ecx,%edx
  800e8a:	89 cb                	mov    %ecx,%ebx
  800e8c:	89 cf                	mov    %ecx,%edi
  800e8e:	51                   	push   %ecx
  800e8f:	52                   	push   %edx
  800e90:	53                   	push   %ebx
  800e91:	56                   	push   %esi
  800e92:	57                   	push   %edi
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	8d 35 9e 0e 80 00    	lea    0x800e9e,%esi
  800e9c:	0f 34                	sysenter 

00800e9e <label_55>:
  800e9e:	89 ec                	mov    %ebp,%esp
  800ea0:	5d                   	pop    %ebp
  800ea1:	5f                   	pop    %edi
  800ea2:	5e                   	pop    %esi
  800ea3:	5b                   	pop    %ebx
  800ea4:	5a                   	pop    %edx
  800ea5:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ea6:	5b                   	pop    %ebx
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eaf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb4:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 d9                	mov    %ebx,%ecx
  800ebe:	89 df                	mov    %ebx,%edi
  800ec0:	51                   	push   %ecx
  800ec1:	52                   	push   %edx
  800ec2:	53                   	push   %ebx
  800ec3:	56                   	push   %esi
  800ec4:	57                   	push   %edi
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	8d 35 d0 0e 80 00    	lea    0x800ed0,%esi
  800ece:	0f 34                	sysenter 

00800ed0 <label_90>:
  800ed0:	89 ec                	mov    %ebp,%esp
  800ed2:	5d                   	pop    %ebp
  800ed3:	5f                   	pop    %edi
  800ed4:	5e                   	pop    %esi
  800ed5:	5b                   	pop    %ebx
  800ed6:	5a                   	pop    %edx
  800ed7:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 17                	jle    800ef3 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	50                   	push   %eax
  800ee0:	6a 03                	push   $0x3
  800ee2:	68 e4 17 80 00       	push   $0x8017e4
  800ee7:	6a 29                	push   $0x29
  800ee9:	68 01 18 80 00       	push   $0x801801
  800eee:	e8 06 03 00 00       	call   8011f9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ef3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	57                   	push   %edi
  800efe:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f04:	b8 02 00 00 00       	mov    $0x2,%eax
  800f09:	89 ca                	mov    %ecx,%edx
  800f0b:	89 cb                	mov    %ecx,%ebx
  800f0d:	89 cf                	mov    %ecx,%edi
  800f0f:	51                   	push   %ecx
  800f10:	52                   	push   %edx
  800f11:	53                   	push   %ebx
  800f12:	56                   	push   %esi
  800f13:	57                   	push   %edi
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	8d 35 1f 0f 80 00    	lea    0x800f1f,%esi
  800f1d:	0f 34                	sysenter 

00800f1f <label_139>:
  800f1f:	89 ec                	mov    %ebp,%esp
  800f21:	5d                   	pop    %ebp
  800f22:	5f                   	pop    %edi
  800f23:	5e                   	pop    %esi
  800f24:	5b                   	pop    %ebx
  800f25:	5a                   	pop    %edx
  800f26:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f27:	5b                   	pop    %ebx
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f30:	bf 00 00 00 00       	mov    $0x0,%edi
  800f35:	b8 04 00 00 00       	mov    $0x4,%eax
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 fb                	mov    %edi,%ebx
  800f42:	51                   	push   %ecx
  800f43:	52                   	push   %edx
  800f44:	53                   	push   %ebx
  800f45:	56                   	push   %esi
  800f46:	57                   	push   %edi
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	8d 35 52 0f 80 00    	lea    0x800f52,%esi
  800f50:	0f 34                	sysenter 

00800f52 <label_174>:
  800f52:	89 ec                	mov    %ebp,%esp
  800f54:	5d                   	pop    %ebp
  800f55:	5f                   	pop    %edi
  800f56:	5e                   	pop    %esi
  800f57:	5b                   	pop    %ebx
  800f58:	5a                   	pop    %edx
  800f59:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f5a:	5b                   	pop    %ebx
  800f5b:	5f                   	pop    %edi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <sys_yield>:

void
sys_yield(void)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	57                   	push   %edi
  800f62:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f63:	ba 00 00 00 00       	mov    $0x0,%edx
  800f68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f6d:	89 d1                	mov    %edx,%ecx
  800f6f:	89 d3                	mov    %edx,%ebx
  800f71:	89 d7                	mov    %edx,%edi
  800f73:	51                   	push   %ecx
  800f74:	52                   	push   %edx
  800f75:	53                   	push   %ebx
  800f76:	56                   	push   %esi
  800f77:	57                   	push   %edi
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	8d 35 83 0f 80 00    	lea    0x800f83,%esi
  800f81:	0f 34                	sysenter 

00800f83 <label_209>:
  800f83:	89 ec                	mov    %ebp,%esp
  800f85:	5d                   	pop    %ebp
  800f86:	5f                   	pop    %edi
  800f87:	5e                   	pop    %esi
  800f88:	5b                   	pop    %ebx
  800f89:	5a                   	pop    %edx
  800f8a:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f8b:	5b                   	pop    %ebx
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	57                   	push   %edi
  800f93:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f94:	bf 00 00 00 00       	mov    $0x0,%edi
  800f99:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa7:	51                   	push   %ecx
  800fa8:	52                   	push   %edx
  800fa9:	53                   	push   %ebx
  800faa:	56                   	push   %esi
  800fab:	57                   	push   %edi
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	8d 35 b7 0f 80 00    	lea    0x800fb7,%esi
  800fb5:	0f 34                	sysenter 

00800fb7 <label_244>:
  800fb7:	89 ec                	mov    %ebp,%esp
  800fb9:	5d                   	pop    %ebp
  800fba:	5f                   	pop    %edi
  800fbb:	5e                   	pop    %esi
  800fbc:	5b                   	pop    %ebx
  800fbd:	5a                   	pop    %edx
  800fbe:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	7e 17                	jle    800fda <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	50                   	push   %eax
  800fc7:	6a 05                	push   $0x5
  800fc9:	68 e4 17 80 00       	push   $0x8017e4
  800fce:	6a 29                	push   $0x29
  800fd0:	68 01 18 80 00       	push   $0x801801
  800fd5:	e8 1f 02 00 00       	call   8011f9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5f                   	pop    %edi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	57                   	push   %edi
  800fe5:	53                   	push   %ebx
  800fe6:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800fef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff2:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800ff5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800ffb:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffe:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  801001:	8b 45 18             	mov    0x18(%ebp),%eax
  801004:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801007:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80100a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100f:	b8 06 00 00 00       	mov    $0x6,%eax
  801014:	89 cb                	mov    %ecx,%ebx
  801016:	89 cf                	mov    %ecx,%edi
  801018:	51                   	push   %ecx
  801019:	52                   	push   %edx
  80101a:	53                   	push   %ebx
  80101b:	56                   	push   %esi
  80101c:	57                   	push   %edi
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	8d 35 28 10 80 00    	lea    0x801028,%esi
  801026:	0f 34                	sysenter 

00801028 <label_304>:
  801028:	89 ec                	mov    %ebp,%esp
  80102a:	5d                   	pop    %ebp
  80102b:	5f                   	pop    %edi
  80102c:	5e                   	pop    %esi
  80102d:	5b                   	pop    %ebx
  80102e:	5a                   	pop    %edx
  80102f:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801030:	85 c0                	test   %eax,%eax
  801032:	7e 17                	jle    80104b <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	50                   	push   %eax
  801038:	6a 06                	push   $0x6
  80103a:	68 e4 17 80 00       	push   $0x8017e4
  80103f:	6a 29                	push   $0x29
  801041:	68 01 18 80 00       	push   $0x801801
  801046:	e8 ae 01 00 00       	call   8011f9 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  80104b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801057:	bf 00 00 00 00       	mov    $0x0,%edi
  80105c:	b8 07 00 00 00       	mov    $0x7,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 fb                	mov    %edi,%ebx
  801069:	51                   	push   %ecx
  80106a:	52                   	push   %edx
  80106b:	53                   	push   %ebx
  80106c:	56                   	push   %esi
  80106d:	57                   	push   %edi
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	8d 35 79 10 80 00    	lea    0x801079,%esi
  801077:	0f 34                	sysenter 

00801079 <label_353>:
  801079:	89 ec                	mov    %ebp,%esp
  80107b:	5d                   	pop    %ebp
  80107c:	5f                   	pop    %edi
  80107d:	5e                   	pop    %esi
  80107e:	5b                   	pop    %ebx
  80107f:	5a                   	pop    %edx
  801080:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801081:	85 c0                	test   %eax,%eax
  801083:	7e 17                	jle    80109c <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	50                   	push   %eax
  801089:	6a 07                	push   $0x7
  80108b:	68 e4 17 80 00       	push   $0x8017e4
  801090:	6a 29                	push   $0x29
  801092:	68 01 18 80 00       	push   $0x801801
  801097:	e8 5d 01 00 00       	call   8011f9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80109c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109f:	5b                   	pop    %ebx
  8010a0:	5f                   	pop    %edi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ad:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b8:	89 fb                	mov    %edi,%ebx
  8010ba:	51                   	push   %ecx
  8010bb:	52                   	push   %edx
  8010bc:	53                   	push   %ebx
  8010bd:	56                   	push   %esi
  8010be:	57                   	push   %edi
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	8d 35 ca 10 80 00    	lea    0x8010ca,%esi
  8010c8:	0f 34                	sysenter 

008010ca <label_402>:
  8010ca:	89 ec                	mov    %ebp,%esp
  8010cc:	5d                   	pop    %ebp
  8010cd:	5f                   	pop    %edi
  8010ce:	5e                   	pop    %esi
  8010cf:	5b                   	pop    %ebx
  8010d0:	5a                   	pop    %edx
  8010d1:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	7e 17                	jle    8010ed <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	50                   	push   %eax
  8010da:	6a 09                	push   $0x9
  8010dc:	68 e4 17 80 00       	push   $0x8017e4
  8010e1:	6a 29                	push   $0x29
  8010e3:	68 01 18 80 00       	push   $0x801801
  8010e8:	e8 0c 01 00 00       	call   8011f9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8010fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	89 fb                	mov    %edi,%ebx
  80110b:	51                   	push   %ecx
  80110c:	52                   	push   %edx
  80110d:	53                   	push   %ebx
  80110e:	56                   	push   %esi
  80110f:	57                   	push   %edi
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	8d 35 1b 11 80 00    	lea    0x80111b,%esi
  801119:	0f 34                	sysenter 

0080111b <label_451>:
  80111b:	89 ec                	mov    %ebp,%esp
  80111d:	5d                   	pop    %ebp
  80111e:	5f                   	pop    %edi
  80111f:	5e                   	pop    %esi
  801120:	5b                   	pop    %ebx
  801121:	5a                   	pop    %edx
  801122:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801123:	85 c0                	test   %eax,%eax
  801125:	7e 17                	jle    80113e <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	50                   	push   %eax
  80112b:	6a 0a                	push   $0xa
  80112d:	68 e4 17 80 00       	push   $0x8017e4
  801132:	6a 29                	push   $0x29
  801134:	68 01 18 80 00       	push   $0x801801
  801139:	e8 bb 00 00 00       	call   8011f9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80113e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801141:	5b                   	pop    %ebx
  801142:	5f                   	pop    %edi
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80114a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80114f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801152:	8b 55 08             	mov    0x8(%ebp),%edx
  801155:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801158:	8b 7d 14             	mov    0x14(%ebp),%edi
  80115b:	51                   	push   %ecx
  80115c:	52                   	push   %edx
  80115d:	53                   	push   %ebx
  80115e:	56                   	push   %esi
  80115f:	57                   	push   %edi
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	8d 35 6b 11 80 00    	lea    0x80116b,%esi
  801169:	0f 34                	sysenter 

0080116b <label_502>:
  80116b:	89 ec                	mov    %ebp,%esp
  80116d:	5d                   	pop    %ebp
  80116e:	5f                   	pop    %edi
  80116f:	5e                   	pop    %esi
  801170:	5b                   	pop    %ebx
  801171:	5a                   	pop    %edx
  801172:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801173:	5b                   	pop    %ebx
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	57                   	push   %edi
  80117b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80117c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801181:	b8 0d 00 00 00       	mov    $0xd,%eax
  801186:	8b 55 08             	mov    0x8(%ebp),%edx
  801189:	89 d9                	mov    %ebx,%ecx
  80118b:	89 df                	mov    %ebx,%edi
  80118d:	51                   	push   %ecx
  80118e:	52                   	push   %edx
  80118f:	53                   	push   %ebx
  801190:	56                   	push   %esi
  801191:	57                   	push   %edi
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	8d 35 9d 11 80 00    	lea    0x80119d,%esi
  80119b:	0f 34                	sysenter 

0080119d <label_537>:
  80119d:	89 ec                	mov    %ebp,%esp
  80119f:	5d                   	pop    %ebp
  8011a0:	5f                   	pop    %edi
  8011a1:	5e                   	pop    %esi
  8011a2:	5b                   	pop    %ebx
  8011a3:	5a                   	pop    %edx
  8011a4:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	7e 17                	jle    8011c0 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	50                   	push   %eax
  8011ad:	6a 0d                	push   $0xd
  8011af:	68 e4 17 80 00       	push   $0x8017e4
  8011b4:	6a 29                	push   $0x29
  8011b6:	68 01 18 80 00       	push   $0x801801
  8011bb:	e8 39 00 00 00       	call   8011f9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011d1:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d9:	89 cb                	mov    %ecx,%ebx
  8011db:	89 cf                	mov    %ecx,%edi
  8011dd:	51                   	push   %ecx
  8011de:	52                   	push   %edx
  8011df:	53                   	push   %ebx
  8011e0:	56                   	push   %esi
  8011e1:	57                   	push   %edi
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	8d 35 ed 11 80 00    	lea    0x8011ed,%esi
  8011eb:	0f 34                	sysenter 

008011ed <label_586>:
  8011ed:	89 ec                	mov    %ebp,%esp
  8011ef:	5d                   	pop    %ebp
  8011f0:	5f                   	pop    %edi
  8011f1:	5e                   	pop    %esi
  8011f2:	5b                   	pop    %ebx
  8011f3:	5a                   	pop    %edx
  8011f4:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011f5:	5b                   	pop    %ebx
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8011fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  801201:	a1 70 30 80 00       	mov    0x803070,%eax
  801206:	85 c0                	test   %eax,%eax
  801208:	74 11                	je     80121b <_panic+0x22>
		cprintf("%s: ", argv0);
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	50                   	push   %eax
  80120e:	68 0f 18 80 00       	push   $0x80180f
  801213:	e8 1a f0 ff ff       	call   800232 <cprintf>
  801218:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80121b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801221:	e8 d4 fc ff ff       	call   800efa <sys_getenvid>
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	ff 75 0c             	pushl  0xc(%ebp)
  80122c:	ff 75 08             	pushl  0x8(%ebp)
  80122f:	56                   	push   %esi
  801230:	50                   	push   %eax
  801231:	68 14 18 80 00       	push   $0x801814
  801236:	e8 f7 ef ff ff       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80123b:	83 c4 18             	add    $0x18,%esp
  80123e:	53                   	push   %ebx
  80123f:	ff 75 10             	pushl  0x10(%ebp)
  801242:	e8 9a ef ff ff       	call   8001e1 <vcprintf>
	cprintf("\n");
  801247:	c7 04 24 1a 15 80 00 	movl   $0x80151a,(%esp)
  80124e:	e8 df ef ff ff       	call   800232 <cprintf>
  801253:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801256:	cc                   	int3   
  801257:	eb fd                	jmp    801256 <_panic+0x5d>
  801259:	66 90                	xchg   %ax,%ax
  80125b:	66 90                	xchg   %ax,%ax
  80125d:	66 90                	xchg   %ax,%ax
  80125f:	90                   	nop

00801260 <__udivdi3>:
  801260:	55                   	push   %ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 1c             	sub    $0x1c,%esp
  801267:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80126b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80126f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801277:	85 f6                	test   %esi,%esi
  801279:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80127d:	89 ca                	mov    %ecx,%edx
  80127f:	89 f8                	mov    %edi,%eax
  801281:	75 3d                	jne    8012c0 <__udivdi3+0x60>
  801283:	39 cf                	cmp    %ecx,%edi
  801285:	0f 87 c5 00 00 00    	ja     801350 <__udivdi3+0xf0>
  80128b:	85 ff                	test   %edi,%edi
  80128d:	89 fd                	mov    %edi,%ebp
  80128f:	75 0b                	jne    80129c <__udivdi3+0x3c>
  801291:	b8 01 00 00 00       	mov    $0x1,%eax
  801296:	31 d2                	xor    %edx,%edx
  801298:	f7 f7                	div    %edi
  80129a:	89 c5                	mov    %eax,%ebp
  80129c:	89 c8                	mov    %ecx,%eax
  80129e:	31 d2                	xor    %edx,%edx
  8012a0:	f7 f5                	div    %ebp
  8012a2:	89 c1                	mov    %eax,%ecx
  8012a4:	89 d8                	mov    %ebx,%eax
  8012a6:	89 cf                	mov    %ecx,%edi
  8012a8:	f7 f5                	div    %ebp
  8012aa:	89 c3                	mov    %eax,%ebx
  8012ac:	89 d8                	mov    %ebx,%eax
  8012ae:	89 fa                	mov    %edi,%edx
  8012b0:	83 c4 1c             	add    $0x1c,%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	5f                   	pop    %edi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    
  8012b8:	90                   	nop
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	39 ce                	cmp    %ecx,%esi
  8012c2:	77 74                	ja     801338 <__udivdi3+0xd8>
  8012c4:	0f bd fe             	bsr    %esi,%edi
  8012c7:	83 f7 1f             	xor    $0x1f,%edi
  8012ca:	0f 84 98 00 00 00    	je     801368 <__udivdi3+0x108>
  8012d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8012d5:	89 f9                	mov    %edi,%ecx
  8012d7:	89 c5                	mov    %eax,%ebp
  8012d9:	29 fb                	sub    %edi,%ebx
  8012db:	d3 e6                	shl    %cl,%esi
  8012dd:	89 d9                	mov    %ebx,%ecx
  8012df:	d3 ed                	shr    %cl,%ebp
  8012e1:	89 f9                	mov    %edi,%ecx
  8012e3:	d3 e0                	shl    %cl,%eax
  8012e5:	09 ee                	or     %ebp,%esi
  8012e7:	89 d9                	mov    %ebx,%ecx
  8012e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ed:	89 d5                	mov    %edx,%ebp
  8012ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012f3:	d3 ed                	shr    %cl,%ebp
  8012f5:	89 f9                	mov    %edi,%ecx
  8012f7:	d3 e2                	shl    %cl,%edx
  8012f9:	89 d9                	mov    %ebx,%ecx
  8012fb:	d3 e8                	shr    %cl,%eax
  8012fd:	09 c2                	or     %eax,%edx
  8012ff:	89 d0                	mov    %edx,%eax
  801301:	89 ea                	mov    %ebp,%edx
  801303:	f7 f6                	div    %esi
  801305:	89 d5                	mov    %edx,%ebp
  801307:	89 c3                	mov    %eax,%ebx
  801309:	f7 64 24 0c          	mull   0xc(%esp)
  80130d:	39 d5                	cmp    %edx,%ebp
  80130f:	72 10                	jb     801321 <__udivdi3+0xc1>
  801311:	8b 74 24 08          	mov    0x8(%esp),%esi
  801315:	89 f9                	mov    %edi,%ecx
  801317:	d3 e6                	shl    %cl,%esi
  801319:	39 c6                	cmp    %eax,%esi
  80131b:	73 07                	jae    801324 <__udivdi3+0xc4>
  80131d:	39 d5                	cmp    %edx,%ebp
  80131f:	75 03                	jne    801324 <__udivdi3+0xc4>
  801321:	83 eb 01             	sub    $0x1,%ebx
  801324:	31 ff                	xor    %edi,%edi
  801326:	89 d8                	mov    %ebx,%eax
  801328:	89 fa                	mov    %edi,%edx
  80132a:	83 c4 1c             	add    $0x1c,%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5e                   	pop    %esi
  80132f:	5f                   	pop    %edi
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    
  801332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801338:	31 ff                	xor    %edi,%edi
  80133a:	31 db                	xor    %ebx,%ebx
  80133c:	89 d8                	mov    %ebx,%eax
  80133e:	89 fa                	mov    %edi,%edx
  801340:	83 c4 1c             	add    $0x1c,%esp
  801343:	5b                   	pop    %ebx
  801344:	5e                   	pop    %esi
  801345:	5f                   	pop    %edi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    
  801348:	90                   	nop
  801349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801350:	89 d8                	mov    %ebx,%eax
  801352:	f7 f7                	div    %edi
  801354:	31 ff                	xor    %edi,%edi
  801356:	89 c3                	mov    %eax,%ebx
  801358:	89 d8                	mov    %ebx,%eax
  80135a:	89 fa                	mov    %edi,%edx
  80135c:	83 c4 1c             	add    $0x1c,%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5f                   	pop    %edi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    
  801364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801368:	39 ce                	cmp    %ecx,%esi
  80136a:	72 0c                	jb     801378 <__udivdi3+0x118>
  80136c:	31 db                	xor    %ebx,%ebx
  80136e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801372:	0f 87 34 ff ff ff    	ja     8012ac <__udivdi3+0x4c>
  801378:	bb 01 00 00 00       	mov    $0x1,%ebx
  80137d:	e9 2a ff ff ff       	jmp    8012ac <__udivdi3+0x4c>
  801382:	66 90                	xchg   %ax,%ax
  801384:	66 90                	xchg   %ax,%ax
  801386:	66 90                	xchg   %ax,%ax
  801388:	66 90                	xchg   %ax,%ax
  80138a:	66 90                	xchg   %ax,%ax
  80138c:	66 90                	xchg   %ax,%ax
  80138e:	66 90                	xchg   %ax,%ax

00801390 <__umoddi3>:
  801390:	55                   	push   %ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	83 ec 1c             	sub    $0x1c,%esp
  801397:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80139b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80139f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013a7:	85 d2                	test   %edx,%edx
  8013a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013b1:	89 f3                	mov    %esi,%ebx
  8013b3:	89 3c 24             	mov    %edi,(%esp)
  8013b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ba:	75 1c                	jne    8013d8 <__umoddi3+0x48>
  8013bc:	39 f7                	cmp    %esi,%edi
  8013be:	76 50                	jbe    801410 <__umoddi3+0x80>
  8013c0:	89 c8                	mov    %ecx,%eax
  8013c2:	89 f2                	mov    %esi,%edx
  8013c4:	f7 f7                	div    %edi
  8013c6:	89 d0                	mov    %edx,%eax
  8013c8:	31 d2                	xor    %edx,%edx
  8013ca:	83 c4 1c             	add    $0x1c,%esp
  8013cd:	5b                   	pop    %ebx
  8013ce:	5e                   	pop    %esi
  8013cf:	5f                   	pop    %edi
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    
  8013d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013d8:	39 f2                	cmp    %esi,%edx
  8013da:	89 d0                	mov    %edx,%eax
  8013dc:	77 52                	ja     801430 <__umoddi3+0xa0>
  8013de:	0f bd ea             	bsr    %edx,%ebp
  8013e1:	83 f5 1f             	xor    $0x1f,%ebp
  8013e4:	75 5a                	jne    801440 <__umoddi3+0xb0>
  8013e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8013ea:	0f 82 e0 00 00 00    	jb     8014d0 <__umoddi3+0x140>
  8013f0:	39 0c 24             	cmp    %ecx,(%esp)
  8013f3:	0f 86 d7 00 00 00    	jbe    8014d0 <__umoddi3+0x140>
  8013f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801401:	83 c4 1c             	add    $0x1c,%esp
  801404:	5b                   	pop    %ebx
  801405:	5e                   	pop    %esi
  801406:	5f                   	pop    %edi
  801407:	5d                   	pop    %ebp
  801408:	c3                   	ret    
  801409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801410:	85 ff                	test   %edi,%edi
  801412:	89 fd                	mov    %edi,%ebp
  801414:	75 0b                	jne    801421 <__umoddi3+0x91>
  801416:	b8 01 00 00 00       	mov    $0x1,%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	f7 f7                	div    %edi
  80141f:	89 c5                	mov    %eax,%ebp
  801421:	89 f0                	mov    %esi,%eax
  801423:	31 d2                	xor    %edx,%edx
  801425:	f7 f5                	div    %ebp
  801427:	89 c8                	mov    %ecx,%eax
  801429:	f7 f5                	div    %ebp
  80142b:	89 d0                	mov    %edx,%eax
  80142d:	eb 99                	jmp    8013c8 <__umoddi3+0x38>
  80142f:	90                   	nop
  801430:	89 c8                	mov    %ecx,%eax
  801432:	89 f2                	mov    %esi,%edx
  801434:	83 c4 1c             	add    $0x1c,%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5f                   	pop    %edi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    
  80143c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801440:	8b 34 24             	mov    (%esp),%esi
  801443:	bf 20 00 00 00       	mov    $0x20,%edi
  801448:	89 e9                	mov    %ebp,%ecx
  80144a:	29 ef                	sub    %ebp,%edi
  80144c:	d3 e0                	shl    %cl,%eax
  80144e:	89 f9                	mov    %edi,%ecx
  801450:	89 f2                	mov    %esi,%edx
  801452:	d3 ea                	shr    %cl,%edx
  801454:	89 e9                	mov    %ebp,%ecx
  801456:	09 c2                	or     %eax,%edx
  801458:	89 d8                	mov    %ebx,%eax
  80145a:	89 14 24             	mov    %edx,(%esp)
  80145d:	89 f2                	mov    %esi,%edx
  80145f:	d3 e2                	shl    %cl,%edx
  801461:	89 f9                	mov    %edi,%ecx
  801463:	89 54 24 04          	mov    %edx,0x4(%esp)
  801467:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80146b:	d3 e8                	shr    %cl,%eax
  80146d:	89 e9                	mov    %ebp,%ecx
  80146f:	89 c6                	mov    %eax,%esi
  801471:	d3 e3                	shl    %cl,%ebx
  801473:	89 f9                	mov    %edi,%ecx
  801475:	89 d0                	mov    %edx,%eax
  801477:	d3 e8                	shr    %cl,%eax
  801479:	89 e9                	mov    %ebp,%ecx
  80147b:	09 d8                	or     %ebx,%eax
  80147d:	89 d3                	mov    %edx,%ebx
  80147f:	89 f2                	mov    %esi,%edx
  801481:	f7 34 24             	divl   (%esp)
  801484:	89 d6                	mov    %edx,%esi
  801486:	d3 e3                	shl    %cl,%ebx
  801488:	f7 64 24 04          	mull   0x4(%esp)
  80148c:	39 d6                	cmp    %edx,%esi
  80148e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801492:	89 d1                	mov    %edx,%ecx
  801494:	89 c3                	mov    %eax,%ebx
  801496:	72 08                	jb     8014a0 <__umoddi3+0x110>
  801498:	75 11                	jne    8014ab <__umoddi3+0x11b>
  80149a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80149e:	73 0b                	jae    8014ab <__umoddi3+0x11b>
  8014a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014a4:	1b 14 24             	sbb    (%esp),%edx
  8014a7:	89 d1                	mov    %edx,%ecx
  8014a9:	89 c3                	mov    %eax,%ebx
  8014ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014af:	29 da                	sub    %ebx,%edx
  8014b1:	19 ce                	sbb    %ecx,%esi
  8014b3:	89 f9                	mov    %edi,%ecx
  8014b5:	89 f0                	mov    %esi,%eax
  8014b7:	d3 e0                	shl    %cl,%eax
  8014b9:	89 e9                	mov    %ebp,%ecx
  8014bb:	d3 ea                	shr    %cl,%edx
  8014bd:	89 e9                	mov    %ebp,%ecx
  8014bf:	d3 ee                	shr    %cl,%esi
  8014c1:	09 d0                	or     %edx,%eax
  8014c3:	89 f2                	mov    %esi,%edx
  8014c5:	83 c4 1c             	add    $0x1c,%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5f                   	pop    %edi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    
  8014cd:	8d 76 00             	lea    0x0(%esi),%esi
  8014d0:	29 f9                	sub    %edi,%ecx
  8014d2:	19 d6                	sbb    %edx,%esi
  8014d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014dc:	e9 18 ff ff ff       	jmp    8013f9 <__umoddi3+0x69>
