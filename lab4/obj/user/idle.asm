
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 e0 	movl   $0x8013e0,0x802000
  800040:	13 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 6f 01 00 00       	call   8001b7 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800055:	e8 f9 00 00 00       	call   800153 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// cprintf("env_id = %08x\n", sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 66 00 00 00       	call   800103 <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000af:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b2:	89 c3                	mov    %eax,%ebx
  8000b4:	89 c7                	mov    %eax,%edi
  8000b6:	51                   	push   %ecx
  8000b7:	52                   	push   %edx
  8000b8:	53                   	push   %ebx
  8000b9:	54                   	push   %esp
  8000ba:	55                   	push   %ebp
  8000bb:	56                   	push   %esi
  8000bc:	57                   	push   %edi
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	8d 35 c7 00 80 00    	lea    0x8000c7,%esi
  8000c5:	0f 34                	sysenter 

008000c7 <label_21>:
  8000c7:	5f                   	pop    %edi
  8000c8:	5e                   	pop    %esi
  8000c9:	5d                   	pop    %ebp
  8000ca:	5c                   	pop    %esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5a                   	pop    %edx
  8000cd:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 ca                	mov    %ecx,%edx
  8000e3:	89 cb                	mov    %ecx,%ebx
  8000e5:	89 cf                	mov    %ecx,%edi
  8000e7:	51                   	push   %ecx
  8000e8:	52                   	push   %edx
  8000e9:	53                   	push   %ebx
  8000ea:	54                   	push   %esp
  8000eb:	55                   	push   %ebp
  8000ec:	56                   	push   %esi
  8000ed:	57                   	push   %edi
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	8d 35 f8 00 80 00    	lea    0x8000f8,%esi
  8000f6:	0f 34                	sysenter 

008000f8 <label_55>:
  8000f8:	5f                   	pop    %edi
  8000f9:	5e                   	pop    %esi
  8000fa:	5d                   	pop    %ebp
  8000fb:	5c                   	pop    %esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5a                   	pop    %edx
  8000fe:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ff:	5b                   	pop    %ebx
  800100:	5f                   	pop    %edi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	57                   	push   %edi
  800107:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800108:	bb 00 00 00 00       	mov    $0x0,%ebx
  80010d:	b8 03 00 00 00       	mov    $0x3,%eax
  800112:	8b 55 08             	mov    0x8(%ebp),%edx
  800115:	89 d9                	mov    %ebx,%ecx
  800117:	89 df                	mov    %ebx,%edi
  800119:	51                   	push   %ecx
  80011a:	52                   	push   %edx
  80011b:	53                   	push   %ebx
  80011c:	54                   	push   %esp
  80011d:	55                   	push   %ebp
  80011e:	56                   	push   %esi
  80011f:	57                   	push   %edi
  800120:	89 e5                	mov    %esp,%ebp
  800122:	8d 35 2a 01 80 00    	lea    0x80012a,%esi
  800128:	0f 34                	sysenter 

0080012a <label_90>:
  80012a:	5f                   	pop    %edi
  80012b:	5e                   	pop    %esi
  80012c:	5d                   	pop    %ebp
  80012d:	5c                   	pop    %esp
  80012e:	5b                   	pop    %ebx
  80012f:	5a                   	pop    %edx
  800130:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7e 17                	jle    80014c <label_90+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	50                   	push   %eax
  800139:	6a 03                	push   $0x3
  80013b:	68 ef 13 80 00       	push   $0x8013ef
  800140:	6a 2a                	push   $0x2a
  800142:	68 0c 14 80 00       	push   $0x80140c
  800147:	e8 e5 02 00 00       	call   800431 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800158:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015d:	b8 02 00 00 00       	mov    $0x2,%eax
  800162:	89 ca                	mov    %ecx,%edx
  800164:	89 cb                	mov    %ecx,%ebx
  800166:	89 cf                	mov    %ecx,%edi
  800168:	51                   	push   %ecx
  800169:	52                   	push   %edx
  80016a:	53                   	push   %ebx
  80016b:	54                   	push   %esp
  80016c:	55                   	push   %ebp
  80016d:	56                   	push   %esi
  80016e:	57                   	push   %edi
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	8d 35 79 01 80 00    	lea    0x800179,%esi
  800177:	0f 34                	sysenter 

00800179 <label_139>:
  800179:	5f                   	pop    %edi
  80017a:	5e                   	pop    %esi
  80017b:	5d                   	pop    %ebp
  80017c:	5c                   	pop    %esp
  80017d:	5b                   	pop    %ebx
  80017e:	5a                   	pop    %edx
  80017f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800189:	bf 00 00 00 00       	mov    $0x0,%edi
  80018e:	b8 04 00 00 00       	mov    $0x4,%eax
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 fb                	mov    %edi,%ebx
  80019b:	51                   	push   %ecx
  80019c:	52                   	push   %edx
  80019d:	53                   	push   %ebx
  80019e:	54                   	push   %esp
  80019f:	55                   	push   %ebp
  8001a0:	56                   	push   %esi
  8001a1:	57                   	push   %edi
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	8d 35 ac 01 80 00    	lea    0x8001ac,%esi
  8001aa:	0f 34                	sysenter 

008001ac <label_174>:
  8001ac:	5f                   	pop    %edi
  8001ad:	5e                   	pop    %esi
  8001ae:	5d                   	pop    %ebp
  8001af:	5c                   	pop    %esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5a                   	pop    %edx
  8001b2:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001b3:	5b                   	pop    %ebx
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <sys_yield>:

void
sys_yield(void)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c6:	89 d1                	mov    %edx,%ecx
  8001c8:	89 d3                	mov    %edx,%ebx
  8001ca:	89 d7                	mov    %edx,%edi
  8001cc:	51                   	push   %ecx
  8001cd:	52                   	push   %edx
  8001ce:	53                   	push   %ebx
  8001cf:	54                   	push   %esp
  8001d0:	55                   	push   %ebp
  8001d1:	56                   	push   %esi
  8001d2:	57                   	push   %edi
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	8d 35 dd 01 80 00    	lea    0x8001dd,%esi
  8001db:	0f 34                	sysenter 

008001dd <label_209>:
  8001dd:	5f                   	pop    %edi
  8001de:	5e                   	pop    %esi
  8001df:	5d                   	pop    %ebp
  8001e0:	5c                   	pop    %esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5a                   	pop    %edx
  8001e3:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001e4:	5b                   	pop    %ebx
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ed:	bf 00 00 00 00       	mov    $0x0,%edi
  8001f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800200:	51                   	push   %ecx
  800201:	52                   	push   %edx
  800202:	53                   	push   %ebx
  800203:	54                   	push   %esp
  800204:	55                   	push   %ebp
  800205:	56                   	push   %esi
  800206:	57                   	push   %edi
  800207:	89 e5                	mov    %esp,%ebp
  800209:	8d 35 11 02 80 00    	lea    0x800211,%esi
  80020f:	0f 34                	sysenter 

00800211 <label_244>:
  800211:	5f                   	pop    %edi
  800212:	5e                   	pop    %esi
  800213:	5d                   	pop    %ebp
  800214:	5c                   	pop    %esp
  800215:	5b                   	pop    %ebx
  800216:	5a                   	pop    %edx
  800217:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800218:	85 c0                	test   %eax,%eax
  80021a:	7e 17                	jle    800233 <label_244+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	50                   	push   %eax
  800220:	6a 05                	push   $0x5
  800222:	68 ef 13 80 00       	push   $0x8013ef
  800227:	6a 2a                	push   $0x2a
  800229:	68 0c 14 80 00       	push   $0x80140c
  80022e:	e8 fe 01 00 00       	call   800431 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800233:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800236:	5b                   	pop    %ebx
  800237:	5f                   	pop    %edi
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80023f:	b8 06 00 00 00       	mov    $0x6,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800250:	51                   	push   %ecx
  800251:	52                   	push   %edx
  800252:	53                   	push   %ebx
  800253:	54                   	push   %esp
  800254:	55                   	push   %ebp
  800255:	56                   	push   %esi
  800256:	57                   	push   %edi
  800257:	89 e5                	mov    %esp,%ebp
  800259:	8d 35 61 02 80 00    	lea    0x800261,%esi
  80025f:	0f 34                	sysenter 

