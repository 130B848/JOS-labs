
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
  800057:	c1 e0 07             	shl    $0x7,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 0c 20 80 00       	mov    %eax,0x80200c

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
  8000b1:	56                   	push   %esi
  8000b2:	57                   	push   %edi
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	8d 35 be 00 80 00    	lea    0x8000be,%esi
  8000bc:	0f 34                	sysenter 

008000be <label_21>:
  8000be:	89 ec                	mov    %ebp,%esp
  8000c0:	5d                   	pop    %ebp
  8000c1:	5f                   	pop    %edi
  8000c2:	5e                   	pop    %esi
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
  8000e2:	56                   	push   %esi
  8000e3:	57                   	push   %edi
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	8d 35 ef 00 80 00    	lea    0x8000ef,%esi
  8000ed:	0f 34                	sysenter 

008000ef <label_55>:
  8000ef:	89 ec                	mov    %ebp,%esp
  8000f1:	5d                   	pop    %ebp
  8000f2:	5f                   	pop    %edi
  8000f3:	5e                   	pop    %esi
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
  800114:	56                   	push   %esi
  800115:	57                   	push   %edi
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	8d 35 21 01 80 00    	lea    0x800121,%esi
  80011f:	0f 34                	sysenter 

00800121 <label_90>:
  800121:	89 ec                	mov    %ebp,%esp
  800123:	5d                   	pop    %ebp
  800124:	5f                   	pop    %edi
  800125:	5e                   	pop    %esi
  800126:	5b                   	pop    %ebx
  800127:	5a                   	pop    %edx
  800128:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800129:	85 c0                	test   %eax,%eax
  80012b:	7e 17                	jle    800144 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	6a 03                	push   $0x3
  800133:	68 0a 14 80 00       	push   $0x80140a
  800138:	6a 29                	push   $0x29
  80013a:	68 27 14 80 00       	push   $0x801427
  80013f:	e8 06 03 00 00       	call   80044a <_panic>

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
  800163:	56                   	push   %esi
  800164:	57                   	push   %edi
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	8d 35 70 01 80 00    	lea    0x800170,%esi
  80016e:	0f 34                	sysenter 

00800170 <label_139>:
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	5f                   	pop    %edi
  800174:	5e                   	pop    %esi
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
  800196:	56                   	push   %esi
  800197:	57                   	push   %edi
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	8d 35 a3 01 80 00    	lea    0x8001a3,%esi
  8001a1:	0f 34                	sysenter 

008001a3 <label_174>:
  8001a3:	89 ec                	mov    %ebp,%esp
  8001a5:	5d                   	pop    %ebp
  8001a6:	5f                   	pop    %edi
  8001a7:	5e                   	pop    %esi
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

008001af <sys_yield>:

void
sys_yield(void)
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
  8001b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001be:	89 d1                	mov    %edx,%ecx
  8001c0:	89 d3                	mov    %edx,%ebx
  8001c2:	89 d7                	mov    %edx,%edi
  8001c4:	51                   	push   %ecx
  8001c5:	52                   	push   %edx
  8001c6:	53                   	push   %ebx
  8001c7:	56                   	push   %esi
  8001c8:	57                   	push   %edi
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	8d 35 d4 01 80 00    	lea    0x8001d4,%esi
  8001d2:	0f 34                	sysenter 

008001d4 <label_209>:
  8001d4:	89 ec                	mov    %ebp,%esp
  8001d6:	5d                   	pop    %ebp
  8001d7:	5f                   	pop    %edi
  8001d8:	5e                   	pop    %esi
  8001d9:	5b                   	pop    %ebx
  8001da:	5a                   	pop    %edx
  8001db:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001dc:	5b                   	pop    %ebx
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	51                   	push   %ecx
  8001f9:	52                   	push   %edx
  8001fa:	53                   	push   %ebx
  8001fb:	56                   	push   %esi
  8001fc:	57                   	push   %edi
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	8d 35 08 02 80 00    	lea    0x800208,%esi
  800206:	0f 34                	sysenter 

00800208 <label_244>:
  800208:	89 ec                	mov    %ebp,%esp
  80020a:	5d                   	pop    %ebp
  80020b:	5f                   	pop    %edi
  80020c:	5e                   	pop    %esi
  80020d:	5b                   	pop    %ebx
  80020e:	5a                   	pop    %edx
  80020f:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800210:	85 c0                	test   %eax,%eax
  800212:	7e 17                	jle    80022b <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	50                   	push   %eax
  800218:	6a 05                	push   $0x5
  80021a:	68 0a 14 80 00       	push   $0x80140a
  80021f:	6a 29                	push   $0x29
  800221:	68 27 14 80 00       	push   $0x801427
  800226:	e8 1f 02 00 00       	call   80044a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5f                   	pop    %edi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	53                   	push   %ebx
  800237:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800240:	8b 45 0c             	mov    0xc(%ebp),%eax
  800243:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800246:	8b 45 10             	mov    0x10(%ebp),%eax
  800249:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  80024c:	8b 45 14             	mov    0x14(%ebp),%eax
  80024f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800252:	8b 45 18             	mov    0x18(%ebp),%eax
  800255:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800258:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80025b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800260:	b8 06 00 00 00       	mov    $0x6,%eax
  800265:	89 cb                	mov    %ecx,%ebx
  800267:	89 cf                	mov    %ecx,%edi
  800269:	51                   	push   %ecx
  80026a:	52                   	push   %edx
  80026b:	53                   	push   %ebx
  80026c:	56                   	push   %esi
  80026d:	57                   	push   %edi
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	8d 35 79 02 80 00    	lea    0x800279,%esi
  800277:	0f 34                	sysenter 

00800279 <label_304>:
  800279:	89 ec                	mov    %ebp,%esp
  80027b:	5d                   	pop    %ebp
  80027c:	5f                   	pop    %edi
  80027d:	5e                   	pop    %esi
  80027e:	5b                   	pop    %ebx
  80027f:	5a                   	pop    %edx
  800280:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800281:	85 c0                	test   %eax,%eax
  800283:	7e 17                	jle    80029c <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800285:	83 ec 0c             	sub    $0xc,%esp
  800288:	50                   	push   %eax
  800289:	6a 06                	push   $0x6
  80028b:	68 0a 14 80 00       	push   $0x80140a
  800290:	6a 29                	push   $0x29
  800292:	68 27 14 80 00       	push   $0x801427
  800297:	e8 ae 01 00 00       	call   80044a <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  80029c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5f                   	pop    %edi
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8002ad:	b8 07 00 00 00       	mov    $0x7,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 fb                	mov    %edi,%ebx
  8002ba:	51                   	push   %ecx
  8002bb:	52                   	push   %edx
  8002bc:	53                   	push   %ebx
  8002bd:	56                   	push   %esi
  8002be:	57                   	push   %edi
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	8d 35 ca 02 80 00    	lea    0x8002ca,%esi
  8002c8:	0f 34                	sysenter 

008002ca <label_353>:
  8002ca:	89 ec                	mov    %ebp,%esp
  8002cc:	5d                   	pop    %ebp
  8002cd:	5f                   	pop    %edi
  8002ce:	5e                   	pop    %esi
  8002cf:	5b                   	pop    %ebx
  8002d0:	5a                   	pop    %edx
  8002d1:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	7e 17                	jle    8002ed <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d6:	83 ec 0c             	sub    $0xc,%esp
  8002d9:	50                   	push   %eax
  8002da:	6a 07                	push   $0x7
  8002dc:	68 0a 14 80 00       	push   $0x80140a
  8002e1:	6a 29                	push   $0x29
  8002e3:	68 27 14 80 00       	push   $0x801427
  8002e8:	e8 5d 01 00 00       	call   80044a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	57                   	push   %edi
  8002f8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8002fe:	b8 09 00 00 00       	mov    $0x9,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	89 fb                	mov    %edi,%ebx
  80030b:	51                   	push   %ecx
  80030c:	52                   	push   %edx
  80030d:	53                   	push   %ebx
  80030e:	56                   	push   %esi
  80030f:	57                   	push   %edi
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	8d 35 1b 03 80 00    	lea    0x80031b,%esi
  800319:	0f 34                	sysenter 

0080031b <label_402>:
  80031b:	89 ec                	mov    %ebp,%esp
  80031d:	5d                   	pop    %ebp
  80031e:	5f                   	pop    %edi
  80031f:	5e                   	pop    %esi
  800320:	5b                   	pop    %ebx
  800321:	5a                   	pop    %edx
  800322:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 09                	push   $0x9
  80032d:	68 0a 14 80 00       	push   $0x80140a
  800332:	6a 29                	push   $0x29
  800334:	68 27 14 80 00       	push   $0x801427
  800339:	e8 0c 01 00 00       	call   80044a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80033e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80034a:	bf 00 00 00 00       	mov    $0x0,%edi
  80034f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800354:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800357:	8b 55 08             	mov    0x8(%ebp),%edx
  80035a:	89 fb                	mov    %edi,%ebx
  80035c:	51                   	push   %ecx
  80035d:	52                   	push   %edx
  80035e:	53                   	push   %ebx
  80035f:	56                   	push   %esi
  800360:	57                   	push   %edi
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	8d 35 6c 03 80 00    	lea    0x80036c,%esi
  80036a:	0f 34                	sysenter 

