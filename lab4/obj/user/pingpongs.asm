
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 20 14 00 00       	call   801461 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 10 20 80 00    	mov    0x802010,%ebx
  80004e:	e8 5e 0e 00 00       	call   800eb1 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 60 18 80 00       	push   $0x801860
  80005d:	e8 87 01 00 00       	call   8001e9 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 47 0e 00 00       	call   800eb1 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 7a 18 80 00       	push   $0x80187a
  800074:	e8 70 01 00 00       	call   8001e9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 0b 14 00 00       	call   801492 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 e1 13 00 00       	call   80147b <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 10 20 80 00    	mov    0x802010,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 fe 0d 00 00       	call   800eb1 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 90 18 80 00       	push   $0x801890
  8000c2:	e8 22 01 00 00       	call   8001e9 <cprintf>
		if (val == 10)
  8000c7:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 0c 20 80 00       	mov    %eax,0x80200c
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 a8 13 00 00       	call   801492 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 0c 20 80 00 0a 	cmpl   $0xa,0x80200c
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800109:	e8 a3 0d 00 00       	call   800eb1 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	c1 e0 07             	shl    $0x7,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 10 20 80 00       	mov    %eax,0x802010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 10 0d 00 00       	call   800e61 <sys_env_destroy>
}
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800160:	8b 13                	mov    (%ebx),%edx
  800162:	8d 42 01             	lea    0x1(%edx),%eax
  800165:	89 03                	mov    %eax,(%ebx)
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 1a                	jne    80018f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	68 ff 00 00 00       	push   $0xff
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 7a 0c 00 00       	call   800e00 <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a8:	00 00 00 
	b.cnt = 0;
  8001ab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c1:	50                   	push   %eax
  8001c2:	68 56 01 80 00       	push   $0x800156
  8001c7:	e8 c0 02 00 00       	call   80048c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cc:	83 c4 08             	add    $0x8,%esp
  8001cf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	e8 1f 0c 00 00       	call   800e00 <sys_cputs>

	return b.cnt;
}
  8001e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f2:	50                   	push   %eax
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	e8 9d ff ff ff       	call   800198 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 1c             	sub    $0x1c,%esp
  800206:	89 c7                	mov    %eax,%edi
  800208:	89 d6                	mov    %edx,%esi
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800210:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800213:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800219:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80021d:	0f 85 bf 00 00 00    	jne    8002e2 <printnum+0xe5>
  800223:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800229:	0f 8d de 00 00 00    	jge    80030d <printnum+0x110>
		judge_time_for_space = width;
  80022f:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800235:	e9 d3 00 00 00       	jmp    80030d <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80023a:	83 eb 01             	sub    $0x1,%ebx
  80023d:	85 db                	test   %ebx,%ebx
  80023f:	7f 37                	jg     800278 <printnum+0x7b>
  800241:	e9 ea 00 00 00       	jmp    800330 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800246:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800249:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	56                   	push   %esi
  800252:	83 ec 04             	sub    $0x4,%esp
  800255:	ff 75 dc             	pushl  -0x24(%ebp)
  800258:	ff 75 d8             	pushl  -0x28(%ebp)
  80025b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025e:	ff 75 e0             	pushl  -0x20(%ebp)
  800261:	e8 9a 14 00 00       	call   801700 <__umoddi3>
  800266:	83 c4 14             	add    $0x14,%esp
  800269:	0f be 80 c0 18 80 00 	movsbl 0x8018c0(%eax),%eax
  800270:	50                   	push   %eax
  800271:	ff d7                	call   *%edi
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	eb 16                	jmp    80028e <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	56                   	push   %esi
  80027c:	ff 75 18             	pushl  0x18(%ebp)
  80027f:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800281:	83 c4 10             	add    $0x10,%esp
  800284:	83 eb 01             	sub    $0x1,%ebx
  800287:	75 ef                	jne    800278 <printnum+0x7b>
  800289:	e9 a2 00 00 00       	jmp    800330 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  80028e:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800294:	0f 85 76 01 00 00    	jne    800410 <printnum+0x213>
		while(num_of_space-- > 0)
  80029a:	a1 04 20 80 00       	mov    0x802004,%eax
  80029f:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002a2:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	7e 1d                	jle    8002c9 <printnum+0xcc>
			putch(' ', putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	6a 20                	push   $0x20
  8002b2:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8002b4:	a1 04 20 80 00       	mov    0x802004,%eax
  8002b9:	8d 50 ff             	lea    -0x1(%eax),%edx
  8002bc:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	85 c0                	test   %eax,%eax
  8002c7:	7f e3                	jg     8002ac <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8002c9:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8002d0:	00 00 00 
		judge_time_for_space = 0;
  8002d3:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8002da:	00 00 00 
	}
}
  8002dd:	e9 2e 01 00 00       	jmp    800410 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002f6:	83 fa 00             	cmp    $0x0,%edx
  8002f9:	0f 87 ba 00 00 00    	ja     8003b9 <printnum+0x1bc>
  8002ff:	3b 45 10             	cmp    0x10(%ebp),%eax
  800302:	0f 83 b1 00 00 00    	jae    8003b9 <printnum+0x1bc>
  800308:	e9 2d ff ff ff       	jmp    80023a <printnum+0x3d>
  80030d:	8b 45 10             	mov    0x10(%ebp),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800318:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80031b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800321:	83 fa 00             	cmp    $0x0,%edx
  800324:	77 37                	ja     80035d <printnum+0x160>
  800326:	3b 45 10             	cmp    0x10(%ebp),%eax
  800329:	73 32                	jae    80035d <printnum+0x160>
  80032b:	e9 16 ff ff ff       	jmp    800246 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800330:	83 ec 08             	sub    $0x8,%esp
  800333:	56                   	push   %esi
  800334:	83 ec 04             	sub    $0x4,%esp
  800337:	ff 75 dc             	pushl  -0x24(%ebp)
  80033a:	ff 75 d8             	pushl  -0x28(%ebp)
  80033d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800340:	ff 75 e0             	pushl  -0x20(%ebp)
  800343:	e8 b8 13 00 00       	call   801700 <__umoddi3>
  800348:	83 c4 14             	add    $0x14,%esp
  80034b:	0f be 80 c0 18 80 00 	movsbl 0x8018c0(%eax),%eax
  800352:	50                   	push   %eax
  800353:	ff d7                	call   *%edi
  800355:	83 c4 10             	add    $0x10,%esp
  800358:	e9 b3 00 00 00       	jmp    800410 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035d:	83 ec 0c             	sub    $0xc,%esp
  800360:	ff 75 18             	pushl  0x18(%ebp)
  800363:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800366:	50                   	push   %eax
  800367:	ff 75 10             	pushl  0x10(%ebp)
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	ff 75 dc             	pushl  -0x24(%ebp)
  800370:	ff 75 d8             	pushl  -0x28(%ebp)
  800373:	ff 75 e4             	pushl  -0x1c(%ebp)
  800376:	ff 75 e0             	pushl  -0x20(%ebp)
  800379:	e8 52 12 00 00       	call   8015d0 <__udivdi3>
  80037e:	83 c4 18             	add    $0x18,%esp
  800381:	52                   	push   %edx
  800382:	50                   	push   %eax
  800383:	89 f2                	mov    %esi,%edx
  800385:	89 f8                	mov    %edi,%eax
  800387:	e8 71 fe ff ff       	call   8001fd <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038c:	83 c4 18             	add    $0x18,%esp
  80038f:	56                   	push   %esi
  800390:	83 ec 04             	sub    $0x4,%esp
  800393:	ff 75 dc             	pushl  -0x24(%ebp)
  800396:	ff 75 d8             	pushl  -0x28(%ebp)
  800399:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039c:	ff 75 e0             	pushl  -0x20(%ebp)
  80039f:	e8 5c 13 00 00       	call   801700 <__umoddi3>
  8003a4:	83 c4 14             	add    $0x14,%esp
  8003a7:	0f be 80 c0 18 80 00 	movsbl 0x8018c0(%eax),%eax
  8003ae:	50                   	push   %eax
  8003af:	ff d7                	call   *%edi
  8003b1:	83 c4 10             	add    $0x10,%esp
  8003b4:	e9 d5 fe ff ff       	jmp    80028e <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b9:	83 ec 0c             	sub    $0xc,%esp
  8003bc:	ff 75 18             	pushl  0x18(%ebp)
  8003bf:	83 eb 01             	sub    $0x1,%ebx
  8003c2:	53                   	push   %ebx
  8003c3:	ff 75 10             	pushl  0x10(%ebp)
  8003c6:	83 ec 08             	sub    $0x8,%esp
  8003c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8003cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d5:	e8 f6 11 00 00       	call   8015d0 <__udivdi3>
  8003da:	83 c4 18             	add    $0x18,%esp
  8003dd:	52                   	push   %edx
  8003de:	50                   	push   %eax
  8003df:	89 f2                	mov    %esi,%edx
  8003e1:	89 f8                	mov    %edi,%eax
  8003e3:	e8 15 fe ff ff       	call   8001fd <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e8:	83 c4 18             	add    $0x18,%esp
  8003eb:	56                   	push   %esi
  8003ec:	83 ec 04             	sub    $0x4,%esp
  8003ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8003fb:	e8 00 13 00 00       	call   801700 <__umoddi3>
  800400:	83 c4 14             	add    $0x14,%esp
  800403:	0f be 80 c0 18 80 00 	movsbl 0x8018c0(%eax),%eax
  80040a:	50                   	push   %eax
  80040b:	ff d7                	call   *%edi
  80040d:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800410:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800413:	5b                   	pop    %ebx
  800414:	5e                   	pop    %esi
  800415:	5f                   	pop    %edi
  800416:	5d                   	pop    %ebp
  800417:	c3                   	ret    

00800418 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80041b:	83 fa 01             	cmp    $0x1,%edx
  80041e:	7e 0e                	jle    80042e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800420:	8b 10                	mov    (%eax),%edx
  800422:	8d 4a 08             	lea    0x8(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 02                	mov    (%edx),%eax
  800429:	8b 52 04             	mov    0x4(%edx),%edx
  80042c:	eb 22                	jmp    800450 <getuint+0x38>
	else if (lflag)
  80042e:	85 d2                	test   %edx,%edx
  800430:	74 10                	je     800442 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800432:	8b 10                	mov    (%eax),%edx
  800434:	8d 4a 04             	lea    0x4(%edx),%ecx
  800437:	89 08                	mov    %ecx,(%eax)
  800439:	8b 02                	mov    (%edx),%eax
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
  800440:	eb 0e                	jmp    800450 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800442:	8b 10                	mov    (%eax),%edx
  800444:	8d 4a 04             	lea    0x4(%edx),%ecx
  800447:	89 08                	mov    %ecx,(%eax)
  800449:	8b 02                	mov    (%edx),%eax
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    

00800452 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800458:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80045c:	8b 10                	mov    (%eax),%edx
  80045e:	3b 50 04             	cmp    0x4(%eax),%edx
  800461:	73 0a                	jae    80046d <sprintputch+0x1b>
		*b->buf++ = ch;
  800463:	8d 4a 01             	lea    0x1(%edx),%ecx
  800466:	89 08                	mov    %ecx,(%eax)
  800468:	8b 45 08             	mov    0x8(%ebp),%eax
  80046b:	88 02                	mov    %al,(%edx)
}
  80046d:	5d                   	pop    %ebp
  80046e:	c3                   	ret    

