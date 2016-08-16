
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
  800063:	c1 e0 07             	shl    $0x7,%eax
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
  80013f:	68 f8 13 80 00       	push   $0x8013f8
  800144:	6a 2a                	push   $0x2a
  800146:	68 15 14 80 00       	push   $0x801415
  80014b:	e8 e5 02 00 00       	call   800435 <_panic>

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

008001bb <sys_yield>:

void
sys_yield(void)
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
  8001c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ca:	89 d1                	mov    %edx,%ecx
  8001cc:	89 d3                	mov    %edx,%ebx
  8001ce:	89 d7                	mov    %edx,%edi
  8001d0:	51                   	push   %ecx
  8001d1:	52                   	push   %edx
  8001d2:	53                   	push   %ebx
  8001d3:	54                   	push   %esp
  8001d4:	55                   	push   %ebp
  8001d5:	56                   	push   %esi
  8001d6:	57                   	push   %edi
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	8d 35 e1 01 80 00    	lea    0x8001e1,%esi
  8001df:	0f 34                	sysenter 

008001e1 <label_209>:
  8001e1:	5f                   	pop    %edi
  8001e2:	5e                   	pop    %esi
  8001e3:	5d                   	pop    %ebp
  8001e4:	5c                   	pop    %esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5a                   	pop    %edx
  8001e7:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001e8:	5b                   	pop    %ebx
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800204:	51                   	push   %ecx
  800205:	52                   	push   %edx
  800206:	53                   	push   %ebx
  800207:	54                   	push   %esp
  800208:	55                   	push   %ebp
  800209:	56                   	push   %esi
  80020a:	57                   	push   %edi
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	8d 35 15 02 80 00    	lea    0x800215,%esi
  800213:	0f 34                	sysenter 

00800215 <label_244>:
  800215:	5f                   	pop    %edi
  800216:	5e                   	pop    %esi
  800217:	5d                   	pop    %ebp
  800218:	5c                   	pop    %esp
  800219:	5b                   	pop    %ebx
  80021a:	5a                   	pop    %edx
  80021b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80021c:	85 c0                	test   %eax,%eax
  80021e:	7e 17                	jle    800237 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	50                   	push   %eax
  800224:	6a 05                	push   $0x5
  800226:	68 f8 13 80 00       	push   $0x8013f8
  80022b:	6a 2a                	push   $0x2a
  80022d:	68 15 14 80 00       	push   $0x801415
  800232:	e8 fe 01 00 00       	call   800435 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800237:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5f                   	pop    %edi
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	57                   	push   %edi
  800242:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800243:	b8 06 00 00 00       	mov    $0x6,%eax
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	8b 55 08             	mov    0x8(%ebp),%edx
  80024e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800251:	8b 7d 14             	mov    0x14(%ebp),%edi
  800254:	51                   	push   %ecx
  800255:	52                   	push   %edx
  800256:	53                   	push   %ebx
  800257:	54                   	push   %esp
  800258:	55                   	push   %ebp
  800259:	56                   	push   %esi
  80025a:	57                   	push   %edi
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	8d 35 65 02 80 00    	lea    0x800265,%esi
  800263:	0f 34                	sysenter 

00800265 <label_295>:
  800265:	5f                   	pop    %edi
  800266:	5e                   	pop    %esi
  800267:	5d                   	pop    %ebp
  800268:	5c                   	pop    %esp
  800269:	5b                   	pop    %ebx
  80026a:	5a                   	pop    %edx
  80026b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80026c:	85 c0                	test   %eax,%eax
  80026e:	7e 17                	jle    800287 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	50                   	push   %eax
  800274:	6a 06                	push   $0x6
  800276:	68 f8 13 80 00       	push   $0x8013f8
  80027b:	6a 2a                	push   $0x2a
  80027d:	68 15 14 80 00       	push   $0x801415
  800282:	e8 ae 01 00 00       	call   800435 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800287:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	57                   	push   %edi
  800292:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800293:	bf 00 00 00 00       	mov    $0x0,%edi
  800298:	b8 07 00 00 00       	mov    $0x7,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 fb                	mov    %edi,%ebx
  8002a5:	51                   	push   %ecx
  8002a6:	52                   	push   %edx
  8002a7:	53                   	push   %ebx
  8002a8:	54                   	push   %esp
  8002a9:	55                   	push   %ebp
  8002aa:	56                   	push   %esi
  8002ab:	57                   	push   %edi
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	8d 35 b6 02 80 00    	lea    0x8002b6,%esi
  8002b4:	0f 34                	sysenter 

008002b6 <label_344>:
  8002b6:	5f                   	pop    %edi
  8002b7:	5e                   	pop    %esi
  8002b8:	5d                   	pop    %ebp
  8002b9:	5c                   	pop    %esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5a                   	pop    %edx
  8002bc:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002bd:	85 c0                	test   %eax,%eax
  8002bf:	7e 17                	jle    8002d8 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002c1:	83 ec 0c             	sub    $0xc,%esp
  8002c4:	50                   	push   %eax
  8002c5:	6a 07                	push   $0x7
  8002c7:	68 f8 13 80 00       	push   $0x8013f8
  8002cc:	6a 2a                	push   $0x2a
  8002ce:	68 15 14 80 00       	push   $0x801415
  8002d3:	e8 5d 01 00 00       	call   800435 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002e9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f4:	89 fb                	mov    %edi,%ebx
  8002f6:	51                   	push   %ecx
  8002f7:	52                   	push   %edx
  8002f8:	53                   	push   %ebx
  8002f9:	54                   	push   %esp
  8002fa:	55                   	push   %ebp
  8002fb:	56                   	push   %esi
  8002fc:	57                   	push   %edi
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	8d 35 07 03 80 00    	lea    0x800307,%esi
  800305:	0f 34                	sysenter 

00800307 <label_393>:
  800307:	5f                   	pop    %edi
  800308:	5e                   	pop    %esi
  800309:	5d                   	pop    %ebp
  80030a:	5c                   	pop    %esp
  80030b:	5b                   	pop    %ebx
  80030c:	5a                   	pop    %edx
  80030d:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80030e:	85 c0                	test   %eax,%eax
  800310:	7e 17                	jle    800329 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	50                   	push   %eax
  800316:	6a 09                	push   $0x9
  800318:	68 f8 13 80 00       	push   $0x8013f8
  80031d:	6a 2a                	push   $0x2a
  80031f:	68 15 14 80 00       	push   $0x801415
  800324:	e8 0c 01 00 00       	call   800435 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800329:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800335:	bf 00 00 00 00       	mov    $0x0,%edi
  80033a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80033f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800342:	8b 55 08             	mov    0x8(%ebp),%edx
  800345:	89 fb                	mov    %edi,%ebx
  800347:	51                   	push   %ecx
  800348:	52                   	push   %edx
  800349:	53                   	push   %ebx
  80034a:	54                   	push   %esp
  80034b:	55                   	push   %ebp
  80034c:	56                   	push   %esi
  80034d:	57                   	push   %edi
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	8d 35 58 03 80 00    	lea    0x800358,%esi
  800356:	0f 34                	sysenter 

00800358 <label_442>:
  800358:	5f                   	pop    %edi
  800359:	5e                   	pop    %esi
  80035a:	5d                   	pop    %ebp
  80035b:	5c                   	pop    %esp
  80035c:	5b                   	pop    %ebx
  80035d:	5a                   	pop    %edx
  80035e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80035f:	85 c0                	test   %eax,%eax
  800361:	7e 17                	jle    80037a <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800363:	83 ec 0c             	sub    $0xc,%esp
  800366:	50                   	push   %eax
  800367:	6a 0a                	push   $0xa
  800369:	68 f8 13 80 00       	push   $0x8013f8
  80036e:	6a 2a                	push   $0x2a
  800370:	68 15 14 80 00       	push   $0x801415
  800375:	e8 bb 00 00 00       	call   800435 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80037a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80037d:	5b                   	pop    %ebx
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	57                   	push   %edi
  800385:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800386:	b8 0c 00 00 00       	mov    $0xc,%eax
  80038b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038e:	8b 55 08             	mov    0x8(%ebp),%edx
  800391:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800394:	8b 7d 14             	mov    0x14(%ebp),%edi
  800397:	51                   	push   %ecx
  800398:	52                   	push   %edx
  800399:	53                   	push   %ebx
  80039a:	54                   	push   %esp
  80039b:	55                   	push   %ebp
  80039c:	56                   	push   %esi
  80039d:	57                   	push   %edi
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	8d 35 a8 03 80 00    	lea    0x8003a8,%esi
  8003a6:	0f 34                	sysenter 

