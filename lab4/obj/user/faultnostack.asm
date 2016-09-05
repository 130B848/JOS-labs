
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
  800039:	68 5c 04 80 00       	push   $0x80045c
  80003e:	6a 00                	push   $0x0
  800040:	e8 12 03 00 00       	call   800357 <sys_env_set_pgfault_upcall>
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
  8000c3:	56                   	push   %esi
  8000c4:	57                   	push   %edi
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	8d 35 d0 00 80 00    	lea    0x8000d0,%esi
  8000ce:	0f 34                	sysenter 

008000d0 <label_21>:
  8000d0:	89 ec                	mov    %ebp,%esp
  8000d2:	5d                   	pop    %ebp
  8000d3:	5f                   	pop    %edi
  8000d4:	5e                   	pop    %esi
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
  8000f4:	56                   	push   %esi
  8000f5:	57                   	push   %edi
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	8d 35 01 01 80 00    	lea    0x800101,%esi
  8000ff:	0f 34                	sysenter 

00800101 <label_55>:
  800101:	89 ec                	mov    %ebp,%esp
  800103:	5d                   	pop    %ebp
  800104:	5f                   	pop    %edi
  800105:	5e                   	pop    %esi
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
  800126:	56                   	push   %esi
  800127:	57                   	push   %edi
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	8d 35 33 01 80 00    	lea    0x800133,%esi
  800131:	0f 34                	sysenter 

00800133 <label_90>:
  800133:	89 ec                	mov    %ebp,%esp
  800135:	5d                   	pop    %ebp
  800136:	5f                   	pop    %edi
  800137:	5e                   	pop    %esi
  800138:	5b                   	pop    %ebx
  800139:	5a                   	pop    %edx
  80013a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80013b:	85 c0                	test   %eax,%eax
  80013d:	7e 17                	jle    800156 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	50                   	push   %eax
  800143:	6a 03                	push   $0x3
  800145:	68 8a 14 80 00       	push   $0x80148a
  80014a:	6a 30                	push   $0x30
  80014c:	68 a7 14 80 00       	push   $0x8014a7
  800151:	e8 2c 03 00 00       	call   800482 <_panic>

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
  800175:	56                   	push   %esi
  800176:	57                   	push   %edi
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	8d 35 82 01 80 00    	lea    0x800182,%esi
  800180:	0f 34                	sysenter 

00800182 <label_139>:
  800182:	89 ec                	mov    %ebp,%esp
  800184:	5d                   	pop    %ebp
  800185:	5f                   	pop    %edi
  800186:	5e                   	pop    %esi
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
  8001a8:	56                   	push   %esi
  8001a9:	57                   	push   %edi
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	8d 35 b5 01 80 00    	lea    0x8001b5,%esi
  8001b3:	0f 34                	sysenter 

008001b5 <label_174>:
  8001b5:	89 ec                	mov    %ebp,%esp
  8001b7:	5d                   	pop    %ebp
  8001b8:	5f                   	pop    %edi
  8001b9:	5e                   	pop    %esi
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
  8001d9:	56                   	push   %esi
  8001da:	57                   	push   %edi
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	8d 35 e6 01 80 00    	lea    0x8001e6,%esi
  8001e4:	0f 34                	sysenter 

008001e6 <label_209>:
  8001e6:	89 ec                	mov    %ebp,%esp
  8001e8:	5d                   	pop    %ebp
  8001e9:	5f                   	pop    %edi
  8001ea:	5e                   	pop    %esi
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
  80020d:	56                   	push   %esi
  80020e:	57                   	push   %edi
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	8d 35 1a 02 80 00    	lea    0x80021a,%esi
  800218:	0f 34                	sysenter 

0080021a <label_244>:
  80021a:	89 ec                	mov    %ebp,%esp
  80021c:	5d                   	pop    %ebp
  80021d:	5f                   	pop    %edi
  80021e:	5e                   	pop    %esi
  80021f:	5b                   	pop    %ebx
  800220:	5a                   	pop    %edx
  800221:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800222:	85 c0                	test   %eax,%eax
  800224:	7e 17                	jle    80023d <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800226:	83 ec 0c             	sub    $0xc,%esp
  800229:	50                   	push   %eax
  80022a:	6a 05                	push   $0x5
  80022c:	68 8a 14 80 00       	push   $0x80148a
  800231:	6a 30                	push   $0x30
  800233:	68 a7 14 80 00       	push   $0x8014a7
  800238:	e8 45 02 00 00       	call   800482 <_panic>

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
  800249:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800252:	8b 45 0c             	mov    0xc(%ebp),%eax
  800255:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  800258:	8b 45 10             	mov    0x10(%ebp),%eax
  80025b:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  80025e:	8b 45 14             	mov    0x14(%ebp),%eax
  800261:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800264:	8b 45 18             	mov    0x18(%ebp),%eax
  800267:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80026a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80026d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800272:	b8 06 00 00 00       	mov    $0x6,%eax
  800277:	89 cb                	mov    %ecx,%ebx
  800279:	89 cf                	mov    %ecx,%edi
  80027b:	51                   	push   %ecx
  80027c:	52                   	push   %edx
  80027d:	53                   	push   %ebx
  80027e:	56                   	push   %esi
  80027f:	57                   	push   %edi
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	8d 35 8b 02 80 00    	lea    0x80028b,%esi
  800289:	0f 34                	sysenter 

0080028b <label_304>:
  80028b:	89 ec                	mov    %ebp,%esp
  80028d:	5d                   	pop    %ebp
  80028e:	5f                   	pop    %edi
  80028f:	5e                   	pop    %esi
  800290:	5b                   	pop    %ebx
  800291:	5a                   	pop    %edx
  800292:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800293:	85 c0                	test   %eax,%eax
  800295:	7e 17                	jle    8002ae <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800297:	83 ec 0c             	sub    $0xc,%esp
  80029a:	50                   	push   %eax
  80029b:	6a 06                	push   $0x6
  80029d:	68 8a 14 80 00       	push   $0x80148a
  8002a2:	6a 30                	push   $0x30
  8002a4:	68 a7 14 80 00       	push   $0x8014a7
  8002a9:	e8 d4 01 00 00       	call   800482 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  8002ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8002bf:	b8 07 00 00 00       	mov    $0x7,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 fb                	mov    %edi,%ebx
  8002cc:	51                   	push   %ecx
  8002cd:	52                   	push   %edx
  8002ce:	53                   	push   %ebx
  8002cf:	56                   	push   %esi
  8002d0:	57                   	push   %edi
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8d 35 dc 02 80 00    	lea    0x8002dc,%esi
  8002da:	0f 34                	sysenter 

008002dc <label_353>:
  8002dc:	89 ec                	mov    %ebp,%esp
  8002de:	5d                   	pop    %ebp
  8002df:	5f                   	pop    %edi
  8002e0:	5e                   	pop    %esi
  8002e1:	5b                   	pop    %ebx
  8002e2:	5a                   	pop    %edx
  8002e3:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7e 17                	jle    8002ff <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	50                   	push   %eax
  8002ec:	6a 07                	push   $0x7
  8002ee:	68 8a 14 80 00       	push   $0x80148a
  8002f3:	6a 30                	push   $0x30
  8002f5:	68 a7 14 80 00       	push   $0x8014a7
  8002fa:	e8 83 01 00 00       	call   800482 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800302:	5b                   	pop    %ebx
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80030b:	bf 00 00 00 00       	mov    $0x0,%edi
  800310:	b8 09 00 00 00       	mov    $0x9,%eax
  800315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 fb                	mov    %edi,%ebx
  80031d:	51                   	push   %ecx
  80031e:	52                   	push   %edx
  80031f:	53                   	push   %ebx
  800320:	56                   	push   %esi
  800321:	57                   	push   %edi
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	8d 35 2d 03 80 00    	lea    0x80032d,%esi
  80032b:	0f 34                	sysenter 

0080032d <label_402>:
  80032d:	89 ec                	mov    %ebp,%esp
  80032f:	5d                   	pop    %ebp
  800330:	5f                   	pop    %edi
  800331:	5e                   	pop    %esi
  800332:	5b                   	pop    %ebx
  800333:	5a                   	pop    %edx
  800334:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800335:	85 c0                	test   %eax,%eax
  800337:	7e 17                	jle    800350 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	50                   	push   %eax
  80033d:	6a 09                	push   $0x9
  80033f:	68 8a 14 80 00       	push   $0x80148a
  800344:	6a 30                	push   $0x30
  800346:	68 a7 14 80 00       	push   $0x8014a7
  80034b:	e8 32 01 00 00       	call   800482 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800350:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800353:	5b                   	pop    %ebx
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80035c:	bf 00 00 00 00       	mov    $0x0,%edi
  800361:	b8 0a 00 00 00       	mov    $0xa,%eax
  800366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	89 fb                	mov    %edi,%ebx
  80036e:	51                   	push   %ecx
  80036f:	52                   	push   %edx
  800370:	53                   	push   %ebx
  800371:	56                   	push   %esi
  800372:	57                   	push   %edi
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	8d 35 7e 03 80 00    	lea    0x80037e,%esi
  80037c:	0f 34                	sysenter 

