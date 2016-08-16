
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 80 14 80 00       	push   $0x801480
  800045:	e8 b6 01 00 00       	call   800200 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 ff 0e 00 00       	call   800f5d <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 a0 14 80 00       	push   $0x8014a0
  80006f:	6a 0f                	push   $0xf
  800071:	68 8a 14 80 00       	push   $0x80148a
  800076:	e8 92 00 00 00       	call   80010d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 14 80 00       	push   $0x8014cc
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 38 09 00 00       	call   8009c1 <snprintf>
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
  80009c:	e8 05 11 00 00       	call   8011a6 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 67 0d 00 00       	call   800e17 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c0:	e8 03 0e 00 00       	call   800ec8 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	c1 e0 07             	shl    $0x7,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 70 0d 00 00       	call   800e78 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800115:	a1 10 20 80 00       	mov    0x802010,%eax
  80011a:	85 c0                	test   %eax,%eax
  80011c:	74 11                	je     80012f <_panic+0x22>
		cprintf("%s: ", argv0);
  80011e:	83 ec 08             	sub    $0x8,%esp
  800121:	50                   	push   %eax
  800122:	68 f7 14 80 00       	push   $0x8014f7
  800127:	e8 d4 00 00 00       	call   800200 <cprintf>
  80012c:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800135:	e8 8e 0d 00 00       	call   800ec8 <sys_getenvid>
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	ff 75 0c             	pushl  0xc(%ebp)
  800140:	ff 75 08             	pushl  0x8(%ebp)
  800143:	56                   	push   %esi
  800144:	50                   	push   %eax
  800145:	68 fc 14 80 00       	push   $0x8014fc
  80014a:	e8 b1 00 00 00       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014f:	83 c4 18             	add    $0x18,%esp
  800152:	53                   	push   %ebx
  800153:	ff 75 10             	pushl  0x10(%ebp)
  800156:	e8 54 00 00 00       	call   8001af <vcprintf>
	cprintf("\n");
  80015b:	c7 04 24 88 14 80 00 	movl   $0x801488,(%esp)
  800162:	e8 99 00 00 00       	call   800200 <cprintf>
  800167:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016a:	cc                   	int3   
  80016b:	eb fd                	jmp    80016a <_panic+0x5d>

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 7a 0c 00 00       	call   800e17 <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 c0 02 00 00       	call   8004a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 1f 0c 00 00       	call   800e17 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80022d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800230:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800234:	0f 85 bf 00 00 00    	jne    8002f9 <printnum+0xe5>
  80023a:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800240:	0f 8d de 00 00 00    	jge    800324 <printnum+0x110>
		judge_time_for_space = width;
  800246:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  80024c:	e9 d3 00 00 00       	jmp    800324 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800251:	83 eb 01             	sub    $0x1,%ebx
  800254:	85 db                	test   %ebx,%ebx
  800256:	7f 37                	jg     80028f <printnum+0x7b>
  800258:	e9 ea 00 00 00       	jmp    800347 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80025d:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800260:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	ff 75 e4             	pushl  -0x1c(%ebp)
  800275:	ff 75 e0             	pushl  -0x20(%ebp)
  800278:	e8 93 10 00 00       	call   801310 <__umoddi3>
  80027d:	83 c4 14             	add    $0x14,%esp
  800280:	0f be 80 1f 15 80 00 	movsbl 0x80151f(%eax),%eax
  800287:	50                   	push   %eax
  800288:	ff d7                	call   *%edi
  80028a:	83 c4 10             	add    $0x10,%esp
  80028d:	eb 16                	jmp    8002a5 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	ff 75 18             	pushl  0x18(%ebp)
  800296:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800298:	83 c4 10             	add    $0x10,%esp
  80029b:	83 eb 01             	sub    $0x1,%ebx
  80029e:	75 ef                	jne    80028f <printnum+0x7b>
  8002a0:	e9 a2 00 00 00       	jmp    800347 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8002a5:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8002ab:	0f 85 76 01 00 00    	jne    800427 <printnum+0x213>
		while(num_of_space-- > 0)
  8002b1:	a1 04 20 80 00       	mov    0x802004,%eax
  8002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002b9:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 1d                	jle    8002e0 <printnum+0xcc>
			putch(' ', putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	56                   	push   %esi
  8002c7:	6a 20                	push   $0x20
  8002c9:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8002cb:	a1 04 20 80 00       	mov    0x802004,%eax
  8002d0:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002d3:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	7f e3                	jg     8002c3 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8002e0:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8002e7:	00 00 00 
		judge_time_for_space = 0;
  8002ea:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8002f1:	00 00 00 
	}
}
  8002f4:	e9 2e 01 00 00       	jmp    800427 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800301:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800304:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800307:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80030d:	83 fa 00             	cmp    $0x0,%edx
  800310:	0f 87 ba 00 00 00    	ja     8003d0 <printnum+0x1bc>
  800316:	3b 45 10             	cmp    0x10(%ebp),%eax
  800319:	0f 83 b1 00 00 00    	jae    8003d0 <printnum+0x1bc>
  80031f:	e9 2d ff ff ff       	jmp    800251 <printnum+0x3d>
  800324:	8b 45 10             	mov    0x10(%ebp),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
  80032c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800338:	83 fa 00             	cmp    $0x0,%edx
  80033b:	77 37                	ja     800374 <printnum+0x160>
  80033d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800340:	73 32                	jae    800374 <printnum+0x160>
  800342:	e9 16 ff ff ff       	jmp    80025d <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800347:	83 ec 08             	sub    $0x8,%esp
  80034a:	56                   	push   %esi
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	ff 75 e4             	pushl  -0x1c(%ebp)
  800357:	ff 75 e0             	pushl  -0x20(%ebp)
  80035a:	e8 b1 0f 00 00       	call   801310 <__umoddi3>
  80035f:	83 c4 14             	add    $0x14,%esp
  800362:	0f be 80 1f 15 80 00 	movsbl 0x80151f(%eax),%eax
  800369:	50                   	push   %eax
  80036a:	ff d7                	call   *%edi
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	e9 b3 00 00 00       	jmp    800427 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800374:	83 ec 0c             	sub    $0xc,%esp
  800377:	ff 75 18             	pushl  0x18(%ebp)
  80037a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80037d:	50                   	push   %eax
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	ff 75 dc             	pushl  -0x24(%ebp)
  800387:	ff 75 d8             	pushl  -0x28(%ebp)
  80038a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038d:	ff 75 e0             	pushl  -0x20(%ebp)
  800390:	e8 4b 0e 00 00       	call   8011e0 <__udivdi3>
  800395:	83 c4 18             	add    $0x18,%esp
  800398:	52                   	push   %edx
  800399:	50                   	push   %eax
  80039a:	89 f2                	mov    %esi,%edx
  80039c:	89 f8                	mov    %edi,%eax
  80039e:	e8 71 fe ff ff       	call   800214 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a3:	83 c4 18             	add    $0x18,%esp
  8003a6:	56                   	push   %esi
  8003a7:	83 ec 04             	sub    $0x4,%esp
  8003aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b6:	e8 55 0f 00 00       	call   801310 <__umoddi3>
  8003bb:	83 c4 14             	add    $0x14,%esp
  8003be:	0f be 80 1f 15 80 00 	movsbl 0x80151f(%eax),%eax
  8003c5:	50                   	push   %eax
  8003c6:	ff d7                	call   *%edi
  8003c8:	83 c4 10             	add    $0x10,%esp
  8003cb:	e9 d5 fe ff ff       	jmp    8002a5 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d0:	83 ec 0c             	sub    $0xc,%esp
  8003d3:	ff 75 18             	pushl  0x18(%ebp)
  8003d6:	83 eb 01             	sub    $0x1,%ebx
  8003d9:	53                   	push   %ebx
  8003da:	ff 75 10             	pushl  0x10(%ebp)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ec:	e8 ef 0d 00 00       	call   8011e0 <__udivdi3>
  8003f1:	83 c4 18             	add    $0x18,%esp
  8003f4:	52                   	push   %edx
  8003f5:	50                   	push   %eax
  8003f6:	89 f2                	mov    %esi,%edx
  8003f8:	89 f8                	mov    %edi,%eax
  8003fa:	e8 15 fe ff ff       	call   800214 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ff:	83 c4 18             	add    $0x18,%esp
  800402:	56                   	push   %esi
  800403:	83 ec 04             	sub    $0x4,%esp
  800406:	ff 75 dc             	pushl  -0x24(%ebp)
  800409:	ff 75 d8             	pushl  -0x28(%ebp)
  80040c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040f:	ff 75 e0             	pushl  -0x20(%ebp)
  800412:	e8 f9 0e 00 00       	call   801310 <__umoddi3>
  800417:	83 c4 14             	add    $0x14,%esp
  80041a:	0f be 80 1f 15 80 00 	movsbl 0x80151f(%eax),%eax
  800421:	50                   	push   %eax
  800422:	ff d7                	call   *%edi
  800424:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800427:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042a:	5b                   	pop    %ebx
  80042b:	5e                   	pop    %esi
  80042c:	5f                   	pop    %edi
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800432:	83 fa 01             	cmp    $0x1,%edx
  800435:	7e 0e                	jle    800445 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800437:	8b 10                	mov    (%eax),%edx
  800439:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043c:	89 08                	mov    %ecx,(%eax)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	8b 52 04             	mov    0x4(%edx),%edx
  800443:	eb 22                	jmp    800467 <getuint+0x38>
	else if (lflag)
  800445:	85 d2                	test   %edx,%edx
  800447:	74 10                	je     800459 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	ba 00 00 00 00       	mov    $0x0,%edx
  800457:	eb 0e                	jmp    800467 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045e:	89 08                	mov    %ecx,(%eax)
  800460:	8b 02                	mov    (%edx),%eax
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    

