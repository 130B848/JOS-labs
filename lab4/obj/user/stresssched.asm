
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 cf 0e 00 00       	call   800f0c <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 a1 11 00 00       	call   8011ea <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 25                	jmp    80007c <umain+0x49>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	74 20                	je     80007c <umain+0x49>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005c:	89 f0                	mov    %esi,%eax
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	89 c2                	mov    %eax,%edx
  800065:	c1 e2 07             	shl    $0x7,%edx
  800068:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80006e:	8b 4a 54             	mov    0x54(%edx),%ecx
  800071:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800076:	85 c9                	test   %ecx,%ecx
  800078:	74 17                	je     800091 <umain+0x5e>
  80007a:	eb 07                	jmp    800083 <umain+0x50>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  80007c:	e8 ef 0e 00 00       	call   800f70 <sys_yield>
		return;
  800081:	eb 6f                	jmp    8000f2 <umain+0xbf>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800083:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800085:	8b 42 54             	mov    0x54(%edx),%eax
  800088:	85 c0                	test   %eax,%eax
  80008a:	75 f7                	jne    800083 <umain+0x50>
  80008c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800091:	e8 da 0e 00 00       	call   800f70 <sys_yield>
  800096:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80009b:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000a0:	83 c0 01             	add    $0x1,%eax
  8000a3:	a3 0c 20 80 00       	mov    %eax,0x80200c
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a8:	83 ea 01             	sub    $0x1,%edx
  8000ab:	75 ee                	jne    80009b <umain+0x68>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ad:	83 eb 01             	sub    $0x1,%ebx
  8000b0:	75 df                	jne    800091 <umain+0x5e>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000b2:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000b7:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000bc:	74 17                	je     8000d5 <umain+0xa2>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000be:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000c3:	50                   	push   %eax
  8000c4:	68 c0 14 80 00       	push   $0x8014c0
  8000c9:	6a 21                	push   $0x21
  8000cb:	68 e8 14 80 00       	push   $0x8014e8
  8000d0:	e8 7c 00 00 00       	call   800151 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000d5:	a1 10 20 80 00       	mov    0x802010,%eax
  8000da:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000dd:	8b 40 48             	mov    0x48(%eax),%eax
  8000e0:	83 ec 04             	sub    $0x4,%esp
  8000e3:	52                   	push   %edx
  8000e4:	50                   	push   %eax
  8000e5:	68 fb 14 80 00       	push   $0x8014fb
  8000ea:	e8 55 01 00 00       	call   800244 <cprintf>
  8000ef:	83 c4 10             	add    $0x10,%esp

}
  8000f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800101:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800104:	e8 03 0e 00 00       	call   800f0c <sys_getenvid>
  800109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010e:	c1 e0 07             	shl    $0x7,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 10 20 80 00       	mov    %eax,0x802010
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011b:	85 db                	test   %ebx,%ebx
  80011d:	7e 07                	jle    800126 <libmain+0x2d>
		binaryname = argv[0];
  80011f:	8b 06                	mov    (%esi),%eax
  800121:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	e8 03 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800130:	e8 0a 00 00 00       	call   80013f <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800145:	6a 00                	push   $0x0
  800147:	e8 70 0d 00 00       	call   800ebc <sys_env_destroy>
}
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800156:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800159:	a1 14 20 80 00       	mov    0x802014,%eax
  80015e:	85 c0                	test   %eax,%eax
  800160:	74 11                	je     800173 <_panic+0x22>
		cprintf("%s: ", argv0);
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	50                   	push   %eax
  800166:	68 23 15 80 00       	push   $0x801523
  80016b:	e8 d4 00 00 00       	call   800244 <cprintf>
  800170:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800173:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800179:	e8 8e 0d 00 00       	call   800f0c <sys_getenvid>
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	ff 75 0c             	pushl  0xc(%ebp)
  800184:	ff 75 08             	pushl  0x8(%ebp)
  800187:	56                   	push   %esi
  800188:	50                   	push   %eax
  800189:	68 28 15 80 00       	push   $0x801528
  80018e:	e8 b1 00 00 00       	call   800244 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800193:	83 c4 18             	add    $0x18,%esp
  800196:	53                   	push   %ebx
  800197:	ff 75 10             	pushl  0x10(%ebp)
  80019a:	e8 54 00 00 00       	call   8001f3 <vcprintf>
	cprintf("\n");
  80019f:	c7 04 24 17 15 80 00 	movl   $0x801517,(%esp)
  8001a6:	e8 99 00 00 00       	call   800244 <cprintf>
  8001ab:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ae:	cc                   	int3   
  8001af:	eb fd                	jmp    8001ae <_panic+0x5d>

008001b1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 04             	sub    $0x4,%esp
  8001b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001bb:	8b 13                	mov    (%ebx),%edx
  8001bd:	8d 42 01             	lea    0x1(%edx),%eax
  8001c0:	89 03                	mov    %eax,(%ebx)
  8001c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ce:	75 1a                	jne    8001ea <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	68 ff 00 00 00       	push   $0xff
  8001d8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001db:	50                   	push   %eax
  8001dc:	e8 7a 0c 00 00       	call   800e5b <sys_cputs>
		b->idx = 0;
  8001e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ea:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800203:	00 00 00 
	b.cnt = 0;
  800206:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800210:	ff 75 0c             	pushl  0xc(%ebp)
  800213:	ff 75 08             	pushl  0x8(%ebp)
  800216:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021c:	50                   	push   %eax
  80021d:	68 b1 01 80 00       	push   $0x8001b1
  800222:	e8 c0 02 00 00       	call   8004e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800227:	83 c4 08             	add    $0x8,%esp
  80022a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800230:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800236:	50                   	push   %eax
  800237:	e8 1f 0c 00 00       	call   800e5b <sys_cputs>

	return b.cnt;
}
  80023c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024d:	50                   	push   %eax
  80024e:	ff 75 08             	pushl  0x8(%ebp)
  800251:	e8 9d ff ff ff       	call   8001f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	57                   	push   %edi
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
  80025e:	83 ec 1c             	sub    $0x1c,%esp
  800261:	89 c7                	mov    %eax,%edi
  800263:	89 d6                	mov    %edx,%esi
  800265:	8b 45 08             	mov    0x8(%ebp),%eax
  800268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800271:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800274:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800278:	0f 85 bf 00 00 00    	jne    80033d <printnum+0xe5>
  80027e:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800284:	0f 8d de 00 00 00    	jge    800368 <printnum+0x110>
		judge_time_for_space = width;
  80028a:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800290:	e9 d3 00 00 00       	jmp    800368 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800295:	83 eb 01             	sub    $0x1,%ebx
  800298:	85 db                	test   %ebx,%ebx
  80029a:	7f 37                	jg     8002d3 <printnum+0x7b>
  80029c:	e9 ea 00 00 00       	jmp    80038b <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8002a1:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002a4:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	83 ec 04             	sub    $0x4,%esp
  8002b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bc:	e8 8f 10 00 00       	call   801350 <__umoddi3>
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	0f be 80 4b 15 80 00 	movsbl 0x80154b(%eax),%eax
  8002cb:	50                   	push   %eax
  8002cc:	ff d7                	call   *%edi
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	eb 16                	jmp    8002e9 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8002d3:	83 ec 08             	sub    $0x8,%esp
  8002d6:	56                   	push   %esi
  8002d7:	ff 75 18             	pushl  0x18(%ebp)
  8002da:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8002dc:	83 c4 10             	add    $0x10,%esp
  8002df:	83 eb 01             	sub    $0x1,%ebx
  8002e2:	75 ef                	jne    8002d3 <printnum+0x7b>
  8002e4:	e9 a2 00 00 00       	jmp    80038b <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8002e9:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8002ef:	0f 85 76 01 00 00    	jne    80046b <printnum+0x213>
		while(num_of_space-- > 0)
  8002f5:	a1 04 20 80 00       	mov    0x802004,%eax
  8002fa:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002fd:	89 15 04 20 80 00    	mov    %edx,0x802004
  800303:	85 c0                	test   %eax,%eax
  800305:	7e 1d                	jle    800324 <printnum+0xcc>
			putch(' ', putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	6a 20                	push   $0x20
  80030d:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80030f:	a1 04 20 80 00       	mov    0x802004,%eax
  800314:	8d 50 ff             	lea    -0x1(%eax),%edx
  800317:	89 15 04 20 80 00    	mov    %edx,0x802004
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	85 c0                	test   %eax,%eax
  800322:	7f e3                	jg     800307 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800324:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80032b:	00 00 00 
		judge_time_for_space = 0;
  80032e:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800335:	00 00 00 
	}
}
  800338:	e9 2e 01 00 00       	jmp    80046b <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033d:	8b 45 10             	mov    0x10(%ebp),%eax
  800340:	ba 00 00 00 00       	mov    $0x0,%edx
  800345:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800348:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80034b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800351:	83 fa 00             	cmp    $0x0,%edx
  800354:	0f 87 ba 00 00 00    	ja     800414 <printnum+0x1bc>
  80035a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80035d:	0f 83 b1 00 00 00    	jae    800414 <printnum+0x1bc>
  800363:	e9 2d ff ff ff       	jmp    800295 <printnum+0x3d>
  800368:	8b 45 10             	mov    0x10(%ebp),%eax
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800373:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800376:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800379:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80037c:	83 fa 00             	cmp    $0x0,%edx
  80037f:	77 37                	ja     8003b8 <printnum+0x160>
  800381:	3b 45 10             	cmp    0x10(%ebp),%eax
  800384:	73 32                	jae    8003b8 <printnum+0x160>
  800386:	e9 16 ff ff ff       	jmp    8002a1 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	56                   	push   %esi
  80038f:	83 ec 04             	sub    $0x4,%esp
  800392:	ff 75 dc             	pushl  -0x24(%ebp)
  800395:	ff 75 d8             	pushl  -0x28(%ebp)
  800398:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039b:	ff 75 e0             	pushl  -0x20(%ebp)
  80039e:	e8 ad 0f 00 00       	call   801350 <__umoddi3>
  8003a3:	83 c4 14             	add    $0x14,%esp
  8003a6:	0f be 80 4b 15 80 00 	movsbl 0x80154b(%eax),%eax
  8003ad:	50                   	push   %eax
  8003ae:	ff d7                	call   *%edi
  8003b0:	83 c4 10             	add    $0x10,%esp
  8003b3:	e9 b3 00 00 00       	jmp    80046b <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b8:	83 ec 0c             	sub    $0xc,%esp
  8003bb:	ff 75 18             	pushl  0x18(%ebp)
  8003be:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8003c1:	50                   	push   %eax
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d4:	e8 47 0e 00 00       	call   801220 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 71 fe ff ff       	call   800258 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e7:	83 c4 18             	add    $0x18,%esp
  8003ea:	56                   	push   %esi
  8003eb:	83 ec 04             	sub    $0x4,%esp
  8003ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003fa:	e8 51 0f 00 00       	call   801350 <__umoddi3>
  8003ff:	83 c4 14             	add    $0x14,%esp
  800402:	0f be 80 4b 15 80 00 	movsbl 0x80154b(%eax),%eax
  800409:	50                   	push   %eax
  80040a:	ff d7                	call   *%edi
  80040c:	83 c4 10             	add    $0x10,%esp
  80040f:	e9 d5 fe ff ff       	jmp    8002e9 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800414:	83 ec 0c             	sub    $0xc,%esp
  800417:	ff 75 18             	pushl  0x18(%ebp)
  80041a:	83 eb 01             	sub    $0x1,%ebx
  80041d:	53                   	push   %ebx
  80041e:	ff 75 10             	pushl  0x10(%ebp)
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	ff 75 dc             	pushl  -0x24(%ebp)
  800427:	ff 75 d8             	pushl  -0x28(%ebp)
  80042a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042d:	ff 75 e0             	pushl  -0x20(%ebp)
  800430:	e8 eb 0d 00 00       	call   801220 <__udivdi3>
  800435:	83 c4 18             	add    $0x18,%esp
  800438:	52                   	push   %edx
  800439:	50                   	push   %eax
  80043a:	89 f2                	mov    %esi,%edx
  80043c:	89 f8                	mov    %edi,%eax
  80043e:	e8 15 fe ff ff       	call   800258 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800443:	83 c4 18             	add    $0x18,%esp
  800446:	56                   	push   %esi
  800447:	83 ec 04             	sub    $0x4,%esp
  80044a:	ff 75 dc             	pushl  -0x24(%ebp)
  80044d:	ff 75 d8             	pushl  -0x28(%ebp)
  800450:	ff 75 e4             	pushl  -0x1c(%ebp)
  800453:	ff 75 e0             	pushl  -0x20(%ebp)
  800456:	e8 f5 0e 00 00       	call   801350 <__umoddi3>
  80045b:	83 c4 14             	add    $0x14,%esp
  80045e:	0f be 80 4b 15 80 00 	movsbl 0x80154b(%eax),%eax
  800465:	50                   	push   %eax
  800466:	ff d7                	call   *%edi
  800468:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80046b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80046e:	5b                   	pop    %ebx
  80046f:	5e                   	pop    %esi
  800470:	5f                   	pop    %edi
  800471:	5d                   	pop    %ebp
  800472:	c3                   	ret    

