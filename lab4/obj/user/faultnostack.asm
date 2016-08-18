
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
  800145:	68 4a 14 80 00       	push   $0x80144a
  80014a:	6a 29                	push   $0x29
  80014c:	68 67 14 80 00       	push   $0x801467
  800151:	e8 11 03 00 00       	call   800467 <_panic>

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
  80022c:	68 4a 14 80 00       	push   $0x80144a
  800231:	6a 29                	push   $0x29
  800233:	68 67 14 80 00       	push   $0x801467
  800238:	e8 2a 02 00 00       	call   800467 <_panic>

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
  80029d:	68 4a 14 80 00       	push   $0x80144a
  8002a2:	6a 29                	push   $0x29
  8002a4:	68 67 14 80 00       	push   $0x801467
  8002a9:	e8 b9 01 00 00       	call   800467 <_panic>
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
  8002ee:	68 4a 14 80 00       	push   $0x80144a
  8002f3:	6a 29                	push   $0x29
  8002f5:	68 67 14 80 00       	push   $0x801467
  8002fa:	e8 68 01 00 00       	call   800467 <_panic>

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
  80033f:	68 4a 14 80 00       	push   $0x80144a
  800344:	6a 29                	push   $0x29
  800346:	68 67 14 80 00       	push   $0x801467
  80034b:	e8 17 01 00 00       	call   800467 <_panic>

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
  800390:	68 4a 14 80 00       	push   $0x80144a
  800395:	6a 29                	push   $0x29
  800397:	68 67 14 80 00       	push   $0x801467
  80039c:	e8 c6 00 00 00       	call   800467 <_panic>

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
  800412:	68 4a 14 80 00       	push   $0x80144a
  800417:	6a 29                	push   $0x29
  800419:	68 67 14 80 00       	push   $0x801467
  80041e:	e8 44 00 00 00       	call   800467 <_panic>

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

00800467 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	56                   	push   %esi
  80046b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80046c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80046f:	a1 10 20 80 00       	mov    0x802010,%eax
  800474:	85 c0                	test   %eax,%eax
  800476:	74 11                	je     800489 <_panic+0x22>
		cprintf("%s: ", argv0);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	50                   	push   %eax
  80047c:	68 75 14 80 00       	push   $0x801475
  800481:	e8 d4 00 00 00       	call   80055a <cprintf>
  800486:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800489:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80048f:	e8 c9 fc ff ff       	call   80015d <sys_getenvid>
  800494:	83 ec 0c             	sub    $0xc,%esp
  800497:	ff 75 0c             	pushl  0xc(%ebp)
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	56                   	push   %esi
  80049e:	50                   	push   %eax
  80049f:	68 7c 14 80 00       	push   $0x80147c
  8004a4:	e8 b1 00 00 00       	call   80055a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004a9:	83 c4 18             	add    $0x18,%esp
  8004ac:	53                   	push   %ebx
  8004ad:	ff 75 10             	pushl  0x10(%ebp)
  8004b0:	e8 54 00 00 00       	call   800509 <vcprintf>
	cprintf("\n");
  8004b5:	c7 04 24 7a 14 80 00 	movl   $0x80147a,(%esp)
  8004bc:	e8 99 00 00 00       	call   80055a <cprintf>
  8004c1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004c4:	cc                   	int3   
  8004c5:	eb fd                	jmp    8004c4 <_panic+0x5d>

008004c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	53                   	push   %ebx
  8004cb:	83 ec 04             	sub    $0x4,%esp
  8004ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004d1:	8b 13                	mov    (%ebx),%edx
  8004d3:	8d 42 01             	lea    0x1(%edx),%eax
  8004d6:	89 03                	mov    %eax,(%ebx)
  8004d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004e4:	75 1a                	jne    800500 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	68 ff 00 00 00       	push   $0xff
  8004ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8004f1:	50                   	push   %eax
  8004f2:	e8 b5 fb ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8004f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004fd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800500:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800504:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800507:	c9                   	leave  
  800508:	c3                   	ret    

00800509 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800509:	55                   	push   %ebp
  80050a:	89 e5                	mov    %esp,%ebp
  80050c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800512:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800519:	00 00 00 
	b.cnt = 0;
  80051c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800523:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800526:	ff 75 0c             	pushl  0xc(%ebp)
  800529:	ff 75 08             	pushl  0x8(%ebp)
  80052c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800532:	50                   	push   %eax
  800533:	68 c7 04 80 00       	push   $0x8004c7
  800538:	e8 c0 02 00 00       	call   8007fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80053d:	83 c4 08             	add    $0x8,%esp
  800540:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800546:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80054c:	50                   	push   %eax
  80054d:	e8 5a fb ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800552:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800558:	c9                   	leave  
  800559:	c3                   	ret    

0080055a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800560:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800563:	50                   	push   %eax
  800564:	ff 75 08             	pushl  0x8(%ebp)
  800567:	e8 9d ff ff ff       	call   800509 <vcprintf>
	va_end(ap);

	return cnt;
}
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    

