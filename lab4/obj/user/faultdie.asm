
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 60 14 80 00       	push   $0x801460
  80004a:	e8 1c 01 00 00       	call   80016b <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 df 0d 00 00       	call   800e33 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 87 0d 00 00       	call   800de3 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 c1 10 00 00       	call   801132 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80008b:	e8 a3 0d 00 00       	call   800e33 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	c1 e0 07             	shl    $0x7,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 10 0d 00 00       	call   800de3 <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	75 1a                	jne    800111 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 7a 0c 00 00       	call   800d82 <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	68 d8 00 80 00       	push   $0x8000d8
  800149:	e8 c0 02 00 00       	call   80040e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014e:	83 c4 08             	add    $0x8,%esp
  800151:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	e8 1f 0c 00 00       	call   800d82 <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	50                   	push   %eax
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	e8 9d ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 1c             	sub    $0x1c,%esp
  800188:	89 c7                	mov    %eax,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800195:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800198:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80019b:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80019f:	0f 85 bf 00 00 00    	jne    800264 <printnum+0xe5>
  8001a5:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8001ab:	0f 8d de 00 00 00    	jge    80028f <printnum+0x110>
		judge_time_for_space = width;
  8001b1:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8001b7:	e9 d3 00 00 00       	jmp    80028f <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001bc:	83 eb 01             	sub    $0x1,%ebx
  8001bf:	85 db                	test   %ebx,%ebx
  8001c1:	7f 37                	jg     8001fa <printnum+0x7b>
  8001c3:	e9 ea 00 00 00       	jmp    8002b2 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8001c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001cb:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	83 ec 04             	sub    $0x4,%esp
  8001d7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001da:	ff 75 d8             	pushl  -0x28(%ebp)
  8001dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e3:	e8 08 11 00 00       	call   8012f0 <__umoddi3>
  8001e8:	83 c4 14             	add    $0x14,%esp
  8001eb:	0f be 80 86 14 80 00 	movsbl 0x801486(%eax),%eax
  8001f2:	50                   	push   %eax
  8001f3:	ff d7                	call   *%edi
  8001f5:	83 c4 10             	add    $0x10,%esp
  8001f8:	eb 16                	jmp    800210 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	56                   	push   %esi
  8001fe:	ff 75 18             	pushl  0x18(%ebp)
  800201:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	83 eb 01             	sub    $0x1,%ebx
  800209:	75 ef                	jne    8001fa <printnum+0x7b>
  80020b:	e9 a2 00 00 00       	jmp    8002b2 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800210:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800216:	0f 85 76 01 00 00    	jne    800392 <printnum+0x213>
		while(num_of_space-- > 0)
  80021c:	a1 04 20 80 00       	mov    0x802004,%eax
  800221:	8d 50 ff             	lea    -0x1(%eax),%edx
  800224:	89 15 04 20 80 00    	mov    %edx,0x802004
  80022a:	85 c0                	test   %eax,%eax
  80022c:	7e 1d                	jle    80024b <printnum+0xcc>
			putch(' ', putdat);
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	56                   	push   %esi
  800232:	6a 20                	push   $0x20
  800234:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800236:	a1 04 20 80 00       	mov    0x802004,%eax
  80023b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80023e:	89 15 04 20 80 00    	mov    %edx,0x802004
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	85 c0                	test   %eax,%eax
  800249:	7f e3                	jg     80022e <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  80024b:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800252:	00 00 00 
		judge_time_for_space = 0;
  800255:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80025c:	00 00 00 
	}
}
  80025f:	e9 2e 01 00 00       	jmp    800392 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800264:	8b 45 10             	mov    0x10(%ebp),%eax
  800267:	ba 00 00 00 00       	mov    $0x0,%edx
  80026c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800275:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800278:	83 fa 00             	cmp    $0x0,%edx
  80027b:	0f 87 ba 00 00 00    	ja     80033b <printnum+0x1bc>
  800281:	3b 45 10             	cmp    0x10(%ebp),%eax
  800284:	0f 83 b1 00 00 00    	jae    80033b <printnum+0x1bc>
  80028a:	e9 2d ff ff ff       	jmp    8001bc <printnum+0x3d>
  80028f:	8b 45 10             	mov    0x10(%ebp),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80029d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002a3:	83 fa 00             	cmp    $0x0,%edx
  8002a6:	77 37                	ja     8002df <printnum+0x160>
  8002a8:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002ab:	73 32                	jae    8002df <printnum+0x160>
  8002ad:	e9 16 ff ff ff       	jmp    8001c8 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	56                   	push   %esi
  8002b6:	83 ec 04             	sub    $0x4,%esp
  8002b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c5:	e8 26 10 00 00       	call   8012f0 <__umoddi3>
  8002ca:	83 c4 14             	add    $0x14,%esp
  8002cd:	0f be 80 86 14 80 00 	movsbl 0x801486(%eax),%eax
  8002d4:	50                   	push   %eax
  8002d5:	ff d7                	call   *%edi
  8002d7:	83 c4 10             	add    $0x10,%esp
  8002da:	e9 b3 00 00 00       	jmp    800392 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 18             	pushl  0x18(%ebp)
  8002e5:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002e8:	50                   	push   %eax
  8002e9:	ff 75 10             	pushl  0x10(%ebp)
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002fb:	e8 c0 0e 00 00       	call   8011c0 <__udivdi3>
  800300:	83 c4 18             	add    $0x18,%esp
  800303:	52                   	push   %edx
  800304:	50                   	push   %eax
  800305:	89 f2                	mov    %esi,%edx
  800307:	89 f8                	mov    %edi,%eax
  800309:	e8 71 fe ff ff       	call   80017f <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030e:	83 c4 18             	add    $0x18,%esp
  800311:	56                   	push   %esi
  800312:	83 ec 04             	sub    $0x4,%esp
  800315:	ff 75 dc             	pushl  -0x24(%ebp)
  800318:	ff 75 d8             	pushl  -0x28(%ebp)
  80031b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80031e:	ff 75 e0             	pushl  -0x20(%ebp)
  800321:	e8 ca 0f 00 00       	call   8012f0 <__umoddi3>
  800326:	83 c4 14             	add    $0x14,%esp
  800329:	0f be 80 86 14 80 00 	movsbl 0x801486(%eax),%eax
  800330:	50                   	push   %eax
  800331:	ff d7                	call   *%edi
  800333:	83 c4 10             	add    $0x10,%esp
  800336:	e9 d5 fe ff ff       	jmp    800210 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033b:	83 ec 0c             	sub    $0xc,%esp
  80033e:	ff 75 18             	pushl  0x18(%ebp)
  800341:	83 eb 01             	sub    $0x1,%ebx
  800344:	53                   	push   %ebx
  800345:	ff 75 10             	pushl  0x10(%ebp)
  800348:	83 ec 08             	sub    $0x8,%esp
  80034b:	ff 75 dc             	pushl  -0x24(%ebp)
  80034e:	ff 75 d8             	pushl  -0x28(%ebp)
  800351:	ff 75 e4             	pushl  -0x1c(%ebp)
  800354:	ff 75 e0             	pushl  -0x20(%ebp)
  800357:	e8 64 0e 00 00       	call   8011c0 <__udivdi3>
  80035c:	83 c4 18             	add    $0x18,%esp
  80035f:	52                   	push   %edx
  800360:	50                   	push   %eax
  800361:	89 f2                	mov    %esi,%edx
  800363:	89 f8                	mov    %edi,%eax
  800365:	e8 15 fe ff ff       	call   80017f <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036a:	83 c4 18             	add    $0x18,%esp
  80036d:	56                   	push   %esi
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	ff 75 e4             	pushl  -0x1c(%ebp)
  80037a:	ff 75 e0             	pushl  -0x20(%ebp)
  80037d:	e8 6e 0f 00 00       	call   8012f0 <__umoddi3>
  800382:	83 c4 14             	add    $0x14,%esp
  800385:	0f be 80 86 14 80 00 	movsbl 0x801486(%eax),%eax
  80038c:	50                   	push   %eax
  80038d:	ff d7                	call   *%edi
  80038f:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800392:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800395:	5b                   	pop    %ebx
  800396:	5e                   	pop    %esi
  800397:	5f                   	pop    %edi
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80039d:	83 fa 01             	cmp    $0x1,%edx
  8003a0:	7e 0e                	jle    8003b0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	8b 52 04             	mov    0x4(%edx),%edx
  8003ae:	eb 22                	jmp    8003d2 <getuint+0x38>
	else if (lflag)
  8003b0:	85 d2                	test   %edx,%edx
  8003b2:	74 10                	je     8003c4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b4:	8b 10                	mov    (%eax),%edx
  8003b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b9:	89 08                	mov    %ecx,(%eax)
  8003bb:	8b 02                	mov    (%edx),%eax
  8003bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c2:	eb 0e                	jmp    8003d2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c9:	89 08                	mov    %ecx,(%eax)
  8003cb:	8b 02                	mov    (%edx),%eax
  8003cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d2:	5d                   	pop    %ebp
  8003d3:	c3                   	ret    

