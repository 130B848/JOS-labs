
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800052:	e8 f9 00 00 00       	call   800150 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	c1 e0 07             	shl    $0x7,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 66 00 00 00       	call   800100 <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	51                   	push   %ecx
  8000b4:	52                   	push   %edx
  8000b5:	53                   	push   %ebx
  8000b6:	54                   	push   %esp
  8000b7:	55                   	push   %ebp
  8000b8:	56                   	push   %esi
  8000b9:	57                   	push   %edi
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	8d 35 c4 00 80 00    	lea    0x8000c4,%esi
  8000c2:	0f 34                	sysenter 

008000c4 <label_21>:
  8000c4:	5f                   	pop    %edi
  8000c5:	5e                   	pop    %esi
  8000c6:	5d                   	pop    %ebp
  8000c7:	5c                   	pop    %esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5a                   	pop    %edx
  8000ca:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cb:	5b                   	pop    %ebx
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 ca                	mov    %ecx,%edx
  8000e0:	89 cb                	mov    %ecx,%ebx
  8000e2:	89 cf                	mov    %ecx,%edi
  8000e4:	51                   	push   %ecx
  8000e5:	52                   	push   %edx
  8000e6:	53                   	push   %ebx
  8000e7:	54                   	push   %esp
  8000e8:	55                   	push   %ebp
  8000e9:	56                   	push   %esi
  8000ea:	57                   	push   %edi
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	8d 35 f5 00 80 00    	lea    0x8000f5,%esi
  8000f3:	0f 34                	sysenter 

008000f5 <label_55>:
  8000f5:	5f                   	pop    %edi
  8000f6:	5e                   	pop    %esi
  8000f7:	5d                   	pop    %ebp
  8000f8:	5c                   	pop    %esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5a                   	pop    %edx
  8000fb:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	57                   	push   %edi
  800104:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800105:	bb 00 00 00 00       	mov    $0x0,%ebx
  80010a:	b8 03 00 00 00       	mov    $0x3,%eax
  80010f:	8b 55 08             	mov    0x8(%ebp),%edx
  800112:	89 d9                	mov    %ebx,%ecx
  800114:	89 df                	mov    %ebx,%edi
  800116:	51                   	push   %ecx
  800117:	52                   	push   %edx
  800118:	53                   	push   %ebx
  800119:	54                   	push   %esp
  80011a:	55                   	push   %ebp
  80011b:	56                   	push   %esi
  80011c:	57                   	push   %edi
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	8d 35 27 01 80 00    	lea    0x800127,%esi
  800125:	0f 34                	sysenter 

00800127 <label_90>:
  800127:	5f                   	pop    %edi
  800128:	5e                   	pop    %esi
  800129:	5d                   	pop    %ebp
  80012a:	5c                   	pop    %esp
  80012b:	5b                   	pop    %ebx
  80012c:	5a                   	pop    %edx
  80012d:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	7e 17                	jle    800149 <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	50                   	push   %eax
  800136:	6a 03                	push   $0x3
  800138:	68 ea 13 80 00       	push   $0x8013ea
  80013d:	6a 2a                	push   $0x2a
  80013f:	68 07 14 80 00       	push   $0x801407
  800144:	e8 e5 02 00 00       	call   80042e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800149:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014c:	5b                   	pop    %ebx
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800155:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 ca                	mov    %ecx,%edx
  800161:	89 cb                	mov    %ecx,%ebx
  800163:	89 cf                	mov    %ecx,%edi
  800165:	51                   	push   %ecx
  800166:	52                   	push   %edx
  800167:	53                   	push   %ebx
  800168:	54                   	push   %esp
  800169:	55                   	push   %ebp
  80016a:	56                   	push   %esi
  80016b:	57                   	push   %edi
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	8d 35 76 01 80 00    	lea    0x800176,%esi
  800174:	0f 34                	sysenter 

00800176 <label_139>:
  800176:	5f                   	pop    %edi
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	5c                   	pop    %esp
  80017a:	5b                   	pop    %ebx
  80017b:	5a                   	pop    %edx
  80017c:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017d:	5b                   	pop    %ebx
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800186:	bf 00 00 00 00       	mov    $0x0,%edi
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800193:	8b 55 08             	mov    0x8(%ebp),%edx
  800196:	89 fb                	mov    %edi,%ebx
  800198:	51                   	push   %ecx
  800199:	52                   	push   %edx
  80019a:	53                   	push   %ebx
  80019b:	54                   	push   %esp
  80019c:	55                   	push   %ebp
  80019d:	56                   	push   %esi
  80019e:	57                   	push   %edi
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	8d 35 a9 01 80 00    	lea    0x8001a9,%esi
  8001a7:	0f 34                	sysenter 

008001a9 <label_174>:
  8001a9:	5f                   	pop    %edi
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	5c                   	pop    %esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5a                   	pop    %edx
  8001af:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001b0:	5b                   	pop    %ebx
  8001b1:	5f                   	pop    %edi
  8001b2:	5d                   	pop    %ebp
  8001b3:	c3                   	ret    

008001b4 <sys_yield>:

void
sys_yield(void)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c3:	89 d1                	mov    %edx,%ecx
  8001c5:	89 d3                	mov    %edx,%ebx
  8001c7:	89 d7                	mov    %edx,%edi
  8001c9:	51                   	push   %ecx
  8001ca:	52                   	push   %edx
  8001cb:	53                   	push   %ebx
  8001cc:	54                   	push   %esp
  8001cd:	55                   	push   %ebp
  8001ce:	56                   	push   %esi
  8001cf:	57                   	push   %edi
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	8d 35 da 01 80 00    	lea    0x8001da,%esi
  8001d8:	0f 34                	sysenter 

008001da <label_209>:
  8001da:	5f                   	pop    %edi
  8001db:	5e                   	pop    %esi
  8001dc:	5d                   	pop    %ebp
  8001dd:	5c                   	pop    %esp
  8001de:	5b                   	pop    %ebx
  8001df:	5a                   	pop    %edx
  8001e0:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001e1:	5b                   	pop    %ebx
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fd:	51                   	push   %ecx
  8001fe:	52                   	push   %edx
  8001ff:	53                   	push   %ebx
  800200:	54                   	push   %esp
  800201:	55                   	push   %ebp
  800202:	56                   	push   %esi
  800203:	57                   	push   %edi
  800204:	89 e5                	mov    %esp,%ebp
  800206:	8d 35 0e 02 80 00    	lea    0x80020e,%esi
  80020c:	0f 34                	sysenter 

0080020e <label_244>:
  80020e:	5f                   	pop    %edi
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	5c                   	pop    %esp
  800212:	5b                   	pop    %ebx
  800213:	5a                   	pop    %edx
  800214:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800215:	85 c0                	test   %eax,%eax
  800217:	7e 17                	jle    800230 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	50                   	push   %eax
  80021d:	6a 05                	push   $0x5
  80021f:	68 ea 13 80 00       	push   $0x8013ea
  800224:	6a 2a                	push   $0x2a
  800226:	68 07 14 80 00       	push   $0x801407
  80022b:	e8 fe 01 00 00       	call   80042e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800230:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800233:	5b                   	pop    %ebx
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80023c:	b8 06 00 00 00       	mov    $0x6,%eax
  800241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80024d:	51                   	push   %ecx
  80024e:	52                   	push   %edx
  80024f:	53                   	push   %ebx
  800250:	54                   	push   %esp
  800251:	55                   	push   %ebp
  800252:	56                   	push   %esi
  800253:	57                   	push   %edi
  800254:	89 e5                	mov    %esp,%ebp
  800256:	8d 35 5e 02 80 00    	lea    0x80025e,%esi
  80025c:	0f 34                	sysenter 

