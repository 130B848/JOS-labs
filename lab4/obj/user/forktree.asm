
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 52 0e 00 00       	call   800e94 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 e0 17 80 00       	push   $0x8017e0
  80004c:	e8 7b 01 00 00       	call   8001cc <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 24 09 00 00       	call   8009a7 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 f1 17 80 00       	push   $0x8017f1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 e8 08 00 00       	call   80098d <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 a4 11 00 00       	call   801251 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 f0 17 80 00       	push   $0x8017f0
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ec:	e8 a3 0d 00 00       	call   800e94 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	c1 e0 07             	shl    $0x7,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012d:	6a 00                	push   $0x0
  80012f:	e8 10 0d 00 00       	call   800e44 <sys_env_destroy>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	53                   	push   %ebx
  80013d:	83 ec 04             	sub    $0x4,%esp
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800143:	8b 13                	mov    (%ebx),%edx
  800145:	8d 42 01             	lea    0x1(%edx),%eax
  800148:	89 03                	mov    %eax,(%ebx)
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800151:	3d ff 00 00 00       	cmp    $0xff,%eax
  800156:	75 1a                	jne    800172 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 7a 0c 00 00       	call   800de3 <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800184:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 39 01 80 00       	push   $0x800139
  8001aa:	e8 c0 02 00 00       	call   80046f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 1f 0c 00 00       	call   800de3 <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	89 c7                	mov    %eax,%edi
  8001eb:	89 d6                	mov    %edx,%esi
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  8001fc:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800200:	0f 85 bf 00 00 00    	jne    8002c5 <printnum+0xe5>
  800206:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  80020c:	0f 8d de 00 00 00    	jge    8002f0 <printnum+0x110>
		judge_time_for_space = width;
  800212:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800218:	e9 d3 00 00 00       	jmp    8002f0 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80021d:	83 eb 01             	sub    $0x1,%ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f 37                	jg     80025b <printnum+0x7b>
  800224:	e9 ea 00 00 00       	jmp    800313 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800229:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80022c:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	56                   	push   %esi
  800235:	83 ec 04             	sub    $0x4,%esp
  800238:	ff 75 dc             	pushl  -0x24(%ebp)
  80023b:	ff 75 d8             	pushl  -0x28(%ebp)
  80023e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800241:	ff 75 e0             	pushl  -0x20(%ebp)
  800244:	e8 27 14 00 00       	call   801670 <__umoddi3>
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	0f be 80 00 18 80 00 	movsbl 0x801800(%eax),%eax
  800253:	50                   	push   %eax
  800254:	ff d7                	call   *%edi
  800256:	83 c4 10             	add    $0x10,%esp
  800259:	eb 16                	jmp    800271 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80025b:	83 ec 08             	sub    $0x8,%esp
  80025e:	56                   	push   %esi
  80025f:	ff 75 18             	pushl  0x18(%ebp)
  800262:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800264:	83 c4 10             	add    $0x10,%esp
  800267:	83 eb 01             	sub    $0x1,%ebx
  80026a:	75 ef                	jne    80025b <printnum+0x7b>
  80026c:	e9 a2 00 00 00       	jmp    800313 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800271:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800277:	0f 85 76 01 00 00    	jne    8003f3 <printnum+0x213>
		while(num_of_space-- > 0)
  80027d:	a1 04 20 80 00       	mov    0x802004,%eax
  800282:	8d 50 ff             	lea    -0x1(%eax),%edx
  800285:	89 15 04 20 80 00    	mov    %edx,0x802004
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 1d                	jle    8002ac <printnum+0xcc>
			putch(' ', putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	6a 20                	push   $0x20
  800295:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800297:	a1 04 20 80 00       	mov    0x802004,%eax
  80029c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80029f:	89 15 04 20 80 00    	mov    %edx,0x802004
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	7f e3                	jg     80028f <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8002ac:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8002b3:	00 00 00 
		judge_time_for_space = 0;
  8002b6:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8002bd:	00 00 00 
	}
}
  8002c0:	e9 2e 01 00 00       	jmp    8003f3 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8002d9:	83 fa 00             	cmp    $0x0,%edx
  8002dc:	0f 87 ba 00 00 00    	ja     80039c <printnum+0x1bc>
  8002e2:	3b 45 10             	cmp    0x10(%ebp),%eax
  8002e5:	0f 83 b1 00 00 00    	jae    80039c <printnum+0x1bc>
  8002eb:	e9 2d ff ff ff       	jmp    80021d <printnum+0x3d>
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800301:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800304:	83 fa 00             	cmp    $0x0,%edx
  800307:	77 37                	ja     800340 <printnum+0x160>
  800309:	3b 45 10             	cmp    0x10(%ebp),%eax
  80030c:	73 32                	jae    800340 <printnum+0x160>
  80030e:	e9 16 ff ff ff       	jmp    800229 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800313:	83 ec 08             	sub    $0x8,%esp
  800316:	56                   	push   %esi
  800317:	83 ec 04             	sub    $0x4,%esp
  80031a:	ff 75 dc             	pushl  -0x24(%ebp)
  80031d:	ff 75 d8             	pushl  -0x28(%ebp)
  800320:	ff 75 e4             	pushl  -0x1c(%ebp)
  800323:	ff 75 e0             	pushl  -0x20(%ebp)
  800326:	e8 45 13 00 00       	call   801670 <__umoddi3>
  80032b:	83 c4 14             	add    $0x14,%esp
  80032e:	0f be 80 00 18 80 00 	movsbl 0x801800(%eax),%eax
  800335:	50                   	push   %eax
  800336:	ff d7                	call   *%edi
  800338:	83 c4 10             	add    $0x10,%esp
  80033b:	e9 b3 00 00 00       	jmp    8003f3 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	ff 75 18             	pushl  0x18(%ebp)
  800346:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	83 ec 08             	sub    $0x8,%esp
  800350:	ff 75 dc             	pushl  -0x24(%ebp)
  800353:	ff 75 d8             	pushl  -0x28(%ebp)
  800356:	ff 75 e4             	pushl  -0x1c(%ebp)
  800359:	ff 75 e0             	pushl  -0x20(%ebp)
  80035c:	e8 df 11 00 00       	call   801540 <__udivdi3>
  800361:	83 c4 18             	add    $0x18,%esp
  800364:	52                   	push   %edx
  800365:	50                   	push   %eax
  800366:	89 f2                	mov    %esi,%edx
  800368:	89 f8                	mov    %edi,%eax
  80036a:	e8 71 fe ff ff       	call   8001e0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	56                   	push   %esi
  800373:	83 ec 04             	sub    $0x4,%esp
  800376:	ff 75 dc             	pushl  -0x24(%ebp)
  800379:	ff 75 d8             	pushl  -0x28(%ebp)
  80037c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80037f:	ff 75 e0             	pushl  -0x20(%ebp)
  800382:	e8 e9 12 00 00       	call   801670 <__umoddi3>
  800387:	83 c4 14             	add    $0x14,%esp
  80038a:	0f be 80 00 18 80 00 	movsbl 0x801800(%eax),%eax
  800391:	50                   	push   %eax
  800392:	ff d7                	call   *%edi
  800394:	83 c4 10             	add    $0x10,%esp
  800397:	e9 d5 fe ff ff       	jmp    800271 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 75 18             	pushl  0x18(%ebp)
  8003a2:	83 eb 01             	sub    $0x1,%ebx
  8003a5:	53                   	push   %ebx
  8003a6:	ff 75 10             	pushl  0x10(%ebp)
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8003af:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b8:	e8 83 11 00 00       	call   801540 <__udivdi3>
  8003bd:	83 c4 18             	add    $0x18,%esp
  8003c0:	52                   	push   %edx
  8003c1:	50                   	push   %eax
  8003c2:	89 f2                	mov    %esi,%edx
  8003c4:	89 f8                	mov    %edi,%eax
  8003c6:	e8 15 fe ff ff       	call   8001e0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cb:	83 c4 18             	add    $0x18,%esp
  8003ce:	56                   	push   %esi
  8003cf:	83 ec 04             	sub    $0x4,%esp
  8003d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003db:	ff 75 e0             	pushl  -0x20(%ebp)
  8003de:	e8 8d 12 00 00       	call   801670 <__umoddi3>
  8003e3:	83 c4 14             	add    $0x14,%esp
  8003e6:	0f be 80 00 18 80 00 	movsbl 0x801800(%eax),%eax
  8003ed:	50                   	push   %eax
  8003ee:	ff d7                	call   *%edi
  8003f0:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8003f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f6:	5b                   	pop    %ebx
  8003f7:	5e                   	pop    %esi
  8003f8:	5f                   	pop    %edi
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fe:	83 fa 01             	cmp    $0x1,%edx
  800401:	7e 0e                	jle    800411 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800403:	8b 10                	mov    (%eax),%edx
  800405:	8d 4a 08             	lea    0x8(%edx),%ecx
  800408:	89 08                	mov    %ecx,(%eax)
  80040a:	8b 02                	mov    (%edx),%eax
  80040c:	8b 52 04             	mov    0x4(%edx),%edx
  80040f:	eb 22                	jmp    800433 <getuint+0x38>
	else if (lflag)
  800411:	85 d2                	test   %edx,%edx
  800413:	74 10                	je     800425 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800415:	8b 10                	mov    (%eax),%edx
  800417:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041a:	89 08                	mov    %ecx,(%eax)
  80041c:	8b 02                	mov    (%edx),%eax
  80041e:	ba 00 00 00 00       	mov    $0x0,%edx
  800423:	eb 0e                	jmp    800433 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800425:	8b 10                	mov    (%eax),%edx
  800427:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042a:	89 08                	mov    %ecx,(%eax)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    

00800435 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043f:	8b 10                	mov    (%eax),%edx
  800441:	3b 50 04             	cmp    0x4(%eax),%edx
  800444:	73 0a                	jae    800450 <sprintputch+0x1b>
		*b->buf++ = ch;
  800446:	8d 4a 01             	lea    0x1(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	88 02                	mov    %al,(%edx)
}
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    

00800452 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800458:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045b:	50                   	push   %eax
  80045c:	ff 75 10             	pushl  0x10(%ebp)
  80045f:	ff 75 0c             	pushl  0xc(%ebp)
  800462:	ff 75 08             	pushl  0x8(%ebp)
  800465:	e8 05 00 00 00       	call   80046f <vprintfmt>
	va_end(ap);
}
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	c9                   	leave  
  80046e:	c3                   	ret    