008003d4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003da:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e3:	73 0a                	jae    8003ef <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e8:	89 08                	mov    %ecx,(%eax)
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ed:	88 02                	mov    %al,(%edx)
}
  8003ef:	5d                   	pop    %ebp
  8003f0:	c3                   	ret    

008003f1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fa:	50                   	push   %eax
  8003fb:	ff 75 10             	pushl  0x10(%ebp)
  8003fe:	ff 75 0c             	pushl  0xc(%ebp)
  800401:	ff 75 08             	pushl  0x8(%ebp)
  800404:	e8 05 00 00 00       	call   80040e <vprintfmt>
	va_end(ap);
}
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	c9                   	leave  
  80040d:	c3                   	ret    

0080040e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	57                   	push   %edi
  800412:	56                   	push   %esi
  800413:	53                   	push   %ebx
  800414:	83 ec 2c             	sub    $0x2c,%esp
  800417:	8b 7d 08             	mov    0x8(%ebp),%edi
  80041a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041d:	eb 03                	jmp    800422 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80041f:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800422:	8b 45 10             	mov    0x10(%ebp),%eax
  800425:	8d 70 01             	lea    0x1(%eax),%esi
  800428:	0f b6 00             	movzbl (%eax),%eax
  80042b:	83 f8 25             	cmp    $0x25,%eax
  80042e:	74 27                	je     800457 <vprintfmt+0x49>
			if (ch == '\0')
  800430:	85 c0                	test   %eax,%eax
  800432:	75 0d                	jne    800441 <vprintfmt+0x33>
  800434:	e9 9d 04 00 00       	jmp    8008d6 <vprintfmt+0x4c8>
  800439:	85 c0                	test   %eax,%eax
  80043b:	0f 84 95 04 00 00    	je     8008d6 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	50                   	push   %eax
  800446:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800448:	83 c6 01             	add    $0x1,%esi
  80044b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	83 f8 25             	cmp    $0x25,%eax
  800455:	75 e2                	jne    800439 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800457:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045c:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800460:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800467:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800475:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80047c:	eb 08                	jmp    800486 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800481:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8d 46 01             	lea    0x1(%esi),%eax
  800489:	89 45 10             	mov    %eax,0x10(%ebp)
  80048c:	0f b6 06             	movzbl (%esi),%eax
  80048f:	0f b6 d0             	movzbl %al,%edx
  800492:	83 e8 23             	sub    $0x23,%eax
  800495:	3c 55                	cmp    $0x55,%al
  800497:	0f 87 fa 03 00 00    	ja     800897 <vprintfmt+0x489>
  80049d:	0f b6 c0             	movzbl %al,%eax
  8004a0:	ff 24 85 c0 15 80 00 	jmp    *0x8015c0(,%eax,4)
  8004a7:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004aa:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8004ae:	eb d6                	jmp    800486 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004b6:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004ba:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004bd:	83 fa 09             	cmp    $0x9,%edx
  8004c0:	77 6b                	ja     80052d <vprintfmt+0x11f>
  8004c2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004c5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004c8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004cb:	eb 09                	jmp    8004d6 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d0:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8004d4:	eb b0                	jmp    800486 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d6:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004d9:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004dc:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004e0:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004e3:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004e6:	83 f9 09             	cmp    $0x9,%ecx
  8004e9:	76 eb                	jbe    8004d6 <vprintfmt+0xc8>
  8004eb:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004ee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f1:	eb 3d                	jmp    800530 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8d 50 04             	lea    0x4(%eax),%edx
  8004f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fc:	8b 00                	mov    (%eax),%eax
  8004fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800504:	eb 2a                	jmp    800530 <vprintfmt+0x122>
  800506:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800509:	85 c0                	test   %eax,%eax
  80050b:	ba 00 00 00 00       	mov    $0x0,%edx
  800510:	0f 49 d0             	cmovns %eax,%edx
  800513:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 75 10             	mov    0x10(%ebp),%esi
  800519:	e9 68 ff ff ff       	jmp    800486 <vprintfmt+0x78>
  80051e:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800521:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800528:	e9 59 ff ff ff       	jmp    800486 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800530:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800534:	0f 89 4c ff ff ff    	jns    800486 <vprintfmt+0x78>
				width = precision, precision = -1;
  80053a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800540:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800547:	e9 3a ff ff ff       	jmp    800486 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054c:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800553:	e9 2e ff ff ff       	jmp    800486 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	53                   	push   %ebx
  800565:	ff 30                	pushl  (%eax)
  800567:	ff d7                	call   *%edi
			break;
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	e9 b1 fe ff ff       	jmp    800422 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	99                   	cltd   
  80057d:	31 d0                	xor    %edx,%eax
  80057f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800581:	83 f8 08             	cmp    $0x8,%eax
  800584:	7f 0b                	jg     800591 <vprintfmt+0x183>
  800586:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  80058d:	85 d2                	test   %edx,%edx
  80058f:	75 15                	jne    8005a6 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800591:	50                   	push   %eax
  800592:	68 9e 14 80 00       	push   $0x80149e
  800597:	53                   	push   %ebx
  800598:	57                   	push   %edi
  800599:	e8 53 fe ff ff       	call   8003f1 <printfmt>
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	e9 7c fe ff ff       	jmp    800422 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005a6:	52                   	push   %edx
  8005a7:	68 a7 14 80 00       	push   $0x8014a7
  8005ac:	53                   	push   %ebx
  8005ad:	57                   	push   %edi
  8005ae:	e8 3e fe ff ff       	call   8003f1 <printfmt>
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	e9 67 fe ff ff       	jmp    800422 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	b9 97 14 80 00       	mov    $0x801497,%ecx
  8005cd:	0f 45 c8             	cmovne %eax,%ecx
  8005d0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d7:	7e 06                	jle    8005df <vprintfmt+0x1d1>
  8005d9:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005dd:	75 19                	jne    8005f8 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005df:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005e2:	8d 70 01             	lea    0x1(%eax),%esi
  8005e5:	0f b6 00             	movzbl (%eax),%eax
  8005e8:	0f be d0             	movsbl %al,%edx
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	0f 85 9f 00 00 00    	jne    800692 <vprintfmt+0x284>
  8005f3:	e9 8c 00 00 00       	jmp    800684 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8005fe:	ff 75 cc             	pushl  -0x34(%ebp)
  800601:	e8 62 03 00 00       	call   800968 <strnlen>
  800606:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800609:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	85 c9                	test   %ecx,%ecx
  800611:	0f 8e a6 02 00 00    	jle    8008bd <vprintfmt+0x4af>
					putch(padc, putdat);
  800617:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80061b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80061e:	89 cb                	mov    %ecx,%ebx
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	ff 75 0c             	pushl  0xc(%ebp)
  800626:	56                   	push   %esi
  800627:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	83 eb 01             	sub    $0x1,%ebx
  80062f:	75 ef                	jne    800620 <vprintfmt+0x212>
  800631:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800634:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800637:	e9 81 02 00 00       	jmp    8008bd <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800640:	74 1b                	je     80065d <vprintfmt+0x24f>
  800642:	0f be c0             	movsbl %al,%eax
  800645:	83 e8 20             	sub    $0x20,%eax
  800648:	83 f8 5e             	cmp    $0x5e,%eax
  80064b:	76 10                	jbe    80065d <vprintfmt+0x24f>
					putch('?', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	ff 75 0c             	pushl  0xc(%ebp)
  800653:	6a 3f                	push   $0x3f
  800655:	ff 55 08             	call   *0x8(%ebp)
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	eb 0d                	jmp    80066a <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	ff 75 0c             	pushl  0xc(%ebp)
  800663:	52                   	push   %edx
  800664:	ff 55 08             	call   *0x8(%ebp)
  800667:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066a:	83 ef 01             	sub    $0x1,%edi
  80066d:	83 c6 01             	add    $0x1,%esi
  800670:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800674:	0f be d0             	movsbl %al,%edx
  800677:	85 d2                	test   %edx,%edx
  800679:	75 31                	jne    8006ac <vprintfmt+0x29e>
  80067b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80067e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800684:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800687:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80068b:	7f 33                	jg     8006c0 <vprintfmt+0x2b2>
  80068d:	e9 90 fd ff ff       	jmp    800422 <vprintfmt+0x14>
  800692:	89 7d 08             	mov    %edi,0x8(%ebp)
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80069e:	eb 0c                	jmp    8006ac <vprintfmt+0x29e>
  8006a0:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ac:	85 db                	test   %ebx,%ebx
  8006ae:	78 8c                	js     80063c <vprintfmt+0x22e>
  8006b0:	83 eb 01             	sub    $0x1,%ebx
  8006b3:	79 87                	jns    80063c <vprintfmt+0x22e>
  8006b5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	eb c4                	jmp    800684 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	6a 20                	push   $0x20
  8006c6:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	83 ee 01             	sub    $0x1,%esi
  8006ce:	75 f0                	jne    8006c0 <vprintfmt+0x2b2>
  8006d0:	e9 4d fd ff ff       	jmp    800422 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d5:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8006d9:	7e 16                	jle    8006f1 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8d 50 08             	lea    0x8(%eax),%edx
  8006e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e4:	8b 50 04             	mov    0x4(%eax),%edx
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006ef:	eb 34                	jmp    800725 <vprintfmt+0x317>
	else if (lflag)
  8006f1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006f5:	74 18                	je     80070f <vprintfmt+0x301>
		return va_arg(*ap, long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 30                	mov    (%eax),%esi
  800702:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800705:	89 f0                	mov    %esi,%eax
  800707:	c1 f8 1f             	sar    $0x1f,%eax
  80070a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80070d:	eb 16                	jmp    800725 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 30                	mov    (%eax),%esi
  80071a:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80071d:	89 f0                	mov    %esi,%eax
  80071f:	c1 f8 1f             	sar    $0x1f,%eax
  800722:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800728:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800731:	85 d2                	test   %edx,%edx
  800733:	79 28                	jns    80075d <vprintfmt+0x34f>
				putch('-', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	53                   	push   %ebx
  800739:	6a 2d                	push   $0x2d
  80073b:	ff d7                	call   *%edi
				num = -(long long) num;
  80073d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800740:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800743:	f7 d8                	neg    %eax
  800745:	83 d2 00             	adc    $0x0,%edx
  800748:	f7 da                	neg    %edx
  80074a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800750:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800753:	b8 0a 00 00 00       	mov    $0xa,%eax
  800758:	e9 b2 00 00 00       	jmp    80080f <vprintfmt+0x401>
  80075d:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800762:	85 c9                	test   %ecx,%ecx
  800764:	0f 84 a5 00 00 00    	je     80080f <vprintfmt+0x401>
				putch('+', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 2b                	push   $0x2b
  800770:	ff d7                	call   *%edi
  800772:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800775:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077a:	e9 90 00 00 00       	jmp    80080f <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	74 0b                	je     80078e <vprintfmt+0x380>
				putch('+', putdat);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	6a 2b                	push   $0x2b
  800789:	ff d7                	call   *%edi
  80078b:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  80078e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	e8 01 fc ff ff       	call   80039a <getuint>
  800799:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80079f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007a4:	eb 69                	jmp    80080f <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	53                   	push   %ebx
  8007aa:	6a 30                	push   $0x30
  8007ac:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007ae:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b4:	e8 e1 fb ff ff       	call   80039a <getuint>
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8007bf:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007c2:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007c7:	eb 46                	jmp    80080f <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	53                   	push   %ebx
  8007cd:	6a 30                	push   $0x30
  8007cf:	ff d7                	call   *%edi
			putch('x', putdat);
  8007d1:	83 c4 08             	add    $0x8,%esp
  8007d4:	53                   	push   %ebx
  8007d5:	6a 78                	push   $0x78
  8007d7:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e2:	8b 00                	mov    (%eax),%eax
  8007e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ef:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007f2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f7:	eb 16                	jmp    80080f <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ff:	e8 96 fb ff ff       	call   80039a <getuint>
  800804:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800807:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80080a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080f:	83 ec 0c             	sub    $0xc,%esp
  800812:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800816:	56                   	push   %esi
  800817:	ff 75 e4             	pushl  -0x1c(%ebp)
  80081a:	50                   	push   %eax
  80081b:	ff 75 dc             	pushl  -0x24(%ebp)
  80081e:	ff 75 d8             	pushl  -0x28(%ebp)
  800821:	89 da                	mov    %ebx,%edx
  800823:	89 f8                	mov    %edi,%eax
  800825:	e8 55 f9 ff ff       	call   80017f <printnum>
			break;
  80082a:	83 c4 20             	add    $0x20,%esp
  80082d:	e9 f0 fb ff ff       	jmp    800422 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8d 50 04             	lea    0x4(%eax),%edx
  800838:	89 55 14             	mov    %edx,0x14(%ebp)
  80083b:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  80083d:	85 f6                	test   %esi,%esi
  80083f:	75 1a                	jne    80085b <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	68 40 15 80 00       	push   $0x801540
  800849:	68 a7 14 80 00       	push   $0x8014a7
  80084e:	e8 18 f9 ff ff       	call   80016b <cprintf>
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	e9 c7 fb ff ff       	jmp    800422 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  80085b:	0f b6 03             	movzbl (%ebx),%eax
  80085e:	84 c0                	test   %al,%al
  800860:	79 1f                	jns    800881 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	68 78 15 80 00       	push   $0x801578
  80086a:	68 a7 14 80 00       	push   $0x8014a7
  80086f:	e8 f7 f8 ff ff       	call   80016b <cprintf>
						*tmp = *(char *)putdat;
  800874:	0f b6 03             	movzbl (%ebx),%eax
  800877:	88 06                	mov    %al,(%esi)
  800879:	83 c4 10             	add    $0x10,%esp
  80087c:	e9 a1 fb ff ff       	jmp    800422 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800881:	88 06                	mov    %al,(%esi)
  800883:	e9 9a fb ff ff       	jmp    800422 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800888:	83 ec 08             	sub    $0x8,%esp
  80088b:	53                   	push   %ebx
  80088c:	52                   	push   %edx
  80088d:	ff d7                	call   *%edi
			break;
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	e9 8b fb ff ff       	jmp    800422 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	6a 25                	push   $0x25
  80089d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008a6:	0f 84 73 fb ff ff    	je     80041f <vprintfmt+0x11>
  8008ac:	83 ee 01             	sub    $0x1,%esi
  8008af:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008b3:	75 f7                	jne    8008ac <vprintfmt+0x49e>
  8008b5:	89 75 10             	mov    %esi,0x10(%ebp)
  8008b8:	e9 65 fb ff ff       	jmp    800422 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008c0:	8d 70 01             	lea    0x1(%eax),%esi
  8008c3:	0f b6 00             	movzbl (%eax),%eax
  8008c6:	0f be d0             	movsbl %al,%edx
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	0f 85 cf fd ff ff    	jne    8006a0 <vprintfmt+0x292>
  8008d1:	e9 4c fb ff ff       	jmp    800422 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5f                   	pop    %edi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 18             	sub    $0x18,%esp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	74 26                	je     800925 <vsnprintf+0x47>
  8008ff:	85 d2                	test   %edx,%edx
  800901:	7e 22                	jle    800925 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800903:	ff 75 14             	pushl  0x14(%ebp)
  800906:	ff 75 10             	pushl  0x10(%ebp)
  800909:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090c:	50                   	push   %eax
  80090d:	68 d4 03 80 00       	push   $0x8003d4
  800912:	e8 f7 fa ff ff       	call   80040e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800917:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800920:	83 c4 10             	add    $0x10,%esp
  800923:	eb 05                	jmp    80092a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800925:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800932:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800935:	50                   	push   %eax
  800936:	ff 75 10             	pushl  0x10(%ebp)
  800939:	ff 75 0c             	pushl  0xc(%ebp)
  80093c:	ff 75 08             	pushl  0x8(%ebp)
  80093f:	e8 9a ff ff ff       	call   8008de <vsnprintf>
	va_end(ap);

	return rc;
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094c:	80 3a 00             	cmpb   $0x0,(%edx)
  80094f:	74 10                	je     800961 <strlen+0x1b>
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800956:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800959:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095d:	75 f7                	jne    800956 <strlen+0x10>
  80095f:	eb 05                	jmp    800966 <strlen+0x20>
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80096f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800972:	85 c9                	test   %ecx,%ecx
  800974:	74 1c                	je     800992 <strnlen+0x2a>
  800976:	80 3b 00             	cmpb   $0x0,(%ebx)
  800979:	74 1e                	je     800999 <strnlen+0x31>
  80097b:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800980:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800982:	39 ca                	cmp    %ecx,%edx
  800984:	74 18                	je     80099e <strnlen+0x36>
  800986:	83 c2 01             	add    $0x1,%edx
  800989:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80098e:	75 f0                	jne    800980 <strnlen+0x18>
  800990:	eb 0c                	jmp    80099e <strnlen+0x36>
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
  800997:	eb 05                	jmp    80099e <strnlen+0x36>
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ab:	89 c2                	mov    %eax,%edx
  8009ad:	83 c2 01             	add    $0x1,%edx
  8009b0:	83 c1 01             	add    $0x1,%ecx
  8009b3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ba:	84 db                	test   %bl,%bl
  8009bc:	75 ef                	jne    8009ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	53                   	push   %ebx
  8009c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c8:	53                   	push   %ebx
  8009c9:	e8 78 ff ff ff       	call   800946 <strlen>
  8009ce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d1:	ff 75 0c             	pushl  0xc(%ebp)
  8009d4:	01 d8                	add    %ebx,%eax
  8009d6:	50                   	push   %eax
  8009d7:	e8 c5 ff ff ff       	call   8009a1 <strcpy>
	return dst;
}
  8009dc:	89 d8                	mov    %ebx,%eax
  8009de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f1:	85 db                	test   %ebx,%ebx
  8009f3:	74 17                	je     800a0c <strncpy+0x29>
  8009f5:	01 f3                	add    %esi,%ebx
  8009f7:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	0f b6 02             	movzbl (%edx),%eax
  8009ff:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a02:	80 3a 01             	cmpb   $0x1,(%edx)
  800a05:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a08:	39 cb                	cmp    %ecx,%ebx
  800a0a:	75 ed                	jne    8009f9 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a0c:	89 f0                	mov    %esi,%eax
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a1d:	8b 55 10             	mov    0x10(%ebp),%edx
  800a20:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a22:	85 d2                	test   %edx,%edx
  800a24:	74 35                	je     800a5b <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a26:	89 d0                	mov    %edx,%eax
  800a28:	83 e8 01             	sub    $0x1,%eax
  800a2b:	74 25                	je     800a52 <strlcpy+0x40>
  800a2d:	0f b6 0b             	movzbl (%ebx),%ecx
  800a30:	84 c9                	test   %cl,%cl
  800a32:	74 22                	je     800a56 <strlcpy+0x44>
  800a34:	8d 53 01             	lea    0x1(%ebx),%edx
  800a37:	01 c3                	add    %eax,%ebx
  800a39:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a41:	39 da                	cmp    %ebx,%edx
  800a43:	74 13                	je     800a58 <strlcpy+0x46>
  800a45:	83 c2 01             	add    $0x1,%edx
  800a48:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a4c:	84 c9                	test   %cl,%cl
  800a4e:	75 eb                	jne    800a3b <strlcpy+0x29>
  800a50:	eb 06                	jmp    800a58 <strlcpy+0x46>
  800a52:	89 f0                	mov    %esi,%eax
  800a54:	eb 02                	jmp    800a58 <strlcpy+0x46>
  800a56:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a58:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5b:	29 f0                	sub    %esi,%eax
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a67:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6a:	0f b6 01             	movzbl (%ecx),%eax
  800a6d:	84 c0                	test   %al,%al
  800a6f:	74 15                	je     800a86 <strcmp+0x25>
  800a71:	3a 02                	cmp    (%edx),%al
  800a73:	75 11                	jne    800a86 <strcmp+0x25>
		p++, q++;
  800a75:	83 c1 01             	add    $0x1,%ecx
  800a78:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a7b:	0f b6 01             	movzbl (%ecx),%eax
  800a7e:	84 c0                	test   %al,%al
  800a80:	74 04                	je     800a86 <strcmp+0x25>
  800a82:	3a 02                	cmp    (%edx),%al
  800a84:	74 ef                	je     800a75 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a86:	0f b6 c0             	movzbl %al,%eax
  800a89:	0f b6 12             	movzbl (%edx),%edx
  800a8c:	29 d0                	sub    %edx,%eax
}
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a9e:	85 f6                	test   %esi,%esi
  800aa0:	74 29                	je     800acb <strncmp+0x3b>
  800aa2:	0f b6 03             	movzbl (%ebx),%eax
  800aa5:	84 c0                	test   %al,%al
  800aa7:	74 30                	je     800ad9 <strncmp+0x49>
  800aa9:	3a 02                	cmp    (%edx),%al
  800aab:	75 2c                	jne    800ad9 <strncmp+0x49>
  800aad:	8d 43 01             	lea    0x1(%ebx),%eax
  800ab0:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800ab2:	89 c3                	mov    %eax,%ebx
  800ab4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab7:	39 c6                	cmp    %eax,%esi
  800ab9:	74 17                	je     800ad2 <strncmp+0x42>
  800abb:	0f b6 08             	movzbl (%eax),%ecx
  800abe:	84 c9                	test   %cl,%cl
  800ac0:	74 17                	je     800ad9 <strncmp+0x49>
  800ac2:	83 c0 01             	add    $0x1,%eax
  800ac5:	3a 0a                	cmp    (%edx),%cl
  800ac7:	74 e9                	je     800ab2 <strncmp+0x22>
  800ac9:	eb 0e                	jmp    800ad9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad0:	eb 0f                	jmp    800ae1 <strncmp+0x51>
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	eb 08                	jmp    800ae1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad9:	0f b6 03             	movzbl (%ebx),%eax
  800adc:	0f b6 12             	movzbl (%edx),%edx
  800adf:	29 d0                	sub    %edx,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	53                   	push   %ebx
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800aef:	0f b6 10             	movzbl (%eax),%edx
  800af2:	84 d2                	test   %dl,%dl
  800af4:	74 1d                	je     800b13 <strchr+0x2e>
  800af6:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800af8:	38 d3                	cmp    %dl,%bl
  800afa:	75 06                	jne    800b02 <strchr+0x1d>
  800afc:	eb 1a                	jmp    800b18 <strchr+0x33>
  800afe:	38 ca                	cmp    %cl,%dl
  800b00:	74 16                	je     800b18 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	0f b6 10             	movzbl (%eax),%edx
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	75 f2                	jne    800afe <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	eb 05                	jmp    800b18 <strchr+0x33>
  800b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b18:	5b                   	pop    %ebx
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	53                   	push   %ebx
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b25:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b28:	38 d3                	cmp    %dl,%bl
  800b2a:	74 14                	je     800b40 <strfind+0x25>
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	84 db                	test   %bl,%bl
  800b30:	74 0e                	je     800b40 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b32:	83 c0 01             	add    $0x1,%eax
  800b35:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b38:	38 ca                	cmp    %cl,%dl
  800b3a:	74 04                	je     800b40 <strfind+0x25>
  800b3c:	84 d2                	test   %dl,%dl
  800b3e:	75 f2                	jne    800b32 <strfind+0x17>
			break;
	return (char *) s;
}
  800b40:	5b                   	pop    %ebx
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b4f:	85 c9                	test   %ecx,%ecx
  800b51:	74 36                	je     800b89 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b53:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b59:	75 28                	jne    800b83 <memset+0x40>
  800b5b:	f6 c1 03             	test   $0x3,%cl
  800b5e:	75 23                	jne    800b83 <memset+0x40>
		c &= 0xFF;
  800b60:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	c1 e3 08             	shl    $0x8,%ebx
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	c1 e6 18             	shl    $0x18,%esi
  800b6e:	89 d0                	mov    %edx,%eax
  800b70:	c1 e0 10             	shl    $0x10,%eax
  800b73:	09 f0                	or     %esi,%eax
  800b75:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b77:	89 d8                	mov    %ebx,%eax
  800b79:	09 d0                	or     %edx,%eax
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
  800b7e:	fc                   	cld    
  800b7f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b81:	eb 06                	jmp    800b89 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	fc                   	cld    
  800b87:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b89:	89 f8                	mov    %edi,%eax
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b9e:	39 c6                	cmp    %eax,%esi
  800ba0:	73 35                	jae    800bd7 <memmove+0x47>
  800ba2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba5:	39 d0                	cmp    %edx,%eax
  800ba7:	73 2e                	jae    800bd7 <memmove+0x47>
		s += n;
		d += n;
  800ba9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bac:	89 d6                	mov    %edx,%esi
  800bae:	09 fe                	or     %edi,%esi
  800bb0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb6:	75 13                	jne    800bcb <memmove+0x3b>
  800bb8:	f6 c1 03             	test   $0x3,%cl
  800bbb:	75 0e                	jne    800bcb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bbd:	83 ef 04             	sub    $0x4,%edi
  800bc0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc3:	c1 e9 02             	shr    $0x2,%ecx
  800bc6:	fd                   	std    
  800bc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc9:	eb 09                	jmp    800bd4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bcb:	83 ef 01             	sub    $0x1,%edi
  800bce:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bd1:	fd                   	std    
  800bd2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd4:	fc                   	cld    
  800bd5:	eb 1d                	jmp    800bf4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd7:	89 f2                	mov    %esi,%edx
  800bd9:	09 c2                	or     %eax,%edx
  800bdb:	f6 c2 03             	test   $0x3,%dl
  800bde:	75 0f                	jne    800bef <memmove+0x5f>
  800be0:	f6 c1 03             	test   $0x3,%cl
  800be3:	75 0a                	jne    800bef <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800be5:	c1 e9 02             	shr    $0x2,%ecx
  800be8:	89 c7                	mov    %eax,%edi
  800bea:	fc                   	cld    
  800beb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bed:	eb 05                	jmp    800bf4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	fc                   	cld    
  800bf2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bfb:	ff 75 10             	pushl  0x10(%ebp)
  800bfe:	ff 75 0c             	pushl  0xc(%ebp)
  800c01:	ff 75 08             	pushl  0x8(%ebp)
  800c04:	e8 87 ff ff ff       	call   800b90 <memmove>
}
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c17:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	74 39                	je     800c57 <memcmp+0x4c>
  800c1e:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c21:	0f b6 13             	movzbl (%ebx),%edx
  800c24:	0f b6 0e             	movzbl (%esi),%ecx
  800c27:	38 ca                	cmp    %cl,%dl
  800c29:	75 17                	jne    800c42 <memcmp+0x37>
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c30:	eb 1a                	jmp    800c4c <memcmp+0x41>
  800c32:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c37:	83 c0 01             	add    $0x1,%eax
  800c3a:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c3e:	38 ca                	cmp    %cl,%dl
  800c40:	74 0a                	je     800c4c <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c42:	0f b6 c2             	movzbl %dl,%eax
  800c45:	0f b6 c9             	movzbl %cl,%ecx
  800c48:	29 c8                	sub    %ecx,%eax
  800c4a:	eb 10                	jmp    800c5c <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4c:	39 f8                	cmp    %edi,%eax
  800c4e:	75 e2                	jne    800c32 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c50:	b8 00 00 00 00       	mov    $0x0,%eax
  800c55:	eb 05                	jmp    800c5c <memcmp+0x51>
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	53                   	push   %ebx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c68:	89 d0                	mov    %edx,%eax
  800c6a:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c6d:	39 c2                	cmp    %eax,%edx
  800c6f:	73 1d                	jae    800c8e <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c71:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c75:	0f b6 0a             	movzbl (%edx),%ecx
  800c78:	39 d9                	cmp    %ebx,%ecx
  800c7a:	75 09                	jne    800c85 <memfind+0x24>
  800c7c:	eb 14                	jmp    800c92 <memfind+0x31>
  800c7e:	0f b6 0a             	movzbl (%edx),%ecx
  800c81:	39 d9                	cmp    %ebx,%ecx
  800c83:	74 11                	je     800c96 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c85:	83 c2 01             	add    $0x1,%edx
  800c88:	39 d0                	cmp    %edx,%eax
  800c8a:	75 f2                	jne    800c7e <memfind+0x1d>
  800c8c:	eb 0a                	jmp    800c98 <memfind+0x37>
  800c8e:	89 d0                	mov    %edx,%eax
  800c90:	eb 06                	jmp    800c98 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c92:	89 d0                	mov    %edx,%eax
  800c94:	eb 02                	jmp    800c98 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c96:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c98:	5b                   	pop    %ebx
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca7:	0f b6 01             	movzbl (%ecx),%eax
  800caa:	3c 20                	cmp    $0x20,%al
  800cac:	74 04                	je     800cb2 <strtol+0x17>
  800cae:	3c 09                	cmp    $0x9,%al
  800cb0:	75 0e                	jne    800cc0 <strtol+0x25>
		s++;
  800cb2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb5:	0f b6 01             	movzbl (%ecx),%eax
  800cb8:	3c 20                	cmp    $0x20,%al
  800cba:	74 f6                	je     800cb2 <strtol+0x17>
  800cbc:	3c 09                	cmp    $0x9,%al
  800cbe:	74 f2                	je     800cb2 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc0:	3c 2b                	cmp    $0x2b,%al
  800cc2:	75 0a                	jne    800cce <strtol+0x33>
		s++;
  800cc4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc7:	bf 00 00 00 00       	mov    $0x0,%edi
  800ccc:	eb 11                	jmp    800cdf <strtol+0x44>
  800cce:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cd3:	3c 2d                	cmp    $0x2d,%al
  800cd5:	75 08                	jne    800cdf <strtol+0x44>
		s++, neg = 1;
  800cd7:	83 c1 01             	add    $0x1,%ecx
  800cda:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cdf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ce5:	75 15                	jne    800cfc <strtol+0x61>
  800ce7:	80 39 30             	cmpb   $0x30,(%ecx)
  800cea:	75 10                	jne    800cfc <strtol+0x61>
  800cec:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf0:	75 7c                	jne    800d6e <strtol+0xd3>
		s += 2, base = 16;
  800cf2:	83 c1 02             	add    $0x2,%ecx
  800cf5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cfa:	eb 16                	jmp    800d12 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cfc:	85 db                	test   %ebx,%ebx
  800cfe:	75 12                	jne    800d12 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d00:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d05:	80 39 30             	cmpb   $0x30,(%ecx)
  800d08:	75 08                	jne    800d12 <strtol+0x77>
		s++, base = 8;
  800d0a:	83 c1 01             	add    $0x1,%ecx
  800d0d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
  800d17:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d1a:	0f b6 11             	movzbl (%ecx),%edx
  800d1d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d20:	89 f3                	mov    %esi,%ebx
  800d22:	80 fb 09             	cmp    $0x9,%bl
  800d25:	77 08                	ja     800d2f <strtol+0x94>
			dig = *s - '0';
  800d27:	0f be d2             	movsbl %dl,%edx
  800d2a:	83 ea 30             	sub    $0x30,%edx
  800d2d:	eb 22                	jmp    800d51 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d2f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d32:	89 f3                	mov    %esi,%ebx
  800d34:	80 fb 19             	cmp    $0x19,%bl
  800d37:	77 08                	ja     800d41 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d39:	0f be d2             	movsbl %dl,%edx
  800d3c:	83 ea 57             	sub    $0x57,%edx
  800d3f:	eb 10                	jmp    800d51 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d41:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d44:	89 f3                	mov    %esi,%ebx
  800d46:	80 fb 19             	cmp    $0x19,%bl
  800d49:	77 16                	ja     800d61 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d4b:	0f be d2             	movsbl %dl,%edx
  800d4e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d51:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d54:	7d 0b                	jge    800d61 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d56:	83 c1 01             	add    $0x1,%ecx
  800d59:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d5d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d5f:	eb b9                	jmp    800d1a <strtol+0x7f>

	if (endptr)
  800d61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d65:	74 0d                	je     800d74 <strtol+0xd9>
		*endptr = (char *) s;
  800d67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d6a:	89 0e                	mov    %ecx,(%esi)
  800d6c:	eb 06                	jmp    800d74 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d6e:	85 db                	test   %ebx,%ebx
  800d70:	74 98                	je     800d0a <strtol+0x6f>
  800d72:	eb 9e                	jmp    800d12 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d74:	89 c2                	mov    %eax,%edx
  800d76:	f7 da                	neg    %edx
  800d78:	85 ff                	test   %edi,%edi
  800d7a:	0f 45 c2             	cmovne %edx,%eax
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d87:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	89 c7                	mov    %eax,%edi
  800d96:	51                   	push   %ecx
  800d97:	52                   	push   %edx
  800d98:	53                   	push   %ebx
  800d99:	56                   	push   %esi
  800d9a:	57                   	push   %edi
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	8d 35 a6 0d 80 00    	lea    0x800da6,%esi
  800da4:	0f 34                	sysenter 