0080037e <label_451>:
  80037e:	89 ec                	mov    %ebp,%esp
  800380:	5d                   	pop    %ebp
  800381:	5f                   	pop    %edi
  800382:	5e                   	pop    %esi
  800383:	5b                   	pop    %ebx
  800384:	5a                   	pop    %edx
  800385:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800386:	85 c0                	test   %eax,%eax
  800388:	7e 17                	jle    8003a1 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038a:	83 ec 0c             	sub    $0xc,%esp
  80038d:	50                   	push   %eax
  80038e:	6a 0a                	push   $0xa
  800390:	68 8a 14 80 00       	push   $0x80148a
  800395:	6a 30                	push   $0x30
  800397:	68 a7 14 80 00       	push   $0x8014a7
  80039c:	e8 e1 00 00 00       	call   800482 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003a4:	5b                   	pop    %ebx
  8003a5:	5f                   	pop    %edi
  8003a6:	5d                   	pop    %ebp
  8003a7:	c3                   	ret    

008003a8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	57                   	push   %edi
  8003ac:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003ad:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003be:	51                   	push   %ecx
  8003bf:	52                   	push   %edx
  8003c0:	53                   	push   %ebx
  8003c1:	56                   	push   %esi
  8003c2:	57                   	push   %edi
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	8d 35 ce 03 80 00    	lea    0x8003ce,%esi
  8003cc:	0f 34                	sysenter 

008003ce <label_502>:
  8003ce:	89 ec                	mov    %ebp,%esp
  8003d0:	5d                   	pop    %ebp
  8003d1:	5f                   	pop    %edi
  8003d2:	5e                   	pop    %esi
  8003d3:	5b                   	pop    %ebx
  8003d4:	5a                   	pop    %edx
  8003d5:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003d6:	5b                   	pop    %ebx
  8003d7:	5f                   	pop    %edi
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	57                   	push   %edi
  8003de:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e4:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ec:	89 d9                	mov    %ebx,%ecx
  8003ee:	89 df                	mov    %ebx,%edi
  8003f0:	51                   	push   %ecx
  8003f1:	52                   	push   %edx
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	57                   	push   %edi
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	8d 35 00 04 80 00    	lea    0x800400,%esi
  8003fe:	0f 34                	sysenter 

00800400 <label_537>:
  800400:	89 ec                	mov    %ebp,%esp
  800402:	5d                   	pop    %ebp
  800403:	5f                   	pop    %edi
  800404:	5e                   	pop    %esi
  800405:	5b                   	pop    %ebx
  800406:	5a                   	pop    %edx
  800407:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800408:	85 c0                	test   %eax,%eax
  80040a:	7e 17                	jle    800423 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040c:	83 ec 0c             	sub    $0xc,%esp
  80040f:	50                   	push   %eax
  800410:	6a 0d                	push   $0xd
  800412:	68 8a 14 80 00       	push   $0x80148a
  800417:	6a 30                	push   $0x30
  800419:	68 a7 14 80 00       	push   $0x8014a7
  80041e:	e8 5f 00 00 00       	call   800482 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800423:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800426:	5b                   	pop    %ebx
  800427:	5f                   	pop    %edi
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	57                   	push   %edi
  80042e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80042f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800434:	b8 0e 00 00 00       	mov    $0xe,%eax
  800439:	8b 55 08             	mov    0x8(%ebp),%edx
  80043c:	89 cb                	mov    %ecx,%ebx
  80043e:	89 cf                	mov    %ecx,%edi
  800440:	51                   	push   %ecx
  800441:	52                   	push   %edx
  800442:	53                   	push   %ebx
  800443:	56                   	push   %esi
  800444:	57                   	push   %edi
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	8d 35 50 04 80 00    	lea    0x800450,%esi
  80044e:	0f 34                	sysenter 

00800450 <label_586>:
  800450:	89 ec                	mov    %ebp,%esp
  800452:	5d                   	pop    %ebp
  800453:	5f                   	pop    %edi
  800454:	5e                   	pop    %esi
  800455:	5b                   	pop    %ebx
  800456:	5a                   	pop    %edx
  800457:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800458:	5b                   	pop    %ebx
  800459:	5f                   	pop    %edi
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    

0080045c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80045c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80045d:	a1 14 20 80 00       	mov    0x802014,%eax
	call *%eax
  800462:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800464:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  800467:	8b 44 24 30          	mov    0x30(%esp),%eax
	leal -0x4(%eax), %eax	// preserve space to store trap-time eip
  80046b:	8d 40 fc             	lea    -0x4(%eax),%eax
	movl %eax, 0x30(%esp)
  80046e:	89 44 24 30          	mov    %eax,0x30(%esp)

	movl 0x28(%esp), %ecx
  800472:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  800476:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800478:	83 c4 08             	add    $0x8,%esp
	popal
  80047b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  80047c:	83 c4 04             	add    $0x4,%esp
	popfl
  80047f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800480:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800481:	c3                   	ret    

00800482 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	56                   	push   %esi
  800486:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800487:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80048a:	a1 10 20 80 00       	mov    0x802010,%eax
  80048f:	85 c0                	test   %eax,%eax
  800491:	74 11                	je     8004a4 <_panic+0x22>
		cprintf("%s: ", argv0);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	50                   	push   %eax
  800497:	68 b5 14 80 00       	push   $0x8014b5
  80049c:	e8 d4 00 00 00       	call   800575 <cprintf>
  8004a1:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004a4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8004aa:	e8 ae fc ff ff       	call   80015d <sys_getenvid>
  8004af:	83 ec 0c             	sub    $0xc,%esp
  8004b2:	ff 75 0c             	pushl  0xc(%ebp)
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	56                   	push   %esi
  8004b9:	50                   	push   %eax
  8004ba:	68 bc 14 80 00       	push   $0x8014bc
  8004bf:	e8 b1 00 00 00       	call   800575 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004c4:	83 c4 18             	add    $0x18,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	ff 75 10             	pushl  0x10(%ebp)
  8004cb:	e8 54 00 00 00       	call   800524 <vcprintf>
	cprintf("\n");
  8004d0:	c7 04 24 bb 17 80 00 	movl   $0x8017bb,(%esp)
  8004d7:	e8 99 00 00 00       	call   800575 <cprintf>
  8004dc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004df:	cc                   	int3   
  8004e0:	eb fd                	jmp    8004df <_panic+0x5d>

008004e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 04             	sub    $0x4,%esp
  8004e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ec:	8b 13                	mov    (%ebx),%edx
  8004ee:	8d 42 01             	lea    0x1(%edx),%eax
  8004f1:	89 03                	mov    %eax,(%ebx)
  8004f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ff:	75 1a                	jne    80051b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	68 ff 00 00 00       	push   $0xff
  800509:	8d 43 08             	lea    0x8(%ebx),%eax
  80050c:	50                   	push   %eax
  80050d:	e8 9a fb ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800512:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800518:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80051b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80051f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800522:	c9                   	leave  
  800523:	c3                   	ret    

00800524 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80052d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800534:	00 00 00 
	b.cnt = 0;
  800537:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80053e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	ff 75 08             	pushl  0x8(%ebp)
  800547:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80054d:	50                   	push   %eax
  80054e:	68 e2 04 80 00       	push   $0x8004e2
  800553:	e8 c0 02 00 00       	call   800818 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800558:	83 c4 08             	add    $0x8,%esp
  80055b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800561:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800567:	50                   	push   %eax
  800568:	e8 3f fb ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80056d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80057b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80057e:	50                   	push   %eax
  80057f:	ff 75 08             	pushl  0x8(%ebp)
  800582:	e8 9d ff ff ff       	call   800524 <vcprintf>
	va_end(ap);

	return cnt;
}
  800587:	c9                   	leave  
  800588:	c3                   	ret    

