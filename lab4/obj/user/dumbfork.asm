
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 bb 01 00 00       	call   8001ec <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 4a 10 00 00       	call   801094 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 80 15 80 00       	push   $0x801580
  800057:	6a 20                	push   $0x20
  800059:	68 93 15 80 00       	push   $0x801593
  80005e:	e8 e1 01 00 00       	call   800244 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 70 10 00 00       	call   8010e6 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 a3 15 80 00       	push   $0x8015a3
  800083:	6a 22                	push   $0x22
  800085:	68 93 15 80 00       	push   $0x801593
  80008a:	e8 b5 01 00 00       	call   800244 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 ba 0c 00 00       	call   800d5c <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 85 10 00 00       	call   801136 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 b4 15 80 00       	push   $0x8015b4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 93 15 80 00       	push   $0x801593
  8000c5:	e8 7a 01 00 00       	call   800244 <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 c7 15 80 00       	push   $0x8015c7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 93 15 80 00       	push   $0x801593
  8000f3:	e8 4c 01 00 00       	call   800244 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 fc 0e 00 00       	call   800fff <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	c1 e0 07             	shl    $0x7,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 71                	jmp    80018d <dumbfork+0xbc>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	b8 14 20 80 00       	mov    $0x802014,%eax
  800128:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80012d:	76 26                	jbe    800155 <dumbfork+0x84>
  80012f:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, addr);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	52                   	push   %edx
  800138:	56                   	push   %esi
  800139:	e8 f5 fe ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80013e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800141:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  800147:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	81 fa 14 20 80 00    	cmp    $0x802014,%edx
  800153:	72 df                	jb     800134 <dumbfork+0x63>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800155:	83 ec 08             	sub    $0x8,%esp
  800158:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80015b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800160:	50                   	push   %eax
  800161:	53                   	push   %ebx
  800162:	e8 cc fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800167:	83 c4 08             	add    $0x8,%esp
  80016a:	6a 02                	push   $0x2
  80016c:	53                   	push   %ebx
  80016d:	e8 15 10 00 00       	call   801187 <sys_env_set_status>
  800172:	83 c4 10             	add    $0x10,%esp
  800175:	85 c0                	test   %eax,%eax
  800177:	79 12                	jns    80018b <dumbfork+0xba>
		panic("sys_env_set_status: %e", r);
  800179:	50                   	push   %eax
  80017a:	68 d7 15 80 00       	push   $0x8015d7
  80017f:	6a 4c                	push   $0x4c
  800181:	68 93 15 80 00       	push   $0x801593
  800186:	e8 b9 00 00 00       	call   800244 <_panic>

	return envid;
  80018b:	89 d8                	mov    %ebx,%eax
}
  80018d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    

00800194 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
  80019a:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80019d:	e8 2f ff ff ff       	call   8000d1 <dumbfork>
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	be f5 15 80 00       	mov    $0x8015f5,%esi
  8001ab:	b8 ee 15 80 00       	mov    $0x8015ee,%eax
  8001b0:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b8:	eb 1a                	jmp    8001d4 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001ba:	83 ec 04             	sub    $0x4,%esp
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	68 fb 15 80 00       	push   $0x8015fb
  8001c4:	e8 6e 01 00 00       	call   800337 <cprintf>
		sys_yield();
  8001c9:	e8 95 0e 00 00       	call   801063 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001ce:	83 c3 01             	add    $0x1,%ebx
  8001d1:	83 c4 10             	add    $0x10,%esp
  8001d4:	85 ff                	test   %edi,%edi
  8001d6:	74 07                	je     8001df <umain+0x4b>
  8001d8:	83 fb 09             	cmp    $0x9,%ebx
  8001db:	7e dd                	jle    8001ba <umain+0x26>
  8001dd:	eb 05                	jmp    8001e4 <umain+0x50>
  8001df:	83 fb 13             	cmp    $0x13,%ebx
  8001e2:	7e d6                	jle    8001ba <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001f7:	e8 03 0e 00 00       	call   800fff <sys_getenvid>
  8001fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800201:	c1 e0 07             	shl    $0x7,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 db                	test   %ebx,%ebx
  800210:	7e 07                	jle    800219 <libmain+0x2d>
		binaryname = argv[0];
  800212:	8b 06                	mov    (%esi),%eax
  800214:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	e8 71 ff ff ff       	call   800194 <umain>

	// exit gracefully
	exit();
  800223:	e8 0a 00 00 00       	call   800232 <exit>
}
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800238:	6a 00                	push   $0x0
  80023a:	e8 70 0d 00 00       	call   800faf <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80024c:	a1 10 20 80 00       	mov    0x802010,%eax
  800251:	85 c0                	test   %eax,%eax
  800253:	74 11                	je     800266 <_panic+0x22>
		cprintf("%s: ", argv0);
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	50                   	push   %eax
  800259:	68 17 16 80 00       	push   $0x801617
  80025e:	e8 d4 00 00 00       	call   800337 <cprintf>
  800263:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800266:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80026c:	e8 8e 0d 00 00       	call   800fff <sys_getenvid>
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	ff 75 0c             	pushl  0xc(%ebp)
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	56                   	push   %esi
  80027b:	50                   	push   %eax
  80027c:	68 1c 16 80 00       	push   $0x80161c
  800281:	e8 b1 00 00 00       	call   800337 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800286:	83 c4 18             	add    $0x18,%esp
  800289:	53                   	push   %ebx
  80028a:	ff 75 10             	pushl  0x10(%ebp)
  80028d:	e8 54 00 00 00       	call   8002e6 <vcprintf>
	cprintf("\n");
  800292:	c7 04 24 0b 16 80 00 	movl   $0x80160b,(%esp)
  800299:	e8 99 00 00 00       	call   800337 <cprintf>
  80029e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a1:	cc                   	int3   
  8002a2:	eb fd                	jmp    8002a1 <_panic+0x5d>

008002a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 04             	sub    $0x4,%esp
  8002ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ae:	8b 13                	mov    (%ebx),%edx
  8002b0:	8d 42 01             	lea    0x1(%edx),%eax
  8002b3:	89 03                	mov    %eax,(%ebx)
  8002b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002bc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c1:	75 1a                	jne    8002dd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	68 ff 00 00 00       	push   $0xff
  8002cb:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ce:	50                   	push   %eax
  8002cf:	e8 7a 0c 00 00       	call   800f4e <sys_cputs>
		b->idx = 0;
  8002d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002da:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002dd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f6:	00 00 00 
	b.cnt = 0;
  8002f9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800300:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800303:	ff 75 0c             	pushl  0xc(%ebp)
  800306:	ff 75 08             	pushl  0x8(%ebp)
  800309:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	68 a4 02 80 00       	push   $0x8002a4
  800315:	e8 c0 02 00 00       	call   8005da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80031a:	83 c4 08             	add    $0x8,%esp
  80031d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800323:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800329:	50                   	push   %eax
  80032a:	e8 1f 0c 00 00       	call   800f4e <sys_cputs>

	return b.cnt;
}
  80032f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80033d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800340:	50                   	push   %eax
  800341:	ff 75 08             	pushl  0x8(%ebp)
  800344:	e8 9d ff ff ff       	call   8002e6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800349:	c9                   	leave  
  80034a:	c3                   	ret    