0080046f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800475:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800478:	50                   	push   %eax
  800479:	ff 75 10             	pushl  0x10(%ebp)
  80047c:	ff 75 0c             	pushl  0xc(%ebp)
  80047f:	ff 75 08             	pushl  0x8(%ebp)
  800482:	e8 05 00 00 00       	call   80048c <vprintfmt>
	va_end(ap);
}
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	c9                   	leave  
  80048b:	c3                   	ret    

0080048c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	57                   	push   %edi
  800490:	56                   	push   %esi
  800491:	53                   	push   %ebx
  800492:	83 ec 2c             	sub    $0x2c,%esp
  800495:	8b 7d 08             	mov    0x8(%ebp),%edi
  800498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049b:	eb 03                	jmp    8004a0 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80049d:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a3:	8d 70 01             	lea    0x1(%eax),%esi
  8004a6:	0f b6 00             	movzbl (%eax),%eax
  8004a9:	83 f8 25             	cmp    $0x25,%eax
  8004ac:	74 27                	je     8004d5 <vprintfmt+0x49>
			if (ch == '\0')
  8004ae:	85 c0                	test   %eax,%eax
  8004b0:	75 0d                	jne    8004bf <vprintfmt+0x33>
  8004b2:	e9 9d 04 00 00       	jmp    800954 <vprintfmt+0x4c8>
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	0f 84 95 04 00 00    	je     800954 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	53                   	push   %ebx
  8004c3:	50                   	push   %eax
  8004c4:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c6:	83 c6 01             	add    $0x1,%esi
  8004c9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	83 f8 25             	cmp    $0x25,%eax
  8004d3:	75 e2                	jne    8004b7 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004da:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ec:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004f3:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004fa:	eb 08                	jmp    800504 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8004ff:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8d 46 01             	lea    0x1(%esi),%eax
  800507:	89 45 10             	mov    %eax,0x10(%ebp)
  80050a:	0f b6 06             	movzbl (%esi),%eax
  80050d:	0f b6 d0             	movzbl %al,%edx
  800510:	83 e8 23             	sub    $0x23,%eax
  800513:	3c 55                	cmp    $0x55,%al
  800515:	0f 87 fa 03 00 00    	ja     800915 <vprintfmt+0x489>
  80051b:	0f b6 c0             	movzbl %al,%eax
  80051e:	ff 24 85 00 1a 80 00 	jmp    *0x801a00(,%eax,4)
  800525:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800528:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80052c:	eb d6                	jmp    800504 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80052e:	8d 42 d0             	lea    -0x30(%edx),%eax
  800531:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800534:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800538:	8d 50 d0             	lea    -0x30(%eax),%edx
  80053b:	83 fa 09             	cmp    $0x9,%edx
  80053e:	77 6b                	ja     8005ab <vprintfmt+0x11f>
  800540:	8b 75 10             	mov    0x10(%ebp),%esi
  800543:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800546:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800549:	eb 09                	jmp    800554 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80054e:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800552:	eb b0                	jmp    800504 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800554:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800557:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80055a:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80055e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800561:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800564:	83 f9 09             	cmp    $0x9,%ecx
  800567:	76 eb                	jbe    800554 <vprintfmt+0xc8>
  800569:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80056c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80056f:	eb 3d                	jmp    8005ae <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800582:	eb 2a                	jmp    8005ae <vprintfmt+0x122>
  800584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	0f 49 d0             	cmovns %eax,%edx
  800591:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 75 10             	mov    0x10(%ebp),%esi
  800597:	e9 68 ff ff ff       	jmp    800504 <vprintfmt+0x78>
  80059c:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005a6:	e9 59 ff ff ff       	jmp    800504 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b2:	0f 89 4c ff ff ff    	jns    800504 <vprintfmt+0x78>
				width = precision, precision = -1;
  8005b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c5:	e9 3a ff ff ff       	jmp    800504 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ca:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d1:	e9 2e ff ff ff       	jmp    800504 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	ff 30                	pushl  (%eax)
  8005e5:	ff d7                	call   *%edi
			break;
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	e9 b1 fe ff ff       	jmp    8004a0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	99                   	cltd   
  8005fb:	31 d0                	xor    %edx,%eax
  8005fd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ff:	83 f8 08             	cmp    $0x8,%eax
  800602:	7f 0b                	jg     80060f <vprintfmt+0x183>
  800604:	8b 14 85 60 1b 80 00 	mov    0x801b60(,%eax,4),%edx
  80060b:	85 d2                	test   %edx,%edx
  80060d:	75 15                	jne    800624 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80060f:	50                   	push   %eax
  800610:	68 d8 18 80 00       	push   $0x8018d8
  800615:	53                   	push   %ebx
  800616:	57                   	push   %edi
  800617:	e8 53 fe ff ff       	call   80046f <printfmt>
  80061c:	83 c4 10             	add    $0x10,%esp
  80061f:	e9 7c fe ff ff       	jmp    8004a0 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800624:	52                   	push   %edx
  800625:	68 e1 18 80 00       	push   $0x8018e1
  80062a:	53                   	push   %ebx
  80062b:	57                   	push   %edi
  80062c:	e8 3e fe ff ff       	call   80046f <printfmt>
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	e9 67 fe ff ff       	jmp    8004a0 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 50 04             	lea    0x4(%eax),%edx
  80063f:	89 55 14             	mov    %edx,0x14(%ebp)
  800642:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800644:	85 c0                	test   %eax,%eax
  800646:	b9 d1 18 80 00       	mov    $0x8018d1,%ecx
  80064b:	0f 45 c8             	cmovne %eax,%ecx
  80064e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800651:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800655:	7e 06                	jle    80065d <vprintfmt+0x1d1>
  800657:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80065b:	75 19                	jne    800676 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800660:	8d 70 01             	lea    0x1(%eax),%esi
  800663:	0f b6 00             	movzbl (%eax),%eax
  800666:	0f be d0             	movsbl %al,%edx
  800669:	85 d2                	test   %edx,%edx
  80066b:	0f 85 9f 00 00 00    	jne    800710 <vprintfmt+0x284>
  800671:	e9 8c 00 00 00       	jmp    800702 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	ff 75 d0             	pushl  -0x30(%ebp)
  80067c:	ff 75 cc             	pushl  -0x34(%ebp)
  80067f:	e8 62 03 00 00       	call   8009e6 <strnlen>
  800684:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800687:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	0f 8e a6 02 00 00    	jle    80093b <vprintfmt+0x4af>
					putch(padc, putdat);
  800695:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800699:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069c:	89 cb                	mov    %ecx,%ebx
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	ff 75 0c             	pushl  0xc(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	83 eb 01             	sub    $0x1,%ebx
  8006ad:	75 ef                	jne    80069e <vprintfmt+0x212>
  8006af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b5:	e9 81 02 00 00       	jmp    80093b <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006be:	74 1b                	je     8006db <vprintfmt+0x24f>
  8006c0:	0f be c0             	movsbl %al,%eax
  8006c3:	83 e8 20             	sub    $0x20,%eax
  8006c6:	83 f8 5e             	cmp    $0x5e,%eax
  8006c9:	76 10                	jbe    8006db <vprintfmt+0x24f>
					putch('?', putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	ff 75 0c             	pushl  0xc(%ebp)
  8006d1:	6a 3f                	push   $0x3f
  8006d3:	ff 55 08             	call   *0x8(%ebp)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb 0d                	jmp    8006e8 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	ff 75 0c             	pushl  0xc(%ebp)
  8006e1:	52                   	push   %edx
  8006e2:	ff 55 08             	call   *0x8(%ebp)
  8006e5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e8:	83 ef 01             	sub    $0x1,%edi
  8006eb:	83 c6 01             	add    $0x1,%esi
  8006ee:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8006f2:	0f be d0             	movsbl %al,%edx
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	75 31                	jne    80072a <vprintfmt+0x29e>
  8006f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800702:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800705:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800709:	7f 33                	jg     80073e <vprintfmt+0x2b2>
  80070b:	e9 90 fd ff ff       	jmp    8004a0 <vprintfmt+0x14>
  800710:	89 7d 08             	mov    %edi,0x8(%ebp)
  800713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800716:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800719:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80071c:	eb 0c                	jmp    80072a <vprintfmt+0x29e>
  80071e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800721:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800724:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800727:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072a:	85 db                	test   %ebx,%ebx
  80072c:	78 8c                	js     8006ba <vprintfmt+0x22e>
  80072e:	83 eb 01             	sub    $0x1,%ebx
  800731:	79 87                	jns    8006ba <vprintfmt+0x22e>
  800733:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800736:	8b 7d 08             	mov    0x8(%ebp),%edi
  800739:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073c:	eb c4                	jmp    800702 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	6a 20                	push   $0x20
  800744:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	83 ee 01             	sub    $0x1,%esi
  80074c:	75 f0                	jne    80073e <vprintfmt+0x2b2>
  80074e:	e9 4d fd ff ff       	jmp    8004a0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800753:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800757:	7e 16                	jle    80076f <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8d 50 08             	lea    0x8(%eax),%edx
  80075f:	89 55 14             	mov    %edx,0x14(%ebp)
  800762:	8b 50 04             	mov    0x4(%eax),%edx
  800765:	8b 00                	mov    (%eax),%eax
  800767:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80076a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80076d:	eb 34                	jmp    8007a3 <vprintfmt+0x317>
	else if (lflag)
  80076f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800773:	74 18                	je     80078d <vprintfmt+0x301>
		return va_arg(*ap, long);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)
  80077e:	8b 30                	mov    (%eax),%esi
  800780:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800783:	89 f0                	mov    %esi,%eax
  800785:	c1 f8 1f             	sar    $0x1f,%eax
  800788:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80078b:	eb 16                	jmp    8007a3 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8d 50 04             	lea    0x4(%eax),%edx
  800793:	89 55 14             	mov    %edx,0x14(%ebp)
  800796:	8b 30                	mov    (%eax),%esi
  800798:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80079b:	89 f0                	mov    %esi,%eax
  80079d:	c1 f8 1f             	sar    $0x1f,%eax
  8007a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007af:	85 d2                	test   %edx,%edx
  8007b1:	79 28                	jns    8007db <vprintfmt+0x34f>
				putch('-', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	53                   	push   %ebx
  8007b7:	6a 2d                	push   $0x2d
  8007b9:	ff d7                	call   *%edi
				num = -(long long) num;
  8007bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c1:	f7 d8                	neg    %eax
  8007c3:	83 d2 00             	adc    $0x0,%edx
  8007c6:	f7 da                	neg    %edx
  8007c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ce:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8007d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d6:	e9 b2 00 00 00       	jmp    80088d <vprintfmt+0x401>
  8007db:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8007e0:	85 c9                	test   %ecx,%ecx
  8007e2:	0f 84 a5 00 00 00    	je     80088d <vprintfmt+0x401>
				putch('+', putdat);
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	53                   	push   %ebx
  8007ec:	6a 2b                	push   $0x2b
  8007ee:	ff d7                	call   *%edi
  8007f0:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8007f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f8:	e9 90 00 00 00       	jmp    80088d <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8007fd:	85 c9                	test   %ecx,%ecx
  8007ff:	74 0b                	je     80080c <vprintfmt+0x380>
				putch('+', putdat);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	53                   	push   %ebx
  800805:	6a 2b                	push   $0x2b
  800807:	ff d7                	call   *%edi
  800809:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  80080c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80080f:	8d 45 14             	lea    0x14(%ebp),%eax
  800812:	e8 01 fc ff ff       	call   800418 <getuint>
  800817:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80081d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800822:	eb 69                	jmp    80088d <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	53                   	push   %ebx
  800828:	6a 30                	push   $0x30
  80082a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80082c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	e8 e1 fb ff ff       	call   800418 <getuint>
  800837:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80083d:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800840:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800845:	eb 46                	jmp    80088d <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	53                   	push   %ebx
  80084b:	6a 30                	push   $0x30
  80084d:	ff d7                	call   *%edi
			putch('x', putdat);
  80084f:	83 c4 08             	add    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 78                	push   $0x78
  800855:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8d 50 04             	lea    0x4(%eax),%edx
  80085d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800860:	8b 00                	mov    (%eax),%eax
  800862:	ba 00 00 00 00       	mov    $0x0,%edx
  800867:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80086a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80086d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800870:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800875:	eb 16                	jmp    80088d <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800877:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80087a:	8d 45 14             	lea    0x14(%ebp),%eax
  80087d:	e8 96 fb ff ff       	call   800418 <getuint>
  800882:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800885:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800888:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088d:	83 ec 0c             	sub    $0xc,%esp
  800890:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800894:	56                   	push   %esi
  800895:	ff 75 e4             	pushl  -0x1c(%ebp)
  800898:	50                   	push   %eax
  800899:	ff 75 dc             	pushl  -0x24(%ebp)
  80089c:	ff 75 d8             	pushl  -0x28(%ebp)
  80089f:	89 da                	mov    %ebx,%edx
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	e8 55 f9 ff ff       	call   8001fd <printnum>
			break;
  8008a8:	83 c4 20             	add    $0x20,%esp
  8008ab:	e9 f0 fb ff ff       	jmp    8004a0 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	8d 50 04             	lea    0x4(%eax),%edx
  8008b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b9:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8008bb:	85 f6                	test   %esi,%esi
  8008bd:	75 1a                	jne    8008d9 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	68 78 19 80 00       	push   $0x801978
  8008c7:	68 e1 18 80 00       	push   $0x8018e1
  8008cc:	e8 18 f9 ff ff       	call   8001e9 <cprintf>
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	e9 c7 fb ff ff       	jmp    8004a0 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8008d9:	0f b6 03             	movzbl (%ebx),%eax
  8008dc:	84 c0                	test   %al,%al
  8008de:	79 1f                	jns    8008ff <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	68 b0 19 80 00       	push   $0x8019b0
  8008e8:	68 e1 18 80 00       	push   $0x8018e1
  8008ed:	e8 f7 f8 ff ff       	call   8001e9 <cprintf>
						*tmp = *(char *)putdat;
  8008f2:	0f b6 03             	movzbl (%ebx),%eax
  8008f5:	88 06                	mov    %al,(%esi)
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	e9 a1 fb ff ff       	jmp    8004a0 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8008ff:	88 06                	mov    %al,(%esi)
  800901:	e9 9a fb ff ff       	jmp    8004a0 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	52                   	push   %edx
  80090b:	ff d7                	call   *%edi
			break;
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	e9 8b fb ff ff       	jmp    8004a0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	53                   	push   %ebx
  800919:	6a 25                	push   $0x25
  80091b:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800924:	0f 84 73 fb ff ff    	je     80049d <vprintfmt+0x11>
  80092a:	83 ee 01             	sub    $0x1,%esi
  80092d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800931:	75 f7                	jne    80092a <vprintfmt+0x49e>
  800933:	89 75 10             	mov    %esi,0x10(%ebp)
  800936:	e9 65 fb ff ff       	jmp    8004a0 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80093e:	8d 70 01             	lea    0x1(%eax),%esi
  800941:	0f b6 00             	movzbl (%eax),%eax
  800944:	0f be d0             	movsbl %al,%edx
  800947:	85 d2                	test   %edx,%edx
  800949:	0f 85 cf fd ff ff    	jne    80071e <vprintfmt+0x292>
  80094f:	e9 4c fb ff ff       	jmp    8004a0 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800954:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	83 ec 18             	sub    $0x18,%esp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800968:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80096b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80096f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800972:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800979:	85 c0                	test   %eax,%eax
  80097b:	74 26                	je     8009a3 <vsnprintf+0x47>
  80097d:	85 d2                	test   %edx,%edx
  80097f:	7e 22                	jle    8009a3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800981:	ff 75 14             	pushl  0x14(%ebp)
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80098a:	50                   	push   %eax
  80098b:	68 52 04 80 00       	push   $0x800452
  800990:	e8 f7 fa ff ff       	call   80048c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800995:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800998:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099e:	83 c4 10             	add    $0x10,%esp
  8009a1:	eb 05                	jmp    8009a8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b3:	50                   	push   %eax
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ba:	ff 75 08             	pushl  0x8(%ebp)
  8009bd:	e8 9a ff ff ff       	call   80095c <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ca:	80 3a 00             	cmpb   $0x0,(%edx)
  8009cd:	74 10                	je     8009df <strlen+0x1b>
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009d4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009db:	75 f7                	jne    8009d4 <strlen+0x10>
  8009dd:	eb 05                	jmp    8009e4 <strlen+0x20>
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	53                   	push   %ebx
  8009ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f0:	85 c9                	test   %ecx,%ecx
  8009f2:	74 1c                	je     800a10 <strnlen+0x2a>
  8009f4:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009f7:	74 1e                	je     800a17 <strnlen+0x31>
  8009f9:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009fe:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a00:	39 ca                	cmp    %ecx,%edx
  800a02:	74 18                	je     800a1c <strnlen+0x36>
  800a04:	83 c2 01             	add    $0x1,%edx
  800a07:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a0c:	75 f0                	jne    8009fe <strnlen+0x18>
  800a0e:	eb 0c                	jmp    800a1c <strnlen+0x36>
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	eb 05                	jmp    800a1c <strnlen+0x36>
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a29:	89 c2                	mov    %eax,%edx
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a35:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a38:	84 db                	test   %bl,%bl
  800a3a:	75 ef                	jne    800a2b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a46:	53                   	push   %ebx
  800a47:	e8 78 ff ff ff       	call   8009c4 <strlen>
  800a4c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	01 d8                	add    %ebx,%eax
  800a54:	50                   	push   %eax
  800a55:	e8 c5 ff ff ff       	call   800a1f <strcpy>
	return dst;
}
  800a5a:	89 d8                	mov    %ebx,%eax
  800a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
  800a66:	8b 75 08             	mov    0x8(%ebp),%esi
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a6f:	85 db                	test   %ebx,%ebx
  800a71:	74 17                	je     800a8a <strncpy+0x29>
  800a73:	01 f3                	add    %esi,%ebx
  800a75:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	0f b6 02             	movzbl (%edx),%eax
  800a7d:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a80:	80 3a 01             	cmpb   $0x1,(%edx)
  800a83:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a86:	39 cb                	cmp    %ecx,%ebx
  800a88:	75 ed                	jne    800a77 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a8a:	89 f0                	mov    %esi,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 75 08             	mov    0x8(%ebp),%esi
  800a98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9b:	8b 55 10             	mov    0x10(%ebp),%edx
  800a9e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa0:	85 d2                	test   %edx,%edx
  800aa2:	74 35                	je     800ad9 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800aa4:	89 d0                	mov    %edx,%eax
  800aa6:	83 e8 01             	sub    $0x1,%eax
  800aa9:	74 25                	je     800ad0 <strlcpy+0x40>
  800aab:	0f b6 0b             	movzbl (%ebx),%ecx
  800aae:	84 c9                	test   %cl,%cl
  800ab0:	74 22                	je     800ad4 <strlcpy+0x44>
  800ab2:	8d 53 01             	lea    0x1(%ebx),%edx
  800ab5:	01 c3                	add    %eax,%ebx
  800ab7:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800abf:	39 da                	cmp    %ebx,%edx
  800ac1:	74 13                	je     800ad6 <strlcpy+0x46>
  800ac3:	83 c2 01             	add    $0x1,%edx
  800ac6:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800aca:	84 c9                	test   %cl,%cl
  800acc:	75 eb                	jne    800ab9 <strlcpy+0x29>
  800ace:	eb 06                	jmp    800ad6 <strlcpy+0x46>
  800ad0:	89 f0                	mov    %esi,%eax
  800ad2:	eb 02                	jmp    800ad6 <strlcpy+0x46>
  800ad4:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ad6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad9:	29 f0                	sub    %esi,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae8:	0f b6 01             	movzbl (%ecx),%eax
  800aeb:	84 c0                	test   %al,%al
  800aed:	74 15                	je     800b04 <strcmp+0x25>
  800aef:	3a 02                	cmp    (%edx),%al
  800af1:	75 11                	jne    800b04 <strcmp+0x25>
		p++, q++;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af9:	0f b6 01             	movzbl (%ecx),%eax
  800afc:	84 c0                	test   %al,%al
  800afe:	74 04                	je     800b04 <strcmp+0x25>
  800b00:	3a 02                	cmp    (%edx),%al
  800b02:	74 ef                	je     800af3 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b04:	0f b6 c0             	movzbl %al,%eax
  800b07:	0f b6 12             	movzbl (%edx),%edx
  800b0a:	29 d0                	sub    %edx,%eax
}
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b19:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b1c:	85 f6                	test   %esi,%esi
  800b1e:	74 29                	je     800b49 <strncmp+0x3b>
  800b20:	0f b6 03             	movzbl (%ebx),%eax
  800b23:	84 c0                	test   %al,%al
  800b25:	74 30                	je     800b57 <strncmp+0x49>
  800b27:	3a 02                	cmp    (%edx),%al
  800b29:	75 2c                	jne    800b57 <strncmp+0x49>
  800b2b:	8d 43 01             	lea    0x1(%ebx),%eax
  800b2e:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b35:	39 c6                	cmp    %eax,%esi
  800b37:	74 17                	je     800b50 <strncmp+0x42>
  800b39:	0f b6 08             	movzbl (%eax),%ecx
  800b3c:	84 c9                	test   %cl,%cl
  800b3e:	74 17                	je     800b57 <strncmp+0x49>
  800b40:	83 c0 01             	add    $0x1,%eax
  800b43:	3a 0a                	cmp    (%edx),%cl
  800b45:	74 e9                	je     800b30 <strncmp+0x22>
  800b47:	eb 0e                	jmp    800b57 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4e:	eb 0f                	jmp    800b5f <strncmp+0x51>
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
  800b55:	eb 08                	jmp    800b5f <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b57:	0f b6 03             	movzbl (%ebx),%eax
  800b5a:	0f b6 12             	movzbl (%edx),%edx
  800b5d:	29 d0                	sub    %edx,%eax
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	53                   	push   %ebx
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	84 d2                	test   %dl,%dl
  800b72:	74 1d                	je     800b91 <strchr+0x2e>
  800b74:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b76:	38 d3                	cmp    %dl,%bl
  800b78:	75 06                	jne    800b80 <strchr+0x1d>
  800b7a:	eb 1a                	jmp    800b96 <strchr+0x33>
  800b7c:	38 ca                	cmp    %cl,%dl
  800b7e:	74 16                	je     800b96 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b80:	83 c0 01             	add    $0x1,%eax
  800b83:	0f b6 10             	movzbl (%eax),%edx
  800b86:	84 d2                	test   %dl,%dl
  800b88:	75 f2                	jne    800b7c <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8f:	eb 05                	jmp    800b96 <strchr+0x33>
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b96:	5b                   	pop    %ebx
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	53                   	push   %ebx
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ba3:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ba6:	38 d3                	cmp    %dl,%bl
  800ba8:	74 14                	je     800bbe <strfind+0x25>
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	84 db                	test   %bl,%bl
  800bae:	74 0e                	je     800bbe <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bb0:	83 c0 01             	add    $0x1,%eax
  800bb3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bb6:	38 ca                	cmp    %cl,%dl
  800bb8:	74 04                	je     800bbe <strfind+0x25>
  800bba:	84 d2                	test   %dl,%dl
  800bbc:	75 f2                	jne    800bb0 <strfind+0x17>
			break;
	return (char *) s;
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bcd:	85 c9                	test   %ecx,%ecx
  800bcf:	74 36                	je     800c07 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd7:	75 28                	jne    800c01 <memset+0x40>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 23                	jne    800c01 <memset+0x40>
		c &= 0xFF;
  800bde:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be2:	89 d3                	mov    %edx,%ebx
  800be4:	c1 e3 08             	shl    $0x8,%ebx
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	c1 e6 18             	shl    $0x18,%esi
  800bec:	89 d0                	mov    %edx,%eax
  800bee:	c1 e0 10             	shl    $0x10,%eax
  800bf1:	09 f0                	or     %esi,%eax
  800bf3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bf5:	89 d8                	mov    %ebx,%eax
  800bf7:	09 d0                	or     %edx,%eax
  800bf9:	c1 e9 02             	shr    $0x2,%ecx
  800bfc:	fc                   	cld    
  800bfd:	f3 ab                	rep stos %eax,%es:(%edi)
  800bff:	eb 06                	jmp    800c07 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c04:	fc                   	cld    
  800c05:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c07:	89 f8                	mov    %edi,%eax
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c19:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c1c:	39 c6                	cmp    %eax,%esi
  800c1e:	73 35                	jae    800c55 <memmove+0x47>
  800c20:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c23:	39 d0                	cmp    %edx,%eax
  800c25:	73 2e                	jae    800c55 <memmove+0x47>
		s += n;
		d += n;
  800c27:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2a:	89 d6                	mov    %edx,%esi
  800c2c:	09 fe                	or     %edi,%esi
  800c2e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c34:	75 13                	jne    800c49 <memmove+0x3b>
  800c36:	f6 c1 03             	test   $0x3,%cl
  800c39:	75 0e                	jne    800c49 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c3b:	83 ef 04             	sub    $0x4,%edi
  800c3e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c41:	c1 e9 02             	shr    $0x2,%ecx
  800c44:	fd                   	std    
  800c45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c47:	eb 09                	jmp    800c52 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c49:	83 ef 01             	sub    $0x1,%edi
  800c4c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c4f:	fd                   	std    
  800c50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c52:	fc                   	cld    
  800c53:	eb 1d                	jmp    800c72 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c55:	89 f2                	mov    %esi,%edx
  800c57:	09 c2                	or     %eax,%edx
  800c59:	f6 c2 03             	test   $0x3,%dl
  800c5c:	75 0f                	jne    800c6d <memmove+0x5f>
  800c5e:	f6 c1 03             	test   $0x3,%cl
  800c61:	75 0a                	jne    800c6d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c63:	c1 e9 02             	shr    $0x2,%ecx
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	fc                   	cld    
  800c69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6b:	eb 05                	jmp    800c72 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c6d:	89 c7                	mov    %eax,%edi
  800c6f:	fc                   	cld    
  800c70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c79:	ff 75 10             	pushl  0x10(%ebp)
  800c7c:	ff 75 0c             	pushl  0xc(%ebp)
  800c7f:	ff 75 08             	pushl  0x8(%ebp)
  800c82:	e8 87 ff ff ff       	call   800c0e <memmove>
}
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    