00800da6 <label_21>:
  800da6:	89 ec                	mov    %ebp,%esp
  800da8:	5d                   	pop    %ebp
  800da9:	5f                   	pop    %edi
  800daa:	5e                   	pop    %esi
  800dab:	5b                   	pop    %ebx
  800dac:	5a                   	pop    %edx
  800dad:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800db7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbc:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc1:	89 ca                	mov    %ecx,%edx
  800dc3:	89 cb                	mov    %ecx,%ebx
  800dc5:	89 cf                	mov    %ecx,%edi
  800dc7:	51                   	push   %ecx
  800dc8:	52                   	push   %edx
  800dc9:	53                   	push   %ebx
  800dca:	56                   	push   %esi
  800dcb:	57                   	push   %edi
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	8d 35 d7 0d 80 00    	lea    0x800dd7,%esi
  800dd5:	0f 34                	sysenter 

00800dd7 <label_55>:
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	5f                   	pop    %edi
  800ddb:	5e                   	pop    %esi
  800ddc:	5b                   	pop    %ebx
  800ddd:	5a                   	pop    %edx
  800dde:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ddf:	5b                   	pop    %ebx
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800de8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ded:	b8 03 00 00 00       	mov    $0x3,%eax
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	89 d9                	mov    %ebx,%ecx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	51                   	push   %ecx
  800dfa:	52                   	push   %edx
  800dfb:	53                   	push   %ebx
  800dfc:	56                   	push   %esi
  800dfd:	57                   	push   %edi
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	8d 35 09 0e 80 00    	lea    0x800e09,%esi
  800e07:	0f 34                	sysenter 

