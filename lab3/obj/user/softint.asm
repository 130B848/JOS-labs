
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800045:	e8 f9 00 00 00       	call   800143 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 64             	imul   $0x64,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 66 00 00 00       	call   8000f3 <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	51                   	push   %ecx
  8000a7:	52                   	push   %edx
  8000a8:	53                   	push   %ebx
  8000a9:	54                   	push   %esp
  8000aa:	55                   	push   %ebp
  8000ab:	56                   	push   %esi
  8000ac:	57                   	push   %edi
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	8d 35 b7 00 80 00    	lea    0x8000b7,%esi
  8000b5:	0f 34                	sysenter 

008000b7 <label_21>:
  8000b7:	5f                   	pop    %edi
  8000b8:	5e                   	pop    %esi
  8000b9:	5d                   	pop    %ebp
  8000ba:	5c                   	pop    %esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5a                   	pop    %edx
  8000bd:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 ca                	mov    %ecx,%edx
  8000d3:	89 cb                	mov    %ecx,%ebx
  8000d5:	89 cf                	mov    %ecx,%edi
  8000d7:	51                   	push   %ecx
  8000d8:	52                   	push   %edx
  8000d9:	53                   	push   %ebx
  8000da:	54                   	push   %esp
  8000db:	55                   	push   %ebp
  8000dc:	56                   	push   %esi
  8000dd:	57                   	push   %edi
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	8d 35 e8 00 80 00    	lea    0x8000e8,%esi
  8000e6:	0f 34                	sysenter 

008000e8 <label_55>:
  8000e8:	5f                   	pop    %edi
  8000e9:	5e                   	pop    %esi
  8000ea:	5d                   	pop    %ebp
  8000eb:	5c                   	pop    %esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5a                   	pop    %edx
  8000ee:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000fd:	b8 03 00 00 00       	mov    $0x3,%eax
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	89 d9                	mov    %ebx,%ecx
  800107:	89 df                	mov    %ebx,%edi
  800109:	51                   	push   %ecx
  80010a:	52                   	push   %edx
  80010b:	53                   	push   %ebx
  80010c:	54                   	push   %esp
  80010d:	55                   	push   %ebp
  80010e:	56                   	push   %esi
  80010f:	57                   	push   %edi
  800110:	89 e5                	mov    %esp,%ebp
  800112:	8d 35 1a 01 80 00    	lea    0x80011a,%esi
  800118:	0f 34                	sysenter 

0080011a <label_90>:
  80011a:	5f                   	pop    %edi
  80011b:	5e                   	pop    %esi
  80011c:	5d                   	pop    %ebp
  80011d:	5c                   	pop    %esp
  80011e:	5b                   	pop    %ebx
  80011f:	5a                   	pop    %edx
  800120:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	7e 17                	jle    80013c <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	50                   	push   %eax
  800129:	6a 03                	push   $0x3
  80012b:	68 7e 11 80 00       	push   $0x80117e
  800130:	6a 2a                	push   $0x2a
  800132:	68 9b 11 80 00       	push   $0x80119b
  800137:	e8 9d 00 00 00       	call   8001d9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013f:	5b                   	pop    %ebx
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800148:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014d:	b8 02 00 00 00       	mov    $0x2,%eax
  800152:	89 ca                	mov    %ecx,%edx
  800154:	89 cb                	mov    %ecx,%ebx
  800156:	89 cf                	mov    %ecx,%edi
  800158:	51                   	push   %ecx
  800159:	52                   	push   %edx
  80015a:	53                   	push   %ebx
  80015b:	54                   	push   %esp
  80015c:	55                   	push   %ebp
  80015d:	56                   	push   %esi
  80015e:	57                   	push   %edi
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	8d 35 69 01 80 00    	lea    0x800169,%esi
  800167:	0f 34                	sysenter 

00800169 <label_139>:
  800169:	5f                   	pop    %edi
  80016a:	5e                   	pop    %esi
  80016b:	5d                   	pop    %ebp
  80016c:	5c                   	pop    %esp
  80016d:	5b                   	pop    %ebx
  80016e:	5a                   	pop    %edx
  80016f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800179:	bf 00 00 00 00       	mov    $0x0,%edi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	89 fb                	mov    %edi,%ebx
  80018b:	51                   	push   %ecx
  80018c:	52                   	push   %edx
  80018d:	53                   	push   %ebx
  80018e:	54                   	push   %esp
  80018f:	55                   	push   %ebp
  800190:	56                   	push   %esi
  800191:	57                   	push   %edi
  800192:	89 e5                	mov    %esp,%ebp
  800194:	8d 35 9c 01 80 00    	lea    0x80019c,%esi
  80019a:	0f 34                	sysenter 

0080019c <label_174>:
  80019c:	5f                   	pop    %edi
  80019d:	5e                   	pop    %esi
  80019e:	5d                   	pop    %ebp
  80019f:	5c                   	pop    %esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5a                   	pop    %edx
  8001a2:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001a3:	5b                   	pop    %ebx
  8001a4:	5f                   	pop    %edi
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	89 cb                	mov    %ecx,%ebx
  8001bb:	89 cf                	mov    %ecx,%edi
  8001bd:	51                   	push   %ecx
  8001be:	52                   	push   %edx
  8001bf:	53                   	push   %ebx
  8001c0:	54                   	push   %esp
  8001c1:	55                   	push   %ebp
  8001c2:	56                   	push   %esi
  8001c3:	57                   	push   %edi
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	8d 35 ce 01 80 00    	lea    0x8001ce,%esi
  8001cc:	0f 34                	sysenter 

008001ce <label_209>:
  8001ce:	5f                   	pop    %edi
  8001cf:	5e                   	pop    %esi
  8001d0:	5d                   	pop    %ebp
  8001d1:	5c                   	pop    %esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5a                   	pop    %edx
  8001d4:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001d5:	5b                   	pop    %ebx
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001de:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001e1:	a1 10 20 80 00       	mov    0x802010,%eax
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	74 11                	je     8001fb <_panic+0x22>
		cprintf("%s: ", argv0);
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	50                   	push   %eax
  8001ee:	68 a9 11 80 00       	push   $0x8011a9
  8001f3:	e8 d4 00 00 00       	call   8002cc <cprintf>
  8001f8:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800201:	e8 3d ff ff ff       	call   800143 <sys_getenvid>
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	ff 75 0c             	pushl  0xc(%ebp)
  80020c:	ff 75 08             	pushl  0x8(%ebp)
  80020f:	56                   	push   %esi
  800210:	50                   	push   %eax
  800211:	68 b0 11 80 00       	push   $0x8011b0
  800216:	e8 b1 00 00 00       	call   8002cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021b:	83 c4 18             	add    $0x18,%esp
  80021e:	53                   	push   %ebx
  80021f:	ff 75 10             	pushl  0x10(%ebp)
  800222:	e8 54 00 00 00       	call   80027b <vcprintf>
	cprintf("\n");
  800227:	c7 04 24 ae 11 80 00 	movl   $0x8011ae,(%esp)
  80022e:	e8 99 00 00 00       	call   8002cc <cprintf>
  800233:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800236:	cc                   	int3   
  800237:	eb fd                	jmp    800236 <_panic+0x5d>

