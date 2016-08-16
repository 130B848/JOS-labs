
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
  800053:	c1 e0 07             	shl    $0x7,%eax
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
  80012f:	68 ca 13 80 00       	push   $0x8013ca
  800134:	6a 2a                	push   $0x2a
  800136:	68 e7 13 80 00       	push   $0x8013e7
  80013b:	e8 e5 02 00 00       	call   800425 <_panic>

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

008001ab <sys_yield>:

void
sys_yield(void)
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
  8001b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ba:	89 d1                	mov    %edx,%ecx
  8001bc:	89 d3                	mov    %edx,%ebx
  8001be:	89 d7                	mov    %edx,%edi
  8001c0:	51                   	push   %ecx
  8001c1:	52                   	push   %edx
  8001c2:	53                   	push   %ebx
  8001c3:	54                   	push   %esp
  8001c4:	55                   	push   %ebp
  8001c5:	56                   	push   %esi
  8001c6:	57                   	push   %edi
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	8d 35 d1 01 80 00    	lea    0x8001d1,%esi
  8001cf:	0f 34                	sysenter 

008001d1 <label_209>:
  8001d1:	5f                   	pop    %edi
  8001d2:	5e                   	pop    %esi
  8001d3:	5d                   	pop    %ebp
  8001d4:	5c                   	pop    %esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5a                   	pop    %edx
  8001d7:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001d8:	5b                   	pop    %ebx
  8001d9:	5f                   	pop    %edi
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8001e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f4:	51                   	push   %ecx
  8001f5:	52                   	push   %edx
  8001f6:	53                   	push   %ebx
  8001f7:	54                   	push   %esp
  8001f8:	55                   	push   %ebp
  8001f9:	56                   	push   %esi
  8001fa:	57                   	push   %edi
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	8d 35 05 02 80 00    	lea    0x800205,%esi
  800203:	0f 34                	sysenter 

00800205 <label_244>:
  800205:	5f                   	pop    %edi
  800206:	5e                   	pop    %esi
  800207:	5d                   	pop    %ebp
  800208:	5c                   	pop    %esp
  800209:	5b                   	pop    %ebx
  80020a:	5a                   	pop    %edx
  80020b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 05                	push   $0x5
  800216:	68 ca 13 80 00       	push   $0x8013ca
  80021b:	6a 2a                	push   $0x2a
  80021d:	68 e7 13 80 00       	push   $0x8013e7
  800222:	e8 fe 01 00 00       	call   800425 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800227:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800233:	b8 06 00 00 00       	mov    $0x6,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800241:	8b 7d 14             	mov    0x14(%ebp),%edi
  800244:	51                   	push   %ecx
  800245:	52                   	push   %edx
  800246:	53                   	push   %ebx
  800247:	54                   	push   %esp
  800248:	55                   	push   %ebp
  800249:	56                   	push   %esi
  80024a:	57                   	push   %edi
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	8d 35 55 02 80 00    	lea    0x800255,%esi
  800253:	0f 34                	sysenter 

00800255 <label_295>:
  800255:	5f                   	pop    %edi
  800256:	5e                   	pop    %esi
  800257:	5d                   	pop    %ebp
  800258:	5c                   	pop    %esp
  800259:	5b                   	pop    %ebx
  80025a:	5a                   	pop    %edx
  80025b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80025c:	85 c0                	test   %eax,%eax
  80025e:	7e 17                	jle    800277 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800260:	83 ec 0c             	sub    $0xc,%esp
  800263:	50                   	push   %eax
  800264:	6a 06                	push   $0x6
  800266:	68 ca 13 80 00       	push   $0x8013ca
  80026b:	6a 2a                	push   $0x2a
  80026d:	68 e7 13 80 00       	push   $0x8013e7
  800272:	e8 ae 01 00 00       	call   800425 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	57                   	push   %edi
  800282:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800283:	bf 00 00 00 00       	mov    $0x0,%edi
  800288:	b8 07 00 00 00       	mov    $0x7,%eax
  80028d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	89 fb                	mov    %edi,%ebx
  800295:	51                   	push   %ecx
  800296:	52                   	push   %edx
  800297:	53                   	push   %ebx
  800298:	54                   	push   %esp
  800299:	55                   	push   %ebp
  80029a:	56                   	push   %esi
  80029b:	57                   	push   %edi
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	8d 35 a6 02 80 00    	lea    0x8002a6,%esi
  8002a4:	0f 34                	sysenter 

008002a6 <label_344>:
  8002a6:	5f                   	pop    %edi
  8002a7:	5e                   	pop    %esi
  8002a8:	5d                   	pop    %ebp
  8002a9:	5c                   	pop    %esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5a                   	pop    %edx
  8002ac:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002ad:	85 c0                	test   %eax,%eax
  8002af:	7e 17                	jle    8002c8 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	50                   	push   %eax
  8002b5:	6a 07                	push   $0x7
  8002b7:	68 ca 13 80 00       	push   $0x8013ca
  8002bc:	6a 2a                	push   $0x2a
  8002be:	68 e7 13 80 00       	push   $0x8013e7
  8002c3:	e8 5d 01 00 00       	call   800425 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 fb                	mov    %edi,%ebx
  8002e6:	51                   	push   %ecx
  8002e7:	52                   	push   %edx
  8002e8:	53                   	push   %ebx
  8002e9:	54                   	push   %esp
  8002ea:	55                   	push   %ebp
  8002eb:	56                   	push   %esi
  8002ec:	57                   	push   %edi
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	8d 35 f7 02 80 00    	lea    0x8002f7,%esi
  8002f5:	0f 34                	sysenter 

008002f7 <label_393>:
  8002f7:	5f                   	pop    %edi
  8002f8:	5e                   	pop    %esi
  8002f9:	5d                   	pop    %ebp
  8002fa:	5c                   	pop    %esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5a                   	pop    %edx
  8002fd:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002fe:	85 c0                	test   %eax,%eax
  800300:	7e 17                	jle    800319 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	50                   	push   %eax
  800306:	6a 09                	push   $0x9
  800308:	68 ca 13 80 00       	push   $0x8013ca
  80030d:	6a 2a                	push   $0x2a
  80030f:	68 e7 13 80 00       	push   $0x8013e7
  800314:	e8 0c 01 00 00       	call   800425 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800319:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800325:	bf 00 00 00 00       	mov    $0x0,%edi
  80032a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80032f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800332:	8b 55 08             	mov    0x8(%ebp),%edx
  800335:	89 fb                	mov    %edi,%ebx
  800337:	51                   	push   %ecx
  800338:	52                   	push   %edx
  800339:	53                   	push   %ebx
  80033a:	54                   	push   %esp
  80033b:	55                   	push   %ebp
  80033c:	56                   	push   %esi
  80033d:	57                   	push   %edi
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	8d 35 48 03 80 00    	lea    0x800348,%esi
  800346:	0f 34                	sysenter 

00800348 <label_442>:
  800348:	5f                   	pop    %edi
  800349:	5e                   	pop    %esi
  80034a:	5d                   	pop    %ebp
  80034b:	5c                   	pop    %esp
  80034c:	5b                   	pop    %ebx
  80034d:	5a                   	pop    %edx
  80034e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0a                	push   $0xa
  800359:	68 ca 13 80 00       	push   $0x8013ca
  80035e:	6a 2a                	push   $0x2a
  800360:	68 e7 13 80 00       	push   $0x8013e7
  800365:	e8 bb 00 00 00       	call   800425 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80036a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800376:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	51                   	push   %ecx
  800388:	52                   	push   %edx
  800389:	53                   	push   %ebx
  80038a:	54                   	push   %esp
  80038b:	55                   	push   %ebp
  80038c:	56                   	push   %esi
  80038d:	57                   	push   %edi
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8d 35 98 03 80 00    	lea    0x800398,%esi
  800396:	0f 34                	sysenter 

00800398 <label_493>:
  800398:	5f                   	pop    %edi
  800399:	5e                   	pop    %esi
  80039a:	5d                   	pop    %ebp
  80039b:	5c                   	pop    %esp
  80039c:	5b                   	pop    %ebx
  80039d:	5a                   	pop    %edx
  80039e:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80039f:	5b                   	pop    %ebx
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ad:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b5:	89 d9                	mov    %ebx,%ecx
  8003b7:	89 df                	mov    %ebx,%edi
  8003b9:	51                   	push   %ecx
  8003ba:	52                   	push   %edx
  8003bb:	53                   	push   %ebx
  8003bc:	54                   	push   %esp
  8003bd:	55                   	push   %ebp
  8003be:	56                   	push   %esi
  8003bf:	57                   	push   %edi
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8d 35 ca 03 80 00    	lea    0x8003ca,%esi
  8003c8:	0f 34                	sysenter 

