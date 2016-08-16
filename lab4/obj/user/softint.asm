
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800045:	e8 f9 00 00 00       	call   800143 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	c1 e0 07             	shl    $0x7,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 66 00 00 00       	call   8000f3 <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	51                   	push   %ecx
  8000a7:	52                   	push   %edx
  8000a8:	53                   	push   %ebx
  8000a9:	54                   	push   %esp
  8000aa:	55                   	push   %ebp
  8000ab:	56                   	push   %esi
  8000ac:	57                   	push   %edi
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	8d 35 b7 00 80 00    	lea    0x8000b7,%esi
  8000b5:	0f 34                	sysenter 

008000b7 <label_21>:
  8000b7:	5f                   	pop    %edi
  8000b8:	5e                   	pop    %esi
  8000b9:	5d                   	pop    %ebp
  8000ba:	5c                   	pop    %esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5a                   	pop    %edx
  8000bd:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 ca                	mov    %ecx,%edx
  8000d3:	89 cb                	mov    %ecx,%ebx
  8000d5:	89 cf                	mov    %ecx,%edi
  8000d7:	51                   	push   %ecx
  8000d8:	52                   	push   %edx
  8000d9:	53                   	push   %ebx
  8000da:	54                   	push   %esp
  8000db:	55                   	push   %ebp
  8000dc:	56                   	push   %esi
  8000dd:	57                   	push   %edi
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	8d 35 e8 00 80 00    	lea    0x8000e8,%esi
  8000e6:	0f 34                	sysenter 

008000e8 <label_55>:
  8000e8:	5f                   	pop    %edi
  8000e9:	5e                   	pop    %esi
  8000ea:	5d                   	pop    %ebp
  8000eb:	5c                   	pop    %esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5a                   	pop    %edx
  8000ee:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000fd:	b8 03 00 00 00       	mov    $0x3,%eax
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	89 d9                	mov    %ebx,%ecx
  800107:	89 df                	mov    %ebx,%edi
  800109:	51                   	push   %ecx
  80010a:	52                   	push   %edx
  80010b:	53                   	push   %ebx
  80010c:	54                   	push   %esp
  80010d:	55                   	push   %ebp
  80010e:	56                   	push   %esi
  80010f:	57                   	push   %edi
  800110:	89 e5                	mov    %esp,%ebp
  800112:	8d 35 1a 01 80 00    	lea    0x80011a,%esi
  800118:	0f 34                	sysenter 

0080011a <label_90>:
  80011a:	5f                   	pop    %edi
  80011b:	5e                   	pop    %esi
  80011c:	5d                   	pop    %ebp
  80011d:	5c                   	pop    %esp
  80011e:	5b                   	pop    %ebx
  80011f:	5a                   	pop    %edx
  800120:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	7e 17                	jle    80013c <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	50                   	push   %eax
  800129:	6a 03                	push   $0x3
  80012b:	68 ca 13 80 00       	push   $0x8013ca
  800130:	6a 2a                	push   $0x2a
  800132:	68 e7 13 80 00       	push   $0x8013e7
  800137:	e8 e5 02 00 00       	call   800421 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013f:	5b                   	pop    %ebx
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800148:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014d:	b8 02 00 00 00       	mov    $0x2,%eax
  800152:	89 ca                	mov    %ecx,%edx
  800154:	89 cb                	mov    %ecx,%ebx
  800156:	89 cf                	mov    %ecx,%edi
  800158:	51                   	push   %ecx
  800159:	52                   	push   %edx
  80015a:	53                   	push   %ebx
  80015b:	54                   	push   %esp
  80015c:	55                   	push   %ebp
  80015d:	56                   	push   %esi
  80015e:	57                   	push   %edi
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	8d 35 69 01 80 00    	lea    0x800169,%esi
  800167:	0f 34                	sysenter 

00800169 <label_139>:
  800169:	5f                   	pop    %edi
  80016a:	5e                   	pop    %esi
  80016b:	5d                   	pop    %ebp
  80016c:	5c                   	pop    %esp
  80016d:	5b                   	pop    %ebx
  80016e:	5a                   	pop    %edx
  80016f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800179:	bf 00 00 00 00       	mov    $0x0,%edi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	89 fb                	mov    %edi,%ebx
  80018b:	51                   	push   %ecx
  80018c:	52                   	push   %edx
  80018d:	53                   	push   %ebx
  80018e:	54                   	push   %esp
  80018f:	55                   	push   %ebp
  800190:	56                   	push   %esi
  800191:	57                   	push   %edi
  800192:	89 e5                	mov    %esp,%ebp
  800194:	8d 35 9c 01 80 00    	lea    0x80019c,%esi
  80019a:	0f 34                	sysenter 

0080019c <label_174>:
  80019c:	5f                   	pop    %edi
  80019d:	5e                   	pop    %esi
  80019e:	5d                   	pop    %ebp
  80019f:	5c                   	pop    %esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5a                   	pop    %edx
  8001a2:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001a3:	5b                   	pop    %ebx
  8001a4:	5f                   	pop    %edi
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <sys_yield>:

void
sys_yield(void)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b6:	89 d1                	mov    %edx,%ecx
  8001b8:	89 d3                	mov    %edx,%ebx
  8001ba:	89 d7                	mov    %edx,%edi
  8001bc:	51                   	push   %ecx
  8001bd:	52                   	push   %edx
  8001be:	53                   	push   %ebx
  8001bf:	54                   	push   %esp
  8001c0:	55                   	push   %ebp
  8001c1:	56                   	push   %esi
  8001c2:	57                   	push   %edi
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	8d 35 cd 01 80 00    	lea    0x8001cd,%esi
  8001cb:	0f 34                	sysenter 

008001cd <label_209>:
  8001cd:	5f                   	pop    %edi
  8001ce:	5e                   	pop    %esi
  8001cf:	5d                   	pop    %ebp
  8001d0:	5c                   	pop    %esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5a                   	pop    %edx
  8001d3:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001d4:	5b                   	pop    %ebx
  8001d5:	5f                   	pop    %edi
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    

008001d8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	57                   	push   %edi
  8001dc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f0:	51                   	push   %ecx
  8001f1:	52                   	push   %edx
  8001f2:	53                   	push   %ebx
  8001f3:	54                   	push   %esp
  8001f4:	55                   	push   %ebp
  8001f5:	56                   	push   %esi
  8001f6:	57                   	push   %edi
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	8d 35 01 02 80 00    	lea    0x800201,%esi
  8001ff:	0f 34                	sysenter 

00800201 <label_244>:
  800201:	5f                   	pop    %edi
  800202:	5e                   	pop    %esi
  800203:	5d                   	pop    %ebp
  800204:	5c                   	pop    %esp
  800205:	5b                   	pop    %ebx
  800206:	5a                   	pop    %edx
  800207:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800208:	85 c0                	test   %eax,%eax
  80020a:	7e 17                	jle    800223 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	6a 05                	push   $0x5
  800212:	68 ca 13 80 00       	push   $0x8013ca
  800217:	6a 2a                	push   $0x2a
  800219:	68 e7 13 80 00       	push   $0x8013e7
  80021e:	e8 fe 01 00 00       	call   800421 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80022f:	b8 06 00 00 00       	mov    $0x6,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80023d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800240:	51                   	push   %ecx
  800241:	52                   	push   %edx
  800242:	53                   	push   %ebx
  800243:	54                   	push   %esp
  800244:	55                   	push   %ebp
  800245:	56                   	push   %esi
  800246:	57                   	push   %edi
  800247:	89 e5                	mov    %esp,%ebp
  800249:	8d 35 51 02 80 00    	lea    0x800251,%esi
  80024f:	0f 34                	sysenter 