0080034b <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
  800351:	83 ec 1c             	sub    $0x1c,%esp
  800354:	89 c7                	mov    %eax,%edi
  800356:	89 d6                	mov    %edx,%esi
  800358:	8b 45 08             	mov    0x8(%ebp),%eax
  80035b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800361:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800364:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800367:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80036b:	0f 85 bf 00 00 00    	jne    800430 <printnum+0xe5>
  800371:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800377:	0f 8d de 00 00 00    	jge    80045b <printnum+0x110>
		judge_time_for_space = width;
  80037d:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800383:	e9 d3 00 00 00       	jmp    80045b <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800388:	83 eb 01             	sub    $0x1,%ebx
  80038b:	85 db                	test   %ebx,%ebx
  80038d:	7f 37                	jg     8003c6 <printnum+0x7b>
  80038f:	e9 ea 00 00 00       	jmp    80047e <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800394:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800397:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	56                   	push   %esi
  8003a0:	83 ec 04             	sub    $0x4,%esp
  8003a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	e8 5c 10 00 00       	call   801410 <__umoddi3>
  8003b4:	83 c4 14             	add    $0x14,%esp
  8003b7:	0f be 80 3f 16 80 00 	movsbl 0x80163f(%eax),%eax
  8003be:	50                   	push   %eax
  8003bf:	ff d7                	call   *%edi
  8003c1:	83 c4 10             	add    $0x10,%esp
  8003c4:	eb 16                	jmp    8003dc <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8003c6:	83 ec 08             	sub    $0x8,%esp
  8003c9:	56                   	push   %esi
  8003ca:	ff 75 18             	pushl  0x18(%ebp)
  8003cd:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8003cf:	83 c4 10             	add    $0x10,%esp
  8003d2:	83 eb 01             	sub    $0x1,%ebx
  8003d5:	75 ef                	jne    8003c6 <printnum+0x7b>
  8003d7:	e9 a2 00 00 00       	jmp    80047e <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8003dc:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8003e2:	0f 85 76 01 00 00    	jne    80055e <printnum+0x213>
		while(num_of_space-- > 0)
  8003e8:	a1 04 20 80 00       	mov    0x802004,%eax
  8003ed:	8d 50 ff             	lea    -0x1(%eax),%edx
  8003f0:	89 15 04 20 80 00    	mov    %edx,0x802004
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	7e 1d                	jle    800417 <printnum+0xcc>
			putch(' ', putdat);
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	56                   	push   %esi
  8003fe:	6a 20                	push   $0x20
  800400:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800402:	a1 04 20 80 00       	mov    0x802004,%eax
  800407:	8d 50 ff             	lea    -0x1(%eax),%edx
  80040a:	89 15 04 20 80 00    	mov    %edx,0x802004
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	7f e3                	jg     8003fa <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800417:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80041e:	00 00 00 
		judge_time_for_space = 0;
  800421:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800428:	00 00 00 
	}
}
  80042b:	e9 2e 01 00 00       	jmp    80055e <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800430:	8b 45 10             	mov    0x10(%ebp),%eax
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
  800438:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80043e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	83 fa 00             	cmp    $0x0,%edx
  800447:	0f 87 ba 00 00 00    	ja     800507 <printnum+0x1bc>
  80044d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800450:	0f 83 b1 00 00 00    	jae    800507 <printnum+0x1bc>
  800456:	e9 2d ff ff ff       	jmp    800388 <printnum+0x3d>
  80045b:	8b 45 10             	mov    0x10(%ebp),%eax
  80045e:	ba 00 00 00 00       	mov    $0x0,%edx
  800463:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800466:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80046f:	83 fa 00             	cmp    $0x0,%edx
  800472:	77 37                	ja     8004ab <printnum+0x160>
  800474:	3b 45 10             	cmp    0x10(%ebp),%eax
  800477:	73 32                	jae    8004ab <printnum+0x160>
  800479:	e9 16 ff ff ff       	jmp    800394 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 dc             	pushl  -0x24(%ebp)
  800488:	ff 75 d8             	pushl  -0x28(%ebp)
  80048b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048e:	ff 75 e0             	pushl  -0x20(%ebp)
  800491:	e8 7a 0f 00 00       	call   801410 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 3f 16 80 00 	movsbl 0x80163f(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	e9 b3 00 00 00       	jmp    80055e <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004ab:	83 ec 0c             	sub    $0xc,%esp
  8004ae:	ff 75 18             	pushl  0x18(%ebp)
  8004b1:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8004b4:	50                   	push   %eax
  8004b5:	ff 75 10             	pushl  0x10(%ebp)
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	ff 75 dc             	pushl  -0x24(%ebp)
  8004be:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c7:	e8 14 0e 00 00       	call   8012e0 <__udivdi3>
  8004cc:	83 c4 18             	add    $0x18,%esp
  8004cf:	52                   	push   %edx
  8004d0:	50                   	push   %eax
  8004d1:	89 f2                	mov    %esi,%edx
  8004d3:	89 f8                	mov    %edi,%eax
  8004d5:	e8 71 fe ff ff       	call   80034b <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004da:	83 c4 18             	add    $0x18,%esp
  8004dd:	56                   	push   %esi
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ed:	e8 1e 0f 00 00       	call   801410 <__umoddi3>
  8004f2:	83 c4 14             	add    $0x14,%esp
  8004f5:	0f be 80 3f 16 80 00 	movsbl 0x80163f(%eax),%eax
  8004fc:	50                   	push   %eax
  8004fd:	ff d7                	call   *%edi
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	e9 d5 fe ff ff       	jmp    8003dc <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800507:	83 ec 0c             	sub    $0xc,%esp
  80050a:	ff 75 18             	pushl  0x18(%ebp)
  80050d:	83 eb 01             	sub    $0x1,%ebx
  800510:	53                   	push   %ebx
  800511:	ff 75 10             	pushl  0x10(%ebp)
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	ff 75 dc             	pushl  -0x24(%ebp)
  80051a:	ff 75 d8             	pushl  -0x28(%ebp)
  80051d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800520:	ff 75 e0             	pushl  -0x20(%ebp)
  800523:	e8 b8 0d 00 00       	call   8012e0 <__udivdi3>
  800528:	83 c4 18             	add    $0x18,%esp
  80052b:	52                   	push   %edx
  80052c:	50                   	push   %eax
  80052d:	89 f2                	mov    %esi,%edx
  80052f:	89 f8                	mov    %edi,%eax
  800531:	e8 15 fe ff ff       	call   80034b <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800536:	83 c4 18             	add    $0x18,%esp
  800539:	56                   	push   %esi
  80053a:	83 ec 04             	sub    $0x4,%esp
  80053d:	ff 75 dc             	pushl  -0x24(%ebp)
  800540:	ff 75 d8             	pushl  -0x28(%ebp)
  800543:	ff 75 e4             	pushl  -0x1c(%ebp)
  800546:	ff 75 e0             	pushl  -0x20(%ebp)
  800549:	e8 c2 0e 00 00       	call   801410 <__umoddi3>
  80054e:	83 c4 14             	add    $0x14,%esp
  800551:	0f be 80 3f 16 80 00 	movsbl 0x80163f(%eax),%eax
  800558:	50                   	push   %eax
  800559:	ff d7                	call   *%edi
  80055b:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80055e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800561:	5b                   	pop    %ebx
  800562:	5e                   	pop    %esi
  800563:	5f                   	pop    %edi
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800569:	83 fa 01             	cmp    $0x1,%edx
  80056c:	7e 0e                	jle    80057c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	8d 4a 08             	lea    0x8(%edx),%ecx
  800573:	89 08                	mov    %ecx,(%eax)
  800575:	8b 02                	mov    (%edx),%eax
  800577:	8b 52 04             	mov    0x4(%edx),%edx
  80057a:	eb 22                	jmp    80059e <getuint+0x38>
	else if (lflag)
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 10                	je     800590 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800580:	8b 10                	mov    (%eax),%edx
  800582:	8d 4a 04             	lea    0x4(%edx),%ecx
  800585:	89 08                	mov    %ecx,(%eax)
  800587:	8b 02                	mov    (%edx),%eax
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	eb 0e                	jmp    80059e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8005af:	73 0a                	jae    8005bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8005b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005b4:	89 08                	mov    %ecx,(%eax)
  8005b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b9:	88 02                	mov    %al,(%edx)
}
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 10             	pushl  0x10(%ebp)
  8005ca:	ff 75 0c             	pushl  0xc(%ebp)
  8005cd:	ff 75 08             	pushl  0x8(%ebp)
  8005d0:	e8 05 00 00 00       	call   8005da <vprintfmt>
	va_end(ap);
}
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	c9                   	leave  
  8005d9:	c3                   	ret    

