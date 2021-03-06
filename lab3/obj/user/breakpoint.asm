
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 48 00 00 00       	call   800079 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 20             	sub    $0x20,%esp
	int a;
	a=10;
  800039:	c7 45 f4 0a 00 00 00 	movl   $0xa,-0xc(%ebp)
	cprintf("At first , a equals %d\n",a);
  800040:	6a 0a                	push   $0xa
  800042:	68 b4 11 80 00       	push   $0x8011b4
  800047:	e8 18 01 00 00       	call   800164 <cprintf>
	cprintf("&a equals 0x%x\n",&a);
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	68 cc 11 80 00       	push   $0x8011cc
  800058:	e8 07 01 00 00       	call   800164 <cprintf>
	asm volatile("int $3");
  80005d:	cc                   	int3   
	// Try single-step here
	a=20;
  80005e:	c7 45 f4 14 00 00 00 	movl   $0x14,-0xc(%ebp)
	cprintf("Finally , a equals %d\n",a);
  800065:	83 c4 08             	add    $0x8,%esp
  800068:	6a 14                	push   $0x14
  80006a:	68 dc 11 80 00       	push   $0x8011dc
  80006f:	e8 f0 00 00 00       	call   800164 <cprintf>
}
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	c9                   	leave  
  800078:	c3                   	ret    

00800079 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800079:	55                   	push   %ebp
  80007a:	89 e5                	mov    %esp,%ebp
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800081:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800084:	e8 a3 0d 00 00       	call   800e2c <sys_getenvid>
  800089:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008e:	6b c0 64             	imul   $0x64,%eax,%eax
  800091:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800096:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 db                	test   %ebx,%ebx
  80009d:	7e 07                	jle    8000a6 <libmain+0x2d>
		binaryname = argv[0];
  80009f:	8b 06                	mov    (%esi),%eax
  8000a1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a6:	83 ec 08             	sub    $0x8,%esp
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
  8000ab:	e8 83 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b0:	e8 0a 00 00 00       	call   8000bf <exit>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000c5:	6a 00                	push   $0x0
  8000c7:	e8 10 0d 00 00       	call   800ddc <sys_env_destroy>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 04             	sub    $0x4,%esp
  8000d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000db:	8b 13                	mov    (%ebx),%edx
  8000dd:	8d 42 01             	lea    0x1(%edx),%eax
  8000e0:	89 03                	mov    %eax,(%ebx)
  8000e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ee:	75 1a                	jne    80010a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	68 ff 00 00 00       	push   $0xff
  8000f8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fb:	50                   	push   %eax
  8000fc:	e8 7a 0c 00 00       	call   800d7b <sys_cputs>
		b->idx = 0;
  800101:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800107:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80010a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800111:	c9                   	leave  
  800112:	c3                   	ret    

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	ff 75 0c             	pushl  0xc(%ebp)
  800133:	ff 75 08             	pushl  0x8(%ebp)
  800136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013c:	50                   	push   %eax
  80013d:	68 d1 00 80 00       	push   $0x8000d1
  800142:	e8 c0 02 00 00       	call   800407 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	83 c4 08             	add    $0x8,%esp
  80014a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800150:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800156:	50                   	push   %eax
  800157:	e8 1f 0c 00 00       	call   800d7b <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	50                   	push   %eax
  80016e:	ff 75 08             	pushl  0x8(%ebp)
  800171:	e8 9d ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 1c             	sub    $0x1c,%esp
  800181:	89 c7                	mov    %eax,%edi
  800183:	89 d6                	mov    %edx,%esi
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800191:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800194:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800198:	0f 85 bf 00 00 00    	jne    80025d <printnum+0xe5>
  80019e:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8001a4:	0f 8d de 00 00 00    	jge    800288 <printnum+0x110>
		judge_time_for_space = width;
  8001aa:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8001b0:	e9 d3 00 00 00       	jmp    800288 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001b5:	83 eb 01             	sub    $0x1,%ebx
  8001b8:	85 db                	test   %ebx,%ebx
  8001ba:	7f 37                	jg     8001f3 <printnum+0x7b>
  8001bc:	e9 ea 00 00 00       	jmp    8002ab <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8001c1:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001c4:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	83 ec 04             	sub    $0x4,%esp
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001dc:	e8 7f 0e 00 00       	call   801060 <__umoddi3>
  8001e1:	83 c4 14             	add    $0x14,%esp
  8001e4:	0f be 80 fd 11 80 00 	movsbl 0x8011fd(%eax),%eax
  8001eb:	50                   	push   %eax
  8001ec:	ff d7                	call   *%edi
  8001ee:	83 c4 10             	add    $0x10,%esp
  8001f1:	eb 16                	jmp    800209 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	ff 75 18             	pushl  0x18(%ebp)
  8001fa:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001fc:	83 c4 10             	add    $0x10,%esp
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	75 ef                	jne    8001f3 <printnum+0x7b>
  800204:	e9 a2 00 00 00       	jmp    8002ab <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800209:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  80020f:	0f 85 76 01 00 00    	jne    80038b <printnum+0x213>
		while(num_of_space-- > 0)
  800215:	a1 04 20 80 00       	mov    0x802004,%eax
  80021a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80021d:	89 15 04 20 80 00    	mov    %edx,0x802004
  800223:	85 c0                	test   %eax,%eax
  800225:	7e 1d                	jle    800244 <printnum+0xcc>
			putch(' ', putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	6a 20                	push   $0x20
  80022d:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80022f:	a1 04 20 80 00       	mov    0x802004,%eax
  800234:	8d 50 ff             	lea    -0x1(%eax),%edx
  800237:	89 15 04 20 80 00    	mov    %edx,0x802004
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	85 c0                	test   %eax,%eax
  800242:	7f e3                	jg     800227 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800244:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80024b:	00 00 00 
		judge_time_for_space = 0;
  80024e:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800255:	00 00 00 
	}
}
  800258:	e9 2e 01 00 00       	jmp    80038b <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025d:	8b 45 10             	mov    0x10(%ebp),%eax
  800260:	ba 00 00 00 00       	mov    $0x0,%edx
  800265:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800268:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80026b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800271:	83 fa 00             	cmp    $0x0,%edx
  800274:	0f 87 ba 00 00 00    	ja     800334 <printnum+0x1bc>
  80027a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80027d:	0f 83 b1 00 00 00    	jae    800334 <printnum+0x1bc>
  800283:	e9 2d ff ff ff       	jmp    8001b5 <printnum+0x3d>
  800288:	8b 45 10             	mov    0x10(%ebp),%eax
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
  800290:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800293:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800296:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800299:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80029c:	83 fa 00             	cmp    $0x0,%edx
  80029f:	77 37                	ja     8002d8 <printnum+0x160>
  8002a1:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002a4:	73 32                	jae    8002d8 <printnum+0x160>
  8002a6:	e9 16 ff ff ff       	jmp    8001c1 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	56                   	push   %esi
  8002af:	83 ec 04             	sub    $0x4,%esp
  8002b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002be:	e8 9d 0d 00 00       	call   801060 <__umoddi3>
  8002c3:	83 c4 14             	add    $0x14,%esp
  8002c6:	0f be 80 fd 11 80 00 	movsbl 0x8011fd(%eax),%eax
  8002cd:	50                   	push   %eax
  8002ce:	ff d7                	call   *%edi
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	e9 b3 00 00 00       	jmp    80038b <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	ff 75 18             	pushl  0x18(%ebp)
  8002de:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff 75 10             	pushl  0x10(%ebp)
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f4:	e8 37 0c 00 00       	call   800f30 <__udivdi3>
  8002f9:	83 c4 18             	add    $0x18,%esp
  8002fc:	52                   	push   %edx
  8002fd:	50                   	push   %eax
  8002fe:	89 f2                	mov    %esi,%edx
  800300:	89 f8                	mov    %edi,%eax
  800302:	e8 71 fe ff ff       	call   800178 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800307:	83 c4 18             	add    $0x18,%esp
  80030a:	56                   	push   %esi
  80030b:	83 ec 04             	sub    $0x4,%esp
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	ff 75 e4             	pushl  -0x1c(%ebp)
  800317:	ff 75 e0             	pushl  -0x20(%ebp)
  80031a:	e8 41 0d 00 00       	call   801060 <__umoddi3>
  80031f:	83 c4 14             	add    $0x14,%esp
  800322:	0f be 80 fd 11 80 00 	movsbl 0x8011fd(%eax),%eax
  800329:	50                   	push   %eax
  80032a:	ff d7                	call   *%edi
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	e9 d5 fe ff ff       	jmp    800209 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	ff 75 18             	pushl  0x18(%ebp)
  80033a:	83 eb 01             	sub    $0x1,%ebx
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	ff 75 dc             	pushl  -0x24(%ebp)
  800347:	ff 75 d8             	pushl  -0x28(%ebp)
  80034a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034d:	ff 75 e0             	pushl  -0x20(%ebp)
  800350:	e8 db 0b 00 00       	call   800f30 <__udivdi3>
  800355:	83 c4 18             	add    $0x18,%esp
  800358:	52                   	push   %edx
  800359:	50                   	push   %eax
  80035a:	89 f2                	mov    %esi,%edx
  80035c:	89 f8                	mov    %edi,%eax
  80035e:	e8 15 fe ff ff       	call   800178 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800363:	83 c4 18             	add    $0x18,%esp
  800366:	56                   	push   %esi
  800367:	83 ec 04             	sub    $0x4,%esp
  80036a:	ff 75 dc             	pushl  -0x24(%ebp)
  80036d:	ff 75 d8             	pushl  -0x28(%ebp)
  800370:	ff 75 e4             	pushl  -0x1c(%ebp)
  800373:	ff 75 e0             	pushl  -0x20(%ebp)
  800376:	e8 e5 0c 00 00       	call   801060 <__umoddi3>
  80037b:	83 c4 14             	add    $0x14,%esp
  80037e:	0f be 80 fd 11 80 00 	movsbl 0x8011fd(%eax),%eax
  800385:	50                   	push   %eax
  800386:	ff d7                	call   *%edi
  800388:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80038b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800396:	83 fa 01             	cmp    $0x1,%edx
  800399:	7e 0e                	jle    8003a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	8b 52 04             	mov    0x4(%edx),%edx
  8003a7:	eb 22                	jmp    8003cb <getuint+0x38>
	else if (lflag)
  8003a9:	85 d2                	test   %edx,%edx
  8003ab:	74 10                	je     8003bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b2:	89 08                	mov    %ecx,(%eax)
  8003b4:	8b 02                	mov    (%edx),%eax
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bb:	eb 0e                	jmp    8003cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003bd:	8b 10                	mov    (%eax),%edx
  8003bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 02                	mov    (%edx),%eax
  8003c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d7:	8b 10                	mov    (%eax),%edx
  8003d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003dc:	73 0a                	jae    8003e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	88 02                	mov    %al,(%edx)
}
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f3:	50                   	push   %eax
  8003f4:	ff 75 10             	pushl  0x10(%ebp)
  8003f7:	ff 75 0c             	pushl  0xc(%ebp)
  8003fa:	ff 75 08             	pushl  0x8(%ebp)
  8003fd:	e8 05 00 00 00       	call   800407 <vprintfmt>
	va_end(ap);
}
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	c9                   	leave  
  800406:	c3                   	ret    

