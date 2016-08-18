
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 a0 14 80 00       	push   $0x8014a0
  800045:	e8 cb 01 00 00       	call   800215 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 14 0f 00 00       	call   800f72 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 c0 14 80 00       	push   $0x8014c0
  80006f:	6a 0e                	push   $0xe
  800071:	68 aa 14 80 00       	push   $0x8014aa
  800076:	e8 a7 00 00 00       	call   800122 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ec 14 80 00       	push   $0x8014ec
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 4d 09 00 00       	call   8009d6 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 3b 11 00 00       	call   8011dc <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 bc 14 80 00       	push   $0x8014bc
  8000ae:	e8 62 01 00 00       	call   800215 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 bc 14 80 00       	push   $0x8014bc
  8000c0:	e8 50 01 00 00       	call   800215 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000d5:	e8 03 0e 00 00       	call   800edd <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	c1 e0 07             	shl    $0x7,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 70 0d 00 00       	call   800e8d <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80012a:	a1 10 20 80 00       	mov    0x802010,%eax
  80012f:	85 c0                	test   %eax,%eax
  800131:	74 11                	je     800144 <_panic+0x22>
		cprintf("%s: ", argv0);
  800133:	83 ec 08             	sub    $0x8,%esp
  800136:	50                   	push   %eax
  800137:	68 17 15 80 00       	push   $0x801517
  80013c:	e8 d4 00 00 00       	call   800215 <cprintf>
  800141:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014a:	e8 8e 0d 00 00       	call   800edd <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 1c 15 80 00       	push   $0x80151c
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 be 14 80 00 	movl   $0x8014be,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x5d>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 7a 0c 00 00       	call   800e2c <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 c0 02 00 00       	call   8004b8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 1f 0c 00 00       	call   800e2c <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800242:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800245:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800249:	0f 85 bf 00 00 00    	jne    80030e <printnum+0xe5>
  80024f:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800255:	0f 8d de 00 00 00    	jge    800339 <printnum+0x110>
		judge_time_for_space = width;
  80025b:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800261:	e9 d3 00 00 00       	jmp    800339 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800266:	83 eb 01             	sub    $0x1,%ebx
  800269:	85 db                	test   %ebx,%ebx
  80026b:	7f 37                	jg     8002a4 <printnum+0x7b>
  80026d:	e9 ea 00 00 00       	jmp    80035c <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800272:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800275:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	56                   	push   %esi
  80027e:	83 ec 04             	sub    $0x4,%esp
  800281:	ff 75 dc             	pushl  -0x24(%ebp)
  800284:	ff 75 d8             	pushl  -0x28(%ebp)
  800287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028a:	ff 75 e0             	pushl  -0x20(%ebp)
  80028d:	e8 ae 10 00 00       	call   801340 <__umoddi3>
  800292:	83 c4 14             	add    $0x14,%esp
  800295:	0f be 80 3f 15 80 00 	movsbl 0x80153f(%eax),%eax
  80029c:	50                   	push   %eax
  80029d:	ff d7                	call   *%edi
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	eb 16                	jmp    8002ba <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	ff 75 18             	pushl  0x18(%ebp)
  8002ab:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	83 eb 01             	sub    $0x1,%ebx
  8002b3:	75 ef                	jne    8002a4 <printnum+0x7b>
  8002b5:	e9 a2 00 00 00       	jmp    80035c <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8002ba:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8002c0:	0f 85 76 01 00 00    	jne    80043c <printnum+0x213>
		while(num_of_space-- > 0)
  8002c6:	a1 04 20 80 00       	mov    0x802004,%eax
  8002cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002ce:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 1d                	jle    8002f5 <printnum+0xcc>
			putch(' ', putdat);
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	56                   	push   %esi
  8002dc:	6a 20                	push   $0x20
  8002de:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8002e0:	a1 04 20 80 00       	mov    0x802004,%eax
  8002e5:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002e8:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7f e3                	jg     8002d8 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8002f5:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8002fc:	00 00 00 
		judge_time_for_space = 0;
  8002ff:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800306:	00 00 00 
	}
}
  800309:	e9 2e 01 00 00       	jmp    80043c <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80030e:	8b 45 10             	mov    0x10(%ebp),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800319:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80031c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800322:	83 fa 00             	cmp    $0x0,%edx
  800325:	0f 87 ba 00 00 00    	ja     8003e5 <printnum+0x1bc>
  80032b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80032e:	0f 83 b1 00 00 00    	jae    8003e5 <printnum+0x1bc>
  800334:	e9 2d ff ff ff       	jmp    800266 <printnum+0x3d>
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	ba 00 00 00 00       	mov    $0x0,%edx
  800341:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800344:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800347:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80034d:	83 fa 00             	cmp    $0x0,%edx
  800350:	77 37                	ja     800389 <printnum+0x160>
  800352:	3b 45 10             	cmp    0x10(%ebp),%eax
  800355:	73 32                	jae    800389 <printnum+0x160>
  800357:	e9 16 ff ff ff       	jmp    800272 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035c:	83 ec 08             	sub    $0x8,%esp
  80035f:	56                   	push   %esi
  800360:	83 ec 04             	sub    $0x4,%esp
  800363:	ff 75 dc             	pushl  -0x24(%ebp)
  800366:	ff 75 d8             	pushl  -0x28(%ebp)
  800369:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036c:	ff 75 e0             	pushl  -0x20(%ebp)
  80036f:	e8 cc 0f 00 00       	call   801340 <__umoddi3>
  800374:	83 c4 14             	add    $0x14,%esp
  800377:	0f be 80 3f 15 80 00 	movsbl 0x80153f(%eax),%eax
  80037e:	50                   	push   %eax
  80037f:	ff d7                	call   *%edi
  800381:	83 c4 10             	add    $0x10,%esp
  800384:	e9 b3 00 00 00       	jmp    80043c <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800389:	83 ec 0c             	sub    $0xc,%esp
  80038c:	ff 75 18             	pushl  0x18(%ebp)
  80038f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800392:	50                   	push   %eax
  800393:	ff 75 10             	pushl  0x10(%ebp)
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	ff 75 dc             	pushl  -0x24(%ebp)
  80039c:	ff 75 d8             	pushl  -0x28(%ebp)
  80039f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a5:	e8 66 0e 00 00       	call   801210 <__udivdi3>
  8003aa:	83 c4 18             	add    $0x18,%esp
  8003ad:	52                   	push   %edx
  8003ae:	50                   	push   %eax
  8003af:	89 f2                	mov    %esi,%edx
  8003b1:	89 f8                	mov    %edi,%eax
  8003b3:	e8 71 fe ff ff       	call   800229 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b8:	83 c4 18             	add    $0x18,%esp
  8003bb:	56                   	push   %esi
  8003bc:	83 ec 04             	sub    $0x4,%esp
  8003bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cb:	e8 70 0f 00 00       	call   801340 <__umoddi3>
  8003d0:	83 c4 14             	add    $0x14,%esp
  8003d3:	0f be 80 3f 15 80 00 	movsbl 0x80153f(%eax),%eax
  8003da:	50                   	push   %eax
  8003db:	ff d7                	call   *%edi
  8003dd:	83 c4 10             	add    $0x10,%esp
  8003e0:	e9 d5 fe ff ff       	jmp    8002ba <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e5:	83 ec 0c             	sub    $0xc,%esp
  8003e8:	ff 75 18             	pushl  0x18(%ebp)
  8003eb:	83 eb 01             	sub    $0x1,%ebx
  8003ee:	53                   	push   %ebx
  8003ef:	ff 75 10             	pushl  0x10(%ebp)
  8003f2:	83 ec 08             	sub    $0x8,%esp
  8003f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800401:	e8 0a 0e 00 00       	call   801210 <__udivdi3>
  800406:	83 c4 18             	add    $0x18,%esp
  800409:	52                   	push   %edx
  80040a:	50                   	push   %eax
  80040b:	89 f2                	mov    %esi,%edx
  80040d:	89 f8                	mov    %edi,%eax
  80040f:	e8 15 fe ff ff       	call   800229 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800414:	83 c4 18             	add    $0x18,%esp
  800417:	56                   	push   %esi
  800418:	83 ec 04             	sub    $0x4,%esp
  80041b:	ff 75 dc             	pushl  -0x24(%ebp)
  80041e:	ff 75 d8             	pushl  -0x28(%ebp)
  800421:	ff 75 e4             	pushl  -0x1c(%ebp)
  800424:	ff 75 e0             	pushl  -0x20(%ebp)
  800427:	e8 14 0f 00 00       	call   801340 <__umoddi3>
  80042c:	83 c4 14             	add    $0x14,%esp
  80042f:	0f be 80 3f 15 80 00 	movsbl 0x80153f(%eax),%eax
  800436:	50                   	push   %eax
  800437:	ff d7                	call   *%edi
  800439:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80043c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80043f:	5b                   	pop    %ebx
  800440:	5e                   	pop    %esi
  800441:	5f                   	pop    %edi
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800447:	83 fa 01             	cmp    $0x1,%edx
  80044a:	7e 0e                	jle    80045a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044c:	8b 10                	mov    (%eax),%edx
  80044e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800451:	89 08                	mov    %ecx,(%eax)
  800453:	8b 02                	mov    (%edx),%eax
  800455:	8b 52 04             	mov    0x4(%edx),%edx
  800458:	eb 22                	jmp    80047c <getuint+0x38>
	else if (lflag)
  80045a:	85 d2                	test   %edx,%edx
  80045c:	74 10                	je     80046e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
  80046c:	eb 0e                	jmp    80047c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80046e:	8b 10                	mov    (%eax),%edx
  800470:	8d 4a 04             	lea    0x4(%edx),%ecx
  800473:	89 08                	mov    %ecx,(%eax)
  800475:	8b 02                	mov    (%edx),%eax
  800477:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800484:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800488:	8b 10                	mov    (%eax),%edx
  80048a:	3b 50 04             	cmp    0x4(%eax),%edx
  80048d:	73 0a                	jae    800499 <sprintputch+0x1b>
		*b->buf++ = ch;
  80048f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800492:	89 08                	mov    %ecx,(%eax)
  800494:	8b 45 08             	mov    0x8(%ebp),%eax
  800497:	88 02                	mov    %al,(%edx)
}
  800499:	5d                   	pop    %ebp
  80049a:	c3                   	ret    

