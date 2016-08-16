
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
  80003c:	e8 65 11 00 00       	call   8011a6 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 10 20 80 00    	mov    0x802010,%ebx
  80004e:	e8 5e 0e 00 00       	call   800eb1 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 40 15 80 00       	push   $0x801540
  80005d:	e8 87 01 00 00       	call   8001e9 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 47 0e 00 00       	call   800eb1 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 5a 15 80 00       	push   $0x80155a
  800074:	e8 70 01 00 00       	call   8001e9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 4d 11 00 00       	call   8011d4 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 23 11 00 00       	call   8011bd <ipc_recv>
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
  8000bd:	68 70 15 80 00       	push   $0x801570
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
  8000e5:	e8 ea 10 00 00       	call   8011d4 <ipc_send>
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
	// cprintf("env_id = %08x\n", sys_getenvid());

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
  800261:	e8 6a 11 00 00       	call   8013d0 <__umoddi3>
  800266:	83 c4 14             	add    $0x14,%esp
  800269:	0f be 80 a0 15 80 00 	movsbl 0x8015a0(%eax),%eax
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
  800343:	e8 88 10 00 00       	call   8013d0 <__umoddi3>
  800348:	83 c4 14             	add    $0x14,%esp
  80034b:	0f be 80 a0 15 80 00 	movsbl 0x8015a0(%eax),%eax
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
  800379:	e8 22 0f 00 00       	call   8012a0 <__udivdi3>
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
  80039f:	e8 2c 10 00 00       	call   8013d0 <__umoddi3>
  8003a4:	83 c4 14             	add    $0x14,%esp
  8003a7:	0f be 80 a0 15 80 00 	movsbl 0x8015a0(%eax),%eax
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
  8003d5:	e8 c6 0e 00 00       	call   8012a0 <__udivdi3>
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
  8003fb:	e8 d0 0f 00 00       	call   8013d0 <__umoddi3>
  800400:	83 c4 14             	add    $0x14,%esp
  800403:	0f be 80 a0 15 80 00 	movsbl 0x8015a0(%eax),%eax
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
  80051e:	ff 24 85 e0 16 80 00 	jmp    *0x8016e0(,%eax,4)
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
  800604:	8b 14 85 40 18 80 00 	mov    0x801840(,%eax,4),%edx
  80060b:	85 d2                	test   %edx,%edx
  80060d:	75 15                	jne    800624 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80060f:	50                   	push   %eax
  800610:	68 b8 15 80 00       	push   $0x8015b8
  800615:	53                   	push   %ebx
  800616:	57                   	push   %edi
  800617:	e8 53 fe ff ff       	call   80046f <printfmt>
  80061c:	83 c4 10             	add    $0x10,%esp
  80061f:	e9 7c fe ff ff       	jmp    8004a0 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800624:	52                   	push   %edx
  800625:	68 c1 15 80 00       	push   $0x8015c1
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
  800646:	b9 b1 15 80 00       	mov    $0x8015b1,%ecx
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
  8008c2:	68 58 16 80 00       	push   $0x801658
  8008c7:	68 c1 15 80 00       	push   $0x8015c1
  8008cc:	e8 18 f9 ff ff       	call   8001e9 <cprintf>
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	e9 c7 fb ff ff       	jmp    8004a0 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8008d9:	0f b6 03             	movzbl (%ebx),%eax
  8008dc:	84 c0                	test   %al,%al
  8008de:	79 1f                	jns    8008ff <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	68 90 16 80 00       	push   $0x801690
  8008e8:	68 c1 15 80 00       	push   $0x8015c1
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
  800e17:	54                   	push   %esp
  800e18:	55                   	push   %ebp
  800e19:	56                   	push   %esi
  800e1a:	57                   	push   %edi
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	8d 35 25 0e 80 00    	lea    0x800e25,%esi
  800e23:	0f 34                	sysenter 

