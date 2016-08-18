
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
  8000bd:	56                   	push   %esi
  8000be:	57                   	push   %edi
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	8d 35 ca 00 80 00    	lea    0x8000ca,%esi
  8000c8:	0f 34                	sysenter 

008000ca <label_21>:
  8000ca:	89 ec                	mov    %ebp,%esp
  8000cc:	5d                   	pop    %ebp
  8000cd:	5f                   	pop    %edi
  8000ce:	5e                   	pop    %esi
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
  8000ee:	56                   	push   %esi
  8000ef:	57                   	push   %edi
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	8d 35 fb 00 80 00    	lea    0x8000fb,%esi
  8000f9:	0f 34                	sysenter 

008000fb <label_55>:
  8000fb:	89 ec                	mov    %ebp,%esp
  8000fd:	5d                   	pop    %ebp
  8000fe:	5f                   	pop    %edi
  8000ff:	5e                   	pop    %esi
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
  800120:	56                   	push   %esi
  800121:	57                   	push   %edi
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	8d 35 2d 01 80 00    	lea    0x80012d,%esi
  80012b:	0f 34                	sysenter 

0080012d <label_90>:
  80012d:	89 ec                	mov    %ebp,%esp
  80012f:	5d                   	pop    %ebp
  800130:	5f                   	pop    %edi
  800131:	5e                   	pop    %esi
  800132:	5b                   	pop    %ebx
  800133:	5a                   	pop    %edx
  800134:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800135:	85 c0                	test   %eax,%eax
  800137:	7e 17                	jle    800150 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	50                   	push   %eax
  80013d:	6a 03                	push   $0x3
  80013f:	68 18 14 80 00       	push   $0x801418
  800144:	6a 29                	push   $0x29
  800146:	68 35 14 80 00       	push   $0x801435
  80014b:	e8 06 03 00 00       	call   800456 <_panic>

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
  80016f:	56                   	push   %esi
  800170:	57                   	push   %edi
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	8d 35 7c 01 80 00    	lea    0x80017c,%esi
  80017a:	0f 34                	sysenter 

0080017c <label_139>:
  80017c:	89 ec                	mov    %ebp,%esp
  80017e:	5d                   	pop    %ebp
  80017f:	5f                   	pop    %edi
  800180:	5e                   	pop    %esi
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
  8001a2:	56                   	push   %esi
  8001a3:	57                   	push   %edi
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	8d 35 af 01 80 00    	lea    0x8001af,%esi
  8001ad:	0f 34                	sysenter 

008001af <label_174>:
  8001af:	89 ec                	mov    %ebp,%esp
  8001b1:	5d                   	pop    %ebp
  8001b2:	5f                   	pop    %edi
  8001b3:	5e                   	pop    %esi
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
  8001d3:	56                   	push   %esi
  8001d4:	57                   	push   %edi
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	8d 35 e0 01 80 00    	lea    0x8001e0,%esi
  8001de:	0f 34                	sysenter 

008001e0 <label_209>:
  8001e0:	89 ec                	mov    %ebp,%esp
  8001e2:	5d                   	pop    %ebp
  8001e3:	5f                   	pop    %edi
  8001e4:	5e                   	pop    %esi
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
  800207:	56                   	push   %esi
  800208:	57                   	push   %edi
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	8d 35 14 02 80 00    	lea    0x800214,%esi
  800212:	0f 34                	sysenter 

00800214 <label_244>:
  800214:	89 ec                	mov    %ebp,%esp
  800216:	5d                   	pop    %ebp
  800217:	5f                   	pop    %edi
  800218:	5e                   	pop    %esi
  800219:	5b                   	pop    %ebx
  80021a:	5a                   	pop    %edx
  80021b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80021c:	85 c0                	test   %eax,%eax
  80021e:	7e 17                	jle    800237 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	50                   	push   %eax
  800224:	6a 05                	push   $0x5
  800226:	68 18 14 80 00       	push   $0x801418
  80022b:	6a 29                	push   $0x29
  80022d:	68 35 14 80 00       	push   $0x801435
  800232:	e8 1f 02 00 00       	call   800456 <_panic>

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
  800243:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  80024c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024f:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800252:	8b 45 10             	mov    0x10(%ebp),%eax
  800255:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800258:	8b 45 14             	mov    0x14(%ebp),%eax
  80025b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  80025e:	8b 45 18             	mov    0x18(%ebp),%eax
  800261:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800264:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800267:	b9 00 00 00 00       	mov    $0x0,%ecx
  80026c:	b8 06 00 00 00       	mov    $0x6,%eax
  800271:	89 cb                	mov    %ecx,%ebx
  800273:	89 cf                	mov    %ecx,%edi
  800275:	51                   	push   %ecx
  800276:	52                   	push   %edx
  800277:	53                   	push   %ebx
  800278:	56                   	push   %esi
  800279:	57                   	push   %edi
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	8d 35 85 02 80 00    	lea    0x800285,%esi
  800283:	0f 34                	sysenter 

00800285 <label_304>:
  800285:	89 ec                	mov    %ebp,%esp
  800287:	5d                   	pop    %ebp
  800288:	5f                   	pop    %edi
  800289:	5e                   	pop    %esi
  80028a:	5b                   	pop    %ebx
  80028b:	5a                   	pop    %edx
  80028c:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80028d:	85 c0                	test   %eax,%eax
  80028f:	7e 17                	jle    8002a8 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	50                   	push   %eax
  800295:	6a 06                	push   $0x6
  800297:	68 18 14 80 00       	push   $0x801418
  80029c:	6a 29                	push   $0x29
  80029e:	68 35 14 80 00       	push   $0x801435
  8002a3:	e8 ae 01 00 00       	call   800456 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  8002a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b9:	b8 07 00 00 00       	mov    $0x7,%eax
  8002be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c4:	89 fb                	mov    %edi,%ebx
  8002c6:	51                   	push   %ecx
  8002c7:	52                   	push   %edx
  8002c8:	53                   	push   %ebx
  8002c9:	56                   	push   %esi
  8002ca:	57                   	push   %edi
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	8d 35 d6 02 80 00    	lea    0x8002d6,%esi
  8002d4:	0f 34                	sysenter 

008002d6 <label_353>:
  8002d6:	89 ec                	mov    %ebp,%esp
  8002d8:	5d                   	pop    %ebp
  8002d9:	5f                   	pop    %edi
  8002da:	5e                   	pop    %esi
  8002db:	5b                   	pop    %ebx
  8002dc:	5a                   	pop    %edx
  8002dd:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 17                	jle    8002f9 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 07                	push   $0x7
  8002e8:	68 18 14 80 00       	push   $0x801418
  8002ed:	6a 29                	push   $0x29
  8002ef:	68 35 14 80 00       	push   $0x801435
  8002f4:	e8 5d 01 00 00       	call   800456 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800305:	bf 00 00 00 00       	mov    $0x0,%edi
  80030a:	b8 09 00 00 00       	mov    $0x9,%eax
  80030f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800312:	8b 55 08             	mov    0x8(%ebp),%edx
  800315:	89 fb                	mov    %edi,%ebx
  800317:	51                   	push   %ecx
  800318:	52                   	push   %edx
  800319:	53                   	push   %ebx
  80031a:	56                   	push   %esi
  80031b:	57                   	push   %edi
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8d 35 27 03 80 00    	lea    0x800327,%esi
  800325:	0f 34                	sysenter 

