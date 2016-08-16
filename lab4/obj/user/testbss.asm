
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 80 14 80 00       	push   $0x801480
  80003e:	e8 04 02 00 00       	call   800247 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800043:	83 c4 10             	add    $0x10,%esp
  800046:	83 3d 40 20 80 00 00 	cmpl   $0x0,0x802040
  80004d:	75 11                	jne    800060 <umain+0x2d>
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
  800054:	83 3c 85 40 20 80 00 	cmpl   $0x0,0x802040(,%eax,4)
  80005b:	00 
  80005c:	74 19                	je     800077 <umain+0x44>
  80005e:	eb 05                	jmp    800065 <umain+0x32>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	50                   	push   %eax
  800066:	68 fb 14 80 00       	push   $0x8014fb
  80006b:	6a 11                	push   $0x11
  80006d:	68 18 15 80 00       	push   $0x801518
  800072:	e8 dd 00 00 00       	call   800154 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800077:	83 c0 01             	add    $0x1,%eax
  80007a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007f:	75 d3                	jne    800054 <umain+0x21>
  800081:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800086:	89 04 85 40 20 80 00 	mov    %eax,0x802040(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008d:	83 c0 01             	add    $0x1,%eax
  800090:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800095:	75 ef                	jne    800086 <umain+0x53>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800097:	83 3d 40 20 80 00 00 	cmpl   $0x0,0x802040
  80009e:	75 10                	jne    8000b0 <umain+0x7d>
  8000a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a5:	3b 04 85 40 20 80 00 	cmp    0x802040(,%eax,4),%eax
  8000ac:	74 19                	je     8000c7 <umain+0x94>
  8000ae:	eb 05                	jmp    8000b5 <umain+0x82>
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000b5:	50                   	push   %eax
  8000b6:	68 a0 14 80 00       	push   $0x8014a0
  8000bb:	6a 16                	push   $0x16
  8000bd:	68 18 15 80 00       	push   $0x801518
  8000c2:	e8 8d 00 00 00       	call   800154 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000c7:	83 c0 01             	add    $0x1,%eax
  8000ca:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000cf:	75 d4                	jne    8000a5 <umain+0x72>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	68 c8 14 80 00       	push   $0x8014c8
  8000d9:	e8 69 01 00 00       	call   800247 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000de:	c7 05 40 30 c0 00 00 	movl   $0x0,0xc03040
  8000e5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e8:	83 c4 0c             	add    $0xc,%esp
  8000eb:	68 27 15 80 00       	push   $0x801527
  8000f0:	6a 1a                	push   $0x1a
  8000f2:	68 18 15 80 00       	push   $0x801518
  8000f7:	e8 58 00 00 00       	call   800154 <_panic>

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800104:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800107:	e8 03 0e 00 00       	call   800f0f <sys_getenvid>
  80010c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800111:	c1 e0 07             	shl    $0x7,%eax
  800114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800119:	a3 40 20 c0 00       	mov    %eax,0xc02040
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	85 db                	test   %ebx,%ebx
  800120:	7e 07                	jle    800129 <libmain+0x2d>
		binaryname = argv[0];
  800122:	8b 06                	mov    (%esi),%eax
  800124:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
  80012e:	e8 00 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800133:	e8 0a 00 00 00       	call   800142 <exit>
}
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800148:	6a 00                	push   $0x0
  80014a:	e8 70 0d 00 00       	call   800ebf <sys_env_destroy>
}
  80014f:	83 c4 10             	add    $0x10,%esp
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800159:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80015c:	a1 44 20 c0 00       	mov    0xc02044,%eax
  800161:	85 c0                	test   %eax,%eax
  800163:	74 11                	je     800176 <_panic+0x22>
		cprintf("%s: ", argv0);
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	50                   	push   %eax
  800169:	68 48 15 80 00       	push   $0x801548
  80016e:	e8 d4 00 00 00       	call   800247 <cprintf>
  800173:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800176:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80017c:	e8 8e 0d 00 00       	call   800f0f <sys_getenvid>
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	ff 75 0c             	pushl  0xc(%ebp)
  800187:	ff 75 08             	pushl  0x8(%ebp)
  80018a:	56                   	push   %esi
  80018b:	50                   	push   %eax
  80018c:	68 50 15 80 00       	push   $0x801550
  800191:	e8 b1 00 00 00       	call   800247 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800196:	83 c4 18             	add    $0x18,%esp
  800199:	53                   	push   %ebx
  80019a:	ff 75 10             	pushl  0x10(%ebp)
  80019d:	e8 54 00 00 00       	call   8001f6 <vcprintf>
	cprintf("\n");
  8001a2:	c7 04 24 16 15 80 00 	movl   $0x801516,(%esp)
  8001a9:	e8 99 00 00 00       	call   800247 <cprintf>
  8001ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b1:	cc                   	int3   
  8001b2:	eb fd                	jmp    8001b1 <_panic+0x5d>

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 04             	sub    $0x4,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 13                	mov    (%ebx),%edx
  8001c0:	8d 42 01             	lea    0x1(%edx),%eax
  8001c3:	89 03                	mov    %eax,(%ebx)
  8001c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d1:	75 1a                	jne    8001ed <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	68 ff 00 00 00       	push   $0xff
  8001db:	8d 43 08             	lea    0x8(%ebx),%eax
  8001de:	50                   	push   %eax
  8001df:	e8 7a 0c 00 00       	call   800e5e <sys_cputs>
		b->idx = 0;
  8001e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ea:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ed:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800206:	00 00 00 
	b.cnt = 0;
  800209:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800210:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800213:	ff 75 0c             	pushl  0xc(%ebp)
  800216:	ff 75 08             	pushl  0x8(%ebp)
  800219:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021f:	50                   	push   %eax
  800220:	68 b4 01 80 00       	push   $0x8001b4
  800225:	e8 c0 02 00 00       	call   8004ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022a:	83 c4 08             	add    $0x8,%esp
  80022d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800233:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	e8 1f 0c 00 00       	call   800e5e <sys_cputs>

	return b.cnt;
}
  80023f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800250:	50                   	push   %eax
  800251:	ff 75 08             	pushl  0x8(%ebp)
  800254:	e8 9d ff ff ff       	call   8001f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 1c             	sub    $0x1c,%esp
  800264:	89 c7                	mov    %eax,%edi
  800266:	89 d6                	mov    %edx,%esi
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800271:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800274:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800277:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80027b:	0f 85 bf 00 00 00    	jne    800340 <printnum+0xe5>
  800281:	39 1d 24 20 80 00    	cmp    %ebx,0x802024
  800287:	0f 8d de 00 00 00    	jge    80036b <printnum+0x110>
		judge_time_for_space = width;
  80028d:	89 1d 24 20 80 00    	mov    %ebx,0x802024
  800293:	e9 d3 00 00 00       	jmp    80036b <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800298:	83 eb 01             	sub    $0x1,%ebx
  80029b:	85 db                	test   %ebx,%ebx
  80029d:	7f 37                	jg     8002d6 <printnum+0x7b>
  80029f:	e9 ea 00 00 00       	jmp    80038e <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8002a4:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002a7:	a3 20 20 80 00       	mov    %eax,0x802020
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bf:	e8 5c 10 00 00       	call   801320 <__umoddi3>
  8002c4:	83 c4 14             	add    $0x14,%esp
  8002c7:	0f be 80 73 15 80 00 	movsbl 0x801573(%eax),%eax
  8002ce:	50                   	push   %eax
  8002cf:	ff d7                	call   *%edi
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	eb 16                	jmp    8002ec <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8002d6:	83 ec 08             	sub    $0x8,%esp
  8002d9:	56                   	push   %esi
  8002da:	ff 75 18             	pushl  0x18(%ebp)
  8002dd:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8002df:	83 c4 10             	add    $0x10,%esp
  8002e2:	83 eb 01             	sub    $0x1,%ebx
  8002e5:	75 ef                	jne    8002d6 <printnum+0x7b>
  8002e7:	e9 a2 00 00 00       	jmp    80038e <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8002ec:	3b 1d 24 20 80 00    	cmp    0x802024,%ebx
  8002f2:	0f 85 76 01 00 00    	jne    80046e <printnum+0x213>
		while(num_of_space-- > 0)
  8002f8:	a1 20 20 80 00       	mov    0x802020,%eax
  8002fd:	8d 50 ff             	lea    -0x1(%eax),%edx
  800300:	89 15 20 20 80 00    	mov    %edx,0x802020
  800306:	85 c0                	test   %eax,%eax
  800308:	7e 1d                	jle    800327 <printnum+0xcc>
			putch(' ', putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	56                   	push   %esi
  80030e:	6a 20                	push   $0x20
  800310:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800312:	a1 20 20 80 00       	mov    0x802020,%eax
  800317:	8d 50 ff             	lea    -0x1(%eax),%edx
  80031a:	89 15 20 20 80 00    	mov    %edx,0x802020
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	85 c0                	test   %eax,%eax
  800325:	7f e3                	jg     80030a <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800327:	c7 05 20 20 80 00 00 	movl   $0x0,0x802020
  80032e:	00 00 00 
		judge_time_for_space = 0;
  800331:	c7 05 24 20 80 00 00 	movl   $0x0,0x802024
  800338:	00 00 00 
	}
}
  80033b:	e9 2e 01 00 00       	jmp    80046e <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800340:	8b 45 10             	mov    0x10(%ebp),%eax
  800343:	ba 00 00 00 00       	mov    $0x0,%edx
  800348:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80034e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800354:	83 fa 00             	cmp    $0x0,%edx
  800357:	0f 87 ba 00 00 00    	ja     800417 <printnum+0x1bc>
  80035d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800360:	0f 83 b1 00 00 00    	jae    800417 <printnum+0x1bc>
  800366:	e9 2d ff ff ff       	jmp    800298 <printnum+0x3d>
  80036b:	8b 45 10             	mov    0x10(%ebp),%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800376:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800379:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80037f:	83 fa 00             	cmp    $0x0,%edx
  800382:	77 37                	ja     8003bb <printnum+0x160>
  800384:	3b 45 10             	cmp    0x10(%ebp),%eax
  800387:	73 32                	jae    8003bb <printnum+0x160>
  800389:	e9 16 ff ff ff       	jmp    8002a4 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	56                   	push   %esi
  800392:	83 ec 04             	sub    $0x4,%esp
  800395:	ff 75 dc             	pushl  -0x24(%ebp)
  800398:	ff 75 d8             	pushl  -0x28(%ebp)
  80039b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039e:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a1:	e8 7a 0f 00 00       	call   801320 <__umoddi3>
  8003a6:	83 c4 14             	add    $0x14,%esp
  8003a9:	0f be 80 73 15 80 00 	movsbl 0x801573(%eax),%eax
  8003b0:	50                   	push   %eax
  8003b1:	ff d7                	call   *%edi
  8003b3:	83 c4 10             	add    $0x10,%esp
  8003b6:	e9 b3 00 00 00       	jmp    80046e <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003bb:	83 ec 0c             	sub    $0xc,%esp
  8003be:	ff 75 18             	pushl  0x18(%ebp)
  8003c1:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff 75 10             	pushl  0x10(%ebp)
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d7:	e8 14 0e 00 00       	call   8011f0 <__udivdi3>
  8003dc:	83 c4 18             	add    $0x18,%esp
  8003df:	52                   	push   %edx
  8003e0:	50                   	push   %eax
  8003e1:	89 f2                	mov    %esi,%edx
  8003e3:	89 f8                	mov    %edi,%eax
  8003e5:	e8 71 fe ff ff       	call   80025b <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ea:	83 c4 18             	add    $0x18,%esp
  8003ed:	56                   	push   %esi
  8003ee:	83 ec 04             	sub    $0x4,%esp
  8003f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8003fd:	e8 1e 0f 00 00       	call   801320 <__umoddi3>
  800402:	83 c4 14             	add    $0x14,%esp
  800405:	0f be 80 73 15 80 00 	movsbl 0x801573(%eax),%eax
  80040c:	50                   	push   %eax
  80040d:	ff d7                	call   *%edi
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	e9 d5 fe ff ff       	jmp    8002ec <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800417:	83 ec 0c             	sub    $0xc,%esp
  80041a:	ff 75 18             	pushl  0x18(%ebp)
  80041d:	83 eb 01             	sub    $0x1,%ebx
  800420:	53                   	push   %ebx
  800421:	ff 75 10             	pushl  0x10(%ebp)
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	ff 75 dc             	pushl  -0x24(%ebp)
  80042a:	ff 75 d8             	pushl  -0x28(%ebp)
  80042d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800430:	ff 75 e0             	pushl  -0x20(%ebp)
  800433:	e8 b8 0d 00 00       	call   8011f0 <__udivdi3>
  800438:	83 c4 18             	add    $0x18,%esp
  80043b:	52                   	push   %edx
  80043c:	50                   	push   %eax
  80043d:	89 f2                	mov    %esi,%edx
  80043f:	89 f8                	mov    %edi,%eax
  800441:	e8 15 fe ff ff       	call   80025b <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800446:	83 c4 18             	add    $0x18,%esp
  800449:	56                   	push   %esi
  80044a:	83 ec 04             	sub    $0x4,%esp
  80044d:	ff 75 dc             	pushl  -0x24(%ebp)
  800450:	ff 75 d8             	pushl  -0x28(%ebp)
  800453:	ff 75 e4             	pushl  -0x1c(%ebp)
  800456:	ff 75 e0             	pushl  -0x20(%ebp)
  800459:	e8 c2 0e 00 00       	call   801320 <__umoddi3>
  80045e:	83 c4 14             	add    $0x14,%esp
  800461:	0f be 80 73 15 80 00 	movsbl 0x801573(%eax),%eax
  800468:	50                   	push   %eax
  800469:	ff d7                	call   *%edi
  80046b:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80046e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800471:	5b                   	pop    %ebx
  800472:	5e                   	pop    %esi
  800473:	5f                   	pop    %edi
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800479:	83 fa 01             	cmp    $0x1,%edx
  80047c:	7e 0e                	jle    80048c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80047e:	8b 10                	mov    (%eax),%edx
  800480:	8d 4a 08             	lea    0x8(%edx),%ecx
  800483:	89 08                	mov    %ecx,(%eax)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	8b 52 04             	mov    0x4(%edx),%edx
  80048a:	eb 22                	jmp    8004ae <getuint+0x38>
	else if (lflag)
  80048c:	85 d2                	test   %edx,%edx
  80048e:	74 10                	je     8004a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800490:	8b 10                	mov    (%eax),%edx
  800492:	8d 4a 04             	lea    0x4(%edx),%ecx
  800495:	89 08                	mov    %ecx,(%eax)
  800497:	8b 02                	mov    (%edx),%eax
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	eb 0e                	jmp    8004ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ba:	8b 10                	mov    (%eax),%edx
  8004bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bf:	73 0a                	jae    8004cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c4:	89 08                	mov    %ecx,(%eax)
  8004c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c9:	88 02                	mov    %al,(%edx)
}
  8004cb:	5d                   	pop    %ebp
  8004cc:	c3                   	ret    

