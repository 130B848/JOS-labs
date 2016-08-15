
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800052:	e8 f9 00 00 00       	call   800150 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 64             	imul   $0x64,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 66 00 00 00       	call   800100 <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	51                   	push   %ecx
  8000b4:	52                   	push   %edx
  8000b5:	53                   	push   %ebx
  8000b6:	54                   	push   %esp
  8000b7:	55                   	push   %ebp
  8000b8:	56                   	push   %esi
  8000b9:	57                   	push   %edi
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	8d 35 c4 00 80 00    	lea    0x8000c4,%esi
  8000c2:	0f 34                	sysenter 

008000c4 <label_21>:
  8000c4:	5f                   	pop    %edi
  8000c5:	5e                   	pop    %esi
  8000c6:	5d                   	pop    %ebp
  8000c7:	5c                   	pop    %esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5a                   	pop    %edx
  8000ca:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cb:	5b                   	pop    %ebx
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 ca                	mov    %ecx,%edx
  8000e0:	89 cb                	mov    %ecx,%ebx
  8000e2:	89 cf                	mov    %ecx,%edi
  8000e4:	51                   	push   %ecx
  8000e5:	52                   	push   %edx
  8000e6:	53                   	push   %ebx
  8000e7:	54                   	push   %esp
  8000e8:	55                   	push   %ebp
  8000e9:	56                   	push   %esi
  8000ea:	57                   	push   %edi
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	8d 35 f5 00 80 00    	lea    0x8000f5,%esi
  8000f3:	0f 34                	sysenter 

008000f5 <label_55>:
  8000f5:	5f                   	pop    %edi
  8000f6:	5e                   	pop    %esi
  8000f7:	5d                   	pop    %ebp
  8000f8:	5c                   	pop    %esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5a                   	pop    %edx
  8000fb:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	57                   	push   %edi
  800104:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800105:	bb 00 00 00 00       	mov    $0x0,%ebx
  80010a:	b8 03 00 00 00       	mov    $0x3,%eax
  80010f:	8b 55 08             	mov    0x8(%ebp),%edx
  800112:	89 d9                	mov    %ebx,%ecx
  800114:	89 df                	mov    %ebx,%edi
  800116:	51                   	push   %ecx
  800117:	52                   	push   %edx
  800118:	53                   	push   %ebx
  800119:	54                   	push   %esp
  80011a:	55                   	push   %ebp
  80011b:	56                   	push   %esi
  80011c:	57                   	push   %edi
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	8d 35 27 01 80 00    	lea    0x800127,%esi
  800125:	0f 34                	sysenter 

00800127 <label_90>:
  800127:	5f                   	pop    %edi
  800128:	5e                   	pop    %esi
  800129:	5d                   	pop    %ebp
  80012a:	5c                   	pop    %esp
  80012b:	5b                   	pop    %ebx
  80012c:	5a                   	pop    %edx
  80012d:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	7e 17                	jle    800149 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	50                   	push   %eax
  800136:	6a 03                	push   $0x3
  800138:	68 7e 11 80 00       	push   $0x80117e
  80013d:	6a 2a                	push   $0x2a
  80013f:	68 9b 11 80 00       	push   $0x80119b
  800144:	e8 9d 00 00 00       	call   8001e6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800149:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014c:	5b                   	pop    %ebx
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800155:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 ca                	mov    %ecx,%edx
  800161:	89 cb                	mov    %ecx,%ebx
  800163:	89 cf                	mov    %ecx,%edi
  800165:	51                   	push   %ecx
  800166:	52                   	push   %edx
  800167:	53                   	push   %ebx
  800168:	54                   	push   %esp
  800169:	55                   	push   %ebp
  80016a:	56                   	push   %esi
  80016b:	57                   	push   %edi
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	8d 35 76 01 80 00    	lea    0x800176,%esi
  800174:	0f 34                	sysenter 

00800176 <label_139>:
  800176:	5f                   	pop    %edi
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	5c                   	pop    %esp
  80017a:	5b                   	pop    %ebx
  80017b:	5a                   	pop    %edx
  80017c:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017d:	5b                   	pop    %ebx
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800186:	bf 00 00 00 00       	mov    $0x0,%edi
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800193:	8b 55 08             	mov    0x8(%ebp),%edx
  800196:	89 fb                	mov    %edi,%ebx
  800198:	51                   	push   %ecx
  800199:	52                   	push   %edx
  80019a:	53                   	push   %ebx
  80019b:	54                   	push   %esp
  80019c:	55                   	push   %ebp
  80019d:	56                   	push   %esi
  80019e:	57                   	push   %edi
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	8d 35 a9 01 80 00    	lea    0x8001a9,%esi
  8001a7:	0f 34                	sysenter 

008001a9 <label_174>:
  8001a9:	5f                   	pop    %edi
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	5c                   	pop    %esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5a                   	pop    %edx
  8001af:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001b0:	5b                   	pop    %ebx
  8001b1:	5f                   	pop    %edi
  8001b2:	5d                   	pop    %ebp
  8001b3:	c3                   	ret    

008001b4 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001be:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c6:	89 cb                	mov    %ecx,%ebx
  8001c8:	89 cf                	mov    %ecx,%edi
  8001ca:	51                   	push   %ecx
  8001cb:	52                   	push   %edx
  8001cc:	53                   	push   %ebx
  8001cd:	54                   	push   %esp
  8001ce:	55                   	push   %ebp
  8001cf:	56                   	push   %esi
  8001d0:	57                   	push   %edi
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	8d 35 db 01 80 00    	lea    0x8001db,%esi
  8001d9:	0f 34                	sysenter 

008001db <label_209>:
  8001db:	5f                   	pop    %edi
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	5c                   	pop    %esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5a                   	pop    %edx
  8001e1:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001e2:	5b                   	pop    %ebx
  8001e3:	5f                   	pop    %edi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001eb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001ee:	a1 10 20 80 00       	mov    0x802010,%eax
  8001f3:	85 c0                	test   %eax,%eax
  8001f5:	74 11                	je     800208 <_panic+0x22>
		cprintf("%s: ", argv0);
  8001f7:	83 ec 08             	sub    $0x8,%esp
  8001fa:	50                   	push   %eax
  8001fb:	68 a9 11 80 00       	push   $0x8011a9
  800200:	e8 d4 00 00 00       	call   8002d9 <cprintf>
  800205:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800208:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80020e:	e8 3d ff ff ff       	call   800150 <sys_getenvid>
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	ff 75 0c             	pushl  0xc(%ebp)
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	56                   	push   %esi
  80021d:	50                   	push   %eax
  80021e:	68 b0 11 80 00       	push   $0x8011b0
  800223:	e8 b1 00 00 00       	call   8002d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800228:	83 c4 18             	add    $0x18,%esp
  80022b:	53                   	push   %ebx
  80022c:	ff 75 10             	pushl  0x10(%ebp)
  80022f:	e8 54 00 00 00       	call   800288 <vcprintf>
	cprintf("\n");
  800234:	c7 04 24 ae 11 80 00 	movl   $0x8011ae,(%esp)
  80023b:	e8 99 00 00 00       	call   8002d9 <cprintf>
  800240:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800243:	cc                   	int3   
  800244:	eb fd                	jmp    800243 <_panic+0x5d>

00800246 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	53                   	push   %ebx
  80024a:	83 ec 04             	sub    $0x4,%esp
  80024d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800250:	8b 13                	mov    (%ebx),%edx
  800252:	8d 42 01             	lea    0x1(%edx),%eax
  800255:	89 03                	mov    %eax,(%ebx)
  800257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80025e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800263:	75 1a                	jne    80027f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	68 ff 00 00 00       	push   $0xff
  80026d:	8d 43 08             	lea    0x8(%ebx),%eax
  800270:	50                   	push   %eax
  800271:	e8 29 fe ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  800276:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80027f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800283:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800291:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800298:	00 00 00 
	b.cnt = 0;
  80029b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a5:	ff 75 0c             	pushl  0xc(%ebp)
  8002a8:	ff 75 08             	pushl  0x8(%ebp)
  8002ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b1:	50                   	push   %eax
  8002b2:	68 46 02 80 00       	push   $0x800246
  8002b7:	e8 c0 02 00 00       	call   80057c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bc:	83 c4 08             	add    $0x8,%esp
  8002bf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002c5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002cb:	50                   	push   %eax
  8002cc:	e8 ce fd ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  8002d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    

