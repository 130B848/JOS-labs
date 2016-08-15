
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004d:	e8 f9 00 00 00       	call   80014b <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 64             	imul   $0x64,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 66 00 00 00       	call   8000fb <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	51                   	push   %ecx
  8000af:	52                   	push   %edx
  8000b0:	53                   	push   %ebx
  8000b1:	54                   	push   %esp
  8000b2:	55                   	push   %ebp
  8000b3:	56                   	push   %esi
  8000b4:	57                   	push   %edi
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	8d 35 bf 00 80 00    	lea    0x8000bf,%esi
  8000bd:	0f 34                	sysenter 

008000bf <label_21>:
  8000bf:	5f                   	pop    %edi
  8000c0:	5e                   	pop    %esi
  8000c1:	5d                   	pop    %ebp
  8000c2:	5c                   	pop    %esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5a                   	pop    %edx
  8000c5:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c6:	5b                   	pop    %ebx
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	89 ca                	mov    %ecx,%edx
  8000db:	89 cb                	mov    %ecx,%ebx
  8000dd:	89 cf                	mov    %ecx,%edi
  8000df:	51                   	push   %ecx
  8000e0:	52                   	push   %edx
  8000e1:	53                   	push   %ebx
  8000e2:	54                   	push   %esp
  8000e3:	55                   	push   %ebp
  8000e4:	56                   	push   %esi
  8000e5:	57                   	push   %edi
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	8d 35 f0 00 80 00    	lea    0x8000f0,%esi
  8000ee:	0f 34                	sysenter 

008000f0 <label_55>:
  8000f0:	5f                   	pop    %edi
  8000f1:	5e                   	pop    %esi
  8000f2:	5d                   	pop    %ebp
  8000f3:	5c                   	pop    %esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5a                   	pop    %edx
  8000f6:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f7:	5b                   	pop    %ebx
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800100:	bb 00 00 00 00       	mov    $0x0,%ebx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	89 d9                	mov    %ebx,%ecx
  80010f:	89 df                	mov    %ebx,%edi
  800111:	51                   	push   %ecx
  800112:	52                   	push   %edx
  800113:	53                   	push   %ebx
  800114:	54                   	push   %esp
  800115:	55                   	push   %ebp
  800116:	56                   	push   %esi
  800117:	57                   	push   %edi
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	8d 35 22 01 80 00    	lea    0x800122,%esi
  800120:	0f 34                	sysenter 

00800122 <label_90>:
  800122:	5f                   	pop    %edi
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	5c                   	pop    %esp
  800126:	5b                   	pop    %ebx
  800127:	5a                   	pop    %edx
  800128:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800129:	85 c0                	test   %eax,%eax
  80012b:	7e 17                	jle    800144 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	6a 03                	push   $0x3
  800133:	68 7e 11 80 00       	push   $0x80117e
  800138:	6a 2a                	push   $0x2a
  80013a:	68 9b 11 80 00       	push   $0x80119b
  80013f:	e8 9d 00 00 00       	call   8001e1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800147:	5b                   	pop    %ebx
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800150:	b9 00 00 00 00       	mov    $0x0,%ecx
  800155:	b8 02 00 00 00       	mov    $0x2,%eax
  80015a:	89 ca                	mov    %ecx,%edx
  80015c:	89 cb                	mov    %ecx,%ebx
  80015e:	89 cf                	mov    %ecx,%edi
  800160:	51                   	push   %ecx
  800161:	52                   	push   %edx
  800162:	53                   	push   %ebx
  800163:	54                   	push   %esp
  800164:	55                   	push   %ebp
  800165:	56                   	push   %esi
  800166:	57                   	push   %edi
  800167:	89 e5                	mov    %esp,%ebp
  800169:	8d 35 71 01 80 00    	lea    0x800171,%esi
  80016f:	0f 34                	sysenter 

00800171 <label_139>:
  800171:	5f                   	pop    %edi
  800172:	5e                   	pop    %esi
  800173:	5d                   	pop    %ebp
  800174:	5c                   	pop    %esp
  800175:	5b                   	pop    %ebx
  800176:	5a                   	pop    %edx
  800177:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5f                   	pop    %edi
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800181:	bf 00 00 00 00       	mov    $0x0,%edi
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	89 fb                	mov    %edi,%ebx
  800193:	51                   	push   %ecx
  800194:	52                   	push   %edx
  800195:	53                   	push   %ebx
  800196:	54                   	push   %esp
  800197:	55                   	push   %ebp
  800198:	56                   	push   %esi
  800199:	57                   	push   %edi
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	8d 35 a4 01 80 00    	lea    0x8001a4,%esi
  8001a2:	0f 34                	sysenter 

008001a4 <label_174>:
  8001a4:	5f                   	pop    %edi
  8001a5:	5e                   	pop    %esi
  8001a6:	5d                   	pop    %ebp
  8001a7:	5c                   	pop    %esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5a                   	pop    %edx
  8001aa:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001ab:	5b                   	pop    %ebx
  8001ac:	5f                   	pop    %edi
  8001ad:	5d                   	pop    %ebp
  8001ae:	c3                   	ret    

008001af <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	57                   	push   %edi
  8001b3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	89 cb                	mov    %ecx,%ebx
  8001c3:	89 cf                	mov    %ecx,%edi
  8001c5:	51                   	push   %ecx
  8001c6:	52                   	push   %edx
  8001c7:	53                   	push   %ebx
  8001c8:	54                   	push   %esp
  8001c9:	55                   	push   %ebp
  8001ca:	56                   	push   %esi
  8001cb:	57                   	push   %edi
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	8d 35 d6 01 80 00    	lea    0x8001d6,%esi
  8001d4:	0f 34                	sysenter 

008001d6 <label_209>:
  8001d6:	5f                   	pop    %edi
  8001d7:	5e                   	pop    %esi
  8001d8:	5d                   	pop    %ebp
  8001d9:	5c                   	pop    %esp
  8001da:	5b                   	pop    %ebx
  8001db:	5a                   	pop    %edx
  8001dc:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001dd:	5b                   	pop    %ebx
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001e9:	a1 10 20 80 00       	mov    0x802010,%eax
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	74 11                	je     800203 <_panic+0x22>
		cprintf("%s: ", argv0);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	50                   	push   %eax
  8001f6:	68 a9 11 80 00       	push   $0x8011a9
  8001fb:	e8 d4 00 00 00       	call   8002d4 <cprintf>
  800200:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800203:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800209:	e8 3d ff ff ff       	call   80014b <sys_getenvid>
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	ff 75 0c             	pushl  0xc(%ebp)
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	56                   	push   %esi
  800218:	50                   	push   %eax
  800219:	68 b0 11 80 00       	push   $0x8011b0
  80021e:	e8 b1 00 00 00       	call   8002d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800223:	83 c4 18             	add    $0x18,%esp
  800226:	53                   	push   %ebx
  800227:	ff 75 10             	pushl  0x10(%ebp)
  80022a:	e8 54 00 00 00       	call   800283 <vcprintf>
	cprintf("\n");
  80022f:	c7 04 24 ae 11 80 00 	movl   $0x8011ae,(%esp)
  800236:	e8 99 00 00 00       	call   8002d4 <cprintf>
  80023b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80023e:	cc                   	int3   
  80023f:	eb fd                	jmp    80023e <_panic+0x5d>