00800e25 <label_21>:
  800e25:	5f                   	pop    %edi
  800e26:	5e                   	pop    %esi
  800e27:	5d                   	pop    %ebp
  800e28:	5c                   	pop    %esp
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
  800e48:	54                   	push   %esp
  800e49:	55                   	push   %ebp
  800e4a:	56                   	push   %esi
  800e4b:	57                   	push   %edi
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8d 35 56 0e 80 00    	lea    0x800e56,%esi
  800e54:	0f 34                	sysenter 

00800e56 <label_55>:
  800e56:	5f                   	pop    %edi
  800e57:	5e                   	pop    %esi
  800e58:	5d                   	pop    %ebp
  800e59:	5c                   	pop    %esp
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
  800e7a:	54                   	push   %esp
  800e7b:	55                   	push   %ebp
  800e7c:	56                   	push   %esi
  800e7d:	57                   	push   %edi
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	8d 35 88 0e 80 00    	lea    0x800e88,%esi
  800e86:	0f 34                	sysenter 

00800e88 <label_90>:
  800e88:	5f                   	pop    %edi
  800e89:	5e                   	pop    %esi
  800e8a:	5d                   	pop    %ebp
  800e8b:	5c                   	pop    %esp
  800e8c:	5b                   	pop    %ebx
  800e8d:	5a                   	pop    %edx
  800e8e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7e 17                	jle    800eaa <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	50                   	push   %eax
  800e97:	6a 03                	push   $0x3
  800e99:	68 64 18 80 00       	push   $0x801864
  800e9e:	6a 2a                	push   $0x2a
  800ea0:	68 81 18 80 00       	push   $0x801881
  800ea5:	e8 8c 03 00 00       	call   801236 <_panic>

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
  800ec9:	54                   	push   %esp
  800eca:	55                   	push   %ebp
  800ecb:	56                   	push   %esi
  800ecc:	57                   	push   %edi
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	8d 35 d7 0e 80 00    	lea    0x800ed7,%esi
  800ed5:	0f 34                	sysenter 

00800ed7 <label_139>:
  800ed7:	5f                   	pop    %edi
  800ed8:	5e                   	pop    %esi
  800ed9:	5d                   	pop    %ebp
  800eda:	5c                   	pop    %esp
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
  800efc:	54                   	push   %esp
  800efd:	55                   	push   %ebp
  800efe:	56                   	push   %esi
  800eff:	57                   	push   %edi
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	8d 35 0a 0f 80 00    	lea    0x800f0a,%esi
  800f08:	0f 34                	sysenter 

00800f0a <label_174>:
  800f0a:	5f                   	pop    %edi
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	5c                   	pop    %esp
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
  800f2d:	54                   	push   %esp
  800f2e:	55                   	push   %ebp
  800f2f:	56                   	push   %esi
  800f30:	57                   	push   %edi
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	8d 35 3b 0f 80 00    	lea    0x800f3b,%esi
  800f39:	0f 34                	sysenter 

00800f3b <label_209>:
  800f3b:	5f                   	pop    %edi
  800f3c:	5e                   	pop    %esi
  800f3d:	5d                   	pop    %ebp
  800f3e:	5c                   	pop    %esp
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
  800f61:	54                   	push   %esp
  800f62:	55                   	push   %ebp
  800f63:	56                   	push   %esi
  800f64:	57                   	push   %edi
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	8d 35 6f 0f 80 00    	lea    0x800f6f,%esi
  800f6d:	0f 34                	sysenter 

00800f6f <label_244>:
  800f6f:	5f                   	pop    %edi
  800f70:	5e                   	pop    %esi
  800f71:	5d                   	pop    %ebp
  800f72:	5c                   	pop    %esp
  800f73:	5b                   	pop    %ebx
  800f74:	5a                   	pop    %edx
  800f75:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	7e 17                	jle    800f91 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	50                   	push   %eax
  800f7e:	6a 05                	push   $0x5
  800f80:	68 64 18 80 00       	push   $0x801864
  800f85:	6a 2a                	push   $0x2a
  800f87:	68 81 18 80 00       	push   $0x801881
  800f8c:	e8 a5 02 00 00       	call   801236 <_panic>

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

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fae:	51                   	push   %ecx
  800faf:	52                   	push   %edx
  800fb0:	53                   	push   %ebx
  800fb1:	54                   	push   %esp
  800fb2:	55                   	push   %ebp
  800fb3:	56                   	push   %esi
  800fb4:	57                   	push   %edi
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	8d 35 bf 0f 80 00    	lea    0x800fbf,%esi
  800fbd:	0f 34                	sysenter 