0080049b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a4:	50                   	push   %eax
  8004a5:	ff 75 10             	pushl  0x10(%ebp)
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	ff 75 08             	pushl  0x8(%ebp)
  8004ae:	e8 05 00 00 00       	call   8004b8 <vprintfmt>
	va_end(ap);
}
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    

008004b8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	57                   	push   %edi
  8004bc:	56                   	push   %esi
  8004bd:	53                   	push   %ebx
  8004be:	83 ec 2c             	sub    $0x2c,%esp
  8004c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c7:	eb 03                	jmp    8004cc <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004c9:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cf:	8d 70 01             	lea    0x1(%eax),%esi
  8004d2:	0f b6 00             	movzbl (%eax),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	74 27                	je     800501 <vprintfmt+0x49>
			if (ch == '\0')
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	75 0d                	jne    8004eb <vprintfmt+0x33>
  8004de:	e9 9d 04 00 00       	jmp    800980 <vprintfmt+0x4c8>
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	0f 84 95 04 00 00    	je     800980 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	50                   	push   %eax
  8004f0:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f2:	83 c6 01             	add    $0x1,%esi
  8004f5:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	83 f8 25             	cmp    $0x25,%eax
  8004ff:	75 e2                	jne    8004e3 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800501:	b9 00 00 00 00       	mov    $0x0,%ecx
  800506:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80050a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800511:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800518:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80051f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800526:	eb 08                	jmp    800530 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80052b:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8d 46 01             	lea    0x1(%esi),%eax
  800533:	89 45 10             	mov    %eax,0x10(%ebp)
  800536:	0f b6 06             	movzbl (%esi),%eax
  800539:	0f b6 d0             	movzbl %al,%edx
  80053c:	83 e8 23             	sub    $0x23,%eax
  80053f:	3c 55                	cmp    $0x55,%al
  800541:	0f 87 fa 03 00 00    	ja     800941 <vprintfmt+0x489>
  800547:	0f b6 c0             	movzbl %al,%eax
  80054a:	ff 24 85 80 16 80 00 	jmp    *0x801680(,%eax,4)
  800551:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800554:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800558:	eb d6                	jmp    800530 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80055a:	8d 42 d0             	lea    -0x30(%edx),%eax
  80055d:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800560:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800564:	8d 50 d0             	lea    -0x30(%eax),%edx
  800567:	83 fa 09             	cmp    $0x9,%edx
  80056a:	77 6b                	ja     8005d7 <vprintfmt+0x11f>
  80056c:	8b 75 10             	mov    0x10(%ebp),%esi
  80056f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800572:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800575:	eb 09                	jmp    800580 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80057a:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80057e:	eb b0                	jmp    800530 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800580:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800583:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800586:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80058a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80058d:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800590:	83 f9 09             	cmp    $0x9,%ecx
  800593:	76 eb                	jbe    800580 <vprintfmt+0xc8>
  800595:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800598:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80059b:	eb 3d                	jmp    8005da <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ae:	eb 2a                	jmp    8005da <vprintfmt+0x122>
  8005b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ba:	0f 49 d0             	cmovns %eax,%edx
  8005bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 75 10             	mov    0x10(%ebp),%esi
  8005c3:	e9 68 ff ff ff       	jmp    800530 <vprintfmt+0x78>
  8005c8:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005cb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d2:	e9 59 ff ff ff       	jmp    800530 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005de:	0f 89 4c ff ff ff    	jns    800530 <vprintfmt+0x78>
				width = precision, precision = -1;
  8005e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f1:	e9 3a ff ff ff       	jmp    800530 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f6:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005fd:	e9 2e ff ff ff       	jmp    800530 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 04             	lea    0x4(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	ff 30                	pushl  (%eax)
  800611:	ff d7                	call   *%edi
			break;
  800613:	83 c4 10             	add    $0x10,%esp
  800616:	e9 b1 fe ff ff       	jmp    8004cc <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	99                   	cltd   
  800627:	31 d0                	xor    %edx,%eax
  800629:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062b:	83 f8 08             	cmp    $0x8,%eax
  80062e:	7f 0b                	jg     80063b <vprintfmt+0x183>
  800630:	8b 14 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%edx
  800637:	85 d2                	test   %edx,%edx
  800639:	75 15                	jne    800650 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80063b:	50                   	push   %eax
  80063c:	68 57 15 80 00       	push   $0x801557
  800641:	53                   	push   %ebx
  800642:	57                   	push   %edi
  800643:	e8 53 fe ff ff       	call   80049b <printfmt>
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	e9 7c fe ff ff       	jmp    8004cc <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800650:	52                   	push   %edx
  800651:	68 60 15 80 00       	push   $0x801560
  800656:	53                   	push   %ebx
  800657:	57                   	push   %edi
  800658:	e8 3e fe ff ff       	call   80049b <printfmt>
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	e9 67 fe ff ff       	jmp    8004cc <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800670:	85 c0                	test   %eax,%eax
  800672:	b9 50 15 80 00       	mov    $0x801550,%ecx
  800677:	0f 45 c8             	cmovne %eax,%ecx
  80067a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80067d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800681:	7e 06                	jle    800689 <vprintfmt+0x1d1>
  800683:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800687:	75 19                	jne    8006a2 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800689:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80068c:	8d 70 01             	lea    0x1(%eax),%esi
  80068f:	0f b6 00             	movzbl (%eax),%eax
  800692:	0f be d0             	movsbl %al,%edx
  800695:	85 d2                	test   %edx,%edx
  800697:	0f 85 9f 00 00 00    	jne    80073c <vprintfmt+0x284>
  80069d:	e9 8c 00 00 00       	jmp    80072e <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a8:	ff 75 cc             	pushl  -0x34(%ebp)
  8006ab:	e8 62 03 00 00       	call   800a12 <strnlen>
  8006b0:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006b3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	85 c9                	test   %ecx,%ecx
  8006bb:	0f 8e a6 02 00 00    	jle    800967 <vprintfmt+0x4af>
					putch(padc, putdat);
  8006c1:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c8:	89 cb                	mov    %ecx,%ebx
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	ff 75 0c             	pushl  0xc(%ebp)
  8006d0:	56                   	push   %esi
  8006d1:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	83 eb 01             	sub    $0x1,%ebx
  8006d9:	75 ef                	jne    8006ca <vprintfmt+0x212>
  8006db:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e1:	e9 81 02 00 00       	jmp    800967 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ea:	74 1b                	je     800707 <vprintfmt+0x24f>
  8006ec:	0f be c0             	movsbl %al,%eax
  8006ef:	83 e8 20             	sub    $0x20,%eax
  8006f2:	83 f8 5e             	cmp    $0x5e,%eax
  8006f5:	76 10                	jbe    800707 <vprintfmt+0x24f>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff 55 08             	call   *0x8(%ebp)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 0d                	jmp    800714 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	52                   	push   %edx
  80070e:	ff 55 08             	call   *0x8(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800714:	83 ef 01             	sub    $0x1,%edi
  800717:	83 c6 01             	add    $0x1,%esi
  80071a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80071e:	0f be d0             	movsbl %al,%edx
  800721:	85 d2                	test   %edx,%edx
  800723:	75 31                	jne    800756 <vprintfmt+0x29e>
  800725:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800728:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800731:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800735:	7f 33                	jg     80076a <vprintfmt+0x2b2>
  800737:	e9 90 fd ff ff       	jmp    8004cc <vprintfmt+0x14>
  80073c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800742:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800745:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800748:	eb 0c                	jmp    800756 <vprintfmt+0x29e>
  80074a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80074d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800750:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800753:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800756:	85 db                	test   %ebx,%ebx
  800758:	78 8c                	js     8006e6 <vprintfmt+0x22e>
  80075a:	83 eb 01             	sub    $0x1,%ebx
  80075d:	79 87                	jns    8006e6 <vprintfmt+0x22e>
  80075f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800762:	8b 7d 08             	mov    0x8(%ebp),%edi
  800765:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800768:	eb c4                	jmp    80072e <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 20                	push   $0x20
  800770:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	83 ee 01             	sub    $0x1,%esi
  800778:	75 f0                	jne    80076a <vprintfmt+0x2b2>
  80077a:	e9 4d fd ff ff       	jmp    8004cc <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077f:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800783:	7e 16                	jle    80079b <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 50 08             	lea    0x8(%eax),%edx
  80078b:	89 55 14             	mov    %edx,0x14(%ebp)
  80078e:	8b 50 04             	mov    0x4(%eax),%edx
  800791:	8b 00                	mov    (%eax),%eax
  800793:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800796:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800799:	eb 34                	jmp    8007cf <vprintfmt+0x317>
	else if (lflag)
  80079b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80079f:	74 18                	je     8007b9 <vprintfmt+0x301>
		return va_arg(*ap, long);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8d 50 04             	lea    0x4(%eax),%edx
  8007a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007aa:	8b 30                	mov    (%eax),%esi
  8007ac:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007af:	89 f0                	mov    %esi,%eax
  8007b1:	c1 f8 1f             	sar    $0x1f,%eax
  8007b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007b7:	eb 16                	jmp    8007cf <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 50 04             	lea    0x4(%eax),%edx
  8007bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c2:	8b 30                	mov    (%eax),%esi
  8007c4:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007c7:	89 f0                	mov    %esi,%eax
  8007c9:	c1 f8 1f             	sar    $0x1f,%eax
  8007cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	79 28                	jns    800807 <vprintfmt+0x34f>
				putch('-', putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	6a 2d                	push   $0x2d
  8007e5:	ff d7                	call   *%edi
				num = -(long long) num;
  8007e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007ed:	f7 d8                	neg    %eax
  8007ef:	83 d2 00             	adc    $0x0,%edx
  8007f2:	f7 da                	neg    %edx
  8007f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007fa:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8007fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800802:	e9 b2 00 00 00       	jmp    8008b9 <vprintfmt+0x401>
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	0f 84 a5 00 00 00    	je     8008b9 <vprintfmt+0x401>
				putch('+', putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	6a 2b                	push   $0x2b
  80081a:	ff d7                	call   *%edi
  80081c:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  80081f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800824:	e9 90 00 00 00       	jmp    8008b9 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800829:	85 c9                	test   %ecx,%ecx
  80082b:	74 0b                	je     800838 <vprintfmt+0x380>
				putch('+', putdat);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	53                   	push   %ebx
  800831:	6a 2b                	push   $0x2b
  800833:	ff d7                	call   *%edi
  800835:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800838:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
  80083e:	e8 01 fc ff ff       	call   800444 <getuint>
  800843:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800846:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800849:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80084e:	eb 69                	jmp    8008b9 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	6a 30                	push   $0x30
  800856:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800858:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
  80085e:	e8 e1 fb ff ff       	call   800444 <getuint>
  800863:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800866:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800869:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80086c:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800871:	eb 46                	jmp    8008b9 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	6a 30                	push   $0x30
  800879:	ff d7                	call   *%edi
			putch('x', putdat);
  80087b:	83 c4 08             	add    $0x8,%esp
  80087e:	53                   	push   %ebx
  80087f:	6a 78                	push   $0x78
  800881:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 50 04             	lea    0x4(%eax),%edx
  800889:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088c:	8b 00                	mov    (%eax),%eax
  80088e:	ba 00 00 00 00       	mov    $0x0,%edx
  800893:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800896:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800899:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80089c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008a1:	eb 16                	jmp    8008b9 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a9:	e8 96 fb ff ff       	call   800444 <getuint>
  8008ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008b4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b9:	83 ec 0c             	sub    $0xc,%esp
  8008bc:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008c0:	56                   	push   %esi
  8008c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008c4:	50                   	push   %eax
  8008c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8008c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8008cb:	89 da                	mov    %ebx,%edx
  8008cd:	89 f8                	mov    %edi,%eax
  8008cf:	e8 55 f9 ff ff       	call   800229 <printnum>
			break;
  8008d4:	83 c4 20             	add    $0x20,%esp
  8008d7:	e9 f0 fb ff ff       	jmp    8004cc <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8008dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008df:	8d 50 04             	lea    0x4(%eax),%edx
  8008e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e5:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8008e7:	85 f6                	test   %esi,%esi
  8008e9:	75 1a                	jne    800905 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	68 f8 15 80 00       	push   $0x8015f8
  8008f3:	68 60 15 80 00       	push   $0x801560
  8008f8:	e8 18 f9 ff ff       	call   800215 <cprintf>
  8008fd:	83 c4 10             	add    $0x10,%esp
  800900:	e9 c7 fb ff ff       	jmp    8004cc <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800905:	0f b6 03             	movzbl (%ebx),%eax
  800908:	84 c0                	test   %al,%al
  80090a:	79 1f                	jns    80092b <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	68 30 16 80 00       	push   $0x801630
  800914:	68 60 15 80 00       	push   $0x801560
  800919:	e8 f7 f8 ff ff       	call   800215 <cprintf>
						*tmp = *(char *)putdat;
  80091e:	0f b6 03             	movzbl (%ebx),%eax
  800921:	88 06                	mov    %al,(%esi)
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	e9 a1 fb ff ff       	jmp    8004cc <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  80092b:	88 06                	mov    %al,(%esi)
  80092d:	e9 9a fb ff ff       	jmp    8004cc <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800932:	83 ec 08             	sub    $0x8,%esp
  800935:	53                   	push   %ebx
  800936:	52                   	push   %edx
  800937:	ff d7                	call   *%edi
			break;
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	e9 8b fb ff ff       	jmp    8004cc <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800941:	83 ec 08             	sub    $0x8,%esp
  800944:	53                   	push   %ebx
  800945:	6a 25                	push   $0x25
  800947:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800949:	83 c4 10             	add    $0x10,%esp
  80094c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800950:	0f 84 73 fb ff ff    	je     8004c9 <vprintfmt+0x11>
  800956:	83 ee 01             	sub    $0x1,%esi
  800959:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80095d:	75 f7                	jne    800956 <vprintfmt+0x49e>
  80095f:	89 75 10             	mov    %esi,0x10(%ebp)
  800962:	e9 65 fb ff ff       	jmp    8004cc <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800967:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80096a:	8d 70 01             	lea    0x1(%eax),%esi
  80096d:	0f b6 00             	movzbl (%eax),%eax
  800970:	0f be d0             	movsbl %al,%edx
  800973:	85 d2                	test   %edx,%edx
  800975:	0f 85 cf fd ff ff    	jne    80074a <vprintfmt+0x292>
  80097b:	e9 4c fb ff ff       	jmp    8004cc <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800980:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 18             	sub    $0x18,%esp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800994:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800997:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80099b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80099e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a5:	85 c0                	test   %eax,%eax
  8009a7:	74 26                	je     8009cf <vsnprintf+0x47>
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	7e 22                	jle    8009cf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ad:	ff 75 14             	pushl  0x14(%ebp)
  8009b0:	ff 75 10             	pushl  0x10(%ebp)
  8009b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b6:	50                   	push   %eax
  8009b7:	68 7e 04 80 00       	push   $0x80047e
  8009bc:	e8 f7 fa ff ff       	call   8004b8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ca:	83 c4 10             	add    $0x10,%esp
  8009cd:	eb 05                	jmp    8009d4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009df:	50                   	push   %eax
  8009e0:	ff 75 10             	pushl  0x10(%ebp)
  8009e3:	ff 75 0c             	pushl  0xc(%ebp)
  8009e6:	ff 75 08             	pushl  0x8(%ebp)
  8009e9:	e8 9a ff ff ff       	call   800988 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	80 3a 00             	cmpb   $0x0,(%edx)
  8009f9:	74 10                	je     800a0b <strlen+0x1b>
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a07:	75 f7                	jne    800a00 <strlen+0x10>
  800a09:	eb 05                	jmp    800a10 <strlen+0x20>
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1c:	85 c9                	test   %ecx,%ecx
  800a1e:	74 1c                	je     800a3c <strnlen+0x2a>
  800a20:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a23:	74 1e                	je     800a43 <strnlen+0x31>
  800a25:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a2a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2c:	39 ca                	cmp    %ecx,%edx
  800a2e:	74 18                	je     800a48 <strnlen+0x36>
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a38:	75 f0                	jne    800a2a <strnlen+0x18>
  800a3a:	eb 0c                	jmp    800a48 <strnlen+0x36>
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	eb 05                	jmp    800a48 <strnlen+0x36>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a61:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a64:	84 db                	test   %bl,%bl
  800a66:	75 ef                	jne    800a57 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a68:	5b                   	pop    %ebx
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a72:	53                   	push   %ebx
  800a73:	e8 78 ff ff ff       	call   8009f0 <strlen>
  800a78:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a7b:	ff 75 0c             	pushl  0xc(%ebp)
  800a7e:	01 d8                	add    %ebx,%eax
  800a80:	50                   	push   %eax
  800a81:	e8 c5 ff ff ff       	call   800a4b <strcpy>
	return dst;
}
  800a86:	89 d8                	mov    %ebx,%eax
  800a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 75 08             	mov    0x8(%ebp),%esi
  800a95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	74 17                	je     800ab6 <strncpy+0x29>
  800a9f:	01 f3                	add    %esi,%ebx
  800aa1:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	0f b6 02             	movzbl (%edx),%eax
  800aa9:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aac:	80 3a 01             	cmpb   $0x1,(%edx)
  800aaf:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab2:	39 cb                	cmp    %ecx,%ebx
  800ab4:	75 ed                	jne    800aa3 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ab6:	89 f0                	mov    %esi,%eax
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac7:	8b 55 10             	mov    0x10(%ebp),%edx
  800aca:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800acc:	85 d2                	test   %edx,%edx
  800ace:	74 35                	je     800b05 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800ad0:	89 d0                	mov    %edx,%eax
  800ad2:	83 e8 01             	sub    $0x1,%eax
  800ad5:	74 25                	je     800afc <strlcpy+0x40>
  800ad7:	0f b6 0b             	movzbl (%ebx),%ecx
  800ada:	84 c9                	test   %cl,%cl
  800adc:	74 22                	je     800b00 <strlcpy+0x44>
  800ade:	8d 53 01             	lea    0x1(%ebx),%edx
  800ae1:	01 c3                	add    %eax,%ebx
  800ae3:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ae5:	83 c0 01             	add    $0x1,%eax
  800ae8:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aeb:	39 da                	cmp    %ebx,%edx
  800aed:	74 13                	je     800b02 <strlcpy+0x46>
  800aef:	83 c2 01             	add    $0x1,%edx
  800af2:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800af6:	84 c9                	test   %cl,%cl
  800af8:	75 eb                	jne    800ae5 <strlcpy+0x29>
  800afa:	eb 06                	jmp    800b02 <strlcpy+0x46>
  800afc:	89 f0                	mov    %esi,%eax
  800afe:	eb 02                	jmp    800b02 <strlcpy+0x46>
  800b00:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b02:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b05:	29 f0                	sub    %esi,%eax
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b11:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b14:	0f b6 01             	movzbl (%ecx),%eax
  800b17:	84 c0                	test   %al,%al
  800b19:	74 15                	je     800b30 <strcmp+0x25>
  800b1b:	3a 02                	cmp    (%edx),%al
  800b1d:	75 11                	jne    800b30 <strcmp+0x25>
		p++, q++;
  800b1f:	83 c1 01             	add    $0x1,%ecx
  800b22:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b25:	0f b6 01             	movzbl (%ecx),%eax
  800b28:	84 c0                	test   %al,%al
  800b2a:	74 04                	je     800b30 <strcmp+0x25>
  800b2c:	3a 02                	cmp    (%edx),%al
  800b2e:	74 ef                	je     800b1f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b30:	0f b6 c0             	movzbl %al,%eax
  800b33:	0f b6 12             	movzbl (%edx),%edx
  800b36:	29 d0                	sub    %edx,%eax
}
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b45:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b48:	85 f6                	test   %esi,%esi
  800b4a:	74 29                	je     800b75 <strncmp+0x3b>
  800b4c:	0f b6 03             	movzbl (%ebx),%eax
  800b4f:	84 c0                	test   %al,%al
  800b51:	74 30                	je     800b83 <strncmp+0x49>
  800b53:	3a 02                	cmp    (%edx),%al
  800b55:	75 2c                	jne    800b83 <strncmp+0x49>
  800b57:	8d 43 01             	lea    0x1(%ebx),%eax
  800b5a:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b5c:	89 c3                	mov    %eax,%ebx
  800b5e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b61:	39 c6                	cmp    %eax,%esi
  800b63:	74 17                	je     800b7c <strncmp+0x42>
  800b65:	0f b6 08             	movzbl (%eax),%ecx
  800b68:	84 c9                	test   %cl,%cl
  800b6a:	74 17                	je     800b83 <strncmp+0x49>
  800b6c:	83 c0 01             	add    $0x1,%eax
  800b6f:	3a 0a                	cmp    (%edx),%cl
  800b71:	74 e9                	je     800b5c <strncmp+0x22>
  800b73:	eb 0e                	jmp    800b83 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	eb 0f                	jmp    800b8b <strncmp+0x51>
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	eb 08                	jmp    800b8b <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b83:	0f b6 03             	movzbl (%ebx),%eax
  800b86:	0f b6 12             	movzbl (%edx),%edx
  800b89:	29 d0                	sub    %edx,%eax
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	53                   	push   %ebx
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
  800b96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b99:	0f b6 10             	movzbl (%eax),%edx
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	74 1d                	je     800bbd <strchr+0x2e>
  800ba0:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ba2:	38 d3                	cmp    %dl,%bl
  800ba4:	75 06                	jne    800bac <strchr+0x1d>
  800ba6:	eb 1a                	jmp    800bc2 <strchr+0x33>
  800ba8:	38 ca                	cmp    %cl,%dl
  800baa:	74 16                	je     800bc2 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bac:	83 c0 01             	add    $0x1,%eax
  800baf:	0f b6 10             	movzbl (%eax),%edx
  800bb2:	84 d2                	test   %dl,%dl
  800bb4:	75 f2                	jne    800ba8 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	eb 05                	jmp    800bc2 <strchr+0x33>
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	53                   	push   %ebx
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bcf:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bd2:	38 d3                	cmp    %dl,%bl
  800bd4:	74 14                	je     800bea <strfind+0x25>
  800bd6:	89 d1                	mov    %edx,%ecx
  800bd8:	84 db                	test   %bl,%bl
  800bda:	74 0e                	je     800bea <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bdc:	83 c0 01             	add    $0x1,%eax
  800bdf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be2:	38 ca                	cmp    %cl,%dl
  800be4:	74 04                	je     800bea <strfind+0x25>
  800be6:	84 d2                	test   %dl,%dl
  800be8:	75 f2                	jne    800bdc <strfind+0x17>
			break;
	return (char *) s;
}
  800bea:	5b                   	pop    %ebx
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf9:	85 c9                	test   %ecx,%ecx
  800bfb:	74 36                	je     800c33 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bfd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c03:	75 28                	jne    800c2d <memset+0x40>
  800c05:	f6 c1 03             	test   $0x3,%cl
  800c08:	75 23                	jne    800c2d <memset+0x40>
		c &= 0xFF;
  800c0a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c0e:	89 d3                	mov    %edx,%ebx
  800c10:	c1 e3 08             	shl    $0x8,%ebx
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	c1 e6 18             	shl    $0x18,%esi
  800c18:	89 d0                	mov    %edx,%eax
  800c1a:	c1 e0 10             	shl    $0x10,%eax
  800c1d:	09 f0                	or     %esi,%eax
  800c1f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c21:	89 d8                	mov    %ebx,%eax
  800c23:	09 d0                	or     %edx,%eax
  800c25:	c1 e9 02             	shr    $0x2,%ecx
  800c28:	fc                   	cld    
  800c29:	f3 ab                	rep stos %eax,%es:(%edi)
  800c2b:	eb 06                	jmp    800c33 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c30:	fc                   	cld    
  800c31:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c33:	89 f8                	mov    %edi,%eax
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c48:	39 c6                	cmp    %eax,%esi
  800c4a:	73 35                	jae    800c81 <memmove+0x47>
  800c4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4f:	39 d0                	cmp    %edx,%eax
  800c51:	73 2e                	jae    800c81 <memmove+0x47>
		s += n;
		d += n;
  800c53:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	89 d6                	mov    %edx,%esi
  800c58:	09 fe                	or     %edi,%esi
  800c5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c60:	75 13                	jne    800c75 <memmove+0x3b>
  800c62:	f6 c1 03             	test   $0x3,%cl
  800c65:	75 0e                	jne    800c75 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c67:	83 ef 04             	sub    $0x4,%edi
  800c6a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c6d:	c1 e9 02             	shr    $0x2,%ecx
  800c70:	fd                   	std    
  800c71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c73:	eb 09                	jmp    800c7e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c75:	83 ef 01             	sub    $0x1,%edi
  800c78:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c7b:	fd                   	std    
  800c7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7e:	fc                   	cld    
  800c7f:	eb 1d                	jmp    800c9e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c81:	89 f2                	mov    %esi,%edx
  800c83:	09 c2                	or     %eax,%edx
  800c85:	f6 c2 03             	test   $0x3,%dl
  800c88:	75 0f                	jne    800c99 <memmove+0x5f>
  800c8a:	f6 c1 03             	test   $0x3,%cl
  800c8d:	75 0a                	jne    800c99 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c8f:	c1 e9 02             	shr    $0x2,%ecx
  800c92:	89 c7                	mov    %eax,%edi
  800c94:	fc                   	cld    
  800c95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c97:	eb 05                	jmp    800c9e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c99:	89 c7                	mov    %eax,%edi
  800c9b:	fc                   	cld    
  800c9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ca5:	ff 75 10             	pushl  0x10(%ebp)
  800ca8:	ff 75 0c             	pushl  0xc(%ebp)
  800cab:	ff 75 08             	pushl  0x8(%ebp)
  800cae:	e8 87 ff ff ff       	call   800c3a <memmove>
}
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cbe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc1:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	74 39                	je     800d01 <memcmp+0x4c>
  800cc8:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ccb:	0f b6 13             	movzbl (%ebx),%edx
  800cce:	0f b6 0e             	movzbl (%esi),%ecx
  800cd1:	38 ca                	cmp    %cl,%dl
  800cd3:	75 17                	jne    800cec <memcmp+0x37>
  800cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cda:	eb 1a                	jmp    800cf6 <memcmp+0x41>
  800cdc:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800ce1:	83 c0 01             	add    $0x1,%eax
  800ce4:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800ce8:	38 ca                	cmp    %cl,%dl
  800cea:	74 0a                	je     800cf6 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cec:	0f b6 c2             	movzbl %dl,%eax
  800cef:	0f b6 c9             	movzbl %cl,%ecx
  800cf2:	29 c8                	sub    %ecx,%eax
  800cf4:	eb 10                	jmp    800d06 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf6:	39 f8                	cmp    %edi,%eax
  800cf8:	75 e2                	jne    800cdc <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800cff:	eb 05                	jmp    800d06 <memcmp+0x51>
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	53                   	push   %ebx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d12:	89 d0                	mov    %edx,%eax
  800d14:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d17:	39 c2                	cmp    %eax,%edx
  800d19:	73 1d                	jae    800d38 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d1f:	0f b6 0a             	movzbl (%edx),%ecx
  800d22:	39 d9                	cmp    %ebx,%ecx
  800d24:	75 09                	jne    800d2f <memfind+0x24>
  800d26:	eb 14                	jmp    800d3c <memfind+0x31>
  800d28:	0f b6 0a             	movzbl (%edx),%ecx
  800d2b:	39 d9                	cmp    %ebx,%ecx
  800d2d:	74 11                	je     800d40 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d2f:	83 c2 01             	add    $0x1,%edx
  800d32:	39 d0                	cmp    %edx,%eax
  800d34:	75 f2                	jne    800d28 <memfind+0x1d>
  800d36:	eb 0a                	jmp    800d42 <memfind+0x37>
  800d38:	89 d0                	mov    %edx,%eax
  800d3a:	eb 06                	jmp    800d42 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d3c:	89 d0                	mov    %edx,%eax
  800d3e:	eb 02                	jmp    800d42 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d40:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d42:	5b                   	pop    %ebx
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d51:	0f b6 01             	movzbl (%ecx),%eax
  800d54:	3c 20                	cmp    $0x20,%al
  800d56:	74 04                	je     800d5c <strtol+0x17>
  800d58:	3c 09                	cmp    $0x9,%al
  800d5a:	75 0e                	jne    800d6a <strtol+0x25>
		s++;
  800d5c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5f:	0f b6 01             	movzbl (%ecx),%eax
  800d62:	3c 20                	cmp    $0x20,%al
  800d64:	74 f6                	je     800d5c <strtol+0x17>
  800d66:	3c 09                	cmp    $0x9,%al
  800d68:	74 f2                	je     800d5c <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d6a:	3c 2b                	cmp    $0x2b,%al
  800d6c:	75 0a                	jne    800d78 <strtol+0x33>
		s++;
  800d6e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d71:	bf 00 00 00 00       	mov    $0x0,%edi
  800d76:	eb 11                	jmp    800d89 <strtol+0x44>
  800d78:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d7d:	3c 2d                	cmp    $0x2d,%al
  800d7f:	75 08                	jne    800d89 <strtol+0x44>
		s++, neg = 1;
  800d81:	83 c1 01             	add    $0x1,%ecx
  800d84:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d89:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d8f:	75 15                	jne    800da6 <strtol+0x61>
  800d91:	80 39 30             	cmpb   $0x30,(%ecx)
  800d94:	75 10                	jne    800da6 <strtol+0x61>
  800d96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d9a:	75 7c                	jne    800e18 <strtol+0xd3>
		s += 2, base = 16;
  800d9c:	83 c1 02             	add    $0x2,%ecx
  800d9f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800da4:	eb 16                	jmp    800dbc <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800da6:	85 db                	test   %ebx,%ebx
  800da8:	75 12                	jne    800dbc <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800daa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800daf:	80 39 30             	cmpb   $0x30,(%ecx)
  800db2:	75 08                	jne    800dbc <strtol+0x77>
		s++, base = 8;
  800db4:	83 c1 01             	add    $0x1,%ecx
  800db7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800dbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc4:	0f b6 11             	movzbl (%ecx),%edx
  800dc7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dca:	89 f3                	mov    %esi,%ebx
  800dcc:	80 fb 09             	cmp    $0x9,%bl
  800dcf:	77 08                	ja     800dd9 <strtol+0x94>
			dig = *s - '0';
  800dd1:	0f be d2             	movsbl %dl,%edx
  800dd4:	83 ea 30             	sub    $0x30,%edx
  800dd7:	eb 22                	jmp    800dfb <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800dd9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ddc:	89 f3                	mov    %esi,%ebx
  800dde:	80 fb 19             	cmp    $0x19,%bl
  800de1:	77 08                	ja     800deb <strtol+0xa6>
			dig = *s - 'a' + 10;
  800de3:	0f be d2             	movsbl %dl,%edx
  800de6:	83 ea 57             	sub    $0x57,%edx
  800de9:	eb 10                	jmp    800dfb <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800deb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dee:	89 f3                	mov    %esi,%ebx
  800df0:	80 fb 19             	cmp    $0x19,%bl
  800df3:	77 16                	ja     800e0b <strtol+0xc6>
			dig = *s - 'A' + 10;
  800df5:	0f be d2             	movsbl %dl,%edx
  800df8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800dfb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dfe:	7d 0b                	jge    800e0b <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e00:	83 c1 01             	add    $0x1,%ecx
  800e03:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e07:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e09:	eb b9                	jmp    800dc4 <strtol+0x7f>

	if (endptr)
  800e0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e0f:	74 0d                	je     800e1e <strtol+0xd9>
		*endptr = (char *) s;
  800e11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e14:	89 0e                	mov    %ecx,(%esi)
  800e16:	eb 06                	jmp    800e1e <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e18:	85 db                	test   %ebx,%ebx
  800e1a:	74 98                	je     800db4 <strtol+0x6f>
  800e1c:	eb 9e                	jmp    800dbc <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	f7 da                	neg    %edx
  800e22:	85 ff                	test   %edi,%edi
  800e24:	0f 45 c2             	cmovne %edx,%eax
}
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	89 c3                	mov    %eax,%ebx
  800e3e:	89 c7                	mov    %eax,%edi
  800e40:	51                   	push   %ecx
  800e41:	52                   	push   %edx
  800e42:	53                   	push   %ebx
  800e43:	56                   	push   %esi
  800e44:	57                   	push   %edi
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	8d 35 50 0e 80 00    	lea    0x800e50,%esi
  800e4e:	0f 34                	sysenter 