008002d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002e2:	50                   	push   %eax
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	e8 9d ff ff ff       	call   800288 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002eb:	c9                   	leave  
  8002ec:	c3                   	ret    

008002ed <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 1c             	sub    $0x1c,%esp
  8002f6:	89 c7                	mov    %eax,%edi
  8002f8:	89 d6                	mov    %edx,%esi
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800300:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800303:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800306:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800309:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80030d:	0f 85 bf 00 00 00    	jne    8003d2 <printnum+0xe5>
  800313:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800319:	0f 8d de 00 00 00    	jge    8003fd <printnum+0x110>
		judge_time_for_space = width;
  80031f:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800325:	e9 d3 00 00 00       	jmp    8003fd <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80032a:	83 eb 01             	sub    $0x1,%ebx
  80032d:	85 db                	test   %ebx,%ebx
  80032f:	7f 37                	jg     800368 <printnum+0x7b>
  800331:	e9 ea 00 00 00       	jmp    800420 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800336:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800339:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033e:	83 ec 08             	sub    $0x8,%esp
  800341:	56                   	push   %esi
  800342:	83 ec 04             	sub    $0x4,%esp
  800345:	ff 75 dc             	pushl  -0x24(%ebp)
  800348:	ff 75 d8             	pushl  -0x28(%ebp)
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	e8 ca 0c 00 00       	call   801020 <__umoddi3>
  800356:	83 c4 14             	add    $0x14,%esp
  800359:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800360:	50                   	push   %eax
  800361:	ff d7                	call   *%edi
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	eb 16                	jmp    80037e <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	56                   	push   %esi
  80036c:	ff 75 18             	pushl  0x18(%ebp)
  80036f:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	83 eb 01             	sub    $0x1,%ebx
  800377:	75 ef                	jne    800368 <printnum+0x7b>
  800379:	e9 a2 00 00 00       	jmp    800420 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  80037e:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800384:	0f 85 76 01 00 00    	jne    800500 <printnum+0x213>
		while(num_of_space-- > 0)
  80038a:	a1 04 20 80 00       	mov    0x802004,%eax
  80038f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800392:	89 15 04 20 80 00    	mov    %edx,0x802004
  800398:	85 c0                	test   %eax,%eax
  80039a:	7e 1d                	jle    8003b9 <printnum+0xcc>
			putch(' ', putdat);
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	56                   	push   %esi
  8003a0:	6a 20                	push   $0x20
  8003a2:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8003a4:	a1 04 20 80 00       	mov    0x802004,%eax
  8003a9:	8d 50 ff             	lea    -0x1(%eax),%edx
  8003ac:	89 15 04 20 80 00    	mov    %edx,0x802004
  8003b2:	83 c4 10             	add    $0x10,%esp
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	7f e3                	jg     80039c <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8003b9:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8003c0:	00 00 00 
		judge_time_for_space = 0;
  8003c3:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8003ca:	00 00 00 
	}
}
  8003cd:	e9 2e 01 00 00       	jmp    800500 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e6:	83 fa 00             	cmp    $0x0,%edx
  8003e9:	0f 87 ba 00 00 00    	ja     8004a9 <printnum+0x1bc>
  8003ef:	3b 45 10             	cmp    0x10(%ebp),%eax
  8003f2:	0f 83 b1 00 00 00    	jae    8004a9 <printnum+0x1bc>
  8003f8:	e9 2d ff ff ff       	jmp    80032a <printnum+0x3d>
  8003fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800400:	ba 00 00 00 00       	mov    $0x0,%edx
  800405:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800408:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80040b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800411:	83 fa 00             	cmp    $0x0,%edx
  800414:	77 37                	ja     80044d <printnum+0x160>
  800416:	3b 45 10             	cmp    0x10(%ebp),%eax
  800419:	73 32                	jae    80044d <printnum+0x160>
  80041b:	e9 16 ff ff ff       	jmp    800336 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	83 ec 04             	sub    $0x4,%esp
  800427:	ff 75 dc             	pushl  -0x24(%ebp)
  80042a:	ff 75 d8             	pushl  -0x28(%ebp)
  80042d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800430:	ff 75 e0             	pushl  -0x20(%ebp)
  800433:	e8 e8 0b 00 00       	call   801020 <__umoddi3>
  800438:	83 c4 14             	add    $0x14,%esp
  80043b:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800442:	50                   	push   %eax
  800443:	ff d7                	call   *%edi
  800445:	83 c4 10             	add    $0x10,%esp
  800448:	e9 b3 00 00 00       	jmp    800500 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044d:	83 ec 0c             	sub    $0xc,%esp
  800450:	ff 75 18             	pushl  0x18(%ebp)
  800453:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800456:	50                   	push   %eax
  800457:	ff 75 10             	pushl  0x10(%ebp)
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	ff 75 dc             	pushl  -0x24(%ebp)
  800460:	ff 75 d8             	pushl  -0x28(%ebp)
  800463:	ff 75 e4             	pushl  -0x1c(%ebp)
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	e8 82 0a 00 00       	call   800ef0 <__udivdi3>
  80046e:	83 c4 18             	add    $0x18,%esp
  800471:	52                   	push   %edx
  800472:	50                   	push   %eax
  800473:	89 f2                	mov    %esi,%edx
  800475:	89 f8                	mov    %edi,%eax
  800477:	e8 71 fe ff ff       	call   8002ed <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047c:	83 c4 18             	add    $0x18,%esp
  80047f:	56                   	push   %esi
  800480:	83 ec 04             	sub    $0x4,%esp
  800483:	ff 75 dc             	pushl  -0x24(%ebp)
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048c:	ff 75 e0             	pushl  -0x20(%ebp)
  80048f:	e8 8c 0b 00 00       	call   801020 <__umoddi3>
  800494:	83 c4 14             	add    $0x14,%esp
  800497:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  80049e:	50                   	push   %eax
  80049f:	ff d7                	call   *%edi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	e9 d5 fe ff ff       	jmp    80037e <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a9:	83 ec 0c             	sub    $0xc,%esp
  8004ac:	ff 75 18             	pushl  0x18(%ebp)
  8004af:	83 eb 01             	sub    $0x1,%ebx
  8004b2:	53                   	push   %ebx
  8004b3:	ff 75 10             	pushl  0x10(%ebp)
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c5:	e8 26 0a 00 00       	call   800ef0 <__udivdi3>
  8004ca:	83 c4 18             	add    $0x18,%esp
  8004cd:	52                   	push   %edx
  8004ce:	50                   	push   %eax
  8004cf:	89 f2                	mov    %esi,%edx
  8004d1:	89 f8                	mov    %edi,%eax
  8004d3:	e8 15 fe ff ff       	call   8002ed <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d8:	83 c4 18             	add    $0x18,%esp
  8004db:	56                   	push   %esi
  8004dc:	83 ec 04             	sub    $0x4,%esp
  8004df:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004eb:	e8 30 0b 00 00       	call   801020 <__umoddi3>
  8004f0:	83 c4 14             	add    $0x14,%esp
  8004f3:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  8004fa:	50                   	push   %eax
  8004fb:	ff d7                	call   *%edi
  8004fd:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800500:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800503:	5b                   	pop    %ebx
  800504:	5e                   	pop    %esi
  800505:	5f                   	pop    %edi
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80050b:	83 fa 01             	cmp    $0x1,%edx
  80050e:	7e 0e                	jle    80051e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800510:	8b 10                	mov    (%eax),%edx
  800512:	8d 4a 08             	lea    0x8(%edx),%ecx
  800515:	89 08                	mov    %ecx,(%eax)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	8b 52 04             	mov    0x4(%edx),%edx
  80051c:	eb 22                	jmp    800540 <getuint+0x38>
	else if (lflag)
  80051e:	85 d2                	test   %edx,%edx
  800520:	74 10                	je     800532 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800522:	8b 10                	mov    (%eax),%edx
  800524:	8d 4a 04             	lea    0x4(%edx),%ecx
  800527:	89 08                	mov    %ecx,(%eax)
  800529:	8b 02                	mov    (%edx),%eax
  80052b:	ba 00 00 00 00       	mov    $0x0,%edx
  800530:	eb 0e                	jmp    800540 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800532:	8b 10                	mov    (%eax),%edx
  800534:	8d 4a 04             	lea    0x4(%edx),%ecx
  800537:	89 08                	mov    %ecx,(%eax)
  800539:	8b 02                	mov    (%edx),%eax
  80053b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800540:	5d                   	pop    %ebp
  800541:	c3                   	ret    