00800261 <label_295>:
  800261:	5f                   	pop    %edi
  800262:	5e                   	pop    %esi
  800263:	5d                   	pop    %ebp
  800264:	5c                   	pop    %esp
  800265:	5b                   	pop    %ebx
  800266:	5a                   	pop    %edx
  800267:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800268:	85 c0                	test   %eax,%eax
  80026a:	7e 17                	jle    800283 <label_295+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	50                   	push   %eax
  800270:	6a 06                	push   $0x6
  800272:	68 ef 13 80 00       	push   $0x8013ef
  800277:	6a 2a                	push   $0x2a
  800279:	68 0c 14 80 00       	push   $0x80140c
  80027e:	e8 ae 01 00 00       	call   800431 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800283:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80028f:	bf 00 00 00 00       	mov    $0x0,%edi
  800294:	b8 07 00 00 00       	mov    $0x7,%eax
  800299:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029c:	8b 55 08             	mov    0x8(%ebp),%edx
  80029f:	89 fb                	mov    %edi,%ebx
  8002a1:	51                   	push   %ecx
  8002a2:	52                   	push   %edx
  8002a3:	53                   	push   %ebx
  8002a4:	54                   	push   %esp
  8002a5:	55                   	push   %ebp
  8002a6:	56                   	push   %esi
  8002a7:	57                   	push   %edi
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	8d 35 b2 02 80 00    	lea    0x8002b2,%esi
  8002b0:	0f 34                	sysenter 

008002b2 <label_344>:
  8002b2:	5f                   	pop    %edi
  8002b3:	5e                   	pop    %esi
  8002b4:	5d                   	pop    %ebp
  8002b5:	5c                   	pop    %esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5a                   	pop    %edx
  8002b8:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	7e 17                	jle    8002d4 <label_344+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	50                   	push   %eax
  8002c1:	6a 07                	push   $0x7
  8002c3:	68 ef 13 80 00       	push   $0x8013ef
  8002c8:	6a 2a                	push   $0x2a
  8002ca:	68 0c 14 80 00       	push   $0x80140c
  8002cf:	e8 5d 01 00 00       	call   800431 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5f                   	pop    %edi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	57                   	push   %edi
  8002df:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8002e5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	89 fb                	mov    %edi,%ebx
  8002f2:	51                   	push   %ecx
  8002f3:	52                   	push   %edx
  8002f4:	53                   	push   %ebx
  8002f5:	54                   	push   %esp
  8002f6:	55                   	push   %ebp
  8002f7:	56                   	push   %esi
  8002f8:	57                   	push   %edi
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8d 35 03 03 80 00    	lea    0x800303,%esi
  800301:	0f 34                	sysenter 

00800303 <label_393>:
  800303:	5f                   	pop    %edi
  800304:	5e                   	pop    %esi
  800305:	5d                   	pop    %ebp
  800306:	5c                   	pop    %esp
  800307:	5b                   	pop    %ebx
  800308:	5a                   	pop    %edx
  800309:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80030a:	85 c0                	test   %eax,%eax
  80030c:	7e 17                	jle    800325 <label_393+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80030e:	83 ec 0c             	sub    $0xc,%esp
  800311:	50                   	push   %eax
  800312:	6a 09                	push   $0x9
  800314:	68 ef 13 80 00       	push   $0x8013ef
  800319:	6a 2a                	push   $0x2a
  80031b:	68 0c 14 80 00       	push   $0x80140c
  800320:	e8 0c 01 00 00       	call   800431 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800325:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800328:	5b                   	pop    %ebx
  800329:	5f                   	pop    %edi
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	57                   	push   %edi
  800330:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800331:	bf 00 00 00 00       	mov    $0x0,%edi
  800336:	b8 0a 00 00 00       	mov    $0xa,%eax
  80033b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033e:	8b 55 08             	mov    0x8(%ebp),%edx
  800341:	89 fb                	mov    %edi,%ebx
  800343:	51                   	push   %ecx
  800344:	52                   	push   %edx
  800345:	53                   	push   %ebx
  800346:	54                   	push   %esp
  800347:	55                   	push   %ebp
  800348:	56                   	push   %esi
  800349:	57                   	push   %edi
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	8d 35 54 03 80 00    	lea    0x800354,%esi
  800352:	0f 34                	sysenter 

00800354 <label_442>:
  800354:	5f                   	pop    %edi
  800355:	5e                   	pop    %esi
  800356:	5d                   	pop    %ebp
  800357:	5c                   	pop    %esp
  800358:	5b                   	pop    %ebx
  800359:	5a                   	pop    %edx
  80035a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80035b:	85 c0                	test   %eax,%eax
  80035d:	7e 17                	jle    800376 <label_442+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  80035f:	83 ec 0c             	sub    $0xc,%esp
  800362:	50                   	push   %eax
  800363:	6a 0a                	push   $0xa
  800365:	68 ef 13 80 00       	push   $0x8013ef
  80036a:	6a 2a                	push   $0x2a
  80036c:	68 0c 14 80 00       	push   $0x80140c
  800371:	e8 bb 00 00 00       	call   800431 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800376:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800379:	5b                   	pop    %ebx
  80037a:	5f                   	pop    %edi
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800382:	b8 0c 00 00 00       	mov    $0xc,%eax
  800387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038a:	8b 55 08             	mov    0x8(%ebp),%edx
  80038d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800390:	8b 7d 14             	mov    0x14(%ebp),%edi
  800393:	51                   	push   %ecx
  800394:	52                   	push   %edx
  800395:	53                   	push   %ebx
  800396:	54                   	push   %esp
  800397:	55                   	push   %ebp
  800398:	56                   	push   %esi
  800399:	57                   	push   %edi
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8d 35 a4 03 80 00    	lea    0x8003a4,%esi
  8003a2:	0f 34                	sysenter 

008003a4 <label_493>:
  8003a4:	5f                   	pop    %edi
  8003a5:	5e                   	pop    %esi
  8003a6:	5d                   	pop    %ebp
  8003a7:	5c                   	pop    %esp
  8003a8:	5b                   	pop    %ebx
  8003a9:	5a                   	pop    %edx
  8003aa:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ab:	5b                   	pop    %ebx
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003be:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c1:	89 d9                	mov    %ebx,%ecx
  8003c3:	89 df                	mov    %ebx,%edi
  8003c5:	51                   	push   %ecx
  8003c6:	52                   	push   %edx
  8003c7:	53                   	push   %ebx
  8003c8:	54                   	push   %esp
  8003c9:	55                   	push   %ebp
  8003ca:	56                   	push   %esi
  8003cb:	57                   	push   %edi
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	8d 35 d6 03 80 00    	lea    0x8003d6,%esi
  8003d4:	0f 34                	sysenter 

008003d6 <label_528>:
  8003d6:	5f                   	pop    %edi
  8003d7:	5e                   	pop    %esi
  8003d8:	5d                   	pop    %ebp
  8003d9:	5c                   	pop    %esp
  8003da:	5b                   	pop    %ebx
  8003db:	5a                   	pop    %edx
  8003dc:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	7e 17                	jle    8003f8 <label_528+0x22>
	panic("syscall %d returned %d (> 0)", num, ret);
  8003e1:	83 ec 0c             	sub    $0xc,%esp
  8003e4:	50                   	push   %eax
  8003e5:	6a 0d                	push   $0xd
  8003e7:	68 ef 13 80 00       	push   $0x8013ef
  8003ec:	6a 2a                	push   $0x2a
  8003ee:	68 0c 14 80 00       	push   $0x80140c
  8003f3:	e8 39 00 00 00       	call   800431 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003fb:	5b                   	pop    %ebx
  8003fc:	5f                   	pop    %edi
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800404:	b9 00 00 00 00       	mov    $0x0,%ecx
  800409:	b8 0e 00 00 00       	mov    $0xe,%eax
  80040e:	8b 55 08             	mov    0x8(%ebp),%edx
  800411:	89 cb                	mov    %ecx,%ebx
  800413:	89 cf                	mov    %ecx,%edi
  800415:	51                   	push   %ecx
  800416:	52                   	push   %edx
  800417:	53                   	push   %ebx
  800418:	54                   	push   %esp
  800419:	55                   	push   %ebp
  80041a:	56                   	push   %esi
  80041b:	57                   	push   %edi
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	8d 35 26 04 80 00    	lea    0x800426,%esi
  800424:	0f 34                	sysenter 

