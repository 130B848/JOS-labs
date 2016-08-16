
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
  800051:	e8 f1 02 00 00       	call   800347 <sys_env_set_pgfault_upcall>
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
	// cprintf("env_id = %08x\n", sys_getenvid());

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
  8000d4:	54                   	push   %esp
  8000d5:	55                   	push   %ebp
  8000d6:	56                   	push   %esi
  8000d7:	57                   	push   %edi
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	8d 35 e2 00 80 00    	lea    0x8000e2,%esi
  8000e0:	0f 34                	sysenter 

008000e2 <label_21>:
  8000e2:	5f                   	pop    %edi
  8000e3:	5e                   	pop    %esi
  8000e4:	5d                   	pop    %ebp
  8000e5:	5c                   	pop    %esp
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
  800105:	54                   	push   %esp
  800106:	55                   	push   %ebp
  800107:	56                   	push   %esi
  800108:	57                   	push   %edi
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	8d 35 13 01 80 00    	lea    0x800113,%esi
  800111:	0f 34                	sysenter 

00800113 <label_55>:
  800113:	5f                   	pop    %edi
  800114:	5e                   	pop    %esi
  800115:	5d                   	pop    %ebp
  800116:	5c                   	pop    %esp
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
  800137:	54                   	push   %esp
  800138:	55                   	push   %ebp
  800139:	56                   	push   %esi
  80013a:	57                   	push   %edi
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	8d 35 45 01 80 00    	lea    0x800145,%esi
  800143:	0f 34                	sysenter 

00800145 <label_90>:
  800145:	5f                   	pop    %edi
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	5c                   	pop    %esp
  800149:	5b                   	pop    %ebx
  80014a:	5a                   	pop    %edx
  80014b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80014c:	85 c0                	test   %eax,%eax
  80014e:	7e 17                	jle    800167 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	50                   	push   %eax
  800154:	6a 03                	push   $0x3
  800156:	68 0a 14 80 00       	push   $0x80140a
  80015b:	6a 2a                	push   $0x2a
  80015d:	68 27 14 80 00       	push   $0x801427
  800162:	e8 e5 02 00 00       	call   80044c <_panic>

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
  800186:	54                   	push   %esp
  800187:	55                   	push   %ebp
  800188:	56                   	push   %esi
  800189:	57                   	push   %edi
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	8d 35 94 01 80 00    	lea    0x800194,%esi
  800192:	0f 34                	sysenter 

00800194 <label_139>:
  800194:	5f                   	pop    %edi
  800195:	5e                   	pop    %esi
  800196:	5d                   	pop    %ebp
  800197:	5c                   	pop    %esp
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
  8001b9:	54                   	push   %esp
  8001ba:	55                   	push   %ebp
  8001bb:	56                   	push   %esi
  8001bc:	57                   	push   %edi
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	8d 35 c7 01 80 00    	lea    0x8001c7,%esi
  8001c5:	0f 34                	sysenter 

008001c7 <label_174>:
  8001c7:	5f                   	pop    %edi
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	5c                   	pop    %esp
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
  8001ea:	54                   	push   %esp
  8001eb:	55                   	push   %ebp
  8001ec:	56                   	push   %esi
  8001ed:	57                   	push   %edi
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	8d 35 f8 01 80 00    	lea    0x8001f8,%esi
  8001f6:	0f 34                	sysenter 

008001f8 <label_209>:
  8001f8:	5f                   	pop    %edi
  8001f9:	5e                   	pop    %esi
  8001fa:	5d                   	pop    %ebp
  8001fb:	5c                   	pop    %esp
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
  80021e:	54                   	push   %esp
  80021f:	55                   	push   %ebp
  800220:	56                   	push   %esi
  800221:	57                   	push   %edi
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8d 35 2c 02 80 00    	lea    0x80022c,%esi
  80022a:	0f 34                	sysenter 

0080022c <label_244>:
  80022c:	5f                   	pop    %edi
  80022d:	5e                   	pop    %esi
  80022e:	5d                   	pop    %ebp
  80022f:	5c                   	pop    %esp
  800230:	5b                   	pop    %ebx
  800231:	5a                   	pop    %edx
  800232:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 17                	jle    80024e <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 05                	push   $0x5
  80023d:	68 0a 14 80 00       	push   $0x80140a
  800242:	6a 2a                	push   $0x2a
  800244:	68 27 14 80 00       	push   $0x801427
  800249:	e8 fe 01 00 00       	call   80044c <_panic>

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

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80025a:	b8 06 00 00 00       	mov    $0x6,%eax
  80025f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800262:	8b 55 08             	mov    0x8(%ebp),%edx
  800265:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800268:	8b 7d 14             	mov    0x14(%ebp),%edi
  80026b:	51                   	push   %ecx
  80026c:	52                   	push   %edx
  80026d:	53                   	push   %ebx
  80026e:	54                   	push   %esp
  80026f:	55                   	push   %ebp
  800270:	56                   	push   %esi
  800271:	57                   	push   %edi
  800272:	89 e5                	mov    %esp,%ebp
  800274:	8d 35 7c 02 80 00    	lea    0x80027c,%esi
  80027a:	0f 34                	sysenter 

0080027c <label_295>:
  80027c:	5f                   	pop    %edi
  80027d:	5e                   	pop    %esi
  80027e:	5d                   	pop    %ebp
  80027f:	5c                   	pop    %esp
  800280:	5b                   	pop    %ebx
  800281:	5a                   	pop    %edx
  800282:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7e 17                	jle    80029e <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 06                	push   $0x6
  80028d:	68 0a 14 80 00       	push   $0x80140a
  800292:	6a 2a                	push   $0x2a
  800294:	68 27 14 80 00       	push   $0x801427
  800299:	e8 ae 01 00 00       	call   80044c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80029e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8002af:	b8 07 00 00 00       	mov    $0x7,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 fb                	mov    %edi,%ebx
  8002bc:	51                   	push   %ecx
  8002bd:	52                   	push   %edx
  8002be:	53                   	push   %ebx
  8002bf:	54                   	push   %esp
  8002c0:	55                   	push   %ebp
  8002c1:	56                   	push   %esi
  8002c2:	57                   	push   %edi
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	8d 35 cd 02 80 00    	lea    0x8002cd,%esi
  8002cb:	0f 34                	sysenter 

008002cd <label_344>:
  8002cd:	5f                   	pop    %edi
  8002ce:	5e                   	pop    %esi
  8002cf:	5d                   	pop    %ebp
  8002d0:	5c                   	pop    %esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5a                   	pop    %edx
  8002d3:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 07                	push   $0x7
  8002de:	68 0a 14 80 00       	push   $0x80140a
  8002e3:	6a 2a                	push   $0x2a
  8002e5:	68 27 14 80 00       	push   $0x801427
  8002ea:	e8 5d 01 00 00       	call   80044c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800300:	b8 09 00 00 00       	mov    $0x9,%eax
  800305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	89 fb                	mov    %edi,%ebx
  80030d:	51                   	push   %ecx
  80030e:	52                   	push   %edx
  80030f:	53                   	push   %ebx
  800310:	54                   	push   %esp
  800311:	55                   	push   %ebp
  800312:	56                   	push   %esi
  800313:	57                   	push   %edi
  800314:	89 e5                	mov    %esp,%ebp
  800316:	8d 35 1e 03 80 00    	lea    0x80031e,%esi
  80031c:	0f 34                	sysenter 