00800469 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800473:	8b 10                	mov    (%eax),%edx
  800475:	3b 50 04             	cmp    0x4(%eax),%edx
  800478:	73 0a                	jae    800484 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047d:	89 08                	mov    %ecx,(%eax)
  80047f:	8b 45 08             	mov    0x8(%ebp),%eax
  800482:	88 02                	mov    %al,(%edx)
}
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80048c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048f:	50                   	push   %eax
  800490:	ff 75 10             	pushl  0x10(%ebp)
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	ff 75 08             	pushl  0x8(%ebp)
  800499:	e8 05 00 00 00       	call   8004a3 <vprintfmt>
	va_end(ap);
}
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	c9                   	leave  
  8004a2:	c3                   	ret    

008004a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a3:	55                   	push   %ebp
  8004a4:	89 e5                	mov    %esp,%ebp
  8004a6:	57                   	push   %edi
  8004a7:	56                   	push   %esi
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 2c             	sub    $0x2c,%esp
  8004ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b2:	eb 03                	jmp    8004b7 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004b4:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ba:	8d 70 01             	lea    0x1(%eax),%esi
  8004bd:	0f b6 00             	movzbl (%eax),%eax
  8004c0:	83 f8 25             	cmp    $0x25,%eax
  8004c3:	74 27                	je     8004ec <vprintfmt+0x49>
			if (ch == '\0')
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	75 0d                	jne    8004d6 <vprintfmt+0x33>
  8004c9:	e9 9d 04 00 00       	jmp    80096b <vprintfmt+0x4c8>
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	0f 84 95 04 00 00    	je     80096b <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	53                   	push   %ebx
  8004da:	50                   	push   %eax
  8004db:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004dd:	83 c6 01             	add    $0x1,%esi
  8004e0:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	83 f8 25             	cmp    $0x25,%eax
  8004ea:	75 e2                	jne    8004ce <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f1:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004f5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800503:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80050a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800511:	eb 08                	jmp    80051b <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800516:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8d 46 01             	lea    0x1(%esi),%eax
  80051e:	89 45 10             	mov    %eax,0x10(%ebp)
  800521:	0f b6 06             	movzbl (%esi),%eax
  800524:	0f b6 d0             	movzbl %al,%edx
  800527:	83 e8 23             	sub    $0x23,%eax
  80052a:	3c 55                	cmp    $0x55,%al
  80052c:	0f 87 fa 03 00 00    	ja     80092c <vprintfmt+0x489>
  800532:	0f b6 c0             	movzbl %al,%eax
  800535:	ff 24 85 60 16 80 00 	jmp    *0x801660(,%eax,4)
  80053c:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80053f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800543:	eb d6                	jmp    80051b <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800545:	8d 42 d0             	lea    -0x30(%edx),%eax
  800548:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80054b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80054f:	8d 50 d0             	lea    -0x30(%eax),%edx
  800552:	83 fa 09             	cmp    $0x9,%edx
  800555:	77 6b                	ja     8005c2 <vprintfmt+0x11f>
  800557:	8b 75 10             	mov    0x10(%ebp),%esi
  80055a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80055d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800560:	eb 09                	jmp    80056b <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800565:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800569:	eb b0                	jmp    80051b <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80056b:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80056e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800571:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800575:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800578:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80057b:	83 f9 09             	cmp    $0x9,%ecx
  80057e:	76 eb                	jbe    80056b <vprintfmt+0xc8>
  800580:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800583:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800586:	eb 3d                	jmp    8005c5 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800599:	eb 2a                	jmp    8005c5 <vprintfmt+0x122>
  80059b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a5:	0f 49 d0             	cmovns %eax,%edx
  8005a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 10             	mov    0x10(%ebp),%esi
  8005ae:	e9 68 ff ff ff       	jmp    80051b <vprintfmt+0x78>
  8005b3:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005bd:	e9 59 ff ff ff       	jmp    80051b <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c9:	0f 89 4c ff ff ff    	jns    80051b <vprintfmt+0x78>
				width = precision, precision = -1;
  8005cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005dc:	e9 3a ff ff ff       	jmp    80051b <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e1:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005e8:	e9 2e ff ff ff       	jmp    80051b <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	53                   	push   %ebx
  8005fa:	ff 30                	pushl  (%eax)
  8005fc:	ff d7                	call   *%edi
			break;
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	e9 b1 fe ff ff       	jmp    8004b7 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	99                   	cltd   
  800612:	31 d0                	xor    %edx,%eax
  800614:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800616:	83 f8 08             	cmp    $0x8,%eax
  800619:	7f 0b                	jg     800626 <vprintfmt+0x183>
  80061b:	8b 14 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%edx
  800622:	85 d2                	test   %edx,%edx
  800624:	75 15                	jne    80063b <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800626:	50                   	push   %eax
  800627:	68 37 15 80 00       	push   $0x801537
  80062c:	53                   	push   %ebx
  80062d:	57                   	push   %edi
  80062e:	e8 53 fe ff ff       	call   800486 <printfmt>
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	e9 7c fe ff ff       	jmp    8004b7 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80063b:	52                   	push   %edx
  80063c:	68 40 15 80 00       	push   $0x801540
  800641:	53                   	push   %ebx
  800642:	57                   	push   %edi
  800643:	e8 3e fe ff ff       	call   800486 <printfmt>
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	e9 67 fe ff ff       	jmp    8004b7 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 04             	lea    0x4(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)
  800659:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80065b:	85 c0                	test   %eax,%eax
  80065d:	b9 30 15 80 00       	mov    $0x801530,%ecx
  800662:	0f 45 c8             	cmovne %eax,%ecx
  800665:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800668:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066c:	7e 06                	jle    800674 <vprintfmt+0x1d1>
  80066e:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800672:	75 19                	jne    80068d <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800677:	8d 70 01             	lea    0x1(%eax),%esi
  80067a:	0f b6 00             	movzbl (%eax),%eax
  80067d:	0f be d0             	movsbl %al,%edx
  800680:	85 d2                	test   %edx,%edx
  800682:	0f 85 9f 00 00 00    	jne    800727 <vprintfmt+0x284>
  800688:	e9 8c 00 00 00       	jmp    800719 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	ff 75 d0             	pushl  -0x30(%ebp)
  800693:	ff 75 cc             	pushl  -0x34(%ebp)
  800696:	e8 62 03 00 00       	call   8009fd <strnlen>
  80069b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80069e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	0f 8e a6 02 00 00    	jle    800952 <vprintfmt+0x4af>
					putch(padc, putdat);
  8006ac:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b3:	89 cb                	mov    %ecx,%ebx
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	56                   	push   %esi
  8006bc:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	83 eb 01             	sub    $0x1,%ebx
  8006c4:	75 ef                	jne    8006b5 <vprintfmt+0x212>
  8006c6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cc:	e9 81 02 00 00       	jmp    800952 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d5:	74 1b                	je     8006f2 <vprintfmt+0x24f>
  8006d7:	0f be c0             	movsbl %al,%eax
  8006da:	83 e8 20             	sub    $0x20,%eax
  8006dd:	83 f8 5e             	cmp    $0x5e,%eax
  8006e0:	76 10                	jbe    8006f2 <vprintfmt+0x24f>
					putch('?', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	ff 75 0c             	pushl  0xc(%ebp)
  8006e8:	6a 3f                	push   $0x3f
  8006ea:	ff 55 08             	call   *0x8(%ebp)
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	eb 0d                	jmp    8006ff <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	52                   	push   %edx
  8006f9:	ff 55 08             	call   *0x8(%ebp)
  8006fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ff:	83 ef 01             	sub    $0x1,%edi
  800702:	83 c6 01             	add    $0x1,%esi
  800705:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800709:	0f be d0             	movsbl %al,%edx
  80070c:	85 d2                	test   %edx,%edx
  80070e:	75 31                	jne    800741 <vprintfmt+0x29e>
  800710:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800713:	8b 7d 08             	mov    0x8(%ebp),%edi
  800716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800719:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800720:	7f 33                	jg     800755 <vprintfmt+0x2b2>
  800722:	e9 90 fd ff ff       	jmp    8004b7 <vprintfmt+0x14>
  800727:	89 7d 08             	mov    %edi,0x8(%ebp)
  80072a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800733:	eb 0c                	jmp    800741 <vprintfmt+0x29e>
  800735:	89 7d 08             	mov    %edi,0x8(%ebp)
  800738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800741:	85 db                	test   %ebx,%ebx
  800743:	78 8c                	js     8006d1 <vprintfmt+0x22e>
  800745:	83 eb 01             	sub    $0x1,%ebx
  800748:	79 87                	jns    8006d1 <vprintfmt+0x22e>
  80074a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80074d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800750:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800753:	eb c4                	jmp    800719 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	53                   	push   %ebx
  800759:	6a 20                	push   $0x20
  80075b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	83 ee 01             	sub    $0x1,%esi
  800763:	75 f0                	jne    800755 <vprintfmt+0x2b2>
  800765:	e9 4d fd ff ff       	jmp    8004b7 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076a:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80076e:	7e 16                	jle    800786 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 50 08             	lea    0x8(%eax),%edx
  800776:	89 55 14             	mov    %edx,0x14(%ebp)
  800779:	8b 50 04             	mov    0x4(%eax),%edx
  80077c:	8b 00                	mov    (%eax),%eax
  80077e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800781:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800784:	eb 34                	jmp    8007ba <vprintfmt+0x317>
	else if (lflag)
  800786:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80078a:	74 18                	je     8007a4 <vprintfmt+0x301>
		return va_arg(*ap, long);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 50 04             	lea    0x4(%eax),%edx
  800792:	89 55 14             	mov    %edx,0x14(%ebp)
  800795:	8b 30                	mov    (%eax),%esi
  800797:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80079a:	89 f0                	mov    %esi,%eax
  80079c:	c1 f8 1f             	sar    $0x1f,%eax
  80079f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007a2:	eb 16                	jmp    8007ba <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8d 50 04             	lea    0x4(%eax),%edx
  8007aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ad:	8b 30                	mov    (%eax),%esi
  8007af:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007b2:	89 f0                	mov    %esi,%eax
  8007b4:	c1 f8 1f             	sar    $0x1f,%eax
  8007b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007c6:	85 d2                	test   %edx,%edx
  8007c8:	79 28                	jns    8007f2 <vprintfmt+0x34f>
				putch('-', putdat);
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	53                   	push   %ebx
  8007ce:	6a 2d                	push   $0x2d
  8007d0:	ff d7                	call   *%edi
				num = -(long long) num;
  8007d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007d8:	f7 d8                	neg    %eax
  8007da:	83 d2 00             	adc    $0x0,%edx
  8007dd:	f7 da                	neg    %edx
  8007df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e5:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8007e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ed:	e9 b2 00 00 00       	jmp    8008a4 <vprintfmt+0x401>
  8007f2:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8007f7:	85 c9                	test   %ecx,%ecx
  8007f9:	0f 84 a5 00 00 00    	je     8008a4 <vprintfmt+0x401>
				putch('+', putdat);
  8007ff:	83 ec 08             	sub    $0x8,%esp
  800802:	53                   	push   %ebx
  800803:	6a 2b                	push   $0x2b
  800805:	ff d7                	call   *%edi
  800807:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  80080a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080f:	e9 90 00 00 00       	jmp    8008a4 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800814:	85 c9                	test   %ecx,%ecx
  800816:	74 0b                	je     800823 <vprintfmt+0x380>
				putch('+', putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	6a 2b                	push   $0x2b
  80081e:	ff d7                	call   *%edi
  800820:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800823:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
  800829:	e8 01 fc ff ff       	call   80042f <getuint>
  80082e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800831:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800834:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800839:	eb 69                	jmp    8008a4 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	53                   	push   %ebx
  80083f:	6a 30                	push   $0x30
  800841:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800843:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 e1 fb ff ff       	call   80042f <getuint>
  80084e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800851:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800854:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800857:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80085c:	eb 46                	jmp    8008a4 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	53                   	push   %ebx
  800862:	6a 30                	push   $0x30
  800864:	ff d7                	call   *%edi
			putch('x', putdat);
  800866:	83 c4 08             	add    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	6a 78                	push   $0x78
  80086c:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8d 50 04             	lea    0x4(%eax),%edx
  800874:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800877:	8b 00                	mov    (%eax),%eax
  800879:	ba 00 00 00 00       	mov    $0x0,%edx
  80087e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800881:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800884:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800887:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088c:	eb 16                	jmp    8008a4 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800891:	8d 45 14             	lea    0x14(%ebp),%eax
  800894:	e8 96 fb ff ff       	call   80042f <getuint>
  800899:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80089f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a4:	83 ec 0c             	sub    $0xc,%esp
  8008a7:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008ab:	56                   	push   %esi
  8008ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008af:	50                   	push   %eax
  8008b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8008b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8008b6:	89 da                	mov    %ebx,%edx
  8008b8:	89 f8                	mov    %edi,%eax
  8008ba:	e8 55 f9 ff ff       	call   800214 <printnum>
			break;
  8008bf:	83 c4 20             	add    $0x20,%esp
  8008c2:	e9 f0 fb ff ff       	jmp    8004b7 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 50 04             	lea    0x4(%eax),%edx
  8008cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d0:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8008d2:	85 f6                	test   %esi,%esi
  8008d4:	75 1a                	jne    8008f0 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	68 d8 15 80 00       	push   $0x8015d8
  8008de:	68 40 15 80 00       	push   $0x801540
  8008e3:	e8 18 f9 ff ff       	call   800200 <cprintf>
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	e9 c7 fb ff ff       	jmp    8004b7 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8008f0:	0f b6 03             	movzbl (%ebx),%eax
  8008f3:	84 c0                	test   %al,%al
  8008f5:	79 1f                	jns    800916 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	68 10 16 80 00       	push   $0x801610
  8008ff:	68 40 15 80 00       	push   $0x801540
  800904:	e8 f7 f8 ff ff       	call   800200 <cprintf>
						*tmp = *(char *)putdat;
  800909:	0f b6 03             	movzbl (%ebx),%eax
  80090c:	88 06                	mov    %al,(%esi)
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	e9 a1 fb ff ff       	jmp    8004b7 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800916:	88 06                	mov    %al,(%esi)
  800918:	e9 9a fb ff ff       	jmp    8004b7 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	53                   	push   %ebx
  800921:	52                   	push   %edx
  800922:	ff d7                	call   *%edi
			break;
  800924:	83 c4 10             	add    $0x10,%esp
  800927:	e9 8b fb ff ff       	jmp    8004b7 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	53                   	push   %ebx
  800930:	6a 25                	push   $0x25
  800932:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80093b:	0f 84 73 fb ff ff    	je     8004b4 <vprintfmt+0x11>
  800941:	83 ee 01             	sub    $0x1,%esi
  800944:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800948:	75 f7                	jne    800941 <vprintfmt+0x49e>
  80094a:	89 75 10             	mov    %esi,0x10(%ebp)
  80094d:	e9 65 fb ff ff       	jmp    8004b7 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800952:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800955:	8d 70 01             	lea    0x1(%eax),%esi
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	0f be d0             	movsbl %al,%edx
  80095e:	85 d2                	test   %edx,%edx
  800960:	0f 85 cf fd ff ff    	jne    800735 <vprintfmt+0x292>
  800966:	e9 4c fb ff ff       	jmp    8004b7 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80096b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 18             	sub    $0x18,%esp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800982:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800986:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800989:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800990:	85 c0                	test   %eax,%eax
  800992:	74 26                	je     8009ba <vsnprintf+0x47>
  800994:	85 d2                	test   %edx,%edx
  800996:	7e 22                	jle    8009ba <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800998:	ff 75 14             	pushl  0x14(%ebp)
  80099b:	ff 75 10             	pushl  0x10(%ebp)
  80099e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a1:	50                   	push   %eax
  8009a2:	68 69 04 80 00       	push   $0x800469
  8009a7:	e8 f7 fa ff ff       	call   8004a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	eb 05                	jmp    8009bf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ca:	50                   	push   %eax
  8009cb:	ff 75 10             	pushl  0x10(%ebp)
  8009ce:	ff 75 0c             	pushl  0xc(%ebp)
  8009d1:	ff 75 08             	pushl  0x8(%ebp)
  8009d4:	e8 9a ff ff ff       	call   800973 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e1:	80 3a 00             	cmpb   $0x0,(%edx)
  8009e4:	74 10                	je     8009f6 <strlen+0x1b>
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009eb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f2:	75 f7                	jne    8009eb <strlen+0x10>
  8009f4:	eb 05                	jmp    8009fb <strlen+0x20>
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	53                   	push   %ebx
  800a01:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a07:	85 c9                	test   %ecx,%ecx
  800a09:	74 1c                	je     800a27 <strnlen+0x2a>
  800a0b:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a0e:	74 1e                	je     800a2e <strnlen+0x31>
  800a10:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a15:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a17:	39 ca                	cmp    %ecx,%edx
  800a19:	74 18                	je     800a33 <strnlen+0x36>
  800a1b:	83 c2 01             	add    $0x1,%edx
  800a1e:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a23:	75 f0                	jne    800a15 <strnlen+0x18>
  800a25:	eb 0c                	jmp    800a33 <strnlen+0x36>
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	eb 05                	jmp    800a33 <strnlen+0x36>
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a33:	5b                   	pop    %ebx
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	53                   	push   %ebx
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	83 c2 01             	add    $0x1,%edx
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a4c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a4f:	84 db                	test   %bl,%bl
  800a51:	75 ef                	jne    800a42 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5d:	53                   	push   %ebx
  800a5e:	e8 78 ff ff ff       	call   8009db <strlen>
  800a63:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a66:	ff 75 0c             	pushl  0xc(%ebp)
  800a69:	01 d8                	add    %ebx,%eax
  800a6b:	50                   	push   %eax
  800a6c:	e8 c5 ff ff ff       	call   800a36 <strcpy>
	return dst;
}
  800a71:	89 d8                	mov    %ebx,%eax
  800a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a86:	85 db                	test   %ebx,%ebx
  800a88:	74 17                	je     800aa1 <strncpy+0x29>
  800a8a:	01 f3                	add    %esi,%ebx
  800a8c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	0f b6 02             	movzbl (%edx),%eax
  800a94:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a97:	80 3a 01             	cmpb   $0x1,(%edx)
  800a9a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9d:	39 cb                	cmp    %ecx,%ebx
  800a9f:	75 ed                	jne    800a8e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa1:	89 f0                	mov    %esi,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 75 08             	mov    0x8(%ebp),%esi
  800aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab2:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab7:	85 d2                	test   %edx,%edx
  800ab9:	74 35                	je     800af0 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800abb:	89 d0                	mov    %edx,%eax
  800abd:	83 e8 01             	sub    $0x1,%eax
  800ac0:	74 25                	je     800ae7 <strlcpy+0x40>
  800ac2:	0f b6 0b             	movzbl (%ebx),%ecx
  800ac5:	84 c9                	test   %cl,%cl
  800ac7:	74 22                	je     800aeb <strlcpy+0x44>
  800ac9:	8d 53 01             	lea    0x1(%ebx),%edx
  800acc:	01 c3                	add    %eax,%ebx
  800ace:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad6:	39 da                	cmp    %ebx,%edx
  800ad8:	74 13                	je     800aed <strlcpy+0x46>
  800ada:	83 c2 01             	add    $0x1,%edx
  800add:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800ae1:	84 c9                	test   %cl,%cl
  800ae3:	75 eb                	jne    800ad0 <strlcpy+0x29>
  800ae5:	eb 06                	jmp    800aed <strlcpy+0x46>
  800ae7:	89 f0                	mov    %esi,%eax
  800ae9:	eb 02                	jmp    800aed <strlcpy+0x46>
  800aeb:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800af0:	29 f0                	sub    %esi,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aff:	0f b6 01             	movzbl (%ecx),%eax
  800b02:	84 c0                	test   %al,%al
  800b04:	74 15                	je     800b1b <strcmp+0x25>
  800b06:	3a 02                	cmp    (%edx),%al
  800b08:	75 11                	jne    800b1b <strcmp+0x25>
		p++, q++;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b10:	0f b6 01             	movzbl (%ecx),%eax
  800b13:	84 c0                	test   %al,%al
  800b15:	74 04                	je     800b1b <strcmp+0x25>
  800b17:	3a 02                	cmp    (%edx),%al
  800b19:	74 ef                	je     800b0a <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1b:	0f b6 c0             	movzbl %al,%eax
  800b1e:	0f b6 12             	movzbl (%edx),%edx
  800b21:	29 d0                	sub    %edx,%eax
}
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b30:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b33:	85 f6                	test   %esi,%esi
  800b35:	74 29                	je     800b60 <strncmp+0x3b>
  800b37:	0f b6 03             	movzbl (%ebx),%eax
  800b3a:	84 c0                	test   %al,%al
  800b3c:	74 30                	je     800b6e <strncmp+0x49>
  800b3e:	3a 02                	cmp    (%edx),%al
  800b40:	75 2c                	jne    800b6e <strncmp+0x49>
  800b42:	8d 43 01             	lea    0x1(%ebx),%eax
  800b45:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4c:	39 c6                	cmp    %eax,%esi
  800b4e:	74 17                	je     800b67 <strncmp+0x42>
  800b50:	0f b6 08             	movzbl (%eax),%ecx
  800b53:	84 c9                	test   %cl,%cl
  800b55:	74 17                	je     800b6e <strncmp+0x49>
  800b57:	83 c0 01             	add    $0x1,%eax
  800b5a:	3a 0a                	cmp    (%edx),%cl
  800b5c:	74 e9                	je     800b47 <strncmp+0x22>
  800b5e:	eb 0e                	jmp    800b6e <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
  800b65:	eb 0f                	jmp    800b76 <strncmp+0x51>
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	eb 08                	jmp    800b76 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6e:	0f b6 03             	movzbl (%ebx),%eax
  800b71:	0f b6 12             	movzbl (%edx),%edx
  800b74:	29 d0                	sub    %edx,%eax
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b84:	0f b6 10             	movzbl (%eax),%edx
  800b87:	84 d2                	test   %dl,%dl
  800b89:	74 1d                	je     800ba8 <strchr+0x2e>
  800b8b:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b8d:	38 d3                	cmp    %dl,%bl
  800b8f:	75 06                	jne    800b97 <strchr+0x1d>
  800b91:	eb 1a                	jmp    800bad <strchr+0x33>
  800b93:	38 ca                	cmp    %cl,%dl
  800b95:	74 16                	je     800bad <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b97:	83 c0 01             	add    $0x1,%eax
  800b9a:	0f b6 10             	movzbl (%eax),%edx
  800b9d:	84 d2                	test   %dl,%dl
  800b9f:	75 f2                	jne    800b93 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	eb 05                	jmp    800bad <strchr+0x33>
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bad:	5b                   	pop    %ebx
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	53                   	push   %ebx
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bba:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bbd:	38 d3                	cmp    %dl,%bl
  800bbf:	74 14                	je     800bd5 <strfind+0x25>
  800bc1:	89 d1                	mov    %edx,%ecx
  800bc3:	84 db                	test   %bl,%bl
  800bc5:	74 0e                	je     800bd5 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bcd:	38 ca                	cmp    %cl,%dl
  800bcf:	74 04                	je     800bd5 <strfind+0x25>
  800bd1:	84 d2                	test   %dl,%dl
  800bd3:	75 f2                	jne    800bc7 <strfind+0x17>
			break;
	return (char *) s;
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be4:	85 c9                	test   %ecx,%ecx
  800be6:	74 36                	je     800c1e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bee:	75 28                	jne    800c18 <memset+0x40>
  800bf0:	f6 c1 03             	test   $0x3,%cl
  800bf3:	75 23                	jne    800c18 <memset+0x40>
		c &= 0xFF;
  800bf5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf9:	89 d3                	mov    %edx,%ebx
  800bfb:	c1 e3 08             	shl    $0x8,%ebx
  800bfe:	89 d6                	mov    %edx,%esi
  800c00:	c1 e6 18             	shl    $0x18,%esi
  800c03:	89 d0                	mov    %edx,%eax
  800c05:	c1 e0 10             	shl    $0x10,%eax
  800c08:	09 f0                	or     %esi,%eax
  800c0a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c0c:	89 d8                	mov    %ebx,%eax
  800c0e:	09 d0                	or     %edx,%eax
  800c10:	c1 e9 02             	shr    $0x2,%ecx
  800c13:	fc                   	cld    
  800c14:	f3 ab                	rep stos %eax,%es:(%edi)
  800c16:	eb 06                	jmp    800c1e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1b:	fc                   	cld    
  800c1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c1e:	89 f8                	mov    %edi,%eax
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c33:	39 c6                	cmp    %eax,%esi
  800c35:	73 35                	jae    800c6c <memmove+0x47>
  800c37:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3a:	39 d0                	cmp    %edx,%eax
  800c3c:	73 2e                	jae    800c6c <memmove+0x47>
		s += n;
		d += n;
  800c3e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	09 fe                	or     %edi,%esi
  800c45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4b:	75 13                	jne    800c60 <memmove+0x3b>
  800c4d:	f6 c1 03             	test   $0x3,%cl
  800c50:	75 0e                	jne    800c60 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c52:	83 ef 04             	sub    $0x4,%edi
  800c55:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c58:	c1 e9 02             	shr    $0x2,%ecx
  800c5b:	fd                   	std    
  800c5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5e:	eb 09                	jmp    800c69 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c60:	83 ef 01             	sub    $0x1,%edi
  800c63:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c66:	fd                   	std    
  800c67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c69:	fc                   	cld    
  800c6a:	eb 1d                	jmp    800c89 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6c:	89 f2                	mov    %esi,%edx
  800c6e:	09 c2                	or     %eax,%edx
  800c70:	f6 c2 03             	test   $0x3,%dl
  800c73:	75 0f                	jne    800c84 <memmove+0x5f>
  800c75:	f6 c1 03             	test   $0x3,%cl
  800c78:	75 0a                	jne    800c84 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c7a:	c1 e9 02             	shr    $0x2,%ecx
  800c7d:	89 c7                	mov    %eax,%edi
  800c7f:	fc                   	cld    
  800c80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c82:	eb 05                	jmp    800c89 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c84:	89 c7                	mov    %eax,%edi
  800c86:	fc                   	cld    
  800c87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c90:	ff 75 10             	pushl  0x10(%ebp)
  800c93:	ff 75 0c             	pushl  0xc(%ebp)
  800c96:	ff 75 08             	pushl  0x8(%ebp)
  800c99:	e8 87 ff ff ff       	call   800c25 <memmove>
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ca9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cac:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	74 39                	je     800cec <memcmp+0x4c>
  800cb3:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cb6:	0f b6 13             	movzbl (%ebx),%edx
  800cb9:	0f b6 0e             	movzbl (%esi),%ecx
  800cbc:	38 ca                	cmp    %cl,%dl
  800cbe:	75 17                	jne    800cd7 <memcmp+0x37>
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc5:	eb 1a                	jmp    800ce1 <memcmp+0x41>
  800cc7:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800ccc:	83 c0 01             	add    $0x1,%eax
  800ccf:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cd3:	38 ca                	cmp    %cl,%dl
  800cd5:	74 0a                	je     800ce1 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cd7:	0f b6 c2             	movzbl %dl,%eax
  800cda:	0f b6 c9             	movzbl %cl,%ecx
  800cdd:	29 c8                	sub    %ecx,%eax
  800cdf:	eb 10                	jmp    800cf1 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce1:	39 f8                	cmp    %edi,%eax
  800ce3:	75 e2                	jne    800cc7 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cea:	eb 05                	jmp    800cf1 <memcmp+0x51>
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	53                   	push   %ebx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800cfd:	89 d0                	mov    %edx,%eax
  800cff:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d02:	39 c2                	cmp    %eax,%edx
  800d04:	73 1d                	jae    800d23 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d06:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d0a:	0f b6 0a             	movzbl (%edx),%ecx
  800d0d:	39 d9                	cmp    %ebx,%ecx
  800d0f:	75 09                	jne    800d1a <memfind+0x24>
  800d11:	eb 14                	jmp    800d27 <memfind+0x31>
  800d13:	0f b6 0a             	movzbl (%edx),%ecx
  800d16:	39 d9                	cmp    %ebx,%ecx
  800d18:	74 11                	je     800d2b <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d1a:	83 c2 01             	add    $0x1,%edx
  800d1d:	39 d0                	cmp    %edx,%eax
  800d1f:	75 f2                	jne    800d13 <memfind+0x1d>
  800d21:	eb 0a                	jmp    800d2d <memfind+0x37>
  800d23:	89 d0                	mov    %edx,%eax
  800d25:	eb 06                	jmp    800d2d <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d27:	89 d0                	mov    %edx,%eax
  800d29:	eb 02                	jmp    800d2d <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d2b:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3c:	0f b6 01             	movzbl (%ecx),%eax
  800d3f:	3c 20                	cmp    $0x20,%al
  800d41:	74 04                	je     800d47 <strtol+0x17>
  800d43:	3c 09                	cmp    $0x9,%al
  800d45:	75 0e                	jne    800d55 <strtol+0x25>
		s++;
  800d47:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4a:	0f b6 01             	movzbl (%ecx),%eax
  800d4d:	3c 20                	cmp    $0x20,%al
  800d4f:	74 f6                	je     800d47 <strtol+0x17>
  800d51:	3c 09                	cmp    $0x9,%al
  800d53:	74 f2                	je     800d47 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d55:	3c 2b                	cmp    $0x2b,%al
  800d57:	75 0a                	jne    800d63 <strtol+0x33>
		s++;
  800d59:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d61:	eb 11                	jmp    800d74 <strtol+0x44>
  800d63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d68:	3c 2d                	cmp    $0x2d,%al
  800d6a:	75 08                	jne    800d74 <strtol+0x44>
		s++, neg = 1;
  800d6c:	83 c1 01             	add    $0x1,%ecx
  800d6f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d7a:	75 15                	jne    800d91 <strtol+0x61>
  800d7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800d7f:	75 10                	jne    800d91 <strtol+0x61>
  800d81:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d85:	75 7c                	jne    800e03 <strtol+0xd3>
		s += 2, base = 16;
  800d87:	83 c1 02             	add    $0x2,%ecx
  800d8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8f:	eb 16                	jmp    800da7 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d91:	85 db                	test   %ebx,%ebx
  800d93:	75 12                	jne    800da7 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d9d:	75 08                	jne    800da7 <strtol+0x77>
		s++, base = 8;
  800d9f:	83 c1 01             	add    $0x1,%ecx
  800da2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800da7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800daf:	0f b6 11             	movzbl (%ecx),%edx
  800db2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db5:	89 f3                	mov    %esi,%ebx
  800db7:	80 fb 09             	cmp    $0x9,%bl
  800dba:	77 08                	ja     800dc4 <strtol+0x94>
			dig = *s - '0';
  800dbc:	0f be d2             	movsbl %dl,%edx
  800dbf:	83 ea 30             	sub    $0x30,%edx
  800dc2:	eb 22                	jmp    800de6 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800dc4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dc7:	89 f3                	mov    %esi,%ebx
  800dc9:	80 fb 19             	cmp    $0x19,%bl
  800dcc:	77 08                	ja     800dd6 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800dce:	0f be d2             	movsbl %dl,%edx
  800dd1:	83 ea 57             	sub    $0x57,%edx
  800dd4:	eb 10                	jmp    800de6 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800dd6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dd9:	89 f3                	mov    %esi,%ebx
  800ddb:	80 fb 19             	cmp    $0x19,%bl
  800dde:	77 16                	ja     800df6 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800de0:	0f be d2             	movsbl %dl,%edx
  800de3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800de6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800de9:	7d 0b                	jge    800df6 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800deb:	83 c1 01             	add    $0x1,%ecx
  800dee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800df2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800df4:	eb b9                	jmp    800daf <strtol+0x7f>

	if (endptr)
  800df6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dfa:	74 0d                	je     800e09 <strtol+0xd9>
		*endptr = (char *) s;
  800dfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dff:	89 0e                	mov    %ecx,(%esi)
  800e01:	eb 06                	jmp    800e09 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	74 98                	je     800d9f <strtol+0x6f>
  800e07:	eb 9e                	jmp    800da7 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e09:	89 c2                	mov    %eax,%edx
  800e0b:	f7 da                	neg    %edx
  800e0d:	85 ff                	test   %edi,%edi
  800e0f:	0f 45 c2             	cmovne %edx,%eax
}
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 c3                	mov    %eax,%ebx
  800e29:	89 c7                	mov    %eax,%edi
  800e2b:	51                   	push   %ecx
  800e2c:	52                   	push   %edx
  800e2d:	53                   	push   %ebx
  800e2e:	54                   	push   %esp
  800e2f:	55                   	push   %ebp
  800e30:	56                   	push   %esi
  800e31:	57                   	push   %edi
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	8d 35 3c 0e 80 00    	lea    0x800e3c,%esi
  800e3a:	0f 34                	sysenter 