00800241 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	53                   	push   %ebx
  800245:	83 ec 04             	sub    $0x4,%esp
  800248:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024b:	8b 13                	mov    (%ebx),%edx
  80024d:	8d 42 01             	lea    0x1(%edx),%eax
  800250:	89 03                	mov    %eax,(%ebx)
  800252:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800255:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800259:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025e:	75 1a                	jne    80027a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800260:	83 ec 08             	sub    $0x8,%esp
  800263:	68 ff 00 00 00       	push   $0xff
  800268:	8d 43 08             	lea    0x8(%ebx),%eax
  80026b:	50                   	push   %eax
  80026c:	e8 29 fe ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  800271:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800277:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80027a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80028c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800293:	00 00 00 
	b.cnt = 0;
  800296:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a0:	ff 75 0c             	pushl  0xc(%ebp)
  8002a3:	ff 75 08             	pushl  0x8(%ebp)
  8002a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ac:	50                   	push   %eax
  8002ad:	68 41 02 80 00       	push   $0x800241
  8002b2:	e8 c0 02 00 00       	call   800577 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b7:	83 c4 08             	add    $0x8,%esp
  8002ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c6:	50                   	push   %eax
  8002c7:	e8 ce fd ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8002cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002dd:	50                   	push   %eax
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 9d ff ff ff       	call   800283 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 1c             	sub    $0x1c,%esp
  8002f1:	89 c7                	mov    %eax,%edi
  8002f3:	89 d6                	mov    %edx,%esi
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800301:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800304:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800308:	0f 85 bf 00 00 00    	jne    8003cd <printnum+0xe5>
  80030e:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800314:	0f 8d de 00 00 00    	jge    8003f8 <printnum+0x110>
		judge_time_for_space = width;
  80031a:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800320:	e9 d3 00 00 00       	jmp    8003f8 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800325:	83 eb 01             	sub    $0x1,%ebx
  800328:	85 db                	test   %ebx,%ebx
  80032a:	7f 37                	jg     800363 <printnum+0x7b>
  80032c:	e9 ea 00 00 00       	jmp    80041b <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800331:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800334:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	83 ec 04             	sub    $0x4,%esp
  800340:	ff 75 dc             	pushl  -0x24(%ebp)
  800343:	ff 75 d8             	pushl  -0x28(%ebp)
  800346:	ff 75 e4             	pushl  -0x1c(%ebp)
  800349:	ff 75 e0             	pushl  -0x20(%ebp)
  80034c:	e8 cf 0c 00 00       	call   801020 <__umoddi3>
  800351:	83 c4 14             	add    $0x14,%esp
  800354:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  80035b:	50                   	push   %eax
  80035c:	ff d7                	call   *%edi
  80035e:	83 c4 10             	add    $0x10,%esp
  800361:	eb 16                	jmp    800379 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	56                   	push   %esi
  800367:	ff 75 18             	pushl  0x18(%ebp)
  80036a:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	83 eb 01             	sub    $0x1,%ebx
  800372:	75 ef                	jne    800363 <printnum+0x7b>
  800374:	e9 a2 00 00 00       	jmp    80041b <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800379:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  80037f:	0f 85 76 01 00 00    	jne    8004fb <printnum+0x213>
		while(num_of_space-- > 0)
  800385:	a1 04 20 80 00       	mov    0x802004,%eax
  80038a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80038d:	89 15 04 20 80 00    	mov    %edx,0x802004
  800393:	85 c0                	test   %eax,%eax
  800395:	7e 1d                	jle    8003b4 <printnum+0xcc>
			putch(' ', putdat);
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	56                   	push   %esi
  80039b:	6a 20                	push   $0x20
  80039d:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80039f:	a1 04 20 80 00       	mov    0x802004,%eax
  8003a4:	8d 50 ff             	lea    -0x1(%eax),%edx
  8003a7:	89 15 04 20 80 00    	mov    %edx,0x802004
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	85 c0                	test   %eax,%eax
  8003b2:	7f e3                	jg     800397 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8003b4:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8003bb:	00 00 00 
		judge_time_for_space = 0;
  8003be:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  8003c5:	00 00 00 
	}
}
  8003c8:	e9 2e 01 00 00       	jmp    8004fb <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e1:	83 fa 00             	cmp    $0x0,%edx
  8003e4:	0f 87 ba 00 00 00    	ja     8004a4 <printnum+0x1bc>
  8003ea:	3b 45 10             	cmp    0x10(%ebp),%eax
  8003ed:	0f 83 b1 00 00 00    	jae    8004a4 <printnum+0x1bc>
  8003f3:	e9 2d ff ff ff       	jmp    800325 <printnum+0x3d>
  8003f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800400:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800403:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800406:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800409:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040c:	83 fa 00             	cmp    $0x0,%edx
  80040f:	77 37                	ja     800448 <printnum+0x160>
  800411:	3b 45 10             	cmp    0x10(%ebp),%eax
  800414:	73 32                	jae    800448 <printnum+0x160>
  800416:	e9 16 ff ff ff       	jmp    800331 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	56                   	push   %esi
  80041f:	83 ec 04             	sub    $0x4,%esp
  800422:	ff 75 dc             	pushl  -0x24(%ebp)
  800425:	ff 75 d8             	pushl  -0x28(%ebp)
  800428:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042b:	ff 75 e0             	pushl  -0x20(%ebp)
  80042e:	e8 ed 0b 00 00       	call   801020 <__umoddi3>
  800433:	83 c4 14             	add    $0x14,%esp
  800436:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  80043d:	50                   	push   %eax
  80043e:	ff d7                	call   *%edi
  800440:	83 c4 10             	add    $0x10,%esp
  800443:	e9 b3 00 00 00       	jmp    8004fb <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800448:	83 ec 0c             	sub    $0xc,%esp
  80044b:	ff 75 18             	pushl  0x18(%ebp)
  80044e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800451:	50                   	push   %eax
  800452:	ff 75 10             	pushl  0x10(%ebp)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 dc             	pushl  -0x24(%ebp)
  80045b:	ff 75 d8             	pushl  -0x28(%ebp)
  80045e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800461:	ff 75 e0             	pushl  -0x20(%ebp)
  800464:	e8 87 0a 00 00       	call   800ef0 <__udivdi3>
  800469:	83 c4 18             	add    $0x18,%esp
  80046c:	52                   	push   %edx
  80046d:	50                   	push   %eax
  80046e:	89 f2                	mov    %esi,%edx
  800470:	89 f8                	mov    %edi,%eax
  800472:	e8 71 fe ff ff       	call   8002e8 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800477:	83 c4 18             	add    $0x18,%esp
  80047a:	56                   	push   %esi
  80047b:	83 ec 04             	sub    $0x4,%esp
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	ff 75 e4             	pushl  -0x1c(%ebp)
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	e8 91 0b 00 00       	call   801020 <__umoddi3>
  80048f:	83 c4 14             	add    $0x14,%esp
  800492:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  800499:	50                   	push   %eax
  80049a:	ff d7                	call   *%edi
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	e9 d5 fe ff ff       	jmp    800379 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	ff 75 18             	pushl  0x18(%ebp)
  8004aa:	83 eb 01             	sub    $0x1,%ebx
  8004ad:	53                   	push   %ebx
  8004ae:	ff 75 10             	pushl  0x10(%ebp)
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c0:	e8 2b 0a 00 00       	call   800ef0 <__udivdi3>
  8004c5:	83 c4 18             	add    $0x18,%esp
  8004c8:	52                   	push   %edx
  8004c9:	50                   	push   %eax
  8004ca:	89 f2                	mov    %esi,%edx
  8004cc:	89 f8                	mov    %edi,%eax
  8004ce:	e8 15 fe ff ff       	call   8002e8 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d3:	83 c4 18             	add    $0x18,%esp
  8004d6:	56                   	push   %esi
  8004d7:	83 ec 04             	sub    $0x4,%esp
  8004da:	ff 75 dc             	pushl  -0x24(%ebp)
  8004dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e6:	e8 35 0b 00 00       	call   801020 <__umoddi3>
  8004eb:	83 c4 14             	add    $0x14,%esp
  8004ee:	0f be 80 d3 11 80 00 	movsbl 0x8011d3(%eax),%eax
  8004f5:	50                   	push   %eax
  8004f6:	ff d7                	call   *%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  8004fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004fe:	5b                   	pop    %ebx
  8004ff:	5e                   	pop    %esi
  800500:	5f                   	pop    %edi
  800501:	5d                   	pop    %ebp
  800502:	c3                   	ret    