008004cd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d6:	50                   	push   %eax
  8004d7:	ff 75 10             	pushl  0x10(%ebp)
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	ff 75 08             	pushl  0x8(%ebp)
  8004e0:	e8 05 00 00 00       	call   8004ea <vprintfmt>
	va_end(ap);
}
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    

008004ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	57                   	push   %edi
  8004ee:	56                   	push   %esi
  8004ef:	53                   	push   %ebx
  8004f0:	83 ec 2c             	sub    $0x2c,%esp
  8004f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f9:	eb 03                	jmp    8004fe <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004fb:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800501:	8d 70 01             	lea    0x1(%eax),%esi
  800504:	0f b6 00             	movzbl (%eax),%eax
  800507:	83 f8 25             	cmp    $0x25,%eax
  80050a:	74 27                	je     800533 <vprintfmt+0x49>
			if (ch == '\0')
  80050c:	85 c0                	test   %eax,%eax
  80050e:	75 0d                	jne    80051d <vprintfmt+0x33>
  800510:	e9 9d 04 00 00       	jmp    8009b2 <vprintfmt+0x4c8>
  800515:	85 c0                	test   %eax,%eax
  800517:	0f 84 95 04 00 00    	je     8009b2 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	50                   	push   %eax
  800522:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800524:	83 c6 01             	add    $0x1,%esi
  800527:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	83 f8 25             	cmp    $0x25,%eax
  800531:	75 e2                	jne    800515 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800533:	b9 00 00 00 00       	mov    $0x0,%ecx
  800538:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80053c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800543:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800551:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800558:	eb 08                	jmp    800562 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80055d:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8d 46 01             	lea    0x1(%esi),%eax
  800565:	89 45 10             	mov    %eax,0x10(%ebp)
  800568:	0f b6 06             	movzbl (%esi),%eax
  80056b:	0f b6 d0             	movzbl %al,%edx
  80056e:	83 e8 23             	sub    $0x23,%eax
  800571:	3c 55                	cmp    $0x55,%al
  800573:	0f 87 fa 03 00 00    	ja     800973 <vprintfmt+0x489>
  800579:	0f b6 c0             	movzbl %al,%eax
  80057c:	ff 24 85 c0 16 80 00 	jmp    *0x8016c0(,%eax,4)
  800583:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800586:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80058a:	eb d6                	jmp    800562 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80058c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80058f:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800592:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800596:	8d 50 d0             	lea    -0x30(%eax),%edx
  800599:	83 fa 09             	cmp    $0x9,%edx
  80059c:	77 6b                	ja     800609 <vprintfmt+0x11f>
  80059e:	8b 75 10             	mov    0x10(%ebp),%esi
  8005a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a7:	eb 09                	jmp    8005b2 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ac:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8005b0:	eb b0                	jmp    800562 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b2:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005b5:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005b8:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005bc:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005bf:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005c2:	83 f9 09             	cmp    $0x9,%ecx
  8005c5:	76 eb                	jbe    8005b2 <vprintfmt+0xc8>
  8005c7:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005cd:	eb 3d                	jmp    80060c <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 50 04             	lea    0x4(%eax),%edx
  8005d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e0:	eb 2a                	jmp    80060c <vprintfmt+0x122>
  8005e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e5:	85 c0                	test   %eax,%eax
  8005e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ec:	0f 49 d0             	cmovns %eax,%edx
  8005ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f5:	e9 68 ff ff ff       	jmp    800562 <vprintfmt+0x78>
  8005fa:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800604:	e9 59 ff ff ff       	jmp    800562 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80060c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800610:	0f 89 4c ff ff ff    	jns    800562 <vprintfmt+0x78>
				width = precision, precision = -1;
  800616:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80061c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800623:	e9 3a ff ff ff       	jmp    800562 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800628:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062f:	e9 2e ff ff ff       	jmp    800562 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	ff 30                	pushl  (%eax)
  800643:	ff d7                	call   *%edi
			break;
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	e9 b1 fe ff ff       	jmp    8004fe <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 50 04             	lea    0x4(%eax),%edx
  800653:	89 55 14             	mov    %edx,0x14(%ebp)
  800656:	8b 00                	mov    (%eax),%eax
  800658:	99                   	cltd   
  800659:	31 d0                	xor    %edx,%eax
  80065b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065d:	83 f8 08             	cmp    $0x8,%eax
  800660:	7f 0b                	jg     80066d <vprintfmt+0x183>
  800662:	8b 14 85 20 18 80 00 	mov    0x801820(,%eax,4),%edx
  800669:	85 d2                	test   %edx,%edx
  80066b:	75 15                	jne    800682 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80066d:	50                   	push   %eax
  80066e:	68 8b 15 80 00       	push   $0x80158b
  800673:	53                   	push   %ebx
  800674:	57                   	push   %edi
  800675:	e8 53 fe ff ff       	call   8004cd <printfmt>
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	e9 7c fe ff ff       	jmp    8004fe <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800682:	52                   	push   %edx
  800683:	68 94 15 80 00       	push   $0x801594
  800688:	53                   	push   %ebx
  800689:	57                   	push   %edi
  80068a:	e8 3e fe ff ff       	call   8004cd <printfmt>
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	e9 67 fe ff ff       	jmp    8004fe <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a0:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	b9 84 15 80 00       	mov    $0x801584,%ecx
  8006a9:	0f 45 c8             	cmovne %eax,%ecx
  8006ac:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b3:	7e 06                	jle    8006bb <vprintfmt+0x1d1>
  8006b5:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006b9:	75 19                	jne    8006d4 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006bb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006be:	8d 70 01             	lea    0x1(%eax),%esi
  8006c1:	0f b6 00             	movzbl (%eax),%eax
  8006c4:	0f be d0             	movsbl %al,%edx
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	0f 85 9f 00 00 00    	jne    80076e <vprintfmt+0x284>
  8006cf:	e9 8c 00 00 00       	jmp    800760 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	ff 75 d0             	pushl  -0x30(%ebp)
  8006da:	ff 75 cc             	pushl  -0x34(%ebp)
  8006dd:	e8 62 03 00 00       	call   800a44 <strnlen>
  8006e2:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006e5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	0f 8e a6 02 00 00    	jle    800999 <vprintfmt+0x4af>
					putch(padc, putdat);
  8006f3:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fa:	89 cb                	mov    %ecx,%ebx
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	56                   	push   %esi
  800703:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	83 eb 01             	sub    $0x1,%ebx
  80070b:	75 ef                	jne    8006fc <vprintfmt+0x212>
  80070d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800710:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800713:	e9 81 02 00 00       	jmp    800999 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800718:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071c:	74 1b                	je     800739 <vprintfmt+0x24f>
  80071e:	0f be c0             	movsbl %al,%eax
  800721:	83 e8 20             	sub    $0x20,%eax
  800724:	83 f8 5e             	cmp    $0x5e,%eax
  800727:	76 10                	jbe    800739 <vprintfmt+0x24f>
					putch('?', putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	6a 3f                	push   $0x3f
  800731:	ff 55 08             	call   *0x8(%ebp)
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	eb 0d                	jmp    800746 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	ff 75 0c             	pushl  0xc(%ebp)
  80073f:	52                   	push   %edx
  800740:	ff 55 08             	call   *0x8(%ebp)
  800743:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800746:	83 ef 01             	sub    $0x1,%edi
  800749:	83 c6 01             	add    $0x1,%esi
  80074c:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800750:	0f be d0             	movsbl %al,%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	75 31                	jne    800788 <vprintfmt+0x29e>
  800757:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80075a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800760:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800763:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800767:	7f 33                	jg     80079c <vprintfmt+0x2b2>
  800769:	e9 90 fd ff ff       	jmp    8004fe <vprintfmt+0x14>
  80076e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800771:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800774:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800777:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80077a:	eb 0c                	jmp    800788 <vprintfmt+0x29e>
  80077c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80077f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800782:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800785:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800788:	85 db                	test   %ebx,%ebx
  80078a:	78 8c                	js     800718 <vprintfmt+0x22e>
  80078c:	83 eb 01             	sub    $0x1,%ebx
  80078f:	79 87                	jns    800718 <vprintfmt+0x22e>
  800791:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800794:	8b 7d 08             	mov    0x8(%ebp),%edi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	eb c4                	jmp    800760 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 20                	push   $0x20
  8007a2:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	83 ee 01             	sub    $0x1,%esi
  8007aa:	75 f0                	jne    80079c <vprintfmt+0x2b2>
  8007ac:	e9 4d fd ff ff       	jmp    8004fe <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b1:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8007b5:	7e 16                	jle    8007cd <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 08             	lea    0x8(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c0:	8b 50 04             	mov    0x4(%eax),%edx
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007cb:	eb 34                	jmp    800801 <vprintfmt+0x317>
	else if (lflag)
  8007cd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007d1:	74 18                	je     8007eb <vprintfmt+0x301>
		return va_arg(*ap, long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 04             	lea    0x4(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	8b 30                	mov    (%eax),%esi
  8007de:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007e1:	89 f0                	mov    %esi,%eax
  8007e3:	c1 f8 1f             	sar    $0x1f,%eax
  8007e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007e9:	eb 16                	jmp    800801 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8d 50 04             	lea    0x4(%eax),%edx
  8007f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f4:	8b 30                	mov    (%eax),%esi
  8007f6:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007f9:	89 f0                	mov    %esi,%eax
  8007fb:	c1 f8 1f             	sar    $0x1f,%eax
  8007fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800801:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800804:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800807:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80080d:	85 d2                	test   %edx,%edx
  80080f:	79 28                	jns    800839 <vprintfmt+0x34f>
				putch('-', putdat);
  800811:	83 ec 08             	sub    $0x8,%esp
  800814:	53                   	push   %ebx
  800815:	6a 2d                	push   $0x2d
  800817:	ff d7                	call   *%edi
				num = -(long long) num;
  800819:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80081c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80081f:	f7 d8                	neg    %eax
  800821:	83 d2 00             	adc    $0x0,%edx
  800824:	f7 da                	neg    %edx
  800826:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800829:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80082c:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  80082f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800834:	e9 b2 00 00 00       	jmp    8008eb <vprintfmt+0x401>
  800839:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	0f 84 a5 00 00 00    	je     8008eb <vprintfmt+0x401>
				putch('+', putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	53                   	push   %ebx
  80084a:	6a 2b                	push   $0x2b
  80084c:	ff d7                	call   *%edi
  80084e:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800851:	b8 0a 00 00 00       	mov    $0xa,%eax
  800856:	e9 90 00 00 00       	jmp    8008eb <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  80085b:	85 c9                	test   %ecx,%ecx
  80085d:	74 0b                	je     80086a <vprintfmt+0x380>
				putch('+', putdat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	6a 2b                	push   $0x2b
  800865:	ff d7                	call   *%edi
  800867:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  80086a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80086d:	8d 45 14             	lea    0x14(%ebp),%eax
  800870:	e8 01 fc ff ff       	call   800476 <getuint>
  800875:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800878:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80087b:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800880:	eb 69                	jmp    8008eb <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	53                   	push   %ebx
  800886:	6a 30                	push   $0x30
  800888:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80088a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80088d:	8d 45 14             	lea    0x14(%ebp),%eax
  800890:	e8 e1 fb ff ff       	call   800476 <getuint>
  800895:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800898:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80089b:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80089e:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008a3:	eb 46                	jmp    8008eb <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	6a 30                	push   $0x30
  8008ab:	ff d7                	call   *%edi
			putch('x', putdat);
  8008ad:	83 c4 08             	add    $0x8,%esp
  8008b0:	53                   	push   %ebx
  8008b1:	6a 78                	push   $0x78
  8008b3:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	8d 50 04             	lea    0x4(%eax),%edx
  8008bb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008be:	8b 00                	mov    (%eax),%eax
  8008c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008cb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d3:	eb 16                	jmp    8008eb <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008db:	e8 96 fb ff ff       	call   800476 <getuint>
  8008e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008e6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008eb:	83 ec 0c             	sub    $0xc,%esp
  8008ee:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008f2:	56                   	push   %esi
  8008f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008f6:	50                   	push   %eax
  8008f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8008fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8008fd:	89 da                	mov    %ebx,%edx
  8008ff:	89 f8                	mov    %edi,%eax
  800901:	e8 55 f9 ff ff       	call   80025b <printnum>
			break;
  800906:	83 c4 20             	add    $0x20,%esp
  800909:	e9 f0 fb ff ff       	jmp    8004fe <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  80090e:	8b 45 14             	mov    0x14(%ebp),%eax
  800911:	8d 50 04             	lea    0x4(%eax),%edx
  800914:	89 55 14             	mov    %edx,0x14(%ebp)
  800917:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800919:	85 f6                	test   %esi,%esi
  80091b:	75 1a                	jne    800937 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	68 2c 16 80 00       	push   $0x80162c
  800925:	68 94 15 80 00       	push   $0x801594
  80092a:	e8 18 f9 ff ff       	call   800247 <cprintf>
  80092f:	83 c4 10             	add    $0x10,%esp
  800932:	e9 c7 fb ff ff       	jmp    8004fe <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800937:	0f b6 03             	movzbl (%ebx),%eax
  80093a:	84 c0                	test   %al,%al
  80093c:	79 1f                	jns    80095d <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	68 64 16 80 00       	push   $0x801664
  800946:	68 94 15 80 00       	push   $0x801594
  80094b:	e8 f7 f8 ff ff       	call   800247 <cprintf>
						*tmp = *(char *)putdat;
  800950:	0f b6 03             	movzbl (%ebx),%eax
  800953:	88 06                	mov    %al,(%esi)
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	e9 a1 fb ff ff       	jmp    8004fe <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  80095d:	88 06                	mov    %al,(%esi)
  80095f:	e9 9a fb ff ff       	jmp    8004fe <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	53                   	push   %ebx
  800968:	52                   	push   %edx
  800969:	ff d7                	call   *%edi
			break;
  80096b:	83 c4 10             	add    $0x10,%esp
  80096e:	e9 8b fb ff ff       	jmp    8004fe <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800973:	83 ec 08             	sub    $0x8,%esp
  800976:	53                   	push   %ebx
  800977:	6a 25                	push   $0x25
  800979:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80097b:	83 c4 10             	add    $0x10,%esp
  80097e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800982:	0f 84 73 fb ff ff    	je     8004fb <vprintfmt+0x11>
  800988:	83 ee 01             	sub    $0x1,%esi
  80098b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80098f:	75 f7                	jne    800988 <vprintfmt+0x49e>
  800991:	89 75 10             	mov    %esi,0x10(%ebp)
  800994:	e9 65 fb ff ff       	jmp    8004fe <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800999:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80099c:	8d 70 01             	lea    0x1(%eax),%esi
  80099f:	0f b6 00             	movzbl (%eax),%eax
  8009a2:	0f be d0             	movsbl %al,%edx
  8009a5:	85 d2                	test   %edx,%edx
  8009a7:	0f 85 cf fd ff ff    	jne    80077c <vprintfmt+0x292>
  8009ad:	e9 4c fb ff ff       	jmp    8004fe <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	83 ec 18             	sub    $0x18,%esp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	74 26                	je     800a01 <vsnprintf+0x47>
  8009db:	85 d2                	test   %edx,%edx
  8009dd:	7e 22                	jle    800a01 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009df:	ff 75 14             	pushl  0x14(%ebp)
  8009e2:	ff 75 10             	pushl  0x10(%ebp)
  8009e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e8:	50                   	push   %eax
  8009e9:	68 b0 04 80 00       	push   $0x8004b0
  8009ee:	e8 f7 fa ff ff       	call   8004ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fc:	83 c4 10             	add    $0x10,%esp
  8009ff:	eb 05                	jmp    800a06 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a0e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a11:	50                   	push   %eax
  800a12:	ff 75 10             	pushl  0x10(%ebp)
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	ff 75 08             	pushl  0x8(%ebp)
  800a1b:	e8 9a ff ff ff       	call   8009ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a28:	80 3a 00             	cmpb   $0x0,(%edx)
  800a2b:	74 10                	je     800a3d <strlen+0x1b>
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a32:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a35:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a39:	75 f7                	jne    800a32 <strlen+0x10>
  800a3b:	eb 05                	jmp    800a42 <strlen+0x20>
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	53                   	push   %ebx
  800a48:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4e:	85 c9                	test   %ecx,%ecx
  800a50:	74 1c                	je     800a6e <strnlen+0x2a>
  800a52:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a55:	74 1e                	je     800a75 <strnlen+0x31>
  800a57:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a5c:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5e:	39 ca                	cmp    %ecx,%edx
  800a60:	74 18                	je     800a7a <strnlen+0x36>
  800a62:	83 c2 01             	add    $0x1,%edx
  800a65:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a6a:	75 f0                	jne    800a5c <strnlen+0x18>
  800a6c:	eb 0c                	jmp    800a7a <strnlen+0x36>
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	eb 05                	jmp    800a7a <strnlen+0x36>
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	83 c2 01             	add    $0x1,%edx
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a93:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a96:	84 db                	test   %bl,%bl
  800a98:	75 ef                	jne    800a89 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	53                   	push   %ebx
  800aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa4:	53                   	push   %ebx
  800aa5:	e8 78 ff ff ff       	call   800a22 <strlen>
  800aaa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800aad:	ff 75 0c             	pushl  0xc(%ebp)
  800ab0:	01 d8                	add    %ebx,%eax
  800ab2:	50                   	push   %eax
  800ab3:	e8 c5 ff ff ff       	call   800a7d <strcpy>
	return dst;
}
  800ab8:	89 d8                	mov    %ebx,%eax
  800aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	74 17                	je     800ae8 <strncpy+0x29>
  800ad1:	01 f3                	add    %esi,%ebx
  800ad3:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800ad5:	83 c1 01             	add    $0x1,%ecx
  800ad8:	0f b6 02             	movzbl (%edx),%eax
  800adb:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ade:	80 3a 01             	cmpb   $0x1,(%edx)
  800ae1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae4:	39 cb                	cmp    %ecx,%ebx
  800ae6:	75 ed                	jne    800ad5 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae8:	89 f0                	mov    %esi,%eax
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 75 08             	mov    0x8(%ebp),%esi
  800af6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af9:	8b 55 10             	mov    0x10(%ebp),%edx
  800afc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afe:	85 d2                	test   %edx,%edx
  800b00:	74 35                	je     800b37 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b02:	89 d0                	mov    %edx,%eax
  800b04:	83 e8 01             	sub    $0x1,%eax
  800b07:	74 25                	je     800b2e <strlcpy+0x40>
  800b09:	0f b6 0b             	movzbl (%ebx),%ecx
  800b0c:	84 c9                	test   %cl,%cl
  800b0e:	74 22                	je     800b32 <strlcpy+0x44>
  800b10:	8d 53 01             	lea    0x1(%ebx),%edx
  800b13:	01 c3                	add    %eax,%ebx
  800b15:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800b17:	83 c0 01             	add    $0x1,%eax
  800b1a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b1d:	39 da                	cmp    %ebx,%edx
  800b1f:	74 13                	je     800b34 <strlcpy+0x46>
  800b21:	83 c2 01             	add    $0x1,%edx
  800b24:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800b28:	84 c9                	test   %cl,%cl
  800b2a:	75 eb                	jne    800b17 <strlcpy+0x29>
  800b2c:	eb 06                	jmp    800b34 <strlcpy+0x46>
  800b2e:	89 f0                	mov    %esi,%eax
  800b30:	eb 02                	jmp    800b34 <strlcpy+0x46>
  800b32:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b34:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b37:	29 f0                	sub    %esi,%eax
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b43:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b46:	0f b6 01             	movzbl (%ecx),%eax
  800b49:	84 c0                	test   %al,%al
  800b4b:	74 15                	je     800b62 <strcmp+0x25>
  800b4d:	3a 02                	cmp    (%edx),%al
  800b4f:	75 11                	jne    800b62 <strcmp+0x25>
		p++, q++;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b57:	0f b6 01             	movzbl (%ecx),%eax
  800b5a:	84 c0                	test   %al,%al
  800b5c:	74 04                	je     800b62 <strcmp+0x25>
  800b5e:	3a 02                	cmp    (%edx),%al
  800b60:	74 ef                	je     800b51 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b62:	0f b6 c0             	movzbl %al,%eax
  800b65:	0f b6 12             	movzbl (%edx),%edx
  800b68:	29 d0                	sub    %edx,%eax
}
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b77:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b7a:	85 f6                	test   %esi,%esi
  800b7c:	74 29                	je     800ba7 <strncmp+0x3b>
  800b7e:	0f b6 03             	movzbl (%ebx),%eax
  800b81:	84 c0                	test   %al,%al
  800b83:	74 30                	je     800bb5 <strncmp+0x49>
  800b85:	3a 02                	cmp    (%edx),%al
  800b87:	75 2c                	jne    800bb5 <strncmp+0x49>
  800b89:	8d 43 01             	lea    0x1(%ebx),%eax
  800b8c:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b8e:	89 c3                	mov    %eax,%ebx
  800b90:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b93:	39 c6                	cmp    %eax,%esi
  800b95:	74 17                	je     800bae <strncmp+0x42>
  800b97:	0f b6 08             	movzbl (%eax),%ecx
  800b9a:	84 c9                	test   %cl,%cl
  800b9c:	74 17                	je     800bb5 <strncmp+0x49>
  800b9e:	83 c0 01             	add    $0x1,%eax
  800ba1:	3a 0a                	cmp    (%edx),%cl
  800ba3:	74 e9                	je     800b8e <strncmp+0x22>
  800ba5:	eb 0e                	jmp    800bb5 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	eb 0f                	jmp    800bbd <strncmp+0x51>
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb3:	eb 08                	jmp    800bbd <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb5:	0f b6 03             	movzbl (%ebx),%eax
  800bb8:	0f b6 12             	movzbl (%edx),%edx
  800bbb:	29 d0                	sub    %edx,%eax
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800bcb:	0f b6 10             	movzbl (%eax),%edx
  800bce:	84 d2                	test   %dl,%dl
  800bd0:	74 1d                	je     800bef <strchr+0x2e>
  800bd2:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800bd4:	38 d3                	cmp    %dl,%bl
  800bd6:	75 06                	jne    800bde <strchr+0x1d>
  800bd8:	eb 1a                	jmp    800bf4 <strchr+0x33>
  800bda:	38 ca                	cmp    %cl,%dl
  800bdc:	74 16                	je     800bf4 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bde:	83 c0 01             	add    $0x1,%eax
  800be1:	0f b6 10             	movzbl (%eax),%edx
  800be4:	84 d2                	test   %dl,%dl
  800be6:	75 f2                	jne    800bda <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800be8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bed:	eb 05                	jmp    800bf4 <strchr+0x33>
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	53                   	push   %ebx
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfe:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c01:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c04:	38 d3                	cmp    %dl,%bl
  800c06:	74 14                	je     800c1c <strfind+0x25>
  800c08:	89 d1                	mov    %edx,%ecx
  800c0a:	84 db                	test   %bl,%bl
  800c0c:	74 0e                	je     800c1c <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c0e:	83 c0 01             	add    $0x1,%eax
  800c11:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c14:	38 ca                	cmp    %cl,%dl
  800c16:	74 04                	je     800c1c <strfind+0x25>
  800c18:	84 d2                	test   %dl,%dl
  800c1a:	75 f2                	jne    800c0e <strfind+0x17>
			break;
	return (char *) s;
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c2b:	85 c9                	test   %ecx,%ecx
  800c2d:	74 36                	je     800c65 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c35:	75 28                	jne    800c5f <memset+0x40>
  800c37:	f6 c1 03             	test   $0x3,%cl
  800c3a:	75 23                	jne    800c5f <memset+0x40>
		c &= 0xFF;
  800c3c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c40:	89 d3                	mov    %edx,%ebx
  800c42:	c1 e3 08             	shl    $0x8,%ebx
  800c45:	89 d6                	mov    %edx,%esi
  800c47:	c1 e6 18             	shl    $0x18,%esi
  800c4a:	89 d0                	mov    %edx,%eax
  800c4c:	c1 e0 10             	shl    $0x10,%eax
  800c4f:	09 f0                	or     %esi,%eax
  800c51:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c53:	89 d8                	mov    %ebx,%eax
  800c55:	09 d0                	or     %edx,%eax
  800c57:	c1 e9 02             	shr    $0x2,%ecx
  800c5a:	fc                   	cld    
  800c5b:	f3 ab                	rep stos %eax,%es:(%edi)
  800c5d:	eb 06                	jmp    800c65 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c62:	fc                   	cld    
  800c63:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c65:	89 f8                	mov    %edi,%eax
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7a:	39 c6                	cmp    %eax,%esi
  800c7c:	73 35                	jae    800cb3 <memmove+0x47>
  800c7e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c81:	39 d0                	cmp    %edx,%eax
  800c83:	73 2e                	jae    800cb3 <memmove+0x47>
		s += n;
		d += n;
  800c85:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c88:	89 d6                	mov    %edx,%esi
  800c8a:	09 fe                	or     %edi,%esi
  800c8c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c92:	75 13                	jne    800ca7 <memmove+0x3b>
  800c94:	f6 c1 03             	test   $0x3,%cl
  800c97:	75 0e                	jne    800ca7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c99:	83 ef 04             	sub    $0x4,%edi
  800c9c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c9f:	c1 e9 02             	shr    $0x2,%ecx
  800ca2:	fd                   	std    
  800ca3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca5:	eb 09                	jmp    800cb0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca7:	83 ef 01             	sub    $0x1,%edi
  800caa:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cad:	fd                   	std    
  800cae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb0:	fc                   	cld    
  800cb1:	eb 1d                	jmp    800cd0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb3:	89 f2                	mov    %esi,%edx
  800cb5:	09 c2                	or     %eax,%edx
  800cb7:	f6 c2 03             	test   $0x3,%dl
  800cba:	75 0f                	jne    800ccb <memmove+0x5f>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 0a                	jne    800ccb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cc1:	c1 e9 02             	shr    $0x2,%ecx
  800cc4:	89 c7                	mov    %eax,%edi
  800cc6:	fc                   	cld    
  800cc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc9:	eb 05                	jmp    800cd0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ccb:	89 c7                	mov    %eax,%edi
  800ccd:	fc                   	cld    
  800cce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cd7:	ff 75 10             	pushl  0x10(%ebp)
  800cda:	ff 75 0c             	pushl  0xc(%ebp)
  800cdd:	ff 75 08             	pushl  0x8(%ebp)
  800ce0:	e8 87 ff ff ff       	call   800c6c <memmove>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	74 39                	je     800d33 <memcmp+0x4c>
  800cfa:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cfd:	0f b6 13             	movzbl (%ebx),%edx
  800d00:	0f b6 0e             	movzbl (%esi),%ecx
  800d03:	38 ca                	cmp    %cl,%dl
  800d05:	75 17                	jne    800d1e <memcmp+0x37>
  800d07:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0c:	eb 1a                	jmp    800d28 <memcmp+0x41>
  800d0e:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800d13:	83 c0 01             	add    $0x1,%eax
  800d16:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800d1a:	38 ca                	cmp    %cl,%dl
  800d1c:	74 0a                	je     800d28 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d1e:	0f b6 c2             	movzbl %dl,%eax
  800d21:	0f b6 c9             	movzbl %cl,%ecx
  800d24:	29 c8                	sub    %ecx,%eax
  800d26:	eb 10                	jmp    800d38 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d28:	39 f8                	cmp    %edi,%eax
  800d2a:	75 e2                	jne    800d0e <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	eb 05                	jmp    800d38 <memcmp+0x51>
  800d33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	53                   	push   %ebx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d44:	89 d0                	mov    %edx,%eax
  800d46:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d49:	39 c2                	cmp    %eax,%edx
  800d4b:	73 1d                	jae    800d6a <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d4d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d51:	0f b6 0a             	movzbl (%edx),%ecx
  800d54:	39 d9                	cmp    %ebx,%ecx
  800d56:	75 09                	jne    800d61 <memfind+0x24>
  800d58:	eb 14                	jmp    800d6e <memfind+0x31>
  800d5a:	0f b6 0a             	movzbl (%edx),%ecx
  800d5d:	39 d9                	cmp    %ebx,%ecx
  800d5f:	74 11                	je     800d72 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d61:	83 c2 01             	add    $0x1,%edx
  800d64:	39 d0                	cmp    %edx,%eax
  800d66:	75 f2                	jne    800d5a <memfind+0x1d>
  800d68:	eb 0a                	jmp    800d74 <memfind+0x37>
  800d6a:	89 d0                	mov    %edx,%eax
  800d6c:	eb 06                	jmp    800d74 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d6e:	89 d0                	mov    %edx,%eax
  800d70:	eb 02                	jmp    800d74 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d72:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d74:	5b                   	pop    %ebx
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d83:	0f b6 01             	movzbl (%ecx),%eax
  800d86:	3c 20                	cmp    $0x20,%al
  800d88:	74 04                	je     800d8e <strtol+0x17>
  800d8a:	3c 09                	cmp    $0x9,%al
  800d8c:	75 0e                	jne    800d9c <strtol+0x25>
		s++;
  800d8e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d91:	0f b6 01             	movzbl (%ecx),%eax
  800d94:	3c 20                	cmp    $0x20,%al
  800d96:	74 f6                	je     800d8e <strtol+0x17>
  800d98:	3c 09                	cmp    $0x9,%al
  800d9a:	74 f2                	je     800d8e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d9c:	3c 2b                	cmp    $0x2b,%al
  800d9e:	75 0a                	jne    800daa <strtol+0x33>
		s++;
  800da0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800da3:	bf 00 00 00 00       	mov    $0x0,%edi
  800da8:	eb 11                	jmp    800dbb <strtol+0x44>
  800daa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800daf:	3c 2d                	cmp    $0x2d,%al
  800db1:	75 08                	jne    800dbb <strtol+0x44>
		s++, neg = 1;
  800db3:	83 c1 01             	add    $0x1,%ecx
  800db6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dbb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dc1:	75 15                	jne    800dd8 <strtol+0x61>
  800dc3:	80 39 30             	cmpb   $0x30,(%ecx)
  800dc6:	75 10                	jne    800dd8 <strtol+0x61>
  800dc8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800dcc:	75 7c                	jne    800e4a <strtol+0xd3>
		s += 2, base = 16;
  800dce:	83 c1 02             	add    $0x2,%ecx
  800dd1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dd6:	eb 16                	jmp    800dee <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800dd8:	85 db                	test   %ebx,%ebx
  800dda:	75 12                	jne    800dee <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ddc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800de1:	80 39 30             	cmpb   $0x30,(%ecx)
  800de4:	75 08                	jne    800dee <strtol+0x77>
		s++, base = 8;
  800de6:	83 c1 01             	add    $0x1,%ecx
  800de9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
  800df3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df6:	0f b6 11             	movzbl (%ecx),%edx
  800df9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dfc:	89 f3                	mov    %esi,%ebx
  800dfe:	80 fb 09             	cmp    $0x9,%bl
  800e01:	77 08                	ja     800e0b <strtol+0x94>
			dig = *s - '0';
  800e03:	0f be d2             	movsbl %dl,%edx
  800e06:	83 ea 30             	sub    $0x30,%edx
  800e09:	eb 22                	jmp    800e2d <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800e0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e0e:	89 f3                	mov    %esi,%ebx
  800e10:	80 fb 19             	cmp    $0x19,%bl
  800e13:	77 08                	ja     800e1d <strtol+0xa6>
			dig = *s - 'a' + 10;
  800e15:	0f be d2             	movsbl %dl,%edx
  800e18:	83 ea 57             	sub    $0x57,%edx
  800e1b:	eb 10                	jmp    800e2d <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800e1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e20:	89 f3                	mov    %esi,%ebx
  800e22:	80 fb 19             	cmp    $0x19,%bl
  800e25:	77 16                	ja     800e3d <strtol+0xc6>
			dig = *s - 'A' + 10;
  800e27:	0f be d2             	movsbl %dl,%edx
  800e2a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e30:	7d 0b                	jge    800e3d <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e32:	83 c1 01             	add    $0x1,%ecx
  800e35:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e39:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e3b:	eb b9                	jmp    800df6 <strtol+0x7f>

	if (endptr)
  800e3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e41:	74 0d                	je     800e50 <strtol+0xd9>
		*endptr = (char *) s;
  800e43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e46:	89 0e                	mov    %ecx,(%esi)
  800e48:	eb 06                	jmp    800e50 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e4a:	85 db                	test   %ebx,%ebx
  800e4c:	74 98                	je     800de6 <strtol+0x6f>
  800e4e:	eb 9e                	jmp    800dee <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e50:	89 c2                	mov    %eax,%edx
  800e52:	f7 da                	neg    %edx
  800e54:	85 ff                	test   %edi,%edi
  800e56:	0f 45 c2             	cmovne %edx,%eax
}
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e63:	b8 00 00 00 00       	mov    $0x0,%eax
  800e68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	89 c3                	mov    %eax,%ebx
  800e70:	89 c7                	mov    %eax,%edi
  800e72:	51                   	push   %ecx
  800e73:	52                   	push   %edx
  800e74:	53                   	push   %ebx
  800e75:	54                   	push   %esp
  800e76:	55                   	push   %ebp
  800e77:	56                   	push   %esi
  800e78:	57                   	push   %edi
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	8d 35 83 0e 80 00    	lea    0x800e83,%esi
  800e81:	0f 34                	sysenter 

00800e83 <label_21>:
  800e83:	5f                   	pop    %edi
  800e84:	5e                   	pop    %esi
  800e85:	5d                   	pop    %ebp
  800e86:	5c                   	pop    %esp
  800e87:	5b                   	pop    %ebx
  800e88:	5a                   	pop    %edx
  800e89:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e8a:	5b                   	pop    %ebx
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e98:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9d:	89 ca                	mov    %ecx,%edx
  800e9f:	89 cb                	mov    %ecx,%ebx
  800ea1:	89 cf                	mov    %ecx,%edi
  800ea3:	51                   	push   %ecx
  800ea4:	52                   	push   %edx
  800ea5:	53                   	push   %ebx
  800ea6:	54                   	push   %esp
  800ea7:	55                   	push   %ebp
  800ea8:	56                   	push   %esi
  800ea9:	57                   	push   %edi
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	8d 35 b4 0e 80 00    	lea    0x800eb4,%esi
  800eb2:	0f 34                	sysenter 

00800eb4 <label_55>:
  800eb4:	5f                   	pop    %edi
  800eb5:	5e                   	pop    %esi
  800eb6:	5d                   	pop    %ebp
  800eb7:	5c                   	pop    %esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5a                   	pop    %edx
  800eba:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec9:	b8 03 00 00 00       	mov    $0x3,%eax
  800ece:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed1:	89 d9                	mov    %ebx,%ecx
  800ed3:	89 df                	mov    %ebx,%edi
  800ed5:	51                   	push   %ecx
  800ed6:	52                   	push   %edx
  800ed7:	53                   	push   %ebx
  800ed8:	54                   	push   %esp
  800ed9:	55                   	push   %ebp
  800eda:	56                   	push   %esi
  800edb:	57                   	push   %edi
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	8d 35 e6 0e 80 00    	lea    0x800ee6,%esi
  800ee4:	0f 34                	sysenter 

00800ee6 <label_90>:
  800ee6:	5f                   	pop    %edi
  800ee7:	5e                   	pop    %esi
  800ee8:	5d                   	pop    %ebp
  800ee9:	5c                   	pop    %esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5a                   	pop    %edx
  800eec:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800eed:	85 c0                	test   %eax,%eax
  800eef:	7e 17                	jle    800f08 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	50                   	push   %eax
  800ef5:	6a 03                	push   $0x3
  800ef7:	68 44 18 80 00       	push   $0x801844
  800efc:	6a 2a                	push   $0x2a
  800efe:	68 61 18 80 00       	push   $0x801861
  800f03:	e8 4c f2 ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	57                   	push   %edi
  800f13:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f19:	b8 02 00 00 00       	mov    $0x2,%eax
  800f1e:	89 ca                	mov    %ecx,%edx
  800f20:	89 cb                	mov    %ecx,%ebx
  800f22:	89 cf                	mov    %ecx,%edi
  800f24:	51                   	push   %ecx
  800f25:	52                   	push   %edx
  800f26:	53                   	push   %ebx
  800f27:	54                   	push   %esp
  800f28:	55                   	push   %ebp
  800f29:	56                   	push   %esi
  800f2a:	57                   	push   %edi
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	8d 35 35 0f 80 00    	lea    0x800f35,%esi
  800f33:	0f 34                	sysenter 

00800f35 <label_139>:
  800f35:	5f                   	pop    %edi
  800f36:	5e                   	pop    %esi
  800f37:	5d                   	pop    %ebp
  800f38:	5c                   	pop    %esp
  800f39:	5b                   	pop    %ebx
  800f3a:	5a                   	pop    %edx
  800f3b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f3c:	5b                   	pop    %ebx
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f45:	bf 00 00 00 00       	mov    $0x0,%edi
  800f4a:	b8 04 00 00 00       	mov    $0x4,%eax
  800f4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	89 fb                	mov    %edi,%ebx
  800f57:	51                   	push   %ecx
  800f58:	52                   	push   %edx
  800f59:	53                   	push   %ebx
  800f5a:	54                   	push   %esp
  800f5b:	55                   	push   %ebp
  800f5c:	56                   	push   %esi
  800f5d:	57                   	push   %edi
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	8d 35 68 0f 80 00    	lea    0x800f68,%esi
  800f66:	0f 34                	sysenter 

00800f68 <label_174>:
  800f68:	5f                   	pop    %edi
  800f69:	5e                   	pop    %esi
  800f6a:	5d                   	pop    %ebp
  800f6b:	5c                   	pop    %esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5a                   	pop    %edx
  800f6e:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f6f:	5b                   	pop    %ebx
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <sys_yield>:

void
sys_yield(void)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f78:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f82:	89 d1                	mov    %edx,%ecx
  800f84:	89 d3                	mov    %edx,%ebx
  800f86:	89 d7                	mov    %edx,%edi
  800f88:	51                   	push   %ecx
  800f89:	52                   	push   %edx
  800f8a:	53                   	push   %ebx
  800f8b:	54                   	push   %esp
  800f8c:	55                   	push   %ebp
  800f8d:	56                   	push   %esi
  800f8e:	57                   	push   %edi
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	8d 35 99 0f 80 00    	lea    0x800f99,%esi
  800f97:	0f 34                	sysenter 

00800f99 <label_209>:
  800f99:	5f                   	pop    %edi
  800f9a:	5e                   	pop    %esi
  800f9b:	5d                   	pop    %ebp
  800f9c:	5c                   	pop    %esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5a                   	pop    %edx
  800f9f:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fa0:	5b                   	pop    %ebx
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa9:	bf 00 00 00 00       	mov    $0x0,%edi
  800fae:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbc:	51                   	push   %ecx
  800fbd:	52                   	push   %edx
  800fbe:	53                   	push   %ebx
  800fbf:	54                   	push   %esp
  800fc0:	55                   	push   %ebp
  800fc1:	56                   	push   %esi
  800fc2:	57                   	push   %edi
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	8d 35 cd 0f 80 00    	lea    0x800fcd,%esi
  800fcb:	0f 34                	sysenter 

00800fcd <label_244>:
  800fcd:	5f                   	pop    %edi
  800fce:	5e                   	pop    %esi
  800fcf:	5d                   	pop    %ebp
  800fd0:	5c                   	pop    %esp
  800fd1:	5b                   	pop    %ebx
  800fd2:	5a                   	pop    %edx
  800fd3:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	7e 17                	jle    800fef <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	50                   	push   %eax
  800fdc:	6a 05                	push   $0x5
  800fde:	68 44 18 80 00       	push   $0x801844
  800fe3:	6a 2a                	push   $0x2a
  800fe5:	68 61 18 80 00       	push   $0x801861
  800fea:	e8 65 f1 ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ffb:	b8 06 00 00 00       	mov    $0x6,%eax
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
  801006:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801009:	8b 7d 14             	mov    0x14(%ebp),%edi
  80100c:	51                   	push   %ecx
  80100d:	52                   	push   %edx
  80100e:	53                   	push   %ebx
  80100f:	54                   	push   %esp
  801010:	55                   	push   %ebp
  801011:	56                   	push   %esi
  801012:	57                   	push   %edi
  801013:	89 e5                	mov    %esp,%ebp
  801015:	8d 35 1d 10 80 00    	lea    0x80101d,%esi
  80101b:	0f 34                	sysenter 

0080101d <label_295>:
  80101d:	5f                   	pop    %edi
  80101e:	5e                   	pop    %esi
  80101f:	5d                   	pop    %ebp
  801020:	5c                   	pop    %esp
  801021:	5b                   	pop    %ebx
  801022:	5a                   	pop    %edx
  801023:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	7e 17                	jle    80103f <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	50                   	push   %eax
  80102c:	6a 06                	push   $0x6
  80102e:	68 44 18 80 00       	push   $0x801844
  801033:	6a 2a                	push   $0x2a
  801035:	68 61 18 80 00       	push   $0x801861
  80103a:	e8 15 f1 ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80103f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	57                   	push   %edi
  80104a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80104b:	bf 00 00 00 00       	mov    $0x0,%edi
  801050:	b8 07 00 00 00       	mov    $0x7,%eax
  801055:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801058:	8b 55 08             	mov    0x8(%ebp),%edx
  80105b:	89 fb                	mov    %edi,%ebx
  80105d:	51                   	push   %ecx
  80105e:	52                   	push   %edx
  80105f:	53                   	push   %ebx
  801060:	54                   	push   %esp
  801061:	55                   	push   %ebp
  801062:	56                   	push   %esi
  801063:	57                   	push   %edi
  801064:	89 e5                	mov    %esp,%ebp
  801066:	8d 35 6e 10 80 00    	lea    0x80106e,%esi
  80106c:	0f 34                	sysenter 

0080106e <label_344>:
  80106e:	5f                   	pop    %edi
  80106f:	5e                   	pop    %esi
  801070:	5d                   	pop    %ebp
  801071:	5c                   	pop    %esp
  801072:	5b                   	pop    %ebx
  801073:	5a                   	pop    %edx
  801074:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801075:	85 c0                	test   %eax,%eax
  801077:	7e 17                	jle    801090 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	50                   	push   %eax
  80107d:	6a 07                	push   $0x7
  80107f:	68 44 18 80 00       	push   $0x801844
  801084:	6a 2a                	push   $0x2a
  801086:	68 61 18 80 00       	push   $0x801861
  80108b:	e8 c4 f0 ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801093:	5b                   	pop    %ebx
  801094:	5f                   	pop    %edi
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    

00801097 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	57                   	push   %edi
  80109b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80109c:	bf 00 00 00 00       	mov    $0x0,%edi
  8010a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8010a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ac:	89 fb                	mov    %edi,%ebx
  8010ae:	51                   	push   %ecx
  8010af:	52                   	push   %edx
  8010b0:	53                   	push   %ebx
  8010b1:	54                   	push   %esp
  8010b2:	55                   	push   %ebp
  8010b3:	56                   	push   %esi
  8010b4:	57                   	push   %edi
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	8d 35 bf 10 80 00    	lea    0x8010bf,%esi
  8010bd:	0f 34                	sysenter 

008010bf <label_393>:
  8010bf:	5f                   	pop    %edi
  8010c0:	5e                   	pop    %esi
  8010c1:	5d                   	pop    %ebp
  8010c2:	5c                   	pop    %esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5a                   	pop    %edx
  8010c5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	7e 17                	jle    8010e1 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	50                   	push   %eax
  8010ce:	6a 09                	push   $0x9
  8010d0:	68 44 18 80 00       	push   $0x801844
  8010d5:	6a 2a                	push   $0x2a
  8010d7:	68 61 18 80 00       	push   $0x801861
  8010dc:	e8 73 f0 ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	57                   	push   %edi
  8010ec:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fd:	89 fb                	mov    %edi,%ebx
  8010ff:	51                   	push   %ecx
  801100:	52                   	push   %edx
  801101:	53                   	push   %ebx
  801102:	54                   	push   %esp
  801103:	55                   	push   %ebp
  801104:	56                   	push   %esi
  801105:	57                   	push   %edi
  801106:	89 e5                	mov    %esp,%ebp
  801108:	8d 35 10 11 80 00    	lea    0x801110,%esi
  80110e:	0f 34                	sysenter 

00801110 <label_442>:
  801110:	5f                   	pop    %edi
  801111:	5e                   	pop    %esi
  801112:	5d                   	pop    %ebp
  801113:	5c                   	pop    %esp
  801114:	5b                   	pop    %ebx
  801115:	5a                   	pop    %edx
  801116:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801117:	85 c0                	test   %eax,%eax
  801119:	7e 17                	jle    801132 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	50                   	push   %eax
  80111f:	6a 0a                	push   $0xa
  801121:	68 44 18 80 00       	push   $0x801844
  801126:	6a 2a                	push   $0x2a
  801128:	68 61 18 80 00       	push   $0x801861
  80112d:	e8 22 f0 ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801132:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5f                   	pop    %edi
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    

00801139 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	57                   	push   %edi
  80113d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113e:	b8 0c 00 00 00       	mov    $0xc,%eax
  801143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801146:	8b 55 08             	mov    0x8(%ebp),%edx
  801149:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114f:	51                   	push   %ecx
  801150:	52                   	push   %edx
  801151:	53                   	push   %ebx
  801152:	54                   	push   %esp
  801153:	55                   	push   %ebp
  801154:	56                   	push   %esi
  801155:	57                   	push   %edi
  801156:	89 e5                	mov    %esp,%ebp
  801158:	8d 35 60 11 80 00    	lea    0x801160,%esi
  80115e:	0f 34                	sysenter 

00801160 <label_493>:
  801160:	5f                   	pop    %edi
  801161:	5e                   	pop    %esi
  801162:	5d                   	pop    %ebp
  801163:	5c                   	pop    %esp
  801164:	5b                   	pop    %ebx
  801165:	5a                   	pop    %edx
  801166:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801167:	5b                   	pop    %ebx
  801168:	5f                   	pop    %edi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	57                   	push   %edi
  80116f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801170:	bb 00 00 00 00       	mov    $0x0,%ebx
  801175:	b8 0d 00 00 00       	mov    $0xd,%eax
  80117a:	8b 55 08             	mov    0x8(%ebp),%edx
  80117d:	89 d9                	mov    %ebx,%ecx
  80117f:	89 df                	mov    %ebx,%edi
  801181:	51                   	push   %ecx
  801182:	52                   	push   %edx
  801183:	53                   	push   %ebx
  801184:	54                   	push   %esp
  801185:	55                   	push   %ebp
  801186:	56                   	push   %esi
  801187:	57                   	push   %edi
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	8d 35 92 11 80 00    	lea    0x801192,%esi
  801190:	0f 34                	sysenter 

00801192 <label_528>:
  801192:	5f                   	pop    %edi
  801193:	5e                   	pop    %esi
  801194:	5d                   	pop    %ebp
  801195:	5c                   	pop    %esp
  801196:	5b                   	pop    %ebx
  801197:	5a                   	pop    %edx
  801198:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801199:	85 c0                	test   %eax,%eax
  80119b:	7e 17                	jle    8011b4 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	50                   	push   %eax
  8011a1:	6a 0d                	push   $0xd
  8011a3:	68 44 18 80 00       	push   $0x801844
  8011a8:	6a 2a                	push   $0x2a
  8011aa:	68 61 18 80 00       	push   $0x801861
  8011af:	e8 a0 ef ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	57                   	push   %edi
  8011bf:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c5:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cd:	89 cb                	mov    %ecx,%ebx
  8011cf:	89 cf                	mov    %ecx,%edi
  8011d1:	51                   	push   %ecx
  8011d2:	52                   	push   %edx
  8011d3:	53                   	push   %ebx
  8011d4:	54                   	push   %esp
  8011d5:	55                   	push   %ebp
  8011d6:	56                   	push   %esi
  8011d7:	57                   	push   %edi
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	8d 35 e2 11 80 00    	lea    0x8011e2,%esi
  8011e0:	0f 34                	sysenter 

008011e2 <label_577>:
  8011e2:	5f                   	pop    %edi
  8011e3:	5e                   	pop    %esi
  8011e4:	5d                   	pop    %ebp
  8011e5:	5c                   	pop    %esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5a                   	pop    %edx
  8011e8:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011e9:	5b                   	pop    %ebx
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    
  8011ed:	66 90                	xchg   %ax,%ax
  8011ef:	90                   	nop

008011f0 <__udivdi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 1c             	sub    $0x1c,%esp
  8011f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8011fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801207:	85 f6                	test   %esi,%esi
  801209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80120d:	89 ca                	mov    %ecx,%edx
  80120f:	89 f8                	mov    %edi,%eax
  801211:	75 3d                	jne    801250 <__udivdi3+0x60>
  801213:	39 cf                	cmp    %ecx,%edi
  801215:	0f 87 c5 00 00 00    	ja     8012e0 <__udivdi3+0xf0>
  80121b:	85 ff                	test   %edi,%edi
  80121d:	89 fd                	mov    %edi,%ebp
  80121f:	75 0b                	jne    80122c <__udivdi3+0x3c>
  801221:	b8 01 00 00 00       	mov    $0x1,%eax
  801226:	31 d2                	xor    %edx,%edx
  801228:	f7 f7                	div    %edi
  80122a:	89 c5                	mov    %eax,%ebp
  80122c:	89 c8                	mov    %ecx,%eax
  80122e:	31 d2                	xor    %edx,%edx
  801230:	f7 f5                	div    %ebp
  801232:	89 c1                	mov    %eax,%ecx
  801234:	89 d8                	mov    %ebx,%eax
  801236:	89 cf                	mov    %ecx,%edi
  801238:	f7 f5                	div    %ebp
  80123a:	89 c3                	mov    %eax,%ebx
  80123c:	89 d8                	mov    %ebx,%eax
  80123e:	89 fa                	mov    %edi,%edx
  801240:	83 c4 1c             	add    $0x1c,%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    
  801248:	90                   	nop
  801249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801250:	39 ce                	cmp    %ecx,%esi
  801252:	77 74                	ja     8012c8 <__udivdi3+0xd8>
  801254:	0f bd fe             	bsr    %esi,%edi
  801257:	83 f7 1f             	xor    $0x1f,%edi
  80125a:	0f 84 98 00 00 00    	je     8012f8 <__udivdi3+0x108>
  801260:	bb 20 00 00 00       	mov    $0x20,%ebx
  801265:	89 f9                	mov    %edi,%ecx
  801267:	89 c5                	mov    %eax,%ebp
  801269:	29 fb                	sub    %edi,%ebx
  80126b:	d3 e6                	shl    %cl,%esi
  80126d:	89 d9                	mov    %ebx,%ecx
  80126f:	d3 ed                	shr    %cl,%ebp
  801271:	89 f9                	mov    %edi,%ecx
  801273:	d3 e0                	shl    %cl,%eax
  801275:	09 ee                	or     %ebp,%esi
  801277:	89 d9                	mov    %ebx,%ecx
  801279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127d:	89 d5                	mov    %edx,%ebp
  80127f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801283:	d3 ed                	shr    %cl,%ebp
  801285:	89 f9                	mov    %edi,%ecx
  801287:	d3 e2                	shl    %cl,%edx
  801289:	89 d9                	mov    %ebx,%ecx
  80128b:	d3 e8                	shr    %cl,%eax
  80128d:	09 c2                	or     %eax,%edx
  80128f:	89 d0                	mov    %edx,%eax
  801291:	89 ea                	mov    %ebp,%edx
  801293:	f7 f6                	div    %esi
  801295:	89 d5                	mov    %edx,%ebp
  801297:	89 c3                	mov    %eax,%ebx
  801299:	f7 64 24 0c          	mull   0xc(%esp)
  80129d:	39 d5                	cmp    %edx,%ebp
  80129f:	72 10                	jb     8012b1 <__udivdi3+0xc1>
  8012a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012a5:	89 f9                	mov    %edi,%ecx
  8012a7:	d3 e6                	shl    %cl,%esi
  8012a9:	39 c6                	cmp    %eax,%esi
  8012ab:	73 07                	jae    8012b4 <__udivdi3+0xc4>
  8012ad:	39 d5                	cmp    %edx,%ebp
  8012af:	75 03                	jne    8012b4 <__udivdi3+0xc4>
  8012b1:	83 eb 01             	sub    $0x1,%ebx
  8012b4:	31 ff                	xor    %edi,%edi
  8012b6:	89 d8                	mov    %ebx,%eax
  8012b8:	89 fa                	mov    %edi,%edx
  8012ba:	83 c4 1c             	add    $0x1c,%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    
  8012c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c8:	31 ff                	xor    %edi,%edi
  8012ca:	31 db                	xor    %ebx,%ebx
  8012cc:	89 d8                	mov    %ebx,%eax
  8012ce:	89 fa                	mov    %edi,%edx
  8012d0:	83 c4 1c             	add    $0x1c,%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    
  8012d8:	90                   	nop
  8012d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	89 d8                	mov    %ebx,%eax
  8012e2:	f7 f7                	div    %edi
  8012e4:	31 ff                	xor    %edi,%edi
  8012e6:	89 c3                	mov    %eax,%ebx
  8012e8:	89 d8                	mov    %ebx,%eax
  8012ea:	89 fa                	mov    %edi,%edx
  8012ec:	83 c4 1c             	add    $0x1c,%esp
  8012ef:	5b                   	pop    %ebx
  8012f0:	5e                   	pop    %esi
  8012f1:	5f                   	pop    %edi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	39 ce                	cmp    %ecx,%esi
  8012fa:	72 0c                	jb     801308 <__udivdi3+0x118>
  8012fc:	31 db                	xor    %ebx,%ebx
  8012fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801302:	0f 87 34 ff ff ff    	ja     80123c <__udivdi3+0x4c>
  801308:	bb 01 00 00 00       	mov    $0x1,%ebx
  80130d:	e9 2a ff ff ff       	jmp    80123c <__udivdi3+0x4c>
  801312:	66 90                	xchg   %ax,%ax
  801314:	66 90                	xchg   %ax,%ax
  801316:	66 90                	xchg   %ax,%ax
  801318:	66 90                	xchg   %ax,%ax
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__umoddi3>:
  801320:	55                   	push   %ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
  801324:	83 ec 1c             	sub    $0x1c,%esp
  801327:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80132b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80132f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801333:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801337:	85 d2                	test   %edx,%edx
  801339:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80133d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801341:	89 f3                	mov    %esi,%ebx
  801343:	89 3c 24             	mov    %edi,(%esp)
  801346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80134a:	75 1c                	jne    801368 <__umoddi3+0x48>
  80134c:	39 f7                	cmp    %esi,%edi
  80134e:	76 50                	jbe    8013a0 <__umoddi3+0x80>
  801350:	89 c8                	mov    %ecx,%eax
  801352:	89 f2                	mov    %esi,%edx
  801354:	f7 f7                	div    %edi
  801356:	89 d0                	mov    %edx,%eax
  801358:	31 d2                	xor    %edx,%edx
  80135a:	83 c4 1c             	add    $0x1c,%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5f                   	pop    %edi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    
  801362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801368:	39 f2                	cmp    %esi,%edx
  80136a:	89 d0                	mov    %edx,%eax
  80136c:	77 52                	ja     8013c0 <__umoddi3+0xa0>
  80136e:	0f bd ea             	bsr    %edx,%ebp
  801371:	83 f5 1f             	xor    $0x1f,%ebp
  801374:	75 5a                	jne    8013d0 <__umoddi3+0xb0>
  801376:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80137a:	0f 82 e0 00 00 00    	jb     801460 <__umoddi3+0x140>
  801380:	39 0c 24             	cmp    %ecx,(%esp)
  801383:	0f 86 d7 00 00 00    	jbe    801460 <__umoddi3+0x140>
  801389:	8b 44 24 08          	mov    0x8(%esp),%eax
  80138d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801391:	83 c4 1c             	add    $0x1c,%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    
  801399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	85 ff                	test   %edi,%edi
  8013a2:	89 fd                	mov    %edi,%ebp
  8013a4:	75 0b                	jne    8013b1 <__umoddi3+0x91>
  8013a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	f7 f7                	div    %edi
  8013af:	89 c5                	mov    %eax,%ebp
  8013b1:	89 f0                	mov    %esi,%eax
  8013b3:	31 d2                	xor    %edx,%edx
  8013b5:	f7 f5                	div    %ebp
  8013b7:	89 c8                	mov    %ecx,%eax
  8013b9:	f7 f5                	div    %ebp
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	eb 99                	jmp    801358 <__umoddi3+0x38>
  8013bf:	90                   	nop
  8013c0:	89 c8                	mov    %ecx,%eax
  8013c2:	89 f2                	mov    %esi,%edx
  8013c4:	83 c4 1c             	add    $0x1c,%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	8b 34 24             	mov    (%esp),%esi
  8013d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013d8:	89 e9                	mov    %ebp,%ecx
  8013da:	29 ef                	sub    %ebp,%edi
  8013dc:	d3 e0                	shl    %cl,%eax
  8013de:	89 f9                	mov    %edi,%ecx
  8013e0:	89 f2                	mov    %esi,%edx
  8013e2:	d3 ea                	shr    %cl,%edx
  8013e4:	89 e9                	mov    %ebp,%ecx
  8013e6:	09 c2                	or     %eax,%edx
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	89 14 24             	mov    %edx,(%esp)
  8013ed:	89 f2                	mov    %esi,%edx
  8013ef:	d3 e2                	shl    %cl,%edx
  8013f1:	89 f9                	mov    %edi,%ecx
  8013f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013fb:	d3 e8                	shr    %cl,%eax
  8013fd:	89 e9                	mov    %ebp,%ecx
  8013ff:	89 c6                	mov    %eax,%esi
  801401:	d3 e3                	shl    %cl,%ebx
  801403:	89 f9                	mov    %edi,%ecx
  801405:	89 d0                	mov    %edx,%eax
  801407:	d3 e8                	shr    %cl,%eax
  801409:	89 e9                	mov    %ebp,%ecx
  80140b:	09 d8                	or     %ebx,%eax
  80140d:	89 d3                	mov    %edx,%ebx
  80140f:	89 f2                	mov    %esi,%edx
  801411:	f7 34 24             	divl   (%esp)
  801414:	89 d6                	mov    %edx,%esi
  801416:	d3 e3                	shl    %cl,%ebx
  801418:	f7 64 24 04          	mull   0x4(%esp)
  80141c:	39 d6                	cmp    %edx,%esi
  80141e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801422:	89 d1                	mov    %edx,%ecx
  801424:	89 c3                	mov    %eax,%ebx
  801426:	72 08                	jb     801430 <__umoddi3+0x110>
  801428:	75 11                	jne    80143b <__umoddi3+0x11b>
  80142a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80142e:	73 0b                	jae    80143b <__umoddi3+0x11b>
  801430:	2b 44 24 04          	sub    0x4(%esp),%eax
  801434:	1b 14 24             	sbb    (%esp),%edx
  801437:	89 d1                	mov    %edx,%ecx
  801439:	89 c3                	mov    %eax,%ebx
  80143b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80143f:	29 da                	sub    %ebx,%edx
  801441:	19 ce                	sbb    %ecx,%esi
  801443:	89 f9                	mov    %edi,%ecx
  801445:	89 f0                	mov    %esi,%eax
  801447:	d3 e0                	shl    %cl,%eax
  801449:	89 e9                	mov    %ebp,%ecx
  80144b:	d3 ea                	shr    %cl,%edx
  80144d:	89 e9                	mov    %ebp,%ecx
  80144f:	d3 ee                	shr    %cl,%esi
  801451:	09 d0                	or     %edx,%eax
  801453:	89 f2                	mov    %esi,%edx
  801455:	83 c4 1c             	add    $0x1c,%esp
  801458:	5b                   	pop    %ebx
  801459:	5e                   	pop    %esi
  80145a:	5f                   	pop    %edi
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    
  80145d:	8d 76 00             	lea    0x0(%esi),%esi
  801460:	29 f9                	sub    %edi,%ecx
  801462:	19 d6                	sbb    %edx,%esi
  801464:	89 74 24 04          	mov    %esi,0x4(%esp)
  801468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80146c:	e9 18 ff ff ff       	jmp    801389 <__umoddi3+0x69>
