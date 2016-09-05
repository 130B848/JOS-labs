
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 ed 11 00 00       	call   80122e <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 22 0e 00 00       	call   800e71 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 18 80 00       	push   $0x801820
  800059:	e8 4b 01 00 00       	call   8001a9 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 e6 13 00 00       	call   801452 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 bc 13 00 00       	call   80143b <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 e8 0d 00 00       	call   800e71 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 18 80 00       	push   $0x801836
  800091:	e8 13 01 00 00       	call   8001a9 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 a4 13 00 00       	call   801452 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c9:	e8 a3 0d 00 00       	call   800e71 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	c1 e0 07             	shl    $0x7,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010a:	6a 00                	push   $0x0
  80010c:	e8 10 0d 00 00       	call   800e21 <sys_env_destroy>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	53                   	push   %ebx
  80011a:	83 ec 04             	sub    $0x4,%esp
  80011d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800120:	8b 13                	mov    (%ebx),%edx
  800122:	8d 42 01             	lea    0x1(%edx),%eax
  800125:	89 03                	mov    %eax,(%ebx)
  800127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 1a                	jne    80014f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 7a 0c 00 00       	call   800dc0 <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	68 16 01 80 00       	push   $0x800116
  800187:	e8 c0 02 00 00       	call   80044c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	83 c4 08             	add    $0x8,%esp
  80018f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 1f 0c 00 00       	call   800dc0 <sys_cputs>

	return b.cnt;
}
  8001a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 9d ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  8001d9:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001dd:	0f 85 bf 00 00 00    	jne    8002a2 <printnum+0xe5>
  8001e3:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8001e9:	0f 8d de 00 00 00    	jge    8002cd <printnum+0x110>
		judge_time_for_space = width;
  8001ef:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8001f5:	e9 d3 00 00 00       	jmp    8002cd <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001fa:	83 eb 01             	sub    $0x1,%ebx
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7f 37                	jg     800238 <printnum+0x7b>
  800201:	e9 ea 00 00 00       	jmp    8002f0 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800206:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800209:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	56                   	push   %esi
  800212:	83 ec 04             	sub    $0x4,%esp
  800215:	ff 75 dc             	pushl  -0x24(%ebp)
  800218:	ff 75 d8             	pushl  -0x28(%ebp)
  80021b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021e:	ff 75 e0             	pushl  -0x20(%ebp)
  800221:	e8 9a 14 00 00       	call   8016c0 <__umoddi3>
  800226:	83 c4 14             	add    $0x14,%esp
  800229:	0f be 80 53 18 80 00 	movsbl 0x801853(%eax),%eax
  800230:	50                   	push   %eax
  800231:	ff d7                	call   *%edi
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	eb 16                	jmp    80024e <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	ff 75 18             	pushl  0x18(%ebp)
  80023f:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	83 eb 01             	sub    $0x1,%ebx
  800247:	75 ef                	jne    800238 <printnum+0x7b>
  800249:	e9 a2 00 00 00       	jmp    8002f0 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  80024e:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800254:	0f 85 76 01 00 00    	jne    8003d0 <printnum+0x213>
		while(num_of_space-- > 0)
  80025a:	a1 04 20 80 00       	mov    0x802004,%eax
  80025f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800262:	89 15 04 20 80 00    	mov    %edx,0x802004
  800268:	85 c0                	test   %eax,%eax
  80026a:	7e 1d                	jle    800289 <printnum+0xcc>
			putch(' ', putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	6a 20                	push   $0x20
  800272:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800274:	a1 04 20 80 00       	mov    0x802004,%eax
  800279:	8d 50 ff             	lea    -0x1(%eax),%edx
  80027c:	89 15 04 20 80 00    	mov    %edx,0x802004
  800282:	83 c4 10             	add    $0x10,%esp
  800285:	85 c0                	test   %eax,%eax
  800287:	7f e3                	jg     80026c <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800289:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800290:	00 00 00 
		judge_time_for_space = 0;
  800293:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80029a:	00 00 00 
	}
}
  80029d:	e9 2e 01 00 00       	jmp    8003d0 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002b6:	83 fa 00             	cmp    $0x0,%edx
  8002b9:	0f 87 ba 00 00 00    	ja     800379 <printnum+0x1bc>
  8002bf:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002c2:	0f 83 b1 00 00 00    	jae    800379 <printnum+0x1bc>
  8002c8:	e9 2d ff ff ff       	jmp    8001fa <printnum+0x3d>
  8002cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002e1:	83 fa 00             	cmp    $0x0,%edx
  8002e4:	77 37                	ja     80031d <printnum+0x160>
  8002e6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002e9:	73 32                	jae    80031d <printnum+0x160>
  8002eb:	e9 16 ff ff ff       	jmp    800206 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	56                   	push   %esi
  8002f4:	83 ec 04             	sub    $0x4,%esp
  8002f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8002fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800300:	ff 75 e0             	pushl  -0x20(%ebp)
  800303:	e8 b8 13 00 00       	call   8016c0 <__umoddi3>
  800308:	83 c4 14             	add    $0x14,%esp
  80030b:	0f be 80 53 18 80 00 	movsbl 0x801853(%eax),%eax
  800312:	50                   	push   %eax
  800313:	ff d7                	call   *%edi
  800315:	83 c4 10             	add    $0x10,%esp
  800318:	e9 b3 00 00 00       	jmp    8003d0 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	ff 75 18             	pushl  0x18(%ebp)
  800323:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800326:	50                   	push   %eax
  800327:	ff 75 10             	pushl  0x10(%ebp)
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	ff 75 dc             	pushl  -0x24(%ebp)
  800330:	ff 75 d8             	pushl  -0x28(%ebp)
  800333:	ff 75 e4             	pushl  -0x1c(%ebp)
  800336:	ff 75 e0             	pushl  -0x20(%ebp)
  800339:	e8 52 12 00 00       	call   801590 <__udivdi3>
  80033e:	83 c4 18             	add    $0x18,%esp
  800341:	52                   	push   %edx
  800342:	50                   	push   %eax
  800343:	89 f2                	mov    %esi,%edx
  800345:	89 f8                	mov    %edi,%eax
  800347:	e8 71 fe ff ff       	call   8001bd <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	56                   	push   %esi
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	ff 75 dc             	pushl  -0x24(%ebp)
  800356:	ff 75 d8             	pushl  -0x28(%ebp)
  800359:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035c:	ff 75 e0             	pushl  -0x20(%ebp)
  80035f:	e8 5c 13 00 00       	call   8016c0 <__umoddi3>
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	0f be 80 53 18 80 00 	movsbl 0x801853(%eax),%eax
  80036e:	50                   	push   %eax
  80036f:	ff d7                	call   *%edi
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	e9 d5 fe ff ff       	jmp    80024e <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800379:	83 ec 0c             	sub    $0xc,%esp
  80037c:	ff 75 18             	pushl  0x18(%ebp)
  80037f:	83 eb 01             	sub    $0x1,%ebx
  800382:	53                   	push   %ebx
  800383:	ff 75 10             	pushl  0x10(%ebp)
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	ff 75 dc             	pushl  -0x24(%ebp)
  80038c:	ff 75 d8             	pushl  -0x28(%ebp)
  80038f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800392:	ff 75 e0             	pushl  -0x20(%ebp)
  800395:	e8 f6 11 00 00       	call   801590 <__udivdi3>
  80039a:	83 c4 18             	add    $0x18,%esp
  80039d:	52                   	push   %edx
  80039e:	50                   	push   %eax
  80039f:	89 f2                	mov    %esi,%edx
  8003a1:	89 f8                	mov    %edi,%eax
  8003a3:	e8 15 fe ff ff       	call   8001bd <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a8:	83 c4 18             	add    $0x18,%esp
  8003ab:	56                   	push   %esi
  8003ac:	83 ec 04             	sub    $0x4,%esp
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bb:	e8 00 13 00 00       	call   8016c0 <__umoddi3>
  8003c0:	83 c4 14             	add    $0x14,%esp
  8003c3:	0f be 80 53 18 80 00 	movsbl 0x801853(%eax),%eax
  8003ca:	50                   	push   %eax
  8003cb:	ff d7                	call   *%edi
  8003cd:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8003d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5e                   	pop    %esi
  8003d5:	5f                   	pop    %edi
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003db:	83 fa 01             	cmp    $0x1,%edx
  8003de:	7e 0e                	jle    8003ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e5:	89 08                	mov    %ecx,(%eax)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	8b 52 04             	mov    0x4(%edx),%edx
  8003ec:	eb 22                	jmp    800410 <getuint+0x38>
	else if (lflag)
  8003ee:	85 d2                	test   %edx,%edx
  8003f0:	74 10                	je     800402 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f7:	89 08                	mov    %ecx,(%eax)
  8003f9:	8b 02                	mov    (%edx),%eax
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800400:	eb 0e                	jmp    800410 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800402:	8b 10                	mov    (%eax),%edx
  800404:	8d 4a 04             	lea    0x4(%edx),%ecx
  800407:	89 08                	mov    %ecx,(%eax)
  800409:	8b 02                	mov    (%edx),%eax
  80040b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800418:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041c:	8b 10                	mov    (%eax),%edx
  80041e:	3b 50 04             	cmp    0x4(%eax),%edx
  800421:	73 0a                	jae    80042d <sprintputch+0x1b>
		*b->buf++ = ch;
  800423:	8d 4a 01             	lea    0x1(%edx),%ecx
  800426:	89 08                	mov    %ecx,(%eax)
  800428:	8b 45 08             	mov    0x8(%ebp),%eax
  80042b:	88 02                	mov    %al,(%edx)
}
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800435:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800438:	50                   	push   %eax
  800439:	ff 75 10             	pushl  0x10(%ebp)
  80043c:	ff 75 0c             	pushl  0xc(%ebp)
  80043f:	ff 75 08             	pushl  0x8(%ebp)
  800442:	e8 05 00 00 00       	call   80044c <vprintfmt>
	va_end(ap);
}
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	c9                   	leave  
  80044b:	c3                   	ret    

