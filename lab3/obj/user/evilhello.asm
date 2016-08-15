
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 5d 00 00 00       	call   8000a2 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800055:	e8 f9 00 00 00       	call   800153 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 64             	imul   $0x64,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 66 00 00 00       	call   800103 <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000af:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b2:	89 c3                	mov    %eax,%ebx
  8000b4:	89 c7                	mov    %eax,%edi
  8000b6:	51                   	push   %ecx
  8000b7:	52                   	push   %edx
  8000b8:	53                   	push   %ebx
  8000b9:	54                   	push   %esp
  8000ba:	55                   	push   %ebp
  8000bb:	56                   	push   %esi
  8000bc:	57                   	push   %edi
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	8d 35 c7 00 80 00    	lea    0x8000c7,%esi
  8000c5:	0f 34                	sysenter 

008000c7 <label_21>:
  8000c7:	5f                   	pop    %edi
  8000c8:	5e                   	pop    %esi
  8000c9:	5d                   	pop    %ebp
  8000ca:	5c                   	pop    %esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5a                   	pop    %edx
  8000cd:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 ca                	mov    %ecx,%edx
  8000e3:	89 cb                	mov    %ecx,%ebx
  8000e5:	89 cf                	mov    %ecx,%edi
  8000e7:	51                   	push   %ecx
  8000e8:	52                   	push   %edx
  8000e9:	53                   	push   %ebx
  8000ea:	54                   	push   %esp
  8000eb:	55                   	push   %ebp
  8000ec:	56                   	push   %esi
  8000ed:	57                   	push   %edi
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	8d 35 f8 00 80 00    	lea    0x8000f8,%esi
  8000f6:	0f 34                	sysenter 

008000f8 <label_55>:
  8000f8:	5f                   	pop    %edi
  8000f9:	5e                   	pop    %esi
  8000fa:	5d                   	pop    %ebp
  8000fb:	5c                   	pop    %esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5a                   	pop    %edx
  8000fe:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ff:	5b                   	pop    %ebx
  800100:	5f                   	pop    %edi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	57                   	push   %edi
  800107:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800108:	bb 00 00 00 00       	mov    $0x0,%ebx
  80010d:	b8 03 00 00 00       	mov    $0x3,%eax
  800112:	8b 55 08             	mov    0x8(%ebp),%edx
  800115:	89 d9                	mov    %ebx,%ecx
  800117:	89 df                	mov    %ebx,%edi
  800119:	51                   	push   %ecx
  80011a:	52                   	push   %edx
  80011b:	53                   	push   %ebx
  80011c:	54                   	push   %esp
  80011d:	55                   	push   %ebp
  80011e:	56                   	push   %esi
  80011f:	57                   	push   %edi
  800120:	89 e5                	mov    %esp,%ebp
  800122:	8d 35 2a 01 80 00    	lea    0x80012a,%esi
  800128:	0f 34                	sysenter 

0080012a <label_90>:
  80012a:	5f                   	pop    %edi
  80012b:	5e                   	pop    %esi
  80012c:	5d                   	pop    %ebp
  80012d:	5c                   	pop    %esp
  80012e:	5b                   	pop    %ebx
  80012f:	5a                   	pop    %edx
  800130:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7e 17                	jle    80014c <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	50                   	push   %eax
  800139:	6a 03                	push   $0x3
  80013b:	68 8e 11 80 00       	push   $0x80118e
  800140:	6a 2a                	push   $0x2a
  800142:	68 ab 11 80 00       	push   $0x8011ab
  800147:	e8 9d 00 00 00       	call   8001e9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800158:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015d:	b8 02 00 00 00       	mov    $0x2,%eax
  800162:	89 ca                	mov    %ecx,%edx
  800164:	89 cb                	mov    %ecx,%ebx
  800166:	89 cf                	mov    %ecx,%edi
  800168:	51                   	push   %ecx
  800169:	52                   	push   %edx
  80016a:	53                   	push   %ebx
  80016b:	54                   	push   %esp
  80016c:	55                   	push   %ebp
  80016d:	56                   	push   %esi
  80016e:	57                   	push   %edi
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	8d 35 79 01 80 00    	lea    0x800179,%esi
  800177:	0f 34                	sysenter 

00800179 <label_139>:
  800179:	5f                   	pop    %edi
  80017a:	5e                   	pop    %esi
  80017b:	5d                   	pop    %ebp
  80017c:	5c                   	pop    %esp
  80017d:	5b                   	pop    %ebx
  80017e:	5a                   	pop    %edx
  80017f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800189:	bf 00 00 00 00       	mov    $0x0,%edi
  80018e:	b8 04 00 00 00       	mov    $0x4,%eax
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 fb                	mov    %edi,%ebx
  80019b:	51                   	push   %ecx
  80019c:	52                   	push   %edx
  80019d:	53                   	push   %ebx
  80019e:	54                   	push   %esp
  80019f:	55                   	push   %ebp
  8001a0:	56                   	push   %esi
  8001a1:	57                   	push   %edi
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	8d 35 ac 01 80 00    	lea    0x8001ac,%esi
  8001aa:	0f 34                	sysenter 

008001ac <label_174>:
  8001ac:	5f                   	pop    %edi
  8001ad:	5e                   	pop    %esi
  8001ae:	5d                   	pop    %ebp
  8001af:	5c                   	pop    %esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5a                   	pop    %edx
  8001b2:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001b3:	5b                   	pop    %ebx
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	89 cb                	mov    %ecx,%ebx
  8001cb:	89 cf                	mov    %ecx,%edi
  8001cd:	51                   	push   %ecx
  8001ce:	52                   	push   %edx
  8001cf:	53                   	push   %ebx
  8001d0:	54                   	push   %esp
  8001d1:	55                   	push   %ebp
  8001d2:	56                   	push   %esi
  8001d3:	57                   	push   %edi
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	8d 35 de 01 80 00    	lea    0x8001de,%esi
  8001dc:	0f 34                	sysenter 