00800473 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800476:	83 fa 01             	cmp    $0x1,%edx
  800479:	7e 0e                	jle    800489 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80047b:	8b 10                	mov    (%eax),%edx
  80047d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800480:	89 08                	mov    %ecx,(%eax)
  800482:	8b 02                	mov    (%edx),%eax
  800484:	8b 52 04             	mov    0x4(%edx),%edx
  800487:	eb 22                	jmp    8004ab <getuint+0x38>
	else if (lflag)
  800489:	85 d2                	test   %edx,%edx
  80048b:	74 10                	je     80049d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80048d:	8b 10                	mov    (%eax),%edx
  80048f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800492:	89 08                	mov    %ecx,(%eax)
  800494:	8b 02                	mov    (%edx),%eax
  800496:	ba 00 00 00 00       	mov    $0x0,%edx
  80049b:	eb 0e                	jmp    8004ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80049d:	8b 10                	mov    (%eax),%edx
  80049f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a2:	89 08                	mov    %ecx,(%eax)
  8004a4:	8b 02                	mov    (%edx),%eax
  8004a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    

008004ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b7:	8b 10                	mov    (%eax),%edx
  8004b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bc:	73 0a                	jae    8004c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c1:	89 08                	mov    %ecx,(%eax)
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	88 02                	mov    %al,(%edx)
}
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d3:	50                   	push   %eax
  8004d4:	ff 75 10             	pushl  0x10(%ebp)
  8004d7:	ff 75 0c             	pushl  0xc(%ebp)
  8004da:	ff 75 08             	pushl  0x8(%ebp)
  8004dd:	e8 05 00 00 00       	call   8004e7 <vprintfmt>
	va_end(ap);
}
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	c9                   	leave  
  8004e6:	c3                   	ret    

