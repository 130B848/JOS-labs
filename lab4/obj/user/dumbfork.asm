
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
  80002c:	e8 f0 01 00 00       	call   800221 <libmain>
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
  800045:	e8 7f 10 00 00       	call   8010c9 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 e0 15 80 00       	push   $0x8015e0
  800057:	6a 20                	push   $0x20
  800059:	68 f3 15 80 00       	push   $0x8015f3
  80005e:	e8 16 02 00 00       	call   800279 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 a5 10 00 00       	call   80111b <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 03 16 80 00       	push   $0x801603
  800083:	6a 22                	push   $0x22
  800085:	68 f3 15 80 00       	push   $0x8015f3
  80008a:	e8 ea 01 00 00       	call   800279 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 ef 0c 00 00       	call   800d91 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 db 10 00 00       	call   80118c <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 14 16 80 00       	push   $0x801614
  8000be:	6a 25                	push   $0x25
  8000c0:	68 f3 15 80 00       	push   $0x8015f3
  8000c5:	e8 af 01 00 00       	call   800279 <_panic>
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
	// 	: "a" (SYS_exofork),
	// 	  "i" (T_SYSCALL)
	// );
	// return ret;
	envid_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8000de:	51                   	push   %ecx
  8000df:	52                   	push   %edx
  8000e0:	53                   	push   %ebx
  8000e1:	56                   	push   %esi
  8000e2:	57                   	push   %edi
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	8d 35 ee 00 80 00    	lea    0x8000ee,%esi
  8000ec:	0f 34                	sysenter 

008000ee <label_102>:
  8000ee:	89 ec                	mov    %ebp,%esp
  8000f0:	5d                   	pop    %ebp
  8000f1:	5f                   	pop    %edi
  8000f2:	5e                   	pop    %esi
  8000f3:	5b                   	pop    %ebx
  8000f4:	5a                   	pop    %edx
  8000f5:	59                   	pop    %ecx
  8000f6:	89 c3                	mov    %eax,%ebx
  8000f8:	89 c6                	mov    %eax,%esi
							: "=a" (ret)
							: "a" (SYS_exofork),
								"i" (T_SYSCALL)
							: "cc", "memory");

	if(ret == -E_NO_FREE_ENV || ret == -E_NO_MEM)
  8000fa:	8d 40 05             	lea    0x5(%eax),%eax
  8000fd:	83 f8 01             	cmp    $0x1,%eax
  800100:	77 17                	ja     800119 <label_102+0x2b>
		panic("syscall %d returned %d (> 0)", SYS_exofork, ret);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	53                   	push   %ebx
  800106:	6a 08                	push   $0x8
  800108:	68 27 16 80 00       	push   $0x801627
  80010d:	6a 62                	push   $0x62
  80010f:	68 44 16 80 00       	push   $0x801644
  800114:	e8 60 01 00 00       	call   800279 <_panic>
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	79 12                	jns    80012f <label_102+0x41>
		panic("sys_exofork: %e", envid);
  80011d:	53                   	push   %ebx
  80011e:	68 50 16 80 00       	push   $0x801650
  800123:	6a 37                	push   $0x37
  800125:	68 f3 15 80 00       	push   $0x8015f3
  80012a:	e8 4a 01 00 00       	call   800279 <_panic>
	if (envid == 0) {
  80012f:	85 db                	test   %ebx,%ebx
  800131:	75 1e                	jne    800151 <label_102+0x63>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800133:	e8 fc 0e 00 00       	call   801034 <sys_getenvid>
  800138:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013d:	c1 e0 07             	shl    $0x7,%eax
  800140:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800145:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  80014a:	b8 00 00 00 00       	mov    $0x0,%eax
  80014f:	eb 71                	jmp    8001c2 <label_102+0xd4>

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.

	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800151:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800158:	b8 14 20 80 00       	mov    $0x802014,%eax
  80015d:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800162:	76 26                	jbe    80018a <label_102+0x9c>
  800164:	ba 00 00 80 00       	mov    $0x800000,%edx
		duppage(envid, addr);
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	52                   	push   %edx
  80016d:	56                   	push   %esi
  80016e:	e8 c0 fe ff ff       	call   800033 <duppage>

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.

	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800173:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800176:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  80017c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	81 fa 14 20 80 00    	cmp    $0x802014,%edx
  800188:	72 df                	jb     800169 <label_102+0x7b>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80018a:	83 ec 08             	sub    $0x8,%esp
  80018d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800190:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800195:	50                   	push   %eax
  800196:	53                   	push   %ebx
  800197:	e8 97 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80019c:	83 c4 08             	add    $0x8,%esp
  80019f:	6a 02                	push   $0x2
  8001a1:	53                   	push   %ebx
  8001a2:	e8 36 10 00 00       	call   8011dd <sys_env_set_status>
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	79 12                	jns    8001c0 <label_102+0xd2>
		panic("sys_env_set_status: %e", r);
  8001ae:	50                   	push   %eax
  8001af:	68 60 16 80 00       	push   $0x801660
  8001b4:	6a 4d                	push   $0x4d
  8001b6:	68 f3 15 80 00       	push   $0x8015f3
  8001bb:	e8 b9 00 00 00       	call   800279 <_panic>

	return envid;
  8001c0:	89 d8                	mov    %ebx,%eax
}
  8001c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c5:	5b                   	pop    %ebx
  8001c6:	5e                   	pop    %esi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001d2:	e8 fa fe ff ff       	call   8000d1 <dumbfork>
  8001d7:	89 c7                	mov    %eax,%edi
  8001d9:	85 c0                	test   %eax,%eax
  8001db:	be 7e 16 80 00       	mov    $0x80167e,%esi
  8001e0:	b8 77 16 80 00       	mov    $0x801677,%eax
  8001e5:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	eb 1a                	jmp    800209 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001ef:	83 ec 04             	sub    $0x4,%esp
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	68 84 16 80 00       	push   $0x801684
  8001f9:	e8 6e 01 00 00       	call   80036c <cprintf>
		sys_yield();
  8001fe:	e8 95 0e 00 00       	call   801098 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800203:	83 c3 01             	add    $0x1,%ebx
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	85 ff                	test   %edi,%edi
  80020b:	74 07                	je     800214 <umain+0x4b>
  80020d:	83 fb 09             	cmp    $0x9,%ebx
  800210:	7e dd                	jle    8001ef <umain+0x26>
  800212:	eb 05                	jmp    800219 <umain+0x50>
  800214:	83 fb 13             	cmp    $0x13,%ebx
  800217:	7e d6                	jle    8001ef <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800229:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80022c:	e8 03 0e 00 00       	call   801034 <sys_getenvid>
  800231:	25 ff 03 00 00       	and    $0x3ff,%eax
  800236:	c1 e0 07             	shl    $0x7,%eax
  800239:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023e:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800243:	85 db                	test   %ebx,%ebx
  800245:	7e 07                	jle    80024e <libmain+0x2d>
		binaryname = argv[0];
  800247:	8b 06                	mov    (%esi),%eax
  800249:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	e8 71 ff ff ff       	call   8001c9 <umain>

	// exit gracefully
	exit();
  800258:	e8 0a 00 00 00       	call   800267 <exit>
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80026d:	6a 00                	push   $0x0
  80026f:	e8 70 0d 00 00       	call   800fe4 <sys_env_destroy>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80027e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800281:	a1 10 20 80 00       	mov    0x802010,%eax
  800286:	85 c0                	test   %eax,%eax
  800288:	74 11                	je     80029b <_panic+0x22>
		cprintf("%s: ", argv0);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	50                   	push   %eax
  80028e:	68 a0 16 80 00       	push   $0x8016a0
  800293:	e8 d4 00 00 00       	call   80036c <cprintf>
  800298:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002a1:	e8 8e 0d 00 00       	call   801034 <sys_getenvid>
  8002a6:	83 ec 0c             	sub    $0xc,%esp
  8002a9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ac:	ff 75 08             	pushl  0x8(%ebp)
  8002af:	56                   	push   %esi
  8002b0:	50                   	push   %eax
  8002b1:	68 a8 16 80 00       	push   $0x8016a8
  8002b6:	e8 b1 00 00 00       	call   80036c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bb:	83 c4 18             	add    $0x18,%esp
  8002be:	53                   	push   %ebx
  8002bf:	ff 75 10             	pushl  0x10(%ebp)
  8002c2:	e8 54 00 00 00       	call   80031b <vcprintf>
	cprintf("\n");
  8002c7:	c7 04 24 94 16 80 00 	movl   $0x801694,(%esp)
  8002ce:	e8 99 00 00 00       	call   80036c <cprintf>
  8002d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d6:	cc                   	int3   
  8002d7:	eb fd                	jmp    8002d6 <_panic+0x5d>