00800c89 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c95:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	74 39                	je     800cd5 <memcmp+0x4c>
  800c9c:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c9f:	0f b6 13             	movzbl (%ebx),%edx
  800ca2:	0f b6 0e             	movzbl (%esi),%ecx
  800ca5:	38 ca                	cmp    %cl,%dl
  800ca7:	75 17                	jne    800cc0 <memcmp+0x37>
  800ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cae:	eb 1a                	jmp    800cca <memcmp+0x41>
  800cb0:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800cb5:	83 c0 01             	add    $0x1,%eax
  800cb8:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cbc:	38 ca                	cmp    %cl,%dl
  800cbe:	74 0a                	je     800cca <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cc0:	0f b6 c2             	movzbl %dl,%eax
  800cc3:	0f b6 c9             	movzbl %cl,%ecx
  800cc6:	29 c8                	sub    %ecx,%eax
  800cc8:	eb 10                	jmp    800cda <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cca:	39 f8                	cmp    %edi,%eax
  800ccc:	75 e2                	jne    800cb0 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd3:	eb 05                	jmp    800cda <memcmp+0x51>
  800cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	53                   	push   %ebx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800ce6:	89 d0                	mov    %edx,%eax
  800ce8:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800ceb:	39 c2                	cmp    %eax,%edx
  800ced:	73 1d                	jae    800d0c <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cef:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800cf3:	0f b6 0a             	movzbl (%edx),%ecx
  800cf6:	39 d9                	cmp    %ebx,%ecx
  800cf8:	75 09                	jne    800d03 <memfind+0x24>
  800cfa:	eb 14                	jmp    800d10 <memfind+0x31>
  800cfc:	0f b6 0a             	movzbl (%edx),%ecx
  800cff:	39 d9                	cmp    %ebx,%ecx
  800d01:	74 11                	je     800d14 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d03:	83 c2 01             	add    $0x1,%edx
  800d06:	39 d0                	cmp    %edx,%eax
  800d08:	75 f2                	jne    800cfc <memfind+0x1d>
  800d0a:	eb 0a                	jmp    800d16 <memfind+0x37>
  800d0c:	89 d0                	mov    %edx,%eax
  800d0e:	eb 06                	jmp    800d16 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d10:	89 d0                	mov    %edx,%eax
  800d12:	eb 02                	jmp    800d16 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d14:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d16:	5b                   	pop    %ebx
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d25:	0f b6 01             	movzbl (%ecx),%eax
  800d28:	3c 20                	cmp    $0x20,%al
  800d2a:	74 04                	je     800d30 <strtol+0x17>
  800d2c:	3c 09                	cmp    $0x9,%al
  800d2e:	75 0e                	jne    800d3e <strtol+0x25>
		s++;
  800d30:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d33:	0f b6 01             	movzbl (%ecx),%eax
  800d36:	3c 20                	cmp    $0x20,%al
  800d38:	74 f6                	je     800d30 <strtol+0x17>
  800d3a:	3c 09                	cmp    $0x9,%al
  800d3c:	74 f2                	je     800d30 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d3e:	3c 2b                	cmp    $0x2b,%al
  800d40:	75 0a                	jne    800d4c <strtol+0x33>
		s++;
  800d42:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d45:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4a:	eb 11                	jmp    800d5d <strtol+0x44>
  800d4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d51:	3c 2d                	cmp    $0x2d,%al
  800d53:	75 08                	jne    800d5d <strtol+0x44>
		s++, neg = 1;
  800d55:	83 c1 01             	add    $0x1,%ecx
  800d58:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d63:	75 15                	jne    800d7a <strtol+0x61>
  800d65:	80 39 30             	cmpb   $0x30,(%ecx)
  800d68:	75 10                	jne    800d7a <strtol+0x61>
  800d6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d6e:	75 7c                	jne    800dec <strtol+0xd3>
		s += 2, base = 16;
  800d70:	83 c1 02             	add    $0x2,%ecx
  800d73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d78:	eb 16                	jmp    800d90 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d7a:	85 db                	test   %ebx,%ebx
  800d7c:	75 12                	jne    800d90 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d83:	80 39 30             	cmpb   $0x30,(%ecx)
  800d86:	75 08                	jne    800d90 <strtol+0x77>
		s++, base = 8;
  800d88:	83 c1 01             	add    $0x1,%ecx
  800d8b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d90:	b8 00 00 00 00       	mov    $0x0,%eax
  800d95:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d98:	0f b6 11             	movzbl (%ecx),%edx
  800d9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d9e:	89 f3                	mov    %esi,%ebx
  800da0:	80 fb 09             	cmp    $0x9,%bl
  800da3:	77 08                	ja     800dad <strtol+0x94>
			dig = *s - '0';
  800da5:	0f be d2             	movsbl %dl,%edx
  800da8:	83 ea 30             	sub    $0x30,%edx
  800dab:	eb 22                	jmp    800dcf <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800dad:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db0:	89 f3                	mov    %esi,%ebx
  800db2:	80 fb 19             	cmp    $0x19,%bl
  800db5:	77 08                	ja     800dbf <strtol+0xa6>
			dig = *s - 'a' + 10;
  800db7:	0f be d2             	movsbl %dl,%edx
  800dba:	83 ea 57             	sub    $0x57,%edx
  800dbd:	eb 10                	jmp    800dcf <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800dbf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc2:	89 f3                	mov    %esi,%ebx
  800dc4:	80 fb 19             	cmp    $0x19,%bl
  800dc7:	77 16                	ja     800ddf <strtol+0xc6>
			dig = *s - 'A' + 10;
  800dc9:	0f be d2             	movsbl %dl,%edx
  800dcc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800dcf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dd2:	7d 0b                	jge    800ddf <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800dd4:	83 c1 01             	add    $0x1,%ecx
  800dd7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ddb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ddd:	eb b9                	jmp    800d98 <strtol+0x7f>

	if (endptr)
  800ddf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de3:	74 0d                	je     800df2 <strtol+0xd9>
		*endptr = (char *) s;
  800de5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de8:	89 0e                	mov    %ecx,(%esi)
  800dea:	eb 06                	jmp    800df2 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dec:	85 db                	test   %ebx,%ebx
  800dee:	74 98                	je     800d88 <strtol+0x6f>
  800df0:	eb 9e                	jmp    800d90 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	f7 da                	neg    %edx
  800df6:	85 ff                	test   %edi,%edi
  800df8:	0f 45 c2             	cmovne %edx,%eax
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e05:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	89 c7                	mov    %eax,%edi
  800e14:	51                   	push   %ecx
  800e15:	52                   	push   %edx
  800e16:	53                   	push   %ebx
  800e17:	56                   	push   %esi
  800e18:	57                   	push   %edi
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	8d 35 24 0e 80 00    	lea    0x800e24,%esi
  800e22:	0f 34                	sysenter 