00800239 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	53                   	push   %ebx
  80023d:	83 ec 04             	sub    $0x4,%esp
  800240:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800243:	8b 13                	mov    (%ebx),%edx
  800245:	8d 42 01             	lea    0x1(%edx),%eax
  800248:	89 03                	mov    %eax,(%ebx)
  80024a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800251:	3d ff 00 00 00       	cmp    $0xff,%eax
  800256:	75 1a                	jne    800272 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800258:	83 ec 08             	sub    $0x8,%esp
  80025b:	68 ff 00 00 00       	push   $0xff
  800260:	8d 43 08             	lea    0x8(%ebx),%eax
  800263:	50                   	push   %eax
  800264:	e8 29 fe ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  800269:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80026f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800272:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800276:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800284:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028b:	00 00 00 
	b.cnt = 0;
  80028e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800295:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a4:	50                   	push   %eax
  8002a5:	68 39 02 80 00       	push   $0x800239
  8002aa:	e8 c0 02 00 00       	call   80056f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002af:	83 c4 08             	add    $0x8,%esp
  8002b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002be:	50                   	push   %eax
  8002bf:	e8 ce fd ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  8002c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	50                   	push   %eax
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 9d ff ff ff       	call   80027b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 1c             	sub    $0x1c,%esp
  8002e9:	89 c7                	mov    %eax,%edi
  8002eb:	89 d6                	mov    %edx,%esi
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  8002fc:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800300:	0f 85 bf 00 00 00    	jne    8003c5 <printnum+0xe5>
  800306:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  80030c:	0f 8d de 00 00 00    	jge    8003f0 <printnum+0x110>
		judge_time_for_space = width;
  800312:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800318:	e9 d3 00 00 00       	jmp    8003f0 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80031d:	83 eb 01             	sub    $0x1,%ebx
  800320:	85 db                	test   %ebx,%ebx
  800322:	7f 37                	jg     80035b <printnum+0x7b>
  800324:	e9 ea 00 00 00       	jmp    800413 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800329:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80032c:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	56                   	push   %esi
  800335:	83 ec 04             	sub    $0x4,%esp
  800338:	ff 75 dc             	pushl  -0x24(%ebp)
  80033b:	ff 75 d8             	pushl  -0x28(%ebp)
  80033e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800341:	ff 75 e0             	pushl  -0x20(%ebp)
  800344:	e8 d7 0c 00 00       	call   801020 <__umoddi3>
  800349:	83 c4 14             	add    $0x14,%esp
  80034c:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800353:	50                   	push   %eax
  800354:	ff d7                	call   *%edi
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	eb 16                	jmp    800371 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	56                   	push   %esi
  80035f:	ff 75 18             	pushl  0x18(%ebp)
  800362:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 eb 01             	sub    $0x1,%ebx
  80036a:	75 ef                	jne    80035b <printnum+0x7b>
  80036c:	e9 a2 00 00 00       	jmp    800413 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800371:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800377:	0f 85 76 01 00 00    	jne    8004f3 <printnum+0x213>
		while(num_of_space-- > 0)
  80037d:	a1 04 20 80 00       	mov    0x802004,%eax
  800382:	8d 50 ff             	lea    -0x1(%eax),%edx
  800385:	89 15 04 20 80 00    	mov    %edx,0x802004
  80038b:	85 c0                	test   %eax,%eax
  80038d:	7e 1d                	jle    8003ac <printnum+0xcc>
			putch(' ', putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	6a 20                	push   $0x20
  800395:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800397:	a1 04 20 80 00       	mov    0x802004,%eax
  80039c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80039f:	89 15 04 20 80 00    	mov    %edx,0x802004
  8003a5:	83 c4 10             	add    $0x10,%esp
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	7f e3                	jg     80038f <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8003ac:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8003b3:	00 00 00 
		judge_time_for_space = 0;
  8003b6:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8003bd:	00 00 00 
	}
}
  8003c0:	e9 2e 01 00 00       	jmp    8004f3 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003d9:	83 fa 00             	cmp    $0x0,%edx
  8003dc:	0f 87 ba 00 00 00    	ja     80049c <printnum+0x1bc>
  8003e2:	3b 45 10             	cmp    0x10(%ebp),%eax
  8003e5:	0f 83 b1 00 00 00    	jae    80049c <printnum+0x1bc>
  8003eb:	e9 2d ff ff ff       	jmp    80031d <printnum+0x3d>
  8003f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800404:	83 fa 00             	cmp    $0x0,%edx
  800407:	77 37                	ja     800440 <printnum+0x160>
  800409:	3b 45 10             	cmp    0x10(%ebp),%eax
  80040c:	73 32                	jae    800440 <printnum+0x160>
  80040e:	e9 16 ff ff ff       	jmp    800329 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	56                   	push   %esi
  800417:	83 ec 04             	sub    $0x4,%esp
  80041a:	ff 75 dc             	pushl  -0x24(%ebp)
  80041d:	ff 75 d8             	pushl  -0x28(%ebp)
  800420:	ff 75 e4             	pushl  -0x1c(%ebp)
  800423:	ff 75 e0             	pushl  -0x20(%ebp)
  800426:	e8 f5 0b 00 00       	call   801020 <__umoddi3>
  80042b:	83 c4 14             	add    $0x14,%esp
  80042e:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800435:	50                   	push   %eax
  800436:	ff d7                	call   *%edi
  800438:	83 c4 10             	add    $0x10,%esp
  80043b:	e9 b3 00 00 00       	jmp    8004f3 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800440:	83 ec 0c             	sub    $0xc,%esp
  800443:	ff 75 18             	pushl  0x18(%ebp)
  800446:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800449:	50                   	push   %eax
  80044a:	ff 75 10             	pushl  0x10(%ebp)
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	ff 75 dc             	pushl  -0x24(%ebp)
  800453:	ff 75 d8             	pushl  -0x28(%ebp)
  800456:	ff 75 e4             	pushl  -0x1c(%ebp)
  800459:	ff 75 e0             	pushl  -0x20(%ebp)
  80045c:	e8 8f 0a 00 00       	call   800ef0 <__udivdi3>
  800461:	83 c4 18             	add    $0x18,%esp
  800464:	52                   	push   %edx
  800465:	50                   	push   %eax
  800466:	89 f2                	mov    %esi,%edx
  800468:	89 f8                	mov    %edi,%eax
  80046a:	e8 71 fe ff ff       	call   8002e0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046f:	83 c4 18             	add    $0x18,%esp
  800472:	56                   	push   %esi
  800473:	83 ec 04             	sub    $0x4,%esp
  800476:	ff 75 dc             	pushl  -0x24(%ebp)
  800479:	ff 75 d8             	pushl  -0x28(%ebp)
  80047c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047f:	ff 75 e0             	pushl  -0x20(%ebp)
  800482:	e8 99 0b 00 00       	call   801020 <__umoddi3>
  800487:	83 c4 14             	add    $0x14,%esp
  80048a:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800491:	50                   	push   %eax
  800492:	ff d7                	call   *%edi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	e9 d5 fe ff ff       	jmp    800371 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80049c:	83 ec 0c             	sub    $0xc,%esp
  80049f:	ff 75 18             	pushl  0x18(%ebp)
  8004a2:	83 eb 01             	sub    $0x1,%ebx
  8004a5:	53                   	push   %ebx
  8004a6:	ff 75 10             	pushl  0x10(%ebp)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8004af:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b8:	e8 33 0a 00 00       	call   800ef0 <__udivdi3>
  8004bd:	83 c4 18             	add    $0x18,%esp
  8004c0:	52                   	push   %edx
  8004c1:	50                   	push   %eax
  8004c2:	89 f2                	mov    %esi,%edx
  8004c4:	89 f8                	mov    %edi,%eax
  8004c6:	e8 15 fe ff ff       	call   8002e0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004cb:	83 c4 18             	add    $0x18,%esp
  8004ce:	56                   	push   %esi
  8004cf:	83 ec 04             	sub    $0x4,%esp
  8004d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004db:	ff 75 e0             	pushl  -0x20(%ebp)
  8004de:	e8 3d 0b 00 00       	call   801020 <__umoddi3>
  8004e3:	83 c4 14             	add    $0x14,%esp
  8004e6:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  8004ed:	50                   	push   %eax
  8004ee:	ff d7                	call   *%edi
  8004f0:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8004f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5f                   	pop    %edi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004fe:	83 fa 01             	cmp    $0x1,%edx
  800501:	7e 0e                	jle    800511 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800503:	8b 10                	mov    (%eax),%edx
  800505:	8d 4a 08             	lea    0x8(%edx),%ecx
  800508:	89 08                	mov    %ecx,(%eax)
  80050a:	8b 02                	mov    (%edx),%eax
  80050c:	8b 52 04             	mov    0x4(%edx),%edx
  80050f:	eb 22                	jmp    800533 <getuint+0x38>
	else if (lflag)
  800511:	85 d2                	test   %edx,%edx
  800513:	74 10                	je     800525 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800515:	8b 10                	mov    (%eax),%edx
  800517:	8d 4a 04             	lea    0x4(%edx),%ecx
  80051a:	89 08                	mov    %ecx,(%eax)
  80051c:	8b 02                	mov    (%edx),%eax
  80051e:	ba 00 00 00 00       	mov    $0x0,%edx
  800523:	eb 0e                	jmp    800533 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800525:	8b 10                	mov    (%eax),%edx
  800527:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052a:	89 08                	mov    %ecx,(%eax)
  80052c:	8b 02                	mov    (%edx),%eax
  80052e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    