008003ca <label_528>:
  8003ca:	5f                   	pop    %edi
  8003cb:	5e                   	pop    %esi
  8003cc:	5d                   	pop    %ebp
  8003cd:	5c                   	pop    %esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5a                   	pop    %edx
  8003d0:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	7e 17                	jle    8003ec <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8003d5:	83 ec 0c             	sub    $0xc,%esp
  8003d8:	50                   	push   %eax
  8003d9:	6a 0d                	push   $0xd
  8003db:	68 ca 13 80 00       	push   $0x8013ca
  8003e0:	6a 2a                	push   $0x2a
  8003e2:	68 e7 13 80 00       	push   $0x8013e7
  8003e7:	e8 39 00 00 00       	call   800425 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003ef:	5b                   	pop    %ebx
  8003f0:	5f                   	pop    %edi
  8003f1:	5d                   	pop    %ebp
  8003f2:	c3                   	ret    

008003f3 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	57                   	push   %edi
  8003f7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800402:	8b 55 08             	mov    0x8(%ebp),%edx
  800405:	89 cb                	mov    %ecx,%ebx
  800407:	89 cf                	mov    %ecx,%edi
  800409:	51                   	push   %ecx
  80040a:	52                   	push   %edx
  80040b:	53                   	push   %ebx
  80040c:	54                   	push   %esp
  80040d:	55                   	push   %ebp
  80040e:	56                   	push   %esi
  80040f:	57                   	push   %edi
  800410:	89 e5                	mov    %esp,%ebp
  800412:	8d 35 1a 04 80 00    	lea    0x80041a,%esi
  800418:	0f 34                	sysenter 

0080041a <label_577>:
  80041a:	5f                   	pop    %edi
  80041b:	5e                   	pop    %esi
  80041c:	5d                   	pop    %ebp
  80041d:	5c                   	pop    %esp
  80041e:	5b                   	pop    %ebx
  80041f:	5a                   	pop    %edx
  800420:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800421:	5b                   	pop    %ebx
  800422:	5f                   	pop    %edi
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80042a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80042d:	a1 10 20 80 00       	mov    0x802010,%eax
  800432:	85 c0                	test   %eax,%eax
  800434:	74 11                	je     800447 <_panic+0x22>
		cprintf("%s: ", argv0);
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	50                   	push   %eax
  80043a:	68 f5 13 80 00       	push   $0x8013f5
  80043f:	e8 d4 00 00 00       	call   800518 <cprintf>
  800444:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800447:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80044d:	e8 f5 fc ff ff       	call   800147 <sys_getenvid>
  800452:	83 ec 0c             	sub    $0xc,%esp
  800455:	ff 75 0c             	pushl  0xc(%ebp)
  800458:	ff 75 08             	pushl  0x8(%ebp)
  80045b:	56                   	push   %esi
  80045c:	50                   	push   %eax
  80045d:	68 fc 13 80 00       	push   $0x8013fc
  800462:	e8 b1 00 00 00       	call   800518 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800467:	83 c4 18             	add    $0x18,%esp
  80046a:	53                   	push   %ebx
  80046b:	ff 75 10             	pushl  0x10(%ebp)
  80046e:	e8 54 00 00 00       	call   8004c7 <vcprintf>
	cprintf("\n");
  800473:	c7 04 24 fa 13 80 00 	movl   $0x8013fa,(%esp)
  80047a:	e8 99 00 00 00       	call   800518 <cprintf>
  80047f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800482:	cc                   	int3   
  800483:	eb fd                	jmp    800482 <_panic+0x5d>

00800485 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	53                   	push   %ebx
  800489:	83 ec 04             	sub    $0x4,%esp
  80048c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80048f:	8b 13                	mov    (%ebx),%edx
  800491:	8d 42 01             	lea    0x1(%edx),%eax
  800494:	89 03                	mov    %eax,(%ebx)
  800496:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800499:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80049d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a2:	75 1a                	jne    8004be <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	68 ff 00 00 00       	push   $0xff
  8004ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8004af:	50                   	push   %eax
  8004b0:	e8 e1 fb ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  8004b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004bb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c5:	c9                   	leave  
  8004c6:	c3                   	ret    