00800e50 <label_21>:
  800e50:	89 ec                	mov    %ebp,%esp
  800e52:	5d                   	pop    %ebp
  800e53:	5f                   	pop    %edi
  800e54:	5e                   	pop    %esi
  800e55:	5b                   	pop    %ebx
  800e56:	5a                   	pop    %edx
  800e57:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e58:	5b                   	pop    %ebx
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_cgetc>:

int
sys_cgetc(void)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	89 ca                	mov    %ecx,%edx
  800e6d:	89 cb                	mov    %ecx,%ebx
  800e6f:	89 cf                	mov    %ecx,%edi
  800e71:	51                   	push   %ecx
  800e72:	52                   	push   %edx
  800e73:	53                   	push   %ebx
  800e74:	56                   	push   %esi
  800e75:	57                   	push   %edi
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	8d 35 81 0e 80 00    	lea    0x800e81,%esi
  800e7f:	0f 34                	sysenter 

00800e81 <label_55>:
  800e81:	89 ec                	mov    %ebp,%esp
  800e83:	5d                   	pop    %ebp
  800e84:	5f                   	pop    %edi
  800e85:	5e                   	pop    %esi
  800e86:	5b                   	pop    %ebx
  800e87:	5a                   	pop    %edx
  800e88:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e89:	5b                   	pop    %ebx
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e97:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 d9                	mov    %ebx,%ecx
  800ea1:	89 df                	mov    %ebx,%edi
  800ea3:	51                   	push   %ecx
  800ea4:	52                   	push   %edx
  800ea5:	53                   	push   %ebx
  800ea6:	56                   	push   %esi
  800ea7:	57                   	push   %edi
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	8d 35 b3 0e 80 00    	lea    0x800eb3,%esi
  800eb1:	0f 34                	sysenter 

