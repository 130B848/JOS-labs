
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800059:	e8 f9 00 00 00       	call   800157 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 64             	imul   $0x64,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 10 20 80 00       	mov    %eax,0x802010
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 66 00 00 00       	call   800107 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	51                   	push   %ecx
  8000bb:	52                   	push   %edx
  8000bc:	53                   	push   %ebx
  8000bd:	54                   	push   %esp
  8000be:	55                   	push   %ebp
  8000bf:	56                   	push   %esi
  8000c0:	57                   	push   %edi
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	8d 35 cb 00 80 00    	lea    0x8000cb,%esi
  8000c9:	0f 34                	sysenter 

008000cb <label_21>:
  8000cb:	5f                   	pop    %edi
  8000cc:	5e                   	pop    %esi
  8000cd:	5d                   	pop    %ebp
  8000ce:	5c                   	pop    %esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5a                   	pop    %edx
  8000d1:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e5:	89 ca                	mov    %ecx,%edx
  8000e7:	89 cb                	mov    %ecx,%ebx
  8000e9:	89 cf                	mov    %ecx,%edi
  8000eb:	51                   	push   %ecx
  8000ec:	52                   	push   %edx
  8000ed:	53                   	push   %ebx
  8000ee:	54                   	push   %esp
  8000ef:	55                   	push   %ebp
  8000f0:	56                   	push   %esi
  8000f1:	57                   	push   %edi
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	8d 35 fc 00 80 00    	lea    0x8000fc,%esi
  8000fa:	0f 34                	sysenter 

008000fc <label_55>:
  8000fc:	5f                   	pop    %edi
  8000fd:	5e                   	pop    %esi
  8000fe:	5d                   	pop    %ebp
  8000ff:	5c                   	pop    %esp
  800100:	5b                   	pop    %ebx
  800101:	5a                   	pop    %edx
  800102:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800103:	5b                   	pop    %ebx
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	57                   	push   %edi
  80010b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80010c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800111:	b8 03 00 00 00       	mov    $0x3,%eax
  800116:	8b 55 08             	mov    0x8(%ebp),%edx
  800119:	89 d9                	mov    %ebx,%ecx
  80011b:	89 df                	mov    %ebx,%edi
  80011d:	51                   	push   %ecx
  80011e:	52                   	push   %edx
  80011f:	53                   	push   %ebx
  800120:	54                   	push   %esp
  800121:	55                   	push   %ebp
  800122:	56                   	push   %esi
  800123:	57                   	push   %edi
  800124:	89 e5                	mov    %esp,%ebp
  800126:	8d 35 2e 01 80 00    	lea    0x80012e,%esi
  80012c:	0f 34                	sysenter 

0080012e <label_90>:
  80012e:	5f                   	pop    %edi
  80012f:	5e                   	pop    %esi
  800130:	5d                   	pop    %ebp
  800131:	5c                   	pop    %esp
  800132:	5b                   	pop    %ebx
  800133:	5a                   	pop    %edx
  800134:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800135:	85 c0                	test   %eax,%eax
  800137:	7e 17                	jle    800150 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	50                   	push   %eax
  80013d:	6a 03                	push   $0x3
  80013f:	68 9c 11 80 00       	push   $0x80119c
  800144:	6a 2a                	push   $0x2a
  800146:	68 b9 11 80 00       	push   $0x8011b9
  80014b:	e8 9d 00 00 00       	call   8001ed <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800153:	5b                   	pop    %ebx
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80015c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800161:	b8 02 00 00 00       	mov    $0x2,%eax
  800166:	89 ca                	mov    %ecx,%edx
  800168:	89 cb                	mov    %ecx,%ebx
  80016a:	89 cf                	mov    %ecx,%edi
  80016c:	51                   	push   %ecx
  80016d:	52                   	push   %edx
  80016e:	53                   	push   %ebx
  80016f:	54                   	push   %esp
  800170:	55                   	push   %ebp
  800171:	56                   	push   %esi
  800172:	57                   	push   %edi
  800173:	89 e5                	mov    %esp,%ebp
  800175:	8d 35 7d 01 80 00    	lea    0x80017d,%esi
  80017b:	0f 34                	sysenter 

0080017d <label_139>:
  80017d:	5f                   	pop    %edi
  80017e:	5e                   	pop    %esi
  80017f:	5d                   	pop    %ebp
  800180:	5c                   	pop    %esp
  800181:	5b                   	pop    %ebx
  800182:	5a                   	pop    %edx
  800183:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %ebx
  800185:	5f                   	pop    %edi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80018d:	bf 00 00 00 00       	mov    $0x0,%edi
  800192:	b8 04 00 00 00       	mov    $0x4,%eax
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	89 fb                	mov    %edi,%ebx
  80019f:	51                   	push   %ecx
  8001a0:	52                   	push   %edx
  8001a1:	53                   	push   %ebx
  8001a2:	54                   	push   %esp
  8001a3:	55                   	push   %ebp
  8001a4:	56                   	push   %esi
  8001a5:	57                   	push   %edi
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	8d 35 b0 01 80 00    	lea    0x8001b0,%esi
  8001ae:	0f 34                	sysenter 

008001b0 <label_174>:
  8001b0:	5f                   	pop    %edi
  8001b1:	5e                   	pop    %esi
  8001b2:	5d                   	pop    %ebp
  8001b3:	5c                   	pop    %esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5a                   	pop    %edx
  8001b6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001b7:	5b                   	pop    %ebx
  8001b8:	5f                   	pop    %edi
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    

008001bb <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cd:	89 cb                	mov    %ecx,%ebx
  8001cf:	89 cf                	mov    %ecx,%edi
  8001d1:	51                   	push   %ecx
  8001d2:	52                   	push   %edx
  8001d3:	53                   	push   %ebx
  8001d4:	54                   	push   %esp
  8001d5:	55                   	push   %ebp
  8001d6:	56                   	push   %esi
  8001d7:	57                   	push   %edi
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	8d 35 e2 01 80 00    	lea    0x8001e2,%esi
  8001e0:	0f 34                	sysenter 

008001e2 <label_209>:
  8001e2:	5f                   	pop    %edi
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	5c                   	pop    %esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5a                   	pop    %edx
  8001e8:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001e9:	5b                   	pop    %ebx
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001f5:	a1 14 20 80 00       	mov    0x802014,%eax
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	74 11                	je     80020f <_panic+0x22>
		cprintf("%s: ", argv0);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	50                   	push   %eax
  800202:	68 c7 11 80 00       	push   $0x8011c7
  800207:	e8 d4 00 00 00       	call   8002e0 <cprintf>
  80020c:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80020f:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800215:	e8 3d ff ff ff       	call   800157 <sys_getenvid>
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	ff 75 0c             	pushl  0xc(%ebp)
  800220:	ff 75 08             	pushl  0x8(%ebp)
  800223:	56                   	push   %esi
  800224:	50                   	push   %eax
  800225:	68 cc 11 80 00       	push   $0x8011cc
  80022a:	e8 b1 00 00 00       	call   8002e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80022f:	83 c4 18             	add    $0x18,%esp
  800232:	53                   	push   %ebx
  800233:	ff 75 10             	pushl  0x10(%ebp)
  800236:	e8 54 00 00 00       	call   80028f <vcprintf>
	cprintf("\n");
  80023b:	c7 04 24 90 11 80 00 	movl   $0x801190,(%esp)
  800242:	e8 99 00 00 00       	call   8002e0 <cprintf>
  800247:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80024a:	cc                   	int3   
  80024b:	eb fd                	jmp    80024a <_panic+0x5d>