00800251 <label_295>:
  800251:	5f                   	pop    %edi
  800252:	5e                   	pop    %esi
  800253:	5d                   	pop    %ebp
  800254:	5c                   	pop    %esp
  800255:	5b                   	pop    %ebx
  800256:	5a                   	pop    %edx
  800257:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7e 17                	jle    800273 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 06                	push   $0x6
  800262:	68 ca 13 80 00       	push   $0x8013ca
  800267:	6a 2a                	push   $0x2a
  800269:	68 e7 13 80 00       	push   $0x8013e7
  80026e:	e8 ae 01 00 00       	call   800421 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800273:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80027f:	bf 00 00 00 00       	mov    $0x0,%edi
  800284:	b8 07 00 00 00       	mov    $0x7,%eax
  800289:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028c:	8b 55 08             	mov    0x8(%ebp),%edx
  80028f:	89 fb                	mov    %edi,%ebx
  800291:	51                   	push   %ecx
  800292:	52                   	push   %edx
  800293:	53                   	push   %ebx
  800294:	54                   	push   %esp
  800295:	55                   	push   %ebp
  800296:	56                   	push   %esi
  800297:	57                   	push   %edi
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	8d 35 a2 02 80 00    	lea    0x8002a2,%esi
  8002a0:	0f 34                	sysenter 

008002a2 <label_344>:
  8002a2:	5f                   	pop    %edi
  8002a3:	5e                   	pop    %esi
  8002a4:	5d                   	pop    %ebp
  8002a5:	5c                   	pop    %esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5a                   	pop    %edx
  8002a8:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 07                	push   $0x7
  8002b3:	68 ca 13 80 00       	push   $0x8013ca
  8002b8:	6a 2a                	push   $0x2a
  8002ba:	68 e7 13 80 00       	push   $0x8013e7
  8002bf:	e8 5d 01 00 00       	call   800421 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8002d5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	89 fb                	mov    %edi,%ebx
  8002e2:	51                   	push   %ecx
  8002e3:	52                   	push   %edx
  8002e4:	53                   	push   %ebx
  8002e5:	54                   	push   %esp
  8002e6:	55                   	push   %ebp
  8002e7:	56                   	push   %esi
  8002e8:	57                   	push   %edi
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	8d 35 f3 02 80 00    	lea    0x8002f3,%esi
  8002f1:	0f 34                	sysenter 

008002f3 <label_393>:
  8002f3:	5f                   	pop    %edi
  8002f4:	5e                   	pop    %esi
  8002f5:	5d                   	pop    %ebp
  8002f6:	5c                   	pop    %esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5a                   	pop    %edx
  8002f9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002fa:	85 c0                	test   %eax,%eax
  8002fc:	7e 17                	jle    800315 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002fe:	83 ec 0c             	sub    $0xc,%esp
  800301:	50                   	push   %eax
  800302:	6a 09                	push   $0x9
  800304:	68 ca 13 80 00       	push   $0x8013ca
  800309:	6a 2a                	push   $0x2a
  80030b:	68 e7 13 80 00       	push   $0x8013e7
  800310:	e8 0c 01 00 00       	call   800421 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5f                   	pop    %edi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800321:	bf 00 00 00 00       	mov    $0x0,%edi
  800326:	b8 0a 00 00 00       	mov    $0xa,%eax
  80032b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	89 fb                	mov    %edi,%ebx
  800333:	51                   	push   %ecx
  800334:	52                   	push   %edx
  800335:	53                   	push   %ebx
  800336:	54                   	push   %esp
  800337:	55                   	push   %ebp
  800338:	56                   	push   %esi
  800339:	57                   	push   %edi
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	8d 35 44 03 80 00    	lea    0x800344,%esi
  800342:	0f 34                	sysenter 

00800344 <label_442>:
  800344:	5f                   	pop    %edi
  800345:	5e                   	pop    %esi
  800346:	5d                   	pop    %ebp
  800347:	5c                   	pop    %esp
  800348:	5b                   	pop    %ebx
  800349:	5a                   	pop    %edx
  80034a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80034b:	85 c0                	test   %eax,%eax
  80034d:	7e 17                	jle    800366 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80034f:	83 ec 0c             	sub    $0xc,%esp
  800352:	50                   	push   %eax
  800353:	6a 0a                	push   $0xa
  800355:	68 ca 13 80 00       	push   $0x8013ca
  80035a:	6a 2a                	push   $0x2a
  80035c:	68 e7 13 80 00       	push   $0x8013e7
  800361:	e8 bb 00 00 00       	call   800421 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800366:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800369:	5b                   	pop    %ebx
  80036a:	5f                   	pop    %edi
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800372:	b8 0c 00 00 00       	mov    $0xc,%eax
  800377:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037a:	8b 55 08             	mov    0x8(%ebp),%edx
  80037d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800380:	8b 7d 14             	mov    0x14(%ebp),%edi
  800383:	51                   	push   %ecx
  800384:	52                   	push   %edx
  800385:	53                   	push   %ebx
  800386:	54                   	push   %esp
  800387:	55                   	push   %ebp
  800388:	56                   	push   %esi
  800389:	57                   	push   %edi
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8d 35 94 03 80 00    	lea    0x800394,%esi
  800392:	0f 34                	sysenter 

00800394 <label_493>:
  800394:	5f                   	pop    %edi
  800395:	5e                   	pop    %esi
  800396:	5d                   	pop    %ebp
  800397:	5c                   	pop    %esp
  800398:	5b                   	pop    %ebx
  800399:	5a                   	pop    %edx
  80039a:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80039b:	5b                   	pop    %ebx
  80039c:	5f                   	pop    %edi
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b1:	89 d9                	mov    %ebx,%ecx
  8003b3:	89 df                	mov    %ebx,%edi
  8003b5:	51                   	push   %ecx
  8003b6:	52                   	push   %edx
  8003b7:	53                   	push   %ebx
  8003b8:	54                   	push   %esp
  8003b9:	55                   	push   %ebp
  8003ba:	56                   	push   %esi
  8003bb:	57                   	push   %edi
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8d 35 c6 03 80 00    	lea    0x8003c6,%esi
  8003c4:	0f 34                	sysenter 

008003c6 <label_528>:
  8003c6:	5f                   	pop    %edi
  8003c7:	5e                   	pop    %esi
  8003c8:	5d                   	pop    %ebp
  8003c9:	5c                   	pop    %esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5a                   	pop    %edx
  8003cc:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	7e 17                	jle    8003e8 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8003d1:	83 ec 0c             	sub    $0xc,%esp
  8003d4:	50                   	push   %eax
  8003d5:	6a 0d                	push   $0xd
  8003d7:	68 ca 13 80 00       	push   $0x8013ca
  8003dc:	6a 2a                	push   $0x2a
  8003de:	68 e7 13 80 00       	push   $0x8013e7
  8003e3:	e8 39 00 00 00       	call   800421 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003eb:	5b                   	pop    %ebx
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	57                   	push   %edi
  8003f3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800401:	89 cb                	mov    %ecx,%ebx
  800403:	89 cf                	mov    %ecx,%edi
  800405:	51                   	push   %ecx
  800406:	52                   	push   %edx
  800407:	53                   	push   %ebx
  800408:	54                   	push   %esp
  800409:	55                   	push   %ebp
  80040a:	56                   	push   %esi
  80040b:	57                   	push   %edi
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	8d 35 16 04 80 00    	lea    0x800416,%esi
  800414:	0f 34                	sysenter 

