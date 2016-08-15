
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800049:	e8 f9 00 00 00       	call   800147 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 64             	imul   $0x64,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 66 00 00 00       	call   8000f7 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	51                   	push   %ecx
  8000ab:	52                   	push   %edx
  8000ac:	53                   	push   %ebx
  8000ad:	54                   	push   %esp
  8000ae:	55                   	push   %ebp
  8000af:	56                   	push   %esi
  8000b0:	57                   	push   %edi
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	8d 35 bb 00 80 00    	lea    0x8000bb,%esi
  8000b9:	0f 34                	sysenter 

008000bb <label_21>:
  8000bb:	5f                   	pop    %edi
  8000bc:	5e                   	pop    %esi
  8000bd:	5d                   	pop    %ebp
  8000be:	5c                   	pop    %esp
  8000bf:	5b                   	pop    %ebx
  8000c0:	5a                   	pop    %edx
  8000c1:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 ca                	mov    %ecx,%edx
  8000d7:	89 cb                	mov    %ecx,%ebx
  8000d9:	89 cf                	mov    %ecx,%edi
  8000db:	51                   	push   %ecx
  8000dc:	52                   	push   %edx
  8000dd:	53                   	push   %ebx
  8000de:	54                   	push   %esp
  8000df:	55                   	push   %ebp
  8000e0:	56                   	push   %esi
  8000e1:	57                   	push   %edi
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	8d 35 ec 00 80 00    	lea    0x8000ec,%esi
  8000ea:	0f 34                	sysenter 

008000ec <label_55>:
  8000ec:	5f                   	pop    %edi
  8000ed:	5e                   	pop    %esi
  8000ee:	5d                   	pop    %ebp
  8000ef:	5c                   	pop    %esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5a                   	pop    %edx
  8000f2:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f3:	5b                   	pop    %ebx
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	89 d9                	mov    %ebx,%ecx
  80010b:	89 df                	mov    %ebx,%edi
  80010d:	51                   	push   %ecx
  80010e:	52                   	push   %edx
  80010f:	53                   	push   %ebx
  800110:	54                   	push   %esp
  800111:	55                   	push   %ebp
  800112:	56                   	push   %esi
  800113:	57                   	push   %edi
  800114:	89 e5                	mov    %esp,%ebp
  800116:	8d 35 1e 01 80 00    	lea    0x80011e,%esi
  80011c:	0f 34                	sysenter 

0080011e <label_90>:
  80011e:	5f                   	pop    %edi
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	5c                   	pop    %esp
  800122:	5b                   	pop    %ebx
  800123:	5a                   	pop    %edx
  800124:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800125:	85 c0                	test   %eax,%eax
  800127:	7e 17                	jle    800140 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	50                   	push   %eax
  80012d:	6a 03                	push   $0x3
  80012f:	68 7e 11 80 00       	push   $0x80117e
  800134:	6a 2a                	push   $0x2a
  800136:	68 9b 11 80 00       	push   $0x80119b
  80013b:	e8 9d 00 00 00       	call   8001dd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800140:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800143:	5b                   	pop    %ebx
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80014c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800151:	b8 02 00 00 00       	mov    $0x2,%eax
  800156:	89 ca                	mov    %ecx,%edx
  800158:	89 cb                	mov    %ecx,%ebx
  80015a:	89 cf                	mov    %ecx,%edi
  80015c:	51                   	push   %ecx
  80015d:	52                   	push   %edx
  80015e:	53                   	push   %ebx
  80015f:	54                   	push   %esp
  800160:	55                   	push   %ebp
  800161:	56                   	push   %esi
  800162:	57                   	push   %edi
  800163:	89 e5                	mov    %esp,%ebp
  800165:	8d 35 6d 01 80 00    	lea    0x80016d,%esi
  80016b:	0f 34                	sysenter 

0080016d <label_139>:
  80016d:	5f                   	pop    %edi
  80016e:	5e                   	pop    %esi
  80016f:	5d                   	pop    %ebp
  800170:	5c                   	pop    %esp
  800171:	5b                   	pop    %ebx
  800172:	5a                   	pop    %edx
  800173:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5f                   	pop    %edi
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80017d:	bf 00 00 00 00       	mov    $0x0,%edi
  800182:	b8 04 00 00 00       	mov    $0x4,%eax
  800187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018a:	8b 55 08             	mov    0x8(%ebp),%edx
  80018d:	89 fb                	mov    %edi,%ebx
  80018f:	51                   	push   %ecx
  800190:	52                   	push   %edx
  800191:	53                   	push   %ebx
  800192:	54                   	push   %esp
  800193:	55                   	push   %ebp
  800194:	56                   	push   %esi
  800195:	57                   	push   %edi
  800196:	89 e5                	mov    %esp,%ebp
  800198:	8d 35 a0 01 80 00    	lea    0x8001a0,%esi
  80019e:	0f 34                	sysenter 

008001a0 <label_174>:
  8001a0:	5f                   	pop    %edi
  8001a1:	5e                   	pop    %esi
  8001a2:	5d                   	pop    %ebp
  8001a3:	5c                   	pop    %esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5a                   	pop    %edx
  8001a6:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001a7:	5b                   	pop    %ebx
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	89 cb                	mov    %ecx,%ebx
  8001bf:	89 cf                	mov    %ecx,%edi
  8001c1:	51                   	push   %ecx
  8001c2:	52                   	push   %edx
  8001c3:	53                   	push   %ebx
  8001c4:	54                   	push   %esp
  8001c5:	55                   	push   %ebp
  8001c6:	56                   	push   %esi
  8001c7:	57                   	push   %edi
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	8d 35 d2 01 80 00    	lea    0x8001d2,%esi
  8001d0:	0f 34                	sysenter 

008001d2 <label_209>:
  8001d2:	5f                   	pop    %edi
  8001d3:	5e                   	pop    %esi
  8001d4:	5d                   	pop    %ebp
  8001d5:	5c                   	pop    %esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5a                   	pop    %edx
  8001d8:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001d9:	5b                   	pop    %ebx
  8001da:	5f                   	pop    %edi
  8001db:	5d                   	pop    %ebp
  8001dc:	c3                   	ret    