008002d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 04             	sub    $0x4,%esp
  8002e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e3:	8b 13                	mov    (%ebx),%edx
  8002e5:	8d 42 01             	lea    0x1(%edx),%eax
  8002e8:	89 03                	mov    %eax,(%ebx)
  8002ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f6:	75 1a                	jne    800312 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002f8:	83 ec 08             	sub    $0x8,%esp
  8002fb:	68 ff 00 00 00       	push   $0xff
  800300:	8d 43 08             	lea    0x8(%ebx),%eax
  800303:	50                   	push   %eax
  800304:	e8 7a 0c 00 00       	call   800f83 <sys_cputs>
		b->idx = 0;
  800309:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80030f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800312:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800324:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032b:	00 00 00 
	b.cnt = 0;
  80032e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800335:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800344:	50                   	push   %eax
  800345:	68 d9 02 80 00       	push   $0x8002d9
  80034a:	e8 c0 02 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80034f:	83 c4 08             	add    $0x8,%esp
  800352:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800358:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80035e:	50                   	push   %eax
  80035f:	e8 1f 0c 00 00       	call   800f83 <sys_cputs>

	return b.cnt;
}
  800364:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800372:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 08             	pushl  0x8(%ebp)
  800379:	e8 9d ff ff ff       	call   80031b <vcprintf>
	va_end(ap);

	return cnt;
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
  800386:	83 ec 1c             	sub    $0x1c,%esp
  800389:	89 c7                	mov    %eax,%edi
  80038b:	89 d6                	mov    %edx,%esi
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	8b 55 0c             	mov    0xc(%ebp),%edx
  800393:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800396:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800399:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80039c:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8003a0:	0f 85 bf 00 00 00    	jne    800465 <printnum+0xe5>
  8003a6:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8003ac:	0f 8d de 00 00 00    	jge    800490 <printnum+0x110>
		judge_time_for_space = width;
  8003b2:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8003b8:	e9 d3 00 00 00       	jmp    800490 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8003bd:	83 eb 01             	sub    $0x1,%ebx
  8003c0:	85 db                	test   %ebx,%ebx
  8003c2:	7f 37                	jg     8003fb <printnum+0x7b>
  8003c4:	e9 ea 00 00 00       	jmp    8004b3 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8003c9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8003cc:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	56                   	push   %esi
  8003d5:	83 ec 04             	sub    $0x4,%esp
  8003d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003db:	ff 75 d8             	pushl  -0x28(%ebp)
  8003de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e4:	e8 87 10 00 00       	call   801470 <__umoddi3>
  8003e9:	83 c4 14             	add    $0x14,%esp
  8003ec:	0f be 80 cb 16 80 00 	movsbl 0x8016cb(%eax),%eax
  8003f3:	50                   	push   %eax
  8003f4:	ff d7                	call   *%edi
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	eb 16                	jmp    800411 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	56                   	push   %esi
  8003ff:	ff 75 18             	pushl  0x18(%ebp)
  800402:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800404:	83 c4 10             	add    $0x10,%esp
  800407:	83 eb 01             	sub    $0x1,%ebx
  80040a:	75 ef                	jne    8003fb <printnum+0x7b>
  80040c:	e9 a2 00 00 00       	jmp    8004b3 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800411:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800417:	0f 85 76 01 00 00    	jne    800593 <printnum+0x213>
		while(num_of_space-- > 0)
  80041d:	a1 04 20 80 00       	mov    0x802004,%eax
  800422:	8d 50 ff             	lea    -0x1(%eax),%edx
  800425:	89 15 04 20 80 00    	mov    %edx,0x802004
  80042b:	85 c0                	test   %eax,%eax
  80042d:	7e 1d                	jle    80044c <printnum+0xcc>
			putch(' ', putdat);
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	56                   	push   %esi
  800433:	6a 20                	push   $0x20
  800435:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800437:	a1 04 20 80 00       	mov    0x802004,%eax
  80043c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80043f:	89 15 04 20 80 00    	mov    %edx,0x802004
  800445:	83 c4 10             	add    $0x10,%esp
  800448:	85 c0                	test   %eax,%eax
  80044a:	7f e3                	jg     80042f <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  80044c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800453:	00 00 00 
		judge_time_for_space = 0;
  800456:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80045d:	00 00 00 
	}
}
  800460:	e9 2e 01 00 00       	jmp    800593 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800465:	8b 45 10             	mov    0x10(%ebp),%eax
  800468:	ba 00 00 00 00       	mov    $0x0,%edx
  80046d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800470:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800473:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800476:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800479:	83 fa 00             	cmp    $0x0,%edx
  80047c:	0f 87 ba 00 00 00    	ja     80053c <printnum+0x1bc>
  800482:	3b 45 10             	cmp    0x10(%ebp),%eax
  800485:	0f 83 b1 00 00 00    	jae    80053c <printnum+0x1bc>
  80048b:	e9 2d ff ff ff       	jmp    8003bd <printnum+0x3d>
  800490:	8b 45 10             	mov    0x10(%ebp),%eax
  800493:	ba 00 00 00 00       	mov    $0x0,%edx
  800498:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80049b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80049e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a4:	83 fa 00             	cmp    $0x0,%edx
  8004a7:	77 37                	ja     8004e0 <printnum+0x160>
  8004a9:	3b 45 10             	cmp    0x10(%ebp),%eax
  8004ac:	73 32                	jae    8004e0 <printnum+0x160>
  8004ae:	e9 16 ff ff ff       	jmp    8003c9 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	56                   	push   %esi
  8004b7:	83 ec 04             	sub    $0x4,%esp
  8004ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c6:	e8 a5 0f 00 00       	call   801470 <__umoddi3>
  8004cb:	83 c4 14             	add    $0x14,%esp
  8004ce:	0f be 80 cb 16 80 00 	movsbl 0x8016cb(%eax),%eax
  8004d5:	50                   	push   %eax
  8004d6:	ff d7                	call   *%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	e9 b3 00 00 00       	jmp    800593 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004e0:	83 ec 0c             	sub    $0xc,%esp
  8004e3:	ff 75 18             	pushl  0x18(%ebp)
  8004e6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8004e9:	50                   	push   %eax
  8004ea:	ff 75 10             	pushl  0x10(%ebp)
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fc:	e8 3f 0e 00 00       	call   801340 <__udivdi3>
  800501:	83 c4 18             	add    $0x18,%esp
  800504:	52                   	push   %edx
  800505:	50                   	push   %eax
  800506:	89 f2                	mov    %esi,%edx
  800508:	89 f8                	mov    %edi,%eax
  80050a:	e8 71 fe ff ff       	call   800380 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80050f:	83 c4 18             	add    $0x18,%esp
  800512:	56                   	push   %esi
  800513:	83 ec 04             	sub    $0x4,%esp
  800516:	ff 75 dc             	pushl  -0x24(%ebp)
  800519:	ff 75 d8             	pushl  -0x28(%ebp)
  80051c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80051f:	ff 75 e0             	pushl  -0x20(%ebp)
  800522:	e8 49 0f 00 00       	call   801470 <__umoddi3>
  800527:	83 c4 14             	add    $0x14,%esp
  80052a:	0f be 80 cb 16 80 00 	movsbl 0x8016cb(%eax),%eax
  800531:	50                   	push   %eax
  800532:	ff d7                	call   *%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	e9 d5 fe ff ff       	jmp    800411 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80053c:	83 ec 0c             	sub    $0xc,%esp
  80053f:	ff 75 18             	pushl  0x18(%ebp)
  800542:	83 eb 01             	sub    $0x1,%ebx
  800545:	53                   	push   %ebx
  800546:	ff 75 10             	pushl  0x10(%ebp)
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	ff 75 dc             	pushl  -0x24(%ebp)
  80054f:	ff 75 d8             	pushl  -0x28(%ebp)
  800552:	ff 75 e4             	pushl  -0x1c(%ebp)
  800555:	ff 75 e0             	pushl  -0x20(%ebp)
  800558:	e8 e3 0d 00 00       	call   801340 <__udivdi3>
  80055d:	83 c4 18             	add    $0x18,%esp
  800560:	52                   	push   %edx
  800561:	50                   	push   %eax
  800562:	89 f2                	mov    %esi,%edx
  800564:	89 f8                	mov    %edi,%eax
  800566:	e8 15 fe ff ff       	call   800380 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 c4 18             	add    $0x18,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 dc             	pushl  -0x24(%ebp)
  800575:	ff 75 d8             	pushl  -0x28(%ebp)
  800578:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057b:	ff 75 e0             	pushl  -0x20(%ebp)
  80057e:	e8 ed 0e 00 00       	call   801470 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 cb 16 80 00 	movsbl 0x8016cb(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
  800590:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 7d 08             	mov    0x8(%ebp),%edi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	eb 03                	jmp    800623 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800620:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800623:	8b 45 10             	mov    0x10(%ebp),%eax
  800626:	8d 70 01             	lea    0x1(%eax),%esi
  800629:	0f b6 00             	movzbl (%eax),%eax
  80062c:	83 f8 25             	cmp    $0x25,%eax
  80062f:	74 27                	je     800658 <vprintfmt+0x49>
			if (ch == '\0')
  800631:	85 c0                	test   %eax,%eax
  800633:	75 0d                	jne    800642 <vprintfmt+0x33>
  800635:	e9 9d 04 00 00       	jmp    800ad7 <vprintfmt+0x4c8>
  80063a:	85 c0                	test   %eax,%eax
  80063c:	0f 84 95 04 00 00    	je     800ad7 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	50                   	push   %eax
  800647:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800649:	83 c6 01             	add    $0x1,%esi
  80064c:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	83 f8 25             	cmp    $0x25,%eax
  800656:	75 e2                	jne    80063a <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800661:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800668:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80066f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800676:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80067d:	eb 08                	jmp    800687 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800682:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8d 46 01             	lea    0x1(%esi),%eax
  80068a:	89 45 10             	mov    %eax,0x10(%ebp)
  80068d:	0f b6 06             	movzbl (%esi),%eax
  800690:	0f b6 d0             	movzbl %al,%edx
  800693:	83 e8 23             	sub    $0x23,%eax
  800696:	3c 55                	cmp    $0x55,%al
  800698:	0f 87 fa 03 00 00    	ja     800a98 <vprintfmt+0x489>
  80069e:	0f b6 c0             	movzbl %al,%eax
  8006a1:	ff 24 85 00 18 80 00 	jmp    *0x801800(,%eax,4)
  8006a8:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ab:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8006af:	eb d6                	jmp    800687 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006b1:	8d 42 d0             	lea    -0x30(%edx),%eax
  8006b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8006b7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8006bb:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006be:	83 fa 09             	cmp    $0x9,%edx
  8006c1:	77 6b                	ja     80072e <vprintfmt+0x11f>
  8006c3:	8b 75 10             	mov    0x10(%ebp),%esi
  8006c6:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006c9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006cc:	eb 09                	jmp    8006d7 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006d1:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8006d5:	eb b0                	jmp    800687 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8006da:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8006dd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8006e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006e4:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006e7:	83 f9 09             	cmp    $0x9,%ecx
  8006ea:	76 eb                	jbe    8006d7 <vprintfmt+0xc8>
  8006ec:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006ef:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006f2:	eb 3d                	jmp    800731 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 00                	mov    (%eax),%eax
  8006ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800705:	eb 2a                	jmp    800731 <vprintfmt+0x122>
  800707:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80070a:	85 c0                	test   %eax,%eax
  80070c:	ba 00 00 00 00       	mov    $0x0,%edx
  800711:	0f 49 d0             	cmovns %eax,%edx
  800714:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800717:	8b 75 10             	mov    0x10(%ebp),%esi
  80071a:	e9 68 ff ff ff       	jmp    800687 <vprintfmt+0x78>
  80071f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800722:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800729:	e9 59 ff ff ff       	jmp    800687 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800731:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800735:	0f 89 4c ff ff ff    	jns    800687 <vprintfmt+0x78>
				width = precision, precision = -1;
  80073b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80073e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800741:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800748:	e9 3a ff ff ff       	jmp    800687 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80074d:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800751:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800754:	e9 2e ff ff ff       	jmp    800687 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8d 50 04             	lea    0x4(%eax),%edx
  80075f:	89 55 14             	mov    %edx,0x14(%ebp)
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	ff 30                	pushl  (%eax)
  800768:	ff d7                	call   *%edi
			break;
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	e9 b1 fe ff ff       	jmp    800623 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	99                   	cltd   
  80077e:	31 d0                	xor    %edx,%eax
  800780:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800782:	83 f8 08             	cmp    $0x8,%eax
  800785:	7f 0b                	jg     800792 <vprintfmt+0x183>
  800787:	8b 14 85 60 19 80 00 	mov    0x801960(,%eax,4),%edx
  80078e:	85 d2                	test   %edx,%edx
  800790:	75 15                	jne    8007a7 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800792:	50                   	push   %eax
  800793:	68 e3 16 80 00       	push   $0x8016e3
  800798:	53                   	push   %ebx
  800799:	57                   	push   %edi
  80079a:	e8 53 fe ff ff       	call   8005f2 <printfmt>
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	e9 7c fe ff ff       	jmp    800623 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8007a7:	52                   	push   %edx
  8007a8:	68 ec 16 80 00       	push   $0x8016ec
  8007ad:	53                   	push   %ebx
  8007ae:	57                   	push   %edi
  8007af:	e8 3e fe ff ff       	call   8005f2 <printfmt>
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	e9 67 fe ff ff       	jmp    800623 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8d 50 04             	lea    0x4(%eax),%edx
  8007c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c5:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	b9 dc 16 80 00       	mov    $0x8016dc,%ecx
  8007ce:	0f 45 c8             	cmovne %eax,%ecx
  8007d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8007d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d8:	7e 06                	jle    8007e0 <vprintfmt+0x1d1>
  8007da:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8007de:	75 19                	jne    8007f9 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007e3:	8d 70 01             	lea    0x1(%eax),%esi
  8007e6:	0f b6 00             	movzbl (%eax),%eax
  8007e9:	0f be d0             	movsbl %al,%edx
  8007ec:	85 d2                	test   %edx,%edx
  8007ee:	0f 85 9f 00 00 00    	jne    800893 <vprintfmt+0x284>
  8007f4:	e9 8c 00 00 00       	jmp    800885 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	ff 75 d0             	pushl  -0x30(%ebp)
  8007ff:	ff 75 cc             	pushl  -0x34(%ebp)
  800802:	e8 62 03 00 00       	call   800b69 <strnlen>
  800807:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80080a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80080d:	83 c4 10             	add    $0x10,%esp
  800810:	85 c9                	test   %ecx,%ecx
  800812:	0f 8e a6 02 00 00    	jle    800abe <vprintfmt+0x4af>
					putch(padc, putdat);
  800818:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80081c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80081f:	89 cb                	mov    %ecx,%ebx
  800821:	83 ec 08             	sub    $0x8,%esp
  800824:	ff 75 0c             	pushl  0xc(%ebp)
  800827:	56                   	push   %esi
  800828:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	83 eb 01             	sub    $0x1,%ebx
  800830:	75 ef                	jne    800821 <vprintfmt+0x212>
  800832:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800838:	e9 81 02 00 00       	jmp    800abe <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80083d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800841:	74 1b                	je     80085e <vprintfmt+0x24f>
  800843:	0f be c0             	movsbl %al,%eax
  800846:	83 e8 20             	sub    $0x20,%eax
  800849:	83 f8 5e             	cmp    $0x5e,%eax
  80084c:	76 10                	jbe    80085e <vprintfmt+0x24f>
					putch('?', putdat);
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	ff 75 0c             	pushl  0xc(%ebp)
  800854:	6a 3f                	push   $0x3f
  800856:	ff 55 08             	call   *0x8(%ebp)
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	eb 0d                	jmp    80086b <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	ff 75 0c             	pushl  0xc(%ebp)
  800864:	52                   	push   %edx
  800865:	ff 55 08             	call   *0x8(%ebp)
  800868:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80086b:	83 ef 01             	sub    $0x1,%edi
  80086e:	83 c6 01             	add    $0x1,%esi
  800871:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800875:	0f be d0             	movsbl %al,%edx
  800878:	85 d2                	test   %edx,%edx
  80087a:	75 31                	jne    8008ad <vprintfmt+0x29e>
  80087c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80087f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800885:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800888:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80088c:	7f 33                	jg     8008c1 <vprintfmt+0x2b2>
  80088e:	e9 90 fd ff ff       	jmp    800623 <vprintfmt+0x14>
  800893:	89 7d 08             	mov    %edi,0x8(%ebp)
  800896:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800899:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80089c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80089f:	eb 0c                	jmp    8008ad <vprintfmt+0x29e>
  8008a1:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008aa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ad:	85 db                	test   %ebx,%ebx
  8008af:	78 8c                	js     80083d <vprintfmt+0x22e>
  8008b1:	83 eb 01             	sub    $0x1,%ebx
  8008b4:	79 87                	jns    80083d <vprintfmt+0x22e>
  8008b6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008bf:	eb c4                	jmp    800885 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	53                   	push   %ebx
  8008c5:	6a 20                	push   $0x20
  8008c7:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008c9:	83 c4 10             	add    $0x10,%esp
  8008cc:	83 ee 01             	sub    $0x1,%esi
  8008cf:	75 f0                	jne    8008c1 <vprintfmt+0x2b2>
  8008d1:	e9 4d fd ff ff       	jmp    800623 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d6:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8008da:	7e 16                	jle    8008f2 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  8008dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008df:	8d 50 08             	lea    0x8(%eax),%edx
  8008e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e5:	8b 50 04             	mov    0x4(%eax),%edx
  8008e8:	8b 00                	mov    (%eax),%eax
  8008ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008ed:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008f0:	eb 34                	jmp    800926 <vprintfmt+0x317>
	else if (lflag)
  8008f2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8008f6:	74 18                	je     800910 <vprintfmt+0x301>
		return va_arg(*ap, long);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8d 50 04             	lea    0x4(%eax),%edx
  8008fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800901:	8b 30                	mov    (%eax),%esi
  800903:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800906:	89 f0                	mov    %esi,%eax
  800908:	c1 f8 1f             	sar    $0x1f,%eax
  80090b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80090e:	eb 16                	jmp    800926 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	8d 50 04             	lea    0x4(%eax),%edx
  800916:	89 55 14             	mov    %edx,0x14(%ebp)
  800919:	8b 30                	mov    (%eax),%esi
  80091b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80091e:	89 f0                	mov    %esi,%eax
  800920:	c1 f8 1f             	sar    $0x1f,%eax
  800923:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800926:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800929:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80092c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800932:	85 d2                	test   %edx,%edx
  800934:	79 28                	jns    80095e <vprintfmt+0x34f>
				putch('-', putdat);
  800936:	83 ec 08             	sub    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 2d                	push   $0x2d
  80093c:	ff d7                	call   *%edi
				num = -(long long) num;
  80093e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800941:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800944:	f7 d8                	neg    %eax
  800946:	83 d2 00             	adc    $0x0,%edx
  800949:	f7 da                	neg    %edx
  80094b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80094e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800951:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800954:	b8 0a 00 00 00       	mov    $0xa,%eax
  800959:	e9 b2 00 00 00       	jmp    800a10 <vprintfmt+0x401>
  80095e:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800963:	85 c9                	test   %ecx,%ecx
  800965:	0f 84 a5 00 00 00    	je     800a10 <vprintfmt+0x401>
				putch('+', putdat);
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	53                   	push   %ebx
  80096f:	6a 2b                	push   $0x2b
  800971:	ff d7                	call   *%edi
  800973:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800976:	b8 0a 00 00 00       	mov    $0xa,%eax
  80097b:	e9 90 00 00 00       	jmp    800a10 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800980:	85 c9                	test   %ecx,%ecx
  800982:	74 0b                	je     80098f <vprintfmt+0x380>
				putch('+', putdat);
  800984:	83 ec 08             	sub    $0x8,%esp
  800987:	53                   	push   %ebx
  800988:	6a 2b                	push   $0x2b
  80098a:	ff d7                	call   *%edi
  80098c:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  80098f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800992:	8d 45 14             	lea    0x14(%ebp),%eax
  800995:	e8 01 fc ff ff       	call   80059b <getuint>
  80099a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8009a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8009a5:	eb 69                	jmp    800a10 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	53                   	push   %ebx
  8009ab:	6a 30                	push   $0x30
  8009ad:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8009af:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b5:	e8 e1 fb ff ff       	call   80059b <getuint>
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8009c0:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8009c3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8009c8:	eb 46                	jmp    800a10 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009ca:	83 ec 08             	sub    $0x8,%esp
  8009cd:	53                   	push   %ebx
  8009ce:	6a 30                	push   $0x30
  8009d0:	ff d7                	call   *%edi
			putch('x', putdat);
  8009d2:	83 c4 08             	add    $0x8,%esp
  8009d5:	53                   	push   %ebx
  8009d6:	6a 78                	push   $0x78
  8009d8:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009da:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dd:	8d 50 04             	lea    0x4(%eax),%edx
  8009e0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009e3:	8b 00                	mov    (%eax),%eax
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009f0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009f3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009f8:	eb 16                	jmp    800a10 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009fa:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800a00:	e8 96 fb ff ff       	call   80059b <getuint>
  800a05:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a08:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800a0b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a10:	83 ec 0c             	sub    $0xc,%esp
  800a13:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800a17:	56                   	push   %esi
  800a18:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a1b:	50                   	push   %eax
  800a1c:	ff 75 dc             	pushl  -0x24(%ebp)
  800a1f:	ff 75 d8             	pushl  -0x28(%ebp)
  800a22:	89 da                	mov    %ebx,%edx
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	e8 55 f9 ff ff       	call   800380 <printnum>
			break;
  800a2b:	83 c4 20             	add    $0x20,%esp
  800a2e:	e9 f0 fb ff ff       	jmp    800623 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800a33:	8b 45 14             	mov    0x14(%ebp),%eax
  800a36:	8d 50 04             	lea    0x4(%eax),%edx
  800a39:	89 55 14             	mov    %edx,0x14(%ebp)
  800a3c:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800a3e:	85 f6                	test   %esi,%esi
  800a40:	75 1a                	jne    800a5c <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800a42:	83 ec 08             	sub    $0x8,%esp
  800a45:	68 84 17 80 00       	push   $0x801784
  800a4a:	68 ec 16 80 00       	push   $0x8016ec
  800a4f:	e8 18 f9 ff ff       	call   80036c <cprintf>
  800a54:	83 c4 10             	add    $0x10,%esp
  800a57:	e9 c7 fb ff ff       	jmp    800623 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800a5c:	0f b6 03             	movzbl (%ebx),%eax
  800a5f:	84 c0                	test   %al,%al
  800a61:	79 1f                	jns    800a82 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800a63:	83 ec 08             	sub    $0x8,%esp
  800a66:	68 bc 17 80 00       	push   $0x8017bc
  800a6b:	68 ec 16 80 00       	push   $0x8016ec
  800a70:	e8 f7 f8 ff ff       	call   80036c <cprintf>
						*tmp = *(char *)putdat;
  800a75:	0f b6 03             	movzbl (%ebx),%eax
  800a78:	88 06                	mov    %al,(%esi)
  800a7a:	83 c4 10             	add    $0x10,%esp
  800a7d:	e9 a1 fb ff ff       	jmp    800623 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800a82:	88 06                	mov    %al,(%esi)
  800a84:	e9 9a fb ff ff       	jmp    800623 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a89:	83 ec 08             	sub    $0x8,%esp
  800a8c:	53                   	push   %ebx
  800a8d:	52                   	push   %edx
  800a8e:	ff d7                	call   *%edi
			break;
  800a90:	83 c4 10             	add    $0x10,%esp
  800a93:	e9 8b fb ff ff       	jmp    800623 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a98:	83 ec 08             	sub    $0x8,%esp
  800a9b:	53                   	push   %ebx
  800a9c:	6a 25                	push   $0x25
  800a9e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa0:	83 c4 10             	add    $0x10,%esp
  800aa3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800aa7:	0f 84 73 fb ff ff    	je     800620 <vprintfmt+0x11>
  800aad:	83 ee 01             	sub    $0x1,%esi
  800ab0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ab4:	75 f7                	jne    800aad <vprintfmt+0x49e>
  800ab6:	89 75 10             	mov    %esi,0x10(%ebp)
  800ab9:	e9 65 fb ff ff       	jmp    800623 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800abe:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ac1:	8d 70 01             	lea    0x1(%eax),%esi
  800ac4:	0f b6 00             	movzbl (%eax),%eax
  800ac7:	0f be d0             	movsbl %al,%edx
  800aca:	85 d2                	test   %edx,%edx
  800acc:	0f 85 cf fd ff ff    	jne    8008a1 <vprintfmt+0x292>
  800ad2:	e9 4c fb ff ff       	jmp    800623 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	83 ec 18             	sub    $0x18,%esp
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aeb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800af2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800afc:	85 c0                	test   %eax,%eax
  800afe:	74 26                	je     800b26 <vsnprintf+0x47>
  800b00:	85 d2                	test   %edx,%edx
  800b02:	7e 22                	jle    800b26 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b04:	ff 75 14             	pushl  0x14(%ebp)
  800b07:	ff 75 10             	pushl  0x10(%ebp)
  800b0a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b0d:	50                   	push   %eax
  800b0e:	68 d5 05 80 00       	push   $0x8005d5
  800b13:	e8 f7 fa ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b1b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b21:	83 c4 10             	add    $0x10,%esp
  800b24:	eb 05                	jmp    800b2b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b33:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b36:	50                   	push   %eax
  800b37:	ff 75 10             	pushl  0x10(%ebp)
  800b3a:	ff 75 0c             	pushl  0xc(%ebp)
  800b3d:	ff 75 08             	pushl  0x8(%ebp)
  800b40:	e8 9a ff ff ff       	call   800adf <vsnprintf>
	va_end(ap);

	return rc;
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b4d:	80 3a 00             	cmpb   $0x0,(%edx)
  800b50:	74 10                	je     800b62 <strlen+0x1b>
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b57:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b5a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b5e:	75 f7                	jne    800b57 <strlen+0x10>
  800b60:	eb 05                	jmp    800b67 <strlen+0x20>
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	53                   	push   %ebx
  800b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b73:	85 c9                	test   %ecx,%ecx
  800b75:	74 1c                	je     800b93 <strnlen+0x2a>
  800b77:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b7a:	74 1e                	je     800b9a <strnlen+0x31>
  800b7c:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b81:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b83:	39 ca                	cmp    %ecx,%edx
  800b85:	74 18                	je     800b9f <strnlen+0x36>
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b8f:	75 f0                	jne    800b81 <strnlen+0x18>
  800b91:	eb 0c                	jmp    800b9f <strnlen+0x36>
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	eb 05                	jmp    800b9f <strnlen+0x36>
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	53                   	push   %ebx
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bac:	89 c2                	mov    %eax,%edx
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	83 c1 01             	add    $0x1,%ecx
  800bb4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800bb8:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bbb:	84 db                	test   %bl,%bl
  800bbd:	75 ef                	jne    800bae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	53                   	push   %ebx
  800bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bc9:	53                   	push   %ebx
  800bca:	e8 78 ff ff ff       	call   800b47 <strlen>
  800bcf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800bd2:	ff 75 0c             	pushl  0xc(%ebp)
  800bd5:	01 d8                	add    %ebx,%eax
  800bd7:	50                   	push   %eax
  800bd8:	e8 c5 ff ff ff       	call   800ba2 <strcpy>
	return dst;
}
  800bdd:	89 d8                	mov    %ebx,%eax
  800bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf2:	85 db                	test   %ebx,%ebx
  800bf4:	74 17                	je     800c0d <strncpy+0x29>
  800bf6:	01 f3                	add    %esi,%ebx
  800bf8:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800bfa:	83 c1 01             	add    $0x1,%ecx
  800bfd:	0f b6 02             	movzbl (%edx),%eax
  800c00:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c03:	80 3a 01             	cmpb   $0x1,(%edx)
  800c06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c09:	39 cb                	cmp    %ecx,%ebx
  800c0b:	75 ed                	jne    800bfa <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c0d:	89 f0                	mov    %esi,%eax
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 75 08             	mov    0x8(%ebp),%esi
  800c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1e:	8b 55 10             	mov    0x10(%ebp),%edx
  800c21:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c23:	85 d2                	test   %edx,%edx
  800c25:	74 35                	je     800c5c <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800c27:	89 d0                	mov    %edx,%eax
  800c29:	83 e8 01             	sub    $0x1,%eax
  800c2c:	74 25                	je     800c53 <strlcpy+0x40>
  800c2e:	0f b6 0b             	movzbl (%ebx),%ecx
  800c31:	84 c9                	test   %cl,%cl
  800c33:	74 22                	je     800c57 <strlcpy+0x44>
  800c35:	8d 53 01             	lea    0x1(%ebx),%edx
  800c38:	01 c3                	add    %eax,%ebx
  800c3a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800c3c:	83 c0 01             	add    $0x1,%eax
  800c3f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c42:	39 da                	cmp    %ebx,%edx
  800c44:	74 13                	je     800c59 <strlcpy+0x46>
  800c46:	83 c2 01             	add    $0x1,%edx
  800c49:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800c4d:	84 c9                	test   %cl,%cl
  800c4f:	75 eb                	jne    800c3c <strlcpy+0x29>
  800c51:	eb 06                	jmp    800c59 <strlcpy+0x46>
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	eb 02                	jmp    800c59 <strlcpy+0x46>
  800c57:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c59:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c5c:	29 f0                	sub    %esi,%eax
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c68:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c6b:	0f b6 01             	movzbl (%ecx),%eax
  800c6e:	84 c0                	test   %al,%al
  800c70:	74 15                	je     800c87 <strcmp+0x25>
  800c72:	3a 02                	cmp    (%edx),%al
  800c74:	75 11                	jne    800c87 <strcmp+0x25>
		p++, q++;
  800c76:	83 c1 01             	add    $0x1,%ecx
  800c79:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c7c:	0f b6 01             	movzbl (%ecx),%eax
  800c7f:	84 c0                	test   %al,%al
  800c81:	74 04                	je     800c87 <strcmp+0x25>
  800c83:	3a 02                	cmp    (%edx),%al
  800c85:	74 ef                	je     800c76 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c87:	0f b6 c0             	movzbl %al,%eax
  800c8a:	0f b6 12             	movzbl (%edx),%edx
  800c8d:	29 d0                	sub    %edx,%eax
}
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9c:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c9f:	85 f6                	test   %esi,%esi
  800ca1:	74 29                	je     800ccc <strncmp+0x3b>
  800ca3:	0f b6 03             	movzbl (%ebx),%eax
  800ca6:	84 c0                	test   %al,%al
  800ca8:	74 30                	je     800cda <strncmp+0x49>
  800caa:	3a 02                	cmp    (%edx),%al
  800cac:	75 2c                	jne    800cda <strncmp+0x49>
  800cae:	8d 43 01             	lea    0x1(%ebx),%eax
  800cb1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800cb3:	89 c3                	mov    %eax,%ebx
  800cb5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cb8:	39 c6                	cmp    %eax,%esi
  800cba:	74 17                	je     800cd3 <strncmp+0x42>
  800cbc:	0f b6 08             	movzbl (%eax),%ecx
  800cbf:	84 c9                	test   %cl,%cl
  800cc1:	74 17                	je     800cda <strncmp+0x49>
  800cc3:	83 c0 01             	add    $0x1,%eax
  800cc6:	3a 0a                	cmp    (%edx),%cl
  800cc8:	74 e9                	je     800cb3 <strncmp+0x22>
  800cca:	eb 0e                	jmp    800cda <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ccc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd1:	eb 0f                	jmp    800ce2 <strncmp+0x51>
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd8:	eb 08                	jmp    800ce2 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cda:	0f b6 03             	movzbl (%ebx),%eax
  800cdd:	0f b6 12             	movzbl (%edx),%edx
  800ce0:	29 d0                	sub    %edx,%eax
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	53                   	push   %ebx
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800cf0:	0f b6 10             	movzbl (%eax),%edx
  800cf3:	84 d2                	test   %dl,%dl
  800cf5:	74 1d                	je     800d14 <strchr+0x2e>
  800cf7:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800cf9:	38 d3                	cmp    %dl,%bl
  800cfb:	75 06                	jne    800d03 <strchr+0x1d>
  800cfd:	eb 1a                	jmp    800d19 <strchr+0x33>
  800cff:	38 ca                	cmp    %cl,%dl
  800d01:	74 16                	je     800d19 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d03:	83 c0 01             	add    $0x1,%eax
  800d06:	0f b6 10             	movzbl (%eax),%edx
  800d09:	84 d2                	test   %dl,%dl
  800d0b:	75 f2                	jne    800cff <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d12:	eb 05                	jmp    800d19 <strchr+0x33>
  800d14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	53                   	push   %ebx
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800d26:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800d29:	38 d3                	cmp    %dl,%bl
  800d2b:	74 14                	je     800d41 <strfind+0x25>
  800d2d:	89 d1                	mov    %edx,%ecx
  800d2f:	84 db                	test   %bl,%bl
  800d31:	74 0e                	je     800d41 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d33:	83 c0 01             	add    $0x1,%eax
  800d36:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d39:	38 ca                	cmp    %cl,%dl
  800d3b:	74 04                	je     800d41 <strfind+0x25>
  800d3d:	84 d2                	test   %dl,%dl
  800d3f:	75 f2                	jne    800d33 <strfind+0x17>
			break;
	return (char *) s;
}
  800d41:	5b                   	pop    %ebx
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d50:	85 c9                	test   %ecx,%ecx
  800d52:	74 36                	je     800d8a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d5a:	75 28                	jne    800d84 <memset+0x40>
  800d5c:	f6 c1 03             	test   $0x3,%cl
  800d5f:	75 23                	jne    800d84 <memset+0x40>
		c &= 0xFF;
  800d61:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d65:	89 d3                	mov    %edx,%ebx
  800d67:	c1 e3 08             	shl    $0x8,%ebx
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	c1 e6 18             	shl    $0x18,%esi
  800d6f:	89 d0                	mov    %edx,%eax
  800d71:	c1 e0 10             	shl    $0x10,%eax
  800d74:	09 f0                	or     %esi,%eax
  800d76:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d78:	89 d8                	mov    %ebx,%eax
  800d7a:	09 d0                	or     %edx,%eax
  800d7c:	c1 e9 02             	shr    $0x2,%ecx
  800d7f:	fc                   	cld    
  800d80:	f3 ab                	rep stos %eax,%es:(%edi)
  800d82:	eb 06                	jmp    800d8a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d87:	fc                   	cld    
  800d88:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d8a:	89 f8                	mov    %edi,%eax
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d9f:	39 c6                	cmp    %eax,%esi
  800da1:	73 35                	jae    800dd8 <memmove+0x47>
  800da3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800da6:	39 d0                	cmp    %edx,%eax
  800da8:	73 2e                	jae    800dd8 <memmove+0x47>
		s += n;
		d += n;
  800daa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dad:	89 d6                	mov    %edx,%esi
  800daf:	09 fe                	or     %edi,%esi
  800db1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800db7:	75 13                	jne    800dcc <memmove+0x3b>
  800db9:	f6 c1 03             	test   $0x3,%cl
  800dbc:	75 0e                	jne    800dcc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800dbe:	83 ef 04             	sub    $0x4,%edi
  800dc1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dc4:	c1 e9 02             	shr    $0x2,%ecx
  800dc7:	fd                   	std    
  800dc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dca:	eb 09                	jmp    800dd5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dcc:	83 ef 01             	sub    $0x1,%edi
  800dcf:	8d 72 ff             	lea    -0x1(%edx),%esi
  800dd2:	fd                   	std    
  800dd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dd5:	fc                   	cld    
  800dd6:	eb 1d                	jmp    800df5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd8:	89 f2                	mov    %esi,%edx
  800dda:	09 c2                	or     %eax,%edx
  800ddc:	f6 c2 03             	test   $0x3,%dl
  800ddf:	75 0f                	jne    800df0 <memmove+0x5f>
  800de1:	f6 c1 03             	test   $0x3,%cl
  800de4:	75 0a                	jne    800df0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800de6:	c1 e9 02             	shr    $0x2,%ecx
  800de9:	89 c7                	mov    %eax,%edi
  800deb:	fc                   	cld    
  800dec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dee:	eb 05                	jmp    800df5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800df0:	89 c7                	mov    %eax,%edi
  800df2:	fc                   	cld    
  800df3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800dfc:	ff 75 10             	pushl  0x10(%ebp)
  800dff:	ff 75 0c             	pushl  0xc(%ebp)
  800e02:	ff 75 08             	pushl  0x8(%ebp)
  800e05:	e8 87 ff ff ff       	call   800d91 <memmove>
}
  800e0a:	c9                   	leave  
  800e0b:	c3                   	ret    

