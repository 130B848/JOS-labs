
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 3b 04 80 00       	push   $0x80043b
  80003e:	6a 00                	push   $0x0
  800040:	e8 f1 02 00 00       	call   800336 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005f:	e8 f9 00 00 00       	call   80015d <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	c1 e0 07             	shl    $0x7,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 66 00 00 00       	call   80010d <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	89 c3                	mov    %eax,%ebx
  8000be:	89 c7                	mov    %eax,%edi
  8000c0:	51                   	push   %ecx
  8000c1:	52                   	push   %edx
  8000c2:	53                   	push   %ebx
  8000c3:	54                   	push   %esp
  8000c4:	55                   	push   %ebp
  8000c5:	56                   	push   %esi
  8000c6:	57                   	push   %edi
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	8d 35 d1 00 80 00    	lea    0x8000d1,%esi
  8000cf:	0f 34                	sysenter 

008000d1 <label_21>:
  8000d1:	5f                   	pop    %edi
  8000d2:	5e                   	pop    %esi
  8000d3:	5d                   	pop    %ebp
  8000d4:	5c                   	pop    %esp
  8000d5:	5b                   	pop    %ebx
  8000d6:	5a                   	pop    %edx
  8000d7:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 ca                	mov    %ecx,%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	51                   	push   %ecx
  8000f2:	52                   	push   %edx
  8000f3:	53                   	push   %ebx
  8000f4:	54                   	push   %esp
  8000f5:	55                   	push   %ebp
  8000f6:	56                   	push   %esi
  8000f7:	57                   	push   %edi
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	8d 35 02 01 80 00    	lea    0x800102,%esi
  800100:	0f 34                	sysenter 

00800102 <label_55>:
  800102:	5f                   	pop    %edi
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	5c                   	pop    %esp
  800106:	5b                   	pop    %ebx
  800107:	5a                   	pop    %edx
  800108:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800109:	5b                   	pop    %ebx
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800112:	bb 00 00 00 00       	mov    $0x0,%ebx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	89 d9                	mov    %ebx,%ecx
  800121:	89 df                	mov    %ebx,%edi
  800123:	51                   	push   %ecx
  800124:	52                   	push   %edx
  800125:	53                   	push   %ebx
  800126:	54                   	push   %esp
  800127:	55                   	push   %ebp
  800128:	56                   	push   %esi
  800129:	57                   	push   %edi
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	8d 35 34 01 80 00    	lea    0x800134,%esi
  800132:	0f 34                	sysenter 

00800134 <label_90>:
  800134:	5f                   	pop    %edi
  800135:	5e                   	pop    %esi
  800136:	5d                   	pop    %ebp
  800137:	5c                   	pop    %esp
  800138:	5b                   	pop    %ebx
  800139:	5a                   	pop    %edx
  80013a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80013b:	85 c0                	test   %eax,%eax
  80013d:	7e 17                	jle    800156 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	50                   	push   %eax
  800143:	6a 03                	push   $0x3
  800145:	68 2a 14 80 00       	push   $0x80142a
  80014a:	6a 2a                	push   $0x2a
  80014c:	68 47 14 80 00       	push   $0x801447
  800151:	e8 f0 02 00 00       	call   800446 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800156:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800159:	5b                   	pop    %ebx
  80015a:	5f                   	pop    %edi
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800162:	b9 00 00 00 00       	mov    $0x0,%ecx
  800167:	b8 02 00 00 00       	mov    $0x2,%eax
  80016c:	89 ca                	mov    %ecx,%edx
  80016e:	89 cb                	mov    %ecx,%ebx
  800170:	89 cf                	mov    %ecx,%edi
  800172:	51                   	push   %ecx
  800173:	52                   	push   %edx
  800174:	53                   	push   %ebx
  800175:	54                   	push   %esp
  800176:	55                   	push   %ebp
  800177:	56                   	push   %esi
  800178:	57                   	push   %edi
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	8d 35 83 01 80 00    	lea    0x800183,%esi
  800181:	0f 34                	sysenter 

00800183 <label_139>:
  800183:	5f                   	pop    %edi
  800184:	5e                   	pop    %esi
  800185:	5d                   	pop    %ebp
  800186:	5c                   	pop    %esp
  800187:	5b                   	pop    %ebx
  800188:	5a                   	pop    %edx
  800189:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018a:	5b                   	pop    %ebx
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    

0080018e <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800193:	bf 00 00 00 00       	mov    $0x0,%edi
  800198:	b8 04 00 00 00       	mov    $0x4,%eax
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a3:	89 fb                	mov    %edi,%ebx
  8001a5:	51                   	push   %ecx
  8001a6:	52                   	push   %edx
  8001a7:	53                   	push   %ebx
  8001a8:	54                   	push   %esp
  8001a9:	55                   	push   %ebp
  8001aa:	56                   	push   %esi
  8001ab:	57                   	push   %edi
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	8d 35 b6 01 80 00    	lea    0x8001b6,%esi
  8001b4:	0f 34                	sysenter 

008001b6 <label_174>:
  8001b6:	5f                   	pop    %edi
  8001b7:	5e                   	pop    %esi
  8001b8:	5d                   	pop    %ebp
  8001b9:	5c                   	pop    %esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5a                   	pop    %edx
  8001bc:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001bd:	5b                   	pop    %ebx
  8001be:	5f                   	pop    %edi
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    

008001c1 <sys_yield>:

void
sys_yield(void)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8001cb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001d0:	89 d1                	mov    %edx,%ecx
  8001d2:	89 d3                	mov    %edx,%ebx
  8001d4:	89 d7                	mov    %edx,%edi
  8001d6:	51                   	push   %ecx
  8001d7:	52                   	push   %edx
  8001d8:	53                   	push   %ebx
  8001d9:	54                   	push   %esp
  8001da:	55                   	push   %ebp
  8001db:	56                   	push   %esi
  8001dc:	57                   	push   %edi
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	8d 35 e7 01 80 00    	lea    0x8001e7,%esi
  8001e5:	0f 34                	sysenter 

008001e7 <label_209>:
  8001e7:	5f                   	pop    %edi
  8001e8:	5e                   	pop    %esi
  8001e9:	5d                   	pop    %ebp
  8001ea:	5c                   	pop    %esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5a                   	pop    %edx
  8001ed:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001ee:	5b                   	pop    %ebx
  8001ef:	5f                   	pop    %edi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	57                   	push   %edi
  8001f6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8001fc:	b8 05 00 00 00       	mov    $0x5,%eax
  800201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800204:	8b 55 08             	mov    0x8(%ebp),%edx
  800207:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020a:	51                   	push   %ecx
  80020b:	52                   	push   %edx
  80020c:	53                   	push   %ebx
  80020d:	54                   	push   %esp
  80020e:	55                   	push   %ebp
  80020f:	56                   	push   %esi
  800210:	57                   	push   %edi
  800211:	89 e5                	mov    %esp,%ebp
  800213:	8d 35 1b 02 80 00    	lea    0x80021b,%esi
  800219:	0f 34                	sysenter 

0080021b <label_244>:
  80021b:	5f                   	pop    %edi
  80021c:	5e                   	pop    %esi
  80021d:	5d                   	pop    %ebp
  80021e:	5c                   	pop    %esp
  80021f:	5b                   	pop    %ebx
  800220:	5a                   	pop    %edx
  800221:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800222:	85 c0                	test   %eax,%eax
  800224:	7e 17                	jle    80023d <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800226:	83 ec 0c             	sub    $0xc,%esp
  800229:	50                   	push   %eax
  80022a:	6a 05                	push   $0x5
  80022c:	68 2a 14 80 00       	push   $0x80142a
  800231:	6a 2a                	push   $0x2a
  800233:	68 47 14 80 00       	push   $0x801447
  800238:	e8 09 02 00 00       	call   800446 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80023d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800240:	5b                   	pop    %ebx
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800249:	b8 06 00 00 00       	mov    $0x6,%eax
  80024e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800251:	8b 55 08             	mov    0x8(%ebp),%edx
  800254:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800257:	8b 7d 14             	mov    0x14(%ebp),%edi
  80025a:	51                   	push   %ecx
  80025b:	52                   	push   %edx
  80025c:	53                   	push   %ebx
  80025d:	54                   	push   %esp
  80025e:	55                   	push   %ebp
  80025f:	56                   	push   %esi
  800260:	57                   	push   %edi
  800261:	89 e5                	mov    %esp,%ebp
  800263:	8d 35 6b 02 80 00    	lea    0x80026b,%esi
  800269:	0f 34                	sysenter 

0080026b <label_295>:
  80026b:	5f                   	pop    %edi
  80026c:	5e                   	pop    %esi
  80026d:	5d                   	pop    %ebp
  80026e:	5c                   	pop    %esp
  80026f:	5b                   	pop    %ebx
  800270:	5a                   	pop    %edx
  800271:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800272:	85 c0                	test   %eax,%eax
  800274:	7e 17                	jle    80028d <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	50                   	push   %eax
  80027a:	6a 06                	push   $0x6
  80027c:	68 2a 14 80 00       	push   $0x80142a
  800281:	6a 2a                	push   $0x2a
  800283:	68 47 14 80 00       	push   $0x801447
  800288:	e8 b9 01 00 00       	call   800446 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80028d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800299:	bf 00 00 00 00       	mov    $0x0,%edi
  80029e:	b8 07 00 00 00       	mov    $0x7,%eax
  8002a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a9:	89 fb                	mov    %edi,%ebx
  8002ab:	51                   	push   %ecx
  8002ac:	52                   	push   %edx
  8002ad:	53                   	push   %ebx
  8002ae:	54                   	push   %esp
  8002af:	55                   	push   %ebp
  8002b0:	56                   	push   %esi
  8002b1:	57                   	push   %edi
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8d 35 bc 02 80 00    	lea    0x8002bc,%esi
  8002ba:	0f 34                	sysenter 