008004e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	57                   	push   %edi
  8004eb:	56                   	push   %esi
  8004ec:	53                   	push   %ebx
  8004ed:	83 ec 2c             	sub    $0x2c,%esp
  8004f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f6:	eb 03                	jmp    8004fb <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004f8:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fe:	8d 70 01             	lea    0x1(%eax),%esi
  800501:	0f b6 00             	movzbl (%eax),%eax
  800504:	83 f8 25             	cmp    $0x25,%eax
  800507:	74 27                	je     800530 <vprintfmt+0x49>
			if (ch == '\0')
  800509:	85 c0                	test   %eax,%eax
  80050b:	75 0d                	jne    80051a <vprintfmt+0x33>
  80050d:	e9 9d 04 00 00       	jmp    8009af <vprintfmt+0x4c8>
  800512:	85 c0                	test   %eax,%eax
  800514:	0f 84 95 04 00 00    	je     8009af <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	50                   	push   %eax
  80051f:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800521:	83 c6 01             	add    $0x1,%esi
  800524:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	83 f8 25             	cmp    $0x25,%eax
  80052e:	75 e2                	jne    800512 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800530:	b9 00 00 00 00       	mov    $0x0,%ecx
  800535:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800539:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800540:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800547:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80054e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800555:	eb 08                	jmp    80055f <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80055a:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8d 46 01             	lea    0x1(%esi),%eax
  800562:	89 45 10             	mov    %eax,0x10(%ebp)
  800565:	0f b6 06             	movzbl (%esi),%eax
  800568:	0f b6 d0             	movzbl %al,%edx
  80056b:	83 e8 23             	sub    $0x23,%eax
  80056e:	3c 55                	cmp    $0x55,%al
  800570:	0f 87 fa 03 00 00    	ja     800970 <vprintfmt+0x489>
  800576:	0f b6 c0             	movzbl %al,%eax
  800579:	ff 24 85 80 16 80 00 	jmp    *0x801680(,%eax,4)
  800580:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800583:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800587:	eb d6                	jmp    80055f <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800589:	8d 42 d0             	lea    -0x30(%edx),%eax
  80058c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80058f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800593:	8d 50 d0             	lea    -0x30(%eax),%edx
  800596:	83 fa 09             	cmp    $0x9,%edx
  800599:	77 6b                	ja     800606 <vprintfmt+0x11f>
  80059b:	8b 75 10             	mov    0x10(%ebp),%esi
  80059e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a4:	eb 09                	jmp    8005af <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a9:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8005ad:	eb b0                	jmp    80055f <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005af:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005b2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005b5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005b9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005bc:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005bf:	83 f9 09             	cmp    $0x9,%ecx
  8005c2:	76 eb                	jbe    8005af <vprintfmt+0xc8>
  8005c4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005ca:	eb 3d                	jmp    800609 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005dd:	eb 2a                	jmp    800609 <vprintfmt+0x122>
  8005df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e9:	0f 49 d0             	cmovns %eax,%edx
  8005ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f2:	e9 68 ff ff ff       	jmp    80055f <vprintfmt+0x78>
  8005f7:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800601:	e9 59 ff ff ff       	jmp    80055f <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800609:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060d:	0f 89 4c ff ff ff    	jns    80055f <vprintfmt+0x78>
				width = precision, precision = -1;
  800613:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800619:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800620:	e9 3a ff ff ff       	jmp    80055f <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800625:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062c:	e9 2e ff ff ff       	jmp    80055f <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	ff 30                	pushl  (%eax)
  800640:	ff d7                	call   *%edi
			break;
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	e9 b1 fe ff ff       	jmp    8004fb <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 00                	mov    (%eax),%eax
  800655:	99                   	cltd   
  800656:	31 d0                	xor    %edx,%eax
  800658:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065a:	83 f8 08             	cmp    $0x8,%eax
  80065d:	7f 0b                	jg     80066a <vprintfmt+0x183>
  80065f:	8b 14 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%edx
  800666:	85 d2                	test   %edx,%edx
  800668:	75 15                	jne    80067f <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80066a:	50                   	push   %eax
  80066b:	68 63 15 80 00       	push   $0x801563
  800670:	53                   	push   %ebx
  800671:	57                   	push   %edi
  800672:	e8 53 fe ff ff       	call   8004ca <printfmt>
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	e9 7c fe ff ff       	jmp    8004fb <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80067f:	52                   	push   %edx
  800680:	68 6c 15 80 00       	push   $0x80156c
  800685:	53                   	push   %ebx
  800686:	57                   	push   %edi
  800687:	e8 3e fe ff ff       	call   8004ca <printfmt>
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	e9 67 fe ff ff       	jmp    8004fb <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	b9 5c 15 80 00       	mov    $0x80155c,%ecx
  8006a6:	0f 45 c8             	cmovne %eax,%ecx
  8006a9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b0:	7e 06                	jle    8006b8 <vprintfmt+0x1d1>
  8006b2:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006b6:	75 19                	jne    8006d1 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006bb:	8d 70 01             	lea    0x1(%eax),%esi
  8006be:	0f b6 00             	movzbl (%eax),%eax
  8006c1:	0f be d0             	movsbl %al,%edx
  8006c4:	85 d2                	test   %edx,%edx
  8006c6:	0f 85 9f 00 00 00    	jne    80076b <vprintfmt+0x284>
  8006cc:	e9 8c 00 00 00       	jmp    80075d <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d7:	ff 75 cc             	pushl  -0x34(%ebp)
  8006da:	e8 62 03 00 00       	call   800a41 <strnlen>
  8006df:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006e2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	85 c9                	test   %ecx,%ecx
  8006ea:	0f 8e a6 02 00 00    	jle    800996 <vprintfmt+0x4af>
					putch(padc, putdat);
  8006f0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f7:	89 cb                	mov    %ecx,%ebx
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	ff 75 0c             	pushl  0xc(%ebp)
  8006ff:	56                   	push   %esi
  800700:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	83 eb 01             	sub    $0x1,%ebx
  800708:	75 ef                	jne    8006f9 <vprintfmt+0x212>
  80070a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800710:	e9 81 02 00 00       	jmp    800996 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800715:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800719:	74 1b                	je     800736 <vprintfmt+0x24f>
  80071b:	0f be c0             	movsbl %al,%eax
  80071e:	83 e8 20             	sub    $0x20,%eax
  800721:	83 f8 5e             	cmp    $0x5e,%eax
  800724:	76 10                	jbe    800736 <vprintfmt+0x24f>
					putch('?', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	6a 3f                	push   $0x3f
  80072e:	ff 55 08             	call   *0x8(%ebp)
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	eb 0d                	jmp    800743 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	ff 75 0c             	pushl  0xc(%ebp)
  80073c:	52                   	push   %edx
  80073d:	ff 55 08             	call   *0x8(%ebp)
  800740:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800743:	83 ef 01             	sub    $0x1,%edi
  800746:	83 c6 01             	add    $0x1,%esi
  800749:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80074d:	0f be d0             	movsbl %al,%edx
  800750:	85 d2                	test   %edx,%edx
  800752:	75 31                	jne    800785 <vprintfmt+0x29e>
  800754:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800757:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800760:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800764:	7f 33                	jg     800799 <vprintfmt+0x2b2>
  800766:	e9 90 fd ff ff       	jmp    8004fb <vprintfmt+0x14>
  80076b:	89 7d 08             	mov    %edi,0x8(%ebp)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800771:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800774:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800777:	eb 0c                	jmp    800785 <vprintfmt+0x29e>
  800779:	89 7d 08             	mov    %edi,0x8(%ebp)
  80077c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800782:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800785:	85 db                	test   %ebx,%ebx
  800787:	78 8c                	js     800715 <vprintfmt+0x22e>
  800789:	83 eb 01             	sub    $0x1,%ebx
  80078c:	79 87                	jns    800715 <vprintfmt+0x22e>
  80078e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800791:	8b 7d 08             	mov    0x8(%ebp),%edi
  800794:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800797:	eb c4                	jmp    80075d <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	53                   	push   %ebx
  80079d:	6a 20                	push   $0x20
  80079f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	83 ee 01             	sub    $0x1,%esi
  8007a7:	75 f0                	jne    800799 <vprintfmt+0x2b2>
  8007a9:	e9 4d fd ff ff       	jmp    8004fb <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ae:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8007b2:	7e 16                	jle    8007ca <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8d 50 08             	lea    0x8(%eax),%edx
  8007ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bd:	8b 50 04             	mov    0x4(%eax),%edx
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007c5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007c8:	eb 34                	jmp    8007fe <vprintfmt+0x317>
	else if (lflag)
  8007ca:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007ce:	74 18                	je     8007e8 <vprintfmt+0x301>
		return va_arg(*ap, long);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8d 50 04             	lea    0x4(%eax),%edx
  8007d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d9:	8b 30                	mov    (%eax),%esi
  8007db:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	c1 f8 1f             	sar    $0x1f,%eax
  8007e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007e6:	eb 16                	jmp    8007fe <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f1:	8b 30                	mov    (%eax),%esi
  8007f3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007f6:	89 f0                	mov    %esi,%eax
  8007f8:	c1 f8 1f             	sar    $0x1f,%eax
  8007fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800801:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800804:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800807:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80080a:	85 d2                	test   %edx,%edx
  80080c:	79 28                	jns    800836 <vprintfmt+0x34f>
				putch('-', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	53                   	push   %ebx
  800812:	6a 2d                	push   $0x2d
  800814:	ff d7                	call   *%edi
				num = -(long long) num;
  800816:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800819:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80081c:	f7 d8                	neg    %eax
  80081e:	83 d2 00             	adc    $0x0,%edx
  800821:	f7 da                	neg    %edx
  800823:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800826:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800829:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  80082c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800831:	e9 b2 00 00 00       	jmp    8008e8 <vprintfmt+0x401>
  800836:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  80083b:	85 c9                	test   %ecx,%ecx
  80083d:	0f 84 a5 00 00 00    	je     8008e8 <vprintfmt+0x401>
				putch('+', putdat);
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	53                   	push   %ebx
  800847:	6a 2b                	push   $0x2b
  800849:	ff d7                	call   *%edi
  80084b:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800853:	e9 90 00 00 00       	jmp    8008e8 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	74 0b                	je     800867 <vprintfmt+0x380>
				putch('+', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 2b                	push   $0x2b
  800862:	ff d7                	call   *%edi
  800864:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800867:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80086a:	8d 45 14             	lea    0x14(%ebp),%eax
  80086d:	e8 01 fc ff ff       	call   800473 <getuint>
  800872:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800875:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800878:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80087d:	eb 69                	jmp    8008e8 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	53                   	push   %ebx
  800883:	6a 30                	push   $0x30
  800885:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800887:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80088a:	8d 45 14             	lea    0x14(%ebp),%eax
  80088d:	e8 e1 fb ff ff       	call   800473 <getuint>
  800892:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800895:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800898:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80089b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008a0:	eb 46                	jmp    8008e8 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008a2:	83 ec 08             	sub    $0x8,%esp
  8008a5:	53                   	push   %ebx
  8008a6:	6a 30                	push   $0x30
  8008a8:	ff d7                	call   *%edi
			putch('x', putdat);
  8008aa:	83 c4 08             	add    $0x8,%esp
  8008ad:	53                   	push   %ebx
  8008ae:	6a 78                	push   $0x78
  8008b0:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008cb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d0:	eb 16                	jmp    8008e8 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d8:	e8 96 fb ff ff       	call   800473 <getuint>
  8008dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e8:	83 ec 0c             	sub    $0xc,%esp
  8008eb:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008ef:	56                   	push   %esi
  8008f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008f3:	50                   	push   %eax
  8008f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8008f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8008fa:	89 da                	mov    %ebx,%edx
  8008fc:	89 f8                	mov    %edi,%eax
  8008fe:	e8 55 f9 ff ff       	call   800258 <printnum>
			break;
  800903:	83 c4 20             	add    $0x20,%esp
  800906:	e9 f0 fb ff ff       	jmp    8004fb <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8d 50 04             	lea    0x4(%eax),%edx
  800911:	89 55 14             	mov    %edx,0x14(%ebp)
  800914:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800916:	85 f6                	test   %esi,%esi
  800918:	75 1a                	jne    800934 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	68 04 16 80 00       	push   $0x801604
  800922:	68 6c 15 80 00       	push   $0x80156c
  800927:	e8 18 f9 ff ff       	call   800244 <cprintf>
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	e9 c7 fb ff ff       	jmp    8004fb <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800934:	0f b6 03             	movzbl (%ebx),%eax
  800937:	84 c0                	test   %al,%al
  800939:	79 1f                	jns    80095a <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	68 3c 16 80 00       	push   $0x80163c
  800943:	68 6c 15 80 00       	push   $0x80156c
  800948:	e8 f7 f8 ff ff       	call   800244 <cprintf>
						*tmp = *(char *)putdat;
  80094d:	0f b6 03             	movzbl (%ebx),%eax
  800950:	88 06                	mov    %al,(%esi)
  800952:	83 c4 10             	add    $0x10,%esp
  800955:	e9 a1 fb ff ff       	jmp    8004fb <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  80095a:	88 06                	mov    %al,(%esi)
  80095c:	e9 9a fb ff ff       	jmp    8004fb <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	53                   	push   %ebx
  800965:	52                   	push   %edx
  800966:	ff d7                	call   *%edi
			break;
  800968:	83 c4 10             	add    $0x10,%esp
  80096b:	e9 8b fb ff ff       	jmp    8004fb <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	53                   	push   %ebx
  800974:	6a 25                	push   $0x25
  800976:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800978:	83 c4 10             	add    $0x10,%esp
  80097b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80097f:	0f 84 73 fb ff ff    	je     8004f8 <vprintfmt+0x11>
  800985:	83 ee 01             	sub    $0x1,%esi
  800988:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80098c:	75 f7                	jne    800985 <vprintfmt+0x49e>
  80098e:	89 75 10             	mov    %esi,0x10(%ebp)
  800991:	e9 65 fb ff ff       	jmp    8004fb <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800996:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800999:	8d 70 01             	lea    0x1(%eax),%esi
  80099c:	0f b6 00             	movzbl (%eax),%eax
  80099f:	0f be d0             	movsbl %al,%edx
  8009a2:	85 d2                	test   %edx,%edx
  8009a4:	0f 85 cf fd ff ff    	jne    800779 <vprintfmt+0x292>
  8009aa:	e9 4c fb ff ff       	jmp    8004fb <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5f                   	pop    %edi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 18             	sub    $0x18,%esp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d4:	85 c0                	test   %eax,%eax
  8009d6:	74 26                	je     8009fe <vsnprintf+0x47>
  8009d8:	85 d2                	test   %edx,%edx
  8009da:	7e 22                	jle    8009fe <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009dc:	ff 75 14             	pushl  0x14(%ebp)
  8009df:	ff 75 10             	pushl  0x10(%ebp)
  8009e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e5:	50                   	push   %eax
  8009e6:	68 ad 04 80 00       	push   $0x8004ad
  8009eb:	e8 f7 fa ff ff       	call   8004e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f9:	83 c4 10             	add    $0x10,%esp
  8009fc:	eb 05                	jmp    800a03 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a0b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a0e:	50                   	push   %eax
  800a0f:	ff 75 10             	pushl  0x10(%ebp)
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	ff 75 08             	pushl  0x8(%ebp)
  800a18:	e8 9a ff ff ff       	call   8009b7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a25:	80 3a 00             	cmpb   $0x0,(%edx)
  800a28:	74 10                	je     800a3a <strlen+0x1b>
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a2f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a32:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a36:	75 f7                	jne    800a2f <strlen+0x10>
  800a38:	eb 05                	jmp    800a3f <strlen+0x20>
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4b:	85 c9                	test   %ecx,%ecx
  800a4d:	74 1c                	je     800a6b <strnlen+0x2a>
  800a4f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a52:	74 1e                	je     800a72 <strnlen+0x31>
  800a54:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a59:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5b:	39 ca                	cmp    %ecx,%edx
  800a5d:	74 18                	je     800a77 <strnlen+0x36>
  800a5f:	83 c2 01             	add    $0x1,%edx
  800a62:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a67:	75 f0                	jne    800a59 <strnlen+0x18>
  800a69:	eb 0c                	jmp    800a77 <strnlen+0x36>
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	eb 05                	jmp    800a77 <strnlen+0x36>
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a84:	89 c2                	mov    %eax,%edx
  800a86:	83 c2 01             	add    $0x1,%edx
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a90:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a93:	84 db                	test   %bl,%bl
  800a95:	75 ef                	jne    800a86 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a97:	5b                   	pop    %ebx
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa1:	53                   	push   %ebx
  800aa2:	e8 78 ff ff ff       	call   800a1f <strlen>
  800aa7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800aaa:	ff 75 0c             	pushl  0xc(%ebp)
  800aad:	01 d8                	add    %ebx,%eax
  800aaf:	50                   	push   %eax
  800ab0:	e8 c5 ff ff ff       	call   800a7a <strcpy>
	return dst;
}
  800ab5:	89 d8                	mov    %ebx,%eax
  800ab7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	74 17                	je     800ae5 <strncpy+0x29>
  800ace:	01 f3                	add    %esi,%ebx
  800ad0:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	0f b6 02             	movzbl (%edx),%eax
  800ad8:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800adb:	80 3a 01             	cmpb   $0x1,(%edx)
  800ade:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae1:	39 cb                	cmp    %ecx,%ebx
  800ae3:	75 ed                	jne    800ad2 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae5:	89 f0                	mov    %esi,%eax
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af6:	8b 55 10             	mov    0x10(%ebp),%edx
  800af9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afb:	85 d2                	test   %edx,%edx
  800afd:	74 35                	je     800b34 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800aff:	89 d0                	mov    %edx,%eax
  800b01:	83 e8 01             	sub    $0x1,%eax
  800b04:	74 25                	je     800b2b <strlcpy+0x40>
  800b06:	0f b6 0b             	movzbl (%ebx),%ecx
  800b09:	84 c9                	test   %cl,%cl
  800b0b:	74 22                	je     800b2f <strlcpy+0x44>
  800b0d:	8d 53 01             	lea    0x1(%ebx),%edx
  800b10:	01 c3                	add    %eax,%ebx
  800b12:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b1a:	39 da                	cmp    %ebx,%edx
  800b1c:	74 13                	je     800b31 <strlcpy+0x46>
  800b1e:	83 c2 01             	add    $0x1,%edx
  800b21:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800b25:	84 c9                	test   %cl,%cl
  800b27:	75 eb                	jne    800b14 <strlcpy+0x29>
  800b29:	eb 06                	jmp    800b31 <strlcpy+0x46>
  800b2b:	89 f0                	mov    %esi,%eax
  800b2d:	eb 02                	jmp    800b31 <strlcpy+0x46>
  800b2f:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b34:	29 f0                	sub    %esi,%eax
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b43:	0f b6 01             	movzbl (%ecx),%eax
  800b46:	84 c0                	test   %al,%al
  800b48:	74 15                	je     800b5f <strcmp+0x25>
  800b4a:	3a 02                	cmp    (%edx),%al
  800b4c:	75 11                	jne    800b5f <strcmp+0x25>
		p++, q++;
  800b4e:	83 c1 01             	add    $0x1,%ecx
  800b51:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b54:	0f b6 01             	movzbl (%ecx),%eax
  800b57:	84 c0                	test   %al,%al
  800b59:	74 04                	je     800b5f <strcmp+0x25>
  800b5b:	3a 02                	cmp    (%edx),%al
  800b5d:	74 ef                	je     800b4e <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5f:	0f b6 c0             	movzbl %al,%eax
  800b62:	0f b6 12             	movzbl (%edx),%edx
  800b65:	29 d0                	sub    %edx,%eax
}
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b74:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b77:	85 f6                	test   %esi,%esi
  800b79:	74 29                	je     800ba4 <strncmp+0x3b>
  800b7b:	0f b6 03             	movzbl (%ebx),%eax
  800b7e:	84 c0                	test   %al,%al
  800b80:	74 30                	je     800bb2 <strncmp+0x49>
  800b82:	3a 02                	cmp    (%edx),%al
  800b84:	75 2c                	jne    800bb2 <strncmp+0x49>
  800b86:	8d 43 01             	lea    0x1(%ebx),%eax
  800b89:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b8b:	89 c3                	mov    %eax,%ebx
  800b8d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b90:	39 c6                	cmp    %eax,%esi
  800b92:	74 17                	je     800bab <strncmp+0x42>
  800b94:	0f b6 08             	movzbl (%eax),%ecx
  800b97:	84 c9                	test   %cl,%cl
  800b99:	74 17                	je     800bb2 <strncmp+0x49>
  800b9b:	83 c0 01             	add    $0x1,%eax
  800b9e:	3a 0a                	cmp    (%edx),%cl
  800ba0:	74 e9                	je     800b8b <strncmp+0x22>
  800ba2:	eb 0e                	jmp    800bb2 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	eb 0f                	jmp    800bba <strncmp+0x51>
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb0:	eb 08                	jmp    800bba <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb2:	0f b6 03             	movzbl (%ebx),%eax
  800bb5:	0f b6 12             	movzbl (%edx),%edx
  800bb8:	29 d0                	sub    %edx,%eax
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	53                   	push   %ebx
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800bc8:	0f b6 10             	movzbl (%eax),%edx
  800bcb:	84 d2                	test   %dl,%dl
  800bcd:	74 1d                	je     800bec <strchr+0x2e>
  800bcf:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800bd1:	38 d3                	cmp    %dl,%bl
  800bd3:	75 06                	jne    800bdb <strchr+0x1d>
  800bd5:	eb 1a                	jmp    800bf1 <strchr+0x33>
  800bd7:	38 ca                	cmp    %cl,%dl
  800bd9:	74 16                	je     800bf1 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bdb:	83 c0 01             	add    $0x1,%eax
  800bde:	0f b6 10             	movzbl (%eax),%edx
  800be1:	84 d2                	test   %dl,%dl
  800be3:	75 f2                	jne    800bd7 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bea:	eb 05                	jmp    800bf1 <strchr+0x33>
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bfe:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c01:	38 d3                	cmp    %dl,%bl
  800c03:	74 14                	je     800c19 <strfind+0x25>
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	84 db                	test   %bl,%bl
  800c09:	74 0e                	je     800c19 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c0b:	83 c0 01             	add    $0x1,%eax
  800c0e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c11:	38 ca                	cmp    %cl,%dl
  800c13:	74 04                	je     800c19 <strfind+0x25>
  800c15:	84 d2                	test   %dl,%dl
  800c17:	75 f2                	jne    800c0b <strfind+0x17>
			break;
	return (char *) s;
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c28:	85 c9                	test   %ecx,%ecx
  800c2a:	74 36                	je     800c62 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c2c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c32:	75 28                	jne    800c5c <memset+0x40>
  800c34:	f6 c1 03             	test   $0x3,%cl
  800c37:	75 23                	jne    800c5c <memset+0x40>
		c &= 0xFF;
  800c39:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c3d:	89 d3                	mov    %edx,%ebx
  800c3f:	c1 e3 08             	shl    $0x8,%ebx
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	c1 e6 18             	shl    $0x18,%esi
  800c47:	89 d0                	mov    %edx,%eax
  800c49:	c1 e0 10             	shl    $0x10,%eax
  800c4c:	09 f0                	or     %esi,%eax
  800c4e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c50:	89 d8                	mov    %ebx,%eax
  800c52:	09 d0                	or     %edx,%eax
  800c54:	c1 e9 02             	shr    $0x2,%ecx
  800c57:	fc                   	cld    
  800c58:	f3 ab                	rep stos %eax,%es:(%edi)
  800c5a:	eb 06                	jmp    800c62 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5f:	fc                   	cld    
  800c60:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c62:	89 f8                	mov    %edi,%eax
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c74:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c77:	39 c6                	cmp    %eax,%esi
  800c79:	73 35                	jae    800cb0 <memmove+0x47>
  800c7b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c7e:	39 d0                	cmp    %edx,%eax
  800c80:	73 2e                	jae    800cb0 <memmove+0x47>
		s += n;
		d += n;
  800c82:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	09 fe                	or     %edi,%esi
  800c89:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c8f:	75 13                	jne    800ca4 <memmove+0x3b>
  800c91:	f6 c1 03             	test   $0x3,%cl
  800c94:	75 0e                	jne    800ca4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c96:	83 ef 04             	sub    $0x4,%edi
  800c99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c9c:	c1 e9 02             	shr    $0x2,%ecx
  800c9f:	fd                   	std    
  800ca0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca2:	eb 09                	jmp    800cad <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca4:	83 ef 01             	sub    $0x1,%edi
  800ca7:	8d 72 ff             	lea    -0x1(%edx),%esi
  800caa:	fd                   	std    
  800cab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cad:	fc                   	cld    
  800cae:	eb 1d                	jmp    800ccd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb0:	89 f2                	mov    %esi,%edx
  800cb2:	09 c2                	or     %eax,%edx
  800cb4:	f6 c2 03             	test   $0x3,%dl
  800cb7:	75 0f                	jne    800cc8 <memmove+0x5f>
  800cb9:	f6 c1 03             	test   $0x3,%cl
  800cbc:	75 0a                	jne    800cc8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cbe:	c1 e9 02             	shr    $0x2,%ecx
  800cc1:	89 c7                	mov    %eax,%edi
  800cc3:	fc                   	cld    
  800cc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc6:	eb 05                	jmp    800ccd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cc8:	89 c7                	mov    %eax,%edi
  800cca:	fc                   	cld    
  800ccb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cd4:	ff 75 10             	pushl  0x10(%ebp)
  800cd7:	ff 75 0c             	pushl  0xc(%ebp)
  800cda:	ff 75 08             	pushl  0x8(%ebp)
  800cdd:	e8 87 ff ff ff       	call   800c69 <memmove>
}
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ced:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf0:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	74 39                	je     800d30 <memcmp+0x4c>
  800cf7:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cfa:	0f b6 13             	movzbl (%ebx),%edx
  800cfd:	0f b6 0e             	movzbl (%esi),%ecx
  800d00:	38 ca                	cmp    %cl,%dl
  800d02:	75 17                	jne    800d1b <memcmp+0x37>
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
  800d09:	eb 1a                	jmp    800d25 <memcmp+0x41>
  800d0b:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800d10:	83 c0 01             	add    $0x1,%eax
  800d13:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800d17:	38 ca                	cmp    %cl,%dl
  800d19:	74 0a                	je     800d25 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d1b:	0f b6 c2             	movzbl %dl,%eax
  800d1e:	0f b6 c9             	movzbl %cl,%ecx
  800d21:	29 c8                	sub    %ecx,%eax
  800d23:	eb 10                	jmp    800d35 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d25:	39 f8                	cmp    %edi,%eax
  800d27:	75 e2                	jne    800d0b <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d29:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2e:	eb 05                	jmp    800d35 <memcmp+0x51>
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	53                   	push   %ebx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d41:	89 d0                	mov    %edx,%eax
  800d43:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d46:	39 c2                	cmp    %eax,%edx
  800d48:	73 1d                	jae    800d67 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d4a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d4e:	0f b6 0a             	movzbl (%edx),%ecx
  800d51:	39 d9                	cmp    %ebx,%ecx
  800d53:	75 09                	jne    800d5e <memfind+0x24>
  800d55:	eb 14                	jmp    800d6b <memfind+0x31>
  800d57:	0f b6 0a             	movzbl (%edx),%ecx
  800d5a:	39 d9                	cmp    %ebx,%ecx
  800d5c:	74 11                	je     800d6f <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5e:	83 c2 01             	add    $0x1,%edx
  800d61:	39 d0                	cmp    %edx,%eax
  800d63:	75 f2                	jne    800d57 <memfind+0x1d>
  800d65:	eb 0a                	jmp    800d71 <memfind+0x37>
  800d67:	89 d0                	mov    %edx,%eax
  800d69:	eb 06                	jmp    800d71 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d6b:	89 d0                	mov    %edx,%eax
  800d6d:	eb 02                	jmp    800d71 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d6f:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d71:	5b                   	pop    %ebx
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d80:	0f b6 01             	movzbl (%ecx),%eax
  800d83:	3c 20                	cmp    $0x20,%al
  800d85:	74 04                	je     800d8b <strtol+0x17>
  800d87:	3c 09                	cmp    $0x9,%al
  800d89:	75 0e                	jne    800d99 <strtol+0x25>
		s++;
  800d8b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8e:	0f b6 01             	movzbl (%ecx),%eax
  800d91:	3c 20                	cmp    $0x20,%al
  800d93:	74 f6                	je     800d8b <strtol+0x17>
  800d95:	3c 09                	cmp    $0x9,%al
  800d97:	74 f2                	je     800d8b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d99:	3c 2b                	cmp    $0x2b,%al
  800d9b:	75 0a                	jne    800da7 <strtol+0x33>
		s++;
  800d9d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800da0:	bf 00 00 00 00       	mov    $0x0,%edi
  800da5:	eb 11                	jmp    800db8 <strtol+0x44>
  800da7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dac:	3c 2d                	cmp    $0x2d,%al
  800dae:	75 08                	jne    800db8 <strtol+0x44>
		s++, neg = 1;
  800db0:	83 c1 01             	add    $0x1,%ecx
  800db3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dbe:	75 15                	jne    800dd5 <strtol+0x61>
  800dc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800dc3:	75 10                	jne    800dd5 <strtol+0x61>
  800dc5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800dc9:	75 7c                	jne    800e47 <strtol+0xd3>
		s += 2, base = 16;
  800dcb:	83 c1 02             	add    $0x2,%ecx
  800dce:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dd3:	eb 16                	jmp    800deb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800dd5:	85 db                	test   %ebx,%ebx
  800dd7:	75 12                	jne    800deb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dde:	80 39 30             	cmpb   $0x30,(%ecx)
  800de1:	75 08                	jne    800deb <strtol+0x77>
		s++, base = 8;
  800de3:	83 c1 01             	add    $0x1,%ecx
  800de6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800deb:	b8 00 00 00 00       	mov    $0x0,%eax
  800df0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df3:	0f b6 11             	movzbl (%ecx),%edx
  800df6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800df9:	89 f3                	mov    %esi,%ebx
  800dfb:	80 fb 09             	cmp    $0x9,%bl
  800dfe:	77 08                	ja     800e08 <strtol+0x94>
			dig = *s - '0';
  800e00:	0f be d2             	movsbl %dl,%edx
  800e03:	83 ea 30             	sub    $0x30,%edx
  800e06:	eb 22                	jmp    800e2a <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800e08:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e0b:	89 f3                	mov    %esi,%ebx
  800e0d:	80 fb 19             	cmp    $0x19,%bl
  800e10:	77 08                	ja     800e1a <strtol+0xa6>
			dig = *s - 'a' + 10;
  800e12:	0f be d2             	movsbl %dl,%edx
  800e15:	83 ea 57             	sub    $0x57,%edx
  800e18:	eb 10                	jmp    800e2a <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800e1a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e1d:	89 f3                	mov    %esi,%ebx
  800e1f:	80 fb 19             	cmp    $0x19,%bl
  800e22:	77 16                	ja     800e3a <strtol+0xc6>
			dig = *s - 'A' + 10;
  800e24:	0f be d2             	movsbl %dl,%edx
  800e27:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e2a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e2d:	7d 0b                	jge    800e3a <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e2f:	83 c1 01             	add    $0x1,%ecx
  800e32:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e36:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e38:	eb b9                	jmp    800df3 <strtol+0x7f>

	if (endptr)
  800e3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e3e:	74 0d                	je     800e4d <strtol+0xd9>
		*endptr = (char *) s;
  800e40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e43:	89 0e                	mov    %ecx,(%esi)
  800e45:	eb 06                	jmp    800e4d <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e47:	85 db                	test   %ebx,%ebx
  800e49:	74 98                	je     800de3 <strtol+0x6f>
  800e4b:	eb 9e                	jmp    800deb <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	f7 da                	neg    %edx
  800e51:	85 ff                	test   %edi,%edi
  800e53:	0f 45 c2             	cmovne %edx,%eax
}
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	57                   	push   %edi
  800e5f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 c3                	mov    %eax,%ebx
  800e6d:	89 c7                	mov    %eax,%edi
  800e6f:	51                   	push   %ecx
  800e70:	52                   	push   %edx
  800e71:	53                   	push   %ebx
  800e72:	54                   	push   %esp
  800e73:	55                   	push   %ebp
  800e74:	56                   	push   %esi
  800e75:	57                   	push   %edi
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8d 35 80 0e 80 00    	lea    0x800e80,%esi
  800e7e:	0f 34                	sysenter 

