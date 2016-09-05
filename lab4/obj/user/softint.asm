
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
  8000a9:	56                   	push   %esi
  8000aa:	57                   	push   %edi
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	8d 35 b6 00 80 00    	lea    0x8000b6,%esi
  8000b4:	0f 34                	sysenter 

008000b6 <label_21>:
  8000b6:	89 ec                	mov    %ebp,%esp
  8000b8:	5d                   	pop    %ebp
  8000b9:	5f                   	pop    %edi
  8000ba:	5e                   	pop    %esi
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
  8000da:	56                   	push   %esi
  8000db:	57                   	push   %edi
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	8d 35 e7 00 80 00    	lea    0x8000e7,%esi
  8000e5:	0f 34                	sysenter 

008000e7 <label_55>:
  8000e7:	89 ec                	mov    %ebp,%esp
  8000e9:	5d                   	pop    %ebp
  8000ea:	5f                   	pop    %edi
  8000eb:	5e                   	pop    %esi
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
  80010c:	56                   	push   %esi
  80010d:	57                   	push   %edi
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	8d 35 19 01 80 00    	lea    0x800119,%esi
  800117:	0f 34                	sysenter 

00800119 <label_90>:
  800119:	89 ec                	mov    %ebp,%esp
  80011b:	5d                   	pop    %ebp
  80011c:	5f                   	pop    %edi
  80011d:	5e                   	pop    %esi
  80011e:	5b                   	pop    %ebx
  80011f:	5a                   	pop    %edx
  800120:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	7e 17                	jle    80013c <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	50                   	push   %eax
  800129:	6a 03                	push   $0x3
  80012b:	68 ea 13 80 00       	push   $0x8013ea
  800130:	6a 30                	push   $0x30
  800132:	68 07 14 80 00       	push   $0x801407
  800137:	e8 06 03 00 00       	call   800442 <_panic>

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
  80015b:	56                   	push   %esi
  80015c:	57                   	push   %edi
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	8d 35 68 01 80 00    	lea    0x800168,%esi
  800166:	0f 34                	sysenter 

00800168 <label_139>:
  800168:	89 ec                	mov    %ebp,%esp
  80016a:	5d                   	pop    %ebp
  80016b:	5f                   	pop    %edi
  80016c:	5e                   	pop    %esi
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
  80018e:	56                   	push   %esi
  80018f:	57                   	push   %edi
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	8d 35 9b 01 80 00    	lea    0x80019b,%esi
  800199:	0f 34                	sysenter 

0080019b <label_174>:
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	5f                   	pop    %edi
  80019f:	5e                   	pop    %esi
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
  8001bf:	56                   	push   %esi
  8001c0:	57                   	push   %edi
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	8d 35 cc 01 80 00    	lea    0x8001cc,%esi
  8001ca:	0f 34                	sysenter 

008001cc <label_209>:
  8001cc:	89 ec                	mov    %ebp,%esp
  8001ce:	5d                   	pop    %ebp
  8001cf:	5f                   	pop    %edi
  8001d0:	5e                   	pop    %esi
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
  8001f3:	56                   	push   %esi
  8001f4:	57                   	push   %edi
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	8d 35 00 02 80 00    	lea    0x800200,%esi
  8001fe:	0f 34                	sysenter 

00800200 <label_244>:
  800200:	89 ec                	mov    %ebp,%esp
  800202:	5d                   	pop    %ebp
  800203:	5f                   	pop    %edi
  800204:	5e                   	pop    %esi
  800205:	5b                   	pop    %ebx
  800206:	5a                   	pop    %edx
  800207:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800208:	85 c0                	test   %eax,%eax
  80020a:	7e 17                	jle    800223 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	6a 05                	push   $0x5
  800212:	68 ea 13 80 00       	push   $0x8013ea
  800217:	6a 30                	push   $0x30
  800219:	68 07 14 80 00       	push   $0x801407
  80021e:	e8 1f 02 00 00       	call   800442 <_panic>

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
  80022f:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023b:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  80023e:	8b 45 10             	mov    0x10(%ebp),%eax
  800241:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800244:	8b 45 14             	mov    0x14(%ebp),%eax
  800247:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  80024a:	8b 45 18             	mov    0x18(%ebp),%eax
  80024d:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800250:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800253:	b9 00 00 00 00       	mov    $0x0,%ecx
  800258:	b8 06 00 00 00       	mov    $0x6,%eax
  80025d:	89 cb                	mov    %ecx,%ebx
  80025f:	89 cf                	mov    %ecx,%edi
  800261:	51                   	push   %ecx
  800262:	52                   	push   %edx
  800263:	53                   	push   %ebx
  800264:	56                   	push   %esi
  800265:	57                   	push   %edi
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	8d 35 71 02 80 00    	lea    0x800271,%esi
  80026f:	0f 34                	sysenter 

00800271 <label_304>:
  800271:	89 ec                	mov    %ebp,%esp
  800273:	5d                   	pop    %ebp
  800274:	5f                   	pop    %edi
  800275:	5e                   	pop    %esi
  800276:	5b                   	pop    %ebx
  800277:	5a                   	pop    %edx
  800278:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800279:	85 c0                	test   %eax,%eax
  80027b:	7e 17                	jle    800294 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	50                   	push   %eax
  800281:	6a 06                	push   $0x6
  800283:	68 ea 13 80 00       	push   $0x8013ea
  800288:	6a 30                	push   $0x30
  80028a:	68 07 14 80 00       	push   $0x801407
  80028f:	e8 ae 01 00 00       	call   800442 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  800294:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	57                   	push   %edi
  80029f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002a0:	bf 00 00 00 00       	mov    $0x0,%edi
  8002a5:	b8 07 00 00 00       	mov    $0x7,%eax
  8002aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	89 fb                	mov    %edi,%ebx
  8002b2:	51                   	push   %ecx
  8002b3:	52                   	push   %edx
  8002b4:	53                   	push   %ebx
  8002b5:	56                   	push   %esi
  8002b6:	57                   	push   %edi
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	8d 35 c2 02 80 00    	lea    0x8002c2,%esi
  8002c0:	0f 34                	sysenter 

008002c2 <label_353>:
  8002c2:	89 ec                	mov    %ebp,%esp
  8002c4:	5d                   	pop    %ebp
  8002c5:	5f                   	pop    %edi
  8002c6:	5e                   	pop    %esi
  8002c7:	5b                   	pop    %ebx
  8002c8:	5a                   	pop    %edx
  8002c9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	7e 17                	jle    8002e5 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	50                   	push   %eax
  8002d2:	6a 07                	push   $0x7
  8002d4:	68 ea 13 80 00       	push   $0x8013ea
  8002d9:	6a 30                	push   $0x30
  8002db:	68 07 14 80 00       	push   $0x801407
  8002e0:	e8 5d 01 00 00       	call   800442 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002e8:	5b                   	pop    %ebx
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	57                   	push   %edi
  8002f0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002f6:	b8 09 00 00 00       	mov    $0x9,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	89 fb                	mov    %edi,%ebx
  800303:	51                   	push   %ecx
  800304:	52                   	push   %edx
  800305:	53                   	push   %ebx
  800306:	56                   	push   %esi
  800307:	57                   	push   %edi
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	8d 35 13 03 80 00    	lea    0x800313,%esi
  800311:	0f 34                	sysenter 

00800313 <label_402>:
  800313:	89 ec                	mov    %ebp,%esp
  800315:	5d                   	pop    %ebp
  800316:	5f                   	pop    %edi
  800317:	5e                   	pop    %esi
  800318:	5b                   	pop    %ebx
  800319:	5a                   	pop    %edx
  80031a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80031b:	85 c0                	test   %eax,%eax
  80031d:	7e 17                	jle    800336 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	50                   	push   %eax
  800323:	6a 09                	push   $0x9
  800325:	68 ea 13 80 00       	push   $0x8013ea
  80032a:	6a 30                	push   $0x30
  80032c:	68 07 14 80 00       	push   $0x801407
  800331:	e8 0c 01 00 00       	call   800442 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800336:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800339:	5b                   	pop    %ebx
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800342:	bf 00 00 00 00       	mov    $0x0,%edi
  800347:	b8 0a 00 00 00       	mov    $0xa,%eax
  80034c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 fb                	mov    %edi,%ebx
  800354:	51                   	push   %ecx
  800355:	52                   	push   %edx
  800356:	53                   	push   %ebx
  800357:	56                   	push   %esi
  800358:	57                   	push   %edi
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	8d 35 64 03 80 00    	lea    0x800364,%esi
  800362:	0f 34                	sysenter 