0080025e <label_295>:
  80025e:	5f                   	pop    %edi
  80025f:	5e                   	pop    %esi
  800260:	5d                   	pop    %ebp
  800261:	5c                   	pop    %esp
  800262:	5b                   	pop    %ebx
  800263:	5a                   	pop    %edx
  800264:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800265:	85 c0                	test   %eax,%eax
  800267:	7e 17                	jle    800280 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	50                   	push   %eax
  80026d:	6a 06                	push   $0x6
  80026f:	68 ea 13 80 00       	push   $0x8013ea
  800274:	6a 2a                	push   $0x2a
  800276:	68 07 14 80 00       	push   $0x801407
  80027b:	e8 ae 01 00 00       	call   80042e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800280:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800283:	5b                   	pop    %ebx
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80028c:	bf 00 00 00 00       	mov    $0x0,%edi
  800291:	b8 07 00 00 00       	mov    $0x7,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 fb                	mov    %edi,%ebx
  80029e:	51                   	push   %ecx
  80029f:	52                   	push   %edx
  8002a0:	53                   	push   %ebx
  8002a1:	54                   	push   %esp
  8002a2:	55                   	push   %ebp
  8002a3:	56                   	push   %esi
  8002a4:	57                   	push   %edi
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	8d 35 af 02 80 00    	lea    0x8002af,%esi
  8002ad:	0f 34                	sysenter 

008002af <label_344>:
  8002af:	5f                   	pop    %edi
  8002b0:	5e                   	pop    %esi
  8002b1:	5d                   	pop    %ebp
  8002b2:	5c                   	pop    %esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5a                   	pop    %edx
  8002b5:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	7e 17                	jle    8002d1 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002ba:	83 ec 0c             	sub    $0xc,%esp
  8002bd:	50                   	push   %eax
  8002be:	6a 07                	push   $0x7
  8002c0:	68 ea 13 80 00       	push   $0x8013ea
  8002c5:	6a 2a                	push   $0x2a
  8002c7:	68 07 14 80 00       	push   $0x801407
  8002cc:	e8 5d 01 00 00       	call   80042e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8002e2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	89 fb                	mov    %edi,%ebx
  8002ef:	51                   	push   %ecx
  8002f0:	52                   	push   %edx
  8002f1:	53                   	push   %ebx
  8002f2:	54                   	push   %esp
  8002f3:	55                   	push   %ebp
  8002f4:	56                   	push   %esi
  8002f5:	57                   	push   %edi
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	8d 35 00 03 80 00    	lea    0x800300,%esi
  8002fe:	0f 34                	sysenter 

00800300 <label_393>:
  800300:	5f                   	pop    %edi
  800301:	5e                   	pop    %esi
  800302:	5d                   	pop    %ebp
  800303:	5c                   	pop    %esp
  800304:	5b                   	pop    %ebx
  800305:	5a                   	pop    %edx
  800306:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800307:	85 c0                	test   %eax,%eax
  800309:	7e 17                	jle    800322 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80030b:	83 ec 0c             	sub    $0xc,%esp
  80030e:	50                   	push   %eax
  80030f:	6a 09                	push   $0x9
  800311:	68 ea 13 80 00       	push   $0x8013ea
  800316:	6a 2a                	push   $0x2a
  800318:	68 07 14 80 00       	push   $0x801407
  80031d:	e8 0c 01 00 00       	call   80042e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800322:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800325:	5b                   	pop    %ebx
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80032e:	bf 00 00 00 00       	mov    $0x0,%edi
  800333:	b8 0a 00 00 00       	mov    $0xa,%eax
  800338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	89 fb                	mov    %edi,%ebx
  800340:	51                   	push   %ecx
  800341:	52                   	push   %edx
  800342:	53                   	push   %ebx
  800343:	54                   	push   %esp
  800344:	55                   	push   %ebp
  800345:	56                   	push   %esi
  800346:	57                   	push   %edi
  800347:	89 e5                	mov    %esp,%ebp
  800349:	8d 35 51 03 80 00    	lea    0x800351,%esi
  80034f:	0f 34                	sysenter 

00800351 <label_442>:
  800351:	5f                   	pop    %edi
  800352:	5e                   	pop    %esi
  800353:	5d                   	pop    %ebp
  800354:	5c                   	pop    %esp
  800355:	5b                   	pop    %ebx
  800356:	5a                   	pop    %edx
  800357:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800358:	85 c0                	test   %eax,%eax
  80035a:	7e 17                	jle    800373 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80035c:	83 ec 0c             	sub    $0xc,%esp
  80035f:	50                   	push   %eax
  800360:	6a 0a                	push   $0xa
  800362:	68 ea 13 80 00       	push   $0x8013ea
  800367:	6a 2a                	push   $0x2a
  800369:	68 07 14 80 00       	push   $0x801407
  80036e:	e8 bb 00 00 00       	call   80042e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800373:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800376:	5b                   	pop    %ebx
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80037f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800384:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800387:	8b 55 08             	mov    0x8(%ebp),%edx
  80038a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800390:	51                   	push   %ecx
  800391:	52                   	push   %edx
  800392:	53                   	push   %ebx
  800393:	54                   	push   %esp
  800394:	55                   	push   %ebp
  800395:	56                   	push   %esi
  800396:	57                   	push   %edi
  800397:	89 e5                	mov    %esp,%ebp
  800399:	8d 35 a1 03 80 00    	lea    0x8003a1,%esi
  80039f:	0f 34                	sysenter 

008003a1 <label_493>:
  8003a1:	5f                   	pop    %edi
  8003a2:	5e                   	pop    %esi
  8003a3:	5d                   	pop    %ebp
  8003a4:	5c                   	pop    %esp
  8003a5:	5b                   	pop    %ebx
  8003a6:	5a                   	pop    %edx
  8003a7:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003a8:	5b                   	pop    %ebx
  8003a9:	5f                   	pop    %edi
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003be:	89 d9                	mov    %ebx,%ecx
  8003c0:	89 df                	mov    %ebx,%edi
  8003c2:	51                   	push   %ecx
  8003c3:	52                   	push   %edx
  8003c4:	53                   	push   %ebx
  8003c5:	54                   	push   %esp
  8003c6:	55                   	push   %ebp
  8003c7:	56                   	push   %esi
  8003c8:	57                   	push   %edi
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	8d 35 d3 03 80 00    	lea    0x8003d3,%esi
  8003d1:	0f 34                	sysenter 

008003d3 <label_528>:
  8003d3:	5f                   	pop    %edi
  8003d4:	5e                   	pop    %esi
  8003d5:	5d                   	pop    %ebp
  8003d6:	5c                   	pop    %esp
  8003d7:	5b                   	pop    %ebx
  8003d8:	5a                   	pop    %edx
  8003d9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003da:	85 c0                	test   %eax,%eax
  8003dc:	7e 17                	jle    8003f5 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8003de:	83 ec 0c             	sub    $0xc,%esp
  8003e1:	50                   	push   %eax
  8003e2:	6a 0d                	push   $0xd
  8003e4:	68 ea 13 80 00       	push   $0x8013ea
  8003e9:	6a 2a                	push   $0x2a
  8003eb:	68 07 14 80 00       	push   $0x801407
  8003f0:	e8 39 00 00 00       	call   80042e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003f8:	5b                   	pop    %ebx
  8003f9:	5f                   	pop    %edi
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800401:	b9 00 00 00 00       	mov    $0x0,%ecx
  800406:	b8 0e 00 00 00       	mov    $0xe,%eax
  80040b:	8b 55 08             	mov    0x8(%ebp),%edx
  80040e:	89 cb                	mov    %ecx,%ebx
  800410:	89 cf                	mov    %ecx,%edi
  800412:	51                   	push   %ecx
  800413:	52                   	push   %edx
  800414:	53                   	push   %ebx
  800415:	54                   	push   %esp
  800416:	55                   	push   %ebp
  800417:	56                   	push   %esi
  800418:	57                   	push   %edi
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	8d 35 23 04 80 00    	lea    0x800423,%esi
  800421:	0f 34                	sysenter 