00800e0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e18:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	74 39                	je     800e58 <memcmp+0x4c>
  800e1f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800e22:	0f b6 13             	movzbl (%ebx),%edx
  800e25:	0f b6 0e             	movzbl (%esi),%ecx
  800e28:	38 ca                	cmp    %cl,%dl
  800e2a:	75 17                	jne    800e43 <memcmp+0x37>
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e31:	eb 1a                	jmp    800e4d <memcmp+0x41>
  800e33:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800e38:	83 c0 01             	add    $0x1,%eax
  800e3b:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800e3f:	38 ca                	cmp    %cl,%dl
  800e41:	74 0a                	je     800e4d <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800e43:	0f b6 c2             	movzbl %dl,%eax
  800e46:	0f b6 c9             	movzbl %cl,%ecx
  800e49:	29 c8                	sub    %ecx,%eax
  800e4b:	eb 10                	jmp    800e5d <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e4d:	39 f8                	cmp    %edi,%eax
  800e4f:	75 e2                	jne    800e33 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e51:	b8 00 00 00 00       	mov    $0x0,%eax
  800e56:	eb 05                	jmp    800e5d <memcmp+0x51>
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	53                   	push   %ebx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800e69:	89 d0                	mov    %edx,%eax
  800e6b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800e6e:	39 c2                	cmp    %eax,%edx
  800e70:	73 1d                	jae    800e8f <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e72:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800e76:	0f b6 0a             	movzbl (%edx),%ecx
  800e79:	39 d9                	cmp    %ebx,%ecx
  800e7b:	75 09                	jne    800e86 <memfind+0x24>
  800e7d:	eb 14                	jmp    800e93 <memfind+0x31>
  800e7f:	0f b6 0a             	movzbl (%edx),%ecx
  800e82:	39 d9                	cmp    %ebx,%ecx
  800e84:	74 11                	je     800e97 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e86:	83 c2 01             	add    $0x1,%edx
  800e89:	39 d0                	cmp    %edx,%eax
  800e8b:	75 f2                	jne    800e7f <memfind+0x1d>
  800e8d:	eb 0a                	jmp    800e99 <memfind+0x37>
  800e8f:	89 d0                	mov    %edx,%eax
  800e91:	eb 06                	jmp    800e99 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e93:	89 d0                	mov    %edx,%eax
  800e95:	eb 02                	jmp    800e99 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e97:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e99:	5b                   	pop    %ebx
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea8:	0f b6 01             	movzbl (%ecx),%eax
  800eab:	3c 20                	cmp    $0x20,%al
  800ead:	74 04                	je     800eb3 <strtol+0x17>
  800eaf:	3c 09                	cmp    $0x9,%al
  800eb1:	75 0e                	jne    800ec1 <strtol+0x25>
		s++;
  800eb3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eb6:	0f b6 01             	movzbl (%ecx),%eax
  800eb9:	3c 20                	cmp    $0x20,%al
  800ebb:	74 f6                	je     800eb3 <strtol+0x17>
  800ebd:	3c 09                	cmp    $0x9,%al
  800ebf:	74 f2                	je     800eb3 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ec1:	3c 2b                	cmp    $0x2b,%al
  800ec3:	75 0a                	jne    800ecf <strtol+0x33>
		s++;
  800ec5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ec8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ecd:	eb 11                	jmp    800ee0 <strtol+0x44>
  800ecf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ed4:	3c 2d                	cmp    $0x2d,%al
  800ed6:	75 08                	jne    800ee0 <strtol+0x44>
		s++, neg = 1;
  800ed8:	83 c1 01             	add    $0x1,%ecx
  800edb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ee0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ee6:	75 15                	jne    800efd <strtol+0x61>
  800ee8:	80 39 30             	cmpb   $0x30,(%ecx)
  800eeb:	75 10                	jne    800efd <strtol+0x61>
  800eed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ef1:	75 7c                	jne    800f6f <strtol+0xd3>
		s += 2, base = 16;
  800ef3:	83 c1 02             	add    $0x2,%ecx
  800ef6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800efb:	eb 16                	jmp    800f13 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800efd:	85 db                	test   %ebx,%ebx
  800eff:	75 12                	jne    800f13 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f01:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f06:	80 39 30             	cmpb   $0x30,(%ecx)
  800f09:	75 08                	jne    800f13 <strtol+0x77>
		s++, base = 8;
  800f0b:	83 c1 01             	add    $0x1,%ecx
  800f0e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
  800f18:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f1b:	0f b6 11             	movzbl (%ecx),%edx
  800f1e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f21:	89 f3                	mov    %esi,%ebx
  800f23:	80 fb 09             	cmp    $0x9,%bl
  800f26:	77 08                	ja     800f30 <strtol+0x94>
			dig = *s - '0';
  800f28:	0f be d2             	movsbl %dl,%edx
  800f2b:	83 ea 30             	sub    $0x30,%edx
  800f2e:	eb 22                	jmp    800f52 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800f30:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f33:	89 f3                	mov    %esi,%ebx
  800f35:	80 fb 19             	cmp    $0x19,%bl
  800f38:	77 08                	ja     800f42 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800f3a:	0f be d2             	movsbl %dl,%edx
  800f3d:	83 ea 57             	sub    $0x57,%edx
  800f40:	eb 10                	jmp    800f52 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800f42:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f45:	89 f3                	mov    %esi,%ebx
  800f47:	80 fb 19             	cmp    $0x19,%bl
  800f4a:	77 16                	ja     800f62 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800f4c:	0f be d2             	movsbl %dl,%edx
  800f4f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f52:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f55:	7d 0b                	jge    800f62 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800f57:	83 c1 01             	add    $0x1,%ecx
  800f5a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f5e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f60:	eb b9                	jmp    800f1b <strtol+0x7f>

	if (endptr)
  800f62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f66:	74 0d                	je     800f75 <strtol+0xd9>
		*endptr = (char *) s;
  800f68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f6b:	89 0e                	mov    %ecx,(%esi)
  800f6d:	eb 06                	jmp    800f75 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f6f:	85 db                	test   %ebx,%ebx
  800f71:	74 98                	je     800f0b <strtol+0x6f>
  800f73:	eb 9e                	jmp    800f13 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f75:	89 c2                	mov    %eax,%edx
  800f77:	f7 da                	neg    %edx
  800f79:	85 ff                	test   %edi,%edi
  800f7b:	0f 45 c2             	cmovne %edx,%eax
}
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	57                   	push   %edi
  800f87:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f90:	8b 55 08             	mov    0x8(%ebp),%edx
  800f93:	89 c3                	mov    %eax,%ebx
  800f95:	89 c7                	mov    %eax,%edi
  800f97:	51                   	push   %ecx
  800f98:	52                   	push   %edx
  800f99:	53                   	push   %ebx
  800f9a:	56                   	push   %esi
  800f9b:	57                   	push   %edi
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	8d 35 a7 0f 80 00    	lea    0x800fa7,%esi
  800fa5:	0f 34                	sysenter 