00800e24 <label_21>:
  800e24:	89 ec                	mov    %ebp,%esp
  800e26:	5d                   	pop    %ebp
  800e27:	5f                   	pop    %edi
  800e28:	5e                   	pop    %esi
  800e29:	5b                   	pop    %ebx
  800e2a:	5a                   	pop    %edx
  800e2b:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3f:	89 ca                	mov    %ecx,%edx
  800e41:	89 cb                	mov    %ecx,%ebx
  800e43:	89 cf                	mov    %ecx,%edi
  800e45:	51                   	push   %ecx
  800e46:	52                   	push   %edx
  800e47:	53                   	push   %ebx
  800e48:	56                   	push   %esi
  800e49:	57                   	push   %edi
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	8d 35 55 0e 80 00    	lea    0x800e55,%esi
  800e53:	0f 34                	sysenter 

00800e55 <label_55>:
  800e55:	89 ec                	mov    %ebp,%esp
  800e57:	5d                   	pop    %ebp
  800e58:	5f                   	pop    %edi
  800e59:	5e                   	pop    %esi
  800e5a:	5b                   	pop    %ebx
  800e5b:	5a                   	pop    %edx
  800e5c:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e5d:	5b                   	pop    %ebx
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 d9                	mov    %ebx,%ecx
  800e75:	89 df                	mov    %ebx,%edi
  800e77:	51                   	push   %ecx
  800e78:	52                   	push   %edx
  800e79:	53                   	push   %ebx
  800e7a:	56                   	push   %esi
  800e7b:	57                   	push   %edi
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	8d 35 87 0e 80 00    	lea    0x800e87,%esi
  800e85:	0f 34                	sysenter 