00800423 <label_577>:
  800423:	5f                   	pop    %edi
  800424:	5e                   	pop    %esi
  800425:	5d                   	pop    %ebp
  800426:	5c                   	pop    %esp
  800427:	5b                   	pop    %ebx
  800428:	5a                   	pop    %edx
  800429:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80042a:	5b                   	pop    %ebx
  80042b:	5f                   	pop    %edi
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	56                   	push   %esi
  800432:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800433:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800436:	a1 10 20 80 00       	mov    0x802010,%eax
  80043b:	85 c0                	test   %eax,%eax
  80043d:	74 11                	je     800450 <_panic+0x22>
		cprintf("%s: ", argv0);
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	50                   	push   %eax
  800443:	68 15 14 80 00       	push   $0x801415
  800448:	e8 d4 00 00 00       	call   800521 <cprintf>
  80044d:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800450:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800456:	e8 f5 fc ff ff       	call   800150 <sys_getenvid>
  80045b:	83 ec 0c             	sub    $0xc,%esp
  80045e:	ff 75 0c             	pushl  0xc(%ebp)
  800461:	ff 75 08             	pushl  0x8(%ebp)
  800464:	56                   	push   %esi
  800465:	50                   	push   %eax
  800466:	68 1c 14 80 00       	push   $0x80141c
  80046b:	e8 b1 00 00 00       	call   800521 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800470:	83 c4 18             	add    $0x18,%esp
  800473:	53                   	push   %ebx
  800474:	ff 75 10             	pushl  0x10(%ebp)
  800477:	e8 54 00 00 00       	call   8004d0 <vcprintf>
	cprintf("\n");
  80047c:	c7 04 24 1a 14 80 00 	movl   $0x80141a,(%esp)
  800483:	e8 99 00 00 00       	call   800521 <cprintf>
  800488:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048b:	cc                   	int3   
  80048c:	eb fd                	jmp    80048b <_panic+0x5d>

0080048e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	53                   	push   %ebx
  800492:	83 ec 04             	sub    $0x4,%esp
  800495:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800498:	8b 13                	mov    (%ebx),%edx
  80049a:	8d 42 01             	lea    0x1(%edx),%eax
  80049d:	89 03                	mov    %eax,(%ebx)
  80049f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ab:	75 1a                	jne    8004c7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	68 ff 00 00 00       	push   $0xff
  8004b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8004b8:	50                   	push   %eax
  8004b9:	e8 e1 fb ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  8004be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004c4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004c7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ce:	c9                   	leave  
  8004cf:	c3                   	ret    

008004d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e0:	00 00 00 
	b.cnt = 0;
  8004e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f9:	50                   	push   %eax
  8004fa:	68 8e 04 80 00       	push   $0x80048e
  8004ff:	e8 c0 02 00 00       	call   8007c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800504:	83 c4 08             	add    $0x8,%esp
  800507:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80050d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800513:	50                   	push   %eax
  800514:	e8 86 fb ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  800519:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800527:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80052a:	50                   	push   %eax
  80052b:	ff 75 08             	pushl  0x8(%ebp)
  80052e:	e8 9d ff ff ff       	call   8004d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800533:	c9                   	leave  
  800534:	c3                   	ret    