00800fa7 <label_21>:
  800fa7:	89 ec                	mov    %ebp,%esp
  800fa9:	5d                   	pop    %ebp
  800faa:	5f                   	pop    %edi
  800fab:	5e                   	pop    %esi
  800fac:	5b                   	pop    %ebx
  800fad:	5a                   	pop    %edx
  800fae:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	57                   	push   %edi
  800fb7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc2:	89 ca                	mov    %ecx,%edx
  800fc4:	89 cb                	mov    %ecx,%ebx
  800fc6:	89 cf                	mov    %ecx,%edi
  800fc8:	51                   	push   %ecx
  800fc9:	52                   	push   %edx
  800fca:	53                   	push   %ebx
  800fcb:	56                   	push   %esi
  800fcc:	57                   	push   %edi
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	8d 35 d8 0f 80 00    	lea    0x800fd8,%esi
  800fd6:	0f 34                	sysenter 

00800fd8 <label_55>:
  800fd8:	89 ec                	mov    %ebp,%esp
  800fda:	5d                   	pop    %ebp
  800fdb:	5f                   	pop    %edi
  800fdc:	5e                   	pop    %esi
  800fdd:	5b                   	pop    %ebx
  800fde:	5a                   	pop    %edx
  800fdf:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fe0:	5b                   	pop    %ebx
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	57                   	push   %edi
  800fe8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fe9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fee:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff6:	89 d9                	mov    %ebx,%ecx
  800ff8:	89 df                	mov    %ebx,%edi
  800ffa:	51                   	push   %ecx
  800ffb:	52                   	push   %edx
  800ffc:	53                   	push   %ebx
  800ffd:	56                   	push   %esi
  800ffe:	57                   	push   %edi
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	8d 35 0a 10 80 00    	lea    0x80100a,%esi
  801008:	0f 34                	sysenter 