00800e87 <label_90>:
  800e87:	89 ec                	mov    %ebp,%esp
  800e89:	5d                   	pop    %ebp
  800e8a:	5f                   	pop    %edi
  800e8b:	5e                   	pop    %esi
  800e8c:	5b                   	pop    %ebx
  800e8d:	5a                   	pop    %edx
  800e8e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7e 17                	jle    800eaa <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	50                   	push   %eax
  800e97:	6a 03                	push   $0x3
  800e99:	68 84 1b 80 00       	push   $0x801b84
  800e9e:	6a 30                	push   $0x30
  800ea0:	68 a1 1b 80 00       	push   $0x801ba1
  800ea5:	e8 4a 06 00 00       	call   8014f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebb:	b8 02 00 00 00       	mov    $0x2,%eax
  800ec0:	89 ca                	mov    %ecx,%edx
  800ec2:	89 cb                	mov    %ecx,%ebx
  800ec4:	89 cf                	mov    %ecx,%edi
  800ec6:	51                   	push   %ecx
  800ec7:	52                   	push   %edx
  800ec8:	53                   	push   %ebx
  800ec9:	56                   	push   %esi
  800eca:	57                   	push   %edi
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	8d 35 d6 0e 80 00    	lea    0x800ed6,%esi
  800ed4:	0f 34                	sysenter 

00800ed6 <label_139>:
  800ed6:	89 ec                	mov    %ebp,%esp
  800ed8:	5d                   	pop    %ebp
  800ed9:	5f                   	pop    %edi
  800eda:	5e                   	pop    %esi
  800edb:	5b                   	pop    %ebx
  800edc:	5a                   	pop    %edx
  800edd:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ede:	5b                   	pop    %ebx
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ee7:	bf 00 00 00 00       	mov    $0x0,%edi
  800eec:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	89 fb                	mov    %edi,%ebx
  800ef9:	51                   	push   %ecx
  800efa:	52                   	push   %edx
  800efb:	53                   	push   %ebx
  800efc:	56                   	push   %esi
  800efd:	57                   	push   %edi
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	8d 35 09 0f 80 00    	lea    0x800f09,%esi
  800f07:	0f 34                	sysenter 

00800f09 <label_174>:
  800f09:	89 ec                	mov    %ebp,%esp
  800f0b:	5d                   	pop    %ebp
  800f0c:	5f                   	pop    %edi
  800f0d:	5e                   	pop    %esi
  800f0e:	5b                   	pop    %ebx
  800f0f:	5a                   	pop    %edx
  800f10:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f11:	5b                   	pop    %ebx
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <sys_yield>:

void
sys_yield(void)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f24:	89 d1                	mov    %edx,%ecx
  800f26:	89 d3                	mov    %edx,%ebx
  800f28:	89 d7                	mov    %edx,%edi
  800f2a:	51                   	push   %ecx
  800f2b:	52                   	push   %edx
  800f2c:	53                   	push   %ebx
  800f2d:	56                   	push   %esi
  800f2e:	57                   	push   %edi
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	8d 35 3a 0f 80 00    	lea    0x800f3a,%esi
  800f38:	0f 34                	sysenter 

00800f3a <label_209>:
  800f3a:	89 ec                	mov    %ebp,%esp
  800f3c:	5d                   	pop    %ebp
  800f3d:	5f                   	pop    %edi
  800f3e:	5e                   	pop    %esi
  800f3f:	5b                   	pop    %ebx
  800f40:	5a                   	pop    %edx
  800f41:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f42:	5b                   	pop    %ebx
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f50:	b8 05 00 00 00       	mov    $0x5,%eax
  800f55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5e:	51                   	push   %ecx
  800f5f:	52                   	push   %edx
  800f60:	53                   	push   %ebx
  800f61:	56                   	push   %esi
  800f62:	57                   	push   %edi
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	8d 35 6e 0f 80 00    	lea    0x800f6e,%esi
  800f6c:	0f 34                	sysenter 

00800f6e <label_244>:
  800f6e:	89 ec                	mov    %ebp,%esp
  800f70:	5d                   	pop    %ebp
  800f71:	5f                   	pop    %edi
  800f72:	5e                   	pop    %esi
  800f73:	5b                   	pop    %ebx
  800f74:	5a                   	pop    %edx
  800f75:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	7e 17                	jle    800f91 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	50                   	push   %eax
  800f7e:	6a 05                	push   $0x5
  800f80:	68 84 1b 80 00       	push   $0x801b84
  800f85:	6a 30                	push   $0x30
  800f87:	68 a1 1b 80 00       	push   $0x801ba1
  800f8c:	e8 63 05 00 00       	call   8014f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5f                   	pop    %edi
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	57                   	push   %edi
  800f9c:	53                   	push   %ebx
  800f9d:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa9:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800fac:	8b 45 10             	mov    0x10(%ebp),%eax
  800faf:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800fb2:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800fb8:	8b 45 18             	mov    0x18(%ebp),%eax
  800fbb:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fbe:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800fc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc6:	b8 06 00 00 00       	mov    $0x6,%eax
  800fcb:	89 cb                	mov    %ecx,%ebx
  800fcd:	89 cf                	mov    %ecx,%edi
  800fcf:	51                   	push   %ecx
  800fd0:	52                   	push   %edx
  800fd1:	53                   	push   %ebx
  800fd2:	56                   	push   %esi
  800fd3:	57                   	push   %edi
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	8d 35 df 0f 80 00    	lea    0x800fdf,%esi
  800fdd:	0f 34                	sysenter 

00800fdf <label_304>:
  800fdf:	89 ec                	mov    %ebp,%esp
  800fe1:	5d                   	pop    %ebp
  800fe2:	5f                   	pop    %edi
  800fe3:	5e                   	pop    %esi
  800fe4:	5b                   	pop    %ebx
  800fe5:	5a                   	pop    %edx
  800fe6:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	7e 17                	jle    801002 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	50                   	push   %eax
  800fef:	6a 06                	push   $0x6
  800ff1:	68 84 1b 80 00       	push   $0x801b84
  800ff6:	6a 30                	push   $0x30
  800ff8:	68 a1 1b 80 00       	push   $0x801ba1
  800ffd:	e8 f2 04 00 00       	call   8014f4 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  801002:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801005:	5b                   	pop    %ebx
  801006:	5f                   	pop    %edi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	57                   	push   %edi
  80100d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80100e:	bf 00 00 00 00       	mov    $0x0,%edi
  801013:	b8 07 00 00 00       	mov    $0x7,%eax
  801018:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	89 fb                	mov    %edi,%ebx
  801020:	51                   	push   %ecx
  801021:	52                   	push   %edx
  801022:	53                   	push   %ebx
  801023:	56                   	push   %esi
  801024:	57                   	push   %edi
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	8d 35 30 10 80 00    	lea    0x801030,%esi
  80102e:	0f 34                	sysenter 

00801030 <label_353>:
  801030:	89 ec                	mov    %ebp,%esp
  801032:	5d                   	pop    %ebp
  801033:	5f                   	pop    %edi
  801034:	5e                   	pop    %esi
  801035:	5b                   	pop    %ebx
  801036:	5a                   	pop    %edx
  801037:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801038:	85 c0                	test   %eax,%eax
  80103a:	7e 17                	jle    801053 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	50                   	push   %eax
  801040:	6a 07                	push   $0x7
  801042:	68 84 1b 80 00       	push   $0x801b84
  801047:	6a 30                	push   $0x30
  801049:	68 a1 1b 80 00       	push   $0x801ba1
  80104e:	e8 a1 04 00 00       	call   8014f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801053:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801056:	5b                   	pop    %ebx
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	57                   	push   %edi
  80105e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80105f:	bf 00 00 00 00       	mov    $0x0,%edi
  801064:	b8 09 00 00 00       	mov    $0x9,%eax
  801069:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106c:	8b 55 08             	mov    0x8(%ebp),%edx
  80106f:	89 fb                	mov    %edi,%ebx
  801071:	51                   	push   %ecx
  801072:	52                   	push   %edx
  801073:	53                   	push   %ebx
  801074:	56                   	push   %esi
  801075:	57                   	push   %edi
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	8d 35 81 10 80 00    	lea    0x801081,%esi
  80107f:	0f 34                	sysenter 

00801081 <label_402>:
  801081:	89 ec                	mov    %ebp,%esp
  801083:	5d                   	pop    %ebp
  801084:	5f                   	pop    %edi
  801085:	5e                   	pop    %esi
  801086:	5b                   	pop    %ebx
  801087:	5a                   	pop    %edx
  801088:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	7e 17                	jle    8010a4 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	50                   	push   %eax
  801091:	6a 09                	push   $0x9
  801093:	68 84 1b 80 00       	push   $0x801b84
  801098:	6a 30                	push   $0x30
  80109a:	68 a1 1b 80 00       	push   $0x801ba1
  80109f:	e8 50 04 00 00       	call   8014f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8010b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c0:	89 fb                	mov    %edi,%ebx
  8010c2:	51                   	push   %ecx
  8010c3:	52                   	push   %edx
  8010c4:	53                   	push   %ebx
  8010c5:	56                   	push   %esi
  8010c6:	57                   	push   %edi
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	8d 35 d2 10 80 00    	lea    0x8010d2,%esi
  8010d0:	0f 34                	sysenter 

008010d2 <label_451>:
  8010d2:	89 ec                	mov    %ebp,%esp
  8010d4:	5d                   	pop    %ebp
  8010d5:	5f                   	pop    %edi
  8010d6:	5e                   	pop    %esi
  8010d7:	5b                   	pop    %ebx
  8010d8:	5a                   	pop    %edx
  8010d9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	7e 17                	jle    8010f5 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	50                   	push   %eax
  8010e2:	6a 0a                	push   $0xa
  8010e4:	68 84 1b 80 00       	push   $0x801b84
  8010e9:	6a 30                	push   $0x30
  8010eb:	68 a1 1b 80 00       	push   $0x801ba1
  8010f0:	e8 ff 03 00 00       	call   8014f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5f                   	pop    %edi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801101:	b8 0c 00 00 00       	mov    $0xc,%eax
  801106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801109:	8b 55 08             	mov    0x8(%ebp),%edx
  80110c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801112:	51                   	push   %ecx
  801113:	52                   	push   %edx
  801114:	53                   	push   %ebx
  801115:	56                   	push   %esi
  801116:	57                   	push   %edi
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	8d 35 22 11 80 00    	lea    0x801122,%esi
  801120:	0f 34                	sysenter 