008003a8 <label_493>:
  8003a8:	5f                   	pop    %edi
  8003a9:	5e                   	pop    %esi
  8003aa:	5d                   	pop    %ebp
  8003ab:	5c                   	pop    %esp
  8003ac:	5b                   	pop    %ebx
  8003ad:	5a                   	pop    %edx
  8003ae:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003af:	5b                   	pop    %ebx
  8003b0:	5f                   	pop    %edi
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	57                   	push   %edi
  8003b7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 d9                	mov    %ebx,%ecx
  8003c7:	89 df                	mov    %ebx,%edi
  8003c9:	51                   	push   %ecx
  8003ca:	52                   	push   %edx
  8003cb:	53                   	push   %ebx
  8003cc:	54                   	push   %esp
  8003cd:	55                   	push   %ebp
  8003ce:	56                   	push   %esi
  8003cf:	57                   	push   %edi
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	8d 35 da 03 80 00    	lea    0x8003da,%esi
  8003d8:	0f 34                	sysenter 

008003da <label_528>:
  8003da:	5f                   	pop    %edi
  8003db:	5e                   	pop    %esi
  8003dc:	5d                   	pop    %ebp
  8003dd:	5c                   	pop    %esp
  8003de:	5b                   	pop    %ebx
  8003df:	5a                   	pop    %edx
  8003e0:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	7e 17                	jle    8003fc <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8003e5:	83 ec 0c             	sub    $0xc,%esp
  8003e8:	50                   	push   %eax
  8003e9:	6a 0d                	push   $0xd
  8003eb:	68 f8 13 80 00       	push   $0x8013f8
  8003f0:	6a 2a                	push   $0x2a
  8003f2:	68 15 14 80 00       	push   $0x801415
  8003f7:	e8 39 00 00 00       	call   800435 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003ff:	5b                   	pop    %ebx
  800400:	5f                   	pop    %edi
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	57                   	push   %edi
  800407:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800408:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800412:	8b 55 08             	mov    0x8(%ebp),%edx
  800415:	89 cb                	mov    %ecx,%ebx
  800417:	89 cf                	mov    %ecx,%edi
  800419:	51                   	push   %ecx
  80041a:	52                   	push   %edx
  80041b:	53                   	push   %ebx
  80041c:	54                   	push   %esp
  80041d:	55                   	push   %ebp
  80041e:	56                   	push   %esi
  80041f:	57                   	push   %edi
  800420:	89 e5                	mov    %esp,%ebp
  800422:	8d 35 2a 04 80 00    	lea    0x80042a,%esi
  800428:	0f 34                	sysenter 

0080042a <label_577>:
  80042a:	5f                   	pop    %edi
  80042b:	5e                   	pop    %esi
  80042c:	5d                   	pop    %ebp
  80042d:	5c                   	pop    %esp
  80042e:	5b                   	pop    %ebx
  80042f:	5a                   	pop    %edx
  800430:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800431:	5b                   	pop    %ebx
  800432:	5f                   	pop    %edi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    

00800435 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80043a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80043d:	a1 14 20 80 00       	mov    0x802014,%eax
  800442:	85 c0                	test   %eax,%eax
  800444:	74 11                	je     800457 <_panic+0x22>
		cprintf("%s: ", argv0);
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	50                   	push   %eax
  80044a:	68 23 14 80 00       	push   $0x801423
  80044f:	e8 d4 00 00 00       	call   800528 <cprintf>
  800454:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800457:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80045d:	e8 f5 fc ff ff       	call   800157 <sys_getenvid>
  800462:	83 ec 0c             	sub    $0xc,%esp
  800465:	ff 75 0c             	pushl  0xc(%ebp)
  800468:	ff 75 08             	pushl  0x8(%ebp)
  80046b:	56                   	push   %esi
  80046c:	50                   	push   %eax
  80046d:	68 28 14 80 00       	push   $0x801428
  800472:	e8 b1 00 00 00       	call   800528 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800477:	83 c4 18             	add    $0x18,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 75 10             	pushl  0x10(%ebp)
  80047e:	e8 54 00 00 00       	call   8004d7 <vcprintf>
	cprintf("\n");
  800483:	c7 04 24 ec 13 80 00 	movl   $0x8013ec,(%esp)
  80048a:	e8 99 00 00 00       	call   800528 <cprintf>
  80048f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800492:	cc                   	int3   
  800493:	eb fd                	jmp    800492 <_panic+0x5d>

00800495 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	53                   	push   %ebx
  800499:	83 ec 04             	sub    $0x4,%esp
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049f:	8b 13                	mov    (%ebx),%edx
  8004a1:	8d 42 01             	lea    0x1(%edx),%eax
  8004a4:	89 03                	mov    %eax,(%ebx)
  8004a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b2:	75 1a                	jne    8004ce <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	68 ff 00 00 00       	push   $0xff
  8004bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 e1 fb ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8004c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004cb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    

008004d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e7:	00 00 00 
	b.cnt = 0;
  8004ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	ff 75 08             	pushl  0x8(%ebp)
  8004fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	68 95 04 80 00       	push   $0x800495
  800506:	e8 c0 02 00 00       	call   8007cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80050b:	83 c4 08             	add    $0x8,%esp
  80050e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800514:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80051a:	50                   	push   %eax
  80051b:	e8 86 fb ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  800520:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800526:	c9                   	leave  
  800527:	c3                   	ret    

00800528 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80052e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800531:	50                   	push   %eax
  800532:	ff 75 08             	pushl  0x8(%ebp)
  800535:	e8 9d ff ff ff       	call   8004d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    