008002bc <label_344>:
  8002bc:	5f                   	pop    %edi
  8002bd:	5e                   	pop    %esi
  8002be:	5d                   	pop    %ebp
  8002bf:	5c                   	pop    %esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5a                   	pop    %edx
  8002c2:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	7e 17                	jle    8002de <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002c7:	83 ec 0c             	sub    $0xc,%esp
  8002ca:	50                   	push   %eax
  8002cb:	6a 07                	push   $0x7
  8002cd:	68 2a 14 80 00       	push   $0x80142a
  8002d2:	6a 2a                	push   $0x2a
  8002d4:	68 47 14 80 00       	push   $0x801447
  8002d9:	e8 68 01 00 00       	call   800446 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5f                   	pop    %edi
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8002ef:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fa:	89 fb                	mov    %edi,%ebx
  8002fc:	51                   	push   %ecx
  8002fd:	52                   	push   %edx
  8002fe:	53                   	push   %ebx
  8002ff:	54                   	push   %esp
  800300:	55                   	push   %ebp
  800301:	56                   	push   %esi
  800302:	57                   	push   %edi
  800303:	89 e5                	mov    %esp,%ebp
  800305:	8d 35 0d 03 80 00    	lea    0x80030d,%esi
  80030b:	0f 34                	sysenter 

0080030d <label_393>:
  80030d:	5f                   	pop    %edi
  80030e:	5e                   	pop    %esi
  80030f:	5d                   	pop    %ebp
  800310:	5c                   	pop    %esp
  800311:	5b                   	pop    %ebx
  800312:	5a                   	pop    %edx
  800313:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800314:	85 c0                	test   %eax,%eax
  800316:	7e 17                	jle    80032f <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	50                   	push   %eax
  80031c:	6a 09                	push   $0x9
  80031e:	68 2a 14 80 00       	push   $0x80142a
  800323:	6a 2a                	push   $0x2a
  800325:	68 47 14 80 00       	push   $0x801447
  80032a:	e8 17 01 00 00       	call   800446 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80032f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800332:	5b                   	pop    %ebx
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80033b:	bf 00 00 00 00       	mov    $0x0,%edi
  800340:	b8 0a 00 00 00       	mov    $0xa,%eax
  800345:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800348:	8b 55 08             	mov    0x8(%ebp),%edx
  80034b:	89 fb                	mov    %edi,%ebx
  80034d:	51                   	push   %ecx
  80034e:	52                   	push   %edx
  80034f:	53                   	push   %ebx
  800350:	54                   	push   %esp
  800351:	55                   	push   %ebp
  800352:	56                   	push   %esi
  800353:	57                   	push   %edi
  800354:	89 e5                	mov    %esp,%ebp
  800356:	8d 35 5e 03 80 00    	lea    0x80035e,%esi
  80035c:	0f 34                	sysenter 

0080035e <label_442>:
  80035e:	5f                   	pop    %edi
  80035f:	5e                   	pop    %esi
  800360:	5d                   	pop    %ebp
  800361:	5c                   	pop    %esp
  800362:	5b                   	pop    %ebx
  800363:	5a                   	pop    %edx
  800364:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800365:	85 c0                	test   %eax,%eax
  800367:	7e 17                	jle    800380 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800369:	83 ec 0c             	sub    $0xc,%esp
  80036c:	50                   	push   %eax
  80036d:	6a 0a                	push   $0xa
  80036f:	68 2a 14 80 00       	push   $0x80142a
  800374:	6a 2a                	push   $0x2a
  800376:	68 47 14 80 00       	push   $0x801447
  80037b:	e8 c6 00 00 00       	call   800446 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800380:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800383:	5b                   	pop    %ebx
  800384:	5f                   	pop    %edi
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	57                   	push   %edi
  80038b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80038c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800391:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80039d:	51                   	push   %ecx
  80039e:	52                   	push   %edx
  80039f:	53                   	push   %ebx
  8003a0:	54                   	push   %esp
  8003a1:	55                   	push   %ebp
  8003a2:	56                   	push   %esi
  8003a3:	57                   	push   %edi
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	8d 35 ae 03 80 00    	lea    0x8003ae,%esi
  8003ac:	0f 34                	sysenter 

008003ae <label_493>:
  8003ae:	5f                   	pop    %edi
  8003af:	5e                   	pop    %esi
  8003b0:	5d                   	pop    %ebp
  8003b1:	5c                   	pop    %esp
  8003b2:	5b                   	pop    %ebx
  8003b3:	5a                   	pop    %edx
  8003b4:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003b5:	5b                   	pop    %ebx
  8003b6:	5f                   	pop    %edi
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cb:	89 d9                	mov    %ebx,%ecx
  8003cd:	89 df                	mov    %ebx,%edi
  8003cf:	51                   	push   %ecx
  8003d0:	52                   	push   %edx
  8003d1:	53                   	push   %ebx
  8003d2:	54                   	push   %esp
  8003d3:	55                   	push   %ebp
  8003d4:	56                   	push   %esi
  8003d5:	57                   	push   %edi
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	8d 35 e0 03 80 00    	lea    0x8003e0,%esi
  8003de:	0f 34                	sysenter 

008003e0 <label_528>:
  8003e0:	5f                   	pop    %edi
  8003e1:	5e                   	pop    %esi
  8003e2:	5d                   	pop    %ebp
  8003e3:	5c                   	pop    %esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5a                   	pop    %edx
  8003e6:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	7e 17                	jle    800402 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8003eb:	83 ec 0c             	sub    $0xc,%esp
  8003ee:	50                   	push   %eax
  8003ef:	6a 0d                	push   $0xd
  8003f1:	68 2a 14 80 00       	push   $0x80142a
  8003f6:	6a 2a                	push   $0x2a
  8003f8:	68 47 14 80 00       	push   $0x801447
  8003fd:	e8 44 00 00 00       	call   800446 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800402:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800405:	5b                   	pop    %ebx
  800406:	5f                   	pop    %edi
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	57                   	push   %edi
  80040d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80040e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800413:	b8 0e 00 00 00       	mov    $0xe,%eax
  800418:	8b 55 08             	mov    0x8(%ebp),%edx
  80041b:	89 cb                	mov    %ecx,%ebx
  80041d:	89 cf                	mov    %ecx,%edi
  80041f:	51                   	push   %ecx
  800420:	52                   	push   %edx
  800421:	53                   	push   %ebx
  800422:	54                   	push   %esp
  800423:	55                   	push   %ebp
  800424:	56                   	push   %esi
  800425:	57                   	push   %edi
  800426:	89 e5                	mov    %esp,%ebp
  800428:	8d 35 30 04 80 00    	lea    0x800430,%esi
  80042e:	0f 34                	sysenter 

00800430 <label_577>:
  800430:	5f                   	pop    %edi
  800431:	5e                   	pop    %esi
  800432:	5d                   	pop    %ebp
  800433:	5c                   	pop    %esp
  800434:	5b                   	pop    %ebx
  800435:	5a                   	pop    %edx
  800436:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800437:	5b                   	pop    %ebx
  800438:	5f                   	pop    %edi
  800439:	5d                   	pop    %ebp
  80043a:	c3                   	ret    

0080043b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80043b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80043c:	a1 14 20 80 00       	mov    0x802014,%eax
	call *%eax
  800441:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800443:	83 c4 04             	add    $0x4,%esp

00800446 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	56                   	push   %esi
  80044a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80044b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80044e:	a1 10 20 80 00       	mov    0x802010,%eax
  800453:	85 c0                	test   %eax,%eax
  800455:	74 11                	je     800468 <_panic+0x22>
		cprintf("%s: ", argv0);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	50                   	push   %eax
  80045b:	68 55 14 80 00       	push   $0x801455
  800460:	e8 d4 00 00 00       	call   800539 <cprintf>
  800465:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800468:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80046e:	e8 ea fc ff ff       	call   80015d <sys_getenvid>
  800473:	83 ec 0c             	sub    $0xc,%esp
  800476:	ff 75 0c             	pushl  0xc(%ebp)
  800479:	ff 75 08             	pushl  0x8(%ebp)
  80047c:	56                   	push   %esi
  80047d:	50                   	push   %eax
  80047e:	68 5c 14 80 00       	push   $0x80145c
  800483:	e8 b1 00 00 00       	call   800539 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800488:	83 c4 18             	add    $0x18,%esp
  80048b:	53                   	push   %ebx
  80048c:	ff 75 10             	pushl  0x10(%ebp)
  80048f:	e8 54 00 00 00       	call   8004e8 <vcprintf>
	cprintf("\n");
  800494:	c7 04 24 5a 14 80 00 	movl   $0x80145a,(%esp)
  80049b:	e8 99 00 00 00       	call   800539 <cprintf>
  8004a0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a3:	cc                   	int3   
  8004a4:	eb fd                	jmp    8004a3 <_panic+0x5d>

008004a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	53                   	push   %ebx
  8004aa:	83 ec 04             	sub    $0x4,%esp
  8004ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b0:	8b 13                	mov    (%ebx),%edx
  8004b2:	8d 42 01             	lea    0x1(%edx),%eax
  8004b5:	89 03                	mov    %eax,(%ebx)
  8004b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c3:	75 1a                	jne    8004df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	68 ff 00 00 00       	push   $0xff
  8004cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d0:	50                   	push   %eax
  8004d1:	e8 d6 fb ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8004d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f8:	00 00 00 
	b.cnt = 0;
  8004fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800502:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	ff 75 08             	pushl  0x8(%ebp)
  80050b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800511:	50                   	push   %eax
  800512:	68 a6 04 80 00       	push   $0x8004a6
  800517:	e8 c0 02 00 00       	call   8007dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80051c:	83 c4 08             	add    $0x8,%esp
  80051f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800525:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80052b:	50                   	push   %eax
  80052c:	e8 7b fb ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800531:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800537:	c9                   	leave  
  800538:	c3                   	ret    