0080024d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	53                   	push   %ebx
  800251:	83 ec 04             	sub    $0x4,%esp
  800254:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800257:	8b 13                	mov    (%ebx),%edx
  800259:	8d 42 01             	lea    0x1(%edx),%eax
  80025c:	89 03                	mov    %eax,(%ebx)
  80025e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800261:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800265:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026a:	75 1a                	jne    800286 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	68 ff 00 00 00       	push   $0xff
  800274:	8d 43 08             	lea    0x8(%ebx),%eax
  800277:	50                   	push   %eax
  800278:	e8 29 fe ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  80027d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800283:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800286:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80028a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800298:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80029f:	00 00 00 
	b.cnt = 0;
  8002a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ac:	ff 75 0c             	pushl  0xc(%ebp)
  8002af:	ff 75 08             	pushl  0x8(%ebp)
  8002b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b8:	50                   	push   %eax
  8002b9:	68 4d 02 80 00       	push   $0x80024d
  8002be:	e8 c0 02 00 00       	call   800583 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c3:	83 c4 08             	add    $0x8,%esp
  8002c6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002cc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d2:	50                   	push   %eax
  8002d3:	e8 ce fd ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8002d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002e9:	50                   	push   %eax
  8002ea:	ff 75 08             	pushl  0x8(%ebp)
  8002ed:	e8 9d ff ff ff       	call   80028f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	57                   	push   %edi
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
  8002fa:	83 ec 1c             	sub    $0x1c,%esp
  8002fd:	89 c7                	mov    %eax,%edi
  8002ff:	89 d6                	mov    %edx,%esi
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	8b 55 0c             	mov    0xc(%ebp),%edx
  800307:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80030d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800310:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800314:	0f 85 bf 00 00 00    	jne    8003d9 <printnum+0xe5>
  80031a:	39 1d 0c 20 80 00    	cmp    %ebx,0x80200c
  800320:	0f 8d de 00 00 00    	jge    800404 <printnum+0x110>
		judge_time_for_space = width;
  800326:	89 1d 0c 20 80 00    	mov    %ebx,0x80200c
  80032c:	e9 d3 00 00 00       	jmp    800404 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800331:	83 eb 01             	sub    $0x1,%ebx
  800334:	85 db                	test   %ebx,%ebx
  800336:	7f 37                	jg     80036f <printnum+0x7b>
  800338:	e9 ea 00 00 00       	jmp    800427 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80033d:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800340:	a3 08 20 80 00       	mov    %eax,0x802008
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	56                   	push   %esi
  800349:	83 ec 04             	sub    $0x4,%esp
  80034c:	ff 75 dc             	pushl  -0x24(%ebp)
  80034f:	ff 75 d8             	pushl  -0x28(%ebp)
  800352:	ff 75 e4             	pushl  -0x1c(%ebp)
  800355:	ff 75 e0             	pushl  -0x20(%ebp)
  800358:	e8 d3 0c 00 00       	call   801030 <__umoddi3>
  80035d:	83 c4 14             	add    $0x14,%esp
  800360:	0f be 80 ef 11 80 00 	movsbl 0x8011ef(%eax),%eax
  800367:	50                   	push   %eax
  800368:	ff d7                	call   *%edi
  80036a:	83 c4 10             	add    $0x10,%esp
  80036d:	eb 16                	jmp    800385 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	56                   	push   %esi
  800373:	ff 75 18             	pushl  0x18(%ebp)
  800376:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800378:	83 c4 10             	add    $0x10,%esp
  80037b:	83 eb 01             	sub    $0x1,%ebx
  80037e:	75 ef                	jne    80036f <printnum+0x7b>
  800380:	e9 a2 00 00 00       	jmp    800427 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800385:	3b 1d 0c 20 80 00    	cmp    0x80200c,%ebx
  80038b:	0f 85 76 01 00 00    	jne    800507 <printnum+0x213>
		while(num_of_space-- > 0)
  800391:	a1 08 20 80 00       	mov    0x802008,%eax
  800396:	8d 50 ff             	lea    -0x1(%eax),%edx
  800399:	89 15 08 20 80 00    	mov    %edx,0x802008
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	7e 1d                	jle    8003c0 <printnum+0xcc>
			putch(' ', putdat);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	56                   	push   %esi
  8003a7:	6a 20                	push   $0x20
  8003a9:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8003ab:	a1 08 20 80 00       	mov    0x802008,%eax
  8003b0:	8d 50 ff             	lea    -0x1(%eax),%edx
  8003b3:	89 15 08 20 80 00    	mov    %edx,0x802008
  8003b9:	83 c4 10             	add    $0x10,%esp
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	7f e3                	jg     8003a3 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8003c0:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8003c7:	00 00 00 
		judge_time_for_space = 0;
  8003ca:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  8003d1:	00 00 00 
	}
}
  8003d4:	e9 2e 01 00 00       	jmp    800507 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ed:	83 fa 00             	cmp    $0x0,%edx
  8003f0:	0f 87 ba 00 00 00    	ja     8004b0 <printnum+0x1bc>
  8003f6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8003f9:	0f 83 b1 00 00 00    	jae    8004b0 <printnum+0x1bc>
  8003ff:	e9 2d ff ff ff       	jmp    800331 <printnum+0x3d>
  800404:	8b 45 10             	mov    0x10(%ebp),%eax
  800407:	ba 00 00 00 00       	mov    $0x0,%edx
  80040c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800412:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800415:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800418:	83 fa 00             	cmp    $0x0,%edx
  80041b:	77 37                	ja     800454 <printnum+0x160>
  80041d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800420:	73 32                	jae    800454 <printnum+0x160>
  800422:	e9 16 ff ff ff       	jmp    80033d <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	56                   	push   %esi
  80042b:	83 ec 04             	sub    $0x4,%esp
  80042e:	ff 75 dc             	pushl  -0x24(%ebp)
  800431:	ff 75 d8             	pushl  -0x28(%ebp)
  800434:	ff 75 e4             	pushl  -0x1c(%ebp)
  800437:	ff 75 e0             	pushl  -0x20(%ebp)
  80043a:	e8 f1 0b 00 00       	call   801030 <__umoddi3>
  80043f:	83 c4 14             	add    $0x14,%esp
  800442:	0f be 80 ef 11 80 00 	movsbl 0x8011ef(%eax),%eax
  800449:	50                   	push   %eax
  80044a:	ff d7                	call   *%edi
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	e9 b3 00 00 00       	jmp    800507 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800454:	83 ec 0c             	sub    $0xc,%esp
  800457:	ff 75 18             	pushl  0x18(%ebp)
  80045a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80045d:	50                   	push   %eax
  80045e:	ff 75 10             	pushl  0x10(%ebp)
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	ff 75 dc             	pushl  -0x24(%ebp)
  800467:	ff 75 d8             	pushl  -0x28(%ebp)
  80046a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046d:	ff 75 e0             	pushl  -0x20(%ebp)
  800470:	e8 8b 0a 00 00       	call   800f00 <__udivdi3>
  800475:	83 c4 18             	add    $0x18,%esp
  800478:	52                   	push   %edx
  800479:	50                   	push   %eax
  80047a:	89 f2                	mov    %esi,%edx
  80047c:	89 f8                	mov    %edi,%eax
  80047e:	e8 71 fe ff ff       	call   8002f4 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800483:	83 c4 18             	add    $0x18,%esp
  800486:	56                   	push   %esi
  800487:	83 ec 04             	sub    $0x4,%esp
  80048a:	ff 75 dc             	pushl  -0x24(%ebp)
  80048d:	ff 75 d8             	pushl  -0x28(%ebp)
  800490:	ff 75 e4             	pushl  -0x1c(%ebp)
  800493:	ff 75 e0             	pushl  -0x20(%ebp)
  800496:	e8 95 0b 00 00       	call   801030 <__umoddi3>
  80049b:	83 c4 14             	add    $0x14,%esp
  80049e:	0f be 80 ef 11 80 00 	movsbl 0x8011ef(%eax),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff d7                	call   *%edi
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	e9 d5 fe ff ff       	jmp    800385 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004b0:	83 ec 0c             	sub    $0xc,%esp
  8004b3:	ff 75 18             	pushl  0x18(%ebp)
  8004b6:	83 eb 01             	sub    $0x1,%ebx
  8004b9:	53                   	push   %ebx
  8004ba:	ff 75 10             	pushl  0x10(%ebp)
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cc:	e8 2f 0a 00 00       	call   800f00 <__udivdi3>
  8004d1:	83 c4 18             	add    $0x18,%esp
  8004d4:	52                   	push   %edx
  8004d5:	50                   	push   %eax
  8004d6:	89 f2                	mov    %esi,%edx
  8004d8:	89 f8                	mov    %edi,%eax
  8004da:	e8 15 fe ff ff       	call   8002f4 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004df:	83 c4 18             	add    $0x18,%esp
  8004e2:	56                   	push   %esi
  8004e3:	83 ec 04             	sub    $0x4,%esp
  8004e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f2:	e8 39 0b 00 00       	call   801030 <__umoddi3>
  8004f7:	83 c4 14             	add    $0x14,%esp
  8004fa:	0f be 80 ef 11 80 00 	movsbl 0x8011ef(%eax),%eax
  800501:	50                   	push   %eax
  800502:	ff d7                	call   *%edi
  800504:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800507:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050a:	5b                   	pop    %ebx
  80050b:	5e                   	pop    %esi
  80050c:	5f                   	pop    %edi
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    

