
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004d:	e8 f9 00 00 00       	call   80014b <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	c1 e0 07             	shl    $0x7,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 66 00 00 00       	call   8000fb <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	51                   	push   %ecx
  8000af:	52                   	push   %edx
  8000b0:	53                   	push   %ebx
  8000b1:	54                   	push   %esp
  8000b2:	55                   	push   %ebp
  8000b3:	56                   	push   %esi
  8000b4:	57                   	push   %edi
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	8d 35 bf 00 80 00    	lea    0x8000bf,%esi
  8000bd:	0f 34                	sysenter 

008000bf <label_21>:
  8000bf:	5f                   	pop    %edi
  8000c0:	5e                   	pop    %esi
  8000c1:	5d                   	pop    %ebp
  8000c2:	5c                   	pop    %esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5a                   	pop    %edx
  8000c5:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c6:	5b                   	pop    %ebx
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	89 ca                	mov    %ecx,%edx
  8000db:	89 cb                	mov    %ecx,%ebx
  8000dd:	89 cf                	mov    %ecx,%edi
  8000df:	51                   	push   %ecx
  8000e0:	52                   	push   %edx
  8000e1:	53                   	push   %ebx
  8000e2:	54                   	push   %esp
  8000e3:	55                   	push   %ebp
  8000e4:	56                   	push   %esi
  8000e5:	57                   	push   %edi
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	8d 35 f0 00 80 00    	lea    0x8000f0,%esi
  8000ee:	0f 34                	sysenter 

008000f0 <label_55>:
  8000f0:	5f                   	pop    %edi
  8000f1:	5e                   	pop    %esi
  8000f2:	5d                   	pop    %ebp
  8000f3:	5c                   	pop    %esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5a                   	pop    %edx
  8000f6:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f7:	5b                   	pop    %ebx
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800100:	bb 00 00 00 00       	mov    $0x0,%ebx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	89 d9                	mov    %ebx,%ecx
  80010f:	89 df                	mov    %ebx,%edi
  800111:	51                   	push   %ecx
  800112:	52                   	push   %edx
  800113:	53                   	push   %ebx
  800114:	54                   	push   %esp
  800115:	55                   	push   %ebp
  800116:	56                   	push   %esi
  800117:	57                   	push   %edi
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	8d 35 22 01 80 00    	lea    0x800122,%esi
  800120:	0f 34                	sysenter 

00800122 <label_90>:
  800122:	5f                   	pop    %edi
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	5c                   	pop    %esp
  800126:	5b                   	pop    %ebx
  800127:	5a                   	pop    %edx
  800128:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800129:	85 c0                	test   %eax,%eax
  80012b:	7e 17                	jle    800144 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	6a 03                	push   $0x3
  800133:	68 ea 13 80 00       	push   $0x8013ea
  800138:	6a 2a                	push   $0x2a
  80013a:	68 07 14 80 00       	push   $0x801407
  80013f:	e8 e5 02 00 00       	call   800429 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800147:	5b                   	pop    %ebx
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800150:	b9 00 00 00 00       	mov    $0x0,%ecx
  800155:	b8 02 00 00 00       	mov    $0x2,%eax
  80015a:	89 ca                	mov    %ecx,%edx
  80015c:	89 cb                	mov    %ecx,%ebx
  80015e:	89 cf                	mov    %ecx,%edi
  800160:	51                   	push   %ecx
  800161:	52                   	push   %edx
  800162:	53                   	push   %ebx
  800163:	54                   	push   %esp
  800164:	55                   	push   %ebp
  800165:	56                   	push   %esi
  800166:	57                   	push   %edi
  800167:	89 e5                	mov    %esp,%ebp
  800169:	8d 35 71 01 80 00    	lea    0x800171,%esi
  80016f:	0f 34                	sysenter 

00800171 <label_139>:
  800171:	5f                   	pop    %edi
  800172:	5e                   	pop    %esi
  800173:	5d                   	pop    %ebp
  800174:	5c                   	pop    %esp
  800175:	5b                   	pop    %ebx
  800176:	5a                   	pop    %edx
  800177:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5f                   	pop    %edi
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800181:	bf 00 00 00 00       	mov    $0x0,%edi
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	89 fb                	mov    %edi,%ebx
  800193:	51                   	push   %ecx
  800194:	52                   	push   %edx
  800195:	53                   	push   %ebx
  800196:	54                   	push   %esp
  800197:	55                   	push   %ebp
  800198:	56                   	push   %esi
  800199:	57                   	push   %edi
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	8d 35 a4 01 80 00    	lea    0x8001a4,%esi
  8001a2:	0f 34                	sysenter 

008001a4 <label_174>:
  8001a4:	5f                   	pop    %edi
  8001a5:	5e                   	pop    %esi
  8001a6:	5d                   	pop    %ebp
  8001a7:	5c                   	pop    %esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5a                   	pop    %edx
  8001aa:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001ab:	5b                   	pop    %ebx
  8001ac:	5f                   	pop    %edi
  8001ad:	5d                   	pop    %ebp
  8001ae:	c3                   	ret    

008001af <sys_yield>:

void
sys_yield(void)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	57                   	push   %edi
  8001b3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001be:	89 d1                	mov    %edx,%ecx
  8001c0:	89 d3                	mov    %edx,%ebx
  8001c2:	89 d7                	mov    %edx,%edi
  8001c4:	51                   	push   %ecx
  8001c5:	52                   	push   %edx
  8001c6:	53                   	push   %ebx
  8001c7:	54                   	push   %esp
  8001c8:	55                   	push   %ebp
  8001c9:	56                   	push   %esi
  8001ca:	57                   	push   %edi
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	8d 35 d5 01 80 00    	lea    0x8001d5,%esi
  8001d3:	0f 34                	sysenter 

008001d5 <label_209>:
  8001d5:	5f                   	pop    %edi
  8001d6:	5e                   	pop    %esi
  8001d7:	5d                   	pop    %ebp
  8001d8:	5c                   	pop    %esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5a                   	pop    %edx
  8001db:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001dc:	5b                   	pop    %ebx
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	51                   	push   %ecx
  8001f9:	52                   	push   %edx
  8001fa:	53                   	push   %ebx
  8001fb:	54                   	push   %esp
  8001fc:	55                   	push   %ebp
  8001fd:	56                   	push   %esi
  8001fe:	57                   	push   %edi
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	8d 35 09 02 80 00    	lea    0x800209,%esi
  800207:	0f 34                	sysenter 

00800209 <label_244>:
  800209:	5f                   	pop    %edi
  80020a:	5e                   	pop    %esi
  80020b:	5d                   	pop    %ebp
  80020c:	5c                   	pop    %esp
  80020d:	5b                   	pop    %ebx
  80020e:	5a                   	pop    %edx
  80020f:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800210:	85 c0                	test   %eax,%eax
  800212:	7e 17                	jle    80022b <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	50                   	push   %eax
  800218:	6a 05                	push   $0x5
  80021a:	68 ea 13 80 00       	push   $0x8013ea
  80021f:	6a 2a                	push   $0x2a
  800221:	68 07 14 80 00       	push   $0x801407
  800226:	e8 fe 01 00 00       	call   800429 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5f                   	pop    %edi
  800230:	5d                   	pop    %ebp
  800231:	c3                   	ret    

00800232 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800237:	b8 06 00 00 00       	mov    $0x6,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800245:	8b 7d 14             	mov    0x14(%ebp),%edi
  800248:	51                   	push   %ecx
  800249:	52                   	push   %edx
  80024a:	53                   	push   %ebx
  80024b:	54                   	push   %esp
  80024c:	55                   	push   %ebp
  80024d:	56                   	push   %esi
  80024e:	57                   	push   %edi
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8d 35 59 02 80 00    	lea    0x800259,%esi
  800257:	0f 34                	sysenter 