008004c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004d7:	00 00 00 
	b.cnt = 0;
  8004da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	ff 75 08             	pushl  0x8(%ebp)
  8004ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	68 85 04 80 00       	push   $0x800485
  8004f6:	e8 c0 02 00 00       	call   8007bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004fb:	83 c4 08             	add    $0x8,%esp
  8004fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800504:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80050a:	50                   	push   %eax
  80050b:	e8 86 fb ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  800510:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80051e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800521:	50                   	push   %eax
  800522:	ff 75 08             	pushl  0x8(%ebp)
  800525:	e8 9d ff ff ff       	call   8004c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	57                   	push   %edi
  800530:	56                   	push   %esi
  800531:	53                   	push   %ebx
  800532:	83 ec 1c             	sub    $0x1c,%esp
  800535:	89 c7                	mov    %eax,%edi
  800537:	89 d6                	mov    %edx,%esi
  800539:	8b 45 08             	mov    0x8(%ebp),%eax
  80053c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800542:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800545:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800548:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80054c:	0f 85 bf 00 00 00    	jne    800611 <printnum+0xe5>
  800552:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800558:	0f 8d de 00 00 00    	jge    80063c <printnum+0x110>
		judge_time_for_space = width;
  80055e:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800564:	e9 d3 00 00 00       	jmp    80063c <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800569:	83 eb 01             	sub    $0x1,%ebx
  80056c:	85 db                	test   %ebx,%ebx
  80056e:	7f 37                	jg     8005a7 <printnum+0x7b>
  800570:	e9 ea 00 00 00       	jmp    80065f <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800575:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800578:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	56                   	push   %esi
  800581:	83 ec 04             	sub    $0x4,%esp
  800584:	ff 75 dc             	pushl  -0x24(%ebp)
  800587:	ff 75 d8             	pushl  -0x28(%ebp)
  80058a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80058d:	ff 75 e0             	pushl  -0x20(%ebp)
  800590:	e8 cb 0c 00 00       	call   801260 <__umoddi3>
  800595:	83 c4 14             	add    $0x14,%esp
  800598:	0f be 80 1f 14 80 00 	movsbl 0x80141f(%eax),%eax
  80059f:	50                   	push   %eax
  8005a0:	ff d7                	call   *%edi
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb 16                	jmp    8005bd <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	56                   	push   %esi
  8005ab:	ff 75 18             	pushl  0x18(%ebp)
  8005ae:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	83 eb 01             	sub    $0x1,%ebx
  8005b6:	75 ef                	jne    8005a7 <printnum+0x7b>
  8005b8:	e9 a2 00 00 00       	jmp    80065f <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005bd:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005c3:	0f 85 76 01 00 00    	jne    80073f <printnum+0x213>
		while(num_of_space-- > 0)
  8005c9:	a1 04 20 80 00       	mov    0x802004,%eax
  8005ce:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005d1:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	7e 1d                	jle    8005f8 <printnum+0xcc>
			putch(' ', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	56                   	push   %esi
  8005df:	6a 20                	push   $0x20
  8005e1:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8005e3:	a1 04 20 80 00       	mov    0x802004,%eax
  8005e8:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005eb:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	85 c0                	test   %eax,%eax
  8005f6:	7f e3                	jg     8005db <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8005f8:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8005ff:	00 00 00 
		judge_time_for_space = 0;
  800602:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800609:	00 00 00 
	}
}
  80060c:	e9 2e 01 00 00       	jmp    80073f <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800611:	8b 45 10             	mov    0x10(%ebp),%eax
  800614:	ba 00 00 00 00       	mov    $0x0,%edx
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800622:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800625:	83 fa 00             	cmp    $0x0,%edx
  800628:	0f 87 ba 00 00 00    	ja     8006e8 <printnum+0x1bc>
  80062e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800631:	0f 83 b1 00 00 00    	jae    8006e8 <printnum+0x1bc>
  800637:	e9 2d ff ff ff       	jmp    800569 <printnum+0x3d>
  80063c:	8b 45 10             	mov    0x10(%ebp),%eax
  80063f:	ba 00 00 00 00       	mov    $0x0,%edx
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800650:	83 fa 00             	cmp    $0x0,%edx
  800653:	77 37                	ja     80068c <printnum+0x160>
  800655:	3b 45 10             	cmp    0x10(%ebp),%eax
  800658:	73 32                	jae    80068c <printnum+0x160>
  80065a:	e9 16 ff ff ff       	jmp    800575 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	56                   	push   %esi
  800663:	83 ec 04             	sub    $0x4,%esp
  800666:	ff 75 dc             	pushl  -0x24(%ebp)
  800669:	ff 75 d8             	pushl  -0x28(%ebp)
  80066c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80066f:	ff 75 e0             	pushl  -0x20(%ebp)
  800672:	e8 e9 0b 00 00       	call   801260 <__umoddi3>
  800677:	83 c4 14             	add    $0x14,%esp
  80067a:	0f be 80 1f 14 80 00 	movsbl 0x80141f(%eax),%eax
  800681:	50                   	push   %eax
  800682:	ff d7                	call   *%edi
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	e9 b3 00 00 00       	jmp    80073f <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80068c:	83 ec 0c             	sub    $0xc,%esp
  80068f:	ff 75 18             	pushl  0x18(%ebp)
  800692:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800695:	50                   	push   %eax
  800696:	ff 75 10             	pushl  0x10(%ebp)
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	ff 75 dc             	pushl  -0x24(%ebp)
  80069f:	ff 75 d8             	pushl  -0x28(%ebp)
  8006a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a8:	e8 83 0a 00 00       	call   801130 <__udivdi3>
  8006ad:	83 c4 18             	add    $0x18,%esp
  8006b0:	52                   	push   %edx
  8006b1:	50                   	push   %eax
  8006b2:	89 f2                	mov    %esi,%edx
  8006b4:	89 f8                	mov    %edi,%eax
  8006b6:	e8 71 fe ff ff       	call   80052c <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006bb:	83 c4 18             	add    $0x18,%esp
  8006be:	56                   	push   %esi
  8006bf:	83 ec 04             	sub    $0x4,%esp
  8006c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ce:	e8 8d 0b 00 00       	call   801260 <__umoddi3>
  8006d3:	83 c4 14             	add    $0x14,%esp
  8006d6:	0f be 80 1f 14 80 00 	movsbl 0x80141f(%eax),%eax
  8006dd:	50                   	push   %eax
  8006de:	ff d7                	call   *%edi
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	e9 d5 fe ff ff       	jmp    8005bd <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	ff 75 18             	pushl  0x18(%ebp)
  8006ee:	83 eb 01             	sub    $0x1,%ebx
  8006f1:	53                   	push   %ebx
  8006f2:	ff 75 10             	pushl  0x10(%ebp)
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	ff 75 dc             	pushl  -0x24(%ebp)
  8006fb:	ff 75 d8             	pushl  -0x28(%ebp)
  8006fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800701:	ff 75 e0             	pushl  -0x20(%ebp)
  800704:	e8 27 0a 00 00       	call   801130 <__udivdi3>
  800709:	83 c4 18             	add    $0x18,%esp
  80070c:	52                   	push   %edx
  80070d:	50                   	push   %eax
  80070e:	89 f2                	mov    %esi,%edx
  800710:	89 f8                	mov    %edi,%eax
  800712:	e8 15 fe ff ff       	call   80052c <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800717:	83 c4 18             	add    $0x18,%esp
  80071a:	56                   	push   %esi
  80071b:	83 ec 04             	sub    $0x4,%esp
  80071e:	ff 75 dc             	pushl  -0x24(%ebp)
  800721:	ff 75 d8             	pushl  -0x28(%ebp)
  800724:	ff 75 e4             	pushl  -0x1c(%ebp)
  800727:	ff 75 e0             	pushl  -0x20(%ebp)
  80072a:	e8 31 0b 00 00       	call   801260 <__umoddi3>
  80072f:	83 c4 14             	add    $0x14,%esp
  800732:	0f be 80 1f 14 80 00 	movsbl 0x80141f(%eax),%eax
  800739:	50                   	push   %eax
  80073a:	ff d7                	call   *%edi
  80073c:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80074a:	83 fa 01             	cmp    $0x1,%edx
  80074d:	7e 0e                	jle    80075d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80074f:	8b 10                	mov    (%eax),%edx
  800751:	8d 4a 08             	lea    0x8(%edx),%ecx
  800754:	89 08                	mov    %ecx,(%eax)
  800756:	8b 02                	mov    (%edx),%eax
  800758:	8b 52 04             	mov    0x4(%edx),%edx
  80075b:	eb 22                	jmp    80077f <getuint+0x38>
	else if (lflag)
  80075d:	85 d2                	test   %edx,%edx
  80075f:	74 10                	je     800771 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800761:	8b 10                	mov    (%eax),%edx
  800763:	8d 4a 04             	lea    0x4(%edx),%ecx
  800766:	89 08                	mov    %ecx,(%eax)
  800768:	8b 02                	mov    (%edx),%eax
  80076a:	ba 00 00 00 00       	mov    $0x0,%edx
  80076f:	eb 0e                	jmp    80077f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800771:	8b 10                	mov    (%eax),%edx
  800773:	8d 4a 04             	lea    0x4(%edx),%ecx
  800776:	89 08                	mov    %ecx,(%eax)
  800778:	8b 02                	mov    (%edx),%eax
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800787:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	3b 50 04             	cmp    0x4(%eax),%edx
  800790:	73 0a                	jae    80079c <sprintputch+0x1b>
		*b->buf++ = ch;
  800792:	8d 4a 01             	lea    0x1(%edx),%ecx
  800795:	89 08                	mov    %ecx,(%eax)
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	88 02                	mov    %al,(%edx)
}
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 10             	pushl  0x10(%ebp)
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	ff 75 08             	pushl  0x8(%ebp)
  8007b1:	e8 05 00 00 00       	call   8007bb <vprintfmt>
	va_end(ap);
}
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	57                   	push   %edi
  8007bf:	56                   	push   %esi
  8007c0:	53                   	push   %ebx
  8007c1:	83 ec 2c             	sub    $0x2c,%esp
  8007c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ca:	eb 03                	jmp    8007cf <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cc:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d2:	8d 70 01             	lea    0x1(%eax),%esi
  8007d5:	0f b6 00             	movzbl (%eax),%eax
  8007d8:	83 f8 25             	cmp    $0x25,%eax
  8007db:	74 27                	je     800804 <vprintfmt+0x49>
			if (ch == '\0')
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	75 0d                	jne    8007ee <vprintfmt+0x33>
  8007e1:	e9 9d 04 00 00       	jmp    800c83 <vprintfmt+0x4c8>
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	0f 84 95 04 00 00    	je     800c83 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	50                   	push   %eax
  8007f3:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f5:	83 c6 01             	add    $0x1,%esi
  8007f8:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	83 f8 25             	cmp    $0x25,%eax
  800802:	75 e2                	jne    8007e6 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
  800809:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80080d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800814:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80081b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800822:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800829:	eb 08                	jmp    800833 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082b:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80082e:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800833:	8d 46 01             	lea    0x1(%esi),%eax
  800836:	89 45 10             	mov    %eax,0x10(%ebp)
  800839:	0f b6 06             	movzbl (%esi),%eax
  80083c:	0f b6 d0             	movzbl %al,%edx
  80083f:	83 e8 23             	sub    $0x23,%eax
  800842:	3c 55                	cmp    $0x55,%al
  800844:	0f 87 fa 03 00 00    	ja     800c44 <vprintfmt+0x489>
  80084a:	0f b6 c0             	movzbl %al,%eax
  80084d:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
  800854:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800857:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80085b:	eb d6                	jmp    800833 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80085d:	8d 42 d0             	lea    -0x30(%edx),%eax
  800860:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800863:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800867:	8d 50 d0             	lea    -0x30(%eax),%edx
  80086a:	83 fa 09             	cmp    $0x9,%edx
  80086d:	77 6b                	ja     8008da <vprintfmt+0x11f>
  80086f:	8b 75 10             	mov    0x10(%ebp),%esi
  800872:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800875:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800878:	eb 09                	jmp    800883 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087a:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80087d:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800881:	eb b0                	jmp    800833 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800883:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800886:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800889:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80088d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800890:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800893:	83 f9 09             	cmp    $0x9,%ecx
  800896:	76 eb                	jbe    800883 <vprintfmt+0xc8>
  800898:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80089b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80089e:	eb 3d                	jmp    8008dd <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a3:	8d 50 04             	lea    0x4(%eax),%edx
  8008a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a9:	8b 00                	mov    (%eax),%eax
  8008ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b1:	eb 2a                	jmp    8008dd <vprintfmt+0x122>
  8008b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008bd:	0f 49 d0             	cmovns %eax,%edx
  8008c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c3:	8b 75 10             	mov    0x10(%ebp),%esi
  8008c6:	e9 68 ff ff ff       	jmp    800833 <vprintfmt+0x78>
  8008cb:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d5:	e9 59 ff ff ff       	jmp    800833 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008da:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008e1:	0f 89 4c ff ff ff    	jns    800833 <vprintfmt+0x78>
				width = precision, precision = -1;
  8008e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f4:	e9 3a ff ff ff       	jmp    800833 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f9:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fd:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800900:	e9 2e ff ff ff       	jmp    800833 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8d 50 04             	lea    0x4(%eax),%edx
  80090b:	89 55 14             	mov    %edx,0x14(%ebp)
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	53                   	push   %ebx
  800912:	ff 30                	pushl  (%eax)
  800914:	ff d7                	call   *%edi
			break;
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	e9 b1 fe ff ff       	jmp    8007cf <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80091e:	8b 45 14             	mov    0x14(%ebp),%eax
  800921:	8d 50 04             	lea    0x4(%eax),%edx
  800924:	89 55 14             	mov    %edx,0x14(%ebp)
  800927:	8b 00                	mov    (%eax),%eax
  800929:	99                   	cltd   
  80092a:	31 d0                	xor    %edx,%eax
  80092c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092e:	83 f8 08             	cmp    $0x8,%eax
  800931:	7f 0b                	jg     80093e <vprintfmt+0x183>
  800933:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  80093a:	85 d2                	test   %edx,%edx
  80093c:	75 15                	jne    800953 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80093e:	50                   	push   %eax
  80093f:	68 37 14 80 00       	push   $0x801437
  800944:	53                   	push   %ebx
  800945:	57                   	push   %edi
  800946:	e8 53 fe ff ff       	call   80079e <printfmt>
  80094b:	83 c4 10             	add    $0x10,%esp
  80094e:	e9 7c fe ff ff       	jmp    8007cf <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800953:	52                   	push   %edx
  800954:	68 40 14 80 00       	push   $0x801440
  800959:	53                   	push   %ebx
  80095a:	57                   	push   %edi
  80095b:	e8 3e fe ff ff       	call   80079e <printfmt>
  800960:	83 c4 10             	add    $0x10,%esp
  800963:	e9 67 fe ff ff       	jmp    8007cf <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800968:	8b 45 14             	mov    0x14(%ebp),%eax
  80096b:	8d 50 04             	lea    0x4(%eax),%edx
  80096e:	89 55 14             	mov    %edx,0x14(%ebp)
  800971:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800973:	85 c0                	test   %eax,%eax
  800975:	b9 30 14 80 00       	mov    $0x801430,%ecx
  80097a:	0f 45 c8             	cmovne %eax,%ecx
  80097d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800980:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800984:	7e 06                	jle    80098c <vprintfmt+0x1d1>
  800986:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80098a:	75 19                	jne    8009a5 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80098c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80098f:	8d 70 01             	lea    0x1(%eax),%esi
  800992:	0f b6 00             	movzbl (%eax),%eax
  800995:	0f be d0             	movsbl %al,%edx
  800998:	85 d2                	test   %edx,%edx
  80099a:	0f 85 9f 00 00 00    	jne    800a3f <vprintfmt+0x284>
  8009a0:	e9 8c 00 00 00       	jmp    800a31 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	ff 75 d0             	pushl  -0x30(%ebp)
  8009ab:	ff 75 cc             	pushl  -0x34(%ebp)
  8009ae:	e8 62 03 00 00       	call   800d15 <strnlen>
  8009b3:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009b6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009b9:	83 c4 10             	add    $0x10,%esp
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	0f 8e a6 02 00 00    	jle    800c6a <vprintfmt+0x4af>
					putch(padc, putdat);
  8009c4:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009cb:	89 cb                	mov    %ecx,%ebx
  8009cd:	83 ec 08             	sub    $0x8,%esp
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	56                   	push   %esi
  8009d4:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d6:	83 c4 10             	add    $0x10,%esp
  8009d9:	83 eb 01             	sub    $0x1,%ebx
  8009dc:	75 ef                	jne    8009cd <vprintfmt+0x212>
  8009de:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e4:	e9 81 02 00 00       	jmp    800c6a <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009ed:	74 1b                	je     800a0a <vprintfmt+0x24f>
  8009ef:	0f be c0             	movsbl %al,%eax
  8009f2:	83 e8 20             	sub    $0x20,%eax
  8009f5:	83 f8 5e             	cmp    $0x5e,%eax
  8009f8:	76 10                	jbe    800a0a <vprintfmt+0x24f>
					putch('?', putdat);
  8009fa:	83 ec 08             	sub    $0x8,%esp
  8009fd:	ff 75 0c             	pushl  0xc(%ebp)
  800a00:	6a 3f                	push   $0x3f
  800a02:	ff 55 08             	call   *0x8(%ebp)
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	eb 0d                	jmp    800a17 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	52                   	push   %edx
  800a11:	ff 55 08             	call   *0x8(%ebp)
  800a14:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a17:	83 ef 01             	sub    $0x1,%edi
  800a1a:	83 c6 01             	add    $0x1,%esi
  800a1d:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a21:	0f be d0             	movsbl %al,%edx
  800a24:	85 d2                	test   %edx,%edx
  800a26:	75 31                	jne    800a59 <vprintfmt+0x29e>
  800a28:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a31:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a34:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a38:	7f 33                	jg     800a6d <vprintfmt+0x2b2>
  800a3a:	e9 90 fd ff ff       	jmp    8007cf <vprintfmt+0x14>
  800a3f:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a45:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a48:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a4b:	eb 0c                	jmp    800a59 <vprintfmt+0x29e>
  800a4d:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a53:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a56:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	78 8c                	js     8009e9 <vprintfmt+0x22e>
  800a5d:	83 eb 01             	sub    $0x1,%ebx
  800a60:	79 87                	jns    8009e9 <vprintfmt+0x22e>
  800a62:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6b:	eb c4                	jmp    800a31 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	53                   	push   %ebx
  800a71:	6a 20                	push   $0x20
  800a73:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	83 ee 01             	sub    $0x1,%esi
  800a7b:	75 f0                	jne    800a6d <vprintfmt+0x2b2>
  800a7d:	e9 4d fd ff ff       	jmp    8007cf <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a82:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800a86:	7e 16                	jle    800a9e <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800a88:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8b:	8d 50 08             	lea    0x8(%eax),%edx
  800a8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a91:	8b 50 04             	mov    0x4(%eax),%edx
  800a94:	8b 00                	mov    (%eax),%eax
  800a96:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a99:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800a9c:	eb 34                	jmp    800ad2 <vprintfmt+0x317>
	else if (lflag)
  800a9e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800aa2:	74 18                	je     800abc <vprintfmt+0x301>
		return va_arg(*ap, long);
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8d 50 04             	lea    0x4(%eax),%edx
  800aaa:	89 55 14             	mov    %edx,0x14(%ebp)
  800aad:	8b 30                	mov    (%eax),%esi
  800aaf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ab2:	89 f0                	mov    %esi,%eax
  800ab4:	c1 f8 1f             	sar    $0x1f,%eax
  800ab7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800aba:	eb 16                	jmp    800ad2 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800abc:	8b 45 14             	mov    0x14(%ebp),%eax
  800abf:	8d 50 04             	lea    0x4(%eax),%edx
  800ac2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac5:	8b 30                	mov    (%eax),%esi
  800ac7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800aca:	89 f0                	mov    %esi,%eax
  800acc:	c1 f8 1f             	sar    $0x1f,%eax
  800acf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ad5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ad8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800ade:	85 d2                	test   %edx,%edx
  800ae0:	79 28                	jns    800b0a <vprintfmt+0x34f>
				putch('-', putdat);
  800ae2:	83 ec 08             	sub    $0x8,%esp
  800ae5:	53                   	push   %ebx
  800ae6:	6a 2d                	push   $0x2d
  800ae8:	ff d7                	call   *%edi
				num = -(long long) num;
  800aea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800aed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800af0:	f7 d8                	neg    %eax
  800af2:	83 d2 00             	adc    $0x0,%edx
  800af5:	f7 da                	neg    %edx
  800af7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800afa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800afd:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b00:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b05:	e9 b2 00 00 00       	jmp    800bbc <vprintfmt+0x401>
  800b0a:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b0f:	85 c9                	test   %ecx,%ecx
  800b11:	0f 84 a5 00 00 00    	je     800bbc <vprintfmt+0x401>
				putch('+', putdat);
  800b17:	83 ec 08             	sub    $0x8,%esp
  800b1a:	53                   	push   %ebx
  800b1b:	6a 2b                	push   $0x2b
  800b1d:	ff d7                	call   *%edi
  800b1f:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b22:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b27:	e9 90 00 00 00       	jmp    800bbc <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b2c:	85 c9                	test   %ecx,%ecx
  800b2e:	74 0b                	je     800b3b <vprintfmt+0x380>
				putch('+', putdat);
  800b30:	83 ec 08             	sub    $0x8,%esp
  800b33:	53                   	push   %ebx
  800b34:	6a 2b                	push   $0x2b
  800b36:	ff d7                	call   *%edi
  800b38:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b3b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b3e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b41:	e8 01 fc ff ff       	call   800747 <getuint>
  800b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b49:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b4c:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b51:	eb 69                	jmp    800bbc <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b53:	83 ec 08             	sub    $0x8,%esp
  800b56:	53                   	push   %ebx
  800b57:	6a 30                	push   $0x30
  800b59:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b5b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b5e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b61:	e8 e1 fb ff ff       	call   800747 <getuint>
  800b66:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b69:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b6c:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b6f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b74:	eb 46                	jmp    800bbc <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b76:	83 ec 08             	sub    $0x8,%esp
  800b79:	53                   	push   %ebx
  800b7a:	6a 30                	push   $0x30
  800b7c:	ff d7                	call   *%edi
			putch('x', putdat);
  800b7e:	83 c4 08             	add    $0x8,%esp
  800b81:	53                   	push   %ebx
  800b82:	6a 78                	push   $0x78
  800b84:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b86:	8b 45 14             	mov    0x14(%ebp),%eax
  800b89:	8d 50 04             	lea    0x4(%eax),%edx
  800b8c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b8f:	8b 00                	mov    (%eax),%eax
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b99:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b9c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b9f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800ba4:	eb 16                	jmp    800bbc <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ba6:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ba9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bac:	e8 96 fb ff ff       	call   800747 <getuint>
  800bb1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bb4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bb7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bc3:	56                   	push   %esi
  800bc4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc7:	50                   	push   %eax
  800bc8:	ff 75 dc             	pushl  -0x24(%ebp)
  800bcb:	ff 75 d8             	pushl  -0x28(%ebp)
  800bce:	89 da                	mov    %ebx,%edx
  800bd0:	89 f8                	mov    %edi,%eax
  800bd2:	e8 55 f9 ff ff       	call   80052c <printnum>
			break;
  800bd7:	83 c4 20             	add    $0x20,%esp
  800bda:	e9 f0 fb ff ff       	jmp    8007cf <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800bdf:	8b 45 14             	mov    0x14(%ebp),%eax
  800be2:	8d 50 04             	lea    0x4(%eax),%edx
  800be5:	89 55 14             	mov    %edx,0x14(%ebp)
  800be8:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800bea:	85 f6                	test   %esi,%esi
  800bec:	75 1a                	jne    800c08 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800bee:	83 ec 08             	sub    $0x8,%esp
  800bf1:	68 d8 14 80 00       	push   $0x8014d8
  800bf6:	68 40 14 80 00       	push   $0x801440
  800bfb:	e8 18 f9 ff ff       	call   800518 <cprintf>
  800c00:	83 c4 10             	add    $0x10,%esp
  800c03:	e9 c7 fb ff ff       	jmp    8007cf <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c08:	0f b6 03             	movzbl (%ebx),%eax
  800c0b:	84 c0                	test   %al,%al
  800c0d:	79 1f                	jns    800c2e <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c0f:	83 ec 08             	sub    $0x8,%esp
  800c12:	68 10 15 80 00       	push   $0x801510
  800c17:	68 40 14 80 00       	push   $0x801440
  800c1c:	e8 f7 f8 ff ff       	call   800518 <cprintf>
						*tmp = *(char *)putdat;
  800c21:	0f b6 03             	movzbl (%ebx),%eax
  800c24:	88 06                	mov    %al,(%esi)
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	e9 a1 fb ff ff       	jmp    8007cf <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c2e:	88 06                	mov    %al,(%esi)
  800c30:	e9 9a fb ff ff       	jmp    8007cf <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c35:	83 ec 08             	sub    $0x8,%esp
  800c38:	53                   	push   %ebx
  800c39:	52                   	push   %edx
  800c3a:	ff d7                	call   *%edi
			break;
  800c3c:	83 c4 10             	add    $0x10,%esp
  800c3f:	e9 8b fb ff ff       	jmp    8007cf <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c44:	83 ec 08             	sub    $0x8,%esp
  800c47:	53                   	push   %ebx
  800c48:	6a 25                	push   $0x25
  800c4a:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c4c:	83 c4 10             	add    $0x10,%esp
  800c4f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c53:	0f 84 73 fb ff ff    	je     8007cc <vprintfmt+0x11>
  800c59:	83 ee 01             	sub    $0x1,%esi
  800c5c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c60:	75 f7                	jne    800c59 <vprintfmt+0x49e>
  800c62:	89 75 10             	mov    %esi,0x10(%ebp)
  800c65:	e9 65 fb ff ff       	jmp    8007cf <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c6a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c6d:	8d 70 01             	lea    0x1(%eax),%esi
  800c70:	0f b6 00             	movzbl (%eax),%eax
  800c73:	0f be d0             	movsbl %al,%edx
  800c76:	85 d2                	test   %edx,%edx
  800c78:	0f 85 cf fd ff ff    	jne    800a4d <vprintfmt+0x292>
  800c7e:	e9 4c fb ff ff       	jmp    8007cf <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	83 ec 18             	sub    $0x18,%esp
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c97:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c9a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c9e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	74 26                	je     800cd2 <vsnprintf+0x47>
  800cac:	85 d2                	test   %edx,%edx
  800cae:	7e 22                	jle    800cd2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb0:	ff 75 14             	pushl  0x14(%ebp)
  800cb3:	ff 75 10             	pushl  0x10(%ebp)
  800cb6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cb9:	50                   	push   %eax
  800cba:	68 81 07 80 00       	push   $0x800781
  800cbf:	e8 f7 fa ff ff       	call   8007bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccd:	83 c4 10             	add    $0x10,%esp
  800cd0:	eb 05                	jmp    800cd7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cdf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ce2:	50                   	push   %eax
  800ce3:	ff 75 10             	pushl  0x10(%ebp)
  800ce6:	ff 75 0c             	pushl  0xc(%ebp)
  800ce9:	ff 75 08             	pushl  0x8(%ebp)
  800cec:	e8 9a ff ff ff       	call   800c8b <vsnprintf>
	va_end(ap);

	return rc;
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf9:	80 3a 00             	cmpb   $0x0,(%edx)
  800cfc:	74 10                	je     800d0e <strlen+0x1b>
  800cfe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d03:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d06:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d0a:	75 f7                	jne    800d03 <strlen+0x10>
  800d0c:	eb 05                	jmp    800d13 <strlen+0x20>
  800d0e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	53                   	push   %ebx
  800d19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1f:	85 c9                	test   %ecx,%ecx
  800d21:	74 1c                	je     800d3f <strnlen+0x2a>
  800d23:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d26:	74 1e                	je     800d46 <strnlen+0x31>
  800d28:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d2d:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2f:	39 ca                	cmp    %ecx,%edx
  800d31:	74 18                	je     800d4b <strnlen+0x36>
  800d33:	83 c2 01             	add    $0x1,%edx
  800d36:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d3b:	75 f0                	jne    800d2d <strnlen+0x18>
  800d3d:	eb 0c                	jmp    800d4b <strnlen+0x36>
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	eb 05                	jmp    800d4b <strnlen+0x36>
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	53                   	push   %ebx
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d58:	89 c2                	mov    %eax,%edx
  800d5a:	83 c2 01             	add    $0x1,%edx
  800d5d:	83 c1 01             	add    $0x1,%ecx
  800d60:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d64:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d67:	84 db                	test   %bl,%bl
  800d69:	75 ef                	jne    800d5a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	53                   	push   %ebx
  800d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d75:	53                   	push   %ebx
  800d76:	e8 78 ff ff ff       	call   800cf3 <strlen>
  800d7b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d7e:	ff 75 0c             	pushl  0xc(%ebp)
  800d81:	01 d8                	add    %ebx,%eax
  800d83:	50                   	push   %eax
  800d84:	e8 c5 ff ff ff       	call   800d4e <strcpy>
	return dst;
}
  800d89:	89 d8                	mov    %ebx,%eax
  800d8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	8b 75 08             	mov    0x8(%ebp),%esi
  800d98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d9e:	85 db                	test   %ebx,%ebx
  800da0:	74 17                	je     800db9 <strncpy+0x29>
  800da2:	01 f3                	add    %esi,%ebx
  800da4:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800da6:	83 c1 01             	add    $0x1,%ecx
  800da9:	0f b6 02             	movzbl (%edx),%eax
  800dac:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800daf:	80 3a 01             	cmpb   $0x1,(%edx)
  800db2:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db5:	39 cb                	cmp    %ecx,%ebx
  800db7:	75 ed                	jne    800da6 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dca:	8b 55 10             	mov    0x10(%ebp),%edx
  800dcd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dcf:	85 d2                	test   %edx,%edx
  800dd1:	74 35                	je     800e08 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800dd3:	89 d0                	mov    %edx,%eax
  800dd5:	83 e8 01             	sub    $0x1,%eax
  800dd8:	74 25                	je     800dff <strlcpy+0x40>
  800dda:	0f b6 0b             	movzbl (%ebx),%ecx
  800ddd:	84 c9                	test   %cl,%cl
  800ddf:	74 22                	je     800e03 <strlcpy+0x44>
  800de1:	8d 53 01             	lea    0x1(%ebx),%edx
  800de4:	01 c3                	add    %eax,%ebx
  800de6:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800de8:	83 c0 01             	add    $0x1,%eax
  800deb:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dee:	39 da                	cmp    %ebx,%edx
  800df0:	74 13                	je     800e05 <strlcpy+0x46>
  800df2:	83 c2 01             	add    $0x1,%edx
  800df5:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800df9:	84 c9                	test   %cl,%cl
  800dfb:	75 eb                	jne    800de8 <strlcpy+0x29>
  800dfd:	eb 06                	jmp    800e05 <strlcpy+0x46>
  800dff:	89 f0                	mov    %esi,%eax
  800e01:	eb 02                	jmp    800e05 <strlcpy+0x46>
  800e03:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e05:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e08:	29 f0                	sub    %esi,%eax
}
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e17:	0f b6 01             	movzbl (%ecx),%eax
  800e1a:	84 c0                	test   %al,%al
  800e1c:	74 15                	je     800e33 <strcmp+0x25>
  800e1e:	3a 02                	cmp    (%edx),%al
  800e20:	75 11                	jne    800e33 <strcmp+0x25>
		p++, q++;
  800e22:	83 c1 01             	add    $0x1,%ecx
  800e25:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e28:	0f b6 01             	movzbl (%ecx),%eax
  800e2b:	84 c0                	test   %al,%al
  800e2d:	74 04                	je     800e33 <strcmp+0x25>
  800e2f:	3a 02                	cmp    (%edx),%al
  800e31:	74 ef                	je     800e22 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e33:	0f b6 c0             	movzbl %al,%eax
  800e36:	0f b6 12             	movzbl (%edx),%edx
  800e39:	29 d0                	sub    %edx,%eax
}
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e45:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e48:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e4b:	85 f6                	test   %esi,%esi
  800e4d:	74 29                	je     800e78 <strncmp+0x3b>
  800e4f:	0f b6 03             	movzbl (%ebx),%eax
  800e52:	84 c0                	test   %al,%al
  800e54:	74 30                	je     800e86 <strncmp+0x49>
  800e56:	3a 02                	cmp    (%edx),%al
  800e58:	75 2c                	jne    800e86 <strncmp+0x49>
  800e5a:	8d 43 01             	lea    0x1(%ebx),%eax
  800e5d:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e5f:	89 c3                	mov    %eax,%ebx
  800e61:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e64:	39 c6                	cmp    %eax,%esi
  800e66:	74 17                	je     800e7f <strncmp+0x42>
  800e68:	0f b6 08             	movzbl (%eax),%ecx
  800e6b:	84 c9                	test   %cl,%cl
  800e6d:	74 17                	je     800e86 <strncmp+0x49>
  800e6f:	83 c0 01             	add    $0x1,%eax
  800e72:	3a 0a                	cmp    (%edx),%cl
  800e74:	74 e9                	je     800e5f <strncmp+0x22>
  800e76:	eb 0e                	jmp    800e86 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7d:	eb 0f                	jmp    800e8e <strncmp+0x51>
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	eb 08                	jmp    800e8e <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e86:	0f b6 03             	movzbl (%ebx),%eax
  800e89:	0f b6 12             	movzbl (%edx),%edx
  800e8c:	29 d0                	sub    %edx,%eax
}
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	53                   	push   %ebx
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800e9c:	0f b6 10             	movzbl (%eax),%edx
  800e9f:	84 d2                	test   %dl,%dl
  800ea1:	74 1d                	je     800ec0 <strchr+0x2e>
  800ea3:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ea5:	38 d3                	cmp    %dl,%bl
  800ea7:	75 06                	jne    800eaf <strchr+0x1d>
  800ea9:	eb 1a                	jmp    800ec5 <strchr+0x33>
  800eab:	38 ca                	cmp    %cl,%dl
  800ead:	74 16                	je     800ec5 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eaf:	83 c0 01             	add    $0x1,%eax
  800eb2:	0f b6 10             	movzbl (%eax),%edx
  800eb5:	84 d2                	test   %dl,%dl
  800eb7:	75 f2                	jne    800eab <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebe:	eb 05                	jmp    800ec5 <strchr+0x33>
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	53                   	push   %ebx
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecf:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ed2:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ed5:	38 d3                	cmp    %dl,%bl
  800ed7:	74 14                	je     800eed <strfind+0x25>
  800ed9:	89 d1                	mov    %edx,%ecx
  800edb:	84 db                	test   %bl,%bl
  800edd:	74 0e                	je     800eed <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800edf:	83 c0 01             	add    $0x1,%eax
  800ee2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ee5:	38 ca                	cmp    %cl,%dl
  800ee7:	74 04                	je     800eed <strfind+0x25>
  800ee9:	84 d2                	test   %dl,%dl
  800eeb:	75 f2                	jne    800edf <strfind+0x17>
			break;
	return (char *) s;
}
  800eed:	5b                   	pop    %ebx
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ef9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800efc:	85 c9                	test   %ecx,%ecx
  800efe:	74 36                	je     800f36 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f00:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f06:	75 28                	jne    800f30 <memset+0x40>
  800f08:	f6 c1 03             	test   $0x3,%cl
  800f0b:	75 23                	jne    800f30 <memset+0x40>
		c &= 0xFF;
  800f0d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f11:	89 d3                	mov    %edx,%ebx
  800f13:	c1 e3 08             	shl    $0x8,%ebx
  800f16:	89 d6                	mov    %edx,%esi
  800f18:	c1 e6 18             	shl    $0x18,%esi
  800f1b:	89 d0                	mov    %edx,%eax
  800f1d:	c1 e0 10             	shl    $0x10,%eax
  800f20:	09 f0                	or     %esi,%eax
  800f22:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f24:	89 d8                	mov    %ebx,%eax
  800f26:	09 d0                	or     %edx,%eax
  800f28:	c1 e9 02             	shr    $0x2,%ecx
  800f2b:	fc                   	cld    
  800f2c:	f3 ab                	rep stos %eax,%es:(%edi)
  800f2e:	eb 06                	jmp    800f36 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f33:	fc                   	cld    
  800f34:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f36:	89 f8                	mov    %edi,%eax
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f4b:	39 c6                	cmp    %eax,%esi
  800f4d:	73 35                	jae    800f84 <memmove+0x47>
  800f4f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f52:	39 d0                	cmp    %edx,%eax
  800f54:	73 2e                	jae    800f84 <memmove+0x47>
		s += n;
		d += n;
  800f56:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f59:	89 d6                	mov    %edx,%esi
  800f5b:	09 fe                	or     %edi,%esi
  800f5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f63:	75 13                	jne    800f78 <memmove+0x3b>
  800f65:	f6 c1 03             	test   $0x3,%cl
  800f68:	75 0e                	jne    800f78 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f6a:	83 ef 04             	sub    $0x4,%edi
  800f6d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f70:	c1 e9 02             	shr    $0x2,%ecx
  800f73:	fd                   	std    
  800f74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f76:	eb 09                	jmp    800f81 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f78:	83 ef 01             	sub    $0x1,%edi
  800f7b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f7e:	fd                   	std    
  800f7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f81:	fc                   	cld    
  800f82:	eb 1d                	jmp    800fa1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f84:	89 f2                	mov    %esi,%edx
  800f86:	09 c2                	or     %eax,%edx
  800f88:	f6 c2 03             	test   $0x3,%dl
  800f8b:	75 0f                	jne    800f9c <memmove+0x5f>
  800f8d:	f6 c1 03             	test   $0x3,%cl
  800f90:	75 0a                	jne    800f9c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f92:	c1 e9 02             	shr    $0x2,%ecx
  800f95:	89 c7                	mov    %eax,%edi
  800f97:	fc                   	cld    
  800f98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9a:	eb 05                	jmp    800fa1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f9c:	89 c7                	mov    %eax,%edi
  800f9e:	fc                   	cld    
  800f9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fa8:	ff 75 10             	pushl  0x10(%ebp)
  800fab:	ff 75 0c             	pushl  0xc(%ebp)
  800fae:	ff 75 08             	pushl  0x8(%ebp)
  800fb1:	e8 87 ff ff ff       	call   800f3d <memmove>
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	57                   	push   %edi
  800fbc:	56                   	push   %esi
  800fbd:	53                   	push   %ebx
  800fbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc4:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	74 39                	je     801004 <memcmp+0x4c>
  800fcb:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800fce:	0f b6 13             	movzbl (%ebx),%edx
  800fd1:	0f b6 0e             	movzbl (%esi),%ecx
  800fd4:	38 ca                	cmp    %cl,%dl
  800fd6:	75 17                	jne    800fef <memcmp+0x37>
  800fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdd:	eb 1a                	jmp    800ff9 <memcmp+0x41>
  800fdf:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800fe4:	83 c0 01             	add    $0x1,%eax
  800fe7:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800feb:	38 ca                	cmp    %cl,%dl
  800fed:	74 0a                	je     800ff9 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800fef:	0f b6 c2             	movzbl %dl,%eax
  800ff2:	0f b6 c9             	movzbl %cl,%ecx
  800ff5:	29 c8                	sub    %ecx,%eax
  800ff7:	eb 10                	jmp    801009 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff9:	39 f8                	cmp    %edi,%eax
  800ffb:	75 e2                	jne    800fdf <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  801002:	eb 05                	jmp    801009 <memcmp+0x51>
  801004:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	53                   	push   %ebx
  801012:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801015:	89 d0                	mov    %edx,%eax
  801017:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80101a:	39 c2                	cmp    %eax,%edx
  80101c:	73 1d                	jae    80103b <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80101e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801022:	0f b6 0a             	movzbl (%edx),%ecx
  801025:	39 d9                	cmp    %ebx,%ecx
  801027:	75 09                	jne    801032 <memfind+0x24>
  801029:	eb 14                	jmp    80103f <memfind+0x31>
  80102b:	0f b6 0a             	movzbl (%edx),%ecx
  80102e:	39 d9                	cmp    %ebx,%ecx
  801030:	74 11                	je     801043 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801032:	83 c2 01             	add    $0x1,%edx
  801035:	39 d0                	cmp    %edx,%eax
  801037:	75 f2                	jne    80102b <memfind+0x1d>
  801039:	eb 0a                	jmp    801045 <memfind+0x37>
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	eb 06                	jmp    801045 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  80103f:	89 d0                	mov    %edx,%eax
  801041:	eb 02                	jmp    801045 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801043:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801045:	5b                   	pop    %ebx
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	53                   	push   %ebx
  80104e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801051:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801054:	0f b6 01             	movzbl (%ecx),%eax
  801057:	3c 20                	cmp    $0x20,%al
  801059:	74 04                	je     80105f <strtol+0x17>
  80105b:	3c 09                	cmp    $0x9,%al
  80105d:	75 0e                	jne    80106d <strtol+0x25>
		s++;
  80105f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801062:	0f b6 01             	movzbl (%ecx),%eax
  801065:	3c 20                	cmp    $0x20,%al
  801067:	74 f6                	je     80105f <strtol+0x17>
  801069:	3c 09                	cmp    $0x9,%al
  80106b:	74 f2                	je     80105f <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80106d:	3c 2b                	cmp    $0x2b,%al
  80106f:	75 0a                	jne    80107b <strtol+0x33>
		s++;
  801071:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801074:	bf 00 00 00 00       	mov    $0x0,%edi
  801079:	eb 11                	jmp    80108c <strtol+0x44>
  80107b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801080:	3c 2d                	cmp    $0x2d,%al
  801082:	75 08                	jne    80108c <strtol+0x44>
		s++, neg = 1;
  801084:	83 c1 01             	add    $0x1,%ecx
  801087:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80108c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801092:	75 15                	jne    8010a9 <strtol+0x61>
  801094:	80 39 30             	cmpb   $0x30,(%ecx)
  801097:	75 10                	jne    8010a9 <strtol+0x61>
  801099:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80109d:	75 7c                	jne    80111b <strtol+0xd3>
		s += 2, base = 16;
  80109f:	83 c1 02             	add    $0x2,%ecx
  8010a2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010a7:	eb 16                	jmp    8010bf <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010a9:	85 db                	test   %ebx,%ebx
  8010ab:	75 12                	jne    8010bf <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010ad:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010b2:	80 39 30             	cmpb   $0x30,(%ecx)
  8010b5:	75 08                	jne    8010bf <strtol+0x77>
		s++, base = 8;
  8010b7:	83 c1 01             	add    $0x1,%ecx
  8010ba:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010c7:	0f b6 11             	movzbl (%ecx),%edx
  8010ca:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010cd:	89 f3                	mov    %esi,%ebx
  8010cf:	80 fb 09             	cmp    $0x9,%bl
  8010d2:	77 08                	ja     8010dc <strtol+0x94>
			dig = *s - '0';
  8010d4:	0f be d2             	movsbl %dl,%edx
  8010d7:	83 ea 30             	sub    $0x30,%edx
  8010da:	eb 22                	jmp    8010fe <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8010dc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010df:	89 f3                	mov    %esi,%ebx
  8010e1:	80 fb 19             	cmp    $0x19,%bl
  8010e4:	77 08                	ja     8010ee <strtol+0xa6>
			dig = *s - 'a' + 10;
  8010e6:	0f be d2             	movsbl %dl,%edx
  8010e9:	83 ea 57             	sub    $0x57,%edx
  8010ec:	eb 10                	jmp    8010fe <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  8010ee:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010f1:	89 f3                	mov    %esi,%ebx
  8010f3:	80 fb 19             	cmp    $0x19,%bl
  8010f6:	77 16                	ja     80110e <strtol+0xc6>
			dig = *s - 'A' + 10;
  8010f8:	0f be d2             	movsbl %dl,%edx
  8010fb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8010fe:	3b 55 10             	cmp    0x10(%ebp),%edx
  801101:	7d 0b                	jge    80110e <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801103:	83 c1 01             	add    $0x1,%ecx
  801106:	0f af 45 10          	imul   0x10(%ebp),%eax
  80110a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80110c:	eb b9                	jmp    8010c7 <strtol+0x7f>

	if (endptr)
  80110e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801112:	74 0d                	je     801121 <strtol+0xd9>
		*endptr = (char *) s;
  801114:	8b 75 0c             	mov    0xc(%ebp),%esi
  801117:	89 0e                	mov    %ecx,(%esi)
  801119:	eb 06                	jmp    801121 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80111b:	85 db                	test   %ebx,%ebx
  80111d:	74 98                	je     8010b7 <strtol+0x6f>
  80111f:	eb 9e                	jmp    8010bf <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801121:	89 c2                	mov    %eax,%edx
  801123:	f7 da                	neg    %edx
  801125:	85 ff                	test   %edi,%edi
  801127:	0f 45 c2             	cmovne %edx,%eax
}
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    
  80112f:	90                   	nop