0080100a <label_90>:
  80100a:	89 ec                	mov    %ebp,%esp
  80100c:	5d                   	pop    %ebp
  80100d:	5f                   	pop    %edi
  80100e:	5e                   	pop    %esi
  80100f:	5b                   	pop    %ebx
  801010:	5a                   	pop    %edx
  801011:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801012:	85 c0                	test   %eax,%eax
  801014:	7e 17                	jle    80102d <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	50                   	push   %eax
  80101a:	6a 03                	push   $0x3
  80101c:	68 27 16 80 00       	push   $0x801627
  801021:	6a 29                	push   $0x29
  801023:	68 84 19 80 00       	push   $0x801984
  801028:	e8 4c f2 ff ff       	call   800279 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80102d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801030:	5b                   	pop    %ebx
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801039:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103e:	b8 02 00 00 00       	mov    $0x2,%eax
  801043:	89 ca                	mov    %ecx,%edx
  801045:	89 cb                	mov    %ecx,%ebx
  801047:	89 cf                	mov    %ecx,%edi
  801049:	51                   	push   %ecx
  80104a:	52                   	push   %edx
  80104b:	53                   	push   %ebx
  80104c:	56                   	push   %esi
  80104d:	57                   	push   %edi
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	8d 35 59 10 80 00    	lea    0x801059,%esi
  801057:	0f 34                	sysenter 

