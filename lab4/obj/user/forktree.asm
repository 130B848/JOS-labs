
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
  800047:	68 a0 14 80 00       	push   $0x8014a0
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
  800095:	68 b1 14 80 00       	push   $0x8014b1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 e8 08 00 00       	call   80098d <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 c5 10 00 00       	call   801172 <fork>
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
  8000d2:	68 b0 14 80 00       	push   $0x8014b0
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
	// cprintf("env_id = %08x\n", sys_getenvid());

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
  800244:	e8 e7 10 00 00       	call   801330 <__umoddi3>
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	0f be 80 c0 14 80 00 	movsbl 0x8014c0(%eax),%eax
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
  800326:	e8 05 10 00 00       	call   801330 <__umoddi3>
  80032b:	83 c4 14             	add    $0x14,%esp
  80032e:	0f be 80 c0 14 80 00 	movsbl 0x8014c0(%eax),%eax
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
  80035c:	e8 9f 0e 00 00       	call   801200 <__udivdi3>
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
  800382:	e8 a9 0f 00 00       	call   801330 <__umoddi3>
  800387:	83 c4 14             	add    $0x14,%esp
  80038a:	0f be 80 c0 14 80 00 	movsbl 0x8014c0(%eax),%eax
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
  8003b8:	e8 43 0e 00 00       	call   801200 <__udivdi3>
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
  8003de:	e8 4d 0f 00 00       	call   801330 <__umoddi3>
  8003e3:	83 c4 14             	add    $0x14,%esp
  8003e6:	0f be 80 c0 14 80 00 	movsbl 0x8014c0(%eax),%eax
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
  800501:	ff 24 85 00 16 80 00 	jmp    *0x801600(,%eax,4)
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
  8005e7:	8b 14 85 60 17 80 00 	mov    0x801760(,%eax,4),%edx
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	75 15                	jne    800607 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8005f2:	50                   	push   %eax
  8005f3:	68 d8 14 80 00       	push   $0x8014d8
  8005f8:	53                   	push   %ebx
  8005f9:	57                   	push   %edi
  8005fa:	e8 53 fe ff ff       	call   800452 <printfmt>
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	e9 7c fe ff ff       	jmp    800483 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800607:	52                   	push   %edx
  800608:	68 e1 14 80 00       	push   $0x8014e1
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
  800629:	b9 d1 14 80 00       	mov    $0x8014d1,%ecx
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
  8008a5:	68 78 15 80 00       	push   $0x801578
  8008aa:	68 e1 14 80 00       	push   $0x8014e1
  8008af:	e8 18 f9 ff ff       	call   8001cc <cprintf>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	e9 c7 fb ff ff       	jmp    800483 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8008bc:	0f b6 03             	movzbl (%ebx),%eax
  8008bf:	84 c0                	test   %al,%al
  8008c1:	79 1f                	jns    8008e2 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	68 b0 15 80 00       	push   $0x8015b0
  8008cb:	68 e1 14 80 00       	push   $0x8014e1
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
  800dfa:	54                   	push   %esp
  800dfb:	55                   	push   %ebp
  800dfc:	56                   	push   %esi
  800dfd:	57                   	push   %edi
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8d 35 08 0e 80 00    	lea    0x800e08,%esi
  800e06:	0f 34                	sysenter 

00800e08 <label_21>:
  800e08:	5f                   	pop    %edi
  800e09:	5e                   	pop    %esi
  800e0a:	5d                   	pop    %ebp
  800e0b:	5c                   	pop    %esp
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
  800e2b:	54                   	push   %esp
  800e2c:	55                   	push   %ebp
  800e2d:	56                   	push   %esi
  800e2e:	57                   	push   %edi
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	8d 35 39 0e 80 00    	lea    0x800e39,%esi
  800e37:	0f 34                	sysenter 

00800e39 <label_55>:
  800e39:	5f                   	pop    %edi
  800e3a:	5e                   	pop    %esi
  800e3b:	5d                   	pop    %ebp
  800e3c:	5c                   	pop    %esp
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
  800e5d:	54                   	push   %esp
  800e5e:	55                   	push   %ebp
  800e5f:	56                   	push   %esi
  800e60:	57                   	push   %edi
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	8d 35 6b 0e 80 00    	lea    0x800e6b,%esi
  800e69:	0f 34                	sysenter 

