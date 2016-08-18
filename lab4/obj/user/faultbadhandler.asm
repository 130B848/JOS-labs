
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 bc 01 00 00       	call   800203 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 12 03 00 00       	call   800368 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800070:	e8 f9 00 00 00       	call   80016e <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	c1 e0 07             	shl    $0x7,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 66 00 00 00       	call   80011e <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	51                   	push   %ecx
  8000d2:	52                   	push   %edx
  8000d3:	53                   	push   %ebx
  8000d4:	56                   	push   %esi
  8000d5:	57                   	push   %edi
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	8d 35 e1 00 80 00    	lea    0x8000e1,%esi
  8000df:	0f 34                	sysenter 

008000e1 <label_21>:
  8000e1:	89 ec                	mov    %ebp,%esp
  8000e3:	5d                   	pop    %ebp
  8000e4:	5f                   	pop    %edi
  8000e5:	5e                   	pop    %esi
  8000e6:	5b                   	pop    %ebx
  8000e7:	5a                   	pop    %edx
  8000e8:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fc:	89 ca                	mov    %ecx,%edx
  8000fe:	89 cb                	mov    %ecx,%ebx
  800100:	89 cf                	mov    %ecx,%edi
  800102:	51                   	push   %ecx
  800103:	52                   	push   %edx
  800104:	53                   	push   %ebx
  800105:	56                   	push   %esi
  800106:	57                   	push   %edi
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	8d 35 12 01 80 00    	lea    0x800112,%esi
  800110:	0f 34                	sysenter 

00800112 <label_55>:
  800112:	89 ec                	mov    %ebp,%esp
  800114:	5d                   	pop    %ebp
  800115:	5f                   	pop    %edi
  800116:	5e                   	pop    %esi
  800117:	5b                   	pop    %ebx
  800118:	5a                   	pop    %edx
  800119:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011a:	5b                   	pop    %ebx
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	57                   	push   %edi
  800122:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800123:	bb 00 00 00 00       	mov    $0x0,%ebx
  800128:	b8 03 00 00 00       	mov    $0x3,%eax
  80012d:	8b 55 08             	mov    0x8(%ebp),%edx
  800130:	89 d9                	mov    %ebx,%ecx
  800132:	89 df                	mov    %ebx,%edi
  800134:	51                   	push   %ecx
  800135:	52                   	push   %edx
  800136:	53                   	push   %ebx
  800137:	56                   	push   %esi
  800138:	57                   	push   %edi
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	8d 35 44 01 80 00    	lea    0x800144,%esi
  800142:	0f 34                	sysenter 

00800144 <label_90>:
  800144:	89 ec                	mov    %ebp,%esp
  800146:	5d                   	pop    %ebp
  800147:	5f                   	pop    %edi
  800148:	5e                   	pop    %esi
  800149:	5b                   	pop    %ebx
  80014a:	5a                   	pop    %edx
  80014b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80014c:	85 c0                	test   %eax,%eax
  80014e:	7e 17                	jle    800167 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	50                   	push   %eax
  800154:	6a 03                	push   $0x3
  800156:	68 2a 14 80 00       	push   $0x80142a
  80015b:	6a 29                	push   $0x29
  80015d:	68 47 14 80 00       	push   $0x801447
  800162:	e8 06 03 00 00       	call   80046d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800167:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80016a:	5b                   	pop    %ebx
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800173:	b9 00 00 00 00       	mov    $0x0,%ecx
  800178:	b8 02 00 00 00       	mov    $0x2,%eax
  80017d:	89 ca                	mov    %ecx,%edx
  80017f:	89 cb                	mov    %ecx,%ebx
  800181:	89 cf                	mov    %ecx,%edi
  800183:	51                   	push   %ecx
  800184:	52                   	push   %edx
  800185:	53                   	push   %ebx
  800186:	56                   	push   %esi
  800187:	57                   	push   %edi
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	8d 35 93 01 80 00    	lea    0x800193,%esi
  800191:	0f 34                	sysenter 

00800193 <label_139>:
  800193:	89 ec                	mov    %ebp,%esp
  800195:	5d                   	pop    %ebp
  800196:	5f                   	pop    %edi
  800197:	5e                   	pop    %esi
  800198:	5b                   	pop    %ebx
  800199:	5a                   	pop    %edx
  80019a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80019b:	5b                   	pop    %ebx
  80019c:	5f                   	pop    %edi
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	57                   	push   %edi
  8001a3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8001a9:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b4:	89 fb                	mov    %edi,%ebx
  8001b6:	51                   	push   %ecx
  8001b7:	52                   	push   %edx
  8001b8:	53                   	push   %ebx
  8001b9:	56                   	push   %esi
  8001ba:	57                   	push   %edi
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	8d 35 c6 01 80 00    	lea    0x8001c6,%esi
  8001c4:	0f 34                	sysenter 

008001c6 <label_174>:
  8001c6:	89 ec                	mov    %ebp,%esp
  8001c8:	5d                   	pop    %ebp
  8001c9:	5f                   	pop    %edi
  8001ca:	5e                   	pop    %esi
  8001cb:	5b                   	pop    %ebx
  8001cc:	5a                   	pop    %edx
  8001cd:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001ce:	5b                   	pop    %ebx
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_yield>:

void
sys_yield(void)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001dc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001e1:	89 d1                	mov    %edx,%ecx
  8001e3:	89 d3                	mov    %edx,%ebx
  8001e5:	89 d7                	mov    %edx,%edi
  8001e7:	51                   	push   %ecx
  8001e8:	52                   	push   %edx
  8001e9:	53                   	push   %ebx
  8001ea:	56                   	push   %esi
  8001eb:	57                   	push   %edi
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	8d 35 f7 01 80 00    	lea    0x8001f7,%esi
  8001f5:	0f 34                	sysenter 

008001f7 <label_209>:
  8001f7:	89 ec                	mov    %ebp,%esp
  8001f9:	5d                   	pop    %ebp
  8001fa:	5f                   	pop    %edi
  8001fb:	5e                   	pop    %esi
  8001fc:	5b                   	pop    %ebx
  8001fd:	5a                   	pop    %edx
  8001fe:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001ff:	5b                   	pop    %ebx
  800200:	5f                   	pop    %edi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	57                   	push   %edi
  800207:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800208:	bf 00 00 00 00       	mov    $0x0,%edi
  80020d:	b8 05 00 00 00       	mov    $0x5,%eax
  800212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800215:	8b 55 08             	mov    0x8(%ebp),%edx
  800218:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80021b:	51                   	push   %ecx
  80021c:	52                   	push   %edx
  80021d:	53                   	push   %ebx
  80021e:	56                   	push   %esi
  80021f:	57                   	push   %edi
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	8d 35 2b 02 80 00    	lea    0x80022b,%esi
  800229:	0f 34                	sysenter 

0080022b <label_244>:
  80022b:	89 ec                	mov    %ebp,%esp
  80022d:	5d                   	pop    %ebp
  80022e:	5f                   	pop    %edi
  80022f:	5e                   	pop    %esi
  800230:	5b                   	pop    %ebx
  800231:	5a                   	pop    %edx
  800232:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 17                	jle    80024e <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 05                	push   $0x5
  80023d:	68 2a 14 80 00       	push   $0x80142a
  800242:	6a 29                	push   $0x29
  800244:	68 47 14 80 00       	push   $0x801447
  800249:	e8 1f 02 00 00       	call   80046d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80024e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	57                   	push   %edi
  800259:	53                   	push   %ebx
  80025a:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800263:	8b 45 0c             	mov    0xc(%ebp),%eax
  800266:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800269:	8b 45 10             	mov    0x10(%ebp),%eax
  80026c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  80026f:	8b 45 14             	mov    0x14(%ebp),%eax
  800272:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80027b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80027e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800283:	b8 06 00 00 00       	mov    $0x6,%eax
  800288:	89 cb                	mov    %ecx,%ebx
  80028a:	89 cf                	mov    %ecx,%edi
  80028c:	51                   	push   %ecx
  80028d:	52                   	push   %edx
  80028e:	53                   	push   %ebx
  80028f:	56                   	push   %esi
  800290:	57                   	push   %edi
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8d 35 9c 02 80 00    	lea    0x80029c,%esi
  80029a:	0f 34                	sysenter 