00800535 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80053b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80053f:	8b 10                	mov    (%eax),%edx
  800541:	3b 50 04             	cmp    0x4(%eax),%edx
  800544:	73 0a                	jae    800550 <sprintputch+0x1b>
		*b->buf++ = ch;
  800546:	8d 4a 01             	lea    0x1(%edx),%ecx
  800549:	89 08                	mov    %ecx,(%eax)
  80054b:	8b 45 08             	mov    0x8(%ebp),%eax
  80054e:	88 02                	mov    %al,(%edx)
}
  800550:	5d                   	pop    %ebp
  800551:	c3                   	ret    

00800552 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800558:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80055b:	50                   	push   %eax
  80055c:	ff 75 10             	pushl  0x10(%ebp)
  80055f:	ff 75 0c             	pushl  0xc(%ebp)
  800562:	ff 75 08             	pushl  0x8(%ebp)
  800565:	e8 05 00 00 00       	call   80056f <vprintfmt>
	va_end(ap);
}
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	c9                   	leave  
  80056e:	c3                   	ret    

0080056f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	57                   	push   %edi
  800573:	56                   	push   %esi
  800574:	53                   	push   %ebx
  800575:	83 ec 2c             	sub    $0x2c,%esp
  800578:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057e:	eb 03                	jmp    800583 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800580:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800583:	8b 45 10             	mov    0x10(%ebp),%eax
  800586:	8d 70 01             	lea    0x1(%eax),%esi
  800589:	0f b6 00             	movzbl (%eax),%eax
  80058c:	83 f8 25             	cmp    $0x25,%eax
  80058f:	74 27                	je     8005b8 <vprintfmt+0x49>
			if (ch == '\0')
  800591:	85 c0                	test   %eax,%eax
  800593:	75 0d                	jne    8005a2 <vprintfmt+0x33>
  800595:	e9 9d 04 00 00       	jmp    800a37 <vprintfmt+0x4c8>
  80059a:	85 c0                	test   %eax,%eax
  80059c:	0f 84 95 04 00 00    	je     800a37 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	53                   	push   %ebx
  8005a6:	50                   	push   %eax
  8005a7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a9:	83 c6 01             	add    $0x1,%esi
  8005ac:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	83 f8 25             	cmp    $0x25,%eax
  8005b6:	75 e2                	jne    80059a <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bd:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8005c1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005c8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005cf:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005d6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8005dd:	eb 08                	jmp    8005e7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8005e2:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8d 46 01             	lea    0x1(%esi),%eax
  8005ea:	89 45 10             	mov    %eax,0x10(%ebp)
  8005ed:	0f b6 06             	movzbl (%esi),%eax
  8005f0:	0f b6 d0             	movzbl %al,%edx
  8005f3:	83 e8 23             	sub    $0x23,%eax
  8005f6:	3c 55                	cmp    $0x55,%al
  8005f8:	0f 87 fa 03 00 00    	ja     8009f8 <vprintfmt+0x489>
  8005fe:	0f b6 c0             	movzbl %al,%eax
  800601:	ff 24 85 dc 12 80 00 	jmp    *0x8012dc(,%eax,4)
  800608:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80060b:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80060f:	eb d6                	jmp    8005e7 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800611:	8d 42 d0             	lea    -0x30(%edx),%eax
  800614:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800617:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80061b:	8d 50 d0             	lea    -0x30(%eax),%edx
  80061e:	83 fa 09             	cmp    $0x9,%edx
  800621:	77 6b                	ja     80068e <vprintfmt+0x11f>
  800623:	8b 75 10             	mov    0x10(%ebp),%esi
  800626:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800629:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80062c:	eb 09                	jmp    800637 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800631:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800635:	eb b0                	jmp    8005e7 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800637:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80063a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80063d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800641:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800644:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800647:	83 f9 09             	cmp    $0x9,%ecx
  80064a:	76 eb                	jbe    800637 <vprintfmt+0xc8>
  80064c:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80064f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800652:	eb 3d                	jmp    800691 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800665:	eb 2a                	jmp    800691 <vprintfmt+0x122>
  800667:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80066a:	85 c0                	test   %eax,%eax
  80066c:	ba 00 00 00 00       	mov    $0x0,%edx
  800671:	0f 49 d0             	cmovns %eax,%edx
  800674:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 75 10             	mov    0x10(%ebp),%esi
  80067a:	e9 68 ff ff ff       	jmp    8005e7 <vprintfmt+0x78>
  80067f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800682:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800689:	e9 59 ff ff ff       	jmp    8005e7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800691:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800695:	0f 89 4c ff ff ff    	jns    8005e7 <vprintfmt+0x78>
				width = precision, precision = -1;
  80069b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80069e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006a8:	e9 3a ff ff ff       	jmp    8005e7 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006ad:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006b4:	e9 2e ff ff ff       	jmp    8005e7 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8d 50 04             	lea    0x4(%eax),%edx
  8006bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	ff 30                	pushl  (%eax)
  8006c8:	ff d7                	call   *%edi
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	e9 b1 fe ff ff       	jmp    800583 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	99                   	cltd   
  8006de:	31 d0                	xor    %edx,%eax
  8006e0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e2:	83 f8 06             	cmp    $0x6,%eax
  8006e5:	7f 0b                	jg     8006f2 <vprintfmt+0x183>
  8006e7:	8b 14 85 34 14 80 00 	mov    0x801434(,%eax,4),%edx
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	75 15                	jne    800707 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8006f2:	50                   	push   %eax
  8006f3:	68 eb 11 80 00       	push   $0x8011eb
  8006f8:	53                   	push   %ebx
  8006f9:	57                   	push   %edi
  8006fa:	e8 53 fe ff ff       	call   800552 <printfmt>
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	e9 7c fe ff ff       	jmp    800583 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800707:	52                   	push   %edx
  800708:	68 f4 11 80 00       	push   $0x8011f4
  80070d:	53                   	push   %ebx
  80070e:	57                   	push   %edi
  80070f:	e8 3e fe ff ff       	call   800552 <printfmt>
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	e9 67 fe ff ff       	jmp    800583 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 50 04             	lea    0x4(%eax),%edx
  800722:	89 55 14             	mov    %edx,0x14(%ebp)
  800725:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800727:	85 c0                	test   %eax,%eax
  800729:	b9 e4 11 80 00       	mov    $0x8011e4,%ecx
  80072e:	0f 45 c8             	cmovne %eax,%ecx
  800731:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800734:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800738:	7e 06                	jle    800740 <vprintfmt+0x1d1>
  80073a:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80073e:	75 19                	jne    800759 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800740:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800743:	8d 70 01             	lea    0x1(%eax),%esi
  800746:	0f b6 00             	movzbl (%eax),%eax
  800749:	0f be d0             	movsbl %al,%edx
  80074c:	85 d2                	test   %edx,%edx
  80074e:	0f 85 9f 00 00 00    	jne    8007f3 <vprintfmt+0x284>
  800754:	e9 8c 00 00 00       	jmp    8007e5 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	ff 75 d0             	pushl  -0x30(%ebp)
  80075f:	ff 75 cc             	pushl  -0x34(%ebp)
  800762:	e8 62 03 00 00       	call   800ac9 <strnlen>
  800767:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80076a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	85 c9                	test   %ecx,%ecx
  800772:	0f 8e a6 02 00 00    	jle    800a1e <vprintfmt+0x4af>
					putch(padc, putdat);
  800778:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80077c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077f:	89 cb                	mov    %ecx,%ebx
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	ff 75 0c             	pushl  0xc(%ebp)
  800787:	56                   	push   %esi
  800788:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	83 eb 01             	sub    $0x1,%ebx
  800790:	75 ef                	jne    800781 <vprintfmt+0x212>
  800792:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800795:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800798:	e9 81 02 00 00       	jmp    800a1e <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80079d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007a1:	74 1b                	je     8007be <vprintfmt+0x24f>
  8007a3:	0f be c0             	movsbl %al,%eax
  8007a6:	83 e8 20             	sub    $0x20,%eax
  8007a9:	83 f8 5e             	cmp    $0x5e,%eax
  8007ac:	76 10                	jbe    8007be <vprintfmt+0x24f>
					putch('?', putdat);
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	ff 75 0c             	pushl  0xc(%ebp)
  8007b4:	6a 3f                	push   $0x3f
  8007b6:	ff 55 08             	call   *0x8(%ebp)
  8007b9:	83 c4 10             	add    $0x10,%esp
  8007bc:	eb 0d                	jmp    8007cb <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	52                   	push   %edx
  8007c5:	ff 55 08             	call   *0x8(%ebp)
  8007c8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cb:	83 ef 01             	sub    $0x1,%edi
  8007ce:	83 c6 01             	add    $0x1,%esi
  8007d1:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007d5:	0f be d0             	movsbl %al,%edx
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	75 31                	jne    80080d <vprintfmt+0x29e>
  8007dc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ec:	7f 33                	jg     800821 <vprintfmt+0x2b2>
  8007ee:	e9 90 fd ff ff       	jmp    800583 <vprintfmt+0x14>
  8007f3:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007fc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007ff:	eb 0c                	jmp    80080d <vprintfmt+0x29e>
  800801:	89 7d 08             	mov    %edi,0x8(%ebp)
  800804:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800807:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80080a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080d:	85 db                	test   %ebx,%ebx
  80080f:	78 8c                	js     80079d <vprintfmt+0x22e>
  800811:	83 eb 01             	sub    $0x1,%ebx
  800814:	79 87                	jns    80079d <vprintfmt+0x22e>
  800816:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800819:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80081f:	eb c4                	jmp    8007e5 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800821:	83 ec 08             	sub    $0x8,%esp
  800824:	53                   	push   %ebx
  800825:	6a 20                	push   $0x20
  800827:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	83 ee 01             	sub    $0x1,%esi
  80082f:	75 f0                	jne    800821 <vprintfmt+0x2b2>
  800831:	e9 4d fd ff ff       	jmp    800583 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800836:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80083a:	7e 16                	jle    800852 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 08             	lea    0x8(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 50 04             	mov    0x4(%eax),%edx
  800848:	8b 00                	mov    (%eax),%eax
  80084a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80084d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800850:	eb 34                	jmp    800886 <vprintfmt+0x317>
	else if (lflag)
  800852:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800856:	74 18                	je     800870 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8d 50 04             	lea    0x4(%eax),%edx
  80085e:	89 55 14             	mov    %edx,0x14(%ebp)
  800861:	8b 30                	mov    (%eax),%esi
  800863:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800866:	89 f0                	mov    %esi,%eax
  800868:	c1 f8 1f             	sar    $0x1f,%eax
  80086b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80086e:	eb 16                	jmp    800886 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8d 50 04             	lea    0x4(%eax),%edx
  800876:	89 55 14             	mov    %edx,0x14(%ebp)
  800879:	8b 30                	mov    (%eax),%esi
  80087b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80087e:	89 f0                	mov    %esi,%eax
  800880:	c1 f8 1f             	sar    $0x1f,%eax
  800883:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800886:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800889:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80088c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	79 28                	jns    8008be <vprintfmt+0x34f>
				putch('-', putdat);
  800896:	83 ec 08             	sub    $0x8,%esp
  800899:	53                   	push   %ebx
  80089a:	6a 2d                	push   $0x2d
  80089c:	ff d7                	call   *%edi
				num = -(long long) num;
  80089e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008a4:	f7 d8                	neg    %eax
  8008a6:	83 d2 00             	adc    $0x0,%edx
  8008a9:	f7 da                	neg    %edx
  8008ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b1:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8008b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008b9:	e9 b2 00 00 00       	jmp    800970 <vprintfmt+0x401>
  8008be:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8008c3:	85 c9                	test   %ecx,%ecx
  8008c5:	0f 84 a5 00 00 00    	je     800970 <vprintfmt+0x401>
				putch('+', putdat);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	6a 2b                	push   $0x2b
  8008d1:	ff d7                	call   *%edi
  8008d3:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8008d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008db:	e9 90 00 00 00       	jmp    800970 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8008e0:	85 c9                	test   %ecx,%ecx
  8008e2:	74 0b                	je     8008ef <vprintfmt+0x380>
				putch('+', putdat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	53                   	push   %ebx
  8008e8:	6a 2b                	push   $0x2b
  8008ea:	ff d7                	call   *%edi
  8008ec:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8008ef:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f5:	e8 01 fc ff ff       	call   8004fb <getuint>
  8008fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800900:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800905:	eb 69                	jmp    800970 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	53                   	push   %ebx
  80090b:	6a 30                	push   $0x30
  80090d:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80090f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800912:	8d 45 14             	lea    0x14(%ebp),%eax
  800915:	e8 e1 fb ff ff       	call   8004fb <getuint>
  80091a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80091d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800920:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800923:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800928:	eb 46                	jmp    800970 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  80092a:	83 ec 08             	sub    $0x8,%esp
  80092d:	53                   	push   %ebx
  80092e:	6a 30                	push   $0x30
  800930:	ff d7                	call   *%edi
			putch('x', putdat);
  800932:	83 c4 08             	add    $0x8,%esp
  800935:	53                   	push   %ebx
  800936:	6a 78                	push   $0x78
  800938:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8d 50 04             	lea    0x4(%eax),%edx
  800940:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800943:	8b 00                	mov    (%eax),%eax
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
  80094a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80094d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800950:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800953:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800958:	eb 16                	jmp    800970 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80095a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80095d:	8d 45 14             	lea    0x14(%ebp),%eax
  800960:	e8 96 fb ff ff       	call   8004fb <getuint>
  800965:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800968:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80096b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800970:	83 ec 0c             	sub    $0xc,%esp
  800973:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800977:	56                   	push   %esi
  800978:	ff 75 e4             	pushl  -0x1c(%ebp)
  80097b:	50                   	push   %eax
  80097c:	ff 75 dc             	pushl  -0x24(%ebp)
  80097f:	ff 75 d8             	pushl  -0x28(%ebp)
  800982:	89 da                	mov    %ebx,%edx
  800984:	89 f8                	mov    %edi,%eax
  800986:	e8 55 f9 ff ff       	call   8002e0 <printnum>
			break;
  80098b:	83 c4 20             	add    $0x20,%esp
  80098e:	e9 f0 fb ff ff       	jmp    800583 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	8d 50 04             	lea    0x4(%eax),%edx
  800999:	89 55 14             	mov    %edx,0x14(%ebp)
  80099c:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  80099e:	85 f6                	test   %esi,%esi
  8009a0:	75 1a                	jne    8009bc <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	68 60 12 80 00       	push   $0x801260
  8009aa:	68 f4 11 80 00       	push   $0x8011f4
  8009af:	e8 18 f9 ff ff       	call   8002cc <cprintf>
  8009b4:	83 c4 10             	add    $0x10,%esp
  8009b7:	e9 c7 fb ff ff       	jmp    800583 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8009bc:	0f b6 03             	movzbl (%ebx),%eax
  8009bf:	84 c0                	test   %al,%al
  8009c1:	79 1f                	jns    8009e2 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8009c3:	83 ec 08             	sub    $0x8,%esp
  8009c6:	68 98 12 80 00       	push   $0x801298
  8009cb:	68 f4 11 80 00       	push   $0x8011f4
  8009d0:	e8 f7 f8 ff ff       	call   8002cc <cprintf>
						*tmp = *(char *)putdat;
  8009d5:	0f b6 03             	movzbl (%ebx),%eax
  8009d8:	88 06                	mov    %al,(%esi)
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	e9 a1 fb ff ff       	jmp    800583 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8009e2:	88 06                	mov    %al,(%esi)
  8009e4:	e9 9a fb ff ff       	jmp    800583 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009e9:	83 ec 08             	sub    $0x8,%esp
  8009ec:	53                   	push   %ebx
  8009ed:	52                   	push   %edx
  8009ee:	ff d7                	call   *%edi
			break;
  8009f0:	83 c4 10             	add    $0x10,%esp
  8009f3:	e9 8b fb ff ff       	jmp    800583 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009f8:	83 ec 08             	sub    $0x8,%esp
  8009fb:	53                   	push   %ebx
  8009fc:	6a 25                	push   $0x25
  8009fe:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a07:	0f 84 73 fb ff ff    	je     800580 <vprintfmt+0x11>
  800a0d:	83 ee 01             	sub    $0x1,%esi
  800a10:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a14:	75 f7                	jne    800a0d <vprintfmt+0x49e>
  800a16:	89 75 10             	mov    %esi,0x10(%ebp)
  800a19:	e9 65 fb ff ff       	jmp    800583 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a21:	8d 70 01             	lea    0x1(%eax),%esi
  800a24:	0f b6 00             	movzbl (%eax),%eax
  800a27:	0f be d0             	movsbl %al,%edx
  800a2a:	85 d2                	test   %edx,%edx
  800a2c:	0f 85 cf fd ff ff    	jne    800801 <vprintfmt+0x292>
  800a32:	e9 4c fb ff ff       	jmp    800583 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	83 ec 18             	sub    $0x18,%esp
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a4e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a52:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a5c:	85 c0                	test   %eax,%eax
  800a5e:	74 26                	je     800a86 <vsnprintf+0x47>
  800a60:	85 d2                	test   %edx,%edx
  800a62:	7e 22                	jle    800a86 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a64:	ff 75 14             	pushl  0x14(%ebp)
  800a67:	ff 75 10             	pushl  0x10(%ebp)
  800a6a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a6d:	50                   	push   %eax
  800a6e:	68 35 05 80 00       	push   $0x800535
  800a73:	e8 f7 fa ff ff       	call   80056f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a7b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a81:	83 c4 10             	add    $0x10,%esp
  800a84:	eb 05                	jmp    800a8b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a93:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a96:	50                   	push   %eax
  800a97:	ff 75 10             	pushl  0x10(%ebp)
  800a9a:	ff 75 0c             	pushl  0xc(%ebp)
  800a9d:	ff 75 08             	pushl  0x8(%ebp)
  800aa0:	e8 9a ff ff ff       	call   800a3f <vsnprintf>
	va_end(ap);

	return rc;
}
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aad:	80 3a 00             	cmpb   $0x0,(%edx)
  800ab0:	74 10                	je     800ac2 <strlen+0x1b>
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ab7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800abe:	75 f7                	jne    800ab7 <strlen+0x10>
  800ac0:	eb 05                	jmp    800ac7 <strlen+0x20>
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	53                   	push   %ebx
  800acd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	74 1c                	je     800af3 <strnlen+0x2a>
  800ad7:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ada:	74 1e                	je     800afa <strnlen+0x31>
  800adc:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800ae1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae3:	39 ca                	cmp    %ecx,%edx
  800ae5:	74 18                	je     800aff <strnlen+0x36>
  800ae7:	83 c2 01             	add    $0x1,%edx
  800aea:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800aef:	75 f0                	jne    800ae1 <strnlen+0x18>
  800af1:	eb 0c                	jmp    800aff <strnlen+0x36>
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	eb 05                	jmp    800aff <strnlen+0x36>
  800afa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800aff:	5b                   	pop    %ebx
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	53                   	push   %ebx
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b0c:	89 c2                	mov    %eax,%edx
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	83 c1 01             	add    $0x1,%ecx
  800b14:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b18:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1b:	84 db                	test   %bl,%bl
  800b1d:	75 ef                	jne    800b0e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b29:	53                   	push   %ebx
  800b2a:	e8 78 ff ff ff       	call   800aa7 <strlen>
  800b2f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b32:	ff 75 0c             	pushl  0xc(%ebp)
  800b35:	01 d8                	add    %ebx,%eax
  800b37:	50                   	push   %eax
  800b38:	e8 c5 ff ff ff       	call   800b02 <strcpy>
	return dst;
}
  800b3d:	89 d8                	mov    %ebx,%eax
  800b3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 75 08             	mov    0x8(%ebp),%esi
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b52:	85 db                	test   %ebx,%ebx
  800b54:	74 17                	je     800b6d <strncpy+0x29>
  800b56:	01 f3                	add    %esi,%ebx
  800b58:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b5a:	83 c1 01             	add    $0x1,%ecx
  800b5d:	0f b6 02             	movzbl (%edx),%eax
  800b60:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b63:	80 3a 01             	cmpb   $0x1,(%edx)
  800b66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b69:	39 cb                	cmp    %ecx,%ebx
  800b6b:	75 ed                	jne    800b5a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b7e:	8b 55 10             	mov    0x10(%ebp),%edx
  800b81:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b83:	85 d2                	test   %edx,%edx
  800b85:	74 35                	je     800bbc <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	83 e8 01             	sub    $0x1,%eax
  800b8c:	74 25                	je     800bb3 <strlcpy+0x40>
  800b8e:	0f b6 0b             	movzbl (%ebx),%ecx
  800b91:	84 c9                	test   %cl,%cl
  800b93:	74 22                	je     800bb7 <strlcpy+0x44>
  800b95:	8d 53 01             	lea    0x1(%ebx),%edx
  800b98:	01 c3                	add    %eax,%ebx
  800b9a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800b9c:	83 c0 01             	add    $0x1,%eax
  800b9f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba2:	39 da                	cmp    %ebx,%edx
  800ba4:	74 13                	je     800bb9 <strlcpy+0x46>
  800ba6:	83 c2 01             	add    $0x1,%edx
  800ba9:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800bad:	84 c9                	test   %cl,%cl
  800baf:	75 eb                	jne    800b9c <strlcpy+0x29>
  800bb1:	eb 06                	jmp    800bb9 <strlcpy+0x46>
  800bb3:	89 f0                	mov    %esi,%eax
  800bb5:	eb 02                	jmp    800bb9 <strlcpy+0x46>
  800bb7:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bb9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bbc:	29 f0                	sub    %esi,%eax
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bcb:	0f b6 01             	movzbl (%ecx),%eax
  800bce:	84 c0                	test   %al,%al
  800bd0:	74 15                	je     800be7 <strcmp+0x25>
  800bd2:	3a 02                	cmp    (%edx),%al
  800bd4:	75 11                	jne    800be7 <strcmp+0x25>
		p++, q++;
  800bd6:	83 c1 01             	add    $0x1,%ecx
  800bd9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bdc:	0f b6 01             	movzbl (%ecx),%eax
  800bdf:	84 c0                	test   %al,%al
  800be1:	74 04                	je     800be7 <strcmp+0x25>
  800be3:	3a 02                	cmp    (%edx),%al
  800be5:	74 ef                	je     800bd6 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800be7:	0f b6 c0             	movzbl %al,%eax
  800bea:	0f b6 12             	movzbl (%edx),%edx
  800bed:	29 d0                	sub    %edx,%eax
}
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfc:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800bff:	85 f6                	test   %esi,%esi
  800c01:	74 29                	je     800c2c <strncmp+0x3b>
  800c03:	0f b6 03             	movzbl (%ebx),%eax
  800c06:	84 c0                	test   %al,%al
  800c08:	74 30                	je     800c3a <strncmp+0x49>
  800c0a:	3a 02                	cmp    (%edx),%al
  800c0c:	75 2c                	jne    800c3a <strncmp+0x49>
  800c0e:	8d 43 01             	lea    0x1(%ebx),%eax
  800c11:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c13:	89 c3                	mov    %eax,%ebx
  800c15:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c18:	39 c6                	cmp    %eax,%esi
  800c1a:	74 17                	je     800c33 <strncmp+0x42>
  800c1c:	0f b6 08             	movzbl (%eax),%ecx
  800c1f:	84 c9                	test   %cl,%cl
  800c21:	74 17                	je     800c3a <strncmp+0x49>
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	3a 0a                	cmp    (%edx),%cl
  800c28:	74 e9                	je     800c13 <strncmp+0x22>
  800c2a:	eb 0e                	jmp    800c3a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c31:	eb 0f                	jmp    800c42 <strncmp+0x51>
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
  800c38:	eb 08                	jmp    800c42 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c3a:	0f b6 03             	movzbl (%ebx),%eax
  800c3d:	0f b6 12             	movzbl (%edx),%edx
  800c40:	29 d0                	sub    %edx,%eax
}
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	53                   	push   %ebx
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c50:	0f b6 10             	movzbl (%eax),%edx
  800c53:	84 d2                	test   %dl,%dl
  800c55:	74 1d                	je     800c74 <strchr+0x2e>
  800c57:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800c59:	38 d3                	cmp    %dl,%bl
  800c5b:	75 06                	jne    800c63 <strchr+0x1d>
  800c5d:	eb 1a                	jmp    800c79 <strchr+0x33>
  800c5f:	38 ca                	cmp    %cl,%dl
  800c61:	74 16                	je     800c79 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c63:	83 c0 01             	add    $0x1,%eax
  800c66:	0f b6 10             	movzbl (%eax),%edx
  800c69:	84 d2                	test   %dl,%dl
  800c6b:	75 f2                	jne    800c5f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800c6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c72:	eb 05                	jmp    800c79 <strchr+0x33>
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	53                   	push   %ebx
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c86:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c89:	38 d3                	cmp    %dl,%bl
  800c8b:	74 14                	je     800ca1 <strfind+0x25>
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	84 db                	test   %bl,%bl
  800c91:	74 0e                	je     800ca1 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c93:	83 c0 01             	add    $0x1,%eax
  800c96:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c99:	38 ca                	cmp    %cl,%dl
  800c9b:	74 04                	je     800ca1 <strfind+0x25>
  800c9d:	84 d2                	test   %dl,%dl
  800c9f:	75 f2                	jne    800c93 <strfind+0x17>
			break;
	return (char *) s;
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb0:	85 c9                	test   %ecx,%ecx
  800cb2:	74 36                	je     800cea <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cba:	75 28                	jne    800ce4 <memset+0x40>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 23                	jne    800ce4 <memset+0x40>
		c &= 0xFF;
  800cc1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc5:	89 d3                	mov    %edx,%ebx
  800cc7:	c1 e3 08             	shl    $0x8,%ebx
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	c1 e6 18             	shl    $0x18,%esi
  800ccf:	89 d0                	mov    %edx,%eax
  800cd1:	c1 e0 10             	shl    $0x10,%eax
  800cd4:	09 f0                	or     %esi,%eax
  800cd6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cd8:	89 d8                	mov    %ebx,%eax
  800cda:	09 d0                	or     %edx,%eax
  800cdc:	c1 e9 02             	shr    $0x2,%ecx
  800cdf:	fc                   	cld    
  800ce0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ce2:	eb 06                	jmp    800cea <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce7:	fc                   	cld    
  800ce8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cea:	89 f8                	mov    %edi,%eax
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cff:	39 c6                	cmp    %eax,%esi
  800d01:	73 35                	jae    800d38 <memmove+0x47>
  800d03:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d06:	39 d0                	cmp    %edx,%eax
  800d08:	73 2e                	jae    800d38 <memmove+0x47>
		s += n;
		d += n;
  800d0a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	09 fe                	or     %edi,%esi
  800d11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d17:	75 13                	jne    800d2c <memmove+0x3b>
  800d19:	f6 c1 03             	test   $0x3,%cl
  800d1c:	75 0e                	jne    800d2c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d1e:	83 ef 04             	sub    $0x4,%edi
  800d21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d24:	c1 e9 02             	shr    $0x2,%ecx
  800d27:	fd                   	std    
  800d28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2a:	eb 09                	jmp    800d35 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d2c:	83 ef 01             	sub    $0x1,%edi
  800d2f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d32:	fd                   	std    
  800d33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d35:	fc                   	cld    
  800d36:	eb 1d                	jmp    800d55 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	09 c2                	or     %eax,%edx
  800d3c:	f6 c2 03             	test   $0x3,%dl
  800d3f:	75 0f                	jne    800d50 <memmove+0x5f>
  800d41:	f6 c1 03             	test   $0x3,%cl
  800d44:	75 0a                	jne    800d50 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d46:	c1 e9 02             	shr    $0x2,%ecx
  800d49:	89 c7                	mov    %eax,%edi
  800d4b:	fc                   	cld    
  800d4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d4e:	eb 05                	jmp    800d55 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d50:	89 c7                	mov    %eax,%edi
  800d52:	fc                   	cld    
  800d53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d5c:	ff 75 10             	pushl  0x10(%ebp)
  800d5f:	ff 75 0c             	pushl  0xc(%ebp)
  800d62:	ff 75 08             	pushl  0x8(%ebp)
  800d65:	e8 87 ff ff ff       	call   800cf1 <memmove>
}
  800d6a:	c9                   	leave  
  800d6b:	c3                   	ret    