0080031e <label_393>:
  80031e:	5f                   	pop    %edi
  80031f:	5e                   	pop    %esi
  800320:	5d                   	pop    %ebp
  800321:	5c                   	pop    %esp
  800322:	5b                   	pop    %ebx
  800323:	5a                   	pop    %edx
  800324:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800325:	85 c0                	test   %eax,%eax
  800327:	7e 17                	jle    800340 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800329:	83 ec 0c             	sub    $0xc,%esp
  80032c:	50                   	push   %eax
  80032d:	6a 09                	push   $0x9
  80032f:	68 0a 14 80 00       	push   $0x80140a
  800334:	6a 2a                	push   $0x2a
  800336:	68 27 14 80 00       	push   $0x801427
  80033b:	e8 0c 01 00 00       	call   80044c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800340:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800343:	5b                   	pop    %ebx
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80034c:	bf 00 00 00 00       	mov    $0x0,%edi
  800351:	b8 0a 00 00 00       	mov    $0xa,%eax
  800356:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 fb                	mov    %edi,%ebx
  80035e:	51                   	push   %ecx
  80035f:	52                   	push   %edx
  800360:	53                   	push   %ebx
  800361:	54                   	push   %esp
  800362:	55                   	push   %ebp
  800363:	56                   	push   %esi
  800364:	57                   	push   %edi
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8d 35 6f 03 80 00    	lea    0x80036f,%esi
  80036d:	0f 34                	sysenter 

0080036f <label_442>:
  80036f:	5f                   	pop    %edi
  800370:	5e                   	pop    %esi
  800371:	5d                   	pop    %ebp
  800372:	5c                   	pop    %esp
  800373:	5b                   	pop    %ebx
  800374:	5a                   	pop    %edx
  800375:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800376:	85 c0                	test   %eax,%eax
  800378:	7e 17                	jle    800391 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80037a:	83 ec 0c             	sub    $0xc,%esp
  80037d:	50                   	push   %eax
  80037e:	6a 0a                	push   $0xa
  800380:	68 0a 14 80 00       	push   $0x80140a
  800385:	6a 2a                	push   $0x2a
  800387:	68 27 14 80 00       	push   $0x801427
  80038c:	e8 bb 00 00 00       	call   80044c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800391:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800394:	5b                   	pop    %ebx
  800395:	5f                   	pop    %edi
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80039d:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ab:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003ae:	51                   	push   %ecx
  8003af:	52                   	push   %edx
  8003b0:	53                   	push   %ebx
  8003b1:	54                   	push   %esp
  8003b2:	55                   	push   %ebp
  8003b3:	56                   	push   %esi
  8003b4:	57                   	push   %edi
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	8d 35 bf 03 80 00    	lea    0x8003bf,%esi
  8003bd:	0f 34                	sysenter 

008003bf <label_493>:
  8003bf:	5f                   	pop    %edi
  8003c0:	5e                   	pop    %esi
  8003c1:	5d                   	pop    %ebp
  8003c2:	5c                   	pop    %esp
  8003c3:	5b                   	pop    %ebx
  8003c4:	5a                   	pop    %edx
  8003c5:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003c6:	5b                   	pop    %ebx
  8003c7:	5f                   	pop    %edi
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d4:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003dc:	89 d9                	mov    %ebx,%ecx
  8003de:	89 df                	mov    %ebx,%edi
  8003e0:	51                   	push   %ecx
  8003e1:	52                   	push   %edx
  8003e2:	53                   	push   %ebx
  8003e3:	54                   	push   %esp
  8003e4:	55                   	push   %ebp
  8003e5:	56                   	push   %esi
  8003e6:	57                   	push   %edi
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	8d 35 f1 03 80 00    	lea    0x8003f1,%esi
  8003ef:	0f 34                	sysenter 

008003f1 <label_528>:
  8003f1:	5f                   	pop    %edi
  8003f2:	5e                   	pop    %esi
  8003f3:	5d                   	pop    %ebp
  8003f4:	5c                   	pop    %esp
  8003f5:	5b                   	pop    %ebx
  8003f6:	5a                   	pop    %edx
  8003f7:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	7e 17                	jle    800413 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8003fc:	83 ec 0c             	sub    $0xc,%esp
  8003ff:	50                   	push   %eax
  800400:	6a 0d                	push   $0xd
  800402:	68 0a 14 80 00       	push   $0x80140a
  800407:	6a 2a                	push   $0x2a
  800409:	68 27 14 80 00       	push   $0x801427
  80040e:	e8 39 00 00 00       	call   80044c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800413:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800416:	5b                   	pop    %ebx
  800417:	5f                   	pop    %edi
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80041f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800424:	b8 0e 00 00 00       	mov    $0xe,%eax
  800429:	8b 55 08             	mov    0x8(%ebp),%edx
  80042c:	89 cb                	mov    %ecx,%ebx
  80042e:	89 cf                	mov    %ecx,%edi
  800430:	51                   	push   %ecx
  800431:	52                   	push   %edx
  800432:	53                   	push   %ebx
  800433:	54                   	push   %esp
  800434:	55                   	push   %ebp
  800435:	56                   	push   %esi
  800436:	57                   	push   %edi
  800437:	89 e5                	mov    %esp,%ebp
  800439:	8d 35 41 04 80 00    	lea    0x800441,%esi
  80043f:	0f 34                	sysenter 

00800441 <label_577>:
  800441:	5f                   	pop    %edi
  800442:	5e                   	pop    %esi
  800443:	5d                   	pop    %ebp
  800444:	5c                   	pop    %esp
  800445:	5b                   	pop    %ebx
  800446:	5a                   	pop    %edx
  800447:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800448:	5b                   	pop    %ebx
  800449:	5f                   	pop    %edi
  80044a:	5d                   	pop    %ebp
  80044b:	c3                   	ret    

0080044c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800451:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800454:	a1 10 20 80 00       	mov    0x802010,%eax
  800459:	85 c0                	test   %eax,%eax
  80045b:	74 11                	je     80046e <_panic+0x22>
		cprintf("%s: ", argv0);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	50                   	push   %eax
  800461:	68 35 14 80 00       	push   $0x801435
  800466:	e8 d4 00 00 00       	call   80053f <cprintf>
  80046b:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800474:	e8 f5 fc ff ff       	call   80016e <sys_getenvid>
  800479:	83 ec 0c             	sub    $0xc,%esp
  80047c:	ff 75 0c             	pushl  0xc(%ebp)
  80047f:	ff 75 08             	pushl  0x8(%ebp)
  800482:	56                   	push   %esi
  800483:	50                   	push   %eax
  800484:	68 3c 14 80 00       	push   $0x80143c
  800489:	e8 b1 00 00 00       	call   80053f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80048e:	83 c4 18             	add    $0x18,%esp
  800491:	53                   	push   %ebx
  800492:	ff 75 10             	pushl  0x10(%ebp)
  800495:	e8 54 00 00 00       	call   8004ee <vcprintf>
	cprintf("\n");
  80049a:	c7 04 24 3a 14 80 00 	movl   $0x80143a,(%esp)
  8004a1:	e8 99 00 00 00       	call   80053f <cprintf>
  8004a6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a9:	cc                   	int3   
  8004aa:	eb fd                	jmp    8004a9 <_panic+0x5d>

008004ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 04             	sub    $0x4,%esp
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b6:	8b 13                	mov    (%ebx),%edx
  8004b8:	8d 42 01             	lea    0x1(%edx),%eax
  8004bb:	89 03                	mov    %eax,(%ebx)
  8004bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c9:	75 1a                	jne    8004e5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	68 ff 00 00 00       	push   $0xff
  8004d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d6:	50                   	push   %eax
  8004d7:	e8 e1 fb ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8004dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004e2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004e5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ec:	c9                   	leave  
  8004ed:	c3                   	ret    