00800e6b <label_90>:
  800e6b:	5f                   	pop    %edi
  800e6c:	5e                   	pop    %esi
  800e6d:	5d                   	pop    %ebp
  800e6e:	5c                   	pop    %esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5a                   	pop    %edx
  800e71:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 17                	jle    800e8d <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	83 ec 0c             	sub    $0xc,%esp
  800e79:	50                   	push   %eax
  800e7a:	6a 03                	push   $0x3
  800e7c:	68 84 17 80 00       	push   $0x801784
  800e81:	6a 2a                	push   $0x2a
  800e83:	68 a1 17 80 00       	push   $0x8017a1
  800e88:	e8 13 03 00 00       	call   8011a0 <_panic>

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
  800eac:	54                   	push   %esp
  800ead:	55                   	push   %ebp
  800eae:	56                   	push   %esi
  800eaf:	57                   	push   %edi
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	8d 35 ba 0e 80 00    	lea    0x800eba,%esi
  800eb8:	0f 34                	sysenter 

00800eba <label_139>:
  800eba:	5f                   	pop    %edi
  800ebb:	5e                   	pop    %esi
  800ebc:	5d                   	pop    %ebp
  800ebd:	5c                   	pop    %esp
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
  800edf:	54                   	push   %esp
  800ee0:	55                   	push   %ebp
  800ee1:	56                   	push   %esi
  800ee2:	57                   	push   %edi
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	8d 35 ed 0e 80 00    	lea    0x800eed,%esi
  800eeb:	0f 34                	sysenter 

00800eed <label_174>:
  800eed:	5f                   	pop    %edi
  800eee:	5e                   	pop    %esi
  800eef:	5d                   	pop    %ebp
  800ef0:	5c                   	pop    %esp
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
  800f10:	54                   	push   %esp
  800f11:	55                   	push   %ebp
  800f12:	56                   	push   %esi
  800f13:	57                   	push   %edi
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	8d 35 1e 0f 80 00    	lea    0x800f1e,%esi
  800f1c:	0f 34                	sysenter 

00800f1e <label_209>:
  800f1e:	5f                   	pop    %edi
  800f1f:	5e                   	pop    %esi
  800f20:	5d                   	pop    %ebp
  800f21:	5c                   	pop    %esp
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
  800f44:	54                   	push   %esp
  800f45:	55                   	push   %ebp
  800f46:	56                   	push   %esi
  800f47:	57                   	push   %edi
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	8d 35 52 0f 80 00    	lea    0x800f52,%esi
  800f50:	0f 34                	sysenter 

00800f52 <label_244>:
  800f52:	5f                   	pop    %edi
  800f53:	5e                   	pop    %esi
  800f54:	5d                   	pop    %ebp
  800f55:	5c                   	pop    %esp
  800f56:	5b                   	pop    %ebx
  800f57:	5a                   	pop    %edx
  800f58:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	7e 17                	jle    800f74 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	50                   	push   %eax
  800f61:	6a 05                	push   $0x5
  800f63:	68 84 17 80 00       	push   $0x801784
  800f68:	6a 2a                	push   $0x2a
  800f6a:	68 a1 17 80 00       	push   $0x8017a1
  800f6f:	e8 2c 02 00 00       	call   8011a0 <_panic>

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

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f80:	b8 06 00 00 00       	mov    $0x6,%eax
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f91:	51                   	push   %ecx
  800f92:	52                   	push   %edx
  800f93:	53                   	push   %ebx
  800f94:	54                   	push   %esp
  800f95:	55                   	push   %ebp
  800f96:	56                   	push   %esi
  800f97:	57                   	push   %edi
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	8d 35 a2 0f 80 00    	lea    0x800fa2,%esi
  800fa0:	0f 34                	sysenter 

00800fa2 <label_295>:
  800fa2:	5f                   	pop    %edi
  800fa3:	5e                   	pop    %esi
  800fa4:	5d                   	pop    %ebp
  800fa5:	5c                   	pop    %esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5a                   	pop    %edx
  800fa8:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 17                	jle    800fc4 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	50                   	push   %eax
  800fb1:	6a 06                	push   $0x6
  800fb3:	68 84 17 80 00       	push   $0x801784
  800fb8:	6a 2a                	push   $0x2a
  800fba:	68 a1 17 80 00       	push   $0x8017a1
  800fbf:	e8 dc 01 00 00       	call   8011a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc7:	5b                   	pop    %ebx
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fd5:	b8 07 00 00 00       	mov    $0x7,%eax
  800fda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe0:	89 fb                	mov    %edi,%ebx
  800fe2:	51                   	push   %ecx
  800fe3:	52                   	push   %edx
  800fe4:	53                   	push   %ebx
  800fe5:	54                   	push   %esp
  800fe6:	55                   	push   %ebp
  800fe7:	56                   	push   %esi
  800fe8:	57                   	push   %edi
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	8d 35 f3 0f 80 00    	lea    0x800ff3,%esi
  800ff1:	0f 34                	sysenter 