0080050f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800512:	83 fa 01             	cmp    $0x1,%edx
  800515:	7e 0e                	jle    800525 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800517:	8b 10                	mov    (%eax),%edx
  800519:	8d 4a 08             	lea    0x8(%edx),%ecx
  80051c:	89 08                	mov    %ecx,(%eax)
  80051e:	8b 02                	mov    (%edx),%eax
  800520:	8b 52 04             	mov    0x4(%edx),%edx
  800523:	eb 22                	jmp    800547 <getuint+0x38>
	else if (lflag)
  800525:	85 d2                	test   %edx,%edx
  800527:	74 10                	je     800539 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800529:	8b 10                	mov    (%eax),%edx
  80052b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052e:	89 08                	mov    %ecx,(%eax)
  800530:	8b 02                	mov    (%edx),%eax
  800532:	ba 00 00 00 00       	mov    $0x0,%edx
  800537:	eb 0e                	jmp    800547 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800539:	8b 10                	mov    (%eax),%edx
  80053b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80053e:	89 08                	mov    %ecx,(%eax)
  800540:	8b 02                	mov    (%edx),%eax
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800547:	5d                   	pop    %ebp
  800548:	c3                   	ret    

00800549 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800553:	8b 10                	mov    (%eax),%edx
  800555:	3b 50 04             	cmp    0x4(%eax),%edx
  800558:	73 0a                	jae    800564 <sprintputch+0x1b>
		*b->buf++ = ch;
  80055a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80055d:	89 08                	mov    %ecx,(%eax)
  80055f:	8b 45 08             	mov    0x8(%ebp),%eax
  800562:	88 02                	mov    %al,(%edx)
}
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80056c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056f:	50                   	push   %eax
  800570:	ff 75 10             	pushl  0x10(%ebp)
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	ff 75 08             	pushl  0x8(%ebp)
  800579:	e8 05 00 00 00       	call   800583 <vprintfmt>
	va_end(ap);
}
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	c9                   	leave  
  800582:	c3                   	ret    