00800589 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
  80058c:	57                   	push   %edi
  80058d:	56                   	push   %esi
  80058e:	53                   	push   %ebx
  80058f:	83 ec 1c             	sub    $0x1c,%esp
  800592:	89 c7                	mov    %eax,%edi
  800594:	89 d6                	mov    %edx,%esi
  800596:	8b 45 08             	mov    0x8(%ebp),%eax
  800599:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  8005a5:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8005a9:	0f 85 bf 00 00 00    	jne    80066e <printnum+0xe5>
  8005af:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  8005b5:	0f 8d de 00 00 00    	jge    800699 <printnum+0x110>
		judge_time_for_space = width;
  8005bb:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8005c1:	e9 d3 00 00 00       	jmp    800699 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005c6:	83 eb 01             	sub    $0x1,%ebx
  8005c9:	85 db                	test   %ebx,%ebx
  8005cb:	7f 37                	jg     800604 <printnum+0x7b>
  8005cd:	e9 ea 00 00 00       	jmp    8006bc <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8005d2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8005d5:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	56                   	push   %esi
  8005de:	83 ec 04             	sub    $0x4,%esp
  8005e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8005e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8005e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ed:	e8 2e 0d 00 00       	call   801320 <__umoddi3>
  8005f2:	83 c4 14             	add    $0x14,%esp
  8005f5:	0f be 80 df 14 80 00 	movsbl 0x8014df(%eax),%eax
  8005fc:	50                   	push   %eax
  8005fd:	ff d7                	call   *%edi
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	eb 16                	jmp    80061a <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	56                   	push   %esi
  800608:	ff 75 18             	pushl  0x18(%ebp)
  80060b:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	83 eb 01             	sub    $0x1,%ebx
  800613:	75 ef                	jne    800604 <printnum+0x7b>
  800615:	e9 a2 00 00 00       	jmp    8006bc <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  80061a:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800620:	0f 85 76 01 00 00    	jne    80079c <printnum+0x213>
		while(num_of_space-- > 0)
  800626:	a1 04 20 80 00       	mov    0x802004,%eax
  80062b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80062e:	89 15 04 20 80 00    	mov    %edx,0x802004
  800634:	85 c0                	test   %eax,%eax
  800636:	7e 1d                	jle    800655 <printnum+0xcc>
			putch(' ', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	6a 20                	push   $0x20
  80063e:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800640:	a1 04 20 80 00       	mov    0x802004,%eax
  800645:	8d 50 ff             	lea    -0x1(%eax),%edx
  800648:	89 15 04 20 80 00    	mov    %edx,0x802004
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	85 c0                	test   %eax,%eax
  800653:	7f e3                	jg     800638 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800655:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80065c:	00 00 00 
		judge_time_for_space = 0;
  80065f:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800666:	00 00 00 
	}
}
  800669:	e9 2e 01 00 00       	jmp    80079c <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80066e:	8b 45 10             	mov    0x10(%ebp),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
  800676:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800679:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800682:	83 fa 00             	cmp    $0x0,%edx
  800685:	0f 87 ba 00 00 00    	ja     800745 <printnum+0x1bc>
  80068b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80068e:	0f 83 b1 00 00 00    	jae    800745 <printnum+0x1bc>
  800694:	e9 2d ff ff ff       	jmp    8005c6 <printnum+0x3d>
  800699:	8b 45 10             	mov    0x10(%ebp),%eax
  80069c:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ad:	83 fa 00             	cmp    $0x0,%edx
  8006b0:	77 37                	ja     8006e9 <printnum+0x160>
  8006b2:	3b 45 10             	cmp    0x10(%ebp),%eax
  8006b5:	73 32                	jae    8006e9 <printnum+0x160>
  8006b7:	e9 16 ff ff ff       	jmp    8005d2 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	56                   	push   %esi
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cf:	e8 4c 0c 00 00       	call   801320 <__umoddi3>
  8006d4:	83 c4 14             	add    $0x14,%esp
  8006d7:	0f be 80 df 14 80 00 	movsbl 0x8014df(%eax),%eax
  8006de:	50                   	push   %eax
  8006df:	ff d7                	call   *%edi
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	e9 b3 00 00 00       	jmp    80079c <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e9:	83 ec 0c             	sub    $0xc,%esp
  8006ec:	ff 75 18             	pushl  0x18(%ebp)
  8006ef:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006f2:	50                   	push   %eax
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8006fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800702:	ff 75 e0             	pushl  -0x20(%ebp)
  800705:	e8 e6 0a 00 00       	call   8011f0 <__udivdi3>
  80070a:	83 c4 18             	add    $0x18,%esp
  80070d:	52                   	push   %edx
  80070e:	50                   	push   %eax
  80070f:	89 f2                	mov    %esi,%edx
  800711:	89 f8                	mov    %edi,%eax
  800713:	e8 71 fe ff ff       	call   800589 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800718:	83 c4 18             	add    $0x18,%esp
  80071b:	56                   	push   %esi
  80071c:	83 ec 04             	sub    $0x4,%esp
  80071f:	ff 75 dc             	pushl  -0x24(%ebp)
  800722:	ff 75 d8             	pushl  -0x28(%ebp)
  800725:	ff 75 e4             	pushl  -0x1c(%ebp)
  800728:	ff 75 e0             	pushl  -0x20(%ebp)
  80072b:	e8 f0 0b 00 00       	call   801320 <__umoddi3>
  800730:	83 c4 14             	add    $0x14,%esp
  800733:	0f be 80 df 14 80 00 	movsbl 0x8014df(%eax),%eax
  80073a:	50                   	push   %eax
  80073b:	ff d7                	call   *%edi
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	e9 d5 fe ff ff       	jmp    80061a <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800745:	83 ec 0c             	sub    $0xc,%esp
  800748:	ff 75 18             	pushl  0x18(%ebp)
  80074b:	83 eb 01             	sub    $0x1,%ebx
  80074e:	53                   	push   %ebx
  80074f:	ff 75 10             	pushl  0x10(%ebp)
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	ff 75 dc             	pushl  -0x24(%ebp)
  800758:	ff 75 d8             	pushl  -0x28(%ebp)
  80075b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80075e:	ff 75 e0             	pushl  -0x20(%ebp)
  800761:	e8 8a 0a 00 00       	call   8011f0 <__udivdi3>
  800766:	83 c4 18             	add    $0x18,%esp
  800769:	52                   	push   %edx
  80076a:	50                   	push   %eax
  80076b:	89 f2                	mov    %esi,%edx
  80076d:	89 f8                	mov    %edi,%eax
  80076f:	e8 15 fe ff ff       	call   800589 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800774:	83 c4 18             	add    $0x18,%esp
  800777:	56                   	push   %esi
  800778:	83 ec 04             	sub    $0x4,%esp
  80077b:	ff 75 dc             	pushl  -0x24(%ebp)
  80077e:	ff 75 d8             	pushl  -0x28(%ebp)
  800781:	ff 75 e4             	pushl  -0x1c(%ebp)
  800784:	ff 75 e0             	pushl  -0x20(%ebp)
  800787:	e8 94 0b 00 00       	call   801320 <__umoddi3>
  80078c:	83 c4 14             	add    $0x14,%esp
  80078f:	0f be 80 df 14 80 00 	movsbl 0x8014df(%eax),%eax
  800796:	50                   	push   %eax
  800797:	ff d7                	call   *%edi
  800799:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80079c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079f:	5b                   	pop    %ebx
  8007a0:	5e                   	pop    %esi
  8007a1:	5f                   	pop    %edi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007a7:	83 fa 01             	cmp    $0x1,%edx
  8007aa:	7e 0e                	jle    8007ba <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007ac:	8b 10                	mov    (%eax),%edx
  8007ae:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007b1:	89 08                	mov    %ecx,(%eax)
  8007b3:	8b 02                	mov    (%edx),%eax
  8007b5:	8b 52 04             	mov    0x4(%edx),%edx
  8007b8:	eb 22                	jmp    8007dc <getuint+0x38>
	else if (lflag)
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	74 10                	je     8007ce <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007be:	8b 10                	mov    (%eax),%edx
  8007c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c3:	89 08                	mov    %ecx,(%eax)
  8007c5:	8b 02                	mov    (%edx),%eax
  8007c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cc:	eb 0e                	jmp    8007dc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007ce:	8b 10                	mov    (%eax),%edx
  8007d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d3:	89 08                	mov    %ecx,(%eax)
  8007d5:	8b 02                	mov    (%edx),%eax
  8007d7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007e8:	8b 10                	mov    (%eax),%edx
  8007ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ed:	73 0a                	jae    8007f9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007f2:	89 08                	mov    %ecx,(%eax)
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	88 02                	mov    %al,(%edx)
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800801:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800804:	50                   	push   %eax
  800805:	ff 75 10             	pushl  0x10(%ebp)
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	ff 75 08             	pushl  0x8(%ebp)
  80080e:	e8 05 00 00 00       	call   800818 <vprintfmt>
	va_end(ap);
}
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	57                   	push   %edi
  80081c:	56                   	push   %esi
  80081d:	53                   	push   %ebx
  80081e:	83 ec 2c             	sub    $0x2c,%esp
  800821:	8b 7d 08             	mov    0x8(%ebp),%edi
  800824:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800827:	eb 03                	jmp    80082c <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800829:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082c:	8b 45 10             	mov    0x10(%ebp),%eax
  80082f:	8d 70 01             	lea    0x1(%eax),%esi
  800832:	0f b6 00             	movzbl (%eax),%eax
  800835:	83 f8 25             	cmp    $0x25,%eax
  800838:	74 27                	je     800861 <vprintfmt+0x49>
			if (ch == '\0')
  80083a:	85 c0                	test   %eax,%eax
  80083c:	75 0d                	jne    80084b <vprintfmt+0x33>
  80083e:	e9 9d 04 00 00       	jmp    800ce0 <vprintfmt+0x4c8>
  800843:	85 c0                	test   %eax,%eax
  800845:	0f 84 95 04 00 00    	je     800ce0 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	50                   	push   %eax
  800850:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800852:	83 c6 01             	add    $0x1,%esi
  800855:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	83 f8 25             	cmp    $0x25,%eax
  80085f:	75 e2                	jne    800843 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800861:	b9 00 00 00 00       	mov    $0x0,%ecx
  800866:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80086a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800871:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800878:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80087f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800886:	eb 08                	jmp    800890 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800888:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80088b:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800890:	8d 46 01             	lea    0x1(%esi),%eax
  800893:	89 45 10             	mov    %eax,0x10(%ebp)
  800896:	0f b6 06             	movzbl (%esi),%eax
  800899:	0f b6 d0             	movzbl %al,%edx
  80089c:	83 e8 23             	sub    $0x23,%eax
  80089f:	3c 55                	cmp    $0x55,%al
  8008a1:	0f 87 fa 03 00 00    	ja     800ca1 <vprintfmt+0x489>
  8008a7:	0f b6 c0             	movzbl %al,%eax
  8008aa:	ff 24 85 20 16 80 00 	jmp    *0x801620(,%eax,4)
  8008b1:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  8008b4:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8008b8:	eb d6                	jmp    800890 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008ba:	8d 42 d0             	lea    -0x30(%edx),%eax
  8008bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8008c0:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8008c4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008c7:	83 fa 09             	cmp    $0x9,%edx
  8008ca:	77 6b                	ja     800937 <vprintfmt+0x11f>
  8008cc:	8b 75 10             	mov    0x10(%ebp),%esi
  8008cf:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8008d5:	eb 09                	jmp    8008e0 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d7:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008da:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008de:	eb b0                	jmp    800890 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008e0:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008e3:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008e6:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008ea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008ed:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008f0:	83 f9 09             	cmp    $0x9,%ecx
  8008f3:	76 eb                	jbe    8008e0 <vprintfmt+0xc8>
  8008f5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008f8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008fb:	eb 3d                	jmp    80093a <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8d 50 04             	lea    0x4(%eax),%edx
  800903:	89 55 14             	mov    %edx,0x14(%ebp)
  800906:	8b 00                	mov    (%eax),%eax
  800908:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090b:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80090e:	eb 2a                	jmp    80093a <vprintfmt+0x122>
  800910:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800913:	85 c0                	test   %eax,%eax
  800915:	ba 00 00 00 00       	mov    $0x0,%edx
  80091a:	0f 49 d0             	cmovns %eax,%edx
  80091d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800920:	8b 75 10             	mov    0x10(%ebp),%esi
  800923:	e9 68 ff ff ff       	jmp    800890 <vprintfmt+0x78>
  800928:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80092b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800932:	e9 59 ff ff ff       	jmp    800890 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800937:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80093a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093e:	0f 89 4c ff ff ff    	jns    800890 <vprintfmt+0x78>
				width = precision, precision = -1;
  800944:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800947:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800951:	e9 3a ff ff ff       	jmp    800890 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800956:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095a:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80095d:	e9 2e ff ff ff       	jmp    800890 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	8d 50 04             	lea    0x4(%eax),%edx
  800968:	89 55 14             	mov    %edx,0x14(%ebp)
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	53                   	push   %ebx
  80096f:	ff 30                	pushl  (%eax)
  800971:	ff d7                	call   *%edi
			break;
  800973:	83 c4 10             	add    $0x10,%esp
  800976:	e9 b1 fe ff ff       	jmp    80082c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80097b:	8b 45 14             	mov    0x14(%ebp),%eax
  80097e:	8d 50 04             	lea    0x4(%eax),%edx
  800981:	89 55 14             	mov    %edx,0x14(%ebp)
  800984:	8b 00                	mov    (%eax),%eax
  800986:	99                   	cltd   
  800987:	31 d0                	xor    %edx,%eax
  800989:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80098b:	83 f8 08             	cmp    $0x8,%eax
  80098e:	7f 0b                	jg     80099b <vprintfmt+0x183>
  800990:	8b 14 85 80 17 80 00 	mov    0x801780(,%eax,4),%edx
  800997:	85 d2                	test   %edx,%edx
  800999:	75 15                	jne    8009b0 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80099b:	50                   	push   %eax
  80099c:	68 f7 14 80 00       	push   $0x8014f7
  8009a1:	53                   	push   %ebx
  8009a2:	57                   	push   %edi
  8009a3:	e8 53 fe ff ff       	call   8007fb <printfmt>
  8009a8:	83 c4 10             	add    $0x10,%esp
  8009ab:	e9 7c fe ff ff       	jmp    80082c <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8009b0:	52                   	push   %edx
  8009b1:	68 00 15 80 00       	push   $0x801500
  8009b6:	53                   	push   %ebx
  8009b7:	57                   	push   %edi
  8009b8:	e8 3e fe ff ff       	call   8007fb <printfmt>
  8009bd:	83 c4 10             	add    $0x10,%esp
  8009c0:	e9 67 fe ff ff       	jmp    80082c <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c8:	8d 50 04             	lea    0x4(%eax),%edx
  8009cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ce:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8009d0:	85 c0                	test   %eax,%eax
  8009d2:	b9 f0 14 80 00       	mov    $0x8014f0,%ecx
  8009d7:	0f 45 c8             	cmovne %eax,%ecx
  8009da:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009e1:	7e 06                	jle    8009e9 <vprintfmt+0x1d1>
  8009e3:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009e7:	75 19                	jne    800a02 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009ec:	8d 70 01             	lea    0x1(%eax),%esi
  8009ef:	0f b6 00             	movzbl (%eax),%eax
  8009f2:	0f be d0             	movsbl %al,%edx
  8009f5:	85 d2                	test   %edx,%edx
  8009f7:	0f 85 9f 00 00 00    	jne    800a9c <vprintfmt+0x284>
  8009fd:	e9 8c 00 00 00       	jmp    800a8e <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a02:	83 ec 08             	sub    $0x8,%esp
  800a05:	ff 75 d0             	pushl  -0x30(%ebp)
  800a08:	ff 75 cc             	pushl  -0x34(%ebp)
  800a0b:	e8 62 03 00 00       	call   800d72 <strnlen>
  800a10:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800a13:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800a16:	83 c4 10             	add    $0x10,%esp
  800a19:	85 c9                	test   %ecx,%ecx
  800a1b:	0f 8e a6 02 00 00    	jle    800cc7 <vprintfmt+0x4af>
					putch(padc, putdat);
  800a21:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800a25:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a28:	89 cb                	mov    %ecx,%ebx
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	ff 75 0c             	pushl  0xc(%ebp)
  800a30:	56                   	push   %esi
  800a31:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	83 eb 01             	sub    $0x1,%ebx
  800a39:	75 ef                	jne    800a2a <vprintfmt+0x212>
  800a3b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a41:	e9 81 02 00 00       	jmp    800cc7 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a46:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a4a:	74 1b                	je     800a67 <vprintfmt+0x24f>
  800a4c:	0f be c0             	movsbl %al,%eax
  800a4f:	83 e8 20             	sub    $0x20,%eax
  800a52:	83 f8 5e             	cmp    $0x5e,%eax
  800a55:	76 10                	jbe    800a67 <vprintfmt+0x24f>
					putch('?', putdat);
  800a57:	83 ec 08             	sub    $0x8,%esp
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	6a 3f                	push   $0x3f
  800a5f:	ff 55 08             	call   *0x8(%ebp)
  800a62:	83 c4 10             	add    $0x10,%esp
  800a65:	eb 0d                	jmp    800a74 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a67:	83 ec 08             	sub    $0x8,%esp
  800a6a:	ff 75 0c             	pushl  0xc(%ebp)
  800a6d:	52                   	push   %edx
  800a6e:	ff 55 08             	call   *0x8(%ebp)
  800a71:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a74:	83 ef 01             	sub    $0x1,%edi
  800a77:	83 c6 01             	add    $0x1,%esi
  800a7a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a7e:	0f be d0             	movsbl %al,%edx
  800a81:	85 d2                	test   %edx,%edx
  800a83:	75 31                	jne    800ab6 <vprintfmt+0x29e>
  800a85:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a88:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a95:	7f 33                	jg     800aca <vprintfmt+0x2b2>
  800a97:	e9 90 fd ff ff       	jmp    80082c <vprintfmt+0x14>
  800a9c:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aa2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aa5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800aa8:	eb 0c                	jmp    800ab6 <vprintfmt+0x29e>
  800aaa:	89 7d 08             	mov    %edi,0x8(%ebp)
  800aad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ab0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ab3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	78 8c                	js     800a46 <vprintfmt+0x22e>
  800aba:	83 eb 01             	sub    $0x1,%ebx
  800abd:	79 87                	jns    800a46 <vprintfmt+0x22e>
  800abf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800ac2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac8:	eb c4                	jmp    800a8e <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	53                   	push   %ebx
  800ace:	6a 20                	push   $0x20
  800ad0:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	83 ee 01             	sub    $0x1,%esi
  800ad8:	75 f0                	jne    800aca <vprintfmt+0x2b2>
  800ada:	e9 4d fd ff ff       	jmp    80082c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800adf:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800ae3:	7e 16                	jle    800afb <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae8:	8d 50 08             	lea    0x8(%eax),%edx
  800aeb:	89 55 14             	mov    %edx,0x14(%ebp)
  800aee:	8b 50 04             	mov    0x4(%eax),%edx
  800af1:	8b 00                	mov    (%eax),%eax
  800af3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800af6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800af9:	eb 34                	jmp    800b2f <vprintfmt+0x317>
	else if (lflag)
  800afb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800aff:	74 18                	je     800b19 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800b01:	8b 45 14             	mov    0x14(%ebp),%eax
  800b04:	8d 50 04             	lea    0x4(%eax),%edx
  800b07:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0a:	8b 30                	mov    (%eax),%esi
  800b0c:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800b0f:	89 f0                	mov    %esi,%eax
  800b11:	c1 f8 1f             	sar    $0x1f,%eax
  800b14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800b17:	eb 16                	jmp    800b2f <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800b19:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1c:	8d 50 04             	lea    0x4(%eax),%edx
  800b1f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b22:	8b 30                	mov    (%eax),%esi
  800b24:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800b27:	89 f0                	mov    %esi,%eax
  800b29:	c1 f8 1f             	sar    $0x1f,%eax
  800b2c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b2f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b32:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b35:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b38:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b3b:	85 d2                	test   %edx,%edx
  800b3d:	79 28                	jns    800b67 <vprintfmt+0x34f>
				putch('-', putdat);
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	53                   	push   %ebx
  800b43:	6a 2d                	push   $0x2d
  800b45:	ff d7                	call   *%edi
				num = -(long long) num;
  800b47:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b4a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b4d:	f7 d8                	neg    %eax
  800b4f:	83 d2 00             	adc    $0x0,%edx
  800b52:	f7 da                	neg    %edx
  800b54:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b57:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b5a:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b5d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b62:	e9 b2 00 00 00       	jmp    800c19 <vprintfmt+0x401>
  800b67:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b6c:	85 c9                	test   %ecx,%ecx
  800b6e:	0f 84 a5 00 00 00    	je     800c19 <vprintfmt+0x401>
				putch('+', putdat);
  800b74:	83 ec 08             	sub    $0x8,%esp
  800b77:	53                   	push   %ebx
  800b78:	6a 2b                	push   $0x2b
  800b7a:	ff d7                	call   *%edi
  800b7c:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b7f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b84:	e9 90 00 00 00       	jmp    800c19 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b89:	85 c9                	test   %ecx,%ecx
  800b8b:	74 0b                	je     800b98 <vprintfmt+0x380>
				putch('+', putdat);
  800b8d:	83 ec 08             	sub    $0x8,%esp
  800b90:	53                   	push   %ebx
  800b91:	6a 2b                	push   $0x2b
  800b93:	ff d7                	call   *%edi
  800b95:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b98:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b9b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9e:	e8 01 fc ff ff       	call   8007a4 <getuint>
  800ba3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ba6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800ba9:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800bae:	eb 69                	jmp    800c19 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800bb0:	83 ec 08             	sub    $0x8,%esp
  800bb3:	53                   	push   %ebx
  800bb4:	6a 30                	push   $0x30
  800bb6:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800bb8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bbb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bbe:	e8 e1 fb ff ff       	call   8007a4 <getuint>
  800bc3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bc6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800bc9:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800bcc:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800bd1:	eb 46                	jmp    800c19 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800bd3:	83 ec 08             	sub    $0x8,%esp
  800bd6:	53                   	push   %ebx
  800bd7:	6a 30                	push   $0x30
  800bd9:	ff d7                	call   *%edi
			putch('x', putdat);
  800bdb:	83 c4 08             	add    $0x8,%esp
  800bde:	53                   	push   %ebx
  800bdf:	6a 78                	push   $0x78
  800be1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800be3:	8b 45 14             	mov    0x14(%ebp),%eax
  800be6:	8d 50 04             	lea    0x4(%eax),%edx
  800be9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bec:	8b 00                	mov    (%eax),%eax
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bf6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bf9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bfc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c01:	eb 16                	jmp    800c19 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c03:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800c06:	8d 45 14             	lea    0x14(%ebp),%eax
  800c09:	e8 96 fb ff ff       	call   8007a4 <getuint>
  800c0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c11:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800c14:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800c20:	56                   	push   %esi
  800c21:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c24:	50                   	push   %eax
  800c25:	ff 75 dc             	pushl  -0x24(%ebp)
  800c28:	ff 75 d8             	pushl  -0x28(%ebp)
  800c2b:	89 da                	mov    %ebx,%edx
  800c2d:	89 f8                	mov    %edi,%eax
  800c2f:	e8 55 f9 ff ff       	call   800589 <printnum>
			break;
  800c34:	83 c4 20             	add    $0x20,%esp
  800c37:	e9 f0 fb ff ff       	jmp    80082c <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3f:	8d 50 04             	lea    0x4(%eax),%edx
  800c42:	89 55 14             	mov    %edx,0x14(%ebp)
  800c45:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c47:	85 f6                	test   %esi,%esi
  800c49:	75 1a                	jne    800c65 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c4b:	83 ec 08             	sub    $0x8,%esp
  800c4e:	68 98 15 80 00       	push   $0x801598
  800c53:	68 00 15 80 00       	push   $0x801500
  800c58:	e8 18 f9 ff ff       	call   800575 <cprintf>
  800c5d:	83 c4 10             	add    $0x10,%esp
  800c60:	e9 c7 fb ff ff       	jmp    80082c <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c65:	0f b6 03             	movzbl (%ebx),%eax
  800c68:	84 c0                	test   %al,%al
  800c6a:	79 1f                	jns    800c8b <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c6c:	83 ec 08             	sub    $0x8,%esp
  800c6f:	68 d0 15 80 00       	push   $0x8015d0
  800c74:	68 00 15 80 00       	push   $0x801500
  800c79:	e8 f7 f8 ff ff       	call   800575 <cprintf>
						*tmp = *(char *)putdat;
  800c7e:	0f b6 03             	movzbl (%ebx),%eax
  800c81:	88 06                	mov    %al,(%esi)
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	e9 a1 fb ff ff       	jmp    80082c <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c8b:	88 06                	mov    %al,(%esi)
  800c8d:	e9 9a fb ff ff       	jmp    80082c <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c92:	83 ec 08             	sub    $0x8,%esp
  800c95:	53                   	push   %ebx
  800c96:	52                   	push   %edx
  800c97:	ff d7                	call   *%edi
			break;
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	e9 8b fb ff ff       	jmp    80082c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ca1:	83 ec 08             	sub    $0x8,%esp
  800ca4:	53                   	push   %ebx
  800ca5:	6a 25                	push   $0x25
  800ca7:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800cb0:	0f 84 73 fb ff ff    	je     800829 <vprintfmt+0x11>
  800cb6:	83 ee 01             	sub    $0x1,%esi
  800cb9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800cbd:	75 f7                	jne    800cb6 <vprintfmt+0x49e>
  800cbf:	89 75 10             	mov    %esi,0x10(%ebp)
  800cc2:	e9 65 fb ff ff       	jmp    80082c <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cc7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800cca:	8d 70 01             	lea    0x1(%eax),%esi
  800ccd:	0f b6 00             	movzbl (%eax),%eax
  800cd0:	0f be d0             	movsbl %al,%edx
  800cd3:	85 d2                	test   %edx,%edx
  800cd5:	0f 85 cf fd ff ff    	jne    800aaa <vprintfmt+0x292>
  800cdb:	e9 4c fb ff ff       	jmp    80082c <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 18             	sub    $0x18,%esp
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cf7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cfb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	74 26                	je     800d2f <vsnprintf+0x47>
  800d09:	85 d2                	test   %edx,%edx
  800d0b:	7e 22                	jle    800d2f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d0d:	ff 75 14             	pushl  0x14(%ebp)
  800d10:	ff 75 10             	pushl  0x10(%ebp)
  800d13:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d16:	50                   	push   %eax
  800d17:	68 de 07 80 00       	push   $0x8007de
  800d1c:	e8 f7 fa ff ff       	call   800818 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d21:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d24:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2a:	83 c4 10             	add    $0x10,%esp
  800d2d:	eb 05                	jmp    800d34 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d3c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d3f:	50                   	push   %eax
  800d40:	ff 75 10             	pushl  0x10(%ebp)
  800d43:	ff 75 0c             	pushl  0xc(%ebp)
  800d46:	ff 75 08             	pushl  0x8(%ebp)
  800d49:	e8 9a ff ff ff       	call   800ce8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d56:	80 3a 00             	cmpb   $0x0,(%edx)
  800d59:	74 10                	je     800d6b <strlen+0x1b>
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d67:	75 f7                	jne    800d60 <strlen+0x10>
  800d69:	eb 05                	jmp    800d70 <strlen+0x20>
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	53                   	push   %ebx
  800d76:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d7c:	85 c9                	test   %ecx,%ecx
  800d7e:	74 1c                	je     800d9c <strnlen+0x2a>
  800d80:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d83:	74 1e                	je     800da3 <strnlen+0x31>
  800d85:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d8a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d8c:	39 ca                	cmp    %ecx,%edx
  800d8e:	74 18                	je     800da8 <strnlen+0x36>
  800d90:	83 c2 01             	add    $0x1,%edx
  800d93:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d98:	75 f0                	jne    800d8a <strnlen+0x18>
  800d9a:	eb 0c                	jmp    800da8 <strnlen+0x36>
  800d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800da1:	eb 05                	jmp    800da8 <strnlen+0x36>
  800da3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	53                   	push   %ebx
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800db5:	89 c2                	mov    %eax,%edx
  800db7:	83 c2 01             	add    $0x1,%edx
  800dba:	83 c1 01             	add    $0x1,%ecx
  800dbd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800dc1:	88 5a ff             	mov    %bl,-0x1(%edx)
  800dc4:	84 db                	test   %bl,%bl
  800dc6:	75 ef                	jne    800db7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	53                   	push   %ebx
  800dcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800dd2:	53                   	push   %ebx
  800dd3:	e8 78 ff ff ff       	call   800d50 <strlen>
  800dd8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ddb:	ff 75 0c             	pushl  0xc(%ebp)
  800dde:	01 d8                	add    %ebx,%eax
  800de0:	50                   	push   %eax
  800de1:	e8 c5 ff ff ff       	call   800dab <strcpy>
	return dst;
}
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    