00800542 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800548:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80054c:	8b 10                	mov    (%eax),%edx
  80054e:	3b 50 04             	cmp    0x4(%eax),%edx
  800551:	73 0a                	jae    80055d <sprintputch+0x1b>
		*b->buf++ = ch;
  800553:	8d 4a 01             	lea    0x1(%edx),%ecx
  800556:	89 08                	mov    %ecx,(%eax)
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	88 02                	mov    %al,(%edx)
}
  80055d:	5d                   	pop    %ebp
  80055e:	c3                   	ret    

0080055f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800565:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800568:	50                   	push   %eax
  800569:	ff 75 10             	pushl  0x10(%ebp)
  80056c:	ff 75 0c             	pushl  0xc(%ebp)
  80056f:	ff 75 08             	pushl  0x8(%ebp)
  800572:	e8 05 00 00 00       	call   80057c <vprintfmt>
	va_end(ap);
}
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	57                   	push   %edi
  800580:	56                   	push   %esi
  800581:	53                   	push   %ebx
  800582:	83 ec 2c             	sub    $0x2c,%esp
  800585:	8b 7d 08             	mov    0x8(%ebp),%edi
  800588:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058b:	eb 03                	jmp    800590 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80058d:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800590:	8b 45 10             	mov    0x10(%ebp),%eax
  800593:	8d 70 01             	lea    0x1(%eax),%esi
  800596:	0f b6 00             	movzbl (%eax),%eax
  800599:	83 f8 25             	cmp    $0x25,%eax
  80059c:	74 27                	je     8005c5 <vprintfmt+0x49>
			if (ch == '\0')
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	75 0d                	jne    8005af <vprintfmt+0x33>
  8005a2:	e9 9d 04 00 00       	jmp    800a44 <vprintfmt+0x4c8>
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	0f 84 95 04 00 00    	je     800a44 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	50                   	push   %eax
  8005b4:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b6:	83 c6 01             	add    $0x1,%esi
  8005b9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	83 f8 25             	cmp    $0x25,%eax
  8005c3:	75 e2                	jne    8005a7 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ca:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8005ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005dc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005e3:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8005ea:	eb 08                	jmp    8005f4 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8005ef:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	8d 46 01             	lea    0x1(%esi),%eax
  8005f7:	89 45 10             	mov    %eax,0x10(%ebp)
  8005fa:	0f b6 06             	movzbl (%esi),%eax
  8005fd:	0f b6 d0             	movzbl %al,%edx
  800600:	83 e8 23             	sub    $0x23,%eax
  800603:	3c 55                	cmp    $0x55,%al
  800605:	0f 87 fa 03 00 00    	ja     800a05 <vprintfmt+0x489>
  80060b:	0f b6 c0             	movzbl %al,%eax
  80060e:	ff 24 85 dc 12 80 00 	jmp    *0x8012dc(,%eax,4)
  800615:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800618:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80061c:	eb d6                	jmp    8005f4 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80061e:	8d 42 d0             	lea    -0x30(%edx),%eax
  800621:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800624:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800628:	8d 50 d0             	lea    -0x30(%eax),%edx
  80062b:	83 fa 09             	cmp    $0x9,%edx
  80062e:	77 6b                	ja     80069b <vprintfmt+0x11f>
  800630:	8b 75 10             	mov    0x10(%ebp),%esi
  800633:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800636:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800639:	eb 09                	jmp    800644 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80063e:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800642:	eb b0                	jmp    8005f4 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800644:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800647:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80064a:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80064e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800651:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800654:	83 f9 09             	cmp    $0x9,%ecx
  800657:	76 eb                	jbe    800644 <vprintfmt+0xc8>
  800659:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80065c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80065f:	eb 3d                	jmp    80069e <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 50 04             	lea    0x4(%eax),%edx
  800667:	89 55 14             	mov    %edx,0x14(%ebp)
  80066a:	8b 00                	mov    (%eax),%eax
  80066c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800672:	eb 2a                	jmp    80069e <vprintfmt+0x122>
  800674:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800677:	85 c0                	test   %eax,%eax
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
  80067e:	0f 49 d0             	cmovns %eax,%edx
  800681:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	8b 75 10             	mov    0x10(%ebp),%esi
  800687:	e9 68 ff ff ff       	jmp    8005f4 <vprintfmt+0x78>
  80068c:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80068f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800696:	e9 59 ff ff ff       	jmp    8005f4 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80069e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a2:	0f 89 4c ff ff ff    	jns    8005f4 <vprintfmt+0x78>
				width = precision, precision = -1;
  8006a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006b5:	e9 3a ff ff ff       	jmp    8005f4 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006ba:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c1:	e9 2e ff ff ff       	jmp    8005f4 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	ff 30                	pushl  (%eax)
  8006d5:	ff d7                	call   *%edi
			break;
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	e9 b1 fe ff ff       	jmp    800590 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 00                	mov    (%eax),%eax
  8006ea:	99                   	cltd   
  8006eb:	31 d0                	xor    %edx,%eax
  8006ed:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ef:	83 f8 06             	cmp    $0x6,%eax
  8006f2:	7f 0b                	jg     8006ff <vprintfmt+0x183>
  8006f4:	8b 14 85 34 14 80 00 	mov    0x801434(,%eax,4),%edx
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	75 15                	jne    800714 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8006ff:	50                   	push   %eax
  800700:	68 eb 11 80 00       	push   $0x8011eb
  800705:	53                   	push   %ebx
  800706:	57                   	push   %edi
  800707:	e8 53 fe ff ff       	call   80055f <printfmt>
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	e9 7c fe ff ff       	jmp    800590 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800714:	52                   	push   %edx
  800715:	68 f4 11 80 00       	push   $0x8011f4
  80071a:	53                   	push   %ebx
  80071b:	57                   	push   %edi
  80071c:	e8 3e fe ff ff       	call   80055f <printfmt>
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	e9 67 fe ff ff       	jmp    800590 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8d 50 04             	lea    0x4(%eax),%edx
  80072f:	89 55 14             	mov    %edx,0x14(%ebp)
  800732:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800734:	85 c0                	test   %eax,%eax
  800736:	b9 e4 11 80 00       	mov    $0x8011e4,%ecx
  80073b:	0f 45 c8             	cmovne %eax,%ecx
  80073e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800741:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800745:	7e 06                	jle    80074d <vprintfmt+0x1d1>
  800747:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80074b:	75 19                	jne    800766 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800750:	8d 70 01             	lea    0x1(%eax),%esi
  800753:	0f b6 00             	movzbl (%eax),%eax
  800756:	0f be d0             	movsbl %al,%edx
  800759:	85 d2                	test   %edx,%edx
  80075b:	0f 85 9f 00 00 00    	jne    800800 <vprintfmt+0x284>
  800761:	e9 8c 00 00 00       	jmp    8007f2 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	ff 75 d0             	pushl  -0x30(%ebp)
  80076c:	ff 75 cc             	pushl  -0x34(%ebp)
  80076f:	e8 62 03 00 00       	call   800ad6 <strnlen>
  800774:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800777:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	85 c9                	test   %ecx,%ecx
  80077f:	0f 8e a6 02 00 00    	jle    800a2b <vprintfmt+0x4af>
					putch(padc, putdat);
  800785:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800789:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80078c:	89 cb                	mov    %ecx,%ebx
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	56                   	push   %esi
  800795:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	83 eb 01             	sub    $0x1,%ebx
  80079d:	75 ef                	jne    80078e <vprintfmt+0x212>
  80079f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a5:	e9 81 02 00 00       	jmp    800a2b <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ae:	74 1b                	je     8007cb <vprintfmt+0x24f>
  8007b0:	0f be c0             	movsbl %al,%eax
  8007b3:	83 e8 20             	sub    $0x20,%eax
  8007b6:	83 f8 5e             	cmp    $0x5e,%eax
  8007b9:	76 10                	jbe    8007cb <vprintfmt+0x24f>
					putch('?', putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	ff 75 0c             	pushl  0xc(%ebp)
  8007c1:	6a 3f                	push   $0x3f
  8007c3:	ff 55 08             	call   *0x8(%ebp)
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	eb 0d                	jmp    8007d8 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	ff 75 0c             	pushl  0xc(%ebp)
  8007d1:	52                   	push   %edx
  8007d2:	ff 55 08             	call   *0x8(%ebp)
  8007d5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	83 c6 01             	add    $0x1,%esi
  8007de:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007e2:	0f be d0             	movsbl %al,%edx
  8007e5:	85 d2                	test   %edx,%edx
  8007e7:	75 31                	jne    80081a <vprintfmt+0x29e>
  8007e9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f9:	7f 33                	jg     80082e <vprintfmt+0x2b2>
  8007fb:	e9 90 fd ff ff       	jmp    800590 <vprintfmt+0x14>
  800800:	89 7d 08             	mov    %edi,0x8(%ebp)
  800803:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800806:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800809:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80080c:	eb 0c                	jmp    80081a <vprintfmt+0x29e>
  80080e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800811:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800814:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800817:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80081a:	85 db                	test   %ebx,%ebx
  80081c:	78 8c                	js     8007aa <vprintfmt+0x22e>
  80081e:	83 eb 01             	sub    $0x1,%ebx
  800821:	79 87                	jns    8007aa <vprintfmt+0x22e>
  800823:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800826:	8b 7d 08             	mov    0x8(%ebp),%edi
  800829:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80082c:	eb c4                	jmp    8007f2 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	53                   	push   %ebx
  800832:	6a 20                	push   $0x20
  800834:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	83 ee 01             	sub    $0x1,%esi
  80083c:	75 f0                	jne    80082e <vprintfmt+0x2b2>
  80083e:	e9 4d fd ff ff       	jmp    800590 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800843:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800847:	7e 16                	jle    80085f <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8d 50 08             	lea    0x8(%eax),%edx
  80084f:	89 55 14             	mov    %edx,0x14(%ebp)
  800852:	8b 50 04             	mov    0x4(%eax),%edx
  800855:	8b 00                	mov    (%eax),%eax
  800857:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80085a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80085d:	eb 34                	jmp    800893 <vprintfmt+0x317>
	else if (lflag)
  80085f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800863:	74 18                	je     80087d <vprintfmt+0x301>
		return va_arg(*ap, long);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8d 50 04             	lea    0x4(%eax),%edx
  80086b:	89 55 14             	mov    %edx,0x14(%ebp)
  80086e:	8b 30                	mov    (%eax),%esi
  800870:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800873:	89 f0                	mov    %esi,%eax
  800875:	c1 f8 1f             	sar    $0x1f,%eax
  800878:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80087b:	eb 16                	jmp    800893 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  80087d:	8b 45 14             	mov    0x14(%ebp),%eax
  800880:	8d 50 04             	lea    0x4(%eax),%edx
  800883:	89 55 14             	mov    %edx,0x14(%ebp)
  800886:	8b 30                	mov    (%eax),%esi
  800888:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	c1 f8 1f             	sar    $0x1f,%eax
  800890:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800893:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800896:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800899:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80089f:	85 d2                	test   %edx,%edx
  8008a1:	79 28                	jns    8008cb <vprintfmt+0x34f>
				putch('-', putdat);
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	53                   	push   %ebx
  8008a7:	6a 2d                	push   $0x2d
  8008a9:	ff d7                	call   *%edi
				num = -(long long) num;
  8008ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008b1:	f7 d8                	neg    %eax
  8008b3:	83 d2 00             	adc    $0x0,%edx
  8008b6:	f7 da                	neg    %edx
  8008b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008be:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8008c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c6:	e9 b2 00 00 00       	jmp    80097d <vprintfmt+0x401>
  8008cb:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8008d0:	85 c9                	test   %ecx,%ecx
  8008d2:	0f 84 a5 00 00 00    	je     80097d <vprintfmt+0x401>
				putch('+', putdat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	53                   	push   %ebx
  8008dc:	6a 2b                	push   $0x2b
  8008de:	ff d7                	call   *%edi
  8008e0:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8008e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e8:	e9 90 00 00 00       	jmp    80097d <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8008ed:	85 c9                	test   %ecx,%ecx
  8008ef:	74 0b                	je     8008fc <vprintfmt+0x380>
				putch('+', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 2b                	push   $0x2b
  8008f7:	ff d7                	call   *%edi
  8008f9:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8008fc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800902:	e8 01 fc ff ff       	call   800508 <getuint>
  800907:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80090a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80090d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800912:	eb 69                	jmp    80097d <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	53                   	push   %ebx
  800918:	6a 30                	push   $0x30
  80091a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80091c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 e1 fb ff ff       	call   800508 <getuint>
  800927:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80092d:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800930:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800935:	eb 46                	jmp    80097d <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800937:	83 ec 08             	sub    $0x8,%esp
  80093a:	53                   	push   %ebx
  80093b:	6a 30                	push   $0x30
  80093d:	ff d7                	call   *%edi
			putch('x', putdat);
  80093f:	83 c4 08             	add    $0x8,%esp
  800942:	53                   	push   %ebx
  800943:	6a 78                	push   $0x78
  800945:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	8d 50 04             	lea    0x4(%eax),%edx
  80094d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800950:	8b 00                	mov    (%eax),%eax
  800952:	ba 00 00 00 00       	mov    $0x0,%edx
  800957:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80095a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80095d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800960:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800965:	eb 16                	jmp    80097d <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800967:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80096a:	8d 45 14             	lea    0x14(%ebp),%eax
  80096d:	e8 96 fb ff ff       	call   800508 <getuint>
  800972:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800975:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800978:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80097d:	83 ec 0c             	sub    $0xc,%esp
  800980:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800984:	56                   	push   %esi
  800985:	ff 75 e4             	pushl  -0x1c(%ebp)
  800988:	50                   	push   %eax
  800989:	ff 75 dc             	pushl  -0x24(%ebp)
  80098c:	ff 75 d8             	pushl  -0x28(%ebp)
  80098f:	89 da                	mov    %ebx,%edx
  800991:	89 f8                	mov    %edi,%eax
  800993:	e8 55 f9 ff ff       	call   8002ed <printnum>
			break;
  800998:	83 c4 20             	add    $0x20,%esp
  80099b:	e9 f0 fb ff ff       	jmp    800590 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  8009a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a3:	8d 50 04             	lea    0x4(%eax),%edx
  8009a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a9:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8009ab:	85 f6                	test   %esi,%esi
  8009ad:	75 1a                	jne    8009c9 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8009af:	83 ec 08             	sub    $0x8,%esp
  8009b2:	68 60 12 80 00       	push   $0x801260
  8009b7:	68 f4 11 80 00       	push   $0x8011f4
  8009bc:	e8 18 f9 ff ff       	call   8002d9 <cprintf>
  8009c1:	83 c4 10             	add    $0x10,%esp
  8009c4:	e9 c7 fb ff ff       	jmp    800590 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8009c9:	0f b6 03             	movzbl (%ebx),%eax
  8009cc:	84 c0                	test   %al,%al
  8009ce:	79 1f                	jns    8009ef <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8009d0:	83 ec 08             	sub    $0x8,%esp
  8009d3:	68 98 12 80 00       	push   $0x801298
  8009d8:	68 f4 11 80 00       	push   $0x8011f4
  8009dd:	e8 f7 f8 ff ff       	call   8002d9 <cprintf>
						*tmp = *(char *)putdat;
  8009e2:	0f b6 03             	movzbl (%ebx),%eax
  8009e5:	88 06                	mov    %al,(%esi)
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	e9 a1 fb ff ff       	jmp    800590 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8009ef:	88 06                	mov    %al,(%esi)
  8009f1:	e9 9a fb ff ff       	jmp    800590 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009f6:	83 ec 08             	sub    $0x8,%esp
  8009f9:	53                   	push   %ebx
  8009fa:	52                   	push   %edx
  8009fb:	ff d7                	call   *%edi
			break;
  8009fd:	83 c4 10             	add    $0x10,%esp
  800a00:	e9 8b fb ff ff       	jmp    800590 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a05:	83 ec 08             	sub    $0x8,%esp
  800a08:	53                   	push   %ebx
  800a09:	6a 25                	push   $0x25
  800a0b:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a14:	0f 84 73 fb ff ff    	je     80058d <vprintfmt+0x11>
  800a1a:	83 ee 01             	sub    $0x1,%esi
  800a1d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a21:	75 f7                	jne    800a1a <vprintfmt+0x49e>
  800a23:	89 75 10             	mov    %esi,0x10(%ebp)
  800a26:	e9 65 fb ff ff       	jmp    800590 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a2e:	8d 70 01             	lea    0x1(%eax),%esi
  800a31:	0f b6 00             	movzbl (%eax),%eax
  800a34:	0f be d0             	movsbl %al,%edx
  800a37:	85 d2                	test   %edx,%edx
  800a39:	0f 85 cf fd ff ff    	jne    80080e <vprintfmt+0x292>
  800a3f:	e9 4c fb ff ff       	jmp    800590 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	83 ec 18             	sub    $0x18,%esp
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a58:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a5b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a5f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a69:	85 c0                	test   %eax,%eax
  800a6b:	74 26                	je     800a93 <vsnprintf+0x47>
  800a6d:	85 d2                	test   %edx,%edx
  800a6f:	7e 22                	jle    800a93 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a71:	ff 75 14             	pushl  0x14(%ebp)
  800a74:	ff 75 10             	pushl  0x10(%ebp)
  800a77:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a7a:	50                   	push   %eax
  800a7b:	68 42 05 80 00       	push   $0x800542
  800a80:	e8 f7 fa ff ff       	call   80057c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a85:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a88:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a8e:	83 c4 10             	add    $0x10,%esp
  800a91:	eb 05                	jmp    800a98 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    

00800a9a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aa0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa3:	50                   	push   %eax
  800aa4:	ff 75 10             	pushl  0x10(%ebp)
  800aa7:	ff 75 0c             	pushl  0xc(%ebp)
  800aaa:	ff 75 08             	pushl  0x8(%ebp)
  800aad:	e8 9a ff ff ff       	call   800a4c <vsnprintf>
	va_end(ap);

	return rc;
}
  800ab2:	c9                   	leave  
  800ab3:	c3                   	ret    

00800ab4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aba:	80 3a 00             	cmpb   $0x0,(%edx)
  800abd:	74 10                	je     800acf <strlen+0x1b>
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ac4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800acb:	75 f7                	jne    800ac4 <strlen+0x10>
  800acd:	eb 05                	jmp    800ad4 <strlen+0x20>
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	53                   	push   %ebx
  800ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800add:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae0:	85 c9                	test   %ecx,%ecx
  800ae2:	74 1c                	je     800b00 <strnlen+0x2a>
  800ae4:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ae7:	74 1e                	je     800b07 <strnlen+0x31>
  800ae9:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800aee:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af0:	39 ca                	cmp    %ecx,%edx
  800af2:	74 18                	je     800b0c <strnlen+0x36>
  800af4:	83 c2 01             	add    $0x1,%edx
  800af7:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800afc:	75 f0                	jne    800aee <strnlen+0x18>
  800afe:	eb 0c                	jmp    800b0c <strnlen+0x36>
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	eb 05                	jmp    800b0c <strnlen+0x36>
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	53                   	push   %ebx
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b19:	89 c2                	mov    %eax,%edx
  800b1b:	83 c2 01             	add    $0x1,%edx
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b25:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b28:	84 db                	test   %bl,%bl
  800b2a:	75 ef                	jne    800b1b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	53                   	push   %ebx
  800b33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b36:	53                   	push   %ebx
  800b37:	e8 78 ff ff ff       	call   800ab4 <strlen>
  800b3c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b3f:	ff 75 0c             	pushl  0xc(%ebp)
  800b42:	01 d8                	add    %ebx,%eax
  800b44:	50                   	push   %eax
  800b45:	e8 c5 ff ff ff       	call   800b0f <strcpy>
	return dst;
}
  800b4a:	89 d8                	mov    %ebx,%eax
  800b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	8b 75 08             	mov    0x8(%ebp),%esi
  800b59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b5f:	85 db                	test   %ebx,%ebx
  800b61:	74 17                	je     800b7a <strncpy+0x29>
  800b63:	01 f3                	add    %esi,%ebx
  800b65:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b67:	83 c1 01             	add    $0x1,%ecx
  800b6a:	0f b6 02             	movzbl (%edx),%eax
  800b6d:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b70:	80 3a 01             	cmpb   $0x1,(%edx)
  800b73:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b76:	39 cb                	cmp    %ecx,%ebx
  800b78:	75 ed                	jne    800b67 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b7a:	89 f0                	mov    %esi,%eax
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	8b 75 08             	mov    0x8(%ebp),%esi
  800b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8b:	8b 55 10             	mov    0x10(%ebp),%edx
  800b8e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b90:	85 d2                	test   %edx,%edx
  800b92:	74 35                	je     800bc9 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b94:	89 d0                	mov    %edx,%eax
  800b96:	83 e8 01             	sub    $0x1,%eax
  800b99:	74 25                	je     800bc0 <strlcpy+0x40>
  800b9b:	0f b6 0b             	movzbl (%ebx),%ecx
  800b9e:	84 c9                	test   %cl,%cl
  800ba0:	74 22                	je     800bc4 <strlcpy+0x44>
  800ba2:	8d 53 01             	lea    0x1(%ebx),%edx
  800ba5:	01 c3                	add    %eax,%ebx
  800ba7:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ba9:	83 c0 01             	add    $0x1,%eax
  800bac:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800baf:	39 da                	cmp    %ebx,%edx
  800bb1:	74 13                	je     800bc6 <strlcpy+0x46>
  800bb3:	83 c2 01             	add    $0x1,%edx
  800bb6:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800bba:	84 c9                	test   %cl,%cl
  800bbc:	75 eb                	jne    800ba9 <strlcpy+0x29>
  800bbe:	eb 06                	jmp    800bc6 <strlcpy+0x46>
  800bc0:	89 f0                	mov    %esi,%eax
  800bc2:	eb 02                	jmp    800bc6 <strlcpy+0x46>
  800bc4:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bc6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc9:	29 f0                	sub    %esi,%eax
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bd8:	0f b6 01             	movzbl (%ecx),%eax
  800bdb:	84 c0                	test   %al,%al
  800bdd:	74 15                	je     800bf4 <strcmp+0x25>
  800bdf:	3a 02                	cmp    (%edx),%al
  800be1:	75 11                	jne    800bf4 <strcmp+0x25>
		p++, q++;
  800be3:	83 c1 01             	add    $0x1,%ecx
  800be6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800be9:	0f b6 01             	movzbl (%ecx),%eax
  800bec:	84 c0                	test   %al,%al
  800bee:	74 04                	je     800bf4 <strcmp+0x25>
  800bf0:	3a 02                	cmp    (%edx),%al
  800bf2:	74 ef                	je     800be3 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf4:	0f b6 c0             	movzbl %al,%eax
  800bf7:	0f b6 12             	movzbl (%edx),%edx
  800bfa:	29 d0                	sub    %edx,%eax
}
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c09:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c0c:	85 f6                	test   %esi,%esi
  800c0e:	74 29                	je     800c39 <strncmp+0x3b>
  800c10:	0f b6 03             	movzbl (%ebx),%eax
  800c13:	84 c0                	test   %al,%al
  800c15:	74 30                	je     800c47 <strncmp+0x49>
  800c17:	3a 02                	cmp    (%edx),%al
  800c19:	75 2c                	jne    800c47 <strncmp+0x49>
  800c1b:	8d 43 01             	lea    0x1(%ebx),%eax
  800c1e:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c20:	89 c3                	mov    %eax,%ebx
  800c22:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c25:	39 c6                	cmp    %eax,%esi
  800c27:	74 17                	je     800c40 <strncmp+0x42>
  800c29:	0f b6 08             	movzbl (%eax),%ecx
  800c2c:	84 c9                	test   %cl,%cl
  800c2e:	74 17                	je     800c47 <strncmp+0x49>
  800c30:	83 c0 01             	add    $0x1,%eax
  800c33:	3a 0a                	cmp    (%edx),%cl
  800c35:	74 e9                	je     800c20 <strncmp+0x22>
  800c37:	eb 0e                	jmp    800c47 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3e:	eb 0f                	jmp    800c4f <strncmp+0x51>
  800c40:	b8 00 00 00 00       	mov    $0x0,%eax
  800c45:	eb 08                	jmp    800c4f <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c47:	0f b6 03             	movzbl (%ebx),%eax
  800c4a:	0f b6 12             	movzbl (%edx),%edx
  800c4d:	29 d0                	sub    %edx,%eax
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	53                   	push   %ebx
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	74 1d                	je     800c81 <strchr+0x2e>
  800c64:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800c66:	38 d3                	cmp    %dl,%bl
  800c68:	75 06                	jne    800c70 <strchr+0x1d>
  800c6a:	eb 1a                	jmp    800c86 <strchr+0x33>
  800c6c:	38 ca                	cmp    %cl,%dl
  800c6e:	74 16                	je     800c86 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c70:	83 c0 01             	add    $0x1,%eax
  800c73:	0f b6 10             	movzbl (%eax),%edx
  800c76:	84 d2                	test   %dl,%dl
  800c78:	75 f2                	jne    800c6c <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7f:	eb 05                	jmp    800c86 <strchr+0x33>
  800c81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c86:	5b                   	pop    %ebx
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	53                   	push   %ebx
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c93:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c96:	38 d3                	cmp    %dl,%bl
  800c98:	74 14                	je     800cae <strfind+0x25>
  800c9a:	89 d1                	mov    %edx,%ecx
  800c9c:	84 db                	test   %bl,%bl
  800c9e:	74 0e                	je     800cae <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ca0:	83 c0 01             	add    $0x1,%eax
  800ca3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ca6:	38 ca                	cmp    %cl,%dl
  800ca8:	74 04                	je     800cae <strfind+0x25>
  800caa:	84 d2                	test   %dl,%dl
  800cac:	75 f2                	jne    800ca0 <strfind+0x17>
			break;
	return (char *) s;
}
  800cae:	5b                   	pop    %ebx
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cbd:	85 c9                	test   %ecx,%ecx
  800cbf:	74 36                	je     800cf7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cc1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cc7:	75 28                	jne    800cf1 <memset+0x40>
  800cc9:	f6 c1 03             	test   $0x3,%cl
  800ccc:	75 23                	jne    800cf1 <memset+0x40>
		c &= 0xFF;
  800cce:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cd2:	89 d3                	mov    %edx,%ebx
  800cd4:	c1 e3 08             	shl    $0x8,%ebx
  800cd7:	89 d6                	mov    %edx,%esi
  800cd9:	c1 e6 18             	shl    $0x18,%esi
  800cdc:	89 d0                	mov    %edx,%eax
  800cde:	c1 e0 10             	shl    $0x10,%eax
  800ce1:	09 f0                	or     %esi,%eax
  800ce3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ce5:	89 d8                	mov    %ebx,%eax
  800ce7:	09 d0                	or     %edx,%eax
  800ce9:	c1 e9 02             	shr    $0x2,%ecx
  800cec:	fc                   	cld    
  800ced:	f3 ab                	rep stos %eax,%es:(%edi)
  800cef:	eb 06                	jmp    800cf7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf4:	fc                   	cld    
  800cf5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cf7:	89 f8                	mov    %edi,%eax
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d0c:	39 c6                	cmp    %eax,%esi
  800d0e:	73 35                	jae    800d45 <memmove+0x47>
  800d10:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d13:	39 d0                	cmp    %edx,%eax
  800d15:	73 2e                	jae    800d45 <memmove+0x47>
		s += n;
		d += n;
  800d17:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	09 fe                	or     %edi,%esi
  800d1e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d24:	75 13                	jne    800d39 <memmove+0x3b>
  800d26:	f6 c1 03             	test   $0x3,%cl
  800d29:	75 0e                	jne    800d39 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d2b:	83 ef 04             	sub    $0x4,%edi
  800d2e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d31:	c1 e9 02             	shr    $0x2,%ecx
  800d34:	fd                   	std    
  800d35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d37:	eb 09                	jmp    800d42 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d39:	83 ef 01             	sub    $0x1,%edi
  800d3c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d3f:	fd                   	std    
  800d40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d42:	fc                   	cld    
  800d43:	eb 1d                	jmp    800d62 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d45:	89 f2                	mov    %esi,%edx
  800d47:	09 c2                	or     %eax,%edx
  800d49:	f6 c2 03             	test   $0x3,%dl
  800d4c:	75 0f                	jne    800d5d <memmove+0x5f>
  800d4e:	f6 c1 03             	test   $0x3,%cl
  800d51:	75 0a                	jne    800d5d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d53:	c1 e9 02             	shr    $0x2,%ecx
  800d56:	89 c7                	mov    %eax,%edi
  800d58:	fc                   	cld    
  800d59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d5b:	eb 05                	jmp    800d62 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d5d:	89 c7                	mov    %eax,%edi
  800d5f:	fc                   	cld    
  800d60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d69:	ff 75 10             	pushl  0x10(%ebp)
  800d6c:	ff 75 0c             	pushl  0xc(%ebp)
  800d6f:	ff 75 08             	pushl  0x8(%ebp)
  800d72:	e8 87 ff ff ff       	call   800cfe <memmove>
}
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d85:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	74 39                	je     800dc5 <memcmp+0x4c>
  800d8c:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800d8f:	0f b6 13             	movzbl (%ebx),%edx
  800d92:	0f b6 0e             	movzbl (%esi),%ecx
  800d95:	38 ca                	cmp    %cl,%dl
  800d97:	75 17                	jne    800db0 <memcmp+0x37>
  800d99:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9e:	eb 1a                	jmp    800dba <memcmp+0x41>
  800da0:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800da5:	83 c0 01             	add    $0x1,%eax
  800da8:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800dac:	38 ca                	cmp    %cl,%dl
  800dae:	74 0a                	je     800dba <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800db0:	0f b6 c2             	movzbl %dl,%eax
  800db3:	0f b6 c9             	movzbl %cl,%ecx
  800db6:	29 c8                	sub    %ecx,%eax
  800db8:	eb 10                	jmp    800dca <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dba:	39 f8                	cmp    %edi,%eax
  800dbc:	75 e2                	jne    800da0 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc3:	eb 05                	jmp    800dca <memcmp+0x51>
  800dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	53                   	push   %ebx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800dd6:	89 d0                	mov    %edx,%eax
  800dd8:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800ddb:	39 c2                	cmp    %eax,%edx
  800ddd:	73 1d                	jae    800dfc <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ddf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800de3:	0f b6 0a             	movzbl (%edx),%ecx
  800de6:	39 d9                	cmp    %ebx,%ecx
  800de8:	75 09                	jne    800df3 <memfind+0x24>
  800dea:	eb 14                	jmp    800e00 <memfind+0x31>
  800dec:	0f b6 0a             	movzbl (%edx),%ecx
  800def:	39 d9                	cmp    %ebx,%ecx
  800df1:	74 11                	je     800e04 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800df3:	83 c2 01             	add    $0x1,%edx
  800df6:	39 d0                	cmp    %edx,%eax
  800df8:	75 f2                	jne    800dec <memfind+0x1d>
  800dfa:	eb 0a                	jmp    800e06 <memfind+0x37>
  800dfc:	89 d0                	mov    %edx,%eax
  800dfe:	eb 06                	jmp    800e06 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e00:	89 d0                	mov    %edx,%eax
  800e02:	eb 02                	jmp    800e06 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e04:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e06:	5b                   	pop    %ebx
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e15:	0f b6 01             	movzbl (%ecx),%eax
  800e18:	3c 20                	cmp    $0x20,%al
  800e1a:	74 04                	je     800e20 <strtol+0x17>
  800e1c:	3c 09                	cmp    $0x9,%al
  800e1e:	75 0e                	jne    800e2e <strtol+0x25>
		s++;
  800e20:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e23:	0f b6 01             	movzbl (%ecx),%eax
  800e26:	3c 20                	cmp    $0x20,%al
  800e28:	74 f6                	je     800e20 <strtol+0x17>
  800e2a:	3c 09                	cmp    $0x9,%al
  800e2c:	74 f2                	je     800e20 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e2e:	3c 2b                	cmp    $0x2b,%al
  800e30:	75 0a                	jne    800e3c <strtol+0x33>
		s++;
  800e32:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e35:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3a:	eb 11                	jmp    800e4d <strtol+0x44>
  800e3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e41:	3c 2d                	cmp    $0x2d,%al
  800e43:	75 08                	jne    800e4d <strtol+0x44>
		s++, neg = 1;
  800e45:	83 c1 01             	add    $0x1,%ecx
  800e48:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e4d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e53:	75 15                	jne    800e6a <strtol+0x61>
  800e55:	80 39 30             	cmpb   $0x30,(%ecx)
  800e58:	75 10                	jne    800e6a <strtol+0x61>
  800e5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e5e:	75 7c                	jne    800edc <strtol+0xd3>
		s += 2, base = 16;
  800e60:	83 c1 02             	add    $0x2,%ecx
  800e63:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e68:	eb 16                	jmp    800e80 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e6a:	85 db                	test   %ebx,%ebx
  800e6c:	75 12                	jne    800e80 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e73:	80 39 30             	cmpb   $0x30,(%ecx)
  800e76:	75 08                	jne    800e80 <strtol+0x77>
		s++, base = 8;
  800e78:	83 c1 01             	add    $0x1,%ecx
  800e7b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e80:	b8 00 00 00 00       	mov    $0x0,%eax
  800e85:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e88:	0f b6 11             	movzbl (%ecx),%edx
  800e8b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e8e:	89 f3                	mov    %esi,%ebx
  800e90:	80 fb 09             	cmp    $0x9,%bl
  800e93:	77 08                	ja     800e9d <strtol+0x94>
			dig = *s - '0';
  800e95:	0f be d2             	movsbl %dl,%edx
  800e98:	83 ea 30             	sub    $0x30,%edx
  800e9b:	eb 22                	jmp    800ebf <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800e9d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ea0:	89 f3                	mov    %esi,%ebx
  800ea2:	80 fb 19             	cmp    $0x19,%bl
  800ea5:	77 08                	ja     800eaf <strtol+0xa6>
			dig = *s - 'a' + 10;
  800ea7:	0f be d2             	movsbl %dl,%edx
  800eaa:	83 ea 57             	sub    $0x57,%edx
  800ead:	eb 10                	jmp    800ebf <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800eaf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eb2:	89 f3                	mov    %esi,%ebx
  800eb4:	80 fb 19             	cmp    $0x19,%bl
  800eb7:	77 16                	ja     800ecf <strtol+0xc6>
			dig = *s - 'A' + 10;
  800eb9:	0f be d2             	movsbl %dl,%edx
  800ebc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ebf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ec2:	7d 0b                	jge    800ecf <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ec4:	83 c1 01             	add    $0x1,%ecx
  800ec7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ecb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ecd:	eb b9                	jmp    800e88 <strtol+0x7f>

	if (endptr)
  800ecf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed3:	74 0d                	je     800ee2 <strtol+0xd9>
		*endptr = (char *) s;
  800ed5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed8:	89 0e                	mov    %ecx,(%esi)
  800eda:	eb 06                	jmp    800ee2 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800edc:	85 db                	test   %ebx,%ebx
  800ede:	74 98                	je     800e78 <strtol+0x6f>
  800ee0:	eb 9e                	jmp    800e80 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ee2:	89 c2                	mov    %eax,%edx
  800ee4:	f7 da                	neg    %edx
  800ee6:	85 ff                	test   %edi,%edi
  800ee8:	0f 45 c2             	cmovne %edx,%eax
}
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <__udivdi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800efb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800eff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 f6                	test   %esi,%esi
  800f09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f0d:	89 ca                	mov    %ecx,%edx
  800f0f:	89 f8                	mov    %edi,%eax
  800f11:	75 3d                	jne    800f50 <__udivdi3+0x60>
  800f13:	39 cf                	cmp    %ecx,%edi
  800f15:	0f 87 c5 00 00 00    	ja     800fe0 <__udivdi3+0xf0>
  800f1b:	85 ff                	test   %edi,%edi
  800f1d:	89 fd                	mov    %edi,%ebp
  800f1f:	75 0b                	jne    800f2c <__udivdi3+0x3c>
  800f21:	b8 01 00 00 00       	mov    $0x1,%eax
  800f26:	31 d2                	xor    %edx,%edx
  800f28:	f7 f7                	div    %edi
  800f2a:	89 c5                	mov    %eax,%ebp
  800f2c:	89 c8                	mov    %ecx,%eax
  800f2e:	31 d2                	xor    %edx,%edx
  800f30:	f7 f5                	div    %ebp
  800f32:	89 c1                	mov    %eax,%ecx
  800f34:	89 d8                	mov    %ebx,%eax
  800f36:	89 cf                	mov    %ecx,%edi
  800f38:	f7 f5                	div    %ebp
  800f3a:	89 c3                	mov    %eax,%ebx
  800f3c:	89 d8                	mov    %ebx,%eax
  800f3e:	89 fa                	mov    %edi,%edx
  800f40:	83 c4 1c             	add    $0x1c,%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    
  800f48:	90                   	nop
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	39 ce                	cmp    %ecx,%esi
  800f52:	77 74                	ja     800fc8 <__udivdi3+0xd8>
  800f54:	0f bd fe             	bsr    %esi,%edi
  800f57:	83 f7 1f             	xor    $0x1f,%edi
  800f5a:	0f 84 98 00 00 00    	je     800ff8 <__udivdi3+0x108>
  800f60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f65:	89 f9                	mov    %edi,%ecx
  800f67:	89 c5                	mov    %eax,%ebp
  800f69:	29 fb                	sub    %edi,%ebx
  800f6b:	d3 e6                	shl    %cl,%esi
  800f6d:	89 d9                	mov    %ebx,%ecx
  800f6f:	d3 ed                	shr    %cl,%ebp
  800f71:	89 f9                	mov    %edi,%ecx
  800f73:	d3 e0                	shl    %cl,%eax
  800f75:	09 ee                	or     %ebp,%esi
  800f77:	89 d9                	mov    %ebx,%ecx
  800f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7d:	89 d5                	mov    %edx,%ebp
  800f7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f83:	d3 ed                	shr    %cl,%ebp
  800f85:	89 f9                	mov    %edi,%ecx
  800f87:	d3 e2                	shl    %cl,%edx
  800f89:	89 d9                	mov    %ebx,%ecx
  800f8b:	d3 e8                	shr    %cl,%eax
  800f8d:	09 c2                	or     %eax,%edx
  800f8f:	89 d0                	mov    %edx,%eax
  800f91:	89 ea                	mov    %ebp,%edx
  800f93:	f7 f6                	div    %esi
  800f95:	89 d5                	mov    %edx,%ebp
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	f7 64 24 0c          	mull   0xc(%esp)
  800f9d:	39 d5                	cmp    %edx,%ebp
  800f9f:	72 10                	jb     800fb1 <__udivdi3+0xc1>
  800fa1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fa5:	89 f9                	mov    %edi,%ecx
  800fa7:	d3 e6                	shl    %cl,%esi
  800fa9:	39 c6                	cmp    %eax,%esi
  800fab:	73 07                	jae    800fb4 <__udivdi3+0xc4>
  800fad:	39 d5                	cmp    %edx,%ebp
  800faf:	75 03                	jne    800fb4 <__udivdi3+0xc4>
  800fb1:	83 eb 01             	sub    $0x1,%ebx
  800fb4:	31 ff                	xor    %edi,%edi
  800fb6:	89 d8                	mov    %ebx,%eax
  800fb8:	89 fa                	mov    %edi,%edx
  800fba:	83 c4 1c             	add    $0x1c,%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	31 ff                	xor    %edi,%edi
  800fca:	31 db                	xor    %ebx,%ebx
  800fcc:	89 d8                	mov    %ebx,%eax
  800fce:	89 fa                	mov    %edi,%edx
  800fd0:	83 c4 1c             	add    $0x1c,%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    
  800fd8:	90                   	nop
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	89 d8                	mov    %ebx,%eax
  800fe2:	f7 f7                	div    %edi
  800fe4:	31 ff                	xor    %edi,%edi
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	89 d8                	mov    %ebx,%eax
  800fea:	89 fa                	mov    %edi,%edx
  800fec:	83 c4 1c             	add    $0x1c,%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    
  800ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	39 ce                	cmp    %ecx,%esi
  800ffa:	72 0c                	jb     801008 <__udivdi3+0x118>
  800ffc:	31 db                	xor    %ebx,%ebx
  800ffe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801002:	0f 87 34 ff ff ff    	ja     800f3c <__udivdi3+0x4c>
  801008:	bb 01 00 00 00       	mov    $0x1,%ebx
  80100d:	e9 2a ff ff ff       	jmp    800f3c <__udivdi3+0x4c>
  801012:	66 90                	xchg   %ax,%ax
  801014:	66 90                	xchg   %ax,%ax
  801016:	66 90                	xchg   %ax,%ax
  801018:	66 90                	xchg   %ax,%ax
  80101a:	66 90                	xchg   %ax,%ax
  80101c:	66 90                	xchg   %ax,%ax
  80101e:	66 90                	xchg   %ax,%ax