00800e80 <label_21>:
  800e80:	5f                   	pop    %edi
  800e81:	5e                   	pop    %esi
  800e82:	5d                   	pop    %ebp
  800e83:	5c                   	pop    %esp
  800e84:	5b                   	pop    %ebx
  800e85:	5a                   	pop    %edx
  800e86:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e87:	5b                   	pop    %ebx
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_cgetc>:

int
sys_cgetc(void)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e95:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9a:	89 ca                	mov    %ecx,%edx
  800e9c:	89 cb                	mov    %ecx,%ebx
  800e9e:	89 cf                	mov    %ecx,%edi
  800ea0:	51                   	push   %ecx
  800ea1:	52                   	push   %edx
  800ea2:	53                   	push   %ebx
  800ea3:	54                   	push   %esp
  800ea4:	55                   	push   %ebp
  800ea5:	56                   	push   %esi
  800ea6:	57                   	push   %edi
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	8d 35 b1 0e 80 00    	lea    0x800eb1,%esi
  800eaf:	0f 34                	sysenter 

00800eb1 <label_55>:
  800eb1:	5f                   	pop    %edi
  800eb2:	5e                   	pop    %esi
  800eb3:	5d                   	pop    %ebp
  800eb4:	5c                   	pop    %esp
  800eb5:	5b                   	pop    %ebx
  800eb6:	5a                   	pop    %edx
  800eb7:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ec1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec6:	b8 03 00 00 00       	mov    $0x3,%eax
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	89 d9                	mov    %ebx,%ecx
  800ed0:	89 df                	mov    %ebx,%edi
  800ed2:	51                   	push   %ecx
  800ed3:	52                   	push   %edx
  800ed4:	53                   	push   %ebx
  800ed5:	54                   	push   %esp
  800ed6:	55                   	push   %ebp
  800ed7:	56                   	push   %esi
  800ed8:	57                   	push   %edi
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	8d 35 e3 0e 80 00    	lea    0x800ee3,%esi
  800ee1:	0f 34                	sysenter 