00800ded <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	8b 75 08             	mov    0x8(%ebp),%esi
  800df5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dfb:	85 db                	test   %ebx,%ebx
  800dfd:	74 17                	je     800e16 <strncpy+0x29>
  800dff:	01 f3                	add    %esi,%ebx
  800e01:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800e03:	83 c1 01             	add    $0x1,%ecx
  800e06:	0f b6 02             	movzbl (%edx),%eax
  800e09:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e0c:	80 3a 01             	cmpb   $0x1,(%edx)
  800e0f:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e12:	39 cb                	cmp    %ecx,%ebx
  800e14:	75 ed                	jne    800e03 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e16:	89 f0                	mov    %esi,%eax
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	8b 75 08             	mov    0x8(%ebp),%esi
  800e24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e27:	8b 55 10             	mov    0x10(%ebp),%edx
  800e2a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e2c:	85 d2                	test   %edx,%edx
  800e2e:	74 35                	je     800e65 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800e30:	89 d0                	mov    %edx,%eax
  800e32:	83 e8 01             	sub    $0x1,%eax
  800e35:	74 25                	je     800e5c <strlcpy+0x40>
  800e37:	0f b6 0b             	movzbl (%ebx),%ecx
  800e3a:	84 c9                	test   %cl,%cl
  800e3c:	74 22                	je     800e60 <strlcpy+0x44>
  800e3e:	8d 53 01             	lea    0x1(%ebx),%edx
  800e41:	01 c3                	add    %eax,%ebx
  800e43:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e45:	83 c0 01             	add    $0x1,%eax
  800e48:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e4b:	39 da                	cmp    %ebx,%edx
  800e4d:	74 13                	je     800e62 <strlcpy+0x46>
  800e4f:	83 c2 01             	add    $0x1,%edx
  800e52:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e56:	84 c9                	test   %cl,%cl
  800e58:	75 eb                	jne    800e45 <strlcpy+0x29>
  800e5a:	eb 06                	jmp    800e62 <strlcpy+0x46>
  800e5c:	89 f0                	mov    %esi,%eax
  800e5e:	eb 02                	jmp    800e62 <strlcpy+0x46>
  800e60:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e62:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e65:	29 f0                	sub    %esi,%eax
}
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e74:	0f b6 01             	movzbl (%ecx),%eax
  800e77:	84 c0                	test   %al,%al
  800e79:	74 15                	je     800e90 <strcmp+0x25>
  800e7b:	3a 02                	cmp    (%edx),%al
  800e7d:	75 11                	jne    800e90 <strcmp+0x25>
		p++, q++;
  800e7f:	83 c1 01             	add    $0x1,%ecx
  800e82:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e85:	0f b6 01             	movzbl (%ecx),%eax
  800e88:	84 c0                	test   %al,%al
  800e8a:	74 04                	je     800e90 <strcmp+0x25>
  800e8c:	3a 02                	cmp    (%edx),%al
  800e8e:	74 ef                	je     800e7f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e90:	0f b6 c0             	movzbl %al,%eax
  800e93:	0f b6 12             	movzbl (%edx),%edx
  800e96:	29 d0                	sub    %edx,%eax
}
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ea2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea5:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800ea8:	85 f6                	test   %esi,%esi
  800eaa:	74 29                	je     800ed5 <strncmp+0x3b>
  800eac:	0f b6 03             	movzbl (%ebx),%eax
  800eaf:	84 c0                	test   %al,%al
  800eb1:	74 30                	je     800ee3 <strncmp+0x49>
  800eb3:	3a 02                	cmp    (%edx),%al
  800eb5:	75 2c                	jne    800ee3 <strncmp+0x49>
  800eb7:	8d 43 01             	lea    0x1(%ebx),%eax
  800eba:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800ebc:	89 c3                	mov    %eax,%ebx
  800ebe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ec1:	39 c6                	cmp    %eax,%esi
  800ec3:	74 17                	je     800edc <strncmp+0x42>
  800ec5:	0f b6 08             	movzbl (%eax),%ecx
  800ec8:	84 c9                	test   %cl,%cl
  800eca:	74 17                	je     800ee3 <strncmp+0x49>
  800ecc:	83 c0 01             	add    $0x1,%eax
  800ecf:	3a 0a                	cmp    (%edx),%cl
  800ed1:	74 e9                	je     800ebc <strncmp+0x22>
  800ed3:	eb 0e                	jmp    800ee3 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	eb 0f                	jmp    800eeb <strncmp+0x51>
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	eb 08                	jmp    800eeb <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ee3:	0f b6 03             	movzbl (%ebx),%eax
  800ee6:	0f b6 12             	movzbl (%edx),%edx
  800ee9:	29 d0                	sub    %edx,%eax
}
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	53                   	push   %ebx
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ef9:	0f b6 10             	movzbl (%eax),%edx
  800efc:	84 d2                	test   %dl,%dl
  800efe:	74 1d                	je     800f1d <strchr+0x2e>
  800f00:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800f02:	38 d3                	cmp    %dl,%bl
  800f04:	75 06                	jne    800f0c <strchr+0x1d>
  800f06:	eb 1a                	jmp    800f22 <strchr+0x33>
  800f08:	38 ca                	cmp    %cl,%dl
  800f0a:	74 16                	je     800f22 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f0c:	83 c0 01             	add    $0x1,%eax
  800f0f:	0f b6 10             	movzbl (%eax),%edx
  800f12:	84 d2                	test   %dl,%dl
  800f14:	75 f2                	jne    800f08 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1b:	eb 05                	jmp    800f22 <strchr+0x33>
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f22:	5b                   	pop    %ebx
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	53                   	push   %ebx
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800f2f:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800f32:	38 d3                	cmp    %dl,%bl
  800f34:	74 14                	je     800f4a <strfind+0x25>
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	84 db                	test   %bl,%bl
  800f3a:	74 0e                	je     800f4a <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f3c:	83 c0 01             	add    $0x1,%eax
  800f3f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f42:	38 ca                	cmp    %cl,%dl
  800f44:	74 04                	je     800f4a <strfind+0x25>
  800f46:	84 d2                	test   %dl,%dl
  800f48:	75 f2                	jne    800f3c <strfind+0x17>
			break;
	return (char *) s;
}
  800f4a:	5b                   	pop    %ebx
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f59:	85 c9                	test   %ecx,%ecx
  800f5b:	74 36                	je     800f93 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f63:	75 28                	jne    800f8d <memset+0x40>
  800f65:	f6 c1 03             	test   $0x3,%cl
  800f68:	75 23                	jne    800f8d <memset+0x40>
		c &= 0xFF;
  800f6a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f6e:	89 d3                	mov    %edx,%ebx
  800f70:	c1 e3 08             	shl    $0x8,%ebx
  800f73:	89 d6                	mov    %edx,%esi
  800f75:	c1 e6 18             	shl    $0x18,%esi
  800f78:	89 d0                	mov    %edx,%eax
  800f7a:	c1 e0 10             	shl    $0x10,%eax
  800f7d:	09 f0                	or     %esi,%eax
  800f7f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f81:	89 d8                	mov    %ebx,%eax
  800f83:	09 d0                	or     %edx,%eax
  800f85:	c1 e9 02             	shr    $0x2,%ecx
  800f88:	fc                   	cld    
  800f89:	f3 ab                	rep stos %eax,%es:(%edi)
  800f8b:	eb 06                	jmp    800f93 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f90:	fc                   	cld    
  800f91:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f93:	89 f8                	mov    %edi,%eax
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800fa8:	39 c6                	cmp    %eax,%esi
  800faa:	73 35                	jae    800fe1 <memmove+0x47>
  800fac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800faf:	39 d0                	cmp    %edx,%eax
  800fb1:	73 2e                	jae    800fe1 <memmove+0x47>
		s += n;
		d += n;
  800fb3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fb6:	89 d6                	mov    %edx,%esi
  800fb8:	09 fe                	or     %edi,%esi
  800fba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fc0:	75 13                	jne    800fd5 <memmove+0x3b>
  800fc2:	f6 c1 03             	test   $0x3,%cl
  800fc5:	75 0e                	jne    800fd5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fc7:	83 ef 04             	sub    $0x4,%edi
  800fca:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fcd:	c1 e9 02             	shr    $0x2,%ecx
  800fd0:	fd                   	std    
  800fd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd3:	eb 09                	jmp    800fde <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fd5:	83 ef 01             	sub    $0x1,%edi
  800fd8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fdb:	fd                   	std    
  800fdc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fde:	fc                   	cld    
  800fdf:	eb 1d                	jmp    800ffe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fe1:	89 f2                	mov    %esi,%edx
  800fe3:	09 c2                	or     %eax,%edx
  800fe5:	f6 c2 03             	test   $0x3,%dl
  800fe8:	75 0f                	jne    800ff9 <memmove+0x5f>
  800fea:	f6 c1 03             	test   $0x3,%cl
  800fed:	75 0a                	jne    800ff9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fef:	c1 e9 02             	shr    $0x2,%ecx
  800ff2:	89 c7                	mov    %eax,%edi
  800ff4:	fc                   	cld    
  800ff5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ff7:	eb 05                	jmp    800ffe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ff9:	89 c7                	mov    %eax,%edi
  800ffb:	fc                   	cld    
  800ffc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801005:	ff 75 10             	pushl  0x10(%ebp)
  801008:	ff 75 0c             	pushl  0xc(%ebp)
  80100b:	ff 75 08             	pushl  0x8(%ebp)
  80100e:	e8 87 ff ff ff       	call   800f9a <memmove>
}
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	57                   	push   %edi
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
  80101b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80101e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801021:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801024:	85 c0                	test   %eax,%eax
  801026:	74 39                	je     801061 <memcmp+0x4c>
  801028:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  80102b:	0f b6 13             	movzbl (%ebx),%edx
  80102e:	0f b6 0e             	movzbl (%esi),%ecx
  801031:	38 ca                	cmp    %cl,%dl
  801033:	75 17                	jne    80104c <memcmp+0x37>
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
  80103a:	eb 1a                	jmp    801056 <memcmp+0x41>
  80103c:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  801041:	83 c0 01             	add    $0x1,%eax
  801044:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  801048:	38 ca                	cmp    %cl,%dl
  80104a:	74 0a                	je     801056 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  80104c:	0f b6 c2             	movzbl %dl,%eax
  80104f:	0f b6 c9             	movzbl %cl,%ecx
  801052:	29 c8                	sub    %ecx,%eax
  801054:	eb 10                	jmp    801066 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801056:	39 f8                	cmp    %edi,%eax
  801058:	75 e2                	jne    80103c <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
  80105f:	eb 05                	jmp    801066 <memcmp+0x51>
  801061:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	53                   	push   %ebx
  80106f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801072:	89 d0                	mov    %edx,%eax
  801074:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801077:	39 c2                	cmp    %eax,%edx
  801079:	73 1d                	jae    801098 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80107b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80107f:	0f b6 0a             	movzbl (%edx),%ecx
  801082:	39 d9                	cmp    %ebx,%ecx
  801084:	75 09                	jne    80108f <memfind+0x24>
  801086:	eb 14                	jmp    80109c <memfind+0x31>
  801088:	0f b6 0a             	movzbl (%edx),%ecx
  80108b:	39 d9                	cmp    %ebx,%ecx
  80108d:	74 11                	je     8010a0 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80108f:	83 c2 01             	add    $0x1,%edx
  801092:	39 d0                	cmp    %edx,%eax
  801094:	75 f2                	jne    801088 <memfind+0x1d>
  801096:	eb 0a                	jmp    8010a2 <memfind+0x37>
  801098:	89 d0                	mov    %edx,%eax
  80109a:	eb 06                	jmp    8010a2 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  80109c:	89 d0                	mov    %edx,%eax
  80109e:	eb 02                	jmp    8010a2 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010a0:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010a2:	5b                   	pop    %ebx
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	57                   	push   %edi
  8010a9:	56                   	push   %esi
  8010aa:	53                   	push   %ebx
  8010ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b1:	0f b6 01             	movzbl (%ecx),%eax
  8010b4:	3c 20                	cmp    $0x20,%al
  8010b6:	74 04                	je     8010bc <strtol+0x17>
  8010b8:	3c 09                	cmp    $0x9,%al
  8010ba:	75 0e                	jne    8010ca <strtol+0x25>
		s++;
  8010bc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010bf:	0f b6 01             	movzbl (%ecx),%eax
  8010c2:	3c 20                	cmp    $0x20,%al
  8010c4:	74 f6                	je     8010bc <strtol+0x17>
  8010c6:	3c 09                	cmp    $0x9,%al
  8010c8:	74 f2                	je     8010bc <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010ca:	3c 2b                	cmp    $0x2b,%al
  8010cc:	75 0a                	jne    8010d8 <strtol+0x33>
		s++;
  8010ce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d6:	eb 11                	jmp    8010e9 <strtol+0x44>
  8010d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010dd:	3c 2d                	cmp    $0x2d,%al
  8010df:	75 08                	jne    8010e9 <strtol+0x44>
		s++, neg = 1;
  8010e1:	83 c1 01             	add    $0x1,%ecx
  8010e4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010e9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010ef:	75 15                	jne    801106 <strtol+0x61>
  8010f1:	80 39 30             	cmpb   $0x30,(%ecx)
  8010f4:	75 10                	jne    801106 <strtol+0x61>
  8010f6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010fa:	75 7c                	jne    801178 <strtol+0xd3>
		s += 2, base = 16;
  8010fc:	83 c1 02             	add    $0x2,%ecx
  8010ff:	bb 10 00 00 00       	mov    $0x10,%ebx
  801104:	eb 16                	jmp    80111c <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801106:	85 db                	test   %ebx,%ebx
  801108:	75 12                	jne    80111c <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80110a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80110f:	80 39 30             	cmpb   $0x30,(%ecx)
  801112:	75 08                	jne    80111c <strtol+0x77>
		s++, base = 8;
  801114:	83 c1 01             	add    $0x1,%ecx
  801117:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
  801121:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801124:	0f b6 11             	movzbl (%ecx),%edx
  801127:	8d 72 d0             	lea    -0x30(%edx),%esi
  80112a:	89 f3                	mov    %esi,%ebx
  80112c:	80 fb 09             	cmp    $0x9,%bl
  80112f:	77 08                	ja     801139 <strtol+0x94>
			dig = *s - '0';
  801131:	0f be d2             	movsbl %dl,%edx
  801134:	83 ea 30             	sub    $0x30,%edx
  801137:	eb 22                	jmp    80115b <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  801139:	8d 72 9f             	lea    -0x61(%edx),%esi
  80113c:	89 f3                	mov    %esi,%ebx
  80113e:	80 fb 19             	cmp    $0x19,%bl
  801141:	77 08                	ja     80114b <strtol+0xa6>
			dig = *s - 'a' + 10;
  801143:	0f be d2             	movsbl %dl,%edx
  801146:	83 ea 57             	sub    $0x57,%edx
  801149:	eb 10                	jmp    80115b <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  80114b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80114e:	89 f3                	mov    %esi,%ebx
  801150:	80 fb 19             	cmp    $0x19,%bl
  801153:	77 16                	ja     80116b <strtol+0xc6>
			dig = *s - 'A' + 10;
  801155:	0f be d2             	movsbl %dl,%edx
  801158:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80115b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80115e:	7d 0b                	jge    80116b <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801160:	83 c1 01             	add    $0x1,%ecx
  801163:	0f af 45 10          	imul   0x10(%ebp),%eax
  801167:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801169:	eb b9                	jmp    801124 <strtol+0x7f>

	if (endptr)
  80116b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80116f:	74 0d                	je     80117e <strtol+0xd9>
		*endptr = (char *) s;
  801171:	8b 75 0c             	mov    0xc(%ebp),%esi
  801174:	89 0e                	mov    %ecx,(%esi)
  801176:	eb 06                	jmp    80117e <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801178:	85 db                	test   %ebx,%ebx
  80117a:	74 98                	je     801114 <strtol+0x6f>
  80117c:	eb 9e                	jmp    80111c <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80117e:	89 c2                	mov    %eax,%edx
  801180:	f7 da                	neg    %edx
  801182:	85 ff                	test   %edi,%edi
  801184:	0f 45 c2             	cmovne %edx,%eax
}
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801192:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  801199:	75 3c                	jne    8011d7 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	6a 07                	push   $0x7
  8011a0:	68 00 f0 bf ee       	push   $0xeebff000
  8011a5:	6a 00                	push   $0x0
  8011a7:	e8 46 f0 ff ff       	call   8001f2 <sys_page_alloc>
		if (r) {
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	74 12                	je     8011c5 <set_pgfault_handler+0x39>
			panic("set_pgfault_handler: %e\n", r);
  8011b3:	50                   	push   %eax
  8011b4:	68 a4 17 80 00       	push   $0x8017a4
  8011b9:	6a 22                	push   $0x22
  8011bb:	68 bd 17 80 00       	push   $0x8017bd
  8011c0:	e8 bd f2 ff ff       	call   800482 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	68 5c 04 80 00       	push   $0x80045c
  8011cd:	6a 00                	push   $0x0
  8011cf:	e8 83 f1 ff ff       	call   800357 <sys_env_set_pgfault_upcall>
  8011d4:	83 c4 10             	add    $0x10,%esp
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	a3 14 20 80 00       	mov    %eax,0x802014
}
  8011df:	c9                   	leave  
  8011e0:	c3                   	ret    
  8011e1:	66 90                	xchg   %ax,%ax
  8011e3:	66 90                	xchg   %ax,%ax
  8011e5:	66 90                	xchg   %ax,%ax
  8011e7:	66 90                	xchg   %ax,%ax
  8011e9:	66 90                	xchg   %ax,%ax
  8011eb:	66 90                	xchg   %ax,%ax
  8011ed:	66 90                	xchg   %ax,%ax
  8011ef:	90                   	nop