00800fbf <label_295>:
  800fbf:	5f                   	pop    %edi
  800fc0:	5e                   	pop    %esi
  800fc1:	5d                   	pop    %ebp
  800fc2:	5c                   	pop    %esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5a                   	pop    %edx
  800fc5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	7e 17                	jle    800fe1 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	50                   	push   %eax
  800fce:	6a 06                	push   $0x6
  800fd0:	68 64 18 80 00       	push   $0x801864
  800fd5:	6a 2a                	push   $0x2a
  800fd7:	68 81 18 80 00       	push   $0x801881
  800fdc:	e8 55 02 00 00       	call   801236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fe1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5f                   	pop    %edi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	57                   	push   %edi
  800fec:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fed:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff2:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffd:	89 fb                	mov    %edi,%ebx
  800fff:	51                   	push   %ecx
  801000:	52                   	push   %edx
  801001:	53                   	push   %ebx
  801002:	54                   	push   %esp
  801003:	55                   	push   %ebp
  801004:	56                   	push   %esi
  801005:	57                   	push   %edi
  801006:	89 e5                	mov    %esp,%ebp
  801008:	8d 35 10 10 80 00    	lea    0x801010,%esi
  80100e:	0f 34                	sysenter 

00801010 <label_344>:
  801010:	5f                   	pop    %edi
  801011:	5e                   	pop    %esi
  801012:	5d                   	pop    %ebp
  801013:	5c                   	pop    %esp
  801014:	5b                   	pop    %ebx
  801015:	5a                   	pop    %edx
  801016:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801017:	85 c0                	test   %eax,%eax
  801019:	7e 17                	jle    801032 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	50                   	push   %eax
  80101f:	6a 07                	push   $0x7
  801021:	68 64 18 80 00       	push   $0x801864
  801026:	6a 2a                	push   $0x2a
  801028:	68 81 18 80 00       	push   $0x801881
  80102d:	e8 04 02 00 00       	call   801236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801032:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801035:	5b                   	pop    %ebx
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80103e:	bf 00 00 00 00       	mov    $0x0,%edi
  801043:	b8 09 00 00 00       	mov    $0x9,%eax
  801048:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	89 fb                	mov    %edi,%ebx
  801050:	51                   	push   %ecx
  801051:	52                   	push   %edx
  801052:	53                   	push   %ebx
  801053:	54                   	push   %esp
  801054:	55                   	push   %ebp
  801055:	56                   	push   %esi
  801056:	57                   	push   %edi
  801057:	89 e5                	mov    %esp,%ebp
  801059:	8d 35 61 10 80 00    	lea    0x801061,%esi
  80105f:	0f 34                	sysenter 

00801061 <label_393>:
  801061:	5f                   	pop    %edi
  801062:	5e                   	pop    %esi
  801063:	5d                   	pop    %ebp
  801064:	5c                   	pop    %esp
  801065:	5b                   	pop    %ebx
  801066:	5a                   	pop    %edx
  801067:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801068:	85 c0                	test   %eax,%eax
  80106a:	7e 17                	jle    801083 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	50                   	push   %eax
  801070:	6a 09                	push   $0x9
  801072:	68 64 18 80 00       	push   $0x801864
  801077:	6a 2a                	push   $0x2a
  801079:	68 81 18 80 00       	push   $0x801881
  80107e:	e8 b3 01 00 00       	call   801236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	57                   	push   %edi
  80108e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80108f:	bf 00 00 00 00       	mov    $0x0,%edi
  801094:	b8 0a 00 00 00       	mov    $0xa,%eax
  801099:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109c:	8b 55 08             	mov    0x8(%ebp),%edx
  80109f:	89 fb                	mov    %edi,%ebx
  8010a1:	51                   	push   %ecx
  8010a2:	52                   	push   %edx
  8010a3:	53                   	push   %ebx
  8010a4:	54                   	push   %esp
  8010a5:	55                   	push   %ebp
  8010a6:	56                   	push   %esi
  8010a7:	57                   	push   %edi
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	8d 35 b2 10 80 00    	lea    0x8010b2,%esi
  8010b0:	0f 34                	sysenter 