00800426 <label_577>:
  800426:	5f                   	pop    %edi
  800427:	5e                   	pop    %esi
  800428:	5d                   	pop    %ebp
  800429:	5c                   	pop    %esp
  80042a:	5b                   	pop    %ebx
  80042b:	5a                   	pop    %edx
  80042c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80042d:	5b                   	pop    %ebx
  80042e:	5f                   	pop    %edi
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800436:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800439:	a1 10 20 80 00       	mov    0x802010,%eax
  80043e:	85 c0                	test   %eax,%eax
  800440:	74 11                	je     800453 <_panic+0x22>
		cprintf("%s: ", argv0);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	50                   	push   %eax
  800446:	68 1a 14 80 00       	push   $0x80141a
  80044b:	e8 d4 00 00 00       	call   800524 <cprintf>
  800450:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800453:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800459:	e8 f5 fc ff ff       	call   800153 <sys_getenvid>
  80045e:	83 ec 0c             	sub    $0xc,%esp
  800461:	ff 75 0c             	pushl  0xc(%ebp)
  800464:	ff 75 08             	pushl  0x8(%ebp)
  800467:	56                   	push   %esi
  800468:	50                   	push   %eax
  800469:	68 24 14 80 00       	push   $0x801424
  80046e:	e8 b1 00 00 00       	call   800524 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800473:	83 c4 18             	add    $0x18,%esp
  800476:	53                   	push   %ebx
  800477:	ff 75 10             	pushl  0x10(%ebp)
  80047a:	e8 54 00 00 00       	call   8004d3 <vcprintf>
	cprintf("\n");
  80047f:	c7 04 24 1f 14 80 00 	movl   $0x80141f,(%esp)
  800486:	e8 99 00 00 00       	call   800524 <cprintf>
  80048b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048e:	cc                   	int3   
  80048f:	eb fd                	jmp    80048e <_panic+0x5d>

00800491 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	53                   	push   %ebx
  800495:	83 ec 04             	sub    $0x4,%esp
  800498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049b:	8b 13                	mov    (%ebx),%edx
  80049d:	8d 42 01             	lea    0x1(%edx),%eax
  8004a0:	89 03                	mov    %eax,(%ebx)
  8004a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004a9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ae:	75 1a                	jne    8004ca <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	68 ff 00 00 00       	push   $0xff
  8004b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8004bb:	50                   	push   %eax
  8004bc:	e8 e1 fb ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8004c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004c7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004ca:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004d1:	c9                   	leave  
  8004d2:	c3                   	ret    

008004d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e3:	00 00 00 
	b.cnt = 0;
  8004e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	ff 75 08             	pushl  0x8(%ebp)
  8004f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004fc:	50                   	push   %eax
  8004fd:	68 91 04 80 00       	push   $0x800491
  800502:	e8 c0 02 00 00       	call   8007c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800507:	83 c4 08             	add    $0x8,%esp
  80050a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800510:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800516:	50                   	push   %eax
  800517:	e8 86 fb ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80051c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800522:	c9                   	leave  
  800523:	c3                   	ret    