00800583 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800583:	55                   	push   %ebp
  800584:	89 e5                	mov    %esp,%ebp
  800586:	57                   	push   %edi
  800587:	56                   	push   %esi
  800588:	53                   	push   %ebx
  800589:	83 ec 2c             	sub    $0x2c,%esp
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800592:	eb 03                	jmp    800597 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800594:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800597:	8b 45 10             	mov    0x10(%ebp),%eax
  80059a:	8d 70 01             	lea    0x1(%eax),%esi
  80059d:	0f b6 00             	movzbl (%eax),%eax
  8005a0:	83 f8 25             	cmp    $0x25,%eax
  8005a3:	74 27                	je     8005cc <vprintfmt+0x49>
			if (ch == '\0')
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	75 0d                	jne    8005b6 <vprintfmt+0x33>
  8005a9:	e9 9d 04 00 00       	jmp    800a4b <vprintfmt+0x4c8>
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	0f 84 95 04 00 00    	je     800a4b <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	50                   	push   %eax
  8005bb:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005bd:	83 c6 01             	add    $0x1,%esi
  8005c0:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	83 f8 25             	cmp    $0x25,%eax
  8005ca:	75 e2                	jne    8005ae <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d1:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8005d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005ea:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8005f1:	eb 08                	jmp    8005fb <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8005f6:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8d 46 01             	lea    0x1(%esi),%eax
  8005fe:	89 45 10             	mov    %eax,0x10(%ebp)
  800601:	0f b6 06             	movzbl (%esi),%eax
  800604:	0f b6 d0             	movzbl %al,%edx
  800607:	83 e8 23             	sub    $0x23,%eax
  80060a:	3c 55                	cmp    $0x55,%al
  80060c:	0f 87 fa 03 00 00    	ja     800a0c <vprintfmt+0x489>
  800612:	0f b6 c0             	movzbl %al,%eax
  800615:	ff 24 85 f8 12 80 00 	jmp    *0x8012f8(,%eax,4)
  80061c:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80061f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800623:	eb d6                	jmp    8005fb <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800625:	8d 42 d0             	lea    -0x30(%edx),%eax
  800628:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80062b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80062f:	8d 50 d0             	lea    -0x30(%eax),%edx
  800632:	83 fa 09             	cmp    $0x9,%edx
  800635:	77 6b                	ja     8006a2 <vprintfmt+0x11f>
  800637:	8b 75 10             	mov    0x10(%ebp),%esi
  80063a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80063d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800640:	eb 09                	jmp    80064b <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800645:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800649:	eb b0                	jmp    8005fb <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80064b:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80064e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800651:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800655:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800658:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80065b:	83 f9 09             	cmp    $0x9,%ecx
  80065e:	76 eb                	jbe    80064b <vprintfmt+0xc8>
  800660:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800663:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800666:	eb 3d                	jmp    8006a5 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800679:	eb 2a                	jmp    8006a5 <vprintfmt+0x122>
  80067b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80067e:	85 c0                	test   %eax,%eax
  800680:	ba 00 00 00 00       	mov    $0x0,%edx
  800685:	0f 49 d0             	cmovns %eax,%edx
  800688:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 75 10             	mov    0x10(%ebp),%esi
  80068e:	e9 68 ff ff ff       	jmp    8005fb <vprintfmt+0x78>
  800693:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800696:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80069d:	e9 59 ff ff ff       	jmp    8005fb <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a9:	0f 89 4c ff ff ff    	jns    8005fb <vprintfmt+0x78>
				width = precision, precision = -1;
  8006af:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006bc:	e9 3a ff ff ff       	jmp    8005fb <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006c1:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c8:	e9 2e ff ff ff       	jmp    8005fb <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 50 04             	lea    0x4(%eax),%edx
  8006d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	ff 30                	pushl  (%eax)
  8006dc:	ff d7                	call   *%edi
			break;
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	e9 b1 fe ff ff       	jmp    800597 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	99                   	cltd   
  8006f2:	31 d0                	xor    %edx,%eax
  8006f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f6:	83 f8 06             	cmp    $0x6,%eax
  8006f9:	7f 0b                	jg     800706 <vprintfmt+0x183>
  8006fb:	8b 14 85 50 14 80 00 	mov    0x801450(,%eax,4),%edx
  800702:	85 d2                	test   %edx,%edx
  800704:	75 15                	jne    80071b <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800706:	50                   	push   %eax
  800707:	68 07 12 80 00       	push   $0x801207
  80070c:	53                   	push   %ebx
  80070d:	57                   	push   %edi
  80070e:	e8 53 fe ff ff       	call   800566 <printfmt>
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	e9 7c fe ff ff       	jmp    800597 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80071b:	52                   	push   %edx
  80071c:	68 10 12 80 00       	push   $0x801210
  800721:	53                   	push   %ebx
  800722:	57                   	push   %edi
  800723:	e8 3e fe ff ff       	call   800566 <printfmt>
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	e9 67 fe ff ff       	jmp    800597 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 50 04             	lea    0x4(%eax),%edx
  800736:	89 55 14             	mov    %edx,0x14(%ebp)
  800739:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80073b:	85 c0                	test   %eax,%eax
  80073d:	b9 00 12 80 00       	mov    $0x801200,%ecx
  800742:	0f 45 c8             	cmovne %eax,%ecx
  800745:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800748:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074c:	7e 06                	jle    800754 <vprintfmt+0x1d1>
  80074e:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800752:	75 19                	jne    80076d <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800757:	8d 70 01             	lea    0x1(%eax),%esi
  80075a:	0f b6 00             	movzbl (%eax),%eax
  80075d:	0f be d0             	movsbl %al,%edx
  800760:	85 d2                	test   %edx,%edx
  800762:	0f 85 9f 00 00 00    	jne    800807 <vprintfmt+0x284>
  800768:	e9 8c 00 00 00       	jmp    8007f9 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	ff 75 d0             	pushl  -0x30(%ebp)
  800773:	ff 75 cc             	pushl  -0x34(%ebp)
  800776:	e8 62 03 00 00       	call   800add <strnlen>
  80077b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80077e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	85 c9                	test   %ecx,%ecx
  800786:	0f 8e a6 02 00 00    	jle    800a32 <vprintfmt+0x4af>
					putch(padc, putdat);
  80078c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800790:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800793:	89 cb                	mov    %ecx,%ebx
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	56                   	push   %esi
  80079c:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	83 eb 01             	sub    $0x1,%ebx
  8007a4:	75 ef                	jne    800795 <vprintfmt+0x212>
  8007a6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	e9 81 02 00 00       	jmp    800a32 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007b1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007b5:	74 1b                	je     8007d2 <vprintfmt+0x24f>
  8007b7:	0f be c0             	movsbl %al,%eax
  8007ba:	83 e8 20             	sub    $0x20,%eax
  8007bd:	83 f8 5e             	cmp    $0x5e,%eax
  8007c0:	76 10                	jbe    8007d2 <vprintfmt+0x24f>
					putch('?', putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	6a 3f                	push   $0x3f
  8007ca:	ff 55 08             	call   *0x8(%ebp)
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	eb 0d                	jmp    8007df <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	52                   	push   %edx
  8007d9:	ff 55 08             	call   *0x8(%ebp)
  8007dc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007df:	83 ef 01             	sub    $0x1,%edi
  8007e2:	83 c6 01             	add    $0x1,%esi
  8007e5:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007e9:	0f be d0             	movsbl %al,%edx
  8007ec:	85 d2                	test   %edx,%edx
  8007ee:	75 31                	jne    800821 <vprintfmt+0x29e>
  8007f0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800800:	7f 33                	jg     800835 <vprintfmt+0x2b2>
  800802:	e9 90 fd ff ff       	jmp    800597 <vprintfmt+0x14>
  800807:	89 7d 08             	mov    %edi,0x8(%ebp)
  80080a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800810:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800813:	eb 0c                	jmp    800821 <vprintfmt+0x29e>
  800815:	89 7d 08             	mov    %edi,0x8(%ebp)
  800818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80081e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800821:	85 db                	test   %ebx,%ebx
  800823:	78 8c                	js     8007b1 <vprintfmt+0x22e>
  800825:	83 eb 01             	sub    $0x1,%ebx
  800828:	79 87                	jns    8007b1 <vprintfmt+0x22e>
  80082a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80082d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800830:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800833:	eb c4                	jmp    8007f9 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800835:	83 ec 08             	sub    $0x8,%esp
  800838:	53                   	push   %ebx
  800839:	6a 20                	push   $0x20
  80083b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	83 ee 01             	sub    $0x1,%esi
  800843:	75 f0                	jne    800835 <vprintfmt+0x2b2>
  800845:	e9 4d fd ff ff       	jmp    800597 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80084a:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80084e:	7e 16                	jle    800866 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 08             	lea    0x8(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 50 04             	mov    0x4(%eax),%edx
  80085c:	8b 00                	mov    (%eax),%eax
  80085e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800861:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800864:	eb 34                	jmp    80089a <vprintfmt+0x317>
	else if (lflag)
  800866:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80086a:	74 18                	je     800884 <vprintfmt+0x301>
		return va_arg(*ap, long);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8d 50 04             	lea    0x4(%eax),%edx
  800872:	89 55 14             	mov    %edx,0x14(%ebp)
  800875:	8b 30                	mov    (%eax),%esi
  800877:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	c1 f8 1f             	sar    $0x1f,%eax
  80087f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800882:	eb 16                	jmp    80089a <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8d 50 04             	lea    0x4(%eax),%edx
  80088a:	89 55 14             	mov    %edx,0x14(%ebp)
  80088d:	8b 30                	mov    (%eax),%esi
  80088f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800892:	89 f0                	mov    %esi,%eax
  800894:	c1 f8 1f             	sar    $0x1f,%eax
  800897:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80089a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80089d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8008a6:	85 d2                	test   %edx,%edx
  8008a8:	79 28                	jns    8008d2 <vprintfmt+0x34f>
				putch('-', putdat);
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	53                   	push   %ebx
  8008ae:	6a 2d                	push   $0x2d
  8008b0:	ff d7                	call   *%edi
				num = -(long long) num;
  8008b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008b8:	f7 d8                	neg    %eax
  8008ba:	83 d2 00             	adc    $0x0,%edx
  8008bd:	f7 da                	neg    %edx
  8008bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008c5:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8008c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008cd:	e9 b2 00 00 00       	jmp    800984 <vprintfmt+0x401>
  8008d2:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8008d7:	85 c9                	test   %ecx,%ecx
  8008d9:	0f 84 a5 00 00 00    	je     800984 <vprintfmt+0x401>
				putch('+', putdat);
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	6a 2b                	push   $0x2b
  8008e5:	ff d7                	call   *%edi
  8008e7:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8008ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ef:	e9 90 00 00 00       	jmp    800984 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 0b                	je     800903 <vprintfmt+0x380>
				putch('+', putdat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	6a 2b                	push   $0x2b
  8008fe:	ff d7                	call   *%edi
  800900:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800903:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800906:	8d 45 14             	lea    0x14(%ebp),%eax
  800909:	e8 01 fc ff ff       	call   80050f <getuint>
  80090e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800911:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800914:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800919:	eb 69                	jmp    800984 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	53                   	push   %ebx
  80091f:	6a 30                	push   $0x30
  800921:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800923:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800926:	8d 45 14             	lea    0x14(%ebp),%eax
  800929:	e8 e1 fb ff ff       	call   80050f <getuint>
  80092e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800931:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800934:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800937:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80093c:	eb 46                	jmp    800984 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	53                   	push   %ebx
  800942:	6a 30                	push   $0x30
  800944:	ff d7                	call   *%edi
			putch('x', putdat);
  800946:	83 c4 08             	add    $0x8,%esp
  800949:	53                   	push   %ebx
  80094a:	6a 78                	push   $0x78
  80094c:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80094e:	8b 45 14             	mov    0x14(%ebp),%eax
  800951:	8d 50 04             	lea    0x4(%eax),%edx
  800954:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800957:	8b 00                	mov    (%eax),%eax
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800961:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800964:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800967:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80096c:	eb 16                	jmp    800984 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80096e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800971:	8d 45 14             	lea    0x14(%ebp),%eax
  800974:	e8 96 fb ff ff       	call   80050f <getuint>
  800979:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80097f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800984:	83 ec 0c             	sub    $0xc,%esp
  800987:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80098b:	56                   	push   %esi
  80098c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80098f:	50                   	push   %eax
  800990:	ff 75 dc             	pushl  -0x24(%ebp)
  800993:	ff 75 d8             	pushl  -0x28(%ebp)
  800996:	89 da                	mov    %ebx,%edx
  800998:	89 f8                	mov    %edi,%eax
  80099a:	e8 55 f9 ff ff       	call   8002f4 <printnum>
			break;
  80099f:	83 c4 20             	add    $0x20,%esp
  8009a2:	e9 f0 fb ff ff       	jmp    800597 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8d 50 04             	lea    0x4(%eax),%edx
  8009ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b0:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8009b2:	85 f6                	test   %esi,%esi
  8009b4:	75 1a                	jne    8009d0 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8009b6:	83 ec 08             	sub    $0x8,%esp
  8009b9:	68 7c 12 80 00       	push   $0x80127c
  8009be:	68 10 12 80 00       	push   $0x801210
  8009c3:	e8 18 f9 ff ff       	call   8002e0 <cprintf>
  8009c8:	83 c4 10             	add    $0x10,%esp
  8009cb:	e9 c7 fb ff ff       	jmp    800597 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8009d0:	0f b6 03             	movzbl (%ebx),%eax
  8009d3:	84 c0                	test   %al,%al
  8009d5:	79 1f                	jns    8009f6 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8009d7:	83 ec 08             	sub    $0x8,%esp
  8009da:	68 b4 12 80 00       	push   $0x8012b4
  8009df:	68 10 12 80 00       	push   $0x801210
  8009e4:	e8 f7 f8 ff ff       	call   8002e0 <cprintf>
						*tmp = *(char *)putdat;
  8009e9:	0f b6 03             	movzbl (%ebx),%eax
  8009ec:	88 06                	mov    %al,(%esi)
  8009ee:	83 c4 10             	add    $0x10,%esp
  8009f1:	e9 a1 fb ff ff       	jmp    800597 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8009f6:	88 06                	mov    %al,(%esi)
  8009f8:	e9 9a fb ff ff       	jmp    800597 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009fd:	83 ec 08             	sub    $0x8,%esp
  800a00:	53                   	push   %ebx
  800a01:	52                   	push   %edx
  800a02:	ff d7                	call   *%edi
			break;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	e9 8b fb ff ff       	jmp    800597 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a0c:	83 ec 08             	sub    $0x8,%esp
  800a0f:	53                   	push   %ebx
  800a10:	6a 25                	push   $0x25
  800a12:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a14:	83 c4 10             	add    $0x10,%esp
  800a17:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a1b:	0f 84 73 fb ff ff    	je     800594 <vprintfmt+0x11>
  800a21:	83 ee 01             	sub    $0x1,%esi
  800a24:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a28:	75 f7                	jne    800a21 <vprintfmt+0x49e>
  800a2a:	89 75 10             	mov    %esi,0x10(%ebp)
  800a2d:	e9 65 fb ff ff       	jmp    800597 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a32:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a35:	8d 70 01             	lea    0x1(%eax),%esi
  800a38:	0f b6 00             	movzbl (%eax),%eax
  800a3b:	0f be d0             	movsbl %al,%edx
  800a3e:	85 d2                	test   %edx,%edx
  800a40:	0f 85 cf fd ff ff    	jne    800815 <vprintfmt+0x292>
  800a46:	e9 4c fb ff ff       	jmp    800597 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	83 ec 18             	sub    $0x18,%esp
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a62:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a66:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a70:	85 c0                	test   %eax,%eax
  800a72:	74 26                	je     800a9a <vsnprintf+0x47>
  800a74:	85 d2                	test   %edx,%edx
  800a76:	7e 22                	jle    800a9a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a78:	ff 75 14             	pushl  0x14(%ebp)
  800a7b:	ff 75 10             	pushl  0x10(%ebp)
  800a7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a81:	50                   	push   %eax
  800a82:	68 49 05 80 00       	push   $0x800549
  800a87:	e8 f7 fa ff ff       	call   800583 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a8f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	eb 05                	jmp    800a9f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aa7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aaa:	50                   	push   %eax
  800aab:	ff 75 10             	pushl  0x10(%ebp)
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	ff 75 08             	pushl  0x8(%ebp)
  800ab4:	e8 9a ff ff ff       	call   800a53 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    

00800abb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac1:	80 3a 00             	cmpb   $0x0,(%edx)
  800ac4:	74 10                	je     800ad6 <strlen+0x1b>
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800acb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ace:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad2:	75 f7                	jne    800acb <strlen+0x10>
  800ad4:	eb 05                	jmp    800adb <strlen+0x20>
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	53                   	push   %ebx
  800ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae7:	85 c9                	test   %ecx,%ecx
  800ae9:	74 1c                	je     800b07 <strnlen+0x2a>
  800aeb:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aee:	74 1e                	je     800b0e <strnlen+0x31>
  800af0:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800af5:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af7:	39 ca                	cmp    %ecx,%edx
  800af9:	74 18                	je     800b13 <strnlen+0x36>
  800afb:	83 c2 01             	add    $0x1,%edx
  800afe:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800b03:	75 f0                	jne    800af5 <strnlen+0x18>
  800b05:	eb 0c                	jmp    800b13 <strnlen+0x36>
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	eb 05                	jmp    800b13 <strnlen+0x36>
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b13:	5b                   	pop    %ebx
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	53                   	push   %ebx
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b20:	89 c2                	mov    %eax,%edx
  800b22:	83 c2 01             	add    $0x1,%edx
  800b25:	83 c1 01             	add    $0x1,%ecx
  800b28:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b2c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b2f:	84 db                	test   %bl,%bl
  800b31:	75 ef                	jne    800b22 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b33:	5b                   	pop    %ebx
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	53                   	push   %ebx
  800b3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b3d:	53                   	push   %ebx
  800b3e:	e8 78 ff ff ff       	call   800abb <strlen>
  800b43:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b46:	ff 75 0c             	pushl  0xc(%ebp)
  800b49:	01 d8                	add    %ebx,%eax
  800b4b:	50                   	push   %eax
  800b4c:	e8 c5 ff ff ff       	call   800b16 <strcpy>
	return dst;
}
  800b51:	89 d8                	mov    %ebx,%eax
  800b53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b60:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b66:	85 db                	test   %ebx,%ebx
  800b68:	74 17                	je     800b81 <strncpy+0x29>
  800b6a:	01 f3                	add    %esi,%ebx
  800b6c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b6e:	83 c1 01             	add    $0x1,%ecx
  800b71:	0f b6 02             	movzbl (%edx),%eax
  800b74:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b77:	80 3a 01             	cmpb   $0x1,(%edx)
  800b7a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b7d:	39 cb                	cmp    %ecx,%ebx
  800b7f:	75 ed                	jne    800b6e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b81:	89 f0                	mov    %esi,%eax
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b92:	8b 55 10             	mov    0x10(%ebp),%edx
  800b95:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b97:	85 d2                	test   %edx,%edx
  800b99:	74 35                	je     800bd0 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b9b:	89 d0                	mov    %edx,%eax
  800b9d:	83 e8 01             	sub    $0x1,%eax
  800ba0:	74 25                	je     800bc7 <strlcpy+0x40>
  800ba2:	0f b6 0b             	movzbl (%ebx),%ecx
  800ba5:	84 c9                	test   %cl,%cl
  800ba7:	74 22                	je     800bcb <strlcpy+0x44>
  800ba9:	8d 53 01             	lea    0x1(%ebx),%edx
  800bac:	01 c3                	add    %eax,%ebx
  800bae:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800bb0:	83 c0 01             	add    $0x1,%eax
  800bb3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb6:	39 da                	cmp    %ebx,%edx
  800bb8:	74 13                	je     800bcd <strlcpy+0x46>
  800bba:	83 c2 01             	add    $0x1,%edx
  800bbd:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800bc1:	84 c9                	test   %cl,%cl
  800bc3:	75 eb                	jne    800bb0 <strlcpy+0x29>
  800bc5:	eb 06                	jmp    800bcd <strlcpy+0x46>
  800bc7:	89 f0                	mov    %esi,%eax
  800bc9:	eb 02                	jmp    800bcd <strlcpy+0x46>
  800bcb:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bcd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bd0:	29 f0                	sub    %esi,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bdf:	0f b6 01             	movzbl (%ecx),%eax
  800be2:	84 c0                	test   %al,%al
  800be4:	74 15                	je     800bfb <strcmp+0x25>
  800be6:	3a 02                	cmp    (%edx),%al
  800be8:	75 11                	jne    800bfb <strcmp+0x25>
		p++, q++;
  800bea:	83 c1 01             	add    $0x1,%ecx
  800bed:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bf0:	0f b6 01             	movzbl (%ecx),%eax
  800bf3:	84 c0                	test   %al,%al
  800bf5:	74 04                	je     800bfb <strcmp+0x25>
  800bf7:	3a 02                	cmp    (%edx),%al
  800bf9:	74 ef                	je     800bea <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bfb:	0f b6 c0             	movzbl %al,%eax
  800bfe:	0f b6 12             	movzbl (%edx),%edx
  800c01:	29 d0                	sub    %edx,%eax
}
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c10:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c13:	85 f6                	test   %esi,%esi
  800c15:	74 29                	je     800c40 <strncmp+0x3b>
  800c17:	0f b6 03             	movzbl (%ebx),%eax
  800c1a:	84 c0                	test   %al,%al
  800c1c:	74 30                	je     800c4e <strncmp+0x49>
  800c1e:	3a 02                	cmp    (%edx),%al
  800c20:	75 2c                	jne    800c4e <strncmp+0x49>
  800c22:	8d 43 01             	lea    0x1(%ebx),%eax
  800c25:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c27:	89 c3                	mov    %eax,%ebx
  800c29:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c2c:	39 c6                	cmp    %eax,%esi
  800c2e:	74 17                	je     800c47 <strncmp+0x42>
  800c30:	0f b6 08             	movzbl (%eax),%ecx
  800c33:	84 c9                	test   %cl,%cl
  800c35:	74 17                	je     800c4e <strncmp+0x49>
  800c37:	83 c0 01             	add    $0x1,%eax
  800c3a:	3a 0a                	cmp    (%edx),%cl
  800c3c:	74 e9                	je     800c27 <strncmp+0x22>
  800c3e:	eb 0e                	jmp    800c4e <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c40:	b8 00 00 00 00       	mov    $0x0,%eax
  800c45:	eb 0f                	jmp    800c56 <strncmp+0x51>
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4c:	eb 08                	jmp    800c56 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c4e:	0f b6 03             	movzbl (%ebx),%eax
  800c51:	0f b6 12             	movzbl (%edx),%edx
  800c54:	29 d0                	sub    %edx,%eax
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	53                   	push   %ebx
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c64:	0f b6 10             	movzbl (%eax),%edx
  800c67:	84 d2                	test   %dl,%dl
  800c69:	74 1d                	je     800c88 <strchr+0x2e>
  800c6b:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800c6d:	38 d3                	cmp    %dl,%bl
  800c6f:	75 06                	jne    800c77 <strchr+0x1d>
  800c71:	eb 1a                	jmp    800c8d <strchr+0x33>
  800c73:	38 ca                	cmp    %cl,%dl
  800c75:	74 16                	je     800c8d <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
  800c7d:	84 d2                	test   %dl,%dl
  800c7f:	75 f2                	jne    800c73 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800c81:	b8 00 00 00 00       	mov    $0x0,%eax
  800c86:	eb 05                	jmp    800c8d <strchr+0x33>
  800c88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	53                   	push   %ebx
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c9a:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c9d:	38 d3                	cmp    %dl,%bl
  800c9f:	74 14                	je     800cb5 <strfind+0x25>
  800ca1:	89 d1                	mov    %edx,%ecx
  800ca3:	84 db                	test   %bl,%bl
  800ca5:	74 0e                	je     800cb5 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ca7:	83 c0 01             	add    $0x1,%eax
  800caa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cad:	38 ca                	cmp    %cl,%dl
  800caf:	74 04                	je     800cb5 <strfind+0x25>
  800cb1:	84 d2                	test   %dl,%dl
  800cb3:	75 f2                	jne    800ca7 <strfind+0x17>
			break;
	return (char *) s;
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cc4:	85 c9                	test   %ecx,%ecx
  800cc6:	74 36                	je     800cfe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cc8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cce:	75 28                	jne    800cf8 <memset+0x40>
  800cd0:	f6 c1 03             	test   $0x3,%cl
  800cd3:	75 23                	jne    800cf8 <memset+0x40>
		c &= 0xFF;
  800cd5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cd9:	89 d3                	mov    %edx,%ebx
  800cdb:	c1 e3 08             	shl    $0x8,%ebx
  800cde:	89 d6                	mov    %edx,%esi
  800ce0:	c1 e6 18             	shl    $0x18,%esi
  800ce3:	89 d0                	mov    %edx,%eax
  800ce5:	c1 e0 10             	shl    $0x10,%eax
  800ce8:	09 f0                	or     %esi,%eax
  800cea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cec:	89 d8                	mov    %ebx,%eax
  800cee:	09 d0                	or     %edx,%eax
  800cf0:	c1 e9 02             	shr    $0x2,%ecx
  800cf3:	fc                   	cld    
  800cf4:	f3 ab                	rep stos %eax,%es:(%edi)
  800cf6:	eb 06                	jmp    800cfe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfb:	fc                   	cld    
  800cfc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cfe:	89 f8                	mov    %edi,%eax
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d13:	39 c6                	cmp    %eax,%esi
  800d15:	73 35                	jae    800d4c <memmove+0x47>
  800d17:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d1a:	39 d0                	cmp    %edx,%eax
  800d1c:	73 2e                	jae    800d4c <memmove+0x47>
		s += n;
		d += n;
  800d1e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d21:	89 d6                	mov    %edx,%esi
  800d23:	09 fe                	or     %edi,%esi
  800d25:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d2b:	75 13                	jne    800d40 <memmove+0x3b>
  800d2d:	f6 c1 03             	test   $0x3,%cl
  800d30:	75 0e                	jne    800d40 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d32:	83 ef 04             	sub    $0x4,%edi
  800d35:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d38:	c1 e9 02             	shr    $0x2,%ecx
  800d3b:	fd                   	std    
  800d3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d3e:	eb 09                	jmp    800d49 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d40:	83 ef 01             	sub    $0x1,%edi
  800d43:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d46:	fd                   	std    
  800d47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d49:	fc                   	cld    
  800d4a:	eb 1d                	jmp    800d69 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d4c:	89 f2                	mov    %esi,%edx
  800d4e:	09 c2                	or     %eax,%edx
  800d50:	f6 c2 03             	test   $0x3,%dl
  800d53:	75 0f                	jne    800d64 <memmove+0x5f>
  800d55:	f6 c1 03             	test   $0x3,%cl
  800d58:	75 0a                	jne    800d64 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d5a:	c1 e9 02             	shr    $0x2,%ecx
  800d5d:	89 c7                	mov    %eax,%edi
  800d5f:	fc                   	cld    
  800d60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d62:	eb 05                	jmp    800d69 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d64:	89 c7                	mov    %eax,%edi
  800d66:	fc                   	cld    
  800d67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d70:	ff 75 10             	pushl  0x10(%ebp)
  800d73:	ff 75 0c             	pushl  0xc(%ebp)
  800d76:	ff 75 08             	pushl  0x8(%ebp)
  800d79:	e8 87 ff ff ff       	call   800d05 <memmove>
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	74 39                	je     800dcc <memcmp+0x4c>
  800d93:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800d96:	0f b6 13             	movzbl (%ebx),%edx
  800d99:	0f b6 0e             	movzbl (%esi),%ecx
  800d9c:	38 ca                	cmp    %cl,%dl
  800d9e:	75 17                	jne    800db7 <memcmp+0x37>
  800da0:	b8 00 00 00 00       	mov    $0x0,%eax
  800da5:	eb 1a                	jmp    800dc1 <memcmp+0x41>
  800da7:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800dac:	83 c0 01             	add    $0x1,%eax
  800daf:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800db3:	38 ca                	cmp    %cl,%dl
  800db5:	74 0a                	je     800dc1 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800db7:	0f b6 c2             	movzbl %dl,%eax
  800dba:	0f b6 c9             	movzbl %cl,%ecx
  800dbd:	29 c8                	sub    %ecx,%eax
  800dbf:	eb 10                	jmp    800dd1 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc1:	39 f8                	cmp    %edi,%eax
  800dc3:	75 e2                	jne    800da7 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dca:	eb 05                	jmp    800dd1 <memcmp+0x51>
  800dcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	53                   	push   %ebx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800ddd:	89 d0                	mov    %edx,%eax
  800ddf:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800de2:	39 c2                	cmp    %eax,%edx
  800de4:	73 1d                	jae    800e03 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800dea:	0f b6 0a             	movzbl (%edx),%ecx
  800ded:	39 d9                	cmp    %ebx,%ecx
  800def:	75 09                	jne    800dfa <memfind+0x24>
  800df1:	eb 14                	jmp    800e07 <memfind+0x31>
  800df3:	0f b6 0a             	movzbl (%edx),%ecx
  800df6:	39 d9                	cmp    %ebx,%ecx
  800df8:	74 11                	je     800e0b <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dfa:	83 c2 01             	add    $0x1,%edx
  800dfd:	39 d0                	cmp    %edx,%eax
  800dff:	75 f2                	jne    800df3 <memfind+0x1d>
  800e01:	eb 0a                	jmp    800e0d <memfind+0x37>
  800e03:	89 d0                	mov    %edx,%eax
  800e05:	eb 06                	jmp    800e0d <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e07:	89 d0                	mov    %edx,%eax
  800e09:	eb 02                	jmp    800e0d <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e0b:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e0d:	5b                   	pop    %ebx
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1c:	0f b6 01             	movzbl (%ecx),%eax
  800e1f:	3c 20                	cmp    $0x20,%al
  800e21:	74 04                	je     800e27 <strtol+0x17>
  800e23:	3c 09                	cmp    $0x9,%al
  800e25:	75 0e                	jne    800e35 <strtol+0x25>
		s++;
  800e27:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e2a:	0f b6 01             	movzbl (%ecx),%eax
  800e2d:	3c 20                	cmp    $0x20,%al
  800e2f:	74 f6                	je     800e27 <strtol+0x17>
  800e31:	3c 09                	cmp    $0x9,%al
  800e33:	74 f2                	je     800e27 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e35:	3c 2b                	cmp    $0x2b,%al
  800e37:	75 0a                	jne    800e43 <strtol+0x33>
		s++;
  800e39:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e3c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e41:	eb 11                	jmp    800e54 <strtol+0x44>
  800e43:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e48:	3c 2d                	cmp    $0x2d,%al
  800e4a:	75 08                	jne    800e54 <strtol+0x44>
		s++, neg = 1;
  800e4c:	83 c1 01             	add    $0x1,%ecx
  800e4f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e5a:	75 15                	jne    800e71 <strtol+0x61>
  800e5c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e5f:	75 10                	jne    800e71 <strtol+0x61>
  800e61:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e65:	75 7c                	jne    800ee3 <strtol+0xd3>
		s += 2, base = 16;
  800e67:	83 c1 02             	add    $0x2,%ecx
  800e6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e6f:	eb 16                	jmp    800e87 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e71:	85 db                	test   %ebx,%ebx
  800e73:	75 12                	jne    800e87 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e75:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800e7d:	75 08                	jne    800e87 <strtol+0x77>
		s++, base = 8;
  800e7f:	83 c1 01             	add    $0x1,%ecx
  800e82:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e8f:	0f b6 11             	movzbl (%ecx),%edx
  800e92:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e95:	89 f3                	mov    %esi,%ebx
  800e97:	80 fb 09             	cmp    $0x9,%bl
  800e9a:	77 08                	ja     800ea4 <strtol+0x94>
			dig = *s - '0';
  800e9c:	0f be d2             	movsbl %dl,%edx
  800e9f:	83 ea 30             	sub    $0x30,%edx
  800ea2:	eb 22                	jmp    800ec6 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800ea4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ea7:	89 f3                	mov    %esi,%ebx
  800ea9:	80 fb 19             	cmp    $0x19,%bl
  800eac:	77 08                	ja     800eb6 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800eae:	0f be d2             	movsbl %dl,%edx
  800eb1:	83 ea 57             	sub    $0x57,%edx
  800eb4:	eb 10                	jmp    800ec6 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800eb6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eb9:	89 f3                	mov    %esi,%ebx
  800ebb:	80 fb 19             	cmp    $0x19,%bl
  800ebe:	77 16                	ja     800ed6 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800ec0:	0f be d2             	movsbl %dl,%edx
  800ec3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ec6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ec9:	7d 0b                	jge    800ed6 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ecb:	83 c1 01             	add    $0x1,%ecx
  800ece:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ed2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ed4:	eb b9                	jmp    800e8f <strtol+0x7f>

	if (endptr)
  800ed6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eda:	74 0d                	je     800ee9 <strtol+0xd9>
		*endptr = (char *) s;
  800edc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800edf:	89 0e                	mov    %ecx,(%esi)
  800ee1:	eb 06                	jmp    800ee9 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ee3:	85 db                	test   %ebx,%ebx
  800ee5:	74 98                	je     800e7f <strtol+0x6f>
  800ee7:	eb 9e                	jmp    800e87 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ee9:	89 c2                	mov    %eax,%edx
  800eeb:	f7 da                	neg    %edx
  800eed:	85 ff                	test   %edi,%edi
  800eef:	0f 45 c2             	cmovne %edx,%eax
}
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    
  800ef7:	66 90                	xchg   %ax,%ax
  800ef9:	66 90                	xchg   %ax,%ax
  800efb:	66 90                	xchg   %ax,%ax
  800efd:	66 90                	xchg   %ax,%ax
  800eff:	90                   	nop