0080036c <label_451>:
  80036c:	89 ec                	mov    %ebp,%esp
  80036e:	5d                   	pop    %ebp
  80036f:	5f                   	pop    %edi
  800370:	5e                   	pop    %esi
  800371:	5b                   	pop    %ebx
  800372:	5a                   	pop    %edx
  800373:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	7e 17                	jle    80038f <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800378:	83 ec 0c             	sub    $0xc,%esp
  80037b:	50                   	push   %eax
  80037c:	6a 0a                	push   $0xa
  80037e:	68 0a 14 80 00       	push   $0x80140a
  800383:	6a 29                	push   $0x29
  800385:	68 27 14 80 00       	push   $0x801427
  80038a:	e8 bb 00 00 00       	call   80044a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80038f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80039b:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003ac:	51                   	push   %ecx
  8003ad:	52                   	push   %edx
  8003ae:	53                   	push   %ebx
  8003af:	56                   	push   %esi
  8003b0:	57                   	push   %edi
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	8d 35 bc 03 80 00    	lea    0x8003bc,%esi
  8003ba:	0f 34                	sysenter 

008003bc <label_502>:
  8003bc:	89 ec                	mov    %ebp,%esp
  8003be:	5d                   	pop    %ebp
  8003bf:	5f                   	pop    %edi
  8003c0:	5e                   	pop    %esi
  8003c1:	5b                   	pop    %ebx
  8003c2:	5a                   	pop    %edx
  8003c3:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003c4:	5b                   	pop    %ebx
  8003c5:	5f                   	pop    %edi
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	57                   	push   %edi
  8003cc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d2:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003da:	89 d9                	mov    %ebx,%ecx
  8003dc:	89 df                	mov    %ebx,%edi
  8003de:	51                   	push   %ecx
  8003df:	52                   	push   %edx
  8003e0:	53                   	push   %ebx
  8003e1:	56                   	push   %esi
  8003e2:	57                   	push   %edi
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	8d 35 ee 03 80 00    	lea    0x8003ee,%esi
  8003ec:	0f 34                	sysenter 

008003ee <label_537>:
  8003ee:	89 ec                	mov    %ebp,%esp
  8003f0:	5d                   	pop    %ebp
  8003f1:	5f                   	pop    %edi
  8003f2:	5e                   	pop    %esi
  8003f3:	5b                   	pop    %ebx
  8003f4:	5a                   	pop    %edx
  8003f5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	7e 17                	jle    800411 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003fa:	83 ec 0c             	sub    $0xc,%esp
  8003fd:	50                   	push   %eax
  8003fe:	6a 0d                	push   $0xd
  800400:	68 0a 14 80 00       	push   $0x80140a
  800405:	6a 29                	push   $0x29
  800407:	68 27 14 80 00       	push   $0x801427
  80040c:	e8 39 00 00 00       	call   80044a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800411:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800414:	5b                   	pop    %ebx
  800415:	5f                   	pop    %edi
  800416:	5d                   	pop    %ebp
  800417:	c3                   	ret    

00800418 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	57                   	push   %edi
  80041c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80041d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800422:	b8 0e 00 00 00       	mov    $0xe,%eax
  800427:	8b 55 08             	mov    0x8(%ebp),%edx
  80042a:	89 cb                	mov    %ecx,%ebx
  80042c:	89 cf                	mov    %ecx,%edi
  80042e:	51                   	push   %ecx
  80042f:	52                   	push   %edx
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	57                   	push   %edi
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	8d 35 3e 04 80 00    	lea    0x80043e,%esi
  80043c:	0f 34                	sysenter 

0080043e <label_586>:
  80043e:	89 ec                	mov    %ebp,%esp
  800440:	5d                   	pop    %ebp
  800441:	5f                   	pop    %edi
  800442:	5e                   	pop    %esi
  800443:	5b                   	pop    %ebx
  800444:	5a                   	pop    %edx
  800445:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800446:	5b                   	pop    %ebx
  800447:	5f                   	pop    %edi
  800448:	5d                   	pop    %ebp
  800449:	c3                   	ret    

0080044a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	56                   	push   %esi
  80044e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80044f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800452:	a1 10 20 80 00       	mov    0x802010,%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	74 11                	je     80046c <_panic+0x22>
		cprintf("%s: ", argv0);
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	50                   	push   %eax
  80045f:	68 35 14 80 00       	push   $0x801435
  800464:	e8 d4 00 00 00       	call   80053d <cprintf>
  800469:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800472:	e8 d4 fc ff ff       	call   80014b <sys_getenvid>
  800477:	83 ec 0c             	sub    $0xc,%esp
  80047a:	ff 75 0c             	pushl  0xc(%ebp)
  80047d:	ff 75 08             	pushl  0x8(%ebp)
  800480:	56                   	push   %esi
  800481:	50                   	push   %eax
  800482:	68 3c 14 80 00       	push   $0x80143c
  800487:	e8 b1 00 00 00       	call   80053d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80048c:	83 c4 18             	add    $0x18,%esp
  80048f:	53                   	push   %ebx
  800490:	ff 75 10             	pushl  0x10(%ebp)
  800493:	e8 54 00 00 00       	call   8004ec <vcprintf>
	cprintf("\n");
  800498:	c7 04 24 3a 14 80 00 	movl   $0x80143a,(%esp)
  80049f:	e8 99 00 00 00       	call   80053d <cprintf>
  8004a4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a7:	cc                   	int3   
  8004a8:	eb fd                	jmp    8004a7 <_panic+0x5d>

008004aa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 04             	sub    $0x4,%esp
  8004b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b4:	8b 13                	mov    (%ebx),%edx
  8004b6:	8d 42 01             	lea    0x1(%edx),%eax
  8004b9:	89 03                	mov    %eax,(%ebx)
  8004bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004be:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c7:	75 1a                	jne    8004e3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	68 ff 00 00 00       	push   $0xff
  8004d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d4:	50                   	push   %eax
  8004d5:	e8 c0 fb ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8004da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004e0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004f5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fc:	00 00 00 
	b.cnt = 0;
  8004ff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800506:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	ff 75 08             	pushl  0x8(%ebp)
  80050f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800515:	50                   	push   %eax
  800516:	68 aa 04 80 00       	push   $0x8004aa
  80051b:	e8 c0 02 00 00       	call   8007e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800520:	83 c4 08             	add    $0x8,%esp
  800523:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800529:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80052f:	50                   	push   %eax
  800530:	e8 65 fb ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  800535:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800543:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 9d ff ff ff       	call   8004ec <vcprintf>
	va_end(ap);

	return cnt;
}
  80054f:	c9                   	leave  
  800550:	c3                   	ret    