00800ee3 <label_90>:
  800ee3:	5f                   	pop    %edi
  800ee4:	5e                   	pop    %esi
  800ee5:	5d                   	pop    %ebp
  800ee6:	5c                   	pop    %esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5a                   	pop    %edx
  800ee9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 17                	jle    800f05 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	50                   	push   %eax
  800ef2:	6a 03                	push   $0x3
  800ef4:	68 04 18 80 00       	push   $0x801804
  800ef9:	6a 2a                	push   $0x2a
  800efb:	68 21 18 80 00       	push   $0x801821
  800f00:	e8 4c f2 ff ff       	call   800151 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f16:	b8 02 00 00 00       	mov    $0x2,%eax
  800f1b:	89 ca                	mov    %ecx,%edx
  800f1d:	89 cb                	mov    %ecx,%ebx
  800f1f:	89 cf                	mov    %ecx,%edi
  800f21:	51                   	push   %ecx
  800f22:	52                   	push   %edx
  800f23:	53                   	push   %ebx
  800f24:	54                   	push   %esp
  800f25:	55                   	push   %ebp
  800f26:	56                   	push   %esi
  800f27:	57                   	push   %edi
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	8d 35 32 0f 80 00    	lea    0x800f32,%esi
  800f30:	0f 34                	sysenter 

