
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 a0 14 80 00       	push   $0x8014a0
  80003f:	e8 5c 01 00 00       	call   8001a0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 1e 11 00 00       	call   801167 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 18 15 80 00       	push   $0x801518
  800058:	e8 43 01 00 00       	call   8001a0 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 c8 14 80 00       	push   $0x8014c8
  80006c:	e8 2f 01 00 00       	call   8001a0 <cprintf>
	sys_yield();
  800071:	e8 56 0e 00 00       	call   800ecc <sys_yield>
	sys_yield();
  800076:	e8 51 0e 00 00       	call   800ecc <sys_yield>
	sys_yield();
  80007b:	e8 4c 0e 00 00       	call   800ecc <sys_yield>
	sys_yield();
  800080:	e8 47 0e 00 00       	call   800ecc <sys_yield>
	sys_yield();
  800085:	e8 42 0e 00 00       	call   800ecc <sys_yield>
	sys_yield();
  80008a:	e8 3d 0e 00 00       	call   800ecc <sys_yield>
	sys_yield();
  80008f:	e8 38 0e 00 00       	call   800ecc <sys_yield>
	sys_yield();
  800094:	e8 33 0e 00 00       	call   800ecc <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  8000a0:	e8 fb 00 00 00       	call   8001a0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 6b 0d 00 00       	call   800e18 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c0:	e8 a3 0d 00 00       	call   800e68 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	c1 e0 07             	shl    $0x7,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 10 0d 00 00       	call   800e18 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	75 1a                	jne    800146 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	68 ff 00 00 00       	push   $0xff
  800134:	8d 43 08             	lea    0x8(%ebx),%eax
  800137:	50                   	push   %eax
  800138:	e8 7a 0c 00 00       	call   800db7 <sys_cputs>
		b->idx = 0;
  80013d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800143:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 0d 01 80 00       	push   $0x80010d
  80017e:	e8 c0 02 00 00       	call   800443 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 1f 0c 00 00       	call   800db7 <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 1c             	sub    $0x1c,%esp
  8001bd:	89 c7                	mov    %eax,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  8001d0:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001d4:	0f 85 bf 00 00 00    	jne    800299 <printnum+0xe5>
  8001da:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8001e0:	0f 8d de 00 00 00    	jge    8002c4 <printnum+0x110>
		judge_time_for_space = width;
  8001e6:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8001ec:	e9 d3 00 00 00       	jmp    8002c4 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001f1:	83 eb 01             	sub    $0x1,%ebx
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7f 37                	jg     80022f <printnum+0x7b>
  8001f8:	e9 ea 00 00 00       	jmp    8002e7 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8001fd:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800200:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	56                   	push   %esi
  800209:	83 ec 04             	sub    $0x4,%esp
  80020c:	ff 75 dc             	pushl  -0x24(%ebp)
  80020f:	ff 75 d8             	pushl  -0x28(%ebp)
  800212:	ff 75 e4             	pushl  -0x1c(%ebp)
  800215:	ff 75 e0             	pushl  -0x20(%ebp)
  800218:	e8 13 11 00 00       	call   801330 <__umoddi3>
  80021d:	83 c4 14             	add    $0x14,%esp
  800220:	0f be 80 40 15 80 00 	movsbl 0x801540(%eax),%eax
  800227:	50                   	push   %eax
  800228:	ff d7                	call   *%edi
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	eb 16                	jmp    800245 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	83 eb 01             	sub    $0x1,%ebx
  80023e:	75 ef                	jne    80022f <printnum+0x7b>
  800240:	e9 a2 00 00 00       	jmp    8002e7 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800245:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  80024b:	0f 85 76 01 00 00    	jne    8003c7 <printnum+0x213>
		while(num_of_space-- > 0)
  800251:	a1 04 20 80 00       	mov    0x802004,%eax
  800256:	8d 50 ff             	lea    -0x1(%eax),%edx
  800259:	89 15 04 20 80 00    	mov    %edx,0x802004
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 1d                	jle    800280 <printnum+0xcc>
			putch(' ', putdat);
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	56                   	push   %esi
  800267:	6a 20                	push   $0x20
  800269:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80026b:	a1 04 20 80 00       	mov    0x802004,%eax
  800270:	8d 50 ff             	lea    -0x1(%eax),%edx
  800273:	89 15 04 20 80 00    	mov    %edx,0x802004
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7f e3                	jg     800263 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800280:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800287:	00 00 00 
		judge_time_for_space = 0;
  80028a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800291:	00 00 00 
	}
}
  800294:	e9 2e 01 00 00       	jmp    8003c7 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 45 10             	mov    0x10(%ebp),%eax
  80029c:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002ad:	83 fa 00             	cmp    $0x0,%edx
  8002b0:	0f 87 ba 00 00 00    	ja     800370 <printnum+0x1bc>
  8002b6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002b9:	0f 83 b1 00 00 00    	jae    800370 <printnum+0x1bc>
  8002bf:	e9 2d ff ff ff       	jmp    8001f1 <printnum+0x3d>
  8002c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002d8:	83 fa 00             	cmp    $0x0,%edx
  8002db:	77 37                	ja     800314 <printnum+0x160>
  8002dd:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002e0:	73 32                	jae    800314 <printnum+0x160>
  8002e2:	e9 16 ff ff ff       	jmp    8001fd <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	83 ec 04             	sub    $0x4,%esp
  8002ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002fa:	e8 31 10 00 00       	call   801330 <__umoddi3>
  8002ff:	83 c4 14             	add    $0x14,%esp
  800302:	0f be 80 40 15 80 00 	movsbl 0x801540(%eax),%eax
  800309:	50                   	push   %eax
  80030a:	ff d7                	call   *%edi
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	e9 b3 00 00 00       	jmp    8003c7 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 18             	pushl  0x18(%ebp)
  80031a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80031d:	50                   	push   %eax
  80031e:	ff 75 10             	pushl  0x10(%ebp)
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	ff 75 dc             	pushl  -0x24(%ebp)
  800327:	ff 75 d8             	pushl  -0x28(%ebp)
  80032a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032d:	ff 75 e0             	pushl  -0x20(%ebp)
  800330:	e8 cb 0e 00 00       	call   801200 <__udivdi3>
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	52                   	push   %edx
  800339:	50                   	push   %eax
  80033a:	89 f2                	mov    %esi,%edx
  80033c:	89 f8                	mov    %edi,%eax
  80033e:	e8 71 fe ff ff       	call   8001b4 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800343:	83 c4 18             	add    $0x18,%esp
  800346:	56                   	push   %esi
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	ff 75 dc             	pushl  -0x24(%ebp)
  80034d:	ff 75 d8             	pushl  -0x28(%ebp)
  800350:	ff 75 e4             	pushl  -0x1c(%ebp)
  800353:	ff 75 e0             	pushl  -0x20(%ebp)
  800356:	e8 d5 0f 00 00       	call   801330 <__umoddi3>
  80035b:	83 c4 14             	add    $0x14,%esp
  80035e:	0f be 80 40 15 80 00 	movsbl 0x801540(%eax),%eax
  800365:	50                   	push   %eax
  800366:	ff d7                	call   *%edi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	e9 d5 fe ff ff       	jmp    800245 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	ff 75 18             	pushl  0x18(%ebp)
  800376:	83 eb 01             	sub    $0x1,%ebx
  800379:	53                   	push   %ebx
  80037a:	ff 75 10             	pushl  0x10(%ebp)
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	ff 75 dc             	pushl  -0x24(%ebp)
  800383:	ff 75 d8             	pushl  -0x28(%ebp)
  800386:	ff 75 e4             	pushl  -0x1c(%ebp)
  800389:	ff 75 e0             	pushl  -0x20(%ebp)
  80038c:	e8 6f 0e 00 00       	call   801200 <__udivdi3>
  800391:	83 c4 18             	add    $0x18,%esp
  800394:	52                   	push   %edx
  800395:	50                   	push   %eax
  800396:	89 f2                	mov    %esi,%edx
  800398:	89 f8                	mov    %edi,%eax
  80039a:	e8 15 fe ff ff       	call   8001b4 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039f:	83 c4 18             	add    $0x18,%esp
  8003a2:	56                   	push   %esi
  8003a3:	83 ec 04             	sub    $0x4,%esp
  8003a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003af:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b2:	e8 79 0f 00 00       	call   801330 <__umoddi3>
  8003b7:	83 c4 14             	add    $0x14,%esp
  8003ba:	0f be 80 40 15 80 00 	movsbl 0x801540(%eax),%eax
  8003c1:	50                   	push   %eax
  8003c2:	ff d7                	call   *%edi
  8003c4:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8003c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d2:	83 fa 01             	cmp    $0x1,%edx
  8003d5:	7e 0e                	jle    8003e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d7:	8b 10                	mov    (%eax),%edx
  8003d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003dc:	89 08                	mov    %ecx,(%eax)
  8003de:	8b 02                	mov    (%edx),%eax
  8003e0:	8b 52 04             	mov    0x4(%edx),%edx
  8003e3:	eb 22                	jmp    800407 <getuint+0x38>
	else if (lflag)
  8003e5:	85 d2                	test   %edx,%edx
  8003e7:	74 10                	je     8003f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 02                	mov    (%edx),%eax
  8003f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f7:	eb 0e                	jmp    800407 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 02                	mov    (%edx),%eax
  800402:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800413:	8b 10                	mov    (%eax),%edx
  800415:	3b 50 04             	cmp    0x4(%eax),%edx
  800418:	73 0a                	jae    800424 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041d:	89 08                	mov    %ecx,(%eax)
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	88 02                	mov    %al,(%edx)
}
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042f:	50                   	push   %eax
  800430:	ff 75 10             	pushl  0x10(%ebp)
  800433:	ff 75 0c             	pushl  0xc(%ebp)
  800436:	ff 75 08             	pushl  0x8(%ebp)
  800439:	e8 05 00 00 00       	call   800443 <vprintfmt>
	va_end(ap);
}
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	c9                   	leave  
  800442:	c3                   	ret    