008005da <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005da:	55                   	push   %ebp
  8005db:	89 e5                	mov    %esp,%ebp
  8005dd:	57                   	push   %edi
  8005de:	56                   	push   %esi
  8005df:	53                   	push   %ebx
  8005e0:	83 ec 2c             	sub    $0x2c,%esp
  8005e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e9:	eb 03                	jmp    8005ee <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005eb:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f1:	8d 70 01             	lea    0x1(%eax),%esi
  8005f4:	0f b6 00             	movzbl (%eax),%eax
  8005f7:	83 f8 25             	cmp    $0x25,%eax
  8005fa:	74 27                	je     800623 <vprintfmt+0x49>
			if (ch == '\0')
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	75 0d                	jne    80060d <vprintfmt+0x33>
  800600:	e9 9d 04 00 00       	jmp    800aa2 <vprintfmt+0x4c8>
  800605:	85 c0                	test   %eax,%eax
  800607:	0f 84 95 04 00 00    	je     800aa2 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	50                   	push   %eax
  800612:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800614:	83 c6 01             	add    $0x1,%esi
  800617:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	83 f8 25             	cmp    $0x25,%eax
  800621:	75 e2                	jne    800605 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800623:	b9 00 00 00 00       	mov    $0x0,%ecx
  800628:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80062c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800633:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80063a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800641:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800648:	eb 08                	jmp    800652 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80064d:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8d 46 01             	lea    0x1(%esi),%eax
  800655:	89 45 10             	mov    %eax,0x10(%ebp)
  800658:	0f b6 06             	movzbl (%esi),%eax
  80065b:	0f b6 d0             	movzbl %al,%edx
  80065e:	83 e8 23             	sub    $0x23,%eax
  800661:	3c 55                	cmp    $0x55,%al
  800663:	0f 87 fa 03 00 00    	ja     800a63 <vprintfmt+0x489>
  800669:	0f b6 c0             	movzbl %al,%eax
  80066c:	ff 24 85 80 17 80 00 	jmp    *0x801780(,%eax,4)
  800673:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800676:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80067a:	eb d6                	jmp    800652 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80067c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80067f:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800682:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800686:	8d 50 d0             	lea    -0x30(%eax),%edx
  800689:	83 fa 09             	cmp    $0x9,%edx
  80068c:	77 6b                	ja     8006f9 <vprintfmt+0x11f>
  80068e:	8b 75 10             	mov    0x10(%ebp),%esi
  800691:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800694:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800697:	eb 09                	jmp    8006a2 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800699:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80069c:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8006a0:	eb b0                	jmp    800652 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a2:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8006a5:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8006a8:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8006ac:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006af:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006b2:	83 f9 09             	cmp    $0x9,%ecx
  8006b5:	76 eb                	jbe    8006a2 <vprintfmt+0xc8>
  8006b7:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006ba:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006bd:	eb 3d                	jmp    8006fc <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006d0:	eb 2a                	jmp    8006fc <vprintfmt+0x122>
  8006d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006dc:	0f 49 d0             	cmovns %eax,%edx
  8006df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 75 10             	mov    0x10(%ebp),%esi
  8006e5:	e9 68 ff ff ff       	jmp    800652 <vprintfmt+0x78>
  8006ea:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006f4:	e9 59 ff ff ff       	jmp    800652 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800700:	0f 89 4c ff ff ff    	jns    800652 <vprintfmt+0x78>
				width = precision, precision = -1;
  800706:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800709:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800713:	e9 3a ff ff ff       	jmp    800652 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800718:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80071f:	e9 2e ff ff ff       	jmp    800652 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	ff 30                	pushl  (%eax)
  800733:	ff d7                	call   *%edi
			break;
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	e9 b1 fe ff ff       	jmp    8005ee <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8d 50 04             	lea    0x4(%eax),%edx
  800743:	89 55 14             	mov    %edx,0x14(%ebp)
  800746:	8b 00                	mov    (%eax),%eax
  800748:	99                   	cltd   
  800749:	31 d0                	xor    %edx,%eax
  80074b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80074d:	83 f8 08             	cmp    $0x8,%eax
  800750:	7f 0b                	jg     80075d <vprintfmt+0x183>
  800752:	8b 14 85 e0 18 80 00 	mov    0x8018e0(,%eax,4),%edx
  800759:	85 d2                	test   %edx,%edx
  80075b:	75 15                	jne    800772 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80075d:	50                   	push   %eax
  80075e:	68 57 16 80 00       	push   $0x801657
  800763:	53                   	push   %ebx
  800764:	57                   	push   %edi
  800765:	e8 53 fe ff ff       	call   8005bd <printfmt>
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	e9 7c fe ff ff       	jmp    8005ee <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800772:	52                   	push   %edx
  800773:	68 60 16 80 00       	push   $0x801660
  800778:	53                   	push   %ebx
  800779:	57                   	push   %edi
  80077a:	e8 3e fe ff ff       	call   8005bd <printfmt>
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	e9 67 fe ff ff       	jmp    8005ee <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8d 50 04             	lea    0x4(%eax),%edx
  80078d:	89 55 14             	mov    %edx,0x14(%ebp)
  800790:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800792:	85 c0                	test   %eax,%eax
  800794:	b9 50 16 80 00       	mov    $0x801650,%ecx
  800799:	0f 45 c8             	cmovne %eax,%ecx
  80079c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80079f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a3:	7e 06                	jle    8007ab <vprintfmt+0x1d1>
  8007a5:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8007a9:	75 19                	jne    8007c4 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007ae:	8d 70 01             	lea    0x1(%eax),%esi
  8007b1:	0f b6 00             	movzbl (%eax),%eax
  8007b4:	0f be d0             	movsbl %al,%edx
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	0f 85 9f 00 00 00    	jne    80085e <vprintfmt+0x284>
  8007bf:	e9 8c 00 00 00       	jmp    800850 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	ff 75 d0             	pushl  -0x30(%ebp)
  8007ca:	ff 75 cc             	pushl  -0x34(%ebp)
  8007cd:	e8 62 03 00 00       	call   800b34 <strnlen>
  8007d2:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8007d5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	85 c9                	test   %ecx,%ecx
  8007dd:	0f 8e a6 02 00 00    	jle    800a89 <vprintfmt+0x4af>
					putch(padc, putdat);
  8007e3:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007ea:	89 cb                	mov    %ecx,%ebx
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	56                   	push   %esi
  8007f3:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f5:	83 c4 10             	add    $0x10,%esp
  8007f8:	83 eb 01             	sub    $0x1,%ebx
  8007fb:	75 ef                	jne    8007ec <vprintfmt+0x212>
  8007fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800803:	e9 81 02 00 00       	jmp    800a89 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800808:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80080c:	74 1b                	je     800829 <vprintfmt+0x24f>
  80080e:	0f be c0             	movsbl %al,%eax
  800811:	83 e8 20             	sub    $0x20,%eax
  800814:	83 f8 5e             	cmp    $0x5e,%eax
  800817:	76 10                	jbe    800829 <vprintfmt+0x24f>
					putch('?', putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	ff 75 0c             	pushl  0xc(%ebp)
  80081f:	6a 3f                	push   $0x3f
  800821:	ff 55 08             	call   *0x8(%ebp)
  800824:	83 c4 10             	add    $0x10,%esp
  800827:	eb 0d                	jmp    800836 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	ff 75 0c             	pushl  0xc(%ebp)
  80082f:	52                   	push   %edx
  800830:	ff 55 08             	call   *0x8(%ebp)
  800833:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800836:	83 ef 01             	sub    $0x1,%edi
  800839:	83 c6 01             	add    $0x1,%esi
  80083c:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800840:	0f be d0             	movsbl %al,%edx
  800843:	85 d2                	test   %edx,%edx
  800845:	75 31                	jne    800878 <vprintfmt+0x29e>
  800847:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80084a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800850:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800853:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800857:	7f 33                	jg     80088c <vprintfmt+0x2b2>
  800859:	e9 90 fd ff ff       	jmp    8005ee <vprintfmt+0x14>
  80085e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800861:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800864:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800867:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80086a:	eb 0c                	jmp    800878 <vprintfmt+0x29e>
  80086c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80086f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800872:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800875:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800878:	85 db                	test   %ebx,%ebx
  80087a:	78 8c                	js     800808 <vprintfmt+0x22e>
  80087c:	83 eb 01             	sub    $0x1,%ebx
  80087f:	79 87                	jns    800808 <vprintfmt+0x22e>
  800881:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800884:	8b 7d 08             	mov    0x8(%ebp),%edi
  800887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80088a:	eb c4                	jmp    800850 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	6a 20                	push   $0x20
  800892:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800894:	83 c4 10             	add    $0x10,%esp
  800897:	83 ee 01             	sub    $0x1,%esi
  80089a:	75 f0                	jne    80088c <vprintfmt+0x2b2>
  80089c:	e9 4d fd ff ff       	jmp    8005ee <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008a1:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8008a5:	7e 16                	jle    8008bd <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8008a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008aa:	8d 50 08             	lea    0x8(%eax),%edx
  8008ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b0:	8b 50 04             	mov    0x4(%eax),%edx
  8008b3:	8b 00                	mov    (%eax),%eax
  8008b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008bb:	eb 34                	jmp    8008f1 <vprintfmt+0x317>
	else if (lflag)
  8008bd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8008c1:	74 18                	je     8008db <vprintfmt+0x301>
		return va_arg(*ap, long);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 50 04             	lea    0x4(%eax),%edx
  8008c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cc:	8b 30                	mov    (%eax),%esi
  8008ce:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8008d1:	89 f0                	mov    %esi,%eax
  8008d3:	c1 f8 1f             	sar    $0x1f,%eax
  8008d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8008d9:	eb 16                	jmp    8008f1 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  8008db:	8b 45 14             	mov    0x14(%ebp),%eax
  8008de:	8d 50 04             	lea    0x4(%eax),%edx
  8008e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e4:	8b 30                	mov    (%eax),%esi
  8008e6:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	c1 f8 1f             	sar    $0x1f,%eax
  8008ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8008fd:	85 d2                	test   %edx,%edx
  8008ff:	79 28                	jns    800929 <vprintfmt+0x34f>
				putch('-', putdat);
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	53                   	push   %ebx
  800905:	6a 2d                	push   $0x2d
  800907:	ff d7                	call   *%edi
				num = -(long long) num;
  800909:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80090c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80090f:	f7 d8                	neg    %eax
  800911:	83 d2 00             	adc    $0x0,%edx
  800914:	f7 da                	neg    %edx
  800916:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800919:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80091c:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  80091f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800924:	e9 b2 00 00 00       	jmp    8009db <vprintfmt+0x401>
  800929:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  80092e:	85 c9                	test   %ecx,%ecx
  800930:	0f 84 a5 00 00 00    	je     8009db <vprintfmt+0x401>
				putch('+', putdat);
  800936:	83 ec 08             	sub    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 2b                	push   $0x2b
  80093c:	ff d7                	call   *%edi
  80093e:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800941:	b8 0a 00 00 00       	mov    $0xa,%eax
  800946:	e9 90 00 00 00       	jmp    8009db <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  80094b:	85 c9                	test   %ecx,%ecx
  80094d:	74 0b                	je     80095a <vprintfmt+0x380>
				putch('+', putdat);
  80094f:	83 ec 08             	sub    $0x8,%esp
  800952:	53                   	push   %ebx
  800953:	6a 2b                	push   $0x2b
  800955:	ff d7                	call   *%edi
  800957:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  80095a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80095d:	8d 45 14             	lea    0x14(%ebp),%eax
  800960:	e8 01 fc ff ff       	call   800566 <getuint>
  800965:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800968:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80096b:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800970:	eb 69                	jmp    8009db <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800972:	83 ec 08             	sub    $0x8,%esp
  800975:	53                   	push   %ebx
  800976:	6a 30                	push   $0x30
  800978:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80097a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80097d:	8d 45 14             	lea    0x14(%ebp),%eax
  800980:	e8 e1 fb ff ff       	call   800566 <getuint>
  800985:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800988:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80098b:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80098e:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800993:	eb 46                	jmp    8009db <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800995:	83 ec 08             	sub    $0x8,%esp
  800998:	53                   	push   %ebx
  800999:	6a 30                	push   $0x30
  80099b:	ff d7                	call   *%edi
			putch('x', putdat);
  80099d:	83 c4 08             	add    $0x8,%esp
  8009a0:	53                   	push   %ebx
  8009a1:	6a 78                	push   $0x78
  8009a3:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a8:	8d 50 04             	lea    0x4(%eax),%edx
  8009ab:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009ae:	8b 00                	mov    (%eax),%eax
  8009b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009bb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009c3:	eb 16                	jmp    8009db <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009cb:	e8 96 fb ff ff       	call   800566 <getuint>
  8009d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8009d6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009db:	83 ec 0c             	sub    $0xc,%esp
  8009de:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009e2:	56                   	push   %esi
  8009e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009e6:	50                   	push   %eax
  8009e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8009ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8009ed:	89 da                	mov    %ebx,%edx
  8009ef:	89 f8                	mov    %edi,%eax
  8009f1:	e8 55 f9 ff ff       	call   80034b <printnum>
			break;
  8009f6:	83 c4 20             	add    $0x20,%esp
  8009f9:	e9 f0 fb ff ff       	jmp    8005ee <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8009fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800a01:	8d 50 04             	lea    0x4(%eax),%edx
  800a04:	89 55 14             	mov    %edx,0x14(%ebp)
  800a07:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800a09:	85 f6                	test   %esi,%esi
  800a0b:	75 1a                	jne    800a27 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	68 f8 16 80 00       	push   $0x8016f8
  800a15:	68 60 16 80 00       	push   $0x801660
  800a1a:	e8 18 f9 ff ff       	call   800337 <cprintf>
  800a1f:	83 c4 10             	add    $0x10,%esp
  800a22:	e9 c7 fb ff ff       	jmp    8005ee <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800a27:	0f b6 03             	movzbl (%ebx),%eax
  800a2a:	84 c0                	test   %al,%al
  800a2c:	79 1f                	jns    800a4d <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800a2e:	83 ec 08             	sub    $0x8,%esp
  800a31:	68 30 17 80 00       	push   $0x801730
  800a36:	68 60 16 80 00       	push   $0x801660
  800a3b:	e8 f7 f8 ff ff       	call   800337 <cprintf>
						*tmp = *(char *)putdat;
  800a40:	0f b6 03             	movzbl (%ebx),%eax
  800a43:	88 06                	mov    %al,(%esi)
  800a45:	83 c4 10             	add    $0x10,%esp
  800a48:	e9 a1 fb ff ff       	jmp    8005ee <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800a4d:	88 06                	mov    %al,(%esi)
  800a4f:	e9 9a fb ff ff       	jmp    8005ee <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	53                   	push   %ebx
  800a58:	52                   	push   %edx
  800a59:	ff d7                	call   *%edi
			break;
  800a5b:	83 c4 10             	add    $0x10,%esp
  800a5e:	e9 8b fb ff ff       	jmp    8005ee <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a63:	83 ec 08             	sub    $0x8,%esp
  800a66:	53                   	push   %ebx
  800a67:	6a 25                	push   $0x25
  800a69:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a6b:	83 c4 10             	add    $0x10,%esp
  800a6e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a72:	0f 84 73 fb ff ff    	je     8005eb <vprintfmt+0x11>
  800a78:	83 ee 01             	sub    $0x1,%esi
  800a7b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a7f:	75 f7                	jne    800a78 <vprintfmt+0x49e>
  800a81:	89 75 10             	mov    %esi,0x10(%ebp)
  800a84:	e9 65 fb ff ff       	jmp    8005ee <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a89:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a8c:	8d 70 01             	lea    0x1(%eax),%esi
  800a8f:	0f b6 00             	movzbl (%eax),%eax
  800a92:	0f be d0             	movsbl %al,%edx
  800a95:	85 d2                	test   %edx,%edx
  800a97:	0f 85 cf fd ff ff    	jne    80086c <vprintfmt+0x292>
  800a9d:	e9 4c fb ff ff       	jmp    8005ee <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	83 ec 18             	sub    $0x18,%esp
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ab6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800abd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ac0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	74 26                	je     800af1 <vsnprintf+0x47>
  800acb:	85 d2                	test   %edx,%edx
  800acd:	7e 22                	jle    800af1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800acf:	ff 75 14             	pushl  0x14(%ebp)
  800ad2:	ff 75 10             	pushl  0x10(%ebp)
  800ad5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad8:	50                   	push   %eax
  800ad9:	68 a0 05 80 00       	push   $0x8005a0
  800ade:	e8 f7 fa ff ff       	call   8005da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ae3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ae6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	eb 05                	jmp    800af6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800af1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800afe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b01:	50                   	push   %eax
  800b02:	ff 75 10             	pushl  0x10(%ebp)
  800b05:	ff 75 0c             	pushl  0xc(%ebp)
  800b08:	ff 75 08             	pushl  0x8(%ebp)
  800b0b:	e8 9a ff ff ff       	call   800aaa <vsnprintf>
	va_end(ap);

	return rc;
}
  800b10:	c9                   	leave  
  800b11:	c3                   	ret    

