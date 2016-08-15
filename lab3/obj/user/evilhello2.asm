
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
  8000c5:	68 74 12 80 00       	push   $0x801274
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
  80015c:	6b c0 64             	imul   $0x64,%eax,%eax
  80015f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800164:	a3 6c 30 80 00       	mov    %eax,0x80306c
	// cprintf("env_id = %08x\n", sys_getenvid());

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
  8002aa:	e8 71 0e 00 00       	call   801120 <__umoddi3>
  8002af:	83 c4 14             	add    $0x14,%esp
  8002b2:	0f be 80 9a 12 80 00 	movsbl 0x80129a(%eax),%eax
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
  80038c:	e8 8f 0d 00 00       	call   801120 <__umoddi3>
  800391:	83 c4 14             	add    $0x14,%esp
  800394:	0f be 80 9a 12 80 00 	movsbl 0x80129a(%eax),%eax
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
  8003c2:	e8 29 0c 00 00       	call   800ff0 <__udivdi3>
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
  8003e8:	e8 33 0d 00 00       	call   801120 <__umoddi3>
  8003ed:	83 c4 14             	add    $0x14,%esp
  8003f0:	0f be 80 9a 12 80 00 	movsbl 0x80129a(%eax),%eax
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
  80041e:	e8 cd 0b 00 00       	call   800ff0 <__udivdi3>
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
  800444:	e8 d7 0c 00 00       	call   801120 <__umoddi3>
  800449:	83 c4 14             	add    $0x14,%esp
  80044c:	0f be 80 9a 12 80 00 	movsbl 0x80129a(%eax),%eax
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
  800567:	ff 24 85 a4 13 80 00 	jmp    *0x8013a4(,%eax,4)
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
  800648:	83 f8 06             	cmp    $0x6,%eax
  80064b:	7f 0b                	jg     800658 <vprintfmt+0x183>
  80064d:	8b 14 85 fc 14 80 00 	mov    0x8014fc(,%eax,4),%edx
  800654:	85 d2                	test   %edx,%edx
  800656:	75 15                	jne    80066d <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800658:	50                   	push   %eax
  800659:	68 b2 12 80 00       	push   $0x8012b2
  80065e:	53                   	push   %ebx
  80065f:	57                   	push   %edi
  800660:	e8 53 fe ff ff       	call   8004b8 <printfmt>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	e9 7c fe ff ff       	jmp    8004e9 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80066d:	52                   	push   %edx
  80066e:	68 bb 12 80 00       	push   $0x8012bb
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
  80068f:	b9 ab 12 80 00       	mov    $0x8012ab,%ecx
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
  80090b:	68 28 13 80 00       	push   $0x801328
  800910:	68 bb 12 80 00       	push   $0x8012bb
  800915:	e8 18 f9 ff ff       	call   800232 <cprintf>
  80091a:	83 c4 10             	add    $0x10,%esp
  80091d:	e9 c7 fb ff ff       	jmp    8004e9 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800922:	0f b6 03             	movzbl (%ebx),%eax
  800925:	84 c0                	test   %al,%al
  800927:	79 1f                	jns    800948 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800929:	83 ec 08             	sub    $0x8,%esp
  80092c:	68 60 13 80 00       	push   $0x801360
  800931:	68 bb 12 80 00       	push   $0x8012bb
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
  800e60:	54                   	push   %esp
  800e61:	55                   	push   %ebp
  800e62:	56                   	push   %esi
  800e63:	57                   	push   %edi
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	8d 35 6e 0e 80 00    	lea    0x800e6e,%esi
  800e6c:	0f 34                	sysenter 

00800e6e <label_21>:
  800e6e:	5f                   	pop    %edi
  800e6f:	5e                   	pop    %esi
  800e70:	5d                   	pop    %ebp
  800e71:	5c                   	pop    %esp
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
  800e91:	54                   	push   %esp
  800e92:	55                   	push   %ebp
  800e93:	56                   	push   %esi
  800e94:	57                   	push   %edi
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	8d 35 9f 0e 80 00    	lea    0x800e9f,%esi
  800e9d:	0f 34                	sysenter 