00800e09 <label_90>:
  800e09:	89 ec                	mov    %ebp,%esp
  800e0b:	5d                   	pop    %ebp
  800e0c:	5f                   	pop    %edi
  800e0d:	5e                   	pop    %esi
  800e0e:	5b                   	pop    %ebx
  800e0f:	5a                   	pop    %edx
  800e10:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7e 17                	jle    800e2c <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	6a 03                	push   $0x3
  800e1b:	68 44 17 80 00       	push   $0x801744
  800e20:	6a 29                	push   $0x29
  800e22:	68 61 17 80 00       	push   $0x801761
  800e27:	e8 33 03 00 00       	call   80115f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e42:	89 ca                	mov    %ecx,%edx
  800e44:	89 cb                	mov    %ecx,%ebx
  800e46:	89 cf                	mov    %ecx,%edi
  800e48:	51                   	push   %ecx
  800e49:	52                   	push   %edx
  800e4a:	53                   	push   %ebx
  800e4b:	56                   	push   %esi
  800e4c:	57                   	push   %edi
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	8d 35 58 0e 80 00    	lea    0x800e58,%esi
  800e56:	0f 34                	sysenter 

00800e58 <label_139>:
  800e58:	89 ec                	mov    %ebp,%esp
  800e5a:	5d                   	pop    %ebp
  800e5b:	5f                   	pop    %edi
  800e5c:	5e                   	pop    %esi
  800e5d:	5b                   	pop    %ebx
  800e5e:	5a                   	pop    %edx
  800e5f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e60:	5b                   	pop    %ebx
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e69:	bf 00 00 00 00       	mov    $0x0,%edi
  800e6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	89 fb                	mov    %edi,%ebx
  800e7b:	51                   	push   %ecx
  800e7c:	52                   	push   %edx
  800e7d:	53                   	push   %ebx
  800e7e:	56                   	push   %esi
  800e7f:	57                   	push   %edi
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	8d 35 8b 0e 80 00    	lea    0x800e8b,%esi
  800e89:	0f 34                	sysenter 