00800b12 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b18:	80 3a 00             	cmpb   $0x0,(%edx)
  800b1b:	74 10                	je     800b2d <strlen+0x1b>
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b22:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b25:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b29:	75 f7                	jne    800b22 <strlen+0x10>
  800b2b:	eb 05                	jmp    800b32 <strlen+0x20>
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	53                   	push   %ebx
  800b38:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b3e:	85 c9                	test   %ecx,%ecx
  800b40:	74 1c                	je     800b5e <strnlen+0x2a>
  800b42:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b45:	74 1e                	je     800b65 <strnlen+0x31>
  800b47:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b4c:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b4e:	39 ca                	cmp    %ecx,%edx
  800b50:	74 18                	je     800b6a <strnlen+0x36>
  800b52:	83 c2 01             	add    $0x1,%edx
  800b55:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b5a:	75 f0                	jne    800b4c <strnlen+0x18>
  800b5c:	eb 0c                	jmp    800b6a <strnlen+0x36>
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	eb 05                	jmp    800b6a <strnlen+0x36>
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	53                   	push   %ebx
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b77:	89 c2                	mov    %eax,%edx
  800b79:	83 c2 01             	add    $0x1,%edx
  800b7c:	83 c1 01             	add    $0x1,%ecx
  800b7f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b83:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b86:	84 db                	test   %bl,%bl
  800b88:	75 ef                	jne    800b79 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	53                   	push   %ebx
  800b91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b94:	53                   	push   %ebx
  800b95:	e8 78 ff ff ff       	call   800b12 <strlen>
  800b9a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ba0:	01 d8                	add    %ebx,%eax
  800ba2:	50                   	push   %eax
  800ba3:	e8 c5 ff ff ff       	call   800b6d <strcpy>
	return dst;
}
  800ba8:	89 d8                	mov    %ebx,%eax
  800baa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bbd:	85 db                	test   %ebx,%ebx
  800bbf:	74 17                	je     800bd8 <strncpy+0x29>
  800bc1:	01 f3                	add    %esi,%ebx
  800bc3:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	0f b6 02             	movzbl (%edx),%eax
  800bcb:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bce:	80 3a 01             	cmpb   $0x1,(%edx)
  800bd1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd4:	39 cb                	cmp    %ecx,%ebx
  800bd6:	75 ed                	jne    800bc5 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bd8:	89 f0                	mov    %esi,%eax
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	8b 75 08             	mov    0x8(%ebp),%esi
  800be6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be9:	8b 55 10             	mov    0x10(%ebp),%edx
  800bec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bee:	85 d2                	test   %edx,%edx
  800bf0:	74 35                	je     800c27 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800bf2:	89 d0                	mov    %edx,%eax
  800bf4:	83 e8 01             	sub    $0x1,%eax
  800bf7:	74 25                	je     800c1e <strlcpy+0x40>
  800bf9:	0f b6 0b             	movzbl (%ebx),%ecx
  800bfc:	84 c9                	test   %cl,%cl
  800bfe:	74 22                	je     800c22 <strlcpy+0x44>
  800c00:	8d 53 01             	lea    0x1(%ebx),%edx
  800c03:	01 c3                	add    %eax,%ebx
  800c05:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800c07:	83 c0 01             	add    $0x1,%eax
  800c0a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c0d:	39 da                	cmp    %ebx,%edx
  800c0f:	74 13                	je     800c24 <strlcpy+0x46>
  800c11:	83 c2 01             	add    $0x1,%edx
  800c14:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800c18:	84 c9                	test   %cl,%cl
  800c1a:	75 eb                	jne    800c07 <strlcpy+0x29>
  800c1c:	eb 06                	jmp    800c24 <strlcpy+0x46>
  800c1e:	89 f0                	mov    %esi,%eax
  800c20:	eb 02                	jmp    800c24 <strlcpy+0x46>
  800c22:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c24:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c27:	29 f0                	sub    %esi,%eax
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c33:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c36:	0f b6 01             	movzbl (%ecx),%eax
  800c39:	84 c0                	test   %al,%al
  800c3b:	74 15                	je     800c52 <strcmp+0x25>
  800c3d:	3a 02                	cmp    (%edx),%al
  800c3f:	75 11                	jne    800c52 <strcmp+0x25>
		p++, q++;
  800c41:	83 c1 01             	add    $0x1,%ecx
  800c44:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c47:	0f b6 01             	movzbl (%ecx),%eax
  800c4a:	84 c0                	test   %al,%al
  800c4c:	74 04                	je     800c52 <strcmp+0x25>
  800c4e:	3a 02                	cmp    (%edx),%al
  800c50:	74 ef                	je     800c41 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c52:	0f b6 c0             	movzbl %al,%eax
  800c55:	0f b6 12             	movzbl (%edx),%edx
  800c58:	29 d0                	sub    %edx,%eax
}
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c67:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c6a:	85 f6                	test   %esi,%esi
  800c6c:	74 29                	je     800c97 <strncmp+0x3b>
  800c6e:	0f b6 03             	movzbl (%ebx),%eax
  800c71:	84 c0                	test   %al,%al
  800c73:	74 30                	je     800ca5 <strncmp+0x49>
  800c75:	3a 02                	cmp    (%edx),%al
  800c77:	75 2c                	jne    800ca5 <strncmp+0x49>
  800c79:	8d 43 01             	lea    0x1(%ebx),%eax
  800c7c:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c7e:	89 c3                	mov    %eax,%ebx
  800c80:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c83:	39 c6                	cmp    %eax,%esi
  800c85:	74 17                	je     800c9e <strncmp+0x42>
  800c87:	0f b6 08             	movzbl (%eax),%ecx
  800c8a:	84 c9                	test   %cl,%cl
  800c8c:	74 17                	je     800ca5 <strncmp+0x49>
  800c8e:	83 c0 01             	add    $0x1,%eax
  800c91:	3a 0a                	cmp    (%edx),%cl
  800c93:	74 e9                	je     800c7e <strncmp+0x22>
  800c95:	eb 0e                	jmp    800ca5 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c97:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9c:	eb 0f                	jmp    800cad <strncmp+0x51>
  800c9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca3:	eb 08                	jmp    800cad <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca5:	0f b6 03             	movzbl (%ebx),%eax
  800ca8:	0f b6 12             	movzbl (%edx),%edx
  800cab:	29 d0                	sub    %edx,%eax
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	53                   	push   %ebx
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800cbb:	0f b6 10             	movzbl (%eax),%edx
  800cbe:	84 d2                	test   %dl,%dl
  800cc0:	74 1d                	je     800cdf <strchr+0x2e>
  800cc2:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800cc4:	38 d3                	cmp    %dl,%bl
  800cc6:	75 06                	jne    800cce <strchr+0x1d>
  800cc8:	eb 1a                	jmp    800ce4 <strchr+0x33>
  800cca:	38 ca                	cmp    %cl,%dl
  800ccc:	74 16                	je     800ce4 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cce:	83 c0 01             	add    $0x1,%eax
  800cd1:	0f b6 10             	movzbl (%eax),%edx
  800cd4:	84 d2                	test   %dl,%dl
  800cd6:	75 f2                	jne    800cca <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdd:	eb 05                	jmp    800ce4 <strchr+0x33>
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	53                   	push   %ebx
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800cf1:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800cf4:	38 d3                	cmp    %dl,%bl
  800cf6:	74 14                	je     800d0c <strfind+0x25>
  800cf8:	89 d1                	mov    %edx,%ecx
  800cfa:	84 db                	test   %bl,%bl
  800cfc:	74 0e                	je     800d0c <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cfe:	83 c0 01             	add    $0x1,%eax
  800d01:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d04:	38 ca                	cmp    %cl,%dl
  800d06:	74 04                	je     800d0c <strfind+0x25>
  800d08:	84 d2                	test   %dl,%dl
  800d0a:	75 f2                	jne    800cfe <strfind+0x17>
			break;
	return (char *) s;
}
  800d0c:	5b                   	pop    %ebx
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d1b:	85 c9                	test   %ecx,%ecx
  800d1d:	74 36                	je     800d55 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d25:	75 28                	jne    800d4f <memset+0x40>
  800d27:	f6 c1 03             	test   $0x3,%cl
  800d2a:	75 23                	jne    800d4f <memset+0x40>
		c &= 0xFF;
  800d2c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d30:	89 d3                	mov    %edx,%ebx
  800d32:	c1 e3 08             	shl    $0x8,%ebx
  800d35:	89 d6                	mov    %edx,%esi
  800d37:	c1 e6 18             	shl    $0x18,%esi
  800d3a:	89 d0                	mov    %edx,%eax
  800d3c:	c1 e0 10             	shl    $0x10,%eax
  800d3f:	09 f0                	or     %esi,%eax
  800d41:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d43:	89 d8                	mov    %ebx,%eax
  800d45:	09 d0                	or     %edx,%eax
  800d47:	c1 e9 02             	shr    $0x2,%ecx
  800d4a:	fc                   	cld    
  800d4b:	f3 ab                	rep stos %eax,%es:(%edi)
  800d4d:	eb 06                	jmp    800d55 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d52:	fc                   	cld    
  800d53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d55:	89 f8                	mov    %edi,%eax
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d6a:	39 c6                	cmp    %eax,%esi
  800d6c:	73 35                	jae    800da3 <memmove+0x47>
  800d6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d71:	39 d0                	cmp    %edx,%eax
  800d73:	73 2e                	jae    800da3 <memmove+0x47>
		s += n;
		d += n;
  800d75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d78:	89 d6                	mov    %edx,%esi
  800d7a:	09 fe                	or     %edi,%esi
  800d7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d82:	75 13                	jne    800d97 <memmove+0x3b>
  800d84:	f6 c1 03             	test   $0x3,%cl
  800d87:	75 0e                	jne    800d97 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d89:	83 ef 04             	sub    $0x4,%edi
  800d8c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d8f:	c1 e9 02             	shr    $0x2,%ecx
  800d92:	fd                   	std    
  800d93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d95:	eb 09                	jmp    800da0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d97:	83 ef 01             	sub    $0x1,%edi
  800d9a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d9d:	fd                   	std    
  800d9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800da0:	fc                   	cld    
  800da1:	eb 1d                	jmp    800dc0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da3:	89 f2                	mov    %esi,%edx
  800da5:	09 c2                	or     %eax,%edx
  800da7:	f6 c2 03             	test   $0x3,%dl
  800daa:	75 0f                	jne    800dbb <memmove+0x5f>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 0a                	jne    800dbb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800db1:	c1 e9 02             	shr    $0x2,%ecx
  800db4:	89 c7                	mov    %eax,%edi
  800db6:	fc                   	cld    
  800db7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800db9:	eb 05                	jmp    800dc0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dbb:	89 c7                	mov    %eax,%edi
  800dbd:	fc                   	cld    
  800dbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800dc7:	ff 75 10             	pushl  0x10(%ebp)
  800dca:	ff 75 0c             	pushl  0xc(%ebp)
  800dcd:	ff 75 08             	pushl  0x8(%ebp)
  800dd0:	e8 87 ff ff ff       	call   800d5c <memmove>
}
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800de0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800de6:	85 c0                	test   %eax,%eax
  800de8:	74 39                	je     800e23 <memcmp+0x4c>
  800dea:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ded:	0f b6 13             	movzbl (%ebx),%edx
  800df0:	0f b6 0e             	movzbl (%esi),%ecx
  800df3:	38 ca                	cmp    %cl,%dl
  800df5:	75 17                	jne    800e0e <memcmp+0x37>
  800df7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfc:	eb 1a                	jmp    800e18 <memcmp+0x41>
  800dfe:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800e03:	83 c0 01             	add    $0x1,%eax
  800e06:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800e0a:	38 ca                	cmp    %cl,%dl
  800e0c:	74 0a                	je     800e18 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800e0e:	0f b6 c2             	movzbl %dl,%eax
  800e11:	0f b6 c9             	movzbl %cl,%ecx
  800e14:	29 c8                	sub    %ecx,%eax
  800e16:	eb 10                	jmp    800e28 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e18:	39 f8                	cmp    %edi,%eax
  800e1a:	75 e2                	jne    800dfe <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e21:	eb 05                	jmp    800e28 <memcmp+0x51>
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	53                   	push   %ebx
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800e34:	89 d0                	mov    %edx,%eax
  800e36:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800e39:	39 c2                	cmp    %eax,%edx
  800e3b:	73 1d                	jae    800e5a <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e3d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800e41:	0f b6 0a             	movzbl (%edx),%ecx
  800e44:	39 d9                	cmp    %ebx,%ecx
  800e46:	75 09                	jne    800e51 <memfind+0x24>
  800e48:	eb 14                	jmp    800e5e <memfind+0x31>
  800e4a:	0f b6 0a             	movzbl (%edx),%ecx
  800e4d:	39 d9                	cmp    %ebx,%ecx
  800e4f:	74 11                	je     800e62 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e51:	83 c2 01             	add    $0x1,%edx
  800e54:	39 d0                	cmp    %edx,%eax
  800e56:	75 f2                	jne    800e4a <memfind+0x1d>
  800e58:	eb 0a                	jmp    800e64 <memfind+0x37>
  800e5a:	89 d0                	mov    %edx,%eax
  800e5c:	eb 06                	jmp    800e64 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e5e:	89 d0                	mov    %edx,%eax
  800e60:	eb 02                	jmp    800e64 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e62:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e64:	5b                   	pop    %ebx
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e73:	0f b6 01             	movzbl (%ecx),%eax
  800e76:	3c 20                	cmp    $0x20,%al
  800e78:	74 04                	je     800e7e <strtol+0x17>
  800e7a:	3c 09                	cmp    $0x9,%al
  800e7c:	75 0e                	jne    800e8c <strtol+0x25>
		s++;
  800e7e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e81:	0f b6 01             	movzbl (%ecx),%eax
  800e84:	3c 20                	cmp    $0x20,%al
  800e86:	74 f6                	je     800e7e <strtol+0x17>
  800e88:	3c 09                	cmp    $0x9,%al
  800e8a:	74 f2                	je     800e7e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e8c:	3c 2b                	cmp    $0x2b,%al
  800e8e:	75 0a                	jne    800e9a <strtol+0x33>
		s++;
  800e90:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e93:	bf 00 00 00 00       	mov    $0x0,%edi
  800e98:	eb 11                	jmp    800eab <strtol+0x44>
  800e9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e9f:	3c 2d                	cmp    $0x2d,%al
  800ea1:	75 08                	jne    800eab <strtol+0x44>
		s++, neg = 1;
  800ea3:	83 c1 01             	add    $0x1,%ecx
  800ea6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800eb1:	75 15                	jne    800ec8 <strtol+0x61>
  800eb3:	80 39 30             	cmpb   $0x30,(%ecx)
  800eb6:	75 10                	jne    800ec8 <strtol+0x61>
  800eb8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ebc:	75 7c                	jne    800f3a <strtol+0xd3>
		s += 2, base = 16;
  800ebe:	83 c1 02             	add    $0x2,%ecx
  800ec1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ec6:	eb 16                	jmp    800ede <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ec8:	85 db                	test   %ebx,%ebx
  800eca:	75 12                	jne    800ede <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ecc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ed1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ed4:	75 08                	jne    800ede <strtol+0x77>
		s++, base = 8;
  800ed6:	83 c1 01             	add    $0x1,%ecx
  800ed9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ee6:	0f b6 11             	movzbl (%ecx),%edx
  800ee9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800eec:	89 f3                	mov    %esi,%ebx
  800eee:	80 fb 09             	cmp    $0x9,%bl
  800ef1:	77 08                	ja     800efb <strtol+0x94>
			dig = *s - '0';
  800ef3:	0f be d2             	movsbl %dl,%edx
  800ef6:	83 ea 30             	sub    $0x30,%edx
  800ef9:	eb 22                	jmp    800f1d <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800efb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800efe:	89 f3                	mov    %esi,%ebx
  800f00:	80 fb 19             	cmp    $0x19,%bl
  800f03:	77 08                	ja     800f0d <strtol+0xa6>
			dig = *s - 'a' + 10;
  800f05:	0f be d2             	movsbl %dl,%edx
  800f08:	83 ea 57             	sub    $0x57,%edx
  800f0b:	eb 10                	jmp    800f1d <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800f0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f10:	89 f3                	mov    %esi,%ebx
  800f12:	80 fb 19             	cmp    $0x19,%bl
  800f15:	77 16                	ja     800f2d <strtol+0xc6>
			dig = *s - 'A' + 10;
  800f17:	0f be d2             	movsbl %dl,%edx
  800f1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f20:	7d 0b                	jge    800f2d <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800f22:	83 c1 01             	add    $0x1,%ecx
  800f25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f2b:	eb b9                	jmp    800ee6 <strtol+0x7f>

	if (endptr)
  800f2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f31:	74 0d                	je     800f40 <strtol+0xd9>
		*endptr = (char *) s;
  800f33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f36:	89 0e                	mov    %ecx,(%esi)
  800f38:	eb 06                	jmp    800f40 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f3a:	85 db                	test   %ebx,%ebx
  800f3c:	74 98                	je     800ed6 <strtol+0x6f>
  800f3e:	eb 9e                	jmp    800ede <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f40:	89 c2                	mov    %eax,%edx
  800f42:	f7 da                	neg    %edx
  800f44:	85 ff                	test   %edi,%edi
  800f46:	0f 45 c2             	cmovne %edx,%eax
}
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	57                   	push   %edi
  800f52:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f53:	b8 00 00 00 00       	mov    $0x0,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	89 c3                	mov    %eax,%ebx
  800f60:	89 c7                	mov    %eax,%edi
  800f62:	51                   	push   %ecx
  800f63:	52                   	push   %edx
  800f64:	53                   	push   %ebx
  800f65:	54                   	push   %esp
  800f66:	55                   	push   %ebp
  800f67:	56                   	push   %esi
  800f68:	57                   	push   %edi
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	8d 35 73 0f 80 00    	lea    0x800f73,%esi
  800f71:	0f 34                	sysenter 