0080044c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	83 ec 2c             	sub    $0x2c,%esp
  800455:	8b 7d 08             	mov    0x8(%ebp),%edi
  800458:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045b:	eb 03                	jmp    800460 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80045d:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800460:	8b 45 10             	mov    0x10(%ebp),%eax
  800463:	8d 70 01             	lea    0x1(%eax),%esi
  800466:	0f b6 00             	movzbl (%eax),%eax
  800469:	83 f8 25             	cmp    $0x25,%eax
  80046c:	74 27                	je     800495 <vprintfmt+0x49>
			if (ch == '\0')
  80046e:	85 c0                	test   %eax,%eax
  800470:	75 0d                	jne    80047f <vprintfmt+0x33>
  800472:	e9 9d 04 00 00       	jmp    800914 <vprintfmt+0x4c8>
  800477:	85 c0                	test   %eax,%eax
  800479:	0f 84 95 04 00 00    	je     800914 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	53                   	push   %ebx
  800483:	50                   	push   %eax
  800484:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800486:	83 c6 01             	add    $0x1,%esi
  800489:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	83 f8 25             	cmp    $0x25,%eax
  800493:	75 e2                	jne    800477 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800495:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80049e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ac:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004b3:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004ba:	eb 08                	jmp    8004c4 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8004bf:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8d 46 01             	lea    0x1(%esi),%eax
  8004c7:	89 45 10             	mov    %eax,0x10(%ebp)
  8004ca:	0f b6 06             	movzbl (%esi),%eax
  8004cd:	0f b6 d0             	movzbl %al,%edx
  8004d0:	83 e8 23             	sub    $0x23,%eax
  8004d3:	3c 55                	cmp    $0x55,%al
  8004d5:	0f 87 fa 03 00 00    	ja     8008d5 <vprintfmt+0x489>
  8004db:	0f b6 c0             	movzbl %al,%eax
  8004de:	ff 24 85 a0 19 80 00 	jmp    *0x8019a0(,%eax,4)
  8004e5:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e8:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8004ec:	eb d6                	jmp    8004c4 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ee:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004f4:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004f8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004fb:	83 fa 09             	cmp    $0x9,%edx
  8004fe:	77 6b                	ja     80056b <vprintfmt+0x11f>
  800500:	8b 75 10             	mov    0x10(%ebp),%esi
  800503:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800506:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800509:	eb 09                	jmp    800514 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80050e:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800512:	eb b0                	jmp    8004c4 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800514:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800517:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80051a:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80051e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800521:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800524:	83 f9 09             	cmp    $0x9,%ecx
  800527:	76 eb                	jbe    800514 <vprintfmt+0xc8>
  800529:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80052c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80052f:	eb 3d                	jmp    80056e <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 50 04             	lea    0x4(%eax),%edx
  800537:	89 55 14             	mov    %edx,0x14(%ebp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800542:	eb 2a                	jmp    80056e <vprintfmt+0x122>
  800544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800547:	85 c0                	test   %eax,%eax
  800549:	ba 00 00 00 00       	mov    $0x0,%edx
  80054e:	0f 49 d0             	cmovns %eax,%edx
  800551:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800554:	8b 75 10             	mov    0x10(%ebp),%esi
  800557:	e9 68 ff ff ff       	jmp    8004c4 <vprintfmt+0x78>
  80055c:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80055f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800566:	e9 59 ff ff ff       	jmp    8004c4 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80056e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800572:	0f 89 4c ff ff ff    	jns    8004c4 <vprintfmt+0x78>
				width = precision, precision = -1;
  800578:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80057b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800585:	e9 3a ff ff ff       	jmp    8004c4 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80058a:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800591:	e9 2e ff ff ff       	jmp    8004c4 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 50 04             	lea    0x4(%eax),%edx
  80059c:	89 55 14             	mov    %edx,0x14(%ebp)
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	53                   	push   %ebx
  8005a3:	ff 30                	pushl  (%eax)
  8005a5:	ff d7                	call   *%edi
			break;
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	e9 b1 fe ff ff       	jmp    800460 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	99                   	cltd   
  8005bb:	31 d0                	xor    %edx,%eax
  8005bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005bf:	83 f8 08             	cmp    $0x8,%eax
  8005c2:	7f 0b                	jg     8005cf <vprintfmt+0x183>
  8005c4:	8b 14 85 00 1b 80 00 	mov    0x801b00(,%eax,4),%edx
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	75 15                	jne    8005e4 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8005cf:	50                   	push   %eax
  8005d0:	68 6b 18 80 00       	push   $0x80186b
  8005d5:	53                   	push   %ebx
  8005d6:	57                   	push   %edi
  8005d7:	e8 53 fe ff ff       	call   80042f <printfmt>
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	e9 7c fe ff ff       	jmp    800460 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005e4:	52                   	push   %edx
  8005e5:	68 74 18 80 00       	push   $0x801874
  8005ea:	53                   	push   %ebx
  8005eb:	57                   	push   %edi
  8005ec:	e8 3e fe ff ff       	call   80042f <printfmt>
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	e9 67 fe ff ff       	jmp    800460 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800604:	85 c0                	test   %eax,%eax
  800606:	b9 64 18 80 00       	mov    $0x801864,%ecx
  80060b:	0f 45 c8             	cmovne %eax,%ecx
  80060e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800611:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800615:	7e 06                	jle    80061d <vprintfmt+0x1d1>
  800617:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80061b:	75 19                	jne    800636 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800620:	8d 70 01             	lea    0x1(%eax),%esi
  800623:	0f b6 00             	movzbl (%eax),%eax
  800626:	0f be d0             	movsbl %al,%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	0f 85 9f 00 00 00    	jne    8006d0 <vprintfmt+0x284>
  800631:	e9 8c 00 00 00       	jmp    8006c2 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	ff 75 d0             	pushl  -0x30(%ebp)
  80063c:	ff 75 cc             	pushl  -0x34(%ebp)
  80063f:	e8 62 03 00 00       	call   8009a6 <strnlen>
  800644:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800647:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	85 c9                	test   %ecx,%ecx
  80064f:	0f 8e a6 02 00 00    	jle    8008fb <vprintfmt+0x4af>
					putch(padc, putdat);
  800655:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800659:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065c:	89 cb                	mov    %ecx,%ebx
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 0c             	pushl  0xc(%ebp)
  800664:	56                   	push   %esi
  800665:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	83 eb 01             	sub    $0x1,%ebx
  80066d:	75 ef                	jne    80065e <vprintfmt+0x212>
  80066f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800675:	e9 81 02 00 00       	jmp    8008fb <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80067a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067e:	74 1b                	je     80069b <vprintfmt+0x24f>
  800680:	0f be c0             	movsbl %al,%eax
  800683:	83 e8 20             	sub    $0x20,%eax
  800686:	83 f8 5e             	cmp    $0x5e,%eax
  800689:	76 10                	jbe    80069b <vprintfmt+0x24f>
					putch('?', putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	ff 75 0c             	pushl  0xc(%ebp)
  800691:	6a 3f                	push   $0x3f
  800693:	ff 55 08             	call   *0x8(%ebp)
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	eb 0d                	jmp    8006a8 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	52                   	push   %edx
  8006a2:	ff 55 08             	call   *0x8(%ebp)
  8006a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a8:	83 ef 01             	sub    $0x1,%edi
  8006ab:	83 c6 01             	add    $0x1,%esi
  8006ae:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8006b2:	0f be d0             	movsbl %al,%edx
  8006b5:	85 d2                	test   %edx,%edx
  8006b7:	75 31                	jne    8006ea <vprintfmt+0x29e>
  8006b9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c9:	7f 33                	jg     8006fe <vprintfmt+0x2b2>
  8006cb:	e9 90 fd ff ff       	jmp    800460 <vprintfmt+0x14>
  8006d0:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006dc:	eb 0c                	jmp    8006ea <vprintfmt+0x29e>
  8006de:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ea:	85 db                	test   %ebx,%ebx
  8006ec:	78 8c                	js     80067a <vprintfmt+0x22e>
  8006ee:	83 eb 01             	sub    $0x1,%ebx
  8006f1:	79 87                	jns    80067a <vprintfmt+0x22e>
  8006f3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fc:	eb c4                	jmp    8006c2 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	6a 20                	push   $0x20
  800704:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	83 ee 01             	sub    $0x1,%esi
  80070c:	75 f0                	jne    8006fe <vprintfmt+0x2b2>
  80070e:	e9 4d fd ff ff       	jmp    800460 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800713:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800717:	7e 16                	jle    80072f <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8d 50 08             	lea    0x8(%eax),%edx
  80071f:	89 55 14             	mov    %edx,0x14(%ebp)
  800722:	8b 50 04             	mov    0x4(%eax),%edx
  800725:	8b 00                	mov    (%eax),%eax
  800727:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80072a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80072d:	eb 34                	jmp    800763 <vprintfmt+0x317>
	else if (lflag)
  80072f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800733:	74 18                	je     80074d <vprintfmt+0x301>
		return va_arg(*ap, long);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8d 50 04             	lea    0x4(%eax),%edx
  80073b:	89 55 14             	mov    %edx,0x14(%ebp)
  80073e:	8b 30                	mov    (%eax),%esi
  800740:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800743:	89 f0                	mov    %esi,%eax
  800745:	c1 f8 1f             	sar    $0x1f,%eax
  800748:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80074b:	eb 16                	jmp    800763 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8d 50 04             	lea    0x4(%eax),%edx
  800753:	89 55 14             	mov    %edx,0x14(%ebp)
  800756:	8b 30                	mov    (%eax),%esi
  800758:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80075b:	89 f0                	mov    %esi,%eax
  80075d:	c1 f8 1f             	sar    $0x1f,%eax
  800760:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800763:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800766:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800769:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80076f:	85 d2                	test   %edx,%edx
  800771:	79 28                	jns    80079b <vprintfmt+0x34f>
				putch('-', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 2d                	push   $0x2d
  800779:	ff d7                	call   *%edi
				num = -(long long) num;
  80077b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80077e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800781:	f7 d8                	neg    %eax
  800783:	83 d2 00             	adc    $0x0,%edx
  800786:	f7 da                	neg    %edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80078e:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800791:	b8 0a 00 00 00       	mov    $0xa,%eax
  800796:	e9 b2 00 00 00       	jmp    80084d <vprintfmt+0x401>
  80079b:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8007a0:	85 c9                	test   %ecx,%ecx
  8007a2:	0f 84 a5 00 00 00    	je     80084d <vprintfmt+0x401>
				putch('+', putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	53                   	push   %ebx
  8007ac:	6a 2b                	push   $0x2b
  8007ae:	ff d7                	call   *%edi
  8007b0:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8007b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b8:	e9 90 00 00 00       	jmp    80084d <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8007bd:	85 c9                	test   %ecx,%ecx
  8007bf:	74 0b                	je     8007cc <vprintfmt+0x380>
				putch('+', putdat);
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	53                   	push   %ebx
  8007c5:	6a 2b                	push   $0x2b
  8007c7:	ff d7                	call   *%edi
  8007c9:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8007cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 01 fc ff ff       	call   8003d8 <getuint>
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007e2:	eb 69                	jmp    80084d <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  8007e4:	83 ec 08             	sub    $0x8,%esp
  8007e7:	53                   	push   %ebx
  8007e8:	6a 30                	push   $0x30
  8007ea:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007ec:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f2:	e8 e1 fb ff ff       	call   8003d8 <getuint>
  8007f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8007fd:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800800:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800805:	eb 46                	jmp    80084d <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	6a 30                	push   $0x30
  80080d:	ff d7                	call   *%edi
			putch('x', putdat);
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	53                   	push   %ebx
  800813:	6a 78                	push   $0x78
  800815:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 04             	lea    0x4(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800820:	8b 00                	mov    (%eax),%eax
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
  800827:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80082d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800830:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800835:	eb 16                	jmp    80084d <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800837:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
  80083d:	e8 96 fb ff ff       	call   8003d8 <getuint>
  800842:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800845:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800848:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80084d:	83 ec 0c             	sub    $0xc,%esp
  800850:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800854:	56                   	push   %esi
  800855:	ff 75 e4             	pushl  -0x1c(%ebp)
  800858:	50                   	push   %eax
  800859:	ff 75 dc             	pushl  -0x24(%ebp)
  80085c:	ff 75 d8             	pushl  -0x28(%ebp)
  80085f:	89 da                	mov    %ebx,%edx
  800861:	89 f8                	mov    %edi,%eax
  800863:	e8 55 f9 ff ff       	call   8001bd <printnum>
			break;
  800868:	83 c4 20             	add    $0x20,%esp
  80086b:	e9 f0 fb ff ff       	jmp    800460 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8d 50 04             	lea    0x4(%eax),%edx
  800876:	89 55 14             	mov    %edx,0x14(%ebp)
  800879:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  80087b:	85 f6                	test   %esi,%esi
  80087d:	75 1a                	jne    800899 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	68 0c 19 80 00       	push   $0x80190c
  800887:	68 74 18 80 00       	push   $0x801874
  80088c:	e8 18 f9 ff ff       	call   8001a9 <cprintf>
  800891:	83 c4 10             	add    $0x10,%esp
  800894:	e9 c7 fb ff ff       	jmp    800460 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800899:	0f b6 03             	movzbl (%ebx),%eax
  80089c:	84 c0                	test   %al,%al
  80089e:	79 1f                	jns    8008bf <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	68 44 19 80 00       	push   $0x801944
  8008a8:	68 74 18 80 00       	push   $0x801874
  8008ad:	e8 f7 f8 ff ff       	call   8001a9 <cprintf>
						*tmp = *(char *)putdat;
  8008b2:	0f b6 03             	movzbl (%ebx),%eax
  8008b5:	88 06                	mov    %al,(%esi)
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	e9 a1 fb ff ff       	jmp    800460 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8008bf:	88 06                	mov    %al,(%esi)
  8008c1:	e9 9a fb ff ff       	jmp    800460 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	52                   	push   %edx
  8008cb:	ff d7                	call   *%edi
			break;
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	e9 8b fb ff ff       	jmp    800460 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	53                   	push   %ebx
  8008d9:	6a 25                	push   $0x25
  8008db:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008e4:	0f 84 73 fb ff ff    	je     80045d <vprintfmt+0x11>
  8008ea:	83 ee 01             	sub    $0x1,%esi
  8008ed:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008f1:	75 f7                	jne    8008ea <vprintfmt+0x49e>
  8008f3:	89 75 10             	mov    %esi,0x10(%ebp)
  8008f6:	e9 65 fb ff ff       	jmp    800460 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008fe:	8d 70 01             	lea    0x1(%eax),%esi
  800901:	0f b6 00             	movzbl (%eax),%eax
  800904:	0f be d0             	movsbl %al,%edx
  800907:	85 d2                	test   %edx,%edx
  800909:	0f 85 cf fd ff ff    	jne    8006de <vprintfmt+0x292>
  80090f:	e9 4c fb ff ff       	jmp    800460 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800914:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5f                   	pop    %edi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 18             	sub    $0x18,%esp
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800928:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800932:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800939:	85 c0                	test   %eax,%eax
  80093b:	74 26                	je     800963 <vsnprintf+0x47>
  80093d:	85 d2                	test   %edx,%edx
  80093f:	7e 22                	jle    800963 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800941:	ff 75 14             	pushl  0x14(%ebp)
  800944:	ff 75 10             	pushl  0x10(%ebp)
  800947:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094a:	50                   	push   %eax
  80094b:	68 12 04 80 00       	push   $0x800412
  800950:	e8 f7 fa ff ff       	call   80044c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800955:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800958:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095e:	83 c4 10             	add    $0x10,%esp
  800961:	eb 05                	jmp    800968 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800963:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800970:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800973:	50                   	push   %eax
  800974:	ff 75 10             	pushl  0x10(%ebp)
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	ff 75 08             	pushl  0x8(%ebp)
  80097d:	e8 9a ff ff ff       	call   80091c <vsnprintf>
	va_end(ap);

	return rc;
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80098a:	80 3a 00             	cmpb   $0x0,(%edx)
  80098d:	74 10                	je     80099f <strlen+0x1b>
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800994:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800997:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80099b:	75 f7                	jne    800994 <strlen+0x10>
  80099d:	eb 05                	jmp    8009a4 <strlen+0x20>
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b0:	85 c9                	test   %ecx,%ecx
  8009b2:	74 1c                	je     8009d0 <strnlen+0x2a>
  8009b4:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009b7:	74 1e                	je     8009d7 <strnlen+0x31>
  8009b9:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009be:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c0:	39 ca                	cmp    %ecx,%edx
  8009c2:	74 18                	je     8009dc <strnlen+0x36>
  8009c4:	83 c2 01             	add    $0x1,%edx
  8009c7:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009cc:	75 f0                	jne    8009be <strnlen+0x18>
  8009ce:	eb 0c                	jmp    8009dc <strnlen+0x36>
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d5:	eb 05                	jmp    8009dc <strnlen+0x36>
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e9:	89 c2                	mov    %eax,%edx
  8009eb:	83 c2 01             	add    $0x1,%edx
  8009ee:	83 c1 01             	add    $0x1,%ecx
  8009f1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f8:	84 db                	test   %bl,%bl
  8009fa:	75 ef                	jne    8009eb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a06:	53                   	push   %ebx
  800a07:	e8 78 ff ff ff       	call   800984 <strlen>
  800a0c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	01 d8                	add    %ebx,%eax
  800a14:	50                   	push   %eax
  800a15:	e8 c5 ff ff ff       	call   8009df <strcpy>
	return dst;
}
  800a1a:	89 d8                	mov    %ebx,%eax
  800a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 75 08             	mov    0x8(%ebp),%esi
  800a29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2f:	85 db                	test   %ebx,%ebx
  800a31:	74 17                	je     800a4a <strncpy+0x29>
  800a33:	01 f3                	add    %esi,%ebx
  800a35:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	0f b6 02             	movzbl (%edx),%eax
  800a3d:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a40:	80 3a 01             	cmpb   $0x1,(%edx)
  800a43:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a46:	39 cb                	cmp    %ecx,%ebx
  800a48:	75 ed                	jne    800a37 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a4a:	89 f0                	mov    %esi,%eax
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 75 08             	mov    0x8(%ebp),%esi
  800a58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5b:	8b 55 10             	mov    0x10(%ebp),%edx
  800a5e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a60:	85 d2                	test   %edx,%edx
  800a62:	74 35                	je     800a99 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	83 e8 01             	sub    $0x1,%eax
  800a69:	74 25                	je     800a90 <strlcpy+0x40>
  800a6b:	0f b6 0b             	movzbl (%ebx),%ecx
  800a6e:	84 c9                	test   %cl,%cl
  800a70:	74 22                	je     800a94 <strlcpy+0x44>
  800a72:	8d 53 01             	lea    0x1(%ebx),%edx
  800a75:	01 c3                	add    %eax,%ebx
  800a77:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a7f:	39 da                	cmp    %ebx,%edx
  800a81:	74 13                	je     800a96 <strlcpy+0x46>
  800a83:	83 c2 01             	add    $0x1,%edx
  800a86:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a8a:	84 c9                	test   %cl,%cl
  800a8c:	75 eb                	jne    800a79 <strlcpy+0x29>
  800a8e:	eb 06                	jmp    800a96 <strlcpy+0x46>
  800a90:	89 f0                	mov    %esi,%eax
  800a92:	eb 02                	jmp    800a96 <strlcpy+0x46>
  800a94:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a96:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a99:	29 f0                	sub    %esi,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa8:	0f b6 01             	movzbl (%ecx),%eax
  800aab:	84 c0                	test   %al,%al
  800aad:	74 15                	je     800ac4 <strcmp+0x25>
  800aaf:	3a 02                	cmp    (%edx),%al
  800ab1:	75 11                	jne    800ac4 <strcmp+0x25>
		p++, q++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab9:	0f b6 01             	movzbl (%ecx),%eax
  800abc:	84 c0                	test   %al,%al
  800abe:	74 04                	je     800ac4 <strcmp+0x25>
  800ac0:	3a 02                	cmp    (%edx),%al
  800ac2:	74 ef                	je     800ab3 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac4:	0f b6 c0             	movzbl %al,%eax
  800ac7:	0f b6 12             	movzbl (%edx),%edx
  800aca:	29 d0                	sub    %edx,%eax
}
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad9:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800adc:	85 f6                	test   %esi,%esi
  800ade:	74 29                	je     800b09 <strncmp+0x3b>
  800ae0:	0f b6 03             	movzbl (%ebx),%eax
  800ae3:	84 c0                	test   %al,%al
  800ae5:	74 30                	je     800b17 <strncmp+0x49>
  800ae7:	3a 02                	cmp    (%edx),%al
  800ae9:	75 2c                	jne    800b17 <strncmp+0x49>
  800aeb:	8d 43 01             	lea    0x1(%ebx),%eax
  800aee:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800af0:	89 c3                	mov    %eax,%ebx
  800af2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af5:	39 c6                	cmp    %eax,%esi
  800af7:	74 17                	je     800b10 <strncmp+0x42>
  800af9:	0f b6 08             	movzbl (%eax),%ecx
  800afc:	84 c9                	test   %cl,%cl
  800afe:	74 17                	je     800b17 <strncmp+0x49>
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	3a 0a                	cmp    (%edx),%cl
  800b05:	74 e9                	je     800af0 <strncmp+0x22>
  800b07:	eb 0e                	jmp    800b17 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0e:	eb 0f                	jmp    800b1f <strncmp+0x51>
  800b10:	b8 00 00 00 00       	mov    $0x0,%eax
  800b15:	eb 08                	jmp    800b1f <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b17:	0f b6 03             	movzbl (%ebx),%eax
  800b1a:	0f b6 12             	movzbl (%edx),%edx
  800b1d:	29 d0                	sub    %edx,%eax
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	53                   	push   %ebx
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b2d:	0f b6 10             	movzbl (%eax),%edx
  800b30:	84 d2                	test   %dl,%dl
  800b32:	74 1d                	je     800b51 <strchr+0x2e>
  800b34:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b36:	38 d3                	cmp    %dl,%bl
  800b38:	75 06                	jne    800b40 <strchr+0x1d>
  800b3a:	eb 1a                	jmp    800b56 <strchr+0x33>
  800b3c:	38 ca                	cmp    %cl,%dl
  800b3e:	74 16                	je     800b56 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b40:	83 c0 01             	add    $0x1,%eax
  800b43:	0f b6 10             	movzbl (%eax),%edx
  800b46:	84 d2                	test   %dl,%dl
  800b48:	75 f2                	jne    800b3c <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	eb 05                	jmp    800b56 <strchr+0x33>
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b56:	5b                   	pop    %ebx
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	53                   	push   %ebx
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b63:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b66:	38 d3                	cmp    %dl,%bl
  800b68:	74 14                	je     800b7e <strfind+0x25>
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	84 db                	test   %bl,%bl
  800b6e:	74 0e                	je     800b7e <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b70:	83 c0 01             	add    $0x1,%eax
  800b73:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b76:	38 ca                	cmp    %cl,%dl
  800b78:	74 04                	je     800b7e <strfind+0x25>
  800b7a:	84 d2                	test   %dl,%dl
  800b7c:	75 f2                	jne    800b70 <strfind+0x17>
			break;
	return (char *) s;
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b8d:	85 c9                	test   %ecx,%ecx
  800b8f:	74 36                	je     800bc7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b97:	75 28                	jne    800bc1 <memset+0x40>
  800b99:	f6 c1 03             	test   $0x3,%cl
  800b9c:	75 23                	jne    800bc1 <memset+0x40>
		c &= 0xFF;
  800b9e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	c1 e3 08             	shl    $0x8,%ebx
  800ba7:	89 d6                	mov    %edx,%esi
  800ba9:	c1 e6 18             	shl    $0x18,%esi
  800bac:	89 d0                	mov    %edx,%eax
  800bae:	c1 e0 10             	shl    $0x10,%eax
  800bb1:	09 f0                	or     %esi,%eax
  800bb3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bb5:	89 d8                	mov    %ebx,%eax
  800bb7:	09 d0                	or     %edx,%eax
  800bb9:	c1 e9 02             	shr    $0x2,%ecx
  800bbc:	fc                   	cld    
  800bbd:	f3 ab                	rep stos %eax,%es:(%edi)
  800bbf:	eb 06                	jmp    800bc7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc4:	fc                   	cld    
  800bc5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc7:	89 f8                	mov    %edi,%eax
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bdc:	39 c6                	cmp    %eax,%esi
  800bde:	73 35                	jae    800c15 <memmove+0x47>
  800be0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be3:	39 d0                	cmp    %edx,%eax
  800be5:	73 2e                	jae    800c15 <memmove+0x47>
		s += n;
		d += n;
  800be7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	09 fe                	or     %edi,%esi
  800bee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf4:	75 13                	jne    800c09 <memmove+0x3b>
  800bf6:	f6 c1 03             	test   $0x3,%cl
  800bf9:	75 0e                	jne    800c09 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bfb:	83 ef 04             	sub    $0x4,%edi
  800bfe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c01:	c1 e9 02             	shr    $0x2,%ecx
  800c04:	fd                   	std    
  800c05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c07:	eb 09                	jmp    800c12 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c09:	83 ef 01             	sub    $0x1,%edi
  800c0c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c0f:	fd                   	std    
  800c10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c12:	fc                   	cld    
  800c13:	eb 1d                	jmp    800c32 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c15:	89 f2                	mov    %esi,%edx
  800c17:	09 c2                	or     %eax,%edx
  800c19:	f6 c2 03             	test   $0x3,%dl
  800c1c:	75 0f                	jne    800c2d <memmove+0x5f>
  800c1e:	f6 c1 03             	test   $0x3,%cl
  800c21:	75 0a                	jne    800c2d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c23:	c1 e9 02             	shr    $0x2,%ecx
  800c26:	89 c7                	mov    %eax,%edi
  800c28:	fc                   	cld    
  800c29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2b:	eb 05                	jmp    800c32 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c2d:	89 c7                	mov    %eax,%edi
  800c2f:	fc                   	cld    
  800c30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c39:	ff 75 10             	pushl  0x10(%ebp)
  800c3c:	ff 75 0c             	pushl  0xc(%ebp)
  800c3f:	ff 75 08             	pushl  0x8(%ebp)
  800c42:	e8 87 ff ff ff       	call   800bce <memmove>
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c55:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	74 39                	je     800c95 <memcmp+0x4c>
  800c5c:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c5f:	0f b6 13             	movzbl (%ebx),%edx
  800c62:	0f b6 0e             	movzbl (%esi),%ecx
  800c65:	38 ca                	cmp    %cl,%dl
  800c67:	75 17                	jne    800c80 <memcmp+0x37>
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6e:	eb 1a                	jmp    800c8a <memcmp+0x41>
  800c70:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c75:	83 c0 01             	add    $0x1,%eax
  800c78:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c7c:	38 ca                	cmp    %cl,%dl
  800c7e:	74 0a                	je     800c8a <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c80:	0f b6 c2             	movzbl %dl,%eax
  800c83:	0f b6 c9             	movzbl %cl,%ecx
  800c86:	29 c8                	sub    %ecx,%eax
  800c88:	eb 10                	jmp    800c9a <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8a:	39 f8                	cmp    %edi,%eax
  800c8c:	75 e2                	jne    800c70 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c93:	eb 05                	jmp    800c9a <memcmp+0x51>
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	53                   	push   %ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800ca6:	89 d0                	mov    %edx,%eax
  800ca8:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800cab:	39 c2                	cmp    %eax,%edx
  800cad:	73 1d                	jae    800ccc <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800caf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800cb3:	0f b6 0a             	movzbl (%edx),%ecx
  800cb6:	39 d9                	cmp    %ebx,%ecx
  800cb8:	75 09                	jne    800cc3 <memfind+0x24>
  800cba:	eb 14                	jmp    800cd0 <memfind+0x31>
  800cbc:	0f b6 0a             	movzbl (%edx),%ecx
  800cbf:	39 d9                	cmp    %ebx,%ecx
  800cc1:	74 11                	je     800cd4 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc3:	83 c2 01             	add    $0x1,%edx
  800cc6:	39 d0                	cmp    %edx,%eax
  800cc8:	75 f2                	jne    800cbc <memfind+0x1d>
  800cca:	eb 0a                	jmp    800cd6 <memfind+0x37>
  800ccc:	89 d0                	mov    %edx,%eax
  800cce:	eb 06                	jmp    800cd6 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd0:	89 d0                	mov    %edx,%eax
  800cd2:	eb 02                	jmp    800cd6 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd4:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce5:	0f b6 01             	movzbl (%ecx),%eax
  800ce8:	3c 20                	cmp    $0x20,%al
  800cea:	74 04                	je     800cf0 <strtol+0x17>
  800cec:	3c 09                	cmp    $0x9,%al
  800cee:	75 0e                	jne    800cfe <strtol+0x25>
		s++;
  800cf0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf3:	0f b6 01             	movzbl (%ecx),%eax
  800cf6:	3c 20                	cmp    $0x20,%al
  800cf8:	74 f6                	je     800cf0 <strtol+0x17>
  800cfa:	3c 09                	cmp    $0x9,%al
  800cfc:	74 f2                	je     800cf0 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cfe:	3c 2b                	cmp    $0x2b,%al
  800d00:	75 0a                	jne    800d0c <strtol+0x33>
		s++;
  800d02:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d05:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0a:	eb 11                	jmp    800d1d <strtol+0x44>
  800d0c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d11:	3c 2d                	cmp    $0x2d,%al
  800d13:	75 08                	jne    800d1d <strtol+0x44>
		s++, neg = 1;
  800d15:	83 c1 01             	add    $0x1,%ecx
  800d18:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d23:	75 15                	jne    800d3a <strtol+0x61>
  800d25:	80 39 30             	cmpb   $0x30,(%ecx)
  800d28:	75 10                	jne    800d3a <strtol+0x61>
  800d2a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d2e:	75 7c                	jne    800dac <strtol+0xd3>
		s += 2, base = 16;
  800d30:	83 c1 02             	add    $0x2,%ecx
  800d33:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d38:	eb 16                	jmp    800d50 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d3a:	85 db                	test   %ebx,%ebx
  800d3c:	75 12                	jne    800d50 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d3e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d43:	80 39 30             	cmpb   $0x30,(%ecx)
  800d46:	75 08                	jne    800d50 <strtol+0x77>
		s++, base = 8;
  800d48:	83 c1 01             	add    $0x1,%ecx
  800d4b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d50:	b8 00 00 00 00       	mov    $0x0,%eax
  800d55:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d58:	0f b6 11             	movzbl (%ecx),%edx
  800d5b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d5e:	89 f3                	mov    %esi,%ebx
  800d60:	80 fb 09             	cmp    $0x9,%bl
  800d63:	77 08                	ja     800d6d <strtol+0x94>
			dig = *s - '0';
  800d65:	0f be d2             	movsbl %dl,%edx
  800d68:	83 ea 30             	sub    $0x30,%edx
  800d6b:	eb 22                	jmp    800d8f <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d6d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d70:	89 f3                	mov    %esi,%ebx
  800d72:	80 fb 19             	cmp    $0x19,%bl
  800d75:	77 08                	ja     800d7f <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d77:	0f be d2             	movsbl %dl,%edx
  800d7a:	83 ea 57             	sub    $0x57,%edx
  800d7d:	eb 10                	jmp    800d8f <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d7f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d82:	89 f3                	mov    %esi,%ebx
  800d84:	80 fb 19             	cmp    $0x19,%bl
  800d87:	77 16                	ja     800d9f <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d89:	0f be d2             	movsbl %dl,%edx
  800d8c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d8f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d92:	7d 0b                	jge    800d9f <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d94:	83 c1 01             	add    $0x1,%ecx
  800d97:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d9d:	eb b9                	jmp    800d58 <strtol+0x7f>

	if (endptr)
  800d9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da3:	74 0d                	je     800db2 <strtol+0xd9>
		*endptr = (char *) s;
  800da5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da8:	89 0e                	mov    %ecx,(%esi)
  800daa:	eb 06                	jmp    800db2 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dac:	85 db                	test   %ebx,%ebx
  800dae:	74 98                	je     800d48 <strtol+0x6f>
  800db0:	eb 9e                	jmp    800d50 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800db2:	89 c2                	mov    %eax,%edx
  800db4:	f7 da                	neg    %edx
  800db6:	85 ff                	test   %edi,%edi
  800db8:	0f 45 c2             	cmovne %edx,%eax
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 c3                	mov    %eax,%ebx
  800dd2:	89 c7                	mov    %eax,%edi
  800dd4:	51                   	push   %ecx
  800dd5:	52                   	push   %edx
  800dd6:	53                   	push   %ebx
  800dd7:	56                   	push   %esi
  800dd8:	57                   	push   %edi
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	8d 35 e4 0d 80 00    	lea    0x800de4,%esi
  800de2:	0f 34                	sysenter 

00800de4 <label_21>:
  800de4:	89 ec                	mov    %ebp,%esp
  800de6:	5d                   	pop    %ebp
  800de7:	5f                   	pop    %edi
  800de8:	5e                   	pop    %esi
  800de9:	5b                   	pop    %ebx
  800dea:	5a                   	pop    %edx
  800deb:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800df5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800dff:	89 ca                	mov    %ecx,%edx
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	51                   	push   %ecx
  800e06:	52                   	push   %edx
  800e07:	53                   	push   %ebx
  800e08:	56                   	push   %esi
  800e09:	57                   	push   %edi
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	8d 35 15 0e 80 00    	lea    0x800e15,%esi
  800e13:	0f 34                	sysenter 

00800e15 <label_55>:
  800e15:	89 ec                	mov    %ebp,%esp
  800e17:	5d                   	pop    %ebp
  800e18:	5f                   	pop    %edi
  800e19:	5e                   	pop    %esi
  800e1a:	5b                   	pop    %ebx
  800e1b:	5a                   	pop    %edx
  800e1c:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e1d:	5b                   	pop    %ebx
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	89 d9                	mov    %ebx,%ecx
  800e35:	89 df                	mov    %ebx,%edi
  800e37:	51                   	push   %ecx
  800e38:	52                   	push   %edx
  800e39:	53                   	push   %ebx
  800e3a:	56                   	push   %esi
  800e3b:	57                   	push   %edi
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	8d 35 47 0e 80 00    	lea    0x800e47,%esi
  800e45:	0f 34                	sysenter 

00800e47 <label_90>:
  800e47:	89 ec                	mov    %ebp,%esp
  800e49:	5d                   	pop    %ebp
  800e4a:	5f                   	pop    %edi
  800e4b:	5e                   	pop    %esi
  800e4c:	5b                   	pop    %ebx
  800e4d:	5a                   	pop    %edx
  800e4e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 17                	jle    800e6a <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 03                	push   $0x3
  800e59:	68 24 1b 80 00       	push   $0x801b24
  800e5e:	6a 30                	push   $0x30
  800e60:	68 41 1b 80 00       	push   $0x801b41
  800e65:	e8 4a 06 00 00       	call   8014b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e80:	89 ca                	mov    %ecx,%edx
  800e82:	89 cb                	mov    %ecx,%ebx
  800e84:	89 cf                	mov    %ecx,%edi
  800e86:	51                   	push   %ecx
  800e87:	52                   	push   %edx
  800e88:	53                   	push   %ebx
  800e89:	56                   	push   %esi
  800e8a:	57                   	push   %edi
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	8d 35 96 0e 80 00    	lea    0x800e96,%esi
  800e94:	0f 34                	sysenter 

00800e96 <label_139>:
  800e96:	89 ec                	mov    %ebp,%esp
  800e98:	5d                   	pop    %ebp
  800e99:	5f                   	pop    %edi
  800e9a:	5e                   	pop    %esi
  800e9b:	5b                   	pop    %ebx
  800e9c:	5a                   	pop    %edx
  800e9d:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ea7:	bf 00 00 00 00       	mov    $0x0,%edi
  800eac:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	89 fb                	mov    %edi,%ebx
  800eb9:	51                   	push   %ecx
  800eba:	52                   	push   %edx
  800ebb:	53                   	push   %ebx
  800ebc:	56                   	push   %esi
  800ebd:	57                   	push   %edi
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	8d 35 c9 0e 80 00    	lea    0x800ec9,%esi
  800ec7:	0f 34                	sysenter 

00800ec9 <label_174>:
  800ec9:	89 ec                	mov    %ebp,%esp
  800ecb:	5d                   	pop    %ebp
  800ecc:	5f                   	pop    %edi
  800ecd:	5e                   	pop    %esi
  800ece:	5b                   	pop    %ebx
  800ecf:	5a                   	pop    %edx
  800ed0:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_yield>:

void
sys_yield(void)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eda:	ba 00 00 00 00       	mov    $0x0,%edx
  800edf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ee4:	89 d1                	mov    %edx,%ecx
  800ee6:	89 d3                	mov    %edx,%ebx
  800ee8:	89 d7                	mov    %edx,%edi
  800eea:	51                   	push   %ecx
  800eeb:	52                   	push   %edx
  800eec:	53                   	push   %ebx
  800eed:	56                   	push   %esi
  800eee:	57                   	push   %edi
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	8d 35 fa 0e 80 00    	lea    0x800efa,%esi
  800ef8:	0f 34                	sysenter 

00800efa <label_209>:
  800efa:	89 ec                	mov    %ebp,%esp
  800efc:	5d                   	pop    %ebp
  800efd:	5f                   	pop    %edi
  800efe:	5e                   	pop    %esi
  800eff:	5b                   	pop    %ebx
  800f00:	5a                   	pop    %edx
  800f01:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f02:	5b                   	pop    %ebx
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f0b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f10:	b8 05 00 00 00       	mov    $0x5,%eax
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1e:	51                   	push   %ecx
  800f1f:	52                   	push   %edx
  800f20:	53                   	push   %ebx
  800f21:	56                   	push   %esi
  800f22:	57                   	push   %edi
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	8d 35 2e 0f 80 00    	lea    0x800f2e,%esi
  800f2c:	0f 34                	sysenter 

00800f2e <label_244>:
  800f2e:	89 ec                	mov    %ebp,%esp
  800f30:	5d                   	pop    %ebp
  800f31:	5f                   	pop    %edi
  800f32:	5e                   	pop    %esi
  800f33:	5b                   	pop    %ebx
  800f34:	5a                   	pop    %edx
  800f35:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f36:	85 c0                	test   %eax,%eax
  800f38:	7e 17                	jle    800f51 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	50                   	push   %eax
  800f3e:	6a 05                	push   $0x5
  800f40:	68 24 1b 80 00       	push   $0x801b24
  800f45:	6a 30                	push   $0x30
  800f47:	68 41 1b 80 00       	push   $0x801b41
  800f4c:	e8 63 05 00 00       	call   8014b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800f60:	8b 45 08             	mov    0x8(%ebp),%eax
  800f63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f69:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800f6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800f72:	8b 45 14             	mov    0x14(%ebp),%eax
  800f75:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800f78:	8b 45 18             	mov    0x18(%ebp),%eax
  800f7b:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f7e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f86:	b8 06 00 00 00       	mov    $0x6,%eax
  800f8b:	89 cb                	mov    %ecx,%ebx
  800f8d:	89 cf                	mov    %ecx,%edi
  800f8f:	51                   	push   %ecx
  800f90:	52                   	push   %edx
  800f91:	53                   	push   %ebx
  800f92:	56                   	push   %esi
  800f93:	57                   	push   %edi
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	8d 35 9f 0f 80 00    	lea    0x800f9f,%esi
  800f9d:	0f 34                	sysenter 

00800f9f <label_304>:
  800f9f:	89 ec                	mov    %ebp,%esp
  800fa1:	5d                   	pop    %ebp
  800fa2:	5f                   	pop    %edi
  800fa3:	5e                   	pop    %esi
  800fa4:	5b                   	pop    %ebx
  800fa5:	5a                   	pop    %edx
  800fa6:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 06                	push   $0x6
  800fb1:	68 24 1b 80 00       	push   $0x801b24
  800fb6:	6a 30                	push   $0x30
  800fb8:	68 41 1b 80 00       	push   $0x801b41
  800fbd:	e8 f2 04 00 00       	call   8014b4 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  800fc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fce:	bf 00 00 00 00       	mov    $0x0,%edi
  800fd3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fde:	89 fb                	mov    %edi,%ebx
  800fe0:	51                   	push   %ecx
  800fe1:	52                   	push   %edx
  800fe2:	53                   	push   %ebx
  800fe3:	56                   	push   %esi
  800fe4:	57                   	push   %edi
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	8d 35 f0 0f 80 00    	lea    0x800ff0,%esi
  800fee:	0f 34                	sysenter 

00800ff0 <label_353>:
  800ff0:	89 ec                	mov    %ebp,%esp
  800ff2:	5d                   	pop    %ebp
  800ff3:	5f                   	pop    %edi
  800ff4:	5e                   	pop    %esi
  800ff5:	5b                   	pop    %ebx
  800ff6:	5a                   	pop    %edx
  800ff7:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	7e 17                	jle    801013 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	50                   	push   %eax
  801000:	6a 07                	push   $0x7
  801002:	68 24 1b 80 00       	push   $0x801b24
  801007:	6a 30                	push   $0x30
  801009:	68 41 1b 80 00       	push   $0x801b41
  80100e:	e8 a1 04 00 00       	call   8014b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801013:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801016:	5b                   	pop    %ebx
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80101f:	bf 00 00 00 00       	mov    $0x0,%edi
  801024:	b8 09 00 00 00       	mov    $0x9,%eax
  801029:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102c:	8b 55 08             	mov    0x8(%ebp),%edx
  80102f:	89 fb                	mov    %edi,%ebx
  801031:	51                   	push   %ecx
  801032:	52                   	push   %edx
  801033:	53                   	push   %ebx
  801034:	56                   	push   %esi
  801035:	57                   	push   %edi
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	8d 35 41 10 80 00    	lea    0x801041,%esi
  80103f:	0f 34                	sysenter 

00801041 <label_402>:
  801041:	89 ec                	mov    %ebp,%esp
  801043:	5d                   	pop    %ebp
  801044:	5f                   	pop    %edi
  801045:	5e                   	pop    %esi
  801046:	5b                   	pop    %ebx
  801047:	5a                   	pop    %edx
  801048:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	7e 17                	jle    801064 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	50                   	push   %eax
  801051:	6a 09                	push   $0x9
  801053:	68 24 1b 80 00       	push   $0x801b24
  801058:	6a 30                	push   $0x30
  80105a:	68 41 1b 80 00       	push   $0x801b41
  80105f:	e8 50 04 00 00       	call   8014b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801064:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801067:	5b                   	pop    %ebx
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801070:	bf 00 00 00 00       	mov    $0x0,%edi
  801075:	b8 0a 00 00 00       	mov    $0xa,%eax
  80107a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107d:	8b 55 08             	mov    0x8(%ebp),%edx
  801080:	89 fb                	mov    %edi,%ebx
  801082:	51                   	push   %ecx
  801083:	52                   	push   %edx
  801084:	53                   	push   %ebx
  801085:	56                   	push   %esi
  801086:	57                   	push   %edi
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	8d 35 92 10 80 00    	lea    0x801092,%esi
  801090:	0f 34                	sysenter 

00801092 <label_451>:
  801092:	89 ec                	mov    %ebp,%esp
  801094:	5d                   	pop    %ebp
  801095:	5f                   	pop    %edi
  801096:	5e                   	pop    %esi
  801097:	5b                   	pop    %ebx
  801098:	5a                   	pop    %edx
  801099:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80109a:	85 c0                	test   %eax,%eax
  80109c:	7e 17                	jle    8010b5 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	50                   	push   %eax
  8010a2:	6a 0a                	push   $0xa
  8010a4:	68 24 1b 80 00       	push   $0x801b24
  8010a9:	6a 30                	push   $0x30
  8010ab:	68 41 1b 80 00       	push   $0x801b41
  8010b0:	e8 ff 03 00 00       	call   8014b4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	57                   	push   %edi
  8010c0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010c1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010cf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d2:	51                   	push   %ecx
  8010d3:	52                   	push   %edx
  8010d4:	53                   	push   %ebx
  8010d5:	56                   	push   %esi
  8010d6:	57                   	push   %edi
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	8d 35 e2 10 80 00    	lea    0x8010e2,%esi
  8010e0:	0f 34                	sysenter 

008010e2 <label_502>:
  8010e2:	89 ec                	mov    %ebp,%esp
  8010e4:	5d                   	pop    %ebp
  8010e5:	5f                   	pop    %edi
  8010e6:	5e                   	pop    %esi
  8010e7:	5b                   	pop    %ebx
  8010e8:	5a                   	pop    %edx
  8010e9:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010ea:	5b                   	pop    %ebx
  8010eb:	5f                   	pop    %edi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	57                   	push   %edi
  8010f2:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801100:	89 d9                	mov    %ebx,%ecx
  801102:	89 df                	mov    %ebx,%edi
  801104:	51                   	push   %ecx
  801105:	52                   	push   %edx
  801106:	53                   	push   %ebx
  801107:	56                   	push   %esi
  801108:	57                   	push   %edi
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	8d 35 14 11 80 00    	lea    0x801114,%esi
  801112:	0f 34                	sysenter 

00801114 <label_537>:
  801114:	89 ec                	mov    %ebp,%esp
  801116:	5d                   	pop    %ebp
  801117:	5f                   	pop    %edi
  801118:	5e                   	pop    %esi
  801119:	5b                   	pop    %ebx
  80111a:	5a                   	pop    %edx
  80111b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80111c:	85 c0                	test   %eax,%eax
  80111e:	7e 17                	jle    801137 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	50                   	push   %eax
  801124:	6a 0d                	push   $0xd
  801126:	68 24 1b 80 00       	push   $0x801b24
  80112b:	6a 30                	push   $0x30
  80112d:	68 41 1b 80 00       	push   $0x801b41
  801132:	e8 7d 03 00 00       	call   8014b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80113a:	5b                   	pop    %ebx
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801143:	b9 00 00 00 00       	mov    $0x0,%ecx
  801148:	b8 0e 00 00 00       	mov    $0xe,%eax
  80114d:	8b 55 08             	mov    0x8(%ebp),%edx
  801150:	89 cb                	mov    %ecx,%ebx
  801152:	89 cf                	mov    %ecx,%edi
  801154:	51                   	push   %ecx
  801155:	52                   	push   %edx
  801156:	53                   	push   %ebx
  801157:	56                   	push   %esi
  801158:	57                   	push   %edi
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	8d 35 64 11 80 00    	lea    0x801164,%esi
  801162:	0f 34                	sysenter 

00801164 <label_586>:
  801164:	89 ec                	mov    %ebp,%esp
  801166:	5d                   	pop    %ebp
  801167:	5f                   	pop    %edi
  801168:	5e                   	pop    %esi
  801169:	5b                   	pop    %ebx
  80116a:	5a                   	pop    %edx
  80116b:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80116c:	5b                   	pop    %ebx
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	53                   	push   %ebx
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80117a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(vpd[PDX(addr)] & PTE_P) || !(vpt[PGNUM(addr)] & PTE_COW)) {
  80117c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801180:	74 21                	je     8011a3 <pgfault+0x33>
  801182:	89 d8                	mov    %ebx,%eax
  801184:	c1 e8 16             	shr    $0x16,%eax
  801187:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80118e:	a8 01                	test   $0x1,%al
  801190:	74 11                	je     8011a3 <pgfault+0x33>
  801192:	89 d8                	mov    %ebx,%eax
  801194:	c1 e8 0c             	shr    $0xc,%eax
  801197:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80119e:	f6 c4 08             	test   $0x8,%ah
  8011a1:	75 14                	jne    8011b7 <pgfault+0x47>
		panic("Faulting access is not a write to COW page.");
  8011a3:	83 ec 04             	sub    $0x4,%esp
  8011a6:	68 50 1b 80 00       	push   $0x801b50
  8011ab:	6a 1d                	push   $0x1d
  8011ad:	68 5a 1c 80 00       	push   $0x801c5a
  8011b2:	e8 fd 02 00 00       	call   8014b4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_U | PTE_W | PTE_P);
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	6a 07                	push   $0x7
  8011bc:	68 00 f0 7f 00       	push   $0x7ff000
  8011c1:	6a 00                	push   $0x0
  8011c3:	e8 3e fd ff ff       	call   800f06 <sys_page_alloc>
	if (r) {
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	74 12                	je     8011e1 <pgfault+0x71>
		panic("pgfault alloc new page failed %e", r);
  8011cf:	50                   	push   %eax
  8011d0:	68 7c 1b 80 00       	push   $0x801b7c
  8011d5:	6a 2a                	push   $0x2a
  8011d7:	68 5a 1c 80 00       	push   $0x801c5a
  8011dc:	e8 d3 02 00 00       	call   8014b4 <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8011e1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	68 00 10 00 00       	push   $0x1000
  8011ef:	53                   	push   %ebx
  8011f0:	68 00 f0 7f 00       	push   $0x7ff000
  8011f5:	e8 d4 f9 ff ff       	call   800bce <memmove>
	r = sys_page_map(0, (void *)PFTEMP,
  8011fa:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801201:	53                   	push   %ebx
  801202:	6a 00                	push   $0x0
  801204:	68 00 f0 7f 00       	push   $0x7ff000
  801209:	6a 00                	push   $0x0
  80120b:	e8 48 fd ff ff       	call   800f58 <sys_page_map>
				0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_W | PTE_P);
	if (r) {
  801210:	83 c4 20             	add    $0x20,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	74 12                	je     801229 <pgfault+0xb9>
		panic("pgfault map pages failed %e", r);
  801217:	50                   	push   %eax
  801218:	68 65 1c 80 00       	push   $0x801c65
  80121d:	6a 30                	push   $0x30
  80121f:	68 5a 1c 80 00       	push   $0x801c5a
  801224:	e8 8b 02 00 00       	call   8014b4 <_panic>
	}
	// panic("pgfault not implemented");
}
  801229:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801237:	68 70 11 80 00       	push   $0x801170
  80123c:	e8 d3 02 00 00       	call   801514 <set_pgfault_handler>
	// 	: "a" (SYS_exofork),
	// 	  "i" (T_SYSCALL)
	// );
	// return ret;
	envid_t ret;
	asm volatile("pushl %%ecx\n\t"
  801241:	b8 08 00 00 00       	mov    $0x8,%eax
  801246:	51                   	push   %ecx
  801247:	52                   	push   %edx
  801248:	53                   	push   %ebx
  801249:	56                   	push   %esi
  80124a:	57                   	push   %edi
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	8d 35 56 12 80 00    	lea    0x801256,%esi
  801254:	0f 34                	sysenter 

00801256 <label_116>:
  801256:	89 ec                	mov    %ebp,%esp
  801258:	5d                   	pop    %ebp
  801259:	5f                   	pop    %edi
  80125a:	5e                   	pop    %esi
  80125b:	5b                   	pop    %ebx
  80125c:	5a                   	pop    %edx
  80125d:	59                   	pop    %ecx
  80125e:	89 c7                	mov    %eax,%edi
  801260:	89 45 e4             	mov    %eax,-0x1c(%ebp)
							: "=a" (ret)
							: "a" (SYS_exofork),
								"i" (T_SYSCALL)
							: "cc", "memory");

	if(ret == -E_NO_FREE_ENV || ret == -E_NO_MEM)
  801263:	8d 40 05             	lea    0x5(%eax),%eax
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	83 f8 01             	cmp    $0x1,%eax
  80126c:	77 17                	ja     801285 <label_116+0x2f>
		panic("syscall %d returned %d (> 0)", SYS_exofork, ret);
  80126e:	83 ec 0c             	sub    $0xc,%esp
  801271:	57                   	push   %edi
  801272:	6a 08                	push   $0x8
  801274:	68 24 1b 80 00       	push   $0x801b24
  801279:	6a 62                	push   $0x62
  80127b:	68 81 1c 80 00       	push   $0x801c81
  801280:	e8 2f 02 00 00       	call   8014b4 <_panic>

	int r;
	envid_t child_id;
	child_id = sys_exofork();
	if (child_id < 0) {
  801285:	85 ff                	test   %edi,%edi
  801287:	0f 88 83 01 00 00    	js     801410 <label_116+0x1ba>
  80128d:	bb 00 08 00 00       	mov    $0x800,%ebx
		return -1;
	} else if (!child_id) {
  801292:	85 ff                	test   %edi,%edi
  801294:	75 21                	jne    8012b7 <label_116+0x61>
		thisenv = &envs[ENVX(sys_getenvid())];
  801296:	e8 d6 fb ff ff       	call   800e71 <sys_getenvid>
  80129b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012a0:	c1 e0 07             	shl    $0x7,%eax
  8012a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a8:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b2:	e9 62 01 00 00       	jmp    801419 <label_116+0x1c3>
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
			if ((vpd[pn / NPTENTRIES] & PTE_P) &&
  8012b7:	89 d8                	mov    %ebx,%eax
  8012b9:	c1 e8 0a             	shr    $0xa,%eax
  8012bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c3:	a8 01                	test   $0x1,%al
  8012c5:	0f 84 b9 00 00 00    	je     801384 <label_116+0x12e>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
  8012cb:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
			if ((vpd[pn / NPTENTRIES] & PTE_P) &&
  8012d2:	a8 01                	test   $0x1,%al
  8012d4:	0f 84 aa 00 00 00    	je     801384 <label_116+0x12e>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
  8012da:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8012e1:	a8 04                	test   $0x4,%al
  8012e3:	0f 84 9b 00 00 00    	je     801384 <label_116+0x12e>
  8012e9:	89 de                	mov    %ebx,%esi
  8012eb:	c1 e6 0c             	shl    $0xc,%esi
	int r;

	// LAB 4: Your code here.
	int perm = PTE_U | PTE_P;
	void *pn_addr = (void *)(pn * PGSIZE);
	pte_t pte = vpt[PGNUM(pn_addr)];
  8012ee:	89 f0                	mov    %esi,%eax
  8012f0:	c1 e8 0c             	shr    $0xc,%eax
  8012f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((pte & PTE_COW) || (pte & PTE_W)) {
  8012fa:	a9 02 08 00 00       	test   $0x802,%eax
  8012ff:	74 59                	je     80135a <label_116+0x104>
		perm |= PTE_COW;
		r = sys_page_map(0, pn_addr, envid, pn_addr, perm);
  801301:	83 ec 0c             	sub    $0xc,%esp
  801304:	68 05 08 00 00       	push   $0x805
  801309:	56                   	push   %esi
  80130a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80130d:	56                   	push   %esi
  80130e:	6a 00                	push   $0x0
  801310:	e8 43 fc ff ff       	call   800f58 <sys_page_map>
		if (r) {
  801315:	83 c4 20             	add    $0x20,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	74 12                	je     80132e <label_116+0xd8>
			panic("duppage sys_page_map 1/2 failed %e", r);
  80131c:	50                   	push   %eax
  80131d:	68 a0 1b 80 00       	push   $0x801ba0
  801322:	6a 4d                	push   $0x4d
  801324:	68 5a 1c 80 00       	push   $0x801c5a
  801329:	e8 86 01 00 00       	call   8014b4 <_panic>
		}
		// TODO: Still don't know why
		r = sys_page_map(0, pn_addr, 0, pn_addr, perm);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	68 05 08 00 00       	push   $0x805
  801336:	56                   	push   %esi
  801337:	6a 00                	push   $0x0
  801339:	56                   	push   %esi
  80133a:	6a 00                	push   $0x0
  80133c:	e8 17 fc ff ff       	call   800f58 <sys_page_map>
		if (r) {
  801341:	83 c4 20             	add    $0x20,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	74 3c                	je     801384 <label_116+0x12e>
			panic("duppage sys_page_map 2/2 failed %e", r);
  801348:	50                   	push   %eax
  801349:	68 c4 1b 80 00       	push   $0x801bc4
  80134e:	6a 52                	push   $0x52
  801350:	68 5a 1c 80 00       	push   $0x801c5a
  801355:	e8 5a 01 00 00       	call   8014b4 <_panic>
		}
	} else {
		r = sys_page_map(0, pn_addr, envid, pn_addr, perm);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	6a 05                	push   $0x5
  80135f:	56                   	push   %esi
  801360:	ff 75 e4             	pushl  -0x1c(%ebp)
  801363:	56                   	push   %esi
  801364:	6a 00                	push   $0x0
  801366:	e8 ed fb ff ff       	call   800f58 <sys_page_map>
		if (r) {
  80136b:	83 c4 20             	add    $0x20,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	74 12                	je     801384 <label_116+0x12e>
			panic("duppage sys_page_map 1/1 failed %e", r);
  801372:	50                   	push   %eax
  801373:	68 e8 1b 80 00       	push   $0x801be8
  801378:	6a 57                	push   $0x57
  80137a:	68 5a 1c 80 00       	push   $0x801c5a
  80137f:	e8 30 01 00 00       	call   8014b4 <_panic>
	} else {
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
  801384:	83 c3 01             	add    $0x1,%ebx
  801387:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80138d:	0f 85 24 ff ff ff    	jne    8012b7 <label_116+0x61>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
				duppage(child_id, pn);
			}
		}

		r = sys_page_alloc(child_id, (void *)(UTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	6a 07                	push   $0x7
  801398:	68 00 f0 bf ee       	push   $0xeebff000
  80139d:	57                   	push   %edi
  80139e:	e8 63 fb ff ff       	call   800f06 <sys_page_alloc>
		if (r) {
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	74 15                	je     8013bf <label_116+0x169>
			panic("fork sys_page_alloc failed %e", r);
  8013aa:	50                   	push   %eax
  8013ab:	68 8d 1c 80 00       	push   $0x801c8d
  8013b0:	68 8a 00 00 00       	push   $0x8a
  8013b5:	68 5a 1c 80 00       	push   $0x801c5a
  8013ba:	e8 f5 00 00 00       	call   8014b4 <_panic>
		}

		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	68 69 15 80 00       	push   $0x801569
  8013c7:	57                   	push   %edi
  8013c8:	e8 9e fc ff ff       	call   80106b <sys_env_set_pgfault_upcall>
		if (r) {
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	74 15                	je     8013e9 <label_116+0x193>
			panic("fork sys_env_set_pgfault_upcall failed %e", r);
  8013d4:	50                   	push   %eax
  8013d5:	68 0c 1c 80 00       	push   $0x801c0c
  8013da:	68 90 00 00 00       	push   $0x90
  8013df:	68 5a 1c 80 00       	push   $0x801c5a
  8013e4:	e8 cb 00 00 00       	call   8014b4 <_panic>
		}

		r = sys_env_set_status(child_id, ENV_RUNNABLE);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	6a 02                	push   $0x2
  8013ee:	57                   	push   %edi
  8013ef:	e8 26 fc ff ff       	call   80101a <sys_env_set_status>
		if (r) {
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	74 1c                	je     801417 <label_116+0x1c1>
			panic("fork sys_env_set_status failed %e", r);
  8013fb:	50                   	push   %eax
  8013fc:	68 38 1c 80 00       	push   $0x801c38
  801401:	68 95 00 00 00       	push   $0x95
  801406:	68 5a 1c 80 00       	push   $0x801c5a
  80140b:	e8 a4 00 00 00       	call   8014b4 <_panic>

	int r;
	envid_t child_id;
	child_id = sys_exofork();
	if (child_id < 0) {
		return -1;
  801410:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801415:	eb 02                	jmp    801419 <label_116+0x1c3>

		r = sys_env_set_status(child_id, ENV_RUNNABLE);
		if (r) {
			panic("fork sys_env_set_status failed %e", r);
		}
		return child_id;
  801417:	89 f8                	mov    %edi,%eax
	}
	// panic("fork not implemented");
}
  801419:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5e                   	pop    %esi
  80141e:	5f                   	pop    %edi
  80141f:	5d                   	pop    %ebp
  801420:	c3                   	ret    

00801421 <sfork>:

// Challenge!
int
sfork(void)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801427:	68 ab 1c 80 00       	push   $0x801cab
  80142c:	68 a0 00 00 00       	push   $0xa0
  801431:	68 5a 1c 80 00       	push   $0x801c5a
  801436:	e8 79 00 00 00       	call   8014b4 <_panic>

0080143b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801441:	68 c1 1c 80 00       	push   $0x801cc1
  801446:	6a 1a                	push   $0x1a
  801448:	68 da 1c 80 00       	push   $0x801cda
  80144d:	e8 62 00 00 00       	call   8014b4 <_panic>

00801452 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801458:	68 e4 1c 80 00       	push   $0x801ce4
  80145d:	6a 2a                	push   $0x2a
  80145f:	68 da 1c 80 00       	push   $0x801cda
  801464:	e8 4b 00 00 00       	call   8014b4 <_panic>

00801469 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80146f:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801474:	39 c1                	cmp    %eax,%ecx
  801476:	74 19                	je     801491 <ipc_find_env+0x28>
  801478:	b8 01 00 00 00       	mov    $0x1,%eax
  80147d:	89 c2                	mov    %eax,%edx
  80147f:	c1 e2 07             	shl    $0x7,%edx
  801482:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801488:	8b 52 50             	mov    0x50(%edx),%edx
  80148b:	39 ca                	cmp    %ecx,%edx
  80148d:	75 14                	jne    8014a3 <ipc_find_env+0x3a>
  80148f:	eb 05                	jmp    801496 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801491:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801496:	c1 e0 07             	shl    $0x7,%eax
  801499:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80149e:	8b 40 48             	mov    0x48(%eax),%eax
  8014a1:	eb 0f                	jmp    8014b2 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014a3:	83 c0 01             	add    $0x1,%eax
  8014a6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014ab:	75 d0                	jne    80147d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	56                   	push   %esi
  8014b8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014b9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8014bc:	a1 10 20 80 00       	mov    0x802010,%eax
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	74 11                	je     8014d6 <_panic+0x22>
		cprintf("%s: ", argv0);
  8014c5:	83 ec 08             	sub    $0x8,%esp
  8014c8:	50                   	push   %eax
  8014c9:	68 fd 1c 80 00       	push   $0x801cfd
  8014ce:	e8 d6 ec ff ff       	call   8001a9 <cprintf>
  8014d3:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014d6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8014dc:	e8 90 f9 ff ff       	call   800e71 <sys_getenvid>
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	ff 75 0c             	pushl  0xc(%ebp)
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	56                   	push   %esi
  8014eb:	50                   	push   %eax
  8014ec:	68 04 1d 80 00       	push   $0x801d04
  8014f1:	e8 b3 ec ff ff       	call   8001a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014f6:	83 c4 18             	add    $0x18,%esp
  8014f9:	53                   	push   %ebx
  8014fa:	ff 75 10             	pushl  0x10(%ebp)
  8014fd:	e8 56 ec ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  801502:	c7 04 24 3f 1d 80 00 	movl   $0x801d3f,(%esp)
  801509:	e8 9b ec ff ff       	call   8001a9 <cprintf>
  80150e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801511:	cc                   	int3   
  801512:	eb fd                	jmp    801511 <_panic+0x5d>

00801514 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80151a:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  801521:	75 3c                	jne    80155f <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801523:	83 ec 04             	sub    $0x4,%esp
  801526:	6a 07                	push   $0x7
  801528:	68 00 f0 bf ee       	push   $0xeebff000
  80152d:	6a 00                	push   $0x0
  80152f:	e8 d2 f9 ff ff       	call   800f06 <sys_page_alloc>
		if (r) {
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	74 12                	je     80154d <set_pgfault_handler+0x39>
			panic("set_pgfault_handler: %e\n", r);
  80153b:	50                   	push   %eax
  80153c:	68 28 1d 80 00       	push   $0x801d28
  801541:	6a 22                	push   $0x22
  801543:	68 41 1d 80 00       	push   $0x801d41
  801548:	e8 67 ff ff ff       	call   8014b4 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	68 69 15 80 00       	push   $0x801569
  801555:	6a 00                	push   $0x0
  801557:	e8 0f fb ff ff       	call   80106b <sys_env_set_pgfault_upcall>
  80155c:	83 c4 10             	add    $0x10,%esp
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80155f:	8b 45 08             	mov    0x8(%ebp),%eax
  801562:	a3 14 20 80 00       	mov    %eax,0x802014
}
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801569:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80156a:	a1 14 20 80 00       	mov    0x802014,%eax
	call *%eax
  80156f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801571:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  801574:	8b 44 24 30          	mov    0x30(%esp),%eax
	leal -0x4(%eax), %eax	// preserve space to store trap-time eip
  801578:	8d 40 fc             	lea    -0x4(%eax),%eax
	movl %eax, 0x30(%esp)
  80157b:	89 44 24 30          	mov    %eax,0x30(%esp)

	movl 0x28(%esp), %ecx
  80157f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801583:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801585:	83 c4 08             	add    $0x8,%esp
	popal
  801588:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801589:	83 c4 04             	add    $0x4,%esp
	popfl
  80158c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80158d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80158e:	c3                   	ret    
  80158f:	90                   	nop

00801590 <__udivdi3>:
  801590:	55                   	push   %ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
  801594:	83 ec 1c             	sub    $0x1c,%esp
  801597:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80159b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80159f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8015a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8015a7:	85 f6                	test   %esi,%esi
  8015a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ad:	89 ca                	mov    %ecx,%edx
  8015af:	89 f8                	mov    %edi,%eax
  8015b1:	75 3d                	jne    8015f0 <__udivdi3+0x60>
  8015b3:	39 cf                	cmp    %ecx,%edi
  8015b5:	0f 87 c5 00 00 00    	ja     801680 <__udivdi3+0xf0>
  8015bb:	85 ff                	test   %edi,%edi
  8015bd:	89 fd                	mov    %edi,%ebp
  8015bf:	75 0b                	jne    8015cc <__udivdi3+0x3c>
  8015c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c6:	31 d2                	xor    %edx,%edx
  8015c8:	f7 f7                	div    %edi
  8015ca:	89 c5                	mov    %eax,%ebp
  8015cc:	89 c8                	mov    %ecx,%eax
  8015ce:	31 d2                	xor    %edx,%edx
  8015d0:	f7 f5                	div    %ebp
  8015d2:	89 c1                	mov    %eax,%ecx
  8015d4:	89 d8                	mov    %ebx,%eax
  8015d6:	89 cf                	mov    %ecx,%edi
  8015d8:	f7 f5                	div    %ebp
  8015da:	89 c3                	mov    %eax,%ebx
  8015dc:	89 d8                	mov    %ebx,%eax
  8015de:	89 fa                	mov    %edi,%edx
  8015e0:	83 c4 1c             	add    $0x1c,%esp
  8015e3:	5b                   	pop    %ebx
  8015e4:	5e                   	pop    %esi
  8015e5:	5f                   	pop    %edi
  8015e6:	5d                   	pop    %ebp
  8015e7:	c3                   	ret    
  8015e8:	90                   	nop
  8015e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015f0:	39 ce                	cmp    %ecx,%esi
  8015f2:	77 74                	ja     801668 <__udivdi3+0xd8>
  8015f4:	0f bd fe             	bsr    %esi,%edi
  8015f7:	83 f7 1f             	xor    $0x1f,%edi
  8015fa:	0f 84 98 00 00 00    	je     801698 <__udivdi3+0x108>
  801600:	bb 20 00 00 00       	mov    $0x20,%ebx
  801605:	89 f9                	mov    %edi,%ecx
  801607:	89 c5                	mov    %eax,%ebp
  801609:	29 fb                	sub    %edi,%ebx
  80160b:	d3 e6                	shl    %cl,%esi
  80160d:	89 d9                	mov    %ebx,%ecx
  80160f:	d3 ed                	shr    %cl,%ebp
  801611:	89 f9                	mov    %edi,%ecx
  801613:	d3 e0                	shl    %cl,%eax
  801615:	09 ee                	or     %ebp,%esi
  801617:	89 d9                	mov    %ebx,%ecx
  801619:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80161d:	89 d5                	mov    %edx,%ebp
  80161f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801623:	d3 ed                	shr    %cl,%ebp
  801625:	89 f9                	mov    %edi,%ecx
  801627:	d3 e2                	shl    %cl,%edx
  801629:	89 d9                	mov    %ebx,%ecx
  80162b:	d3 e8                	shr    %cl,%eax
  80162d:	09 c2                	or     %eax,%edx
  80162f:	89 d0                	mov    %edx,%eax
  801631:	89 ea                	mov    %ebp,%edx
  801633:	f7 f6                	div    %esi
  801635:	89 d5                	mov    %edx,%ebp
  801637:	89 c3                	mov    %eax,%ebx
  801639:	f7 64 24 0c          	mull   0xc(%esp)
  80163d:	39 d5                	cmp    %edx,%ebp
  80163f:	72 10                	jb     801651 <__udivdi3+0xc1>
  801641:	8b 74 24 08          	mov    0x8(%esp),%esi
  801645:	89 f9                	mov    %edi,%ecx
  801647:	d3 e6                	shl    %cl,%esi
  801649:	39 c6                	cmp    %eax,%esi
  80164b:	73 07                	jae    801654 <__udivdi3+0xc4>
  80164d:	39 d5                	cmp    %edx,%ebp
  80164f:	75 03                	jne    801654 <__udivdi3+0xc4>
  801651:	83 eb 01             	sub    $0x1,%ebx
  801654:	31 ff                	xor    %edi,%edi
  801656:	89 d8                	mov    %ebx,%eax
  801658:	89 fa                	mov    %edi,%edx
  80165a:	83 c4 1c             	add    $0x1c,%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    
  801662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801668:	31 ff                	xor    %edi,%edi
  80166a:	31 db                	xor    %ebx,%ebx
  80166c:	89 d8                	mov    %ebx,%eax
  80166e:	89 fa                	mov    %edi,%edx
  801670:	83 c4 1c             	add    $0x1c,%esp
  801673:	5b                   	pop    %ebx
  801674:	5e                   	pop    %esi
  801675:	5f                   	pop    %edi
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    
  801678:	90                   	nop
  801679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801680:	89 d8                	mov    %ebx,%eax
  801682:	f7 f7                	div    %edi
  801684:	31 ff                	xor    %edi,%edi
  801686:	89 c3                	mov    %eax,%ebx
  801688:	89 d8                	mov    %ebx,%eax
  80168a:	89 fa                	mov    %edi,%edx
  80168c:	83 c4 1c             	add    $0x1c,%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5f                   	pop    %edi
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    
  801694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801698:	39 ce                	cmp    %ecx,%esi
  80169a:	72 0c                	jb     8016a8 <__udivdi3+0x118>
  80169c:	31 db                	xor    %ebx,%ebx
  80169e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8016a2:	0f 87 34 ff ff ff    	ja     8015dc <__udivdi3+0x4c>
  8016a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8016ad:	e9 2a ff ff ff       	jmp    8015dc <__udivdi3+0x4c>
  8016b2:	66 90                	xchg   %ax,%ax
  8016b4:	66 90                	xchg   %ax,%ax
  8016b6:	66 90                	xchg   %ax,%ax
  8016b8:	66 90                	xchg   %ax,%ax
  8016ba:	66 90                	xchg   %ax,%ax
  8016bc:	66 90                	xchg   %ax,%ax
  8016be:	66 90                	xchg   %ax,%ax

008016c0 <__umoddi3>:
  8016c0:	55                   	push   %ebp
  8016c1:	57                   	push   %edi
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 1c             	sub    $0x1c,%esp
  8016c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8016cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8016cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8016d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8016d7:	85 d2                	test   %edx,%edx
  8016d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8016dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016e1:	89 f3                	mov    %esi,%ebx
  8016e3:	89 3c 24             	mov    %edi,(%esp)
  8016e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ea:	75 1c                	jne    801708 <__umoddi3+0x48>
  8016ec:	39 f7                	cmp    %esi,%edi
  8016ee:	76 50                	jbe    801740 <__umoddi3+0x80>
  8016f0:	89 c8                	mov    %ecx,%eax
  8016f2:	89 f2                	mov    %esi,%edx
  8016f4:	f7 f7                	div    %edi
  8016f6:	89 d0                	mov    %edx,%eax
  8016f8:	31 d2                	xor    %edx,%edx
  8016fa:	83 c4 1c             	add    $0x1c,%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5f                   	pop    %edi
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    
  801702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801708:	39 f2                	cmp    %esi,%edx
  80170a:	89 d0                	mov    %edx,%eax
  80170c:	77 52                	ja     801760 <__umoddi3+0xa0>
  80170e:	0f bd ea             	bsr    %edx,%ebp
  801711:	83 f5 1f             	xor    $0x1f,%ebp
  801714:	75 5a                	jne    801770 <__umoddi3+0xb0>
  801716:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80171a:	0f 82 e0 00 00 00    	jb     801800 <__umoddi3+0x140>
  801720:	39 0c 24             	cmp    %ecx,(%esp)
  801723:	0f 86 d7 00 00 00    	jbe    801800 <__umoddi3+0x140>
  801729:	8b 44 24 08          	mov    0x8(%esp),%eax
  80172d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801731:	83 c4 1c             	add    $0x1c,%esp
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5f                   	pop    %edi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    
  801739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801740:	85 ff                	test   %edi,%edi
  801742:	89 fd                	mov    %edi,%ebp
  801744:	75 0b                	jne    801751 <__umoddi3+0x91>
  801746:	b8 01 00 00 00       	mov    $0x1,%eax
  80174b:	31 d2                	xor    %edx,%edx
  80174d:	f7 f7                	div    %edi
  80174f:	89 c5                	mov    %eax,%ebp
  801751:	89 f0                	mov    %esi,%eax
  801753:	31 d2                	xor    %edx,%edx
  801755:	f7 f5                	div    %ebp
  801757:	89 c8                	mov    %ecx,%eax
  801759:	f7 f5                	div    %ebp
  80175b:	89 d0                	mov    %edx,%eax
  80175d:	eb 99                	jmp    8016f8 <__umoddi3+0x38>
  80175f:	90                   	nop
  801760:	89 c8                	mov    %ecx,%eax
  801762:	89 f2                	mov    %esi,%edx
  801764:	83 c4 1c             	add    $0x1c,%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5f                   	pop    %edi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    
  80176c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801770:	8b 34 24             	mov    (%esp),%esi
  801773:	bf 20 00 00 00       	mov    $0x20,%edi
  801778:	89 e9                	mov    %ebp,%ecx
  80177a:	29 ef                	sub    %ebp,%edi
  80177c:	d3 e0                	shl    %cl,%eax
  80177e:	89 f9                	mov    %edi,%ecx
  801780:	89 f2                	mov    %esi,%edx
  801782:	d3 ea                	shr    %cl,%edx
  801784:	89 e9                	mov    %ebp,%ecx
  801786:	09 c2                	or     %eax,%edx
  801788:	89 d8                	mov    %ebx,%eax
  80178a:	89 14 24             	mov    %edx,(%esp)
  80178d:	89 f2                	mov    %esi,%edx
  80178f:	d3 e2                	shl    %cl,%edx
  801791:	89 f9                	mov    %edi,%ecx
  801793:	89 54 24 04          	mov    %edx,0x4(%esp)
  801797:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80179b:	d3 e8                	shr    %cl,%eax
  80179d:	89 e9                	mov    %ebp,%ecx
  80179f:	89 c6                	mov    %eax,%esi
  8017a1:	d3 e3                	shl    %cl,%ebx
  8017a3:	89 f9                	mov    %edi,%ecx
  8017a5:	89 d0                	mov    %edx,%eax
  8017a7:	d3 e8                	shr    %cl,%eax
  8017a9:	89 e9                	mov    %ebp,%ecx
  8017ab:	09 d8                	or     %ebx,%eax
  8017ad:	89 d3                	mov    %edx,%ebx
  8017af:	89 f2                	mov    %esi,%edx
  8017b1:	f7 34 24             	divl   (%esp)
  8017b4:	89 d6                	mov    %edx,%esi
  8017b6:	d3 e3                	shl    %cl,%ebx
  8017b8:	f7 64 24 04          	mull   0x4(%esp)
  8017bc:	39 d6                	cmp    %edx,%esi
  8017be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017c2:	89 d1                	mov    %edx,%ecx
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	72 08                	jb     8017d0 <__umoddi3+0x110>
  8017c8:	75 11                	jne    8017db <__umoddi3+0x11b>
  8017ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8017ce:	73 0b                	jae    8017db <__umoddi3+0x11b>
  8017d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8017d4:	1b 14 24             	sbb    (%esp),%edx
  8017d7:	89 d1                	mov    %edx,%ecx
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8017df:	29 da                	sub    %ebx,%edx
  8017e1:	19 ce                	sbb    %ecx,%esi
  8017e3:	89 f9                	mov    %edi,%ecx
  8017e5:	89 f0                	mov    %esi,%eax
  8017e7:	d3 e0                	shl    %cl,%eax
  8017e9:	89 e9                	mov    %ebp,%ecx
  8017eb:	d3 ea                	shr    %cl,%edx
  8017ed:	89 e9                	mov    %ebp,%ecx
  8017ef:	d3 ee                	shr    %cl,%esi
  8017f1:	09 d0                	or     %edx,%eax
  8017f3:	89 f2                	mov    %esi,%edx
  8017f5:	83 c4 1c             	add    $0x1c,%esp
  8017f8:	5b                   	pop    %ebx
  8017f9:	5e                   	pop    %esi
  8017fa:	5f                   	pop    %edi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    
  8017fd:	8d 76 00             	lea    0x0(%esi),%esi
  801800:	29 f9                	sub    %edi,%ecx
  801802:	19 d6                	sbb    %edx,%esi
  801804:	89 74 24 04          	mov    %esi,0x4(%esp)
  801808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80180c:	e9 18 ff ff ff       	jmp    801729 <__umoddi3+0x69>