00800f32 <label_139>:
  800f32:	5f                   	pop    %edi
  800f33:	5e                   	pop    %esi
  800f34:	5d                   	pop    %ebp
  800f35:	5c                   	pop    %esp
  800f36:	5b                   	pop    %ebx
  800f37:	5a                   	pop    %edx
  800f38:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f39:	5b                   	pop    %ebx
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f42:	bf 00 00 00 00       	mov    $0x0,%edi
  800f47:	b8 04 00 00 00       	mov    $0x4,%eax
  800f4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f52:	89 fb                	mov    %edi,%ebx
  800f54:	51                   	push   %ecx
  800f55:	52                   	push   %edx
  800f56:	53                   	push   %ebx
  800f57:	54                   	push   %esp
  800f58:	55                   	push   %ebp
  800f59:	56                   	push   %esi
  800f5a:	57                   	push   %edi
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	8d 35 65 0f 80 00    	lea    0x800f65,%esi
  800f63:	0f 34                	sysenter 

00800f65 <label_174>:
  800f65:	5f                   	pop    %edi
  800f66:	5e                   	pop    %esi
  800f67:	5d                   	pop    %ebp
  800f68:	5c                   	pop    %esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5a                   	pop    %edx
  800f6b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f6c:	5b                   	pop    %ebx
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <sys_yield>:

void
sys_yield(void)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f75:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f7f:	89 d1                	mov    %edx,%ecx
  800f81:	89 d3                	mov    %edx,%ebx
  800f83:	89 d7                	mov    %edx,%edi
  800f85:	51                   	push   %ecx
  800f86:	52                   	push   %edx
  800f87:	53                   	push   %ebx
  800f88:	54                   	push   %esp
  800f89:	55                   	push   %ebp
  800f8a:	56                   	push   %esi
  800f8b:	57                   	push   %edi
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	8d 35 96 0f 80 00    	lea    0x800f96,%esi
  800f94:	0f 34                	sysenter 

00800f96 <label_209>:
  800f96:	5f                   	pop    %edi
  800f97:	5e                   	pop    %esi
  800f98:	5d                   	pop    %ebp
  800f99:	5c                   	pop    %esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5a                   	pop    %edx
  800f9c:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f9d:	5b                   	pop    %ebx
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	57                   	push   %edi
  800fa5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa6:	bf 00 00 00 00       	mov    $0x0,%edi
  800fab:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb9:	51                   	push   %ecx
  800fba:	52                   	push   %edx
  800fbb:	53                   	push   %ebx
  800fbc:	54                   	push   %esp
  800fbd:	55                   	push   %ebp
  800fbe:	56                   	push   %esi
  800fbf:	57                   	push   %edi
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	8d 35 ca 0f 80 00    	lea    0x800fca,%esi
  800fc8:	0f 34                	sysenter 

00800fca <label_244>:
  800fca:	5f                   	pop    %edi
  800fcb:	5e                   	pop    %esi
  800fcc:	5d                   	pop    %ebp
  800fcd:	5c                   	pop    %esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5a                   	pop    %edx
  800fd0:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7e 17                	jle    800fec <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	50                   	push   %eax
  800fd9:	6a 05                	push   $0x5
  800fdb:	68 04 18 80 00       	push   $0x801804
  800fe0:	6a 2a                	push   $0x2a
  800fe2:	68 21 18 80 00       	push   $0x801821
  800fe7:	e8 65 f1 ff ff       	call   800151 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801006:	8b 7d 14             	mov    0x14(%ebp),%edi
  801009:	51                   	push   %ecx
  80100a:	52                   	push   %edx
  80100b:	53                   	push   %ebx
  80100c:	54                   	push   %esp
  80100d:	55                   	push   %ebp
  80100e:	56                   	push   %esi
  80100f:	57                   	push   %edi
  801010:	89 e5                	mov    %esp,%ebp
  801012:	8d 35 1a 10 80 00    	lea    0x80101a,%esi
  801018:	0f 34                	sysenter 

0080101a <label_295>:
  80101a:	5f                   	pop    %edi
  80101b:	5e                   	pop    %esi
  80101c:	5d                   	pop    %ebp
  80101d:	5c                   	pop    %esp
  80101e:	5b                   	pop    %ebx
  80101f:	5a                   	pop    %edx
  801020:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801021:	85 c0                	test   %eax,%eax
  801023:	7e 17                	jle    80103c <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	50                   	push   %eax
  801029:	6a 06                	push   $0x6
  80102b:	68 04 18 80 00       	push   $0x801804
  801030:	6a 2a                	push   $0x2a
  801032:	68 21 18 80 00       	push   $0x801821
  801037:	e8 15 f1 ff ff       	call   800151 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80103c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103f:	5b                   	pop    %ebx
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801048:	bf 00 00 00 00       	mov    $0x0,%edi
  80104d:	b8 07 00 00 00       	mov    $0x7,%eax
  801052:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801055:	8b 55 08             	mov    0x8(%ebp),%edx
  801058:	89 fb                	mov    %edi,%ebx
  80105a:	51                   	push   %ecx
  80105b:	52                   	push   %edx
  80105c:	53                   	push   %ebx
  80105d:	54                   	push   %esp
  80105e:	55                   	push   %ebp
  80105f:	56                   	push   %esi
  801060:	57                   	push   %edi
  801061:	89 e5                	mov    %esp,%ebp
  801063:	8d 35 6b 10 80 00    	lea    0x80106b,%esi
  801069:	0f 34                	sysenter 

0080106b <label_344>:
  80106b:	5f                   	pop    %edi
  80106c:	5e                   	pop    %esi
  80106d:	5d                   	pop    %ebp
  80106e:	5c                   	pop    %esp
  80106f:	5b                   	pop    %ebx
  801070:	5a                   	pop    %edx
  801071:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 17                	jle    80108d <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	50                   	push   %eax
  80107a:	6a 07                	push   $0x7
  80107c:	68 04 18 80 00       	push   $0x801804
  801081:	6a 2a                	push   $0x2a
  801083:	68 21 18 80 00       	push   $0x801821
  801088:	e8 c4 f0 ff ff       	call   800151 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80108d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801099:	bf 00 00 00 00       	mov    $0x0,%edi
  80109e:	b8 09 00 00 00       	mov    $0x9,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 fb                	mov    %edi,%ebx
  8010ab:	51                   	push   %ecx
  8010ac:	52                   	push   %edx
  8010ad:	53                   	push   %ebx
  8010ae:	54                   	push   %esp
  8010af:	55                   	push   %ebp
  8010b0:	56                   	push   %esi
  8010b1:	57                   	push   %edi
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	8d 35 bc 10 80 00    	lea    0x8010bc,%esi
  8010ba:	0f 34                	sysenter 