00801059 <label_139>:
  801059:	89 ec                	mov    %ebp,%esp
  80105b:	5d                   	pop    %ebp
  80105c:	5f                   	pop    %edi
  80105d:	5e                   	pop    %esi
  80105e:	5b                   	pop    %ebx
  80105f:	5a                   	pop    %edx
  801060:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801061:	5b                   	pop    %ebx
  801062:	5f                   	pop    %edi
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	57                   	push   %edi
  801069:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80106a:	bf 00 00 00 00       	mov    $0x0,%edi
  80106f:	b8 04 00 00 00       	mov    $0x4,%eax
  801074:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801077:	8b 55 08             	mov    0x8(%ebp),%edx
  80107a:	89 fb                	mov    %edi,%ebx
  80107c:	51                   	push   %ecx
  80107d:	52                   	push   %edx
  80107e:	53                   	push   %ebx
  80107f:	56                   	push   %esi
  801080:	57                   	push   %edi
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	8d 35 8c 10 80 00    	lea    0x80108c,%esi
  80108a:	0f 34                	sysenter 

0080108c <label_174>:
  80108c:	89 ec                	mov    %ebp,%esp
  80108e:	5d                   	pop    %ebp
  80108f:	5f                   	pop    %edi
  801090:	5e                   	pop    %esi
  801091:	5b                   	pop    %ebx
  801092:	5a                   	pop    %edx
  801093:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801094:	5b                   	pop    %ebx
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sys_yield>:

void
sys_yield(void)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80109d:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010a7:	89 d1                	mov    %edx,%ecx
  8010a9:	89 d3                	mov    %edx,%ebx
  8010ab:	89 d7                	mov    %edx,%edi
  8010ad:	51                   	push   %ecx
  8010ae:	52                   	push   %edx
  8010af:	53                   	push   %ebx
  8010b0:	56                   	push   %esi
  8010b1:	57                   	push   %edi
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	8d 35 bd 10 80 00    	lea    0x8010bd,%esi
  8010bb:	0f 34                	sysenter 

008010bd <label_209>:
  8010bd:	89 ec                	mov    %ebp,%esp
  8010bf:	5d                   	pop    %ebp
  8010c0:	5f                   	pop    %edi
  8010c1:	5e                   	pop    %esi
  8010c2:	5b                   	pop    %ebx
  8010c3:	5a                   	pop    %edx
  8010c4:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5f                   	pop    %edi
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	57                   	push   %edi
  8010cd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8010ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8010d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010e1:	51                   	push   %ecx
  8010e2:	52                   	push   %edx
  8010e3:	53                   	push   %ebx
  8010e4:	56                   	push   %esi
  8010e5:	57                   	push   %edi
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	8d 35 f1 10 80 00    	lea    0x8010f1,%esi
  8010ef:	0f 34                	sysenter 

008010f1 <label_244>:
  8010f1:	89 ec                	mov    %ebp,%esp
  8010f3:	5d                   	pop    %ebp
  8010f4:	5f                   	pop    %edi
  8010f5:	5e                   	pop    %esi
  8010f6:	5b                   	pop    %ebx
  8010f7:	5a                   	pop    %edx
  8010f8:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	7e 17                	jle    801114 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	50                   	push   %eax
  801101:	6a 05                	push   $0x5
  801103:	68 27 16 80 00       	push   $0x801627
  801108:	6a 29                	push   $0x29
  80110a:	68 84 19 80 00       	push   $0x801984
  80110f:	e8 65 f1 ff ff       	call   800279 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5f                   	pop    %edi
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	57                   	push   %edi
  80111f:	53                   	push   %ebx
  801120:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  801123:	8b 45 08             	mov    0x8(%ebp),%eax
  801126:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  801129:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  80112f:	8b 45 10             	mov    0x10(%ebp),%eax
  801132:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  801135:	8b 45 14             	mov    0x14(%ebp),%eax
  801138:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  80113b:	8b 45 18             	mov    0x18(%ebp),%eax
  80113e:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801141:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801144:	b9 00 00 00 00       	mov    $0x0,%ecx
  801149:	b8 06 00 00 00       	mov    $0x6,%eax
  80114e:	89 cb                	mov    %ecx,%ebx
  801150:	89 cf                	mov    %ecx,%edi
  801152:	51                   	push   %ecx
  801153:	52                   	push   %edx
  801154:	53                   	push   %ebx
  801155:	56                   	push   %esi
  801156:	57                   	push   %edi
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	8d 35 62 11 80 00    	lea    0x801162,%esi
  801160:	0f 34                	sysenter 

00801162 <label_304>:
  801162:	89 ec                	mov    %ebp,%esp
  801164:	5d                   	pop    %ebp
  801165:	5f                   	pop    %edi
  801166:	5e                   	pop    %esi
  801167:	5b                   	pop    %ebx
  801168:	5a                   	pop    %edx
  801169:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80116a:	85 c0                	test   %eax,%eax
  80116c:	7e 17                	jle    801185 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	50                   	push   %eax
  801172:	6a 06                	push   $0x6
  801174:	68 27 16 80 00       	push   $0x801627
  801179:	6a 29                	push   $0x29
  80117b:	68 84 19 80 00       	push   $0x801984
  801180:	e8 f4 f0 ff ff       	call   800279 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  801185:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	57                   	push   %edi
  801190:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801191:	bf 00 00 00 00       	mov    $0x0,%edi
  801196:	b8 07 00 00 00       	mov    $0x7,%eax
  80119b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119e:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a1:	89 fb                	mov    %edi,%ebx
  8011a3:	51                   	push   %ecx
  8011a4:	52                   	push   %edx
  8011a5:	53                   	push   %ebx
  8011a6:	56                   	push   %esi
  8011a7:	57                   	push   %edi
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	8d 35 b3 11 80 00    	lea    0x8011b3,%esi
  8011b1:	0f 34                	sysenter 