00800416 <label_577>:
  800416:	5f                   	pop    %edi
  800417:	5e                   	pop    %esi
  800418:	5d                   	pop    %ebp
  800419:	5c                   	pop    %esp
  80041a:	5b                   	pop    %ebx
  80041b:	5a                   	pop    %edx
  80041c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80041d:	5b                   	pop    %ebx
  80041e:	5f                   	pop    %edi
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800426:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800429:	a1 10 20 80 00       	mov    0x802010,%eax
  80042e:	85 c0                	test   %eax,%eax
  800430:	74 11                	je     800443 <_panic+0x22>
		cprintf("%s: ", argv0);
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	50                   	push   %eax
  800436:	68 f5 13 80 00       	push   $0x8013f5
  80043b:	e8 d4 00 00 00       	call   800514 <cprintf>
  800440:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800443:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800449:	e8 f5 fc ff ff       	call   800143 <sys_getenvid>
  80044e:	83 ec 0c             	sub    $0xc,%esp
  800451:	ff 75 0c             	pushl  0xc(%ebp)
  800454:	ff 75 08             	pushl  0x8(%ebp)
  800457:	56                   	push   %esi
  800458:	50                   	push   %eax
  800459:	68 fc 13 80 00       	push   $0x8013fc
  80045e:	e8 b1 00 00 00       	call   800514 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800463:	83 c4 18             	add    $0x18,%esp
  800466:	53                   	push   %ebx
  800467:	ff 75 10             	pushl  0x10(%ebp)
  80046a:	e8 54 00 00 00       	call   8004c3 <vcprintf>
	cprintf("\n");
  80046f:	c7 04 24 fa 13 80 00 	movl   $0x8013fa,(%esp)
  800476:	e8 99 00 00 00       	call   800514 <cprintf>
  80047b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80047e:	cc                   	int3   
  80047f:	eb fd                	jmp    80047e <_panic+0x5d>

00800481 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800481:	55                   	push   %ebp
  800482:	89 e5                	mov    %esp,%ebp
  800484:	53                   	push   %ebx
  800485:	83 ec 04             	sub    $0x4,%esp
  800488:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80048b:	8b 13                	mov    (%ebx),%edx
  80048d:	8d 42 01             	lea    0x1(%edx),%eax
  800490:	89 03                	mov    %eax,(%ebx)
  800492:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800495:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800499:	3d ff 00 00 00       	cmp    $0xff,%eax
  80049e:	75 1a                	jne    8004ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	68 ff 00 00 00       	push   $0xff
  8004a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ab:	50                   	push   %eax
  8004ac:	e8 e1 fb ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  8004b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c1:	c9                   	leave  
  8004c2:	c3                   	ret    

008004c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004d3:	00 00 00 
	b.cnt = 0;
  8004d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004e0:	ff 75 0c             	pushl  0xc(%ebp)
  8004e3:	ff 75 08             	pushl  0x8(%ebp)
  8004e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004ec:	50                   	push   %eax
  8004ed:	68 81 04 80 00       	push   $0x800481
  8004f2:	e8 c0 02 00 00       	call   8007b7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004f7:	83 c4 08             	add    $0x8,%esp
  8004fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800500:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800506:	50                   	push   %eax
  800507:	e8 86 fb ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  80050c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800512:	c9                   	leave  
  800513:	c3                   	ret    

00800514 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80051a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80051d:	50                   	push   %eax
  80051e:	ff 75 08             	pushl  0x8(%ebp)
  800521:	e8 9d ff ff ff       	call   8004c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800526:	c9                   	leave  
  800527:	c3                   	ret    

