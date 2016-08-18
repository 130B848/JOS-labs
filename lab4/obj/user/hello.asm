
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 00 14 80 00       	push   $0x801400
  80003e:	e8 06 01 00 00       	call   800149 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 0e 14 80 00       	push   $0x80140e
  800054:	e8 f0 00 00 00       	call   800149 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800069:	e8 a3 0d 00 00       	call   800e11 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 10 0d 00 00       	call   800dc1 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 1a                	jne    8000ef <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 ff 00 00 00       	push   $0xff
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 7a 0c 00 00       	call   800d60 <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	ff 75 08             	pushl  0x8(%ebp)
  80011b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800121:	50                   	push   %eax
  800122:	68 b6 00 80 00       	push   $0x8000b6
  800127:	e8 c0 02 00 00       	call   8003ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012c:	83 c4 08             	add    $0x8,%esp
  80012f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800135:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 1f 0c 00 00       	call   800d60 <sys_cputs>

	return b.cnt;
}
  800141:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800152:	50                   	push   %eax
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	e8 9d ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 1c             	sub    $0x1c,%esp
  800166:	89 c7                	mov    %eax,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800170:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800173:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800176:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800179:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80017d:	0f 85 bf 00 00 00    	jne    800242 <printnum+0xe5>
  800183:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800189:	0f 8d de 00 00 00    	jge    80026d <printnum+0x110>
		judge_time_for_space = width;
  80018f:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800195:	e9 d3 00 00 00       	jmp    80026d <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80019a:	83 eb 01             	sub    $0x1,%ebx
  80019d:	85 db                	test   %ebx,%ebx
  80019f:	7f 37                	jg     8001d8 <printnum+0x7b>
  8001a1:	e9 ea 00 00 00       	jmp    800290 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8001a6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001a9:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	56                   	push   %esi
  8001b2:	83 ec 04             	sub    $0x4,%esp
  8001b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001be:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c1:	e8 da 10 00 00       	call   8012a0 <__umoddi3>
  8001c6:	83 c4 14             	add    $0x14,%esp
  8001c9:	0f be 80 2f 14 80 00 	movsbl 0x80142f(%eax),%eax
  8001d0:	50                   	push   %eax
  8001d1:	ff d7                	call   *%edi
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	eb 16                	jmp    8001ee <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8001d8:	83 ec 08             	sub    $0x8,%esp
  8001db:	56                   	push   %esi
  8001dc:	ff 75 18             	pushl  0x18(%ebp)
  8001df:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001e1:	83 c4 10             	add    $0x10,%esp
  8001e4:	83 eb 01             	sub    $0x1,%ebx
  8001e7:	75 ef                	jne    8001d8 <printnum+0x7b>
  8001e9:	e9 a2 00 00 00       	jmp    800290 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8001ee:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8001f4:	0f 85 76 01 00 00    	jne    800370 <printnum+0x213>
		while(num_of_space-- > 0)
  8001fa:	a1 04 20 80 00       	mov    0x802004,%eax
  8001ff:	8d 50 ff             	lea    -0x1(%eax),%edx
  800202:	89 15 04 20 80 00    	mov    %edx,0x802004
  800208:	85 c0                	test   %eax,%eax
  80020a:	7e 1d                	jle    800229 <printnum+0xcc>
			putch(' ', putdat);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	56                   	push   %esi
  800210:	6a 20                	push   $0x20
  800212:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800214:	a1 04 20 80 00       	mov    0x802004,%eax
  800219:	8d 50 ff             	lea    -0x1(%eax),%edx
  80021c:	89 15 04 20 80 00    	mov    %edx,0x802004
  800222:	83 c4 10             	add    $0x10,%esp
  800225:	85 c0                	test   %eax,%eax
  800227:	7f e3                	jg     80020c <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800229:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800230:	00 00 00 
		judge_time_for_space = 0;
  800233:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80023a:	00 00 00 
	}
}
  80023d:	e9 2e 01 00 00       	jmp    800370 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 45 10             	mov    0x10(%ebp),%eax
  800245:	ba 00 00 00 00       	mov    $0x0,%edx
  80024a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800250:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800253:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800256:	83 fa 00             	cmp    $0x0,%edx
  800259:	0f 87 ba 00 00 00    	ja     800319 <printnum+0x1bc>
  80025f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800262:	0f 83 b1 00 00 00    	jae    800319 <printnum+0x1bc>
  800268:	e9 2d ff ff ff       	jmp    80019a <printnum+0x3d>
  80026d:	8b 45 10             	mov    0x10(%ebp),%eax
  800270:	ba 00 00 00 00       	mov    $0x0,%edx
  800275:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800278:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80027b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800281:	83 fa 00             	cmp    $0x0,%edx
  800284:	77 37                	ja     8002bd <printnum+0x160>
  800286:	3b 45 10             	cmp    0x10(%ebp),%eax
  800289:	73 32                	jae    8002bd <printnum+0x160>
  80028b:	e9 16 ff ff ff       	jmp    8001a6 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	83 ec 04             	sub    $0x4,%esp
  800297:	ff 75 dc             	pushl  -0x24(%ebp)
  80029a:	ff 75 d8             	pushl  -0x28(%ebp)
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	e8 f8 0f 00 00       	call   8012a0 <__umoddi3>
  8002a8:	83 c4 14             	add    $0x14,%esp
  8002ab:	0f be 80 2f 14 80 00 	movsbl 0x80142f(%eax),%eax
  8002b2:	50                   	push   %eax
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	e9 b3 00 00 00       	jmp    800370 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	ff 75 18             	pushl  0x18(%ebp)
  8002c3:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002c6:	50                   	push   %eax
  8002c7:	ff 75 10             	pushl  0x10(%ebp)
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d9:	e8 92 0e 00 00       	call   801170 <__udivdi3>
  8002de:	83 c4 18             	add    $0x18,%esp
  8002e1:	52                   	push   %edx
  8002e2:	50                   	push   %eax
  8002e3:	89 f2                	mov    %esi,%edx
  8002e5:	89 f8                	mov    %edi,%eax
  8002e7:	e8 71 fe ff ff       	call   80015d <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	56                   	push   %esi
  8002f0:	83 ec 04             	sub    $0x4,%esp
  8002f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ff:	e8 9c 0f 00 00       	call   8012a0 <__umoddi3>
  800304:	83 c4 14             	add    $0x14,%esp
  800307:	0f be 80 2f 14 80 00 	movsbl 0x80142f(%eax),%eax
  80030e:	50                   	push   %eax
  80030f:	ff d7                	call   *%edi
  800311:	83 c4 10             	add    $0x10,%esp
  800314:	e9 d5 fe ff ff       	jmp    8001ee <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800319:	83 ec 0c             	sub    $0xc,%esp
  80031c:	ff 75 18             	pushl  0x18(%ebp)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	53                   	push   %ebx
  800323:	ff 75 10             	pushl  0x10(%ebp)
  800326:	83 ec 08             	sub    $0x8,%esp
  800329:	ff 75 dc             	pushl  -0x24(%ebp)
  80032c:	ff 75 d8             	pushl  -0x28(%ebp)
  80032f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800332:	ff 75 e0             	pushl  -0x20(%ebp)
  800335:	e8 36 0e 00 00       	call   801170 <__udivdi3>
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	52                   	push   %edx
  80033e:	50                   	push   %eax
  80033f:	89 f2                	mov    %esi,%edx
  800341:	89 f8                	mov    %edi,%eax
  800343:	e8 15 fe ff ff       	call   80015d <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800348:	83 c4 18             	add    $0x18,%esp
  80034b:	56                   	push   %esi
  80034c:	83 ec 04             	sub    $0x4,%esp
  80034f:	ff 75 dc             	pushl  -0x24(%ebp)
  800352:	ff 75 d8             	pushl  -0x28(%ebp)
  800355:	ff 75 e4             	pushl  -0x1c(%ebp)
  800358:	ff 75 e0             	pushl  -0x20(%ebp)
  80035b:	e8 40 0f 00 00       	call   8012a0 <__umoddi3>
  800360:	83 c4 14             	add    $0x14,%esp
  800363:	0f be 80 2f 14 80 00 	movsbl 0x80142f(%eax),%eax
  80036a:	50                   	push   %eax
  80036b:	ff d7                	call   *%edi
  80036d:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800370:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037b:	83 fa 01             	cmp    $0x1,%edx
  80037e:	7e 0e                	jle    80038e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 08             	lea    0x8(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	8b 52 04             	mov    0x4(%edx),%edx
  80038c:	eb 22                	jmp    8003b0 <getuint+0x38>
	else if (lflag)
  80038e:	85 d2                	test   %edx,%edx
  800390:	74 10                	je     8003a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a0:	eb 0e                	jmp    8003b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c1:	73 0a                	jae    8003cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c6:	89 08                	mov    %ecx,(%eax)
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	88 02                	mov    %al,(%edx)
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d8:	50                   	push   %eax
  8003d9:	ff 75 10             	pushl  0x10(%ebp)
  8003dc:	ff 75 0c             	pushl  0xc(%ebp)
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 05 00 00 00       	call   8003ec <vprintfmt>
	va_end(ap);
}
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	83 ec 2c             	sub    $0x2c,%esp
  8003f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003fb:	eb 03                	jmp    800400 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003fd:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800400:	8b 45 10             	mov    0x10(%ebp),%eax
  800403:	8d 70 01             	lea    0x1(%eax),%esi
  800406:	0f b6 00             	movzbl (%eax),%eax
  800409:	83 f8 25             	cmp    $0x25,%eax
  80040c:	74 27                	je     800435 <vprintfmt+0x49>
			if (ch == '\0')
  80040e:	85 c0                	test   %eax,%eax
  800410:	75 0d                	jne    80041f <vprintfmt+0x33>
  800412:	e9 9d 04 00 00       	jmp    8008b4 <vprintfmt+0x4c8>
  800417:	85 c0                	test   %eax,%eax
  800419:	0f 84 95 04 00 00    	je     8008b4 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	53                   	push   %ebx
  800423:	50                   	push   %eax
  800424:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800426:	83 c6 01             	add    $0x1,%esi
  800429:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80042d:	83 c4 10             	add    $0x10,%esp
  800430:	83 f8 25             	cmp    $0x25,%eax
  800433:	75 e2                	jne    800417 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800435:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80043e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800445:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800453:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80045a:	eb 08                	jmp    800464 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80045f:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8d 46 01             	lea    0x1(%esi),%eax
  800467:	89 45 10             	mov    %eax,0x10(%ebp)
  80046a:	0f b6 06             	movzbl (%esi),%eax
  80046d:	0f b6 d0             	movzbl %al,%edx
  800470:	83 e8 23             	sub    $0x23,%eax
  800473:	3c 55                	cmp    $0x55,%al
  800475:	0f 87 fa 03 00 00    	ja     800875 <vprintfmt+0x489>
  80047b:	0f b6 c0             	movzbl %al,%eax
  80047e:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  800485:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800488:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80048c:	eb d6                	jmp    800464 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80048e:	8d 42 d0             	lea    -0x30(%edx),%eax
  800491:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800494:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800498:	8d 50 d0             	lea    -0x30(%eax),%edx
  80049b:	83 fa 09             	cmp    $0x9,%edx
  80049e:	77 6b                	ja     80050b <vprintfmt+0x11f>
  8004a0:	8b 75 10             	mov    0x10(%ebp),%esi
  8004a3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a9:	eb 09                	jmp    8004b4 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ae:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8004b2:	eb b0                	jmp    800464 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004b7:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004ba:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004be:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c1:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004c4:	83 f9 09             	cmp    $0x9,%ecx
  8004c7:	76 eb                	jbe    8004b4 <vprintfmt+0xc8>
  8004c9:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004cc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004cf:	eb 3d                	jmp    80050e <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 50 04             	lea    0x4(%eax),%edx
  8004d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e2:	eb 2a                	jmp    80050e <vprintfmt+0x122>
  8004e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ee:	0f 49 d0             	cmovns %eax,%edx
  8004f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f7:	e9 68 ff ff ff       	jmp    800464 <vprintfmt+0x78>
  8004fc:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ff:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800506:	e9 59 ff ff ff       	jmp    800464 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80050e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800512:	0f 89 4c ff ff ff    	jns    800464 <vprintfmt+0x78>
				width = precision, precision = -1;
  800518:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80051b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800525:	e9 3a ff ff ff       	jmp    800464 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052a:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800531:	e9 2e ff ff ff       	jmp    800464 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 50 04             	lea    0x4(%eax),%edx
  80053c:	89 55 14             	mov    %edx,0x14(%ebp)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	ff 30                	pushl  (%eax)
  800545:	ff d7                	call   *%edi
			break;
  800547:	83 c4 10             	add    $0x10,%esp
  80054a:	e9 b1 fe ff ff       	jmp    800400 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	99                   	cltd   
  80055b:	31 d0                	xor    %edx,%eax
  80055d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055f:	83 f8 08             	cmp    $0x8,%eax
  800562:	7f 0b                	jg     80056f <vprintfmt+0x183>
  800564:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  80056b:	85 d2                	test   %edx,%edx
  80056d:	75 15                	jne    800584 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80056f:	50                   	push   %eax
  800570:	68 47 14 80 00       	push   $0x801447
  800575:	53                   	push   %ebx
  800576:	57                   	push   %edi
  800577:	e8 53 fe ff ff       	call   8003cf <printfmt>
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	e9 7c fe ff ff       	jmp    800400 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800584:	52                   	push   %edx
  800585:	68 50 14 80 00       	push   $0x801450
  80058a:	53                   	push   %ebx
  80058b:	57                   	push   %edi
  80058c:	e8 3e fe ff ff       	call   8003cf <printfmt>
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	e9 67 fe ff ff       	jmp    800400 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	b9 40 14 80 00       	mov    $0x801440,%ecx
  8005ab:	0f 45 c8             	cmovne %eax,%ecx
  8005ae:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b5:	7e 06                	jle    8005bd <vprintfmt+0x1d1>
  8005b7:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005bb:	75 19                	jne    8005d6 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005c0:	8d 70 01             	lea    0x1(%eax),%esi
  8005c3:	0f b6 00             	movzbl (%eax),%eax
  8005c6:	0f be d0             	movsbl %al,%edx
  8005c9:	85 d2                	test   %edx,%edx
  8005cb:	0f 85 9f 00 00 00    	jne    800670 <vprintfmt+0x284>
  8005d1:	e9 8c 00 00 00       	jmp    800662 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005dc:	ff 75 cc             	pushl  -0x34(%ebp)
  8005df:	e8 62 03 00 00       	call   800946 <strnlen>
  8005e4:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005e7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	0f 8e a6 02 00 00    	jle    80089b <vprintfmt+0x4af>
					putch(padc, putdat);
  8005f5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005fc:	89 cb                	mov    %ecx,%ebx
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	56                   	push   %esi
  800605:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	83 eb 01             	sub    $0x1,%ebx
  80060d:	75 ef                	jne    8005fe <vprintfmt+0x212>
  80060f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800612:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800615:	e9 81 02 00 00       	jmp    80089b <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x24f>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x24f>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 ef 01             	sub    $0x1,%edi
  80064b:	83 c6 01             	add    $0x1,%esi
  80064e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800652:	0f be d0             	movsbl %al,%edx
  800655:	85 d2                	test   %edx,%edx
  800657:	75 31                	jne    80068a <vprintfmt+0x29e>
  800659:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80065f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800662:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800665:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800669:	7f 33                	jg     80069e <vprintfmt+0x2b2>
  80066b:	e9 90 fd ff ff       	jmp    800400 <vprintfmt+0x14>
  800670:	89 7d 08             	mov    %edi,0x8(%ebp)
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800676:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800679:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80067c:	eb 0c                	jmp    80068a <vprintfmt+0x29e>
  80067e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800684:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800687:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068a:	85 db                	test   %ebx,%ebx
  80068c:	78 8c                	js     80061a <vprintfmt+0x22e>
  80068e:	83 eb 01             	sub    $0x1,%ebx
  800691:	79 87                	jns    80061a <vprintfmt+0x22e>
  800693:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800696:	8b 7d 08             	mov    0x8(%ebp),%edi
  800699:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069c:	eb c4                	jmp    800662 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 20                	push   $0x20
  8006a4:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	83 ee 01             	sub    $0x1,%esi
  8006ac:	75 f0                	jne    80069e <vprintfmt+0x2b2>
  8006ae:	e9 4d fd ff ff       	jmp    800400 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b3:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8006b7:	7e 16                	jle    8006cf <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8d 50 08             	lea    0x8(%eax),%edx
  8006bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c2:	8b 50 04             	mov    0x4(%eax),%edx
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006cd:	eb 34                	jmp    800703 <vprintfmt+0x317>
	else if (lflag)
  8006cf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006d3:	74 18                	je     8006ed <vprintfmt+0x301>
		return va_arg(*ap, long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 30                	mov    (%eax),%esi
  8006e0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006e3:	89 f0                	mov    %esi,%eax
  8006e5:	c1 f8 1f             	sar    $0x1f,%eax
  8006e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006eb:	eb 16                	jmp    800703 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 50 04             	lea    0x4(%eax),%edx
  8006f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f6:	8b 30                	mov    (%eax),%esi
  8006f8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	c1 f8 1f             	sar    $0x1f,%eax
  800700:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800703:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800706:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800709:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80070f:	85 d2                	test   %edx,%edx
  800711:	79 28                	jns    80073b <vprintfmt+0x34f>
				putch('-', putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 2d                	push   $0x2d
  800719:	ff d7                	call   *%edi
				num = -(long long) num;
  80071b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80071e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800721:	f7 d8                	neg    %eax
  800723:	83 d2 00             	adc    $0x0,%edx
  800726:	f7 da                	neg    %edx
  800728:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80072e:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800731:	b8 0a 00 00 00       	mov    $0xa,%eax
  800736:	e9 b2 00 00 00       	jmp    8007ed <vprintfmt+0x401>
  80073b:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800740:	85 c9                	test   %ecx,%ecx
  800742:	0f 84 a5 00 00 00    	je     8007ed <vprintfmt+0x401>
				putch('+', putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	53                   	push   %ebx
  80074c:	6a 2b                	push   $0x2b
  80074e:	ff d7                	call   *%edi
  800750:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800753:	b8 0a 00 00 00       	mov    $0xa,%eax
  800758:	e9 90 00 00 00       	jmp    8007ed <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  80075d:	85 c9                	test   %ecx,%ecx
  80075f:	74 0b                	je     80076c <vprintfmt+0x380>
				putch('+', putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	6a 2b                	push   $0x2b
  800767:	ff d7                	call   *%edi
  800769:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  80076c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
  800772:	e8 01 fc ff ff       	call   800378 <getuint>
  800777:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80077d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800782:	eb 69                	jmp    8007ed <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 30                	push   $0x30
  80078a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80078c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 e1 fb ff ff       	call   800378 <getuint>
  800797:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80079d:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007a0:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007a5:	eb 46                	jmp    8007ed <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	53                   	push   %ebx
  8007ab:	6a 30                	push   $0x30
  8007ad:	ff d7                	call   *%edi
			putch('x', putdat);
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	6a 78                	push   $0x78
  8007b5:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 04             	lea    0x4(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d5:	eb 16                	jmp    8007ed <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007da:	8d 45 14             	lea    0x14(%ebp),%eax
  8007dd:	e8 96 fb ff ff       	call   800378 <getuint>
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8007e8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ed:	83 ec 0c             	sub    $0xc,%esp
  8007f0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007f4:	56                   	push   %esi
  8007f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007f8:	50                   	push   %eax
  8007f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8007fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8007ff:	89 da                	mov    %ebx,%edx
  800801:	89 f8                	mov    %edi,%eax
  800803:	e8 55 f9 ff ff       	call   80015d <printnum>
			break;
  800808:	83 c4 20             	add    $0x20,%esp
  80080b:	e9 f0 fb ff ff       	jmp    800400 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8d 50 04             	lea    0x4(%eax),%edx
  800816:	89 55 14             	mov    %edx,0x14(%ebp)
  800819:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  80081b:	85 f6                	test   %esi,%esi
  80081d:	75 1a                	jne    800839 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	68 e8 14 80 00       	push   $0x8014e8
  800827:	68 50 14 80 00       	push   $0x801450
  80082c:	e8 18 f9 ff ff       	call   800149 <cprintf>
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	e9 c7 fb ff ff       	jmp    800400 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800839:	0f b6 03             	movzbl (%ebx),%eax
  80083c:	84 c0                	test   %al,%al
  80083e:	79 1f                	jns    80085f <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	68 20 15 80 00       	push   $0x801520
  800848:	68 50 14 80 00       	push   $0x801450
  80084d:	e8 f7 f8 ff ff       	call   800149 <cprintf>
						*tmp = *(char *)putdat;
  800852:	0f b6 03             	movzbl (%ebx),%eax
  800855:	88 06                	mov    %al,(%esi)
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	e9 a1 fb ff ff       	jmp    800400 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  80085f:	88 06                	mov    %al,(%esi)
  800861:	e9 9a fb ff ff       	jmp    800400 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	52                   	push   %edx
  80086b:	ff d7                	call   *%edi
			break;
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	e9 8b fb ff ff       	jmp    800400 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	53                   	push   %ebx
  800879:	6a 25                	push   $0x25
  80087b:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800884:	0f 84 73 fb ff ff    	je     8003fd <vprintfmt+0x11>
  80088a:	83 ee 01             	sub    $0x1,%esi
  80088d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800891:	75 f7                	jne    80088a <vprintfmt+0x49e>
  800893:	89 75 10             	mov    %esi,0x10(%ebp)
  800896:	e9 65 fb ff ff       	jmp    800400 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80089b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80089e:	8d 70 01             	lea    0x1(%eax),%esi
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f be d0             	movsbl %al,%edx
  8008a7:	85 d2                	test   %edx,%edx
  8008a9:	0f 85 cf fd ff ff    	jne    80067e <vprintfmt+0x292>
  8008af:	e9 4c fb ff ff       	jmp    800400 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5f                   	pop    %edi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	83 ec 18             	sub    $0x18,%esp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d9:	85 c0                	test   %eax,%eax
  8008db:	74 26                	je     800903 <vsnprintf+0x47>
  8008dd:	85 d2                	test   %edx,%edx
  8008df:	7e 22                	jle    800903 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e1:	ff 75 14             	pushl  0x14(%ebp)
  8008e4:	ff 75 10             	pushl  0x10(%ebp)
  8008e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ea:	50                   	push   %eax
  8008eb:	68 b2 03 80 00       	push   $0x8003b2
  8008f0:	e8 f7 fa ff ff       	call   8003ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	eb 05                	jmp    800908 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800903:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800910:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800913:	50                   	push   %eax
  800914:	ff 75 10             	pushl  0x10(%ebp)
  800917:	ff 75 0c             	pushl  0xc(%ebp)
  80091a:	ff 75 08             	pushl  0x8(%ebp)
  80091d:	e8 9a ff ff ff       	call   8008bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800922:	c9                   	leave  
  800923:	c3                   	ret    

00800924 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092a:	80 3a 00             	cmpb   $0x0,(%edx)
  80092d:	74 10                	je     80093f <strlen+0x1b>
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800934:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800937:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093b:	75 f7                	jne    800934 <strlen+0x10>
  80093d:	eb 05                	jmp    800944 <strlen+0x20>
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80094d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800950:	85 c9                	test   %ecx,%ecx
  800952:	74 1c                	je     800970 <strnlen+0x2a>
  800954:	80 3b 00             	cmpb   $0x0,(%ebx)
  800957:	74 1e                	je     800977 <strnlen+0x31>
  800959:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80095e:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800960:	39 ca                	cmp    %ecx,%edx
  800962:	74 18                	je     80097c <strnlen+0x36>
  800964:	83 c2 01             	add    $0x1,%edx
  800967:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80096c:	75 f0                	jne    80095e <strnlen+0x18>
  80096e:	eb 0c                	jmp    80097c <strnlen+0x36>
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
  800975:	eb 05                	jmp    80097c <strnlen+0x36>
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80097c:	5b                   	pop    %ebx
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800989:	89 c2                	mov    %eax,%edx
  80098b:	83 c2 01             	add    $0x1,%edx
  80098e:	83 c1 01             	add    $0x1,%ecx
  800991:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800995:	88 5a ff             	mov    %bl,-0x1(%edx)
  800998:	84 db                	test   %bl,%bl
  80099a:	75 ef                	jne    80098b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a6:	53                   	push   %ebx
  8009a7:	e8 78 ff ff ff       	call   800924 <strlen>
  8009ac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009af:	ff 75 0c             	pushl  0xc(%ebp)
  8009b2:	01 d8                	add    %ebx,%eax
  8009b4:	50                   	push   %eax
  8009b5:	e8 c5 ff ff ff       	call   80097f <strcpy>
	return dst;
}
  8009ba:	89 d8                	mov    %ebx,%eax
  8009bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009cf:	85 db                	test   %ebx,%ebx
  8009d1:	74 17                	je     8009ea <strncpy+0x29>
  8009d3:	01 f3                	add    %esi,%ebx
  8009d5:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	0f b6 02             	movzbl (%edx),%eax
  8009dd:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e0:	80 3a 01             	cmpb   $0x1,(%edx)
  8009e3:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e6:	39 cb                	cmp    %ecx,%ebx
  8009e8:	75 ed                	jne    8009d7 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ea:	89 f0                	mov    %esi,%eax
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009fb:	8b 55 10             	mov    0x10(%ebp),%edx
  8009fe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a00:	85 d2                	test   %edx,%edx
  800a02:	74 35                	je     800a39 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	83 e8 01             	sub    $0x1,%eax
  800a09:	74 25                	je     800a30 <strlcpy+0x40>
  800a0b:	0f b6 0b             	movzbl (%ebx),%ecx
  800a0e:	84 c9                	test   %cl,%cl
  800a10:	74 22                	je     800a34 <strlcpy+0x44>
  800a12:	8d 53 01             	lea    0x1(%ebx),%edx
  800a15:	01 c3                	add    %eax,%ebx
  800a17:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a1f:	39 da                	cmp    %ebx,%edx
  800a21:	74 13                	je     800a36 <strlcpy+0x46>
  800a23:	83 c2 01             	add    $0x1,%edx
  800a26:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a2a:	84 c9                	test   %cl,%cl
  800a2c:	75 eb                	jne    800a19 <strlcpy+0x29>
  800a2e:	eb 06                	jmp    800a36 <strlcpy+0x46>
  800a30:	89 f0                	mov    %esi,%eax
  800a32:	eb 02                	jmp    800a36 <strlcpy+0x46>
  800a34:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a36:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a39:	29 f0                	sub    %esi,%eax
}
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a45:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a48:	0f b6 01             	movzbl (%ecx),%eax
  800a4b:	84 c0                	test   %al,%al
  800a4d:	74 15                	je     800a64 <strcmp+0x25>
  800a4f:	3a 02                	cmp    (%edx),%al
  800a51:	75 11                	jne    800a64 <strcmp+0x25>
		p++, q++;
  800a53:	83 c1 01             	add    $0x1,%ecx
  800a56:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a59:	0f b6 01             	movzbl (%ecx),%eax
  800a5c:	84 c0                	test   %al,%al
  800a5e:	74 04                	je     800a64 <strcmp+0x25>
  800a60:	3a 02                	cmp    (%edx),%al
  800a62:	74 ef                	je     800a53 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a64:	0f b6 c0             	movzbl %al,%eax
  800a67:	0f b6 12             	movzbl (%edx),%edx
  800a6a:	29 d0                	sub    %edx,%eax
}
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a79:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a7c:	85 f6                	test   %esi,%esi
  800a7e:	74 29                	je     800aa9 <strncmp+0x3b>
  800a80:	0f b6 03             	movzbl (%ebx),%eax
  800a83:	84 c0                	test   %al,%al
  800a85:	74 30                	je     800ab7 <strncmp+0x49>
  800a87:	3a 02                	cmp    (%edx),%al
  800a89:	75 2c                	jne    800ab7 <strncmp+0x49>
  800a8b:	8d 43 01             	lea    0x1(%ebx),%eax
  800a8e:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a90:	89 c3                	mov    %eax,%ebx
  800a92:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a95:	39 c6                	cmp    %eax,%esi
  800a97:	74 17                	je     800ab0 <strncmp+0x42>
  800a99:	0f b6 08             	movzbl (%eax),%ecx
  800a9c:	84 c9                	test   %cl,%cl
  800a9e:	74 17                	je     800ab7 <strncmp+0x49>
  800aa0:	83 c0 01             	add    $0x1,%eax
  800aa3:	3a 0a                	cmp    (%edx),%cl
  800aa5:	74 e9                	je     800a90 <strncmp+0x22>
  800aa7:	eb 0e                	jmp    800ab7 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aae:	eb 0f                	jmp    800abf <strncmp+0x51>
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab5:	eb 08                	jmp    800abf <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab7:	0f b6 03             	movzbl (%ebx),%eax
  800aba:	0f b6 12             	movzbl (%edx),%edx
  800abd:	29 d0                	sub    %edx,%eax
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800acd:	0f b6 10             	movzbl (%eax),%edx
  800ad0:	84 d2                	test   %dl,%dl
  800ad2:	74 1d                	je     800af1 <strchr+0x2e>
  800ad4:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ad6:	38 d3                	cmp    %dl,%bl
  800ad8:	75 06                	jne    800ae0 <strchr+0x1d>
  800ada:	eb 1a                	jmp    800af6 <strchr+0x33>
  800adc:	38 ca                	cmp    %cl,%dl
  800ade:	74 16                	je     800af6 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae0:	83 c0 01             	add    $0x1,%eax
  800ae3:	0f b6 10             	movzbl (%eax),%edx
  800ae6:	84 d2                	test   %dl,%dl
  800ae8:	75 f2                	jne    800adc <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	eb 05                	jmp    800af6 <strchr+0x33>
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af6:	5b                   	pop    %ebx
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	53                   	push   %ebx
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b03:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b06:	38 d3                	cmp    %dl,%bl
  800b08:	74 14                	je     800b1e <strfind+0x25>
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	84 db                	test   %bl,%bl
  800b0e:	74 0e                	je     800b1e <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b10:	83 c0 01             	add    $0x1,%eax
  800b13:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b16:	38 ca                	cmp    %cl,%dl
  800b18:	74 04                	je     800b1e <strfind+0x25>
  800b1a:	84 d2                	test   %dl,%dl
  800b1c:	75 f2                	jne    800b10 <strfind+0x17>
			break;
	return (char *) s;
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b2d:	85 c9                	test   %ecx,%ecx
  800b2f:	74 36                	je     800b67 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b37:	75 28                	jne    800b61 <memset+0x40>
  800b39:	f6 c1 03             	test   $0x3,%cl
  800b3c:	75 23                	jne    800b61 <memset+0x40>
		c &= 0xFF;
  800b3e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	c1 e3 08             	shl    $0x8,%ebx
  800b47:	89 d6                	mov    %edx,%esi
  800b49:	c1 e6 18             	shl    $0x18,%esi
  800b4c:	89 d0                	mov    %edx,%eax
  800b4e:	c1 e0 10             	shl    $0x10,%eax
  800b51:	09 f0                	or     %esi,%eax
  800b53:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b55:	89 d8                	mov    %ebx,%eax
  800b57:	09 d0                	or     %edx,%eax
  800b59:	c1 e9 02             	shr    $0x2,%ecx
  800b5c:	fc                   	cld    
  800b5d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b5f:	eb 06                	jmp    800b67 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b64:	fc                   	cld    
  800b65:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b67:	89 f8                	mov    %edi,%eax
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7c:	39 c6                	cmp    %eax,%esi
  800b7e:	73 35                	jae    800bb5 <memmove+0x47>
  800b80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b83:	39 d0                	cmp    %edx,%eax
  800b85:	73 2e                	jae    800bb5 <memmove+0x47>
		s += n;
		d += n;
  800b87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	09 fe                	or     %edi,%esi
  800b8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b94:	75 13                	jne    800ba9 <memmove+0x3b>
  800b96:	f6 c1 03             	test   $0x3,%cl
  800b99:	75 0e                	jne    800ba9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b9b:	83 ef 04             	sub    $0x4,%edi
  800b9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba1:	c1 e9 02             	shr    $0x2,%ecx
  800ba4:	fd                   	std    
  800ba5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba7:	eb 09                	jmp    800bb2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ba9:	83 ef 01             	sub    $0x1,%edi
  800bac:	8d 72 ff             	lea    -0x1(%edx),%esi
  800baf:	fd                   	std    
  800bb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb2:	fc                   	cld    
  800bb3:	eb 1d                	jmp    800bd2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb5:	89 f2                	mov    %esi,%edx
  800bb7:	09 c2                	or     %eax,%edx
  800bb9:	f6 c2 03             	test   $0x3,%dl
  800bbc:	75 0f                	jne    800bcd <memmove+0x5f>
  800bbe:	f6 c1 03             	test   $0x3,%cl
  800bc1:	75 0a                	jne    800bcd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bc3:	c1 e9 02             	shr    $0x2,%ecx
  800bc6:	89 c7                	mov    %eax,%edi
  800bc8:	fc                   	cld    
  800bc9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcb:	eb 05                	jmp    800bd2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	fc                   	cld    
  800bd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bd9:	ff 75 10             	pushl  0x10(%ebp)
  800bdc:	ff 75 0c             	pushl  0xc(%ebp)
  800bdf:	ff 75 08             	pushl  0x8(%ebp)
  800be2:	e8 87 ff ff ff       	call   800b6e <memmove>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bf2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf5:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	74 39                	je     800c35 <memcmp+0x4c>
  800bfc:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800bff:	0f b6 13             	movzbl (%ebx),%edx
  800c02:	0f b6 0e             	movzbl (%esi),%ecx
  800c05:	38 ca                	cmp    %cl,%dl
  800c07:	75 17                	jne    800c20 <memcmp+0x37>
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0e:	eb 1a                	jmp    800c2a <memcmp+0x41>
  800c10:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c15:	83 c0 01             	add    $0x1,%eax
  800c18:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c1c:	38 ca                	cmp    %cl,%dl
  800c1e:	74 0a                	je     800c2a <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c20:	0f b6 c2             	movzbl %dl,%eax
  800c23:	0f b6 c9             	movzbl %cl,%ecx
  800c26:	29 c8                	sub    %ecx,%eax
  800c28:	eb 10                	jmp    800c3a <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2a:	39 f8                	cmp    %edi,%eax
  800c2c:	75 e2                	jne    800c10 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c33:	eb 05                	jmp    800c3a <memcmp+0x51>
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	53                   	push   %ebx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c46:	89 d0                	mov    %edx,%eax
  800c48:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c4b:	39 c2                	cmp    %eax,%edx
  800c4d:	73 1d                	jae    800c6c <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c53:	0f b6 0a             	movzbl (%edx),%ecx
  800c56:	39 d9                	cmp    %ebx,%ecx
  800c58:	75 09                	jne    800c63 <memfind+0x24>
  800c5a:	eb 14                	jmp    800c70 <memfind+0x31>
  800c5c:	0f b6 0a             	movzbl (%edx),%ecx
  800c5f:	39 d9                	cmp    %ebx,%ecx
  800c61:	74 11                	je     800c74 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c63:	83 c2 01             	add    $0x1,%edx
  800c66:	39 d0                	cmp    %edx,%eax
  800c68:	75 f2                	jne    800c5c <memfind+0x1d>
  800c6a:	eb 0a                	jmp    800c76 <memfind+0x37>
  800c6c:	89 d0                	mov    %edx,%eax
  800c6e:	eb 06                	jmp    800c76 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c70:	89 d0                	mov    %edx,%eax
  800c72:	eb 02                	jmp    800c76 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c74:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c76:	5b                   	pop    %ebx
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c85:	0f b6 01             	movzbl (%ecx),%eax
  800c88:	3c 20                	cmp    $0x20,%al
  800c8a:	74 04                	je     800c90 <strtol+0x17>
  800c8c:	3c 09                	cmp    $0x9,%al
  800c8e:	75 0e                	jne    800c9e <strtol+0x25>
		s++;
  800c90:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c93:	0f b6 01             	movzbl (%ecx),%eax
  800c96:	3c 20                	cmp    $0x20,%al
  800c98:	74 f6                	je     800c90 <strtol+0x17>
  800c9a:	3c 09                	cmp    $0x9,%al
  800c9c:	74 f2                	je     800c90 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c9e:	3c 2b                	cmp    $0x2b,%al
  800ca0:	75 0a                	jne    800cac <strtol+0x33>
		s++;
  800ca2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca5:	bf 00 00 00 00       	mov    $0x0,%edi
  800caa:	eb 11                	jmp    800cbd <strtol+0x44>
  800cac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb1:	3c 2d                	cmp    $0x2d,%al
  800cb3:	75 08                	jne    800cbd <strtol+0x44>
		s++, neg = 1;
  800cb5:	83 c1 01             	add    $0x1,%ecx
  800cb8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc3:	75 15                	jne    800cda <strtol+0x61>
  800cc5:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc8:	75 10                	jne    800cda <strtol+0x61>
  800cca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cce:	75 7c                	jne    800d4c <strtol+0xd3>
		s += 2, base = 16;
  800cd0:	83 c1 02             	add    $0x2,%ecx
  800cd3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd8:	eb 16                	jmp    800cf0 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cda:	85 db                	test   %ebx,%ebx
  800cdc:	75 12                	jne    800cf0 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cde:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce6:	75 08                	jne    800cf0 <strtol+0x77>
		s++, base = 8;
  800ce8:	83 c1 01             	add    $0x1,%ecx
  800ceb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf8:	0f b6 11             	movzbl (%ecx),%edx
  800cfb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cfe:	89 f3                	mov    %esi,%ebx
  800d00:	80 fb 09             	cmp    $0x9,%bl
  800d03:	77 08                	ja     800d0d <strtol+0x94>
			dig = *s - '0';
  800d05:	0f be d2             	movsbl %dl,%edx
  800d08:	83 ea 30             	sub    $0x30,%edx
  800d0b:	eb 22                	jmp    800d2f <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d10:	89 f3                	mov    %esi,%ebx
  800d12:	80 fb 19             	cmp    $0x19,%bl
  800d15:	77 08                	ja     800d1f <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d17:	0f be d2             	movsbl %dl,%edx
  800d1a:	83 ea 57             	sub    $0x57,%edx
  800d1d:	eb 10                	jmp    800d2f <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d22:	89 f3                	mov    %esi,%ebx
  800d24:	80 fb 19             	cmp    $0x19,%bl
  800d27:	77 16                	ja     800d3f <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d29:	0f be d2             	movsbl %dl,%edx
  800d2c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d2f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d32:	7d 0b                	jge    800d3f <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d34:	83 c1 01             	add    $0x1,%ecx
  800d37:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d3b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d3d:	eb b9                	jmp    800cf8 <strtol+0x7f>

	if (endptr)
  800d3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d43:	74 0d                	je     800d52 <strtol+0xd9>
		*endptr = (char *) s;
  800d45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d48:	89 0e                	mov    %ecx,(%esi)
  800d4a:	eb 06                	jmp    800d52 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d4c:	85 db                	test   %ebx,%ebx
  800d4e:	74 98                	je     800ce8 <strtol+0x6f>
  800d50:	eb 9e                	jmp    800cf0 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d52:	89 c2                	mov    %eax,%edx
  800d54:	f7 da                	neg    %edx
  800d56:	85 ff                	test   %edi,%edi
  800d58:	0f 45 c2             	cmovne %edx,%eax
}
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d65:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	89 c3                	mov    %eax,%ebx
  800d72:	89 c7                	mov    %eax,%edi
  800d74:	51                   	push   %ecx
  800d75:	52                   	push   %edx
  800d76:	53                   	push   %ebx
  800d77:	56                   	push   %esi
  800d78:	57                   	push   %edi
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	8d 35 84 0d 80 00    	lea    0x800d84,%esi
  800d82:	0f 34                	sysenter 

00800d84 <label_21>:
  800d84:	89 ec                	mov    %ebp,%esp
  800d86:	5d                   	pop    %ebp
  800d87:	5f                   	pop    %edi
  800d88:	5e                   	pop    %esi
  800d89:	5b                   	pop    %ebx
  800d8a:	5a                   	pop    %edx
  800d8b:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9f:	89 ca                	mov    %ecx,%edx
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	51                   	push   %ecx
  800da6:	52                   	push   %edx
  800da7:	53                   	push   %ebx
  800da8:	56                   	push   %esi
  800da9:	57                   	push   %edi
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	8d 35 b5 0d 80 00    	lea    0x800db5,%esi
  800db3:	0f 34                	sysenter 

00800db5 <label_55>:
  800db5:	89 ec                	mov    %ebp,%esp
  800db7:	5d                   	pop    %ebp
  800db8:	5f                   	pop    %edi
  800db9:	5e                   	pop    %esi
  800dba:	5b                   	pop    %ebx
  800dbb:	5a                   	pop    %edx
  800dbc:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 d9                	mov    %ebx,%ecx
  800dd5:	89 df                	mov    %ebx,%edi
  800dd7:	51                   	push   %ecx
  800dd8:	52                   	push   %edx
  800dd9:	53                   	push   %ebx
  800dda:	56                   	push   %esi
  800ddb:	57                   	push   %edi
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	8d 35 e7 0d 80 00    	lea    0x800de7,%esi
  800de5:	0f 34                	sysenter 

00800de7 <label_90>:
  800de7:	89 ec                	mov    %ebp,%esp
  800de9:	5d                   	pop    %ebp
  800dea:	5f                   	pop    %edi
  800deb:	5e                   	pop    %esi
  800dec:	5b                   	pop    %ebx
  800ded:	5a                   	pop    %edx
  800dee:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 17                	jle    800e0a <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 03                	push   $0x3
  800df9:	68 04 17 80 00       	push   $0x801704
  800dfe:	6a 29                	push   $0x29
  800e00:	68 21 17 80 00       	push   $0x801721
  800e05:	e8 06 03 00 00       	call   801110 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	57                   	push   %edi
  800e15:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e20:	89 ca                	mov    %ecx,%edx
  800e22:	89 cb                	mov    %ecx,%ebx
  800e24:	89 cf                	mov    %ecx,%edi
  800e26:	51                   	push   %ecx
  800e27:	52                   	push   %edx
  800e28:	53                   	push   %ebx
  800e29:	56                   	push   %esi
  800e2a:	57                   	push   %edi
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	8d 35 36 0e 80 00    	lea    0x800e36,%esi
  800e34:	0f 34                	sysenter 

00800e36 <label_139>:
  800e36:	89 ec                	mov    %ebp,%esp
  800e38:	5d                   	pop    %ebp
  800e39:	5f                   	pop    %edi
  800e3a:	5e                   	pop    %esi
  800e3b:	5b                   	pop    %ebx
  800e3c:	5a                   	pop    %edx
  800e3d:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e3e:	5b                   	pop    %ebx
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e47:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800e51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e54:	8b 55 08             	mov    0x8(%ebp),%edx
  800e57:	89 fb                	mov    %edi,%ebx
  800e59:	51                   	push   %ecx
  800e5a:	52                   	push   %edx
  800e5b:	53                   	push   %ebx
  800e5c:	56                   	push   %esi
  800e5d:	57                   	push   %edi
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	8d 35 69 0e 80 00    	lea    0x800e69,%esi
  800e67:	0f 34                	sysenter 

00800e69 <label_174>:
  800e69:	89 ec                	mov    %ebp,%esp
  800e6b:	5d                   	pop    %ebp
  800e6c:	5f                   	pop    %edi
  800e6d:	5e                   	pop    %esi
  800e6e:	5b                   	pop    %ebx
  800e6f:	5a                   	pop    %edx
  800e70:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e71:	5b                   	pop    %ebx
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_yield>:

void
sys_yield(void)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e84:	89 d1                	mov    %edx,%ecx
  800e86:	89 d3                	mov    %edx,%ebx
  800e88:	89 d7                	mov    %edx,%edi
  800e8a:	51                   	push   %ecx
  800e8b:	52                   	push   %edx
  800e8c:	53                   	push   %ebx
  800e8d:	56                   	push   %esi
  800e8e:	57                   	push   %edi
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	8d 35 9a 0e 80 00    	lea    0x800e9a,%esi
  800e98:	0f 34                	sysenter 

00800e9a <label_209>:
  800e9a:	89 ec                	mov    %ebp,%esp
  800e9c:	5d                   	pop    %ebp
  800e9d:	5f                   	pop    %edi
  800e9e:	5e                   	pop    %esi
  800e9f:	5b                   	pop    %ebx
  800ea0:	5a                   	pop    %edx
  800ea1:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eab:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb0:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebe:	51                   	push   %ecx
  800ebf:	52                   	push   %edx
  800ec0:	53                   	push   %ebx
  800ec1:	56                   	push   %esi
  800ec2:	57                   	push   %edi
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	8d 35 ce 0e 80 00    	lea    0x800ece,%esi
  800ecc:	0f 34                	sysenter 

00800ece <label_244>:
  800ece:	89 ec                	mov    %ebp,%esp
  800ed0:	5d                   	pop    %ebp
  800ed1:	5f                   	pop    %edi
  800ed2:	5e                   	pop    %esi
  800ed3:	5b                   	pop    %ebx
  800ed4:	5a                   	pop    %edx
  800ed5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	7e 17                	jle    800ef1 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	50                   	push   %eax
  800ede:	6a 05                	push   $0x5
  800ee0:	68 04 17 80 00       	push   $0x801704
  800ee5:	6a 29                	push   $0x29
  800ee7:	68 21 17 80 00       	push   $0x801721
  800eec:	e8 1f 02 00 00       	call   801110 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ef1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800f00:	8b 45 08             	mov    0x8(%ebp),%eax
  800f03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f09:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800f0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800f12:	8b 45 14             	mov    0x14(%ebp),%eax
  800f15:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800f18:	8b 45 18             	mov    0x18(%ebp),%eax
  800f1b:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f1e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f26:	b8 06 00 00 00       	mov    $0x6,%eax
  800f2b:	89 cb                	mov    %ecx,%ebx
  800f2d:	89 cf                	mov    %ecx,%edi
  800f2f:	51                   	push   %ecx
  800f30:	52                   	push   %edx
  800f31:	53                   	push   %ebx
  800f32:	56                   	push   %esi
  800f33:	57                   	push   %edi
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	8d 35 3f 0f 80 00    	lea    0x800f3f,%esi
  800f3d:	0f 34                	sysenter 

00800f3f <label_304>:
  800f3f:	89 ec                	mov    %ebp,%esp
  800f41:	5d                   	pop    %ebp
  800f42:	5f                   	pop    %edi
  800f43:	5e                   	pop    %esi
  800f44:	5b                   	pop    %ebx
  800f45:	5a                   	pop    %edx
  800f46:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	7e 17                	jle    800f62 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	50                   	push   %eax
  800f4f:	6a 06                	push   $0x6
  800f51:	68 04 17 80 00       	push   $0x801704
  800f56:	6a 29                	push   $0x29
  800f58:	68 21 17 80 00       	push   $0x801721
  800f5d:	e8 ae 01 00 00       	call   801110 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  800f62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f73:	b8 07 00 00 00       	mov    $0x7,%eax
  800f78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	89 fb                	mov    %edi,%ebx
  800f80:	51                   	push   %ecx
  800f81:	52                   	push   %edx
  800f82:	53                   	push   %ebx
  800f83:	56                   	push   %esi
  800f84:	57                   	push   %edi
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	8d 35 90 0f 80 00    	lea    0x800f90,%esi
  800f8e:	0f 34                	sysenter 

00800f90 <label_353>:
  800f90:	89 ec                	mov    %ebp,%esp
  800f92:	5d                   	pop    %ebp
  800f93:	5f                   	pop    %edi
  800f94:	5e                   	pop    %esi
  800f95:	5b                   	pop    %ebx
  800f96:	5a                   	pop    %edx
  800f97:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	7e 17                	jle    800fb3 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	50                   	push   %eax
  800fa0:	6a 07                	push   $0x7
  800fa2:	68 04 17 80 00       	push   $0x801704
  800fa7:	6a 29                	push   $0x29
  800fa9:	68 21 17 80 00       	push   $0x801721
  800fae:	e8 5d 01 00 00       	call   801110 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fbf:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcf:	89 fb                	mov    %edi,%ebx
  800fd1:	51                   	push   %ecx
  800fd2:	52                   	push   %edx
  800fd3:	53                   	push   %ebx
  800fd4:	56                   	push   %esi
  800fd5:	57                   	push   %edi
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	8d 35 e1 0f 80 00    	lea    0x800fe1,%esi
  800fdf:	0f 34                	sysenter 

00800fe1 <label_402>:
  800fe1:	89 ec                	mov    %ebp,%esp
  800fe3:	5d                   	pop    %ebp
  800fe4:	5f                   	pop    %edi
  800fe5:	5e                   	pop    %esi
  800fe6:	5b                   	pop    %ebx
  800fe7:	5a                   	pop    %edx
  800fe8:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 09                	push   $0x9
  800ff3:	68 04 17 80 00       	push   $0x801704
  800ff8:	6a 29                	push   $0x29
  800ffa:	68 21 17 80 00       	push   $0x801721
  800fff:	e8 0c 01 00 00       	call   801110 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801004:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801010:	bf 00 00 00 00       	mov    $0x0,%edi
  801015:	b8 0a 00 00 00       	mov    $0xa,%eax
  80101a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101d:	8b 55 08             	mov    0x8(%ebp),%edx
  801020:	89 fb                	mov    %edi,%ebx
  801022:	51                   	push   %ecx
  801023:	52                   	push   %edx
  801024:	53                   	push   %ebx
  801025:	56                   	push   %esi
  801026:	57                   	push   %edi
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	8d 35 32 10 80 00    	lea    0x801032,%esi
  801030:	0f 34                	sysenter 

00801032 <label_451>:
  801032:	89 ec                	mov    %ebp,%esp
  801034:	5d                   	pop    %ebp
  801035:	5f                   	pop    %edi
  801036:	5e                   	pop    %esi
  801037:	5b                   	pop    %ebx
  801038:	5a                   	pop    %edx
  801039:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	7e 17                	jle    801055 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103e:	83 ec 0c             	sub    $0xc,%esp
  801041:	50                   	push   %eax
  801042:	6a 0a                	push   $0xa
  801044:	68 04 17 80 00       	push   $0x801704
  801049:	6a 29                	push   $0x29
  80104b:	68 21 17 80 00       	push   $0x801721
  801050:	e8 bb 00 00 00       	call   801110 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801055:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	57                   	push   %edi
  801060:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801061:	b8 0c 00 00 00       	mov    $0xc,%eax
  801066:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801069:	8b 55 08             	mov    0x8(%ebp),%edx
  80106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801072:	51                   	push   %ecx
  801073:	52                   	push   %edx
  801074:	53                   	push   %ebx
  801075:	56                   	push   %esi
  801076:	57                   	push   %edi
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	8d 35 82 10 80 00    	lea    0x801082,%esi
  801080:	0f 34                	sysenter 

00801082 <label_502>:
  801082:	89 ec                	mov    %ebp,%esp
  801084:	5d                   	pop    %ebp
  801085:	5f                   	pop    %edi
  801086:	5e                   	pop    %esi
  801087:	5b                   	pop    %ebx
  801088:	5a                   	pop    %edx
  801089:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80108a:	5b                   	pop    %ebx
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	57                   	push   %edi
  801092:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801093:	bb 00 00 00 00       	mov    $0x0,%ebx
  801098:	b8 0d 00 00 00       	mov    $0xd,%eax
  80109d:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a0:	89 d9                	mov    %ebx,%ecx
  8010a2:	89 df                	mov    %ebx,%edi
  8010a4:	51                   	push   %ecx
  8010a5:	52                   	push   %edx
  8010a6:	53                   	push   %ebx
  8010a7:	56                   	push   %esi
  8010a8:	57                   	push   %edi
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	8d 35 b4 10 80 00    	lea    0x8010b4,%esi
  8010b2:	0f 34                	sysenter 

008010b4 <label_537>:
  8010b4:	89 ec                	mov    %ebp,%esp
  8010b6:	5d                   	pop    %ebp
  8010b7:	5f                   	pop    %edi
  8010b8:	5e                   	pop    %esi
  8010b9:	5b                   	pop    %ebx
  8010ba:	5a                   	pop    %edx
  8010bb:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	7e 17                	jle    8010d7 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	50                   	push   %eax
  8010c4:	6a 0d                	push   $0xd
  8010c6:	68 04 17 80 00       	push   $0x801704
  8010cb:	6a 29                	push   $0x29
  8010cd:	68 21 17 80 00       	push   $0x801721
  8010d2:	e8 39 00 00 00       	call   801110 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5f                   	pop    %edi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	57                   	push   %edi
  8010e2:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	89 cb                	mov    %ecx,%ebx
  8010f2:	89 cf                	mov    %ecx,%edi
  8010f4:	51                   	push   %ecx
  8010f5:	52                   	push   %edx
  8010f6:	53                   	push   %ebx
  8010f7:	56                   	push   %esi
  8010f8:	57                   	push   %edi
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	8d 35 04 11 80 00    	lea    0x801104,%esi
  801102:	0f 34                	sysenter 

00801104 <label_586>:
  801104:	89 ec                	mov    %ebp,%esp
  801106:	5d                   	pop    %ebp
  801107:	5f                   	pop    %edi
  801108:	5e                   	pop    %esi
  801109:	5b                   	pop    %ebx
  80110a:	5a                   	pop    %edx
  80110b:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80110c:	5b                   	pop    %ebx
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801115:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  801118:	a1 10 20 80 00       	mov    0x802010,%eax
  80111d:	85 c0                	test   %eax,%eax
  80111f:	74 11                	je     801132 <_panic+0x22>
		cprintf("%s: ", argv0);
  801121:	83 ec 08             	sub    $0x8,%esp
  801124:	50                   	push   %eax
  801125:	68 2f 17 80 00       	push   $0x80172f
  80112a:	e8 1a f0 ff ff       	call   800149 <cprintf>
  80112f:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801132:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801138:	e8 d4 fc ff ff       	call   800e11 <sys_getenvid>
  80113d:	83 ec 0c             	sub    $0xc,%esp
  801140:	ff 75 0c             	pushl  0xc(%ebp)
  801143:	ff 75 08             	pushl  0x8(%ebp)
  801146:	56                   	push   %esi
  801147:	50                   	push   %eax
  801148:	68 34 17 80 00       	push   $0x801734
  80114d:	e8 f7 ef ff ff       	call   800149 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801152:	83 c4 18             	add    $0x18,%esp
  801155:	53                   	push   %ebx
  801156:	ff 75 10             	pushl  0x10(%ebp)
  801159:	e8 9a ef ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  80115e:	c7 04 24 0c 14 80 00 	movl   $0x80140c,(%esp)
  801165:	e8 df ef ff ff       	call   800149 <cprintf>
  80116a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80116d:	cc                   	int3   
  80116e:	eb fd                	jmp    80116d <_panic+0x5d>

00801170 <__udivdi3>:
  801170:	55                   	push   %ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80117b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80117f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801187:	85 f6                	test   %esi,%esi
  801189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80118d:	89 ca                	mov    %ecx,%edx
  80118f:	89 f8                	mov    %edi,%eax
  801191:	75 3d                	jne    8011d0 <__udivdi3+0x60>
  801193:	39 cf                	cmp    %ecx,%edi
  801195:	0f 87 c5 00 00 00    	ja     801260 <__udivdi3+0xf0>
  80119b:	85 ff                	test   %edi,%edi
  80119d:	89 fd                	mov    %edi,%ebp
  80119f:	75 0b                	jne    8011ac <__udivdi3+0x3c>
  8011a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a6:	31 d2                	xor    %edx,%edx
  8011a8:	f7 f7                	div    %edi
  8011aa:	89 c5                	mov    %eax,%ebp
  8011ac:	89 c8                	mov    %ecx,%eax
  8011ae:	31 d2                	xor    %edx,%edx
  8011b0:	f7 f5                	div    %ebp
  8011b2:	89 c1                	mov    %eax,%ecx
  8011b4:	89 d8                	mov    %ebx,%eax
  8011b6:	89 cf                	mov    %ecx,%edi
  8011b8:	f7 f5                	div    %ebp
  8011ba:	89 c3                	mov    %eax,%ebx
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	89 fa                	mov    %edi,%edx
  8011c0:	83 c4 1c             	add    $0x1c,%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    
  8011c8:	90                   	nop
  8011c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	39 ce                	cmp    %ecx,%esi
  8011d2:	77 74                	ja     801248 <__udivdi3+0xd8>
  8011d4:	0f bd fe             	bsr    %esi,%edi
  8011d7:	83 f7 1f             	xor    $0x1f,%edi
  8011da:	0f 84 98 00 00 00    	je     801278 <__udivdi3+0x108>
  8011e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011e5:	89 f9                	mov    %edi,%ecx
  8011e7:	89 c5                	mov    %eax,%ebp
  8011e9:	29 fb                	sub    %edi,%ebx
  8011eb:	d3 e6                	shl    %cl,%esi
  8011ed:	89 d9                	mov    %ebx,%ecx
  8011ef:	d3 ed                	shr    %cl,%ebp
  8011f1:	89 f9                	mov    %edi,%ecx
  8011f3:	d3 e0                	shl    %cl,%eax
  8011f5:	09 ee                	or     %ebp,%esi
  8011f7:	89 d9                	mov    %ebx,%ecx
  8011f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011fd:	89 d5                	mov    %edx,%ebp
  8011ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801203:	d3 ed                	shr    %cl,%ebp
  801205:	89 f9                	mov    %edi,%ecx
  801207:	d3 e2                	shl    %cl,%edx
  801209:	89 d9                	mov    %ebx,%ecx
  80120b:	d3 e8                	shr    %cl,%eax
  80120d:	09 c2                	or     %eax,%edx
  80120f:	89 d0                	mov    %edx,%eax
  801211:	89 ea                	mov    %ebp,%edx
  801213:	f7 f6                	div    %esi
  801215:	89 d5                	mov    %edx,%ebp
  801217:	89 c3                	mov    %eax,%ebx
  801219:	f7 64 24 0c          	mull   0xc(%esp)
  80121d:	39 d5                	cmp    %edx,%ebp
  80121f:	72 10                	jb     801231 <__udivdi3+0xc1>
  801221:	8b 74 24 08          	mov    0x8(%esp),%esi
  801225:	89 f9                	mov    %edi,%ecx
  801227:	d3 e6                	shl    %cl,%esi
  801229:	39 c6                	cmp    %eax,%esi
  80122b:	73 07                	jae    801234 <__udivdi3+0xc4>
  80122d:	39 d5                	cmp    %edx,%ebp
  80122f:	75 03                	jne    801234 <__udivdi3+0xc4>
  801231:	83 eb 01             	sub    $0x1,%ebx
  801234:	31 ff                	xor    %edi,%edi
  801236:	89 d8                	mov    %ebx,%eax
  801238:	89 fa                	mov    %edi,%edx
  80123a:	83 c4 1c             	add    $0x1c,%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5f                   	pop    %edi
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    
  801242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801248:	31 ff                	xor    %edi,%edi
  80124a:	31 db                	xor    %ebx,%ebx
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	89 fa                	mov    %edi,%edx
  801250:	83 c4 1c             	add    $0x1c,%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    
  801258:	90                   	nop
  801259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 d8                	mov    %ebx,%eax
  801262:	f7 f7                	div    %edi
  801264:	31 ff                	xor    %edi,%edi
  801266:	89 c3                	mov    %eax,%ebx
  801268:	89 d8                	mov    %ebx,%eax
  80126a:	89 fa                	mov    %edi,%edx
  80126c:	83 c4 1c             	add    $0x1c,%esp
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5f                   	pop    %edi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	39 ce                	cmp    %ecx,%esi
  80127a:	72 0c                	jb     801288 <__udivdi3+0x118>
  80127c:	31 db                	xor    %ebx,%ebx
  80127e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801282:	0f 87 34 ff ff ff    	ja     8011bc <__udivdi3+0x4c>
  801288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80128d:	e9 2a ff ff ff       	jmp    8011bc <__udivdi3+0x4c>
  801292:	66 90                	xchg   %ax,%ax
  801294:	66 90                	xchg   %ax,%ax
  801296:	66 90                	xchg   %ax,%ax
  801298:	66 90                	xchg   %ax,%ax
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__umoddi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 1c             	sub    $0x1c,%esp
  8012a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012b7:	85 d2                	test   %edx,%edx
  8012b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c1:	89 f3                	mov    %esi,%ebx
  8012c3:	89 3c 24             	mov    %edi,(%esp)
  8012c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ca:	75 1c                	jne    8012e8 <__umoddi3+0x48>
  8012cc:	39 f7                	cmp    %esi,%edi
  8012ce:	76 50                	jbe    801320 <__umoddi3+0x80>
  8012d0:	89 c8                	mov    %ecx,%eax
  8012d2:	89 f2                	mov    %esi,%edx
  8012d4:	f7 f7                	div    %edi
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	31 d2                	xor    %edx,%edx
  8012da:	83 c4 1c             	add    $0x1c,%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5f                   	pop    %edi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    
  8012e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e8:	39 f2                	cmp    %esi,%edx
  8012ea:	89 d0                	mov    %edx,%eax
  8012ec:	77 52                	ja     801340 <__umoddi3+0xa0>
  8012ee:	0f bd ea             	bsr    %edx,%ebp
  8012f1:	83 f5 1f             	xor    $0x1f,%ebp
  8012f4:	75 5a                	jne    801350 <__umoddi3+0xb0>
  8012f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012fa:	0f 82 e0 00 00 00    	jb     8013e0 <__umoddi3+0x140>
  801300:	39 0c 24             	cmp    %ecx,(%esp)
  801303:	0f 86 d7 00 00 00    	jbe    8013e0 <__umoddi3+0x140>
  801309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80130d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801311:	83 c4 1c             	add    $0x1c,%esp
  801314:	5b                   	pop    %ebx
  801315:	5e                   	pop    %esi
  801316:	5f                   	pop    %edi
  801317:	5d                   	pop    %ebp
  801318:	c3                   	ret    
  801319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801320:	85 ff                	test   %edi,%edi
  801322:	89 fd                	mov    %edi,%ebp
  801324:	75 0b                	jne    801331 <__umoddi3+0x91>
  801326:	b8 01 00 00 00       	mov    $0x1,%eax
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	f7 f7                	div    %edi
  80132f:	89 c5                	mov    %eax,%ebp
  801331:	89 f0                	mov    %esi,%eax
  801333:	31 d2                	xor    %edx,%edx
  801335:	f7 f5                	div    %ebp
  801337:	89 c8                	mov    %ecx,%eax
  801339:	f7 f5                	div    %ebp
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	eb 99                	jmp    8012d8 <__umoddi3+0x38>
  80133f:	90                   	nop
  801340:	89 c8                	mov    %ecx,%eax
  801342:	89 f2                	mov    %esi,%edx
  801344:	83 c4 1c             	add    $0x1c,%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    
  80134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801350:	8b 34 24             	mov    (%esp),%esi
  801353:	bf 20 00 00 00       	mov    $0x20,%edi
  801358:	89 e9                	mov    %ebp,%ecx
  80135a:	29 ef                	sub    %ebp,%edi
  80135c:	d3 e0                	shl    %cl,%eax
  80135e:	89 f9                	mov    %edi,%ecx
  801360:	89 f2                	mov    %esi,%edx
  801362:	d3 ea                	shr    %cl,%edx
  801364:	89 e9                	mov    %ebp,%ecx
  801366:	09 c2                	or     %eax,%edx
  801368:	89 d8                	mov    %ebx,%eax
  80136a:	89 14 24             	mov    %edx,(%esp)
  80136d:	89 f2                	mov    %esi,%edx
  80136f:	d3 e2                	shl    %cl,%edx
  801371:	89 f9                	mov    %edi,%ecx
  801373:	89 54 24 04          	mov    %edx,0x4(%esp)
  801377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80137b:	d3 e8                	shr    %cl,%eax
  80137d:	89 e9                	mov    %ebp,%ecx
  80137f:	89 c6                	mov    %eax,%esi
  801381:	d3 e3                	shl    %cl,%ebx
  801383:	89 f9                	mov    %edi,%ecx
  801385:	89 d0                	mov    %edx,%eax
  801387:	d3 e8                	shr    %cl,%eax
  801389:	89 e9                	mov    %ebp,%ecx
  80138b:	09 d8                	or     %ebx,%eax
  80138d:	89 d3                	mov    %edx,%ebx
  80138f:	89 f2                	mov    %esi,%edx
  801391:	f7 34 24             	divl   (%esp)
  801394:	89 d6                	mov    %edx,%esi
  801396:	d3 e3                	shl    %cl,%ebx
  801398:	f7 64 24 04          	mull   0x4(%esp)
  80139c:	39 d6                	cmp    %edx,%esi
  80139e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013a2:	89 d1                	mov    %edx,%ecx
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	72 08                	jb     8013b0 <__umoddi3+0x110>
  8013a8:	75 11                	jne    8013bb <__umoddi3+0x11b>
  8013aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013ae:	73 0b                	jae    8013bb <__umoddi3+0x11b>
  8013b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013b4:	1b 14 24             	sbb    (%esp),%edx
  8013b7:	89 d1                	mov    %edx,%ecx
  8013b9:	89 c3                	mov    %eax,%ebx
  8013bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013bf:	29 da                	sub    %ebx,%edx
  8013c1:	19 ce                	sbb    %ecx,%esi
  8013c3:	89 f9                	mov    %edi,%ecx
  8013c5:	89 f0                	mov    %esi,%eax
  8013c7:	d3 e0                	shl    %cl,%eax
  8013c9:	89 e9                	mov    %ebp,%ecx
  8013cb:	d3 ea                	shr    %cl,%edx
  8013cd:	89 e9                	mov    %ebp,%ecx
  8013cf:	d3 ee                	shr    %cl,%esi
  8013d1:	09 d0                	or     %edx,%eax
  8013d3:	89 f2                	mov    %esi,%edx
  8013d5:	83 c4 1c             	add    $0x1c,%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	29 f9                	sub    %edi,%ecx
  8013e2:	19 d6                	sbb    %edx,%esi
  8013e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ec:	e9 18 ff ff ff       	jmp    801309 <__umoddi3+0x69>