00800f73 <label_21>:
  800f73:	5f                   	pop    %edi
  800f74:	5e                   	pop    %esi
  800f75:	5d                   	pop    %ebp
  800f76:	5c                   	pop    %esp
  800f77:	5b                   	pop    %ebx
  800f78:	5a                   	pop    %edx
  800f79:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f7a:	5b                   	pop    %ebx
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f88:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8d:	89 ca                	mov    %ecx,%edx
  800f8f:	89 cb                	mov    %ecx,%ebx
  800f91:	89 cf                	mov    %ecx,%edi
  800f93:	51                   	push   %ecx
  800f94:	52                   	push   %edx
  800f95:	53                   	push   %ebx
  800f96:	54                   	push   %esp
  800f97:	55                   	push   %ebp
  800f98:	56                   	push   %esi
  800f99:	57                   	push   %edi
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	8d 35 a4 0f 80 00    	lea    0x800fa4,%esi
  800fa2:	0f 34                	sysenter 

00800fa4 <label_55>:
  800fa4:	5f                   	pop    %edi
  800fa5:	5e                   	pop    %esi
  800fa6:	5d                   	pop    %ebp
  800fa7:	5c                   	pop    %esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5a                   	pop    %edx
  800faa:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fab:	5b                   	pop    %ebx
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	57                   	push   %edi
  800fb3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb9:	b8 03 00 00 00       	mov    $0x3,%eax
  800fbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc1:	89 d9                	mov    %ebx,%ecx
  800fc3:	89 df                	mov    %ebx,%edi
  800fc5:	51                   	push   %ecx
  800fc6:	52                   	push   %edx
  800fc7:	53                   	push   %ebx
  800fc8:	54                   	push   %esp
  800fc9:	55                   	push   %ebp
  800fca:	56                   	push   %esi
  800fcb:	57                   	push   %edi
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	8d 35 d6 0f 80 00    	lea    0x800fd6,%esi
  800fd4:	0f 34                	sysenter 