0080029c <label_304>:
  80029c:	89 ec                	mov    %ebp,%esp
  80029e:	5d                   	pop    %ebp
  80029f:	5f                   	pop    %edi
  8002a0:	5e                   	pop    %esi
  8002a1:	5b                   	pop    %ebx
  8002a2:	5a                   	pop    %edx
  8002a3:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002a4:	85 c0                	test   %eax,%eax
  8002a6:	7e 17                	jle    8002bf <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a8:	83 ec 0c             	sub    $0xc,%esp
  8002ab:	50                   	push   %eax
  8002ac:	6a 06                	push   $0x6
  8002ae:	68 2a 14 80 00       	push   $0x80142a
  8002b3:	6a 29                	push   $0x29
  8002b5:	68 47 14 80 00       	push   $0x801447
  8002ba:	e8 ae 01 00 00       	call   80046d <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  8002bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8002d0:	b8 07 00 00 00       	mov    $0x7,%eax
  8002d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	89 fb                	mov    %edi,%ebx
  8002dd:	51                   	push   %ecx
  8002de:	52                   	push   %edx
  8002df:	53                   	push   %ebx
  8002e0:	56                   	push   %esi
  8002e1:	57                   	push   %edi
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	8d 35 ed 02 80 00    	lea    0x8002ed,%esi
  8002eb:	0f 34                	sysenter 

008002ed <label_353>:
  8002ed:	89 ec                	mov    %ebp,%esp
  8002ef:	5d                   	pop    %ebp
  8002f0:	5f                   	pop    %edi
  8002f1:	5e                   	pop    %esi
  8002f2:	5b                   	pop    %ebx
  8002f3:	5a                   	pop    %edx
  8002f4:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7e 17                	jle    800310 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	83 ec 0c             	sub    $0xc,%esp
  8002fc:	50                   	push   %eax
  8002fd:	6a 07                	push   $0x7
  8002ff:	68 2a 14 80 00       	push   $0x80142a
  800304:	6a 29                	push   $0x29
  800306:	68 47 14 80 00       	push   $0x801447
  80030b:	e8 5d 01 00 00       	call   80046d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800310:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800313:	5b                   	pop    %ebx
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	57                   	push   %edi
  80031b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80031c:	bf 00 00 00 00       	mov    $0x0,%edi
  800321:	b8 09 00 00 00       	mov    $0x9,%eax
  800326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 fb                	mov    %edi,%ebx
  80032e:	51                   	push   %ecx
  80032f:	52                   	push   %edx
  800330:	53                   	push   %ebx
  800331:	56                   	push   %esi
  800332:	57                   	push   %edi
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	8d 35 3e 03 80 00    	lea    0x80033e,%esi
  80033c:	0f 34                	sysenter 

0080033e <label_402>:
  80033e:	89 ec                	mov    %ebp,%esp
  800340:	5d                   	pop    %ebp
  800341:	5f                   	pop    %edi
  800342:	5e                   	pop    %esi
  800343:	5b                   	pop    %ebx
  800344:	5a                   	pop    %edx
  800345:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800346:	85 c0                	test   %eax,%eax
  800348:	7e 17                	jle    800361 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	83 ec 0c             	sub    $0xc,%esp
  80034d:	50                   	push   %eax
  80034e:	6a 09                	push   $0x9
  800350:	68 2a 14 80 00       	push   $0x80142a
  800355:	6a 29                	push   $0x29
  800357:	68 47 14 80 00       	push   $0x801447
  80035c:	e8 0c 01 00 00       	call   80046d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800361:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800364:	5b                   	pop    %ebx
  800365:	5f                   	pop    %edi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80036d:	bf 00 00 00 00       	mov    $0x0,%edi
  800372:	b8 0a 00 00 00       	mov    $0xa,%eax
  800377:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037a:	8b 55 08             	mov    0x8(%ebp),%edx
  80037d:	89 fb                	mov    %edi,%ebx
  80037f:	51                   	push   %ecx
  800380:	52                   	push   %edx
  800381:	53                   	push   %ebx
  800382:	56                   	push   %esi
  800383:	57                   	push   %edi
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8d 35 8f 03 80 00    	lea    0x80038f,%esi
  80038d:	0f 34                	sysenter 

0080038f <label_451>:
  80038f:	89 ec                	mov    %ebp,%esp
  800391:	5d                   	pop    %ebp
  800392:	5f                   	pop    %edi
  800393:	5e                   	pop    %esi
  800394:	5b                   	pop    %ebx
  800395:	5a                   	pop    %edx
  800396:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800397:	85 c0                	test   %eax,%eax
  800399:	7e 17                	jle    8003b2 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039b:	83 ec 0c             	sub    $0xc,%esp
  80039e:	50                   	push   %eax
  80039f:	6a 0a                	push   $0xa
  8003a1:	68 2a 14 80 00       	push   $0x80142a
  8003a6:	6a 29                	push   $0x29
  8003a8:	68 47 14 80 00       	push   $0x801447
  8003ad:	e8 bb 00 00 00       	call   80046d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003b5:	5b                   	pop    %ebx
  8003b6:	5f                   	pop    %edi
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  8003be:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003cf:	51                   	push   %ecx
  8003d0:	52                   	push   %edx
  8003d1:	53                   	push   %ebx
  8003d2:	56                   	push   %esi
  8003d3:	57                   	push   %edi
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	8d 35 df 03 80 00    	lea    0x8003df,%esi
  8003dd:	0f 34                	sysenter 

008003df <label_502>:
  8003df:	89 ec                	mov    %ebp,%esp
  8003e1:	5d                   	pop    %ebp
  8003e2:	5f                   	pop    %edi
  8003e3:	5e                   	pop    %esi
  8003e4:	5b                   	pop    %ebx
  8003e5:	5a                   	pop    %edx
  8003e6:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003e7:	5b                   	pop    %ebx
  8003e8:	5f                   	pop    %edi
  8003e9:	5d                   	pop    %ebp
  8003ea:	c3                   	ret    

008003eb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	57                   	push   %edi
  8003ef:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003f5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fd:	89 d9                	mov    %ebx,%ecx
  8003ff:	89 df                	mov    %ebx,%edi
  800401:	51                   	push   %ecx
  800402:	52                   	push   %edx
  800403:	53                   	push   %ebx
  800404:	56                   	push   %esi
  800405:	57                   	push   %edi
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	8d 35 11 04 80 00    	lea    0x800411,%esi
  80040f:	0f 34                	sysenter 

00800411 <label_537>:
  800411:	89 ec                	mov    %ebp,%esp
  800413:	5d                   	pop    %ebp
  800414:	5f                   	pop    %edi
  800415:	5e                   	pop    %esi
  800416:	5b                   	pop    %ebx
  800417:	5a                   	pop    %edx
  800418:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800419:	85 c0                	test   %eax,%eax
  80041b:	7e 17                	jle    800434 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80041d:	83 ec 0c             	sub    $0xc,%esp
  800420:	50                   	push   %eax
  800421:	6a 0d                	push   $0xd
  800423:	68 2a 14 80 00       	push   $0x80142a
  800428:	6a 29                	push   $0x29
  80042a:	68 47 14 80 00       	push   $0x801447
  80042f:	e8 39 00 00 00       	call   80046d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800434:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800437:	5b                   	pop    %ebx
  800438:	5f                   	pop    %edi
  800439:	5d                   	pop    %ebp
  80043a:	c3                   	ret    

0080043b <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	57                   	push   %edi
  80043f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800440:	b9 00 00 00 00       	mov    $0x0,%ecx
  800445:	b8 0e 00 00 00       	mov    $0xe,%eax
  80044a:	8b 55 08             	mov    0x8(%ebp),%edx
  80044d:	89 cb                	mov    %ecx,%ebx
  80044f:	89 cf                	mov    %ecx,%edi
  800451:	51                   	push   %ecx
  800452:	52                   	push   %edx
  800453:	53                   	push   %ebx
  800454:	56                   	push   %esi
  800455:	57                   	push   %edi
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	8d 35 61 04 80 00    	lea    0x800461,%esi
  80045f:	0f 34                	sysenter 