008010b2 <label_442>:
  8010b2:	5f                   	pop    %edi
  8010b3:	5e                   	pop    %esi
  8010b4:	5d                   	pop    %ebp
  8010b5:	5c                   	pop    %esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5a                   	pop    %edx
  8010b8:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	7e 17                	jle    8010d4 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	50                   	push   %eax
  8010c1:	6a 0a                	push   $0xa
  8010c3:	68 64 18 80 00       	push   $0x801864
  8010c8:	6a 2a                	push   $0x2a
  8010ca:	68 81 18 80 00       	push   $0x801881
  8010cf:	e8 62 01 00 00       	call   801236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f1:	51                   	push   %ecx
  8010f2:	52                   	push   %edx
  8010f3:	53                   	push   %ebx
  8010f4:	54                   	push   %esp
  8010f5:	55                   	push   %ebp
  8010f6:	56                   	push   %esi
  8010f7:	57                   	push   %edi
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	8d 35 02 11 80 00    	lea    0x801102,%esi
  801100:	0f 34                	sysenter 

00801102 <label_493>:
  801102:	5f                   	pop    %edi
  801103:	5e                   	pop    %esi
  801104:	5d                   	pop    %ebp
  801105:	5c                   	pop    %esp
  801106:	5b                   	pop    %ebx
  801107:	5a                   	pop    %edx
  801108:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801109:	5b                   	pop    %ebx
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801112:	bb 00 00 00 00       	mov    $0x0,%ebx
  801117:	b8 0d 00 00 00       	mov    $0xd,%eax
  80111c:	8b 55 08             	mov    0x8(%ebp),%edx
  80111f:	89 d9                	mov    %ebx,%ecx
  801121:	89 df                	mov    %ebx,%edi
  801123:	51                   	push   %ecx
  801124:	52                   	push   %edx
  801125:	53                   	push   %ebx
  801126:	54                   	push   %esp
  801127:	55                   	push   %ebp
  801128:	56                   	push   %esi
  801129:	57                   	push   %edi
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	8d 35 34 11 80 00    	lea    0x801134,%esi
  801132:	0f 34                	sysenter 

00801134 <label_528>:
  801134:	5f                   	pop    %edi
  801135:	5e                   	pop    %esi
  801136:	5d                   	pop    %ebp
  801137:	5c                   	pop    %esp
  801138:	5b                   	pop    %ebx
  801139:	5a                   	pop    %edx
  80113a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80113b:	85 c0                	test   %eax,%eax
  80113d:	7e 17                	jle    801156 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80113f:	83 ec 0c             	sub    $0xc,%esp
  801142:	50                   	push   %eax
  801143:	6a 0d                	push   $0xd
  801145:	68 64 18 80 00       	push   $0x801864
  80114a:	6a 2a                	push   $0x2a
  80114c:	68 81 18 80 00       	push   $0x801881
  801151:	e8 e0 00 00 00       	call   801236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801156:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	57                   	push   %edi
  801161:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801162:	b9 00 00 00 00       	mov    $0x0,%ecx
  801167:	b8 0e 00 00 00       	mov    $0xe,%eax
  80116c:	8b 55 08             	mov    0x8(%ebp),%edx
  80116f:	89 cb                	mov    %ecx,%ebx
  801171:	89 cf                	mov    %ecx,%edi
  801173:	51                   	push   %ecx
  801174:	52                   	push   %edx
  801175:	53                   	push   %ebx
  801176:	54                   	push   %esp
  801177:	55                   	push   %ebp
  801178:	56                   	push   %esi
  801179:	57                   	push   %edi
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	8d 35 84 11 80 00    	lea    0x801184,%esi
  801182:	0f 34                	sysenter 

