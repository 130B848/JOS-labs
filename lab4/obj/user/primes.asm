
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 ec 11 00 00       	call   801238 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 60 15 80 00       	push   $0x801560
  800060:	e8 de 01 00 00       	call   800243 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 a0 11 00 00       	call   80120a <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 6c 15 80 00       	push   $0x80156c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 75 15 80 00       	push   $0x801575
  800080:	e8 cb 00 00 00       	call   800150 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 9f 11 00 00       	call   801238 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 9f 11 00 00       	call   80124f <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 4b 11 00 00       	call   80120a <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 6c 15 80 00       	push   $0x80156c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 75 15 80 00       	push   $0x801575
  8000d2:	e8 79 00 00 00       	call   800150 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 5f 11 00 00       	call   80124f <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800103:	e8 03 0e 00 00       	call   800f0b <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	c1 e0 07             	shl    $0x7,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800144:	6a 00                	push   $0x0
  800146:	e8 70 0d 00 00       	call   800ebb <sys_env_destroy>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800158:	a1 10 20 80 00       	mov    0x802010,%eax
  80015d:	85 c0                	test   %eax,%eax
  80015f:	74 11                	je     800172 <_panic+0x22>
		cprintf("%s: ", argv0);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	50                   	push   %eax
  800165:	68 8d 15 80 00       	push   $0x80158d
  80016a:	e8 d4 00 00 00       	call   800243 <cprintf>
  80016f:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800172:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800178:	e8 8e 0d 00 00       	call   800f0b <sys_getenvid>
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	56                   	push   %esi
  800187:	50                   	push   %eax
  800188:	68 94 15 80 00       	push   $0x801594
  80018d:	e8 b1 00 00 00       	call   800243 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800192:	83 c4 18             	add    $0x18,%esp
  800195:	53                   	push   %ebx
  800196:	ff 75 10             	pushl  0x10(%ebp)
  800199:	e8 54 00 00 00       	call   8001f2 <vcprintf>
	cprintf("\n");
  80019e:	c7 04 24 92 15 80 00 	movl   $0x801592,(%esp)
  8001a5:	e8 99 00 00 00       	call   800243 <cprintf>
  8001aa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ad:	cc                   	int3   
  8001ae:	eb fd                	jmp    8001ad <_panic+0x5d>

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 04             	sub    $0x4,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 13                	mov    (%ebx),%edx
  8001bc:	8d 42 01             	lea    0x1(%edx),%eax
  8001bf:	89 03                	mov    %eax,(%ebx)
  8001c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cd:	75 1a                	jne    8001e9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	68 ff 00 00 00       	push   $0xff
  8001d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001da:	50                   	push   %eax
  8001db:	e8 7a 0c 00 00       	call   800e5a <sys_cputs>
		b->idx = 0;
  8001e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    

008001f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800202:	00 00 00 
	b.cnt = 0;
  800205:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020f:	ff 75 0c             	pushl  0xc(%ebp)
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	68 b0 01 80 00       	push   $0x8001b0
  800221:	e8 c0 02 00 00       	call   8004e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80022f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800235:	50                   	push   %eax
  800236:	e8 1f 0c 00 00       	call   800e5a <sys_cputs>

	return b.cnt;
}
  80023b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800249:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024c:	50                   	push   %eax
  80024d:	ff 75 08             	pushl  0x8(%ebp)
  800250:	e8 9d ff ff ff       	call   8001f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 1c             	sub    $0x1c,%esp
  800260:	89 c7                	mov    %eax,%edi
  800262:	89 d6                	mov    %edx,%esi
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800270:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800273:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800277:	0f 85 bf 00 00 00    	jne    80033c <printnum+0xe5>
  80027d:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800283:	0f 8d de 00 00 00    	jge    800367 <printnum+0x110>
		judge_time_for_space = width;
  800289:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  80028f:	e9 d3 00 00 00       	jmp    800367 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800294:	83 eb 01             	sub    $0x1,%ebx
  800297:	85 db                	test   %ebx,%ebx
  800299:	7f 37                	jg     8002d2 <printnum+0x7b>
  80029b:	e9 ea 00 00 00       	jmp    80038a <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8002a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002a3:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bb:	e8 30 11 00 00       	call   8013f0 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 b7 15 80 00 	movsbl 0x8015b7(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	eb 16                	jmp    8002e8 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8002d2:	83 ec 08             	sub    $0x8,%esp
  8002d5:	56                   	push   %esi
  8002d6:	ff 75 18             	pushl  0x18(%ebp)
  8002d9:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	83 eb 01             	sub    $0x1,%ebx
  8002e1:	75 ef                	jne    8002d2 <printnum+0x7b>
  8002e3:	e9 a2 00 00 00       	jmp    80038a <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8002e8:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8002ee:	0f 85 76 01 00 00    	jne    80046a <printnum+0x213>
		while(num_of_space-- > 0)
  8002f4:	a1 04 20 80 00       	mov    0x802004,%eax
  8002f9:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002fc:	89 15 04 20 80 00    	mov    %edx,0x802004
  800302:	85 c0                	test   %eax,%eax
  800304:	7e 1d                	jle    800323 <printnum+0xcc>
			putch(' ', putdat);
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	56                   	push   %esi
  80030a:	6a 20                	push   $0x20
  80030c:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80030e:	a1 04 20 80 00       	mov    0x802004,%eax
  800313:	8d 50 ff             	lea    -0x1(%eax),%edx
  800316:	89 15 04 20 80 00    	mov    %edx,0x802004
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	85 c0                	test   %eax,%eax
  800321:	7f e3                	jg     800306 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800323:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80032a:	00 00 00 
		judge_time_for_space = 0;
  80032d:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800334:	00 00 00 
	}
}
  800337:	e9 2e 01 00 00       	jmp    80046a <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 45 10             	mov    0x10(%ebp),%eax
  80033f:	ba 00 00 00 00       	mov    $0x0,%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80034a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800350:	83 fa 00             	cmp    $0x0,%edx
  800353:	0f 87 ba 00 00 00    	ja     800413 <printnum+0x1bc>
  800359:	3b 45 10             	cmp    0x10(%ebp),%eax
  80035c:	0f 83 b1 00 00 00    	jae    800413 <printnum+0x1bc>
  800362:	e9 2d ff ff ff       	jmp    800294 <printnum+0x3d>
  800367:	8b 45 10             	mov    0x10(%ebp),%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800372:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800375:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800378:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80037b:	83 fa 00             	cmp    $0x0,%edx
  80037e:	77 37                	ja     8003b7 <printnum+0x160>
  800380:	3b 45 10             	cmp    0x10(%ebp),%eax
  800383:	73 32                	jae    8003b7 <printnum+0x160>
  800385:	e9 16 ff ff ff       	jmp    8002a0 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	83 ec 04             	sub    $0x4,%esp
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039a:	ff 75 e0             	pushl  -0x20(%ebp)
  80039d:	e8 4e 10 00 00       	call   8013f0 <__umoddi3>
  8003a2:	83 c4 14             	add    $0x14,%esp
  8003a5:	0f be 80 b7 15 80 00 	movsbl 0x8015b7(%eax),%eax
  8003ac:	50                   	push   %eax
  8003ad:	ff d7                	call   *%edi
  8003af:	83 c4 10             	add    $0x10,%esp
  8003b2:	e9 b3 00 00 00       	jmp    80046a <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b7:	83 ec 0c             	sub    $0xc,%esp
  8003ba:	ff 75 18             	pushl  0x18(%ebp)
  8003bd:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8003c0:	50                   	push   %eax
  8003c1:	ff 75 10             	pushl  0x10(%ebp)
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d3:	e8 e8 0e 00 00       	call   8012c0 <__udivdi3>
  8003d8:	83 c4 18             	add    $0x18,%esp
  8003db:	52                   	push   %edx
  8003dc:	50                   	push   %eax
  8003dd:	89 f2                	mov    %esi,%edx
  8003df:	89 f8                	mov    %edi,%eax
  8003e1:	e8 71 fe ff ff       	call   800257 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e6:	83 c4 18             	add    $0x18,%esp
  8003e9:	56                   	push   %esi
  8003ea:	83 ec 04             	sub    $0x4,%esp
  8003ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f9:	e8 f2 0f 00 00       	call   8013f0 <__umoddi3>
  8003fe:	83 c4 14             	add    $0x14,%esp
  800401:	0f be 80 b7 15 80 00 	movsbl 0x8015b7(%eax),%eax
  800408:	50                   	push   %eax
  800409:	ff d7                	call   *%edi
  80040b:	83 c4 10             	add    $0x10,%esp
  80040e:	e9 d5 fe ff ff       	jmp    8002e8 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800413:	83 ec 0c             	sub    $0xc,%esp
  800416:	ff 75 18             	pushl  0x18(%ebp)
  800419:	83 eb 01             	sub    $0x1,%ebx
  80041c:	53                   	push   %ebx
  80041d:	ff 75 10             	pushl  0x10(%ebp)
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	ff 75 dc             	pushl  -0x24(%ebp)
  800426:	ff 75 d8             	pushl  -0x28(%ebp)
  800429:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042c:	ff 75 e0             	pushl  -0x20(%ebp)
  80042f:	e8 8c 0e 00 00       	call   8012c0 <__udivdi3>
  800434:	83 c4 18             	add    $0x18,%esp
  800437:	52                   	push   %edx
  800438:	50                   	push   %eax
  800439:	89 f2                	mov    %esi,%edx
  80043b:	89 f8                	mov    %edi,%eax
  80043d:	e8 15 fe ff ff       	call   800257 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800442:	83 c4 18             	add    $0x18,%esp
  800445:	56                   	push   %esi
  800446:	83 ec 04             	sub    $0x4,%esp
  800449:	ff 75 dc             	pushl  -0x24(%ebp)
  80044c:	ff 75 d8             	pushl  -0x28(%ebp)
  80044f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800452:	ff 75 e0             	pushl  -0x20(%ebp)
  800455:	e8 96 0f 00 00       	call   8013f0 <__umoddi3>
  80045a:	83 c4 14             	add    $0x14,%esp
  80045d:	0f be 80 b7 15 80 00 	movsbl 0x8015b7(%eax),%eax
  800464:	50                   	push   %eax
  800465:	ff d7                	call   *%edi
  800467:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80046a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80046d:	5b                   	pop    %ebx
  80046e:	5e                   	pop    %esi
  80046f:	5f                   	pop    %edi
  800470:	5d                   	pop    %ebp
  800471:	c3                   	ret    