00800461 <label_586>:
  800461:	89 ec                	mov    %ebp,%esp
  800463:	5d                   	pop    %ebp
  800464:	5f                   	pop    %edi
  800465:	5e                   	pop    %esi
  800466:	5b                   	pop    %ebx
  800467:	5a                   	pop    %edx
  800468:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800469:	5b                   	pop    %ebx
  80046a:	5f                   	pop    %edi
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    

0080046d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	56                   	push   %esi
  800471:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800472:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800475:	a1 10 20 80 00       	mov    0x802010,%eax
  80047a:	85 c0                	test   %eax,%eax
  80047c:	74 11                	je     80048f <_panic+0x22>
		cprintf("%s: ", argv0);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	50                   	push   %eax
  800482:	68 55 14 80 00       	push   $0x801455
  800487:	e8 d4 00 00 00       	call   800560 <cprintf>
  80048c:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80048f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800495:	e8 d4 fc ff ff       	call   80016e <sys_getenvid>
  80049a:	83 ec 0c             	sub    $0xc,%esp
  80049d:	ff 75 0c             	pushl  0xc(%ebp)
  8004a0:	ff 75 08             	pushl  0x8(%ebp)
  8004a3:	56                   	push   %esi
  8004a4:	50                   	push   %eax
  8004a5:	68 5c 14 80 00       	push   $0x80145c
  8004aa:	e8 b1 00 00 00       	call   800560 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004af:	83 c4 18             	add    $0x18,%esp
  8004b2:	53                   	push   %ebx
  8004b3:	ff 75 10             	pushl  0x10(%ebp)
  8004b6:	e8 54 00 00 00       	call   80050f <vcprintf>
	cprintf("\n");
  8004bb:	c7 04 24 5a 14 80 00 	movl   $0x80145a,(%esp)
  8004c2:	e8 99 00 00 00       	call   800560 <cprintf>
  8004c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ca:	cc                   	int3   
  8004cb:	eb fd                	jmp    8004ca <_panic+0x5d>

008004cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	53                   	push   %ebx
  8004d1:	83 ec 04             	sub    $0x4,%esp
  8004d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004d7:	8b 13                	mov    (%ebx),%edx
  8004d9:	8d 42 01             	lea    0x1(%edx),%eax
  8004dc:	89 03                	mov    %eax,(%ebx)
  8004de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ea:	75 1a                	jne    800506 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	68 ff 00 00 00       	push   $0xff
  8004f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8004f7:	50                   	push   %eax
  8004f8:	e8 c0 fb ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8004fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800503:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800506:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80050a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80050d:	c9                   	leave  
  80050e:	c3                   	ret    

0080050f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800518:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80051f:	00 00 00 
	b.cnt = 0;
  800522:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800529:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80052c:	ff 75 0c             	pushl  0xc(%ebp)
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800538:	50                   	push   %eax
  800539:	68 cd 04 80 00       	push   $0x8004cd
  80053e:	e8 c0 02 00 00       	call   800803 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800543:	83 c4 08             	add    $0x8,%esp
  800546:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80054c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800552:	50                   	push   %eax
  800553:	e8 65 fb ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  800558:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800566:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800569:	50                   	push   %eax
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 9d ff ff ff       	call   80050f <vcprintf>
	va_end(ap);

	return cnt;
}
  800572:	c9                   	leave  
  800573:	c3                   	ret    