00800ff3 <label_344>:
  800ff3:	5f                   	pop    %edi
  800ff4:	5e                   	pop    %esi
  800ff5:	5d                   	pop    %ebp
  800ff6:	5c                   	pop    %esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5a                   	pop    %edx
  800ff9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	7e 17                	jle    801015 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	50                   	push   %eax
  801002:	6a 07                	push   $0x7
  801004:	68 84 17 80 00       	push   $0x801784
  801009:	6a 2a                	push   $0x2a
  80100b:	68 a1 17 80 00       	push   $0x8017a1
  801010:	e8 8b 01 00 00       	call   8011a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801015:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801018:	5b                   	pop    %ebx
  801019:	5f                   	pop    %edi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801021:	bf 00 00 00 00       	mov    $0x0,%edi
  801026:	b8 09 00 00 00       	mov    $0x9,%eax
  80102b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102e:	8b 55 08             	mov    0x8(%ebp),%edx
  801031:	89 fb                	mov    %edi,%ebx
  801033:	51                   	push   %ecx
  801034:	52                   	push   %edx
  801035:	53                   	push   %ebx
  801036:	54                   	push   %esp
  801037:	55                   	push   %ebp
  801038:	56                   	push   %esi
  801039:	57                   	push   %edi
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	8d 35 44 10 80 00    	lea    0x801044,%esi
  801042:	0f 34                	sysenter 

00801044 <label_393>:
  801044:	5f                   	pop    %edi
  801045:	5e                   	pop    %esi
  801046:	5d                   	pop    %ebp
  801047:	5c                   	pop    %esp
  801048:	5b                   	pop    %ebx
  801049:	5a                   	pop    %edx
  80104a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80104b:	85 c0                	test   %eax,%eax
  80104d:	7e 17                	jle    801066 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	50                   	push   %eax
  801053:	6a 09                	push   $0x9
  801055:	68 84 17 80 00       	push   $0x801784
  80105a:	6a 2a                	push   $0x2a
  80105c:	68 a1 17 80 00       	push   $0x8017a1
  801061:	e8 3a 01 00 00       	call   8011a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801066:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801069:	5b                   	pop    %ebx
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	57                   	push   %edi
  801071:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801072:	bf 00 00 00 00       	mov    $0x0,%edi
  801077:	b8 0a 00 00 00       	mov    $0xa,%eax
  80107c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107f:	8b 55 08             	mov    0x8(%ebp),%edx
  801082:	89 fb                	mov    %edi,%ebx
  801084:	51                   	push   %ecx
  801085:	52                   	push   %edx
  801086:	53                   	push   %ebx
  801087:	54                   	push   %esp
  801088:	55                   	push   %ebp
  801089:	56                   	push   %esi
  80108a:	57                   	push   %edi
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	8d 35 95 10 80 00    	lea    0x801095,%esi
  801093:	0f 34                	sysenter 

00801095 <label_442>:
  801095:	5f                   	pop    %edi
  801096:	5e                   	pop    %esi
  801097:	5d                   	pop    %ebp
  801098:	5c                   	pop    %esp
  801099:	5b                   	pop    %ebx
  80109a:	5a                   	pop    %edx
  80109b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80109c:	85 c0                	test   %eax,%eax
  80109e:	7e 17                	jle    8010b7 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	50                   	push   %eax
  8010a4:	6a 0a                	push   $0xa
  8010a6:	68 84 17 80 00       	push   $0x801784
  8010ab:	6a 2a                	push   $0x2a
  8010ad:	68 a1 17 80 00       	push   $0x8017a1
  8010b2:	e8 e9 00 00 00       	call   8011a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5f                   	pop    %edi
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	57                   	push   %edi
  8010c2:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010c3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d4:	51                   	push   %ecx
  8010d5:	52                   	push   %edx
  8010d6:	53                   	push   %ebx
  8010d7:	54                   	push   %esp
  8010d8:	55                   	push   %ebp
  8010d9:	56                   	push   %esi
  8010da:	57                   	push   %edi
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	8d 35 e5 10 80 00    	lea    0x8010e5,%esi
  8010e3:	0f 34                	sysenter 