0080046f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	57                   	push   %edi
  800473:	56                   	push   %esi
  800474:	53                   	push   %ebx
  800475:	83 ec 2c             	sub    $0x2c,%esp
  800478:	8b 7d 08             	mov    0x8(%ebp),%edi
  80047b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047e:	eb 03                	jmp    800483 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800480:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800483:	8b 45 10             	mov    0x10(%ebp),%eax
  800486:	8d 70 01             	lea    0x1(%eax),%esi
  800489:	0f b6 00             	movzbl (%eax),%eax
  80048c:	83 f8 25             	cmp    $0x25,%eax
  80048f:	74 27                	je     8004b8 <vprintfmt+0x49>
			if (ch == '\0')
  800491:	85 c0                	test   %eax,%eax
  800493:	75 0d                	jne    8004a2 <vprintfmt+0x33>
  800495:	e9 9d 04 00 00       	jmp    800937 <vprintfmt+0x4c8>
  80049a:	85 c0                	test   %eax,%eax
  80049c:	0f 84 95 04 00 00    	je     800937 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	50                   	push   %eax
  8004a7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a9:	83 c6 01             	add    $0x1,%esi
  8004ac:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	83 f8 25             	cmp    $0x25,%eax
  8004b6:	75 e2                	jne    80049a <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004bd:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004c1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004c8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004cf:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004d6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004dd:	eb 08                	jmp    8004e7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8004e2:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8d 46 01             	lea    0x1(%esi),%eax
  8004ea:	89 45 10             	mov    %eax,0x10(%ebp)
  8004ed:	0f b6 06             	movzbl (%esi),%eax
  8004f0:	0f b6 d0             	movzbl %al,%edx
  8004f3:	83 e8 23             	sub    $0x23,%eax
  8004f6:	3c 55                	cmp    $0x55,%al
  8004f8:	0f 87 fa 03 00 00    	ja     8008f8 <vprintfmt+0x489>
  8004fe:	0f b6 c0             	movzbl %al,%eax
  800501:	ff 24 85 40 19 80 00 	jmp    *0x801940(,%eax,4)
  800508:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80050b:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80050f:	eb d6                	jmp    8004e7 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800511:	8d 42 d0             	lea    -0x30(%edx),%eax
  800514:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800517:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80051b:	8d 50 d0             	lea    -0x30(%eax),%edx
  80051e:	83 fa 09             	cmp    $0x9,%edx
  800521:	77 6b                	ja     80058e <vprintfmt+0x11f>
  800523:	8b 75 10             	mov    0x10(%ebp),%esi
  800526:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800529:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80052c:	eb 09                	jmp    800537 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800531:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800535:	eb b0                	jmp    8004e7 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800537:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80053a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80053d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800541:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800544:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800547:	83 f9 09             	cmp    $0x9,%ecx
  80054a:	76 eb                	jbe    800537 <vprintfmt+0xc8>
  80054c:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80054f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800552:	eb 3d                	jmp    800591 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800565:	eb 2a                	jmp    800591 <vprintfmt+0x122>
  800567:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056a:	85 c0                	test   %eax,%eax
  80056c:	ba 00 00 00 00       	mov    $0x0,%edx
  800571:	0f 49 d0             	cmovns %eax,%edx
  800574:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800577:	8b 75 10             	mov    0x10(%ebp),%esi
  80057a:	e9 68 ff ff ff       	jmp    8004e7 <vprintfmt+0x78>
  80057f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800582:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800589:	e9 59 ff ff ff       	jmp    8004e7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800591:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800595:	0f 89 4c ff ff ff    	jns    8004e7 <vprintfmt+0x78>
				width = precision, precision = -1;
  80059b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80059e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a8:	e9 3a ff ff ff       	jmp    8004e7 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ad:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005b4:	e9 2e ff ff ff       	jmp    8004e7 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 04             	lea    0x4(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	ff 30                	pushl  (%eax)
  8005c8:	ff d7                	call   *%edi
			break;
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	e9 b1 fe ff ff       	jmp    800483 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	99                   	cltd   
  8005de:	31 d0                	xor    %edx,%eax
  8005e0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e2:	83 f8 08             	cmp    $0x8,%eax
  8005e5:	7f 0b                	jg     8005f2 <vprintfmt+0x183>
  8005e7:	8b 14 85 a0 1a 80 00 	mov    0x801aa0(,%eax,4),%edx
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	75 15                	jne    800607 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8005f2:	50                   	push   %eax
  8005f3:	68 18 18 80 00       	push   $0x801818
  8005f8:	53                   	push   %ebx
  8005f9:	57                   	push   %edi
  8005fa:	e8 53 fe ff ff       	call   800452 <printfmt>
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	e9 7c fe ff ff       	jmp    800483 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800607:	52                   	push   %edx
  800608:	68 21 18 80 00       	push   $0x801821
  80060d:	53                   	push   %ebx
  80060e:	57                   	push   %edi
  80060f:	e8 3e fe ff ff       	call   800452 <printfmt>
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	e9 67 fe ff ff       	jmp    800483 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800627:	85 c0                	test   %eax,%eax
  800629:	b9 11 18 80 00       	mov    $0x801811,%ecx
  80062e:	0f 45 c8             	cmovne %eax,%ecx
  800631:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800634:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800638:	7e 06                	jle    800640 <vprintfmt+0x1d1>
  80063a:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80063e:	75 19                	jne    800659 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800640:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800643:	8d 70 01             	lea    0x1(%eax),%esi
  800646:	0f b6 00             	movzbl (%eax),%eax
  800649:	0f be d0             	movsbl %al,%edx
  80064c:	85 d2                	test   %edx,%edx
  80064e:	0f 85 9f 00 00 00    	jne    8006f3 <vprintfmt+0x284>
  800654:	e9 8c 00 00 00       	jmp    8006e5 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 d0             	pushl  -0x30(%ebp)
  80065f:	ff 75 cc             	pushl  -0x34(%ebp)
  800662:	e8 62 03 00 00       	call   8009c9 <strnlen>
  800667:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80066a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	85 c9                	test   %ecx,%ecx
  800672:	0f 8e a6 02 00 00    	jle    80091e <vprintfmt+0x4af>
					putch(padc, putdat);
  800678:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80067c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067f:	89 cb                	mov    %ecx,%ebx
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	56                   	push   %esi
  800688:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	83 eb 01             	sub    $0x1,%ebx
  800690:	75 ef                	jne    800681 <vprintfmt+0x212>
  800692:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800695:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800698:	e9 81 02 00 00       	jmp    80091e <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a1:	74 1b                	je     8006be <vprintfmt+0x24f>
  8006a3:	0f be c0             	movsbl %al,%eax
  8006a6:	83 e8 20             	sub    $0x20,%eax
  8006a9:	83 f8 5e             	cmp    $0x5e,%eax
  8006ac:	76 10                	jbe    8006be <vprintfmt+0x24f>
					putch('?', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	ff 75 0c             	pushl  0xc(%ebp)
  8006b4:	6a 3f                	push   $0x3f
  8006b6:	ff 55 08             	call   *0x8(%ebp)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 0d                	jmp    8006cb <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	52                   	push   %edx
  8006c5:	ff 55 08             	call   *0x8(%ebp)
  8006c8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cb:	83 ef 01             	sub    $0x1,%edi
  8006ce:	83 c6 01             	add    $0x1,%esi
  8006d1:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8006d5:	0f be d0             	movsbl %al,%edx
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	75 31                	jne    80070d <vprintfmt+0x29e>
  8006dc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ec:	7f 33                	jg     800721 <vprintfmt+0x2b2>
  8006ee:	e9 90 fd ff ff       	jmp    800483 <vprintfmt+0x14>
  8006f3:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006ff:	eb 0c                	jmp    80070d <vprintfmt+0x29e>
  800701:	89 7d 08             	mov    %edi,0x8(%ebp)
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070d:	85 db                	test   %ebx,%ebx
  80070f:	78 8c                	js     80069d <vprintfmt+0x22e>
  800711:	83 eb 01             	sub    $0x1,%ebx
  800714:	79 87                	jns    80069d <vprintfmt+0x22e>
  800716:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800719:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071f:	eb c4                	jmp    8006e5 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	53                   	push   %ebx
  800725:	6a 20                	push   $0x20
  800727:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	83 ee 01             	sub    $0x1,%esi
  80072f:	75 f0                	jne    800721 <vprintfmt+0x2b2>
  800731:	e9 4d fd ff ff       	jmp    800483 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800736:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80073a:	7e 16                	jle    800752 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8d 50 08             	lea    0x8(%eax),%edx
  800742:	89 55 14             	mov    %edx,0x14(%ebp)
  800745:	8b 50 04             	mov    0x4(%eax),%edx
  800748:	8b 00                	mov    (%eax),%eax
  80074a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80074d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800750:	eb 34                	jmp    800786 <vprintfmt+0x317>
	else if (lflag)
  800752:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800756:	74 18                	je     800770 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 50 04             	lea    0x4(%eax),%edx
  80075e:	89 55 14             	mov    %edx,0x14(%ebp)
  800761:	8b 30                	mov    (%eax),%esi
  800763:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800766:	89 f0                	mov    %esi,%eax
  800768:	c1 f8 1f             	sar    $0x1f,%eax
  80076b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80076e:	eb 16                	jmp    800786 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800770:	8b 45 14             	mov    0x14(%ebp),%eax
  800773:	8d 50 04             	lea    0x4(%eax),%edx
  800776:	89 55 14             	mov    %edx,0x14(%ebp)
  800779:	8b 30                	mov    (%eax),%esi
  80077b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80077e:	89 f0                	mov    %esi,%eax
  800780:	c1 f8 1f             	sar    $0x1f,%eax
  800783:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800786:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800789:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80078c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800792:	85 d2                	test   %edx,%edx
  800794:	79 28                	jns    8007be <vprintfmt+0x34f>
				putch('-', putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	53                   	push   %ebx
  80079a:	6a 2d                	push   $0x2d
  80079c:	ff d7                	call   *%edi
				num = -(long long) num;
  80079e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007a4:	f7 d8                	neg    %eax
  8007a6:	83 d2 00             	adc    $0x0,%edx
  8007a9:	f7 da                	neg    %edx
  8007ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b1:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8007b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b9:	e9 b2 00 00 00       	jmp    800870 <vprintfmt+0x401>
  8007be:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8007c3:	85 c9                	test   %ecx,%ecx
  8007c5:	0f 84 a5 00 00 00    	je     800870 <vprintfmt+0x401>
				putch('+', putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	6a 2b                	push   $0x2b
  8007d1:	ff d7                	call   *%edi
  8007d3:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8007d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007db:	e9 90 00 00 00       	jmp    800870 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8007e0:	85 c9                	test   %ecx,%ecx
  8007e2:	74 0b                	je     8007ef <vprintfmt+0x380>
				putch('+', putdat);
  8007e4:	83 ec 08             	sub    $0x8,%esp
  8007e7:	53                   	push   %ebx
  8007e8:	6a 2b                	push   $0x2b
  8007ea:	ff d7                	call   *%edi
  8007ec:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8007ef:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f5:	e8 01 fc ff ff       	call   8003fb <getuint>
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800800:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800805:	eb 69                	jmp    800870 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	6a 30                	push   $0x30
  80080d:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80080f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800812:	8d 45 14             	lea    0x14(%ebp),%eax
  800815:	e8 e1 fb ff ff       	call   8003fb <getuint>
  80081a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800820:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800823:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800828:	eb 46                	jmp    800870 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	53                   	push   %ebx
  80082e:	6a 30                	push   $0x30
  800830:	ff d7                	call   *%edi
			putch('x', putdat);
  800832:	83 c4 08             	add    $0x8,%esp
  800835:	53                   	push   %ebx
  800836:	6a 78                	push   $0x78
  800838:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8d 50 04             	lea    0x4(%eax),%edx
  800840:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800843:	8b 00                	mov    (%eax),%eax
  800845:	ba 00 00 00 00       	mov    $0x0,%edx
  80084a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800850:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800853:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800858:	eb 16                	jmp    800870 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80085a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80085d:	8d 45 14             	lea    0x14(%ebp),%eax
  800860:	e8 96 fb ff ff       	call   8003fb <getuint>
  800865:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800868:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80086b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800870:	83 ec 0c             	sub    $0xc,%esp
  800873:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800877:	56                   	push   %esi
  800878:	ff 75 e4             	pushl  -0x1c(%ebp)
  80087b:	50                   	push   %eax
  80087c:	ff 75 dc             	pushl  -0x24(%ebp)
  80087f:	ff 75 d8             	pushl  -0x28(%ebp)
  800882:	89 da                	mov    %ebx,%edx
  800884:	89 f8                	mov    %edi,%eax
  800886:	e8 55 f9 ff ff       	call   8001e0 <printnum>
			break;
  80088b:	83 c4 20             	add    $0x20,%esp
  80088e:	e9 f0 fb ff ff       	jmp    800483 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800893:	8b 45 14             	mov    0x14(%ebp),%eax
  800896:	8d 50 04             	lea    0x4(%eax),%edx
  800899:	89 55 14             	mov    %edx,0x14(%ebp)
  80089c:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  80089e:	85 f6                	test   %esi,%esi
  8008a0:	75 1a                	jne    8008bc <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8008a2:	83 ec 08             	sub    $0x8,%esp
  8008a5:	68 b8 18 80 00       	push   $0x8018b8
  8008aa:	68 21 18 80 00       	push   $0x801821
  8008af:	e8 18 f9 ff ff       	call   8001cc <cprintf>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	e9 c7 fb ff ff       	jmp    800483 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8008bc:	0f b6 03             	movzbl (%ebx),%eax
  8008bf:	84 c0                	test   %al,%al
  8008c1:	79 1f                	jns    8008e2 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	68 f0 18 80 00       	push   $0x8018f0
  8008cb:	68 21 18 80 00       	push   $0x801821
  8008d0:	e8 f7 f8 ff ff       	call   8001cc <cprintf>
						*tmp = *(char *)putdat;
  8008d5:	0f b6 03             	movzbl (%ebx),%eax
  8008d8:	88 06                	mov    %al,(%esi)
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	e9 a1 fb ff ff       	jmp    800483 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8008e2:	88 06                	mov    %al,(%esi)
  8008e4:	e9 9a fb ff ff       	jmp    800483 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	52                   	push   %edx
  8008ee:	ff d7                	call   *%edi
			break;
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	e9 8b fb ff ff       	jmp    800483 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	6a 25                	push   $0x25
  8008fe:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800907:	0f 84 73 fb ff ff    	je     800480 <vprintfmt+0x11>
  80090d:	83 ee 01             	sub    $0x1,%esi
  800910:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800914:	75 f7                	jne    80090d <vprintfmt+0x49e>
  800916:	89 75 10             	mov    %esi,0x10(%ebp)
  800919:	e9 65 fb ff ff       	jmp    800483 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80091e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800921:	8d 70 01             	lea    0x1(%eax),%esi
  800924:	0f b6 00             	movzbl (%eax),%eax
  800927:	0f be d0             	movsbl %al,%edx
  80092a:	85 d2                	test   %edx,%edx
  80092c:	0f 85 cf fd ff ff    	jne    800701 <vprintfmt+0x292>
  800932:	e9 4c fb ff ff       	jmp    800483 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800937:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	83 ec 18             	sub    $0x18,%esp
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80094b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800952:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095c:	85 c0                	test   %eax,%eax
  80095e:	74 26                	je     800986 <vsnprintf+0x47>
  800960:	85 d2                	test   %edx,%edx
  800962:	7e 22                	jle    800986 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800964:	ff 75 14             	pushl  0x14(%ebp)
  800967:	ff 75 10             	pushl  0x10(%ebp)
  80096a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80096d:	50                   	push   %eax
  80096e:	68 35 04 80 00       	push   $0x800435
  800973:	e8 f7 fa ff ff       	call   80046f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800978:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80097b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800981:	83 c4 10             	add    $0x10,%esp
  800984:	eb 05                	jmp    80098b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800986:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800993:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800996:	50                   	push   %eax
  800997:	ff 75 10             	pushl  0x10(%ebp)
  80099a:	ff 75 0c             	pushl  0xc(%ebp)
  80099d:	ff 75 08             	pushl  0x8(%ebp)
  8009a0:	e8 9a ff ff ff       	call   80093f <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ad:	80 3a 00             	cmpb   $0x0,(%edx)
  8009b0:	74 10                	je     8009c2 <strlen+0x1b>
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009b7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009be:	75 f7                	jne    8009b7 <strlen+0x10>
  8009c0:	eb 05                	jmp    8009c7 <strlen+0x20>
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d3:	85 c9                	test   %ecx,%ecx
  8009d5:	74 1c                	je     8009f3 <strnlen+0x2a>
  8009d7:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009da:	74 1e                	je     8009fa <strnlen+0x31>
  8009dc:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009e1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e3:	39 ca                	cmp    %ecx,%edx
  8009e5:	74 18                	je     8009ff <strnlen+0x36>
  8009e7:	83 c2 01             	add    $0x1,%edx
  8009ea:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009ef:	75 f0                	jne    8009e1 <strnlen+0x18>
  8009f1:	eb 0c                	jmp    8009ff <strnlen+0x36>
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	eb 05                	jmp    8009ff <strnlen+0x36>
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	53                   	push   %ebx
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a0c:	89 c2                	mov    %eax,%edx
  800a0e:	83 c2 01             	add    $0x1,%edx
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a18:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a1b:	84 db                	test   %bl,%bl
  800a1d:	75 ef                	jne    800a0e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a1f:	5b                   	pop    %ebx
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a29:	53                   	push   %ebx
  800a2a:	e8 78 ff ff ff       	call   8009a7 <strlen>
  800a2f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a32:	ff 75 0c             	pushl  0xc(%ebp)
  800a35:	01 d8                	add    %ebx,%eax
  800a37:	50                   	push   %eax
  800a38:	e8 c5 ff ff ff       	call   800a02 <strcpy>
	return dst;
}
  800a3d:	89 d8                	mov    %ebx,%eax
  800a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	74 17                	je     800a6d <strncpy+0x29>
  800a56:	01 f3                	add    %esi,%ebx
  800a58:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	0f b6 02             	movzbl (%edx),%eax
  800a60:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a63:	80 3a 01             	cmpb   $0x1,(%edx)
  800a66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a69:	39 cb                	cmp    %ecx,%ebx
  800a6b:	75 ed                	jne    800a5a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a6d:	89 f0                	mov    %esi,%eax
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7e:	8b 55 10             	mov    0x10(%ebp),%edx
  800a81:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a83:	85 d2                	test   %edx,%edx
  800a85:	74 35                	je     800abc <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a87:	89 d0                	mov    %edx,%eax
  800a89:	83 e8 01             	sub    $0x1,%eax
  800a8c:	74 25                	je     800ab3 <strlcpy+0x40>
  800a8e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a91:	84 c9                	test   %cl,%cl
  800a93:	74 22                	je     800ab7 <strlcpy+0x44>
  800a95:	8d 53 01             	lea    0x1(%ebx),%edx
  800a98:	01 c3                	add    %eax,%ebx
  800a9a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa2:	39 da                	cmp    %ebx,%edx
  800aa4:	74 13                	je     800ab9 <strlcpy+0x46>
  800aa6:	83 c2 01             	add    $0x1,%edx
  800aa9:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800aad:	84 c9                	test   %cl,%cl
  800aaf:	75 eb                	jne    800a9c <strlcpy+0x29>
  800ab1:	eb 06                	jmp    800ab9 <strlcpy+0x46>
  800ab3:	89 f0                	mov    %esi,%eax
  800ab5:	eb 02                	jmp    800ab9 <strlcpy+0x46>
  800ab7:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ab9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800abc:	29 f0                	sub    %esi,%eax
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800acb:	0f b6 01             	movzbl (%ecx),%eax
  800ace:	84 c0                	test   %al,%al
  800ad0:	74 15                	je     800ae7 <strcmp+0x25>
  800ad2:	3a 02                	cmp    (%edx),%al
  800ad4:	75 11                	jne    800ae7 <strcmp+0x25>
		p++, q++;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800adc:	0f b6 01             	movzbl (%ecx),%eax
  800adf:	84 c0                	test   %al,%al
  800ae1:	74 04                	je     800ae7 <strcmp+0x25>
  800ae3:	3a 02                	cmp    (%edx),%al
  800ae5:	74 ef                	je     800ad6 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae7:	0f b6 c0             	movzbl %al,%eax
  800aea:	0f b6 12             	movzbl (%edx),%edx
  800aed:	29 d0                	sub    %edx,%eax
}
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afc:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800aff:	85 f6                	test   %esi,%esi
  800b01:	74 29                	je     800b2c <strncmp+0x3b>
  800b03:	0f b6 03             	movzbl (%ebx),%eax
  800b06:	84 c0                	test   %al,%al
  800b08:	74 30                	je     800b3a <strncmp+0x49>
  800b0a:	3a 02                	cmp    (%edx),%al
  800b0c:	75 2c                	jne    800b3a <strncmp+0x49>
  800b0e:	8d 43 01             	lea    0x1(%ebx),%eax
  800b11:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b13:	89 c3                	mov    %eax,%ebx
  800b15:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b18:	39 c6                	cmp    %eax,%esi
  800b1a:	74 17                	je     800b33 <strncmp+0x42>
  800b1c:	0f b6 08             	movzbl (%eax),%ecx
  800b1f:	84 c9                	test   %cl,%cl
  800b21:	74 17                	je     800b3a <strncmp+0x49>
  800b23:	83 c0 01             	add    $0x1,%eax
  800b26:	3a 0a                	cmp    (%edx),%cl
  800b28:	74 e9                	je     800b13 <strncmp+0x22>
  800b2a:	eb 0e                	jmp    800b3a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b31:	eb 0f                	jmp    800b42 <strncmp+0x51>
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
  800b38:	eb 08                	jmp    800b42 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3a:	0f b6 03             	movzbl (%ebx),%eax
  800b3d:	0f b6 12             	movzbl (%edx),%edx
  800b40:	29 d0                	sub    %edx,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	53                   	push   %ebx
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b50:	0f b6 10             	movzbl (%eax),%edx
  800b53:	84 d2                	test   %dl,%dl
  800b55:	74 1d                	je     800b74 <strchr+0x2e>
  800b57:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b59:	38 d3                	cmp    %dl,%bl
  800b5b:	75 06                	jne    800b63 <strchr+0x1d>
  800b5d:	eb 1a                	jmp    800b79 <strchr+0x33>
  800b5f:	38 ca                	cmp    %cl,%dl
  800b61:	74 16                	je     800b79 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b63:	83 c0 01             	add    $0x1,%eax
  800b66:	0f b6 10             	movzbl (%eax),%edx
  800b69:	84 d2                	test   %dl,%dl
  800b6b:	75 f2                	jne    800b5f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	eb 05                	jmp    800b79 <strchr+0x33>
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	53                   	push   %ebx
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b86:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b89:	38 d3                	cmp    %dl,%bl
  800b8b:	74 14                	je     800ba1 <strfind+0x25>
  800b8d:	89 d1                	mov    %edx,%ecx
  800b8f:	84 db                	test   %bl,%bl
  800b91:	74 0e                	je     800ba1 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b93:	83 c0 01             	add    $0x1,%eax
  800b96:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b99:	38 ca                	cmp    %cl,%dl
  800b9b:	74 04                	je     800ba1 <strfind+0x25>
  800b9d:	84 d2                	test   %dl,%dl
  800b9f:	75 f2                	jne    800b93 <strfind+0x17>
			break;
	return (char *) s;
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb0:	85 c9                	test   %ecx,%ecx
  800bb2:	74 36                	je     800bea <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 28                	jne    800be4 <memset+0x40>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 23                	jne    800be4 <memset+0x40>
		c &= 0xFF;
  800bc1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	c1 e3 08             	shl    $0x8,%ebx
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	c1 e6 18             	shl    $0x18,%esi
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	c1 e0 10             	shl    $0x10,%eax
  800bd4:	09 f0                	or     %esi,%eax
  800bd6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bd8:	89 d8                	mov    %ebx,%eax
  800bda:	09 d0                	or     %edx,%eax
  800bdc:	c1 e9 02             	shr    $0x2,%ecx
  800bdf:	fc                   	cld    
  800be0:	f3 ab                	rep stos %eax,%es:(%edi)
  800be2:	eb 06                	jmp    800bea <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be7:	fc                   	cld    
  800be8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bea:	89 f8                	mov    %edi,%eax
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bff:	39 c6                	cmp    %eax,%esi
  800c01:	73 35                	jae    800c38 <memmove+0x47>
  800c03:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c06:	39 d0                	cmp    %edx,%eax
  800c08:	73 2e                	jae    800c38 <memmove+0x47>
		s += n;
		d += n;
  800c0a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	09 fe                	or     %edi,%esi
  800c11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c17:	75 13                	jne    800c2c <memmove+0x3b>
  800c19:	f6 c1 03             	test   $0x3,%cl
  800c1c:	75 0e                	jne    800c2c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c1e:	83 ef 04             	sub    $0x4,%edi
  800c21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c24:	c1 e9 02             	shr    $0x2,%ecx
  800c27:	fd                   	std    
  800c28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2a:	eb 09                	jmp    800c35 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2c:	83 ef 01             	sub    $0x1,%edi
  800c2f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c32:	fd                   	std    
  800c33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c35:	fc                   	cld    
  800c36:	eb 1d                	jmp    800c55 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c38:	89 f2                	mov    %esi,%edx
  800c3a:	09 c2                	or     %eax,%edx
  800c3c:	f6 c2 03             	test   $0x3,%dl
  800c3f:	75 0f                	jne    800c50 <memmove+0x5f>
  800c41:	f6 c1 03             	test   $0x3,%cl
  800c44:	75 0a                	jne    800c50 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c46:	c1 e9 02             	shr    $0x2,%ecx
  800c49:	89 c7                	mov    %eax,%edi
  800c4b:	fc                   	cld    
  800c4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4e:	eb 05                	jmp    800c55 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	fc                   	cld    
  800c53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c5c:	ff 75 10             	pushl  0x10(%ebp)
  800c5f:	ff 75 0c             	pushl  0xc(%ebp)
  800c62:	ff 75 08             	pushl  0x8(%ebp)
  800c65:	e8 87 ff ff ff       	call   800bf1 <memmove>
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	74 39                	je     800cb8 <memcmp+0x4c>
  800c7f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c82:	0f b6 13             	movzbl (%ebx),%edx
  800c85:	0f b6 0e             	movzbl (%esi),%ecx
  800c88:	38 ca                	cmp    %cl,%dl
  800c8a:	75 17                	jne    800ca3 <memcmp+0x37>
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c91:	eb 1a                	jmp    800cad <memcmp+0x41>
  800c93:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c98:	83 c0 01             	add    $0x1,%eax
  800c9b:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c9f:	38 ca                	cmp    %cl,%dl
  800ca1:	74 0a                	je     800cad <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ca3:	0f b6 c2             	movzbl %dl,%eax
  800ca6:	0f b6 c9             	movzbl %cl,%ecx
  800ca9:	29 c8                	sub    %ecx,%eax
  800cab:	eb 10                	jmp    800cbd <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cad:	39 f8                	cmp    %edi,%eax
  800caf:	75 e2                	jne    800c93 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	eb 05                	jmp    800cbd <memcmp+0x51>
  800cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	53                   	push   %ebx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800cc9:	89 d0                	mov    %edx,%eax
  800ccb:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800cce:	39 c2                	cmp    %eax,%edx
  800cd0:	73 1d                	jae    800cef <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800cd6:	0f b6 0a             	movzbl (%edx),%ecx
  800cd9:	39 d9                	cmp    %ebx,%ecx
  800cdb:	75 09                	jne    800ce6 <memfind+0x24>
  800cdd:	eb 14                	jmp    800cf3 <memfind+0x31>
  800cdf:	0f b6 0a             	movzbl (%edx),%ecx
  800ce2:	39 d9                	cmp    %ebx,%ecx
  800ce4:	74 11                	je     800cf7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce6:	83 c2 01             	add    $0x1,%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	75 f2                	jne    800cdf <memfind+0x1d>
  800ced:	eb 0a                	jmp    800cf9 <memfind+0x37>
  800cef:	89 d0                	mov    %edx,%eax
  800cf1:	eb 06                	jmp    800cf9 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf3:	89 d0                	mov    %edx,%eax
  800cf5:	eb 02                	jmp    800cf9 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cf7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d08:	0f b6 01             	movzbl (%ecx),%eax
  800d0b:	3c 20                	cmp    $0x20,%al
  800d0d:	74 04                	je     800d13 <strtol+0x17>
  800d0f:	3c 09                	cmp    $0x9,%al
  800d11:	75 0e                	jne    800d21 <strtol+0x25>
		s++;
  800d13:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d16:	0f b6 01             	movzbl (%ecx),%eax
  800d19:	3c 20                	cmp    $0x20,%al
  800d1b:	74 f6                	je     800d13 <strtol+0x17>
  800d1d:	3c 09                	cmp    $0x9,%al
  800d1f:	74 f2                	je     800d13 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d21:	3c 2b                	cmp    $0x2b,%al
  800d23:	75 0a                	jne    800d2f <strtol+0x33>
		s++;
  800d25:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d28:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2d:	eb 11                	jmp    800d40 <strtol+0x44>
  800d2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d34:	3c 2d                	cmp    $0x2d,%al
  800d36:	75 08                	jne    800d40 <strtol+0x44>
		s++, neg = 1;
  800d38:	83 c1 01             	add    $0x1,%ecx
  800d3b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d46:	75 15                	jne    800d5d <strtol+0x61>
  800d48:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4b:	75 10                	jne    800d5d <strtol+0x61>
  800d4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d51:	75 7c                	jne    800dcf <strtol+0xd3>
		s += 2, base = 16;
  800d53:	83 c1 02             	add    $0x2,%ecx
  800d56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d5b:	eb 16                	jmp    800d73 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d5d:	85 db                	test   %ebx,%ebx
  800d5f:	75 12                	jne    800d73 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d61:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d66:	80 39 30             	cmpb   $0x30,(%ecx)
  800d69:	75 08                	jne    800d73 <strtol+0x77>
		s++, base = 8;
  800d6b:	83 c1 01             	add    $0x1,%ecx
  800d6e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d7b:	0f b6 11             	movzbl (%ecx),%edx
  800d7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d81:	89 f3                	mov    %esi,%ebx
  800d83:	80 fb 09             	cmp    $0x9,%bl
  800d86:	77 08                	ja     800d90 <strtol+0x94>
			dig = *s - '0';
  800d88:	0f be d2             	movsbl %dl,%edx
  800d8b:	83 ea 30             	sub    $0x30,%edx
  800d8e:	eb 22                	jmp    800db2 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d90:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d93:	89 f3                	mov    %esi,%ebx
  800d95:	80 fb 19             	cmp    $0x19,%bl
  800d98:	77 08                	ja     800da2 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d9a:	0f be d2             	movsbl %dl,%edx
  800d9d:	83 ea 57             	sub    $0x57,%edx
  800da0:	eb 10                	jmp    800db2 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800da2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800da5:	89 f3                	mov    %esi,%ebx
  800da7:	80 fb 19             	cmp    $0x19,%bl
  800daa:	77 16                	ja     800dc2 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800dac:	0f be d2             	movsbl %dl,%edx
  800daf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800db2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800db5:	7d 0b                	jge    800dc2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800db7:	83 c1 01             	add    $0x1,%ecx
  800dba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dbe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800dc0:	eb b9                	jmp    800d7b <strtol+0x7f>

	if (endptr)
  800dc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc6:	74 0d                	je     800dd5 <strtol+0xd9>
		*endptr = (char *) s;
  800dc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcb:	89 0e                	mov    %ecx,(%esi)
  800dcd:	eb 06                	jmp    800dd5 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dcf:	85 db                	test   %ebx,%ebx
  800dd1:	74 98                	je     800d6b <strtol+0x6f>
  800dd3:	eb 9e                	jmp    800d73 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	f7 da                	neg    %edx
  800dd9:	85 ff                	test   %edi,%edi
  800ddb:	0f 45 c2             	cmovne %edx,%eax
}
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800de8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 c3                	mov    %eax,%ebx
  800df5:	89 c7                	mov    %eax,%edi
  800df7:	51                   	push   %ecx
  800df8:	52                   	push   %edx
  800df9:	53                   	push   %ebx
  800dfa:	56                   	push   %esi
  800dfb:	57                   	push   %edi
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	8d 35 07 0e 80 00    	lea    0x800e07,%esi
  800e05:	0f 34                	sysenter 

00800e07 <label_21>:
  800e07:	89 ec                	mov    %ebp,%esp
  800e09:	5d                   	pop    %ebp
  800e0a:	5f                   	pop    %edi
  800e0b:	5e                   	pop    %esi
  800e0c:	5b                   	pop    %ebx
  800e0d:	5a                   	pop    %edx
  800e0e:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e0f:	5b                   	pop    %ebx
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_cgetc>:

int
sys_cgetc(void)
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
  800e1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e22:	89 ca                	mov    %ecx,%edx
  800e24:	89 cb                	mov    %ecx,%ebx
  800e26:	89 cf                	mov    %ecx,%edi
  800e28:	51                   	push   %ecx
  800e29:	52                   	push   %edx
  800e2a:	53                   	push   %ebx
  800e2b:	56                   	push   %esi
  800e2c:	57                   	push   %edi
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	8d 35 38 0e 80 00    	lea    0x800e38,%esi
  800e36:	0f 34                	sysenter 

00800e38 <label_55>:
  800e38:	89 ec                	mov    %ebp,%esp
  800e3a:	5d                   	pop    %ebp
  800e3b:	5f                   	pop    %edi
  800e3c:	5e                   	pop    %esi
  800e3d:	5b                   	pop    %ebx
  800e3e:	5a                   	pop    %edx
  800e3f:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e40:	5b                   	pop    %ebx
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800e49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	89 d9                	mov    %ebx,%ecx
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	51                   	push   %ecx
  800e5b:	52                   	push   %edx
  800e5c:	53                   	push   %ebx
  800e5d:	56                   	push   %esi
  800e5e:	57                   	push   %edi
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	8d 35 6a 0e 80 00    	lea    0x800e6a,%esi
  800e68:	0f 34                	sysenter 

00800e6a <label_90>:
  800e6a:	89 ec                	mov    %ebp,%esp
  800e6c:	5d                   	pop    %ebp
  800e6d:	5f                   	pop    %edi
  800e6e:	5e                   	pop    %esi
  800e6f:	5b                   	pop    %ebx
  800e70:	5a                   	pop    %edx
  800e71:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 17                	jle    800e8d <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	83 ec 0c             	sub    $0xc,%esp
  800e79:	50                   	push   %eax
  800e7a:	6a 03                	push   $0x3
  800e7c:	68 c4 1a 80 00       	push   $0x801ac4
  800e81:	6a 30                	push   $0x30
  800e83:	68 e1 1a 80 00       	push   $0x801ae1
  800e88:	e8 d1 05 00 00       	call   80145e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea3:	89 ca                	mov    %ecx,%edx
  800ea5:	89 cb                	mov    %ecx,%ebx
  800ea7:	89 cf                	mov    %ecx,%edi
  800ea9:	51                   	push   %ecx
  800eaa:	52                   	push   %edx
  800eab:	53                   	push   %ebx
  800eac:	56                   	push   %esi
  800ead:	57                   	push   %edi
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	8d 35 b9 0e 80 00    	lea    0x800eb9,%esi
  800eb7:	0f 34                	sysenter 

00800eb9 <label_139>:
  800eb9:	89 ec                	mov    %ebp,%esp
  800ebb:	5d                   	pop    %ebp
  800ebc:	5f                   	pop    %edi
  800ebd:	5e                   	pop    %esi
  800ebe:	5b                   	pop    %ebx
  800ebf:	5a                   	pop    %edx
  800ec0:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eca:	bf 00 00 00 00       	mov    $0x0,%edi
  800ecf:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eda:	89 fb                	mov    %edi,%ebx
  800edc:	51                   	push   %ecx
  800edd:	52                   	push   %edx
  800ede:	53                   	push   %ebx
  800edf:	56                   	push   %esi
  800ee0:	57                   	push   %edi
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	8d 35 ec 0e 80 00    	lea    0x800eec,%esi
  800eea:	0f 34                	sysenter 

00800eec <label_174>:
  800eec:	89 ec                	mov    %ebp,%esp
  800eee:	5d                   	pop    %ebp
  800eef:	5f                   	pop    %edi
  800ef0:	5e                   	pop    %esi
  800ef1:	5b                   	pop    %ebx
  800ef2:	5a                   	pop    %edx
  800ef3:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ef4:	5b                   	pop    %ebx
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <sys_yield>:

void
sys_yield(void)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800efd:	ba 00 00 00 00       	mov    $0x0,%edx
  800f02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f07:	89 d1                	mov    %edx,%ecx
  800f09:	89 d3                	mov    %edx,%ebx
  800f0b:	89 d7                	mov    %edx,%edi
  800f0d:	51                   	push   %ecx
  800f0e:	52                   	push   %edx
  800f0f:	53                   	push   %ebx
  800f10:	56                   	push   %esi
  800f11:	57                   	push   %edi
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	8d 35 1d 0f 80 00    	lea    0x800f1d,%esi
  800f1b:	0f 34                	sysenter 

00800f1d <label_209>:
  800f1d:	89 ec                	mov    %ebp,%esp
  800f1f:	5d                   	pop    %ebp
  800f20:	5f                   	pop    %edi
  800f21:	5e                   	pop    %esi
  800f22:	5b                   	pop    %ebx
  800f23:	5a                   	pop    %edx
  800f24:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f25:	5b                   	pop    %ebx
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f33:	b8 05 00 00 00       	mov    $0x5,%eax
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f41:	51                   	push   %ecx
  800f42:	52                   	push   %edx
  800f43:	53                   	push   %ebx
  800f44:	56                   	push   %esi
  800f45:	57                   	push   %edi
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	8d 35 51 0f 80 00    	lea    0x800f51,%esi
  800f4f:	0f 34                	sysenter 

00800f51 <label_244>:
  800f51:	89 ec                	mov    %ebp,%esp
  800f53:	5d                   	pop    %ebp
  800f54:	5f                   	pop    %edi
  800f55:	5e                   	pop    %esi
  800f56:	5b                   	pop    %ebx
  800f57:	5a                   	pop    %edx
  800f58:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	7e 17                	jle    800f74 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	50                   	push   %eax
  800f61:	6a 05                	push   $0x5
  800f63:	68 c4 1a 80 00       	push   $0x801ac4
  800f68:	6a 30                	push   $0x30
  800f6a:	68 e1 1a 80 00       	push   $0x801ae1
  800f6f:	e8 ea 04 00 00       	call   80145e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	57                   	push   %edi
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800f89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800f8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f92:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800f95:	8b 45 14             	mov    0x14(%ebp),%eax
  800f98:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800f9b:	8b 45 18             	mov    0x18(%ebp),%eax
  800f9e:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fa1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800fa4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa9:	b8 06 00 00 00       	mov    $0x6,%eax
  800fae:	89 cb                	mov    %ecx,%ebx
  800fb0:	89 cf                	mov    %ecx,%edi
  800fb2:	51                   	push   %ecx
  800fb3:	52                   	push   %edx
  800fb4:	53                   	push   %ebx
  800fb5:	56                   	push   %esi
  800fb6:	57                   	push   %edi
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	8d 35 c2 0f 80 00    	lea    0x800fc2,%esi
  800fc0:	0f 34                	sysenter 

00800fc2 <label_304>:
  800fc2:	89 ec                	mov    %ebp,%esp
  800fc4:	5d                   	pop    %ebp
  800fc5:	5f                   	pop    %edi
  800fc6:	5e                   	pop    %esi
  800fc7:	5b                   	pop    %ebx
  800fc8:	5a                   	pop    %edx
  800fc9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 17                	jle    800fe5 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	50                   	push   %eax
  800fd2:	6a 06                	push   $0x6
  800fd4:	68 c4 1a 80 00       	push   $0x801ac4
  800fd9:	6a 30                	push   $0x30
  800fdb:	68 e1 1a 80 00       	push   $0x801ae1
  800fe0:	e8 79 04 00 00       	call   80145e <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  800fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800ff6:	b8 07 00 00 00       	mov    $0x7,%eax
  800ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	89 fb                	mov    %edi,%ebx
  801003:	51                   	push   %ecx
  801004:	52                   	push   %edx
  801005:	53                   	push   %ebx
  801006:	56                   	push   %esi
  801007:	57                   	push   %edi
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	8d 35 13 10 80 00    	lea    0x801013,%esi
  801011:	0f 34                	sysenter 

00801013 <label_353>:
  801013:	89 ec                	mov    %ebp,%esp
  801015:	5d                   	pop    %ebp
  801016:	5f                   	pop    %edi
  801017:	5e                   	pop    %esi
  801018:	5b                   	pop    %ebx
  801019:	5a                   	pop    %edx
  80101a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	7e 17                	jle    801036 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	50                   	push   %eax
  801023:	6a 07                	push   $0x7
  801025:	68 c4 1a 80 00       	push   $0x801ac4
  80102a:	6a 30                	push   $0x30
  80102c:	68 e1 1a 80 00       	push   $0x801ae1
  801031:	e8 28 04 00 00       	call   80145e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801036:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801039:	5b                   	pop    %ebx
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  801042:	bf 00 00 00 00       	mov    $0x0,%edi
  801047:	b8 09 00 00 00       	mov    $0x9,%eax
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104f:	8b 55 08             	mov    0x8(%ebp),%edx
  801052:	89 fb                	mov    %edi,%ebx
  801054:	51                   	push   %ecx
  801055:	52                   	push   %edx
  801056:	53                   	push   %ebx
  801057:	56                   	push   %esi
  801058:	57                   	push   %edi
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	8d 35 64 10 80 00    	lea    0x801064,%esi
  801062:	0f 34                	sysenter 

00801064 <label_402>:
  801064:	89 ec                	mov    %ebp,%esp
  801066:	5d                   	pop    %ebp
  801067:	5f                   	pop    %edi
  801068:	5e                   	pop    %esi
  801069:	5b                   	pop    %ebx
  80106a:	5a                   	pop    %edx
  80106b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80106c:	85 c0                	test   %eax,%eax
  80106e:	7e 17                	jle    801087 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	50                   	push   %eax
  801074:	6a 09                	push   $0x9
  801076:	68 c4 1a 80 00       	push   $0x801ac4
  80107b:	6a 30                	push   $0x30
  80107d:	68 e1 1a 80 00       	push   $0x801ae1
  801082:	e8 d7 03 00 00       	call   80145e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108a:	5b                   	pop    %ebx
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  801093:	bf 00 00 00 00       	mov    $0x0,%edi
  801098:	b8 0a 00 00 00       	mov    $0xa,%eax
  80109d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a3:	89 fb                	mov    %edi,%ebx
  8010a5:	51                   	push   %ecx
  8010a6:	52                   	push   %edx
  8010a7:	53                   	push   %ebx
  8010a8:	56                   	push   %esi
  8010a9:	57                   	push   %edi
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	8d 35 b5 10 80 00    	lea    0x8010b5,%esi
  8010b3:	0f 34                	sysenter 

008010b5 <label_451>:
  8010b5:	89 ec                	mov    %ebp,%esp
  8010b7:	5d                   	pop    %ebp
  8010b8:	5f                   	pop    %edi
  8010b9:	5e                   	pop    %esi
  8010ba:	5b                   	pop    %ebx
  8010bb:	5a                   	pop    %edx
  8010bc:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	7e 17                	jle    8010d8 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	50                   	push   %eax
  8010c5:	6a 0a                	push   $0xa
  8010c7:	68 c4 1a 80 00       	push   $0x801ac4
  8010cc:	6a 30                	push   $0x30
  8010ce:	68 e1 1a 80 00       	push   $0x801ae1
  8010d3:	e8 86 03 00 00       	call   80145e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f5:	51                   	push   %ecx
  8010f6:	52                   	push   %edx
  8010f7:	53                   	push   %ebx
  8010f8:	56                   	push   %esi
  8010f9:	57                   	push   %edi
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	8d 35 05 11 80 00    	lea    0x801105,%esi
  801103:	0f 34                	sysenter 

00801105 <label_502>:
  801105:	89 ec                	mov    %ebp,%esp
  801107:	5d                   	pop    %ebp
  801108:	5f                   	pop    %edi
  801109:	5e                   	pop    %esi
  80110a:	5b                   	pop    %ebx
  80110b:	5a                   	pop    %edx
  80110c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80110d:	5b                   	pop    %ebx
  80110e:	5f                   	pop    %edi
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	57                   	push   %edi
  801115:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801116:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801120:	8b 55 08             	mov    0x8(%ebp),%edx
  801123:	89 d9                	mov    %ebx,%ecx
  801125:	89 df                	mov    %ebx,%edi
  801127:	51                   	push   %ecx
  801128:	52                   	push   %edx
  801129:	53                   	push   %ebx
  80112a:	56                   	push   %esi
  80112b:	57                   	push   %edi
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	8d 35 37 11 80 00    	lea    0x801137,%esi
  801135:	0f 34                	sysenter 

00801137 <label_537>:
  801137:	89 ec                	mov    %ebp,%esp
  801139:	5d                   	pop    %ebp
  80113a:	5f                   	pop    %edi
  80113b:	5e                   	pop    %esi
  80113c:	5b                   	pop    %ebx
  80113d:	5a                   	pop    %edx
  80113e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80113f:	85 c0                	test   %eax,%eax
  801141:	7e 17                	jle    80115a <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801143:	83 ec 0c             	sub    $0xc,%esp
  801146:	50                   	push   %eax
  801147:	6a 0d                	push   $0xd
  801149:	68 c4 1a 80 00       	push   $0x801ac4
  80114e:	6a 30                	push   $0x30
  801150:	68 e1 1a 80 00       	push   $0x801ae1
  801155:	e8 04 03 00 00       	call   80145e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80115a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	57                   	push   %edi
  801165:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801166:	b9 00 00 00 00       	mov    $0x0,%ecx
  80116b:	b8 0e 00 00 00       	mov    $0xe,%eax
  801170:	8b 55 08             	mov    0x8(%ebp),%edx
  801173:	89 cb                	mov    %ecx,%ebx
  801175:	89 cf                	mov    %ecx,%edi
  801177:	51                   	push   %ecx
  801178:	52                   	push   %edx
  801179:	53                   	push   %ebx
  80117a:	56                   	push   %esi
  80117b:	57                   	push   %edi
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	8d 35 87 11 80 00    	lea    0x801187,%esi
  801185:	0f 34                	sysenter 

00801187 <label_586>:
  801187:	89 ec                	mov    %ebp,%esp
  801189:	5d                   	pop    %ebp
  80118a:	5f                   	pop    %edi
  80118b:	5e                   	pop    %esi
  80118c:	5b                   	pop    %ebx
  80118d:	5a                   	pop    %edx
  80118e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80118f:	5b                   	pop    %ebx
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	53                   	push   %ebx
  801197:	83 ec 04             	sub    $0x4,%esp
  80119a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80119d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(vpd[PDX(addr)] & PTE_P) || !(vpt[PGNUM(addr)] & PTE_COW)) {
  80119f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011a3:	74 21                	je     8011c6 <pgfault+0x33>
  8011a5:	89 d8                	mov    %ebx,%eax
  8011a7:	c1 e8 16             	shr    $0x16,%eax
  8011aa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b1:	a8 01                	test   $0x1,%al
  8011b3:	74 11                	je     8011c6 <pgfault+0x33>
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	c1 e8 0c             	shr    $0xc,%eax
  8011ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c1:	f6 c4 08             	test   $0x8,%ah
  8011c4:	75 14                	jne    8011da <pgfault+0x47>
		panic("Faulting access is not a write to COW page.");
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	68 f0 1a 80 00       	push   $0x801af0
  8011ce:	6a 1d                	push   $0x1d
  8011d0:	68 fa 1b 80 00       	push   $0x801bfa
  8011d5:	e8 84 02 00 00       	call   80145e <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_U | PTE_W | PTE_P);
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	6a 07                	push   $0x7
  8011df:	68 00 f0 7f 00       	push   $0x7ff000
  8011e4:	6a 00                	push   $0x0
  8011e6:	e8 3e fd ff ff       	call   800f29 <sys_page_alloc>
	if (r) {
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	74 12                	je     801204 <pgfault+0x71>
		panic("pgfault alloc new page failed %e", r);
  8011f2:	50                   	push   %eax
  8011f3:	68 1c 1b 80 00       	push   $0x801b1c
  8011f8:	6a 2a                	push   $0x2a
  8011fa:	68 fa 1b 80 00       	push   $0x801bfa
  8011ff:	e8 5a 02 00 00       	call   80145e <_panic>
	}
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801204:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	68 00 10 00 00       	push   $0x1000
  801212:	53                   	push   %ebx
  801213:	68 00 f0 7f 00       	push   $0x7ff000
  801218:	e8 d4 f9 ff ff       	call   800bf1 <memmove>
	r = sys_page_map(0, (void *)PFTEMP,
  80121d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801224:	53                   	push   %ebx
  801225:	6a 00                	push   $0x0
  801227:	68 00 f0 7f 00       	push   $0x7ff000
  80122c:	6a 00                	push   $0x0
  80122e:	e8 48 fd ff ff       	call   800f7b <sys_page_map>
				0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_W | PTE_P);
	if (r) {
  801233:	83 c4 20             	add    $0x20,%esp
  801236:	85 c0                	test   %eax,%eax
  801238:	74 12                	je     80124c <pgfault+0xb9>
		panic("pgfault map pages failed %e", r);
  80123a:	50                   	push   %eax
  80123b:	68 05 1c 80 00       	push   $0x801c05
  801240:	6a 30                	push   $0x30
  801242:	68 fa 1b 80 00       	push   $0x801bfa
  801247:	e8 12 02 00 00       	call   80145e <_panic>
	}
	// panic("pgfault not implemented");
}
  80124c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	57                   	push   %edi
  801255:	56                   	push   %esi
  801256:	53                   	push   %ebx
  801257:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80125a:	68 93 11 80 00       	push   $0x801193
  80125f:	e8 5a 02 00 00       	call   8014be <set_pgfault_handler>
	// 	: "a" (SYS_exofork),
	// 	  "i" (T_SYSCALL)
	// );
	// return ret;
	envid_t ret;
	asm volatile("pushl %%ecx\n\t"
  801264:	b8 08 00 00 00       	mov    $0x8,%eax
  801269:	51                   	push   %ecx
  80126a:	52                   	push   %edx
  80126b:	53                   	push   %ebx
  80126c:	56                   	push   %esi
  80126d:	57                   	push   %edi
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	8d 35 79 12 80 00    	lea    0x801279,%esi
  801277:	0f 34                	sysenter 

00801279 <label_116>:
  801279:	89 ec                	mov    %ebp,%esp
  80127b:	5d                   	pop    %ebp
  80127c:	5f                   	pop    %edi
  80127d:	5e                   	pop    %esi
  80127e:	5b                   	pop    %ebx
  80127f:	5a                   	pop    %edx
  801280:	59                   	pop    %ecx
  801281:	89 c7                	mov    %eax,%edi
  801283:	89 45 e4             	mov    %eax,-0x1c(%ebp)
							: "=a" (ret)
							: "a" (SYS_exofork),
								"i" (T_SYSCALL)
							: "cc", "memory");

	if(ret == -E_NO_FREE_ENV || ret == -E_NO_MEM)
  801286:	8d 40 05             	lea    0x5(%eax),%eax
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	83 f8 01             	cmp    $0x1,%eax
  80128f:	77 17                	ja     8012a8 <label_116+0x2f>
		panic("syscall %d returned %d (> 0)", SYS_exofork, ret);
  801291:	83 ec 0c             	sub    $0xc,%esp
  801294:	57                   	push   %edi
  801295:	6a 08                	push   $0x8
  801297:	68 c4 1a 80 00       	push   $0x801ac4
  80129c:	6a 62                	push   $0x62
  80129e:	68 21 1c 80 00       	push   $0x801c21
  8012a3:	e8 b6 01 00 00       	call   80145e <_panic>

	int r;
	envid_t child_id;
	child_id = sys_exofork();
	if (child_id < 0) {
  8012a8:	85 ff                	test   %edi,%edi
  8012aa:	0f 88 83 01 00 00    	js     801433 <label_116+0x1ba>
  8012b0:	bb 00 08 00 00       	mov    $0x800,%ebx
		return -1;
	} else if (!child_id) {
  8012b5:	85 ff                	test   %edi,%edi
  8012b7:	75 21                	jne    8012da <label_116+0x61>
		thisenv = &envs[ENVX(sys_getenvid())];
  8012b9:	e8 d6 fb ff ff       	call   800e94 <sys_getenvid>
  8012be:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012c3:	c1 e0 07             	shl    $0x7,%eax
  8012c6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012cb:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d5:	e9 62 01 00 00       	jmp    80143c <label_116+0x1c3>
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
			if ((vpd[pn / NPTENTRIES] & PTE_P) &&
  8012da:	89 d8                	mov    %ebx,%eax
  8012dc:	c1 e8 0a             	shr    $0xa,%eax
  8012df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e6:	a8 01                	test   $0x1,%al
  8012e8:	0f 84 b9 00 00 00    	je     8013a7 <label_116+0x12e>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
  8012ee:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
			if ((vpd[pn / NPTENTRIES] & PTE_P) &&
  8012f5:	a8 01                	test   $0x1,%al
  8012f7:	0f 84 aa 00 00 00    	je     8013a7 <label_116+0x12e>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
  8012fd:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801304:	a8 04                	test   $0x4,%al
  801306:	0f 84 9b 00 00 00    	je     8013a7 <label_116+0x12e>
  80130c:	89 de                	mov    %ebx,%esi
  80130e:	c1 e6 0c             	shl    $0xc,%esi
	int r;

	// LAB 4: Your code here.
	int perm = PTE_U | PTE_P;
	void *pn_addr = (void *)(pn * PGSIZE);
	pte_t pte = vpt[PGNUM(pn_addr)];
  801311:	89 f0                	mov    %esi,%eax
  801313:	c1 e8 0c             	shr    $0xc,%eax
  801316:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if ((pte & PTE_COW) || (pte & PTE_W)) {
  80131d:	a9 02 08 00 00       	test   $0x802,%eax
  801322:	74 59                	je     80137d <label_116+0x104>
		perm |= PTE_COW;
		r = sys_page_map(0, pn_addr, envid, pn_addr, perm);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	68 05 08 00 00       	push   $0x805
  80132c:	56                   	push   %esi
  80132d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801330:	56                   	push   %esi
  801331:	6a 00                	push   $0x0
  801333:	e8 43 fc ff ff       	call   800f7b <sys_page_map>
		if (r) {
  801338:	83 c4 20             	add    $0x20,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	74 12                	je     801351 <label_116+0xd8>
			panic("duppage sys_page_map 1/2 failed %e", r);
  80133f:	50                   	push   %eax
  801340:	68 40 1b 80 00       	push   $0x801b40
  801345:	6a 4d                	push   $0x4d
  801347:	68 fa 1b 80 00       	push   $0x801bfa
  80134c:	e8 0d 01 00 00       	call   80145e <_panic>
		}
		// TODO: Still don't know why
		r = sys_page_map(0, pn_addr, 0, pn_addr, perm);
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	68 05 08 00 00       	push   $0x805
  801359:	56                   	push   %esi
  80135a:	6a 00                	push   $0x0
  80135c:	56                   	push   %esi
  80135d:	6a 00                	push   $0x0
  80135f:	e8 17 fc ff ff       	call   800f7b <sys_page_map>
		if (r) {
  801364:	83 c4 20             	add    $0x20,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	74 3c                	je     8013a7 <label_116+0x12e>
			panic("duppage sys_page_map 2/2 failed %e", r);
  80136b:	50                   	push   %eax
  80136c:	68 64 1b 80 00       	push   $0x801b64
  801371:	6a 52                	push   $0x52
  801373:	68 fa 1b 80 00       	push   $0x801bfa
  801378:	e8 e1 00 00 00       	call   80145e <_panic>
		}
	} else {
		r = sys_page_map(0, pn_addr, envid, pn_addr, perm);
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	6a 05                	push   $0x5
  801382:	56                   	push   %esi
  801383:	ff 75 e4             	pushl  -0x1c(%ebp)
  801386:	56                   	push   %esi
  801387:	6a 00                	push   $0x0
  801389:	e8 ed fb ff ff       	call   800f7b <sys_page_map>
		if (r) {
  80138e:	83 c4 20             	add    $0x20,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	74 12                	je     8013a7 <label_116+0x12e>
			panic("duppage sys_page_map 1/1 failed %e", r);
  801395:	50                   	push   %eax
  801396:	68 88 1b 80 00       	push   $0x801b88
  80139b:	6a 57                	push   $0x57
  80139d:	68 fa 1b 80 00       	push   $0x801bfa
  8013a2:	e8 b7 00 00 00       	call   80145e <_panic>
	} else {
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
  8013a7:	83 c3 01             	add    $0x1,%ebx
  8013aa:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8013b0:	0f 85 24 ff ff ff    	jne    8012da <label_116+0x61>
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
				duppage(child_id, pn);
			}
		}

		r = sys_page_alloc(child_id, (void *)(UTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8013b6:	83 ec 04             	sub    $0x4,%esp
  8013b9:	6a 07                	push   $0x7
  8013bb:	68 00 f0 bf ee       	push   $0xeebff000
  8013c0:	57                   	push   %edi
  8013c1:	e8 63 fb ff ff       	call   800f29 <sys_page_alloc>
		if (r) {
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	74 15                	je     8013e2 <label_116+0x169>
			panic("fork sys_page_alloc failed %e", r);
  8013cd:	50                   	push   %eax
  8013ce:	68 2d 1c 80 00       	push   $0x801c2d
  8013d3:	68 8a 00 00 00       	push   $0x8a
  8013d8:	68 fa 1b 80 00       	push   $0x801bfa
  8013dd:	e8 7c 00 00 00       	call   80145e <_panic>
		}

		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	68 13 15 80 00       	push   $0x801513
  8013ea:	57                   	push   %edi
  8013eb:	e8 9e fc ff ff       	call   80108e <sys_env_set_pgfault_upcall>
		if (r) {
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	74 15                	je     80140c <label_116+0x193>
			panic("fork sys_env_set_pgfault_upcall failed %e", r);
  8013f7:	50                   	push   %eax
  8013f8:	68 ac 1b 80 00       	push   $0x801bac
  8013fd:	68 90 00 00 00       	push   $0x90
  801402:	68 fa 1b 80 00       	push   $0x801bfa
  801407:	e8 52 00 00 00       	call   80145e <_panic>
		}

		r = sys_env_set_status(child_id, ENV_RUNNABLE);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	6a 02                	push   $0x2
  801411:	57                   	push   %edi
  801412:	e8 26 fc ff ff       	call   80103d <sys_env_set_status>
		if (r) {
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	85 c0                	test   %eax,%eax
  80141c:	74 1c                	je     80143a <label_116+0x1c1>
			panic("fork sys_env_set_status failed %e", r);
  80141e:	50                   	push   %eax
  80141f:	68 d8 1b 80 00       	push   $0x801bd8
  801424:	68 95 00 00 00       	push   $0x95
  801429:	68 fa 1b 80 00       	push   $0x801bfa
  80142e:	e8 2b 00 00 00       	call   80145e <_panic>

	int r;
	envid_t child_id;
	child_id = sys_exofork();
	if (child_id < 0) {
		return -1;
  801433:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801438:	eb 02                	jmp    80143c <label_116+0x1c3>

		r = sys_env_set_status(child_id, ENV_RUNNABLE);
		if (r) {
			panic("fork sys_env_set_status failed %e", r);
		}
		return child_id;
  80143a:	89 f8                	mov    %edi,%eax
	}
	// panic("fork not implemented");
}
  80143c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <sfork>:

// Challenge!
int
sfork(void)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80144a:	68 4b 1c 80 00       	push   $0x801c4b
  80144f:	68 a0 00 00 00       	push   $0xa0
  801454:	68 fa 1b 80 00       	push   $0x801bfa
  801459:	e8 00 00 00 00       	call   80145e <_panic>

0080145e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	56                   	push   %esi
  801462:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801463:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  801466:	a1 10 20 80 00       	mov    0x802010,%eax
  80146b:	85 c0                	test   %eax,%eax
  80146d:	74 11                	je     801480 <_panic+0x22>
		cprintf("%s: ", argv0);
  80146f:	83 ec 08             	sub    $0x8,%esp
  801472:	50                   	push   %eax
  801473:	68 61 1c 80 00       	push   $0x801c61
  801478:	e8 4f ed ff ff       	call   8001cc <cprintf>
  80147d:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801480:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801486:	e8 09 fa ff ff       	call   800e94 <sys_getenvid>
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	ff 75 0c             	pushl  0xc(%ebp)
  801491:	ff 75 08             	pushl  0x8(%ebp)
  801494:	56                   	push   %esi
  801495:	50                   	push   %eax
  801496:	68 68 1c 80 00       	push   $0x801c68
  80149b:	e8 2c ed ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014a0:	83 c4 18             	add    $0x18,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	ff 75 10             	pushl  0x10(%ebp)
  8014a7:	e8 cf ec ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  8014ac:	c7 04 24 ef 17 80 00 	movl   $0x8017ef,(%esp)
  8014b3:	e8 14 ed ff ff       	call   8001cc <cprintf>
  8014b8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014bb:	cc                   	int3   
  8014bc:	eb fd                	jmp    8014bb <_panic+0x5d>

008014be <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8014c4:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  8014cb:	75 3c                	jne    801509 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	6a 07                	push   $0x7
  8014d2:	68 00 f0 bf ee       	push   $0xeebff000
  8014d7:	6a 00                	push   $0x0
  8014d9:	e8 4b fa ff ff       	call   800f29 <sys_page_alloc>
		if (r) {
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	74 12                	je     8014f7 <set_pgfault_handler+0x39>
			panic("set_pgfault_handler: %e\n", r);
  8014e5:	50                   	push   %eax
  8014e6:	68 8c 1c 80 00       	push   $0x801c8c
  8014eb:	6a 22                	push   $0x22
  8014ed:	68 a5 1c 80 00       	push   $0x801ca5
  8014f2:	e8 67 ff ff ff       	call   80145e <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	68 13 15 80 00       	push   $0x801513
  8014ff:	6a 00                	push   $0x0
  801501:	e8 88 fb ff ff       	call   80108e <sys_env_set_pgfault_upcall>
  801506:	83 c4 10             	add    $0x10,%esp
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801509:	8b 45 08             	mov    0x8(%ebp),%eax
  80150c:	a3 14 20 80 00       	mov    %eax,0x802014
}
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801513:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801514:	a1 14 20 80 00       	mov    0x802014,%eax
	call *%eax
  801519:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80151b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  80151e:	8b 44 24 30          	mov    0x30(%esp),%eax
	leal -0x4(%eax), %eax	// preserve space to store trap-time eip
  801522:	8d 40 fc             	lea    -0x4(%eax),%eax
	movl %eax, 0x30(%esp)
  801525:	89 44 24 30          	mov    %eax,0x30(%esp)

	movl 0x28(%esp), %ecx
  801529:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  80152d:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80152f:	83 c4 08             	add    $0x8,%esp
	popal
  801532:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801533:	83 c4 04             	add    $0x4,%esp
	popfl
  801536:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801537:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801538:	c3                   	ret    
  801539:	66 90                	xchg   %ax,%ax
  80153b:	66 90                	xchg   %ax,%ax
  80153d:	66 90                	xchg   %ax,%ax
  80153f:	90                   	nop

00801540 <__udivdi3>:
  801540:	55                   	push   %ebp
  801541:	57                   	push   %edi
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
  801544:	83 ec 1c             	sub    $0x1c,%esp
  801547:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80154b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80154f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801557:	85 f6                	test   %esi,%esi
  801559:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80155d:	89 ca                	mov    %ecx,%edx
  80155f:	89 f8                	mov    %edi,%eax
  801561:	75 3d                	jne    8015a0 <__udivdi3+0x60>
  801563:	39 cf                	cmp    %ecx,%edi
  801565:	0f 87 c5 00 00 00    	ja     801630 <__udivdi3+0xf0>
  80156b:	85 ff                	test   %edi,%edi
  80156d:	89 fd                	mov    %edi,%ebp
  80156f:	75 0b                	jne    80157c <__udivdi3+0x3c>
  801571:	b8 01 00 00 00       	mov    $0x1,%eax
  801576:	31 d2                	xor    %edx,%edx
  801578:	f7 f7                	div    %edi
  80157a:	89 c5                	mov    %eax,%ebp
  80157c:	89 c8                	mov    %ecx,%eax
  80157e:	31 d2                	xor    %edx,%edx
  801580:	f7 f5                	div    %ebp
  801582:	89 c1                	mov    %eax,%ecx
  801584:	89 d8                	mov    %ebx,%eax
  801586:	89 cf                	mov    %ecx,%edi
  801588:	f7 f5                	div    %ebp
  80158a:	89 c3                	mov    %eax,%ebx
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	89 fa                	mov    %edi,%edx
  801590:	83 c4 1c             	add    $0x1c,%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    
  801598:	90                   	nop
  801599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015a0:	39 ce                	cmp    %ecx,%esi
  8015a2:	77 74                	ja     801618 <__udivdi3+0xd8>
  8015a4:	0f bd fe             	bsr    %esi,%edi
  8015a7:	83 f7 1f             	xor    $0x1f,%edi
  8015aa:	0f 84 98 00 00 00    	je     801648 <__udivdi3+0x108>
  8015b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8015b5:	89 f9                	mov    %edi,%ecx
  8015b7:	89 c5                	mov    %eax,%ebp
  8015b9:	29 fb                	sub    %edi,%ebx
  8015bb:	d3 e6                	shl    %cl,%esi
  8015bd:	89 d9                	mov    %ebx,%ecx
  8015bf:	d3 ed                	shr    %cl,%ebp
  8015c1:	89 f9                	mov    %edi,%ecx
  8015c3:	d3 e0                	shl    %cl,%eax
  8015c5:	09 ee                	or     %ebp,%esi
  8015c7:	89 d9                	mov    %ebx,%ecx
  8015c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015cd:	89 d5                	mov    %edx,%ebp
  8015cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015d3:	d3 ed                	shr    %cl,%ebp
  8015d5:	89 f9                	mov    %edi,%ecx
  8015d7:	d3 e2                	shl    %cl,%edx
  8015d9:	89 d9                	mov    %ebx,%ecx
  8015db:	d3 e8                	shr    %cl,%eax
  8015dd:	09 c2                	or     %eax,%edx
  8015df:	89 d0                	mov    %edx,%eax
  8015e1:	89 ea                	mov    %ebp,%edx
  8015e3:	f7 f6                	div    %esi
  8015e5:	89 d5                	mov    %edx,%ebp
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	f7 64 24 0c          	mull   0xc(%esp)
  8015ed:	39 d5                	cmp    %edx,%ebp
  8015ef:	72 10                	jb     801601 <__udivdi3+0xc1>
  8015f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8015f5:	89 f9                	mov    %edi,%ecx
  8015f7:	d3 e6                	shl    %cl,%esi
  8015f9:	39 c6                	cmp    %eax,%esi
  8015fb:	73 07                	jae    801604 <__udivdi3+0xc4>
  8015fd:	39 d5                	cmp    %edx,%ebp
  8015ff:	75 03                	jne    801604 <__udivdi3+0xc4>
  801601:	83 eb 01             	sub    $0x1,%ebx
  801604:	31 ff                	xor    %edi,%edi
  801606:	89 d8                	mov    %ebx,%eax
  801608:	89 fa                	mov    %edi,%edx
  80160a:	83 c4 1c             	add    $0x1c,%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5f                   	pop    %edi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    
  801612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801618:	31 ff                	xor    %edi,%edi
  80161a:	31 db                	xor    %ebx,%ebx
  80161c:	89 d8                	mov    %ebx,%eax
  80161e:	89 fa                	mov    %edi,%edx
  801620:	83 c4 1c             	add    $0x1c,%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    
  801628:	90                   	nop
  801629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801630:	89 d8                	mov    %ebx,%eax
  801632:	f7 f7                	div    %edi
  801634:	31 ff                	xor    %edi,%edi
  801636:	89 c3                	mov    %eax,%ebx
  801638:	89 d8                	mov    %ebx,%eax
  80163a:	89 fa                	mov    %edi,%edx
  80163c:	83 c4 1c             	add    $0x1c,%esp
  80163f:	5b                   	pop    %ebx
  801640:	5e                   	pop    %esi
  801641:	5f                   	pop    %edi
  801642:	5d                   	pop    %ebp
  801643:	c3                   	ret    
  801644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801648:	39 ce                	cmp    %ecx,%esi
  80164a:	72 0c                	jb     801658 <__udivdi3+0x118>
  80164c:	31 db                	xor    %ebx,%ebx
  80164e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801652:	0f 87 34 ff ff ff    	ja     80158c <__udivdi3+0x4c>
  801658:	bb 01 00 00 00       	mov    $0x1,%ebx
  80165d:	e9 2a ff ff ff       	jmp    80158c <__udivdi3+0x4c>
  801662:	66 90                	xchg   %ax,%ax
  801664:	66 90                	xchg   %ax,%ax
  801666:	66 90                	xchg   %ax,%ax
  801668:	66 90                	xchg   %ax,%ax
  80166a:	66 90                	xchg   %ax,%ax
  80166c:	66 90                	xchg   %ax,%ax
  80166e:	66 90                	xchg   %ax,%ax

00801670 <__umoddi3>:
  801670:	55                   	push   %ebp
  801671:	57                   	push   %edi
  801672:	56                   	push   %esi
  801673:	53                   	push   %ebx
  801674:	83 ec 1c             	sub    $0x1c,%esp
  801677:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80167b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80167f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801683:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801687:	85 d2                	test   %edx,%edx
  801689:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80168d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801691:	89 f3                	mov    %esi,%ebx
  801693:	89 3c 24             	mov    %edi,(%esp)
  801696:	89 74 24 04          	mov    %esi,0x4(%esp)
  80169a:	75 1c                	jne    8016b8 <__umoddi3+0x48>
  80169c:	39 f7                	cmp    %esi,%edi
  80169e:	76 50                	jbe    8016f0 <__umoddi3+0x80>
  8016a0:	89 c8                	mov    %ecx,%eax
  8016a2:	89 f2                	mov    %esi,%edx
  8016a4:	f7 f7                	div    %edi
  8016a6:	89 d0                	mov    %edx,%eax
  8016a8:	31 d2                	xor    %edx,%edx
  8016aa:	83 c4 1c             	add    $0x1c,%esp
  8016ad:	5b                   	pop    %ebx
  8016ae:	5e                   	pop    %esi
  8016af:	5f                   	pop    %edi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    
  8016b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8016b8:	39 f2                	cmp    %esi,%edx
  8016ba:	89 d0                	mov    %edx,%eax
  8016bc:	77 52                	ja     801710 <__umoddi3+0xa0>
  8016be:	0f bd ea             	bsr    %edx,%ebp
  8016c1:	83 f5 1f             	xor    $0x1f,%ebp
  8016c4:	75 5a                	jne    801720 <__umoddi3+0xb0>
  8016c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8016ca:	0f 82 e0 00 00 00    	jb     8017b0 <__umoddi3+0x140>
  8016d0:	39 0c 24             	cmp    %ecx,(%esp)
  8016d3:	0f 86 d7 00 00 00    	jbe    8017b0 <__umoddi3+0x140>
  8016d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8016e1:	83 c4 1c             	add    $0x1c,%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5e                   	pop    %esi
  8016e6:	5f                   	pop    %edi
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    
  8016e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8016f0:	85 ff                	test   %edi,%edi
  8016f2:	89 fd                	mov    %edi,%ebp
  8016f4:	75 0b                	jne    801701 <__umoddi3+0x91>
  8016f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8016fb:	31 d2                	xor    %edx,%edx
  8016fd:	f7 f7                	div    %edi
  8016ff:	89 c5                	mov    %eax,%ebp
  801701:	89 f0                	mov    %esi,%eax
  801703:	31 d2                	xor    %edx,%edx
  801705:	f7 f5                	div    %ebp
  801707:	89 c8                	mov    %ecx,%eax
  801709:	f7 f5                	div    %ebp
  80170b:	89 d0                	mov    %edx,%eax
  80170d:	eb 99                	jmp    8016a8 <__umoddi3+0x38>
  80170f:	90                   	nop
  801710:	89 c8                	mov    %ecx,%eax
  801712:	89 f2                	mov    %esi,%edx
  801714:	83 c4 1c             	add    $0x1c,%esp
  801717:	5b                   	pop    %ebx
  801718:	5e                   	pop    %esi
  801719:	5f                   	pop    %edi
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    
  80171c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801720:	8b 34 24             	mov    (%esp),%esi
  801723:	bf 20 00 00 00       	mov    $0x20,%edi
  801728:	89 e9                	mov    %ebp,%ecx
  80172a:	29 ef                	sub    %ebp,%edi
  80172c:	d3 e0                	shl    %cl,%eax
  80172e:	89 f9                	mov    %edi,%ecx
  801730:	89 f2                	mov    %esi,%edx
  801732:	d3 ea                	shr    %cl,%edx
  801734:	89 e9                	mov    %ebp,%ecx
  801736:	09 c2                	or     %eax,%edx
  801738:	89 d8                	mov    %ebx,%eax
  80173a:	89 14 24             	mov    %edx,(%esp)
  80173d:	89 f2                	mov    %esi,%edx
  80173f:	d3 e2                	shl    %cl,%edx
  801741:	89 f9                	mov    %edi,%ecx
  801743:	89 54 24 04          	mov    %edx,0x4(%esp)
  801747:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80174b:	d3 e8                	shr    %cl,%eax
  80174d:	89 e9                	mov    %ebp,%ecx
  80174f:	89 c6                	mov    %eax,%esi
  801751:	d3 e3                	shl    %cl,%ebx
  801753:	89 f9                	mov    %edi,%ecx
  801755:	89 d0                	mov    %edx,%eax
  801757:	d3 e8                	shr    %cl,%eax
  801759:	89 e9                	mov    %ebp,%ecx
  80175b:	09 d8                	or     %ebx,%eax
  80175d:	89 d3                	mov    %edx,%ebx
  80175f:	89 f2                	mov    %esi,%edx
  801761:	f7 34 24             	divl   (%esp)
  801764:	89 d6                	mov    %edx,%esi
  801766:	d3 e3                	shl    %cl,%ebx
  801768:	f7 64 24 04          	mull   0x4(%esp)
  80176c:	39 d6                	cmp    %edx,%esi
  80176e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801772:	89 d1                	mov    %edx,%ecx
  801774:	89 c3                	mov    %eax,%ebx
  801776:	72 08                	jb     801780 <__umoddi3+0x110>
  801778:	75 11                	jne    80178b <__umoddi3+0x11b>
  80177a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80177e:	73 0b                	jae    80178b <__umoddi3+0x11b>
  801780:	2b 44 24 04          	sub    0x4(%esp),%eax
  801784:	1b 14 24             	sbb    (%esp),%edx
  801787:	89 d1                	mov    %edx,%ecx
  801789:	89 c3                	mov    %eax,%ebx
  80178b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80178f:	29 da                	sub    %ebx,%edx
  801791:	19 ce                	sbb    %ecx,%esi
  801793:	89 f9                	mov    %edi,%ecx
  801795:	89 f0                	mov    %esi,%eax
  801797:	d3 e0                	shl    %cl,%eax
  801799:	89 e9                	mov    %ebp,%ecx
  80179b:	d3 ea                	shr    %cl,%edx
  80179d:	89 e9                	mov    %ebp,%ecx
  80179f:	d3 ee                	shr    %cl,%esi
  8017a1:	09 d0                	or     %edx,%eax
  8017a3:	89 f2                	mov    %esi,%edx
  8017a5:	83 c4 1c             	add    $0x1c,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    
  8017ad:	8d 76 00             	lea    0x0(%esi),%esi
  8017b0:	29 f9                	sub    %edi,%ecx
  8017b2:	19 d6                	sbb    %edx,%esi
  8017b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017bc:	e9 18 ff ff ff       	jmp    8016d9 <__umoddi3+0x69>