00800539 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800542:	50                   	push   %eax
  800543:	ff 75 08             	pushl  0x8(%ebp)
  800546:	e8 9d ff ff ff       	call   8004e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    

0080054d <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	57                   	push   %edi
  800551:	56                   	push   %esi
  800552:	53                   	push   %ebx
  800553:	83 ec 1c             	sub    $0x1c,%esp
  800556:	89 c7                	mov    %eax,%edi
  800558:	89 d6                	mov    %edx,%esi
  80055a:	8b 45 08             	mov    0x8(%ebp),%eax
  80055d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800560:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800563:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800566:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800569:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80056d:	0f 85 bf 00 00 00    	jne    800632 <printnum+0xe5>
  800573:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800579:	0f 8d de 00 00 00    	jge    80065d <printnum+0x110>
		judge_time_for_space = width;
  80057f:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800585:	e9 d3 00 00 00       	jmp    80065d <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	85 db                	test   %ebx,%ebx
  80058f:	7f 37                	jg     8005c8 <printnum+0x7b>
  800591:	e9 ea 00 00 00       	jmp    800680 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800596:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800599:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	56                   	push   %esi
  8005a2:	83 ec 04             	sub    $0x4,%esp
  8005a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8005a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8005ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b1:	e8 fa 0c 00 00       	call   8012b0 <__umoddi3>
  8005b6:	83 c4 14             	add    $0x14,%esp
  8005b9:	0f be 80 7f 14 80 00 	movsbl 0x80147f(%eax),%eax
  8005c0:	50                   	push   %eax
  8005c1:	ff d7                	call   *%edi
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	eb 16                	jmp    8005de <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	56                   	push   %esi
  8005cc:	ff 75 18             	pushl  0x18(%ebp)
  8005cf:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	83 eb 01             	sub    $0x1,%ebx
  8005d7:	75 ef                	jne    8005c8 <printnum+0x7b>
  8005d9:	e9 a2 00 00 00       	jmp    800680 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005de:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005e4:	0f 85 76 01 00 00    	jne    800760 <printnum+0x213>
		while(num_of_space-- > 0)
  8005ea:	a1 04 20 80 00       	mov    0x802004,%eax
  8005ef:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005f2:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	7e 1d                	jle    800619 <printnum+0xcc>
			putch(' ', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	56                   	push   %esi
  800600:	6a 20                	push   $0x20
  800602:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800604:	a1 04 20 80 00       	mov    0x802004,%eax
  800609:	8d 50 ff             	lea    -0x1(%eax),%edx
  80060c:	89 15 04 20 80 00    	mov    %edx,0x802004
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 c0                	test   %eax,%eax
  800617:	7f e3                	jg     8005fc <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800619:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800620:	00 00 00 
		judge_time_for_space = 0;
  800623:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80062a:	00 00 00 
	}
}
  80062d:	e9 2e 01 00 00       	jmp    800760 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800632:	8b 45 10             	mov    0x10(%ebp),%eax
  800635:	ba 00 00 00 00       	mov    $0x0,%edx
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800643:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800646:	83 fa 00             	cmp    $0x0,%edx
  800649:	0f 87 ba 00 00 00    	ja     800709 <printnum+0x1bc>
  80064f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800652:	0f 83 b1 00 00 00    	jae    800709 <printnum+0x1bc>
  800658:	e9 2d ff ff ff       	jmp    80058a <printnum+0x3d>
  80065d:	8b 45 10             	mov    0x10(%ebp),%eax
  800660:	ba 00 00 00 00       	mov    $0x0,%edx
  800665:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800668:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800671:	83 fa 00             	cmp    $0x0,%edx
  800674:	77 37                	ja     8006ad <printnum+0x160>
  800676:	3b 45 10             	cmp    0x10(%ebp),%eax
  800679:	73 32                	jae    8006ad <printnum+0x160>
  80067b:	e9 16 ff ff ff       	jmp    800596 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	56                   	push   %esi
  800684:	83 ec 04             	sub    $0x4,%esp
  800687:	ff 75 dc             	pushl  -0x24(%ebp)
  80068a:	ff 75 d8             	pushl  -0x28(%ebp)
  80068d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800690:	ff 75 e0             	pushl  -0x20(%ebp)
  800693:	e8 18 0c 00 00       	call   8012b0 <__umoddi3>
  800698:	83 c4 14             	add    $0x14,%esp
  80069b:	0f be 80 7f 14 80 00 	movsbl 0x80147f(%eax),%eax
  8006a2:	50                   	push   %eax
  8006a3:	ff d7                	call   *%edi
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	e9 b3 00 00 00       	jmp    800760 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006ad:	83 ec 0c             	sub    $0xc,%esp
  8006b0:	ff 75 18             	pushl  0x18(%ebp)
  8006b3:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006b6:	50                   	push   %eax
  8006b7:	ff 75 10             	pushl  0x10(%ebp)
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	e8 b2 0a 00 00       	call   801180 <__udivdi3>
  8006ce:	83 c4 18             	add    $0x18,%esp
  8006d1:	52                   	push   %edx
  8006d2:	50                   	push   %eax
  8006d3:	89 f2                	mov    %esi,%edx
  8006d5:	89 f8                	mov    %edi,%eax
  8006d7:	e8 71 fe ff ff       	call   80054d <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006dc:	83 c4 18             	add    $0x18,%esp
  8006df:	56                   	push   %esi
  8006e0:	83 ec 04             	sub    $0x4,%esp
  8006e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8006e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ef:	e8 bc 0b 00 00       	call   8012b0 <__umoddi3>
  8006f4:	83 c4 14             	add    $0x14,%esp
  8006f7:	0f be 80 7f 14 80 00 	movsbl 0x80147f(%eax),%eax
  8006fe:	50                   	push   %eax
  8006ff:	ff d7                	call   *%edi
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	e9 d5 fe ff ff       	jmp    8005de <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	ff 75 18             	pushl  0x18(%ebp)
  80070f:	83 eb 01             	sub    $0x1,%ebx
  800712:	53                   	push   %ebx
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	ff 75 dc             	pushl  -0x24(%ebp)
  80071c:	ff 75 d8             	pushl  -0x28(%ebp)
  80071f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800722:	ff 75 e0             	pushl  -0x20(%ebp)
  800725:	e8 56 0a 00 00       	call   801180 <__udivdi3>
  80072a:	83 c4 18             	add    $0x18,%esp
  80072d:	52                   	push   %edx
  80072e:	50                   	push   %eax
  80072f:	89 f2                	mov    %esi,%edx
  800731:	89 f8                	mov    %edi,%eax
  800733:	e8 15 fe ff ff       	call   80054d <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	56                   	push   %esi
  80073c:	83 ec 04             	sub    $0x4,%esp
  80073f:	ff 75 dc             	pushl  -0x24(%ebp)
  800742:	ff 75 d8             	pushl  -0x28(%ebp)
  800745:	ff 75 e4             	pushl  -0x1c(%ebp)
  800748:	ff 75 e0             	pushl  -0x20(%ebp)
  80074b:	e8 60 0b 00 00       	call   8012b0 <__umoddi3>
  800750:	83 c4 14             	add    $0x14,%esp
  800753:	0f be 80 7f 14 80 00 	movsbl 0x80147f(%eax),%eax
  80075a:	50                   	push   %eax
  80075b:	ff d7                	call   *%edi
  80075d:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800760:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5f                   	pop    %edi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80076b:	83 fa 01             	cmp    $0x1,%edx
  80076e:	7e 0e                	jle    80077e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800770:	8b 10                	mov    (%eax),%edx
  800772:	8d 4a 08             	lea    0x8(%edx),%ecx
  800775:	89 08                	mov    %ecx,(%eax)
  800777:	8b 02                	mov    (%edx),%eax
  800779:	8b 52 04             	mov    0x4(%edx),%edx
  80077c:	eb 22                	jmp    8007a0 <getuint+0x38>
	else if (lflag)
  80077e:	85 d2                	test   %edx,%edx
  800780:	74 10                	je     800792 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800782:	8b 10                	mov    (%eax),%edx
  800784:	8d 4a 04             	lea    0x4(%edx),%ecx
  800787:	89 08                	mov    %ecx,(%eax)
  800789:	8b 02                	mov    (%edx),%eax
  80078b:	ba 00 00 00 00       	mov    $0x0,%edx
  800790:	eb 0e                	jmp    8007a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800792:	8b 10                	mov    (%eax),%edx
  800794:	8d 4a 04             	lea    0x4(%edx),%ecx
  800797:	89 08                	mov    %ecx,(%eax)
  800799:	8b 02                	mov    (%edx),%eax
  80079b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007ac:	8b 10                	mov    (%eax),%edx
  8007ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8007b1:	73 0a                	jae    8007bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8007b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007b6:	89 08                	mov    %ecx,(%eax)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	88 02                	mov    %al,(%edx)
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007c8:	50                   	push   %eax
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	ff 75 08             	pushl  0x8(%ebp)
  8007d2:	e8 05 00 00 00       	call   8007dc <vprintfmt>
	va_end(ap);
}
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	57                   	push   %edi
  8007e0:	56                   	push   %esi
  8007e1:	53                   	push   %ebx
  8007e2:	83 ec 2c             	sub    $0x2c,%esp
  8007e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007eb:	eb 03                	jmp    8007f0 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ed:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f3:	8d 70 01             	lea    0x1(%eax),%esi
  8007f6:	0f b6 00             	movzbl (%eax),%eax
  8007f9:	83 f8 25             	cmp    $0x25,%eax
  8007fc:	74 27                	je     800825 <vprintfmt+0x49>
			if (ch == '\0')
  8007fe:	85 c0                	test   %eax,%eax
  800800:	75 0d                	jne    80080f <vprintfmt+0x33>
  800802:	e9 9d 04 00 00       	jmp    800ca4 <vprintfmt+0x4c8>
  800807:	85 c0                	test   %eax,%eax
  800809:	0f 84 95 04 00 00    	je     800ca4 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	53                   	push   %ebx
  800813:	50                   	push   %eax
  800814:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800816:	83 c6 01             	add    $0x1,%esi
  800819:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	83 f8 25             	cmp    $0x25,%eax
  800823:	75 e2                	jne    800807 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800825:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80082e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800835:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80083c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800843:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80084a:	eb 08                	jmp    800854 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084c:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80084f:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800854:	8d 46 01             	lea    0x1(%esi),%eax
  800857:	89 45 10             	mov    %eax,0x10(%ebp)
  80085a:	0f b6 06             	movzbl (%esi),%eax
  80085d:	0f b6 d0             	movzbl %al,%edx
  800860:	83 e8 23             	sub    $0x23,%eax
  800863:	3c 55                	cmp    $0x55,%al
  800865:	0f 87 fa 03 00 00    	ja     800c65 <vprintfmt+0x489>
  80086b:	0f b6 c0             	movzbl %al,%eax
  80086e:	ff 24 85 c0 15 80 00 	jmp    *0x8015c0(,%eax,4)
  800875:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800878:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80087c:	eb d6                	jmp    800854 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80087e:	8d 42 d0             	lea    -0x30(%edx),%eax
  800881:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800884:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800888:	8d 50 d0             	lea    -0x30(%eax),%edx
  80088b:	83 fa 09             	cmp    $0x9,%edx
  80088e:	77 6b                	ja     8008fb <vprintfmt+0x11f>
  800890:	8b 75 10             	mov    0x10(%ebp),%esi
  800893:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800896:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800899:	eb 09                	jmp    8008a4 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089b:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80089e:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008a2:	eb b0                	jmp    800854 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008a7:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008aa:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008ae:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008b1:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008b4:	83 f9 09             	cmp    $0x9,%ecx
  8008b7:	76 eb                	jbe    8008a4 <vprintfmt+0xc8>
  8008b9:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008bc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008bf:	eb 3d                	jmp    8008fe <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c4:	8d 50 04             	lea    0x4(%eax),%edx
  8008c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ca:	8b 00                	mov    (%eax),%eax
  8008cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008d2:	eb 2a                	jmp    8008fe <vprintfmt+0x122>
  8008d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	0f 49 d0             	cmovns %eax,%edx
  8008e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e4:	8b 75 10             	mov    0x10(%ebp),%esi
  8008e7:	e9 68 ff ff ff       	jmp    800854 <vprintfmt+0x78>
  8008ec:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ef:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008f6:	e9 59 ff ff ff       	jmp    800854 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800902:	0f 89 4c ff ff ff    	jns    800854 <vprintfmt+0x78>
				width = precision, precision = -1;
  800908:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80090b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80090e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800915:	e9 3a ff ff ff       	jmp    800854 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80091a:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800921:	e9 2e ff ff ff       	jmp    800854 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800926:	8b 45 14             	mov    0x14(%ebp),%eax
  800929:	8d 50 04             	lea    0x4(%eax),%edx
  80092c:	89 55 14             	mov    %edx,0x14(%ebp)
  80092f:	83 ec 08             	sub    $0x8,%esp
  800932:	53                   	push   %ebx
  800933:	ff 30                	pushl  (%eax)
  800935:	ff d7                	call   *%edi
			break;
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	e9 b1 fe ff ff       	jmp    8007f0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80093f:	8b 45 14             	mov    0x14(%ebp),%eax
  800942:	8d 50 04             	lea    0x4(%eax),%edx
  800945:	89 55 14             	mov    %edx,0x14(%ebp)
  800948:	8b 00                	mov    (%eax),%eax
  80094a:	99                   	cltd   
  80094b:	31 d0                	xor    %edx,%eax
  80094d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094f:	83 f8 08             	cmp    $0x8,%eax
  800952:	7f 0b                	jg     80095f <vprintfmt+0x183>
  800954:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  80095b:	85 d2                	test   %edx,%edx
  80095d:	75 15                	jne    800974 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80095f:	50                   	push   %eax
  800960:	68 97 14 80 00       	push   $0x801497
  800965:	53                   	push   %ebx
  800966:	57                   	push   %edi
  800967:	e8 53 fe ff ff       	call   8007bf <printfmt>
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	e9 7c fe ff ff       	jmp    8007f0 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800974:	52                   	push   %edx
  800975:	68 a0 14 80 00       	push   $0x8014a0
  80097a:	53                   	push   %ebx
  80097b:	57                   	push   %edi
  80097c:	e8 3e fe ff ff       	call   8007bf <printfmt>
  800981:	83 c4 10             	add    $0x10,%esp
  800984:	e9 67 fe ff ff       	jmp    8007f0 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800989:	8b 45 14             	mov    0x14(%ebp),%eax
  80098c:	8d 50 04             	lea    0x4(%eax),%edx
  80098f:	89 55 14             	mov    %edx,0x14(%ebp)
  800992:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800994:	85 c0                	test   %eax,%eax
  800996:	b9 90 14 80 00       	mov    $0x801490,%ecx
  80099b:	0f 45 c8             	cmovne %eax,%ecx
  80099e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009a5:	7e 06                	jle    8009ad <vprintfmt+0x1d1>
  8009a7:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009ab:	75 19                	jne    8009c6 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b0:	8d 70 01             	lea    0x1(%eax),%esi
  8009b3:	0f b6 00             	movzbl (%eax),%eax
  8009b6:	0f be d0             	movsbl %al,%edx
  8009b9:	85 d2                	test   %edx,%edx
  8009bb:	0f 85 9f 00 00 00    	jne    800a60 <vprintfmt+0x284>
  8009c1:	e9 8c 00 00 00       	jmp    800a52 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c6:	83 ec 08             	sub    $0x8,%esp
  8009c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8009cc:	ff 75 cc             	pushl  -0x34(%ebp)
  8009cf:	e8 62 03 00 00       	call   800d36 <strnlen>
  8009d4:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	85 c9                	test   %ecx,%ecx
  8009df:	0f 8e a6 02 00 00    	jle    800c8b <vprintfmt+0x4af>
					putch(padc, putdat);
  8009e5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ec:	89 cb                	mov    %ecx,%ebx
  8009ee:	83 ec 08             	sub    $0x8,%esp
  8009f1:	ff 75 0c             	pushl  0xc(%ebp)
  8009f4:	56                   	push   %esi
  8009f5:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	83 eb 01             	sub    $0x1,%ebx
  8009fd:	75 ef                	jne    8009ee <vprintfmt+0x212>
  8009ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a05:	e9 81 02 00 00       	jmp    800c8b <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a0a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a0e:	74 1b                	je     800a2b <vprintfmt+0x24f>
  800a10:	0f be c0             	movsbl %al,%eax
  800a13:	83 e8 20             	sub    $0x20,%eax
  800a16:	83 f8 5e             	cmp    $0x5e,%eax
  800a19:	76 10                	jbe    800a2b <vprintfmt+0x24f>
					putch('?', putdat);
  800a1b:	83 ec 08             	sub    $0x8,%esp
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	6a 3f                	push   $0x3f
  800a23:	ff 55 08             	call   *0x8(%ebp)
  800a26:	83 c4 10             	add    $0x10,%esp
  800a29:	eb 0d                	jmp    800a38 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a2b:	83 ec 08             	sub    $0x8,%esp
  800a2e:	ff 75 0c             	pushl  0xc(%ebp)
  800a31:	52                   	push   %edx
  800a32:	ff 55 08             	call   *0x8(%ebp)
  800a35:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a38:	83 ef 01             	sub    $0x1,%edi
  800a3b:	83 c6 01             	add    $0x1,%esi
  800a3e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a42:	0f be d0             	movsbl %al,%edx
  800a45:	85 d2                	test   %edx,%edx
  800a47:	75 31                	jne    800a7a <vprintfmt+0x29e>
  800a49:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a52:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a55:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a59:	7f 33                	jg     800a8e <vprintfmt+0x2b2>
  800a5b:	e9 90 fd ff ff       	jmp    8007f0 <vprintfmt+0x14>
  800a60:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a66:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a69:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a6c:	eb 0c                	jmp    800a7a <vprintfmt+0x29e>
  800a6e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a74:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a77:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	78 8c                	js     800a0a <vprintfmt+0x22e>
  800a7e:	83 eb 01             	sub    $0x1,%ebx
  800a81:	79 87                	jns    800a0a <vprintfmt+0x22e>
  800a83:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a86:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8c:	eb c4                	jmp    800a52 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a8e:	83 ec 08             	sub    $0x8,%esp
  800a91:	53                   	push   %ebx
  800a92:	6a 20                	push   $0x20
  800a94:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a96:	83 c4 10             	add    $0x10,%esp
  800a99:	83 ee 01             	sub    $0x1,%esi
  800a9c:	75 f0                	jne    800a8e <vprintfmt+0x2b2>
  800a9e:	e9 4d fd ff ff       	jmp    8007f0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aa3:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800aa7:	7e 16                	jle    800abf <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800aa9:	8b 45 14             	mov    0x14(%ebp),%eax
  800aac:	8d 50 08             	lea    0x8(%eax),%edx
  800aaf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab2:	8b 50 04             	mov    0x4(%eax),%edx
  800ab5:	8b 00                	mov    (%eax),%eax
  800ab7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800aba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800abd:	eb 34                	jmp    800af3 <vprintfmt+0x317>
	else if (lflag)
  800abf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ac3:	74 18                	je     800add <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	8d 50 04             	lea    0x4(%eax),%edx
  800acb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ace:	8b 30                	mov    (%eax),%esi
  800ad0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ad3:	89 f0                	mov    %esi,%eax
  800ad5:	c1 f8 1f             	sar    $0x1f,%eax
  800ad8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800adb:	eb 16                	jmp    800af3 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800add:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae0:	8d 50 04             	lea    0x4(%eax),%edx
  800ae3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae6:	8b 30                	mov    (%eax),%esi
  800ae8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800aeb:	89 f0                	mov    %esi,%eax
  800aed:	c1 f8 1f             	sar    $0x1f,%eax
  800af0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800af3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800af6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800af9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800afc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800aff:	85 d2                	test   %edx,%edx
  800b01:	79 28                	jns    800b2b <vprintfmt+0x34f>
				putch('-', putdat);
  800b03:	83 ec 08             	sub    $0x8,%esp
  800b06:	53                   	push   %ebx
  800b07:	6a 2d                	push   $0x2d
  800b09:	ff d7                	call   *%edi
				num = -(long long) num;
  800b0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b0e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b11:	f7 d8                	neg    %eax
  800b13:	83 d2 00             	adc    $0x0,%edx
  800b16:	f7 da                	neg    %edx
  800b18:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b1e:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b26:	e9 b2 00 00 00       	jmp    800bdd <vprintfmt+0x401>
  800b2b:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b30:	85 c9                	test   %ecx,%ecx
  800b32:	0f 84 a5 00 00 00    	je     800bdd <vprintfmt+0x401>
				putch('+', putdat);
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	53                   	push   %ebx
  800b3c:	6a 2b                	push   $0x2b
  800b3e:	ff d7                	call   *%edi
  800b40:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b43:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b48:	e9 90 00 00 00       	jmp    800bdd <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b4d:	85 c9                	test   %ecx,%ecx
  800b4f:	74 0b                	je     800b5c <vprintfmt+0x380>
				putch('+', putdat);
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	53                   	push   %ebx
  800b55:	6a 2b                	push   $0x2b
  800b57:	ff d7                	call   *%edi
  800b59:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b5c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b5f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b62:	e8 01 fc ff ff       	call   800768 <getuint>
  800b67:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b6d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b72:	eb 69                	jmp    800bdd <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b74:	83 ec 08             	sub    $0x8,%esp
  800b77:	53                   	push   %ebx
  800b78:	6a 30                	push   $0x30
  800b7a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b7c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b7f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b82:	e8 e1 fb ff ff       	call   800768 <getuint>
  800b87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b8a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b8d:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b90:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b95:	eb 46                	jmp    800bdd <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b97:	83 ec 08             	sub    $0x8,%esp
  800b9a:	53                   	push   %ebx
  800b9b:	6a 30                	push   $0x30
  800b9d:	ff d7                	call   *%edi
			putch('x', putdat);
  800b9f:	83 c4 08             	add    $0x8,%esp
  800ba2:	53                   	push   %ebx
  800ba3:	6a 78                	push   $0x78
  800ba5:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ba7:	8b 45 14             	mov    0x14(%ebp),%eax
  800baa:	8d 50 04             	lea    0x4(%eax),%edx
  800bad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bb0:	8b 00                	mov    (%eax),%eax
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bba:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bbd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bc0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bc5:	eb 16                	jmp    800bdd <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bc7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bca:	8d 45 14             	lea    0x14(%ebp),%eax
  800bcd:	e8 96 fb ff ff       	call   800768 <getuint>
  800bd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bd5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bd8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800be4:	56                   	push   %esi
  800be5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be8:	50                   	push   %eax
  800be9:	ff 75 dc             	pushl  -0x24(%ebp)
  800bec:	ff 75 d8             	pushl  -0x28(%ebp)
  800bef:	89 da                	mov    %ebx,%edx
  800bf1:	89 f8                	mov    %edi,%eax
  800bf3:	e8 55 f9 ff ff       	call   80054d <printnum>
			break;
  800bf8:	83 c4 20             	add    $0x20,%esp
  800bfb:	e9 f0 fb ff ff       	jmp    8007f0 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c00:	8b 45 14             	mov    0x14(%ebp),%eax
  800c03:	8d 50 04             	lea    0x4(%eax),%edx
  800c06:	89 55 14             	mov    %edx,0x14(%ebp)
  800c09:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c0b:	85 f6                	test   %esi,%esi
  800c0d:	75 1a                	jne    800c29 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c0f:	83 ec 08             	sub    $0x8,%esp
  800c12:	68 38 15 80 00       	push   $0x801538
  800c17:	68 a0 14 80 00       	push   $0x8014a0
  800c1c:	e8 18 f9 ff ff       	call   800539 <cprintf>
  800c21:	83 c4 10             	add    $0x10,%esp
  800c24:	e9 c7 fb ff ff       	jmp    8007f0 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c29:	0f b6 03             	movzbl (%ebx),%eax
  800c2c:	84 c0                	test   %al,%al
  800c2e:	79 1f                	jns    800c4f <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c30:	83 ec 08             	sub    $0x8,%esp
  800c33:	68 70 15 80 00       	push   $0x801570
  800c38:	68 a0 14 80 00       	push   $0x8014a0
  800c3d:	e8 f7 f8 ff ff       	call   800539 <cprintf>
						*tmp = *(char *)putdat;
  800c42:	0f b6 03             	movzbl (%ebx),%eax
  800c45:	88 06                	mov    %al,(%esi)
  800c47:	83 c4 10             	add    $0x10,%esp
  800c4a:	e9 a1 fb ff ff       	jmp    8007f0 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c4f:	88 06                	mov    %al,(%esi)
  800c51:	e9 9a fb ff ff       	jmp    8007f0 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	53                   	push   %ebx
  800c5a:	52                   	push   %edx
  800c5b:	ff d7                	call   *%edi
			break;
  800c5d:	83 c4 10             	add    $0x10,%esp
  800c60:	e9 8b fb ff ff       	jmp    8007f0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c65:	83 ec 08             	sub    $0x8,%esp
  800c68:	53                   	push   %ebx
  800c69:	6a 25                	push   $0x25
  800c6b:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c6d:	83 c4 10             	add    $0x10,%esp
  800c70:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c74:	0f 84 73 fb ff ff    	je     8007ed <vprintfmt+0x11>
  800c7a:	83 ee 01             	sub    $0x1,%esi
  800c7d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c81:	75 f7                	jne    800c7a <vprintfmt+0x49e>
  800c83:	89 75 10             	mov    %esi,0x10(%ebp)
  800c86:	e9 65 fb ff ff       	jmp    8007f0 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c8b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c8e:	8d 70 01             	lea    0x1(%eax),%esi
  800c91:	0f b6 00             	movzbl (%eax),%eax
  800c94:	0f be d0             	movsbl %al,%edx
  800c97:	85 d2                	test   %edx,%edx
  800c99:	0f 85 cf fd ff ff    	jne    800a6e <vprintfmt+0x292>
  800c9f:	e9 4c fb ff ff       	jmp    8007f0 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 18             	sub    $0x18,%esp
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cbb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cbf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	74 26                	je     800cf3 <vsnprintf+0x47>
  800ccd:	85 d2                	test   %edx,%edx
  800ccf:	7e 22                	jle    800cf3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cd1:	ff 75 14             	pushl  0x14(%ebp)
  800cd4:	ff 75 10             	pushl  0x10(%ebp)
  800cd7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cda:	50                   	push   %eax
  800cdb:	68 a2 07 80 00       	push   $0x8007a2
  800ce0:	e8 f7 fa ff ff       	call   8007dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ce5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cee:	83 c4 10             	add    $0x10,%esp
  800cf1:	eb 05                	jmp    800cf8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cf3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d00:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d03:	50                   	push   %eax
  800d04:	ff 75 10             	pushl  0x10(%ebp)
  800d07:	ff 75 0c             	pushl  0xc(%ebp)
  800d0a:	ff 75 08             	pushl  0x8(%ebp)
  800d0d:	e8 9a ff ff ff       	call   800cac <vsnprintf>
	va_end(ap);

	return rc;
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d1a:	80 3a 00             	cmpb   $0x0,(%edx)
  800d1d:	74 10                	je     800d2f <strlen+0x1b>
  800d1f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d24:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d27:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d2b:	75 f7                	jne    800d24 <strlen+0x10>
  800d2d:	eb 05                	jmp    800d34 <strlen+0x20>
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	53                   	push   %ebx
  800d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d40:	85 c9                	test   %ecx,%ecx
  800d42:	74 1c                	je     800d60 <strnlen+0x2a>
  800d44:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d47:	74 1e                	je     800d67 <strnlen+0x31>
  800d49:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d4e:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d50:	39 ca                	cmp    %ecx,%edx
  800d52:	74 18                	je     800d6c <strnlen+0x36>
  800d54:	83 c2 01             	add    $0x1,%edx
  800d57:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d5c:	75 f0                	jne    800d4e <strnlen+0x18>
  800d5e:	eb 0c                	jmp    800d6c <strnlen+0x36>
  800d60:	b8 00 00 00 00       	mov    $0x0,%eax
  800d65:	eb 05                	jmp    800d6c <strnlen+0x36>
  800d67:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	53                   	push   %ebx
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d79:	89 c2                	mov    %eax,%edx
  800d7b:	83 c2 01             	add    $0x1,%edx
  800d7e:	83 c1 01             	add    $0x1,%ecx
  800d81:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d85:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d88:	84 db                	test   %bl,%bl
  800d8a:	75 ef                	jne    800d7b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	53                   	push   %ebx
  800d93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d96:	53                   	push   %ebx
  800d97:	e8 78 ff ff ff       	call   800d14 <strlen>
  800d9c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d9f:	ff 75 0c             	pushl  0xc(%ebp)
  800da2:	01 d8                	add    %ebx,%eax
  800da4:	50                   	push   %eax
  800da5:	e8 c5 ff ff ff       	call   800d6f <strcpy>
	return dst;
}
  800daa:	89 d8                	mov    %ebx,%eax
  800dac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	8b 75 08             	mov    0x8(%ebp),%esi
  800db9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dbf:	85 db                	test   %ebx,%ebx
  800dc1:	74 17                	je     800dda <strncpy+0x29>
  800dc3:	01 f3                	add    %esi,%ebx
  800dc5:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dc7:	83 c1 01             	add    $0x1,%ecx
  800dca:	0f b6 02             	movzbl (%edx),%eax
  800dcd:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dd0:	80 3a 01             	cmpb   $0x1,(%edx)
  800dd3:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dd6:	39 cb                	cmp    %ecx,%ebx
  800dd8:	75 ed                	jne    800dc7 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dda:	89 f0                	mov    %esi,%eax
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	8b 75 08             	mov    0x8(%ebp),%esi
  800de8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800deb:	8b 55 10             	mov    0x10(%ebp),%edx
  800dee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800df0:	85 d2                	test   %edx,%edx
  800df2:	74 35                	je     800e29 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800df4:	89 d0                	mov    %edx,%eax
  800df6:	83 e8 01             	sub    $0x1,%eax
  800df9:	74 25                	je     800e20 <strlcpy+0x40>
  800dfb:	0f b6 0b             	movzbl (%ebx),%ecx
  800dfe:	84 c9                	test   %cl,%cl
  800e00:	74 22                	je     800e24 <strlcpy+0x44>
  800e02:	8d 53 01             	lea    0x1(%ebx),%edx
  800e05:	01 c3                	add    %eax,%ebx
  800e07:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e09:	83 c0 01             	add    $0x1,%eax
  800e0c:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e0f:	39 da                	cmp    %ebx,%edx
  800e11:	74 13                	je     800e26 <strlcpy+0x46>
  800e13:	83 c2 01             	add    $0x1,%edx
  800e16:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e1a:	84 c9                	test   %cl,%cl
  800e1c:	75 eb                	jne    800e09 <strlcpy+0x29>
  800e1e:	eb 06                	jmp    800e26 <strlcpy+0x46>
  800e20:	89 f0                	mov    %esi,%eax
  800e22:	eb 02                	jmp    800e26 <strlcpy+0x46>
  800e24:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e26:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e29:	29 f0                	sub    %esi,%eax
}
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e35:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e38:	0f b6 01             	movzbl (%ecx),%eax
  800e3b:	84 c0                	test   %al,%al
  800e3d:	74 15                	je     800e54 <strcmp+0x25>
  800e3f:	3a 02                	cmp    (%edx),%al
  800e41:	75 11                	jne    800e54 <strcmp+0x25>
		p++, q++;
  800e43:	83 c1 01             	add    $0x1,%ecx
  800e46:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e49:	0f b6 01             	movzbl (%ecx),%eax
  800e4c:	84 c0                	test   %al,%al
  800e4e:	74 04                	je     800e54 <strcmp+0x25>
  800e50:	3a 02                	cmp    (%edx),%al
  800e52:	74 ef                	je     800e43 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e54:	0f b6 c0             	movzbl %al,%eax
  800e57:	0f b6 12             	movzbl (%edx),%edx
  800e5a:	29 d0                	sub    %edx,%eax
}
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e69:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e6c:	85 f6                	test   %esi,%esi
  800e6e:	74 29                	je     800e99 <strncmp+0x3b>
  800e70:	0f b6 03             	movzbl (%ebx),%eax
  800e73:	84 c0                	test   %al,%al
  800e75:	74 30                	je     800ea7 <strncmp+0x49>
  800e77:	3a 02                	cmp    (%edx),%al
  800e79:	75 2c                	jne    800ea7 <strncmp+0x49>
  800e7b:	8d 43 01             	lea    0x1(%ebx),%eax
  800e7e:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e80:	89 c3                	mov    %eax,%ebx
  800e82:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e85:	39 c6                	cmp    %eax,%esi
  800e87:	74 17                	je     800ea0 <strncmp+0x42>
  800e89:	0f b6 08             	movzbl (%eax),%ecx
  800e8c:	84 c9                	test   %cl,%cl
  800e8e:	74 17                	je     800ea7 <strncmp+0x49>
  800e90:	83 c0 01             	add    $0x1,%eax
  800e93:	3a 0a                	cmp    (%edx),%cl
  800e95:	74 e9                	je     800e80 <strncmp+0x22>
  800e97:	eb 0e                	jmp    800ea7 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	eb 0f                	jmp    800eaf <strncmp+0x51>
  800ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea5:	eb 08                	jmp    800eaf <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ea7:	0f b6 03             	movzbl (%ebx),%eax
  800eaa:	0f b6 12             	movzbl (%edx),%edx
  800ead:	29 d0                	sub    %edx,%eax
}
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	53                   	push   %ebx
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ebd:	0f b6 10             	movzbl (%eax),%edx
  800ec0:	84 d2                	test   %dl,%dl
  800ec2:	74 1d                	je     800ee1 <strchr+0x2e>
  800ec4:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ec6:	38 d3                	cmp    %dl,%bl
  800ec8:	75 06                	jne    800ed0 <strchr+0x1d>
  800eca:	eb 1a                	jmp    800ee6 <strchr+0x33>
  800ecc:	38 ca                	cmp    %cl,%dl
  800ece:	74 16                	je     800ee6 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ed0:	83 c0 01             	add    $0x1,%eax
  800ed3:	0f b6 10             	movzbl (%eax),%edx
  800ed6:	84 d2                	test   %dl,%dl
  800ed8:	75 f2                	jne    800ecc <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
  800edf:	eb 05                	jmp    800ee6 <strchr+0x33>
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee6:	5b                   	pop    %ebx
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	53                   	push   %ebx
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ef3:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ef6:	38 d3                	cmp    %dl,%bl
  800ef8:	74 14                	je     800f0e <strfind+0x25>
  800efa:	89 d1                	mov    %edx,%ecx
  800efc:	84 db                	test   %bl,%bl
  800efe:	74 0e                	je     800f0e <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f00:	83 c0 01             	add    $0x1,%eax
  800f03:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f06:	38 ca                	cmp    %cl,%dl
  800f08:	74 04                	je     800f0e <strfind+0x25>
  800f0a:	84 d2                	test   %dl,%dl
  800f0c:	75 f2                	jne    800f00 <strfind+0x17>
			break;
	return (char *) s;
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	57                   	push   %edi
  800f15:	56                   	push   %esi
  800f16:	53                   	push   %ebx
  800f17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f1d:	85 c9                	test   %ecx,%ecx
  800f1f:	74 36                	je     800f57 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f27:	75 28                	jne    800f51 <memset+0x40>
  800f29:	f6 c1 03             	test   $0x3,%cl
  800f2c:	75 23                	jne    800f51 <memset+0x40>
		c &= 0xFF;
  800f2e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f32:	89 d3                	mov    %edx,%ebx
  800f34:	c1 e3 08             	shl    $0x8,%ebx
  800f37:	89 d6                	mov    %edx,%esi
  800f39:	c1 e6 18             	shl    $0x18,%esi
  800f3c:	89 d0                	mov    %edx,%eax
  800f3e:	c1 e0 10             	shl    $0x10,%eax
  800f41:	09 f0                	or     %esi,%eax
  800f43:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f45:	89 d8                	mov    %ebx,%eax
  800f47:	09 d0                	or     %edx,%eax
  800f49:	c1 e9 02             	shr    $0x2,%ecx
  800f4c:	fc                   	cld    
  800f4d:	f3 ab                	rep stos %eax,%es:(%edi)
  800f4f:	eb 06                	jmp    800f57 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f54:	fc                   	cld    
  800f55:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f57:	89 f8                	mov    %edi,%eax
  800f59:	5b                   	pop    %ebx
  800f5a:	5e                   	pop    %esi
  800f5b:	5f                   	pop    %edi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	8b 45 08             	mov    0x8(%ebp),%eax
  800f66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f6c:	39 c6                	cmp    %eax,%esi
  800f6e:	73 35                	jae    800fa5 <memmove+0x47>
  800f70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f73:	39 d0                	cmp    %edx,%eax
  800f75:	73 2e                	jae    800fa5 <memmove+0x47>
		s += n;
		d += n;
  800f77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f7a:	89 d6                	mov    %edx,%esi
  800f7c:	09 fe                	or     %edi,%esi
  800f7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f84:	75 13                	jne    800f99 <memmove+0x3b>
  800f86:	f6 c1 03             	test   $0x3,%cl
  800f89:	75 0e                	jne    800f99 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f8b:	83 ef 04             	sub    $0x4,%edi
  800f8e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f91:	c1 e9 02             	shr    $0x2,%ecx
  800f94:	fd                   	std    
  800f95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f97:	eb 09                	jmp    800fa2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f99:	83 ef 01             	sub    $0x1,%edi
  800f9c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f9f:	fd                   	std    
  800fa0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fa2:	fc                   	cld    
  800fa3:	eb 1d                	jmp    800fc2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa5:	89 f2                	mov    %esi,%edx
  800fa7:	09 c2                	or     %eax,%edx
  800fa9:	f6 c2 03             	test   $0x3,%dl
  800fac:	75 0f                	jne    800fbd <memmove+0x5f>
  800fae:	f6 c1 03             	test   $0x3,%cl
  800fb1:	75 0a                	jne    800fbd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fb3:	c1 e9 02             	shr    $0x2,%ecx
  800fb6:	89 c7                	mov    %eax,%edi
  800fb8:	fc                   	cld    
  800fb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fbb:	eb 05                	jmp    800fc2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fbd:	89 c7                	mov    %eax,%edi
  800fbf:	fc                   	cld    
  800fc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fc9:	ff 75 10             	pushl  0x10(%ebp)
  800fcc:	ff 75 0c             	pushl  0xc(%ebp)
  800fcf:	ff 75 08             	pushl  0x8(%ebp)
  800fd2:	e8 87 ff ff ff       	call   800f5e <memmove>
}
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    