00800fd6 <label_90>:
  800fd6:	5f                   	pop    %edi
  800fd7:	5e                   	pop    %esi
  800fd8:	5d                   	pop    %ebp
  800fd9:	5c                   	pop    %esp
  800fda:	5b                   	pop    %ebx
  800fdb:	5a                   	pop    %edx
  800fdc:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	7e 17                	jle    800ff8 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	50                   	push   %eax
  800fe5:	6a 03                	push   $0x3
  800fe7:	68 04 19 80 00       	push   $0x801904
  800fec:	6a 2a                	push   $0x2a
  800fee:	68 21 19 80 00       	push   $0x801921
  800ff3:	e8 4c f2 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ff8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffb:	5b                   	pop    %ebx
  800ffc:	5f                   	pop    %edi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	57                   	push   %edi
  801003:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801004:	b9 00 00 00 00       	mov    $0x0,%ecx
  801009:	b8 02 00 00 00       	mov    $0x2,%eax
  80100e:	89 ca                	mov    %ecx,%edx
  801010:	89 cb                	mov    %ecx,%ebx
  801012:	89 cf                	mov    %ecx,%edi
  801014:	51                   	push   %ecx
  801015:	52                   	push   %edx
  801016:	53                   	push   %ebx
  801017:	54                   	push   %esp
  801018:	55                   	push   %ebp
  801019:	56                   	push   %esi
  80101a:	57                   	push   %edi
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	8d 35 25 10 80 00    	lea    0x801025,%esi
  801023:	0f 34                	sysenter 

00801025 <label_139>:
  801025:	5f                   	pop    %edi
  801026:	5e                   	pop    %esi
  801027:	5d                   	pop    %ebp
  801028:	5c                   	pop    %esp
  801029:	5b                   	pop    %ebx
  80102a:	5a                   	pop    %edx
  80102b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102c:	5b                   	pop    %ebx
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801035:	bf 00 00 00 00       	mov    $0x0,%edi
  80103a:	b8 04 00 00 00       	mov    $0x4,%eax
  80103f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801042:	8b 55 08             	mov    0x8(%ebp),%edx
  801045:	89 fb                	mov    %edi,%ebx
  801047:	51                   	push   %ecx
  801048:	52                   	push   %edx
  801049:	53                   	push   %ebx
  80104a:	54                   	push   %esp
  80104b:	55                   	push   %ebp
  80104c:	56                   	push   %esi
  80104d:	57                   	push   %edi
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	8d 35 58 10 80 00    	lea    0x801058,%esi
  801056:	0f 34                	sysenter 

00801058 <label_174>:
  801058:	5f                   	pop    %edi
  801059:	5e                   	pop    %esi
  80105a:	5d                   	pop    %ebp
  80105b:	5c                   	pop    %esp
  80105c:	5b                   	pop    %ebx
  80105d:	5a                   	pop    %edx
  80105e:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80105f:	5b                   	pop    %ebx
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <sys_yield>:

void
sys_yield(void)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	57                   	push   %edi
  801067:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801068:	ba 00 00 00 00       	mov    $0x0,%edx
  80106d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801072:	89 d1                	mov    %edx,%ecx
  801074:	89 d3                	mov    %edx,%ebx
  801076:	89 d7                	mov    %edx,%edi
  801078:	51                   	push   %ecx
  801079:	52                   	push   %edx
  80107a:	53                   	push   %ebx
  80107b:	54                   	push   %esp
  80107c:	55                   	push   %ebp
  80107d:	56                   	push   %esi
  80107e:	57                   	push   %edi
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	8d 35 89 10 80 00    	lea    0x801089,%esi
  801087:	0f 34                	sysenter 

00801089 <label_209>:
  801089:	5f                   	pop    %edi
  80108a:	5e                   	pop    %esi
  80108b:	5d                   	pop    %ebp
  80108c:	5c                   	pop    %esp
  80108d:	5b                   	pop    %ebx
  80108e:	5a                   	pop    %edx
  80108f:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801090:	5b                   	pop    %ebx
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801099:	bf 00 00 00 00       	mov    $0x0,%edi
  80109e:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ac:	51                   	push   %ecx
  8010ad:	52                   	push   %edx
  8010ae:	53                   	push   %ebx
  8010af:	54                   	push   %esp
  8010b0:	55                   	push   %ebp
  8010b1:	56                   	push   %esi
  8010b2:	57                   	push   %edi
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	8d 35 bd 10 80 00    	lea    0x8010bd,%esi
  8010bb:	0f 34                	sysenter 

008010bd <label_244>:
  8010bd:	5f                   	pop    %edi
  8010be:	5e                   	pop    %esi
  8010bf:	5d                   	pop    %ebp
  8010c0:	5c                   	pop    %esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5a                   	pop    %edx
  8010c3:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	7e 17                	jle    8010df <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	50                   	push   %eax
  8010cc:	6a 05                	push   $0x5
  8010ce:	68 04 19 80 00       	push   $0x801904
  8010d3:	6a 2a                	push   $0x2a
  8010d5:	68 21 19 80 00       	push   $0x801921
  8010da:	e8 65 f1 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010fc:	51                   	push   %ecx
  8010fd:	52                   	push   %edx
  8010fe:	53                   	push   %ebx
  8010ff:	54                   	push   %esp
  801100:	55                   	push   %ebp
  801101:	56                   	push   %esi
  801102:	57                   	push   %edi
  801103:	89 e5                	mov    %esp,%ebp
  801105:	8d 35 0d 11 80 00    	lea    0x80110d,%esi
  80110b:	0f 34                	sysenter 

0080110d <label_295>:
  80110d:	5f                   	pop    %edi
  80110e:	5e                   	pop    %esi
  80110f:	5d                   	pop    %ebp
  801110:	5c                   	pop    %esp
  801111:	5b                   	pop    %ebx
  801112:	5a                   	pop    %edx
  801113:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801114:	85 c0                	test   %eax,%eax
  801116:	7e 17                	jle    80112f <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	50                   	push   %eax
  80111c:	6a 06                	push   $0x6
  80111e:	68 04 19 80 00       	push   $0x801904
  801123:	6a 2a                	push   $0x2a
  801125:	68 21 19 80 00       	push   $0x801921
  80112a:	e8 15 f1 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80112f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80113b:	bf 00 00 00 00       	mov    $0x0,%edi
  801140:	b8 07 00 00 00       	mov    $0x7,%eax
  801145:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801148:	8b 55 08             	mov    0x8(%ebp),%edx
  80114b:	89 fb                	mov    %edi,%ebx
  80114d:	51                   	push   %ecx
  80114e:	52                   	push   %edx
  80114f:	53                   	push   %ebx
  801150:	54                   	push   %esp
  801151:	55                   	push   %ebp
  801152:	56                   	push   %esi
  801153:	57                   	push   %edi
  801154:	89 e5                	mov    %esp,%ebp
  801156:	8d 35 5e 11 80 00    	lea    0x80115e,%esi
  80115c:	0f 34                	sysenter 