008010bc <label_393>:
  8010bc:	5f                   	pop    %edi
  8010bd:	5e                   	pop    %esi
  8010be:	5d                   	pop    %ebp
  8010bf:	5c                   	pop    %esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5a                   	pop    %edx
  8010c2:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	7e 17                	jle    8010de <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	50                   	push   %eax
  8010cb:	6a 09                	push   $0x9
  8010cd:	68 04 18 80 00       	push   $0x801804
  8010d2:	6a 2a                	push   $0x2a
  8010d4:	68 21 18 80 00       	push   $0x801821
  8010d9:	e8 73 f0 ff ff       	call   800151 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fa:	89 fb                	mov    %edi,%ebx
  8010fc:	51                   	push   %ecx
  8010fd:	52                   	push   %edx
  8010fe:	53                   	push   %ebx
  8010ff:	54                   	push   %esp
  801100:	55                   	push   %ebp
  801101:	56                   	push   %esi
  801102:	57                   	push   %edi
  801103:	89 e5                	mov    %esp,%ebp
  801105:	8d 35 0d 11 80 00    	lea    0x80110d,%esi
  80110b:	0f 34                	sysenter 

0080110d <label_442>:
  80110d:	5f                   	pop    %edi
  80110e:	5e                   	pop    %esi
  80110f:	5d                   	pop    %ebp
  801110:	5c                   	pop    %esp
  801111:	5b                   	pop    %ebx
  801112:	5a                   	pop    %edx
  801113:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801114:	85 c0                	test   %eax,%eax
  801116:	7e 17                	jle    80112f <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	50                   	push   %eax
  80111c:	6a 0a                	push   $0xa
  80111e:	68 04 18 80 00       	push   $0x801804
  801123:	6a 2a                	push   $0x2a
  801125:	68 21 18 80 00       	push   $0x801821
  80112a:	e8 22 f0 ff ff       	call   800151 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80112f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801140:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801143:	8b 55 08             	mov    0x8(%ebp),%edx
  801146:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801149:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114c:	51                   	push   %ecx
  80114d:	52                   	push   %edx
  80114e:	53                   	push   %ebx
  80114f:	54                   	push   %esp
  801150:	55                   	push   %ebp
  801151:	56                   	push   %esi
  801152:	57                   	push   %edi
  801153:	89 e5                	mov    %esp,%ebp
  801155:	8d 35 5d 11 80 00    	lea    0x80115d,%esi
  80115b:	0f 34                	sysenter 

0080115d <label_493>:
  80115d:	5f                   	pop    %edi
  80115e:	5e                   	pop    %esi
  80115f:	5d                   	pop    %ebp
  801160:	5c                   	pop    %esp
  801161:	5b                   	pop    %ebx
  801162:	5a                   	pop    %edx
  801163:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801164:	5b                   	pop    %ebx
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80116d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801172:	b8 0d 00 00 00       	mov    $0xd,%eax
  801177:	8b 55 08             	mov    0x8(%ebp),%edx
  80117a:	89 d9                	mov    %ebx,%ecx
  80117c:	89 df                	mov    %ebx,%edi
  80117e:	51                   	push   %ecx
  80117f:	52                   	push   %edx
  801180:	53                   	push   %ebx
  801181:	54                   	push   %esp
  801182:	55                   	push   %ebp
  801183:	56                   	push   %esi
  801184:	57                   	push   %edi
  801185:	89 e5                	mov    %esp,%ebp
  801187:	8d 35 8f 11 80 00    	lea    0x80118f,%esi
  80118d:	0f 34                	sysenter 

0080118f <label_528>:
  80118f:	5f                   	pop    %edi
  801190:	5e                   	pop    %esi
  801191:	5d                   	pop    %ebp
  801192:	5c                   	pop    %esp
  801193:	5b                   	pop    %ebx
  801194:	5a                   	pop    %edx
  801195:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801196:	85 c0                	test   %eax,%eax
  801198:	7e 17                	jle    8011b1 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	50                   	push   %eax
  80119e:	6a 0d                	push   $0xd
  8011a0:	68 04 18 80 00       	push   $0x801804
  8011a5:	6a 2a                	push   $0x2a
  8011a7:	68 21 18 80 00       	push   $0x801821
  8011ac:	e8 a0 ef ff ff       	call   800151 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	57                   	push   %edi
  8011bc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ca:	89 cb                	mov    %ecx,%ebx
  8011cc:	89 cf                	mov    %ecx,%edi
  8011ce:	51                   	push   %ecx
  8011cf:	52                   	push   %edx
  8011d0:	53                   	push   %ebx
  8011d1:	54                   	push   %esp
  8011d2:	55                   	push   %ebp
  8011d3:	56                   	push   %esi
  8011d4:	57                   	push   %edi
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	8d 35 df 11 80 00    	lea    0x8011df,%esi
  8011dd:	0f 34                	sysenter 

008011df <label_577>:
  8011df:	5f                   	pop    %edi
  8011e0:	5e                   	pop    %esi
  8011e1:	5d                   	pop    %ebp
  8011e2:	5c                   	pop    %esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5a                   	pop    %edx
  8011e5:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011e6:	5b                   	pop    %ebx
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  8011f0:	68 3b 18 80 00       	push   $0x80183b
  8011f5:	6a 52                	push   $0x52
  8011f7:	68 2f 18 80 00       	push   $0x80182f
  8011fc:	e8 50 ef ff ff       	call   800151 <_panic>

00801201 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801207:	68 3a 18 80 00       	push   $0x80183a
  80120c:	6a 59                	push   $0x59
  80120e:	68 2f 18 80 00       	push   $0x80182f
  801213:	e8 39 ef ff ff       	call   800151 <_panic>
  801218:	66 90                	xchg   %ax,%ax
  80121a:	66 90                	xchg   %ax,%ax
  80121c:	66 90                	xchg   %ax,%ax
  80121e:	66 90                	xchg   %ax,%ax

00801220 <__udivdi3>:
  801220:	55                   	push   %ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 1c             	sub    $0x1c,%esp
  801227:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80122b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80122f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801237:	85 f6                	test   %esi,%esi
  801239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80123d:	89 ca                	mov    %ecx,%edx
  80123f:	89 f8                	mov    %edi,%eax
  801241:	75 3d                	jne    801280 <__udivdi3+0x60>
  801243:	39 cf                	cmp    %ecx,%edi
  801245:	0f 87 c5 00 00 00    	ja     801310 <__udivdi3+0xf0>
  80124b:	85 ff                	test   %edi,%edi
  80124d:	89 fd                	mov    %edi,%ebp
  80124f:	75 0b                	jne    80125c <__udivdi3+0x3c>
  801251:	b8 01 00 00 00       	mov    $0x1,%eax
  801256:	31 d2                	xor    %edx,%edx
  801258:	f7 f7                	div    %edi
  80125a:	89 c5                	mov    %eax,%ebp
  80125c:	89 c8                	mov    %ecx,%eax
  80125e:	31 d2                	xor    %edx,%edx
  801260:	f7 f5                	div    %ebp
  801262:	89 c1                	mov    %eax,%ecx
  801264:	89 d8                	mov    %ebx,%eax
  801266:	89 cf                	mov    %ecx,%edi
  801268:	f7 f5                	div    %ebp
  80126a:	89 c3                	mov    %eax,%ebx
  80126c:	89 d8                	mov    %ebx,%eax
  80126e:	89 fa                	mov    %edi,%edx
  801270:	83 c4 1c             	add    $0x1c,%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
  801278:	90                   	nop
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	39 ce                	cmp    %ecx,%esi
  801282:	77 74                	ja     8012f8 <__udivdi3+0xd8>
  801284:	0f bd fe             	bsr    %esi,%edi
  801287:	83 f7 1f             	xor    $0x1f,%edi
  80128a:	0f 84 98 00 00 00    	je     801328 <__udivdi3+0x108>
  801290:	bb 20 00 00 00       	mov    $0x20,%ebx
  801295:	89 f9                	mov    %edi,%ecx
  801297:	89 c5                	mov    %eax,%ebp
  801299:	29 fb                	sub    %edi,%ebx
  80129b:	d3 e6                	shl    %cl,%esi
  80129d:	89 d9                	mov    %ebx,%ecx
  80129f:	d3 ed                	shr    %cl,%ebp
  8012a1:	89 f9                	mov    %edi,%ecx
  8012a3:	d3 e0                	shl    %cl,%eax
  8012a5:	09 ee                	or     %ebp,%esi
  8012a7:	89 d9                	mov    %ebx,%ecx
  8012a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ad:	89 d5                	mov    %edx,%ebp
  8012af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012b3:	d3 ed                	shr    %cl,%ebp
  8012b5:	89 f9                	mov    %edi,%ecx
  8012b7:	d3 e2                	shl    %cl,%edx
  8012b9:	89 d9                	mov    %ebx,%ecx
  8012bb:	d3 e8                	shr    %cl,%eax
  8012bd:	09 c2                	or     %eax,%edx
  8012bf:	89 d0                	mov    %edx,%eax
  8012c1:	89 ea                	mov    %ebp,%edx
  8012c3:	f7 f6                	div    %esi
  8012c5:	89 d5                	mov    %edx,%ebp
  8012c7:	89 c3                	mov    %eax,%ebx
  8012c9:	f7 64 24 0c          	mull   0xc(%esp)
  8012cd:	39 d5                	cmp    %edx,%ebp
  8012cf:	72 10                	jb     8012e1 <__udivdi3+0xc1>
  8012d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012d5:	89 f9                	mov    %edi,%ecx
  8012d7:	d3 e6                	shl    %cl,%esi
  8012d9:	39 c6                	cmp    %eax,%esi
  8012db:	73 07                	jae    8012e4 <__udivdi3+0xc4>
  8012dd:	39 d5                	cmp    %edx,%ebp
  8012df:	75 03                	jne    8012e4 <__udivdi3+0xc4>
  8012e1:	83 eb 01             	sub    $0x1,%ebx
  8012e4:	31 ff                	xor    %edi,%edi
  8012e6:	89 d8                	mov    %ebx,%eax
  8012e8:	89 fa                	mov    %edi,%edx
  8012ea:	83 c4 1c             	add    $0x1c,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    
  8012f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f8:	31 ff                	xor    %edi,%edi
  8012fa:	31 db                	xor    %ebx,%ebx
  8012fc:	89 d8                	mov    %ebx,%eax
  8012fe:	89 fa                	mov    %edi,%edx
  801300:	83 c4 1c             	add    $0x1c,%esp
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5f                   	pop    %edi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    
  801308:	90                   	nop
  801309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801310:	89 d8                	mov    %ebx,%eax
  801312:	f7 f7                	div    %edi
  801314:	31 ff                	xor    %edi,%edi
  801316:	89 c3                	mov    %eax,%ebx
  801318:	89 d8                	mov    %ebx,%eax
  80131a:	89 fa                	mov    %edi,%edx
  80131c:	83 c4 1c             	add    $0x1c,%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    
  801324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801328:	39 ce                	cmp    %ecx,%esi
  80132a:	72 0c                	jb     801338 <__udivdi3+0x118>
  80132c:	31 db                	xor    %ebx,%ebx
  80132e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801332:	0f 87 34 ff ff ff    	ja     80126c <__udivdi3+0x4c>
  801338:	bb 01 00 00 00       	mov    $0x1,%ebx
  80133d:	e9 2a ff ff ff       	jmp    80126c <__udivdi3+0x4c>
  801342:	66 90                	xchg   %ax,%ax
  801344:	66 90                	xchg   %ax,%ax
  801346:	66 90                	xchg   %ax,%ax
  801348:	66 90                	xchg   %ax,%ax
  80134a:	66 90                	xchg   %ax,%ax
  80134c:	66 90                	xchg   %ax,%ax
  80134e:	66 90                	xchg   %ax,%ax