00800e8b <label_174>:
  800e8b:	89 ec                	mov    %ebp,%esp
  800e8d:	5d                   	pop    %ebp
  800e8e:	5f                   	pop    %edi
  800e8f:	5e                   	pop    %esi
  800e90:	5b                   	pop    %ebx
  800e91:	5a                   	pop    %edx
  800e92:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e93:	5b                   	pop    %ebx
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <sys_yield>:

void
sys_yield(void)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea6:	89 d1                	mov    %edx,%ecx
  800ea8:	89 d3                	mov    %edx,%ebx
  800eaa:	89 d7                	mov    %edx,%edi
  800eac:	51                   	push   %ecx
  800ead:	52                   	push   %edx
  800eae:	53                   	push   %ebx
  800eaf:	56                   	push   %esi
  800eb0:	57                   	push   %edi
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	8d 35 bc 0e 80 00    	lea    0x800ebc,%esi
  800eba:	0f 34                	sysenter 

00800ebc <label_209>:
  800ebc:	89 ec                	mov    %ebp,%esp
  800ebe:	5d                   	pop    %ebp
  800ebf:	5f                   	pop    %edi
  800ec0:	5e                   	pop    %esi
  800ec1:	5b                   	pop    %ebx
  800ec2:	5a                   	pop    %edx
  800ec3:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ec4:	5b                   	pop    %ebx
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800ecd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ed2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee0:	51                   	push   %ecx
  800ee1:	52                   	push   %edx
  800ee2:	53                   	push   %ebx
  800ee3:	56                   	push   %esi
  800ee4:	57                   	push   %edi
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	8d 35 f0 0e 80 00    	lea    0x800ef0,%esi
  800eee:	0f 34                	sysenter 