00800364 <label_451>:
  800364:	89 ec                	mov    %ebp,%esp
  800366:	5d                   	pop    %ebp
  800367:	5f                   	pop    %edi
  800368:	5e                   	pop    %esi
  800369:	5b                   	pop    %ebx
  80036a:	5a                   	pop    %edx
  80036b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80036c:	85 c0                	test   %eax,%eax
  80036e:	7e 17                	jle    800387 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	50                   	push   %eax
  800374:	6a 0a                	push   $0xa
  800376:	68 ea 13 80 00       	push   $0x8013ea
  80037b:	6a 30                	push   $0x30
  80037d:	68 07 14 80 00       	push   $0x801407
  800382:	e8 bb 00 00 00       	call   800442 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800387:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800393:	b8 0c 00 00 00       	mov    $0xc,%eax
  800398:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039b:	8b 55 08             	mov    0x8(%ebp),%edx
  80039e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003a4:	51                   	push   %ecx
  8003a5:	52                   	push   %edx
  8003a6:	53                   	push   %ebx
  8003a7:	56                   	push   %esi
  8003a8:	57                   	push   %edi
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	8d 35 b4 03 80 00    	lea    0x8003b4,%esi
  8003b2:	0f 34                	sysenter 

008003b4 <label_502>:
  8003b4:	89 ec                	mov    %ebp,%esp
  8003b6:	5d                   	pop    %ebp
  8003b7:	5f                   	pop    %edi
  8003b8:	5e                   	pop    %esi
  8003b9:	5b                   	pop    %ebx
  8003ba:	5a                   	pop    %edx
  8003bb:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003bc:	5b                   	pop    %ebx
  8003bd:	5f                   	pop    %edi
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    

008003c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	57                   	push   %edi
  8003c4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ca:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d2:	89 d9                	mov    %ebx,%ecx
  8003d4:	89 df                	mov    %ebx,%edi
  8003d6:	51                   	push   %ecx
  8003d7:	52                   	push   %edx
  8003d8:	53                   	push   %ebx
  8003d9:	56                   	push   %esi
  8003da:	57                   	push   %edi
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	8d 35 e6 03 80 00    	lea    0x8003e6,%esi
  8003e4:	0f 34                	sysenter 

008003e6 <label_537>:
  8003e6:	89 ec                	mov    %ebp,%esp
  8003e8:	5d                   	pop    %ebp
  8003e9:	5f                   	pop    %edi
  8003ea:	5e                   	pop    %esi
  8003eb:	5b                   	pop    %ebx
  8003ec:	5a                   	pop    %edx
  8003ed:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003ee:	85 c0                	test   %eax,%eax
  8003f0:	7e 17                	jle    800409 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f2:	83 ec 0c             	sub    $0xc,%esp
  8003f5:	50                   	push   %eax
  8003f6:	6a 0d                	push   $0xd
  8003f8:	68 ea 13 80 00       	push   $0x8013ea
  8003fd:	6a 30                	push   $0x30
  8003ff:	68 07 14 80 00       	push   $0x801407
  800404:	e8 39 00 00 00       	call   800442 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800409:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80040c:	5b                   	pop    %ebx
  80040d:	5f                   	pop    %edi
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	57                   	push   %edi
  800414:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80041f:	8b 55 08             	mov    0x8(%ebp),%edx
  800422:	89 cb                	mov    %ecx,%ebx
  800424:	89 cf                	mov    %ecx,%edi
  800426:	51                   	push   %ecx
  800427:	52                   	push   %edx
  800428:	53                   	push   %ebx
  800429:	56                   	push   %esi
  80042a:	57                   	push   %edi
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	8d 35 36 04 80 00    	lea    0x800436,%esi
  800434:	0f 34                	sysenter 

00800436 <label_586>:
  800436:	89 ec                	mov    %ebp,%esp
  800438:	5d                   	pop    %ebp
  800439:	5f                   	pop    %edi
  80043a:	5e                   	pop    %esi
  80043b:	5b                   	pop    %ebx
  80043c:	5a                   	pop    %edx
  80043d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80043e:	5b                   	pop    %ebx
  80043f:	5f                   	pop    %edi
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800447:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80044a:	a1 10 20 80 00       	mov    0x802010,%eax
  80044f:	85 c0                	test   %eax,%eax
  800451:	74 11                	je     800464 <_panic+0x22>
		cprintf("%s: ", argv0);
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	50                   	push   %eax
  800457:	68 15 14 80 00       	push   $0x801415
  80045c:	e8 d4 00 00 00       	call   800535 <cprintf>
  800461:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800464:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80046a:	e8 d4 fc ff ff       	call   800143 <sys_getenvid>
  80046f:	83 ec 0c             	sub    $0xc,%esp
  800472:	ff 75 0c             	pushl  0xc(%ebp)
  800475:	ff 75 08             	pushl  0x8(%ebp)
  800478:	56                   	push   %esi
  800479:	50                   	push   %eax
  80047a:	68 1c 14 80 00       	push   $0x80141c
  80047f:	e8 b1 00 00 00       	call   800535 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800484:	83 c4 18             	add    $0x18,%esp
  800487:	53                   	push   %ebx
  800488:	ff 75 10             	pushl  0x10(%ebp)
  80048b:	e8 54 00 00 00       	call   8004e4 <vcprintf>
	cprintf("\n");
  800490:	c7 04 24 1a 14 80 00 	movl   $0x80141a,(%esp)
  800497:	e8 99 00 00 00       	call   800535 <cprintf>
  80049c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80049f:	cc                   	int3   
  8004a0:	eb fd                	jmp    80049f <_panic+0x5d>

008004a2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 04             	sub    $0x4,%esp
  8004a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ac:	8b 13                	mov    (%ebx),%edx
  8004ae:	8d 42 01             	lea    0x1(%edx),%eax
  8004b1:	89 03                	mov    %eax,(%ebx)
  8004b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004bf:	75 1a                	jne    8004db <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	68 ff 00 00 00       	push   $0xff
  8004c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8004cc:	50                   	push   %eax
  8004cd:	e8 c0 fb ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  8004d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004d8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f4:	00 00 00 
	b.cnt = 0;
  8004f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	ff 75 08             	pushl  0x8(%ebp)
  800507:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80050d:	50                   	push   %eax
  80050e:	68 a2 04 80 00       	push   $0x8004a2
  800513:	e8 c0 02 00 00       	call   8007d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800521:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800527:	50                   	push   %eax
  800528:	e8 65 fb ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  80052d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800533:	c9                   	leave  
  800534:	c3                   	ret    

00800535 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80053e:	50                   	push   %eax
  80053f:	ff 75 08             	pushl  0x8(%ebp)
  800542:	e8 9d ff ff ff       	call   8004e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800547:	c9                   	leave  
  800548:	c3                   	ret    