00801350 <__umoddi3>:
  801350:	55                   	push   %ebp
  801351:	57                   	push   %edi
  801352:	56                   	push   %esi
  801353:	53                   	push   %ebx
  801354:	83 ec 1c             	sub    $0x1c,%esp
  801357:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80135b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80135f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801363:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801367:	85 d2                	test   %edx,%edx
  801369:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80136d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801371:	89 f3                	mov    %esi,%ebx
  801373:	89 3c 24             	mov    %edi,(%esp)
  801376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80137a:	75 1c                	jne    801398 <__umoddi3+0x48>
  80137c:	39 f7                	cmp    %esi,%edi
  80137e:	76 50                	jbe    8013d0 <__umoddi3+0x80>
  801380:	89 c8                	mov    %ecx,%eax
  801382:	89 f2                	mov    %esi,%edx
  801384:	f7 f7                	div    %edi
  801386:	89 d0                	mov    %edx,%eax
  801388:	31 d2                	xor    %edx,%edx
  80138a:	83 c4 1c             	add    $0x1c,%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    
  801392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801398:	39 f2                	cmp    %esi,%edx
  80139a:	89 d0                	mov    %edx,%eax
  80139c:	77 52                	ja     8013f0 <__umoddi3+0xa0>
  80139e:	0f bd ea             	bsr    %edx,%ebp
  8013a1:	83 f5 1f             	xor    $0x1f,%ebp
  8013a4:	75 5a                	jne    801400 <__umoddi3+0xb0>
  8013a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8013aa:	0f 82 e0 00 00 00    	jb     801490 <__umoddi3+0x140>
  8013b0:	39 0c 24             	cmp    %ecx,(%esp)
  8013b3:	0f 86 d7 00 00 00    	jbe    801490 <__umoddi3+0x140>
  8013b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013c1:	83 c4 1c             	add    $0x1c,%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5e                   	pop    %esi
  8013c6:	5f                   	pop    %edi
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    
  8013c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	85 ff                	test   %edi,%edi
  8013d2:	89 fd                	mov    %edi,%ebp
  8013d4:	75 0b                	jne    8013e1 <__umoddi3+0x91>
  8013d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	f7 f7                	div    %edi
  8013df:	89 c5                	mov    %eax,%ebp
  8013e1:	89 f0                	mov    %esi,%eax
  8013e3:	31 d2                	xor    %edx,%edx
  8013e5:	f7 f5                	div    %ebp
  8013e7:	89 c8                	mov    %ecx,%eax
  8013e9:	f7 f5                	div    %ebp
  8013eb:	89 d0                	mov    %edx,%eax
  8013ed:	eb 99                	jmp    801388 <__umoddi3+0x38>
  8013ef:	90                   	nop
  8013f0:	89 c8                	mov    %ecx,%eax
  8013f2:	89 f2                	mov    %esi,%edx
  8013f4:	83 c4 1c             	add    $0x1c,%esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5e                   	pop    %esi
  8013f9:	5f                   	pop    %edi
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    
  8013fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801400:	8b 34 24             	mov    (%esp),%esi
  801403:	bf 20 00 00 00       	mov    $0x20,%edi
  801408:	89 e9                	mov    %ebp,%ecx
  80140a:	29 ef                	sub    %ebp,%edi
  80140c:	d3 e0                	shl    %cl,%eax
  80140e:	89 f9                	mov    %edi,%ecx
  801410:	89 f2                	mov    %esi,%edx
  801412:	d3 ea                	shr    %cl,%edx
  801414:	89 e9                	mov    %ebp,%ecx
  801416:	09 c2                	or     %eax,%edx
  801418:	89 d8                	mov    %ebx,%eax
  80141a:	89 14 24             	mov    %edx,(%esp)
  80141d:	89 f2                	mov    %esi,%edx
  80141f:	d3 e2                	shl    %cl,%edx
  801421:	89 f9                	mov    %edi,%ecx
  801423:	89 54 24 04          	mov    %edx,0x4(%esp)
  801427:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80142b:	d3 e8                	shr    %cl,%eax
  80142d:	89 e9                	mov    %ebp,%ecx
  80142f:	89 c6                	mov    %eax,%esi
  801431:	d3 e3                	shl    %cl,%ebx
  801433:	89 f9                	mov    %edi,%ecx
  801435:	89 d0                	mov    %edx,%eax
  801437:	d3 e8                	shr    %cl,%eax
  801439:	89 e9                	mov    %ebp,%ecx
  80143b:	09 d8                	or     %ebx,%eax
  80143d:	89 d3                	mov    %edx,%ebx
  80143f:	89 f2                	mov    %esi,%edx
  801441:	f7 34 24             	divl   (%esp)
  801444:	89 d6                	mov    %edx,%esi
  801446:	d3 e3                	shl    %cl,%ebx
  801448:	f7 64 24 04          	mull   0x4(%esp)
  80144c:	39 d6                	cmp    %edx,%esi
  80144e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801452:	89 d1                	mov    %edx,%ecx
  801454:	89 c3                	mov    %eax,%ebx
  801456:	72 08                	jb     801460 <__umoddi3+0x110>
  801458:	75 11                	jne    80146b <__umoddi3+0x11b>
  80145a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80145e:	73 0b                	jae    80146b <__umoddi3+0x11b>
  801460:	2b 44 24 04          	sub    0x4(%esp),%eax
  801464:	1b 14 24             	sbb    (%esp),%edx
  801467:	89 d1                	mov    %edx,%ecx
  801469:	89 c3                	mov    %eax,%ebx
  80146b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80146f:	29 da                	sub    %ebx,%edx
  801471:	19 ce                	sbb    %ecx,%esi
  801473:	89 f9                	mov    %edi,%ecx
  801475:	89 f0                	mov    %esi,%eax
  801477:	d3 e0                	shl    %cl,%eax
  801479:	89 e9                	mov    %ebp,%ecx
  80147b:	d3 ea                	shr    %cl,%edx
  80147d:	89 e9                	mov    %ebp,%ecx
  80147f:	d3 ee                	shr    %cl,%esi
  801481:	09 d0                	or     %edx,%eax
  801483:	89 f2                	mov    %esi,%edx
  801485:	83 c4 1c             	add    $0x1c,%esp
  801488:	5b                   	pop    %ebx
  801489:	5e                   	pop    %esi
  80148a:	5f                   	pop    %edi
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    
  80148d:	8d 76 00             	lea    0x0(%esi),%esi
  801490:	29 f9                	sub    %edi,%ecx
  801492:	19 d6                	sbb    %edx,%esi
  801494:	89 74 24 04          	mov    %esi,0x4(%esp)
  801498:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149c:	e9 18 ff ff ff       	jmp    8013b9 <__umoddi3+0x69>