00801130 <__udivdi3>:
  801130:	55                   	push   %ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 1c             	sub    $0x1c,%esp
  801137:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80113b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80113f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801147:	85 f6                	test   %esi,%esi
  801149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80114d:	89 ca                	mov    %ecx,%edx
  80114f:	89 f8                	mov    %edi,%eax
  801151:	75 3d                	jne    801190 <__udivdi3+0x60>
  801153:	39 cf                	cmp    %ecx,%edi
  801155:	0f 87 c5 00 00 00    	ja     801220 <__udivdi3+0xf0>
  80115b:	85 ff                	test   %edi,%edi
  80115d:	89 fd                	mov    %edi,%ebp
  80115f:	75 0b                	jne    80116c <__udivdi3+0x3c>
  801161:	b8 01 00 00 00       	mov    $0x1,%eax
  801166:	31 d2                	xor    %edx,%edx
  801168:	f7 f7                	div    %edi
  80116a:	89 c5                	mov    %eax,%ebp
  80116c:	89 c8                	mov    %ecx,%eax
  80116e:	31 d2                	xor    %edx,%edx
  801170:	f7 f5                	div    %ebp
  801172:	89 c1                	mov    %eax,%ecx
  801174:	89 d8                	mov    %ebx,%eax
  801176:	89 cf                	mov    %ecx,%edi
  801178:	f7 f5                	div    %ebp
  80117a:	89 c3                	mov    %eax,%ebx
  80117c:	89 d8                	mov    %ebx,%eax
  80117e:	89 fa                	mov    %edi,%edx
  801180:	83 c4 1c             	add    $0x1c,%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    
  801188:	90                   	nop
  801189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801190:	39 ce                	cmp    %ecx,%esi
  801192:	77 74                	ja     801208 <__udivdi3+0xd8>
  801194:	0f bd fe             	bsr    %esi,%edi
  801197:	83 f7 1f             	xor    $0x1f,%edi
  80119a:	0f 84 98 00 00 00    	je     801238 <__udivdi3+0x108>
  8011a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011a5:	89 f9                	mov    %edi,%ecx
  8011a7:	89 c5                	mov    %eax,%ebp
  8011a9:	29 fb                	sub    %edi,%ebx
  8011ab:	d3 e6                	shl    %cl,%esi
  8011ad:	89 d9                	mov    %ebx,%ecx
  8011af:	d3 ed                	shr    %cl,%ebp
  8011b1:	89 f9                	mov    %edi,%ecx
  8011b3:	d3 e0                	shl    %cl,%eax
  8011b5:	09 ee                	or     %ebp,%esi
  8011b7:	89 d9                	mov    %ebx,%ecx
  8011b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bd:	89 d5                	mov    %edx,%ebp
  8011bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011c3:	d3 ed                	shr    %cl,%ebp
  8011c5:	89 f9                	mov    %edi,%ecx
  8011c7:	d3 e2                	shl    %cl,%edx
  8011c9:	89 d9                	mov    %ebx,%ecx
  8011cb:	d3 e8                	shr    %cl,%eax
  8011cd:	09 c2                	or     %eax,%edx
  8011cf:	89 d0                	mov    %edx,%eax
  8011d1:	89 ea                	mov    %ebp,%edx
  8011d3:	f7 f6                	div    %esi
  8011d5:	89 d5                	mov    %edx,%ebp
  8011d7:	89 c3                	mov    %eax,%ebx
  8011d9:	f7 64 24 0c          	mull   0xc(%esp)
  8011dd:	39 d5                	cmp    %edx,%ebp
  8011df:	72 10                	jb     8011f1 <__udivdi3+0xc1>
  8011e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011e5:	89 f9                	mov    %edi,%ecx
  8011e7:	d3 e6                	shl    %cl,%esi
  8011e9:	39 c6                	cmp    %eax,%esi
  8011eb:	73 07                	jae    8011f4 <__udivdi3+0xc4>
  8011ed:	39 d5                	cmp    %edx,%ebp
  8011ef:	75 03                	jne    8011f4 <__udivdi3+0xc4>
  8011f1:	83 eb 01             	sub    $0x1,%ebx
  8011f4:	31 ff                	xor    %edi,%edi
  8011f6:	89 d8                	mov    %ebx,%eax
  8011f8:	89 fa                	mov    %edi,%edx
  8011fa:	83 c4 1c             	add    $0x1c,%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    
  801202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801208:	31 ff                	xor    %edi,%edi
  80120a:	31 db                	xor    %ebx,%ebx
  80120c:	89 d8                	mov    %ebx,%eax
  80120e:	89 fa                	mov    %edi,%edx
  801210:	83 c4 1c             	add    $0x1c,%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    
  801218:	90                   	nop
  801219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 d8                	mov    %ebx,%eax
  801222:	f7 f7                	div    %edi
  801224:	31 ff                	xor    %edi,%edi
  801226:	89 c3                	mov    %eax,%ebx
  801228:	89 d8                	mov    %ebx,%eax
  80122a:	89 fa                	mov    %edi,%edx
  80122c:	83 c4 1c             	add    $0x1c,%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	39 ce                	cmp    %ecx,%esi
  80123a:	72 0c                	jb     801248 <__udivdi3+0x118>
  80123c:	31 db                	xor    %ebx,%ebx
  80123e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801242:	0f 87 34 ff ff ff    	ja     80117c <__udivdi3+0x4c>
  801248:	bb 01 00 00 00       	mov    $0x1,%ebx
  80124d:	e9 2a ff ff ff       	jmp    80117c <__udivdi3+0x4c>
  801252:	66 90                	xchg   %ax,%ax
  801254:	66 90                	xchg   %ax,%ax
  801256:	66 90                	xchg   %ax,%ax
  801258:	66 90                	xchg   %ax,%ax
  80125a:	66 90                	xchg   %ax,%ax
  80125c:	66 90                	xchg   %ax,%ax
  80125e:	66 90                	xchg   %ax,%ax

