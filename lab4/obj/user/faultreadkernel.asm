
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 00 14 80 00       	push   $0x801400
  800044:	e8 f0 00 00 00       	call   800139 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800059:	e8 a3 0d 00 00       	call   800e01 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 10 0d 00 00       	call   800db1 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 7a 0c 00 00       	call   800d50 <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 a6 00 80 00       	push   $0x8000a6
  800117:	e8 c0 02 00 00       	call   8003dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800125:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 1f 0c 00 00       	call   800d50 <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800142:	50                   	push   %eax
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 9d ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 1c             	sub    $0x1c,%esp
  800156:	89 c7                	mov    %eax,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800163:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800166:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800169:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80016d:	0f 85 bf 00 00 00    	jne    800232 <printnum+0xe5>
  800173:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800179:	0f 8d de 00 00 00    	jge    80025d <printnum+0x110>
		judge_time_for_space = width;
  80017f:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800185:	e9 d3 00 00 00       	jmp    80025d <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80018a:	83 eb 01             	sub    $0x1,%ebx
  80018d:	85 db                	test   %ebx,%ebx
  80018f:	7f 37                	jg     8001c8 <printnum+0x7b>
  800191:	e9 ea 00 00 00       	jmp    800280 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800196:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800199:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80019e:	83 ec 08             	sub    $0x8,%esp
  8001a1:	56                   	push   %esi
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b1:	e8 da 10 00 00       	call   801290 <__umoddi3>
  8001b6:	83 c4 14             	add    $0x14,%esp
  8001b9:	0f be 80 31 14 80 00 	movsbl 0x801431(%eax),%eax
  8001c0:	50                   	push   %eax
  8001c1:	ff d7                	call   *%edi
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 16                	jmp    8001de <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	56                   	push   %esi
  8001cc:	ff 75 18             	pushl  0x18(%ebp)
  8001cf:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001d1:	83 c4 10             	add    $0x10,%esp
  8001d4:	83 eb 01             	sub    $0x1,%ebx
  8001d7:	75 ef                	jne    8001c8 <printnum+0x7b>
  8001d9:	e9 a2 00 00 00       	jmp    800280 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8001de:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8001e4:	0f 85 76 01 00 00    	jne    800360 <printnum+0x213>
		while(num_of_space-- > 0)
  8001ea:	a1 04 20 80 00       	mov    0x802004,%eax
  8001ef:	8d 50 ff             	lea    -0x1(%eax),%edx
  8001f2:	89 15 04 20 80 00    	mov    %edx,0x802004
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	7e 1d                	jle    800219 <printnum+0xcc>
			putch(' ', putdat);
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	56                   	push   %esi
  800200:	6a 20                	push   $0x20
  800202:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800204:	a1 04 20 80 00       	mov    0x802004,%eax
  800209:	8d 50 ff             	lea    -0x1(%eax),%edx
  80020c:	89 15 04 20 80 00    	mov    %edx,0x802004
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	7f e3                	jg     8001fc <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800219:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800220:	00 00 00 
		judge_time_for_space = 0;
  800223:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80022a:	00 00 00 
	}
}
  80022d:	e9 2e 01 00 00       	jmp    800360 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	8b 45 10             	mov    0x10(%ebp),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
  80023a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800240:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800243:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800246:	83 fa 00             	cmp    $0x0,%edx
  800249:	0f 87 ba 00 00 00    	ja     800309 <printnum+0x1bc>
  80024f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800252:	0f 83 b1 00 00 00    	jae    800309 <printnum+0x1bc>
  800258:	e9 2d ff ff ff       	jmp    80018a <printnum+0x3d>
  80025d:	8b 45 10             	mov    0x10(%ebp),%eax
  800260:	ba 00 00 00 00       	mov    $0x0,%edx
  800265:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800268:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80026b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800271:	83 fa 00             	cmp    $0x0,%edx
  800274:	77 37                	ja     8002ad <printnum+0x160>
  800276:	3b 45 10             	cmp    0x10(%ebp),%eax
  800279:	73 32                	jae    8002ad <printnum+0x160>
  80027b:	e9 16 ff ff ff       	jmp    800196 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	83 ec 04             	sub    $0x4,%esp
  800287:	ff 75 dc             	pushl  -0x24(%ebp)
  80028a:	ff 75 d8             	pushl  -0x28(%ebp)
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	e8 f8 0f 00 00       	call   801290 <__umoddi3>
  800298:	83 c4 14             	add    $0x14,%esp
  80029b:	0f be 80 31 14 80 00 	movsbl 0x801431(%eax),%eax
  8002a2:	50                   	push   %eax
  8002a3:	ff d7                	call   *%edi
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	e9 b3 00 00 00       	jmp    800360 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002b6:	50                   	push   %eax
  8002b7:	ff 75 10             	pushl  0x10(%ebp)
  8002ba:	83 ec 08             	sub    $0x8,%esp
  8002bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	e8 92 0e 00 00       	call   801160 <__udivdi3>
  8002ce:	83 c4 18             	add    $0x18,%esp
  8002d1:	52                   	push   %edx
  8002d2:	50                   	push   %eax
  8002d3:	89 f2                	mov    %esi,%edx
  8002d5:	89 f8                	mov    %edi,%eax
  8002d7:	e8 71 fe ff ff       	call   80014d <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002dc:	83 c4 18             	add    $0x18,%esp
  8002df:	56                   	push   %esi
  8002e0:	83 ec 04             	sub    $0x4,%esp
  8002e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ef:	e8 9c 0f 00 00       	call   801290 <__umoddi3>
  8002f4:	83 c4 14             	add    $0x14,%esp
  8002f7:	0f be 80 31 14 80 00 	movsbl 0x801431(%eax),%eax
  8002fe:	50                   	push   %eax
  8002ff:	ff d7                	call   *%edi
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	e9 d5 fe ff ff       	jmp    8001de <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	ff 75 18             	pushl  0x18(%ebp)
  80030f:	83 eb 01             	sub    $0x1,%ebx
  800312:	53                   	push   %ebx
  800313:	ff 75 10             	pushl  0x10(%ebp)
  800316:	83 ec 08             	sub    $0x8,%esp
  800319:	ff 75 dc             	pushl  -0x24(%ebp)
  80031c:	ff 75 d8             	pushl  -0x28(%ebp)
  80031f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800322:	ff 75 e0             	pushl  -0x20(%ebp)
  800325:	e8 36 0e 00 00       	call   801160 <__udivdi3>
  80032a:	83 c4 18             	add    $0x18,%esp
  80032d:	52                   	push   %edx
  80032e:	50                   	push   %eax
  80032f:	89 f2                	mov    %esi,%edx
  800331:	89 f8                	mov    %edi,%eax
  800333:	e8 15 fe ff ff       	call   80014d <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800338:	83 c4 18             	add    $0x18,%esp
  80033b:	56                   	push   %esi
  80033c:	83 ec 04             	sub    $0x4,%esp
  80033f:	ff 75 dc             	pushl  -0x24(%ebp)
  800342:	ff 75 d8             	pushl  -0x28(%ebp)
  800345:	ff 75 e4             	pushl  -0x1c(%ebp)
  800348:	ff 75 e0             	pushl  -0x20(%ebp)
  80034b:	e8 40 0f 00 00       	call   801290 <__umoddi3>
  800350:	83 c4 14             	add    $0x14,%esp
  800353:	0f be 80 31 14 80 00 	movsbl 0x801431(%eax),%eax
  80035a:	50                   	push   %eax
  80035b:	ff d7                	call   *%edi
  80035d:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800360:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800363:	5b                   	pop    %ebx
  800364:	5e                   	pop    %esi
  800365:	5f                   	pop    %edi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036b:	83 fa 01             	cmp    $0x1,%edx
  80036e:	7e 0e                	jle    80037e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 08             	lea    0x8(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	8b 52 04             	mov    0x4(%edx),%edx
  80037c:	eb 22                	jmp    8003a0 <getuint+0x38>
	else if (lflag)
  80037e:	85 d2                	test   %edx,%edx
  800380:	74 10                	je     800392 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 04             	lea    0x4(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	eb 0e                	jmp    8003a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ac:	8b 10                	mov    (%eax),%edx
  8003ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b1:	73 0a                	jae    8003bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003b6:	89 08                	mov    %ecx,(%eax)
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	88 02                	mov    %al,(%edx)
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c8:	50                   	push   %eax
  8003c9:	ff 75 10             	pushl  0x10(%ebp)
  8003cc:	ff 75 0c             	pushl  0xc(%ebp)
  8003cf:	ff 75 08             	pushl  0x8(%ebp)
  8003d2:	e8 05 00 00 00       	call   8003dc <vprintfmt>
	va_end(ap);
}
  8003d7:	83 c4 10             	add    $0x10,%esp
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	57                   	push   %edi
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	83 ec 2c             	sub    $0x2c,%esp
  8003e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003eb:	eb 03                	jmp    8003f0 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003ed:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f3:	8d 70 01             	lea    0x1(%eax),%esi
  8003f6:	0f b6 00             	movzbl (%eax),%eax
  8003f9:	83 f8 25             	cmp    $0x25,%eax
  8003fc:	74 27                	je     800425 <vprintfmt+0x49>
			if (ch == '\0')
  8003fe:	85 c0                	test   %eax,%eax
  800400:	75 0d                	jne    80040f <vprintfmt+0x33>
  800402:	e9 9d 04 00 00       	jmp    8008a4 <vprintfmt+0x4c8>
  800407:	85 c0                	test   %eax,%eax
  800409:	0f 84 95 04 00 00    	je     8008a4 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	53                   	push   %ebx
  800413:	50                   	push   %eax
  800414:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800416:	83 c6 01             	add    $0x1,%esi
  800419:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80041d:	83 c4 10             	add    $0x10,%esp
  800420:	83 f8 25             	cmp    $0x25,%eax
  800423:	75 e2                	jne    800407 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80042e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800435:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800443:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80044a:	eb 08                	jmp    800454 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80044f:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8d 46 01             	lea    0x1(%esi),%eax
  800457:	89 45 10             	mov    %eax,0x10(%ebp)
  80045a:	0f b6 06             	movzbl (%esi),%eax
  80045d:	0f b6 d0             	movzbl %al,%edx
  800460:	83 e8 23             	sub    $0x23,%eax
  800463:	3c 55                	cmp    $0x55,%al
  800465:	0f 87 fa 03 00 00    	ja     800865 <vprintfmt+0x489>
  80046b:	0f b6 c0             	movzbl %al,%eax
  80046e:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  800475:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800478:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80047c:	eb d6                	jmp    800454 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047e:	8d 42 d0             	lea    -0x30(%edx),%eax
  800481:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800484:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800488:	8d 50 d0             	lea    -0x30(%eax),%edx
  80048b:	83 fa 09             	cmp    $0x9,%edx
  80048e:	77 6b                	ja     8004fb <vprintfmt+0x11f>
  800490:	8b 75 10             	mov    0x10(%ebp),%esi
  800493:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800496:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800499:	eb 09                	jmp    8004a4 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80049e:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8004a2:	eb b0                	jmp    800454 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004a7:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004aa:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004ae:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b1:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004b4:	83 f9 09             	cmp    $0x9,%ecx
  8004b7:	76 eb                	jbe    8004a4 <vprintfmt+0xc8>
  8004b9:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004bc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004bf:	eb 3d                	jmp    8004fe <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	8b 00                	mov    (%eax),%eax
  8004cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d2:	eb 2a                	jmp    8004fe <vprintfmt+0x122>
  8004d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004de:	0f 49 d0             	cmovns %eax,%edx
  8004e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 10             	mov    0x10(%ebp),%esi
  8004e7:	e9 68 ff ff ff       	jmp    800454 <vprintfmt+0x78>
  8004ec:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ef:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f6:	e9 59 ff ff ff       	jmp    800454 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800502:	0f 89 4c ff ff ff    	jns    800454 <vprintfmt+0x78>
				width = precision, precision = -1;
  800508:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800515:	e9 3a ff ff ff       	jmp    800454 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051a:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800521:	e9 2e ff ff ff       	jmp    800454 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	53                   	push   %ebx
  800533:	ff 30                	pushl  (%eax)
  800535:	ff d7                	call   *%edi
			break;
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	e9 b1 fe ff ff       	jmp    8003f0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	99                   	cltd   
  80054b:	31 d0                	xor    %edx,%eax
  80054d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054f:	83 f8 08             	cmp    $0x8,%eax
  800552:	7f 0b                	jg     80055f <vprintfmt+0x183>
  800554:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  80055b:	85 d2                	test   %edx,%edx
  80055d:	75 15                	jne    800574 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80055f:	50                   	push   %eax
  800560:	68 49 14 80 00       	push   $0x801449
  800565:	53                   	push   %ebx
  800566:	57                   	push   %edi
  800567:	e8 53 fe ff ff       	call   8003bf <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	e9 7c fe ff ff       	jmp    8003f0 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800574:	52                   	push   %edx
  800575:	68 52 14 80 00       	push   $0x801452
  80057a:	53                   	push   %ebx
  80057b:	57                   	push   %edi
  80057c:	e8 3e fe ff ff       	call   8003bf <printfmt>
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	e9 67 fe ff ff       	jmp    8003f0 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800594:	85 c0                	test   %eax,%eax
  800596:	b9 42 14 80 00       	mov    $0x801442,%ecx
  80059b:	0f 45 c8             	cmovne %eax,%ecx
  80059e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a5:	7e 06                	jle    8005ad <vprintfmt+0x1d1>
  8005a7:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005ab:	75 19                	jne    8005c6 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b0:	8d 70 01             	lea    0x1(%eax),%esi
  8005b3:	0f b6 00             	movzbl (%eax),%eax
  8005b6:	0f be d0             	movsbl %al,%edx
  8005b9:	85 d2                	test   %edx,%edx
  8005bb:	0f 85 9f 00 00 00    	jne    800660 <vprintfmt+0x284>
  8005c1:	e9 8c 00 00 00       	jmp    800652 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005cc:	ff 75 cc             	pushl  -0x34(%ebp)
  8005cf:	e8 62 03 00 00       	call   800936 <strnlen>
  8005d4:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	85 c9                	test   %ecx,%ecx
  8005df:	0f 8e a6 02 00 00    	jle    80088b <vprintfmt+0x4af>
					putch(padc, putdat);
  8005e5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ec:	89 cb                	mov    %ecx,%ebx
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	ff 75 0c             	pushl  0xc(%ebp)
  8005f4:	56                   	push   %esi
  8005f5:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	83 eb 01             	sub    $0x1,%ebx
  8005fd:	75 ef                	jne    8005ee <vprintfmt+0x212>
  8005ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800605:	e9 81 02 00 00       	jmp    80088b <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060e:	74 1b                	je     80062b <vprintfmt+0x24f>
  800610:	0f be c0             	movsbl %al,%eax
  800613:	83 e8 20             	sub    $0x20,%eax
  800616:	83 f8 5e             	cmp    $0x5e,%eax
  800619:	76 10                	jbe    80062b <vprintfmt+0x24f>
					putch('?', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	ff 75 0c             	pushl  0xc(%ebp)
  800621:	6a 3f                	push   $0x3f
  800623:	ff 55 08             	call   *0x8(%ebp)
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 0d                	jmp    800638 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	52                   	push   %edx
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800638:	83 ef 01             	sub    $0x1,%edi
  80063b:	83 c6 01             	add    $0x1,%esi
  80063e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800642:	0f be d0             	movsbl %al,%edx
  800645:	85 d2                	test   %edx,%edx
  800647:	75 31                	jne    80067a <vprintfmt+0x29e>
  800649:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80064c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80064f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800652:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800655:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800659:	7f 33                	jg     80068e <vprintfmt+0x2b2>
  80065b:	e9 90 fd ff ff       	jmp    8003f0 <vprintfmt+0x14>
  800660:	89 7d 08             	mov    %edi,0x8(%ebp)
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800666:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800669:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80066c:	eb 0c                	jmp    80067a <vprintfmt+0x29e>
  80066e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800674:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800677:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067a:	85 db                	test   %ebx,%ebx
  80067c:	78 8c                	js     80060a <vprintfmt+0x22e>
  80067e:	83 eb 01             	sub    $0x1,%ebx
  800681:	79 87                	jns    80060a <vprintfmt+0x22e>
  800683:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800686:	8b 7d 08             	mov    0x8(%ebp),%edi
  800689:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80068c:	eb c4                	jmp    800652 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 20                	push   $0x20
  800694:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	83 ee 01             	sub    $0x1,%esi
  80069c:	75 f0                	jne    80068e <vprintfmt+0x2b2>
  80069e:	e9 4d fd ff ff       	jmp    8003f0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a3:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8006a7:	7e 16                	jle    8006bf <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 08             	lea    0x8(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b2:	8b 50 04             	mov    0x4(%eax),%edx
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006bd:	eb 34                	jmp    8006f3 <vprintfmt+0x317>
	else if (lflag)
  8006bf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006c3:	74 18                	je     8006dd <vprintfmt+0x301>
		return va_arg(*ap, long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 04             	lea    0x4(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	8b 30                	mov    (%eax),%esi
  8006d0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006d3:	89 f0                	mov    %esi,%eax
  8006d5:	c1 f8 1f             	sar    $0x1f,%eax
  8006d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006db:	eb 16                	jmp    8006f3 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 30                	mov    (%eax),%esi
  8006e8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	c1 f8 1f             	sar    $0x1f,%eax
  8006f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8006ff:	85 d2                	test   %edx,%edx
  800701:	79 28                	jns    80072b <vprintfmt+0x34f>
				putch('-', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	53                   	push   %ebx
  800707:	6a 2d                	push   $0x2d
  800709:	ff d7                	call   *%edi
				num = -(long long) num;
  80070b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80070e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800711:	f7 d8                	neg    %eax
  800713:	83 d2 00             	adc    $0x0,%edx
  800716:	f7 da                	neg    %edx
  800718:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80071e:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800721:	b8 0a 00 00 00       	mov    $0xa,%eax
  800726:	e9 b2 00 00 00       	jmp    8007dd <vprintfmt+0x401>
  80072b:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800730:	85 c9                	test   %ecx,%ecx
  800732:	0f 84 a5 00 00 00    	je     8007dd <vprintfmt+0x401>
				putch('+', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 2b                	push   $0x2b
  80073e:	ff d7                	call   *%edi
  800740:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800743:	b8 0a 00 00 00       	mov    $0xa,%eax
  800748:	e9 90 00 00 00       	jmp    8007dd <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  80074d:	85 c9                	test   %ecx,%ecx
  80074f:	74 0b                	je     80075c <vprintfmt+0x380>
				putch('+', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 2b                	push   $0x2b
  800757:	ff d7                	call   *%edi
  800759:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  80075c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	e8 01 fc ff ff       	call   800368 <getuint>
  800767:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80076d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800772:	eb 69                	jmp    8007dd <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	53                   	push   %ebx
  800778:	6a 30                	push   $0x30
  80077a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80077c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80077f:	8d 45 14             	lea    0x14(%ebp),%eax
  800782:	e8 e1 fb ff ff       	call   800368 <getuint>
  800787:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80078d:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800790:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800795:	eb 46                	jmp    8007dd <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 30                	push   $0x30
  80079d:	ff d7                	call   *%edi
			putch('x', putdat);
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 78                	push   $0x78
  8007a5:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8d 50 04             	lea    0x4(%eax),%edx
  8007ad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b0:	8b 00                	mov    (%eax),%eax
  8007b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007bd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007c5:	eb 16                	jmp    8007dd <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cd:	e8 96 fb ff ff       	call   800368 <getuint>
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8007d8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007dd:	83 ec 0c             	sub    $0xc,%esp
  8007e0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007e4:	56                   	push   %esi
  8007e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007e8:	50                   	push   %eax
  8007e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8007ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8007ef:	89 da                	mov    %ebx,%edx
  8007f1:	89 f8                	mov    %edi,%eax
  8007f3:	e8 55 f9 ff ff       	call   80014d <printnum>
			break;
  8007f8:	83 c4 20             	add    $0x20,%esp
  8007fb:	e9 f0 fb ff ff       	jmp    8003f0 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8d 50 04             	lea    0x4(%eax),%edx
  800806:	89 55 14             	mov    %edx,0x14(%ebp)
  800809:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  80080b:	85 f6                	test   %esi,%esi
  80080d:	75 1a                	jne    800829 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	68 e8 14 80 00       	push   $0x8014e8
  800817:	68 52 14 80 00       	push   $0x801452
  80081c:	e8 18 f9 ff ff       	call   800139 <cprintf>
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	e9 c7 fb ff ff       	jmp    8003f0 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800829:	0f b6 03             	movzbl (%ebx),%eax
  80082c:	84 c0                	test   %al,%al
  80082e:	79 1f                	jns    80084f <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	68 20 15 80 00       	push   $0x801520
  800838:	68 52 14 80 00       	push   $0x801452
  80083d:	e8 f7 f8 ff ff       	call   800139 <cprintf>
						*tmp = *(char *)putdat;
  800842:	0f b6 03             	movzbl (%ebx),%eax
  800845:	88 06                	mov    %al,(%esi)
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	e9 a1 fb ff ff       	jmp    8003f0 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  80084f:	88 06                	mov    %al,(%esi)
  800851:	e9 9a fb ff ff       	jmp    8003f0 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	53                   	push   %ebx
  80085a:	52                   	push   %edx
  80085b:	ff d7                	call   *%edi
			break;
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	e9 8b fb ff ff       	jmp    8003f0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 25                	push   $0x25
  80086b:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800874:	0f 84 73 fb ff ff    	je     8003ed <vprintfmt+0x11>
  80087a:	83 ee 01             	sub    $0x1,%esi
  80087d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800881:	75 f7                	jne    80087a <vprintfmt+0x49e>
  800883:	89 75 10             	mov    %esi,0x10(%ebp)
  800886:	e9 65 fb ff ff       	jmp    8003f0 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80088e:	8d 70 01             	lea    0x1(%eax),%esi
  800891:	0f b6 00             	movzbl (%eax),%eax
  800894:	0f be d0             	movsbl %al,%edx
  800897:	85 d2                	test   %edx,%edx
  800899:	0f 85 cf fd ff ff    	jne    80066e <vprintfmt+0x292>
  80089f:	e9 4c fb ff ff       	jmp    8003f0 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a7:	5b                   	pop    %ebx
  8008a8:	5e                   	pop    %esi
  8008a9:	5f                   	pop    %edi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	83 ec 18             	sub    $0x18,%esp
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008bb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008bf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	74 26                	je     8008f3 <vsnprintf+0x47>
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	7e 22                	jle    8008f3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d1:	ff 75 14             	pushl  0x14(%ebp)
  8008d4:	ff 75 10             	pushl  0x10(%ebp)
  8008d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008da:	50                   	push   %eax
  8008db:	68 a2 03 80 00       	push   $0x8003a2
  8008e0:	e8 f7 fa ff ff       	call   8003dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	eb 05                	jmp    8008f8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800900:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800903:	50                   	push   %eax
  800904:	ff 75 10             	pushl  0x10(%ebp)
  800907:	ff 75 0c             	pushl  0xc(%ebp)
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 9a ff ff ff       	call   8008ac <vsnprintf>
	va_end(ap);

	return rc;
}
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80091a:	80 3a 00             	cmpb   $0x0,(%edx)
  80091d:	74 10                	je     80092f <strlen+0x1b>
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800924:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800927:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80092b:	75 f7                	jne    800924 <strlen+0x10>
  80092d:	eb 05                	jmp    800934 <strlen+0x20>
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80093d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800940:	85 c9                	test   %ecx,%ecx
  800942:	74 1c                	je     800960 <strnlen+0x2a>
  800944:	80 3b 00             	cmpb   $0x0,(%ebx)
  800947:	74 1e                	je     800967 <strnlen+0x31>
  800949:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80094e:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800950:	39 ca                	cmp    %ecx,%edx
  800952:	74 18                	je     80096c <strnlen+0x36>
  800954:	83 c2 01             	add    $0x1,%edx
  800957:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80095c:	75 f0                	jne    80094e <strnlen+0x18>
  80095e:	eb 0c                	jmp    80096c <strnlen+0x36>
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
  800965:	eb 05                	jmp    80096c <strnlen+0x36>
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80096c:	5b                   	pop    %ebx
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800979:	89 c2                	mov    %eax,%edx
  80097b:	83 c2 01             	add    $0x1,%edx
  80097e:	83 c1 01             	add    $0x1,%ecx
  800981:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800985:	88 5a ff             	mov    %bl,-0x1(%edx)
  800988:	84 db                	test   %bl,%bl
  80098a:	75 ef                	jne    80097b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098c:	5b                   	pop    %ebx
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800996:	53                   	push   %ebx
  800997:	e8 78 ff ff ff       	call   800914 <strlen>
  80099c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	01 d8                	add    %ebx,%eax
  8009a4:	50                   	push   %eax
  8009a5:	e8 c5 ff ff ff       	call   80096f <strcpy>
	return dst;
}
  8009aa:	89 d8                	mov    %ebx,%eax
  8009ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	74 17                	je     8009da <strncpy+0x29>
  8009c3:	01 f3                	add    %esi,%ebx
  8009c5:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	0f b6 02             	movzbl (%edx),%eax
  8009cd:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d0:	80 3a 01             	cmpb   $0x1,(%edx)
  8009d3:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d6:	39 cb                	cmp    %ecx,%ebx
  8009d8:	75 ed                	jne    8009c7 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009da:	89 f0                	mov    %esi,%eax
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009eb:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f0:	85 d2                	test   %edx,%edx
  8009f2:	74 35                	je     800a29 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  8009f4:	89 d0                	mov    %edx,%eax
  8009f6:	83 e8 01             	sub    $0x1,%eax
  8009f9:	74 25                	je     800a20 <strlcpy+0x40>
  8009fb:	0f b6 0b             	movzbl (%ebx),%ecx
  8009fe:	84 c9                	test   %cl,%cl
  800a00:	74 22                	je     800a24 <strlcpy+0x44>
  800a02:	8d 53 01             	lea    0x1(%ebx),%edx
  800a05:	01 c3                	add    %eax,%ebx
  800a07:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a0f:	39 da                	cmp    %ebx,%edx
  800a11:	74 13                	je     800a26 <strlcpy+0x46>
  800a13:	83 c2 01             	add    $0x1,%edx
  800a16:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a1a:	84 c9                	test   %cl,%cl
  800a1c:	75 eb                	jne    800a09 <strlcpy+0x29>
  800a1e:	eb 06                	jmp    800a26 <strlcpy+0x46>
  800a20:	89 f0                	mov    %esi,%eax
  800a22:	eb 02                	jmp    800a26 <strlcpy+0x46>
  800a24:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a26:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a29:	29 f0                	sub    %esi,%eax
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a35:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a38:	0f b6 01             	movzbl (%ecx),%eax
  800a3b:	84 c0                	test   %al,%al
  800a3d:	74 15                	je     800a54 <strcmp+0x25>
  800a3f:	3a 02                	cmp    (%edx),%al
  800a41:	75 11                	jne    800a54 <strcmp+0x25>
		p++, q++;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a49:	0f b6 01             	movzbl (%ecx),%eax
  800a4c:	84 c0                	test   %al,%al
  800a4e:	74 04                	je     800a54 <strcmp+0x25>
  800a50:	3a 02                	cmp    (%edx),%al
  800a52:	74 ef                	je     800a43 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a54:	0f b6 c0             	movzbl %al,%eax
  800a57:	0f b6 12             	movzbl (%edx),%edx
  800a5a:	29 d0                	sub    %edx,%eax
}
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a69:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a6c:	85 f6                	test   %esi,%esi
  800a6e:	74 29                	je     800a99 <strncmp+0x3b>
  800a70:	0f b6 03             	movzbl (%ebx),%eax
  800a73:	84 c0                	test   %al,%al
  800a75:	74 30                	je     800aa7 <strncmp+0x49>
  800a77:	3a 02                	cmp    (%edx),%al
  800a79:	75 2c                	jne    800aa7 <strncmp+0x49>
  800a7b:	8d 43 01             	lea    0x1(%ebx),%eax
  800a7e:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a80:	89 c3                	mov    %eax,%ebx
  800a82:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a85:	39 c6                	cmp    %eax,%esi
  800a87:	74 17                	je     800aa0 <strncmp+0x42>
  800a89:	0f b6 08             	movzbl (%eax),%ecx
  800a8c:	84 c9                	test   %cl,%cl
  800a8e:	74 17                	je     800aa7 <strncmp+0x49>
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	3a 0a                	cmp    (%edx),%cl
  800a95:	74 e9                	je     800a80 <strncmp+0x22>
  800a97:	eb 0e                	jmp    800aa7 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9e:	eb 0f                	jmp    800aaf <strncmp+0x51>
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa5:	eb 08                	jmp    800aaf <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa7:	0f b6 03             	movzbl (%ebx),%eax
  800aaa:	0f b6 12             	movzbl (%edx),%edx
  800aad:	29 d0                	sub    %edx,%eax
}
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	53                   	push   %ebx
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	74 1d                	je     800ae1 <strchr+0x2e>
  800ac4:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ac6:	38 d3                	cmp    %dl,%bl
  800ac8:	75 06                	jne    800ad0 <strchr+0x1d>
  800aca:	eb 1a                	jmp    800ae6 <strchr+0x33>
  800acc:	38 ca                	cmp    %cl,%dl
  800ace:	74 16                	je     800ae6 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	0f b6 10             	movzbl (%eax),%edx
  800ad6:	84 d2                	test   %dl,%dl
  800ad8:	75 f2                	jne    800acc <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	eb 05                	jmp    800ae6 <strchr+0x33>
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	53                   	push   %ebx
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800af3:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800af6:	38 d3                	cmp    %dl,%bl
  800af8:	74 14                	je     800b0e <strfind+0x25>
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	84 db                	test   %bl,%bl
  800afe:	74 0e                	je     800b0e <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b06:	38 ca                	cmp    %cl,%dl
  800b08:	74 04                	je     800b0e <strfind+0x25>
  800b0a:	84 d2                	test   %dl,%dl
  800b0c:	75 f2                	jne    800b00 <strfind+0x17>
			break;
	return (char *) s;
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1d:	85 c9                	test   %ecx,%ecx
  800b1f:	74 36                	je     800b57 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b27:	75 28                	jne    800b51 <memset+0x40>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 23                	jne    800b51 <memset+0x40>
		c &= 0xFF;
  800b2e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	c1 e3 08             	shl    $0x8,%ebx
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	c1 e6 18             	shl    $0x18,%esi
  800b3c:	89 d0                	mov    %edx,%eax
  800b3e:	c1 e0 10             	shl    $0x10,%eax
  800b41:	09 f0                	or     %esi,%eax
  800b43:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b45:	89 d8                	mov    %ebx,%eax
  800b47:	09 d0                	or     %edx,%eax
  800b49:	c1 e9 02             	shr    $0x2,%ecx
  800b4c:	fc                   	cld    
  800b4d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4f:	eb 06                	jmp    800b57 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b54:	fc                   	cld    
  800b55:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b57:	89 f8                	mov    %edi,%eax
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6c:	39 c6                	cmp    %eax,%esi
  800b6e:	73 35                	jae    800ba5 <memmove+0x47>
  800b70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b73:	39 d0                	cmp    %edx,%eax
  800b75:	73 2e                	jae    800ba5 <memmove+0x47>
		s += n;
		d += n;
  800b77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	09 fe                	or     %edi,%esi
  800b7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b84:	75 13                	jne    800b99 <memmove+0x3b>
  800b86:	f6 c1 03             	test   $0x3,%cl
  800b89:	75 0e                	jne    800b99 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b8b:	83 ef 04             	sub    $0x4,%edi
  800b8e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b91:	c1 e9 02             	shr    $0x2,%ecx
  800b94:	fd                   	std    
  800b95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b97:	eb 09                	jmp    800ba2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b99:	83 ef 01             	sub    $0x1,%edi
  800b9c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9f:	fd                   	std    
  800ba0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba2:	fc                   	cld    
  800ba3:	eb 1d                	jmp    800bc2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba5:	89 f2                	mov    %esi,%edx
  800ba7:	09 c2                	or     %eax,%edx
  800ba9:	f6 c2 03             	test   $0x3,%dl
  800bac:	75 0f                	jne    800bbd <memmove+0x5f>
  800bae:	f6 c1 03             	test   $0x3,%cl
  800bb1:	75 0a                	jne    800bbd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb3:	c1 e9 02             	shr    $0x2,%ecx
  800bb6:	89 c7                	mov    %eax,%edi
  800bb8:	fc                   	cld    
  800bb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbb:	eb 05                	jmp    800bc2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbd:	89 c7                	mov    %eax,%edi
  800bbf:	fc                   	cld    
  800bc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc9:	ff 75 10             	pushl  0x10(%ebp)
  800bcc:	ff 75 0c             	pushl  0xc(%ebp)
  800bcf:	ff 75 08             	pushl  0x8(%ebp)
  800bd2:	e8 87 ff ff ff       	call   800b5e <memmove>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800be2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be5:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be8:	85 c0                	test   %eax,%eax
  800bea:	74 39                	je     800c25 <memcmp+0x4c>
  800bec:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800bef:	0f b6 13             	movzbl (%ebx),%edx
  800bf2:	0f b6 0e             	movzbl (%esi),%ecx
  800bf5:	38 ca                	cmp    %cl,%dl
  800bf7:	75 17                	jne    800c10 <memcmp+0x37>
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfe:	eb 1a                	jmp    800c1a <memcmp+0x41>
  800c00:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c0c:	38 ca                	cmp    %cl,%dl
  800c0e:	74 0a                	je     800c1a <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c10:	0f b6 c2             	movzbl %dl,%eax
  800c13:	0f b6 c9             	movzbl %cl,%ecx
  800c16:	29 c8                	sub    %ecx,%eax
  800c18:	eb 10                	jmp    800c2a <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1a:	39 f8                	cmp    %edi,%eax
  800c1c:	75 e2                	jne    800c00 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	eb 05                	jmp    800c2a <memcmp+0x51>
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	53                   	push   %ebx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c36:	89 d0                	mov    %edx,%eax
  800c38:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c3b:	39 c2                	cmp    %eax,%edx
  800c3d:	73 1d                	jae    800c5c <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c43:	0f b6 0a             	movzbl (%edx),%ecx
  800c46:	39 d9                	cmp    %ebx,%ecx
  800c48:	75 09                	jne    800c53 <memfind+0x24>
  800c4a:	eb 14                	jmp    800c60 <memfind+0x31>
  800c4c:	0f b6 0a             	movzbl (%edx),%ecx
  800c4f:	39 d9                	cmp    %ebx,%ecx
  800c51:	74 11                	je     800c64 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c53:	83 c2 01             	add    $0x1,%edx
  800c56:	39 d0                	cmp    %edx,%eax
  800c58:	75 f2                	jne    800c4c <memfind+0x1d>
  800c5a:	eb 0a                	jmp    800c66 <memfind+0x37>
  800c5c:	89 d0                	mov    %edx,%eax
  800c5e:	eb 06                	jmp    800c66 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c60:	89 d0                	mov    %edx,%eax
  800c62:	eb 02                	jmp    800c66 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c64:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c66:	5b                   	pop    %ebx
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c75:	0f b6 01             	movzbl (%ecx),%eax
  800c78:	3c 20                	cmp    $0x20,%al
  800c7a:	74 04                	je     800c80 <strtol+0x17>
  800c7c:	3c 09                	cmp    $0x9,%al
  800c7e:	75 0e                	jne    800c8e <strtol+0x25>
		s++;
  800c80:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c83:	0f b6 01             	movzbl (%ecx),%eax
  800c86:	3c 20                	cmp    $0x20,%al
  800c88:	74 f6                	je     800c80 <strtol+0x17>
  800c8a:	3c 09                	cmp    $0x9,%al
  800c8c:	74 f2                	je     800c80 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c8e:	3c 2b                	cmp    $0x2b,%al
  800c90:	75 0a                	jne    800c9c <strtol+0x33>
		s++;
  800c92:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c95:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9a:	eb 11                	jmp    800cad <strtol+0x44>
  800c9c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ca1:	3c 2d                	cmp    $0x2d,%al
  800ca3:	75 08                	jne    800cad <strtol+0x44>
		s++, neg = 1;
  800ca5:	83 c1 01             	add    $0x1,%ecx
  800ca8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cb3:	75 15                	jne    800cca <strtol+0x61>
  800cb5:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb8:	75 10                	jne    800cca <strtol+0x61>
  800cba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cbe:	75 7c                	jne    800d3c <strtol+0xd3>
		s += 2, base = 16;
  800cc0:	83 c1 02             	add    $0x2,%ecx
  800cc3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cc8:	eb 16                	jmp    800ce0 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cca:	85 db                	test   %ebx,%ebx
  800ccc:	75 12                	jne    800ce0 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cce:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd3:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd6:	75 08                	jne    800ce0 <strtol+0x77>
		s++, base = 8;
  800cd8:	83 c1 01             	add    $0x1,%ecx
  800cdb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce8:	0f b6 11             	movzbl (%ecx),%edx
  800ceb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cee:	89 f3                	mov    %esi,%ebx
  800cf0:	80 fb 09             	cmp    $0x9,%bl
  800cf3:	77 08                	ja     800cfd <strtol+0x94>
			dig = *s - '0';
  800cf5:	0f be d2             	movsbl %dl,%edx
  800cf8:	83 ea 30             	sub    $0x30,%edx
  800cfb:	eb 22                	jmp    800d1f <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800cfd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d00:	89 f3                	mov    %esi,%ebx
  800d02:	80 fb 19             	cmp    $0x19,%bl
  800d05:	77 08                	ja     800d0f <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d07:	0f be d2             	movsbl %dl,%edx
  800d0a:	83 ea 57             	sub    $0x57,%edx
  800d0d:	eb 10                	jmp    800d1f <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d0f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d12:	89 f3                	mov    %esi,%ebx
  800d14:	80 fb 19             	cmp    $0x19,%bl
  800d17:	77 16                	ja     800d2f <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d19:	0f be d2             	movsbl %dl,%edx
  800d1c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d1f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d22:	7d 0b                	jge    800d2f <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d24:	83 c1 01             	add    $0x1,%ecx
  800d27:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d2b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d2d:	eb b9                	jmp    800ce8 <strtol+0x7f>

	if (endptr)
  800d2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d33:	74 0d                	je     800d42 <strtol+0xd9>
		*endptr = (char *) s;
  800d35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d38:	89 0e                	mov    %ecx,(%esi)
  800d3a:	eb 06                	jmp    800d42 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d3c:	85 db                	test   %ebx,%ebx
  800d3e:	74 98                	je     800cd8 <strtol+0x6f>
  800d40:	eb 9e                	jmp    800ce0 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d42:	89 c2                	mov    %eax,%edx
  800d44:	f7 da                	neg    %edx
  800d46:	85 ff                	test   %edi,%edi
  800d48:	0f 45 c2             	cmovne %edx,%eax
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 c3                	mov    %eax,%ebx
  800d62:	89 c7                	mov    %eax,%edi
  800d64:	51                   	push   %ecx
  800d65:	52                   	push   %edx
  800d66:	53                   	push   %ebx
  800d67:	56                   	push   %esi
  800d68:	57                   	push   %edi
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	8d 35 74 0d 80 00    	lea    0x800d74,%esi
  800d72:	0f 34                	sysenter 

00800d74 <label_21>:
  800d74:	89 ec                	mov    %ebp,%esp
  800d76:	5d                   	pop    %ebp
  800d77:	5f                   	pop    %edi
  800d78:	5e                   	pop    %esi
  800d79:	5b                   	pop    %ebx
  800d7a:	5a                   	pop    %edx
  800d7b:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8f:	89 ca                	mov    %ecx,%edx
  800d91:	89 cb                	mov    %ecx,%ebx
  800d93:	89 cf                	mov    %ecx,%edi
  800d95:	51                   	push   %ecx
  800d96:	52                   	push   %edx
  800d97:	53                   	push   %ebx
  800d98:	56                   	push   %esi
  800d99:	57                   	push   %edi
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	8d 35 a5 0d 80 00    	lea    0x800da5,%esi
  800da3:	0f 34                	sysenter 

00800da5 <label_55>:
  800da5:	89 ec                	mov    %ebp,%esp
  800da7:	5d                   	pop    %ebp
  800da8:	5f                   	pop    %edi
  800da9:	5e                   	pop    %esi
  800daa:	5b                   	pop    %ebx
  800dab:	5a                   	pop    %edx
  800dac:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dad:	5b                   	pop    %ebx
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 d9                	mov    %ebx,%ecx
  800dc5:	89 df                	mov    %ebx,%edi
  800dc7:	51                   	push   %ecx
  800dc8:	52                   	push   %edx
  800dc9:	53                   	push   %ebx
  800dca:	56                   	push   %esi
  800dcb:	57                   	push   %edi
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	8d 35 d7 0d 80 00    	lea    0x800dd7,%esi
  800dd5:	0f 34                	sysenter 

00800dd7 <label_90>:
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	5f                   	pop    %edi
  800ddb:	5e                   	pop    %esi
  800ddc:	5b                   	pop    %ebx
  800ddd:	5a                   	pop    %edx
  800dde:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 03                	push   $0x3
  800de9:	68 04 17 80 00       	push   $0x801704
  800dee:	6a 30                	push   $0x30
  800df0:	68 21 17 80 00       	push   $0x801721
  800df5:	e8 06 03 00 00       	call   801100 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e10:	89 ca                	mov    %ecx,%edx
  800e12:	89 cb                	mov    %ecx,%ebx
  800e14:	89 cf                	mov    %ecx,%edi
  800e16:	51                   	push   %ecx
  800e17:	52                   	push   %edx
  800e18:	53                   	push   %ebx
  800e19:	56                   	push   %esi
  800e1a:	57                   	push   %edi
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	8d 35 26 0e 80 00    	lea    0x800e26,%esi
  800e24:	0f 34                	sysenter 

00800e26 <label_139>:
  800e26:	89 ec                	mov    %ebp,%esp
  800e28:	5d                   	pop    %ebp
  800e29:	5f                   	pop    %edi
  800e2a:	5e                   	pop    %esi
  800e2b:	5b                   	pop    %ebx
  800e2c:	5a                   	pop    %edx
  800e2d:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e2e:	5b                   	pop    %ebx
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e37:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3c:	b8 04 00 00 00       	mov    $0x4,%eax
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 fb                	mov    %edi,%ebx
  800e49:	51                   	push   %ecx
  800e4a:	52                   	push   %edx
  800e4b:	53                   	push   %ebx
  800e4c:	56                   	push   %esi
  800e4d:	57                   	push   %edi
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	8d 35 59 0e 80 00    	lea    0x800e59,%esi
  800e57:	0f 34                	sysenter 

00800e59 <label_174>:
  800e59:	89 ec                	mov    %ebp,%esp
  800e5b:	5d                   	pop    %ebp
  800e5c:	5f                   	pop    %edi
  800e5d:	5e                   	pop    %esi
  800e5e:	5b                   	pop    %ebx
  800e5f:	5a                   	pop    %edx
  800e60:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e61:	5b                   	pop    %ebx
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_yield>:

void
sys_yield(void)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e74:	89 d1                	mov    %edx,%ecx
  800e76:	89 d3                	mov    %edx,%ebx
  800e78:	89 d7                	mov    %edx,%edi
  800e7a:	51                   	push   %ecx
  800e7b:	52                   	push   %edx
  800e7c:	53                   	push   %ebx
  800e7d:	56                   	push   %esi
  800e7e:	57                   	push   %edi
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	8d 35 8a 0e 80 00    	lea    0x800e8a,%esi
  800e88:	0f 34                	sysenter 

00800e8a <label_209>:
  800e8a:	89 ec                	mov    %ebp,%esp
  800e8c:	5d                   	pop    %ebp
  800e8d:	5f                   	pop    %edi
  800e8e:	5e                   	pop    %esi
  800e8f:	5b                   	pop    %ebx
  800e90:	5a                   	pop    %edx
  800e91:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e92:	5b                   	pop    %ebx
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800ea0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eae:	51                   	push   %ecx
  800eaf:	52                   	push   %edx
  800eb0:	53                   	push   %ebx
  800eb1:	56                   	push   %esi
  800eb2:	57                   	push   %edi
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	8d 35 be 0e 80 00    	lea    0x800ebe,%esi
  800ebc:	0f 34                	sysenter 

00800ebe <label_244>:
  800ebe:	89 ec                	mov    %ebp,%esp
  800ec0:	5d                   	pop    %ebp
  800ec1:	5f                   	pop    %edi
  800ec2:	5e                   	pop    %esi
  800ec3:	5b                   	pop    %ebx
  800ec4:	5a                   	pop    %edx
  800ec5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	7e 17                	jle    800ee1 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	50                   	push   %eax
  800ece:	6a 05                	push   $0x5
  800ed0:	68 04 17 80 00       	push   $0x801704
  800ed5:	6a 30                	push   $0x30
  800ed7:	68 21 17 80 00       	push   $0x801721
  800edc:	e8 1f 02 00 00       	call   801100 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ee1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	53                   	push   %ebx
  800eed:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef9:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800efc:	8b 45 10             	mov    0x10(%ebp),%eax
  800eff:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800f02:	8b 45 14             	mov    0x14(%ebp),%eax
  800f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800f08:	8b 45 18             	mov    0x18(%ebp),%eax
  800f0b:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f0e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f16:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1b:	89 cb                	mov    %ecx,%ebx
  800f1d:	89 cf                	mov    %ecx,%edi
  800f1f:	51                   	push   %ecx
  800f20:	52                   	push   %edx
  800f21:	53                   	push   %ebx
  800f22:	56                   	push   %esi
  800f23:	57                   	push   %edi
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	8d 35 2f 0f 80 00    	lea    0x800f2f,%esi
  800f2d:	0f 34                	sysenter 

00800f2f <label_304>:
  800f2f:	89 ec                	mov    %ebp,%esp
  800f31:	5d                   	pop    %ebp
  800f32:	5f                   	pop    %edi
  800f33:	5e                   	pop    %esi
  800f34:	5b                   	pop    %ebx
  800f35:	5a                   	pop    %edx
  800f36:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f37:	85 c0                	test   %eax,%eax
  800f39:	7e 17                	jle    800f52 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	50                   	push   %eax
  800f3f:	6a 06                	push   $0x6
  800f41:	68 04 17 80 00       	push   $0x801704
  800f46:	6a 30                	push   $0x30
  800f48:	68 21 17 80 00       	push   $0x801721
  800f4d:	e8 ae 01 00 00       	call   801100 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  800f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f63:	b8 07 00 00 00       	mov    $0x7,%eax
  800f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6e:	89 fb                	mov    %edi,%ebx
  800f70:	51                   	push   %ecx
  800f71:	52                   	push   %edx
  800f72:	53                   	push   %ebx
  800f73:	56                   	push   %esi
  800f74:	57                   	push   %edi
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	8d 35 80 0f 80 00    	lea    0x800f80,%esi
  800f7e:	0f 34                	sysenter 

00800f80 <label_353>:
  800f80:	89 ec                	mov    %ebp,%esp
  800f82:	5d                   	pop    %ebp
  800f83:	5f                   	pop    %edi
  800f84:	5e                   	pop    %esi
  800f85:	5b                   	pop    %ebx
  800f86:	5a                   	pop    %edx
  800f87:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	7e 17                	jle    800fa3 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	50                   	push   %eax
  800f90:	6a 07                	push   $0x7
  800f92:	68 04 17 80 00       	push   $0x801704
  800f97:	6a 30                	push   $0x30
  800f99:	68 21 17 80 00       	push   $0x801721
  800f9e:	e8 5d 01 00 00       	call   801100 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800faf:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	89 fb                	mov    %edi,%ebx
  800fc1:	51                   	push   %ecx
  800fc2:	52                   	push   %edx
  800fc3:	53                   	push   %ebx
  800fc4:	56                   	push   %esi
  800fc5:	57                   	push   %edi
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	8d 35 d1 0f 80 00    	lea    0x800fd1,%esi
  800fcf:	0f 34                	sysenter 

00800fd1 <label_402>:
  800fd1:	89 ec                	mov    %ebp,%esp
  800fd3:	5d                   	pop    %ebp
  800fd4:	5f                   	pop    %edi
  800fd5:	5e                   	pop    %esi
  800fd6:	5b                   	pop    %ebx
  800fd7:	5a                   	pop    %edx
  800fd8:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	7e 17                	jle    800ff4 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdd:	83 ec 0c             	sub    $0xc,%esp
  800fe0:	50                   	push   %eax
  800fe1:	6a 09                	push   $0x9
  800fe3:	68 04 17 80 00       	push   $0x801704
  800fe8:	6a 30                	push   $0x30
  800fea:	68 21 17 80 00       	push   $0x801721
  800fef:	e8 0c 01 00 00       	call   801100 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ff4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5f                   	pop    %edi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	57                   	push   %edi
  800fff:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801000:	bf 00 00 00 00       	mov    $0x0,%edi
  801005:	b8 0a 00 00 00       	mov    $0xa,%eax
  80100a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100d:	8b 55 08             	mov    0x8(%ebp),%edx
  801010:	89 fb                	mov    %edi,%ebx
  801012:	51                   	push   %ecx
  801013:	52                   	push   %edx
  801014:	53                   	push   %ebx
  801015:	56                   	push   %esi
  801016:	57                   	push   %edi
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	8d 35 22 10 80 00    	lea    0x801022,%esi
  801020:	0f 34                	sysenter 

00801022 <label_451>:
  801022:	89 ec                	mov    %ebp,%esp
  801024:	5d                   	pop    %ebp
  801025:	5f                   	pop    %edi
  801026:	5e                   	pop    %esi
  801027:	5b                   	pop    %ebx
  801028:	5a                   	pop    %edx
  801029:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80102a:	85 c0                	test   %eax,%eax
  80102c:	7e 17                	jle    801045 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	50                   	push   %eax
  801032:	6a 0a                	push   $0xa
  801034:	68 04 17 80 00       	push   $0x801704
  801039:	6a 30                	push   $0x30
  80103b:	68 21 17 80 00       	push   $0x801721
  801040:	e8 bb 00 00 00       	call   801100 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801045:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801048:	5b                   	pop    %ebx
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	57                   	push   %edi
  801050:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801051:	b8 0c 00 00 00       	mov    $0xc,%eax
  801056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801059:	8b 55 08             	mov    0x8(%ebp),%edx
  80105c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80105f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801062:	51                   	push   %ecx
  801063:	52                   	push   %edx
  801064:	53                   	push   %ebx
  801065:	56                   	push   %esi
  801066:	57                   	push   %edi
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	8d 35 72 10 80 00    	lea    0x801072,%esi
  801070:	0f 34                	sysenter 

00801072 <label_502>:
  801072:	89 ec                	mov    %ebp,%esp
  801074:	5d                   	pop    %ebp
  801075:	5f                   	pop    %edi
  801076:	5e                   	pop    %esi
  801077:	5b                   	pop    %ebx
  801078:	5a                   	pop    %edx
  801079:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80107a:	5b                   	pop    %ebx
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	57                   	push   %edi
  801082:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801083:	bb 00 00 00 00       	mov    $0x0,%ebx
  801088:	b8 0d 00 00 00       	mov    $0xd,%eax
  80108d:	8b 55 08             	mov    0x8(%ebp),%edx
  801090:	89 d9                	mov    %ebx,%ecx
  801092:	89 df                	mov    %ebx,%edi
  801094:	51                   	push   %ecx
  801095:	52                   	push   %edx
  801096:	53                   	push   %ebx
  801097:	56                   	push   %esi
  801098:	57                   	push   %edi
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	8d 35 a4 10 80 00    	lea    0x8010a4,%esi
  8010a2:	0f 34                	sysenter 

008010a4 <label_537>:
  8010a4:	89 ec                	mov    %ebp,%esp
  8010a6:	5d                   	pop    %ebp
  8010a7:	5f                   	pop    %edi
  8010a8:	5e                   	pop    %esi
  8010a9:	5b                   	pop    %ebx
  8010aa:	5a                   	pop    %edx
  8010ab:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	7e 17                	jle    8010c7 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	50                   	push   %eax
  8010b4:	6a 0d                	push   $0xd
  8010b6:	68 04 17 80 00       	push   $0x801704
  8010bb:	6a 30                	push   $0x30
  8010bd:	68 21 17 80 00       	push   $0x801721
  8010c2:	e8 39 00 00 00       	call   801100 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ca:	5b                   	pop    %ebx
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	57                   	push   %edi
  8010d2:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e0:	89 cb                	mov    %ecx,%ebx
  8010e2:	89 cf                	mov    %ecx,%edi
  8010e4:	51                   	push   %ecx
  8010e5:	52                   	push   %edx
  8010e6:	53                   	push   %ebx
  8010e7:	56                   	push   %esi
  8010e8:	57                   	push   %edi
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	8d 35 f4 10 80 00    	lea    0x8010f4,%esi
  8010f2:	0f 34                	sysenter 

008010f4 <label_586>:
  8010f4:	89 ec                	mov    %ebp,%esp
  8010f6:	5d                   	pop    %ebp
  8010f7:	5f                   	pop    %edi
  8010f8:	5e                   	pop    %esi
  8010f9:	5b                   	pop    %ebx
  8010fa:	5a                   	pop    %edx
  8010fb:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010fc:	5b                   	pop    %ebx
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801105:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  801108:	a1 10 20 80 00       	mov    0x802010,%eax
  80110d:	85 c0                	test   %eax,%eax
  80110f:	74 11                	je     801122 <_panic+0x22>
		cprintf("%s: ", argv0);
  801111:	83 ec 08             	sub    $0x8,%esp
  801114:	50                   	push   %eax
  801115:	68 2f 17 80 00       	push   $0x80172f
  80111a:	e8 1a f0 ff ff       	call   800139 <cprintf>
  80111f:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801122:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801128:	e8 d4 fc ff ff       	call   800e01 <sys_getenvid>
  80112d:	83 ec 0c             	sub    $0xc,%esp
  801130:	ff 75 0c             	pushl  0xc(%ebp)
  801133:	ff 75 08             	pushl  0x8(%ebp)
  801136:	56                   	push   %esi
  801137:	50                   	push   %eax
  801138:	68 38 17 80 00       	push   $0x801738
  80113d:	e8 f7 ef ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801142:	83 c4 18             	add    $0x18,%esp
  801145:	53                   	push   %ebx
  801146:	ff 75 10             	pushl  0x10(%ebp)
  801149:	e8 9a ef ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  80114e:	c7 04 24 34 17 80 00 	movl   $0x801734,(%esp)
  801155:	e8 df ef ff ff       	call   800139 <cprintf>
  80115a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80115d:	cc                   	int3   
  80115e:	eb fd                	jmp    80115d <_panic+0x5d>

00801160 <__udivdi3>:
  801160:	55                   	push   %ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 1c             	sub    $0x1c,%esp
  801167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80116b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80116f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801177:	85 f6                	test   %esi,%esi
  801179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80117d:	89 ca                	mov    %ecx,%edx
  80117f:	89 f8                	mov    %edi,%eax
  801181:	75 3d                	jne    8011c0 <__udivdi3+0x60>
  801183:	39 cf                	cmp    %ecx,%edi
  801185:	0f 87 c5 00 00 00    	ja     801250 <__udivdi3+0xf0>
  80118b:	85 ff                	test   %edi,%edi
  80118d:	89 fd                	mov    %edi,%ebp
  80118f:	75 0b                	jne    80119c <__udivdi3+0x3c>
  801191:	b8 01 00 00 00       	mov    $0x1,%eax
  801196:	31 d2                	xor    %edx,%edx
  801198:	f7 f7                	div    %edi
  80119a:	89 c5                	mov    %eax,%ebp
  80119c:	89 c8                	mov    %ecx,%eax
  80119e:	31 d2                	xor    %edx,%edx
  8011a0:	f7 f5                	div    %ebp
  8011a2:	89 c1                	mov    %eax,%ecx
  8011a4:	89 d8                	mov    %ebx,%eax
  8011a6:	89 cf                	mov    %ecx,%edi
  8011a8:	f7 f5                	div    %ebp
  8011aa:	89 c3                	mov    %eax,%ebx
  8011ac:	89 d8                	mov    %ebx,%eax
  8011ae:	89 fa                	mov    %edi,%edx
  8011b0:	83 c4 1c             	add    $0x1c,%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    
  8011b8:	90                   	nop
  8011b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	39 ce                	cmp    %ecx,%esi
  8011c2:	77 74                	ja     801238 <__udivdi3+0xd8>
  8011c4:	0f bd fe             	bsr    %esi,%edi
  8011c7:	83 f7 1f             	xor    $0x1f,%edi
  8011ca:	0f 84 98 00 00 00    	je     801268 <__udivdi3+0x108>
  8011d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011d5:	89 f9                	mov    %edi,%ecx
  8011d7:	89 c5                	mov    %eax,%ebp
  8011d9:	29 fb                	sub    %edi,%ebx
  8011db:	d3 e6                	shl    %cl,%esi
  8011dd:	89 d9                	mov    %ebx,%ecx
  8011df:	d3 ed                	shr    %cl,%ebp
  8011e1:	89 f9                	mov    %edi,%ecx
  8011e3:	d3 e0                	shl    %cl,%eax
  8011e5:	09 ee                	or     %ebp,%esi
  8011e7:	89 d9                	mov    %ebx,%ecx
  8011e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ed:	89 d5                	mov    %edx,%ebp
  8011ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011f3:	d3 ed                	shr    %cl,%ebp
  8011f5:	89 f9                	mov    %edi,%ecx
  8011f7:	d3 e2                	shl    %cl,%edx
  8011f9:	89 d9                	mov    %ebx,%ecx
  8011fb:	d3 e8                	shr    %cl,%eax
  8011fd:	09 c2                	or     %eax,%edx
  8011ff:	89 d0                	mov    %edx,%eax
  801201:	89 ea                	mov    %ebp,%edx
  801203:	f7 f6                	div    %esi
  801205:	89 d5                	mov    %edx,%ebp
  801207:	89 c3                	mov    %eax,%ebx
  801209:	f7 64 24 0c          	mull   0xc(%esp)
  80120d:	39 d5                	cmp    %edx,%ebp
  80120f:	72 10                	jb     801221 <__udivdi3+0xc1>
  801211:	8b 74 24 08          	mov    0x8(%esp),%esi
  801215:	89 f9                	mov    %edi,%ecx
  801217:	d3 e6                	shl    %cl,%esi
  801219:	39 c6                	cmp    %eax,%esi
  80121b:	73 07                	jae    801224 <__udivdi3+0xc4>
  80121d:	39 d5                	cmp    %edx,%ebp
  80121f:	75 03                	jne    801224 <__udivdi3+0xc4>
  801221:	83 eb 01             	sub    $0x1,%ebx
  801224:	31 ff                	xor    %edi,%edi
  801226:	89 d8                	mov    %ebx,%eax
  801228:	89 fa                	mov    %edi,%edx
  80122a:	83 c4 1c             	add    $0x1c,%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    
  801232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801238:	31 ff                	xor    %edi,%edi
  80123a:	31 db                	xor    %ebx,%ebx
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
  801250:	89 d8                	mov    %ebx,%eax
  801252:	f7 f7                	div    %edi
  801254:	31 ff                	xor    %edi,%edi
  801256:	89 c3                	mov    %eax,%ebx
  801258:	89 d8                	mov    %ebx,%eax
  80125a:	89 fa                	mov    %edi,%edx
  80125c:	83 c4 1c             	add    $0x1c,%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	39 ce                	cmp    %ecx,%esi
  80126a:	72 0c                	jb     801278 <__udivdi3+0x118>
  80126c:	31 db                	xor    %ebx,%ebx
  80126e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801272:	0f 87 34 ff ff ff    	ja     8011ac <__udivdi3+0x4c>
  801278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80127d:	e9 2a ff ff ff       	jmp    8011ac <__udivdi3+0x4c>
  801282:	66 90                	xchg   %ax,%ax
  801284:	66 90                	xchg   %ax,%ax
  801286:	66 90                	xchg   %ax,%ax
  801288:	66 90                	xchg   %ax,%ax
  80128a:	66 90                	xchg   %ax,%ax
  80128c:	66 90                	xchg   %ax,%ax
  80128e:	66 90                	xchg   %ax,%ax

00801290 <__umoddi3>:
  801290:	55                   	push   %ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	83 ec 1c             	sub    $0x1c,%esp
  801297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80129b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80129f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012a7:	85 d2                	test   %edx,%edx
  8012a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012b1:	89 f3                	mov    %esi,%ebx
  8012b3:	89 3c 24             	mov    %edi,(%esp)
  8012b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ba:	75 1c                	jne    8012d8 <__umoddi3+0x48>
  8012bc:	39 f7                	cmp    %esi,%edi
  8012be:	76 50                	jbe    801310 <__umoddi3+0x80>
  8012c0:	89 c8                	mov    %ecx,%eax
  8012c2:	89 f2                	mov    %esi,%edx
  8012c4:	f7 f7                	div    %edi
  8012c6:	89 d0                	mov    %edx,%eax
  8012c8:	31 d2                	xor    %edx,%edx
  8012ca:	83 c4 1c             	add    $0x1c,%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    
  8012d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d8:	39 f2                	cmp    %esi,%edx
  8012da:	89 d0                	mov    %edx,%eax
  8012dc:	77 52                	ja     801330 <__umoddi3+0xa0>
  8012de:	0f bd ea             	bsr    %edx,%ebp
  8012e1:	83 f5 1f             	xor    $0x1f,%ebp
  8012e4:	75 5a                	jne    801340 <__umoddi3+0xb0>
  8012e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012ea:	0f 82 e0 00 00 00    	jb     8013d0 <__umoddi3+0x140>
  8012f0:	39 0c 24             	cmp    %ecx,(%esp)
  8012f3:	0f 86 d7 00 00 00    	jbe    8013d0 <__umoddi3+0x140>
  8012f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801301:	83 c4 1c             	add    $0x1c,%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    
  801309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801310:	85 ff                	test   %edi,%edi
  801312:	89 fd                	mov    %edi,%ebp
  801314:	75 0b                	jne    801321 <__umoddi3+0x91>
  801316:	b8 01 00 00 00       	mov    $0x1,%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	f7 f7                	div    %edi
  80131f:	89 c5                	mov    %eax,%ebp
  801321:	89 f0                	mov    %esi,%eax
  801323:	31 d2                	xor    %edx,%edx
  801325:	f7 f5                	div    %ebp
  801327:	89 c8                	mov    %ecx,%eax
  801329:	f7 f5                	div    %ebp
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	eb 99                	jmp    8012c8 <__umoddi3+0x38>
  80132f:	90                   	nop
  801330:	89 c8                	mov    %ecx,%eax
  801332:	89 f2                	mov    %esi,%edx
  801334:	83 c4 1c             	add    $0x1c,%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    
  80133c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801340:	8b 34 24             	mov    (%esp),%esi
  801343:	bf 20 00 00 00       	mov    $0x20,%edi
  801348:	89 e9                	mov    %ebp,%ecx
  80134a:	29 ef                	sub    %ebp,%edi
  80134c:	d3 e0                	shl    %cl,%eax
  80134e:	89 f9                	mov    %edi,%ecx
  801350:	89 f2                	mov    %esi,%edx
  801352:	d3 ea                	shr    %cl,%edx
  801354:	89 e9                	mov    %ebp,%ecx
  801356:	09 c2                	or     %eax,%edx
  801358:	89 d8                	mov    %ebx,%eax
  80135a:	89 14 24             	mov    %edx,(%esp)
  80135d:	89 f2                	mov    %esi,%edx
  80135f:	d3 e2                	shl    %cl,%edx
  801361:	89 f9                	mov    %edi,%ecx
  801363:	89 54 24 04          	mov    %edx,0x4(%esp)
  801367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80136b:	d3 e8                	shr    %cl,%eax
  80136d:	89 e9                	mov    %ebp,%ecx
  80136f:	89 c6                	mov    %eax,%esi
  801371:	d3 e3                	shl    %cl,%ebx
  801373:	89 f9                	mov    %edi,%ecx
  801375:	89 d0                	mov    %edx,%eax
  801377:	d3 e8                	shr    %cl,%eax
  801379:	89 e9                	mov    %ebp,%ecx
  80137b:	09 d8                	or     %ebx,%eax
  80137d:	89 d3                	mov    %edx,%ebx
  80137f:	89 f2                	mov    %esi,%edx
  801381:	f7 34 24             	divl   (%esp)
  801384:	89 d6                	mov    %edx,%esi
  801386:	d3 e3                	shl    %cl,%ebx
  801388:	f7 64 24 04          	mull   0x4(%esp)
  80138c:	39 d6                	cmp    %edx,%esi
  80138e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801392:	89 d1                	mov    %edx,%ecx
  801394:	89 c3                	mov    %eax,%ebx
  801396:	72 08                	jb     8013a0 <__umoddi3+0x110>
  801398:	75 11                	jne    8013ab <__umoddi3+0x11b>
  80139a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80139e:	73 0b                	jae    8013ab <__umoddi3+0x11b>
  8013a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013a4:	1b 14 24             	sbb    (%esp),%edx
  8013a7:	89 d1                	mov    %edx,%ecx
  8013a9:	89 c3                	mov    %eax,%ebx
  8013ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013af:	29 da                	sub    %ebx,%edx
  8013b1:	19 ce                	sbb    %ecx,%esi
  8013b3:	89 f9                	mov    %edi,%ecx
  8013b5:	89 f0                	mov    %esi,%eax
  8013b7:	d3 e0                	shl    %cl,%eax
  8013b9:	89 e9                	mov    %ebp,%ecx
  8013bb:	d3 ea                	shr    %cl,%edx
  8013bd:	89 e9                	mov    %ebp,%ecx
  8013bf:	d3 ee                	shr    %cl,%esi
  8013c1:	09 d0                	or     %edx,%eax
  8013c3:	89 f2                	mov    %esi,%edx
  8013c5:	83 c4 1c             	add    $0x1c,%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    
  8013cd:	8d 76 00             	lea    0x0(%esi),%esi
  8013d0:	29 f9                	sub    %edi,%ecx
  8013d2:	19 d6                	sbb    %edx,%esi
  8013d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013dc:	e9 18 ff ff ff       	jmp    8012f9 <__umoddi3+0x69>