00801122 <label_502>:
  801122:	89 ec                	mov    %ebp,%esp
  801124:	5d                   	pop    %ebp
  801125:	5f                   	pop    %edi
  801126:	5e                   	pop    %esi
  801127:	5b                   	pop    %ebx
  801128:	5a                   	pop    %edx
  801129:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80112a:	5b                   	pop    %ebx
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801133:	bb 00 00 00 00       	mov    $0x0,%ebx
  801138:	b8 0d 00 00 00       	mov    $0xd,%eax
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx
  801140:	89 d9                	mov    %ebx,%ecx
  801142:	89 df                	mov    %ebx,%edi
  801144:	51                   	push   %ecx
  801145:	52                   	push   %edx
  801146:	53                   	push   %ebx
  801147:	56                   	push   %esi
  801148:	57                   	push   %edi
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	8d 35 54 11 80 00    	lea    0x801154,%esi
  801152:	0f 34                	sysenter 

00801154 <label_537>:
  801154:	89 ec                	mov    %ebp,%esp
  801156:	5d                   	pop    %ebp
  801157:	5f                   	pop    %edi
  801158:	5e                   	pop    %esi
  801159:	5b                   	pop    %ebx
  80115a:	5a                   	pop    %edx
  80115b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80115c:	85 c0                	test   %eax,%eax
  80115e:	7e 17                	jle    801177 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	50                   	push   %eax
  801164:	6a 0d                	push   $0xd
  801166:	68 84 1b 80 00       	push   $0x801b84
  80116b:	6a 30                	push   $0x30
  80116d:	68 a1 1b 80 00       	push   $0x801ba1
  801172:	e8 7d 03 00 00       	call   8014f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801177:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801183:	b9 00 00 00 00       	mov    $0x0,%ecx
  801188:	b8 0e 00 00 00       	mov    $0xe,%eax
  80118d:	8b 55 08             	mov    0x8(%ebp),%edx
  801190:	89 cb                	mov    %ecx,%ebx
  801192:	89 cf                	mov    %ecx,%edi
  801194:	51                   	push   %ecx
  801195:	52                   	push   %edx
  801196:	53                   	push   %ebx
  801197:	56                   	push   %esi
  801198:	57                   	push   %edi
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	8d 35 a4 11 80 00    	lea    0x8011a4,%esi
  8011a2:	0f 34                	sysenter 