008010e5 <label_493>:
  8010e5:	5f                   	pop    %edi
  8010e6:	5e                   	pop    %esi
  8010e7:	5d                   	pop    %ebp
  8010e8:	5c                   	pop    %esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5a                   	pop    %edx
  8010eb:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010ec:	5b                   	pop    %ebx
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fa:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	89 d9                	mov    %ebx,%ecx
  801104:	89 df                	mov    %ebx,%edi
  801106:	51                   	push   %ecx
  801107:	52                   	push   %edx
  801108:	53                   	push   %ebx
  801109:	54                   	push   %esp
  80110a:	55                   	push   %ebp
  80110b:	56                   	push   %esi
  80110c:	57                   	push   %edi
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	8d 35 17 11 80 00    	lea    0x801117,%esi
  801115:	0f 34                	sysenter 

00801117 <label_528>:
  801117:	5f                   	pop    %edi
  801118:	5e                   	pop    %esi
  801119:	5d                   	pop    %ebp
  80111a:	5c                   	pop    %esp
  80111b:	5b                   	pop    %ebx
  80111c:	5a                   	pop    %edx
  80111d:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80111e:	85 c0                	test   %eax,%eax
  801120:	7e 17                	jle    801139 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	50                   	push   %eax
  801126:	6a 0d                	push   $0xd
  801128:	68 84 17 80 00       	push   $0x801784
  80112d:	6a 2a                	push   $0x2a
  80112f:	68 a1 17 80 00       	push   $0x8017a1
  801134:	e8 67 00 00 00       	call   8011a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801139:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801145:	b9 00 00 00 00       	mov    $0x0,%ecx
  80114a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80114f:	8b 55 08             	mov    0x8(%ebp),%edx
  801152:	89 cb                	mov    %ecx,%ebx
  801154:	89 cf                	mov    %ecx,%edi
  801156:	51                   	push   %ecx
  801157:	52                   	push   %edx
  801158:	53                   	push   %ebx
  801159:	54                   	push   %esp
  80115a:	55                   	push   %ebp
  80115b:	56                   	push   %esi
  80115c:	57                   	push   %edi
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	8d 35 67 11 80 00    	lea    0x801167,%esi
  801165:	0f 34                	sysenter 

00801167 <label_577>:
  801167:	5f                   	pop    %edi
  801168:	5e                   	pop    %esi
  801169:	5d                   	pop    %ebp
  80116a:	5c                   	pop    %esp
  80116b:	5b                   	pop    %ebx
  80116c:	5a                   	pop    %edx
  80116d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80116e:	5b                   	pop    %ebx
  80116f:	5f                   	pop    %edi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  801178:	68 bb 17 80 00       	push   $0x8017bb
  80117d:	6a 52                	push   $0x52
  80117f:	68 af 17 80 00       	push   $0x8017af
  801184:	e8 17 00 00 00       	call   8011a0 <_panic>

00801189 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80118f:	68 ba 17 80 00       	push   $0x8017ba
  801194:	6a 59                	push   $0x59
  801196:	68 af 17 80 00       	push   $0x8017af
  80119b:	e8 00 00 00 00       	call   8011a0 <_panic>

008011a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8011a5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8011a8:	a1 10 20 80 00       	mov    0x802010,%eax
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	74 11                	je     8011c2 <_panic+0x22>
		cprintf("%s: ", argv0);
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	50                   	push   %eax
  8011b5:	68 d0 17 80 00       	push   $0x8017d0
  8011ba:	e8 0d f0 ff ff       	call   8001cc <cprintf>
  8011bf:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011c2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011c8:	e8 c7 fc ff ff       	call   800e94 <sys_getenvid>
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	ff 75 0c             	pushl  0xc(%ebp)
  8011d3:	ff 75 08             	pushl  0x8(%ebp)
  8011d6:	56                   	push   %esi
  8011d7:	50                   	push   %eax
  8011d8:	68 d8 17 80 00       	push   $0x8017d8
  8011dd:	e8 ea ef ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011e2:	83 c4 18             	add    $0x18,%esp
  8011e5:	53                   	push   %ebx
  8011e6:	ff 75 10             	pushl  0x10(%ebp)
  8011e9:	e8 8d ef ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  8011ee:	c7 04 24 af 14 80 00 	movl   $0x8014af,(%esp)
  8011f5:	e8 d2 ef ff ff       	call   8001cc <cprintf>
  8011fa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011fd:	cc                   	int3   
  8011fe:	eb fd                	jmp    8011fd <_panic+0x5d>

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