0080053c <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
  800542:	83 ec 1c             	sub    $0x1c,%esp
  800545:	89 c7                	mov    %eax,%edi
  800547:	89 d6                	mov    %edx,%esi
  800549:	8b 45 08             	mov    0x8(%ebp),%eax
  80054c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800552:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800555:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800558:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80055c:	0f 85 bf 00 00 00    	jne    800621 <printnum+0xe5>
  800562:	39 1d 0c 20 80 00    	cmp    %ebx,0x80200c
  800568:	0f 8d de 00 00 00    	jge    80064c <printnum+0x110>
		judge_time_for_space = width;
  80056e:	89 1d 0c 20 80 00    	mov    %ebx,0x80200c
  800574:	e9 d3 00 00 00       	jmp    80064c <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800579:	83 eb 01             	sub    $0x1,%ebx
  80057c:	85 db                	test   %ebx,%ebx
  80057e:	7f 37                	jg     8005b7 <printnum+0x7b>
  800580:	e9 ea 00 00 00       	jmp    80066f <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800585:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800588:	a3 08 20 80 00       	mov    %eax,0x802008
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	56                   	push   %esi
  800591:	83 ec 04             	sub    $0x4,%esp
  800594:	ff 75 dc             	pushl  -0x24(%ebp)
  800597:	ff 75 d8             	pushl  -0x28(%ebp)
  80059a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059d:	ff 75 e0             	pushl  -0x20(%ebp)
  8005a0:	e8 cb 0c 00 00       	call   801270 <__umoddi3>
  8005a5:	83 c4 14             	add    $0x14,%esp
  8005a8:	0f be 80 4b 14 80 00 	movsbl 0x80144b(%eax),%eax
  8005af:	50                   	push   %eax
  8005b0:	ff d7                	call   *%edi
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	eb 16                	jmp    8005cd <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	56                   	push   %esi
  8005bb:	ff 75 18             	pushl  0x18(%ebp)
  8005be:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	83 eb 01             	sub    $0x1,%ebx
  8005c6:	75 ef                	jne    8005b7 <printnum+0x7b>
  8005c8:	e9 a2 00 00 00       	jmp    80066f <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005cd:	3b 1d 0c 20 80 00    	cmp    0x80200c,%ebx
  8005d3:	0f 85 76 01 00 00    	jne    80074f <printnum+0x213>
		while(num_of_space-- > 0)
  8005d9:	a1 08 20 80 00       	mov    0x802008,%eax
  8005de:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005e1:	89 15 08 20 80 00    	mov    %edx,0x802008
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	7e 1d                	jle    800608 <printnum+0xcc>
			putch(' ', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	56                   	push   %esi
  8005ef:	6a 20                	push   $0x20
  8005f1:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8005f3:	a1 08 20 80 00       	mov    0x802008,%eax
  8005f8:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005fb:	89 15 08 20 80 00    	mov    %edx,0x802008
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	85 c0                	test   %eax,%eax
  800606:	7f e3                	jg     8005eb <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800608:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80060f:	00 00 00 
		judge_time_for_space = 0;
  800612:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  800619:	00 00 00 
	}
}
  80061c:	e9 2e 01 00 00       	jmp    80074f <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800621:	8b 45 10             	mov    0x10(%ebp),%eax
  800624:	ba 00 00 00 00       	mov    $0x0,%edx
  800629:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800632:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800635:	83 fa 00             	cmp    $0x0,%edx
  800638:	0f 87 ba 00 00 00    	ja     8006f8 <printnum+0x1bc>
  80063e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800641:	0f 83 b1 00 00 00    	jae    8006f8 <printnum+0x1bc>
  800647:	e9 2d ff ff ff       	jmp    800579 <printnum+0x3d>
  80064c:	8b 45 10             	mov    0x10(%ebp),%eax
  80064f:	ba 00 00 00 00       	mov    $0x0,%edx
  800654:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800657:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80065d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800660:	83 fa 00             	cmp    $0x0,%edx
  800663:	77 37                	ja     80069c <printnum+0x160>
  800665:	3b 45 10             	cmp    0x10(%ebp),%eax
  800668:	73 32                	jae    80069c <printnum+0x160>
  80066a:	e9 16 ff ff ff       	jmp    800585 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	56                   	push   %esi
  800673:	83 ec 04             	sub    $0x4,%esp
  800676:	ff 75 dc             	pushl  -0x24(%ebp)
  800679:	ff 75 d8             	pushl  -0x28(%ebp)
  80067c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80067f:	ff 75 e0             	pushl  -0x20(%ebp)
  800682:	e8 e9 0b 00 00       	call   801270 <__umoddi3>
  800687:	83 c4 14             	add    $0x14,%esp
  80068a:	0f be 80 4b 14 80 00 	movsbl 0x80144b(%eax),%eax
  800691:	50                   	push   %eax
  800692:	ff d7                	call   *%edi
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	e9 b3 00 00 00       	jmp    80074f <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	ff 75 18             	pushl  0x18(%ebp)
  8006a2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006a5:	50                   	push   %eax
  8006a6:	ff 75 10             	pushl  0x10(%ebp)
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8006af:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b8:	e8 83 0a 00 00       	call   801140 <__udivdi3>
  8006bd:	83 c4 18             	add    $0x18,%esp
  8006c0:	52                   	push   %edx
  8006c1:	50                   	push   %eax
  8006c2:	89 f2                	mov    %esi,%edx
  8006c4:	89 f8                	mov    %edi,%eax
  8006c6:	e8 71 fe ff ff       	call   80053c <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006cb:	83 c4 18             	add    $0x18,%esp
  8006ce:	56                   	push   %esi
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8006d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006db:	ff 75 e0             	pushl  -0x20(%ebp)
  8006de:	e8 8d 0b 00 00       	call   801270 <__umoddi3>
  8006e3:	83 c4 14             	add    $0x14,%esp
  8006e6:	0f be 80 4b 14 80 00 	movsbl 0x80144b(%eax),%eax
  8006ed:	50                   	push   %eax
  8006ee:	ff d7                	call   *%edi
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	e9 d5 fe ff ff       	jmp    8005cd <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	ff 75 18             	pushl  0x18(%ebp)
  8006fe:	83 eb 01             	sub    $0x1,%ebx
  800701:	53                   	push   %ebx
  800702:	ff 75 10             	pushl  0x10(%ebp)
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	ff 75 dc             	pushl  -0x24(%ebp)
  80070b:	ff 75 d8             	pushl  -0x28(%ebp)
  80070e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800711:	ff 75 e0             	pushl  -0x20(%ebp)
  800714:	e8 27 0a 00 00       	call   801140 <__udivdi3>
  800719:	83 c4 18             	add    $0x18,%esp
  80071c:	52                   	push   %edx
  80071d:	50                   	push   %eax
  80071e:	89 f2                	mov    %esi,%edx
  800720:	89 f8                	mov    %edi,%eax
  800722:	e8 15 fe ff ff       	call   80053c <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800727:	83 c4 18             	add    $0x18,%esp
  80072a:	56                   	push   %esi
  80072b:	83 ec 04             	sub    $0x4,%esp
  80072e:	ff 75 dc             	pushl  -0x24(%ebp)
  800731:	ff 75 d8             	pushl  -0x28(%ebp)
  800734:	ff 75 e4             	pushl  -0x1c(%ebp)
  800737:	ff 75 e0             	pushl  -0x20(%ebp)
  80073a:	e8 31 0b 00 00       	call   801270 <__umoddi3>
  80073f:	83 c4 14             	add    $0x14,%esp
  800742:	0f be 80 4b 14 80 00 	movsbl 0x80144b(%eax),%eax
  800749:	50                   	push   %eax
  80074a:	ff d7                	call   *%edi
  80074c:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80074f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800752:	5b                   	pop    %ebx
  800753:	5e                   	pop    %esi
  800754:	5f                   	pop    %edi
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80075a:	83 fa 01             	cmp    $0x1,%edx
  80075d:	7e 0e                	jle    80076d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80075f:	8b 10                	mov    (%eax),%edx
  800761:	8d 4a 08             	lea    0x8(%edx),%ecx
  800764:	89 08                	mov    %ecx,(%eax)
  800766:	8b 02                	mov    (%edx),%eax
  800768:	8b 52 04             	mov    0x4(%edx),%edx
  80076b:	eb 22                	jmp    80078f <getuint+0x38>
	else if (lflag)
  80076d:	85 d2                	test   %edx,%edx
  80076f:	74 10                	je     800781 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800771:	8b 10                	mov    (%eax),%edx
  800773:	8d 4a 04             	lea    0x4(%edx),%ecx
  800776:	89 08                	mov    %ecx,(%eax)
  800778:	8b 02                	mov    (%edx),%eax
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
  80077f:	eb 0e                	jmp    80078f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800781:	8b 10                	mov    (%eax),%edx
  800783:	8d 4a 04             	lea    0x4(%edx),%ecx
  800786:	89 08                	mov    %ecx,(%eax)
  800788:	8b 02                	mov    (%edx),%eax
  80078a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800797:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	3b 50 04             	cmp    0x4(%eax),%edx
  8007a0:	73 0a                	jae    8007ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8007a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007a5:	89 08                	mov    %ecx,(%eax)
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	88 02                	mov    %al,(%edx)
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b7:	50                   	push   %eax
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	ff 75 0c             	pushl  0xc(%ebp)
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 05 00 00 00       	call   8007cb <vprintfmt>
	va_end(ap);
}
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	57                   	push   %edi
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	83 ec 2c             	sub    $0x2c,%esp
  8007d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007da:	eb 03                	jmp    8007df <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dc:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007df:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e2:	8d 70 01             	lea    0x1(%eax),%esi
  8007e5:	0f b6 00             	movzbl (%eax),%eax
  8007e8:	83 f8 25             	cmp    $0x25,%eax
  8007eb:	74 27                	je     800814 <vprintfmt+0x49>
			if (ch == '\0')
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	75 0d                	jne    8007fe <vprintfmt+0x33>
  8007f1:	e9 9d 04 00 00       	jmp    800c93 <vprintfmt+0x4c8>
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	0f 84 95 04 00 00    	je     800c93 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	50                   	push   %eax
  800803:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800805:	83 c6 01             	add    $0x1,%esi
  800808:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	83 f8 25             	cmp    $0x25,%eax
  800812:	75 e2                	jne    8007f6 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800814:	b9 00 00 00 00       	mov    $0x0,%ecx
  800819:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80081d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800824:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80082b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800832:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800839:	eb 08                	jmp    800843 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083b:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80083e:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800843:	8d 46 01             	lea    0x1(%esi),%eax
  800846:	89 45 10             	mov    %eax,0x10(%ebp)
  800849:	0f b6 06             	movzbl (%esi),%eax
  80084c:	0f b6 d0             	movzbl %al,%edx
  80084f:	83 e8 23             	sub    $0x23,%eax
  800852:	3c 55                	cmp    $0x55,%al
  800854:	0f 87 fa 03 00 00    	ja     800c54 <vprintfmt+0x489>
  80085a:	0f b6 c0             	movzbl %al,%eax
  80085d:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  800864:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800867:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80086b:	eb d6                	jmp    800843 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80086d:	8d 42 d0             	lea    -0x30(%edx),%eax
  800870:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800873:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800877:	8d 50 d0             	lea    -0x30(%eax),%edx
  80087a:	83 fa 09             	cmp    $0x9,%edx
  80087d:	77 6b                	ja     8008ea <vprintfmt+0x11f>
  80087f:	8b 75 10             	mov    0x10(%ebp),%esi
  800882:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800885:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800888:	eb 09                	jmp    800893 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088a:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80088d:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800891:	eb b0                	jmp    800843 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800893:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800896:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800899:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80089d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008a0:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008a3:	83 f9 09             	cmp    $0x9,%ecx
  8008a6:	76 eb                	jbe    800893 <vprintfmt+0xc8>
  8008a8:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008ab:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008ae:	eb 3d                	jmp    8008ed <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	8d 50 04             	lea    0x4(%eax),%edx
  8008b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b9:	8b 00                	mov    (%eax),%eax
  8008bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008c1:	eb 2a                	jmp    8008ed <vprintfmt+0x122>
  8008c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008c6:	85 c0                	test   %eax,%eax
  8008c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008cd:	0f 49 d0             	cmovns %eax,%edx
  8008d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 75 10             	mov    0x10(%ebp),%esi
  8008d6:	e9 68 ff ff ff       	jmp    800843 <vprintfmt+0x78>
  8008db:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008e5:	e9 59 ff ff ff       	jmp    800843 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008f1:	0f 89 4c ff ff ff    	jns    800843 <vprintfmt+0x78>
				width = precision, precision = -1;
  8008f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800904:	e9 3a ff ff ff       	jmp    800843 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800909:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090d:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800910:	e9 2e ff ff ff       	jmp    800843 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8d 50 04             	lea    0x4(%eax),%edx
  80091b:	89 55 14             	mov    %edx,0x14(%ebp)
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	53                   	push   %ebx
  800922:	ff 30                	pushl  (%eax)
  800924:	ff d7                	call   *%edi
			break;
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	e9 b1 fe ff ff       	jmp    8007df <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)
  800937:	8b 00                	mov    (%eax),%eax
  800939:	99                   	cltd   
  80093a:	31 d0                	xor    %edx,%eax
  80093c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80093e:	83 f8 08             	cmp    $0x8,%eax
  800941:	7f 0b                	jg     80094e <vprintfmt+0x183>
  800943:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  80094a:	85 d2                	test   %edx,%edx
  80094c:	75 15                	jne    800963 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80094e:	50                   	push   %eax
  80094f:	68 63 14 80 00       	push   $0x801463
  800954:	53                   	push   %ebx
  800955:	57                   	push   %edi
  800956:	e8 53 fe ff ff       	call   8007ae <printfmt>
  80095b:	83 c4 10             	add    $0x10,%esp
  80095e:	e9 7c fe ff ff       	jmp    8007df <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800963:	52                   	push   %edx
  800964:	68 6c 14 80 00       	push   $0x80146c
  800969:	53                   	push   %ebx
  80096a:	57                   	push   %edi
  80096b:	e8 3e fe ff ff       	call   8007ae <printfmt>
  800970:	83 c4 10             	add    $0x10,%esp
  800973:	e9 67 fe ff ff       	jmp    8007df <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8d 50 04             	lea    0x4(%eax),%edx
  80097e:	89 55 14             	mov    %edx,0x14(%ebp)
  800981:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800983:	85 c0                	test   %eax,%eax
  800985:	b9 5c 14 80 00       	mov    $0x80145c,%ecx
  80098a:	0f 45 c8             	cmovne %eax,%ecx
  80098d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800990:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800994:	7e 06                	jle    80099c <vprintfmt+0x1d1>
  800996:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80099a:	75 19                	jne    8009b5 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80099c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80099f:	8d 70 01             	lea    0x1(%eax),%esi
  8009a2:	0f b6 00             	movzbl (%eax),%eax
  8009a5:	0f be d0             	movsbl %al,%edx
  8009a8:	85 d2                	test   %edx,%edx
  8009aa:	0f 85 9f 00 00 00    	jne    800a4f <vprintfmt+0x284>
  8009b0:	e9 8c 00 00 00       	jmp    800a41 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	ff 75 d0             	pushl  -0x30(%ebp)
  8009bb:	ff 75 cc             	pushl  -0x34(%ebp)
  8009be:	e8 62 03 00 00       	call   800d25 <strnlen>
  8009c3:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009c6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009c9:	83 c4 10             	add    $0x10,%esp
  8009cc:	85 c9                	test   %ecx,%ecx
  8009ce:	0f 8e a6 02 00 00    	jle    800c7a <vprintfmt+0x4af>
					putch(padc, putdat);
  8009d4:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009db:	89 cb                	mov    %ecx,%ebx
  8009dd:	83 ec 08             	sub    $0x8,%esp
  8009e0:	ff 75 0c             	pushl  0xc(%ebp)
  8009e3:	56                   	push   %esi
  8009e4:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	83 eb 01             	sub    $0x1,%ebx
  8009ec:	75 ef                	jne    8009dd <vprintfmt+0x212>
  8009ee:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f4:	e9 81 02 00 00       	jmp    800c7a <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fd:	74 1b                	je     800a1a <vprintfmt+0x24f>
  8009ff:	0f be c0             	movsbl %al,%eax
  800a02:	83 e8 20             	sub    $0x20,%eax
  800a05:	83 f8 5e             	cmp    $0x5e,%eax
  800a08:	76 10                	jbe    800a1a <vprintfmt+0x24f>
					putch('?', putdat);
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	6a 3f                	push   $0x3f
  800a12:	ff 55 08             	call   *0x8(%ebp)
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	eb 0d                	jmp    800a27 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a1a:	83 ec 08             	sub    $0x8,%esp
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	52                   	push   %edx
  800a21:	ff 55 08             	call   *0x8(%ebp)
  800a24:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a27:	83 ef 01             	sub    $0x1,%edi
  800a2a:	83 c6 01             	add    $0x1,%esi
  800a2d:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a31:	0f be d0             	movsbl %al,%edx
  800a34:	85 d2                	test   %edx,%edx
  800a36:	75 31                	jne    800a69 <vprintfmt+0x29e>
  800a38:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a41:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a44:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a48:	7f 33                	jg     800a7d <vprintfmt+0x2b2>
  800a4a:	e9 90 fd ff ff       	jmp    8007df <vprintfmt+0x14>
  800a4f:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a55:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a58:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a5b:	eb 0c                	jmp    800a69 <vprintfmt+0x29e>
  800a5d:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a63:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a66:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	78 8c                	js     8009f9 <vprintfmt+0x22e>
  800a6d:	83 eb 01             	sub    $0x1,%ebx
  800a70:	79 87                	jns    8009f9 <vprintfmt+0x22e>
  800a72:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7b:	eb c4                	jmp    800a41 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a7d:	83 ec 08             	sub    $0x8,%esp
  800a80:	53                   	push   %ebx
  800a81:	6a 20                	push   $0x20
  800a83:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	83 ee 01             	sub    $0x1,%esi
  800a8b:	75 f0                	jne    800a7d <vprintfmt+0x2b2>
  800a8d:	e9 4d fd ff ff       	jmp    8007df <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a92:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800a96:	7e 16                	jle    800aae <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800a98:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9b:	8d 50 08             	lea    0x8(%eax),%edx
  800a9e:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa1:	8b 50 04             	mov    0x4(%eax),%edx
  800aa4:	8b 00                	mov    (%eax),%eax
  800aa6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800aa9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800aac:	eb 34                	jmp    800ae2 <vprintfmt+0x317>
	else if (lflag)
  800aae:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ab2:	74 18                	je     800acc <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ab4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab7:	8d 50 04             	lea    0x4(%eax),%edx
  800aba:	89 55 14             	mov    %edx,0x14(%ebp)
  800abd:	8b 30                	mov    (%eax),%esi
  800abf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ac2:	89 f0                	mov    %esi,%eax
  800ac4:	c1 f8 1f             	sar    $0x1f,%eax
  800ac7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800aca:	eb 16                	jmp    800ae2 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800acc:	8b 45 14             	mov    0x14(%ebp),%eax
  800acf:	8d 50 04             	lea    0x4(%eax),%edx
  800ad2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad5:	8b 30                	mov    (%eax),%esi
  800ad7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ada:	89 f0                	mov    %esi,%eax
  800adc:	c1 f8 1f             	sar    $0x1f,%eax
  800adf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ae2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ae5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ae8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aeb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800aee:	85 d2                	test   %edx,%edx
  800af0:	79 28                	jns    800b1a <vprintfmt+0x34f>
				putch('-', putdat);
  800af2:	83 ec 08             	sub    $0x8,%esp
  800af5:	53                   	push   %ebx
  800af6:	6a 2d                	push   $0x2d
  800af8:	ff d7                	call   *%edi
				num = -(long long) num;
  800afa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800afd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b00:	f7 d8                	neg    %eax
  800b02:	83 d2 00             	adc    $0x0,%edx
  800b05:	f7 da                	neg    %edx
  800b07:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b0a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b0d:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b15:	e9 b2 00 00 00       	jmp    800bcc <vprintfmt+0x401>
  800b1a:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b1f:	85 c9                	test   %ecx,%ecx
  800b21:	0f 84 a5 00 00 00    	je     800bcc <vprintfmt+0x401>
				putch('+', putdat);
  800b27:	83 ec 08             	sub    $0x8,%esp
  800b2a:	53                   	push   %ebx
  800b2b:	6a 2b                	push   $0x2b
  800b2d:	ff d7                	call   *%edi
  800b2f:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b37:	e9 90 00 00 00       	jmp    800bcc <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b3c:	85 c9                	test   %ecx,%ecx
  800b3e:	74 0b                	je     800b4b <vprintfmt+0x380>
				putch('+', putdat);
  800b40:	83 ec 08             	sub    $0x8,%esp
  800b43:	53                   	push   %ebx
  800b44:	6a 2b                	push   $0x2b
  800b46:	ff d7                	call   *%edi
  800b48:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b4b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b4e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b51:	e8 01 fc ff ff       	call   800757 <getuint>
  800b56:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b59:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b5c:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b61:	eb 69                	jmp    800bcc <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	53                   	push   %ebx
  800b67:	6a 30                	push   $0x30
  800b69:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b6b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b71:	e8 e1 fb ff ff       	call   800757 <getuint>
  800b76:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b79:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b7c:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b7f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b84:	eb 46                	jmp    800bcc <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b86:	83 ec 08             	sub    $0x8,%esp
  800b89:	53                   	push   %ebx
  800b8a:	6a 30                	push   $0x30
  800b8c:	ff d7                	call   *%edi
			putch('x', putdat);
  800b8e:	83 c4 08             	add    $0x8,%esp
  800b91:	53                   	push   %ebx
  800b92:	6a 78                	push   $0x78
  800b94:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b96:	8b 45 14             	mov    0x14(%ebp),%eax
  800b99:	8d 50 04             	lea    0x4(%eax),%edx
  800b9c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b9f:	8b 00                	mov    (%eax),%eax
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ba9:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bac:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800baf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bb4:	eb 16                	jmp    800bcc <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bb6:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bb9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bbc:	e8 96 fb ff ff       	call   800757 <getuint>
  800bc1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bc4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bc7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bd3:	56                   	push   %esi
  800bd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bd7:	50                   	push   %eax
  800bd8:	ff 75 dc             	pushl  -0x24(%ebp)
  800bdb:	ff 75 d8             	pushl  -0x28(%ebp)
  800bde:	89 da                	mov    %ebx,%edx
  800be0:	89 f8                	mov    %edi,%eax
  800be2:	e8 55 f9 ff ff       	call   80053c <printnum>
			break;
  800be7:	83 c4 20             	add    $0x20,%esp
  800bea:	e9 f0 fb ff ff       	jmp    8007df <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800bef:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf2:	8d 50 04             	lea    0x4(%eax),%edx
  800bf5:	89 55 14             	mov    %edx,0x14(%ebp)
  800bf8:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800bfa:	85 f6                	test   %esi,%esi
  800bfc:	75 1a                	jne    800c18 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	68 04 15 80 00       	push   $0x801504
  800c06:	68 6c 14 80 00       	push   $0x80146c
  800c0b:	e8 18 f9 ff ff       	call   800528 <cprintf>
  800c10:	83 c4 10             	add    $0x10,%esp
  800c13:	e9 c7 fb ff ff       	jmp    8007df <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c18:	0f b6 03             	movzbl (%ebx),%eax
  800c1b:	84 c0                	test   %al,%al
  800c1d:	79 1f                	jns    800c3e <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c1f:	83 ec 08             	sub    $0x8,%esp
  800c22:	68 3c 15 80 00       	push   $0x80153c
  800c27:	68 6c 14 80 00       	push   $0x80146c
  800c2c:	e8 f7 f8 ff ff       	call   800528 <cprintf>
						*tmp = *(char *)putdat;
  800c31:	0f b6 03             	movzbl (%ebx),%eax
  800c34:	88 06                	mov    %al,(%esi)
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	e9 a1 fb ff ff       	jmp    8007df <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c3e:	88 06                	mov    %al,(%esi)
  800c40:	e9 9a fb ff ff       	jmp    8007df <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c45:	83 ec 08             	sub    $0x8,%esp
  800c48:	53                   	push   %ebx
  800c49:	52                   	push   %edx
  800c4a:	ff d7                	call   *%edi
			break;
  800c4c:	83 c4 10             	add    $0x10,%esp
  800c4f:	e9 8b fb ff ff       	jmp    8007df <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c54:	83 ec 08             	sub    $0x8,%esp
  800c57:	53                   	push   %ebx
  800c58:	6a 25                	push   $0x25
  800c5a:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c63:	0f 84 73 fb ff ff    	je     8007dc <vprintfmt+0x11>
  800c69:	83 ee 01             	sub    $0x1,%esi
  800c6c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c70:	75 f7                	jne    800c69 <vprintfmt+0x49e>
  800c72:	89 75 10             	mov    %esi,0x10(%ebp)
  800c75:	e9 65 fb ff ff       	jmp    8007df <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c7a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c7d:	8d 70 01             	lea    0x1(%eax),%esi
  800c80:	0f b6 00             	movzbl (%eax),%eax
  800c83:	0f be d0             	movsbl %al,%edx
  800c86:	85 d2                	test   %edx,%edx
  800c88:	0f 85 cf fd ff ff    	jne    800a5d <vprintfmt+0x292>
  800c8e:	e9 4c fb ff ff       	jmp    8007df <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 18             	sub    $0x18,%esp
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800caa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	74 26                	je     800ce2 <vsnprintf+0x47>
  800cbc:	85 d2                	test   %edx,%edx
  800cbe:	7e 22                	jle    800ce2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cc0:	ff 75 14             	pushl  0x14(%ebp)
  800cc3:	ff 75 10             	pushl  0x10(%ebp)
  800cc6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc9:	50                   	push   %eax
  800cca:	68 91 07 80 00       	push   $0x800791
  800ccf:	e8 f7 fa ff ff       	call   8007cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	eb 05                	jmp    800ce7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ce2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    