00800d6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d78:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	74 39                	je     800db8 <memcmp+0x4c>
  800d7f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800d82:	0f b6 13             	movzbl (%ebx),%edx
  800d85:	0f b6 0e             	movzbl (%esi),%ecx
  800d88:	38 ca                	cmp    %cl,%dl
  800d8a:	75 17                	jne    800da3 <memcmp+0x37>
  800d8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d91:	eb 1a                	jmp    800dad <memcmp+0x41>
  800d93:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800d98:	83 c0 01             	add    $0x1,%eax
  800d9b:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800d9f:	38 ca                	cmp    %cl,%dl
  800da1:	74 0a                	je     800dad <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800da3:	0f b6 c2             	movzbl %dl,%eax
  800da6:	0f b6 c9             	movzbl %cl,%ecx
  800da9:	29 c8                	sub    %ecx,%eax
  800dab:	eb 10                	jmp    800dbd <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dad:	39 f8                	cmp    %edi,%eax
  800daf:	75 e2                	jne    800d93 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800db1:	b8 00 00 00 00       	mov    $0x0,%eax
  800db6:	eb 05                	jmp    800dbd <memcmp+0x51>
  800db8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	53                   	push   %ebx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800dc9:	89 d0                	mov    %edx,%eax
  800dcb:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800dce:	39 c2                	cmp    %eax,%edx
  800dd0:	73 1d                	jae    800def <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dd2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800dd6:	0f b6 0a             	movzbl (%edx),%ecx
  800dd9:	39 d9                	cmp    %ebx,%ecx
  800ddb:	75 09                	jne    800de6 <memfind+0x24>
  800ddd:	eb 14                	jmp    800df3 <memfind+0x31>
  800ddf:	0f b6 0a             	movzbl (%edx),%ecx
  800de2:	39 d9                	cmp    %ebx,%ecx
  800de4:	74 11                	je     800df7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800de6:	83 c2 01             	add    $0x1,%edx
  800de9:	39 d0                	cmp    %edx,%eax
  800deb:	75 f2                	jne    800ddf <memfind+0x1d>
  800ded:	eb 0a                	jmp    800df9 <memfind+0x37>
  800def:	89 d0                	mov    %edx,%eax
  800df1:	eb 06                	jmp    800df9 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df3:	89 d0                	mov    %edx,%eax
  800df5:	eb 02                	jmp    800df9 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800df7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800df9:	5b                   	pop    %ebx
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e08:	0f b6 01             	movzbl (%ecx),%eax
  800e0b:	3c 20                	cmp    $0x20,%al
  800e0d:	74 04                	je     800e13 <strtol+0x17>
  800e0f:	3c 09                	cmp    $0x9,%al
  800e11:	75 0e                	jne    800e21 <strtol+0x25>
		s++;
  800e13:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e16:	0f b6 01             	movzbl (%ecx),%eax
  800e19:	3c 20                	cmp    $0x20,%al
  800e1b:	74 f6                	je     800e13 <strtol+0x17>
  800e1d:	3c 09                	cmp    $0x9,%al
  800e1f:	74 f2                	je     800e13 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e21:	3c 2b                	cmp    $0x2b,%al
  800e23:	75 0a                	jne    800e2f <strtol+0x33>
		s++;
  800e25:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e28:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2d:	eb 11                	jmp    800e40 <strtol+0x44>
  800e2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e34:	3c 2d                	cmp    $0x2d,%al
  800e36:	75 08                	jne    800e40 <strtol+0x44>
		s++, neg = 1;
  800e38:	83 c1 01             	add    $0x1,%ecx
  800e3b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e46:	75 15                	jne    800e5d <strtol+0x61>
  800e48:	80 39 30             	cmpb   $0x30,(%ecx)
  800e4b:	75 10                	jne    800e5d <strtol+0x61>
  800e4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e51:	75 7c                	jne    800ecf <strtol+0xd3>
		s += 2, base = 16;
  800e53:	83 c1 02             	add    $0x2,%ecx
  800e56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e5b:	eb 16                	jmp    800e73 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e5d:	85 db                	test   %ebx,%ebx
  800e5f:	75 12                	jne    800e73 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e61:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e66:	80 39 30             	cmpb   $0x30,(%ecx)
  800e69:	75 08                	jne    800e73 <strtol+0x77>
		s++, base = 8;
  800e6b:	83 c1 01             	add    $0x1,%ecx
  800e6e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e73:	b8 00 00 00 00       	mov    $0x0,%eax
  800e78:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e7b:	0f b6 11             	movzbl (%ecx),%edx
  800e7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e81:	89 f3                	mov    %esi,%ebx
  800e83:	80 fb 09             	cmp    $0x9,%bl
  800e86:	77 08                	ja     800e90 <strtol+0x94>
			dig = *s - '0';
  800e88:	0f be d2             	movsbl %dl,%edx
  800e8b:	83 ea 30             	sub    $0x30,%edx
  800e8e:	eb 22                	jmp    800eb2 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800e90:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e93:	89 f3                	mov    %esi,%ebx
  800e95:	80 fb 19             	cmp    $0x19,%bl
  800e98:	77 08                	ja     800ea2 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800e9a:	0f be d2             	movsbl %dl,%edx
  800e9d:	83 ea 57             	sub    $0x57,%edx
  800ea0:	eb 10                	jmp    800eb2 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800ea2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ea5:	89 f3                	mov    %esi,%ebx
  800ea7:	80 fb 19             	cmp    $0x19,%bl
  800eaa:	77 16                	ja     800ec2 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800eac:	0f be d2             	movsbl %dl,%edx
  800eaf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800eb2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800eb5:	7d 0b                	jge    800ec2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800eb7:	83 c1 01             	add    $0x1,%ecx
  800eba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ebe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ec0:	eb b9                	jmp    800e7b <strtol+0x7f>

	if (endptr)
  800ec2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec6:	74 0d                	je     800ed5 <strtol+0xd9>
		*endptr = (char *) s;
  800ec8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ecb:	89 0e                	mov    %ecx,(%esi)
  800ecd:	eb 06                	jmp    800ed5 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ecf:	85 db                	test   %ebx,%ebx
  800ed1:	74 98                	je     800e6b <strtol+0x6f>
  800ed3:	eb 9e                	jmp    800e73 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	f7 da                	neg    %edx
  800ed9:	85 ff                	test   %edi,%edi
  800edb:	0f 45 c2             	cmovne %edx,%eax
}
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
  800ee3:	66 90                	xchg   %ax,%ax
  800ee5:	66 90                	xchg   %ax,%ax
  800ee7:	66 90                	xchg   %ax,%ax
  800ee9:	66 90                	xchg   %ax,%ax
  800eeb:	66 90                	xchg   %ax,%ax
  800eed:	66 90                	xchg   %ax,%ax
  800eef:	90                   	nop

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