00801184 <label_577>:
  801184:	5f                   	pop    %edi
  801185:	5e                   	pop    %esi
  801186:	5d                   	pop    %ebp
  801187:	5c                   	pop    %esp
  801188:	5b                   	pop    %ebx
  801189:	5a                   	pop    %edx
  80118a:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80118b:	5b                   	pop    %ebx
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  801195:	68 9b 18 80 00       	push   $0x80189b
  80119a:	6a 52                	push   $0x52
  80119c:	68 8f 18 80 00       	push   $0x80188f
  8011a1:	e8 90 00 00 00       	call   801236 <_panic>

008011a6 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ac:	68 9a 18 80 00       	push   $0x80189a
  8011b1:	6a 59                	push   $0x59
  8011b3:	68 8f 18 80 00       	push   $0x80188f
  8011b8:	e8 79 00 00 00       	call   801236 <_panic>

008011bd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  8011c3:	68 b0 18 80 00       	push   $0x8018b0
  8011c8:	6a 1a                	push   $0x1a
  8011ca:	68 c9 18 80 00       	push   $0x8018c9
  8011cf:	e8 62 00 00 00       	call   801236 <_panic>

008011d4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  8011da:	68 d3 18 80 00       	push   $0x8018d3
  8011df:	6a 2a                	push   $0x2a
  8011e1:	68 c9 18 80 00       	push   $0x8018c9
  8011e6:	e8 4b 00 00 00       	call   801236 <_panic>