008011b3 <label_353>:
  8011b3:	89 ec                	mov    %ebp,%esp
  8011b5:	5d                   	pop    %ebp
  8011b6:	5f                   	pop    %edi
  8011b7:	5e                   	pop    %esi
  8011b8:	5b                   	pop    %ebx
  8011b9:	5a                   	pop    %edx
  8011ba:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	7e 17                	jle    8011d6 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bf:	83 ec 0c             	sub    $0xc,%esp
  8011c2:	50                   	push   %eax
  8011c3:	6a 07                	push   $0x7
  8011c5:	68 27 16 80 00       	push   $0x801627
  8011ca:	6a 29                	push   $0x29
  8011cc:	68 84 19 80 00       	push   $0x801984
  8011d1:	e8 a3 f0 ff ff       	call   800279 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8011e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e7:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f2:	89 fb                	mov    %edi,%ebx
  8011f4:	51                   	push   %ecx
  8011f5:	52                   	push   %edx
  8011f6:	53                   	push   %ebx
  8011f7:	56                   	push   %esi
  8011f8:	57                   	push   %edi
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	8d 35 04 12 80 00    	lea    0x801204,%esi
  801202:	0f 34                	sysenter 

00801204 <label_402>:
  801204:	89 ec                	mov    %ebp,%esp
  801206:	5d                   	pop    %ebp
  801207:	5f                   	pop    %edi
  801208:	5e                   	pop    %esi
  801209:	5b                   	pop    %ebx
  80120a:	5a                   	pop    %edx
  80120b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	7e 17                	jle    801227 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801210:	83 ec 0c             	sub    $0xc,%esp
  801213:	50                   	push   %eax
  801214:	6a 09                	push   $0x9
  801216:	68 27 16 80 00       	push   $0x801627
  80121b:	6a 29                	push   $0x29
  80121d:	68 84 19 80 00       	push   $0x801984
  801222:	e8 52 f0 ff ff       	call   800279 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801227:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122a:	5b                   	pop    %ebx
  80122b:	5f                   	pop    %edi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	57                   	push   %edi
  801232:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801233:	bf 00 00 00 00       	mov    $0x0,%edi
  801238:	b8 0a 00 00 00       	mov    $0xa,%eax
  80123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801240:	8b 55 08             	mov    0x8(%ebp),%edx
  801243:	89 fb                	mov    %edi,%ebx
  801245:	51                   	push   %ecx
  801246:	52                   	push   %edx
  801247:	53                   	push   %ebx
  801248:	56                   	push   %esi
  801249:	57                   	push   %edi
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	8d 35 55 12 80 00    	lea    0x801255,%esi
  801253:	0f 34                	sysenter 

00801255 <label_451>:
  801255:	89 ec                	mov    %ebp,%esp
  801257:	5d                   	pop    %ebp
  801258:	5f                   	pop    %edi
  801259:	5e                   	pop    %esi
  80125a:	5b                   	pop    %ebx
  80125b:	5a                   	pop    %edx
  80125c:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80125d:	85 c0                	test   %eax,%eax
  80125f:	7e 17                	jle    801278 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801261:	83 ec 0c             	sub    $0xc,%esp
  801264:	50                   	push   %eax
  801265:	6a 0a                	push   $0xa
  801267:	68 27 16 80 00       	push   $0x801627
  80126c:	6a 29                	push   $0x29
  80126e:	68 84 19 80 00       	push   $0x801984
  801273:	e8 01 f0 ff ff       	call   800279 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801278:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5f                   	pop    %edi
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	57                   	push   %edi
  801283:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801284:	b8 0c 00 00 00       	mov    $0xc,%eax
  801289:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128c:	8b 55 08             	mov    0x8(%ebp),%edx
  80128f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801292:	8b 7d 14             	mov    0x14(%ebp),%edi
  801295:	51                   	push   %ecx
  801296:	52                   	push   %edx
  801297:	53                   	push   %ebx
  801298:	56                   	push   %esi
  801299:	57                   	push   %edi
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	8d 35 a5 12 80 00    	lea    0x8012a5,%esi
  8012a3:	0f 34                	sysenter 

008012a5 <label_502>:
  8012a5:	89 ec                	mov    %ebp,%esp
  8012a7:	5d                   	pop    %ebp
  8012a8:	5f                   	pop    %edi
  8012a9:	5e                   	pop    %esi
  8012aa:	5b                   	pop    %ebx
  8012ab:	5a                   	pop    %edx
  8012ac:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012ad:	5b                   	pop    %ebx
  8012ae:	5f                   	pop    %edi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	57                   	push   %edi
  8012b5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012bb:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c3:	89 d9                	mov    %ebx,%ecx
  8012c5:	89 df                	mov    %ebx,%edi
  8012c7:	51                   	push   %ecx
  8012c8:	52                   	push   %edx
  8012c9:	53                   	push   %ebx
  8012ca:	56                   	push   %esi
  8012cb:	57                   	push   %edi
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	8d 35 d7 12 80 00    	lea    0x8012d7,%esi
  8012d5:	0f 34                	sysenter 

008012d7 <label_537>:
  8012d7:	89 ec                	mov    %ebp,%esp
  8012d9:	5d                   	pop    %ebp
  8012da:	5f                   	pop    %edi
  8012db:	5e                   	pop    %esi
  8012dc:	5b                   	pop    %ebx
  8012dd:	5a                   	pop    %edx
  8012de:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	7e 17                	jle    8012fa <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e3:	83 ec 0c             	sub    $0xc,%esp
  8012e6:	50                   	push   %eax
  8012e7:	6a 0d                	push   $0xd
  8012e9:	68 27 16 80 00       	push   $0x801627
  8012ee:	6a 29                	push   $0x29
  8012f0:	68 84 19 80 00       	push   $0x801984
  8012f5:	e8 7f ef ff ff       	call   800279 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5f                   	pop    %edi
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	57                   	push   %edi
  801305:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801306:	b9 00 00 00 00       	mov    $0x0,%ecx
  80130b:	b8 0e 00 00 00       	mov    $0xe,%eax
  801310:	8b 55 08             	mov    0x8(%ebp),%edx
  801313:	89 cb                	mov    %ecx,%ebx
  801315:	89 cf                	mov    %ecx,%edi
  801317:	51                   	push   %ecx
  801318:	52                   	push   %edx
  801319:	53                   	push   %ebx
  80131a:	56                   	push   %esi
  80131b:	57                   	push   %edi
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	8d 35 27 13 80 00    	lea    0x801327,%esi
  801325:	0f 34                	sysenter 

00801327 <label_586>:
  801327:	89 ec                	mov    %ebp,%esp
  801329:	5d                   	pop    %ebp
  80132a:	5f                   	pop    %edi
  80132b:	5e                   	pop    %esi
  80132c:	5b                   	pop    %ebx
  80132d:	5a                   	pop    %edx
  80132e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80132f:	5b                   	pop    %ebx
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
  801333:	66 90                	xchg   %ax,%ax
  801335:	66 90                	xchg   %ax,%ax
  801337:	66 90                	xchg   %ax,%ax
  801339:	66 90                	xchg   %ax,%ax
  80133b:	66 90                	xchg   %ax,%ax
  80133d:	66 90                	xchg   %ax,%ax
  80133f:	90                   	nop

