
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 00 14 80 00       	push   $0x801400
  800056:	e8 f0 00 00 00       	call   80014b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006b:	e8 a3 0d 00 00       	call   800e13 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	c1 e0 07             	shl    $0x7,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 10 20 80 00       	mov    %eax,0x802010
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 10 0d 00 00       	call   800dc3 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 1a                	jne    8000f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 ff 00 00 00       	push   $0xff
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	50                   	push   %eax
  8000e3:	e8 7a 0c 00 00       	call   800d62 <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b8 00 80 00       	push   $0x8000b8
  800129:	e8 c0 02 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 1f 0c 00 00       	call   800d62 <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800175:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800178:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80017b:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80017f:	0f 85 bf 00 00 00    	jne    800244 <printnum+0xe5>
  800185:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  80018b:	0f 8d de 00 00 00    	jge    80026f <printnum+0x110>
		judge_time_for_space = width;
  800191:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800197:	e9 d3 00 00 00       	jmp    80026f <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80019c:	83 eb 01             	sub    $0x1,%ebx
  80019f:	85 db                	test   %ebx,%ebx
  8001a1:	7f 37                	jg     8001da <printnum+0x7b>
  8001a3:	e9 ea 00 00 00       	jmp    800292 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8001a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001ab:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	56                   	push   %esi
  8001b4:	83 ec 04             	sub    $0x4,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c3:	e8 c8 10 00 00       	call   801290 <__umoddi3>
  8001c8:	83 c4 14             	add    $0x14,%esp
  8001cb:	0f be 80 18 14 80 00 	movsbl 0x801418(%eax),%eax
  8001d2:	50                   	push   %eax
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 16                	jmp    8001f0 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8001da:	83 ec 08             	sub    $0x8,%esp
  8001dd:	56                   	push   %esi
  8001de:	ff 75 18             	pushl  0x18(%ebp)
  8001e1:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001e3:	83 c4 10             	add    $0x10,%esp
  8001e6:	83 eb 01             	sub    $0x1,%ebx
  8001e9:	75 ef                	jne    8001da <printnum+0x7b>
  8001eb:	e9 a2 00 00 00       	jmp    800292 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8001f0:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8001f6:	0f 85 76 01 00 00    	jne    800372 <printnum+0x213>
		while(num_of_space-- > 0)
  8001fc:	a1 04 20 80 00       	mov    0x802004,%eax
  800201:	8d 50 ff             	lea    -0x1(%eax),%edx
  800204:	89 15 04 20 80 00    	mov    %edx,0x802004
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 1d                	jle    80022b <printnum+0xcc>
			putch(' ', putdat);
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	56                   	push   %esi
  800212:	6a 20                	push   $0x20
  800214:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800216:	a1 04 20 80 00       	mov    0x802004,%eax
  80021b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80021e:	89 15 04 20 80 00    	mov    %edx,0x802004
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	85 c0                	test   %eax,%eax
  800229:	7f e3                	jg     80020e <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  80022b:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800232:	00 00 00 
		judge_time_for_space = 0;
  800235:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80023c:	00 00 00 
	}
}
  80023f:	e9 2e 01 00 00       	jmp    800372 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	8b 45 10             	mov    0x10(%ebp),%eax
  800247:	ba 00 00 00 00       	mov    $0x0,%edx
  80024c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800252:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800255:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800258:	83 fa 00             	cmp    $0x0,%edx
  80025b:	0f 87 ba 00 00 00    	ja     80031b <printnum+0x1bc>
  800261:	3b 45 10             	cmp    0x10(%ebp),%eax
  800264:	0f 83 b1 00 00 00    	jae    80031b <printnum+0x1bc>
  80026a:	e9 2d ff ff ff       	jmp    80019c <printnum+0x3d>
  80026f:	8b 45 10             	mov    0x10(%ebp),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80027d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800280:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800283:	83 fa 00             	cmp    $0x0,%edx
  800286:	77 37                	ja     8002bf <printnum+0x160>
  800288:	3b 45 10             	cmp    0x10(%ebp),%eax
  80028b:	73 32                	jae    8002bf <printnum+0x160>
  80028d:	e9 16 ff ff ff       	jmp    8001a8 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	56                   	push   %esi
  800296:	83 ec 04             	sub    $0x4,%esp
  800299:	ff 75 dc             	pushl  -0x24(%ebp)
  80029c:	ff 75 d8             	pushl  -0x28(%ebp)
  80029f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a5:	e8 e6 0f 00 00       	call   801290 <__umoddi3>
  8002aa:	83 c4 14             	add    $0x14,%esp
  8002ad:	0f be 80 18 14 80 00 	movsbl 0x801418(%eax),%eax
  8002b4:	50                   	push   %eax
  8002b5:	ff d7                	call   *%edi
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	e9 b3 00 00 00       	jmp    800372 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	ff 75 18             	pushl  0x18(%ebp)
  8002c5:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002c8:	50                   	push   %eax
  8002c9:	ff 75 10             	pushl  0x10(%ebp)
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002db:	e8 80 0e 00 00       	call   801160 <__udivdi3>
  8002e0:	83 c4 18             	add    $0x18,%esp
  8002e3:	52                   	push   %edx
  8002e4:	50                   	push   %eax
  8002e5:	89 f2                	mov    %esi,%edx
  8002e7:	89 f8                	mov    %edi,%eax
  8002e9:	e8 71 fe ff ff       	call   80015f <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ee:	83 c4 18             	add    $0x18,%esp
  8002f1:	56                   	push   %esi
  8002f2:	83 ec 04             	sub    $0x4,%esp
  8002f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800301:	e8 8a 0f 00 00       	call   801290 <__umoddi3>
  800306:	83 c4 14             	add    $0x14,%esp
  800309:	0f be 80 18 14 80 00 	movsbl 0x801418(%eax),%eax
  800310:	50                   	push   %eax
  800311:	ff d7                	call   *%edi
  800313:	83 c4 10             	add    $0x10,%esp
  800316:	e9 d5 fe ff ff       	jmp    8001f0 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031b:	83 ec 0c             	sub    $0xc,%esp
  80031e:	ff 75 18             	pushl  0x18(%ebp)
  800321:	83 eb 01             	sub    $0x1,%ebx
  800324:	53                   	push   %ebx
  800325:	ff 75 10             	pushl  0x10(%ebp)
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	ff 75 dc             	pushl  -0x24(%ebp)
  80032e:	ff 75 d8             	pushl  -0x28(%ebp)
  800331:	ff 75 e4             	pushl  -0x1c(%ebp)
  800334:	ff 75 e0             	pushl  -0x20(%ebp)
  800337:	e8 24 0e 00 00       	call   801160 <__udivdi3>
  80033c:	83 c4 18             	add    $0x18,%esp
  80033f:	52                   	push   %edx
  800340:	50                   	push   %eax
  800341:	89 f2                	mov    %esi,%edx
  800343:	89 f8                	mov    %edi,%eax
  800345:	e8 15 fe ff ff       	call   80015f <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034a:	83 c4 18             	add    $0x18,%esp
  80034d:	56                   	push   %esi
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035a:	ff 75 e0             	pushl  -0x20(%ebp)
  80035d:	e8 2e 0f 00 00       	call   801290 <__umoddi3>
  800362:	83 c4 14             	add    $0x14,%esp
  800365:	0f be 80 18 14 80 00 	movsbl 0x801418(%eax),%eax
  80036c:	50                   	push   %eax
  80036d:	ff d7                	call   *%edi
  80036f:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037d:	83 fa 01             	cmp    $0x1,%edx
  800380:	7e 0e                	jle    800390 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 08             	lea    0x8(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	8b 52 04             	mov    0x4(%edx),%edx
  80038e:	eb 22                	jmp    8003b2 <getuint+0x38>
	else if (lflag)
  800390:	85 d2                	test   %edx,%edx
  800392:	74 10                	je     8003a4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800394:	8b 10                	mov    (%eax),%edx
  800396:	8d 4a 04             	lea    0x4(%edx),%ecx
  800399:	89 08                	mov    %ecx,(%eax)
  80039b:	8b 02                	mov    (%edx),%eax
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	eb 0e                	jmp    8003b2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a4:	8b 10                	mov    (%eax),%edx
  8003a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a9:	89 08                	mov    %ecx,(%eax)
  8003ab:	8b 02                	mov    (%edx),%eax
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003be:	8b 10                	mov    (%eax),%edx
  8003c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c3:	73 0a                	jae    8003cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	88 02                	mov    %al,(%edx)
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 10             	pushl  0x10(%ebp)
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 05 00 00 00       	call   8003ee <vprintfmt>
	va_end(ap);
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 2c             	sub    $0x2c,%esp
  8003f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003fd:	eb 03                	jmp    800402 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003ff:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800402:	8b 45 10             	mov    0x10(%ebp),%eax
  800405:	8d 70 01             	lea    0x1(%eax),%esi
  800408:	0f b6 00             	movzbl (%eax),%eax
  80040b:	83 f8 25             	cmp    $0x25,%eax
  80040e:	74 27                	je     800437 <vprintfmt+0x49>
			if (ch == '\0')
  800410:	85 c0                	test   %eax,%eax
  800412:	75 0d                	jne    800421 <vprintfmt+0x33>
  800414:	e9 9d 04 00 00       	jmp    8008b6 <vprintfmt+0x4c8>
  800419:	85 c0                	test   %eax,%eax
  80041b:	0f 84 95 04 00 00    	je     8008b6 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	53                   	push   %ebx
  800425:	50                   	push   %eax
  800426:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800428:	83 c6 01             	add    $0x1,%esi
  80042b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80042f:	83 c4 10             	add    $0x10,%esp
  800432:	83 f8 25             	cmp    $0x25,%eax
  800435:	75 e2                	jne    800419 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800437:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043c:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800440:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800447:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800455:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80045c:	eb 08                	jmp    800466 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800461:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8d 46 01             	lea    0x1(%esi),%eax
  800469:	89 45 10             	mov    %eax,0x10(%ebp)
  80046c:	0f b6 06             	movzbl (%esi),%eax
  80046f:	0f b6 d0             	movzbl %al,%edx
  800472:	83 e8 23             	sub    $0x23,%eax
  800475:	3c 55                	cmp    $0x55,%al
  800477:	0f 87 fa 03 00 00    	ja     800877 <vprintfmt+0x489>
  80047d:	0f b6 c0             	movzbl %al,%eax
  800480:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
  800487:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80048a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80048e:	eb d6                	jmp    800466 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800490:	8d 42 d0             	lea    -0x30(%edx),%eax
  800493:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800496:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80049a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80049d:	83 fa 09             	cmp    $0x9,%edx
  8004a0:	77 6b                	ja     80050d <vprintfmt+0x11f>
  8004a2:	8b 75 10             	mov    0x10(%ebp),%esi
  8004a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004a8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004ab:	eb 09                	jmp    8004b6 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b0:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8004b4:	eb b0                	jmp    800466 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b6:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004b9:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004bc:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004c0:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c3:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004c6:	83 f9 09             	cmp    $0x9,%ecx
  8004c9:	76 eb                	jbe    8004b6 <vprintfmt+0xc8>
  8004cb:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004ce:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d1:	eb 3d                	jmp    800510 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e4:	eb 2a                	jmp    800510 <vprintfmt+0x122>
  8004e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f0:	0f 49 d0             	cmovns %eax,%edx
  8004f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f9:	e9 68 ff ff ff       	jmp    800466 <vprintfmt+0x78>
  8004fe:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800501:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800508:	e9 59 ff ff ff       	jmp    800466 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	0f 89 4c ff ff ff    	jns    800466 <vprintfmt+0x78>
				width = precision, precision = -1;
  80051a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80051d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800520:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800527:	e9 3a ff ff ff       	jmp    800466 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052c:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800533:	e9 2e ff ff ff       	jmp    800466 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	53                   	push   %ebx
  800545:	ff 30                	pushl  (%eax)
  800547:	ff d7                	call   *%edi
			break;
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	e9 b1 fe ff ff       	jmp    800402 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	99                   	cltd   
  80055d:	31 d0                	xor    %edx,%eax
  80055f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800561:	83 f8 08             	cmp    $0x8,%eax
  800564:	7f 0b                	jg     800571 <vprintfmt+0x183>
  800566:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  80056d:	85 d2                	test   %edx,%edx
  80056f:	75 15                	jne    800586 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800571:	50                   	push   %eax
  800572:	68 30 14 80 00       	push   $0x801430
  800577:	53                   	push   %ebx
  800578:	57                   	push   %edi
  800579:	e8 53 fe ff ff       	call   8003d1 <printfmt>
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	e9 7c fe ff ff       	jmp    800402 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800586:	52                   	push   %edx
  800587:	68 39 14 80 00       	push   $0x801439
  80058c:	53                   	push   %ebx
  80058d:	57                   	push   %edi
  80058e:	e8 3e fe ff ff       	call   8003d1 <printfmt>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	e9 67 fe ff ff       	jmp    800402 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 50 04             	lea    0x4(%eax),%edx
  8005a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a4:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	b9 29 14 80 00       	mov    $0x801429,%ecx
  8005ad:	0f 45 c8             	cmovne %eax,%ecx
  8005b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b7:	7e 06                	jle    8005bf <vprintfmt+0x1d1>
  8005b9:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005bd:	75 19                	jne    8005d8 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bf:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005c2:	8d 70 01             	lea    0x1(%eax),%esi
  8005c5:	0f b6 00             	movzbl (%eax),%eax
  8005c8:	0f be d0             	movsbl %al,%edx
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	0f 85 9f 00 00 00    	jne    800672 <vprintfmt+0x284>
  8005d3:	e9 8c 00 00 00       	jmp    800664 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	ff 75 d0             	pushl  -0x30(%ebp)
  8005de:	ff 75 cc             	pushl  -0x34(%ebp)
  8005e1:	e8 62 03 00 00       	call   800948 <strnlen>
  8005e6:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005e9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	85 c9                	test   %ecx,%ecx
  8005f1:	0f 8e a6 02 00 00    	jle    80089d <vprintfmt+0x4af>
					putch(padc, putdat);
  8005f7:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005fe:	89 cb                	mov    %ecx,%ebx
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	ff 75 0c             	pushl  0xc(%ebp)
  800606:	56                   	push   %esi
  800607:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	83 eb 01             	sub    $0x1,%ebx
  80060f:	75 ef                	jne    800600 <vprintfmt+0x212>
  800611:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800614:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800617:	e9 81 02 00 00       	jmp    80089d <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800620:	74 1b                	je     80063d <vprintfmt+0x24f>
  800622:	0f be c0             	movsbl %al,%eax
  800625:	83 e8 20             	sub    $0x20,%eax
  800628:	83 f8 5e             	cmp    $0x5e,%eax
  80062b:	76 10                	jbe    80063d <vprintfmt+0x24f>
					putch('?', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	ff 75 0c             	pushl  0xc(%ebp)
  800633:	6a 3f                	push   $0x3f
  800635:	ff 55 08             	call   *0x8(%ebp)
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	eb 0d                	jmp    80064a <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	ff 75 0c             	pushl  0xc(%ebp)
  800643:	52                   	push   %edx
  800644:	ff 55 08             	call   *0x8(%ebp)
  800647:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064a:	83 ef 01             	sub    $0x1,%edi
  80064d:	83 c6 01             	add    $0x1,%esi
  800650:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800654:	0f be d0             	movsbl %al,%edx
  800657:	85 d2                	test   %edx,%edx
  800659:	75 31                	jne    80068c <vprintfmt+0x29e>
  80065b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800664:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066b:	7f 33                	jg     8006a0 <vprintfmt+0x2b2>
  80066d:	e9 90 fd ff ff       	jmp    800402 <vprintfmt+0x14>
  800672:	89 7d 08             	mov    %edi,0x8(%ebp)
  800675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800678:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80067e:	eb 0c                	jmp    80068c <vprintfmt+0x29e>
  800680:	89 7d 08             	mov    %edi,0x8(%ebp)
  800683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800686:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800689:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068c:	85 db                	test   %ebx,%ebx
  80068e:	78 8c                	js     80061c <vprintfmt+0x22e>
  800690:	83 eb 01             	sub    $0x1,%ebx
  800693:	79 87                	jns    80061c <vprintfmt+0x22e>
  800695:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800698:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069e:	eb c4                	jmp    800664 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	6a 20                	push   $0x20
  8006a6:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	83 ee 01             	sub    $0x1,%esi
  8006ae:	75 f0                	jne    8006a0 <vprintfmt+0x2b2>
  8006b0:	e9 4d fd ff ff       	jmp    800402 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b5:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8006b9:	7e 16                	jle    8006d1 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 08             	lea    0x8(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 50 04             	mov    0x4(%eax),%edx
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006cc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006cf:	eb 34                	jmp    800705 <vprintfmt+0x317>
	else if (lflag)
  8006d1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006d5:	74 18                	je     8006ef <vprintfmt+0x301>
		return va_arg(*ap, long);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 50 04             	lea    0x4(%eax),%edx
  8006dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e0:	8b 30                	mov    (%eax),%esi
  8006e2:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006e5:	89 f0                	mov    %esi,%eax
  8006e7:	c1 f8 1f             	sar    $0x1f,%eax
  8006ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006ed:	eb 16                	jmp    800705 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 30                	mov    (%eax),%esi
  8006fa:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006fd:	89 f0                	mov    %esi,%eax
  8006ff:	c1 f8 1f             	sar    $0x1f,%eax
  800702:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800705:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800708:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80070b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800711:	85 d2                	test   %edx,%edx
  800713:	79 28                	jns    80073d <vprintfmt+0x34f>
				putch('-', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	6a 2d                	push   $0x2d
  80071b:	ff d7                	call   *%edi
				num = -(long long) num;
  80071d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800720:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800723:	f7 d8                	neg    %eax
  800725:	83 d2 00             	adc    $0x0,%edx
  800728:	f7 da                	neg    %edx
  80072a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800733:	b8 0a 00 00 00       	mov    $0xa,%eax
  800738:	e9 b2 00 00 00       	jmp    8007ef <vprintfmt+0x401>
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800742:	85 c9                	test   %ecx,%ecx
  800744:	0f 84 a5 00 00 00    	je     8007ef <vprintfmt+0x401>
				putch('+', putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	6a 2b                	push   $0x2b
  800750:	ff d7                	call   *%edi
  800752:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800755:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075a:	e9 90 00 00 00       	jmp    8007ef <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  80075f:	85 c9                	test   %ecx,%ecx
  800761:	74 0b                	je     80076e <vprintfmt+0x380>
				putch('+', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 2b                	push   $0x2b
  800769:	ff d7                	call   *%edi
  80076b:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  80076e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 01 fc ff ff       	call   80037a <getuint>
  800779:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80077f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800784:	eb 69                	jmp    8007ef <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	53                   	push   %ebx
  80078a:	6a 30                	push   $0x30
  80078c:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80078e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	e8 e1 fb ff ff       	call   80037a <getuint>
  800799:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80079f:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007a2:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007a7:	eb 46                	jmp    8007ef <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007a9:	83 ec 08             	sub    $0x8,%esp
  8007ac:	53                   	push   %ebx
  8007ad:	6a 30                	push   $0x30
  8007af:	ff d7                	call   *%edi
			putch('x', putdat);
  8007b1:	83 c4 08             	add    $0x8,%esp
  8007b4:	53                   	push   %ebx
  8007b5:	6a 78                	push   $0x78
  8007b7:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 50 04             	lea    0x4(%eax),%edx
  8007bf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c2:	8b 00                	mov    (%eax),%eax
  8007c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d7:	eb 16                	jmp    8007ef <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007df:	e8 96 fb ff ff       	call   80037a <getuint>
  8007e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8007ea:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ef:	83 ec 0c             	sub    $0xc,%esp
  8007f2:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007f6:	56                   	push   %esi
  8007f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fa:	50                   	push   %eax
  8007fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8007fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800801:	89 da                	mov    %ebx,%edx
  800803:	89 f8                	mov    %edi,%eax
  800805:	e8 55 f9 ff ff       	call   80015f <printnum>
			break;
  80080a:	83 c4 20             	add    $0x20,%esp
  80080d:	e9 f0 fb ff ff       	jmp    800402 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)
  80081b:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  80081d:	85 f6                	test   %esi,%esi
  80081f:	75 1a                	jne    80083b <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800821:	83 ec 08             	sub    $0x8,%esp
  800824:	68 d0 14 80 00       	push   $0x8014d0
  800829:	68 39 14 80 00       	push   $0x801439
  80082e:	e8 18 f9 ff ff       	call   80014b <cprintf>
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	e9 c7 fb ff ff       	jmp    800402 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  80083b:	0f b6 03             	movzbl (%ebx),%eax
  80083e:	84 c0                	test   %al,%al
  800840:	79 1f                	jns    800861 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	68 08 15 80 00       	push   $0x801508
  80084a:	68 39 14 80 00       	push   $0x801439
  80084f:	e8 f7 f8 ff ff       	call   80014b <cprintf>
						*tmp = *(char *)putdat;
  800854:	0f b6 03             	movzbl (%ebx),%eax
  800857:	88 06                	mov    %al,(%esi)
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	e9 a1 fb ff ff       	jmp    800402 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800861:	88 06                	mov    %al,(%esi)
  800863:	e9 9a fb ff ff       	jmp    800402 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	52                   	push   %edx
  80086d:	ff d7                	call   *%edi
			break;
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	e9 8b fb ff ff       	jmp    800402 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	53                   	push   %ebx
  80087b:	6a 25                	push   $0x25
  80087d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800886:	0f 84 73 fb ff ff    	je     8003ff <vprintfmt+0x11>
  80088c:	83 ee 01             	sub    $0x1,%esi
  80088f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800893:	75 f7                	jne    80088c <vprintfmt+0x49e>
  800895:	89 75 10             	mov    %esi,0x10(%ebp)
  800898:	e9 65 fb ff ff       	jmp    800402 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80089d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008a0:	8d 70 01             	lea    0x1(%eax),%esi
  8008a3:	0f b6 00             	movzbl (%eax),%eax
  8008a6:	0f be d0             	movsbl %al,%edx
  8008a9:	85 d2                	test   %edx,%edx
  8008ab:	0f 85 cf fd ff ff    	jne    800680 <vprintfmt+0x292>
  8008b1:	e9 4c fb ff ff       	jmp    800402 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5f                   	pop    %edi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	83 ec 18             	sub    $0x18,%esp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	74 26                	je     800905 <vsnprintf+0x47>
  8008df:	85 d2                	test   %edx,%edx
  8008e1:	7e 22                	jle    800905 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e3:	ff 75 14             	pushl  0x14(%ebp)
  8008e6:	ff 75 10             	pushl  0x10(%ebp)
  8008e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ec:	50                   	push   %eax
  8008ed:	68 b4 03 80 00       	push   $0x8003b4
  8008f2:	e8 f7 fa ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	eb 05                	jmp    80090a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800905:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800912:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800915:	50                   	push   %eax
  800916:	ff 75 10             	pushl  0x10(%ebp)
  800919:	ff 75 0c             	pushl  0xc(%ebp)
  80091c:	ff 75 08             	pushl  0x8(%ebp)
  80091f:	e8 9a ff ff ff       	call   8008be <vsnprintf>
	va_end(ap);

	return rc;
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092c:	80 3a 00             	cmpb   $0x0,(%edx)
  80092f:	74 10                	je     800941 <strlen+0x1b>
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800936:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800939:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093d:	75 f7                	jne    800936 <strlen+0x10>
  80093f:	eb 05                	jmp    800946 <strlen+0x20>
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	53                   	push   %ebx
  80094c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80094f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800952:	85 c9                	test   %ecx,%ecx
  800954:	74 1c                	je     800972 <strnlen+0x2a>
  800956:	80 3b 00             	cmpb   $0x0,(%ebx)
  800959:	74 1e                	je     800979 <strnlen+0x31>
  80095b:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800960:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800962:	39 ca                	cmp    %ecx,%edx
  800964:	74 18                	je     80097e <strnlen+0x36>
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80096e:	75 f0                	jne    800960 <strnlen+0x18>
  800970:	eb 0c                	jmp    80097e <strnlen+0x36>
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
  800977:	eb 05                	jmp    80097e <strnlen+0x36>
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80097e:	5b                   	pop    %ebx
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	53                   	push   %ebx
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098b:	89 c2                	mov    %eax,%edx
  80098d:	83 c2 01             	add    $0x1,%edx
  800990:	83 c1 01             	add    $0x1,%ecx
  800993:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800997:	88 5a ff             	mov    %bl,-0x1(%edx)
  80099a:	84 db                	test   %bl,%bl
  80099c:	75 ef                	jne    80098d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a8:	53                   	push   %ebx
  8009a9:	e8 78 ff ff ff       	call   800926 <strlen>
  8009ae:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b1:	ff 75 0c             	pushl  0xc(%ebp)
  8009b4:	01 d8                	add    %ebx,%eax
  8009b6:	50                   	push   %eax
  8009b7:	e8 c5 ff ff ff       	call   800981 <strcpy>
	return dst;
}
  8009bc:	89 d8                	mov    %ebx,%eax
  8009be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d1:	85 db                	test   %ebx,%ebx
  8009d3:	74 17                	je     8009ec <strncpy+0x29>
  8009d5:	01 f3                	add    %esi,%ebx
  8009d7:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	0f b6 02             	movzbl (%edx),%eax
  8009df:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e2:	80 3a 01             	cmpb   $0x1,(%edx)
  8009e5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e8:	39 cb                	cmp    %ecx,%ebx
  8009ea:	75 ed                	jne    8009d9 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ec:	89 f0                	mov    %esi,%eax
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009fd:	8b 55 10             	mov    0x10(%ebp),%edx
  800a00:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a02:	85 d2                	test   %edx,%edx
  800a04:	74 35                	je     800a3b <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a06:	89 d0                	mov    %edx,%eax
  800a08:	83 e8 01             	sub    $0x1,%eax
  800a0b:	74 25                	je     800a32 <strlcpy+0x40>
  800a0d:	0f b6 0b             	movzbl (%ebx),%ecx
  800a10:	84 c9                	test   %cl,%cl
  800a12:	74 22                	je     800a36 <strlcpy+0x44>
  800a14:	8d 53 01             	lea    0x1(%ebx),%edx
  800a17:	01 c3                	add    %eax,%ebx
  800a19:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a21:	39 da                	cmp    %ebx,%edx
  800a23:	74 13                	je     800a38 <strlcpy+0x46>
  800a25:	83 c2 01             	add    $0x1,%edx
  800a28:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a2c:	84 c9                	test   %cl,%cl
  800a2e:	75 eb                	jne    800a1b <strlcpy+0x29>
  800a30:	eb 06                	jmp    800a38 <strlcpy+0x46>
  800a32:	89 f0                	mov    %esi,%eax
  800a34:	eb 02                	jmp    800a38 <strlcpy+0x46>
  800a36:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a38:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a3b:	29 f0                	sub    %esi,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a4a:	0f b6 01             	movzbl (%ecx),%eax
  800a4d:	84 c0                	test   %al,%al
  800a4f:	74 15                	je     800a66 <strcmp+0x25>
  800a51:	3a 02                	cmp    (%edx),%al
  800a53:	75 11                	jne    800a66 <strcmp+0x25>
		p++, q++;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5b:	0f b6 01             	movzbl (%ecx),%eax
  800a5e:	84 c0                	test   %al,%al
  800a60:	74 04                	je     800a66 <strcmp+0x25>
  800a62:	3a 02                	cmp    (%edx),%al
  800a64:	74 ef                	je     800a55 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 c0             	movzbl %al,%eax
  800a69:	0f b6 12             	movzbl (%edx),%edx
  800a6c:	29 d0                	sub    %edx,%eax
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a7e:	85 f6                	test   %esi,%esi
  800a80:	74 29                	je     800aab <strncmp+0x3b>
  800a82:	0f b6 03             	movzbl (%ebx),%eax
  800a85:	84 c0                	test   %al,%al
  800a87:	74 30                	je     800ab9 <strncmp+0x49>
  800a89:	3a 02                	cmp    (%edx),%al
  800a8b:	75 2c                	jne    800ab9 <strncmp+0x49>
  800a8d:	8d 43 01             	lea    0x1(%ebx),%eax
  800a90:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a92:	89 c3                	mov    %eax,%ebx
  800a94:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a97:	39 c6                	cmp    %eax,%esi
  800a99:	74 17                	je     800ab2 <strncmp+0x42>
  800a9b:	0f b6 08             	movzbl (%eax),%ecx
  800a9e:	84 c9                	test   %cl,%cl
  800aa0:	74 17                	je     800ab9 <strncmp+0x49>
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	3a 0a                	cmp    (%edx),%cl
  800aa7:	74 e9                	je     800a92 <strncmp+0x22>
  800aa9:	eb 0e                	jmp    800ab9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab0:	eb 0f                	jmp    800ac1 <strncmp+0x51>
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	eb 08                	jmp    800ac1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab9:	0f b6 03             	movzbl (%ebx),%eax
  800abc:	0f b6 12             	movzbl (%edx),%edx
  800abf:	29 d0                	sub    %edx,%eax
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	53                   	push   %ebx
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800acf:	0f b6 10             	movzbl (%eax),%edx
  800ad2:	84 d2                	test   %dl,%dl
  800ad4:	74 1d                	je     800af3 <strchr+0x2e>
  800ad6:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ad8:	38 d3                	cmp    %dl,%bl
  800ada:	75 06                	jne    800ae2 <strchr+0x1d>
  800adc:	eb 1a                	jmp    800af8 <strchr+0x33>
  800ade:	38 ca                	cmp    %cl,%dl
  800ae0:	74 16                	je     800af8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	0f b6 10             	movzbl (%eax),%edx
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	75 f2                	jne    800ade <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	eb 05                	jmp    800af8 <strchr+0x33>
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b05:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b08:	38 d3                	cmp    %dl,%bl
  800b0a:	74 14                	je     800b20 <strfind+0x25>
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	84 db                	test   %bl,%bl
  800b10:	74 0e                	je     800b20 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b12:	83 c0 01             	add    $0x1,%eax
  800b15:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b18:	38 ca                	cmp    %cl,%dl
  800b1a:	74 04                	je     800b20 <strfind+0x25>
  800b1c:	84 d2                	test   %dl,%dl
  800b1e:	75 f2                	jne    800b12 <strfind+0x17>
			break;
	return (char *) s;
}
  800b20:	5b                   	pop    %ebx
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b2f:	85 c9                	test   %ecx,%ecx
  800b31:	74 36                	je     800b69 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b33:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b39:	75 28                	jne    800b63 <memset+0x40>
  800b3b:	f6 c1 03             	test   $0x3,%cl
  800b3e:	75 23                	jne    800b63 <memset+0x40>
		c &= 0xFF;
  800b40:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	c1 e3 08             	shl    $0x8,%ebx
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	c1 e6 18             	shl    $0x18,%esi
  800b4e:	89 d0                	mov    %edx,%eax
  800b50:	c1 e0 10             	shl    $0x10,%eax
  800b53:	09 f0                	or     %esi,%eax
  800b55:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b57:	89 d8                	mov    %ebx,%eax
  800b59:	09 d0                	or     %edx,%eax
  800b5b:	c1 e9 02             	shr    $0x2,%ecx
  800b5e:	fc                   	cld    
  800b5f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b61:	eb 06                	jmp    800b69 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b66:	fc                   	cld    
  800b67:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b69:	89 f8                	mov    %edi,%eax
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7e:	39 c6                	cmp    %eax,%esi
  800b80:	73 35                	jae    800bb7 <memmove+0x47>
  800b82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b85:	39 d0                	cmp    %edx,%eax
  800b87:	73 2e                	jae    800bb7 <memmove+0x47>
		s += n;
		d += n;
  800b89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	09 fe                	or     %edi,%esi
  800b90:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b96:	75 13                	jne    800bab <memmove+0x3b>
  800b98:	f6 c1 03             	test   $0x3,%cl
  800b9b:	75 0e                	jne    800bab <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b9d:	83 ef 04             	sub    $0x4,%edi
  800ba0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba3:	c1 e9 02             	shr    $0x2,%ecx
  800ba6:	fd                   	std    
  800ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba9:	eb 09                	jmp    800bb4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bab:	83 ef 01             	sub    $0x1,%edi
  800bae:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bb1:	fd                   	std    
  800bb2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb4:	fc                   	cld    
  800bb5:	eb 1d                	jmp    800bd4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb7:	89 f2                	mov    %esi,%edx
  800bb9:	09 c2                	or     %eax,%edx
  800bbb:	f6 c2 03             	test   $0x3,%dl
  800bbe:	75 0f                	jne    800bcf <memmove+0x5f>
  800bc0:	f6 c1 03             	test   $0x3,%cl
  800bc3:	75 0a                	jne    800bcf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bc5:	c1 e9 02             	shr    $0x2,%ecx
  800bc8:	89 c7                	mov    %eax,%edi
  800bca:	fc                   	cld    
  800bcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcd:	eb 05                	jmp    800bd4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bcf:	89 c7                	mov    %eax,%edi
  800bd1:	fc                   	cld    
  800bd2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bdb:	ff 75 10             	pushl  0x10(%ebp)
  800bde:	ff 75 0c             	pushl  0xc(%ebp)
  800be1:	ff 75 08             	pushl  0x8(%ebp)
  800be4:	e8 87 ff ff ff       	call   800b70 <memmove>
}
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf7:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	74 39                	je     800c37 <memcmp+0x4c>
  800bfe:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c01:	0f b6 13             	movzbl (%ebx),%edx
  800c04:	0f b6 0e             	movzbl (%esi),%ecx
  800c07:	38 ca                	cmp    %cl,%dl
  800c09:	75 17                	jne    800c22 <memcmp+0x37>
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c10:	eb 1a                	jmp    800c2c <memcmp+0x41>
  800c12:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c17:	83 c0 01             	add    $0x1,%eax
  800c1a:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c1e:	38 ca                	cmp    %cl,%dl
  800c20:	74 0a                	je     800c2c <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c22:	0f b6 c2             	movzbl %dl,%eax
  800c25:	0f b6 c9             	movzbl %cl,%ecx
  800c28:	29 c8                	sub    %ecx,%eax
  800c2a:	eb 10                	jmp    800c3c <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2c:	39 f8                	cmp    %edi,%eax
  800c2e:	75 e2                	jne    800c12 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c30:	b8 00 00 00 00       	mov    $0x0,%eax
  800c35:	eb 05                	jmp    800c3c <memcmp+0x51>
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	53                   	push   %ebx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c48:	89 d0                	mov    %edx,%eax
  800c4a:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c4d:	39 c2                	cmp    %eax,%edx
  800c4f:	73 1d                	jae    800c6e <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c51:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c55:	0f b6 0a             	movzbl (%edx),%ecx
  800c58:	39 d9                	cmp    %ebx,%ecx
  800c5a:	75 09                	jne    800c65 <memfind+0x24>
  800c5c:	eb 14                	jmp    800c72 <memfind+0x31>
  800c5e:	0f b6 0a             	movzbl (%edx),%ecx
  800c61:	39 d9                	cmp    %ebx,%ecx
  800c63:	74 11                	je     800c76 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c65:	83 c2 01             	add    $0x1,%edx
  800c68:	39 d0                	cmp    %edx,%eax
  800c6a:	75 f2                	jne    800c5e <memfind+0x1d>
  800c6c:	eb 0a                	jmp    800c78 <memfind+0x37>
  800c6e:	89 d0                	mov    %edx,%eax
  800c70:	eb 06                	jmp    800c78 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c72:	89 d0                	mov    %edx,%eax
  800c74:	eb 02                	jmp    800c78 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c76:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c78:	5b                   	pop    %ebx
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c87:	0f b6 01             	movzbl (%ecx),%eax
  800c8a:	3c 20                	cmp    $0x20,%al
  800c8c:	74 04                	je     800c92 <strtol+0x17>
  800c8e:	3c 09                	cmp    $0x9,%al
  800c90:	75 0e                	jne    800ca0 <strtol+0x25>
		s++;
  800c92:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c95:	0f b6 01             	movzbl (%ecx),%eax
  800c98:	3c 20                	cmp    $0x20,%al
  800c9a:	74 f6                	je     800c92 <strtol+0x17>
  800c9c:	3c 09                	cmp    $0x9,%al
  800c9e:	74 f2                	je     800c92 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca0:	3c 2b                	cmp    $0x2b,%al
  800ca2:	75 0a                	jne    800cae <strtol+0x33>
		s++;
  800ca4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca7:	bf 00 00 00 00       	mov    $0x0,%edi
  800cac:	eb 11                	jmp    800cbf <strtol+0x44>
  800cae:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb3:	3c 2d                	cmp    $0x2d,%al
  800cb5:	75 08                	jne    800cbf <strtol+0x44>
		s++, neg = 1;
  800cb7:	83 c1 01             	add    $0x1,%ecx
  800cba:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc5:	75 15                	jne    800cdc <strtol+0x61>
  800cc7:	80 39 30             	cmpb   $0x30,(%ecx)
  800cca:	75 10                	jne    800cdc <strtol+0x61>
  800ccc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd0:	75 7c                	jne    800d4e <strtol+0xd3>
		s += 2, base = 16;
  800cd2:	83 c1 02             	add    $0x2,%ecx
  800cd5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cda:	eb 16                	jmp    800cf2 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cdc:	85 db                	test   %ebx,%ebx
  800cde:	75 12                	jne    800cf2 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce8:	75 08                	jne    800cf2 <strtol+0x77>
		s++, base = 8;
  800cea:	83 c1 01             	add    $0x1,%ecx
  800ced:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cfa:	0f b6 11             	movzbl (%ecx),%edx
  800cfd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d00:	89 f3                	mov    %esi,%ebx
  800d02:	80 fb 09             	cmp    $0x9,%bl
  800d05:	77 08                	ja     800d0f <strtol+0x94>
			dig = *s - '0';
  800d07:	0f be d2             	movsbl %dl,%edx
  800d0a:	83 ea 30             	sub    $0x30,%edx
  800d0d:	eb 22                	jmp    800d31 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d12:	89 f3                	mov    %esi,%ebx
  800d14:	80 fb 19             	cmp    $0x19,%bl
  800d17:	77 08                	ja     800d21 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d19:	0f be d2             	movsbl %dl,%edx
  800d1c:	83 ea 57             	sub    $0x57,%edx
  800d1f:	eb 10                	jmp    800d31 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d21:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d24:	89 f3                	mov    %esi,%ebx
  800d26:	80 fb 19             	cmp    $0x19,%bl
  800d29:	77 16                	ja     800d41 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d2b:	0f be d2             	movsbl %dl,%edx
  800d2e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d34:	7d 0b                	jge    800d41 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d36:	83 c1 01             	add    $0x1,%ecx
  800d39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d3d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d3f:	eb b9                	jmp    800cfa <strtol+0x7f>

	if (endptr)
  800d41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d45:	74 0d                	je     800d54 <strtol+0xd9>
		*endptr = (char *) s;
  800d47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d4a:	89 0e                	mov    %ecx,(%esi)
  800d4c:	eb 06                	jmp    800d54 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d4e:	85 db                	test   %ebx,%ebx
  800d50:	74 98                	je     800cea <strtol+0x6f>
  800d52:	eb 9e                	jmp    800cf2 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d54:	89 c2                	mov    %eax,%edx
  800d56:	f7 da                	neg    %edx
  800d58:	85 ff                	test   %edi,%edi
  800d5a:	0f 45 c2             	cmovne %edx,%eax
}
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d67:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 c3                	mov    %eax,%ebx
  800d74:	89 c7                	mov    %eax,%edi
  800d76:	51                   	push   %ecx
  800d77:	52                   	push   %edx
  800d78:	53                   	push   %ebx
  800d79:	54                   	push   %esp
  800d7a:	55                   	push   %ebp
  800d7b:	56                   	push   %esi
  800d7c:	57                   	push   %edi
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	8d 35 87 0d 80 00    	lea    0x800d87,%esi
  800d85:	0f 34                	sysenter 

00800d87 <label_21>:
  800d87:	5f                   	pop    %edi
  800d88:	5e                   	pop    %esi
  800d89:	5d                   	pop    %ebp
  800d8a:	5c                   	pop    %esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5a                   	pop    %edx
  800d8d:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800da1:	89 ca                	mov    %ecx,%edx
  800da3:	89 cb                	mov    %ecx,%ebx
  800da5:	89 cf                	mov    %ecx,%edi
  800da7:	51                   	push   %ecx
  800da8:	52                   	push   %edx
  800da9:	53                   	push   %ebx
  800daa:	54                   	push   %esp
  800dab:	55                   	push   %ebp
  800dac:	56                   	push   %esi
  800dad:	57                   	push   %edi
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	8d 35 b8 0d 80 00    	lea    0x800db8,%esi
  800db6:	0f 34                	sysenter 

00800db8 <label_55>:
  800db8:	5f                   	pop    %edi
  800db9:	5e                   	pop    %esi
  800dba:	5d                   	pop    %ebp
  800dbb:	5c                   	pop    %esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5a                   	pop    %edx
  800dbe:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 d9                	mov    %ebx,%ecx
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	51                   	push   %ecx
  800dda:	52                   	push   %edx
  800ddb:	53                   	push   %ebx
  800ddc:	54                   	push   %esp
  800ddd:	55                   	push   %ebp
  800dde:	56                   	push   %esi
  800ddf:	57                   	push   %edi
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	8d 35 ea 0d 80 00    	lea    0x800dea,%esi
  800de8:	0f 34                	sysenter 

00800dea <label_90>:
  800dea:	5f                   	pop    %edi
  800deb:	5e                   	pop    %esi
  800dec:	5d                   	pop    %ebp
  800ded:	5c                   	pop    %esp
  800dee:	5b                   	pop    %ebx
  800def:	5a                   	pop    %edx
  800df0:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 17                	jle    800e0c <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	50                   	push   %eax
  800df9:	6a 03                	push   $0x3
  800dfb:	68 e4 16 80 00       	push   $0x8016e4
  800e00:	6a 2a                	push   $0x2a
  800e02:	68 01 17 80 00       	push   $0x801701
  800e07:	e8 e5 02 00 00       	call   8010f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e22:	89 ca                	mov    %ecx,%edx
  800e24:	89 cb                	mov    %ecx,%ebx
  800e26:	89 cf                	mov    %ecx,%edi
  800e28:	51                   	push   %ecx
  800e29:	52                   	push   %edx
  800e2a:	53                   	push   %ebx
  800e2b:	54                   	push   %esp
  800e2c:	55                   	push   %ebp
  800e2d:	56                   	push   %esi
  800e2e:	57                   	push   %edi
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	8d 35 39 0e 80 00    	lea    0x800e39,%esi
  800e37:	0f 34                	sysenter 

00800e39 <label_139>:
  800e39:	5f                   	pop    %edi
  800e3a:	5e                   	pop    %esi
  800e3b:	5d                   	pop    %ebp
  800e3c:	5c                   	pop    %esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5a                   	pop    %edx
  800e3f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e40:	5b                   	pop    %ebx
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e49:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 fb                	mov    %edi,%ebx
  800e5b:	51                   	push   %ecx
  800e5c:	52                   	push   %edx
  800e5d:	53                   	push   %ebx
  800e5e:	54                   	push   %esp
  800e5f:	55                   	push   %ebp
  800e60:	56                   	push   %esi
  800e61:	57                   	push   %edi
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	8d 35 6c 0e 80 00    	lea    0x800e6c,%esi
  800e6a:	0f 34                	sysenter 

00800e6c <label_174>:
  800e6c:	5f                   	pop    %edi
  800e6d:	5e                   	pop    %esi
  800e6e:	5d                   	pop    %ebp
  800e6f:	5c                   	pop    %esp
  800e70:	5b                   	pop    %ebx
  800e71:	5a                   	pop    %edx
  800e72:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e73:	5b                   	pop    %ebx
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_yield>:

void
sys_yield(void)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e86:	89 d1                	mov    %edx,%ecx
  800e88:	89 d3                	mov    %edx,%ebx
  800e8a:	89 d7                	mov    %edx,%edi
  800e8c:	51                   	push   %ecx
  800e8d:	52                   	push   %edx
  800e8e:	53                   	push   %ebx
  800e8f:	54                   	push   %esp
  800e90:	55                   	push   %ebp
  800e91:	56                   	push   %esi
  800e92:	57                   	push   %edi
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	8d 35 9d 0e 80 00    	lea    0x800e9d,%esi
  800e9b:	0f 34                	sysenter 

00800e9d <label_209>:
  800e9d:	5f                   	pop    %edi
  800e9e:	5e                   	pop    %esi
  800e9f:	5d                   	pop    %ebp
  800ea0:	5c                   	pop    %esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5a                   	pop    %edx
  800ea3:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ead:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec0:	51                   	push   %ecx
  800ec1:	52                   	push   %edx
  800ec2:	53                   	push   %ebx
  800ec3:	54                   	push   %esp
  800ec4:	55                   	push   %ebp
  800ec5:	56                   	push   %esi
  800ec6:	57                   	push   %edi
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	8d 35 d1 0e 80 00    	lea    0x800ed1,%esi
  800ecf:	0f 34                	sysenter 

00800ed1 <label_244>:
  800ed1:	5f                   	pop    %edi
  800ed2:	5e                   	pop    %esi
  800ed3:	5d                   	pop    %ebp
  800ed4:	5c                   	pop    %esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5a                   	pop    %edx
  800ed7:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 17                	jle    800ef3 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	50                   	push   %eax
  800ee0:	6a 05                	push   $0x5
  800ee2:	68 e4 16 80 00       	push   $0x8016e4
  800ee7:	6a 2a                	push   $0x2a
  800ee9:	68 01 17 80 00       	push   $0x801701
  800eee:	e8 fe 01 00 00       	call   8010f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ef3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	57                   	push   %edi
  800efe:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eff:	b8 06 00 00 00       	mov    $0x6,%eax
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f10:	51                   	push   %ecx
  800f11:	52                   	push   %edx
  800f12:	53                   	push   %ebx
  800f13:	54                   	push   %esp
  800f14:	55                   	push   %ebp
  800f15:	56                   	push   %esi
  800f16:	57                   	push   %edi
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	8d 35 21 0f 80 00    	lea    0x800f21,%esi
  800f1f:	0f 34                	sysenter 

00800f21 <label_295>:
  800f21:	5f                   	pop    %edi
  800f22:	5e                   	pop    %esi
  800f23:	5d                   	pop    %ebp
  800f24:	5c                   	pop    %esp
  800f25:	5b                   	pop    %ebx
  800f26:	5a                   	pop    %edx
  800f27:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	7e 17                	jle    800f43 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	50                   	push   %eax
  800f30:	6a 06                	push   $0x6
  800f32:	68 e4 16 80 00       	push   $0x8016e4
  800f37:	6a 2a                	push   $0x2a
  800f39:	68 01 17 80 00       	push   $0x801701
  800f3e:	e8 ae 01 00 00       	call   8010f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f54:	b8 07 00 00 00       	mov    $0x7,%eax
  800f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5f:	89 fb                	mov    %edi,%ebx
  800f61:	51                   	push   %ecx
  800f62:	52                   	push   %edx
  800f63:	53                   	push   %ebx
  800f64:	54                   	push   %esp
  800f65:	55                   	push   %ebp
  800f66:	56                   	push   %esi
  800f67:	57                   	push   %edi
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	8d 35 72 0f 80 00    	lea    0x800f72,%esi
  800f70:	0f 34                	sysenter 

00800f72 <label_344>:
  800f72:	5f                   	pop    %edi
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	5c                   	pop    %esp
  800f76:	5b                   	pop    %ebx
  800f77:	5a                   	pop    %edx
  800f78:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	7e 17                	jle    800f94 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800f7d:	83 ec 0c             	sub    $0xc,%esp
  800f80:	50                   	push   %eax
  800f81:	6a 07                	push   $0x7
  800f83:	68 e4 16 80 00       	push   $0x8016e4
  800f88:	6a 2a                	push   $0x2a
  800f8a:	68 01 17 80 00       	push   $0x801701
  800f8f:	e8 5d 01 00 00       	call   8010f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fa5:	b8 09 00 00 00       	mov    $0x9,%eax
  800faa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fad:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb0:	89 fb                	mov    %edi,%ebx
  800fb2:	51                   	push   %ecx
  800fb3:	52                   	push   %edx
  800fb4:	53                   	push   %ebx
  800fb5:	54                   	push   %esp
  800fb6:	55                   	push   %ebp
  800fb7:	56                   	push   %esi
  800fb8:	57                   	push   %edi
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	8d 35 c3 0f 80 00    	lea    0x800fc3,%esi
  800fc1:	0f 34                	sysenter 

00800fc3 <label_393>:
  800fc3:	5f                   	pop    %edi
  800fc4:	5e                   	pop    %esi
  800fc5:	5d                   	pop    %ebp
  800fc6:	5c                   	pop    %esp
  800fc7:	5b                   	pop    %ebx
  800fc8:	5a                   	pop    %edx
  800fc9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 17                	jle    800fe5 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	50                   	push   %eax
  800fd2:	6a 09                	push   $0x9
  800fd4:	68 e4 16 80 00       	push   $0x8016e4
  800fd9:	6a 2a                	push   $0x2a
  800fdb:	68 01 17 80 00       	push   $0x801701
  800fe0:	e8 0c 01 00 00       	call   8010f1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	57                   	push   %edi
  800ff0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ff1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	89 fb                	mov    %edi,%ebx
  801003:	51                   	push   %ecx
  801004:	52                   	push   %edx
  801005:	53                   	push   %ebx
  801006:	54                   	push   %esp
  801007:	55                   	push   %ebp
  801008:	56                   	push   %esi
  801009:	57                   	push   %edi
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	8d 35 14 10 80 00    	lea    0x801014,%esi
  801012:	0f 34                	sysenter 

00801014 <label_442>:
  801014:	5f                   	pop    %edi
  801015:	5e                   	pop    %esi
  801016:	5d                   	pop    %ebp
  801017:	5c                   	pop    %esp
  801018:	5b                   	pop    %ebx
  801019:	5a                   	pop    %edx
  80101a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	7e 17                	jle    801036 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	50                   	push   %eax
  801023:	6a 0a                	push   $0xa
  801025:	68 e4 16 80 00       	push   $0x8016e4
  80102a:	6a 2a                	push   $0x2a
  80102c:	68 01 17 80 00       	push   $0x801701
  801031:	e8 bb 00 00 00       	call   8010f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801036:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801039:	5b                   	pop    %ebx
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	57                   	push   %edi
  801041:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801042:	b8 0c 00 00 00       	mov    $0xc,%eax
  801047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104a:	8b 55 08             	mov    0x8(%ebp),%edx
  80104d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801050:	8b 7d 14             	mov    0x14(%ebp),%edi
  801053:	51                   	push   %ecx
  801054:	52                   	push   %edx
  801055:	53                   	push   %ebx
  801056:	54                   	push   %esp
  801057:	55                   	push   %ebp
  801058:	56                   	push   %esi
  801059:	57                   	push   %edi
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	8d 35 64 10 80 00    	lea    0x801064,%esi
  801062:	0f 34                	sysenter 

00801064 <label_493>:
  801064:	5f                   	pop    %edi
  801065:	5e                   	pop    %esi
  801066:	5d                   	pop    %ebp
  801067:	5c                   	pop    %esp
  801068:	5b                   	pop    %ebx
  801069:	5a                   	pop    %edx
  80106a:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80106b:	5b                   	pop    %ebx
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801074:	bb 00 00 00 00       	mov    $0x0,%ebx
  801079:	b8 0d 00 00 00       	mov    $0xd,%eax
  80107e:	8b 55 08             	mov    0x8(%ebp),%edx
  801081:	89 d9                	mov    %ebx,%ecx
  801083:	89 df                	mov    %ebx,%edi
  801085:	51                   	push   %ecx
  801086:	52                   	push   %edx
  801087:	53                   	push   %ebx
  801088:	54                   	push   %esp
  801089:	55                   	push   %ebp
  80108a:	56                   	push   %esi
  80108b:	57                   	push   %edi
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	8d 35 96 10 80 00    	lea    0x801096,%esi
  801094:	0f 34                	sysenter 

00801096 <label_528>:
  801096:	5f                   	pop    %edi
  801097:	5e                   	pop    %esi
  801098:	5d                   	pop    %ebp
  801099:	5c                   	pop    %esp
  80109a:	5b                   	pop    %ebx
  80109b:	5a                   	pop    %edx
  80109c:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80109d:	85 c0                	test   %eax,%eax
  80109f:	7e 17                	jle    8010b8 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	50                   	push   %eax
  8010a5:	6a 0d                	push   $0xd
  8010a7:	68 e4 16 80 00       	push   $0x8016e4
  8010ac:	6a 2a                	push   $0x2a
  8010ae:	68 01 17 80 00       	push   $0x801701
  8010b3:	e8 39 00 00 00       	call   8010f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bb:	5b                   	pop    %ebx
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	57                   	push   %edi
  8010c3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c9:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d1:	89 cb                	mov    %ecx,%ebx
  8010d3:	89 cf                	mov    %ecx,%edi
  8010d5:	51                   	push   %ecx
  8010d6:	52                   	push   %edx
  8010d7:	53                   	push   %ebx
  8010d8:	54                   	push   %esp
  8010d9:	55                   	push   %ebp
  8010da:	56                   	push   %esi
  8010db:	57                   	push   %edi
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	8d 35 e6 10 80 00    	lea    0x8010e6,%esi
  8010e4:	0f 34                	sysenter 

008010e6 <label_577>:
  8010e6:	5f                   	pop    %edi
  8010e7:	5e                   	pop    %esi
  8010e8:	5d                   	pop    %ebp
  8010e9:	5c                   	pop    %esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5a                   	pop    %edx
  8010ec:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8010ed:	5b                   	pop    %ebx
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8010f9:	a1 14 20 80 00       	mov    0x802014,%eax
  8010fe:	85 c0                	test   %eax,%eax
  801100:	74 11                	je     801113 <_panic+0x22>
		cprintf("%s: ", argv0);
  801102:	83 ec 08             	sub    $0x8,%esp
  801105:	50                   	push   %eax
  801106:	68 0f 17 80 00       	push   $0x80170f
  80110b:	e8 3b f0 ff ff       	call   80014b <cprintf>
  801110:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801113:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801119:	e8 f5 fc ff ff       	call   800e13 <sys_getenvid>
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	ff 75 0c             	pushl  0xc(%ebp)
  801124:	ff 75 08             	pushl  0x8(%ebp)
  801127:	56                   	push   %esi
  801128:	50                   	push   %eax
  801129:	68 14 17 80 00       	push   $0x801714
  80112e:	e8 18 f0 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801133:	83 c4 18             	add    $0x18,%esp
  801136:	53                   	push   %ebx
  801137:	ff 75 10             	pushl  0x10(%ebp)
  80113a:	e8 bb ef ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  80113f:	c7 04 24 0c 14 80 00 	movl   $0x80140c,(%esp)
  801146:	e8 00 f0 ff ff       	call   80014b <cprintf>
  80114b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80114e:	cc                   	int3   
  80114f:	eb fd                	jmp    80114e <_panic+0x5d>
  801151:	66 90                	xchg   %ax,%ax
  801153:	66 90                	xchg   %ax,%ax
  801155:	66 90                	xchg   %ax,%ax
  801157:	66 90                	xchg   %ax,%ax
  801159:	66 90                	xchg   %ax,%ax
  80115b:	66 90                	xchg   %ax,%ax
  80115d:	66 90                	xchg   %ax,%ax
  80115f:	90                   	nop

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