00800fd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fe2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fe5:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	74 39                	je     801025 <memcmp+0x4c>
  800fec:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800fef:	0f b6 13             	movzbl (%ebx),%edx
  800ff2:	0f b6 0e             	movzbl (%esi),%ecx
  800ff5:	38 ca                	cmp    %cl,%dl
  800ff7:	75 17                	jne    801010 <memcmp+0x37>
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffe:	eb 1a                	jmp    80101a <memcmp+0x41>
  801000:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  801005:	83 c0 01             	add    $0x1,%eax
  801008:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  80100c:	38 ca                	cmp    %cl,%dl
  80100e:	74 0a                	je     80101a <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801010:	0f b6 c2             	movzbl %dl,%eax
  801013:	0f b6 c9             	movzbl %cl,%ecx
  801016:	29 c8                	sub    %ecx,%eax
  801018:	eb 10                	jmp    80102a <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80101a:	39 f8                	cmp    %edi,%eax
  80101c:	75 e2                	jne    801000 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80101e:	b8 00 00 00 00       	mov    $0x0,%eax
  801023:	eb 05                	jmp    80102a <memcmp+0x51>
  801025:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	53                   	push   %ebx
  801033:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801036:	89 d0                	mov    %edx,%eax
  801038:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80103b:	39 c2                	cmp    %eax,%edx
  80103d:	73 1d                	jae    80105c <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80103f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801043:	0f b6 0a             	movzbl (%edx),%ecx
  801046:	39 d9                	cmp    %ebx,%ecx
  801048:	75 09                	jne    801053 <memfind+0x24>
  80104a:	eb 14                	jmp    801060 <memfind+0x31>
  80104c:	0f b6 0a             	movzbl (%edx),%ecx
  80104f:	39 d9                	cmp    %ebx,%ecx
  801051:	74 11                	je     801064 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801053:	83 c2 01             	add    $0x1,%edx
  801056:	39 d0                	cmp    %edx,%eax
  801058:	75 f2                	jne    80104c <memfind+0x1d>
  80105a:	eb 0a                	jmp    801066 <memfind+0x37>
  80105c:	89 d0                	mov    %edx,%eax
  80105e:	eb 06                	jmp    801066 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801060:	89 d0                	mov    %edx,%eax
  801062:	eb 02                	jmp    801066 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801064:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801066:	5b                   	pop    %ebx
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	57                   	push   %edi
  80106d:	56                   	push   %esi
  80106e:	53                   	push   %ebx
  80106f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801072:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801075:	0f b6 01             	movzbl (%ecx),%eax
  801078:	3c 20                	cmp    $0x20,%al
  80107a:	74 04                	je     801080 <strtol+0x17>
  80107c:	3c 09                	cmp    $0x9,%al
  80107e:	75 0e                	jne    80108e <strtol+0x25>
		s++;
  801080:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801083:	0f b6 01             	movzbl (%ecx),%eax
  801086:	3c 20                	cmp    $0x20,%al
  801088:	74 f6                	je     801080 <strtol+0x17>
  80108a:	3c 09                	cmp    $0x9,%al
  80108c:	74 f2                	je     801080 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80108e:	3c 2b                	cmp    $0x2b,%al
  801090:	75 0a                	jne    80109c <strtol+0x33>
		s++;
  801092:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801095:	bf 00 00 00 00       	mov    $0x0,%edi
  80109a:	eb 11                	jmp    8010ad <strtol+0x44>
  80109c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010a1:	3c 2d                	cmp    $0x2d,%al
  8010a3:	75 08                	jne    8010ad <strtol+0x44>
		s++, neg = 1;
  8010a5:	83 c1 01             	add    $0x1,%ecx
  8010a8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010b3:	75 15                	jne    8010ca <strtol+0x61>
  8010b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8010b8:	75 10                	jne    8010ca <strtol+0x61>
  8010ba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010be:	75 7c                	jne    80113c <strtol+0xd3>
		s += 2, base = 16;
  8010c0:	83 c1 02             	add    $0x2,%ecx
  8010c3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010c8:	eb 16                	jmp    8010e0 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010ca:	85 db                	test   %ebx,%ebx
  8010cc:	75 12                	jne    8010e0 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010ce:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010d3:	80 39 30             	cmpb   $0x30,(%ecx)
  8010d6:	75 08                	jne    8010e0 <strtol+0x77>
		s++, base = 8;
  8010d8:	83 c1 01             	add    $0x1,%ecx
  8010db:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010e8:	0f b6 11             	movzbl (%ecx),%edx
  8010eb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010ee:	89 f3                	mov    %esi,%ebx
  8010f0:	80 fb 09             	cmp    $0x9,%bl
  8010f3:	77 08                	ja     8010fd <strtol+0x94>
			dig = *s - '0';
  8010f5:	0f be d2             	movsbl %dl,%edx
  8010f8:	83 ea 30             	sub    $0x30,%edx
  8010fb:	eb 22                	jmp    80111f <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8010fd:	8d 72 9f             	lea    -0x61(%edx),%esi
  801100:	89 f3                	mov    %esi,%ebx
  801102:	80 fb 19             	cmp    $0x19,%bl
  801105:	77 08                	ja     80110f <strtol+0xa6>
			dig = *s - 'a' + 10;
  801107:	0f be d2             	movsbl %dl,%edx
  80110a:	83 ea 57             	sub    $0x57,%edx
  80110d:	eb 10                	jmp    80111f <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  80110f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801112:	89 f3                	mov    %esi,%ebx
  801114:	80 fb 19             	cmp    $0x19,%bl
  801117:	77 16                	ja     80112f <strtol+0xc6>
			dig = *s - 'A' + 10;
  801119:	0f be d2             	movsbl %dl,%edx
  80111c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80111f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801122:	7d 0b                	jge    80112f <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801124:	83 c1 01             	add    $0x1,%ecx
  801127:	0f af 45 10          	imul   0x10(%ebp),%eax
  80112b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80112d:	eb b9                	jmp    8010e8 <strtol+0x7f>

	if (endptr)
  80112f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801133:	74 0d                	je     801142 <strtol+0xd9>
		*endptr = (char *) s;
  801135:	8b 75 0c             	mov    0xc(%ebp),%esi
  801138:	89 0e                	mov    %ecx,(%esi)
  80113a:	eb 06                	jmp    801142 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80113c:	85 db                	test   %ebx,%ebx
  80113e:	74 98                	je     8010d8 <strtol+0x6f>
  801140:	eb 9e                	jmp    8010e0 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801142:	89 c2                	mov    %eax,%edx
  801144:	f7 da                	neg    %edx
  801146:	85 ff                	test   %edi,%edi
  801148:	0f 45 c2             	cmovne %edx,%eax
}
  80114b:	5b                   	pop    %ebx
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801156:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  80115d:	75 14                	jne    801173 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  80115f:	83 ec 04             	sub    $0x4,%esp
  801162:	68 44 17 80 00       	push   $0x801744
  801167:	6a 20                	push   $0x20
  801169:	68 68 17 80 00       	push   $0x801768
  80116e:	e8 d3 f2 ff ff       	call   800446 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	a3 14 20 80 00       	mov    %eax,0x802014
}
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    
  80117d:	66 90                	xchg   %ax,%ax
  80117f:	90                   	nop