00800ce9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cf2:	50                   	push   %eax
  800cf3:	ff 75 10             	pushl  0x10(%ebp)
  800cf6:	ff 75 0c             	pushl  0xc(%ebp)
  800cf9:	ff 75 08             	pushl  0x8(%ebp)
  800cfc:	e8 9a ff ff ff       	call   800c9b <vsnprintf>
	va_end(ap);

	return rc;
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d09:	80 3a 00             	cmpb   $0x0,(%edx)
  800d0c:	74 10                	je     800d1e <strlen+0x1b>
  800d0e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d13:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d16:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d1a:	75 f7                	jne    800d13 <strlen+0x10>
  800d1c:	eb 05                	jmp    800d23 <strlen+0x20>
  800d1e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	53                   	push   %ebx
  800d29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2f:	85 c9                	test   %ecx,%ecx
  800d31:	74 1c                	je     800d4f <strnlen+0x2a>
  800d33:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d36:	74 1e                	je     800d56 <strnlen+0x31>
  800d38:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d3d:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d3f:	39 ca                	cmp    %ecx,%edx
  800d41:	74 18                	je     800d5b <strnlen+0x36>
  800d43:	83 c2 01             	add    $0x1,%edx
  800d46:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d4b:	75 f0                	jne    800d3d <strnlen+0x18>
  800d4d:	eb 0c                	jmp    800d5b <strnlen+0x36>
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d54:	eb 05                	jmp    800d5b <strnlen+0x36>
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d5b:	5b                   	pop    %ebx
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	53                   	push   %ebx
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	83 c2 01             	add    $0x1,%edx
  800d6d:	83 c1 01             	add    $0x1,%ecx
  800d70:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d74:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d77:	84 db                	test   %bl,%bl
  800d79:	75 ef                	jne    800d6a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	53                   	push   %ebx
  800d82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d85:	53                   	push   %ebx
  800d86:	e8 78 ff ff ff       	call   800d03 <strlen>
  800d8b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d8e:	ff 75 0c             	pushl  0xc(%ebp)
  800d91:	01 d8                	add    %ebx,%eax
  800d93:	50                   	push   %eax
  800d94:	e8 c5 ff ff ff       	call   800d5e <strcpy>
	return dst;
}
  800d99:	89 d8                	mov    %ebx,%eax
  800d9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d9e:	c9                   	leave  
  800d9f:	c3                   	ret    