00800259 <label_295>:
  800259:	5f                   	pop    %edi
  80025a:	5e                   	pop    %esi
  80025b:	5d                   	pop    %ebp
  80025c:	5c                   	pop    %esp
  80025d:	5b                   	pop    %ebx
  80025e:	5a                   	pop    %edx
  80025f:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7e 17                	jle    80027b <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	50                   	push   %eax
  800268:	6a 06                	push   $0x6
  80026a:	68 ea 13 80 00       	push   $0x8013ea
  80026f:	6a 2a                	push   $0x2a
  800271:	68 07 14 80 00       	push   $0x801407
  800276:	e8 ae 01 00 00       	call   800429 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80027b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800287:	bf 00 00 00 00       	mov    $0x0,%edi
  80028c:	b8 07 00 00 00       	mov    $0x7,%eax
  800291:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	89 fb                	mov    %edi,%ebx
  800299:	51                   	push   %ecx
  80029a:	52                   	push   %edx
  80029b:	53                   	push   %ebx
  80029c:	54                   	push   %esp
  80029d:	55                   	push   %ebp
  80029e:	56                   	push   %esi
  80029f:	57                   	push   %edi
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	8d 35 aa 02 80 00    	lea    0x8002aa,%esi
  8002a8:	0f 34                	sysenter 

008002aa <label_344>:
  8002aa:	5f                   	pop    %edi
  8002ab:	5e                   	pop    %esi
  8002ac:	5d                   	pop    %ebp
  8002ad:	5c                   	pop    %esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5a                   	pop    %edx
  8002b0:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	7e 17                	jle    8002cc <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	50                   	push   %eax
  8002b9:	6a 07                	push   $0x7
  8002bb:	68 ea 13 80 00       	push   $0x8013ea
  8002c0:	6a 2a                	push   $0x2a
  8002c2:	68 07 14 80 00       	push   $0x801407
  8002c7:	e8 5d 01 00 00       	call   800429 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	57                   	push   %edi
  8002d7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8002dd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	89 fb                	mov    %edi,%ebx
  8002ea:	51                   	push   %ecx
  8002eb:	52                   	push   %edx
  8002ec:	53                   	push   %ebx
  8002ed:	54                   	push   %esp
  8002ee:	55                   	push   %ebp
  8002ef:	56                   	push   %esi
  8002f0:	57                   	push   %edi
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	8d 35 fb 02 80 00    	lea    0x8002fb,%esi
  8002f9:	0f 34                	sysenter 

008002fb <label_393>:
  8002fb:	5f                   	pop    %edi
  8002fc:	5e                   	pop    %esi
  8002fd:	5d                   	pop    %ebp
  8002fe:	5c                   	pop    %esp
  8002ff:	5b                   	pop    %ebx
  800300:	5a                   	pop    %edx
  800301:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800302:	85 c0                	test   %eax,%eax
  800304:	7e 17                	jle    80031d <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800306:	83 ec 0c             	sub    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	6a 09                	push   $0x9
  80030c:	68 ea 13 80 00       	push   $0x8013ea
  800311:	6a 2a                	push   $0x2a
  800313:	68 07 14 80 00       	push   $0x801407
  800318:	e8 0c 01 00 00       	call   800429 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80031d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800320:	5b                   	pop    %ebx
  800321:	5f                   	pop    %edi
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800329:	bf 00 00 00 00       	mov    $0x0,%edi
  80032e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800336:	8b 55 08             	mov    0x8(%ebp),%edx
  800339:	89 fb                	mov    %edi,%ebx
  80033b:	51                   	push   %ecx
  80033c:	52                   	push   %edx
  80033d:	53                   	push   %ebx
  80033e:	54                   	push   %esp
  80033f:	55                   	push   %ebp
  800340:	56                   	push   %esi
  800341:	57                   	push   %edi
  800342:	89 e5                	mov    %esp,%ebp
  800344:	8d 35 4c 03 80 00    	lea    0x80034c,%esi
  80034a:	0f 34                	sysenter 

0080034c <label_442>:
  80034c:	5f                   	pop    %edi
  80034d:	5e                   	pop    %esi
  80034e:	5d                   	pop    %ebp
  80034f:	5c                   	pop    %esp
  800350:	5b                   	pop    %ebx
  800351:	5a                   	pop    %edx
  800352:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800353:	85 c0                	test   %eax,%eax
  800355:	7e 17                	jle    80036e <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	50                   	push   %eax
  80035b:	6a 0a                	push   $0xa
  80035d:	68 ea 13 80 00       	push   $0x8013ea
  800362:	6a 2a                	push   $0x2a
  800364:	68 07 14 80 00       	push   $0x801407
  800369:	e8 bb 00 00 00       	call   800429 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80036e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800371:	5b                   	pop    %ebx
  800372:	5f                   	pop    %edi
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	57                   	push   %edi
  800379:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80037a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800382:	8b 55 08             	mov    0x8(%ebp),%edx
  800385:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800388:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038b:	51                   	push   %ecx
  80038c:	52                   	push   %edx
  80038d:	53                   	push   %ebx
  80038e:	54                   	push   %esp
  80038f:	55                   	push   %ebp
  800390:	56                   	push   %esi
  800391:	57                   	push   %edi
  800392:	89 e5                	mov    %esp,%ebp
  800394:	8d 35 9c 03 80 00    	lea    0x80039c,%esi
  80039a:	0f 34                	sysenter 

0080039c <label_493>:
  80039c:	5f                   	pop    %edi
  80039d:	5e                   	pop    %esi
  80039e:	5d                   	pop    %ebp
  80039f:	5c                   	pop    %esp
  8003a0:	5b                   	pop    %ebx
  8003a1:	5a                   	pop    %edx
  8003a2:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003a3:	5b                   	pop    %ebx
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	57                   	push   %edi
  8003ab:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b9:	89 d9                	mov    %ebx,%ecx
  8003bb:	89 df                	mov    %ebx,%edi
  8003bd:	51                   	push   %ecx
  8003be:	52                   	push   %edx
  8003bf:	53                   	push   %ebx
  8003c0:	54                   	push   %esp
  8003c1:	55                   	push   %ebp
  8003c2:	56                   	push   %esi
  8003c3:	57                   	push   %edi
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	8d 35 ce 03 80 00    	lea    0x8003ce,%esi
  8003cc:	0f 34                	sysenter 

008003ce <label_528>:
  8003ce:	5f                   	pop    %edi
  8003cf:	5e                   	pop    %esi
  8003d0:	5d                   	pop    %ebp
  8003d1:	5c                   	pop    %esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5a                   	pop    %edx
  8003d4:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	7e 17                	jle    8003f0 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8003d9:	83 ec 0c             	sub    $0xc,%esp
  8003dc:	50                   	push   %eax
  8003dd:	6a 0d                	push   $0xd
  8003df:	68 ea 13 80 00       	push   $0x8013ea
  8003e4:	6a 2a                	push   $0x2a
  8003e6:	68 07 14 80 00       	push   $0x801407
  8003eb:	e8 39 00 00 00       	call   800429 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003f3:	5b                   	pop    %ebx
  8003f4:	5f                   	pop    %edi
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	57                   	push   %edi
  8003fb:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800401:	b8 0e 00 00 00       	mov    $0xe,%eax
  800406:	8b 55 08             	mov    0x8(%ebp),%edx
  800409:	89 cb                	mov    %ecx,%ebx
  80040b:	89 cf                	mov    %ecx,%edi
  80040d:	51                   	push   %ecx
  80040e:	52                   	push   %edx
  80040f:	53                   	push   %ebx
  800410:	54                   	push   %esp
  800411:	55                   	push   %ebp
  800412:	56                   	push   %esi
  800413:	57                   	push   %edi
  800414:	89 e5                	mov    %esp,%ebp
  800416:	8d 35 1e 04 80 00    	lea    0x80041e,%esi
  80041c:	0f 34                	sysenter 

