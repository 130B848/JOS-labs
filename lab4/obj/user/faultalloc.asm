
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
  80002c:	e8 a5 00 00 00       	call   8000d6 <libmain>
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
  800040:	68 00 15 80 00       	push   $0x801500
  800045:	e8 d7 01 00 00       	call   800221 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 20 0f 00 00       	call   800f7e <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 20 15 80 00       	push   $0x801520
  80006f:	6a 0e                	push   $0xe
  800071:	68 0a 15 80 00       	push   $0x80150a
  800076:	e8 b3 00 00 00       	call   80012e <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 4c 15 80 00       	push   $0x80154c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 59 09 00 00       	call   8009e2 <snprintf>
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
	cprintf("set_pgfault_handler end in umain fault alloc\n");
  800097:	68 70 15 80 00       	push   $0x801570
  80009c:	e8 80 01 00 00       	call   800221 <cprintf>
	set_pgfault_handler(handler);
  8000a1:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000a8:	e8 3b 11 00 00       	call   8011e8 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000ad:	83 c4 08             	add    $0x8,%esp
  8000b0:	68 ef be ad de       	push   $0xdeadbeef
  8000b5:	68 1c 15 80 00       	push   $0x80151c
  8000ba:	e8 62 01 00 00       	call   800221 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bf:	83 c4 08             	add    $0x8,%esp
  8000c2:	68 fe bf fe ca       	push   $0xcafebffe
  8000c7:	68 1c 15 80 00       	push   $0x80151c
  8000cc:	e8 50 01 00 00       	call   800221 <cprintf>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    

008000d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000e1:	e8 03 0e 00 00       	call   800ee9 <sys_getenvid>
  8000e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000eb:	c1 e0 07             	shl    $0x7,%eax
  8000ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f3:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f8:	85 db                	test   %ebx,%ebx
  8000fa:	7e 07                	jle    800103 <libmain+0x2d>
		binaryname = argv[0];
  8000fc:	8b 06                	mov    (%esi),%eax
  8000fe:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	e8 84 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  80010d:	e8 0a 00 00 00       	call   80011c <exit>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800122:	6a 00                	push   $0x0
  800124:	e8 70 0d 00 00       	call   800e99 <sys_env_destroy>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	c9                   	leave  
  80012d:	c3                   	ret    

0080012e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	56                   	push   %esi
  800132:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800133:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800136:	a1 10 20 80 00       	mov    0x802010,%eax
  80013b:	85 c0                	test   %eax,%eax
  80013d:	74 11                	je     800150 <_panic+0x22>
		cprintf("%s: ", argv0);
  80013f:	83 ec 08             	sub    $0x8,%esp
  800142:	50                   	push   %eax
  800143:	68 a8 15 80 00       	push   $0x8015a8
  800148:	e8 d4 00 00 00       	call   800221 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800150:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800156:	e8 8e 0d 00 00       	call   800ee9 <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	56                   	push   %esi
  800165:	50                   	push   %eax
  800166:	68 b0 15 80 00       	push   $0x8015b0
  80016b:	e8 b1 00 00 00       	call   800221 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	53                   	push   %ebx
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 54 00 00 00       	call   8001d0 <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 e6 18 80 00 	movl   $0x8018e6,(%esp)
  800183:	e8 99 00 00 00       	call   800221 <cprintf>
  800188:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x5d>

0080018e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	53                   	push   %ebx
  800192:	83 ec 04             	sub    $0x4,%esp
  800195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800198:	8b 13                	mov    (%ebx),%edx
  80019a:	8d 42 01             	lea    0x1(%edx),%eax
  80019d:	89 03                	mov    %eax,(%ebx)
  80019f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	75 1a                	jne    8001c7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ad:	83 ec 08             	sub    $0x8,%esp
  8001b0:	68 ff 00 00 00       	push   $0xff
  8001b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b8:	50                   	push   %eax
  8001b9:	e8 7a 0c 00 00       	call   800e38 <sys_cputs>
		b->idx = 0;
  8001be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e0:	00 00 00 
	b.cnt = 0;
  8001e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ed:	ff 75 0c             	pushl  0xc(%ebp)
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f9:	50                   	push   %eax
  8001fa:	68 8e 01 80 00       	push   $0x80018e
  8001ff:	e8 c0 02 00 00       	call   8004c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800204:	83 c4 08             	add    $0x8,%esp
  800207:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800213:	50                   	push   %eax
  800214:	e8 1f 0c 00 00       	call   800e38 <sys_cputs>

	return b.cnt;
}
  800219:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800227:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022a:	50                   	push   %eax
  80022b:	ff 75 08             	pushl  0x8(%ebp)
  80022e:	e8 9d ff ff ff       	call   8001d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800233:	c9                   	leave  
  800234:	c3                   	ret    

00800235 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	57                   	push   %edi
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
  80023b:	83 ec 1c             	sub    $0x1c,%esp
  80023e:	89 c7                	mov    %eax,%edi
  800240:	89 d6                	mov    %edx,%esi
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	8b 55 0c             	mov    0xc(%ebp),%edx
  800248:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80024e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800251:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800255:	0f 85 bf 00 00 00    	jne    80031a <printnum+0xe5>
  80025b:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800261:	0f 8d de 00 00 00    	jge    800345 <printnum+0x110>
		judge_time_for_space = width;
  800267:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  80026d:	e9 d3 00 00 00       	jmp    800345 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800272:	83 eb 01             	sub    $0x1,%ebx
  800275:	85 db                	test   %ebx,%ebx
  800277:	7f 37                	jg     8002b0 <printnum+0x7b>
  800279:	e9 ea 00 00 00       	jmp    800368 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80027e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800281:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	83 ec 04             	sub    $0x4,%esp
  80028d:	ff 75 dc             	pushl  -0x24(%ebp)
  800290:	ff 75 d8             	pushl  -0x28(%ebp)
  800293:	ff 75 e4             	pushl  -0x1c(%ebp)
  800296:	ff 75 e0             	pushl  -0x20(%ebp)
  800299:	e8 02 11 00 00       	call   8013a0 <__umoddi3>
  80029e:	83 c4 14             	add    $0x14,%esp
  8002a1:	0f be 80 d3 15 80 00 	movsbl 0x8015d3(%eax),%eax
  8002a8:	50                   	push   %eax
  8002a9:	ff d7                	call   *%edi
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	eb 16                	jmp    8002c6 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8002b0:	83 ec 08             	sub    $0x8,%esp
  8002b3:	56                   	push   %esi
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8002b9:	83 c4 10             	add    $0x10,%esp
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	75 ef                	jne    8002b0 <printnum+0x7b>
  8002c1:	e9 a2 00 00 00       	jmp    800368 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8002c6:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8002cc:	0f 85 76 01 00 00    	jne    800448 <printnum+0x213>
		while(num_of_space-- > 0)
  8002d2:	a1 04 20 80 00       	mov    0x802004,%eax
  8002d7:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002da:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	7e 1d                	jle    800301 <printnum+0xcc>
			putch(' ', putdat);
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	56                   	push   %esi
  8002e8:	6a 20                	push   $0x20
  8002ea:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8002ec:	a1 04 20 80 00       	mov    0x802004,%eax
  8002f1:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002f4:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7f e3                	jg     8002e4 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800301:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800308:	00 00 00 
		judge_time_for_space = 0;
  80030b:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800312:	00 00 00 
	}
}
  800315:	e9 2e 01 00 00       	jmp    800448 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031a:	8b 45 10             	mov    0x10(%ebp),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
  800322:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800325:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80032e:	83 fa 00             	cmp    $0x0,%edx
  800331:	0f 87 ba 00 00 00    	ja     8003f1 <printnum+0x1bc>
  800337:	3b 45 10             	cmp    0x10(%ebp),%eax
  80033a:	0f 83 b1 00 00 00    	jae    8003f1 <printnum+0x1bc>
  800340:	e9 2d ff ff ff       	jmp    800272 <printnum+0x3d>
  800345:	8b 45 10             	mov    0x10(%ebp),%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
  80034d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800350:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800353:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800359:	83 fa 00             	cmp    $0x0,%edx
  80035c:	77 37                	ja     800395 <printnum+0x160>
  80035e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800361:	73 32                	jae    800395 <printnum+0x160>
  800363:	e9 16 ff ff ff       	jmp    80027e <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	56                   	push   %esi
  80036c:	83 ec 04             	sub    $0x4,%esp
  80036f:	ff 75 dc             	pushl  -0x24(%ebp)
  800372:	ff 75 d8             	pushl  -0x28(%ebp)
  800375:	ff 75 e4             	pushl  -0x1c(%ebp)
  800378:	ff 75 e0             	pushl  -0x20(%ebp)
  80037b:	e8 20 10 00 00       	call   8013a0 <__umoddi3>
  800380:	83 c4 14             	add    $0x14,%esp
  800383:	0f be 80 d3 15 80 00 	movsbl 0x8015d3(%eax),%eax
  80038a:	50                   	push   %eax
  80038b:	ff d7                	call   *%edi
  80038d:	83 c4 10             	add    $0x10,%esp
  800390:	e9 b3 00 00 00       	jmp    800448 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800395:	83 ec 0c             	sub    $0xc,%esp
  800398:	ff 75 18             	pushl  0x18(%ebp)
  80039b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80039e:	50                   	push   %eax
  80039f:	ff 75 10             	pushl  0x10(%ebp)
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b1:	e8 ba 0e 00 00       	call   801270 <__udivdi3>
  8003b6:	83 c4 18             	add    $0x18,%esp
  8003b9:	52                   	push   %edx
  8003ba:	50                   	push   %eax
  8003bb:	89 f2                	mov    %esi,%edx
  8003bd:	89 f8                	mov    %edi,%eax
  8003bf:	e8 71 fe ff ff       	call   800235 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c4:	83 c4 18             	add    $0x18,%esp
  8003c7:	56                   	push   %esi
  8003c8:	83 ec 04             	sub    $0x4,%esp
  8003cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d7:	e8 c4 0f 00 00       	call   8013a0 <__umoddi3>
  8003dc:	83 c4 14             	add    $0x14,%esp
  8003df:	0f be 80 d3 15 80 00 	movsbl 0x8015d3(%eax),%eax
  8003e6:	50                   	push   %eax
  8003e7:	ff d7                	call   *%edi
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	e9 d5 fe ff ff       	jmp    8002c6 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f1:	83 ec 0c             	sub    $0xc,%esp
  8003f4:	ff 75 18             	pushl  0x18(%ebp)
  8003f7:	83 eb 01             	sub    $0x1,%ebx
  8003fa:	53                   	push   %ebx
  8003fb:	ff 75 10             	pushl  0x10(%ebp)
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	ff 75 dc             	pushl  -0x24(%ebp)
  800404:	ff 75 d8             	pushl  -0x28(%ebp)
  800407:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040a:	ff 75 e0             	pushl  -0x20(%ebp)
  80040d:	e8 5e 0e 00 00       	call   801270 <__udivdi3>
  800412:	83 c4 18             	add    $0x18,%esp
  800415:	52                   	push   %edx
  800416:	50                   	push   %eax
  800417:	89 f2                	mov    %esi,%edx
  800419:	89 f8                	mov    %edi,%eax
  80041b:	e8 15 fe ff ff       	call   800235 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800420:	83 c4 18             	add    $0x18,%esp
  800423:	56                   	push   %esi
  800424:	83 ec 04             	sub    $0x4,%esp
  800427:	ff 75 dc             	pushl  -0x24(%ebp)
  80042a:	ff 75 d8             	pushl  -0x28(%ebp)
  80042d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800430:	ff 75 e0             	pushl  -0x20(%ebp)
  800433:	e8 68 0f 00 00       	call   8013a0 <__umoddi3>
  800438:	83 c4 14             	add    $0x14,%esp
  80043b:	0f be 80 d3 15 80 00 	movsbl 0x8015d3(%eax),%eax
  800442:	50                   	push   %eax
  800443:	ff d7                	call   *%edi
  800445:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800448:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80044b:	5b                   	pop    %ebx
  80044c:	5e                   	pop    %esi
  80044d:	5f                   	pop    %edi
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800453:	83 fa 01             	cmp    $0x1,%edx
  800456:	7e 0e                	jle    800466 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800458:	8b 10                	mov    (%eax),%edx
  80045a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80045d:	89 08                	mov    %ecx,(%eax)
  80045f:	8b 02                	mov    (%edx),%eax
  800461:	8b 52 04             	mov    0x4(%edx),%edx
  800464:	eb 22                	jmp    800488 <getuint+0x38>
	else if (lflag)
  800466:	85 d2                	test   %edx,%edx
  800468:	74 10                	je     80047a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80046a:	8b 10                	mov    (%eax),%edx
  80046c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046f:	89 08                	mov    %ecx,(%eax)
  800471:	8b 02                	mov    (%edx),%eax
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 0e                	jmp    800488 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800488:	5d                   	pop    %ebp
  800489:	c3                   	ret    