008004ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fe:	00 00 00 
	b.cnt = 0;
  800501:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800508:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80050b:	ff 75 0c             	pushl  0xc(%ebp)
  80050e:	ff 75 08             	pushl  0x8(%ebp)
  800511:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800517:	50                   	push   %eax
  800518:	68 ac 04 80 00       	push   $0x8004ac
  80051d:	e8 c0 02 00 00       	call   8007e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800522:	83 c4 08             	add    $0x8,%esp
  800525:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80052b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800531:	50                   	push   %eax
  800532:	e8 86 fb ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  800537:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800545:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800548:	50                   	push   %eax
  800549:	ff 75 08             	pushl  0x8(%ebp)
  80054c:	e8 9d ff ff ff       	call   8004ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800551:	c9                   	leave  
  800552:	c3                   	ret    

00800553 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	57                   	push   %edi
  800557:	56                   	push   %esi
  800558:	53                   	push   %ebx
  800559:	83 ec 1c             	sub    $0x1c,%esp
  80055c:	89 c7                	mov    %eax,%edi
  80055e:	89 d6                	mov    %edx,%esi
  800560:	8b 45 08             	mov    0x8(%ebp),%eax
  800563:	8b 55 0c             	mov    0xc(%ebp),%edx
  800566:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800569:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80056c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80056f:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800573:	0f 85 bf 00 00 00    	jne    800638 <printnum+0xe5>
  800579:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  80057f:	0f 8d de 00 00 00    	jge    800663 <printnum+0x110>
		judge_time_for_space = width;
  800585:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  80058b:	e9 d3 00 00 00       	jmp    800663 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800590:	83 eb 01             	sub    $0x1,%ebx
  800593:	85 db                	test   %ebx,%ebx
  800595:	7f 37                	jg     8005ce <printnum+0x7b>
  800597:	e9 ea 00 00 00       	jmp    800686 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80059c:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80059f:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	56                   	push   %esi
  8005a8:	83 ec 04             	sub    $0x4,%esp
  8005ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8005ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b7:	e8 d4 0c 00 00       	call   801290 <__umoddi3>
  8005bc:	83 c4 14             	add    $0x14,%esp
  8005bf:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff d7                	call   *%edi
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	eb 16                	jmp    8005e4 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	56                   	push   %esi
  8005d2:	ff 75 18             	pushl  0x18(%ebp)
  8005d5:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	83 eb 01             	sub    $0x1,%ebx
  8005dd:	75 ef                	jne    8005ce <printnum+0x7b>
  8005df:	e9 a2 00 00 00       	jmp    800686 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005e4:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005ea:	0f 85 76 01 00 00    	jne    800766 <printnum+0x213>
		while(num_of_space-- > 0)
  8005f0:	a1 04 20 80 00       	mov    0x802004,%eax
  8005f5:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005f8:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005fe:	85 c0                	test   %eax,%eax
  800600:	7e 1d                	jle    80061f <printnum+0xcc>
			putch(' ', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	56                   	push   %esi
  800606:	6a 20                	push   $0x20
  800608:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80060a:	a1 04 20 80 00       	mov    0x802004,%eax
  80060f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800612:	89 15 04 20 80 00    	mov    %edx,0x802004
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	85 c0                	test   %eax,%eax
  80061d:	7f e3                	jg     800602 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  80061f:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800626:	00 00 00 
		judge_time_for_space = 0;
  800629:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800630:	00 00 00 
	}
}
  800633:	e9 2e 01 00 00       	jmp    800766 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	ba 00 00 00 00       	mov    $0x0,%edx
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800646:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800649:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064c:	83 fa 00             	cmp    $0x0,%edx
  80064f:	0f 87 ba 00 00 00    	ja     80070f <printnum+0x1bc>
  800655:	3b 45 10             	cmp    0x10(%ebp),%eax
  800658:	0f 83 b1 00 00 00    	jae    80070f <printnum+0x1bc>
  80065e:	e9 2d ff ff ff       	jmp    800590 <printnum+0x3d>
  800663:	8b 45 10             	mov    0x10(%ebp),%eax
  800666:	ba 00 00 00 00       	mov    $0x0,%edx
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800671:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800674:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800677:	83 fa 00             	cmp    $0x0,%edx
  80067a:	77 37                	ja     8006b3 <printnum+0x160>
  80067c:	3b 45 10             	cmp    0x10(%ebp),%eax
  80067f:	73 32                	jae    8006b3 <printnum+0x160>
  800681:	e9 16 ff ff ff       	jmp    80059c <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	56                   	push   %esi
  80068a:	83 ec 04             	sub    $0x4,%esp
  80068d:	ff 75 dc             	pushl  -0x24(%ebp)
  800690:	ff 75 d8             	pushl  -0x28(%ebp)
  800693:	ff 75 e4             	pushl  -0x1c(%ebp)
  800696:	ff 75 e0             	pushl  -0x20(%ebp)
  800699:	e8 f2 0b 00 00       	call   801290 <__umoddi3>
  80069e:	83 c4 14             	add    $0x14,%esp
  8006a1:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  8006a8:	50                   	push   %eax
  8006a9:	ff d7                	call   *%edi
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	e9 b3 00 00 00       	jmp    800766 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	ff 75 18             	pushl  0x18(%ebp)
  8006b9:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006bc:	50                   	push   %eax
  8006bd:	ff 75 10             	pushl  0x10(%ebp)
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cf:	e8 8c 0a 00 00       	call   801160 <__udivdi3>
  8006d4:	83 c4 18             	add    $0x18,%esp
  8006d7:	52                   	push   %edx
  8006d8:	50                   	push   %eax
  8006d9:	89 f2                	mov    %esi,%edx
  8006db:	89 f8                	mov    %edi,%eax
  8006dd:	e8 71 fe ff ff       	call   800553 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006e2:	83 c4 18             	add    $0x18,%esp
  8006e5:	56                   	push   %esi
  8006e6:	83 ec 04             	sub    $0x4,%esp
  8006e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f5:	e8 96 0b 00 00       	call   801290 <__umoddi3>
  8006fa:	83 c4 14             	add    $0x14,%esp
  8006fd:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  800704:	50                   	push   %eax
  800705:	ff d7                	call   *%edi
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	e9 d5 fe ff ff       	jmp    8005e4 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070f:	83 ec 0c             	sub    $0xc,%esp
  800712:	ff 75 18             	pushl  0x18(%ebp)
  800715:	83 eb 01             	sub    $0x1,%ebx
  800718:	53                   	push   %ebx
  800719:	ff 75 10             	pushl  0x10(%ebp)
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	ff 75 dc             	pushl  -0x24(%ebp)
  800722:	ff 75 d8             	pushl  -0x28(%ebp)
  800725:	ff 75 e4             	pushl  -0x1c(%ebp)
  800728:	ff 75 e0             	pushl  -0x20(%ebp)
  80072b:	e8 30 0a 00 00       	call   801160 <__udivdi3>
  800730:	83 c4 18             	add    $0x18,%esp
  800733:	52                   	push   %edx
  800734:	50                   	push   %eax
  800735:	89 f2                	mov    %esi,%edx
  800737:	89 f8                	mov    %edi,%eax
  800739:	e8 15 fe ff ff       	call   800553 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80073e:	83 c4 18             	add    $0x18,%esp
  800741:	56                   	push   %esi
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	ff 75 dc             	pushl  -0x24(%ebp)
  800748:	ff 75 d8             	pushl  -0x28(%ebp)
  80074b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80074e:	ff 75 e0             	pushl  -0x20(%ebp)
  800751:	e8 3a 0b 00 00       	call   801290 <__umoddi3>
  800756:	83 c4 14             	add    $0x14,%esp
  800759:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  800760:	50                   	push   %eax
  800761:	ff d7                	call   *%edi
  800763:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800766:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800771:	83 fa 01             	cmp    $0x1,%edx
  800774:	7e 0e                	jle    800784 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800776:	8b 10                	mov    (%eax),%edx
  800778:	8d 4a 08             	lea    0x8(%edx),%ecx
  80077b:	89 08                	mov    %ecx,(%eax)
  80077d:	8b 02                	mov    (%edx),%eax
  80077f:	8b 52 04             	mov    0x4(%edx),%edx
  800782:	eb 22                	jmp    8007a6 <getuint+0x38>
	else if (lflag)
  800784:	85 d2                	test   %edx,%edx
  800786:	74 10                	je     800798 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800788:	8b 10                	mov    (%eax),%edx
  80078a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80078d:	89 08                	mov    %ecx,(%eax)
  80078f:	8b 02                	mov    (%edx),%eax
  800791:	ba 00 00 00 00       	mov    $0x0,%edx
  800796:	eb 0e                	jmp    8007a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800798:	8b 10                	mov    (%eax),%edx
  80079a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80079d:	89 08                	mov    %ecx,(%eax)
  80079f:	8b 02                	mov    (%edx),%eax
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ae:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007b2:	8b 10                	mov    (%eax),%edx
  8007b4:	3b 50 04             	cmp    0x4(%eax),%edx
  8007b7:	73 0a                	jae    8007c3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007b9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007bc:	89 08                	mov    %ecx,(%eax)
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	88 02                	mov    %al,(%edx)
}
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ce:	50                   	push   %eax
  8007cf:	ff 75 10             	pushl  0x10(%ebp)
  8007d2:	ff 75 0c             	pushl  0xc(%ebp)
  8007d5:	ff 75 08             	pushl  0x8(%ebp)
  8007d8:	e8 05 00 00 00       	call   8007e2 <vprintfmt>
	va_end(ap);
}
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	57                   	push   %edi
  8007e6:	56                   	push   %esi
  8007e7:	53                   	push   %ebx
  8007e8:	83 ec 2c             	sub    $0x2c,%esp
  8007eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f1:	eb 03                	jmp    8007f6 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f3:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f9:	8d 70 01             	lea    0x1(%eax),%esi
  8007fc:	0f b6 00             	movzbl (%eax),%eax
  8007ff:	83 f8 25             	cmp    $0x25,%eax
  800802:	74 27                	je     80082b <vprintfmt+0x49>
			if (ch == '\0')
  800804:	85 c0                	test   %eax,%eax
  800806:	75 0d                	jne    800815 <vprintfmt+0x33>
  800808:	e9 9d 04 00 00       	jmp    800caa <vprintfmt+0x4c8>
  80080d:	85 c0                	test   %eax,%eax
  80080f:	0f 84 95 04 00 00    	je     800caa <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	53                   	push   %ebx
  800819:	50                   	push   %eax
  80081a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80081c:	83 c6 01             	add    $0x1,%esi
  80081f:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	83 f8 25             	cmp    $0x25,%eax
  800829:	75 e2                	jne    80080d <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80082b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800830:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800834:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80083b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800842:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800849:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800850:	eb 08                	jmp    80085a <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800852:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800855:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8d 46 01             	lea    0x1(%esi),%eax
  80085d:	89 45 10             	mov    %eax,0x10(%ebp)
  800860:	0f b6 06             	movzbl (%esi),%eax
  800863:	0f b6 d0             	movzbl %al,%edx
  800866:	83 e8 23             	sub    $0x23,%eax
  800869:	3c 55                	cmp    $0x55,%al
  80086b:	0f 87 fa 03 00 00    	ja     800c6b <vprintfmt+0x489>
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
  80087b:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80087e:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800882:	eb d6                	jmp    80085a <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800884:	8d 42 d0             	lea    -0x30(%edx),%eax
  800887:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80088a:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80088e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800891:	83 fa 09             	cmp    $0x9,%edx
  800894:	77 6b                	ja     800901 <vprintfmt+0x11f>
  800896:	8b 75 10             	mov    0x10(%ebp),%esi
  800899:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80089c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80089f:	eb 09                	jmp    8008aa <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a1:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008a4:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008a8:	eb b0                	jmp    80085a <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008aa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008ad:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008b0:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008b4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008b7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008ba:	83 f9 09             	cmp    $0x9,%ecx
  8008bd:	76 eb                	jbe    8008aa <vprintfmt+0xc8>
  8008bf:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008c2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008c5:	eb 3d                	jmp    800904 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 50 04             	lea    0x4(%eax),%edx
  8008cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d0:	8b 00                	mov    (%eax),%eax
  8008d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d5:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008d8:	eb 2a                	jmp    800904 <vprintfmt+0x122>
  8008da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e4:	0f 49 d0             	cmovns %eax,%edx
  8008e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 75 10             	mov    0x10(%ebp),%esi
  8008ed:	e9 68 ff ff ff       	jmp    80085a <vprintfmt+0x78>
  8008f2:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008fc:	e9 59 ff ff ff       	jmp    80085a <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800901:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800904:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800908:	0f 89 4c ff ff ff    	jns    80085a <vprintfmt+0x78>
				width = precision, precision = -1;
  80090e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800911:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800914:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80091b:	e9 3a ff ff ff       	jmp    80085a <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800920:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800924:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800927:	e9 2e ff ff ff       	jmp    80085a <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8d 50 04             	lea    0x4(%eax),%edx
  800932:	89 55 14             	mov    %edx,0x14(%ebp)
  800935:	83 ec 08             	sub    $0x8,%esp
  800938:	53                   	push   %ebx
  800939:	ff 30                	pushl  (%eax)
  80093b:	ff d7                	call   *%edi
			break;
  80093d:	83 c4 10             	add    $0x10,%esp
  800940:	e9 b1 fe ff ff       	jmp    8007f6 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800945:	8b 45 14             	mov    0x14(%ebp),%eax
  800948:	8d 50 04             	lea    0x4(%eax),%edx
  80094b:	89 55 14             	mov    %edx,0x14(%ebp)
  80094e:	8b 00                	mov    (%eax),%eax
  800950:	99                   	cltd   
  800951:	31 d0                	xor    %edx,%eax
  800953:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800955:	83 f8 08             	cmp    $0x8,%eax
  800958:	7f 0b                	jg     800965 <vprintfmt+0x183>
  80095a:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  800961:	85 d2                	test   %edx,%edx
  800963:	75 15                	jne    80097a <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800965:	50                   	push   %eax
  800966:	68 77 14 80 00       	push   $0x801477
  80096b:	53                   	push   %ebx
  80096c:	57                   	push   %edi
  80096d:	e8 53 fe ff ff       	call   8007c5 <printfmt>
  800972:	83 c4 10             	add    $0x10,%esp
  800975:	e9 7c fe ff ff       	jmp    8007f6 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80097a:	52                   	push   %edx
  80097b:	68 80 14 80 00       	push   $0x801480
  800980:	53                   	push   %ebx
  800981:	57                   	push   %edi
  800982:	e8 3e fe ff ff       	call   8007c5 <printfmt>
  800987:	83 c4 10             	add    $0x10,%esp
  80098a:	e9 67 fe ff ff       	jmp    8007f6 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80099a:	85 c0                	test   %eax,%eax
  80099c:	b9 70 14 80 00       	mov    $0x801470,%ecx
  8009a1:	0f 45 c8             	cmovne %eax,%ecx
  8009a4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ab:	7e 06                	jle    8009b3 <vprintfmt+0x1d1>
  8009ad:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009b1:	75 19                	jne    8009cc <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b6:	8d 70 01             	lea    0x1(%eax),%esi
  8009b9:	0f b6 00             	movzbl (%eax),%eax
  8009bc:	0f be d0             	movsbl %al,%edx
  8009bf:	85 d2                	test   %edx,%edx
  8009c1:	0f 85 9f 00 00 00    	jne    800a66 <vprintfmt+0x284>
  8009c7:	e9 8c 00 00 00       	jmp    800a58 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cc:	83 ec 08             	sub    $0x8,%esp
  8009cf:	ff 75 d0             	pushl  -0x30(%ebp)
  8009d2:	ff 75 cc             	pushl  -0x34(%ebp)
  8009d5:	e8 62 03 00 00       	call   800d3c <strnlen>
  8009da:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009dd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009e0:	83 c4 10             	add    $0x10,%esp
  8009e3:	85 c9                	test   %ecx,%ecx
  8009e5:	0f 8e a6 02 00 00    	jle    800c91 <vprintfmt+0x4af>
					putch(padc, putdat);
  8009eb:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f2:	89 cb                	mov    %ecx,%ebx
  8009f4:	83 ec 08             	sub    $0x8,%esp
  8009f7:	ff 75 0c             	pushl  0xc(%ebp)
  8009fa:	56                   	push   %esi
  8009fb:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009fd:	83 c4 10             	add    $0x10,%esp
  800a00:	83 eb 01             	sub    $0x1,%ebx
  800a03:	75 ef                	jne    8009f4 <vprintfmt+0x212>
  800a05:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0b:	e9 81 02 00 00       	jmp    800c91 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a10:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a14:	74 1b                	je     800a31 <vprintfmt+0x24f>
  800a16:	0f be c0             	movsbl %al,%eax
  800a19:	83 e8 20             	sub    $0x20,%eax
  800a1c:	83 f8 5e             	cmp    $0x5e,%eax
  800a1f:	76 10                	jbe    800a31 <vprintfmt+0x24f>
					putch('?', putdat);
  800a21:	83 ec 08             	sub    $0x8,%esp
  800a24:	ff 75 0c             	pushl  0xc(%ebp)
  800a27:	6a 3f                	push   $0x3f
  800a29:	ff 55 08             	call   *0x8(%ebp)
  800a2c:	83 c4 10             	add    $0x10,%esp
  800a2f:	eb 0d                	jmp    800a3e <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	52                   	push   %edx
  800a38:	ff 55 08             	call   *0x8(%ebp)
  800a3b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3e:	83 ef 01             	sub    $0x1,%edi
  800a41:	83 c6 01             	add    $0x1,%esi
  800a44:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a48:	0f be d0             	movsbl %al,%edx
  800a4b:	85 d2                	test   %edx,%edx
  800a4d:	75 31                	jne    800a80 <vprintfmt+0x29e>
  800a4f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a52:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a58:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a5b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a5f:	7f 33                	jg     800a94 <vprintfmt+0x2b2>
  800a61:	e9 90 fd ff ff       	jmp    8007f6 <vprintfmt+0x14>
  800a66:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a6c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a6f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a72:	eb 0c                	jmp    800a80 <vprintfmt+0x29e>
  800a74:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a7d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	78 8c                	js     800a10 <vprintfmt+0x22e>
  800a84:	83 eb 01             	sub    $0x1,%ebx
  800a87:	79 87                	jns    800a10 <vprintfmt+0x22e>
  800a89:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a92:	eb c4                	jmp    800a58 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a94:	83 ec 08             	sub    $0x8,%esp
  800a97:	53                   	push   %ebx
  800a98:	6a 20                	push   $0x20
  800a9a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a9c:	83 c4 10             	add    $0x10,%esp
  800a9f:	83 ee 01             	sub    $0x1,%esi
  800aa2:	75 f0                	jne    800a94 <vprintfmt+0x2b2>
  800aa4:	e9 4d fd ff ff       	jmp    8007f6 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aa9:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800aad:	7e 16                	jle    800ac5 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800aaf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab2:	8d 50 08             	lea    0x8(%eax),%edx
  800ab5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab8:	8b 50 04             	mov    0x4(%eax),%edx
  800abb:	8b 00                	mov    (%eax),%eax
  800abd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ac0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ac3:	eb 34                	jmp    800af9 <vprintfmt+0x317>
	else if (lflag)
  800ac5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ac9:	74 18                	je     800ae3 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800acb:	8b 45 14             	mov    0x14(%ebp),%eax
  800ace:	8d 50 04             	lea    0x4(%eax),%edx
  800ad1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad4:	8b 30                	mov    (%eax),%esi
  800ad6:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ad9:	89 f0                	mov    %esi,%eax
  800adb:	c1 f8 1f             	sar    $0x1f,%eax
  800ade:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ae1:	eb 16                	jmp    800af9 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ae3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae6:	8d 50 04             	lea    0x4(%eax),%edx
  800ae9:	89 55 14             	mov    %edx,0x14(%ebp)
  800aec:	8b 30                	mov    (%eax),%esi
  800aee:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800af1:	89 f0                	mov    %esi,%eax
  800af3:	c1 f8 1f             	sar    $0x1f,%eax
  800af6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800af9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800afc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800aff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b02:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b05:	85 d2                	test   %edx,%edx
  800b07:	79 28                	jns    800b31 <vprintfmt+0x34f>
				putch('-', putdat);
  800b09:	83 ec 08             	sub    $0x8,%esp
  800b0c:	53                   	push   %ebx
  800b0d:	6a 2d                	push   $0x2d
  800b0f:	ff d7                	call   *%edi
				num = -(long long) num;
  800b11:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b14:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b17:	f7 d8                	neg    %eax
  800b19:	83 d2 00             	adc    $0x0,%edx
  800b1c:	f7 da                	neg    %edx
  800b1e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b21:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b24:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2c:	e9 b2 00 00 00       	jmp    800be3 <vprintfmt+0x401>
  800b31:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b36:	85 c9                	test   %ecx,%ecx
  800b38:	0f 84 a5 00 00 00    	je     800be3 <vprintfmt+0x401>
				putch('+', putdat);
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	53                   	push   %ebx
  800b42:	6a 2b                	push   $0x2b
  800b44:	ff d7                	call   *%edi
  800b46:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4e:	e9 90 00 00 00       	jmp    800be3 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b53:	85 c9                	test   %ecx,%ecx
  800b55:	74 0b                	je     800b62 <vprintfmt+0x380>
				putch('+', putdat);
  800b57:	83 ec 08             	sub    $0x8,%esp
  800b5a:	53                   	push   %ebx
  800b5b:	6a 2b                	push   $0x2b
  800b5d:	ff d7                	call   *%edi
  800b5f:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b62:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b65:	8d 45 14             	lea    0x14(%ebp),%eax
  800b68:	e8 01 fc ff ff       	call   80076e <getuint>
  800b6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b70:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b73:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b78:	eb 69                	jmp    800be3 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	6a 30                	push   $0x30
  800b80:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b82:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b85:	8d 45 14             	lea    0x14(%ebp),%eax
  800b88:	e8 e1 fb ff ff       	call   80076e <getuint>
  800b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b90:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b93:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b96:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b9b:	eb 46                	jmp    800be3 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b9d:	83 ec 08             	sub    $0x8,%esp
  800ba0:	53                   	push   %ebx
  800ba1:	6a 30                	push   $0x30
  800ba3:	ff d7                	call   *%edi
			putch('x', putdat);
  800ba5:	83 c4 08             	add    $0x8,%esp
  800ba8:	53                   	push   %ebx
  800ba9:	6a 78                	push   $0x78
  800bab:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bad:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb0:	8d 50 04             	lea    0x4(%eax),%edx
  800bb3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bb6:	8b 00                	mov    (%eax),%eax
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bc0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bc3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bc6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bcb:	eb 16                	jmp    800be3 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bcd:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bd0:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd3:	e8 96 fb ff ff       	call   80076e <getuint>
  800bd8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bdb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bde:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bea:	56                   	push   %esi
  800beb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bee:	50                   	push   %eax
  800bef:	ff 75 dc             	pushl  -0x24(%ebp)
  800bf2:	ff 75 d8             	pushl  -0x28(%ebp)
  800bf5:	89 da                	mov    %ebx,%edx
  800bf7:	89 f8                	mov    %edi,%eax
  800bf9:	e8 55 f9 ff ff       	call   800553 <printnum>
			break;
  800bfe:	83 c4 20             	add    $0x20,%esp
  800c01:	e9 f0 fb ff ff       	jmp    8007f6 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c06:	8b 45 14             	mov    0x14(%ebp),%eax
  800c09:	8d 50 04             	lea    0x4(%eax),%edx
  800c0c:	89 55 14             	mov    %edx,0x14(%ebp)
  800c0f:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c11:	85 f6                	test   %esi,%esi
  800c13:	75 1a                	jne    800c2f <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c15:	83 ec 08             	sub    $0x8,%esp
  800c18:	68 18 15 80 00       	push   $0x801518
  800c1d:	68 80 14 80 00       	push   $0x801480
  800c22:	e8 18 f9 ff ff       	call   80053f <cprintf>
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	e9 c7 fb ff ff       	jmp    8007f6 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c2f:	0f b6 03             	movzbl (%ebx),%eax
  800c32:	84 c0                	test   %al,%al
  800c34:	79 1f                	jns    800c55 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c36:	83 ec 08             	sub    $0x8,%esp
  800c39:	68 50 15 80 00       	push   $0x801550
  800c3e:	68 80 14 80 00       	push   $0x801480
  800c43:	e8 f7 f8 ff ff       	call   80053f <cprintf>
						*tmp = *(char *)putdat;
  800c48:	0f b6 03             	movzbl (%ebx),%eax
  800c4b:	88 06                	mov    %al,(%esi)
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	e9 a1 fb ff ff       	jmp    8007f6 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c55:	88 06                	mov    %al,(%esi)
  800c57:	e9 9a fb ff ff       	jmp    8007f6 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c5c:	83 ec 08             	sub    $0x8,%esp
  800c5f:	53                   	push   %ebx
  800c60:	52                   	push   %edx
  800c61:	ff d7                	call   *%edi
			break;
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	e9 8b fb ff ff       	jmp    8007f6 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c6b:	83 ec 08             	sub    $0x8,%esp
  800c6e:	53                   	push   %ebx
  800c6f:	6a 25                	push   $0x25
  800c71:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c7a:	0f 84 73 fb ff ff    	je     8007f3 <vprintfmt+0x11>
  800c80:	83 ee 01             	sub    $0x1,%esi
  800c83:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c87:	75 f7                	jne    800c80 <vprintfmt+0x49e>
  800c89:	89 75 10             	mov    %esi,0x10(%ebp)
  800c8c:	e9 65 fb ff ff       	jmp    8007f6 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c91:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c94:	8d 70 01             	lea    0x1(%eax),%esi
  800c97:	0f b6 00             	movzbl (%eax),%eax
  800c9a:	0f be d0             	movsbl %al,%edx
  800c9d:	85 d2                	test   %edx,%edx
  800c9f:	0f 85 cf fd ff ff    	jne    800a74 <vprintfmt+0x292>
  800ca5:	e9 4c fb ff ff       	jmp    8007f6 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	83 ec 18             	sub    $0x18,%esp
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cc1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cc5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	74 26                	je     800cf9 <vsnprintf+0x47>
  800cd3:	85 d2                	test   %edx,%edx
  800cd5:	7e 22                	jle    800cf9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cd7:	ff 75 14             	pushl  0x14(%ebp)
  800cda:	ff 75 10             	pushl  0x10(%ebp)
  800cdd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ce0:	50                   	push   %eax
  800ce1:	68 a8 07 80 00       	push   $0x8007a8
  800ce6:	e8 f7 fa ff ff       	call   8007e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ceb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf4:	83 c4 10             	add    $0x10,%esp
  800cf7:	eb 05                	jmp    800cfe <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cf9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    