00800551 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	57                   	push   %edi
  800555:	56                   	push   %esi
  800556:	53                   	push   %ebx
  800557:	83 ec 1c             	sub    $0x1c,%esp
  80055a:	89 c7                	mov    %eax,%edi
  80055c:	89 d6                	mov    %edx,%esi
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	8b 55 0c             	mov    0xc(%ebp),%edx
  800564:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800567:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80056a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80056d:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800571:	0f 85 bf 00 00 00    	jne    800636 <printnum+0xe5>
  800577:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  80057d:	0f 8d de 00 00 00    	jge    800661 <printnum+0x110>
		judge_time_for_space = width;
  800583:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800589:	e9 d3 00 00 00       	jmp    800661 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80058e:	83 eb 01             	sub    $0x1,%ebx
  800591:	85 db                	test   %ebx,%ebx
  800593:	7f 37                	jg     8005cc <printnum+0x7b>
  800595:	e9 ea 00 00 00       	jmp    800684 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80059a:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80059d:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	56                   	push   %esi
  8005a6:	83 ec 04             	sub    $0x4,%esp
  8005a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8005ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8005af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b5:	e8 d6 0c 00 00       	call   801290 <__umoddi3>
  8005ba:	83 c4 14             	add    $0x14,%esp
  8005bd:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  8005c4:	50                   	push   %eax
  8005c5:	ff d7                	call   *%edi
  8005c7:	83 c4 10             	add    $0x10,%esp
  8005ca:	eb 16                	jmp    8005e2 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	56                   	push   %esi
  8005d0:	ff 75 18             	pushl  0x18(%ebp)
  8005d3:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	83 eb 01             	sub    $0x1,%ebx
  8005db:	75 ef                	jne    8005cc <printnum+0x7b>
  8005dd:	e9 a2 00 00 00       	jmp    800684 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005e2:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005e8:	0f 85 76 01 00 00    	jne    800764 <printnum+0x213>
		while(num_of_space-- > 0)
  8005ee:	a1 04 20 80 00       	mov    0x802004,%eax
  8005f3:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005f6:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	7e 1d                	jle    80061d <printnum+0xcc>
			putch(' ', putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	56                   	push   %esi
  800604:	6a 20                	push   $0x20
  800606:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800608:	a1 04 20 80 00       	mov    0x802004,%eax
  80060d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800610:	89 15 04 20 80 00    	mov    %edx,0x802004
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	85 c0                	test   %eax,%eax
  80061b:	7f e3                	jg     800600 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  80061d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800624:	00 00 00 
		judge_time_for_space = 0;
  800627:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80062e:	00 00 00 
	}
}
  800631:	e9 2e 01 00 00       	jmp    800764 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800636:	8b 45 10             	mov    0x10(%ebp),%eax
  800639:	ba 00 00 00 00       	mov    $0x0,%edx
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800644:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800647:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064a:	83 fa 00             	cmp    $0x0,%edx
  80064d:	0f 87 ba 00 00 00    	ja     80070d <printnum+0x1bc>
  800653:	3b 45 10             	cmp    0x10(%ebp),%eax
  800656:	0f 83 b1 00 00 00    	jae    80070d <printnum+0x1bc>
  80065c:	e9 2d ff ff ff       	jmp    80058e <printnum+0x3d>
  800661:	8b 45 10             	mov    0x10(%ebp),%eax
  800664:	ba 00 00 00 00       	mov    $0x0,%edx
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800672:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800675:	83 fa 00             	cmp    $0x0,%edx
  800678:	77 37                	ja     8006b1 <printnum+0x160>
  80067a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80067d:	73 32                	jae    8006b1 <printnum+0x160>
  80067f:	e9 16 ff ff ff       	jmp    80059a <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	56                   	push   %esi
  800688:	83 ec 04             	sub    $0x4,%esp
  80068b:	ff 75 dc             	pushl  -0x24(%ebp)
  80068e:	ff 75 d8             	pushl  -0x28(%ebp)
  800691:	ff 75 e4             	pushl  -0x1c(%ebp)
  800694:	ff 75 e0             	pushl  -0x20(%ebp)
  800697:	e8 f4 0b 00 00       	call   801290 <__umoddi3>
  80069c:	83 c4 14             	add    $0x14,%esp
  80069f:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  8006a6:	50                   	push   %eax
  8006a7:	ff d7                	call   *%edi
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	e9 b3 00 00 00       	jmp    800764 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006b1:	83 ec 0c             	sub    $0xc,%esp
  8006b4:	ff 75 18             	pushl  0x18(%ebp)
  8006b7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006ba:	50                   	push   %eax
  8006bb:	ff 75 10             	pushl  0x10(%ebp)
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cd:	e8 8e 0a 00 00       	call   801160 <__udivdi3>
  8006d2:	83 c4 18             	add    $0x18,%esp
  8006d5:	52                   	push   %edx
  8006d6:	50                   	push   %eax
  8006d7:	89 f2                	mov    %esi,%edx
  8006d9:	89 f8                	mov    %edi,%eax
  8006db:	e8 71 fe ff ff       	call   800551 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006e0:	83 c4 18             	add    $0x18,%esp
  8006e3:	56                   	push   %esi
  8006e4:	83 ec 04             	sub    $0x4,%esp
  8006e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f3:	e8 98 0b 00 00       	call   801290 <__umoddi3>
  8006f8:	83 c4 14             	add    $0x14,%esp
  8006fb:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  800702:	50                   	push   %eax
  800703:	ff d7                	call   *%edi
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	e9 d5 fe ff ff       	jmp    8005e2 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070d:	83 ec 0c             	sub    $0xc,%esp
  800710:	ff 75 18             	pushl  0x18(%ebp)
  800713:	83 eb 01             	sub    $0x1,%ebx
  800716:	53                   	push   %ebx
  800717:	ff 75 10             	pushl  0x10(%ebp)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	ff 75 dc             	pushl  -0x24(%ebp)
  800720:	ff 75 d8             	pushl  -0x28(%ebp)
  800723:	ff 75 e4             	pushl  -0x1c(%ebp)
  800726:	ff 75 e0             	pushl  -0x20(%ebp)
  800729:	e8 32 0a 00 00       	call   801160 <__udivdi3>
  80072e:	83 c4 18             	add    $0x18,%esp
  800731:	52                   	push   %edx
  800732:	50                   	push   %eax
  800733:	89 f2                	mov    %esi,%edx
  800735:	89 f8                	mov    %edi,%eax
  800737:	e8 15 fe ff ff       	call   800551 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80073c:	83 c4 18             	add    $0x18,%esp
  80073f:	56                   	push   %esi
  800740:	83 ec 04             	sub    $0x4,%esp
  800743:	ff 75 dc             	pushl  -0x24(%ebp)
  800746:	ff 75 d8             	pushl  -0x28(%ebp)
  800749:	ff 75 e4             	pushl  -0x1c(%ebp)
  80074c:	ff 75 e0             	pushl  -0x20(%ebp)
  80074f:	e8 3c 0b 00 00       	call   801290 <__umoddi3>
  800754:	83 c4 14             	add    $0x14,%esp
  800757:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  80075e:	50                   	push   %eax
  80075f:	ff d7                	call   *%edi
  800761:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800764:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800767:	5b                   	pop    %ebx
  800768:	5e                   	pop    %esi
  800769:	5f                   	pop    %edi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80076f:	83 fa 01             	cmp    $0x1,%edx
  800772:	7e 0e                	jle    800782 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800774:	8b 10                	mov    (%eax),%edx
  800776:	8d 4a 08             	lea    0x8(%edx),%ecx
  800779:	89 08                	mov    %ecx,(%eax)
  80077b:	8b 02                	mov    (%edx),%eax
  80077d:	8b 52 04             	mov    0x4(%edx),%edx
  800780:	eb 22                	jmp    8007a4 <getuint+0x38>
	else if (lflag)
  800782:	85 d2                	test   %edx,%edx
  800784:	74 10                	je     800796 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800786:	8b 10                	mov    (%eax),%edx
  800788:	8d 4a 04             	lea    0x4(%edx),%ecx
  80078b:	89 08                	mov    %ecx,(%eax)
  80078d:	8b 02                	mov    (%edx),%eax
  80078f:	ba 00 00 00 00       	mov    $0x0,%edx
  800794:	eb 0e                	jmp    8007a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800796:	8b 10                	mov    (%eax),%edx
  800798:	8d 4a 04             	lea    0x4(%edx),%ecx
  80079b:	89 08                	mov    %ecx,(%eax)
  80079d:	8b 02                	mov    (%edx),%eax
  80079f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8007b5:	73 0a                	jae    8007c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007ba:	89 08                	mov    %ecx,(%eax)
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	88 02                	mov    %al,(%edx)
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007cc:	50                   	push   %eax
  8007cd:	ff 75 10             	pushl  0x10(%ebp)
  8007d0:	ff 75 0c             	pushl  0xc(%ebp)
  8007d3:	ff 75 08             	pushl  0x8(%ebp)
  8007d6:	e8 05 00 00 00       	call   8007e0 <vprintfmt>
	va_end(ap);
}
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	57                   	push   %edi
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	83 ec 2c             	sub    $0x2c,%esp
  8007e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ef:	eb 03                	jmp    8007f4 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f1:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f7:	8d 70 01             	lea    0x1(%eax),%esi
  8007fa:	0f b6 00             	movzbl (%eax),%eax
  8007fd:	83 f8 25             	cmp    $0x25,%eax
  800800:	74 27                	je     800829 <vprintfmt+0x49>
			if (ch == '\0')
  800802:	85 c0                	test   %eax,%eax
  800804:	75 0d                	jne    800813 <vprintfmt+0x33>
  800806:	e9 9d 04 00 00       	jmp    800ca8 <vprintfmt+0x4c8>
  80080b:	85 c0                	test   %eax,%eax
  80080d:	0f 84 95 04 00 00    	je     800ca8 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800813:	83 ec 08             	sub    $0x8,%esp
  800816:	53                   	push   %ebx
  800817:	50                   	push   %eax
  800818:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80081a:	83 c6 01             	add    $0x1,%esi
  80081d:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	83 f8 25             	cmp    $0x25,%eax
  800827:	75 e2                	jne    80080b <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082e:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800832:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800839:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800840:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800847:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80084e:	eb 08                	jmp    800858 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800850:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800853:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800858:	8d 46 01             	lea    0x1(%esi),%eax
  80085b:	89 45 10             	mov    %eax,0x10(%ebp)
  80085e:	0f b6 06             	movzbl (%esi),%eax
  800861:	0f b6 d0             	movzbl %al,%edx
  800864:	83 e8 23             	sub    $0x23,%eax
  800867:	3c 55                	cmp    $0x55,%al
  800869:	0f 87 fa 03 00 00    	ja     800c69 <vprintfmt+0x489>
  80086f:	0f b6 c0             	movzbl %al,%eax
  800872:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
  800879:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80087c:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800880:	eb d6                	jmp    800858 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800882:	8d 42 d0             	lea    -0x30(%edx),%eax
  800885:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800888:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80088c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80088f:	83 fa 09             	cmp    $0x9,%edx
  800892:	77 6b                	ja     8008ff <vprintfmt+0x11f>
  800894:	8b 75 10             	mov    0x10(%ebp),%esi
  800897:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80089a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80089d:	eb 09                	jmp    8008a8 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089f:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008a2:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008a6:	eb b0                	jmp    800858 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a8:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008ab:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008ae:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008b5:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008b8:	83 f9 09             	cmp    $0x9,%ecx
  8008bb:	76 eb                	jbe    8008a8 <vprintfmt+0xc8>
  8008bd:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008c0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008c3:	eb 3d                	jmp    800902 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8d 50 04             	lea    0x4(%eax),%edx
  8008cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ce:	8b 00                	mov    (%eax),%eax
  8008d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008d6:	eb 2a                	jmp    800902 <vprintfmt+0x122>
  8008d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	0f 49 d0             	cmovns %eax,%edx
  8008e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e8:	8b 75 10             	mov    0x10(%ebp),%esi
  8008eb:	e9 68 ff ff ff       	jmp    800858 <vprintfmt+0x78>
  8008f0:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008f3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008fa:	e9 59 ff ff ff       	jmp    800858 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ff:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800902:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800906:	0f 89 4c ff ff ff    	jns    800858 <vprintfmt+0x78>
				width = precision, precision = -1;
  80090c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80090f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800912:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800919:	e9 3a ff ff ff       	jmp    800858 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80091e:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800922:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800925:	e9 2e ff ff ff       	jmp    800858 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	53                   	push   %ebx
  800937:	ff 30                	pushl  (%eax)
  800939:	ff d7                	call   *%edi
			break;
  80093b:	83 c4 10             	add    $0x10,%esp
  80093e:	e9 b1 fe ff ff       	jmp    8007f4 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800943:	8b 45 14             	mov    0x14(%ebp),%eax
  800946:	8d 50 04             	lea    0x4(%eax),%edx
  800949:	89 55 14             	mov    %edx,0x14(%ebp)
  80094c:	8b 00                	mov    (%eax),%eax
  80094e:	99                   	cltd   
  80094f:	31 d0                	xor    %edx,%eax
  800951:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800953:	83 f8 08             	cmp    $0x8,%eax
  800956:	7f 0b                	jg     800963 <vprintfmt+0x183>
  800958:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  80095f:	85 d2                	test   %edx,%edx
  800961:	75 15                	jne    800978 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800963:	50                   	push   %eax
  800964:	68 77 14 80 00       	push   $0x801477
  800969:	53                   	push   %ebx
  80096a:	57                   	push   %edi
  80096b:	e8 53 fe ff ff       	call   8007c3 <printfmt>
  800970:	83 c4 10             	add    $0x10,%esp
  800973:	e9 7c fe ff ff       	jmp    8007f4 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800978:	52                   	push   %edx
  800979:	68 80 14 80 00       	push   $0x801480
  80097e:	53                   	push   %ebx
  80097f:	57                   	push   %edi
  800980:	e8 3e fe ff ff       	call   8007c3 <printfmt>
  800985:	83 c4 10             	add    $0x10,%esp
  800988:	e9 67 fe ff ff       	jmp    8007f4 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80098d:	8b 45 14             	mov    0x14(%ebp),%eax
  800990:	8d 50 04             	lea    0x4(%eax),%edx
  800993:	89 55 14             	mov    %edx,0x14(%ebp)
  800996:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800998:	85 c0                	test   %eax,%eax
  80099a:	b9 70 14 80 00       	mov    $0x801470,%ecx
  80099f:	0f 45 c8             	cmovne %eax,%ecx
  8009a2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009a9:	7e 06                	jle    8009b1 <vprintfmt+0x1d1>
  8009ab:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009af:	75 19                	jne    8009ca <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b4:	8d 70 01             	lea    0x1(%eax),%esi
  8009b7:	0f b6 00             	movzbl (%eax),%eax
  8009ba:	0f be d0             	movsbl %al,%edx
  8009bd:	85 d2                	test   %edx,%edx
  8009bf:	0f 85 9f 00 00 00    	jne    800a64 <vprintfmt+0x284>
  8009c5:	e9 8c 00 00 00       	jmp    800a56 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ca:	83 ec 08             	sub    $0x8,%esp
  8009cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8009d0:	ff 75 cc             	pushl  -0x34(%ebp)
  8009d3:	e8 62 03 00 00       	call   800d3a <strnlen>
  8009d8:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009db:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	85 c9                	test   %ecx,%ecx
  8009e3:	0f 8e a6 02 00 00    	jle    800c8f <vprintfmt+0x4af>
					putch(padc, putdat);
  8009e9:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f0:	89 cb                	mov    %ecx,%ebx
  8009f2:	83 ec 08             	sub    $0x8,%esp
  8009f5:	ff 75 0c             	pushl  0xc(%ebp)
  8009f8:	56                   	push   %esi
  8009f9:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009fb:	83 c4 10             	add    $0x10,%esp
  8009fe:	83 eb 01             	sub    $0x1,%ebx
  800a01:	75 ef                	jne    8009f2 <vprintfmt+0x212>
  800a03:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a09:	e9 81 02 00 00       	jmp    800c8f <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a0e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a12:	74 1b                	je     800a2f <vprintfmt+0x24f>
  800a14:	0f be c0             	movsbl %al,%eax
  800a17:	83 e8 20             	sub    $0x20,%eax
  800a1a:	83 f8 5e             	cmp    $0x5e,%eax
  800a1d:	76 10                	jbe    800a2f <vprintfmt+0x24f>
					putch('?', putdat);
  800a1f:	83 ec 08             	sub    $0x8,%esp
  800a22:	ff 75 0c             	pushl  0xc(%ebp)
  800a25:	6a 3f                	push   $0x3f
  800a27:	ff 55 08             	call   *0x8(%ebp)
  800a2a:	83 c4 10             	add    $0x10,%esp
  800a2d:	eb 0d                	jmp    800a3c <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a2f:	83 ec 08             	sub    $0x8,%esp
  800a32:	ff 75 0c             	pushl  0xc(%ebp)
  800a35:	52                   	push   %edx
  800a36:	ff 55 08             	call   *0x8(%ebp)
  800a39:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3c:	83 ef 01             	sub    $0x1,%edi
  800a3f:	83 c6 01             	add    $0x1,%esi
  800a42:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a46:	0f be d0             	movsbl %al,%edx
  800a49:	85 d2                	test   %edx,%edx
  800a4b:	75 31                	jne    800a7e <vprintfmt+0x29e>
  800a4d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a56:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a59:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a5d:	7f 33                	jg     800a92 <vprintfmt+0x2b2>
  800a5f:	e9 90 fd ff ff       	jmp    8007f4 <vprintfmt+0x14>
  800a64:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a6a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a6d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a70:	eb 0c                	jmp    800a7e <vprintfmt+0x29e>
  800a72:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a78:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a7b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a7e:	85 db                	test   %ebx,%ebx
  800a80:	78 8c                	js     800a0e <vprintfmt+0x22e>
  800a82:	83 eb 01             	sub    $0x1,%ebx
  800a85:	79 87                	jns    800a0e <vprintfmt+0x22e>
  800a87:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a90:	eb c4                	jmp    800a56 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a92:	83 ec 08             	sub    $0x8,%esp
  800a95:	53                   	push   %ebx
  800a96:	6a 20                	push   $0x20
  800a98:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a9a:	83 c4 10             	add    $0x10,%esp
  800a9d:	83 ee 01             	sub    $0x1,%esi
  800aa0:	75 f0                	jne    800a92 <vprintfmt+0x2b2>
  800aa2:	e9 4d fd ff ff       	jmp    8007f4 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aa7:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800aab:	7e 16                	jle    800ac3 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800aad:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab0:	8d 50 08             	lea    0x8(%eax),%edx
  800ab3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab6:	8b 50 04             	mov    0x4(%eax),%edx
  800ab9:	8b 00                	mov    (%eax),%eax
  800abb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800abe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ac1:	eb 34                	jmp    800af7 <vprintfmt+0x317>
	else if (lflag)
  800ac3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ac7:	74 18                	je     800ae1 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ac9:	8b 45 14             	mov    0x14(%ebp),%eax
  800acc:	8d 50 04             	lea    0x4(%eax),%edx
  800acf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad2:	8b 30                	mov    (%eax),%esi
  800ad4:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ad7:	89 f0                	mov    %esi,%eax
  800ad9:	c1 f8 1f             	sar    $0x1f,%eax
  800adc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800adf:	eb 16                	jmp    800af7 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ae1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae4:	8d 50 04             	lea    0x4(%eax),%edx
  800ae7:	89 55 14             	mov    %edx,0x14(%ebp)
  800aea:	8b 30                	mov    (%eax),%esi
  800aec:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800aef:	89 f0                	mov    %esi,%eax
  800af1:	c1 f8 1f             	sar    $0x1f,%eax
  800af4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800af7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800afa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800afd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b00:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b03:	85 d2                	test   %edx,%edx
  800b05:	79 28                	jns    800b2f <vprintfmt+0x34f>
				putch('-', putdat);
  800b07:	83 ec 08             	sub    $0x8,%esp
  800b0a:	53                   	push   %ebx
  800b0b:	6a 2d                	push   $0x2d
  800b0d:	ff d7                	call   *%edi
				num = -(long long) num;
  800b0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b12:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b15:	f7 d8                	neg    %eax
  800b17:	83 d2 00             	adc    $0x0,%edx
  800b1a:	f7 da                	neg    %edx
  800b1c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b22:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2a:	e9 b2 00 00 00       	jmp    800be1 <vprintfmt+0x401>
  800b2f:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b34:	85 c9                	test   %ecx,%ecx
  800b36:	0f 84 a5 00 00 00    	je     800be1 <vprintfmt+0x401>
				putch('+', putdat);
  800b3c:	83 ec 08             	sub    $0x8,%esp
  800b3f:	53                   	push   %ebx
  800b40:	6a 2b                	push   $0x2b
  800b42:	ff d7                	call   *%edi
  800b44:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4c:	e9 90 00 00 00       	jmp    800be1 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b51:	85 c9                	test   %ecx,%ecx
  800b53:	74 0b                	je     800b60 <vprintfmt+0x380>
				putch('+', putdat);
  800b55:	83 ec 08             	sub    $0x8,%esp
  800b58:	53                   	push   %ebx
  800b59:	6a 2b                	push   $0x2b
  800b5b:	ff d7                	call   *%edi
  800b5d:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b60:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b63:	8d 45 14             	lea    0x14(%ebp),%eax
  800b66:	e8 01 fc ff ff       	call   80076c <getuint>
  800b6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b71:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b76:	eb 69                	jmp    800be1 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b78:	83 ec 08             	sub    $0x8,%esp
  800b7b:	53                   	push   %ebx
  800b7c:	6a 30                	push   $0x30
  800b7e:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b80:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b83:	8d 45 14             	lea    0x14(%ebp),%eax
  800b86:	e8 e1 fb ff ff       	call   80076c <getuint>
  800b8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b8e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b91:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b94:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b99:	eb 46                	jmp    800be1 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b9b:	83 ec 08             	sub    $0x8,%esp
  800b9e:	53                   	push   %ebx
  800b9f:	6a 30                	push   $0x30
  800ba1:	ff d7                	call   *%edi
			putch('x', putdat);
  800ba3:	83 c4 08             	add    $0x8,%esp
  800ba6:	53                   	push   %ebx
  800ba7:	6a 78                	push   $0x78
  800ba9:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bab:	8b 45 14             	mov    0x14(%ebp),%eax
  800bae:	8d 50 04             	lea    0x4(%eax),%edx
  800bb1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bb4:	8b 00                	mov    (%eax),%eax
  800bb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bbe:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bc1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bc4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bc9:	eb 16                	jmp    800be1 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bcb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bce:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd1:	e8 96 fb ff ff       	call   80076c <getuint>
  800bd6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bd9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bdc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800be8:	56                   	push   %esi
  800be9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bec:	50                   	push   %eax
  800bed:	ff 75 dc             	pushl  -0x24(%ebp)
  800bf0:	ff 75 d8             	pushl  -0x28(%ebp)
  800bf3:	89 da                	mov    %ebx,%edx
  800bf5:	89 f8                	mov    %edi,%eax
  800bf7:	e8 55 f9 ff ff       	call   800551 <printnum>
			break;
  800bfc:	83 c4 20             	add    $0x20,%esp
  800bff:	e9 f0 fb ff ff       	jmp    8007f4 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c04:	8b 45 14             	mov    0x14(%ebp),%eax
  800c07:	8d 50 04             	lea    0x4(%eax),%edx
  800c0a:	89 55 14             	mov    %edx,0x14(%ebp)
  800c0d:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c0f:	85 f6                	test   %esi,%esi
  800c11:	75 1a                	jne    800c2d <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c13:	83 ec 08             	sub    $0x8,%esp
  800c16:	68 18 15 80 00       	push   $0x801518
  800c1b:	68 80 14 80 00       	push   $0x801480
  800c20:	e8 18 f9 ff ff       	call   80053d <cprintf>
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	e9 c7 fb ff ff       	jmp    8007f4 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c2d:	0f b6 03             	movzbl (%ebx),%eax
  800c30:	84 c0                	test   %al,%al
  800c32:	79 1f                	jns    800c53 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c34:	83 ec 08             	sub    $0x8,%esp
  800c37:	68 50 15 80 00       	push   $0x801550
  800c3c:	68 80 14 80 00       	push   $0x801480
  800c41:	e8 f7 f8 ff ff       	call   80053d <cprintf>
						*tmp = *(char *)putdat;
  800c46:	0f b6 03             	movzbl (%ebx),%eax
  800c49:	88 06                	mov    %al,(%esi)
  800c4b:	83 c4 10             	add    $0x10,%esp
  800c4e:	e9 a1 fb ff ff       	jmp    8007f4 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c53:	88 06                	mov    %al,(%esi)
  800c55:	e9 9a fb ff ff       	jmp    8007f4 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c5a:	83 ec 08             	sub    $0x8,%esp
  800c5d:	53                   	push   %ebx
  800c5e:	52                   	push   %edx
  800c5f:	ff d7                	call   *%edi
			break;
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	e9 8b fb ff ff       	jmp    8007f4 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c69:	83 ec 08             	sub    $0x8,%esp
  800c6c:	53                   	push   %ebx
  800c6d:	6a 25                	push   $0x25
  800c6f:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c71:	83 c4 10             	add    $0x10,%esp
  800c74:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c78:	0f 84 73 fb ff ff    	je     8007f1 <vprintfmt+0x11>
  800c7e:	83 ee 01             	sub    $0x1,%esi
  800c81:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c85:	75 f7                	jne    800c7e <vprintfmt+0x49e>
  800c87:	89 75 10             	mov    %esi,0x10(%ebp)
  800c8a:	e9 65 fb ff ff       	jmp    8007f4 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c8f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c92:	8d 70 01             	lea    0x1(%eax),%esi
  800c95:	0f b6 00             	movzbl (%eax),%eax
  800c98:	0f be d0             	movsbl %al,%edx
  800c9b:	85 d2                	test   %edx,%edx
  800c9d:	0f 85 cf fd ff ff    	jne    800a72 <vprintfmt+0x292>
  800ca3:	e9 4c fb ff ff       	jmp    8007f4 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 18             	sub    $0x18,%esp
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cbf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cc3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	74 26                	je     800cf7 <vsnprintf+0x47>
  800cd1:	85 d2                	test   %edx,%edx
  800cd3:	7e 22                	jle    800cf7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cd5:	ff 75 14             	pushl  0x14(%ebp)
  800cd8:	ff 75 10             	pushl  0x10(%ebp)
  800cdb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cde:	50                   	push   %eax
  800cdf:	68 a6 07 80 00       	push   $0x8007a6
  800ce4:	e8 f7 fa ff ff       	call   8007e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ce9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf2:	83 c4 10             	add    $0x10,%esp
  800cf5:	eb 05                	jmp    800cfc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cf7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cfc:	c9                   	leave  
  800cfd:	c3                   	ret    