008001de <label_209>:
  8001de:	5f                   	pop    %edi
  8001df:	5e                   	pop    %esi
  8001e0:	5d                   	pop    %ebp
  8001e1:	5c                   	pop    %esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5a                   	pop    %edx
  8001e4:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001e5:	5b                   	pop    %ebx
  8001e6:	5f                   	pop    %edi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001f1:	a1 10 20 80 00       	mov    0x802010,%eax
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	74 11                	je     80020b <_panic+0x22>
		cprintf("%s: ", argv0);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	50                   	push   %eax
  8001fe:	68 b9 11 80 00       	push   $0x8011b9
  800203:	e8 d4 00 00 00       	call   8002dc <cprintf>
  800208:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80020b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800211:	e8 3d ff ff ff       	call   800153 <sys_getenvid>
  800216:	83 ec 0c             	sub    $0xc,%esp
  800219:	ff 75 0c             	pushl  0xc(%ebp)
  80021c:	ff 75 08             	pushl  0x8(%ebp)
  80021f:	56                   	push   %esi
  800220:	50                   	push   %eax
  800221:	68 c0 11 80 00       	push   $0x8011c0
  800226:	e8 b1 00 00 00       	call   8002dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80022b:	83 c4 18             	add    $0x18,%esp
  80022e:	53                   	push   %ebx
  80022f:	ff 75 10             	pushl  0x10(%ebp)
  800232:	e8 54 00 00 00       	call   80028b <vcprintf>
	cprintf("\n");
  800237:	c7 04 24 be 11 80 00 	movl   $0x8011be,(%esp)
  80023e:	e8 99 00 00 00       	call   8002dc <cprintf>
  800243:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800246:	cc                   	int3   
  800247:	eb fd                	jmp    800246 <_panic+0x5d>

00800249 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	53                   	push   %ebx
  80024d:	83 ec 04             	sub    $0x4,%esp
  800250:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800253:	8b 13                	mov    (%ebx),%edx
  800255:	8d 42 01             	lea    0x1(%edx),%eax
  800258:	89 03                	mov    %eax,(%ebx)
  80025a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800261:	3d ff 00 00 00       	cmp    $0xff,%eax
  800266:	75 1a                	jne    800282 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	68 ff 00 00 00       	push   $0xff
  800270:	8d 43 08             	lea    0x8(%ebx),%eax
  800273:	50                   	push   %eax
  800274:	e8 29 fe ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  800279:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800282:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800286:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800294:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80029b:	00 00 00 
	b.cnt = 0;
  80029e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a8:	ff 75 0c             	pushl  0xc(%ebp)
  8002ab:	ff 75 08             	pushl  0x8(%ebp)
  8002ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b4:	50                   	push   %eax
  8002b5:	68 49 02 80 00       	push   $0x800249
  8002ba:	e8 c0 02 00 00       	call   80057f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bf:	83 c4 08             	add    $0x8,%esp
  8002c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ce:	50                   	push   %eax
  8002cf:	e8 ce fd ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8002d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002e5:	50                   	push   %eax
  8002e6:	ff 75 08             	pushl  0x8(%ebp)
  8002e9:	e8 9d ff ff ff       	call   80028b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 1c             	sub    $0x1c,%esp
  8002f9:	89 c7                	mov    %eax,%edi
  8002fb:	89 d6                	mov    %edx,%esi
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	8b 55 0c             	mov    0xc(%ebp),%edx
  800303:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800306:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800309:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80030c:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800310:	0f 85 bf 00 00 00    	jne    8003d5 <printnum+0xe5>
  800316:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  80031c:	0f 8d de 00 00 00    	jge    800400 <printnum+0x110>
		judge_time_for_space = width;
  800322:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800328:	e9 d3 00 00 00       	jmp    800400 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80032d:	83 eb 01             	sub    $0x1,%ebx
  800330:	85 db                	test   %ebx,%ebx
  800332:	7f 37                	jg     80036b <printnum+0x7b>
  800334:	e9 ea 00 00 00       	jmp    800423 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800339:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80033c:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	56                   	push   %esi
  800345:	83 ec 04             	sub    $0x4,%esp
  800348:	ff 75 dc             	pushl  -0x24(%ebp)
  80034b:	ff 75 d8             	pushl  -0x28(%ebp)
  80034e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800351:	ff 75 e0             	pushl  -0x20(%ebp)
  800354:	e8 d7 0c 00 00       	call   801030 <__umoddi3>
  800359:	83 c4 14             	add    $0x14,%esp
  80035c:	0f be 80 e3 11 80 00 	movsbl 0x8011e3(%eax),%eax
  800363:	50                   	push   %eax
  800364:	ff d7                	call   *%edi
  800366:	83 c4 10             	add    $0x10,%esp
  800369:	eb 16                	jmp    800381 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80036b:	83 ec 08             	sub    $0x8,%esp
  80036e:	56                   	push   %esi
  80036f:	ff 75 18             	pushl  0x18(%ebp)
  800372:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	83 eb 01             	sub    $0x1,%ebx
  80037a:	75 ef                	jne    80036b <printnum+0x7b>
  80037c:	e9 a2 00 00 00       	jmp    800423 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800381:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800387:	0f 85 76 01 00 00    	jne    800503 <printnum+0x213>
		while(num_of_space-- > 0)
  80038d:	a1 04 20 80 00       	mov    0x802004,%eax
  800392:	8d 50 ff             	lea    -0x1(%eax),%edx
  800395:	89 15 04 20 80 00    	mov    %edx,0x802004
  80039b:	85 c0                	test   %eax,%eax
  80039d:	7e 1d                	jle    8003bc <printnum+0xcc>
			putch(' ', putdat);
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	56                   	push   %esi
  8003a3:	6a 20                	push   $0x20
  8003a5:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8003a7:	a1 04 20 80 00       	mov    0x802004,%eax
  8003ac:	8d 50 ff             	lea    -0x1(%eax),%edx
  8003af:	89 15 04 20 80 00    	mov    %edx,0x802004
  8003b5:	83 c4 10             	add    $0x10,%esp
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	7f e3                	jg     80039f <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8003bc:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8003c3:	00 00 00 
		judge_time_for_space = 0;
  8003c6:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8003cd:	00 00 00 
	}
}
  8003d0:	e9 2e 01 00 00       	jmp    800503 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e9:	83 fa 00             	cmp    $0x0,%edx
  8003ec:	0f 87 ba 00 00 00    	ja     8004ac <printnum+0x1bc>
  8003f2:	3b 45 10             	cmp    0x10(%ebp),%eax
  8003f5:	0f 83 b1 00 00 00    	jae    8004ac <printnum+0x1bc>
  8003fb:	e9 2d ff ff ff       	jmp    80032d <printnum+0x3d>
  800400:	8b 45 10             	mov    0x10(%ebp),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80040e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800411:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800414:	83 fa 00             	cmp    $0x0,%edx
  800417:	77 37                	ja     800450 <printnum+0x160>
  800419:	3b 45 10             	cmp    0x10(%ebp),%eax
  80041c:	73 32                	jae    800450 <printnum+0x160>
  80041e:	e9 16 ff ff ff       	jmp    800339 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	56                   	push   %esi
  800427:	83 ec 04             	sub    $0x4,%esp
  80042a:	ff 75 dc             	pushl  -0x24(%ebp)
  80042d:	ff 75 d8             	pushl  -0x28(%ebp)
  800430:	ff 75 e4             	pushl  -0x1c(%ebp)
  800433:	ff 75 e0             	pushl  -0x20(%ebp)
  800436:	e8 f5 0b 00 00       	call   801030 <__umoddi3>
  80043b:	83 c4 14             	add    $0x14,%esp
  80043e:	0f be 80 e3 11 80 00 	movsbl 0x8011e3(%eax),%eax
  800445:	50                   	push   %eax
  800446:	ff d7                	call   *%edi
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	e9 b3 00 00 00       	jmp    800503 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800450:	83 ec 0c             	sub    $0xc,%esp
  800453:	ff 75 18             	pushl  0x18(%ebp)
  800456:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800459:	50                   	push   %eax
  80045a:	ff 75 10             	pushl  0x10(%ebp)
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 dc             	pushl  -0x24(%ebp)
  800463:	ff 75 d8             	pushl  -0x28(%ebp)
  800466:	ff 75 e4             	pushl  -0x1c(%ebp)
  800469:	ff 75 e0             	pushl  -0x20(%ebp)
  80046c:	e8 8f 0a 00 00       	call   800f00 <__udivdi3>
  800471:	83 c4 18             	add    $0x18,%esp
  800474:	52                   	push   %edx
  800475:	50                   	push   %eax
  800476:	89 f2                	mov    %esi,%edx
  800478:	89 f8                	mov    %edi,%eax
  80047a:	e8 71 fe ff ff       	call   8002f0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047f:	83 c4 18             	add    $0x18,%esp
  800482:	56                   	push   %esi
  800483:	83 ec 04             	sub    $0x4,%esp
  800486:	ff 75 dc             	pushl  -0x24(%ebp)
  800489:	ff 75 d8             	pushl  -0x28(%ebp)
  80048c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048f:	ff 75 e0             	pushl  -0x20(%ebp)
  800492:	e8 99 0b 00 00       	call   801030 <__umoddi3>
  800497:	83 c4 14             	add    $0x14,%esp
  80049a:	0f be 80 e3 11 80 00 	movsbl 0x8011e3(%eax),%eax
  8004a1:	50                   	push   %eax
  8004a2:	ff d7                	call   *%edi
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	e9 d5 fe ff ff       	jmp    800381 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004ac:	83 ec 0c             	sub    $0xc,%esp
  8004af:	ff 75 18             	pushl  0x18(%ebp)
  8004b2:	83 eb 01             	sub    $0x1,%ebx
  8004b5:	53                   	push   %ebx
  8004b6:	ff 75 10             	pushl  0x10(%ebp)
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c8:	e8 33 0a 00 00       	call   800f00 <__udivdi3>
  8004cd:	83 c4 18             	add    $0x18,%esp
  8004d0:	52                   	push   %edx
  8004d1:	50                   	push   %eax
  8004d2:	89 f2                	mov    %esi,%edx
  8004d4:	89 f8                	mov    %edi,%eax
  8004d6:	e8 15 fe ff ff       	call   8002f0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004db:	83 c4 18             	add    $0x18,%esp
  8004de:	56                   	push   %esi
  8004df:	83 ec 04             	sub    $0x4,%esp
  8004e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ee:	e8 3d 0b 00 00       	call   801030 <__umoddi3>
  8004f3:	83 c4 14             	add    $0x14,%esp
  8004f6:	0f be 80 e3 11 80 00 	movsbl 0x8011e3(%eax),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff d7                	call   *%edi
  800500:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800503:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800506:	5b                   	pop    %ebx
  800507:	5e                   	pop    %esi
  800508:	5f                   	pop    %edi
  800509:	5d                   	pop    %ebp
  80050a:	c3                   	ret    