00800da0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	8b 75 08             	mov    0x8(%ebp),%esi
  800da8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dae:	85 db                	test   %ebx,%ebx
  800db0:	74 17                	je     800dc9 <strncpy+0x29>
  800db2:	01 f3                	add    %esi,%ebx
  800db4:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800db6:	83 c1 01             	add    $0x1,%ecx
  800db9:	0f b6 02             	movzbl (%edx),%eax
  800dbc:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dbf:	80 3a 01             	cmpb   $0x1,(%edx)
  800dc2:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc5:	39 cb                	cmp    %ecx,%ebx
  800dc7:	75 ed                	jne    800db6 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dda:	8b 55 10             	mov    0x10(%ebp),%edx
  800ddd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ddf:	85 d2                	test   %edx,%edx
  800de1:	74 35                	je     800e18 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800de3:	89 d0                	mov    %edx,%eax
  800de5:	83 e8 01             	sub    $0x1,%eax
  800de8:	74 25                	je     800e0f <strlcpy+0x40>
  800dea:	0f b6 0b             	movzbl (%ebx),%ecx
  800ded:	84 c9                	test   %cl,%cl
  800def:	74 22                	je     800e13 <strlcpy+0x44>
  800df1:	8d 53 01             	lea    0x1(%ebx),%edx
  800df4:	01 c3                	add    %eax,%ebx
  800df6:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800df8:	83 c0 01             	add    $0x1,%eax
  800dfb:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dfe:	39 da                	cmp    %ebx,%edx
  800e00:	74 13                	je     800e15 <strlcpy+0x46>
  800e02:	83 c2 01             	add    $0x1,%edx
  800e05:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e09:	84 c9                	test   %cl,%cl
  800e0b:	75 eb                	jne    800df8 <strlcpy+0x29>
  800e0d:	eb 06                	jmp    800e15 <strlcpy+0x46>
  800e0f:	89 f0                	mov    %esi,%eax
  800e11:	eb 02                	jmp    800e15 <strlcpy+0x46>
  800e13:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e15:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e18:	29 f0                	sub    %esi,%eax
}
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e24:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e27:	0f b6 01             	movzbl (%ecx),%eax
  800e2a:	84 c0                	test   %al,%al
  800e2c:	74 15                	je     800e43 <strcmp+0x25>
  800e2e:	3a 02                	cmp    (%edx),%al
  800e30:	75 11                	jne    800e43 <strcmp+0x25>
		p++, q++;
  800e32:	83 c1 01             	add    $0x1,%ecx
  800e35:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e38:	0f b6 01             	movzbl (%ecx),%eax
  800e3b:	84 c0                	test   %al,%al
  800e3d:	74 04                	je     800e43 <strcmp+0x25>
  800e3f:	3a 02                	cmp    (%edx),%al
  800e41:	74 ef                	je     800e32 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e43:	0f b6 c0             	movzbl %al,%eax
  800e46:	0f b6 12             	movzbl (%edx),%edx
  800e49:	29 d0                	sub    %edx,%eax
}
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e58:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e5b:	85 f6                	test   %esi,%esi
  800e5d:	74 29                	je     800e88 <strncmp+0x3b>
  800e5f:	0f b6 03             	movzbl (%ebx),%eax
  800e62:	84 c0                	test   %al,%al
  800e64:	74 30                	je     800e96 <strncmp+0x49>
  800e66:	3a 02                	cmp    (%edx),%al
  800e68:	75 2c                	jne    800e96 <strncmp+0x49>
  800e6a:	8d 43 01             	lea    0x1(%ebx),%eax
  800e6d:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e6f:	89 c3                	mov    %eax,%ebx
  800e71:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e74:	39 c6                	cmp    %eax,%esi
  800e76:	74 17                	je     800e8f <strncmp+0x42>
  800e78:	0f b6 08             	movzbl (%eax),%ecx
  800e7b:	84 c9                	test   %cl,%cl
  800e7d:	74 17                	je     800e96 <strncmp+0x49>
  800e7f:	83 c0 01             	add    $0x1,%eax
  800e82:	3a 0a                	cmp    (%edx),%cl
  800e84:	74 e9                	je     800e6f <strncmp+0x22>
  800e86:	eb 0e                	jmp    800e96 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	eb 0f                	jmp    800e9e <strncmp+0x51>
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	eb 08                	jmp    800e9e <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e96:	0f b6 03             	movzbl (%ebx),%eax
  800e99:	0f b6 12             	movzbl (%edx),%edx
  800e9c:	29 d0                	sub    %edx,%eax
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	53                   	push   %ebx
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800eac:	0f b6 10             	movzbl (%eax),%edx
  800eaf:	84 d2                	test   %dl,%dl
  800eb1:	74 1d                	je     800ed0 <strchr+0x2e>
  800eb3:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800eb5:	38 d3                	cmp    %dl,%bl
  800eb7:	75 06                	jne    800ebf <strchr+0x1d>
  800eb9:	eb 1a                	jmp    800ed5 <strchr+0x33>
  800ebb:	38 ca                	cmp    %cl,%dl
  800ebd:	74 16                	je     800ed5 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ebf:	83 c0 01             	add    $0x1,%eax
  800ec2:	0f b6 10             	movzbl (%eax),%edx
  800ec5:	84 d2                	test   %dl,%dl
  800ec7:	75 f2                	jne    800ebb <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ece:	eb 05                	jmp    800ed5 <strchr+0x33>
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed5:	5b                   	pop    %ebx
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	53                   	push   %ebx
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ee2:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ee5:	38 d3                	cmp    %dl,%bl
  800ee7:	74 14                	je     800efd <strfind+0x25>
  800ee9:	89 d1                	mov    %edx,%ecx
  800eeb:	84 db                	test   %bl,%bl
  800eed:	74 0e                	je     800efd <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eef:	83 c0 01             	add    $0x1,%eax
  800ef2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ef5:	38 ca                	cmp    %cl,%dl
  800ef7:	74 04                	je     800efd <strfind+0x25>
  800ef9:	84 d2                	test   %dl,%dl
  800efb:	75 f2                	jne    800eef <strfind+0x17>
			break;
	return (char *) s;
}
  800efd:	5b                   	pop    %ebx
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f0c:	85 c9                	test   %ecx,%ecx
  800f0e:	74 36                	je     800f46 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f10:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f16:	75 28                	jne    800f40 <memset+0x40>
  800f18:	f6 c1 03             	test   $0x3,%cl
  800f1b:	75 23                	jne    800f40 <memset+0x40>
		c &= 0xFF;
  800f1d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f21:	89 d3                	mov    %edx,%ebx
  800f23:	c1 e3 08             	shl    $0x8,%ebx
  800f26:	89 d6                	mov    %edx,%esi
  800f28:	c1 e6 18             	shl    $0x18,%esi
  800f2b:	89 d0                	mov    %edx,%eax
  800f2d:	c1 e0 10             	shl    $0x10,%eax
  800f30:	09 f0                	or     %esi,%eax
  800f32:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f34:	89 d8                	mov    %ebx,%eax
  800f36:	09 d0                	or     %edx,%eax
  800f38:	c1 e9 02             	shr    $0x2,%ecx
  800f3b:	fc                   	cld    
  800f3c:	f3 ab                	rep stos %eax,%es:(%edi)
  800f3e:	eb 06                	jmp    800f46 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f43:	fc                   	cld    
  800f44:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f46:	89 f8                	mov    %edi,%eax
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	8b 45 08             	mov    0x8(%ebp),%eax
  800f55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f5b:	39 c6                	cmp    %eax,%esi
  800f5d:	73 35                	jae    800f94 <memmove+0x47>
  800f5f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f62:	39 d0                	cmp    %edx,%eax
  800f64:	73 2e                	jae    800f94 <memmove+0x47>
		s += n;
		d += n;
  800f66:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f69:	89 d6                	mov    %edx,%esi
  800f6b:	09 fe                	or     %edi,%esi
  800f6d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f73:	75 13                	jne    800f88 <memmove+0x3b>
  800f75:	f6 c1 03             	test   $0x3,%cl
  800f78:	75 0e                	jne    800f88 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f7a:	83 ef 04             	sub    $0x4,%edi
  800f7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f80:	c1 e9 02             	shr    $0x2,%ecx
  800f83:	fd                   	std    
  800f84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f86:	eb 09                	jmp    800f91 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f88:	83 ef 01             	sub    $0x1,%edi
  800f8b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f8e:	fd                   	std    
  800f8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f91:	fc                   	cld    
  800f92:	eb 1d                	jmp    800fb1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f94:	89 f2                	mov    %esi,%edx
  800f96:	09 c2                	or     %eax,%edx
  800f98:	f6 c2 03             	test   $0x3,%dl
  800f9b:	75 0f                	jne    800fac <memmove+0x5f>
  800f9d:	f6 c1 03             	test   $0x3,%cl
  800fa0:	75 0a                	jne    800fac <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fa2:	c1 e9 02             	shr    $0x2,%ecx
  800fa5:	89 c7                	mov    %eax,%edi
  800fa7:	fc                   	cld    
  800fa8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800faa:	eb 05                	jmp    800fb1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fac:	89 c7                	mov    %eax,%edi
  800fae:	fc                   	cld    
  800faf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fb8:	ff 75 10             	pushl  0x10(%ebp)
  800fbb:	ff 75 0c             	pushl  0xc(%ebp)
  800fbe:	ff 75 08             	pushl  0x8(%ebp)
  800fc1:	e8 87 ff ff ff       	call   800f4d <memmove>
}
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	57                   	push   %edi
  800fcc:	56                   	push   %esi
  800fcd:	53                   	push   %ebx
  800fce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fd4:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	74 39                	je     801014 <memcmp+0x4c>
  800fdb:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800fde:	0f b6 13             	movzbl (%ebx),%edx
  800fe1:	0f b6 0e             	movzbl (%esi),%ecx
  800fe4:	38 ca                	cmp    %cl,%dl
  800fe6:	75 17                	jne    800fff <memcmp+0x37>
  800fe8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fed:	eb 1a                	jmp    801009 <memcmp+0x41>
  800fef:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800ff4:	83 c0 01             	add    $0x1,%eax
  800ff7:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800ffb:	38 ca                	cmp    %cl,%dl
  800ffd:	74 0a                	je     801009 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800fff:	0f b6 c2             	movzbl %dl,%eax
  801002:	0f b6 c9             	movzbl %cl,%ecx
  801005:	29 c8                	sub    %ecx,%eax
  801007:	eb 10                	jmp    801019 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801009:	39 f8                	cmp    %edi,%eax
  80100b:	75 e2                	jne    800fef <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
  801012:	eb 05                	jmp    801019 <memcmp+0x51>
  801014:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801019:	5b                   	pop    %ebx
  80101a:	5e                   	pop    %esi
  80101b:	5f                   	pop    %edi
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    