00800cfe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d04:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d07:	50                   	push   %eax
  800d08:	ff 75 10             	pushl  0x10(%ebp)
  800d0b:	ff 75 0c             	pushl  0xc(%ebp)
  800d0e:	ff 75 08             	pushl  0x8(%ebp)
  800d11:	e8 9a ff ff ff       	call   800cb0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d16:	c9                   	leave  
  800d17:	c3                   	ret    

00800d18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d1e:	80 3a 00             	cmpb   $0x0,(%edx)
  800d21:	74 10                	je     800d33 <strlen+0x1b>
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d28:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d2b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d2f:	75 f7                	jne    800d28 <strlen+0x10>
  800d31:	eb 05                	jmp    800d38 <strlen+0x20>
  800d33:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	53                   	push   %ebx
  800d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d44:	85 c9                	test   %ecx,%ecx
  800d46:	74 1c                	je     800d64 <strnlen+0x2a>
  800d48:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d4b:	74 1e                	je     800d6b <strnlen+0x31>
  800d4d:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d52:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d54:	39 ca                	cmp    %ecx,%edx
  800d56:	74 18                	je     800d70 <strnlen+0x36>
  800d58:	83 c2 01             	add    $0x1,%edx
  800d5b:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d60:	75 f0                	jne    800d52 <strnlen+0x18>
  800d62:	eb 0c                	jmp    800d70 <strnlen+0x36>
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
  800d69:	eb 05                	jmp    800d70 <strnlen+0x36>
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d70:	5b                   	pop    %ebx
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	53                   	push   %ebx
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	83 c2 01             	add    $0x1,%edx
  800d82:	83 c1 01             	add    $0x1,%ecx
  800d85:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d89:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d8c:	84 db                	test   %bl,%bl
  800d8e:	75 ef                	jne    800d7f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d90:	5b                   	pop    %ebx
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	53                   	push   %ebx
  800d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d9a:	53                   	push   %ebx
  800d9b:	e8 78 ff ff ff       	call   800d18 <strlen>
  800da0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800da3:	ff 75 0c             	pushl  0xc(%ebp)
  800da6:	01 d8                	add    %ebx,%eax
  800da8:	50                   	push   %eax
  800da9:	e8 c5 ff ff ff       	call   800d73 <strcpy>
	return dst;
}
  800dae:	89 d8                	mov    %ebx,%eax
  800db0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    

