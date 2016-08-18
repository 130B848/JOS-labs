
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 14 0e 00 00       	call   800e54 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 0c 20 80 00 80 	cmpl   $0xeec00080,0x80200c
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 f5 10 00 00       	call   801153 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 14 80 00       	push   $0x8014c0
  80006a:	e8 1d 01 00 00       	call   80018c <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 d1 14 80 00       	push   $0x8014d1
  800083:	e8 04 01 00 00       	call   80018c <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 ce 10 00 00       	call   80116a <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ac:	e8 a3 0d 00 00       	call   800e54 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	c1 e0 07             	shl    $0x7,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 10 0d 00 00       	call   800e04 <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	75 1a                	jne    800132 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	68 ff 00 00 00       	push   $0xff
  800120:	8d 43 08             	lea    0x8(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	e8 7a 0c 00 00       	call   800da3 <sys_cputs>
		b->idx = 0;
  800129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	68 f9 00 80 00       	push   $0x8000f9
  80016a:	e8 c0 02 00 00       	call   80042f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 1f 0c 00 00       	call   800da3 <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 9d ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 1c             	sub    $0x1c,%esp
  8001a9:	89 c7                	mov    %eax,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  8001bc:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001c0:	0f 85 bf 00 00 00    	jne    800285 <printnum+0xe5>
  8001c6:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8001cc:	0f 8d de 00 00 00    	jge    8002b0 <printnum+0x110>
		judge_time_for_space = width;
  8001d2:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8001d8:	e9 d3 00 00 00       	jmp    8002b0 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f 37                	jg     80021b <printnum+0x7b>
  8001e4:	e9 ea 00 00 00       	jmp    8002d3 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8001e9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001ec:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	56                   	push   %esi
  8001f5:	83 ec 04             	sub    $0x4,%esp
  8001f8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800201:	ff 75 e0             	pushl  -0x20(%ebp)
  800204:	e8 57 11 00 00       	call   801360 <__umoddi3>
  800209:	83 c4 14             	add    $0x14,%esp
  80020c:	0f be 80 f2 14 80 00 	movsbl 0x8014f2(%eax),%eax
  800213:	50                   	push   %eax
  800214:	ff d7                	call   *%edi
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	eb 16                	jmp    800231 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	83 eb 01             	sub    $0x1,%ebx
  80022a:	75 ef                	jne    80021b <printnum+0x7b>
  80022c:	e9 a2 00 00 00       	jmp    8002d3 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800231:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800237:	0f 85 76 01 00 00    	jne    8003b3 <printnum+0x213>
		while(num_of_space-- > 0)
  80023d:	a1 04 20 80 00       	mov    0x802004,%eax
  800242:	8d 50 ff             	lea    -0x1(%eax),%edx
  800245:	89 15 04 20 80 00    	mov    %edx,0x802004
  80024b:	85 c0                	test   %eax,%eax
  80024d:	7e 1d                	jle    80026c <printnum+0xcc>
			putch(' ', putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	6a 20                	push   $0x20
  800255:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800257:	a1 04 20 80 00       	mov    0x802004,%eax
  80025c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80025f:	89 15 04 20 80 00    	mov    %edx,0x802004
  800265:	83 c4 10             	add    $0x10,%esp
  800268:	85 c0                	test   %eax,%eax
  80026a:	7f e3                	jg     80024f <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  80026c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800273:	00 00 00 
		judge_time_for_space = 0;
  800276:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80027d:	00 00 00 
	}
}
  800280:	e9 2e 01 00 00       	jmp    8003b3 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800285:	8b 45 10             	mov    0x10(%ebp),%eax
  800288:	ba 00 00 00 00       	mov    $0x0,%edx
  80028d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800290:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800293:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800296:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800299:	83 fa 00             	cmp    $0x0,%edx
  80029c:	0f 87 ba 00 00 00    	ja     80035c <printnum+0x1bc>
  8002a2:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002a5:	0f 83 b1 00 00 00    	jae    80035c <printnum+0x1bc>
  8002ab:	e9 2d ff ff ff       	jmp    8001dd <printnum+0x3d>
  8002b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002c4:	83 fa 00             	cmp    $0x0,%edx
  8002c7:	77 37                	ja     800300 <printnum+0x160>
  8002c9:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002cc:	73 32                	jae    800300 <printnum+0x160>
  8002ce:	e9 16 ff ff ff       	jmp    8001e9 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d3:	83 ec 08             	sub    $0x8,%esp
  8002d6:	56                   	push   %esi
  8002d7:	83 ec 04             	sub    $0x4,%esp
  8002da:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e6:	e8 75 10 00 00       	call   801360 <__umoddi3>
  8002eb:	83 c4 14             	add    $0x14,%esp
  8002ee:	0f be 80 f2 14 80 00 	movsbl 0x8014f2(%eax),%eax
  8002f5:	50                   	push   %eax
  8002f6:	ff d7                	call   *%edi
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	e9 b3 00 00 00       	jmp    8003b3 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800309:	50                   	push   %eax
  80030a:	ff 75 10             	pushl  0x10(%ebp)
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	ff 75 dc             	pushl  -0x24(%ebp)
  800313:	ff 75 d8             	pushl  -0x28(%ebp)
  800316:	ff 75 e4             	pushl  -0x1c(%ebp)
  800319:	ff 75 e0             	pushl  -0x20(%ebp)
  80031c:	e8 0f 0f 00 00       	call   801230 <__udivdi3>
  800321:	83 c4 18             	add    $0x18,%esp
  800324:	52                   	push   %edx
  800325:	50                   	push   %eax
  800326:	89 f2                	mov    %esi,%edx
  800328:	89 f8                	mov    %edi,%eax
  80032a:	e8 71 fe ff ff       	call   8001a0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032f:	83 c4 18             	add    $0x18,%esp
  800332:	56                   	push   %esi
  800333:	83 ec 04             	sub    $0x4,%esp
  800336:	ff 75 dc             	pushl  -0x24(%ebp)
  800339:	ff 75 d8             	pushl  -0x28(%ebp)
  80033c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80033f:	ff 75 e0             	pushl  -0x20(%ebp)
  800342:	e8 19 10 00 00       	call   801360 <__umoddi3>
  800347:	83 c4 14             	add    $0x14,%esp
  80034a:	0f be 80 f2 14 80 00 	movsbl 0x8014f2(%eax),%eax
  800351:	50                   	push   %eax
  800352:	ff d7                	call   *%edi
  800354:	83 c4 10             	add    $0x10,%esp
  800357:	e9 d5 fe ff ff       	jmp    800231 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035c:	83 ec 0c             	sub    $0xc,%esp
  80035f:	ff 75 18             	pushl  0x18(%ebp)
  800362:	83 eb 01             	sub    $0x1,%ebx
  800365:	53                   	push   %ebx
  800366:	ff 75 10             	pushl  0x10(%ebp)
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	ff 75 e4             	pushl  -0x1c(%ebp)
  800375:	ff 75 e0             	pushl  -0x20(%ebp)
  800378:	e8 b3 0e 00 00       	call   801230 <__udivdi3>
  80037d:	83 c4 18             	add    $0x18,%esp
  800380:	52                   	push   %edx
  800381:	50                   	push   %eax
  800382:	89 f2                	mov    %esi,%edx
  800384:	89 f8                	mov    %edi,%eax
  800386:	e8 15 fe ff ff       	call   8001a0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038b:	83 c4 18             	add    $0x18,%esp
  80038e:	56                   	push   %esi
  80038f:	83 ec 04             	sub    $0x4,%esp
  800392:	ff 75 dc             	pushl  -0x24(%ebp)
  800395:	ff 75 d8             	pushl  -0x28(%ebp)
  800398:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039b:	ff 75 e0             	pushl  -0x20(%ebp)
  80039e:	e8 bd 0f 00 00       	call   801360 <__umoddi3>
  8003a3:	83 c4 14             	add    $0x14,%esp
  8003a6:	0f be 80 f2 14 80 00 	movsbl 0x8014f2(%eax),%eax
  8003ad:	50                   	push   %eax
  8003ae:	ff d7                	call   *%edi
  8003b0:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8003b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003be:	83 fa 01             	cmp    $0x1,%edx
  8003c1:	7e 0e                	jle    8003d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c3:	8b 10                	mov    (%eax),%edx
  8003c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 02                	mov    (%edx),%eax
  8003cc:	8b 52 04             	mov    0x4(%edx),%edx
  8003cf:	eb 22                	jmp    8003f3 <getuint+0x38>
	else if (lflag)
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	74 10                	je     8003e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d5:	8b 10                	mov    (%eax),%edx
  8003d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003da:	89 08                	mov    %ecx,(%eax)
  8003dc:	8b 02                	mov    (%edx),%eax
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e3:	eb 0e                	jmp    8003f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e5:	8b 10                	mov    (%eax),%edx
  8003e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ea:	89 08                	mov    %ecx,(%eax)
  8003ec:	8b 02                	mov    (%edx),%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ff:	8b 10                	mov    (%eax),%edx
  800401:	3b 50 04             	cmp    0x4(%eax),%edx
  800404:	73 0a                	jae    800410 <sprintputch+0x1b>
		*b->buf++ = ch;
  800406:	8d 4a 01             	lea    0x1(%edx),%ecx
  800409:	89 08                	mov    %ecx,(%eax)
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	88 02                	mov    %al,(%edx)
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800418:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041b:	50                   	push   %eax
  80041c:	ff 75 10             	pushl  0x10(%ebp)
  80041f:	ff 75 0c             	pushl  0xc(%ebp)
  800422:	ff 75 08             	pushl  0x8(%ebp)
  800425:	e8 05 00 00 00       	call   80042f <vprintfmt>
	va_end(ap);
}
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	c9                   	leave  
  80042e:	c3                   	ret    