00800eb3 <label_90>:
  800eb3:	89 ec                	mov    %ebp,%esp
  800eb5:	5d                   	pop    %ebp
  800eb6:	5f                   	pop    %edi
  800eb7:	5e                   	pop    %esi
  800eb8:	5b                   	pop    %ebx
  800eb9:	5a                   	pop    %edx
  800eba:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	7e 17                	jle    800ed6 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	50                   	push   %eax
  800ec3:	6a 03                	push   $0x3
  800ec5:	68 04 18 80 00       	push   $0x801804
  800eca:	6a 29                	push   $0x29
  800ecc:	68 21 18 80 00       	push   $0x801821
  800ed1:	e8 4c f2 ff ff       	call   800122 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ed6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ee2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee7:	b8 02 00 00 00       	mov    $0x2,%eax
  800eec:	89 ca                	mov    %ecx,%edx
  800eee:	89 cb                	mov    %ecx,%ebx
  800ef0:	89 cf                	mov    %ecx,%edi
  800ef2:	51                   	push   %ecx
  800ef3:	52                   	push   %edx
  800ef4:	53                   	push   %ebx
  800ef5:	56                   	push   %esi
  800ef6:	57                   	push   %edi
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	8d 35 02 0f 80 00    	lea    0x800f02,%esi
  800f00:	0f 34                	sysenter 