008011f0 <__udivdi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 1c             	sub    $0x1c,%esp
  8011f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8011fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801207:	85 f6                	test   %esi,%esi
  801209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80120d:	89 ca                	mov    %ecx,%edx
  80120f:	89 f8                	mov    %edi,%eax
  801211:	75 3d                	jne    801250 <__udivdi3+0x60>
  801213:	39 cf                	cmp    %ecx,%edi
  801215:	0f 87 c5 00 00 00    	ja     8012e0 <__udivdi3+0xf0>
  80121b:	85 ff                	test   %edi,%edi
  80121d:	89 fd                	mov    %edi,%ebp
  80121f:	75 0b                	jne    80122c <__udivdi3+0x3c>
  801221:	b8 01 00 00 00       	mov    $0x1,%eax
  801226:	31 d2                	xor    %edx,%edx
  801228:	f7 f7                	div    %edi
  80122a:	89 c5                	mov    %eax,%ebp
  80122c:	89 c8                	mov    %ecx,%eax
  80122e:	31 d2                	xor    %edx,%edx
  801230:	f7 f5                	div    %ebp
  801232:	89 c1                	mov    %eax,%ecx
  801234:	89 d8                	mov    %ebx,%eax
  801236:	89 cf                	mov    %ecx,%edi
  801238:	f7 f5                	div    %ebp
  80123a:	89 c3                	mov    %eax,%ebx
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
  801250:	39 ce                	cmp    %ecx,%esi
  801252:	77 74                	ja     8012c8 <__udivdi3+0xd8>
  801254:	0f bd fe             	bsr    %esi,%edi
  801257:	83 f7 1f             	xor    $0x1f,%edi
  80125a:	0f 84 98 00 00 00    	je     8012f8 <__udivdi3+0x108>
  801260:	bb 20 00 00 00       	mov    $0x20,%ebx
  801265:	89 f9                	mov    %edi,%ecx
  801267:	89 c5                	mov    %eax,%ebp
  801269:	29 fb                	sub    %edi,%ebx
  80126b:	d3 e6                	shl    %cl,%esi
  80126d:	89 d9                	mov    %ebx,%ecx
  80126f:	d3 ed                	shr    %cl,%ebp
  801271:	89 f9                	mov    %edi,%ecx
  801273:	d3 e0                	shl    %cl,%eax
  801275:	09 ee                	or     %ebp,%esi
  801277:	89 d9                	mov    %ebx,%ecx
  801279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127d:	89 d5                	mov    %edx,%ebp
  80127f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801283:	d3 ed                	shr    %cl,%ebp
  801285:	89 f9                	mov    %edi,%ecx
  801287:	d3 e2                	shl    %cl,%edx
  801289:	89 d9                	mov    %ebx,%ecx
  80128b:	d3 e8                	shr    %cl,%eax
  80128d:	09 c2                	or     %eax,%edx
  80128f:	89 d0                	mov    %edx,%eax
  801291:	89 ea                	mov    %ebp,%edx
  801293:	f7 f6                	div    %esi
  801295:	89 d5                	mov    %edx,%ebp
  801297:	89 c3                	mov    %eax,%ebx
  801299:	f7 64 24 0c          	mull   0xc(%esp)
  80129d:	39 d5                	cmp    %edx,%ebp
  80129f:	72 10                	jb     8012b1 <__udivdi3+0xc1>
  8012a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012a5:	89 f9                	mov    %edi,%ecx
  8012a7:	d3 e6                	shl    %cl,%esi
  8012a9:	39 c6                	cmp    %eax,%esi
  8012ab:	73 07                	jae    8012b4 <__udivdi3+0xc4>
  8012ad:	39 d5                	cmp    %edx,%ebp
  8012af:	75 03                	jne    8012b4 <__udivdi3+0xc4>
  8012b1:	83 eb 01             	sub    $0x1,%ebx
  8012b4:	31 ff                	xor    %edi,%edi
  8012b6:	89 d8                	mov    %ebx,%eax
  8012b8:	89 fa                	mov    %edi,%edx
  8012ba:	83 c4 1c             	add    $0x1c,%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    
  8012c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c8:	31 ff                	xor    %edi,%edi
  8012ca:	31 db                	xor    %ebx,%ebx
  8012cc:	89 d8                	mov    %ebx,%eax
  8012ce:	89 fa                	mov    %edi,%edx
  8012d0:	83 c4 1c             	add    $0x1c,%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    
  8012d8:	90                   	nop
  8012d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	89 d8                	mov    %ebx,%eax
  8012e2:	f7 f7                	div    %edi
  8012e4:	31 ff                	xor    %edi,%edi
  8012e6:	89 c3                	mov    %eax,%ebx
  8012e8:	89 d8                	mov    %ebx,%eax
  8012ea:	89 fa                	mov    %edi,%edx
  8012ec:	83 c4 1c             	add    $0x1c,%esp
  8012ef:	5b                   	pop    %ebx
  8012f0:	5e                   	pop    %esi
  8012f1:	5f                   	pop    %edi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	39 ce                	cmp    %ecx,%esi
  8012fa:	72 0c                	jb     801308 <__udivdi3+0x118>
  8012fc:	31 db                	xor    %ebx,%ebx
  8012fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801302:	0f 87 34 ff ff ff    	ja     80123c <__udivdi3+0x4c>
  801308:	bb 01 00 00 00       	mov    $0x1,%ebx
  80130d:	e9 2a ff ff ff       	jmp    80123c <__udivdi3+0x4c>
  801312:	66 90                	xchg   %ax,%ax
  801314:	66 90                	xchg   %ax,%ax
  801316:	66 90                	xchg   %ax,%ax
  801318:	66 90                	xchg   %ax,%ax
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__umoddi3>:
  801320:	55                   	push   %ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
  801324:	83 ec 1c             	sub    $0x1c,%esp
  801327:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80132b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80132f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801333:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801337:	85 d2                	test   %edx,%edx
  801339:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80133d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801341:	89 f3                	mov    %esi,%ebx
  801343:	89 3c 24             	mov    %edi,(%esp)
  801346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80134a:	75 1c                	jne    801368 <__umoddi3+0x48>
  80134c:	39 f7                	cmp    %esi,%edi
  80134e:	76 50                	jbe    8013a0 <__umoddi3+0x80>
  801350:	89 c8                	mov    %ecx,%eax
  801352:	89 f2                	mov    %esi,%edx
  801354:	f7 f7                	div    %edi
  801356:	89 d0                	mov    %edx,%eax
  801358:	31 d2                	xor    %edx,%edx
  80135a:	83 c4 1c             	add    $0x1c,%esp
  80135d:	5b                   	pop    %ebx
  80135e:	5e                   	pop    %esi
  80135f:	5f                   	pop    %edi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    
  801362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801368:	39 f2                	cmp    %esi,%edx
  80136a:	89 d0                	mov    %edx,%eax
  80136c:	77 52                	ja     8013c0 <__umoddi3+0xa0>
  80136e:	0f bd ea             	bsr    %edx,%ebp
  801371:	83 f5 1f             	xor    $0x1f,%ebp
  801374:	75 5a                	jne    8013d0 <__umoddi3+0xb0>
  801376:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80137a:	0f 82 e0 00 00 00    	jb     801460 <__umoddi3+0x140>
  801380:	39 0c 24             	cmp    %ecx,(%esp)
  801383:	0f 86 d7 00 00 00    	jbe    801460 <__umoddi3+0x140>
  801389:	8b 44 24 08          	mov    0x8(%esp),%eax
  80138d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801391:	83 c4 1c             	add    $0x1c,%esp
  801394:	5b                   	pop    %ebx
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    
  801399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	85 ff                	test   %edi,%edi
  8013a2:	89 fd                	mov    %edi,%ebp
  8013a4:	75 0b                	jne    8013b1 <__umoddi3+0x91>
  8013a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	f7 f7                	div    %edi
  8013af:	89 c5                	mov    %eax,%ebp
  8013b1:	89 f0                	mov    %esi,%eax
  8013b3:	31 d2                	xor    %edx,%edx
  8013b5:	f7 f5                	div    %ebp
  8013b7:	89 c8                	mov    %ecx,%eax
  8013b9:	f7 f5                	div    %ebp
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	eb 99                	jmp    801358 <__umoddi3+0x38>
  8013bf:	90                   	nop
  8013c0:	89 c8                	mov    %ecx,%eax
  8013c2:	89 f2                	mov    %esi,%edx
  8013c4:	83 c4 1c             	add    $0x1c,%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	8b 34 24             	mov    (%esp),%esi
  8013d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013d8:	89 e9                	mov    %ebp,%ecx
  8013da:	29 ef                	sub    %ebp,%edi
  8013dc:	d3 e0                	shl    %cl,%eax
  8013de:	89 f9                	mov    %edi,%ecx
  8013e0:	89 f2                	mov    %esi,%edx
  8013e2:	d3 ea                	shr    %cl,%edx
  8013e4:	89 e9                	mov    %ebp,%ecx
  8013e6:	09 c2                	or     %eax,%edx
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	89 14 24             	mov    %edx,(%esp)
  8013ed:	89 f2                	mov    %esi,%edx
  8013ef:	d3 e2                	shl    %cl,%edx
  8013f1:	89 f9                	mov    %edi,%ecx
  8013f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013fb:	d3 e8                	shr    %cl,%eax
  8013fd:	89 e9                	mov    %ebp,%ecx
  8013ff:	89 c6                	mov    %eax,%esi
  801401:	d3 e3                	shl    %cl,%ebx
  801403:	89 f9                	mov    %edi,%ecx
  801405:	89 d0                	mov    %edx,%eax
  801407:	d3 e8                	shr    %cl,%eax
  801409:	89 e9                	mov    %ebp,%ecx
  80140b:	09 d8                	or     %ebx,%eax
  80140d:	89 d3                	mov    %edx,%ebx
  80140f:	89 f2                	mov    %esi,%edx
  801411:	f7 34 24             	divl   (%esp)
  801414:	89 d6                	mov    %edx,%esi
  801416:	d3 e3                	shl    %cl,%ebx
  801418:	f7 64 24 04          	mull   0x4(%esp)
  80141c:	39 d6                	cmp    %edx,%esi
  80141e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801422:	89 d1                	mov    %edx,%ecx
  801424:	89 c3                	mov    %eax,%ebx
  801426:	72 08                	jb     801430 <__umoddi3+0x110>
  801428:	75 11                	jne    80143b <__umoddi3+0x11b>
  80142a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80142e:	73 0b                	jae    80143b <__umoddi3+0x11b>
  801430:	2b 44 24 04          	sub    0x4(%esp),%eax
  801434:	1b 14 24             	sbb    (%esp),%edx
  801437:	89 d1                	mov    %edx,%ecx
  801439:	89 c3                	mov    %eax,%ebx
  80143b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80143f:	29 da                	sub    %ebx,%edx
  801441:	19 ce                	sbb    %ecx,%esi
  801443:	89 f9                	mov    %edi,%ecx
  801445:	89 f0                	mov    %esi,%eax
  801447:	d3 e0                	shl    %cl,%eax
  801449:	89 e9                	mov    %ebp,%ecx
  80144b:	d3 ea                	shr    %cl,%edx
  80144d:	89 e9                	mov    %ebp,%ecx
  80144f:	d3 ee                	shr    %cl,%esi
  801451:	09 d0                	or     %edx,%eax
  801453:	89 f2                	mov    %esi,%edx
  801455:	83 c4 1c             	add    $0x1c,%esp
  801458:	5b                   	pop    %ebx
  801459:	5e                   	pop    %esi
  80145a:	5f                   	pop    %edi
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    
  80145d:	8d 76 00             	lea    0x0(%esi),%esi
  801460:	29 f9                	sub    %edi,%ecx
  801462:	19 d6                	sbb    %edx,%esi
  801464:	89 74 24 04          	mov    %esi,0x4(%esp)
  801468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80146c:	e9 18 ff ff ff       	jmp    801389 <__umoddi3+0x69>