0080115e <label_344>:
  80115e:	5f                   	pop    %edi
  80115f:	5e                   	pop    %esi
  801160:	5d                   	pop    %ebp
  801161:	5c                   	pop    %esp
  801162:	5b                   	pop    %ebx
  801163:	5a                   	pop    %edx
  801164:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801165:	85 c0                	test   %eax,%eax
  801167:	7e 17                	jle    801180 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  801169:	83 ec 0c             	sub    $0xc,%esp
  80116c:	50                   	push   %eax
  80116d:	6a 07                	push   $0x7
  80116f:	68 04 19 80 00       	push   $0x801904
  801174:	6a 2a                	push   $0x2a
  801176:	68 21 19 80 00       	push   $0x801921
  80117b:	e8 c4 f0 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80118c:	bf 00 00 00 00       	mov    $0x0,%edi
  801191:	b8 09 00 00 00       	mov    $0x9,%eax
  801196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801199:	8b 55 08             	mov    0x8(%ebp),%edx
  80119c:	89 fb                	mov    %edi,%ebx
  80119e:	51                   	push   %ecx
  80119f:	52                   	push   %edx
  8011a0:	53                   	push   %ebx
  8011a1:	54                   	push   %esp
  8011a2:	55                   	push   %ebp
  8011a3:	56                   	push   %esi
  8011a4:	57                   	push   %edi
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8d 35 af 11 80 00    	lea    0x8011af,%esi
  8011ad:	0f 34                	sysenter 

008011af <label_393>:
  8011af:	5f                   	pop    %edi
  8011b0:	5e                   	pop    %esi
  8011b1:	5d                   	pop    %ebp
  8011b2:	5c                   	pop    %esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5a                   	pop    %edx
  8011b5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	7e 17                	jle    8011d1 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	50                   	push   %eax
  8011be:	6a 09                	push   $0x9
  8011c0:	68 04 19 80 00       	push   $0x801904
  8011c5:	6a 2a                	push   $0x2a
  8011c7:	68 21 19 80 00       	push   $0x801921
  8011cc:	e8 73 f0 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	57                   	push   %edi
  8011dc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ed:	89 fb                	mov    %edi,%ebx
  8011ef:	51                   	push   %ecx
  8011f0:	52                   	push   %edx
  8011f1:	53                   	push   %ebx
  8011f2:	54                   	push   %esp
  8011f3:	55                   	push   %ebp
  8011f4:	56                   	push   %esi
  8011f5:	57                   	push   %edi
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	8d 35 00 12 80 00    	lea    0x801200,%esi
  8011fe:	0f 34                	sysenter 

00801200 <label_442>:
  801200:	5f                   	pop    %edi
  801201:	5e                   	pop    %esi
  801202:	5d                   	pop    %ebp
  801203:	5c                   	pop    %esp
  801204:	5b                   	pop    %ebx
  801205:	5a                   	pop    %edx
  801206:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801207:	85 c0                	test   %eax,%eax
  801209:	7e 17                	jle    801222 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80120b:	83 ec 0c             	sub    $0xc,%esp
  80120e:	50                   	push   %eax
  80120f:	6a 0a                	push   $0xa
  801211:	68 04 19 80 00       	push   $0x801904
  801216:	6a 2a                	push   $0x2a
  801218:	68 21 19 80 00       	push   $0x801921
  80121d:	e8 22 f0 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801222:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801225:	5b                   	pop    %ebx
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	57                   	push   %edi
  80122d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80122e:	b8 0c 00 00 00       	mov    $0xc,%eax
  801233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801236:	8b 55 08             	mov    0x8(%ebp),%edx
  801239:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80123c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80123f:	51                   	push   %ecx
  801240:	52                   	push   %edx
  801241:	53                   	push   %ebx
  801242:	54                   	push   %esp
  801243:	55                   	push   %ebp
  801244:	56                   	push   %esi
  801245:	57                   	push   %edi
  801246:	89 e5                	mov    %esp,%ebp
  801248:	8d 35 50 12 80 00    	lea    0x801250,%esi
  80124e:	0f 34                	sysenter 

00801250 <label_493>:
  801250:	5f                   	pop    %edi
  801251:	5e                   	pop    %esi
  801252:	5d                   	pop    %ebp
  801253:	5c                   	pop    %esp
  801254:	5b                   	pop    %ebx
  801255:	5a                   	pop    %edx
  801256:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801257:	5b                   	pop    %ebx
  801258:	5f                   	pop    %edi
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	57                   	push   %edi
  80125f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801260:	bb 00 00 00 00       	mov    $0x0,%ebx
  801265:	b8 0d 00 00 00       	mov    $0xd,%eax
  80126a:	8b 55 08             	mov    0x8(%ebp),%edx
  80126d:	89 d9                	mov    %ebx,%ecx
  80126f:	89 df                	mov    %ebx,%edi
  801271:	51                   	push   %ecx
  801272:	52                   	push   %edx
  801273:	53                   	push   %ebx
  801274:	54                   	push   %esp
  801275:	55                   	push   %ebp
  801276:	56                   	push   %esi
  801277:	57                   	push   %edi
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	8d 35 82 12 80 00    	lea    0x801282,%esi
  801280:	0f 34                	sysenter 

00801282 <label_528>:
  801282:	5f                   	pop    %edi
  801283:	5e                   	pop    %esi
  801284:	5d                   	pop    %ebp
  801285:	5c                   	pop    %esp
  801286:	5b                   	pop    %ebx
  801287:	5a                   	pop    %edx
  801288:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801289:	85 c0                	test   %eax,%eax
  80128b:	7e 17                	jle    8012a4 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	50                   	push   %eax
  801291:	6a 0d                	push   $0xd
  801293:	68 04 19 80 00       	push   $0x801904
  801298:	6a 2a                	push   $0x2a
  80129a:	68 21 19 80 00       	push   $0x801921
  80129f:	e8 a0 ef ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5f                   	pop    %edi
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	57                   	push   %edi
  8012af:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b5:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bd:	89 cb                	mov    %ecx,%ebx
  8012bf:	89 cf                	mov    %ecx,%edi
  8012c1:	51                   	push   %ecx
  8012c2:	52                   	push   %edx
  8012c3:	53                   	push   %ebx
  8012c4:	54                   	push   %esp
  8012c5:	55                   	push   %ebp
  8012c6:	56                   	push   %esi
  8012c7:	57                   	push   %edi
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	8d 35 d2 12 80 00    	lea    0x8012d2,%esi
  8012d0:	0f 34                	sysenter 

008012d2 <label_577>:
  8012d2:	5f                   	pop    %edi
  8012d3:	5e                   	pop    %esi
  8012d4:	5d                   	pop    %ebp
  8012d5:	5c                   	pop    %esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5a                   	pop    %edx
  8012d8:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8012d9:	5b                   	pop    %ebx
  8012da:	5f                   	pop    %edi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    
  8012dd:	66 90                	xchg   %ax,%ax
  8012df:	90                   	nop