00800f02 <label_139>:
  800f02:	89 ec                	mov    %ebp,%esp
  800f04:	5d                   	pop    %ebp
  800f05:	5f                   	pop    %edi
  800f06:	5e                   	pop    %esi
  800f07:	5b                   	pop    %ebx
  800f08:	5a                   	pop    %edx
  800f09:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f0a:	5b                   	pop    %ebx
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	57                   	push   %edi
  800f12:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f13:	bf 00 00 00 00       	mov    $0x0,%edi
  800f18:	b8 04 00 00 00       	mov    $0x4,%eax
  800f1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	89 fb                	mov    %edi,%ebx
  800f25:	51                   	push   %ecx
  800f26:	52                   	push   %edx
  800f27:	53                   	push   %ebx
  800f28:	56                   	push   %esi
  800f29:	57                   	push   %edi
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	8d 35 35 0f 80 00    	lea    0x800f35,%esi
  800f33:	0f 34                	sysenter 

00800f35 <label_174>:
  800f35:	89 ec                	mov    %ebp,%esp
  800f37:	5d                   	pop    %ebp
  800f38:	5f                   	pop    %edi
  800f39:	5e                   	pop    %esi
  800f3a:	5b                   	pop    %ebx
  800f3b:	5a                   	pop    %edx
  800f3c:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f3d:	5b                   	pop    %ebx
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <sys_yield>:

void
sys_yield(void)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	57                   	push   %edi
  800f45:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f46:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f50:	89 d1                	mov    %edx,%ecx
  800f52:	89 d3                	mov    %edx,%ebx
  800f54:	89 d7                	mov    %edx,%edi
  800f56:	51                   	push   %ecx
  800f57:	52                   	push   %edx
  800f58:	53                   	push   %ebx
  800f59:	56                   	push   %esi
  800f5a:	57                   	push   %edi
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	8d 35 66 0f 80 00    	lea    0x800f66,%esi
  800f64:	0f 34                	sysenter 

00800f66 <label_209>:
  800f66:	89 ec                	mov    %ebp,%esp
  800f68:	5d                   	pop    %ebp
  800f69:	5f                   	pop    %edi
  800f6a:	5e                   	pop    %esi
  800f6b:	5b                   	pop    %ebx
  800f6c:	5a                   	pop    %edx
  800f6d:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f6e:	5b                   	pop    %ebx
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f77:	bf 00 00 00 00       	mov    $0x0,%edi
  800f7c:	b8 05 00 00 00       	mov    $0x5,%eax
  800f81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f84:	8b 55 08             	mov    0x8(%ebp),%edx
  800f87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8a:	51                   	push   %ecx
  800f8b:	52                   	push   %edx
  800f8c:	53                   	push   %ebx
  800f8d:	56                   	push   %esi
  800f8e:	57                   	push   %edi
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	8d 35 9a 0f 80 00    	lea    0x800f9a,%esi
  800f98:	0f 34                	sysenter 

00800f9a <label_244>:
  800f9a:	89 ec                	mov    %ebp,%esp
  800f9c:	5d                   	pop    %ebp
  800f9d:	5f                   	pop    %edi
  800f9e:	5e                   	pop    %esi
  800f9f:	5b                   	pop    %ebx
  800fa0:	5a                   	pop    %edx
  800fa1:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	7e 17                	jle    800fbd <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	50                   	push   %eax
  800faa:	6a 05                	push   $0x5
  800fac:	68 04 18 80 00       	push   $0x801804
  800fb1:	6a 29                	push   $0x29
  800fb3:	68 21 18 80 00       	push   $0x801821
  800fb8:	e8 65 f1 ff ff       	call   800122 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd5:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800fd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800fdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800fde:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800fe4:	8b 45 18             	mov    0x18(%ebp),%eax
  800fe7:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fea:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800fed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ff7:	89 cb                	mov    %ecx,%ebx
  800ff9:	89 cf                	mov    %ecx,%edi
  800ffb:	51                   	push   %ecx
  800ffc:	52                   	push   %edx
  800ffd:	53                   	push   %ebx
  800ffe:	56                   	push   %esi
  800fff:	57                   	push   %edi
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	8d 35 0b 10 80 00    	lea    0x80100b,%esi
  801009:	0f 34                	sysenter 

0080100b <label_304>:
  80100b:	89 ec                	mov    %ebp,%esp
  80100d:	5d                   	pop    %ebp
  80100e:	5f                   	pop    %edi
  80100f:	5e                   	pop    %esi
  801010:	5b                   	pop    %ebx
  801011:	5a                   	pop    %edx
  801012:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	7e 17                	jle    80102e <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	50                   	push   %eax
  80101b:	6a 06                	push   $0x6
  80101d:	68 04 18 80 00       	push   $0x801804
  801022:	6a 29                	push   $0x29
  801024:	68 21 18 80 00       	push   $0x801821
  801029:	e8 f4 f0 ff ff       	call   800122 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  80102e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801031:	5b                   	pop    %ebx
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	57                   	push   %edi
  801039:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80103a:	bf 00 00 00 00       	mov    $0x0,%edi
  80103f:	b8 07 00 00 00       	mov    $0x7,%eax
  801044:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801047:	8b 55 08             	mov    0x8(%ebp),%edx
  80104a:	89 fb                	mov    %edi,%ebx
  80104c:	51                   	push   %ecx
  80104d:	52                   	push   %edx
  80104e:	53                   	push   %ebx
  80104f:	56                   	push   %esi
  801050:	57                   	push   %edi
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	8d 35 5c 10 80 00    	lea    0x80105c,%esi
  80105a:	0f 34                	sysenter 

0080105c <label_353>:
  80105c:	89 ec                	mov    %ebp,%esp
  80105e:	5d                   	pop    %ebp
  80105f:	5f                   	pop    %edi
  801060:	5e                   	pop    %esi
  801061:	5b                   	pop    %ebx
  801062:	5a                   	pop    %edx
  801063:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801064:	85 c0                	test   %eax,%eax
  801066:	7e 17                	jle    80107f <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	50                   	push   %eax
  80106c:	6a 07                	push   $0x7
  80106e:	68 04 18 80 00       	push   $0x801804
  801073:	6a 29                	push   $0x29
  801075:	68 21 18 80 00       	push   $0x801821
  80107a:	e8 a3 f0 ff ff       	call   800122 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80107f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	57                   	push   %edi
  80108a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108b:	bf 00 00 00 00       	mov    $0x0,%edi
  801090:	b8 09 00 00 00       	mov    $0x9,%eax
  801095:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801098:	8b 55 08             	mov    0x8(%ebp),%edx
  80109b:	89 fb                	mov    %edi,%ebx
  80109d:	51                   	push   %ecx
  80109e:	52                   	push   %edx
  80109f:	53                   	push   %ebx
  8010a0:	56                   	push   %esi
  8010a1:	57                   	push   %edi
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	8d 35 ad 10 80 00    	lea    0x8010ad,%esi
  8010ab:	0f 34                	sysenter 