0080041e <label_577>:
  80041e:	5f                   	pop    %edi
  80041f:	5e                   	pop    %esi
  800420:	5d                   	pop    %ebp
  800421:	5c                   	pop    %esp
  800422:	5b                   	pop    %ebx
  800423:	5a                   	pop    %edx
  800424:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800425:	5b                   	pop    %ebx
  800426:	5f                   	pop    %edi
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80042e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800431:	a1 10 20 80 00       	mov    0x802010,%eax
  800436:	85 c0                	test   %eax,%eax
  800438:	74 11                	je     80044b <_panic+0x22>
		cprintf("%s: ", argv0);
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	50                   	push   %eax
  80043e:	68 15 14 80 00       	push   $0x801415
  800443:	e8 d4 00 00 00       	call   80051c <cprintf>
  800448:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80044b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800451:	e8 f5 fc ff ff       	call   80014b <sys_getenvid>
  800456:	83 ec 0c             	sub    $0xc,%esp
  800459:	ff 75 0c             	pushl  0xc(%ebp)
  80045c:	ff 75 08             	pushl  0x8(%ebp)
  80045f:	56                   	push   %esi
  800460:	50                   	push   %eax
  800461:	68 1c 14 80 00       	push   $0x80141c
  800466:	e8 b1 00 00 00       	call   80051c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80046b:	83 c4 18             	add    $0x18,%esp
  80046e:	53                   	push   %ebx
  80046f:	ff 75 10             	pushl  0x10(%ebp)
  800472:	e8 54 00 00 00       	call   8004cb <vcprintf>
	cprintf("\n");
  800477:	c7 04 24 1a 14 80 00 	movl   $0x80141a,(%esp)
  80047e:	e8 99 00 00 00       	call   80051c <cprintf>
  800483:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800486:	cc                   	int3   
  800487:	eb fd                	jmp    800486 <_panic+0x5d>

00800489 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	53                   	push   %ebx
  80048d:	83 ec 04             	sub    $0x4,%esp
  800490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800493:	8b 13                	mov    (%ebx),%edx
  800495:	8d 42 01             	lea    0x1(%edx),%eax
  800498:	89 03                	mov    %eax,(%ebx)
  80049a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80049d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004a1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a6:	75 1a                	jne    8004c2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	68 ff 00 00 00       	push   $0xff
  8004b0:	8d 43 08             	lea    0x8(%ebx),%eax
  8004b3:	50                   	push   %eax
  8004b4:	e8 e1 fb ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8004b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004bf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004c2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c9:	c9                   	leave  
  8004ca:	c3                   	ret    

008004cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004db:	00 00 00 
	b.cnt = 0;
  8004de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	ff 75 08             	pushl  0x8(%ebp)
  8004ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	68 89 04 80 00       	push   $0x800489
  8004fa:	e8 c0 02 00 00       	call   8007bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004ff:	83 c4 08             	add    $0x8,%esp
  800502:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800508:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80050e:	50                   	push   %eax
  80050f:	e8 86 fb ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  800514:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800522:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800525:	50                   	push   %eax
  800526:	ff 75 08             	pushl  0x8(%ebp)
  800529:	e8 9d ff ff ff       	call   8004cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80052e:	c9                   	leave  
  80052f:	c3                   	ret    