00800db5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc3:	85 db                	test   %ebx,%ebx
  800dc5:	74 17                	je     800dde <strncpy+0x29>
  800dc7:	01 f3                	add    %esi,%ebx
  800dc9:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dcb:	83 c1 01             	add    $0x1,%ecx
  800dce:	0f b6 02             	movzbl (%edx),%eax
  800dd1:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dd4:	80 3a 01             	cmpb   $0x1,(%edx)
  800dd7:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dda:	39 cb                	cmp    %ecx,%ebx
  800ddc:	75 ed                	jne    800dcb <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dde:	89 f0                	mov    %esi,%eax
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	8b 75 08             	mov    0x8(%ebp),%esi
  800dec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800def:	8b 55 10             	mov    0x10(%ebp),%edx
  800df2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800df4:	85 d2                	test   %edx,%edx
  800df6:	74 35                	je     800e2d <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800df8:	89 d0                	mov    %edx,%eax
  800dfa:	83 e8 01             	sub    $0x1,%eax
  800dfd:	74 25                	je     800e24 <strlcpy+0x40>
  800dff:	0f b6 0b             	movzbl (%ebx),%ecx
  800e02:	84 c9                	test   %cl,%cl
  800e04:	74 22                	je     800e28 <strlcpy+0x44>
  800e06:	8d 53 01             	lea    0x1(%ebx),%edx
  800e09:	01 c3                	add    %eax,%ebx
  800e0b:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e0d:	83 c0 01             	add    $0x1,%eax
  800e10:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e13:	39 da                	cmp    %ebx,%edx
  800e15:	74 13                	je     800e2a <strlcpy+0x46>
  800e17:	83 c2 01             	add    $0x1,%edx
  800e1a:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e1e:	84 c9                	test   %cl,%cl
  800e20:	75 eb                	jne    800e0d <strlcpy+0x29>
  800e22:	eb 06                	jmp    800e2a <strlcpy+0x46>
  800e24:	89 f0                	mov    %esi,%eax
  800e26:	eb 02                	jmp    800e2a <strlcpy+0x46>
  800e28:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e2a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e2d:	29 f0                	sub    %esi,%eax
}
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e3c:	0f b6 01             	movzbl (%ecx),%eax
  800e3f:	84 c0                	test   %al,%al
  800e41:	74 15                	je     800e58 <strcmp+0x25>
  800e43:	3a 02                	cmp    (%edx),%al
  800e45:	75 11                	jne    800e58 <strcmp+0x25>
		p++, q++;
  800e47:	83 c1 01             	add    $0x1,%ecx
  800e4a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e4d:	0f b6 01             	movzbl (%ecx),%eax
  800e50:	84 c0                	test   %al,%al
  800e52:	74 04                	je     800e58 <strcmp+0x25>
  800e54:	3a 02                	cmp    (%edx),%al
  800e56:	74 ef                	je     800e47 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e58:	0f b6 c0             	movzbl %al,%eax
  800e5b:	0f b6 12             	movzbl (%edx),%edx
  800e5e:	29 d0                	sub    %edx,%eax
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6d:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e70:	85 f6                	test   %esi,%esi
  800e72:	74 29                	je     800e9d <strncmp+0x3b>
  800e74:	0f b6 03             	movzbl (%ebx),%eax
  800e77:	84 c0                	test   %al,%al
  800e79:	74 30                	je     800eab <strncmp+0x49>
  800e7b:	3a 02                	cmp    (%edx),%al
  800e7d:	75 2c                	jne    800eab <strncmp+0x49>
  800e7f:	8d 43 01             	lea    0x1(%ebx),%eax
  800e82:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e84:	89 c3                	mov    %eax,%ebx
  800e86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e89:	39 c6                	cmp    %eax,%esi
  800e8b:	74 17                	je     800ea4 <strncmp+0x42>
  800e8d:	0f b6 08             	movzbl (%eax),%ecx
  800e90:	84 c9                	test   %cl,%cl
  800e92:	74 17                	je     800eab <strncmp+0x49>
  800e94:	83 c0 01             	add    $0x1,%eax
  800e97:	3a 0a                	cmp    (%edx),%cl
  800e99:	74 e9                	je     800e84 <strncmp+0x22>
  800e9b:	eb 0e                	jmp    800eab <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	eb 0f                	jmp    800eb3 <strncmp+0x51>
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea9:	eb 08                	jmp    800eb3 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800eab:	0f b6 03             	movzbl (%ebx),%eax
  800eae:	0f b6 12             	movzbl (%edx),%edx
  800eb1:	29 d0                	sub    %edx,%eax
}
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	53                   	push   %ebx
  800ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ec1:	0f b6 10             	movzbl (%eax),%edx
  800ec4:	84 d2                	test   %dl,%dl
  800ec6:	74 1d                	je     800ee5 <strchr+0x2e>
  800ec8:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800eca:	38 d3                	cmp    %dl,%bl
  800ecc:	75 06                	jne    800ed4 <strchr+0x1d>
  800ece:	eb 1a                	jmp    800eea <strchr+0x33>
  800ed0:	38 ca                	cmp    %cl,%dl
  800ed2:	74 16                	je     800eea <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ed4:	83 c0 01             	add    $0x1,%eax
  800ed7:	0f b6 10             	movzbl (%eax),%edx
  800eda:	84 d2                	test   %dl,%dl
  800edc:	75 f2                	jne    800ed0 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	eb 05                	jmp    800eea <strchr+0x33>
  800ee5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eea:	5b                   	pop    %ebx
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	53                   	push   %ebx
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef4:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ef7:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800efa:	38 d3                	cmp    %dl,%bl
  800efc:	74 14                	je     800f12 <strfind+0x25>
  800efe:	89 d1                	mov    %edx,%ecx
  800f00:	84 db                	test   %bl,%bl
  800f02:	74 0e                	je     800f12 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f04:	83 c0 01             	add    $0x1,%eax
  800f07:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f0a:	38 ca                	cmp    %cl,%dl
  800f0c:	74 04                	je     800f12 <strfind+0x25>
  800f0e:	84 d2                	test   %dl,%dl
  800f10:	75 f2                	jne    800f04 <strfind+0x17>
			break;
	return (char *) s;
}
  800f12:	5b                   	pop    %ebx
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
  800f1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f21:	85 c9                	test   %ecx,%ecx
  800f23:	74 36                	je     800f5b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f2b:	75 28                	jne    800f55 <memset+0x40>
  800f2d:	f6 c1 03             	test   $0x3,%cl
  800f30:	75 23                	jne    800f55 <memset+0x40>
		c &= 0xFF;
  800f32:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f36:	89 d3                	mov    %edx,%ebx
  800f38:	c1 e3 08             	shl    $0x8,%ebx
  800f3b:	89 d6                	mov    %edx,%esi
  800f3d:	c1 e6 18             	shl    $0x18,%esi
  800f40:	89 d0                	mov    %edx,%eax
  800f42:	c1 e0 10             	shl    $0x10,%eax
  800f45:	09 f0                	or     %esi,%eax
  800f47:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f49:	89 d8                	mov    %ebx,%eax
  800f4b:	09 d0                	or     %edx,%eax
  800f4d:	c1 e9 02             	shr    $0x2,%ecx
  800f50:	fc                   	cld    
  800f51:	f3 ab                	rep stos %eax,%es:(%edi)
  800f53:	eb 06                	jmp    800f5b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f58:	fc                   	cld    
  800f59:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f5b:	89 f8                	mov    %edi,%eax
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    