00800407 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	57                   	push   %edi
  80040b:	56                   	push   %esi
  80040c:	53                   	push   %ebx
  80040d:	83 ec 2c             	sub    $0x2c,%esp
  800410:	8b 7d 08             	mov    0x8(%ebp),%edi
  800413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800416:	eb 03                	jmp    80041b <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800418:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	8b 45 10             	mov    0x10(%ebp),%eax
  80041e:	8d 70 01             	lea    0x1(%eax),%esi
  800421:	0f b6 00             	movzbl (%eax),%eax
  800424:	83 f8 25             	cmp    $0x25,%eax
  800427:	74 27                	je     800450 <vprintfmt+0x49>
			if (ch == '\0')
  800429:	85 c0                	test   %eax,%eax
  80042b:	75 0d                	jne    80043a <vprintfmt+0x33>
  80042d:	e9 9d 04 00 00       	jmp    8008cf <vprintfmt+0x4c8>
  800432:	85 c0                	test   %eax,%eax
  800434:	0f 84 95 04 00 00    	je     8008cf <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	50                   	push   %eax
  80043f:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800441:	83 c6 01             	add    $0x1,%esi
  800444:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	83 f8 25             	cmp    $0x25,%eax
  80044e:	75 e2                	jne    800432 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800450:	b9 00 00 00 00       	mov    $0x0,%ecx
  800455:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800459:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800460:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800467:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80046e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800475:	eb 08                	jmp    80047f <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80047a:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8d 46 01             	lea    0x1(%esi),%eax
  800482:	89 45 10             	mov    %eax,0x10(%ebp)
  800485:	0f b6 06             	movzbl (%esi),%eax
  800488:	0f b6 d0             	movzbl %al,%edx
  80048b:	83 e8 23             	sub    $0x23,%eax
  80048e:	3c 55                	cmp    $0x55,%al
  800490:	0f 87 fa 03 00 00    	ja     800890 <vprintfmt+0x489>
  800496:	0f b6 c0             	movzbl %al,%eax
  800499:	ff 24 85 08 13 80 00 	jmp    *0x801308(,%eax,4)
  8004a0:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a3:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8004a7:	eb d6                	jmp    80047f <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a9:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004af:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004b3:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b6:	83 fa 09             	cmp    $0x9,%edx
  8004b9:	77 6b                	ja     800526 <vprintfmt+0x11f>
  8004bb:	8b 75 10             	mov    0x10(%ebp),%esi
  8004be:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004c1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004c4:	eb 09                	jmp    8004cf <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c9:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8004cd:	eb b0                	jmp    80047f <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004cf:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004d2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004d5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004d9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004dc:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004df:	83 f9 09             	cmp    $0x9,%ecx
  8004e2:	76 eb                	jbe    8004cf <vprintfmt+0xc8>
  8004e4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004e7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ea:	eb 3d                	jmp    800529 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 50 04             	lea    0x4(%eax),%edx
  8004f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fd:	eb 2a                	jmp    800529 <vprintfmt+0x122>
  8004ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800502:	85 c0                	test   %eax,%eax
  800504:	ba 00 00 00 00       	mov    $0x0,%edx
  800509:	0f 49 d0             	cmovns %eax,%edx
  80050c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 10             	mov    0x10(%ebp),%esi
  800512:	e9 68 ff ff ff       	jmp    80047f <vprintfmt+0x78>
  800517:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800521:	e9 59 ff ff ff       	jmp    80047f <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800529:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052d:	0f 89 4c ff ff ff    	jns    80047f <vprintfmt+0x78>
				width = precision, precision = -1;
  800533:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800536:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800539:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800540:	e9 3a ff ff ff       	jmp    80047f <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800545:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054c:	e9 2e ff ff ff       	jmp    80047f <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	ff 30                	pushl  (%eax)
  800560:	ff d7                	call   *%edi
			break;
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	e9 b1 fe ff ff       	jmp    80041b <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 04             	lea    0x4(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 00                	mov    (%eax),%eax
  800575:	99                   	cltd   
  800576:	31 d0                	xor    %edx,%eax
  800578:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057a:	83 f8 06             	cmp    $0x6,%eax
  80057d:	7f 0b                	jg     80058a <vprintfmt+0x183>
  80057f:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800586:	85 d2                	test   %edx,%edx
  800588:	75 15                	jne    80059f <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80058a:	50                   	push   %eax
  80058b:	68 15 12 80 00       	push   $0x801215
  800590:	53                   	push   %ebx
  800591:	57                   	push   %edi
  800592:	e8 53 fe ff ff       	call   8003ea <printfmt>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	e9 7c fe ff ff       	jmp    80041b <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80059f:	52                   	push   %edx
  8005a0:	68 1e 12 80 00       	push   $0x80121e
  8005a5:	53                   	push   %ebx
  8005a6:	57                   	push   %edi
  8005a7:	e8 3e fe ff ff       	call   8003ea <printfmt>
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	e9 67 fe ff ff       	jmp    80041b <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	b9 0e 12 80 00       	mov    $0x80120e,%ecx
  8005c6:	0f 45 c8             	cmovne %eax,%ecx
  8005c9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d0:	7e 06                	jle    8005d8 <vprintfmt+0x1d1>
  8005d2:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005d6:	75 19                	jne    8005f1 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005db:	8d 70 01             	lea    0x1(%eax),%esi
  8005de:	0f b6 00             	movzbl (%eax),%eax
  8005e1:	0f be d0             	movsbl %al,%edx
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	0f 85 9f 00 00 00    	jne    80068b <vprintfmt+0x284>
  8005ec:	e9 8c 00 00 00       	jmp    80067d <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f7:	ff 75 cc             	pushl  -0x34(%ebp)
  8005fa:	e8 62 03 00 00       	call   800961 <strnlen>
  8005ff:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800602:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	85 c9                	test   %ecx,%ecx
  80060a:	0f 8e a6 02 00 00    	jle    8008b6 <vprintfmt+0x4af>
					putch(padc, putdat);
  800610:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800614:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800617:	89 cb                	mov    %ecx,%ebx
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	ff 75 0c             	pushl  0xc(%ebp)
  80061f:	56                   	push   %esi
  800620:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	83 eb 01             	sub    $0x1,%ebx
  800628:	75 ef                	jne    800619 <vprintfmt+0x212>
  80062a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80062d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800630:	e9 81 02 00 00       	jmp    8008b6 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800635:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800639:	74 1b                	je     800656 <vprintfmt+0x24f>
  80063b:	0f be c0             	movsbl %al,%eax
  80063e:	83 e8 20             	sub    $0x20,%eax
  800641:	83 f8 5e             	cmp    $0x5e,%eax
  800644:	76 10                	jbe    800656 <vprintfmt+0x24f>
					putch('?', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	ff 75 0c             	pushl  0xc(%ebp)
  80064c:	6a 3f                	push   $0x3f
  80064e:	ff 55 08             	call   *0x8(%ebp)
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	eb 0d                	jmp    800663 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	ff 75 0c             	pushl  0xc(%ebp)
  80065c:	52                   	push   %edx
  80065d:	ff 55 08             	call   *0x8(%ebp)
  800660:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800663:	83 ef 01             	sub    $0x1,%edi
  800666:	83 c6 01             	add    $0x1,%esi
  800669:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80066d:	0f be d0             	movsbl %al,%edx
  800670:	85 d2                	test   %edx,%edx
  800672:	75 31                	jne    8006a5 <vprintfmt+0x29e>
  800674:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800677:	8b 7d 08             	mov    0x8(%ebp),%edi
  80067a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800680:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800684:	7f 33                	jg     8006b9 <vprintfmt+0x2b2>
  800686:	e9 90 fd ff ff       	jmp    80041b <vprintfmt+0x14>
  80068b:	89 7d 08             	mov    %edi,0x8(%ebp)
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800691:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800694:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800697:	eb 0c                	jmp    8006a5 <vprintfmt+0x29e>
  800699:	89 7d 08             	mov    %edi,0x8(%ebp)
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a5:	85 db                	test   %ebx,%ebx
  8006a7:	78 8c                	js     800635 <vprintfmt+0x22e>
  8006a9:	83 eb 01             	sub    $0x1,%ebx
  8006ac:	79 87                	jns    800635 <vprintfmt+0x22e>
  8006ae:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b7:	eb c4                	jmp    80067d <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 20                	push   $0x20
  8006bf:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	83 ee 01             	sub    $0x1,%esi
  8006c7:	75 f0                	jne    8006b9 <vprintfmt+0x2b2>
  8006c9:	e9 4d fd ff ff       	jmp    80041b <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ce:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8006d2:	7e 16                	jle    8006ea <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 08             	lea    0x8(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 50 04             	mov    0x4(%eax),%edx
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006e8:	eb 34                	jmp    80071e <vprintfmt+0x317>
	else if (lflag)
  8006ea:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006ee:	74 18                	je     800708 <vprintfmt+0x301>
		return va_arg(*ap, long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 04             	lea    0x4(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f9:	8b 30                	mov    (%eax),%esi
  8006fb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006fe:	89 f0                	mov    %esi,%eax
  800700:	c1 f8 1f             	sar    $0x1f,%eax
  800703:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800706:	eb 16                	jmp    80071e <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8d 50 04             	lea    0x4(%eax),%edx
  80070e:	89 55 14             	mov    %edx,0x14(%ebp)
  800711:	8b 30                	mov    (%eax),%esi
  800713:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800716:	89 f0                	mov    %esi,%eax
  800718:	c1 f8 1f             	sar    $0x1f,%eax
  80071b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800721:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800724:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800727:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80072a:	85 d2                	test   %edx,%edx
  80072c:	79 28                	jns    800756 <vprintfmt+0x34f>
				putch('-', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 2d                	push   $0x2d
  800734:	ff d7                	call   *%edi
				num = -(long long) num;
  800736:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800739:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80073c:	f7 d8                	neg    %eax
  80073e:	83 d2 00             	adc    $0x0,%edx
  800741:	f7 da                	neg    %edx
  800743:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800746:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800749:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  80074c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800751:	e9 b2 00 00 00       	jmp    800808 <vprintfmt+0x401>
  800756:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  80075b:	85 c9                	test   %ecx,%ecx
  80075d:	0f 84 a5 00 00 00    	je     800808 <vprintfmt+0x401>
				putch('+', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 2b                	push   $0x2b
  800769:	ff d7                	call   *%edi
  80076b:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800773:	e9 90 00 00 00       	jmp    800808 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800778:	85 c9                	test   %ecx,%ecx
  80077a:	74 0b                	je     800787 <vprintfmt+0x380>
				putch('+', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 2b                	push   $0x2b
  800782:	ff d7                	call   *%edi
  800784:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800787:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
  80078d:	e8 01 fc ff ff       	call   800393 <getuint>
  800792:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800795:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800798:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80079d:	eb 69                	jmp    800808 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 30                	push   $0x30
  8007a5:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007a7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ad:	e8 e1 fb ff ff       	call   800393 <getuint>
  8007b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8007b8:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007bb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007c0:	eb 46                	jmp    800808 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	53                   	push   %ebx
  8007c6:	6a 30                	push   $0x30
  8007c8:	ff d7                	call   *%edi
			putch('x', putdat);
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	53                   	push   %ebx
  8007ce:	6a 78                	push   $0x78
  8007d0:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007eb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f0:	eb 16                	jmp    800808 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f8:	e8 96 fb ff ff       	call   800393 <getuint>
  8007fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800800:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800803:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800808:	83 ec 0c             	sub    $0xc,%esp
  80080b:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80080f:	56                   	push   %esi
  800810:	ff 75 e4             	pushl  -0x1c(%ebp)
  800813:	50                   	push   %eax
  800814:	ff 75 dc             	pushl  -0x24(%ebp)
  800817:	ff 75 d8             	pushl  -0x28(%ebp)
  80081a:	89 da                	mov    %ebx,%edx
  80081c:	89 f8                	mov    %edi,%eax
  80081e:	e8 55 f9 ff ff       	call   800178 <printnum>
			break;
  800823:	83 c4 20             	add    $0x20,%esp
  800826:	e9 f0 fb ff ff       	jmp    80041b <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8d 50 04             	lea    0x4(%eax),%edx
  800831:	89 55 14             	mov    %edx,0x14(%ebp)
  800834:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800836:	85 f6                	test   %esi,%esi
  800838:	75 1a                	jne    800854 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	68 8c 12 80 00       	push   $0x80128c
  800842:	68 1e 12 80 00       	push   $0x80121e
  800847:	e8 18 f9 ff ff       	call   800164 <cprintf>
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	e9 c7 fb ff ff       	jmp    80041b <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800854:	0f b6 03             	movzbl (%ebx),%eax
  800857:	84 c0                	test   %al,%al
  800859:	79 1f                	jns    80087a <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	68 c4 12 80 00       	push   $0x8012c4
  800863:	68 1e 12 80 00       	push   $0x80121e
  800868:	e8 f7 f8 ff ff       	call   800164 <cprintf>
						*tmp = *(char *)putdat;
  80086d:	0f b6 03             	movzbl (%ebx),%eax
  800870:	88 06                	mov    %al,(%esi)
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	e9 a1 fb ff ff       	jmp    80041b <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  80087a:	88 06                	mov    %al,(%esi)
  80087c:	e9 9a fb ff ff       	jmp    80041b <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	53                   	push   %ebx
  800885:	52                   	push   %edx
  800886:	ff d7                	call   *%edi
			break;
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	e9 8b fb ff ff       	jmp    80041b <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	53                   	push   %ebx
  800894:	6a 25                	push   $0x25
  800896:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800898:	83 c4 10             	add    $0x10,%esp
  80089b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80089f:	0f 84 73 fb ff ff    	je     800418 <vprintfmt+0x11>
  8008a5:	83 ee 01             	sub    $0x1,%esi
  8008a8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008ac:	75 f7                	jne    8008a5 <vprintfmt+0x49e>
  8008ae:	89 75 10             	mov    %esi,0x10(%ebp)
  8008b1:	e9 65 fb ff ff       	jmp    80041b <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008b9:	8d 70 01             	lea    0x1(%eax),%esi
  8008bc:	0f b6 00             	movzbl (%eax),%eax
  8008bf:	0f be d0             	movsbl %al,%edx
  8008c2:	85 d2                	test   %edx,%edx
  8008c4:	0f 85 cf fd ff ff    	jne    800699 <vprintfmt+0x292>
  8008ca:	e9 4c fb ff ff       	jmp    80041b <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 18             	sub    $0x18,%esp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f4:	85 c0                	test   %eax,%eax
  8008f6:	74 26                	je     80091e <vsnprintf+0x47>
  8008f8:	85 d2                	test   %edx,%edx
  8008fa:	7e 22                	jle    80091e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008fc:	ff 75 14             	pushl  0x14(%ebp)
  8008ff:	ff 75 10             	pushl  0x10(%ebp)
  800902:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800905:	50                   	push   %eax
  800906:	68 cd 03 80 00       	push   $0x8003cd
  80090b:	e8 f7 fa ff ff       	call   800407 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800910:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800913:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	eb 05                	jmp    800923 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80091e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80092b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80092e:	50                   	push   %eax
  80092f:	ff 75 10             	pushl  0x10(%ebp)
  800932:	ff 75 0c             	pushl  0xc(%ebp)
  800935:	ff 75 08             	pushl  0x8(%ebp)
  800938:	e8 9a ff ff ff       	call   8008d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800945:	80 3a 00             	cmpb   $0x0,(%edx)
  800948:	74 10                	je     80095a <strlen+0x1b>
  80094a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80094f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800952:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800956:	75 f7                	jne    80094f <strlen+0x10>
  800958:	eb 05                	jmp    80095f <strlen+0x20>
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096b:	85 c9                	test   %ecx,%ecx
  80096d:	74 1c                	je     80098b <strnlen+0x2a>
  80096f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800972:	74 1e                	je     800992 <strnlen+0x31>
  800974:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800979:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097b:	39 ca                	cmp    %ecx,%edx
  80097d:	74 18                	je     800997 <strnlen+0x36>
  80097f:	83 c2 01             	add    $0x1,%edx
  800982:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800987:	75 f0                	jne    800979 <strnlen+0x18>
  800989:	eb 0c                	jmp    800997 <strnlen+0x36>
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
  800990:	eb 05                	jmp    800997 <strnlen+0x36>
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a4:	89 c2                	mov    %eax,%edx
  8009a6:	83 c2 01             	add    $0x1,%edx
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b3:	84 db                	test   %bl,%bl
  8009b5:	75 ef                	jne    8009a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	53                   	push   %ebx
  8009be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c1:	53                   	push   %ebx
  8009c2:	e8 78 ff ff ff       	call   80093f <strlen>
  8009c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009ca:	ff 75 0c             	pushl  0xc(%ebp)
  8009cd:	01 d8                	add    %ebx,%eax
  8009cf:	50                   	push   %eax
  8009d0:	e8 c5 ff ff ff       	call   80099a <strcpy>
	return dst;
}
  8009d5:	89 d8                	mov    %ebx,%eax
  8009d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ea:	85 db                	test   %ebx,%ebx
  8009ec:	74 17                	je     800a05 <strncpy+0x29>
  8009ee:	01 f3                	add    %esi,%ebx
  8009f0:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8009f2:	83 c1 01             	add    $0x1,%ecx
  8009f5:	0f b6 02             	movzbl (%edx),%eax
  8009f8:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009fb:	80 3a 01             	cmpb   $0x1,(%edx)
  8009fe:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a01:	39 cb                	cmp    %ecx,%ebx
  800a03:	75 ed                	jne    8009f2 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a05:	89 f0                	mov    %esi,%eax
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 75 08             	mov    0x8(%ebp),%esi
  800a13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a16:	8b 55 10             	mov    0x10(%ebp),%edx
  800a19:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a1b:	85 d2                	test   %edx,%edx
  800a1d:	74 35                	je     800a54 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a1f:	89 d0                	mov    %edx,%eax
  800a21:	83 e8 01             	sub    $0x1,%eax
  800a24:	74 25                	je     800a4b <strlcpy+0x40>
  800a26:	0f b6 0b             	movzbl (%ebx),%ecx
  800a29:	84 c9                	test   %cl,%cl
  800a2b:	74 22                	je     800a4f <strlcpy+0x44>
  800a2d:	8d 53 01             	lea    0x1(%ebx),%edx
  800a30:	01 c3                	add    %eax,%ebx
  800a32:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a3a:	39 da                	cmp    %ebx,%edx
  800a3c:	74 13                	je     800a51 <strlcpy+0x46>
  800a3e:	83 c2 01             	add    $0x1,%edx
  800a41:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a45:	84 c9                	test   %cl,%cl
  800a47:	75 eb                	jne    800a34 <strlcpy+0x29>
  800a49:	eb 06                	jmp    800a51 <strlcpy+0x46>
  800a4b:	89 f0                	mov    %esi,%eax
  800a4d:	eb 02                	jmp    800a51 <strlcpy+0x46>
  800a4f:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a54:	29 f0                	sub    %esi,%eax
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a60:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a63:	0f b6 01             	movzbl (%ecx),%eax
  800a66:	84 c0                	test   %al,%al
  800a68:	74 15                	je     800a7f <strcmp+0x25>
  800a6a:	3a 02                	cmp    (%edx),%al
  800a6c:	75 11                	jne    800a7f <strcmp+0x25>
		p++, q++;
  800a6e:	83 c1 01             	add    $0x1,%ecx
  800a71:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a74:	0f b6 01             	movzbl (%ecx),%eax
  800a77:	84 c0                	test   %al,%al
  800a79:	74 04                	je     800a7f <strcmp+0x25>
  800a7b:	3a 02                	cmp    (%edx),%al
  800a7d:	74 ef                	je     800a6e <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7f:	0f b6 c0             	movzbl %al,%eax
  800a82:	0f b6 12             	movzbl (%edx),%edx
  800a85:	29 d0                	sub    %edx,%eax
}
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
  800a8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a94:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a97:	85 f6                	test   %esi,%esi
  800a99:	74 29                	je     800ac4 <strncmp+0x3b>
  800a9b:	0f b6 03             	movzbl (%ebx),%eax
  800a9e:	84 c0                	test   %al,%al
  800aa0:	74 30                	je     800ad2 <strncmp+0x49>
  800aa2:	3a 02                	cmp    (%edx),%al
  800aa4:	75 2c                	jne    800ad2 <strncmp+0x49>
  800aa6:	8d 43 01             	lea    0x1(%ebx),%eax
  800aa9:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800aab:	89 c3                	mov    %eax,%ebx
  800aad:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab0:	39 c6                	cmp    %eax,%esi
  800ab2:	74 17                	je     800acb <strncmp+0x42>
  800ab4:	0f b6 08             	movzbl (%eax),%ecx
  800ab7:	84 c9                	test   %cl,%cl
  800ab9:	74 17                	je     800ad2 <strncmp+0x49>
  800abb:	83 c0 01             	add    $0x1,%eax
  800abe:	3a 0a                	cmp    (%edx),%cl
  800ac0:	74 e9                	je     800aab <strncmp+0x22>
  800ac2:	eb 0e                	jmp    800ad2 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	eb 0f                	jmp    800ada <strncmp+0x51>
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad0:	eb 08                	jmp    800ada <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad2:	0f b6 03             	movzbl (%ebx),%eax
  800ad5:	0f b6 12             	movzbl (%edx),%edx
  800ad8:	29 d0                	sub    %edx,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	53                   	push   %ebx
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ae8:	0f b6 10             	movzbl (%eax),%edx
  800aeb:	84 d2                	test   %dl,%dl
  800aed:	74 1d                	je     800b0c <strchr+0x2e>
  800aef:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800af1:	38 d3                	cmp    %dl,%bl
  800af3:	75 06                	jne    800afb <strchr+0x1d>
  800af5:	eb 1a                	jmp    800b11 <strchr+0x33>
  800af7:	38 ca                	cmp    %cl,%dl
  800af9:	74 16                	je     800b11 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	0f b6 10             	movzbl (%eax),%edx
  800b01:	84 d2                	test   %dl,%dl
  800b03:	75 f2                	jne    800af7 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0a:	eb 05                	jmp    800b11 <strchr+0x33>
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	53                   	push   %ebx
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b1e:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b21:	38 d3                	cmp    %dl,%bl
  800b23:	74 14                	je     800b39 <strfind+0x25>
  800b25:	89 d1                	mov    %edx,%ecx
  800b27:	84 db                	test   %bl,%bl
  800b29:	74 0e                	je     800b39 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b2b:	83 c0 01             	add    $0x1,%eax
  800b2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b31:	38 ca                	cmp    %cl,%dl
  800b33:	74 04                	je     800b39 <strfind+0x25>
  800b35:	84 d2                	test   %dl,%dl
  800b37:	75 f2                	jne    800b2b <strfind+0x17>
			break;
	return (char *) s;
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b48:	85 c9                	test   %ecx,%ecx
  800b4a:	74 36                	je     800b82 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b52:	75 28                	jne    800b7c <memset+0x40>
  800b54:	f6 c1 03             	test   $0x3,%cl
  800b57:	75 23                	jne    800b7c <memset+0x40>
		c &= 0xFF;
  800b59:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5d:	89 d3                	mov    %edx,%ebx
  800b5f:	c1 e3 08             	shl    $0x8,%ebx
  800b62:	89 d6                	mov    %edx,%esi
  800b64:	c1 e6 18             	shl    $0x18,%esi
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	c1 e0 10             	shl    $0x10,%eax
  800b6c:	09 f0                	or     %esi,%eax
  800b6e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b70:	89 d8                	mov    %ebx,%eax
  800b72:	09 d0                	or     %edx,%eax
  800b74:	c1 e9 02             	shr    $0x2,%ecx
  800b77:	fc                   	cld    
  800b78:	f3 ab                	rep stos %eax,%es:(%edi)
  800b7a:	eb 06                	jmp    800b82 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7f:	fc                   	cld    
  800b80:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b82:	89 f8                	mov    %edi,%eax
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b97:	39 c6                	cmp    %eax,%esi
  800b99:	73 35                	jae    800bd0 <memmove+0x47>
  800b9b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b9e:	39 d0                	cmp    %edx,%eax
  800ba0:	73 2e                	jae    800bd0 <memmove+0x47>
		s += n;
		d += n;
  800ba2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	09 fe                	or     %edi,%esi
  800ba9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800baf:	75 13                	jne    800bc4 <memmove+0x3b>
  800bb1:	f6 c1 03             	test   $0x3,%cl
  800bb4:	75 0e                	jne    800bc4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bb6:	83 ef 04             	sub    $0x4,%edi
  800bb9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bbc:	c1 e9 02             	shr    $0x2,%ecx
  800bbf:	fd                   	std    
  800bc0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc2:	eb 09                	jmp    800bcd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bc4:	83 ef 01             	sub    $0x1,%edi
  800bc7:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bca:	fd                   	std    
  800bcb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bcd:	fc                   	cld    
  800bce:	eb 1d                	jmp    800bed <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd0:	89 f2                	mov    %esi,%edx
  800bd2:	09 c2                	or     %eax,%edx
  800bd4:	f6 c2 03             	test   $0x3,%dl
  800bd7:	75 0f                	jne    800be8 <memmove+0x5f>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 0a                	jne    800be8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bde:	c1 e9 02             	shr    $0x2,%ecx
  800be1:	89 c7                	mov    %eax,%edi
  800be3:	fc                   	cld    
  800be4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be6:	eb 05                	jmp    800bed <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be8:	89 c7                	mov    %eax,%edi
  800bea:	fc                   	cld    
  800beb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bf4:	ff 75 10             	pushl  0x10(%ebp)
  800bf7:	ff 75 0c             	pushl  0xc(%ebp)
  800bfa:	ff 75 08             	pushl  0x8(%ebp)
  800bfd:	e8 87 ff ff ff       	call   800b89 <memmove>
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c10:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c13:	85 c0                	test   %eax,%eax
  800c15:	74 39                	je     800c50 <memcmp+0x4c>
  800c17:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c1a:	0f b6 13             	movzbl (%ebx),%edx
  800c1d:	0f b6 0e             	movzbl (%esi),%ecx
  800c20:	38 ca                	cmp    %cl,%dl
  800c22:	75 17                	jne    800c3b <memcmp+0x37>
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
  800c29:	eb 1a                	jmp    800c45 <memcmp+0x41>
  800c2b:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c30:	83 c0 01             	add    $0x1,%eax
  800c33:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c37:	38 ca                	cmp    %cl,%dl
  800c39:	74 0a                	je     800c45 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c3b:	0f b6 c2             	movzbl %dl,%eax
  800c3e:	0f b6 c9             	movzbl %cl,%ecx
  800c41:	29 c8                	sub    %ecx,%eax
  800c43:	eb 10                	jmp    800c55 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c45:	39 f8                	cmp    %edi,%eax
  800c47:	75 e2                	jne    800c2b <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c49:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4e:	eb 05                	jmp    800c55 <memcmp+0x51>
  800c50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	53                   	push   %ebx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c61:	89 d0                	mov    %edx,%eax
  800c63:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c66:	39 c2                	cmp    %eax,%edx
  800c68:	73 1d                	jae    800c87 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c6a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c6e:	0f b6 0a             	movzbl (%edx),%ecx
  800c71:	39 d9                	cmp    %ebx,%ecx
  800c73:	75 09                	jne    800c7e <memfind+0x24>
  800c75:	eb 14                	jmp    800c8b <memfind+0x31>
  800c77:	0f b6 0a             	movzbl (%edx),%ecx
  800c7a:	39 d9                	cmp    %ebx,%ecx
  800c7c:	74 11                	je     800c8f <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c7e:	83 c2 01             	add    $0x1,%edx
  800c81:	39 d0                	cmp    %edx,%eax
  800c83:	75 f2                	jne    800c77 <memfind+0x1d>
  800c85:	eb 0a                	jmp    800c91 <memfind+0x37>
  800c87:	89 d0                	mov    %edx,%eax
  800c89:	eb 06                	jmp    800c91 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8b:	89 d0                	mov    %edx,%eax
  800c8d:	eb 02                	jmp    800c91 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8f:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c91:	5b                   	pop    %ebx
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca0:	0f b6 01             	movzbl (%ecx),%eax
  800ca3:	3c 20                	cmp    $0x20,%al
  800ca5:	74 04                	je     800cab <strtol+0x17>
  800ca7:	3c 09                	cmp    $0x9,%al
  800ca9:	75 0e                	jne    800cb9 <strtol+0x25>
		s++;
  800cab:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cae:	0f b6 01             	movzbl (%ecx),%eax
  800cb1:	3c 20                	cmp    $0x20,%al
  800cb3:	74 f6                	je     800cab <strtol+0x17>
  800cb5:	3c 09                	cmp    $0x9,%al
  800cb7:	74 f2                	je     800cab <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb9:	3c 2b                	cmp    $0x2b,%al
  800cbb:	75 0a                	jne    800cc7 <strtol+0x33>
		s++;
  800cbd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc5:	eb 11                	jmp    800cd8 <strtol+0x44>
  800cc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ccc:	3c 2d                	cmp    $0x2d,%al
  800cce:	75 08                	jne    800cd8 <strtol+0x44>
		s++, neg = 1;
  800cd0:	83 c1 01             	add    $0x1,%ecx
  800cd3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cde:	75 15                	jne    800cf5 <strtol+0x61>
  800ce0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce3:	75 10                	jne    800cf5 <strtol+0x61>
  800ce5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ce9:	75 7c                	jne    800d67 <strtol+0xd3>
		s += 2, base = 16;
  800ceb:	83 c1 02             	add    $0x2,%ecx
  800cee:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf3:	eb 16                	jmp    800d0b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cf5:	85 db                	test   %ebx,%ebx
  800cf7:	75 12                	jne    800d0b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfe:	80 39 30             	cmpb   $0x30,(%ecx)
  800d01:	75 08                	jne    800d0b <strtol+0x77>
		s++, base = 8;
  800d03:	83 c1 01             	add    $0x1,%ecx
  800d06:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d10:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d13:	0f b6 11             	movzbl (%ecx),%edx
  800d16:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d19:	89 f3                	mov    %esi,%ebx
  800d1b:	80 fb 09             	cmp    $0x9,%bl
  800d1e:	77 08                	ja     800d28 <strtol+0x94>
			dig = *s - '0';
  800d20:	0f be d2             	movsbl %dl,%edx
  800d23:	83 ea 30             	sub    $0x30,%edx
  800d26:	eb 22                	jmp    800d4a <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d28:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d2b:	89 f3                	mov    %esi,%ebx
  800d2d:	80 fb 19             	cmp    $0x19,%bl
  800d30:	77 08                	ja     800d3a <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d32:	0f be d2             	movsbl %dl,%edx
  800d35:	83 ea 57             	sub    $0x57,%edx
  800d38:	eb 10                	jmp    800d4a <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d3a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d3d:	89 f3                	mov    %esi,%ebx
  800d3f:	80 fb 19             	cmp    $0x19,%bl
  800d42:	77 16                	ja     800d5a <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d44:	0f be d2             	movsbl %dl,%edx
  800d47:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d4a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d4d:	7d 0b                	jge    800d5a <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d4f:	83 c1 01             	add    $0x1,%ecx
  800d52:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d56:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d58:	eb b9                	jmp    800d13 <strtol+0x7f>

	if (endptr)
  800d5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5e:	74 0d                	je     800d6d <strtol+0xd9>
		*endptr = (char *) s;
  800d60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d63:	89 0e                	mov    %ecx,(%esi)
  800d65:	eb 06                	jmp    800d6d <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d67:	85 db                	test   %ebx,%ebx
  800d69:	74 98                	je     800d03 <strtol+0x6f>
  800d6b:	eb 9e                	jmp    800d0b <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d6d:	89 c2                	mov    %eax,%edx
  800d6f:	f7 da                	neg    %edx
  800d71:	85 ff                	test   %edi,%edi
  800d73:	0f 45 c2             	cmovne %edx,%eax
}
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d80:	b8 00 00 00 00       	mov    $0x0,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 c3                	mov    %eax,%ebx
  800d8d:	89 c7                	mov    %eax,%edi
  800d8f:	51                   	push   %ecx
  800d90:	52                   	push   %edx
  800d91:	53                   	push   %ebx
  800d92:	54                   	push   %esp
  800d93:	55                   	push   %ebp
  800d94:	56                   	push   %esi
  800d95:	57                   	push   %edi
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	8d 35 a0 0d 80 00    	lea    0x800da0,%esi
  800d9e:	0f 34                	sysenter 

00800da0 <label_21>:
  800da0:	5f                   	pop    %edi
  800da1:	5e                   	pop    %esi
  800da2:	5d                   	pop    %ebp
  800da3:	5c                   	pop    %esp
  800da4:	5b                   	pop    %ebx
  800da5:	5a                   	pop    %edx
  800da6:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da7:	5b                   	pop    %ebx
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_cgetc>:

int
sys_cgetc(void)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800db0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dba:	89 ca                	mov    %ecx,%edx
  800dbc:	89 cb                	mov    %ecx,%ebx
  800dbe:	89 cf                	mov    %ecx,%edi
  800dc0:	51                   	push   %ecx
  800dc1:	52                   	push   %edx
  800dc2:	53                   	push   %ebx
  800dc3:	54                   	push   %esp
  800dc4:	55                   	push   %ebp
  800dc5:	56                   	push   %esi
  800dc6:	57                   	push   %edi
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	8d 35 d1 0d 80 00    	lea    0x800dd1,%esi
  800dcf:	0f 34                	sysenter 

00800dd1 <label_55>:
  800dd1:	5f                   	pop    %edi
  800dd2:	5e                   	pop    %esi
  800dd3:	5d                   	pop    %ebp
  800dd4:	5c                   	pop    %esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5a                   	pop    %edx
  800dd7:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800de1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de6:	b8 03 00 00 00       	mov    $0x3,%eax
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 d9                	mov    %ebx,%ecx
  800df0:	89 df                	mov    %ebx,%edi
  800df2:	51                   	push   %ecx
  800df3:	52                   	push   %edx
  800df4:	53                   	push   %ebx
  800df5:	54                   	push   %esp
  800df6:	55                   	push   %ebp
  800df7:	56                   	push   %esi
  800df8:	57                   	push   %edi
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	8d 35 03 0e 80 00    	lea    0x800e03,%esi
  800e01:	0f 34                	sysenter 

00800e03 <label_90>:
  800e03:	5f                   	pop    %edi
  800e04:	5e                   	pop    %esi
  800e05:	5d                   	pop    %ebp
  800e06:	5c                   	pop    %esp
  800e07:	5b                   	pop    %ebx
  800e08:	5a                   	pop    %edx
  800e09:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7e 17                	jle    800e25 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	6a 03                	push   $0x3
  800e14:	68 7c 14 80 00       	push   $0x80147c
  800e19:	6a 2a                	push   $0x2a
  800e1b:	68 99 14 80 00       	push   $0x801499
  800e20:	e8 9d 00 00 00       	call   800ec2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e36:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3b:	89 ca                	mov    %ecx,%edx
  800e3d:	89 cb                	mov    %ecx,%ebx
  800e3f:	89 cf                	mov    %ecx,%edi
  800e41:	51                   	push   %ecx
  800e42:	52                   	push   %edx
  800e43:	53                   	push   %ebx
  800e44:	54                   	push   %esp
  800e45:	55                   	push   %ebp
  800e46:	56                   	push   %esi
  800e47:	57                   	push   %edi
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	8d 35 52 0e 80 00    	lea    0x800e52,%esi
  800e50:	0f 34                	sysenter 

00800e52 <label_139>:
  800e52:	5f                   	pop    %edi
  800e53:	5e                   	pop    %esi
  800e54:	5d                   	pop    %ebp
  800e55:	5c                   	pop    %esp
  800e56:	5b                   	pop    %ebx
  800e57:	5a                   	pop    %edx
  800e58:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e59:	5b                   	pop    %ebx
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e62:	bf 00 00 00 00       	mov    $0x0,%edi
  800e67:	b8 04 00 00 00       	mov    $0x4,%eax
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	89 fb                	mov    %edi,%ebx
  800e74:	51                   	push   %ecx
  800e75:	52                   	push   %edx
  800e76:	53                   	push   %ebx
  800e77:	54                   	push   %esp
  800e78:	55                   	push   %ebp
  800e79:	56                   	push   %esi
  800e7a:	57                   	push   %edi
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8d 35 85 0e 80 00    	lea    0x800e85,%esi
  800e83:	0f 34                	sysenter 

00800e85 <label_174>:
  800e85:	5f                   	pop    %edi
  800e86:	5e                   	pop    %esi
  800e87:	5d                   	pop    %ebp
  800e88:	5c                   	pop    %esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5a                   	pop    %edx
  800e8b:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	5f                   	pop    %edi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	89 cb                	mov    %ecx,%ebx
  800ea4:	89 cf                	mov    %ecx,%edi
  800ea6:	51                   	push   %ecx
  800ea7:	52                   	push   %edx
  800ea8:	53                   	push   %ebx
  800ea9:	54                   	push   %esp
  800eaa:	55                   	push   %ebp
  800eab:	56                   	push   %esi
  800eac:	57                   	push   %edi
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	8d 35 b7 0e 80 00    	lea    0x800eb7,%esi
  800eb5:	0f 34                	sysenter 

00800eb7 <label_209>:
  800eb7:	5f                   	pop    %edi
  800eb8:	5e                   	pop    %esi
  800eb9:	5d                   	pop    %ebp
  800eba:	5c                   	pop    %esp
  800ebb:	5b                   	pop    %ebx
  800ebc:	5a                   	pop    %edx
  800ebd:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ec7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800eca:	a1 10 20 80 00       	mov    0x802010,%eax
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	74 11                	je     800ee4 <_panic+0x22>
		cprintf("%s: ", argv0);
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	50                   	push   %eax
  800ed7:	68 a7 14 80 00       	push   $0x8014a7
  800edc:	e8 83 f2 ff ff       	call   800164 <cprintf>
  800ee1:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ee4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800eea:	e8 3d ff ff ff       	call   800e2c <sys_getenvid>
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	ff 75 0c             	pushl  0xc(%ebp)
  800ef5:	ff 75 08             	pushl  0x8(%ebp)
  800ef8:	56                   	push   %esi
  800ef9:	50                   	push   %eax
  800efa:	68 ac 14 80 00       	push   $0x8014ac
  800eff:	e8 60 f2 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f04:	83 c4 18             	add    $0x18,%esp
  800f07:	53                   	push   %ebx
  800f08:	ff 75 10             	pushl  0x10(%ebp)
  800f0b:	e8 03 f2 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  800f10:	c7 04 24 ca 11 80 00 	movl   $0x8011ca,(%esp)
  800f17:	e8 48 f2 ff ff       	call   800164 <cprintf>
  800f1c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f1f:	cc                   	int3   
  800f20:	eb fd                	jmp    800f1f <_panic+0x5d>
  800f22:	66 90                	xchg   %ax,%ax
  800f24:	66 90                	xchg   %ax,%ax
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__udivdi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 1c             	sub    $0x1c,%esp
  800f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f47:	85 f6                	test   %esi,%esi
  800f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f4d:	89 ca                	mov    %ecx,%edx
  800f4f:	89 f8                	mov    %edi,%eax
  800f51:	75 3d                	jne    800f90 <__udivdi3+0x60>
  800f53:	39 cf                	cmp    %ecx,%edi
  800f55:	0f 87 c5 00 00 00    	ja     801020 <__udivdi3+0xf0>
  800f5b:	85 ff                	test   %edi,%edi
  800f5d:	89 fd                	mov    %edi,%ebp
  800f5f:	75 0b                	jne    800f6c <__udivdi3+0x3c>
  800f61:	b8 01 00 00 00       	mov    $0x1,%eax
  800f66:	31 d2                	xor    %edx,%edx
  800f68:	f7 f7                	div    %edi
  800f6a:	89 c5                	mov    %eax,%ebp
  800f6c:	89 c8                	mov    %ecx,%eax
  800f6e:	31 d2                	xor    %edx,%edx
  800f70:	f7 f5                	div    %ebp
  800f72:	89 c1                	mov    %eax,%ecx
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	89 cf                	mov    %ecx,%edi
  800f78:	f7 f5                	div    %ebp
  800f7a:	89 c3                	mov    %eax,%ebx
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	89 fa                	mov    %edi,%edx
  800f80:	83 c4 1c             	add    $0x1c,%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    
  800f88:	90                   	nop
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	39 ce                	cmp    %ecx,%esi
  800f92:	77 74                	ja     801008 <__udivdi3+0xd8>
  800f94:	0f bd fe             	bsr    %esi,%edi
  800f97:	83 f7 1f             	xor    $0x1f,%edi
  800f9a:	0f 84 98 00 00 00    	je     801038 <__udivdi3+0x108>
  800fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800fa5:	89 f9                	mov    %edi,%ecx
  800fa7:	89 c5                	mov    %eax,%ebp
  800fa9:	29 fb                	sub    %edi,%ebx
  800fab:	d3 e6                	shl    %cl,%esi
  800fad:	89 d9                	mov    %ebx,%ecx
  800faf:	d3 ed                	shr    %cl,%ebp
  800fb1:	89 f9                	mov    %edi,%ecx
  800fb3:	d3 e0                	shl    %cl,%eax
  800fb5:	09 ee                	or     %ebp,%esi
  800fb7:	89 d9                	mov    %ebx,%ecx
  800fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fbd:	89 d5                	mov    %edx,%ebp
  800fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fc3:	d3 ed                	shr    %cl,%ebp
  800fc5:	89 f9                	mov    %edi,%ecx
  800fc7:	d3 e2                	shl    %cl,%edx
  800fc9:	89 d9                	mov    %ebx,%ecx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	09 c2                	or     %eax,%edx
  800fcf:	89 d0                	mov    %edx,%eax
  800fd1:	89 ea                	mov    %ebp,%edx
  800fd3:	f7 f6                	div    %esi
  800fd5:	89 d5                	mov    %edx,%ebp
  800fd7:	89 c3                	mov    %eax,%ebx
  800fd9:	f7 64 24 0c          	mull   0xc(%esp)
  800fdd:	39 d5                	cmp    %edx,%ebp
  800fdf:	72 10                	jb     800ff1 <__udivdi3+0xc1>
  800fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fe5:	89 f9                	mov    %edi,%ecx
  800fe7:	d3 e6                	shl    %cl,%esi
  800fe9:	39 c6                	cmp    %eax,%esi
  800feb:	73 07                	jae    800ff4 <__udivdi3+0xc4>
  800fed:	39 d5                	cmp    %edx,%ebp
  800fef:	75 03                	jne    800ff4 <__udivdi3+0xc4>
  800ff1:	83 eb 01             	sub    $0x1,%ebx
  800ff4:	31 ff                	xor    %edi,%edi
  800ff6:	89 d8                	mov    %ebx,%eax
  800ff8:	89 fa                	mov    %edi,%edx
  800ffa:	83 c4 1c             	add    $0x1c,%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    
  801002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801008:	31 ff                	xor    %edi,%edi
  80100a:	31 db                	xor    %ebx,%ebx
  80100c:	89 d8                	mov    %ebx,%eax
  80100e:	89 fa                	mov    %edi,%edx
  801010:	83 c4 1c             	add    $0x1c,%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    
  801018:	90                   	nop
  801019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801020:	89 d8                	mov    %ebx,%eax
  801022:	f7 f7                	div    %edi
  801024:	31 ff                	xor    %edi,%edi
  801026:	89 c3                	mov    %eax,%ebx
  801028:	89 d8                	mov    %ebx,%eax
  80102a:	89 fa                	mov    %edi,%edx
  80102c:	83 c4 1c             	add    $0x1c,%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    
  801034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801038:	39 ce                	cmp    %ecx,%esi
  80103a:	72 0c                	jb     801048 <__udivdi3+0x118>
  80103c:	31 db                	xor    %ebx,%ebx
  80103e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801042:	0f 87 34 ff ff ff    	ja     800f7c <__udivdi3+0x4c>
  801048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80104d:	e9 2a ff ff ff       	jmp    800f7c <__udivdi3+0x4c>
  801052:	66 90                	xchg   %ax,%ax
  801054:	66 90                	xchg   %ax,%ax
  801056:	66 90                	xchg   %ax,%ax
  801058:	66 90                	xchg   %ax,%ax
  80105a:	66 90                	xchg   %ax,%ax
  80105c:	66 90                	xchg   %ax,%ax
  80105e:	66 90                	xchg   %ax,%ax

00801060 <__umoddi3>:
  801060:	55                   	push   %ebp
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	83 ec 1c             	sub    $0x1c,%esp
  801067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80106b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80106f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801077:	85 d2                	test   %edx,%edx
  801079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80107d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801081:	89 f3                	mov    %esi,%ebx
  801083:	89 3c 24             	mov    %edi,(%esp)
  801086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80108a:	75 1c                	jne    8010a8 <__umoddi3+0x48>
  80108c:	39 f7                	cmp    %esi,%edi
  80108e:	76 50                	jbe    8010e0 <__umoddi3+0x80>
  801090:	89 c8                	mov    %ecx,%eax
  801092:	89 f2                	mov    %esi,%edx
  801094:	f7 f7                	div    %edi
  801096:	89 d0                	mov    %edx,%eax
  801098:	31 d2                	xor    %edx,%edx
  80109a:	83 c4 1c             	add    $0x1c,%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5f                   	pop    %edi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    
  8010a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010a8:	39 f2                	cmp    %esi,%edx
  8010aa:	89 d0                	mov    %edx,%eax
  8010ac:	77 52                	ja     801100 <__umoddi3+0xa0>
  8010ae:	0f bd ea             	bsr    %edx,%ebp
  8010b1:	83 f5 1f             	xor    $0x1f,%ebp
  8010b4:	75 5a                	jne    801110 <__umoddi3+0xb0>
  8010b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8010ba:	0f 82 e0 00 00 00    	jb     8011a0 <__umoddi3+0x140>
  8010c0:	39 0c 24             	cmp    %ecx,(%esp)
  8010c3:	0f 86 d7 00 00 00    	jbe    8011a0 <__umoddi3+0x140>
  8010c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010d1:	83 c4 1c             	add    $0x1c,%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    
  8010d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	85 ff                	test   %edi,%edi
  8010e2:	89 fd                	mov    %edi,%ebp
  8010e4:	75 0b                	jne    8010f1 <__umoddi3+0x91>
  8010e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	f7 f7                	div    %edi
  8010ef:	89 c5                	mov    %eax,%ebp
  8010f1:	89 f0                	mov    %esi,%eax
  8010f3:	31 d2                	xor    %edx,%edx
  8010f5:	f7 f5                	div    %ebp
  8010f7:	89 c8                	mov    %ecx,%eax
  8010f9:	f7 f5                	div    %ebp
  8010fb:	89 d0                	mov    %edx,%eax
  8010fd:	eb 99                	jmp    801098 <__umoddi3+0x38>
  8010ff:	90                   	nop
  801100:	89 c8                	mov    %ecx,%eax
  801102:	89 f2                	mov    %esi,%edx
  801104:	83 c4 1c             	add    $0x1c,%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    
  80110c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801110:	8b 34 24             	mov    (%esp),%esi
  801113:	bf 20 00 00 00       	mov    $0x20,%edi
  801118:	89 e9                	mov    %ebp,%ecx
  80111a:	29 ef                	sub    %ebp,%edi
  80111c:	d3 e0                	shl    %cl,%eax
  80111e:	89 f9                	mov    %edi,%ecx
  801120:	89 f2                	mov    %esi,%edx
  801122:	d3 ea                	shr    %cl,%edx
  801124:	89 e9                	mov    %ebp,%ecx
  801126:	09 c2                	or     %eax,%edx
  801128:	89 d8                	mov    %ebx,%eax
  80112a:	89 14 24             	mov    %edx,(%esp)
  80112d:	89 f2                	mov    %esi,%edx
  80112f:	d3 e2                	shl    %cl,%edx
  801131:	89 f9                	mov    %edi,%ecx
  801133:	89 54 24 04          	mov    %edx,0x4(%esp)
  801137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80113b:	d3 e8                	shr    %cl,%eax
  80113d:	89 e9                	mov    %ebp,%ecx
  80113f:	89 c6                	mov    %eax,%esi
  801141:	d3 e3                	shl    %cl,%ebx
  801143:	89 f9                	mov    %edi,%ecx
  801145:	89 d0                	mov    %edx,%eax
  801147:	d3 e8                	shr    %cl,%eax
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	09 d8                	or     %ebx,%eax
  80114d:	89 d3                	mov    %edx,%ebx
  80114f:	89 f2                	mov    %esi,%edx
  801151:	f7 34 24             	divl   (%esp)
  801154:	89 d6                	mov    %edx,%esi
  801156:	d3 e3                	shl    %cl,%ebx
  801158:	f7 64 24 04          	mull   0x4(%esp)
  80115c:	39 d6                	cmp    %edx,%esi
  80115e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801162:	89 d1                	mov    %edx,%ecx
  801164:	89 c3                	mov    %eax,%ebx
  801166:	72 08                	jb     801170 <__umoddi3+0x110>
  801168:	75 11                	jne    80117b <__umoddi3+0x11b>
  80116a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80116e:	73 0b                	jae    80117b <__umoddi3+0x11b>
  801170:	2b 44 24 04          	sub    0x4(%esp),%eax
  801174:	1b 14 24             	sbb    (%esp),%edx
  801177:	89 d1                	mov    %edx,%ecx
  801179:	89 c3                	mov    %eax,%ebx
  80117b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80117f:	29 da                	sub    %ebx,%edx
  801181:	19 ce                	sbb    %ecx,%esi
  801183:	89 f9                	mov    %edi,%ecx
  801185:	89 f0                	mov    %esi,%eax
  801187:	d3 e0                	shl    %cl,%eax
  801189:	89 e9                	mov    %ebp,%ecx
  80118b:	d3 ea                	shr    %cl,%edx
  80118d:	89 e9                	mov    %ebp,%ecx
  80118f:	d3 ee                	shr    %cl,%esi
  801191:	09 d0                	or     %edx,%eax
  801193:	89 f2                	mov    %esi,%edx
  801195:	83 c4 1c             	add    $0x1c,%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    
  80119d:	8d 76 00             	lea    0x0(%esi),%esi
  8011a0:	29 f9                	sub    %edi,%ecx
  8011a2:	19 d6                	sbb    %edx,%esi
  8011a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ac:	e9 18 ff ff ff       	jmp    8010c9 <__umoddi3+0x69>