00800549 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	57                   	push   %edi
  80054d:	56                   	push   %esi
  80054e:	53                   	push   %ebx
  80054f:	83 ec 1c             	sub    $0x1c,%esp
  800552:	89 c7                	mov    %eax,%edi
  800554:	89 d6                	mov    %edx,%esi
  800556:	8b 45 08             	mov    0x8(%ebp),%eax
  800559:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800562:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800565:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800569:	0f 85 bf 00 00 00    	jne    80062e <printnum+0xe5>
  80056f:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800575:	0f 8d de 00 00 00    	jge    800659 <printnum+0x110>
		judge_time_for_space = width;
  80057b:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800581:	e9 d3 00 00 00       	jmp    800659 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	85 db                	test   %ebx,%ebx
  80058b:	7f 37                	jg     8005c4 <printnum+0x7b>
  80058d:	e9 ea 00 00 00       	jmp    80067c <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800592:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800595:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	56                   	push   %esi
  80059e:	83 ec 04             	sub    $0x4,%esp
  8005a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8005a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8005a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ad:	e8 ce 0c 00 00       	call   801280 <__umoddi3>
  8005b2:	83 c4 14             	add    $0x14,%esp
  8005b5:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  8005bc:	50                   	push   %eax
  8005bd:	ff d7                	call   *%edi
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	eb 16                	jmp    8005da <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	ff 75 18             	pushl  0x18(%ebp)
  8005cb:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	83 eb 01             	sub    $0x1,%ebx
  8005d3:	75 ef                	jne    8005c4 <printnum+0x7b>
  8005d5:	e9 a2 00 00 00       	jmp    80067c <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005da:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005e0:	0f 85 76 01 00 00    	jne    80075c <printnum+0x213>
		while(num_of_space-- > 0)
  8005e6:	a1 04 20 80 00       	mov    0x802004,%eax
  8005eb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005ee:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005f4:	85 c0                	test   %eax,%eax
  8005f6:	7e 1d                	jle    800615 <printnum+0xcc>
			putch(' ', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	56                   	push   %esi
  8005fc:	6a 20                	push   $0x20
  8005fe:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800600:	a1 04 20 80 00       	mov    0x802004,%eax
  800605:	8d 50 ff             	lea    -0x1(%eax),%edx
  800608:	89 15 04 20 80 00    	mov    %edx,0x802004
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	85 c0                	test   %eax,%eax
  800613:	7f e3                	jg     8005f8 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800615:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80061c:	00 00 00 
		judge_time_for_space = 0;
  80061f:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800626:	00 00 00 
	}
}
  800629:	e9 2e 01 00 00       	jmp    80075c <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80062e:	8b 45 10             	mov    0x10(%ebp),%eax
  800631:	ba 00 00 00 00       	mov    $0x0,%edx
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800642:	83 fa 00             	cmp    $0x0,%edx
  800645:	0f 87 ba 00 00 00    	ja     800705 <printnum+0x1bc>
  80064b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80064e:	0f 83 b1 00 00 00    	jae    800705 <printnum+0x1bc>
  800654:	e9 2d ff ff ff       	jmp    800586 <printnum+0x3d>
  800659:	8b 45 10             	mov    0x10(%ebp),%eax
  80065c:	ba 00 00 00 00       	mov    $0x0,%edx
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800667:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066d:	83 fa 00             	cmp    $0x0,%edx
  800670:	77 37                	ja     8006a9 <printnum+0x160>
  800672:	3b 45 10             	cmp    0x10(%ebp),%eax
  800675:	73 32                	jae    8006a9 <printnum+0x160>
  800677:	e9 16 ff ff ff       	jmp    800592 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	56                   	push   %esi
  800680:	83 ec 04             	sub    $0x4,%esp
  800683:	ff 75 dc             	pushl  -0x24(%ebp)
  800686:	ff 75 d8             	pushl  -0x28(%ebp)
  800689:	ff 75 e4             	pushl  -0x1c(%ebp)
  80068c:	ff 75 e0             	pushl  -0x20(%ebp)
  80068f:	e8 ec 0b 00 00       	call   801280 <__umoddi3>
  800694:	83 c4 14             	add    $0x14,%esp
  800697:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  80069e:	50                   	push   %eax
  80069f:	ff d7                	call   *%edi
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	e9 b3 00 00 00       	jmp    80075c <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006a9:	83 ec 0c             	sub    $0xc,%esp
  8006ac:	ff 75 18             	pushl  0x18(%ebp)
  8006af:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006b2:	50                   	push   %eax
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8006bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8006bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c5:	e8 86 0a 00 00       	call   801150 <__udivdi3>
  8006ca:	83 c4 18             	add    $0x18,%esp
  8006cd:	52                   	push   %edx
  8006ce:	50                   	push   %eax
  8006cf:	89 f2                	mov    %esi,%edx
  8006d1:	89 f8                	mov    %edi,%eax
  8006d3:	e8 71 fe ff ff       	call   800549 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006d8:	83 c4 18             	add    $0x18,%esp
  8006db:	56                   	push   %esi
  8006dc:	83 ec 04             	sub    $0x4,%esp
  8006df:	ff 75 dc             	pushl  -0x24(%ebp)
  8006e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006eb:	e8 90 0b 00 00       	call   801280 <__umoddi3>
  8006f0:	83 c4 14             	add    $0x14,%esp
  8006f3:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  8006fa:	50                   	push   %eax
  8006fb:	ff d7                	call   *%edi
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	e9 d5 fe ff ff       	jmp    8005da <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800705:	83 ec 0c             	sub    $0xc,%esp
  800708:	ff 75 18             	pushl  0x18(%ebp)
  80070b:	83 eb 01             	sub    $0x1,%ebx
  80070e:	53                   	push   %ebx
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	ff 75 dc             	pushl  -0x24(%ebp)
  800718:	ff 75 d8             	pushl  -0x28(%ebp)
  80071b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071e:	ff 75 e0             	pushl  -0x20(%ebp)
  800721:	e8 2a 0a 00 00       	call   801150 <__udivdi3>
  800726:	83 c4 18             	add    $0x18,%esp
  800729:	52                   	push   %edx
  80072a:	50                   	push   %eax
  80072b:	89 f2                	mov    %esi,%edx
  80072d:	89 f8                	mov    %edi,%eax
  80072f:	e8 15 fe ff ff       	call   800549 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800734:	83 c4 18             	add    $0x18,%esp
  800737:	56                   	push   %esi
  800738:	83 ec 04             	sub    $0x4,%esp
  80073b:	ff 75 dc             	pushl  -0x24(%ebp)
  80073e:	ff 75 d8             	pushl  -0x28(%ebp)
  800741:	ff 75 e4             	pushl  -0x1c(%ebp)
  800744:	ff 75 e0             	pushl  -0x20(%ebp)
  800747:	e8 34 0b 00 00       	call   801280 <__umoddi3>
  80074c:	83 c4 14             	add    $0x14,%esp
  80074f:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  800756:	50                   	push   %eax
  800757:	ff d7                	call   *%edi
  800759:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80075c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075f:	5b                   	pop    %ebx
  800760:	5e                   	pop    %esi
  800761:	5f                   	pop    %edi
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800767:	83 fa 01             	cmp    $0x1,%edx
  80076a:	7e 0e                	jle    80077a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80076c:	8b 10                	mov    (%eax),%edx
  80076e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800771:	89 08                	mov    %ecx,(%eax)
  800773:	8b 02                	mov    (%edx),%eax
  800775:	8b 52 04             	mov    0x4(%edx),%edx
  800778:	eb 22                	jmp    80079c <getuint+0x38>
	else if (lflag)
  80077a:	85 d2                	test   %edx,%edx
  80077c:	74 10                	je     80078e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80077e:	8b 10                	mov    (%eax),%edx
  800780:	8d 4a 04             	lea    0x4(%edx),%ecx
  800783:	89 08                	mov    %ecx,(%eax)
  800785:	8b 02                	mov    (%edx),%eax
  800787:	ba 00 00 00 00       	mov    $0x0,%edx
  80078c:	eb 0e                	jmp    80079c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80078e:	8b 10                	mov    (%eax),%edx
  800790:	8d 4a 04             	lea    0x4(%edx),%ecx
  800793:	89 08                	mov    %ecx,(%eax)
  800795:	8b 02                	mov    (%edx),%eax
  800797:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007a4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007a8:	8b 10                	mov    (%eax),%edx
  8007aa:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ad:	73 0a                	jae    8007b9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007af:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007b2:	89 08                	mov    %ecx,(%eax)
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	88 02                	mov    %al,(%edx)
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007c1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007c4:	50                   	push   %eax
  8007c5:	ff 75 10             	pushl  0x10(%ebp)
  8007c8:	ff 75 0c             	pushl  0xc(%ebp)
  8007cb:	ff 75 08             	pushl  0x8(%ebp)
  8007ce:	e8 05 00 00 00       	call   8007d8 <vprintfmt>
	va_end(ap);
}
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	57                   	push   %edi
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	83 ec 2c             	sub    $0x2c,%esp
  8007e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e7:	eb 03                	jmp    8007ec <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e9:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ef:	8d 70 01             	lea    0x1(%eax),%esi
  8007f2:	0f b6 00             	movzbl (%eax),%eax
  8007f5:	83 f8 25             	cmp    $0x25,%eax
  8007f8:	74 27                	je     800821 <vprintfmt+0x49>
			if (ch == '\0')
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	75 0d                	jne    80080b <vprintfmt+0x33>
  8007fe:	e9 9d 04 00 00       	jmp    800ca0 <vprintfmt+0x4c8>
  800803:	85 c0                	test   %eax,%eax
  800805:	0f 84 95 04 00 00    	je     800ca0 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	53                   	push   %ebx
  80080f:	50                   	push   %eax
  800810:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800812:	83 c6 01             	add    $0x1,%esi
  800815:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	83 f8 25             	cmp    $0x25,%eax
  80081f:	75 e2                	jne    800803 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800821:	b9 00 00 00 00       	mov    $0x0,%ecx
  800826:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80082a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800831:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800838:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80083f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800846:	eb 08                	jmp    800850 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800848:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80084b:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800850:	8d 46 01             	lea    0x1(%esi),%eax
  800853:	89 45 10             	mov    %eax,0x10(%ebp)
  800856:	0f b6 06             	movzbl (%esi),%eax
  800859:	0f b6 d0             	movzbl %al,%edx
  80085c:	83 e8 23             	sub    $0x23,%eax
  80085f:	3c 55                	cmp    $0x55,%al
  800861:	0f 87 fa 03 00 00    	ja     800c61 <vprintfmt+0x489>
  800867:	0f b6 c0             	movzbl %al,%eax
  80086a:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  800871:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800874:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800878:	eb d6                	jmp    800850 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80087a:	8d 42 d0             	lea    -0x30(%edx),%eax
  80087d:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800880:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800884:	8d 50 d0             	lea    -0x30(%eax),%edx
  800887:	83 fa 09             	cmp    $0x9,%edx
  80088a:	77 6b                	ja     8008f7 <vprintfmt+0x11f>
  80088c:	8b 75 10             	mov    0x10(%ebp),%esi
  80088f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800892:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800895:	eb 09                	jmp    8008a0 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800897:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80089a:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80089e:	eb b0                	jmp    800850 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a0:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008a3:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008a6:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008aa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008ad:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008b0:	83 f9 09             	cmp    $0x9,%ecx
  8008b3:	76 eb                	jbe    8008a0 <vprintfmt+0xc8>
  8008b5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008b8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008bb:	eb 3d                	jmp    8008fa <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 50 04             	lea    0x4(%eax),%edx
  8008c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c6:	8b 00                	mov    (%eax),%eax
  8008c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cb:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ce:	eb 2a                	jmp    8008fa <vprintfmt+0x122>
  8008d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008da:	0f 49 d0             	cmovns %eax,%edx
  8008dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e0:	8b 75 10             	mov    0x10(%ebp),%esi
  8008e3:	e9 68 ff ff ff       	jmp    800850 <vprintfmt+0x78>
  8008e8:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008eb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008f2:	e9 59 ff ff ff       	jmp    800850 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f7:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008fe:	0f 89 4c ff ff ff    	jns    800850 <vprintfmt+0x78>
				width = precision, precision = -1;
  800904:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800907:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80090a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800911:	e9 3a ff ff ff       	jmp    800850 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800916:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80091d:	e9 2e ff ff ff       	jmp    800850 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8d 50 04             	lea    0x4(%eax),%edx
  800928:	89 55 14             	mov    %edx,0x14(%ebp)
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	ff 30                	pushl  (%eax)
  800931:	ff d7                	call   *%edi
			break;
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	e9 b1 fe ff ff       	jmp    8007ec <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80093b:	8b 45 14             	mov    0x14(%ebp),%eax
  80093e:	8d 50 04             	lea    0x4(%eax),%edx
  800941:	89 55 14             	mov    %edx,0x14(%ebp)
  800944:	8b 00                	mov    (%eax),%eax
  800946:	99                   	cltd   
  800947:	31 d0                	xor    %edx,%eax
  800949:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094b:	83 f8 08             	cmp    $0x8,%eax
  80094e:	7f 0b                	jg     80095b <vprintfmt+0x183>
  800950:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  800957:	85 d2                	test   %edx,%edx
  800959:	75 15                	jne    800970 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80095b:	50                   	push   %eax
  80095c:	68 57 14 80 00       	push   $0x801457
  800961:	53                   	push   %ebx
  800962:	57                   	push   %edi
  800963:	e8 53 fe ff ff       	call   8007bb <printfmt>
  800968:	83 c4 10             	add    $0x10,%esp
  80096b:	e9 7c fe ff ff       	jmp    8007ec <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800970:	52                   	push   %edx
  800971:	68 60 14 80 00       	push   $0x801460
  800976:	53                   	push   %ebx
  800977:	57                   	push   %edi
  800978:	e8 3e fe ff ff       	call   8007bb <printfmt>
  80097d:	83 c4 10             	add    $0x10,%esp
  800980:	e9 67 fe ff ff       	jmp    8007ec <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8d 50 04             	lea    0x4(%eax),%edx
  80098b:	89 55 14             	mov    %edx,0x14(%ebp)
  80098e:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800990:	85 c0                	test   %eax,%eax
  800992:	b9 50 14 80 00       	mov    $0x801450,%ecx
  800997:	0f 45 c8             	cmovne %eax,%ecx
  80099a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80099d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009a1:	7e 06                	jle    8009a9 <vprintfmt+0x1d1>
  8009a3:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009a7:	75 19                	jne    8009c2 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009ac:	8d 70 01             	lea    0x1(%eax),%esi
  8009af:	0f b6 00             	movzbl (%eax),%eax
  8009b2:	0f be d0             	movsbl %al,%edx
  8009b5:	85 d2                	test   %edx,%edx
  8009b7:	0f 85 9f 00 00 00    	jne    800a5c <vprintfmt+0x284>
  8009bd:	e9 8c 00 00 00       	jmp    800a4e <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	ff 75 d0             	pushl  -0x30(%ebp)
  8009c8:	ff 75 cc             	pushl  -0x34(%ebp)
  8009cb:	e8 62 03 00 00       	call   800d32 <strnlen>
  8009d0:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009d6:	83 c4 10             	add    $0x10,%esp
  8009d9:	85 c9                	test   %ecx,%ecx
  8009db:	0f 8e a6 02 00 00    	jle    800c87 <vprintfmt+0x4af>
					putch(padc, putdat);
  8009e1:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009e8:	89 cb                	mov    %ecx,%ebx
  8009ea:	83 ec 08             	sub    $0x8,%esp
  8009ed:	ff 75 0c             	pushl  0xc(%ebp)
  8009f0:	56                   	push   %esi
  8009f1:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f3:	83 c4 10             	add    $0x10,%esp
  8009f6:	83 eb 01             	sub    $0x1,%ebx
  8009f9:	75 ef                	jne    8009ea <vprintfmt+0x212>
  8009fb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a01:	e9 81 02 00 00       	jmp    800c87 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a06:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a0a:	74 1b                	je     800a27 <vprintfmt+0x24f>
  800a0c:	0f be c0             	movsbl %al,%eax
  800a0f:	83 e8 20             	sub    $0x20,%eax
  800a12:	83 f8 5e             	cmp    $0x5e,%eax
  800a15:	76 10                	jbe    800a27 <vprintfmt+0x24f>
					putch('?', putdat);
  800a17:	83 ec 08             	sub    $0x8,%esp
  800a1a:	ff 75 0c             	pushl  0xc(%ebp)
  800a1d:	6a 3f                	push   $0x3f
  800a1f:	ff 55 08             	call   *0x8(%ebp)
  800a22:	83 c4 10             	add    $0x10,%esp
  800a25:	eb 0d                	jmp    800a34 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a27:	83 ec 08             	sub    $0x8,%esp
  800a2a:	ff 75 0c             	pushl  0xc(%ebp)
  800a2d:	52                   	push   %edx
  800a2e:	ff 55 08             	call   *0x8(%ebp)
  800a31:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a34:	83 ef 01             	sub    $0x1,%edi
  800a37:	83 c6 01             	add    $0x1,%esi
  800a3a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a3e:	0f be d0             	movsbl %al,%edx
  800a41:	85 d2                	test   %edx,%edx
  800a43:	75 31                	jne    800a76 <vprintfmt+0x29e>
  800a45:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a48:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a4e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a51:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a55:	7f 33                	jg     800a8a <vprintfmt+0x2b2>
  800a57:	e9 90 fd ff ff       	jmp    8007ec <vprintfmt+0x14>
  800a5c:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a62:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a65:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a68:	eb 0c                	jmp    800a76 <vprintfmt+0x29e>
  800a6a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a70:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a73:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	78 8c                	js     800a06 <vprintfmt+0x22e>
  800a7a:	83 eb 01             	sub    $0x1,%ebx
  800a7d:	79 87                	jns    800a06 <vprintfmt+0x22e>
  800a7f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a82:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a88:	eb c4                	jmp    800a4e <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a8a:	83 ec 08             	sub    $0x8,%esp
  800a8d:	53                   	push   %ebx
  800a8e:	6a 20                	push   $0x20
  800a90:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	83 ee 01             	sub    $0x1,%esi
  800a98:	75 f0                	jne    800a8a <vprintfmt+0x2b2>
  800a9a:	e9 4d fd ff ff       	jmp    8007ec <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a9f:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800aa3:	7e 16                	jle    800abb <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa8:	8d 50 08             	lea    0x8(%eax),%edx
  800aab:	89 55 14             	mov    %edx,0x14(%ebp)
  800aae:	8b 50 04             	mov    0x4(%eax),%edx
  800ab1:	8b 00                	mov    (%eax),%eax
  800ab3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ab6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ab9:	eb 34                	jmp    800aef <vprintfmt+0x317>
	else if (lflag)
  800abb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800abf:	74 18                	je     800ad9 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ac1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac4:	8d 50 04             	lea    0x4(%eax),%edx
  800ac7:	89 55 14             	mov    %edx,0x14(%ebp)
  800aca:	8b 30                	mov    (%eax),%esi
  800acc:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800acf:	89 f0                	mov    %esi,%eax
  800ad1:	c1 f8 1f             	sar    $0x1f,%eax
  800ad4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ad7:	eb 16                	jmp    800aef <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ad9:	8b 45 14             	mov    0x14(%ebp),%eax
  800adc:	8d 50 04             	lea    0x4(%eax),%edx
  800adf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae2:	8b 30                	mov    (%eax),%esi
  800ae4:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ae7:	89 f0                	mov    %esi,%eax
  800ae9:	c1 f8 1f             	sar    $0x1f,%eax
  800aec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800aef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800af2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800af5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800afb:	85 d2                	test   %edx,%edx
  800afd:	79 28                	jns    800b27 <vprintfmt+0x34f>
				putch('-', putdat);
  800aff:	83 ec 08             	sub    $0x8,%esp
  800b02:	53                   	push   %ebx
  800b03:	6a 2d                	push   $0x2d
  800b05:	ff d7                	call   *%edi
				num = -(long long) num;
  800b07:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b0a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b0d:	f7 d8                	neg    %eax
  800b0f:	83 d2 00             	adc    $0x0,%edx
  800b12:	f7 da                	neg    %edx
  800b14:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b17:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b1a:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b22:	e9 b2 00 00 00       	jmp    800bd9 <vprintfmt+0x401>
  800b27:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b2c:	85 c9                	test   %ecx,%ecx
  800b2e:	0f 84 a5 00 00 00    	je     800bd9 <vprintfmt+0x401>
				putch('+', putdat);
  800b34:	83 ec 08             	sub    $0x8,%esp
  800b37:	53                   	push   %ebx
  800b38:	6a 2b                	push   $0x2b
  800b3a:	ff d7                	call   *%edi
  800b3c:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b44:	e9 90 00 00 00       	jmp    800bd9 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b49:	85 c9                	test   %ecx,%ecx
  800b4b:	74 0b                	je     800b58 <vprintfmt+0x380>
				putch('+', putdat);
  800b4d:	83 ec 08             	sub    $0x8,%esp
  800b50:	53                   	push   %ebx
  800b51:	6a 2b                	push   $0x2b
  800b53:	ff d7                	call   *%edi
  800b55:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b58:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5e:	e8 01 fc ff ff       	call   800764 <getuint>
  800b63:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b66:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b69:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b6e:	eb 69                	jmp    800bd9 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b70:	83 ec 08             	sub    $0x8,%esp
  800b73:	53                   	push   %ebx
  800b74:	6a 30                	push   $0x30
  800b76:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b78:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b7b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b7e:	e8 e1 fb ff ff       	call   800764 <getuint>
  800b83:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b86:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b89:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b8c:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b91:	eb 46                	jmp    800bd9 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b93:	83 ec 08             	sub    $0x8,%esp
  800b96:	53                   	push   %ebx
  800b97:	6a 30                	push   $0x30
  800b99:	ff d7                	call   *%edi
			putch('x', putdat);
  800b9b:	83 c4 08             	add    $0x8,%esp
  800b9e:	53                   	push   %ebx
  800b9f:	6a 78                	push   $0x78
  800ba1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ba3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba6:	8d 50 04             	lea    0x4(%eax),%edx
  800ba9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bac:	8b 00                	mov    (%eax),%eax
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bb6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bb9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bbc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bc1:	eb 16                	jmp    800bd9 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bc3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bc6:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc9:	e8 96 fb ff ff       	call   800764 <getuint>
  800bce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bd1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bd4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800be0:	56                   	push   %esi
  800be1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be4:	50                   	push   %eax
  800be5:	ff 75 dc             	pushl  -0x24(%ebp)
  800be8:	ff 75 d8             	pushl  -0x28(%ebp)
  800beb:	89 da                	mov    %ebx,%edx
  800bed:	89 f8                	mov    %edi,%eax
  800bef:	e8 55 f9 ff ff       	call   800549 <printnum>
			break;
  800bf4:	83 c4 20             	add    $0x20,%esp
  800bf7:	e9 f0 fb ff ff       	jmp    8007ec <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800bfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bff:	8d 50 04             	lea    0x4(%eax),%edx
  800c02:	89 55 14             	mov    %edx,0x14(%ebp)
  800c05:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c07:	85 f6                	test   %esi,%esi
  800c09:	75 1a                	jne    800c25 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c0b:	83 ec 08             	sub    $0x8,%esp
  800c0e:	68 f8 14 80 00       	push   $0x8014f8
  800c13:	68 60 14 80 00       	push   $0x801460
  800c18:	e8 18 f9 ff ff       	call   800535 <cprintf>
  800c1d:	83 c4 10             	add    $0x10,%esp
  800c20:	e9 c7 fb ff ff       	jmp    8007ec <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c25:	0f b6 03             	movzbl (%ebx),%eax
  800c28:	84 c0                	test   %al,%al
  800c2a:	79 1f                	jns    800c4b <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c2c:	83 ec 08             	sub    $0x8,%esp
  800c2f:	68 30 15 80 00       	push   $0x801530
  800c34:	68 60 14 80 00       	push   $0x801460
  800c39:	e8 f7 f8 ff ff       	call   800535 <cprintf>
						*tmp = *(char *)putdat;
  800c3e:	0f b6 03             	movzbl (%ebx),%eax
  800c41:	88 06                	mov    %al,(%esi)
  800c43:	83 c4 10             	add    $0x10,%esp
  800c46:	e9 a1 fb ff ff       	jmp    8007ec <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c4b:	88 06                	mov    %al,(%esi)
  800c4d:	e9 9a fb ff ff       	jmp    8007ec <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c52:	83 ec 08             	sub    $0x8,%esp
  800c55:	53                   	push   %ebx
  800c56:	52                   	push   %edx
  800c57:	ff d7                	call   *%edi
			break;
  800c59:	83 c4 10             	add    $0x10,%esp
  800c5c:	e9 8b fb ff ff       	jmp    8007ec <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c61:	83 ec 08             	sub    $0x8,%esp
  800c64:	53                   	push   %ebx
  800c65:	6a 25                	push   $0x25
  800c67:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c70:	0f 84 73 fb ff ff    	je     8007e9 <vprintfmt+0x11>
  800c76:	83 ee 01             	sub    $0x1,%esi
  800c79:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c7d:	75 f7                	jne    800c76 <vprintfmt+0x49e>
  800c7f:	89 75 10             	mov    %esi,0x10(%ebp)
  800c82:	e9 65 fb ff ff       	jmp    8007ec <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c87:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c8a:	8d 70 01             	lea    0x1(%eax),%esi
  800c8d:	0f b6 00             	movzbl (%eax),%eax
  800c90:	0f be d0             	movsbl %al,%edx
  800c93:	85 d2                	test   %edx,%edx
  800c95:	0f 85 cf fd ff ff    	jne    800a6a <vprintfmt+0x292>
  800c9b:	e9 4c fb ff ff       	jmp    8007ec <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 18             	sub    $0x18,%esp
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cb7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cbb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	74 26                	je     800cef <vsnprintf+0x47>
  800cc9:	85 d2                	test   %edx,%edx
  800ccb:	7e 22                	jle    800cef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ccd:	ff 75 14             	pushl  0x14(%ebp)
  800cd0:	ff 75 10             	pushl  0x10(%ebp)
  800cd3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cd6:	50                   	push   %eax
  800cd7:	68 9e 07 80 00       	push   $0x80079e
  800cdc:	e8 f7 fa ff ff       	call   8007d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ce1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cea:	83 c4 10             	add    $0x10,%esp
  800ced:	eb 05                	jmp    800cf4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cfc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cff:	50                   	push   %eax
  800d00:	ff 75 10             	pushl  0x10(%ebp)
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	ff 75 08             	pushl  0x8(%ebp)
  800d09:	e8 9a ff ff ff       	call   800ca8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d16:	80 3a 00             	cmpb   $0x0,(%edx)
  800d19:	74 10                	je     800d2b <strlen+0x1b>
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d27:	75 f7                	jne    800d20 <strlen+0x10>
  800d29:	eb 05                	jmp    800d30 <strlen+0x20>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	53                   	push   %ebx
  800d36:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d3c:	85 c9                	test   %ecx,%ecx
  800d3e:	74 1c                	je     800d5c <strnlen+0x2a>
  800d40:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d43:	74 1e                	je     800d63 <strnlen+0x31>
  800d45:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d4a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4c:	39 ca                	cmp    %ecx,%edx
  800d4e:	74 18                	je     800d68 <strnlen+0x36>
  800d50:	83 c2 01             	add    $0x1,%edx
  800d53:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d58:	75 f0                	jne    800d4a <strnlen+0x18>
  800d5a:	eb 0c                	jmp    800d68 <strnlen+0x36>
  800d5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d61:	eb 05                	jmp    800d68 <strnlen+0x36>
  800d63:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d68:	5b                   	pop    %ebx
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d75:	89 c2                	mov    %eax,%edx
  800d77:	83 c2 01             	add    $0x1,%edx
  800d7a:	83 c1 01             	add    $0x1,%ecx
  800d7d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d81:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d84:	84 db                	test   %bl,%bl
  800d86:	75 ef                	jne    800d77 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d88:	5b                   	pop    %ebx
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	53                   	push   %ebx
  800d8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d92:	53                   	push   %ebx
  800d93:	e8 78 ff ff ff       	call   800d10 <strlen>
  800d98:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d9b:	ff 75 0c             	pushl  0xc(%ebp)
  800d9e:	01 d8                	add    %ebx,%eax
  800da0:	50                   	push   %eax
  800da1:	e8 c5 ff ff ff       	call   800d6b <strcpy>
	return dst;
}
  800da6:	89 d8                	mov    %ebx,%eax
  800da8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    