008011eb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8011f1:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8011f6:	39 c1                	cmp    %eax,%ecx
  8011f8:	74 19                	je     801213 <ipc_find_env+0x28>
  8011fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	c1 e2 07             	shl    $0x7,%edx
  801204:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80120a:	8b 52 50             	mov    0x50(%edx),%edx
  80120d:	39 ca                	cmp    %ecx,%edx
  80120f:	75 14                	jne    801225 <ipc_find_env+0x3a>
  801211:	eb 05                	jmp    801218 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801218:	c1 e0 07             	shl    $0x7,%eax
  80121b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801220:	8b 40 48             	mov    0x48(%eax),%eax
  801223:	eb 0f                	jmp    801234 <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801225:	83 c0 01             	add    $0x1,%eax
  801228:	3d 00 04 00 00       	cmp    $0x400,%eax
  80122d:	75 d0                	jne    8011ff <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	56                   	push   %esi
  80123a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80123b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80123e:	a1 14 20 80 00       	mov    0x802014,%eax
  801243:	85 c0                	test   %eax,%eax
  801245:	74 11                	je     801258 <_panic+0x22>
		cprintf("%s: ", argv0);
  801247:	83 ec 08             	sub    $0x8,%esp
  80124a:	50                   	push   %eax
  80124b:	68 ec 18 80 00       	push   $0x8018ec
  801250:	e8 94 ef ff ff       	call   8001e9 <cprintf>
  801255:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801258:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80125e:	e8 4e fc ff ff       	call   800eb1 <sys_getenvid>
  801263:	83 ec 0c             	sub    $0xc,%esp
  801266:	ff 75 0c             	pushl  0xc(%ebp)
  801269:	ff 75 08             	pushl  0x8(%ebp)
  80126c:	56                   	push   %esi
  80126d:	50                   	push   %eax
  80126e:	68 f4 18 80 00       	push   $0x8018f4
  801273:	e8 71 ef ff ff       	call   8001e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801278:	83 c4 18             	add    $0x18,%esp
  80127b:	53                   	push   %ebx
  80127c:	ff 75 10             	pushl  0x10(%ebp)
  80127f:	e8 14 ef ff ff       	call   800198 <vcprintf>
	cprintf("\n");
  801284:	c7 04 24 58 15 80 00 	movl   $0x801558,(%esp)
  80128b:	e8 59 ef ff ff       	call   8001e9 <cprintf>
  801290:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801293:	cc                   	int3   
  801294:	eb fd                	jmp    801293 <_panic+0x5d>
  801296:	66 90                	xchg   %ax,%ax
  801298:	66 90                	xchg   %ax,%ax
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__udivdi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 1c             	sub    $0x1c,%esp
  8012a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8012ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8012af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8012b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012b7:	85 f6                	test   %esi,%esi
  8012b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bd:	89 ca                	mov    %ecx,%edx
  8012bf:	89 f8                	mov    %edi,%eax
  8012c1:	75 3d                	jne    801300 <__udivdi3+0x60>
  8012c3:	39 cf                	cmp    %ecx,%edi
  8012c5:	0f 87 c5 00 00 00    	ja     801390 <__udivdi3+0xf0>
  8012cb:	85 ff                	test   %edi,%edi
  8012cd:	89 fd                	mov    %edi,%ebp
  8012cf:	75 0b                	jne    8012dc <__udivdi3+0x3c>
  8012d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d6:	31 d2                	xor    %edx,%edx
  8012d8:	f7 f7                	div    %edi
  8012da:	89 c5                	mov    %eax,%ebp
  8012dc:	89 c8                	mov    %ecx,%eax
  8012de:	31 d2                	xor    %edx,%edx
  8012e0:	f7 f5                	div    %ebp
  8012e2:	89 c1                	mov    %eax,%ecx
  8012e4:	89 d8                	mov    %ebx,%eax
  8012e6:	89 cf                	mov    %ecx,%edi
  8012e8:	f7 f5                	div    %ebp
  8012ea:	89 c3                	mov    %eax,%ebx
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
  801300:	39 ce                	cmp    %ecx,%esi
  801302:	77 74                	ja     801378 <__udivdi3+0xd8>
  801304:	0f bd fe             	bsr    %esi,%edi
  801307:	83 f7 1f             	xor    $0x1f,%edi
  80130a:	0f 84 98 00 00 00    	je     8013a8 <__udivdi3+0x108>
  801310:	bb 20 00 00 00       	mov    $0x20,%ebx
  801315:	89 f9                	mov    %edi,%ecx
  801317:	89 c5                	mov    %eax,%ebp
  801319:	29 fb                	sub    %edi,%ebx
  80131b:	d3 e6                	shl    %cl,%esi
  80131d:	89 d9                	mov    %ebx,%ecx
  80131f:	d3 ed                	shr    %cl,%ebp
  801321:	89 f9                	mov    %edi,%ecx
  801323:	d3 e0                	shl    %cl,%eax
  801325:	09 ee                	or     %ebp,%esi
  801327:	89 d9                	mov    %ebx,%ecx
  801329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132d:	89 d5                	mov    %edx,%ebp
  80132f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801333:	d3 ed                	shr    %cl,%ebp
  801335:	89 f9                	mov    %edi,%ecx
  801337:	d3 e2                	shl    %cl,%edx
  801339:	89 d9                	mov    %ebx,%ecx
  80133b:	d3 e8                	shr    %cl,%eax
  80133d:	09 c2                	or     %eax,%edx
  80133f:	89 d0                	mov    %edx,%eax
  801341:	89 ea                	mov    %ebp,%edx
  801343:	f7 f6                	div    %esi
  801345:	89 d5                	mov    %edx,%ebp
  801347:	89 c3                	mov    %eax,%ebx
  801349:	f7 64 24 0c          	mull   0xc(%esp)
  80134d:	39 d5                	cmp    %edx,%ebp
  80134f:	72 10                	jb     801361 <__udivdi3+0xc1>
  801351:	8b 74 24 08          	mov    0x8(%esp),%esi
  801355:	89 f9                	mov    %edi,%ecx
  801357:	d3 e6                	shl    %cl,%esi
  801359:	39 c6                	cmp    %eax,%esi
  80135b:	73 07                	jae    801364 <__udivdi3+0xc4>
  80135d:	39 d5                	cmp    %edx,%ebp
  80135f:	75 03                	jne    801364 <__udivdi3+0xc4>
  801361:	83 eb 01             	sub    $0x1,%ebx
  801364:	31 ff                	xor    %edi,%edi
  801366:	89 d8                	mov    %ebx,%eax
  801368:	89 fa                	mov    %edi,%edx
  80136a:	83 c4 1c             	add    $0x1c,%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5f                   	pop    %edi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	31 ff                	xor    %edi,%edi
  80137a:	31 db                	xor    %ebx,%ebx
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	89 fa                	mov    %edi,%edx
  801380:	83 c4 1c             	add    $0x1c,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
  801388:	90                   	nop
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	89 d8                	mov    %ebx,%eax
  801392:	f7 f7                	div    %edi
  801394:	31 ff                	xor    %edi,%edi
  801396:	89 c3                	mov    %eax,%ebx
  801398:	89 d8                	mov    %ebx,%eax
  80139a:	89 fa                	mov    %edi,%edx
  80139c:	83 c4 1c             	add    $0x1c,%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	39 ce                	cmp    %ecx,%esi
  8013aa:	72 0c                	jb     8013b8 <__udivdi3+0x118>
  8013ac:	31 db                	xor    %ebx,%ebx
  8013ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8013b2:	0f 87 34 ff ff ff    	ja     8012ec <__udivdi3+0x4c>
  8013b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8013bd:	e9 2a ff ff ff       	jmp    8012ec <__udivdi3+0x4c>
  8013c2:	66 90                	xchg   %ax,%ax
  8013c4:	66 90                	xchg   %ax,%ax
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	66 90                	xchg   %ax,%ax
  8013ca:	66 90                	xchg   %ax,%ax
  8013cc:	66 90                	xchg   %ax,%ax
  8013ce:	66 90                	xchg   %ax,%ax