00800530 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	57                   	push   %edi
  800534:	56                   	push   %esi
  800535:	53                   	push   %ebx
  800536:	83 ec 1c             	sub    $0x1c,%esp
  800539:	89 c7                	mov    %eax,%edi
  80053b:	89 d6                	mov    %edx,%esi
  80053d:	8b 45 08             	mov    0x8(%ebp),%eax
  800540:	8b 55 0c             	mov    0xc(%ebp),%edx
  800543:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800546:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800549:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80054c:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800550:	0f 85 bf 00 00 00    	jne    800615 <printnum+0xe5>
  800556:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  80055c:	0f 8d de 00 00 00    	jge    800640 <printnum+0x110>
		judge_time_for_space = width;
  800562:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800568:	e9 d3 00 00 00       	jmp    800640 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80056d:	83 eb 01             	sub    $0x1,%ebx
  800570:	85 db                	test   %ebx,%ebx
  800572:	7f 37                	jg     8005ab <printnum+0x7b>
  800574:	e9 ea 00 00 00       	jmp    800663 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800579:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80057c:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	56                   	push   %esi
  800585:	83 ec 04             	sub    $0x4,%esp
  800588:	ff 75 dc             	pushl  -0x24(%ebp)
  80058b:	ff 75 d8             	pushl  -0x28(%ebp)
  80058e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800591:	ff 75 e0             	pushl  -0x20(%ebp)
  800594:	e8 d7 0c 00 00       	call   801270 <__umoddi3>
  800599:	83 c4 14             	add    $0x14,%esp
  80059c:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  8005a3:	50                   	push   %eax
  8005a4:	ff d7                	call   *%edi
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	eb 16                	jmp    8005c1 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	56                   	push   %esi
  8005af:	ff 75 18             	pushl  0x18(%ebp)
  8005b2:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	83 eb 01             	sub    $0x1,%ebx
  8005ba:	75 ef                	jne    8005ab <printnum+0x7b>
  8005bc:	e9 a2 00 00 00       	jmp    800663 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005c1:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005c7:	0f 85 76 01 00 00    	jne    800743 <printnum+0x213>
		while(num_of_space-- > 0)
  8005cd:	a1 04 20 80 00       	mov    0x802004,%eax
  8005d2:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005d5:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	7e 1d                	jle    8005fc <printnum+0xcc>
			putch(' ', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	56                   	push   %esi
  8005e3:	6a 20                	push   $0x20
  8005e5:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8005e7:	a1 04 20 80 00       	mov    0x802004,%eax
  8005ec:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005ef:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	7f e3                	jg     8005df <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8005fc:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800603:	00 00 00 
		judge_time_for_space = 0;
  800606:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80060d:	00 00 00 
	}
}
  800610:	e9 2e 01 00 00       	jmp    800743 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800615:	8b 45 10             	mov    0x10(%ebp),%eax
  800618:	ba 00 00 00 00       	mov    $0x0,%edx
  80061d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800620:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800623:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800626:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800629:	83 fa 00             	cmp    $0x0,%edx
  80062c:	0f 87 ba 00 00 00    	ja     8006ec <printnum+0x1bc>
  800632:	3b 45 10             	cmp    0x10(%ebp),%eax
  800635:	0f 83 b1 00 00 00    	jae    8006ec <printnum+0x1bc>
  80063b:	e9 2d ff ff ff       	jmp    80056d <printnum+0x3d>
  800640:	8b 45 10             	mov    0x10(%ebp),%eax
  800643:	ba 00 00 00 00       	mov    $0x0,%edx
  800648:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800651:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800654:	83 fa 00             	cmp    $0x0,%edx
  800657:	77 37                	ja     800690 <printnum+0x160>
  800659:	3b 45 10             	cmp    0x10(%ebp),%eax
  80065c:	73 32                	jae    800690 <printnum+0x160>
  80065e:	e9 16 ff ff ff       	jmp    800579 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	56                   	push   %esi
  800667:	83 ec 04             	sub    $0x4,%esp
  80066a:	ff 75 dc             	pushl  -0x24(%ebp)
  80066d:	ff 75 d8             	pushl  -0x28(%ebp)
  800670:	ff 75 e4             	pushl  -0x1c(%ebp)
  800673:	ff 75 e0             	pushl  -0x20(%ebp)
  800676:	e8 f5 0b 00 00       	call   801270 <__umoddi3>
  80067b:	83 c4 14             	add    $0x14,%esp
  80067e:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  800685:	50                   	push   %eax
  800686:	ff d7                	call   *%edi
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	e9 b3 00 00 00       	jmp    800743 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	ff 75 18             	pushl  0x18(%ebp)
  800696:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800699:	50                   	push   %eax
  80069a:	ff 75 10             	pushl  0x10(%ebp)
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8006a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8006a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ac:	e8 8f 0a 00 00       	call   801140 <__udivdi3>
  8006b1:	83 c4 18             	add    $0x18,%esp
  8006b4:	52                   	push   %edx
  8006b5:	50                   	push   %eax
  8006b6:	89 f2                	mov    %esi,%edx
  8006b8:	89 f8                	mov    %edi,%eax
  8006ba:	e8 71 fe ff ff       	call   800530 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006bf:	83 c4 18             	add    $0x18,%esp
  8006c2:	56                   	push   %esi
  8006c3:	83 ec 04             	sub    $0x4,%esp
  8006c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8006cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d2:	e8 99 0b 00 00       	call   801270 <__umoddi3>
  8006d7:	83 c4 14             	add    $0x14,%esp
  8006da:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  8006e1:	50                   	push   %eax
  8006e2:	ff d7                	call   *%edi
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	e9 d5 fe ff ff       	jmp    8005c1 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006ec:	83 ec 0c             	sub    $0xc,%esp
  8006ef:	ff 75 18             	pushl  0x18(%ebp)
  8006f2:	83 eb 01             	sub    $0x1,%ebx
  8006f5:	53                   	push   %ebx
  8006f6:	ff 75 10             	pushl  0x10(%ebp)
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800702:	ff 75 e4             	pushl  -0x1c(%ebp)
  800705:	ff 75 e0             	pushl  -0x20(%ebp)
  800708:	e8 33 0a 00 00       	call   801140 <__udivdi3>
  80070d:	83 c4 18             	add    $0x18,%esp
  800710:	52                   	push   %edx
  800711:	50                   	push   %eax
  800712:	89 f2                	mov    %esi,%edx
  800714:	89 f8                	mov    %edi,%eax
  800716:	e8 15 fe ff ff       	call   800530 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80071b:	83 c4 18             	add    $0x18,%esp
  80071e:	56                   	push   %esi
  80071f:	83 ec 04             	sub    $0x4,%esp
  800722:	ff 75 dc             	pushl  -0x24(%ebp)
  800725:	ff 75 d8             	pushl  -0x28(%ebp)
  800728:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072b:	ff 75 e0             	pushl  -0x20(%ebp)
  80072e:	e8 3d 0b 00 00       	call   801270 <__umoddi3>
  800733:	83 c4 14             	add    $0x14,%esp
  800736:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  80073d:	50                   	push   %eax
  80073e:	ff d7                	call   *%edi
  800740:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800743:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800746:	5b                   	pop    %ebx
  800747:	5e                   	pop    %esi
  800748:	5f                   	pop    %edi
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80074e:	83 fa 01             	cmp    $0x1,%edx
  800751:	7e 0e                	jle    800761 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800753:	8b 10                	mov    (%eax),%edx
  800755:	8d 4a 08             	lea    0x8(%edx),%ecx
  800758:	89 08                	mov    %ecx,(%eax)
  80075a:	8b 02                	mov    (%edx),%eax
  80075c:	8b 52 04             	mov    0x4(%edx),%edx
  80075f:	eb 22                	jmp    800783 <getuint+0x38>
	else if (lflag)
  800761:	85 d2                	test   %edx,%edx
  800763:	74 10                	je     800775 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800765:	8b 10                	mov    (%eax),%edx
  800767:	8d 4a 04             	lea    0x4(%edx),%ecx
  80076a:	89 08                	mov    %ecx,(%eax)
  80076c:	8b 02                	mov    (%edx),%eax
  80076e:	ba 00 00 00 00       	mov    $0x0,%edx
  800773:	eb 0e                	jmp    800783 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800775:	8b 10                	mov    (%eax),%edx
  800777:	8d 4a 04             	lea    0x4(%edx),%ecx
  80077a:	89 08                	mov    %ecx,(%eax)
  80077c:	8b 02                	mov    (%edx),%eax
  80077e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80078b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80078f:	8b 10                	mov    (%eax),%edx
  800791:	3b 50 04             	cmp    0x4(%eax),%edx
  800794:	73 0a                	jae    8007a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800796:	8d 4a 01             	lea    0x1(%edx),%ecx
  800799:	89 08                	mov    %ecx,(%eax)
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	88 02                	mov    %al,(%edx)
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 05 00 00 00       	call   8007bf <vprintfmt>
	va_end(ap);
}
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	57                   	push   %edi
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	83 ec 2c             	sub    $0x2c,%esp
  8007c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ce:	eb 03                	jmp    8007d3 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d0:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d6:	8d 70 01             	lea    0x1(%eax),%esi
  8007d9:	0f b6 00             	movzbl (%eax),%eax
  8007dc:	83 f8 25             	cmp    $0x25,%eax
  8007df:	74 27                	je     800808 <vprintfmt+0x49>
			if (ch == '\0')
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	75 0d                	jne    8007f2 <vprintfmt+0x33>
  8007e5:	e9 9d 04 00 00       	jmp    800c87 <vprintfmt+0x4c8>
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	0f 84 95 04 00 00    	je     800c87 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	53                   	push   %ebx
  8007f6:	50                   	push   %eax
  8007f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f9:	83 c6 01             	add    $0x1,%esi
  8007fc:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	83 f8 25             	cmp    $0x25,%eax
  800806:	75 e2                	jne    8007ea <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800808:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080d:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800811:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800818:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80081f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800826:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80082d:	eb 08                	jmp    800837 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800832:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800837:	8d 46 01             	lea    0x1(%esi),%eax
  80083a:	89 45 10             	mov    %eax,0x10(%ebp)
  80083d:	0f b6 06             	movzbl (%esi),%eax
  800840:	0f b6 d0             	movzbl %al,%edx
  800843:	83 e8 23             	sub    $0x23,%eax
  800846:	3c 55                	cmp    $0x55,%al
  800848:	0f 87 fa 03 00 00    	ja     800c48 <vprintfmt+0x489>
  80084e:	0f b6 c0             	movzbl %al,%eax
  800851:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  800858:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  80085b:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80085f:	eb d6                	jmp    800837 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800861:	8d 42 d0             	lea    -0x30(%edx),%eax
  800864:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800867:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80086b:	8d 50 d0             	lea    -0x30(%eax),%edx
  80086e:	83 fa 09             	cmp    $0x9,%edx
  800871:	77 6b                	ja     8008de <vprintfmt+0x11f>
  800873:	8b 75 10             	mov    0x10(%ebp),%esi
  800876:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800879:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80087c:	eb 09                	jmp    800887 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087e:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800881:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800885:	eb b0                	jmp    800837 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800887:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80088a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80088d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800891:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800894:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800897:	83 f9 09             	cmp    $0x9,%ecx
  80089a:	76 eb                	jbe    800887 <vprintfmt+0xc8>
  80089c:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80089f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008a2:	eb 3d                	jmp    8008e1 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8d 50 04             	lea    0x4(%eax),%edx
  8008aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ad:	8b 00                	mov    (%eax),%eax
  8008af:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b2:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b5:	eb 2a                	jmp    8008e1 <vprintfmt+0x122>
  8008b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c1:	0f 49 d0             	cmovns %eax,%edx
  8008c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c7:	8b 75 10             	mov    0x10(%ebp),%esi
  8008ca:	e9 68 ff ff ff       	jmp    800837 <vprintfmt+0x78>
  8008cf:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d9:	e9 59 ff ff ff       	jmp    800837 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008de:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008e5:	0f 89 4c ff ff ff    	jns    800837 <vprintfmt+0x78>
				width = precision, precision = -1;
  8008eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f8:	e9 3a ff ff ff       	jmp    800837 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008fd:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800901:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800904:	e9 2e ff ff ff       	jmp    800837 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800909:	8b 45 14             	mov    0x14(%ebp),%eax
  80090c:	8d 50 04             	lea    0x4(%eax),%edx
  80090f:	89 55 14             	mov    %edx,0x14(%ebp)
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	53                   	push   %ebx
  800916:	ff 30                	pushl  (%eax)
  800918:	ff d7                	call   *%edi
			break;
  80091a:	83 c4 10             	add    $0x10,%esp
  80091d:	e9 b1 fe ff ff       	jmp    8007d3 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8d 50 04             	lea    0x4(%eax),%edx
  800928:	89 55 14             	mov    %edx,0x14(%ebp)
  80092b:	8b 00                	mov    (%eax),%eax
  80092d:	99                   	cltd   
  80092e:	31 d0                	xor    %edx,%eax
  800930:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800932:	83 f8 08             	cmp    $0x8,%eax
  800935:	7f 0b                	jg     800942 <vprintfmt+0x183>
  800937:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  80093e:	85 d2                	test   %edx,%edx
  800940:	75 15                	jne    800957 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800942:	50                   	push   %eax
  800943:	68 57 14 80 00       	push   $0x801457
  800948:	53                   	push   %ebx
  800949:	57                   	push   %edi
  80094a:	e8 53 fe ff ff       	call   8007a2 <printfmt>
  80094f:	83 c4 10             	add    $0x10,%esp
  800952:	e9 7c fe ff ff       	jmp    8007d3 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800957:	52                   	push   %edx
  800958:	68 60 14 80 00       	push   $0x801460
  80095d:	53                   	push   %ebx
  80095e:	57                   	push   %edi
  80095f:	e8 3e fe ff ff       	call   8007a2 <printfmt>
  800964:	83 c4 10             	add    $0x10,%esp
  800967:	e9 67 fe ff ff       	jmp    8007d3 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80096c:	8b 45 14             	mov    0x14(%ebp),%eax
  80096f:	8d 50 04             	lea    0x4(%eax),%edx
  800972:	89 55 14             	mov    %edx,0x14(%ebp)
  800975:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800977:	85 c0                	test   %eax,%eax
  800979:	b9 50 14 80 00       	mov    $0x801450,%ecx
  80097e:	0f 45 c8             	cmovne %eax,%ecx
  800981:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800984:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800988:	7e 06                	jle    800990 <vprintfmt+0x1d1>
  80098a:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80098e:	75 19                	jne    8009a9 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800990:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800993:	8d 70 01             	lea    0x1(%eax),%esi
  800996:	0f b6 00             	movzbl (%eax),%eax
  800999:	0f be d0             	movsbl %al,%edx
  80099c:	85 d2                	test   %edx,%edx
  80099e:	0f 85 9f 00 00 00    	jne    800a43 <vprintfmt+0x284>
  8009a4:	e9 8c 00 00 00       	jmp    800a35 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a9:	83 ec 08             	sub    $0x8,%esp
  8009ac:	ff 75 d0             	pushl  -0x30(%ebp)
  8009af:	ff 75 cc             	pushl  -0x34(%ebp)
  8009b2:	e8 62 03 00 00       	call   800d19 <strnlen>
  8009b7:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009ba:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009bd:	83 c4 10             	add    $0x10,%esp
  8009c0:	85 c9                	test   %ecx,%ecx
  8009c2:	0f 8e a6 02 00 00    	jle    800c6e <vprintfmt+0x4af>
					putch(padc, putdat);
  8009c8:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009cc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009cf:	89 cb                	mov    %ecx,%ebx
  8009d1:	83 ec 08             	sub    $0x8,%esp
  8009d4:	ff 75 0c             	pushl  0xc(%ebp)
  8009d7:	56                   	push   %esi
  8009d8:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	83 eb 01             	sub    $0x1,%ebx
  8009e0:	75 ef                	jne    8009d1 <vprintfmt+0x212>
  8009e2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e8:	e9 81 02 00 00       	jmp    800c6e <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f1:	74 1b                	je     800a0e <vprintfmt+0x24f>
  8009f3:	0f be c0             	movsbl %al,%eax
  8009f6:	83 e8 20             	sub    $0x20,%eax
  8009f9:	83 f8 5e             	cmp    $0x5e,%eax
  8009fc:	76 10                	jbe    800a0e <vprintfmt+0x24f>
					putch('?', putdat);
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	ff 75 0c             	pushl  0xc(%ebp)
  800a04:	6a 3f                	push   $0x3f
  800a06:	ff 55 08             	call   *0x8(%ebp)
  800a09:	83 c4 10             	add    $0x10,%esp
  800a0c:	eb 0d                	jmp    800a1b <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a0e:	83 ec 08             	sub    $0x8,%esp
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	52                   	push   %edx
  800a15:	ff 55 08             	call   *0x8(%ebp)
  800a18:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1b:	83 ef 01             	sub    $0x1,%edi
  800a1e:	83 c6 01             	add    $0x1,%esi
  800a21:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a25:	0f be d0             	movsbl %al,%edx
  800a28:	85 d2                	test   %edx,%edx
  800a2a:	75 31                	jne    800a5d <vprintfmt+0x29e>
  800a2c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a35:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a38:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a3c:	7f 33                	jg     800a71 <vprintfmt+0x2b2>
  800a3e:	e9 90 fd ff ff       	jmp    8007d3 <vprintfmt+0x14>
  800a43:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a49:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a4c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a4f:	eb 0c                	jmp    800a5d <vprintfmt+0x29e>
  800a51:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a57:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a5a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5d:	85 db                	test   %ebx,%ebx
  800a5f:	78 8c                	js     8009ed <vprintfmt+0x22e>
  800a61:	83 eb 01             	sub    $0x1,%ebx
  800a64:	79 87                	jns    8009ed <vprintfmt+0x22e>
  800a66:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a69:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6f:	eb c4                	jmp    800a35 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a71:	83 ec 08             	sub    $0x8,%esp
  800a74:	53                   	push   %ebx
  800a75:	6a 20                	push   $0x20
  800a77:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a79:	83 c4 10             	add    $0x10,%esp
  800a7c:	83 ee 01             	sub    $0x1,%esi
  800a7f:	75 f0                	jne    800a71 <vprintfmt+0x2b2>
  800a81:	e9 4d fd ff ff       	jmp    8007d3 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a86:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800a8a:	7e 16                	jle    800aa2 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 08             	lea    0x8(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)
  800a95:	8b 50 04             	mov    0x4(%eax),%edx
  800a98:	8b 00                	mov    (%eax),%eax
  800a9a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a9d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800aa0:	eb 34                	jmp    800ad6 <vprintfmt+0x317>
	else if (lflag)
  800aa2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800aa6:	74 18                	je     800ac0 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800aa8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aab:	8d 50 04             	lea    0x4(%eax),%edx
  800aae:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab1:	8b 30                	mov    (%eax),%esi
  800ab3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ab6:	89 f0                	mov    %esi,%eax
  800ab8:	c1 f8 1f             	sar    $0x1f,%eax
  800abb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800abe:	eb 16                	jmp    800ad6 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ac0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac3:	8d 50 04             	lea    0x4(%eax),%edx
  800ac6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac9:	8b 30                	mov    (%eax),%esi
  800acb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ace:	89 f0                	mov    %esi,%eax
  800ad0:	c1 f8 1f             	sar    $0x1f,%eax
  800ad3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ad9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800adc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adf:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800ae2:	85 d2                	test   %edx,%edx
  800ae4:	79 28                	jns    800b0e <vprintfmt+0x34f>
				putch('-', putdat);
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	53                   	push   %ebx
  800aea:	6a 2d                	push   $0x2d
  800aec:	ff d7                	call   *%edi
				num = -(long long) num;
  800aee:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800af1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800af4:	f7 d8                	neg    %eax
  800af6:	83 d2 00             	adc    $0x0,%edx
  800af9:	f7 da                	neg    %edx
  800afb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800afe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b01:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b09:	e9 b2 00 00 00       	jmp    800bc0 <vprintfmt+0x401>
  800b0e:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b13:	85 c9                	test   %ecx,%ecx
  800b15:	0f 84 a5 00 00 00    	je     800bc0 <vprintfmt+0x401>
				putch('+', putdat);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	53                   	push   %ebx
  800b1f:	6a 2b                	push   $0x2b
  800b21:	ff d7                	call   *%edi
  800b23:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b26:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2b:	e9 90 00 00 00       	jmp    800bc0 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b30:	85 c9                	test   %ecx,%ecx
  800b32:	74 0b                	je     800b3f <vprintfmt+0x380>
				putch('+', putdat);
  800b34:	83 ec 08             	sub    $0x8,%esp
  800b37:	53                   	push   %ebx
  800b38:	6a 2b                	push   $0x2b
  800b3a:	ff d7                	call   *%edi
  800b3c:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b3f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b42:	8d 45 14             	lea    0x14(%ebp),%eax
  800b45:	e8 01 fc ff ff       	call   80074b <getuint>
  800b4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b4d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b55:	eb 69                	jmp    800bc0 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b57:	83 ec 08             	sub    $0x8,%esp
  800b5a:	53                   	push   %ebx
  800b5b:	6a 30                	push   $0x30
  800b5d:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b5f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b62:	8d 45 14             	lea    0x14(%ebp),%eax
  800b65:	e8 e1 fb ff ff       	call   80074b <getuint>
  800b6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b6d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b70:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b73:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b78:	eb 46                	jmp    800bc0 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	6a 30                	push   $0x30
  800b80:	ff d7                	call   *%edi
			putch('x', putdat);
  800b82:	83 c4 08             	add    $0x8,%esp
  800b85:	53                   	push   %ebx
  800b86:	6a 78                	push   $0x78
  800b88:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8d:	8d 50 04             	lea    0x4(%eax),%edx
  800b90:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b93:	8b 00                	mov    (%eax),%eax
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b9d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ba0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ba3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800ba8:	eb 16                	jmp    800bc0 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800baa:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bad:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb0:	e8 96 fb ff ff       	call   80074b <getuint>
  800bb5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bb8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bbb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bc7:	56                   	push   %esi
  800bc8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bcb:	50                   	push   %eax
  800bcc:	ff 75 dc             	pushl  -0x24(%ebp)
  800bcf:	ff 75 d8             	pushl  -0x28(%ebp)
  800bd2:	89 da                	mov    %ebx,%edx
  800bd4:	89 f8                	mov    %edi,%eax
  800bd6:	e8 55 f9 ff ff       	call   800530 <printnum>
			break;
  800bdb:	83 c4 20             	add    $0x20,%esp
  800bde:	e9 f0 fb ff ff       	jmp    8007d3 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800be3:	8b 45 14             	mov    0x14(%ebp),%eax
  800be6:	8d 50 04             	lea    0x4(%eax),%edx
  800be9:	89 55 14             	mov    %edx,0x14(%ebp)
  800bec:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800bee:	85 f6                	test   %esi,%esi
  800bf0:	75 1a                	jne    800c0c <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800bf2:	83 ec 08             	sub    $0x8,%esp
  800bf5:	68 f8 14 80 00       	push   $0x8014f8
  800bfa:	68 60 14 80 00       	push   $0x801460
  800bff:	e8 18 f9 ff ff       	call   80051c <cprintf>
  800c04:	83 c4 10             	add    $0x10,%esp
  800c07:	e9 c7 fb ff ff       	jmp    8007d3 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c0c:	0f b6 03             	movzbl (%ebx),%eax
  800c0f:	84 c0                	test   %al,%al
  800c11:	79 1f                	jns    800c32 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c13:	83 ec 08             	sub    $0x8,%esp
  800c16:	68 30 15 80 00       	push   $0x801530
  800c1b:	68 60 14 80 00       	push   $0x801460
  800c20:	e8 f7 f8 ff ff       	call   80051c <cprintf>
						*tmp = *(char *)putdat;
  800c25:	0f b6 03             	movzbl (%ebx),%eax
  800c28:	88 06                	mov    %al,(%esi)
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	e9 a1 fb ff ff       	jmp    8007d3 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c32:	88 06                	mov    %al,(%esi)
  800c34:	e9 9a fb ff ff       	jmp    8007d3 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c39:	83 ec 08             	sub    $0x8,%esp
  800c3c:	53                   	push   %ebx
  800c3d:	52                   	push   %edx
  800c3e:	ff d7                	call   *%edi
			break;
  800c40:	83 c4 10             	add    $0x10,%esp
  800c43:	e9 8b fb ff ff       	jmp    8007d3 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c48:	83 ec 08             	sub    $0x8,%esp
  800c4b:	53                   	push   %ebx
  800c4c:	6a 25                	push   $0x25
  800c4e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c57:	0f 84 73 fb ff ff    	je     8007d0 <vprintfmt+0x11>
  800c5d:	83 ee 01             	sub    $0x1,%esi
  800c60:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c64:	75 f7                	jne    800c5d <vprintfmt+0x49e>
  800c66:	89 75 10             	mov    %esi,0x10(%ebp)
  800c69:	e9 65 fb ff ff       	jmp    8007d3 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c6e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c71:	8d 70 01             	lea    0x1(%eax),%esi
  800c74:	0f b6 00             	movzbl (%eax),%eax
  800c77:	0f be d0             	movsbl %al,%edx
  800c7a:	85 d2                	test   %edx,%edx
  800c7c:	0f 85 cf fd ff ff    	jne    800a51 <vprintfmt+0x292>
  800c82:	e9 4c fb ff ff       	jmp    8007d3 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 18             	sub    $0x18,%esp
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c9e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	74 26                	je     800cd6 <vsnprintf+0x47>
  800cb0:	85 d2                	test   %edx,%edx
  800cb2:	7e 22                	jle    800cd6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb4:	ff 75 14             	pushl  0x14(%ebp)
  800cb7:	ff 75 10             	pushl  0x10(%ebp)
  800cba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cbd:	50                   	push   %eax
  800cbe:	68 85 07 80 00       	push   $0x800785
  800cc3:	e8 f7 fa ff ff       	call   8007bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ccb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd1:	83 c4 10             	add    $0x10,%esp
  800cd4:	eb 05                	jmp    800cdb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ce6:	50                   	push   %eax
  800ce7:	ff 75 10             	pushl  0x10(%ebp)
  800cea:	ff 75 0c             	pushl  0xc(%ebp)
  800ced:	ff 75 08             	pushl  0x8(%ebp)
  800cf0:	e8 9a ff ff ff       	call   800c8f <vsnprintf>
	va_end(ap);

	return rc;
}
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cfd:	80 3a 00             	cmpb   $0x0,(%edx)
  800d00:	74 10                	je     800d12 <strlen+0x1b>
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d07:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d0a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d0e:	75 f7                	jne    800d07 <strlen+0x10>
  800d10:	eb 05                	jmp    800d17 <strlen+0x20>
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	53                   	push   %ebx
  800d1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d23:	85 c9                	test   %ecx,%ecx
  800d25:	74 1c                	je     800d43 <strnlen+0x2a>
  800d27:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d2a:	74 1e                	je     800d4a <strnlen+0x31>
  800d2c:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d31:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d33:	39 ca                	cmp    %ecx,%edx
  800d35:	74 18                	je     800d4f <strnlen+0x36>
  800d37:	83 c2 01             	add    $0x1,%edx
  800d3a:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d3f:	75 f0                	jne    800d31 <strnlen+0x18>
  800d41:	eb 0c                	jmp    800d4f <strnlen+0x36>
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
  800d48:	eb 05                	jmp    800d4f <strnlen+0x36>
  800d4a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	53                   	push   %ebx
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	83 c2 01             	add    $0x1,%edx
  800d61:	83 c1 01             	add    $0x1,%ecx
  800d64:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d68:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d6b:	84 db                	test   %bl,%bl
  800d6d:	75 ef                	jne    800d5e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	53                   	push   %ebx
  800d76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d79:	53                   	push   %ebx
  800d7a:	e8 78 ff ff ff       	call   800cf7 <strlen>
  800d7f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d82:	ff 75 0c             	pushl  0xc(%ebp)
  800d85:	01 d8                	add    %ebx,%eax
  800d87:	50                   	push   %eax
  800d88:	e8 c5 ff ff ff       	call   800d52 <strcpy>
	return dst;
}
  800d8d:	89 d8                	mov    %ebx,%eax
  800d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da2:	85 db                	test   %ebx,%ebx
  800da4:	74 17                	je     800dbd <strncpy+0x29>
  800da6:	01 f3                	add    %esi,%ebx
  800da8:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800daa:	83 c1 01             	add    $0x1,%ecx
  800dad:	0f b6 02             	movzbl (%edx),%eax
  800db0:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800db3:	80 3a 01             	cmpb   $0x1,(%edx)
  800db6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db9:	39 cb                	cmp    %ecx,%ebx
  800dbb:	75 ed                	jne    800daa <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800dcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dce:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dd3:	85 d2                	test   %edx,%edx
  800dd5:	74 35                	je     800e0c <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800dd7:	89 d0                	mov    %edx,%eax
  800dd9:	83 e8 01             	sub    $0x1,%eax
  800ddc:	74 25                	je     800e03 <strlcpy+0x40>
  800dde:	0f b6 0b             	movzbl (%ebx),%ecx
  800de1:	84 c9                	test   %cl,%cl
  800de3:	74 22                	je     800e07 <strlcpy+0x44>
  800de5:	8d 53 01             	lea    0x1(%ebx),%edx
  800de8:	01 c3                	add    %eax,%ebx
  800dea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800dec:	83 c0 01             	add    $0x1,%eax
  800def:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df2:	39 da                	cmp    %ebx,%edx
  800df4:	74 13                	je     800e09 <strlcpy+0x46>
  800df6:	83 c2 01             	add    $0x1,%edx
  800df9:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800dfd:	84 c9                	test   %cl,%cl
  800dff:	75 eb                	jne    800dec <strlcpy+0x29>
  800e01:	eb 06                	jmp    800e09 <strlcpy+0x46>
  800e03:	89 f0                	mov    %esi,%eax
  800e05:	eb 02                	jmp    800e09 <strlcpy+0x46>
  800e07:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e09:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e0c:	29 f0                	sub    %esi,%eax
}
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e18:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e1b:	0f b6 01             	movzbl (%ecx),%eax
  800e1e:	84 c0                	test   %al,%al
  800e20:	74 15                	je     800e37 <strcmp+0x25>
  800e22:	3a 02                	cmp    (%edx),%al
  800e24:	75 11                	jne    800e37 <strcmp+0x25>
		p++, q++;
  800e26:	83 c1 01             	add    $0x1,%ecx
  800e29:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e2c:	0f b6 01             	movzbl (%ecx),%eax
  800e2f:	84 c0                	test   %al,%al
  800e31:	74 04                	je     800e37 <strcmp+0x25>
  800e33:	3a 02                	cmp    (%edx),%al
  800e35:	74 ef                	je     800e26 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e37:	0f b6 c0             	movzbl %al,%eax
  800e3a:	0f b6 12             	movzbl (%edx),%edx
  800e3d:	29 d0                	sub    %edx,%eax
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
  800e46:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4c:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e4f:	85 f6                	test   %esi,%esi
  800e51:	74 29                	je     800e7c <strncmp+0x3b>
  800e53:	0f b6 03             	movzbl (%ebx),%eax
  800e56:	84 c0                	test   %al,%al
  800e58:	74 30                	je     800e8a <strncmp+0x49>
  800e5a:	3a 02                	cmp    (%edx),%al
  800e5c:	75 2c                	jne    800e8a <strncmp+0x49>
  800e5e:	8d 43 01             	lea    0x1(%ebx),%eax
  800e61:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e63:	89 c3                	mov    %eax,%ebx
  800e65:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e68:	39 c6                	cmp    %eax,%esi
  800e6a:	74 17                	je     800e83 <strncmp+0x42>
  800e6c:	0f b6 08             	movzbl (%eax),%ecx
  800e6f:	84 c9                	test   %cl,%cl
  800e71:	74 17                	je     800e8a <strncmp+0x49>
  800e73:	83 c0 01             	add    $0x1,%eax
  800e76:	3a 0a                	cmp    (%edx),%cl
  800e78:	74 e9                	je     800e63 <strncmp+0x22>
  800e7a:	eb 0e                	jmp    800e8a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e81:	eb 0f                	jmp    800e92 <strncmp+0x51>
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
  800e88:	eb 08                	jmp    800e92 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e8a:	0f b6 03             	movzbl (%ebx),%eax
  800e8d:	0f b6 12             	movzbl (%edx),%edx
  800e90:	29 d0                	sub    %edx,%eax
}
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	53                   	push   %ebx
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ea0:	0f b6 10             	movzbl (%eax),%edx
  800ea3:	84 d2                	test   %dl,%dl
  800ea5:	74 1d                	je     800ec4 <strchr+0x2e>
  800ea7:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ea9:	38 d3                	cmp    %dl,%bl
  800eab:	75 06                	jne    800eb3 <strchr+0x1d>
  800ead:	eb 1a                	jmp    800ec9 <strchr+0x33>
  800eaf:	38 ca                	cmp    %cl,%dl
  800eb1:	74 16                	je     800ec9 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eb3:	83 c0 01             	add    $0x1,%eax
  800eb6:	0f b6 10             	movzbl (%eax),%edx
  800eb9:	84 d2                	test   %dl,%dl
  800ebb:	75 f2                	jne    800eaf <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec2:	eb 05                	jmp    800ec9 <strchr+0x33>
  800ec4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec9:	5b                   	pop    %ebx
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	53                   	push   %ebx
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ed6:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ed9:	38 d3                	cmp    %dl,%bl
  800edb:	74 14                	je     800ef1 <strfind+0x25>
  800edd:	89 d1                	mov    %edx,%ecx
  800edf:	84 db                	test   %bl,%bl
  800ee1:	74 0e                	je     800ef1 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ee3:	83 c0 01             	add    $0x1,%eax
  800ee6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ee9:	38 ca                	cmp    %cl,%dl
  800eeb:	74 04                	je     800ef1 <strfind+0x25>
  800eed:	84 d2                	test   %dl,%dl
  800eef:	75 f2                	jne    800ee3 <strfind+0x17>
			break;
	return (char *) s;
}
  800ef1:	5b                   	pop    %ebx
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800efd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f00:	85 c9                	test   %ecx,%ecx
  800f02:	74 36                	je     800f3a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f0a:	75 28                	jne    800f34 <memset+0x40>
  800f0c:	f6 c1 03             	test   $0x3,%cl
  800f0f:	75 23                	jne    800f34 <memset+0x40>
		c &= 0xFF;
  800f11:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f15:	89 d3                	mov    %edx,%ebx
  800f17:	c1 e3 08             	shl    $0x8,%ebx
  800f1a:	89 d6                	mov    %edx,%esi
  800f1c:	c1 e6 18             	shl    $0x18,%esi
  800f1f:	89 d0                	mov    %edx,%eax
  800f21:	c1 e0 10             	shl    $0x10,%eax
  800f24:	09 f0                	or     %esi,%eax
  800f26:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	09 d0                	or     %edx,%eax
  800f2c:	c1 e9 02             	shr    $0x2,%ecx
  800f2f:	fc                   	cld    
  800f30:	f3 ab                	rep stos %eax,%es:(%edi)
  800f32:	eb 06                	jmp    800f3a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f37:	fc                   	cld    
  800f38:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f3a:	89 f8                	mov    %edi,%eax
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	57                   	push   %edi
  800f45:	56                   	push   %esi
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
  800f49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f4f:	39 c6                	cmp    %eax,%esi
  800f51:	73 35                	jae    800f88 <memmove+0x47>
  800f53:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f56:	39 d0                	cmp    %edx,%eax
  800f58:	73 2e                	jae    800f88 <memmove+0x47>
		s += n;
		d += n;
  800f5a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f5d:	89 d6                	mov    %edx,%esi
  800f5f:	09 fe                	or     %edi,%esi
  800f61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f67:	75 13                	jne    800f7c <memmove+0x3b>
  800f69:	f6 c1 03             	test   $0x3,%cl
  800f6c:	75 0e                	jne    800f7c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f6e:	83 ef 04             	sub    $0x4,%edi
  800f71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f74:	c1 e9 02             	shr    $0x2,%ecx
  800f77:	fd                   	std    
  800f78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f7a:	eb 09                	jmp    800f85 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f7c:	83 ef 01             	sub    $0x1,%edi
  800f7f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f82:	fd                   	std    
  800f83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f85:	fc                   	cld    
  800f86:	eb 1d                	jmp    800fa5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	09 c2                	or     %eax,%edx
  800f8c:	f6 c2 03             	test   $0x3,%dl
  800f8f:	75 0f                	jne    800fa0 <memmove+0x5f>
  800f91:	f6 c1 03             	test   $0x3,%cl
  800f94:	75 0a                	jne    800fa0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f96:	c1 e9 02             	shr    $0x2,%ecx
  800f99:	89 c7                	mov    %eax,%edi
  800f9b:	fc                   	cld    
  800f9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9e:	eb 05                	jmp    800fa5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fa0:	89 c7                	mov    %eax,%edi
  800fa2:	fc                   	cld    
  800fa3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fac:	ff 75 10             	pushl  0x10(%ebp)
  800faf:	ff 75 0c             	pushl  0xc(%ebp)
  800fb2:	ff 75 08             	pushl  0x8(%ebp)
  800fb5:	e8 87 ff ff ff       	call   800f41 <memmove>
}
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    