0080056e <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	57                   	push   %edi
  800572:	56                   	push   %esi
  800573:	53                   	push   %ebx
  800574:	83 ec 1c             	sub    $0x1c,%esp
  800577:	89 c7                	mov    %eax,%edi
  800579:	89 d6                	mov    %edx,%esi
  80057b:	8b 45 08             	mov    0x8(%ebp),%eax
  80057e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800581:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800584:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800587:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80058a:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80058e:	0f 85 bf 00 00 00    	jne    800653 <printnum+0xe5>
  800594:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  80059a:	0f 8d de 00 00 00    	jge    80067e <printnum+0x110>
		judge_time_for_space = width;
  8005a0:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  8005a6:	e9 d3 00 00 00       	jmp    80067e <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005ab:	83 eb 01             	sub    $0x1,%ebx
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7f 37                	jg     8005e9 <printnum+0x7b>
  8005b2:	e9 ea 00 00 00       	jmp    8006a1 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8005b7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8005ba:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	56                   	push   %esi
  8005c3:	83 ec 04             	sub    $0x4,%esp
  8005c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8005c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8005cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d2:	e8 f9 0c 00 00       	call   8012d0 <__umoddi3>
  8005d7:	83 c4 14             	add    $0x14,%esp
  8005da:	0f be 80 9f 14 80 00 	movsbl 0x80149f(%eax),%eax
  8005e1:	50                   	push   %eax
  8005e2:	ff d7                	call   *%edi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb 16                	jmp    8005ff <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	56                   	push   %esi
  8005ed:	ff 75 18             	pushl  0x18(%ebp)
  8005f0:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	83 eb 01             	sub    $0x1,%ebx
  8005f8:	75 ef                	jne    8005e9 <printnum+0x7b>
  8005fa:	e9 a2 00 00 00       	jmp    8006a1 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005ff:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  800605:	0f 85 76 01 00 00    	jne    800781 <printnum+0x213>
		while(num_of_space-- > 0)
  80060b:	a1 04 20 80 00       	mov    0x802004,%eax
  800610:	8d 50 ff             	lea    -0x1(%eax),%edx
  800613:	89 15 04 20 80 00    	mov    %edx,0x802004
  800619:	85 c0                	test   %eax,%eax
  80061b:	7e 1d                	jle    80063a <printnum+0xcc>
			putch(' ', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	56                   	push   %esi
  800621:	6a 20                	push   $0x20
  800623:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800625:	a1 04 20 80 00       	mov    0x802004,%eax
  80062a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80062d:	89 15 04 20 80 00    	mov    %edx,0x802004
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	85 c0                	test   %eax,%eax
  800638:	7f e3                	jg     80061d <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  80063a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800641:	00 00 00 
		judge_time_for_space = 0;
  800644:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80064b:	00 00 00 
	}
}
  80064e:	e9 2e 01 00 00       	jmp    800781 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800653:	8b 45 10             	mov    0x10(%ebp),%eax
  800656:	ba 00 00 00 00       	mov    $0x0,%edx
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800661:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800664:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800667:	83 fa 00             	cmp    $0x0,%edx
  80066a:	0f 87 ba 00 00 00    	ja     80072a <printnum+0x1bc>
  800670:	3b 45 10             	cmp    0x10(%ebp),%eax
  800673:	0f 83 b1 00 00 00    	jae    80072a <printnum+0x1bc>
  800679:	e9 2d ff ff ff       	jmp    8005ab <printnum+0x3d>
  80067e:	8b 45 10             	mov    0x10(%ebp),%eax
  800681:	ba 00 00 00 00       	mov    $0x0,%edx
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800692:	83 fa 00             	cmp    $0x0,%edx
  800695:	77 37                	ja     8006ce <printnum+0x160>
  800697:	3b 45 10             	cmp    0x10(%ebp),%eax
  80069a:	73 32                	jae    8006ce <printnum+0x160>
  80069c:	e9 16 ff ff ff       	jmp    8005b7 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	56                   	push   %esi
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b4:	e8 17 0c 00 00       	call   8012d0 <__umoddi3>
  8006b9:	83 c4 14             	add    $0x14,%esp
  8006bc:	0f be 80 9f 14 80 00 	movsbl 0x80149f(%eax),%eax
  8006c3:	50                   	push   %eax
  8006c4:	ff d7                	call   *%edi
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	e9 b3 00 00 00       	jmp    800781 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	ff 75 18             	pushl  0x18(%ebp)
  8006d4:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006d7:	50                   	push   %eax
  8006d8:	ff 75 10             	pushl  0x10(%ebp)
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	ff 75 dc             	pushl  -0x24(%ebp)
  8006e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ea:	e8 b1 0a 00 00       	call   8011a0 <__udivdi3>
  8006ef:	83 c4 18             	add    $0x18,%esp
  8006f2:	52                   	push   %edx
  8006f3:	50                   	push   %eax
  8006f4:	89 f2                	mov    %esi,%edx
  8006f6:	89 f8                	mov    %edi,%eax
  8006f8:	e8 71 fe ff ff       	call   80056e <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006fd:	83 c4 18             	add    $0x18,%esp
  800700:	56                   	push   %esi
  800701:	83 ec 04             	sub    $0x4,%esp
  800704:	ff 75 dc             	pushl  -0x24(%ebp)
  800707:	ff 75 d8             	pushl  -0x28(%ebp)
  80070a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80070d:	ff 75 e0             	pushl  -0x20(%ebp)
  800710:	e8 bb 0b 00 00       	call   8012d0 <__umoddi3>
  800715:	83 c4 14             	add    $0x14,%esp
  800718:	0f be 80 9f 14 80 00 	movsbl 0x80149f(%eax),%eax
  80071f:	50                   	push   %eax
  800720:	ff d7                	call   *%edi
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	e9 d5 fe ff ff       	jmp    8005ff <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80072a:	83 ec 0c             	sub    $0xc,%esp
  80072d:	ff 75 18             	pushl  0x18(%ebp)
  800730:	83 eb 01             	sub    $0x1,%ebx
  800733:	53                   	push   %ebx
  800734:	ff 75 10             	pushl  0x10(%ebp)
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 dc             	pushl  -0x24(%ebp)
  80073d:	ff 75 d8             	pushl  -0x28(%ebp)
  800740:	ff 75 e4             	pushl  -0x1c(%ebp)
  800743:	ff 75 e0             	pushl  -0x20(%ebp)
  800746:	e8 55 0a 00 00       	call   8011a0 <__udivdi3>
  80074b:	83 c4 18             	add    $0x18,%esp
  80074e:	52                   	push   %edx
  80074f:	50                   	push   %eax
  800750:	89 f2                	mov    %esi,%edx
  800752:	89 f8                	mov    %edi,%eax
  800754:	e8 15 fe ff ff       	call   80056e <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800759:	83 c4 18             	add    $0x18,%esp
  80075c:	56                   	push   %esi
  80075d:	83 ec 04             	sub    $0x4,%esp
  800760:	ff 75 dc             	pushl  -0x24(%ebp)
  800763:	ff 75 d8             	pushl  -0x28(%ebp)
  800766:	ff 75 e4             	pushl  -0x1c(%ebp)
  800769:	ff 75 e0             	pushl  -0x20(%ebp)
  80076c:	e8 5f 0b 00 00       	call   8012d0 <__umoddi3>
  800771:	83 c4 14             	add    $0x14,%esp
  800774:	0f be 80 9f 14 80 00 	movsbl 0x80149f(%eax),%eax
  80077b:	50                   	push   %eax
  80077c:	ff d7                	call   *%edi
  80077e:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5f                   	pop    %edi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078c:	83 fa 01             	cmp    $0x1,%edx
  80078f:	7e 0e                	jle    80079f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800791:	8b 10                	mov    (%eax),%edx
  800793:	8d 4a 08             	lea    0x8(%edx),%ecx
  800796:	89 08                	mov    %ecx,(%eax)
  800798:	8b 02                	mov    (%edx),%eax
  80079a:	8b 52 04             	mov    0x4(%edx),%edx
  80079d:	eb 22                	jmp    8007c1 <getuint+0x38>
	else if (lflag)
  80079f:	85 d2                	test   %edx,%edx
  8007a1:	74 10                	je     8007b3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a3:	8b 10                	mov    (%eax),%edx
  8007a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a8:	89 08                	mov    %ecx,(%eax)
  8007aa:	8b 02                	mov    (%edx),%eax
  8007ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b1:	eb 0e                	jmp    8007c1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b3:	8b 10                	mov    (%eax),%edx
  8007b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b8:	89 08                	mov    %ecx,(%eax)
  8007ba:	8b 02                	mov    (%edx),%eax
  8007bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007cd:	8b 10                	mov    (%eax),%edx
  8007cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d2:	73 0a                	jae    8007de <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d7:	89 08                	mov    %ecx,(%eax)
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	88 02                	mov    %al,(%edx)
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e9:	50                   	push   %eax
  8007ea:	ff 75 10             	pushl  0x10(%ebp)
  8007ed:	ff 75 0c             	pushl  0xc(%ebp)
  8007f0:	ff 75 08             	pushl  0x8(%ebp)
  8007f3:	e8 05 00 00 00       	call   8007fd <vprintfmt>
	va_end(ap);
}
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	57                   	push   %edi
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	83 ec 2c             	sub    $0x2c,%esp
  800806:	8b 7d 08             	mov    0x8(%ebp),%edi
  800809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080c:	eb 03                	jmp    800811 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80080e:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800811:	8b 45 10             	mov    0x10(%ebp),%eax
  800814:	8d 70 01             	lea    0x1(%eax),%esi
  800817:	0f b6 00             	movzbl (%eax),%eax
  80081a:	83 f8 25             	cmp    $0x25,%eax
  80081d:	74 27                	je     800846 <vprintfmt+0x49>
			if (ch == '\0')
  80081f:	85 c0                	test   %eax,%eax
  800821:	75 0d                	jne    800830 <vprintfmt+0x33>
  800823:	e9 9d 04 00 00       	jmp    800cc5 <vprintfmt+0x4c8>
  800828:	85 c0                	test   %eax,%eax
  80082a:	0f 84 95 04 00 00    	je     800cc5 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	53                   	push   %ebx
  800834:	50                   	push   %eax
  800835:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800837:	83 c6 01             	add    $0x1,%esi
  80083a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	83 f8 25             	cmp    $0x25,%eax
  800844:	75 e2                	jne    800828 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800846:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084b:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80084f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800856:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80085d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800864:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80086b:	eb 08                	jmp    800875 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086d:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800870:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800875:	8d 46 01             	lea    0x1(%esi),%eax
  800878:	89 45 10             	mov    %eax,0x10(%ebp)
  80087b:	0f b6 06             	movzbl (%esi),%eax
  80087e:	0f b6 d0             	movzbl %al,%edx
  800881:	83 e8 23             	sub    $0x23,%eax
  800884:	3c 55                	cmp    $0x55,%al
  800886:	0f 87 fa 03 00 00    	ja     800c86 <vprintfmt+0x489>
  80088c:	0f b6 c0             	movzbl %al,%eax
  80088f:	ff 24 85 e0 15 80 00 	jmp    *0x8015e0(,%eax,4)
  800896:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800899:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80089d:	eb d6                	jmp    800875 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80089f:	8d 42 d0             	lea    -0x30(%edx),%eax
  8008a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8008a5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8008a9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008ac:	83 fa 09             	cmp    $0x9,%edx
  8008af:	77 6b                	ja     80091c <vprintfmt+0x11f>
  8008b1:	8b 75 10             	mov    0x10(%ebp),%esi
  8008b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008b7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8008ba:	eb 09                	jmp    8008c5 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bc:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008bf:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008c3:	eb b0                	jmp    800875 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008c5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008c8:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008cb:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008cf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008d2:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008d5:	83 f9 09             	cmp    $0x9,%ecx
  8008d8:	76 eb                	jbe    8008c5 <vprintfmt+0xc8>
  8008da:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008dd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008e0:	eb 3d                	jmp    80091f <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8d 50 04             	lea    0x4(%eax),%edx
  8008e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008eb:	8b 00                	mov    (%eax),%eax
  8008ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f0:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008f3:	eb 2a                	jmp    80091f <vprintfmt+0x122>
  8008f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008f8:	85 c0                	test   %eax,%eax
  8008fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ff:	0f 49 d0             	cmovns %eax,%edx
  800902:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800905:	8b 75 10             	mov    0x10(%ebp),%esi
  800908:	e9 68 ff ff ff       	jmp    800875 <vprintfmt+0x78>
  80090d:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800910:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800917:	e9 59 ff ff ff       	jmp    800875 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091c:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80091f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800923:	0f 89 4c ff ff ff    	jns    800875 <vprintfmt+0x78>
				width = precision, precision = -1;
  800929:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80092c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80092f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800936:	e9 3a ff ff ff       	jmp    800875 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80093b:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093f:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800942:	e9 2e ff ff ff       	jmp    800875 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	8d 50 04             	lea    0x4(%eax),%edx
  80094d:	89 55 14             	mov    %edx,0x14(%ebp)
  800950:	83 ec 08             	sub    $0x8,%esp
  800953:	53                   	push   %ebx
  800954:	ff 30                	pushl  (%eax)
  800956:	ff d7                	call   *%edi
			break;
  800958:	83 c4 10             	add    $0x10,%esp
  80095b:	e9 b1 fe ff ff       	jmp    800811 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8d 50 04             	lea    0x4(%eax),%edx
  800966:	89 55 14             	mov    %edx,0x14(%ebp)
  800969:	8b 00                	mov    (%eax),%eax
  80096b:	99                   	cltd   
  80096c:	31 d0                	xor    %edx,%eax
  80096e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800970:	83 f8 08             	cmp    $0x8,%eax
  800973:	7f 0b                	jg     800980 <vprintfmt+0x183>
  800975:	8b 14 85 40 17 80 00 	mov    0x801740(,%eax,4),%edx
  80097c:	85 d2                	test   %edx,%edx
  80097e:	75 15                	jne    800995 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800980:	50                   	push   %eax
  800981:	68 b7 14 80 00       	push   $0x8014b7
  800986:	53                   	push   %ebx
  800987:	57                   	push   %edi
  800988:	e8 53 fe ff ff       	call   8007e0 <printfmt>
  80098d:	83 c4 10             	add    $0x10,%esp
  800990:	e9 7c fe ff ff       	jmp    800811 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800995:	52                   	push   %edx
  800996:	68 c0 14 80 00       	push   $0x8014c0
  80099b:	53                   	push   %ebx
  80099c:	57                   	push   %edi
  80099d:	e8 3e fe ff ff       	call   8007e0 <printfmt>
  8009a2:	83 c4 10             	add    $0x10,%esp
  8009a5:	e9 67 fe ff ff       	jmp    800811 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ad:	8d 50 04             	lea    0x4(%eax),%edx
  8009b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b3:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	b9 b0 14 80 00       	mov    $0x8014b0,%ecx
  8009bc:	0f 45 c8             	cmovne %eax,%ecx
  8009bf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009c6:	7e 06                	jle    8009ce <vprintfmt+0x1d1>
  8009c8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009cc:	75 19                	jne    8009e7 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009d1:	8d 70 01             	lea    0x1(%eax),%esi
  8009d4:	0f b6 00             	movzbl (%eax),%eax
  8009d7:	0f be d0             	movsbl %al,%edx
  8009da:	85 d2                	test   %edx,%edx
  8009dc:	0f 85 9f 00 00 00    	jne    800a81 <vprintfmt+0x284>
  8009e2:	e9 8c 00 00 00       	jmp    800a73 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e7:	83 ec 08             	sub    $0x8,%esp
  8009ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8009ed:	ff 75 cc             	pushl  -0x34(%ebp)
  8009f0:	e8 62 03 00 00       	call   800d57 <strnlen>
  8009f5:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009f8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009fb:	83 c4 10             	add    $0x10,%esp
  8009fe:	85 c9                	test   %ecx,%ecx
  800a00:	0f 8e a6 02 00 00    	jle    800cac <vprintfmt+0x4af>
					putch(padc, putdat);
  800a06:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800a0a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a0d:	89 cb                	mov    %ecx,%ebx
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	56                   	push   %esi
  800a16:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a18:	83 c4 10             	add    $0x10,%esp
  800a1b:	83 eb 01             	sub    $0x1,%ebx
  800a1e:	75 ef                	jne    800a0f <vprintfmt+0x212>
  800a20:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a26:	e9 81 02 00 00       	jmp    800cac <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a2b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a2f:	74 1b                	je     800a4c <vprintfmt+0x24f>
  800a31:	0f be c0             	movsbl %al,%eax
  800a34:	83 e8 20             	sub    $0x20,%eax
  800a37:	83 f8 5e             	cmp    $0x5e,%eax
  800a3a:	76 10                	jbe    800a4c <vprintfmt+0x24f>
					putch('?', putdat);
  800a3c:	83 ec 08             	sub    $0x8,%esp
  800a3f:	ff 75 0c             	pushl  0xc(%ebp)
  800a42:	6a 3f                	push   $0x3f
  800a44:	ff 55 08             	call   *0x8(%ebp)
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	eb 0d                	jmp    800a59 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	52                   	push   %edx
  800a53:	ff 55 08             	call   *0x8(%ebp)
  800a56:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a59:	83 ef 01             	sub    $0x1,%edi
  800a5c:	83 c6 01             	add    $0x1,%esi
  800a5f:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a63:	0f be d0             	movsbl %al,%edx
  800a66:	85 d2                	test   %edx,%edx
  800a68:	75 31                	jne    800a9b <vprintfmt+0x29e>
  800a6a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a73:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a76:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a7a:	7f 33                	jg     800aaf <vprintfmt+0x2b2>
  800a7c:	e9 90 fd ff ff       	jmp    800811 <vprintfmt+0x14>
  800a81:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a87:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a8a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a8d:	eb 0c                	jmp    800a9b <vprintfmt+0x29e>
  800a8f:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a95:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a98:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	78 8c                	js     800a2b <vprintfmt+0x22e>
  800a9f:	83 eb 01             	sub    $0x1,%ebx
  800aa2:	79 87                	jns    800a2b <vprintfmt+0x22e>
  800aa4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800aa7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aad:	eb c4                	jmp    800a73 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aaf:	83 ec 08             	sub    $0x8,%esp
  800ab2:	53                   	push   %ebx
  800ab3:	6a 20                	push   $0x20
  800ab5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ab7:	83 c4 10             	add    $0x10,%esp
  800aba:	83 ee 01             	sub    $0x1,%esi
  800abd:	75 f0                	jne    800aaf <vprintfmt+0x2b2>
  800abf:	e9 4d fd ff ff       	jmp    800811 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ac4:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800ac8:	7e 16                	jle    800ae0 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800aca:	8b 45 14             	mov    0x14(%ebp),%eax
  800acd:	8d 50 08             	lea    0x8(%eax),%edx
  800ad0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad3:	8b 50 04             	mov    0x4(%eax),%edx
  800ad6:	8b 00                	mov    (%eax),%eax
  800ad8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800adb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ade:	eb 34                	jmp    800b14 <vprintfmt+0x317>
	else if (lflag)
  800ae0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ae4:	74 18                	je     800afe <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ae6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae9:	8d 50 04             	lea    0x4(%eax),%edx
  800aec:	89 55 14             	mov    %edx,0x14(%ebp)
  800aef:	8b 30                	mov    (%eax),%esi
  800af1:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800af4:	89 f0                	mov    %esi,%eax
  800af6:	c1 f8 1f             	sar    $0x1f,%eax
  800af9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800afc:	eb 16                	jmp    800b14 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800afe:	8b 45 14             	mov    0x14(%ebp),%eax
  800b01:	8d 50 04             	lea    0x4(%eax),%edx
  800b04:	89 55 14             	mov    %edx,0x14(%ebp)
  800b07:	8b 30                	mov    (%eax),%esi
  800b09:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800b0c:	89 f0                	mov    %esi,%eax
  800b0e:	c1 f8 1f             	sar    $0x1f,%eax
  800b11:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b14:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b17:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b1a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b20:	85 d2                	test   %edx,%edx
  800b22:	79 28                	jns    800b4c <vprintfmt+0x34f>
				putch('-', putdat);
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	53                   	push   %ebx
  800b28:	6a 2d                	push   $0x2d
  800b2a:	ff d7                	call   *%edi
				num = -(long long) num;
  800b2c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b32:	f7 d8                	neg    %eax
  800b34:	83 d2 00             	adc    $0x0,%edx
  800b37:	f7 da                	neg    %edx
  800b39:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b3c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b3f:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b47:	e9 b2 00 00 00       	jmp    800bfe <vprintfmt+0x401>
  800b4c:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b51:	85 c9                	test   %ecx,%ecx
  800b53:	0f 84 a5 00 00 00    	je     800bfe <vprintfmt+0x401>
				putch('+', putdat);
  800b59:	83 ec 08             	sub    $0x8,%esp
  800b5c:	53                   	push   %ebx
  800b5d:	6a 2b                	push   $0x2b
  800b5f:	ff d7                	call   *%edi
  800b61:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b69:	e9 90 00 00 00       	jmp    800bfe <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b6e:	85 c9                	test   %ecx,%ecx
  800b70:	74 0b                	je     800b7d <vprintfmt+0x380>
				putch('+', putdat);
  800b72:	83 ec 08             	sub    $0x8,%esp
  800b75:	53                   	push   %ebx
  800b76:	6a 2b                	push   $0x2b
  800b78:	ff d7                	call   *%edi
  800b7a:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b7d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b80:	8d 45 14             	lea    0x14(%ebp),%eax
  800b83:	e8 01 fc ff ff       	call   800789 <getuint>
  800b88:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b8b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b8e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b93:	eb 69                	jmp    800bfe <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	53                   	push   %ebx
  800b99:	6a 30                	push   $0x30
  800b9b:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b9d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ba0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba3:	e8 e1 fb ff ff       	call   800789 <getuint>
  800ba8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bab:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800bae:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800bb1:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800bb6:	eb 46                	jmp    800bfe <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800bb8:	83 ec 08             	sub    $0x8,%esp
  800bbb:	53                   	push   %ebx
  800bbc:	6a 30                	push   $0x30
  800bbe:	ff d7                	call   *%edi
			putch('x', putdat);
  800bc0:	83 c4 08             	add    $0x8,%esp
  800bc3:	53                   	push   %ebx
  800bc4:	6a 78                	push   $0x78
  800bc6:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcb:	8d 50 04             	lea    0x4(%eax),%edx
  800bce:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bd1:	8b 00                	mov    (%eax),%eax
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bdb:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bde:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800be1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800be6:	eb 16                	jmp    800bfe <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800be8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800beb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bee:	e8 96 fb ff ff       	call   800789 <getuint>
  800bf3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bf6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bf9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800c05:	56                   	push   %esi
  800c06:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c09:	50                   	push   %eax
  800c0a:	ff 75 dc             	pushl  -0x24(%ebp)
  800c0d:	ff 75 d8             	pushl  -0x28(%ebp)
  800c10:	89 da                	mov    %ebx,%edx
  800c12:	89 f8                	mov    %edi,%eax
  800c14:	e8 55 f9 ff ff       	call   80056e <printnum>
			break;
  800c19:	83 c4 20             	add    $0x20,%esp
  800c1c:	e9 f0 fb ff ff       	jmp    800811 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c21:	8b 45 14             	mov    0x14(%ebp),%eax
  800c24:	8d 50 04             	lea    0x4(%eax),%edx
  800c27:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2a:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c2c:	85 f6                	test   %esi,%esi
  800c2e:	75 1a                	jne    800c4a <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c30:	83 ec 08             	sub    $0x8,%esp
  800c33:	68 58 15 80 00       	push   $0x801558
  800c38:	68 c0 14 80 00       	push   $0x8014c0
  800c3d:	e8 18 f9 ff ff       	call   80055a <cprintf>
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	e9 c7 fb ff ff       	jmp    800811 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c4a:	0f b6 03             	movzbl (%ebx),%eax
  800c4d:	84 c0                	test   %al,%al
  800c4f:	79 1f                	jns    800c70 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c51:	83 ec 08             	sub    $0x8,%esp
  800c54:	68 90 15 80 00       	push   $0x801590
  800c59:	68 c0 14 80 00       	push   $0x8014c0
  800c5e:	e8 f7 f8 ff ff       	call   80055a <cprintf>
						*tmp = *(char *)putdat;
  800c63:	0f b6 03             	movzbl (%ebx),%eax
  800c66:	88 06                	mov    %al,(%esi)
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	e9 a1 fb ff ff       	jmp    800811 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c70:	88 06                	mov    %al,(%esi)
  800c72:	e9 9a fb ff ff       	jmp    800811 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c77:	83 ec 08             	sub    $0x8,%esp
  800c7a:	53                   	push   %ebx
  800c7b:	52                   	push   %edx
  800c7c:	ff d7                	call   *%edi
			break;
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	e9 8b fb ff ff       	jmp    800811 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c86:	83 ec 08             	sub    $0x8,%esp
  800c89:	53                   	push   %ebx
  800c8a:	6a 25                	push   $0x25
  800c8c:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c8e:	83 c4 10             	add    $0x10,%esp
  800c91:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c95:	0f 84 73 fb ff ff    	je     80080e <vprintfmt+0x11>
  800c9b:	83 ee 01             	sub    $0x1,%esi
  800c9e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ca2:	75 f7                	jne    800c9b <vprintfmt+0x49e>
  800ca4:	89 75 10             	mov    %esi,0x10(%ebp)
  800ca7:	e9 65 fb ff ff       	jmp    800811 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cac:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800caf:	8d 70 01             	lea    0x1(%eax),%esi
  800cb2:	0f b6 00             	movzbl (%eax),%eax
  800cb5:	0f be d0             	movsbl %al,%edx
  800cb8:	85 d2                	test   %edx,%edx
  800cba:	0f 85 cf fd ff ff    	jne    800a8f <vprintfmt+0x292>
  800cc0:	e9 4c fb ff ff       	jmp    800811 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	83 ec 18             	sub    $0x18,%esp
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cdc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ce0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ce3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	74 26                	je     800d14 <vsnprintf+0x47>
  800cee:	85 d2                	test   %edx,%edx
  800cf0:	7e 22                	jle    800d14 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cf2:	ff 75 14             	pushl  0x14(%ebp)
  800cf5:	ff 75 10             	pushl  0x10(%ebp)
  800cf8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cfb:	50                   	push   %eax
  800cfc:	68 c3 07 80 00       	push   $0x8007c3
  800d01:	e8 f7 fa ff ff       	call   8007fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d06:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d09:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d0f:	83 c4 10             	add    $0x10,%esp
  800d12:	eb 05                	jmp    800d19 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d21:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d24:	50                   	push   %eax
  800d25:	ff 75 10             	pushl  0x10(%ebp)
  800d28:	ff 75 0c             	pushl  0xc(%ebp)
  800d2b:	ff 75 08             	pushl  0x8(%ebp)
  800d2e:	e8 9a ff ff ff       	call   800ccd <vsnprintf>
	va_end(ap);

	return rc;
}
  800d33:	c9                   	leave  
  800d34:	c3                   	ret    