008011a4 <label_586>:
  8011a4:	89 ec                	mov    %ebp,%esp
  8011a6:	5d                   	pop    %ebp
  8011a7:	5f                   	pop    %edi
  8011a8:	5e                   	pop    %esi
  8011a9:	5b                   	pop    %ebx
  8011aa:	5a                   	pop    %edx
  8011ab:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8011ac:	5b                   	pop    %ebx
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	53                   	push   %ebx
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011ba:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(vpd[PDX(addr)] & PTE_P) || !(vpt[PGNUM(addr)] & PTE_COW)) {
  8011bc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011c0:	74 21                	je     8011e3 <pgfault+0x33>
  8011c2:	89 d8                	mov    %ebx,%eax
  8011c4:	c1 e8 16             	shr    $0x16,%eax
  8011c7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011ce:	a8 01                	test   $0x1,%al
  8011d0:	74 11                	je     8011e3 <pgfault+0x33>
  8011d2:	89 d8                	mov    %ebx,%eax
  8011d4:	c1 e8 0c             	shr    $0xc,%eax
  8011d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011de:	f6 c4 08             	test   $0x8,%ah
  8011e1:	75 14                	jne    8011f7 <pgfault+0x47>
		panic("Faulting access is not a write to COW page.");
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	68 b0 1b 80 00       	push   $0x801bb0
  8011eb:	6a 1d                	push   $0x1d
  8011ed:	68 ba 1c 80 00       	push   $0x801cba
  8011f2:	e8 fd 02 00 00       	call   8014f4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_U | PTE_W | PTE_P);
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	6a 07                	push   $0x7
  8011fc:	68 00 f0 7f 00       	push   $0x7ff000
  801201:	6a 00                	push   $0x0
  801203:	e8 3e fd ff ff       	call   800f46 <sys_page_alloc>
	if (r) {
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	74 12                	je     801221 <pgfault+0x71>
		panic("pgfault alloc new page failed %e", r);
  80120f:	50                   	push   %eax
  801210:	68 dc 1b 80 00       	push   $0x801bdc
  801215:	6a 2a                	push   $0x2a
  801217:	68 ba 1c 80 00       	push   $0x801cba
  80121c:	e8 d3 02 00 00       	call   8014f4 <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801221:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	68 00 10 00 00       	push   $0x1000
  80122f:	53                   	push   %ebx
  801230:	68 00 f0 7f 00       	push   $0x7ff000
  801235:	e8 d4 f9 ff ff       	call   800c0e <memmove>
	r = sys_page_map(0, (void *)PFTEMP,
  80123a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801241:	53                   	push   %ebx
  801242:	6a 00                	push   $0x0
  801244:	68 00 f0 7f 00       	push   $0x7ff000
  801249:	6a 00                	push   $0x0
  80124b:	e8 48 fd ff ff       	call   800f98 <sys_page_map>
				0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_W | PTE_P);
	if (r) {
  801250:	83 c4 20             	add    $0x20,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	74 12                	je     801269 <pgfault+0xb9>
		panic("pgfault map pages failed %e", r);
  801257:	50                   	push   %eax
  801258:	68 c5 1c 80 00       	push   $0x801cc5
  80125d:	6a 30                	push   $0x30
  80125f:	68 ba 1c 80 00       	push   $0x801cba
  801264:	e8 8b 02 00 00       	call   8014f4 <_panic>
	}
	// panic("pgfault not implemented");
}
  801269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801277:	68 b0 11 80 00       	push   $0x8011b0
  80127c:	e8 d3 02 00 00       	call   801554 <set_pgfault_handler>
	// 	: "a" (SYS_exofork),
	// 	  "i" (T_SYSCALL)
	// );
	// return ret;
	envid_t ret;
	asm volatile("pushl %%ecx\n\t"
  801281:	b8 08 00 00 00       	mov    $0x8,%eax
  801286:	51                   	push   %ecx
  801287:	52                   	push   %edx
  801288:	53                   	push   %ebx
  801289:	56                   	push   %esi
  80128a:	57                   	push   %edi
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	8d 35 96 12 80 00    	lea    0x801296,%esi
  801294:	0f 34                	sysenter 

00801296 <label_116>:
  801296:	89 ec                	mov    %ebp,%esp
  801298:	5d                   	pop    %ebp
  801299:	5f                   	pop    %edi
  80129a:	5e                   	pop    %esi
  80129b:	5b                   	pop    %ebx
  80129c:	5a                   	pop    %edx
  80129d:	59                   	pop    %ecx
  80129e:	89 c7                	mov    %eax,%edi
  8012a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
							: "=a" (ret)
							: "a" (SYS_exofork),
								"i" (T_SYSCALL)
							: "cc", "memory");

	if(ret == -E_NO_FREE_ENV || ret == -E_NO_MEM)
  8012a3:	8d 40 05             	lea    0x5(%eax),%eax
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	83 f8 01             	cmp    $0x1,%eax
  8012ac:	77 17                	ja     8012c5 <label_116+0x2f>
		panic("syscall %d returned %d (> 0)", SYS_exofork, ret);
  8012ae:	83 ec 0c             	sub    $0xc,%esp
  8012b1:	57                   	push   %edi
  8012b2:	6a 08                	push   $0x8
  8012b4:	68 84 1b 80 00       	push   $0x801b84
  8012b9:	6a 62                	push   $0x62
  8012bb:	68 e1 1c 80 00       	push   $0x801ce1
  8012c0:	e8 2f 02 00 00       	call   8014f4 <_panic>

	int r;
	envid_t child_id;
	child_id = sys_exofork();
	if (child_id < 0) {
  8012c5:	85 ff                	test   %edi,%edi
  8012c7:	0f 88 83 01 00 00    	js     801450 <label_116+0x1ba>
  8012cd:	bb 00 08 00 00       	mov    $0x800,%ebx
		return -1;
	} else if (!child_id) {
  8012d2:	85 ff                	test   %edi,%edi
  8012d4:	75 21                	jne    8012f7 <label_116+0x61>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012d6:	e8 d6 fb ff ff       	call   800eb1 <sys_getenvid>
  8012db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012e0:	c1 e0 07             	shl    $0x7,%eax
  8012e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012e8:	a3 10 20 80 00       	mov    %eax,0x802010
		return 0;
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f2:	e9 62 01 00 00       	jmp    801459 <label_116+0x1c3>
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
			if ((vpd[pn / NPTENTRIES] & PTE_P) &&
  8012f7:	89 d8                	mov    %ebx,%eax
  8012f9:	c1 e8 0a             	shr    $0xa,%eax
  8012fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801303:	a8 01                	test   $0x1,%al
  801305:	0f 84 b9 00 00 00    	je     8013c4 <label_116+0x12e>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
  80130b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
			if ((vpd[pn / NPTENTRIES] & PTE_P) &&
  801312:	a8 01                	test   $0x1,%al
  801314:	0f 84 aa 00 00 00    	je     8013c4 <label_116+0x12e>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
  80131a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801321:	a8 04                	test   $0x4,%al
  801323:	0f 84 9b 00 00 00    	je     8013c4 <label_116+0x12e>
  801329:	89 de                	mov    %ebx,%esi
  80132b:	c1 e6 0c             	shl    $0xc,%esi
	int r;

	// LAB 4: Your code here.
	int perm = PTE_U | PTE_P;
	void *pn_addr = (void *)(pn * PGSIZE);
	pte_t pte = vpt[PGNUM(pn_addr)];
  80132e:	89 f0                	mov    %esi,%eax
  801330:	c1 e8 0c             	shr    $0xc,%eax
  801333:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((pte & PTE_COW) || (pte & PTE_W)) {
  80133a:	a9 02 08 00 00       	test   $0x802,%eax
  80133f:	74 59                	je     80139a <label_116+0x104>
		perm |= PTE_COW;
		r = sys_page_map(0, pn_addr, envid, pn_addr, perm);
  801341:	83 ec 0c             	sub    $0xc,%esp
  801344:	68 05 08 00 00       	push   $0x805
  801349:	56                   	push   %esi
  80134a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80134d:	56                   	push   %esi
  80134e:	6a 00                	push   $0x0
  801350:	e8 43 fc ff ff       	call   800f98 <sys_page_map>
		if (r) {
  801355:	83 c4 20             	add    $0x20,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	74 12                	je     80136e <label_116+0xd8>
			panic("duppage sys_page_map 1/2 failed %e", r);
  80135c:	50                   	push   %eax
  80135d:	68 00 1c 80 00       	push   $0x801c00
  801362:	6a 4d                	push   $0x4d
  801364:	68 ba 1c 80 00       	push   $0x801cba
  801369:	e8 86 01 00 00       	call   8014f4 <_panic>
		}
		// TODO: Still don't know why
		r = sys_page_map(0, pn_addr, 0, pn_addr, perm);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	68 05 08 00 00       	push   $0x805
  801376:	56                   	push   %esi
  801377:	6a 00                	push   $0x0
  801379:	56                   	push   %esi
  80137a:	6a 00                	push   $0x0
  80137c:	e8 17 fc ff ff       	call   800f98 <sys_page_map>
		if (r) {
  801381:	83 c4 20             	add    $0x20,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	74 3c                	je     8013c4 <label_116+0x12e>
			panic("duppage sys_page_map 2/2 failed %e", r);
  801388:	50                   	push   %eax
  801389:	68 24 1c 80 00       	push   $0x801c24
  80138e:	6a 52                	push   $0x52
  801390:	68 ba 1c 80 00       	push   $0x801cba
  801395:	e8 5a 01 00 00       	call   8014f4 <_panic>
		}
	} else {
		r = sys_page_map(0, pn_addr, envid, pn_addr, perm);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	6a 05                	push   $0x5
  80139f:	56                   	push   %esi
  8013a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a3:	56                   	push   %esi
  8013a4:	6a 00                	push   $0x0
  8013a6:	e8 ed fb ff ff       	call   800f98 <sys_page_map>
		if (r) {
  8013ab:	83 c4 20             	add    $0x20,%esp
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	74 12                	je     8013c4 <label_116+0x12e>
			panic("duppage sys_page_map 1/1 failed %e", r);
  8013b2:	50                   	push   %eax
  8013b3:	68 48 1c 80 00       	push   $0x801c48
  8013b8:	6a 57                	push   $0x57
  8013ba:	68 ba 1c 80 00       	push   $0x801cba
  8013bf:	e8 30 01 00 00       	call   8014f4 <_panic>
	} else {
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
  8013c4:	83 c3 01             	add    $0x1,%ebx
  8013c7:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8013cd:	0f 85 24 ff ff ff    	jne    8012f7 <label_116+0x61>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
				duppage(child_id, pn);
			}
		}

		r = sys_page_alloc(child_id, (void *)(UTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8013d3:	83 ec 04             	sub    $0x4,%esp
  8013d6:	6a 07                	push   $0x7
  8013d8:	68 00 f0 bf ee       	push   $0xeebff000
  8013dd:	57                   	push   %edi
  8013de:	e8 63 fb ff ff       	call   800f46 <sys_page_alloc>
		if (r) {
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	74 15                	je     8013ff <label_116+0x169>
			panic("fork sys_page_alloc failed %e", r);
  8013ea:	50                   	push   %eax
  8013eb:	68 ed 1c 80 00       	push   $0x801ced
  8013f0:	68 8a 00 00 00       	push   $0x8a
  8013f5:	68 ba 1c 80 00       	push   $0x801cba
  8013fa:	e8 f5 00 00 00       	call   8014f4 <_panic>
		}

		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	68 a9 15 80 00       	push   $0x8015a9
  801407:	57                   	push   %edi
  801408:	e8 9e fc ff ff       	call   8010ab <sys_env_set_pgfault_upcall>
		if (r) {
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	74 15                	je     801429 <label_116+0x193>
			panic("fork sys_env_set_pgfault_upcall failed %e", r);
  801414:	50                   	push   %eax
  801415:	68 6c 1c 80 00       	push   $0x801c6c
  80141a:	68 90 00 00 00       	push   $0x90
  80141f:	68 ba 1c 80 00       	push   $0x801cba
  801424:	e8 cb 00 00 00       	call   8014f4 <_panic>
		}

		r = sys_env_set_status(child_id, ENV_RUNNABLE);
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	6a 02                	push   $0x2
  80142e:	57                   	push   %edi
  80142f:	e8 26 fc ff ff       	call   80105a <sys_env_set_status>
		if (r) {
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	74 1c                	je     801457 <label_116+0x1c1>
			panic("fork sys_env_set_status failed %e", r);
  80143b:	50                   	push   %eax
  80143c:	68 98 1c 80 00       	push   $0x801c98
  801441:	68 95 00 00 00       	push   $0x95
  801446:	68 ba 1c 80 00       	push   $0x801cba
  80144b:	e8 a4 00 00 00       	call   8014f4 <_panic>

	int r;
	envid_t child_id;
	child_id = sys_exofork();
	if (child_id < 0) {
		return -1;
  801450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801455:	eb 02                	jmp    801459 <label_116+0x1c3>

		r = sys_env_set_status(child_id, ENV_RUNNABLE);
		if (r) {
			panic("fork sys_env_set_status failed %e", r);
		}
		return child_id;
  801457:	89 f8                	mov    %edi,%eax
	}
	// panic("fork not implemented");
}
  801459:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145c:	5b                   	pop    %ebx
  80145d:	5e                   	pop    %esi
  80145e:	5f                   	pop    %edi
  80145f:	5d                   	pop    %ebp
  801460:	c3                   	ret    

00801461 <sfork>:

// Challenge!
int
sfork(void)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801467:	68 0b 1d 80 00       	push   $0x801d0b
  80146c:	68 a0 00 00 00       	push   $0xa0
  801471:	68 ba 1c 80 00       	push   $0x801cba
  801476:	e8 79 00 00 00       	call   8014f4 <_panic>

0080147b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801481:	68 21 1d 80 00       	push   $0x801d21
  801486:	6a 1a                	push   $0x1a
  801488:	68 3a 1d 80 00       	push   $0x801d3a
  80148d:	e8 62 00 00 00       	call   8014f4 <_panic>

00801492 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801498:	68 44 1d 80 00       	push   $0x801d44
  80149d:	6a 2a                	push   $0x2a
  80149f:	68 3a 1d 80 00       	push   $0x801d3a
  8014a4:	e8 4b 00 00 00       	call   8014f4 <_panic>

008014a9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8014af:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8014b4:	39 c1                	cmp    %eax,%ecx
  8014b6:	74 19                	je     8014d1 <ipc_find_env+0x28>
  8014b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bd:	89 c2                	mov    %eax,%edx
  8014bf:	c1 e2 07             	shl    $0x7,%edx
  8014c2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014c8:	8b 52 50             	mov    0x50(%edx),%edx
  8014cb:	39 ca                	cmp    %ecx,%edx
  8014cd:	75 14                	jne    8014e3 <ipc_find_env+0x3a>
  8014cf:	eb 05                	jmp    8014d6 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014d1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8014d6:	c1 e0 07             	shl    $0x7,%eax
  8014d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014de:	8b 40 48             	mov    0x48(%eax),%eax
  8014e1:	eb 0f                	jmp    8014f2 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014e3:	83 c0 01             	add    $0x1,%eax
  8014e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014eb:	75 d0                	jne    8014bd <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8014fc:	a1 14 20 80 00       	mov    0x802014,%eax
  801501:	85 c0                	test   %eax,%eax
  801503:	74 11                	je     801516 <_panic+0x22>
		cprintf("%s: ", argv0);
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	50                   	push   %eax
  801509:	68 5d 1d 80 00       	push   $0x801d5d
  80150e:	e8 d6 ec ff ff       	call   8001e9 <cprintf>
  801513:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801516:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80151c:	e8 90 f9 ff ff       	call   800eb1 <sys_getenvid>
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	ff 75 08             	pushl  0x8(%ebp)
  80152a:	56                   	push   %esi
  80152b:	50                   	push   %eax
  80152c:	68 64 1d 80 00       	push   $0x801d64
  801531:	e8 b3 ec ff ff       	call   8001e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801536:	83 c4 18             	add    $0x18,%esp
  801539:	53                   	push   %ebx
  80153a:	ff 75 10             	pushl  0x10(%ebp)
  80153d:	e8 56 ec ff ff       	call   800198 <vcprintf>
	cprintf("\n");
  801542:	c7 04 24 9f 1d 80 00 	movl   $0x801d9f,(%esp)
  801549:	e8 9b ec ff ff       	call   8001e9 <cprintf>
  80154e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801551:	cc                   	int3   
  801552:	eb fd                	jmp    801551 <_panic+0x5d>

00801554 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80155a:	83 3d 18 20 80 00 00 	cmpl   $0x0,0x802018
  801561:	75 3c                	jne    80159f <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	6a 07                	push   $0x7
  801568:	68 00 f0 bf ee       	push   $0xeebff000
  80156d:	6a 00                	push   $0x0
  80156f:	e8 d2 f9 ff ff       	call   800f46 <sys_page_alloc>
		if (r) {
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	74 12                	je     80158d <set_pgfault_handler+0x39>
			panic("set_pgfault_handler: %e\n", r);
  80157b:	50                   	push   %eax
  80157c:	68 88 1d 80 00       	push   $0x801d88
  801581:	6a 22                	push   $0x22
  801583:	68 a1 1d 80 00       	push   $0x801da1
  801588:	e8 67 ff ff ff       	call   8014f4 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	68 a9 15 80 00       	push   $0x8015a9
  801595:	6a 00                	push   $0x0
  801597:	e8 0f fb ff ff       	call   8010ab <sys_env_set_pgfault_upcall>
  80159c:	83 c4 10             	add    $0x10,%esp
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80159f:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a2:	a3 18 20 80 00       	mov    %eax,0x802018
}
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8015a9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8015aa:	a1 18 20 80 00       	mov    0x802018,%eax
	call *%eax
  8015af:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8015b1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  8015b4:	8b 44 24 30          	mov    0x30(%esp),%eax
	leal -0x4(%eax), %eax	// preserve space to store trap-time eip
  8015b8:	8d 40 fc             	lea    -0x4(%eax),%eax
	movl %eax, 0x30(%esp)
  8015bb:	89 44 24 30          	mov    %eax,0x30(%esp)

	movl 0x28(%esp), %ecx
  8015bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  8015c3:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8015c5:	83 c4 08             	add    $0x8,%esp
	popal
  8015c8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8015c9:	83 c4 04             	add    $0x4,%esp
	popfl
  8015cc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8015cd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8015ce:	c3                   	ret    
  8015cf:	90                   	nop

008015d0 <__udivdi3>:
  8015d0:	55                   	push   %ebp
  8015d1:	57                   	push   %edi
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 1c             	sub    $0x1c,%esp
  8015d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8015db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8015df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8015e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8015e7:	85 f6                	test   %esi,%esi
  8015e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ed:	89 ca                	mov    %ecx,%edx
  8015ef:	89 f8                	mov    %edi,%eax
  8015f1:	75 3d                	jne    801630 <__udivdi3+0x60>
  8015f3:	39 cf                	cmp    %ecx,%edi
  8015f5:	0f 87 c5 00 00 00    	ja     8016c0 <__udivdi3+0xf0>
  8015fb:	85 ff                	test   %edi,%edi
  8015fd:	89 fd                	mov    %edi,%ebp
  8015ff:	75 0b                	jne    80160c <__udivdi3+0x3c>
  801601:	b8 01 00 00 00       	mov    $0x1,%eax
  801606:	31 d2                	xor    %edx,%edx
  801608:	f7 f7                	div    %edi
  80160a:	89 c5                	mov    %eax,%ebp
  80160c:	89 c8                	mov    %ecx,%eax
  80160e:	31 d2                	xor    %edx,%edx
  801610:	f7 f5                	div    %ebp
  801612:	89 c1                	mov    %eax,%ecx
  801614:	89 d8                	mov    %ebx,%eax
  801616:	89 cf                	mov    %ecx,%edi
  801618:	f7 f5                	div    %ebp
  80161a:	89 c3                	mov    %eax,%ebx
  80161c:	89 d8                	mov    %ebx,%eax
  80161e:	89 fa                	mov    %edi,%edx
  801620:	83 c4 1c             	add    $0x1c,%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    
  801628:	90                   	nop
  801629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801630:	39 ce                	cmp    %ecx,%esi
  801632:	77 74                	ja     8016a8 <__udivdi3+0xd8>
  801634:	0f bd fe             	bsr    %esi,%edi
  801637:	83 f7 1f             	xor    $0x1f,%edi
  80163a:	0f 84 98 00 00 00    	je     8016d8 <__udivdi3+0x108>
  801640:	bb 20 00 00 00       	mov    $0x20,%ebx
  801645:	89 f9                	mov    %edi,%ecx
  801647:	89 c5                	mov    %eax,%ebp
  801649:	29 fb                	sub    %edi,%ebx
  80164b:	d3 e6                	shl    %cl,%esi
  80164d:	89 d9                	mov    %ebx,%ecx
  80164f:	d3 ed                	shr    %cl,%ebp
  801651:	89 f9                	mov    %edi,%ecx
  801653:	d3 e0                	shl    %cl,%eax
  801655:	09 ee                	or     %ebp,%esi
  801657:	89 d9                	mov    %ebx,%ecx
  801659:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80165d:	89 d5                	mov    %edx,%ebp
  80165f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801663:	d3 ed                	shr    %cl,%ebp
  801665:	89 f9                	mov    %edi,%ecx
  801667:	d3 e2                	shl    %cl,%edx
  801669:	89 d9                	mov    %ebx,%ecx
  80166b:	d3 e8                	shr    %cl,%eax
  80166d:	09 c2                	or     %eax,%edx
  80166f:	89 d0                	mov    %edx,%eax
  801671:	89 ea                	mov    %ebp,%edx
  801673:	f7 f6                	div    %esi
  801675:	89 d5                	mov    %edx,%ebp
  801677:	89 c3                	mov    %eax,%ebx
  801679:	f7 64 24 0c          	mull   0xc(%esp)
  80167d:	39 d5                	cmp    %edx,%ebp
  80167f:	72 10                	jb     801691 <__udivdi3+0xc1>
  801681:	8b 74 24 08          	mov    0x8(%esp),%esi
  801685:	89 f9                	mov    %edi,%ecx
  801687:	d3 e6                	shl    %cl,%esi
  801689:	39 c6                	cmp    %eax,%esi
  80168b:	73 07                	jae    801694 <__udivdi3+0xc4>
  80168d:	39 d5                	cmp    %edx,%ebp
  80168f:	75 03                	jne    801694 <__udivdi3+0xc4>
  801691:	83 eb 01             	sub    $0x1,%ebx
  801694:	31 ff                	xor    %edi,%edi
  801696:	89 d8                	mov    %ebx,%eax
  801698:	89 fa                	mov    %edi,%edx
  80169a:	83 c4 1c             	add    $0x1c,%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	5f                   	pop    %edi
  8016a0:	5d                   	pop    %ebp
  8016a1:	c3                   	ret    
  8016a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8016a8:	31 ff                	xor    %edi,%edi
  8016aa:	31 db                	xor    %ebx,%ebx
  8016ac:	89 d8                	mov    %ebx,%eax
  8016ae:	89 fa                	mov    %edi,%edx
  8016b0:	83 c4 1c             	add    $0x1c,%esp
  8016b3:	5b                   	pop    %ebx
  8016b4:	5e                   	pop    %esi
  8016b5:	5f                   	pop    %edi
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    
  8016b8:	90                   	nop
  8016b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	f7 f7                	div    %edi
  8016c4:	31 ff                	xor    %edi,%edi
  8016c6:	89 c3                	mov    %eax,%ebx
  8016c8:	89 d8                	mov    %ebx,%eax
  8016ca:	89 fa                	mov    %edi,%edx
  8016cc:	83 c4 1c             	add    $0x1c,%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5f                   	pop    %edi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    
  8016d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016d8:	39 ce                	cmp    %ecx,%esi
  8016da:	72 0c                	jb     8016e8 <__udivdi3+0x118>
  8016dc:	31 db                	xor    %ebx,%ebx
  8016de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8016e2:	0f 87 34 ff ff ff    	ja     80161c <__udivdi3+0x4c>
  8016e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8016ed:	e9 2a ff ff ff       	jmp    80161c <__udivdi3+0x4c>
  8016f2:	66 90                	xchg   %ax,%ax
  8016f4:	66 90                	xchg   %ax,%ax
  8016f6:	66 90                	xchg   %ax,%ax
  8016f8:	66 90                	xchg   %ax,%ax
  8016fa:	66 90                	xchg   %ax,%ax
  8016fc:	66 90                	xchg   %ax,%ax
  8016fe:	66 90                	xchg   %ax,%ax

00801700 <__umoddi3>:
  801700:	55                   	push   %ebp
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	83 ec 1c             	sub    $0x1c,%esp
  801707:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80170b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80170f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801713:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801717:	85 d2                	test   %edx,%edx
  801719:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80171d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801721:	89 f3                	mov    %esi,%ebx
  801723:	89 3c 24             	mov    %edi,(%esp)
  801726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80172a:	75 1c                	jne    801748 <__umoddi3+0x48>
  80172c:	39 f7                	cmp    %esi,%edi
  80172e:	76 50                	jbe    801780 <__umoddi3+0x80>
  801730:	89 c8                	mov    %ecx,%eax
  801732:	89 f2                	mov    %esi,%edx
  801734:	f7 f7                	div    %edi
  801736:	89 d0                	mov    %edx,%eax
  801738:	31 d2                	xor    %edx,%edx
  80173a:	83 c4 1c             	add    $0x1c,%esp
  80173d:	5b                   	pop    %ebx
  80173e:	5e                   	pop    %esi
  80173f:	5f                   	pop    %edi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    
  801742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801748:	39 f2                	cmp    %esi,%edx
  80174a:	89 d0                	mov    %edx,%eax
  80174c:	77 52                	ja     8017a0 <__umoddi3+0xa0>
  80174e:	0f bd ea             	bsr    %edx,%ebp
  801751:	83 f5 1f             	xor    $0x1f,%ebp
  801754:	75 5a                	jne    8017b0 <__umoddi3+0xb0>
  801756:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80175a:	0f 82 e0 00 00 00    	jb     801840 <__umoddi3+0x140>
  801760:	39 0c 24             	cmp    %ecx,(%esp)
  801763:	0f 86 d7 00 00 00    	jbe    801840 <__umoddi3+0x140>
  801769:	8b 44 24 08          	mov    0x8(%esp),%eax
  80176d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801771:	83 c4 1c             	add    $0x1c,%esp
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5f                   	pop    %edi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    
  801779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801780:	85 ff                	test   %edi,%edi
  801782:	89 fd                	mov    %edi,%ebp
  801784:	75 0b                	jne    801791 <__umoddi3+0x91>
  801786:	b8 01 00 00 00       	mov    $0x1,%eax
  80178b:	31 d2                	xor    %edx,%edx
  80178d:	f7 f7                	div    %edi
  80178f:	89 c5                	mov    %eax,%ebp
  801791:	89 f0                	mov    %esi,%eax
  801793:	31 d2                	xor    %edx,%edx
  801795:	f7 f5                	div    %ebp
  801797:	89 c8                	mov    %ecx,%eax
  801799:	f7 f5                	div    %ebp
  80179b:	89 d0                	mov    %edx,%eax
  80179d:	eb 99                	jmp    801738 <__umoddi3+0x38>
  80179f:	90                   	nop
  8017a0:	89 c8                	mov    %ecx,%eax
  8017a2:	89 f2                	mov    %esi,%edx
  8017a4:	83 c4 1c             	add    $0x1c,%esp
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	5f                   	pop    %edi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    
  8017ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017b0:	8b 34 24             	mov    (%esp),%esi
  8017b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8017b8:	89 e9                	mov    %ebp,%ecx
  8017ba:	29 ef                	sub    %ebp,%edi
  8017bc:	d3 e0                	shl    %cl,%eax
  8017be:	89 f9                	mov    %edi,%ecx
  8017c0:	89 f2                	mov    %esi,%edx
  8017c2:	d3 ea                	shr    %cl,%edx
  8017c4:	89 e9                	mov    %ebp,%ecx
  8017c6:	09 c2                	or     %eax,%edx
  8017c8:	89 d8                	mov    %ebx,%eax
  8017ca:	89 14 24             	mov    %edx,(%esp)
  8017cd:	89 f2                	mov    %esi,%edx
  8017cf:	d3 e2                	shl    %cl,%edx
  8017d1:	89 f9                	mov    %edi,%ecx
  8017d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8017db:	d3 e8                	shr    %cl,%eax
  8017dd:	89 e9                	mov    %ebp,%ecx
  8017df:	89 c6                	mov    %eax,%esi
  8017e1:	d3 e3                	shl    %cl,%ebx
  8017e3:	89 f9                	mov    %edi,%ecx
  8017e5:	89 d0                	mov    %edx,%eax
  8017e7:	d3 e8                	shr    %cl,%eax
  8017e9:	89 e9                	mov    %ebp,%ecx
  8017eb:	09 d8                	or     %ebx,%eax
  8017ed:	89 d3                	mov    %edx,%ebx
  8017ef:	89 f2                	mov    %esi,%edx
  8017f1:	f7 34 24             	divl   (%esp)
  8017f4:	89 d6                	mov    %edx,%esi
  8017f6:	d3 e3                	shl    %cl,%ebx
  8017f8:	f7 64 24 04          	mull   0x4(%esp)
  8017fc:	39 d6                	cmp    %edx,%esi
  8017fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801802:	89 d1                	mov    %edx,%ecx
  801804:	89 c3                	mov    %eax,%ebx
  801806:	72 08                	jb     801810 <__umoddi3+0x110>
  801808:	75 11                	jne    80181b <__umoddi3+0x11b>
  80180a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80180e:	73 0b                	jae    80181b <__umoddi3+0x11b>
  801810:	2b 44 24 04          	sub    0x4(%esp),%eax
  801814:	1b 14 24             	sbb    (%esp),%edx
  801817:	89 d1                	mov    %edx,%ecx
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80181f:	29 da                	sub    %ebx,%edx
  801821:	19 ce                	sbb    %ecx,%esi
  801823:	89 f9                	mov    %edi,%ecx
  801825:	89 f0                	mov    %esi,%eax
  801827:	d3 e0                	shl    %cl,%eax
  801829:	89 e9                	mov    %ebp,%ecx
  80182b:	d3 ea                	shr    %cl,%edx
  80182d:	89 e9                	mov    %ebp,%ecx
  80182f:	d3 ee                	shr    %cl,%esi
  801831:	09 d0                	or     %edx,%eax
  801833:	89 f2                	mov    %esi,%edx
  801835:	83 c4 1c             	add    $0x1c,%esp
  801838:	5b                   	pop    %ebx
  801839:	5e                   	pop    %esi
  80183a:	5f                   	pop    %edi
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    
  80183d:	8d 76 00             	lea    0x0(%esi),%esi
  801840:	29 f9                	sub    %edi,%ecx
  801842:	19 d6                	sbb    %edx,%esi
  801844:	89 74 24 04          	mov    %esi,0x4(%esp)
  801848:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80184c:	e9 18 ff ff ff       	jmp    801769 <__umoddi3+0x69>
