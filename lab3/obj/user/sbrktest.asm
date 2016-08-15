
obj/user/sbrktest:     file format elf32-i386


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
  80002c:	e8 88 00 00 00       	call   8000b9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define ALLOCATE_SIZE 4096
#define STRING_SIZE	  64

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 18             	sub    $0x18,%esp
	int i;
	uint32_t start, end;
	char *s;

	start = sys_sbrk(0);
  80003c:	6a 00                	push   $0x0
  80003e:	e8 8d 0e 00 00       	call   800ed0 <sys_sbrk>
  800043:	89 c6                	mov    %eax,%esi
  800045:	89 c3                	mov    %eax,%ebx
	end = sys_sbrk(ALLOCATE_SIZE);
  800047:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  80004e:	e8 7d 0e 00 00       	call   800ed0 <sys_sbrk>

	if (end - start < ALLOCATE_SIZE) {
  800053:	29 f0                	sub    %esi,%eax
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  80005d:	77 10                	ja     80006f <umain+0x3c>
		cprintf("sbrk not correctly implemented\n");
  80005f:	83 ec 0c             	sub    $0xc,%esp
  800062:	68 f4 11 80 00       	push   $0x8011f4
  800067:	e8 38 01 00 00       	call   8001a4 <cprintf>
  80006c:	83 c4 10             	add    $0x10,%esp
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  80006f:	b9 00 00 00 00       	mov    $0x0,%ecx
		s[i] = 'A' + (i % 26);
  800074:	bf 4f ec c4 4e       	mov    $0x4ec4ec4f,%edi
  800079:	89 c8                	mov    %ecx,%eax
  80007b:	f7 ef                	imul   %edi
  80007d:	c1 fa 03             	sar    $0x3,%edx
  800080:	89 c8                	mov    %ecx,%eax
  800082:	c1 f8 1f             	sar    $0x1f,%eax
  800085:	29 c2                	sub    %eax,%edx
  800087:	6b d2 1a             	imul   $0x1a,%edx,%edx
  80008a:	89 c8                	mov    %ecx,%eax
  80008c:	29 d0                	sub    %edx,%eax
  80008e:	83 c0 41             	add    $0x41,%eax
  800091:	88 04 19             	mov    %al,(%ecx,%ebx,1)
	if (end - start < ALLOCATE_SIZE) {
		cprintf("sbrk not correctly implemented\n");
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  800094:	83 c1 01             	add    $0x1,%ecx
  800097:	83 f9 40             	cmp    $0x40,%ecx
  80009a:	75 dd                	jne    800079 <umain+0x46>
		s[i] = 'A' + (i % 26);
	}
	s[STRING_SIZE] = '\0';
  80009c:	c6 46 40 00          	movb   $0x0,0x40(%esi)

	cprintf("SBRK_TEST(%s)\n", s);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	56                   	push   %esi
  8000a4:	68 14 12 80 00       	push   $0x801214
  8000a9:	e8 f6 00 00 00       	call   8001a4 <cprintf>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
  8000be:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c4:	e8 a3 0d 00 00       	call   800e6c <sys_getenvid>
  8000c9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ce:	6b c0 64             	imul   $0x64,%eax,%eax
  8000d1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d6:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000db:	85 db                	test   %ebx,%ebx
  8000dd:	7e 07                	jle    8000e6 <libmain+0x2d>
		binaryname = argv[0];
  8000df:	8b 06                	mov    (%esi),%eax
  8000e1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	e8 43 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f0:	e8 0a 00 00 00       	call   8000ff <exit>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800105:	6a 00                	push   $0x0
  800107:	e8 10 0d 00 00       	call   800e1c <sys_env_destroy>
}
  80010c:	83 c4 10             	add    $0x10,%esp
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	53                   	push   %ebx
  800115:	83 ec 04             	sub    $0x4,%esp
  800118:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011b:	8b 13                	mov    (%ebx),%edx
  80011d:	8d 42 01             	lea    0x1(%edx),%eax
  800120:	89 03                	mov    %eax,(%ebx)
  800122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800125:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800129:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012e:	75 1a                	jne    80014a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	68 ff 00 00 00       	push   $0xff
  800138:	8d 43 08             	lea    0x8(%ebx),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 7a 0c 00 00       	call   800dbb <sys_cputs>
		b->idx = 0;
  800141:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800147:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800163:	00 00 00 
	b.cnt = 0;
  800166:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800170:	ff 75 0c             	pushl  0xc(%ebp)
  800173:	ff 75 08             	pushl  0x8(%ebp)
  800176:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017c:	50                   	push   %eax
  80017d:	68 11 01 80 00       	push   $0x800111
  800182:	e8 c0 02 00 00       	call   800447 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	83 c4 08             	add    $0x8,%esp
  80018a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800190:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800196:	50                   	push   %eax
  800197:	e8 1f 0c 00 00       	call   800dbb <sys_cputs>

	return b.cnt;
}
  80019c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ad:	50                   	push   %eax
  8001ae:	ff 75 08             	pushl  0x8(%ebp)
  8001b1:	e8 9d ff ff ff       	call   800153 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 1c             	sub    $0x1c,%esp
  8001c1:	89 c7                	mov    %eax,%edi
  8001c3:	89 d6                	mov    %edx,%esi
  8001c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  8001d4:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001d8:	0f 85 bf 00 00 00    	jne    80029d <printnum+0xe5>
  8001de:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8001e4:	0f 8d de 00 00 00    	jge    8002c8 <printnum+0x110>
		judge_time_for_space = width;
  8001ea:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8001f0:	e9 d3 00 00 00       	jmp    8002c8 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001f5:	83 eb 01             	sub    $0x1,%ebx
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7f 37                	jg     800233 <printnum+0x7b>
  8001fc:	e9 ea 00 00 00       	jmp    8002eb <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800201:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800204:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	83 ec 04             	sub    $0x4,%esp
  800210:	ff 75 dc             	pushl  -0x24(%ebp)
  800213:	ff 75 d8             	pushl  -0x28(%ebp)
  800216:	ff 75 e4             	pushl  -0x1c(%ebp)
  800219:	ff 75 e0             	pushl  -0x20(%ebp)
  80021c:	e8 7f 0e 00 00       	call   8010a0 <__umoddi3>
  800221:	83 c4 14             	add    $0x14,%esp
  800224:	0f be 80 2d 12 80 00 	movsbl 0x80122d(%eax),%eax
  80022b:	50                   	push   %eax
  80022c:	ff d7                	call   *%edi
  80022e:	83 c4 10             	add    $0x10,%esp
  800231:	eb 16                	jmp    800249 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	ff 75 18             	pushl  0x18(%ebp)
  80023a:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80023c:	83 c4 10             	add    $0x10,%esp
  80023f:	83 eb 01             	sub    $0x1,%ebx
  800242:	75 ef                	jne    800233 <printnum+0x7b>
  800244:	e9 a2 00 00 00       	jmp    8002eb <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800249:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  80024f:	0f 85 76 01 00 00    	jne    8003cb <printnum+0x213>
		while(num_of_space-- > 0)
  800255:	a1 04 20 80 00       	mov    0x802004,%eax
  80025a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80025d:	89 15 04 20 80 00    	mov    %edx,0x802004
  800263:	85 c0                	test   %eax,%eax
  800265:	7e 1d                	jle    800284 <printnum+0xcc>
			putch(' ', putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	6a 20                	push   $0x20
  80026d:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80026f:	a1 04 20 80 00       	mov    0x802004,%eax
  800274:	8d 50 ff             	lea    -0x1(%eax),%edx
  800277:	89 15 04 20 80 00    	mov    %edx,0x802004
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	85 c0                	test   %eax,%eax
  800282:	7f e3                	jg     800267 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800284:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80028b:	00 00 00 
		judge_time_for_space = 0;
  80028e:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800295:	00 00 00 
	}
}
  800298:	e9 2e 01 00 00       	jmp    8003cb <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029d:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002b1:	83 fa 00             	cmp    $0x0,%edx
  8002b4:	0f 87 ba 00 00 00    	ja     800374 <printnum+0x1bc>
  8002ba:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002bd:	0f 83 b1 00 00 00    	jae    800374 <printnum+0x1bc>
  8002c3:	e9 2d ff ff ff       	jmp    8001f5 <printnum+0x3d>
  8002c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002dc:	83 fa 00             	cmp    $0x0,%edx
  8002df:	77 37                	ja     800318 <printnum+0x160>
  8002e1:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002e4:	73 32                	jae    800318 <printnum+0x160>
  8002e6:	e9 16 ff ff ff       	jmp    800201 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002eb:	83 ec 08             	sub    $0x8,%esp
  8002ee:	56                   	push   %esi
  8002ef:	83 ec 04             	sub    $0x4,%esp
  8002f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002fe:	e8 9d 0d 00 00       	call   8010a0 <__umoddi3>
  800303:	83 c4 14             	add    $0x14,%esp
  800306:	0f be 80 2d 12 80 00 	movsbl 0x80122d(%eax),%eax
  80030d:	50                   	push   %eax
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	e9 b3 00 00 00       	jmp    8003cb <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	ff 75 18             	pushl  0x18(%ebp)
  80031e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800321:	50                   	push   %eax
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	ff 75 dc             	pushl  -0x24(%ebp)
  80032b:	ff 75 d8             	pushl  -0x28(%ebp)
  80032e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800331:	ff 75 e0             	pushl  -0x20(%ebp)
  800334:	e8 37 0c 00 00       	call   800f70 <__udivdi3>
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	52                   	push   %edx
  80033d:	50                   	push   %eax
  80033e:	89 f2                	mov    %esi,%edx
  800340:	89 f8                	mov    %edi,%eax
  800342:	e8 71 fe ff ff       	call   8001b8 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800347:	83 c4 18             	add    $0x18,%esp
  80034a:	56                   	push   %esi
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	ff 75 e4             	pushl  -0x1c(%ebp)
  800357:	ff 75 e0             	pushl  -0x20(%ebp)
  80035a:	e8 41 0d 00 00       	call   8010a0 <__umoddi3>
  80035f:	83 c4 14             	add    $0x14,%esp
  800362:	0f be 80 2d 12 80 00 	movsbl 0x80122d(%eax),%eax
  800369:	50                   	push   %eax
  80036a:	ff d7                	call   *%edi
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	e9 d5 fe ff ff       	jmp    800249 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800374:	83 ec 0c             	sub    $0xc,%esp
  800377:	ff 75 18             	pushl  0x18(%ebp)
  80037a:	83 eb 01             	sub    $0x1,%ebx
  80037d:	53                   	push   %ebx
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	ff 75 dc             	pushl  -0x24(%ebp)
  800387:	ff 75 d8             	pushl  -0x28(%ebp)
  80038a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038d:	ff 75 e0             	pushl  -0x20(%ebp)
  800390:	e8 db 0b 00 00       	call   800f70 <__udivdi3>
  800395:	83 c4 18             	add    $0x18,%esp
  800398:	52                   	push   %edx
  800399:	50                   	push   %eax
  80039a:	89 f2                	mov    %esi,%edx
  80039c:	89 f8                	mov    %edi,%eax
  80039e:	e8 15 fe ff ff       	call   8001b8 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a3:	83 c4 18             	add    $0x18,%esp
  8003a6:	56                   	push   %esi
  8003a7:	83 ec 04             	sub    $0x4,%esp
  8003aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b6:	e8 e5 0c 00 00       	call   8010a0 <__umoddi3>
  8003bb:	83 c4 14             	add    $0x14,%esp
  8003be:	0f be 80 2d 12 80 00 	movsbl 0x80122d(%eax),%eax
  8003c5:	50                   	push   %eax
  8003c6:	ff d7                	call   *%edi
  8003c8:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8003cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d6:	83 fa 01             	cmp    $0x1,%edx
  8003d9:	7e 0e                	jle    8003e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e0:	89 08                	mov    %ecx,(%eax)
  8003e2:	8b 02                	mov    (%edx),%eax
  8003e4:	8b 52 04             	mov    0x4(%edx),%edx
  8003e7:	eb 22                	jmp    80040b <getuint+0x38>
	else if (lflag)
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	74 10                	je     8003fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f2:	89 08                	mov    %ecx,(%eax)
  8003f4:	8b 02                	mov    (%edx),%eax
  8003f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fb:	eb 0e                	jmp    80040b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fd:	8b 10                	mov    (%eax),%edx
  8003ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 02                	mov    (%edx),%eax
  800406:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800413:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800417:	8b 10                	mov    (%eax),%edx
  800419:	3b 50 04             	cmp    0x4(%eax),%edx
  80041c:	73 0a                	jae    800428 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800421:	89 08                	mov    %ecx,(%eax)
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	88 02                	mov    %al,(%edx)
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800430:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800433:	50                   	push   %eax
  800434:	ff 75 10             	pushl  0x10(%ebp)
  800437:	ff 75 0c             	pushl  0xc(%ebp)
  80043a:	ff 75 08             	pushl  0x8(%ebp)
  80043d:	e8 05 00 00 00       	call   800447 <vprintfmt>
	va_end(ap);
}
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	c9                   	leave  
  800446:	c3                   	ret    