00800d00 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d06:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d09:	50                   	push   %eax
  800d0a:	ff 75 10             	pushl  0x10(%ebp)
  800d0d:	ff 75 0c             	pushl  0xc(%ebp)
  800d10:	ff 75 08             	pushl  0x8(%ebp)
  800d13:	e8 9a ff ff ff       	call   800cb2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d20:	80 3a 00             	cmpb   $0x0,(%edx)
  800d23:	74 10                	je     800d35 <strlen+0x1b>
  800d25:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d2a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d2d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d31:	75 f7                	jne    800d2a <strlen+0x10>
  800d33:	eb 05                	jmp    800d3a <strlen+0x20>
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	53                   	push   %ebx
  800d40:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d46:	85 c9                	test   %ecx,%ecx
  800d48:	74 1c                	je     800d66 <strnlen+0x2a>
  800d4a:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d4d:	74 1e                	je     800d6d <strnlen+0x31>
  800d4f:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d54:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d56:	39 ca                	cmp    %ecx,%edx
  800d58:	74 18                	je     800d72 <strnlen+0x36>
  800d5a:	83 c2 01             	add    $0x1,%edx
  800d5d:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d62:	75 f0                	jne    800d54 <strnlen+0x18>
  800d64:	eb 0c                	jmp    800d72 <strnlen+0x36>
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6b:	eb 05                	jmp    800d72 <strnlen+0x36>
  800d6d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d72:	5b                   	pop    %ebx
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	53                   	push   %ebx
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d7f:	89 c2                	mov    %eax,%edx
  800d81:	83 c2 01             	add    $0x1,%edx
  800d84:	83 c1 01             	add    $0x1,%ecx
  800d87:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d8b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d8e:	84 db                	test   %bl,%bl
  800d90:	75 ef                	jne    800d81 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d92:	5b                   	pop    %ebx
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	53                   	push   %ebx
  800d99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d9c:	53                   	push   %ebx
  800d9d:	e8 78 ff ff ff       	call   800d1a <strlen>
  800da2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800da5:	ff 75 0c             	pushl  0xc(%ebp)
  800da8:	01 d8                	add    %ebx,%eax
  800daa:	50                   	push   %eax
  800dab:	e8 c5 ff ff ff       	call   800d75 <strcpy>
	return dst;
}
  800db0:	89 d8                	mov    %ebx,%eax
  800db2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc5:	85 db                	test   %ebx,%ebx
  800dc7:	74 17                	je     800de0 <strncpy+0x29>
  800dc9:	01 f3                	add    %esi,%ebx
  800dcb:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dcd:	83 c1 01             	add    $0x1,%ecx
  800dd0:	0f b6 02             	movzbl (%edx),%eax
  800dd3:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dd6:	80 3a 01             	cmpb   $0x1,(%edx)
  800dd9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ddc:	39 cb                	cmp    %ecx,%ebx
  800dde:	75 ed                	jne    800dcd <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800de0:	89 f0                	mov    %esi,%eax
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
  800deb:	8b 75 08             	mov    0x8(%ebp),%esi
  800dee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800df1:	8b 55 10             	mov    0x10(%ebp),%edx
  800df4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800df6:	85 d2                	test   %edx,%edx
  800df8:	74 35                	je     800e2f <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800dfa:	89 d0                	mov    %edx,%eax
  800dfc:	83 e8 01             	sub    $0x1,%eax
  800dff:	74 25                	je     800e26 <strlcpy+0x40>
  800e01:	0f b6 0b             	movzbl (%ebx),%ecx
  800e04:	84 c9                	test   %cl,%cl
  800e06:	74 22                	je     800e2a <strlcpy+0x44>
  800e08:	8d 53 01             	lea    0x1(%ebx),%edx
  800e0b:	01 c3                	add    %eax,%ebx
  800e0d:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e0f:	83 c0 01             	add    $0x1,%eax
  800e12:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e15:	39 da                	cmp    %ebx,%edx
  800e17:	74 13                	je     800e2c <strlcpy+0x46>
  800e19:	83 c2 01             	add    $0x1,%edx
  800e1c:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e20:	84 c9                	test   %cl,%cl
  800e22:	75 eb                	jne    800e0f <strlcpy+0x29>
  800e24:	eb 06                	jmp    800e2c <strlcpy+0x46>
  800e26:	89 f0                	mov    %esi,%eax
  800e28:	eb 02                	jmp    800e2c <strlcpy+0x46>
  800e2a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e2c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e2f:	29 f0                	sub    %esi,%eax
}
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e3e:	0f b6 01             	movzbl (%ecx),%eax
  800e41:	84 c0                	test   %al,%al
  800e43:	74 15                	je     800e5a <strcmp+0x25>
  800e45:	3a 02                	cmp    (%edx),%al
  800e47:	75 11                	jne    800e5a <strcmp+0x25>
		p++, q++;
  800e49:	83 c1 01             	add    $0x1,%ecx
  800e4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e4f:	0f b6 01             	movzbl (%ecx),%eax
  800e52:	84 c0                	test   %al,%al
  800e54:	74 04                	je     800e5a <strcmp+0x25>
  800e56:	3a 02                	cmp    (%edx),%al
  800e58:	74 ef                	je     800e49 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e5a:	0f b6 c0             	movzbl %al,%eax
  800e5d:	0f b6 12             	movzbl (%edx),%edx
  800e60:	29 d0                	sub    %edx,%eax
}
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e72:	85 f6                	test   %esi,%esi
  800e74:	74 29                	je     800e9f <strncmp+0x3b>
  800e76:	0f b6 03             	movzbl (%ebx),%eax
  800e79:	84 c0                	test   %al,%al
  800e7b:	74 30                	je     800ead <strncmp+0x49>
  800e7d:	3a 02                	cmp    (%edx),%al
  800e7f:	75 2c                	jne    800ead <strncmp+0x49>
  800e81:	8d 43 01             	lea    0x1(%ebx),%eax
  800e84:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e8b:	39 c6                	cmp    %eax,%esi
  800e8d:	74 17                	je     800ea6 <strncmp+0x42>
  800e8f:	0f b6 08             	movzbl (%eax),%ecx
  800e92:	84 c9                	test   %cl,%cl
  800e94:	74 17                	je     800ead <strncmp+0x49>
  800e96:	83 c0 01             	add    $0x1,%eax
  800e99:	3a 0a                	cmp    (%edx),%cl
  800e9b:	74 e9                	je     800e86 <strncmp+0x22>
  800e9d:	eb 0e                	jmp    800ead <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea4:	eb 0f                	jmp    800eb5 <strncmp+0x51>
  800ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eab:	eb 08                	jmp    800eb5 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ead:	0f b6 03             	movzbl (%ebx),%eax
  800eb0:	0f b6 12             	movzbl (%edx),%edx
  800eb3:	29 d0                	sub    %edx,%eax
}
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	53                   	push   %ebx
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ec3:	0f b6 10             	movzbl (%eax),%edx
  800ec6:	84 d2                	test   %dl,%dl
  800ec8:	74 1d                	je     800ee7 <strchr+0x2e>
  800eca:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ecc:	38 d3                	cmp    %dl,%bl
  800ece:	75 06                	jne    800ed6 <strchr+0x1d>
  800ed0:	eb 1a                	jmp    800eec <strchr+0x33>
  800ed2:	38 ca                	cmp    %cl,%dl
  800ed4:	74 16                	je     800eec <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ed6:	83 c0 01             	add    $0x1,%eax
  800ed9:	0f b6 10             	movzbl (%eax),%edx
  800edc:	84 d2                	test   %dl,%dl
  800ede:	75 f2                	jne    800ed2 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	eb 05                	jmp    800eec <strchr+0x33>
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eec:	5b                   	pop    %ebx
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	53                   	push   %ebx
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ef9:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800efc:	38 d3                	cmp    %dl,%bl
  800efe:	74 14                	je     800f14 <strfind+0x25>
  800f00:	89 d1                	mov    %edx,%ecx
  800f02:	84 db                	test   %bl,%bl
  800f04:	74 0e                	je     800f14 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f06:	83 c0 01             	add    $0x1,%eax
  800f09:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f0c:	38 ca                	cmp    %cl,%dl
  800f0e:	74 04                	je     800f14 <strfind+0x25>
  800f10:	84 d2                	test   %dl,%dl
  800f12:	75 f2                	jne    800f06 <strfind+0x17>
			break;
	return (char *) s;
}
  800f14:	5b                   	pop    %ebx
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f23:	85 c9                	test   %ecx,%ecx
  800f25:	74 36                	je     800f5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f2d:	75 28                	jne    800f57 <memset+0x40>
  800f2f:	f6 c1 03             	test   $0x3,%cl
  800f32:	75 23                	jne    800f57 <memset+0x40>
		c &= 0xFF;
  800f34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	c1 e3 08             	shl    $0x8,%ebx
  800f3d:	89 d6                	mov    %edx,%esi
  800f3f:	c1 e6 18             	shl    $0x18,%esi
  800f42:	89 d0                	mov    %edx,%eax
  800f44:	c1 e0 10             	shl    $0x10,%eax
  800f47:	09 f0                	or     %esi,%eax
  800f49:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	09 d0                	or     %edx,%eax
  800f4f:	c1 e9 02             	shr    $0x2,%ecx
  800f52:	fc                   	cld    
  800f53:	f3 ab                	rep stos %eax,%es:(%edi)
  800f55:	eb 06                	jmp    800f5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5a:	fc                   	cld    
  800f5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f5d:	89 f8                	mov    %edi,%eax
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f72:	39 c6                	cmp    %eax,%esi
  800f74:	73 35                	jae    800fab <memmove+0x47>
  800f76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f79:	39 d0                	cmp    %edx,%eax
  800f7b:	73 2e                	jae    800fab <memmove+0x47>
		s += n;
		d += n;
  800f7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f80:	89 d6                	mov    %edx,%esi
  800f82:	09 fe                	or     %edi,%esi
  800f84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f8a:	75 13                	jne    800f9f <memmove+0x3b>
  800f8c:	f6 c1 03             	test   $0x3,%cl
  800f8f:	75 0e                	jne    800f9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f91:	83 ef 04             	sub    $0x4,%edi
  800f94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f97:	c1 e9 02             	shr    $0x2,%ecx
  800f9a:	fd                   	std    
  800f9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9d:	eb 09                	jmp    800fa8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f9f:	83 ef 01             	sub    $0x1,%edi
  800fa2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fa5:	fd                   	std    
  800fa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fa8:	fc                   	cld    
  800fa9:	eb 1d                	jmp    800fc8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fab:	89 f2                	mov    %esi,%edx
  800fad:	09 c2                	or     %eax,%edx
  800faf:	f6 c2 03             	test   $0x3,%dl
  800fb2:	75 0f                	jne    800fc3 <memmove+0x5f>
  800fb4:	f6 c1 03             	test   $0x3,%cl
  800fb7:	75 0a                	jne    800fc3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fb9:	c1 e9 02             	shr    $0x2,%ecx
  800fbc:	89 c7                	mov    %eax,%edi
  800fbe:	fc                   	cld    
  800fbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fc1:	eb 05                	jmp    800fc8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fc3:	89 c7                	mov    %eax,%edi
  800fc5:	fc                   	cld    
  800fc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fc8:	5e                   	pop    %esi
  800fc9:	5f                   	pop    %edi
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fcf:	ff 75 10             	pushl  0x10(%ebp)
  800fd2:	ff 75 0c             	pushl  0xc(%ebp)
  800fd5:	ff 75 08             	pushl  0x8(%ebp)
  800fd8:	e8 87 ff ff ff       	call   800f64 <memmove>
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fe8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800feb:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	74 39                	je     80102b <memcmp+0x4c>
  800ff2:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ff5:	0f b6 13             	movzbl (%ebx),%edx
  800ff8:	0f b6 0e             	movzbl (%esi),%ecx
  800ffb:	38 ca                	cmp    %cl,%dl
  800ffd:	75 17                	jne    801016 <memcmp+0x37>
  800fff:	b8 00 00 00 00       	mov    $0x0,%eax
  801004:	eb 1a                	jmp    801020 <memcmp+0x41>
  801006:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  80100b:	83 c0 01             	add    $0x1,%eax
  80100e:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  801012:	38 ca                	cmp    %cl,%dl
  801014:	74 0a                	je     801020 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801016:	0f b6 c2             	movzbl %dl,%eax
  801019:	0f b6 c9             	movzbl %cl,%ecx
  80101c:	29 c8                	sub    %ecx,%eax
  80101e:	eb 10                	jmp    801030 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801020:	39 f8                	cmp    %edi,%eax
  801022:	75 e2                	jne    801006 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801024:	b8 00 00 00 00       	mov    $0x0,%eax
  801029:	eb 05                	jmp    801030 <memcmp+0x51>
  80102b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	53                   	push   %ebx
  801039:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  80103c:	89 d0                	mov    %edx,%eax
  80103e:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801041:	39 c2                	cmp    %eax,%edx
  801043:	73 1d                	jae    801062 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  801045:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801049:	0f b6 0a             	movzbl (%edx),%ecx
  80104c:	39 d9                	cmp    %ebx,%ecx
  80104e:	75 09                	jne    801059 <memfind+0x24>
  801050:	eb 14                	jmp    801066 <memfind+0x31>
  801052:	0f b6 0a             	movzbl (%edx),%ecx
  801055:	39 d9                	cmp    %ebx,%ecx
  801057:	74 11                	je     80106a <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801059:	83 c2 01             	add    $0x1,%edx
  80105c:	39 d0                	cmp    %edx,%eax
  80105e:	75 f2                	jne    801052 <memfind+0x1d>
  801060:	eb 0a                	jmp    80106c <memfind+0x37>
  801062:	89 d0                	mov    %edx,%eax
  801064:	eb 06                	jmp    80106c <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801066:	89 d0                	mov    %edx,%eax
  801068:	eb 02                	jmp    80106c <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80106a:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80106c:	5b                   	pop    %ebx
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
  801075:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801078:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107b:	0f b6 01             	movzbl (%ecx),%eax
  80107e:	3c 20                	cmp    $0x20,%al
  801080:	74 04                	je     801086 <strtol+0x17>
  801082:	3c 09                	cmp    $0x9,%al
  801084:	75 0e                	jne    801094 <strtol+0x25>
		s++;
  801086:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801089:	0f b6 01             	movzbl (%ecx),%eax
  80108c:	3c 20                	cmp    $0x20,%al
  80108e:	74 f6                	je     801086 <strtol+0x17>
  801090:	3c 09                	cmp    $0x9,%al
  801092:	74 f2                	je     801086 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801094:	3c 2b                	cmp    $0x2b,%al
  801096:	75 0a                	jne    8010a2 <strtol+0x33>
		s++;
  801098:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80109b:	bf 00 00 00 00       	mov    $0x0,%edi
  8010a0:	eb 11                	jmp    8010b3 <strtol+0x44>
  8010a2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010a7:	3c 2d                	cmp    $0x2d,%al
  8010a9:	75 08                	jne    8010b3 <strtol+0x44>
		s++, neg = 1;
  8010ab:	83 c1 01             	add    $0x1,%ecx
  8010ae:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010b9:	75 15                	jne    8010d0 <strtol+0x61>
  8010bb:	80 39 30             	cmpb   $0x30,(%ecx)
  8010be:	75 10                	jne    8010d0 <strtol+0x61>
  8010c0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010c4:	75 7c                	jne    801142 <strtol+0xd3>
		s += 2, base = 16;
  8010c6:	83 c1 02             	add    $0x2,%ecx
  8010c9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010ce:	eb 16                	jmp    8010e6 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010d0:	85 db                	test   %ebx,%ebx
  8010d2:	75 12                	jne    8010e6 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010d4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010d9:	80 39 30             	cmpb   $0x30,(%ecx)
  8010dc:	75 08                	jne    8010e6 <strtol+0x77>
		s++, base = 8;
  8010de:	83 c1 01             	add    $0x1,%ecx
  8010e1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010eb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010ee:	0f b6 11             	movzbl (%ecx),%edx
  8010f1:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010f4:	89 f3                	mov    %esi,%ebx
  8010f6:	80 fb 09             	cmp    $0x9,%bl
  8010f9:	77 08                	ja     801103 <strtol+0x94>
			dig = *s - '0';
  8010fb:	0f be d2             	movsbl %dl,%edx
  8010fe:	83 ea 30             	sub    $0x30,%edx
  801101:	eb 22                	jmp    801125 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  801103:	8d 72 9f             	lea    -0x61(%edx),%esi
  801106:	89 f3                	mov    %esi,%ebx
  801108:	80 fb 19             	cmp    $0x19,%bl
  80110b:	77 08                	ja     801115 <strtol+0xa6>
			dig = *s - 'a' + 10;
  80110d:	0f be d2             	movsbl %dl,%edx
  801110:	83 ea 57             	sub    $0x57,%edx
  801113:	eb 10                	jmp    801125 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  801115:	8d 72 bf             	lea    -0x41(%edx),%esi
  801118:	89 f3                	mov    %esi,%ebx
  80111a:	80 fb 19             	cmp    $0x19,%bl
  80111d:	77 16                	ja     801135 <strtol+0xc6>
			dig = *s - 'A' + 10;
  80111f:	0f be d2             	movsbl %dl,%edx
  801122:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801125:	3b 55 10             	cmp    0x10(%ebp),%edx
  801128:	7d 0b                	jge    801135 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  80112a:	83 c1 01             	add    $0x1,%ecx
  80112d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801131:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801133:	eb b9                	jmp    8010ee <strtol+0x7f>

	if (endptr)
  801135:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801139:	74 0d                	je     801148 <strtol+0xd9>
		*endptr = (char *) s;
  80113b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80113e:	89 0e                	mov    %ecx,(%esi)
  801140:	eb 06                	jmp    801148 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801142:	85 db                	test   %ebx,%ebx
  801144:	74 98                	je     8010de <strtol+0x6f>
  801146:	eb 9e                	jmp    8010e6 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801148:	89 c2                	mov    %eax,%edx
  80114a:	f7 da                	neg    %edx
  80114c:	85 ff                	test   %edi,%edi
  80114e:	0f 45 c2             	cmovne %edx,%eax
}
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    
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