008001dd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001e5:	a1 10 20 80 00       	mov    0x802010,%eax
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	74 11                	je     8001ff <_panic+0x22>
		cprintf("%s: ", argv0);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	50                   	push   %eax
  8001f2:	68 a9 11 80 00       	push   $0x8011a9
  8001f7:	e8 d4 00 00 00       	call   8002d0 <cprintf>
  8001fc:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ff:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800205:	e8 3d ff ff ff       	call   800147 <sys_getenvid>
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	ff 75 0c             	pushl  0xc(%ebp)
  800210:	ff 75 08             	pushl  0x8(%ebp)
  800213:	56                   	push   %esi
  800214:	50                   	push   %eax
  800215:	68 b0 11 80 00       	push   $0x8011b0
  80021a:	e8 b1 00 00 00       	call   8002d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021f:	83 c4 18             	add    $0x18,%esp
  800222:	53                   	push   %ebx
  800223:	ff 75 10             	pushl  0x10(%ebp)
  800226:	e8 54 00 00 00       	call   80027f <vcprintf>
	cprintf("\n");
  80022b:	c7 04 24 ae 11 80 00 	movl   $0x8011ae,(%esp)
  800232:	e8 99 00 00 00       	call   8002d0 <cprintf>
  800237:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80023a:	cc                   	int3   
  80023b:	eb fd                	jmp    80023a <_panic+0x5d>

0080023d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	53                   	push   %ebx
  800241:	83 ec 04             	sub    $0x4,%esp
  800244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800247:	8b 13                	mov    (%ebx),%edx
  800249:	8d 42 01             	lea    0x1(%edx),%eax
  80024c:	89 03                	mov    %eax,(%ebx)
  80024e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800251:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800255:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025a:	75 1a                	jne    800276 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80025c:	83 ec 08             	sub    $0x8,%esp
  80025f:	68 ff 00 00 00       	push   $0xff
  800264:	8d 43 08             	lea    0x8(%ebx),%eax
  800267:	50                   	push   %eax
  800268:	e8 29 fe ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  80026d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800273:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800276:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800288:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028f:	00 00 00 
	b.cnt = 0;
  800292:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800299:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029c:	ff 75 0c             	pushl  0xc(%ebp)
  80029f:	ff 75 08             	pushl  0x8(%ebp)
  8002a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a8:	50                   	push   %eax
  8002a9:	68 3d 02 80 00       	push   $0x80023d
  8002ae:	e8 c0 02 00 00       	call   800573 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b3:	83 c4 08             	add    $0x8,%esp
  8002b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c2:	50                   	push   %eax
  8002c3:	e8 ce fd ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8002c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d9:	50                   	push   %eax
  8002da:	ff 75 08             	pushl  0x8(%ebp)
  8002dd:	e8 9d ff ff ff       	call   80027f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	57                   	push   %edi
  8002e8:	56                   	push   %esi
  8002e9:	53                   	push   %ebx
  8002ea:	83 ec 1c             	sub    $0x1c,%esp
  8002ed:	89 c7                	mov    %eax,%edi
  8002ef:	89 d6                	mov    %edx,%esi
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800300:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800304:	0f 85 bf 00 00 00    	jne    8003c9 <printnum+0xe5>
  80030a:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800310:	0f 8d de 00 00 00    	jge    8003f4 <printnum+0x110>
		judge_time_for_space = width;
  800316:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  80031c:	e9 d3 00 00 00       	jmp    8003f4 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800321:	83 eb 01             	sub    $0x1,%ebx
  800324:	85 db                	test   %ebx,%ebx
  800326:	7f 37                	jg     80035f <printnum+0x7b>
  800328:	e9 ea 00 00 00       	jmp    800417 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80032d:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800330:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	56                   	push   %esi
  800339:	83 ec 04             	sub    $0x4,%esp
  80033c:	ff 75 dc             	pushl  -0x24(%ebp)
  80033f:	ff 75 d8             	pushl  -0x28(%ebp)
  800342:	ff 75 e4             	pushl  -0x1c(%ebp)
  800345:	ff 75 e0             	pushl  -0x20(%ebp)
  800348:	e8 d3 0c 00 00       	call   801020 <__umoddi3>
  80034d:	83 c4 14             	add    $0x14,%esp
  800350:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800357:	50                   	push   %eax
  800358:	ff d7                	call   *%edi
  80035a:	83 c4 10             	add    $0x10,%esp
  80035d:	eb 16                	jmp    800375 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	56                   	push   %esi
  800363:	ff 75 18             	pushl  0x18(%ebp)
  800366:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	83 eb 01             	sub    $0x1,%ebx
  80036e:	75 ef                	jne    80035f <printnum+0x7b>
  800370:	e9 a2 00 00 00       	jmp    800417 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800375:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  80037b:	0f 85 76 01 00 00    	jne    8004f7 <printnum+0x213>
		while(num_of_space-- > 0)
  800381:	a1 04 20 80 00       	mov    0x802004,%eax
  800386:	8d 50 ff             	lea    -0x1(%eax),%edx
  800389:	89 15 04 20 80 00    	mov    %edx,0x802004
  80038f:	85 c0                	test   %eax,%eax
  800391:	7e 1d                	jle    8003b0 <printnum+0xcc>
			putch(' ', putdat);
  800393:	83 ec 08             	sub    $0x8,%esp
  800396:	56                   	push   %esi
  800397:	6a 20                	push   $0x20
  800399:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80039b:	a1 04 20 80 00       	mov    0x802004,%eax
  8003a0:	8d 50 ff             	lea    -0x1(%eax),%edx
  8003a3:	89 15 04 20 80 00    	mov    %edx,0x802004
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	7f e3                	jg     800393 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8003b0:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8003b7:	00 00 00 
		judge_time_for_space = 0;
  8003ba:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8003c1:	00 00 00 
	}
}
  8003c4:	e9 2e 01 00 00       	jmp    8004f7 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003dd:	83 fa 00             	cmp    $0x0,%edx
  8003e0:	0f 87 ba 00 00 00    	ja     8004a0 <printnum+0x1bc>
  8003e6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8003e9:	0f 83 b1 00 00 00    	jae    8004a0 <printnum+0x1bc>
  8003ef:	e9 2d ff ff ff       	jmp    800321 <printnum+0x3d>
  8003f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800405:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800408:	83 fa 00             	cmp    $0x0,%edx
  80040b:	77 37                	ja     800444 <printnum+0x160>
  80040d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800410:	73 32                	jae    800444 <printnum+0x160>
  800412:	e9 16 ff ff ff       	jmp    80032d <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	56                   	push   %esi
  80041b:	83 ec 04             	sub    $0x4,%esp
  80041e:	ff 75 dc             	pushl  -0x24(%ebp)
  800421:	ff 75 d8             	pushl  -0x28(%ebp)
  800424:	ff 75 e4             	pushl  -0x1c(%ebp)
  800427:	ff 75 e0             	pushl  -0x20(%ebp)
  80042a:	e8 f1 0b 00 00       	call   801020 <__umoddi3>
  80042f:	83 c4 14             	add    $0x14,%esp
  800432:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800439:	50                   	push   %eax
  80043a:	ff d7                	call   *%edi
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	e9 b3 00 00 00       	jmp    8004f7 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800444:	83 ec 0c             	sub    $0xc,%esp
  800447:	ff 75 18             	pushl  0x18(%ebp)
  80044a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80044d:	50                   	push   %eax
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 dc             	pushl  -0x24(%ebp)
  800457:	ff 75 d8             	pushl  -0x28(%ebp)
  80045a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80045d:	ff 75 e0             	pushl  -0x20(%ebp)
  800460:	e8 8b 0a 00 00       	call   800ef0 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 71 fe ff ff       	call   8002e4 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800473:	83 c4 18             	add    $0x18,%esp
  800476:	56                   	push   %esi
  800477:	83 ec 04             	sub    $0x4,%esp
  80047a:	ff 75 dc             	pushl  -0x24(%ebp)
  80047d:	ff 75 d8             	pushl  -0x28(%ebp)
  800480:	ff 75 e4             	pushl  -0x1c(%ebp)
  800483:	ff 75 e0             	pushl  -0x20(%ebp)
  800486:	e8 95 0b 00 00       	call   801020 <__umoddi3>
  80048b:	83 c4 14             	add    $0x14,%esp
  80048e:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800495:	50                   	push   %eax
  800496:	ff d7                	call   *%edi
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	e9 d5 fe ff ff       	jmp    800375 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a0:	83 ec 0c             	sub    $0xc,%esp
  8004a3:	ff 75 18             	pushl  0x18(%ebp)
  8004a6:	83 eb 01             	sub    $0x1,%ebx
  8004a9:	53                   	push   %ebx
  8004aa:	ff 75 10             	pushl  0x10(%ebp)
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bc:	e8 2f 0a 00 00       	call   800ef0 <__udivdi3>
  8004c1:	83 c4 18             	add    $0x18,%esp
  8004c4:	52                   	push   %edx
  8004c5:	50                   	push   %eax
  8004c6:	89 f2                	mov    %esi,%edx
  8004c8:	89 f8                	mov    %edi,%eax
  8004ca:	e8 15 fe ff ff       	call   8002e4 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004cf:	83 c4 18             	add    $0x18,%esp
  8004d2:	56                   	push   %esi
  8004d3:	83 ec 04             	sub    $0x4,%esp
  8004d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004df:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e2:	e8 39 0b 00 00       	call   801020 <__umoddi3>
  8004e7:	83 c4 14             	add    $0x14,%esp
  8004ea:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  8004f1:	50                   	push   %eax
  8004f2:	ff d7                	call   *%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8004f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004fa:	5b                   	pop    %ebx
  8004fb:	5e                   	pop    %esi
  8004fc:	5f                   	pop    %edi
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800502:	83 fa 01             	cmp    $0x1,%edx
  800505:	7e 0e                	jle    800515 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800507:	8b 10                	mov    (%eax),%edx
  800509:	8d 4a 08             	lea    0x8(%edx),%ecx
  80050c:	89 08                	mov    %ecx,(%eax)
  80050e:	8b 02                	mov    (%edx),%eax
  800510:	8b 52 04             	mov    0x4(%edx),%edx
  800513:	eb 22                	jmp    800537 <getuint+0x38>
	else if (lflag)
  800515:	85 d2                	test   %edx,%edx
  800517:	74 10                	je     800529 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800519:	8b 10                	mov    (%eax),%edx
  80051b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80051e:	89 08                	mov    %ecx,(%eax)
  800520:	8b 02                	mov    (%edx),%eax
  800522:	ba 00 00 00 00       	mov    $0x0,%edx
  800527:	eb 0e                	jmp    800537 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800529:	8b 10                	mov    (%eax),%edx
  80052b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052e:	89 08                	mov    %ecx,(%eax)
  800530:	8b 02                	mov    (%edx),%eax
  800532:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800537:	5d                   	pop    %ebp
  800538:	c3                   	ret    