00800503 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800506:	83 fa 01             	cmp    $0x1,%edx
  800509:	7e 0e                	jle    800519 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80050b:	8b 10                	mov    (%eax),%edx
  80050d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800510:	89 08                	mov    %ecx,(%eax)
  800512:	8b 02                	mov    (%edx),%eax
  800514:	8b 52 04             	mov    0x4(%edx),%edx
  800517:	eb 22                	jmp    80053b <getuint+0x38>
	else if (lflag)
  800519:	85 d2                	test   %edx,%edx
  80051b:	74 10                	je     80052d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80051d:	8b 10                	mov    (%eax),%edx
  80051f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800522:	89 08                	mov    %ecx,(%eax)
  800524:	8b 02                	mov    (%edx),%eax
  800526:	ba 00 00 00 00       	mov    $0x0,%edx
  80052b:	eb 0e                	jmp    80053b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80052d:	8b 10                	mov    (%eax),%edx
  80052f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800532:	89 08                	mov    %ecx,(%eax)
  800534:	8b 02                	mov    (%edx),%eax
  800536:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80053b:	5d                   	pop    %ebp
  80053c:	c3                   	ret    

0080053d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800543:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800547:	8b 10                	mov    (%eax),%edx
  800549:	3b 50 04             	cmp    0x4(%eax),%edx
  80054c:	73 0a                	jae    800558 <sprintputch+0x1b>
		*b->buf++ = ch;
  80054e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800551:	89 08                	mov    %ecx,(%eax)
  800553:	8b 45 08             	mov    0x8(%ebp),%eax
  800556:	88 02                	mov    %al,(%edx)
}
  800558:	5d                   	pop    %ebp
  800559:	c3                   	ret    