00800ef0 <label_244>:
  800ef0:	89 ec                	mov    %ebp,%esp
  800ef2:	5d                   	pop    %ebp
  800ef3:	5f                   	pop    %edi
  800ef4:	5e                   	pop    %esi
  800ef5:	5b                   	pop    %ebx
  800ef6:	5a                   	pop    %edx
  800ef7:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	7e 17                	jle    800f13 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	50                   	push   %eax
  800f00:	6a 05                	push   $0x5
  800f02:	68 44 17 80 00       	push   $0x801744
  800f07:	6a 29                	push   $0x29
  800f09:	68 61 17 80 00       	push   $0x801761
  800f0e:	e8 4c 02 00 00       	call   80115f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800f28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800f2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f31:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800f34:	8b 45 14             	mov    0x14(%ebp),%eax
  800f37:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800f3a:	8b 45 18             	mov    0x18(%ebp),%eax
  800f3d:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f40:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f48:	b8 06 00 00 00       	mov    $0x6,%eax
  800f4d:	89 cb                	mov    %ecx,%ebx
  800f4f:	89 cf                	mov    %ecx,%edi
  800f51:	51                   	push   %ecx
  800f52:	52                   	push   %edx
  800f53:	53                   	push   %ebx
  800f54:	56                   	push   %esi
  800f55:	57                   	push   %edi
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	8d 35 61 0f 80 00    	lea    0x800f61,%esi
  800f5f:	0f 34                	sysenter 

00800f61 <label_304>:
  800f61:	89 ec                	mov    %ebp,%esp
  800f63:	5d                   	pop    %ebp
  800f64:	5f                   	pop    %edi
  800f65:	5e                   	pop    %esi
  800f66:	5b                   	pop    %ebx
  800f67:	5a                   	pop    %edx
  800f68:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 17                	jle    800f84 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	50                   	push   %eax
  800f71:	6a 06                	push   $0x6
  800f73:	68 44 17 80 00       	push   $0x801744
  800f78:	6a 29                	push   $0x29
  800f7a:	68 61 17 80 00       	push   $0x801761
  800f7f:	e8 db 01 00 00       	call   80115f <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  800f84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	57                   	push   %edi
  800f8f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f90:	bf 00 00 00 00       	mov    $0x0,%edi
  800f95:	b8 07 00 00 00       	mov    $0x7,%eax
  800f9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa0:	89 fb                	mov    %edi,%ebx
  800fa2:	51                   	push   %ecx
  800fa3:	52                   	push   %edx
  800fa4:	53                   	push   %ebx
  800fa5:	56                   	push   %esi
  800fa6:	57                   	push   %edi
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	8d 35 b2 0f 80 00    	lea    0x800fb2,%esi
  800fb0:	0f 34                	sysenter 

00800fb2 <label_353>:
  800fb2:	89 ec                	mov    %ebp,%esp
  800fb4:	5d                   	pop    %ebp
  800fb5:	5f                   	pop    %edi
  800fb6:	5e                   	pop    %esi
  800fb7:	5b                   	pop    %ebx
  800fb8:	5a                   	pop    %edx
  800fb9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	7e 17                	jle    800fd5 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbe:	83 ec 0c             	sub    $0xc,%esp
  800fc1:	50                   	push   %eax
  800fc2:	6a 07                	push   $0x7
  800fc4:	68 44 17 80 00       	push   $0x801744
  800fc9:	6a 29                	push   $0x29
  800fcb:	68 61 17 80 00       	push   $0x801761
  800fd0:	e8 8a 01 00 00       	call   80115f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5f                   	pop    %edi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	57                   	push   %edi
  800fe0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe1:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe6:	b8 09 00 00 00       	mov    $0x9,%eax
  800feb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	89 fb                	mov    %edi,%ebx
  800ff3:	51                   	push   %ecx
  800ff4:	52                   	push   %edx
  800ff5:	53                   	push   %ebx
  800ff6:	56                   	push   %esi
  800ff7:	57                   	push   %edi
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	8d 35 03 10 80 00    	lea    0x801003,%esi
  801001:	0f 34                	sysenter 

00801003 <label_402>:
  801003:	89 ec                	mov    %ebp,%esp
  801005:	5d                   	pop    %ebp
  801006:	5f                   	pop    %edi
  801007:	5e                   	pop    %esi
  801008:	5b                   	pop    %ebx
  801009:	5a                   	pop    %edx
  80100a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	7e 17                	jle    801026 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	50                   	push   %eax
  801013:	6a 09                	push   $0x9
  801015:	68 44 17 80 00       	push   $0x801744
  80101a:	6a 29                	push   $0x29
  80101c:	68 61 17 80 00       	push   $0x801761
  801021:	e8 39 01 00 00       	call   80115f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801026:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801029:	5b                   	pop    %ebx
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801032:	bf 00 00 00 00       	mov    $0x0,%edi
  801037:	b8 0a 00 00 00       	mov    $0xa,%eax
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	89 fb                	mov    %edi,%ebx
  801044:	51                   	push   %ecx
  801045:	52                   	push   %edx
  801046:	53                   	push   %ebx
  801047:	56                   	push   %esi
  801048:	57                   	push   %edi
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	8d 35 54 10 80 00    	lea    0x801054,%esi
  801052:	0f 34                	sysenter 