0080042f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	57                   	push   %edi
  800433:	56                   	push   %esi
  800434:	53                   	push   %ebx
  800435:	83 ec 2c             	sub    $0x2c,%esp
  800438:	8b 7d 08             	mov    0x8(%ebp),%edi
  80043b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043e:	eb 03                	jmp    800443 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800440:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800443:	8b 45 10             	mov    0x10(%ebp),%eax
  800446:	8d 70 01             	lea    0x1(%eax),%esi
  800449:	0f b6 00             	movzbl (%eax),%eax
  80044c:	83 f8 25             	cmp    $0x25,%eax
  80044f:	74 27                	je     800478 <vprintfmt+0x49>
			if (ch == '\0')
  800451:	85 c0                	test   %eax,%eax
  800453:	75 0d                	jne    800462 <vprintfmt+0x33>
  800455:	e9 9d 04 00 00       	jmp    8008f7 <vprintfmt+0x4c8>
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 95 04 00 00    	je     8008f7 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800469:	83 c6 01             	add    $0x1,%esi
  80046c:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800478:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047d:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800481:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800488:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800496:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80049d:	eb 08                	jmp    8004a7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8004a2:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8d 46 01             	lea    0x1(%esi),%eax
  8004aa:	89 45 10             	mov    %eax,0x10(%ebp)
  8004ad:	0f b6 06             	movzbl (%esi),%eax
  8004b0:	0f b6 d0             	movzbl %al,%edx
  8004b3:	83 e8 23             	sub    $0x23,%eax
  8004b6:	3c 55                	cmp    $0x55,%al
  8004b8:	0f 87 fa 03 00 00    	ja     8008b8 <vprintfmt+0x489>
  8004be:	0f b6 c0             	movzbl %al,%eax
  8004c1:	ff 24 85 40 16 80 00 	jmp    *0x801640(,%eax,4)
  8004c8:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8004cb:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8004cf:	eb d6                	jmp    8004a7 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8004d7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004db:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004de:	83 fa 09             	cmp    $0x9,%edx
  8004e1:	77 6b                	ja     80054e <vprintfmt+0x11f>
  8004e3:	8b 75 10             	mov    0x10(%ebp),%esi
  8004e6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004e9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004ec:	eb 09                	jmp    8004f7 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f1:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8004f5:	eb b0                	jmp    8004a7 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004fa:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004fd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800501:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800504:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800507:	83 f9 09             	cmp    $0x9,%ecx
  80050a:	76 eb                	jbe    8004f7 <vprintfmt+0xc8>
  80050c:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80050f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800512:	eb 3d                	jmp    800551 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 50 04             	lea    0x4(%eax),%edx
  80051a:	89 55 14             	mov    %edx,0x14(%ebp)
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800525:	eb 2a                	jmp    800551 <vprintfmt+0x122>
  800527:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052a:	85 c0                	test   %eax,%eax
  80052c:	ba 00 00 00 00       	mov    $0x0,%edx
  800531:	0f 49 d0             	cmovns %eax,%edx
  800534:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 75 10             	mov    0x10(%ebp),%esi
  80053a:	e9 68 ff ff ff       	jmp    8004a7 <vprintfmt+0x78>
  80053f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800542:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800549:	e9 59 ff ff ff       	jmp    8004a7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800551:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800555:	0f 89 4c ff ff ff    	jns    8004a7 <vprintfmt+0x78>
				width = precision, precision = -1;
  80055b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80055e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800561:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800568:	e9 3a ff ff ff       	jmp    8004a7 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056d:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800574:	e9 2e ff ff ff       	jmp    8004a7 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	53                   	push   %ebx
  800586:	ff 30                	pushl  (%eax)
  800588:	ff d7                	call   *%edi
			break;
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	e9 b1 fe ff ff       	jmp    800443 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	99                   	cltd   
  80059e:	31 d0                	xor    %edx,%eax
  8005a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a2:	83 f8 08             	cmp    $0x8,%eax
  8005a5:	7f 0b                	jg     8005b2 <vprintfmt+0x183>
  8005a7:	8b 14 85 a0 17 80 00 	mov    0x8017a0(,%eax,4),%edx
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	75 15                	jne    8005c7 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8005b2:	50                   	push   %eax
  8005b3:	68 0a 15 80 00       	push   $0x80150a
  8005b8:	53                   	push   %ebx
  8005b9:	57                   	push   %edi
  8005ba:	e8 53 fe ff ff       	call   800412 <printfmt>
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	e9 7c fe ff ff       	jmp    800443 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005c7:	52                   	push   %edx
  8005c8:	68 13 15 80 00       	push   $0x801513
  8005cd:	53                   	push   %ebx
  8005ce:	57                   	push   %edi
  8005cf:	e8 3e fe ff ff       	call   800412 <printfmt>
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	e9 67 fe ff ff       	jmp    800443 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	b9 03 15 80 00       	mov    $0x801503,%ecx
  8005ee:	0f 45 c8             	cmovne %eax,%ecx
  8005f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f8:	7e 06                	jle    800600 <vprintfmt+0x1d1>
  8005fa:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8005fe:	75 19                	jne    800619 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800600:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800603:	8d 70 01             	lea    0x1(%eax),%esi
  800606:	0f b6 00             	movzbl (%eax),%eax
  800609:	0f be d0             	movsbl %al,%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	0f 85 9f 00 00 00    	jne    8006b3 <vprintfmt+0x284>
  800614:	e9 8c 00 00 00       	jmp    8006a5 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	ff 75 d0             	pushl  -0x30(%ebp)
  80061f:	ff 75 cc             	pushl  -0x34(%ebp)
  800622:	e8 62 03 00 00       	call   800989 <strnlen>
  800627:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80062a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	85 c9                	test   %ecx,%ecx
  800632:	0f 8e a6 02 00 00    	jle    8008de <vprintfmt+0x4af>
					putch(padc, putdat);
  800638:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80063c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063f:	89 cb                	mov    %ecx,%ebx
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	ff 75 0c             	pushl  0xc(%ebp)
  800647:	56                   	push   %esi
  800648:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	83 eb 01             	sub    $0x1,%ebx
  800650:	75 ef                	jne    800641 <vprintfmt+0x212>
  800652:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800658:	e9 81 02 00 00       	jmp    8008de <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80065d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800661:	74 1b                	je     80067e <vprintfmt+0x24f>
  800663:	0f be c0             	movsbl %al,%eax
  800666:	83 e8 20             	sub    $0x20,%eax
  800669:	83 f8 5e             	cmp    $0x5e,%eax
  80066c:	76 10                	jbe    80067e <vprintfmt+0x24f>
					putch('?', putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	ff 75 0c             	pushl  0xc(%ebp)
  800674:	6a 3f                	push   $0x3f
  800676:	ff 55 08             	call   *0x8(%ebp)
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb 0d                	jmp    80068b <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	ff 75 0c             	pushl  0xc(%ebp)
  800684:	52                   	push   %edx
  800685:	ff 55 08             	call   *0x8(%ebp)
  800688:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068b:	83 ef 01             	sub    $0x1,%edi
  80068e:	83 c6 01             	add    $0x1,%esi
  800691:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800695:	0f be d0             	movsbl %al,%edx
  800698:	85 d2                	test   %edx,%edx
  80069a:	75 31                	jne    8006cd <vprintfmt+0x29e>
  80069c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80069f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ac:	7f 33                	jg     8006e1 <vprintfmt+0x2b2>
  8006ae:	e9 90 fd ff ff       	jmp    800443 <vprintfmt+0x14>
  8006b3:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006bf:	eb 0c                	jmp    8006cd <vprintfmt+0x29e>
  8006c1:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cd:	85 db                	test   %ebx,%ebx
  8006cf:	78 8c                	js     80065d <vprintfmt+0x22e>
  8006d1:	83 eb 01             	sub    $0x1,%ebx
  8006d4:	79 87                	jns    80065d <vprintfmt+0x22e>
  8006d6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006df:	eb c4                	jmp    8006a5 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	6a 20                	push   $0x20
  8006e7:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	83 ee 01             	sub    $0x1,%esi
  8006ef:	75 f0                	jne    8006e1 <vprintfmt+0x2b2>
  8006f1:	e9 4d fd ff ff       	jmp    800443 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f6:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8006fa:	7e 16                	jle    800712 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 08             	lea    0x8(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	8b 50 04             	mov    0x4(%eax),%edx
  800708:	8b 00                	mov    (%eax),%eax
  80070a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80070d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800710:	eb 34                	jmp    800746 <vprintfmt+0x317>
	else if (lflag)
  800712:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800716:	74 18                	je     800730 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	8b 30                	mov    (%eax),%esi
  800723:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800726:	89 f0                	mov    %esi,%eax
  800728:	c1 f8 1f             	sar    $0x1f,%eax
  80072b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80072e:	eb 16                	jmp    800746 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 50 04             	lea    0x4(%eax),%edx
  800736:	89 55 14             	mov    %edx,0x14(%ebp)
  800739:	8b 30                	mov    (%eax),%esi
  80073b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80073e:	89 f0                	mov    %esi,%eax
  800740:	c1 f8 1f             	sar    $0x1f,%eax
  800743:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800746:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800749:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80074c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800752:	85 d2                	test   %edx,%edx
  800754:	79 28                	jns    80077e <vprintfmt+0x34f>
				putch('-', putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 2d                	push   $0x2d
  80075c:	ff d7                	call   *%edi
				num = -(long long) num;
  80075e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800761:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800764:	f7 d8                	neg    %eax
  800766:	83 d2 00             	adc    $0x0,%edx
  800769:	f7 da                	neg    %edx
  80076b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800771:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800774:	b8 0a 00 00 00       	mov    $0xa,%eax
  800779:	e9 b2 00 00 00       	jmp    800830 <vprintfmt+0x401>
  80077e:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800783:	85 c9                	test   %ecx,%ecx
  800785:	0f 84 a5 00 00 00    	je     800830 <vprintfmt+0x401>
				putch('+', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	6a 2b                	push   $0x2b
  800791:	ff d7                	call   *%edi
  800793:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800796:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079b:	e9 90 00 00 00       	jmp    800830 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8007a0:	85 c9                	test   %ecx,%ecx
  8007a2:	74 0b                	je     8007af <vprintfmt+0x380>
				putch('+', putdat);
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	53                   	push   %ebx
  8007a8:	6a 2b                	push   $0x2b
  8007aa:	ff d7                	call   *%edi
  8007ac:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8007af:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b5:	e8 01 fc ff ff       	call   8003bb <getuint>
  8007ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007c0:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007c5:	eb 69                	jmp    800830 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 30                	push   $0x30
  8007cd:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007cf:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d5:	e8 e1 fb ff ff       	call   8003bb <getuint>
  8007da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8007e0:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8007e3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007e8:	eb 46                	jmp    800830 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	6a 30                	push   $0x30
  8007f0:	ff d7                	call   *%edi
			putch('x', putdat);
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	53                   	push   %ebx
  8007f6:	6a 78                	push   $0x78
  8007f8:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800803:	8b 00                	mov    (%eax),%eax
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800810:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800818:	eb 16                	jmp    800830 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80081a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80081d:	8d 45 14             	lea    0x14(%ebp),%eax
  800820:	e8 96 fb ff ff       	call   8003bb <getuint>
  800825:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800828:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80082b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800830:	83 ec 0c             	sub    $0xc,%esp
  800833:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800837:	56                   	push   %esi
  800838:	ff 75 e4             	pushl  -0x1c(%ebp)
  80083b:	50                   	push   %eax
  80083c:	ff 75 dc             	pushl  -0x24(%ebp)
  80083f:	ff 75 d8             	pushl  -0x28(%ebp)
  800842:	89 da                	mov    %ebx,%edx
  800844:	89 f8                	mov    %edi,%eax
  800846:	e8 55 f9 ff ff       	call   8001a0 <printnum>
			break;
  80084b:	83 c4 20             	add    $0x20,%esp
  80084e:	e9 f0 fb ff ff       	jmp    800443 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8d 50 04             	lea    0x4(%eax),%edx
  800859:	89 55 14             	mov    %edx,0x14(%ebp)
  80085c:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  80085e:	85 f6                	test   %esi,%esi
  800860:	75 1a                	jne    80087c <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	68 ac 15 80 00       	push   $0x8015ac
  80086a:	68 13 15 80 00       	push   $0x801513
  80086f:	e8 18 f9 ff ff       	call   80018c <cprintf>
  800874:	83 c4 10             	add    $0x10,%esp
  800877:	e9 c7 fb ff ff       	jmp    800443 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  80087c:	0f b6 03             	movzbl (%ebx),%eax
  80087f:	84 c0                	test   %al,%al
  800881:	79 1f                	jns    8008a2 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	68 e4 15 80 00       	push   $0x8015e4
  80088b:	68 13 15 80 00       	push   $0x801513
  800890:	e8 f7 f8 ff ff       	call   80018c <cprintf>
						*tmp = *(char *)putdat;
  800895:	0f b6 03             	movzbl (%ebx),%eax
  800898:	88 06                	mov    %al,(%esi)
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	e9 a1 fb ff ff       	jmp    800443 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8008a2:	88 06                	mov    %al,(%esi)
  8008a4:	e9 9a fb ff ff       	jmp    800443 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	52                   	push   %edx
  8008ae:	ff d7                	call   *%edi
			break;
  8008b0:	83 c4 10             	add    $0x10,%esp
  8008b3:	e9 8b fb ff ff       	jmp    800443 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	53                   	push   %ebx
  8008bc:	6a 25                	push   $0x25
  8008be:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008c7:	0f 84 73 fb ff ff    	je     800440 <vprintfmt+0x11>
  8008cd:	83 ee 01             	sub    $0x1,%esi
  8008d0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008d4:	75 f7                	jne    8008cd <vprintfmt+0x49e>
  8008d6:	89 75 10             	mov    %esi,0x10(%ebp)
  8008d9:	e9 65 fb ff ff       	jmp    800443 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008de:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008e1:	8d 70 01             	lea    0x1(%eax),%esi
  8008e4:	0f b6 00             	movzbl (%eax),%eax
  8008e7:	0f be d0             	movsbl %al,%edx
  8008ea:	85 d2                	test   %edx,%edx
  8008ec:	0f 85 cf fd ff ff    	jne    8006c1 <vprintfmt+0x292>
  8008f2:	e9 4c fb ff ff       	jmp    800443 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	83 ec 18             	sub    $0x18,%esp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800912:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800915:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091c:	85 c0                	test   %eax,%eax
  80091e:	74 26                	je     800946 <vsnprintf+0x47>
  800920:	85 d2                	test   %edx,%edx
  800922:	7e 22                	jle    800946 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800924:	ff 75 14             	pushl  0x14(%ebp)
  800927:	ff 75 10             	pushl  0x10(%ebp)
  80092a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80092d:	50                   	push   %eax
  80092e:	68 f5 03 80 00       	push   $0x8003f5
  800933:	e8 f7 fa ff ff       	call   80042f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800938:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80093b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	eb 05                	jmp    80094b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800946:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800953:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800956:	50                   	push   %eax
  800957:	ff 75 10             	pushl  0x10(%ebp)
  80095a:	ff 75 0c             	pushl  0xc(%ebp)
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	e8 9a ff ff ff       	call   8008ff <vsnprintf>
	va_end(ap);

	return rc;
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80096d:	80 3a 00             	cmpb   $0x0,(%edx)
  800970:	74 10                	je     800982 <strlen+0x1b>
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800977:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80097a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80097e:	75 f7                	jne    800977 <strlen+0x10>
  800980:	eb 05                	jmp    800987 <strlen+0x20>
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	53                   	push   %ebx
  80098d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800990:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800993:	85 c9                	test   %ecx,%ecx
  800995:	74 1c                	je     8009b3 <strnlen+0x2a>
  800997:	80 3b 00             	cmpb   $0x0,(%ebx)
  80099a:	74 1e                	je     8009ba <strnlen+0x31>
  80099c:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009a1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a3:	39 ca                	cmp    %ecx,%edx
  8009a5:	74 18                	je     8009bf <strnlen+0x36>
  8009a7:	83 c2 01             	add    $0x1,%edx
  8009aa:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009af:	75 f0                	jne    8009a1 <strnlen+0x18>
  8009b1:	eb 0c                	jmp    8009bf <strnlen+0x36>
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b8:	eb 05                	jmp    8009bf <strnlen+0x36>
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	83 c2 01             	add    $0x1,%edx
  8009d1:	83 c1 01             	add    $0x1,%ecx
  8009d4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009d8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009db:	84 db                	test   %bl,%bl
  8009dd:	75 ef                	jne    8009ce <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e9:	53                   	push   %ebx
  8009ea:	e8 78 ff ff ff       	call   800967 <strlen>
  8009ef:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	01 d8                	add    %ebx,%eax
  8009f7:	50                   	push   %eax
  8009f8:	e8 c5 ff ff ff       	call   8009c2 <strcpy>
	return dst;
}
  8009fd:	89 d8                	mov    %ebx,%eax
  8009ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a12:	85 db                	test   %ebx,%ebx
  800a14:	74 17                	je     800a2d <strncpy+0x29>
  800a16:	01 f3                	add    %esi,%ebx
  800a18:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	0f b6 02             	movzbl (%edx),%eax
  800a20:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a23:	80 3a 01             	cmpb   $0x1,(%edx)
  800a26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a29:	39 cb                	cmp    %ecx,%ebx
  800a2b:	75 ed                	jne    800a1a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a2d:	89 f0                	mov    %esi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3e:	8b 55 10             	mov    0x10(%ebp),%edx
  800a41:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a43:	85 d2                	test   %edx,%edx
  800a45:	74 35                	je     800a7c <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a47:	89 d0                	mov    %edx,%eax
  800a49:	83 e8 01             	sub    $0x1,%eax
  800a4c:	74 25                	je     800a73 <strlcpy+0x40>
  800a4e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a51:	84 c9                	test   %cl,%cl
  800a53:	74 22                	je     800a77 <strlcpy+0x44>
  800a55:	8d 53 01             	lea    0x1(%ebx),%edx
  800a58:	01 c3                	add    %eax,%ebx
  800a5a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a5c:	83 c0 01             	add    $0x1,%eax
  800a5f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a62:	39 da                	cmp    %ebx,%edx
  800a64:	74 13                	je     800a79 <strlcpy+0x46>
  800a66:	83 c2 01             	add    $0x1,%edx
  800a69:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a6d:	84 c9                	test   %cl,%cl
  800a6f:	75 eb                	jne    800a5c <strlcpy+0x29>
  800a71:	eb 06                	jmp    800a79 <strlcpy+0x46>
  800a73:	89 f0                	mov    %esi,%eax
  800a75:	eb 02                	jmp    800a79 <strlcpy+0x46>
  800a77:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a79:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a7c:	29 f0                	sub    %esi,%eax
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a88:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	84 c0                	test   %al,%al
  800a90:	74 15                	je     800aa7 <strcmp+0x25>
  800a92:	3a 02                	cmp    (%edx),%al
  800a94:	75 11                	jne    800aa7 <strcmp+0x25>
		p++, q++;
  800a96:	83 c1 01             	add    $0x1,%ecx
  800a99:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9c:	0f b6 01             	movzbl (%ecx),%eax
  800a9f:	84 c0                	test   %al,%al
  800aa1:	74 04                	je     800aa7 <strcmp+0x25>
  800aa3:	3a 02                	cmp    (%edx),%al
  800aa5:	74 ef                	je     800a96 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa7:	0f b6 c0             	movzbl %al,%eax
  800aaa:	0f b6 12             	movzbl (%edx),%edx
  800aad:	29 d0                	sub    %edx,%eax
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800abf:	85 f6                	test   %esi,%esi
  800ac1:	74 29                	je     800aec <strncmp+0x3b>
  800ac3:	0f b6 03             	movzbl (%ebx),%eax
  800ac6:	84 c0                	test   %al,%al
  800ac8:	74 30                	je     800afa <strncmp+0x49>
  800aca:	3a 02                	cmp    (%edx),%al
  800acc:	75 2c                	jne    800afa <strncmp+0x49>
  800ace:	8d 43 01             	lea    0x1(%ebx),%eax
  800ad1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad8:	39 c6                	cmp    %eax,%esi
  800ada:	74 17                	je     800af3 <strncmp+0x42>
  800adc:	0f b6 08             	movzbl (%eax),%ecx
  800adf:	84 c9                	test   %cl,%cl
  800ae1:	74 17                	je     800afa <strncmp+0x49>
  800ae3:	83 c0 01             	add    $0x1,%eax
  800ae6:	3a 0a                	cmp    (%edx),%cl
  800ae8:	74 e9                	je     800ad3 <strncmp+0x22>
  800aea:	eb 0e                	jmp    800afa <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	eb 0f                	jmp    800b02 <strncmp+0x51>
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	eb 08                	jmp    800b02 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800afa:	0f b6 03             	movzbl (%ebx),%eax
  800afd:	0f b6 12             	movzbl (%edx),%edx
  800b00:	29 d0                	sub    %edx,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b10:	0f b6 10             	movzbl (%eax),%edx
  800b13:	84 d2                	test   %dl,%dl
  800b15:	74 1d                	je     800b34 <strchr+0x2e>
  800b17:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b19:	38 d3                	cmp    %dl,%bl
  800b1b:	75 06                	jne    800b23 <strchr+0x1d>
  800b1d:	eb 1a                	jmp    800b39 <strchr+0x33>
  800b1f:	38 ca                	cmp    %cl,%dl
  800b21:	74 16                	je     800b39 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b23:	83 c0 01             	add    $0x1,%eax
  800b26:	0f b6 10             	movzbl (%eax),%edx
  800b29:	84 d2                	test   %dl,%dl
  800b2b:	75 f2                	jne    800b1f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	eb 05                	jmp    800b39 <strchr+0x33>
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b46:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b49:	38 d3                	cmp    %dl,%bl
  800b4b:	74 14                	je     800b61 <strfind+0x25>
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	84 db                	test   %bl,%bl
  800b51:	74 0e                	je     800b61 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b53:	83 c0 01             	add    $0x1,%eax
  800b56:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b59:	38 ca                	cmp    %cl,%dl
  800b5b:	74 04                	je     800b61 <strfind+0x25>
  800b5d:	84 d2                	test   %dl,%dl
  800b5f:	75 f2                	jne    800b53 <strfind+0x17>
			break;
	return (char *) s;
}
  800b61:	5b                   	pop    %ebx
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b70:	85 c9                	test   %ecx,%ecx
  800b72:	74 36                	je     800baa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7a:	75 28                	jne    800ba4 <memset+0x40>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	75 23                	jne    800ba4 <memset+0x40>
		c &= 0xFF;
  800b81:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	c1 e3 08             	shl    $0x8,%ebx
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	c1 e6 18             	shl    $0x18,%esi
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	c1 e0 10             	shl    $0x10,%eax
  800b94:	09 f0                	or     %esi,%eax
  800b96:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b98:	89 d8                	mov    %ebx,%eax
  800b9a:	09 d0                	or     %edx,%eax
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
  800b9f:	fc                   	cld    
  800ba0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba2:	eb 06                	jmp    800baa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba7:	fc                   	cld    
  800ba8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800baa:	89 f8                	mov    %edi,%eax
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bbf:	39 c6                	cmp    %eax,%esi
  800bc1:	73 35                	jae    800bf8 <memmove+0x47>
  800bc3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc6:	39 d0                	cmp    %edx,%eax
  800bc8:	73 2e                	jae    800bf8 <memmove+0x47>
		s += n;
		d += n;
  800bca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	09 fe                	or     %edi,%esi
  800bd1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd7:	75 13                	jne    800bec <memmove+0x3b>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 0e                	jne    800bec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bde:	83 ef 04             	sub    $0x4,%edi
  800be1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be4:	c1 e9 02             	shr    $0x2,%ecx
  800be7:	fd                   	std    
  800be8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bea:	eb 09                	jmp    800bf5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bec:	83 ef 01             	sub    $0x1,%edi
  800bef:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bf2:	fd                   	std    
  800bf3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf5:	fc                   	cld    
  800bf6:	eb 1d                	jmp    800c15 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf8:	89 f2                	mov    %esi,%edx
  800bfa:	09 c2                	or     %eax,%edx
  800bfc:	f6 c2 03             	test   $0x3,%dl
  800bff:	75 0f                	jne    800c10 <memmove+0x5f>
  800c01:	f6 c1 03             	test   $0x3,%cl
  800c04:	75 0a                	jne    800c10 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c06:	c1 e9 02             	shr    $0x2,%ecx
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	fc                   	cld    
  800c0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0e:	eb 05                	jmp    800c15 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c10:	89 c7                	mov    %eax,%edi
  800c12:	fc                   	cld    
  800c13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c1c:	ff 75 10             	pushl  0x10(%ebp)
  800c1f:	ff 75 0c             	pushl  0xc(%ebp)
  800c22:	ff 75 08             	pushl  0x8(%ebp)
  800c25:	e8 87 ff ff ff       	call   800bb1 <memmove>
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c38:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	74 39                	je     800c78 <memcmp+0x4c>
  800c3f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c42:	0f b6 13             	movzbl (%ebx),%edx
  800c45:	0f b6 0e             	movzbl (%esi),%ecx
  800c48:	38 ca                	cmp    %cl,%dl
  800c4a:	75 17                	jne    800c63 <memcmp+0x37>
  800c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c51:	eb 1a                	jmp    800c6d <memcmp+0x41>
  800c53:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c58:	83 c0 01             	add    $0x1,%eax
  800c5b:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c5f:	38 ca                	cmp    %cl,%dl
  800c61:	74 0a                	je     800c6d <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c63:	0f b6 c2             	movzbl %dl,%eax
  800c66:	0f b6 c9             	movzbl %cl,%ecx
  800c69:	29 c8                	sub    %ecx,%eax
  800c6b:	eb 10                	jmp    800c7d <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6d:	39 f8                	cmp    %edi,%eax
  800c6f:	75 e2                	jne    800c53 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	eb 05                	jmp    800c7d <memcmp+0x51>
  800c78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	53                   	push   %ebx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c89:	89 d0                	mov    %edx,%eax
  800c8b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c8e:	39 c2                	cmp    %eax,%edx
  800c90:	73 1d                	jae    800caf <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c92:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c96:	0f b6 0a             	movzbl (%edx),%ecx
  800c99:	39 d9                	cmp    %ebx,%ecx
  800c9b:	75 09                	jne    800ca6 <memfind+0x24>
  800c9d:	eb 14                	jmp    800cb3 <memfind+0x31>
  800c9f:	0f b6 0a             	movzbl (%edx),%ecx
  800ca2:	39 d9                	cmp    %ebx,%ecx
  800ca4:	74 11                	je     800cb7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca6:	83 c2 01             	add    $0x1,%edx
  800ca9:	39 d0                	cmp    %edx,%eax
  800cab:	75 f2                	jne    800c9f <memfind+0x1d>
  800cad:	eb 0a                	jmp    800cb9 <memfind+0x37>
  800caf:	89 d0                	mov    %edx,%eax
  800cb1:	eb 06                	jmp    800cb9 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb3:	89 d0                	mov    %edx,%eax
  800cb5:	eb 02                	jmp    800cb9 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cb9:	5b                   	pop    %ebx
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc8:	0f b6 01             	movzbl (%ecx),%eax
  800ccb:	3c 20                	cmp    $0x20,%al
  800ccd:	74 04                	je     800cd3 <strtol+0x17>
  800ccf:	3c 09                	cmp    $0x9,%al
  800cd1:	75 0e                	jne    800ce1 <strtol+0x25>
		s++;
  800cd3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd6:	0f b6 01             	movzbl (%ecx),%eax
  800cd9:	3c 20                	cmp    $0x20,%al
  800cdb:	74 f6                	je     800cd3 <strtol+0x17>
  800cdd:	3c 09                	cmp    $0x9,%al
  800cdf:	74 f2                	je     800cd3 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce1:	3c 2b                	cmp    $0x2b,%al
  800ce3:	75 0a                	jne    800cef <strtol+0x33>
		s++;
  800ce5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ced:	eb 11                	jmp    800d00 <strtol+0x44>
  800cef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf4:	3c 2d                	cmp    $0x2d,%al
  800cf6:	75 08                	jne    800d00 <strtol+0x44>
		s++, neg = 1;
  800cf8:	83 c1 01             	add    $0x1,%ecx
  800cfb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d00:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d06:	75 15                	jne    800d1d <strtol+0x61>
  800d08:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0b:	75 10                	jne    800d1d <strtol+0x61>
  800d0d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d11:	75 7c                	jne    800d8f <strtol+0xd3>
		s += 2, base = 16;
  800d13:	83 c1 02             	add    $0x2,%ecx
  800d16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d1b:	eb 16                	jmp    800d33 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d1d:	85 db                	test   %ebx,%ebx
  800d1f:	75 12                	jne    800d33 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d21:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d26:	80 39 30             	cmpb   $0x30,(%ecx)
  800d29:	75 08                	jne    800d33 <strtol+0x77>
		s++, base = 8;
  800d2b:	83 c1 01             	add    $0x1,%ecx
  800d2e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d33:	b8 00 00 00 00       	mov    $0x0,%eax
  800d38:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3b:	0f b6 11             	movzbl (%ecx),%edx
  800d3e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d41:	89 f3                	mov    %esi,%ebx
  800d43:	80 fb 09             	cmp    $0x9,%bl
  800d46:	77 08                	ja     800d50 <strtol+0x94>
			dig = *s - '0';
  800d48:	0f be d2             	movsbl %dl,%edx
  800d4b:	83 ea 30             	sub    $0x30,%edx
  800d4e:	eb 22                	jmp    800d72 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d50:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d53:	89 f3                	mov    %esi,%ebx
  800d55:	80 fb 19             	cmp    $0x19,%bl
  800d58:	77 08                	ja     800d62 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d5a:	0f be d2             	movsbl %dl,%edx
  800d5d:	83 ea 57             	sub    $0x57,%edx
  800d60:	eb 10                	jmp    800d72 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d62:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d65:	89 f3                	mov    %esi,%ebx
  800d67:	80 fb 19             	cmp    $0x19,%bl
  800d6a:	77 16                	ja     800d82 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d6c:	0f be d2             	movsbl %dl,%edx
  800d6f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d75:	7d 0b                	jge    800d82 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d77:	83 c1 01             	add    $0x1,%ecx
  800d7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d7e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d80:	eb b9                	jmp    800d3b <strtol+0x7f>

	if (endptr)
  800d82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d86:	74 0d                	je     800d95 <strtol+0xd9>
		*endptr = (char *) s;
  800d88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8b:	89 0e                	mov    %ecx,(%esi)
  800d8d:	eb 06                	jmp    800d95 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d8f:	85 db                	test   %ebx,%ebx
  800d91:	74 98                	je     800d2b <strtol+0x6f>
  800d93:	eb 9e                	jmp    800d33 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	f7 da                	neg    %edx
  800d99:	85 ff                	test   %edi,%edi
  800d9b:	0f 45 c2             	cmovne %edx,%eax
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 c3                	mov    %eax,%ebx
  800db5:	89 c7                	mov    %eax,%edi
  800db7:	51                   	push   %ecx
  800db8:	52                   	push   %edx
  800db9:	53                   	push   %ebx
  800dba:	56                   	push   %esi
  800dbb:	57                   	push   %edi
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	8d 35 c7 0d 80 00    	lea    0x800dc7,%esi
  800dc5:	0f 34                	sysenter 

00800dc7 <label_21>:
  800dc7:	89 ec                	mov    %ebp,%esp
  800dc9:	5d                   	pop    %ebp
  800dca:	5f                   	pop    %edi
  800dcb:	5e                   	pop    %esi
  800dcc:	5b                   	pop    %ebx
  800dcd:	5a                   	pop    %edx
  800dce:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dcf:	5b                   	pop    %ebx
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddd:	b8 01 00 00 00       	mov    $0x1,%eax
  800de2:	89 ca                	mov    %ecx,%edx
  800de4:	89 cb                	mov    %ecx,%ebx
  800de6:	89 cf                	mov    %ecx,%edi
  800de8:	51                   	push   %ecx
  800de9:	52                   	push   %edx
  800dea:	53                   	push   %ebx
  800deb:	56                   	push   %esi
  800dec:	57                   	push   %edi
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	8d 35 f8 0d 80 00    	lea    0x800df8,%esi
  800df6:	0f 34                	sysenter 

00800df8 <label_55>:
  800df8:	89 ec                	mov    %ebp,%esp
  800dfa:	5d                   	pop    %ebp
  800dfb:	5f                   	pop    %edi
  800dfc:	5e                   	pop    %esi
  800dfd:	5b                   	pop    %ebx
  800dfe:	5a                   	pop    %edx
  800dff:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 d9                	mov    %ebx,%ecx
  800e18:	89 df                	mov    %ebx,%edi
  800e1a:	51                   	push   %ecx
  800e1b:	52                   	push   %edx
  800e1c:	53                   	push   %ebx
  800e1d:	56                   	push   %esi
  800e1e:	57                   	push   %edi
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	8d 35 2a 0e 80 00    	lea    0x800e2a,%esi
  800e28:	0f 34                	sysenter 

00800e2a <label_90>:
  800e2a:	89 ec                	mov    %ebp,%esp
  800e2c:	5d                   	pop    %ebp
  800e2d:	5f                   	pop    %edi
  800e2e:	5e                   	pop    %esi
  800e2f:	5b                   	pop    %ebx
  800e30:	5a                   	pop    %edx
  800e31:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 17                	jle    800e4d <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	50                   	push   %eax
  800e3a:	6a 03                	push   $0x3
  800e3c:	68 c4 17 80 00       	push   $0x8017c4
  800e41:	6a 29                	push   $0x29
  800e43:	68 e1 17 80 00       	push   $0x8017e1
  800e48:	e8 7f 03 00 00       	call   8011cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e63:	89 ca                	mov    %ecx,%edx
  800e65:	89 cb                	mov    %ecx,%ebx
  800e67:	89 cf                	mov    %ecx,%edi
  800e69:	51                   	push   %ecx
  800e6a:	52                   	push   %edx
  800e6b:	53                   	push   %ebx
  800e6c:	56                   	push   %esi
  800e6d:	57                   	push   %edi
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	8d 35 79 0e 80 00    	lea    0x800e79,%esi
  800e77:	0f 34                	sysenter 

00800e79 <label_139>:
  800e79:	89 ec                	mov    %ebp,%esp
  800e7b:	5d                   	pop    %ebp
  800e7c:	5f                   	pop    %edi
  800e7d:	5e                   	pop    %esi
  800e7e:	5b                   	pop    %ebx
  800e7f:	5a                   	pop    %edx
  800e80:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e81:	5b                   	pop    %ebx
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 fb                	mov    %edi,%ebx
  800e9c:	51                   	push   %ecx
  800e9d:	52                   	push   %edx
  800e9e:	53                   	push   %ebx
  800e9f:	56                   	push   %esi
  800ea0:	57                   	push   %edi
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	8d 35 ac 0e 80 00    	lea    0x800eac,%esi
  800eaa:	0f 34                	sysenter 

00800eac <label_174>:
  800eac:	89 ec                	mov    %ebp,%esp
  800eae:	5d                   	pop    %ebp
  800eaf:	5f                   	pop    %edi
  800eb0:	5e                   	pop    %esi
  800eb1:	5b                   	pop    %ebx
  800eb2:	5a                   	pop    %edx
  800eb3:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <sys_yield>:

void
sys_yield(void)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ebd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec7:	89 d1                	mov    %edx,%ecx
  800ec9:	89 d3                	mov    %edx,%ebx
  800ecb:	89 d7                	mov    %edx,%edi
  800ecd:	51                   	push   %ecx
  800ece:	52                   	push   %edx
  800ecf:	53                   	push   %ebx
  800ed0:	56                   	push   %esi
  800ed1:	57                   	push   %edi
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	8d 35 dd 0e 80 00    	lea    0x800edd,%esi
  800edb:	0f 34                	sysenter 

00800edd <label_209>:
  800edd:	89 ec                	mov    %ebp,%esp
  800edf:	5d                   	pop    %ebp
  800ee0:	5f                   	pop    %edi
  800ee1:	5e                   	pop    %esi
  800ee2:	5b                   	pop    %ebx
  800ee3:	5a                   	pop    %edx
  800ee4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ee5:	5b                   	pop    %ebx
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eee:	bf 00 00 00 00       	mov    $0x0,%edi
  800ef3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f01:	51                   	push   %ecx
  800f02:	52                   	push   %edx
  800f03:	53                   	push   %ebx
  800f04:	56                   	push   %esi
  800f05:	57                   	push   %edi
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	8d 35 11 0f 80 00    	lea    0x800f11,%esi
  800f0f:	0f 34                	sysenter 

00800f11 <label_244>:
  800f11:	89 ec                	mov    %ebp,%esp
  800f13:	5d                   	pop    %ebp
  800f14:	5f                   	pop    %edi
  800f15:	5e                   	pop    %esi
  800f16:	5b                   	pop    %ebx
  800f17:	5a                   	pop    %edx
  800f18:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	7e 17                	jle    800f34 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	50                   	push   %eax
  800f21:	6a 05                	push   $0x5
  800f23:	68 c4 17 80 00       	push   $0x8017c4
  800f28:	6a 29                	push   $0x29
  800f2a:	68 e1 17 80 00       	push   $0x8017e1
  800f2f:	e8 98 02 00 00       	call   8011cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	57                   	push   %edi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800f49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800f4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f52:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800f55:	8b 45 14             	mov    0x14(%ebp),%eax
  800f58:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800f5b:	8b 45 18             	mov    0x18(%ebp),%eax
  800f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f61:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f69:	b8 06 00 00 00       	mov    $0x6,%eax
  800f6e:	89 cb                	mov    %ecx,%ebx
  800f70:	89 cf                	mov    %ecx,%edi
  800f72:	51                   	push   %ecx
  800f73:	52                   	push   %edx
  800f74:	53                   	push   %ebx
  800f75:	56                   	push   %esi
  800f76:	57                   	push   %edi
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	8d 35 82 0f 80 00    	lea    0x800f82,%esi
  800f80:	0f 34                	sysenter 

00800f82 <label_304>:
  800f82:	89 ec                	mov    %ebp,%esp
  800f84:	5d                   	pop    %ebp
  800f85:	5f                   	pop    %edi
  800f86:	5e                   	pop    %esi
  800f87:	5b                   	pop    %ebx
  800f88:	5a                   	pop    %edx
  800f89:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	7e 17                	jle    800fa5 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	50                   	push   %eax
  800f92:	6a 06                	push   $0x6
  800f94:	68 c4 17 80 00       	push   $0x8017c4
  800f99:	6a 29                	push   $0x29
  800f9b:	68 e1 17 80 00       	push   $0x8017e1
  800fa0:	e8 27 02 00 00       	call   8011cc <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  800fa5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	57                   	push   %edi
  800fb0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb1:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb6:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc1:	89 fb                	mov    %edi,%ebx
  800fc3:	51                   	push   %ecx
  800fc4:	52                   	push   %edx
  800fc5:	53                   	push   %ebx
  800fc6:	56                   	push   %esi
  800fc7:	57                   	push   %edi
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	8d 35 d3 0f 80 00    	lea    0x800fd3,%esi
  800fd1:	0f 34                	sysenter 

00800fd3 <label_353>:
  800fd3:	89 ec                	mov    %ebp,%esp
  800fd5:	5d                   	pop    %ebp
  800fd6:	5f                   	pop    %edi
  800fd7:	5e                   	pop    %esi
  800fd8:	5b                   	pop    %ebx
  800fd9:	5a                   	pop    %edx
  800fda:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	7e 17                	jle    800ff6 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	50                   	push   %eax
  800fe3:	6a 07                	push   $0x7
  800fe5:	68 c4 17 80 00       	push   $0x8017c4
  800fea:	6a 29                	push   $0x29
  800fec:	68 e1 17 80 00       	push   $0x8017e1
  800ff1:	e8 d6 01 00 00       	call   8011cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ff6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff9:	5b                   	pop    %ebx
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801002:	bf 00 00 00 00       	mov    $0x0,%edi
  801007:	b8 09 00 00 00       	mov    $0x9,%eax
  80100c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100f:	8b 55 08             	mov    0x8(%ebp),%edx
  801012:	89 fb                	mov    %edi,%ebx
  801014:	51                   	push   %ecx
  801015:	52                   	push   %edx
  801016:	53                   	push   %ebx
  801017:	56                   	push   %esi
  801018:	57                   	push   %edi
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	8d 35 24 10 80 00    	lea    0x801024,%esi
  801022:	0f 34                	sysenter 

00801024 <label_402>:
  801024:	89 ec                	mov    %ebp,%esp
  801026:	5d                   	pop    %ebp
  801027:	5f                   	pop    %edi
  801028:	5e                   	pop    %esi
  801029:	5b                   	pop    %ebx
  80102a:	5a                   	pop    %edx
  80102b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80102c:	85 c0                	test   %eax,%eax
  80102e:	7e 17                	jle    801047 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	50                   	push   %eax
  801034:	6a 09                	push   $0x9
  801036:	68 c4 17 80 00       	push   $0x8017c4
  80103b:	6a 29                	push   $0x29
  80103d:	68 e1 17 80 00       	push   $0x8017e1
  801042:	e8 85 01 00 00       	call   8011cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801047:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801053:	bf 00 00 00 00       	mov    $0x0,%edi
  801058:	b8 0a 00 00 00       	mov    $0xa,%eax
  80105d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801060:	8b 55 08             	mov    0x8(%ebp),%edx
  801063:	89 fb                	mov    %edi,%ebx
  801065:	51                   	push   %ecx
  801066:	52                   	push   %edx
  801067:	53                   	push   %ebx
  801068:	56                   	push   %esi
  801069:	57                   	push   %edi
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	8d 35 75 10 80 00    	lea    0x801075,%esi
  801073:	0f 34                	sysenter 

00801075 <label_451>:
  801075:	89 ec                	mov    %ebp,%esp
  801077:	5d                   	pop    %ebp
  801078:	5f                   	pop    %edi
  801079:	5e                   	pop    %esi
  80107a:	5b                   	pop    %ebx
  80107b:	5a                   	pop    %edx
  80107c:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80107d:	85 c0                	test   %eax,%eax
  80107f:	7e 17                	jle    801098 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	50                   	push   %eax
  801085:	6a 0a                	push   $0xa
  801087:	68 c4 17 80 00       	push   $0x8017c4
  80108c:	6a 29                	push   $0x29
  80108e:	68 e1 17 80 00       	push   $0x8017e1
  801093:	e8 34 01 00 00       	call   8011cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	57                   	push   %edi
  8010a3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010a4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8010af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b5:	51                   	push   %ecx
  8010b6:	52                   	push   %edx
  8010b7:	53                   	push   %ebx
  8010b8:	56                   	push   %esi
  8010b9:	57                   	push   %edi
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	8d 35 c5 10 80 00    	lea    0x8010c5,%esi
  8010c3:	0f 34                	sysenter 

008010c5 <label_502>:
  8010c5:	89 ec                	mov    %ebp,%esp
  8010c7:	5d                   	pop    %ebp
  8010c8:	5f                   	pop    %edi
  8010c9:	5e                   	pop    %esi
  8010ca:	5b                   	pop    %ebx
  8010cb:	5a                   	pop    %edx
  8010cc:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010cd:	5b                   	pop    %ebx
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010db:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e3:	89 d9                	mov    %ebx,%ecx
  8010e5:	89 df                	mov    %ebx,%edi
  8010e7:	51                   	push   %ecx
  8010e8:	52                   	push   %edx
  8010e9:	53                   	push   %ebx
  8010ea:	56                   	push   %esi
  8010eb:	57                   	push   %edi
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	8d 35 f7 10 80 00    	lea    0x8010f7,%esi
  8010f5:	0f 34                	sysenter 

008010f7 <label_537>:
  8010f7:	89 ec                	mov    %ebp,%esp
  8010f9:	5d                   	pop    %ebp
  8010fa:	5f                   	pop    %edi
  8010fb:	5e                   	pop    %esi
  8010fc:	5b                   	pop    %ebx
  8010fd:	5a                   	pop    %edx
  8010fe:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010ff:	85 c0                	test   %eax,%eax
  801101:	7e 17                	jle    80111a <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	50                   	push   %eax
  801107:	6a 0d                	push   $0xd
  801109:	68 c4 17 80 00       	push   $0x8017c4
  80110e:	6a 29                	push   $0x29
  801110:	68 e1 17 80 00       	push   $0x8017e1
  801115:	e8 b2 00 00 00       	call   8011cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80111a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5f                   	pop    %edi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	57                   	push   %edi
  801125:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112b:	b8 0e 00 00 00       	mov    $0xe,%eax
  801130:	8b 55 08             	mov    0x8(%ebp),%edx
  801133:	89 cb                	mov    %ecx,%ebx
  801135:	89 cf                	mov    %ecx,%edi
  801137:	51                   	push   %ecx
  801138:	52                   	push   %edx
  801139:	53                   	push   %ebx
  80113a:	56                   	push   %esi
  80113b:	57                   	push   %edi
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	8d 35 47 11 80 00    	lea    0x801147,%esi
  801145:	0f 34                	sysenter 

00801147 <label_586>:
  801147:	89 ec                	mov    %ebp,%esp
  801149:	5d                   	pop    %ebp
  80114a:	5f                   	pop    %edi
  80114b:	5e                   	pop    %esi
  80114c:	5b                   	pop    %ebx
  80114d:	5a                   	pop    %edx
  80114e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80114f:	5b                   	pop    %ebx
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801159:	68 ef 17 80 00       	push   $0x8017ef
  80115e:	6a 1a                	push   $0x1a
  801160:	68 08 18 80 00       	push   $0x801808
  801165:	e8 62 00 00 00       	call   8011cc <_panic>

0080116a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801170:	68 12 18 80 00       	push   $0x801812
  801175:	6a 2a                	push   $0x2a
  801177:	68 08 18 80 00       	push   $0x801808
  80117c:	e8 4b 00 00 00       	call   8011cc <_panic>

00801181 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801187:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80118c:	39 c1                	cmp    %eax,%ecx
  80118e:	74 19                	je     8011a9 <ipc_find_env+0x28>
  801190:	b8 01 00 00 00       	mov    $0x1,%eax
  801195:	89 c2                	mov    %eax,%edx
  801197:	c1 e2 07             	shl    $0x7,%edx
  80119a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011a0:	8b 52 50             	mov    0x50(%edx),%edx
  8011a3:	39 ca                	cmp    %ecx,%edx
  8011a5:	75 14                	jne    8011bb <ipc_find_env+0x3a>
  8011a7:	eb 05                	jmp    8011ae <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8011ae:	c1 e0 07             	shl    $0x7,%eax
  8011b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011b6:	8b 40 48             	mov    0x48(%eax),%eax
  8011b9:	eb 0f                	jmp    8011ca <ipc_find_env+0x49>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011bb:	83 c0 01             	add    $0x1,%eax
  8011be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c3:	75 d0                	jne    801195 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8011d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8011d4:	a1 10 20 80 00       	mov    0x802010,%eax
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	74 11                	je     8011ee <_panic+0x22>
		cprintf("%s: ", argv0);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	50                   	push   %eax
  8011e1:	68 2b 18 80 00       	push   $0x80182b
  8011e6:	e8 a1 ef ff ff       	call   80018c <cprintf>
  8011eb:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011ee:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011f4:	e8 5b fc ff ff       	call   800e54 <sys_getenvid>
  8011f9:	83 ec 0c             	sub    $0xc,%esp
  8011fc:	ff 75 0c             	pushl  0xc(%ebp)
  8011ff:	ff 75 08             	pushl  0x8(%ebp)
  801202:	56                   	push   %esi
  801203:	50                   	push   %eax
  801204:	68 30 18 80 00       	push   $0x801830
  801209:	e8 7e ef ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80120e:	83 c4 18             	add    $0x18,%esp
  801211:	53                   	push   %ebx
  801212:	ff 75 10             	pushl  0x10(%ebp)
  801215:	e8 21 ef ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  80121a:	c7 04 24 cf 14 80 00 	movl   $0x8014cf,(%esp)
  801221:	e8 66 ef ff ff       	call   80018c <cprintf>
  801226:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801229:	cc                   	int3   
  80122a:	eb fd                	jmp    801229 <_panic+0x5d>
  80122c:	66 90                	xchg   %ax,%ax
  80122e:	66 90                	xchg   %ax,%ax

00801230 <__udivdi3>:
  801230:	55                   	push   %ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 1c             	sub    $0x1c,%esp
  801237:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80123b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80123f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801247:	85 f6                	test   %esi,%esi
  801249:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80124d:	89 ca                	mov    %ecx,%edx
  80124f:	89 f8                	mov    %edi,%eax
  801251:	75 3d                	jne    801290 <__udivdi3+0x60>
  801253:	39 cf                	cmp    %ecx,%edi
  801255:	0f 87 c5 00 00 00    	ja     801320 <__udivdi3+0xf0>
  80125b:	85 ff                	test   %edi,%edi
  80125d:	89 fd                	mov    %edi,%ebp
  80125f:	75 0b                	jne    80126c <__udivdi3+0x3c>
  801261:	b8 01 00 00 00       	mov    $0x1,%eax
  801266:	31 d2                	xor    %edx,%edx
  801268:	f7 f7                	div    %edi
  80126a:	89 c5                	mov    %eax,%ebp
  80126c:	89 c8                	mov    %ecx,%eax
  80126e:	31 d2                	xor    %edx,%edx
  801270:	f7 f5                	div    %ebp
  801272:	89 c1                	mov    %eax,%ecx
  801274:	89 d8                	mov    %ebx,%eax
  801276:	89 cf                	mov    %ecx,%edi
  801278:	f7 f5                	div    %ebp
  80127a:	89 c3                	mov    %eax,%ebx
  80127c:	89 d8                	mov    %ebx,%eax
  80127e:	89 fa                	mov    %edi,%edx
  801280:	83 c4 1c             	add    $0x1c,%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    
  801288:	90                   	nop
  801289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801290:	39 ce                	cmp    %ecx,%esi
  801292:	77 74                	ja     801308 <__udivdi3+0xd8>
  801294:	0f bd fe             	bsr    %esi,%edi
  801297:	83 f7 1f             	xor    $0x1f,%edi
  80129a:	0f 84 98 00 00 00    	je     801338 <__udivdi3+0x108>
  8012a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8012a5:	89 f9                	mov    %edi,%ecx
  8012a7:	89 c5                	mov    %eax,%ebp
  8012a9:	29 fb                	sub    %edi,%ebx
  8012ab:	d3 e6                	shl    %cl,%esi
  8012ad:	89 d9                	mov    %ebx,%ecx
  8012af:	d3 ed                	shr    %cl,%ebp
  8012b1:	89 f9                	mov    %edi,%ecx
  8012b3:	d3 e0                	shl    %cl,%eax
  8012b5:	09 ee                	or     %ebp,%esi
  8012b7:	89 d9                	mov    %ebx,%ecx
  8012b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012bd:	89 d5                	mov    %edx,%ebp
  8012bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012c3:	d3 ed                	shr    %cl,%ebp
  8012c5:	89 f9                	mov    %edi,%ecx
  8012c7:	d3 e2                	shl    %cl,%edx
  8012c9:	89 d9                	mov    %ebx,%ecx
  8012cb:	d3 e8                	shr    %cl,%eax
  8012cd:	09 c2                	or     %eax,%edx
  8012cf:	89 d0                	mov    %edx,%eax
  8012d1:	89 ea                	mov    %ebp,%edx
  8012d3:	f7 f6                	div    %esi
  8012d5:	89 d5                	mov    %edx,%ebp
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	f7 64 24 0c          	mull   0xc(%esp)
  8012dd:	39 d5                	cmp    %edx,%ebp
  8012df:	72 10                	jb     8012f1 <__udivdi3+0xc1>
  8012e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012e5:	89 f9                	mov    %edi,%ecx
  8012e7:	d3 e6                	shl    %cl,%esi
  8012e9:	39 c6                	cmp    %eax,%esi
  8012eb:	73 07                	jae    8012f4 <__udivdi3+0xc4>
  8012ed:	39 d5                	cmp    %edx,%ebp
  8012ef:	75 03                	jne    8012f4 <__udivdi3+0xc4>
  8012f1:	83 eb 01             	sub    $0x1,%ebx
  8012f4:	31 ff                	xor    %edi,%edi
  8012f6:	89 d8                	mov    %ebx,%eax
  8012f8:	89 fa                	mov    %edi,%edx
  8012fa:	83 c4 1c             	add    $0x1c,%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    
  801302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801308:	31 ff                	xor    %edi,%edi
  80130a:	31 db                	xor    %ebx,%ebx
  80130c:	89 d8                	mov    %ebx,%eax
  80130e:	89 fa                	mov    %edi,%edx
  801310:	83 c4 1c             	add    $0x1c,%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    
  801318:	90                   	nop
  801319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801320:	89 d8                	mov    %ebx,%eax
  801322:	f7 f7                	div    %edi
  801324:	31 ff                	xor    %edi,%edi
  801326:	89 c3                	mov    %eax,%ebx
  801328:	89 d8                	mov    %ebx,%eax
  80132a:	89 fa                	mov    %edi,%edx
  80132c:	83 c4 1c             	add    $0x1c,%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    
  801334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801338:	39 ce                	cmp    %ecx,%esi
  80133a:	72 0c                	jb     801348 <__udivdi3+0x118>
  80133c:	31 db                	xor    %ebx,%ebx
  80133e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801342:	0f 87 34 ff ff ff    	ja     80127c <__udivdi3+0x4c>
  801348:	bb 01 00 00 00       	mov    $0x1,%ebx
  80134d:	e9 2a ff ff ff       	jmp    80127c <__udivdi3+0x4c>
  801352:	66 90                	xchg   %ax,%ax
  801354:	66 90                	xchg   %ax,%ax
  801356:	66 90                	xchg   %ax,%ax
  801358:	66 90                	xchg   %ax,%ax
  80135a:	66 90                	xchg   %ax,%ax
  80135c:	66 90                	xchg   %ax,%ax
  80135e:	66 90                	xchg   %ax,%ax

00801360 <__umoddi3>:
  801360:	55                   	push   %ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
  801364:	83 ec 1c             	sub    $0x1c,%esp
  801367:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80136b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80136f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801377:	85 d2                	test   %edx,%edx
  801379:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80137d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801381:	89 f3                	mov    %esi,%ebx
  801383:	89 3c 24             	mov    %edi,(%esp)
  801386:	89 74 24 04          	mov    %esi,0x4(%esp)
  80138a:	75 1c                	jne    8013a8 <__umoddi3+0x48>
  80138c:	39 f7                	cmp    %esi,%edi
  80138e:	76 50                	jbe    8013e0 <__umoddi3+0x80>
  801390:	89 c8                	mov    %ecx,%eax
  801392:	89 f2                	mov    %esi,%edx
  801394:	f7 f7                	div    %edi
  801396:	89 d0                	mov    %edx,%eax
  801398:	31 d2                	xor    %edx,%edx
  80139a:	83 c4 1c             	add    $0x1c,%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5e                   	pop    %esi
  80139f:	5f                   	pop    %edi
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    
  8013a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013a8:	39 f2                	cmp    %esi,%edx
  8013aa:	89 d0                	mov    %edx,%eax
  8013ac:	77 52                	ja     801400 <__umoddi3+0xa0>
  8013ae:	0f bd ea             	bsr    %edx,%ebp
  8013b1:	83 f5 1f             	xor    $0x1f,%ebp
  8013b4:	75 5a                	jne    801410 <__umoddi3+0xb0>
  8013b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8013ba:	0f 82 e0 00 00 00    	jb     8014a0 <__umoddi3+0x140>
  8013c0:	39 0c 24             	cmp    %ecx,(%esp)
  8013c3:	0f 86 d7 00 00 00    	jbe    8014a0 <__umoddi3+0x140>
  8013c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013d1:	83 c4 1c             	add    $0x1c,%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5f                   	pop    %edi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    
  8013d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	85 ff                	test   %edi,%edi
  8013e2:	89 fd                	mov    %edi,%ebp
  8013e4:	75 0b                	jne    8013f1 <__umoddi3+0x91>
  8013e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	f7 f7                	div    %edi
  8013ef:	89 c5                	mov    %eax,%ebp
  8013f1:	89 f0                	mov    %esi,%eax
  8013f3:	31 d2                	xor    %edx,%edx
  8013f5:	f7 f5                	div    %ebp
  8013f7:	89 c8                	mov    %ecx,%eax
  8013f9:	f7 f5                	div    %ebp
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	eb 99                	jmp    801398 <__umoddi3+0x38>
  8013ff:	90                   	nop
  801400:	89 c8                	mov    %ecx,%eax
  801402:	89 f2                	mov    %esi,%edx
  801404:	83 c4 1c             	add    $0x1c,%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5f                   	pop    %edi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    
  80140c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801410:	8b 34 24             	mov    (%esp),%esi
  801413:	bf 20 00 00 00       	mov    $0x20,%edi
  801418:	89 e9                	mov    %ebp,%ecx
  80141a:	29 ef                	sub    %ebp,%edi
  80141c:	d3 e0                	shl    %cl,%eax
  80141e:	89 f9                	mov    %edi,%ecx
  801420:	89 f2                	mov    %esi,%edx
  801422:	d3 ea                	shr    %cl,%edx
  801424:	89 e9                	mov    %ebp,%ecx
  801426:	09 c2                	or     %eax,%edx
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	89 14 24             	mov    %edx,(%esp)
  80142d:	89 f2                	mov    %esi,%edx
  80142f:	d3 e2                	shl    %cl,%edx
  801431:	89 f9                	mov    %edi,%ecx
  801433:	89 54 24 04          	mov    %edx,0x4(%esp)
  801437:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80143b:	d3 e8                	shr    %cl,%eax
  80143d:	89 e9                	mov    %ebp,%ecx
  80143f:	89 c6                	mov    %eax,%esi
  801441:	d3 e3                	shl    %cl,%ebx
  801443:	89 f9                	mov    %edi,%ecx
  801445:	89 d0                	mov    %edx,%eax
  801447:	d3 e8                	shr    %cl,%eax
  801449:	89 e9                	mov    %ebp,%ecx
  80144b:	09 d8                	or     %ebx,%eax
  80144d:	89 d3                	mov    %edx,%ebx
  80144f:	89 f2                	mov    %esi,%edx
  801451:	f7 34 24             	divl   (%esp)
  801454:	89 d6                	mov    %edx,%esi
  801456:	d3 e3                	shl    %cl,%ebx
  801458:	f7 64 24 04          	mull   0x4(%esp)
  80145c:	39 d6                	cmp    %edx,%esi
  80145e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801462:	89 d1                	mov    %edx,%ecx
  801464:	89 c3                	mov    %eax,%ebx
  801466:	72 08                	jb     801470 <__umoddi3+0x110>
  801468:	75 11                	jne    80147b <__umoddi3+0x11b>
  80146a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80146e:	73 0b                	jae    80147b <__umoddi3+0x11b>
  801470:	2b 44 24 04          	sub    0x4(%esp),%eax
  801474:	1b 14 24             	sbb    (%esp),%edx
  801477:	89 d1                	mov    %edx,%ecx
  801479:	89 c3                	mov    %eax,%ebx
  80147b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80147f:	29 da                	sub    %ebx,%edx
  801481:	19 ce                	sbb    %ecx,%esi
  801483:	89 f9                	mov    %edi,%ecx
  801485:	89 f0                	mov    %esi,%eax
  801487:	d3 e0                	shl    %cl,%eax
  801489:	89 e9                	mov    %ebp,%ecx
  80148b:	d3 ea                	shr    %cl,%edx
  80148d:	89 e9                	mov    %ebp,%ecx
  80148f:	d3 ee                	shr    %cl,%esi
  801491:	09 d0                	or     %edx,%eax
  801493:	89 f2                	mov    %esi,%edx
  801495:	83 c4 1c             	add    $0x1c,%esp
  801498:	5b                   	pop    %ebx
  801499:	5e                   	pop    %esi
  80149a:	5f                   	pop    %edi
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    
  80149d:	8d 76 00             	lea    0x0(%esi),%esi
  8014a0:	29 f9                	sub    %edi,%ecx
  8014a2:	19 d6                	sbb    %edx,%esi
  8014a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ac:	e9 18 ff ff ff       	jmp    8013c9 <__umoddi3+0x69>