0080101e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	53                   	push   %ebx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801025:	89 d0                	mov    %edx,%eax
  801027:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80102a:	39 c2                	cmp    %eax,%edx
  80102c:	73 1d                	jae    80104b <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80102e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801032:	0f b6 0a             	movzbl (%edx),%ecx
  801035:	39 d9                	cmp    %ebx,%ecx
  801037:	75 09                	jne    801042 <memfind+0x24>
  801039:	eb 14                	jmp    80104f <memfind+0x31>
  80103b:	0f b6 0a             	movzbl (%edx),%ecx
  80103e:	39 d9                	cmp    %ebx,%ecx
  801040:	74 11                	je     801053 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801042:	83 c2 01             	add    $0x1,%edx
  801045:	39 d0                	cmp    %edx,%eax
  801047:	75 f2                	jne    80103b <memfind+0x1d>
  801049:	eb 0a                	jmp    801055 <memfind+0x37>
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	eb 06                	jmp    801055 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  80104f:	89 d0                	mov    %edx,%eax
  801051:	eb 02                	jmp    801055 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801053:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801055:	5b                   	pop    %ebx
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801061:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801064:	0f b6 01             	movzbl (%ecx),%eax
  801067:	3c 20                	cmp    $0x20,%al
  801069:	74 04                	je     80106f <strtol+0x17>
  80106b:	3c 09                	cmp    $0x9,%al
  80106d:	75 0e                	jne    80107d <strtol+0x25>
		s++;
  80106f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801072:	0f b6 01             	movzbl (%ecx),%eax
  801075:	3c 20                	cmp    $0x20,%al
  801077:	74 f6                	je     80106f <strtol+0x17>
  801079:	3c 09                	cmp    $0x9,%al
  80107b:	74 f2                	je     80106f <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80107d:	3c 2b                	cmp    $0x2b,%al
  80107f:	75 0a                	jne    80108b <strtol+0x33>
		s++;
  801081:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801084:	bf 00 00 00 00       	mov    $0x0,%edi
  801089:	eb 11                	jmp    80109c <strtol+0x44>
  80108b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801090:	3c 2d                	cmp    $0x2d,%al
  801092:	75 08                	jne    80109c <strtol+0x44>
		s++, neg = 1;
  801094:	83 c1 01             	add    $0x1,%ecx
  801097:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80109c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010a2:	75 15                	jne    8010b9 <strtol+0x61>
  8010a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8010a7:	75 10                	jne    8010b9 <strtol+0x61>
  8010a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010ad:	75 7c                	jne    80112b <strtol+0xd3>
		s += 2, base = 16;
  8010af:	83 c1 02             	add    $0x2,%ecx
  8010b2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010b7:	eb 16                	jmp    8010cf <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010b9:	85 db                	test   %ebx,%ebx
  8010bb:	75 12                	jne    8010cf <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8010c5:	75 08                	jne    8010cf <strtol+0x77>
		s++, base = 8;
  8010c7:	83 c1 01             	add    $0x1,%ecx
  8010ca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d7:	0f b6 11             	movzbl (%ecx),%edx
  8010da:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010dd:	89 f3                	mov    %esi,%ebx
  8010df:	80 fb 09             	cmp    $0x9,%bl
  8010e2:	77 08                	ja     8010ec <strtol+0x94>
			dig = *s - '0';
  8010e4:	0f be d2             	movsbl %dl,%edx
  8010e7:	83 ea 30             	sub    $0x30,%edx
  8010ea:	eb 22                	jmp    80110e <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8010ec:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010ef:	89 f3                	mov    %esi,%ebx
  8010f1:	80 fb 19             	cmp    $0x19,%bl
  8010f4:	77 08                	ja     8010fe <strtol+0xa6>
			dig = *s - 'a' + 10;
  8010f6:	0f be d2             	movsbl %dl,%edx
  8010f9:	83 ea 57             	sub    $0x57,%edx
  8010fc:	eb 10                	jmp    80110e <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  8010fe:	8d 72 bf             	lea    -0x41(%edx),%esi
  801101:	89 f3                	mov    %esi,%ebx
  801103:	80 fb 19             	cmp    $0x19,%bl
  801106:	77 16                	ja     80111e <strtol+0xc6>
			dig = *s - 'A' + 10;
  801108:	0f be d2             	movsbl %dl,%edx
  80110b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80110e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801111:	7d 0b                	jge    80111e <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801113:	83 c1 01             	add    $0x1,%ecx
  801116:	0f af 45 10          	imul   0x10(%ebp),%eax
  80111a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80111c:	eb b9                	jmp    8010d7 <strtol+0x7f>

	if (endptr)
  80111e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801122:	74 0d                	je     801131 <strtol+0xd9>
		*endptr = (char *) s;
  801124:	8b 75 0c             	mov    0xc(%ebp),%esi
  801127:	89 0e                	mov    %ecx,(%esi)
  801129:	eb 06                	jmp    801131 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80112b:	85 db                	test   %ebx,%ebx
  80112d:	74 98                	je     8010c7 <strtol+0x6f>
  80112f:	eb 9e                	jmp    8010cf <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801131:	89 c2                	mov    %eax,%edx
  801133:	f7 da                	neg    %edx
  801135:	85 ff                	test   %edi,%edi
  801137:	0f 45 c2             	cmovne %edx,%eax
}
  80113a:	5b                   	pop    %ebx
  80113b:	5e                   	pop    %esi
  80113c:	5f                   	pop    %edi
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    
  80113f:	90                   	nop