0080050b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80050e:	83 fa 01             	cmp    $0x1,%edx
  800511:	7e 0e                	jle    800521 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800513:	8b 10                	mov    (%eax),%edx
  800515:	8d 4a 08             	lea    0x8(%edx),%ecx
  800518:	89 08                	mov    %ecx,(%eax)
  80051a:	8b 02                	mov    (%edx),%eax
  80051c:	8b 52 04             	mov    0x4(%edx),%edx
  80051f:	eb 22                	jmp    800543 <getuint+0x38>
	else if (lflag)
  800521:	85 d2                	test   %edx,%edx
  800523:	74 10                	je     800535 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800525:	8b 10                	mov    (%eax),%edx
  800527:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052a:	89 08                	mov    %ecx,(%eax)
  80052c:	8b 02                	mov    (%edx),%eax
  80052e:	ba 00 00 00 00       	mov    $0x0,%edx
  800533:	eb 0e                	jmp    800543 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800535:	8b 10                	mov    (%eax),%edx
  800537:	8d 4a 04             	lea    0x4(%edx),%ecx
  80053a:	89 08                	mov    %ecx,(%eax)
  80053c:	8b 02                	mov    (%edx),%eax
  80053e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800543:	5d                   	pop    %ebp
  800544:	c3                   	ret    

00800545 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80054f:	8b 10                	mov    (%eax),%edx
  800551:	3b 50 04             	cmp    0x4(%eax),%edx
  800554:	73 0a                	jae    800560 <sprintputch+0x1b>
		*b->buf++ = ch;
  800556:	8d 4a 01             	lea    0x1(%edx),%ecx
  800559:	89 08                	mov    %ecx,(%eax)
  80055b:	8b 45 08             	mov    0x8(%ebp),%eax
  80055e:	88 02                	mov    %al,(%edx)
}
  800560:	5d                   	pop    %ebp
  800561:	c3                   	ret    

00800562 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800568:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056b:	50                   	push   %eax
  80056c:	ff 75 10             	pushl  0x10(%ebp)
  80056f:	ff 75 0c             	pushl  0xc(%ebp)
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 05 00 00 00       	call   80057f <vprintfmt>
	va_end(ap);
}
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	c9                   	leave  
  80057e:	c3                   	ret    