00800e3c <label_21>:
  800e3c:	5f                   	pop    %edi
  800e3d:	5e                   	pop    %esi
  800e3e:	5d                   	pop    %ebp
  800e3f:	5c                   	pop    %esp
  800e40:	5b                   	pop    %ebx
  800e41:	5a                   	pop    %edx
  800e42:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e51:	b8 01 00 00 00       	mov    $0x1,%eax
  800e56:	89 ca                	mov    %ecx,%edx
  800e58:	89 cb                	mov    %ecx,%ebx
  800e5a:	89 cf                	mov    %ecx,%edi
  800e5c:	51                   	push   %ecx
  800e5d:	52                   	push   %edx
  800e5e:	53                   	push   %ebx
  800e5f:	54                   	push   %esp
  800e60:	55                   	push   %ebp
  800e61:	56                   	push   %esi
  800e62:	57                   	push   %edi
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	8d 35 6d 0e 80 00    	lea    0x800e6d,%esi
  800e6b:	0f 34                	sysenter 

00800e6d <label_55>:
  800e6d:	5f                   	pop    %edi
  800e6e:	5e                   	pop    %esi
  800e6f:	5d                   	pop    %ebp
  800e70:	5c                   	pop    %esp
  800e71:	5b                   	pop    %ebx
  800e72:	5a                   	pop    %edx
  800e73:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e74:	5b                   	pop    %ebx
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e82:	b8 03 00 00 00       	mov    $0x3,%eax
  800e87:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8a:	89 d9                	mov    %ebx,%ecx
  800e8c:	89 df                	mov    %ebx,%edi
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