00800fbc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	57                   	push   %edi
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
  800fc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc8:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	74 39                	je     801008 <memcmp+0x4c>
  800fcf:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800fd2:	0f b6 13             	movzbl (%ebx),%edx
  800fd5:	0f b6 0e             	movzbl (%esi),%ecx
  800fd8:	38 ca                	cmp    %cl,%dl
  800fda:	75 17                	jne    800ff3 <memcmp+0x37>
  800fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe1:	eb 1a                	jmp    800ffd <memcmp+0x41>
  800fe3:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800fe8:	83 c0 01             	add    $0x1,%eax
  800feb:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800fef:	38 ca                	cmp    %cl,%dl
  800ff1:	74 0a                	je     800ffd <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ff3:	0f b6 c2             	movzbl %dl,%eax
  800ff6:	0f b6 c9             	movzbl %cl,%ecx
  800ff9:	29 c8                	sub    %ecx,%eax
  800ffb:	eb 10                	jmp    80100d <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ffd:	39 f8                	cmp    %edi,%eax
  800fff:	75 e2                	jne    800fe3 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801001:	b8 00 00 00 00       	mov    $0x0,%eax
  801006:	eb 05                	jmp    80100d <memcmp+0x51>
  801008:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	53                   	push   %ebx
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801019:	89 d0                	mov    %edx,%eax
  80101b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80101e:	39 c2                	cmp    %eax,%edx
  801020:	73 1d                	jae    80103f <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  801022:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801026:	0f b6 0a             	movzbl (%edx),%ecx
  801029:	39 d9                	cmp    %ebx,%ecx
  80102b:	75 09                	jne    801036 <memfind+0x24>
  80102d:	eb 14                	jmp    801043 <memfind+0x31>
  80102f:	0f b6 0a             	movzbl (%edx),%ecx
  801032:	39 d9                	cmp    %ebx,%ecx
  801034:	74 11                	je     801047 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801036:	83 c2 01             	add    $0x1,%edx
  801039:	39 d0                	cmp    %edx,%eax
  80103b:	75 f2                	jne    80102f <memfind+0x1d>
  80103d:	eb 0a                	jmp    801049 <memfind+0x37>
  80103f:	89 d0                	mov    %edx,%eax
  801041:	eb 06                	jmp    801049 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801043:	89 d0                	mov    %edx,%eax
  801045:	eb 02                	jmp    801049 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801047:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801049:	5b                   	pop    %ebx
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	53                   	push   %ebx
  801052:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801055:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801058:	0f b6 01             	movzbl (%ecx),%eax
  80105b:	3c 20                	cmp    $0x20,%al
  80105d:	74 04                	je     801063 <strtol+0x17>
  80105f:	3c 09                	cmp    $0x9,%al
  801061:	75 0e                	jne    801071 <strtol+0x25>
		s++;
  801063:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801066:	0f b6 01             	movzbl (%ecx),%eax
  801069:	3c 20                	cmp    $0x20,%al
  80106b:	74 f6                	je     801063 <strtol+0x17>
  80106d:	3c 09                	cmp    $0x9,%al
  80106f:	74 f2                	je     801063 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801071:	3c 2b                	cmp    $0x2b,%al
  801073:	75 0a                	jne    80107f <strtol+0x33>
		s++;
  801075:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801078:	bf 00 00 00 00       	mov    $0x0,%edi
  80107d:	eb 11                	jmp    801090 <strtol+0x44>
  80107f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801084:	3c 2d                	cmp    $0x2d,%al
  801086:	75 08                	jne    801090 <strtol+0x44>
		s++, neg = 1;
  801088:	83 c1 01             	add    $0x1,%ecx
  80108b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801090:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801096:	75 15                	jne    8010ad <strtol+0x61>
  801098:	80 39 30             	cmpb   $0x30,(%ecx)
  80109b:	75 10                	jne    8010ad <strtol+0x61>
  80109d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010a1:	75 7c                	jne    80111f <strtol+0xd3>
		s += 2, base = 16;
  8010a3:	83 c1 02             	add    $0x2,%ecx
  8010a6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010ab:	eb 16                	jmp    8010c3 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010ad:	85 db                	test   %ebx,%ebx
  8010af:	75 12                	jne    8010c3 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010b1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8010b9:	75 08                	jne    8010c3 <strtol+0x77>
		s++, base = 8;
  8010bb:	83 c1 01             	add    $0x1,%ecx
  8010be:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010cb:	0f b6 11             	movzbl (%ecx),%edx
  8010ce:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010d1:	89 f3                	mov    %esi,%ebx
  8010d3:	80 fb 09             	cmp    $0x9,%bl
  8010d6:	77 08                	ja     8010e0 <strtol+0x94>
			dig = *s - '0';
  8010d8:	0f be d2             	movsbl %dl,%edx
  8010db:	83 ea 30             	sub    $0x30,%edx
  8010de:	eb 22                	jmp    801102 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8010e0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010e3:	89 f3                	mov    %esi,%ebx
  8010e5:	80 fb 19             	cmp    $0x19,%bl
  8010e8:	77 08                	ja     8010f2 <strtol+0xa6>
			dig = *s - 'a' + 10;
  8010ea:	0f be d2             	movsbl %dl,%edx
  8010ed:	83 ea 57             	sub    $0x57,%edx
  8010f0:	eb 10                	jmp    801102 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  8010f2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010f5:	89 f3                	mov    %esi,%ebx
  8010f7:	80 fb 19             	cmp    $0x19,%bl
  8010fa:	77 16                	ja     801112 <strtol+0xc6>
			dig = *s - 'A' + 10;
  8010fc:	0f be d2             	movsbl %dl,%edx
  8010ff:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801102:	3b 55 10             	cmp    0x10(%ebp),%edx
  801105:	7d 0b                	jge    801112 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801107:	83 c1 01             	add    $0x1,%ecx
  80110a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80110e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801110:	eb b9                	jmp    8010cb <strtol+0x7f>

	if (endptr)
  801112:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801116:	74 0d                	je     801125 <strtol+0xd9>
		*endptr = (char *) s;
  801118:	8b 75 0c             	mov    0xc(%ebp),%esi
  80111b:	89 0e                	mov    %ecx,(%esi)
  80111d:	eb 06                	jmp    801125 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80111f:	85 db                	test   %ebx,%ebx
  801121:	74 98                	je     8010bb <strtol+0x6f>
  801123:	eb 9e                	jmp    8010c3 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801125:	89 c2                	mov    %eax,%edx
  801127:	f7 da                	neg    %edx
  801129:	85 ff                	test   %edi,%edi
  80112b:	0f 45 c2             	cmovne %edx,%eax
}
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    
  801133:	66 90                	xchg   %ax,%ax
  801135:	66 90                	xchg   %ax,%ax
  801137:	66 90                	xchg   %ax,%ax
  801139:	66 90                	xchg   %ax,%ax
  80113b:	66 90                	xchg   %ax,%ax
  80113d:	66 90                	xchg   %ax,%ax
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