00800524 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80052a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80052d:	50                   	push   %eax
  80052e:	ff 75 08             	pushl  0x8(%ebp)
  800531:	e8 9d ff ff ff       	call   8004d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	57                   	push   %edi
  80053c:	56                   	push   %esi
  80053d:	53                   	push   %ebx
  80053e:	83 ec 1c             	sub    $0x1c,%esp
  800541:	89 c7                	mov    %eax,%edi
  800543:	89 d6                	mov    %edx,%esi
  800545:	8b 45 08             	mov    0x8(%ebp),%eax
  800548:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800551:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800554:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800558:	0f 85 bf 00 00 00    	jne    80061d <printnum+0xe5>
  80055e:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800564:	0f 8d de 00 00 00    	jge    800648 <printnum+0x110>
		judge_time_for_space = width;
  80056a:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800570:	e9 d3 00 00 00       	jmp    800648 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800575:	83 eb 01             	sub    $0x1,%ebx
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f 37                	jg     8005b3 <printnum+0x7b>
  80057c:	e9 ea 00 00 00       	jmp    80066b <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800581:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800584:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	56                   	push   %esi
  80058d:	83 ec 04             	sub    $0x4,%esp
  800590:	ff 75 dc             	pushl  -0x24(%ebp)
  800593:	ff 75 d8             	pushl  -0x28(%ebp)
  800596:	ff 75 e4             	pushl  -0x1c(%ebp)
  800599:	ff 75 e0             	pushl  -0x20(%ebp)
  80059c:	e8 cf 0c 00 00       	call   801270 <__umoddi3>
  8005a1:	83 c4 14             	add    $0x14,%esp
  8005a4:	0f be 80 47 14 80 00 	movsbl 0x801447(%eax),%eax
  8005ab:	50                   	push   %eax
  8005ac:	ff d7                	call   *%edi
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	eb 16                	jmp    8005c9 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	56                   	push   %esi
  8005b7:	ff 75 18             	pushl  0x18(%ebp)
  8005ba:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	83 eb 01             	sub    $0x1,%ebx
  8005c2:	75 ef                	jne    8005b3 <printnum+0x7b>
  8005c4:	e9 a2 00 00 00       	jmp    80066b <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005c9:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005cf:	0f 85 76 01 00 00    	jne    80074b <printnum+0x213>
		while(num_of_space-- > 0)
  8005d5:	a1 04 20 80 00       	mov    0x802004,%eax
  8005da:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005dd:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	7e 1d                	jle    800604 <printnum+0xcc>
			putch(' ', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	6a 20                	push   $0x20
  8005ed:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8005ef:	a1 04 20 80 00       	mov    0x802004,%eax
  8005f4:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005f7:	89 15 04 20 80 00    	mov    %edx,0x802004
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	85 c0                	test   %eax,%eax
  800602:	7f e3                	jg     8005e7 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800604:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80060b:	00 00 00 
		judge_time_for_space = 0;
  80060e:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800615:	00 00 00 
	}
}
  800618:	e9 2e 01 00 00       	jmp    80074b <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80061d:	8b 45 10             	mov    0x10(%ebp),%eax
  800620:	ba 00 00 00 00       	mov    $0x0,%edx
  800625:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800628:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800631:	83 fa 00             	cmp    $0x0,%edx
  800634:	0f 87 ba 00 00 00    	ja     8006f4 <printnum+0x1bc>
  80063a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80063d:	0f 83 b1 00 00 00    	jae    8006f4 <printnum+0x1bc>
  800643:	e9 2d ff ff ff       	jmp    800575 <printnum+0x3d>
  800648:	8b 45 10             	mov    0x10(%ebp),%eax
  80064b:	ba 00 00 00 00       	mov    $0x0,%edx
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800656:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800659:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065c:	83 fa 00             	cmp    $0x0,%edx
  80065f:	77 37                	ja     800698 <printnum+0x160>
  800661:	3b 45 10             	cmp    0x10(%ebp),%eax
  800664:	73 32                	jae    800698 <printnum+0x160>
  800666:	e9 16 ff ff ff       	jmp    800581 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	56                   	push   %esi
  80066f:	83 ec 04             	sub    $0x4,%esp
  800672:	ff 75 dc             	pushl  -0x24(%ebp)
  800675:	ff 75 d8             	pushl  -0x28(%ebp)
  800678:	ff 75 e4             	pushl  -0x1c(%ebp)
  80067b:	ff 75 e0             	pushl  -0x20(%ebp)
  80067e:	e8 ed 0b 00 00       	call   801270 <__umoddi3>
  800683:	83 c4 14             	add    $0x14,%esp
  800686:	0f be 80 47 14 80 00 	movsbl 0x801447(%eax),%eax
  80068d:	50                   	push   %eax
  80068e:	ff d7                	call   *%edi
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	e9 b3 00 00 00       	jmp    80074b <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	ff 75 18             	pushl  0x18(%ebp)
  80069e:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006a1:	50                   	push   %eax
  8006a2:	ff 75 10             	pushl  0x10(%ebp)
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b4:	e8 87 0a 00 00       	call   801140 <__udivdi3>
  8006b9:	83 c4 18             	add    $0x18,%esp
  8006bc:	52                   	push   %edx
  8006bd:	50                   	push   %eax
  8006be:	89 f2                	mov    %esi,%edx
  8006c0:	89 f8                	mov    %edi,%eax
  8006c2:	e8 71 fe ff ff       	call   800538 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006c7:	83 c4 18             	add    $0x18,%esp
  8006ca:	56                   	push   %esi
  8006cb:	83 ec 04             	sub    $0x4,%esp
  8006ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8006d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006da:	e8 91 0b 00 00       	call   801270 <__umoddi3>
  8006df:	83 c4 14             	add    $0x14,%esp
  8006e2:	0f be 80 47 14 80 00 	movsbl 0x801447(%eax),%eax
  8006e9:	50                   	push   %eax
  8006ea:	ff d7                	call   *%edi
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	e9 d5 fe ff ff       	jmp    8005c9 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f4:	83 ec 0c             	sub    $0xc,%esp
  8006f7:	ff 75 18             	pushl  0x18(%ebp)
  8006fa:	83 eb 01             	sub    $0x1,%ebx
  8006fd:	53                   	push   %ebx
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	ff 75 dc             	pushl  -0x24(%ebp)
  800707:	ff 75 d8             	pushl  -0x28(%ebp)
  80070a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80070d:	ff 75 e0             	pushl  -0x20(%ebp)
  800710:	e8 2b 0a 00 00       	call   801140 <__udivdi3>
  800715:	83 c4 18             	add    $0x18,%esp
  800718:	52                   	push   %edx
  800719:	50                   	push   %eax
  80071a:	89 f2                	mov    %esi,%edx
  80071c:	89 f8                	mov    %edi,%eax
  80071e:	e8 15 fe ff ff       	call   800538 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800723:	83 c4 18             	add    $0x18,%esp
  800726:	56                   	push   %esi
  800727:	83 ec 04             	sub    $0x4,%esp
  80072a:	ff 75 dc             	pushl  -0x24(%ebp)
  80072d:	ff 75 d8             	pushl  -0x28(%ebp)
  800730:	ff 75 e4             	pushl  -0x1c(%ebp)
  800733:	ff 75 e0             	pushl  -0x20(%ebp)
  800736:	e8 35 0b 00 00       	call   801270 <__umoddi3>
  80073b:	83 c4 14             	add    $0x14,%esp
  80073e:	0f be 80 47 14 80 00 	movsbl 0x801447(%eax),%eax
  800745:	50                   	push   %eax
  800746:	ff d7                	call   *%edi
  800748:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80074b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5f                   	pop    %edi
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800756:	83 fa 01             	cmp    $0x1,%edx
  800759:	7e 0e                	jle    800769 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800760:	89 08                	mov    %ecx,(%eax)
  800762:	8b 02                	mov    (%edx),%eax
  800764:	8b 52 04             	mov    0x4(%edx),%edx
  800767:	eb 22                	jmp    80078b <getuint+0x38>
	else if (lflag)
  800769:	85 d2                	test   %edx,%edx
  80076b:	74 10                	je     80077d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80076d:	8b 10                	mov    (%eax),%edx
  80076f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800772:	89 08                	mov    %ecx,(%eax)
  800774:	8b 02                	mov    (%edx),%eax
  800776:	ba 00 00 00 00       	mov    $0x0,%edx
  80077b:	eb 0e                	jmp    80078b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80077d:	8b 10                	mov    (%eax),%edx
  80077f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800782:	89 08                	mov    %ecx,(%eax)
  800784:	8b 02                	mov    (%edx),%eax
  800786:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800793:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800797:	8b 10                	mov    (%eax),%edx
  800799:	3b 50 04             	cmp    0x4(%eax),%edx
  80079c:	73 0a                	jae    8007a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80079e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007a1:	89 08                	mov    %ecx,(%eax)
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	88 02                	mov    %al,(%edx)
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b3:	50                   	push   %eax
  8007b4:	ff 75 10             	pushl  0x10(%ebp)
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	ff 75 08             	pushl  0x8(%ebp)
  8007bd:	e8 05 00 00 00       	call   8007c7 <vprintfmt>
	va_end(ap);
}
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	57                   	push   %edi
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	83 ec 2c             	sub    $0x2c,%esp
  8007d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d6:	eb 03                	jmp    8007db <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007db:	8b 45 10             	mov    0x10(%ebp),%eax
  8007de:	8d 70 01             	lea    0x1(%eax),%esi
  8007e1:	0f b6 00             	movzbl (%eax),%eax
  8007e4:	83 f8 25             	cmp    $0x25,%eax
  8007e7:	74 27                	je     800810 <vprintfmt+0x49>
			if (ch == '\0')
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	75 0d                	jne    8007fa <vprintfmt+0x33>
  8007ed:	e9 9d 04 00 00       	jmp    800c8f <vprintfmt+0x4c8>
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	0f 84 95 04 00 00    	je     800c8f <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	53                   	push   %ebx
  8007fe:	50                   	push   %eax
  8007ff:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800801:	83 c6 01             	add    $0x1,%esi
  800804:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800808:	83 c4 10             	add    $0x10,%esp
  80080b:	83 f8 25             	cmp    $0x25,%eax
  80080e:	75 e2                	jne    8007f2 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800810:	b9 00 00 00 00       	mov    $0x0,%ecx
  800815:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800819:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800820:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800827:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80082e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800835:	eb 08                	jmp    80083f <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800837:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80083a:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083f:	8d 46 01             	lea    0x1(%esi),%eax
  800842:	89 45 10             	mov    %eax,0x10(%ebp)
  800845:	0f b6 06             	movzbl (%esi),%eax
  800848:	0f b6 d0             	movzbl %al,%edx
  80084b:	83 e8 23             	sub    $0x23,%eax
  80084e:	3c 55                	cmp    $0x55,%al
  800850:	0f 87 fa 03 00 00    	ja     800c50 <vprintfmt+0x489>
  800856:	0f b6 c0             	movzbl %al,%eax
  800859:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  800860:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800863:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800867:	eb d6                	jmp    80083f <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800869:	8d 42 d0             	lea    -0x30(%edx),%eax
  80086c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80086f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800873:	8d 50 d0             	lea    -0x30(%eax),%edx
  800876:	83 fa 09             	cmp    $0x9,%edx
  800879:	77 6b                	ja     8008e6 <vprintfmt+0x11f>
  80087b:	8b 75 10             	mov    0x10(%ebp),%esi
  80087e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800881:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800884:	eb 09                	jmp    80088f <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800889:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80088d:	eb b0                	jmp    80083f <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80088f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800892:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800895:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800899:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80089c:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80089f:	83 f9 09             	cmp    $0x9,%ecx
  8008a2:	76 eb                	jbe    80088f <vprintfmt+0xc8>
  8008a4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008a7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008aa:	eb 3d                	jmp    8008e9 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8d 50 04             	lea    0x4(%eax),%edx
  8008b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b5:	8b 00                	mov    (%eax),%eax
  8008b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008bd:	eb 2a                	jmp    8008e9 <vprintfmt+0x122>
  8008bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c9:	0f 49 d0             	cmovns %eax,%edx
  8008cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 75 10             	mov    0x10(%ebp),%esi
  8008d2:	e9 68 ff ff ff       	jmp    80083f <vprintfmt+0x78>
  8008d7:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008e1:	e9 59 ff ff ff       	jmp    80083f <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8008e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ed:	0f 89 4c ff ff ff    	jns    80083f <vprintfmt+0x78>
				width = precision, precision = -1;
  8008f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800900:	e9 3a ff ff ff       	jmp    80083f <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800905:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800909:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80090c:	e9 2e ff ff ff       	jmp    80083f <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800911:	8b 45 14             	mov    0x14(%ebp),%eax
  800914:	8d 50 04             	lea    0x4(%eax),%edx
  800917:	89 55 14             	mov    %edx,0x14(%ebp)
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	53                   	push   %ebx
  80091e:	ff 30                	pushl  (%eax)
  800920:	ff d7                	call   *%edi
			break;
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	e9 b1 fe ff ff       	jmp    8007db <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)
  800933:	8b 00                	mov    (%eax),%eax
  800935:	99                   	cltd   
  800936:	31 d0                	xor    %edx,%eax
  800938:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80093a:	83 f8 08             	cmp    $0x8,%eax
  80093d:	7f 0b                	jg     80094a <vprintfmt+0x183>
  80093f:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  800946:	85 d2                	test   %edx,%edx
  800948:	75 15                	jne    80095f <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80094a:	50                   	push   %eax
  80094b:	68 5f 14 80 00       	push   $0x80145f
  800950:	53                   	push   %ebx
  800951:	57                   	push   %edi
  800952:	e8 53 fe ff ff       	call   8007aa <printfmt>
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	e9 7c fe ff ff       	jmp    8007db <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80095f:	52                   	push   %edx
  800960:	68 68 14 80 00       	push   $0x801468
  800965:	53                   	push   %ebx
  800966:	57                   	push   %edi
  800967:	e8 3e fe ff ff       	call   8007aa <printfmt>
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	e9 67 fe ff ff       	jmp    8007db <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800974:	8b 45 14             	mov    0x14(%ebp),%eax
  800977:	8d 50 04             	lea    0x4(%eax),%edx
  80097a:	89 55 14             	mov    %edx,0x14(%ebp)
  80097d:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80097f:	85 c0                	test   %eax,%eax
  800981:	b9 58 14 80 00       	mov    $0x801458,%ecx
  800986:	0f 45 c8             	cmovne %eax,%ecx
  800989:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80098c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800990:	7e 06                	jle    800998 <vprintfmt+0x1d1>
  800992:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800996:	75 19                	jne    8009b1 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800998:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80099b:	8d 70 01             	lea    0x1(%eax),%esi
  80099e:	0f b6 00             	movzbl (%eax),%eax
  8009a1:	0f be d0             	movsbl %al,%edx
  8009a4:	85 d2                	test   %edx,%edx
  8009a6:	0f 85 9f 00 00 00    	jne    800a4b <vprintfmt+0x284>
  8009ac:	e9 8c 00 00 00       	jmp    800a3d <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b1:	83 ec 08             	sub    $0x8,%esp
  8009b4:	ff 75 d0             	pushl  -0x30(%ebp)
  8009b7:	ff 75 cc             	pushl  -0x34(%ebp)
  8009ba:	e8 62 03 00 00       	call   800d21 <strnlen>
  8009bf:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009c2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009c5:	83 c4 10             	add    $0x10,%esp
  8009c8:	85 c9                	test   %ecx,%ecx
  8009ca:	0f 8e a6 02 00 00    	jle    800c76 <vprintfmt+0x4af>
					putch(padc, putdat);
  8009d0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009d7:	89 cb                	mov    %ecx,%ebx
  8009d9:	83 ec 08             	sub    $0x8,%esp
  8009dc:	ff 75 0c             	pushl  0xc(%ebp)
  8009df:	56                   	push   %esi
  8009e0:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e2:	83 c4 10             	add    $0x10,%esp
  8009e5:	83 eb 01             	sub    $0x1,%ebx
  8009e8:	75 ef                	jne    8009d9 <vprintfmt+0x212>
  8009ea:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f0:	e9 81 02 00 00       	jmp    800c76 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f9:	74 1b                	je     800a16 <vprintfmt+0x24f>
  8009fb:	0f be c0             	movsbl %al,%eax
  8009fe:	83 e8 20             	sub    $0x20,%eax
  800a01:	83 f8 5e             	cmp    $0x5e,%eax
  800a04:	76 10                	jbe    800a16 <vprintfmt+0x24f>
					putch('?', putdat);
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	ff 75 0c             	pushl  0xc(%ebp)
  800a0c:	6a 3f                	push   $0x3f
  800a0e:	ff 55 08             	call   *0x8(%ebp)
  800a11:	83 c4 10             	add    $0x10,%esp
  800a14:	eb 0d                	jmp    800a23 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a16:	83 ec 08             	sub    $0x8,%esp
  800a19:	ff 75 0c             	pushl  0xc(%ebp)
  800a1c:	52                   	push   %edx
  800a1d:	ff 55 08             	call   *0x8(%ebp)
  800a20:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a23:	83 ef 01             	sub    $0x1,%edi
  800a26:	83 c6 01             	add    $0x1,%esi
  800a29:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a2d:	0f be d0             	movsbl %al,%edx
  800a30:	85 d2                	test   %edx,%edx
  800a32:	75 31                	jne    800a65 <vprintfmt+0x29e>
  800a34:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a40:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a44:	7f 33                	jg     800a79 <vprintfmt+0x2b2>
  800a46:	e9 90 fd ff ff       	jmp    8007db <vprintfmt+0x14>
  800a4b:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a51:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a54:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a57:	eb 0c                	jmp    800a65 <vprintfmt+0x29e>
  800a59:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a62:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a65:	85 db                	test   %ebx,%ebx
  800a67:	78 8c                	js     8009f5 <vprintfmt+0x22e>
  800a69:	83 eb 01             	sub    $0x1,%ebx
  800a6c:	79 87                	jns    8009f5 <vprintfmt+0x22e>
  800a6e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a71:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a77:	eb c4                	jmp    800a3d <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a79:	83 ec 08             	sub    $0x8,%esp
  800a7c:	53                   	push   %ebx
  800a7d:	6a 20                	push   $0x20
  800a7f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a81:	83 c4 10             	add    $0x10,%esp
  800a84:	83 ee 01             	sub    $0x1,%esi
  800a87:	75 f0                	jne    800a79 <vprintfmt+0x2b2>
  800a89:	e9 4d fd ff ff       	jmp    8007db <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8e:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800a92:	7e 16                	jle    800aaa <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800a94:	8b 45 14             	mov    0x14(%ebp),%eax
  800a97:	8d 50 08             	lea    0x8(%eax),%edx
  800a9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9d:	8b 50 04             	mov    0x4(%eax),%edx
  800aa0:	8b 00                	mov    (%eax),%eax
  800aa2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800aa5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800aa8:	eb 34                	jmp    800ade <vprintfmt+0x317>
	else if (lflag)
  800aaa:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800aae:	74 18                	je     800ac8 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab3:	8d 50 04             	lea    0x4(%eax),%edx
  800ab6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab9:	8b 30                	mov    (%eax),%esi
  800abb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800abe:	89 f0                	mov    %esi,%eax
  800ac0:	c1 f8 1f             	sar    $0x1f,%eax
  800ac3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ac6:	eb 16                	jmp    800ade <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ac8:	8b 45 14             	mov    0x14(%ebp),%eax
  800acb:	8d 50 04             	lea    0x4(%eax),%edx
  800ace:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad1:	8b 30                	mov    (%eax),%esi
  800ad3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800ad6:	89 f0                	mov    %esi,%eax
  800ad8:	c1 f8 1f             	sar    $0x1f,%eax
  800adb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ade:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ae1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ae4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800aea:	85 d2                	test   %edx,%edx
  800aec:	79 28                	jns    800b16 <vprintfmt+0x34f>
				putch('-', putdat);
  800aee:	83 ec 08             	sub    $0x8,%esp
  800af1:	53                   	push   %ebx
  800af2:	6a 2d                	push   $0x2d
  800af4:	ff d7                	call   *%edi
				num = -(long long) num;
  800af6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800af9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800afc:	f7 d8                	neg    %eax
  800afe:	83 d2 00             	adc    $0x0,%edx
  800b01:	f7 da                	neg    %edx
  800b03:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b06:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b09:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b0c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b11:	e9 b2 00 00 00       	jmp    800bc8 <vprintfmt+0x401>
  800b16:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b1b:	85 c9                	test   %ecx,%ecx
  800b1d:	0f 84 a5 00 00 00    	je     800bc8 <vprintfmt+0x401>
				putch('+', putdat);
  800b23:	83 ec 08             	sub    $0x8,%esp
  800b26:	53                   	push   %ebx
  800b27:	6a 2b                	push   $0x2b
  800b29:	ff d7                	call   *%edi
  800b2b:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b33:	e9 90 00 00 00       	jmp    800bc8 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b38:	85 c9                	test   %ecx,%ecx
  800b3a:	74 0b                	je     800b47 <vprintfmt+0x380>
				putch('+', putdat);
  800b3c:	83 ec 08             	sub    $0x8,%esp
  800b3f:	53                   	push   %ebx
  800b40:	6a 2b                	push   $0x2b
  800b42:	ff d7                	call   *%edi
  800b44:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b47:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4d:	e8 01 fc ff ff       	call   800753 <getuint>
  800b52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b55:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b58:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b5d:	eb 69                	jmp    800bc8 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	53                   	push   %ebx
  800b63:	6a 30                	push   $0x30
  800b65:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b67:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b6a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6d:	e8 e1 fb ff ff       	call   800753 <getuint>
  800b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b75:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b78:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b7b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b80:	eb 46                	jmp    800bc8 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b82:	83 ec 08             	sub    $0x8,%esp
  800b85:	53                   	push   %ebx
  800b86:	6a 30                	push   $0x30
  800b88:	ff d7                	call   *%edi
			putch('x', putdat);
  800b8a:	83 c4 08             	add    $0x8,%esp
  800b8d:	53                   	push   %ebx
  800b8e:	6a 78                	push   $0x78
  800b90:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b92:	8b 45 14             	mov    0x14(%ebp),%eax
  800b95:	8d 50 04             	lea    0x4(%eax),%edx
  800b98:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b9b:	8b 00                	mov    (%eax),%eax
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ba5:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ba8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bab:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bb0:	eb 16                	jmp    800bc8 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bb2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bb5:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb8:	e8 96 fb ff ff       	call   800753 <getuint>
  800bbd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bc0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800bc3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bcf:	56                   	push   %esi
  800bd0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bd3:	50                   	push   %eax
  800bd4:	ff 75 dc             	pushl  -0x24(%ebp)
  800bd7:	ff 75 d8             	pushl  -0x28(%ebp)
  800bda:	89 da                	mov    %ebx,%edx
  800bdc:	89 f8                	mov    %edi,%eax
  800bde:	e8 55 f9 ff ff       	call   800538 <printnum>
			break;
  800be3:	83 c4 20             	add    $0x20,%esp
  800be6:	e9 f0 fb ff ff       	jmp    8007db <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800beb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bee:	8d 50 04             	lea    0x4(%eax),%edx
  800bf1:	89 55 14             	mov    %edx,0x14(%ebp)
  800bf4:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800bf6:	85 f6                	test   %esi,%esi
  800bf8:	75 1a                	jne    800c14 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800bfa:	83 ec 08             	sub    $0x8,%esp
  800bfd:	68 00 15 80 00       	push   $0x801500
  800c02:	68 68 14 80 00       	push   $0x801468
  800c07:	e8 18 f9 ff ff       	call   800524 <cprintf>
  800c0c:	83 c4 10             	add    $0x10,%esp
  800c0f:	e9 c7 fb ff ff       	jmp    8007db <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c14:	0f b6 03             	movzbl (%ebx),%eax
  800c17:	84 c0                	test   %al,%al
  800c19:	79 1f                	jns    800c3a <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c1b:	83 ec 08             	sub    $0x8,%esp
  800c1e:	68 38 15 80 00       	push   $0x801538
  800c23:	68 68 14 80 00       	push   $0x801468
  800c28:	e8 f7 f8 ff ff       	call   800524 <cprintf>
						*tmp = *(char *)putdat;
  800c2d:	0f b6 03             	movzbl (%ebx),%eax
  800c30:	88 06                	mov    %al,(%esi)
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	e9 a1 fb ff ff       	jmp    8007db <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c3a:	88 06                	mov    %al,(%esi)
  800c3c:	e9 9a fb ff ff       	jmp    8007db <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	53                   	push   %ebx
  800c45:	52                   	push   %edx
  800c46:	ff d7                	call   *%edi
			break;
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	e9 8b fb ff ff       	jmp    8007db <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c50:	83 ec 08             	sub    $0x8,%esp
  800c53:	53                   	push   %ebx
  800c54:	6a 25                	push   $0x25
  800c56:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c5f:	0f 84 73 fb ff ff    	je     8007d8 <vprintfmt+0x11>
  800c65:	83 ee 01             	sub    $0x1,%esi
  800c68:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c6c:	75 f7                	jne    800c65 <vprintfmt+0x49e>
  800c6e:	89 75 10             	mov    %esi,0x10(%ebp)
  800c71:	e9 65 fb ff ff       	jmp    8007db <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c76:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c79:	8d 70 01             	lea    0x1(%eax),%esi
  800c7c:	0f b6 00             	movzbl (%eax),%eax
  800c7f:	0f be d0             	movsbl %al,%edx
  800c82:	85 d2                	test   %edx,%edx
  800c84:	0f 85 cf fd ff ff    	jne    800a59 <vprintfmt+0x292>
  800c8a:	e9 4c fb ff ff       	jmp    8007db <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 18             	sub    $0x18,%esp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800caa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	74 26                	je     800cde <vsnprintf+0x47>
  800cb8:	85 d2                	test   %edx,%edx
  800cba:	7e 22                	jle    800cde <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cbc:	ff 75 14             	pushl  0x14(%ebp)
  800cbf:	ff 75 10             	pushl  0x10(%ebp)
  800cc2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc5:	50                   	push   %eax
  800cc6:	68 8d 07 80 00       	push   $0x80078d
  800ccb:	e8 f7 fa ff ff       	call   8007c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	eb 05                	jmp    800ce3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ceb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cee:	50                   	push   %eax
  800cef:	ff 75 10             	pushl  0x10(%ebp)
  800cf2:	ff 75 0c             	pushl  0xc(%ebp)
  800cf5:	ff 75 08             	pushl  0x8(%ebp)
  800cf8:	e8 9a ff ff ff       	call   800c97 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d05:	80 3a 00             	cmpb   $0x0,(%edx)
  800d08:	74 10                	je     800d1a <strlen+0x1b>
  800d0a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d0f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d12:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d16:	75 f7                	jne    800d0f <strlen+0x10>
  800d18:	eb 05                	jmp    800d1f <strlen+0x20>
  800d1a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	53                   	push   %ebx
  800d25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2b:	85 c9                	test   %ecx,%ecx
  800d2d:	74 1c                	je     800d4b <strnlen+0x2a>
  800d2f:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d32:	74 1e                	je     800d52 <strnlen+0x31>
  800d34:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d39:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d3b:	39 ca                	cmp    %ecx,%edx
  800d3d:	74 18                	je     800d57 <strnlen+0x36>
  800d3f:	83 c2 01             	add    $0x1,%edx
  800d42:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d47:	75 f0                	jne    800d39 <strnlen+0x18>
  800d49:	eb 0c                	jmp    800d57 <strnlen+0x36>
  800d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d50:	eb 05                	jmp    800d57 <strnlen+0x36>
  800d52:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d57:	5b                   	pop    %ebx
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	53                   	push   %ebx
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d64:	89 c2                	mov    %eax,%edx
  800d66:	83 c2 01             	add    $0x1,%edx
  800d69:	83 c1 01             	add    $0x1,%ecx
  800d6c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d70:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d73:	84 db                	test   %bl,%bl
  800d75:	75 ef                	jne    800d66 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d77:	5b                   	pop    %ebx
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	53                   	push   %ebx
  800d7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d81:	53                   	push   %ebx
  800d82:	e8 78 ff ff ff       	call   800cff <strlen>
  800d87:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d8a:	ff 75 0c             	pushl  0xc(%ebp)
  800d8d:	01 d8                	add    %ebx,%eax
  800d8f:	50                   	push   %eax
  800d90:	e8 c5 ff ff ff       	call   800d5a <strcpy>
	return dst;
}
  800d95:	89 d8                	mov    %ebx,%eax
  800d97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d9a:	c9                   	leave  
  800d9b:	c3                   	ret    