00800e9f <label_90>:
  800e9f:	5f                   	pop    %edi
  800ea0:	5e                   	pop    %esi
  800ea1:	5d                   	pop    %ebp
  800ea2:	5c                   	pop    %esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5a                   	pop    %edx
  800ea5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	7e 17                	jle    800ec1 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	50                   	push   %eax
  800eae:	6a 03                	push   $0x3
  800eb0:	68 e4 17 80 00       	push   $0x8017e4
  800eb5:	6a 2a                	push   $0x2a
  800eb7:	68 01 18 80 00       	push   $0x801801
  800ebc:	e8 4c f2 ff ff       	call   80010d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ec1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ecd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ed7:	89 ca                	mov    %ecx,%edx
  800ed9:	89 cb                	mov    %ecx,%ebx
  800edb:	89 cf                	mov    %ecx,%edi
  800edd:	51                   	push   %ecx
  800ede:	52                   	push   %edx
  800edf:	53                   	push   %ebx
  800ee0:	54                   	push   %esp
  800ee1:	55                   	push   %ebp
  800ee2:	56                   	push   %esi
  800ee3:	57                   	push   %edi
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	8d 35 ee 0e 80 00    	lea    0x800eee,%esi
  800eec:	0f 34                	sysenter 

00800eee <label_139>:
  800eee:	5f                   	pop    %edi
  800eef:	5e                   	pop    %esi
  800ef0:	5d                   	pop    %ebp
  800ef1:	5c                   	pop    %esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5a                   	pop    %edx
  800ef4:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ef5:	5b                   	pop    %ebx
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800efe:	bf 00 00 00 00       	mov    $0x0,%edi
  800f03:	b8 04 00 00 00       	mov    $0x4,%eax
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	89 fb                	mov    %edi,%ebx
  800f10:	51                   	push   %ecx
  800f11:	52                   	push   %edx
  800f12:	53                   	push   %ebx
  800f13:	54                   	push   %esp
  800f14:	55                   	push   %ebp
  800f15:	56                   	push   %esi
  800f16:	57                   	push   %edi
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	8d 35 21 0f 80 00    	lea    0x800f21,%esi
  800f1f:	0f 34                	sysenter 