00800f62 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f70:	39 c6                	cmp    %eax,%esi
  800f72:	73 35                	jae    800fa9 <memmove+0x47>
  800f74:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f77:	39 d0                	cmp    %edx,%eax
  800f79:	73 2e                	jae    800fa9 <memmove+0x47>
		s += n;
		d += n;
  800f7b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f7e:	89 d6                	mov    %edx,%esi
  800f80:	09 fe                	or     %edi,%esi
  800f82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f88:	75 13                	jne    800f9d <memmove+0x3b>
  800f8a:	f6 c1 03             	test   $0x3,%cl
  800f8d:	75 0e                	jne    800f9d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f8f:	83 ef 04             	sub    $0x4,%edi
  800f92:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f95:	c1 e9 02             	shr    $0x2,%ecx
  800f98:	fd                   	std    
  800f99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9b:	eb 09                	jmp    800fa6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f9d:	83 ef 01             	sub    $0x1,%edi
  800fa0:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fa3:	fd                   	std    
  800fa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fa6:	fc                   	cld    
  800fa7:	eb 1d                	jmp    800fc6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa9:	89 f2                	mov    %esi,%edx
  800fab:	09 c2                	or     %eax,%edx
  800fad:	f6 c2 03             	test   $0x3,%dl
  800fb0:	75 0f                	jne    800fc1 <memmove+0x5f>
  800fb2:	f6 c1 03             	test   $0x3,%cl
  800fb5:	75 0a                	jne    800fc1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fb7:	c1 e9 02             	shr    $0x2,%ecx
  800fba:	89 c7                	mov    %eax,%edi
  800fbc:	fc                   	cld    
  800fbd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fbf:	eb 05                	jmp    800fc6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fc1:	89 c7                	mov    %eax,%edi
  800fc3:	fc                   	cld    
  800fc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fcd:	ff 75 10             	pushl  0x10(%ebp)
  800fd0:	ff 75 0c             	pushl  0xc(%ebp)
  800fd3:	ff 75 08             	pushl  0x8(%ebp)
  800fd6:	e8 87 ff ff ff       	call   800f62 <memmove>
}
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fe6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fe9:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fec:	85 c0                	test   %eax,%eax
  800fee:	74 39                	je     801029 <memcmp+0x4c>
  800ff0:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ff3:	0f b6 13             	movzbl (%ebx),%edx
  800ff6:	0f b6 0e             	movzbl (%esi),%ecx
  800ff9:	38 ca                	cmp    %cl,%dl
  800ffb:	75 17                	jne    801014 <memcmp+0x37>
  800ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  801002:	eb 1a                	jmp    80101e <memcmp+0x41>
  801004:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  801009:	83 c0 01             	add    $0x1,%eax
  80100c:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  801010:	38 ca                	cmp    %cl,%dl
  801012:	74 0a                	je     80101e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801014:	0f b6 c2             	movzbl %dl,%eax
  801017:	0f b6 c9             	movzbl %cl,%ecx
  80101a:	29 c8                	sub    %ecx,%eax
  80101c:	eb 10                	jmp    80102e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80101e:	39 f8                	cmp    %edi,%eax
  801020:	75 e2                	jne    801004 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801022:	b8 00 00 00 00       	mov    $0x0,%eax
  801027:	eb 05                	jmp    80102e <memcmp+0x51>
  801029:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	53                   	push   %ebx
  801037:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  80103a:	89 d0                	mov    %edx,%eax
  80103c:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80103f:	39 c2                	cmp    %eax,%edx
  801041:	73 1d                	jae    801060 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  801043:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801047:	0f b6 0a             	movzbl (%edx),%ecx
  80104a:	39 d9                	cmp    %ebx,%ecx
  80104c:	75 09                	jne    801057 <memfind+0x24>
  80104e:	eb 14                	jmp    801064 <memfind+0x31>
  801050:	0f b6 0a             	movzbl (%edx),%ecx
  801053:	39 d9                	cmp    %ebx,%ecx
  801055:	74 11                	je     801068 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801057:	83 c2 01             	add    $0x1,%edx
  80105a:	39 d0                	cmp    %edx,%eax
  80105c:	75 f2                	jne    801050 <memfind+0x1d>
  80105e:	eb 0a                	jmp    80106a <memfind+0x37>
  801060:	89 d0                	mov    %edx,%eax
  801062:	eb 06                	jmp    80106a <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801064:	89 d0                	mov    %edx,%eax
  801066:	eb 02                	jmp    80106a <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801068:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80106a:	5b                   	pop    %ebx
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	57                   	push   %edi
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
  801073:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801076:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801079:	0f b6 01             	movzbl (%ecx),%eax
  80107c:	3c 20                	cmp    $0x20,%al
  80107e:	74 04                	je     801084 <strtol+0x17>
  801080:	3c 09                	cmp    $0x9,%al
  801082:	75 0e                	jne    801092 <strtol+0x25>
		s++;
  801084:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801087:	0f b6 01             	movzbl (%ecx),%eax
  80108a:	3c 20                	cmp    $0x20,%al
  80108c:	74 f6                	je     801084 <strtol+0x17>
  80108e:	3c 09                	cmp    $0x9,%al
  801090:	74 f2                	je     801084 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801092:	3c 2b                	cmp    $0x2b,%al
  801094:	75 0a                	jne    8010a0 <strtol+0x33>
		s++;
  801096:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801099:	bf 00 00 00 00       	mov    $0x0,%edi
  80109e:	eb 11                	jmp    8010b1 <strtol+0x44>
  8010a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010a5:	3c 2d                	cmp    $0x2d,%al
  8010a7:	75 08                	jne    8010b1 <strtol+0x44>
		s++, neg = 1;
  8010a9:	83 c1 01             	add    $0x1,%ecx
  8010ac:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010b7:	75 15                	jne    8010ce <strtol+0x61>
  8010b9:	80 39 30             	cmpb   $0x30,(%ecx)
  8010bc:	75 10                	jne    8010ce <strtol+0x61>
  8010be:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010c2:	75 7c                	jne    801140 <strtol+0xd3>
		s += 2, base = 16;
  8010c4:	83 c1 02             	add    $0x2,%ecx
  8010c7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010cc:	eb 16                	jmp    8010e4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010ce:	85 db                	test   %ebx,%ebx
  8010d0:	75 12                	jne    8010e4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010d7:	80 39 30             	cmpb   $0x30,(%ecx)
  8010da:	75 08                	jne    8010e4 <strtol+0x77>
		s++, base = 8;
  8010dc:	83 c1 01             	add    $0x1,%ecx
  8010df:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010ec:	0f b6 11             	movzbl (%ecx),%edx
  8010ef:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010f2:	89 f3                	mov    %esi,%ebx
  8010f4:	80 fb 09             	cmp    $0x9,%bl
  8010f7:	77 08                	ja     801101 <strtol+0x94>
			dig = *s - '0';
  8010f9:	0f be d2             	movsbl %dl,%edx
  8010fc:	83 ea 30             	sub    $0x30,%edx
  8010ff:	eb 22                	jmp    801123 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  801101:	8d 72 9f             	lea    -0x61(%edx),%esi
  801104:	89 f3                	mov    %esi,%ebx
  801106:	80 fb 19             	cmp    $0x19,%bl
  801109:	77 08                	ja     801113 <strtol+0xa6>
			dig = *s - 'a' + 10;
  80110b:	0f be d2             	movsbl %dl,%edx
  80110e:	83 ea 57             	sub    $0x57,%edx
  801111:	eb 10                	jmp    801123 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  801113:	8d 72 bf             	lea    -0x41(%edx),%esi
  801116:	89 f3                	mov    %esi,%ebx
  801118:	80 fb 19             	cmp    $0x19,%bl
  80111b:	77 16                	ja     801133 <strtol+0xc6>
			dig = *s - 'A' + 10;
  80111d:	0f be d2             	movsbl %dl,%edx
  801120:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801123:	3b 55 10             	cmp    0x10(%ebp),%edx
  801126:	7d 0b                	jge    801133 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801128:	83 c1 01             	add    $0x1,%ecx
  80112b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80112f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801131:	eb b9                	jmp    8010ec <strtol+0x7f>

	if (endptr)
  801133:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801137:	74 0d                	je     801146 <strtol+0xd9>
		*endptr = (char *) s;
  801139:	8b 75 0c             	mov    0xc(%ebp),%esi
  80113c:	89 0e                	mov    %ecx,(%esi)
  80113e:	eb 06                	jmp    801146 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801140:	85 db                	test   %ebx,%ebx
  801142:	74 98                	je     8010dc <strtol+0x6f>
  801144:	eb 9e                	jmp    8010e4 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801146:	89 c2                	mov    %eax,%edx
  801148:	f7 da                	neg    %edx
  80114a:	85 ff                	test   %edi,%edi
  80114c:	0f 45 c2             	cmovne %edx,%eax
}
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    
  801154:	66 90                	xchg   %ax,%ax
  801156:	66 90                	xchg   %ax,%ax
  801158:	66 90                	xchg   %ax,%ax
  80115a:	66 90                	xchg   %ax,%ax
  80115c:	66 90                	xchg   %ax,%ax
  80115e:	66 90                	xchg   %ax,%ax