008013d0 <__umoddi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 1c             	sub    $0x1c,%esp
  8013d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f1:	89 f3                	mov    %esi,%ebx
  8013f3:	89 3c 24             	mov    %edi,(%esp)
  8013f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fa:	75 1c                	jne    801418 <__umoddi3+0x48>
  8013fc:	39 f7                	cmp    %esi,%edi
  8013fe:	76 50                	jbe    801450 <__umoddi3+0x80>
  801400:	89 c8                	mov    %ecx,%eax
  801402:	89 f2                	mov    %esi,%edx
  801404:	f7 f7                	div    %edi
  801406:	89 d0                	mov    %edx,%eax
  801408:	31 d2                	xor    %edx,%edx
  80140a:	83 c4 1c             	add    $0x1c,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	39 f2                	cmp    %esi,%edx
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	77 52                	ja     801470 <__umoddi3+0xa0>
  80141e:	0f bd ea             	bsr    %edx,%ebp
  801421:	83 f5 1f             	xor    $0x1f,%ebp
  801424:	75 5a                	jne    801480 <__umoddi3+0xb0>
  801426:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80142a:	0f 82 e0 00 00 00    	jb     801510 <__umoddi3+0x140>
  801430:	39 0c 24             	cmp    %ecx,(%esp)
  801433:	0f 86 d7 00 00 00    	jbe    801510 <__umoddi3+0x140>
  801439:	8b 44 24 08          	mov    0x8(%esp),%eax
  80143d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801441:	83 c4 1c             	add    $0x1c,%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    
  801449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801450:	85 ff                	test   %edi,%edi
  801452:	89 fd                	mov    %edi,%ebp
  801454:	75 0b                	jne    801461 <__umoddi3+0x91>
  801456:	b8 01 00 00 00       	mov    $0x1,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	f7 f7                	div    %edi
  80145f:	89 c5                	mov    %eax,%ebp
  801461:	89 f0                	mov    %esi,%eax
  801463:	31 d2                	xor    %edx,%edx
  801465:	f7 f5                	div    %ebp
  801467:	89 c8                	mov    %ecx,%eax
  801469:	f7 f5                	div    %ebp
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	eb 99                	jmp    801408 <__umoddi3+0x38>
  80146f:	90                   	nop
  801470:	89 c8                	mov    %ecx,%eax
  801472:	89 f2                	mov    %esi,%edx
  801474:	83 c4 1c             	add    $0x1c,%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    
  80147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801480:	8b 34 24             	mov    (%esp),%esi
  801483:	bf 20 00 00 00       	mov    $0x20,%edi
  801488:	89 e9                	mov    %ebp,%ecx
  80148a:	29 ef                	sub    %ebp,%edi
  80148c:	d3 e0                	shl    %cl,%eax
  80148e:	89 f9                	mov    %edi,%ecx
  801490:	89 f2                	mov    %esi,%edx
  801492:	d3 ea                	shr    %cl,%edx
  801494:	89 e9                	mov    %ebp,%ecx
  801496:	09 c2                	or     %eax,%edx
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	89 14 24             	mov    %edx,(%esp)
  80149d:	89 f2                	mov    %esi,%edx
  80149f:	d3 e2                	shl    %cl,%edx
  8014a1:	89 f9                	mov    %edi,%ecx
  8014a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014ab:	d3 e8                	shr    %cl,%eax
  8014ad:	89 e9                	mov    %ebp,%ecx
  8014af:	89 c6                	mov    %eax,%esi
  8014b1:	d3 e3                	shl    %cl,%ebx
  8014b3:	89 f9                	mov    %edi,%ecx
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	d3 e8                	shr    %cl,%eax
  8014b9:	89 e9                	mov    %ebp,%ecx
  8014bb:	09 d8                	or     %ebx,%eax
  8014bd:	89 d3                	mov    %edx,%ebx
  8014bf:	89 f2                	mov    %esi,%edx
  8014c1:	f7 34 24             	divl   (%esp)
  8014c4:	89 d6                	mov    %edx,%esi
  8014c6:	d3 e3                	shl    %cl,%ebx
  8014c8:	f7 64 24 04          	mull   0x4(%esp)
  8014cc:	39 d6                	cmp    %edx,%esi
  8014ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d2:	89 d1                	mov    %edx,%ecx
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	72 08                	jb     8014e0 <__umoddi3+0x110>
  8014d8:	75 11                	jne    8014eb <__umoddi3+0x11b>
  8014da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014de:	73 0b                	jae    8014eb <__umoddi3+0x11b>
  8014e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014e4:	1b 14 24             	sbb    (%esp),%edx
  8014e7:	89 d1                	mov    %edx,%ecx
  8014e9:	89 c3                	mov    %eax,%ebx
  8014eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014ef:	29 da                	sub    %ebx,%edx
  8014f1:	19 ce                	sbb    %ecx,%esi
  8014f3:	89 f9                	mov    %edi,%ecx
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	d3 e0                	shl    %cl,%eax
  8014f9:	89 e9                	mov    %ebp,%ecx
  8014fb:	d3 ea                	shr    %cl,%edx
  8014fd:	89 e9                	mov    %ebp,%ecx
  8014ff:	d3 ee                	shr    %cl,%esi
  801501:	09 d0                	or     %edx,%eax
  801503:	89 f2                	mov    %esi,%edx
  801505:	83 c4 1c             	add    $0x1c,%esp
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
  80150d:	8d 76 00             	lea    0x0(%esi),%esi
  801510:	29 f9                	sub    %edi,%ecx
  801512:	19 d6                	sbb    %edx,%esi
  801514:	89 74 24 04          	mov    %esi,0x4(%esp)
  801518:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80151c:	e9 18 ff ff ff       	jmp    801439 <__umoddi3+0x69>