00801260 <__umoddi3>:
  801260:	55                   	push   %ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 1c             	sub    $0x1c,%esp
  801267:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80126b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80126f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801277:	85 d2                	test   %edx,%edx
  801279:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80127d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801281:	89 f3                	mov    %esi,%ebx
  801283:	89 3c 24             	mov    %edi,(%esp)
  801286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80128a:	75 1c                	jne    8012a8 <__umoddi3+0x48>
  80128c:	39 f7                	cmp    %esi,%edi
  80128e:	76 50                	jbe    8012e0 <__umoddi3+0x80>
  801290:	89 c8                	mov    %ecx,%eax
  801292:	89 f2                	mov    %esi,%edx
  801294:	f7 f7                	div    %edi
  801296:	89 d0                	mov    %edx,%eax
  801298:	31 d2                	xor    %edx,%edx
  80129a:	83 c4 1c             	add    $0x1c,%esp
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5f                   	pop    %edi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	39 f2                	cmp    %esi,%edx
  8012aa:	89 d0                	mov    %edx,%eax
  8012ac:	77 52                	ja     801300 <__umoddi3+0xa0>
  8012ae:	0f bd ea             	bsr    %edx,%ebp
  8012b1:	83 f5 1f             	xor    $0x1f,%ebp
  8012b4:	75 5a                	jne    801310 <__umoddi3+0xb0>
  8012b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012ba:	0f 82 e0 00 00 00    	jb     8013a0 <__umoddi3+0x140>
  8012c0:	39 0c 24             	cmp    %ecx,(%esp)
  8012c3:	0f 86 d7 00 00 00    	jbe    8013a0 <__umoddi3+0x140>
  8012c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012d1:	83 c4 1c             	add    $0x1c,%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5f                   	pop    %edi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    
  8012d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	85 ff                	test   %edi,%edi
  8012e2:	89 fd                	mov    %edi,%ebp
  8012e4:	75 0b                	jne    8012f1 <__umoddi3+0x91>
  8012e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	f7 f7                	div    %edi
  8012ef:	89 c5                	mov    %eax,%ebp
  8012f1:	89 f0                	mov    %esi,%eax
  8012f3:	31 d2                	xor    %edx,%edx
  8012f5:	f7 f5                	div    %ebp
  8012f7:	89 c8                	mov    %ecx,%eax
  8012f9:	f7 f5                	div    %ebp
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	eb 99                	jmp    801298 <__umoddi3+0x38>
  8012ff:	90                   	nop
  801300:	89 c8                	mov    %ecx,%eax
  801302:	89 f2                	mov    %esi,%edx
  801304:	83 c4 1c             	add    $0x1c,%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    
  80130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801310:	8b 34 24             	mov    (%esp),%esi
  801313:	bf 20 00 00 00       	mov    $0x20,%edi
  801318:	89 e9                	mov    %ebp,%ecx
  80131a:	29 ef                	sub    %ebp,%edi
  80131c:	d3 e0                	shl    %cl,%eax
  80131e:	89 f9                	mov    %edi,%ecx
  801320:	89 f2                	mov    %esi,%edx
  801322:	d3 ea                	shr    %cl,%edx
  801324:	89 e9                	mov    %ebp,%ecx
  801326:	09 c2                	or     %eax,%edx
  801328:	89 d8                	mov    %ebx,%eax
  80132a:	89 14 24             	mov    %edx,(%esp)
  80132d:	89 f2                	mov    %esi,%edx
  80132f:	d3 e2                	shl    %cl,%edx
  801331:	89 f9                	mov    %edi,%ecx
  801333:	89 54 24 04          	mov    %edx,0x4(%esp)
  801337:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80133b:	d3 e8                	shr    %cl,%eax
  80133d:	89 e9                	mov    %ebp,%ecx
  80133f:	89 c6                	mov    %eax,%esi
  801341:	d3 e3                	shl    %cl,%ebx
  801343:	89 f9                	mov    %edi,%ecx
  801345:	89 d0                	mov    %edx,%eax
  801347:	d3 e8                	shr    %cl,%eax
  801349:	89 e9                	mov    %ebp,%ecx
  80134b:	09 d8                	or     %ebx,%eax
  80134d:	89 d3                	mov    %edx,%ebx
  80134f:	89 f2                	mov    %esi,%edx
  801351:	f7 34 24             	divl   (%esp)
  801354:	89 d6                	mov    %edx,%esi
  801356:	d3 e3                	shl    %cl,%ebx
  801358:	f7 64 24 04          	mull   0x4(%esp)
  80135c:	39 d6                	cmp    %edx,%esi
  80135e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801362:	89 d1                	mov    %edx,%ecx
  801364:	89 c3                	mov    %eax,%ebx
  801366:	72 08                	jb     801370 <__umoddi3+0x110>
  801368:	75 11                	jne    80137b <__umoddi3+0x11b>
  80136a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80136e:	73 0b                	jae    80137b <__umoddi3+0x11b>
  801370:	2b 44 24 04          	sub    0x4(%esp),%eax
  801374:	1b 14 24             	sbb    (%esp),%edx
  801377:	89 d1                	mov    %edx,%ecx
  801379:	89 c3                	mov    %eax,%ebx
  80137b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80137f:	29 da                	sub    %ebx,%edx
  801381:	19 ce                	sbb    %ecx,%esi
  801383:	89 f9                	mov    %edi,%ecx
  801385:	89 f0                	mov    %esi,%eax
  801387:	d3 e0                	shl    %cl,%eax
  801389:	89 e9                	mov    %ebp,%ecx
  80138b:	d3 ea                	shr    %cl,%edx
  80138d:	89 e9                	mov    %ebp,%ecx
  80138f:	d3 ee                	shr    %cl,%esi
  801391:	09 d0                	or     %edx,%eax
  801393:	89 f2                	mov    %esi,%edx
  801395:	83 c4 1c             	add    $0x1c,%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
  80139d:	8d 76 00             	lea    0x0(%esi),%esi
  8013a0:	29 f9                	sub    %edi,%ecx
  8013a2:	19 d6                	sbb    %edx,%esi
  8013a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ac:	e9 18 ff ff ff       	jmp    8012c9 <__umoddi3+0x69>