00801160 <__udivdi3>:
  801160:	55                   	push   %ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 1c             	sub    $0x1c,%esp
  801167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80116b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80116f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801177:	85 f6                	test   %esi,%esi
  801179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80117d:	89 ca                	mov    %ecx,%edx
  80117f:	89 f8                	mov    %edi,%eax
  801181:	75 3d                	jne    8011c0 <__udivdi3+0x60>
  801183:	39 cf                	cmp    %ecx,%edi
  801185:	0f 87 c5 00 00 00    	ja     801250 <__udivdi3+0xf0>
  80118b:	85 ff                	test   %edi,%edi
  80118d:	89 fd                	mov    %edi,%ebp
  80118f:	75 0b                	jne    80119c <__udivdi3+0x3c>
  801191:	b8 01 00 00 00       	mov    $0x1,%eax
  801196:	31 d2                	xor    %edx,%edx
  801198:	f7 f7                	div    %edi
  80119a:	89 c5                	mov    %eax,%ebp
  80119c:	89 c8                	mov    %ecx,%eax
  80119e:	31 d2                	xor    %edx,%edx
  8011a0:	f7 f5                	div    %ebp
  8011a2:	89 c1                	mov    %eax,%ecx
  8011a4:	89 d8                	mov    %ebx,%eax
  8011a6:	89 cf                	mov    %ecx,%edi
  8011a8:	f7 f5                	div    %ebp
  8011aa:	89 c3                	mov    %eax,%ebx
  8011ac:	89 d8                	mov    %ebx,%eax
  8011ae:	89 fa                	mov    %edi,%edx
  8011b0:	83 c4 1c             	add    $0x1c,%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    
  8011b8:	90                   	nop
  8011b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	39 ce                	cmp    %ecx,%esi
  8011c2:	77 74                	ja     801238 <__udivdi3+0xd8>
  8011c4:	0f bd fe             	bsr    %esi,%edi
  8011c7:	83 f7 1f             	xor    $0x1f,%edi
  8011ca:	0f 84 98 00 00 00    	je     801268 <__udivdi3+0x108>
  8011d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011d5:	89 f9                	mov    %edi,%ecx
  8011d7:	89 c5                	mov    %eax,%ebp
  8011d9:	29 fb                	sub    %edi,%ebx
  8011db:	d3 e6                	shl    %cl,%esi
  8011dd:	89 d9                	mov    %ebx,%ecx
  8011df:	d3 ed                	shr    %cl,%ebp
  8011e1:	89 f9                	mov    %edi,%ecx
  8011e3:	d3 e0                	shl    %cl,%eax
  8011e5:	09 ee                	or     %ebp,%esi
  8011e7:	89 d9                	mov    %ebx,%ecx
  8011e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ed:	89 d5                	mov    %edx,%ebp
  8011ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011f3:	d3 ed                	shr    %cl,%ebp
  8011f5:	89 f9                	mov    %edi,%ecx
  8011f7:	d3 e2                	shl    %cl,%edx
  8011f9:	89 d9                	mov    %ebx,%ecx
  8011fb:	d3 e8                	shr    %cl,%eax
  8011fd:	09 c2                	or     %eax,%edx
  8011ff:	89 d0                	mov    %edx,%eax
  801201:	89 ea                	mov    %ebp,%edx
  801203:	f7 f6                	div    %esi
  801205:	89 d5                	mov    %edx,%ebp
  801207:	89 c3                	mov    %eax,%ebx
  801209:	f7 64 24 0c          	mull   0xc(%esp)
  80120d:	39 d5                	cmp    %edx,%ebp
  80120f:	72 10                	jb     801221 <__udivdi3+0xc1>
  801211:	8b 74 24 08          	mov    0x8(%esp),%esi
  801215:	89 f9                	mov    %edi,%ecx
  801217:	d3 e6                	shl    %cl,%esi
  801219:	39 c6                	cmp    %eax,%esi
  80121b:	73 07                	jae    801224 <__udivdi3+0xc4>
  80121d:	39 d5                	cmp    %edx,%ebp
  80121f:	75 03                	jne    801224 <__udivdi3+0xc4>
  801221:	83 eb 01             	sub    $0x1,%ebx
  801224:	31 ff                	xor    %edi,%edi
  801226:	89 d8                	mov    %ebx,%eax
  801228:	89 fa                	mov    %edi,%edx
  80122a:	83 c4 1c             	add    $0x1c,%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    
  801232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801238:	31 ff                	xor    %edi,%edi
  80123a:	31 db                	xor    %ebx,%ebx
  80123c:	89 d8                	mov    %ebx,%eax
  80123e:	89 fa                	mov    %edi,%edx
  801240:	83 c4 1c             	add    $0x1c,%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    
  801248:	90                   	nop
  801249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 d8                	mov    %ebx,%eax
  801252:	f7 f7                	div    %edi
  801254:	31 ff                	xor    %edi,%edi
  801256:	89 c3                	mov    %eax,%ebx
  801258:	89 d8                	mov    %ebx,%eax
  80125a:	89 fa                	mov    %edi,%edx
  80125c:	83 c4 1c             	add    $0x1c,%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	39 ce                	cmp    %ecx,%esi
  80126a:	72 0c                	jb     801278 <__udivdi3+0x118>
  80126c:	31 db                	xor    %ebx,%ebx
  80126e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801272:	0f 87 34 ff ff ff    	ja     8011ac <__udivdi3+0x4c>
  801278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80127d:	e9 2a ff ff ff       	jmp    8011ac <__udivdi3+0x4c>
  801282:	66 90                	xchg   %ax,%ax
  801284:	66 90                	xchg   %ax,%ax
  801286:	66 90                	xchg   %ax,%ax
  801288:	66 90                	xchg   %ax,%ax
  80128a:	66 90                	xchg   %ax,%ax
  80128c:	66 90                	xchg   %ax,%ax
  80128e:	66 90                	xchg   %ax,%ax