00800d35 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800d3e:	74 10                	je     800d50 <strlen+0x1b>
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d45:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d48:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d4c:	75 f7                	jne    800d45 <strlen+0x10>
  800d4e:	eb 05                	jmp    800d55 <strlen+0x20>
  800d50:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	53                   	push   %ebx
  800d5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d61:	85 c9                	test   %ecx,%ecx
  800d63:	74 1c                	je     800d81 <strnlen+0x2a>
  800d65:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d68:	74 1e                	je     800d88 <strnlen+0x31>
  800d6a:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d6f:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d71:	39 ca                	cmp    %ecx,%edx
  800d73:	74 18                	je     800d8d <strnlen+0x36>
  800d75:	83 c2 01             	add    $0x1,%edx
  800d78:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d7d:	75 f0                	jne    800d6f <strnlen+0x18>
  800d7f:	eb 0c                	jmp    800d8d <strnlen+0x36>
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
  800d86:	eb 05                	jmp    800d8d <strnlen+0x36>
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d8d:	5b                   	pop    %ebx
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	53                   	push   %ebx
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d9a:	89 c2                	mov    %eax,%edx
  800d9c:	83 c2 01             	add    $0x1,%edx
  800d9f:	83 c1 01             	add    $0x1,%ecx
  800da2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800da6:	88 5a ff             	mov    %bl,-0x1(%edx)
  800da9:	84 db                	test   %bl,%bl
  800dab:	75 ef                	jne    800d9c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800dad:	5b                   	pop    %ebx
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	53                   	push   %ebx
  800db4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800db7:	53                   	push   %ebx
  800db8:	e8 78 ff ff ff       	call   800d35 <strlen>
  800dbd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800dc0:	ff 75 0c             	pushl  0xc(%ebp)
  800dc3:	01 d8                	add    %ebx,%eax
  800dc5:	50                   	push   %eax
  800dc6:	e8 c5 ff ff ff       	call   800d90 <strcpy>
	return dst;
}
  800dcb:	89 d8                	mov    %ebx,%eax
  800dcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd0:	c9                   	leave  
  800dd1:	c3                   	ret    