00800d9c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	8b 75 08             	mov    0x8(%ebp),%esi
  800da4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800daa:	85 db                	test   %ebx,%ebx
  800dac:	74 17                	je     800dc5 <strncpy+0x29>
  800dae:	01 f3                	add    %esi,%ebx
  800db0:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800db2:	83 c1 01             	add    $0x1,%ecx
  800db5:	0f b6 02             	movzbl (%edx),%eax
  800db8:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dbb:	80 3a 01             	cmpb   $0x1,(%edx)
  800dbe:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc1:	39 cb                	cmp    %ecx,%ebx
  800dc3:	75 ed                	jne    800db2 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dc5:	89 f0                	mov    %esi,%eax
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd6:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ddb:	85 d2                	test   %edx,%edx
  800ddd:	74 35                	je     800e14 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800ddf:	89 d0                	mov    %edx,%eax
  800de1:	83 e8 01             	sub    $0x1,%eax
  800de4:	74 25                	je     800e0b <strlcpy+0x40>
  800de6:	0f b6 0b             	movzbl (%ebx),%ecx
  800de9:	84 c9                	test   %cl,%cl
  800deb:	74 22                	je     800e0f <strlcpy+0x44>
  800ded:	8d 53 01             	lea    0x1(%ebx),%edx
  800df0:	01 c3                	add    %eax,%ebx
  800df2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800df4:	83 c0 01             	add    $0x1,%eax
  800df7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dfa:	39 da                	cmp    %ebx,%edx
  800dfc:	74 13                	je     800e11 <strlcpy+0x46>
  800dfe:	83 c2 01             	add    $0x1,%edx
  800e01:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e05:	84 c9                	test   %cl,%cl
  800e07:	75 eb                	jne    800df4 <strlcpy+0x29>
  800e09:	eb 06                	jmp    800e11 <strlcpy+0x46>
  800e0b:	89 f0                	mov    %esi,%eax
  800e0d:	eb 02                	jmp    800e11 <strlcpy+0x46>
  800e0f:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e14:	29 f0                	sub    %esi,%eax
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e23:	0f b6 01             	movzbl (%ecx),%eax
  800e26:	84 c0                	test   %al,%al
  800e28:	74 15                	je     800e3f <strcmp+0x25>
  800e2a:	3a 02                	cmp    (%edx),%al
  800e2c:	75 11                	jne    800e3f <strcmp+0x25>
		p++, q++;
  800e2e:	83 c1 01             	add    $0x1,%ecx
  800e31:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e34:	0f b6 01             	movzbl (%ecx),%eax
  800e37:	84 c0                	test   %al,%al
  800e39:	74 04                	je     800e3f <strcmp+0x25>
  800e3b:	3a 02                	cmp    (%edx),%al
  800e3d:	74 ef                	je     800e2e <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e3f:	0f b6 c0             	movzbl %al,%eax
  800e42:	0f b6 12             	movzbl (%edx),%edx
  800e45:	29 d0                	sub    %edx,%eax
}
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e54:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e57:	85 f6                	test   %esi,%esi
  800e59:	74 29                	je     800e84 <strncmp+0x3b>
  800e5b:	0f b6 03             	movzbl (%ebx),%eax
  800e5e:	84 c0                	test   %al,%al
  800e60:	74 30                	je     800e92 <strncmp+0x49>
  800e62:	3a 02                	cmp    (%edx),%al
  800e64:	75 2c                	jne    800e92 <strncmp+0x49>
  800e66:	8d 43 01             	lea    0x1(%ebx),%eax
  800e69:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e6b:	89 c3                	mov    %eax,%ebx
  800e6d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e70:	39 c6                	cmp    %eax,%esi
  800e72:	74 17                	je     800e8b <strncmp+0x42>
  800e74:	0f b6 08             	movzbl (%eax),%ecx
  800e77:	84 c9                	test   %cl,%cl
  800e79:	74 17                	je     800e92 <strncmp+0x49>
  800e7b:	83 c0 01             	add    $0x1,%eax
  800e7e:	3a 0a                	cmp    (%edx),%cl
  800e80:	74 e9                	je     800e6b <strncmp+0x22>
  800e82:	eb 0e                	jmp    800e92 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	eb 0f                	jmp    800e9a <strncmp+0x51>
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	eb 08                	jmp    800e9a <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e92:	0f b6 03             	movzbl (%ebx),%eax
  800e95:	0f b6 12             	movzbl (%edx),%edx
  800e98:	29 d0                	sub    %edx,%eax
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	53                   	push   %ebx
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ea8:	0f b6 10             	movzbl (%eax),%edx
  800eab:	84 d2                	test   %dl,%dl
  800ead:	74 1d                	je     800ecc <strchr+0x2e>
  800eaf:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800eb1:	38 d3                	cmp    %dl,%bl
  800eb3:	75 06                	jne    800ebb <strchr+0x1d>
  800eb5:	eb 1a                	jmp    800ed1 <strchr+0x33>
  800eb7:	38 ca                	cmp    %cl,%dl
  800eb9:	74 16                	je     800ed1 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ebb:	83 c0 01             	add    $0x1,%eax
  800ebe:	0f b6 10             	movzbl (%eax),%edx
  800ec1:	84 d2                	test   %dl,%dl
  800ec3:	75 f2                	jne    800eb7 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	eb 05                	jmp    800ed1 <strchr+0x33>
  800ecc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	53                   	push   %ebx
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  800edb:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ede:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ee1:	38 d3                	cmp    %dl,%bl
  800ee3:	74 14                	je     800ef9 <strfind+0x25>
  800ee5:	89 d1                	mov    %edx,%ecx
  800ee7:	84 db                	test   %bl,%bl
  800ee9:	74 0e                	je     800ef9 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eeb:	83 c0 01             	add    $0x1,%eax
  800eee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ef1:	38 ca                	cmp    %cl,%dl
  800ef3:	74 04                	je     800ef9 <strfind+0x25>
  800ef5:	84 d2                	test   %dl,%dl
  800ef7:	75 f2                	jne    800eeb <strfind+0x17>
			break;
	return (char *) s;
}
  800ef9:	5b                   	pop    %ebx
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f08:	85 c9                	test   %ecx,%ecx
  800f0a:	74 36                	je     800f42 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f0c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f12:	75 28                	jne    800f3c <memset+0x40>
  800f14:	f6 c1 03             	test   $0x3,%cl
  800f17:	75 23                	jne    800f3c <memset+0x40>
		c &= 0xFF;
  800f19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f1d:	89 d3                	mov    %edx,%ebx
  800f1f:	c1 e3 08             	shl    $0x8,%ebx
  800f22:	89 d6                	mov    %edx,%esi
  800f24:	c1 e6 18             	shl    $0x18,%esi
  800f27:	89 d0                	mov    %edx,%eax
  800f29:	c1 e0 10             	shl    $0x10,%eax
  800f2c:	09 f0                	or     %esi,%eax
  800f2e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f30:	89 d8                	mov    %ebx,%eax
  800f32:	09 d0                	or     %edx,%eax
  800f34:	c1 e9 02             	shr    $0x2,%ecx
  800f37:	fc                   	cld    
  800f38:	f3 ab                	rep stos %eax,%es:(%edi)
  800f3a:	eb 06                	jmp    800f42 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3f:	fc                   	cld    
  800f40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f42:	89 f8                	mov    %edi,%eax
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f57:	39 c6                	cmp    %eax,%esi
  800f59:	73 35                	jae    800f90 <memmove+0x47>
  800f5b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f5e:	39 d0                	cmp    %edx,%eax
  800f60:	73 2e                	jae    800f90 <memmove+0x47>
		s += n;
		d += n;
  800f62:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f65:	89 d6                	mov    %edx,%esi
  800f67:	09 fe                	or     %edi,%esi
  800f69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f6f:	75 13                	jne    800f84 <memmove+0x3b>
  800f71:	f6 c1 03             	test   $0x3,%cl
  800f74:	75 0e                	jne    800f84 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f76:	83 ef 04             	sub    $0x4,%edi
  800f79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f7c:	c1 e9 02             	shr    $0x2,%ecx
  800f7f:	fd                   	std    
  800f80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f82:	eb 09                	jmp    800f8d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f84:	83 ef 01             	sub    $0x1,%edi
  800f87:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f8a:	fd                   	std    
  800f8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f8d:	fc                   	cld    
  800f8e:	eb 1d                	jmp    800fad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	09 c2                	or     %eax,%edx
  800f94:	f6 c2 03             	test   $0x3,%dl
  800f97:	75 0f                	jne    800fa8 <memmove+0x5f>
  800f99:	f6 c1 03             	test   $0x3,%cl
  800f9c:	75 0a                	jne    800fa8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f9e:	c1 e9 02             	shr    $0x2,%ecx
  800fa1:	89 c7                	mov    %eax,%edi
  800fa3:	fc                   	cld    
  800fa4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fa6:	eb 05                	jmp    800fad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fa8:	89 c7                	mov    %eax,%edi
  800faa:	fc                   	cld    
  800fab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fb4:	ff 75 10             	pushl  0x10(%ebp)
  800fb7:	ff 75 0c             	pushl  0xc(%ebp)
  800fba:	ff 75 08             	pushl  0x8(%ebp)
  800fbd:	e8 87 ff ff ff       	call   800f49 <memmove>
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
  800fca:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fcd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fd0:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	74 39                	je     801010 <memcmp+0x4c>
  800fd7:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800fda:	0f b6 13             	movzbl (%ebx),%edx
  800fdd:	0f b6 0e             	movzbl (%esi),%ecx
  800fe0:	38 ca                	cmp    %cl,%dl
  800fe2:	75 17                	jne    800ffb <memcmp+0x37>
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe9:	eb 1a                	jmp    801005 <memcmp+0x41>
  800feb:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800ff0:	83 c0 01             	add    $0x1,%eax
  800ff3:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800ff7:	38 ca                	cmp    %cl,%dl
  800ff9:	74 0a                	je     801005 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800ffb:	0f b6 c2             	movzbl %dl,%eax
  800ffe:	0f b6 c9             	movzbl %cl,%ecx
  801001:	29 c8                	sub    %ecx,%eax
  801003:	eb 10                	jmp    801015 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801005:	39 f8                	cmp    %edi,%eax
  801007:	75 e2                	jne    800feb <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
  80100e:	eb 05                	jmp    801015 <memcmp+0x51>
  801010:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	53                   	push   %ebx
  80101e:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801021:	89 d0                	mov    %edx,%eax
  801023:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801026:	39 c2                	cmp    %eax,%edx
  801028:	73 1d                	jae    801047 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80102a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80102e:	0f b6 0a             	movzbl (%edx),%ecx
  801031:	39 d9                	cmp    %ebx,%ecx
  801033:	75 09                	jne    80103e <memfind+0x24>
  801035:	eb 14                	jmp    80104b <memfind+0x31>
  801037:	0f b6 0a             	movzbl (%edx),%ecx
  80103a:	39 d9                	cmp    %ebx,%ecx
  80103c:	74 11                	je     80104f <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80103e:	83 c2 01             	add    $0x1,%edx
  801041:	39 d0                	cmp    %edx,%eax
  801043:	75 f2                	jne    801037 <memfind+0x1d>
  801045:	eb 0a                	jmp    801051 <memfind+0x37>
  801047:	89 d0                	mov    %edx,%eax
  801049:	eb 06                	jmp    801051 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	eb 02                	jmp    801051 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80104f:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801051:	5b                   	pop    %ebx
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
  80105a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801060:	0f b6 01             	movzbl (%ecx),%eax
  801063:	3c 20                	cmp    $0x20,%al
  801065:	74 04                	je     80106b <strtol+0x17>
  801067:	3c 09                	cmp    $0x9,%al
  801069:	75 0e                	jne    801079 <strtol+0x25>
		s++;
  80106b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80106e:	0f b6 01             	movzbl (%ecx),%eax
  801071:	3c 20                	cmp    $0x20,%al
  801073:	74 f6                	je     80106b <strtol+0x17>
  801075:	3c 09                	cmp    $0x9,%al
  801077:	74 f2                	je     80106b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801079:	3c 2b                	cmp    $0x2b,%al
  80107b:	75 0a                	jne    801087 <strtol+0x33>
		s++;
  80107d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801080:	bf 00 00 00 00       	mov    $0x0,%edi
  801085:	eb 11                	jmp    801098 <strtol+0x44>
  801087:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80108c:	3c 2d                	cmp    $0x2d,%al
  80108e:	75 08                	jne    801098 <strtol+0x44>
		s++, neg = 1;
  801090:	83 c1 01             	add    $0x1,%ecx
  801093:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801098:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80109e:	75 15                	jne    8010b5 <strtol+0x61>
  8010a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8010a3:	75 10                	jne    8010b5 <strtol+0x61>
  8010a5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010a9:	75 7c                	jne    801127 <strtol+0xd3>
		s += 2, base = 16;
  8010ab:	83 c1 02             	add    $0x2,%ecx
  8010ae:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010b3:	eb 16                	jmp    8010cb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010b5:	85 db                	test   %ebx,%ebx
  8010b7:	75 12                	jne    8010cb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010b9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010be:	80 39 30             	cmpb   $0x30,(%ecx)
  8010c1:	75 08                	jne    8010cb <strtol+0x77>
		s++, base = 8;
  8010c3:	83 c1 01             	add    $0x1,%ecx
  8010c6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d3:	0f b6 11             	movzbl (%ecx),%edx
  8010d6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010d9:	89 f3                	mov    %esi,%ebx
  8010db:	80 fb 09             	cmp    $0x9,%bl
  8010de:	77 08                	ja     8010e8 <strtol+0x94>
			dig = *s - '0';
  8010e0:	0f be d2             	movsbl %dl,%edx
  8010e3:	83 ea 30             	sub    $0x30,%edx
  8010e6:	eb 22                	jmp    80110a <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8010e8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010eb:	89 f3                	mov    %esi,%ebx
  8010ed:	80 fb 19             	cmp    $0x19,%bl
  8010f0:	77 08                	ja     8010fa <strtol+0xa6>
			dig = *s - 'a' + 10;
  8010f2:	0f be d2             	movsbl %dl,%edx
  8010f5:	83 ea 57             	sub    $0x57,%edx
  8010f8:	eb 10                	jmp    80110a <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  8010fa:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010fd:	89 f3                	mov    %esi,%ebx
  8010ff:	80 fb 19             	cmp    $0x19,%bl
  801102:	77 16                	ja     80111a <strtol+0xc6>
			dig = *s - 'A' + 10;
  801104:	0f be d2             	movsbl %dl,%edx
  801107:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80110a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80110d:	7d 0b                	jge    80111a <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  80110f:	83 c1 01             	add    $0x1,%ecx
  801112:	0f af 45 10          	imul   0x10(%ebp),%eax
  801116:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801118:	eb b9                	jmp    8010d3 <strtol+0x7f>

	if (endptr)
  80111a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80111e:	74 0d                	je     80112d <strtol+0xd9>
		*endptr = (char *) s;
  801120:	8b 75 0c             	mov    0xc(%ebp),%esi
  801123:	89 0e                	mov    %ecx,(%esi)
  801125:	eb 06                	jmp    80112d <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801127:	85 db                	test   %ebx,%ebx
  801129:	74 98                	je     8010c3 <strtol+0x6f>
  80112b:	eb 9e                	jmp    8010cb <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	f7 da                	neg    %edx
  801131:	85 ff                	test   %edi,%edi
  801133:	0f 45 c2             	cmovne %edx,%eax
}
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	5f                   	pop    %edi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    
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