00800f21 <label_174>:
  800f21:	5f                   	pop    %edi
  800f22:	5e                   	pop    %esi
  800f23:	5d                   	pop    %ebp
  800f24:	5c                   	pop    %esp
  800f25:	5b                   	pop    %ebx
  800f26:	5a                   	pop    %edx
  800f27:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f28:	5b                   	pop    %ebx
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <sys_yield>:

void
sys_yield(void)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	57                   	push   %edi
  800f30:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f31:	ba 00 00 00 00       	mov    $0x0,%edx
  800f36:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f3b:	89 d1                	mov    %edx,%ecx
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 d7                	mov    %edx,%edi
  800f41:	51                   	push   %ecx
  800f42:	52                   	push   %edx
  800f43:	53                   	push   %ebx
  800f44:	54                   	push   %esp
  800f45:	55                   	push   %ebp
  800f46:	56                   	push   %esi
  800f47:	57                   	push   %edi
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	8d 35 52 0f 80 00    	lea    0x800f52,%esi
  800f50:	0f 34                	sysenter 

00800f52 <label_209>:
  800f52:	5f                   	pop    %edi
  800f53:	5e                   	pop    %esi
  800f54:	5d                   	pop    %ebp
  800f55:	5c                   	pop    %esp
  800f56:	5b                   	pop    %ebx
  800f57:	5a                   	pop    %edx
  800f58:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f59:	5b                   	pop    %ebx
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f62:	bf 00 00 00 00       	mov    $0x0,%edi
  800f67:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f75:	51                   	push   %ecx
  800f76:	52                   	push   %edx
  800f77:	53                   	push   %ebx
  800f78:	54                   	push   %esp
  800f79:	55                   	push   %ebp
  800f7a:	56                   	push   %esi
  800f7b:	57                   	push   %edi
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	8d 35 86 0f 80 00    	lea    0x800f86,%esi
  800f84:	0f 34                	sysenter 