00800535 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	57                   	push   %edi
  800539:	56                   	push   %esi
  80053a:	53                   	push   %ebx
  80053b:	83 ec 1c             	sub    $0x1c,%esp
  80053e:	89 c7                	mov    %eax,%edi
  800540:	89 d6                	mov    %edx,%esi
  800542:	8b 45 08             	mov    0x8(%ebp),%eax
  800545:	8b 55 0c             	mov    0xc(%ebp),%edx
  800548:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800551:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800555:	0f 85 bf 00 00 00    	jne    80061a <printnum+0xe5>
  80055b:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800561:	0f 8d de 00 00 00    	jge    800645 <printnum+0x110>
		judge_time_for_space = width;
  800567:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  80056d:	e9 d3 00 00 00       	jmp    800645 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800572:	83 eb 01             	sub    $0x1,%ebx
  800575:	85 db                	test   %ebx,%ebx
  800577:	7f 37                	jg     8005b0 <printnum+0x7b>
  800579:	e9 ea 00 00 00       	jmp    800668 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80057e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800581:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	56                   	push   %esi
  80058a:	83 ec 04             	sub    $0x4,%esp
  80058d:	ff 75 dc             	pushl  -0x24(%ebp)
  800590:	ff 75 d8             	pushl  -0x28(%ebp)
  800593:	ff 75 e4             	pushl  -0x1c(%ebp)
  800596:	ff 75 e0             	pushl  -0x20(%ebp)
  800599:	e8 d2 0c 00 00       	call   801270 <__umoddi3>
  80059e:	83 c4 14             	add    $0x14,%esp
  8005a1:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  8005a8:	50                   	push   %eax
  8005a9:	ff d7                	call   *%edi
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	eb 16                	jmp    8005c6 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	56                   	push   %esi
  8005b4:	ff 75 18             	pushl  0x18(%ebp)
  8005b7:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	83 eb 01             	sub    $0x1,%ebx
  8005bf:	75 ef                	jne    8005b0 <printnum+0x7b>
  8005c1:	e9 a2 00 00 00       	jmp    800668 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005c6:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005cc:	0f 85 76 01 00 00    	jne    800748 <printnum+0x213>
		while(num_of_space-- > 0)
  8005d2:	a1 04 20 80 00       	mov    0x802004,%eax
  8005d7:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005da:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	7e 1d                	jle    800601 <printnum+0xcc>
			putch(' ', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	56                   	push   %esi
  8005e8:	6a 20                	push   $0x20
  8005ea:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8005ec:	a1 04 20 80 00       	mov    0x802004,%eax
  8005f1:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005f4:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005fa:	83 c4 10             	add    $0x10,%esp
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	7f e3                	jg     8005e4 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800601:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800608:	00 00 00 
		judge_time_for_space = 0;
  80060b:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800612:	00 00 00 
	}
}
  800615:	e9 2e 01 00 00       	jmp    800748 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80061a:	8b 45 10             	mov    0x10(%ebp),%eax
  80061d:	ba 00 00 00 00       	mov    $0x0,%edx
  800622:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800625:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800628:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062e:	83 fa 00             	cmp    $0x0,%edx
  800631:	0f 87 ba 00 00 00    	ja     8006f1 <printnum+0x1bc>
  800637:	3b 45 10             	cmp    0x10(%ebp),%eax
  80063a:	0f 83 b1 00 00 00    	jae    8006f1 <printnum+0x1bc>
  800640:	e9 2d ff ff ff       	jmp    800572 <printnum+0x3d>
  800645:	8b 45 10             	mov    0x10(%ebp),%eax
  800648:	ba 00 00 00 00       	mov    $0x0,%edx
  80064d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800650:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800653:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800656:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800659:	83 fa 00             	cmp    $0x0,%edx
  80065c:	77 37                	ja     800695 <printnum+0x160>
  80065e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800661:	73 32                	jae    800695 <printnum+0x160>
  800663:	e9 16 ff ff ff       	jmp    80057e <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	56                   	push   %esi
  80066c:	83 ec 04             	sub    $0x4,%esp
  80066f:	ff 75 dc             	pushl  -0x24(%ebp)
  800672:	ff 75 d8             	pushl  -0x28(%ebp)
  800675:	ff 75 e4             	pushl  -0x1c(%ebp)
  800678:	ff 75 e0             	pushl  -0x20(%ebp)
  80067b:	e8 f0 0b 00 00       	call   801270 <__umoddi3>
  800680:	83 c4 14             	add    $0x14,%esp
  800683:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  80068a:	50                   	push   %eax
  80068b:	ff d7                	call   *%edi
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	e9 b3 00 00 00       	jmp    800748 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800695:	83 ec 0c             	sub    $0xc,%esp
  800698:	ff 75 18             	pushl  0x18(%ebp)
  80069b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80069e:	50                   	push   %eax
  80069f:	ff 75 10             	pushl  0x10(%ebp)
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8006a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b1:	e8 8a 0a 00 00       	call   801140 <__udivdi3>
  8006b6:	83 c4 18             	add    $0x18,%esp
  8006b9:	52                   	push   %edx
  8006ba:	50                   	push   %eax
  8006bb:	89 f2                	mov    %esi,%edx
  8006bd:	89 f8                	mov    %edi,%eax
  8006bf:	e8 71 fe ff ff       	call   800535 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006c4:	83 c4 18             	add    $0x18,%esp
  8006c7:	56                   	push   %esi
  8006c8:	83 ec 04             	sub    $0x4,%esp
  8006cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d7:	e8 94 0b 00 00       	call   801270 <__umoddi3>
  8006dc:	83 c4 14             	add    $0x14,%esp
  8006df:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  8006e6:	50                   	push   %eax
  8006e7:	ff d7                	call   *%edi
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	e9 d5 fe ff ff       	jmp    8005c6 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f1:	83 ec 0c             	sub    $0xc,%esp
  8006f4:	ff 75 18             	pushl  0x18(%ebp)
  8006f7:	83 eb 01             	sub    $0x1,%ebx
  8006fa:	53                   	push   %ebx
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	ff 75 dc             	pushl  -0x24(%ebp)
  800704:	ff 75 d8             	pushl  -0x28(%ebp)
  800707:	ff 75 e4             	pushl  -0x1c(%ebp)
  80070a:	ff 75 e0             	pushl  -0x20(%ebp)
  80070d:	e8 2e 0a 00 00       	call   801140 <__udivdi3>
  800712:	83 c4 18             	add    $0x18,%esp
  800715:	52                   	push   %edx
  800716:	50                   	push   %eax
  800717:	89 f2                	mov    %esi,%edx
  800719:	89 f8                	mov    %edi,%eax
  80071b:	e8 15 fe ff ff       	call   800535 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800720:	83 c4 18             	add    $0x18,%esp
  800723:	56                   	push   %esi
  800724:	83 ec 04             	sub    $0x4,%esp
  800727:	ff 75 dc             	pushl  -0x24(%ebp)
  80072a:	ff 75 d8             	pushl  -0x28(%ebp)
  80072d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800730:	ff 75 e0             	pushl  -0x20(%ebp)
  800733:	e8 38 0b 00 00       	call   801270 <__umoddi3>
  800738:	83 c4 14             	add    $0x14,%esp
  80073b:	0f be 80 3f 14 80 00 	movsbl 0x80143f(%eax),%eax
  800742:	50                   	push   %eax
  800743:	ff d7                	call   *%edi
  800745:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800753:	83 fa 01             	cmp    $0x1,%edx
  800756:	7e 0e                	jle    800766 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800758:	8b 10                	mov    (%eax),%edx
  80075a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80075d:	89 08                	mov    %ecx,(%eax)
  80075f:	8b 02                	mov    (%edx),%eax
  800761:	8b 52 04             	mov    0x4(%edx),%edx
  800764:	eb 22                	jmp    800788 <getuint+0x38>
	else if (lflag)
  800766:	85 d2                	test   %edx,%edx
  800768:	74 10                	je     80077a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80076a:	8b 10                	mov    (%eax),%edx
  80076c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80076f:	89 08                	mov    %ecx,(%eax)
  800771:	8b 02                	mov    (%edx),%eax
  800773:	ba 00 00 00 00       	mov    $0x0,%edx
  800778:	eb 0e                	jmp    800788 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80077a:	8b 10                	mov    (%eax),%edx
  80077c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80077f:	89 08                	mov    %ecx,(%eax)
  800781:	8b 02                	mov    (%edx),%eax
  800783:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800790:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800794:	8b 10                	mov    (%eax),%edx
  800796:	3b 50 04             	cmp    0x4(%eax),%edx
  800799:	73 0a                	jae    8007a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80079b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80079e:	89 08                	mov    %ecx,(%eax)
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	88 02                	mov    %al,(%edx)
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	ff 75 08             	pushl  0x8(%ebp)
  8007ba:	e8 05 00 00 00       	call   8007c4 <vprintfmt>
	va_end(ap);
}
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	57                   	push   %edi
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 2c             	sub    $0x2c,%esp
  8007cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d3:	eb 03                	jmp    8007d8 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d5:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007db:	8d 70 01             	lea    0x1(%eax),%esi
  8007de:	0f b6 00             	movzbl (%eax),%eax
  8007e1:	83 f8 25             	cmp    $0x25,%eax
  8007e4:	74 27                	je     80080d <vprintfmt+0x49>
			if (ch == '\0')
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	75 0d                	jne    8007f7 <vprintfmt+0x33>
  8007ea:	e9 9d 04 00 00       	jmp    800c8c <vprintfmt+0x4c8>
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	0f 84 95 04 00 00    	je     800c8c <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007fe:	83 c6 01             	add    $0x1,%esi
  800801:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	83 f8 25             	cmp    $0x25,%eax
  80080b:	75 e2                	jne    8007ef <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800812:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800816:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80081d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800824:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80082b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800832:	eb 08                	jmp    80083c <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800834:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800837:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083c:	8d 46 01             	lea    0x1(%esi),%eax
  80083f:	89 45 10             	mov    %eax,0x10(%ebp)
  800842:	0f b6 06             	movzbl (%esi),%eax
  800845:	0f b6 d0             	movzbl %al,%edx
  800848:	83 e8 23             	sub    $0x23,%eax
  80084b:	3c 55                	cmp    $0x55,%al
  80084d:	0f 87 fa 03 00 00    	ja     800c4d <vprintfmt+0x489>
  800853:	0f b6 c0             	movzbl %al,%eax
  800856:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  80085d:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800860:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800864:	eb d6                	jmp    80083c <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800866:	8d 42 d0             	lea    -0x30(%edx),%eax
  800869:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80086c:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800870:	8d 50 d0             	lea    -0x30(%eax),%edx
  800873:	83 fa 09             	cmp    $0x9,%edx
  800876:	77 6b                	ja     8008e3 <vprintfmt+0x11f>
  800878:	8b 75 10             	mov    0x10(%ebp),%esi
  80087b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80087e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800881:	eb 09                	jmp    80088c <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800883:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800886:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80088a:	eb b0                	jmp    80083c <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80088c:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80088f:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800892:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800896:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800899:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80089c:	83 f9 09             	cmp    $0x9,%ecx
  80089f:	76 eb                	jbe    80088c <vprintfmt+0xc8>
  8008a1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008a4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008a7:	eb 3d                	jmp    8008e6 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ac:	8d 50 04             	lea    0x4(%eax),%edx
  8008af:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b2:	8b 00                	mov    (%eax),%eax
  8008b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ba:	eb 2a                	jmp    8008e6 <vprintfmt+0x122>
  8008bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c6:	0f 49 d0             	cmovns %eax,%edx
  8008c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cc:	8b 75 10             	mov    0x10(%ebp),%esi
  8008cf:	e9 68 ff ff ff       	jmp    80083c <vprintfmt+0x78>
  8008d4:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008de:	e9 59 ff ff ff       	jmp    80083c <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e3:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ea:	0f 89 4c ff ff ff    	jns    80083c <vprintfmt+0x78>
				width = precision, precision = -1;
  8008f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008fd:	e9 3a ff ff ff       	jmp    80083c <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800902:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800906:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800909:	e9 2e ff ff ff       	jmp    80083c <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80090e:	8b 45 14             	mov    0x14(%ebp),%eax
  800911:	8d 50 04             	lea    0x4(%eax),%edx
  800914:	89 55 14             	mov    %edx,0x14(%ebp)
  800917:	83 ec 08             	sub    $0x8,%esp
  80091a:	53                   	push   %ebx
  80091b:	ff 30                	pushl  (%eax)
  80091d:	ff d7                	call   *%edi
			break;
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	e9 b1 fe ff ff       	jmp    8007d8 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800927:	8b 45 14             	mov    0x14(%ebp),%eax
  80092a:	8d 50 04             	lea    0x4(%eax),%edx
  80092d:	89 55 14             	mov    %edx,0x14(%ebp)
  800930:	8b 00                	mov    (%eax),%eax
  800932:	99                   	cltd   
  800933:	31 d0                	xor    %edx,%eax
  800935:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800937:	83 f8 08             	cmp    $0x8,%eax
  80093a:	7f 0b                	jg     800947 <vprintfmt+0x183>
  80093c:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  800943:	85 d2                	test   %edx,%edx
  800945:	75 15                	jne    80095c <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800947:	50                   	push   %eax
  800948:	68 57 14 80 00       	push   $0x801457
  80094d:	53                   	push   %ebx
  80094e:	57                   	push   %edi
  80094f:	e8 53 fe ff ff       	call   8007a7 <printfmt>
  800954:	83 c4 10             	add    $0x10,%esp
  800957:	e9 7c fe ff ff       	jmp    8007d8 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80095c:	52                   	push   %edx
  80095d:	68 60 14 80 00       	push   $0x801460
  800962:	53                   	push   %ebx
  800963:	57                   	push   %edi
  800964:	e8 3e fe ff ff       	call   8007a7 <printfmt>
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	e9 67 fe ff ff       	jmp    8007d8 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 50 04             	lea    0x4(%eax),%edx
  800977:	89 55 14             	mov    %edx,0x14(%ebp)
  80097a:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80097c:	85 c0                	test   %eax,%eax
  80097e:	b9 50 14 80 00       	mov    $0x801450,%ecx
  800983:	0f 45 c8             	cmovne %eax,%ecx
  800986:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800989:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80098d:	7e 06                	jle    800995 <vprintfmt+0x1d1>
  80098f:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800993:	75 19                	jne    8009ae <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800995:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800998:	8d 70 01             	lea    0x1(%eax),%esi
  80099b:	0f b6 00             	movzbl (%eax),%eax
  80099e:	0f be d0             	movsbl %al,%edx
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	0f 85 9f 00 00 00    	jne    800a48 <vprintfmt+0x284>
  8009a9:	e9 8c 00 00 00       	jmp    800a3a <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ae:	83 ec 08             	sub    $0x8,%esp
  8009b1:	ff 75 d0             	pushl  -0x30(%ebp)
  8009b4:	ff 75 cc             	pushl  -0x34(%ebp)
  8009b7:	e8 62 03 00 00       	call   800d1e <strnlen>
  8009bc:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009c2:	83 c4 10             	add    $0x10,%esp
  8009c5:	85 c9                	test   %ecx,%ecx
  8009c7:	0f 8e a6 02 00 00    	jle    800c73 <vprintfmt+0x4af>
					putch(padc, putdat);
  8009cd:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009d4:	89 cb                	mov    %ecx,%ebx
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	ff 75 0c             	pushl  0xc(%ebp)
  8009dc:	56                   	push   %esi
  8009dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009df:	83 c4 10             	add    $0x10,%esp
  8009e2:	83 eb 01             	sub    $0x1,%ebx
  8009e5:	75 ef                	jne    8009d6 <vprintfmt+0x212>
  8009e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ed:	e9 81 02 00 00       	jmp    800c73 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f6:	74 1b                	je     800a13 <vprintfmt+0x24f>
  8009f8:	0f be c0             	movsbl %al,%eax
  8009fb:	83 e8 20             	sub    $0x20,%eax
  8009fe:	83 f8 5e             	cmp    $0x5e,%eax
  800a01:	76 10                	jbe    800a13 <vprintfmt+0x24f>
					putch('?', putdat);
  800a03:	83 ec 08             	sub    $0x8,%esp
  800a06:	ff 75 0c             	pushl  0xc(%ebp)
  800a09:	6a 3f                	push   $0x3f
  800a0b:	ff 55 08             	call   *0x8(%ebp)
  800a0e:	83 c4 10             	add    $0x10,%esp
  800a11:	eb 0d                	jmp    800a20 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	ff 75 0c             	pushl  0xc(%ebp)
  800a19:	52                   	push   %edx
  800a1a:	ff 55 08             	call   *0x8(%ebp)
  800a1d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a20:	83 ef 01             	sub    $0x1,%edi
  800a23:	83 c6 01             	add    $0x1,%esi
  800a26:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a2a:	0f be d0             	movsbl %al,%edx
  800a2d:	85 d2                	test   %edx,%edx
  800a2f:	75 31                	jne    800a62 <vprintfmt+0x29e>
  800a31:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a34:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a3d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a41:	7f 33                	jg     800a76 <vprintfmt+0x2b2>
  800a43:	e9 90 fd ff ff       	jmp    8007d8 <vprintfmt+0x14>
  800a48:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a4e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a51:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a54:	eb 0c                	jmp    800a62 <vprintfmt+0x29e>
  800a56:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a5f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a62:	85 db                	test   %ebx,%ebx
  800a64:	78 8c                	js     8009f2 <vprintfmt+0x22e>
  800a66:	83 eb 01             	sub    $0x1,%ebx
  800a69:	79 87                	jns    8009f2 <vprintfmt+0x22e>
  800a6b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a74:	eb c4                	jmp    800a3a <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a76:	83 ec 08             	sub    $0x8,%esp
  800a79:	53                   	push   %ebx
  800a7a:	6a 20                	push   $0x20
  800a7c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a7e:	83 c4 10             	add    $0x10,%esp
  800a81:	83 ee 01             	sub    $0x1,%esi
  800a84:	75 f0                	jne    800a76 <vprintfmt+0x2b2>
  800a86:	e9 4d fd ff ff       	jmp    8007d8 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8b:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800a8f:	7e 16                	jle    800aa7 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800a91:	8b 45 14             	mov    0x14(%ebp),%eax
  800a94:	8d 50 08             	lea    0x8(%eax),%edx
  800a97:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9a:	8b 50 04             	mov    0x4(%eax),%edx
  800a9d:	8b 00                	mov    (%eax),%eax
  800a9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800aa2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800aa5:	eb 34                	jmp    800adb <vprintfmt+0x317>
	else if (lflag)
  800aa7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800aab:	74 18                	je     800ac5 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800aad:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab0:	8d 50 04             	lea    0x4(%eax),%edx
  800ab3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab6:	8b 30                	mov    (%eax),%esi
  800ab8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800abb:	89 f0                	mov    %esi,%eax
  800abd:	c1 f8 1f             	sar    $0x1f,%eax
  800ac0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ac3:	eb 16                	jmp    800adb <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	8d 50 04             	lea    0x4(%eax),%edx
  800acb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ace:	8b 30                	mov    (%eax),%esi
  800ad0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ad3:	89 f0                	mov    %esi,%eax
  800ad5:	c1 f8 1f             	sar    $0x1f,%eax
  800ad8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800adb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ade:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ae1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800ae7:	85 d2                	test   %edx,%edx
  800ae9:	79 28                	jns    800b13 <vprintfmt+0x34f>
				putch('-', putdat);
  800aeb:	83 ec 08             	sub    $0x8,%esp
  800aee:	53                   	push   %ebx
  800aef:	6a 2d                	push   $0x2d
  800af1:	ff d7                	call   *%edi
				num = -(long long) num;
  800af3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800af6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800af9:	f7 d8                	neg    %eax
  800afb:	83 d2 00             	adc    $0x0,%edx
  800afe:	f7 da                	neg    %edx
  800b00:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b03:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b06:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0e:	e9 b2 00 00 00       	jmp    800bc5 <vprintfmt+0x401>
  800b13:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b18:	85 c9                	test   %ecx,%ecx
  800b1a:	0f 84 a5 00 00 00    	je     800bc5 <vprintfmt+0x401>
				putch('+', putdat);
  800b20:	83 ec 08             	sub    $0x8,%esp
  800b23:	53                   	push   %ebx
  800b24:	6a 2b                	push   $0x2b
  800b26:	ff d7                	call   *%edi
  800b28:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b30:	e9 90 00 00 00       	jmp    800bc5 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b35:	85 c9                	test   %ecx,%ecx
  800b37:	74 0b                	je     800b44 <vprintfmt+0x380>
				putch('+', putdat);
  800b39:	83 ec 08             	sub    $0x8,%esp
  800b3c:	53                   	push   %ebx
  800b3d:	6a 2b                	push   $0x2b
  800b3f:	ff d7                	call   *%edi
  800b41:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b44:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b47:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4a:	e8 01 fc ff ff       	call   800750 <getuint>
  800b4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b52:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b55:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b5a:	eb 69                	jmp    800bc5 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	53                   	push   %ebx
  800b60:	6a 30                	push   $0x30
  800b62:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b64:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b67:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6a:	e8 e1 fb ff ff       	call   800750 <getuint>
  800b6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b72:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b75:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b78:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b7d:	eb 46                	jmp    800bc5 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b7f:	83 ec 08             	sub    $0x8,%esp
  800b82:	53                   	push   %ebx
  800b83:	6a 30                	push   $0x30
  800b85:	ff d7                	call   *%edi
			putch('x', putdat);
  800b87:	83 c4 08             	add    $0x8,%esp
  800b8a:	53                   	push   %ebx
  800b8b:	6a 78                	push   $0x78
  800b8d:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b92:	8d 50 04             	lea    0x4(%eax),%edx
  800b95:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b98:	8b 00                	mov    (%eax),%eax
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ba2:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ba5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ba8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bad:	eb 16                	jmp    800bc5 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800baf:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bb2:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb5:	e8 96 fb ff ff       	call   800750 <getuint>
  800bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bbd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bc0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bcc:	56                   	push   %esi
  800bcd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bd0:	50                   	push   %eax
  800bd1:	ff 75 dc             	pushl  -0x24(%ebp)
  800bd4:	ff 75 d8             	pushl  -0x28(%ebp)
  800bd7:	89 da                	mov    %ebx,%edx
  800bd9:	89 f8                	mov    %edi,%eax
  800bdb:	e8 55 f9 ff ff       	call   800535 <printnum>
			break;
  800be0:	83 c4 20             	add    $0x20,%esp
  800be3:	e9 f0 fb ff ff       	jmp    8007d8 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800be8:	8b 45 14             	mov    0x14(%ebp),%eax
  800beb:	8d 50 04             	lea    0x4(%eax),%edx
  800bee:	89 55 14             	mov    %edx,0x14(%ebp)
  800bf1:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800bf3:	85 f6                	test   %esi,%esi
  800bf5:	75 1a                	jne    800c11 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800bf7:	83 ec 08             	sub    $0x8,%esp
  800bfa:	68 f8 14 80 00       	push   $0x8014f8
  800bff:	68 60 14 80 00       	push   $0x801460
  800c04:	e8 18 f9 ff ff       	call   800521 <cprintf>
  800c09:	83 c4 10             	add    $0x10,%esp
  800c0c:	e9 c7 fb ff ff       	jmp    8007d8 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c11:	0f b6 03             	movzbl (%ebx),%eax
  800c14:	84 c0                	test   %al,%al
  800c16:	79 1f                	jns    800c37 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c18:	83 ec 08             	sub    $0x8,%esp
  800c1b:	68 30 15 80 00       	push   $0x801530
  800c20:	68 60 14 80 00       	push   $0x801460
  800c25:	e8 f7 f8 ff ff       	call   800521 <cprintf>
						*tmp = *(char *)putdat;
  800c2a:	0f b6 03             	movzbl (%ebx),%eax
  800c2d:	88 06                	mov    %al,(%esi)
  800c2f:	83 c4 10             	add    $0x10,%esp
  800c32:	e9 a1 fb ff ff       	jmp    8007d8 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c37:	88 06                	mov    %al,(%esi)
  800c39:	e9 9a fb ff ff       	jmp    8007d8 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c3e:	83 ec 08             	sub    $0x8,%esp
  800c41:	53                   	push   %ebx
  800c42:	52                   	push   %edx
  800c43:	ff d7                	call   *%edi
			break;
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	e9 8b fb ff ff       	jmp    8007d8 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c4d:	83 ec 08             	sub    $0x8,%esp
  800c50:	53                   	push   %ebx
  800c51:	6a 25                	push   $0x25
  800c53:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c55:	83 c4 10             	add    $0x10,%esp
  800c58:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c5c:	0f 84 73 fb ff ff    	je     8007d5 <vprintfmt+0x11>
  800c62:	83 ee 01             	sub    $0x1,%esi
  800c65:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c69:	75 f7                	jne    800c62 <vprintfmt+0x49e>
  800c6b:	89 75 10             	mov    %esi,0x10(%ebp)
  800c6e:	e9 65 fb ff ff       	jmp    8007d8 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c73:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c76:	8d 70 01             	lea    0x1(%eax),%esi
  800c79:	0f b6 00             	movzbl (%eax),%eax
  800c7c:	0f be d0             	movsbl %al,%edx
  800c7f:	85 d2                	test   %edx,%edx
  800c81:	0f 85 cf fd ff ff    	jne    800a56 <vprintfmt+0x292>
  800c87:	e9 4c fb ff ff       	jmp    8007d8 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 18             	sub    $0x18,%esp
  800c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800caa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	74 26                	je     800cdb <vsnprintf+0x47>
  800cb5:	85 d2                	test   %edx,%edx
  800cb7:	7e 22                	jle    800cdb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb9:	ff 75 14             	pushl  0x14(%ebp)
  800cbc:	ff 75 10             	pushl  0x10(%ebp)
  800cbf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc2:	50                   	push   %eax
  800cc3:	68 8a 07 80 00       	push   $0x80078a
  800cc8:	e8 f7 fa ff ff       	call   8007c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ccd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd6:	83 c4 10             	add    $0x10,%esp
  800cd9:	eb 05                	jmp    800ce0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ceb:	50                   	push   %eax
  800cec:	ff 75 10             	pushl  0x10(%ebp)
  800cef:	ff 75 0c             	pushl  0xc(%ebp)
  800cf2:	ff 75 08             	pushl  0x8(%ebp)
  800cf5:	e8 9a ff ff ff       	call   800c94 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d02:	80 3a 00             	cmpb   $0x0,(%edx)
  800d05:	74 10                	je     800d17 <strlen+0x1b>
  800d07:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d0c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d0f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d13:	75 f7                	jne    800d0c <strlen+0x10>
  800d15:	eb 05                	jmp    800d1c <strlen+0x20>
  800d17:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	53                   	push   %ebx
  800d22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d28:	85 c9                	test   %ecx,%ecx
  800d2a:	74 1c                	je     800d48 <strnlen+0x2a>
  800d2c:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d2f:	74 1e                	je     800d4f <strnlen+0x31>
  800d31:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d36:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d38:	39 ca                	cmp    %ecx,%edx
  800d3a:	74 18                	je     800d54 <strnlen+0x36>
  800d3c:	83 c2 01             	add    $0x1,%edx
  800d3f:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d44:	75 f0                	jne    800d36 <strnlen+0x18>
  800d46:	eb 0c                	jmp    800d54 <strnlen+0x36>
  800d48:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4d:	eb 05                	jmp    800d54 <strnlen+0x36>
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d54:	5b                   	pop    %ebx
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	53                   	push   %ebx
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	83 c2 01             	add    $0x1,%edx
  800d66:	83 c1 01             	add    $0x1,%ecx
  800d69:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d6d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d70:	84 db                	test   %bl,%bl
  800d72:	75 ef                	jne    800d63 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d74:	5b                   	pop    %ebx
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	53                   	push   %ebx
  800d7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d7e:	53                   	push   %ebx
  800d7f:	e8 78 ff ff ff       	call   800cfc <strlen>
  800d84:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d87:	ff 75 0c             	pushl  0xc(%ebp)
  800d8a:	01 d8                	add    %ebx,%eax
  800d8c:	50                   	push   %eax
  800d8d:	e8 c5 ff ff ff       	call   800d57 <strcpy>
	return dst;
}
  800d92:	89 d8                	mov    %ebx,%eax
  800d94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800da1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da7:	85 db                	test   %ebx,%ebx
  800da9:	74 17                	je     800dc2 <strncpy+0x29>
  800dab:	01 f3                	add    %esi,%ebx
  800dad:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800daf:	83 c1 01             	add    $0x1,%ecx
  800db2:	0f b6 02             	movzbl (%edx),%eax
  800db5:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800db8:	80 3a 01             	cmpb   $0x1,(%edx)
  800dbb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dbe:	39 cb                	cmp    %ecx,%ebx
  800dc0:	75 ed                	jne    800daf <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dc2:	89 f0                	mov    %esi,%eax
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd3:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dd8:	85 d2                	test   %edx,%edx
  800dda:	74 35                	je     800e11 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800ddc:	89 d0                	mov    %edx,%eax
  800dde:	83 e8 01             	sub    $0x1,%eax
  800de1:	74 25                	je     800e08 <strlcpy+0x40>
  800de3:	0f b6 0b             	movzbl (%ebx),%ecx
  800de6:	84 c9                	test   %cl,%cl
  800de8:	74 22                	je     800e0c <strlcpy+0x44>
  800dea:	8d 53 01             	lea    0x1(%ebx),%edx
  800ded:	01 c3                	add    %eax,%ebx
  800def:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800df1:	83 c0 01             	add    $0x1,%eax
  800df4:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df7:	39 da                	cmp    %ebx,%edx
  800df9:	74 13                	je     800e0e <strlcpy+0x46>
  800dfb:	83 c2 01             	add    $0x1,%edx
  800dfe:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e02:	84 c9                	test   %cl,%cl
  800e04:	75 eb                	jne    800df1 <strlcpy+0x29>
  800e06:	eb 06                	jmp    800e0e <strlcpy+0x46>
  800e08:	89 f0                	mov    %esi,%eax
  800e0a:	eb 02                	jmp    800e0e <strlcpy+0x46>
  800e0c:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e0e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e11:	29 f0                	sub    %esi,%eax
}
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e20:	0f b6 01             	movzbl (%ecx),%eax
  800e23:	84 c0                	test   %al,%al
  800e25:	74 15                	je     800e3c <strcmp+0x25>
  800e27:	3a 02                	cmp    (%edx),%al
  800e29:	75 11                	jne    800e3c <strcmp+0x25>
		p++, q++;
  800e2b:	83 c1 01             	add    $0x1,%ecx
  800e2e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e31:	0f b6 01             	movzbl (%ecx),%eax
  800e34:	84 c0                	test   %al,%al
  800e36:	74 04                	je     800e3c <strcmp+0x25>
  800e38:	3a 02                	cmp    (%edx),%al
  800e3a:	74 ef                	je     800e2b <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e3c:	0f b6 c0             	movzbl %al,%eax
  800e3f:	0f b6 12             	movzbl (%edx),%edx
  800e42:	29 d0                	sub    %edx,%eax
}
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
  800e4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e51:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e54:	85 f6                	test   %esi,%esi
  800e56:	74 29                	je     800e81 <strncmp+0x3b>
  800e58:	0f b6 03             	movzbl (%ebx),%eax
  800e5b:	84 c0                	test   %al,%al
  800e5d:	74 30                	je     800e8f <strncmp+0x49>
  800e5f:	3a 02                	cmp    (%edx),%al
  800e61:	75 2c                	jne    800e8f <strncmp+0x49>
  800e63:	8d 43 01             	lea    0x1(%ebx),%eax
  800e66:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e68:	89 c3                	mov    %eax,%ebx
  800e6a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e6d:	39 c6                	cmp    %eax,%esi
  800e6f:	74 17                	je     800e88 <strncmp+0x42>
  800e71:	0f b6 08             	movzbl (%eax),%ecx
  800e74:	84 c9                	test   %cl,%cl
  800e76:	74 17                	je     800e8f <strncmp+0x49>
  800e78:	83 c0 01             	add    $0x1,%eax
  800e7b:	3a 0a                	cmp    (%edx),%cl
  800e7d:	74 e9                	je     800e68 <strncmp+0x22>
  800e7f:	eb 0e                	jmp    800e8f <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	eb 0f                	jmp    800e97 <strncmp+0x51>
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	eb 08                	jmp    800e97 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e8f:	0f b6 03             	movzbl (%ebx),%eax
  800e92:	0f b6 12             	movzbl (%edx),%edx
  800e95:	29 d0                	sub    %edx,%eax
}
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ea5:	0f b6 10             	movzbl (%eax),%edx
  800ea8:	84 d2                	test   %dl,%dl
  800eaa:	74 1d                	je     800ec9 <strchr+0x2e>
  800eac:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800eae:	38 d3                	cmp    %dl,%bl
  800eb0:	75 06                	jne    800eb8 <strchr+0x1d>
  800eb2:	eb 1a                	jmp    800ece <strchr+0x33>
  800eb4:	38 ca                	cmp    %cl,%dl
  800eb6:	74 16                	je     800ece <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eb8:	83 c0 01             	add    $0x1,%eax
  800ebb:	0f b6 10             	movzbl (%eax),%edx
  800ebe:	84 d2                	test   %dl,%dl
  800ec0:	75 f2                	jne    800eb4 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec7:	eb 05                	jmp    800ece <strchr+0x33>
  800ec9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ece:	5b                   	pop    %ebx
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	53                   	push   %ebx
  800ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800edb:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ede:	38 d3                	cmp    %dl,%bl
  800ee0:	74 14                	je     800ef6 <strfind+0x25>
  800ee2:	89 d1                	mov    %edx,%ecx
  800ee4:	84 db                	test   %bl,%bl
  800ee6:	74 0e                	je     800ef6 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ee8:	83 c0 01             	add    $0x1,%eax
  800eeb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800eee:	38 ca                	cmp    %cl,%dl
  800ef0:	74 04                	je     800ef6 <strfind+0x25>
  800ef2:	84 d2                	test   %dl,%dl
  800ef4:	75 f2                	jne    800ee8 <strfind+0x17>
			break;
	return (char *) s;
}
  800ef6:	5b                   	pop    %ebx
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f05:	85 c9                	test   %ecx,%ecx
  800f07:	74 36                	je     800f3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f0f:	75 28                	jne    800f39 <memset+0x40>
  800f11:	f6 c1 03             	test   $0x3,%cl
  800f14:	75 23                	jne    800f39 <memset+0x40>
		c &= 0xFF;
  800f16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f1a:	89 d3                	mov    %edx,%ebx
  800f1c:	c1 e3 08             	shl    $0x8,%ebx
  800f1f:	89 d6                	mov    %edx,%esi
  800f21:	c1 e6 18             	shl    $0x18,%esi
  800f24:	89 d0                	mov    %edx,%eax
  800f26:	c1 e0 10             	shl    $0x10,%eax
  800f29:	09 f0                	or     %esi,%eax
  800f2b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f2d:	89 d8                	mov    %ebx,%eax
  800f2f:	09 d0                	or     %edx,%eax
  800f31:	c1 e9 02             	shr    $0x2,%ecx
  800f34:	fc                   	cld    
  800f35:	f3 ab                	rep stos %eax,%es:(%edi)
  800f37:	eb 06                	jmp    800f3f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3c:	fc                   	cld    
  800f3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f3f:	89 f8                	mov    %edi,%eax
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f54:	39 c6                	cmp    %eax,%esi
  800f56:	73 35                	jae    800f8d <memmove+0x47>
  800f58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f5b:	39 d0                	cmp    %edx,%eax
  800f5d:	73 2e                	jae    800f8d <memmove+0x47>
		s += n;
		d += n;
  800f5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f62:	89 d6                	mov    %edx,%esi
  800f64:	09 fe                	or     %edi,%esi
  800f66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f6c:	75 13                	jne    800f81 <memmove+0x3b>
  800f6e:	f6 c1 03             	test   $0x3,%cl
  800f71:	75 0e                	jne    800f81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f73:	83 ef 04             	sub    $0x4,%edi
  800f76:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f79:	c1 e9 02             	shr    $0x2,%ecx
  800f7c:	fd                   	std    
  800f7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f7f:	eb 09                	jmp    800f8a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f81:	83 ef 01             	sub    $0x1,%edi
  800f84:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f87:	fd                   	std    
  800f88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f8a:	fc                   	cld    
  800f8b:	eb 1d                	jmp    800faa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	09 c2                	or     %eax,%edx
  800f91:	f6 c2 03             	test   $0x3,%dl
  800f94:	75 0f                	jne    800fa5 <memmove+0x5f>
  800f96:	f6 c1 03             	test   $0x3,%cl
  800f99:	75 0a                	jne    800fa5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f9b:	c1 e9 02             	shr    $0x2,%ecx
  800f9e:	89 c7                	mov    %eax,%edi
  800fa0:	fc                   	cld    
  800fa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fa3:	eb 05                	jmp    800faa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fa5:	89 c7                	mov    %eax,%edi
  800fa7:	fc                   	cld    
  800fa8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fb1:	ff 75 10             	pushl  0x10(%ebp)
  800fb4:	ff 75 0c             	pushl  0xc(%ebp)
  800fb7:	ff 75 08             	pushl  0x8(%ebp)
  800fba:	e8 87 ff ff ff       	call   800f46 <memmove>
}
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	57                   	push   %edi
  800fc5:	56                   	push   %esi
  800fc6:	53                   	push   %ebx
  800fc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fcd:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	74 39                	je     80100d <memcmp+0x4c>
  800fd4:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800fd7:	0f b6 13             	movzbl (%ebx),%edx
  800fda:	0f b6 0e             	movzbl (%esi),%ecx
  800fdd:	38 ca                	cmp    %cl,%dl
  800fdf:	75 17                	jne    800ff8 <memcmp+0x37>
  800fe1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe6:	eb 1a                	jmp    801002 <memcmp+0x41>
  800fe8:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800fed:	83 c0 01             	add    $0x1,%eax
  800ff0:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800ff4:	38 ca                	cmp    %cl,%dl
  800ff6:	74 0a                	je     801002 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ff8:	0f b6 c2             	movzbl %dl,%eax
  800ffb:	0f b6 c9             	movzbl %cl,%ecx
  800ffe:	29 c8                	sub    %ecx,%eax
  801000:	eb 10                	jmp    801012 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801002:	39 f8                	cmp    %edi,%eax
  801004:	75 e2                	jne    800fe8 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801006:	b8 00 00 00 00       	mov    $0x0,%eax
  80100b:	eb 05                	jmp    801012 <memcmp+0x51>
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5f                   	pop    %edi
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	53                   	push   %ebx
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  80101e:	89 d0                	mov    %edx,%eax
  801020:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801023:	39 c2                	cmp    %eax,%edx
  801025:	73 1d                	jae    801044 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  801027:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80102b:	0f b6 0a             	movzbl (%edx),%ecx
  80102e:	39 d9                	cmp    %ebx,%ecx
  801030:	75 09                	jne    80103b <memfind+0x24>
  801032:	eb 14                	jmp    801048 <memfind+0x31>
  801034:	0f b6 0a             	movzbl (%edx),%ecx
  801037:	39 d9                	cmp    %ebx,%ecx
  801039:	74 11                	je     80104c <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80103b:	83 c2 01             	add    $0x1,%edx
  80103e:	39 d0                	cmp    %edx,%eax
  801040:	75 f2                	jne    801034 <memfind+0x1d>
  801042:	eb 0a                	jmp    80104e <memfind+0x37>
  801044:	89 d0                	mov    %edx,%eax
  801046:	eb 06                	jmp    80104e <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801048:	89 d0                	mov    %edx,%eax
  80104a:	eb 02                	jmp    80104e <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80104c:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80104e:	5b                   	pop    %ebx
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80105d:	0f b6 01             	movzbl (%ecx),%eax
  801060:	3c 20                	cmp    $0x20,%al
  801062:	74 04                	je     801068 <strtol+0x17>
  801064:	3c 09                	cmp    $0x9,%al
  801066:	75 0e                	jne    801076 <strtol+0x25>
		s++;
  801068:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80106b:	0f b6 01             	movzbl (%ecx),%eax
  80106e:	3c 20                	cmp    $0x20,%al
  801070:	74 f6                	je     801068 <strtol+0x17>
  801072:	3c 09                	cmp    $0x9,%al
  801074:	74 f2                	je     801068 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801076:	3c 2b                	cmp    $0x2b,%al
  801078:	75 0a                	jne    801084 <strtol+0x33>
		s++;
  80107a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80107d:	bf 00 00 00 00       	mov    $0x0,%edi
  801082:	eb 11                	jmp    801095 <strtol+0x44>
  801084:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801089:	3c 2d                	cmp    $0x2d,%al
  80108b:	75 08                	jne    801095 <strtol+0x44>
		s++, neg = 1;
  80108d:	83 c1 01             	add    $0x1,%ecx
  801090:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801095:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80109b:	75 15                	jne    8010b2 <strtol+0x61>
  80109d:	80 39 30             	cmpb   $0x30,(%ecx)
  8010a0:	75 10                	jne    8010b2 <strtol+0x61>
  8010a2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010a6:	75 7c                	jne    801124 <strtol+0xd3>
		s += 2, base = 16;
  8010a8:	83 c1 02             	add    $0x2,%ecx
  8010ab:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010b0:	eb 16                	jmp    8010c8 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010b2:	85 db                	test   %ebx,%ebx
  8010b4:	75 12                	jne    8010c8 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010b6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010bb:	80 39 30             	cmpb   $0x30,(%ecx)
  8010be:	75 08                	jne    8010c8 <strtol+0x77>
		s++, base = 8;
  8010c0:	83 c1 01             	add    $0x1,%ecx
  8010c3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d0:	0f b6 11             	movzbl (%ecx),%edx
  8010d3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010d6:	89 f3                	mov    %esi,%ebx
  8010d8:	80 fb 09             	cmp    $0x9,%bl
  8010db:	77 08                	ja     8010e5 <strtol+0x94>
			dig = *s - '0';
  8010dd:	0f be d2             	movsbl %dl,%edx
  8010e0:	83 ea 30             	sub    $0x30,%edx
  8010e3:	eb 22                	jmp    801107 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8010e5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010e8:	89 f3                	mov    %esi,%ebx
  8010ea:	80 fb 19             	cmp    $0x19,%bl
  8010ed:	77 08                	ja     8010f7 <strtol+0xa6>
			dig = *s - 'a' + 10;
  8010ef:	0f be d2             	movsbl %dl,%edx
  8010f2:	83 ea 57             	sub    $0x57,%edx
  8010f5:	eb 10                	jmp    801107 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  8010f7:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010fa:	89 f3                	mov    %esi,%ebx
  8010fc:	80 fb 19             	cmp    $0x19,%bl
  8010ff:	77 16                	ja     801117 <strtol+0xc6>
			dig = *s - 'A' + 10;
  801101:	0f be d2             	movsbl %dl,%edx
  801104:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801107:	3b 55 10             	cmp    0x10(%ebp),%edx
  80110a:	7d 0b                	jge    801117 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  80110c:	83 c1 01             	add    $0x1,%ecx
  80110f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801113:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801115:	eb b9                	jmp    8010d0 <strtol+0x7f>

	if (endptr)
  801117:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80111b:	74 0d                	je     80112a <strtol+0xd9>
		*endptr = (char *) s;
  80111d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801120:	89 0e                	mov    %ecx,(%esi)
  801122:	eb 06                	jmp    80112a <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801124:	85 db                	test   %ebx,%ebx
  801126:	74 98                	je     8010c0 <strtol+0x6f>
  801128:	eb 9e                	jmp    8010c8 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	f7 da                	neg    %edx
  80112e:	85 ff                	test   %edi,%edi
  801130:	0f 45 c2             	cmovne %edx,%eax
}
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    
  801138:	66 90                	xchg   %ax,%ax
  80113a:	66 90                	xchg   %ax,%ax
  80113c:	66 90                	xchg   %ax,%ax
  80113e:	66 90                	xchg   %ax,%ax

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