0080055a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800560:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800563:	50                   	push   %eax
  800564:	ff 75 10             	pushl  0x10(%ebp)
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 05 00 00 00       	call   800577 <vprintfmt>
	va_end(ap);
}
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	57                   	push   %edi
  80057b:	56                   	push   %esi
  80057c:	53                   	push   %ebx
  80057d:	83 ec 2c             	sub    $0x2c,%esp
  800580:	8b 7d 08             	mov    0x8(%ebp),%edi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 03                	jmp    80058b <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800588:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80058b:	8b 45 10             	mov    0x10(%ebp),%eax
  80058e:	8d 70 01             	lea    0x1(%eax),%esi
  800591:	0f b6 00             	movzbl (%eax),%eax
  800594:	83 f8 25             	cmp    $0x25,%eax
  800597:	74 27                	je     8005c0 <vprintfmt+0x49>
			if (ch == '\0')
  800599:	85 c0                	test   %eax,%eax
  80059b:	75 0d                	jne    8005aa <vprintfmt+0x33>
  80059d:	e9 9d 04 00 00       	jmp    800a3f <vprintfmt+0x4c8>
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	0f 84 95 04 00 00    	je     800a3f <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	50                   	push   %eax
  8005af:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b1:	83 c6 01             	add    $0x1,%esi
  8005b4:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	83 f8 25             	cmp    $0x25,%eax
  8005be:	75 e2                	jne    8005a2 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c5:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8005c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005d7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005de:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8005e5:	eb 08                	jmp    8005ef <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8005ea:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8d 46 01             	lea    0x1(%esi),%eax
  8005f2:	89 45 10             	mov    %eax,0x10(%ebp)
  8005f5:	0f b6 06             	movzbl (%esi),%eax
  8005f8:	0f b6 d0             	movzbl %al,%edx
  8005fb:	83 e8 23             	sub    $0x23,%eax
  8005fe:	3c 55                	cmp    $0x55,%al
  800600:	0f 87 fa 03 00 00    	ja     800a00 <vprintfmt+0x489>
  800606:	0f b6 c0             	movzbl %al,%eax
  800609:	ff 24 85 dc 12 80 00 	jmp    *0x8012dc(,%eax,4)
  800610:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800613:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800617:	eb d6                	jmp    8005ef <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800619:	8d 42 d0             	lea    -0x30(%edx),%eax
  80061c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80061f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800623:	8d 50 d0             	lea    -0x30(%eax),%edx
  800626:	83 fa 09             	cmp    $0x9,%edx
  800629:	77 6b                	ja     800696 <vprintfmt+0x11f>
  80062b:	8b 75 10             	mov    0x10(%ebp),%esi
  80062e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800631:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800634:	eb 09                	jmp    80063f <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800639:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80063d:	eb b0                	jmp    8005ef <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80063f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800642:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800645:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800649:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80064c:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80064f:	83 f9 09             	cmp    $0x9,%ecx
  800652:	76 eb                	jbe    80063f <vprintfmt+0xc8>
  800654:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800657:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80065a:	eb 3d                	jmp    800699 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	8b 00                	mov    (%eax),%eax
  800667:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80066d:	eb 2a                	jmp    800699 <vprintfmt+0x122>
  80066f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800672:	85 c0                	test   %eax,%eax
  800674:	ba 00 00 00 00       	mov    $0x0,%edx
  800679:	0f 49 d0             	cmovns %eax,%edx
  80067c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 75 10             	mov    0x10(%ebp),%esi
  800682:	e9 68 ff ff ff       	jmp    8005ef <vprintfmt+0x78>
  800687:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80068a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800691:	e9 59 ff ff ff       	jmp    8005ef <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800699:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069d:	0f 89 4c ff ff ff    	jns    8005ef <vprintfmt+0x78>
				width = precision, precision = -1;
  8006a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006b0:	e9 3a ff ff ff       	jmp    8005ef <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006b5:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b9:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006bc:	e9 2e ff ff ff       	jmp    8005ef <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 04             	lea    0x4(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	ff 30                	pushl  (%eax)
  8006d0:	ff d7                	call   *%edi
			break;
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	e9 b1 fe ff ff       	jmp    80058b <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8d 50 04             	lea    0x4(%eax),%edx
  8006e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e3:	8b 00                	mov    (%eax),%eax
  8006e5:	99                   	cltd   
  8006e6:	31 d0                	xor    %edx,%eax
  8006e8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ea:	83 f8 06             	cmp    $0x6,%eax
  8006ed:	7f 0b                	jg     8006fa <vprintfmt+0x183>
  8006ef:	8b 14 85 34 14 80 00 	mov    0x801434(,%eax,4),%edx
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	75 15                	jne    80070f <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  8006fa:	50                   	push   %eax
  8006fb:	68 eb 11 80 00       	push   $0x8011eb
  800700:	53                   	push   %ebx
  800701:	57                   	push   %edi
  800702:	e8 53 fe ff ff       	call   80055a <printfmt>
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	e9 7c fe ff ff       	jmp    80058b <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80070f:	52                   	push   %edx
  800710:	68 f4 11 80 00       	push   $0x8011f4
  800715:	53                   	push   %ebx
  800716:	57                   	push   %edi
  800717:	e8 3e fe ff ff       	call   80055a <printfmt>
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	e9 67 fe ff ff       	jmp    80058b <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)
  80072d:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80072f:	85 c0                	test   %eax,%eax
  800731:	b9 e4 11 80 00       	mov    $0x8011e4,%ecx
  800736:	0f 45 c8             	cmovne %eax,%ecx
  800739:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80073c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800740:	7e 06                	jle    800748 <vprintfmt+0x1d1>
  800742:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800746:	75 19                	jne    800761 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800748:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80074b:	8d 70 01             	lea    0x1(%eax),%esi
  80074e:	0f b6 00             	movzbl (%eax),%eax
  800751:	0f be d0             	movsbl %al,%edx
  800754:	85 d2                	test   %edx,%edx
  800756:	0f 85 9f 00 00 00    	jne    8007fb <vprintfmt+0x284>
  80075c:	e9 8c 00 00 00       	jmp    8007ed <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	ff 75 d0             	pushl  -0x30(%ebp)
  800767:	ff 75 cc             	pushl  -0x34(%ebp)
  80076a:	e8 62 03 00 00       	call   800ad1 <strnlen>
  80076f:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800772:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 c9                	test   %ecx,%ecx
  80077a:	0f 8e a6 02 00 00    	jle    800a26 <vprintfmt+0x4af>
					putch(padc, putdat);
  800780:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800784:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800787:	89 cb                	mov    %ecx,%ebx
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	56                   	push   %esi
  800790:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	83 eb 01             	sub    $0x1,%ebx
  800798:	75 ef                	jne    800789 <vprintfmt+0x212>
  80079a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a0:	e9 81 02 00 00       	jmp    800a26 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007a9:	74 1b                	je     8007c6 <vprintfmt+0x24f>
  8007ab:	0f be c0             	movsbl %al,%eax
  8007ae:	83 e8 20             	sub    $0x20,%eax
  8007b1:	83 f8 5e             	cmp    $0x5e,%eax
  8007b4:	76 10                	jbe    8007c6 <vprintfmt+0x24f>
					putch('?', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	ff 75 0c             	pushl  0xc(%ebp)
  8007bc:	6a 3f                	push   $0x3f
  8007be:	ff 55 08             	call   *0x8(%ebp)
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	eb 0d                	jmp    8007d3 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  8007c6:	83 ec 08             	sub    $0x8,%esp
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	52                   	push   %edx
  8007cd:	ff 55 08             	call   *0x8(%ebp)
  8007d0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d3:	83 ef 01             	sub    $0x1,%edi
  8007d6:	83 c6 01             	add    $0x1,%esi
  8007d9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007dd:	0f be d0             	movsbl %al,%edx
  8007e0:	85 d2                	test   %edx,%edx
  8007e2:	75 31                	jne    800815 <vprintfmt+0x29e>
  8007e4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ed:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f4:	7f 33                	jg     800829 <vprintfmt+0x2b2>
  8007f6:	e9 90 fd ff ff       	jmp    80058b <vprintfmt+0x14>
  8007fb:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800801:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800804:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800807:	eb 0c                	jmp    800815 <vprintfmt+0x29e>
  800809:	89 7d 08             	mov    %edi,0x8(%ebp)
  80080c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800812:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800815:	85 db                	test   %ebx,%ebx
  800817:	78 8c                	js     8007a5 <vprintfmt+0x22e>
  800819:	83 eb 01             	sub    $0x1,%ebx
  80081c:	79 87                	jns    8007a5 <vprintfmt+0x22e>
  80081e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800821:	8b 7d 08             	mov    0x8(%ebp),%edi
  800824:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800827:	eb c4                	jmp    8007ed <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	53                   	push   %ebx
  80082d:	6a 20                	push   $0x20
  80082f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	83 ee 01             	sub    $0x1,%esi
  800837:	75 f0                	jne    800829 <vprintfmt+0x2b2>
  800839:	e9 4d fd ff ff       	jmp    80058b <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083e:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800842:	7e 16                	jle    80085a <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 50 08             	lea    0x8(%eax),%edx
  80084a:	89 55 14             	mov    %edx,0x14(%ebp)
  80084d:	8b 50 04             	mov    0x4(%eax),%edx
  800850:	8b 00                	mov    (%eax),%eax
  800852:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800855:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800858:	eb 34                	jmp    80088e <vprintfmt+0x317>
	else if (lflag)
  80085a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80085e:	74 18                	je     800878 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)
  800869:	8b 30                	mov    (%eax),%esi
  80086b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80086e:	89 f0                	mov    %esi,%eax
  800870:	c1 f8 1f             	sar    $0x1f,%eax
  800873:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800876:	eb 16                	jmp    80088e <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8d 50 04             	lea    0x4(%eax),%edx
  80087e:	89 55 14             	mov    %edx,0x14(%ebp)
  800881:	8b 30                	mov    (%eax),%esi
  800883:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800886:	89 f0                	mov    %esi,%eax
  800888:	c1 f8 1f             	sar    $0x1f,%eax
  80088b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80088e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800894:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800897:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80089a:	85 d2                	test   %edx,%edx
  80089c:	79 28                	jns    8008c6 <vprintfmt+0x34f>
				putch('-', putdat);
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	53                   	push   %ebx
  8008a2:	6a 2d                	push   $0x2d
  8008a4:	ff d7                	call   *%edi
				num = -(long long) num;
  8008a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008a9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008ac:	f7 d8                	neg    %eax
  8008ae:	83 d2 00             	adc    $0x0,%edx
  8008b1:	f7 da                	neg    %edx
  8008b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b9:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  8008bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c1:	e9 b2 00 00 00       	jmp    800978 <vprintfmt+0x401>
  8008c6:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  8008cb:	85 c9                	test   %ecx,%ecx
  8008cd:	0f 84 a5 00 00 00    	je     800978 <vprintfmt+0x401>
				putch('+', putdat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	53                   	push   %ebx
  8008d7:	6a 2b                	push   $0x2b
  8008d9:	ff d7                	call   *%edi
  8008db:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  8008de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e3:	e9 90 00 00 00       	jmp    800978 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 0b                	je     8008f7 <vprintfmt+0x380>
				putch('+', putdat);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	53                   	push   %ebx
  8008f0:	6a 2b                	push   $0x2b
  8008f2:	ff d7                	call   *%edi
  8008f4:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  8008f7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fd:	e8 01 fc ff ff       	call   800503 <getuint>
  800902:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800905:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800908:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80090d:	eb 69                	jmp    800978 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  80090f:	83 ec 08             	sub    $0x8,%esp
  800912:	53                   	push   %ebx
  800913:	6a 30                	push   $0x30
  800915:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800917:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80091a:	8d 45 14             	lea    0x14(%ebp),%eax
  80091d:	e8 e1 fb ff ff       	call   800503 <getuint>
  800922:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800925:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800928:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80092b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800930:	eb 46                	jmp    800978 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800932:	83 ec 08             	sub    $0x8,%esp
  800935:	53                   	push   %ebx
  800936:	6a 30                	push   $0x30
  800938:	ff d7                	call   *%edi
			putch('x', putdat);
  80093a:	83 c4 08             	add    $0x8,%esp
  80093d:	53                   	push   %ebx
  80093e:	6a 78                	push   $0x78
  800940:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 50 04             	lea    0x4(%eax),%edx
  800948:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80094b:	8b 00                	mov    (%eax),%eax
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800955:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800958:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80095b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800960:	eb 16                	jmp    800978 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800962:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800965:	8d 45 14             	lea    0x14(%ebp),%eax
  800968:	e8 96 fb ff ff       	call   800503 <getuint>
  80096d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800970:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800973:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800978:	83 ec 0c             	sub    $0xc,%esp
  80097b:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80097f:	56                   	push   %esi
  800980:	ff 75 e4             	pushl  -0x1c(%ebp)
  800983:	50                   	push   %eax
  800984:	ff 75 dc             	pushl  -0x24(%ebp)
  800987:	ff 75 d8             	pushl  -0x28(%ebp)
  80098a:	89 da                	mov    %ebx,%edx
  80098c:	89 f8                	mov    %edi,%eax
  80098e:	e8 55 f9 ff ff       	call   8002e8 <printnum>
			break;
  800993:	83 c4 20             	add    $0x20,%esp
  800996:	e9 f0 fb ff ff       	jmp    80058b <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  80099b:	8b 45 14             	mov    0x14(%ebp),%eax
  80099e:	8d 50 04             	lea    0x4(%eax),%edx
  8009a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a4:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  8009a6:	85 f6                	test   %esi,%esi
  8009a8:	75 1a                	jne    8009c4 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  8009aa:	83 ec 08             	sub    $0x8,%esp
  8009ad:	68 60 12 80 00       	push   $0x801260
  8009b2:	68 f4 11 80 00       	push   $0x8011f4
  8009b7:	e8 18 f9 ff ff       	call   8002d4 <cprintf>
  8009bc:	83 c4 10             	add    $0x10,%esp
  8009bf:	e9 c7 fb ff ff       	jmp    80058b <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  8009c4:	0f b6 03             	movzbl (%ebx),%eax
  8009c7:	84 c0                	test   %al,%al
  8009c9:	79 1f                	jns    8009ea <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	68 98 12 80 00       	push   $0x801298
  8009d3:	68 f4 11 80 00       	push   $0x8011f4
  8009d8:	e8 f7 f8 ff ff       	call   8002d4 <cprintf>
						*tmp = *(char *)putdat;
  8009dd:	0f b6 03             	movzbl (%ebx),%eax
  8009e0:	88 06                	mov    %al,(%esi)
  8009e2:	83 c4 10             	add    $0x10,%esp
  8009e5:	e9 a1 fb ff ff       	jmp    80058b <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  8009ea:	88 06                	mov    %al,(%esi)
  8009ec:	e9 9a fb ff ff       	jmp    80058b <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009f1:	83 ec 08             	sub    $0x8,%esp
  8009f4:	53                   	push   %ebx
  8009f5:	52                   	push   %edx
  8009f6:	ff d7                	call   *%edi
			break;
  8009f8:	83 c4 10             	add    $0x10,%esp
  8009fb:	e9 8b fb ff ff       	jmp    80058b <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a00:	83 ec 08             	sub    $0x8,%esp
  800a03:	53                   	push   %ebx
  800a04:	6a 25                	push   $0x25
  800a06:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a08:	83 c4 10             	add    $0x10,%esp
  800a0b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a0f:	0f 84 73 fb ff ff    	je     800588 <vprintfmt+0x11>
  800a15:	83 ee 01             	sub    $0x1,%esi
  800a18:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a1c:	75 f7                	jne    800a15 <vprintfmt+0x49e>
  800a1e:	89 75 10             	mov    %esi,0x10(%ebp)
  800a21:	e9 65 fb ff ff       	jmp    80058b <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a26:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a29:	8d 70 01             	lea    0x1(%eax),%esi
  800a2c:	0f b6 00             	movzbl (%eax),%eax
  800a2f:	0f be d0             	movsbl %al,%edx
  800a32:	85 d2                	test   %edx,%edx
  800a34:	0f 85 cf fd ff ff    	jne    800809 <vprintfmt+0x292>
  800a3a:	e9 4c fb ff ff       	jmp    80058b <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	83 ec 18             	sub    $0x18,%esp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a56:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a5a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a64:	85 c0                	test   %eax,%eax
  800a66:	74 26                	je     800a8e <vsnprintf+0x47>
  800a68:	85 d2                	test   %edx,%edx
  800a6a:	7e 22                	jle    800a8e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a6c:	ff 75 14             	pushl  0x14(%ebp)
  800a6f:	ff 75 10             	pushl  0x10(%ebp)
  800a72:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a75:	50                   	push   %eax
  800a76:	68 3d 05 80 00       	push   $0x80053d
  800a7b:	e8 f7 fa ff ff       	call   800577 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a83:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	eb 05                	jmp    800a93 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a93:	c9                   	leave  
  800a94:	c3                   	ret    

00800a95 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a9b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a9e:	50                   	push   %eax
  800a9f:	ff 75 10             	pushl  0x10(%ebp)
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	ff 75 08             	pushl  0x8(%ebp)
  800aa8:	e8 9a ff ff ff       	call   800a47 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab5:	80 3a 00             	cmpb   $0x0,(%edx)
  800ab8:	74 10                	je     800aca <strlen+0x1b>
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800abf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac6:	75 f7                	jne    800abf <strlen+0x10>
  800ac8:	eb 05                	jmp    800acf <strlen+0x20>
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	53                   	push   %ebx
  800ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800adb:	85 c9                	test   %ecx,%ecx
  800add:	74 1c                	je     800afb <strnlen+0x2a>
  800adf:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ae2:	74 1e                	je     800b02 <strnlen+0x31>
  800ae4:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800ae9:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aeb:	39 ca                	cmp    %ecx,%edx
  800aed:	74 18                	je     800b07 <strnlen+0x36>
  800aef:	83 c2 01             	add    $0x1,%edx
  800af2:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800af7:	75 f0                	jne    800ae9 <strnlen+0x18>
  800af9:	eb 0c                	jmp    800b07 <strnlen+0x36>
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
  800b00:	eb 05                	jmp    800b07 <strnlen+0x36>
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b07:	5b                   	pop    %ebx
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b14:	89 c2                	mov    %eax,%edx
  800b16:	83 c2 01             	add    $0x1,%edx
  800b19:	83 c1 01             	add    $0x1,%ecx
  800b1c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b20:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b23:	84 db                	test   %bl,%bl
  800b25:	75 ef                	jne    800b16 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b27:	5b                   	pop    %ebx
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	53                   	push   %ebx
  800b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b31:	53                   	push   %ebx
  800b32:	e8 78 ff ff ff       	call   800aaf <strlen>
  800b37:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b3a:	ff 75 0c             	pushl  0xc(%ebp)
  800b3d:	01 d8                	add    %ebx,%eax
  800b3f:	50                   	push   %eax
  800b40:	e8 c5 ff ff ff       	call   800b0a <strcpy>
	return dst;
}
  800b45:	89 d8                	mov    %ebx,%eax
  800b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	8b 75 08             	mov    0x8(%ebp),%esi
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	74 17                	je     800b75 <strncpy+0x29>
  800b5e:	01 f3                	add    %esi,%ebx
  800b60:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b62:	83 c1 01             	add    $0x1,%ecx
  800b65:	0f b6 02             	movzbl (%edx),%eax
  800b68:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b6b:	80 3a 01             	cmpb   $0x1,(%edx)
  800b6e:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b71:	39 cb                	cmp    %ecx,%ebx
  800b73:	75 ed                	jne    800b62 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b75:	89 f0                	mov    %esi,%eax
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	8b 75 08             	mov    0x8(%ebp),%esi
  800b83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b86:	8b 55 10             	mov    0x10(%ebp),%edx
  800b89:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b8b:	85 d2                	test   %edx,%edx
  800b8d:	74 35                	je     800bc4 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	83 e8 01             	sub    $0x1,%eax
  800b94:	74 25                	je     800bbb <strlcpy+0x40>
  800b96:	0f b6 0b             	movzbl (%ebx),%ecx
  800b99:	84 c9                	test   %cl,%cl
  800b9b:	74 22                	je     800bbf <strlcpy+0x44>
  800b9d:	8d 53 01             	lea    0x1(%ebx),%edx
  800ba0:	01 c3                	add    %eax,%ebx
  800ba2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ba4:	83 c0 01             	add    $0x1,%eax
  800ba7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800baa:	39 da                	cmp    %ebx,%edx
  800bac:	74 13                	je     800bc1 <strlcpy+0x46>
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800bb5:	84 c9                	test   %cl,%cl
  800bb7:	75 eb                	jne    800ba4 <strlcpy+0x29>
  800bb9:	eb 06                	jmp    800bc1 <strlcpy+0x46>
  800bbb:	89 f0                	mov    %esi,%eax
  800bbd:	eb 02                	jmp    800bc1 <strlcpy+0x46>
  800bbf:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bc1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc4:	29 f0                	sub    %esi,%eax
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bd3:	0f b6 01             	movzbl (%ecx),%eax
  800bd6:	84 c0                	test   %al,%al
  800bd8:	74 15                	je     800bef <strcmp+0x25>
  800bda:	3a 02                	cmp    (%edx),%al
  800bdc:	75 11                	jne    800bef <strcmp+0x25>
		p++, q++;
  800bde:	83 c1 01             	add    $0x1,%ecx
  800be1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800be4:	0f b6 01             	movzbl (%ecx),%eax
  800be7:	84 c0                	test   %al,%al
  800be9:	74 04                	je     800bef <strcmp+0x25>
  800beb:	3a 02                	cmp    (%edx),%al
  800bed:	74 ef                	je     800bde <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bef:	0f b6 c0             	movzbl %al,%eax
  800bf2:	0f b6 12             	movzbl (%edx),%edx
  800bf5:	29 d0                	sub    %edx,%eax
}
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c04:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c07:	85 f6                	test   %esi,%esi
  800c09:	74 29                	je     800c34 <strncmp+0x3b>
  800c0b:	0f b6 03             	movzbl (%ebx),%eax
  800c0e:	84 c0                	test   %al,%al
  800c10:	74 30                	je     800c42 <strncmp+0x49>
  800c12:	3a 02                	cmp    (%edx),%al
  800c14:	75 2c                	jne    800c42 <strncmp+0x49>
  800c16:	8d 43 01             	lea    0x1(%ebx),%eax
  800c19:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800c1b:	89 c3                	mov    %eax,%ebx
  800c1d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c20:	39 c6                	cmp    %eax,%esi
  800c22:	74 17                	je     800c3b <strncmp+0x42>
  800c24:	0f b6 08             	movzbl (%eax),%ecx
  800c27:	84 c9                	test   %cl,%cl
  800c29:	74 17                	je     800c42 <strncmp+0x49>
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	3a 0a                	cmp    (%edx),%cl
  800c30:	74 e9                	je     800c1b <strncmp+0x22>
  800c32:	eb 0e                	jmp    800c42 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
  800c39:	eb 0f                	jmp    800c4a <strncmp+0x51>
  800c3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c40:	eb 08                	jmp    800c4a <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c42:	0f b6 03             	movzbl (%ebx),%eax
  800c45:	0f b6 12             	movzbl (%edx),%edx
  800c48:	29 d0                	sub    %edx,%eax
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	53                   	push   %ebx
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c58:	0f b6 10             	movzbl (%eax),%edx
  800c5b:	84 d2                	test   %dl,%dl
  800c5d:	74 1d                	je     800c7c <strchr+0x2e>
  800c5f:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800c61:	38 d3                	cmp    %dl,%bl
  800c63:	75 06                	jne    800c6b <strchr+0x1d>
  800c65:	eb 1a                	jmp    800c81 <strchr+0x33>
  800c67:	38 ca                	cmp    %cl,%dl
  800c69:	74 16                	je     800c81 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c6b:	83 c0 01             	add    $0x1,%eax
  800c6e:	0f b6 10             	movzbl (%eax),%edx
  800c71:	84 d2                	test   %dl,%dl
  800c73:	75 f2                	jne    800c67 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7a:	eb 05                	jmp    800c81 <strchr+0x33>
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c81:	5b                   	pop    %ebx
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	53                   	push   %ebx
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c8e:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c91:	38 d3                	cmp    %dl,%bl
  800c93:	74 14                	je     800ca9 <strfind+0x25>
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	84 db                	test   %bl,%bl
  800c99:	74 0e                	je     800ca9 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c9b:	83 c0 01             	add    $0x1,%eax
  800c9e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ca1:	38 ca                	cmp    %cl,%dl
  800ca3:	74 04                	je     800ca9 <strfind+0x25>
  800ca5:	84 d2                	test   %dl,%dl
  800ca7:	75 f2                	jne    800c9b <strfind+0x17>
			break;
	return (char *) s;
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb8:	85 c9                	test   %ecx,%ecx
  800cba:	74 36                	je     800cf2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cbc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cc2:	75 28                	jne    800cec <memset+0x40>
  800cc4:	f6 c1 03             	test   $0x3,%cl
  800cc7:	75 23                	jne    800cec <memset+0x40>
		c &= 0xFF;
  800cc9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	c1 e3 08             	shl    $0x8,%ebx
  800cd2:	89 d6                	mov    %edx,%esi
  800cd4:	c1 e6 18             	shl    $0x18,%esi
  800cd7:	89 d0                	mov    %edx,%eax
  800cd9:	c1 e0 10             	shl    $0x10,%eax
  800cdc:	09 f0                	or     %esi,%eax
  800cde:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ce0:	89 d8                	mov    %ebx,%eax
  800ce2:	09 d0                	or     %edx,%eax
  800ce4:	c1 e9 02             	shr    $0x2,%ecx
  800ce7:	fc                   	cld    
  800ce8:	f3 ab                	rep stos %eax,%es:(%edi)
  800cea:	eb 06                	jmp    800cf2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cef:	fc                   	cld    
  800cf0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cf2:	89 f8                	mov    %edi,%eax
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d07:	39 c6                	cmp    %eax,%esi
  800d09:	73 35                	jae    800d40 <memmove+0x47>
  800d0b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d0e:	39 d0                	cmp    %edx,%eax
  800d10:	73 2e                	jae    800d40 <memmove+0x47>
		s += n;
		d += n;
  800d12:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d15:	89 d6                	mov    %edx,%esi
  800d17:	09 fe                	or     %edi,%esi
  800d19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d1f:	75 13                	jne    800d34 <memmove+0x3b>
  800d21:	f6 c1 03             	test   $0x3,%cl
  800d24:	75 0e                	jne    800d34 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d26:	83 ef 04             	sub    $0x4,%edi
  800d29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d2c:	c1 e9 02             	shr    $0x2,%ecx
  800d2f:	fd                   	std    
  800d30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d32:	eb 09                	jmp    800d3d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d34:	83 ef 01             	sub    $0x1,%edi
  800d37:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d3a:	fd                   	std    
  800d3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d3d:	fc                   	cld    
  800d3e:	eb 1d                	jmp    800d5d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d40:	89 f2                	mov    %esi,%edx
  800d42:	09 c2                	or     %eax,%edx
  800d44:	f6 c2 03             	test   $0x3,%dl
  800d47:	75 0f                	jne    800d58 <memmove+0x5f>
  800d49:	f6 c1 03             	test   $0x3,%cl
  800d4c:	75 0a                	jne    800d58 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d4e:	c1 e9 02             	shr    $0x2,%ecx
  800d51:	89 c7                	mov    %eax,%edi
  800d53:	fc                   	cld    
  800d54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d56:	eb 05                	jmp    800d5d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d58:	89 c7                	mov    %eax,%edi
  800d5a:	fc                   	cld    
  800d5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d64:	ff 75 10             	pushl  0x10(%ebp)
  800d67:	ff 75 0c             	pushl  0xc(%ebp)
  800d6a:	ff 75 08             	pushl  0x8(%ebp)
  800d6d:	e8 87 ff ff ff       	call   800cf9 <memmove>
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d80:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d83:	85 c0                	test   %eax,%eax
  800d85:	74 39                	je     800dc0 <memcmp+0x4c>
  800d87:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800d8a:	0f b6 13             	movzbl (%ebx),%edx
  800d8d:	0f b6 0e             	movzbl (%esi),%ecx
  800d90:	38 ca                	cmp    %cl,%dl
  800d92:	75 17                	jne    800dab <memcmp+0x37>
  800d94:	b8 00 00 00 00       	mov    $0x0,%eax
  800d99:	eb 1a                	jmp    800db5 <memcmp+0x41>
  800d9b:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800da0:	83 c0 01             	add    $0x1,%eax
  800da3:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800da7:	38 ca                	cmp    %cl,%dl
  800da9:	74 0a                	je     800db5 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800dab:	0f b6 c2             	movzbl %dl,%eax
  800dae:	0f b6 c9             	movzbl %cl,%ecx
  800db1:	29 c8                	sub    %ecx,%eax
  800db3:	eb 10                	jmp    800dc5 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800db5:	39 f8                	cmp    %edi,%eax
  800db7:	75 e2                	jne    800d9b <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	eb 05                	jmp    800dc5 <memcmp+0x51>
  800dc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	53                   	push   %ebx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800dd1:	89 d0                	mov    %edx,%eax
  800dd3:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800dd6:	39 c2                	cmp    %eax,%edx
  800dd8:	73 1d                	jae    800df7 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dda:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800dde:	0f b6 0a             	movzbl (%edx),%ecx
  800de1:	39 d9                	cmp    %ebx,%ecx
  800de3:	75 09                	jne    800dee <memfind+0x24>
  800de5:	eb 14                	jmp    800dfb <memfind+0x31>
  800de7:	0f b6 0a             	movzbl (%edx),%ecx
  800dea:	39 d9                	cmp    %ebx,%ecx
  800dec:	74 11                	je     800dff <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dee:	83 c2 01             	add    $0x1,%edx
  800df1:	39 d0                	cmp    %edx,%eax
  800df3:	75 f2                	jne    800de7 <memfind+0x1d>
  800df5:	eb 0a                	jmp    800e01 <memfind+0x37>
  800df7:	89 d0                	mov    %edx,%eax
  800df9:	eb 06                	jmp    800e01 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dfb:	89 d0                	mov    %edx,%eax
  800dfd:	eb 02                	jmp    800e01 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dff:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e01:	5b                   	pop    %ebx
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e10:	0f b6 01             	movzbl (%ecx),%eax
  800e13:	3c 20                	cmp    $0x20,%al
  800e15:	74 04                	je     800e1b <strtol+0x17>
  800e17:	3c 09                	cmp    $0x9,%al
  800e19:	75 0e                	jne    800e29 <strtol+0x25>
		s++;
  800e1b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1e:	0f b6 01             	movzbl (%ecx),%eax
  800e21:	3c 20                	cmp    $0x20,%al
  800e23:	74 f6                	je     800e1b <strtol+0x17>
  800e25:	3c 09                	cmp    $0x9,%al
  800e27:	74 f2                	je     800e1b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e29:	3c 2b                	cmp    $0x2b,%al
  800e2b:	75 0a                	jne    800e37 <strtol+0x33>
		s++;
  800e2d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e30:	bf 00 00 00 00       	mov    $0x0,%edi
  800e35:	eb 11                	jmp    800e48 <strtol+0x44>
  800e37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e3c:	3c 2d                	cmp    $0x2d,%al
  800e3e:	75 08                	jne    800e48 <strtol+0x44>
		s++, neg = 1;
  800e40:	83 c1 01             	add    $0x1,%ecx
  800e43:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e48:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e4e:	75 15                	jne    800e65 <strtol+0x61>
  800e50:	80 39 30             	cmpb   $0x30,(%ecx)
  800e53:	75 10                	jne    800e65 <strtol+0x61>
  800e55:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e59:	75 7c                	jne    800ed7 <strtol+0xd3>
		s += 2, base = 16;
  800e5b:	83 c1 02             	add    $0x2,%ecx
  800e5e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e63:	eb 16                	jmp    800e7b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800e65:	85 db                	test   %ebx,%ebx
  800e67:	75 12                	jne    800e7b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e69:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800e71:	75 08                	jne    800e7b <strtol+0x77>
		s++, base = 8;
  800e73:	83 c1 01             	add    $0x1,%ecx
  800e76:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e83:	0f b6 11             	movzbl (%ecx),%edx
  800e86:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e89:	89 f3                	mov    %esi,%ebx
  800e8b:	80 fb 09             	cmp    $0x9,%bl
  800e8e:	77 08                	ja     800e98 <strtol+0x94>
			dig = *s - '0';
  800e90:	0f be d2             	movsbl %dl,%edx
  800e93:	83 ea 30             	sub    $0x30,%edx
  800e96:	eb 22                	jmp    800eba <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800e98:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e9b:	89 f3                	mov    %esi,%ebx
  800e9d:	80 fb 19             	cmp    $0x19,%bl
  800ea0:	77 08                	ja     800eaa <strtol+0xa6>
			dig = *s - 'a' + 10;
  800ea2:	0f be d2             	movsbl %dl,%edx
  800ea5:	83 ea 57             	sub    $0x57,%edx
  800ea8:	eb 10                	jmp    800eba <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800eaa:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ead:	89 f3                	mov    %esi,%ebx
  800eaf:	80 fb 19             	cmp    $0x19,%bl
  800eb2:	77 16                	ja     800eca <strtol+0xc6>
			dig = *s - 'A' + 10;
  800eb4:	0f be d2             	movsbl %dl,%edx
  800eb7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800eba:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ebd:	7d 0b                	jge    800eca <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800ebf:	83 c1 01             	add    $0x1,%ecx
  800ec2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ec6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ec8:	eb b9                	jmp    800e83 <strtol+0x7f>

	if (endptr)
  800eca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ece:	74 0d                	je     800edd <strtol+0xd9>
		*endptr = (char *) s;
  800ed0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed3:	89 0e                	mov    %ecx,(%esi)
  800ed5:	eb 06                	jmp    800edd <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ed7:	85 db                	test   %ebx,%ebx
  800ed9:	74 98                	je     800e73 <strtol+0x6f>
  800edb:	eb 9e                	jmp    800e7b <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	f7 da                	neg    %edx
  800ee1:	85 ff                	test   %edi,%edi
  800ee3:	0f 45 c2             	cmovne %edx,%eax
}
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    
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