008010ad <label_402>:
  8010ad:	89 ec                	mov    %ebp,%esp
  8010af:	5d                   	pop    %ebp
  8010b0:	5f                   	pop    %edi
  8010b1:	5e                   	pop    %esi
  8010b2:	5b                   	pop    %ebx
  8010b3:	5a                   	pop    %edx
  8010b4:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	7e 17                	jle    8010d0 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	50                   	push   %eax
  8010bd:	6a 09                	push   $0x9
  8010bf:	68 04 18 80 00       	push   $0x801804
  8010c4:	6a 29                	push   $0x29
  8010c6:	68 21 18 80 00       	push   $0x801821
  8010cb:	e8 52 f0 ff ff       	call   800122 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8010e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ec:	89 fb                	mov    %edi,%ebx
  8010ee:	51                   	push   %ecx
  8010ef:	52                   	push   %edx
  8010f0:	53                   	push   %ebx
  8010f1:	56                   	push   %esi
  8010f2:	57                   	push   %edi
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	8d 35 fe 10 80 00    	lea    0x8010fe,%esi
  8010fc:	0f 34                	sysenter 

008010fe <label_451>:
  8010fe:	89 ec                	mov    %ebp,%esp
  801100:	5d                   	pop    %ebp
  801101:	5f                   	pop    %edi
  801102:	5e                   	pop    %esi
  801103:	5b                   	pop    %ebx
  801104:	5a                   	pop    %edx
  801105:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801106:	85 c0                	test   %eax,%eax
  801108:	7e 17                	jle    801121 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	50                   	push   %eax
  80110e:	6a 0a                	push   $0xa
  801110:	68 04 18 80 00       	push   $0x801804
  801115:	6a 29                	push   $0x29
  801117:	68 21 18 80 00       	push   $0x801821
  80111c:	e8 01 f0 ff ff       	call   800122 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801121:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	57                   	push   %edi
  80112c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80112d:	b8 0c 00 00 00       	mov    $0xc,%eax
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	8b 55 08             	mov    0x8(%ebp),%edx
  801138:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80113b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80113e:	51                   	push   %ecx
  80113f:	52                   	push   %edx
  801140:	53                   	push   %ebx
  801141:	56                   	push   %esi
  801142:	57                   	push   %edi
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	8d 35 4e 11 80 00    	lea    0x80114e,%esi
  80114c:	0f 34                	sysenter 

0080114e <label_502>:
  80114e:	89 ec                	mov    %ebp,%esp
  801150:	5d                   	pop    %ebp
  801151:	5f                   	pop    %edi
  801152:	5e                   	pop    %esi
  801153:	5b                   	pop    %ebx
  801154:	5a                   	pop    %edx
  801155:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801156:	5b                   	pop    %ebx
  801157:	5f                   	pop    %edi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	57                   	push   %edi
  80115e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80115f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801164:	b8 0d 00 00 00       	mov    $0xd,%eax
  801169:	8b 55 08             	mov    0x8(%ebp),%edx
  80116c:	89 d9                	mov    %ebx,%ecx
  80116e:	89 df                	mov    %ebx,%edi
  801170:	51                   	push   %ecx
  801171:	52                   	push   %edx
  801172:	53                   	push   %ebx
  801173:	56                   	push   %esi
  801174:	57                   	push   %edi
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	8d 35 80 11 80 00    	lea    0x801180,%esi
  80117e:	0f 34                	sysenter 

00801180 <label_537>:
  801180:	89 ec                	mov    %ebp,%esp
  801182:	5d                   	pop    %ebp
  801183:	5f                   	pop    %edi
  801184:	5e                   	pop    %esi
  801185:	5b                   	pop    %ebx
  801186:	5a                   	pop    %edx
  801187:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801188:	85 c0                	test   %eax,%eax
  80118a:	7e 17                	jle    8011a3 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	50                   	push   %eax
  801190:	6a 0d                	push   $0xd
  801192:	68 04 18 80 00       	push   $0x801804
  801197:	6a 29                	push   $0x29
  801199:	68 21 18 80 00       	push   $0x801821
  80119e:	e8 7f ef ff ff       	call   800122 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5f                   	pop    %edi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	57                   	push   %edi
  8011ae:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011b4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bc:	89 cb                	mov    %ecx,%ebx
  8011be:	89 cf                	mov    %ecx,%edi
  8011c0:	51                   	push   %ecx
  8011c1:	52                   	push   %edx
  8011c2:	53                   	push   %ebx
  8011c3:	56                   	push   %esi
  8011c4:	57                   	push   %edi
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	8d 35 d0 11 80 00    	lea    0x8011d0,%esi
  8011ce:	0f 34                	sysenter 

008011d0 <label_586>:
  8011d0:	89 ec                	mov    %ebp,%esp
  8011d2:	5d                   	pop    %ebp
  8011d3:	5f                   	pop    %edi
  8011d4:	5e                   	pop    %esi
  8011d5:	5b                   	pop    %ebx
  8011d6:	5a                   	pop    %edx
  8011d7:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011d8:	5b                   	pop    %ebx
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011e2:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  8011e9:	75 14                	jne    8011ff <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	68 30 18 80 00       	push   $0x801830
  8011f3:	6a 20                	push   $0x20
  8011f5:	68 54 18 80 00       	push   $0x801854
  8011fa:	e8 23 ef ff ff       	call   800122 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801202:	a3 14 20 80 00       	mov    %eax,0x802014
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    
  801209:	66 90                	xchg   %ax,%ax
  80120b:	66 90                	xchg   %ax,%ax
  80120d:	66 90                	xchg   %ax,%ax
  80120f:	90                   	nop

00801210 <__udivdi3>:
  801210:	55                   	push   %ebp
  801211:	57                   	push   %edi
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	83 ec 1c             	sub    $0x1c,%esp
  801217:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80121b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80121f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801227:	85 f6                	test   %esi,%esi
  801229:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80122d:	89 ca                	mov    %ecx,%edx
  80122f:	89 f8                	mov    %edi,%eax
  801231:	75 3d                	jne    801270 <__udivdi3+0x60>
  801233:	39 cf                	cmp    %ecx,%edi
  801235:	0f 87 c5 00 00 00    	ja     801300 <__udivdi3+0xf0>
  80123b:	85 ff                	test   %edi,%edi
  80123d:	89 fd                	mov    %edi,%ebp
  80123f:	75 0b                	jne    80124c <__udivdi3+0x3c>
  801241:	b8 01 00 00 00       	mov    $0x1,%eax
  801246:	31 d2                	xor    %edx,%edx
  801248:	f7 f7                	div    %edi
  80124a:	89 c5                	mov    %eax,%ebp
  80124c:	89 c8                	mov    %ecx,%eax
  80124e:	31 d2                	xor    %edx,%edx
  801250:	f7 f5                	div    %ebp
  801252:	89 c1                	mov    %eax,%ecx
  801254:	89 d8                	mov    %ebx,%eax
  801256:	89 cf                	mov    %ecx,%edi
  801258:	f7 f5                	div    %ebp
  80125a:	89 c3                	mov    %eax,%ebx
  80125c:	89 d8                	mov    %ebx,%eax
  80125e:	89 fa                	mov    %edi,%edx
  801260:	83 c4 1c             	add    $0x1c,%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    
  801268:	90                   	nop
  801269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801270:	39 ce                	cmp    %ecx,%esi
  801272:	77 74                	ja     8012e8 <__udivdi3+0xd8>
  801274:	0f bd fe             	bsr    %esi,%edi
  801277:	83 f7 1f             	xor    $0x1f,%edi
  80127a:	0f 84 98 00 00 00    	je     801318 <__udivdi3+0x108>
  801280:	bb 20 00 00 00       	mov    $0x20,%ebx
  801285:	89 f9                	mov    %edi,%ecx
  801287:	89 c5                	mov    %eax,%ebp
  801289:	29 fb                	sub    %edi,%ebx
  80128b:	d3 e6                	shl    %cl,%esi
  80128d:	89 d9                	mov    %ebx,%ecx
  80128f:	d3 ed                	shr    %cl,%ebp
  801291:	89 f9                	mov    %edi,%ecx
  801293:	d3 e0                	shl    %cl,%eax
  801295:	09 ee                	or     %ebp,%esi
  801297:	89 d9                	mov    %ebx,%ecx
  801299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80129d:	89 d5                	mov    %edx,%ebp
  80129f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012a3:	d3 ed                	shr    %cl,%ebp
  8012a5:	89 f9                	mov    %edi,%ecx
  8012a7:	d3 e2                	shl    %cl,%edx
  8012a9:	89 d9                	mov    %ebx,%ecx
  8012ab:	d3 e8                	shr    %cl,%eax
  8012ad:	09 c2                	or     %eax,%edx
  8012af:	89 d0                	mov    %edx,%eax
  8012b1:	89 ea                	mov    %ebp,%edx
  8012b3:	f7 f6                	div    %esi
  8012b5:	89 d5                	mov    %edx,%ebp
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	f7 64 24 0c          	mull   0xc(%esp)
  8012bd:	39 d5                	cmp    %edx,%ebp
  8012bf:	72 10                	jb     8012d1 <__udivdi3+0xc1>
  8012c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012c5:	89 f9                	mov    %edi,%ecx
  8012c7:	d3 e6                	shl    %cl,%esi
  8012c9:	39 c6                	cmp    %eax,%esi
  8012cb:	73 07                	jae    8012d4 <__udivdi3+0xc4>
  8012cd:	39 d5                	cmp    %edx,%ebp
  8012cf:	75 03                	jne    8012d4 <__udivdi3+0xc4>
  8012d1:	83 eb 01             	sub    $0x1,%ebx
  8012d4:	31 ff                	xor    %edi,%edi
  8012d6:	89 d8                	mov    %ebx,%eax
  8012d8:	89 fa                	mov    %edi,%edx
  8012da:	83 c4 1c             	add    $0x1c,%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5f                   	pop    %edi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    
  8012e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e8:	31 ff                	xor    %edi,%edi
  8012ea:	31 db                	xor    %ebx,%ebx
  8012ec:	89 d8                	mov    %ebx,%eax
  8012ee:	89 fa                	mov    %edi,%edx
  8012f0:	83 c4 1c             	add    $0x1c,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    
  8012f8:	90                   	nop
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	89 d8                	mov    %ebx,%eax
  801302:	f7 f7                	div    %edi
  801304:	31 ff                	xor    %edi,%edi
  801306:	89 c3                	mov    %eax,%ebx
  801308:	89 d8                	mov    %ebx,%eax
  80130a:	89 fa                	mov    %edi,%edx
  80130c:	83 c4 1c             	add    $0x1c,%esp
  80130f:	5b                   	pop    %ebx
  801310:	5e                   	pop    %esi
  801311:	5f                   	pop    %edi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    
  801314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801318:	39 ce                	cmp    %ecx,%esi
  80131a:	72 0c                	jb     801328 <__udivdi3+0x118>
  80131c:	31 db                	xor    %ebx,%ebx
  80131e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801322:	0f 87 34 ff ff ff    	ja     80125c <__udivdi3+0x4c>
  801328:	bb 01 00 00 00       	mov    $0x1,%ebx
  80132d:	e9 2a ff ff ff       	jmp    80125c <__udivdi3+0x4c>
  801332:	66 90                	xchg   %ax,%ax
  801334:	66 90                	xchg   %ax,%ax
  801336:	66 90                	xchg   %ax,%ax
  801338:	66 90                	xchg   %ax,%ax
  80133a:	66 90                	xchg   %ax,%ax
  80133c:	66 90                	xchg   %ax,%ax
  80133e:	66 90                	xchg   %ax,%ax