00800528 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	57                   	push   %edi
  80052c:	56                   	push   %esi
  80052d:	53                   	push   %ebx
  80052e:	83 ec 1c             	sub    $0x1c,%esp
  800531:	89 c7                	mov    %eax,%edi
  800533:	89 d6                	mov    %edx,%esi
  800535:	8b 45 08             	mov    0x8(%ebp),%eax
  800538:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800541:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800544:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800548:	0f 85 bf 00 00 00    	jne    80060d <printnum+0xe5>
  80054e:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800554:	0f 8d de 00 00 00    	jge    800638 <printnum+0x110>
		judge_time_for_space = width;
  80055a:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800560:	e9 d3 00 00 00       	jmp    800638 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800565:	83 eb 01             	sub    $0x1,%ebx
  800568:	85 db                	test   %ebx,%ebx
  80056a:	7f 37                	jg     8005a3 <printnum+0x7b>
  80056c:	e9 ea 00 00 00       	jmp    80065b <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800571:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800574:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	56                   	push   %esi
  80057d:	83 ec 04             	sub    $0x4,%esp
  800580:	ff 75 dc             	pushl  -0x24(%ebp)
  800583:	ff 75 d8             	pushl  -0x28(%ebp)
  800586:	ff 75 e4             	pushl  -0x1c(%ebp)
  800589:	ff 75 e0             	pushl  -0x20(%ebp)
  80058c:	e8 cf 0c 00 00       	call   801260 <__umoddi3>
  800591:	83 c4 14             	add    $0x14,%esp
  800594:	0f be 80 1f 14 80 00 	movsbl 0x80141f(%eax),%eax
  80059b:	50                   	push   %eax
  80059c:	ff d7                	call   *%edi
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	eb 16                	jmp    8005b9 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	56                   	push   %esi
  8005a7:	ff 75 18             	pushl  0x18(%ebp)
  8005aa:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	83 eb 01             	sub    $0x1,%ebx
  8005b2:	75 ef                	jne    8005a3 <printnum+0x7b>
  8005b4:	e9 a2 00 00 00       	jmp    80065b <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005b9:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005bf:	0f 85 76 01 00 00    	jne    80073b <printnum+0x213>
		while(num_of_space-- > 0)
  8005c5:	a1 04 20 80 00       	mov    0x802004,%eax
  8005ca:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005cd:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	7e 1d                	jle    8005f4 <printnum+0xcc>
			putch(' ', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	56                   	push   %esi
  8005db:	6a 20                	push   $0x20
  8005dd:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8005df:	a1 04 20 80 00       	mov    0x802004,%eax
  8005e4:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005e7:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	85 c0                	test   %eax,%eax
  8005f2:	7f e3                	jg     8005d7 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8005f4:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8005fb:	00 00 00 
		judge_time_for_space = 0;
  8005fe:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800605:	00 00 00 
	}
}
  800608:	e9 2e 01 00 00       	jmp    80073b <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80060d:	8b 45 10             	mov    0x10(%ebp),%eax
  800610:	ba 00 00 00 00       	mov    $0x0,%edx
  800615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800618:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800621:	83 fa 00             	cmp    $0x0,%edx
  800624:	0f 87 ba 00 00 00    	ja     8006e4 <printnum+0x1bc>
  80062a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80062d:	0f 83 b1 00 00 00    	jae    8006e4 <printnum+0x1bc>
  800633:	e9 2d ff ff ff       	jmp    800565 <printnum+0x3d>
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	ba 00 00 00 00       	mov    $0x0,%edx
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800646:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800649:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064c:	83 fa 00             	cmp    $0x0,%edx
  80064f:	77 37                	ja     800688 <printnum+0x160>
  800651:	3b 45 10             	cmp    0x10(%ebp),%eax
  800654:	73 32                	jae    800688 <printnum+0x160>
  800656:	e9 16 ff ff ff       	jmp    800571 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	56                   	push   %esi
  80065f:	83 ec 04             	sub    $0x4,%esp
  800662:	ff 75 dc             	pushl  -0x24(%ebp)
  800665:	ff 75 d8             	pushl  -0x28(%ebp)
  800668:	ff 75 e4             	pushl  -0x1c(%ebp)
  80066b:	ff 75 e0             	pushl  -0x20(%ebp)
  80066e:	e8 ed 0b 00 00       	call   801260 <__umoddi3>
  800673:	83 c4 14             	add    $0x14,%esp
  800676:	0f be 80 1f 14 80 00 	movsbl 0x80141f(%eax),%eax
  80067d:	50                   	push   %eax
  80067e:	ff d7                	call   *%edi
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	e9 b3 00 00 00       	jmp    80073b <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	ff 75 18             	pushl  0x18(%ebp)
  80068e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800691:	50                   	push   %eax
  800692:	ff 75 10             	pushl  0x10(%ebp)
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	ff 75 dc             	pushl  -0x24(%ebp)
  80069b:	ff 75 d8             	pushl  -0x28(%ebp)
  80069e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a4:	e8 87 0a 00 00       	call   801130 <__udivdi3>
  8006a9:	83 c4 18             	add    $0x18,%esp
  8006ac:	52                   	push   %edx
  8006ad:	50                   	push   %eax
  8006ae:	89 f2                	mov    %esi,%edx
  8006b0:	89 f8                	mov    %edi,%eax
  8006b2:	e8 71 fe ff ff       	call   800528 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006b7:	83 c4 18             	add    $0x18,%esp
  8006ba:	56                   	push   %esi
  8006bb:	83 ec 04             	sub    $0x4,%esp
  8006be:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ca:	e8 91 0b 00 00       	call   801260 <__umoddi3>
  8006cf:	83 c4 14             	add    $0x14,%esp
  8006d2:	0f be 80 1f 14 80 00 	movsbl 0x80141f(%eax),%eax
  8006d9:	50                   	push   %eax
  8006da:	ff d7                	call   *%edi
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	e9 d5 fe ff ff       	jmp    8005b9 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e4:	83 ec 0c             	sub    $0xc,%esp
  8006e7:	ff 75 18             	pushl  0x18(%ebp)
  8006ea:	83 eb 01             	sub    $0x1,%ebx
  8006ed:	53                   	push   %ebx
  8006ee:	ff 75 10             	pushl  0x10(%ebp)
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8006f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8006fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800700:	e8 2b 0a 00 00       	call   801130 <__udivdi3>
  800705:	83 c4 18             	add    $0x18,%esp
  800708:	52                   	push   %edx
  800709:	50                   	push   %eax
  80070a:	89 f2                	mov    %esi,%edx
  80070c:	89 f8                	mov    %edi,%eax
  80070e:	e8 15 fe ff ff       	call   800528 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800713:	83 c4 18             	add    $0x18,%esp
  800716:	56                   	push   %esi
  800717:	83 ec 04             	sub    $0x4,%esp
  80071a:	ff 75 dc             	pushl  -0x24(%ebp)
  80071d:	ff 75 d8             	pushl  -0x28(%ebp)
  800720:	ff 75 e4             	pushl  -0x1c(%ebp)
  800723:	ff 75 e0             	pushl  -0x20(%ebp)
  800726:	e8 35 0b 00 00       	call   801260 <__umoddi3>
  80072b:	83 c4 14             	add    $0x14,%esp
  80072e:	0f be 80 1f 14 80 00 	movsbl 0x80141f(%eax),%eax
  800735:	50                   	push   %eax
  800736:	ff d7                	call   *%edi
  800738:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80073b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073e:	5b                   	pop    %ebx
  80073f:	5e                   	pop    %esi
  800740:	5f                   	pop    %edi
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800746:	83 fa 01             	cmp    $0x1,%edx
  800749:	7e 0e                	jle    800759 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800750:	89 08                	mov    %ecx,(%eax)
  800752:	8b 02                	mov    (%edx),%eax
  800754:	8b 52 04             	mov    0x4(%edx),%edx
  800757:	eb 22                	jmp    80077b <getuint+0x38>
	else if (lflag)
  800759:	85 d2                	test   %edx,%edx
  80075b:	74 10                	je     80076d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80075d:	8b 10                	mov    (%eax),%edx
  80075f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800762:	89 08                	mov    %ecx,(%eax)
  800764:	8b 02                	mov    (%edx),%eax
  800766:	ba 00 00 00 00       	mov    $0x0,%edx
  80076b:	eb 0e                	jmp    80077b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80076d:	8b 10                	mov    (%eax),%edx
  80076f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800772:	89 08                	mov    %ecx,(%eax)
  800774:	8b 02                	mov    (%edx),%eax
  800776:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800783:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800787:	8b 10                	mov    (%eax),%edx
  800789:	3b 50 04             	cmp    0x4(%eax),%edx
  80078c:	73 0a                	jae    800798 <sprintputch+0x1b>
		*b->buf++ = ch;
  80078e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800791:	89 08                	mov    %ecx,(%eax)
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	88 02                	mov    %al,(%edx)
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007a3:	50                   	push   %eax
  8007a4:	ff 75 10             	pushl  0x10(%ebp)
  8007a7:	ff 75 0c             	pushl  0xc(%ebp)
  8007aa:	ff 75 08             	pushl  0x8(%ebp)
  8007ad:	e8 05 00 00 00       	call   8007b7 <vprintfmt>
	va_end(ap);
}
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	57                   	push   %edi
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	83 ec 2c             	sub    $0x2c,%esp
  8007c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c6:	eb 03                	jmp    8007cb <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c8:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ce:	8d 70 01             	lea    0x1(%eax),%esi
  8007d1:	0f b6 00             	movzbl (%eax),%eax
  8007d4:	83 f8 25             	cmp    $0x25,%eax
  8007d7:	74 27                	je     800800 <vprintfmt+0x49>
			if (ch == '\0')
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	75 0d                	jne    8007ea <vprintfmt+0x33>
  8007dd:	e9 9d 04 00 00       	jmp    800c7f <vprintfmt+0x4c8>
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	0f 84 95 04 00 00    	je     800c7f <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	50                   	push   %eax
  8007ef:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f1:	83 c6 01             	add    $0x1,%esi
  8007f4:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	83 f8 25             	cmp    $0x25,%eax
  8007fe:	75 e2                	jne    8007e2 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800800:	b9 00 00 00 00       	mov    $0x0,%ecx
  800805:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800809:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800810:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800817:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80081e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800825:	eb 08                	jmp    80082f <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800827:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80082a:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8d 46 01             	lea    0x1(%esi),%eax
  800832:	89 45 10             	mov    %eax,0x10(%ebp)
  800835:	0f b6 06             	movzbl (%esi),%eax
  800838:	0f b6 d0             	movzbl %al,%edx
  80083b:	83 e8 23             	sub    $0x23,%eax
  80083e:	3c 55                	cmp    $0x55,%al
  800840:	0f 87 fa 03 00 00    	ja     800c40 <vprintfmt+0x489>
  800846:	0f b6 c0             	movzbl %al,%eax
  800849:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
  800850:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800853:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800857:	eb d6                	jmp    80082f <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800859:	8d 42 d0             	lea    -0x30(%edx),%eax
  80085c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80085f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800863:	8d 50 d0             	lea    -0x30(%eax),%edx
  800866:	83 fa 09             	cmp    $0x9,%edx
  800869:	77 6b                	ja     8008d6 <vprintfmt+0x11f>
  80086b:	8b 75 10             	mov    0x10(%ebp),%esi
  80086e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800871:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800874:	eb 09                	jmp    80087f <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800876:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800879:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80087d:	eb b0                	jmp    80082f <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80087f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800882:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800885:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800889:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80088c:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80088f:	83 f9 09             	cmp    $0x9,%ecx
  800892:	76 eb                	jbe    80087f <vprintfmt+0xc8>
  800894:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800897:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80089a:	eb 3d                	jmp    8008d9 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8d 50 04             	lea    0x4(%eax),%edx
  8008a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a5:	8b 00                	mov    (%eax),%eax
  8008a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008aa:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ad:	eb 2a                	jmp    8008d9 <vprintfmt+0x122>
  8008af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008b2:	85 c0                	test   %eax,%eax
  8008b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b9:	0f 49 d0             	cmovns %eax,%edx
  8008bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bf:	8b 75 10             	mov    0x10(%ebp),%esi
  8008c2:	e9 68 ff ff ff       	jmp    80082f <vprintfmt+0x78>
  8008c7:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ca:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d1:	e9 59 ff ff ff       	jmp    80082f <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008dd:	0f 89 4c ff ff ff    	jns    80082f <vprintfmt+0x78>
				width = precision, precision = -1;
  8008e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f0:	e9 3a ff ff ff       	jmp    80082f <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f5:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f9:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008fc:	e9 2e ff ff ff       	jmp    80082f <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800901:	8b 45 14             	mov    0x14(%ebp),%eax
  800904:	8d 50 04             	lea    0x4(%eax),%edx
  800907:	89 55 14             	mov    %edx,0x14(%ebp)
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	ff 30                	pushl  (%eax)
  800910:	ff d7                	call   *%edi
			break;
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	e9 b1 fe ff ff       	jmp    8007cb <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8d 50 04             	lea    0x4(%eax),%edx
  800920:	89 55 14             	mov    %edx,0x14(%ebp)
  800923:	8b 00                	mov    (%eax),%eax
  800925:	99                   	cltd   
  800926:	31 d0                	xor    %edx,%eax
  800928:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092a:	83 f8 08             	cmp    $0x8,%eax
  80092d:	7f 0b                	jg     80093a <vprintfmt+0x183>
  80092f:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  800936:	85 d2                	test   %edx,%edx
  800938:	75 15                	jne    80094f <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80093a:	50                   	push   %eax
  80093b:	68 37 14 80 00       	push   $0x801437
  800940:	53                   	push   %ebx
  800941:	57                   	push   %edi
  800942:	e8 53 fe ff ff       	call   80079a <printfmt>
  800947:	83 c4 10             	add    $0x10,%esp
  80094a:	e9 7c fe ff ff       	jmp    8007cb <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80094f:	52                   	push   %edx
  800950:	68 40 14 80 00       	push   $0x801440
  800955:	53                   	push   %ebx
  800956:	57                   	push   %edi
  800957:	e8 3e fe ff ff       	call   80079a <printfmt>
  80095c:	83 c4 10             	add    $0x10,%esp
  80095f:	e9 67 fe ff ff       	jmp    8007cb <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800964:	8b 45 14             	mov    0x14(%ebp),%eax
  800967:	8d 50 04             	lea    0x4(%eax),%edx
  80096a:	89 55 14             	mov    %edx,0x14(%ebp)
  80096d:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80096f:	85 c0                	test   %eax,%eax
  800971:	b9 30 14 80 00       	mov    $0x801430,%ecx
  800976:	0f 45 c8             	cmovne %eax,%ecx
  800979:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80097c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800980:	7e 06                	jle    800988 <vprintfmt+0x1d1>
  800982:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800986:	75 19                	jne    8009a1 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800988:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80098b:	8d 70 01             	lea    0x1(%eax),%esi
  80098e:	0f b6 00             	movzbl (%eax),%eax
  800991:	0f be d0             	movsbl %al,%edx
  800994:	85 d2                	test   %edx,%edx
  800996:	0f 85 9f 00 00 00    	jne    800a3b <vprintfmt+0x284>
  80099c:	e9 8c 00 00 00       	jmp    800a2d <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a1:	83 ec 08             	sub    $0x8,%esp
  8009a4:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a7:	ff 75 cc             	pushl  -0x34(%ebp)
  8009aa:	e8 62 03 00 00       	call   800d11 <strnlen>
  8009af:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009b2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	0f 8e a6 02 00 00    	jle    800c66 <vprintfmt+0x4af>
					putch(padc, putdat);
  8009c0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009c7:	89 cb                	mov    %ecx,%ebx
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	ff 75 0c             	pushl  0xc(%ebp)
  8009cf:	56                   	push   %esi
  8009d0:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	83 eb 01             	sub    $0x1,%ebx
  8009d8:	75 ef                	jne    8009c9 <vprintfmt+0x212>
  8009da:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e0:	e9 81 02 00 00       	jmp    800c66 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009e9:	74 1b                	je     800a06 <vprintfmt+0x24f>
  8009eb:	0f be c0             	movsbl %al,%eax
  8009ee:	83 e8 20             	sub    $0x20,%eax
  8009f1:	83 f8 5e             	cmp    $0x5e,%eax
  8009f4:	76 10                	jbe    800a06 <vprintfmt+0x24f>
					putch('?', putdat);
  8009f6:	83 ec 08             	sub    $0x8,%esp
  8009f9:	ff 75 0c             	pushl  0xc(%ebp)
  8009fc:	6a 3f                	push   $0x3f
  8009fe:	ff 55 08             	call   *0x8(%ebp)
  800a01:	83 c4 10             	add    $0x10,%esp
  800a04:	eb 0d                	jmp    800a13 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	ff 75 0c             	pushl  0xc(%ebp)
  800a0c:	52                   	push   %edx
  800a0d:	ff 55 08             	call   *0x8(%ebp)
  800a10:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a13:	83 ef 01             	sub    $0x1,%edi
  800a16:	83 c6 01             	add    $0x1,%esi
  800a19:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a1d:	0f be d0             	movsbl %al,%edx
  800a20:	85 d2                	test   %edx,%edx
  800a22:	75 31                	jne    800a55 <vprintfmt+0x29e>
  800a24:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a30:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a34:	7f 33                	jg     800a69 <vprintfmt+0x2b2>
  800a36:	e9 90 fd ff ff       	jmp    8007cb <vprintfmt+0x14>
  800a3b:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a41:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a44:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a47:	eb 0c                	jmp    800a55 <vprintfmt+0x29e>
  800a49:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a4f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a52:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a55:	85 db                	test   %ebx,%ebx
  800a57:	78 8c                	js     8009e5 <vprintfmt+0x22e>
  800a59:	83 eb 01             	sub    $0x1,%ebx
  800a5c:	79 87                	jns    8009e5 <vprintfmt+0x22e>
  800a5e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a61:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a67:	eb c4                	jmp    800a2d <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a69:	83 ec 08             	sub    $0x8,%esp
  800a6c:	53                   	push   %ebx
  800a6d:	6a 20                	push   $0x20
  800a6f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a71:	83 c4 10             	add    $0x10,%esp
  800a74:	83 ee 01             	sub    $0x1,%esi
  800a77:	75 f0                	jne    800a69 <vprintfmt+0x2b2>
  800a79:	e9 4d fd ff ff       	jmp    8007cb <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a7e:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800a82:	7e 16                	jle    800a9a <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800a84:	8b 45 14             	mov    0x14(%ebp),%eax
  800a87:	8d 50 08             	lea    0x8(%eax),%edx
  800a8a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8d:	8b 50 04             	mov    0x4(%eax),%edx
  800a90:	8b 00                	mov    (%eax),%eax
  800a92:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a95:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800a98:	eb 34                	jmp    800ace <vprintfmt+0x317>
	else if (lflag)
  800a9a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a9e:	74 18                	je     800ab8 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8d 50 04             	lea    0x4(%eax),%edx
  800aa6:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa9:	8b 30                	mov    (%eax),%esi
  800aab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800aae:	89 f0                	mov    %esi,%eax
  800ab0:	c1 f8 1f             	sar    $0x1f,%eax
  800ab3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ab6:	eb 16                	jmp    800ace <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  800abb:	8d 50 04             	lea    0x4(%eax),%edx
  800abe:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac1:	8b 30                	mov    (%eax),%esi
  800ac3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	c1 f8 1f             	sar    $0x1f,%eax
  800acb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ace:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ad1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ad4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800ada:	85 d2                	test   %edx,%edx
  800adc:	79 28                	jns    800b06 <vprintfmt+0x34f>
				putch('-', putdat);
  800ade:	83 ec 08             	sub    $0x8,%esp
  800ae1:	53                   	push   %ebx
  800ae2:	6a 2d                	push   $0x2d
  800ae4:	ff d7                	call   *%edi
				num = -(long long) num;
  800ae6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ae9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800aec:	f7 d8                	neg    %eax
  800aee:	83 d2 00             	adc    $0x0,%edx
  800af1:	f7 da                	neg    %edx
  800af3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800af9:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800afc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b01:	e9 b2 00 00 00       	jmp    800bb8 <vprintfmt+0x401>
  800b06:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b0b:	85 c9                	test   %ecx,%ecx
  800b0d:	0f 84 a5 00 00 00    	je     800bb8 <vprintfmt+0x401>
				putch('+', putdat);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	53                   	push   %ebx
  800b17:	6a 2b                	push   $0x2b
  800b19:	ff d7                	call   *%edi
  800b1b:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b23:	e9 90 00 00 00       	jmp    800bb8 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b28:	85 c9                	test   %ecx,%ecx
  800b2a:	74 0b                	je     800b37 <vprintfmt+0x380>
				putch('+', putdat);
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	53                   	push   %ebx
  800b30:	6a 2b                	push   $0x2b
  800b32:	ff d7                	call   *%edi
  800b34:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b37:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b3a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3d:	e8 01 fc ff ff       	call   800743 <getuint>
  800b42:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b45:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b48:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b4d:	eb 69                	jmp    800bb8 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b4f:	83 ec 08             	sub    $0x8,%esp
  800b52:	53                   	push   %ebx
  800b53:	6a 30                	push   $0x30
  800b55:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b57:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b5a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5d:	e8 e1 fb ff ff       	call   800743 <getuint>
  800b62:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b65:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b68:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b6b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b70:	eb 46                	jmp    800bb8 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b72:	83 ec 08             	sub    $0x8,%esp
  800b75:	53                   	push   %ebx
  800b76:	6a 30                	push   $0x30
  800b78:	ff d7                	call   *%edi
			putch('x', putdat);
  800b7a:	83 c4 08             	add    $0x8,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	6a 78                	push   $0x78
  800b80:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b82:	8b 45 14             	mov    0x14(%ebp),%eax
  800b85:	8d 50 04             	lea    0x4(%eax),%edx
  800b88:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b8b:	8b 00                	mov    (%eax),%eax
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b95:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b98:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b9b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800ba0:	eb 16                	jmp    800bb8 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ba2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ba5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba8:	e8 96 fb ff ff       	call   800743 <getuint>
  800bad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bb0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bb3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bbf:	56                   	push   %esi
  800bc0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc3:	50                   	push   %eax
  800bc4:	ff 75 dc             	pushl  -0x24(%ebp)
  800bc7:	ff 75 d8             	pushl  -0x28(%ebp)
  800bca:	89 da                	mov    %ebx,%edx
  800bcc:	89 f8                	mov    %edi,%eax
  800bce:	e8 55 f9 ff ff       	call   800528 <printnum>
			break;
  800bd3:	83 c4 20             	add    $0x20,%esp
  800bd6:	e9 f0 fb ff ff       	jmp    8007cb <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800bdb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bde:	8d 50 04             	lea    0x4(%eax),%edx
  800be1:	89 55 14             	mov    %edx,0x14(%ebp)
  800be4:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800be6:	85 f6                	test   %esi,%esi
  800be8:	75 1a                	jne    800c04 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800bea:	83 ec 08             	sub    $0x8,%esp
  800bed:	68 d8 14 80 00       	push   $0x8014d8
  800bf2:	68 40 14 80 00       	push   $0x801440
  800bf7:	e8 18 f9 ff ff       	call   800514 <cprintf>
  800bfc:	83 c4 10             	add    $0x10,%esp
  800bff:	e9 c7 fb ff ff       	jmp    8007cb <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c04:	0f b6 03             	movzbl (%ebx),%eax
  800c07:	84 c0                	test   %al,%al
  800c09:	79 1f                	jns    800c2a <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c0b:	83 ec 08             	sub    $0x8,%esp
  800c0e:	68 10 15 80 00       	push   $0x801510
  800c13:	68 40 14 80 00       	push   $0x801440
  800c18:	e8 f7 f8 ff ff       	call   800514 <cprintf>
						*tmp = *(char *)putdat;
  800c1d:	0f b6 03             	movzbl (%ebx),%eax
  800c20:	88 06                	mov    %al,(%esi)
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	e9 a1 fb ff ff       	jmp    8007cb <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c2a:	88 06                	mov    %al,(%esi)
  800c2c:	e9 9a fb ff ff       	jmp    8007cb <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c31:	83 ec 08             	sub    $0x8,%esp
  800c34:	53                   	push   %ebx
  800c35:	52                   	push   %edx
  800c36:	ff d7                	call   *%edi
			break;
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	e9 8b fb ff ff       	jmp    8007cb <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c40:	83 ec 08             	sub    $0x8,%esp
  800c43:	53                   	push   %ebx
  800c44:	6a 25                	push   $0x25
  800c46:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c4f:	0f 84 73 fb ff ff    	je     8007c8 <vprintfmt+0x11>
  800c55:	83 ee 01             	sub    $0x1,%esi
  800c58:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c5c:	75 f7                	jne    800c55 <vprintfmt+0x49e>
  800c5e:	89 75 10             	mov    %esi,0x10(%ebp)
  800c61:	e9 65 fb ff ff       	jmp    8007cb <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c66:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c69:	8d 70 01             	lea    0x1(%eax),%esi
  800c6c:	0f b6 00             	movzbl (%eax),%eax
  800c6f:	0f be d0             	movsbl %al,%edx
  800c72:	85 d2                	test   %edx,%edx
  800c74:	0f 85 cf fd ff ff    	jne    800a49 <vprintfmt+0x292>
  800c7a:	e9 4c fb ff ff       	jmp    8007cb <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	83 ec 18             	sub    $0x18,%esp
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c93:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c96:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c9a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	74 26                	je     800cce <vsnprintf+0x47>
  800ca8:	85 d2                	test   %edx,%edx
  800caa:	7e 22                	jle    800cce <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cac:	ff 75 14             	pushl  0x14(%ebp)
  800caf:	ff 75 10             	pushl  0x10(%ebp)
  800cb2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cb5:	50                   	push   %eax
  800cb6:	68 7d 07 80 00       	push   $0x80077d
  800cbb:	e8 f7 fa ff ff       	call   8007b7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	eb 05                	jmp    800cd3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    