00800dd2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	8b 75 08             	mov    0x8(%ebp),%esi
  800dda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de0:	85 db                	test   %ebx,%ebx
  800de2:	74 17                	je     800dfb <strncpy+0x29>
  800de4:	01 f3                	add    %esi,%ebx
  800de6:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800de8:	83 c1 01             	add    $0x1,%ecx
  800deb:	0f b6 02             	movzbl (%edx),%eax
  800dee:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800df1:	80 3a 01             	cmpb   $0x1,(%edx)
  800df4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800df7:	39 cb                	cmp    %ecx,%ebx
  800df9:	75 ed                	jne    800de8 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dfb:	89 f0                	mov    %esi,%eax
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	8b 75 08             	mov    0x8(%ebp),%esi
  800e09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e0c:	8b 55 10             	mov    0x10(%ebp),%edx
  800e0f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e11:	85 d2                	test   %edx,%edx
  800e13:	74 35                	je     800e4a <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800e15:	89 d0                	mov    %edx,%eax
  800e17:	83 e8 01             	sub    $0x1,%eax
  800e1a:	74 25                	je     800e41 <strlcpy+0x40>
  800e1c:	0f b6 0b             	movzbl (%ebx),%ecx
  800e1f:	84 c9                	test   %cl,%cl
  800e21:	74 22                	je     800e45 <strlcpy+0x44>
  800e23:	8d 53 01             	lea    0x1(%ebx),%edx
  800e26:	01 c3                	add    %eax,%ebx
  800e28:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e2a:	83 c0 01             	add    $0x1,%eax
  800e2d:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e30:	39 da                	cmp    %ebx,%edx
  800e32:	74 13                	je     800e47 <strlcpy+0x46>
  800e34:	83 c2 01             	add    $0x1,%edx
  800e37:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e3b:	84 c9                	test   %cl,%cl
  800e3d:	75 eb                	jne    800e2a <strlcpy+0x29>
  800e3f:	eb 06                	jmp    800e47 <strlcpy+0x46>
  800e41:	89 f0                	mov    %esi,%eax
  800e43:	eb 02                	jmp    800e47 <strlcpy+0x46>
  800e45:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e47:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e4a:	29 f0                	sub    %esi,%eax
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e56:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e59:	0f b6 01             	movzbl (%ecx),%eax
  800e5c:	84 c0                	test   %al,%al
  800e5e:	74 15                	je     800e75 <strcmp+0x25>
  800e60:	3a 02                	cmp    (%edx),%al
  800e62:	75 11                	jne    800e75 <strcmp+0x25>
		p++, q++;
  800e64:	83 c1 01             	add    $0x1,%ecx
  800e67:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e6a:	0f b6 01             	movzbl (%ecx),%eax
  800e6d:	84 c0                	test   %al,%al
  800e6f:	74 04                	je     800e75 <strcmp+0x25>
  800e71:	3a 02                	cmp    (%edx),%al
  800e73:	74 ef                	je     800e64 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e75:	0f b6 c0             	movzbl %al,%eax
  800e78:	0f b6 12             	movzbl (%edx),%edx
  800e7b:	29 d0                	sub    %edx,%eax
}
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8a:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e8d:	85 f6                	test   %esi,%esi
  800e8f:	74 29                	je     800eba <strncmp+0x3b>
  800e91:	0f b6 03             	movzbl (%ebx),%eax
  800e94:	84 c0                	test   %al,%al
  800e96:	74 30                	je     800ec8 <strncmp+0x49>
  800e98:	3a 02                	cmp    (%edx),%al
  800e9a:	75 2c                	jne    800ec8 <strncmp+0x49>
  800e9c:	8d 43 01             	lea    0x1(%ebx),%eax
  800e9f:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800ea1:	89 c3                	mov    %eax,%ebx
  800ea3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ea6:	39 c6                	cmp    %eax,%esi
  800ea8:	74 17                	je     800ec1 <strncmp+0x42>
  800eaa:	0f b6 08             	movzbl (%eax),%ecx
  800ead:	84 c9                	test   %cl,%cl
  800eaf:	74 17                	je     800ec8 <strncmp+0x49>
  800eb1:	83 c0 01             	add    $0x1,%eax
  800eb4:	3a 0a                	cmp    (%edx),%cl
  800eb6:	74 e9                	je     800ea1 <strncmp+0x22>
  800eb8:	eb 0e                	jmp    800ec8 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	eb 0f                	jmp    800ed0 <strncmp+0x51>
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	eb 08                	jmp    800ed0 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ec8:	0f b6 03             	movzbl (%ebx),%eax
  800ecb:	0f b6 12             	movzbl (%edx),%edx
  800ece:	29 d0                	sub    %edx,%eax
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	53                   	push   %ebx
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  800edb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ede:	0f b6 10             	movzbl (%eax),%edx
  800ee1:	84 d2                	test   %dl,%dl
  800ee3:	74 1d                	je     800f02 <strchr+0x2e>
  800ee5:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ee7:	38 d3                	cmp    %dl,%bl
  800ee9:	75 06                	jne    800ef1 <strchr+0x1d>
  800eeb:	eb 1a                	jmp    800f07 <strchr+0x33>
  800eed:	38 ca                	cmp    %cl,%dl
  800eef:	74 16                	je     800f07 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ef1:	83 c0 01             	add    $0x1,%eax
  800ef4:	0f b6 10             	movzbl (%eax),%edx
  800ef7:	84 d2                	test   %dl,%dl
  800ef9:	75 f2                	jne    800eed <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	eb 05                	jmp    800f07 <strchr+0x33>
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f07:	5b                   	pop    %ebx
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	53                   	push   %ebx
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800f14:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800f17:	38 d3                	cmp    %dl,%bl
  800f19:	74 14                	je     800f2f <strfind+0x25>
  800f1b:	89 d1                	mov    %edx,%ecx
  800f1d:	84 db                	test   %bl,%bl
  800f1f:	74 0e                	je     800f2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f21:	83 c0 01             	add    $0x1,%eax
  800f24:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f27:	38 ca                	cmp    %cl,%dl
  800f29:	74 04                	je     800f2f <strfind+0x25>
  800f2b:	84 d2                	test   %dl,%dl
  800f2d:	75 f2                	jne    800f21 <strfind+0x17>
			break;
	return (char *) s;
}
  800f2f:	5b                   	pop    %ebx
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f3e:	85 c9                	test   %ecx,%ecx
  800f40:	74 36                	je     800f78 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f42:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f48:	75 28                	jne    800f72 <memset+0x40>
  800f4a:	f6 c1 03             	test   $0x3,%cl
  800f4d:	75 23                	jne    800f72 <memset+0x40>
		c &= 0xFF;
  800f4f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f53:	89 d3                	mov    %edx,%ebx
  800f55:	c1 e3 08             	shl    $0x8,%ebx
  800f58:	89 d6                	mov    %edx,%esi
  800f5a:	c1 e6 18             	shl    $0x18,%esi
  800f5d:	89 d0                	mov    %edx,%eax
  800f5f:	c1 e0 10             	shl    $0x10,%eax
  800f62:	09 f0                	or     %esi,%eax
  800f64:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f66:	89 d8                	mov    %ebx,%eax
  800f68:	09 d0                	or     %edx,%eax
  800f6a:	c1 e9 02             	shr    $0x2,%ecx
  800f6d:	fc                   	cld    
  800f6e:	f3 ab                	rep stos %eax,%es:(%edi)
  800f70:	eb 06                	jmp    800f78 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f75:	fc                   	cld    
  800f76:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f78:	89 f8                	mov    %edi,%eax
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f8d:	39 c6                	cmp    %eax,%esi
  800f8f:	73 35                	jae    800fc6 <memmove+0x47>
  800f91:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f94:	39 d0                	cmp    %edx,%eax
  800f96:	73 2e                	jae    800fc6 <memmove+0x47>
		s += n;
		d += n;
  800f98:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f9b:	89 d6                	mov    %edx,%esi
  800f9d:	09 fe                	or     %edi,%esi
  800f9f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fa5:	75 13                	jne    800fba <memmove+0x3b>
  800fa7:	f6 c1 03             	test   $0x3,%cl
  800faa:	75 0e                	jne    800fba <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fac:	83 ef 04             	sub    $0x4,%edi
  800faf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fb2:	c1 e9 02             	shr    $0x2,%ecx
  800fb5:	fd                   	std    
  800fb6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fb8:	eb 09                	jmp    800fc3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fba:	83 ef 01             	sub    $0x1,%edi
  800fbd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fc0:	fd                   	std    
  800fc1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fc3:	fc                   	cld    
  800fc4:	eb 1d                	jmp    800fe3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fc6:	89 f2                	mov    %esi,%edx
  800fc8:	09 c2                	or     %eax,%edx
  800fca:	f6 c2 03             	test   $0x3,%dl
  800fcd:	75 0f                	jne    800fde <memmove+0x5f>
  800fcf:	f6 c1 03             	test   $0x3,%cl
  800fd2:	75 0a                	jne    800fde <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fd4:	c1 e9 02             	shr    $0x2,%ecx
  800fd7:	89 c7                	mov    %eax,%edi
  800fd9:	fc                   	cld    
  800fda:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fdc:	eb 05                	jmp    800fe3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fde:	89 c7                	mov    %eax,%edi
  800fe0:	fc                   	cld    
  800fe1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fea:	ff 75 10             	pushl  0x10(%ebp)
  800fed:	ff 75 0c             	pushl  0xc(%ebp)
  800ff0:	ff 75 08             	pushl  0x8(%ebp)
  800ff3:	e8 87 ff ff ff       	call   800f7f <memmove>
}
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	57                   	push   %edi
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801003:	8b 75 0c             	mov    0xc(%ebp),%esi
  801006:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801009:	85 c0                	test   %eax,%eax
  80100b:	74 39                	je     801046 <memcmp+0x4c>
  80100d:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801010:	0f b6 13             	movzbl (%ebx),%edx
  801013:	0f b6 0e             	movzbl (%esi),%ecx
  801016:	38 ca                	cmp    %cl,%dl
  801018:	75 17                	jne    801031 <memcmp+0x37>
  80101a:	b8 00 00 00 00       	mov    $0x0,%eax
  80101f:	eb 1a                	jmp    80103b <memcmp+0x41>
  801021:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  801026:	83 c0 01             	add    $0x1,%eax
  801029:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  80102d:	38 ca                	cmp    %cl,%dl
  80102f:	74 0a                	je     80103b <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801031:	0f b6 c2             	movzbl %dl,%eax
  801034:	0f b6 c9             	movzbl %cl,%ecx
  801037:	29 c8                	sub    %ecx,%eax
  801039:	eb 10                	jmp    80104b <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80103b:	39 f8                	cmp    %edi,%eax
  80103d:	75 e2                	jne    801021 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80103f:	b8 00 00 00 00       	mov    $0x0,%eax
  801044:	eb 05                	jmp    80104b <memcmp+0x51>
  801046:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	53                   	push   %ebx
  801054:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801057:	89 d0                	mov    %edx,%eax
  801059:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80105c:	39 c2                	cmp    %eax,%edx
  80105e:	73 1d                	jae    80107d <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  801060:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801064:	0f b6 0a             	movzbl (%edx),%ecx
  801067:	39 d9                	cmp    %ebx,%ecx
  801069:	75 09                	jne    801074 <memfind+0x24>
  80106b:	eb 14                	jmp    801081 <memfind+0x31>
  80106d:	0f b6 0a             	movzbl (%edx),%ecx
  801070:	39 d9                	cmp    %ebx,%ecx
  801072:	74 11                	je     801085 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801074:	83 c2 01             	add    $0x1,%edx
  801077:	39 d0                	cmp    %edx,%eax
  801079:	75 f2                	jne    80106d <memfind+0x1d>
  80107b:	eb 0a                	jmp    801087 <memfind+0x37>
  80107d:	89 d0                	mov    %edx,%eax
  80107f:	eb 06                	jmp    801087 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801081:	89 d0                	mov    %edx,%eax
  801083:	eb 02                	jmp    801087 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801085:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801087:	5b                   	pop    %ebx
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	57                   	push   %edi
  80108e:	56                   	push   %esi
  80108f:	53                   	push   %ebx
  801090:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801093:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801096:	0f b6 01             	movzbl (%ecx),%eax
  801099:	3c 20                	cmp    $0x20,%al
  80109b:	74 04                	je     8010a1 <strtol+0x17>
  80109d:	3c 09                	cmp    $0x9,%al
  80109f:	75 0e                	jne    8010af <strtol+0x25>
		s++;
  8010a1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010a4:	0f b6 01             	movzbl (%ecx),%eax
  8010a7:	3c 20                	cmp    $0x20,%al
  8010a9:	74 f6                	je     8010a1 <strtol+0x17>
  8010ab:	3c 09                	cmp    $0x9,%al
  8010ad:	74 f2                	je     8010a1 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010af:	3c 2b                	cmp    $0x2b,%al
  8010b1:	75 0a                	jne    8010bd <strtol+0x33>
		s++;
  8010b3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010b6:	bf 00 00 00 00       	mov    $0x0,%edi
  8010bb:	eb 11                	jmp    8010ce <strtol+0x44>
  8010bd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010c2:	3c 2d                	cmp    $0x2d,%al
  8010c4:	75 08                	jne    8010ce <strtol+0x44>
		s++, neg = 1;
  8010c6:	83 c1 01             	add    $0x1,%ecx
  8010c9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ce:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010d4:	75 15                	jne    8010eb <strtol+0x61>
  8010d6:	80 39 30             	cmpb   $0x30,(%ecx)
  8010d9:	75 10                	jne    8010eb <strtol+0x61>
  8010db:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010df:	75 7c                	jne    80115d <strtol+0xd3>
		s += 2, base = 16;
  8010e1:	83 c1 02             	add    $0x2,%ecx
  8010e4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010e9:	eb 16                	jmp    801101 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010eb:	85 db                	test   %ebx,%ebx
  8010ed:	75 12                	jne    801101 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010ef:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010f4:	80 39 30             	cmpb   $0x30,(%ecx)
  8010f7:	75 08                	jne    801101 <strtol+0x77>
		s++, base = 8;
  8010f9:	83 c1 01             	add    $0x1,%ecx
  8010fc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801101:	b8 00 00 00 00       	mov    $0x0,%eax
  801106:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801109:	0f b6 11             	movzbl (%ecx),%edx
  80110c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80110f:	89 f3                	mov    %esi,%ebx
  801111:	80 fb 09             	cmp    $0x9,%bl
  801114:	77 08                	ja     80111e <strtol+0x94>
			dig = *s - '0';
  801116:	0f be d2             	movsbl %dl,%edx
  801119:	83 ea 30             	sub    $0x30,%edx
  80111c:	eb 22                	jmp    801140 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  80111e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801121:	89 f3                	mov    %esi,%ebx
  801123:	80 fb 19             	cmp    $0x19,%bl
  801126:	77 08                	ja     801130 <strtol+0xa6>
			dig = *s - 'a' + 10;
  801128:	0f be d2             	movsbl %dl,%edx
  80112b:	83 ea 57             	sub    $0x57,%edx
  80112e:	eb 10                	jmp    801140 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  801130:	8d 72 bf             	lea    -0x41(%edx),%esi
  801133:	89 f3                	mov    %esi,%ebx
  801135:	80 fb 19             	cmp    $0x19,%bl
  801138:	77 16                	ja     801150 <strtol+0xc6>
			dig = *s - 'A' + 10;
  80113a:	0f be d2             	movsbl %dl,%edx
  80113d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801140:	3b 55 10             	cmp    0x10(%ebp),%edx
  801143:	7d 0b                	jge    801150 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801145:	83 c1 01             	add    $0x1,%ecx
  801148:	0f af 45 10          	imul   0x10(%ebp),%eax
  80114c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80114e:	eb b9                	jmp    801109 <strtol+0x7f>

	if (endptr)
  801150:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801154:	74 0d                	je     801163 <strtol+0xd9>
		*endptr = (char *) s;
  801156:	8b 75 0c             	mov    0xc(%ebp),%esi
  801159:	89 0e                	mov    %ecx,(%esi)
  80115b:	eb 06                	jmp    801163 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80115d:	85 db                	test   %ebx,%ebx
  80115f:	74 98                	je     8010f9 <strtol+0x6f>
  801161:	eb 9e                	jmp    801101 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801163:	89 c2                	mov    %eax,%edx
  801165:	f7 da                	neg    %edx
  801167:	85 ff                	test   %edi,%edi
  801169:	0f 45 c2             	cmovne %edx,%eax
}
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801177:	83 3d 14 20 80 00 00 	cmpl   $0x0,0x802014
  80117e:	75 14                	jne    801194 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	68 64 17 80 00       	push   $0x801764
  801188:	6a 20                	push   $0x20
  80118a:	68 88 17 80 00       	push   $0x801788
  80118f:	e8 d3 f2 ff ff       	call   800467 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
  801197:	a3 14 20 80 00       	mov    %eax,0x802014
}
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    
  80119e:	66 90                	xchg   %ax,%ax

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 1c             	sub    $0x1c,%esp
  8011a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8011ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011b7:	85 f6                	test   %esi,%esi
  8011b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011bd:	89 ca                	mov    %ecx,%edx
  8011bf:	89 f8                	mov    %edi,%eax
  8011c1:	75 3d                	jne    801200 <__udivdi3+0x60>
  8011c3:	39 cf                	cmp    %ecx,%edi
  8011c5:	0f 87 c5 00 00 00    	ja     801290 <__udivdi3+0xf0>
  8011cb:	85 ff                	test   %edi,%edi
  8011cd:	89 fd                	mov    %edi,%ebp
  8011cf:	75 0b                	jne    8011dc <__udivdi3+0x3c>
  8011d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d6:	31 d2                	xor    %edx,%edx
  8011d8:	f7 f7                	div    %edi
  8011da:	89 c5                	mov    %eax,%ebp
  8011dc:	89 c8                	mov    %ecx,%eax
  8011de:	31 d2                	xor    %edx,%edx
  8011e0:	f7 f5                	div    %ebp
  8011e2:	89 c1                	mov    %eax,%ecx
  8011e4:	89 d8                	mov    %ebx,%eax
  8011e6:	89 cf                	mov    %ecx,%edi
  8011e8:	f7 f5                	div    %ebp
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	89 d8                	mov    %ebx,%eax
  8011ee:	89 fa                	mov    %edi,%edx
  8011f0:	83 c4 1c             	add    $0x1c,%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    
  8011f8:	90                   	nop
  8011f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801200:	39 ce                	cmp    %ecx,%esi
  801202:	77 74                	ja     801278 <__udivdi3+0xd8>
  801204:	0f bd fe             	bsr    %esi,%edi
  801207:	83 f7 1f             	xor    $0x1f,%edi
  80120a:	0f 84 98 00 00 00    	je     8012a8 <__udivdi3+0x108>
  801210:	bb 20 00 00 00       	mov    $0x20,%ebx
  801215:	89 f9                	mov    %edi,%ecx
  801217:	89 c5                	mov    %eax,%ebp
  801219:	29 fb                	sub    %edi,%ebx
  80121b:	d3 e6                	shl    %cl,%esi
  80121d:	89 d9                	mov    %ebx,%ecx
  80121f:	d3 ed                	shr    %cl,%ebp
  801221:	89 f9                	mov    %edi,%ecx
  801223:	d3 e0                	shl    %cl,%eax
  801225:	09 ee                	or     %ebp,%esi
  801227:	89 d9                	mov    %ebx,%ecx
  801229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122d:	89 d5                	mov    %edx,%ebp
  80122f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801233:	d3 ed                	shr    %cl,%ebp
  801235:	89 f9                	mov    %edi,%ecx
  801237:	d3 e2                	shl    %cl,%edx
  801239:	89 d9                	mov    %ebx,%ecx
  80123b:	d3 e8                	shr    %cl,%eax
  80123d:	09 c2                	or     %eax,%edx
  80123f:	89 d0                	mov    %edx,%eax
  801241:	89 ea                	mov    %ebp,%edx
  801243:	f7 f6                	div    %esi
  801245:	89 d5                	mov    %edx,%ebp
  801247:	89 c3                	mov    %eax,%ebx
  801249:	f7 64 24 0c          	mull   0xc(%esp)
  80124d:	39 d5                	cmp    %edx,%ebp
  80124f:	72 10                	jb     801261 <__udivdi3+0xc1>
  801251:	8b 74 24 08          	mov    0x8(%esp),%esi
  801255:	89 f9                	mov    %edi,%ecx
  801257:	d3 e6                	shl    %cl,%esi
  801259:	39 c6                	cmp    %eax,%esi
  80125b:	73 07                	jae    801264 <__udivdi3+0xc4>
  80125d:	39 d5                	cmp    %edx,%ebp
  80125f:	75 03                	jne    801264 <__udivdi3+0xc4>
  801261:	83 eb 01             	sub    $0x1,%ebx
  801264:	31 ff                	xor    %edi,%edi
  801266:	89 d8                	mov    %ebx,%eax
  801268:	89 fa                	mov    %edi,%edx
  80126a:	83 c4 1c             	add    $0x1c,%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    
  801272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801278:	31 ff                	xor    %edi,%edi
  80127a:	31 db                	xor    %ebx,%ebx
  80127c:	89 d8                	mov    %ebx,%eax
  80127e:	89 fa                	mov    %edi,%edx
  801280:	83 c4 1c             	add    $0x1c,%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    
  801288:	90                   	nop
  801289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801290:	89 d8                	mov    %ebx,%eax
  801292:	f7 f7                	div    %edi
  801294:	31 ff                	xor    %edi,%edi
  801296:	89 c3                	mov    %eax,%ebx
  801298:	89 d8                	mov    %ebx,%eax
  80129a:	89 fa                	mov    %edi,%edx
  80129c:	83 c4 1c             	add    $0x1c,%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5e                   	pop    %esi
  8012a1:	5f                   	pop    %edi
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	39 ce                	cmp    %ecx,%esi
  8012aa:	72 0c                	jb     8012b8 <__udivdi3+0x118>
  8012ac:	31 db                	xor    %ebx,%ebx
  8012ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012b2:	0f 87 34 ff ff ff    	ja     8011ec <__udivdi3+0x4c>
  8012b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012bd:	e9 2a ff ff ff       	jmp    8011ec <__udivdi3+0x4c>
  8012c2:	66 90                	xchg   %ax,%ax
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 1c             	sub    $0x1c,%esp
  8012d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012e7:	85 d2                	test   %edx,%edx
  8012e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f1:	89 f3                	mov    %esi,%ebx
  8012f3:	89 3c 24             	mov    %edi,(%esp)
  8012f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fa:	75 1c                	jne    801318 <__umoddi3+0x48>
  8012fc:	39 f7                	cmp    %esi,%edi
  8012fe:	76 50                	jbe    801350 <__umoddi3+0x80>
  801300:	89 c8                	mov    %ecx,%eax
  801302:	89 f2                	mov    %esi,%edx
  801304:	f7 f7                	div    %edi
  801306:	89 d0                	mov    %edx,%eax
  801308:	31 d2                	xor    %edx,%edx
  80130a:	83 c4 1c             	add    $0x1c,%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    
  801312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801318:	39 f2                	cmp    %esi,%edx
  80131a:	89 d0                	mov    %edx,%eax
  80131c:	77 52                	ja     801370 <__umoddi3+0xa0>
  80131e:	0f bd ea             	bsr    %edx,%ebp
  801321:	83 f5 1f             	xor    $0x1f,%ebp
  801324:	75 5a                	jne    801380 <__umoddi3+0xb0>
  801326:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80132a:	0f 82 e0 00 00 00    	jb     801410 <__umoddi3+0x140>
  801330:	39 0c 24             	cmp    %ecx,(%esp)
  801333:	0f 86 d7 00 00 00    	jbe    801410 <__umoddi3+0x140>
  801339:	8b 44 24 08          	mov    0x8(%esp),%eax
  80133d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801341:	83 c4 1c             	add    $0x1c,%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    
  801349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801350:	85 ff                	test   %edi,%edi
  801352:	89 fd                	mov    %edi,%ebp
  801354:	75 0b                	jne    801361 <__umoddi3+0x91>
  801356:	b8 01 00 00 00       	mov    $0x1,%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	f7 f7                	div    %edi
  80135f:	89 c5                	mov    %eax,%ebp
  801361:	89 f0                	mov    %esi,%eax
  801363:	31 d2                	xor    %edx,%edx
  801365:	f7 f5                	div    %ebp
  801367:	89 c8                	mov    %ecx,%eax
  801369:	f7 f5                	div    %ebp
  80136b:	89 d0                	mov    %edx,%eax
  80136d:	eb 99                	jmp    801308 <__umoddi3+0x38>
  80136f:	90                   	nop
  801370:	89 c8                	mov    %ecx,%eax
  801372:	89 f2                	mov    %esi,%edx
  801374:	83 c4 1c             	add    $0x1c,%esp
  801377:	5b                   	pop    %ebx
  801378:	5e                   	pop    %esi
  801379:	5f                   	pop    %edi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	8b 34 24             	mov    (%esp),%esi
  801383:	bf 20 00 00 00       	mov    $0x20,%edi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	29 ef                	sub    %ebp,%edi
  80138c:	d3 e0                	shl    %cl,%eax
  80138e:	89 f9                	mov    %edi,%ecx
  801390:	89 f2                	mov    %esi,%edx
  801392:	d3 ea                	shr    %cl,%edx
  801394:	89 e9                	mov    %ebp,%ecx
  801396:	09 c2                	or     %eax,%edx
  801398:	89 d8                	mov    %ebx,%eax
  80139a:	89 14 24             	mov    %edx,(%esp)
  80139d:	89 f2                	mov    %esi,%edx
  80139f:	d3 e2                	shl    %cl,%edx
  8013a1:	89 f9                	mov    %edi,%ecx
  8013a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013ab:	d3 e8                	shr    %cl,%eax
  8013ad:	89 e9                	mov    %ebp,%ecx
  8013af:	89 c6                	mov    %eax,%esi
  8013b1:	d3 e3                	shl    %cl,%ebx
  8013b3:	89 f9                	mov    %edi,%ecx
  8013b5:	89 d0                	mov    %edx,%eax
  8013b7:	d3 e8                	shr    %cl,%eax
  8013b9:	89 e9                	mov    %ebp,%ecx
  8013bb:	09 d8                	or     %ebx,%eax
  8013bd:	89 d3                	mov    %edx,%ebx
  8013bf:	89 f2                	mov    %esi,%edx
  8013c1:	f7 34 24             	divl   (%esp)
  8013c4:	89 d6                	mov    %edx,%esi
  8013c6:	d3 e3                	shl    %cl,%ebx
  8013c8:	f7 64 24 04          	mull   0x4(%esp)
  8013cc:	39 d6                	cmp    %edx,%esi
  8013ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d2:	89 d1                	mov    %edx,%ecx
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	72 08                	jb     8013e0 <__umoddi3+0x110>
  8013d8:	75 11                	jne    8013eb <__umoddi3+0x11b>
  8013da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013de:	73 0b                	jae    8013eb <__umoddi3+0x11b>
  8013e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013e4:	1b 14 24             	sbb    (%esp),%edx
  8013e7:	89 d1                	mov    %edx,%ecx
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013ef:	29 da                	sub    %ebx,%edx
  8013f1:	19 ce                	sbb    %ecx,%esi
  8013f3:	89 f9                	mov    %edi,%ecx
  8013f5:	89 f0                	mov    %esi,%eax
  8013f7:	d3 e0                	shl    %cl,%eax
  8013f9:	89 e9                	mov    %ebp,%ecx
  8013fb:	d3 ea                	shr    %cl,%edx
  8013fd:	89 e9                	mov    %ebp,%ecx
  8013ff:	d3 ee                	shr    %cl,%esi
  801401:	09 d0                	or     %edx,%eax
  801403:	89 f2                	mov    %esi,%edx
  801405:	83 c4 1c             	add    $0x1c,%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5f                   	pop    %edi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    
  80140d:	8d 76 00             	lea    0x0(%esi),%esi
  801410:	29 f9                	sub    %edi,%ecx
  801412:	19 d6                	sbb    %edx,%esi
  801414:	89 74 24 04          	mov    %esi,0x4(%esp)
  801418:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80141c:	e9 18 ff ff ff       	jmp    801339 <__umoddi3+0x69>