00800574 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 1c             	sub    $0x1c,%esp
  80057d:	89 c7                	mov    %eax,%edi
  80057f:	89 d6                	mov    %edx,%esi
  800581:	8b 45 08             	mov    0x8(%ebp),%eax
  800584:	8b 55 0c             	mov    0xc(%ebp),%edx
  800587:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80058d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800590:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800594:	0f 85 bf 00 00 00    	jne    800659 <printnum+0xe5>
  80059a:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8005a0:	0f 8d de 00 00 00    	jge    800684 <printnum+0x110>
		judge_time_for_space = width;
  8005a6:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8005ac:	e9 d3 00 00 00       	jmp    800684 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005b1:	83 eb 01             	sub    $0x1,%ebx
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f 37                	jg     8005ef <printnum+0x7b>
  8005b8:	e9 ea 00 00 00       	jmp    8006a7 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8005bd:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8005c0:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	56                   	push   %esi
  8005c9:	83 ec 04             	sub    $0x4,%esp
  8005cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8005cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8005d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d8:	e8 d3 0c 00 00       	call   8012b0 <__umoddi3>
  8005dd:	83 c4 14             	add    $0x14,%esp
  8005e0:	0f be 80 7f 14 80 00 	movsbl 0x80147f(%eax),%eax
  8005e7:	50                   	push   %eax
  8005e8:	ff d7                	call   *%edi
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	eb 16                	jmp    800605 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	56                   	push   %esi
  8005f3:	ff 75 18             	pushl  0x18(%ebp)
  8005f6:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	83 eb 01             	sub    $0x1,%ebx
  8005fe:	75 ef                	jne    8005ef <printnum+0x7b>
  800600:	e9 a2 00 00 00       	jmp    8006a7 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800605:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  80060b:	0f 85 76 01 00 00    	jne    800787 <printnum+0x213>
		while(num_of_space-- > 0)
  800611:	a1 04 20 80 00       	mov    0x802004,%eax
  800616:	8d 50 ff             	lea    -0x1(%eax),%edx
  800619:	89 15 04 20 80 00    	mov    %edx,0x802004
  80061f:	85 c0                	test   %eax,%eax
  800621:	7e 1d                	jle    800640 <printnum+0xcc>
			putch(' ', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	56                   	push   %esi
  800627:	6a 20                	push   $0x20
  800629:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80062b:	a1 04 20 80 00       	mov    0x802004,%eax
  800630:	8d 50 ff             	lea    -0x1(%eax),%edx
  800633:	89 15 04 20 80 00    	mov    %edx,0x802004
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	85 c0                	test   %eax,%eax
  80063e:	7f e3                	jg     800623 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800640:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800647:	00 00 00 
		judge_time_for_space = 0;
  80064a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800651:	00 00 00 
	}
}
  800654:	e9 2e 01 00 00       	jmp    800787 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800659:	8b 45 10             	mov    0x10(%ebp),%eax
  80065c:	ba 00 00 00 00       	mov    $0x0,%edx
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800667:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066d:	83 fa 00             	cmp    $0x0,%edx
  800670:	0f 87 ba 00 00 00    	ja     800730 <printnum+0x1bc>
  800676:	3b 45 10             	cmp    0x10(%ebp),%eax
  800679:	0f 83 b1 00 00 00    	jae    800730 <printnum+0x1bc>
  80067f:	e9 2d ff ff ff       	jmp    8005b1 <printnum+0x3d>
  800684:	8b 45 10             	mov    0x10(%ebp),%eax
  800687:	ba 00 00 00 00       	mov    $0x0,%edx
  80068c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800695:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800698:	83 fa 00             	cmp    $0x0,%edx
  80069b:	77 37                	ja     8006d4 <printnum+0x160>
  80069d:	3b 45 10             	cmp    0x10(%ebp),%eax
  8006a0:	73 32                	jae    8006d4 <printnum+0x160>
  8006a2:	e9 16 ff ff ff       	jmp    8005bd <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	56                   	push   %esi
  8006ab:	83 ec 04             	sub    $0x4,%esp
  8006ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8006b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ba:	e8 f1 0b 00 00       	call   8012b0 <__umoddi3>
  8006bf:	83 c4 14             	add    $0x14,%esp
  8006c2:	0f be 80 7f 14 80 00 	movsbl 0x80147f(%eax),%eax
  8006c9:	50                   	push   %eax
  8006ca:	ff d7                	call   *%edi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	e9 b3 00 00 00       	jmp    800787 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006d4:	83 ec 0c             	sub    $0xc,%esp
  8006d7:	ff 75 18             	pushl  0x18(%ebp)
  8006da:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006dd:	50                   	push   %eax
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	ff 75 dc             	pushl  -0x24(%ebp)
  8006e7:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f0:	e8 8b 0a 00 00       	call   801180 <__udivdi3>
  8006f5:	83 c4 18             	add    $0x18,%esp
  8006f8:	52                   	push   %edx
  8006f9:	50                   	push   %eax
  8006fa:	89 f2                	mov    %esi,%edx
  8006fc:	89 f8                	mov    %edi,%eax
  8006fe:	e8 71 fe ff ff       	call   800574 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800703:	83 c4 18             	add    $0x18,%esp
  800706:	56                   	push   %esi
  800707:	83 ec 04             	sub    $0x4,%esp
  80070a:	ff 75 dc             	pushl  -0x24(%ebp)
  80070d:	ff 75 d8             	pushl  -0x28(%ebp)
  800710:	ff 75 e4             	pushl  -0x1c(%ebp)
  800713:	ff 75 e0             	pushl  -0x20(%ebp)
  800716:	e8 95 0b 00 00       	call   8012b0 <__umoddi3>
  80071b:	83 c4 14             	add    $0x14,%esp
  80071e:	0f be 80 7f 14 80 00 	movsbl 0x80147f(%eax),%eax
  800725:	50                   	push   %eax
  800726:	ff d7                	call   *%edi
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	e9 d5 fe ff ff       	jmp    800605 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	ff 75 18             	pushl  0x18(%ebp)
  800736:	83 eb 01             	sub    $0x1,%ebx
  800739:	53                   	push   %ebx
  80073a:	ff 75 10             	pushl  0x10(%ebp)
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	ff 75 dc             	pushl  -0x24(%ebp)
  800743:	ff 75 d8             	pushl  -0x28(%ebp)
  800746:	ff 75 e4             	pushl  -0x1c(%ebp)
  800749:	ff 75 e0             	pushl  -0x20(%ebp)
  80074c:	e8 2f 0a 00 00       	call   801180 <__udivdi3>
  800751:	83 c4 18             	add    $0x18,%esp
  800754:	52                   	push   %edx
  800755:	50                   	push   %eax
  800756:	89 f2                	mov    %esi,%edx
  800758:	89 f8                	mov    %edi,%eax
  80075a:	e8 15 fe ff ff       	call   800574 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80075f:	83 c4 18             	add    $0x18,%esp
  800762:	56                   	push   %esi
  800763:	83 ec 04             	sub    $0x4,%esp
  800766:	ff 75 dc             	pushl  -0x24(%ebp)
  800769:	ff 75 d8             	pushl  -0x28(%ebp)
  80076c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076f:	ff 75 e0             	pushl  -0x20(%ebp)
  800772:	e8 39 0b 00 00       	call   8012b0 <__umoddi3>
  800777:	83 c4 14             	add    $0x14,%esp
  80077a:	0f be 80 7f 14 80 00 	movsbl 0x80147f(%eax),%eax
  800781:	50                   	push   %eax
  800782:	ff d7                	call   *%edi
  800784:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800787:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5f                   	pop    %edi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800792:	83 fa 01             	cmp    $0x1,%edx
  800795:	7e 0e                	jle    8007a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800797:	8b 10                	mov    (%eax),%edx
  800799:	8d 4a 08             	lea    0x8(%edx),%ecx
  80079c:	89 08                	mov    %ecx,(%eax)
  80079e:	8b 02                	mov    (%edx),%eax
  8007a0:	8b 52 04             	mov    0x4(%edx),%edx
  8007a3:	eb 22                	jmp    8007c7 <getuint+0x38>
	else if (lflag)
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	74 10                	je     8007b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a9:	8b 10                	mov    (%eax),%edx
  8007ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ae:	89 08                	mov    %ecx,(%eax)
  8007b0:	8b 02                	mov    (%edx),%eax
  8007b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b7:	eb 0e                	jmp    8007c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b9:	8b 10                	mov    (%eax),%edx
  8007bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007be:	89 08                	mov    %ecx,(%eax)
  8007c0:	8b 02                	mov    (%edx),%eax
  8007c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d3:	8b 10                	mov    (%eax),%edx
  8007d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d8:	73 0a                	jae    8007e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007dd:	89 08                	mov    %ecx,(%eax)
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	88 02                	mov    %al,(%edx)
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ef:	50                   	push   %eax
  8007f0:	ff 75 10             	pushl  0x10(%ebp)
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	ff 75 08             	pushl  0x8(%ebp)
  8007f9:	e8 05 00 00 00       	call   800803 <vprintfmt>
	va_end(ap);
}
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	57                   	push   %edi
  800807:	56                   	push   %esi
  800808:	53                   	push   %ebx
  800809:	83 ec 2c             	sub    $0x2c,%esp
  80080c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800812:	eb 03                	jmp    800817 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800814:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	8d 70 01             	lea    0x1(%eax),%esi
  80081d:	0f b6 00             	movzbl (%eax),%eax
  800820:	83 f8 25             	cmp    $0x25,%eax
  800823:	74 27                	je     80084c <vprintfmt+0x49>
			if (ch == '\0')
  800825:	85 c0                	test   %eax,%eax
  800827:	75 0d                	jne    800836 <vprintfmt+0x33>
  800829:	e9 9d 04 00 00       	jmp    800ccb <vprintfmt+0x4c8>
  80082e:	85 c0                	test   %eax,%eax
  800830:	0f 84 95 04 00 00    	je     800ccb <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	53                   	push   %ebx
  80083a:	50                   	push   %eax
  80083b:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80083d:	83 c6 01             	add    $0x1,%esi
  800840:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	83 f8 25             	cmp    $0x25,%eax
  80084a:	75 e2                	jne    80082e <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80084c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800851:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800855:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80085c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800863:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80086a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800871:	eb 08                	jmp    80087b <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800873:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800876:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087b:	8d 46 01             	lea    0x1(%esi),%eax
  80087e:	89 45 10             	mov    %eax,0x10(%ebp)
  800881:	0f b6 06             	movzbl (%esi),%eax
  800884:	0f b6 d0             	movzbl %al,%edx
  800887:	83 e8 23             	sub    $0x23,%eax
  80088a:	3c 55                	cmp    $0x55,%al
  80088c:	0f 87 fa 03 00 00    	ja     800c8c <vprintfmt+0x489>
  800892:	0f b6 c0             	movzbl %al,%eax
  800895:	ff 24 85 c0 15 80 00 	jmp    *0x8015c0(,%eax,4)
  80089c:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80089f:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8008a3:	eb d6                	jmp    80087b <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008a5:	8d 42 d0             	lea    -0x30(%edx),%eax
  8008a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8008ab:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8008af:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008b2:	83 fa 09             	cmp    $0x9,%edx
  8008b5:	77 6b                	ja     800922 <vprintfmt+0x11f>
  8008b7:	8b 75 10             	mov    0x10(%ebp),%esi
  8008ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008bd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8008c0:	eb 09                	jmp    8008cb <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c2:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008c5:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008c9:	eb b0                	jmp    80087b <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008cb:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008ce:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008d1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008d5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008d8:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008db:	83 f9 09             	cmp    $0x9,%ecx
  8008de:	76 eb                	jbe    8008cb <vprintfmt+0xc8>
  8008e0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008e3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008e6:	eb 3d                	jmp    800925 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f1:	8b 00                	mov    (%eax),%eax
  8008f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008f9:	eb 2a                	jmp    800925 <vprintfmt+0x122>
  8008fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008fe:	85 c0                	test   %eax,%eax
  800900:	ba 00 00 00 00       	mov    $0x0,%edx
  800905:	0f 49 d0             	cmovns %eax,%edx
  800908:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8b 75 10             	mov    0x10(%ebp),%esi
  80090e:	e9 68 ff ff ff       	jmp    80087b <vprintfmt+0x78>
  800913:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800916:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80091d:	e9 59 ff ff ff       	jmp    80087b <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800922:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800925:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800929:	0f 89 4c ff ff ff    	jns    80087b <vprintfmt+0x78>
				width = precision, precision = -1;
  80092f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800932:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800935:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80093c:	e9 3a ff ff ff       	jmp    80087b <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800941:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800945:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800948:	e9 2e ff ff ff       	jmp    80087b <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80094d:	8b 45 14             	mov    0x14(%ebp),%eax
  800950:	8d 50 04             	lea    0x4(%eax),%edx
  800953:	89 55 14             	mov    %edx,0x14(%ebp)
  800956:	83 ec 08             	sub    $0x8,%esp
  800959:	53                   	push   %ebx
  80095a:	ff 30                	pushl  (%eax)
  80095c:	ff d7                	call   *%edi
			break;
  80095e:	83 c4 10             	add    $0x10,%esp
  800961:	e9 b1 fe ff ff       	jmp    800817 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8d 50 04             	lea    0x4(%eax),%edx
  80096c:	89 55 14             	mov    %edx,0x14(%ebp)
  80096f:	8b 00                	mov    (%eax),%eax
  800971:	99                   	cltd   
  800972:	31 d0                	xor    %edx,%eax
  800974:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800976:	83 f8 08             	cmp    $0x8,%eax
  800979:	7f 0b                	jg     800986 <vprintfmt+0x183>
  80097b:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  800982:	85 d2                	test   %edx,%edx
  800984:	75 15                	jne    80099b <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800986:	50                   	push   %eax
  800987:	68 97 14 80 00       	push   $0x801497
  80098c:	53                   	push   %ebx
  80098d:	57                   	push   %edi
  80098e:	e8 53 fe ff ff       	call   8007e6 <printfmt>
  800993:	83 c4 10             	add    $0x10,%esp
  800996:	e9 7c fe ff ff       	jmp    800817 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80099b:	52                   	push   %edx
  80099c:	68 a0 14 80 00       	push   $0x8014a0
  8009a1:	53                   	push   %ebx
  8009a2:	57                   	push   %edi
  8009a3:	e8 3e fe ff ff       	call   8007e6 <printfmt>
  8009a8:	83 c4 10             	add    $0x10,%esp
  8009ab:	e9 67 fe ff ff       	jmp    800817 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b3:	8d 50 04             	lea    0x4(%eax),%edx
  8009b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b9:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8009bb:	85 c0                	test   %eax,%eax
  8009bd:	b9 90 14 80 00       	mov    $0x801490,%ecx
  8009c2:	0f 45 c8             	cmovne %eax,%ecx
  8009c5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009cc:	7e 06                	jle    8009d4 <vprintfmt+0x1d1>
  8009ce:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009d2:	75 19                	jne    8009ed <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009d4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009d7:	8d 70 01             	lea    0x1(%eax),%esi
  8009da:	0f b6 00             	movzbl (%eax),%eax
  8009dd:	0f be d0             	movsbl %al,%edx
  8009e0:	85 d2                	test   %edx,%edx
  8009e2:	0f 85 9f 00 00 00    	jne    800a87 <vprintfmt+0x284>
  8009e8:	e9 8c 00 00 00       	jmp    800a79 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ed:	83 ec 08             	sub    $0x8,%esp
  8009f0:	ff 75 d0             	pushl  -0x30(%ebp)
  8009f3:	ff 75 cc             	pushl  -0x34(%ebp)
  8009f6:	e8 62 03 00 00       	call   800d5d <strnlen>
  8009fb:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009fe:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800a01:	83 c4 10             	add    $0x10,%esp
  800a04:	85 c9                	test   %ecx,%ecx
  800a06:	0f 8e a6 02 00 00    	jle    800cb2 <vprintfmt+0x4af>
					putch(padc, putdat);
  800a0c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800a10:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a13:	89 cb                	mov    %ecx,%ebx
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	ff 75 0c             	pushl  0xc(%ebp)
  800a1b:	56                   	push   %esi
  800a1c:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	83 eb 01             	sub    $0x1,%ebx
  800a24:	75 ef                	jne    800a15 <vprintfmt+0x212>
  800a26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2c:	e9 81 02 00 00       	jmp    800cb2 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a31:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a35:	74 1b                	je     800a52 <vprintfmt+0x24f>
  800a37:	0f be c0             	movsbl %al,%eax
  800a3a:	83 e8 20             	sub    $0x20,%eax
  800a3d:	83 f8 5e             	cmp    $0x5e,%eax
  800a40:	76 10                	jbe    800a52 <vprintfmt+0x24f>
					putch('?', putdat);
  800a42:	83 ec 08             	sub    $0x8,%esp
  800a45:	ff 75 0c             	pushl  0xc(%ebp)
  800a48:	6a 3f                	push   $0x3f
  800a4a:	ff 55 08             	call   *0x8(%ebp)
  800a4d:	83 c4 10             	add    $0x10,%esp
  800a50:	eb 0d                	jmp    800a5f <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a52:	83 ec 08             	sub    $0x8,%esp
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	52                   	push   %edx
  800a59:	ff 55 08             	call   *0x8(%ebp)
  800a5c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5f:	83 ef 01             	sub    $0x1,%edi
  800a62:	83 c6 01             	add    $0x1,%esi
  800a65:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a69:	0f be d0             	movsbl %al,%edx
  800a6c:	85 d2                	test   %edx,%edx
  800a6e:	75 31                	jne    800aa1 <vprintfmt+0x29e>
  800a70:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a73:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a79:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a7c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a80:	7f 33                	jg     800ab5 <vprintfmt+0x2b2>
  800a82:	e9 90 fd ff ff       	jmp    800817 <vprintfmt+0x14>
  800a87:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a8d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a90:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a93:	eb 0c                	jmp    800aa1 <vprintfmt+0x29e>
  800a95:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a98:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a9b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a9e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa1:	85 db                	test   %ebx,%ebx
  800aa3:	78 8c                	js     800a31 <vprintfmt+0x22e>
  800aa5:	83 eb 01             	sub    $0x1,%ebx
  800aa8:	79 87                	jns    800a31 <vprintfmt+0x22e>
  800aaa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800aad:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab3:	eb c4                	jmp    800a79 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ab5:	83 ec 08             	sub    $0x8,%esp
  800ab8:	53                   	push   %ebx
  800ab9:	6a 20                	push   $0x20
  800abb:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	83 ee 01             	sub    $0x1,%esi
  800ac3:	75 f0                	jne    800ab5 <vprintfmt+0x2b2>
  800ac5:	e9 4d fd ff ff       	jmp    800817 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aca:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800ace:	7e 16                	jle    800ae6 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800ad0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad3:	8d 50 08             	lea    0x8(%eax),%edx
  800ad6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad9:	8b 50 04             	mov    0x4(%eax),%edx
  800adc:	8b 00                	mov    (%eax),%eax
  800ade:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ae1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ae4:	eb 34                	jmp    800b1a <vprintfmt+0x317>
	else if (lflag)
  800ae6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800aea:	74 18                	je     800b04 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800aec:	8b 45 14             	mov    0x14(%ebp),%eax
  800aef:	8d 50 04             	lea    0x4(%eax),%edx
  800af2:	89 55 14             	mov    %edx,0x14(%ebp)
  800af5:	8b 30                	mov    (%eax),%esi
  800af7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800afa:	89 f0                	mov    %esi,%eax
  800afc:	c1 f8 1f             	sar    $0x1f,%eax
  800aff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b02:	eb 16                	jmp    800b1a <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800b04:	8b 45 14             	mov    0x14(%ebp),%eax
  800b07:	8d 50 04             	lea    0x4(%eax),%edx
  800b0a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0d:	8b 30                	mov    (%eax),%esi
  800b0f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800b12:	89 f0                	mov    %esi,%eax
  800b14:	c1 f8 1f             	sar    $0x1f,%eax
  800b17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b1d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b20:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b23:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b26:	85 d2                	test   %edx,%edx
  800b28:	79 28                	jns    800b52 <vprintfmt+0x34f>
				putch('-', putdat);
  800b2a:	83 ec 08             	sub    $0x8,%esp
  800b2d:	53                   	push   %ebx
  800b2e:	6a 2d                	push   $0x2d
  800b30:	ff d7                	call   *%edi
				num = -(long long) num;
  800b32:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b35:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b38:	f7 d8                	neg    %eax
  800b3a:	83 d2 00             	adc    $0x0,%edx
  800b3d:	f7 da                	neg    %edx
  800b3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b42:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b45:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4d:	e9 b2 00 00 00       	jmp    800c04 <vprintfmt+0x401>
  800b52:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b57:	85 c9                	test   %ecx,%ecx
  800b59:	0f 84 a5 00 00 00    	je     800c04 <vprintfmt+0x401>
				putch('+', putdat);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	53                   	push   %ebx
  800b63:	6a 2b                	push   $0x2b
  800b65:	ff d7                	call   *%edi
  800b67:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b6a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6f:	e9 90 00 00 00       	jmp    800c04 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b74:	85 c9                	test   %ecx,%ecx
  800b76:	74 0b                	je     800b83 <vprintfmt+0x380>
				putch('+', putdat);
  800b78:	83 ec 08             	sub    $0x8,%esp
  800b7b:	53                   	push   %ebx
  800b7c:	6a 2b                	push   $0x2b
  800b7e:	ff d7                	call   *%edi
  800b80:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b83:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b86:	8d 45 14             	lea    0x14(%ebp),%eax
  800b89:	e8 01 fc ff ff       	call   80078f <getuint>
  800b8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b91:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b94:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b99:	eb 69                	jmp    800c04 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b9b:	83 ec 08             	sub    $0x8,%esp
  800b9e:	53                   	push   %ebx
  800b9f:	6a 30                	push   $0x30
  800ba1:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800ba3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ba6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba9:	e8 e1 fb ff ff       	call   80078f <getuint>
  800bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bb1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800bb4:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800bb7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800bbc:	eb 46                	jmp    800c04 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800bbe:	83 ec 08             	sub    $0x8,%esp
  800bc1:	53                   	push   %ebx
  800bc2:	6a 30                	push   $0x30
  800bc4:	ff d7                	call   *%edi
			putch('x', putdat);
  800bc6:	83 c4 08             	add    $0x8,%esp
  800bc9:	53                   	push   %ebx
  800bca:	6a 78                	push   $0x78
  800bcc:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bce:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd1:	8d 50 04             	lea    0x4(%eax),%edx
  800bd4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bd7:	8b 00                	mov    (%eax),%eax
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bde:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800be1:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800be4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800be7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bec:	eb 16                	jmp    800c04 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bee:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bf1:	8d 45 14             	lea    0x14(%ebp),%eax
  800bf4:	e8 96 fb ff ff       	call   80078f <getuint>
  800bf9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bfc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800c0b:	56                   	push   %esi
  800c0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c0f:	50                   	push   %eax
  800c10:	ff 75 dc             	pushl  -0x24(%ebp)
  800c13:	ff 75 d8             	pushl  -0x28(%ebp)
  800c16:	89 da                	mov    %ebx,%edx
  800c18:	89 f8                	mov    %edi,%eax
  800c1a:	e8 55 f9 ff ff       	call   800574 <printnum>
			break;
  800c1f:	83 c4 20             	add    $0x20,%esp
  800c22:	e9 f0 fb ff ff       	jmp    800817 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c27:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2a:	8d 50 04             	lea    0x4(%eax),%edx
  800c2d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c30:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c32:	85 f6                	test   %esi,%esi
  800c34:	75 1a                	jne    800c50 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c36:	83 ec 08             	sub    $0x8,%esp
  800c39:	68 38 15 80 00       	push   $0x801538
  800c3e:	68 a0 14 80 00       	push   $0x8014a0
  800c43:	e8 18 f9 ff ff       	call   800560 <cprintf>
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	e9 c7 fb ff ff       	jmp    800817 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c50:	0f b6 03             	movzbl (%ebx),%eax
  800c53:	84 c0                	test   %al,%al
  800c55:	79 1f                	jns    800c76 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c57:	83 ec 08             	sub    $0x8,%esp
  800c5a:	68 70 15 80 00       	push   $0x801570
  800c5f:	68 a0 14 80 00       	push   $0x8014a0
  800c64:	e8 f7 f8 ff ff       	call   800560 <cprintf>
						*tmp = *(char *)putdat;
  800c69:	0f b6 03             	movzbl (%ebx),%eax
  800c6c:	88 06                	mov    %al,(%esi)
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	e9 a1 fb ff ff       	jmp    800817 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c76:	88 06                	mov    %al,(%esi)
  800c78:	e9 9a fb ff ff       	jmp    800817 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c7d:	83 ec 08             	sub    $0x8,%esp
  800c80:	53                   	push   %ebx
  800c81:	52                   	push   %edx
  800c82:	ff d7                	call   *%edi
			break;
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	e9 8b fb ff ff       	jmp    800817 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c8c:	83 ec 08             	sub    $0x8,%esp
  800c8f:	53                   	push   %ebx
  800c90:	6a 25                	push   $0x25
  800c92:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c9b:	0f 84 73 fb ff ff    	je     800814 <vprintfmt+0x11>
  800ca1:	83 ee 01             	sub    $0x1,%esi
  800ca4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ca8:	75 f7                	jne    800ca1 <vprintfmt+0x49e>
  800caa:	89 75 10             	mov    %esi,0x10(%ebp)
  800cad:	e9 65 fb ff ff       	jmp    800817 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cb2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800cb5:	8d 70 01             	lea    0x1(%eax),%esi
  800cb8:	0f b6 00             	movzbl (%eax),%eax
  800cbb:	0f be d0             	movsbl %al,%edx
  800cbe:	85 d2                	test   %edx,%edx
  800cc0:	0f 85 cf fd ff ff    	jne    800a95 <vprintfmt+0x292>
  800cc6:	e9 4c fb ff ff       	jmp    800817 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 18             	sub    $0x18,%esp
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ce2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ce6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ce9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	74 26                	je     800d1a <vsnprintf+0x47>
  800cf4:	85 d2                	test   %edx,%edx
  800cf6:	7e 22                	jle    800d1a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cf8:	ff 75 14             	pushl  0x14(%ebp)
  800cfb:	ff 75 10             	pushl  0x10(%ebp)
  800cfe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d01:	50                   	push   %eax
  800d02:	68 c9 07 80 00       	push   $0x8007c9
  800d07:	e8 f7 fa ff ff       	call   800803 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d0f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d15:	83 c4 10             	add    $0x10,%esp
  800d18:	eb 05                	jmp    800d1f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d27:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d2a:	50                   	push   %eax
  800d2b:	ff 75 10             	pushl  0x10(%ebp)
  800d2e:	ff 75 0c             	pushl  0xc(%ebp)
  800d31:	ff 75 08             	pushl  0x8(%ebp)
  800d34:	e8 9a ff ff ff       	call   800cd3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d41:	80 3a 00             	cmpb   $0x0,(%edx)
  800d44:	74 10                	je     800d56 <strlen+0x1b>
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d4b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d4e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d52:	75 f7                	jne    800d4b <strlen+0x10>
  800d54:	eb 05                	jmp    800d5b <strlen+0x20>
  800d56:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	53                   	push   %ebx
  800d61:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d67:	85 c9                	test   %ecx,%ecx
  800d69:	74 1c                	je     800d87 <strnlen+0x2a>
  800d6b:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d6e:	74 1e                	je     800d8e <strnlen+0x31>
  800d70:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d75:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d77:	39 ca                	cmp    %ecx,%edx
  800d79:	74 18                	je     800d93 <strnlen+0x36>
  800d7b:	83 c2 01             	add    $0x1,%edx
  800d7e:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d83:	75 f0                	jne    800d75 <strnlen+0x18>
  800d85:	eb 0c                	jmp    800d93 <strnlen+0x36>
  800d87:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8c:	eb 05                	jmp    800d93 <strnlen+0x36>
  800d8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d93:	5b                   	pop    %ebx
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	53                   	push   %ebx
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800da0:	89 c2                	mov    %eax,%edx
  800da2:	83 c2 01             	add    $0x1,%edx
  800da5:	83 c1 01             	add    $0x1,%ecx
  800da8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800dac:	88 5a ff             	mov    %bl,-0x1(%edx)
  800daf:	84 db                	test   %bl,%bl
  800db1:	75 ef                	jne    800da2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800db3:	5b                   	pop    %ebx
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	53                   	push   %ebx
  800dba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800dbd:	53                   	push   %ebx
  800dbe:	e8 78 ff ff ff       	call   800d3b <strlen>
  800dc3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800dc6:	ff 75 0c             	pushl  0xc(%ebp)
  800dc9:	01 d8                	add    %ebx,%eax
  800dcb:	50                   	push   %eax
  800dcc:	e8 c5 ff ff ff       	call   800d96 <strcpy>
	return dst;
}
  800dd1:	89 d8                	mov    %ebx,%eax
  800dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd6:	c9                   	leave  
  800dd7:	c3                   	ret    