00800327 <label_402>:
  800327:	89 ec                	mov    %ebp,%esp
  800329:	5d                   	pop    %ebp
  80032a:	5f                   	pop    %edi
  80032b:	5e                   	pop    %esi
  80032c:	5b                   	pop    %ebx
  80032d:	5a                   	pop    %edx
  80032e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80032f:	85 c0                	test   %eax,%eax
  800331:	7e 17                	jle    80034a <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	50                   	push   %eax
  800337:	6a 09                	push   $0x9
  800339:	68 18 14 80 00       	push   $0x801418
  80033e:	6a 29                	push   $0x29
  800340:	68 35 14 80 00       	push   $0x801435
  800345:	e8 0c 01 00 00       	call   800456 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80034a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5f                   	pop    %edi
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	57                   	push   %edi
  800355:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800356:	bf 00 00 00 00       	mov    $0x0,%edi
  80035b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800360:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800363:	8b 55 08             	mov    0x8(%ebp),%edx
  800366:	89 fb                	mov    %edi,%ebx
  800368:	51                   	push   %ecx
  800369:	52                   	push   %edx
  80036a:	53                   	push   %ebx
  80036b:	56                   	push   %esi
  80036c:	57                   	push   %edi
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8d 35 78 03 80 00    	lea    0x800378,%esi
  800376:	0f 34                	sysenter 

00800378 <label_451>:
  800378:	89 ec                	mov    %ebp,%esp
  80037a:	5d                   	pop    %ebp
  80037b:	5f                   	pop    %edi
  80037c:	5e                   	pop    %esi
  80037d:	5b                   	pop    %ebx
  80037e:	5a                   	pop    %edx
  80037f:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800380:	85 c0                	test   %eax,%eax
  800382:	7e 17                	jle    80039b <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800384:	83 ec 0c             	sub    $0xc,%esp
  800387:	50                   	push   %eax
  800388:	6a 0a                	push   $0xa
  80038a:	68 18 14 80 00       	push   $0x801418
  80038f:	6a 29                	push   $0x29
  800391:	68 35 14 80 00       	push   $0x801435
  800396:	e8 bb 00 00 00       	call   800456 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80039b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80039e:	5b                   	pop    %ebx
  80039f:	5f                   	pop    %edi
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	57                   	push   %edi
  8003a6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003a7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003af:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b8:	51                   	push   %ecx
  8003b9:	52                   	push   %edx
  8003ba:	53                   	push   %ebx
  8003bb:	56                   	push   %esi
  8003bc:	57                   	push   %edi
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8d 35 c8 03 80 00    	lea    0x8003c8,%esi
  8003c6:	0f 34                	sysenter 

008003c8 <label_502>:
  8003c8:	89 ec                	mov    %ebp,%esp
  8003ca:	5d                   	pop    %ebp
  8003cb:	5f                   	pop    %edi
  8003cc:	5e                   	pop    %esi
  8003cd:	5b                   	pop    %ebx
  8003ce:	5a                   	pop    %edx
  8003cf:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003d0:	5b                   	pop    %ebx
  8003d1:	5f                   	pop    %edi
  8003d2:	5d                   	pop    %ebp
  8003d3:	c3                   	ret    

008003d4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003de:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e6:	89 d9                	mov    %ebx,%ecx
  8003e8:	89 df                	mov    %ebx,%edi
  8003ea:	51                   	push   %ecx
  8003eb:	52                   	push   %edx
  8003ec:	53                   	push   %ebx
  8003ed:	56                   	push   %esi
  8003ee:	57                   	push   %edi
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	8d 35 fa 03 80 00    	lea    0x8003fa,%esi
  8003f8:	0f 34                	sysenter 

008003fa <label_537>:
  8003fa:	89 ec                	mov    %ebp,%esp
  8003fc:	5d                   	pop    %ebp
  8003fd:	5f                   	pop    %edi
  8003fe:	5e                   	pop    %esi
  8003ff:	5b                   	pop    %ebx
  800400:	5a                   	pop    %edx
  800401:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800402:	85 c0                	test   %eax,%eax
  800404:	7e 17                	jle    80041d <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800406:	83 ec 0c             	sub    $0xc,%esp
  800409:	50                   	push   %eax
  80040a:	6a 0d                	push   $0xd
  80040c:	68 18 14 80 00       	push   $0x801418
  800411:	6a 29                	push   $0x29
  800413:	68 35 14 80 00       	push   $0x801435
  800418:	e8 39 00 00 00       	call   800456 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80041d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800420:	5b                   	pop    %ebx
  800421:	5f                   	pop    %edi
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800429:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800433:	8b 55 08             	mov    0x8(%ebp),%edx
  800436:	89 cb                	mov    %ecx,%ebx
  800438:	89 cf                	mov    %ecx,%edi
  80043a:	51                   	push   %ecx
  80043b:	52                   	push   %edx
  80043c:	53                   	push   %ebx
  80043d:	56                   	push   %esi
  80043e:	57                   	push   %edi
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	8d 35 4a 04 80 00    	lea    0x80044a,%esi
  800448:	0f 34                	sysenter 

0080044a <label_586>:
  80044a:	89 ec                	mov    %ebp,%esp
  80044c:	5d                   	pop    %ebp
  80044d:	5f                   	pop    %edi
  80044e:	5e                   	pop    %esi
  80044f:	5b                   	pop    %ebx
  800450:	5a                   	pop    %edx
  800451:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800452:	5b                   	pop    %ebx
  800453:	5f                   	pop    %edi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	56                   	push   %esi
  80045a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80045b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80045e:	a1 14 20 80 00       	mov    0x802014,%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	74 11                	je     800478 <_panic+0x22>
		cprintf("%s: ", argv0);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	50                   	push   %eax
  80046b:	68 43 14 80 00       	push   $0x801443
  800470:	e8 d4 00 00 00       	call   800549 <cprintf>
  800475:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800478:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80047e:	e8 d4 fc ff ff       	call   800157 <sys_getenvid>
  800483:	83 ec 0c             	sub    $0xc,%esp
  800486:	ff 75 0c             	pushl  0xc(%ebp)
  800489:	ff 75 08             	pushl  0x8(%ebp)
  80048c:	56                   	push   %esi
  80048d:	50                   	push   %eax
  80048e:	68 48 14 80 00       	push   $0x801448
  800493:	e8 b1 00 00 00       	call   800549 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800498:	83 c4 18             	add    $0x18,%esp
  80049b:	53                   	push   %ebx
  80049c:	ff 75 10             	pushl  0x10(%ebp)
  80049f:	e8 54 00 00 00       	call   8004f8 <vcprintf>
	cprintf("\n");
  8004a4:	c7 04 24 0c 14 80 00 	movl   $0x80140c,(%esp)
  8004ab:	e8 99 00 00 00       	call   800549 <cprintf>
  8004b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b3:	cc                   	int3   
  8004b4:	eb fd                	jmp    8004b3 <_panic+0x5d>

008004b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	53                   	push   %ebx
  8004ba:	83 ec 04             	sub    $0x4,%esp
  8004bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004c0:	8b 13                	mov    (%ebx),%edx
  8004c2:	8d 42 01             	lea    0x1(%edx),%eax
  8004c5:	89 03                	mov    %eax,(%ebx)
  8004c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004d3:	75 1a                	jne    8004ef <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	68 ff 00 00 00       	push   $0xff
  8004dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e0:	50                   	push   %eax
  8004e1:	e8 c0 fb ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8004e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004f6:	c9                   	leave  
  8004f7:	c3                   	ret    