00801180 <__udivdi3>:
  801180:	55                   	push   %ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 1c             	sub    $0x1c,%esp
  801187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80118b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80118f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801197:	85 f6                	test   %esi,%esi
  801199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80119d:	89 ca                	mov    %ecx,%edx
  80119f:	89 f8                	mov    %edi,%eax
  8011a1:	75 3d                	jne    8011e0 <__udivdi3+0x60>
  8011a3:	39 cf                	cmp    %ecx,%edi
  8011a5:	0f 87 c5 00 00 00    	ja     801270 <__udivdi3+0xf0>
  8011ab:	85 ff                	test   %edi,%edi
  8011ad:	89 fd                	mov    %edi,%ebp
  8011af:	75 0b                	jne    8011bc <__udivdi3+0x3c>
  8011b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b6:	31 d2                	xor    %edx,%edx
  8011b8:	f7 f7                	div    %edi
  8011ba:	89 c5                	mov    %eax,%ebp
  8011bc:	89 c8                	mov    %ecx,%eax
  8011be:	31 d2                	xor    %edx,%edx
  8011c0:	f7 f5                	div    %ebp
  8011c2:	89 c1                	mov    %eax,%ecx
  8011c4:	89 d8                	mov    %ebx,%eax
  8011c6:	89 cf                	mov    %ecx,%edi
  8011c8:	f7 f5                	div    %ebp
  8011ca:	89 c3                	mov    %eax,%ebx
  8011cc:	89 d8                	mov    %ebx,%eax
  8011ce:	89 fa                	mov    %edi,%edx
  8011d0:	83 c4 1c             	add    $0x1c,%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    
  8011d8:	90                   	nop
  8011d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	39 ce                	cmp    %ecx,%esi
  8011e2:	77 74                	ja     801258 <__udivdi3+0xd8>
  8011e4:	0f bd fe             	bsr    %esi,%edi
  8011e7:	83 f7 1f             	xor    $0x1f,%edi
  8011ea:	0f 84 98 00 00 00    	je     801288 <__udivdi3+0x108>
  8011f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011f5:	89 f9                	mov    %edi,%ecx
  8011f7:	89 c5                	mov    %eax,%ebp
  8011f9:	29 fb                	sub    %edi,%ebx
  8011fb:	d3 e6                	shl    %cl,%esi
  8011fd:	89 d9                	mov    %ebx,%ecx
  8011ff:	d3 ed                	shr    %cl,%ebp
  801201:	89 f9                	mov    %edi,%ecx
  801203:	d3 e0                	shl    %cl,%eax
  801205:	09 ee                	or     %ebp,%esi
  801207:	89 d9                	mov    %ebx,%ecx
  801209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80120d:	89 d5                	mov    %edx,%ebp
  80120f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801213:	d3 ed                	shr    %cl,%ebp
  801215:	89 f9                	mov    %edi,%ecx
  801217:	d3 e2                	shl    %cl,%edx
  801219:	89 d9                	mov    %ebx,%ecx
  80121b:	d3 e8                	shr    %cl,%eax
  80121d:	09 c2                	or     %eax,%edx
  80121f:	89 d0                	mov    %edx,%eax
  801221:	89 ea                	mov    %ebp,%edx
  801223:	f7 f6                	div    %esi
  801225:	89 d5                	mov    %edx,%ebp
  801227:	89 c3                	mov    %eax,%ebx
  801229:	f7 64 24 0c          	mull   0xc(%esp)
  80122d:	39 d5                	cmp    %edx,%ebp
  80122f:	72 10                	jb     801241 <__udivdi3+0xc1>
  801231:	8b 74 24 08          	mov    0x8(%esp),%esi
  801235:	89 f9                	mov    %edi,%ecx
  801237:	d3 e6                	shl    %cl,%esi
  801239:	39 c6                	cmp    %eax,%esi
  80123b:	73 07                	jae    801244 <__udivdi3+0xc4>
  80123d:	39 d5                	cmp    %edx,%ebp
  80123f:	75 03                	jne    801244 <__udivdi3+0xc4>
  801241:	83 eb 01             	sub    $0x1,%ebx
  801244:	31 ff                	xor    %edi,%edi
  801246:	89 d8                	mov    %ebx,%eax
  801248:	89 fa                	mov    %edi,%edx
  80124a:	83 c4 1c             	add    $0x1c,%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    
  801252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801258:	31 ff                	xor    %edi,%edi
  80125a:	31 db                	xor    %ebx,%ebx
  80125c:	89 d8                	mov    %ebx,%eax
  80125e:	89 fa                	mov    %edi,%edx
  801260:	83 c4 1c             	add    $0x1c,%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    
  801268:	90                   	nop
  801269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 d8                	mov    %ebx,%eax
  801272:	f7 f7                	div    %edi
  801274:	31 ff                	xor    %edi,%edi
  801276:	89 c3                	mov    %eax,%ebx
  801278:	89 d8                	mov    %ebx,%eax
  80127a:	89 fa                	mov    %edi,%edx
  80127c:	83 c4 1c             	add    $0x1c,%esp
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5f                   	pop    %edi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	39 ce                	cmp    %ecx,%esi
  80128a:	72 0c                	jb     801298 <__udivdi3+0x118>
  80128c:	31 db                	xor    %ebx,%ebx
  80128e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801292:	0f 87 34 ff ff ff    	ja     8011cc <__udivdi3+0x4c>
  801298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80129d:	e9 2a ff ff ff       	jmp    8011cc <__udivdi3+0x4c>
  8012a2:	66 90                	xchg   %ax,%ax
  8012a4:	66 90                	xchg   %ax,%ax
  8012a6:	66 90                	xchg   %ax,%ax
  8012a8:	66 90                	xchg   %ax,%ax
  8012aa:	66 90                	xchg   %ax,%ax
  8012ac:	66 90                	xchg   %ax,%ax
  8012ae:	66 90                	xchg   %ax,%ax