00801340 <__udivdi3>:
  801340:	55                   	push   %ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 1c             	sub    $0x1c,%esp
  801347:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80134b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80134f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801357:	85 f6                	test   %esi,%esi
  801359:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80135d:	89 ca                	mov    %ecx,%edx
  80135f:	89 f8                	mov    %edi,%eax
  801361:	75 3d                	jne    8013a0 <__udivdi3+0x60>
  801363:	39 cf                	cmp    %ecx,%edi
  801365:	0f 87 c5 00 00 00    	ja     801430 <__udivdi3+0xf0>
  80136b:	85 ff                	test   %edi,%edi
  80136d:	89 fd                	mov    %edi,%ebp
  80136f:	75 0b                	jne    80137c <__udivdi3+0x3c>
  801371:	b8 01 00 00 00       	mov    $0x1,%eax
  801376:	31 d2                	xor    %edx,%edx
  801378:	f7 f7                	div    %edi
  80137a:	89 c5                	mov    %eax,%ebp
  80137c:	89 c8                	mov    %ecx,%eax
  80137e:	31 d2                	xor    %edx,%edx
  801380:	f7 f5                	div    %ebp
  801382:	89 c1                	mov    %eax,%ecx
  801384:	89 d8                	mov    %ebx,%eax
  801386:	89 cf                	mov    %ecx,%edi
  801388:	f7 f5                	div    %ebp
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	89 d8                	mov    %ebx,%eax
  80138e:	89 fa                	mov    %edi,%edx
  801390:	83 c4 1c             	add    $0x1c,%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    
  801398:	90                   	nop
  801399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	39 ce                	cmp    %ecx,%esi
  8013a2:	77 74                	ja     801418 <__udivdi3+0xd8>
  8013a4:	0f bd fe             	bsr    %esi,%edi
  8013a7:	83 f7 1f             	xor    $0x1f,%edi
  8013aa:	0f 84 98 00 00 00    	je     801448 <__udivdi3+0x108>
  8013b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8013b5:	89 f9                	mov    %edi,%ecx
  8013b7:	89 c5                	mov    %eax,%ebp
  8013b9:	29 fb                	sub    %edi,%ebx
  8013bb:	d3 e6                	shl    %cl,%esi
  8013bd:	89 d9                	mov    %ebx,%ecx
  8013bf:	d3 ed                	shr    %cl,%ebp
  8013c1:	89 f9                	mov    %edi,%ecx
  8013c3:	d3 e0                	shl    %cl,%eax
  8013c5:	09 ee                	or     %ebp,%esi
  8013c7:	89 d9                	mov    %ebx,%ecx
  8013c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013cd:	89 d5                	mov    %edx,%ebp
  8013cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013d3:	d3 ed                	shr    %cl,%ebp
  8013d5:	89 f9                	mov    %edi,%ecx
  8013d7:	d3 e2                	shl    %cl,%edx
  8013d9:	89 d9                	mov    %ebx,%ecx
  8013db:	d3 e8                	shr    %cl,%eax
  8013dd:	09 c2                	or     %eax,%edx
  8013df:	89 d0                	mov    %edx,%eax
  8013e1:	89 ea                	mov    %ebp,%edx
  8013e3:	f7 f6                	div    %esi
  8013e5:	89 d5                	mov    %edx,%ebp
  8013e7:	89 c3                	mov    %eax,%ebx
  8013e9:	f7 64 24 0c          	mull   0xc(%esp)
  8013ed:	39 d5                	cmp    %edx,%ebp
  8013ef:	72 10                	jb     801401 <__udivdi3+0xc1>
  8013f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8013f5:	89 f9                	mov    %edi,%ecx
  8013f7:	d3 e6                	shl    %cl,%esi
  8013f9:	39 c6                	cmp    %eax,%esi
  8013fb:	73 07                	jae    801404 <__udivdi3+0xc4>
  8013fd:	39 d5                	cmp    %edx,%ebp
  8013ff:	75 03                	jne    801404 <__udivdi3+0xc4>
  801401:	83 eb 01             	sub    $0x1,%ebx
  801404:	31 ff                	xor    %edi,%edi
  801406:	89 d8                	mov    %ebx,%eax
  801408:	89 fa                	mov    %edi,%edx
  80140a:	83 c4 1c             	add    $0x1c,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	31 ff                	xor    %edi,%edi
  80141a:	31 db                	xor    %ebx,%ebx
  80141c:	89 d8                	mov    %ebx,%eax
  80141e:	89 fa                	mov    %edi,%edx
  801420:	83 c4 1c             	add    $0x1c,%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    
  801428:	90                   	nop
  801429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801430:	89 d8                	mov    %ebx,%eax
  801432:	f7 f7                	div    %edi
  801434:	31 ff                	xor    %edi,%edi
  801436:	89 c3                	mov    %eax,%ebx
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	89 fa                	mov    %edi,%edx
  80143c:	83 c4 1c             	add    $0x1c,%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	39 ce                	cmp    %ecx,%esi
  80144a:	72 0c                	jb     801458 <__udivdi3+0x118>
  80144c:	31 db                	xor    %ebx,%ebx
  80144e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801452:	0f 87 34 ff ff ff    	ja     80138c <__udivdi3+0x4c>
  801458:	bb 01 00 00 00       	mov    $0x1,%ebx
  80145d:	e9 2a ff ff ff       	jmp    80138c <__udivdi3+0x4c>
  801462:	66 90                	xchg   %ax,%ax
  801464:	66 90                	xchg   %ax,%ax
  801466:	66 90                	xchg   %ax,%ax
  801468:	66 90                	xchg   %ax,%ax
  80146a:	66 90                	xchg   %ax,%ax
  80146c:	66 90                	xchg   %ax,%ax
  80146e:	66 90                	xchg   %ax,%ax

00801470 <__umoddi3>:
  801470:	55                   	push   %ebp
  801471:	57                   	push   %edi
  801472:	56                   	push   %esi
  801473:	53                   	push   %ebx
  801474:	83 ec 1c             	sub    $0x1c,%esp
  801477:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80147b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80147f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801487:	85 d2                	test   %edx,%edx
  801489:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80148d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801491:	89 f3                	mov    %esi,%ebx
  801493:	89 3c 24             	mov    %edi,(%esp)
  801496:	89 74 24 04          	mov    %esi,0x4(%esp)
  80149a:	75 1c                	jne    8014b8 <__umoddi3+0x48>
  80149c:	39 f7                	cmp    %esi,%edi
  80149e:	76 50                	jbe    8014f0 <__umoddi3+0x80>
  8014a0:	89 c8                	mov    %ecx,%eax
  8014a2:	89 f2                	mov    %esi,%edx
  8014a4:	f7 f7                	div    %edi
  8014a6:	89 d0                	mov    %edx,%eax
  8014a8:	31 d2                	xor    %edx,%edx
  8014aa:	83 c4 1c             	add    $0x1c,%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5f                   	pop    %edi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    
  8014b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014b8:	39 f2                	cmp    %esi,%edx
  8014ba:	89 d0                	mov    %edx,%eax
  8014bc:	77 52                	ja     801510 <__umoddi3+0xa0>
  8014be:	0f bd ea             	bsr    %edx,%ebp
  8014c1:	83 f5 1f             	xor    $0x1f,%ebp
  8014c4:	75 5a                	jne    801520 <__umoddi3+0xb0>
  8014c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8014ca:	0f 82 e0 00 00 00    	jb     8015b0 <__umoddi3+0x140>
  8014d0:	39 0c 24             	cmp    %ecx,(%esp)
  8014d3:	0f 86 d7 00 00 00    	jbe    8015b0 <__umoddi3+0x140>
  8014d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014e1:	83 c4 1c             	add    $0x1c,%esp
  8014e4:	5b                   	pop    %ebx
  8014e5:	5e                   	pop    %esi
  8014e6:	5f                   	pop    %edi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    
  8014e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014f0:	85 ff                	test   %edi,%edi
  8014f2:	89 fd                	mov    %edi,%ebp
  8014f4:	75 0b                	jne    801501 <__umoddi3+0x91>
  8014f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fb:	31 d2                	xor    %edx,%edx
  8014fd:	f7 f7                	div    %edi
  8014ff:	89 c5                	mov    %eax,%ebp
  801501:	89 f0                	mov    %esi,%eax
  801503:	31 d2                	xor    %edx,%edx
  801505:	f7 f5                	div    %ebp
  801507:	89 c8                	mov    %ecx,%eax
  801509:	f7 f5                	div    %ebp
  80150b:	89 d0                	mov    %edx,%eax
  80150d:	eb 99                	jmp    8014a8 <__umoddi3+0x38>
  80150f:	90                   	nop
  801510:	89 c8                	mov    %ecx,%eax
  801512:	89 f2                	mov    %esi,%edx
  801514:	83 c4 1c             	add    $0x1c,%esp
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	5f                   	pop    %edi
  80151a:	5d                   	pop    %ebp
  80151b:	c3                   	ret    
  80151c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801520:	8b 34 24             	mov    (%esp),%esi
  801523:	bf 20 00 00 00       	mov    $0x20,%edi
  801528:	89 e9                	mov    %ebp,%ecx
  80152a:	29 ef                	sub    %ebp,%edi
  80152c:	d3 e0                	shl    %cl,%eax
  80152e:	89 f9                	mov    %edi,%ecx
  801530:	89 f2                	mov    %esi,%edx
  801532:	d3 ea                	shr    %cl,%edx
  801534:	89 e9                	mov    %ebp,%ecx
  801536:	09 c2                	or     %eax,%edx
  801538:	89 d8                	mov    %ebx,%eax
  80153a:	89 14 24             	mov    %edx,(%esp)
  80153d:	89 f2                	mov    %esi,%edx
  80153f:	d3 e2                	shl    %cl,%edx
  801541:	89 f9                	mov    %edi,%ecx
  801543:	89 54 24 04          	mov    %edx,0x4(%esp)
  801547:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80154b:	d3 e8                	shr    %cl,%eax
  80154d:	89 e9                	mov    %ebp,%ecx
  80154f:	89 c6                	mov    %eax,%esi
  801551:	d3 e3                	shl    %cl,%ebx
  801553:	89 f9                	mov    %edi,%ecx
  801555:	89 d0                	mov    %edx,%eax
  801557:	d3 e8                	shr    %cl,%eax
  801559:	89 e9                	mov    %ebp,%ecx
  80155b:	09 d8                	or     %ebx,%eax
  80155d:	89 d3                	mov    %edx,%ebx
  80155f:	89 f2                	mov    %esi,%edx
  801561:	f7 34 24             	divl   (%esp)
  801564:	89 d6                	mov    %edx,%esi
  801566:	d3 e3                	shl    %cl,%ebx
  801568:	f7 64 24 04          	mull   0x4(%esp)
  80156c:	39 d6                	cmp    %edx,%esi
  80156e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801572:	89 d1                	mov    %edx,%ecx
  801574:	89 c3                	mov    %eax,%ebx
  801576:	72 08                	jb     801580 <__umoddi3+0x110>
  801578:	75 11                	jne    80158b <__umoddi3+0x11b>
  80157a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80157e:	73 0b                	jae    80158b <__umoddi3+0x11b>
  801580:	2b 44 24 04          	sub    0x4(%esp),%eax
  801584:	1b 14 24             	sbb    (%esp),%edx
  801587:	89 d1                	mov    %edx,%ecx
  801589:	89 c3                	mov    %eax,%ebx
  80158b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80158f:	29 da                	sub    %ebx,%edx
  801591:	19 ce                	sbb    %ecx,%esi
  801593:	89 f9                	mov    %edi,%ecx
  801595:	89 f0                	mov    %esi,%eax
  801597:	d3 e0                	shl    %cl,%eax
  801599:	89 e9                	mov    %ebp,%ecx
  80159b:	d3 ea                	shr    %cl,%edx
  80159d:	89 e9                	mov    %ebp,%ecx
  80159f:	d3 ee                	shr    %cl,%esi
  8015a1:	09 d0                	or     %edx,%eax
  8015a3:	89 f2                	mov    %esi,%edx
  8015a5:	83 c4 1c             	add    $0x1c,%esp
  8015a8:	5b                   	pop    %ebx
  8015a9:	5e                   	pop    %esi
  8015aa:	5f                   	pop    %edi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    
  8015ad:	8d 76 00             	lea    0x0(%esi),%esi
  8015b0:	29 f9                	sub    %edi,%ecx
  8015b2:	19 d6                	sbb    %edx,%esi
  8015b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bc:	e9 18 ff ff ff       	jmp    8014d9 <__umoddi3+0x69>