00800539 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80053f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800543:	8b 10                	mov    (%eax),%edx
  800545:	3b 50 04             	cmp    0x4(%eax),%edx
  800548:	73 0a                	jae    800554 <sprintputch+0x1b>
		*b->buf++ = ch;
  80054a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80054d:	89 08                	mov    %ecx,(%eax)
  80054f:	8b 45 08             	mov    0x8(%ebp),%eax
  800552:	88 02                	mov    %al,(%edx)
}
  800554:	5d                   	pop    %ebp
  800555:	c3                   	ret    

00800556 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80055c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80055f:	50                   	push   %eax
  800560:	ff 75 10             	pushl  0x10(%ebp)
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	ff 75 08             	pushl  0x8(%ebp)
  800569:	e8 05 00 00 00       	call   800573 <vprintfmt>
	va_end(ap);
}
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	c9                   	leave  
  800572:	c3                   	ret    

00800573 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	57                   	push   %edi
  800577:	56                   	push   %esi
  800578:	53                   	push   %ebx
  800579:	83 ec 2c             	sub    $0x2c,%esp
  80057c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800582:	eb 03                	jmp    800587 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800584:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800587:	8b 45 10             	mov    0x10(%ebp),%eax
  80058a:	8d 70 01             	lea    0x1(%eax),%esi
  80058d:	0f b6 00             	movzbl (%eax),%eax
  800590:	83 f8 25             	cmp    $0x25,%eax
  800593:	74 27                	je     8005bc <vprintfmt+0x49>
			if (ch == '\0')
  800595:	85 c0                	test   %eax,%eax
  800597:	75 0d                	jne    8005a6 <vprintfmt+0x33>
  800599:	e9 9d 04 00 00       	jmp    800a3b <vprintfmt+0x4c8>
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	0f 84 95 04 00 00    	je     800a3b <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	50                   	push   %eax
  8005ab:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ad:	83 c6 01             	add    $0x1,%esi
  8005b0:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	83 f8 25             	cmp    $0x25,%eax
  8005ba:	75 e2                	jne    80059e <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c1:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8005c5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005cc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005d3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005da:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8005e1:	eb 08                	jmp    8005eb <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8005e6:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8d 46 01             	lea    0x1(%esi),%eax
  8005ee:	89 45 10             	mov    %eax,0x10(%ebp)
  8005f1:	0f b6 06             	movzbl (%esi),%eax
  8005f4:	0f b6 d0             	movzbl %al,%edx
  8005f7:	83 e8 23             	sub    $0x23,%eax
  8005fa:	3c 55                	cmp    $0x55,%al
  8005fc:	0f 87 fa 03 00 00    	ja     8009fc <vprintfmt+0x489>
  800602:	0f b6 c0             	movzbl %al,%eax
  800605:	ff 24 85 dc 12 80 00 	jmp    *0x8012dc(,%eax,4)
  80060c:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80060f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800613:	eb d6                	jmp    8005eb <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800615:	8d 42 d0             	lea    -0x30(%edx),%eax
  800618:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80061b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80061f:	8d 50 d0             	lea    -0x30(%eax),%edx
  800622:	83 fa 09             	cmp    $0x9,%edx
  800625:	77 6b                	ja     800692 <vprintfmt+0x11f>
  800627:	8b 75 10             	mov    0x10(%ebp),%esi
  80062a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80062d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800630:	eb 09                	jmp    80063b <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800635:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800639:	eb b0                	jmp    8005eb <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80063b:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80063e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800641:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800645:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800648:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80064b:	83 f9 09             	cmp    $0x9,%ecx
  80064e:	76 eb                	jbe    80063b <vprintfmt+0xc8>
  800650:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800653:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800656:	eb 3d                	jmp    800695 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 04             	lea    0x4(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)
  800661:	8b 00                	mov    (%eax),%eax
  800663:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800669:	eb 2a                	jmp    800695 <vprintfmt+0x122>
  80066b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80066e:	85 c0                	test   %eax,%eax
  800670:	ba 00 00 00 00       	mov    $0x0,%edx
  800675:	0f 49 d0             	cmovns %eax,%edx
  800678:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 75 10             	mov    0x10(%ebp),%esi
  80067e:	e9 68 ff ff ff       	jmp    8005eb <vprintfmt+0x78>
  800683:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800686:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80068d:	e9 59 ff ff ff       	jmp    8005eb <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800695:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800699:	0f 89 4c ff ff ff    	jns    8005eb <vprintfmt+0x78>
				width = precision, precision = -1;
  80069f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006ac:	e9 3a ff ff ff       	jmp    8005eb <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006b1:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b5:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006b8:	e9 2e ff ff ff       	jmp    8005eb <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	ff 30                	pushl  (%eax)
  8006cc:	ff d7                	call   *%edi
			break;
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	e9 b1 fe ff ff       	jmp    800587 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	99                   	cltd   
  8006e2:	31 d0                	xor    %edx,%eax
  8006e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e6:	83 f8 06             	cmp    $0x6,%eax
  8006e9:	7f 0b                	jg     8006f6 <vprintfmt+0x183>
  8006eb:	8b 14 85 34 14 80 00 	mov    0x801434(,%eax,4),%edx
  8006f2:	85 d2                	test   %edx,%edx
  8006f4:	75 15                	jne    80070b <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8006f6:	50                   	push   %eax
  8006f7:	68 eb 11 80 00       	push   $0x8011eb
  8006fc:	53                   	push   %ebx
  8006fd:	57                   	push   %edi
  8006fe:	e8 53 fe ff ff       	call   800556 <printfmt>
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	e9 7c fe ff ff       	jmp    800587 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80070b:	52                   	push   %edx
  80070c:	68 f4 11 80 00       	push   $0x8011f4
  800711:	53                   	push   %ebx
  800712:	57                   	push   %edi
  800713:	e8 3e fe ff ff       	call   800556 <printfmt>
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	e9 67 fe ff ff       	jmp    800587 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8d 50 04             	lea    0x4(%eax),%edx
  800726:	89 55 14             	mov    %edx,0x14(%ebp)
  800729:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80072b:	85 c0                	test   %eax,%eax
  80072d:	b9 e4 11 80 00       	mov    $0x8011e4,%ecx
  800732:	0f 45 c8             	cmovne %eax,%ecx
  800735:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800738:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073c:	7e 06                	jle    800744 <vprintfmt+0x1d1>
  80073e:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800742:	75 19                	jne    80075d <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800744:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800747:	8d 70 01             	lea    0x1(%eax),%esi
  80074a:	0f b6 00             	movzbl (%eax),%eax
  80074d:	0f be d0             	movsbl %al,%edx
  800750:	85 d2                	test   %edx,%edx
  800752:	0f 85 9f 00 00 00    	jne    8007f7 <vprintfmt+0x284>
  800758:	e9 8c 00 00 00       	jmp    8007e9 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	ff 75 d0             	pushl  -0x30(%ebp)
  800763:	ff 75 cc             	pushl  -0x34(%ebp)
  800766:	e8 62 03 00 00       	call   800acd <strnlen>
  80076b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80076e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	85 c9                	test   %ecx,%ecx
  800776:	0f 8e a6 02 00 00    	jle    800a22 <vprintfmt+0x4af>
					putch(padc, putdat);
  80077c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800780:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800783:	89 cb                	mov    %ecx,%ebx
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	ff 75 0c             	pushl  0xc(%ebp)
  80078b:	56                   	push   %esi
  80078c:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80078e:	83 c4 10             	add    $0x10,%esp
  800791:	83 eb 01             	sub    $0x1,%ebx
  800794:	75 ef                	jne    800785 <vprintfmt+0x212>
  800796:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079c:	e9 81 02 00 00       	jmp    800a22 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007a1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007a5:	74 1b                	je     8007c2 <vprintfmt+0x24f>
  8007a7:	0f be c0             	movsbl %al,%eax
  8007aa:	83 e8 20             	sub    $0x20,%eax
  8007ad:	83 f8 5e             	cmp    $0x5e,%eax
  8007b0:	76 10                	jbe    8007c2 <vprintfmt+0x24f>
					putch('?', putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	6a 3f                	push   $0x3f
  8007ba:	ff 55 08             	call   *0x8(%ebp)
  8007bd:	83 c4 10             	add    $0x10,%esp
  8007c0:	eb 0d                	jmp    8007cf <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	52                   	push   %edx
  8007c9:	ff 55 08             	call   *0x8(%ebp)
  8007cc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cf:	83 ef 01             	sub    $0x1,%edi
  8007d2:	83 c6 01             	add    $0x1,%esi
  8007d5:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007d9:	0f be d0             	movsbl %al,%edx
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	75 31                	jne    800811 <vprintfmt+0x29e>
  8007e0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f0:	7f 33                	jg     800825 <vprintfmt+0x2b2>
  8007f2:	e9 90 fd ff ff       	jmp    800587 <vprintfmt+0x14>
  8007f7:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800800:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800803:	eb 0c                	jmp    800811 <vprintfmt+0x29e>
  800805:	89 7d 08             	mov    %edi,0x8(%ebp)
  800808:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80080e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800811:	85 db                	test   %ebx,%ebx
  800813:	78 8c                	js     8007a1 <vprintfmt+0x22e>
  800815:	83 eb 01             	sub    $0x1,%ebx
  800818:	79 87                	jns    8007a1 <vprintfmt+0x22e>
  80081a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80081d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800823:	eb c4                	jmp    8007e9 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800825:	83 ec 08             	sub    $0x8,%esp
  800828:	53                   	push   %ebx
  800829:	6a 20                	push   $0x20
  80082b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	83 ee 01             	sub    $0x1,%esi
  800833:	75 f0                	jne    800825 <vprintfmt+0x2b2>
  800835:	e9 4d fd ff ff       	jmp    800587 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083a:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80083e:	7e 16                	jle    800856 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800840:	8b 45 14             	mov    0x14(%ebp),%eax
  800843:	8d 50 08             	lea    0x8(%eax),%edx
  800846:	89 55 14             	mov    %edx,0x14(%ebp)
  800849:	8b 50 04             	mov    0x4(%eax),%edx
  80084c:	8b 00                	mov    (%eax),%eax
  80084e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800851:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800854:	eb 34                	jmp    80088a <vprintfmt+0x317>
	else if (lflag)
  800856:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80085a:	74 18                	je     800874 <vprintfmt+0x301>
		return va_arg(*ap, long);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8d 50 04             	lea    0x4(%eax),%edx
  800862:	89 55 14             	mov    %edx,0x14(%ebp)
  800865:	8b 30                	mov    (%eax),%esi
  800867:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80086a:	89 f0                	mov    %esi,%eax
  80086c:	c1 f8 1f             	sar    $0x1f,%eax
  80086f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800872:	eb 16                	jmp    80088a <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8d 50 04             	lea    0x4(%eax),%edx
  80087a:	89 55 14             	mov    %edx,0x14(%ebp)
  80087d:	8b 30                	mov    (%eax),%esi
  80087f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800882:	89 f0                	mov    %esi,%eax
  800884:	c1 f8 1f             	sar    $0x1f,%eax
  800887:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80088a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80088d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800890:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800893:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800896:	85 d2                	test   %edx,%edx
  800898:	79 28                	jns    8008c2 <vprintfmt+0x34f>
				putch('-', putdat);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	53                   	push   %ebx
  80089e:	6a 2d                	push   $0x2d
  8008a0:	ff d7                	call   *%edi
				num = -(long long) num;
  8008a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008a8:	f7 d8                	neg    %eax
  8008aa:	83 d2 00             	adc    $0x0,%edx
  8008ad:	f7 da                	neg    %edx
  8008af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b5:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8008b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008bd:	e9 b2 00 00 00       	jmp    800974 <vprintfmt+0x401>
  8008c2:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	0f 84 a5 00 00 00    	je     800974 <vprintfmt+0x401>
				putch('+', putdat);
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	53                   	push   %ebx
  8008d3:	6a 2b                	push   $0x2b
  8008d5:	ff d7                	call   *%edi
  8008d7:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8008da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008df:	e9 90 00 00 00       	jmp    800974 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8008e4:	85 c9                	test   %ecx,%ecx
  8008e6:	74 0b                	je     8008f3 <vprintfmt+0x380>
				putch('+', putdat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	53                   	push   %ebx
  8008ec:	6a 2b                	push   $0x2b
  8008ee:	ff d7                	call   *%edi
  8008f0:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8008f3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f9:	e8 01 fc ff ff       	call   8004ff <getuint>
  8008fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800901:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800904:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800909:	eb 69                	jmp    800974 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	53                   	push   %ebx
  80090f:	6a 30                	push   $0x30
  800911:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800913:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800916:	8d 45 14             	lea    0x14(%ebp),%eax
  800919:	e8 e1 fb ff ff       	call   8004ff <getuint>
  80091e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800921:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800924:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800927:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80092c:	eb 46                	jmp    800974 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	6a 30                	push   $0x30
  800934:	ff d7                	call   *%edi
			putch('x', putdat);
  800936:	83 c4 08             	add    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 78                	push   $0x78
  80093c:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800947:	8b 00                	mov    (%eax),%eax
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
  80094e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800951:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800954:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800957:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80095c:	eb 16                	jmp    800974 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80095e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800961:	8d 45 14             	lea    0x14(%ebp),%eax
  800964:	e8 96 fb ff ff       	call   8004ff <getuint>
  800969:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80096c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80096f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800974:	83 ec 0c             	sub    $0xc,%esp
  800977:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80097b:	56                   	push   %esi
  80097c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80097f:	50                   	push   %eax
  800980:	ff 75 dc             	pushl  -0x24(%ebp)
  800983:	ff 75 d8             	pushl  -0x28(%ebp)
  800986:	89 da                	mov    %ebx,%edx
  800988:	89 f8                	mov    %edi,%eax
  80098a:	e8 55 f9 ff ff       	call   8002e4 <printnum>
			break;
  80098f:	83 c4 20             	add    $0x20,%esp
  800992:	e9 f0 fb ff ff       	jmp    800587 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8009a2:	85 f6                	test   %esi,%esi
  8009a4:	75 1a                	jne    8009c0 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8009a6:	83 ec 08             	sub    $0x8,%esp
  8009a9:	68 60 12 80 00       	push   $0x801260
  8009ae:	68 f4 11 80 00       	push   $0x8011f4
  8009b3:	e8 18 f9 ff ff       	call   8002d0 <cprintf>
  8009b8:	83 c4 10             	add    $0x10,%esp
  8009bb:	e9 c7 fb ff ff       	jmp    800587 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8009c0:	0f b6 03             	movzbl (%ebx),%eax
  8009c3:	84 c0                	test   %al,%al
  8009c5:	79 1f                	jns    8009e6 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8009c7:	83 ec 08             	sub    $0x8,%esp
  8009ca:	68 98 12 80 00       	push   $0x801298
  8009cf:	68 f4 11 80 00       	push   $0x8011f4
  8009d4:	e8 f7 f8 ff ff       	call   8002d0 <cprintf>
						*tmp = *(char *)putdat;
  8009d9:	0f b6 03             	movzbl (%ebx),%eax
  8009dc:	88 06                	mov    %al,(%esi)
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	e9 a1 fb ff ff       	jmp    800587 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8009e6:	88 06                	mov    %al,(%esi)
  8009e8:	e9 9a fb ff ff       	jmp    800587 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009ed:	83 ec 08             	sub    $0x8,%esp
  8009f0:	53                   	push   %ebx
  8009f1:	52                   	push   %edx
  8009f2:	ff d7                	call   *%edi
			break;
  8009f4:	83 c4 10             	add    $0x10,%esp
  8009f7:	e9 8b fb ff ff       	jmp    800587 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009fc:	83 ec 08             	sub    $0x8,%esp
  8009ff:	53                   	push   %ebx
  800a00:	6a 25                	push   $0x25
  800a02:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a0b:	0f 84 73 fb ff ff    	je     800584 <vprintfmt+0x11>
  800a11:	83 ee 01             	sub    $0x1,%esi
  800a14:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a18:	75 f7                	jne    800a11 <vprintfmt+0x49e>
  800a1a:	89 75 10             	mov    %esi,0x10(%ebp)
  800a1d:	e9 65 fb ff ff       	jmp    800587 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a22:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a25:	8d 70 01             	lea    0x1(%eax),%esi
  800a28:	0f b6 00             	movzbl (%eax),%eax
  800a2b:	0f be d0             	movsbl %al,%edx
  800a2e:	85 d2                	test   %edx,%edx
  800a30:	0f 85 cf fd ff ff    	jne    800805 <vprintfmt+0x292>
  800a36:	e9 4c fb ff ff       	jmp    800587 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	83 ec 18             	sub    $0x18,%esp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a52:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a56:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a60:	85 c0                	test   %eax,%eax
  800a62:	74 26                	je     800a8a <vsnprintf+0x47>
  800a64:	85 d2                	test   %edx,%edx
  800a66:	7e 22                	jle    800a8a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a68:	ff 75 14             	pushl  0x14(%ebp)
  800a6b:	ff 75 10             	pushl  0x10(%ebp)
  800a6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a71:	50                   	push   %eax
  800a72:	68 39 05 80 00       	push   $0x800539
  800a77:	e8 f7 fa ff ff       	call   800573 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	eb 05                	jmp    800a8f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a8f:	c9                   	leave  
  800a90:	c3                   	ret    

00800a91 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a97:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a9a:	50                   	push   %eax
  800a9b:	ff 75 10             	pushl  0x10(%ebp)
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	ff 75 08             	pushl  0x8(%ebp)
  800aa4:	e8 9a ff ff ff       	call   800a43 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab1:	80 3a 00             	cmpb   $0x0,(%edx)
  800ab4:	74 10                	je     800ac6 <strlen+0x1b>
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800abb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800abe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac2:	75 f7                	jne    800abb <strlen+0x10>
  800ac4:	eb 05                	jmp    800acb <strlen+0x20>
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	53                   	push   %ebx
  800ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad7:	85 c9                	test   %ecx,%ecx
  800ad9:	74 1c                	je     800af7 <strnlen+0x2a>
  800adb:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ade:	74 1e                	je     800afe <strnlen+0x31>
  800ae0:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800ae5:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae7:	39 ca                	cmp    %ecx,%edx
  800ae9:	74 18                	je     800b03 <strnlen+0x36>
  800aeb:	83 c2 01             	add    $0x1,%edx
  800aee:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800af3:	75 f0                	jne    800ae5 <strnlen+0x18>
  800af5:	eb 0c                	jmp    800b03 <strnlen+0x36>
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	eb 05                	jmp    800b03 <strnlen+0x36>
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b03:	5b                   	pop    %ebx
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	83 c2 01             	add    $0x1,%edx
  800b15:	83 c1 01             	add    $0x1,%ecx
  800b18:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b1c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1f:	84 db                	test   %bl,%bl
  800b21:	75 ef                	jne    800b12 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b23:	5b                   	pop    %ebx
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	53                   	push   %ebx
  800b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b2d:	53                   	push   %ebx
  800b2e:	e8 78 ff ff ff       	call   800aab <strlen>
  800b33:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b36:	ff 75 0c             	pushl  0xc(%ebp)
  800b39:	01 d8                	add    %ebx,%eax
  800b3b:	50                   	push   %eax
  800b3c:	e8 c5 ff ff ff       	call   800b06 <strcpy>
	return dst;
}
  800b41:	89 d8                	mov    %ebx,%eax
  800b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b56:	85 db                	test   %ebx,%ebx
  800b58:	74 17                	je     800b71 <strncpy+0x29>
  800b5a:	01 f3                	add    %esi,%ebx
  800b5c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	0f b6 02             	movzbl (%edx),%eax
  800b64:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b67:	80 3a 01             	cmpb   $0x1,(%edx)
  800b6a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b6d:	39 cb                	cmp    %ecx,%ebx
  800b6f:	75 ed                	jne    800b5e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b71:	89 f0                	mov    %esi,%eax
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b82:	8b 55 10             	mov    0x10(%ebp),%edx
  800b85:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b87:	85 d2                	test   %edx,%edx
  800b89:	74 35                	je     800bc0 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b8b:	89 d0                	mov    %edx,%eax
  800b8d:	83 e8 01             	sub    $0x1,%eax
  800b90:	74 25                	je     800bb7 <strlcpy+0x40>
  800b92:	0f b6 0b             	movzbl (%ebx),%ecx
  800b95:	84 c9                	test   %cl,%cl
  800b97:	74 22                	je     800bbb <strlcpy+0x44>
  800b99:	8d 53 01             	lea    0x1(%ebx),%edx
  800b9c:	01 c3                	add    %eax,%ebx
  800b9e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ba0:	83 c0 01             	add    $0x1,%eax
  800ba3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba6:	39 da                	cmp    %ebx,%edx
  800ba8:	74 13                	je     800bbd <strlcpy+0x46>
  800baa:	83 c2 01             	add    $0x1,%edx
  800bad:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800bb1:	84 c9                	test   %cl,%cl
  800bb3:	75 eb                	jne    800ba0 <strlcpy+0x29>
  800bb5:	eb 06                	jmp    800bbd <strlcpy+0x46>
  800bb7:	89 f0                	mov    %esi,%eax
  800bb9:	eb 02                	jmp    800bbd <strlcpy+0x46>
  800bbb:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bbd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc0:	29 f0                	sub    %esi,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bcf:	0f b6 01             	movzbl (%ecx),%eax
  800bd2:	84 c0                	test   %al,%al
  800bd4:	74 15                	je     800beb <strcmp+0x25>
  800bd6:	3a 02                	cmp    (%edx),%al
  800bd8:	75 11                	jne    800beb <strcmp+0x25>
		p++, q++;
  800bda:	83 c1 01             	add    $0x1,%ecx
  800bdd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800be0:	0f b6 01             	movzbl (%ecx),%eax
  800be3:	84 c0                	test   %al,%al
  800be5:	74 04                	je     800beb <strcmp+0x25>
  800be7:	3a 02                	cmp    (%edx),%al
  800be9:	74 ef                	je     800bda <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800beb:	0f b6 c0             	movzbl %al,%eax
  800bee:	0f b6 12             	movzbl (%edx),%edx
  800bf1:	29 d0                	sub    %edx,%eax
}
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c00:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c03:	85 f6                	test   %esi,%esi
  800c05:	74 29                	je     800c30 <strncmp+0x3b>
  800c07:	0f b6 03             	movzbl (%ebx),%eax
  800c0a:	84 c0                	test   %al,%al
  800c0c:	74 30                	je     800c3e <strncmp+0x49>
  800c0e:	3a 02                	cmp    (%edx),%al
  800c10:	75 2c                	jne    800c3e <strncmp+0x49>
  800c12:	8d 43 01             	lea    0x1(%ebx),%eax
  800c15:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c17:	89 c3                	mov    %eax,%ebx
  800c19:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c1c:	39 c6                	cmp    %eax,%esi
  800c1e:	74 17                	je     800c37 <strncmp+0x42>
  800c20:	0f b6 08             	movzbl (%eax),%ecx
  800c23:	84 c9                	test   %cl,%cl
  800c25:	74 17                	je     800c3e <strncmp+0x49>
  800c27:	83 c0 01             	add    $0x1,%eax
  800c2a:	3a 0a                	cmp    (%edx),%cl
  800c2c:	74 e9                	je     800c17 <strncmp+0x22>
  800c2e:	eb 0e                	jmp    800c3e <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c30:	b8 00 00 00 00       	mov    $0x0,%eax
  800c35:	eb 0f                	jmp    800c46 <strncmp+0x51>
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	eb 08                	jmp    800c46 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c3e:	0f b6 03             	movzbl (%ebx),%eax
  800c41:	0f b6 12             	movzbl (%edx),%edx
  800c44:	29 d0                	sub    %edx,%eax
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	53                   	push   %ebx
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c54:	0f b6 10             	movzbl (%eax),%edx
  800c57:	84 d2                	test   %dl,%dl
  800c59:	74 1d                	je     800c78 <strchr+0x2e>
  800c5b:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800c5d:	38 d3                	cmp    %dl,%bl
  800c5f:	75 06                	jne    800c67 <strchr+0x1d>
  800c61:	eb 1a                	jmp    800c7d <strchr+0x33>
  800c63:	38 ca                	cmp    %cl,%dl
  800c65:	74 16                	je     800c7d <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c67:	83 c0 01             	add    $0x1,%eax
  800c6a:	0f b6 10             	movzbl (%eax),%edx
  800c6d:	84 d2                	test   %dl,%dl
  800c6f:	75 f2                	jne    800c63 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	eb 05                	jmp    800c7d <strchr+0x33>
  800c78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	53                   	push   %ebx
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c8a:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c8d:	38 d3                	cmp    %dl,%bl
  800c8f:	74 14                	je     800ca5 <strfind+0x25>
  800c91:	89 d1                	mov    %edx,%ecx
  800c93:	84 db                	test   %bl,%bl
  800c95:	74 0e                	je     800ca5 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c97:	83 c0 01             	add    $0x1,%eax
  800c9a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c9d:	38 ca                	cmp    %cl,%dl
  800c9f:	74 04                	je     800ca5 <strfind+0x25>
  800ca1:	84 d2                	test   %dl,%dl
  800ca3:	75 f2                	jne    800c97 <strfind+0x17>
			break;
	return (char *) s;
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cb1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb4:	85 c9                	test   %ecx,%ecx
  800cb6:	74 36                	je     800cee <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cbe:	75 28                	jne    800ce8 <memset+0x40>
  800cc0:	f6 c1 03             	test   $0x3,%cl
  800cc3:	75 23                	jne    800ce8 <memset+0x40>
		c &= 0xFF;
  800cc5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc9:	89 d3                	mov    %edx,%ebx
  800ccb:	c1 e3 08             	shl    $0x8,%ebx
  800cce:	89 d6                	mov    %edx,%esi
  800cd0:	c1 e6 18             	shl    $0x18,%esi
  800cd3:	89 d0                	mov    %edx,%eax
  800cd5:	c1 e0 10             	shl    $0x10,%eax
  800cd8:	09 f0                	or     %esi,%eax
  800cda:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cdc:	89 d8                	mov    %ebx,%eax
  800cde:	09 d0                	or     %edx,%eax
  800ce0:	c1 e9 02             	shr    $0x2,%ecx
  800ce3:	fc                   	cld    
  800ce4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ce6:	eb 06                	jmp    800cee <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ceb:	fc                   	cld    
  800cec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cee:	89 f8                	mov    %edi,%eax
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d03:	39 c6                	cmp    %eax,%esi
  800d05:	73 35                	jae    800d3c <memmove+0x47>
  800d07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d0a:	39 d0                	cmp    %edx,%eax
  800d0c:	73 2e                	jae    800d3c <memmove+0x47>
		s += n;
		d += n;
  800d0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d11:	89 d6                	mov    %edx,%esi
  800d13:	09 fe                	or     %edi,%esi
  800d15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d1b:	75 13                	jne    800d30 <memmove+0x3b>
  800d1d:	f6 c1 03             	test   $0x3,%cl
  800d20:	75 0e                	jne    800d30 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d22:	83 ef 04             	sub    $0x4,%edi
  800d25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d28:	c1 e9 02             	shr    $0x2,%ecx
  800d2b:	fd                   	std    
  800d2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d2e:	eb 09                	jmp    800d39 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d30:	83 ef 01             	sub    $0x1,%edi
  800d33:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d36:	fd                   	std    
  800d37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d39:	fc                   	cld    
  800d3a:	eb 1d                	jmp    800d59 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	09 c2                	or     %eax,%edx
  800d40:	f6 c2 03             	test   $0x3,%dl
  800d43:	75 0f                	jne    800d54 <memmove+0x5f>
  800d45:	f6 c1 03             	test   $0x3,%cl
  800d48:	75 0a                	jne    800d54 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d4a:	c1 e9 02             	shr    $0x2,%ecx
  800d4d:	89 c7                	mov    %eax,%edi
  800d4f:	fc                   	cld    
  800d50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d52:	eb 05                	jmp    800d59 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d54:	89 c7                	mov    %eax,%edi
  800d56:	fc                   	cld    
  800d57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d60:	ff 75 10             	pushl  0x10(%ebp)
  800d63:	ff 75 0c             	pushl  0xc(%ebp)
  800d66:	ff 75 08             	pushl  0x8(%ebp)
  800d69:	e8 87 ff ff ff       	call   800cf5 <memmove>
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d7c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	74 39                	je     800dbc <memcmp+0x4c>
  800d83:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800d86:	0f b6 13             	movzbl (%ebx),%edx
  800d89:	0f b6 0e             	movzbl (%esi),%ecx
  800d8c:	38 ca                	cmp    %cl,%dl
  800d8e:	75 17                	jne    800da7 <memcmp+0x37>
  800d90:	b8 00 00 00 00       	mov    $0x0,%eax
  800d95:	eb 1a                	jmp    800db1 <memcmp+0x41>
  800d97:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800d9c:	83 c0 01             	add    $0x1,%eax
  800d9f:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800da3:	38 ca                	cmp    %cl,%dl
  800da5:	74 0a                	je     800db1 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800da7:	0f b6 c2             	movzbl %dl,%eax
  800daa:	0f b6 c9             	movzbl %cl,%ecx
  800dad:	29 c8                	sub    %ecx,%eax
  800daf:	eb 10                	jmp    800dc1 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800db1:	39 f8                	cmp    %edi,%eax
  800db3:	75 e2                	jne    800d97 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dba:	eb 05                	jmp    800dc1 <memcmp+0x51>
  800dbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	53                   	push   %ebx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800dcd:	89 d0                	mov    %edx,%eax
  800dcf:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800dd2:	39 c2                	cmp    %eax,%edx
  800dd4:	73 1d                	jae    800df3 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dd6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800dda:	0f b6 0a             	movzbl (%edx),%ecx
  800ddd:	39 d9                	cmp    %ebx,%ecx
  800ddf:	75 09                	jne    800dea <memfind+0x24>
  800de1:	eb 14                	jmp    800df7 <memfind+0x31>
  800de3:	0f b6 0a             	movzbl (%edx),%ecx
  800de6:	39 d9                	cmp    %ebx,%ecx
  800de8:	74 11                	je     800dfb <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dea:	83 c2 01             	add    $0x1,%edx
  800ded:	39 d0                	cmp    %edx,%eax
  800def:	75 f2                	jne    800de3 <memfind+0x1d>
  800df1:	eb 0a                	jmp    800dfd <memfind+0x37>
  800df3:	89 d0                	mov    %edx,%eax
  800df5:	eb 06                	jmp    800dfd <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df7:	89 d0                	mov    %edx,%eax
  800df9:	eb 02                	jmp    800dfd <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dfb:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dfd:	5b                   	pop    %ebx
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0c:	0f b6 01             	movzbl (%ecx),%eax
  800e0f:	3c 20                	cmp    $0x20,%al
  800e11:	74 04                	je     800e17 <strtol+0x17>
  800e13:	3c 09                	cmp    $0x9,%al
  800e15:	75 0e                	jne    800e25 <strtol+0x25>
		s++;
  800e17:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1a:	0f b6 01             	movzbl (%ecx),%eax
  800e1d:	3c 20                	cmp    $0x20,%al
  800e1f:	74 f6                	je     800e17 <strtol+0x17>
  800e21:	3c 09                	cmp    $0x9,%al
  800e23:	74 f2                	je     800e17 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e25:	3c 2b                	cmp    $0x2b,%al
  800e27:	75 0a                	jne    800e33 <strtol+0x33>
		s++;
  800e29:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e31:	eb 11                	jmp    800e44 <strtol+0x44>
  800e33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e38:	3c 2d                	cmp    $0x2d,%al
  800e3a:	75 08                	jne    800e44 <strtol+0x44>
		s++, neg = 1;
  800e3c:	83 c1 01             	add    $0x1,%ecx
  800e3f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e4a:	75 15                	jne    800e61 <strtol+0x61>
  800e4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e4f:	75 10                	jne    800e61 <strtol+0x61>
  800e51:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e55:	75 7c                	jne    800ed3 <strtol+0xd3>
		s += 2, base = 16;
  800e57:	83 c1 02             	add    $0x2,%ecx
  800e5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e5f:	eb 16                	jmp    800e77 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e61:	85 db                	test   %ebx,%ebx
  800e63:	75 12                	jne    800e77 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e65:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800e6d:	75 08                	jne    800e77 <strtol+0x77>
		s++, base = 8;
  800e6f:	83 c1 01             	add    $0x1,%ecx
  800e72:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e7f:	0f b6 11             	movzbl (%ecx),%edx
  800e82:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e85:	89 f3                	mov    %esi,%ebx
  800e87:	80 fb 09             	cmp    $0x9,%bl
  800e8a:	77 08                	ja     800e94 <strtol+0x94>
			dig = *s - '0';
  800e8c:	0f be d2             	movsbl %dl,%edx
  800e8f:	83 ea 30             	sub    $0x30,%edx
  800e92:	eb 22                	jmp    800eb6 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800e94:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e97:	89 f3                	mov    %esi,%ebx
  800e99:	80 fb 19             	cmp    $0x19,%bl
  800e9c:	77 08                	ja     800ea6 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800e9e:	0f be d2             	movsbl %dl,%edx
  800ea1:	83 ea 57             	sub    $0x57,%edx
  800ea4:	eb 10                	jmp    800eb6 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800ea6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ea9:	89 f3                	mov    %esi,%ebx
  800eab:	80 fb 19             	cmp    $0x19,%bl
  800eae:	77 16                	ja     800ec6 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800eb0:	0f be d2             	movsbl %dl,%edx
  800eb3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800eb6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800eb9:	7d 0b                	jge    800ec6 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ebb:	83 c1 01             	add    $0x1,%ecx
  800ebe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ec2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ec4:	eb b9                	jmp    800e7f <strtol+0x7f>

	if (endptr)
  800ec6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eca:	74 0d                	je     800ed9 <strtol+0xd9>
		*endptr = (char *) s;
  800ecc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ecf:	89 0e                	mov    %ecx,(%esi)
  800ed1:	eb 06                	jmp    800ed9 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ed3:	85 db                	test   %ebx,%ebx
  800ed5:	74 98                	je     800e6f <strtol+0x6f>
  800ed7:	eb 9e                	jmp    800e77 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ed9:	89 c2                	mov    %eax,%edx
  800edb:	f7 da                	neg    %edx
  800edd:	85 ff                	test   %edi,%edi
  800edf:	0f 45 c2             	cmovne %edx,%eax
}
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    
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