00800cd5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cdb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cde:	50                   	push   %eax
  800cdf:	ff 75 10             	pushl  0x10(%ebp)
  800ce2:	ff 75 0c             	pushl  0xc(%ebp)
  800ce5:	ff 75 08             	pushl  0x8(%ebp)
  800ce8:	e8 9a ff ff ff       	call   800c87 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf5:	80 3a 00             	cmpb   $0x0,(%edx)
  800cf8:	74 10                	je     800d0a <strlen+0x1b>
  800cfa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800cff:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d02:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d06:	75 f7                	jne    800cff <strlen+0x10>
  800d08:	eb 05                	jmp    800d0f <strlen+0x20>
  800d0a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	53                   	push   %ebx
  800d15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1b:	85 c9                	test   %ecx,%ecx
  800d1d:	74 1c                	je     800d3b <strnlen+0x2a>
  800d1f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d22:	74 1e                	je     800d42 <strnlen+0x31>
  800d24:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d29:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2b:	39 ca                	cmp    %ecx,%edx
  800d2d:	74 18                	je     800d47 <strnlen+0x36>
  800d2f:	83 c2 01             	add    $0x1,%edx
  800d32:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d37:	75 f0                	jne    800d29 <strnlen+0x18>
  800d39:	eb 0c                	jmp    800d47 <strnlen+0x36>
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d40:	eb 05                	jmp    800d47 <strnlen+0x36>
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d47:	5b                   	pop    %ebx
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	53                   	push   %ebx
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d54:	89 c2                	mov    %eax,%edx
  800d56:	83 c2 01             	add    $0x1,%edx
  800d59:	83 c1 01             	add    $0x1,%ecx
  800d5c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d60:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d63:	84 db                	test   %bl,%bl
  800d65:	75 ef                	jne    800d56 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d67:	5b                   	pop    %ebx
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	53                   	push   %ebx
  800d6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d71:	53                   	push   %ebx
  800d72:	e8 78 ff ff ff       	call   800cef <strlen>
  800d77:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d7a:	ff 75 0c             	pushl  0xc(%ebp)
  800d7d:	01 d8                	add    %ebx,%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 c5 ff ff ff       	call   800d4a <strcpy>
	return dst;
}
  800d85:	89 d8                	mov    %ebx,%eax
  800d87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	8b 75 08             	mov    0x8(%ebp),%esi
  800d94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d9a:	85 db                	test   %ebx,%ebx
  800d9c:	74 17                	je     800db5 <strncpy+0x29>
  800d9e:	01 f3                	add    %esi,%ebx
  800da0:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800da2:	83 c1 01             	add    $0x1,%ecx
  800da5:	0f b6 02             	movzbl (%edx),%eax
  800da8:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dab:	80 3a 01             	cmpb   $0x1,(%edx)
  800dae:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db1:	39 cb                	cmp    %ecx,%ebx
  800db3:	75 ed                	jne    800da2 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800db5:	89 f0                	mov    %esi,%eax
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc6:	8b 55 10             	mov    0x10(%ebp),%edx
  800dc9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dcb:	85 d2                	test   %edx,%edx
  800dcd:	74 35                	je     800e04 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800dcf:	89 d0                	mov    %edx,%eax
  800dd1:	83 e8 01             	sub    $0x1,%eax
  800dd4:	74 25                	je     800dfb <strlcpy+0x40>
  800dd6:	0f b6 0b             	movzbl (%ebx),%ecx
  800dd9:	84 c9                	test   %cl,%cl
  800ddb:	74 22                	je     800dff <strlcpy+0x44>
  800ddd:	8d 53 01             	lea    0x1(%ebx),%edx
  800de0:	01 c3                	add    %eax,%ebx
  800de2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800de4:	83 c0 01             	add    $0x1,%eax
  800de7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dea:	39 da                	cmp    %ebx,%edx
  800dec:	74 13                	je     800e01 <strlcpy+0x46>
  800dee:	83 c2 01             	add    $0x1,%edx
  800df1:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800df5:	84 c9                	test   %cl,%cl
  800df7:	75 eb                	jne    800de4 <strlcpy+0x29>
  800df9:	eb 06                	jmp    800e01 <strlcpy+0x46>
  800dfb:	89 f0                	mov    %esi,%eax
  800dfd:	eb 02                	jmp    800e01 <strlcpy+0x46>
  800dff:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e04:	29 f0                	sub    %esi,%eax
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e10:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e13:	0f b6 01             	movzbl (%ecx),%eax
  800e16:	84 c0                	test   %al,%al
  800e18:	74 15                	je     800e2f <strcmp+0x25>
  800e1a:	3a 02                	cmp    (%edx),%al
  800e1c:	75 11                	jne    800e2f <strcmp+0x25>
		p++, q++;
  800e1e:	83 c1 01             	add    $0x1,%ecx
  800e21:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e24:	0f b6 01             	movzbl (%ecx),%eax
  800e27:	84 c0                	test   %al,%al
  800e29:	74 04                	je     800e2f <strcmp+0x25>
  800e2b:	3a 02                	cmp    (%edx),%al
  800e2d:	74 ef                	je     800e1e <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e2f:	0f b6 c0             	movzbl %al,%eax
  800e32:	0f b6 12             	movzbl (%edx),%edx
  800e35:	29 d0                	sub    %edx,%eax
}
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e44:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e47:	85 f6                	test   %esi,%esi
  800e49:	74 29                	je     800e74 <strncmp+0x3b>
  800e4b:	0f b6 03             	movzbl (%ebx),%eax
  800e4e:	84 c0                	test   %al,%al
  800e50:	74 30                	je     800e82 <strncmp+0x49>
  800e52:	3a 02                	cmp    (%edx),%al
  800e54:	75 2c                	jne    800e82 <strncmp+0x49>
  800e56:	8d 43 01             	lea    0x1(%ebx),%eax
  800e59:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e5b:	89 c3                	mov    %eax,%ebx
  800e5d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e60:	39 c6                	cmp    %eax,%esi
  800e62:	74 17                	je     800e7b <strncmp+0x42>
  800e64:	0f b6 08             	movzbl (%eax),%ecx
  800e67:	84 c9                	test   %cl,%cl
  800e69:	74 17                	je     800e82 <strncmp+0x49>
  800e6b:	83 c0 01             	add    $0x1,%eax
  800e6e:	3a 0a                	cmp    (%edx),%cl
  800e70:	74 e9                	je     800e5b <strncmp+0x22>
  800e72:	eb 0e                	jmp    800e82 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e74:	b8 00 00 00 00       	mov    $0x0,%eax
  800e79:	eb 0f                	jmp    800e8a <strncmp+0x51>
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	eb 08                	jmp    800e8a <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e82:	0f b6 03             	movzbl (%ebx),%eax
  800e85:	0f b6 12             	movzbl (%edx),%edx
  800e88:	29 d0                	sub    %edx,%eax
}
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	53                   	push   %ebx
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800e98:	0f b6 10             	movzbl (%eax),%edx
  800e9b:	84 d2                	test   %dl,%dl
  800e9d:	74 1d                	je     800ebc <strchr+0x2e>
  800e9f:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ea1:	38 d3                	cmp    %dl,%bl
  800ea3:	75 06                	jne    800eab <strchr+0x1d>
  800ea5:	eb 1a                	jmp    800ec1 <strchr+0x33>
  800ea7:	38 ca                	cmp    %cl,%dl
  800ea9:	74 16                	je     800ec1 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eab:	83 c0 01             	add    $0x1,%eax
  800eae:	0f b6 10             	movzbl (%eax),%edx
  800eb1:	84 d2                	test   %dl,%dl
  800eb3:	75 f2                	jne    800ea7 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eba:	eb 05                	jmp    800ec1 <strchr+0x33>
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	53                   	push   %ebx
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ece:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ed1:	38 d3                	cmp    %dl,%bl
  800ed3:	74 14                	je     800ee9 <strfind+0x25>
  800ed5:	89 d1                	mov    %edx,%ecx
  800ed7:	84 db                	test   %bl,%bl
  800ed9:	74 0e                	je     800ee9 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800edb:	83 c0 01             	add    $0x1,%eax
  800ede:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ee1:	38 ca                	cmp    %cl,%dl
  800ee3:	74 04                	je     800ee9 <strfind+0x25>
  800ee5:	84 d2                	test   %dl,%dl
  800ee7:	75 f2                	jne    800edb <strfind+0x17>
			break;
	return (char *) s;
}
  800ee9:	5b                   	pop    %ebx
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ef5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ef8:	85 c9                	test   %ecx,%ecx
  800efa:	74 36                	je     800f32 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800efc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f02:	75 28                	jne    800f2c <memset+0x40>
  800f04:	f6 c1 03             	test   $0x3,%cl
  800f07:	75 23                	jne    800f2c <memset+0x40>
		c &= 0xFF;
  800f09:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f0d:	89 d3                	mov    %edx,%ebx
  800f0f:	c1 e3 08             	shl    $0x8,%ebx
  800f12:	89 d6                	mov    %edx,%esi
  800f14:	c1 e6 18             	shl    $0x18,%esi
  800f17:	89 d0                	mov    %edx,%eax
  800f19:	c1 e0 10             	shl    $0x10,%eax
  800f1c:	09 f0                	or     %esi,%eax
  800f1e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	09 d0                	or     %edx,%eax
  800f24:	c1 e9 02             	shr    $0x2,%ecx
  800f27:	fc                   	cld    
  800f28:	f3 ab                	rep stos %eax,%es:(%edi)
  800f2a:	eb 06                	jmp    800f32 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2f:	fc                   	cld    
  800f30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f32:	89 f8                	mov    %edi,%eax
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f47:	39 c6                	cmp    %eax,%esi
  800f49:	73 35                	jae    800f80 <memmove+0x47>
  800f4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f4e:	39 d0                	cmp    %edx,%eax
  800f50:	73 2e                	jae    800f80 <memmove+0x47>
		s += n;
		d += n;
  800f52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f55:	89 d6                	mov    %edx,%esi
  800f57:	09 fe                	or     %edi,%esi
  800f59:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f5f:	75 13                	jne    800f74 <memmove+0x3b>
  800f61:	f6 c1 03             	test   $0x3,%cl
  800f64:	75 0e                	jne    800f74 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f66:	83 ef 04             	sub    $0x4,%edi
  800f69:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f6c:	c1 e9 02             	shr    $0x2,%ecx
  800f6f:	fd                   	std    
  800f70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f72:	eb 09                	jmp    800f7d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f74:	83 ef 01             	sub    $0x1,%edi
  800f77:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f7a:	fd                   	std    
  800f7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f7d:	fc                   	cld    
  800f7e:	eb 1d                	jmp    800f9d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f80:	89 f2                	mov    %esi,%edx
  800f82:	09 c2                	or     %eax,%edx
  800f84:	f6 c2 03             	test   $0x3,%dl
  800f87:	75 0f                	jne    800f98 <memmove+0x5f>
  800f89:	f6 c1 03             	test   $0x3,%cl
  800f8c:	75 0a                	jne    800f98 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f8e:	c1 e9 02             	shr    $0x2,%ecx
  800f91:	89 c7                	mov    %eax,%edi
  800f93:	fc                   	cld    
  800f94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f96:	eb 05                	jmp    800f9d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f98:	89 c7                	mov    %eax,%edi
  800f9a:	fc                   	cld    
  800f9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fa4:	ff 75 10             	pushl  0x10(%ebp)
  800fa7:	ff 75 0c             	pushl  0xc(%ebp)
  800faa:	ff 75 08             	pushl  0x8(%ebp)
  800fad:	e8 87 ff ff ff       	call   800f39 <memmove>
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc0:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	74 39                	je     801000 <memcmp+0x4c>
  800fc7:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800fca:	0f b6 13             	movzbl (%ebx),%edx
  800fcd:	0f b6 0e             	movzbl (%esi),%ecx
  800fd0:	38 ca                	cmp    %cl,%dl
  800fd2:	75 17                	jne    800feb <memcmp+0x37>
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	eb 1a                	jmp    800ff5 <memcmp+0x41>
  800fdb:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800fe0:	83 c0 01             	add    $0x1,%eax
  800fe3:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800fe7:	38 ca                	cmp    %cl,%dl
  800fe9:	74 0a                	je     800ff5 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800feb:	0f b6 c2             	movzbl %dl,%eax
  800fee:	0f b6 c9             	movzbl %cl,%ecx
  800ff1:	29 c8                	sub    %ecx,%eax
  800ff3:	eb 10                	jmp    801005 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff5:	39 f8                	cmp    %edi,%eax
  800ff7:	75 e2                	jne    800fdb <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffe:	eb 05                	jmp    801005 <memcmp+0x51>
  801000:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	53                   	push   %ebx
  80100e:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801011:	89 d0                	mov    %edx,%eax
  801013:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801016:	39 c2                	cmp    %eax,%edx
  801018:	73 1d                	jae    801037 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80101a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80101e:	0f b6 0a             	movzbl (%edx),%ecx
  801021:	39 d9                	cmp    %ebx,%ecx
  801023:	75 09                	jne    80102e <memfind+0x24>
  801025:	eb 14                	jmp    80103b <memfind+0x31>
  801027:	0f b6 0a             	movzbl (%edx),%ecx
  80102a:	39 d9                	cmp    %ebx,%ecx
  80102c:	74 11                	je     80103f <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80102e:	83 c2 01             	add    $0x1,%edx
  801031:	39 d0                	cmp    %edx,%eax
  801033:	75 f2                	jne    801027 <memfind+0x1d>
  801035:	eb 0a                	jmp    801041 <memfind+0x37>
  801037:	89 d0                	mov    %edx,%eax
  801039:	eb 06                	jmp    801041 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	eb 02                	jmp    801041 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80103f:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801041:	5b                   	pop    %ebx
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	57                   	push   %edi
  801048:	56                   	push   %esi
  801049:	53                   	push   %ebx
  80104a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801050:	0f b6 01             	movzbl (%ecx),%eax
  801053:	3c 20                	cmp    $0x20,%al
  801055:	74 04                	je     80105b <strtol+0x17>
  801057:	3c 09                	cmp    $0x9,%al
  801059:	75 0e                	jne    801069 <strtol+0x25>
		s++;
  80105b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80105e:	0f b6 01             	movzbl (%ecx),%eax
  801061:	3c 20                	cmp    $0x20,%al
  801063:	74 f6                	je     80105b <strtol+0x17>
  801065:	3c 09                	cmp    $0x9,%al
  801067:	74 f2                	je     80105b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801069:	3c 2b                	cmp    $0x2b,%al
  80106b:	75 0a                	jne    801077 <strtol+0x33>
		s++;
  80106d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801070:	bf 00 00 00 00       	mov    $0x0,%edi
  801075:	eb 11                	jmp    801088 <strtol+0x44>
  801077:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80107c:	3c 2d                	cmp    $0x2d,%al
  80107e:	75 08                	jne    801088 <strtol+0x44>
		s++, neg = 1;
  801080:	83 c1 01             	add    $0x1,%ecx
  801083:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801088:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80108e:	75 15                	jne    8010a5 <strtol+0x61>
  801090:	80 39 30             	cmpb   $0x30,(%ecx)
  801093:	75 10                	jne    8010a5 <strtol+0x61>
  801095:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801099:	75 7c                	jne    801117 <strtol+0xd3>
		s += 2, base = 16;
  80109b:	83 c1 02             	add    $0x2,%ecx
  80109e:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010a3:	eb 16                	jmp    8010bb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010a5:	85 db                	test   %ebx,%ebx
  8010a7:	75 12                	jne    8010bb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010a9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8010b1:	75 08                	jne    8010bb <strtol+0x77>
		s++, base = 8;
  8010b3:	83 c1 01             	add    $0x1,%ecx
  8010b6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010c3:	0f b6 11             	movzbl (%ecx),%edx
  8010c6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010c9:	89 f3                	mov    %esi,%ebx
  8010cb:	80 fb 09             	cmp    $0x9,%bl
  8010ce:	77 08                	ja     8010d8 <strtol+0x94>
			dig = *s - '0';
  8010d0:	0f be d2             	movsbl %dl,%edx
  8010d3:	83 ea 30             	sub    $0x30,%edx
  8010d6:	eb 22                	jmp    8010fa <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8010d8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010db:	89 f3                	mov    %esi,%ebx
  8010dd:	80 fb 19             	cmp    $0x19,%bl
  8010e0:	77 08                	ja     8010ea <strtol+0xa6>
			dig = *s - 'a' + 10;
  8010e2:	0f be d2             	movsbl %dl,%edx
  8010e5:	83 ea 57             	sub    $0x57,%edx
  8010e8:	eb 10                	jmp    8010fa <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  8010ea:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010ed:	89 f3                	mov    %esi,%ebx
  8010ef:	80 fb 19             	cmp    $0x19,%bl
  8010f2:	77 16                	ja     80110a <strtol+0xc6>
			dig = *s - 'A' + 10;
  8010f4:	0f be d2             	movsbl %dl,%edx
  8010f7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8010fa:	3b 55 10             	cmp    0x10(%ebp),%edx
  8010fd:	7d 0b                	jge    80110a <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  8010ff:	83 c1 01             	add    $0x1,%ecx
  801102:	0f af 45 10          	imul   0x10(%ebp),%eax
  801106:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801108:	eb b9                	jmp    8010c3 <strtol+0x7f>

	if (endptr)
  80110a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80110e:	74 0d                	je     80111d <strtol+0xd9>
		*endptr = (char *) s;
  801110:	8b 75 0c             	mov    0xc(%ebp),%esi
  801113:	89 0e                	mov    %ecx,(%esi)
  801115:	eb 06                	jmp    80111d <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801117:	85 db                	test   %ebx,%ebx
  801119:	74 98                	je     8010b3 <strtol+0x6f>
  80111b:	eb 9e                	jmp    8010bb <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80111d:	89 c2                	mov    %eax,%edx
  80111f:	f7 da                	neg    %edx
  801121:	85 ff                	test   %edi,%edi
  801123:	0f 45 c2             	cmovne %edx,%eax
}
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    
  80112b:	66 90                	xchg   %ax,%ax
  80112d:	66 90                	xchg   %ax,%ax
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