00801140 <__udivdi3>:
  801140:	55                   	push   %ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 1c             	sub    $0x1c,%esp
  801147:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80114b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80114f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801157:	85 f6                	test   %esi,%esi
  801159:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80115d:	89 ca                	mov    %ecx,%edx
  80115f:	89 f8                	mov    %edi,%eax
  801161:	75 3d                	jne    8011a0 <__udivdi3+0x60>
  801163:	39 cf                	cmp    %ecx,%edi
  801165:	0f 87 c5 00 00 00    	ja     801230 <__udivdi3+0xf0>
  80116b:	85 ff                	test   %edi,%edi
  80116d:	89 fd                	mov    %edi,%ebp
  80116f:	75 0b                	jne    80117c <__udivdi3+0x3c>
  801171:	b8 01 00 00 00       	mov    $0x1,%eax
  801176:	31 d2                	xor    %edx,%edx
  801178:	f7 f7                	div    %edi
  80117a:	89 c5                	mov    %eax,%ebp
  80117c:	89 c8                	mov    %ecx,%eax
  80117e:	31 d2                	xor    %edx,%edx
  801180:	f7 f5                	div    %ebp
  801182:	89 c1                	mov    %eax,%ecx
  801184:	89 d8                	mov    %ebx,%eax
  801186:	89 cf                	mov    %ecx,%edi
  801188:	f7 f5                	div    %ebp
  80118a:	89 c3                	mov    %eax,%ebx
  80118c:	89 d8                	mov    %ebx,%eax
  80118e:	89 fa                	mov    %edi,%edx
  801190:	83 c4 1c             	add    $0x1c,%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    
  801198:	90                   	nop
  801199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	39 ce                	cmp    %ecx,%esi
  8011a2:	77 74                	ja     801218 <__udivdi3+0xd8>
  8011a4:	0f bd fe             	bsr    %esi,%edi
  8011a7:	83 f7 1f             	xor    $0x1f,%edi
  8011aa:	0f 84 98 00 00 00    	je     801248 <__udivdi3+0x108>
  8011b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011b5:	89 f9                	mov    %edi,%ecx
  8011b7:	89 c5                	mov    %eax,%ebp
  8011b9:	29 fb                	sub    %edi,%ebx
  8011bb:	d3 e6                	shl    %cl,%esi
  8011bd:	89 d9                	mov    %ebx,%ecx
  8011bf:	d3 ed                	shr    %cl,%ebp
  8011c1:	89 f9                	mov    %edi,%ecx
  8011c3:	d3 e0                	shl    %cl,%eax
  8011c5:	09 ee                	or     %ebp,%esi
  8011c7:	89 d9                	mov    %ebx,%ecx
  8011c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011cd:	89 d5                	mov    %edx,%ebp
  8011cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011d3:	d3 ed                	shr    %cl,%ebp
  8011d5:	89 f9                	mov    %edi,%ecx
  8011d7:	d3 e2                	shl    %cl,%edx
  8011d9:	89 d9                	mov    %ebx,%ecx
  8011db:	d3 e8                	shr    %cl,%eax
  8011dd:	09 c2                	or     %eax,%edx
  8011df:	89 d0                	mov    %edx,%eax
  8011e1:	89 ea                	mov    %ebp,%edx
  8011e3:	f7 f6                	div    %esi
  8011e5:	89 d5                	mov    %edx,%ebp
  8011e7:	89 c3                	mov    %eax,%ebx
  8011e9:	f7 64 24 0c          	mull   0xc(%esp)
  8011ed:	39 d5                	cmp    %edx,%ebp
  8011ef:	72 10                	jb     801201 <__udivdi3+0xc1>
  8011f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011f5:	89 f9                	mov    %edi,%ecx
  8011f7:	d3 e6                	shl    %cl,%esi
  8011f9:	39 c6                	cmp    %eax,%esi
  8011fb:	73 07                	jae    801204 <__udivdi3+0xc4>
  8011fd:	39 d5                	cmp    %edx,%ebp
  8011ff:	75 03                	jne    801204 <__udivdi3+0xc4>
  801201:	83 eb 01             	sub    $0x1,%ebx
  801204:	31 ff                	xor    %edi,%edi
  801206:	89 d8                	mov    %ebx,%eax
  801208:	89 fa                	mov    %edi,%edx
  80120a:	83 c4 1c             	add    $0x1c,%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5e                   	pop    %esi
  80120f:	5f                   	pop    %edi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    
  801212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801218:	31 ff                	xor    %edi,%edi
  80121a:	31 db                	xor    %ebx,%ebx
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	89 fa                	mov    %edi,%edx
  801220:	83 c4 1c             	add    $0x1c,%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
  801228:	90                   	nop
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 d8                	mov    %ebx,%eax
  801232:	f7 f7                	div    %edi
  801234:	31 ff                	xor    %edi,%edi
  801236:	89 c3                	mov    %eax,%ebx
  801238:	89 d8                	mov    %ebx,%eax
  80123a:	89 fa                	mov    %edi,%edx
  80123c:	83 c4 1c             	add    $0x1c,%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5f                   	pop    %edi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	39 ce                	cmp    %ecx,%esi
  80124a:	72 0c                	jb     801258 <__udivdi3+0x118>
  80124c:	31 db                	xor    %ebx,%ebx
  80124e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801252:	0f 87 34 ff ff ff    	ja     80118c <__udivdi3+0x4c>
  801258:	bb 01 00 00 00       	mov    $0x1,%ebx
  80125d:	e9 2a ff ff ff       	jmp    80118c <__udivdi3+0x4c>
  801262:	66 90                	xchg   %ax,%ax
  801264:	66 90                	xchg   %ax,%ax
  801266:	66 90                	xchg   %ax,%ax
  801268:	66 90                	xchg   %ax,%ax
  80126a:	66 90                	xchg   %ax,%ax
  80126c:	66 90                	xchg   %ax,%ax
  80126e:	66 90                	xchg   %ax,%ax