00801340 <__umoddi3>:
  801340:	55                   	push   %ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 1c             	sub    $0x1c,%esp
  801347:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80134b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80134f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801357:	85 d2                	test   %edx,%edx
  801359:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80135d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801361:	89 f3                	mov    %esi,%ebx
  801363:	89 3c 24             	mov    %edi,(%esp)
  801366:	89 74 24 04          	mov    %esi,0x4(%esp)
  80136a:	75 1c                	jne    801388 <__umoddi3+0x48>
  80136c:	39 f7                	cmp    %esi,%edi
  80136e:	76 50                	jbe    8013c0 <__umoddi3+0x80>
  801370:	89 c8                	mov    %ecx,%eax
  801372:	89 f2                	mov    %esi,%edx
  801374:	f7 f7                	div    %edi
  801376:	89 d0                	mov    %edx,%eax
  801378:	31 d2                	xor    %edx,%edx
  80137a:	83 c4 1c             	add    $0x1c,%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5f                   	pop    %edi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    
  801382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801388:	39 f2                	cmp    %esi,%edx
  80138a:	89 d0                	mov    %edx,%eax
  80138c:	77 52                	ja     8013e0 <__umoddi3+0xa0>
  80138e:	0f bd ea             	bsr    %edx,%ebp
  801391:	83 f5 1f             	xor    $0x1f,%ebp
  801394:	75 5a                	jne    8013f0 <__umoddi3+0xb0>
  801396:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80139a:	0f 82 e0 00 00 00    	jb     801480 <__umoddi3+0x140>
  8013a0:	39 0c 24             	cmp    %ecx,(%esp)
  8013a3:	0f 86 d7 00 00 00    	jbe    801480 <__umoddi3+0x140>
  8013a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013b1:	83 c4 1c             	add    $0x1c,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5f                   	pop    %edi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    
  8013b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	85 ff                	test   %edi,%edi
  8013c2:	89 fd                	mov    %edi,%ebp
  8013c4:	75 0b                	jne    8013d1 <__umoddi3+0x91>
  8013c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	f7 f7                	div    %edi
  8013cf:	89 c5                	mov    %eax,%ebp
  8013d1:	89 f0                	mov    %esi,%eax
  8013d3:	31 d2                	xor    %edx,%edx
  8013d5:	f7 f5                	div    %ebp
  8013d7:	89 c8                	mov    %ecx,%eax
  8013d9:	f7 f5                	div    %ebp
  8013db:	89 d0                	mov    %edx,%eax
  8013dd:	eb 99                	jmp    801378 <__umoddi3+0x38>
  8013df:	90                   	nop
  8013e0:	89 c8                	mov    %ecx,%eax
  8013e2:	89 f2                	mov    %esi,%edx
  8013e4:	83 c4 1c             	add    $0x1c,%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5f                   	pop    %edi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    
  8013ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f0:	8b 34 24             	mov    (%esp),%esi
  8013f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013f8:	89 e9                	mov    %ebp,%ecx
  8013fa:	29 ef                	sub    %ebp,%edi
  8013fc:	d3 e0                	shl    %cl,%eax
  8013fe:	89 f9                	mov    %edi,%ecx
  801400:	89 f2                	mov    %esi,%edx
  801402:	d3 ea                	shr    %cl,%edx
  801404:	89 e9                	mov    %ebp,%ecx
  801406:	09 c2                	or     %eax,%edx
  801408:	89 d8                	mov    %ebx,%eax
  80140a:	89 14 24             	mov    %edx,(%esp)
  80140d:	89 f2                	mov    %esi,%edx
  80140f:	d3 e2                	shl    %cl,%edx
  801411:	89 f9                	mov    %edi,%ecx
  801413:	89 54 24 04          	mov    %edx,0x4(%esp)
  801417:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80141b:	d3 e8                	shr    %cl,%eax
  80141d:	89 e9                	mov    %ebp,%ecx
  80141f:	89 c6                	mov    %eax,%esi
  801421:	d3 e3                	shl    %cl,%ebx
  801423:	89 f9                	mov    %edi,%ecx
  801425:	89 d0                	mov    %edx,%eax
  801427:	d3 e8                	shr    %cl,%eax
  801429:	89 e9                	mov    %ebp,%ecx
  80142b:	09 d8                	or     %ebx,%eax
  80142d:	89 d3                	mov    %edx,%ebx
  80142f:	89 f2                	mov    %esi,%edx
  801431:	f7 34 24             	divl   (%esp)
  801434:	89 d6                	mov    %edx,%esi
  801436:	d3 e3                	shl    %cl,%ebx
  801438:	f7 64 24 04          	mull   0x4(%esp)
  80143c:	39 d6                	cmp    %edx,%esi
  80143e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801442:	89 d1                	mov    %edx,%ecx
  801444:	89 c3                	mov    %eax,%ebx
  801446:	72 08                	jb     801450 <__umoddi3+0x110>
  801448:	75 11                	jne    80145b <__umoddi3+0x11b>
  80144a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80144e:	73 0b                	jae    80145b <__umoddi3+0x11b>
  801450:	2b 44 24 04          	sub    0x4(%esp),%eax
  801454:	1b 14 24             	sbb    (%esp),%edx
  801457:	89 d1                	mov    %edx,%ecx
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80145f:	29 da                	sub    %ebx,%edx
  801461:	19 ce                	sbb    %ecx,%esi
  801463:	89 f9                	mov    %edi,%ecx
  801465:	89 f0                	mov    %esi,%eax
  801467:	d3 e0                	shl    %cl,%eax
  801469:	89 e9                	mov    %ebp,%ecx
  80146b:	d3 ea                	shr    %cl,%edx
  80146d:	89 e9                	mov    %ebp,%ecx
  80146f:	d3 ee                	shr    %cl,%esi
  801471:	09 d0                	or     %edx,%eax
  801473:	89 f2                	mov    %esi,%edx
  801475:	83 c4 1c             	add    $0x1c,%esp
  801478:	5b                   	pop    %ebx
  801479:	5e                   	pop    %esi
  80147a:	5f                   	pop    %edi
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    
  80147d:	8d 76 00             	lea    0x0(%esi),%esi
  801480:	29 f9                	sub    %edi,%ecx
  801482:	19 d6                	sbb    %edx,%esi
  801484:	89 74 24 04          	mov    %esi,0x4(%esp)
  801488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80148c:	e9 18 ff ff ff       	jmp    8013a9 <__umoddi3+0x69>