008012b0 <__umoddi3>:
  8012b0:	55                   	push   %ebp
  8012b1:	57                   	push   %edi
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 1c             	sub    $0x1c,%esp
  8012b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012c7:	85 d2                	test   %edx,%edx
  8012c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d1:	89 f3                	mov    %esi,%ebx
  8012d3:	89 3c 24             	mov    %edi,(%esp)
  8012d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012da:	75 1c                	jne    8012f8 <__umoddi3+0x48>
  8012dc:	39 f7                	cmp    %esi,%edi
  8012de:	76 50                	jbe    801330 <__umoddi3+0x80>
  8012e0:	89 c8                	mov    %ecx,%eax
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	f7 f7                	div    %edi
  8012e6:	89 d0                	mov    %edx,%eax
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	83 c4 1c             	add    $0x1c,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    
  8012f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f8:	39 f2                	cmp    %esi,%edx
  8012fa:	89 d0                	mov    %edx,%eax
  8012fc:	77 52                	ja     801350 <__umoddi3+0xa0>
  8012fe:	0f bd ea             	bsr    %edx,%ebp
  801301:	83 f5 1f             	xor    $0x1f,%ebp
  801304:	75 5a                	jne    801360 <__umoddi3+0xb0>
  801306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80130a:	0f 82 e0 00 00 00    	jb     8013f0 <__umoddi3+0x140>
  801310:	39 0c 24             	cmp    %ecx,(%esp)
  801313:	0f 86 d7 00 00 00    	jbe    8013f0 <__umoddi3+0x140>
  801319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80131d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801321:	83 c4 1c             	add    $0x1c,%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5f                   	pop    %edi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    
  801329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801330:	85 ff                	test   %edi,%edi
  801332:	89 fd                	mov    %edi,%ebp
  801334:	75 0b                	jne    801341 <__umoddi3+0x91>
  801336:	b8 01 00 00 00       	mov    $0x1,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	f7 f7                	div    %edi
  80133f:	89 c5                	mov    %eax,%ebp
  801341:	89 f0                	mov    %esi,%eax
  801343:	31 d2                	xor    %edx,%edx
  801345:	f7 f5                	div    %ebp
  801347:	89 c8                	mov    %ecx,%eax
  801349:	f7 f5                	div    %ebp
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	eb 99                	jmp    8012e8 <__umoddi3+0x38>
  80134f:	90                   	nop
  801350:	89 c8                	mov    %ecx,%eax
  801352:	89 f2                	mov    %esi,%edx
  801354:	83 c4 1c             	add    $0x1c,%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    
  80135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801360:	8b 34 24             	mov    (%esp),%esi
  801363:	bf 20 00 00 00       	mov    $0x20,%edi
  801368:	89 e9                	mov    %ebp,%ecx
  80136a:	29 ef                	sub    %ebp,%edi
  80136c:	d3 e0                	shl    %cl,%eax
  80136e:	89 f9                	mov    %edi,%ecx
  801370:	89 f2                	mov    %esi,%edx
  801372:	d3 ea                	shr    %cl,%edx
  801374:	89 e9                	mov    %ebp,%ecx
  801376:	09 c2                	or     %eax,%edx
  801378:	89 d8                	mov    %ebx,%eax
  80137a:	89 14 24             	mov    %edx,(%esp)
  80137d:	89 f2                	mov    %esi,%edx
  80137f:	d3 e2                	shl    %cl,%edx
  801381:	89 f9                	mov    %edi,%ecx
  801383:	89 54 24 04          	mov    %edx,0x4(%esp)
  801387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80138b:	d3 e8                	shr    %cl,%eax
  80138d:	89 e9                	mov    %ebp,%ecx
  80138f:	89 c6                	mov    %eax,%esi
  801391:	d3 e3                	shl    %cl,%ebx
  801393:	89 f9                	mov    %edi,%ecx
  801395:	89 d0                	mov    %edx,%eax
  801397:	d3 e8                	shr    %cl,%eax
  801399:	89 e9                	mov    %ebp,%ecx
  80139b:	09 d8                	or     %ebx,%eax
  80139d:	89 d3                	mov    %edx,%ebx
  80139f:	89 f2                	mov    %esi,%edx
  8013a1:	f7 34 24             	divl   (%esp)
  8013a4:	89 d6                	mov    %edx,%esi
  8013a6:	d3 e3                	shl    %cl,%ebx
  8013a8:	f7 64 24 04          	mull   0x4(%esp)
  8013ac:	39 d6                	cmp    %edx,%esi
  8013ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b2:	89 d1                	mov    %edx,%ecx
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	72 08                	jb     8013c0 <__umoddi3+0x110>
  8013b8:	75 11                	jne    8013cb <__umoddi3+0x11b>
  8013ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013be:	73 0b                	jae    8013cb <__umoddi3+0x11b>
  8013c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013c4:	1b 14 24             	sbb    (%esp),%edx
  8013c7:	89 d1                	mov    %edx,%ecx
  8013c9:	89 c3                	mov    %eax,%ebx
  8013cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013cf:	29 da                	sub    %ebx,%edx
  8013d1:	19 ce                	sbb    %ecx,%esi
  8013d3:	89 f9                	mov    %edi,%ecx
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	d3 e0                	shl    %cl,%eax
  8013d9:	89 e9                	mov    %ebp,%ecx
  8013db:	d3 ea                	shr    %cl,%edx
  8013dd:	89 e9                	mov    %ebp,%ecx
  8013df:	d3 ee                	shr    %cl,%esi
  8013e1:	09 d0                	or     %edx,%eax
  8013e3:	89 f2                	mov    %esi,%edx
  8013e5:	83 c4 1c             	add    $0x1c,%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    
  8013ed:	8d 76 00             	lea    0x0(%esi),%esi
  8013f0:	29 f9                	sub    %edi,%ecx
  8013f2:	19 d6                	sbb    %edx,%esi
  8013f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013fc:	e9 18 ff ff ff       	jmp    801319 <__umoddi3+0x69>