00800447 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	57                   	push   %edi
  80044b:	56                   	push   %esi
  80044c:	53                   	push   %ebx
  80044d:	83 ec 2c             	sub    $0x2c,%esp
  800450:	8b 7d 08             	mov    0x8(%ebp),%edi
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800456:	eb 03                	jmp    80045b <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800458:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045b:	8b 45 10             	mov    0x10(%ebp),%eax
  80045e:	8d 70 01             	lea    0x1(%eax),%esi
  800461:	0f b6 00             	movzbl (%eax),%eax
  800464:	83 f8 25             	cmp    $0x25,%eax
  800467:	74 27                	je     800490 <vprintfmt+0x49>
			if (ch == '\0')
  800469:	85 c0                	test   %eax,%eax
  80046b:	75 0d                	jne    80047a <vprintfmt+0x33>
  80046d:	e9 9d 04 00 00       	jmp    80090f <vprintfmt+0x4c8>
  800472:	85 c0                	test   %eax,%eax
  800474:	0f 84 95 04 00 00    	je     80090f <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	50                   	push   %eax
  80047f:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800481:	83 c6 01             	add    $0x1,%esi
  800484:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	83 f8 25             	cmp    $0x25,%eax
  80048e:	75 e2                	jne    800472 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800490:	b9 00 00 00 00       	mov    $0x0,%ecx
  800495:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800499:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004a0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004ae:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004b5:	eb 08                	jmp    8004bf <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8004ba:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8d 46 01             	lea    0x1(%esi),%eax
  8004c2:	89 45 10             	mov    %eax,0x10(%ebp)
  8004c5:	0f b6 06             	movzbl (%esi),%eax
  8004c8:	0f b6 d0             	movzbl %al,%edx
  8004cb:	83 e8 23             	sub    $0x23,%eax
  8004ce:	3c 55                	cmp    $0x55,%al
  8004d0:	0f 87 fa 03 00 00    	ja     8008d0 <vprintfmt+0x489>
  8004d6:	0f b6 c0             	movzbl %al,%eax
  8004d9:	ff 24 85 38 13 80 00 	jmp    *0x801338(,%eax,4)
  8004e0:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e3:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8004e7:	eb d6                	jmp    8004bf <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e9:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004ef:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004f3:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f6:	83 fa 09             	cmp    $0x9,%edx
  8004f9:	77 6b                	ja     800566 <vprintfmt+0x11f>
  8004fb:	8b 75 10             	mov    0x10(%ebp),%esi
  8004fe:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800501:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800504:	eb 09                	jmp    80050f <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800509:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80050d:	eb b0                	jmp    8004bf <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800512:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800515:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800519:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80051c:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80051f:	83 f9 09             	cmp    $0x9,%ecx
  800522:	76 eb                	jbe    80050f <vprintfmt+0xc8>
  800524:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800527:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80052a:	eb 3d                	jmp    800569 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80053d:	eb 2a                	jmp    800569 <vprintfmt+0x122>
  80053f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800542:	85 c0                	test   %eax,%eax
  800544:	ba 00 00 00 00       	mov    $0x0,%edx
  800549:	0f 49 d0             	cmovns %eax,%edx
  80054c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 75 10             	mov    0x10(%ebp),%esi
  800552:	e9 68 ff ff ff       	jmp    8004bf <vprintfmt+0x78>
  800557:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80055a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800561:	e9 59 ff ff ff       	jmp    8004bf <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800569:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056d:	0f 89 4c ff ff ff    	jns    8004bf <vprintfmt+0x78>
				width = precision, precision = -1;
  800573:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800579:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800580:	e9 3a ff ff ff       	jmp    8004bf <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800585:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80058c:	e9 2e ff ff ff       	jmp    8004bf <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	ff 30                	pushl  (%eax)
  8005a0:	ff d7                	call   *%edi
			break;
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	e9 b1 fe ff ff       	jmp    80045b <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	99                   	cltd   
  8005b6:	31 d0                	xor    %edx,%eax
  8005b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ba:	83 f8 06             	cmp    $0x6,%eax
  8005bd:	7f 0b                	jg     8005ca <vprintfmt+0x183>
  8005bf:	8b 14 85 90 14 80 00 	mov    0x801490(,%eax,4),%edx
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	75 15                	jne    8005df <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8005ca:	50                   	push   %eax
  8005cb:	68 45 12 80 00       	push   $0x801245
  8005d0:	53                   	push   %ebx
  8005d1:	57                   	push   %edi
  8005d2:	e8 53 fe ff ff       	call   80042a <printfmt>
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	e9 7c fe ff ff       	jmp    80045b <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005df:	52                   	push   %edx
  8005e0:	68 4e 12 80 00       	push   $0x80124e
  8005e5:	53                   	push   %ebx
  8005e6:	57                   	push   %edi
  8005e7:	e8 3e fe ff ff       	call   80042a <printfmt>
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	e9 67 fe ff ff       	jmp    80045b <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005ff:	85 c0                	test   %eax,%eax
  800601:	b9 3e 12 80 00       	mov    $0x80123e,%ecx
  800606:	0f 45 c8             	cmovne %eax,%ecx
  800609:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80060c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800610:	7e 06                	jle    800618 <vprintfmt+0x1d1>
  800612:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800616:	75 19                	jne    800631 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800618:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80061b:	8d 70 01             	lea    0x1(%eax),%esi
  80061e:	0f b6 00             	movzbl (%eax),%eax
  800621:	0f be d0             	movsbl %al,%edx
  800624:	85 d2                	test   %edx,%edx
  800626:	0f 85 9f 00 00 00    	jne    8006cb <vprintfmt+0x284>
  80062c:	e9 8c 00 00 00       	jmp    8006bd <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	ff 75 d0             	pushl  -0x30(%ebp)
  800637:	ff 75 cc             	pushl  -0x34(%ebp)
  80063a:	e8 62 03 00 00       	call   8009a1 <strnlen>
  80063f:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800642:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	85 c9                	test   %ecx,%ecx
  80064a:	0f 8e a6 02 00 00    	jle    8008f6 <vprintfmt+0x4af>
					putch(padc, putdat);
  800650:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800654:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800657:	89 cb                	mov    %ecx,%ebx
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	56                   	push   %esi
  800660:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	83 eb 01             	sub    $0x1,%ebx
  800668:	75 ef                	jne    800659 <vprintfmt+0x212>
  80066a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80066d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800670:	e9 81 02 00 00       	jmp    8008f6 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800675:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800679:	74 1b                	je     800696 <vprintfmt+0x24f>
  80067b:	0f be c0             	movsbl %al,%eax
  80067e:	83 e8 20             	sub    $0x20,%eax
  800681:	83 f8 5e             	cmp    $0x5e,%eax
  800684:	76 10                	jbe    800696 <vprintfmt+0x24f>
					putch('?', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	ff 75 0c             	pushl  0xc(%ebp)
  80068c:	6a 3f                	push   $0x3f
  80068e:	ff 55 08             	call   *0x8(%ebp)
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 0d                	jmp    8006a3 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	ff 75 0c             	pushl  0xc(%ebp)
  80069c:	52                   	push   %edx
  80069d:	ff 55 08             	call   *0x8(%ebp)
  8006a0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a3:	83 ef 01             	sub    $0x1,%edi
  8006a6:	83 c6 01             	add    $0x1,%esi
  8006a9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8006ad:	0f be d0             	movsbl %al,%edx
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	75 31                	jne    8006e5 <vprintfmt+0x29e>
  8006b4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006bd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c4:	7f 33                	jg     8006f9 <vprintfmt+0x2b2>
  8006c6:	e9 90 fd ff ff       	jmp    80045b <vprintfmt+0x14>
  8006cb:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006d7:	eb 0c                	jmp    8006e5 <vprintfmt+0x29e>
  8006d9:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e5:	85 db                	test   %ebx,%ebx
  8006e7:	78 8c                	js     800675 <vprintfmt+0x22e>
  8006e9:	83 eb 01             	sub    $0x1,%ebx
  8006ec:	79 87                	jns    800675 <vprintfmt+0x22e>
  8006ee:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f7:	eb c4                	jmp    8006bd <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	6a 20                	push   $0x20
  8006ff:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	83 ee 01             	sub    $0x1,%esi
  800707:	75 f0                	jne    8006f9 <vprintfmt+0x2b2>
  800709:	e9 4d fd ff ff       	jmp    80045b <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070e:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800712:	7e 16                	jle    80072a <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 08             	lea    0x8(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 50 04             	mov    0x4(%eax),%edx
  800720:	8b 00                	mov    (%eax),%eax
  800722:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800725:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800728:	eb 34                	jmp    80075e <vprintfmt+0x317>
	else if (lflag)
  80072a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80072e:	74 18                	je     800748 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 50 04             	lea    0x4(%eax),%edx
  800736:	89 55 14             	mov    %edx,0x14(%ebp)
  800739:	8b 30                	mov    (%eax),%esi
  80073b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80073e:	89 f0                	mov    %esi,%eax
  800740:	c1 f8 1f             	sar    $0x1f,%eax
  800743:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800746:	eb 16                	jmp    80075e <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8d 50 04             	lea    0x4(%eax),%edx
  80074e:	89 55 14             	mov    %edx,0x14(%ebp)
  800751:	8b 30                	mov    (%eax),%esi
  800753:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800756:	89 f0                	mov    %esi,%eax
  800758:	c1 f8 1f             	sar    $0x1f,%eax
  80075b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800761:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800764:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800767:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80076a:	85 d2                	test   %edx,%edx
  80076c:	79 28                	jns    800796 <vprintfmt+0x34f>
				putch('-', putdat);
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 2d                	push   $0x2d
  800774:	ff d7                	call   *%edi
				num = -(long long) num;
  800776:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800779:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80077c:	f7 d8                	neg    %eax
  80077e:	83 d2 00             	adc    $0x0,%edx
  800781:	f7 da                	neg    %edx
  800783:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800786:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800789:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  80078c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800791:	e9 b2 00 00 00       	jmp    800848 <vprintfmt+0x401>
  800796:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  80079b:	85 c9                	test   %ecx,%ecx
  80079d:	0f 84 a5 00 00 00    	je     800848 <vprintfmt+0x401>
				putch('+', putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	6a 2b                	push   $0x2b
  8007a9:	ff d7                	call   *%edi
  8007ab:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8007ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b3:	e9 90 00 00 00       	jmp    800848 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8007b8:	85 c9                	test   %ecx,%ecx
  8007ba:	74 0b                	je     8007c7 <vprintfmt+0x380>
				putch('+', putdat);
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	53                   	push   %ebx
  8007c0:	6a 2b                	push   $0x2b
  8007c2:	ff d7                	call   *%edi
  8007c4:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8007c7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cd:	e8 01 fc ff ff       	call   8003d3 <getuint>
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007d8:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007dd:	eb 69                	jmp    800848 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	6a 30                	push   $0x30
  8007e5:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007e7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ed:	e8 e1 fb ff ff       	call   8003d3 <getuint>
  8007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8007f8:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007fb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800800:	eb 46                	jmp    800848 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	53                   	push   %ebx
  800806:	6a 30                	push   $0x30
  800808:	ff d7                	call   *%edi
			putch('x', putdat);
  80080a:	83 c4 08             	add    $0x8,%esp
  80080d:	53                   	push   %ebx
  80080e:	6a 78                	push   $0x78
  800810:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80081b:	8b 00                	mov    (%eax),%eax
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800825:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800828:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80082b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800830:	eb 16                	jmp    800848 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800832:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 96 fb ff ff       	call   8003d3 <getuint>
  80083d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800840:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800843:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800848:	83 ec 0c             	sub    $0xc,%esp
  80084b:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80084f:	56                   	push   %esi
  800850:	ff 75 e4             	pushl  -0x1c(%ebp)
  800853:	50                   	push   %eax
  800854:	ff 75 dc             	pushl  -0x24(%ebp)
  800857:	ff 75 d8             	pushl  -0x28(%ebp)
  80085a:	89 da                	mov    %ebx,%edx
  80085c:	89 f8                	mov    %edi,%eax
  80085e:	e8 55 f9 ff ff       	call   8001b8 <printnum>
			break;
  800863:	83 c4 20             	add    $0x20,%esp
  800866:	e9 f0 fb ff ff       	jmp    80045b <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  80086b:	8b 45 14             	mov    0x14(%ebp),%eax
  80086e:	8d 50 04             	lea    0x4(%eax),%edx
  800871:	89 55 14             	mov    %edx,0x14(%ebp)
  800874:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800876:	85 f6                	test   %esi,%esi
  800878:	75 1a                	jne    800894 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	68 bc 12 80 00       	push   $0x8012bc
  800882:	68 4e 12 80 00       	push   $0x80124e
  800887:	e8 18 f9 ff ff       	call   8001a4 <cprintf>
  80088c:	83 c4 10             	add    $0x10,%esp
  80088f:	e9 c7 fb ff ff       	jmp    80045b <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800894:	0f b6 03             	movzbl (%ebx),%eax
  800897:	84 c0                	test   %al,%al
  800899:	79 1f                	jns    8008ba <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	68 f4 12 80 00       	push   $0x8012f4
  8008a3:	68 4e 12 80 00       	push   $0x80124e
  8008a8:	e8 f7 f8 ff ff       	call   8001a4 <cprintf>
						*tmp = *(char *)putdat;
  8008ad:	0f b6 03             	movzbl (%ebx),%eax
  8008b0:	88 06                	mov    %al,(%esi)
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	e9 a1 fb ff ff       	jmp    80045b <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8008ba:	88 06                	mov    %al,(%esi)
  8008bc:	e9 9a fb ff ff       	jmp    80045b <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	53                   	push   %ebx
  8008c5:	52                   	push   %edx
  8008c6:	ff d7                	call   *%edi
			break;
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	e9 8b fb ff ff       	jmp    80045b <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d0:	83 ec 08             	sub    $0x8,%esp
  8008d3:	53                   	push   %ebx
  8008d4:	6a 25                	push   $0x25
  8008d6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008df:	0f 84 73 fb ff ff    	je     800458 <vprintfmt+0x11>
  8008e5:	83 ee 01             	sub    $0x1,%esi
  8008e8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008ec:	75 f7                	jne    8008e5 <vprintfmt+0x49e>
  8008ee:	89 75 10             	mov    %esi,0x10(%ebp)
  8008f1:	e9 65 fb ff ff       	jmp    80045b <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008f9:	8d 70 01             	lea    0x1(%eax),%esi
  8008fc:	0f b6 00             	movzbl (%eax),%eax
  8008ff:	0f be d0             	movsbl %al,%edx
  800902:	85 d2                	test   %edx,%edx
  800904:	0f 85 cf fd ff ff    	jne    8006d9 <vprintfmt+0x292>
  80090a:	e9 4c fb ff ff       	jmp    80045b <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80090f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 18             	sub    $0x18,%esp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800923:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800926:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800934:	85 c0                	test   %eax,%eax
  800936:	74 26                	je     80095e <vsnprintf+0x47>
  800938:	85 d2                	test   %edx,%edx
  80093a:	7e 22                	jle    80095e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093c:	ff 75 14             	pushl  0x14(%ebp)
  80093f:	ff 75 10             	pushl  0x10(%ebp)
  800942:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800945:	50                   	push   %eax
  800946:	68 0d 04 80 00       	push   $0x80040d
  80094b:	e8 f7 fa ff ff       	call   800447 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800950:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800953:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800959:	83 c4 10             	add    $0x10,%esp
  80095c:	eb 05                	jmp    800963 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096e:	50                   	push   %eax
  80096f:	ff 75 10             	pushl  0x10(%ebp)
  800972:	ff 75 0c             	pushl  0xc(%ebp)
  800975:	ff 75 08             	pushl  0x8(%ebp)
  800978:	e8 9a ff ff ff       	call   800917 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800985:	80 3a 00             	cmpb   $0x0,(%edx)
  800988:	74 10                	je     80099a <strlen+0x1b>
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80098f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800992:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800996:	75 f7                	jne    80098f <strlen+0x10>
  800998:	eb 05                	jmp    80099f <strlen+0x20>
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ab:	85 c9                	test   %ecx,%ecx
  8009ad:	74 1c                	je     8009cb <strnlen+0x2a>
  8009af:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009b2:	74 1e                	je     8009d2 <strnlen+0x31>
  8009b4:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009b9:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bb:	39 ca                	cmp    %ecx,%edx
  8009bd:	74 18                	je     8009d7 <strnlen+0x36>
  8009bf:	83 c2 01             	add    $0x1,%edx
  8009c2:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009c7:	75 f0                	jne    8009b9 <strnlen+0x18>
  8009c9:	eb 0c                	jmp    8009d7 <strnlen+0x36>
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d0:	eb 05                	jmp    8009d7 <strnlen+0x36>
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e4:	89 c2                	mov    %eax,%edx
  8009e6:	83 c2 01             	add    $0x1,%edx
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f3:	84 db                	test   %bl,%bl
  8009f5:	75 ef                	jne    8009e6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a01:	53                   	push   %ebx
  800a02:	e8 78 ff ff ff       	call   80097f <strlen>
  800a07:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a0a:	ff 75 0c             	pushl  0xc(%ebp)
  800a0d:	01 d8                	add    %ebx,%eax
  800a0f:	50                   	push   %eax
  800a10:	e8 c5 ff ff ff       	call   8009da <strcpy>
	return dst;
}
  800a15:	89 d8                	mov    %ebx,%eax
  800a17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 75 08             	mov    0x8(%ebp),%esi
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2a:	85 db                	test   %ebx,%ebx
  800a2c:	74 17                	je     800a45 <strncpy+0x29>
  800a2e:	01 f3                	add    %esi,%ebx
  800a30:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a32:	83 c1 01             	add    $0x1,%ecx
  800a35:	0f b6 02             	movzbl (%edx),%eax
  800a38:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3b:	80 3a 01             	cmpb   $0x1,(%edx)
  800a3e:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a41:	39 cb                	cmp    %ecx,%ebx
  800a43:	75 ed                	jne    800a32 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a45:	89 f0                	mov    %esi,%eax
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 75 08             	mov    0x8(%ebp),%esi
  800a53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a56:	8b 55 10             	mov    0x10(%ebp),%edx
  800a59:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5b:	85 d2                	test   %edx,%edx
  800a5d:	74 35                	je     800a94 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a5f:	89 d0                	mov    %edx,%eax
  800a61:	83 e8 01             	sub    $0x1,%eax
  800a64:	74 25                	je     800a8b <strlcpy+0x40>
  800a66:	0f b6 0b             	movzbl (%ebx),%ecx
  800a69:	84 c9                	test   %cl,%cl
  800a6b:	74 22                	je     800a8f <strlcpy+0x44>
  800a6d:	8d 53 01             	lea    0x1(%ebx),%edx
  800a70:	01 c3                	add    %eax,%ebx
  800a72:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a7a:	39 da                	cmp    %ebx,%edx
  800a7c:	74 13                	je     800a91 <strlcpy+0x46>
  800a7e:	83 c2 01             	add    $0x1,%edx
  800a81:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a85:	84 c9                	test   %cl,%cl
  800a87:	75 eb                	jne    800a74 <strlcpy+0x29>
  800a89:	eb 06                	jmp    800a91 <strlcpy+0x46>
  800a8b:	89 f0                	mov    %esi,%eax
  800a8d:	eb 02                	jmp    800a91 <strlcpy+0x46>
  800a8f:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a94:	29 f0                	sub    %esi,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa3:	0f b6 01             	movzbl (%ecx),%eax
  800aa6:	84 c0                	test   %al,%al
  800aa8:	74 15                	je     800abf <strcmp+0x25>
  800aaa:	3a 02                	cmp    (%edx),%al
  800aac:	75 11                	jne    800abf <strcmp+0x25>
		p++, q++;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab4:	0f b6 01             	movzbl (%ecx),%eax
  800ab7:	84 c0                	test   %al,%al
  800ab9:	74 04                	je     800abf <strcmp+0x25>
  800abb:	3a 02                	cmp    (%edx),%al
  800abd:	74 ef                	je     800aae <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800abf:	0f b6 c0             	movzbl %al,%eax
  800ac2:	0f b6 12             	movzbl (%edx),%edx
  800ac5:	29 d0                	sub    %edx,%eax
}
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad4:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800ad7:	85 f6                	test   %esi,%esi
  800ad9:	74 29                	je     800b04 <strncmp+0x3b>
  800adb:	0f b6 03             	movzbl (%ebx),%eax
  800ade:	84 c0                	test   %al,%al
  800ae0:	74 30                	je     800b12 <strncmp+0x49>
  800ae2:	3a 02                	cmp    (%edx),%al
  800ae4:	75 2c                	jne    800b12 <strncmp+0x49>
  800ae6:	8d 43 01             	lea    0x1(%ebx),%eax
  800ae9:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800aeb:	89 c3                	mov    %eax,%ebx
  800aed:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af0:	39 c6                	cmp    %eax,%esi
  800af2:	74 17                	je     800b0b <strncmp+0x42>
  800af4:	0f b6 08             	movzbl (%eax),%ecx
  800af7:	84 c9                	test   %cl,%cl
  800af9:	74 17                	je     800b12 <strncmp+0x49>
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	3a 0a                	cmp    (%edx),%cl
  800b00:	74 e9                	je     800aeb <strncmp+0x22>
  800b02:	eb 0e                	jmp    800b12 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	eb 0f                	jmp    800b1a <strncmp+0x51>
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	eb 08                	jmp    800b1a <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b12:	0f b6 03             	movzbl (%ebx),%eax
  800b15:	0f b6 12             	movzbl (%edx),%edx
  800b18:	29 d0                	sub    %edx,%eax
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	53                   	push   %ebx
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b28:	0f b6 10             	movzbl (%eax),%edx
  800b2b:	84 d2                	test   %dl,%dl
  800b2d:	74 1d                	je     800b4c <strchr+0x2e>
  800b2f:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b31:	38 d3                	cmp    %dl,%bl
  800b33:	75 06                	jne    800b3b <strchr+0x1d>
  800b35:	eb 1a                	jmp    800b51 <strchr+0x33>
  800b37:	38 ca                	cmp    %cl,%dl
  800b39:	74 16                	je     800b51 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3b:	83 c0 01             	add    $0x1,%eax
  800b3e:	0f b6 10             	movzbl (%eax),%edx
  800b41:	84 d2                	test   %dl,%dl
  800b43:	75 f2                	jne    800b37 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4a:	eb 05                	jmp    800b51 <strchr+0x33>
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b51:	5b                   	pop    %ebx
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	53                   	push   %ebx
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b5e:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b61:	38 d3                	cmp    %dl,%bl
  800b63:	74 14                	je     800b79 <strfind+0x25>
  800b65:	89 d1                	mov    %edx,%ecx
  800b67:	84 db                	test   %bl,%bl
  800b69:	74 0e                	je     800b79 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b6b:	83 c0 01             	add    $0x1,%eax
  800b6e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 04                	je     800b79 <strfind+0x25>
  800b75:	84 d2                	test   %dl,%dl
  800b77:	75 f2                	jne    800b6b <strfind+0x17>
			break;
	return (char *) s;
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b88:	85 c9                	test   %ecx,%ecx
  800b8a:	74 36                	je     800bc2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b92:	75 28                	jne    800bbc <memset+0x40>
  800b94:	f6 c1 03             	test   $0x3,%cl
  800b97:	75 23                	jne    800bbc <memset+0x40>
		c &= 0xFF;
  800b99:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	c1 e3 08             	shl    $0x8,%ebx
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	c1 e6 18             	shl    $0x18,%esi
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	c1 e0 10             	shl    $0x10,%eax
  800bac:	09 f0                	or     %esi,%eax
  800bae:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bb0:	89 d8                	mov    %ebx,%eax
  800bb2:	09 d0                	or     %edx,%eax
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
  800bb7:	fc                   	cld    
  800bb8:	f3 ab                	rep stos %eax,%es:(%edi)
  800bba:	eb 06                	jmp    800bc2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	fc                   	cld    
  800bc0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc2:	89 f8                	mov    %edi,%eax
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd7:	39 c6                	cmp    %eax,%esi
  800bd9:	73 35                	jae    800c10 <memmove+0x47>
  800bdb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bde:	39 d0                	cmp    %edx,%eax
  800be0:	73 2e                	jae    800c10 <memmove+0x47>
		s += n;
		d += n;
  800be2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be5:	89 d6                	mov    %edx,%esi
  800be7:	09 fe                	or     %edi,%esi
  800be9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bef:	75 13                	jne    800c04 <memmove+0x3b>
  800bf1:	f6 c1 03             	test   $0x3,%cl
  800bf4:	75 0e                	jne    800c04 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bf6:	83 ef 04             	sub    $0x4,%edi
  800bf9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bfc:	c1 e9 02             	shr    $0x2,%ecx
  800bff:	fd                   	std    
  800c00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c02:	eb 09                	jmp    800c0d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c04:	83 ef 01             	sub    $0x1,%edi
  800c07:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c0a:	fd                   	std    
  800c0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c0d:	fc                   	cld    
  800c0e:	eb 1d                	jmp    800c2d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c10:	89 f2                	mov    %esi,%edx
  800c12:	09 c2                	or     %eax,%edx
  800c14:	f6 c2 03             	test   $0x3,%dl
  800c17:	75 0f                	jne    800c28 <memmove+0x5f>
  800c19:	f6 c1 03             	test   $0x3,%cl
  800c1c:	75 0a                	jne    800c28 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c1e:	c1 e9 02             	shr    $0x2,%ecx
  800c21:	89 c7                	mov    %eax,%edi
  800c23:	fc                   	cld    
  800c24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c26:	eb 05                	jmp    800c2d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c28:	89 c7                	mov    %eax,%edi
  800c2a:	fc                   	cld    
  800c2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c34:	ff 75 10             	pushl  0x10(%ebp)
  800c37:	ff 75 0c             	pushl  0xc(%ebp)
  800c3a:	ff 75 08             	pushl  0x8(%ebp)
  800c3d:	e8 87 ff ff ff       	call   800bc9 <memmove>
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c50:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c53:	85 c0                	test   %eax,%eax
  800c55:	74 39                	je     800c90 <memcmp+0x4c>
  800c57:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c5a:	0f b6 13             	movzbl (%ebx),%edx
  800c5d:	0f b6 0e             	movzbl (%esi),%ecx
  800c60:	38 ca                	cmp    %cl,%dl
  800c62:	75 17                	jne    800c7b <memcmp+0x37>
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
  800c69:	eb 1a                	jmp    800c85 <memcmp+0x41>
  800c6b:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c70:	83 c0 01             	add    $0x1,%eax
  800c73:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c77:	38 ca                	cmp    %cl,%dl
  800c79:	74 0a                	je     800c85 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c7b:	0f b6 c2             	movzbl %dl,%eax
  800c7e:	0f b6 c9             	movzbl %cl,%ecx
  800c81:	29 c8                	sub    %ecx,%eax
  800c83:	eb 10                	jmp    800c95 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c85:	39 f8                	cmp    %edi,%eax
  800c87:	75 e2                	jne    800c6b <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c89:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8e:	eb 05                	jmp    800c95 <memcmp+0x51>
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	53                   	push   %ebx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800ca1:	89 d0                	mov    %edx,%eax
  800ca3:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800ca6:	39 c2                	cmp    %eax,%edx
  800ca8:	73 1d                	jae    800cc7 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800caa:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800cae:	0f b6 0a             	movzbl (%edx),%ecx
  800cb1:	39 d9                	cmp    %ebx,%ecx
  800cb3:	75 09                	jne    800cbe <memfind+0x24>
  800cb5:	eb 14                	jmp    800ccb <memfind+0x31>
  800cb7:	0f b6 0a             	movzbl (%edx),%ecx
  800cba:	39 d9                	cmp    %ebx,%ecx
  800cbc:	74 11                	je     800ccf <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbe:	83 c2 01             	add    $0x1,%edx
  800cc1:	39 d0                	cmp    %edx,%eax
  800cc3:	75 f2                	jne    800cb7 <memfind+0x1d>
  800cc5:	eb 0a                	jmp    800cd1 <memfind+0x37>
  800cc7:	89 d0                	mov    %edx,%eax
  800cc9:	eb 06                	jmp    800cd1 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ccb:	89 d0                	mov    %edx,%eax
  800ccd:	eb 02                	jmp    800cd1 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ccf:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce0:	0f b6 01             	movzbl (%ecx),%eax
  800ce3:	3c 20                	cmp    $0x20,%al
  800ce5:	74 04                	je     800ceb <strtol+0x17>
  800ce7:	3c 09                	cmp    $0x9,%al
  800ce9:	75 0e                	jne    800cf9 <strtol+0x25>
		s++;
  800ceb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cee:	0f b6 01             	movzbl (%ecx),%eax
  800cf1:	3c 20                	cmp    $0x20,%al
  800cf3:	74 f6                	je     800ceb <strtol+0x17>
  800cf5:	3c 09                	cmp    $0x9,%al
  800cf7:	74 f2                	je     800ceb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf9:	3c 2b                	cmp    $0x2b,%al
  800cfb:	75 0a                	jne    800d07 <strtol+0x33>
		s++;
  800cfd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d00:	bf 00 00 00 00       	mov    $0x0,%edi
  800d05:	eb 11                	jmp    800d18 <strtol+0x44>
  800d07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d0c:	3c 2d                	cmp    $0x2d,%al
  800d0e:	75 08                	jne    800d18 <strtol+0x44>
		s++, neg = 1;
  800d10:	83 c1 01             	add    $0x1,%ecx
  800d13:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d18:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d1e:	75 15                	jne    800d35 <strtol+0x61>
  800d20:	80 39 30             	cmpb   $0x30,(%ecx)
  800d23:	75 10                	jne    800d35 <strtol+0x61>
  800d25:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d29:	75 7c                	jne    800da7 <strtol+0xd3>
		s += 2, base = 16;
  800d2b:	83 c1 02             	add    $0x2,%ecx
  800d2e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d33:	eb 16                	jmp    800d4b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d35:	85 db                	test   %ebx,%ebx
  800d37:	75 12                	jne    800d4b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d39:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800d41:	75 08                	jne    800d4b <strtol+0x77>
		s++, base = 8;
  800d43:	83 c1 01             	add    $0x1,%ecx
  800d46:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d50:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d53:	0f b6 11             	movzbl (%ecx),%edx
  800d56:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d59:	89 f3                	mov    %esi,%ebx
  800d5b:	80 fb 09             	cmp    $0x9,%bl
  800d5e:	77 08                	ja     800d68 <strtol+0x94>
			dig = *s - '0';
  800d60:	0f be d2             	movsbl %dl,%edx
  800d63:	83 ea 30             	sub    $0x30,%edx
  800d66:	eb 22                	jmp    800d8a <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d68:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d6b:	89 f3                	mov    %esi,%ebx
  800d6d:	80 fb 19             	cmp    $0x19,%bl
  800d70:	77 08                	ja     800d7a <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d72:	0f be d2             	movsbl %dl,%edx
  800d75:	83 ea 57             	sub    $0x57,%edx
  800d78:	eb 10                	jmp    800d8a <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d7a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d7d:	89 f3                	mov    %esi,%ebx
  800d7f:	80 fb 19             	cmp    $0x19,%bl
  800d82:	77 16                	ja     800d9a <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d84:	0f be d2             	movsbl %dl,%edx
  800d87:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d8a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d8d:	7d 0b                	jge    800d9a <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d8f:	83 c1 01             	add    $0x1,%ecx
  800d92:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d96:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d98:	eb b9                	jmp    800d53 <strtol+0x7f>

	if (endptr)
  800d9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9e:	74 0d                	je     800dad <strtol+0xd9>
		*endptr = (char *) s;
  800da0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da3:	89 0e                	mov    %ecx,(%esi)
  800da5:	eb 06                	jmp    800dad <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800da7:	85 db                	test   %ebx,%ebx
  800da9:	74 98                	je     800d43 <strtol+0x6f>
  800dab:	eb 9e                	jmp    800d4b <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	f7 da                	neg    %edx
  800db1:	85 ff                	test   %edi,%edi
  800db3:	0f 45 c2             	cmovne %edx,%eax
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	89 c3                	mov    %eax,%ebx
  800dcd:	89 c7                	mov    %eax,%edi
  800dcf:	51                   	push   %ecx
  800dd0:	52                   	push   %edx
  800dd1:	53                   	push   %ebx
  800dd2:	54                   	push   %esp
  800dd3:	55                   	push   %ebp
  800dd4:	56                   	push   %esi
  800dd5:	57                   	push   %edi
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	8d 35 e0 0d 80 00    	lea    0x800de0,%esi
  800dde:	0f 34                	sysenter 

00800de0 <label_21>:
  800de0:	5f                   	pop    %edi
  800de1:	5e                   	pop    %esi
  800de2:	5d                   	pop    %ebp
  800de3:	5c                   	pop    %esp
  800de4:	5b                   	pop    %ebx
  800de5:	5a                   	pop    %edx
  800de6:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de7:	5b                   	pop    %ebx
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_cgetc>:

int
sys_cgetc(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800df0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df5:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfa:	89 ca                	mov    %ecx,%edx
  800dfc:	89 cb                	mov    %ecx,%ebx
  800dfe:	89 cf                	mov    %ecx,%edi
  800e00:	51                   	push   %ecx
  800e01:	52                   	push   %edx
  800e02:	53                   	push   %ebx
  800e03:	54                   	push   %esp
  800e04:	55                   	push   %ebp
  800e05:	56                   	push   %esi
  800e06:	57                   	push   %edi
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	8d 35 11 0e 80 00    	lea    0x800e11,%esi
  800e0f:	0f 34                	sysenter 

00800e11 <label_55>:
  800e11:	5f                   	pop    %edi
  800e12:	5e                   	pop    %esi
  800e13:	5d                   	pop    %ebp
  800e14:	5c                   	pop    %esp
  800e15:	5b                   	pop    %ebx
  800e16:	5a                   	pop    %edx
  800e17:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e18:	5b                   	pop    %ebx
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e26:	b8 03 00 00 00       	mov    $0x3,%eax
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	89 d9                	mov    %ebx,%ecx
  800e30:	89 df                	mov    %ebx,%edi
  800e32:	51                   	push   %ecx
  800e33:	52                   	push   %edx
  800e34:	53                   	push   %ebx
  800e35:	54                   	push   %esp
  800e36:	55                   	push   %ebp
  800e37:	56                   	push   %esi
  800e38:	57                   	push   %edi
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8d 35 43 0e 80 00    	lea    0x800e43,%esi
  800e41:	0f 34                	sysenter 

00800e43 <label_90>:
  800e43:	5f                   	pop    %edi
  800e44:	5e                   	pop    %esi
  800e45:	5d                   	pop    %ebp
  800e46:	5c                   	pop    %esp
  800e47:	5b                   	pop    %ebx
  800e48:	5a                   	pop    %edx
  800e49:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	7e 17                	jle    800e65 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800e4e:	83 ec 0c             	sub    $0xc,%esp
  800e51:	50                   	push   %eax
  800e52:	6a 03                	push   $0x3
  800e54:	68 ac 14 80 00       	push   $0x8014ac
  800e59:	6a 2a                	push   $0x2a
  800e5b:	68 c9 14 80 00       	push   $0x8014c9
  800e60:	e8 9d 00 00 00       	call   800f02 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e76:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7b:	89 ca                	mov    %ecx,%edx
  800e7d:	89 cb                	mov    %ecx,%ebx
  800e7f:	89 cf                	mov    %ecx,%edi
  800e81:	51                   	push   %ecx
  800e82:	52                   	push   %edx
  800e83:	53                   	push   %ebx
  800e84:	54                   	push   %esp
  800e85:	55                   	push   %ebp
  800e86:	56                   	push   %esi
  800e87:	57                   	push   %edi
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	8d 35 92 0e 80 00    	lea    0x800e92,%esi
  800e90:	0f 34                	sysenter 

00800e92 <label_139>:
  800e92:	5f                   	pop    %edi
  800e93:	5e                   	pop    %esi
  800e94:	5d                   	pop    %ebp
  800e95:	5c                   	pop    %esp
  800e96:	5b                   	pop    %ebx
  800e97:	5a                   	pop    %edx
  800e98:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e99:	5b                   	pop    %ebx
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ea2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ea7:	b8 04 00 00 00       	mov    $0x4,%eax
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	89 fb                	mov    %edi,%ebx
  800eb4:	51                   	push   %ecx
  800eb5:	52                   	push   %edx
  800eb6:	53                   	push   %ebx
  800eb7:	54                   	push   %esp
  800eb8:	55                   	push   %ebp
  800eb9:	56                   	push   %esi
  800eba:	57                   	push   %edi
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	8d 35 c5 0e 80 00    	lea    0x800ec5,%esi
  800ec3:	0f 34                	sysenter 

00800ec5 <label_174>:
  800ec5:	5f                   	pop    %edi
  800ec6:	5e                   	pop    %esi
  800ec7:	5d                   	pop    %ebp
  800ec8:	5c                   	pop    %esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5a                   	pop    %edx
  800ecb:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ecc:	5b                   	pop    %ebx
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eda:	b8 05 00 00 00       	mov    $0x5,%eax
  800edf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee2:	89 cb                	mov    %ecx,%ebx
  800ee4:	89 cf                	mov    %ecx,%edi
  800ee6:	51                   	push   %ecx
  800ee7:	52                   	push   %edx
  800ee8:	53                   	push   %ebx
  800ee9:	54                   	push   %esp
  800eea:	55                   	push   %ebp
  800eeb:	56                   	push   %esi
  800eec:	57                   	push   %edi
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	8d 35 f7 0e 80 00    	lea    0x800ef7,%esi
  800ef5:	0f 34                	sysenter 

00800ef7 <label_209>:
  800ef7:	5f                   	pop    %edi
  800ef8:	5e                   	pop    %esi
  800ef9:	5d                   	pop    %ebp
  800efa:	5c                   	pop    %esp
  800efb:	5b                   	pop    %ebx
  800efc:	5a                   	pop    %edx
  800efd:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800efe:	5b                   	pop    %ebx
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f07:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800f0a:	a1 10 20 80 00       	mov    0x802010,%eax
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	74 11                	je     800f24 <_panic+0x22>
		cprintf("%s: ", argv0);
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	50                   	push   %eax
  800f17:	68 d7 14 80 00       	push   $0x8014d7
  800f1c:	e8 83 f2 ff ff       	call   8001a4 <cprintf>
  800f21:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f24:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f2a:	e8 3d ff ff ff       	call   800e6c <sys_getenvid>
  800f2f:	83 ec 0c             	sub    $0xc,%esp
  800f32:	ff 75 0c             	pushl  0xc(%ebp)
  800f35:	ff 75 08             	pushl  0x8(%ebp)
  800f38:	56                   	push   %esi
  800f39:	50                   	push   %eax
  800f3a:	68 dc 14 80 00       	push   $0x8014dc
  800f3f:	e8 60 f2 ff ff       	call   8001a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f44:	83 c4 18             	add    $0x18,%esp
  800f47:	53                   	push   %ebx
  800f48:	ff 75 10             	pushl  0x10(%ebp)
  800f4b:	e8 03 f2 ff ff       	call   800153 <vcprintf>
	cprintf("\n");
  800f50:	c7 04 24 21 12 80 00 	movl   $0x801221,(%esp)
  800f57:	e8 48 f2 ff ff       	call   8001a4 <cprintf>
  800f5c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f5f:	cc                   	int3   
  800f60:	eb fd                	jmp    800f5f <_panic+0x5d>
  800f62:	66 90                	xchg   %ax,%ax
  800f64:	66 90                	xchg   %ax,%ax
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__udivdi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 1c             	sub    $0x1c,%esp
  800f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f87:	85 f6                	test   %esi,%esi
  800f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f8d:	89 ca                	mov    %ecx,%edx
  800f8f:	89 f8                	mov    %edi,%eax
  800f91:	75 3d                	jne    800fd0 <__udivdi3+0x60>
  800f93:	39 cf                	cmp    %ecx,%edi
  800f95:	0f 87 c5 00 00 00    	ja     801060 <__udivdi3+0xf0>
  800f9b:	85 ff                	test   %edi,%edi
  800f9d:	89 fd                	mov    %edi,%ebp
  800f9f:	75 0b                	jne    800fac <__udivdi3+0x3c>
  800fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa6:	31 d2                	xor    %edx,%edx
  800fa8:	f7 f7                	div    %edi
  800faa:	89 c5                	mov    %eax,%ebp
  800fac:	89 c8                	mov    %ecx,%eax
  800fae:	31 d2                	xor    %edx,%edx
  800fb0:	f7 f5                	div    %ebp
  800fb2:	89 c1                	mov    %eax,%ecx
  800fb4:	89 d8                	mov    %ebx,%eax
  800fb6:	89 cf                	mov    %ecx,%edi
  800fb8:	f7 f5                	div    %ebp
  800fba:	89 c3                	mov    %eax,%ebx
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	89 fa                	mov    %edi,%edx
  800fc0:	83 c4 1c             	add    $0x1c,%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    
  800fc8:	90                   	nop
  800fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	39 ce                	cmp    %ecx,%esi
  800fd2:	77 74                	ja     801048 <__udivdi3+0xd8>
  800fd4:	0f bd fe             	bsr    %esi,%edi
  800fd7:	83 f7 1f             	xor    $0x1f,%edi
  800fda:	0f 84 98 00 00 00    	je     801078 <__udivdi3+0x108>
  800fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800fe5:	89 f9                	mov    %edi,%ecx
  800fe7:	89 c5                	mov    %eax,%ebp
  800fe9:	29 fb                	sub    %edi,%ebx
  800feb:	d3 e6                	shl    %cl,%esi
  800fed:	89 d9                	mov    %ebx,%ecx
  800fef:	d3 ed                	shr    %cl,%ebp
  800ff1:	89 f9                	mov    %edi,%ecx
  800ff3:	d3 e0                	shl    %cl,%eax
  800ff5:	09 ee                	or     %ebp,%esi
  800ff7:	89 d9                	mov    %ebx,%ecx
  800ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ffd:	89 d5                	mov    %edx,%ebp
  800fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801003:	d3 ed                	shr    %cl,%ebp
  801005:	89 f9                	mov    %edi,%ecx
  801007:	d3 e2                	shl    %cl,%edx
  801009:	89 d9                	mov    %ebx,%ecx
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	09 c2                	or     %eax,%edx
  80100f:	89 d0                	mov    %edx,%eax
  801011:	89 ea                	mov    %ebp,%edx
  801013:	f7 f6                	div    %esi
  801015:	89 d5                	mov    %edx,%ebp
  801017:	89 c3                	mov    %eax,%ebx
  801019:	f7 64 24 0c          	mull   0xc(%esp)
  80101d:	39 d5                	cmp    %edx,%ebp
  80101f:	72 10                	jb     801031 <__udivdi3+0xc1>
  801021:	8b 74 24 08          	mov    0x8(%esp),%esi
  801025:	89 f9                	mov    %edi,%ecx
  801027:	d3 e6                	shl    %cl,%esi
  801029:	39 c6                	cmp    %eax,%esi
  80102b:	73 07                	jae    801034 <__udivdi3+0xc4>
  80102d:	39 d5                	cmp    %edx,%ebp
  80102f:	75 03                	jne    801034 <__udivdi3+0xc4>
  801031:	83 eb 01             	sub    $0x1,%ebx
  801034:	31 ff                	xor    %edi,%edi
  801036:	89 d8                	mov    %ebx,%eax
  801038:	89 fa                	mov    %edi,%edx
  80103a:	83 c4 1c             	add    $0x1c,%esp
  80103d:	5b                   	pop    %ebx
  80103e:	5e                   	pop    %esi
  80103f:	5f                   	pop    %edi
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    
  801042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801048:	31 ff                	xor    %edi,%edi
  80104a:	31 db                	xor    %ebx,%ebx
  80104c:	89 d8                	mov    %ebx,%eax
  80104e:	89 fa                	mov    %edi,%edx
  801050:	83 c4 1c             	add    $0x1c,%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    
  801058:	90                   	nop
  801059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801060:	89 d8                	mov    %ebx,%eax
  801062:	f7 f7                	div    %edi
  801064:	31 ff                	xor    %edi,%edi
  801066:	89 c3                	mov    %eax,%ebx
  801068:	89 d8                	mov    %ebx,%eax
  80106a:	89 fa                	mov    %edi,%edx
  80106c:	83 c4 1c             	add    $0x1c,%esp
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    
  801074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801078:	39 ce                	cmp    %ecx,%esi
  80107a:	72 0c                	jb     801088 <__udivdi3+0x118>
  80107c:	31 db                	xor    %ebx,%ebx
  80107e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801082:	0f 87 34 ff ff ff    	ja     800fbc <__udivdi3+0x4c>
  801088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80108d:	e9 2a ff ff ff       	jmp    800fbc <__udivdi3+0x4c>
  801092:	66 90                	xchg   %ax,%ax
  801094:	66 90                	xchg   %ax,%ax
  801096:	66 90                	xchg   %ax,%ax
  801098:	66 90                	xchg   %ax,%ax
  80109a:	66 90                	xchg   %ax,%ax
  80109c:	66 90                	xchg   %ax,%ax
  80109e:	66 90                	xchg   %ax,%ax

008010a0 <__umoddi3>:
  8010a0:	55                   	push   %ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 1c             	sub    $0x1c,%esp
  8010a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8010ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8010af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8010b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010b7:	85 d2                	test   %edx,%edx
  8010b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8010bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c1:	89 f3                	mov    %esi,%ebx
  8010c3:	89 3c 24             	mov    %edi,(%esp)
  8010c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ca:	75 1c                	jne    8010e8 <__umoddi3+0x48>
  8010cc:	39 f7                	cmp    %esi,%edi
  8010ce:	76 50                	jbe    801120 <__umoddi3+0x80>
  8010d0:	89 c8                	mov    %ecx,%eax
  8010d2:	89 f2                	mov    %esi,%edx
  8010d4:	f7 f7                	div    %edi
  8010d6:	89 d0                	mov    %edx,%eax
  8010d8:	31 d2                	xor    %edx,%edx
  8010da:	83 c4 1c             	add    $0x1c,%esp
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5f                   	pop    %edi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    
  8010e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010e8:	39 f2                	cmp    %esi,%edx
  8010ea:	89 d0                	mov    %edx,%eax
  8010ec:	77 52                	ja     801140 <__umoddi3+0xa0>
  8010ee:	0f bd ea             	bsr    %edx,%ebp
  8010f1:	83 f5 1f             	xor    $0x1f,%ebp
  8010f4:	75 5a                	jne    801150 <__umoddi3+0xb0>
  8010f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8010fa:	0f 82 e0 00 00 00    	jb     8011e0 <__umoddi3+0x140>
  801100:	39 0c 24             	cmp    %ecx,(%esp)
  801103:	0f 86 d7 00 00 00    	jbe    8011e0 <__umoddi3+0x140>
  801109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80110d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801111:	83 c4 1c             	add    $0x1c,%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    
  801119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801120:	85 ff                	test   %edi,%edi
  801122:	89 fd                	mov    %edi,%ebp
  801124:	75 0b                	jne    801131 <__umoddi3+0x91>
  801126:	b8 01 00 00 00       	mov    $0x1,%eax
  80112b:	31 d2                	xor    %edx,%edx
  80112d:	f7 f7                	div    %edi
  80112f:	89 c5                	mov    %eax,%ebp
  801131:	89 f0                	mov    %esi,%eax
  801133:	31 d2                	xor    %edx,%edx
  801135:	f7 f5                	div    %ebp
  801137:	89 c8                	mov    %ecx,%eax
  801139:	f7 f5                	div    %ebp
  80113b:	89 d0                	mov    %edx,%eax
  80113d:	eb 99                	jmp    8010d8 <__umoddi3+0x38>
  80113f:	90                   	nop
  801140:	89 c8                	mov    %ecx,%eax
  801142:	89 f2                	mov    %esi,%edx
  801144:	83 c4 1c             	add    $0x1c,%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    
  80114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801150:	8b 34 24             	mov    (%esp),%esi
  801153:	bf 20 00 00 00       	mov    $0x20,%edi
  801158:	89 e9                	mov    %ebp,%ecx
  80115a:	29 ef                	sub    %ebp,%edi
  80115c:	d3 e0                	shl    %cl,%eax
  80115e:	89 f9                	mov    %edi,%ecx
  801160:	89 f2                	mov    %esi,%edx
  801162:	d3 ea                	shr    %cl,%edx
  801164:	89 e9                	mov    %ebp,%ecx
  801166:	09 c2                	or     %eax,%edx
  801168:	89 d8                	mov    %ebx,%eax
  80116a:	89 14 24             	mov    %edx,(%esp)
  80116d:	89 f2                	mov    %esi,%edx
  80116f:	d3 e2                	shl    %cl,%edx
  801171:	89 f9                	mov    %edi,%ecx
  801173:	89 54 24 04          	mov    %edx,0x4(%esp)
  801177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80117b:	d3 e8                	shr    %cl,%eax
  80117d:	89 e9                	mov    %ebp,%ecx
  80117f:	89 c6                	mov    %eax,%esi
  801181:	d3 e3                	shl    %cl,%ebx
  801183:	89 f9                	mov    %edi,%ecx
  801185:	89 d0                	mov    %edx,%eax
  801187:	d3 e8                	shr    %cl,%eax
  801189:	89 e9                	mov    %ebp,%ecx
  80118b:	09 d8                	or     %ebx,%eax
  80118d:	89 d3                	mov    %edx,%ebx
  80118f:	89 f2                	mov    %esi,%edx
  801191:	f7 34 24             	divl   (%esp)
  801194:	89 d6                	mov    %edx,%esi
  801196:	d3 e3                	shl    %cl,%ebx
  801198:	f7 64 24 04          	mull   0x4(%esp)
  80119c:	39 d6                	cmp    %edx,%esi
  80119e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011a2:	89 d1                	mov    %edx,%ecx
  8011a4:	89 c3                	mov    %eax,%ebx
  8011a6:	72 08                	jb     8011b0 <__umoddi3+0x110>
  8011a8:	75 11                	jne    8011bb <__umoddi3+0x11b>
  8011aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8011ae:	73 0b                	jae    8011bb <__umoddi3+0x11b>
  8011b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8011b4:	1b 14 24             	sbb    (%esp),%edx
  8011b7:	89 d1                	mov    %edx,%ecx
  8011b9:	89 c3                	mov    %eax,%ebx
  8011bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8011bf:	29 da                	sub    %ebx,%edx
  8011c1:	19 ce                	sbb    %ecx,%esi
  8011c3:	89 f9                	mov    %edi,%ecx
  8011c5:	89 f0                	mov    %esi,%eax
  8011c7:	d3 e0                	shl    %cl,%eax
  8011c9:	89 e9                	mov    %ebp,%ecx
  8011cb:	d3 ea                	shr    %cl,%edx
  8011cd:	89 e9                	mov    %ebp,%ecx
  8011cf:	d3 ee                	shr    %cl,%esi
  8011d1:	09 d0                	or     %edx,%eax
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	83 c4 1c             	add    $0x1c,%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    
  8011dd:	8d 76 00             	lea    0x0(%esi),%esi
  8011e0:	29 f9                	sub    %edi,%ecx
  8011e2:	19 d6                	sbb    %edx,%esi
  8011e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ec:	e9 18 ff ff ff       	jmp    801109 <__umoddi3+0x69>