00800f86 <label_244>:
  800f86:	5f                   	pop    %edi
  800f87:	5e                   	pop    %esi
  800f88:	5d                   	pop    %ebp
  800f89:	5c                   	pop    %esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5a                   	pop    %edx
  800f8c:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	7e 17                	jle    800fa8 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	50                   	push   %eax
  800f95:	6a 05                	push   $0x5
  800f97:	68 e4 17 80 00       	push   $0x8017e4
  800f9c:	6a 2a                	push   $0x2a
  800f9e:	68 01 18 80 00       	push   $0x801801
  800fa3:	e8 65 f1 ff ff       	call   80010d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fa8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	57                   	push   %edi
  800fb3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb4:	b8 06 00 00 00       	mov    $0x6,%eax
  800fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc5:	51                   	push   %ecx
  800fc6:	52                   	push   %edx
  800fc7:	53                   	push   %ebx
  800fc8:	54                   	push   %esp
  800fc9:	55                   	push   %ebp
  800fca:	56                   	push   %esi
  800fcb:	57                   	push   %edi
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	8d 35 d6 0f 80 00    	lea    0x800fd6,%esi
  800fd4:	0f 34                	sysenter 

00800fd6 <label_295>:
  800fd6:	5f                   	pop    %edi
  800fd7:	5e                   	pop    %esi
  800fd8:	5d                   	pop    %ebp
  800fd9:	5c                   	pop    %esp
  800fda:	5b                   	pop    %ebx
  800fdb:	5a                   	pop    %edx
  800fdc:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	7e 17                	jle    800ff8 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	50                   	push   %eax
  800fe5:	6a 06                	push   $0x6
  800fe7:	68 e4 17 80 00       	push   $0x8017e4
  800fec:	6a 2a                	push   $0x2a
  800fee:	68 01 18 80 00       	push   $0x801801
  800ff3:	e8 15 f1 ff ff       	call   80010d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ff8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5f                   	pop    %edi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	57                   	push   %edi
  801003:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801004:	bf 00 00 00 00       	mov    $0x0,%edi
  801009:	b8 07 00 00 00       	mov    $0x7,%eax
  80100e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801011:	8b 55 08             	mov    0x8(%ebp),%edx
  801014:	89 fb                	mov    %edi,%ebx
  801016:	51                   	push   %ecx
  801017:	52                   	push   %edx
  801018:	53                   	push   %ebx
  801019:	54                   	push   %esp
  80101a:	55                   	push   %ebp
  80101b:	56                   	push   %esi
  80101c:	57                   	push   %edi
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	8d 35 27 10 80 00    	lea    0x801027,%esi
  801025:	0f 34                	sysenter 

00801027 <label_344>:
  801027:	5f                   	pop    %edi
  801028:	5e                   	pop    %esi
  801029:	5d                   	pop    %ebp
  80102a:	5c                   	pop    %esp
  80102b:	5b                   	pop    %ebx
  80102c:	5a                   	pop    %edx
  80102d:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80102e:	85 c0                	test   %eax,%eax
  801030:	7e 17                	jle    801049 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	50                   	push   %eax
  801036:	6a 07                	push   $0x7
  801038:	68 e4 17 80 00       	push   $0x8017e4
  80103d:	6a 2a                	push   $0x2a
  80103f:	68 01 18 80 00       	push   $0x801801
  801044:	e8 c4 f0 ff ff       	call   80010d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801049:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801055:	bf 00 00 00 00       	mov    $0x0,%edi
  80105a:	b8 09 00 00 00       	mov    $0x9,%eax
  80105f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801062:	8b 55 08             	mov    0x8(%ebp),%edx
  801065:	89 fb                	mov    %edi,%ebx
  801067:	51                   	push   %ecx
  801068:	52                   	push   %edx
  801069:	53                   	push   %ebx
  80106a:	54                   	push   %esp
  80106b:	55                   	push   %ebp
  80106c:	56                   	push   %esi
  80106d:	57                   	push   %edi
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	8d 35 78 10 80 00    	lea    0x801078,%esi
  801076:	0f 34                	sysenter 

00801078 <label_393>:
  801078:	5f                   	pop    %edi
  801079:	5e                   	pop    %esi
  80107a:	5d                   	pop    %ebp
  80107b:	5c                   	pop    %esp
  80107c:	5b                   	pop    %ebx
  80107d:	5a                   	pop    %edx
  80107e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80107f:	85 c0                	test   %eax,%eax
  801081:	7e 17                	jle    80109a <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	50                   	push   %eax
  801087:	6a 09                	push   $0x9
  801089:	68 e4 17 80 00       	push   $0x8017e4
  80108e:	6a 2a                	push   $0x2a
  801090:	68 01 18 80 00       	push   $0x801801
  801095:	e8 73 f0 ff ff       	call   80010d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80109a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5f                   	pop    %edi
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	57                   	push   %edi
  8010a5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	89 fb                	mov    %edi,%ebx
  8010b8:	51                   	push   %ecx
  8010b9:	52                   	push   %edx
  8010ba:	53                   	push   %ebx
  8010bb:	54                   	push   %esp
  8010bc:	55                   	push   %ebp
  8010bd:	56                   	push   %esi
  8010be:	57                   	push   %edi
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	8d 35 c9 10 80 00    	lea    0x8010c9,%esi
  8010c7:	0f 34                	sysenter 