00800dd8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	8b 75 08             	mov    0x8(%ebp),%esi
  800de0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de6:	85 db                	test   %ebx,%ebx
  800de8:	74 17                	je     800e01 <strncpy+0x29>
  800dea:	01 f3                	add    %esi,%ebx
  800dec:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dee:	83 c1 01             	add    $0x1,%ecx
  800df1:	0f b6 02             	movzbl (%edx),%eax
  800df4:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800df7:	80 3a 01             	cmpb   $0x1,(%edx)
  800dfa:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dfd:	39 cb                	cmp    %ecx,%ebx
  800dff:	75 ed                	jne    800dee <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e01:	89 f0                	mov    %esi,%eax
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	8b 75 08             	mov    0x8(%ebp),%esi
  800e0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e12:	8b 55 10             	mov    0x10(%ebp),%edx
  800e15:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e17:	85 d2                	test   %edx,%edx
  800e19:	74 35                	je     800e50 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800e1b:	89 d0                	mov    %edx,%eax
  800e1d:	83 e8 01             	sub    $0x1,%eax
  800e20:	74 25                	je     800e47 <strlcpy+0x40>
  800e22:	0f b6 0b             	movzbl (%ebx),%ecx
  800e25:	84 c9                	test   %cl,%cl
  800e27:	74 22                	je     800e4b <strlcpy+0x44>
  800e29:	8d 53 01             	lea    0x1(%ebx),%edx
  800e2c:	01 c3                	add    %eax,%ebx
  800e2e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e30:	83 c0 01             	add    $0x1,%eax
  800e33:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e36:	39 da                	cmp    %ebx,%edx
  800e38:	74 13                	je     800e4d <strlcpy+0x46>
  800e3a:	83 c2 01             	add    $0x1,%edx
  800e3d:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e41:	84 c9                	test   %cl,%cl
  800e43:	75 eb                	jne    800e30 <strlcpy+0x29>
  800e45:	eb 06                	jmp    800e4d <strlcpy+0x46>
  800e47:	89 f0                	mov    %esi,%eax
  800e49:	eb 02                	jmp    800e4d <strlcpy+0x46>
  800e4b:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e4d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e50:	29 f0                	sub    %esi,%eax
}
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e5f:	0f b6 01             	movzbl (%ecx),%eax
  800e62:	84 c0                	test   %al,%al
  800e64:	74 15                	je     800e7b <strcmp+0x25>
  800e66:	3a 02                	cmp    (%edx),%al
  800e68:	75 11                	jne    800e7b <strcmp+0x25>
		p++, q++;
  800e6a:	83 c1 01             	add    $0x1,%ecx
  800e6d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e70:	0f b6 01             	movzbl (%ecx),%eax
  800e73:	84 c0                	test   %al,%al
  800e75:	74 04                	je     800e7b <strcmp+0x25>
  800e77:	3a 02                	cmp    (%edx),%al
  800e79:	74 ef                	je     800e6a <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e7b:	0f b6 c0             	movzbl %al,%eax
  800e7e:	0f b6 12             	movzbl (%edx),%edx
  800e81:	29 d0                	sub    %edx,%eax
}
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e90:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e93:	85 f6                	test   %esi,%esi
  800e95:	74 29                	je     800ec0 <strncmp+0x3b>
  800e97:	0f b6 03             	movzbl (%ebx),%eax
  800e9a:	84 c0                	test   %al,%al
  800e9c:	74 30                	je     800ece <strncmp+0x49>
  800e9e:	3a 02                	cmp    (%edx),%al
  800ea0:	75 2c                	jne    800ece <strncmp+0x49>
  800ea2:	8d 43 01             	lea    0x1(%ebx),%eax
  800ea5:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800ea7:	89 c3                	mov    %eax,%ebx
  800ea9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800eac:	39 c6                	cmp    %eax,%esi
  800eae:	74 17                	je     800ec7 <strncmp+0x42>
  800eb0:	0f b6 08             	movzbl (%eax),%ecx
  800eb3:	84 c9                	test   %cl,%cl
  800eb5:	74 17                	je     800ece <strncmp+0x49>
  800eb7:	83 c0 01             	add    $0x1,%eax
  800eba:	3a 0a                	cmp    (%edx),%cl
  800ebc:	74 e9                	je     800ea7 <strncmp+0x22>
  800ebe:	eb 0e                	jmp    800ece <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	eb 0f                	jmp    800ed6 <strncmp+0x51>
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecc:	eb 08                	jmp    800ed6 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ece:	0f b6 03             	movzbl (%ebx),%eax
  800ed1:	0f b6 12             	movzbl (%edx),%edx
  800ed4:	29 d0                	sub    %edx,%eax
}
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	53                   	push   %ebx
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ee4:	0f b6 10             	movzbl (%eax),%edx
  800ee7:	84 d2                	test   %dl,%dl
  800ee9:	74 1d                	je     800f08 <strchr+0x2e>
  800eeb:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800eed:	38 d3                	cmp    %dl,%bl
  800eef:	75 06                	jne    800ef7 <strchr+0x1d>
  800ef1:	eb 1a                	jmp    800f0d <strchr+0x33>
  800ef3:	38 ca                	cmp    %cl,%dl
  800ef5:	74 16                	je     800f0d <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ef7:	83 c0 01             	add    $0x1,%eax
  800efa:	0f b6 10             	movzbl (%eax),%edx
  800efd:	84 d2                	test   %dl,%dl
  800eff:	75 f2                	jne    800ef3 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	eb 05                	jmp    800f0d <strchr+0x33>
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f0d:	5b                   	pop    %ebx
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	53                   	push   %ebx
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
  800f17:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800f1a:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800f1d:	38 d3                	cmp    %dl,%bl
  800f1f:	74 14                	je     800f35 <strfind+0x25>
  800f21:	89 d1                	mov    %edx,%ecx
  800f23:	84 db                	test   %bl,%bl
  800f25:	74 0e                	je     800f35 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f27:	83 c0 01             	add    $0x1,%eax
  800f2a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f2d:	38 ca                	cmp    %cl,%dl
  800f2f:	74 04                	je     800f35 <strfind+0x25>
  800f31:	84 d2                	test   %dl,%dl
  800f33:	75 f2                	jne    800f27 <strfind+0x17>
			break;
	return (char *) s;
}
  800f35:	5b                   	pop    %ebx
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f41:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f44:	85 c9                	test   %ecx,%ecx
  800f46:	74 36                	je     800f7e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f48:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f4e:	75 28                	jne    800f78 <memset+0x40>
  800f50:	f6 c1 03             	test   $0x3,%cl
  800f53:	75 23                	jne    800f78 <memset+0x40>
		c &= 0xFF;
  800f55:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f59:	89 d3                	mov    %edx,%ebx
  800f5b:	c1 e3 08             	shl    $0x8,%ebx
  800f5e:	89 d6                	mov    %edx,%esi
  800f60:	c1 e6 18             	shl    $0x18,%esi
  800f63:	89 d0                	mov    %edx,%eax
  800f65:	c1 e0 10             	shl    $0x10,%eax
  800f68:	09 f0                	or     %esi,%eax
  800f6a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f6c:	89 d8                	mov    %ebx,%eax
  800f6e:	09 d0                	or     %edx,%eax
  800f70:	c1 e9 02             	shr    $0x2,%ecx
  800f73:	fc                   	cld    
  800f74:	f3 ab                	rep stos %eax,%es:(%edi)
  800f76:	eb 06                	jmp    800f7e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7b:	fc                   	cld    
  800f7c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f7e:	89 f8                	mov    %edi,%eax
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	57                   	push   %edi
  800f89:	56                   	push   %esi
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f93:	39 c6                	cmp    %eax,%esi
  800f95:	73 35                	jae    800fcc <memmove+0x47>
  800f97:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f9a:	39 d0                	cmp    %edx,%eax
  800f9c:	73 2e                	jae    800fcc <memmove+0x47>
		s += n;
		d += n;
  800f9e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa1:	89 d6                	mov    %edx,%esi
  800fa3:	09 fe                	or     %edi,%esi
  800fa5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fab:	75 13                	jne    800fc0 <memmove+0x3b>
  800fad:	f6 c1 03             	test   $0x3,%cl
  800fb0:	75 0e                	jne    800fc0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fb2:	83 ef 04             	sub    $0x4,%edi
  800fb5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fb8:	c1 e9 02             	shr    $0x2,%ecx
  800fbb:	fd                   	std    
  800fbc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fbe:	eb 09                	jmp    800fc9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fc0:	83 ef 01             	sub    $0x1,%edi
  800fc3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fc6:	fd                   	std    
  800fc7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fc9:	fc                   	cld    
  800fca:	eb 1d                	jmp    800fe9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fcc:	89 f2                	mov    %esi,%edx
  800fce:	09 c2                	or     %eax,%edx
  800fd0:	f6 c2 03             	test   $0x3,%dl
  800fd3:	75 0f                	jne    800fe4 <memmove+0x5f>
  800fd5:	f6 c1 03             	test   $0x3,%cl
  800fd8:	75 0a                	jne    800fe4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fda:	c1 e9 02             	shr    $0x2,%ecx
  800fdd:	89 c7                	mov    %eax,%edi
  800fdf:	fc                   	cld    
  800fe0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fe2:	eb 05                	jmp    800fe9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fe4:	89 c7                	mov    %eax,%edi
  800fe6:	fc                   	cld    
  800fe7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ff0:	ff 75 10             	pushl  0x10(%ebp)
  800ff3:	ff 75 0c             	pushl  0xc(%ebp)
  800ff6:	ff 75 08             	pushl  0x8(%ebp)
  800ff9:	e8 87 ff ff ff       	call   800f85 <memmove>
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801009:	8b 75 0c             	mov    0xc(%ebp),%esi
  80100c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80100f:	85 c0                	test   %eax,%eax
  801011:	74 39                	je     80104c <memcmp+0x4c>
  801013:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801016:	0f b6 13             	movzbl (%ebx),%edx
  801019:	0f b6 0e             	movzbl (%esi),%ecx
  80101c:	38 ca                	cmp    %cl,%dl
  80101e:	75 17                	jne    801037 <memcmp+0x37>
  801020:	b8 00 00 00 00       	mov    $0x0,%eax
  801025:	eb 1a                	jmp    801041 <memcmp+0x41>
  801027:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  80102c:	83 c0 01             	add    $0x1,%eax
  80102f:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  801033:	38 ca                	cmp    %cl,%dl
  801035:	74 0a                	je     801041 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801037:	0f b6 c2             	movzbl %dl,%eax
  80103a:	0f b6 c9             	movzbl %cl,%ecx
  80103d:	29 c8                	sub    %ecx,%eax
  80103f:	eb 10                	jmp    801051 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801041:	39 f8                	cmp    %edi,%eax
  801043:	75 e2                	jne    801027 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801045:	b8 00 00 00 00       	mov    $0x0,%eax
  80104a:	eb 05                	jmp    801051 <memcmp+0x51>
  80104c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	53                   	push   %ebx
  80105a:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  80105d:	89 d0                	mov    %edx,%eax
  80105f:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801062:	39 c2                	cmp    %eax,%edx
  801064:	73 1d                	jae    801083 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  801066:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80106a:	0f b6 0a             	movzbl (%edx),%ecx
  80106d:	39 d9                	cmp    %ebx,%ecx
  80106f:	75 09                	jne    80107a <memfind+0x24>
  801071:	eb 14                	jmp    801087 <memfind+0x31>
  801073:	0f b6 0a             	movzbl (%edx),%ecx
  801076:	39 d9                	cmp    %ebx,%ecx
  801078:	74 11                	je     80108b <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80107a:	83 c2 01             	add    $0x1,%edx
  80107d:	39 d0                	cmp    %edx,%eax
  80107f:	75 f2                	jne    801073 <memfind+0x1d>
  801081:	eb 0a                	jmp    80108d <memfind+0x37>
  801083:	89 d0                	mov    %edx,%eax
  801085:	eb 06                	jmp    80108d <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801087:	89 d0                	mov    %edx,%eax
  801089:	eb 02                	jmp    80108d <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80108b:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80108d:	5b                   	pop    %ebx
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801099:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80109c:	0f b6 01             	movzbl (%ecx),%eax
  80109f:	3c 20                	cmp    $0x20,%al
  8010a1:	74 04                	je     8010a7 <strtol+0x17>
  8010a3:	3c 09                	cmp    $0x9,%al
  8010a5:	75 0e                	jne    8010b5 <strtol+0x25>
		s++;
  8010a7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010aa:	0f b6 01             	movzbl (%ecx),%eax
  8010ad:	3c 20                	cmp    $0x20,%al
  8010af:	74 f6                	je     8010a7 <strtol+0x17>
  8010b1:	3c 09                	cmp    $0x9,%al
  8010b3:	74 f2                	je     8010a7 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010b5:	3c 2b                	cmp    $0x2b,%al
  8010b7:	75 0a                	jne    8010c3 <strtol+0x33>
		s++;
  8010b9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8010c1:	eb 11                	jmp    8010d4 <strtol+0x44>
  8010c3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010c8:	3c 2d                	cmp    $0x2d,%al
  8010ca:	75 08                	jne    8010d4 <strtol+0x44>
		s++, neg = 1;
  8010cc:	83 c1 01             	add    $0x1,%ecx
  8010cf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010d4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010da:	75 15                	jne    8010f1 <strtol+0x61>
  8010dc:	80 39 30             	cmpb   $0x30,(%ecx)
  8010df:	75 10                	jne    8010f1 <strtol+0x61>
  8010e1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010e5:	75 7c                	jne    801163 <strtol+0xd3>
		s += 2, base = 16;
  8010e7:	83 c1 02             	add    $0x2,%ecx
  8010ea:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010ef:	eb 16                	jmp    801107 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010f1:	85 db                	test   %ebx,%ebx
  8010f3:	75 12                	jne    801107 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010f5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010fa:	80 39 30             	cmpb   $0x30,(%ecx)
  8010fd:	75 08                	jne    801107 <strtol+0x77>
		s++, base = 8;
  8010ff:	83 c1 01             	add    $0x1,%ecx
  801102:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801107:	b8 00 00 00 00       	mov    $0x0,%eax
  80110c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80110f:	0f b6 11             	movzbl (%ecx),%edx
  801112:	8d 72 d0             	lea    -0x30(%edx),%esi
  801115:	89 f3                	mov    %esi,%ebx
  801117:	80 fb 09             	cmp    $0x9,%bl
  80111a:	77 08                	ja     801124 <strtol+0x94>
			dig = *s - '0';
  80111c:	0f be d2             	movsbl %dl,%edx
  80111f:	83 ea 30             	sub    $0x30,%edx
  801122:	eb 22                	jmp    801146 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  801124:	8d 72 9f             	lea    -0x61(%edx),%esi
  801127:	89 f3                	mov    %esi,%ebx
  801129:	80 fb 19             	cmp    $0x19,%bl
  80112c:	77 08                	ja     801136 <strtol+0xa6>
			dig = *s - 'a' + 10;
  80112e:	0f be d2             	movsbl %dl,%edx
  801131:	83 ea 57             	sub    $0x57,%edx
  801134:	eb 10                	jmp    801146 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  801136:	8d 72 bf             	lea    -0x41(%edx),%esi
  801139:	89 f3                	mov    %esi,%ebx
  80113b:	80 fb 19             	cmp    $0x19,%bl
  80113e:	77 16                	ja     801156 <strtol+0xc6>
			dig = *s - 'A' + 10;
  801140:	0f be d2             	movsbl %dl,%edx
  801143:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801146:	3b 55 10             	cmp    0x10(%ebp),%edx
  801149:	7d 0b                	jge    801156 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  80114b:	83 c1 01             	add    $0x1,%ecx
  80114e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801152:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801154:	eb b9                	jmp    80110f <strtol+0x7f>

	if (endptr)
  801156:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80115a:	74 0d                	je     801169 <strtol+0xd9>
		*endptr = (char *) s;
  80115c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115f:	89 0e                	mov    %ecx,(%esi)
  801161:	eb 06                	jmp    801169 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801163:	85 db                	test   %ebx,%ebx
  801165:	74 98                	je     8010ff <strtol+0x6f>
  801167:	eb 9e                	jmp    801107 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801169:	89 c2                	mov    %eax,%edx
  80116b:	f7 da                	neg    %edx
  80116d:	85 ff                	test   %edi,%edi
  80116f:	0f 45 c2             	cmovne %edx,%eax
}
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    
  801177:	66 90                	xchg   %ax,%ax
  801179:	66 90                	xchg   %ax,%ax
  80117b:	66 90                	xchg   %ax,%ax
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