00800f00 <__udivdi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800f0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800f0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f17:	85 f6                	test   %esi,%esi
  800f19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f1d:	89 ca                	mov    %ecx,%edx
  800f1f:	89 f8                	mov    %edi,%eax
  800f21:	75 3d                	jne    800f60 <__udivdi3+0x60>
  800f23:	39 cf                	cmp    %ecx,%edi
  800f25:	0f 87 c5 00 00 00    	ja     800ff0 <__udivdi3+0xf0>
  800f2b:	85 ff                	test   %edi,%edi
  800f2d:	89 fd                	mov    %edi,%ebp
  800f2f:	75 0b                	jne    800f3c <__udivdi3+0x3c>
  800f31:	b8 01 00 00 00       	mov    $0x1,%eax
  800f36:	31 d2                	xor    %edx,%edx
  800f38:	f7 f7                	div    %edi
  800f3a:	89 c5                	mov    %eax,%ebp
  800f3c:	89 c8                	mov    %ecx,%eax
  800f3e:	31 d2                	xor    %edx,%edx
  800f40:	f7 f5                	div    %ebp
  800f42:	89 c1                	mov    %eax,%ecx
  800f44:	89 d8                	mov    %ebx,%eax
  800f46:	89 cf                	mov    %ecx,%edi
  800f48:	f7 f5                	div    %ebp
  800f4a:	89 c3                	mov    %eax,%ebx
  800f4c:	89 d8                	mov    %ebx,%eax
  800f4e:	89 fa                	mov    %edi,%edx
  800f50:	83 c4 1c             	add    $0x1c,%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
  800f58:	90                   	nop
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	39 ce                	cmp    %ecx,%esi
  800f62:	77 74                	ja     800fd8 <__udivdi3+0xd8>
  800f64:	0f bd fe             	bsr    %esi,%edi
  800f67:	83 f7 1f             	xor    $0x1f,%edi
  800f6a:	0f 84 98 00 00 00    	je     801008 <__udivdi3+0x108>
  800f70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f75:	89 f9                	mov    %edi,%ecx
  800f77:	89 c5                	mov    %eax,%ebp
  800f79:	29 fb                	sub    %edi,%ebx
  800f7b:	d3 e6                	shl    %cl,%esi
  800f7d:	89 d9                	mov    %ebx,%ecx
  800f7f:	d3 ed                	shr    %cl,%ebp
  800f81:	89 f9                	mov    %edi,%ecx
  800f83:	d3 e0                	shl    %cl,%eax
  800f85:	09 ee                	or     %ebp,%esi
  800f87:	89 d9                	mov    %ebx,%ecx
  800f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f8d:	89 d5                	mov    %edx,%ebp
  800f8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f93:	d3 ed                	shr    %cl,%ebp
  800f95:	89 f9                	mov    %edi,%ecx
  800f97:	d3 e2                	shl    %cl,%edx
  800f99:	89 d9                	mov    %ebx,%ecx
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	09 c2                	or     %eax,%edx
  800f9f:	89 d0                	mov    %edx,%eax
  800fa1:	89 ea                	mov    %ebp,%edx
  800fa3:	f7 f6                	div    %esi
  800fa5:	89 d5                	mov    %edx,%ebp
  800fa7:	89 c3                	mov    %eax,%ebx
  800fa9:	f7 64 24 0c          	mull   0xc(%esp)
  800fad:	39 d5                	cmp    %edx,%ebp
  800faf:	72 10                	jb     800fc1 <__udivdi3+0xc1>
  800fb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fb5:	89 f9                	mov    %edi,%ecx
  800fb7:	d3 e6                	shl    %cl,%esi
  800fb9:	39 c6                	cmp    %eax,%esi
  800fbb:	73 07                	jae    800fc4 <__udivdi3+0xc4>
  800fbd:	39 d5                	cmp    %edx,%ebp
  800fbf:	75 03                	jne    800fc4 <__udivdi3+0xc4>
  800fc1:	83 eb 01             	sub    $0x1,%ebx
  800fc4:	31 ff                	xor    %edi,%edi
  800fc6:	89 d8                	mov    %ebx,%eax
  800fc8:	89 fa                	mov    %edi,%edx
  800fca:	83 c4 1c             	add    $0x1c,%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5f                   	pop    %edi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    
  800fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd8:	31 ff                	xor    %edi,%edi
  800fda:	31 db                	xor    %ebx,%ebx
  800fdc:	89 d8                	mov    %ebx,%eax
  800fde:	89 fa                	mov    %edi,%edx
  800fe0:	83 c4 1c             	add    $0x1c,%esp
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5f                   	pop    %edi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    
  800fe8:	90                   	nop
  800fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	89 d8                	mov    %ebx,%eax
  800ff2:	f7 f7                	div    %edi
  800ff4:	31 ff                	xor    %edi,%edi
  800ff6:	89 c3                	mov    %eax,%ebx
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	89 fa                	mov    %edi,%edx
  800ffc:	83 c4 1c             	add    $0x1c,%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	39 ce                	cmp    %ecx,%esi
  80100a:	72 0c                	jb     801018 <__udivdi3+0x118>
  80100c:	31 db                	xor    %ebx,%ebx
  80100e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801012:	0f 87 34 ff ff ff    	ja     800f4c <__udivdi3+0x4c>
  801018:	bb 01 00 00 00       	mov    $0x1,%ebx
  80101d:	e9 2a ff ff ff       	jmp    800f4c <__udivdi3+0x4c>
  801022:	66 90                	xchg   %ax,%ax
  801024:	66 90                	xchg   %ax,%ax
  801026:	66 90                	xchg   %ax,%ax
  801028:	66 90                	xchg   %ax,%ax
  80102a:	66 90                	xchg   %ax,%ax
  80102c:	66 90                	xchg   %ax,%ax
  80102e:	66 90                	xchg   %ax,%ax