00800dad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	8b 75 08             	mov    0x8(%ebp),%esi
  800db5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dbb:	85 db                	test   %ebx,%ebx
  800dbd:	74 17                	je     800dd6 <strncpy+0x29>
  800dbf:	01 f3                	add    %esi,%ebx
  800dc1:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dc3:	83 c1 01             	add    $0x1,%ecx
  800dc6:	0f b6 02             	movzbl (%edx),%eax
  800dc9:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dcc:	80 3a 01             	cmpb   $0x1,(%edx)
  800dcf:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dd2:	39 cb                	cmp    %ecx,%ebx
  800dd4:	75 ed                	jne    800dc3 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dd6:	89 f0                	mov    %esi,%eax
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
  800de1:	8b 75 08             	mov    0x8(%ebp),%esi
  800de4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800de7:	8b 55 10             	mov    0x10(%ebp),%edx
  800dea:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dec:	85 d2                	test   %edx,%edx
  800dee:	74 35                	je     800e25 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800df0:	89 d0                	mov    %edx,%eax
  800df2:	83 e8 01             	sub    $0x1,%eax
  800df5:	74 25                	je     800e1c <strlcpy+0x40>
  800df7:	0f b6 0b             	movzbl (%ebx),%ecx
  800dfa:	84 c9                	test   %cl,%cl
  800dfc:	74 22                	je     800e20 <strlcpy+0x44>
  800dfe:	8d 53 01             	lea    0x1(%ebx),%edx
  800e01:	01 c3                	add    %eax,%ebx
  800e03:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e05:	83 c0 01             	add    $0x1,%eax
  800e08:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e0b:	39 da                	cmp    %ebx,%edx
  800e0d:	74 13                	je     800e22 <strlcpy+0x46>
  800e0f:	83 c2 01             	add    $0x1,%edx
  800e12:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e16:	84 c9                	test   %cl,%cl
  800e18:	75 eb                	jne    800e05 <strlcpy+0x29>
  800e1a:	eb 06                	jmp    800e22 <strlcpy+0x46>
  800e1c:	89 f0                	mov    %esi,%eax
  800e1e:	eb 02                	jmp    800e22 <strlcpy+0x46>
  800e20:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e22:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e25:	29 f0                	sub    %esi,%eax
}
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e31:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e34:	0f b6 01             	movzbl (%ecx),%eax
  800e37:	84 c0                	test   %al,%al
  800e39:	74 15                	je     800e50 <strcmp+0x25>
  800e3b:	3a 02                	cmp    (%edx),%al
  800e3d:	75 11                	jne    800e50 <strcmp+0x25>
		p++, q++;
  800e3f:	83 c1 01             	add    $0x1,%ecx
  800e42:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e45:	0f b6 01             	movzbl (%ecx),%eax
  800e48:	84 c0                	test   %al,%al
  800e4a:	74 04                	je     800e50 <strcmp+0x25>
  800e4c:	3a 02                	cmp    (%edx),%al
  800e4e:	74 ef                	je     800e3f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e50:	0f b6 c0             	movzbl %al,%eax
  800e53:	0f b6 12             	movzbl (%edx),%edx
  800e56:	29 d0                	sub    %edx,%eax
}
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e65:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e68:	85 f6                	test   %esi,%esi
  800e6a:	74 29                	je     800e95 <strncmp+0x3b>
  800e6c:	0f b6 03             	movzbl (%ebx),%eax
  800e6f:	84 c0                	test   %al,%al
  800e71:	74 30                	je     800ea3 <strncmp+0x49>
  800e73:	3a 02                	cmp    (%edx),%al
  800e75:	75 2c                	jne    800ea3 <strncmp+0x49>
  800e77:	8d 43 01             	lea    0x1(%ebx),%eax
  800e7a:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e7c:	89 c3                	mov    %eax,%ebx
  800e7e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e81:	39 c6                	cmp    %eax,%esi
  800e83:	74 17                	je     800e9c <strncmp+0x42>
  800e85:	0f b6 08             	movzbl (%eax),%ecx
  800e88:	84 c9                	test   %cl,%cl
  800e8a:	74 17                	je     800ea3 <strncmp+0x49>
  800e8c:	83 c0 01             	add    $0x1,%eax
  800e8f:	3a 0a                	cmp    (%edx),%cl
  800e91:	74 e9                	je     800e7c <strncmp+0x22>
  800e93:	eb 0e                	jmp    800ea3 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	eb 0f                	jmp    800eab <strncmp+0x51>
  800e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea1:	eb 08                	jmp    800eab <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ea3:	0f b6 03             	movzbl (%ebx),%eax
  800ea6:	0f b6 12             	movzbl (%edx),%edx
  800ea9:	29 d0                	sub    %edx,%eax
}
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	53                   	push   %ebx
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800eb9:	0f b6 10             	movzbl (%eax),%edx
  800ebc:	84 d2                	test   %dl,%dl
  800ebe:	74 1d                	je     800edd <strchr+0x2e>
  800ec0:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ec2:	38 d3                	cmp    %dl,%bl
  800ec4:	75 06                	jne    800ecc <strchr+0x1d>
  800ec6:	eb 1a                	jmp    800ee2 <strchr+0x33>
  800ec8:	38 ca                	cmp    %cl,%dl
  800eca:	74 16                	je     800ee2 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ecc:	83 c0 01             	add    $0x1,%eax
  800ecf:	0f b6 10             	movzbl (%eax),%edx
  800ed2:	84 d2                	test   %dl,%dl
  800ed4:	75 f2                	jne    800ec8 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  800edb:	eb 05                	jmp    800ee2 <strchr+0x33>
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee2:	5b                   	pop    %ebx
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	53                   	push   %ebx
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800eef:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ef2:	38 d3                	cmp    %dl,%bl
  800ef4:	74 14                	je     800f0a <strfind+0x25>
  800ef6:	89 d1                	mov    %edx,%ecx
  800ef8:	84 db                	test   %bl,%bl
  800efa:	74 0e                	je     800f0a <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800efc:	83 c0 01             	add    $0x1,%eax
  800eff:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f02:	38 ca                	cmp    %cl,%dl
  800f04:	74 04                	je     800f0a <strfind+0x25>
  800f06:	84 d2                	test   %dl,%dl
  800f08:	75 f2                	jne    800efc <strfind+0x17>
			break;
	return (char *) s;
}
  800f0a:	5b                   	pop    %ebx
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f19:	85 c9                	test   %ecx,%ecx
  800f1b:	74 36                	je     800f53 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f23:	75 28                	jne    800f4d <memset+0x40>
  800f25:	f6 c1 03             	test   $0x3,%cl
  800f28:	75 23                	jne    800f4d <memset+0x40>
		c &= 0xFF;
  800f2a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f2e:	89 d3                	mov    %edx,%ebx
  800f30:	c1 e3 08             	shl    $0x8,%ebx
  800f33:	89 d6                	mov    %edx,%esi
  800f35:	c1 e6 18             	shl    $0x18,%esi
  800f38:	89 d0                	mov    %edx,%eax
  800f3a:	c1 e0 10             	shl    $0x10,%eax
  800f3d:	09 f0                	or     %esi,%eax
  800f3f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	09 d0                	or     %edx,%eax
  800f45:	c1 e9 02             	shr    $0x2,%ecx
  800f48:	fc                   	cld    
  800f49:	f3 ab                	rep stos %eax,%es:(%edi)
  800f4b:	eb 06                	jmp    800f53 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f50:	fc                   	cld    
  800f51:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f53:	89 f8                	mov    %edi,%eax
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f68:	39 c6                	cmp    %eax,%esi
  800f6a:	73 35                	jae    800fa1 <memmove+0x47>
  800f6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f6f:	39 d0                	cmp    %edx,%eax
  800f71:	73 2e                	jae    800fa1 <memmove+0x47>
		s += n;
		d += n;
  800f73:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f76:	89 d6                	mov    %edx,%esi
  800f78:	09 fe                	or     %edi,%esi
  800f7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f80:	75 13                	jne    800f95 <memmove+0x3b>
  800f82:	f6 c1 03             	test   $0x3,%cl
  800f85:	75 0e                	jne    800f95 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f87:	83 ef 04             	sub    $0x4,%edi
  800f8a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f8d:	c1 e9 02             	shr    $0x2,%ecx
  800f90:	fd                   	std    
  800f91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f93:	eb 09                	jmp    800f9e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f95:	83 ef 01             	sub    $0x1,%edi
  800f98:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f9b:	fd                   	std    
  800f9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f9e:	fc                   	cld    
  800f9f:	eb 1d                	jmp    800fbe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa1:	89 f2                	mov    %esi,%edx
  800fa3:	09 c2                	or     %eax,%edx
  800fa5:	f6 c2 03             	test   $0x3,%dl
  800fa8:	75 0f                	jne    800fb9 <memmove+0x5f>
  800faa:	f6 c1 03             	test   $0x3,%cl
  800fad:	75 0a                	jne    800fb9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800faf:	c1 e9 02             	shr    $0x2,%ecx
  800fb2:	89 c7                	mov    %eax,%edi
  800fb4:	fc                   	cld    
  800fb5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fb7:	eb 05                	jmp    800fbe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fb9:	89 c7                	mov    %eax,%edi
  800fbb:	fc                   	cld    
  800fbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fc5:	ff 75 10             	pushl  0x10(%ebp)
  800fc8:	ff 75 0c             	pushl  0xc(%ebp)
  800fcb:	ff 75 08             	pushl  0x8(%ebp)
  800fce:	e8 87 ff ff ff       	call   800f5a <memmove>
}
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	57                   	push   %edi
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
  800fdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fe1:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	74 39                	je     801021 <memcmp+0x4c>
  800fe8:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800feb:	0f b6 13             	movzbl (%ebx),%edx
  800fee:	0f b6 0e             	movzbl (%esi),%ecx
  800ff1:	38 ca                	cmp    %cl,%dl
  800ff3:	75 17                	jne    80100c <memcmp+0x37>
  800ff5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffa:	eb 1a                	jmp    801016 <memcmp+0x41>
  800ffc:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  801001:	83 c0 01             	add    $0x1,%eax
  801004:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  801008:	38 ca                	cmp    %cl,%dl
  80100a:	74 0a                	je     801016 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  80100c:	0f b6 c2             	movzbl %dl,%eax
  80100f:	0f b6 c9             	movzbl %cl,%ecx
  801012:	29 c8                	sub    %ecx,%eax
  801014:	eb 10                	jmp    801026 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801016:	39 f8                	cmp    %edi,%eax
  801018:	75 e2                	jne    800ffc <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80101a:	b8 00 00 00 00       	mov    $0x0,%eax
  80101f:	eb 05                	jmp    801026 <memcmp+0x51>
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	53                   	push   %ebx
  80102f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801032:	89 d0                	mov    %edx,%eax
  801034:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801037:	39 c2                	cmp    %eax,%edx
  801039:	73 1d                	jae    801058 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80103b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80103f:	0f b6 0a             	movzbl (%edx),%ecx
  801042:	39 d9                	cmp    %ebx,%ecx
  801044:	75 09                	jne    80104f <memfind+0x24>
  801046:	eb 14                	jmp    80105c <memfind+0x31>
  801048:	0f b6 0a             	movzbl (%edx),%ecx
  80104b:	39 d9                	cmp    %ebx,%ecx
  80104d:	74 11                	je     801060 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80104f:	83 c2 01             	add    $0x1,%edx
  801052:	39 d0                	cmp    %edx,%eax
  801054:	75 f2                	jne    801048 <memfind+0x1d>
  801056:	eb 0a                	jmp    801062 <memfind+0x37>
  801058:	89 d0                	mov    %edx,%eax
  80105a:	eb 06                	jmp    801062 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  80105c:	89 d0                	mov    %edx,%eax
  80105e:	eb 02                	jmp    801062 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801060:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801062:	5b                   	pop    %ebx
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	57                   	push   %edi
  801069:	56                   	push   %esi
  80106a:	53                   	push   %ebx
  80106b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801071:	0f b6 01             	movzbl (%ecx),%eax
  801074:	3c 20                	cmp    $0x20,%al
  801076:	74 04                	je     80107c <strtol+0x17>
  801078:	3c 09                	cmp    $0x9,%al
  80107a:	75 0e                	jne    80108a <strtol+0x25>
		s++;
  80107c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107f:	0f b6 01             	movzbl (%ecx),%eax
  801082:	3c 20                	cmp    $0x20,%al
  801084:	74 f6                	je     80107c <strtol+0x17>
  801086:	3c 09                	cmp    $0x9,%al
  801088:	74 f2                	je     80107c <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80108a:	3c 2b                	cmp    $0x2b,%al
  80108c:	75 0a                	jne    801098 <strtol+0x33>
		s++;
  80108e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801091:	bf 00 00 00 00       	mov    $0x0,%edi
  801096:	eb 11                	jmp    8010a9 <strtol+0x44>
  801098:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80109d:	3c 2d                	cmp    $0x2d,%al
  80109f:	75 08                	jne    8010a9 <strtol+0x44>
		s++, neg = 1;
  8010a1:	83 c1 01             	add    $0x1,%ecx
  8010a4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010a9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010af:	75 15                	jne    8010c6 <strtol+0x61>
  8010b1:	80 39 30             	cmpb   $0x30,(%ecx)
  8010b4:	75 10                	jne    8010c6 <strtol+0x61>
  8010b6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010ba:	75 7c                	jne    801138 <strtol+0xd3>
		s += 2, base = 16;
  8010bc:	83 c1 02             	add    $0x2,%ecx
  8010bf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010c4:	eb 16                	jmp    8010dc <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010c6:	85 db                	test   %ebx,%ebx
  8010c8:	75 12                	jne    8010dc <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010ca:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010cf:	80 39 30             	cmpb   $0x30,(%ecx)
  8010d2:	75 08                	jne    8010dc <strtol+0x77>
		s++, base = 8;
  8010d4:	83 c1 01             	add    $0x1,%ecx
  8010d7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010e4:	0f b6 11             	movzbl (%ecx),%edx
  8010e7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010ea:	89 f3                	mov    %esi,%ebx
  8010ec:	80 fb 09             	cmp    $0x9,%bl
  8010ef:	77 08                	ja     8010f9 <strtol+0x94>
			dig = *s - '0';
  8010f1:	0f be d2             	movsbl %dl,%edx
  8010f4:	83 ea 30             	sub    $0x30,%edx
  8010f7:	eb 22                	jmp    80111b <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8010f9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010fc:	89 f3                	mov    %esi,%ebx
  8010fe:	80 fb 19             	cmp    $0x19,%bl
  801101:	77 08                	ja     80110b <strtol+0xa6>
			dig = *s - 'a' + 10;
  801103:	0f be d2             	movsbl %dl,%edx
  801106:	83 ea 57             	sub    $0x57,%edx
  801109:	eb 10                	jmp    80111b <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  80110b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80110e:	89 f3                	mov    %esi,%ebx
  801110:	80 fb 19             	cmp    $0x19,%bl
  801113:	77 16                	ja     80112b <strtol+0xc6>
			dig = *s - 'A' + 10;
  801115:	0f be d2             	movsbl %dl,%edx
  801118:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80111b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80111e:	7d 0b                	jge    80112b <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801120:	83 c1 01             	add    $0x1,%ecx
  801123:	0f af 45 10          	imul   0x10(%ebp),%eax
  801127:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801129:	eb b9                	jmp    8010e4 <strtol+0x7f>

	if (endptr)
  80112b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80112f:	74 0d                	je     80113e <strtol+0xd9>
		*endptr = (char *) s;
  801131:	8b 75 0c             	mov    0xc(%ebp),%esi
  801134:	89 0e                	mov    %ecx,(%esi)
  801136:	eb 06                	jmp    80113e <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801138:	85 db                	test   %ebx,%ebx
  80113a:	74 98                	je     8010d4 <strtol+0x6f>
  80113c:	eb 9e                	jmp    8010dc <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80113e:	89 c2                	mov    %eax,%edx
  801140:	f7 da                	neg    %edx
  801142:	85 ff                	test   %edi,%edi
  801144:	0f 45 c2             	cmovne %edx,%eax
}
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    
  80114c:	66 90                	xchg   %ax,%ax
  80114e:	66 90                	xchg   %ax,%ax