00800e9f <label_55>:
  800e9f:	5f                   	pop    %edi
  800ea0:	5e                   	pop    %esi
  800ea1:	5d                   	pop    %ebp
  800ea2:	5c                   	pop    %esp
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
  800ec3:	54                   	push   %esp
  800ec4:	55                   	push   %ebp
  800ec5:	56                   	push   %esi
  800ec6:	57                   	push   %edi
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	8d 35 d1 0e 80 00    	lea    0x800ed1,%esi
  800ecf:	0f 34                	sysenter 

00800ed1 <label_90>:
  800ed1:	5f                   	pop    %edi
  800ed2:	5e                   	pop    %esi
  800ed3:	5d                   	pop    %ebp
  800ed4:	5c                   	pop    %esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5a                   	pop    %edx
  800ed7:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 17                	jle    800ef3 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	50                   	push   %eax
  800ee0:	6a 03                	push   $0x3
  800ee2:	68 18 15 80 00       	push   $0x801518
  800ee7:	6a 2a                	push   $0x2a
  800ee9:	68 35 15 80 00       	push   $0x801535
  800eee:	e8 9d 00 00 00       	call   800f90 <_panic>

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
  800f12:	54                   	push   %esp
  800f13:	55                   	push   %ebp
  800f14:	56                   	push   %esi
  800f15:	57                   	push   %edi
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	8d 35 20 0f 80 00    	lea    0x800f20,%esi
  800f1e:	0f 34                	sysenter 

00800f20 <label_139>:
  800f20:	5f                   	pop    %edi
  800f21:	5e                   	pop    %esi
  800f22:	5d                   	pop    %ebp
  800f23:	5c                   	pop    %esp
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
  800f45:	54                   	push   %esp
  800f46:	55                   	push   %ebp
  800f47:	56                   	push   %esi
  800f48:	57                   	push   %edi
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	8d 35 53 0f 80 00    	lea    0x800f53,%esi
  800f51:	0f 34                	sysenter 

00800f53 <label_174>:
  800f53:	5f                   	pop    %edi
  800f54:	5e                   	pop    %esi
  800f55:	5d                   	pop    %ebp
  800f56:	5c                   	pop    %esp
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

00800f5e <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
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
  800f63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f68:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f70:	89 cb                	mov    %ecx,%ebx
  800f72:	89 cf                	mov    %ecx,%edi
  800f74:	51                   	push   %ecx
  800f75:	52                   	push   %edx
  800f76:	53                   	push   %ebx
  800f77:	54                   	push   %esp
  800f78:	55                   	push   %ebp
  800f79:	56                   	push   %esi
  800f7a:	57                   	push   %edi
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	8d 35 85 0f 80 00    	lea    0x800f85,%esi
  800f83:	0f 34                	sysenter 

00800f85 <label_209>:
  800f85:	5f                   	pop    %edi
  800f86:	5e                   	pop    %esi
  800f87:	5d                   	pop    %ebp
  800f88:	5c                   	pop    %esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5a                   	pop    %edx
  800f8b:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f8c:	5b                   	pop    %ebx
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	56                   	push   %esi
  800f94:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f95:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800f98:	a1 70 30 80 00       	mov    0x803070,%eax
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	74 11                	je     800fb2 <_panic+0x22>
		cprintf("%s: ", argv0);
  800fa1:	83 ec 08             	sub    $0x8,%esp
  800fa4:	50                   	push   %eax
  800fa5:	68 43 15 80 00       	push   $0x801543
  800faa:	e8 83 f2 ff ff       	call   800232 <cprintf>
  800faf:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fb2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fb8:	e8 3d ff ff ff       	call   800efa <sys_getenvid>
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	ff 75 0c             	pushl  0xc(%ebp)
  800fc3:	ff 75 08             	pushl  0x8(%ebp)
  800fc6:	56                   	push   %esi
  800fc7:	50                   	push   %eax
  800fc8:	68 48 15 80 00       	push   $0x801548
  800fcd:	e8 60 f2 ff ff       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fd2:	83 c4 18             	add    $0x18,%esp
  800fd5:	53                   	push   %ebx
  800fd6:	ff 75 10             	pushl  0x10(%ebp)
  800fd9:	e8 03 f2 ff ff       	call   8001e1 <vcprintf>
	cprintf("\n");
  800fde:	c7 04 24 8e 12 80 00 	movl   $0x80128e,(%esp)
  800fe5:	e8 48 f2 ff ff       	call   800232 <cprintf>
  800fea:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fed:	cc                   	int3   
  800fee:	eb fd                	jmp    800fed <_panic+0x5d>