00800472 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800475:	83 fa 01             	cmp    $0x1,%edx
  800478:	7e 0e                	jle    800488 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80047f:	89 08                	mov    %ecx,(%eax)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	8b 52 04             	mov    0x4(%edx),%edx
  800486:	eb 22                	jmp    8004aa <getuint+0x38>
	else if (lflag)
  800488:	85 d2                	test   %edx,%edx
  80048a:	74 10                	je     80049c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80048c:	8b 10                	mov    (%eax),%edx
  80048e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800491:	89 08                	mov    %ecx,(%eax)
  800493:	8b 02                	mov    (%edx),%eax
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	eb 0e                	jmp    8004aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004aa:	5d                   	pop    %ebp
  8004ab:	c3                   	ret    

008004ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bb:	73 0a                	jae    8004c7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c5:	88 02                	mov    %al,(%edx)
}
  8004c7:	5d                   	pop    %ebp
  8004c8:	c3                   	ret    

008004c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004cf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d2:	50                   	push   %eax
  8004d3:	ff 75 10             	pushl  0x10(%ebp)
  8004d6:	ff 75 0c             	pushl  0xc(%ebp)
  8004d9:	ff 75 08             	pushl  0x8(%ebp)
  8004dc:	e8 05 00 00 00       	call   8004e6 <vprintfmt>
	va_end(ap);
}
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    