00801290 <__umoddi3>:
  801290:	55                   	push   %ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	83 ec 1c             	sub    $0x1c,%esp
  801297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80129b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80129f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012a7:	85 d2                	test   %edx,%edx
  8012a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012b1:	89 f3                	mov    %esi,%ebx
  8012b3:	89 3c 24             	mov    %edi,(%esp)
  8012b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ba:	75 1c                	jne    8012d8 <__umoddi3+0x48>
  8012bc:	39 f7                	cmp    %esi,%edi
  8012be:	76 50                	jbe    801310 <__umoddi3+0x80>
  8012c0:	89 c8                	mov    %ecx,%eax
  8012c2:	89 f2                	mov    %esi,%edx
  8012c4:	f7 f7                	div    %edi
  8012c6:	89 d0                	mov    %edx,%eax
  8012c8:	31 d2                	xor    %edx,%edx
  8012ca:	83 c4 1c             	add    $0x1c,%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    
  8012d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d8:	39 f2                	cmp    %esi,%edx
  8012da:	89 d0                	mov    %edx,%eax
  8012dc:	77 52                	ja     801330 <__umoddi3+0xa0>
  8012de:	0f bd ea             	bsr    %edx,%ebp
  8012e1:	83 f5 1f             	xor    $0x1f,%ebp
  8012e4:	75 5a                	jne    801340 <__umoddi3+0xb0>
  8012e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012ea:	0f 82 e0 00 00 00    	jb     8013d0 <__umoddi3+0x140>
  8012f0:	39 0c 24             	cmp    %ecx,(%esp)
  8012f3:	0f 86 d7 00 00 00    	jbe    8013d0 <__umoddi3+0x140>
  8012f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801301:	83 c4 1c             	add    $0x1c,%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5f                   	pop    %edi
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    
  801309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801310:	85 ff                	test   %edi,%edi
  801312:	89 fd                	mov    %edi,%ebp
  801314:	75 0b                	jne    801321 <__umoddi3+0x91>
  801316:	b8 01 00 00 00       	mov    $0x1,%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	f7 f7                	div    %edi
  80131f:	89 c5                	mov    %eax,%ebp
  801321:	89 f0                	mov    %esi,%eax
  801323:	31 d2                	xor    %edx,%edx
  801325:	f7 f5                	div    %ebp
  801327:	89 c8                	mov    %ecx,%eax
  801329:	f7 f5                	div    %ebp
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	eb 99                	jmp    8012c8 <__umoddi3+0x38>
  80132f:	90                   	nop
  801330:	89 c8                	mov    %ecx,%eax
  801332:	89 f2                	mov    %esi,%edx
  801334:	83 c4 1c             	add    $0x1c,%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    
  80133c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801340:	8b 34 24             	mov    (%esp),%esi
  801343:	bf 20 00 00 00       	mov    $0x20,%edi
  801348:	89 e9                	mov    %ebp,%ecx
  80134a:	29 ef                	sub    %ebp,%edi
  80134c:	d3 e0                	shl    %cl,%eax
  80134e:	89 f9                	mov    %edi,%ecx
  801350:	89 f2                	mov    %esi,%edx
  801352:	d3 ea                	shr    %cl,%edx
  801354:	89 e9                	mov    %ebp,%ecx
  801356:	09 c2                	or     %eax,%edx
  801358:	89 d8                	mov    %ebx,%eax
  80135a:	89 14 24             	mov    %edx,(%esp)
  80135d:	89 f2                	mov    %esi,%edx
  80135f:	d3 e2                	shl    %cl,%edx
  801361:	89 f9                	mov    %edi,%ecx
  801363:	89 54 24 04          	mov    %edx,0x4(%esp)
  801367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80136b:	d3 e8                	shr    %cl,%eax
  80136d:	89 e9                	mov    %ebp,%ecx
  80136f:	89 c6                	mov    %eax,%esi
  801371:	d3 e3                	shl    %cl,%ebx
  801373:	89 f9                	mov    %edi,%ecx
  801375:	89 d0                	mov    %edx,%eax
  801377:	d3 e8                	shr    %cl,%eax
  801379:	89 e9                	mov    %ebp,%ecx
  80137b:	09 d8                	or     %ebx,%eax
  80137d:	89 d3                	mov    %edx,%ebx
  80137f:	89 f2                	mov    %esi,%edx
  801381:	f7 34 24             	divl   (%esp)
  801384:	89 d6                	mov    %edx,%esi
  801386:	d3 e3                	shl    %cl,%ebx
  801388:	f7 64 24 04          	mull   0x4(%esp)
  80138c:	39 d6                	cmp    %edx,%esi
  80138e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801392:	89 d1                	mov    %edx,%ecx
  801394:	89 c3                	mov    %eax,%ebx
  801396:	72 08                	jb     8013a0 <__umoddi3+0x110>
  801398:	75 11                	jne    8013ab <__umoddi3+0x11b>
  80139a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80139e:	73 0b                	jae    8013ab <__umoddi3+0x11b>
  8013a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013a4:	1b 14 24             	sbb    (%esp),%edx
  8013a7:	89 d1                	mov    %edx,%ecx
  8013a9:	89 c3                	mov    %eax,%ebx
  8013ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013af:	29 da                	sub    %ebx,%edx
  8013b1:	19 ce                	sbb    %ecx,%esi
  8013b3:	89 f9                	mov    %edi,%ecx
  8013b5:	89 f0                	mov    %esi,%eax
  8013b7:	d3 e0                	shl    %cl,%eax
  8013b9:	89 e9                	mov    %ebp,%ecx
  8013bb:	d3 ea                	shr    %cl,%edx
  8013bd:	89 e9                	mov    %ebp,%ecx
  8013bf:	d3 ee                	shr    %cl,%esi
  8013c1:	09 d0                	or     %edx,%eax
  8013c3:	89 f2                	mov    %esi,%edx
  8013c5:	83 c4 1c             	add    $0x1c,%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    
  8013cd:	8d 76 00             	lea    0x0(%esi),%esi
  8013d0:	29 f9                	sub    %edi,%ecx
  8013d2:	19 d6                	sbb    %edx,%esi
  8013d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013dc:	e9 18 ff ff ff       	jmp    8012f9 <__umoddi3+0x69>