00801020 <__umoddi3>:
  801020:	55                   	push   %ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 1c             	sub    $0x1c,%esp
  801027:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80102b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80102f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801037:	85 d2                	test   %edx,%edx
  801039:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80103d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801041:	89 f3                	mov    %esi,%ebx
  801043:	89 3c 24             	mov    %edi,(%esp)
  801046:	89 74 24 04          	mov    %esi,0x4(%esp)
  80104a:	75 1c                	jne    801068 <__umoddi3+0x48>
  80104c:	39 f7                	cmp    %esi,%edi
  80104e:	76 50                	jbe    8010a0 <__umoddi3+0x80>
  801050:	89 c8                	mov    %ecx,%eax
  801052:	89 f2                	mov    %esi,%edx
  801054:	f7 f7                	div    %edi
  801056:	89 d0                	mov    %edx,%eax
  801058:	31 d2                	xor    %edx,%edx
  80105a:	83 c4 1c             	add    $0x1c,%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5f                   	pop    %edi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    
  801062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801068:	39 f2                	cmp    %esi,%edx
  80106a:	89 d0                	mov    %edx,%eax
  80106c:	77 52                	ja     8010c0 <__umoddi3+0xa0>
  80106e:	0f bd ea             	bsr    %edx,%ebp
  801071:	83 f5 1f             	xor    $0x1f,%ebp
  801074:	75 5a                	jne    8010d0 <__umoddi3+0xb0>
  801076:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80107a:	0f 82 e0 00 00 00    	jb     801160 <__umoddi3+0x140>
  801080:	39 0c 24             	cmp    %ecx,(%esp)
  801083:	0f 86 d7 00 00 00    	jbe    801160 <__umoddi3+0x140>
  801089:	8b 44 24 08          	mov    0x8(%esp),%eax
  80108d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801091:	83 c4 1c             	add    $0x1c,%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    
  801099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	85 ff                	test   %edi,%edi
  8010a2:	89 fd                	mov    %edi,%ebp
  8010a4:	75 0b                	jne    8010b1 <__umoddi3+0x91>
  8010a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f7                	div    %edi
  8010af:	89 c5                	mov    %eax,%ebp
  8010b1:	89 f0                	mov    %esi,%eax
  8010b3:	31 d2                	xor    %edx,%edx
  8010b5:	f7 f5                	div    %ebp
  8010b7:	89 c8                	mov    %ecx,%eax
  8010b9:	f7 f5                	div    %ebp
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	eb 99                	jmp    801058 <__umoddi3+0x38>
  8010bf:	90                   	nop
  8010c0:	89 c8                	mov    %ecx,%eax
  8010c2:	89 f2                	mov    %esi,%edx
  8010c4:	83 c4 1c             	add    $0x1c,%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    
  8010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	8b 34 24             	mov    (%esp),%esi
  8010d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010d8:	89 e9                	mov    %ebp,%ecx
  8010da:	29 ef                	sub    %ebp,%edi
  8010dc:	d3 e0                	shl    %cl,%eax
  8010de:	89 f9                	mov    %edi,%ecx
  8010e0:	89 f2                	mov    %esi,%edx
  8010e2:	d3 ea                	shr    %cl,%edx
  8010e4:	89 e9                	mov    %ebp,%ecx
  8010e6:	09 c2                	or     %eax,%edx
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	89 14 24             	mov    %edx,(%esp)
  8010ed:	89 f2                	mov    %esi,%edx
  8010ef:	d3 e2                	shl    %cl,%edx
  8010f1:	89 f9                	mov    %edi,%ecx
  8010f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010fb:	d3 e8                	shr    %cl,%eax
  8010fd:	89 e9                	mov    %ebp,%ecx
  8010ff:	89 c6                	mov    %eax,%esi
  801101:	d3 e3                	shl    %cl,%ebx
  801103:	89 f9                	mov    %edi,%ecx
  801105:	89 d0                	mov    %edx,%eax
  801107:	d3 e8                	shr    %cl,%eax
  801109:	89 e9                	mov    %ebp,%ecx
  80110b:	09 d8                	or     %ebx,%eax
  80110d:	89 d3                	mov    %edx,%ebx
  80110f:	89 f2                	mov    %esi,%edx
  801111:	f7 34 24             	divl   (%esp)
  801114:	89 d6                	mov    %edx,%esi
  801116:	d3 e3                	shl    %cl,%ebx
  801118:	f7 64 24 04          	mull   0x4(%esp)
  80111c:	39 d6                	cmp    %edx,%esi
  80111e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801122:	89 d1                	mov    %edx,%ecx
  801124:	89 c3                	mov    %eax,%ebx
  801126:	72 08                	jb     801130 <__umoddi3+0x110>
  801128:	75 11                	jne    80113b <__umoddi3+0x11b>
  80112a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80112e:	73 0b                	jae    80113b <__umoddi3+0x11b>
  801130:	2b 44 24 04          	sub    0x4(%esp),%eax
  801134:	1b 14 24             	sbb    (%esp),%edx
  801137:	89 d1                	mov    %edx,%ecx
  801139:	89 c3                	mov    %eax,%ebx
  80113b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80113f:	29 da                	sub    %ebx,%edx
  801141:	19 ce                	sbb    %ecx,%esi
  801143:	89 f9                	mov    %edi,%ecx
  801145:	89 f0                	mov    %esi,%eax
  801147:	d3 e0                	shl    %cl,%eax
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	d3 ea                	shr    %cl,%edx
  80114d:	89 e9                	mov    %ebp,%ecx
  80114f:	d3 ee                	shr    %cl,%esi
  801151:	09 d0                	or     %edx,%eax
  801153:	89 f2                	mov    %esi,%edx
  801155:	83 c4 1c             	add    $0x1c,%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    
  80115d:	8d 76 00             	lea    0x0(%esi),%esi
  801160:	29 f9                	sub    %edi,%ecx
  801162:	19 d6                	sbb    %edx,%esi
  801164:	89 74 24 04          	mov    %esi,0x4(%esp)
  801168:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80116c:	e9 18 ff ff ff       	jmp    801089 <__umoddi3+0x69>