00801054 <label_451>:
  801054:	89 ec                	mov    %ebp,%esp
  801056:	5d                   	pop    %ebp
  801057:	5f                   	pop    %edi
  801058:	5e                   	pop    %esi
  801059:	5b                   	pop    %ebx
  80105a:	5a                   	pop    %edx
  80105b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80105c:	85 c0                	test   %eax,%eax
  80105e:	7e 17                	jle    801077 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	50                   	push   %eax
  801064:	6a 0a                	push   $0xa
  801066:	68 44 17 80 00       	push   $0x801744
  80106b:	6a 29                	push   $0x29
  80106d:	68 61 17 80 00       	push   $0x801761
  801072:	e8 e8 00 00 00       	call   80115f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801077:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107a:	5b                   	pop    %ebx
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  801083:	b8 0c 00 00 00       	mov    $0xc,%eax
  801088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801091:	8b 7d 14             	mov    0x14(%ebp),%edi
  801094:	51                   	push   %ecx
  801095:	52                   	push   %edx
  801096:	53                   	push   %ebx
  801097:	56                   	push   %esi
  801098:	57                   	push   %edi
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	8d 35 a4 10 80 00    	lea    0x8010a4,%esi
  8010a2:	0f 34                	sysenter 

008010a4 <label_502>:
  8010a4:	89 ec                	mov    %ebp,%esp
  8010a6:	5d                   	pop    %ebp
  8010a7:	5f                   	pop    %edi
  8010a8:	5e                   	pop    %esi
  8010a9:	5b                   	pop    %ebx
  8010aa:	5a                   	pop    %edx
  8010ab:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010ac:	5b                   	pop    %ebx
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ba:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c2:	89 d9                	mov    %ebx,%ecx
  8010c4:	89 df                	mov    %ebx,%edi
  8010c6:	51                   	push   %ecx
  8010c7:	52                   	push   %edx
  8010c8:	53                   	push   %ebx
  8010c9:	56                   	push   %esi
  8010ca:	57                   	push   %edi
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	8d 35 d6 10 80 00    	lea    0x8010d6,%esi
  8010d4:	0f 34                	sysenter 

008010d6 <label_537>:
  8010d6:	89 ec                	mov    %ebp,%esp
  8010d8:	5d                   	pop    %ebp
  8010d9:	5f                   	pop    %edi
  8010da:	5e                   	pop    %esi
  8010db:	5b                   	pop    %ebx
  8010dc:	5a                   	pop    %edx
  8010dd:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	7e 17                	jle    8010f9 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	50                   	push   %eax
  8010e6:	6a 0d                	push   $0xd
  8010e8:	68 44 17 80 00       	push   $0x801744
  8010ed:	6a 29                	push   $0x29
  8010ef:	68 61 17 80 00       	push   $0x801761
  8010f4:	e8 66 00 00 00       	call   80115f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801105:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80110f:	8b 55 08             	mov    0x8(%ebp),%edx
  801112:	89 cb                	mov    %ecx,%ebx
  801114:	89 cf                	mov    %ecx,%edi
  801116:	51                   	push   %ecx
  801117:	52                   	push   %edx
  801118:	53                   	push   %ebx
  801119:	56                   	push   %esi
  80111a:	57                   	push   %edi
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	8d 35 26 11 80 00    	lea    0x801126,%esi
  801124:	0f 34                	sysenter 

00801126 <label_586>:
  801126:	89 ec                	mov    %ebp,%esp
  801128:	5d                   	pop    %ebp
  801129:	5f                   	pop    %edi
  80112a:	5e                   	pop    %esi
  80112b:	5b                   	pop    %ebx
  80112c:	5a                   	pop    %edx
  80112d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80112e:	5b                   	pop    %ebx
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801138:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  80113f:	75 14                	jne    801155 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801141:	83 ec 04             	sub    $0x4,%esp
  801144:	68 70 17 80 00       	push   $0x801770
  801149:	6a 20                	push   $0x20
  80114b:	68 94 17 80 00       	push   $0x801794
  801150:	e8 0a 00 00 00       	call   80115f <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801155:	8b 45 08             	mov    0x8(%ebp),%eax
  801158:	a3 10 20 80 00       	mov    %eax,0x802010
}
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801164:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  801167:	a1 14 20 80 00       	mov    0x802014,%eax
  80116c:	85 c0                	test   %eax,%eax
  80116e:	74 11                	je     801181 <_panic+0x22>
		cprintf("%s: ", argv0);
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	50                   	push   %eax
  801174:	68 a2 17 80 00       	push   $0x8017a2
  801179:	e8 ed ef ff ff       	call   80016b <cprintf>
  80117e:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801181:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801187:	e8 a7 fc ff ff       	call   800e33 <sys_getenvid>
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	ff 75 0c             	pushl  0xc(%ebp)
  801192:	ff 75 08             	pushl  0x8(%ebp)
  801195:	56                   	push   %esi
  801196:	50                   	push   %eax
  801197:	68 a8 17 80 00       	push   $0x8017a8
  80119c:	e8 ca ef ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011a1:	83 c4 18             	add    $0x18,%esp
  8011a4:	53                   	push   %ebx
  8011a5:	ff 75 10             	pushl  0x10(%ebp)
  8011a8:	e8 6d ef ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  8011ad:	c7 04 24 7a 14 80 00 	movl   $0x80147a,(%esp)
  8011b4:	e8 b2 ef ff ff       	call   80016b <cprintf>
  8011b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011bc:	cc                   	int3   
  8011bd:	eb fd                	jmp    8011bc <_panic+0x5d>
  8011bf:	90                   	nop