008012e0 <__udivdi3>:
  8012e0:	55                   	push   %ebp
  8012e1:	57                   	push   %edi
  8012e2:	56                   	push   %esi
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 1c             	sub    $0x1c,%esp
  8012e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8012eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8012ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8012f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012f7:	85 f6                	test   %esi,%esi
  8012f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012fd:	89 ca                	mov    %ecx,%edx
  8012ff:	89 f8                	mov    %edi,%eax
  801301:	75 3d                	jne    801340 <__udivdi3+0x60>
  801303:	39 cf                	cmp    %ecx,%edi
  801305:	0f 87 c5 00 00 00    	ja     8013d0 <__udivdi3+0xf0>
  80130b:	85 ff                	test   %edi,%edi
  80130d:	89 fd                	mov    %edi,%ebp
  80130f:	75 0b                	jne    80131c <__udivdi3+0x3c>
  801311:	b8 01 00 00 00       	mov    $0x1,%eax
  801316:	31 d2                	xor    %edx,%edx
  801318:	f7 f7                	div    %edi
  80131a:	89 c5                	mov    %eax,%ebp
  80131c:	89 c8                	mov    %ecx,%eax
  80131e:	31 d2                	xor    %edx,%edx
  801320:	f7 f5                	div    %ebp
  801322:	89 c1                	mov    %eax,%ecx
  801324:	89 d8                	mov    %ebx,%eax
  801326:	89 cf                	mov    %ecx,%edi
  801328:	f7 f5                	div    %ebp
  80132a:	89 c3                	mov    %eax,%ebx
  80132c:	89 d8                	mov    %ebx,%eax
  80132e:	89 fa                	mov    %edi,%edx
  801330:	83 c4 1c             	add    $0x1c,%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    
  801338:	90                   	nop
  801339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801340:	39 ce                	cmp    %ecx,%esi
  801342:	77 74                	ja     8013b8 <__udivdi3+0xd8>
  801344:	0f bd fe             	bsr    %esi,%edi
  801347:	83 f7 1f             	xor    $0x1f,%edi
  80134a:	0f 84 98 00 00 00    	je     8013e8 <__udivdi3+0x108>
  801350:	bb 20 00 00 00       	mov    $0x20,%ebx
  801355:	89 f9                	mov    %edi,%ecx
  801357:	89 c5                	mov    %eax,%ebp
  801359:	29 fb                	sub    %edi,%ebx
  80135b:	d3 e6                	shl    %cl,%esi
  80135d:	89 d9                	mov    %ebx,%ecx
  80135f:	d3 ed                	shr    %cl,%ebp
  801361:	89 f9                	mov    %edi,%ecx
  801363:	d3 e0                	shl    %cl,%eax
  801365:	09 ee                	or     %ebp,%esi
  801367:	89 d9                	mov    %ebx,%ecx
  801369:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80136d:	89 d5                	mov    %edx,%ebp
  80136f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801373:	d3 ed                	shr    %cl,%ebp
  801375:	89 f9                	mov    %edi,%ecx
  801377:	d3 e2                	shl    %cl,%edx
  801379:	89 d9                	mov    %ebx,%ecx
  80137b:	d3 e8                	shr    %cl,%eax
  80137d:	09 c2                	or     %eax,%edx
  80137f:	89 d0                	mov    %edx,%eax
  801381:	89 ea                	mov    %ebp,%edx
  801383:	f7 f6                	div    %esi
  801385:	89 d5                	mov    %edx,%ebp
  801387:	89 c3                	mov    %eax,%ebx
  801389:	f7 64 24 0c          	mull   0xc(%esp)
  80138d:	39 d5                	cmp    %edx,%ebp
  80138f:	72 10                	jb     8013a1 <__udivdi3+0xc1>
  801391:	8b 74 24 08          	mov    0x8(%esp),%esi
  801395:	89 f9                	mov    %edi,%ecx
  801397:	d3 e6                	shl    %cl,%esi
  801399:	39 c6                	cmp    %eax,%esi
  80139b:	73 07                	jae    8013a4 <__udivdi3+0xc4>
  80139d:	39 d5                	cmp    %edx,%ebp
  80139f:	75 03                	jne    8013a4 <__udivdi3+0xc4>
  8013a1:	83 eb 01             	sub    $0x1,%ebx
  8013a4:	31 ff                	xor    %edi,%edi
  8013a6:	89 d8                	mov    %ebx,%eax
  8013a8:	89 fa                	mov    %edi,%edx
  8013aa:	83 c4 1c             	add    $0x1c,%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5e                   	pop    %esi
  8013af:	5f                   	pop    %edi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    
  8013b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013b8:	31 ff                	xor    %edi,%edi
  8013ba:	31 db                	xor    %ebx,%ebx
  8013bc:	89 d8                	mov    %ebx,%eax
  8013be:	89 fa                	mov    %edi,%edx
  8013c0:	83 c4 1c             	add    $0x1c,%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    
  8013c8:	90                   	nop
  8013c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	89 d8                	mov    %ebx,%eax
  8013d2:	f7 f7                	div    %edi
  8013d4:	31 ff                	xor    %edi,%edi
  8013d6:	89 c3                	mov    %eax,%ebx
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	89 fa                	mov    %edi,%edx
  8013dc:	83 c4 1c             	add    $0x1c,%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5e                   	pop    %esi
  8013e1:	5f                   	pop    %edi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    
  8013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	39 ce                	cmp    %ecx,%esi
  8013ea:	72 0c                	jb     8013f8 <__udivdi3+0x118>
  8013ec:	31 db                	xor    %ebx,%ebx
  8013ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8013f2:	0f 87 34 ff ff ff    	ja     80132c <__udivdi3+0x4c>
  8013f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8013fd:	e9 2a ff ff ff       	jmp    80132c <__udivdi3+0x4c>
  801402:	66 90                	xchg   %ax,%ax
  801404:	66 90                	xchg   %ax,%ax
  801406:	66 90                	xchg   %ax,%ax
  801408:	66 90                	xchg   %ax,%ax
  80140a:	66 90                	xchg   %ax,%ax
  80140c:	66 90                	xchg   %ax,%ax
  80140e:	66 90                	xchg   %ax,%ax

00801410 <__umoddi3>:
  801410:	55                   	push   %ebp
  801411:	57                   	push   %edi
  801412:	56                   	push   %esi
  801413:	53                   	push   %ebx
  801414:	83 ec 1c             	sub    $0x1c,%esp
  801417:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80141b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80141f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801427:	85 d2                	test   %edx,%edx
  801429:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80142d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801431:	89 f3                	mov    %esi,%ebx
  801433:	89 3c 24             	mov    %edi,(%esp)
  801436:	89 74 24 04          	mov    %esi,0x4(%esp)
  80143a:	75 1c                	jne    801458 <__umoddi3+0x48>
  80143c:	39 f7                	cmp    %esi,%edi
  80143e:	76 50                	jbe    801490 <__umoddi3+0x80>
  801440:	89 c8                	mov    %ecx,%eax
  801442:	89 f2                	mov    %esi,%edx
  801444:	f7 f7                	div    %edi
  801446:	89 d0                	mov    %edx,%eax
  801448:	31 d2                	xor    %edx,%edx
  80144a:	83 c4 1c             	add    $0x1c,%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5e                   	pop    %esi
  80144f:	5f                   	pop    %edi
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    
  801452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801458:	39 f2                	cmp    %esi,%edx
  80145a:	89 d0                	mov    %edx,%eax
  80145c:	77 52                	ja     8014b0 <__umoddi3+0xa0>
  80145e:	0f bd ea             	bsr    %edx,%ebp
  801461:	83 f5 1f             	xor    $0x1f,%ebp
  801464:	75 5a                	jne    8014c0 <__umoddi3+0xb0>
  801466:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80146a:	0f 82 e0 00 00 00    	jb     801550 <__umoddi3+0x140>
  801470:	39 0c 24             	cmp    %ecx,(%esp)
  801473:	0f 86 d7 00 00 00    	jbe    801550 <__umoddi3+0x140>
  801479:	8b 44 24 08          	mov    0x8(%esp),%eax
  80147d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801481:	83 c4 1c             	add    $0x1c,%esp
  801484:	5b                   	pop    %ebx
  801485:	5e                   	pop    %esi
  801486:	5f                   	pop    %edi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    
  801489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801490:	85 ff                	test   %edi,%edi
  801492:	89 fd                	mov    %edi,%ebp
  801494:	75 0b                	jne    8014a1 <__umoddi3+0x91>
  801496:	b8 01 00 00 00       	mov    $0x1,%eax
  80149b:	31 d2                	xor    %edx,%edx
  80149d:	f7 f7                	div    %edi
  80149f:	89 c5                	mov    %eax,%ebp
  8014a1:	89 f0                	mov    %esi,%eax
  8014a3:	31 d2                	xor    %edx,%edx
  8014a5:	f7 f5                	div    %ebp
  8014a7:	89 c8                	mov    %ecx,%eax
  8014a9:	f7 f5                	div    %ebp
  8014ab:	89 d0                	mov    %edx,%eax
  8014ad:	eb 99                	jmp    801448 <__umoddi3+0x38>
  8014af:	90                   	nop
  8014b0:	89 c8                	mov    %ecx,%eax
  8014b2:	89 f2                	mov    %esi,%edx
  8014b4:	83 c4 1c             	add    $0x1c,%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    
  8014bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014c0:	8b 34 24             	mov    (%esp),%esi
  8014c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8014c8:	89 e9                	mov    %ebp,%ecx
  8014ca:	29 ef                	sub    %ebp,%edi
  8014cc:	d3 e0                	shl    %cl,%eax
  8014ce:	89 f9                	mov    %edi,%ecx
  8014d0:	89 f2                	mov    %esi,%edx
  8014d2:	d3 ea                	shr    %cl,%edx
  8014d4:	89 e9                	mov    %ebp,%ecx
  8014d6:	09 c2                	or     %eax,%edx
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	89 14 24             	mov    %edx,(%esp)
  8014dd:	89 f2                	mov    %esi,%edx
  8014df:	d3 e2                	shl    %cl,%edx
  8014e1:	89 f9                	mov    %edi,%ecx
  8014e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014eb:	d3 e8                	shr    %cl,%eax
  8014ed:	89 e9                	mov    %ebp,%ecx
  8014ef:	89 c6                	mov    %eax,%esi
  8014f1:	d3 e3                	shl    %cl,%ebx
  8014f3:	89 f9                	mov    %edi,%ecx
  8014f5:	89 d0                	mov    %edx,%eax
  8014f7:	d3 e8                	shr    %cl,%eax
  8014f9:	89 e9                	mov    %ebp,%ecx
  8014fb:	09 d8                	or     %ebx,%eax
  8014fd:	89 d3                	mov    %edx,%ebx
  8014ff:	89 f2                	mov    %esi,%edx
  801501:	f7 34 24             	divl   (%esp)
  801504:	89 d6                	mov    %edx,%esi
  801506:	d3 e3                	shl    %cl,%ebx
  801508:	f7 64 24 04          	mull   0x4(%esp)
  80150c:	39 d6                	cmp    %edx,%esi
  80150e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801512:	89 d1                	mov    %edx,%ecx
  801514:	89 c3                	mov    %eax,%ebx
  801516:	72 08                	jb     801520 <__umoddi3+0x110>
  801518:	75 11                	jne    80152b <__umoddi3+0x11b>
  80151a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80151e:	73 0b                	jae    80152b <__umoddi3+0x11b>
  801520:	2b 44 24 04          	sub    0x4(%esp),%eax
  801524:	1b 14 24             	sbb    (%esp),%edx
  801527:	89 d1                	mov    %edx,%ecx
  801529:	89 c3                	mov    %eax,%ebx
  80152b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80152f:	29 da                	sub    %ebx,%edx
  801531:	19 ce                	sbb    %ecx,%esi
  801533:	89 f9                	mov    %edi,%ecx
  801535:	89 f0                	mov    %esi,%eax
  801537:	d3 e0                	shl    %cl,%eax
  801539:	89 e9                	mov    %ebp,%ecx
  80153b:	d3 ea                	shr    %cl,%edx
  80153d:	89 e9                	mov    %ebp,%ecx
  80153f:	d3 ee                	shr    %cl,%esi
  801541:	09 d0                	or     %edx,%eax
  801543:	89 f2                	mov    %esi,%edx
  801545:	83 c4 1c             	add    $0x1c,%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5f                   	pop    %edi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    
  80154d:	8d 76 00             	lea    0x0(%esi),%esi
  801550:	29 f9                	sub    %edi,%ecx
  801552:	19 d6                	sbb    %edx,%esi
  801554:	89 74 24 04          	mov    %esi,0x4(%esp)
  801558:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80155c:	e9 18 ff ff ff       	jmp    801479 <__umoddi3+0x69>