00801150 <__udivdi3>:
  801150:	55                   	push   %ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 1c             	sub    $0x1c,%esp
  801157:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80115b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80115f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801167:	85 f6                	test   %esi,%esi
  801169:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80116d:	89 ca                	mov    %ecx,%edx
  80116f:	89 f8                	mov    %edi,%eax
  801171:	75 3d                	jne    8011b0 <__udivdi3+0x60>
  801173:	39 cf                	cmp    %ecx,%edi
  801175:	0f 87 c5 00 00 00    	ja     801240 <__udivdi3+0xf0>
  80117b:	85 ff                	test   %edi,%edi
  80117d:	89 fd                	mov    %edi,%ebp
  80117f:	75 0b                	jne    80118c <__udivdi3+0x3c>
  801181:	b8 01 00 00 00       	mov    $0x1,%eax
  801186:	31 d2                	xor    %edx,%edx
  801188:	f7 f7                	div    %edi
  80118a:	89 c5                	mov    %eax,%ebp
  80118c:	89 c8                	mov    %ecx,%eax
  80118e:	31 d2                	xor    %edx,%edx
  801190:	f7 f5                	div    %ebp
  801192:	89 c1                	mov    %eax,%ecx
  801194:	89 d8                	mov    %ebx,%eax
  801196:	89 cf                	mov    %ecx,%edi
  801198:	f7 f5                	div    %ebp
  80119a:	89 c3                	mov    %eax,%ebx
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	89 fa                	mov    %edi,%edx
  8011a0:	83 c4 1c             	add    $0x1c,%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    
  8011a8:	90                   	nop
  8011a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	39 ce                	cmp    %ecx,%esi
  8011b2:	77 74                	ja     801228 <__udivdi3+0xd8>
  8011b4:	0f bd fe             	bsr    %esi,%edi
  8011b7:	83 f7 1f             	xor    $0x1f,%edi
  8011ba:	0f 84 98 00 00 00    	je     801258 <__udivdi3+0x108>
  8011c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011c5:	89 f9                	mov    %edi,%ecx
  8011c7:	89 c5                	mov    %eax,%ebp
  8011c9:	29 fb                	sub    %edi,%ebx
  8011cb:	d3 e6                	shl    %cl,%esi
  8011cd:	89 d9                	mov    %ebx,%ecx
  8011cf:	d3 ed                	shr    %cl,%ebp
  8011d1:	89 f9                	mov    %edi,%ecx
  8011d3:	d3 e0                	shl    %cl,%eax
  8011d5:	09 ee                	or     %ebp,%esi
  8011d7:	89 d9                	mov    %ebx,%ecx
  8011d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011dd:	89 d5                	mov    %edx,%ebp
  8011df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011e3:	d3 ed                	shr    %cl,%ebp
  8011e5:	89 f9                	mov    %edi,%ecx
  8011e7:	d3 e2                	shl    %cl,%edx
  8011e9:	89 d9                	mov    %ebx,%ecx
  8011eb:	d3 e8                	shr    %cl,%eax
  8011ed:	09 c2                	or     %eax,%edx
  8011ef:	89 d0                	mov    %edx,%eax
  8011f1:	89 ea                	mov    %ebp,%edx
  8011f3:	f7 f6                	div    %esi
  8011f5:	89 d5                	mov    %edx,%ebp
  8011f7:	89 c3                	mov    %eax,%ebx
  8011f9:	f7 64 24 0c          	mull   0xc(%esp)
  8011fd:	39 d5                	cmp    %edx,%ebp
  8011ff:	72 10                	jb     801211 <__udivdi3+0xc1>
  801201:	8b 74 24 08          	mov    0x8(%esp),%esi
  801205:	89 f9                	mov    %edi,%ecx
  801207:	d3 e6                	shl    %cl,%esi
  801209:	39 c6                	cmp    %eax,%esi
  80120b:	73 07                	jae    801214 <__udivdi3+0xc4>
  80120d:	39 d5                	cmp    %edx,%ebp
  80120f:	75 03                	jne    801214 <__udivdi3+0xc4>
  801211:	83 eb 01             	sub    $0x1,%ebx
  801214:	31 ff                	xor    %edi,%edi
  801216:	89 d8                	mov    %ebx,%eax
  801218:	89 fa                	mov    %edi,%edx
  80121a:	83 c4 1c             	add    $0x1c,%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    
  801222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801228:	31 ff                	xor    %edi,%edi
  80122a:	31 db                	xor    %ebx,%ebx
  80122c:	89 d8                	mov    %ebx,%eax
  80122e:	89 fa                	mov    %edi,%edx
  801230:	83 c4 1c             	add    $0x1c,%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
  801238:	90                   	nop
  801239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801240:	89 d8                	mov    %ebx,%eax
  801242:	f7 f7                	div    %edi
  801244:	31 ff                	xor    %edi,%edi
  801246:	89 c3                	mov    %eax,%ebx
  801248:	89 d8                	mov    %ebx,%eax
  80124a:	89 fa                	mov    %edi,%edx
  80124c:	83 c4 1c             	add    $0x1c,%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5f                   	pop    %edi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	39 ce                	cmp    %ecx,%esi
  80125a:	72 0c                	jb     801268 <__udivdi3+0x118>
  80125c:	31 db                	xor    %ebx,%ebx
  80125e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801262:	0f 87 34 ff ff ff    	ja     80119c <__udivdi3+0x4c>
  801268:	bb 01 00 00 00       	mov    $0x1,%ebx
  80126d:	e9 2a ff ff ff       	jmp    80119c <__udivdi3+0x4c>
  801272:	66 90                	xchg   %ax,%ax
  801274:	66 90                	xchg   %ax,%ax
  801276:	66 90                	xchg   %ax,%ax
  801278:	66 90                	xchg   %ax,%ax
  80127a:	66 90                	xchg   %ax,%ax
  80127c:	66 90                	xchg   %ax,%ax
  80127e:	66 90                	xchg   %ax,%ax