008011c0 <__udivdi3>:
  8011c0:	55                   	push   %ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 1c             	sub    $0x1c,%esp
  8011c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8011cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011d7:	85 f6                	test   %esi,%esi
  8011d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011dd:	89 ca                	mov    %ecx,%edx
  8011df:	89 f8                	mov    %edi,%eax
  8011e1:	75 3d                	jne    801220 <__udivdi3+0x60>
  8011e3:	39 cf                	cmp    %ecx,%edi
  8011e5:	0f 87 c5 00 00 00    	ja     8012b0 <__udivdi3+0xf0>
  8011eb:	85 ff                	test   %edi,%edi
  8011ed:	89 fd                	mov    %edi,%ebp
  8011ef:	75 0b                	jne    8011fc <__udivdi3+0x3c>
  8011f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f6:	31 d2                	xor    %edx,%edx
  8011f8:	f7 f7                	div    %edi
  8011fa:	89 c5                	mov    %eax,%ebp
  8011fc:	89 c8                	mov    %ecx,%eax
  8011fe:	31 d2                	xor    %edx,%edx
  801200:	f7 f5                	div    %ebp
  801202:	89 c1                	mov    %eax,%ecx
  801204:	89 d8                	mov    %ebx,%eax
  801206:	89 cf                	mov    %ecx,%edi
  801208:	f7 f5                	div    %ebp
  80120a:	89 c3                	mov    %eax,%ebx
  80120c:	89 d8                	mov    %ebx,%eax
  80120e:	89 fa                	mov    %edi,%edx
  801210:	83 c4 1c             	add    $0x1c,%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    
  801218:	90                   	nop
  801219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801220:	39 ce                	cmp    %ecx,%esi
  801222:	77 74                	ja     801298 <__udivdi3+0xd8>
  801224:	0f bd fe             	bsr    %esi,%edi
  801227:	83 f7 1f             	xor    $0x1f,%edi
  80122a:	0f 84 98 00 00 00    	je     8012c8 <__udivdi3+0x108>
  801230:	bb 20 00 00 00       	mov    $0x20,%ebx
  801235:	89 f9                	mov    %edi,%ecx
  801237:	89 c5                	mov    %eax,%ebp
  801239:	29 fb                	sub    %edi,%ebx
  80123b:	d3 e6                	shl    %cl,%esi
  80123d:	89 d9                	mov    %ebx,%ecx
  80123f:	d3 ed                	shr    %cl,%ebp
  801241:	89 f9                	mov    %edi,%ecx
  801243:	d3 e0                	shl    %cl,%eax
  801245:	09 ee                	or     %ebp,%esi
  801247:	89 d9                	mov    %ebx,%ecx
  801249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124d:	89 d5                	mov    %edx,%ebp
  80124f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801253:	d3 ed                	shr    %cl,%ebp
  801255:	89 f9                	mov    %edi,%ecx
  801257:	d3 e2                	shl    %cl,%edx
  801259:	89 d9                	mov    %ebx,%ecx
  80125b:	d3 e8                	shr    %cl,%eax
  80125d:	09 c2                	or     %eax,%edx
  80125f:	89 d0                	mov    %edx,%eax
  801261:	89 ea                	mov    %ebp,%edx
  801263:	f7 f6                	div    %esi
  801265:	89 d5                	mov    %edx,%ebp
  801267:	89 c3                	mov    %eax,%ebx
  801269:	f7 64 24 0c          	mull   0xc(%esp)
  80126d:	39 d5                	cmp    %edx,%ebp
  80126f:	72 10                	jb     801281 <__udivdi3+0xc1>
  801271:	8b 74 24 08          	mov    0x8(%esp),%esi
  801275:	89 f9                	mov    %edi,%ecx
  801277:	d3 e6                	shl    %cl,%esi
  801279:	39 c6                	cmp    %eax,%esi
  80127b:	73 07                	jae    801284 <__udivdi3+0xc4>
  80127d:	39 d5                	cmp    %edx,%ebp
  80127f:	75 03                	jne    801284 <__udivdi3+0xc4>
  801281:	83 eb 01             	sub    $0x1,%ebx
  801284:	31 ff                	xor    %edi,%edi
  801286:	89 d8                	mov    %ebx,%eax
  801288:	89 fa                	mov    %edi,%edx
  80128a:	83 c4 1c             	add    $0x1c,%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    
  801292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801298:	31 ff                	xor    %edi,%edi
  80129a:	31 db                	xor    %ebx,%ebx
  80129c:	89 d8                	mov    %ebx,%eax
  80129e:	89 fa                	mov    %edi,%edx
  8012a0:	83 c4 1c             	add    $0x1c,%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    
  8012a8:	90                   	nop
  8012a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	89 d8                	mov    %ebx,%eax
  8012b2:	f7 f7                	div    %edi
  8012b4:	31 ff                	xor    %edi,%edi
  8012b6:	89 c3                	mov    %eax,%ebx
  8012b8:	89 d8                	mov    %ebx,%eax
  8012ba:	89 fa                	mov    %edi,%edx
  8012bc:	83 c4 1c             	add    $0x1c,%esp
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	39 ce                	cmp    %ecx,%esi
  8012ca:	72 0c                	jb     8012d8 <__udivdi3+0x118>
  8012cc:	31 db                	xor    %ebx,%ebx
  8012ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012d2:	0f 87 34 ff ff ff    	ja     80120c <__udivdi3+0x4c>
  8012d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012dd:	e9 2a ff ff ff       	jmp    80120c <__udivdi3+0x4c>
  8012e2:	66 90                	xchg   %ax,%ax
  8012e4:	66 90                	xchg   %ax,%ax
  8012e6:	66 90                	xchg   %ax,%ax
  8012e8:	66 90                	xchg   %ax,%ax
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <__umoddi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 1c             	sub    $0x1c,%esp
  8012f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801307:	85 d2                	test   %edx,%edx
  801309:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80130d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801311:	89 f3                	mov    %esi,%ebx
  801313:	89 3c 24             	mov    %edi,(%esp)
  801316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80131a:	75 1c                	jne    801338 <__umoddi3+0x48>
  80131c:	39 f7                	cmp    %esi,%edi
  80131e:	76 50                	jbe    801370 <__umoddi3+0x80>
  801320:	89 c8                	mov    %ecx,%eax
  801322:	89 f2                	mov    %esi,%edx
  801324:	f7 f7                	div    %edi
  801326:	89 d0                	mov    %edx,%eax
  801328:	31 d2                	xor    %edx,%edx
  80132a:	83 c4 1c             	add    $0x1c,%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5e                   	pop    %esi
  80132f:	5f                   	pop    %edi
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    
  801332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801338:	39 f2                	cmp    %esi,%edx
  80133a:	89 d0                	mov    %edx,%eax
  80133c:	77 52                	ja     801390 <__umoddi3+0xa0>
  80133e:	0f bd ea             	bsr    %edx,%ebp
  801341:	83 f5 1f             	xor    $0x1f,%ebp
  801344:	75 5a                	jne    8013a0 <__umoddi3+0xb0>
  801346:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80134a:	0f 82 e0 00 00 00    	jb     801430 <__umoddi3+0x140>
  801350:	39 0c 24             	cmp    %ecx,(%esp)
  801353:	0f 86 d7 00 00 00    	jbe    801430 <__umoddi3+0x140>
  801359:	8b 44 24 08          	mov    0x8(%esp),%eax
  80135d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801361:	83 c4 1c             	add    $0x1c,%esp
  801364:	5b                   	pop    %ebx
  801365:	5e                   	pop    %esi
  801366:	5f                   	pop    %edi
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    
  801369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801370:	85 ff                	test   %edi,%edi
  801372:	89 fd                	mov    %edi,%ebp
  801374:	75 0b                	jne    801381 <__umoddi3+0x91>
  801376:	b8 01 00 00 00       	mov    $0x1,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	f7 f7                	div    %edi
  80137f:	89 c5                	mov    %eax,%ebp
  801381:	89 f0                	mov    %esi,%eax
  801383:	31 d2                	xor    %edx,%edx
  801385:	f7 f5                	div    %ebp
  801387:	89 c8                	mov    %ecx,%eax
  801389:	f7 f5                	div    %ebp
  80138b:	89 d0                	mov    %edx,%eax
  80138d:	eb 99                	jmp    801328 <__umoddi3+0x38>
  80138f:	90                   	nop
  801390:	89 c8                	mov    %ecx,%eax
  801392:	89 f2                	mov    %esi,%edx
  801394:	83 c4 1c             	add    $0x1c,%esp
  801397:	5b                   	pop    %ebx
  801398:	5e                   	pop    %esi
  801399:	5f                   	pop    %edi
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    
  80139c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	8b 34 24             	mov    (%esp),%esi
  8013a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013a8:	89 e9                	mov    %ebp,%ecx
  8013aa:	29 ef                	sub    %ebp,%edi
  8013ac:	d3 e0                	shl    %cl,%eax
  8013ae:	89 f9                	mov    %edi,%ecx
  8013b0:	89 f2                	mov    %esi,%edx
  8013b2:	d3 ea                	shr    %cl,%edx
  8013b4:	89 e9                	mov    %ebp,%ecx
  8013b6:	09 c2                	or     %eax,%edx
  8013b8:	89 d8                	mov    %ebx,%eax
  8013ba:	89 14 24             	mov    %edx,(%esp)
  8013bd:	89 f2                	mov    %esi,%edx
  8013bf:	d3 e2                	shl    %cl,%edx
  8013c1:	89 f9                	mov    %edi,%ecx
  8013c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013cb:	d3 e8                	shr    %cl,%eax
  8013cd:	89 e9                	mov    %ebp,%ecx
  8013cf:	89 c6                	mov    %eax,%esi
  8013d1:	d3 e3                	shl    %cl,%ebx
  8013d3:	89 f9                	mov    %edi,%ecx
  8013d5:	89 d0                	mov    %edx,%eax
  8013d7:	d3 e8                	shr    %cl,%eax
  8013d9:	89 e9                	mov    %ebp,%ecx
  8013db:	09 d8                	or     %ebx,%eax
  8013dd:	89 d3                	mov    %edx,%ebx
  8013df:	89 f2                	mov    %esi,%edx
  8013e1:	f7 34 24             	divl   (%esp)
  8013e4:	89 d6                	mov    %edx,%esi
  8013e6:	d3 e3                	shl    %cl,%ebx
  8013e8:	f7 64 24 04          	mull   0x4(%esp)
  8013ec:	39 d6                	cmp    %edx,%esi
  8013ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f2:	89 d1                	mov    %edx,%ecx
  8013f4:	89 c3                	mov    %eax,%ebx
  8013f6:	72 08                	jb     801400 <__umoddi3+0x110>
  8013f8:	75 11                	jne    80140b <__umoddi3+0x11b>
  8013fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013fe:	73 0b                	jae    80140b <__umoddi3+0x11b>
  801400:	2b 44 24 04          	sub    0x4(%esp),%eax
  801404:	1b 14 24             	sbb    (%esp),%edx
  801407:	89 d1                	mov    %edx,%ecx
  801409:	89 c3                	mov    %eax,%ebx
  80140b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80140f:	29 da                	sub    %ebx,%edx
  801411:	19 ce                	sbb    %ecx,%esi
  801413:	89 f9                	mov    %edi,%ecx
  801415:	89 f0                	mov    %esi,%eax
  801417:	d3 e0                	shl    %cl,%eax
  801419:	89 e9                	mov    %ebp,%ecx
  80141b:	d3 ea                	shr    %cl,%edx
  80141d:	89 e9                	mov    %ebp,%ecx
  80141f:	d3 ee                	shr    %cl,%esi
  801421:	09 d0                	or     %edx,%eax
  801423:	89 f2                	mov    %esi,%edx
  801425:	83 c4 1c             	add    $0x1c,%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5f                   	pop    %edi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    
  80142d:	8d 76 00             	lea    0x0(%esi),%esi
  801430:	29 f9                	sub    %edi,%ecx
  801432:	19 d6                	sbb    %edx,%esi
  801434:	89 74 24 04          	mov    %esi,0x4(%esp)
  801438:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80143c:	e9 18 ff ff ff       	jmp    801359 <__umoddi3+0x69>
