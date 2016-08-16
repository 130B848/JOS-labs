
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 20 14 80 00       	push   $0x801420
  800048:	e8 38 01 00 00       	call   800185 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 57 0e 00 00       	call   800eb1 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 0c 20 80 00       	mov    0x80200c,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 40 14 80 00       	push   $0x801440
  80006c:	e8 14 01 00 00       	call   800185 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 6c 14 80 00       	push   $0x80146c
  80008d:	e8 f3 00 00 00       	call   800185 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a5:	e8 a3 0d 00 00       	call   800e4d <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	c1 e0 07             	shl    $0x7,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 10 0d 00 00       	call   800dfd <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 1a                	jne    80012b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 7a 0c 00 00       	call   800d9c <sys_cputs>
		b->idx = 0;
  800122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800128:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	68 f2 00 80 00       	push   $0x8000f2
  800163:	e8 c0 02 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800168:	83 c4 08             	add    $0x8,%esp
  80016b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800171:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	e8 1f 0c 00 00       	call   800d9c <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018e:	50                   	push   %eax
  80018f:	ff 75 08             	pushl  0x8(%ebp)
  800192:	e8 9d ff ff ff       	call   800134 <vcprintf>
	va_end(ap);

	return cnt;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 1c             	sub    $0x1c,%esp
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	89 d6                	mov    %edx,%esi
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  8001b5:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001b9:	0f 85 bf 00 00 00    	jne    80027e <printnum+0xe5>
  8001bf:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8001c5:	0f 8d de 00 00 00    	jge    8002a9 <printnum+0x110>
		judge_time_for_space = width;
  8001cb:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8001d1:	e9 d3 00 00 00       	jmp    8002a9 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001d6:	83 eb 01             	sub    $0x1,%ebx
  8001d9:	85 db                	test   %ebx,%ebx
  8001db:	7f 37                	jg     800214 <printnum+0x7b>
  8001dd:	e9 ea 00 00 00       	jmp    8002cc <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8001e2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001e5:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	56                   	push   %esi
  8001ee:	83 ec 04             	sub    $0x4,%esp
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	e8 be 10 00 00       	call   8012c0 <__umoddi3>
  800202:	83 c4 14             	add    $0x14,%esp
  800205:	0f be 80 95 14 80 00 	movsbl 0x801495(%eax),%eax
  80020c:	50                   	push   %eax
  80020d:	ff d7                	call   *%edi
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	eb 16                	jmp    80022a <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	56                   	push   %esi
  800218:	ff 75 18             	pushl  0x18(%ebp)
  80021b:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	75 ef                	jne    800214 <printnum+0x7b>
  800225:	e9 a2 00 00 00       	jmp    8002cc <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  80022a:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800230:	0f 85 76 01 00 00    	jne    8003ac <printnum+0x213>
		while(num_of_space-- > 0)
  800236:	a1 04 20 80 00       	mov    0x802004,%eax
  80023b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80023e:	89 15 04 20 80 00    	mov    %edx,0x802004
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 1d                	jle    800265 <printnum+0xcc>
			putch(' ', putdat);
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	56                   	push   %esi
  80024c:	6a 20                	push   $0x20
  80024e:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800250:	a1 04 20 80 00       	mov    0x802004,%eax
  800255:	8d 50 ff             	lea    -0x1(%eax),%edx
  800258:	89 15 04 20 80 00    	mov    %edx,0x802004
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	85 c0                	test   %eax,%eax
  800263:	7f e3                	jg     800248 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800265:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80026c:	00 00 00 
		judge_time_for_space = 0;
  80026f:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800276:	00 00 00 
	}
}
  800279:	e9 2e 01 00 00       	jmp    8003ac <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027e:	8b 45 10             	mov    0x10(%ebp),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
  800286:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800289:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80028c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80028f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800292:	83 fa 00             	cmp    $0x0,%edx
  800295:	0f 87 ba 00 00 00    	ja     800355 <printnum+0x1bc>
  80029b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80029e:	0f 83 b1 00 00 00    	jae    800355 <printnum+0x1bc>
  8002a4:	e9 2d ff ff ff       	jmp    8001d6 <printnum+0x3d>
  8002a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002bd:	83 fa 00             	cmp    $0x0,%edx
  8002c0:	77 37                	ja     8002f9 <printnum+0x160>
  8002c2:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002c5:	73 32                	jae    8002f9 <printnum+0x160>
  8002c7:	e9 16 ff ff ff       	jmp    8001e2 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	56                   	push   %esi
  8002d0:	83 ec 04             	sub    $0x4,%esp
  8002d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8002df:	e8 dc 0f 00 00       	call   8012c0 <__umoddi3>
  8002e4:	83 c4 14             	add    $0x14,%esp
  8002e7:	0f be 80 95 14 80 00 	movsbl 0x801495(%eax),%eax
  8002ee:	50                   	push   %eax
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	e9 b3 00 00 00       	jmp    8003ac <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f9:	83 ec 0c             	sub    $0xc,%esp
  8002fc:	ff 75 18             	pushl  0x18(%ebp)
  8002ff:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800302:	50                   	push   %eax
  800303:	ff 75 10             	pushl  0x10(%ebp)
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	ff 75 dc             	pushl  -0x24(%ebp)
  80030c:	ff 75 d8             	pushl  -0x28(%ebp)
  80030f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800312:	ff 75 e0             	pushl  -0x20(%ebp)
  800315:	e8 76 0e 00 00       	call   801190 <__udivdi3>
  80031a:	83 c4 18             	add    $0x18,%esp
  80031d:	52                   	push   %edx
  80031e:	50                   	push   %eax
  80031f:	89 f2                	mov    %esi,%edx
  800321:	89 f8                	mov    %edi,%eax
  800323:	e8 71 fe ff ff       	call   800199 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800328:	83 c4 18             	add    $0x18,%esp
  80032b:	56                   	push   %esi
  80032c:	83 ec 04             	sub    $0x4,%esp
  80032f:	ff 75 dc             	pushl  -0x24(%ebp)
  800332:	ff 75 d8             	pushl  -0x28(%ebp)
  800335:	ff 75 e4             	pushl  -0x1c(%ebp)
  800338:	ff 75 e0             	pushl  -0x20(%ebp)
  80033b:	e8 80 0f 00 00       	call   8012c0 <__umoddi3>
  800340:	83 c4 14             	add    $0x14,%esp
  800343:	0f be 80 95 14 80 00 	movsbl 0x801495(%eax),%eax
  80034a:	50                   	push   %eax
  80034b:	ff d7                	call   *%edi
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	e9 d5 fe ff ff       	jmp    80022a <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800355:	83 ec 0c             	sub    $0xc,%esp
  800358:	ff 75 18             	pushl  0x18(%ebp)
  80035b:	83 eb 01             	sub    $0x1,%ebx
  80035e:	53                   	push   %ebx
  80035f:	ff 75 10             	pushl  0x10(%ebp)
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	ff 75 dc             	pushl  -0x24(%ebp)
  800368:	ff 75 d8             	pushl  -0x28(%ebp)
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	e8 1a 0e 00 00       	call   801190 <__udivdi3>
  800376:	83 c4 18             	add    $0x18,%esp
  800379:	52                   	push   %edx
  80037a:	50                   	push   %eax
  80037b:	89 f2                	mov    %esi,%edx
  80037d:	89 f8                	mov    %edi,%eax
  80037f:	e8 15 fe ff ff       	call   800199 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 c4 18             	add    $0x18,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 dc             	pushl  -0x24(%ebp)
  80038e:	ff 75 d8             	pushl  -0x28(%ebp)
  800391:	ff 75 e4             	pushl  -0x1c(%ebp)
  800394:	ff 75 e0             	pushl  -0x20(%ebp)
  800397:	e8 24 0f 00 00       	call   8012c0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 95 14 80 00 	movsbl 0x801495(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
  8003a9:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 7d 08             	mov    0x8(%ebp),%edi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	eb 03                	jmp    80043c <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800439:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043c:	8b 45 10             	mov    0x10(%ebp),%eax
  80043f:	8d 70 01             	lea    0x1(%eax),%esi
  800442:	0f b6 00             	movzbl (%eax),%eax
  800445:	83 f8 25             	cmp    $0x25,%eax
  800448:	74 27                	je     800471 <vprintfmt+0x49>
			if (ch == '\0')
  80044a:	85 c0                	test   %eax,%eax
  80044c:	75 0d                	jne    80045b <vprintfmt+0x33>
  80044e:	e9 9d 04 00 00       	jmp    8008f0 <vprintfmt+0x4c8>
  800453:	85 c0                	test   %eax,%eax
  800455:	0f 84 95 04 00 00    	je     8008f0 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	53                   	push   %ebx
  80045f:	50                   	push   %eax
  800460:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800462:	83 c6 01             	add    $0x1,%esi
  800465:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	83 f8 25             	cmp    $0x25,%eax
  80046f:	75 e2                	jne    800453 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800471:	b9 00 00 00 00       	mov    $0x0,%ecx
  800476:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80047a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800481:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800488:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80048f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800496:	eb 08                	jmp    8004a0 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80049b:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8d 46 01             	lea    0x1(%esi),%eax
  8004a3:	89 45 10             	mov    %eax,0x10(%ebp)
  8004a6:	0f b6 06             	movzbl (%esi),%eax
  8004a9:	0f b6 d0             	movzbl %al,%edx
  8004ac:	83 e8 23             	sub    $0x23,%eax
  8004af:	3c 55                	cmp    $0x55,%al
  8004b1:	0f 87 fa 03 00 00    	ja     8008b1 <vprintfmt+0x489>
  8004b7:	0f b6 c0             	movzbl %al,%eax
  8004ba:	ff 24 85 e0 15 80 00 	jmp    *0x8015e0(,%eax,4)
  8004c1:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c4:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8004c8:	eb d6                	jmp    8004a0 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ca:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004d0:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004d4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d7:	83 fa 09             	cmp    $0x9,%edx
  8004da:	77 6b                	ja     800547 <vprintfmt+0x11f>
  8004dc:	8b 75 10             	mov    0x10(%ebp),%esi
  8004df:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004e2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004e5:	eb 09                	jmp    8004f0 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ea:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8004ee:	eb b0                	jmp    8004a0 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f0:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004f3:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004f6:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004fa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004fd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800500:	83 f9 09             	cmp    $0x9,%ecx
  800503:	76 eb                	jbe    8004f0 <vprintfmt+0xc8>
  800505:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800508:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80050b:	eb 3d                	jmp    80054a <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80051e:	eb 2a                	jmp    80054a <vprintfmt+0x122>
  800520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
  80052a:	0f 49 d0             	cmovns %eax,%edx
  80052d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 10             	mov    0x10(%ebp),%esi
  800533:	e9 68 ff ff ff       	jmp    8004a0 <vprintfmt+0x78>
  800538:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80053b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800542:	e9 59 ff ff ff       	jmp    8004a0 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80054a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054e:	0f 89 4c ff ff ff    	jns    8004a0 <vprintfmt+0x78>
				width = precision, precision = -1;
  800554:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800557:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800561:	e9 3a ff ff ff       	jmp    8004a0 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800566:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056d:	e9 2e ff ff ff       	jmp    8004a0 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	ff 30                	pushl  (%eax)
  800581:	ff d7                	call   *%edi
			break;
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	e9 b1 fe ff ff       	jmp    80043c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	99                   	cltd   
  800597:	31 d0                	xor    %edx,%eax
  800599:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059b:	83 f8 08             	cmp    $0x8,%eax
  80059e:	7f 0b                	jg     8005ab <vprintfmt+0x183>
  8005a0:	8b 14 85 40 17 80 00 	mov    0x801740(,%eax,4),%edx
  8005a7:	85 d2                	test   %edx,%edx
  8005a9:	75 15                	jne    8005c0 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8005ab:	50                   	push   %eax
  8005ac:	68 ad 14 80 00       	push   $0x8014ad
  8005b1:	53                   	push   %ebx
  8005b2:	57                   	push   %edi
  8005b3:	e8 53 fe ff ff       	call   80040b <printfmt>
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	e9 7c fe ff ff       	jmp    80043c <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005c0:	52                   	push   %edx
  8005c1:	68 b6 14 80 00       	push   $0x8014b6
  8005c6:	53                   	push   %ebx
  8005c7:	57                   	push   %edi
  8005c8:	e8 3e fe ff ff       	call   80040b <printfmt>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	e9 67 fe ff ff       	jmp    80043c <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	b9 a6 14 80 00       	mov    $0x8014a6,%ecx
  8005e7:	0f 45 c8             	cmovne %eax,%ecx
  8005ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f1:	7e 06                	jle    8005f9 <vprintfmt+0x1d1>
  8005f3:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005f7:	75 19                	jne    800612 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005fc:	8d 70 01             	lea    0x1(%eax),%esi
  8005ff:	0f b6 00             	movzbl (%eax),%eax
  800602:	0f be d0             	movsbl %al,%edx
  800605:	85 d2                	test   %edx,%edx
  800607:	0f 85 9f 00 00 00    	jne    8006ac <vprintfmt+0x284>
  80060d:	e9 8c 00 00 00       	jmp    80069e <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	ff 75 d0             	pushl  -0x30(%ebp)
  800618:	ff 75 cc             	pushl  -0x34(%ebp)
  80061b:	e8 62 03 00 00       	call   800982 <strnlen>
  800620:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800623:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	85 c9                	test   %ecx,%ecx
  80062b:	0f 8e a6 02 00 00    	jle    8008d7 <vprintfmt+0x4af>
					putch(padc, putdat);
  800631:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800635:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800638:	89 cb                	mov    %ecx,%ebx
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	ff 75 0c             	pushl  0xc(%ebp)
  800640:	56                   	push   %esi
  800641:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 c4 10             	add    $0x10,%esp
  800646:	83 eb 01             	sub    $0x1,%ebx
  800649:	75 ef                	jne    80063a <vprintfmt+0x212>
  80064b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80064e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800651:	e9 81 02 00 00       	jmp    8008d7 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800656:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80065a:	74 1b                	je     800677 <vprintfmt+0x24f>
  80065c:	0f be c0             	movsbl %al,%eax
  80065f:	83 e8 20             	sub    $0x20,%eax
  800662:	83 f8 5e             	cmp    $0x5e,%eax
  800665:	76 10                	jbe    800677 <vprintfmt+0x24f>
					putch('?', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	6a 3f                	push   $0x3f
  80066f:	ff 55 08             	call   *0x8(%ebp)
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	eb 0d                	jmp    800684 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	ff 75 0c             	pushl  0xc(%ebp)
  80067d:	52                   	push   %edx
  80067e:	ff 55 08             	call   *0x8(%ebp)
  800681:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800684:	83 ef 01             	sub    $0x1,%edi
  800687:	83 c6 01             	add    $0x1,%esi
  80068a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80068e:	0f be d0             	movsbl %al,%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	75 31                	jne    8006c6 <vprintfmt+0x29e>
  800695:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800698:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a5:	7f 33                	jg     8006da <vprintfmt+0x2b2>
  8006a7:	e9 90 fd ff ff       	jmp    80043c <vprintfmt+0x14>
  8006ac:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b8:	eb 0c                	jmp    8006c6 <vprintfmt+0x29e>
  8006ba:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c6:	85 db                	test   %ebx,%ebx
  8006c8:	78 8c                	js     800656 <vprintfmt+0x22e>
  8006ca:	83 eb 01             	sub    $0x1,%ebx
  8006cd:	79 87                	jns    800656 <vprintfmt+0x22e>
  8006cf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d8:	eb c4                	jmp    80069e <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 20                	push   $0x20
  8006e0:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	83 ee 01             	sub    $0x1,%esi
  8006e8:	75 f0                	jne    8006da <vprintfmt+0x2b2>
  8006ea:	e9 4d fd ff ff       	jmp    80043c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ef:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8006f3:	7e 16                	jle    80070b <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 50 08             	lea    0x8(%eax),%edx
  8006fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fe:	8b 50 04             	mov    0x4(%eax),%edx
  800701:	8b 00                	mov    (%eax),%eax
  800703:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800706:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800709:	eb 34                	jmp    80073f <vprintfmt+0x317>
	else if (lflag)
  80070b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80070f:	74 18                	je     800729 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8d 50 04             	lea    0x4(%eax),%edx
  800717:	89 55 14             	mov    %edx,0x14(%ebp)
  80071a:	8b 30                	mov    (%eax),%esi
  80071c:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80071f:	89 f0                	mov    %esi,%eax
  800721:	c1 f8 1f             	sar    $0x1f,%eax
  800724:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800727:	eb 16                	jmp    80073f <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8d 50 04             	lea    0x4(%eax),%edx
  80072f:	89 55 14             	mov    %edx,0x14(%ebp)
  800732:	8b 30                	mov    (%eax),%esi
  800734:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800737:	89 f0                	mov    %esi,%eax
  800739:	c1 f8 1f             	sar    $0x1f,%eax
  80073c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800742:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800745:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800748:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80074b:	85 d2                	test   %edx,%edx
  80074d:	79 28                	jns    800777 <vprintfmt+0x34f>
				putch('-', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 2d                	push   $0x2d
  800755:	ff d7                	call   *%edi
				num = -(long long) num;
  800757:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80075a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80075d:	f7 d8                	neg    %eax
  80075f:	83 d2 00             	adc    $0x0,%edx
  800762:	f7 da                	neg    %edx
  800764:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800767:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076a:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  80076d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800772:	e9 b2 00 00 00       	jmp    800829 <vprintfmt+0x401>
  800777:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  80077c:	85 c9                	test   %ecx,%ecx
  80077e:	0f 84 a5 00 00 00    	je     800829 <vprintfmt+0x401>
				putch('+', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 2b                	push   $0x2b
  80078a:	ff d7                	call   *%edi
  80078c:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  80078f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800794:	e9 90 00 00 00       	jmp    800829 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800799:	85 c9                	test   %ecx,%ecx
  80079b:	74 0b                	je     8007a8 <vprintfmt+0x380>
				putch('+', putdat);
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	53                   	push   %ebx
  8007a1:	6a 2b                	push   $0x2b
  8007a3:	ff d7                	call   *%edi
  8007a5:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8007a8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ae:	e8 01 fc ff ff       	call   8003b4 <getuint>
  8007b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007b9:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007be:	eb 69                	jmp    800829 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	53                   	push   %ebx
  8007c4:	6a 30                	push   $0x30
  8007c6:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007c8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	e8 e1 fb ff ff       	call   8003b4 <getuint>
  8007d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8007d9:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007dc:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007e1:	eb 46                	jmp    800829 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	6a 30                	push   $0x30
  8007e9:	ff d7                	call   *%edi
			putch('x', putdat);
  8007eb:	83 c4 08             	add    $0x8,%esp
  8007ee:	53                   	push   %ebx
  8007ef:	6a 78                	push   $0x78
  8007f1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 50 04             	lea    0x4(%eax),%edx
  8007f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007fc:	8b 00                	mov    (%eax),%eax
  8007fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800803:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800806:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800809:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800811:	eb 16                	jmp    800829 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800813:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
  800819:	e8 96 fb ff ff       	call   8003b4 <getuint>
  80081e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800821:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800824:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800829:	83 ec 0c             	sub    $0xc,%esp
  80082c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800830:	56                   	push   %esi
  800831:	ff 75 e4             	pushl  -0x1c(%ebp)
  800834:	50                   	push   %eax
  800835:	ff 75 dc             	pushl  -0x24(%ebp)
  800838:	ff 75 d8             	pushl  -0x28(%ebp)
  80083b:	89 da                	mov    %ebx,%edx
  80083d:	89 f8                	mov    %edi,%eax
  80083f:	e8 55 f9 ff ff       	call   800199 <printnum>
			break;
  800844:	83 c4 20             	add    $0x20,%esp
  800847:	e9 f0 fb ff ff       	jmp    80043c <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 04             	lea    0x4(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800857:	85 f6                	test   %esi,%esi
  800859:	75 1a                	jne    800875 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	68 4c 15 80 00       	push   $0x80154c
  800863:	68 b6 14 80 00       	push   $0x8014b6
  800868:	e8 18 f9 ff ff       	call   800185 <cprintf>
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	e9 c7 fb ff ff       	jmp    80043c <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800875:	0f b6 03             	movzbl (%ebx),%eax
  800878:	84 c0                	test   %al,%al
  80087a:	79 1f                	jns    80089b <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	68 84 15 80 00       	push   $0x801584
  800884:	68 b6 14 80 00       	push   $0x8014b6
  800889:	e8 f7 f8 ff ff       	call   800185 <cprintf>
						*tmp = *(char *)putdat;
  80088e:	0f b6 03             	movzbl (%ebx),%eax
  800891:	88 06                	mov    %al,(%esi)
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	e9 a1 fb ff ff       	jmp    80043c <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  80089b:	88 06                	mov    %al,(%esi)
  80089d:	e9 9a fb ff ff       	jmp    80043c <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a2:	83 ec 08             	sub    $0x8,%esp
  8008a5:	53                   	push   %ebx
  8008a6:	52                   	push   %edx
  8008a7:	ff d7                	call   *%edi
			break;
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	e9 8b fb ff ff       	jmp    80043c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	53                   	push   %ebx
  8008b5:	6a 25                	push   $0x25
  8008b7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008c0:	0f 84 73 fb ff ff    	je     800439 <vprintfmt+0x11>
  8008c6:	83 ee 01             	sub    $0x1,%esi
  8008c9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008cd:	75 f7                	jne    8008c6 <vprintfmt+0x49e>
  8008cf:	89 75 10             	mov    %esi,0x10(%ebp)
  8008d2:	e9 65 fb ff ff       	jmp    80043c <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008da:	8d 70 01             	lea    0x1(%eax),%esi
  8008dd:	0f b6 00             	movzbl (%eax),%eax
  8008e0:	0f be d0             	movsbl %al,%edx
  8008e3:	85 d2                	test   %edx,%edx
  8008e5:	0f 85 cf fd ff ff    	jne    8006ba <vprintfmt+0x292>
  8008eb:	e9 4c fb ff ff       	jmp    80043c <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5f                   	pop    %edi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	83 ec 18             	sub    $0x18,%esp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800904:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800907:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80090b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80090e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800915:	85 c0                	test   %eax,%eax
  800917:	74 26                	je     80093f <vsnprintf+0x47>
  800919:	85 d2                	test   %edx,%edx
  80091b:	7e 22                	jle    80093f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80091d:	ff 75 14             	pushl  0x14(%ebp)
  800920:	ff 75 10             	pushl  0x10(%ebp)
  800923:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800926:	50                   	push   %eax
  800927:	68 ee 03 80 00       	push   $0x8003ee
  80092c:	e8 f7 fa ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800931:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800934:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800937:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	eb 05                	jmp    800944 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80093f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80094c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80094f:	50                   	push   %eax
  800950:	ff 75 10             	pushl  0x10(%ebp)
  800953:	ff 75 0c             	pushl  0xc(%ebp)
  800956:	ff 75 08             	pushl  0x8(%ebp)
  800959:	e8 9a ff ff ff       	call   8008f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800966:	80 3a 00             	cmpb   $0x0,(%edx)
  800969:	74 10                	je     80097b <strlen+0x1b>
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800970:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800973:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800977:	75 f7                	jne    800970 <strlen+0x10>
  800979:	eb 05                	jmp    800980 <strlen+0x20>
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098c:	85 c9                	test   %ecx,%ecx
  80098e:	74 1c                	je     8009ac <strnlen+0x2a>
  800990:	80 3b 00             	cmpb   $0x0,(%ebx)
  800993:	74 1e                	je     8009b3 <strnlen+0x31>
  800995:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80099a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099c:	39 ca                	cmp    %ecx,%edx
  80099e:	74 18                	je     8009b8 <strnlen+0x36>
  8009a0:	83 c2 01             	add    $0x1,%edx
  8009a3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009a8:	75 f0                	jne    80099a <strnlen+0x18>
  8009aa:	eb 0c                	jmp    8009b8 <strnlen+0x36>
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb 05                	jmp    8009b8 <strnlen+0x36>
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c5:	89 c2                	mov    %eax,%edx
  8009c7:	83 c2 01             	add    $0x1,%edx
  8009ca:	83 c1 01             	add    $0x1,%ecx
  8009cd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009d1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d4:	84 db                	test   %bl,%bl
  8009d6:	75 ef                	jne    8009c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e2:	53                   	push   %ebx
  8009e3:	e8 78 ff ff ff       	call   800960 <strlen>
  8009e8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	01 d8                	add    %ebx,%eax
  8009f0:	50                   	push   %eax
  8009f1:	e8 c5 ff ff ff       	call   8009bb <strcpy>
	return dst;
}
  8009f6:	89 d8                	mov    %ebx,%eax
  8009f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 75 08             	mov    0x8(%ebp),%esi
  800a05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0b:	85 db                	test   %ebx,%ebx
  800a0d:	74 17                	je     800a26 <strncpy+0x29>
  800a0f:	01 f3                	add    %esi,%ebx
  800a11:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	0f b6 02             	movzbl (%edx),%eax
  800a19:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a1c:	80 3a 01             	cmpb   $0x1,(%edx)
  800a1f:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a22:	39 cb                	cmp    %ecx,%ebx
  800a24:	75 ed                	jne    800a13 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a26:	89 f0                	mov    %esi,%eax
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 75 08             	mov    0x8(%ebp),%esi
  800a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a37:	8b 55 10             	mov    0x10(%ebp),%edx
  800a3a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3c:	85 d2                	test   %edx,%edx
  800a3e:	74 35                	je     800a75 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a40:	89 d0                	mov    %edx,%eax
  800a42:	83 e8 01             	sub    $0x1,%eax
  800a45:	74 25                	je     800a6c <strlcpy+0x40>
  800a47:	0f b6 0b             	movzbl (%ebx),%ecx
  800a4a:	84 c9                	test   %cl,%cl
  800a4c:	74 22                	je     800a70 <strlcpy+0x44>
  800a4e:	8d 53 01             	lea    0x1(%ebx),%edx
  800a51:	01 c3                	add    %eax,%ebx
  800a53:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a5b:	39 da                	cmp    %ebx,%edx
  800a5d:	74 13                	je     800a72 <strlcpy+0x46>
  800a5f:	83 c2 01             	add    $0x1,%edx
  800a62:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a66:	84 c9                	test   %cl,%cl
  800a68:	75 eb                	jne    800a55 <strlcpy+0x29>
  800a6a:	eb 06                	jmp    800a72 <strlcpy+0x46>
  800a6c:	89 f0                	mov    %esi,%eax
  800a6e:	eb 02                	jmp    800a72 <strlcpy+0x46>
  800a70:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a72:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a75:	29 f0                	sub    %esi,%eax
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a84:	0f b6 01             	movzbl (%ecx),%eax
  800a87:	84 c0                	test   %al,%al
  800a89:	74 15                	je     800aa0 <strcmp+0x25>
  800a8b:	3a 02                	cmp    (%edx),%al
  800a8d:	75 11                	jne    800aa0 <strcmp+0x25>
		p++, q++;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a95:	0f b6 01             	movzbl (%ecx),%eax
  800a98:	84 c0                	test   %al,%al
  800a9a:	74 04                	je     800aa0 <strcmp+0x25>
  800a9c:	3a 02                	cmp    (%edx),%al
  800a9e:	74 ef                	je     800a8f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa0:	0f b6 c0             	movzbl %al,%eax
  800aa3:	0f b6 12             	movzbl (%edx),%edx
  800aa6:	29 d0                	sub    %edx,%eax
}
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab5:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800ab8:	85 f6                	test   %esi,%esi
  800aba:	74 29                	je     800ae5 <strncmp+0x3b>
  800abc:	0f b6 03             	movzbl (%ebx),%eax
  800abf:	84 c0                	test   %al,%al
  800ac1:	74 30                	je     800af3 <strncmp+0x49>
  800ac3:	3a 02                	cmp    (%edx),%al
  800ac5:	75 2c                	jne    800af3 <strncmp+0x49>
  800ac7:	8d 43 01             	lea    0x1(%ebx),%eax
  800aca:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800acc:	89 c3                	mov    %eax,%ebx
  800ace:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad1:	39 c6                	cmp    %eax,%esi
  800ad3:	74 17                	je     800aec <strncmp+0x42>
  800ad5:	0f b6 08             	movzbl (%eax),%ecx
  800ad8:	84 c9                	test   %cl,%cl
  800ada:	74 17                	je     800af3 <strncmp+0x49>
  800adc:	83 c0 01             	add    $0x1,%eax
  800adf:	3a 0a                	cmp    (%edx),%cl
  800ae1:	74 e9                	je     800acc <strncmp+0x22>
  800ae3:	eb 0e                	jmp    800af3 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	eb 0f                	jmp    800afb <strncmp+0x51>
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	eb 08                	jmp    800afb <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af3:	0f b6 03             	movzbl (%ebx),%eax
  800af6:	0f b6 12             	movzbl (%edx),%edx
  800af9:	29 d0                	sub    %edx,%eax
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	53                   	push   %ebx
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b09:	0f b6 10             	movzbl (%eax),%edx
  800b0c:	84 d2                	test   %dl,%dl
  800b0e:	74 1d                	je     800b2d <strchr+0x2e>
  800b10:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b12:	38 d3                	cmp    %dl,%bl
  800b14:	75 06                	jne    800b1c <strchr+0x1d>
  800b16:	eb 1a                	jmp    800b32 <strchr+0x33>
  800b18:	38 ca                	cmp    %cl,%dl
  800b1a:	74 16                	je     800b32 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b1c:	83 c0 01             	add    $0x1,%eax
  800b1f:	0f b6 10             	movzbl (%eax),%edx
  800b22:	84 d2                	test   %dl,%dl
  800b24:	75 f2                	jne    800b18 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	eb 05                	jmp    800b32 <strchr+0x33>
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	53                   	push   %ebx
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b3f:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b42:	38 d3                	cmp    %dl,%bl
  800b44:	74 14                	je     800b5a <strfind+0x25>
  800b46:	89 d1                	mov    %edx,%ecx
  800b48:	84 db                	test   %bl,%bl
  800b4a:	74 0e                	je     800b5a <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b4c:	83 c0 01             	add    $0x1,%eax
  800b4f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b52:	38 ca                	cmp    %cl,%dl
  800b54:	74 04                	je     800b5a <strfind+0x25>
  800b56:	84 d2                	test   %dl,%dl
  800b58:	75 f2                	jne    800b4c <strfind+0x17>
			break;
	return (char *) s;
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b69:	85 c9                	test   %ecx,%ecx
  800b6b:	74 36                	je     800ba3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b73:	75 28                	jne    800b9d <memset+0x40>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	75 23                	jne    800b9d <memset+0x40>
		c &= 0xFF;
  800b7a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	c1 e3 08             	shl    $0x8,%ebx
  800b83:	89 d6                	mov    %edx,%esi
  800b85:	c1 e6 18             	shl    $0x18,%esi
  800b88:	89 d0                	mov    %edx,%eax
  800b8a:	c1 e0 10             	shl    $0x10,%eax
  800b8d:	09 f0                	or     %esi,%eax
  800b8f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b91:	89 d8                	mov    %ebx,%eax
  800b93:	09 d0                	or     %edx,%eax
  800b95:	c1 e9 02             	shr    $0x2,%ecx
  800b98:	fc                   	cld    
  800b99:	f3 ab                	rep stos %eax,%es:(%edi)
  800b9b:	eb 06                	jmp    800ba3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba0:	fc                   	cld    
  800ba1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba3:	89 f8                	mov    %edi,%eax
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb8:	39 c6                	cmp    %eax,%esi
  800bba:	73 35                	jae    800bf1 <memmove+0x47>
  800bbc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bbf:	39 d0                	cmp    %edx,%eax
  800bc1:	73 2e                	jae    800bf1 <memmove+0x47>
		s += n;
		d += n;
  800bc3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc6:	89 d6                	mov    %edx,%esi
  800bc8:	09 fe                	or     %edi,%esi
  800bca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd0:	75 13                	jne    800be5 <memmove+0x3b>
  800bd2:	f6 c1 03             	test   $0x3,%cl
  800bd5:	75 0e                	jne    800be5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bd7:	83 ef 04             	sub    $0x4,%edi
  800bda:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bdd:	c1 e9 02             	shr    $0x2,%ecx
  800be0:	fd                   	std    
  800be1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be3:	eb 09                	jmp    800bee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be5:	83 ef 01             	sub    $0x1,%edi
  800be8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800beb:	fd                   	std    
  800bec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bee:	fc                   	cld    
  800bef:	eb 1d                	jmp    800c0e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf1:	89 f2                	mov    %esi,%edx
  800bf3:	09 c2                	or     %eax,%edx
  800bf5:	f6 c2 03             	test   $0x3,%dl
  800bf8:	75 0f                	jne    800c09 <memmove+0x5f>
  800bfa:	f6 c1 03             	test   $0x3,%cl
  800bfd:	75 0a                	jne    800c09 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bff:	c1 e9 02             	shr    $0x2,%ecx
  800c02:	89 c7                	mov    %eax,%edi
  800c04:	fc                   	cld    
  800c05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c07:	eb 05                	jmp    800c0e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	fc                   	cld    
  800c0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c15:	ff 75 10             	pushl  0x10(%ebp)
  800c18:	ff 75 0c             	pushl  0xc(%ebp)
  800c1b:	ff 75 08             	pushl  0x8(%ebp)
  800c1e:	e8 87 ff ff ff       	call   800baa <memmove>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c31:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c34:	85 c0                	test   %eax,%eax
  800c36:	74 39                	je     800c71 <memcmp+0x4c>
  800c38:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c3b:	0f b6 13             	movzbl (%ebx),%edx
  800c3e:	0f b6 0e             	movzbl (%esi),%ecx
  800c41:	38 ca                	cmp    %cl,%dl
  800c43:	75 17                	jne    800c5c <memcmp+0x37>
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4a:	eb 1a                	jmp    800c66 <memcmp+0x41>
  800c4c:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c51:	83 c0 01             	add    $0x1,%eax
  800c54:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c58:	38 ca                	cmp    %cl,%dl
  800c5a:	74 0a                	je     800c66 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c5c:	0f b6 c2             	movzbl %dl,%eax
  800c5f:	0f b6 c9             	movzbl %cl,%ecx
  800c62:	29 c8                	sub    %ecx,%eax
  800c64:	eb 10                	jmp    800c76 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c66:	39 f8                	cmp    %edi,%eax
  800c68:	75 e2                	jne    800c4c <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6f:	eb 05                	jmp    800c76 <memcmp+0x51>
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c82:	89 d0                	mov    %edx,%eax
  800c84:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c87:	39 c2                	cmp    %eax,%edx
  800c89:	73 1d                	jae    800ca8 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c8f:	0f b6 0a             	movzbl (%edx),%ecx
  800c92:	39 d9                	cmp    %ebx,%ecx
  800c94:	75 09                	jne    800c9f <memfind+0x24>
  800c96:	eb 14                	jmp    800cac <memfind+0x31>
  800c98:	0f b6 0a             	movzbl (%edx),%ecx
  800c9b:	39 d9                	cmp    %ebx,%ecx
  800c9d:	74 11                	je     800cb0 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c9f:	83 c2 01             	add    $0x1,%edx
  800ca2:	39 d0                	cmp    %edx,%eax
  800ca4:	75 f2                	jne    800c98 <memfind+0x1d>
  800ca6:	eb 0a                	jmp    800cb2 <memfind+0x37>
  800ca8:	89 d0                	mov    %edx,%eax
  800caa:	eb 06                	jmp    800cb2 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cac:	89 d0                	mov    %edx,%eax
  800cae:	eb 02                	jmp    800cb2 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb0:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc1:	0f b6 01             	movzbl (%ecx),%eax
  800cc4:	3c 20                	cmp    $0x20,%al
  800cc6:	74 04                	je     800ccc <strtol+0x17>
  800cc8:	3c 09                	cmp    $0x9,%al
  800cca:	75 0e                	jne    800cda <strtol+0x25>
		s++;
  800ccc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccf:	0f b6 01             	movzbl (%ecx),%eax
  800cd2:	3c 20                	cmp    $0x20,%al
  800cd4:	74 f6                	je     800ccc <strtol+0x17>
  800cd6:	3c 09                	cmp    $0x9,%al
  800cd8:	74 f2                	je     800ccc <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cda:	3c 2b                	cmp    $0x2b,%al
  800cdc:	75 0a                	jne    800ce8 <strtol+0x33>
		s++;
  800cde:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce6:	eb 11                	jmp    800cf9 <strtol+0x44>
  800ce8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ced:	3c 2d                	cmp    $0x2d,%al
  800cef:	75 08                	jne    800cf9 <strtol+0x44>
		s++, neg = 1;
  800cf1:	83 c1 01             	add    $0x1,%ecx
  800cf4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cff:	75 15                	jne    800d16 <strtol+0x61>
  800d01:	80 39 30             	cmpb   $0x30,(%ecx)
  800d04:	75 10                	jne    800d16 <strtol+0x61>
  800d06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d0a:	75 7c                	jne    800d88 <strtol+0xd3>
		s += 2, base = 16;
  800d0c:	83 c1 02             	add    $0x2,%ecx
  800d0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d14:	eb 16                	jmp    800d2c <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d16:	85 db                	test   %ebx,%ebx
  800d18:	75 12                	jne    800d2c <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800d22:	75 08                	jne    800d2c <strtol+0x77>
		s++, base = 8;
  800d24:	83 c1 01             	add    $0x1,%ecx
  800d27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d34:	0f b6 11             	movzbl (%ecx),%edx
  800d37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d3a:	89 f3                	mov    %esi,%ebx
  800d3c:	80 fb 09             	cmp    $0x9,%bl
  800d3f:	77 08                	ja     800d49 <strtol+0x94>
			dig = *s - '0';
  800d41:	0f be d2             	movsbl %dl,%edx
  800d44:	83 ea 30             	sub    $0x30,%edx
  800d47:	eb 22                	jmp    800d6b <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d49:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d4c:	89 f3                	mov    %esi,%ebx
  800d4e:	80 fb 19             	cmp    $0x19,%bl
  800d51:	77 08                	ja     800d5b <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d53:	0f be d2             	movsbl %dl,%edx
  800d56:	83 ea 57             	sub    $0x57,%edx
  800d59:	eb 10                	jmp    800d6b <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d5e:	89 f3                	mov    %esi,%ebx
  800d60:	80 fb 19             	cmp    $0x19,%bl
  800d63:	77 16                	ja     800d7b <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d65:	0f be d2             	movsbl %dl,%edx
  800d68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d6e:	7d 0b                	jge    800d7b <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d70:	83 c1 01             	add    $0x1,%ecx
  800d73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d79:	eb b9                	jmp    800d34 <strtol+0x7f>

	if (endptr)
  800d7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d7f:	74 0d                	je     800d8e <strtol+0xd9>
		*endptr = (char *) s;
  800d81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d84:	89 0e                	mov    %ecx,(%esi)
  800d86:	eb 06                	jmp    800d8e <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d88:	85 db                	test   %ebx,%ebx
  800d8a:	74 98                	je     800d24 <strtol+0x6f>
  800d8c:	eb 9e                	jmp    800d2c <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	f7 da                	neg    %edx
  800d92:	85 ff                	test   %edi,%edi
  800d94:	0f 45 c2             	cmovne %edx,%eax
}
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	89 c3                	mov    %eax,%ebx
  800dae:	89 c7                	mov    %eax,%edi
  800db0:	51                   	push   %ecx
  800db1:	52                   	push   %edx
  800db2:	53                   	push   %ebx
  800db3:	54                   	push   %esp
  800db4:	55                   	push   %ebp
  800db5:	56                   	push   %esi
  800db6:	57                   	push   %edi
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	8d 35 c1 0d 80 00    	lea    0x800dc1,%esi
  800dbf:	0f 34                	sysenter 

00800dc1 <label_21>:
  800dc1:	5f                   	pop    %edi
  800dc2:	5e                   	pop    %esi
  800dc3:	5d                   	pop    %ebp
  800dc4:	5c                   	pop    %esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5a                   	pop    %edx
  800dc7:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_cgetc>:

int
sys_cgetc(void)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddb:	89 ca                	mov    %ecx,%edx
  800ddd:	89 cb                	mov    %ecx,%ebx
  800ddf:	89 cf                	mov    %ecx,%edi
  800de1:	51                   	push   %ecx
  800de2:	52                   	push   %edx
  800de3:	53                   	push   %ebx
  800de4:	54                   	push   %esp
  800de5:	55                   	push   %ebp
  800de6:	56                   	push   %esi
  800de7:	57                   	push   %edi
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	8d 35 f2 0d 80 00    	lea    0x800df2,%esi
  800df0:	0f 34                	sysenter 

00800df2 <label_55>:
  800df2:	5f                   	pop    %edi
  800df3:	5e                   	pop    %esi
  800df4:	5d                   	pop    %ebp
  800df5:	5c                   	pop    %esp
  800df6:	5b                   	pop    %ebx
  800df7:	5a                   	pop    %edx
  800df8:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800df9:	5b                   	pop    %ebx
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e07:	b8 03 00 00 00       	mov    $0x3,%eax
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 d9                	mov    %ebx,%ecx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	51                   	push   %ecx
  800e14:	52                   	push   %edx
  800e15:	53                   	push   %ebx
  800e16:	54                   	push   %esp
  800e17:	55                   	push   %ebp
  800e18:	56                   	push   %esi
  800e19:	57                   	push   %edi
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	8d 35 24 0e 80 00    	lea    0x800e24,%esi
  800e22:	0f 34                	sysenter 

00800e24 <label_90>:
  800e24:	5f                   	pop    %edi
  800e25:	5e                   	pop    %esi
  800e26:	5d                   	pop    %ebp
  800e27:	5c                   	pop    %esp
  800e28:	5b                   	pop    %ebx
  800e29:	5a                   	pop    %edx
  800e2a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 17                	jle    800e46 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	50                   	push   %eax
  800e33:	6a 03                	push   $0x3
  800e35:	68 64 17 80 00       	push   $0x801764
  800e3a:	6a 2a                	push   $0x2a
  800e3c:	68 81 17 80 00       	push   $0x801781
  800e41:	e8 e5 02 00 00       	call   80112b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e57:	b8 02 00 00 00       	mov    $0x2,%eax
  800e5c:	89 ca                	mov    %ecx,%edx
  800e5e:	89 cb                	mov    %ecx,%ebx
  800e60:	89 cf                	mov    %ecx,%edi
  800e62:	51                   	push   %ecx
  800e63:	52                   	push   %edx
  800e64:	53                   	push   %ebx
  800e65:	54                   	push   %esp
  800e66:	55                   	push   %ebp
  800e67:	56                   	push   %esi
  800e68:	57                   	push   %edi
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	8d 35 73 0e 80 00    	lea    0x800e73,%esi
  800e71:	0f 34                	sysenter 

00800e73 <label_139>:
  800e73:	5f                   	pop    %edi
  800e74:	5e                   	pop    %esi
  800e75:	5d                   	pop    %ebp
  800e76:	5c                   	pop    %esp
  800e77:	5b                   	pop    %ebx
  800e78:	5a                   	pop    %edx
  800e79:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e7a:	5b                   	pop    %ebx
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e83:	bf 00 00 00 00       	mov    $0x0,%edi
  800e88:	b8 04 00 00 00       	mov    $0x4,%eax
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	8b 55 08             	mov    0x8(%ebp),%edx
  800e93:	89 fb                	mov    %edi,%ebx
  800e95:	51                   	push   %ecx
  800e96:	52                   	push   %edx
  800e97:	53                   	push   %ebx
  800e98:	54                   	push   %esp
  800e99:	55                   	push   %ebp
  800e9a:	56                   	push   %esi
  800e9b:	57                   	push   %edi
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	8d 35 a6 0e 80 00    	lea    0x800ea6,%esi
  800ea4:	0f 34                	sysenter 

00800ea6 <label_174>:
  800ea6:	5f                   	pop    %edi
  800ea7:	5e                   	pop    %esi
  800ea8:	5d                   	pop    %ebp
  800ea9:	5c                   	pop    %esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5a                   	pop    %edx
  800eac:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ead:	5b                   	pop    %ebx
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_yield>:

void
sys_yield(void)
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
  800eb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec0:	89 d1                	mov    %edx,%ecx
  800ec2:	89 d3                	mov    %edx,%ebx
  800ec4:	89 d7                	mov    %edx,%edi
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

00800ed7 <label_209>:
  800ed7:	5f                   	pop    %edi
  800ed8:	5e                   	pop    %esi
  800ed9:	5d                   	pop    %ebp
  800eda:	5c                   	pop    %esp
  800edb:	5b                   	pop    %ebx
  800edc:	5a                   	pop    %edx
  800edd:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ede:	5b                   	pop    %ebx
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800eec:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efa:	51                   	push   %ecx
  800efb:	52                   	push   %edx
  800efc:	53                   	push   %ebx
  800efd:	54                   	push   %esp
  800efe:	55                   	push   %ebp
  800eff:	56                   	push   %esi
  800f00:	57                   	push   %edi
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	8d 35 0b 0f 80 00    	lea    0x800f0b,%esi
  800f09:	0f 34                	sysenter 

00800f0b <label_244>:
  800f0b:	5f                   	pop    %edi
  800f0c:	5e                   	pop    %esi
  800f0d:	5d                   	pop    %ebp
  800f0e:	5c                   	pop    %esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5a                   	pop    %edx
  800f11:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f12:	85 c0                	test   %eax,%eax
  800f14:	7e 17                	jle    800f2d <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	50                   	push   %eax
  800f1a:	6a 05                	push   $0x5
  800f1c:	68 64 17 80 00       	push   $0x801764
  800f21:	6a 2a                	push   $0x2a
  800f23:	68 81 17 80 00       	push   $0x801781
  800f28:	e8 fe 01 00 00       	call   80112b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f39:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f41:	8b 55 08             	mov    0x8(%ebp),%edx
  800f44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f4a:	51                   	push   %ecx
  800f4b:	52                   	push   %edx
  800f4c:	53                   	push   %ebx
  800f4d:	54                   	push   %esp
  800f4e:	55                   	push   %ebp
  800f4f:	56                   	push   %esi
  800f50:	57                   	push   %edi
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	8d 35 5b 0f 80 00    	lea    0x800f5b,%esi
  800f59:	0f 34                	sysenter 

00800f5b <label_295>:
  800f5b:	5f                   	pop    %edi
  800f5c:	5e                   	pop    %esi
  800f5d:	5d                   	pop    %ebp
  800f5e:	5c                   	pop    %esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5a                   	pop    %edx
  800f61:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f62:	85 c0                	test   %eax,%eax
  800f64:	7e 17                	jle    800f7d <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	50                   	push   %eax
  800f6a:	6a 06                	push   $0x6
  800f6c:	68 64 17 80 00       	push   $0x801764
  800f71:	6a 2a                	push   $0x2a
  800f73:	68 81 17 80 00       	push   $0x801781
  800f78:	e8 ae 01 00 00       	call   80112b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f89:	bf 00 00 00 00       	mov    $0x0,%edi
  800f8e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f96:	8b 55 08             	mov    0x8(%ebp),%edx
  800f99:	89 fb                	mov    %edi,%ebx
  800f9b:	51                   	push   %ecx
  800f9c:	52                   	push   %edx
  800f9d:	53                   	push   %ebx
  800f9e:	54                   	push   %esp
  800f9f:	55                   	push   %ebp
  800fa0:	56                   	push   %esi
  800fa1:	57                   	push   %edi
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	8d 35 ac 0f 80 00    	lea    0x800fac,%esi
  800faa:	0f 34                	sysenter 

00800fac <label_344>:
  800fac:	5f                   	pop    %edi
  800fad:	5e                   	pop    %esi
  800fae:	5d                   	pop    %ebp
  800faf:	5c                   	pop    %esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5a                   	pop    %edx
  800fb2:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	7e 17                	jle    800fce <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	50                   	push   %eax
  800fbb:	6a 07                	push   $0x7
  800fbd:	68 64 17 80 00       	push   $0x801764
  800fc2:	6a 2a                	push   $0x2a
  800fc4:	68 81 17 80 00       	push   $0x801781
  800fc9:	e8 5d 01 00 00       	call   80112b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd1:	5b                   	pop    %ebx
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	57                   	push   %edi
  800fd9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fda:	bf 00 00 00 00       	mov    $0x0,%edi
  800fdf:	b8 09 00 00 00       	mov    $0x9,%eax
  800fe4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fea:	89 fb                	mov    %edi,%ebx
  800fec:	51                   	push   %ecx
  800fed:	52                   	push   %edx
  800fee:	53                   	push   %ebx
  800fef:	54                   	push   %esp
  800ff0:	55                   	push   %ebp
  800ff1:	56                   	push   %esi
  800ff2:	57                   	push   %edi
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	8d 35 fd 0f 80 00    	lea    0x800ffd,%esi
  800ffb:	0f 34                	sysenter 

00800ffd <label_393>:
  800ffd:	5f                   	pop    %edi
  800ffe:	5e                   	pop    %esi
  800fff:	5d                   	pop    %ebp
  801000:	5c                   	pop    %esp
  801001:	5b                   	pop    %ebx
  801002:	5a                   	pop    %edx
  801003:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801004:	85 c0                	test   %eax,%eax
  801006:	7e 17                	jle    80101f <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	50                   	push   %eax
  80100c:	6a 09                	push   $0x9
  80100e:	68 64 17 80 00       	push   $0x801764
  801013:	6a 2a                	push   $0x2a
  801015:	68 81 17 80 00       	push   $0x801781
  80101a:	e8 0c 01 00 00       	call   80112b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80101f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801022:	5b                   	pop    %ebx
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	57                   	push   %edi
  80102a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80102b:	bf 00 00 00 00       	mov    $0x0,%edi
  801030:	b8 0a 00 00 00       	mov    $0xa,%eax
  801035:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801038:	8b 55 08             	mov    0x8(%ebp),%edx
  80103b:	89 fb                	mov    %edi,%ebx
  80103d:	51                   	push   %ecx
  80103e:	52                   	push   %edx
  80103f:	53                   	push   %ebx
  801040:	54                   	push   %esp
  801041:	55                   	push   %ebp
  801042:	56                   	push   %esi
  801043:	57                   	push   %edi
  801044:	89 e5                	mov    %esp,%ebp
  801046:	8d 35 4e 10 80 00    	lea    0x80104e,%esi
  80104c:	0f 34                	sysenter 

0080104e <label_442>:
  80104e:	5f                   	pop    %edi
  80104f:	5e                   	pop    %esi
  801050:	5d                   	pop    %ebp
  801051:	5c                   	pop    %esp
  801052:	5b                   	pop    %ebx
  801053:	5a                   	pop    %edx
  801054:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801055:	85 c0                	test   %eax,%eax
  801057:	7e 17                	jle    801070 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	50                   	push   %eax
  80105d:	6a 0a                	push   $0xa
  80105f:	68 64 17 80 00       	push   $0x801764
  801064:	6a 2a                	push   $0x2a
  801066:	68 81 17 80 00       	push   $0x801781
  80106b:	e8 bb 00 00 00       	call   80112b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801070:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	57                   	push   %edi
  80107b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80107c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801084:	8b 55 08             	mov    0x8(%ebp),%edx
  801087:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80108a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80108d:	51                   	push   %ecx
  80108e:	52                   	push   %edx
  80108f:	53                   	push   %ebx
  801090:	54                   	push   %esp
  801091:	55                   	push   %ebp
  801092:	56                   	push   %esi
  801093:	57                   	push   %edi
  801094:	89 e5                	mov    %esp,%ebp
  801096:	8d 35 9e 10 80 00    	lea    0x80109e,%esi
  80109c:	0f 34                	sysenter 

0080109e <label_493>:
  80109e:	5f                   	pop    %edi
  80109f:	5e                   	pop    %esi
  8010a0:	5d                   	pop    %ebp
  8010a1:	5c                   	pop    %esp
  8010a2:	5b                   	pop    %ebx
  8010a3:	5a                   	pop    %edx
  8010a4:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010a5:	5b                   	pop    %ebx
  8010a6:	5f                   	pop    %edi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	57                   	push   %edi
  8010ad:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bb:	89 d9                	mov    %ebx,%ecx
  8010bd:	89 df                	mov    %ebx,%edi
  8010bf:	51                   	push   %ecx
  8010c0:	52                   	push   %edx
  8010c1:	53                   	push   %ebx
  8010c2:	54                   	push   %esp
  8010c3:	55                   	push   %ebp
  8010c4:	56                   	push   %esi
  8010c5:	57                   	push   %edi
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	8d 35 d0 10 80 00    	lea    0x8010d0,%esi
  8010ce:	0f 34                	sysenter 

008010d0 <label_528>:
  8010d0:	5f                   	pop    %edi
  8010d1:	5e                   	pop    %esi
  8010d2:	5d                   	pop    %ebp
  8010d3:	5c                   	pop    %esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5a                   	pop    %edx
  8010d6:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	7e 17                	jle    8010f2 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	50                   	push   %eax
  8010df:	6a 0d                	push   $0xd
  8010e1:	68 64 17 80 00       	push   $0x801764
  8010e6:	6a 2a                	push   $0x2a
  8010e8:	68 81 17 80 00       	push   $0x801781
  8010ed:	e8 39 00 00 00       	call   80112b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f5:	5b                   	pop    %ebx
  8010f6:	5f                   	pop    %edi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0e 00 00 00       	mov    $0xe,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	51                   	push   %ecx
  801110:	52                   	push   %edx
  801111:	53                   	push   %ebx
  801112:	54                   	push   %esp
  801113:	55                   	push   %ebp
  801114:	56                   	push   %esi
  801115:	57                   	push   %edi
  801116:	89 e5                	mov    %esp,%ebp
  801118:	8d 35 20 11 80 00    	lea    0x801120,%esi
  80111e:	0f 34                	sysenter 

00801120 <label_577>:
  801120:	5f                   	pop    %edi
  801121:	5e                   	pop    %esi
  801122:	5d                   	pop    %ebp
  801123:	5c                   	pop    %esp
  801124:	5b                   	pop    %ebx
  801125:	5a                   	pop    %edx
  801126:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801127:	5b                   	pop    %ebx
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801130:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  801133:	a1 10 20 80 00       	mov    0x802010,%eax
  801138:	85 c0                	test   %eax,%eax
  80113a:	74 11                	je     80114d <_panic+0x22>
		cprintf("%s: ", argv0);
  80113c:	83 ec 08             	sub    $0x8,%esp
  80113f:	50                   	push   %eax
  801140:	68 8f 17 80 00       	push   $0x80178f
  801145:	e8 3b f0 ff ff       	call   800185 <cprintf>
  80114a:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80114d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801153:	e8 f5 fc ff ff       	call   800e4d <sys_getenvid>
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	ff 75 0c             	pushl  0xc(%ebp)
  80115e:	ff 75 08             	pushl  0x8(%ebp)
  801161:	56                   	push   %esi
  801162:	50                   	push   %eax
  801163:	68 98 17 80 00       	push   $0x801798
  801168:	e8 18 f0 ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80116d:	83 c4 18             	add    $0x18,%esp
  801170:	53                   	push   %ebx
  801171:	ff 75 10             	pushl  0x10(%ebp)
  801174:	e8 bb ef ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  801179:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  801180:	e8 00 f0 ff ff       	call   800185 <cprintf>
  801185:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801188:	cc                   	int3   
  801189:	eb fd                	jmp    801188 <_panic+0x5d>
  80118b:	66 90                	xchg   %ax,%ax
  80118d:	66 90                	xchg   %ax,%ax
  80118f:	90                   	nop

00801190 <__udivdi3>:
  801190:	55                   	push   %ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 1c             	sub    $0x1c,%esp
  801197:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80119b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80119f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011a7:	85 f6                	test   %esi,%esi
  8011a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ad:	89 ca                	mov    %ecx,%edx
  8011af:	89 f8                	mov    %edi,%eax
  8011b1:	75 3d                	jne    8011f0 <__udivdi3+0x60>
  8011b3:	39 cf                	cmp    %ecx,%edi
  8011b5:	0f 87 c5 00 00 00    	ja     801280 <__udivdi3+0xf0>
  8011bb:	85 ff                	test   %edi,%edi
  8011bd:	89 fd                	mov    %edi,%ebp
  8011bf:	75 0b                	jne    8011cc <__udivdi3+0x3c>
  8011c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c6:	31 d2                	xor    %edx,%edx
  8011c8:	f7 f7                	div    %edi
  8011ca:	89 c5                	mov    %eax,%ebp
  8011cc:	89 c8                	mov    %ecx,%eax
  8011ce:	31 d2                	xor    %edx,%edx
  8011d0:	f7 f5                	div    %ebp
  8011d2:	89 c1                	mov    %eax,%ecx
  8011d4:	89 d8                	mov    %ebx,%eax
  8011d6:	89 cf                	mov    %ecx,%edi
  8011d8:	f7 f5                	div    %ebp
  8011da:	89 c3                	mov    %eax,%ebx
  8011dc:	89 d8                	mov    %ebx,%eax
  8011de:	89 fa                	mov    %edi,%edx
  8011e0:	83 c4 1c             	add    $0x1c,%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    
  8011e8:	90                   	nop
  8011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	39 ce                	cmp    %ecx,%esi
  8011f2:	77 74                	ja     801268 <__udivdi3+0xd8>
  8011f4:	0f bd fe             	bsr    %esi,%edi
  8011f7:	83 f7 1f             	xor    $0x1f,%edi
  8011fa:	0f 84 98 00 00 00    	je     801298 <__udivdi3+0x108>
  801200:	bb 20 00 00 00       	mov    $0x20,%ebx
  801205:	89 f9                	mov    %edi,%ecx
  801207:	89 c5                	mov    %eax,%ebp
  801209:	29 fb                	sub    %edi,%ebx
  80120b:	d3 e6                	shl    %cl,%esi
  80120d:	89 d9                	mov    %ebx,%ecx
  80120f:	d3 ed                	shr    %cl,%ebp
  801211:	89 f9                	mov    %edi,%ecx
  801213:	d3 e0                	shl    %cl,%eax
  801215:	09 ee                	or     %ebp,%esi
  801217:	89 d9                	mov    %ebx,%ecx
  801219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121d:	89 d5                	mov    %edx,%ebp
  80121f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801223:	d3 ed                	shr    %cl,%ebp
  801225:	89 f9                	mov    %edi,%ecx
  801227:	d3 e2                	shl    %cl,%edx
  801229:	89 d9                	mov    %ebx,%ecx
  80122b:	d3 e8                	shr    %cl,%eax
  80122d:	09 c2                	or     %eax,%edx
  80122f:	89 d0                	mov    %edx,%eax
  801231:	89 ea                	mov    %ebp,%edx
  801233:	f7 f6                	div    %esi
  801235:	89 d5                	mov    %edx,%ebp
  801237:	89 c3                	mov    %eax,%ebx
  801239:	f7 64 24 0c          	mull   0xc(%esp)
  80123d:	39 d5                	cmp    %edx,%ebp
  80123f:	72 10                	jb     801251 <__udivdi3+0xc1>
  801241:	8b 74 24 08          	mov    0x8(%esp),%esi
  801245:	89 f9                	mov    %edi,%ecx
  801247:	d3 e6                	shl    %cl,%esi
  801249:	39 c6                	cmp    %eax,%esi
  80124b:	73 07                	jae    801254 <__udivdi3+0xc4>
  80124d:	39 d5                	cmp    %edx,%ebp
  80124f:	75 03                	jne    801254 <__udivdi3+0xc4>
  801251:	83 eb 01             	sub    $0x1,%ebx
  801254:	31 ff                	xor    %edi,%edi
  801256:	89 d8                	mov    %ebx,%eax
  801258:	89 fa                	mov    %edi,%edx
  80125a:	83 c4 1c             	add    $0x1c,%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    
  801262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801268:	31 ff                	xor    %edi,%edi
  80126a:	31 db                	xor    %ebx,%ebx
  80126c:	89 d8                	mov    %ebx,%eax
  80126e:	89 fa                	mov    %edi,%edx
  801270:	83 c4 1c             	add    $0x1c,%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
  801278:	90                   	nop
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 d8                	mov    %ebx,%eax
  801282:	f7 f7                	div    %edi
  801284:	31 ff                	xor    %edi,%edi
  801286:	89 c3                	mov    %eax,%ebx
  801288:	89 d8                	mov    %ebx,%eax
  80128a:	89 fa                	mov    %edi,%edx
  80128c:	83 c4 1c             	add    $0x1c,%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	39 ce                	cmp    %ecx,%esi
  80129a:	72 0c                	jb     8012a8 <__udivdi3+0x118>
  80129c:	31 db                	xor    %ebx,%ebx
  80129e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012a2:	0f 87 34 ff ff ff    	ja     8011dc <__udivdi3+0x4c>
  8012a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012ad:	e9 2a ff ff ff       	jmp    8011dc <__udivdi3+0x4c>
  8012b2:	66 90                	xchg   %ax,%ax
  8012b4:	66 90                	xchg   %ax,%ax
  8012b6:	66 90                	xchg   %ax,%ax
  8012b8:	66 90                	xchg   %ax,%ax
  8012ba:	66 90                	xchg   %ax,%ax
  8012bc:	66 90                	xchg   %ax,%ax
  8012be:	66 90                	xchg   %ax,%ax

008012c0 <__umoddi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 1c             	sub    $0x1c,%esp
  8012c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012d7:	85 d2                	test   %edx,%edx
  8012d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e1:	89 f3                	mov    %esi,%ebx
  8012e3:	89 3c 24             	mov    %edi,(%esp)
  8012e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ea:	75 1c                	jne    801308 <__umoddi3+0x48>
  8012ec:	39 f7                	cmp    %esi,%edi
  8012ee:	76 50                	jbe    801340 <__umoddi3+0x80>
  8012f0:	89 c8                	mov    %ecx,%eax
  8012f2:	89 f2                	mov    %esi,%edx
  8012f4:	f7 f7                	div    %edi
  8012f6:	89 d0                	mov    %edx,%eax
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	83 c4 1c             	add    $0x1c,%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    
  801302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801308:	39 f2                	cmp    %esi,%edx
  80130a:	89 d0                	mov    %edx,%eax
  80130c:	77 52                	ja     801360 <__umoddi3+0xa0>
  80130e:	0f bd ea             	bsr    %edx,%ebp
  801311:	83 f5 1f             	xor    $0x1f,%ebp
  801314:	75 5a                	jne    801370 <__umoddi3+0xb0>
  801316:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80131a:	0f 82 e0 00 00 00    	jb     801400 <__umoddi3+0x140>
  801320:	39 0c 24             	cmp    %ecx,(%esp)
  801323:	0f 86 d7 00 00 00    	jbe    801400 <__umoddi3+0x140>
  801329:	8b 44 24 08          	mov    0x8(%esp),%eax
  80132d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801331:	83 c4 1c             	add    $0x1c,%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    
  801339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801340:	85 ff                	test   %edi,%edi
  801342:	89 fd                	mov    %edi,%ebp
  801344:	75 0b                	jne    801351 <__umoddi3+0x91>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f7                	div    %edi
  80134f:	89 c5                	mov    %eax,%ebp
  801351:	89 f0                	mov    %esi,%eax
  801353:	31 d2                	xor    %edx,%edx
  801355:	f7 f5                	div    %ebp
  801357:	89 c8                	mov    %ecx,%eax
  801359:	f7 f5                	div    %ebp
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	eb 99                	jmp    8012f8 <__umoddi3+0x38>
  80135f:	90                   	nop
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 f2                	mov    %esi,%edx
  801364:	83 c4 1c             	add    $0x1c,%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5f                   	pop    %edi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    
  80136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801370:	8b 34 24             	mov    (%esp),%esi
  801373:	bf 20 00 00 00       	mov    $0x20,%edi
  801378:	89 e9                	mov    %ebp,%ecx
  80137a:	29 ef                	sub    %ebp,%edi
  80137c:	d3 e0                	shl    %cl,%eax
  80137e:	89 f9                	mov    %edi,%ecx
  801380:	89 f2                	mov    %esi,%edx
  801382:	d3 ea                	shr    %cl,%edx
  801384:	89 e9                	mov    %ebp,%ecx
  801386:	09 c2                	or     %eax,%edx
  801388:	89 d8                	mov    %ebx,%eax
  80138a:	89 14 24             	mov    %edx,(%esp)
  80138d:	89 f2                	mov    %esi,%edx
  80138f:	d3 e2                	shl    %cl,%edx
  801391:	89 f9                	mov    %edi,%ecx
  801393:	89 54 24 04          	mov    %edx,0x4(%esp)
  801397:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80139b:	d3 e8                	shr    %cl,%eax
  80139d:	89 e9                	mov    %ebp,%ecx
  80139f:	89 c6                	mov    %eax,%esi
  8013a1:	d3 e3                	shl    %cl,%ebx
  8013a3:	89 f9                	mov    %edi,%ecx
  8013a5:	89 d0                	mov    %edx,%eax
  8013a7:	d3 e8                	shr    %cl,%eax
  8013a9:	89 e9                	mov    %ebp,%ecx
  8013ab:	09 d8                	or     %ebx,%eax
  8013ad:	89 d3                	mov    %edx,%ebx
  8013af:	89 f2                	mov    %esi,%edx
  8013b1:	f7 34 24             	divl   (%esp)
  8013b4:	89 d6                	mov    %edx,%esi
  8013b6:	d3 e3                	shl    %cl,%ebx
  8013b8:	f7 64 24 04          	mull   0x4(%esp)
  8013bc:	39 d6                	cmp    %edx,%esi
  8013be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c2:	89 d1                	mov    %edx,%ecx
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	72 08                	jb     8013d0 <__umoddi3+0x110>
  8013c8:	75 11                	jne    8013db <__umoddi3+0x11b>
  8013ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013ce:	73 0b                	jae    8013db <__umoddi3+0x11b>
  8013d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013d4:	1b 14 24             	sbb    (%esp),%edx
  8013d7:	89 d1                	mov    %edx,%ecx
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013df:	29 da                	sub    %ebx,%edx
  8013e1:	19 ce                	sbb    %ecx,%esi
  8013e3:	89 f9                	mov    %edi,%ecx
  8013e5:	89 f0                	mov    %esi,%eax
  8013e7:	d3 e0                	shl    %cl,%eax
  8013e9:	89 e9                	mov    %ebp,%ecx
  8013eb:	d3 ea                	shr    %cl,%edx
  8013ed:	89 e9                	mov    %ebp,%ecx
  8013ef:	d3 ee                	shr    %cl,%esi
  8013f1:	09 d0                	or     %edx,%eax
  8013f3:	89 f2                	mov    %esi,%edx
  8013f5:	83 c4 1c             	add    $0x1c,%esp
  8013f8:	5b                   	pop    %ebx
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	29 f9                	sub    %edi,%ecx
  801402:	19 d6                	sbb    %edx,%esi
  801404:	89 74 24 04          	mov    %esi,0x4(%esp)
  801408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140c:	e9 18 ff ff ff       	jmp    801329 <__umoddi3+0x69>