00801030 <__umoddi3>:
  801030:	55                   	push   %ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 1c             	sub    $0x1c,%esp
  801037:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80103b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80103f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801047:	85 d2                	test   %edx,%edx
  801049:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80104d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801051:	89 f3                	mov    %esi,%ebx
  801053:	89 3c 24             	mov    %edi,(%esp)
  801056:	89 74 24 04          	mov    %esi,0x4(%esp)
  80105a:	75 1c                	jne    801078 <__umoddi3+0x48>
  80105c:	39 f7                	cmp    %esi,%edi
  80105e:	76 50                	jbe    8010b0 <__umoddi3+0x80>
  801060:	89 c8                	mov    %ecx,%eax
  801062:	89 f2                	mov    %esi,%edx
  801064:	f7 f7                	div    %edi
  801066:	89 d0                	mov    %edx,%eax
  801068:	31 d2                	xor    %edx,%edx
  80106a:	83 c4 1c             	add    $0x1c,%esp
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5f                   	pop    %edi
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    
  801072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801078:	39 f2                	cmp    %esi,%edx
  80107a:	89 d0                	mov    %edx,%eax
  80107c:	77 52                	ja     8010d0 <__umoddi3+0xa0>
  80107e:	0f bd ea             	bsr    %edx,%ebp
  801081:	83 f5 1f             	xor    $0x1f,%ebp
  801084:	75 5a                	jne    8010e0 <__umoddi3+0xb0>
  801086:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80108a:	0f 82 e0 00 00 00    	jb     801170 <__umoddi3+0x140>
  801090:	39 0c 24             	cmp    %ecx,(%esp)
  801093:	0f 86 d7 00 00 00    	jbe    801170 <__umoddi3+0x140>
  801099:	8b 44 24 08          	mov    0x8(%esp),%eax
  80109d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010a1:	83 c4 1c             	add    $0x1c,%esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5e                   	pop    %esi
  8010a6:	5f                   	pop    %edi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    
  8010a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b0:	85 ff                	test   %edi,%edi
  8010b2:	89 fd                	mov    %edi,%ebp
  8010b4:	75 0b                	jne    8010c1 <__umoddi3+0x91>
  8010b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	f7 f7                	div    %edi
  8010bf:	89 c5                	mov    %eax,%ebp
  8010c1:	89 f0                	mov    %esi,%eax
  8010c3:	31 d2                	xor    %edx,%edx
  8010c5:	f7 f5                	div    %ebp
  8010c7:	89 c8                	mov    %ecx,%eax
  8010c9:	f7 f5                	div    %ebp
  8010cb:	89 d0                	mov    %edx,%eax
  8010cd:	eb 99                	jmp    801068 <__umoddi3+0x38>
  8010cf:	90                   	nop
  8010d0:	89 c8                	mov    %ecx,%eax
  8010d2:	89 f2                	mov    %esi,%edx
  8010d4:	83 c4 1c             	add    $0x1c,%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	8b 34 24             	mov    (%esp),%esi
  8010e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010e8:	89 e9                	mov    %ebp,%ecx
  8010ea:	29 ef                	sub    %ebp,%edi
  8010ec:	d3 e0                	shl    %cl,%eax
  8010ee:	89 f9                	mov    %edi,%ecx
  8010f0:	89 f2                	mov    %esi,%edx
  8010f2:	d3 ea                	shr    %cl,%edx
  8010f4:	89 e9                	mov    %ebp,%ecx
  8010f6:	09 c2                	or     %eax,%edx
  8010f8:	89 d8                	mov    %ebx,%eax
  8010fa:	89 14 24             	mov    %edx,(%esp)
  8010fd:	89 f2                	mov    %esi,%edx
  8010ff:	d3 e2                	shl    %cl,%edx
  801101:	89 f9                	mov    %edi,%ecx
  801103:	89 54 24 04          	mov    %edx,0x4(%esp)
  801107:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80110b:	d3 e8                	shr    %cl,%eax
  80110d:	89 e9                	mov    %ebp,%ecx
  80110f:	89 c6                	mov    %eax,%esi
  801111:	d3 e3                	shl    %cl,%ebx
  801113:	89 f9                	mov    %edi,%ecx
  801115:	89 d0                	mov    %edx,%eax
  801117:	d3 e8                	shr    %cl,%eax
  801119:	89 e9                	mov    %ebp,%ecx
  80111b:	09 d8                	or     %ebx,%eax
  80111d:	89 d3                	mov    %edx,%ebx
  80111f:	89 f2                	mov    %esi,%edx
  801121:	f7 34 24             	divl   (%esp)
  801124:	89 d6                	mov    %edx,%esi
  801126:	d3 e3                	shl    %cl,%ebx
  801128:	f7 64 24 04          	mull   0x4(%esp)
  80112c:	39 d6                	cmp    %edx,%esi
  80112e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801132:	89 d1                	mov    %edx,%ecx
  801134:	89 c3                	mov    %eax,%ebx
  801136:	72 08                	jb     801140 <__umoddi3+0x110>
  801138:	75 11                	jne    80114b <__umoddi3+0x11b>
  80113a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80113e:	73 0b                	jae    80114b <__umoddi3+0x11b>
  801140:	2b 44 24 04          	sub    0x4(%esp),%eax
  801144:	1b 14 24             	sbb    (%esp),%edx
  801147:	89 d1                	mov    %edx,%ecx
  801149:	89 c3                	mov    %eax,%ebx
  80114b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80114f:	29 da                	sub    %ebx,%edx
  801151:	19 ce                	sbb    %ecx,%esi
  801153:	89 f9                	mov    %edi,%ecx
  801155:	89 f0                	mov    %esi,%eax
  801157:	d3 e0                	shl    %cl,%eax
  801159:	89 e9                	mov    %ebp,%ecx
  80115b:	d3 ea                	shr    %cl,%edx
  80115d:	89 e9                	mov    %ebp,%ecx
  80115f:	d3 ee                	shr    %cl,%esi
  801161:	09 d0                	or     %edx,%eax
  801163:	89 f2                	mov    %esi,%edx
  801165:	83 c4 1c             	add    $0x1c,%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    
  80116d:	8d 76 00             	lea    0x0(%esi),%esi
  801170:	29 f9                	sub    %edi,%ecx
  801172:	19 d6                	sbb    %edx,%esi
  801174:	89 74 24 04          	mov    %esi,0x4(%esp)
  801178:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80117c:	e9 18 ff ff ff       	jmp    801099 <__umoddi3+0x69>