0080057f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	57                   	push   %edi
  800583:	56                   	push   %esi
  800584:	53                   	push   %ebx
  800585:	83 ec 2c             	sub    $0x2c,%esp
  800588:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058e:	eb 03                	jmp    800593 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800590:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800593:	8b 45 10             	mov    0x10(%ebp),%eax
  800596:	8d 70 01             	lea    0x1(%eax),%esi
  800599:	0f b6 00             	movzbl (%eax),%eax
  80059c:	83 f8 25             	cmp    $0x25,%eax
  80059f:	74 27                	je     8005c8 <vprintfmt+0x49>
			if (ch == '\0')
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	75 0d                	jne    8005b2 <vprintfmt+0x33>
  8005a5:	e9 9d 04 00 00       	jmp    800a47 <vprintfmt+0x4c8>
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	0f 84 95 04 00 00    	je     800a47 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	50                   	push   %eax
  8005b7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b9:	83 c6 01             	add    $0x1,%esi
  8005bc:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	83 f8 25             	cmp    $0x25,%eax
  8005c6:	75 e2                	jne    8005aa <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cd:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8005d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005df:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005e6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8005ed:	eb 08                	jmp    8005f7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8005f2:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8d 46 01             	lea    0x1(%esi),%eax
  8005fa:	89 45 10             	mov    %eax,0x10(%ebp)
  8005fd:	0f b6 06             	movzbl (%esi),%eax
  800600:	0f b6 d0             	movzbl %al,%edx
  800603:	83 e8 23             	sub    $0x23,%eax
  800606:	3c 55                	cmp    $0x55,%al
  800608:	0f 87 fa 03 00 00    	ja     800a08 <vprintfmt+0x489>
  80060e:	0f b6 c0             	movzbl %al,%eax
  800611:	ff 24 85 ec 12 80 00 	jmp    *0x8012ec(,%eax,4)
  800618:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80061b:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80061f:	eb d6                	jmp    8005f7 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800621:	8d 42 d0             	lea    -0x30(%edx),%eax
  800624:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800627:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80062b:	8d 50 d0             	lea    -0x30(%eax),%edx
  80062e:	83 fa 09             	cmp    $0x9,%edx
  800631:	77 6b                	ja     80069e <vprintfmt+0x11f>
  800633:	8b 75 10             	mov    0x10(%ebp),%esi
  800636:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800639:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80063c:	eb 09                	jmp    800647 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800641:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800645:	eb b0                	jmp    8005f7 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800647:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80064a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80064d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800651:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800654:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800657:	83 f9 09             	cmp    $0x9,%ecx
  80065a:	76 eb                	jbe    800647 <vprintfmt+0xc8>
  80065c:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80065f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800662:	eb 3d                	jmp    8006a1 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800675:	eb 2a                	jmp    8006a1 <vprintfmt+0x122>
  800677:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80067a:	85 c0                	test   %eax,%eax
  80067c:	ba 00 00 00 00       	mov    $0x0,%edx
  800681:	0f 49 d0             	cmovns %eax,%edx
  800684:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 75 10             	mov    0x10(%ebp),%esi
  80068a:	e9 68 ff ff ff       	jmp    8005f7 <vprintfmt+0x78>
  80068f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800692:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800699:	e9 59 ff ff ff       	jmp    8005f7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a5:	0f 89 4c ff ff ff    	jns    8005f7 <vprintfmt+0x78>
				width = precision, precision = -1;
  8006ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006b8:	e9 3a ff ff ff       	jmp    8005f7 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006bd:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c4:	e9 2e ff ff ff       	jmp    8005f7 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 50 04             	lea    0x4(%eax),%edx
  8006cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	ff 30                	pushl  (%eax)
  8006d8:	ff d7                	call   *%edi
			break;
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	e9 b1 fe ff ff       	jmp    800593 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 04             	lea    0x4(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	99                   	cltd   
  8006ee:	31 d0                	xor    %edx,%eax
  8006f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f2:	83 f8 06             	cmp    $0x6,%eax
  8006f5:	7f 0b                	jg     800702 <vprintfmt+0x183>
  8006f7:	8b 14 85 44 14 80 00 	mov    0x801444(,%eax,4),%edx
  8006fe:	85 d2                	test   %edx,%edx
  800700:	75 15                	jne    800717 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800702:	50                   	push   %eax
  800703:	68 fb 11 80 00       	push   $0x8011fb
  800708:	53                   	push   %ebx
  800709:	57                   	push   %edi
  80070a:	e8 53 fe ff ff       	call   800562 <printfmt>
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	e9 7c fe ff ff       	jmp    800593 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800717:	52                   	push   %edx
  800718:	68 04 12 80 00       	push   $0x801204
  80071d:	53                   	push   %ebx
  80071e:	57                   	push   %edi
  80071f:	e8 3e fe ff ff       	call   800562 <printfmt>
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	e9 67 fe ff ff       	jmp    800593 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800737:	85 c0                	test   %eax,%eax
  800739:	b9 f4 11 80 00       	mov    $0x8011f4,%ecx
  80073e:	0f 45 c8             	cmovne %eax,%ecx
  800741:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800744:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800748:	7e 06                	jle    800750 <vprintfmt+0x1d1>
  80074a:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80074e:	75 19                	jne    800769 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800750:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800753:	8d 70 01             	lea    0x1(%eax),%esi
  800756:	0f b6 00             	movzbl (%eax),%eax
  800759:	0f be d0             	movsbl %al,%edx
  80075c:	85 d2                	test   %edx,%edx
  80075e:	0f 85 9f 00 00 00    	jne    800803 <vprintfmt+0x284>
  800764:	e9 8c 00 00 00       	jmp    8007f5 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	ff 75 d0             	pushl  -0x30(%ebp)
  80076f:	ff 75 cc             	pushl  -0x34(%ebp)
  800772:	e8 62 03 00 00       	call   800ad9 <strnlen>
  800777:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80077a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	85 c9                	test   %ecx,%ecx
  800782:	0f 8e a6 02 00 00    	jle    800a2e <vprintfmt+0x4af>
					putch(padc, putdat);
  800788:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80078c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80078f:	89 cb                	mov    %ecx,%ebx
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	ff 75 0c             	pushl  0xc(%ebp)
  800797:	56                   	push   %esi
  800798:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	83 eb 01             	sub    $0x1,%ebx
  8007a0:	75 ef                	jne    800791 <vprintfmt+0x212>
  8007a2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a8:	e9 81 02 00 00       	jmp    800a2e <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007b1:	74 1b                	je     8007ce <vprintfmt+0x24f>
  8007b3:	0f be c0             	movsbl %al,%eax
  8007b6:	83 e8 20             	sub    $0x20,%eax
  8007b9:	83 f8 5e             	cmp    $0x5e,%eax
  8007bc:	76 10                	jbe    8007ce <vprintfmt+0x24f>
					putch('?', putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	6a 3f                	push   $0x3f
  8007c6:	ff 55 08             	call   *0x8(%ebp)
  8007c9:	83 c4 10             	add    $0x10,%esp
  8007cc:	eb 0d                	jmp    8007db <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	ff 75 0c             	pushl  0xc(%ebp)
  8007d4:	52                   	push   %edx
  8007d5:	ff 55 08             	call   *0x8(%ebp)
  8007d8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007db:	83 ef 01             	sub    $0x1,%edi
  8007de:	83 c6 01             	add    $0x1,%esi
  8007e1:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007e5:	0f be d0             	movsbl %al,%edx
  8007e8:	85 d2                	test   %edx,%edx
  8007ea:	75 31                	jne    80081d <vprintfmt+0x29e>
  8007ec:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007fc:	7f 33                	jg     800831 <vprintfmt+0x2b2>
  8007fe:	e9 90 fd ff ff       	jmp    800593 <vprintfmt+0x14>
  800803:	89 7d 08             	mov    %edi,0x8(%ebp)
  800806:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800809:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80080c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80080f:	eb 0c                	jmp    80081d <vprintfmt+0x29e>
  800811:	89 7d 08             	mov    %edi,0x8(%ebp)
  800814:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800817:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80081a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80081d:	85 db                	test   %ebx,%ebx
  80081f:	78 8c                	js     8007ad <vprintfmt+0x22e>
  800821:	83 eb 01             	sub    $0x1,%ebx
  800824:	79 87                	jns    8007ad <vprintfmt+0x22e>
  800826:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800829:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80082f:	eb c4                	jmp    8007f5 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800831:	83 ec 08             	sub    $0x8,%esp
  800834:	53                   	push   %ebx
  800835:	6a 20                	push   $0x20
  800837:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	83 ee 01             	sub    $0x1,%esi
  80083f:	75 f0                	jne    800831 <vprintfmt+0x2b2>
  800841:	e9 4d fd ff ff       	jmp    800593 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800846:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80084a:	7e 16                	jle    800862 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 08             	lea    0x8(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 50 04             	mov    0x4(%eax),%edx
  800858:	8b 00                	mov    (%eax),%eax
  80085a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80085d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800860:	eb 34                	jmp    800896 <vprintfmt+0x317>
	else if (lflag)
  800862:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800866:	74 18                	je     800880 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	8b 30                	mov    (%eax),%esi
  800873:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800876:	89 f0                	mov    %esi,%eax
  800878:	c1 f8 1f             	sar    $0x1f,%eax
  80087b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80087e:	eb 16                	jmp    800896 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8d 50 04             	lea    0x4(%eax),%edx
  800886:	89 55 14             	mov    %edx,0x14(%ebp)
  800889:	8b 30                	mov    (%eax),%esi
  80088b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80088e:	89 f0                	mov    %esi,%eax
  800890:	c1 f8 1f             	sar    $0x1f,%eax
  800893:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800896:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800899:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80089c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8008a2:	85 d2                	test   %edx,%edx
  8008a4:	79 28                	jns    8008ce <vprintfmt+0x34f>
				putch('-', putdat);
  8008a6:	83 ec 08             	sub    $0x8,%esp
  8008a9:	53                   	push   %ebx
  8008aa:	6a 2d                	push   $0x2d
  8008ac:	ff d7                	call   *%edi
				num = -(long long) num;
  8008ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008b4:	f7 d8                	neg    %eax
  8008b6:	83 d2 00             	adc    $0x0,%edx
  8008b9:	f7 da                	neg    %edx
  8008bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008c1:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8008c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c9:	e9 b2 00 00 00       	jmp    800980 <vprintfmt+0x401>
  8008ce:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	0f 84 a5 00 00 00    	je     800980 <vprintfmt+0x401>
				putch('+', putdat);
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	53                   	push   %ebx
  8008df:	6a 2b                	push   $0x2b
  8008e1:	ff d7                	call   *%edi
  8008e3:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8008e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008eb:	e9 90 00 00 00       	jmp    800980 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8008f0:	85 c9                	test   %ecx,%ecx
  8008f2:	74 0b                	je     8008ff <vprintfmt+0x380>
				putch('+', putdat);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	53                   	push   %ebx
  8008f8:	6a 2b                	push   $0x2b
  8008fa:	ff d7                	call   *%edi
  8008fc:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8008ff:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800902:	8d 45 14             	lea    0x14(%ebp),%eax
  800905:	e8 01 fc ff ff       	call   80050b <getuint>
  80090a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80090d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800910:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800915:	eb 69                	jmp    800980 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800917:	83 ec 08             	sub    $0x8,%esp
  80091a:	53                   	push   %ebx
  80091b:	6a 30                	push   $0x30
  80091d:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80091f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800922:	8d 45 14             	lea    0x14(%ebp),%eax
  800925:	e8 e1 fb ff ff       	call   80050b <getuint>
  80092a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800930:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800933:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800938:	eb 46                	jmp    800980 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	53                   	push   %ebx
  80093e:	6a 30                	push   $0x30
  800940:	ff d7                	call   *%edi
			putch('x', putdat);
  800942:	83 c4 08             	add    $0x8,%esp
  800945:	53                   	push   %ebx
  800946:	6a 78                	push   $0x78
  800948:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80094a:	8b 45 14             	mov    0x14(%ebp),%eax
  80094d:	8d 50 04             	lea    0x4(%eax),%edx
  800950:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800953:	8b 00                	mov    (%eax),%eax
  800955:	ba 00 00 00 00       	mov    $0x0,%edx
  80095a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80095d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800960:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800963:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800968:	eb 16                	jmp    800980 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80096a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80096d:	8d 45 14             	lea    0x14(%ebp),%eax
  800970:	e8 96 fb ff ff       	call   80050b <getuint>
  800975:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800978:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80097b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800980:	83 ec 0c             	sub    $0xc,%esp
  800983:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800987:	56                   	push   %esi
  800988:	ff 75 e4             	pushl  -0x1c(%ebp)
  80098b:	50                   	push   %eax
  80098c:	ff 75 dc             	pushl  -0x24(%ebp)
  80098f:	ff 75 d8             	pushl  -0x28(%ebp)
  800992:	89 da                	mov    %ebx,%edx
  800994:	89 f8                	mov    %edi,%eax
  800996:	e8 55 f9 ff ff       	call   8002f0 <printnum>
			break;
  80099b:	83 c4 20             	add    $0x20,%esp
  80099e:	e9 f0 fb ff ff       	jmp    800593 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	8d 50 04             	lea    0x4(%eax),%edx
  8009a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ac:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8009ae:	85 f6                	test   %esi,%esi
  8009b0:	75 1a                	jne    8009cc <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8009b2:	83 ec 08             	sub    $0x8,%esp
  8009b5:	68 70 12 80 00       	push   $0x801270
  8009ba:	68 04 12 80 00       	push   $0x801204
  8009bf:	e8 18 f9 ff ff       	call   8002dc <cprintf>
  8009c4:	83 c4 10             	add    $0x10,%esp
  8009c7:	e9 c7 fb ff ff       	jmp    800593 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8009cc:	0f b6 03             	movzbl (%ebx),%eax
  8009cf:	84 c0                	test   %al,%al
  8009d1:	79 1f                	jns    8009f2 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	68 a8 12 80 00       	push   $0x8012a8
  8009db:	68 04 12 80 00       	push   $0x801204
  8009e0:	e8 f7 f8 ff ff       	call   8002dc <cprintf>
						*tmp = *(char *)putdat;
  8009e5:	0f b6 03             	movzbl (%ebx),%eax
  8009e8:	88 06                	mov    %al,(%esi)
  8009ea:	83 c4 10             	add    $0x10,%esp
  8009ed:	e9 a1 fb ff ff       	jmp    800593 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8009f2:	88 06                	mov    %al,(%esi)
  8009f4:	e9 9a fb ff ff       	jmp    800593 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009f9:	83 ec 08             	sub    $0x8,%esp
  8009fc:	53                   	push   %ebx
  8009fd:	52                   	push   %edx
  8009fe:	ff d7                	call   *%edi
			break;
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	e9 8b fb ff ff       	jmp    800593 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	53                   	push   %ebx
  800a0c:	6a 25                	push   $0x25
  800a0e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a17:	0f 84 73 fb ff ff    	je     800590 <vprintfmt+0x11>
  800a1d:	83 ee 01             	sub    $0x1,%esi
  800a20:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a24:	75 f7                	jne    800a1d <vprintfmt+0x49e>
  800a26:	89 75 10             	mov    %esi,0x10(%ebp)
  800a29:	e9 65 fb ff ff       	jmp    800593 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a31:	8d 70 01             	lea    0x1(%eax),%esi
  800a34:	0f b6 00             	movzbl (%eax),%eax
  800a37:	0f be d0             	movsbl %al,%edx
  800a3a:	85 d2                	test   %edx,%edx
  800a3c:	0f 85 cf fd ff ff    	jne    800811 <vprintfmt+0x292>
  800a42:	e9 4c fb ff ff       	jmp    800593 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	83 ec 18             	sub    $0x18,%esp
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a5e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a62:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	74 26                	je     800a96 <vsnprintf+0x47>
  800a70:	85 d2                	test   %edx,%edx
  800a72:	7e 22                	jle    800a96 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a74:	ff 75 14             	pushl  0x14(%ebp)
  800a77:	ff 75 10             	pushl  0x10(%ebp)
  800a7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a7d:	50                   	push   %eax
  800a7e:	68 45 05 80 00       	push   $0x800545
  800a83:	e8 f7 fa ff ff       	call   80057f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a8b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	eb 05                	jmp    800a9b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aa3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa6:	50                   	push   %eax
  800aa7:	ff 75 10             	pushl  0x10(%ebp)
  800aaa:	ff 75 0c             	pushl  0xc(%ebp)
  800aad:	ff 75 08             	pushl  0x8(%ebp)
  800ab0:	e8 9a ff ff ff       	call   800a4f <vsnprintf>
	va_end(ap);

	return rc;
}
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800abd:	80 3a 00             	cmpb   $0x0,(%edx)
  800ac0:	74 10                	je     800ad2 <strlen+0x1b>
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ac7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ace:	75 f7                	jne    800ac7 <strlen+0x10>
  800ad0:	eb 05                	jmp    800ad7 <strlen+0x20>
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	53                   	push   %ebx
  800add:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae3:	85 c9                	test   %ecx,%ecx
  800ae5:	74 1c                	je     800b03 <strnlen+0x2a>
  800ae7:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aea:	74 1e                	je     800b0a <strnlen+0x31>
  800aec:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800af1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af3:	39 ca                	cmp    %ecx,%edx
  800af5:	74 18                	je     800b0f <strnlen+0x36>
  800af7:	83 c2 01             	add    $0x1,%edx
  800afa:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800aff:	75 f0                	jne    800af1 <strnlen+0x18>
  800b01:	eb 0c                	jmp    800b0f <strnlen+0x36>
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	eb 05                	jmp    800b0f <strnlen+0x36>
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	53                   	push   %ebx
  800b16:	8b 45 08             	mov    0x8(%ebp),%eax
  800b19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b1c:	89 c2                	mov    %eax,%edx
  800b1e:	83 c2 01             	add    $0x1,%edx
  800b21:	83 c1 01             	add    $0x1,%ecx
  800b24:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b28:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b2b:	84 db                	test   %bl,%bl
  800b2d:	75 ef                	jne    800b1e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	53                   	push   %ebx
  800b36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b39:	53                   	push   %ebx
  800b3a:	e8 78 ff ff ff       	call   800ab7 <strlen>
  800b3f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b42:	ff 75 0c             	pushl  0xc(%ebp)
  800b45:	01 d8                	add    %ebx,%eax
  800b47:	50                   	push   %eax
  800b48:	e8 c5 ff ff ff       	call   800b12 <strcpy>
	return dst;
}
  800b4d:	89 d8                	mov    %ebx,%eax
  800b4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b52:	c9                   	leave  
  800b53:	c3                   	ret    

00800b54 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b62:	85 db                	test   %ebx,%ebx
  800b64:	74 17                	je     800b7d <strncpy+0x29>
  800b66:	01 f3                	add    %esi,%ebx
  800b68:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b6a:	83 c1 01             	add    $0x1,%ecx
  800b6d:	0f b6 02             	movzbl (%edx),%eax
  800b70:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b73:	80 3a 01             	cmpb   $0x1,(%edx)
  800b76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b79:	39 cb                	cmp    %ecx,%ebx
  800b7b:	75 ed                	jne    800b6a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8e:	8b 55 10             	mov    0x10(%ebp),%edx
  800b91:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b93:	85 d2                	test   %edx,%edx
  800b95:	74 35                	je     800bcc <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	83 e8 01             	sub    $0x1,%eax
  800b9c:	74 25                	je     800bc3 <strlcpy+0x40>
  800b9e:	0f b6 0b             	movzbl (%ebx),%ecx
  800ba1:	84 c9                	test   %cl,%cl
  800ba3:	74 22                	je     800bc7 <strlcpy+0x44>
  800ba5:	8d 53 01             	lea    0x1(%ebx),%edx
  800ba8:	01 c3                	add    %eax,%ebx
  800baa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800bac:	83 c0 01             	add    $0x1,%eax
  800baf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb2:	39 da                	cmp    %ebx,%edx
  800bb4:	74 13                	je     800bc9 <strlcpy+0x46>
  800bb6:	83 c2 01             	add    $0x1,%edx
  800bb9:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800bbd:	84 c9                	test   %cl,%cl
  800bbf:	75 eb                	jne    800bac <strlcpy+0x29>
  800bc1:	eb 06                	jmp    800bc9 <strlcpy+0x46>
  800bc3:	89 f0                	mov    %esi,%eax
  800bc5:	eb 02                	jmp    800bc9 <strlcpy+0x46>
  800bc7:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bc9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bcc:	29 f0                	sub    %esi,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bdb:	0f b6 01             	movzbl (%ecx),%eax
  800bde:	84 c0                	test   %al,%al
  800be0:	74 15                	je     800bf7 <strcmp+0x25>
  800be2:	3a 02                	cmp    (%edx),%al
  800be4:	75 11                	jne    800bf7 <strcmp+0x25>
		p++, q++;
  800be6:	83 c1 01             	add    $0x1,%ecx
  800be9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bec:	0f b6 01             	movzbl (%ecx),%eax
  800bef:	84 c0                	test   %al,%al
  800bf1:	74 04                	je     800bf7 <strcmp+0x25>
  800bf3:	3a 02                	cmp    (%edx),%al
  800bf5:	74 ef                	je     800be6 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf7:	0f b6 c0             	movzbl %al,%eax
  800bfa:	0f b6 12             	movzbl (%edx),%edx
  800bfd:	29 d0                	sub    %edx,%eax
}
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0c:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c0f:	85 f6                	test   %esi,%esi
  800c11:	74 29                	je     800c3c <strncmp+0x3b>
  800c13:	0f b6 03             	movzbl (%ebx),%eax
  800c16:	84 c0                	test   %al,%al
  800c18:	74 30                	je     800c4a <strncmp+0x49>
  800c1a:	3a 02                	cmp    (%edx),%al
  800c1c:	75 2c                	jne    800c4a <strncmp+0x49>
  800c1e:	8d 43 01             	lea    0x1(%ebx),%eax
  800c21:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c23:	89 c3                	mov    %eax,%ebx
  800c25:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c28:	39 c6                	cmp    %eax,%esi
  800c2a:	74 17                	je     800c43 <strncmp+0x42>
  800c2c:	0f b6 08             	movzbl (%eax),%ecx
  800c2f:	84 c9                	test   %cl,%cl
  800c31:	74 17                	je     800c4a <strncmp+0x49>
  800c33:	83 c0 01             	add    $0x1,%eax
  800c36:	3a 0a                	cmp    (%edx),%cl
  800c38:	74 e9                	je     800c23 <strncmp+0x22>
  800c3a:	eb 0e                	jmp    800c4a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c41:	eb 0f                	jmp    800c52 <strncmp+0x51>
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	eb 08                	jmp    800c52 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c4a:	0f b6 03             	movzbl (%ebx),%eax
  800c4d:	0f b6 12             	movzbl (%edx),%edx
  800c50:	29 d0                	sub    %edx,%eax
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	53                   	push   %ebx
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c60:	0f b6 10             	movzbl (%eax),%edx
  800c63:	84 d2                	test   %dl,%dl
  800c65:	74 1d                	je     800c84 <strchr+0x2e>
  800c67:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800c69:	38 d3                	cmp    %dl,%bl
  800c6b:	75 06                	jne    800c73 <strchr+0x1d>
  800c6d:	eb 1a                	jmp    800c89 <strchr+0x33>
  800c6f:	38 ca                	cmp    %cl,%dl
  800c71:	74 16                	je     800c89 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c73:	83 c0 01             	add    $0x1,%eax
  800c76:	0f b6 10             	movzbl (%eax),%edx
  800c79:	84 d2                	test   %dl,%dl
  800c7b:	75 f2                	jne    800c6f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c82:	eb 05                	jmp    800c89 <strchr+0x33>
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	53                   	push   %ebx
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c96:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c99:	38 d3                	cmp    %dl,%bl
  800c9b:	74 14                	je     800cb1 <strfind+0x25>
  800c9d:	89 d1                	mov    %edx,%ecx
  800c9f:	84 db                	test   %bl,%bl
  800ca1:	74 0e                	je     800cb1 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ca3:	83 c0 01             	add    $0x1,%eax
  800ca6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ca9:	38 ca                	cmp    %cl,%dl
  800cab:	74 04                	je     800cb1 <strfind+0x25>
  800cad:	84 d2                	test   %dl,%dl
  800caf:	75 f2                	jne    800ca3 <strfind+0x17>
			break;
	return (char *) s;
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cc0:	85 c9                	test   %ecx,%ecx
  800cc2:	74 36                	je     800cfa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cca:	75 28                	jne    800cf4 <memset+0x40>
  800ccc:	f6 c1 03             	test   $0x3,%cl
  800ccf:	75 23                	jne    800cf4 <memset+0x40>
		c &= 0xFF;
  800cd1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cd5:	89 d3                	mov    %edx,%ebx
  800cd7:	c1 e3 08             	shl    $0x8,%ebx
  800cda:	89 d6                	mov    %edx,%esi
  800cdc:	c1 e6 18             	shl    $0x18,%esi
  800cdf:	89 d0                	mov    %edx,%eax
  800ce1:	c1 e0 10             	shl    $0x10,%eax
  800ce4:	09 f0                	or     %esi,%eax
  800ce6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ce8:	89 d8                	mov    %ebx,%eax
  800cea:	09 d0                	or     %edx,%eax
  800cec:	c1 e9 02             	shr    $0x2,%ecx
  800cef:	fc                   	cld    
  800cf0:	f3 ab                	rep stos %eax,%es:(%edi)
  800cf2:	eb 06                	jmp    800cfa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf7:	fc                   	cld    
  800cf8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cfa:	89 f8                	mov    %edi,%eax
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	8b 45 08             	mov    0x8(%ebp),%eax
  800d09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d0f:	39 c6                	cmp    %eax,%esi
  800d11:	73 35                	jae    800d48 <memmove+0x47>
  800d13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d16:	39 d0                	cmp    %edx,%eax
  800d18:	73 2e                	jae    800d48 <memmove+0x47>
		s += n;
		d += n;
  800d1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1d:	89 d6                	mov    %edx,%esi
  800d1f:	09 fe                	or     %edi,%esi
  800d21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d27:	75 13                	jne    800d3c <memmove+0x3b>
  800d29:	f6 c1 03             	test   $0x3,%cl
  800d2c:	75 0e                	jne    800d3c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d2e:	83 ef 04             	sub    $0x4,%edi
  800d31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d34:	c1 e9 02             	shr    $0x2,%ecx
  800d37:	fd                   	std    
  800d38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d3a:	eb 09                	jmp    800d45 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d3c:	83 ef 01             	sub    $0x1,%edi
  800d3f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d42:	fd                   	std    
  800d43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d45:	fc                   	cld    
  800d46:	eb 1d                	jmp    800d65 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d48:	89 f2                	mov    %esi,%edx
  800d4a:	09 c2                	or     %eax,%edx
  800d4c:	f6 c2 03             	test   $0x3,%dl
  800d4f:	75 0f                	jne    800d60 <memmove+0x5f>
  800d51:	f6 c1 03             	test   $0x3,%cl
  800d54:	75 0a                	jne    800d60 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d56:	c1 e9 02             	shr    $0x2,%ecx
  800d59:	89 c7                	mov    %eax,%edi
  800d5b:	fc                   	cld    
  800d5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d5e:	eb 05                	jmp    800d65 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d60:	89 c7                	mov    %eax,%edi
  800d62:	fc                   	cld    
  800d63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d6c:	ff 75 10             	pushl  0x10(%ebp)
  800d6f:	ff 75 0c             	pushl  0xc(%ebp)
  800d72:	ff 75 08             	pushl  0x8(%ebp)
  800d75:	e8 87 ff ff ff       	call   800d01 <memmove>
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d88:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	74 39                	je     800dc8 <memcmp+0x4c>
  800d8f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800d92:	0f b6 13             	movzbl (%ebx),%edx
  800d95:	0f b6 0e             	movzbl (%esi),%ecx
  800d98:	38 ca                	cmp    %cl,%dl
  800d9a:	75 17                	jne    800db3 <memcmp+0x37>
  800d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800da1:	eb 1a                	jmp    800dbd <memcmp+0x41>
  800da3:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800da8:	83 c0 01             	add    $0x1,%eax
  800dab:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800daf:	38 ca                	cmp    %cl,%dl
  800db1:	74 0a                	je     800dbd <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800db3:	0f b6 c2             	movzbl %dl,%eax
  800db6:	0f b6 c9             	movzbl %cl,%ecx
  800db9:	29 c8                	sub    %ecx,%eax
  800dbb:	eb 10                	jmp    800dcd <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbd:	39 f8                	cmp    %edi,%eax
  800dbf:	75 e2                	jne    800da3 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	eb 05                	jmp    800dcd <memcmp+0x51>
  800dc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	53                   	push   %ebx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800dd9:	89 d0                	mov    %edx,%eax
  800ddb:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800dde:	39 c2                	cmp    %eax,%edx
  800de0:	73 1d                	jae    800dff <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800de6:	0f b6 0a             	movzbl (%edx),%ecx
  800de9:	39 d9                	cmp    %ebx,%ecx
  800deb:	75 09                	jne    800df6 <memfind+0x24>
  800ded:	eb 14                	jmp    800e03 <memfind+0x31>
  800def:	0f b6 0a             	movzbl (%edx),%ecx
  800df2:	39 d9                	cmp    %ebx,%ecx
  800df4:	74 11                	je     800e07 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800df6:	83 c2 01             	add    $0x1,%edx
  800df9:	39 d0                	cmp    %edx,%eax
  800dfb:	75 f2                	jne    800def <memfind+0x1d>
  800dfd:	eb 0a                	jmp    800e09 <memfind+0x37>
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	eb 06                	jmp    800e09 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e03:	89 d0                	mov    %edx,%eax
  800e05:	eb 02                	jmp    800e09 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e07:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e18:	0f b6 01             	movzbl (%ecx),%eax
  800e1b:	3c 20                	cmp    $0x20,%al
  800e1d:	74 04                	je     800e23 <strtol+0x17>
  800e1f:	3c 09                	cmp    $0x9,%al
  800e21:	75 0e                	jne    800e31 <strtol+0x25>
		s++;
  800e23:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e26:	0f b6 01             	movzbl (%ecx),%eax
  800e29:	3c 20                	cmp    $0x20,%al
  800e2b:	74 f6                	je     800e23 <strtol+0x17>
  800e2d:	3c 09                	cmp    $0x9,%al
  800e2f:	74 f2                	je     800e23 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e31:	3c 2b                	cmp    $0x2b,%al
  800e33:	75 0a                	jne    800e3f <strtol+0x33>
		s++;
  800e35:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e38:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3d:	eb 11                	jmp    800e50 <strtol+0x44>
  800e3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e44:	3c 2d                	cmp    $0x2d,%al
  800e46:	75 08                	jne    800e50 <strtol+0x44>
		s++, neg = 1;
  800e48:	83 c1 01             	add    $0x1,%ecx
  800e4b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e50:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e56:	75 15                	jne    800e6d <strtol+0x61>
  800e58:	80 39 30             	cmpb   $0x30,(%ecx)
  800e5b:	75 10                	jne    800e6d <strtol+0x61>
  800e5d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e61:	75 7c                	jne    800edf <strtol+0xd3>
		s += 2, base = 16;
  800e63:	83 c1 02             	add    $0x2,%ecx
  800e66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e6b:	eb 16                	jmp    800e83 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e6d:	85 db                	test   %ebx,%ebx
  800e6f:	75 12                	jne    800e83 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e71:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e76:	80 39 30             	cmpb   $0x30,(%ecx)
  800e79:	75 08                	jne    800e83 <strtol+0x77>
		s++, base = 8;
  800e7b:	83 c1 01             	add    $0x1,%ecx
  800e7e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
  800e88:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e8b:	0f b6 11             	movzbl (%ecx),%edx
  800e8e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e91:	89 f3                	mov    %esi,%ebx
  800e93:	80 fb 09             	cmp    $0x9,%bl
  800e96:	77 08                	ja     800ea0 <strtol+0x94>
			dig = *s - '0';
  800e98:	0f be d2             	movsbl %dl,%edx
  800e9b:	83 ea 30             	sub    $0x30,%edx
  800e9e:	eb 22                	jmp    800ec2 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800ea0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ea3:	89 f3                	mov    %esi,%ebx
  800ea5:	80 fb 19             	cmp    $0x19,%bl
  800ea8:	77 08                	ja     800eb2 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800eaa:	0f be d2             	movsbl %dl,%edx
  800ead:	83 ea 57             	sub    $0x57,%edx
  800eb0:	eb 10                	jmp    800ec2 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800eb2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eb5:	89 f3                	mov    %esi,%ebx
  800eb7:	80 fb 19             	cmp    $0x19,%bl
  800eba:	77 16                	ja     800ed2 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800ebc:	0f be d2             	movsbl %dl,%edx
  800ebf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ec2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ec5:	7d 0b                	jge    800ed2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ec7:	83 c1 01             	add    $0x1,%ecx
  800eca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ece:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ed0:	eb b9                	jmp    800e8b <strtol+0x7f>

	if (endptr)
  800ed2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed6:	74 0d                	je     800ee5 <strtol+0xd9>
		*endptr = (char *) s;
  800ed8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800edb:	89 0e                	mov    %ecx,(%esi)
  800edd:	eb 06                	jmp    800ee5 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800edf:	85 db                	test   %ebx,%ebx
  800ee1:	74 98                	je     800e7b <strtol+0x6f>
  800ee3:	eb 9e                	jmp    800e83 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ee5:	89 c2                	mov    %eax,%edx
  800ee7:	f7 da                	neg    %edx
  800ee9:	85 ff                	test   %edi,%edi
  800eeb:	0f 45 c2             	cmovne %edx,%eax
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    
  800ef3:	66 90                	xchg   %ax,%ax
  800ef5:	66 90                	xchg   %ax,%ax
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