00800ff0 <__udivdi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 1c             	sub    $0x1c,%esp
  800ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801007:	85 f6                	test   %esi,%esi
  801009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80100d:	89 ca                	mov    %ecx,%edx
  80100f:	89 f8                	mov    %edi,%eax
  801011:	75 3d                	jne    801050 <__udivdi3+0x60>
  801013:	39 cf                	cmp    %ecx,%edi
  801015:	0f 87 c5 00 00 00    	ja     8010e0 <__udivdi3+0xf0>
  80101b:	85 ff                	test   %edi,%edi
  80101d:	89 fd                	mov    %edi,%ebp
  80101f:	75 0b                	jne    80102c <__udivdi3+0x3c>
  801021:	b8 01 00 00 00       	mov    $0x1,%eax
  801026:	31 d2                	xor    %edx,%edx
  801028:	f7 f7                	div    %edi
  80102a:	89 c5                	mov    %eax,%ebp
  80102c:	89 c8                	mov    %ecx,%eax
  80102e:	31 d2                	xor    %edx,%edx
  801030:	f7 f5                	div    %ebp
  801032:	89 c1                	mov    %eax,%ecx
  801034:	89 d8                	mov    %ebx,%eax
  801036:	89 cf                	mov    %ecx,%edi
  801038:	f7 f5                	div    %ebp
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	89 d8                	mov    %ebx,%eax
  80103e:	89 fa                	mov    %edi,%edx
  801040:	83 c4 1c             	add    $0x1c,%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    
  801048:	90                   	nop
  801049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801050:	39 ce                	cmp    %ecx,%esi
  801052:	77 74                	ja     8010c8 <__udivdi3+0xd8>
  801054:	0f bd fe             	bsr    %esi,%edi
  801057:	83 f7 1f             	xor    $0x1f,%edi
  80105a:	0f 84 98 00 00 00    	je     8010f8 <__udivdi3+0x108>
  801060:	bb 20 00 00 00       	mov    $0x20,%ebx
  801065:	89 f9                	mov    %edi,%ecx
  801067:	89 c5                	mov    %eax,%ebp
  801069:	29 fb                	sub    %edi,%ebx
  80106b:	d3 e6                	shl    %cl,%esi
  80106d:	89 d9                	mov    %ebx,%ecx
  80106f:	d3 ed                	shr    %cl,%ebp
  801071:	89 f9                	mov    %edi,%ecx
  801073:	d3 e0                	shl    %cl,%eax
  801075:	09 ee                	or     %ebp,%esi
  801077:	89 d9                	mov    %ebx,%ecx
  801079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80107d:	89 d5                	mov    %edx,%ebp
  80107f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801083:	d3 ed                	shr    %cl,%ebp
  801085:	89 f9                	mov    %edi,%ecx
  801087:	d3 e2                	shl    %cl,%edx
  801089:	89 d9                	mov    %ebx,%ecx
  80108b:	d3 e8                	shr    %cl,%eax
  80108d:	09 c2                	or     %eax,%edx
  80108f:	89 d0                	mov    %edx,%eax
  801091:	89 ea                	mov    %ebp,%edx
  801093:	f7 f6                	div    %esi
  801095:	89 d5                	mov    %edx,%ebp
  801097:	89 c3                	mov    %eax,%ebx
  801099:	f7 64 24 0c          	mull   0xc(%esp)
  80109d:	39 d5                	cmp    %edx,%ebp
  80109f:	72 10                	jb     8010b1 <__udivdi3+0xc1>
  8010a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010a5:	89 f9                	mov    %edi,%ecx
  8010a7:	d3 e6                	shl    %cl,%esi
  8010a9:	39 c6                	cmp    %eax,%esi
  8010ab:	73 07                	jae    8010b4 <__udivdi3+0xc4>
  8010ad:	39 d5                	cmp    %edx,%ebp
  8010af:	75 03                	jne    8010b4 <__udivdi3+0xc4>
  8010b1:	83 eb 01             	sub    $0x1,%ebx
  8010b4:	31 ff                	xor    %edi,%edi
  8010b6:	89 d8                	mov    %ebx,%eax
  8010b8:	89 fa                	mov    %edi,%edx
  8010ba:	83 c4 1c             	add    $0x1c,%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5f                   	pop    %edi
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    
  8010c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010c8:	31 ff                	xor    %edi,%edi
  8010ca:	31 db                	xor    %ebx,%ebx
  8010cc:	89 d8                	mov    %ebx,%eax
  8010ce:	89 fa                	mov    %edi,%edx
  8010d0:	83 c4 1c             	add    $0x1c,%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    
  8010d8:	90                   	nop
  8010d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	89 d8                	mov    %ebx,%eax
  8010e2:	f7 f7                	div    %edi
  8010e4:	31 ff                	xor    %edi,%edi
  8010e6:	89 c3                	mov    %eax,%ebx
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	89 fa                	mov    %edi,%edx
  8010ec:	83 c4 1c             	add    $0x1c,%esp
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	39 ce                	cmp    %ecx,%esi
  8010fa:	72 0c                	jb     801108 <__udivdi3+0x118>
  8010fc:	31 db                	xor    %ebx,%ebx
  8010fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801102:	0f 87 34 ff ff ff    	ja     80103c <__udivdi3+0x4c>
  801108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80110d:	e9 2a ff ff ff       	jmp    80103c <__udivdi3+0x4c>
  801112:	66 90                	xchg   %ax,%ax
  801114:	66 90                	xchg   %ax,%ax
  801116:	66 90                	xchg   %ax,%ax
  801118:	66 90                	xchg   %ax,%ax
  80111a:	66 90                	xchg   %ax,%ax
  80111c:	66 90                	xchg   %ax,%ax
  80111e:	66 90                	xchg   %ax,%ax