008004e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	53                   	push   %ebx
  8004ec:	83 ec 2c             	sub    $0x2c,%esp
  8004ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f5:	eb 03                	jmp    8004fa <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004f7:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fd:	8d 70 01             	lea    0x1(%eax),%esi
  800500:	0f b6 00             	movzbl (%eax),%eax
  800503:	83 f8 25             	cmp    $0x25,%eax
  800506:	74 27                	je     80052f <vprintfmt+0x49>
			if (ch == '\0')
  800508:	85 c0                	test   %eax,%eax
  80050a:	75 0d                	jne    800519 <vprintfmt+0x33>
  80050c:	e9 9d 04 00 00       	jmp    8009ae <vprintfmt+0x4c8>
  800511:	85 c0                	test   %eax,%eax
  800513:	0f 84 95 04 00 00    	je     8009ae <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	53                   	push   %ebx
  80051d:	50                   	push   %eax
  80051e:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800520:	83 c6 01             	add    $0x1,%esi
  800523:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	83 f8 25             	cmp    $0x25,%eax
  80052d:	75 e2                	jne    800511 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80052f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800534:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800538:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80053f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800546:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80054d:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800554:	eb 08                	jmp    80055e <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800559:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8d 46 01             	lea    0x1(%esi),%eax
  800561:	89 45 10             	mov    %eax,0x10(%ebp)
  800564:	0f b6 06             	movzbl (%esi),%eax
  800567:	0f b6 d0             	movzbl %al,%edx
  80056a:	83 e8 23             	sub    $0x23,%eax
  80056d:	3c 55                	cmp    $0x55,%al
  80056f:	0f 87 fa 03 00 00    	ja     80096f <vprintfmt+0x489>
  800575:	0f b6 c0             	movzbl %al,%eax
  800578:	ff 24 85 00 17 80 00 	jmp    *0x801700(,%eax,4)
  80057f:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800582:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800586:	eb d6                	jmp    80055e <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800588:	8d 42 d0             	lea    -0x30(%edx),%eax
  80058b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80058e:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800592:	8d 50 d0             	lea    -0x30(%eax),%edx
  800595:	83 fa 09             	cmp    $0x9,%edx
  800598:	77 6b                	ja     800605 <vprintfmt+0x11f>
  80059a:	8b 75 10             	mov    0x10(%ebp),%esi
  80059d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a3:	eb 09                	jmp    8005ae <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a8:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8005ac:	eb b0                	jmp    80055e <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ae:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005b1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005b4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005b8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005bb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8005be:	83 f9 09             	cmp    $0x9,%ecx
  8005c1:	76 eb                	jbe    8005ae <vprintfmt+0xc8>
  8005c3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005c9:	eb 3d                	jmp    800608 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005dc:	eb 2a                	jmp    800608 <vprintfmt+0x122>
  8005de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e8:	0f 49 d0             	cmovns %eax,%edx
  8005eb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f1:	e9 68 ff ff ff       	jmp    80055e <vprintfmt+0x78>
  8005f6:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800600:	e9 59 ff ff ff       	jmp    80055e <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800608:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060c:	0f 89 4c ff ff ff    	jns    80055e <vprintfmt+0x78>
				width = precision, precision = -1;
  800612:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800615:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800618:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80061f:	e9 3a ff ff ff       	jmp    80055e <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800624:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062b:	e9 2e ff ff ff       	jmp    80055e <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	ff 30                	pushl  (%eax)
  80063f:	ff d7                	call   *%edi
			break;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	e9 b1 fe ff ff       	jmp    8004fa <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)
  800652:	8b 00                	mov    (%eax),%eax
  800654:	99                   	cltd   
  800655:	31 d0                	xor    %edx,%eax
  800657:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800659:	83 f8 08             	cmp    $0x8,%eax
  80065c:	7f 0b                	jg     800669 <vprintfmt+0x183>
  80065e:	8b 14 85 60 18 80 00 	mov    0x801860(,%eax,4),%edx
  800665:	85 d2                	test   %edx,%edx
  800667:	75 15                	jne    80067e <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800669:	50                   	push   %eax
  80066a:	68 cf 15 80 00       	push   $0x8015cf
  80066f:	53                   	push   %ebx
  800670:	57                   	push   %edi
  800671:	e8 53 fe ff ff       	call   8004c9 <printfmt>
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	e9 7c fe ff ff       	jmp    8004fa <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80067e:	52                   	push   %edx
  80067f:	68 d8 15 80 00       	push   $0x8015d8
  800684:	53                   	push   %ebx
  800685:	57                   	push   %edi
  800686:	e8 3e fe ff ff       	call   8004c9 <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	e9 67 fe ff ff       	jmp    8004fa <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 50 04             	lea    0x4(%eax),%edx
  800699:	89 55 14             	mov    %edx,0x14(%ebp)
  80069c:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	b9 c8 15 80 00       	mov    $0x8015c8,%ecx
  8006a5:	0f 45 c8             	cmovne %eax,%ecx
  8006a8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006af:	7e 06                	jle    8006b7 <vprintfmt+0x1d1>
  8006b1:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006b5:	75 19                	jne    8006d0 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ba:	8d 70 01             	lea    0x1(%eax),%esi
  8006bd:	0f b6 00             	movzbl (%eax),%eax
  8006c0:	0f be d0             	movsbl %al,%edx
  8006c3:	85 d2                	test   %edx,%edx
  8006c5:	0f 85 9f 00 00 00    	jne    80076a <vprintfmt+0x284>
  8006cb:	e9 8c 00 00 00       	jmp    80075c <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d6:	ff 75 cc             	pushl  -0x34(%ebp)
  8006d9:	e8 62 03 00 00       	call   800a40 <strnlen>
  8006de:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006e1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	85 c9                	test   %ecx,%ecx
  8006e9:	0f 8e a6 02 00 00    	jle    800995 <vprintfmt+0x4af>
					putch(padc, putdat);
  8006ef:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f6:	89 cb                	mov    %ecx,%ebx
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	ff 75 0c             	pushl  0xc(%ebp)
  8006fe:	56                   	push   %esi
  8006ff:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	83 eb 01             	sub    $0x1,%ebx
  800707:	75 ef                	jne    8006f8 <vprintfmt+0x212>
  800709:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070f:	e9 81 02 00 00       	jmp    800995 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	74 1b                	je     800735 <vprintfmt+0x24f>
  80071a:	0f be c0             	movsbl %al,%eax
  80071d:	83 e8 20             	sub    $0x20,%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 10                	jbe    800735 <vprintfmt+0x24f>
					putch('?', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff 55 08             	call   *0x8(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	52                   	push   %edx
  80073c:	ff 55 08             	call   *0x8(%ebp)
  80073f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	83 ef 01             	sub    $0x1,%edi
  800745:	83 c6 01             	add    $0x1,%esi
  800748:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80074c:	0f be d0             	movsbl %al,%edx
  80074f:	85 d2                	test   %edx,%edx
  800751:	75 31                	jne    800784 <vprintfmt+0x29e>
  800753:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800756:	8b 7d 08             	mov    0x8(%ebp),%edi
  800759:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800763:	7f 33                	jg     800798 <vprintfmt+0x2b2>
  800765:	e9 90 fd ff ff       	jmp    8004fa <vprintfmt+0x14>
  80076a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80076d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800770:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800773:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800776:	eb 0c                	jmp    800784 <vprintfmt+0x29e>
  800778:	89 7d 08             	mov    %edi,0x8(%ebp)
  80077b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800781:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800784:	85 db                	test   %ebx,%ebx
  800786:	78 8c                	js     800714 <vprintfmt+0x22e>
  800788:	83 eb 01             	sub    $0x1,%ebx
  80078b:	79 87                	jns    800714 <vprintfmt+0x22e>
  80078d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800790:	8b 7d 08             	mov    0x8(%ebp),%edi
  800793:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800796:	eb c4                	jmp    80075c <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	53                   	push   %ebx
  80079c:	6a 20                	push   $0x20
  80079e:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	83 ee 01             	sub    $0x1,%esi
  8007a6:	75 f0                	jne    800798 <vprintfmt+0x2b2>
  8007a8:	e9 4d fd ff ff       	jmp    8004fa <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ad:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8007b1:	7e 16                	jle    8007c9 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 50 08             	lea    0x8(%eax),%edx
  8007b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bc:	8b 50 04             	mov    0x4(%eax),%edx
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007c7:	eb 34                	jmp    8007fd <vprintfmt+0x317>
	else if (lflag)
  8007c9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007cd:	74 18                	je     8007e7 <vprintfmt+0x301>
		return va_arg(*ap, long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 04             	lea    0x4(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d8:	8b 30                	mov    (%eax),%esi
  8007da:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	c1 f8 1f             	sar    $0x1f,%eax
  8007e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007e5:	eb 16                	jmp    8007fd <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8d 50 04             	lea    0x4(%eax),%edx
  8007ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f0:	8b 30                	mov    (%eax),%esi
  8007f2:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	c1 f8 1f             	sar    $0x1f,%eax
  8007fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800800:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800803:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800806:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800809:	85 d2                	test   %edx,%edx
  80080b:	79 28                	jns    800835 <vprintfmt+0x34f>
				putch('-', putdat);
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	53                   	push   %ebx
  800811:	6a 2d                	push   $0x2d
  800813:	ff d7                	call   *%edi
				num = -(long long) num;
  800815:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800818:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80081b:	f7 d8                	neg    %eax
  80081d:	83 d2 00             	adc    $0x0,%edx
  800820:	f7 da                	neg    %edx
  800822:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800825:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800828:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  80082b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800830:	e9 b2 00 00 00       	jmp    8008e7 <vprintfmt+0x401>
  800835:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	0f 84 a5 00 00 00    	je     8008e7 <vprintfmt+0x401>
				putch('+', putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	53                   	push   %ebx
  800846:	6a 2b                	push   $0x2b
  800848:	ff d7                	call   *%edi
  80084a:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  80084d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800852:	e9 90 00 00 00       	jmp    8008e7 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800857:	85 c9                	test   %ecx,%ecx
  800859:	74 0b                	je     800866 <vprintfmt+0x380>
				putch('+', putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 2b                	push   $0x2b
  800861:	ff d7                	call   *%edi
  800863:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800866:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800869:	8d 45 14             	lea    0x14(%ebp),%eax
  80086c:	e8 01 fc ff ff       	call   800472 <getuint>
  800871:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800874:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800877:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80087c:	eb 69                	jmp    8008e7 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80087e:	83 ec 08             	sub    $0x8,%esp
  800881:	53                   	push   %ebx
  800882:	6a 30                	push   $0x30
  800884:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800886:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800889:	8d 45 14             	lea    0x14(%ebp),%eax
  80088c:	e8 e1 fb ff ff       	call   800472 <getuint>
  800891:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800894:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800897:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80089a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80089f:	eb 46                	jmp    8008e7 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	6a 30                	push   $0x30
  8008a7:	ff d7                	call   *%edi
			putch('x', putdat);
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	6a 78                	push   $0x78
  8008af:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b4:	8d 50 04             	lea    0x4(%eax),%edx
  8008b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ba:	8b 00                	mov    (%eax),%eax
  8008bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008c7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008cf:	eb 16                	jmp    8008e7 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d7:	e8 96 fb ff ff       	call   800472 <getuint>
  8008dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008df:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008e2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e7:	83 ec 0c             	sub    $0xc,%esp
  8008ea:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008ee:	56                   	push   %esi
  8008ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008f2:	50                   	push   %eax
  8008f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8008f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8008f9:	89 da                	mov    %ebx,%edx
  8008fb:	89 f8                	mov    %edi,%eax
  8008fd:	e8 55 f9 ff ff       	call   800257 <printnum>
			break;
  800902:	83 c4 20             	add    $0x20,%esp
  800905:	e9 f0 fb ff ff       	jmp    8004fa <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  80090a:	8b 45 14             	mov    0x14(%ebp),%eax
  80090d:	8d 50 04             	lea    0x4(%eax),%edx
  800910:	89 55 14             	mov    %edx,0x14(%ebp)
  800913:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800915:	85 f6                	test   %esi,%esi
  800917:	75 1a                	jne    800933 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	68 70 16 80 00       	push   $0x801670
  800921:	68 d8 15 80 00       	push   $0x8015d8
  800926:	e8 18 f9 ff ff       	call   800243 <cprintf>
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	e9 c7 fb ff ff       	jmp    8004fa <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800933:	0f b6 03             	movzbl (%ebx),%eax
  800936:	84 c0                	test   %al,%al
  800938:	79 1f                	jns    800959 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	68 a8 16 80 00       	push   $0x8016a8
  800942:	68 d8 15 80 00       	push   $0x8015d8
  800947:	e8 f7 f8 ff ff       	call   800243 <cprintf>
						*tmp = *(char *)putdat;
  80094c:	0f b6 03             	movzbl (%ebx),%eax
  80094f:	88 06                	mov    %al,(%esi)
  800951:	83 c4 10             	add    $0x10,%esp
  800954:	e9 a1 fb ff ff       	jmp    8004fa <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800959:	88 06                	mov    %al,(%esi)
  80095b:	e9 9a fb ff ff       	jmp    8004fa <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800960:	83 ec 08             	sub    $0x8,%esp
  800963:	53                   	push   %ebx
  800964:	52                   	push   %edx
  800965:	ff d7                	call   *%edi
			break;
  800967:	83 c4 10             	add    $0x10,%esp
  80096a:	e9 8b fb ff ff       	jmp    8004fa <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096f:	83 ec 08             	sub    $0x8,%esp
  800972:	53                   	push   %ebx
  800973:	6a 25                	push   $0x25
  800975:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800977:	83 c4 10             	add    $0x10,%esp
  80097a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80097e:	0f 84 73 fb ff ff    	je     8004f7 <vprintfmt+0x11>
  800984:	83 ee 01             	sub    $0x1,%esi
  800987:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80098b:	75 f7                	jne    800984 <vprintfmt+0x49e>
  80098d:	89 75 10             	mov    %esi,0x10(%ebp)
  800990:	e9 65 fb ff ff       	jmp    8004fa <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800995:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800998:	8d 70 01             	lea    0x1(%eax),%esi
  80099b:	0f b6 00             	movzbl (%eax),%eax
  80099e:	0f be d0             	movsbl %al,%edx
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	0f 85 cf fd ff ff    	jne    800778 <vprintfmt+0x292>
  8009a9:	e9 4c fb ff ff       	jmp    8004fa <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 18             	sub    $0x18,%esp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	74 26                	je     8009fd <vsnprintf+0x47>
  8009d7:	85 d2                	test   %edx,%edx
  8009d9:	7e 22                	jle    8009fd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009db:	ff 75 14             	pushl  0x14(%ebp)
  8009de:	ff 75 10             	pushl  0x10(%ebp)
  8009e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e4:	50                   	push   %eax
  8009e5:	68 ac 04 80 00       	push   $0x8004ac
  8009ea:	e8 f7 fa ff ff       	call   8004e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f8:	83 c4 10             	add    $0x10,%esp
  8009fb:	eb 05                	jmp    800a02 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a0a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a0d:	50                   	push   %eax
  800a0e:	ff 75 10             	pushl  0x10(%ebp)
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	ff 75 08             	pushl  0x8(%ebp)
  800a17:	e8 9a ff ff ff       	call   8009b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a24:	80 3a 00             	cmpb   $0x0,(%edx)
  800a27:	74 10                	je     800a39 <strlen+0x1b>
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a2e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a31:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a35:	75 f7                	jne    800a2e <strlen+0x10>
  800a37:	eb 05                	jmp    800a3e <strlen+0x20>
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4a:	85 c9                	test   %ecx,%ecx
  800a4c:	74 1c                	je     800a6a <strnlen+0x2a>
  800a4e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a51:	74 1e                	je     800a71 <strnlen+0x31>
  800a53:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a58:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5a:	39 ca                	cmp    %ecx,%edx
  800a5c:	74 18                	je     800a76 <strnlen+0x36>
  800a5e:	83 c2 01             	add    $0x1,%edx
  800a61:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a66:	75 f0                	jne    800a58 <strnlen+0x18>
  800a68:	eb 0c                	jmp    800a76 <strnlen+0x36>
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	eb 05                	jmp    800a76 <strnlen+0x36>
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a76:	5b                   	pop    %ebx
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	53                   	push   %ebx
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a83:	89 c2                	mov    %eax,%edx
  800a85:	83 c2 01             	add    $0x1,%edx
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a8f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a92:	84 db                	test   %bl,%bl
  800a94:	75 ef                	jne    800a85 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a96:	5b                   	pop    %ebx
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	53                   	push   %ebx
  800a9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa0:	53                   	push   %ebx
  800aa1:	e8 78 ff ff ff       	call   800a1e <strlen>
  800aa6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800aa9:	ff 75 0c             	pushl  0xc(%ebp)
  800aac:	01 d8                	add    %ebx,%eax
  800aae:	50                   	push   %eax
  800aaf:	e8 c5 ff ff ff       	call   800a79 <strcpy>
	return dst;
}
  800ab4:	89 d8                	mov    %ebx,%eax
  800ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    

00800abb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	74 17                	je     800ae4 <strncpy+0x29>
  800acd:	01 f3                	add    %esi,%ebx
  800acf:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	0f b6 02             	movzbl (%edx),%eax
  800ad7:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ada:	80 3a 01             	cmpb   $0x1,(%edx)
  800add:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae0:	39 cb                	cmp    %ecx,%ebx
  800ae2:	75 ed                	jne    800ad1 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae4:	89 f0                	mov    %esi,%eax
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	8b 75 08             	mov    0x8(%ebp),%esi
  800af2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af5:	8b 55 10             	mov    0x10(%ebp),%edx
  800af8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afa:	85 d2                	test   %edx,%edx
  800afc:	74 35                	je     800b33 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800afe:	89 d0                	mov    %edx,%eax
  800b00:	83 e8 01             	sub    $0x1,%eax
  800b03:	74 25                	je     800b2a <strlcpy+0x40>
  800b05:	0f b6 0b             	movzbl (%ebx),%ecx
  800b08:	84 c9                	test   %cl,%cl
  800b0a:	74 22                	je     800b2e <strlcpy+0x44>
  800b0c:	8d 53 01             	lea    0x1(%ebx),%edx
  800b0f:	01 c3                	add    %eax,%ebx
  800b11:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800b13:	83 c0 01             	add    $0x1,%eax
  800b16:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b19:	39 da                	cmp    %ebx,%edx
  800b1b:	74 13                	je     800b30 <strlcpy+0x46>
  800b1d:	83 c2 01             	add    $0x1,%edx
  800b20:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800b24:	84 c9                	test   %cl,%cl
  800b26:	75 eb                	jne    800b13 <strlcpy+0x29>
  800b28:	eb 06                	jmp    800b30 <strlcpy+0x46>
  800b2a:	89 f0                	mov    %esi,%eax
  800b2c:	eb 02                	jmp    800b30 <strlcpy+0x46>
  800b2e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b30:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b33:	29 f0                	sub    %esi,%eax
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b42:	0f b6 01             	movzbl (%ecx),%eax
  800b45:	84 c0                	test   %al,%al
  800b47:	74 15                	je     800b5e <strcmp+0x25>
  800b49:	3a 02                	cmp    (%edx),%al
  800b4b:	75 11                	jne    800b5e <strcmp+0x25>
		p++, q++;
  800b4d:	83 c1 01             	add    $0x1,%ecx
  800b50:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b53:	0f b6 01             	movzbl (%ecx),%eax
  800b56:	84 c0                	test   %al,%al
  800b58:	74 04                	je     800b5e <strcmp+0x25>
  800b5a:	3a 02                	cmp    (%edx),%al
  800b5c:	74 ef                	je     800b4d <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5e:	0f b6 c0             	movzbl %al,%eax
  800b61:	0f b6 12             	movzbl (%edx),%edx
  800b64:	29 d0                	sub    %edx,%eax
}
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b73:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b76:	85 f6                	test   %esi,%esi
  800b78:	74 29                	je     800ba3 <strncmp+0x3b>
  800b7a:	0f b6 03             	movzbl (%ebx),%eax
  800b7d:	84 c0                	test   %al,%al
  800b7f:	74 30                	je     800bb1 <strncmp+0x49>
  800b81:	3a 02                	cmp    (%edx),%al
  800b83:	75 2c                	jne    800bb1 <strncmp+0x49>
  800b85:	8d 43 01             	lea    0x1(%ebx),%eax
  800b88:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b8a:	89 c3                	mov    %eax,%ebx
  800b8c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b8f:	39 c6                	cmp    %eax,%esi
  800b91:	74 17                	je     800baa <strncmp+0x42>
  800b93:	0f b6 08             	movzbl (%eax),%ecx
  800b96:	84 c9                	test   %cl,%cl
  800b98:	74 17                	je     800bb1 <strncmp+0x49>
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	3a 0a                	cmp    (%edx),%cl
  800b9f:	74 e9                	je     800b8a <strncmp+0x22>
  800ba1:	eb 0e                	jmp    800bb1 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba8:	eb 0f                	jmp    800bb9 <strncmp+0x51>
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	eb 08                	jmp    800bb9 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb1:	0f b6 03             	movzbl (%ebx),%eax
  800bb4:	0f b6 12             	movzbl (%edx),%edx
  800bb7:	29 d0                	sub    %edx,%eax
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	53                   	push   %ebx
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800bc7:	0f b6 10             	movzbl (%eax),%edx
  800bca:	84 d2                	test   %dl,%dl
  800bcc:	74 1d                	je     800beb <strchr+0x2e>
  800bce:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800bd0:	38 d3                	cmp    %dl,%bl
  800bd2:	75 06                	jne    800bda <strchr+0x1d>
  800bd4:	eb 1a                	jmp    800bf0 <strchr+0x33>
  800bd6:	38 ca                	cmp    %cl,%dl
  800bd8:	74 16                	je     800bf0 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 10             	movzbl (%eax),%edx
  800be0:	84 d2                	test   %dl,%dl
  800be2:	75 f2                	jne    800bd6 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	eb 05                	jmp    800bf0 <strchr+0x33>
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	53                   	push   %ebx
  800bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bfd:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c00:	38 d3                	cmp    %dl,%bl
  800c02:	74 14                	je     800c18 <strfind+0x25>
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	84 db                	test   %bl,%bl
  800c08:	74 0e                	je     800c18 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c10:	38 ca                	cmp    %cl,%dl
  800c12:	74 04                	je     800c18 <strfind+0x25>
  800c14:	84 d2                	test   %dl,%dl
  800c16:	75 f2                	jne    800c0a <strfind+0x17>
			break;
	return (char *) s;
}
  800c18:	5b                   	pop    %ebx
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c24:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c27:	85 c9                	test   %ecx,%ecx
  800c29:	74 36                	je     800c61 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c2b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c31:	75 28                	jne    800c5b <memset+0x40>
  800c33:	f6 c1 03             	test   $0x3,%cl
  800c36:	75 23                	jne    800c5b <memset+0x40>
		c &= 0xFF;
  800c38:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c3c:	89 d3                	mov    %edx,%ebx
  800c3e:	c1 e3 08             	shl    $0x8,%ebx
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	c1 e6 18             	shl    $0x18,%esi
  800c46:	89 d0                	mov    %edx,%eax
  800c48:	c1 e0 10             	shl    $0x10,%eax
  800c4b:	09 f0                	or     %esi,%eax
  800c4d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c4f:	89 d8                	mov    %ebx,%eax
  800c51:	09 d0                	or     %edx,%eax
  800c53:	c1 e9 02             	shr    $0x2,%ecx
  800c56:	fc                   	cld    
  800c57:	f3 ab                	rep stos %eax,%es:(%edi)
  800c59:	eb 06                	jmp    800c61 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5e:	fc                   	cld    
  800c5f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c61:	89 f8                	mov    %edi,%eax
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c76:	39 c6                	cmp    %eax,%esi
  800c78:	73 35                	jae    800caf <memmove+0x47>
  800c7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c7d:	39 d0                	cmp    %edx,%eax
  800c7f:	73 2e                	jae    800caf <memmove+0x47>
		s += n;
		d += n;
  800c81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	09 fe                	or     %edi,%esi
  800c88:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c8e:	75 13                	jne    800ca3 <memmove+0x3b>
  800c90:	f6 c1 03             	test   $0x3,%cl
  800c93:	75 0e                	jne    800ca3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c95:	83 ef 04             	sub    $0x4,%edi
  800c98:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c9b:	c1 e9 02             	shr    $0x2,%ecx
  800c9e:	fd                   	std    
  800c9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca1:	eb 09                	jmp    800cac <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca3:	83 ef 01             	sub    $0x1,%edi
  800ca6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ca9:	fd                   	std    
  800caa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cac:	fc                   	cld    
  800cad:	eb 1d                	jmp    800ccc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800caf:	89 f2                	mov    %esi,%edx
  800cb1:	09 c2                	or     %eax,%edx
  800cb3:	f6 c2 03             	test   $0x3,%dl
  800cb6:	75 0f                	jne    800cc7 <memmove+0x5f>
  800cb8:	f6 c1 03             	test   $0x3,%cl
  800cbb:	75 0a                	jne    800cc7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cbd:	c1 e9 02             	shr    $0x2,%ecx
  800cc0:	89 c7                	mov    %eax,%edi
  800cc2:	fc                   	cld    
  800cc3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc5:	eb 05                	jmp    800ccc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cc7:	89 c7                	mov    %eax,%edi
  800cc9:	fc                   	cld    
  800cca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cd3:	ff 75 10             	pushl  0x10(%ebp)
  800cd6:	ff 75 0c             	pushl  0xc(%ebp)
  800cd9:	ff 75 08             	pushl  0x8(%ebp)
  800cdc:	e8 87 ff ff ff       	call   800c68 <memmove>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cef:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	74 39                	je     800d2f <memcmp+0x4c>
  800cf6:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cf9:	0f b6 13             	movzbl (%ebx),%edx
  800cfc:	0f b6 0e             	movzbl (%esi),%ecx
  800cff:	38 ca                	cmp    %cl,%dl
  800d01:	75 17                	jne    800d1a <memcmp+0x37>
  800d03:	b8 00 00 00 00       	mov    $0x0,%eax
  800d08:	eb 1a                	jmp    800d24 <memcmp+0x41>
  800d0a:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800d0f:	83 c0 01             	add    $0x1,%eax
  800d12:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800d16:	38 ca                	cmp    %cl,%dl
  800d18:	74 0a                	je     800d24 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d1a:	0f b6 c2             	movzbl %dl,%eax
  800d1d:	0f b6 c9             	movzbl %cl,%ecx
  800d20:	29 c8                	sub    %ecx,%eax
  800d22:	eb 10                	jmp    800d34 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d24:	39 f8                	cmp    %edi,%eax
  800d26:	75 e2                	jne    800d0a <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2d:	eb 05                	jmp    800d34 <memcmp+0x51>
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	53                   	push   %ebx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d40:	89 d0                	mov    %edx,%eax
  800d42:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d45:	39 c2                	cmp    %eax,%edx
  800d47:	73 1d                	jae    800d66 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d49:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d4d:	0f b6 0a             	movzbl (%edx),%ecx
  800d50:	39 d9                	cmp    %ebx,%ecx
  800d52:	75 09                	jne    800d5d <memfind+0x24>
  800d54:	eb 14                	jmp    800d6a <memfind+0x31>
  800d56:	0f b6 0a             	movzbl (%edx),%ecx
  800d59:	39 d9                	cmp    %ebx,%ecx
  800d5b:	74 11                	je     800d6e <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5d:	83 c2 01             	add    $0x1,%edx
  800d60:	39 d0                	cmp    %edx,%eax
  800d62:	75 f2                	jne    800d56 <memfind+0x1d>
  800d64:	eb 0a                	jmp    800d70 <memfind+0x37>
  800d66:	89 d0                	mov    %edx,%eax
  800d68:	eb 06                	jmp    800d70 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d6a:	89 d0                	mov    %edx,%eax
  800d6c:	eb 02                	jmp    800d70 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d6e:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d70:	5b                   	pop    %ebx
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7f:	0f b6 01             	movzbl (%ecx),%eax
  800d82:	3c 20                	cmp    $0x20,%al
  800d84:	74 04                	je     800d8a <strtol+0x17>
  800d86:	3c 09                	cmp    $0x9,%al
  800d88:	75 0e                	jne    800d98 <strtol+0x25>
		s++;
  800d8a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8d:	0f b6 01             	movzbl (%ecx),%eax
  800d90:	3c 20                	cmp    $0x20,%al
  800d92:	74 f6                	je     800d8a <strtol+0x17>
  800d94:	3c 09                	cmp    $0x9,%al
  800d96:	74 f2                	je     800d8a <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d98:	3c 2b                	cmp    $0x2b,%al
  800d9a:	75 0a                	jne    800da6 <strtol+0x33>
		s++;
  800d9c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800da4:	eb 11                	jmp    800db7 <strtol+0x44>
  800da6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dab:	3c 2d                	cmp    $0x2d,%al
  800dad:	75 08                	jne    800db7 <strtol+0x44>
		s++, neg = 1;
  800daf:	83 c1 01             	add    $0x1,%ecx
  800db2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dbd:	75 15                	jne    800dd4 <strtol+0x61>
  800dbf:	80 39 30             	cmpb   $0x30,(%ecx)
  800dc2:	75 10                	jne    800dd4 <strtol+0x61>
  800dc4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800dc8:	75 7c                	jne    800e46 <strtol+0xd3>
		s += 2, base = 16;
  800dca:	83 c1 02             	add    $0x2,%ecx
  800dcd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dd2:	eb 16                	jmp    800dea <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800dd4:	85 db                	test   %ebx,%ebx
  800dd6:	75 12                	jne    800dea <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ddd:	80 39 30             	cmpb   $0x30,(%ecx)
  800de0:	75 08                	jne    800dea <strtol+0x77>
		s++, base = 8;
  800de2:	83 c1 01             	add    $0x1,%ecx
  800de5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800dea:	b8 00 00 00 00       	mov    $0x0,%eax
  800def:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df2:	0f b6 11             	movzbl (%ecx),%edx
  800df5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800df8:	89 f3                	mov    %esi,%ebx
  800dfa:	80 fb 09             	cmp    $0x9,%bl
  800dfd:	77 08                	ja     800e07 <strtol+0x94>
			dig = *s - '0';
  800dff:	0f be d2             	movsbl %dl,%edx
  800e02:	83 ea 30             	sub    $0x30,%edx
  800e05:	eb 22                	jmp    800e29 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800e07:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e0a:	89 f3                	mov    %esi,%ebx
  800e0c:	80 fb 19             	cmp    $0x19,%bl
  800e0f:	77 08                	ja     800e19 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800e11:	0f be d2             	movsbl %dl,%edx
  800e14:	83 ea 57             	sub    $0x57,%edx
  800e17:	eb 10                	jmp    800e29 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800e19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e1c:	89 f3                	mov    %esi,%ebx
  800e1e:	80 fb 19             	cmp    $0x19,%bl
  800e21:	77 16                	ja     800e39 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800e23:	0f be d2             	movsbl %dl,%edx
  800e26:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e29:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e2c:	7d 0b                	jge    800e39 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e2e:	83 c1 01             	add    $0x1,%ecx
  800e31:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e35:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e37:	eb b9                	jmp    800df2 <strtol+0x7f>

	if (endptr)
  800e39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e3d:	74 0d                	je     800e4c <strtol+0xd9>
		*endptr = (char *) s;
  800e3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e42:	89 0e                	mov    %ecx,(%esi)
  800e44:	eb 06                	jmp    800e4c <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e46:	85 db                	test   %ebx,%ebx
  800e48:	74 98                	je     800de2 <strtol+0x6f>
  800e4a:	eb 9e                	jmp    800dea <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e4c:	89 c2                	mov    %eax,%edx
  800e4e:	f7 da                	neg    %edx
  800e50:	85 ff                	test   %edi,%edi
  800e52:	0f 45 c2             	cmovne %edx,%eax
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	89 c7                	mov    %eax,%edi
  800e6e:	51                   	push   %ecx
  800e6f:	52                   	push   %edx
  800e70:	53                   	push   %ebx
  800e71:	56                   	push   %esi
  800e72:	57                   	push   %edi
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	8d 35 7e 0e 80 00    	lea    0x800e7e,%esi
  800e7c:	0f 34                	sysenter 

00800e7e <label_21>:
  800e7e:	89 ec                	mov    %ebp,%esp
  800e80:	5d                   	pop    %ebp
  800e81:	5f                   	pop    %edi
  800e82:	5e                   	pop    %esi
  800e83:	5b                   	pop    %ebx
  800e84:	5a                   	pop    %edx
  800e85:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e86:	5b                   	pop    %ebx
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	57                   	push   %edi
  800e8e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e94:	b8 01 00 00 00       	mov    $0x1,%eax
  800e99:	89 ca                	mov    %ecx,%edx
  800e9b:	89 cb                	mov    %ecx,%ebx
  800e9d:	89 cf                	mov    %ecx,%edi
  800e9f:	51                   	push   %ecx
  800ea0:	52                   	push   %edx
  800ea1:	53                   	push   %ebx
  800ea2:	56                   	push   %esi
  800ea3:	57                   	push   %edi
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	8d 35 af 0e 80 00    	lea    0x800eaf,%esi
  800ead:	0f 34                	sysenter 

00800eaf <label_55>:
  800eaf:	89 ec                	mov    %ebp,%esp
  800eb1:	5d                   	pop    %ebp
  800eb2:	5f                   	pop    %edi
  800eb3:	5e                   	pop    %esi
  800eb4:	5b                   	pop    %ebx
  800eb5:	5a                   	pop    %edx
  800eb6:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eb7:	5b                   	pop    %ebx
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec5:	b8 03 00 00 00       	mov    $0x3,%eax
  800eca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecd:	89 d9                	mov    %ebx,%ecx
  800ecf:	89 df                	mov    %ebx,%edi
  800ed1:	51                   	push   %ecx
  800ed2:	52                   	push   %edx
  800ed3:	53                   	push   %ebx
  800ed4:	56                   	push   %esi
  800ed5:	57                   	push   %edi
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	8d 35 e1 0e 80 00    	lea    0x800ee1,%esi
  800edf:	0f 34                	sysenter 

00800ee1 <label_90>:
  800ee1:	89 ec                	mov    %ebp,%esp
  800ee3:	5d                   	pop    %ebp
  800ee4:	5f                   	pop    %edi
  800ee5:	5e                   	pop    %esi
  800ee6:	5b                   	pop    %ebx
  800ee7:	5a                   	pop    %edx
  800ee8:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 17                	jle    800f04 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	50                   	push   %eax
  800ef1:	6a 03                	push   $0x3
  800ef3:	68 84 18 80 00       	push   $0x801884
  800ef8:	6a 29                	push   $0x29
  800efa:	68 a1 18 80 00       	push   $0x8018a1
  800eff:	e8 4c f2 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	57                   	push   %edi
  800f0f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f15:	b8 02 00 00 00       	mov    $0x2,%eax
  800f1a:	89 ca                	mov    %ecx,%edx
  800f1c:	89 cb                	mov    %ecx,%ebx
  800f1e:	89 cf                	mov    %ecx,%edi
  800f20:	51                   	push   %ecx
  800f21:	52                   	push   %edx
  800f22:	53                   	push   %ebx
  800f23:	56                   	push   %esi
  800f24:	57                   	push   %edi
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	8d 35 30 0f 80 00    	lea    0x800f30,%esi
  800f2e:	0f 34                	sysenter 

00800f30 <label_139>:
  800f30:	89 ec                	mov    %ebp,%esp
  800f32:	5d                   	pop    %ebp
  800f33:	5f                   	pop    %edi
  800f34:	5e                   	pop    %esi
  800f35:	5b                   	pop    %ebx
  800f36:	5a                   	pop    %edx
  800f37:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f38:	5b                   	pop    %ebx
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	57                   	push   %edi
  800f40:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f41:	bf 00 00 00 00       	mov    $0x0,%edi
  800f46:	b8 04 00 00 00       	mov    $0x4,%eax
  800f4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f51:	89 fb                	mov    %edi,%ebx
  800f53:	51                   	push   %ecx
  800f54:	52                   	push   %edx
  800f55:	53                   	push   %ebx
  800f56:	56                   	push   %esi
  800f57:	57                   	push   %edi
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	8d 35 63 0f 80 00    	lea    0x800f63,%esi
  800f61:	0f 34                	sysenter 

00800f63 <label_174>:
  800f63:	89 ec                	mov    %ebp,%esp
  800f65:	5d                   	pop    %ebp
  800f66:	5f                   	pop    %edi
  800f67:	5e                   	pop    %esi
  800f68:	5b                   	pop    %ebx
  800f69:	5a                   	pop    %edx
  800f6a:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f6b:	5b                   	pop    %ebx
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <sys_yield>:

void
sys_yield(void)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	57                   	push   %edi
  800f73:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f74:	ba 00 00 00 00       	mov    $0x0,%edx
  800f79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f7e:	89 d1                	mov    %edx,%ecx
  800f80:	89 d3                	mov    %edx,%ebx
  800f82:	89 d7                	mov    %edx,%edi
  800f84:	51                   	push   %ecx
  800f85:	52                   	push   %edx
  800f86:	53                   	push   %ebx
  800f87:	56                   	push   %esi
  800f88:	57                   	push   %edi
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	8d 35 94 0f 80 00    	lea    0x800f94,%esi
  800f92:	0f 34                	sysenter 

00800f94 <label_209>:
  800f94:	89 ec                	mov    %ebp,%esp
  800f96:	5d                   	pop    %ebp
  800f97:	5f                   	pop    %edi
  800f98:	5e                   	pop    %esi
  800f99:	5b                   	pop    %ebx
  800f9a:	5a                   	pop    %edx
  800f9b:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f9c:	5b                   	pop    %ebx
  800f9d:	5f                   	pop    %edi
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa5:	bf 00 00 00 00       	mov    $0x0,%edi
  800faa:	b8 05 00 00 00       	mov    $0x5,%eax
  800faf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb8:	51                   	push   %ecx
  800fb9:	52                   	push   %edx
  800fba:	53                   	push   %ebx
  800fbb:	56                   	push   %esi
  800fbc:	57                   	push   %edi
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	8d 35 c8 0f 80 00    	lea    0x800fc8,%esi
  800fc6:	0f 34                	sysenter 

00800fc8 <label_244>:
  800fc8:	89 ec                	mov    %ebp,%esp
  800fca:	5d                   	pop    %ebp
  800fcb:	5f                   	pop    %edi
  800fcc:	5e                   	pop    %esi
  800fcd:	5b                   	pop    %ebx
  800fce:	5a                   	pop    %edx
  800fcf:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	7e 17                	jle    800feb <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd4:	83 ec 0c             	sub    $0xc,%esp
  800fd7:	50                   	push   %eax
  800fd8:	6a 05                	push   $0x5
  800fda:	68 84 18 80 00       	push   $0x801884
  800fdf:	6a 29                	push   $0x29
  800fe1:	68 a1 18 80 00       	push   $0x8018a1
  800fe6:	e8 65 f1 ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800feb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fee:	5b                   	pop    %ebx
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	57                   	push   %edi
  800ff6:	53                   	push   %ebx
  800ff7:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  801000:	8b 45 0c             	mov    0xc(%ebp),%eax
  801003:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  801006:	8b 45 10             	mov    0x10(%ebp),%eax
  801009:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  80100c:	8b 45 14             	mov    0x14(%ebp),%eax
  80100f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  801012:	8b 45 18             	mov    0x18(%ebp),%eax
  801015:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801018:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80101b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801020:	b8 06 00 00 00       	mov    $0x6,%eax
  801025:	89 cb                	mov    %ecx,%ebx
  801027:	89 cf                	mov    %ecx,%edi
  801029:	51                   	push   %ecx
  80102a:	52                   	push   %edx
  80102b:	53                   	push   %ebx
  80102c:	56                   	push   %esi
  80102d:	57                   	push   %edi
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	8d 35 39 10 80 00    	lea    0x801039,%esi
  801037:	0f 34                	sysenter 

00801039 <label_304>:
  801039:	89 ec                	mov    %ebp,%esp
  80103b:	5d                   	pop    %ebp
  80103c:	5f                   	pop    %edi
  80103d:	5e                   	pop    %esi
  80103e:	5b                   	pop    %ebx
  80103f:	5a                   	pop    %edx
  801040:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801041:	85 c0                	test   %eax,%eax
  801043:	7e 17                	jle    80105c <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	50                   	push   %eax
  801049:	6a 06                	push   $0x6
  80104b:	68 84 18 80 00       	push   $0x801884
  801050:	6a 29                	push   $0x29
  801052:	68 a1 18 80 00       	push   $0x8018a1
  801057:	e8 f4 f0 ff ff       	call   800150 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  80105c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	57                   	push   %edi
  801067:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801068:	bf 00 00 00 00       	mov    $0x0,%edi
  80106d:	b8 07 00 00 00       	mov    $0x7,%eax
  801072:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801075:	8b 55 08             	mov    0x8(%ebp),%edx
  801078:	89 fb                	mov    %edi,%ebx
  80107a:	51                   	push   %ecx
  80107b:	52                   	push   %edx
  80107c:	53                   	push   %ebx
  80107d:	56                   	push   %esi
  80107e:	57                   	push   %edi
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	8d 35 8a 10 80 00    	lea    0x80108a,%esi
  801088:	0f 34                	sysenter 

0080108a <label_353>:
  80108a:	89 ec                	mov    %ebp,%esp
  80108c:	5d                   	pop    %ebp
  80108d:	5f                   	pop    %edi
  80108e:	5e                   	pop    %esi
  80108f:	5b                   	pop    %ebx
  801090:	5a                   	pop    %edx
  801091:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801092:	85 c0                	test   %eax,%eax
  801094:	7e 17                	jle    8010ad <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	50                   	push   %eax
  80109a:	6a 07                	push   $0x7
  80109c:	68 84 18 80 00       	push   $0x801884
  8010a1:	6a 29                	push   $0x29
  8010a3:	68 a1 18 80 00       	push   $0x8018a1
  8010a8:	e8 a3 f0 ff ff       	call   800150 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8010be:	b8 09 00 00 00       	mov    $0x9,%eax
  8010c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c9:	89 fb                	mov    %edi,%ebx
  8010cb:	51                   	push   %ecx
  8010cc:	52                   	push   %edx
  8010cd:	53                   	push   %ebx
  8010ce:	56                   	push   %esi
  8010cf:	57                   	push   %edi
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	8d 35 db 10 80 00    	lea    0x8010db,%esi
  8010d9:	0f 34                	sysenter 

008010db <label_402>:
  8010db:	89 ec                	mov    %ebp,%esp
  8010dd:	5d                   	pop    %ebp
  8010de:	5f                   	pop    %edi
  8010df:	5e                   	pop    %esi
  8010e0:	5b                   	pop    %ebx
  8010e1:	5a                   	pop    %edx
  8010e2:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	7e 17                	jle    8010fe <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	50                   	push   %eax
  8010eb:	6a 09                	push   $0x9
  8010ed:	68 84 18 80 00       	push   $0x801884
  8010f2:	6a 29                	push   $0x29
  8010f4:	68 a1 18 80 00       	push   $0x8018a1
  8010f9:	e8 52 f0 ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801101:	5b                   	pop    %ebx
  801102:	5f                   	pop    %edi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80110a:	bf 00 00 00 00       	mov    $0x0,%edi
  80110f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801114:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801117:	8b 55 08             	mov    0x8(%ebp),%edx
  80111a:	89 fb                	mov    %edi,%ebx
  80111c:	51                   	push   %ecx
  80111d:	52                   	push   %edx
  80111e:	53                   	push   %ebx
  80111f:	56                   	push   %esi
  801120:	57                   	push   %edi
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	8d 35 2c 11 80 00    	lea    0x80112c,%esi
  80112a:	0f 34                	sysenter 

0080112c <label_451>:
  80112c:	89 ec                	mov    %ebp,%esp
  80112e:	5d                   	pop    %ebp
  80112f:	5f                   	pop    %edi
  801130:	5e                   	pop    %esi
  801131:	5b                   	pop    %ebx
  801132:	5a                   	pop    %edx
  801133:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801134:	85 c0                	test   %eax,%eax
  801136:	7e 17                	jle    80114f <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	50                   	push   %eax
  80113c:	6a 0a                	push   $0xa
  80113e:	68 84 18 80 00       	push   $0x801884
  801143:	6a 29                	push   $0x29
  801145:	68 a1 18 80 00       	push   $0x8018a1
  80114a:	e8 01 f0 ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80114f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801152:	5b                   	pop    %ebx
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	57                   	push   %edi
  80115a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80115b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801163:	8b 55 08             	mov    0x8(%ebp),%edx
  801166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801169:	8b 7d 14             	mov    0x14(%ebp),%edi
  80116c:	51                   	push   %ecx
  80116d:	52                   	push   %edx
  80116e:	53                   	push   %ebx
  80116f:	56                   	push   %esi
  801170:	57                   	push   %edi
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	8d 35 7c 11 80 00    	lea    0x80117c,%esi
  80117a:	0f 34                	sysenter 

0080117c <label_502>:
  80117c:	89 ec                	mov    %ebp,%esp
  80117e:	5d                   	pop    %ebp
  80117f:	5f                   	pop    %edi
  801180:	5e                   	pop    %esi
  801181:	5b                   	pop    %ebx
  801182:	5a                   	pop    %edx
  801183:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801184:	5b                   	pop    %ebx
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	57                   	push   %edi
  80118c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	b8 0d 00 00 00       	mov    $0xd,%eax
  801197:	8b 55 08             	mov    0x8(%ebp),%edx
  80119a:	89 d9                	mov    %ebx,%ecx
  80119c:	89 df                	mov    %ebx,%edi
  80119e:	51                   	push   %ecx
  80119f:	52                   	push   %edx
  8011a0:	53                   	push   %ebx
  8011a1:	56                   	push   %esi
  8011a2:	57                   	push   %edi
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	8d 35 ae 11 80 00    	lea    0x8011ae,%esi
  8011ac:	0f 34                	sysenter 

008011ae <label_537>:
  8011ae:	89 ec                	mov    %ebp,%esp
  8011b0:	5d                   	pop    %ebp
  8011b1:	5f                   	pop    %edi
  8011b2:	5e                   	pop    %esi
  8011b3:	5b                   	pop    %ebx
  8011b4:	5a                   	pop    %edx
  8011b5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	7e 17                	jle    8011d1 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	50                   	push   %eax
  8011be:	6a 0d                	push   $0xd
  8011c0:	68 84 18 80 00       	push   $0x801884
  8011c5:	6a 29                	push   $0x29
  8011c7:	68 a1 18 80 00       	push   $0x8018a1
  8011cc:	e8 7f ef ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	57                   	push   %edi
  8011dc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ea:	89 cb                	mov    %ecx,%ebx
  8011ec:	89 cf                	mov    %ecx,%edi
  8011ee:	51                   	push   %ecx
  8011ef:	52                   	push   %edx
  8011f0:	53                   	push   %ebx
  8011f1:	56                   	push   %esi
  8011f2:	57                   	push   %edi
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8d 35 fe 11 80 00    	lea    0x8011fe,%esi
  8011fc:	0f 34                	sysenter 

008011fe <label_586>:
  8011fe:	89 ec                	mov    %ebp,%esp
  801200:	5d                   	pop    %ebp
  801201:	5f                   	pop    %edi
  801202:	5e                   	pop    %esi
  801203:	5b                   	pop    %ebx
  801204:	5a                   	pop    %edx
  801205:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801206:	5b                   	pop    %ebx
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  801210:	68 bb 18 80 00       	push   $0x8018bb
  801215:	6a 52                	push   $0x52
  801217:	68 af 18 80 00       	push   $0x8018af
  80121c:	e8 2f ef ff ff       	call   800150 <_panic>

00801221 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801227:	68 ba 18 80 00       	push   $0x8018ba
  80122c:	6a 59                	push   $0x59
  80122e:	68 af 18 80 00       	push   $0x8018af
  801233:	e8 18 ef ff ff       	call   800150 <_panic>

00801238 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  80123e:	68 d0 18 80 00       	push   $0x8018d0
  801243:	6a 1a                	push   $0x1a
  801245:	68 e9 18 80 00       	push   $0x8018e9
  80124a:	e8 01 ef ff ff       	call   800150 <_panic>

0080124f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801255:	68 f3 18 80 00       	push   $0x8018f3
  80125a:	6a 2a                	push   $0x2a
  80125c:	68 e9 18 80 00       	push   $0x8018e9
  801261:	e8 ea ee ff ff       	call   800150 <_panic>

00801266 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80126c:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801271:	39 c1                	cmp    %eax,%ecx
  801273:	74 19                	je     80128e <ipc_find_env+0x28>
  801275:	b8 01 00 00 00       	mov    $0x1,%eax
  80127a:	89 c2                	mov    %eax,%edx
  80127c:	c1 e2 07             	shl    $0x7,%edx
  80127f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801285:	8b 52 50             	mov    0x50(%edx),%edx
  801288:	39 ca                	cmp    %ecx,%edx
  80128a:	75 14                	jne    8012a0 <ipc_find_env+0x3a>
  80128c:	eb 05                	jmp    801293 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801293:	c1 e0 07             	shl    $0x7,%eax
  801296:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80129b:	8b 40 48             	mov    0x48(%eax),%eax
  80129e:	eb 0f                	jmp    8012af <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012a0:	83 c0 01             	add    $0x1,%eax
  8012a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012a8:	75 d0                	jne    80127a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    
  8012b1:	66 90                	xchg   %ax,%ax
  8012b3:	66 90                	xchg   %ax,%ax
  8012b5:	66 90                	xchg   %ax,%ax
  8012b7:	66 90                	xchg   %ax,%ax
  8012b9:	66 90                	xchg   %ax,%ax
  8012bb:	66 90                	xchg   %ax,%ax
  8012bd:	66 90                	xchg   %ax,%ax
  8012bf:	90                   	nop

008012c0 <__udivdi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 1c             	sub    $0x1c,%esp
  8012c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8012cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8012cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8012d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012d7:	85 f6                	test   %esi,%esi
  8012d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012dd:	89 ca                	mov    %ecx,%edx
  8012df:	89 f8                	mov    %edi,%eax
  8012e1:	75 3d                	jne    801320 <__udivdi3+0x60>
  8012e3:	39 cf                	cmp    %ecx,%edi
  8012e5:	0f 87 c5 00 00 00    	ja     8013b0 <__udivdi3+0xf0>
  8012eb:	85 ff                	test   %edi,%edi
  8012ed:	89 fd                	mov    %edi,%ebp
  8012ef:	75 0b                	jne    8012fc <__udivdi3+0x3c>
  8012f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f6:	31 d2                	xor    %edx,%edx
  8012f8:	f7 f7                	div    %edi
  8012fa:	89 c5                	mov    %eax,%ebp
  8012fc:	89 c8                	mov    %ecx,%eax
  8012fe:	31 d2                	xor    %edx,%edx
  801300:	f7 f5                	div    %ebp
  801302:	89 c1                	mov    %eax,%ecx
  801304:	89 d8                	mov    %ebx,%eax
  801306:	89 cf                	mov    %ecx,%edi
  801308:	f7 f5                	div    %ebp
  80130a:	89 c3                	mov    %eax,%ebx
  80130c:	89 d8                	mov    %ebx,%eax
  80130e:	89 fa                	mov    %edi,%edx
  801310:	83 c4 1c             	add    $0x1c,%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    
  801318:	90                   	nop
  801319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801320:	39 ce                	cmp    %ecx,%esi
  801322:	77 74                	ja     801398 <__udivdi3+0xd8>
  801324:	0f bd fe             	bsr    %esi,%edi
  801327:	83 f7 1f             	xor    $0x1f,%edi
  80132a:	0f 84 98 00 00 00    	je     8013c8 <__udivdi3+0x108>
  801330:	bb 20 00 00 00       	mov    $0x20,%ebx
  801335:	89 f9                	mov    %edi,%ecx
  801337:	89 c5                	mov    %eax,%ebp
  801339:	29 fb                	sub    %edi,%ebx
  80133b:	d3 e6                	shl    %cl,%esi
  80133d:	89 d9                	mov    %ebx,%ecx
  80133f:	d3 ed                	shr    %cl,%ebp
  801341:	89 f9                	mov    %edi,%ecx
  801343:	d3 e0                	shl    %cl,%eax
  801345:	09 ee                	or     %ebp,%esi
  801347:	89 d9                	mov    %ebx,%ecx
  801349:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134d:	89 d5                	mov    %edx,%ebp
  80134f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801353:	d3 ed                	shr    %cl,%ebp
  801355:	89 f9                	mov    %edi,%ecx
  801357:	d3 e2                	shl    %cl,%edx
  801359:	89 d9                	mov    %ebx,%ecx
  80135b:	d3 e8                	shr    %cl,%eax
  80135d:	09 c2                	or     %eax,%edx
  80135f:	89 d0                	mov    %edx,%eax
  801361:	89 ea                	mov    %ebp,%edx
  801363:	f7 f6                	div    %esi
  801365:	89 d5                	mov    %edx,%ebp
  801367:	89 c3                	mov    %eax,%ebx
  801369:	f7 64 24 0c          	mull   0xc(%esp)
  80136d:	39 d5                	cmp    %edx,%ebp
  80136f:	72 10                	jb     801381 <__udivdi3+0xc1>
  801371:	8b 74 24 08          	mov    0x8(%esp),%esi
  801375:	89 f9                	mov    %edi,%ecx
  801377:	d3 e6                	shl    %cl,%esi
  801379:	39 c6                	cmp    %eax,%esi
  80137b:	73 07                	jae    801384 <__udivdi3+0xc4>
  80137d:	39 d5                	cmp    %edx,%ebp
  80137f:	75 03                	jne    801384 <__udivdi3+0xc4>
  801381:	83 eb 01             	sub    $0x1,%ebx
  801384:	31 ff                	xor    %edi,%edi
  801386:	89 d8                	mov    %ebx,%eax
  801388:	89 fa                	mov    %edi,%edx
  80138a:	83 c4 1c             	add    $0x1c,%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    
  801392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801398:	31 ff                	xor    %edi,%edi
  80139a:	31 db                	xor    %ebx,%ebx
  80139c:	89 d8                	mov    %ebx,%eax
  80139e:	89 fa                	mov    %edi,%edx
  8013a0:	83 c4 1c             	add    $0x1c,%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5e                   	pop    %esi
  8013a5:	5f                   	pop    %edi
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    
  8013a8:	90                   	nop
  8013a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	89 d8                	mov    %ebx,%eax
  8013b2:	f7 f7                	div    %edi
  8013b4:	31 ff                	xor    %edi,%edi
  8013b6:	89 c3                	mov    %eax,%ebx
  8013b8:	89 d8                	mov    %ebx,%eax
  8013ba:	89 fa                	mov    %edi,%edx
  8013bc:	83 c4 1c             	add    $0x1c,%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    
  8013c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	39 ce                	cmp    %ecx,%esi
  8013ca:	72 0c                	jb     8013d8 <__udivdi3+0x118>
  8013cc:	31 db                	xor    %ebx,%ebx
  8013ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8013d2:	0f 87 34 ff ff ff    	ja     80130c <__udivdi3+0x4c>
  8013d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8013dd:	e9 2a ff ff ff       	jmp    80130c <__udivdi3+0x4c>
  8013e2:	66 90                	xchg   %ax,%ax
  8013e4:	66 90                	xchg   %ax,%ax
  8013e6:	66 90                	xchg   %ax,%ax
  8013e8:	66 90                	xchg   %ax,%ax
  8013ea:	66 90                	xchg   %ax,%ax
  8013ec:	66 90                	xchg   %ax,%ax
  8013ee:	66 90                	xchg   %ax,%ax

008013f0 <__umoddi3>:
  8013f0:	55                   	push   %ebp
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 1c             	sub    $0x1c,%esp
  8013f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801403:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801407:	85 d2                	test   %edx,%edx
  801409:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80140d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801411:	89 f3                	mov    %esi,%ebx
  801413:	89 3c 24             	mov    %edi,(%esp)
  801416:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141a:	75 1c                	jne    801438 <__umoddi3+0x48>
  80141c:	39 f7                	cmp    %esi,%edi
  80141e:	76 50                	jbe    801470 <__umoddi3+0x80>
  801420:	89 c8                	mov    %ecx,%eax
  801422:	89 f2                	mov    %esi,%edx
  801424:	f7 f7                	div    %edi
  801426:	89 d0                	mov    %edx,%eax
  801428:	31 d2                	xor    %edx,%edx
  80142a:	83 c4 1c             	add    $0x1c,%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5f                   	pop    %edi
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    
  801432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801438:	39 f2                	cmp    %esi,%edx
  80143a:	89 d0                	mov    %edx,%eax
  80143c:	77 52                	ja     801490 <__umoddi3+0xa0>
  80143e:	0f bd ea             	bsr    %edx,%ebp
  801441:	83 f5 1f             	xor    $0x1f,%ebp
  801444:	75 5a                	jne    8014a0 <__umoddi3+0xb0>
  801446:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80144a:	0f 82 e0 00 00 00    	jb     801530 <__umoddi3+0x140>
  801450:	39 0c 24             	cmp    %ecx,(%esp)
  801453:	0f 86 d7 00 00 00    	jbe    801530 <__umoddi3+0x140>
  801459:	8b 44 24 08          	mov    0x8(%esp),%eax
  80145d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801461:	83 c4 1c             	add    $0x1c,%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    
  801469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801470:	85 ff                	test   %edi,%edi
  801472:	89 fd                	mov    %edi,%ebp
  801474:	75 0b                	jne    801481 <__umoddi3+0x91>
  801476:	b8 01 00 00 00       	mov    $0x1,%eax
  80147b:	31 d2                	xor    %edx,%edx
  80147d:	f7 f7                	div    %edi
  80147f:	89 c5                	mov    %eax,%ebp
  801481:	89 f0                	mov    %esi,%eax
  801483:	31 d2                	xor    %edx,%edx
  801485:	f7 f5                	div    %ebp
  801487:	89 c8                	mov    %ecx,%eax
  801489:	f7 f5                	div    %ebp
  80148b:	89 d0                	mov    %edx,%eax
  80148d:	eb 99                	jmp    801428 <__umoddi3+0x38>
  80148f:	90                   	nop
  801490:	89 c8                	mov    %ecx,%eax
  801492:	89 f2                	mov    %esi,%edx
  801494:	83 c4 1c             	add    $0x1c,%esp
  801497:	5b                   	pop    %ebx
  801498:	5e                   	pop    %esi
  801499:	5f                   	pop    %edi
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    
  80149c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a0:	8b 34 24             	mov    (%esp),%esi
  8014a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8014a8:	89 e9                	mov    %ebp,%ecx
  8014aa:	29 ef                	sub    %ebp,%edi
  8014ac:	d3 e0                	shl    %cl,%eax
  8014ae:	89 f9                	mov    %edi,%ecx
  8014b0:	89 f2                	mov    %esi,%edx
  8014b2:	d3 ea                	shr    %cl,%edx
  8014b4:	89 e9                	mov    %ebp,%ecx
  8014b6:	09 c2                	or     %eax,%edx
  8014b8:	89 d8                	mov    %ebx,%eax
  8014ba:	89 14 24             	mov    %edx,(%esp)
  8014bd:	89 f2                	mov    %esi,%edx
  8014bf:	d3 e2                	shl    %cl,%edx
  8014c1:	89 f9                	mov    %edi,%ecx
  8014c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014cb:	d3 e8                	shr    %cl,%eax
  8014cd:	89 e9                	mov    %ebp,%ecx
  8014cf:	89 c6                	mov    %eax,%esi
  8014d1:	d3 e3                	shl    %cl,%ebx
  8014d3:	89 f9                	mov    %edi,%ecx
  8014d5:	89 d0                	mov    %edx,%eax
  8014d7:	d3 e8                	shr    %cl,%eax
  8014d9:	89 e9                	mov    %ebp,%ecx
  8014db:	09 d8                	or     %ebx,%eax
  8014dd:	89 d3                	mov    %edx,%ebx
  8014df:	89 f2                	mov    %esi,%edx
  8014e1:	f7 34 24             	divl   (%esp)
  8014e4:	89 d6                	mov    %edx,%esi
  8014e6:	d3 e3                	shl    %cl,%ebx
  8014e8:	f7 64 24 04          	mull   0x4(%esp)
  8014ec:	39 d6                	cmp    %edx,%esi
  8014ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014f2:	89 d1                	mov    %edx,%ecx
  8014f4:	89 c3                	mov    %eax,%ebx
  8014f6:	72 08                	jb     801500 <__umoddi3+0x110>
  8014f8:	75 11                	jne    80150b <__umoddi3+0x11b>
  8014fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014fe:	73 0b                	jae    80150b <__umoddi3+0x11b>
  801500:	2b 44 24 04          	sub    0x4(%esp),%eax
  801504:	1b 14 24             	sbb    (%esp),%edx
  801507:	89 d1                	mov    %edx,%ecx
  801509:	89 c3                	mov    %eax,%ebx
  80150b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80150f:	29 da                	sub    %ebx,%edx
  801511:	19 ce                	sbb    %ecx,%esi
  801513:	89 f9                	mov    %edi,%ecx
  801515:	89 f0                	mov    %esi,%eax
  801517:	d3 e0                	shl    %cl,%eax
  801519:	89 e9                	mov    %ebp,%ecx
  80151b:	d3 ea                	shr    %cl,%edx
  80151d:	89 e9                	mov    %ebp,%ecx
  80151f:	d3 ee                	shr    %cl,%esi
  801521:	09 d0                	or     %edx,%eax
  801523:	89 f2                	mov    %esi,%edx
  801525:	83 c4 1c             	add    $0x1c,%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    
  80152d:	8d 76 00             	lea    0x0(%esi),%esi
  801530:	29 f9                	sub    %edi,%ecx
  801532:	19 d6                	sbb    %edx,%esi
  801534:	89 74 24 04          	mov    %esi,0x4(%esp)
  801538:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80153c:	e9 18 ff ff ff       	jmp    801459 <__umoddi3+0x69>