00801270 <__umoddi3>:
  801270:	55                   	push   %ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 1c             	sub    $0x1c,%esp
  801277:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80127b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80127f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801287:	85 d2                	test   %edx,%edx
  801289:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80128d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801291:	89 f3                	mov    %esi,%ebx
  801293:	89 3c 24             	mov    %edi,(%esp)
  801296:	89 74 24 04          	mov    %esi,0x4(%esp)
  80129a:	75 1c                	jne    8012b8 <__umoddi3+0x48>
  80129c:	39 f7                	cmp    %esi,%edi
  80129e:	76 50                	jbe    8012f0 <__umoddi3+0x80>
  8012a0:	89 c8                	mov    %ecx,%eax
  8012a2:	89 f2                	mov    %esi,%edx
  8012a4:	f7 f7                	div    %edi
  8012a6:	89 d0                	mov    %edx,%eax
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	83 c4 1c             	add    $0x1c,%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5f                   	pop    %edi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    
  8012b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012b8:	39 f2                	cmp    %esi,%edx
  8012ba:	89 d0                	mov    %edx,%eax
  8012bc:	77 52                	ja     801310 <__umoddi3+0xa0>
  8012be:	0f bd ea             	bsr    %edx,%ebp
  8012c1:	83 f5 1f             	xor    $0x1f,%ebp
  8012c4:	75 5a                	jne    801320 <__umoddi3+0xb0>
  8012c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012ca:	0f 82 e0 00 00 00    	jb     8013b0 <__umoddi3+0x140>
  8012d0:	39 0c 24             	cmp    %ecx,(%esp)
  8012d3:	0f 86 d7 00 00 00    	jbe    8013b0 <__umoddi3+0x140>
  8012d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012e1:	83 c4 1c             	add    $0x1c,%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    
  8012e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	85 ff                	test   %edi,%edi
  8012f2:	89 fd                	mov    %edi,%ebp
  8012f4:	75 0b                	jne    801301 <__umoddi3+0x91>
  8012f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	f7 f7                	div    %edi
  8012ff:	89 c5                	mov    %eax,%ebp
  801301:	89 f0                	mov    %esi,%eax
  801303:	31 d2                	xor    %edx,%edx
  801305:	f7 f5                	div    %ebp
  801307:	89 c8                	mov    %ecx,%eax
  801309:	f7 f5                	div    %ebp
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	eb 99                	jmp    8012a8 <__umoddi3+0x38>
  80130f:	90                   	nop
  801310:	89 c8                	mov    %ecx,%eax
  801312:	89 f2                	mov    %esi,%edx
  801314:	83 c4 1c             	add    $0x1c,%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5f                   	pop    %edi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	8b 34 24             	mov    (%esp),%esi
  801323:	bf 20 00 00 00       	mov    $0x20,%edi
  801328:	89 e9                	mov    %ebp,%ecx
  80132a:	29 ef                	sub    %ebp,%edi
  80132c:	d3 e0                	shl    %cl,%eax
  80132e:	89 f9                	mov    %edi,%ecx
  801330:	89 f2                	mov    %esi,%edx
  801332:	d3 ea                	shr    %cl,%edx
  801334:	89 e9                	mov    %ebp,%ecx
  801336:	09 c2                	or     %eax,%edx
  801338:	89 d8                	mov    %ebx,%eax
  80133a:	89 14 24             	mov    %edx,(%esp)
  80133d:	89 f2                	mov    %esi,%edx
  80133f:	d3 e2                	shl    %cl,%edx
  801341:	89 f9                	mov    %edi,%ecx
  801343:	89 54 24 04          	mov    %edx,0x4(%esp)
  801347:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80134b:	d3 e8                	shr    %cl,%eax
  80134d:	89 e9                	mov    %ebp,%ecx
  80134f:	89 c6                	mov    %eax,%esi
  801351:	d3 e3                	shl    %cl,%ebx
  801353:	89 f9                	mov    %edi,%ecx
  801355:	89 d0                	mov    %edx,%eax
  801357:	d3 e8                	shr    %cl,%eax
  801359:	89 e9                	mov    %ebp,%ecx
  80135b:	09 d8                	or     %ebx,%eax
  80135d:	89 d3                	mov    %edx,%ebx
  80135f:	89 f2                	mov    %esi,%edx
  801361:	f7 34 24             	divl   (%esp)
  801364:	89 d6                	mov    %edx,%esi
  801366:	d3 e3                	shl    %cl,%ebx
  801368:	f7 64 24 04          	mull   0x4(%esp)
  80136c:	39 d6                	cmp    %edx,%esi
  80136e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801372:	89 d1                	mov    %edx,%ecx
  801374:	89 c3                	mov    %eax,%ebx
  801376:	72 08                	jb     801380 <__umoddi3+0x110>
  801378:	75 11                	jne    80138b <__umoddi3+0x11b>
  80137a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80137e:	73 0b                	jae    80138b <__umoddi3+0x11b>
  801380:	2b 44 24 04          	sub    0x4(%esp),%eax
  801384:	1b 14 24             	sbb    (%esp),%edx
  801387:	89 d1                	mov    %edx,%ecx
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80138f:	29 da                	sub    %ebx,%edx
  801391:	19 ce                	sbb    %ecx,%esi
  801393:	89 f9                	mov    %edi,%ecx
  801395:	89 f0                	mov    %esi,%eax
  801397:	d3 e0                	shl    %cl,%eax
  801399:	89 e9                	mov    %ebp,%ecx
  80139b:	d3 ea                	shr    %cl,%edx
  80139d:	89 e9                	mov    %ebp,%ecx
  80139f:	d3 ee                	shr    %cl,%esi
  8013a1:	09 d0                	or     %edx,%eax
  8013a3:	89 f2                	mov    %esi,%edx
  8013a5:	83 c4 1c             	add    $0x1c,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    
  8013ad:	8d 76 00             	lea    0x0(%esi),%esi
  8013b0:	29 f9                	sub    %edi,%ecx
  8013b2:	19 d6                	sbb    %edx,%esi
  8013b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013bc:	e9 18 ff ff ff       	jmp    8012d9 <__umoddi3+0x69>