00800443 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
  800446:	57                   	push   %edi
  800447:	56                   	push   %esi
  800448:	53                   	push   %ebx
  800449:	83 ec 2c             	sub    $0x2c,%esp
  80044c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80044f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800452:	eb 03                	jmp    800457 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800454:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800457:	8b 45 10             	mov    0x10(%ebp),%eax
  80045a:	8d 70 01             	lea    0x1(%eax),%esi
  80045d:	0f b6 00             	movzbl (%eax),%eax
  800460:	83 f8 25             	cmp    $0x25,%eax
  800463:	74 27                	je     80048c <vprintfmt+0x49>
			if (ch == '\0')
  800465:	85 c0                	test   %eax,%eax
  800467:	75 0d                	jne    800476 <vprintfmt+0x33>
  800469:	e9 9d 04 00 00       	jmp    80090b <vprintfmt+0x4c8>
  80046e:	85 c0                	test   %eax,%eax
  800470:	0f 84 95 04 00 00    	je     80090b <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	53                   	push   %ebx
  80047a:	50                   	push   %eax
  80047b:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047d:	83 c6 01             	add    $0x1,%esi
  800480:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	83 f8 25             	cmp    $0x25,%eax
  80048a:	75 e2                	jne    80046e <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80048c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800491:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800495:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80049c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004aa:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004b1:	eb 08                	jmp    8004bb <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8004b6:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8d 46 01             	lea    0x1(%esi),%eax
  8004be:	89 45 10             	mov    %eax,0x10(%ebp)
  8004c1:	0f b6 06             	movzbl (%esi),%eax
  8004c4:	0f b6 d0             	movzbl %al,%edx
  8004c7:	83 e8 23             	sub    $0x23,%eax
  8004ca:	3c 55                	cmp    $0x55,%al
  8004cc:	0f 87 fa 03 00 00    	ja     8008cc <vprintfmt+0x489>
  8004d2:	0f b6 c0             	movzbl %al,%eax
  8004d5:	ff 24 85 80 16 80 00 	jmp    *0x801680(,%eax,4)
  8004dc:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004df:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8004e3:	eb d6                	jmp    8004bb <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e5:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004eb:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004ef:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f2:	83 fa 09             	cmp    $0x9,%edx
  8004f5:	77 6b                	ja     800562 <vprintfmt+0x11f>
  8004f7:	8b 75 10             	mov    0x10(%ebp),%esi
  8004fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004fd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800500:	eb 09                	jmp    80050b <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800505:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800509:	eb b0                	jmp    8004bb <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050b:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80050e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800511:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800515:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800518:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80051b:	83 f9 09             	cmp    $0x9,%ecx
  80051e:	76 eb                	jbe    80050b <vprintfmt+0xc8>
  800520:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800523:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800526:	eb 3d                	jmp    800565 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 00                	mov    (%eax),%eax
  800533:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800539:	eb 2a                	jmp    800565 <vprintfmt+0x122>
  80053b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053e:	85 c0                	test   %eax,%eax
  800540:	ba 00 00 00 00       	mov    $0x0,%edx
  800545:	0f 49 d0             	cmovns %eax,%edx
  800548:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 75 10             	mov    0x10(%ebp),%esi
  80054e:	e9 68 ff ff ff       	jmp    8004bb <vprintfmt+0x78>
  800553:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800556:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80055d:	e9 59 ff ff ff       	jmp    8004bb <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800565:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800569:	0f 89 4c ff ff ff    	jns    8004bb <vprintfmt+0x78>
				width = precision, precision = -1;
  80056f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800572:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800575:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80057c:	e9 3a ff ff ff       	jmp    8004bb <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800581:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800588:	e9 2e ff ff ff       	jmp    8004bb <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	ff 30                	pushl  (%eax)
  80059c:	ff d7                	call   *%edi
			break;
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	e9 b1 fe ff ff       	jmp    800457 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	99                   	cltd   
  8005b2:	31 d0                	xor    %edx,%eax
  8005b4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b6:	83 f8 08             	cmp    $0x8,%eax
  8005b9:	7f 0b                	jg     8005c6 <vprintfmt+0x183>
  8005bb:	8b 14 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%edx
  8005c2:	85 d2                	test   %edx,%edx
  8005c4:	75 15                	jne    8005db <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8005c6:	50                   	push   %eax
  8005c7:	68 58 15 80 00       	push   $0x801558
  8005cc:	53                   	push   %ebx
  8005cd:	57                   	push   %edi
  8005ce:	e8 53 fe ff ff       	call   800426 <printfmt>
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	e9 7c fe ff ff       	jmp    800457 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005db:	52                   	push   %edx
  8005dc:	68 61 15 80 00       	push   $0x801561
  8005e1:	53                   	push   %ebx
  8005e2:	57                   	push   %edi
  8005e3:	e8 3e fe ff ff       	call   800426 <printfmt>
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	e9 67 fe ff ff       	jmp    800457 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 04             	lea    0x4(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	b9 51 15 80 00       	mov    $0x801551,%ecx
  800602:	0f 45 c8             	cmovne %eax,%ecx
  800605:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800608:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060c:	7e 06                	jle    800614 <vprintfmt+0x1d1>
  80060e:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800612:	75 19                	jne    80062d <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800614:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800617:	8d 70 01             	lea    0x1(%eax),%esi
  80061a:	0f b6 00             	movzbl (%eax),%eax
  80061d:	0f be d0             	movsbl %al,%edx
  800620:	85 d2                	test   %edx,%edx
  800622:	0f 85 9f 00 00 00    	jne    8006c7 <vprintfmt+0x284>
  800628:	e9 8c 00 00 00       	jmp    8006b9 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	ff 75 d0             	pushl  -0x30(%ebp)
  800633:	ff 75 cc             	pushl  -0x34(%ebp)
  800636:	e8 62 03 00 00       	call   80099d <strnlen>
  80063b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80063e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	85 c9                	test   %ecx,%ecx
  800646:	0f 8e a6 02 00 00    	jle    8008f2 <vprintfmt+0x4af>
					putch(padc, putdat);
  80064c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800650:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800653:	89 cb                	mov    %ecx,%ebx
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	56                   	push   %esi
  80065c:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	83 eb 01             	sub    $0x1,%ebx
  800664:	75 ef                	jne    800655 <vprintfmt+0x212>
  800666:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800669:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066c:	e9 81 02 00 00       	jmp    8008f2 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800671:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800675:	74 1b                	je     800692 <vprintfmt+0x24f>
  800677:	0f be c0             	movsbl %al,%eax
  80067a:	83 e8 20             	sub    $0x20,%eax
  80067d:	83 f8 5e             	cmp    $0x5e,%eax
  800680:	76 10                	jbe    800692 <vprintfmt+0x24f>
					putch('?', putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	ff 75 0c             	pushl  0xc(%ebp)
  800688:	6a 3f                	push   $0x3f
  80068a:	ff 55 08             	call   *0x8(%ebp)
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	eb 0d                	jmp    80069f <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	ff 75 0c             	pushl  0xc(%ebp)
  800698:	52                   	push   %edx
  800699:	ff 55 08             	call   *0x8(%ebp)
  80069c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069f:	83 ef 01             	sub    $0x1,%edi
  8006a2:	83 c6 01             	add    $0x1,%esi
  8006a5:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8006a9:	0f be d0             	movsbl %al,%edx
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	75 31                	jne    8006e1 <vprintfmt+0x29e>
  8006b0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c0:	7f 33                	jg     8006f5 <vprintfmt+0x2b2>
  8006c2:	e9 90 fd ff ff       	jmp    800457 <vprintfmt+0x14>
  8006c7:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006d3:	eb 0c                	jmp    8006e1 <vprintfmt+0x29e>
  8006d5:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006de:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e1:	85 db                	test   %ebx,%ebx
  8006e3:	78 8c                	js     800671 <vprintfmt+0x22e>
  8006e5:	83 eb 01             	sub    $0x1,%ebx
  8006e8:	79 87                	jns    800671 <vprintfmt+0x22e>
  8006ea:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f3:	eb c4                	jmp    8006b9 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 20                	push   $0x20
  8006fb:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	83 ee 01             	sub    $0x1,%esi
  800703:	75 f0                	jne    8006f5 <vprintfmt+0x2b2>
  800705:	e9 4d fd ff ff       	jmp    800457 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070a:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80070e:	7e 16                	jle    800726 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8d 50 08             	lea    0x8(%eax),%edx
  800716:	89 55 14             	mov    %edx,0x14(%ebp)
  800719:	8b 50 04             	mov    0x4(%eax),%edx
  80071c:	8b 00                	mov    (%eax),%eax
  80071e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800721:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800724:	eb 34                	jmp    80075a <vprintfmt+0x317>
	else if (lflag)
  800726:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80072a:	74 18                	je     800744 <vprintfmt+0x301>
		return va_arg(*ap, long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 30                	mov    (%eax),%esi
  800737:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80073a:	89 f0                	mov    %esi,%eax
  80073c:	c1 f8 1f             	sar    $0x1f,%eax
  80073f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800742:	eb 16                	jmp    80075a <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 04             	lea    0x4(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)
  80074d:	8b 30                	mov    (%eax),%esi
  80074f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800752:	89 f0                	mov    %esi,%eax
  800754:	c1 f8 1f             	sar    $0x1f,%eax
  800757:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80075d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800760:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800763:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800766:	85 d2                	test   %edx,%edx
  800768:	79 28                	jns    800792 <vprintfmt+0x34f>
				putch('-', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 2d                	push   $0x2d
  800770:	ff d7                	call   *%edi
				num = -(long long) num;
  800772:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800775:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800778:	f7 d8                	neg    %eax
  80077a:	83 d2 00             	adc    $0x0,%edx
  80077d:	f7 da                	neg    %edx
  80077f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800782:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800785:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800788:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078d:	e9 b2 00 00 00       	jmp    800844 <vprintfmt+0x401>
  800792:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800797:	85 c9                	test   %ecx,%ecx
  800799:	0f 84 a5 00 00 00    	je     800844 <vprintfmt+0x401>
				putch('+', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 2b                	push   $0x2b
  8007a5:	ff d7                	call   *%edi
  8007a7:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8007aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007af:	e9 90 00 00 00       	jmp    800844 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8007b4:	85 c9                	test   %ecx,%ecx
  8007b6:	74 0b                	je     8007c3 <vprintfmt+0x380>
				putch('+', putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	53                   	push   %ebx
  8007bc:	6a 2b                	push   $0x2b
  8007be:	ff d7                	call   *%edi
  8007c0:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8007c3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 01 fc ff ff       	call   8003cf <getuint>
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007d4:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007d9:	eb 69                	jmp    800844 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	53                   	push   %ebx
  8007df:	6a 30                	push   $0x30
  8007e1:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007e3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 e1 fb ff ff       	call   8003cf <getuint>
  8007ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8007f4:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007f7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007fc:	eb 46                	jmp    800844 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	6a 30                	push   $0x30
  800804:	ff d7                	call   *%edi
			putch('x', putdat);
  800806:	83 c4 08             	add    $0x8,%esp
  800809:	53                   	push   %ebx
  80080a:	6a 78                	push   $0x78
  80080c:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8d 50 04             	lea    0x4(%eax),%edx
  800814:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800817:	8b 00                	mov    (%eax),%eax
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800821:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800824:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800827:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80082c:	eb 16                	jmp    800844 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80082e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800831:	8d 45 14             	lea    0x14(%ebp),%eax
  800834:	e8 96 fb ff ff       	call   8003cf <getuint>
  800839:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80083f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800844:	83 ec 0c             	sub    $0xc,%esp
  800847:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80084b:	56                   	push   %esi
  80084c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80084f:	50                   	push   %eax
  800850:	ff 75 dc             	pushl  -0x24(%ebp)
  800853:	ff 75 d8             	pushl  -0x28(%ebp)
  800856:	89 da                	mov    %ebx,%edx
  800858:	89 f8                	mov    %edi,%eax
  80085a:	e8 55 f9 ff ff       	call   8001b4 <printnum>
			break;
  80085f:	83 c4 20             	add    $0x20,%esp
  800862:	e9 f0 fb ff ff       	jmp    800457 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800867:	8b 45 14             	mov    0x14(%ebp),%eax
  80086a:	8d 50 04             	lea    0x4(%eax),%edx
  80086d:	89 55 14             	mov    %edx,0x14(%ebp)
  800870:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800872:	85 f6                	test   %esi,%esi
  800874:	75 1a                	jne    800890 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	68 f8 15 80 00       	push   $0x8015f8
  80087e:	68 61 15 80 00       	push   $0x801561
  800883:	e8 18 f9 ff ff       	call   8001a0 <cprintf>
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	e9 c7 fb ff ff       	jmp    800457 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800890:	0f b6 03             	movzbl (%ebx),%eax
  800893:	84 c0                	test   %al,%al
  800895:	79 1f                	jns    8008b6 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	68 30 16 80 00       	push   $0x801630
  80089f:	68 61 15 80 00       	push   $0x801561
  8008a4:	e8 f7 f8 ff ff       	call   8001a0 <cprintf>
						*tmp = *(char *)putdat;
  8008a9:	0f b6 03             	movzbl (%ebx),%eax
  8008ac:	88 06                	mov    %al,(%esi)
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	e9 a1 fb ff ff       	jmp    800457 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8008b6:	88 06                	mov    %al,(%esi)
  8008b8:	e9 9a fb ff ff       	jmp    800457 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	52                   	push   %edx
  8008c2:	ff d7                	call   *%edi
			break;
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	e9 8b fb ff ff       	jmp    800457 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	53                   	push   %ebx
  8008d0:	6a 25                	push   $0x25
  8008d2:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008db:	0f 84 73 fb ff ff    	je     800454 <vprintfmt+0x11>
  8008e1:	83 ee 01             	sub    $0x1,%esi
  8008e4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008e8:	75 f7                	jne    8008e1 <vprintfmt+0x49e>
  8008ea:	89 75 10             	mov    %esi,0x10(%ebp)
  8008ed:	e9 65 fb ff ff       	jmp    800457 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008f5:	8d 70 01             	lea    0x1(%eax),%esi
  8008f8:	0f b6 00             	movzbl (%eax),%eax
  8008fb:	0f be d0             	movsbl %al,%edx
  8008fe:	85 d2                	test   %edx,%edx
  800900:	0f 85 cf fd ff ff    	jne    8006d5 <vprintfmt+0x292>
  800906:	e9 4c fb ff ff       	jmp    800457 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80090b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	83 ec 18             	sub    $0x18,%esp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800922:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800926:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800929:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800930:	85 c0                	test   %eax,%eax
  800932:	74 26                	je     80095a <vsnprintf+0x47>
  800934:	85 d2                	test   %edx,%edx
  800936:	7e 22                	jle    80095a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800938:	ff 75 14             	pushl  0x14(%ebp)
  80093b:	ff 75 10             	pushl  0x10(%ebp)
  80093e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800941:	50                   	push   %eax
  800942:	68 09 04 80 00       	push   $0x800409
  800947:	e8 f7 fa ff ff       	call   800443 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	eb 05                	jmp    80095f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800967:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096a:	50                   	push   %eax
  80096b:	ff 75 10             	pushl  0x10(%ebp)
  80096e:	ff 75 0c             	pushl  0xc(%ebp)
  800971:	ff 75 08             	pushl  0x8(%ebp)
  800974:	e8 9a ff ff ff       	call   800913 <vsnprintf>
	va_end(ap);

	return rc;
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800981:	80 3a 00             	cmpb   $0x0,(%edx)
  800984:	74 10                	je     800996 <strlen+0x1b>
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80098b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80098e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800992:	75 f7                	jne    80098b <strlen+0x10>
  800994:	eb 05                	jmp    80099b <strlen+0x20>
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a7:	85 c9                	test   %ecx,%ecx
  8009a9:	74 1c                	je     8009c7 <strnlen+0x2a>
  8009ab:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009ae:	74 1e                	je     8009ce <strnlen+0x31>
  8009b0:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009b5:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b7:	39 ca                	cmp    %ecx,%edx
  8009b9:	74 18                	je     8009d3 <strnlen+0x36>
  8009bb:	83 c2 01             	add    $0x1,%edx
  8009be:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009c3:	75 f0                	jne    8009b5 <strnlen+0x18>
  8009c5:	eb 0c                	jmp    8009d3 <strnlen+0x36>
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cc:	eb 05                	jmp    8009d3 <strnlen+0x36>
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	53                   	push   %ebx
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e0:	89 c2                	mov    %eax,%edx
  8009e2:	83 c2 01             	add    $0x1,%edx
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009ef:	84 db                	test   %bl,%bl
  8009f1:	75 ef                	jne    8009e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009fd:	53                   	push   %ebx
  8009fe:	e8 78 ff ff ff       	call   80097b <strlen>
  800a03:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a06:	ff 75 0c             	pushl  0xc(%ebp)
  800a09:	01 d8                	add    %ebx,%eax
  800a0b:	50                   	push   %eax
  800a0c:	e8 c5 ff ff ff       	call   8009d6 <strcpy>
	return dst;
}
  800a11:	89 d8                	mov    %ebx,%eax
  800a13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a26:	85 db                	test   %ebx,%ebx
  800a28:	74 17                	je     800a41 <strncpy+0x29>
  800a2a:	01 f3                	add    %esi,%ebx
  800a2c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	0f b6 02             	movzbl (%edx),%eax
  800a34:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a37:	80 3a 01             	cmpb   $0x1,(%edx)
  800a3a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3d:	39 cb                	cmp    %ecx,%ebx
  800a3f:	75 ed                	jne    800a2e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a41:	89 f0                	mov    %esi,%eax
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a52:	8b 55 10             	mov    0x10(%ebp),%edx
  800a55:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a57:	85 d2                	test   %edx,%edx
  800a59:	74 35                	je     800a90 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a5b:	89 d0                	mov    %edx,%eax
  800a5d:	83 e8 01             	sub    $0x1,%eax
  800a60:	74 25                	je     800a87 <strlcpy+0x40>
  800a62:	0f b6 0b             	movzbl (%ebx),%ecx
  800a65:	84 c9                	test   %cl,%cl
  800a67:	74 22                	je     800a8b <strlcpy+0x44>
  800a69:	8d 53 01             	lea    0x1(%ebx),%edx
  800a6c:	01 c3                	add    %eax,%ebx
  800a6e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a76:	39 da                	cmp    %ebx,%edx
  800a78:	74 13                	je     800a8d <strlcpy+0x46>
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a81:	84 c9                	test   %cl,%cl
  800a83:	75 eb                	jne    800a70 <strlcpy+0x29>
  800a85:	eb 06                	jmp    800a8d <strlcpy+0x46>
  800a87:	89 f0                	mov    %esi,%eax
  800a89:	eb 02                	jmp    800a8d <strlcpy+0x46>
  800a8b:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a8d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a90:	29 f0                	sub    %esi,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a9f:	0f b6 01             	movzbl (%ecx),%eax
  800aa2:	84 c0                	test   %al,%al
  800aa4:	74 15                	je     800abb <strcmp+0x25>
  800aa6:	3a 02                	cmp    (%edx),%al
  800aa8:	75 11                	jne    800abb <strcmp+0x25>
		p++, q++;
  800aaa:	83 c1 01             	add    $0x1,%ecx
  800aad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab0:	0f b6 01             	movzbl (%ecx),%eax
  800ab3:	84 c0                	test   %al,%al
  800ab5:	74 04                	je     800abb <strcmp+0x25>
  800ab7:	3a 02                	cmp    (%edx),%al
  800ab9:	74 ef                	je     800aaa <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800abb:	0f b6 c0             	movzbl %al,%eax
  800abe:	0f b6 12             	movzbl (%edx),%edx
  800ac1:	29 d0                	sub    %edx,%eax
}
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800acd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad0:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800ad3:	85 f6                	test   %esi,%esi
  800ad5:	74 29                	je     800b00 <strncmp+0x3b>
  800ad7:	0f b6 03             	movzbl (%ebx),%eax
  800ada:	84 c0                	test   %al,%al
  800adc:	74 30                	je     800b0e <strncmp+0x49>
  800ade:	3a 02                	cmp    (%edx),%al
  800ae0:	75 2c                	jne    800b0e <strncmp+0x49>
  800ae2:	8d 43 01             	lea    0x1(%ebx),%eax
  800ae5:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aec:	39 c6                	cmp    %eax,%esi
  800aee:	74 17                	je     800b07 <strncmp+0x42>
  800af0:	0f b6 08             	movzbl (%eax),%ecx
  800af3:	84 c9                	test   %cl,%cl
  800af5:	74 17                	je     800b0e <strncmp+0x49>
  800af7:	83 c0 01             	add    $0x1,%eax
  800afa:	3a 0a                	cmp    (%edx),%cl
  800afc:	74 e9                	je     800ae7 <strncmp+0x22>
  800afe:	eb 0e                	jmp    800b0e <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	eb 0f                	jmp    800b16 <strncmp+0x51>
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	eb 08                	jmp    800b16 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0e:	0f b6 03             	movzbl (%ebx),%eax
  800b11:	0f b6 12             	movzbl (%edx),%edx
  800b14:	29 d0                	sub    %edx,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b24:	0f b6 10             	movzbl (%eax),%edx
  800b27:	84 d2                	test   %dl,%dl
  800b29:	74 1d                	je     800b48 <strchr+0x2e>
  800b2b:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b2d:	38 d3                	cmp    %dl,%bl
  800b2f:	75 06                	jne    800b37 <strchr+0x1d>
  800b31:	eb 1a                	jmp    800b4d <strchr+0x33>
  800b33:	38 ca                	cmp    %cl,%dl
  800b35:	74 16                	je     800b4d <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b37:	83 c0 01             	add    $0x1,%eax
  800b3a:	0f b6 10             	movzbl (%eax),%edx
  800b3d:	84 d2                	test   %dl,%dl
  800b3f:	75 f2                	jne    800b33 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	eb 05                	jmp    800b4d <strchr+0x33>
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	53                   	push   %ebx
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b5a:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b5d:	38 d3                	cmp    %dl,%bl
  800b5f:	74 14                	je     800b75 <strfind+0x25>
  800b61:	89 d1                	mov    %edx,%ecx
  800b63:	84 db                	test   %bl,%bl
  800b65:	74 0e                	je     800b75 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b6d:	38 ca                	cmp    %cl,%dl
  800b6f:	74 04                	je     800b75 <strfind+0x25>
  800b71:	84 d2                	test   %dl,%dl
  800b73:	75 f2                	jne    800b67 <strfind+0x17>
			break;
	return (char *) s;
}
  800b75:	5b                   	pop    %ebx
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b81:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b84:	85 c9                	test   %ecx,%ecx
  800b86:	74 36                	je     800bbe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b88:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8e:	75 28                	jne    800bb8 <memset+0x40>
  800b90:	f6 c1 03             	test   $0x3,%cl
  800b93:	75 23                	jne    800bb8 <memset+0x40>
		c &= 0xFF;
  800b95:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	c1 e3 08             	shl    $0x8,%ebx
  800b9e:	89 d6                	mov    %edx,%esi
  800ba0:	c1 e6 18             	shl    $0x18,%esi
  800ba3:	89 d0                	mov    %edx,%eax
  800ba5:	c1 e0 10             	shl    $0x10,%eax
  800ba8:	09 f0                	or     %esi,%eax
  800baa:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bac:	89 d8                	mov    %ebx,%eax
  800bae:	09 d0                	or     %edx,%eax
  800bb0:	c1 e9 02             	shr    $0x2,%ecx
  800bb3:	fc                   	cld    
  800bb4:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb6:	eb 06                	jmp    800bbe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	fc                   	cld    
  800bbc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bbe:	89 f8                	mov    %edi,%eax
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd3:	39 c6                	cmp    %eax,%esi
  800bd5:	73 35                	jae    800c0c <memmove+0x47>
  800bd7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bda:	39 d0                	cmp    %edx,%eax
  800bdc:	73 2e                	jae    800c0c <memmove+0x47>
		s += n;
		d += n;
  800bde:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	09 fe                	or     %edi,%esi
  800be5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800beb:	75 13                	jne    800c00 <memmove+0x3b>
  800bed:	f6 c1 03             	test   $0x3,%cl
  800bf0:	75 0e                	jne    800c00 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bf2:	83 ef 04             	sub    $0x4,%edi
  800bf5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf8:	c1 e9 02             	shr    $0x2,%ecx
  800bfb:	fd                   	std    
  800bfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfe:	eb 09                	jmp    800c09 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c00:	83 ef 01             	sub    $0x1,%edi
  800c03:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c06:	fd                   	std    
  800c07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c09:	fc                   	cld    
  800c0a:	eb 1d                	jmp    800c29 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0c:	89 f2                	mov    %esi,%edx
  800c0e:	09 c2                	or     %eax,%edx
  800c10:	f6 c2 03             	test   $0x3,%dl
  800c13:	75 0f                	jne    800c24 <memmove+0x5f>
  800c15:	f6 c1 03             	test   $0x3,%cl
  800c18:	75 0a                	jne    800c24 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c1a:	c1 e9 02             	shr    $0x2,%ecx
  800c1d:	89 c7                	mov    %eax,%edi
  800c1f:	fc                   	cld    
  800c20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c22:	eb 05                	jmp    800c29 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c24:	89 c7                	mov    %eax,%edi
  800c26:	fc                   	cld    
  800c27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c30:	ff 75 10             	pushl  0x10(%ebp)
  800c33:	ff 75 0c             	pushl  0xc(%ebp)
  800c36:	ff 75 08             	pushl  0x8(%ebp)
  800c39:	e8 87 ff ff ff       	call   800bc5 <memmove>
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	74 39                	je     800c8c <memcmp+0x4c>
  800c53:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c56:	0f b6 13             	movzbl (%ebx),%edx
  800c59:	0f b6 0e             	movzbl (%esi),%ecx
  800c5c:	38 ca                	cmp    %cl,%dl
  800c5e:	75 17                	jne    800c77 <memcmp+0x37>
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
  800c65:	eb 1a                	jmp    800c81 <memcmp+0x41>
  800c67:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c6c:	83 c0 01             	add    $0x1,%eax
  800c6f:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c73:	38 ca                	cmp    %cl,%dl
  800c75:	74 0a                	je     800c81 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c77:	0f b6 c2             	movzbl %dl,%eax
  800c7a:	0f b6 c9             	movzbl %cl,%ecx
  800c7d:	29 c8                	sub    %ecx,%eax
  800c7f:	eb 10                	jmp    800c91 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c81:	39 f8                	cmp    %edi,%eax
  800c83:	75 e2                	jne    800c67 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8a:	eb 05                	jmp    800c91 <memcmp+0x51>
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	53                   	push   %ebx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c9d:	89 d0                	mov    %edx,%eax
  800c9f:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800ca2:	39 c2                	cmp    %eax,%edx
  800ca4:	73 1d                	jae    800cc3 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800caa:	0f b6 0a             	movzbl (%edx),%ecx
  800cad:	39 d9                	cmp    %ebx,%ecx
  800caf:	75 09                	jne    800cba <memfind+0x24>
  800cb1:	eb 14                	jmp    800cc7 <memfind+0x31>
  800cb3:	0f b6 0a             	movzbl (%edx),%ecx
  800cb6:	39 d9                	cmp    %ebx,%ecx
  800cb8:	74 11                	je     800ccb <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cba:	83 c2 01             	add    $0x1,%edx
  800cbd:	39 d0                	cmp    %edx,%eax
  800cbf:	75 f2                	jne    800cb3 <memfind+0x1d>
  800cc1:	eb 0a                	jmp    800ccd <memfind+0x37>
  800cc3:	89 d0                	mov    %edx,%eax
  800cc5:	eb 06                	jmp    800ccd <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc7:	89 d0                	mov    %edx,%eax
  800cc9:	eb 02                	jmp    800ccd <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ccb:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdc:	0f b6 01             	movzbl (%ecx),%eax
  800cdf:	3c 20                	cmp    $0x20,%al
  800ce1:	74 04                	je     800ce7 <strtol+0x17>
  800ce3:	3c 09                	cmp    $0x9,%al
  800ce5:	75 0e                	jne    800cf5 <strtol+0x25>
		s++;
  800ce7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cea:	0f b6 01             	movzbl (%ecx),%eax
  800ced:	3c 20                	cmp    $0x20,%al
  800cef:	74 f6                	je     800ce7 <strtol+0x17>
  800cf1:	3c 09                	cmp    $0x9,%al
  800cf3:	74 f2                	je     800ce7 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf5:	3c 2b                	cmp    $0x2b,%al
  800cf7:	75 0a                	jne    800d03 <strtol+0x33>
		s++;
  800cf9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800d01:	eb 11                	jmp    800d14 <strtol+0x44>
  800d03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d08:	3c 2d                	cmp    $0x2d,%al
  800d0a:	75 08                	jne    800d14 <strtol+0x44>
		s++, neg = 1;
  800d0c:	83 c1 01             	add    $0x1,%ecx
  800d0f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d1a:	75 15                	jne    800d31 <strtol+0x61>
  800d1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800d1f:	75 10                	jne    800d31 <strtol+0x61>
  800d21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d25:	75 7c                	jne    800da3 <strtol+0xd3>
		s += 2, base = 16;
  800d27:	83 c1 02             	add    $0x2,%ecx
  800d2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d2f:	eb 16                	jmp    800d47 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d31:	85 db                	test   %ebx,%ebx
  800d33:	75 12                	jne    800d47 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d35:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d3d:	75 08                	jne    800d47 <strtol+0x77>
		s++, base = 8;
  800d3f:	83 c1 01             	add    $0x1,%ecx
  800d42:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d47:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d4f:	0f b6 11             	movzbl (%ecx),%edx
  800d52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d55:	89 f3                	mov    %esi,%ebx
  800d57:	80 fb 09             	cmp    $0x9,%bl
  800d5a:	77 08                	ja     800d64 <strtol+0x94>
			dig = *s - '0';
  800d5c:	0f be d2             	movsbl %dl,%edx
  800d5f:	83 ea 30             	sub    $0x30,%edx
  800d62:	eb 22                	jmp    800d86 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d64:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d67:	89 f3                	mov    %esi,%ebx
  800d69:	80 fb 19             	cmp    $0x19,%bl
  800d6c:	77 08                	ja     800d76 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d6e:	0f be d2             	movsbl %dl,%edx
  800d71:	83 ea 57             	sub    $0x57,%edx
  800d74:	eb 10                	jmp    800d86 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d76:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d79:	89 f3                	mov    %esi,%ebx
  800d7b:	80 fb 19             	cmp    $0x19,%bl
  800d7e:	77 16                	ja     800d96 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d80:	0f be d2             	movsbl %dl,%edx
  800d83:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d86:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d89:	7d 0b                	jge    800d96 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d8b:	83 c1 01             	add    $0x1,%ecx
  800d8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d92:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d94:	eb b9                	jmp    800d4f <strtol+0x7f>

	if (endptr)
  800d96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9a:	74 0d                	je     800da9 <strtol+0xd9>
		*endptr = (char *) s;
  800d9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d9f:	89 0e                	mov    %ecx,(%esi)
  800da1:	eb 06                	jmp    800da9 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800da3:	85 db                	test   %ebx,%ebx
  800da5:	74 98                	je     800d3f <strtol+0x6f>
  800da7:	eb 9e                	jmp    800d47 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800da9:	89 c2                	mov    %eax,%edx
  800dab:	f7 da                	neg    %edx
  800dad:	85 ff                	test   %edi,%edi
  800daf:	0f 45 c2             	cmovne %edx,%eax
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	89 c7                	mov    %eax,%edi
  800dcb:	51                   	push   %ecx
  800dcc:	52                   	push   %edx
  800dcd:	53                   	push   %ebx
  800dce:	56                   	push   %esi
  800dcf:	57                   	push   %edi
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	8d 35 db 0d 80 00    	lea    0x800ddb,%esi
  800dd9:	0f 34                	sysenter 

00800ddb <label_21>:
  800ddb:	89 ec                	mov    %ebp,%esp
  800ddd:	5d                   	pop    %ebp
  800dde:	5f                   	pop    %edi
  800ddf:	5e                   	pop    %esi
  800de0:	5b                   	pop    %ebx
  800de1:	5a                   	pop    %edx
  800de2:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	89 ca                	mov    %ecx,%edx
  800df8:	89 cb                	mov    %ecx,%ebx
  800dfa:	89 cf                	mov    %ecx,%edi
  800dfc:	51                   	push   %ecx
  800dfd:	52                   	push   %edx
  800dfe:	53                   	push   %ebx
  800dff:	56                   	push   %esi
  800e00:	57                   	push   %edi
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	8d 35 0c 0e 80 00    	lea    0x800e0c,%esi
  800e0a:	0f 34                	sysenter 

00800e0c <label_55>:
  800e0c:	89 ec                	mov    %ebp,%esp
  800e0e:	5d                   	pop    %ebp
  800e0f:	5f                   	pop    %edi
  800e10:	5e                   	pop    %esi
  800e11:	5b                   	pop    %ebx
  800e12:	5a                   	pop    %edx
  800e13:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e14:	5b                   	pop    %ebx
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e22:	b8 03 00 00 00       	mov    $0x3,%eax
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	89 d9                	mov    %ebx,%ecx
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	51                   	push   %ecx
  800e2f:	52                   	push   %edx
  800e30:	53                   	push   %ebx
  800e31:	56                   	push   %esi
  800e32:	57                   	push   %edi
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	8d 35 3e 0e 80 00    	lea    0x800e3e,%esi
  800e3c:	0f 34                	sysenter 

00800e3e <label_90>:
  800e3e:	89 ec                	mov    %ebp,%esp
  800e40:	5d                   	pop    %ebp
  800e41:	5f                   	pop    %edi
  800e42:	5e                   	pop    %esi
  800e43:	5b                   	pop    %ebx
  800e44:	5a                   	pop    %edx
  800e45:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7e 17                	jle    800e61 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	50                   	push   %eax
  800e4e:	6a 03                	push   $0x3
  800e50:	68 04 18 80 00       	push   $0x801804
  800e55:	6a 29                	push   $0x29
  800e57:	68 21 18 80 00       	push   $0x801821
  800e5c:	e8 34 03 00 00       	call   801195 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e72:	b8 02 00 00 00       	mov    $0x2,%eax
  800e77:	89 ca                	mov    %ecx,%edx
  800e79:	89 cb                	mov    %ecx,%ebx
  800e7b:	89 cf                	mov    %ecx,%edi
  800e7d:	51                   	push   %ecx
  800e7e:	52                   	push   %edx
  800e7f:	53                   	push   %ebx
  800e80:	56                   	push   %esi
  800e81:	57                   	push   %edi
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	8d 35 8d 0e 80 00    	lea    0x800e8d,%esi
  800e8b:	0f 34                	sysenter 

00800e8d <label_139>:
  800e8d:	89 ec                	mov    %ebp,%esp
  800e8f:	5d                   	pop    %ebp
  800e90:	5f                   	pop    %edi
  800e91:	5e                   	pop    %esi
  800e92:	5b                   	pop    %ebx
  800e93:	5a                   	pop    %edx
  800e94:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e95:	5b                   	pop    %ebx
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800ea3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	89 fb                	mov    %edi,%ebx
  800eb0:	51                   	push   %ecx
  800eb1:	52                   	push   %edx
  800eb2:	53                   	push   %ebx
  800eb3:	56                   	push   %esi
  800eb4:	57                   	push   %edi
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	8d 35 c0 0e 80 00    	lea    0x800ec0,%esi
  800ebe:	0f 34                	sysenter 

00800ec0 <label_174>:
  800ec0:	89 ec                	mov    %ebp,%esp
  800ec2:	5d                   	pop    %ebp
  800ec3:	5f                   	pop    %edi
  800ec4:	5e                   	pop    %esi
  800ec5:	5b                   	pop    %ebx
  800ec6:	5a                   	pop    %edx
  800ec7:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ec8:	5b                   	pop    %ebx
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_yield>:

void
sys_yield(void)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	57                   	push   %edi
  800ed0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ed1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800edb:	89 d1                	mov    %edx,%ecx
  800edd:	89 d3                	mov    %edx,%ebx
  800edf:	89 d7                	mov    %edx,%edi
  800ee1:	51                   	push   %ecx
  800ee2:	52                   	push   %edx
  800ee3:	53                   	push   %ebx
  800ee4:	56                   	push   %esi
  800ee5:	57                   	push   %edi
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	8d 35 f1 0e 80 00    	lea    0x800ef1,%esi
  800eef:	0f 34                	sysenter 

00800ef1 <label_209>:
  800ef1:	89 ec                	mov    %ebp,%esp
  800ef3:	5d                   	pop    %ebp
  800ef4:	5f                   	pop    %edi
  800ef5:	5e                   	pop    %esi
  800ef6:	5b                   	pop    %ebx
  800ef7:	5a                   	pop    %edx
  800ef8:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ef9:	5b                   	pop    %ebx
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f02:	bf 00 00 00 00       	mov    $0x0,%edi
  800f07:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f15:	51                   	push   %ecx
  800f16:	52                   	push   %edx
  800f17:	53                   	push   %ebx
  800f18:	56                   	push   %esi
  800f19:	57                   	push   %edi
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	8d 35 25 0f 80 00    	lea    0x800f25,%esi
  800f23:	0f 34                	sysenter 

00800f25 <label_244>:
  800f25:	89 ec                	mov    %ebp,%esp
  800f27:	5d                   	pop    %ebp
  800f28:	5f                   	pop    %edi
  800f29:	5e                   	pop    %esi
  800f2a:	5b                   	pop    %ebx
  800f2b:	5a                   	pop    %edx
  800f2c:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	7e 17                	jle    800f48 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f31:	83 ec 0c             	sub    $0xc,%esp
  800f34:	50                   	push   %eax
  800f35:	6a 05                	push   $0x5
  800f37:	68 04 18 80 00       	push   $0x801804
  800f3c:	6a 29                	push   $0x29
  800f3e:	68 21 18 80 00       	push   $0x801821
  800f43:	e8 4d 02 00 00       	call   801195 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800f57:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800f63:	8b 45 10             	mov    0x10(%ebp),%eax
  800f66:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800f69:	8b 45 14             	mov    0x14(%ebp),%eax
  800f6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800f6f:	8b 45 18             	mov    0x18(%ebp),%eax
  800f72:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f75:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f82:	89 cb                	mov    %ecx,%ebx
  800f84:	89 cf                	mov    %ecx,%edi
  800f86:	51                   	push   %ecx
  800f87:	52                   	push   %edx
  800f88:	53                   	push   %ebx
  800f89:	56                   	push   %esi
  800f8a:	57                   	push   %edi
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	8d 35 96 0f 80 00    	lea    0x800f96,%esi
  800f94:	0f 34                	sysenter 

00800f96 <label_304>:
  800f96:	89 ec                	mov    %ebp,%esp
  800f98:	5d                   	pop    %ebp
  800f99:	5f                   	pop    %edi
  800f9a:	5e                   	pop    %esi
  800f9b:	5b                   	pop    %ebx
  800f9c:	5a                   	pop    %edx
  800f9d:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	7e 17                	jle    800fb9 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	50                   	push   %eax
  800fa6:	6a 06                	push   $0x6
  800fa8:	68 04 18 80 00       	push   $0x801804
  800fad:	6a 29                	push   $0x29
  800faf:	68 21 18 80 00       	push   $0x801821
  800fb4:	e8 dc 01 00 00       	call   801195 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  800fb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc5:	bf 00 00 00 00       	mov    $0x0,%edi
  800fca:	b8 07 00 00 00       	mov    $0x7,%eax
  800fcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd5:	89 fb                	mov    %edi,%ebx
  800fd7:	51                   	push   %ecx
  800fd8:	52                   	push   %edx
  800fd9:	53                   	push   %ebx
  800fda:	56                   	push   %esi
  800fdb:	57                   	push   %edi
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	8d 35 e7 0f 80 00    	lea    0x800fe7,%esi
  800fe5:	0f 34                	sysenter 

00800fe7 <label_353>:
  800fe7:	89 ec                	mov    %ebp,%esp
  800fe9:	5d                   	pop    %ebp
  800fea:	5f                   	pop    %edi
  800feb:	5e                   	pop    %esi
  800fec:	5b                   	pop    %ebx
  800fed:	5a                   	pop    %edx
  800fee:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	7e 17                	jle    80100a <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	50                   	push   %eax
  800ff7:	6a 07                	push   $0x7
  800ff9:	68 04 18 80 00       	push   $0x801804
  800ffe:	6a 29                	push   $0x29
  801000:	68 21 18 80 00       	push   $0x801821
  801005:	e8 8b 01 00 00       	call   801195 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80100a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	57                   	push   %edi
  801015:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801016:	bf 00 00 00 00       	mov    $0x0,%edi
  80101b:	b8 09 00 00 00       	mov    $0x9,%eax
  801020:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801023:	8b 55 08             	mov    0x8(%ebp),%edx
  801026:	89 fb                	mov    %edi,%ebx
  801028:	51                   	push   %ecx
  801029:	52                   	push   %edx
  80102a:	53                   	push   %ebx
  80102b:	56                   	push   %esi
  80102c:	57                   	push   %edi
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	8d 35 38 10 80 00    	lea    0x801038,%esi
  801036:	0f 34                	sysenter 

00801038 <label_402>:
  801038:	89 ec                	mov    %ebp,%esp
  80103a:	5d                   	pop    %ebp
  80103b:	5f                   	pop    %edi
  80103c:	5e                   	pop    %esi
  80103d:	5b                   	pop    %ebx
  80103e:	5a                   	pop    %edx
  80103f:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801040:	85 c0                	test   %eax,%eax
  801042:	7e 17                	jle    80105b <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	50                   	push   %eax
  801048:	6a 09                	push   $0x9
  80104a:	68 04 18 80 00       	push   $0x801804
  80104f:	6a 29                	push   $0x29
  801051:	68 21 18 80 00       	push   $0x801821
  801056:	e8 3a 01 00 00       	call   801195 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80105b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5f                   	pop    %edi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	57                   	push   %edi
  801066:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801067:	bf 00 00 00 00       	mov    $0x0,%edi
  80106c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801071:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801074:	8b 55 08             	mov    0x8(%ebp),%edx
  801077:	89 fb                	mov    %edi,%ebx
  801079:	51                   	push   %ecx
  80107a:	52                   	push   %edx
  80107b:	53                   	push   %ebx
  80107c:	56                   	push   %esi
  80107d:	57                   	push   %edi
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	8d 35 89 10 80 00    	lea    0x801089,%esi
  801087:	0f 34                	sysenter 

00801089 <label_451>:
  801089:	89 ec                	mov    %ebp,%esp
  80108b:	5d                   	pop    %ebp
  80108c:	5f                   	pop    %edi
  80108d:	5e                   	pop    %esi
  80108e:	5b                   	pop    %ebx
  80108f:	5a                   	pop    %edx
  801090:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801091:	85 c0                	test   %eax,%eax
  801093:	7e 17                	jle    8010ac <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	50                   	push   %eax
  801099:	6a 0a                	push   $0xa
  80109b:	68 04 18 80 00       	push   $0x801804
  8010a0:	6a 29                	push   $0x29
  8010a2:	68 21 18 80 00       	push   $0x801821
  8010a7:	e8 e9 00 00 00       	call   801195 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010b8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010c9:	51                   	push   %ecx
  8010ca:	52                   	push   %edx
  8010cb:	53                   	push   %ebx
  8010cc:	56                   	push   %esi
  8010cd:	57                   	push   %edi
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	8d 35 d9 10 80 00    	lea    0x8010d9,%esi
  8010d7:	0f 34                	sysenter 

008010d9 <label_502>:
  8010d9:	89 ec                	mov    %ebp,%esp
  8010db:	5d                   	pop    %ebp
  8010dc:	5f                   	pop    %edi
  8010dd:	5e                   	pop    %esi
  8010de:	5b                   	pop    %ebx
  8010df:	5a                   	pop    %edx
  8010e0:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010e1:	5b                   	pop    %ebx
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ef:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f7:	89 d9                	mov    %ebx,%ecx
  8010f9:	89 df                	mov    %ebx,%edi
  8010fb:	51                   	push   %ecx
  8010fc:	52                   	push   %edx
  8010fd:	53                   	push   %ebx
  8010fe:	56                   	push   %esi
  8010ff:	57                   	push   %edi
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	8d 35 0b 11 80 00    	lea    0x80110b,%esi
  801109:	0f 34                	sysenter 

0080110b <label_537>:
  80110b:	89 ec                	mov    %ebp,%esp
  80110d:	5d                   	pop    %ebp
  80110e:	5f                   	pop    %edi
  80110f:	5e                   	pop    %esi
  801110:	5b                   	pop    %ebx
  801111:	5a                   	pop    %edx
  801112:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 04 18 80 00       	push   $0x801804
  801122:	6a 29                	push   $0x29
  801124:	68 21 18 80 00       	push   $0x801821
  801129:	e8 67 00 00 00       	call   801195 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80113f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	89 cb                	mov    %ecx,%ebx
  801149:	89 cf                	mov    %ecx,%edi
  80114b:	51                   	push   %ecx
  80114c:	52                   	push   %edx
  80114d:	53                   	push   %ebx
  80114e:	56                   	push   %esi
  80114f:	57                   	push   %edi
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	8d 35 5b 11 80 00    	lea    0x80115b,%esi
  801159:	0f 34                	sysenter 

0080115b <label_586>:
  80115b:	89 ec                	mov    %ebp,%esp
  80115d:	5d                   	pop    %ebp
  80115e:	5f                   	pop    %edi
  80115f:	5e                   	pop    %esi
  801160:	5b                   	pop    %ebx
  801161:	5a                   	pop    %edx
  801162:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801163:	5b                   	pop    %ebx
  801164:	5f                   	pop    %edi
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80116d:	68 3b 18 80 00       	push   $0x80183b
  801172:	6a 52                	push   $0x52
  801174:	68 2f 18 80 00       	push   $0x80182f
  801179:	e8 17 00 00 00       	call   801195 <_panic>

0080117e <sfork>:
}

// Challenge!
int
sfork(void)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801184:	68 3a 18 80 00       	push   $0x80183a
  801189:	6a 59                	push   $0x59
  80118b:	68 2f 18 80 00       	push   $0x80182f
  801190:	e8 00 00 00 00       	call   801195 <_panic>

00801195 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	56                   	push   %esi
  801199:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80119a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80119d:	a1 10 20 80 00       	mov    0x802010,%eax
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	74 11                	je     8011b7 <_panic+0x22>
		cprintf("%s: ", argv0);
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	50                   	push   %eax
  8011aa:	68 50 18 80 00       	push   $0x801850
  8011af:	e8 ec ef ff ff       	call   8001a0 <cprintf>
  8011b4:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011b7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011bd:	e8 a6 fc ff ff       	call   800e68 <sys_getenvid>
  8011c2:	83 ec 0c             	sub    $0xc,%esp
  8011c5:	ff 75 0c             	pushl  0xc(%ebp)
  8011c8:	ff 75 08             	pushl  0x8(%ebp)
  8011cb:	56                   	push   %esi
  8011cc:	50                   	push   %eax
  8011cd:	68 58 18 80 00       	push   $0x801858
  8011d2:	e8 c9 ef ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011d7:	83 c4 18             	add    $0x18,%esp
  8011da:	53                   	push   %ebx
  8011db:	ff 75 10             	pushl  0x10(%ebp)
  8011de:	e8 6c ef ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  8011e3:	c7 04 24 34 15 80 00 	movl   $0x801534,(%esp)
  8011ea:	e8 b1 ef ff ff       	call   8001a0 <cprintf>
  8011ef:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011f2:	cc                   	int3   
  8011f3:	eb fd                	jmp    8011f2 <_panic+0x5d>
  8011f5:	66 90                	xchg   %ax,%ax
  8011f7:	66 90                	xchg   %ax,%ax
  8011f9:	66 90                	xchg   %ax,%ax
  8011fb:	66 90                	xchg   %ax,%ax
  8011fd:	66 90                	xchg   %ax,%ax
  8011ff:	90                   	nop

00801200 <__udivdi3>:
  801200:	55                   	push   %ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 1c             	sub    $0x1c,%esp
  801207:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80120b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80120f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801217:	85 f6                	test   %esi,%esi
  801219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80121d:	89 ca                	mov    %ecx,%edx
  80121f:	89 f8                	mov    %edi,%eax
  801221:	75 3d                	jne    801260 <__udivdi3+0x60>
  801223:	39 cf                	cmp    %ecx,%edi
  801225:	0f 87 c5 00 00 00    	ja     8012f0 <__udivdi3+0xf0>
  80122b:	85 ff                	test   %edi,%edi
  80122d:	89 fd                	mov    %edi,%ebp
  80122f:	75 0b                	jne    80123c <__udivdi3+0x3c>
  801231:	b8 01 00 00 00       	mov    $0x1,%eax
  801236:	31 d2                	xor    %edx,%edx
  801238:	f7 f7                	div    %edi
  80123a:	89 c5                	mov    %eax,%ebp
  80123c:	89 c8                	mov    %ecx,%eax
  80123e:	31 d2                	xor    %edx,%edx
  801240:	f7 f5                	div    %ebp
  801242:	89 c1                	mov    %eax,%ecx
  801244:	89 d8                	mov    %ebx,%eax
  801246:	89 cf                	mov    %ecx,%edi
  801248:	f7 f5                	div    %ebp
  80124a:	89 c3                	mov    %eax,%ebx
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
  801260:	39 ce                	cmp    %ecx,%esi
  801262:	77 74                	ja     8012d8 <__udivdi3+0xd8>
  801264:	0f bd fe             	bsr    %esi,%edi
  801267:	83 f7 1f             	xor    $0x1f,%edi
  80126a:	0f 84 98 00 00 00    	je     801308 <__udivdi3+0x108>
  801270:	bb 20 00 00 00       	mov    $0x20,%ebx
  801275:	89 f9                	mov    %edi,%ecx
  801277:	89 c5                	mov    %eax,%ebp
  801279:	29 fb                	sub    %edi,%ebx
  80127b:	d3 e6                	shl    %cl,%esi
  80127d:	89 d9                	mov    %ebx,%ecx
  80127f:	d3 ed                	shr    %cl,%ebp
  801281:	89 f9                	mov    %edi,%ecx
  801283:	d3 e0                	shl    %cl,%eax
  801285:	09 ee                	or     %ebp,%esi
  801287:	89 d9                	mov    %ebx,%ecx
  801289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128d:	89 d5                	mov    %edx,%ebp
  80128f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801293:	d3 ed                	shr    %cl,%ebp
  801295:	89 f9                	mov    %edi,%ecx
  801297:	d3 e2                	shl    %cl,%edx
  801299:	89 d9                	mov    %ebx,%ecx
  80129b:	d3 e8                	shr    %cl,%eax
  80129d:	09 c2                	or     %eax,%edx
  80129f:	89 d0                	mov    %edx,%eax
  8012a1:	89 ea                	mov    %ebp,%edx
  8012a3:	f7 f6                	div    %esi
  8012a5:	89 d5                	mov    %edx,%ebp
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	f7 64 24 0c          	mull   0xc(%esp)
  8012ad:	39 d5                	cmp    %edx,%ebp
  8012af:	72 10                	jb     8012c1 <__udivdi3+0xc1>
  8012b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012b5:	89 f9                	mov    %edi,%ecx
  8012b7:	d3 e6                	shl    %cl,%esi
  8012b9:	39 c6                	cmp    %eax,%esi
  8012bb:	73 07                	jae    8012c4 <__udivdi3+0xc4>
  8012bd:	39 d5                	cmp    %edx,%ebp
  8012bf:	75 03                	jne    8012c4 <__udivdi3+0xc4>
  8012c1:	83 eb 01             	sub    $0x1,%ebx
  8012c4:	31 ff                	xor    %edi,%edi
  8012c6:	89 d8                	mov    %ebx,%eax
  8012c8:	89 fa                	mov    %edi,%edx
  8012ca:	83 c4 1c             	add    $0x1c,%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    
  8012d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d8:	31 ff                	xor    %edi,%edi
  8012da:	31 db                	xor    %ebx,%ebx
  8012dc:	89 d8                	mov    %ebx,%eax
  8012de:	89 fa                	mov    %edi,%edx
  8012e0:	83 c4 1c             	add    $0x1c,%esp
  8012e3:	5b                   	pop    %ebx
  8012e4:	5e                   	pop    %esi
  8012e5:	5f                   	pop    %edi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    
  8012e8:	90                   	nop
  8012e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	89 d8                	mov    %ebx,%eax
  8012f2:	f7 f7                	div    %edi
  8012f4:	31 ff                	xor    %edi,%edi
  8012f6:	89 c3                	mov    %eax,%ebx
  8012f8:	89 d8                	mov    %ebx,%eax
  8012fa:	89 fa                	mov    %edi,%edx
  8012fc:	83 c4 1c             	add    $0x1c,%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	39 ce                	cmp    %ecx,%esi
  80130a:	72 0c                	jb     801318 <__udivdi3+0x118>
  80130c:	31 db                	xor    %ebx,%ebx
  80130e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801312:	0f 87 34 ff ff ff    	ja     80124c <__udivdi3+0x4c>
  801318:	bb 01 00 00 00       	mov    $0x1,%ebx
  80131d:	e9 2a ff ff ff       	jmp    80124c <__udivdi3+0x4c>
  801322:	66 90                	xchg   %ax,%ax
  801324:	66 90                	xchg   %ax,%ax
  801326:	66 90                	xchg   %ax,%ax
  801328:	66 90                	xchg   %ax,%ax
  80132a:	66 90                	xchg   %ax,%ax
  80132c:	66 90                	xchg   %ax,%ax
  80132e:	66 90                	xchg   %ax,%ax

00801330 <__umoddi3>:
  801330:	55                   	push   %ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 1c             	sub    $0x1c,%esp
  801337:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80133b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80133f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801347:	85 d2                	test   %edx,%edx
  801349:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80134d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801351:	89 f3                	mov    %esi,%ebx
  801353:	89 3c 24             	mov    %edi,(%esp)
  801356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80135a:	75 1c                	jne    801378 <__umoddi3+0x48>
  80135c:	39 f7                	cmp    %esi,%edi
  80135e:	76 50                	jbe    8013b0 <__umoddi3+0x80>
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 f2                	mov    %esi,%edx
  801364:	f7 f7                	div    %edi
  801366:	89 d0                	mov    %edx,%eax
  801368:	31 d2                	xor    %edx,%edx
  80136a:	83 c4 1c             	add    $0x1c,%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5f                   	pop    %edi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	39 f2                	cmp    %esi,%edx
  80137a:	89 d0                	mov    %edx,%eax
  80137c:	77 52                	ja     8013d0 <__umoddi3+0xa0>
  80137e:	0f bd ea             	bsr    %edx,%ebp
  801381:	83 f5 1f             	xor    $0x1f,%ebp
  801384:	75 5a                	jne    8013e0 <__umoddi3+0xb0>
  801386:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80138a:	0f 82 e0 00 00 00    	jb     801470 <__umoddi3+0x140>
  801390:	39 0c 24             	cmp    %ecx,(%esp)
  801393:	0f 86 d7 00 00 00    	jbe    801470 <__umoddi3+0x140>
  801399:	8b 44 24 08          	mov    0x8(%esp),%eax
  80139d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013a1:	83 c4 1c             	add    $0x1c,%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    
  8013a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	85 ff                	test   %edi,%edi
  8013b2:	89 fd                	mov    %edi,%ebp
  8013b4:	75 0b                	jne    8013c1 <__umoddi3+0x91>
  8013b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	f7 f7                	div    %edi
  8013bf:	89 c5                	mov    %eax,%ebp
  8013c1:	89 f0                	mov    %esi,%eax
  8013c3:	31 d2                	xor    %edx,%edx
  8013c5:	f7 f5                	div    %ebp
  8013c7:	89 c8                	mov    %ecx,%eax
  8013c9:	f7 f5                	div    %ebp
  8013cb:	89 d0                	mov    %edx,%eax
  8013cd:	eb 99                	jmp    801368 <__umoddi3+0x38>
  8013cf:	90                   	nop
  8013d0:	89 c8                	mov    %ecx,%eax
  8013d2:	89 f2                	mov    %esi,%edx
  8013d4:	83 c4 1c             	add    $0x1c,%esp
  8013d7:	5b                   	pop    %ebx
  8013d8:	5e                   	pop    %esi
  8013d9:	5f                   	pop    %edi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    
  8013dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	8b 34 24             	mov    (%esp),%esi
  8013e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013e8:	89 e9                	mov    %ebp,%ecx
  8013ea:	29 ef                	sub    %ebp,%edi
  8013ec:	d3 e0                	shl    %cl,%eax
  8013ee:	89 f9                	mov    %edi,%ecx
  8013f0:	89 f2                	mov    %esi,%edx
  8013f2:	d3 ea                	shr    %cl,%edx
  8013f4:	89 e9                	mov    %ebp,%ecx
  8013f6:	09 c2                	or     %eax,%edx
  8013f8:	89 d8                	mov    %ebx,%eax
  8013fa:	89 14 24             	mov    %edx,(%esp)
  8013fd:	89 f2                	mov    %esi,%edx
  8013ff:	d3 e2                	shl    %cl,%edx
  801401:	89 f9                	mov    %edi,%ecx
  801403:	89 54 24 04          	mov    %edx,0x4(%esp)
  801407:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80140b:	d3 e8                	shr    %cl,%eax
  80140d:	89 e9                	mov    %ebp,%ecx
  80140f:	89 c6                	mov    %eax,%esi
  801411:	d3 e3                	shl    %cl,%ebx
  801413:	89 f9                	mov    %edi,%ecx
  801415:	89 d0                	mov    %edx,%eax
  801417:	d3 e8                	shr    %cl,%eax
  801419:	89 e9                	mov    %ebp,%ecx
  80141b:	09 d8                	or     %ebx,%eax
  80141d:	89 d3                	mov    %edx,%ebx
  80141f:	89 f2                	mov    %esi,%edx
  801421:	f7 34 24             	divl   (%esp)
  801424:	89 d6                	mov    %edx,%esi
  801426:	d3 e3                	shl    %cl,%ebx
  801428:	f7 64 24 04          	mull   0x4(%esp)
  80142c:	39 d6                	cmp    %edx,%esi
  80142e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801432:	89 d1                	mov    %edx,%ecx
  801434:	89 c3                	mov    %eax,%ebx
  801436:	72 08                	jb     801440 <__umoddi3+0x110>
  801438:	75 11                	jne    80144b <__umoddi3+0x11b>
  80143a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80143e:	73 0b                	jae    80144b <__umoddi3+0x11b>
  801440:	2b 44 24 04          	sub    0x4(%esp),%eax
  801444:	1b 14 24             	sbb    (%esp),%edx
  801447:	89 d1                	mov    %edx,%ecx
  801449:	89 c3                	mov    %eax,%ebx
  80144b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80144f:	29 da                	sub    %ebx,%edx
  801451:	19 ce                	sbb    %ecx,%esi
  801453:	89 f9                	mov    %edi,%ecx
  801455:	89 f0                	mov    %esi,%eax
  801457:	d3 e0                	shl    %cl,%eax
  801459:	89 e9                	mov    %ebp,%ecx
  80145b:	d3 ea                	shr    %cl,%edx
  80145d:	89 e9                	mov    %ebp,%ecx
  80145f:	d3 ee                	shr    %cl,%esi
  801461:	09 d0                	or     %edx,%eax
  801463:	89 f2                	mov    %esi,%edx
  801465:	83 c4 1c             	add    $0x1c,%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5f                   	pop    %edi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    
  80146d:	8d 76 00             	lea    0x0(%esi),%esi
  801470:	29 f9                	sub    %edi,%ecx
  801472:	19 d6                	sbb    %edx,%esi
  801474:	89 74 24 04          	mov    %esi,0x4(%esp)
  801478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80147c:	e9 18 ff ff ff       	jmp    801399 <__umoddi3+0x69>