008004f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800501:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800508:	00 00 00 
	b.cnt = 0;
  80050b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800512:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800515:	ff 75 0c             	pushl  0xc(%ebp)
  800518:	ff 75 08             	pushl  0x8(%ebp)
  80051b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800521:	50                   	push   %eax
  800522:	68 b6 04 80 00       	push   $0x8004b6
  800527:	e8 c0 02 00 00       	call   8007ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052c:	83 c4 08             	add    $0x8,%esp
  80052f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800535:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053b:	50                   	push   %eax
  80053c:	e8 65 fb ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  800541:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800547:	c9                   	leave  
  800548:	c3                   	ret    

00800549 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80054f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800552:	50                   	push   %eax
  800553:	ff 75 08             	pushl  0x8(%ebp)
  800556:	e8 9d ff ff ff       	call   8004f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80055b:	c9                   	leave  
  80055c:	c3                   	ret    

0080055d <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	57                   	push   %edi
  800561:	56                   	push   %esi
  800562:	53                   	push   %ebx
  800563:	83 ec 1c             	sub    $0x1c,%esp
  800566:	89 c7                	mov    %eax,%edi
  800568:	89 d6                	mov    %edx,%esi
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800570:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800573:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800576:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800579:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80057d:	0f 85 bf 00 00 00    	jne    800642 <printnum+0xe5>
  800583:	39 1d 0c 20 80 00    	cmp    %ebx,0x80200c
  800589:	0f 8d de 00 00 00    	jge    80066d <printnum+0x110>
		judge_time_for_space = width;
  80058f:	89 1d 0c 20 80 00    	mov    %ebx,0x80200c
  800595:	e9 d3 00 00 00       	jmp    80066d <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80059a:	83 eb 01             	sub    $0x1,%ebx
  80059d:	85 db                	test   %ebx,%ebx
  80059f:	7f 37                	jg     8005d8 <printnum+0x7b>
  8005a1:	e9 ea 00 00 00       	jmp    800690 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8005a6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8005a9:	a3 08 20 80 00       	mov    %eax,0x802008
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	56                   	push   %esi
  8005b2:	83 ec 04             	sub    $0x4,%esp
  8005b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8005b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8005bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005be:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c1:	e8 ca 0c 00 00       	call   801290 <__umoddi3>
  8005c6:	83 c4 14             	add    $0x14,%esp
  8005c9:	0f be 80 6b 14 80 00 	movsbl 0x80146b(%eax),%eax
  8005d0:	50                   	push   %eax
  8005d1:	ff d7                	call   *%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 16                	jmp    8005ee <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	56                   	push   %esi
  8005dc:	ff 75 18             	pushl  0x18(%ebp)
  8005df:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	83 eb 01             	sub    $0x1,%ebx
  8005e7:	75 ef                	jne    8005d8 <printnum+0x7b>
  8005e9:	e9 a2 00 00 00       	jmp    800690 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005ee:	3b 1d 0c 20 80 00    	cmp    0x80200c,%ebx
  8005f4:	0f 85 76 01 00 00    	jne    800770 <printnum+0x213>
		while(num_of_space-- > 0)
  8005fa:	a1 08 20 80 00       	mov    0x802008,%eax
  8005ff:	8d 50 ff             	lea    -0x1(%eax),%edx
  800602:	89 15 08 20 80 00    	mov    %edx,0x802008
  800608:	85 c0                	test   %eax,%eax
  80060a:	7e 1d                	jle    800629 <printnum+0xcc>
			putch(' ', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	56                   	push   %esi
  800610:	6a 20                	push   $0x20
  800612:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800614:	a1 08 20 80 00       	mov    0x802008,%eax
  800619:	8d 50 ff             	lea    -0x1(%eax),%edx
  80061c:	89 15 08 20 80 00    	mov    %edx,0x802008
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	85 c0                	test   %eax,%eax
  800627:	7f e3                	jg     80060c <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800629:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800630:	00 00 00 
		judge_time_for_space = 0;
  800633:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  80063a:	00 00 00 
	}
}
  80063d:	e9 2e 01 00 00       	jmp    800770 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800642:	8b 45 10             	mov    0x10(%ebp),%eax
  800645:	ba 00 00 00 00       	mov    $0x0,%edx
  80064a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800650:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800653:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800656:	83 fa 00             	cmp    $0x0,%edx
  800659:	0f 87 ba 00 00 00    	ja     800719 <printnum+0x1bc>
  80065f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800662:	0f 83 b1 00 00 00    	jae    800719 <printnum+0x1bc>
  800668:	e9 2d ff ff ff       	jmp    80059a <printnum+0x3d>
  80066d:	8b 45 10             	mov    0x10(%ebp),%eax
  800670:	ba 00 00 00 00       	mov    $0x0,%edx
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800681:	83 fa 00             	cmp    $0x0,%edx
  800684:	77 37                	ja     8006bd <printnum+0x160>
  800686:	3b 45 10             	cmp    0x10(%ebp),%eax
  800689:	73 32                	jae    8006bd <printnum+0x160>
  80068b:	e9 16 ff ff ff       	jmp    8005a6 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	56                   	push   %esi
  800694:	83 ec 04             	sub    $0x4,%esp
  800697:	ff 75 dc             	pushl  -0x24(%ebp)
  80069a:	ff 75 d8             	pushl  -0x28(%ebp)
  80069d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a3:	e8 e8 0b 00 00       	call   801290 <__umoddi3>
  8006a8:	83 c4 14             	add    $0x14,%esp
  8006ab:	0f be 80 6b 14 80 00 	movsbl 0x80146b(%eax),%eax
  8006b2:	50                   	push   %eax
  8006b3:	ff d7                	call   *%edi
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	e9 b3 00 00 00       	jmp    800770 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	ff 75 18             	pushl  0x18(%ebp)
  8006c3:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006c6:	50                   	push   %eax
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8006d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d9:	e8 82 0a 00 00       	call   801160 <__udivdi3>
  8006de:	83 c4 18             	add    $0x18,%esp
  8006e1:	52                   	push   %edx
  8006e2:	50                   	push   %eax
  8006e3:	89 f2                	mov    %esi,%edx
  8006e5:	89 f8                	mov    %edi,%eax
  8006e7:	e8 71 fe ff ff       	call   80055d <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006ec:	83 c4 18             	add    $0x18,%esp
  8006ef:	56                   	push   %esi
  8006f0:	83 ec 04             	sub    $0x4,%esp
  8006f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8006f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ff:	e8 8c 0b 00 00       	call   801290 <__umoddi3>
  800704:	83 c4 14             	add    $0x14,%esp
  800707:	0f be 80 6b 14 80 00 	movsbl 0x80146b(%eax),%eax
  80070e:	50                   	push   %eax
  80070f:	ff d7                	call   *%edi
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	e9 d5 fe ff ff       	jmp    8005ee <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	ff 75 18             	pushl  0x18(%ebp)
  80071f:	83 eb 01             	sub    $0x1,%ebx
  800722:	53                   	push   %ebx
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	ff 75 dc             	pushl  -0x24(%ebp)
  80072c:	ff 75 d8             	pushl  -0x28(%ebp)
  80072f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800732:	ff 75 e0             	pushl  -0x20(%ebp)
  800735:	e8 26 0a 00 00       	call   801160 <__udivdi3>
  80073a:	83 c4 18             	add    $0x18,%esp
  80073d:	52                   	push   %edx
  80073e:	50                   	push   %eax
  80073f:	89 f2                	mov    %esi,%edx
  800741:	89 f8                	mov    %edi,%eax
  800743:	e8 15 fe ff ff       	call   80055d <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800748:	83 c4 18             	add    $0x18,%esp
  80074b:	56                   	push   %esi
  80074c:	83 ec 04             	sub    $0x4,%esp
  80074f:	ff 75 dc             	pushl  -0x24(%ebp)
  800752:	ff 75 d8             	pushl  -0x28(%ebp)
  800755:	ff 75 e4             	pushl  -0x1c(%ebp)
  800758:	ff 75 e0             	pushl  -0x20(%ebp)
  80075b:	e8 30 0b 00 00       	call   801290 <__umoddi3>
  800760:	83 c4 14             	add    $0x14,%esp
  800763:	0f be 80 6b 14 80 00 	movsbl 0x80146b(%eax),%eax
  80076a:	50                   	push   %eax
  80076b:	ff d7                	call   *%edi
  80076d:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80077b:	83 fa 01             	cmp    $0x1,%edx
  80077e:	7e 0e                	jle    80078e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800780:	8b 10                	mov    (%eax),%edx
  800782:	8d 4a 08             	lea    0x8(%edx),%ecx
  800785:	89 08                	mov    %ecx,(%eax)
  800787:	8b 02                	mov    (%edx),%eax
  800789:	8b 52 04             	mov    0x4(%edx),%edx
  80078c:	eb 22                	jmp    8007b0 <getuint+0x38>
	else if (lflag)
  80078e:	85 d2                	test   %edx,%edx
  800790:	74 10                	je     8007a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800792:	8b 10                	mov    (%eax),%edx
  800794:	8d 4a 04             	lea    0x4(%edx),%ecx
  800797:	89 08                	mov    %ecx,(%eax)
  800799:	8b 02                	mov    (%edx),%eax
  80079b:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a0:	eb 0e                	jmp    8007b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 02                	mov    (%edx),%eax
  8007ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	3b 50 04             	cmp    0x4(%eax),%edx
  8007c1:	73 0a                	jae    8007cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8007c3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007c6:	89 08                	mov    %ecx,(%eax)
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	88 02                	mov    %al,(%edx)
}
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007d8:	50                   	push   %eax
  8007d9:	ff 75 10             	pushl  0x10(%ebp)
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	ff 75 08             	pushl  0x8(%ebp)
  8007e2:	e8 05 00 00 00       	call   8007ec <vprintfmt>
	va_end(ap);
}
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	57                   	push   %edi
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	83 ec 2c             	sub    $0x2c,%esp
  8007f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007fb:	eb 03                	jmp    800800 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fd:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800800:	8b 45 10             	mov    0x10(%ebp),%eax
  800803:	8d 70 01             	lea    0x1(%eax),%esi
  800806:	0f b6 00             	movzbl (%eax),%eax
  800809:	83 f8 25             	cmp    $0x25,%eax
  80080c:	74 27                	je     800835 <vprintfmt+0x49>
			if (ch == '\0')
  80080e:	85 c0                	test   %eax,%eax
  800810:	75 0d                	jne    80081f <vprintfmt+0x33>
  800812:	e9 9d 04 00 00       	jmp    800cb4 <vprintfmt+0x4c8>
  800817:	85 c0                	test   %eax,%eax
  800819:	0f 84 95 04 00 00    	je     800cb4 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	50                   	push   %eax
  800824:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800826:	83 c6 01             	add    $0x1,%esi
  800829:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	83 f8 25             	cmp    $0x25,%eax
  800833:	75 e2                	jne    800817 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800835:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80083e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800845:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80084c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800853:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80085a:	eb 08                	jmp    800864 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085c:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80085f:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800864:	8d 46 01             	lea    0x1(%esi),%eax
  800867:	89 45 10             	mov    %eax,0x10(%ebp)
  80086a:	0f b6 06             	movzbl (%esi),%eax
  80086d:	0f b6 d0             	movzbl %al,%edx
  800870:	83 e8 23             	sub    $0x23,%eax
  800873:	3c 55                	cmp    $0x55,%al
  800875:	0f 87 fa 03 00 00    	ja     800c75 <vprintfmt+0x489>
  80087b:	0f b6 c0             	movzbl %al,%eax
  80087e:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
  800885:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800888:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80088c:	eb d6                	jmp    800864 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088e:	8d 42 d0             	lea    -0x30(%edx),%eax
  800891:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800894:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800898:	8d 50 d0             	lea    -0x30(%eax),%edx
  80089b:	83 fa 09             	cmp    $0x9,%edx
  80089e:	77 6b                	ja     80090b <vprintfmt+0x11f>
  8008a0:	8b 75 10             	mov    0x10(%ebp),%esi
  8008a3:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8008a9:	eb 09                	jmp    8008b4 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ab:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008ae:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008b2:	eb b0                	jmp    800864 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008b4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008b7:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008ba:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008be:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008c1:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008c4:	83 f9 09             	cmp    $0x9,%ecx
  8008c7:	76 eb                	jbe    8008b4 <vprintfmt+0xc8>
  8008c9:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008cc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008cf:	eb 3d                	jmp    80090e <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d4:	8d 50 04             	lea    0x4(%eax),%edx
  8008d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008da:	8b 00                	mov    (%eax),%eax
  8008dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008df:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008e2:	eb 2a                	jmp    80090e <vprintfmt+0x122>
  8008e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ee:	0f 49 d0             	cmovns %eax,%edx
  8008f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f4:	8b 75 10             	mov    0x10(%ebp),%esi
  8008f7:	e9 68 ff ff ff       	jmp    800864 <vprintfmt+0x78>
  8008fc:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ff:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800906:	e9 59 ff ff ff       	jmp    800864 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80090e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800912:	0f 89 4c ff ff ff    	jns    800864 <vprintfmt+0x78>
				width = precision, precision = -1;
  800918:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80091b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800925:	e9 3a ff ff ff       	jmp    800864 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80092a:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092e:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800931:	e9 2e ff ff ff       	jmp    800864 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800936:	8b 45 14             	mov    0x14(%ebp),%eax
  800939:	8d 50 04             	lea    0x4(%eax),%edx
  80093c:	89 55 14             	mov    %edx,0x14(%ebp)
  80093f:	83 ec 08             	sub    $0x8,%esp
  800942:	53                   	push   %ebx
  800943:	ff 30                	pushl  (%eax)
  800945:	ff d7                	call   *%edi
			break;
  800947:	83 c4 10             	add    $0x10,%esp
  80094a:	e9 b1 fe ff ff       	jmp    800800 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8d 50 04             	lea    0x4(%eax),%edx
  800955:	89 55 14             	mov    %edx,0x14(%ebp)
  800958:	8b 00                	mov    (%eax),%eax
  80095a:	99                   	cltd   
  80095b:	31 d0                	xor    %edx,%eax
  80095d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80095f:	83 f8 08             	cmp    $0x8,%eax
  800962:	7f 0b                	jg     80096f <vprintfmt+0x183>
  800964:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  80096b:	85 d2                	test   %edx,%edx
  80096d:	75 15                	jne    800984 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80096f:	50                   	push   %eax
  800970:	68 83 14 80 00       	push   $0x801483
  800975:	53                   	push   %ebx
  800976:	57                   	push   %edi
  800977:	e8 53 fe ff ff       	call   8007cf <printfmt>
  80097c:	83 c4 10             	add    $0x10,%esp
  80097f:	e9 7c fe ff ff       	jmp    800800 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800984:	52                   	push   %edx
  800985:	68 8c 14 80 00       	push   $0x80148c
  80098a:	53                   	push   %ebx
  80098b:	57                   	push   %edi
  80098c:	e8 3e fe ff ff       	call   8007cf <printfmt>
  800991:	83 c4 10             	add    $0x10,%esp
  800994:	e9 67 fe ff ff       	jmp    800800 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800999:	8b 45 14             	mov    0x14(%ebp),%eax
  80099c:	8d 50 04             	lea    0x4(%eax),%edx
  80099f:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a2:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	b9 7c 14 80 00       	mov    $0x80147c,%ecx
  8009ab:	0f 45 c8             	cmovne %eax,%ecx
  8009ae:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009b5:	7e 06                	jle    8009bd <vprintfmt+0x1d1>
  8009b7:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009bb:	75 19                	jne    8009d6 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009c0:	8d 70 01             	lea    0x1(%eax),%esi
  8009c3:	0f b6 00             	movzbl (%eax),%eax
  8009c6:	0f be d0             	movsbl %al,%edx
  8009c9:	85 d2                	test   %edx,%edx
  8009cb:	0f 85 9f 00 00 00    	jne    800a70 <vprintfmt+0x284>
  8009d1:	e9 8c 00 00 00       	jmp    800a62 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8009dc:	ff 75 cc             	pushl  -0x34(%ebp)
  8009df:	e8 62 03 00 00       	call   800d46 <strnlen>
  8009e4:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009e7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009ea:	83 c4 10             	add    $0x10,%esp
  8009ed:	85 c9                	test   %ecx,%ecx
  8009ef:	0f 8e a6 02 00 00    	jle    800c9b <vprintfmt+0x4af>
					putch(padc, putdat);
  8009f5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009fc:	89 cb                	mov    %ecx,%ebx
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	ff 75 0c             	pushl  0xc(%ebp)
  800a04:	56                   	push   %esi
  800a05:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a07:	83 c4 10             	add    $0x10,%esp
  800a0a:	83 eb 01             	sub    $0x1,%ebx
  800a0d:	75 ef                	jne    8009fe <vprintfmt+0x212>
  800a0f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a15:	e9 81 02 00 00       	jmp    800c9b <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a1e:	74 1b                	je     800a3b <vprintfmt+0x24f>
  800a20:	0f be c0             	movsbl %al,%eax
  800a23:	83 e8 20             	sub    $0x20,%eax
  800a26:	83 f8 5e             	cmp    $0x5e,%eax
  800a29:	76 10                	jbe    800a3b <vprintfmt+0x24f>
					putch('?', putdat);
  800a2b:	83 ec 08             	sub    $0x8,%esp
  800a2e:	ff 75 0c             	pushl  0xc(%ebp)
  800a31:	6a 3f                	push   $0x3f
  800a33:	ff 55 08             	call   *0x8(%ebp)
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	eb 0d                	jmp    800a48 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a3b:	83 ec 08             	sub    $0x8,%esp
  800a3e:	ff 75 0c             	pushl  0xc(%ebp)
  800a41:	52                   	push   %edx
  800a42:	ff 55 08             	call   *0x8(%ebp)
  800a45:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a48:	83 ef 01             	sub    $0x1,%edi
  800a4b:	83 c6 01             	add    $0x1,%esi
  800a4e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a52:	0f be d0             	movsbl %al,%edx
  800a55:	85 d2                	test   %edx,%edx
  800a57:	75 31                	jne    800a8a <vprintfmt+0x29e>
  800a59:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a62:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a65:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a69:	7f 33                	jg     800a9e <vprintfmt+0x2b2>
  800a6b:	e9 90 fd ff ff       	jmp    800800 <vprintfmt+0x14>
  800a70:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a76:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a79:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a7c:	eb 0c                	jmp    800a8a <vprintfmt+0x29e>
  800a7e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a84:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a87:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	78 8c                	js     800a1a <vprintfmt+0x22e>
  800a8e:	83 eb 01             	sub    $0x1,%ebx
  800a91:	79 87                	jns    800a1a <vprintfmt+0x22e>
  800a93:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a96:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9c:	eb c4                	jmp    800a62 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a9e:	83 ec 08             	sub    $0x8,%esp
  800aa1:	53                   	push   %ebx
  800aa2:	6a 20                	push   $0x20
  800aa4:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	83 ee 01             	sub    $0x1,%esi
  800aac:	75 f0                	jne    800a9e <vprintfmt+0x2b2>
  800aae:	e9 4d fd ff ff       	jmp    800800 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ab3:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800ab7:	7e 16                	jle    800acf <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800ab9:	8b 45 14             	mov    0x14(%ebp),%eax
  800abc:	8d 50 08             	lea    0x8(%eax),%edx
  800abf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac2:	8b 50 04             	mov    0x4(%eax),%edx
  800ac5:	8b 00                	mov    (%eax),%eax
  800ac7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800aca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800acd:	eb 34                	jmp    800b03 <vprintfmt+0x317>
	else if (lflag)
  800acf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ad3:	74 18                	je     800aed <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ad5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad8:	8d 50 04             	lea    0x4(%eax),%edx
  800adb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ade:	8b 30                	mov    (%eax),%esi
  800ae0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ae3:	89 f0                	mov    %esi,%eax
  800ae5:	c1 f8 1f             	sar    $0x1f,%eax
  800ae8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800aeb:	eb 16                	jmp    800b03 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800aed:	8b 45 14             	mov    0x14(%ebp),%eax
  800af0:	8d 50 04             	lea    0x4(%eax),%edx
  800af3:	89 55 14             	mov    %edx,0x14(%ebp)
  800af6:	8b 30                	mov    (%eax),%esi
  800af8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800afb:	89 f0                	mov    %esi,%eax
  800afd:	c1 f8 1f             	sar    $0x1f,%eax
  800b00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b03:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b06:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b09:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b0c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b0f:	85 d2                	test   %edx,%edx
  800b11:	79 28                	jns    800b3b <vprintfmt+0x34f>
				putch('-', putdat);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	53                   	push   %ebx
  800b17:	6a 2d                	push   $0x2d
  800b19:	ff d7                	call   *%edi
				num = -(long long) num;
  800b1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b1e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b21:	f7 d8                	neg    %eax
  800b23:	83 d2 00             	adc    $0x0,%edx
  800b26:	f7 da                	neg    %edx
  800b28:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b2b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b2e:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b36:	e9 b2 00 00 00       	jmp    800bed <vprintfmt+0x401>
  800b3b:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b40:	85 c9                	test   %ecx,%ecx
  800b42:	0f 84 a5 00 00 00    	je     800bed <vprintfmt+0x401>
				putch('+', putdat);
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	53                   	push   %ebx
  800b4c:	6a 2b                	push   $0x2b
  800b4e:	ff d7                	call   *%edi
  800b50:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b58:	e9 90 00 00 00       	jmp    800bed <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b5d:	85 c9                	test   %ecx,%ecx
  800b5f:	74 0b                	je     800b6c <vprintfmt+0x380>
				putch('+', putdat);
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	53                   	push   %ebx
  800b65:	6a 2b                	push   $0x2b
  800b67:	ff d7                	call   *%edi
  800b69:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b6c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b6f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b72:	e8 01 fc ff ff       	call   800778 <getuint>
  800b77:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b7a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b7d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b82:	eb 69                	jmp    800bed <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b84:	83 ec 08             	sub    $0x8,%esp
  800b87:	53                   	push   %ebx
  800b88:	6a 30                	push   $0x30
  800b8a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b8c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b8f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b92:	e8 e1 fb ff ff       	call   800778 <getuint>
  800b97:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b9a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b9d:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800ba0:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800ba5:	eb 46                	jmp    800bed <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800ba7:	83 ec 08             	sub    $0x8,%esp
  800baa:	53                   	push   %ebx
  800bab:	6a 30                	push   $0x30
  800bad:	ff d7                	call   *%edi
			putch('x', putdat);
  800baf:	83 c4 08             	add    $0x8,%esp
  800bb2:	53                   	push   %ebx
  800bb3:	6a 78                	push   $0x78
  800bb5:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bba:	8d 50 04             	lea    0x4(%eax),%edx
  800bbd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bc0:	8b 00                	mov    (%eax),%eax
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bca:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bcd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bd0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bd5:	eb 16                	jmp    800bed <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bd7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bda:	8d 45 14             	lea    0x14(%ebp),%eax
  800bdd:	e8 96 fb ff ff       	call   800778 <getuint>
  800be2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800be5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800be8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bf4:	56                   	push   %esi
  800bf5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bf8:	50                   	push   %eax
  800bf9:	ff 75 dc             	pushl  -0x24(%ebp)
  800bfc:	ff 75 d8             	pushl  -0x28(%ebp)
  800bff:	89 da                	mov    %ebx,%edx
  800c01:	89 f8                	mov    %edi,%eax
  800c03:	e8 55 f9 ff ff       	call   80055d <printnum>
			break;
  800c08:	83 c4 20             	add    $0x20,%esp
  800c0b:	e9 f0 fb ff ff       	jmp    800800 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c10:	8b 45 14             	mov    0x14(%ebp),%eax
  800c13:	8d 50 04             	lea    0x4(%eax),%edx
  800c16:	89 55 14             	mov    %edx,0x14(%ebp)
  800c19:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c1b:	85 f6                	test   %esi,%esi
  800c1d:	75 1a                	jne    800c39 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c1f:	83 ec 08             	sub    $0x8,%esp
  800c22:	68 24 15 80 00       	push   $0x801524
  800c27:	68 8c 14 80 00       	push   $0x80148c
  800c2c:	e8 18 f9 ff ff       	call   800549 <cprintf>
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	e9 c7 fb ff ff       	jmp    800800 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c39:	0f b6 03             	movzbl (%ebx),%eax
  800c3c:	84 c0                	test   %al,%al
  800c3e:	79 1f                	jns    800c5f <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c40:	83 ec 08             	sub    $0x8,%esp
  800c43:	68 5c 15 80 00       	push   $0x80155c
  800c48:	68 8c 14 80 00       	push   $0x80148c
  800c4d:	e8 f7 f8 ff ff       	call   800549 <cprintf>
						*tmp = *(char *)putdat;
  800c52:	0f b6 03             	movzbl (%ebx),%eax
  800c55:	88 06                	mov    %al,(%esi)
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	e9 a1 fb ff ff       	jmp    800800 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c5f:	88 06                	mov    %al,(%esi)
  800c61:	e9 9a fb ff ff       	jmp    800800 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c66:	83 ec 08             	sub    $0x8,%esp
  800c69:	53                   	push   %ebx
  800c6a:	52                   	push   %edx
  800c6b:	ff d7                	call   *%edi
			break;
  800c6d:	83 c4 10             	add    $0x10,%esp
  800c70:	e9 8b fb ff ff       	jmp    800800 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c75:	83 ec 08             	sub    $0x8,%esp
  800c78:	53                   	push   %ebx
  800c79:	6a 25                	push   $0x25
  800c7b:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c7d:	83 c4 10             	add    $0x10,%esp
  800c80:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c84:	0f 84 73 fb ff ff    	je     8007fd <vprintfmt+0x11>
  800c8a:	83 ee 01             	sub    $0x1,%esi
  800c8d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c91:	75 f7                	jne    800c8a <vprintfmt+0x49e>
  800c93:	89 75 10             	mov    %esi,0x10(%ebp)
  800c96:	e9 65 fb ff ff       	jmp    800800 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c9b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c9e:	8d 70 01             	lea    0x1(%eax),%esi
  800ca1:	0f b6 00             	movzbl (%eax),%eax
  800ca4:	0f be d0             	movsbl %al,%edx
  800ca7:	85 d2                	test   %edx,%edx
  800ca9:	0f 85 cf fd ff ff    	jne    800a7e <vprintfmt+0x292>
  800caf:	e9 4c fb ff ff       	jmp    800800 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 18             	sub    $0x18,%esp
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ccb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ccf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	74 26                	je     800d03 <vsnprintf+0x47>
  800cdd:	85 d2                	test   %edx,%edx
  800cdf:	7e 22                	jle    800d03 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ce1:	ff 75 14             	pushl  0x14(%ebp)
  800ce4:	ff 75 10             	pushl  0x10(%ebp)
  800ce7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cea:	50                   	push   %eax
  800ceb:	68 b2 07 80 00       	push   $0x8007b2
  800cf0:	e8 f7 fa ff ff       	call   8007ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cf8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cfe:	83 c4 10             	add    $0x10,%esp
  800d01:	eb 05                	jmp    800d08 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d10:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d13:	50                   	push   %eax
  800d14:	ff 75 10             	pushl  0x10(%ebp)
  800d17:	ff 75 0c             	pushl  0xc(%ebp)
  800d1a:	ff 75 08             	pushl  0x8(%ebp)
  800d1d:	e8 9a ff ff ff       	call   800cbc <vsnprintf>
	va_end(ap);

	return rc;
}
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d2a:	80 3a 00             	cmpb   $0x0,(%edx)
  800d2d:	74 10                	je     800d3f <strlen+0x1b>
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d34:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d37:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d3b:	75 f7                	jne    800d34 <strlen+0x10>
  800d3d:	eb 05                	jmp    800d44 <strlen+0x20>
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	53                   	push   %ebx
  800d4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d50:	85 c9                	test   %ecx,%ecx
  800d52:	74 1c                	je     800d70 <strnlen+0x2a>
  800d54:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d57:	74 1e                	je     800d77 <strnlen+0x31>
  800d59:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d5e:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d60:	39 ca                	cmp    %ecx,%edx
  800d62:	74 18                	je     800d7c <strnlen+0x36>
  800d64:	83 c2 01             	add    $0x1,%edx
  800d67:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d6c:	75 f0                	jne    800d5e <strnlen+0x18>
  800d6e:	eb 0c                	jmp    800d7c <strnlen+0x36>
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
  800d75:	eb 05                	jmp    800d7c <strnlen+0x36>
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	53                   	push   %ebx
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	83 c2 01             	add    $0x1,%edx
  800d8e:	83 c1 01             	add    $0x1,%ecx
  800d91:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d95:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d98:	84 db                	test   %bl,%bl
  800d9a:	75 ef                	jne    800d8b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	53                   	push   %ebx
  800da3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800da6:	53                   	push   %ebx
  800da7:	e8 78 ff ff ff       	call   800d24 <strlen>
  800dac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800daf:	ff 75 0c             	pushl  0xc(%ebp)
  800db2:	01 d8                	add    %ebx,%eax
  800db4:	50                   	push   %eax
  800db5:	e8 c5 ff ff ff       	call   800d7f <strcpy>
	return dst;
}
  800dba:	89 d8                	mov    %ebx,%eax
  800dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dcf:	85 db                	test   %ebx,%ebx
  800dd1:	74 17                	je     800dea <strncpy+0x29>
  800dd3:	01 f3                	add    %esi,%ebx
  800dd5:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dd7:	83 c1 01             	add    $0x1,%ecx
  800dda:	0f b6 02             	movzbl (%edx),%eax
  800ddd:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800de0:	80 3a 01             	cmpb   $0x1,(%edx)
  800de3:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de6:	39 cb                	cmp    %ecx,%ebx
  800de8:	75 ed                	jne    800dd7 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dea:	89 f0                	mov    %esi,%eax
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
  800df5:	8b 75 08             	mov    0x8(%ebp),%esi
  800df8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dfb:	8b 55 10             	mov    0x10(%ebp),%edx
  800dfe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e00:	85 d2                	test   %edx,%edx
  800e02:	74 35                	je     800e39 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800e04:	89 d0                	mov    %edx,%eax
  800e06:	83 e8 01             	sub    $0x1,%eax
  800e09:	74 25                	je     800e30 <strlcpy+0x40>
  800e0b:	0f b6 0b             	movzbl (%ebx),%ecx
  800e0e:	84 c9                	test   %cl,%cl
  800e10:	74 22                	je     800e34 <strlcpy+0x44>
  800e12:	8d 53 01             	lea    0x1(%ebx),%edx
  800e15:	01 c3                	add    %eax,%ebx
  800e17:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e19:	83 c0 01             	add    $0x1,%eax
  800e1c:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e1f:	39 da                	cmp    %ebx,%edx
  800e21:	74 13                	je     800e36 <strlcpy+0x46>
  800e23:	83 c2 01             	add    $0x1,%edx
  800e26:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e2a:	84 c9                	test   %cl,%cl
  800e2c:	75 eb                	jne    800e19 <strlcpy+0x29>
  800e2e:	eb 06                	jmp    800e36 <strlcpy+0x46>
  800e30:	89 f0                	mov    %esi,%eax
  800e32:	eb 02                	jmp    800e36 <strlcpy+0x46>
  800e34:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e36:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e39:	29 f0                	sub    %esi,%eax
}
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e48:	0f b6 01             	movzbl (%ecx),%eax
  800e4b:	84 c0                	test   %al,%al
  800e4d:	74 15                	je     800e64 <strcmp+0x25>
  800e4f:	3a 02                	cmp    (%edx),%al
  800e51:	75 11                	jne    800e64 <strcmp+0x25>
		p++, q++;
  800e53:	83 c1 01             	add    $0x1,%ecx
  800e56:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e59:	0f b6 01             	movzbl (%ecx),%eax
  800e5c:	84 c0                	test   %al,%al
  800e5e:	74 04                	je     800e64 <strcmp+0x25>
  800e60:	3a 02                	cmp    (%edx),%al
  800e62:	74 ef                	je     800e53 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e64:	0f b6 c0             	movzbl %al,%eax
  800e67:	0f b6 12             	movzbl (%edx),%edx
  800e6a:	29 d0                	sub    %edx,%eax
}
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
  800e73:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e79:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e7c:	85 f6                	test   %esi,%esi
  800e7e:	74 29                	je     800ea9 <strncmp+0x3b>
  800e80:	0f b6 03             	movzbl (%ebx),%eax
  800e83:	84 c0                	test   %al,%al
  800e85:	74 30                	je     800eb7 <strncmp+0x49>
  800e87:	3a 02                	cmp    (%edx),%al
  800e89:	75 2c                	jne    800eb7 <strncmp+0x49>
  800e8b:	8d 43 01             	lea    0x1(%ebx),%eax
  800e8e:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e95:	39 c6                	cmp    %eax,%esi
  800e97:	74 17                	je     800eb0 <strncmp+0x42>
  800e99:	0f b6 08             	movzbl (%eax),%ecx
  800e9c:	84 c9                	test   %cl,%cl
  800e9e:	74 17                	je     800eb7 <strncmp+0x49>
  800ea0:	83 c0 01             	add    $0x1,%eax
  800ea3:	3a 0a                	cmp    (%edx),%cl
  800ea5:	74 e9                	je     800e90 <strncmp+0x22>
  800ea7:	eb 0e                	jmp    800eb7 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	eb 0f                	jmp    800ebf <strncmp+0x51>
  800eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb5:	eb 08                	jmp    800ebf <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800eb7:	0f b6 03             	movzbl (%ebx),%eax
  800eba:	0f b6 12             	movzbl (%edx),%edx
  800ebd:	29 d0                	sub    %edx,%eax
}
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	53                   	push   %ebx
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ecd:	0f b6 10             	movzbl (%eax),%edx
  800ed0:	84 d2                	test   %dl,%dl
  800ed2:	74 1d                	je     800ef1 <strchr+0x2e>
  800ed4:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ed6:	38 d3                	cmp    %dl,%bl
  800ed8:	75 06                	jne    800ee0 <strchr+0x1d>
  800eda:	eb 1a                	jmp    800ef6 <strchr+0x33>
  800edc:	38 ca                	cmp    %cl,%dl
  800ede:	74 16                	je     800ef6 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ee0:	83 c0 01             	add    $0x1,%eax
  800ee3:	0f b6 10             	movzbl (%eax),%edx
  800ee6:	84 d2                	test   %dl,%dl
  800ee8:	75 f2                	jne    800edc <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	eb 05                	jmp    800ef6 <strchr+0x33>
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef6:	5b                   	pop    %ebx
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	53                   	push   %ebx
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800f03:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800f06:	38 d3                	cmp    %dl,%bl
  800f08:	74 14                	je     800f1e <strfind+0x25>
  800f0a:	89 d1                	mov    %edx,%ecx
  800f0c:	84 db                	test   %bl,%bl
  800f0e:	74 0e                	je     800f1e <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f10:	83 c0 01             	add    $0x1,%eax
  800f13:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f16:	38 ca                	cmp    %cl,%dl
  800f18:	74 04                	je     800f1e <strfind+0x25>
  800f1a:	84 d2                	test   %dl,%dl
  800f1c:	75 f2                	jne    800f10 <strfind+0x17>
			break;
	return (char *) s;
}
  800f1e:	5b                   	pop    %ebx
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f2d:	85 c9                	test   %ecx,%ecx
  800f2f:	74 36                	je     800f67 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f37:	75 28                	jne    800f61 <memset+0x40>
  800f39:	f6 c1 03             	test   $0x3,%cl
  800f3c:	75 23                	jne    800f61 <memset+0x40>
		c &= 0xFF;
  800f3e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f42:	89 d3                	mov    %edx,%ebx
  800f44:	c1 e3 08             	shl    $0x8,%ebx
  800f47:	89 d6                	mov    %edx,%esi
  800f49:	c1 e6 18             	shl    $0x18,%esi
  800f4c:	89 d0                	mov    %edx,%eax
  800f4e:	c1 e0 10             	shl    $0x10,%eax
  800f51:	09 f0                	or     %esi,%eax
  800f53:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f55:	89 d8                	mov    %ebx,%eax
  800f57:	09 d0                	or     %edx,%eax
  800f59:	c1 e9 02             	shr    $0x2,%ecx
  800f5c:	fc                   	cld    
  800f5d:	f3 ab                	rep stos %eax,%es:(%edi)
  800f5f:	eb 06                	jmp    800f67 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f64:	fc                   	cld    
  800f65:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f67:	89 f8                	mov    %edi,%eax
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f7c:	39 c6                	cmp    %eax,%esi
  800f7e:	73 35                	jae    800fb5 <memmove+0x47>
  800f80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f83:	39 d0                	cmp    %edx,%eax
  800f85:	73 2e                	jae    800fb5 <memmove+0x47>
		s += n;
		d += n;
  800f87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f8a:	89 d6                	mov    %edx,%esi
  800f8c:	09 fe                	or     %edi,%esi
  800f8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f94:	75 13                	jne    800fa9 <memmove+0x3b>
  800f96:	f6 c1 03             	test   $0x3,%cl
  800f99:	75 0e                	jne    800fa9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f9b:	83 ef 04             	sub    $0x4,%edi
  800f9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fa1:	c1 e9 02             	shr    $0x2,%ecx
  800fa4:	fd                   	std    
  800fa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fa7:	eb 09                	jmp    800fb2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fa9:	83 ef 01             	sub    $0x1,%edi
  800fac:	8d 72 ff             	lea    -0x1(%edx),%esi
  800faf:	fd                   	std    
  800fb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fb2:	fc                   	cld    
  800fb3:	eb 1d                	jmp    800fd2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fb5:	89 f2                	mov    %esi,%edx
  800fb7:	09 c2                	or     %eax,%edx
  800fb9:	f6 c2 03             	test   $0x3,%dl
  800fbc:	75 0f                	jne    800fcd <memmove+0x5f>
  800fbe:	f6 c1 03             	test   $0x3,%cl
  800fc1:	75 0a                	jne    800fcd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fc3:	c1 e9 02             	shr    $0x2,%ecx
  800fc6:	89 c7                	mov    %eax,%edi
  800fc8:	fc                   	cld    
  800fc9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fcb:	eb 05                	jmp    800fd2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fcd:	89 c7                	mov    %eax,%edi
  800fcf:	fc                   	cld    
  800fd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fd9:	ff 75 10             	pushl  0x10(%ebp)
  800fdc:	ff 75 0c             	pushl  0xc(%ebp)
  800fdf:	ff 75 08             	pushl  0x8(%ebp)
  800fe2:	e8 87 ff ff ff       	call   800f6e <memmove>
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ff2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ff5:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	74 39                	je     801035 <memcmp+0x4c>
  800ffc:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800fff:	0f b6 13             	movzbl (%ebx),%edx
  801002:	0f b6 0e             	movzbl (%esi),%ecx
  801005:	38 ca                	cmp    %cl,%dl
  801007:	75 17                	jne    801020 <memcmp+0x37>
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
  80100e:	eb 1a                	jmp    80102a <memcmp+0x41>
  801010:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  801015:	83 c0 01             	add    $0x1,%eax
  801018:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  80101c:	38 ca                	cmp    %cl,%dl
  80101e:	74 0a                	je     80102a <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801020:	0f b6 c2             	movzbl %dl,%eax
  801023:	0f b6 c9             	movzbl %cl,%ecx
  801026:	29 c8                	sub    %ecx,%eax
  801028:	eb 10                	jmp    80103a <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80102a:	39 f8                	cmp    %edi,%eax
  80102c:	75 e2                	jne    801010 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80102e:	b8 00 00 00 00       	mov    $0x0,%eax
  801033:	eb 05                	jmp    80103a <memcmp+0x51>
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	53                   	push   %ebx
  801043:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801046:	89 d0                	mov    %edx,%eax
  801048:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80104b:	39 c2                	cmp    %eax,%edx
  80104d:	73 1d                	jae    80106c <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80104f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801053:	0f b6 0a             	movzbl (%edx),%ecx
  801056:	39 d9                	cmp    %ebx,%ecx
  801058:	75 09                	jne    801063 <memfind+0x24>
  80105a:	eb 14                	jmp    801070 <memfind+0x31>
  80105c:	0f b6 0a             	movzbl (%edx),%ecx
  80105f:	39 d9                	cmp    %ebx,%ecx
  801061:	74 11                	je     801074 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801063:	83 c2 01             	add    $0x1,%edx
  801066:	39 d0                	cmp    %edx,%eax
  801068:	75 f2                	jne    80105c <memfind+0x1d>
  80106a:	eb 0a                	jmp    801076 <memfind+0x37>
  80106c:	89 d0                	mov    %edx,%eax
  80106e:	eb 06                	jmp    801076 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801070:	89 d0                	mov    %edx,%eax
  801072:	eb 02                	jmp    801076 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801074:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801076:	5b                   	pop    %ebx
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801082:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801085:	0f b6 01             	movzbl (%ecx),%eax
  801088:	3c 20                	cmp    $0x20,%al
  80108a:	74 04                	je     801090 <strtol+0x17>
  80108c:	3c 09                	cmp    $0x9,%al
  80108e:	75 0e                	jne    80109e <strtol+0x25>
		s++;
  801090:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801093:	0f b6 01             	movzbl (%ecx),%eax
  801096:	3c 20                	cmp    $0x20,%al
  801098:	74 f6                	je     801090 <strtol+0x17>
  80109a:	3c 09                	cmp    $0x9,%al
  80109c:	74 f2                	je     801090 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80109e:	3c 2b                	cmp    $0x2b,%al
  8010a0:	75 0a                	jne    8010ac <strtol+0x33>
		s++;
  8010a2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010a5:	bf 00 00 00 00       	mov    $0x0,%edi
  8010aa:	eb 11                	jmp    8010bd <strtol+0x44>
  8010ac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010b1:	3c 2d                	cmp    $0x2d,%al
  8010b3:	75 08                	jne    8010bd <strtol+0x44>
		s++, neg = 1;
  8010b5:	83 c1 01             	add    $0x1,%ecx
  8010b8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010c3:	75 15                	jne    8010da <strtol+0x61>
  8010c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8010c8:	75 10                	jne    8010da <strtol+0x61>
  8010ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010ce:	75 7c                	jne    80114c <strtol+0xd3>
		s += 2, base = 16;
  8010d0:	83 c1 02             	add    $0x2,%ecx
  8010d3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010d8:	eb 16                	jmp    8010f0 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010da:	85 db                	test   %ebx,%ebx
  8010dc:	75 12                	jne    8010f0 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010de:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8010e6:	75 08                	jne    8010f0 <strtol+0x77>
		s++, base = 8;
  8010e8:	83 c1 01             	add    $0x1,%ecx
  8010eb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010f8:	0f b6 11             	movzbl (%ecx),%edx
  8010fb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010fe:	89 f3                	mov    %esi,%ebx
  801100:	80 fb 09             	cmp    $0x9,%bl
  801103:	77 08                	ja     80110d <strtol+0x94>
			dig = *s - '0';
  801105:	0f be d2             	movsbl %dl,%edx
  801108:	83 ea 30             	sub    $0x30,%edx
  80110b:	eb 22                	jmp    80112f <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  80110d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801110:	89 f3                	mov    %esi,%ebx
  801112:	80 fb 19             	cmp    $0x19,%bl
  801115:	77 08                	ja     80111f <strtol+0xa6>
			dig = *s - 'a' + 10;
  801117:	0f be d2             	movsbl %dl,%edx
  80111a:	83 ea 57             	sub    $0x57,%edx
  80111d:	eb 10                	jmp    80112f <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  80111f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801122:	89 f3                	mov    %esi,%ebx
  801124:	80 fb 19             	cmp    $0x19,%bl
  801127:	77 16                	ja     80113f <strtol+0xc6>
			dig = *s - 'A' + 10;
  801129:	0f be d2             	movsbl %dl,%edx
  80112c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80112f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801132:	7d 0b                	jge    80113f <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801134:	83 c1 01             	add    $0x1,%ecx
  801137:	0f af 45 10          	imul   0x10(%ebp),%eax
  80113b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80113d:	eb b9                	jmp    8010f8 <strtol+0x7f>

	if (endptr)
  80113f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801143:	74 0d                	je     801152 <strtol+0xd9>
		*endptr = (char *) s;
  801145:	8b 75 0c             	mov    0xc(%ebp),%esi
  801148:	89 0e                	mov    %ecx,(%esi)
  80114a:	eb 06                	jmp    801152 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80114c:	85 db                	test   %ebx,%ebx
  80114e:	74 98                	je     8010e8 <strtol+0x6f>
  801150:	eb 9e                	jmp    8010f0 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801152:	89 c2                	mov    %eax,%edx
  801154:	f7 da                	neg    %edx
  801156:	85 ff                	test   %edi,%edi
  801158:	0f 45 c2             	cmovne %edx,%eax
}
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

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