0080048a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800490:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800494:	8b 10                	mov    (%eax),%edx
  800496:	3b 50 04             	cmp    0x4(%eax),%edx
  800499:	73 0a                	jae    8004a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80049b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80049e:	89 08                	mov    %ecx,(%eax)
  8004a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a3:	88 02                	mov    %al,(%edx)
}
  8004a5:	5d                   	pop    %ebp
  8004a6:	c3                   	ret    

008004a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004a7:	55                   	push   %ebp
  8004a8:	89 e5                	mov    %esp,%ebp
  8004aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b0:	50                   	push   %eax
  8004b1:	ff 75 10             	pushl  0x10(%ebp)
  8004b4:	ff 75 0c             	pushl  0xc(%ebp)
  8004b7:	ff 75 08             	pushl  0x8(%ebp)
  8004ba:	e8 05 00 00 00       	call   8004c4 <vprintfmt>
	va_end(ap);
}
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	57                   	push   %edi
  8004c8:	56                   	push   %esi
  8004c9:	53                   	push   %ebx
  8004ca:	83 ec 2c             	sub    $0x2c,%esp
  8004cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d3:	eb 03                	jmp    8004d8 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004d5:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004db:	8d 70 01             	lea    0x1(%eax),%esi
  8004de:	0f b6 00             	movzbl (%eax),%eax
  8004e1:	83 f8 25             	cmp    $0x25,%eax
  8004e4:	74 27                	je     80050d <vprintfmt+0x49>
			if (ch == '\0')
  8004e6:	85 c0                	test   %eax,%eax
  8004e8:	75 0d                	jne    8004f7 <vprintfmt+0x33>
  8004ea:	e9 9d 04 00 00       	jmp    80098c <vprintfmt+0x4c8>
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	0f 84 95 04 00 00    	je     80098c <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	50                   	push   %eax
  8004fc:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fe:	83 c6 01             	add    $0x1,%esi
  800501:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	83 f8 25             	cmp    $0x25,%eax
  80050b:	75 e2                	jne    8004ef <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80050d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800512:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800516:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80051d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800524:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80052b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800532:	eb 08                	jmp    80053c <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800537:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8d 46 01             	lea    0x1(%esi),%eax
  80053f:	89 45 10             	mov    %eax,0x10(%ebp)
  800542:	0f b6 06             	movzbl (%esi),%eax
  800545:	0f b6 d0             	movzbl %al,%edx
  800548:	83 e8 23             	sub    $0x23,%eax
  80054b:	3c 55                	cmp    $0x55,%al
  80054d:	0f 87 fa 03 00 00    	ja     80094d <vprintfmt+0x489>
  800553:	0f b6 c0             	movzbl %al,%eax
  800556:	ff 24 85 20 17 80 00 	jmp    *0x801720(,%eax,4)
  80055d:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800560:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800564:	eb d6                	jmp    80053c <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800566:	8d 42 d0             	lea    -0x30(%edx),%eax
  800569:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80056c:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800570:	8d 50 d0             	lea    -0x30(%eax),%edx
  800573:	83 fa 09             	cmp    $0x9,%edx
  800576:	77 6b                	ja     8005e3 <vprintfmt+0x11f>
  800578:	8b 75 10             	mov    0x10(%ebp),%esi
  80057b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80057e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800581:	eb 09                	jmp    80058c <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800586:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80058a:	eb b0                	jmp    80053c <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80058c:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80058f:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800592:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800596:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800599:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80059c:	83 f9 09             	cmp    $0x9,%ecx
  80059f:	76 eb                	jbe    80058c <vprintfmt+0xc8>
  8005a1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005a4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005a7:	eb 3d                	jmp    8005e6 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ba:	eb 2a                	jmp    8005e6 <vprintfmt+0x122>
  8005bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c6:	0f 49 d0             	cmovns %eax,%edx
  8005c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 75 10             	mov    0x10(%ebp),%esi
  8005cf:	e9 68 ff ff ff       	jmp    80053c <vprintfmt+0x78>
  8005d4:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005de:	e9 59 ff ff ff       	jmp    80053c <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ea:	0f 89 4c ff ff ff    	jns    80053c <vprintfmt+0x78>
				width = precision, precision = -1;
  8005f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005fd:	e9 3a ff ff ff       	jmp    80053c <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800602:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800609:	e9 2e ff ff ff       	jmp    80053c <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 30                	pushl  (%eax)
  80061d:	ff d7                	call   *%edi
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	e9 b1 fe ff ff       	jmp    8004d8 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 50 04             	lea    0x4(%eax),%edx
  80062d:	89 55 14             	mov    %edx,0x14(%ebp)
  800630:	8b 00                	mov    (%eax),%eax
  800632:	99                   	cltd   
  800633:	31 d0                	xor    %edx,%eax
  800635:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800637:	83 f8 08             	cmp    $0x8,%eax
  80063a:	7f 0b                	jg     800647 <vprintfmt+0x183>
  80063c:	8b 14 85 80 18 80 00 	mov    0x801880(,%eax,4),%edx
  800643:	85 d2                	test   %edx,%edx
  800645:	75 15                	jne    80065c <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800647:	50                   	push   %eax
  800648:	68 eb 15 80 00       	push   $0x8015eb
  80064d:	53                   	push   %ebx
  80064e:	57                   	push   %edi
  80064f:	e8 53 fe ff ff       	call   8004a7 <printfmt>
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	e9 7c fe ff ff       	jmp    8004d8 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80065c:	52                   	push   %edx
  80065d:	68 f4 15 80 00       	push   $0x8015f4
  800662:	53                   	push   %ebx
  800663:	57                   	push   %edi
  800664:	e8 3e fe ff ff       	call   8004a7 <printfmt>
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	e9 67 fe ff ff       	jmp    8004d8 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 04             	lea    0x4(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80067c:	85 c0                	test   %eax,%eax
  80067e:	b9 e4 15 80 00       	mov    $0x8015e4,%ecx
  800683:	0f 45 c8             	cmovne %eax,%ecx
  800686:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800689:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80068d:	7e 06                	jle    800695 <vprintfmt+0x1d1>
  80068f:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800693:	75 19                	jne    8006ae <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800695:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800698:	8d 70 01             	lea    0x1(%eax),%esi
  80069b:	0f b6 00             	movzbl (%eax),%eax
  80069e:	0f be d0             	movsbl %al,%edx
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	0f 85 9f 00 00 00    	jne    800748 <vprintfmt+0x284>
  8006a9:	e9 8c 00 00 00       	jmp    80073a <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	ff 75 d0             	pushl  -0x30(%ebp)
  8006b4:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b7:	e8 62 03 00 00       	call   800a1e <strnlen>
  8006bc:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	85 c9                	test   %ecx,%ecx
  8006c7:	0f 8e a6 02 00 00    	jle    800973 <vprintfmt+0x4af>
					putch(padc, putdat);
  8006cd:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d4:	89 cb                	mov    %ecx,%ebx
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	ff 75 0c             	pushl  0xc(%ebp)
  8006dc:	56                   	push   %esi
  8006dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	83 eb 01             	sub    $0x1,%ebx
  8006e5:	75 ef                	jne    8006d6 <vprintfmt+0x212>
  8006e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ed:	e9 81 02 00 00       	jmp    800973 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f6:	74 1b                	je     800713 <vprintfmt+0x24f>
  8006f8:	0f be c0             	movsbl %al,%eax
  8006fb:	83 e8 20             	sub    $0x20,%eax
  8006fe:	83 f8 5e             	cmp    $0x5e,%eax
  800701:	76 10                	jbe    800713 <vprintfmt+0x24f>
					putch('?', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	ff 75 0c             	pushl  0xc(%ebp)
  800709:	6a 3f                	push   $0x3f
  80070b:	ff 55 08             	call   *0x8(%ebp)
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb 0d                	jmp    800720 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	ff 75 0c             	pushl  0xc(%ebp)
  800719:	52                   	push   %edx
  80071a:	ff 55 08             	call   *0x8(%ebp)
  80071d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800720:	83 ef 01             	sub    $0x1,%edi
  800723:	83 c6 01             	add    $0x1,%esi
  800726:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80072a:	0f be d0             	movsbl %al,%edx
  80072d:	85 d2                	test   %edx,%edx
  80072f:	75 31                	jne    800762 <vprintfmt+0x29e>
  800731:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800734:	8b 7d 08             	mov    0x8(%ebp),%edi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800741:	7f 33                	jg     800776 <vprintfmt+0x2b2>
  800743:	e9 90 fd ff ff       	jmp    8004d8 <vprintfmt+0x14>
  800748:	89 7d 08             	mov    %edi,0x8(%ebp)
  80074b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800751:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800754:	eb 0c                	jmp    800762 <vprintfmt+0x29e>
  800756:	89 7d 08             	mov    %edi,0x8(%ebp)
  800759:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800762:	85 db                	test   %ebx,%ebx
  800764:	78 8c                	js     8006f2 <vprintfmt+0x22e>
  800766:	83 eb 01             	sub    $0x1,%ebx
  800769:	79 87                	jns    8006f2 <vprintfmt+0x22e>
  80076b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80076e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800774:	eb c4                	jmp    80073a <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800776:	83 ec 08             	sub    $0x8,%esp
  800779:	53                   	push   %ebx
  80077a:	6a 20                	push   $0x20
  80077c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	83 ee 01             	sub    $0x1,%esi
  800784:	75 f0                	jne    800776 <vprintfmt+0x2b2>
  800786:	e9 4d fd ff ff       	jmp    8004d8 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80078b:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80078f:	7e 16                	jle    8007a7 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 08             	lea    0x8(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	8b 50 04             	mov    0x4(%eax),%edx
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007a5:	eb 34                	jmp    8007db <vprintfmt+0x317>
	else if (lflag)
  8007a7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007ab:	74 18                	je     8007c5 <vprintfmt+0x301>
		return va_arg(*ap, long);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8d 50 04             	lea    0x4(%eax),%edx
  8007b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b6:	8b 30                	mov    (%eax),%esi
  8007b8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007bb:	89 f0                	mov    %esi,%eax
  8007bd:	c1 f8 1f             	sar    $0x1f,%eax
  8007c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007c3:	eb 16                	jmp    8007db <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 04             	lea    0x4(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 30                	mov    (%eax),%esi
  8007d0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007d3:	89 f0                	mov    %esi,%eax
  8007d5:	c1 f8 1f             	sar    $0x1f,%eax
  8007d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007db:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007e7:	85 d2                	test   %edx,%edx
  8007e9:	79 28                	jns    800813 <vprintfmt+0x34f>
				putch('-', putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	53                   	push   %ebx
  8007ef:	6a 2d                	push   $0x2d
  8007f1:	ff d7                	call   *%edi
				num = -(long long) num;
  8007f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007f9:	f7 d8                	neg    %eax
  8007fb:	83 d2 00             	adc    $0x0,%edx
  8007fe:	f7 da                	neg    %edx
  800800:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800803:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800806:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800809:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080e:	e9 b2 00 00 00       	jmp    8008c5 <vprintfmt+0x401>
  800813:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800818:	85 c9                	test   %ecx,%ecx
  80081a:	0f 84 a5 00 00 00    	je     8008c5 <vprintfmt+0x401>
				putch('+', putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	6a 2b                	push   $0x2b
  800826:	ff d7                	call   *%edi
  800828:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  80082b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800830:	e9 90 00 00 00       	jmp    8008c5 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800835:	85 c9                	test   %ecx,%ecx
  800837:	74 0b                	je     800844 <vprintfmt+0x380>
				putch('+', putdat);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	53                   	push   %ebx
  80083d:	6a 2b                	push   $0x2b
  80083f:	ff d7                	call   *%edi
  800841:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800844:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
  80084a:	e8 01 fc ff ff       	call   800450 <getuint>
  80084f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800852:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800855:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80085a:	eb 69                	jmp    8008c5 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 30                	push   $0x30
  800862:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800864:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
  80086a:	e8 e1 fb ff ff       	call   800450 <getuint>
  80086f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800872:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800875:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800878:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80087d:	eb 46                	jmp    8008c5 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	53                   	push   %ebx
  800883:	6a 30                	push   $0x30
  800885:	ff d7                	call   *%edi
			putch('x', putdat);
  800887:	83 c4 08             	add    $0x8,%esp
  80088a:	53                   	push   %ebx
  80088b:	6a 78                	push   $0x78
  80088d:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8d 50 04             	lea    0x4(%eax),%edx
  800895:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800898:	8b 00                	mov    (%eax),%eax
  80089a:	ba 00 00 00 00       	mov    $0x0,%edx
  80089f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008a5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ad:	eb 16                	jmp    8008c5 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008af:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b5:	e8 96 fb ff ff       	call   800450 <getuint>
  8008ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008c0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008c5:	83 ec 0c             	sub    $0xc,%esp
  8008c8:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008cc:	56                   	push   %esi
  8008cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008d0:	50                   	push   %eax
  8008d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8008d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8008d7:	89 da                	mov    %ebx,%edx
  8008d9:	89 f8                	mov    %edi,%eax
  8008db:	e8 55 f9 ff ff       	call   800235 <printnum>
			break;
  8008e0:	83 c4 20             	add    $0x20,%esp
  8008e3:	e9 f0 fb ff ff       	jmp    8004d8 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f1:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8008f3:	85 f6                	test   %esi,%esi
  8008f5:	75 1a                	jne    800911 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	68 8c 16 80 00       	push   $0x80168c
  8008ff:	68 f4 15 80 00       	push   $0x8015f4
  800904:	e8 18 f9 ff ff       	call   800221 <cprintf>
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	e9 c7 fb ff ff       	jmp    8004d8 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800911:	0f b6 03             	movzbl (%ebx),%eax
  800914:	84 c0                	test   %al,%al
  800916:	79 1f                	jns    800937 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800918:	83 ec 08             	sub    $0x8,%esp
  80091b:	68 c4 16 80 00       	push   $0x8016c4
  800920:	68 f4 15 80 00       	push   $0x8015f4
  800925:	e8 f7 f8 ff ff       	call   800221 <cprintf>
						*tmp = *(char *)putdat;
  80092a:	0f b6 03             	movzbl (%ebx),%eax
  80092d:	88 06                	mov    %al,(%esi)
  80092f:	83 c4 10             	add    $0x10,%esp
  800932:	e9 a1 fb ff ff       	jmp    8004d8 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800937:	88 06                	mov    %al,(%esi)
  800939:	e9 9a fb ff ff       	jmp    8004d8 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	53                   	push   %ebx
  800942:	52                   	push   %edx
  800943:	ff d7                	call   *%edi
			break;
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	e9 8b fb ff ff       	jmp    8004d8 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80094d:	83 ec 08             	sub    $0x8,%esp
  800950:	53                   	push   %ebx
  800951:	6a 25                	push   $0x25
  800953:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80095c:	0f 84 73 fb ff ff    	je     8004d5 <vprintfmt+0x11>
  800962:	83 ee 01             	sub    $0x1,%esi
  800965:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800969:	75 f7                	jne    800962 <vprintfmt+0x49e>
  80096b:	89 75 10             	mov    %esi,0x10(%ebp)
  80096e:	e9 65 fb ff ff       	jmp    8004d8 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800973:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800976:	8d 70 01             	lea    0x1(%eax),%esi
  800979:	0f b6 00             	movzbl (%eax),%eax
  80097c:	0f be d0             	movsbl %al,%edx
  80097f:	85 d2                	test   %edx,%edx
  800981:	0f 85 cf fd ff ff    	jne    800756 <vprintfmt+0x292>
  800987:	e9 4c fb ff ff       	jmp    8004d8 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80098c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 18             	sub    $0x18,%esp
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	74 26                	je     8009db <vsnprintf+0x47>
  8009b5:	85 d2                	test   %edx,%edx
  8009b7:	7e 22                	jle    8009db <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b9:	ff 75 14             	pushl  0x14(%ebp)
  8009bc:	ff 75 10             	pushl  0x10(%ebp)
  8009bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c2:	50                   	push   %eax
  8009c3:	68 8a 04 80 00       	push   $0x80048a
  8009c8:	e8 f7 fa ff ff       	call   8004c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d6:	83 c4 10             	add    $0x10,%esp
  8009d9:	eb 05                	jmp    8009e0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009eb:	50                   	push   %eax
  8009ec:	ff 75 10             	pushl  0x10(%ebp)
  8009ef:	ff 75 0c             	pushl  0xc(%ebp)
  8009f2:	ff 75 08             	pushl  0x8(%ebp)
  8009f5:	e8 9a ff ff ff       	call   800994 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a02:	80 3a 00             	cmpb   $0x0,(%edx)
  800a05:	74 10                	je     800a17 <strlen+0x1b>
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a0c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a13:	75 f7                	jne    800a0c <strlen+0x10>
  800a15:	eb 05                	jmp    800a1c <strlen+0x20>
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a28:	85 c9                	test   %ecx,%ecx
  800a2a:	74 1c                	je     800a48 <strnlen+0x2a>
  800a2c:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a2f:	74 1e                	je     800a4f <strnlen+0x31>
  800a31:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a36:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a38:	39 ca                	cmp    %ecx,%edx
  800a3a:	74 18                	je     800a54 <strnlen+0x36>
  800a3c:	83 c2 01             	add    $0x1,%edx
  800a3f:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a44:	75 f0                	jne    800a36 <strnlen+0x18>
  800a46:	eb 0c                	jmp    800a54 <strnlen+0x36>
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4d:	eb 05                	jmp    800a54 <strnlen+0x36>
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a54:	5b                   	pop    %ebx
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a61:	89 c2                	mov    %eax,%edx
  800a63:	83 c2 01             	add    $0x1,%edx
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a6d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a70:	84 db                	test   %bl,%bl
  800a72:	75 ef                	jne    800a63 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a74:	5b                   	pop    %ebx
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	53                   	push   %ebx
  800a7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a7e:	53                   	push   %ebx
  800a7f:	e8 78 ff ff ff       	call   8009fc <strlen>
  800a84:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a87:	ff 75 0c             	pushl  0xc(%ebp)
  800a8a:	01 d8                	add    %ebx,%eax
  800a8c:	50                   	push   %eax
  800a8d:	e8 c5 ff ff ff       	call   800a57 <strcpy>
	return dst;
}
  800a92:	89 d8                	mov    %ebx,%eax
  800a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa7:	85 db                	test   %ebx,%ebx
  800aa9:	74 17                	je     800ac2 <strncpy+0x29>
  800aab:	01 f3                	add    %esi,%ebx
  800aad:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	0f b6 02             	movzbl (%edx),%eax
  800ab5:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab8:	80 3a 01             	cmpb   $0x1,(%edx)
  800abb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800abe:	39 cb                	cmp    %ecx,%ebx
  800ac0:	75 ed                	jne    800aaf <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac2:	89 f0                	mov    %esi,%eax
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad3:	8b 55 10             	mov    0x10(%ebp),%edx
  800ad6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad8:	85 d2                	test   %edx,%edx
  800ada:	74 35                	je     800b11 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800adc:	89 d0                	mov    %edx,%eax
  800ade:	83 e8 01             	sub    $0x1,%eax
  800ae1:	74 25                	je     800b08 <strlcpy+0x40>
  800ae3:	0f b6 0b             	movzbl (%ebx),%ecx
  800ae6:	84 c9                	test   %cl,%cl
  800ae8:	74 22                	je     800b0c <strlcpy+0x44>
  800aea:	8d 53 01             	lea    0x1(%ebx),%edx
  800aed:	01 c3                	add    %eax,%ebx
  800aef:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800af1:	83 c0 01             	add    $0x1,%eax
  800af4:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af7:	39 da                	cmp    %ebx,%edx
  800af9:	74 13                	je     800b0e <strlcpy+0x46>
  800afb:	83 c2 01             	add    $0x1,%edx
  800afe:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800b02:	84 c9                	test   %cl,%cl
  800b04:	75 eb                	jne    800af1 <strlcpy+0x29>
  800b06:	eb 06                	jmp    800b0e <strlcpy+0x46>
  800b08:	89 f0                	mov    %esi,%eax
  800b0a:	eb 02                	jmp    800b0e <strlcpy+0x46>
  800b0c:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b0e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b11:	29 f0                	sub    %esi,%eax
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b20:	0f b6 01             	movzbl (%ecx),%eax
  800b23:	84 c0                	test   %al,%al
  800b25:	74 15                	je     800b3c <strcmp+0x25>
  800b27:	3a 02                	cmp    (%edx),%al
  800b29:	75 11                	jne    800b3c <strcmp+0x25>
		p++, q++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
  800b2e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b31:	0f b6 01             	movzbl (%ecx),%eax
  800b34:	84 c0                	test   %al,%al
  800b36:	74 04                	je     800b3c <strcmp+0x25>
  800b38:	3a 02                	cmp    (%edx),%al
  800b3a:	74 ef                	je     800b2b <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3c:	0f b6 c0             	movzbl %al,%eax
  800b3f:	0f b6 12             	movzbl (%edx),%edx
  800b42:	29 d0                	sub    %edx,%eax
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b51:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b54:	85 f6                	test   %esi,%esi
  800b56:	74 29                	je     800b81 <strncmp+0x3b>
  800b58:	0f b6 03             	movzbl (%ebx),%eax
  800b5b:	84 c0                	test   %al,%al
  800b5d:	74 30                	je     800b8f <strncmp+0x49>
  800b5f:	3a 02                	cmp    (%edx),%al
  800b61:	75 2c                	jne    800b8f <strncmp+0x49>
  800b63:	8d 43 01             	lea    0x1(%ebx),%eax
  800b66:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b68:	89 c3                	mov    %eax,%ebx
  800b6a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b6d:	39 c6                	cmp    %eax,%esi
  800b6f:	74 17                	je     800b88 <strncmp+0x42>
  800b71:	0f b6 08             	movzbl (%eax),%ecx
  800b74:	84 c9                	test   %cl,%cl
  800b76:	74 17                	je     800b8f <strncmp+0x49>
  800b78:	83 c0 01             	add    $0x1,%eax
  800b7b:	3a 0a                	cmp    (%edx),%cl
  800b7d:	74 e9                	je     800b68 <strncmp+0x22>
  800b7f:	eb 0e                	jmp    800b8f <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	eb 0f                	jmp    800b97 <strncmp+0x51>
  800b88:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8d:	eb 08                	jmp    800b97 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b8f:	0f b6 03             	movzbl (%ebx),%eax
  800b92:	0f b6 12             	movzbl (%edx),%edx
  800b95:	29 d0                	sub    %edx,%eax
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ba5:	0f b6 10             	movzbl (%eax),%edx
  800ba8:	84 d2                	test   %dl,%dl
  800baa:	74 1d                	je     800bc9 <strchr+0x2e>
  800bac:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800bae:	38 d3                	cmp    %dl,%bl
  800bb0:	75 06                	jne    800bb8 <strchr+0x1d>
  800bb2:	eb 1a                	jmp    800bce <strchr+0x33>
  800bb4:	38 ca                	cmp    %cl,%dl
  800bb6:	74 16                	je     800bce <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bb8:	83 c0 01             	add    $0x1,%eax
  800bbb:	0f b6 10             	movzbl (%eax),%edx
  800bbe:	84 d2                	test   %dl,%dl
  800bc0:	75 f2                	jne    800bb4 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc7:	eb 05                	jmp    800bce <strchr+0x33>
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	53                   	push   %ebx
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bdb:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bde:	38 d3                	cmp    %dl,%bl
  800be0:	74 14                	je     800bf6 <strfind+0x25>
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	84 db                	test   %bl,%bl
  800be6:	74 0e                	je     800bf6 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800be8:	83 c0 01             	add    $0x1,%eax
  800beb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bee:	38 ca                	cmp    %cl,%dl
  800bf0:	74 04                	je     800bf6 <strfind+0x25>
  800bf2:	84 d2                	test   %dl,%dl
  800bf4:	75 f2                	jne    800be8 <strfind+0x17>
			break;
	return (char *) s;
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c05:	85 c9                	test   %ecx,%ecx
  800c07:	74 36                	je     800c3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0f:	75 28                	jne    800c39 <memset+0x40>
  800c11:	f6 c1 03             	test   $0x3,%cl
  800c14:	75 23                	jne    800c39 <memset+0x40>
		c &= 0xFF;
  800c16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	c1 e3 08             	shl    $0x8,%ebx
  800c1f:	89 d6                	mov    %edx,%esi
  800c21:	c1 e6 18             	shl    $0x18,%esi
  800c24:	89 d0                	mov    %edx,%eax
  800c26:	c1 e0 10             	shl    $0x10,%eax
  800c29:	09 f0                	or     %esi,%eax
  800c2b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c2d:	89 d8                	mov    %ebx,%eax
  800c2f:	09 d0                	or     %edx,%eax
  800c31:	c1 e9 02             	shr    $0x2,%ecx
  800c34:	fc                   	cld    
  800c35:	f3 ab                	rep stos %eax,%es:(%edi)
  800c37:	eb 06                	jmp    800c3f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3c:	fc                   	cld    
  800c3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c3f:	89 f8                	mov    %edi,%eax
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c54:	39 c6                	cmp    %eax,%esi
  800c56:	73 35                	jae    800c8d <memmove+0x47>
  800c58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c5b:	39 d0                	cmp    %edx,%eax
  800c5d:	73 2e                	jae    800c8d <memmove+0x47>
		s += n;
		d += n;
  800c5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c62:	89 d6                	mov    %edx,%esi
  800c64:	09 fe                	or     %edi,%esi
  800c66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c6c:	75 13                	jne    800c81 <memmove+0x3b>
  800c6e:	f6 c1 03             	test   $0x3,%cl
  800c71:	75 0e                	jne    800c81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c73:	83 ef 04             	sub    $0x4,%edi
  800c76:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c79:	c1 e9 02             	shr    $0x2,%ecx
  800c7c:	fd                   	std    
  800c7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7f:	eb 09                	jmp    800c8a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c81:	83 ef 01             	sub    $0x1,%edi
  800c84:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c87:	fd                   	std    
  800c88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c8a:	fc                   	cld    
  800c8b:	eb 1d                	jmp    800caa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8d:	89 f2                	mov    %esi,%edx
  800c8f:	09 c2                	or     %eax,%edx
  800c91:	f6 c2 03             	test   $0x3,%dl
  800c94:	75 0f                	jne    800ca5 <memmove+0x5f>
  800c96:	f6 c1 03             	test   $0x3,%cl
  800c99:	75 0a                	jne    800ca5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c9b:	c1 e9 02             	shr    $0x2,%ecx
  800c9e:	89 c7                	mov    %eax,%edi
  800ca0:	fc                   	cld    
  800ca1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca3:	eb 05                	jmp    800caa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ca5:	89 c7                	mov    %eax,%edi
  800ca7:	fc                   	cld    
  800ca8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cb1:	ff 75 10             	pushl  0x10(%ebp)
  800cb4:	ff 75 0c             	pushl  0xc(%ebp)
  800cb7:	ff 75 08             	pushl  0x8(%ebp)
  800cba:	e8 87 ff ff ff       	call   800c46 <memmove>
}
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccd:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	74 39                	je     800d0d <memcmp+0x4c>
  800cd4:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cd7:	0f b6 13             	movzbl (%ebx),%edx
  800cda:	0f b6 0e             	movzbl (%esi),%ecx
  800cdd:	38 ca                	cmp    %cl,%dl
  800cdf:	75 17                	jne    800cf8 <memcmp+0x37>
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce6:	eb 1a                	jmp    800d02 <memcmp+0x41>
  800ce8:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800ced:	83 c0 01             	add    $0x1,%eax
  800cf0:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cf4:	38 ca                	cmp    %cl,%dl
  800cf6:	74 0a                	je     800d02 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cf8:	0f b6 c2             	movzbl %dl,%eax
  800cfb:	0f b6 c9             	movzbl %cl,%ecx
  800cfe:	29 c8                	sub    %ecx,%eax
  800d00:	eb 10                	jmp    800d12 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d02:	39 f8                	cmp    %edi,%eax
  800d04:	75 e2                	jne    800ce8 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d06:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0b:	eb 05                	jmp    800d12 <memcmp+0x51>
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	53                   	push   %ebx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d1e:	89 d0                	mov    %edx,%eax
  800d20:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d23:	39 c2                	cmp    %eax,%edx
  800d25:	73 1d                	jae    800d44 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d27:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d2b:	0f b6 0a             	movzbl (%edx),%ecx
  800d2e:	39 d9                	cmp    %ebx,%ecx
  800d30:	75 09                	jne    800d3b <memfind+0x24>
  800d32:	eb 14                	jmp    800d48 <memfind+0x31>
  800d34:	0f b6 0a             	movzbl (%edx),%ecx
  800d37:	39 d9                	cmp    %ebx,%ecx
  800d39:	74 11                	je     800d4c <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d3b:	83 c2 01             	add    $0x1,%edx
  800d3e:	39 d0                	cmp    %edx,%eax
  800d40:	75 f2                	jne    800d34 <memfind+0x1d>
  800d42:	eb 0a                	jmp    800d4e <memfind+0x37>
  800d44:	89 d0                	mov    %edx,%eax
  800d46:	eb 06                	jmp    800d4e <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d48:	89 d0                	mov    %edx,%eax
  800d4a:	eb 02                	jmp    800d4e <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d4c:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5d:	0f b6 01             	movzbl (%ecx),%eax
  800d60:	3c 20                	cmp    $0x20,%al
  800d62:	74 04                	je     800d68 <strtol+0x17>
  800d64:	3c 09                	cmp    $0x9,%al
  800d66:	75 0e                	jne    800d76 <strtol+0x25>
		s++;
  800d68:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6b:	0f b6 01             	movzbl (%ecx),%eax
  800d6e:	3c 20                	cmp    $0x20,%al
  800d70:	74 f6                	je     800d68 <strtol+0x17>
  800d72:	3c 09                	cmp    $0x9,%al
  800d74:	74 f2                	je     800d68 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d76:	3c 2b                	cmp    $0x2b,%al
  800d78:	75 0a                	jne    800d84 <strtol+0x33>
		s++;
  800d7a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d82:	eb 11                	jmp    800d95 <strtol+0x44>
  800d84:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d89:	3c 2d                	cmp    $0x2d,%al
  800d8b:	75 08                	jne    800d95 <strtol+0x44>
		s++, neg = 1;
  800d8d:	83 c1 01             	add    $0x1,%ecx
  800d90:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d9b:	75 15                	jne    800db2 <strtol+0x61>
  800d9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800da0:	75 10                	jne    800db2 <strtol+0x61>
  800da2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800da6:	75 7c                	jne    800e24 <strtol+0xd3>
		s += 2, base = 16;
  800da8:	83 c1 02             	add    $0x2,%ecx
  800dab:	bb 10 00 00 00       	mov    $0x10,%ebx
  800db0:	eb 16                	jmp    800dc8 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800db2:	85 db                	test   %ebx,%ebx
  800db4:	75 12                	jne    800dc8 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800db6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dbb:	80 39 30             	cmpb   $0x30,(%ecx)
  800dbe:	75 08                	jne    800dc8 <strtol+0x77>
		s++, base = 8;
  800dc0:	83 c1 01             	add    $0x1,%ecx
  800dc3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800dc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd0:	0f b6 11             	movzbl (%ecx),%edx
  800dd3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dd6:	89 f3                	mov    %esi,%ebx
  800dd8:	80 fb 09             	cmp    $0x9,%bl
  800ddb:	77 08                	ja     800de5 <strtol+0x94>
			dig = *s - '0';
  800ddd:	0f be d2             	movsbl %dl,%edx
  800de0:	83 ea 30             	sub    $0x30,%edx
  800de3:	eb 22                	jmp    800e07 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800de5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800de8:	89 f3                	mov    %esi,%ebx
  800dea:	80 fb 19             	cmp    $0x19,%bl
  800ded:	77 08                	ja     800df7 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800def:	0f be d2             	movsbl %dl,%edx
  800df2:	83 ea 57             	sub    $0x57,%edx
  800df5:	eb 10                	jmp    800e07 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800df7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dfa:	89 f3                	mov    %esi,%ebx
  800dfc:	80 fb 19             	cmp    $0x19,%bl
  800dff:	77 16                	ja     800e17 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800e01:	0f be d2             	movsbl %dl,%edx
  800e04:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e07:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e0a:	7d 0b                	jge    800e17 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e0c:	83 c1 01             	add    $0x1,%ecx
  800e0f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e13:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e15:	eb b9                	jmp    800dd0 <strtol+0x7f>

	if (endptr)
  800e17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e1b:	74 0d                	je     800e2a <strtol+0xd9>
		*endptr = (char *) s;
  800e1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e20:	89 0e                	mov    %ecx,(%esi)
  800e22:	eb 06                	jmp    800e2a <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e24:	85 db                	test   %ebx,%ebx
  800e26:	74 98                	je     800dc0 <strtol+0x6f>
  800e28:	eb 9e                	jmp    800dc8 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e2a:	89 c2                	mov    %eax,%edx
  800e2c:	f7 da                	neg    %edx
  800e2e:	85 ff                	test   %edi,%edi
  800e30:	0f 45 c2             	cmovne %edx,%eax
}
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	57                   	push   %edi
  800e3c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	89 c3                	mov    %eax,%ebx
  800e4a:	89 c7                	mov    %eax,%edi
  800e4c:	51                   	push   %ecx
  800e4d:	52                   	push   %edx
  800e4e:	53                   	push   %ebx
  800e4f:	56                   	push   %esi
  800e50:	57                   	push   %edi
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	8d 35 5c 0e 80 00    	lea    0x800e5c,%esi
  800e5a:	0f 34                	sysenter 

00800e5c <label_21>:
  800e5c:	89 ec                	mov    %ebp,%esp
  800e5e:	5d                   	pop    %ebp
  800e5f:	5f                   	pop    %edi
  800e60:	5e                   	pop    %esi
  800e61:	5b                   	pop    %ebx
  800e62:	5a                   	pop    %edx
  800e63:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e64:	5b                   	pop    %ebx
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e72:	b8 01 00 00 00       	mov    $0x1,%eax
  800e77:	89 ca                	mov    %ecx,%edx
  800e79:	89 cb                	mov    %ecx,%ebx
  800e7b:	89 cf                	mov    %ecx,%edi
  800e7d:	51                   	push   %ecx
  800e7e:	52                   	push   %edx
  800e7f:	53                   	push   %ebx
  800e80:	56                   	push   %esi
  800e81:	57                   	push   %edi
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	8d 35 8d 0e 80 00    	lea    0x800e8d,%esi
  800e8b:	0f 34                	sysenter 

00800e8d <label_55>:
  800e8d:	89 ec                	mov    %ebp,%esp
  800e8f:	5d                   	pop    %ebp
  800e90:	5f                   	pop    %edi
  800e91:	5e                   	pop    %esi
  800e92:	5b                   	pop    %ebx
  800e93:	5a                   	pop    %edx
  800e94:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e95:	5b                   	pop    %ebx
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	89 d9                	mov    %ebx,%ecx
  800ead:	89 df                	mov    %ebx,%edi
  800eaf:	51                   	push   %ecx
  800eb0:	52                   	push   %edx
  800eb1:	53                   	push   %ebx
  800eb2:	56                   	push   %esi
  800eb3:	57                   	push   %edi
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	8d 35 bf 0e 80 00    	lea    0x800ebf,%esi
  800ebd:	0f 34                	sysenter 

00800ebf <label_90>:
  800ebf:	89 ec                	mov    %ebp,%esp
  800ec1:	5d                   	pop    %ebp
  800ec2:	5f                   	pop    %edi
  800ec3:	5e                   	pop    %esi
  800ec4:	5b                   	pop    %ebx
  800ec5:	5a                   	pop    %edx
  800ec6:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 17                	jle    800ee2 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 03                	push   $0x3
  800ed1:	68 a4 18 80 00       	push   $0x8018a4
  800ed6:	6a 29                	push   $0x29
  800ed8:	68 c1 18 80 00       	push   $0x8018c1
  800edd:	e8 4c f2 ff ff       	call   80012e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ee2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ef8:	89 ca                	mov    %ecx,%edx
  800efa:	89 cb                	mov    %ecx,%ebx
  800efc:	89 cf                	mov    %ecx,%edi
  800efe:	51                   	push   %ecx
  800eff:	52                   	push   %edx
  800f00:	53                   	push   %ebx
  800f01:	56                   	push   %esi
  800f02:	57                   	push   %edi
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	8d 35 0e 0f 80 00    	lea    0x800f0e,%esi
  800f0c:	0f 34                	sysenter 

00800f0e <label_139>:
  800f0e:	89 ec                	mov    %ebp,%esp
  800f10:	5d                   	pop    %ebp
  800f11:	5f                   	pop    %edi
  800f12:	5e                   	pop    %esi
  800f13:	5b                   	pop    %ebx
  800f14:	5a                   	pop    %edx
  800f15:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f16:	5b                   	pop    %ebx
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f24:	b8 04 00 00 00       	mov    $0x4,%eax
  800f29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2f:	89 fb                	mov    %edi,%ebx
  800f31:	51                   	push   %ecx
  800f32:	52                   	push   %edx
  800f33:	53                   	push   %ebx
  800f34:	56                   	push   %esi
  800f35:	57                   	push   %edi
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	8d 35 41 0f 80 00    	lea    0x800f41,%esi
  800f3f:	0f 34                	sysenter 

00800f41 <label_174>:
  800f41:	89 ec                	mov    %ebp,%esp
  800f43:	5d                   	pop    %ebp
  800f44:	5f                   	pop    %edi
  800f45:	5e                   	pop    %esi
  800f46:	5b                   	pop    %ebx
  800f47:	5a                   	pop    %edx
  800f48:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f49:	5b                   	pop    %ebx
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <sys_yield>:

void
sys_yield(void)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f52:	ba 00 00 00 00       	mov    $0x0,%edx
  800f57:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f5c:	89 d1                	mov    %edx,%ecx
  800f5e:	89 d3                	mov    %edx,%ebx
  800f60:	89 d7                	mov    %edx,%edi
  800f62:	51                   	push   %ecx
  800f63:	52                   	push   %edx
  800f64:	53                   	push   %ebx
  800f65:	56                   	push   %esi
  800f66:	57                   	push   %edi
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	8d 35 72 0f 80 00    	lea    0x800f72,%esi
  800f70:	0f 34                	sysenter 

00800f72 <label_209>:
  800f72:	89 ec                	mov    %ebp,%esp
  800f74:	5d                   	pop    %ebp
  800f75:	5f                   	pop    %edi
  800f76:	5e                   	pop    %esi
  800f77:	5b                   	pop    %ebx
  800f78:	5a                   	pop    %edx
  800f79:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f7a:	5b                   	pop    %ebx
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f83:	bf 00 00 00 00       	mov    $0x0,%edi
  800f88:	b8 05 00 00 00       	mov    $0x5,%eax
  800f8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f90:	8b 55 08             	mov    0x8(%ebp),%edx
  800f93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f96:	51                   	push   %ecx
  800f97:	52                   	push   %edx
  800f98:	53                   	push   %ebx
  800f99:	56                   	push   %esi
  800f9a:	57                   	push   %edi
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	8d 35 a6 0f 80 00    	lea    0x800fa6,%esi
  800fa4:	0f 34                	sysenter 

00800fa6 <label_244>:
  800fa6:	89 ec                	mov    %ebp,%esp
  800fa8:	5d                   	pop    %ebp
  800fa9:	5f                   	pop    %edi
  800faa:	5e                   	pop    %esi
  800fab:	5b                   	pop    %ebx
  800fac:	5a                   	pop    %edx
  800fad:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 17                	jle    800fc9 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb2:	83 ec 0c             	sub    $0xc,%esp
  800fb5:	50                   	push   %eax
  800fb6:	6a 05                	push   $0x5
  800fb8:	68 a4 18 80 00       	push   $0x8018a4
  800fbd:	6a 29                	push   $0x29
  800fbf:	68 c1 18 80 00       	push   $0x8018c1
  800fc4:	e8 65 f1 ff ff       	call   80012e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800fde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe1:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800fe4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800fea:	8b 45 14             	mov    0x14(%ebp),%eax
  800fed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800ff0:	8b 45 18             	mov    0x18(%ebp),%eax
  800ff3:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800ff9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ffe:	b8 06 00 00 00       	mov    $0x6,%eax
  801003:	89 cb                	mov    %ecx,%ebx
  801005:	89 cf                	mov    %ecx,%edi
  801007:	51                   	push   %ecx
  801008:	52                   	push   %edx
  801009:	53                   	push   %ebx
  80100a:	56                   	push   %esi
  80100b:	57                   	push   %edi
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	8d 35 17 10 80 00    	lea    0x801017,%esi
  801015:	0f 34                	sysenter 

00801017 <label_304>:
  801017:	89 ec                	mov    %ebp,%esp
  801019:	5d                   	pop    %ebp
  80101a:	5f                   	pop    %edi
  80101b:	5e                   	pop    %esi
  80101c:	5b                   	pop    %ebx
  80101d:	5a                   	pop    %edx
  80101e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80101f:	85 c0                	test   %eax,%eax
  801021:	7e 17                	jle    80103a <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	50                   	push   %eax
  801027:	6a 06                	push   $0x6
  801029:	68 a4 18 80 00       	push   $0x8018a4
  80102e:	6a 29                	push   $0x29
  801030:	68 c1 18 80 00       	push   $0x8018c1
  801035:	e8 f4 f0 ff ff       	call   80012e <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  80103a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103d:	5b                   	pop    %ebx
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801046:	bf 00 00 00 00       	mov    $0x0,%edi
  80104b:	b8 07 00 00 00       	mov    $0x7,%eax
  801050:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801053:	8b 55 08             	mov    0x8(%ebp),%edx
  801056:	89 fb                	mov    %edi,%ebx
  801058:	51                   	push   %ecx
  801059:	52                   	push   %edx
  80105a:	53                   	push   %ebx
  80105b:	56                   	push   %esi
  80105c:	57                   	push   %edi
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	8d 35 68 10 80 00    	lea    0x801068,%esi
  801066:	0f 34                	sysenter 

00801068 <label_353>:
  801068:	89 ec                	mov    %ebp,%esp
  80106a:	5d                   	pop    %ebp
  80106b:	5f                   	pop    %edi
  80106c:	5e                   	pop    %esi
  80106d:	5b                   	pop    %ebx
  80106e:	5a                   	pop    %edx
  80106f:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801070:	85 c0                	test   %eax,%eax
  801072:	7e 17                	jle    80108b <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	50                   	push   %eax
  801078:	6a 07                	push   $0x7
  80107a:	68 a4 18 80 00       	push   $0x8018a4
  80107f:	6a 29                	push   $0x29
  801081:	68 c1 18 80 00       	push   $0x8018c1
  801086:	e8 a3 f0 ff ff       	call   80012e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80108b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5f                   	pop    %edi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801097:	bf 00 00 00 00       	mov    $0x0,%edi
  80109c:	b8 09 00 00 00       	mov    $0x9,%eax
  8010a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a7:	89 fb                	mov    %edi,%ebx
  8010a9:	51                   	push   %ecx
  8010aa:	52                   	push   %edx
  8010ab:	53                   	push   %ebx
  8010ac:	56                   	push   %esi
  8010ad:	57                   	push   %edi
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	8d 35 b9 10 80 00    	lea    0x8010b9,%esi
  8010b7:	0f 34                	sysenter 

008010b9 <label_402>:
  8010b9:	89 ec                	mov    %ebp,%esp
  8010bb:	5d                   	pop    %ebp
  8010bc:	5f                   	pop    %edi
  8010bd:	5e                   	pop    %esi
  8010be:	5b                   	pop    %ebx
  8010bf:	5a                   	pop    %edx
  8010c0:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7e 17                	jle    8010dc <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	50                   	push   %eax
  8010c9:	6a 09                	push   $0x9
  8010cb:	68 a4 18 80 00       	push   $0x8018a4
  8010d0:	6a 29                	push   $0x29
  8010d2:	68 c1 18 80 00       	push   $0x8018c1
  8010d7:	e8 52 f0 ff ff       	call   80012e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f8:	89 fb                	mov    %edi,%ebx
  8010fa:	51                   	push   %ecx
  8010fb:	52                   	push   %edx
  8010fc:	53                   	push   %ebx
  8010fd:	56                   	push   %esi
  8010fe:	57                   	push   %edi
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	8d 35 0a 11 80 00    	lea    0x80110a,%esi
  801108:	0f 34                	sysenter 

0080110a <label_451>:
  80110a:	89 ec                	mov    %ebp,%esp
  80110c:	5d                   	pop    %ebp
  80110d:	5f                   	pop    %edi
  80110e:	5e                   	pop    %esi
  80110f:	5b                   	pop    %ebx
  801110:	5a                   	pop    %edx
  801111:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	7e 17                	jle    80112d <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	50                   	push   %eax
  80111a:	6a 0a                	push   $0xa
  80111c:	68 a4 18 80 00       	push   $0x8018a4
  801121:	6a 29                	push   $0x29
  801123:	68 c1 18 80 00       	push   $0x8018c1
  801128:	e8 01 f0 ff ff       	call   80012e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80112d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801130:	5b                   	pop    %ebx
  801131:	5f                   	pop    %edi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801139:	b8 0c 00 00 00       	mov    $0xc,%eax
  80113e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801141:	8b 55 08             	mov    0x8(%ebp),%edx
  801144:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801147:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114a:	51                   	push   %ecx
  80114b:	52                   	push   %edx
  80114c:	53                   	push   %ebx
  80114d:	56                   	push   %esi
  80114e:	57                   	push   %edi
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	8d 35 5a 11 80 00    	lea    0x80115a,%esi
  801158:	0f 34                	sysenter 

0080115a <label_502>:
  80115a:	89 ec                	mov    %ebp,%esp
  80115c:	5d                   	pop    %ebp
  80115d:	5f                   	pop    %edi
  80115e:	5e                   	pop    %esi
  80115f:	5b                   	pop    %ebx
  801160:	5a                   	pop    %edx
  801161:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801162:	5b                   	pop    %ebx
  801163:	5f                   	pop    %edi
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80116b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801170:	b8 0d 00 00 00       	mov    $0xd,%eax
  801175:	8b 55 08             	mov    0x8(%ebp),%edx
  801178:	89 d9                	mov    %ebx,%ecx
  80117a:	89 df                	mov    %ebx,%edi
  80117c:	51                   	push   %ecx
  80117d:	52                   	push   %edx
  80117e:	53                   	push   %ebx
  80117f:	56                   	push   %esi
  801180:	57                   	push   %edi
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	8d 35 8c 11 80 00    	lea    0x80118c,%esi
  80118a:	0f 34                	sysenter 

0080118c <label_537>:
  80118c:	89 ec                	mov    %ebp,%esp
  80118e:	5d                   	pop    %ebp
  80118f:	5f                   	pop    %edi
  801190:	5e                   	pop    %esi
  801191:	5b                   	pop    %ebx
  801192:	5a                   	pop    %edx
  801193:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801194:	85 c0                	test   %eax,%eax
  801196:	7e 17                	jle    8011af <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	50                   	push   %eax
  80119c:	6a 0d                	push   $0xd
  80119e:	68 a4 18 80 00       	push   $0x8018a4
  8011a3:	6a 29                	push   $0x29
  8011a5:	68 c1 18 80 00       	push   $0x8018c1
  8011aa:	e8 7f ef ff ff       	call   80012e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b2:	5b                   	pop    %ebx
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	57                   	push   %edi
  8011ba:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c8:	89 cb                	mov    %ecx,%ebx
  8011ca:	89 cf                	mov    %ecx,%edi
  8011cc:	51                   	push   %ecx
  8011cd:	52                   	push   %edx
  8011ce:	53                   	push   %ebx
  8011cf:	56                   	push   %esi
  8011d0:	57                   	push   %edi
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	8d 35 dc 11 80 00    	lea    0x8011dc,%esi
  8011da:	0f 34                	sysenter 

008011dc <label_586>:
  8011dc:	89 ec                	mov    %ebp,%esp
  8011de:	5d                   	pop    %ebp
  8011df:	5f                   	pop    %edi
  8011e0:	5e                   	pop    %esi
  8011e1:	5b                   	pop    %ebx
  8011e2:	5a                   	pop    %edx
  8011e3:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011e4:	5b                   	pop    %ebx
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011ee:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  8011f5:	75 3c                	jne    801233 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	6a 07                	push   $0x7
  8011fc:	68 00 f0 bf ee       	push   $0xeebff000
  801201:	6a 00                	push   $0x0
  801203:	e8 76 fd ff ff       	call   800f7e <sys_page_alloc>
		if (r) {
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	74 12                	je     801221 <set_pgfault_handler+0x39>
			panic("set_pgfault_handler: %e\n", r);
  80120f:	50                   	push   %eax
  801210:	68 cf 18 80 00       	push   $0x8018cf
  801215:	6a 22                	push   $0x22
  801217:	68 e8 18 80 00       	push   $0x8018e8
  80121c:	e8 0d ef ff ff       	call   80012e <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	68 3d 12 80 00       	push   $0x80123d
  801229:	6a 00                	push   $0x0
  80122b:	e8 b3 fe ff ff       	call   8010e3 <sys_env_set_pgfault_upcall>
  801230:	83 c4 10             	add    $0x10,%esp
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	a3 14 20 80 00       	mov    %eax,0x802014
}
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80123d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80123e:	a1 14 20 80 00       	mov    0x802014,%eax
	call *%eax
  801243:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801245:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  801248:	8b 44 24 30          	mov    0x30(%esp),%eax
	leal -0x4(%eax), %eax	// preserve space to store trap-time eip
  80124c:	8d 40 fc             	lea    -0x4(%eax),%eax
	movl %eax, 0x30(%esp)
  80124f:	89 44 24 30          	mov    %eax,0x30(%esp)

	movl 0x28(%esp), %ecx
  801253:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801257:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801259:	83 c4 08             	add    $0x8,%esp
	popal
  80125c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  80125d:	83 c4 04             	add    $0x4,%esp
	popfl
  801260:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801261:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801262:	c3                   	ret    
  801263:	66 90                	xchg   %ax,%ax
  801265:	66 90                	xchg   %ax,%ax
  801267:	66 90                	xchg   %ax,%ax
  801269:	66 90                	xchg   %ax,%ax
  80126b:	66 90                	xchg   %ax,%ax
  80126d:	66 90                	xchg   %ax,%ax
  80126f:	90                   	nop

00801270 <__udivdi3>:
  801270:	55                   	push   %ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 1c             	sub    $0x1c,%esp
  801277:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80127b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80127f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801287:	85 f6                	test   %esi,%esi
  801289:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80128d:	89 ca                	mov    %ecx,%edx
  80128f:	89 f8                	mov    %edi,%eax
  801291:	75 3d                	jne    8012d0 <__udivdi3+0x60>
  801293:	39 cf                	cmp    %ecx,%edi
  801295:	0f 87 c5 00 00 00    	ja     801360 <__udivdi3+0xf0>
  80129b:	85 ff                	test   %edi,%edi
  80129d:	89 fd                	mov    %edi,%ebp
  80129f:	75 0b                	jne    8012ac <__udivdi3+0x3c>
  8012a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a6:	31 d2                	xor    %edx,%edx
  8012a8:	f7 f7                	div    %edi
  8012aa:	89 c5                	mov    %eax,%ebp
  8012ac:	89 c8                	mov    %ecx,%eax
  8012ae:	31 d2                	xor    %edx,%edx
  8012b0:	f7 f5                	div    %ebp
  8012b2:	89 c1                	mov    %eax,%ecx
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	89 cf                	mov    %ecx,%edi
  8012b8:	f7 f5                	div    %ebp
  8012ba:	89 c3                	mov    %eax,%ebx
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
  8012d0:	39 ce                	cmp    %ecx,%esi
  8012d2:	77 74                	ja     801348 <__udivdi3+0xd8>
  8012d4:	0f bd fe             	bsr    %esi,%edi
  8012d7:	83 f7 1f             	xor    $0x1f,%edi
  8012da:	0f 84 98 00 00 00    	je     801378 <__udivdi3+0x108>
  8012e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8012e5:	89 f9                	mov    %edi,%ecx
  8012e7:	89 c5                	mov    %eax,%ebp
  8012e9:	29 fb                	sub    %edi,%ebx
  8012eb:	d3 e6                	shl    %cl,%esi
  8012ed:	89 d9                	mov    %ebx,%ecx
  8012ef:	d3 ed                	shr    %cl,%ebp
  8012f1:	89 f9                	mov    %edi,%ecx
  8012f3:	d3 e0                	shl    %cl,%eax
  8012f5:	09 ee                	or     %ebp,%esi
  8012f7:	89 d9                	mov    %ebx,%ecx
  8012f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fd:	89 d5                	mov    %edx,%ebp
  8012ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801303:	d3 ed                	shr    %cl,%ebp
  801305:	89 f9                	mov    %edi,%ecx
  801307:	d3 e2                	shl    %cl,%edx
  801309:	89 d9                	mov    %ebx,%ecx
  80130b:	d3 e8                	shr    %cl,%eax
  80130d:	09 c2                	or     %eax,%edx
  80130f:	89 d0                	mov    %edx,%eax
  801311:	89 ea                	mov    %ebp,%edx
  801313:	f7 f6                	div    %esi
  801315:	89 d5                	mov    %edx,%ebp
  801317:	89 c3                	mov    %eax,%ebx
  801319:	f7 64 24 0c          	mull   0xc(%esp)
  80131d:	39 d5                	cmp    %edx,%ebp
  80131f:	72 10                	jb     801331 <__udivdi3+0xc1>
  801321:	8b 74 24 08          	mov    0x8(%esp),%esi
  801325:	89 f9                	mov    %edi,%ecx
  801327:	d3 e6                	shl    %cl,%esi
  801329:	39 c6                	cmp    %eax,%esi
  80132b:	73 07                	jae    801334 <__udivdi3+0xc4>
  80132d:	39 d5                	cmp    %edx,%ebp
  80132f:	75 03                	jne    801334 <__udivdi3+0xc4>
  801331:	83 eb 01             	sub    $0x1,%ebx
  801334:	31 ff                	xor    %edi,%edi
  801336:	89 d8                	mov    %ebx,%eax
  801338:	89 fa                	mov    %edi,%edx
  80133a:	83 c4 1c             	add    $0x1c,%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    
  801342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801348:	31 ff                	xor    %edi,%edi
  80134a:	31 db                	xor    %ebx,%ebx
  80134c:	89 d8                	mov    %ebx,%eax
  80134e:	89 fa                	mov    %edi,%edx
  801350:	83 c4 1c             	add    $0x1c,%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    
  801358:	90                   	nop
  801359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801360:	89 d8                	mov    %ebx,%eax
  801362:	f7 f7                	div    %edi
  801364:	31 ff                	xor    %edi,%edi
  801366:	89 c3                	mov    %eax,%ebx
  801368:	89 d8                	mov    %ebx,%eax
  80136a:	89 fa                	mov    %edi,%edx
  80136c:	83 c4 1c             	add    $0x1c,%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    
  801374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801378:	39 ce                	cmp    %ecx,%esi
  80137a:	72 0c                	jb     801388 <__udivdi3+0x118>
  80137c:	31 db                	xor    %ebx,%ebx
  80137e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801382:	0f 87 34 ff ff ff    	ja     8012bc <__udivdi3+0x4c>
  801388:	bb 01 00 00 00       	mov    $0x1,%ebx
  80138d:	e9 2a ff ff ff       	jmp    8012bc <__udivdi3+0x4c>
  801392:	66 90                	xchg   %ax,%ax
  801394:	66 90                	xchg   %ax,%ax
  801396:	66 90                	xchg   %ax,%ax
  801398:	66 90                	xchg   %ax,%ax
  80139a:	66 90                	xchg   %ax,%ax
  80139c:	66 90                	xchg   %ax,%ax
  80139e:	66 90                	xchg   %ax,%ax

008013a0 <__umoddi3>:
  8013a0:	55                   	push   %ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 1c             	sub    $0x1c,%esp
  8013a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013b7:	85 d2                	test   %edx,%edx
  8013b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c1:	89 f3                	mov    %esi,%ebx
  8013c3:	89 3c 24             	mov    %edi,(%esp)
  8013c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ca:	75 1c                	jne    8013e8 <__umoddi3+0x48>
  8013cc:	39 f7                	cmp    %esi,%edi
  8013ce:	76 50                	jbe    801420 <__umoddi3+0x80>
  8013d0:	89 c8                	mov    %ecx,%eax
  8013d2:	89 f2                	mov    %esi,%edx
  8013d4:	f7 f7                	div    %edi
  8013d6:	89 d0                	mov    %edx,%eax
  8013d8:	31 d2                	xor    %edx,%edx
  8013da:	83 c4 1c             	add    $0x1c,%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    
  8013e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013e8:	39 f2                	cmp    %esi,%edx
  8013ea:	89 d0                	mov    %edx,%eax
  8013ec:	77 52                	ja     801440 <__umoddi3+0xa0>
  8013ee:	0f bd ea             	bsr    %edx,%ebp
  8013f1:	83 f5 1f             	xor    $0x1f,%ebp
  8013f4:	75 5a                	jne    801450 <__umoddi3+0xb0>
  8013f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8013fa:	0f 82 e0 00 00 00    	jb     8014e0 <__umoddi3+0x140>
  801400:	39 0c 24             	cmp    %ecx,(%esp)
  801403:	0f 86 d7 00 00 00    	jbe    8014e0 <__umoddi3+0x140>
  801409:	8b 44 24 08          	mov    0x8(%esp),%eax
  80140d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801411:	83 c4 1c             	add    $0x1c,%esp
  801414:	5b                   	pop    %ebx
  801415:	5e                   	pop    %esi
  801416:	5f                   	pop    %edi
  801417:	5d                   	pop    %ebp
  801418:	c3                   	ret    
  801419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801420:	85 ff                	test   %edi,%edi
  801422:	89 fd                	mov    %edi,%ebp
  801424:	75 0b                	jne    801431 <__umoddi3+0x91>
  801426:	b8 01 00 00 00       	mov    $0x1,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	f7 f7                	div    %edi
  80142f:	89 c5                	mov    %eax,%ebp
  801431:	89 f0                	mov    %esi,%eax
  801433:	31 d2                	xor    %edx,%edx
  801435:	f7 f5                	div    %ebp
  801437:	89 c8                	mov    %ecx,%eax
  801439:	f7 f5                	div    %ebp
  80143b:	89 d0                	mov    %edx,%eax
  80143d:	eb 99                	jmp    8013d8 <__umoddi3+0x38>
  80143f:	90                   	nop
  801440:	89 c8                	mov    %ecx,%eax
  801442:	89 f2                	mov    %esi,%edx
  801444:	83 c4 1c             	add    $0x1c,%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5f                   	pop    %edi
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    
  80144c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801450:	8b 34 24             	mov    (%esp),%esi
  801453:	bf 20 00 00 00       	mov    $0x20,%edi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	29 ef                	sub    %ebp,%edi
  80145c:	d3 e0                	shl    %cl,%eax
  80145e:	89 f9                	mov    %edi,%ecx
  801460:	89 f2                	mov    %esi,%edx
  801462:	d3 ea                	shr    %cl,%edx
  801464:	89 e9                	mov    %ebp,%ecx
  801466:	09 c2                	or     %eax,%edx
  801468:	89 d8                	mov    %ebx,%eax
  80146a:	89 14 24             	mov    %edx,(%esp)
  80146d:	89 f2                	mov    %esi,%edx
  80146f:	d3 e2                	shl    %cl,%edx
  801471:	89 f9                	mov    %edi,%ecx
  801473:	89 54 24 04          	mov    %edx,0x4(%esp)
  801477:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80147b:	d3 e8                	shr    %cl,%eax
  80147d:	89 e9                	mov    %ebp,%ecx
  80147f:	89 c6                	mov    %eax,%esi
  801481:	d3 e3                	shl    %cl,%ebx
  801483:	89 f9                	mov    %edi,%ecx
  801485:	89 d0                	mov    %edx,%eax
  801487:	d3 e8                	shr    %cl,%eax
  801489:	89 e9                	mov    %ebp,%ecx
  80148b:	09 d8                	or     %ebx,%eax
  80148d:	89 d3                	mov    %edx,%ebx
  80148f:	89 f2                	mov    %esi,%edx
  801491:	f7 34 24             	divl   (%esp)
  801494:	89 d6                	mov    %edx,%esi
  801496:	d3 e3                	shl    %cl,%ebx
  801498:	f7 64 24 04          	mull   0x4(%esp)
  80149c:	39 d6                	cmp    %edx,%esi
  80149e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a2:	89 d1                	mov    %edx,%ecx
  8014a4:	89 c3                	mov    %eax,%ebx
  8014a6:	72 08                	jb     8014b0 <__umoddi3+0x110>
  8014a8:	75 11                	jne    8014bb <__umoddi3+0x11b>
  8014aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014ae:	73 0b                	jae    8014bb <__umoddi3+0x11b>
  8014b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014b4:	1b 14 24             	sbb    (%esp),%edx
  8014b7:	89 d1                	mov    %edx,%ecx
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014bf:	29 da                	sub    %ebx,%edx
  8014c1:	19 ce                	sbb    %ecx,%esi
  8014c3:	89 f9                	mov    %edi,%ecx
  8014c5:	89 f0                	mov    %esi,%eax
  8014c7:	d3 e0                	shl    %cl,%eax
  8014c9:	89 e9                	mov    %ebp,%ecx
  8014cb:	d3 ea                	shr    %cl,%edx
  8014cd:	89 e9                	mov    %ebp,%ecx
  8014cf:	d3 ee                	shr    %cl,%esi
  8014d1:	09 d0                	or     %edx,%eax
  8014d3:	89 f2                	mov    %esi,%edx
  8014d5:	83 c4 1c             	add    $0x1c,%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5f                   	pop    %edi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    
  8014dd:	8d 76 00             	lea    0x0(%esi),%esi
  8014e0:	29 f9                	sub    %edi,%ecx
  8014e2:	19 d6                	sbb    %edx,%esi
  8014e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ec:	e9 18 ff ff ff       	jmp    801409 <__umoddi3+0x69>