008010c9 <label_442>:
  8010c9:	5f                   	pop    %edi
  8010ca:	5e                   	pop    %esi
  8010cb:	5d                   	pop    %ebp
  8010cc:	5c                   	pop    %esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5a                   	pop    %edx
  8010cf:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	7e 17                	jle    8010eb <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	50                   	push   %eax
  8010d8:	6a 0a                	push   $0xa
  8010da:	68 e4 17 80 00       	push   $0x8017e4
  8010df:	6a 2a                	push   $0x2a
  8010e1:	68 01 18 80 00       	push   $0x801801
  8010e6:	e8 22 f0 ff ff       	call   80010d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ee:	5b                   	pop    %ebx
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801105:	8b 7d 14             	mov    0x14(%ebp),%edi
  801108:	51                   	push   %ecx
  801109:	52                   	push   %edx
  80110a:	53                   	push   %ebx
  80110b:	54                   	push   %esp
  80110c:	55                   	push   %ebp
  80110d:	56                   	push   %esi
  80110e:	57                   	push   %edi
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	8d 35 19 11 80 00    	lea    0x801119,%esi
  801117:	0f 34                	sysenter 

00801119 <label_493>:
  801119:	5f                   	pop    %edi
  80111a:	5e                   	pop    %esi
  80111b:	5d                   	pop    %ebp
  80111c:	5c                   	pop    %esp
  80111d:	5b                   	pop    %ebx
  80111e:	5a                   	pop    %edx
  80111f:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801120:	5b                   	pop    %ebx
  801121:	5f                   	pop    %edi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801129:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801133:	8b 55 08             	mov    0x8(%ebp),%edx
  801136:	89 d9                	mov    %ebx,%ecx
  801138:	89 df                	mov    %ebx,%edi
  80113a:	51                   	push   %ecx
  80113b:	52                   	push   %edx
  80113c:	53                   	push   %ebx
  80113d:	54                   	push   %esp
  80113e:	55                   	push   %ebp
  80113f:	56                   	push   %esi
  801140:	57                   	push   %edi
  801141:	89 e5                	mov    %esp,%ebp
  801143:	8d 35 4b 11 80 00    	lea    0x80114b,%esi
  801149:	0f 34                	sysenter 

0080114b <label_528>:
  80114b:	5f                   	pop    %edi
  80114c:	5e                   	pop    %esi
  80114d:	5d                   	pop    %ebp
  80114e:	5c                   	pop    %esp
  80114f:	5b                   	pop    %ebx
  801150:	5a                   	pop    %edx
  801151:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801152:	85 c0                	test   %eax,%eax
  801154:	7e 17                	jle    80116d <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	50                   	push   %eax
  80115a:	6a 0d                	push   $0xd
  80115c:	68 e4 17 80 00       	push   $0x8017e4
  801161:	6a 2a                	push   $0x2a
  801163:	68 01 18 80 00       	push   $0x801801
  801168:	e8 a0 ef ff ff       	call   80010d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80116d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801170:	5b                   	pop    %ebx
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801179:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117e:	b8 0e 00 00 00       	mov    $0xe,%eax
  801183:	8b 55 08             	mov    0x8(%ebp),%edx
  801186:	89 cb                	mov    %ecx,%ebx
  801188:	89 cf                	mov    %ecx,%edi
  80118a:	51                   	push   %ecx
  80118b:	52                   	push   %edx
  80118c:	53                   	push   %ebx
  80118d:	54                   	push   %esp
  80118e:	55                   	push   %ebp
  80118f:	56                   	push   %esi
  801190:	57                   	push   %edi
  801191:	89 e5                	mov    %esp,%ebp
  801193:	8d 35 9b 11 80 00    	lea    0x80119b,%esi
  801199:	0f 34                	sysenter 

0080119b <label_577>:
  80119b:	5f                   	pop    %edi
  80119c:	5e                   	pop    %esi
  80119d:	5d                   	pop    %ebp
  80119e:	5c                   	pop    %esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5a                   	pop    %edx
  8011a1:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011a2:	5b                   	pop    %ebx
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011ac:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  8011b3:	75 14                	jne    8011c9 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	68 10 18 80 00       	push   $0x801810
  8011bd:	6a 20                	push   $0x20
  8011bf:	68 34 18 80 00       	push   $0x801834
  8011c4:	e8 44 ef ff ff       	call   80010d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cc:	a3 14 20 80 00       	mov    %eax,0x802014
}
  8011d1:	c9                   	leave  
  8011d2:	c3                   	ret    
  8011d3:	66 90                	xchg   %ax,%ax
  8011d5:	66 90                	xchg   %ax,%ax
  8011d7:	66 90                	xchg   %ax,%ax
  8011d9:	66 90                	xchg   %ax,%ax
  8011db:	66 90                	xchg   %ax,%ax
  8011dd:	66 90                	xchg   %ax,%ax
  8011df:	90                   	nop

008011e0 <__udivdi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	57                   	push   %edi
  8011e2:	56                   	push   %esi
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 1c             	sub    $0x1c,%esp
  8011e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8011eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011f7:	85 f6                	test   %esi,%esi
  8011f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011fd:	89 ca                	mov    %ecx,%edx
  8011ff:	89 f8                	mov    %edi,%eax
  801201:	75 3d                	jne    801240 <__udivdi3+0x60>
  801203:	39 cf                	cmp    %ecx,%edi
  801205:	0f 87 c5 00 00 00    	ja     8012d0 <__udivdi3+0xf0>
  80120b:	85 ff                	test   %edi,%edi
  80120d:	89 fd                	mov    %edi,%ebp
  80120f:	75 0b                	jne    80121c <__udivdi3+0x3c>
  801211:	b8 01 00 00 00       	mov    $0x1,%eax
  801216:	31 d2                	xor    %edx,%edx
  801218:	f7 f7                	div    %edi
  80121a:	89 c5                	mov    %eax,%ebp
  80121c:	89 c8                	mov    %ecx,%eax
  80121e:	31 d2                	xor    %edx,%edx
  801220:	f7 f5                	div    %ebp
  801222:	89 c1                	mov    %eax,%ecx
  801224:	89 d8                	mov    %ebx,%eax
  801226:	89 cf                	mov    %ecx,%edi
  801228:	f7 f5                	div    %ebp
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	89 d8                	mov    %ebx,%eax
  80122e:	89 fa                	mov    %edi,%edx
  801230:	83 c4 1c             	add    $0x1c,%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
  801238:	90                   	nop
  801239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801240:	39 ce                	cmp    %ecx,%esi
  801242:	77 74                	ja     8012b8 <__udivdi3+0xd8>
  801244:	0f bd fe             	bsr    %esi,%edi
  801247:	83 f7 1f             	xor    $0x1f,%edi
  80124a:	0f 84 98 00 00 00    	je     8012e8 <__udivdi3+0x108>
  801250:	bb 20 00 00 00       	mov    $0x20,%ebx
  801255:	89 f9                	mov    %edi,%ecx
  801257:	89 c5                	mov    %eax,%ebp
  801259:	29 fb                	sub    %edi,%ebx
  80125b:	d3 e6                	shl    %cl,%esi
  80125d:	89 d9                	mov    %ebx,%ecx
  80125f:	d3 ed                	shr    %cl,%ebp
  801261:	89 f9                	mov    %edi,%ecx
  801263:	d3 e0                	shl    %cl,%eax
  801265:	09 ee                	or     %ebp,%esi
  801267:	89 d9                	mov    %ebx,%ecx
  801269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80126d:	89 d5                	mov    %edx,%ebp
  80126f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801273:	d3 ed                	shr    %cl,%ebp
  801275:	89 f9                	mov    %edi,%ecx
  801277:	d3 e2                	shl    %cl,%edx
  801279:	89 d9                	mov    %ebx,%ecx
  80127b:	d3 e8                	shr    %cl,%eax
  80127d:	09 c2                	or     %eax,%edx
  80127f:	89 d0                	mov    %edx,%eax
  801281:	89 ea                	mov    %ebp,%edx
  801283:	f7 f6                	div    %esi
  801285:	89 d5                	mov    %edx,%ebp
  801287:	89 c3                	mov    %eax,%ebx
  801289:	f7 64 24 0c          	mull   0xc(%esp)
  80128d:	39 d5                	cmp    %edx,%ebp
  80128f:	72 10                	jb     8012a1 <__udivdi3+0xc1>
  801291:	8b 74 24 08          	mov    0x8(%esp),%esi
  801295:	89 f9                	mov    %edi,%ecx
  801297:	d3 e6                	shl    %cl,%esi
  801299:	39 c6                	cmp    %eax,%esi
  80129b:	73 07                	jae    8012a4 <__udivdi3+0xc4>
  80129d:	39 d5                	cmp    %edx,%ebp
  80129f:	75 03                	jne    8012a4 <__udivdi3+0xc4>
  8012a1:	83 eb 01             	sub    $0x1,%ebx
  8012a4:	31 ff                	xor    %edi,%edi
  8012a6:	89 d8                	mov    %ebx,%eax
  8012a8:	89 fa                	mov    %edi,%edx
  8012aa:	83 c4 1c             	add    $0x1c,%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5f                   	pop    %edi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    
  8012b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012b8:	31 ff                	xor    %edi,%edi
  8012ba:	31 db                	xor    %ebx,%ebx
  8012bc:	89 d8                	mov    %ebx,%eax
  8012be:	89 fa                	mov    %edi,%edx
  8012c0:	83 c4 1c             	add    $0x1c,%esp
  8012c3:	5b                   	pop    %ebx
  8012c4:	5e                   	pop    %esi
  8012c5:	5f                   	pop    %edi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    
  8012c8:	90                   	nop
  8012c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	89 d8                	mov    %ebx,%eax
  8012d2:	f7 f7                	div    %edi
  8012d4:	31 ff                	xor    %edi,%edi
  8012d6:	89 c3                	mov    %eax,%ebx
  8012d8:	89 d8                	mov    %ebx,%eax
  8012da:	89 fa                	mov    %edi,%edx
  8012dc:	83 c4 1c             	add    $0x1c,%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5e                   	pop    %esi
  8012e1:	5f                   	pop    %edi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    
  8012e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	39 ce                	cmp    %ecx,%esi
  8012ea:	72 0c                	jb     8012f8 <__udivdi3+0x118>
  8012ec:	31 db                	xor    %ebx,%ebx
  8012ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012f2:	0f 87 34 ff ff ff    	ja     80122c <__udivdi3+0x4c>
  8012f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012fd:	e9 2a ff ff ff       	jmp    80122c <__udivdi3+0x4c>
  801302:	66 90                	xchg   %ax,%ax
  801304:	66 90                	xchg   %ax,%ax
  801306:	66 90                	xchg   %ax,%ax
  801308:	66 90                	xchg   %ax,%ax
  80130a:	66 90                	xchg   %ax,%ax
  80130c:	66 90                	xchg   %ax,%ax
  80130e:	66 90                	xchg   %ax,%ax