00801280 <__umoddi3>:
  801280:	55                   	push   %ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 1c             	sub    $0x1c,%esp
  801287:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80128b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80128f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801297:	85 d2                	test   %edx,%edx
  801299:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80129d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a1:	89 f3                	mov    %esi,%ebx
  8012a3:	89 3c 24             	mov    %edi,(%esp)
  8012a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012aa:	75 1c                	jne    8012c8 <__umoddi3+0x48>
  8012ac:	39 f7                	cmp    %esi,%edi
  8012ae:	76 50                	jbe    801300 <__umoddi3+0x80>
  8012b0:	89 c8                	mov    %ecx,%eax
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	f7 f7                	div    %edi
  8012b6:	89 d0                	mov    %edx,%eax
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	83 c4 1c             	add    $0x1c,%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    
  8012c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c8:	39 f2                	cmp    %esi,%edx
  8012ca:	89 d0                	mov    %edx,%eax
  8012cc:	77 52                	ja     801320 <__umoddi3+0xa0>
  8012ce:	0f bd ea             	bsr    %edx,%ebp
  8012d1:	83 f5 1f             	xor    $0x1f,%ebp
  8012d4:	75 5a                	jne    801330 <__umoddi3+0xb0>
  8012d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012da:	0f 82 e0 00 00 00    	jb     8013c0 <__umoddi3+0x140>
  8012e0:	39 0c 24             	cmp    %ecx,(%esp)
  8012e3:	0f 86 d7 00 00 00    	jbe    8013c0 <__umoddi3+0x140>
  8012e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012f1:	83 c4 1c             	add    $0x1c,%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	85 ff                	test   %edi,%edi
  801302:	89 fd                	mov    %edi,%ebp
  801304:	75 0b                	jne    801311 <__umoddi3+0x91>
  801306:	b8 01 00 00 00       	mov    $0x1,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f7                	div    %edi
  80130f:	89 c5                	mov    %eax,%ebp
  801311:	89 f0                	mov    %esi,%eax
  801313:	31 d2                	xor    %edx,%edx
  801315:	f7 f5                	div    %ebp
  801317:	89 c8                	mov    %ecx,%eax
  801319:	f7 f5                	div    %ebp
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	eb 99                	jmp    8012b8 <__umoddi3+0x38>
  80131f:	90                   	nop
  801320:	89 c8                	mov    %ecx,%eax
  801322:	89 f2                	mov    %esi,%edx
  801324:	83 c4 1c             	add    $0x1c,%esp
  801327:	5b                   	pop    %ebx
  801328:	5e                   	pop    %esi
  801329:	5f                   	pop    %edi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	8b 34 24             	mov    (%esp),%esi
  801333:	bf 20 00 00 00       	mov    $0x20,%edi
  801338:	89 e9                	mov    %ebp,%ecx
  80133a:	29 ef                	sub    %ebp,%edi
  80133c:	d3 e0                	shl    %cl,%eax
  80133e:	89 f9                	mov    %edi,%ecx
  801340:	89 f2                	mov    %esi,%edx
  801342:	d3 ea                	shr    %cl,%edx
  801344:	89 e9                	mov    %ebp,%ecx
  801346:	09 c2                	or     %eax,%edx
  801348:	89 d8                	mov    %ebx,%eax
  80134a:	89 14 24             	mov    %edx,(%esp)
  80134d:	89 f2                	mov    %esi,%edx
  80134f:	d3 e2                	shl    %cl,%edx
  801351:	89 f9                	mov    %edi,%ecx
  801353:	89 54 24 04          	mov    %edx,0x4(%esp)
  801357:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80135b:	d3 e8                	shr    %cl,%eax
  80135d:	89 e9                	mov    %ebp,%ecx
  80135f:	89 c6                	mov    %eax,%esi
  801361:	d3 e3                	shl    %cl,%ebx
  801363:	89 f9                	mov    %edi,%ecx
  801365:	89 d0                	mov    %edx,%eax
  801367:	d3 e8                	shr    %cl,%eax
  801369:	89 e9                	mov    %ebp,%ecx
  80136b:	09 d8                	or     %ebx,%eax
  80136d:	89 d3                	mov    %edx,%ebx
  80136f:	89 f2                	mov    %esi,%edx
  801371:	f7 34 24             	divl   (%esp)
  801374:	89 d6                	mov    %edx,%esi
  801376:	d3 e3                	shl    %cl,%ebx
  801378:	f7 64 24 04          	mull   0x4(%esp)
  80137c:	39 d6                	cmp    %edx,%esi
  80137e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801382:	89 d1                	mov    %edx,%ecx
  801384:	89 c3                	mov    %eax,%ebx
  801386:	72 08                	jb     801390 <__umoddi3+0x110>
  801388:	75 11                	jne    80139b <__umoddi3+0x11b>
  80138a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80138e:	73 0b                	jae    80139b <__umoddi3+0x11b>
  801390:	2b 44 24 04          	sub    0x4(%esp),%eax
  801394:	1b 14 24             	sbb    (%esp),%edx
  801397:	89 d1                	mov    %edx,%ecx
  801399:	89 c3                	mov    %eax,%ebx
  80139b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80139f:	29 da                	sub    %ebx,%edx
  8013a1:	19 ce                	sbb    %ecx,%esi
  8013a3:	89 f9                	mov    %edi,%ecx
  8013a5:	89 f0                	mov    %esi,%eax
  8013a7:	d3 e0                	shl    %cl,%eax
  8013a9:	89 e9                	mov    %ebp,%ecx
  8013ab:	d3 ea                	shr    %cl,%edx
  8013ad:	89 e9                	mov    %ebp,%ecx
  8013af:	d3 ee                	shr    %cl,%esi
  8013b1:	09 d0                	or     %edx,%eax
  8013b3:	89 f2                	mov    %esi,%edx
  8013b5:	83 c4 1c             	add    $0x1c,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    
  8013bd:	8d 76 00             	lea    0x0(%esi),%esi
  8013c0:	29 f9                	sub    %edi,%ecx
  8013c2:	19 d6                	sbb    %edx,%esi
  8013c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013cc:	e9 18 ff ff ff       	jmp    8012e9 <__umoddi3+0x69>