00801120 <__umoddi3>:
  801120:	55                   	push   %ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 1c             	sub    $0x1c,%esp
  801127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80112b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80112f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801137:	85 d2                	test   %edx,%edx
  801139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80113d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801141:	89 f3                	mov    %esi,%ebx
  801143:	89 3c 24             	mov    %edi,(%esp)
  801146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114a:	75 1c                	jne    801168 <__umoddi3+0x48>
  80114c:	39 f7                	cmp    %esi,%edi
  80114e:	76 50                	jbe    8011a0 <__umoddi3+0x80>
  801150:	89 c8                	mov    %ecx,%eax
  801152:	89 f2                	mov    %esi,%edx
  801154:	f7 f7                	div    %edi
  801156:	89 d0                	mov    %edx,%eax
  801158:	31 d2                	xor    %edx,%edx
  80115a:	83 c4 1c             	add    $0x1c,%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5f                   	pop    %edi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    
  801162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801168:	39 f2                	cmp    %esi,%edx
  80116a:	89 d0                	mov    %edx,%eax
  80116c:	77 52                	ja     8011c0 <__umoddi3+0xa0>
  80116e:	0f bd ea             	bsr    %edx,%ebp
  801171:	83 f5 1f             	xor    $0x1f,%ebp
  801174:	75 5a                	jne    8011d0 <__umoddi3+0xb0>
  801176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80117a:	0f 82 e0 00 00 00    	jb     801260 <__umoddi3+0x140>
  801180:	39 0c 24             	cmp    %ecx,(%esp)
  801183:	0f 86 d7 00 00 00    	jbe    801260 <__umoddi3+0x140>
  801189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80118d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801191:	83 c4 1c             	add    $0x1c,%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    
  801199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	85 ff                	test   %edi,%edi
  8011a2:	89 fd                	mov    %edi,%ebp
  8011a4:	75 0b                	jne    8011b1 <__umoddi3+0x91>
  8011a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ab:	31 d2                	xor    %edx,%edx
  8011ad:	f7 f7                	div    %edi
  8011af:	89 c5                	mov    %eax,%ebp
  8011b1:	89 f0                	mov    %esi,%eax
  8011b3:	31 d2                	xor    %edx,%edx
  8011b5:	f7 f5                	div    %ebp
  8011b7:	89 c8                	mov    %ecx,%eax
  8011b9:	f7 f5                	div    %ebp
  8011bb:	89 d0                	mov    %edx,%eax
  8011bd:	eb 99                	jmp    801158 <__umoddi3+0x38>
  8011bf:	90                   	nop
  8011c0:	89 c8                	mov    %ecx,%eax
  8011c2:	89 f2                	mov    %esi,%edx
  8011c4:	83 c4 1c             	add    $0x1c,%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5f                   	pop    %edi
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	8b 34 24             	mov    (%esp),%esi
  8011d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8011d8:	89 e9                	mov    %ebp,%ecx
  8011da:	29 ef                	sub    %ebp,%edi
  8011dc:	d3 e0                	shl    %cl,%eax
  8011de:	89 f9                	mov    %edi,%ecx
  8011e0:	89 f2                	mov    %esi,%edx
  8011e2:	d3 ea                	shr    %cl,%edx
  8011e4:	89 e9                	mov    %ebp,%ecx
  8011e6:	09 c2                	or     %eax,%edx
  8011e8:	89 d8                	mov    %ebx,%eax
  8011ea:	89 14 24             	mov    %edx,(%esp)
  8011ed:	89 f2                	mov    %esi,%edx
  8011ef:	d3 e2                	shl    %cl,%edx
  8011f1:	89 f9                	mov    %edi,%ecx
  8011f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8011fb:	d3 e8                	shr    %cl,%eax
  8011fd:	89 e9                	mov    %ebp,%ecx
  8011ff:	89 c6                	mov    %eax,%esi
  801201:	d3 e3                	shl    %cl,%ebx
  801203:	89 f9                	mov    %edi,%ecx
  801205:	89 d0                	mov    %edx,%eax
  801207:	d3 e8                	shr    %cl,%eax
  801209:	89 e9                	mov    %ebp,%ecx
  80120b:	09 d8                	or     %ebx,%eax
  80120d:	89 d3                	mov    %edx,%ebx
  80120f:	89 f2                	mov    %esi,%edx
  801211:	f7 34 24             	divl   (%esp)
  801214:	89 d6                	mov    %edx,%esi
  801216:	d3 e3                	shl    %cl,%ebx
  801218:	f7 64 24 04          	mull   0x4(%esp)
  80121c:	39 d6                	cmp    %edx,%esi
  80121e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801222:	89 d1                	mov    %edx,%ecx
  801224:	89 c3                	mov    %eax,%ebx
  801226:	72 08                	jb     801230 <__umoddi3+0x110>
  801228:	75 11                	jne    80123b <__umoddi3+0x11b>
  80122a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80122e:	73 0b                	jae    80123b <__umoddi3+0x11b>
  801230:	2b 44 24 04          	sub    0x4(%esp),%eax
  801234:	1b 14 24             	sbb    (%esp),%edx
  801237:	89 d1                	mov    %edx,%ecx
  801239:	89 c3                	mov    %eax,%ebx
  80123b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80123f:	29 da                	sub    %ebx,%edx
  801241:	19 ce                	sbb    %ecx,%esi
  801243:	89 f9                	mov    %edi,%ecx
  801245:	89 f0                	mov    %esi,%eax
  801247:	d3 e0                	shl    %cl,%eax
  801249:	89 e9                	mov    %ebp,%ecx
  80124b:	d3 ea                	shr    %cl,%edx
  80124d:	89 e9                	mov    %ebp,%ecx
  80124f:	d3 ee                	shr    %cl,%esi
  801251:	09 d0                	or     %edx,%eax
  801253:	89 f2                	mov    %esi,%edx
  801255:	83 c4 1c             	add    $0x1c,%esp
  801258:	5b                   	pop    %ebx
  801259:	5e                   	pop    %esi
  80125a:	5f                   	pop    %edi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    
  80125d:	8d 76 00             	lea    0x0(%esi),%esi
  801260:	29 f9                	sub    %edi,%ecx
  801262:	19 d6                	sbb    %edx,%esi
  801264:	89 74 24 04          	mov    %esi,0x4(%esp)
  801268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126c:	e9 18 ff ff ff       	jmp    801189 <__umoddi3+0x69>