00801310 <__umoddi3>:
  801310:	55                   	push   %ebp
  801311:	57                   	push   %edi
  801312:	56                   	push   %esi
  801313:	53                   	push   %ebx
  801314:	83 ec 1c             	sub    $0x1c,%esp
  801317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80131b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80131f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801327:	85 d2                	test   %edx,%edx
  801329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80132d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801331:	89 f3                	mov    %esi,%ebx
  801333:	89 3c 24             	mov    %edi,(%esp)
  801336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80133a:	75 1c                	jne    801358 <__umoddi3+0x48>
  80133c:	39 f7                	cmp    %esi,%edi
  80133e:	76 50                	jbe    801390 <__umoddi3+0x80>
  801340:	89 c8                	mov    %ecx,%eax
  801342:	89 f2                	mov    %esi,%edx
  801344:	f7 f7                	div    %edi
  801346:	89 d0                	mov    %edx,%eax
  801348:	31 d2                	xor    %edx,%edx
  80134a:	83 c4 1c             	add    $0x1c,%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5f                   	pop    %edi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    
  801352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801358:	39 f2                	cmp    %esi,%edx
  80135a:	89 d0                	mov    %edx,%eax
  80135c:	77 52                	ja     8013b0 <__umoddi3+0xa0>
  80135e:	0f bd ea             	bsr    %edx,%ebp
  801361:	83 f5 1f             	xor    $0x1f,%ebp
  801364:	75 5a                	jne    8013c0 <__umoddi3+0xb0>
  801366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80136a:	0f 82 e0 00 00 00    	jb     801450 <__umoddi3+0x140>
  801370:	39 0c 24             	cmp    %ecx,(%esp)
  801373:	0f 86 d7 00 00 00    	jbe    801450 <__umoddi3+0x140>
  801379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80137d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801381:	83 c4 1c             	add    $0x1c,%esp
  801384:	5b                   	pop    %ebx
  801385:	5e                   	pop    %esi
  801386:	5f                   	pop    %edi
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	85 ff                	test   %edi,%edi
  801392:	89 fd                	mov    %edi,%ebp
  801394:	75 0b                	jne    8013a1 <__umoddi3+0x91>
  801396:	b8 01 00 00 00       	mov    $0x1,%eax
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	f7 f7                	div    %edi
  80139f:	89 c5                	mov    %eax,%ebp
  8013a1:	89 f0                	mov    %esi,%eax
  8013a3:	31 d2                	xor    %edx,%edx
  8013a5:	f7 f5                	div    %ebp
  8013a7:	89 c8                	mov    %ecx,%eax
  8013a9:	f7 f5                	div    %ebp
  8013ab:	89 d0                	mov    %edx,%eax
  8013ad:	eb 99                	jmp    801348 <__umoddi3+0x38>
  8013af:	90                   	nop
  8013b0:	89 c8                	mov    %ecx,%eax
  8013b2:	89 f2                	mov    %esi,%edx
  8013b4:	83 c4 1c             	add    $0x1c,%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5f                   	pop    %edi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    
  8013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	8b 34 24             	mov    (%esp),%esi
  8013c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	29 ef                	sub    %ebp,%edi
  8013cc:	d3 e0                	shl    %cl,%eax
  8013ce:	89 f9                	mov    %edi,%ecx
  8013d0:	89 f2                	mov    %esi,%edx
  8013d2:	d3 ea                	shr    %cl,%edx
  8013d4:	89 e9                	mov    %ebp,%ecx
  8013d6:	09 c2                	or     %eax,%edx
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	89 14 24             	mov    %edx,(%esp)
  8013dd:	89 f2                	mov    %esi,%edx
  8013df:	d3 e2                	shl    %cl,%edx
  8013e1:	89 f9                	mov    %edi,%ecx
  8013e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013eb:	d3 e8                	shr    %cl,%eax
  8013ed:	89 e9                	mov    %ebp,%ecx
  8013ef:	89 c6                	mov    %eax,%esi
  8013f1:	d3 e3                	shl    %cl,%ebx
  8013f3:	89 f9                	mov    %edi,%ecx
  8013f5:	89 d0                	mov    %edx,%eax
  8013f7:	d3 e8                	shr    %cl,%eax
  8013f9:	89 e9                	mov    %ebp,%ecx
  8013fb:	09 d8                	or     %ebx,%eax
  8013fd:	89 d3                	mov    %edx,%ebx
  8013ff:	89 f2                	mov    %esi,%edx
  801401:	f7 34 24             	divl   (%esp)
  801404:	89 d6                	mov    %edx,%esi
  801406:	d3 e3                	shl    %cl,%ebx
  801408:	f7 64 24 04          	mull   0x4(%esp)
  80140c:	39 d6                	cmp    %edx,%esi
  80140e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801412:	89 d1                	mov    %edx,%ecx
  801414:	89 c3                	mov    %eax,%ebx
  801416:	72 08                	jb     801420 <__umoddi3+0x110>
  801418:	75 11                	jne    80142b <__umoddi3+0x11b>
  80141a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80141e:	73 0b                	jae    80142b <__umoddi3+0x11b>
  801420:	2b 44 24 04          	sub    0x4(%esp),%eax
  801424:	1b 14 24             	sbb    (%esp),%edx
  801427:	89 d1                	mov    %edx,%ecx
  801429:	89 c3                	mov    %eax,%ebx
  80142b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80142f:	29 da                	sub    %ebx,%edx
  801431:	19 ce                	sbb    %ecx,%esi
  801433:	89 f9                	mov    %edi,%ecx
  801435:	89 f0                	mov    %esi,%eax
  801437:	d3 e0                	shl    %cl,%eax
  801439:	89 e9                	mov    %ebp,%ecx
  80143b:	d3 ea                	shr    %cl,%edx
  80143d:	89 e9                	mov    %ebp,%ecx
  80143f:	d3 ee                	shr    %cl,%esi
  801441:	09 d0                	or     %edx,%eax
  801443:	89 f2                	mov    %esi,%edx
  801445:	83 c4 1c             	add    $0x1c,%esp
  801448:	5b                   	pop    %ebx
  801449:	5e                   	pop    %esi
  80144a:	5f                   	pop    %edi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    
  80144d:	8d 76 00             	lea    0x0(%esi),%esi
  801450:	29 f9                	sub    %edi,%ecx
  801452:	19 d6                	sbb    %edx,%esi
  801454:	89 74 24 04          	mov    %esi,0x4(%esp)
  801458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80145c:	e9 18 ff ff ff       	jmp    801379 <__umoddi3+0x69>
